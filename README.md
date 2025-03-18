# Bootcamp

## Tasks:
1. Create EC2 Instance t2.micro
   - Ubuntu
   - Amazon Linux

   Both instances must have a tag with names.

2. EC2 Ubuntu must have Internet access, there must be incoming access: ICMP, TCP/22, 80, 443, and any outgoing access.

3. EC2 Amazon Linux should not have access to the Internet, but must have outgoing and incoming access: ICMP, TCP/22, TCP/80, TCP/443 only on the local network where EC2 Ubuntu, EC2 Amazon Linux is located.

4. On EC2 Ubuntu, install a web server (nginx/apache);
   - Create a web page with the text “Hello World” and information about the current version of the operating system. This page must be visible from the Internet.

5. On EC2 Ubuntu install Docker, installation should be done according to the recommendation of the official Docker manuals

6. Complete  step 1, but AMI ID cannot be hardcoded. You can hardcode the operation system name, version, etc. 

7. Step 3 read as:
   EC2 Amazon Linux should have outgoing and incoming access: ICMP, TCP/22, TCP/80, TCP/443, only to EC2 Ubuntu. 

8. On EC2 Amazon Linux install nginx (note. Remember about step 7, the task can be done in any way, it is not necessary to use terraform)
   - Create a web page with the text “Hello World”. This page must be visible from the  EC2 Ubuntu.

## Launch terraform:

```bash
terraform init
terraform apply
```


## Connect to the public instance:

```bash
ssh -i "BootcampKeyPair.pem" ubuntu@18.203.224.69
```

## Copy public key to the private instance:
```bash
scp -i "BootcampKeyPair.pem" BootcampKeyPair.pem ubuntu@18.203.224.69:
```

## Connect to the private instance:
```bash
ssh -i "BootcampKeyPair.pem" ec2-user@10.0.2.160
```
