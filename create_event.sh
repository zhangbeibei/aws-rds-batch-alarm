#创建 cloudwatch event，并将target设置为lambda

lambdaname="lambda-rds-alarm"$1
echo $lambdaname
eventname="lambda-rds-alarm"$1

#aws events put-rule --name $eventname --event-pattern "{\"source\":[\"aws.config\"],\"detail-type\":[\"Config Rules Compliance Change\"]}"
aws events put-rule --name $eventname --event-pattern "{\"source\": [\"aws.rds\"],\"detail-type\": [\"RDS DB Instance Event\"]}" --state ENABLED

earn=$(aws events list-rules --query "Rules[?Name == '$eventname'].[Name,Arn][0][1]")
eventarn=$(echo "$earn" | tr -d '"')
aws lambda add-permission --function-name $lambdaname --statement-id $eventname \
--action 'lambda:InvokeFunction' \
--principal events.amazonaws.com \
--source-arn  $eventarn 

larn=$(aws lambda list-functions --query "Functions [?FunctionName=='$lambdaname'].[FunctionName,FunctionArn][0][1]")
echo "lambdabanme : "$lambdaname
echo "lambdaarn  :  "$larn
lambdaarn=$(echo "$larn" | tr -d '"')

aws events put-targets --rule $eventname --targets "Id"="target"$lambdabanme,"Arn"=$larn

