# Copilot Studio Workflow Setup

Use this runbook to validate the simple automation that learners build in the new **Copilot Studio Workflows** experience. Do not prepare or import a Workflow package, and do not build it as a Power Automate cloud flow.

The Workflow has one responsibility: detect a new supplier review request, invoke the published agent, and save the readable response on the request.

```text
SharePoint request created
  -> Run an agent
  -> Update the request
```

The Workflow does not retrieve invoice lines, calculate amounts, parse the agent response, apply policy, or create a review log. The Supplier Assurance Agent already performs research through the SharePoint MCP, grounds its answer in SharePoint knowledge, and runs both skills.

## Why this design is intentionally small

- **No Select:** the Workflow does not reshape invoice lines. It passes the invoice identifier to the agent, which retrieves current records through MCP.
- **No Compose:** the Run an agent message can contain trigger fields and instructions directly.
- **No Parse JSON:** the Workflow distributes the agent's readable response; it does not route on individual financial fields.
- **No duplicated policy:** thresholds and review rules remain in the uploaded skill and governed policy document.
- **No Workflow review-log write:** the interactive exercise already demonstrates the controlled MCP write. The Workflow records its result on the request item.

This division is the lesson: the Workflow handles predictable orchestration, while the agent handles adaptive investigation and reasoning.

## What the agent message does

The message tells the agent which case to review and what a useful response must contain. It does not prepare or transform business data.

Only these trigger values are passed:

- Invoice ID;
- Request title; and
- Request notes.

The agent then uses the Invoice ID to retrieve the current invoice, lines, supplier, and quality records through the SharePoint MCP.

## Prerequisites

Confirm in the event tenant that Copilot Studio Workflows provides:

- SharePoint **When an item is created**;
- **Run an agent** under AI capabilities;
- SharePoint **Update item**.

Also confirm:

- the learner's `Supplier Assurance Agent` can be selected after publication;
- the SharePoint MCP can read Suppliers, Supplier Invoices, Invoice Lines, and Quality Events;
- SharePoint knowledge contains the Northwind agreement and procurement decision;
- `Invoice Review Requests` contains the fields defined in [README.md](./README.md); and
- `NWT-260821` and its four lines are present in the prepared lists.

Use the same learner identity for SharePoint and Copilot Studio connections.

## Build the Workflow

### 1. Create the Workflow

1. Sign in to Copilot Studio and select the event authoring environment.
2. Select **Workflows** in the left navigation.
3. Select **New workflow**.
4. Name it:

   ```text
   Process Supplier Invoice Review Request
   ```

### 2. Configure the SharePoint trigger

1. Select the start node.
2. Set **Trigger type** to **Connector**.
3. Select SharePoint **When an item is created**.
4. Configure:

   | Field | Value |
   | --- | --- |
   | Site Address | Prepared tenant root SharePoint site |
   | List Name | `Invoice Review Requests` |

Use **When an item is created**, not **created or modified**. The Workflow updates the same request later and must not trigger itself again.

### 3. Add Run an agent

Add **Run an agent** under **AI capabilities** and select a published validation copy of the Supplier Assurance Agent.

In the **Message** field, enter the text below. Replace each bracketed value with dynamic content from the SharePoint trigger.

```text
A new supplier invoice review was requested.

Invoice ID: [Invoice ID]
Request title: [Title]
Request notes: [Request Notes]

Use the SharePoint MCP to retrieve the current invoice, invoice lines, supplier record, and quality-event record. Use Caldova SharePoint knowledge for the governing contract, written approvals, and invoice-review policy. Run the configured Invoice Fact Check and Invoice Review Decision skills.

Return a concise readable response with:
- supported amount;
- disputed amount;
- reconciliation difference;
- whether human review is required and every reason;
- recommendation;
- evidence citations; and
- the statement that no payment, invoice rejection, supplier change, or quality-hold change was made.
```

The message provides the case identifier and response requirements. It does not carry invoice data or business rules.

### 4. Update the request

Add SharePoint **Update item** directly below Run an agent.

| Field | Value |
| --- | --- |
| Site Address | Same Caldova site as the trigger |
| List Name | `Invoice Review Requests` |
| Id | Trigger `ID` |
| Title | Trigger `Title` |
| Invoice ID | Trigger `Invoice ID` |
| Request Notes | Trigger `Request Notes` |
| Status | `Complete` |
| Agent Response | Final readable response from Run an agent |
| Error Detail | Blank |

Preserve required trigger values in Update item so they are not cleared.

The Workflow deliberately uses one final `Complete` state. Whether a person must review the recommendation appears in the agent response; the Workflow does not parse or independently reinterpret that decision.

### 5. Save and publish

1. Save the Workflow.
2. Run the Workflow checker.
3. Resolve connection and configuration errors.
4. Publish or turn on the Workflow.

## Prepare the learner environment

Do not create or import the Workflow for the learner. Confirm only that Workflows is available and that the learner can create SharePoint and Run an agent connections with the assigned identity. Delete the operator's validation Workflow before the seat is released.

## Validate the golden path

1. Publish a fully configured Supplier Assurance Agent.
2. Turn on the Workflow.
3. Create this request in `Invoice Review Requests`:

   | Field | Value |
   | --- | --- |
   | Title | `Review NWT-260821` |
   | Invoice ID | `NWT-260821` |
   | Request Notes | `Review charges against current records, contract, approvals, policy, and quality holds.` |
   | Status | `New` |

4. Confirm exactly one Workflow run starts.
5. Confirm Run an agent uses the SharePoint MCP, SharePoint knowledge, and both skills.
6. Confirm the final response reports:
   - invoice total `$122,300`;
   - supported `$108,800`;
   - disputed `$13,500`;
   - reconciliation difference `$0`;
   - no active quality hold; and
   - human review required.
7. Confirm the request Status becomes `Complete` and Agent Response contains the readable result.
8. Confirm no invoice, supplier, review-log, or quality record was modified.

## Release gates

- Confirm the learner can create all three nodes in the event tenant.
- Confirm the final response output from Run an agent maps directly to Update item.
- Capture screenshots only after the Workflow-native design passes in a clean learner environment.
- Delete the validation Workflow before releasing the learner environment.
