# RMMLogging Module Installer
$ModuleName = "RMMLogging"
$GitHubOwner = "Merit-IT"
$GitHubRepo = "RMMLoggingModule"
$GitHubBranch = "main"

Write-Host "Installing $ModuleName from GitHub..." -ForegroundColor Cyan

$Url = "https://raw.githubusercontent.com/$GitHubOwner/$GitHubRepo/$GitHubBranch/RMMLogging.psm1"

Write-Host "Downloading from: $Url" -ForegroundColor Gray

try {
    # Download
    $content = Invoke-WebRequest -Uri $Url -UseBasicParsing -ErrorAction Stop
    Write-Host "Downloaded module ($($content.Content.Length) chars)" -ForegroundColor Green
    
    # Install path
    $InstallPath = "$env:ProgramFiles\WindowsPowerShell\Modules\$ModuleName"
    
    if (-not (Test-Path $InstallPath)) {
        New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
        Write-Host "Created directory: $InstallPath" -ForegroundColor Cyan
    }
    
    # Save
    $ModuleFile = "$InstallPath\$ModuleName.psm1"
    $content.Content | Out-File -FilePath $ModuleFile -Encoding UTF8 -Force
    Write-Host "Saved to: $ModuleFile" -ForegroundColor Green
    
    # Test
    Import-Module $ModuleName -Force
    Write-Host "`nModule installed successfully!" -ForegroundColor Green
    Write-Host "Available commands:" -ForegroundColor Cyan
    Get-Command -Module $ModuleName | ForEach-Object { Write-Host "  - $($_.Name)" }
    
} catch {
    Write-Error "Installation failed: $_"
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
