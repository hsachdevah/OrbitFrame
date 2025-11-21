variable "project_id" {
  description = "The Google Cloud Project ID"
  type        = string
}

variable "region" {
  description = "The Google Cloud Region"
  type        = string
  default     = "us-central1"
}

variable "cloud_functions" {
  description = "Map of cloud functions to deploy"
  type = map(object({
    source_dir         = string
    runtime            = optional(string, "python310")
    entry_point        = optional(string, "main")
    is_public          = optional(bool, false)
    environment_variables = optional(map(string), {})
    secret_env_vars    = optional(map(object({
      secret_id = string
      version   = optional(string, "latest")
    })), {})
    bucket_permissions = optional(map(string), {})
    schedule_config = optional(object({
      cron      = string
      time_zone = optional(string, "Etc/UTC")
    }), null)
  }))
}
