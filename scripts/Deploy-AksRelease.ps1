#Requires -Version 7.2
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Context,
    [Parameter(Mandatory)][string]$Namespace
)

$ErrorActionPreference = 'Stop'
$manifest = Join-Path $PSScriptRoot '../k8s/deployment.yaml'

$target = @{
    Context   = $Context
    Namespace = $Namespace
}

& "$PSScriptRoot/Test-AksPreflight.ps1" @target -Manifest $manifest

kubectl --context $Context --namespace $Namespace apply -f $manifest
if ($LASTEXITCODE -ne 0) {
    throw "Could not apply the Kubernetes manifest to '$Context/$Namespace'."
}

& "$PSScriptRoot/Test-AksRelease.ps1" @target