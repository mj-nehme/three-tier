#!/bin/bash

# Three-Tier Application Deployment Script for Students
# This script helps you deploy the application step by step

set -e  # Exit on any error

echo "🚀 Three-Tier Application Deployment"
echo "====================================="

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
print_status "Checking prerequisites..."

# Check if Docker is installed and running
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

if ! docker info &> /dev/null; then
    print_error "Docker is not running. Please start Docker."
    exit 1
fi
print_success "Docker is ready ✓"

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    print_warning "kubectl is not installed. You won't be able to use Kubernetes deployment."
    KUBERNETES_AVAILABLE=false
else
    print_success "kubectl is ready ✓"
    KUBERNETES_AVAILABLE=true
fi

# Check if Go is installed
if ! command -v go &> /dev/null; then
    print_error "Go is not installed. Please install Go 1.20+."
    exit 1
fi
print_success "Go is ready ✓"

echo ""
print_status "What would you like to do?"
echo "1) Build and test the application"
echo "2) Deploy with Docker (Simple)"
echo "3) Deploy with Kubernetes (Advanced)"
echo "4) Clean up everything"
echo "5) Show application status"
echo ""

read -p "Enter your choice (1-5): " choice

case $choice in
    1)
        print_status "Building and testing application..."
        make dev
        print_success "Build and tests completed!"
        ;;
    2)
        print_status "Deploying with Docker..."
        
        # Build images
        print_status "Building Docker images..."
        make docker-build
        
        # Stop any existing containers
        print_status "Stopping any existing containers..."
        docker stop mongo-db login-service 2>/dev/null || true
        docker rm mongo-db login-service 2>/dev/null || true
        
        # Start MongoDB
        print_status "Starting MongoDB..."
        docker run -d --name mongo-db -p 27017:27017 mongo-app
        
        # Wait a bit for MongoDB to start
        print_status "Waiting for MongoDB to start..."
        sleep 5
        
        # Start the login service
        print_status "Starting login service..."
        docker run -d --name login-service -p 8000:80 --link mongo-db:mongo login-app mongo-db
        
        # Wait a bit for the service to start
        sleep 3
        
        print_success "Application deployed!"
        print_success "Visit http://localhost:8000 to access the application"
        print_status "Default credentials: Username=Ahmad, Password=Pass123"
        ;;
    3)
        if [ "$KUBERNETES_AVAILABLE" = false ]; then
            print_error "Kubernetes is not available. Please install kubectl first."
            exit 1
        fi
        
        print_status "Deploying with Kubernetes..."
        
        # Build images first
        print_status "Building Docker images..."
        make docker-build
        
        # Deploy to Kubernetes
        print_status "Applying Kubernetes manifests..."
        make k8s-deploy
        
        # Wait for pods to be ready
        print_status "Waiting for pods to be ready..."
        kubectl wait --for=condition=ready pod -l app=mongodb -n three-tier-app --timeout=60s
        kubectl wait --for=condition=ready pod -l app=login-app -n three-tier-app --timeout=60s
        
        # Show status
        print_status "Application status:"
        make k8s-status
        
        print_success "Kubernetes deployment completed!"
        print_status "Use 'kubectl port-forward service/login-app-service 8000:80 -n three-tier-app' to access the application"
        ;;
    4)
        print_status "Cleaning up..."
        
        # Clean Docker containers
        print_status "Stopping Docker containers..."
        docker stop mongo-db login-service 2>/dev/null || true
        docker rm mongo-db login-service 2>/dev/null || true
        
        # Clean Kubernetes deployment
        if [ "$KUBERNETES_AVAILABLE" = true ]; then
            print_status "Cleaning Kubernetes deployment..."
            make k8s-clean
        fi
        
        # Clean build artifacts
        make clean
        
        print_success "Cleanup completed!"
        ;;
    5)
        print_status "Checking application status..."
        
        echo ""
        echo "Docker Containers:"
        docker ps | grep -E "(mongo-db|login-service)" || echo "No Docker containers running"
        
        if [ "$KUBERNETES_AVAILABLE" = true ]; then
            echo ""
            echo "Kubernetes Status:"
            kubectl get all -n three-tier-app 2>/dev/null || echo "No Kubernetes deployment found"
        fi
        ;;
    *)
        print_error "Invalid choice. Please run the script again and choose 1-5."
        exit 1
        ;;
esac

echo ""
print_success "Script completed successfully! 🎉"