FROM golang:latest

COPY go.mod go.sum ./

RUN go mod download

COPY . .

RUN go build -o ./server main.go

RUN apt-get install ca-certificates

EXPOSE 8080 

ENTRYPOINT ["./server"]