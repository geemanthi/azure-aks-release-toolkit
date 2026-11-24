#Requires -Version 7.2
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)][string]$Context,
    [Parameter(Mandatory)][string]$Namespace,
    [Parameter(Mandatory)][ValidateRange(1, 2147483647)][int]$Revision,
    [string]$Deployment = 'aks-demo',
    [string]$Selector = 'app=aks-demo',
    [uri]$HealthUrl
)

$ErrorActionPreference = 'Stop'
$target = @('--context', $Context, '--namespace', $Namespace)

if ($PSCmdlet.ShouldProcess("$Context/$Namespace/$Deployment", "Roll back to revision $Revision")) {
    kubectl @target rollout undo "deployment/$Deployment" --to-revision=$Revision
    if ($LASTEXITCODE -ne 0) {
        throw "Could not roll back '$Deployment' to revision $Revision."
    }

    $verify = @{
        Context = $Context
        Namespace = $Namespace
        Deployment = $Deployment
        Selector = $Selector
    }
    if ($HealthUrl) {
        $verify.HealthUrl = $HealthUrl
    }

    & "$PSScriptRoot/Test-AksRelease.ps1" @verify
}