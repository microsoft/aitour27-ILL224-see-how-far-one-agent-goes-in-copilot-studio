<!-- markdownlint-disable MD034 -->

# 2 - Add SharePoint Knowledge

Contracts, policy, approvals, and quality documents are are the sources that will govern the supplier reviews. You will connect the prepared SharePoint library as agent knowledge.

1. On the agent overview, find **Knowledge** and select **Add knowledge**.

    ![Select the add knowledge button](./assets/02.1-add-knowledge.png)

1. Select **SharePoint**.

    ![Select the SharePoint option](./assets/02.2-select-sharepoint.png)

1. Enter the assigned tenant root site URL then select **Add**:

    +++@lab.CloudCredential(AITour27M365E7).TenantPrefix+++

    ![Select the add button](./assets/02.3-add-button.png)

1. Review the knowledge details and select **Add to agent**.

    ![Select add to agent button](./assets/02.4-add-to-agent.png)

1. Confirm the knowledge source is now showing in the knowledge section. Select the **Save** icon in the upper right hand corner.

    ![Confirm knowledge](./assets/02.5-confirm-knowledge.png)

> [!NOTE]
> **Why:** Knowledge retrieves relevant information from governed documents. It's different from an MCP tool, which performs live operations against data.

## Test document knowledge grounding

1. Select the **Preview** tab at the top or your agent to open up the testing screen.

    ![Select the preview tab](./assets/02.6-preview-tab.png)

1. Paste the following in the **ask a question or describe what you need** box then press **Enter**:

    ```text
    Under contract CMO-2026-041, what is the maximum expedited-production premium for a $185,000 batch, and what approval is required above that amount?
    ```

    ![Test prompt](./assets/02.7-test-prompt.png)

1. Confirm the answer identifies 4%, `$7,400`, and the need for a revised purchase order and written VP approval.

    ![Review the response](./assets/02.8-prompt-response.png)

> [!TIP]
> Wording can vary. Validate the facts and source rather than expecting an exact sentence.

1. Click on each of the **Citations** shown below the response and verify where the answer came from.

    ![Review citations](./assets/02.9-citations.png)

1. Select the **Build** tab to go back to the configuration screen.

    ![Select the build tab](./assets/02.10-build-tab.png)

Select **Next** to continue with the lab to connect live SharePoint operations.
