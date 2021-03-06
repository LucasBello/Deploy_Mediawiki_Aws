#As variaveis já estão no Terraform Cloud
#Se for deploy manual tem que fazer o EXPORT

provider "aws" {
  region = var.aws_region
}

#Setup da VPC
resource "aws_vpc" "vinnland_vpc" {
  cidr_block = var.aws_cidr_vpc
  tags = {
    Name = "VINAWSVPC"
  }
}

#Gateway para internet
resource "aws_internet_gateway" "wiki_igw" {
    vpc_id = aws_vpc.vinnland_vpc.id
    tags = {
        Name = "Gateway para internet"
    }
}


#Subnet Producao_a - us-west-2a
resource "aws_subnet" "Producao_subneta" {
  vpc_id = aws_vpc.vinnland_vpc.id
  cidr_block = var.aws_cidr_subnet1
  availability_zone = element(var.zonadisp, 0)

  tags = {
    Name = "sub_Producao_a"
  }
}

#Subnet Producao_b - sa-east-1b
resource "aws_subnet" "Producao_subnetb" {
  vpc_id = aws_vpc.vinnland_vpc.id
  cidr_block = var.aws_cidr_subnet2
  availability_zone = element(var.zonadisp, 1)

  tags = {
    Name = "sub_Producao_b"
  }
}

#Subnet Producao_c - sa-east-1c
resource "aws_subnet" "DB_Producao_subnet" {
  vpc_id = aws_vpc.vinnland_vpc.id
  cidr_block = var.aws_cidr_subnet3
  availability_zone = element(var.zonadisp, 2)

  tags = {
    Name = "sub_DB_Producao"
  }
}

#Tabela da rota de acesso a internet
resource "aws_route_table" "mw_rt" {
  vpc_id = aws_vpc.vinnland_vpc.id

  route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.wiki_igw.id
    }

    tags = {
      Name = "Rota MediaWiki"
    }
}
resource "aws_route_table_association" "Producao_Internet" {
    subnet_id = aws_subnet.Producao_subneta.id
    route_table_id = aws_route_table.mw_rt.id
}

resource "aws_route_table_association" "Producao_Internetb" {
    subnet_id = aws_subnet.Producao_subnetb.id
    route_table_id = aws_route_table.mw_rt.id
}

resource "aws_route_table_association" "DB_Producao_subnet" {
    subnet_id = aws_subnet.DB_Producao_subnet.id
    route_table_id = aws_route_table.mw_rt.id
}

#Abrir portas de aplicação
resource "aws_security_group" "mw_sg" {
  name = "mw_sg"
  description = "HTTP, SSH, BANCO e GRAFANA"
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
#Liberar porta 3306
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]

  }
#Liberar porta 3000
  ingress {
    from_port = 3000
    to_port = 3000
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
#Liberar porta 9100
  ingress {
    from_port = 9100
    to_port = 9100
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

#Liberar porta 9090
  ingress {
    from_port = 9090
    to_port = 9090
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]

  }

#Liberar porta 9155
  ingress {
    from_port = 9115
    to_port = 9115
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

#Elastic IP
resource "aws_eip" "grafana" {
    instance = aws_instance.webserver3.id
  vpc      = true
  depends_on = ["aws_internet_gateway.wiki_igw"]
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

resource "aws_eip" "mw_eip_db" {
    instance = aws_instance.dbserver.id
  vpc      = true
  depends_on = ["aws_internet_gateway.wiki_igw"]
}

resource "aws_elb" "mw_elb" {
  name = "MediaWikiELB"
  subnets         = [aws_subnet.Producao_subneta.id, aws_subnet.Producao_subnetb.id]
  security_groups = [aws_security_group.mw_sg.id]
  instances = [aws_instance.webserver1.id, aws_instance.webserver2.id]
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
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

#Setup das Instancias
resource "aws_instance" "webserver1" {
  ami           = var.aws_ami_RHEL
  availability_zone = element(var.zonadisp, 0)
  instance_type = var.aws_instance_type
  key_name  = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [aws_security_group.mw_sg.id]
  subnet_id     = aws_subnet.Producao_subneta.id 
  private_ip = lookup(var.ip_priv,"wiki01")
  associate_public_ip_address = true
  #user_data = "gobal_script.sh"

  #root_block_device {
  #volume_size = 50
  #}

  tags = {
    Name = lookup(var.aws_tags,"webserver1")
    group = "web"
  }
}

resource "aws_instance" "webserver2" {
  ami           = var.aws_ami_RHEL
  availability_zone = element(var.zonadisp, 1)
  instance_type = var.aws_instance_type
  key_name  = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [aws_security_group.mw_sg.id]
  subnet_id     = aws_subnet.Producao_subnetb.id
  private_ip = lookup(var.ip_priv,"wiki02")
  associate_public_ip_address = true
  #user_data = "gobal_script.sh"

  #root_block_device {
  #volume_size = 50
  #}

  tags = {
    Name = lookup(var.aws_tags,"webserver2")
    group = "web"
  }
}

resource "aws_instance" "webserver3" {
  ami           = var.aws_ami_Ubuntu
  availability_zone = element(var.zonadisp, 0)
  instance_type = var.aws_instance_type
  key_name  = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [aws_security_group.mw_sg.id]
  subnet_id     = aws_subnet.Producao_subneta.id
  private_ip = lookup(var.ip_priv,"grafana")
  associate_public_ip_address = true
  #user_data = "prometheus_script.sh"

  #root_block_device {
  #volume_size = 50
  #}

  tags = {
    Name = lookup(var.aws_tags,"webserver3")
    group = "grafana"
  }
}

resource "aws_instance" "dbserver" {
  ami           = var.aws_ami_RHEL
  availability_zone = element(var.zonadisp, 2)
  instance_type = var.aws_instance_type
  key_name  = aws_key_pair.generated_key.key_name 
  vpc_security_group_ids = [aws_security_group.mw_sg.id]
  subnet_id     = aws_subnet.DB_Producao_subnet.id
  private_ip = lookup(var.ip_priv,"sql")
  associate_public_ip_address = true
  #user_data = "gobal_script.sh"
    
  #root_block_device {
  #volume_size = 50
  #}

  tags = {
    Name = lookup(var.aws_tags,"dbserver")
    group = "db"
  }
}

output "pem" {
  value = [tls_private_key.mw_key.private_key_pem]
}

output "LoadBalance" {
  value = aws_elb.mw_elb.dns_name
}

output "Grafana" {
  value = aws_eip.grafana.public_ip
}

output "WIKI01" {
  value = aws_eip.mw_eip_01.public_ip
}

output "WIKI02" {
  value = aws_eip.mw_eip_02.public_ip
}

output "DATABASE" {
  value = aws_eip.mw_eip_db.public_ip
}