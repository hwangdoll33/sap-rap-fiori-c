# Priority Formula

## Purpose

본 문서는 Payment Simulation에서 사용하는 Priority Score 계산 규칙을 정의한다.

---

# 1. Priority Score Formula

Priority Score는 Weighted Sum Model(가중합계모델)을 사용한다.

[
P_{total}
=========

(W_{fin}\times S_{fin})
+
(W_{ven}\times S_{ven})
+
(W_{time}\times S_{time})
-------------------------

P_{block}
]

또는 일반식

[
P_{total}
=========

\sum_{i=1}^{n}(W_i\times S_i)-P_{block}
]

---

# 2. Variable Definition

| Variable | Description       |
| -------- | ----------------- |
| Ptotal   | 최종 지급 우선순위        |
| Wfin     | 재무 가중치            |
| Sfin     | 재무 점수             |
| Wven     | 거래처 가중치           |
| Sven     | 거래처 점수            |
| Wtime    | 만기일 가중치           |
| Stime    | 만기일 점수            |
| Pblock   | Payment Block 제어값 |

---

# 3. Weight Rule

가중치는 관리자가 설정한다.

조건

```
Wfin + Wven + Wtime = 1
```

예시

| Weight | Value |
| ------ | ----: |
| Wfin   |   0.4 |
| Wven   |   0.3 |
| Wtime  |   0.3 |

---

# 4. Financial Score (Sfin)

재무 점수는 지급 시 발생하는 재무적 이익을 평가한다.

```
Net Benefit
=
Early Payment Discount
-
Late Payment Penalty
```

Net Benefit을 0~100 범위로 정규화하여 Sfin으로 사용한다.

---

# 5. Vendor Score (Sven)

Vendor Evaluation Table

| 평가 항목    | 최대 점수 |
| -------- | ----: |
| 대체 공급사 수 |    40 |
| 생산 직결성   |    30 |
| 리드타임     |    15 |
| 연간 매입 규모 |    15 |

총점은 100점이다.

평가표에서 계산된 점수를 그대로 Sven으로 사용한다.

예시

```
92점

↓

Sven = 92
```

Vendor Grade는 화면 표시용이다.

|   Sven | Grade |
| -----: | ----- |
| 90~100 | S     |
|  70~89 | A     |
|  40~69 | B     |
|   0~39 | C     |

---

# 6. Due Date Score (Stime)

| Due Date | Score |
| -------- | ----: |
| 30일 이상   |    10 |
| 15~29일   |    30 |
| 7~14일    |    60 |
| 3~6일     |    80 |
| 0~2일     |   100 |
| Overdue  |   100 |

---

# 7. Payment Block Rule

Payment Block이 존재하는 Invoice는 Priority 계산 대상에서 제외한다.

```
Payment Block

↓

Status = HOLD

↓

Priority 계산 제외

↓

Approval 대상 제외
```

---

# 8. Recommendation Rule

| Priority Score | Recommendation  |
| -------------- | --------------- |
| 90~100         | Pay Immediately |
| 70~89          | Recommended     |
| 50~69          | Review          |
| 0~49           | Hold            |

---

# 9. Invoice Priority Rule

Priority Score는 Invoice별로 계산한다.

Simulation 화면에서는 다음 정보를 집계하여 표시한다.

* Total Payment Amount
* Total Discount
* Total Penalty
* Available Cash After Payment
