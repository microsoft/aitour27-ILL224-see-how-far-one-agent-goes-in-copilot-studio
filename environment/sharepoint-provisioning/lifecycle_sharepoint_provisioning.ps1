#requires -Version 7.4

$ErrorActionPreference = "Stop"
$logFile = "C:\Users\LabUser\Desktop\ill224-sharepoint-provisioning.log"

function Write-ILL224LifecycleLog {
    param([Parameter(Mandatory)][string]$Message)

    $line = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $Message"
    Write-Host $line
    Add-Content -LiteralPath $logFile -Value $line
}

$clientId = "@lab.CloudSubscription.AppId"
$tenantId = "@lab.CloudSubscription.TenantId"
$learnerUpn = "@lab.CloudPortalCredential(User1).Username"
$sharePointTenantName = "@lab.Variable(ILL224SharePointTenantName)"
$certificateBase64 = "@lab.Variable(ILL224PnPCertificateBase64)"
$certificatePasswordText = "@lab.Variable(ILL224PnPCertificatePassword)"

$requiredValues = @{
    ClientId                 = $clientId
    TenantId                 = $tenantId
    LearnerUpn               = $learnerUpn
    SharePointTenantName     = $sharePointTenantName
    CertificateBase64Encoded = $certificateBase64
    CertificatePassword      = $certificatePasswordText
}

foreach ($entry in $requiredValues.GetEnumerator()) {
    if ([string]::IsNullOrWhiteSpace($entry.Value) -or $entry.Value -like "@lab.*") {
        throw "Skillable did not resolve the required value '$($entry.Key)'."
    }
}

$adminUrl = "https://$sharePointTenantName-admin.sharepoint.com"
$siteUrl = "https://$sharePointTenantName.sharepoint.com"
$certificatePassword = ConvertTo-SecureString $certificatePasswordText -AsPlainText -Force
$provisioningScript = Join-Path $PSScriptRoot "Provision-ILL224SharePoint.ps1"

try {
    Write-ILL224LifecycleLog "Starting ILL224 SharePoint provisioning for $learnerUpn."

    & $provisioningScript `
        -Tenant $tenantId `
        -AdminUrl $adminUrl `
        -SiteUrl $siteUrl `
        -LearnerUpn $learnerUpn `
        -ClientId $clientId `
        -AuthenticationMode Certificate `
        -CertificateBase64Encoded $certificateBase64 `
        -CertificatePassword $certificatePassword `
        -UseExistingSite `
        -IncludeOptionalContent *>> $logFile

    Write-ILL224LifecycleLog "ILL224 SharePoint provisioning completed for $siteUrl."
}
catch {
    Write-ILL224LifecycleLog "ILL224 SharePoint provisioning failed: $($_.Exception.Message)"
    throw
}
