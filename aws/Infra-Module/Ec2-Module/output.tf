output "ec2_instance_id" {
  value       = aws_instance.ec2_instance.id
}

output "ec2_public_ip" {
  value       = aws_instance.ec2_instance.public_ip
}

output "ec2_private_ip" {
  value       = aws_instance.ec2_instance.private_ip
}

output "ec2_arn" {
  value       = aws_instance.ec2_instance.arn
}

output "ec2_public_dns" {
  value       = aws_instance.ec2_instance.public_dns
}
output "instance_profile_name" {
  value       = aws_iam_instance_profile.eks_profile.name
}

output "instance_profile_arn" {
  value       = aws_iam_instance_profile.eks_profile.arn
}
