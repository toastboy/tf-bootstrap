# tf-bootstrap

Terraform Bootstrap for the toastboy org: fundamental, org-wide setup items

The .env file is only for local development runs and grabs its secrets
from 1Password using the references. For Terraform Cloud runs, these variables
are set statically in the tf_bootstrap workspace.

To run locally during development, use:

``op run --env-file=.env -- terraform plan``

## Overview

This is a simple repo with one job: to get the toastboy infrastructure basics up
and running with the links for secrets management put in place.

If we're recreating everything from first principles then some manual setup is
required. Once that's done, everything else can run through automation using
Terraform, Ansible etc. This Terraform creates a Service Access Token in
Cloudflare for 1Password Connect, an Access Policy for it, and a Zero Trust
Access Application to allow connections using that policy. So, on top of that, a
first-time setup will need to make sure there's a Cloudflare tunnel in place, a
running pair of 1Password Connect containers and a valid DNS entry pointing to
them.
