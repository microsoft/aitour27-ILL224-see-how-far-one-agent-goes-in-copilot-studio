# 5 - Evaluate and Publish the Agent

Preview explains one conversation. Evaluation checks saved expectations repeatedly after the agent changes.

## Enable preference-only memory

1. Return to the agent overview and turn **Memory** on.
1. Save the agent.
1. In a new test session, enter:

    ```text
    Remember that I am based in London. Use UK date and time conventions, and put anything that needs my attention first under a heading called My actions.
    ```

1. Start another test session. Without restating the preference, enter:

    ```text
    Give me the Astor Ridge ARB-260814 review result. Include the invoice date.
    ```

1. Confirm the response puts required attention under **My actions** and shows the invoice date using a UK format such as `14 August 2026`, not `08/14/2026`.
1. Confirm the amounts, status, and evidence still come from the file, knowledge, and MCP rather than memory.

> [!IMPORTANT]
> **Why:** Location, date format, and personal working style are durable user preferences. Supplier facts, approval limits, case decisions, and quality status can change and must never come from memory.

## Evaluate the configured agent

1. Open the agent's **Operate** area and select **Evaluations**.
1. Select **New evaluation**, then choose the option to import a test set.
1. Import:

    ```text
    C:\LabFiles\ILL224\evaluation\Supplier-Assurance-Baseline.csv
    ```

1. Name the evaluation `Supplier Assurance baseline`.
1. Confirm the import contains two conversations: the multi-turn Astor Ridge review and the `$10,000` human-review policy threshold.
1. Keep the default **General quality** test method. Add other test methods only if they are available and appropriate in the event tenant.
1. Review the reference responses so you understand the expected facts and guardrails. They guide your review but are not directly compared with the agent's responses.
1. Run the evaluation with the same learner connection used for SharePoint.
1. Inspect each result. Do not weaken an expected result merely to make a failure pass.

> [!NOTE]
> **Why:** A multi-turn conversation tests whether the agent maintains case context while preserving its grounding and action guardrails. General quality evaluates the conversation without requiring identical wording.

## Publish

1. Save the agent.
1. Select **Publish** and wait for completion.

**Verify:** The baseline has run, memory applies a user-specific regional and working preference across sessions, case facts remain grounded, and the agent is published.

Select **Next** to build the workflow.
