#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
pushd "$SCRIPT_DIR" || exit
sudo docker build --build-arg MONGODB_IP="172.19.0.5" --tag course-gocode .
docker run --name gocode-cr --ip 172.19.0.4 --expose 80 -p 80:80 --net course-net -d course-gocode
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' gocode-cr
popd || exit
