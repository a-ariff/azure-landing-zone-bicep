# Security Policy

## Reporting Security Vulnerabilities

We take security vulnerabilities seriously. If you discover a security vulnerability in this Azure Landing Zone Bicep project, please report it responsibly.

### 🔒 Please DO NOT report security vulnerabilities through public GitHub issues.

Instead, please use one of the following secure channels:

1. **GitHub Security Advisories** (Recommended)
   - Navigate to the [Security Advisories](../../security/advisories/new) section
   - Click "Report a vulnerability"
   - Provide detailed information about the vulnerability

2. **Private Contact** (If available)
   - Contact the maintainers privately if contact information is available

## What to Include in Your Report

To help us understand and address the vulnerability quickly, please include:

- **Description**: Clear description of the vulnerability
- **Impact**: Potential impact and severity assessment  
- **Steps to Reproduce**: Detailed reproduction steps
- **Affected Components**: Which Bicep templates, modules, or configurations are affected
- **Environment**: Azure regions, services, or configurations where applicable
- **Mitigation**: Any temporary workarounds you've identified

## Response Process

1. **Acknowledgment**: We'll acknowledge your report within 48 hours
2. **Investigation**: We'll investigate and assess the vulnerability
3. **Updates**: We'll provide regular updates on our progress
4. **Resolution**: We'll work to resolve the issue and release fixes
5. **Credit**: We'll acknowledge your responsible disclosure (unless you prefer to remain anonymous)

## Supported Versions

We provide security updates for:

- **Current major version**: Full security support
- **Previous major version**: Critical security fixes only

Older versions may not receive security updates. Please upgrade to supported versions.

## Security Best Practices

When using this Azure Landing Zone:

### Deployment Security
- Always review Bicep templates before deployment
- Use least-privilege service principals for deployments
- Deploy to isolated environments first
- Validate all parameter files for sensitive data

### Infrastructure Security  
- Enable Azure Security Center/Microsoft Defender for Cloud
- Configure network security groups appropriately
- Use Azure Key Vault for secrets management
- Enable diagnostic logging and monitoring
- Implement proper RBAC controls

### Operational Security
- Regularly update to latest versions
- Monitor for security advisories
- Follow Azure security best practices
- Implement backup and disaster recovery

## Security Features

This project includes security-focused features:

- Network segmentation with NSGs
- Azure Firewall integration
- Key Vault for secrets management
- Security Center/Defender integration
- Diagnostic logging configuration
- RBAC role assignments

## Additional Resources

- [Azure Security Documentation](https://docs.microsoft.com/azure/security/)
- [Azure Security Center](https://docs.microsoft.com/azure/security-center/)
- [Azure Security Best Practices](https://docs.microsoft.com/azure/security/fundamentals/best-practices-and-patterns)
- [Microsoft Security Response Center](https://msrc.microsoft.com/)

---

**Thank you for helping keep our project and community safe!** 🔒
