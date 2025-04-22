
#AMI
variable "ami_id" {
    description = "ID da ami do Ubuntu"
    type = string
    default = "ami-0c1ac8a41498c1a9c" 
}

#tipo de instância
variable "instance_type" {
    description = "Tipo de Instância do EC2"
    type = string
    default = "t3.micro"
}

#numero de instancias
variable "instance_count" {
  description = "Número de instâncias backend"
  type        = number
  default     = 1
}

#chave ssh
variable "key_name" {
    description = "Nome da chave SSH"
    type = string
    default = "RSA_key"
}