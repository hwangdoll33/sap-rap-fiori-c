@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PayWise Invoice Factor Scores'
define view entity ZI_PAY_INVSCORE
  as select from ZI_PAY_INVCALC
  association [0..1] to ZI_PAY_SUPPLIER as _Supplier
    on $projection.SupplierUUID = _Supplier.SupplierUUID
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

      // Flattened supplier attributes
      _Supplier.SupplierId                                as SupplierId,
      _Supplier.SupplierName                              as SupplierName,
      _Supplier.SupplierGrade                             as SupplierGrade,

      // Sfin: discount APR only, normalized linearly with cap APR 40% -> 100 points
      // Overdue and late-penalty priority are handled separately in ZI_PAY_INVOICE
      cast(
        case
          when DiscountApr >= 40                 then 100
          when DiscountApr > 0                   then division( DiscountApr * 5, 2, 1 )
          else 0
        end as abap.dec(5,1) )                            as FinancialScore,

      // Sven: importance level 1..5 -> 20..100
      cast(
        case
          when _Supplier.ImportanceLevel is null then 0
          else _Supplier.ImportanceLevel * 20
        end as abap.dec(5,1) )                            as SupplierScore,

      // Stime: continuous due-date proximity with 14-day half-score point
      // Score = 100 * 14^2 / ( 14^2 + days-to-due^2 ); due/overdue = 100
      cast(
        case
          when DaysToDue <= 0 then 100
          else division(
                 19600,
                 196
                 + cast( DaysToDue as abap.dec(15,0) )
                 * cast( DaysToDue as abap.dec(15,0) ),
                 1 )
        end as abap.dec(5,1) )                            as TimeScore,

      _Supplier
}
