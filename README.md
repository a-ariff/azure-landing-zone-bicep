# Azure Landing Zone Bicep

[![Azure](https://img.shields.io/badge/Azure-0078D4?style=for-the-badge&logo=microsoft-azure&logoColor=white)](https://azure.microsoft.com/)
[![Bicep](https://img.shields.io/badge/Bicep-0078D4?style=for-the-badge&logo=azure-devops&logoColor=white)](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

## Overview

A comprehensive Azure Landing Zone implementation using Bicep Infrastructure as Code (IaC) templates. This repository provides enterprise-ready, scalable cloud architecture patterns following Microsoft's Cloud Adoption Framework (CAF) and Well-Architected Framework principles.

### Key Features

- **Enterprise-Scale Architecture**: Modular Bicep templates for scalable cloud infrastructure
- **Governance & Compliance**: Built-in Azure Policy assignments and security configurations
- **Multi-Environment Support**: Parameterized templates for dev, staging, and production environments
- **Network Segmentation**: Hub-and-spoke network topology with secure connectivity patterns
- **Identity & Access Management**: Azure AD integration with RBAC and Conditional Access policies
- **Monitoring & Logging**: Centralized logging with Azure Monitor and Log Analytics

## Repository Structure

```
azure-landing-zone-bicep/
├── bicep/
│   ├── core/
│   │   ├── networking/
│   │   │   ├── hub-vnet.bicep
│   │   │   ├── spoke-vnet.bicep
│   │   │   └── peering.bicep
│   │   ├── security/
│   │   │   ├── key-vault.bicep
│   │   │   ├── nsg-rules.bicep
│   │   │   └── azure-firewall.bicep
│   │   ├── compute/
│   │   │   ├── vm-windows.bicep
│   │   │   ├── vm-linux.bicep
│   │   │   └── app-service.bicep
│   │   └── storage/
│   │       ├── storage-account.bicep
│   │       └── blob-containers.bicep
│   ├── modules/
│   │   ├── logging/
│   │   ├── monitoring/
│   │   └── backup/
│   └── main.bicep
├── parameters/
│   ├── dev/
│   ├── staging/
│   └── production/
├── policies/
│   ├── governance/
│   ├── security/
│   └── compliance/
├── scripts/
│   ├── deployment/
│   ├── validation/
│   └── cleanup/
├── docs/
│   ├── architecture/
│   ├── deployment-guide.md
│   └── best-practices.md
├── .github/
│   └── workflows/
└── README.md
```

## Quick Start

### Prerequisites

- Azure CLI 2.40.0 or later
- Bicep CLI 0.12.0 or later
- Azure subscription with Owner or Contributor permissions
- PowerShell 7.0+ or Bash

### Deployment

1. **Clone the repository**
   ```bash
   git clone https://github.com/a-ariff/azure-landing-zone-bicep.git
   cd azure-landing-zone-bicep
   ```

2. **Configure parameters**
   ```bash
   # Copy and modify parameter files
   cp parameters/dev/main.parameters.json.example parameters/dev/main.parameters.json
   ```

3. **Deploy the landing zone**
   ```bash
   # Deploy to development environment
   az deployment sub create \
     --location eastus \
     --template-file bicep/main.bicep \
     --parameters @parameters/dev/main.parameters.json
   ```

## Architecture Components

### Networking
- Hub and spoke network topology
- Azure Firewall for centralized security
- Network Security Groups (NSGs) with standardized rules
- Azure Bastion for secure remote access

### Security
- Azure Key Vault for secrets management
- Azure Security Center integration
- Just-in-Time (JIT) VM access
- Azure Sentinel for security monitoring

### Governance
- Azure Policy for compliance enforcement
- Resource tagging standards
- Cost management and budgeting
- Azure Blueprints for repeatable deployments

## Contributing

Contributions are welcome! Please read our [Contributing Guidelines](CONTRIBUTING.md) and [Code of Conduct](CODE_OF_CONDUCT.md) before submitting pull requests.

## Documentation

- [Architecture Overview](docs/architecture/overview.md)
- [Deployment Guide](docs/deployment-guide.md)
- [Best Practices](docs/best-practices.md)
- [Troubleshooting](docs/troubleshooting.md)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For questions and support:
- Create an [issue](https://github.com/a-ariff/azure-landing-zone-bicep/issues)
- Check the [documentation](docs/)
- Review [Azure Landing Zone documentation](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/)

## Tags

`azure` `bicep` `infrastructure-as-code` `landing-zone` `cloud-adoption-framework` `enterprise-scale` `governance` `security` `networking` `devops`
