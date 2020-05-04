package main

import (
	"bytes"
	sha "crypto/sha256"
	b64 "encoding/base64"
	"encoding/json"
	"net/http"
	"os"

	"github.com/gin-gonic/gin"
	log "github.com/sirupsen/logrus"
)

var HASURA_OPERATION = `
	mutation createMessage(
		$subject: String,
		$message: String,
		$name: String,
		$password: String,
		$tripcode: String,
		$attachments: [attachments_insert_input!]!,
		$child_of: [relations_insert_input!]!
	) {
		insert_msgs_one(
			object: {
				message: $message,
				name: $name,
				password: $password,
				subject: $subject,
				tripcode: $tripcode,
				child_of: {data: $child_of},
				attachments: {data: $attachments}
			}
		) {
			id
			created_at
			message
			name
			password
			subject
			tripcode
		}
	}
`

type AttachmentsInput struct {
	FileID string `json:"file_id"`
}

type ChildOfInput struct {
	TargetID string `json:"target_id"`
}

type InputModel struct {
	Subject     *string            `json:"subject"`
	Message     *string            `json:"message"`
	Name        *string            `json:"name"`
	Password    *string            `json:"password"`
	Tripcode    *string            `json:"tripcode"`
	Attachments []AttachmentsInput `json:"attachments"`
	ChildOf     []ChildOfInput     `json:"child_of"`
}

type Req struct {
	Input InputModel `json:"input"`
}

type Transaction struct {
	Query     string     `json:"query"`
	Variables InputModel `json:"variables"`
}

type Resp struct {
	Data *struct {
		Resp interface{} `json:"insert_msgs_one"`
	} `json:"data"`
	Errors *[]interface{} `json:"errors"`
}

func init() {
	log.SetFormatter(&log.TextFormatter{
		FullTimestamp: true,
	})
	log.SetOutput(os.Stdout)
	log.SetLevel(log.InfoLevel)
}

func morphTrip(i string) string {
	hash := sha.Sum256([]byte(i))

	return b64.StdEncoding.EncodeToString(hash[0:9])
}

func doHasuraReq(transaction *Transaction, secret string) (*Resp, error) {
	transactionJSON, _ := json.Marshal(transaction)

	hasuraReq, _ := http.NewRequest("POST", "http://hasura:8080/v1/graphql", bytes.NewReader(transactionJSON))
	hasuraReq.Header.Set("Content-Type", "application/json")
	hasuraReq.Header.Set("x-hasura-admin-secret", secret)

	client := &http.Client{}
	resp, err := client.Do(hasuraReq)
	if err != nil {
		return nil, err
	}

	defer resp.Body.Close()

	data := &Resp{}

	err = json.NewDecoder(resp.Body).Decode(&data)

	if err != nil {
		return nil, err
	}

	return data, nil
}

func main() {
	secret, ok := os.LookupEnv("HASURA_SECRET")
	if !ok {
		panic("HASURA_SECRET env variable is required")
	}

	port, ok := os.LookupEnv("PORT")
	if !ok {
		port = "8080"
	}

	router := gin.Default()

	router.POST("/", func(c *gin.Context) {
		req := Req{}
		if err := c.ShouldBindJSON(&req); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}

		if req.Input.Tripcode != nil {
			realTrip := morphTrip(*req.Input.Tripcode)
			req.Input.Tripcode = &realTrip
		}

		resp, err := doHasuraReq(&Transaction{HASURA_OPERATION, req.Input}, secret)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"message": err.Error()})
			return
		}

		if resp.Errors != nil {
			finalJSON, err := json.Marshal((*resp.Errors)[0])

			if err != nil {
				c.JSON(http.StatusBadRequest, gin.H{"message": err.Error()})
				return
			}

			c.Data(http.StatusBadRequest, "application/json", finalJSON)

			return
		}

		finalJSON, _ := json.Marshal((*resp.Data).Resp)

		c.Data(http.StatusOK, "application/json", finalJSON)
	})

	addr := "0.0.0.0:" + port

	log.WithField("addr", addr).Info("Server has been started")

	router.Use(gin.Recovery())
	router.Run(addr)
}
