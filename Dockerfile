FROM alpine:latest

RUN apk add --no-cache bash curl

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]