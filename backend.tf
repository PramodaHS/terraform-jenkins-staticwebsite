terraform {
  backend "s3" {
    bucket         = "pramod-terraform-state"
    key            = "mys3staticwebsite/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}
