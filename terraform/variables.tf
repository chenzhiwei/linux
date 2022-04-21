variable "project" {
  type = string
  default = "my-project"
  description = "the gcp project name"
}

variable "tags" {
  type = list(string)
  description = "firewall tags"
}

variable "metadata" {
  type = map(string)
  description = "metadata"
}

variable "interfaces" {
  type = list(object({
    subnetwork = string
  }))
}

variable "disks" {
  type = list(object({
    boot = bool
    auto_delete = bool
    mode = string
    type = string
    size_gb = number
    image_family = string
  }))
}

variable "service_account_scopes" {
  type = list(string)
  default = [
    "https://www.googleapis.com/auth/compute"
  ]
}
