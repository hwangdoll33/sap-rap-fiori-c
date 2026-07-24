@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PayWise Invoice Projection View'
@Metadata.allowExtensions: true
define root view entity ZC_PAY_INVOICE
  provider contract transactional_query
  as projection on ZI_PAY_INVOICE
{
  key InvoiceUUID,
      @EndUserText.label: 'Invoice'
      InvoiceId,
      @EndUserText.label: 'Company Code'
      CompanyCode,
      SupplierUUID,
      @EndUserText.label: 'Supplier ID'
      SupplierId,
      @EndUserText.label: 'Supplier'
      SupplierName,
      @EndUserText.label: 'Supplier Grade'
      SupplierGrade,
      @EndUserText.label: 'Invoice Date'
      InvoiceDate,
      @EndUserText.label: 'Baseline Date'
      BaselineDate,
      @EndUserText.label: 'Payment Terms'
      PaymentTerms,
      @EndUserText.label: 'Gross Amount'
      GrossAmount,
      CurrencyCode,
      @EndUserText.label: 'Discount %'
      DiscountPercent,
      @EndUserText.label: 'Discount Deadline'
      DiscountDeadline,
      @EndUserText.label: 'Late Penalty % p.a.'
      LatePenaltyPercent,
      @EndUserText.label: 'Due Date'
      DueDate,
      @EndUserText.label: 'Days to Due'
      DaysToDue,
      @EndUserText.label: 'Days Overdue'
      DaysOverdue,
      @EndUserText.label: 'Discount APR %'
      DiscountApr,
      @EndUserText.label: 'Payment Block'
      PaymentBlock,
      @EndUserText.label: 'Status'
      PaymentStatus,
      @EndUserText.label: 'Financial Score'
      FinancialScore,
      @EndUserText.label: 'Supplier Score'
      SupplierScore,
      @EndUserText.label: 'Due Date Score'
      TimeScore,
      @EndUserText.label: 'Priority Score'
      TotalScore,
      @EndUserText.label: 'Priority Group'
      PriorityGroup,
      @EndUserText.label: 'Penalty Priority'
      PenaltyIndicator,
      @EndUserText.label: 'Recommendation Code'
      RecommendationCode,
      @EndUserText.label: 'Recommendation'
      RecommendationText,
      @EndUserText.label: 'Recommendation Reason'
      RecommendationReason,
      ScoreCriticality,
      @EndUserText.label: 'Simulated Paid At'
      SimulatedPaidAt,
      @EndUserText.label: 'Simulated Paid By'
      SimulatedPaidBy,
      LastChangedAt
}
