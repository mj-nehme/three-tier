#!/bin/bash
# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
pushd "$SCRIPT_DIR" || exit

docker network create --subnet=172.19.0.0/24 course-net
sudo docker build --tag mongodb .
docker run --name mongodb-cr -p 27017:27017 --ip 172.19.0.5 --expose 27017 --net course-net -d mongodb
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mongodb-cr
popd || exit
