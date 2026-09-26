# 6 - Build the Workflow

Create a small Copilot Studio Workflow that starts an invoice review when a SharePoint request is added. The Workflow only orchestrates the work; your agent retrieves records, applies policy, and produces the response.

## Create the Workflow

1. Open **Workflows** in Copilot Studio.
1. Select **New workflow**.
1. Name it `Process Supplier Invoice Review Request`.

## Add the SharePoint trigger

1. Select the start node and choose SharePoint **When an item is created**.
1. Create or select the learner-owned SharePoint connection.
1. Set **Site Address** to the prepared tenant root SharePoint site.
1. Set **List Name** to `Invoice Review Requests`.

> [!IMPORTANT]
> Use **When an item is created**, not **created or modified**. The Workflow updates the request later and must not trigger itself again.

## Run the agent

1. Add **Run an agent** under AI capabilities.
1. Create or select the learner-owned connection and choose the published `Supplier Assurance Agent`.
1. In **Message**, enter the text below. Replace each bracketed value with dynamic content from the SharePoint trigger.

    ```text
    Review supplier invoice [Invoice ID].

    Request notes: [Request Notes]

    Use the SharePoint MCP for current invoice, line, supplier, and quality records. Use Caldova SharePoint knowledge for the governing contract, approvals, and policy. Run both configured skills.

    Return supported and disputed amounts, reconciliation difference, human-review status and reasons, evidence citations, and a statement that no financial or supplier action was taken.
    ```

## Update the request

1. Add SharePoint **Update item** below **Run an agent**.
1. Set **Site Address** and **List Name** to the same site and `Invoice Review Requests` list.
1. Map **Id**, **Title**, **Invoice ID**, and **Request Notes** from the trigger.
1. Set **Status** to `Complete`.
1. Map **Agent Response** to the final response from **Run an agent** and leave **Error Detail** blank.
1. Save the Workflow, run the checker, and resolve every connection or mapping error.
1. Publish or turn on the Workflow.

> [!NOTE]
> **Why:** The three-node Workflow provides a predictable trigger and stores the result. The agent owns MCP retrieval, knowledge grounding, skill execution, and policy reasoning, so no Select, Compose, Parse JSON, or email action is needed.

**Verify:** The Workflow is on, contains exactly the SharePoint trigger, Run an agent, and Update item, and the checker reports no errors.

Select **Next** to run the Northwind transfer case.
