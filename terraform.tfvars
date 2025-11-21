project_id = "my-gcp-project-id"
region     = "us-central1"

cloud_functions = {
  "api-service" = {
    source_dir  = "./src/sample-http"
    runtime     = "python310"
    entry_point = "hello_http"
    is_public   = true
    environment_variables = {
      LOG_LEVEL = "INFO"
    }
  }

  "nightly-job" = {
    source_dir  = "./src/sample-scheduled"
    runtime     = "python310"
    entry_point = "hello_scheduled"
    is_public   = false
    schedule_config = {
      cron = "0 2 * * *" # Every day at 2 AM
    }
    # Grant read access to a specific data bucket
    bucket_permissions = {
      "my-data-lake" = "roles/storage.objectViewer"
    }
    # Example of using a secret
    secret_env_vars = {
      API_KEY = {
        secret_id = "projects/my-project/secrets/api-key"
        version   = "1"
      }
    }
  }
}
