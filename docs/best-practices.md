# Best Practices

## Bicep Template Design
- Structure modules for repeatability and reusability.
- Prefer parameters for values that change per environment.
- Use outputs to pass values between modules.
- Reference parameter and variable files—avoid hardcoding secrets or sensitive info.

## Naming & Tagging
- Adopt a universal naming convention (e.g., `az-<env>-<resourceType>-<appName>`).
- Apply tags for environment, owner, cost center, and compliance.

## Security & Governance
- Assign least-privilege RBAC roles using Azure AD groups.
- Deploy built-in or custom Azure Policy assignments for compliance.
- Enable resource locks on key infrastructure.
- Integrate with Azure Key Vault for secrets and certificates.

## Networking
- Use hub-and-spoke VNet design with peering.
- Secure management and shared resources in the hub.
- Define NSG rules strictly (deny all by default, allow only needed traffic).

## Scalability
- Use modules for workloads that may need to scale horizontally.
- Parameterize size and SKU for compute/storage/network resources.
- Leverage Azure Monitor and Log Analytics for central monitoring.

## Automation & Testing
- Leverage CI/CD pipelines for deployment (GitHub Actions, Azure DevOps).
- Test deployments in dev or sandbox environment before deploying to prod.
- Use `what-if` for dry runs and plan validation.

## Documentation
- Comment templates with purpose, input/output, and examples.
- Maintain clear documentation for onboarding and support.

For more guidance, see the Microsoft Cloud Adoption Framework and Well-Architected Framework.
