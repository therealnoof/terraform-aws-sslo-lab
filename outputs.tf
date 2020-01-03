
# Jump Box Public IP Address
output "eip_for_jumpbox" {
  description = "EIP or Public address for the jump box"
  value       = aws_eip_association.eip.public_ip
}
