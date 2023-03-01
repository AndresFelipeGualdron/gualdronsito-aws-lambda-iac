variable "myregion" {
  type = string
}

variable "accountId" {
  type = string
}

variable "api_name" {
  type = string
}

variable "lambda_name" {
  type = string
}

variable "lambda_handler" {
  type = string
}

variable "lambda_runtime" {
  type = string
}

variable "name_role" {
  type = string
}

variable "source_code_hash_lambda" {}

variable "filename_lambda" {
  type = string
}

variable "resource_integration" {
  type = string
}

variable "http_method_integration" {
  type = string
}

variable "cors_settings" {
  type = any

  default = {
    "loggingLevel"       = "INFO"
    "metricsEnabled"     = true
    "loggingLevel"       = "INFO"
    "throttlingBurstLimit" = 1000
    "throttlingRateLimit" = 500
    "cors" = {
      "allowMethods" = ["OPTIONS", "POST", "GET"]
      "allowHeaders" = ["Content-Type", "X-Amz-Date", "Authorization", "X-Api-Key", "X-Amz-Security-Token"]
      "allowOrigins" = ["*"]
    }
  }
}