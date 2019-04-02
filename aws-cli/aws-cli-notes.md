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
|  arn:aws:rds:ap-southeast-1:1121xxxxxxxx:db:xxx        |  ap-southeast-1a |  db.m3.medium |  xx     |  mysql  |  xx         |  False |  available  |
|  arn:aws:rds:ap-southeast-1:1121xxxxxxxx:db:xxxxxxx    |  ap-southeast-1b |  db.t2.medium |  xxx    |  aurora |  xxxxxxxxxx |  False |  available  |
|  arn:aws:rds:ap-southeast-1:1121xxxxxxxx:db:xxxxxxx    |  ap-southeast-1b |  db.t2.medium |  xx     |  mysql  |  xxxxxxx    |  False |  available  |
+--------------------------------------------------------+------------------+---------------+---------+---------+-------------+--------+-------------+

~~~~

### Attaching a Volume 
~~~~ 
$ aws ec2 attach-volume --volume-id vol-011432exxxxxx --instance-id i-0baf904axxxxxxxx --device /dev/sdb 
-------------------------------------------------------------------------------------------------------
|                                            AttachVolume                                             |
+---------------------------+-----------+----------------------+------------+-------------------------+
|        AttachTime         |  Device   |     InstanceId       |   State    |        VolumeId         |
+---------------------------+-----------+----------------------+------------+-------------------------+
|  2018-10-29T11:28:29.441Z |  /dev/sdb |  i-0baf904xxxxxxxxxx |  attaching |  vol-011432exxxxxxxxxx  |
+---------------------------+-----------+----------------------+------------+-------------------------+
~~~~ 

### Volume delete on termination 
~~~~ 
aws ec2 modify-instance-attribute --instance-id i-ce9xxxxx --block-device-mappings "[{\"DeviceName\": \"/dev/sda1\",\"Ebs\":{\"DeleteOnTermination\":true}}]"
~~~~ 

### EBS Volume modification / increase 

~~~~ 

$ aws ec2 describe-volumes --filter Name=attachment.instance-id,Values=i-09a36xxxxxxx  --output=table
---------------------------------------------------------
|                    DescribeVolumes                    |
+-------------------------------------------------------+
||                       Volumes                       ||
|+---------------------+-------------------------------+|
||  AvailabilityZone   |  ap-northeast-2a              ||
||  CreateTime         |  2018-02-05T08:50:18.701Z     ||
||  Encrypted          |  False                        ||
||  Iops               |  3000                         ||
||  Size               |  1000                         ||
||  SnapshotId         |                               ||
||  State              |  in-use                       ||
||  VolumeId           |  vol-052156axxxxxxxxxxx       ||
||  VolumeType         |  gp2                          ||
|+---------------------+-------------------------------+|


$ aws ec2 modify-volume  --volume-id vol-052156afxxxxxxx --size 1250 --volume-type gp2 
------------------------------------------------------
|                    ModifyVolume                    |
+----------------------------------------------------+
||                VolumeModification                ||
|+---------------------+----------------------------+|
||  ModificationState  |  modifying                 ||
||  OriginalIops       |  3000                      ||
||  OriginalSize       |  1000                      ||
||  OriginalVolumeType |  gp2                       ||
||  Progress           |  0                         ||
||  StartTime          |  2018-10-31T07:17:30.000Z  ||
||  TargetIops         |  3750                      ||
||  TargetSize         |  1250                      ||
||  TargetVolumeType   |  gp2                       ||
||  VolumeId           |  vol-052156afxxxxxxxxx     ||
|+---------------------+----------------------------+|

$ aws ec2 describe-volumes-modifications --volume-id vol-052156axxxxxxxx

------------------------------------------------------
|            DescribeVolumesModifications            |
+----------------------------------------------------+
||               VolumesModifications               ||
|+---------------------+----------------------------+|
||  ModificationState  |  optimizing                ||
||  OriginalIops       |  3000                      ||
||  OriginalSize       |  1000                      ||
||  OriginalVolumeType |  gp2                       ||
||  Progress           |  3                         ||
||  StartTime          |  2018-10-31T07:17:30.000Z  ||
||  TargetIops         |  3750                      ||
||  TargetSize         |  1250                      ||
||  TargetVolumeType   |  gp2                       ||
||  VolumeId           |  vol-052156afxxxxxxxxx     ||
|+---------------------+----------------------------+|

~~~~ 

### All private and EIP Assigned to a instance 

~~~~ 
$ aws ec2 describe-addresses --filters "Name=instance-id,Values=i-0fee11exxxxxxx" 
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
|                                                                          DescribeAddresses                                                                         |
+--------------------------------------------------------------------------------------------------------------------------------------------------------------------+
||                                                                             Addresses                                                                            ||
|+-------------------+--------------------+---------+----------------------+---------------------+--------------------------+--------------------+------------------+|
||   AllocationId    |   AssociationId    | Domain  |     InstanceId       | NetworkInterfaceId  | NetworkInterfaceOwnerId  | PrivateIpAddress   |    PublicIp      ||
|+-------------------+--------------------+---------+----------------------+---------------------+--------------------------+--------------------+------------------+|
||  eipalloc-5207727c|  eipassoc-ae541f80 |  vpc    |  i-0fee11eb323aaa67a |  eni-8691c0da       |  983960597111            |  10.4.xxx.xxx      |  13.124.xxx.xxx  ||
||  eipalloc-e8741bc6|  eipassoc-8c7300a2 |  vpc    |  i-0fee11eb323aaa67a |  eni-35673d69       |  983960597111            |  10.4.xxx.xxx      |  13.124.xxx.xxx  ||
||  eipalloc-3efc9110|  eipassoc-9ac5afb4 |  vpc    |  i-0fee11eb323aaa67a |  eni-8691c0da       |  983960597111            |  10.4.xxx.xxx      |  13.124.xxx.xxx  ||
||  eipalloc-bff49991|  eipassoc-b93e4b97 |  vpc    |  i-0fee11eb323aaa67a |  eni-7efbaa22       |  983960597111            |  10.4.xxx.xxx      |  13.124.xxx.xxx  ||
||  eipalloc-aa721d84|  eipassoc-d17201ff |  vpc    |  i-0fee11eb323aaa67a |  eni-5d673d01       |  983960597111            |  10.4.xxx.xxx      |  13.124.xxx.xxx  ||
||  eipalloc-af077281|  eipassoc-21561d0f |  vpc    |  i-0fee11eb323aaa67a |  eni-8691c0da       |  983960597111            |  10.4.xxx.xxx      |  52.79.xxx.xxx  ||
|+-------------------+--------------------+---------+----------------------+---------------------+--------------------------+--------------------+------------------+|

~~~~ 

### Termination of instance 

1. before terminating instance via cli we need to do change block device delete on termination.
2. also we need to modify termination via api protection. 

~~~~ 
$ aws ec2 modify-instance-attribute --instance-id i-040e1f39axxxxxxx --block-device-mappings "[{\"DeviceName\": \"/dev/sda1\",\"Ebs\":{\"DeleteOnTermination\":true}}]" 
$ aws ec2 modify-instance-attribute --no-disable-api-termination --instance-id i-040e1f39axxxxxxx 
$ aws ec2 terminate-instances --dry-run --instance-ids i-040e1f39axxxxxxx 

$ aws ec2 terminate-instances  --instance-ids i-040e1f39axxxxxxx 
-------------------------------
|     TerminateInstances      |
+-----------------------------+
||   TerminatingInstances    ||
|+---------------------------+|
||        InstanceId         ||
|+---------------------------+|
||  i-040e1f39axxxxxxx      ||
|+---------------------------+|
|||      CurrentState       |||
||+-------+-----------------+||
||| Code  |      Name       |||
||+-------+-----------------+||
|||  32   |  shutting-down  |||
||+-------+-----------------+||
|||      PreviousState      |||
||+---------+---------------+||
|||  Code   |     Name      |||
||+---------+---------------+||
|||  16     |  running      |||
||+---------+---------------+||


~~~~ 



