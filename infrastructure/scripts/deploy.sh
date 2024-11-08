#!/bin/bash

# Define constants
AWS_REGION="us-east-2"
UUID=$(date +%s)  # Replace this with a consistent UUID if necessary

# Define Lambda function names
LAMBDA_FUNCTION_NAME_GET="newGetChatMessages_$UUID"
LAMBDA_FUNCTION_NAME_STORE="newStoreChatMessage_$UUID"

# Create a virtual environment in a temporary folder
TEMP_DIR=$(mktemp -d)
python3 -m venv $TEMP_DIR/venv

# Activate the virtual environment
source $TEMP_DIR/venv/bin/activate

# Install dependencies in the virtual environment
pip install -r infrastructure/lambdas/requirements.txt

# Run the up.sh script
echo "Running the up.sh script to deploy resources..."
bash infrastructure/scripts/up.sh

# Deactivate the virtual environment
deactivate

# Clean up the temporary directory
rm -rf $TEMP_DIR

echo "Deployment completed."