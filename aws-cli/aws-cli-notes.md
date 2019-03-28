# AWS Cli Notes 

### List Instance Details
``` 
$ aws ec2 describe-instances --query 'Reservations[*].Instances[*].[Tags[?Key==`Name`].Value,InstanceId,InstanceType,State.Name,NetworkInterfaces[0].PrivateIpAddress,NetworkInterfaces[0].Association.PublicIp]' --output=text  | sed '$!N;s/\n/ /'
```

~~~~ 
$ aws ec2 describe-instances --query 'Reservations[*].Instances[*].[Tags[?Key==`Name`].Value,InstanceId,InstanceType,State.Name,NetworkInterfaces[0].PrivateIpAddress,NetworkInterfaces[0].Association.PublicIp]' --output=text  | sed '$!N;s/\n/ /' 
i-04e222xxxxx	t3.micro	running	10.211.0.247	xx.xxx.xxx.241 Server1
i-0c24c7xxxxx	t3.micro	running	10.211.59.29	xx.xxx.xxx.149 Server2
i-0d972dxxxxx	t3.micro	running	10.211.61.189	xx.xxx.xxx.243 Server3
i-06e930xxxxx	t3.medium	running	10.211.3.133	xx.xxx.xxx.121 Server4
~~~~

### List All running Instances volumes , size, snapshot 
``` 
$ for i in `aws ec2 describe-instances --filter Name=instance-state-name,Values=running --query 'Reservations[*].Instances[*].[InstanceId]' --output=text` ; 
do 
aws ec2 describe-volumes --filter Name=attachment.instance-id,Values=$i --query "Volumes[*].[Attachments[0].InstanceId,VolumeId,Attachments[0].Device,Size,SnapshotId]" --output=table 
done
``` 
~~~~ 
for i in `aws ec2 describe-instances --filter Name=instance-state-name,Values=running --query 'Reservations[*].Instances[*].[InstanceId]' --output=text` ; 
do
aws ec2 describe-volumes --filter Name=attachment.instance-id,Values=$i --query "Volumes[*].[Attachments[0].InstanceId,VolumeId,Attachments[0].Device,Size,SnapshotId]" --output=table 
done
-----------------------------------------------------------------------------------------------
|                                       DescribeVolumes                                       |
+---------------------+-------------------------+------------+-----+--------------------------+
|  i-0e73cxxxxxxxxxxxx|  vol-05f76axxxxxxxxxxx  |  /dev/sda1 |  20 |  snap-0e1xxxxxxxxxxx     |
|  i-0e73cxxxxxxxxxxxx|  vol-0a0107xxxxxxxxxxx  |  /dev/sdf  |  50 |  snap-013xxxxxxxxxxx     |
|  i-0e73cxxxxxxxxxxxx|  vol-0bbe5bxxxxxxxxxxx  |  /dev/sdg  |  16 |  snap-0ddxxxxxxxxxxx     |
+---------------------+-------------------------+------------+-----+--------------------------+
~~~~ 

### List All running RDS Instances 

```
aws rds describe-db-instances --query 'DBInstances[*].{DBNAME:DBName,ARN:DBInstanceArn,Identifier:DBInstanceIdentifier,Class:DBInstanceClass,Engine:Engine,Status:DBInstanceStatus,AZ:AvailabilityZone,MZ:MultiAZ}' 
``` 

~~~~
------------------------------------------------------------------------------------------------------------------------------------------------------
|                                                                 DescribeDBInstances                                                                |
+--------------------------------------------------------+------------------+---------------+---------+---------+-------------+--------+-------------+
|                           ARN                          |       AZ         |     Class     | DBNAME  | Engine  | Identifier  |  MZ    |   Status    |
+--------------------------------------------------------+------------------+---------------+---------+---------+-------------+--------+-------------+
|  arn:aws:rds:ap-southeast-1:1121xxxxxxxx:db:xxx        |  ap-southeast-1a |  db.m3.medium |  xx     |  mysql  |  ub         |  False |  available  |
|  arn:aws:rds:ap-southeast-1:1121xxxxxxxx:db:xxxxxxx    |  ap-southeast-1b |  db.t2.medium |  xxx    |  aurora |  ub3-aurora |  False |  available  |
|  arn:aws:rds:ap-southeast-1:1121xxxxxxxx:db:xxxxxxx    |  ap-southeast-1b |  db.t2.medium |  xx     |  mysql  |  ubtest1    |  False |  available  |
+--------------------------------------------------------+------------------+---------------+---------+---------+-------------+--------+-------------+

~~~~


