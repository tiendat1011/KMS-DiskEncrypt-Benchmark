data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "default" {
  vpc_id = data.aws_vpc.default.id
  availability_zone = var.availability_zone
}

# EC2 Instance

resource "aws_instance" "ec2" {
  ami               = var.ami
  instance_type     = var.instance_type
  availability_zone = var.availability_zone
  key_name          = aws_key_pair.gen_key.key_name
  subnet_id         = data.aws_subnet.default.id
  security_groups   = [aws_security_group.allow_ssh.id]

  tags = var.ec2_tags
}

# Security group

resource "aws_security_group" "allow_ssh" {
  name   = "allow_ssh"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Đổi IP nếu cần bảo mật hơn
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Attach volume

resource "aws_volume_attachment" "volume" {
  device_name = var.device_name
  volume_id   = aws_ebs_volume.encrypted_volume.id
  instance_id = aws_instance.ec2.id
}