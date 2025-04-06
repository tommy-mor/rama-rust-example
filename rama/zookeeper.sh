#!/bin/bash

set -e

echo "📦 Pulling Zookeeper image..."
#docker pull zookeeper:3.8

echo "🚀 Starting Zookeeper container..."
docker run --name rama-zookeeper --restart always -p 2181:2181 -d zookeeper

echo "✅ Zookeeper is now running on port 2181."
echo "You can check logs with: docker logs -f rama-zookeeper"
