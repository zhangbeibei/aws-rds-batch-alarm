#create sns 

timestamp=$1
submail=$2

echo target mail is $submail

snsname="lambda-rds-alarm"$1
arn=$(aws sns create-topic --name $snsname)
echo "arn : "$arn
id=$(awk  'BEGIN{FS="\""}{print $4}' <<< "${arn}")
snsarn=$(echo $id | tr -d '\r')
echo "id : "$id
touch config_sns.py
cat>config_sns.py <<eof
snsname="$snsarn"
eof
echo "snsarn :  "$snsarn
aws sns subscribe --topic-arn $snsarn --protocol email --notification-endpoint $submail
echo "add alarm for exsiting rds... "
chmod 777 add_alarm.sh
#./add_alarm.sh $snsarn

#add alarm to exsiting rds
function jsonValue() {
KEY=$1
num=$2
awk -F"[,:}]" '{for(i=1;i<=NF;i++){if($i~/'$KEY'\042/){print $(i+1)}}}' | tr -d '"' | sed -n ${num}p
}

rdsid_dis=$(aws rds describe-db-instances)
touch buf.json
cat>buf.json<<eof
$rdsid_dis
eof
rdsid=$(cat buf.json | jsonValue DBInstanceIdentifier)

rm buf.json

touch buf.txt
cat>buf.txt <<eof
$rdsid
eof

cat buf.txt |while read line
do
echo ${line} is adding alarm
aws cloudwatch put-metric-alarm --alarm-name "rds_CPU_Utilization${line}" \
                                --alarm-description "Alarm when rds CPU exceeds 70" \
                                --namespace  AWS/RDS \
                                --statistic Average \
                                --dimensions "Name=DBInstanceIdentifier,Value=${line}"  \
                                --period 300 \
                                --threshold 70  \
                                --comparison-operator GreaterThanThreshold  \
                                --evaluation-periods 1  \
                                --metric-name CPUUtilization \
                                --alarm-actions $snsarn
done
rm buf.txt

