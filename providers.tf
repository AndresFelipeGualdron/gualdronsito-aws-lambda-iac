provider "aws" {
  region = "us-east-1"
}

terraform {
  required_providers {
    aws = "3.48.0"
  }
}
