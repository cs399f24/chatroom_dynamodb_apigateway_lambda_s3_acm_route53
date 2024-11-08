// index.js
import { DynamoDB } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocument } from '@aws-sdk/lib-dynamodb';

const client = new DynamoDB({});
const dynamodb = DynamoDBDocument.from(client);

export const handler = async (event) => {
    try {
        console.log("Full event received:", JSON.stringify(event, null, 2)); // Log the full event for debugging

        // Check for both direct properties and event.body
        let username, message;
        
        // If event has `username` and `message` directly, use them
        if (event.username && event.message) {
            username = event.username;
            message = event.message;
        } 
        // Otherwise, parse from event.body if available
        else if (event.body) {
            const body = JSON.parse(event.body);
            username = body.username;
            message = body.message;
        } else {
            throw new Error("Request body is missing");
        }

        // Validate that username and message are present
        if (!username || !message) {
            throw new Error("Request body is missing required fields: 'username' and 'message'");
        }

        const params = {
            TableName: 'ChatMessages',
            Item: {
                Username: username,
                Timestamp: Date.now().toString(), // Use Unix timestamp in milliseconds
                Message: message
            }
        };
        
        await dynamodb.put(params);

        return {
            statusCode: 200,
            headers: {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'POST'
            },
            body: JSON.stringify({ success: true })
        };
    } catch (error) {
        console.error('Error storing message:', error);
        return {
            statusCode: 500,
            headers: {
                'Access-Control-Allow-Origin': '*',
            },
            body: JSON.stringify({ error: 'Failed to store message', details: error.message })
        };
    }
};