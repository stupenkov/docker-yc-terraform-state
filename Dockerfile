FROM stupean/yandex-terraform:latest

COPY terraform/ /app/

WORKDIR /app

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]