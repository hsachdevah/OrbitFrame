# Cloud Functions Framework (Terraform)

This repository contains a modular, configuration-driven framework for deploying Google Cloud Functions (Gen 2) using Terraform. It simplifies the management of multiple functions, supporting features like:

*   **Configuration-driven:** Define all functions in `terraform.tfvars`.
*   **Source Code Management:** Automatically zips and uploads source code from a local directory.
*   **Security:** Per-function Service Accounts, fine-grained IAM permissions, and Secret Manager integration.
*   **Scheduling:** Optional Cloud Scheduler integration for recurring jobs.
*   **Networking:** Easy toggle for Public/Private access.
*   **Observability:** built-in basic error rate alerting.

## Directory Structure

```
.
├── main.tf                  # Root Terraform logic (calls the module)
├── variables.tf             # Input definitions
├── terraform.tfvars         # Configuration file (Define your functions here)
├── backend.tf               # State management configuration
├── modules/
│   └── function_factory/    # The reusable module logic
└── src/                     # Source code for your functions
    ├── function-a/
    └── function-b/
```

## How to Add a New Function

1.  Create a new directory in `src/` (e.g., `src/my-new-func`) and add your code (`main.py`, `requirements.txt`, etc.).
2.  Open `terraform.tfvars`.
3.  Add a new entry to the `cloud_functions` map:

```hcl
cloud_functions = {
  # ... existing functions ...

  "my-new-func" = {
    source_dir  = "./src/my-new-func"
    runtime     = "python310"
    entry_point = "main"
    
    # Optional: Make it public
    is_public   = true

    # Optional: Schedule it
    schedule_config = {
      cron = "0 9 * * *" # Daily at 9 AM
    }

    # Optional: Environment Variables
    environment_variables = {
      ENV = "production"
    }
  }
}
```

4.  Run `terraform apply`.

## Configuration Options

| Option | Type | Description |
| source_dir | string | Path to the function source code. |
| runtime | string | Runtime environment (e.g., `python310`, `nodejs18`). Default: `python310`. |
| entry_point | string | Name of the function to execute. Default: `main`. |
| is_public | bool | If `true`, allows unauthenticated access. Default: `false`. |
| schedule_config | object | Optional. contains `cron` (string) and `time_zone` (string). |
| bucket_permissions | map | Map of Bucket Name -> IAM Role (e.g., `roles/storage.objectViewer`). |
| secret_env_vars | map | Map of Env Var Name -> Secret Resource ID. |

## Requirements

*   Terraform >= 1.0
*   Google Cloud SDK (gcloud) installed and authenticated.
