provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias = "bucket"
  region = "eu-central-1"
}

terraform {
  required_providers {
    aws = "3.48.0"
  }
}
