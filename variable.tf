variable "region" {
  default = ""
}

variable "account_id" {
  default = ""
}

variable "lambda_function_name" {
  default = ""
}

variable "email-topic-subscription" {
  default = ""
}

variable "sns-topic-name" {
  default = ""
}

variable "event_scheduler" {
  default = "" 
}

variable "tags" {
  default = {
    "Environment" = "Dev"
    "Project"     = "Ec2-Right-Sizing"
  }
}