# Multi-stage build for PadCare Go Translation Service
FROM golang:1.21-alpine AS builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o /translate-server .

# Minimal runtime image
FROM alpine:3.18
RUN apk --no-cache add ca-certificates

WORKDIR /root/
COPY --from=builder /translate-server .

EXPOSE 8000

ENTRYPOINT ["./translate-server"]
