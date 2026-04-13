#!/usr/bin/env bash
# deploy.sh - Azure Landing Zone deployment script
#
# Usage:
#   ./scripts/deploy.sh <environment>
#
# Arguments:
#   environment   Target environment: dev, staging, or prod
#
# Examples:
#   ./scripts/deploy.sh dev
#   ./scripts/deploy.sh prod
#
# Prerequisites:
#   - Azure CLI >= 2.50.0
#   - Bicep CLI >= 0.22.0
#   - Logged in to Azure (az login)
#   - Subscription selected (az account set)

set -euo pipefail

# ---------------------------------------------------------------------------
# Colours
# ---------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No colour

info()    { echo -e "${BLUE}[INFO]${NC}  $*"; }
success() { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# ---------------------------------------------------------------------------
# Validate arguments
# ---------------------------------------------------------------------------
ENVIRONMENT="${1:-}"

if [[ -z "$ENVIRONMENT" ]]; then
    error "Usage: $0 <environment>"
    error "Environments: dev, staging, prod"
    exit 1
fi

if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|prod)$ ]]; then
    error "Invalid environment: $ENVIRONMENT"
    error "Valid values: dev, staging, prod"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATE_FILE="$REPO_ROOT/bicep/main.bicep"
PARAMS_FILE="$REPO_ROOT/parameters/$ENVIRONMENT/main.bicepparam"
LOCATION="australiaeast"
DEPLOYMENT_NAME="lz-${ENVIRONMENT}-$(date +%Y%m%d%H%M%S)"

# ---------------------------------------------------------------------------
# Prerequisites check
# ---------------------------------------------------------------------------
info "Checking prerequisites..."

# Azure CLI
if ! command -v az &>/dev/null; then
    error "Azure CLI is not installed. Install from https://aka.ms/installazurecli"
    exit 1
fi

AZ_VERSION=$(az version --query '"azure-cli"' -o tsv 2>/dev/null)
info "Azure CLI version: $AZ_VERSION"

# Bicep
BICEP_VERSION=$(az bicep version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
if [[ -z "$BICEP_VERSION" ]]; then
    warn "Bicep CLI not found, installing..."
    az bicep install
    BICEP_VERSION=$(az bicep version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
fi
info "Bicep CLI version: $BICEP_VERSION"

# Logged in
ACCOUNT=$(az account show --query 'name' -o tsv 2>/dev/null) || {
    error "Not logged in to Azure. Run: az login"
    exit 1
}
info "Azure subscription: $ACCOUNT"

# Parameter file exists
if [[ ! -f "$PARAMS_FILE" ]]; then
    error "Parameter file not found: $PARAMS_FILE"
    exit 1
fi
success "All prerequisites met"

# ---------------------------------------------------------------------------
# Build / validate
# ---------------------------------------------------------------------------
info "Building Bicep template..."
az bicep build --file "$TEMPLATE_FILE" --stdout >/dev/null
success "Bicep build succeeded"

# ---------------------------------------------------------------------------
# What-if preview
# ---------------------------------------------------------------------------
info "Running what-if preview for $ENVIRONMENT..."
az deployment sub what-if \
    --location "$LOCATION" \
    --template-file "$TEMPLATE_FILE" \
    --parameters "$PARAMS_FILE" || true

echo ""
if [[ "$ENVIRONMENT" == "prod" ]]; then
    warn "PRODUCTION deployment - review the what-if output above."
    read -r -p "Continue with deployment? (y/N): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        info "Deployment cancelled."
        exit 0
    fi
fi

# ---------------------------------------------------------------------------
# Deploy
# ---------------------------------------------------------------------------
info "Deploying landing zone ($ENVIRONMENT)..."
info "Deployment name: $DEPLOYMENT_NAME"

az deployment sub create \
    --name "$DEPLOYMENT_NAME" \
    --location "$LOCATION" \
    --template-file "$TEMPLATE_FILE" \
    --parameters "$PARAMS_FILE" \
    --verbose

success "Landing zone deployed successfully to $ENVIRONMENT"
info "Deployment name: $DEPLOYMENT_NAME"
info "View in portal: https://portal.azure.com/#view/HubsExtension/DeploymentDetailsBlade/~/overview/id/%2Fsubscriptions%2F{sub-id}%2Fproviders%2FMicrosoft.Resources%2Fdeployments%2F$DEPLOYMENT_NAME"
