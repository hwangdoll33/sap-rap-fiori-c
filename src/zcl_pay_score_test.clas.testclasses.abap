CLASS ltc_pay_scoring DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CLASS-DATA environment TYPE REF TO if_cds_test_environment.

    CONSTANTS:
      gc_sup_uuid TYPE sysuuid_x16 VALUE '11111111111111111111111111111111',
      gc_inv_uuid TYPE sysuuid_x16 VALUE '22222222222222222222222222222222'.

    DATA today TYPE d.

    CLASS-METHODS class_setup.
    CLASS-METHODS class_teardown.
    METHODS setup.

    METHODS prepare_data
      IMPORTING importance       TYPE i DEFAULT 2
                discount         TYPE zpay_invoice-discount_percent DEFAULT 0
                deadline         TYPE d OPTIONAL
                due              TYPE d
                penalty          TYPE zpay_invoice-late_penalty_percent DEFAULT 0
                block            TYPE zpay_invoice-payment_block DEFAULT ''
                status           TYPE zpay_invoice-payment_status DEFAULT 'OPEN'.

    METHODS read_result
      RETURNING VALUE(result) TYPE zi_pay_invoice.

    METHODS assert_time_score
      IMPORTING days_to_due TYPE i
                expected    TYPE zi_pay_invoice-TimeScore.

    "! Sfin: APR 37.24% -> 93.1 points; continuous Stime at 25 days = 23.9
    METHODS discount_apr_normalized       FOR TESTING.
    "! Sfin: expired discount deadline yields zero financial score
    METHODS expired_discount_is_zero      FOR TESTING.
    "! Overdue penalty is a ranking key, not a financial-score override
    METHODS overdue_penalty_priority      FOR TESTING.
    "! Overdue without penalty remains highest group but has no penalty priority
    METHODS overdue_without_penalty       FOR TESTING.
    "! Paid invoices are placed after actionable and blocked invoices
    METHODS paid_priority_excluded        FOR TESTING.
    "! Stime: due today scores 100 but is not overdue
    METHODS due_today_time_100            FOR TESTING.
    "! Stime: continuous curve at approved future-day checkpoints
    METHODS continuous_time_curve          FOR TESTING.
    "! Stime: overdue also scores 100
    METHODS overdue_time_100              FOR TESTING.
    "! Sven: importance 5 maps to 100 and grade S
    METHODS supplier_level5_is_100        FOR TESTING.
    "! Sven: importance 1 maps to 20 and grade C
    METHODS supplier_level1_is_20         FOR TESTING.
    "! Payment block excludes invoice from actionable priority
    METHODS blocked_total_zero            FOR TESTING.
ENDCLASS.


CLASS ltc_pay_scoring IMPLEMENTATION.

  METHOD class_setup.
    environment = cl_cds_test_environment=>create(
      i_for_entity      = 'ZI_PAY_INVOICE'
      i_dependency_list = VALUE #( ( name = 'ZPAY_INVOICE'  type = 'TABLE' )
                                   ( name = 'ZPAY_SUPPLIER' type = 'TABLE' ) ) ).
  ENDMETHOD.

  METHOD class_teardown.
    environment->destroy( ).
  ENDMETHOD.

  METHOD setup.
    environment->clear_doubles( ).
    today = cl_abap_context_info=>get_system_date( ).
  ENDMETHOD.

  METHOD prepare_data.
    DATA suppliers TYPE STANDARD TABLE OF zpay_supplier WITH EMPTY KEY.
    DATA invoices  TYPE STANDARD TABLE OF zpay_invoice WITH EMPTY KEY.

    suppliers = VALUE #( ( supplier_uuid    = gc_sup_uuid
                           supplier_id      = 'TSUP01'
                           supplier_name    = 'Test Supplier'
                           importance_level = importance ) ).

    invoices = VALUE #( ( invoice_uuid         = gc_inv_uuid
                          invoice_id           = 'TINV01'
                          company_code         = '1000'
                          supplier_uuid        = gc_sup_uuid
                          invoice_date         = CONV d( today - 10 )
                          baseline_date        = CONV d( today - 10 )
                          payment_terms        = 'TEST'
                          gross_amount         = '1000000.00'
                          currency_code        = 'KRW'
                          discount_percent     = discount
                          discount_deadline    = deadline
                          late_penalty_percent = penalty
                          due_date             = due
                          payment_block        = block
                          payment_status       = status ) ).

    environment->insert_test_data( i_data = suppliers ).
    environment->insert_test_data( i_data = invoices ).
  ENDMETHOD.

  METHOD read_result.
    SELECT SINGLE * FROM zi_pay_invoice
      WHERE InvoiceId = 'TINV01'
      INTO CORRESPONDING FIELDS OF @result.
  ENDMETHOD.

  METHOD assert_time_score.
    environment->clear_doubles( ).
    prepare_data( due = CONV d( today + days_to_due ) ).
    DATA(result) = read_result( ).

    cl_abap_unit_assert=>assert_equals(
      act = result-TimeScore
      exp = expected
      msg = |Unexpected TimeScore for { days_to_due } days to due| ).
  ENDMETHOD.

  METHOD discount_apr_normalized.
    " 2% discount, 20 days between deadline and due date:
    " APR = 2/98 * 365/20 * 100 = 37.24 -> Sfin = 37.24 * 2.5 = 93.1
    prepare_data( importance = 2
                  discount   = '2.00'
                  deadline   = CONV d( today + 5 )
                  due        = CONV d( today + 25 ) ).
    DATA(result) = read_result( ).

    cl_abap_unit_assert=>assert_equals( act = result-DiscountApr
                                        exp = CONV zi_pay_invoice-DiscountApr( '37.24' ) ).
    cl_abap_unit_assert=>assert_equals( act = result-FinancialScore
                                        exp = CONV zi_pay_invoice-FinancialScore( '93.1' ) ).
    cl_abap_unit_assert=>assert_equals( act = result-SupplierScore
                                        exp = CONV zi_pay_invoice-SupplierScore( '40.0' ) ).
    cl_abap_unit_assert=>assert_equals( act = result-TimeScore
                                        exp = CONV zi_pay_invoice-TimeScore( '23.9' ) ).
    " Ptotal = 0.4*93.1 + 0.3*40 + 0.3*23.9 = 56.4
    cl_abap_unit_assert=>assert_equals( act = result-TotalScore
                                        exp = CONV zi_pay_invoice-TotalScore( '56.4' ) ).
    cl_abap_unit_assert=>assert_equals( act = result-PriorityGroup
                                        exp = CONV zi_pay_invoice-PriorityGroup( 2 ) ).
  ENDMETHOD.

  METHOD expired_discount_is_zero.
    prepare_data( discount = '1.50'
                  deadline = CONV d( today - 1 )
                  due      = CONV d( today + 10 ) ).
    DATA(result) = read_result( ).

    cl_abap_unit_assert=>assert_equals( act = result-DiscountApr
                                        exp = CONV zi_pay_invoice-DiscountApr( '0.00' ) ).
    cl_abap_unit_assert=>assert_equals( act = result-FinancialScore
                                        exp = CONV zi_pay_invoice-FinancialScore( '0.0' ) ).
  ENDMETHOD.

  METHOD overdue_penalty_priority.
    prepare_data( penalty = '6.00'
                  due     = CONV d( today - 10 ) ).
    DATA(result) = read_result( ).

    cl_abap_unit_assert=>assert_equals( act = result-FinancialScore
                                        exp = CONV zi_pay_invoice-FinancialScore( '0.0' ) ).
    cl_abap_unit_assert=>assert_equals( act = result-TotalScore
                                        exp = CONV zi_pay_invoice-TotalScore( '42.0' ) ).
    cl_abap_unit_assert=>assert_equals( act = result-PriorityGroup
                                        exp = CONV zi_pay_invoice-PriorityGroup( 1 ) ).
    cl_abap_unit_assert=>assert_equals( act = result-PenaltyIndicator
                                        exp = CONV zi_pay_invoice-PenaltyIndicator( 1 ) ).
    cl_abap_unit_assert=>assert_equals( act = result-DaysOverdue
                                        exp = 10 ).
    cl_abap_unit_assert=>assert_equals( act = result-RecommendationCode
                                        exp = 'OVD' ).
  ENDMETHOD.

  METHOD overdue_without_penalty.
    prepare_data( due = CONV d( today - 3 ) ).
    DATA(result) = read_result( ).

    cl_abap_unit_assert=>assert_equals( act = result-PriorityGroup
                                        exp = CONV zi_pay_invoice-PriorityGroup( 1 ) ).
    cl_abap_unit_assert=>assert_equals( act = result-PenaltyIndicator
                                        exp = CONV zi_pay_invoice-PenaltyIndicator( 0 ) ).
    cl_abap_unit_assert=>assert_equals( act = result-DaysOverdue
                                        exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = result-RecommendationCode
                                        exp = 'OVD' ).
  ENDMETHOD.

  METHOD paid_priority_excluded.
    prepare_data( penalty = '6.00'
                  due     = CONV d( today - 5 )
                  status  = 'PAID' ).
    DATA(result) = read_result( ).

    cl_abap_unit_assert=>assert_equals( act = result-PriorityGroup
                                        exp = CONV zi_pay_invoice-PriorityGroup( 4 ) ).
    cl_abap_unit_assert=>assert_equals( act = result-PenaltyIndicator
                                        exp = CONV zi_pay_invoice-PenaltyIndicator( 0 ) ).
    cl_abap_unit_assert=>assert_equals( act = result-DaysOverdue
                                        exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = result-RecommendationCode
                                        exp = 'PAID' ).
    cl_abap_unit_assert=>assert_equals( act = result-ScoreCriticality
                                        exp = CONV zi_pay_invoice-ScoreCriticality( 0 ) ).
  ENDMETHOD.

  METHOD due_today_time_100.
    prepare_data( due = today ).
    DATA(result) = read_result( ).

    cl_abap_unit_assert=>assert_equals( act = result-TimeScore
                                        exp = CONV zi_pay_invoice-TimeScore( '100.0' ) ).
    cl_abap_unit_assert=>assert_equals( act = result-PriorityGroup
                                        exp = CONV zi_pay_invoice-PriorityGroup( 2 ) ).
  ENDMETHOD.

  METHOD continuous_time_curve.
    assert_time_score( days_to_due =  2
                       expected    = CONV #( '98.0' ) ).
    assert_time_score( days_to_due =  6
                       expected    = CONV #( '84.5' ) ).
    assert_time_score( days_to_due =  7
                       expected    = CONV #( '80.0' ) ).
    assert_time_score( days_to_due = 14
                       expected    = CONV #( '50.0' ) ).
    assert_time_score( days_to_due = 21
                       expected    = CONV #( '30.8' ) ).
    assert_time_score( days_to_due = 30
                       expected    = CONV #( '17.9' ) ).
    assert_time_score( days_to_due = 45
                       expected    = CONV #( '8.8' ) ).
  ENDMETHOD.

  METHOD overdue_time_100.
    prepare_data( due = CONV d( today - 3 ) ).
    DATA(result) = read_result( ).

    cl_abap_unit_assert=>assert_equals( act = result-TimeScore
                                        exp = CONV zi_pay_invoice-TimeScore( '100.0' ) ).
  ENDMETHOD.

  METHOD supplier_level5_is_100.
    prepare_data( importance = 5
                  due        = CONV d( today + 20 ) ).
    DATA(result) = read_result( ).

    cl_abap_unit_assert=>assert_equals( act = result-SupplierScore
                                        exp = CONV zi_pay_invoice-SupplierScore( '100.0' ) ).
    cl_abap_unit_assert=>assert_equals( act = result-SupplierGrade
                                        exp = 'S' ).
  ENDMETHOD.

  METHOD supplier_level1_is_20.
    prepare_data( importance = 1
                  due        = CONV d( today + 20 ) ).
    DATA(result) = read_result( ).

    cl_abap_unit_assert=>assert_equals( act = result-SupplierScore
                                        exp = CONV zi_pay_invoice-SupplierScore( '20.0' ) ).
    cl_abap_unit_assert=>assert_equals( act = result-SupplierGrade
                                        exp = 'C' ).
  ENDMETHOD.

  METHOD blocked_total_zero.
    prepare_data( importance = 5
                  penalty    = '6.00'
                  due        = CONV d( today - 5 )
                  block      = 'A' ).
    DATA(result) = read_result( ).

    cl_abap_unit_assert=>assert_equals( act = result-TotalScore
                                        exp = CONV zi_pay_invoice-TotalScore( '0.0' ) ).
    cl_abap_unit_assert=>assert_equals( act = result-PriorityGroup
                                        exp = CONV zi_pay_invoice-PriorityGroup( 3 ) ).
    cl_abap_unit_assert=>assert_equals( act = result-PenaltyIndicator
                                        exp = CONV zi_pay_invoice-PenaltyIndicator( 0 ) ).
    cl_abap_unit_assert=>assert_equals( act = result-DaysOverdue
                                        exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = result-RecommendationCode
                                        exp = 'BLK' ).
  ENDMETHOD.

ENDCLASS.
