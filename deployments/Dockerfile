#######################
## The builder image ##
#######################
FROM golang:1.22-alpine3.19 AS builder

ENV CGO_ENABLED=1

WORKDIR /app

RUN apk add --no-cache build-base=0.5-r3
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN go build -ldflags "-w -s" -o relink cmd/relink/main.go

#######################
## The final image   ##
#######################
FROM alpine:3.19

LABEL maintainer="cmj <cmj@cmj.tw>"
LABEL description="The simple URL shorten and rename service"
LABEL version="0.1.0"

WORKDIR /app

COPY --from=builder /app/relink /usr/local/bin/relink
COPY deployments/entrypoint.sh /entrypoint.sh

CMD ["/entrypoint.sh"]