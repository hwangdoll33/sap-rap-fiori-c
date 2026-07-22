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

        invoices = VALUE #(
          ( invoice_uuid = cl_system_uuid=>create_uuid_x16_static( )
            invoice_id = 'PWI0001' company_code = gc_company_code
            supplier_uuid = supplier_1 invoice_date = today - 20
            gross_amount = '1250000.00' currency_code = gc_currency
            discount_percent = '0.00' due_date = today + 10
            payment_status = 'OPEN'
            created_by = sy-uname created_at = timestamp
            local_last_changed_by = sy-uname local_last_changed_at = timestamp
            last_changed_at = timestamp )
          ( invoice_uuid = cl_system_uuid=>create_uuid_x16_static( )
            invoice_id = 'PWI0002' company_code = gc_company_code
            supplier_uuid = supplier_2 invoice_date = today - 10
            gross_amount = '2400000.00' currency_code = gc_currency
            discount_percent = '2.00' discount_deadline = today + 5
            due_date = today + 30 payment_status = 'OPEN'
            created_by = sy-uname created_at = timestamp
            local_last_changed_by = sy-uname local_last_changed_at = timestamp
            last_changed_at = timestamp )
          ( invoice_uuid = cl_system_uuid=>create_uuid_x16_static( )
            invoice_id = 'PWI0003' company_code = gc_company_code
            supplier_uuid = supplier_3 invoice_date = today - 30
            gross_amount = '3750000.00' currency_code = gc_currency
            discount_percent = '1.50' discount_deadline = today - 5
            due_date = today + 5 payment_status = 'OPEN'
            created_by = sy-uname created_at = timestamp
            local_last_changed_by = sy-uname local_last_changed_at = timestamp
            last_changed_at = timestamp )
          ( invoice_uuid = cl_system_uuid=>create_uuid_x16_static( )
            invoice_id = 'PWI0004' company_code = gc_company_code
            supplier_uuid = supplier_4 invoice_date = today - 25
            gross_amount = '5100000.00' currency_code = gc_currency
            discount_percent = '0.00' due_date = today
            payment_status = 'OPEN'
            created_by = sy-uname created_at = timestamp
            local_last_changed_by = sy-uname local_last_changed_at = timestamp
            last_changed_at = timestamp )
          ( invoice_uuid = cl_system_uuid=>create_uuid_x16_static( )
            invoice_id = 'PWI0005' company_code = gc_company_code
            supplier_uuid = supplier_5 invoice_date = today - 45
            gross_amount = '8200000.00' currency_code = gc_currency
            discount_percent = '3.00' discount_deadline = today - 20
            due_date = today - 10 payment_status = 'OPEN'
            created_by = sy-uname created_at = timestamp
            local_last_changed_by = sy-uname local_last_changed_at = timestamp
            last_changed_at = timestamp )
          ( invoice_uuid = cl_system_uuid=>create_uuid_x16_static( )
            invoice_id = 'PWI0006' company_code = gc_company_code
            supplier_uuid = supplier_1 invoice_date = today - 5
            gross_amount = '680000.00' currency_code = gc_currency
            discount_percent = '1.00' discount_deadline = today + 2
            due_date = today + 20 payment_status = 'OPEN'
            created_by = sy-uname created_at = timestamp
            local_last_changed_by = sy-uname local_last_changed_at = timestamp
            last_changed_at = timestamp )
          ( invoice_uuid = cl_system_uuid=>create_uuid_x16_static( )
            invoice_id = 'PWI0007' company_code = gc_company_code
            supplier_uuid = supplier_2 invoice_date = today - 60
            gross_amount = '1900000.00' currency_code = gc_currency
            discount_percent = '0.00' due_date = today - 1
            payment_status = 'OPEN'
            created_by = sy-uname created_at = timestamp
            local_last_changed_by = sy-uname local_last_changed_at = timestamp
            last_changed_at = timestamp )
          ( invoice_uuid = cl_system_uuid=>create_uuid_x16_static( )
            invoice_id = 'PWI0008' company_code = gc_company_code
            supplier_uuid = supplier_3 invoice_date = today - 2
            gross_amount = '4300000.00' currency_code = gc_currency
            discount_percent = '2.50' discount_deadline = today + 7
            due_date = today + 45 payment_status = 'OPEN'
            created_by = sy-uname created_at = timestamp
            local_last_changed_by = sy-uname local_last_changed_at = timestamp
            last_changed_at = timestamp )
          ( invoice_uuid = cl_system_uuid=>create_uuid_x16_static( )
            invoice_id = 'PWI0009' company_code = gc_company_code
            supplier_uuid = supplier_4 invoice_date = today - 15
            gross_amount = '9600000.00' currency_code = gc_currency
            discount_percent = '1.75' discount_deadline = today + 1
            due_date = today + 15 payment_status = 'OPEN'
            created_by = sy-uname created_at = timestamp
            local_last_changed_by = sy-uname local_last_changed_at = timestamp
            last_changed_at = timestamp )
          ( invoice_uuid = cl_system_uuid=>create_uuid_x16_static( )
            invoice_id = 'PWI0010' company_code = gc_company_code
            supplier_uuid = supplier_5 invoice_date = today - 35
            gross_amount = '15000000.00' currency_code = gc_currency
            discount_percent = '0.50' discount_deadline = today - 10
            due_date = today + 1 payment_status = 'OPEN'
            created_by = sy-uname created_at = timestamp
            local_last_changed_by = sy-uname local_last_changed_at = timestamp
            last_changed_at = timestamp )
          ( invoice_uuid = cl_system_uuid=>create_uuid_x16_static( )
            invoice_id = 'PWI0011' company_code = gc_company_code
            supplier_uuid = supplier_3 invoice_date = today - 40
            gross_amount = '3200000.00' currency_code = gc_currency
            discount_percent = '0.00' due_date = today - 5
            payment_status = 'PAID' simulated_paid_at = timestamp
            simulated_paid_by = sy-uname
            created_by = sy-uname created_at = timestamp
            local_last_changed_by = sy-uname local_last_changed_at = timestamp
            last_changed_at = timestamp )
          ( invoice_uuid = cl_system_uuid=>create_uuid_x16_static( )
            invoice_id = 'PWI0012' company_code = gc_company_code
            supplier_uuid = supplier_5 invoice_date = today - 18
            gross_amount = '7500000.00' currency_code = gc_currency
            discount_percent = '2.00' discount_deadline = today - 8
            due_date = today + 12 payment_status = 'PAID'
            simulated_paid_at = timestamp simulated_paid_by = sy-uname
            created_by = sy-uname created_at = timestamp
            local_last_changed_by = sy-uname local_last_changed_at = timestamp
            last_changed_at = timestamp ) ).

        DELETE FROM zpay_invoice
          WHERE company_code = @gc_company_code
            AND invoice_id BETWEEN 'PWI0001' AND 'PWI0012'.

        DELETE FROM zpay_supplier
          WHERE supplier_id BETWEEN 'SUP0001' AND 'SUP0005'.

        INSERT zpay_supplier FROM TABLE @suppliers.
        IF sy-subrc <> 0 OR sy-dbcnt <> lines( suppliers ).
          ROLLBACK WORK.
          out->write( 'Supplier insertion failed; changes rolled back.' ).
          RETURN.
        ENDIF.

        INSERT zpay_invoice FROM TABLE @invoices.
        IF sy-subrc <> 0 OR sy-dbcnt <> lines( invoices ).
          ROLLBACK WORK.
          out->write( 'Invoice insertion failed; changes rolled back.' ).
          RETURN.
        ENDIF.

        COMMIT WORK.
        out->write( |Created { lines( suppliers ) } suppliers and { lines( invoices ) } invoices.| ).

      CATCH cx_uuid_error cx_sy_open_sql_db INTO DATA(error).
        ROLLBACK WORK.
        out->write( |Sample data generation failed: { error->get_text( ) }| ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
