terraform {
  backend "s3" {
    bucket = "my-blog1"
    key    = "terraform.tfstate"
    region = "eu-central-1"
    encrypt = true
  }
}
