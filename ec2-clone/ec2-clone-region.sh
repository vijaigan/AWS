#!/bin/bash 


# Script for cloning AWS instances from one REGION to Other REGION 
# You need to have AWS cli setup for your account
# please refer to https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html for setting up aws cli 
# Please update SRC_REGION , DST_REGION and INSTANCE_IDS (space between instances ) 
# This script will create latest AMI Image without rebooting the server and Put's appropriate 
# tags with Date and Name on the AMI Image on Destination Region. 

DATE=`date +%F`
#Source REGION 
SRC_REGION=ap-southeast-1
#Destination REGION 
DST_REGION=eu-west-1
# Please input the Instance ID's here 
INSTANCE_IDS="i-c47xxxx i-0d269cxxxx i-9729xxx i-0532afxxx"

#echo $INSTANCE_IDS
for i in $INSTANCE_IDS 
do 
	INSTANCE_NAME=`aws ec2 describe-instances --instance-id $i --query 'Reservations[*].Instances[*].[Tags[?Key==\`Name\`].Value]' --output text --region $SRC_REGION`
	echo "Working on $INSTANCE_NAME " 
	AMI_NAME=`echo $INSTANCE_NAME"-AMI-"$DATE`
	#echo $AMI_NAME 
	#echo "aws ec2 create-image --instance-id $i --name $AMI_NAME --no-reboot --output text --region $SRC_REGION "
	AMI_ID=`aws ec2 create-image --instance-id $i --name $AMI_NAME --no-reboot --output text --region $SRC_REGION` 
	echo $AMI_ID is created for $INSTANCE_NAME 
	AMI_STATUS=`aws ec2 describe-images --owners self  --image-id $AMI_ID --query 'Images[*].State' --output text` 

	echo "Waiting for create-ami for $AMI_ID to finish" 
	until [ $AMI_STATUS = "available" ]
	do
		AMI_STATUS=`aws ec2 describe-images --owners self  --image-id $AMI_ID --query 'Images[*].State' --output text --region $SRC_REGION`
		sleep 2
		echo -n "." 
	done
	echo " " 

	#echo "aws ec2 copy-image --source-image-id ami-5731123e --source-region $SRC_REGION --region $DST_REGION --name $AMI_NAME "
	DST_AMI_ID=`aws ec2 copy-image --source-image-id $AMI_ID --source-region $SRC_REGION --region $DST_REGION --name $AMI_NAME --output text`
	NAME_TAG=`aws ec2 create-tags --resources $DST_AMI_ID --tags Key=Name,Value=$AMI_NAME --region $DST_REGION`
	echo $DST_AMI_ID created in $DST_REGION with Name $AMI_NAME from source $AMI_ID from $SRC_REGION 
done 
