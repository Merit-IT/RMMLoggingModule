# RMMLogging Module Installer
$ModuleName = "RMMLogging"
$GitHubOwner = "Merit-IT"
$GitHubRepo = "RMMLoggingModule"
$GitHubBranch = "main"

Write-Host "=== $ModuleName Installer ===" -ForegroundColor Cyan

# URLs
$BaseUrl = "https://raw.githubusercontent.com/$GitHubOwner/$GitHubRepo/$GitHubBranch"
$ManifestUrl = "$BaseUrl/$ModuleName.psd1"
$ModuleUrl = "$BaseUrl/$ModuleName.psm1"

try {
    # Download manifest to get version
    Write-Host "Checking latest version..." -ForegroundColor Cyan
    $manifestContent = Invoke-WebRequest -Uri $ManifestUrl -UseBasicParsing -ErrorAction Stop
    
    $tempPath = "$env:TEMP\$ModuleName.psd1"
    $manifestContent.Content | Out-File -FilePath $tempPath -Encoding UTF8 -Force
    
    $manifest = Import-PowerShellDataFile -Path $tempPath
    $NewVersion = $manifest.ModuleVersion
    
    Write-Host "Latest version: $NewVersion" -ForegroundColor Green
    
    # Check existing installation
    $existingModule = Get-Module -Name $ModuleName -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1
    
    if ($existingModule) {
        Write-Host "Installed version: $($existingModule.Version)" -ForegroundColor Yellow
        
        if ([version]$NewVersion -le [version]$existingModule.Version) {
            Write-Host "`nModule is already up to date (v$($existingModule.Version))" -ForegroundColor Green
            exit 0
        } else {
            Write-Host "Upgrading from v$($existingModule.Version) to v$NewVersion" -ForegroundColor Cyan
        }
    } else {
        Write-Host "Installing v$NewVersion (new installation)" -ForegroundColor Cyan
    }
    
    # Create versioned directory
    $InstallPath = "$env:ProgramFiles\WindowsPowerShell\Modules\$ModuleName\$NewVersion"
    
    if (-not (Test-Path $InstallPath)) {
        New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
    }
    
    # Install files
    Write-Host "`nInstalling files..." -ForegroundColor Cyan
    
    # Manifest
    $manifestContent.Content | Out-File -FilePath "$InstallPath\$ModuleName.psd1" -Encoding UTF8 -Force
    Write-Host "  Installed $ModuleName.psd1" -ForegroundColor Green
    
    # Module
    $moduleContent = Invoke-WebRequest -Uri $ModuleUrl -UseBasicParsing -ErrorAction Stop
    $moduleContent.Content | Out-File -FilePath "$InstallPath\$ModuleName.psm1" -Encoding UTF8 -Force
    Write-Host "  Installed $ModuleName.psm1" -ForegroundColor Green
    
    # Cleanup
    Remove-Item -Path $tempPath -Force -ErrorAction SilentlyContinue
    
    # Test import
    Write-Host "`nVerifying installation..." -ForegroundColor Cyan
    Import-Module $ModuleName -Force -RequiredVersion $NewVersion -ErrorAction Stop
    
    $loadedModule = Get-Module $ModuleName
    
    Write-Host "`nSuccessfully installed $ModuleName v$($loadedModule.Version)" -ForegroundColor Green
    Write-Host "Location: $InstallPath" -ForegroundColor Gray
    
    Write-Host "`nAvailable commands:" -ForegroundColor Cyan
    $loadedModule.ExportedCommands.Keys | ForEach-Object {
        Write-Host "  - $_" -ForegroundColor White
    }
    
} catch {
    Write-Error "Installation failed: $_"
    Write-Host "`nTroubleshooting:" -ForegroundColor Yellow
    Write-Host "  1. Check internet connectivity" -ForegroundColor Gray
    Write-Host "  2. Verify GitHub URLs are accessible" -ForegroundColor Gray
    Write-Host "  3. Ensure you have admin rights" -ForegroundColor Gray
    exit 1
}