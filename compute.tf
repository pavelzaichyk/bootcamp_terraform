# Generate a new RSA private key
resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create a new key pair using the generated private key
resource "aws_key_pair" "key" {
  key_name   = "BootcampKeyPair"
  public_key = tls_private_key.key.public_key_openssh
}

# Save the private key locally for SSH access
resource "local_file" "private_key" {
  content         = tls_private_key.key.private_key_pem
  filename        = "${path.module}/BootcampKeyPair.pem"
  file_permission = "0600"
}

# Fetch the latest Amazon Linux AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners = ["self"]

  filter {
    name = "name"
    values = ["AmazonLinux-Nginx-AMI"]
  }
}

# Create an EC2 instance for Amazon Linux
resource "aws_instance" "amazon_linux" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_subnet.id
  security_groups = [aws_security_group.amazon_linux_sg.id]
  key_name      = aws_key_pair.key.key_name
  tags = {
    Name = "EC2-Amazon-Linux"
  }

  # User data script
  user_data = <<-EOF
              #!/bin/bash
              echo "<h1>Hello World</h1><p>OS Version: $(cat /etc/os-release | grep PRETTY_NAME | cut -d '=' -f2 | tr -d '\"')</p>" | sudo tee /usr/share/nginx/html/index.html
              sudo systemctl restart nginx
              EOF
}

# Fetch the latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

# Create an EC2 instance for Ubuntu
resource "aws_instance" "ubuntu" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.ubuntu_sg.id]
  key_name                    = aws_key_pair.key.key_name
  associate_public_ip_address = true
  tags = {
    Name = "EC2-Ubuntu"
  }

  # User data script to install Nginx and Docker, and create a web page
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y nginx docker.io
              sudo systemctl start nginx
              sudo systemctl enable nginx
              echo "<h1>Hello World</h1><p>OS Version: $(lsb_release -d | cut -f2)</p>" | sudo tee /var/www/html/index.html
              sudo systemctl restart nginx
              EOF
}
