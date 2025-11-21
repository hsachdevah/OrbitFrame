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

locals {
  function_configs = {
    for f in fileset(path.module, "functions/*/config.yaml") :
    basename(dirname(f)) => yamldecode(file(f))
  }
}

module "function_factory" {
  source   = "./modules/function_factory"
  for_each = local.function_configs

  project_id            = var.project_id
  region                = var.region
  function_name         = each.key
  source_dir            = "${path.module}/functions/${each.key}/src"
  runtime               = try(each.value.runtime, "python310")
  entry_point           = try(each.value.entry_point, "main")
  is_public             = try(each.value.is_public, false)
  environment_variables = try(each.value.environment_variables, {})
  secret_env_vars       = try(each.value.secret_env_vars, {})
  bucket_permissions    = try(each.value.bucket_permissions, {})
  schedule_config       = try(each.value.schedule_config, null)
  source_bucket_name    = google_storage_bucket.source_bucket.name
}
