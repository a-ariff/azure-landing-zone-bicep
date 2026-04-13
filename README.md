Azure Landing Zone Bicep

[Azure] [Bicep] [License: MIT] [CI/CD]

Enterprise-ready Azure Landing Zone built entirely in Bicep. Implements hub-and-spoke networking with an optional Azure Virtual WAN path, Azure Firewall with IDPS, VPN Gateway, Bastion, Key Vault, and centralised monitoring through Log Analytics and Sentinel.

Table of Contents

- Architecture
- What is in this repo
- Features
- Prerequisites
- Quick start
- Module reference
- CI/CD pipeline
- Contributing

Architecture

Two topology options are provided. Choose hub-and-spoke for smaller environments where you need full control, or vWAN when you have 30+ branch sites and want Microsoft-managed routing.

    Hub-and-Spoke topology
    ======================

        On-Premises
            |
        [VPN Gateway]
            |
      +-----+-----+
      |  Hub VNet  |
      |  10.0.0.0  |
      |            |
      | +--------+ |      +------------------+
      | |  Azure | |      |   Spoke VNet A   |
      | |Firewall|--------| App / DB / Mgmt  |
      | +--------+ |      +------------------+
      |            |
      | +--------+ |      +------------------+
      | | Bastion| |      |   Spoke VNet B   |
      | +--------+ |------| App / DB / Mgmt  |
      +-----+-----+      +------------------+
            |
      [Log Analytics + Sentinel]


    Virtual WAN topology
    ====================

        Branch 1 ---+
        Branch 2 ---+--- [vWAN VPN Gateway] --- Virtual Hub --- Spoke VNets
        Branch N ---+          |
                         [Route Tables]

What is in this repo

    azure-landing-zone-bicep/
      bicep/
        main.bicep                              -- orchestrator (subscription scope)
        core/
          networking/
            hub-vnet.bicep                      -- hub VNet, Firewall, VPN GW, Bastion
            spoke-vnet.bicep                    -- spoke VNet, peering, NSGs, diagnostics
            vwan.bicep                          -- Virtual WAN, Virtual Hub, VPN
          security/
            azure-firewall.bicep                -- standalone Firewall with IDPS + rules
            key-vault.bicep                     -- Key Vault, RBAC, private endpoint
          monitoring/
            log-analytics.bicep                 -- Log Analytics, Sentinel, VMInsights
      parameters/
        dev/main.bicepparam                     -- development environment values
        prod/main.bicepparam                    -- production environment values
      scripts/
        deploy.sh                               -- interactive deployment helper
      .github/
        workflows/
          deploy.yml                            -- GitHub Actions CI/CD pipeline
      docs/                                     -- architecture and deployment guides

Features

- Azure Virtual WAN support – full vWAN module alongside traditional hub-and-spoke
- Azure Firewall with IDPS – Premium SKU with intrusion detection in Deny mode, application and network rule collections, DNS proxy
- Bicep native – no ARM JSON, no Terraform; pure Bicep with .bicepparam files
- GitHub Actions CI/CD – lint, build, what-if on PRs, auto-deploy dev on merge, manual production deploy with environment protection
- Modular design – each resource type is an independent module you can compose or deploy standalone
- Multi-environment – parameterised for dev, staging, and production with sensible defaults per tier
- Security first – Key Vault with RBAC and purge protection, NSGs with deny-all baseline, network ACLs with default deny
- Observability – Log Analytics with Sentinel, VMInsights, and diagnostic settings wired through every module

Prerequisites

  --------------------------------------------------------------------------------------------------------------------------
  Tool                 Minimum version                                    Install
  -------------------- -------------------------------------------------- --------------------------------------------------
  Azure CLI            2.50.0                                             brew install azure-cli or aka.ms/installazurecli

  Bicep CLI            0.22.0                                             az bicep install

  Azure subscription   Owner or Contributor + User Access Administrator   

  PowerShell or Bash   7.0+ / 5.0+                                        
  --------------------------------------------------------------------------------------------------------------------------

Quick start

    # clone
    git clone https://github.com/a-ariff/azure-landing-zone-bicep.git
    cd azure-landing-zone-bicep

    # login and select subscription
    az login
    az account set --subscription "<subscription-id>"

    # deploy to dev
    az deployment sub create \
      --location australiaeast \
      --template-file bicep/main.bicep \
      --parameters parameters/dev/main.bicepparam

    # or use the helper script
    chmod +x scripts/deploy.sh
    ./scripts/deploy.sh dev

Module reference

  --------------------------------------------------------------------------------------------------------------------
  Module                                      Scope             Description
  ------------------------------------------- ----------------- ------------------------------------------------------
  bicep/main.bicep                            subscription      Creates resource groups, calls all modules in order

  bicep/core/networking/hub-vnet.bicep        resourceGroup     Hub VNet with Azure Firewall, VPN Gateway, Bastion

  bicep/core/networking/spoke-vnet.bicep      resourceGroup     Spoke VNet with NSGs, peering to hub, diagnostics

  bicep/core/networking/vwan.bicep            resourceGroup     Virtual WAN, Virtual Hub, VPN Gateway, VPN Site

  bicep/core/security/azure-firewall.bicep    resourceGroup     Standalone Firewall with IDPS, app and network rules

  bicep/core/security/key-vault.bicep         resourceGroup     Key Vault with RBAC, private endpoint, diagnostics

  bicep/core/monitoring/log-analytics.bicep   resourceGroup     Log Analytics, Sentinel, VMInsights, Security
  --------------------------------------------------------------------------------------------------------------------

CI/CD pipeline

The GitHub Actions workflow (.github/workflows/deploy.yml) runs on every push and PR that touches bicep/** or parameters/**.

  ---------------------------------------------------------------------------------------------------
  Job           Trigger                 What it does
  ------------- ----------------------- -------------------------------------------------------------
  validate      push, PR                Bicep lint, build, what-if; comments what-if results on PRs

  deploy-dev    push to main            Deploys to the dev environment automatically

  deploy-prod   manual dispatch         Requires environment protection approval before deploying
  ---------------------------------------------------------------------------------------------------

Authentication uses OIDC federated credentials (no secrets stored). Configure AZURE_SUBSCRIPTION_ID, AZURE_TENANT_ID, and AZURE_CLIENT_ID as repository secrets.

Contributing

1.  Fork the repository
2.  Create a feature branch
3.  Make changes and verify with az bicep build --file bicep/main.bicep
4.  Open a pull request – the workflow will validate and post what-if results

License

MIT – see LICENSE for details.

Back to top
