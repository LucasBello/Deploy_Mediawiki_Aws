#Região
variable "aws_region" {
  default =  "us-east-1"
}

 #Zonas de Disponibilidade 
variable "zonadisp" {
  default = ["us-east-1a", "us-east-1b", "us-east-1c"] #Indice inicia em 0
}

#VPC
variable "aws_cidr_vpc" {
  default = "10.0.0.0/16"
}

#Subnet Producao A
variable "aws_cidr_subnet1" {
  default = "10.0.1.0/24"
}

#Subnet Producao B
variable "aws_cidr_subnet2" {
  default = "10.0.2.0/24"
}

#Subnet Producao Banco de Dados
variable "aws_cidr_subnet3" {
  default = "10.0.3.0/24"
}

#Nome do Security Group
variable "aws_sg" {
  default = "sg_mediawiki"
}

#CNAME dos servers
variable "aws_tags" {
  default = {
    "webserver1" = "MEDIAWIKI01"
	  "webserver2" = "MEDIAWIKI02"
    "dbserver"   = "SQLPROD01" 
  }
}

#Nome do PEM
variable "keyname" {
  default = "mediawiki_key"
}

#Red Hat Enterprise Linux 8 (HVM) para região us-west-2.
#Verificar ami para outras regiões
variable "aws_ami" {
  default= "ami-098f16afa9edf40be"
}

variable "aws_instance_type" {
  default = "t2.micro"
}