#Região
variable "aws_region" {
  type = "string"
  default =  "sa-east-1" #São Paulo
}

 # Zonas de Disponibilidade 
variable "zonadisp" {
  type = "list"
  default = ["sa-east-1a", "sa-east-1b", "sa-east-1c"] #Indice inicia em 0
}

variable "keyname" {
  default = "mediawiki"
}

# RHEL 7.5
variable "aws_ami" {
  default= "ami-28e07e50"
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
  type = "map"
  default = {
    "webserver1" = "UOLWIKI01"
	  "webserver2" = "UOLWIKI01"
    "dbserver"   = "UOLSQLPROD01" 
  }
}

variable "aws_instance_type" {
  default = "t2.micro"
}