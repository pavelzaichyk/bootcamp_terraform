output "ec2_ubuntu_public_ip" {
  value = aws_instance.ubuntu.public_ip
}

output "ec2_amazon_linux_private_ip" {
  value = aws_instance.amazon_linux.private_ip
}
