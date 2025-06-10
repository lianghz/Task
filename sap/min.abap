"SH SCCC、SM：认识范围 8012\80F0
IF p0001-werks = '8012' OR p0001-werks = '80F0'.
  CASE RT_WA-LGART.
    WHEN '8100' OR '8300' OR '8400' OR '8420' OR '8465' OR '8410' 
          OR '8755' OR '8500' OR '8800' OR '8805' OR '8810'
          OR '8815' OR '8820' OR '8825' OR '8650' OR '8651'
          OR '8705' OR '8715' OR '8725' OR '8745' OR '8747'.
          YMIN = YMIN + RT_WA-BETRG.

    WHEN '/403' OR '/404' OR '/313' OR '/323'
          OR '/333' OR '/362' OR '8760' OR '8A50'.
          YMIN = YMIN - RT_WA-BETRG.

    WHEN OTHERS.
  ENDCASE.


"HN:8050\8051\8052
ELSEIF p0001-werks = '8050' OR p0001-werks = '8051' OR p0001-werks = '8052'.

ELSEIF p0001-werks = '80A0' OR p0001-werks = ''.

ENDIF.




