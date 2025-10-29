FORM collect_paid_mpf_amount .
  DATA: l_betrg        LIKE pc207-betrg,
        l_flag,
        prcl_69_val(1) TYPE n.

  LOOP AT rt.
    CASE rt-lgart.
      WHEN g_basis_wt.
        PERFORM check_wpbp_data USING rt-apznr
                             CHANGING l_flag.
        IF l_flag EQ 'X'.
          CONTINUE.
        ENDIF.
        IF g_basis_wt+1(1) EQ 'R'.
          mpf_amount-basis = rt-betrg.
        ELSE.
          mpf_amount-basis = mpf_amount-basis + rt-betrg.
        ENDIF.
      WHEN i7hk2b-ermwt.
        l_betrg = rt-betrg.
        PERFORM get_contrib_sign USING rt-lgart
                              CHANGING l_betrg
                                       prcl_69_val.
        mpf_amount-ermco = mpf_amount-ermco + l_betrg.
      WHEN i7hk2b-eemwt.
        l_betrg = rt-betrg.
        PERFORM get_contrib_sign  USING rt-lgart
                               CHANGING l_betrg
                                        prcl_69_val.
        mpf_amount-eemco = mpf_amount-eemco + l_betrg.
      WHEN i7hk2b-ernwt.
        l_betrg = rt-betrg.
        PERFORM get_contrib_sign  USING rt-lgart
                               CHANGING l_betrg
                                        prcl_69_val.
        mpf_amount-ernco = mpf_amount-ernco + l_betrg.
      WHEN i7hk2b-eenwt.
        l_betrg = rt-betrg.
        PERFORM get_contrib_sign  USING rt-lgart
                               CHANGING l_betrg
                                        prcl_69_val.
        mpf_amount-eenco = mpf_amount-eenco + l_betrg.
    ENDCASE.
  ENDLOOP.
ENDFORM.

" 解决次月调整没有加上调整金额的问题
FORM collect_unpaid_mpf_amount .
  DATA: prcl_69_val(1) TYPE n,
        d_ermwt        LIKE i7hk2b-ermwt,
        d_eemwt        LIKE i7hk2b-eemwt,
        d_ernwt        LIKE i7hk2b-ernwt,
        d_eenwt        LIKE i7hk2b-eenwt,
        l_betrg        LIKE pc207-betrg.

  d_ermwt = i7hk2b-ermwt.
  d_eemwt = i7hk2b-eemwt.
  d_ernwt = i7hk2b-ernwt.
  d_eenwt = i7hk2b-eenwt.

  MOVE 'D' TO d_ermwt+1(1).
  MOVE 'D' TO d_eemwt+1(1).
  MOVE 'D' TO d_ernwt+1(1).
  MOVE 'D' TO d_eenwt+1(1).

  LOOP AT rt.
    IF rt-lgart = d_ermwt .
      l_betrg = rt-betrg.
      PERFORM get_contrib_sign  USING rt-lgart
                             CHANGING l_betrg
                                      prcl_69_val.
      mpf_amount-ermco = mpf_amount-ermco + l_betrg.
    ENDIF.
    IF rt-lgart = d_eemwt .
      l_betrg = rt-betrg.
      PERFORM get_contrib_sign  USING rt-lgart
                             CHANGING l_betrg
                                      prcl_69_val.
      mpf_amount-eemco = mpf_amount-eemco + l_betrg.
    ENDIF.
    IF rt-lgart = d_ernwt.
      l_betrg = rt-betrg.
      PERFORM get_contrib_sign  USING rt-lgart
                             CHANGING l_betrg
                                      prcl_69_val.
      mpf_amount-ernco = mpf_amount-ernco + l_betrg.
    ENDIF.
    IF rt-lgart = d_eenwt.
      l_betrg = rt-betrg.
      PERFORM get_contrib_sign  USING rt-lgart
                             CHANGING l_betrg
                                      prcl_69_val.
      mpf_amount-eenco = mpf_amount-eenco + l_betrg.
    ENDIF.

" ================================================== add wt /312 /310 /313 /311 for new member
    IF rt-lgart = i7hk2b-ermwt.
      l_betrg = rt-betrg.
      PERFORM get_contrib_sign  USING rt-lgart
                              CHANGING l_betrg
                                      prcl_69_val.
      mpf_amount-ermco = mpf_amount-ermco + l_betrg.
    ENDIF.
    IF rt-lgart = i7hk2b-eemwt.
      l_betrg = rt-betrg.
      PERFORM get_contrib_sign  USING rt-lgart
                              CHANGING l_betrg
                                      prcl_69_val.
      mpf_amount-eemco = mpf_amount-eemco + l_betrg.
    ENDIF.
    IF rt-lgart = i7hk2b-ernwt.
      l_betrg = rt-betrg.
      PERFORM get_contrib_sign  USING rt-lgart
                              CHANGING l_betrg
                                      prcl_69_val.
      mpf_amount-ernco = mpf_amount-ernco + l_betrg.
    ENDIF.
    IF rt-lgart = i7hk2b-eenwt.
      l_betrg = rt-betrg.
      PERFORM get_contrib_sign  USING rt-lgart
                              CHANGING l_betrg
                                      prcl_69_val.
      mpf_amount-eenco = mpf_amount-eenco + l_betrg.
    ENDIF.

    
  ENDLOOP.
ENDFORM.