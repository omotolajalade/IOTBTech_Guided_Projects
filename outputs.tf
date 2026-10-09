output "managed_public_ip" {
  value = aws_instance.ubuntu.public_ip
}

output "managed_private_ip" {
  value = aws_instance.ubuntu.private_ip
}

output "controller_public_ip" {
  value = aws_instance.ctrl_ubuntu.public_ip
}

output "ssh_command" {
  value = "ssh -i ${var.private_key_path} ubuntu@${aws_instance.ctrl_ubuntu.public_ip}"
}

output "run_playbook" {
  value = "cd ~/ansible && ansible-playbook playbook.yml"
}
