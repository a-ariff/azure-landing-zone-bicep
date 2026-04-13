using '../../bicep/main.bicep'

param environment = 'prod'
param location = 'australiaeast'
param prefix = 'ariff-lz'
param tags = {
  Environment: 'Production'
  Owner: 'CloudOps'
  CostCentre: 'IT'
  ManagedBy: 'Bicep'
  Compliance: 'Required'
}
