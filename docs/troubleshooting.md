# Troubleshooting Guide

This document provides solutions to common issues encountered when working with Azure Landing Zone Bicep templates.

## Deployment Issues

### Template Validation Errors

#### Problem
Bicep templates fail validation during deployment.

#### Solution
1. Check syntax using Azure CLI:
   ```bash
   az bicep build --file main.bicep
   ```
2. Validate parameter files format
3. Ensure all required parameters are provided

### Resource Naming Conflicts

#### Problem
Deployment fails due to existing resource names.

#### Solution
- Use unique naming conventions with prefixes/suffixes
- Check Azure resource naming rules and restrictions
- Implement name uniqueness functions in templates

### Permission Errors

#### Problem
Insufficient permissions to create resources.

#### Solution
- Verify service principal has required permissions
- Check subscription-level and resource group-level access
- Ensure custom roles have necessary actions

## Networking Issues

### Connectivity Problems

#### Problem
Resources cannot communicate across virtual networks.

#### Solution
1. Verify VNet peering configuration
2. Check Network Security Group rules
3. Validate route table configurations
4. Ensure DNS resolution is working

### Firewall Rules

#### Problem
Azure Firewall blocking legitimate traffic.

#### Solution
- Review firewall rules and priorities
- Check application rules vs network rules
- Validate FQDN filtering configuration
- Monitor firewall logs for blocked traffic

## Authentication Issues

### Service Principal Problems

#### Problem
Authentication failures during automated deployments.

#### Solution
1. Verify service principal credentials
2. Check certificate/secret expiration
3. Validate role assignments
4. Ensure proper scope assignments

### Key Vault Access

#### Problem
Cannot retrieve secrets from Key Vault.

#### Solution
- Check Key Vault access policies
- Verify managed identity permissions
- Ensure firewall and virtual network rules allow access
- Validate secret names and versions

## Performance Issues

### Slow Deployment Times

#### Problem
Templates take too long to deploy.

#### Solution
- Use parallel deployment where possible
- Optimize template dependencies
- Consider breaking large templates into modules
- Use copy loops efficiently

### Resource Sizing

#### Problem
Resources are over or under-provisioned.

#### Solution
- Monitor resource utilization metrics
- Implement auto-scaling policies
- Right-size based on workload requirements
- Use Azure Advisor recommendations

## Common Error Messages

### "Resource not found"
- Check resource names and case sensitivity
- Verify resource exists in correct subscription/resource group
- Ensure dependencies are properly defined

### "Quota exceeded"
- Check subscription quotas and limits
- Request quota increases if needed
- Consider alternative resource configurations

### "Location not supported"
- Verify resource provider registration
- Check if service is available in target region
- Consider alternative locations

## Getting Help

- Review Azure documentation and best practices
- Check GitHub issues and community forums
- Use Azure Support for complex issues
- Monitor Azure Service Health for service disruptions
