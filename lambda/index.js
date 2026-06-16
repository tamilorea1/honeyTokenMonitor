/**
 * This is the lambda function code
 * It will receive the SNS event,
 * Pull out the alarm details (name, why it fired, when),
 * deactivate the honeytoken's access key,
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
const {IAMClient, ListAccessKeysCommand, UpdateAccessKeyCommand } = require("@aws-sdk/client-iam")
const {randomUUID} = require("crypto")

const dynamo = new DynamoDBClient({})
const iam = new IAMClient({})

//Looks up the honeytoken user's access keys and deactivates any that are stil active
async function deactivateKeys() {
    const username = process.env.HONEYTOKEN_USERNAME

    const {AccessKeyMetadata} = await iam.send(new ListAccessKeysCommand({
        UserName: username
    }))

    for(const key of AccessKeyMetadata){
        if(key.Status === 'Active'){
            await iam.send(new UpdateAccessKeyCommand({
                UserName: username,
                AccessKeyId: key.AccessKeyId,
                Status: 'Inactive'
            }))
            console.log(`Deactivated key: ${key.AccessKeyId}`);
        }
    }
}



exports.handler = async (event) => {
    const snsMessage = JSON.parse(event.Records[0].Sns.Message);

    console.log('HONEYTOKEN ALERT:', {
        alarm: snsMessage.AlarmName,
        reason: snsMessage.NewStateReason,
        time: snsMessage.StateChangeTime
    })

    //done before DYNAMODB write since we want containment as quickly as possible, then logging second
    await deactivateKeys()

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