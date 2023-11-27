data "aws_ami" "roboshop" {
  most_recent = true
  name_regex  = "Centos-8-DevOps-Practice"
  owners = ["973714476881"] # Canonical
}

resource "aws_instance" "web" {
  ami = data.aws_ami.roboshop.id
  vpc_security_group_ids = [aws_security_group.allow_all_traffic.id]
  instance_type = "t3.micro"
  tags = {
    Name = "${component}-${env}"
  }
}

resource "aws_security_group" "allow_all_traffic" {
  name        = "Allow_all_traffic"
  description = "Allow TLS inbound traffic"
  vpc_id      = "vpc-00149dd4447623e6e"

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Allow_all_traffic"
  }
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "${component}-${env}@learnskill.fun"
  type    = "A"
  ttl     = 30
  records = [aws_instance.web.private_ip]
}

