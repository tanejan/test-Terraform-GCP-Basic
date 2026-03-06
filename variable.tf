variable "project_id"
variable "region"
variable "zone"

variable "common_tags" {
  type = map(string)
  default = {
    environment = "dev"
    managed_by  = "terraform"
    owner       = "training-team"
  }
}
