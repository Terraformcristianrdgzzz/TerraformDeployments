# TerraformDeployments
First Deployments  using Good Practices learn in the book "Terraform-Up-and-Running"

# terraform-azure-oidc

A modular Terraform repository for managing Azure infrastructure with reusable modules, environment-specific configurations, GitHub Actions, and OpenID Connect (OIDC).

The repository keeps reusable infrastructure building blocks separate from the configurations that deploy them. GitHub Actions authenticates to Azure through Microsoft Entra ID workload identity federation, avoiding long-lived Azure credentials in GitHub.

> Replace example names, IDs, regions, and resource settings with values appropriate for your environment.

## Design principles

- **Modules define reusable infrastructure.** They do not configure a backend or hold environment-specific credentials.
- **Live configurations compose modules.** Each deployable component has its own directory, inputs, and Terraform state.
- **Azure Blob Storage holds remote state.** The state container is private, access is controlled with Azure RBAC, and Azure Blob leases provide state locking.
- **GitHub Actions uses OIDC.** No Azure client secret is needed in GitHub.
- **Environments are isolated.** `stage` and `prod` have separate configurations, state keys, and deployment protections.

## Repository layout

```text
.
├── .github/
│   └── workflows/
│       └── terraform.yml
├── modules/
│   ├── network/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── versions.tf
│   ├── services/
│   │   └── webserver-cluster/
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       ├── outputs.tf
│   │       └── versions.tf
│   └── data-stores/
│       └── mysql/
│           ├── main.tf
│           ├── variables.tf
│           ├── outputs.tf
│           └── versions.tf
├── live/
│   ├── stage/
│   │   ├── network/
│   │   │   ├── backend.tf
│   │   │   ├── main.tf
│   │   │   ├── providers.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   ├── services/
│   │   │   └── webserver-cluster/
│   │   │       ├── backend.tf
│   │   │       ├── main.tf
│   │   │       ├── providers.tf
│   │   │       └── variables.tf
│   │   └── data-stores/
│   │       └── mysql/
│   │           ├── backend.tf
│   │           ├── main.tf
│   │           ├── providers.tf
│   │           └── variables.tf
│   ├── prod/
│   │   ├── network/
│   │   ├── services/
│   │   │   └── webserver-cluster/
│   │   └── data-stores/
│   │       └── mysql/
│   └── global/
│       └── terraform-state/
│           ├── main.tf
│           ├── variables.tf
│           └── outputs.tf
├── .gitignore
└── README.md
