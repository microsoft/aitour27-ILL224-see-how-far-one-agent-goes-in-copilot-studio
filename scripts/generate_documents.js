#!/usr/bin/env node

const fs = require("fs");
const path = require("path");
const { execFileSync } = require("child_process");
const {
  AlignmentType,
  BorderStyle,
  Document,
  HeadingLevel,
  Packer,
  Paragraph,
  ShadingType,
  Table,
  TableCell,
  TableRow,
  TextRun,
  WidthType,
} = require("docx");
const pptxgen = require("pptxgenjs");

const ROOT = path.resolve(__dirname, "..");
const CORE = path.join(ROOT, "package", "SharePoint", "core");
const OPTIONAL = path.join(ROOT, "package", "SharePoint", "optional");
const BUILD = path.join(ROOT, ".build");

for (const directory of [CORE, OPTIONAL, BUILD]) {
  fs.mkdirSync(directory, { recursive: true });
}

const colors = {
  navy: "16324F",
  teal: "007F73",
  mint: "DDF3EC",
  gold: "F2B134",
  ink: "25313C",
  gray: "E8EDF1",
  red: "B42318",
  white: "FFFFFF",
};

function title(text) {
  return new Paragraph({
    alignment: AlignmentType.CENTER,
    spacing: { after: 120 },
    children: [new TextRun({ text, bold: true, size: 34, color: colors.navy })],
  });
}

function subtitle(text) {
  return new Paragraph({
    alignment: AlignmentType.CENTER,
    spacing: { after: 280 },
    children: [new TextRun({ text, bold: true, size: 20, color: colors.teal })],
  });
}

function heading(text, level = HeadingLevel.HEADING_1) {
  return new Paragraph({ text, heading: level, spacing: { before: 220, after: 100 } });
}

function body(text, options = {}) {
  return new Paragraph({
    text,
    bullet: options.bullet ? { level: 0 } : undefined,
    spacing: { after: 110, line: 280 },
  });
}

function factTable(rows) {
  return new Table({
    width: { size: 100, type: WidthType.PERCENTAGE },
    rows: rows.map((row, index) => new TableRow({
      children: row.map((value) => new TableCell({
        shading: index === 0 ? { fill: colors.navy, type: ShadingType.CLEAR } : undefined,
        borders: {
          top: { style: BorderStyle.SINGLE, color: "B8C3CC", size: 4 },
          bottom: { style: BorderStyle.SINGLE, color: "B8C3CC", size: 4 },
          left: { style: BorderStyle.SINGLE, color: "B8C3CC", size: 4 },
          right: { style: BorderStyle.SINGLE, color: "B8C3CC", size: 4 },
        },
        children: [new Paragraph({
          children: [new TextRun({
            text: String(value),
            bold: index === 0,
            color: index === 0 ? colors.white : colors.ink,
          })],
        })],
      })),
    })),
  });
}

function makeDocument(children, description) {
  return new Document({
    creator: "Caldova Pharmaceuticals",
    title: description,
    description: "Fictional data for Microsoft AI Tour lab ILL224",
    styles: {
      default: { document: { run: { font: "Aptos", size: 22, color: colors.ink } } },
      paragraphStyles: [
        { id: "Heading1", name: "Heading 1", basedOn: "Normal", next: "Normal", quickFormat: true,
          run: { font: "Aptos Display", size: 28, bold: true, color: colors.navy },
          paragraph: { spacing: { before: 240, after: 120 }, outlineLevel: 0 } },
        { id: "Heading2", name: "Heading 2", basedOn: "Normal", next: "Normal", quickFormat: true,
          run: { font: "Aptos Display", size: 24, bold: true, color: colors.teal },
          paragraph: { spacing: { before: 180, after: 100 }, outlineLevel: 1 } },
      ],
    },
    sections: [{
      properties: { page: { margin: { top: 720, right: 850, bottom: 720, left: 850 } } },
      children,
    }],
  });
}

async function writeDocx(filePath, children, description) {
  const buffer = await Packer.toBuffer(makeDocument(children, description));
  fs.writeFileSync(filePath, buffer);
}

async function generateCoreDocuments() {
  await writeDocx(
    path.join(CORE, "Caldova_Supplier_Invoice_Review_Policy.docx"),
    [
      title("CALDOVA PHARMACEUTICALS"),
      subtitle("SUPPLIER INVOICE REVIEW POLICY | EFFECTIVE JULY 1, 2026"),
      body("FICTIONAL LAB DATA"),
      heading("1. Review standard"),
      body("Compare every invoice charge with the governing agreement, purchase order, and written approvals."),
      body("Treat unsupported charges and amounts above contractual caps as disputed."),
      body("Calculate disputed amount, supported amount, and reconciliation difference using code."),
      heading("2. Human-review conditions"),
      body("Require human review when any condition below is true:"),
      body("The disputed amount is greater than USD 10,000.", { bullet: true }),
      body("Required evidence is missing, stale, conflicting, or ambiguous.", { bullet: true }),
      body("An active quality hold exists.", { bullet: true }),
      body("Financial amounts do not reconcile.", { bullet: true }),
      body("This policy does not clearly cover the case.", { bullet: true }),
      body("A disputed amount equal to USD 10,000 does not trigger the amount threshold by itself."),
      heading("3. Control boundary"),
      body("Human review accepts or rejects the recommendation only. It does not initiate payment, reject an invoice, change supplier status, or issue or remove a quality hold."),
    ],
    "Supplier Invoice Review Policy",
  );

  await writeDocx(
    path.join(CORE, "Caldova_Astor_Ridge_Manufacturing_Agreement.docx"),
    [
      title("CALDOVA PHARMACEUTICALS"),
      subtitle("COMMERCIAL MANUFACTURING AGREEMENT CMO-2026-041"),
      factTable([["Supplier", "Supplier ID", "Effective date"], ["Astor Ridge Biologics", "SUP-1042", "August 1, 2026"]]),
      heading("Section 4 - Commercial Charges"),
      heading("4.1 Commercial manufacturing batch", HeadingLevel.HEADING_2),
      body("The price for one commercial manufacturing batch is USD 185,000."),
      heading("4.2 Expedited production", HeadingLevel.HEADING_2),
      body("When Caldova requests an expedited production schedule, the supplier may charge a premium of no more than 4% of the commercial manufacturing batch price. Any amount above that cap requires both a revised purchase order and written approval from Caldova's VP of Procurement."),
      heading("4.3 Cold-chain freight", HeadingLevel.HEADING_2),
      body("Cold-chain freight may be charged at actual cost up to USD 12,500 per batch."),
      heading("4.4 Additional services", HeadingLevel.HEADING_2),
      body("Charges not listed in this agreement require a revised purchase order and written approval from Caldova's VP of Procurement before the supplier performs or invoices the service."),
      heading("Section 7 - Quality Events"),
      body("An open quality investigation does not by itself place a batch or supplier on quality hold. A quality hold must be expressly issued by Caldova Quality."),
      heading("Section 9 - Payment Control"),
      body("An invoice review recommendation does not authorize payment, reject an invoice, or modify a supplier record. Those actions remain subject to Caldova's financial and supplier-management controls."),
      body("FICTIONAL LAB DATA"),
    ],
    "Commercial Manufacturing Agreement CMO-2026-041",
  );

  await writeDocx(
    path.join(CORE, "Caldova_Northwind_Packaging_Agreement.docx"),
    [
      title("CALDOVA PHARMACEUTICALS"),
      subtitle("PACKAGING SERVICES AGREEMENT PKG-2026-052"),
      factTable([["Supplier", "Supplier ID", "Effective date", "Terms"], ["Northwind Therapeutics", "SUP-1088", "January 1, 2026", "Net 45"]]),
      heading("Section 4 - Commercial Terms"),
      heading("4.1 Packaging production run", HeadingLevel.HEADING_2),
      body("Northwind may charge USD 96,000 for one packaging and labeling run for lot CDV-LB22."),
      heading("4.2 Serialized label setup", HeadingLevel.HEADING_2),
      body("The fixed fee for serialized label setup is USD 8,000 per lot. A higher fee requires a revised purchase order and written approval from Caldova Procurement before work begins."),
      heading("4.3 Standard freight", HeadingLevel.HEADING_2),
      body("Standard freight may be invoiced at actual cost up to USD 5,000 per shipment."),
      heading("4.4 Additional services", HeadingLevel.HEADING_2),
      body("Rush changeovers, rework, validation support, and other services not listed in this agreement require a revised purchase order and written approval before work begins."),
      heading("Section 7 - Quality Status"),
      body("An open corrective-action item does not by itself create a quality hold. A hold must be explicitly issued by Caldova Quality."),
      heading("Section 9 - Payment Control"),
      body("Caldova may process supported, undisputed charges under normal payment controls. Unsupported charges must be challenged, and total disputed amounts greater than USD 10,000 require human review."),
      body("FICTIONAL LAB DATA"),
    ],
    "Packaging Services Agreement PKG-2026-052",
  );

  const approvalDocs = [
    {
      file: "Astor_Ridge_Expedite_Approval.docx",
      title: "EXPEDITED PRODUCTION APPROVAL RECORD",
      rows: [["Supplier", "Invoice", "Purchase order"], ["Astor Ridge Biologics", "ARB-260814", "PO-88431"]],
      paragraphs: [
        "Decision date: August 6, 2026",
        "Caldova Procurement confirms expedited scheduling for batch CDV-AX47 under agreement CMO-2026-041.",
        "The approved expedited-production premium is limited to the existing contractual cap of 4% of the USD 185,000 batch price, or USD 7,400.",
        "No revised purchase order or VP Procurement approval was issued for a premium above USD 7,400. No approval was issued for a validation documentation fee.",
      ],
    },
    {
      file: "Northwind_Label_Setup_Decision.docx",
      title: "PROCUREMENT DECISION RECORD",
      rows: [["Supplier", "Invoice", "Purchase order"], ["Northwind Therapeutics", "NWT-260821", "PO-89214"]],
      paragraphs: [
        "Decision date: August 18, 2026",
        "Caldova Procurement confirms the serialized label setup allowance under agreement PKG-2026-052 is USD 8,000 for lot CDV-LB22.",
        "No revised purchase order or written Procurement approval exists for a setup fee above USD 8,000.",
        "No approval exists for a rush changeover fee.",
      ],
    },
    {
      file: "Caldova_Supplier_Quality_Exception.docx",
      title: "SUPPLIER QUALITY EVENT QE-2026-118",
      rows: [["Supplier", "Batch", "Event status", "Active quality hold"], ["Astor Ridge Biologics", "CDV-AX47", "Open", "No"]],
      paragraphs: [
        "Record date: August 9, 2026",
        "A temperature logger showed a short excursion during transit. Quality review found no product impact. The investigation remains open for corrective-action tracking.",
        "Caldova Quality has not issued an active quality hold for batch CDV-AX47 or supplier SUP-1042.",
        "An open investigation is not equivalent to an active quality hold.",
      ],
    },
  ];

  for (const item of approvalDocs) {
    await writeDocx(
      path.join(BUILD, item.file),
      [
        title("CALDOVA PHARMACEUTICALS"),
        subtitle(item.title),
        factTable(item.rows),
        ...item.paragraphs.map((text) => body(text)),
        heading("Control note"),
        body("This record documents evidence for review. It does not authorize payment, reject an invoice, or change supplier or quality status."),
        body("FICTIONAL LAB DATA"),
      ],
      item.title,
    );
  }
}

function addSlideTitle(slide, titleText, sectionText) {
  slide.addText(sectionText.toUpperCase(), { x: 0.55, y: 0.28, w: 3.5, h: 0.25, fontFace: "Aptos", fontSize: 9, bold: true, color: colors.teal, charSpacing: 1.4, margin: 0 });
  slide.addText(titleText, { x: 0.55, y: 0.62, w: 8.8, h: 0.55, fontFace: "Aptos Display", fontSize: 26, bold: true, color: colors.navy, margin: 0 });
  slide.addShape("line", { x: 0.55, y: 1.27, w: 8.9, h: 0, line: { color: colors.gold, width: 2 } });
}

function warnIfSlideElementsOutOfBounds(slide, deck) {
  const width = 10;
  const height = 5.625;
  for (const object of slide._slideObjects || []) {
    const options = object.options || object.opts || {};
    if ([options.x, options.y, options.w, options.h].every((value) => typeof value === "number") &&
        (options.x < 0 || options.y < 0 || options.x + options.w > width || options.y + options.h > height)) {
      console.warn(`Out-of-bounds element on slide ${deck._slides.indexOf(slide) + 1}`);
    }
  }
}

function warnIfSlideHasOverlaps(slide, deck) {
  const objects = (slide._slideObjects || []).filter((object) => {
    const options = object.options || object.opts || {};
    return object.text !== null && object.text !== undefined &&
      [options.x, options.y, options.w, options.h].every((value) => typeof value === "number");
  });
  for (let left = 0; left < objects.length; left += 1) {
    for (let right = left + 1; right < objects.length; right += 1) {
      const a = objects[left].options || objects[left].opts;
      const b = objects[right].options || objects[right].opts;
      const area = Math.max(0, Math.min(a.x + a.w, b.x + b.w) - Math.max(a.x, b.x)) *
        Math.max(0, Math.min(a.y + a.h, b.y + b.h) - Math.max(a.y, b.y));
      if (area > 0.35) {
        console.warn(`Possible overlap on slide ${deck._slides.indexOf(slide) + 1}`);
      }
    }
  }
}

async function generateGovernanceDeck() {
  const deck = new pptxgen();
  deck.layout = "LAYOUT_16x9";
  deck.author = "Caldova Pharmaceuticals";
  deck.subject = "Fictional supplier governance briefing for ILL224";
  deck.title = "Caldova Supplier Governance Briefing";
  deck.company = "Caldova Pharmaceuticals";
  deck.lang = "en-US";
  deck.theme = {
    headFontFace: "Aptos Display",
    bodyFontFace: "Aptos",
    lang: "en-US",
  };

  let slide = deck.addSlide();
  slide.background = { color: colors.navy };
  slide.addShape(deck.ShapeType.rect, { x: 0, y: 4.72, w: 10, h: 0.905, fill: { color: colors.teal }, line: { transparency: 100 } });
  slide.addText("CALDOVA PHARMACEUTICALS", { x: 0.7, y: 0.65, w: 5.2, h: 0.3, fontFace: "Aptos", fontSize: 11, bold: true, color: colors.gold, charSpacing: 1.5, margin: 0 });
  slide.addText("Supplier governance\nbriefing", { x: 0.7, y: 1.35, w: 6.5, h: 1.55, fontFace: "Aptos Display", fontSize: 34, bold: true, color: colors.white, margin: 0, breakLine: false });
  slide.addText("Q3 2026 | Procurement, Quality, and Finance", { x: 0.72, y: 3.25, w: 5.8, h: 0.4, fontFace: "Aptos", fontSize: 16, color: "D7E1E8", margin: 0 });
  slide.addText("FICTIONAL LAB DATA", { x: 7.42, y: 5.02, w: 1.9, h: 0.2, fontFace: "Aptos", fontSize: 8, bold: true, color: colors.white, align: "right", margin: 0 });

  slide = deck.addSlide();
  slide.background = { color: "F7F9FA" };
  addSlideTitle(slide, "Supplier portfolio at a glance", "Governance snapshot");
  const cards = [
    ["4", "monitored suppliers", colors.navy],
    ["1", "conditional supplier", colors.gold],
    ["1", "active quality hold", colors.red],
  ];
  cards.forEach(([number, label, color], index) => {
    const x = 0.65 + index * 3.05;
    slide.addShape(deck.ShapeType.rect, { x, y: 1.65, w: 2.65, h: 1.35, fill: { color: colors.white }, line: { color: "D7DFE5", width: 1 } });
    slide.addText(number, { x: x + 0.2, y: 1.84, w: 0.75, h: 0.55, fontFace: "Aptos Display", fontSize: 30, bold: true, color, margin: 0 });
    slide.addText(label, { x: x + 0.2, y: 2.48, w: 2.15, h: 0.3, fontFace: "Aptos", fontSize: 12, color: colors.ink, margin: 0 });
  });
  slide.addText("Control signal", { x: 0.65, y: 3.42, w: 2, h: 0.3, fontFace: "Aptos Display", fontSize: 17, bold: true, color: colors.navy, margin: 0 });
  slide.addText("Open investigations and active quality holds are distinct states. Only an explicit Quality action creates a hold.", { x: 0.65, y: 3.88, w: 8.4, h: 0.75, fontFace: "Aptos", fontSize: 17, color: colors.ink, margin: 0, breakLine: false });

  slide = deck.addSlide();
  slide.background = { color: "F7F9FA" };
  addSlideTitle(slide, "Invoice review control", "Policy");
  const steps = [
    ["1", "Verify", "Invoice and current records"],
    ["2", "Ground", "Contract and approvals"],
    ["3", "Calculate", "Supported and disputed"],
    ["4", "Route", "Human review when required"],
  ];
  steps.forEach(([number, verb, label], index) => {
    const x = 0.55 + index * 2.36;
    slide.addShape(deck.ShapeType.ellipse, { x, y: 1.72, w: 0.58, h: 0.58, fill: { color: index === 3 ? colors.gold : colors.teal }, line: { transparency: 100 } });
    slide.addText(number, { x, y: 1.85, w: 0.58, h: 0.2, fontFace: "Aptos", fontSize: 12, bold: true, color: index === 3 ? colors.navy : colors.white, align: "center", margin: 0 });
    slide.addText(verb, { x: x + 0.72, y: 1.7, w: 1.45, h: 0.3, fontFace: "Aptos Display", fontSize: 17, bold: true, color: colors.navy, margin: 0 });
    slide.addText(label, { x: x + 0.72, y: 2.09, w: 1.45, h: 0.65, fontFace: "Aptos", fontSize: 11, color: colors.ink, margin: 0 });
    if (index < 3) slide.addShape(deck.ShapeType.line, { x: x + 2.02, y: 2.0, w: 0.22, h: 0, line: { color: "95A5B1", width: 1.5, endArrowType: "triangle" } });
  });
  slide.addShape(deck.ShapeType.rect, { x: 0.65, y: 3.48, w: 8.7, h: 1.03, fill: { color: colors.mint }, line: { color: "A9D8CD", width: 1 } });
  slide.addText("Human review is required above $10,000 disputed, when evidence is incomplete or conflicting, when an active quality hold exists, when arithmetic fails, or when policy is unclear.", { x: 0.9, y: 3.76, w: 8.15, h: 0.5, fontFace: "Aptos", fontSize: 16, bold: true, color: colors.navy, margin: 0, align: "center" });

  slide = deck.addSlide();
  slide.background = { color: colors.navy };
  slide.addText("Decision boundary", { x: 0.65, y: 0.65, w: 5.5, h: 0.55, fontFace: "Aptos Display", fontSize: 30, bold: true, color: colors.white, margin: 0 });
  slide.addText("The assurance agent may", { x: 0.7, y: 1.65, w: 3.6, h: 0.35, fontFace: "Aptos Display", fontSize: 18, bold: true, color: colors.gold, margin: 0 });
  slide.addText([
    { text: "Read current records", options: { bullet: true, breakLine: true } },
    { text: "Compare governed evidence", options: { bullet: true, breakLine: true } },
    { text: "Calculate and recommend", options: { bullet: true, breakLine: true } },
    { text: "Create a review brief and log", options: { bullet: true } },
  ], { x: 0.8, y: 2.15, w: 3.65, h: 1.8, fontFace: "Aptos", fontSize: 17, color: colors.white, breakLine: false, margin: 0.06 });
  slide.addText("Only an authorized person may", { x: 5.35, y: 1.65, w: 3.9, h: 0.35, fontFace: "Aptos Display", fontSize: 18, bold: true, color: colors.gold, margin: 0 });
  slide.addText([
    { text: "Pay or reject an invoice", options: { bullet: true, breakLine: true } },
    { text: "Change supplier status", options: { bullet: true, breakLine: true } },
    { text: "Issue or remove a quality hold", options: { bullet: true, breakLine: true } },
    { text: "Approve an unsupported charge", options: { bullet: true } },
  ], { x: 5.45, y: 2.15, w: 3.7, h: 1.8, fontFace: "Aptos", fontSize: 17, color: colors.white, breakLine: false, margin: 0.06 });
  slide.addText("Recommendation is not authorization.", { x: 0.7, y: 4.72, w: 8.6, h: 0.35, fontFace: "Aptos Display", fontSize: 21, bold: true, color: colors.mint, align: "center", margin: 0 });

  for (const currentSlide of deck._slides) {
    warnIfSlideHasOverlaps(currentSlide, deck);
    warnIfSlideElementsOutOfBounds(currentSlide, deck);
  }
  await deck.writeFile({ fileName: path.join(OPTIONAL, "Caldova_Supplier_Governance_Briefing.pptx") });
}

function convertPdfSources() {
  const executable = process.env.SOFFICE || "/Applications/LibreOffice.app/Contents/MacOS/soffice";
  execFileSync(executable, ["--headless", "--convert-to", "pdf", "--outdir", CORE, ...fs.readdirSync(BUILD).filter((name) => name.endsWith(".docx")).map((name) => path.join(BUILD, name))], { stdio: "inherit" });
  const renames = {
    "Astor_Ridge_Expedite_Approval.pdf": "Astor_Ridge_Expedite_Approval.pdf",
    "Northwind_Label_Setup_Decision.pdf": "Northwind_Label_Setup_Decision.pdf",
    "Caldova_Supplier_Quality_Exception.pdf": "Caldova_Supplier_Quality_Exception.pdf",
  };
  for (const [generated, target] of Object.entries(renames)) {
    const sourcePath = path.join(CORE, generated);
    if (!fs.existsSync(sourcePath)) throw new Error(`Expected PDF was not generated: ${sourcePath}`);
    if (generated !== target) fs.renameSync(sourcePath, path.join(CORE, target));
  }
}

async function main() {
  await generateCoreDocuments();
  await generateGovernanceDeck();
  convertPdfSources();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
