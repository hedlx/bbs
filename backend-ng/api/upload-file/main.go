package main

import (
	"fmt"
	"image"
	"image/jpeg"
	"image/png"
	"io"
	"io/ioutil"
	"net/http"
	"os"

	"github.com/disintegration/imaging"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/h2non/filetype"
	minio "github.com/minio/minio-go/v6"
	log "github.com/sirupsen/logrus"
)

func init() {
	log.SetFormatter(&log.TextFormatter{
		FullTimestamp: true,
	})
	log.SetOutput(os.Stdout)
	log.SetLevel(log.InfoLevel)
}

func setUpMinio(bucket string) (*minio.Client, error) {
	endpoint := "minio:9000"
	accessKey, ok := os.LookupEnv("MINIO_ACCESS_KEY")
	if !ok {
		return nil, fmt.Errorf("MINIO_ACCESS_KEY env variable is required")
	}

	secretKey, ok := os.LookupEnv("MINIO_SECRET_KEY")
	if !ok {
		return nil, fmt.Errorf("MINIO_SECRET_KEY env variable is required")
	}

	client, err := minio.New(endpoint, accessKey, secretKey, false)
	if err != nil {
		return nil, err
	}

	exists, err := client.BucketExists(bucket)
	if err != nil {
		return nil, err
	}

	if !exists {
		err = client.MakeBucket(bucket, "")
		if err != nil {
			return nil, err
		}
	}

	policy := `{
		"Version":"2012-10-17",
		"Statement":[
			{
				"Effect":"Allow",
				"Principal":{"AWS":["*"]},
				"Action":["s3:GetBucketLocation","s3:ListBucket"],
				"Resource":["arn:aws:s3:::` + bucket + `"]
			},
			{
				"Effect":"Allow",
				"Principal":{"AWS":["*"]},
				"Action":["s3:GetObject"],
				"Resource":["arn:aws:s3:::` + bucket + `/*"]
			}
		]
	}`

	err = client.SetBucketPolicy(bucket, policy)
	if err != nil {
		return nil, err
	}

	return client, nil
}

func main() {
	bucket, ok := os.LookupEnv("MINIO_BUCKET")
	if !ok {
		panic("MINIO_BUCKET env variable is required")
	}

	minioClient, err := setUpMinio(bucket)
	if err != nil {
		panic(err.Error())
	}

	router := gin.Default()

	router.POST("/", func(c *gin.Context) {
		file, err := c.FormFile("file")
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"message": err.Error()})
			return
		}

		// TODO: Move to common limits
		var maxSize int64 = 5 * 1024 * 1024
		if file.Size > maxSize {
			c.JSON(http.StatusBadRequest, gin.H{"message": "File exceeded limit: " + fmt.Sprintf("%d", maxSize)})
			return
		}

		srcFile, err := file.Open()
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
			return
		}

		defer srcFile.Close()

		imageFile, err := ioutil.TempFile("/tmp", "minio-*")
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
			return
		}

		defer imageFile.Close()
		defer os.Remove(imageFile.Name())

		_, err = io.Copy(imageFile, srcFile)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
			return
		}

		kind, err := filetype.MatchFile(imageFile.Name())
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
			return
		}

		if kind.MIME.Type != "image" {
			c.JSON(http.StatusBadRequest, gin.H{"message": "Unsupported file type"})
			return
		}

		subtype := kind.MIME.Subtype

		if subtype != "jpeg" &&
			subtype != "png" &&
			subtype != "gif" {
			c.JSON(http.StatusBadRequest, gin.H{"message": "Unsupported file type"})
			return
		}

		imageFile.Seek(0, 0)
		image, _, err := image.Decode(imageFile)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"message": err.Error()})
			return
		}

		imageBounds := image.Bounds()
		previewSize := 1024

		thumbWidth := imageBounds.Dx()
		thumbHeight := imageBounds.Dy()

		if thumbWidth > previewSize || thumbHeight > previewSize {
			if thumbWidth > thumbHeight {
				thumbWidth = previewSize
				thumbHeight = 0
			} else {
				thumbHeight = previewSize
				thumbWidth = 0
			}
		}

		thumbImage := imaging.Resize(image, thumbWidth, thumbHeight, imaging.Lanczos)

		thumbFile, err := ioutil.TempFile("/tmp", "minio-*.thumb")
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
			return
		}

		defer thumbFile.Close()
		defer os.Remove(thumbFile.Name())

		thumbSubtype := ""

		if subtype == "jpeg" {
			err = jpeg.Encode(thumbFile, thumbImage, nil)
			if err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
				return
			}

			thumbSubtype = "jpeg"
		} else if subtype == "png" {
			err = png.Encode(thumbFile, thumbImage)
			if err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
				return
			}

			thumbSubtype = "png"
		} else if subtype == "gif" {
			err = png.Encode(thumbFile, thumbImage)
			if err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
				return
			}

			thumbSubtype = "png"
		}

		id := uuid.New().String()
		fmt.Println(id)
		_, err = minioClient.FPutObject(bucket, id, imageFile.Name(), minio.PutObjectOptions{ContentType: "image/" + subtype})
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
			return
		}

		_, err = minioClient.FPutObject(bucket, id+".thumb", thumbFile.Name(), minio.PutObjectOptions{ContentType: "image/" + thumbSubtype})
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"message": err.Error()})
			return
		}

		c.JSON(http.StatusOK, gin.H{"id": id})
	})

	port, ok := os.LookupEnv("PORT")
	if !ok {
		port = "8080"
	}

	addr := "0.0.0.0:" + port

	log.WithField("addr", addr).Info("Server has been started")

	router.Use(gin.Recovery())
	router.Run(addr)
}
