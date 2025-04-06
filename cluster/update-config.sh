#!/bin/bash
set -e

CONFIG_FILE="./rama/rama.yaml"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "❌ Cannot find rama.yaml at $CONFIG_FILE"
  exit 1
fi

# Check if the line already exists to avoid duplicates
if grep -q "^zookeeper.port:" "$CONFIG_FILE"; then
  echo "ℹ️  zookeeper.port already configured in rama.yaml"
else
  echo -e "\nzookeeper.port: 2181" >> "$CONFIG_FILE"
  echo "✅ Added zookeeper.port: 2181 to $CONFIG_FILE"
fi

