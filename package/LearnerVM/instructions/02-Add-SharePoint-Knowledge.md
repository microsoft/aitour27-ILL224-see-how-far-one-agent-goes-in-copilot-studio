<!-- markdownlint-disable MD034 -->

# 2 - Add SharePoint Knowledge

Contracts, policy, approvals, and quality documents are human-readable sources that govern the review. You will connect the prepared SharePoint library as agent knowledge.

1. On the agent overview, find **Knowledge** and select **Add knowledge**.
1. Select **SharePoint**.
1. Enter the assigned tenant root site URL:

    +++@lab.Variable(SHAREPOINT_SITE_URL)+++

1. Select the `Contracts` library.
1. Add it to the agent.
1. Confirm the source is connected or Ready.

> [!NOTE]
> **Why:** Knowledge retrieves relevant passages from governed documents. It is different from an MCP tool, which performs live operations against structured records.

## Test document grounding

1. Open the test pane and start a new session.
1. Ask:

    ```text
    Under contract CMO-2026-041, what is the maximum expedited-production premium for a $185,000 batch, and what approval is required above that amount?
    ```

1. Confirm the answer identifies 4%, `$7,400`, and the need for a revised purchase order and written VP approval.
1. Open the activity or citations and confirm the manufacturing agreement was used.

> [!TIP]
> Wording can vary. Validate the facts and source rather than expecting an exact sentence.

**Verify:** The answer cites Caldova’s agreement and does not use a public website.

Select **Next** to connect live SharePoint operations.
