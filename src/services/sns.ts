import { SNSClient, PublishCommand } from "@aws-sdk/client-sns";

//Connect to SNS in the configure region
const sns = new SNSClient({region: process.env.AWS_REGION});

//Shape of a trap hit
interface TrapHit {
    path: string,
    ip: string,
    userAgent: string,
    time: string
}

//Publish an alert to the SNS topic - triggers an email to all subscribers
export async function publishTrapAlert(hit:TrapHit): Promise<void> {

    //The message is in plain text joined with new lines for readability on emails
    const message = [
        'HONEYTOKEN HTTP TRAP TRIGGERED',
        '',
        `Endpoint : ${hit.path}`,
        `IP Address : ${hit.ip}`,
        `User Agent : ${hit.userAgent}`,
        `Time : ${hit.time}`,
    ].join('\n')

    //Subject shows as the email subject line
    await sns.send(new PublishCommand ({
        TopicArn: process.env.SNS_TOPIC_ARN,
        Subject: 'Honeytoken Alert: HTTP Trap Hit',
        Message: message
    }))
}