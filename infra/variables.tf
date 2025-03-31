
#AMI
variable "ami_id" {
    description = "ID da ami do Ubuntu"
    type = string
    default = "ami-04b4f1a9cf54c11d0" 
}

#tipo de instância
variable "instance_type" {
    description = "Tipo de Instância do EC2"
    type = string
    default = "t2.micro"
  
}

#chave ssh
variable "key_name" {
    description = "Nome da chave SSH"
    type = string
    default = "RSA_key"
  
}