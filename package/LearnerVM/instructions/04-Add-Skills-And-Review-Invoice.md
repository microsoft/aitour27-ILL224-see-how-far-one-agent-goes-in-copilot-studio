# 4 - Add Skills and Review an Invoice

The harness will coordinate two skills. Invoice Fact Check gathers and structures facts. Invoice Review Decision runs deterministic Python, applies policy, and creates a PDF.

## Create Invoice Fact Check

1. In **Skills**, select **Add skill**, then **Create from blank**.
1. Name it `invoice-fact-check`.
1. Enter this description:

    ```text
    Use when a user asks to review a supplier invoice. Read the submitted invoice, retrieve current SharePoint records, and gather governing contract terms, approvals, policy, and active quality-hold information before a decision is made.
    ```

1. Paste these instructions:

    ```text
    1. Read the attached invoice and capture its supplier, invoice ID, PO, contract, batch or lot, total, and every line.
    2. Use the SharePoint MCP to retrieve the matching invoice, lines, supplier, and quality-event records.
    3. Use SharePoint knowledge to find the governing contract, policy, and written approvals.
    4. Compare the submitted file with current records. Never resolve a conflict by guessing.
    5. For each line, identify the invoiced amount, contract-permitted amount, and supporting source.
    6. Return valid JSON with supplierName, supplierId, invoiceId, purchaseOrder, contractId, invoiceTotal, lineItems, missingEvidence, conflictingEvidence, activeQualityHold, policyUnclear, evidenceSummary, and evidenceCitations.
    7. Do not calculate totals, recommend an outcome, or write to SharePoint.
    ```

1. Create the skill.

## Upload Invoice Review Decision

1. Add another skill and select **Upload**.
1. Browse to:

    ```text
    C:\LabFiles\ILL224\skills\invoice-review-decision.zip
    ```

1. Confirm the package contains `SKILL.md` and `calculate_supplier_review.py` at its root.
1. Create the skill.

> [!NOTE]
> **Why:** The uploaded skill demonstrates that a skill can carry executable resources. Python uses decimal-safe arithmetic and creates a PDF in the sandbox.

## Review the submitted invoice

1. Start a new test session.
1. Select the attachment button and attach:

    ```text
    C:\LabFiles\ILL224\case-inputs\Caldova_Astor_Ridge_Invoice.xlsx
    ```

1. Send:

    ```text
    Review this Astor Ridge invoice for Finance. Check the submitted charges against current SharePoint records, the governing contract, written approvals, policy, and any active quality hold. Tell me what is supported, what should be challenged, and whether human review is required. Cite the sources and create a review brief. Do not take financial action.
    ```

1. Inspect activity and confirm this sequence:
   - attached Excel file read;
   - SharePoint MCP list reads;
   - SharePoint knowledge citations;
   - `invoice-fact-check`;
   - `invoice-review-decision`; and
   - Python execution.
1. Confirm `$204,600` supported, `$13,100` disputed, `$0` reconciliation difference, no active quality hold, and human review required.
1. Download `Caldova_Supplier_Review_ARB-260814.pdf` and open it.

## Record the recommendation

1. Ask:

    ```text
    Record this recommendation in the Invoice Review Log.
    ```

1. Confirm the action when asked.
1. Open the SharePoint `Invoice Review Log` and verify one ARB-260814 item with the expected amounts and `Interactive Agent` source.

> [!IMPORTANT]
> The log is an audit record. No payment, invoice rejection, supplier change, or quality-hold change occurred.

Select **Next** to evaluate and publish the agent.
