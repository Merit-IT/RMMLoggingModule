# Simple installer - no version management
$ModuleName = "RMMLogging"
$GitHubOwner = "Merit-IT"
$GitHubRepo = "RMMLoggingModule"
$GitHubBranch = "main"

Write-Host "Installing $ModuleName..." -ForegroundColor Cyan

# Download URL
$Url = "https://raw.githubusercontent.com/$GitHubOwner/$GitHubRepo/$GitHubBranch/RMMLogging.psm1"

try {
    # Create module directory
    $InstallPath = Join-Path $env:ProgramFiles "WindowsPowerShell\Modules\$ModuleName"
    
    if (-not (Test-Path $InstallPath)) {
        New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
    }
    
    # Download and save
    Write-Host "Downloading from GitHub..." -ForegroundColor Cyan
    $content = (New-Object Net.WebClient).DownloadString($Url)
    
    $ModuleFile = Join-Path $InstallPath "$ModuleName.psm1"
    $content | Out-File -FilePath $ModuleFile -Encoding UTF8 -Force
    
    Write-Host "✓ Installed to: $InstallPath" -ForegroundColor Green
    
    # Test
    Import-Module $ModuleName -Force
    Write-Host "✓ Module loaded!" -ForegroundColor Green
    Get-Command -Module $ModuleName
    
} catch {
    Write-Error "Installation failed: $_"
    exit 1
}