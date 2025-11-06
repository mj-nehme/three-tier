# Three-Tier Application

![Go](https://github.com/mj-nehme/three-tier/workflows/Go/badge.svg)

A three-tier application that consists of:

- **Client**: Frontend layer for user interaction
- **Login**: A webapp that has a login webpage running on port _8000_. This app is supposed to run in a separate container.
- **MongoDB**: A MongoDB database running on port _27017_. This app is supposed to run in a different docker container.

## Architecture

```
Client (Web Interface) 
    ↓
Login Service (Go - Port 8000)
    ↓  
MongoDB (Database - Port 27017)
```

## Quick Start

### Prerequisites

- Go 1.20 or higher
- Docker
- Docker Compose (optional)

### Building the Application

#### Using Make (Recommended)

```bash
# See all available commands
make help

# Run all development checks (format, lint, build, test)
make dev

# Run CI checks (what GitHub Actions runs)
make ci-test

# Build the application
make build

# Run tests
make test
```

#### Manual Build

```bash
# Navigate to the Go application directory
cd login/gocode

# Download dependencies
go mod download

# Build the application
go build -v main.go

# Run tests
go test -v ./...
```

### Running with Docker Compose (Recommended)

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all services
docker-compose down
```

### Running with Docker (Manual)

```bash
# Build the MongoDB container
docker build -t mongo-app ./mongo

# Build the Login application container  
docker build -t login-app ./login

# Run MongoDB
docker run -d --name mongo-db -p 27017:27017 mongo-app

# Run Login application (replace localhost with container IP if needed)
docker run -d --name login-service -p 8000:80 --link mongo-db:mongo login-app
```

### Running Locally

```bash
# Start MongoDB (requires MongoDB installed locally)
mongod --port 27017

# Run the Go application
cd login/gocode
go run main.go
```

The application will be available at `http://localhost:8000`

## Default Credentials

- Username: `Ahmad`
- Password: `Pass123`

## Development

### Running Tests

```bash
cd login/gocode
go test -v ./...
```

### Code Quality

```bash
# Run linter
go vet ./...

# Format code
go fmt ./...
```

## CI/CD

This project uses GitHub Actions for continuous integration. The pipeline:

1. Builds the Go application
2. Runs tests
3. Performs code quality checks
4. Builds Docker containers
5. Tests container functionality

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and ensure they pass
5. Submit a pull request

## License

This project is open source and available under the [MIT License](LICENSE).
