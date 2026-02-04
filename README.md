# RMMLogging Module

A PowerShell module for centralized error logging from NinjaRMM scripts to Azure Log Analytics.

[![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-blue.svg)](https://github.com/PowerShell/PowerShell)

## Overview

RMMLogging provides a simple, secure way to send error logs from NinjaRMM client scripts to Azure Log Analytics for centralized monitoring and alerting. Errors are authenticated using HMAC-SHA256 signatures to prevent unauthorized log submissions.

### Key Features

- ✅ **Simple Integration** - Single function call to log errors
- 🔒 **Secure** - HMAC-SHA256 signature validation
- 📊 **Centralized** - All errors in one Azure Log Analytics workspace
- 🔔 **Alerting Ready** - Query and alert on errors in Azure
- 🚀 **Lightweight** - Minimal overhead, fails silently if logging unavailable
- 📦 **Easy Installation** - One-line installer from GitHub

## Architecture

```
┌─────────────────────┐
│  Client Machine     │
│  (NinjaRMM Agent)   │
└──────────┬──────────┘
           │
           │ Error + HMAC Signature
           │
           ▼
┌─────────────────────┐
│  Azure Function     │
│                     │
│  1. Validate        │
│     Signature       │
│                     │
│  2. Enrich with     │
│     Client Data     │
│                     │
│  3. Forward to      │
│     Log Analytics   │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Azure Log Analytics │
│                     │
│  • Monitor errors   │
│  • Create alerts    │
│  • Generate reports │
└─────────────────────┘
```

## Installation

### Quick Install (One-Liner)

Run this in an elevated PowerShell window:

```powershell
iex ((New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/Merit-IT/RMMLoggingModule/main/Install-RMMLogging.ps1'))
```

### Manual Install

1. Download `RMMLogging.psm1` and `RMMLogging.psd1`
2. Copy to `C:\Program Files\WindowsPowerShell\Modules\RMMLogging\1.0.x\`
3. Import the module:
   ```powershell
   Import-Module RMMLogging -Force
   ```

### Verify Installation

```powershell
Get-Module RMMLogging -ListAvailable
Get-Command -Module RMMLogging
```

## Prerequisites

### NinjaRMM Configuration

1. **Set Custom Field** - Create a custom organization field called `loggingSecret`
2. **Generate Secret** - Use a strong random string (recommended: 32+ characters)
   ```powershell
   # Generate a secure random secret
   -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 32 | ForEach-Object {[char]$_})
   ```
3. **Store Secret** - Save the secret in the `loggingSecret` custom field for each organization

## Usage

### Basic Error Logging

```powershell
Import-Module RMMLogging -Force

try {
    # Your script logic
    Invoke-SomeCommand
} catch {
    Send-RMMError -ScriptName "MyScript" -ErrorMessage $_
    throw
}
```

## API Reference

### Send-RMMError

Sends error information to Azure Log Analytics via Azure Function.

#### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `ScriptName` | String | Yes | Name of the script that encountered the error |
| `ErrorMessage` | String | Yes | Error message or exception details |


- ✅ Use strong random strings for `loggingSecret` (32+ characters)
- ✅ Rotate secrets periodically
- ✅ Use HTTPS for all communications
- ✅ Review Log Analytics queries regularly
- ✅ Set up alerts for unusual error patterns

## Troubleshooting

### Module Not Found

```powershell
# Check if module is installed
Get-Module RMMLogging -ListAvailable

# If not found, reinstall
iex ((New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/Merit-IT/RMMLoggingModule/main/Install-RMMLogging.ps1'))
```

### Silent Failures

By design, `Send-RMMError` fails silently to prevent logging errors from breaking your scripts:

```powershell
Send-RMMError -ScriptName "Test" -ErrorMessage "Test error"
```

## Updating

The installer automatically checks for newer versions. To update:

```powershell
# Run installer again
iex ((New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/Merit-IT/RMMLoggingModule/main/Install-RMMLogging.ps1'))
```

Or manually:

```powershell
# Remove old version
Remove-Module RMMLogging -ErrorAction SilentlyContinue
Remove-Item "C:\Program Files\WindowsPowerShell\Modules\RMMLogging" -Recurse -Force

# Reinstall
# ... run installer ...
```

