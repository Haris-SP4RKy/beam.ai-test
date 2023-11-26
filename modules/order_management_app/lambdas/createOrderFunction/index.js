const AWS = require('aws-sdk');
require('dotenv').config();
const Joi = require('joi');
const sqs = new AWS.SQS();

exports.handler = async (event) => {
    const schema = Joi.object({
        email: Joi.string().required(),
        products: Joi.array().required()
    })
    try {

        const orderData = JSON.parse(event.body);
        const value = await schema.validateAsync(orderData);

        const params = {
            MessageBody: JSON.stringify(orderData),
            QueueUrl: process.env.SQS_QUEUE_URL
        };

        await sqs.sendMessage(params).promise();

        return {
            statusCode: 200,
            body: JSON.stringify({ message: 'Order successfully placed and sent to SQS' })
        };
    } catch (error) {
        console.error('Error:', error);

        return {
            statusCode: 500,
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({ message: 'Internal Server Error', error })
        };
    }
};
