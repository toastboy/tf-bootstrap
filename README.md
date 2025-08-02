# tf-bootstrap

Terraform Bootstrap for the toastboy org: fundamental, org-wide setup items

The .env file is only for local development runs and grabs its secrets
from 1Password using the references. For Terraform Cloud runs, these variables
are set statically in the tf_bootstrap workspace.

To run locally during development, use:

``op run --env-file=.env -- terraform plan``
