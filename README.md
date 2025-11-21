# Cloud Functions Framework (Terraform)

This repository contains a modular, configuration-driven framework for deploying Google Cloud Functions (Gen 2) using Terraform. It simplifies the management of multiple functions, supporting features like:

*   **Configuration-driven:** Define functions in individual `config.yaml` files.
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
├── terraform.tfvars         # Global project configuration
├── backend.tf               # State management configuration
├── modules/
│   └── function_factory/    # The reusable module logic
└── functions/               # Directory containing all functions
    ├── function-a/
    │   ├── config.yaml      # Function configuration
    │   └── src/             # Source code (main.py, requirements.txt)
    └── function-b/
        ├── config.yaml
        └── src/
```

## How to Add a New Function

1.  Create a new directory in `functions/` (e.g., `functions/my-new-func`).
2.  Inside that directory, create a `src/` folder and add your code (`main.py`, `requirements.txt`, etc.).
3.  Inside `functions/my-new-func`, create a `config.yaml` file:

```yaml
runtime: python310
entry_point: main

# Optional: Make it public
is_public: true

# Optional: Schedule it
schedule_config:
  cron: "0 9 * * *" # Daily at 9 AM

# Optional: Environment Variables
environment_variables:
  ENV: production
```

4.  Run `terraform apply`.

## Configuration Options

These options are used in `config.yaml`:

| Option | Type | Description |
| runtime | string | Runtime environment (e.g., `python310`, `nodejs18`). Default: `python310`. |
| entry_point | string | Name of the function to execute. Default: `main`. |
| is_public | bool | If `true`, allows unauthenticated access. Default: `false`. |
| schedule_config | object | Optional. contains `cron` (string) and `time_zone` (string). |
| bucket_permissions | map | Map of Bucket Name -> IAM Role (e.g., `roles/storage.objectViewer`). |
| secret_env_vars | map | Map of Env Var Name -> Secret Resource ID. |

## Requirements

*   Terraform >= 1.0
*   Google Cloud SDK (gcloud) installed and authenticated.
