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

#CNAME dos servers
variable "aws_tags" {
  default = {
    "dbserver"   = "SQLPROD01" 
  }
}

#Nome do PEM
variable "keyname" {
  default = "mariadb_key"
}

#Red Hat Enterprise Linux 8 (HVM) para região us-west-2.
#Verificar ami para outras regiões
variable "aws_ami" {
  default= "ami-28e07e50"
}

variable "aws_instance_type" {
  default = "t2.micro"
}