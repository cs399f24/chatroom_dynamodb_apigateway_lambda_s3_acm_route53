#!/bin/bash

# Configuration
AWS_REGION="us-east-2"  # Set your region
API_NAME="ChatAPI"

# Fetch the Account ID dynamically
ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)

# Check if the Account ID was retrieved successfully
if [ -z "$ACCOUNT_ID" ]; then
    echo "Failed to retrieve AWS account ID. Please ensure you have the AWS CLI configured correctly."
    exit 1
fi
echo "Using AWS Account ID: $ACCOUNT_ID"

# Step 1: Create or fetch Lambda execution role

ROLE_NAME="LambdaDynamoDBExecutionRole"
ROLE_POLICY_NAME="LambdaDynamoDBAccessPolicy"

# Check if the IAM role already exists
ROLE_ARN=$(aws iam get-role --role-name $ROLE_NAME --query "Role.Arn" --output text 2>/dev/null)

if [ -z "$ROLE_ARN" ]; then
    echo "Creating IAM role for Lambda with DynamoDB access..."
    # Create the role
    ROLE_ARN=$(aws iam create-role \
        --role-name $ROLE_NAME \
        --assume-role-policy-document '{
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Principal": {
                        "Service": "lambda.amazonaws.com"
                    },
                    "Action": "sts:AssumeRole"
                }
            ]
        }' --query "Role.Arn" --output text)
    
    # Attach the inline policy for DynamoDB access
    aws iam put-role-policy \
        --role-name $ROLE_NAME \
        --policy-name $ROLE_POLICY_NAME \
        --policy-document '{
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Action": [
                        "dynamodb:PutItem",
                        "dynamodb:Scan"
                    ],
                    "Resource": "arn:aws:dynamodb:'"$AWS_REGION"':'"$ACCOUNT_ID"':table/ChatMessages"
                },
                {
                    "Effect": "Allow",
                    "Action": [
                        "logs:CreateLogGroup",
                        "logs:CreateLogStream",
                        "logs:PutLogEvents"
                    ],
                    "Resource": "arn:aws:logs:'"$AWS_REGION"':'"$ACCOUNT_ID"':*"
                }
            ]
        }'
else
    echo "Using existing IAM role: $ROLE_ARN"
fi

# Step 2: Deploy getChatMessages Lambda function
echo "Deploying getChatMessages Lambda..."
aws lambda create-function \
    --function-name getChatMessages \
    --zip-file fileb://lambdas/getChatMessages/getChatMessages.zip \
    --handler index.handler \
    --runtime nodejs18.x \
    --role $ROLE_ARN || echo "Lambda getChatMessages already exists"

# Step 3: Deploy storeChatMessage Lambda function
echo "Deploying storeChatMessage Lambda..."
aws lambda create-function \
    --function-name storeChatMessage \
    --zip-file fileb://lambdas/storeChatMessage/storeChatMessage.zip \
    --handler index.handler \
    --runtime nodejs18.x \
    --role $ROLE_ARN || echo "Lambda storeChatMessage already exists"

# Step 4: Set up API Gateway for the functions

# Create the API Gateway if not already created
API_ID=$(aws apigateway get-rest-apis --query "items[?name=='$API_NAME'].id" --output text)
if [ "$API_ID" == "None" ]; then
    echo "Creating API Gateway..."
    API_ID=$(aws apigateway create-rest-api --name "$API_NAME" --query "id" --output text)
fi
echo "Using API Gateway with ID: $API_ID"

# Get root resource ID for API Gateway
ROOT_RESOURCE_ID=$(aws apigateway get-resources --rest-api-id $API_ID --query "items[?path=='/'].id" --output text)

# Step 5: Configure API Gateway resources and methods for getChatMessages (GET) and storeChatMessage (POST)

# Configure GET route for getChatMessages
echo "Configuring GET route for getChatMessages..."
GET_RESOURCE_ID=$(aws apigateway create-resource \
    --rest-api-id $API_ID \
    --parent-id $ROOT_RESOURCE_ID \
    --path-part "getChatMessages" \
    --query "id" --output text)

aws apigateway put-method \
    --rest-api-id $API_ID \
    --resource-id $GET_RESOURCE_ID \
    --http-method GET \
    --authorization-type "NONE"

aws apigateway put-integration \
    --rest-api-id $API_ID \
    --resource-id $GET_RESOURCE_ID \
    --http-method GET \
    --type AWS_PROXY \
    --integration-http-method GET \
    --uri arn:aws:apigateway:$AWS_REGION:lambda:path/2015-03-31/functions/arn:aws:lambda:$AWS_REGION:$ACCOUNT_ID:function:getChatMessages/invocations

# Allow API Gateway to invoke getChatMessages Lambda
aws lambda add-permission \
    --function-name getChatMessages \
    --statement-id apigateway-get-getChatMessages \
    --action "lambda:InvokeFunction" \
    --principal apigateway.amazonaws.com \
    --source-arn "arn:aws:execute-api:$AWS_REGION:$ACCOUNT_ID:$API_ID/*/GET/getChatMessages"

# Configure POST route for storeChatMessage
echo "Configuring POST route for storeChatMessage..."
POST_RESOURCE_ID=$(aws apigateway create-resource \
    --rest-api-id $API_ID \
    --parent-id $ROOT_RESOURCE_ID \
    --path-part "storeChatMessage" \
    --query "id" --output text)

aws apigateway put-method \
    --rest-api-id $API_ID \
    --resource-id $POST_RESOURCE_ID \
    --http-method POST \
    --authorization-type "NONE"

aws apigateway put-integration \
    --rest-api-id $API_ID \
    --resource-id $POST_RESOURCE_ID \
    --http-method POST \
    --type AWS_PROXY \
    --integration-http-method POST \
    --uri arn:aws:apigateway:$AWS_REGION:lambda:path/2015-03-31/functions/arn:aws:lambda:$AWS_REGION:$ACCOUNT_ID:function:storeChatMessage/invocations

# Allow API Gateway to invoke storeChatMessage Lambda
aws lambda add-permission \
    --function-name storeChatMessage \
    --statement-id apigateway-post-storeChatMessage \
    --action "lambda:InvokeFunction" \
    --principal apigateway.amazonaws.com \
    --source-arn "arn:aws:execute-api:$AWS_REGION:$ACCOUNT_ID:$API_ID/*/POST/storeChatMessage"

# Configure OPTIONS route for CORS preflight on getChatMessages and storeChatMessage
echo "Configuring OPTIONS route for CORS preflight..."
for RESOURCE_ID in $GET_RESOURCE_ID $POST_RESOURCE_ID; do
    aws apigateway put-method \
        --rest-api-id $API_ID \
        --resource-id $RESOURCE_ID \
        --http-method OPTIONS \
        --authorization-type "NONE"

    aws apigateway put-integration \
        --rest-api-id $API_ID \
        --resource-id $RESOURCE_ID \
        --http-method OPTIONS \
        --type MOCK \
        --request-templates '{"application/json":"{\"statusCode\": 200}"}'

    aws apigateway put-method-response \
        --rest-api-id $API_ID \
        --resource-id $RESOURCE_ID \
        --http-method OPTIONS \
        --status-code 200 \
        --response-parameters '{"method.response.header.Access-Control-Allow-Headers":true, "method.response.header.Access-Control-Allow-Methods":true, "method.response.header.Access-Control-Allow-Origin":true}'

    aws apigateway put-integration-response \
        --rest-api-id $API_ID \
        --resource-id $RESOURCE_ID \
        --http-method OPTIONS \
        --status-code 200 \
        --response-parameters '{"method.response.header.Access-Control-Allow-Headers":"\'Content-Type\'", "method.response.header.Access-Control-Allow-Methods":"\'OPTIONS,GET,POST\'", "method.response.header.Access-Control-Allow-Origin":"\'*\'"}'
done

# Step 6: Deploy the API Gateway to a stage (e.g., 'prod')
echo "Deploying API Gateway to 'prod' stage..."
aws apigateway create-deployment \
    --rest-api-id $API_ID \
    --stage-name prod

echo "Deployment completed. API Gateway ID: $API_ID"