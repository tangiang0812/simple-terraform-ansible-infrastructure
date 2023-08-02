#outputs.tf

output "ssh_security_group_id" {
  value = aws_security_group.allow_ssh.id
}

output "jenkins_instance_endpoint" {
  value = aws_instance.jenkins_server.public_dns
}
