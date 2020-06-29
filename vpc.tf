#As variaveis já estão no Terraform
provider "aws" {
  version = "2.33.0"

  region = var.region
}

#Setup da VPC
resource "aws_vpc" "uol_vpc" {
  cidr_block = "${var.aws_cidr_vpc}"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "UOLAWSVPC"
  }
}
#Subnet Producao_a - sa-east-1a
resource "aws_subnet" "Producao_subneta" {
  vpc_id = "${aws_vpc.uol_vpc.id}"
  cidr_block = "${var.aws_cidr_subnet1}"
  availability_zone = "${element(var.zonadisp, 0)}"

  tags {
    Name = "sub_Producao_a"
  }
}

#Subnet Producao_b - sa-east-1b
resource "aws_subnet" "Producao_subnetb" {
  vpc_id = "${aws_vpc.uol_vpc.id}"
  cidr_block = "${var.aws_cidr_subnet2}"
  availability_zone = "${element(var.zonadisp, 1)}"

  tags = {
    Name = "sub_Producao_b"
  }
}

#Subnet Producao_c - sa-east-1c
resource "aws_subnet" "DB_Producao_subnet" {
  vpc_id = "${aws_vpc.uol_vpc.id}"
  cidr_block = "${var.aws_cidr_subnet3}"
  availability_zone = "${element(var.zonadisp, 2)}"

  tags = {
    Name = "sub_DB_Producao"
  }
}

#NACL - TCP 80, 3306 e 22
resource "aws_security_group" "mw_sg" {
  name = "mw_sg"
  vpc_id = "${aws_vpc.uol_vpc.id}"
  ingress {
    from_port = 22 
    to_port  = 22
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    from_port = 80
    to_port  = 80
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 3306
    to_port  = 3306
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = "0"
    to_port  = "0"
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
}

#Gerando Key Privada
resource "tls_private_key" "mw_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
resource "aws_key_pair" "generated_key" {
  key_name   = "${var.keyname}"
  public_key = "${tls_private_key.mw_key.public_key_openssh}"
}


#####Gateway para internet
#resource "aws_internet_gateway" "pd_igw" {
#    vpc_id = "${aws_vpc.uol_vpc.id}"
#    tags {
#        Name = "Gateway para internet"
#    }
#}

#####Tabela da rota de acesso a internet
#resource "aws_route_table" "pd_rt" {
#  vpc_id = "${aws_vpc.uol_vpc.id}"
#  route {
#        cidr_block = "0.0.0.0/0"
#        gateway_id = "${aws_internet_gateway.pd_igw.id}"
#    }
#}
#resource "aws_route_table_association" "Producao_Internet" {
#    subnet_id = "${aws_subnet.Producao_subneta.id}"
#    route_table_id = "${aws_route_table.pd_rt.id}"
#}

#####NAT
#resource "aws_eip" "nat" {
#}
#
#resource "aws_nat_gateway" "main-natgw" {
#  allocation_id = "${aws_eip.nat.id}"
#  subnet_id     = "${aws_subnet.Producao_subneta.id}"
#
#  tags {
#   Name = "main-nat"
#  }
#}

#Setup das Instancias
resource "aws_instance" "WebServer1" {
  ami           = "${var.aws_ami}"
  instance_type = "${var.aws_instance_type}"
  key_name  = "${aws_key_pair.generated_key.key_name}"
  vpc_security_group_ids = ["${aws_security_group.mw_sg.id}"]
  subnet_id     = "${aws_subnet.Producao_subneta.id}" 
  associate_public_ip_address = true
  tags = {
    Name = "${lookup(var.aws_tags,"WebServer1")}"
    group = "web"
  }
}

resource "aws_instance" "webserver2" {
  #depends_on = ["${aws_security_group.mw_sg}"]
  ami           = "${var.aws_ami}"
  instance_type = "${var.aws_instance_type}"
  key_name  = "${aws_key_pair.generated_key.key_name}"
  vpc_security_group_ids = ["${aws_security_group.mw_sg.id}"]
  subnet_id     = "${aws_subnet.Producao_subnetb.id}" 
  associate_public_ip_address = true
  tags = {
    Name = "${lookup(var.aws_tags,"webserver2")}"
    group = "web"
  }
}

resource "aws_instance" "dbserver" {
  #depends_on = ["${aws_security_group.mw_sg}"]
  ami           = "${var.aws_ami}"
  instance_type = "${var.aws_instance_type}"
  key_name  = "${aws_key_pair.generated_key.key_name}" 
  vpc_security_group_ids = ["${aws_security_group.mw_sg.id}"]
  subnet_id     = "${aws_subnet.DB_Producao_subnet.id}"

  tags = {
    Name = "${lookup(var.aws_tags,"dbserver")}"
    group = "db"
  }
}

resource "aws_elb" "mw_elb" {
  name = "MediaWikiELB"
  subnets         = ["${aws_subnet.Producao_subneta.id}", "${aws_subnet.Producao_subnetb.id}"]
  security_groups = ["${aws_security_group.mw_sg.id}"]
  instances = ["${aws_instance.webserver1.id}", "${aws_instance.webserver2.id}"]
  listener = {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}

output "pem" {
        value = ["${tls_private_key.mw_key.private_key_pem}"]
}

output "address" {
  value = "${aws_elb.mw_elb.dns_name}"
}