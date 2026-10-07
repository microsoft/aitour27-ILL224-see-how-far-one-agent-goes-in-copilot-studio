<!-- markdownlint-disable MD034 -->

# @lab.Title

In this lab, you'll build a Supplier Assurance Agent for Caldova Pharmaceuticals with Copilot Studio and the GitHub Copilot harness.

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

The green text with the +++icon+++ can be clicked on and will be typed automatically into the VM, For example, please click in the password text box and then click the password: +++Passw0rd!++ to login to the Virtual Machine.

[!note] To ensure text is entered accurately avoid interacting or clicking in the VM until the text has finished being typed

## Verify your assigned resources

1. Confirm the Resources panel shows values for **ADMINISTRATIVE USERNAME** and **TEMPORARY ACCESS PASS**. You'll need these to login to the Microsoft 365 account.
1. Confirm the lab files exist in your Virtual Machine's hard drive at `D:\LabFiles\ILL224`.
1. Open Microsoft Edge.

> [!NOTE]
> If credentials are missing, select **Refresh Credentials**. Wait for autotype to finish before interacting with the VM.

Ready to get started? Click **Next**.
