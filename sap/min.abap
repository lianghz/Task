" SH SCCC&SM: 8012\80F0
" 8115	实习津贴
" 8120	见习津贴

" IF (p0001-werks = '8012' OR p0001-werks = '80F0') AND P0531-TXARE='SH'.
IF (p0001-werks = '8012' OR p0001-werks = '80F0'  OR p0001-werks = '80F0') AND P0531-TXARE='SH'
  CASE RT_WA-LGART.
    " WHEN '8100' OR '8300' OR '8400' OR '8420' OR '8465' OR '8410' 
    WHEN '8100' OR '8300' OR '8400' OR '8420' OR '8465' OR '8410' OR '8415'  
          OR '8755' OR '8500' OR '8800' OR '8805' OR '8810'
          OR '8815' OR '8820' OR '8825' OR '8650' OR '8651'
          OR '8705' OR '8715' OR '8725' OR '8745' OR '8747' OR '8A50'
          OR '8115' OR '8120'.
          YMIN = YMIN + RT_WA-BETRG.

    WHEN '/403' OR '/404' OR '/313' OR '/323' OR '/333' 
          OR '/362' OR '8760'.
          YMIN = YMIN - RT_WA-BETRG.
  ENDCASE.

" HN:8050\8051\8052
ELSEIF p0001-werks = '8050' OR p0001-werks = '8051' OR p0001-werks = '8052'.
  CASE RT_WA-LGART.
    WHEN '8100' OR '8300' OR '8400' OR '8755' OR '8415'
          OR '8420' OR '8465' OR '8410' OR '8505' OR '8250'
          OR '8800' OR '8805' OR '8810' OR '8815' OR '8820'
          OR '8825' OR '8A50' OR '8115' OR '8120'.
          YMIN = YMIN + RT_WA-BETRG
  ENDCASE

" GX:80D0\80N0
ELSEIF p0001-werks = '80D0' OR p0001-werks = '80N0'.
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
          OR '8825' OR '8500' OR '8A50' OR '8115' OR '8120'.
          YMIN = YMIN + RT_WA-BETRG.
  ENDCASE.
" other
ELSE.
    CASE RT_WA-LGART.
      WHEN '8100' OR '8300' OR '8400' OR '8755' OR '8415' 
            OR '8420' OR '8465' OR '8410' OR '8800' OR '8805' 
            OR '8810' OR '8815' OR '8820' OR '8825' OR '8A50'
            OR '8115' OR '8120'.
            YMIN = YMIN + RT_WA-BETRG.
    ENDCASE.
ENDIF.

" 621 行
READ TABLE itab_512t WITH KEY /sc1/pa_code = 'A1A15'."病假调整
READ TABLE itab_512t WITH KEY /sc1/pa_code = 'A1B69'."病假天数