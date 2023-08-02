#outputs.tf

output "ssh_security_group_id" {
  value = aws_security_group.allow_ssh.id
}
