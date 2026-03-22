resource "aws_iam_instance_profile" "eks_profile" {
  name = var.instance_profile_name
  role = var.role
  tags = var.tags
}

resource "aws_instance" "ec2_instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  iam_instance_profile   = var.iam_instance_profile

provisioner "file" {
  source      = "${path.module}/script.sh"
  destination = "/tmp/script.sh"

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = self.public_ip
    private_key = file("${path.module}/siva01.pem")
    timeout     = "10m"
  }
}

provisioner "remote-exec" {
  inline = [
    "chmod +x /tmp/script.sh",
    "/tmp/script.sh"
  ]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = self.public_ip
    private_key = file("${path.module}/siva01.pem")
    timeout     = "10m"
  }
}
}