#Requires -Version 7.2
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Context,
    [Parameter(Mandatory)][string]$Namespace,
    [string]$Deployment = 'aks-demo',
    [string]$Selector = 'app=aks-demo',
    [string]$OutputDirectory = './artifacts/aks-diagnostics'
)

$ErrorActionPreference = 'Stop'
$target = @('--context', $Context, '--namespace', $Namespace)
New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null

$checks = @(
    @{
        File = 'deployment.txt'
        Args = @('describe', "deployment/$Deployment")
    }
    @{
        File = 'replicasets.txt'
        Args = @('get', 'replicasets', '--selector', $Selector, '--output', 'wide')
    }
    @{
        File = 'pods.txt'
        Args = @('describe', 'pods', '--selector', $Selector)
    }
    @{
        File = 'events.txt'
        Args = @('get', 'events', '--sort-by=.metadata.creationTimestamp')
    }
    @{
        File = 'logs.txt'
        Args = @('logs', '--selector', $Selector, '--all-containers=true',
                 '--prefix=true', '--tail=100', '--max-log-requests=5')
    }
)

foreach ($check in $checks) {
    $kubectlArgs = $check.Args
    $output = kubectl @target --request-timeout=20s @kubectlArgs 2>&1
    $exitCode = $LASTEXITCODE

    $output | Out-File -FilePath (Join-Path $OutputDirectory $check.File)
    if ($exitCode -ne 0) {
        Write-Warning "Could not fully collect $($check.File). See the file for details."
    }
}

Write-Host "Diagnostics saved to $OutputDirectory."