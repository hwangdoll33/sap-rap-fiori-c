# PayWise Development Instructions

## 1. Project identity

- Project name: **PayWise**
- Product description: **AP Payment Priority Advisor**
- SAP package: `ZRAP_PAYWISE`
- Platform: SAP BTP ABAP Environment Trial
- Programming model: ABAP Cloud with RAP managed scenario
- UI: SAP Fiori elements
- SAP MCP destination: `abap-btp`
- GitHub repository: `hwangdoll33/sap-rap-fiori-c`
- Default Git branch: `main`
- Version control: Eclipse ADT abapGit connected to the shared GitHub repository

PayWise is a portfolio application that stores sample accounts-payable invoices,
evaluates their payment priority, explains the recommendation, and allows a user
to simulate payment processing.

## 2. Confirmed functional scope

### Data

- Use custom database tables and generated sample data in BTP Trial.
- Do not assume access to a productive S/4HANA system, `ACDOCA`, `BSEG`, or other
  productive SAP data.
- Use a repeatable ABAP data-generator class so sample data can be recreated.
- The initial version supports one company and KRW only.
- Store amounts with correct currency semantics even though the initial currency
  is always KRW.

### Priority score

The total invoice priority score will use exactly these three factors:

1. APR / early-payment-discount attractiveness
2. Proximity to payment due date
3. Supplier importance

The formulas, weights, thresholds, and maximum points for these factors are **not
yet defined**. Do not invent them. Ask the user to define or approve them before
implementing production scoring logic.

WACC and APR-versus-WACC comparison are not part of the current BTP Trial MVP.
Do not add manual WACC maintenance or an external WACC API unless the user later
expands the scope explicitly. Keep financial scoring modular enough to add a WACC
comparison implementation later.

### Payment processing

- Payment is a simulation only; never initiate a bank transfer, payment run, or
  call to an external payment system.
- Expose a RAP action that changes an eligible invoice from `OPEN` to `PAID`.
- Record at least the payment status and simulated payment date. Propose any
  additional audit fields before creating them.
- Prevent repeated payment of an already-paid invoice.
- There is no manager approval workflow in the current scope.

### Expected UI outcome

The Fiori elements application should support:

- Viewing sample AP invoices
- Sorting and filtering invoices
- Showing the three factor scores and total score
- Showing priority rank or recommendation level
- Showing a human-readable recommendation reason
- Executing the simulated payment action for eligible invoices

## 3. Source of truth and tool rules

The SAP BTP repository is the source of truth for ABAP and RAP development
objects. The locally cloned GitHub repository is context and version history; it
is not a substitute for updating SAP objects.

- Use the `abap-btp` MCP for every SAP repository read or mutation.
- Before changing anything, inspect `ZRAP_PAYWISE` and read the current version of
  every target object.
- Do not create, update, rename, move, activate, or delete SAP objects by editing
  abapGit-serialized files locally.
- Do not modify any SAP object outside `ZRAP_PAYWISE`.
- Do not use classic ABAP-only APIs or syntax. Use ABAP Cloud syntax and released
  APIs.
- Eclipse ADT may remain connected while MCP is used.
- If Eclipse contains unsaved changes to a target object, stop and ask the user
  to save, discard, or reconcile them first.
- Do not run local Git commits, pushes, branch switches, or destructive Git
  commands unless the user explicitly requests them. The normal Git write path
  is Eclipse ADT abapGit after SAP objects are activated and reviewed.

## 4. Ask before assuming

When a missing decision affects the data model, behavior, scoring, UI, security,
integration, object names, or team workflow:

1. State what information is missing.
2. Explain briefly why it affects the implementation.
3. Offer two or three concrete options when useful.
4. Recommend one option, but do not silently choose it.
5. Wait for the user's answer before making the affected SAP change.

For a new feature, first inspect the system and present a concise design and
target-object list. Do not mutate the SAP system until the user approves that
bounded implementation. After approval, complete the approved work without
asking repetitive questions unless a new material decision or blocker appears.

Never fabricate SAP object metadata, released-API availability, external API
responses, calculation rules, or activation results. Verify them through the
available system tools.

## 5. Two-developer collaboration rules

Two developers use separate BTP accounts and separate service keys but share the
same BTP system and `ZRAP_PAYWISE` package. Git branches do not isolate SAP
repository objects in this shared system.

- Treat one ABAP repository object as owned by only one developer at a time.
- Never modify an object currently assigned to or being edited by the other
  developer.
- Different methods in the same ABAP class still count as the same object.
- A database table, CDS entity, behavior definition, behavior pool, class,
  metadata extension, service definition, and service binding are each separate
  collaboration units.
- Before changing an object, re-read it and check for locks or inactive changes.
- If an object is locked by another user, stop. Report the lock owner when
  available and do not retry by bypassing the lock.
- If the requested change requires editing another developer's object, explain
  the dependency and ask the user to coordinate ownership first.
- Even when objects differ, check dependencies. A table-field change can break
  CDS views, behaviors, classes, services, and UI metadata.
- Activate and announce completed dependency changes before downstream work
  begins.
- Only one person should perform an abapGit commit/push at a time. The user who
  configured the repository is the default Git integrator unless the team says
  otherwise.

At the start of a write task, report:

- Target objects
- Intended changes
- Dependencies
- Whether any target is locked, inactive, or owned by the other developer

At the end of a write task, report:

- Objects created or changed
- Syntax-check result
- Activation result
- Tests performed and results
- Remaining inactive objects, warnings, blockers, and recommended next step

## 6. Preferred architecture and naming

Use a small, complete managed RAP business object and create artifacts
incrementally. Do not generate the entire application in one unreviewed step.

Preferred naming, subject to existing-object inspection and user approval:

- Database tables: `ZPAY_*`
- Interface/root CDS views: `ZI_PAY_*`
- Projection/consumption CDS views: `ZC_PAY_*`
- ABAP classes: `ZCL_PAY_*`
- Behavior pools: `ZBP_I_PAY_*`
- Service artifacts: `ZUI_PAYWISE*`

Typical dependency order:

1. Confirm invoice, supplier, score, status, and audit fields.
2. Create and activate persistence tables.
3. Create the repeatable sample-data generator.
4. Create and activate interface CDS entities.
5. Create scoring classes and ABAP Unit tests.
6. Create behavior definition and implementation, including the simulated
   payment action and validations.
7. Create projection CDS and metadata extension.
8. Create and activate service definition and service binding.
9. Test Fiori preview and the end-to-end payment-status transition.

## 7. Quality requirements

- Use clear English object descriptions and field labels.
- Keep scoring logic out of UI annotations and separate it from persistence when
  practical.
- Add ABAP Unit tests for APR, due-date, supplier-importance, total-score, and
  payment-eligibility rules after those rules are approved.
- Include boundary cases, such as zero discount, expired discount date, due
  today, overdue invoice, low-importance supplier, and already-paid invoice.
- Use managed RAP administrative fields and ETags where required by the chosen
  scenario.
- Validate syntax before activation and activate in dependency order.
- Never report success merely because an object was created. Confirm syntax,
  activation, and relevant behavior.
- Do not delete or rename existing objects without explicit user approval and a
  dependency/impact check.

## 8. Current non-goals

Unless the user explicitly changes scope, do not implement:

- Productive S/4HANA AP integration
- Direct access to productive standard tables
- Multi-currency conversion
- WACC maintenance or external WACC integration
- Real payment execution or banking integration
- Manager approval workflow
- AI/ML-based scoring
- Objects outside `ZRAP_PAYWISE`
