# ILL224 SharePoint Provisioning

This package recreates the SharePoint portion of an ILL224 learner seat. It is intended for the Skillable or Microsoft 365 provisioning team, not for learners.

It configures an existing site or creates and updates a dedicated site. For the one-tenant-per-seat Skillable architecture, the existing tenant root site is preferred. It creates or updates:

- the `Caldova Supplier Operations` site;
- the `Contracts` library, with all documents stored at its root;
- the Document Type, Supplier ID, Contract ID, Effective Date, and Lab Data library columns;
- Suppliers, Supplier Invoices, Invoice Lines, and Quality Events with seed rows;
- empty Invoice Review Requests and Invoice Review Log lists;
- learner Read permissions on immutable reference content; and
- learner Contribute permissions on Supplier Invoices and the two review lists.

The script is idempotent. Running it again updates matching seed rows and root-level documents instead of creating duplicates. It does not create folders in `Contracts`.

The script is also non-destructive. If a tenant was previously provisioned with the former `Contracts and Approvals` library, the script creates `Contracts` but does not delete the old library. Use a fresh test tenant or remove the obsolete library after confirming that nothing still depends on it.

## SharePoint Result

Each Skillable tenant uses its existing root site at:

```text
https://<tenant>.sharepoint.com
```

Because every lab seat uses a unique tenant, the root site is already isolated to that learner. It contains one document library and six lists:

| Resource | Initial content |
| --- | --- |
| `Contracts` | Six core documents and, when selected, two optional documents |
| `Suppliers` | Four rows from `Suppliers.csv` |
| `Supplier Invoices` | Four rows from `SupplierInvoices.csv`, each with Status `Pending Review` |
| `Invoice Lines` | Sixteen rows from `InvoiceLines.csv`, four per invoice |
| `Quality Events` | Four rows from `QualityEvents.csv`, one matching each invoice batch |
| `Invoice Review Requests` | Empty; its CSV contains headers only |
| `Invoice Review Log` | Empty; its CSV contains headers only |

The script defines SharePoint column types explicitly instead of relying on CSV type inference. CSV rows are matched by `Title`, so later runs update matching rows.

### Contracts library

The `Contracts` library has no custom folders. Every file is uploaded to the library root with these columns:

| Column | SharePoint type | Purpose |
| --- | --- | --- |
| Document Type | Choice | Policy, contract, approval, decision, quality record, or reference |
| Supplier ID | Single line of text | Related supplier when applicable |
| Contract ID | Single line of text | Related agreement when applicable |
| Effective Date | Date and time | Governing or decision date |
| Lab Data | Yes/No | Identifies fictional lab content |

The six core files are always uploaded. `-IncludeOptionalContent` also uploads the XLSX supplier master and PPTX governance briefing. Uploading an existing filename replaces its content and reapplies its metadata.

## Script Parameters

| Parameter | Required | Description |
| --- | --- | --- |
| `Tenant` | Yes | Tenant domain or tenant ID used during PnP authentication |
| `AdminUrl` | Yes | SharePoint admin URL, such as `https://contoso-admin.sharepoint.com` |
| `SiteUrl` | Yes | Existing or target SharePoint site URL |
| `LearnerUpn` | Yes | Learner account that owns and uses the site |
| `ClientId` | Yes | Approved Entra application ID for PnP authentication |
| `AuthenticationMode` | No | `Interactive` by default; use `Certificate` for unattended Skillable provisioning |
| `CertificateBase64Encoded` | Certificate mode | Base64-encoded PFX containing the app certificate and private key |
| `CertificatePassword` | Certificate mode | PFX password supplied as a PowerShell `SecureString` |
| `SiteTitle` | No | Site display name; defaults to `Caldova Supplier Operations` |
| `PackageRoot` | No | Package directory; defaults to `ILL224/package` |
| `IncludeOptionalContent` | No | Uploads the two optional reference files |
| `UseExistingSite` | No | Connects directly to `SiteUrl` and skips all tenant-admin site lookup and creation calls |
| `ValidateOnly` | No | Verifies that expected resources and seeded items exist without provisioning |

## Provisioning Sequence

The script:

1. Confirms PnP.PowerShell and every selected source file are available.
2. Connects directly to the existing site when `UseExistingSite` is specified. Otherwise, it uses the SharePoint admin center to create a modern team site without a Microsoft 365 group when absent.
3. Creates the `Contracts` library and its typed columns.
4. Creates all six lists and their typed columns, repairs missing choice values, and places custom columns in each default view.
5. Validates CSV statuses and relationships, then creates or updates the four sets of reference rows.
6. Uploads documents to the root of `Contracts` and applies metadata.
7. Grants the learner Read access to immutable reference content and Contribute access to Supplier Invoices and the two review lists.

## Prerequisites

- PowerShell 7.4 or later.
- PnP.PowerShell 2.12 or later.
- A Microsoft Entra application configured for PnP.PowerShell interactive or certificate authentication.
- SharePoint Administrator rights in the target tenant.
- Admin consent for the application in every target tenant.
- The complete `ILL224/package` directory beside the environment directory.

Install the module:

```powershell
Install-Module PnP.PowerShell -Scope CurrentUser
```

PnP interactive sign-in requires an Entra application client ID. The tenant provisioning team should supply its approved client ID; do not embed a secret in this package or in the learner VM.

For unattended execution, the application needs a certificate credential and the SharePoint application permissions required by the script. Because the script creates a site and changes permissions, use `Sites.FullControl.All` during provisioning. A Global Administrator must grant admin consent in every tenant. Remove or reduce the application's access after the seat is provisioned if the provisioning identity is not also used for reset.

## Provision One Seat

Run from the `ILL224` directory:

```powershell
./environment/sharepoint-provisioning/Provision-ILL224SharePoint.ps1 `
  -Tenant "contoso.onmicrosoft.com" `
  -AdminUrl "https://contoso-admin.sharepoint.com" `
  -SiteUrl "https://contoso.sharepoint.com" `
  -LearnerUpn "learner001@contoso.onmicrosoft.com" `
  -ClientId "00000000-0000-0000-0000-000000000000" `
  -UseExistingSite `
  -IncludeOptionalContent
```

Site creation is asynchronous. The script uses `New-PnPSite -Type TeamSiteWithoutMicrosoft365Group`, prints a waiting message every 15 seconds, and allows up to 15 minutes for SharePoint to make the site available. If the target URL belongs to a deleted site, the script stops with instructions to restore or permanently delete that site in the SharePoint admin center.

PnP.PowerShell 3.x defaults SharePoint HTTP requests to 100 seconds, which can also affect `Get-PnPTenantSite`. Before loading PnP or connecting, the script sets the supported `SharePointPnPHttpTimeout` environment variable to 600 seconds. Override it with `-HttpTimeoutSeconds` when needed. After a run has already timed out, start a fresh PowerShell session before retrying so the previous PnP HTTP client is not reused.

After provisioning, verify the seat:

```powershell
./environment/sharepoint-provisioning/Provision-ILL224SharePoint.ps1 `
  -Tenant "contoso.onmicrosoft.com" `
  -AdminUrl "https://contoso-admin.sharepoint.com" `
  -SiteUrl "https://contoso.sharepoint.com" `
  -LearnerUpn "learner001@contoso.onmicrosoft.com" `
  -ClientId "00000000-0000-0000-0000-000000000000" `
  -UseExistingSite `
  -IncludeOptionalContent `
  -ValidateOnly
```

## Multi-Tenant Skillable Use

If every lab seat receives a separate Microsoft 365 tenant, run the script once in each tenant before the tenant enters the Skillable ready pool. Each tenant must consent to the provisioning application and provide a SharePoint administrator identity.

The included `lifecycle_sharepoint_provisioning.ps1` follows the same Skillable substitution pattern used by the reference LAB532 lifecycle script:

```powershell
$clientId = "@lab.CloudSubscription.AppId"
$tenantId = "@lab.CloudSubscription.TenantId"
$learnerUpn = "@lab.CloudPortalCredential(User1).Username"
```

Configure these additional secret-backed lab variables:

| Skillable variable | Purpose |
| --- | --- |
| `ILL224SharePointTenantName` | SharePoint host prefix, for example `contoso` |
| `ILL224PnPCertificateBase64` | One-line Base64 representation of the app's PFX certificate |
| `ILL224PnPCertificatePassword` | Password protecting that PFX certificate |

The CloudSubscription application must exist in the Microsoft 365 tenant, have its certificate's public key uploaded, hold admin-consented SharePoint `Sites.FullControl.All` application permission, and be authorized to create tenant sites. The accounts being Global Administrators is sufficient for initial registration and consent, but the unattended lifecycle run authenticates as the application, not as the administrator account.

Do not pass `@lab.CloudSubscription.AppSecret` to `Connect-PnPOnline`. LAB532 can use that secret because it requests a Microsoft Graph token directly. Modern PnP SharePoint app-only authentication uses a certificate.

Place the wrapper beside `Provision-ILL224SharePoint.ps1` and invoke it with PowerShell 7 from the Skillable lifecycle action:

```powershell
pwsh.exe -NoLogo -NoProfile -File "C:\LabFiles\ILL224\environment\sharepoint-provisioning\lifecycle_sharepoint_provisioning.ps1"
```

The wrapper fails before connecting if a substitution is unresolved and writes operational output to `C:\Users\LabUser\Desktop\ill224-sharepoint-provisioning.log`. Run this during seat preparation, not learner launch, so SharePoint and Copilot knowledge indexing can finish before the lab begins.

This package assumes every seat has a unique tenant. If that architecture changes and seats share a tenant, restore unique site URLs for each seat. Never assign a learner a site created for a different seat.

## Package Layout

Keep the provisioning script and package directories in their supplied relative locations:

```text
ILL224/
  environment/sharepoint-provisioning/
    Provision-ILL224SharePoint.ps1
    lifecycle_sharepoint_provisioning.ps1
    README.md
  package/
    SharePoint/core/
    SharePoint/optional/
    SharePoint-Lists/seed-data/
```

The local `core` and `optional` directories control which files are uploaded. They are source-package directories only and are not reproduced as folders in SharePoint.

## Test a Tenant

Use a disposable tenant first. Run the provisioning command, run it a second time to test repeatability, and then run the `-ValidateOnly` command. In SharePoint, confirm:

- the configured URL is the tenant root site;
- `Contracts` contains six root-level files, or eight with optional content;
- `Contracts` has no custom folders;
- each document displays the expected metadata;
- Suppliers, Supplier Invoices, Invoice Lines, and Quality Events contain 4, 4, 16, and 4 rows respectively;
- the `Status` column is visible in the default views for Suppliers, Supplier Invoices, and Invoice Review Requests;
- all four Supplier Invoices have Status `Pending Review`, and each invoice total equals the sum of its lines;
- Invoice Review Requests and Invoice Review Log are empty; and
- the learner can update Supplier Invoices and create or update items in the two review lists.

Finally, add `Contracts` as a Copilot Studio knowledge source and verify that the Astor Ridge agreement can be retrieved. SharePoint indexing is asynchronous, so allow processing time before declaring the tenant ready.

The Skillable seat record must expose at least:

```text
LAB_USER_UPN
POWER_PLATFORM_ENVIRONMENT
SHAREPOINT_SITE_URL
REVIEW_REQUESTS_LIST_URL
SEAT_ID
```

Do not place provisioning credentials, application secrets, certificates, refresh tokens, or tenant administrator sessions in the saved VM image.

## Scope Boundary

This script provisions SharePoint only. Copilot Studio environments require separate Power Platform provisioning, and learners build the Workflow during the lab. SharePoint search and Copilot knowledge indexing can remain asynchronous after upload, so provision and validate seats before learner launch rather than running this script during the timed lab.
