FROM alpine:3.15.4

RUN apk add --no-cache bash curl jq

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]