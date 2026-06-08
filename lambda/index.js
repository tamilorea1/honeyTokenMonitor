/**
 * This is the lambda function code
 * It will receive the SNS event,
 * Pull out the alarm details (name, why it fired, when),
 * and will Log them
 * @param {*} event 
 */

/**
 * DynamoDBClient is the connection to DynamoDB
 * PutItemCommand is the action to "write a new record"
 * 
 * randomUUID is needed since each row in the DynamoDB table needs a unique ID
 */
const {DynamoDBClient, PutItemCommand} = require("@aws-sdk/client-dynamodb")
const {randomUUID} = require("crypto")

const dynamo = new DynamoDBClient({})

exports.handler = async (event) => {
    const snsMessage = JSON.parse(event.Records[0].Sns.Message);

    console.log('HONEYTOKEN ALERT:', {
        alarm: snsMessage.AlarmName,
        reason: snsMessage.NewStateReason,
        time: snsMessage.StateChangeTime
    })

    await dynamo.send(new PutItemCommand({
        //DynamoDB table name (honeytoken_incidents)
        TableName: process.env.DYNAMODB_TABLE,
        Item: {
            incident_id: {S: randomUUID() },
            alarm_name: {S: snsMessage.AlarmName },
            reason: {S: snsMessage.NewStateReason },
            timeStamp: {S: snsMessage.StateChangeTime}
        }
    }))
}