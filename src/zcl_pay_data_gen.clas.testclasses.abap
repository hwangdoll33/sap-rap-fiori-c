CLASS ltc_pay_data_gen DEFINITION
  FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    METHODS validates_fixed_context FOR TESTING.
ENDCLASS.

CLASS ltc_pay_data_gen IMPLEMENTATION.
  METHOD validates_fixed_context.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_pay_data_gen=>gc_company_code
      exp = '1000' ).

    cl_abap_unit_assert=>assert_equals(
      act = zcl_pay_data_gen=>gc_currency
      exp = 'KRW' ).
  ENDMETHOD.
ENDCLASS.
