require('dotenv').config();
const AWS = require('aws-sdk');
const mysql = require('mysql2/promise');
const SecretsManager = require('./secretManager');
const secretName = 'db_secrets';
const region = 'us-east-2';
const secondSqsQueueUrl = process.env.SQS_QUEUE_URL
const sqs = new AWS.SQS({ region: region });

exports.handler = async (event, context) => {

    let dbCredentials = await SecretsManager.getSecret(secretName, region);
    dbCredentials = JSON.parse(dbCredentials)
    const connection = await mysql.createConnection({
        host: dbCredentials.db_host,
        user: dbCredentials.username,
        password: dbCredentials.password,
        database: "Beam"
    });

    // Assuming the event contains SQS messages
    for (const record of event.Records) {
        // Extract message body from SQS record
        const messageBody = JSON.parse(record.body);

        const { email, products } = messageBody;

        console.log({ email, products })
        // Start a transaction
        try {
            await connection.beginTransaction();

            // Insert Order
            const [orderResult] = await connection.execute(
                'INSERT INTO Orders (CustomerEmail) VALUES (?)',
                [email]
            );
            const orderId = orderResult.insertId;

            // Insert Order Items
            const orderItemsPromises = products.map(async (product) => {
                // Get the product price
                const [productResult] = await connection.execute(
                    'SELECT Price FROM Products WHERE ProductID = ?',
                    [product.id]
                );
                const productPrice = productResult[0].Price;
                // Calculate the total price for the order item
                const totalItemPrice = product.quantity * productPrice;

                const [itemResult] = await connection.execute(
                    'INSERT INTO OrderItems (OrderID, ProductID, Quantity,TotalPrice) VALUES (?, ?, ?,?)',
                    [orderId, product.id, product.quantity, totalItemPrice]
                );
                return product;
            });

            // Commit the transaction if all queries succeed
            const result = await Promise.all(orderItemsPromises);
            await connection.commit();
            // Example message to be sent to the second SQS queue
            const messageToSend = {
                items: result
            };

            // Send the message to the second SQS queue
            await sqs.sendMessage({
                QueueUrl: secondSqsQueueUrl,
                MessageBody: JSON.stringify(messageToSend)
            }).promise();

        } catch (e) {
            await connection.rollback();
            console.error(e);
            // return { success: false, message: 'Error inserting order and items' };
        }



    }
    // Close MySQL connection
    await connection.end();
    return {
        statusCode: 200,
        body: 'Lambda function executed successfully!'
    };
};
