  IF $method EQ 'E'.                   "for exist member
    LOOP AT rt.
*      IF rt-lgart = l_basis.           "revelant income
*        mpf_amount-basis = mpf_amount-basis + rt-betrg.
*      ENDIF.
*   HRS-298 RI wage type (/R24 should be the total for the period)
      IF rt-lgart = lw_basis.           "revelant income
        mpf_amount-basis =  rt-betrg.
      ENDIF.
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
* check if retro has happend, if no, add /Hxx to EE vol. contribution
* which might come from arrears table
    DESCRIBE TABLE reti LINES l_linenum.
    IF l_linenum = 0.
      LOOP AT rt.
        IF rt-lgart = h_eenwt.
          l_betrg = rt-betrg.
          PERFORM get_contrib_sign  USING rt-lgart
                                 CHANGING l_betrg
                                          prcl_69_val.
          mpf_amount-eenco = mpf_amount-eenco + l_betrg.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

  IF $method EQ 'N'.                   "for new member
    LOOP AT rt.
      IF rt-lgart = l_basis.           "revelant income
        mpf_amount-basis = mpf_amount-basis + rt-betrg.
      ENDIF.
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
      IF rt-lgart = i7hk2b-eenwt .
        l_betrg = rt-betrg.
        PERFORM get_contrib_sign  USING rt-lgart
                               CHANGING l_betrg
                                        prcl_69_val.
        mpf_amount-eenco = mpf_amount-eenco + l_betrg.
      ENDIF.

      
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
    ENDLOOP.
  ENDIF.