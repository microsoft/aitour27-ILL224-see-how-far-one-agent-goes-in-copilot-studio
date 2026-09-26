<!-- markdownlint-disable MD034 -->

# 3 - Connect the SharePoint MCP

## What is MCP?

Model Context Protocol exposes a menu of operations an agent can discover and call. In this lab, SharePoint knowledge reads documents, while the SharePoint MCP reads current list records and records a review result.

1. Select the **Plus button** in the **Tools** section.

    ![Select the add button](./assets/03.1-add-tool.png)

1. Select the **MCP** tab.

    ![Select the MCP tab](./assets/03.2-mcp-tab.png)

1. Type `SharePoint` in the text box, and select the prepared SharePoint MCP.

    ![Select the SharePoint MCP](./assets/03.3-select-sharepoint-mcp.png)

1. Select the **Add** button.

    ![Select the add button](./assets/03.4-add-mcp.png)

1. Select the **SharePoint** pill under **Tools** that was just added to open the configuration screen.

    ![Select the SharePoint tool](./assets/03.5-select-added-tool.png)

1. Select the **Allow all** radio button to toggle it to off.

    ![Toggle off allow all](./assets/03.6-allow-all-off.png)

1. Toggle all of the list of tools back to **On** EXCEPT the following:
   - Create list
   - Delete list item
   - Delete list
   - Delete file or folder
   - Delete column
   - Create column
   - Share file or folder
1. Confirm **Create list item**, **Update list item**, and the list-reading tools are **On**. You will need those for the lab and don't want them accidentally turned off.
1. Review and select the **Done** button.

    ![Change the tool capabilities](./assets/03.7-change-tool-selections.png)

1. Select the **Save** icon to save your changes.

    ![Save the changes](./assets/03.8-save.png)

> [!IMPORTANT]
> **Why:** Least privilege lets the agent investigate a case, submit a review request, and later record a recommendation without the ability to do destructive actions like deleting files.

## Start a supplier invoice review

1. Select the **Preview** tab to go back to the testing screen.

    ![Test the changes](./assets/03.9-preview-tab.png)

1. Select the **New chat** button. Copy and paste the following into the text box and press **Enter**.

    ```text
    Astor Ridge Biologics has asked us to review invoice ARB-260814.

    Verify that the supplier is active and whether batch CDV-AX47 has an active quality hold. If the supplier is active and there is no active hold:
    1. Update invoice ARB-260814 from Pending Review to Review Requested.
    2. Look for an Invoice Review Requests item whose Title is Astor Ridge invoice review - ARB-260814. If it does not exist, create it. If it already exists, update it instead so there is only one request.
    3. Set Invoice ID to ARB-260814, Request Notes to Review the expedited production premium, cold-chain freight, and validation documentation charges against the contract, approvals, policy, and quality records, and Status to New.

    Read the invoice and request back. Report the supplier and quality checks, the invoice's new status, the request item ID, and whether you created or updated the request. Do not analyze the contract or decide which charges are supported yet.
    ```

    ![Enter the request](./assets/03.10-test-prompt.png)

1. If prompted, select **Approve** in the **Permission Required** message to call the SharePoint MCP.

    ![Approve the request](./assets/03.11-approve-mcp.png)

1. Confirm the response reports an active supplier, no active quality hold, invoice status `Review Requested`, and the request item ID.

    ![Review the response](./assets/03.12-review-response.png)

1. Open `Invoice Review Requests` and verify one `Astor Ridge invoice review - ARB-260814` item has Status `New` and the specified request notes.

    ![Review the list](./assets/03.13-view-list-item.png)

1. Select the **Build** tab to go back to the configuration screen.

    ![GO back to the build tab](./assets/03.14-build-tab.png)

Select **Next** to add reusable skills.
