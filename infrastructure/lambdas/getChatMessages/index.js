import { DynamoDB } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocument } from '@aws-sdk/lib-dynamodb';

const client = new DynamoDB({});
const dynamodb = DynamoDBDocument.from(client);

export const handler = async (event) => {
    try {
        const params = {
            TableName: process.env.DYNAMODB_TABLE_NAME
        };
        
        const result = await dynamodb.scan(params);
        const messages = result.Items || [];

        // Clean up messages by removing extra quotes around each field
        const cleanedMessages = messages.map((msg) => ({
            Timestamp: msg.Timestamp.replace(/^"|"$/g, ''),
            Message: msg.Message.replace(/^"|"$/g, ''),
            Username: msg.Username.replace(/^"|"$/g, '')
        }));
        
        return {
            statusCode: 200,
            headers: {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'GET'
            },
            body: JSON.stringify(cleanedMessages)
        };
    } catch (error) {
        console.error('Error:', error);
        return {
            statusCode: 500,
            headers: {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'GET'
            },
            body: JSON.stringify({ message: "An error occurred retrieving messages" })
        };
    }
};