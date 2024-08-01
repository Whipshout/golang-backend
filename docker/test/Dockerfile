FROM golang:1.22-alpine

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download

COPY . .

RUN apk add --no-cache curl

CMD ["go", "test", "-v", "./tests/integration/..."]