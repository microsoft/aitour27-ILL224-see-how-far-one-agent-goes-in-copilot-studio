[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [string]$Tenant,

    [Parameter(Mandatory)]
    [string]$AdminUrl,

    [Parameter(Mandatory)]
    [string]$SiteUrl,

    [Parameter(Mandatory)]
    [string]$LearnerUpn,

    [Parameter(Mandatory)]
    [string]$ClientId,

    [ValidateSet("Interactive", "Certificate")]
    [string]$AuthenticationMode = "Interactive",

    [string]$CertificateBase64Encoded,

    [securestring]$CertificatePassword,

    [string]$SiteTitle = "Caldova Supplier Operations",

    [ValidateRange(101, 3600)]
    [int]$HttpTimeoutSeconds = 600,

    [string]$PackageRoot = (Join-Path $PSScriptRoot ".." ".." "package"),

    [switch]$IncludeOptionalContent,

    [switch]$UseExistingSite,

    [switch]$ValidateOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$env:SharePointPnPHttpTimeout = $HttpTimeoutSeconds.ToString([Globalization.CultureInfo]::InvariantCulture)

function Connect-ILL224PnP {
    param([Parameter(Mandatory)][string]$Url)

    if ($AuthenticationMode -eq "Certificate") {
        Connect-PnPOnline `
            -Url $Url `
            -Tenant $Tenant `
            -ClientId $ClientId `
            -CertificateBase64Encoded $CertificateBase64Encoded `
            -CertificatePassword $CertificatePassword
        return
    }

    Connect-PnPOnline -Url $Url -Tenant $Tenant -ClientId $ClientId -Interactive
}

function Assert-ILL224Authentication {
    if ($AuthenticationMode -ne "Certificate") {
        return
    }

    if ([string]::IsNullOrWhiteSpace($CertificateBase64Encoded)) {
        throw "CertificateBase64Encoded is required when AuthenticationMode is Certificate."
    }

    if ($null -eq $CertificatePassword) {
        throw "CertificatePassword is required when AuthenticationMode is Certificate."
    }
}

function Ensure-ILL224Module {
    if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
        throw "PnP.PowerShell is required. Install it with: Install-Module PnP.PowerShell -Scope CurrentUser"
    }

    Import-Module PnP.PowerShell -MinimumVersion 2.12.0
}

function Assert-ILL224Package {
    $requiredPaths = @(
        "SharePoint/core/Caldova_Supplier_Invoice_Review_Policy.docx",
        "SharePoint/core/Caldova_Astor_Ridge_Manufacturing_Agreement.docx",
        "SharePoint/core/Caldova_Northwind_Packaging_Agreement.docx",
        "SharePoint/core/Astor_Ridge_Expedite_Approval.pdf",
        "SharePoint/core/Northwind_Label_Setup_Decision.pdf",
        "SharePoint/core/Caldova_Supplier_Quality_Exception.pdf",
        "SharePoint-Lists/seed-data/Suppliers.csv",
        "SharePoint-Lists/seed-data/SupplierInvoices.csv",
        "SharePoint-Lists/seed-data/InvoiceLines.csv",
        "SharePoint-Lists/seed-data/QualityEvents.csv",
        "SharePoint-Lists/seed-data/InvoiceReviewRequests.csv",
        "SharePoint-Lists/seed-data/InvoiceReviewLog.csv"
    )

    if ($IncludeOptionalContent) {
        $requiredPaths += @(
            "SharePoint/optional/Caldova_Multi_Case_Supplier_Master.xlsx",
            "SharePoint/optional/Caldova_Supplier_Governance_Briefing.pptx"
        )
    }

    foreach ($relativePath in $requiredPaths) {
        $path = Join-Path $PackageRoot $relativePath
        if (-not (Test-Path -LiteralPath $path)) {
            throw "Required package path not found: $path"
        }
    }
}

function Assert-ILL224SeedData {
    $seedRoot = Join-Path $PackageRoot "SharePoint-Lists/seed-data"
    $suppliers = @(Import-Csv -LiteralPath (Join-Path $seedRoot "Suppliers.csv"))
    $invoices = @(Import-Csv -LiteralPath (Join-Path $seedRoot "SupplierInvoices.csv"))
    $lines = @(Import-Csv -LiteralPath (Join-Path $seedRoot "InvoiceLines.csv"))
    $qualityEvents = @(Import-Csv -LiteralPath (Join-Path $seedRoot "QualityEvents.csv"))

    if ($invoices.Count -lt 4) {
        throw "SupplierInvoices.csv must contain at least four invoices."
    }

    $supplierStatuses = @("Active", "Conditional", "Inactive")
    foreach ($supplier in $suppliers) {
        if ($supplier.Status -notin $supplierStatuses) {
            throw "Supplier '$($supplier.Title)' has invalid Status '$($supplier.Status)'."
        }
    }

    $invoiceStatuses = @("Pending Review", "Review Requested", "Review Complete")
    foreach ($invoice in $invoices) {
        if ($invoice.Status -notin $invoiceStatuses) {
            throw "Invoice '$($invoice.Title)' has invalid or missing Status '$($invoice.Status)'."
        }

        $supplier = $suppliers | Where-Object { $_."Supplier ID" -eq $invoice."Supplier ID" } | Select-Object -First 1
        if (-not $supplier) {
            throw "Invoice '$($invoice.Title)' references missing supplier '$($invoice.'Supplier ID')'."
        }
        if ($supplier.Title -ne $invoice."Supplier Name") {
            throw "Invoice '$($invoice.Title)' supplier name does not match '$($supplier.Title)'."
        }

        $invoiceLines = @($lines | Where-Object { $_."Invoice ID" -eq $invoice.Title })
        if ($invoiceLines.Count -eq 0) {
            throw "Invoice '$($invoice.Title)' has no invoice lines."
        }
        $lineTotal = ($invoiceLines | Measure-Object -Property Amount -Sum).Sum
        if ([decimal]$lineTotal -ne [decimal]$invoice."Invoice Total") {
            throw "Invoice '$($invoice.Title)' total does not match its line total."
        }

        $qualityEvent = $qualityEvents | Where-Object {
            $_."Supplier ID" -eq $invoice."Supplier ID" -and
            $_."Batch or Lot ID" -eq $invoice."Batch or Lot ID"
        } | Select-Object -First 1
        if (-not $qualityEvent) {
            throw "Invoice '$($invoice.Title)' has no matching supplier and batch record in QualityEvents.csv."
        }
    }

    foreach ($qualityEvent in $qualityEvents) {
        if ($qualityEvent."Event Status" -notin @("Open", "Closed")) {
            throw "Quality event '$($qualityEvent.Title)' has invalid Event Status '$($qualityEvent.'Event Status')'."
        }
        if ($qualityEvent."Active Quality Hold" -notin @("Yes", "No")) {
            throw "Quality event '$($qualityEvent.Title)' has invalid Active Quality Hold '$($qualityEvent.'Active Quality Hold')'."
        }
        if ($qualityEvent."Product Impact" -notin @("Yes", "No", "Under Review")) {
            throw "Quality event '$($qualityEvent.Title)' has invalid Product Impact '$($qualityEvent.'Product Impact')'."
        }
    }
}

function Test-ILL224HttpTimeout {
    param([Parameter(Mandatory)][System.Management.Automation.ErrorRecord]$ErrorRecord)

    return $ErrorRecord.Exception.ToString() -match "HttpClient\.Timeout of 100 seconds"
}

function Wait-ILL224TenantSite {
    param(
        [Parameter(Mandatory)][string]$Url,
        [int]$TimeoutSeconds = 900
    )

    $deadline = [datetime]::UtcNow.AddSeconds($TimeoutSeconds)
    do {
        $site = $null
        try {
            $site = Get-PnPTenantSite -Url $Url -ErrorAction SilentlyContinue
        }
        catch {
            if (-not (Test-ILL224HttpTimeout -ErrorRecord $_)) {
                throw
            }
            Write-Warning "The SharePoint readiness check timed out; retrying until the provisioning deadline."
        }

        if ($site) {
            Write-Host "SharePoint site is ready: $Url" -ForegroundColor Green
            return
        }

        Write-Host "Waiting for SharePoint to finish creating $Url..."
        Start-Sleep -Seconds 15
    } while ([datetime]::UtcNow -lt $deadline)

    throw "SharePoint site was not ready within $TimeoutSeconds seconds: $Url"
}

function Ensure-ILL224Site {
    if ($UseExistingSite) {
        Write-Host "Using existing SharePoint site: $SiteUrl"
        Connect-ILL224PnP -Url $SiteUrl
        Get-PnPWeb -Includes Title | Out-Null
        return
    }

    Write-Host "Connecting to the SharePoint admin center: $AdminUrl"
    Connect-ILL224PnP -Url $AdminUrl

    Write-Host "Checking whether the SharePoint site already exists: $SiteUrl"
    $existingSite = Get-PnPTenantSite -Url $SiteUrl -ErrorAction SilentlyContinue

    if (-not $existingSite) {
        if ($ValidateOnly) {
            throw "Site does not exist: $SiteUrl"
        }

        if ($PSCmdlet.ShouldProcess($SiteUrl, "Create SharePoint team site")) {
            Write-Host "Submitting SharePoint site creation: $SiteUrl"
            try {
                New-PnPSite `
                    -Type TeamSiteWithoutMicrosoft365Group `
                    -Title $SiteTitle `
                    -Url $SiteUrl `
                    -Owner $LearnerUpn `
                    -TimeZone UTCMINUS0500_EASTERN_TIME_US_AND_CANADA
            }
            catch {
                if (-not (Test-ILL224HttpTimeout -ErrorRecord $_)) {
                    throw
                }
                Write-Warning "The creation request timed out after 100 seconds. SharePoint may still have accepted it; checking tenant status."
            }
            Wait-ILL224TenantSite -Url $SiteUrl
        }
    }

    Write-Host "Connecting to the provisioned SharePoint site: $SiteUrl"
    Connect-ILL224PnP -Url $SiteUrl
}

function Ensure-ILL224List {
    param(
        [Parameter(Mandatory)][string]$Title,
        [ValidateSet("GenericList", "DocumentLibrary")][string]$Template = "GenericList"
    )

    $list = Get-PnPList -Identity $Title -ErrorAction SilentlyContinue
    if (-not $list) {
        if ($ValidateOnly) {
            throw "List or library does not exist: $Title"
        }

        if ($PSCmdlet.ShouldProcess($Title, "Create $Template")) {
            New-PnPList -Title $Title -Template $Template -OnQuickLaunch | Out-Null
            $list = Get-PnPList -Identity $Title
        }
    }

    return $list
}

function Ensure-ILL224Field {
    param(
        [Parameter(Mandatory)][string]$List,
        [Parameter(Mandatory)][string]$DisplayName,
        [Parameter(Mandatory)][string]$InternalName,
        [Parameter(Mandatory)][ValidateSet("Text", "Number", "Currency", "DateTime", "Boolean", "Note", "Choice")][string]$Type,
        [string[]]$Choices,
        [switch]$Indexed
    )

    $field = Get-PnPField -List $List -Identity $InternalName -ErrorAction SilentlyContinue
    if (-not $field) {
        if ($ValidateOnly) {
            throw "Field '$InternalName' does not exist on '$List'."
        }

        if ($PSCmdlet.ShouldProcess("$List/$InternalName", "Create field")) {
            if ($Type -eq "Choice") {
                if (-not $Choices) {
                    throw "Choices are required for choice field '$InternalName' on '$List'."
                }

                $choiceElements = ($Choices | ForEach-Object {
                    "<CHOICE>$([Security.SecurityElement]::Escape($_))</CHOICE>"
                }) -join ""
                $fieldXml = "<Field Type=`"Choice`" DisplayName=`"$([Security.SecurityElement]::Escape($DisplayName))`" Name=`"$([Security.SecurityElement]::Escape($InternalName))`" StaticName=`"$([Security.SecurityElement]::Escape($InternalName))`" Format=`"Dropdown`" AddToDefaultView=`"TRUE`"><CHOICES>$choiceElements</CHOICES></Field>"
                Add-PnPFieldFromXml -List $List -FieldXml $fieldXml | Out-Null
            }
            else {
                Add-PnPField `
                    -List $List `
                    -DisplayName $DisplayName `
                    -InternalName $InternalName `
                    -Type $Type `
                    -AddToDefaultView | Out-Null
            }
        }
    }

    if ($field) {
        Get-PnPProperty -ClientObject $field -Property TypeAsString | Out-Null
        if ($field.TypeAsString -ne $Type) {
            throw "Field '$InternalName' on '$List' has type '$($field.TypeAsString)'; expected '$Type'."
        }

        if ($Type -eq "Choice") {
            Get-PnPProperty -ClientObject $field -Property Choices | Out-Null
            $missingChoices = @($Choices | Where-Object { $_ -notin $field.Choices })
            if ($missingChoices.Count -gt 0) {
                if ($ValidateOnly) {
                    throw "Field '$InternalName' on '$List' is missing choices: $($missingChoices -join ', ')."
                }
                if ($PSCmdlet.ShouldProcess("$List/$InternalName", "Add choices: $($missingChoices -join ', ')")) {
                    Set-PnPField -List $List -Identity $InternalName -Values @{ Choices = @($field.Choices + $missingChoices) } | Out-Null
                }
            }
        }
    }

    if ($Indexed -and -not $ValidateOnly) {
        Set-PnPField -List $List -Identity $InternalName -Values @{ Indexed = $true } | Out-Null
    }
}

function Ensure-ILL224DefaultViewFields {
    param(
        [Parameter(Mandatory)][string]$List,
        [Parameter(Mandatory)][string[]]$InternalNames
    )

    $defaultView = Get-PnPView -List $List | Where-Object DefaultView | Select-Object -First 1
    if (-not $defaultView) {
        throw "Default view not found for '$List'."
    }

    Get-PnPProperty -ClientObject $defaultView -Property ViewFields | Out-Null
    $currentFields = @($defaultView.ViewFields)
    $missingFields = @($InternalNames | Where-Object { $_ -notin $currentFields })
    if ($missingFields.Count -eq 0) {
        return
    }

    if ($ValidateOnly) {
        throw "Default view for '$List' is missing fields: $($missingFields -join ', ')."
    }

    if ($PSCmdlet.ShouldProcess("$List/$($defaultView.Title)", "Add fields to default view: $($missingFields -join ', ')")) {
        Set-PnPView -List $List -Identity $defaultView.Id -Fields @($currentFields + $missingFields) | Out-Null
    }
}

function ConvertTo-ILL224FieldValue {
    param(
        [AllowNull()][string]$Value,
        [Parameter(Mandatory)][string]$Type
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return $null
    }

    switch ($Type) {
        "Boolean" { return $Value -match "^(Yes|True|1)$" }
        "Number" { return [double]::Parse($Value, [Globalization.CultureInfo]::InvariantCulture) }
        "Currency" { return [double]::Parse($Value, [Globalization.CultureInfo]::InvariantCulture) }
        "DateTime" { return [datetime]::Parse($Value, [Globalization.CultureInfo]::InvariantCulture) }
        default { return $Value }
    }
}

function Import-ILL224SeedData {
    param(
        [Parameter(Mandatory)][string]$List,
        [Parameter(Mandatory)][string]$CsvName,
        [Parameter(Mandatory)][hashtable]$ColumnMap
    )

    $csvPath = Join-Path $PackageRoot "SharePoint-Lists/seed-data/$CsvName"
    foreach ($row in (Import-Csv -LiteralPath $csvPath)) {
        if ([string]::IsNullOrWhiteSpace($row.Title)) {
            continue
        }

        $escapedTitle = [Security.SecurityElement]::Escape($row.Title)
        $query = "<View><Query><Where><Eq><FieldRef Name='Title'/><Value Type='Text'>$escapedTitle</Value></Eq></Where></Query><RowLimit>1</RowLimit></View>"
        $existingItem = Get-PnPListItem -List $List -Query $query | Select-Object -First 1
        $values = @{ Title = $row.Title }

        foreach ($heading in $ColumnMap.Keys) {
            $definition = $ColumnMap[$heading]
            $value = ConvertTo-ILL224FieldValue -Value $row.$heading -Type $definition.Type
            if ($null -ne $value) {
                $values[$definition.Name] = $value
            }
        }

        if ($ValidateOnly) {
            if (-not $existingItem) {
                throw "Seed item '$($row.Title)' is missing from '$List'."
            }
            continue
        }

        if ($existingItem) {
            if ($PSCmdlet.ShouldProcess("$List/$($row.Title)", "Update seed item")) {
                Set-PnPListItem -List $List -Identity $existingItem.Id -Values $values | Out-Null
            }
        }
        elseif ($PSCmdlet.ShouldProcess("$List/$($row.Title)", "Create seed item")) {
            Add-PnPListItem -List $List -Values $values | Out-Null
        }
    }
}

function Add-ILL224Document {
    param(
        [Parameter(Mandatory)][string]$FileName,
        [Parameter(Mandatory)][hashtable]$Metadata,
        [switch]$Optional
    )

    $sourceFolder = if ($Optional) { "optional" } else { "core" }
    $sourcePath = Join-Path $PackageRoot "SharePoint/$sourceFolder/$FileName"
    $targetFolder = "Contracts"

    if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) {
        throw "Document source file not found: $sourcePath"
    }

    $existingFile = Get-PnPFile -Url "$targetFolder/$FileName" -AsListItem -ErrorAction SilentlyContinue

    if ($ValidateOnly) {
        if (-not $existingFile) {
            throw "Document is missing: $targetFolder/$FileName"
        }
        return
    }

    if ($PSCmdlet.ShouldProcess("$targetFolder/$FileName", "Upload document and apply metadata")) {
        Add-PnPFile -Path $sourcePath -Folder $targetFolder -Values $Metadata | Out-Null
    }
}

function Set-ILL224Permissions {
    $readLists = @("Contracts", "Suppliers", "Invoice Lines", "Quality Events")
    $contributeLists = @("Supplier Invoices", "Invoice Review Requests", "Invoice Review Log")

    if ($ValidateOnly) {
        return
    }

    Set-PnPWebPermission -User $LearnerUpn -AddRole "Read"
    foreach ($list in $readLists) {
        $targetList = Get-PnPList -Identity $list
        Get-PnPProperty -ClientObject $targetList -Property HasUniqueRoleAssignments | Out-Null
        if (-not $targetList.HasUniqueRoleAssignments) {
            Set-PnPList -Identity $targetList -BreakRoleInheritance -CopyRoleAssignments
        }
        Set-PnPListPermission -Identity $list -User $LearnerUpn -AddRole "Read"
    }
    foreach ($list in $contributeLists) {
        $targetList = Get-PnPList -Identity $list
        Get-PnPProperty -ClientObject $targetList -Property HasUniqueRoleAssignments | Out-Null
        if (-not $targetList.HasUniqueRoleAssignments) {
            Set-PnPList -Identity $targetList -BreakRoleInheritance -CopyRoleAssignments
        }
        Set-PnPListPermission -Identity $list -User $LearnerUpn -AddRole "Contribute"
    }
}

Assert-ILL224Authentication
Ensure-ILL224Module
Assert-ILL224Package
Assert-ILL224SeedData
Ensure-ILL224Site

Ensure-ILL224List -Title "Contracts" -Template DocumentLibrary | Out-Null
Ensure-ILL224Field -List "Contracts" -DisplayName "Document Type" -InternalName "DocumentType" -Type Choice -Choices @("Policy", "Contract", "Written Approval", "Procurement Decision", "Quality Record", "Reference")
Ensure-ILL224Field -List "Contracts" -DisplayName "Supplier ID" -InternalName "SupplierID" -Type Text
Ensure-ILL224Field -List "Contracts" -DisplayName "Contract ID" -InternalName "ContractID" -Type Text
Ensure-ILL224Field -List "Contracts" -DisplayName "Effective Date" -InternalName "EffectiveDate" -Type DateTime
Ensure-ILL224Field -List "Contracts" -DisplayName "Lab Data" -InternalName "LabData" -Type Boolean

$listDefinitions = @(
    @{ Title = "Suppliers"; Fields = @(
        @{ DisplayName = "Supplier ID"; InternalName = "SupplierID"; Type = "Text"; Indexed = $true },
        @{ DisplayName = "Status"; InternalName = "Status"; Type = "Choice"; Choices = @("Active", "Conditional", "Inactive") },
        @{ DisplayName = "Risk Tier"; InternalName = "RiskTier"; Type = "Choice"; Choices = @("Low", "Medium", "High") },
        @{ DisplayName = "Contract ID"; InternalName = "ContractID"; Type = "Text" },
        @{ DisplayName = "Payment Terms"; InternalName = "PaymentTerms"; Type = "Text" },
        @{ DisplayName = "Eligible for Standard Controls"; InternalName = "EligibleForStandardControls"; Type = "Boolean" }
    )},
    @{ Title = "Supplier Invoices"; Fields = @(
        @{ DisplayName = "Supplier ID"; InternalName = "SupplierID"; Type = "Text" },
        @{ DisplayName = "Supplier Name"; InternalName = "SupplierName"; Type = "Text" },
        @{ DisplayName = "Purchase Order"; InternalName = "PurchaseOrder"; Type = "Text" },
        @{ DisplayName = "Contract ID"; InternalName = "ContractID"; Type = "Text" },
        @{ DisplayName = "Invoice Date"; InternalName = "InvoiceDate"; Type = "DateTime" },
        @{ DisplayName = "Batch or Lot ID"; InternalName = "BatchOrLotID"; Type = "Text" },
        @{ DisplayName = "Currency"; InternalName = "CurrencyCode"; Type = "Text" },
        @{ DisplayName = "Invoice Total"; InternalName = "InvoiceTotal"; Type = "Currency" },
        @{ DisplayName = "Status"; InternalName = "Status"; Type = "Choice"; Choices = @("Pending Review", "Review Requested", "Review Complete") }
    )},
    @{ Title = "Invoice Lines"; Fields = @(
        @{ DisplayName = "Invoice ID"; InternalName = "InvoiceID"; Type = "Text"; Indexed = $true },
        @{ DisplayName = "Sequence"; InternalName = "Sequence"; Type = "Number" },
        @{ DisplayName = "Description"; InternalName = "Description"; Type = "Text" },
        @{ DisplayName = "Quantity"; InternalName = "Quantity"; Type = "Number" },
        @{ DisplayName = "Unit Price"; InternalName = "UnitPrice"; Type = "Currency" },
        @{ DisplayName = "Amount"; InternalName = "Amount"; Type = "Currency" },
        @{ DisplayName = "Claimed Contract Reference"; InternalName = "ClaimedContractReference"; Type = "Text" }
    )},
    @{ Title = "Quality Events"; Fields = @(
        @{ DisplayName = "Supplier ID"; InternalName = "SupplierID"; Type = "Text" },
        @{ DisplayName = "Batch or Lot ID"; InternalName = "BatchOrLotID"; Type = "Text" },
        @{ DisplayName = "Event Status"; InternalName = "EventStatus"; Type = "Choice"; Choices = @("Open", "Closed") },
        @{ DisplayName = "Active Quality Hold"; InternalName = "ActiveQualityHold"; Type = "Boolean" },
        @{ DisplayName = "Product Impact"; InternalName = "ProductImpact"; Type = "Choice"; Choices = @("Yes", "No", "Under Review") },
        @{ DisplayName = "Summary"; InternalName = "Summary"; Type = "Note" }
    )},
    @{ Title = "Invoice Review Requests"; Fields = @(
        @{ DisplayName = "Invoice ID"; InternalName = "InvoiceID"; Type = "Text" },
        @{ DisplayName = "Request Notes"; InternalName = "RequestNotes"; Type = "Note" },
        @{ DisplayName = "Status"; InternalName = "Status"; Type = "Choice"; Choices = @("New", "Processing", "Awaiting Human Review", "Complete", "Failed") },
        @{ DisplayName = "Agent Response"; InternalName = "AgentResponse"; Type = "Note" },
        @{ DisplayName = "Error Detail"; InternalName = "ErrorDetail"; Type = "Note" }
    )},
    @{ Title = "Invoice Review Log"; Fields = @(
        @{ DisplayName = "Invoice ID"; InternalName = "InvoiceID"; Type = "Text"; Indexed = $true },
        @{ DisplayName = "Supported Amount"; InternalName = "SupportedAmount"; Type = "Currency" },
        @{ DisplayName = "Disputed Amount"; InternalName = "DisputedAmount"; Type = "Currency" },
        @{ DisplayName = "Human Review Required"; InternalName = "HumanReviewRequired"; Type = "Boolean" },
        @{ DisplayName = "Recommendation"; InternalName = "Recommendation"; Type = "Note" },
        @{ DisplayName = "Review Source"; InternalName = "ReviewSource"; Type = "Choice"; Choices = @("Interactive Agent", "Workflow") },
        @{ DisplayName = "Review Document Name"; InternalName = "ReviewDocumentName"; Type = "Text" }
    )}
)

foreach ($definition in $listDefinitions) {
    Ensure-ILL224List -Title $definition.Title | Out-Null
    foreach ($field in $definition.Fields) {
        $fieldChoices = if ($field.ContainsKey("Choices")) { $field.Choices } else { $null }
        $fieldIndexed = $field.ContainsKey("Indexed") -and [bool]$field.Indexed
        Ensure-ILL224Field -List $definition.Title -DisplayName $field.DisplayName -InternalName $field.InternalName -Type $field.Type -Choices $fieldChoices -Indexed:$fieldIndexed
    }
    Ensure-ILL224DefaultViewFields -List $definition.Title -InternalNames @($definition.Fields | ForEach-Object InternalName)
}

$supplierMap = @{
    "Supplier ID" = @{ Name = "SupplierID"; Type = "Text" }
    "Status" = @{ Name = "Status"; Type = "Text" }
    "Risk Tier" = @{ Name = "RiskTier"; Type = "Text" }
    "Contract ID" = @{ Name = "ContractID"; Type = "Text" }
    "Payment Terms" = @{ Name = "PaymentTerms"; Type = "Text" }
    "Eligible for Standard Controls" = @{ Name = "EligibleForStandardControls"; Type = "Boolean" }
}
$invoiceMap = @{
    "Supplier ID" = @{ Name = "SupplierID"; Type = "Text" }
    "Supplier Name" = @{ Name = "SupplierName"; Type = "Text" }
    "Purchase Order" = @{ Name = "PurchaseOrder"; Type = "Text" }
    "Contract ID" = @{ Name = "ContractID"; Type = "Text" }
    "Invoice Date" = @{ Name = "InvoiceDate"; Type = "DateTime" }
    "Batch or Lot ID" = @{ Name = "BatchOrLotID"; Type = "Text" }
    "Currency" = @{ Name = "CurrencyCode"; Type = "Text" }
    "Invoice Total" = @{ Name = "InvoiceTotal"; Type = "Currency" }
    "Status" = @{ Name = "Status"; Type = "Text" }
}
$lineMap = @{
    "Invoice ID" = @{ Name = "InvoiceID"; Type = "Text" }
    "Sequence" = @{ Name = "Sequence"; Type = "Number" }
    "Description" = @{ Name = "Description"; Type = "Text" }
    "Quantity" = @{ Name = "Quantity"; Type = "Number" }
    "Unit Price" = @{ Name = "UnitPrice"; Type = "Currency" }
    "Amount" = @{ Name = "Amount"; Type = "Currency" }
    "Claimed Contract Reference" = @{ Name = "ClaimedContractReference"; Type = "Text" }
}
$qualityMap = @{
    "Supplier ID" = @{ Name = "SupplierID"; Type = "Text" }
    "Batch or Lot ID" = @{ Name = "BatchOrLotID"; Type = "Text" }
    "Event Status" = @{ Name = "EventStatus"; Type = "Text" }
    "Active Quality Hold" = @{ Name = "ActiveQualityHold"; Type = "Boolean" }
    "Product Impact" = @{ Name = "ProductImpact"; Type = "Text" }
    "Summary" = @{ Name = "Summary"; Type = "Text" }
}

Import-ILL224SeedData -List "Suppliers" -CsvName "Suppliers.csv" -ColumnMap $supplierMap
Import-ILL224SeedData -List "Supplier Invoices" -CsvName "SupplierInvoices.csv" -ColumnMap $invoiceMap
Import-ILL224SeedData -List "Invoice Lines" -CsvName "InvoiceLines.csv" -ColumnMap $lineMap
Import-ILL224SeedData -List "Quality Events" -CsvName "QualityEvents.csv" -ColumnMap $qualityMap

$documents = @(
    @{ FileName = "Caldova_Supplier_Invoice_Review_Policy.docx"; Type = "Policy"; Supplier = $null; Contract = $null; Date = "2026-07-01" },
    @{ FileName = "Caldova_Astor_Ridge_Manufacturing_Agreement.docx"; Type = "Contract"; Supplier = "SUP-1042"; Contract = "CMO-2026-041"; Date = "2026-08-01" },
    @{ FileName = "Caldova_Northwind_Packaging_Agreement.docx"; Type = "Contract"; Supplier = "SUP-1088"; Contract = "PKG-2026-052"; Date = "2026-01-01" },
    @{ FileName = "Astor_Ridge_Expedite_Approval.pdf"; Type = "Written Approval"; Supplier = "SUP-1042"; Contract = "CMO-2026-041"; Date = "2026-08-06" },
    @{ FileName = "Northwind_Label_Setup_Decision.pdf"; Type = "Procurement Decision"; Supplier = "SUP-1088"; Contract = "PKG-2026-052"; Date = "2026-08-18" },
    @{ FileName = "Caldova_Supplier_Quality_Exception.pdf"; Type = "Quality Record"; Supplier = "SUP-1042"; Contract = "CMO-2026-041"; Date = "2026-08-09" }
)

foreach ($document in $documents) {
    $metadata = @{
        DocumentType = $document.Type
        EffectiveDate = [datetime]$document.Date
        LabData = $true
    }
    if ($document.Supplier) { $metadata.SupplierID = $document.Supplier }
    if ($document.Contract) { $metadata.ContractID = $document.Contract }
    Add-ILL224Document -FileName $document.FileName -Metadata $metadata
}

if ($IncludeOptionalContent) {
    Add-ILL224Document -FileName "Caldova_Multi_Case_Supplier_Master.xlsx" -Optional -Metadata @{ DocumentType = "Reference"; LabData = $true }
    Add-ILL224Document -FileName "Caldova_Supplier_Governance_Briefing.pptx" -Optional -Metadata @{ DocumentType = "Reference"; LabData = $true }
}

Set-ILL224Permissions

Write-Host "ILL224 SharePoint provisioning completed for $SiteUrl" -ForegroundColor Green
Write-Host "Run this command again with -ValidateOnly to verify the site and seeded content."