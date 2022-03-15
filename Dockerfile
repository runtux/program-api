FROM golang:alpine

RUN mkdir /app
COPY foobar-api/* /app/
COPY certs/* /app/
WORKDIR /app


RUN go mod download



RUN go build -o /docker-app

CMD ["/docker-app"]
