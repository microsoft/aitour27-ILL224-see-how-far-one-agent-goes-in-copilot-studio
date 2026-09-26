<!-- markdownlint-disable MD034 -->

# @lab.Title

In this 60-minute hands-on lab, you will build a Supplier Assurance Agent for Caldova Pharmaceuticals with Copilot Studio and the GitHub Copilot harness.

## Workshop scenario

Caldova receives an invoice from Astor Ridge Biologics with charges that might exceed its contract. Before Finance processes it, a sourcing manager must compare the submitted invoice with current operational records, the governing agreement, written approvals, and any active quality hold.

Your agent will:

- read an Excel invoice you attach;
- retrieve current records through the SharePoint MCP;
- ground decisions in SharePoint contracts, policy, approvals, and quality documents;
- run reusable skills and packaged Python;
- create a PDF review brief;
- record a non-financial review log after you confirm; and
- build a simple workflow that reviews a second supplier request.

The agent never pays an invoice, rejects a charge, changes supplier status, or issues a quality hold. It recommends; an authorized person decides.

## Sign in to the virtual machine

The green text surrounded by `+++` can be selected to autotype into the virtual machine.

**Username:** +++@lab.CloudCredential(CSBatch1).Username+++

**Password:** +++@lab.CloudCredential(CSBatch1).Password+++

**Temporary Access Pass:** +++@lab.Variable(TAP)+++

> [!NOTE]
> If credentials are missing, select **Refresh Credentials**. Wait for autotype to finish before interacting with the VM.

## Verify your assigned resources

1. Confirm the Resources panel shows values for `POWER_PLATFORM_ENVIRONMENT`, `SHAREPOINT_SITE_URL`, and `REVIEW_REQUESTS_LIST_URL`. `SHAREPOINT_SITE_URL` should be the assigned tenant's root SharePoint URL.
1. Confirm the lab files exist at `C:\LabFiles\ILL224`.
1. Open Microsoft Edge.

> [!IMPORTANT]
> Use only the assigned account, environment, and SharePoint site. If a value does not match, stop and contact the facilitator.

Select **Next** to build the agent.
