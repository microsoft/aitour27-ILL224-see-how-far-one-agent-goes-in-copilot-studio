<!-- markdownlint-disable MD034 -->

# 7 - Run the Solution End to End

You built the agent with Astor Ridge. Now use a different supplier to test whether the procedure transfers to new facts.

1. Open the prepared request list:

    +++@lab.Variable(REVIEW_REQUESTS_LIST_URL)+++

1. Select **New**.
1. Enter:

    | Field | Value |
    | --- | --- |
    | Title | `Review NWT-260821` |
    | Invoice ID | `NWT-260821` |
    | Request Notes | `Review the submitted charges against current records, contract, approvals, policy, and quality holds.` |
    | Status | `New` |

1. Save the item.
1. Return to Workflows and open the latest run.
1. Confirm the trigger, Run an agent, and Update item nodes complete.
1. Open the request item and verify Status `Complete` and the readable Agent Response.

Expected Northwind result:

- invoice total `$122,300`;
- supported `$108,800`;
- disputed `$13,500`;
- reconciliation difference `$0`;
- no active quality hold; and
- human review required because disputed amount is greater than `$10,000`.

## What happened

| Layer | Responsibility |
| --- | --- |
| Request list and Workflow | Started the review and stored the readable response |
| SharePoint MCP | Retrieved current records and enabled a controlled log write |
| SharePoint knowledge | Supplied contract, approval, policy, and quality-document facts |
| Skills and sandbox | Organized facts, calculated the result, and created the PDF |
| Human reviewer | Owns every financial decision |

No payment, rejection, supplier change, or quality-hold change was made.

Congratulations. Select **Next**, then **Submit** to finish the lab.
