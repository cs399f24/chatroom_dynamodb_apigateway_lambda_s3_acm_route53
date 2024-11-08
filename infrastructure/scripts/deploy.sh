#!/bin/bash

# Move to the project root
cd "$(dirname "$0")"/../../

# Set up paths
VENV_DIR="dependencies/venv"
REQUIREMENTS_FILE="dependencies/requirements.txt"
UP_SCRIPT="infrastructure/scripts/up.sh"
BUILD_ZIP_SCRIPT="scripts/build_lambda_zips.sh"  # Path to the ZIP building script

# Check for and create virtual environment
if [ ! -d "$VENV_DIR" ]; then
    echo "Creating virtual environment..."
    python3 -m venv "$VENV_DIR"
fi

# Activate virtual environment
source "$VENV_DIR/bin/activate"

# Install dependencies
if [ -f "$REQUIREMENTS_FILE" ]; then
    echo "Installing dependencies from $REQUIREMENTS_FILE..."
    pip install -r "$REQUIREMENTS_FILE"
else
    echo "Requirements file not found: $REQUIREMENTS_FILE"
    exit 1
fi

# Build Lambda ZIP files
if [ -f "$BUILD_ZIP_SCRIPT" ]; then
    echo "Building Lambda ZIP files..."
    bash "$BUILD_ZIP_SCRIPT"
else
    echo "Build script not found: $BUILD_ZIP_SCRIPT"
    exit 1
fi

# Run the up.sh deployment script
if [ -f "$UP_SCRIPT" ]; then
    echo "Running the up.sh script to deploy resources..."
    bash "$UP_SCRIPT"
else
    echo "Deployment script not found: $UP_SCRIPT"
    exit 1
fi

# Deactivate virtual environment
deactivate

echo "Deployment completed."