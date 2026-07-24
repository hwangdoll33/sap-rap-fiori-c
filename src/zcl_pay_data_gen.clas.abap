CLASS zcl_pay_data_gen DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

    CONSTANTS:
      gc_company_code TYPE zpay_invoice-company_code VALUE '1000',
      gc_currency     TYPE zpay_invoice-currency_code VALUE 'KRW'.
ENDCLASS.

CLASS zcl_pay_data_gen IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA suppliers TYPE STANDARD TABLE OF zpay_supplier WITH EMPTY KEY.
    DATA invoices  TYPE STANDARD TABLE OF zpay_invoice WITH EMPTY KEY.
    DATA timestamp TYPE timestampl.

    DATA(today) = cl_abap_context_info=>get_system_date( ).
    GET TIME STAMP FIELD timestamp.

    TRY.
        DATA(supplier_1) = cl_system_uuid=>create_uuid_x16_static( ).
        DATA(supplier_2) = cl_system_uuid=>create_uuid_x16_static( ).
        DATA(supplier_3) = cl_system_uuid=>create_uuid_x16_static( ).
        DATA(supplier_4) = cl_system_uuid=>create_uuid_x16_static( ).
        DATA(supplier_5) = cl_system_uuid=>create_uuid_x16_static( ).

        suppliers = VALUE #(
          ( supplier_uuid = supplier_1 supplier_id = 'SUP0001'
            supplier_name = 'Hanul Office Supplies' importance_level = 1
            created_by = sy-uname created_at = timestamp
            local_last_changed_by = sy-uname local_last_changed_at = timestamp
            last_changed_at = timestamp )
          ( supplier_uuid = supplier_2 supplier_id = 'SUP0002'
            supplier_name = 'Mirae Logistics' importance_level = 2
            created_by = sy-uname created_at = timestamp
            local_last_changed_by = sy-uname local_last_changed_at = timestamp
            last_changed_at = timestamp )
          ( supplier_uuid = supplier_3 supplier_id = 'SUP0003'
            supplier_name = 'Daehan Components' importance_level = 3
            created_by = sy-uname created_at = timestamp
            local_last_changed_by = sy-uname local_last_changed_at = timestamp
            last_changed_at = timestamp )
          ( supplier_uuid = supplier_4 supplier_id = 'SUP0004'
            supplier_name = 'Seoul IT Services' importance_level = 4
            created_by = sy-uname created_at = timestamp
            local_last_changed_by = sy-uname local_last_changed_at = timestamp
            last_changed_at = timestamp )
          ( supplier_uuid = supplier_5 supplier_id = 'SUP0005'
            supplier_name = 'Korea Strategic Materials' importance_level = 5
            created_by = sy-uname created_at = timestamp
            local_last_changed_by = sy-uname local_last_changed_at = timestamp
            last_changed_at = timestamp ) ).

        " Boundary-case coverage:
        "  PWI0001 no discount, mid-term due          PWI0002 active cash discount (2/10 net 30)
        "  PWI0003 expired discount, due soon         PWI0004 due today
        "  PWI0005 overdue + penalty accruing         PWI0006 overdue, no penalty
        "  PWI0007 payment block (HOLD)               PWI0008 strategic supplier + discount
        "  PWI0009 low importance, far due            PWI0010 discount deadline today
        "  PWI0011 penalty rate, due in 6 days        PWI0012 due in 15 days
        "  PWI0013 already PAID                       PWI0014 already PAID
        invoices = VALUE #(
          ( invoice_uuid = cl_system_uuid=>create_uuid_x16_static( )
            invoice_id = 'PWI0001' company_code = gc_company_code
            supplier_uuid = supplier_1 invoice_date = today - 20
            baseline_date = today - 20 payment_terms = 'NET30'
            gross_amount = '1250000.00' currency_code = gc_currency
            discount_percent = '0.00' late_penalty_percent = '0.00'
            due_date = today + 10 payment_status = 'OPEN'
            created_by = sy-uname created_at = timestamp
            local_last_changed_by = sy-uname local_last_changed_at = timestamp
            last_changed_at = timestamp )
          ( invoice_uuid = cl_system_uuid=>create_uuid_x16_static( )
            invoice_id = 'PWI0002' company_code = gc_company_code
            supplier_uuid = supplier_2 invoice_date = today - 5
            baseline_date = today - 5 payment_terms = '2/10NET30'
            gross_amount = '2400000.00' currency_code = gc_currency
            discount_percent = '2.00' discount_deadline = today + 5
            late_penalty_percent = '0.00'
            due_date = today + 25 payment_status = 'OPEN'
            created_by = sy-uname created_at = timestamp
            local_last_changed_by = sy-uname local_last_changed_at = timestamp
            last_changed_at = timestamp )
          ( invoice_uuid = cl_system_uuid=>create_uuid_x16_static( )
            invoice_id = 'PWI0003' company_code = gc_company_code
            supplier_uuid = supplier_3 invoice_date = today - 30
            baseline_date = today - 30 payment_terms = '1.5/10NET30'
            gross_amount = '3750000.00' currency_code = gc_currency
            discount_percent = '1.50' discount_deadline = today - 5
            late_penalty_percent = '0.00'
            due_date = today + 3 payment_status = 'OPEN'
            created_by = sy-uname created_at = timestamp
            local_last_changed_by = sy-uname local_last_changed_at = timestamp
            last_changed_at = timestamp )
          ( invoice_uuid = cl_system_uuid=>create_uuid_x16_static( )
            invoice_id = 'PWI0004' company_code = gc_company_code
            supplier_uuid = supplier_2 invoice_date = today - 30
            baseline_date = today - 30 payment_terms = 'NET30'
            gross_amount = '860000.00' currency_code = gc_currency
            discount_percent = '0.00' late_penalty_percent = '0.00'
            due_date = today payment_status = 'OPEN'
            created_by = sy-uname created_at = timestamp
            local_last_changed_by = sy-uname local_last_changed_at = timestamp
            last_changed_at = timestamp )
          ( invoice_uuid = cl_system_uuid=>create_uuid_x16_static( )
            invoice_id = 'PWI0005' company_code = gc_company_code
            supplier_uuid = supplier_4 invoice_date = today - 40
            baseline_date = today - 40 payment_terms = 'NET30'
            gross_amount = '5200000.00' currency_code = gc_currency
            discount_percent = '0.00' late_penalty_percent = '6.00'
            due_date = today - 10 payment_status = 'OPEN'
            created_by = sy-uname created_at = timestamp
            local_last_changed_by = sy-uname local_last_changed_at = timestamp
            last_changed_at = timestamp )
          ( invoice_uuid = cl_system_uuid=>create_uuid_x16_static( )
            invoice_id = 'PWI0006' company_code = gc_company_code
            supplier_uuid = supplier_1 invoice_date = today - 33
            baseline_date = today - 33 payment_terms = 'NET30'
            gross_amount = '430000.00' currency_code = gc_currency
            discount_percent = '0.00' late_penalty_percent = '0.00'
            due_date = today - 3 payment_status = 'OPEN'
            created_by = sy-uname created_at = timestamp
            local_last_changed_by = sy-uname local_last_changed_at = timestamp
            last_changed_at = timestamp )
          ( invoice_uuid = cl_system_uuid=>create_uuid_x16_static( )
            invoice_id = 'PWI0007' company_code = gc_company_code
            supplier_uuid = supplier_3 invoice_date = today - 15
            baseline_date = today - 15 payment_terms = 'NET30'
            gross_amount = '1980000.00' currency_code = gc_currency
            discount_percent = '0.00' late_penalty_percent = '0.00'
            due_date = today + 5 payment_block = 'A'
            payment_status = 'OPEN'
            created_by = sy-uname created_at = timestamp
            local_last_changed_by = sy-uname local_last_changed_at = timestamp
            last_changed_at = timestamp )
          ( invoice_uuid = cl_system_uuid=>create_uuid_x16_static( )
            invoice_id = 'PWI0008' company_code = gc_company_code
            supplier_uuid = supplier_5 invoice_date = today - 3
            baseline_date = today - 3 payment_terms = '2/10NET45'
            gross_amount = '8700000.00' currency_code = gc_currency
            discount_percent = '2.00' discount_deadline = today + 7
            late_penalty_percent = '0.00'
            due_date = today + 42 payment_status = 'OPEN'
            created_by = sy-uname created_at = timestamp
            local_last_changed_by = sy-uname local_last_changed_at = timestamp
            last_changed_at = timestamp )
          ( invoice_uuid = cl_system_uuid=>create_uuid_x16_static( )
            invoice_id = 'PWI0009' company_code = gc_company_code
            supplier_uuid = supplier_1 invoice_date = today
            baseline_date = today payment_terms = 'NET45'
            gross_amount = '320000.00' currency_code = gc_currency
            discount_percent = '0.00' late_penalty_percent = '0.00'
            due_date = today + 45 payment_status = 'OPEN'
            created_by = sy-uname created_at = timestamp
            local_last_changed_by = sy-uname local_last_changed_at = timestamp
            last_changed_at = timestamp )
          ( invoice_uuid = cl_system_uuid=>create_uuid_x16_static( )
            invoice_id = 'PWI0010' company_code = gc_company_code
            supplier_uuid = supplier_4 invoice_date = today - 10
            baseline_date = today - 10 payment_terms = '1/10NET30'
            gross_amount = '2150000.00' currency_code = gc_currency
            discount_percent = '1.00' discount_deadline = today
            late_penalty_percent = '0.00'
            due_date = today + 20 payment_status = 'OPEN'
            created_by = sy-uname created_at = timestamp
            local_last_changed_by = sy-uname local_last_changed_at = timestamp
            last_changed_at = timestamp )
          ( invoice_uuid = cl_system_uuid=>create_uuid_x16_static( )
            invoice_id = 'PWI0011' company_code = gc_company_code
            supplier_uuid = supplier_5 invoice_date = today - 24
            baseline_date = today - 24 payment_terms = 'NET30'
            gross_amount = '6600000.00' currency_code = gc_currency
            discount_percent = '0.00' late_penalty_percent = '8.00'
            due_date = today + 6 payment_status = 'OPEN'
            created_by = sy-uname created_at = timestamp
            local_last_changed_by = sy-uname local_last_changed_at = timestamp
            last_changed_at = timestamp )
          ( invoice_uuid = cl_system_uuid=>create_uuid_x16_static( )
            invoice_id = 'PWI0012' company_code = gc_company_code
            supplier_uuid = supplier_2 invoice_date = today - 15
            baseline_date = today - 15 payment_terms = 'NET30'
            gross_amount = '1120000.00' currency_code = gc_currency
            discount_percent = '0.00' late_penalty_percent = '0.00'
            due_date = today + 15 payment_status = 'OPEN'
            created_by = sy-uname created_at = timestamp
            local_last_changed_by = sy-uname local_last_changed_at = timestamp
            last_changed_at = timestamp )
          ( invoice_uuid = cl_system_uuid=>create_uuid_x16_static( )
            invoice_id = 'PWI0013' company_code = gc_company_code
            supplier_uuid = supplier_3 invoice_date = today - 50
            baseline_date = today - 50 payment_terms = 'NET30'
            gross_amount = '2750000.00' currency_code = gc_currency
            discount_percent = '0.00' late_penalty_percent = '0.00'
            due_date = today - 20 payment_status = 'PAID'
            simulated_paid_at = timestamp simulated_paid_by = sy-uname
            created_by = sy-uname created_at = timestamp
            local_last_changed_by = sy-uname local_last_changed_at = timestamp
            last_changed_at = timestamp )
          ( invoice_uuid = cl_system_uuid=>create_uuid_x16_static( )
            invoice_id = 'PWI0014' company_code = gc_company_code
            supplier_uuid = supplier_5 invoice_date = today - 35
            baseline_date = today - 35 payment_terms = '2/10NET30'
            gross_amount = '4300000.00' currency_code = gc_currency
            discount_percent = '2.00' discount_deadline = today - 25
            late_penalty_percent = '0.00'
            due_date = today - 5 payment_status = 'PAID'
            simulated_paid_at = timestamp simulated_paid_by = sy-uname
            created_by = sy-uname created_at = timestamp
            local_last_changed_by = sy-uname local_last_changed_at = timestamp
            last_changed_at = timestamp ) ).

        DELETE FROM zpay_invoice.
        DELETE FROM zpay_supplier.

        INSERT zpay_supplier FROM TABLE @suppliers.
        DATA(supplier_count) = sy-dbcnt.
        INSERT zpay_invoice FROM TABLE @invoices.
        DATA(invoice_count) = sy-dbcnt.

        COMMIT WORK.

        out->write( |PayWise sample data regenerated.| ).
        out->write( |Suppliers inserted: { supplier_count }| ).
        out->write( |Invoices inserted:  { invoice_count }| ).

      CATCH cx_uuid_error INTO DATA(uuid_error).
        out->write( |UUID generation failed: { uuid_error->get_text( ) }| ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
