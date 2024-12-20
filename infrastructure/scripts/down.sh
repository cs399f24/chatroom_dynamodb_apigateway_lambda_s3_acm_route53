#!/bin/bash

# Set AWS Region
AWS_REGION="us-east-2"
UUID="<use-same-UUID-as-deployed>"  # Replace with the UUID used in deploy/up script for consistency

# Define Lambda function names and API name
LAMBDA_FUNCTION_NAME_GET="getChatMessages"  # Use the actual function name
LAMBDA_FUNCTION_NAME_STORE="storeChatMessage"  # Use the actual function name
API_NAME="ChatAPI"

# Delete Lambda functions
echo "Deleting Lambda functions..."
aws lambda delete-function --function-name $LAMBDA_FUNCTION_NAME_GET --region $AWS_REGION
aws lambda delete-function --function-name $LAMBDA_FUNCTION_NAME_STORE --region $AWS_REGION
echo "Lambda functions deleted."

# Delete API Gateway
API_ID=$(aws apigateway get-rest-apis --query "items[?name=='$API_NAME'].id" --output text --region $AWS_REGION)
if [ "$API_ID" != "None" ]; then
    echo "Deleting API Gateway with ID: $API_ID"
    aws apigateway delete-rest-api --rest-api-id $API_ID --region $AWS_REGION
    echo "API Gateway deleted."
else
    echo "No API Gateway found with name $API_NAME."
fi

# Optionally, delete DynamoDB table (if created dynamically)
DYNAMODB_TABLE_NAME="ChatMessages"  # Use the actual table name
echo "Deleting DynamoDB table..."
aws dynamodb delete-table --table-name $DYNAMODB_TABLE_NAME --region $AWS_REGION
echo "DynamoDB table deleted."

echo "All resources have been successfully removed."