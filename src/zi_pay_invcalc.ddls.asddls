@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PayWise Invoice Basic Calculations'
define view entity ZI_PAY_INVCALC
  as select from zpay_invoice
{
  key invoice_uuid          as InvoiceUUID,
      invoice_id            as InvoiceId,
      company_code          as CompanyCode,
      supplier_uuid         as SupplierUUID,
      invoice_date          as InvoiceDate,
      baseline_date         as BaselineDate,
      payment_terms         as PaymentTerms,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      gross_amount          as GrossAmount,
      currency_code         as CurrencyCode,
      discount_percent      as DiscountPercent,
      discount_deadline     as DiscountDeadline,
      late_penalty_percent  as LatePenaltyPercent,
      due_date              as DueDate,
      payment_block         as PaymentBlock,
      payment_status        as PaymentStatus,
      simulated_paid_at     as SimulatedPaidAt,
      simulated_paid_by     as SimulatedPaidBy,
      created_by            as CreatedBy,
      created_at            as CreatedAt,
      local_last_changed_by as LocalLastChangedBy,
      local_last_changed_at as LocalLastChangedAt,
      last_changed_at       as LastChangedAt,

      // Days from today until due date (negative = overdue)
      dats_days_between( $session.system_date, due_date ) as DaysToDue,

      // Annualized cost of forgoing the cash discount (finance-team standard):
      // APR% = d / (100 - d) * 365 / (net days - discount days) * 100
      cast(
        case
          when discount_percent > 0
           and discount_deadline is not initial
           and discount_deadline >= $session.system_date
           and dats_days_between( discount_deadline, due_date ) > 0
          then division( discount_percent * 36500,
                         ( 100 - discount_percent )
                         * dats_days_between( discount_deadline, due_date ),
                         2 )
          else 0
        end as abap.dec(7,2) )                            as DiscountApr
}
