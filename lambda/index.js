/**
 * This is the lambda function code
 * It will receive the SNS event,
 * Pull out the alarm details (name, why it fired, when),
 * and will Log them
 * @param {*} event 
 */

exports.handler = async (event) => {
    const snsMessage = JSON.parse(event.Records[0].Sns.Message);

    console.log('HONEYTOKEN ALERT:', {
        alarm: snsMessage.AlarmName,
        reason: snsMessage.NewStateReason,
        time: snsMessage.StateChangeTime
    })
}