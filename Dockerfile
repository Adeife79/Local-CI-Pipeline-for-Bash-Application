FROM bash:5.2

RUN apk add --no-cache coreutils musl-utils
WORKDIR /opt/devops-tool
COPY app/app.sh ./app.sh
RUN chmod +x ./app.sh

ENTRYPOINT ["./app.sh"]
CMD ["help"]
