terraform {
  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "aws" {}
provider "random" {}

variable "openai_api_key" {
  description = "API key for interacting with OpenAI programmatically"
  type        = string
}

resource "random_pet" "openai_api_key" {
  length    = 2
  separator = "-"
}

resource "aws_ssm_parameter" "openai_api_key" {
  name        = "/openai_client/${random_pet.openai_api_key.id}/api_key"
  description = "API Key for OpenAI"
  type        = "SecureString"
  value       = var.openai_api_key
  overwrite   = true
}

data "aws_region" "current" {}

output "OPENAI_API_KEY" {
  value = {
    arn: aws_ssm_parameter.openai_api_key.arn
    key: aws_ssm_parameter.openai_api_key.name
    region: data.aws_region.current.name
    type: "ssm"
  }
}
