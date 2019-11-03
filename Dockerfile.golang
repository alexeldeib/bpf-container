FROM golang:1.13.4-buster

RUN mkdir -p /bpf
WORKDIR /bpf

ADD go.mod .
ADD go.sum .
ADD vendor vendor
ADD main.go .
ADD start.sh .

RUN chmod +x start.sh

RUN go build -mod vendor -o bpf .