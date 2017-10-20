#!/usr/bin/env bash
aws ec2 start-instances --instance-ids i-0193a1e01f23aca23
the_ip=$(aws ec2 describe-instances | python -c "import sys, json; print json.load(sys.stdin)['Reservations'][0]['Instances'][0]['PublicIpAddress']")
echo this in echo of aws server ip $the_ip
code=$(aws ec2 describe-instances | python -c "import sys, json; print json.load(sys.stdin)['Reservations'][0]['Instances'][0]['State']['Name']")
echo the AWS instance is $code
while [ $code != "running" ]; do 
	code=$(aws ec2 describe-instances | python -c "import sys, json; print json.load(sys.stdin)['Reservations'][0]['Instances'][0]['State']['Name']")
	echo the AWS instance is $code
	sleep 5
done
echo start ssh tunnal
ssh -i ~/.ssh/ronnewvm.pem -o StrictHostKeyChecking=no -D 8123 -C -q -N -o ConnectTimeout=120 ubuntu@$the_ip &
echo tunnal open
echo set proxy config
sudo networksetup -setsocksfirewallproxy Wi-Fi 127.0.0.1 8123 ;
/usr/bin/open -W -a "/Applications/Google Chrome.app" "https://www.netflix.com/browse"
echo app open
pkill ssh
sudo networksetup -setsocksfirewallproxystate Wi-Fi off
echo end tunnal to AWS server
aws ec2 stop-instances --instance-ids i-0193a1e01f23aca23
