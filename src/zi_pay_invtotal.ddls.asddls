@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PayWise Invoice Total Priority Score'
define view entity ZI_PAY_INVTOTAL
  as select from ZI_PAY_INVSCORE
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

      // Ptotal = 0.4 * Sfin + 0.3 * Sven + 0.3 * Stime, blocked invoices excluded
      cast(
        case
          when PaymentBlock <> '' then 0
          else division( FinancialScore * 4 + SupplierScore * 3 + TimeScore * 3,
                         10, 1 )
        end as abap.dec(5,1) )                            as TotalScore,

      _Supplier
}
