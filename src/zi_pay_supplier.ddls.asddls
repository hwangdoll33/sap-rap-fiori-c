@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PayWise Supplier Interface View'
define view entity ZI_PAY_SUPPLIER
  as select from zpay_supplier
{
  key supplier_uuid         as SupplierUUID,
      supplier_id           as SupplierId,
      supplier_name         as SupplierName,
      importance_level      as ImportanceLevel,
      // Vendor grade for display: 5=S, 4=A, 3/2=B, 1=C (Sven = level * 20)
      case
        when importance_level >= 5 then 'S'
        when importance_level  = 4 then 'A'
        when importance_level >= 2 then 'B'
        else 'C'
      end                   as SupplierGrade,
      created_by            as CreatedBy,
      created_at            as CreatedAt,
      local_last_changed_by as LocalLastChangedBy,
      local_last_changed_at as LocalLastChangedAt,
      last_changed_at       as LastChangedAt
}
