/**
 * The file is a service that knows how to talk to DynamoDB when a trap hit occurs
 */

import { DynamoDBClient, PutItemCommand, ScanCommand } from "@aws-sdk/client-dynamodb";
import { unmarshall } from "@aws-sdk/util-dynamodb";
import { randomUUID } from "crypto";

//Connect to DynamoDB in the configure region
const dynamo = new DynamoDBClient({region: process.env.AWS_REGION});

//Shape of a trap hit - Typescript ensures these fields exist
interface TrapHit {
    path: string,
    ip: string,
    userAgent: string,
    time: string
}


//write one trap hit as a new row in DynamoDB
export async function logTrapHit(hit:TrapHit): Promise<void> {
    await dynamo.send(new PutItemCommand({
        TableName: process.env.DYNAMODB_TABLE!,
        Item: {
            incident_id: {S: randomUUID()},
            source: {S: 'http-trap'},
            path: {S: hit.path},
            ip: {S: hit.ip},
            userAgent: {S: hit.userAgent},
            time: {S: hit.time}
        }
    }))
}

// Reads every incident currently stored in the table
export async function getAllIncidents(): Promise<Record<string, any>[]> {
    const {Items} = await dynamo.send(new ScanCommand({
        TableName: process.env.DYNAMODB_TABLE!
    }))

    // Convert DynamoDB's typed format ({ S: "value" }) into plain objects
    return (Items || []).map(item => unmarshall(item))
}