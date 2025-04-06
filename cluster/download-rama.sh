#!/bin/bash

set -e

RAMA_VERSION="1.0.0"
RAMA_ZIP_URL="https://redplanetlabs.s3.us-west-2.amazonaws.com/rama/rama-${RAMA_VERSION}.zip"
RAMA_DIR="rama/"
ZIP_FILE="${RAMA_DIR}.zip"

# Choose install directory (default: current dir)
INSTALL_DIR="${1:-$PWD}"
TARGET_DIR="$INSTALL_DIR/$RAMA_DIR"

mkdir -p "$TARGET_DIR"
cd "$INSTALL_DIR"

echo "Downloading Rama $RAMA_VERSION from:"
echo "$RAMA_ZIP_URL"
curl -LO "$RAMA_ZIP_URL"

echo "Unzipping into $TARGET_DIR..."
unzip -q "$ZIP_FILE" -d "$TARGET_DIR"

echo "Cleaning up zip file..."
rm "$ZIP_FILE"

echo "Rama installed in: $TARGET_DIR"
echo "To try it out: cd $TARGET_DIR"

