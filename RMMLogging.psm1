# Import NinjaRMM module at module load time
try {
    Import-Module NJCliPSh -ErrorAction Stop -Verbose:$false 3>$null
} catch {
    Write-Warning "NJCliPSh module not available. Some features may be limited."
}

function Send-RMMError {
    param(
        [Parameter(Mandatory)]
        [string]$ScriptName,
        
        [Parameter(Mandatory)]
        [string]$ErrorMessage,
        
        [string]$ApiUrl = "https://logerror-prod-nwee4zhwawxie.azurewebsites.net/api/LogError"
    )
    
    $orgId = $env:NINJA_ORGANIZATION_ID
    $timestamp = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
    
    # Create signature
    $sharedSecret = Ninja-Property-Get loggingSecret
    if (-not $sharedSecret) {
        Write-Warning "loggingSecret not set, cannot log error"
        return
    }
    
    $message = "$orgId|$timestamp"
    $hmac = New-Object System.Security.Cryptography.HMACSHA256
    $hmac.Key = [Text.Encoding]::UTF8.GetBytes($sharedSecret)
    $signature = [Convert]::ToBase64String($hmac.ComputeHash([Text.Encoding]::UTF8.GetBytes($message)))
    
    $payload = @{
        org_id = $orgId
        computer = $env:COMPUTERNAME
        script = $ScriptName
        error = $ErrorMessage
        timestamp = $timestamp
        signature = $signature
    } | ConvertTo-Json
    
    try {
        Invoke-RestMethod -Uri $ApiUrl `
            -Method Post `
            -Body $payload `
            -ContentType "application/json" `
            -TimeoutSec 5 `
            -ErrorAction Stop | Out-Null
         Write-Verbose "Sent logs"   
    } catch {
        # Fail silently - don't break script if logging fails
        Write-Verbose "Failed to send error log: $_"
    }
}

Export-ModuleMember -Function Send-RMMError