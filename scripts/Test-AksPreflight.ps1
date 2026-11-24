#Requires -Version 7.2
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Context,
    [Parameter(Mandatory)][string]$Namespace,
    [string]$Manifest = (Join-Path $PSScriptRoot '../k8s/deployment.yaml')
)

$ErrorActionPreference = 'Stop'

$target = @('--context', $Context, '--namespace', $Namespace)
$requiredAccess = @(
    @{ Verb = 'get'; Resource = 'deployments.apps' }
    @{ Verb = 'watch'; Resource = 'deployments.apps' }
    @{ Verb = 'list'; Resource = 'deployments.apps' }
    @{ Verb = 'list'; Resource = 'pods' }
    @{ Verb = 'get'; Resource = 'pods/log' }
    @{ Verb = 'list'; Resource = 'events' }
)

foreach ($permission in $requiredAccess) {
    kubectl @target auth can-i $permission.Verb $permission.Resource --quiet
    if ($LASTEXITCODE -ne 0) {
        throw "Access check failed: $($permission.Verb) $($permission.Resource) in '$Namespace'."
    }
}

kubectl @target apply --dry-run=server --filename $Manifest
if ($LASTEXITCODE -ne 0) {
    throw "The API server rejected the proposed deployment in '$Namespace'."
}

Write-Host "Preflight passed for '$Context/$Namespace'."