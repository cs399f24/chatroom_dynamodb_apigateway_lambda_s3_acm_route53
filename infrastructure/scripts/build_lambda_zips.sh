#!/bin/bash

# Set the base directory for Lambda functions
LAMBDA_BASE_DIR="lambdas"

echo "Building Lambda function ZIP files..."

# Loop through each Lambda function directory
for lambda_dir in $LAMBDA_BASE_DIR/*/; do
    if [[ -d "$lambda_dir" ]]; then
        lambda_name=$(basename "$lambda_dir")
        zip_path="$lambda_dir$lambda_name.zip"
        echo "Processing Lambda function: $lambda_name"

        # Navigate to Lambda function directory
        cd "$lambda_dir" || { echo "Failed to navigate to $lambda_dir"; exit 1; }

        # Check if index.js exists
        if [[ ! -f index.js ]]; then
            echo "index.js not found in $lambda_name, skipping this function."
            cd - > /dev/null || exit 1
            continue
        fi

        # Install dependencies in a temporary directory to avoid polluting the function directory
        mkdir -p temp_node_modules
        npm install --only=prod --prefix temp_node_modules || { echo "npm install failed in $lambda_name"; exit 1; }

        # Check if node_modules exists
        if [[ -d temp_node_modules/node_modules ]]; then
            # Create the ZIP file including `index.js` and `node_modules`
            zip -r "$zip_path" index.js temp_node_modules/node_modules
            echo "Created ZIP file: $zip_path"
        else
            echo "No node_modules found for $lambda_name, skipping zip creation."
        fi

        # Clean up temporary node_modules
        rm -rf temp_node_modules

        # Go back to the root directory
        cd - > /dev/null || { echo "Failed to return to the root directory"; exit 1; }
    else
        echo "No directory found in $LAMBDA_BASE_DIR"
    fi
done

echo "All Lambda functions have been zipped successfully."