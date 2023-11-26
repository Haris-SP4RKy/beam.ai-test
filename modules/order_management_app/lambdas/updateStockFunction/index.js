require('dotenv').config();
const AWS = require('aws-sdk');
const mysql = require('mysql2/promise');
const SecretsManager = require('./secretManager');
const secretName = 'db_secrets';
const region = 'us-east-2';
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


        const { items } = messageBody
        try {
            // Insert Transaction
            const transactionPromises = items.map(async (product) => {
                await connection.beginTransaction();
                try {
                    // Get the product price
                    const [productResult] = await connection.execute(
                        'SELECT StockQuantity FROM Products WHERE ProductID = ? and StockQuantity >= ?',
                        [product.id, product.quantity]
                    );
                    if (!productResult) {
                        //Here we can tell or send an email to user that this product is not available and his payment
                        //Will be refunded
                        return
                    }
                    const newQuantity = productResult[0].StockQuantity - product.quantity;
                    await connection.execute('UPDATE Products set StockQuantity= ?', [newQuantity])


                    const [itemResult] = await connection.execute(
                        'INSERT INTO  StockTransactions (  ProductID, QuantityChange, NewStockQuantity) VALUES (?, ?,?)',
                        [product.id, product.quantity, newQuantity]
                    );
                    await connection.commit();
                } catch (e) {
                    await connection.rollback();
                    console.error(e);
                }
                return product;
            });

            const result = await Promise.all(transactionPromises);

        } catch (e) {
            console.error(e)
        }

    }
    // Close MySQL connection
    await connection.end();
    return {
        statusCode: 200,
        body: 'Lambda function executed successfully!'
    };
};
