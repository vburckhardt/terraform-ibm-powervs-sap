<!-- BEGIN MODULE HOOK -->

# SAP on secure Power Virtual Servers Solutions

<!-- UPDATE BADGE: Update the link for the badge below-->
[![Graduated (Supported)](https://img.shields.io/badge/status-Graduated%20(Supported)-brightgreen?style=plastic)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-powervs-sap?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-sap/releases/latest)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)

# Table of Contents
1. [Required IAM access policies](#required-iam-access-policies)
2. [Reference architectures](#reference-architectures)
3. [Solutions](#solutions)

## Required IAM access policies

You need the following permissions to run this module.

- Account Management
    - **Resource Group** service
        - `Viewer` platform access
    - IAM Services
        - **Workspace for Power Systems Virtual Server** service
        - **Power Systems Virtual Server** service
            - `Editor` platform access
        - **VPC Infrastructure Services** service
            - `Editor` platform access
        - **Transit Gateway** service
            - `Editor` platform access
        - **Direct Link** service
            - `Editor` platform access

<!-- END MODULE HOOK -->

## Reference architectures

- [SAP Ready to go PowerVS](reference-architectures/sap-ready-to-go/deploy-arch-ibm-pvs-sap-ready-to-go.md)


## Solutions

| Variation  | Available on IBM Catalog | Requires Schematics Workspace ID | Creates PowerVS HANA Instance | Creates PowerVS NW Instances |  Performs PowerVS OS Config | Performs PowerVS SAP Tuning | Install SAP software |
| ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- |
| [sap-ready-to-go](./solutions/ibm-catalog/sap-ready-to-go/)  | :heavy_check_mark:  | :heavy_check_mark:  | 1  | 0 to N  | :heavy_check_mark:  |  :heavy_check_mark: |   N/A |
| [sap-ready-to-go](./solutions/sap-ready-to-go/)  | N/A  | N/A  | 1  | 0 to N  | :heavy_check_mark:  |  :heavy_check_mark: |   N/A |



<!-- BEGIN CONTRIBUTING HOOK -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
<!-- END CONTRIBUTING HOOK -->

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

No requirements.

### Modules

No modules.

### Resources

No resources.

### Inputs

No inputs.

### Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
