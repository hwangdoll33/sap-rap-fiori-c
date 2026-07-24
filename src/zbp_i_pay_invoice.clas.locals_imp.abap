CLASS lhc_invoice DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    CONSTANTS:
      gc_status_open TYPE c LENGTH 4 VALUE 'OPEN',
      gc_status_paid TYPE c LENGTH 4 VALUE 'PAID'.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Invoice
      RESULT result.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Invoice
      RESULT result.

    METHODS simulatePayment FOR MODIFY
      IMPORTING keys FOR ACTION Invoice~simulatePayment
      RESULT result.

ENDCLASS.

CLASS lhc_invoice IMPLEMENTATION.

  METHOD get_global_authorizations.
    " Portfolio app on trial system: no additional authorization restrictions
    CLEAR result.
  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF zi_pay_invoice IN LOCAL MODE
      ENTITY Invoice
        FIELDS ( PaymentStatus PaymentBlock )
        WITH CORRESPONDING #( keys )
      RESULT DATA(invoices).

    result = VALUE #(
      FOR invoice IN invoices
        ( %tky = invoice-%tky
          %action-simulatePayment = COND #(
            WHEN invoice-PaymentStatus = gc_status_paid
              OR invoice-PaymentBlock IS NOT INITIAL
            THEN if_abap_behv=>fc-o-disabled
            ELSE if_abap_behv=>fc-o-enabled ) ) ).
  ENDMETHOD.

  METHOD simulatePayment.
    DATA payment_timestamp TYPE timestampl.
    GET TIME STAMP FIELD payment_timestamp.

    READ ENTITIES OF zi_pay_invoice IN LOCAL MODE
      ENTITY Invoice
        FIELDS ( InvoiceId PaymentStatus PaymentBlock )
        WITH CORRESPONDING #( keys )
      RESULT DATA(invoices).

    DATA update_lines TYPE TABLE FOR UPDATE zi_pay_invoice\\Invoice.

    LOOP AT invoices ASSIGNING FIELD-SYMBOL(<invoice>).

      " Guard: never pay an already-paid invoice again
      IF <invoice>-PaymentStatus = gc_status_paid.
        APPEND VALUE #( %tky = <invoice>-%tky ) TO failed-invoice.
        APPEND VALUE #(
          %tky = <invoice>-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = |Invoice { <invoice>-InvoiceId } is already paid.| )
        ) TO reported-invoice.
        CONTINUE.
      ENDIF.

      " Guard: blocked invoices are excluded from payment
      IF <invoice>-PaymentBlock IS NOT INITIAL.
        APPEND VALUE #( %tky = <invoice>-%tky ) TO failed-invoice.
        APPEND VALUE #(
          %tky = <invoice>-%tky
          %msg = new_message_with_text(
                   severity = if_abap_behv_message=>severity-error
                   text     = |Invoice { <invoice>-InvoiceId } has a payment block.| )
        ) TO reported-invoice.
        CONTINUE.
      ENDIF.

      APPEND VALUE #( %tky            = <invoice>-%tky
                      PaymentStatus   = gc_status_paid
                      SimulatedPaidAt = payment_timestamp
                      SimulatedPaidBy = cl_abap_context_info=>get_user_technical_name( )
                    ) TO update_lines.
    ENDLOOP.

    IF update_lines IS NOT INITIAL.
      MODIFY ENTITIES OF zi_pay_invoice IN LOCAL MODE
        ENTITY Invoice
          UPDATE FIELDS ( PaymentStatus SimulatedPaidAt SimulatedPaidBy )
          WITH update_lines.
    ENDIF.

    " Return current state of all requested instances
    READ ENTITIES OF zi_pay_invoice IN LOCAL MODE
      ENTITY Invoice
        ALL FIELDS
        WITH CORRESPONDING #( keys )
      RESULT DATA(invoices_after).

    result = VALUE #( FOR paid IN invoices_after
                      ( %tky   = paid-%tky
                        %param = paid ) ).
  ENDMETHOD.

ENDCLASS.
