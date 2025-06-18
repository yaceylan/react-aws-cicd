output "instance_public_ip" {
  value = aws_instance.web.public_ip
}

output "instance_id" {
  value = aws_instance.web.id
}

output "ssh_key_name" {
  value = aws_key_pair.deployer.key_name
}
