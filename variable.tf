variable "project_id" { type = string }
variable "region"     { default = "us-central1" }
variable "zone"       { default = "us-central1-a" }
variable "environment" {default = "dev"}
variable "owner"      {default = "neeraj"}

variable "common_tags" {
  type = map(string)
  default = {
    environment = "dev"
    managed_by  = "terraform"
    owner       = "training-team"
  }
}
