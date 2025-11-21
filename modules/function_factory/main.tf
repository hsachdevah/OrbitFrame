resource "random_string" "sa_suffix" {
  length  = 4
  special = false
  upper   = false
}

resource "google_service_account" "function_sa" {
  account_id   = "${substr(var.function_name, 0, 25)}-${random_string.sa_suffix.result}"
  display_name = "Service Account for ${var.function_name}"
  project      = var.project_id
}

data "archive_file" "source_zip" {
  type        = "zip"
  source_dir  = var.source_dir
  output_path = "${path.module}/build/${var.function_name}.zip"
}

resource "google_storage_bucket_object" "source_archive" {
  name   = "source/${var.function_name}-${data.archive_file.source_zip.output_md5}.zip"
  bucket = var.source_bucket_name
  source = data.archive_file.source_zip.output_path
}

resource "google_cloudfunctions2_function" "function" {
  name        = var.function_name
  location    = var.region
  description = "Managed by Terraform"
  project     = var.project_id

  build_config {
    runtime     = var.runtime
    entry_point = var.entry_point
    source {
      storage_source {
        bucket = var.source_bucket_name
        object = google_storage_bucket_object.source_archive.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
    service_account_email = google_service_account.function_sa.email
    environment_variables = var.environment_variables
    
    dynamic "secret_environment_variables" {
      for_each = var.secret_env_vars
      content {
        key        = secret_environment_variables.key
        project_id = can(regex("^projects/", secret_environment_variables.value.secret_id)) ? regex("^projects/([^/]+)/secrets/.*$", secret_environment_variables.value.secret_id)[0] : var.project_id
        secret     = can(regex("^projects/", secret_environment_variables.value.secret_id)) ? regex("^projects/[^/]+/secrets/([^/]+)$", secret_environment_variables.value.secret_id)[0] : secret_environment_variables.value.secret_id
        version    = secret_environment_variables.value.version
      }
    }
  }
}

# Cloud Scheduler (Optional)
resource "google_cloud_scheduler_job" "job" {
  count       = var.schedule_config != null ? 1 : 0
  name        = "${var.function_name}-scheduler"
  description = "Trigger for ${var.function_name}"
  schedule    = var.schedule_config.cron
  time_zone   = var.schedule_config.time_zone
  project     = var.project_id
  region      = var.region

  http_target {
    http_method = "GET"
    uri         = google_cloudfunctions2_function.function.service_config[0].uri

    oidc_token {
      service_account_email = google_service_account.function_sa.email
    }
  }
}

# IAM Bindings for Buckets (Flexible)
resource "google_storage_bucket_iam_member" "bucket_permissions" {
  for_each = var.bucket_permissions
  bucket   = each.key
  role     = each.value
  member   = "serviceAccount:${google_service_account.function_sa.email}"
}

# Secret Manager Access (if secrets are used)
resource "google_project_iam_member" "secret_accessor" {
  count   = length(var.secret_env_vars) > 0 ? 1 : 0
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.function_sa.email}"
}

# Basic Alerting Policy
resource "google_monitoring_alert_policy" "error_rate" {
  display_name = "Error Rate Alert - ${var.function_name}"
  combiner     = "OR"
  project      = var.project_id
  conditions {
    display_name = "Error Rate High"
    condition_threshold {
      filter          = "resource.type = \"cloud_run_revision\" AND resource.labels.service_name = \"${google_cloudfunctions2_function.function.name}\" AND metric.type = \"run.googleapis.com/request_count\" AND metric.labels.response_code_class = \"5xx\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0.5 
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }
  # Note: Notification channels would need to be passed in as a variable
}

# Public Access (Run Invoker)
resource "google_cloud_run_service_iam_member" "public_invoker" {
  count    = var.is_public ? 1 : 0
  location = google_cloudfunctions2_function.function.location
  service  = google_cloudfunctions2_function.function.name
  project  = var.project_id
  role     = "roles/run.invoker"
  member   = "allUsers"
}
