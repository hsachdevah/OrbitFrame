variable "project_id" {
  description = "The Google Cloud Project ID"
  type        = string
}

variable "region" {
  description = "The Google Cloud Region"
  type        = string
}

variable "function_name" {
  description = "Name of the function"
  type        = string
}

variable "environment_variables" {
  description = "Map of environment variables"
  type        = map(string)
  default     = {}
}

variable "is_public" {
  description = "Whether the function should be publicly accessible"
  type        = bool
  default     = false
}

variable "schedule_config" {
  description = "Configuration for Cloud Scheduler (optional). Example: { cron = '0 0 * * *', time_zone = 'Etc/UTC' }"
  type = object({
    cron      = string
    time_zone = optional(string, "Etc/UTC")
  })
  default = null
}

variable "bucket_permissions" {
  description = "Map of bucket names to roles to grant the service account. Example: { 'my-bucket' = 'roles/storage.objectViewer' }"
  type        = map(string)
  default     = {}
}

variable "secret_env_vars" {
  description = "Map of environment variable names to secret configuration. Example: { 'API_KEY' = { secret_id = 'projects/.../secrets/api-key', version = '1' } }"
  type = map(object({
    secret_id = string
    version   = optional(string, "latest")
  }))
  default = {}
}

variable "source_dir" {
  description = "Path to the local source directory (e.g., ./src/my-func)"
  type        = string
}

variable "runtime" {
  description = "Runtime (e.g., python310, nodejs18)"
  type        = string
  default     = "python310"
}

variable "entry_point" {
  description = "The name of the function (entry point) in the source code"
  type        = string
  default     = "main"
}

variable "source_bucket_name" {
  description = "Name of the GCS bucket to store source code zips"
  type        = string
}
