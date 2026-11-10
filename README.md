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
| [`terraform-module-azurerm-network`](https://github.com/Terraformcristianrdgzzz/terraform-module-azurerm-network) | Reusable Azure network module. |
| [`terraform-module-azurerm-linux-webserver`](https://github.com/Terraformcristianrdgzzz/terraform-module-azurerm-linux-webserver) | Reusable Linux VM, public IP, NSG, and Apache example module. |
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

Deployment configurations reference explicit module versions (Git tags), rather than a moving branch. Both modules currently publish `v0.1.0`:

```hcl
module "network" {
  source = "git::https://github.com/Terraformcristianrdgzzz/terraform-module-azurerm-network.git?ref=v0.1.0"
}
```

The stage deployment also pins the web server module to its `v0.1.0` tag.

## Azure and GitHub authentication

GitHub Actions authenticates to Azure using Microsoft Entra workload identity federation (OIDC), without a long-lived Azure client secret. The manually triggered `Terraform Stage Plan` workflow always runs formatting, initialization, and validation; initialization checks remote backend access. Creating a VM plan is an optional manual input and does not apply changes.

The optional VM plan requires `ADMIN_SSH_PUBLIC_KEY` in the GitHub `stage` environment. It is the VM administrator's public key, not a private key, and is only passed into the VM configuration; the NSG does not allow SSH ingress by default. The workflow also expects `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, and `AZURE_SUBSCRIPTION_ID` environment variables for the existing federated identity.

The stage identity should receive only the permissions required for the resources it manages, scoped to the stage resource group and the state container. Production should use a separate GitHub Environment and an appropriately scoped identity and permissions before production deployment is enabled.

The Azure subscription, resource groups, app registration, federated credential, and some role assignments have been configured manually for learning. OIDC sign-in has been tested. Remote state access and the identity's permissions to plan and create the configured resources still need verification before deployment.

## Cost and security notes

- A public IP and a running VM may incur charges. Check the Azure offer's remaining free allowance and the pricing estimate for the selected VM size, disk, region, IP, and network usage before deployment.
- The NSG should allow HTTP only as required for the demo. If SSH is enabled, restrict it to a trusted source IP; do not expose SSH to the entire internet.
- Terraform state and plan files can contain sensitive values. Store state in a private Azure Blob container and restrict access with Azure RBAC.
- Do not commit credentials, Terraform state, plan files, or local variable files containing sensitive values.
- A VM that is no longer needed should be deallocated or removed, and its related billable resources reviewed.

## Deployment status

- The `stage` configuration composes the pinned network and web server modules in `live/stage/webserver`.
- Terraform state is configured to use the Azure Blob backend with OIDC and Azure AD authentication.
- The workflow only creates a plan; it does not deploy infrastructure.
- Verify remote backend access, Azure RBAC permissions, and VM size availability/cost before considering an apply.
- Production and the GitHub template are not yet implemented.
