
rolename="lambda-rds-alarm"$1
echo $rolename is creating
aws iam create-role --role-name $rolename --assume-role-policy-document file://role_policy.json
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/CloudWatchFullAccess --role-name $rolename
aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole --role-name $rolename

lambdaname="lambda-rds-alarm"$1
echo lambda $lambdaname is creating
rarn=$(aws iam list-roles --query "Roles[?RoleName == '$rolename'].[RoleName, Arn][0][1]")
rolearn=$(echo "$rarn" | tr -d '"')

sleep 3s

echo "rolearn : " $rolearn

aws lambda create-function \
    --function-name $lambdaname \
    --runtime python3.7 \
    --handler lambda_function.lambda_handler \
    --role $rolearn \
    --zip-file fileb://lambda.zip

