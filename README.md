# TerraformDeployments

Terraform configuration for this project's single Azure `stage` deployment. The configuration composes reusable modules maintained in separate GitHub repositories.

When applied, the deployment creates:

- An Azure virtual network and subnet.
- A Linux virtual machine connected to that subnet.
- A public IP address and a network security group (NSG).
- Apache installed on the VM and configured to serve a simple "Hello" page.

This repository is the deployment repository. It will consume versioned modules; it will not contain their implementation.

## Repository architecture

The project is split into four repositories:

| Repository | Responsibility |
| --- | --- |
| `TerraformDeployments` | The real `stage` deployment configuration for this project. |
| [`terraform-module-azurerm-network`](https://github.com/Terraformcristianrdgzzz/terraform-module-azurerm-network) | Reusable Azure network module. |
| [`terraform-module-azurerm-linux-webserver`](https://github.com/Terraformcristianrdgzzz/terraform-module-azurerm-linux-webserver) | Reusable Linux VM, public IP, NSG, and Apache example module. |
| [`terraform-azure-deployment-template`](https://github.com/Terraformcristianrdgzzz/terraform-azure-deployment-template) | Reusable GitHub template that composes the two modules for new projects. |

The GitHub template is a starting point for creating new deployment repositories. It copies its files when a new repository is created; it is not a runtime dependency of this deployment. Terraform downloads the modules directly from their repositories.

## Repository layout

```text
.
├── .github/
│   └── workflows/
└── live/
    └── stage/
        └── webserver/
```

The `stage` directory is the only deployment in this repository. It has its own remote Terraform state and calls the same reusable modules that the template uses.

## Module versioning

Deployment configurations reference explicit module versions (Git tags), rather than a moving branch. `stage` currently pins network `v0.2.0` and web server `v0.2.1`:

```hcl
module "network" {
  source = "git::https://github.com/Terraformcristianrdgzzz/terraform-module-azurerm-network.git?ref=v0.2.0"
}

module "webserver" {
  source = "git::https://github.com/Terraformcristianrdgzzz/terraform-module-azurerm-linux-webserver.git?ref=v0.2.1"
}
```

The web server module's `v0.2.1` uses the Ubuntu 22.04 Gen2 image compatible with `Standard_D2s_v7`. Consumers should keep module references pinned to published tags.

## Azure and GitHub authentication

GitHub Actions authenticates to Azure using Microsoft Entra workload identity federation (OIDC), without a long-lived Azure client secret. The manually triggered `Terraform Stage Plan` workflow runs formatting, initialization, and validation; it can optionally create a plan and never applies it.

The optional VM plan requires `ADMIN_SSH_PUBLIC_KEY` in the GitHub `stage` environment. It is the VM administrator's public key, not a private key, and is only passed into the VM configuration; the NSG does not allow SSH ingress by default. The workflow also expects `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, and `AZURE_SUBSCRIPTION_ID` environment variables for the existing federated identity.

`Terraform Stage Apply` and `Terraform Stage Destroy` are also manually triggered workflows. Apply requires the `APPLY` confirmation, displays and stores a plan, then automatically applies that same plan. Destroy requires `DESTROY STAGE`, displays and stores a destroy plan, then automatically applies it. Neither workflow pauses for a separate plan review between those jobs unless GitHub Environment protection is configured. Do not start either workflow unless you intend to perform the corresponding Azure operation.

The stage identity has been used to manage resources in the stage resource group and access the state container. The template's users must configure their own GitHub Environment, OIDC trust, state backend, and appropriately scoped Azure roles.

The stage AzureRM provider disables automatic subscription-wide resource provider registration. Before planning or applying, an administrator must ensure `Microsoft.Network` and `Microsoft.Compute` are registered in the subscription. OIDC sign-in, remote state access, and the permissions required for the successful stage deployment have been verified.

## Cost and security notes

- A public IP and a running VM may incur charges. Check the Azure offer's remaining free allowance and the pricing estimate for the selected VM size, disk, region, IP, and network usage before deployment.
- The NSG should allow HTTP only as required for the demo. If SSH is enabled, restrict it to a trusted source IP; do not expose SSH to the entire internet.
- Terraform state and plan files can contain sensitive values. Store state in a private Azure Blob container and restrict access with Azure RBAC.
- Do not commit credentials, Terraform state, plan files, or local variable files containing sensitive values.
- A VM that is no longer needed should be deallocated or removed, and its related billable resources reviewed.

## Deployment status

- The `stage` configuration composes the pinned network and web server modules in `live/stage/webserver`.
- Terraform state is configured to use the Azure Blob backend with OIDC and Azure AD authentication.
- The Apply workflow successfully created the stage VM and the Destroy workflow subsequently completed successfully. Check the latest workflow run before assuming the Azure resource group is empty.
- The workflows remain manually runnable: starting `Terraform Stage Apply` with the required confirmation can recreate the resources.
- `stage` is the only real deployment; no `prod` environment is planned.
- The reusable template is published separately in [`terraform-azure-deployment-template`](https://github.com/Terraformcristianrdgzzz/terraform-azure-deployment-template).
