provider "aws" {
  region = var.aws_region
}


#Abrir portas de aplicação
resource "aws_security_group" "grafana_sg" {
  name = "grafana_sg"
  description = "HTTP, SSH e BANCO"
  vpc_id = aws_vpc.vinnland_vpc.id

ingress {
    from_port = 3000
    to_port = 3000
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

resource "aws_instance" "webserver3" {
  ami           = var.aws_ami
  availability_zone = element(var.zonadisp, 0)
  instance_type = var.aws_instance_type
  key_name  = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [aws_security_group.grafana_sg.id]
  subnet_id     = aws_subnet.Producao_subneta.id
  associate_public_ip_address = true

  root_block_device {
  volume_size = 50
  }

  tags = {
    Name = lookup(var.aws_tags,"webserver3")
    group = "grafana"
  }
}

output "pem" {
        value = [tls_private_key.mw_key.private_key_pem]
}

output "Grafana" {
  value = aws_eip.grafana.public_ip
}
