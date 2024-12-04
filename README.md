# Overview

![Architecture Diagram](ArchitectureDiagramv4.png)

# AWS Chatroom with DynamoDB, API Gateway, Lambda, S3, ACM, and Route53
A serverless chat application built using various AWS services demonstrating cloud architecture and infrastructure as code.

## Architecture

- Frontend: Static website hosted on S3
- Backend: Serverless architecture using AWS Lambda and API Gateway
- Database: DynamoDB
- DNS: Route 53

## Prerequisites

- Python 3.8+
- AWS CLI configured with appropriate permissions
- Node.js 18+ (for Lambda functions)
- AWS account with access to:
  - DynamoDB
  - API Gateway
  - Lambda
  - S3
  - Route 53
  - ACM
  - Secrets Manager

## Setup

1. Clone the repository:
```bash
git clone https://github.com/yourusername/chatroom-deployment.git
cd chatroom-deployment
```

2. Install Python dependencies:
```bash
pip install -r requirements.txt
```

3. Set up AWS Secrets:
```bash
python scripts/setup-secrets.py
```

4. Deploy the infrastructure:
```bash
python infrastructure/deploy.py
```

## Project Structure

- `src/static/`: Contains the website files
- `src/lambda/`: Contains Lambda function code
- `infrastructure/`: Contains deployment scripts and API definitions
- `scripts/`: Contains utility scripts

## Deployment

The deployment script will:
1. Create/update DynamoDB table
2. Deploy API Gateway using swagger definition
3. Set up S3 bucket for static website hosting
4. Upload static files
5. Configure DNS settings
### Contributing

This project is part of CS399 F24. Please follow your instructor's guidelines for contributions and submissions.

