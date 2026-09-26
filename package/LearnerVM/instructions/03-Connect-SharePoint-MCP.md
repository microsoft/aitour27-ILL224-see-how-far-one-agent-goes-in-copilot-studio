<!-- markdownlint-disable MD034 -->

# 3 - Connect the SharePoint MCP

## What is MCP?

Model Context Protocol exposes a menu of operations an agent can discover and call. In this lab, SharePoint knowledge reads governed documents, while the SharePoint MCP reads current list records and records a review result.

1. Open the agent's **Tools** area and select **Add a tool**.
1. Select **Model Context Protocol**, search for `SharePoint`, and select the prepared SharePoint MCP.
1. Create or select the connection owned by +++@lab.CloudCredential(CSBatch1).Username+++.
1. Add and configure the MCP.
1. Keep only the operations needed to:
   - read Suppliers;
   - read Supplier Invoices;
   - read Invoice Lines;
   - read Quality Events;
   - read, create, or update Invoice Review Requests;
   - update Supplier Invoices; and
   - read, create, or update Invoice Review Log items.
1. Turn off delete operations and all other writes.
1. Save the tool configuration.

> [!IMPORTANT]
> **Why:** Least privilege lets the agent investigate a case, submit a review request, and later record a recommendation without changing invoice payment state, supplier status, documents, or quality holds.

## Start a supplier invoice review

1. Start a new test session and ask:

    ```text
    Astor Ridge Biologics has asked Caldova to review invoice ARB-260814, specifically the expedited production premium, cold-chain freight, and validation documentation charges.

    Use the SharePoint MCP to verify that the supplier is active and whether batch CDV-AX47 has an active quality hold. If the supplier is active and there is no active hold:
    1. Update invoice ARB-260814 from Pending Review to Review Requested.
    2. Look for an Invoice Review Requests item whose Title is Astor Ridge invoice review - ARB-260814. If it does not exist, create it. If it already exists, update it instead so there is only one request.
    3. Set Invoice ID to ARB-260814, Request Notes to Review the expedited production premium, cold-chain freight, and validation documentation charges against the contract, approvals, policy, and quality records, and Status to New.

    Read the invoice and request back from SharePoint. Report the supplier and quality checks, the invoice's new status, the request item ID, and whether you created or updated the request. Do not analyze the contract or decide which charges are supported yet. I confirm that you may make these SharePoint updates.
    ```

1. If prompted, open connection manager, connect the prepared SharePoint connection, and retry.
1. Confirm the response reports an active supplier, no active quality hold, invoice status `Review Requested`, and the request item ID.
1. Open `Supplier Invoices` in SharePoint and verify ARB-260814 has Status `Review Requested`.
1. Open `Invoice Review Requests` and verify one `Astor Ridge invoice review - ARB-260814` item has Status `New` and the specified request notes.
1. Inspect the activity map and confirm the SharePoint MCP read and write operations ran.

**Verify:** The live invoice and request records changed in SharePoint. Knowledge can retrieve contract passages, but the MCP tool performs the operational updates that start the review.

Select **Next** to add reusable skills.
