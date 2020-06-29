#Região
variable "aws_region" {

  default =  "us-east-1" #São Paulo
}

 # Zonas de Disponibilidade 
variable "zonadisp" {
  #type = "list"
  default = ["us-east-1a", "us-east-1b", "us-east-1c"] #Indice inicia em 0
}

variable "keyname" {
  default = "mediawiki"
}

# Red Hat Enterprise Linux 8 (HVM)
variable "aws_ami" {
  default= "ami-00e63b4959e1a98b7"
}

# VPC e Subnet
variable "aws_cidr_vpc" {
  default = "10.0.0.0/16"
}

variable "aws_cidr_subnet1" {
  default = "10.0.1.0/24"
}

variable "aws_cidr_subnet2" {
  default = "10.0.2.0/24"
}

variable "aws_cidr_subnet3" {
  default = "10.0.3.0/24"
}

variable "aws_sg" {
  default = "sg_mediawiki"
}

variable "aws_tags" {
  #type = "map"
  default = {
    "webserver1" = "UOLWIKI01"
	  "webserver2" = "UOLWIKI01"
    "dbserver"   = "UOLSQLPROD01" 
  }
}

variable "aws_instance_type" {
  default = "t2.micro"
}