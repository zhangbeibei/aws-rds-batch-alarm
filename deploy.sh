echo "start deploying... "
num=$#
soureigion=$(aws configure get region)
echo source reigion is $soureigion

if [ $num -gt 2 ];then
    echo error1 :error input args,num of input args should be 1 or 2
    echo you has input $num
    exit 1
fi


if [ $num -lt 1 ];then
    echo error2 :error input args,num of input args should be 1 or 2  
    echo you has input $num
    exit 1
fi


if [ $num -eq 2 ];then
    region=$2
    echo "region will be set into $region"
    aws configure set region $region
fi

touch lambda_function.py
cat>lambda_function.py<<eof
import json
import boto3
from config_sns import *

def lambda_handler(event, context):
    # TODO implement
    print(event)
    sig=event['detail']['EventCategories'][0]
    print('sig= ',sig)
    if sig=='creation':
        dbid=event['detail']['SourceIdentifier']
        cw=boto3.client('cloudwatch')
        response=cw.put_metric_alarm(
            AlarmName='rds_CPU_Utilization'+dbid,
            ComparisonOperator='GreaterThanThreshold',
            EvaluationPeriods=1,
            MetricName='CPUUtilization',
            Namespace='AWS/RDS',
            Statistic='Average',
            Period=300,
            Threshold=70.0,
            ActionsEnabled=True,
            AlarmActions=[
                snsname,
                ],
            AlarmDescription='Alarm when rds CPU exceeds 70%',
            Dimensions=[{
          'Name': 'DBInstanceIdentifier',
          'Value': dbid
            },
        ])
        print(response)

    else:
        pass
        
eof

touch role_policy.json
cat >role_policy.json<<eof
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "",
        "Effect": "Allow",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
eof


timestamp=$(date +%s)
submail=$1
echo target_mail is $submail


echo "create sns..."
chmod 777 create_sns.sh
./create_sns.sh $timestamp $submail
zip lambda.zip config_sns.py lambda_function.py

chmod 777 create_lambda.sh
chmod 777 create_event.sh

echo "create lambda... "
./create_lambda.sh $timestamp

echo "creete cloudwatch event... "
./create_event.sh $timestamp


rm lambda.zip
rm role_policy.json
rm lambda_function.py
rm config_sns.py
aws configure set region $soureigion


echo region has been changed back to $soureigion
echo "rds batch alarm has been deployed."

