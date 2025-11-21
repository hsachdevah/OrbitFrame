terraform {
  backend "gcs" {
    bucket = "project-id-tf-state-bucket"
    prefix = "orbitframe"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}