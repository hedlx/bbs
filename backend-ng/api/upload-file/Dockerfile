FROM golang:1.13-alpine

RUN mkdir -p /go/src/lambda
ADD . /go/src/lambda


RUN cd /go/src/lambda && go build && cp upload-file /go

ENTRYPOINT /go/upload-file
