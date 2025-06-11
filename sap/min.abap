" SH SCCC&SM: 8012\80F0
IF p0001-werks = '8012' OR p0001-werks = '80F0'.
  CASE RT_WA-LGART.
    WHEN '8100' OR '8300' OR '8400' OR '8420' OR '8465' OR '8410' 
          OR '8755' OR '8500' OR '8800' OR '8805' OR '8810'
          OR '8815' OR '8820' OR '8825' OR '8650' OR '8651'
          OR '8705' OR '8715' OR '8725' OR '8745' OR '8747' OR '8A50'.
          YMIN = YMIN + RT_WA-BETRG.

    WHEN '/403' OR '/404' OR '/313' OR '/323'
          OR '/333' OR '/362' OR '8760'.
          YMIN = YMIN - RT_WA-BETRG.

    WHEN OTHERS.
  ENDCASE.

" HN:8050\8051\8052
ELSEIF p0001-werks = '8050' OR p0001-werks = '8051' OR p0001-werks = '8052'.
  CASE RT_WA-LGART.
    WHEN '8300' OR '8100' OR '8400' OR '8755' OR '8415'
          OR '8420' OR '8465' OR '8410' OR '8505' OR '8250'
          OR '8800' OR '8805' OR '8810' OR '8815' OR '8820'
          OR '8825' OR '8A50'.
          YMIN = YMIN + RT_WA-BETRG.
  ENDCASE.

" GX:80D0
ELSEIF p0001-werks = '80D0'.
  CASE RT_WA-LGART.
    WHEN '/101' OR '8800'.
          YMIN = YMIN + RT_WA-BETRG.
  ENDCASE.

" New ME&HaiN:8017\80A0
ELSEIF p0001-werks = '8017' OR p0001-werks = '80A0'.
  CASE RT_WA-LGART.
    WHEN '8100' OR '8300' OR '8400' OR '8410' OR '8415'
          OR '8420' OR '8465' OR '8755' OR '8220' OR '8225'
          OR '8230' OR '8235' OR '8270' OR '8250' OR '8258'
          OR '8800' OR '8805' OR '8810' OR '8815'OR '8820'
          OR '8825' OR '8500' OR '8A50'.
          YMIN = YMIN + RT_WA-BETRG.
  ENDCASE.
" other
ELSE.
    CASE RT_WA-LGART.
      WHEN '8100' OR '8300' OR '8400' OR '8755' OR '8415' 
            OR '8420' OR '8465' OR '8410' OR '8800' OR '8805' 
            OR '8810' OR '8815' OR '8820' OR '8825' OR '8A50'.
            YMIN = YMIN + RT_WA-BETRG.
    ENDCASE.
ENDIF.








