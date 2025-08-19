# aws ec2 describe-images --region us-east-2 --filters "Name=name, Values=al2023-ami-2023*"
data "aws_ami" "amazon_linux_2023_x64" {
 most_recent = true
 owners = ["amazon"]
 filter {
   name   = "name"
   values = ["al2023-ami-2023*"]
 }
 filter {
      name = "architecture"
      values = [ "x86_64" ]
  }
  filter {
      name = "virtualization-type"
      values = [ "hvm" ]
  }
}

data "aws_ami" "ubuntu_22_04_gen2" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's AWS Account ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-2025*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}
