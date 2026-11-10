# TerraformDeployments

Terraform configurations for deploying a small Azure web application in isolated `stage` and `prod` environments. The infrastructure is assembled from reusable modules maintained in separate GitHub repositories.

The initial example will create:

- An Azure virtual network and subnet.
- A Linux virtual machine connected to that subnet.
- A public IP address and a network security group (NSG).
- Apache installed on the VM and configured to serve a simple "Hello" page.

This repository is the deployment repository. It will consume versioned modules; it will not contain their implementation.

## Repository architecture

The project is split into four repositories:

| Repository | Responsibility |
| --- | --- |
| `TerraformDeployments` | Main repository. Holds the environment-specific Terraform configurations for `stage` and `prod`. |
| [`terraform-module-azurerm-network`](https://github.com/cristianrdgzzz/terraform-module-azurerm-network) | Reusable Azure network module. |
| [`terraform-module-azurerm-linux-webserver`](https://github.com/cristianrdgzzz/terraform-module-azurerm-linux-webserver) | Reusable Linux VM, public IP, NSG, and Apache example module. |
| `terraform-azure-deployment-template` | GitHub template repository with a small example configuration that composes the two modules. |

The template repository name is still provisional. Module source URLs must use a version tag that exists in the corresponding repository.

The GitHub template is a starting point for creating new deployment repositories. It copies its files when a new repository is created; it is not itself a runtime dependency of `TerraformDeployments`. Terraform will download the modules directly from their repositories.

## Repository layout

```text
.
├── .github/
│   └── workflows/
├── live/
│   ├── stage/
│   │   └── webserver/
│   └── prod/
│       └── webserver/
└── README.md
```

Each environment is a separate Terraform root configuration with its own remote state key. The `stage` and `prod` configurations can call the same module versions with different inputs.

## Module versioning

Deployment configurations should reference explicit module versions (Git tags), rather than a moving branch. For example, after a module repository publishes a `v1.0.0` tag:

```hcl
module "network" {
  source = "git::https://github.com/cristianrdgzzz/terraform-module-azurerm-network.git?ref=v0.1.0"
}
```

The tag is an example and must be created in the module repository before using it. The module repository is being implemented and does not yet have a published release.

## Azure and GitHub authentication

GitHub Actions is intended to authenticate to Azure using Microsoft Entra workload identity federation (OIDC), without a long-lived Azure client secret. The federated credential is configured to trust the `stage` GitHub Environment. The workflow and end-to-end authentication still need to be implemented and verified.

The stage identity should receive only the permissions required for the resources it manages, scoped to the stage resource group and the state container. Production should use a separate GitHub Environment and an appropriately scoped identity and permissions before production deployment is enabled.

The Azure subscription, resource groups, app registration, federated credential, and some role assignments have been configured manually for learning. Review their actual settings before running Terraform; this README does not certify that OIDC or remote state access is working.

## Cost and security notes

- A public IP and a running VM may incur charges. Check the Azure offer's remaining free allowance and the pricing estimate for the selected VM size, disk, region, IP, and network usage before deployment.
- The NSG should allow HTTP only as required for the demo. If SSH is enabled, restrict it to a trusted source IP; do not expose SSH to the entire internet.
- Terraform state and plan files can contain sensitive values. Store state in a private Azure Blob container and restrict access with Azure RBAC.
- Do not commit credentials, Terraform state, plan files, or local variable files containing sensitive values.
- A VM that is no longer needed should be deallocated or removed, and its related billable resources reviewed.

## Planned implementation order

1. Create and implement the network module repository.
2. Create and implement the Linux web server module repository.
3. Create a GitHub template repository that composes the published module versions.
4. Add the `stage` configuration in this repository and validate OIDC and remote state access.
5. Add `prod` only after the stage deployment and its cost/security settings are verified.

## Status

The repository is being built incrementally. The module code, template, deployment workflow, and end-to-end OIDC validation are not yet complete.
