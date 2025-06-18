variable "aws_region" {
  description = "Die AWS-Region, in der die Ressourcen erstellt werden"
  type        = string
}

variable "bucket_name" {
  description = "Name des S3 Buckets für das Terraform Backend"
  type        = string
}

variable "ssh_key_name" {
  description = "Name des SSH Key Pairs, das in AWS erstellt wird"
  type        = string
}

variable "instance_type" {
  description = "EC2 Instance Type"
  type        = string
  default     = "t3.micro"
}

variable "ssh_public_key" {
  description = "Öffentlicher SSH-Key als String"
  type        = string
}

