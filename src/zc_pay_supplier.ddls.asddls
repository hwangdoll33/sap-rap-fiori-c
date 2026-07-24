@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PayWise Supplier Consumption View'
define view entity ZC_PAY_SUPPLIER
  as select from ZI_PAY_SUPPLIER
{
  key SupplierUUID,
      @EndUserText.label: 'Supplier ID'
      SupplierId,
      @EndUserText.label: 'Supplier Name'
      SupplierName,
      @EndUserText.label: 'Importance Level'
      ImportanceLevel,
      @EndUserText.label: 'Supplier Grade'
      SupplierGrade,
      LastChangedAt
}
