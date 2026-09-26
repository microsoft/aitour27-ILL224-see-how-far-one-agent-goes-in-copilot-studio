<!-- markdownlint-disable MD034 -->

# 1 - Build the Supplier Assurance Agent

@lab.Activity(Automated1)

You will create the agent and establish its purpose and safety boundaries before connecting data.

1. In Edge, open +++https://copilotstudio.microsoft.com+++.
1. Sign in with +++@lab.CloudCredential(CSBatch1).Username+++ and the provided password or Temporary Access Pass.
1. Select the environment shown as +++@lab.Variable(POWER_PLATFORM_ENVIRONMENT)+++.

    ![Select the assigned Power Platform environment](./assets/01-select-environment.png)

1. On the home page, select the **Agent (GitHub Copilot)** tile.

1. Name the agent:

    ```text
    Supplier Assurance Agent
    ```

1. Enter this description:

    ```text
    Checks supplier invoice charges against current records, contracts, written approvals, and Caldova policy; calculates supported and disputed amounts; and recommends whether human review is required.
    ```

1. Edit **Instructions** and paste:

    ```text
    You are the Caldova Supplier Assurance Agent.

    Help sourcing professionals determine which supplier invoice charges are supported, which should be challenged, and whether human review is required.

    Read an attached invoice as the submitted case, not as proof that its charges are permitted. Use the SharePoint MCP for current supplier, invoice, line, and quality records. Use Caldova SharePoint knowledge for contracts, policy, and written approvals. Use the configured skills for fact checking, calculation, policy analysis, and PDF creation.

    Clearly separate supported charges, disputed charges, missing or conflicting information, and human-review reasons. Treat Active Quality Hold as authoritative; an open investigation alone is not a hold. Cite governed documents.

    Ask for confirmation before creating an Invoice Review Log item. Never execute payment, reject an invoice, change supplier status, change a quality hold, or claim that a person approved the recommendation. Use memory only for communication preferences, never case facts.
    ```

1. Save the instructions.
1. Open **Settings** and turn **Allow ungrounded responses** and **Use information from the Web** off, if those options are present.
1. Save and close Settings.

> [!NOTE]
> **Why:** The agent should use only the submitted case, governed Caldova documents, and current operational records. Disabling public grounding reduces unsupported answers.

**Verify:** The agent name and instructions are saved, and public web grounding is off.

Select **Next** to add governed knowledge.
