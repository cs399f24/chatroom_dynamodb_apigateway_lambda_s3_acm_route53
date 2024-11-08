# Overview

![Architecture Diagram](ArchitectureDiagramv4.png)

# AWS Chatroom with DynamoDB, API Gateway, Lambda, S3, ACM, and Route53
A serverless chat application built using various AWS services demonstrating cloud architecture and infrastructure as code.

## Overview
This project sets up a serverless chat application on AWS, including S3 for static file hosting, DynamoDB for storing messages, Lambda for backend logic, and API Gateway for the API endpoint.

## Project Structure
- `infrastructure/`: Contains configuration files and deployment scripts.
- `lambdas/`: Contains Lambda function source code.
- `static/`: Contains static files for the web interface (HTML, CSS, JS).

## Setup Instructions

### How To Run on AWS

#### Clone Repo
```bash
git clone https://github.com/cs399f24/chatroom_dynamodb_apigateway_lambda_s3_acm_route53.git
```

#### Move in to directory
```bash
cd chatroom_dynamodb_apigateway_lambda_s3_acm_route53
```

#### Install Depedencies

```bash
pip install -r dependencies/requirements.txt
```

### AWS Services Used

This project integrates several AWS services:

- DynamoDB: Stores chat messages
- API Gateway: Manages API endpoints
- Lambda: Handles serverless backend logic
- S3: Hosts static website content
- ACM: Provides SSL/TLS certificates
- Route53: Manages DNS and domain routing

### Deployment Scripts

The application includes three main scripts:

#### Deploy all resources:

```bash
chmod +x infrastructure/scripts/deploy.sh
```

```bash
cd infrastructure/scripts
```

```bash
bash deploy.sh
```

#### Start the application:

```bash
chmod +x infrastructure/scripts/up.sh
```

```bash
cd infrastructure/scripts
```

```bash
bash up.sh
```

#### Remove all resources:

```bash
chmod +x scripts/down.sh
./scripts/down.sh
```

### Lambda Functions

The backend consists of two Lambda functions:

getChatMessages:

- Retrieves messages from DynamoDB
- Implements pagination


storeChatMessage:

- Saves new messages to DynamoDB
- Handles message validation



### API Documentation

API specifications are available in api_documentation.yaml and include:

Endpoint definitions
Request/response formats
Authentication requirements

### Architecture

The architecture (shown in ArchitectureDiagramv4.png) demonstrates:

- Secure communication via HTTPS using ACM certificates
- Custom domain routing through Route53
- Static website hosting on S3
- Serverless backend using Lambda and API Gateway
- Persistent storage with DynamoDB

### Contributing

This project is part of CS399 F24. Please follow your instructor's guidelines for contributions and submissions.

