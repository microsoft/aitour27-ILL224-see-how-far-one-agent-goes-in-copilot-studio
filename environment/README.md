# ILL224 Environment Setup

## Purpose

This runbook defines the cloud resources, Skillable image, sample data, connections, validation, and reset process required for **Caldova Supplier Assurance Agent**.

The learner must not create SharePoint sites, lists, Power Platform environments, or accounts during the 60-minute lab. The learner does create the simple Workflow.

## Seat architecture

Provision at least one complete seat for every concurrent learner plus a 10% hot-spare pool.

```text
Pooled account
  + Microsoft 365 and Copilot Studio licenses
  + isolated Power Platform environment
  + tenant root SharePoint site
  + populated document library and lists
  + Copilot Studio Workflows enabled
  + Skillable VM entitlement
```

Skillable may assign a prepared seat at launch. Do not create accounts, sites, or knowledge sources after launch. SharePoint processing and connection propagation are not deterministic enough for a timed session.

## Required services

- Microsoft Entra ID learner account
- SharePoint Online
- Copilot Studio with the GitHub Copilot harness, skills, sandbox code execution, file creation, memory, Agent Ops evaluation, and workflows enabled
- Stable SharePoint MCP visible in the Copilot Studio tool catalog
- Power Automate or Copilot Studio Workflows entitlement required by the final workflow action
- Sufficient Copilot Credit and service capacity for the full event load

## SharePoint site

Use the idempotent [SharePoint provisioning package](./sharepoint-provisioning/README.md) to create and seed this configuration in each assigned Microsoft 365 tenant.

Each seat has a unique Microsoft 365 tenant, so use its existing root SharePoint site instead of creating another site collection.

| Setting | Value |
| --- | --- |
| Name | Existing tenant root site |
| URL | `https://<tenant>.sharepoint.com` |
| Owner | Assigned learner account |
| Additional owners | Event support group |
| External sharing | Off |

Expose the URL as `SHAREPOINT_SITE_URL`.

### Document library

Create `Contracts`. Store every document at the root of the library; do not create folders.

Create columns:

| Column | Type | Values |
| --- | --- | --- |
| Document Type | Choice | Policy; Contract; Written Approval; Procurement Decision; Quality Record; Reference |
| Supplier ID | Single line of text | Supplier identifier or blank |
| Contract ID | Single line of text | Contract identifier or blank |
| Effective Date | Date only | Source effective or decision date |
| Lab Data | Yes/No | Default Yes |

Upload files from `package/SharePoint/core` and `package/SharePoint/optional`. Do not upload `.txt`, `.json`, or `.csv` files.

Core file metadata:

| File | Type | Supplier | Contract | Date |
| --- | --- | --- | --- | --- |
| `Caldova_Supplier_Invoice_Review_Policy.docx` | Policy | blank | blank | 2026-07-01 |
| `Caldova_Astor_Ridge_Manufacturing_Agreement.docx` | Contract | SUP-1042 | CMO-2026-041 | 2026-08-01 |
| `Caldova_Northwind_Packaging_Agreement.docx` | Contract | SUP-1088 | PKG-2026-052 | 2026-01-01 |
| `Astor_Ridge_Expedite_Approval.pdf` | Written Approval | SUP-1042 | CMO-2026-041 | 2026-08-06 |
| `Northwind_Label_Setup_Decision.pdf` | Procurement Decision | SUP-1088 | PKG-2026-052 | 2026-08-18 |
| `Caldova_Supplier_Quality_Exception.pdf` | Quality Record | SUP-1042 | CMO-2026-041 | 2026-08-09 |

### Lists

Create six lists. Seed CSVs are in `package/SharePoint-Lists/seed-data`.

#### Suppliers

`Title` (supplier name), `Supplier ID` (unique text), `Status` (Active/Conditional/Inactive), `Risk Tier` (Low/Medium/High), `Contract ID`, `Payment Terms`, and `Eligible for Standard Controls` (Yes/No).

#### Supplier Invoices

`Title` (unique invoice ID), `Supplier ID`, `Supplier Name`, `Purchase Order`, `Contract ID`, `Invoice Date`, `Batch or Lot ID`, `Currency`, `Invoice Total` (currency), and `Status` (Pending Review/Review Requested/Review Complete).

#### Invoice Lines

`Title`, `Invoice ID` (indexed), `Sequence`, `Description`, `Quantity`, `Unit Price`, `Amount`, and `Claimed Contract Reference`.

#### Quality Events

`Title` (event ID), `Supplier ID`, `Batch or Lot ID`, `Event Status` (Open/Closed), `Active Quality Hold` (Yes/No), `Product Impact` (Yes/No/Under Review), and `Summary`.

#### Invoice Review Requests

`Title`, `Invoice ID`, `Request Notes`, `Status` (New/Processing/Awaiting Human Review/Complete/Failed), `Agent Response`, and `Error Detail`. Leave empty.

#### Invoice Review Log

`Title`, `Invoice ID` (indexed), `Supported Amount`, `Disputed Amount`, `Human Review Required`, `Recommendation`, `Review Source` (Interactive Agent/Workflow), and `Review Document Name`. Leave empty.

Learners receive Read access to Suppliers, Invoice Lines, Quality Events, and Contracts. They receive Contribute access to Supplier Invoices, Invoice Review Requests, and Invoice Review Log so the MCP can advance invoice status and record review activity. Disable delete operations in the MCP tool configuration.

## SharePoint MCP

The learner creates the MCP connection during the lab. The tenant and site must allow these operations:

- read Suppliers;
- read and update Supplier Invoices;
- read Invoice Lines;
- read Quality Events;
- read, create, and update Invoice Review Requests; and
- read, create, and update Invoice Review Log items.

Disable delete, schema changes, file sharing, and unrelated writes. Validate the exact operation labels in the event tenant before capturing screenshots.

## SharePoint knowledge

The learner adds the prepared site or `Contracts` library as knowledge. Validate retrieval with the learner account before marking a seat ready.

Required facts:

- Astor Ridge expedite cap: 4% of `$185,000`, or `$7,400`.
- No approval exists for the additional expedite amount or `$5,700` documentation fee.
- Northwind label setup allowance: `$8,000`.
- Northwind rush changeover lacks contract coverage and written approval.
- Human review threshold: disputed amount greater than `$10,000`.

## Learner-built Copilot Studio Workflow

Learners build the automation from scratch in the new Copilot Studio **Workflows** experience. Use [COPILOT_STUDIO_WORKFLOW_SETUP.md](./COPILOT_STUDIO_WORKFLOW_SETUP.md) to validate the experience before release. Do not prepare or import a Workflow package, and do not substitute a Power Automate cloud flow.

The learner creates three nodes:

1. Trigger when an item is created in `Invoice Review Requests`.
2. Run the published Supplier Assurance Agent using the trigger's Invoice ID and Request Notes.
3. Update the request with the readable agent response and Status `Complete`.

The Workflow does not retrieve or reshape invoice data because the agent uses the SharePoint MCP for that work.

## Skillable VM image

Place the complete `package/LearnerVM` content under:

```text
C:\LabFiles\ILL224
```

Required local files:

- `case-inputs\Caldova_Astor_Ridge_Invoice.xlsx`
- `skills\invoice-review-decision.zip`
- `evaluation\Supplier-Assurance-Baseline.csv`
- the student instruction folder
- local recovery copies of all SharePoint documents

> [!NOTE]
> The finished agent has two skills, but only one skill ZIP is expected on the VM. Learners create `invoice-fact-check` from blank in Copilot Studio to practice skill authoring. They upload `invoice-review-decision.zip` because that skill includes the packaged `calculate_supplier_review.py` resource.

The image must contain no cached Microsoft identity, browser synchronization, refresh token, or administrator connection.

## Skillable variables

| Variable | Purpose |
| --- | --- |
| `LAB_USER_UPN` | Learner sign-in identity |
| `LAB_USER_PASSWORD` | Secret handled by Skillable |
| `TAP` | Temporary Access Pass when required |
| `POWER_PLATFORM_ENVIRONMENT` | Exact environment name and URL |
| `SHAREPOINT_SITE_URL` | Tenant root URL, such as `https://contoso.sharepoint.com` |
| `REVIEW_REQUESTS_LIST_URL` | Direct link to `Invoice Review Requests` on the tenant root site |
| `SKILL_PACKAGE_PATH` | Path to `invoice-review-decision.zip` |
| `EVALUATION_PATH` | Path to the evaluation CSV |
| `SEAT_ID` | Support and reset correlation ID |

The provisioning lifecycle also requires `ILL224SharePointTenantName`, `ILL224PnPCertificateBase64`, and `ILL224PnPCertificatePassword`. These are operator-only inputs and must not be exposed to learners or retained in the VM image. See the [SharePoint provisioning package](./sharepoint-provisioning/README.md) for the unattended Skillable command and Entra application requirements.

## Provisioning order

1. Create and license pooled learner accounts.
2. Create or assign isolated Power Platform environments.
3. Create each account's SharePoint site, library, columns, and lists.
4. Upload Office/PDF documents and apply metadata.
5. Seed four reference lists; leave the two review lists empty.
6. Apply permissions.
7. Confirm the learner can create SharePoint and Run an agent connections in Copilot Studio Workflows.
8. Wait for SharePoint knowledge processing.
9. Build the immutable VM image and bind each account/site/environment/VM bundle in the seat manifest.
10. Run readiness validation and expose only passing seats.

## Readiness validation

For every seat, confirm:

- all portals use the same learner identity;
- the correct Power Platform environment is selected;
- six core documents and optional content exist with no `.txt`, `.json`, or `.csv` library files;
- all five required knowledge facts are retrievable;
- the four reference lists contain expected rows;
- both review lists are empty;
- SharePoint MCP reads work and one disposable review-log item can be created but not deleted by the MCP;
- the disposable item is removed by support;
- the learner can create and save a disposable three-node Workflow, and support removes it after validation;
- all local VM files exist and match `checksums.sha256`; and
- the Astor Ridge and Northwind golden-path results match the presenter guide.

## Reset

After a session, delete learner-created agents, skills, evaluations, Workflows and their runs, review requests, and review-log items. Restore invoice statuses, verify reference documents and rows, clear browser state, rerun readiness checks, and only then return the seat to the pool.

## Release gates

- Validate that learners can build, publish, and run the three-node Workflow in the event version of Copilot Studio Workflows.
- Validate evaluation CSV import against the actual Agent Ops schema.
- Capture screenshots after the final Copilot Studio UI is confirmed.
- Load-test MCP and workflow operations at 25, 50, 100, and expected peak concurrency.
- Keep at least 10% validated hot spares.
