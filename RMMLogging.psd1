@{
    ModuleVersion = '1.0.1'
    GUID = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890' 
    Author = 'Merit IT'
    CompanyName = 'Merit IT LLC'
    Copyright = '(c) 2026. All rights reserved.'
    Description = 'RMM logging module for NinjaRMM with centralized error reporting to Azure'
    PowerShellVersion = '5.1'
    
    # Module to process
    RootModule = 'RMMLogging.psm1'
    
    # Functions to export
    FunctionsToExport = @('Send-RMMError')
    
    # Cmdlets to export
    CmdletsToExport = @()
    
    # Variables to export
    VariablesToExport = @()
    
    # Aliases to export
    AliasesToExport = @()
    
    # Private data
    PrivateData = @{
        PSData = @{
            ProjectUri = 'https://github.com/Merit-IT/RMMLogging'
            LicenseUri = 'https://github.com/Merit-IT/RMMLogging/blob/main/LICENSE'
            ReleaseNotes = 'Initial release with Send-RMMError function'
        }
    }
}