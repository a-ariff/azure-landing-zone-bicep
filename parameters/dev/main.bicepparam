using '../../bicep/main.bicep'

param environment = 'dev'
param location = 'australiaeast'
param prefix = 'ariff-lz'
param tags = {
  Environment: 'Development'
  Owner: 'CloudOps'
  CostCentre: 'IT'
  ManagedBy: 'Bicep'
}
