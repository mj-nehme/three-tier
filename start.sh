#!/bin/bash
./clean.sh
./mongo/run_mongodb.sh
./login/run_logincode.sh

echo ""
echo "🚀 Application started successfully!"
echo ""
echo "📊 Container Status:"
echo "===================="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" --filter "name=mongodb-cr" --filter "name=gocode-cr"
echo ""
echo "💡 Tips:"
echo "- Use 'docker logs gocode-cr' to view application logs"
echo "- Use 'docker logs mongodb-cr' to view database logs"
echo "- Use './clean.sh' to stop and remove all containers"
echo ""
echo "📍 Available Endpoints:"
echo "===================="
echo "🌐 Web Application: http://localhost:80"
echo "🗄️  MongoDB:        mongodb://localhost:27017"