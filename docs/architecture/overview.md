# Architecture Overview

This solution implements the Azure Landing Zone using Bicep (Infrastructure-as-Code) following Microsoft's Cloud Adoption Framework (CAF).

## Core Concepts
- **Modular Infrastructure**: All components are organized as reusable Bicep modules.
- **Governance**: Built-in Azure Policy, management groups, RBAC, tags, and security baselines.
- **Network Topology**: Hub-and-spoke pattern for secure and scalable connectivity.
- **Resource Segregation**: Segregation of workloads by environment (dev, staging, prod), and resource group.

## Major Components
- **Networking**: Hub VNets, Spoke VNets, subnets, NSGs, Azure Firewall, Bastion.
- **Identity & Security**: Azure AD integration, RBAC, PIM, Key Vault, policy assignments.
- **Management**: Log Analytics, Azure Monitor, Automation Accounts.
- **Policy & Compliance**: Policy initiatives for cost, security, audit, and tagging standards.

## Example Reference Architecture
```
Hub VNet
  |__ Azure Firewall
  |__ Bastion
  |__ Shared Services
  |
  |-- Spoke VNet(s)
        |__ Subnet(s)
        |__ App Services, VMs
```

## More
For a detailed diagram, see `/docs/architecture/diagram.png` (add your PNG here if you have one).
