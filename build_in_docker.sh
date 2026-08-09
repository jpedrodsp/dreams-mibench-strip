#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Configuration
IMAGE_NAME="dreams-mibench-build"
WORKSPACE_DIR="$(pwd)"

echo "=========================================================="
echo " Starting DREAMS MiBench Compilation inside Docker"
echo "=========================================================="

# Check if docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Error: Docker is not installed or not in your PATH."
    echo "Please install Docker and try again."
    exit 1
fi

# Build the Docker image
echo "🔨 Building Docker image: ${IMAGE_NAME}..."
docker build -t "${IMAGE_NAME}" -f Dockerfile .

# Run the compilation inside the container
echo "🚀 Running compilation script in Docker container..."
echo "📂 Mounting host directory: ${WORKSPACE_DIR} to container: /workspace"

docker run --rm \
    -v "${WORKSPACE_DIR}":/workspace \
    -w /workspace \
    "${IMAGE_NAME}" \
    ./compile.sh

echo "=========================================================="
echo " ✅ Compilation completed successfully!"
echo " Compiled binaries are available in your local directories."
echo "=========================================================="
