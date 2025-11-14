# MongoDB Authentication Guide

This guide explains how to use MongoDB authentication with the three-tier application.

## Overview

The application now supports MongoDB authentication through environment variables. When credentials are provided, the application will connect to MongoDB using authenticated connections. If no credentials are provided, it will attempt to connect without authentication (backward compatible).

## Environment Variables

### For the Login Application

Set these environment variables when running the login application:

- `MONGODB_USERNAME` - The MongoDB username
- `MONGODB_PASSWORD` - The MongoDB password

### For the MongoDB Container

Set these environment variables when running the MongoDB container:

- `MONGO_INITDB_ROOT_USERNAME` - Creates a root user with this username
- `MONGO_INITDB_ROOT_PASSWORD` - Sets the password for the root user

## Usage Examples

### Running with Docker

#### 1. Start MongoDB with authentication

```bash
docker run -d --name mongo-db \
  -e MONGO_INITDB_ROOT_USERNAME=admin \
  -e MONGO_INITDB_ROOT_PASSWORD=secretpassword \
  -p 27017:27017 \
  mongo-app
```

#### 2. Start the login application with MongoDB credentials

```bash
docker run -d --name login-service \
  -e MONGODB_USERNAME=admin \
  -e MONGODB_PASSWORD=secretpassword \
  -p 80:8000 \
  --link mongo-db:mongo \
  login-app mongo-db
```

### Running with Docker Compose

Create a `docker-compose.yml` file:

```yaml
version: '3.8'

services:
  mongodb:
    image: mongo-app
    environment:
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: secretpassword
    ports:
      - "27017:27017"
    networks:
      - three-tier-net

  login-app:
    image: login-app
    environment:
      MONGODB_USERNAME: admin
      MONGODB_PASSWORD: secretpassword
    command: ["sh", "-c", "./main mongodb"]
    ports:
      - "80:8000"
    depends_on:
      - mongodb
    networks:
      - three-tier-net

networks:
  three-tier-net:
    driver: bridge
```

Then run:

```bash
docker-compose up -d
```

### Running without Authentication (Backward Compatible)

If you don't set the authentication environment variables, the application will work as before without authentication:

```bash
# MongoDB without auth
docker run -d --name mongo-db -p 27017:27017 mongo-app

# Login app without auth credentials
docker run -d --name login-service -p 80:8000 --link mongo-db:mongo login-app mongo-db
```

## Kubernetes Deployment

For Kubernetes deployments, you can use Secrets to store credentials:

### 1. Create a Secret

```bash
kubectl create secret generic mongodb-credentials \
  --from-literal=username=admin \
  --from-literal=password=secretpassword \
  -n three-tier-app
```

### 2. Reference in Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: login-app
spec:
  template:
    spec:
      containers:
      - name: login-app
        image: login-app
        env:
        - name: MONGODB_USERNAME
          valueFrom:
            secretKeyRef:
              name: mongodb-credentials
              key: username
        - name: MONGODB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mongodb-credentials
              key: password
```

## Security Best Practices

1. **Never commit credentials to source control** - Use environment variables or secrets management
2. **Use strong passwords** - Generate random, complex passwords for production
3. **Rotate credentials regularly** - Change passwords periodically
4. **Use Kubernetes Secrets** - For Kubernetes deployments, always use Secrets, not ConfigMaps
5. **Limit network access** - Ensure MongoDB is not exposed to the public internet
6. **Use TLS/SSL** - For production, configure MongoDB to use encrypted connections

## Testing

The application includes tests for MongoDB authentication:

```bash
cd login/gocode
go test -v -run TestGetMongoDBCredentials
```

## Troubleshooting

### Connection Fails with Authentication

If you see errors like "authentication failed" or "server selection timeout":

1. Verify that the MongoDB username and password match in both containers
2. Ensure the MongoDB container has finished initializing before the login app starts
3. Check that the `MONGO_INITDB_ROOT_USERNAME` and `MONGO_INITDB_ROOT_PASSWORD` are set on the MongoDB container
4. Verify network connectivity between containers

### Application Still Uses Hardcoded Credentials

If the application uses hardcoded credentials (Ahmad/Pass123) instead of the database:

1. Check that the `MONGODB_USERNAME` and `MONGODB_PASSWORD` environment variables are set
2. Verify that the MongoDB connection succeeds (check logs)
3. Ensure the MongoDB service is running and accessible

### View Application Logs

```bash
# For Docker
docker logs login-service

# For Kubernetes
kubectl logs deployment/login-app -n three-tier-app
```

The logs will show:
- MongoDB IP being used
- Whether credentials were loaded from environment variables
- Connection success/failure messages
