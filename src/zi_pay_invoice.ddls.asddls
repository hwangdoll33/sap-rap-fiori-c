@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PayWise Invoice Root Interface View'
define root view entity ZI_PAY_INVOICE
  as select from ZI_PAY_INVTOTAL
{
  key InvoiceUUID,
      InvoiceId,
      CompanyCode,
      SupplierUUID,
      InvoiceDate,
      BaselineDate,
      PaymentTerms,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      GrossAmount,
      CurrencyCode,
      DiscountPercent,
      DiscountDeadline,
      LatePenaltyPercent,
      DueDate,
      PaymentBlock,
      PaymentStatus,
      SimulatedPaidAt,
      SimulatedPaidBy,
      CreatedBy,
      CreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      DaysToDue,
      DiscountApr,
      SupplierId,
      SupplierName,
      SupplierGrade,
      FinancialScore,
      SupplierScore,
      TimeScore,
      TotalScore,

      // Final ranking group: overdue eligible, normal eligible, blocked, paid
      cast(
        case
          when PaymentStatus = 'PAID'         then 4
          when PaymentBlock <> ''             then 3
          when DueDate < $session.system_date then 1
          else 2
        end as abap.int1 )                                as PriorityGroup,

      // Within the overdue group, penalty-bearing invoices come first
      cast(
        case
          when PaymentStatus <> 'PAID'
           and PaymentBlock = ''
           and DueDate < $session.system_date
           and LatePenaltyPercent > 0          then 1
          else 0
        end as abap.int1 )                                as PenaltyIndicator,

      // Positive overdue days for descending sort; zero outside eligible overdue group
      cast(
        case
          when PaymentStatus <> 'PAID'
           and PaymentBlock = ''
           and DueDate < $session.system_date
            then DaysToDue * -1
          else 0
        end as abap.int4 )                                as DaysOverdue,

      // Status rules take precedence over score-based recommendation thresholds
      cast(
        case
          when PaymentStatus = 'PAID'         then 'PAID'
          when PaymentBlock <> ''             then 'BLK'
          when DueDate < $session.system_date then 'OVD'
          when TotalScore >= 90                then 'PAY'
          when TotalScore >= 70                then 'REC'
          when TotalScore >= 50                then 'REV'
          else 'HLD'
        end as abap.char(4) )                             as RecommendationCode,

      cast(
        case
          when PaymentStatus = 'PAID'         then 'Paid'
          when PaymentBlock <> ''             then 'Blocked'
          when DueDate < $session.system_date then 'Overdue - Highest Priority'
          when TotalScore >= 90                then 'Pay Immediately'
          when TotalScore >= 70                then 'Recommended'
          when TotalScore >= 50                then 'Review'
          else 'Hold'
        end as abap.char(30) )                            as RecommendationText,

      // Human-readable recommendation reason (dominant driver)
      cast(
        case
          when PaymentStatus = 'PAID'
            then 'Already paid via payment simulation'
          when PaymentBlock <> ''
            then 'Payment block set - excluded from priority ranking'
          when DueDate < $session.system_date and LatePenaltyPercent > 0
            then 'Overdue - late payment penalty is accruing'
          when DueDate < $session.system_date
            then 'Overdue - highest priority for payment'
          when DiscountApr >= 40
            then 'Early payment discount is highly attractive (APR 40%+)'
          when DiscountApr > 0
            then 'Cash discount available until discount deadline'
          when DaysToDue <= 6
            then 'Due date is imminent'
          else 'No urgent financial driver - pay at due date'
        end as abap.char(60) )                            as RecommendationReason,

      // UI criticality: 1=red(urgent), 2=yellow, 3=green, 0=neutral
      cast(
        case
          when PaymentStatus = 'PAID'         then 0
          when PaymentBlock <> ''             then 0
          when DueDate < $session.system_date then 1
          when TotalScore >= 90                then 1
          when TotalScore >= 70                then 2
          when TotalScore >= 50                then 3
          else 0
        end as abap.int1 )                                as ScoreCriticality,

      _Supplier
}
