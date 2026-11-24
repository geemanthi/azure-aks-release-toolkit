#Requires -Version 7.2
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Context,
    [Parameter(Mandatory)][string]$Namespace,
    [string]$Deployment = 'aks-demo',
    [string]$Selector = 'app=aks-demo',
    [ValidateRange(1, 600)][int]$TimeoutSeconds = 120,
    [uri]$HealthUrl,
    [string]$OutputDirectory = './artifacts/aks-diagnostics'
)

$ErrorActionPreference = 'Stop'
$target = @('--context', $Context, '--namespace', $Namespace)

try {
    kubectl @target rollout status "deployment/$Deployment" --timeout="${TimeoutSeconds}s"
    if ($LASTEXITCODE -ne 0) {
        throw "Deployment '$Deployment' did not complete its rollout."
    }

    if ($HealthUrl) {
        $response = Invoke-WebRequest -Uri $HealthUrl -TimeoutSec 15

        if ($response.StatusCode -lt 200 -or $response.StatusCode -ge 300) {
            throw "Smoke test returned HTTP $($response.StatusCode)."
        }

        Write-Host "Smoke test passed with HTTP $($response.StatusCode)."
    }

    Write-Host "Release verification passed for '$Deployment'."
}
catch {
    $releaseError = $_
    try {
        & "$PSScriptRoot/Get-AksDiagnostics.ps1" `
            -Context $Context -Namespace $Namespace -Deployment $Deployment `
            -Selector $Selector -OutputDirectory $OutputDirectory
    }
    catch {
        Write-Warning "Diagnostics collection failed: $($_.Exception.Message)"
    }

    throw $releaseError
}