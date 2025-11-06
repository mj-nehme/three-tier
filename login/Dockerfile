FROM golang:1.16-alpine

WORKDIR /app

COPY gocode/* ./

RUN go mod download

EXPOSE 80
ARG MONGODB_IP
ENV MONGODB_IP=$MONGODB_IP

CMD [ "sh", "-c", "go run main.go $MONGODB_IP" ]
