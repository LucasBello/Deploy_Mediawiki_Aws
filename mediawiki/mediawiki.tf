provider "aws" {
  region = var.aws_region
}

#Abrir portas de aplicação
resource "aws_security_group" "mediawiki_sg" {
  name = "mediawiki_sg"
  description = "HTTP e SSH"
  vpc_id = aws_vpc.vinnland_vpc.id

#Liberar porta 80
 ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

#Liberar porta 22
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #Saida
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
resource "aws_eip" "mw_eip_01" {
    instance = aws_instance.webserver1.id
  vpc      = true
  depends_on = ["aws_internet_gateway.wiki_igw"]
}

resource "aws_eip" "mw_eip_02" {
    instance = aws_instance.webserver2.id
  vpc      = true
  depends_on = ["aws_internet_gateway.wiki_igw"]
}

#Gerando Key Privada
resource "tls_private_key" "mw_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
resource "aws_key_pair" "generated_key" {
  key_name   = var.keyname
  public_key = tls_private_key.mw_key.public_key_openssh
}

resource "aws_instance" "webserver1" {
  ami           = var.aws_ami
  availability_zone = element(var.zonadisp, 0)
  instance_type = var.aws_instance_type
  key_name  = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [aws_security_group.mediawiki_sg.id]
  subnet_id     = aws_subnet.Producao_subneta.id 
  associate_public_ip_address = true

  root_block_device {
  volume_size = 50
  }

  tags = {
    Name = lookup(var.aws_tags,"webserver1")
    group = "web"
  }
}

resource "aws_instance" "webserver2" {
  ami           = var.aws_ami
  availability_zone = element(var.zonadisp, 1)
  instance_type = var.aws_instance_type
  key_name  = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [aws_security_group.mediawiki_sg.id]
  subnet_id     = aws_subnet.Producao_subnetb.id
  associate_public_ip_address = true

  root_block_device {
  volume_size = 50
  }

  tags = {
    Name = lookup(var.aws_tags,"webserver2")
    group = "web"
  }
}

resource "aws_elb" "mw_elb" {
  name = "MediaWikiELB"
  subnets         = [aws_subnet.Producao_subneta.id, aws_subnet.Producao_subnetb.id]
  security_groups = [aws_security_group.mediawiki_sg.id]
  instances = [aws_instance.webserver1.id, aws_instance.webserver2.id]
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}


output "pem" {
        value = [tls_private_key.mw_key.private_key_pem]
}

output "WIKI01" {
  value = aws_eip.mw_eip_01.public_ip
}

output "WIKI02" {
  value = aws_eip.mw_eip_02.public_ip
}

output "LoadBalance" {
  value = aws_elb.mw_elb.dns_name
}