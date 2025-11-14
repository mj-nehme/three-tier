#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
pushd "$SCRIPT_DIR" || exit
sudo docker build --build-arg MONGODB_IP="172.19.0.5" --build-arg MONGODB_USERNAME="" --build-arg MONGODB_PASSWORD="" --tag course-gocode .
docker run --name gocode-cr --ip 172.19.0.4 --expose 8000 -p 80:8000 --net app-network -d course-gocode
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' gocode-cr
popd || exit
