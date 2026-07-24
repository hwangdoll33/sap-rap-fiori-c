CLASS ltc_payment_action DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CLASS-DATA sql_environment TYPE REF TO if_osql_test_environment.

    CONSTANTS:
      gc_open_uuid     TYPE sysuuid_x16 VALUE 'BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB',
      gc_paid_uuid     TYPE sysuuid_x16 VALUE 'CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC',
      gc_blocked_uuid  TYPE sysuuid_x16 VALUE 'DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD'.

    CLASS-METHODS class_setup.
    CLASS-METHODS class_teardown.
    METHODS setup.
    METHODS teardown.

    "! Open invoice transitions to PAID with audit fields
    METHODS pay_open_invoice        FOR TESTING.
    "! Already-paid invoice is rejected (no double payment):
    "! instance feature control disables the action, framework fills FAILED
    METHODS reject_paid_invoice     FOR TESTING.
    "! Blocked invoice is rejected via instance feature control
    METHODS reject_blocked_invoice  FOR TESTING.
ENDCLASS.


CLASS ltc_payment_action IMPLEMENTATION.

  METHOD class_setup.
    " Managed RAP reads through the root CDS view, writes to the table:
    " both must be doubled.
    sql_environment = cl_osql_test_environment=>create(
      VALUE #( ( 'ZI_PAY_INVOICE' ) ( 'ZPAY_INVOICE' ) ) ).
  ENDMETHOD.

  METHOD class_teardown.
    sql_environment->destroy( ).
  ENDMETHOD.

  METHOD setup.
    sql_environment->clear_doubles( ).

    DATA(today) = cl_abap_context_info=>get_system_date( ).

    DATA view_rows TYPE STANDARD TABLE OF zi_pay_invoice WITH EMPTY KEY.
    view_rows = VALUE #(
      ( InvoiceUUID = gc_open_uuid    InvoiceId = 'TOPEN'
        CompanyCode = '1000' GrossAmount = '1000000.00' CurrencyCode = 'KRW'
        DueDate = CONV d( today + 10 ) PaymentStatus = 'OPEN' )
      ( InvoiceUUID = gc_paid_uuid    InvoiceId = 'TPAID'
        CompanyCode = '1000' GrossAmount = '2000000.00' CurrencyCode = 'KRW'
        DueDate = CONV d( today - 5 )  PaymentStatus = 'PAID' )
      ( InvoiceUUID = gc_blocked_uuid InvoiceId = 'TBLCK'
        CompanyCode = '1000' GrossAmount = '3000000.00' CurrencyCode = 'KRW'
        DueDate = CONV d( today + 5 )  PaymentBlock = 'A'
        PaymentStatus = 'OPEN' ) ).

    DATA table_rows TYPE STANDARD TABLE OF zpay_invoice WITH EMPTY KEY.
    table_rows = VALUE #(
      ( invoice_uuid = gc_open_uuid    invoice_id = 'TOPEN'
        company_code = '1000' gross_amount = '1000000.00'
        currency_code = 'KRW' due_date = CONV d( today + 10 )
        payment_status = 'OPEN' )
      ( invoice_uuid = gc_paid_uuid    invoice_id = 'TPAID'
        company_code = '1000' gross_amount = '2000000.00'
        currency_code = 'KRW' due_date = CONV d( today - 5 )
        payment_status = 'PAID' )
      ( invoice_uuid = gc_blocked_uuid invoice_id = 'TBLCK'
        company_code = '1000' gross_amount = '3000000.00'
        currency_code = 'KRW' due_date = CONV d( today + 5 )
        payment_block = 'A' payment_status = 'OPEN' ) ).

    sql_environment->insert_test_data( view_rows ).
    sql_environment->insert_test_data( table_rows ).
  ENDMETHOD.

  METHOD teardown.
    ROLLBACK ENTITIES.
  ENDMETHOD.

  METHOD pay_open_invoice.
    MODIFY ENTITIES OF zi_pay_invoice
      ENTITY Invoice
        EXECUTE simulatePayment
        FROM VALUE #( ( InvoiceUUID = gc_open_uuid ) )
      RESULT DATA(results)
      FAILED DATA(failed)
      REPORTED DATA(reported).

    cl_abap_unit_assert=>assert_initial( act = failed-invoice ).
    cl_abap_unit_assert=>assert_not_initial( act = results ).

    DATA(paid_invoice) = results[ 1 ]-%param.
    cl_abap_unit_assert=>assert_equals( act = paid_invoice-PaymentStatus
                                        exp = 'PAID' ).
    cl_abap_unit_assert=>assert_not_initial( act = paid_invoice-SimulatedPaidAt ).
    cl_abap_unit_assert=>assert_not_initial( act = paid_invoice-SimulatedPaidBy ).
  ENDMETHOD.

  METHOD reject_paid_invoice.
    MODIFY ENTITIES OF zi_pay_invoice
      ENTITY Invoice
        EXECUTE simulatePayment
        FROM VALUE #( ( InvoiceUUID = gc_paid_uuid ) )
      RESULT DATA(results)
      FAILED DATA(failed)
      REPORTED DATA(reported).

    " Instance feature control disables the action for paid invoices:
    " the framework rejects the request and fills FAILED, RESULT stays empty.
    cl_abap_unit_assert=>assert_not_initial( act = failed-invoice ).
    cl_abap_unit_assert=>assert_initial( act = results ).
  ENDMETHOD.

  METHOD reject_blocked_invoice.
    MODIFY ENTITIES OF zi_pay_invoice
      ENTITY Invoice
        EXECUTE simulatePayment
        FROM VALUE #( ( InvoiceUUID = gc_blocked_uuid ) )
      RESULT DATA(results)
      FAILED DATA(failed)
      REPORTED DATA(reported).

    " Instance feature control disables the action for blocked invoices.
    cl_abap_unit_assert=>assert_not_initial( act = failed-invoice ).
    cl_abap_unit_assert=>assert_initial( act = results ).
  ENDMETHOD.

ENDCLASS.
