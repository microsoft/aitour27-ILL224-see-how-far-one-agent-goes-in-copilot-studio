# ILL224 Presenter Guide

## Session promise

Participants will build one useful agent that combines a submitted Excel invoice, grounded SharePoint documents, live SharePoint MCP operations, reusable skills, sandboxed Python, generated files, evaluation, memory, and workflow automation.

## Audience

The lab is designed for business users, makers, developers, and technical decision makers. Explain business terms before product terms and avoid assuming Power Platform experience.

## Story in one minute

Caldova Pharmaceuticals receives a supplier invoice with charges that may exceed its contract. The sourcing manager currently checks an invoice, contract, purchase order, approval messages, supplier status, and quality records separately. The agent combines those inputs, calculates the exception, creates a decision brief, and records a recommendation. A human still owns the financial decision.

## Vocabulary

| Term | Plain-language explanation |
| --- | --- |
| Submitted file | The invoice being reviewed; it is a claim, not proof that charges are valid |
| Knowledge | Governed documents the agent reads, such as contracts and policy |
| MCP tool | A live capability the agent can discover and call, such as reading a list or recording a review |
| Skill | A reusable procedure that tells the harness how to perform a specialized task |
| Sandbox | The isolated runtime where packaged Python executes and creates a file |
| Quality event | An investigation record |
| Active quality hold | An explicit block issued by Quality; an open event alone is not a hold |
| Evaluation | Saved prompts and expected meanings used to detect regressions |
| Workflow | Predictable automation that starts from a business event and invokes the agent |

## Architecture talk track

```text
Uploaded Excel invoice: what the supplier submitted
SharePoint knowledge: what contracts, policy, and approvals permit
SharePoint MCP: what current operational records say and where the result is logged
Skills and sandbox: how facts become a repeatable calculation and PDF
Workflow: how a new request starts the same review without an interactive chat
Human reviewer: who makes the final financial decision
```

Emphasize that the lab shows multiple information channels, not unrelated data sources added for spectacle.

## Timing

| Time | Activity | Presenter checkpoint |
| --- | --- | --- |
| 0-10 | Presentation | Learners understand the invoice exception and human boundary |
| 10-16 | Agent foundation | Agent exists with instructions and web grounding disabled |
| 16-22 | SharePoint knowledge | Contract and policy source shows Ready |
| 22-29 | SharePoint MCP | Astor Ridge review request is created through MCP |
| 29-40 | Skills and complete review | Python runs and PDF is generated |
| 40-44 | MCP review log | One confirmed audit item is created |
| 44-48 | Memory | Preference persists; case facts are still retrieved |
| 48-53 | Evaluation | Baseline CSV runs |
| 53-59 | Workflow | Learner builds three nodes and starts the Northwind request |
| 59-60 | Result and recap | Learner sees the updated request; facilitator can show full completion |

## Expected results

### Astor Ridge ARB-260814

- Invoice total: `$217,700`
- Supported: `$204,600`
- Disputed: `$13,100`
- Reconciliation difference: `$0`
- Active quality hold: No
- Human review: Yes, because disputed amount is greater than `$10,000`

### Northwind NWT-260821

- Invoice total: `$122,300`
- Supported: `$108,800`
- Disputed: `$13,500`
- Reconciliation difference: `$0`
- Active quality hold: No
- Human review: Yes, because disputed amount is greater than `$10,000`

## Teaching moments

### Uploaded file versus grounded truth

The Excel invoice states what the supplier billed. It does not prove that the billed amount is contractually supported. The contract and written approvals establish permitted amounts.

### Knowledge versus MCP

Both happen to use SharePoint, but the interaction is different. Knowledge retrieves passages from governed documents. MCP discovers operations and accesses current structured records, including a controlled write to the review log.

### Why two skills

Invoice Fact Check gathers and cites facts without deciding. Invoice Review Decision consumes that structured packet, runs deterministic code, applies policy, and creates the PDF. This separation makes the activity trace understandable and each procedure reusable.

### Human boundary

Creating a review request and recording a review result are safe administrative actions. Paying an invoice, rejecting a charge, changing supplier status, or issuing a quality hold are not authorized.

## Facilitation checkpoints

Pause briefly after:

1. Knowledge is added: ask which documents should be authoritative.
2. MCP is connected: show its permitted operations and disabled delete/write capabilities.
3. The Excel invoice is attached: explain that user input can conflict with governed sources.
4. Python runs: inspect the activity, not only the final prose.
5. The log item is created: reinforce explicit confirmation and least privilege.
6. Evaluation runs: explain why expected meaning is better than exact wording.
7. Workflow starts: contrast adaptive agent reasoning with predictable orchestration.

## Recovery paths

| Symptom | Recovery |
| --- | --- |
| Wrong environment or account | Stop and replace the seat; do not repair identity ownership during the lab |
| Knowledge cannot retrieve facts | Confirm site URL and learner access; switch to a hot spare if readiness validation was wrong |
| MCP is disconnected | Open connection manager, select the prepared learner connection, and retry |
| MCP write is unavailable | Continue after verifying reads; facilitator demonstrates the review-log write |
| Skill upload fails | Re-upload `invoice-review-decision.zip`; verify `SKILL.md` and Python are at ZIP root |
| Python does not run | Start a new test session; inspect activity; use a hot spare if sandbox execution is unavailable |
| Evaluation CSV import differs | Use the tenant-validated CSV; otherwise run the facilitator-precreated baseline |
| Workflow agent is missing | Publish the agent, refresh the designer, and confirm environment and connection identity |
| Workflow does not start | Confirm it is on and uses **When an item is created**, then create a new request item |

## Optional prompts

- Compare the risk tier in the supplier list with the quarterly governance presentation.
- Find a bonus supplier with an active quality hold and explain why human review is required.
- Review an invoice with exactly `$10,000` disputed and explain the threshold behavior.
- Identify a conflict between an optional spreadsheet and a governed contract without guessing.

## Completion standard

A learner succeeds when they can show the Astor Ridge activity trace, exact calculation, generated PDF, review-log item, baseline evaluation, and a three-node Workflow that stores the Northwind response on its request item.
