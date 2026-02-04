# RMMLogging Module Installer with Auto-Versioning
$ModuleName = "RMMLogging"
$GitHubOwner = "Merit-IT"
$GitHubRepo = "RMMLoggingModule"
$GitHubBranch = "main"

Write-Host "Installing $ModuleName from GitHub..." -ForegroundColor Cyan

# URLs
$BaseUrl = "https://raw.githubusercontent.com/$GitHubOwner/$GitHubRepo/$GitHubBranch"
$ManifestUrl = "$BaseUrl/$ModuleName.psd1"
$ModuleUrl = "$BaseUrl/$ModuleName.psm1"

try {
    # Download manifest to get version
    Write-Host "Downloading manifest..." -ForegroundColor Cyan
    $manifestContent = Invoke-WebRequest -Uri $ManifestUrl -UseBasicParsing -ErrorAction Stop
    
    # Save to temp location to read version
    $tempPath = "$env:TEMP\$ModuleName.psd1"
    $manifestContent.Content | Out-File -FilePath $tempPath -Encoding UTF8 -Force
    
    # Read version from manifest
    $manifest = Import-PowerShellDataFile -Path $tempPath
    $ModuleVersion = $manifest.ModuleVersion
    
    Write-Host "Found version: $ModuleVersion" -ForegroundColor Green
    
    # Create versioned directory
    $InstallPath = "$env:ProgramFiles\WindowsPowerShell\Modules\$ModuleName\$ModuleVersion"
    
    if (-not (Test-Path $InstallPath)) {
        New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
        Write-Host "Created directory: $InstallPath" -ForegroundColor Cyan
    } else {
        Write-Host "Directory exists: $InstallPath" -ForegroundColor Yellow
    }
    
    # Save manifest to final location
    $manifestContent.Content | Out-File -FilePath "$InstallPath\$ModuleName.psd1" -Encoding UTF8 -Force
    Write-Host "Installed manifest" -ForegroundColor Green
    
    #  Download and save module file
    Write-Host "Downloading module..." -ForegroundColor Cyan
    $moduleContent = Invoke-WebRequest -Uri $ModuleUrl -UseBasicParsing -ErrorAction Stop
    $moduleContent.Content | Out-File -FilePath "$InstallPath\$ModuleName.psm1" -Encoding UTF8 -Force
    Write-Host "Installed module" -ForegroundColor Green
    
    # Cleanup temp file
    Remove-Item -Path $tempPath -Force -ErrorAction SilentlyContinue
    
    # Test import
    Write-Host "`nTesting module..." -ForegroundColor Cyan
    Import-Module $ModuleName -Force -ErrorAction Stop
    
    $loadedModule = Get-Module $ModuleName
    Write-Host "`n✓ Successfully installed $ModuleName v$($loadedModule.Version)" -ForegroundColor Green
    Write-Host "  Path: $($loadedModule.Path)" -ForegroundColor Gray
    
    # Show available commands to verify 
    Write-Host "`nAvailable commands:" -ForegroundColor Cyan
    $loadedModule.ExportedCommands.Keys | ForEach-Object {
        Write-Host "  - $_" -ForegroundColor White
    }
    
} catch {
    Write-Error "Installation failed: $_"
    Write-Host "`nError details:" -ForegroundColor Red
    Write-Host "  $($_.Exception.Message)" -ForegroundColor Yellow
    exit 1
}