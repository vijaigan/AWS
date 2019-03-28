# AWS Cli Notes 



### List Instance Details 
~~~~ 
$ aws ec2 describe-instances --query 'Reservations[*].Instances[*].[Tags[?Key==`Name`].Value,InstanceId,InstanceType,State.Name,NetworkInterfaces[0].PrivateIpAddress,NetworkInterfaces[0].Association.PublicIp]' --output=text  | sed '$!N;s/\n/ /'  
i-04e222xxxxx	t3.micro	running	10.211.0.247	xx.xxx.xxx.241 Server1
i-0c24c7xxxxx	t3.micro	running	10.211.59.29	xx.xxx.xxx.149 Server2
i-0d972dxxxxx	t3.micro	running	10.211.61.189	xx.xxx.xxx.243 Server3
i-06e930xxxxx	t3.medium	running	10.211.3.133	xx.xxx.xxx.121 Server4
~~~~  
