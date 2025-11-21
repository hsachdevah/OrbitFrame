terraform {
  backend "gcs" {
    bucket = "my-terraform-state-bucket"
    prefix = "cloud-functions"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}
