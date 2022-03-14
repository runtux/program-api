FROM golang:alpine

WORKDIR foobar-api
COPY foobar-api/* ./

RUN go get -u github.com/gorilla/websocket
RUN go build -o foobar-api .

CMD ["app"]
