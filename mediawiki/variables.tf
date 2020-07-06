#Região
variable "aws_region" {
  default =  "us-west-2"
}

 #Zonas de Disponibilidade 
variable "zonadisp" {
  default = ["us-west-2a", "us-west-2b", "us-west-2c"] #Indice inicia em 0
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

#CNAME dos servers
variable "aws_tags" {
  default = {
    "webserver1" = "MEDIAWIKI01"
	"webserver2" = "MEDIAWIKI02"
  }
}

#Nome do PEM
variable "keyname" {
  default = "mediawiki_key"
}

#Red Hat Enterprise Linux 8 (HVM) para região us-west-2.
#Verificar ami para outras regiões
variable "aws_ami" {
  default= "ami-28e07e50"
}

variable "aws_instance_type" {
  default = "t2.micro"
}