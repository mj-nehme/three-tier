# Three-Tier Application Tutorial 📚

![Go](https://github.com/mj-nehme/three-tier/workflows/Go/badge.svg)
[![codecov](https://codecov.io/gh/mj-nehme/three-tier/branch/master/graph/badge.svg)](https://codecov.io/gh/mj-nehme/three-tier)

## 🎓 Learning Objectives

This project teaches you how to build and deploy a **three-tier application** using modern technologies. Perfect for students learning about:

- **Backend Development** with Go (Golang)
- **Database Integration** with MongoDB
- **Containerization** with Docker
- **Orchestration** with Kubernetes
- **CI/CD** with GitHub Actions

## 🏗️ What is a Three-Tier Application?

A three-tier application separates your code into three layers:

```
┌─────────────────────┐
│   Presentation      │  ← Frontend (Web Browser)
│      Layer          │
└─────────────────────┘
           │
┌─────────────────────┐
│    Application      │  ← Backend Logic (Go App)
│      Layer          │    Port 80 (exposed from 8000)
└─────────────────────┘
           │
┌─────────────────────┐
│      Data           │  ← Database (MongoDB)
│      Layer          │    Port 27017
└─────────────────────┘
```

### Our Application Components:

- **Frontend Layer**: Simple HTML login form
- **Backend Layer**: Go web server handling authentication
- **Database Layer**: MongoDB storing user credentials

## 🚀 Quick Start Guide

### Step 1: Check Prerequisites

Make sure you have these installed:

```bash
# Check Go installation
go version  # Should show Go 1.20+

# Check Docker installation  
docker --version

# Check Kubernetes (kubectl)
kubectl version --client

# For local Kubernetes, you can use:
# - Docker Desktop (includes Kubernetes)
# - minikube
# - kind
```

### Step 2: Clone and Build

```bash
# Clone the repository
git clone https://github.com/mj-nehme/three-tier.git
cd three-tier

# See all available commands
make help

# Build and test everything
make dev
```

### Step 3A: Running with Docker (Simple Way)

```bash
# Build Docker images
make docker-build

# Run MongoDB container (without authentication)
docker run -d --name mongo-db -p 27017:27017 mongo-app

# Run the Go application container (without authentication)
docker run -d --name login-service -p 80:8000 \
  --link mongo-db:mongo login-app mongo-db

# Visit http://localhost:80 in your browser
```

**Why Port 80?** The Go app runs on port 8000 inside the container, but Docker maps it to port 80 on your computer to avoid conflicts.

#### Running with MongoDB Authentication (Recommended for Production)

```bash
# Run MongoDB container with authentication
docker run -d --name mongo-db \
  -e MONGO_INITDB_ROOT_USERNAME=admin \
  -e MONGO_INITDB_ROOT_PASSWORD=secretpassword \
  -p 27017:27017 mongo-app

# Run the Go application container with MongoDB credentials
docker run -d --name login-service \
  -e MONGODB_USERNAME=admin \
  -e MONGODB_PASSWORD=secretpassword \
  -p 80:8000 \
  --link mongo-db:mongo login-app mongo-db
```

**📖 See [MONGODB_AUTH.md](MONGODB_AUTH.md) for detailed MongoDB authentication setup and Kubernetes examples.**


### Step 3B: Running with Kubernetes (Advanced Way)

```bash
# Deploy to Kubernetes
make k8s-deploy

# Check if everything is running
make k8s-status

# Get the external IP (for LoadBalancer)
kubectl get service login-app-loadbalancer -n three-tier-app

# Clean up when done
make k8s-clean
```

## 🔧 Understanding the Code

### Backend (Go Application)

The main application is in `login/gocode/main.go`:

```go
// The app listens on port 8000 (internal)
var http_port = 8000
var mongodb_port = 27017

// Default credentials for testing
var username = "Ahmad"
var password = "Pass123"
```

**Key Features:**
- Session management with secure cookies
- MongoDB integration
- Simple HTML forms
- HTTP routing with Gorilla Mux

### Database (MongoDB)

- **Database**: `login_app` 
- **Collection**: `users`
- **Default User**: Ahmad / Pass123

## 📁 Project Structure

```
three-tier/
├── README.md              # You are here!
├── Makefile              # Build automation
├── .github/workflows/    # CI/CD automation
│   └── go.yml           # GitHub Actions
├── login/               # Backend application
│   ├── Dockerfile       # Container definition
│   └── gocode/         # Go source code
│       ├── main.go     # Main application
│       ├── main_test.go # Tests
│       ├── go.mod      # Dependencies
│       └── go.sum      # Dependency checksums
├── mongo/              # Database
│   └── Dockerfile     # MongoDB container
└── k8s/               # Kubernetes deployments
    ├── mongodb-deployment.yaml
    ├── login-app-deployment.yaml
    └── kustomization.yaml
```

## 🧪 Testing Your Knowledge

### 1. Basic Testing

```bash
# Run unit tests
make test

# Run tests with coverage
make test-coverage
# This creates coverage.html - open it in your browser!
```

### 2. Manual Testing

1. **Start the application** (Docker or Kubernetes)
2. **Open your browser** to http://localhost:8000
3. **Try logging in** with:
   - Username: `Ahmad`
   - Password: `Pass123`
4. **Try wrong credentials** to see error handling

### 3. Understanding Docker

```bash
# Build images manually
docker build -t login-app ./login
docker build -t mongo-app ./mongo

# See what's inside
docker images
docker run -it login-app sh  # Explore the container
```

### 4. Understanding Kubernetes

```bash
# Apply deployments step by step
kubectl apply -f k8s/mongodb-deployment.yaml
kubectl apply -f k8s/login-app-deployment.yaml

# Watch pods start up
kubectl get pods -n three-tier-app -w

# See logs
kubectl logs -n three-tier-app deployment/login-app
kubectl logs -n three-tier-app deployment/mongodb
```

## 🔬 Advanced Experiments

### Experiment 1: Scaling the Application

```bash
# Scale the login app to 5 replicas
kubectl scale deployment login-app --replicas=5 -n three-tier-app

# Watch the pods
kubectl get pods -n three-tier-app -w
```

### Experiment 2: Modify the Code

1. Change the default username/password in `login/gocode/main.go`
2. Rebuild: `make docker-build`
3. Redeploy: `make k8s-deploy`
4. Test your changes!

### Experiment 3: Add More Tests

1. Look at `login/gocode/main_test.go`
2. Add a new test function
3. Run `make test` to see it work

## 🐛 Troubleshooting

### Common Issues:

**"Cannot connect to MongoDB"**
```bash
# Check if MongoDB pod is running
kubectl get pods -n three-tier-app
kubectl logs deployment/mongodb -n three-tier-app
```

**"Port already in use"**
```bash
# Kill any processes using port 80
lsof -ti:80 | xargs kill
```

**"Docker image not found"**
```bash
# Make sure you built the images
make docker-build
```

**"Kubectl command not found"**
- Install kubectl or enable Kubernetes in Docker Desktop

## 📊 Monitoring and CI/CD

### Code Quality

This project uses:
- **GitHub Actions** for automated testing
- **CodeCov** for test coverage tracking
- **Go vet** for code quality
- **Go fmt** for code formatting

### Viewing Coverage

1. Run `make test-coverage`
2. Open `login/gocode/coverage.html` in your browser
3. See which parts of your code are tested!

## 🎯 Next Steps

Once you understand this project, try:

1. **Add a frontend framework** (React, Vue, etc.)
2. **Add user registration** functionality
3. **Use environment variables** for configuration
4. **Add logging** and monitoring
5. **Deploy to a cloud provider** (AWS, GCP, Azure)
6. **Add HTTPS/TLS** security
7. **Implement real authentication** (JWT tokens, OAuth)

## 🤝 Contributing

Found a bug? Want to add a feature? Great!

1. Fork the repository
2. Create a feature branch: `git checkout -b my-new-feature`
3. Make your changes
4. Run tests: `make ci-test`
5. Commit: `git commit -am 'Add some feature'`
6. Push: `git push origin my-new-feature`
7. Submit a pull request

## 📚 Additional Resources

- [Go Tutorial](https://tour.golang.org/)
- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Basics](https://kubernetes.io/docs/tutorials/kubernetes-basics/)
- [MongoDB Tutorial](https://docs.mongodb.com/manual/tutorial/)

## ❓ Getting Help

- 📧 Create an issue in this repository
- 💬 Ask questions in the GitHub discussions
- 🔍 Check the troubleshooting section above

---

**Happy Learning! 🎉**
