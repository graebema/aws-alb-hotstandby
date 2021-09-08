output "ec2_private_ip" { value = aws_instance.ec2.private_ip }
output "ec2_private_dns" { value = aws_instance.ec2.private_dns }
output "ec2_instance_id" { value = aws_instance.ec2.id }
