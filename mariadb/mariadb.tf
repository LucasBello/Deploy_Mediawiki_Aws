provider "aws" {
  region = var.aws_region
}

#Abrir portas de aplicação
resource "aws_security_group" "maria_sg" {
  name = "maria_sg"
  description = "SSH e BANCO"
  vpc_id = aws_vpc.vinnland_vpc.id
#Liberar porta 22
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
#Liberar porta 3306
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "TCP"
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

#Gerando Key Privada
resource "tls_private_key" "mw_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
resource "aws_key_pair" "generated_key" {
  key_name   = var.keyname
  public_key = tls_private_key.mw_key.public_key_openssh
}

#Deploy Instancia
resource "aws_instance" "dbserver" {
  ami           = var.aws_ami
  availability_zone = element(var.zonadisp, 2)
  instance_type = var.aws_instance_type
  key_name  = aws_key_pair.generated_key.key_name 
  vpc_security_group_ids = [aws_security_group.mw_sg.id]
  subnet_id     = aws_subnet.DB_Producao_subnet.id
  
  root_block_device {
  volume_size = 50
  }

  tags = {
    Name = lookup(var.aws_tags,"dbserver")
    group = "db"
  }
}

output "pem" {
        value = [tls_private_key.mw_key.private_key_pem]
}

output "DATABASE" {
  value = aws_eip.grafana.public_ip
}