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
        cd "$lambda_dir" || exit

        # Install dependencies in a temporary directory to avoid polluting the function directory
        mkdir -p temp_node_modules
        npm install --only=prod --prefix temp_node_modules

        # Create the ZIP file including `index.js` and `node_modules`
        zip -r "$zip_path" index.js temp_node_modules/node_modules

        # Clean up temporary node_modules
        rm -rf temp_node_modules
        echo "Created ZIP file: $zip_path"

        # Go back to the root directory
        cd - > /dev/null || exit
    fi
done

echo "All Lambda functions have been zipped successfully."