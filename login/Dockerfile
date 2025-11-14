FROM golang:1.20-alpine

# Install ca-certificates and git for better module downloads
RUN apk add --no-cache ca-certificates git

WORKDIR /app

# Copy go mod and sum files first for better caching
COPY gocode/go.mod gocode/go.sum ./

# Download dependencies with retry mechanism
RUN go mod download || (sleep 10 && go mod download) || (sleep 30 && go mod download)

# Copy source code
COPY gocode/*.go ./

# Build the application
RUN go build -o main main.go

EXPOSE 8000
ARG MONGODB_IP
ENV MONGODB_IP=$MONGODB_IP
ARG MONGODB_USERNAME
ENV MONGODB_USERNAME=$MONGODB_USERNAME
ARG MONGODB_PASSWORD
ENV MONGODB_PASSWORD=$MONGODB_PASSWORD

CMD [ "sh", "-c", "./main $MONGODB_IP" ]
