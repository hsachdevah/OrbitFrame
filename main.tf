provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_storage_bucket" "source_bucket" {
  name          = "${var.project_id}-function-source"
  location      = var.region
  force_destroy = false
  uniform_bucket_level_access = true
  
  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }
}

module "function_factory" {
  source   = "./modules/function_factory"
  for_each = var.cloud_functions

  project_id            = var.project_id
  region                = var.region
  function_name         = each.key
  source_dir            = each.value.source_dir
  runtime               = each.value.runtime
  entry_point           = each.value.entry_point
  is_public             = each.value.is_public
  environment_variables = each.value.environment_variables
  secret_env_vars       = each.value.secret_env_vars
  bucket_permissions    = each.value.bucket_permissions
  schedule_config       = each.value.schedule_config
  source_bucket_name    = google_storage_bucket.source_bucket.name
}
