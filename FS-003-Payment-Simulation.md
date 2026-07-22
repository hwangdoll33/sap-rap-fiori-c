1# FS-003 Payment Simulation

- **Module**: FI-AP (Accounts Payable)
- **Screen ID**: FS-003
- **Screen Name**: Payment Simulation
- **Application**: AI-Based AP Payment Priority
- **Development Type**: RAP + SAP Fiori Elements
- **Priority**: High

---

# 1. Purpose

Payment Simulation은 사용자가 선택한 Invoice를 지급하기 전에 재무적 영향을 미리 분석하고, 지급 여부를 합리적으로 판단할 수 있도록 지원하는 기능이다.

SAP 표준은 지급 실행(Payment Run)은 제공하지만 지급 전 시뮬레이션 기능은 제공하지 않는다.

본 기능은

- 지급 후 예상 현금 잔액
- 조기지급 할인 효과
- 연체 패널티
- Priority Score
- Recommendation

을 통합적으로 제공하여 AP 담당자의 의사결정을 지원한다.

---

# 2. Business Goal

사용자는 실제 지급을 실행하기 전에

> "지금 지급하는 것이 유리한가?"

를 판단할 수 있어야 한다.

이를 위해

- Cash Forecast
- Trade-off Analysis
- Priority Score
- Recommendation

을 하나의 화면에서 제공한다.

---

# 3. SAP Standard vs Custom Development

| Feature | SAP Standard | Custom Development |
|----------|-------------|-------------------|
| Invoice Information | ✔ | - |
| Cash Position | ✔ | - |
| Payment Terms | ✔ | - |
| Vendor Information | ✔ | - |
| Cash Forecast | - | ✔ |
| Trade-off Analysis | - | ✔ |
| Priority Score | - | ✔ |
| Recommendation | - | ✔ |
| Payment Simulation | - | ✔ |

---

# 4. Business Scenario

## Step 1

사용자는 Invoice List 화면에서 하나 이상의 Invoice를 선택한다.

↓

## Step 2

Simulation 버튼을 클릭한다.

↓

## Step 3

시스템은 선택된 Invoice를 기준으로

- Cash Position
- Payment Terms
- Vendor Importance
- Due Date

를 조회한다.

↓

## Step 4

Priority Score를 계산한다.

↓

## Step 5

Trade-off를 계산한다.

↓

## Step 6

Simulation 결과를 화면에 출력한다.

↓

## Step 7

사용자는

- Approval Request
- Recalculate
- Save Scenario

중 하나를 선택한다.

---

# 5. Input Data

## Invoice

| Field | Description |
|---------|------------|
| Invoice Number | Invoice 번호 |
| Invoice Amount | 지급 금액 |
| Due Date | 만기일 |
| Currency | 통화 |
| Payment Terms | 지급 조건 |

---

## Vendor

| Field | Description |
|---------|------------|
| Vendor ID | 거래처 |
| Vendor Name | 거래처명 |
| Vendor Importance | 거래처 중요도 |

---

## Cash Position

| Field | Description |
|---------|------------|
| Available Cash | 가용 현금 |
| Minimum Cash | 최소 보유 현금 |

---

# 6. Screen Layout

## Section 1. Selection Summary

### Purpose

선택된 Invoice 요약 정보를 제공한다.

### Display Items

- Selected Invoice Count
- Total Payment Amount
- Payment Date

### Validation

Payment Date는 오늘 또는 미래 날짜만 입력 가능하다.

---

## Section 2. KPI Cards

Simulation 실행 후 KPI를 표시한다.

### KPI

- Available Cash Before Payment
- Available Cash After Payment
- Minimum Cash Threshold
- Net Benefit

### Validation

예상 현금이 최소 보유 현금보다 낮으면 Warning을 표시한다.

---

## Section 3. Cash Forecast

### Purpose

지급 전과 지급 후의 현금 잔액을 비교한다.

### Display

- Before Payment
- After Payment

### Future Extension

일자별 Cash Flow Timeline은 Phase 2에서 구현한다.

---

## Section 4. Trade-off Analysis

선택한 Invoice별 손익을 비교한다.

### Columns

- Priority Rank
- Invoice
- Vendor
- Amount
- Payment Date
- Early Payment Discount
- Late Payment Penalty
- Net Benefit

### Business Rule

Net Benefit = Early Payment Discount − Late Payment Penalty

Net Benefit ≤ 0

↓

Recommendation = Hold

---

## Section 5. Priority Score

Priority Score 계산 결과를 차트로 제공한다.

### Formula

Priority Score

=

Financial Score

+

Vendor Score

+

Due Date Score

-

Penalty Score

### Display

- Total Score
- Financial Score
- Vendor Score
- Due Date Score
- Error Penalty

---

## Section 6. Recommendation

Priority Score를 기반으로 Recommendation을 제공한다.

| Score | Recommendation |
|---------|---------------|
| ≥90 | Pay Immediately |
| 70~89 | Recommended |
| 50~69 | Review |
| <50 | Hold |

Recommendation은 Object Status(Tag)로 표시한다.

---

# 7. Action Buttons

## Approval Request

Simulation 결과를 Approval 화면으로 전달한다.

---

## Recalculate

Invoice 선택을 변경하여 Simulation을 다시 수행한다.

---

## Save Scenario

Simulation 결과를 저장한다.

(선택 기능)

---

# 8. Business Rules

## BR-001

Priority Score는 Rule Engine에서 계산한다.

---

## BR-002

Trade-off는

Early Payment Discount

-

Late Payment Penalty

로 계산한다.

---

## BR-003

Available Cash After Payment

=

Current Cash

-

Selected Payment Amount

---

## BR-004

Available Cash After Payment

<

Minimum Cash

↓

Warning 표시

---

## BR-005

Priority Score는 내림차순으로 정렬한다.

---

# 9. Validation

| Rule | Message |
|-------|----------|
| Payment Date Required | Payment Date is required. |
| No Invoice Selected | Select at least one Invoice. |
| Cash Below Threshold | Available Cash is below the minimum threshold. |

---

# 10. Exception Handling

## No Invoice

Simulation을 수행할 수 없다.

---

## Cash Position Not Available

Cash Position 조회 실패

↓

Simulation 중단

---

## Payment Terms Missing

Trade-off 계산 제외

Warning 표시

---

# 11. SAP Standard Integration

| SAP Object | Usage |
|------------|------|
| Invoice | Invoice Information |
| Business Partner | Vendor Information |
| Cash Position | Available Cash |
| Payment Terms | Discount / Penalty |

---

# 12. RAP Development Specification

## RAP Business Object

Payment Simulation

---

## CDS

Interface View

Projection View

Consumption View

---

## Behavior

Managed

---

## Actions

- Simulate
- Recalculate
- SaveScenario
- SubmitApproval

---

## OData

V4

---

## UI

Fiori Elements Object Page

---

## Navigation

Invoice List

↓

Payment Simulation

↓

Approval

---

# 13. Acceptance Criteria

- 사용자는 하나 이상의 Invoice를 선택하여 Simulation을 수행할 수 있다.
- 지급 전/후 Available Cash를 확인할 수 있다.
- Priority Score가 계산된다.
- Recommendation이 표시된다.
- Trade-off 결과가 계산된다.
- Approval Request가 가능하다.
- Recalculate가 정상 동작한다.

---

# 14. Future Enhancement

- Cash Flow Timeline
- AI Prediction Model
- ML 기반 Priority Optimization
- Multi Scenario Comparison
- What-if Analysis
