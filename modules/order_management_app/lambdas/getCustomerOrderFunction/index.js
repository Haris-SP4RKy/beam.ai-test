require('dotenv').config();
const mysql = require('mysql2/promise');
const AWS = require('aws-sdk');
const SecretsManager = require('./secretManager');

const secretName = 'db_secrets';
const region = 'us-east-2';


exports.handler = async (event, context) => {
    try {
        console.log(event)
        const email = event.queryStringParameters.email;
        if (!email) {
            throw new Error("Email is required as query param");
        }
        let dbCredentials = await SecretsManager.getSecret(secretName, region);
        dbCredentials = JSON.parse(dbCredentials)
        const connection = await mysql.createConnection({
            host: dbCredentials["db_host"],
            user: dbCredentials["username"],
            password: dbCredentials["password"],
            database: "Beam"
        });

        const [rows, fields] = await connection.execute(`SELECT Orders.OrderID as Id , CustomerEmail as Email , OrderStatus as status ,OrderDate as date ,JSON_ARRAYAGG(JSON_OBJECT('name',ProductName,'quantity',OI.Quantity,'total_price',OI.TotalPrice)) as products , SUM(OI.TotalPrice) as SubTotal FROM Orders join OrderItems OI on Orders.OrderID = OI.OrderID JOIN Products P on P.ProductID = OI.ProductID where CustomerEmail= ? group by Orders.OrderID, CustomerEmail, OrderStatus, OrderDate`, [email]);
        console.log(rows);

        console.log('Query Results:', rows);


        connection.end();

        return {
            statusCode: 200,
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({ message: 'Get Orders Successfull', results: rows })
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
