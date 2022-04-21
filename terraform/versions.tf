terraform {
  required_version = "> 1.6.0"
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.18.0"
    }
  }
}
