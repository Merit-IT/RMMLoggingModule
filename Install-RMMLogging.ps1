# Configuration
$ModuleName = "RMMLogging" 
$GitHubOwner = "Merit-IT" 
$GitHubRepo = "RMMLoggingModule"
$GitHubBranch = "main"

# URLs
$BaseUrl = "https://raw.githubusercontent.com/$GitHubOwner/$GitHubRepo/$GitHubBranch"
$ManifestUrl = "$BaseUrl/$ModuleName.psd1"
$ModuleUrl = "$BaseUrl/$ModuleName.psm1"

# Temp download location
$TempPath = Join-Path -Path $env:TEMP -ChildPath "${ModuleName}_Install"
New-Item -ItemType Directory -Path $TempPath -Force | Out-Null

Write-Host "Downloading $ModuleName from GitHub..." -ForegroundColor Cyan

# Download manifest
try {
    $manifestPath = Join-Path -Path $TempPath -ChildPath "$ModuleName.psd1"
    Invoke-WebRequest -Uri $ManifestUrl -OutFile $manifestPath -UseBasicParsing -ErrorAction Stop
    
    # Get version from manifest
    $manifest = Import-PowerShellDataFile -Path $manifestPath
    $version = $manifest.ModuleVersion
    Write-Host "✓ Downloaded manifest (v$version)" -ForegroundColor Green
} catch {
    Write-Error "Failed to download manifest: $_"
    Remove-Item -Path $TempPath -Recurse -Force -ErrorAction SilentlyContinue
    exit 1
}

# Download module
try {
    $modulePath = Join-Path -Path $TempPath -ChildPath "$ModuleName.psm1"
    Invoke-WebRequest -Uri $ModuleUrl -OutFile $modulePath -UseBasicParsing -ErrorAction Stop
    Write-Host "✓ Downloaded module" -ForegroundColor Green
} catch {
    Write-Error "Failed to download module: $_"
    Remove-Item -Path $TempPath -Recurse -Force -ErrorAction SilentlyContinue
    exit 1
}

# Install to module path
$installPath = "$env:ProgramFiles\WindowsPowerShell\Modules\$ModuleName\$version"
try {
    if (-not (Test-Path $installPath)) {
        New-Item -ItemType Directory -Path $installPath -Force | Out-Null
    }
    
    Copy-Item -Path "$TempPath\*" -Destination $installPath -Force
    Write-Host "✓ Installed to $installPath" -ForegroundColor Green
} catch {
    Write-Error "Failed to install module: $_"
    exit 1
} finally {
    Remove-Item -Path $TempPath -Recurse -Force -ErrorAction SilentlyContinue
}

# Test import
try {
    Import-Module $ModuleName -Force -ErrorAction Stop
    Write-Host "`n✓ Module imported successfully!" -ForegroundColor Green
    Write-Host "`nAvailable commands:" -ForegroundColor Cyan
    Get-Command -Module $ModuleName | ForEach-Object { Write-Host "  - $($_.Name)" }
} catch {
    Write-Warning "Module installed but import failed: $_"
}