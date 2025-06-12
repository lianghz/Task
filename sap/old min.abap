*>>>>>>>>>> ADD BY YUWEI @26.10.2017 17:30:18 >>>>>>>>>>
*  Request: 申美（人事范围pa0001- WERKS=80F0） 需要单独处理
    IF P0001-WERKS NE '80F0'.
      IF p0001-werks NE '80A0'.
      IF p0001-werks NE '8050' AND p0001-werks NE '8051' AND p0001-werks NE '8052'.
      IF   RT_WA-LGART = '8100'
        OR RT_WA-LGART = '8115'
        OR RT_WA-LGART = '8120'
        OR RT_WA-LGART = '8400'
        OR RT_WA-LGART = '8755'
        OR RT_WA-LGART = '8A50'
        OR RT_WA-LGART = '8800'
        OR RT_WA-LGART = '8805'
        OR RT_WA-LGART = '8810'
        OR RT_WA-LGART = '8815'
        OR RT_WA-LGART = '8820'
        OR RT_WA-LGART = '8825'.

        YMIN = YMIN + RT_WA-BETRG.

      ENDIF.

      "如果人事范围是上海SBCD（WERKS=8012），比较基数要减去“社保公积金合计汇总(E)” OHR-1816
      IF P0001-WERKS = '8012'.
        CASE RT_WA-LGART.
          WHEN '/313' OR '/323' OR '/333' OR '/362' OR '8760'.
            YMIN = YMIN - RT_WA-BETRG.
          WHEN '8650' OR '8705' OR '8715' OR '8725' OR '8745' OR '8747'.
            YMIN = YMIN + RT_WA-BETRG.
          WHEN OTHERS.
        ENDCASE.
      ENDIF.
      ELSE.
        "河南特殊规则
        "正常出勤：
        "8100+8400+8755+8800+8805+8810+8815+8820+8825+ 8415+ 8420+ 8505+ 8250
        "病假情况：
        "8100+8400+8755+8A50+8800+8805+8810+8815+8820+8825+ 8415+ 8420+ 8505+ 8250
        IF rt_wa-lgart = '8100' OR rt_wa-lgart = '8400' OR rt_wa-lgart = '8755' OR
          rt_wa-lgart = '8800' OR rt_wa-lgart = '8805' OR rt_wa-lgart = '8810' OR
          rt_wa-lgart = '8815' OR rt_wa-lgart = '8820' OR rt_wa-lgart = '8825' OR
          rt_wa-lgart = '8415' OR rt_wa-lgart = '8420' OR rt_wa-lgart = '8505' OR
          rt_wa-lgart = '8250' OR rt_wa-lgart = '8A50'.
          ymin = ymin + rt_wa-betrg.
        ENDIF.
      ENDIF.
      ELSE.
        "海南特殊规则
        "正常出勤：
        "8100+8300+8400+8410+8415+8420+8755+8220+8225+8230+8235+8240+8270+8250+8258+8500
        "病假情况：
        "8100+8300+8400+8410+8415+8420+8755+8220+8225+8230+8235+8240+8270+8250+8258+8500+8A50
        IF rt_wa-lgart = '8100' OR rt_wa-lgart = '8300' OR rt_wa-lgart = '8400' OR
          rt_wa-lgart = '8410' OR rt_wa-lgart = '8415' OR rt_wa-lgart = '8420' OR
          rt_wa-lgart = '8755' OR rt_wa-lgart = '8220' OR rt_wa-lgart = '8225' OR
          rt_wa-lgart = '8230' OR rt_wa-lgart = '8235' OR rt_wa-lgart = '8240' OR
          rt_wa-lgart = '8270' OR rt_wa-lgart = '8250' OR rt_wa-lgart = '8258' OR
          rt_wa-lgart = '8500' OR rt_wa-lgart = '8A50'.
          ymin = ymin + rt_wa-betrg.
        ENDIF.
      ENDIF.
    ELSE."申美（人事范围pa0001- WERKS=80F0）

*正常出勤：8100+8400+8500+8300-8705-8715-8725-8745-8650-/313-/323-/333-/343-/353-/362-/403-/404+8800
*全月病假：8100+8400+8500+8300-8705-8715-8725-8745-8650-/313-/323-/333-/343-/353-/362-/403-/404+8800+8A50
      CASE RT_WA-LGART.
        WHEN '8100' OR '8400' OR '8500' OR '8300' OR '8800' OR '8A50' .
          YMIN = YMIN + RT_WA-BETRG.
        WHEN '8705' OR '8715' OR '8725' OR '8745' OR '8650' OR '/313' OR
             '/323' OR '/333' OR '/343' OR '/353' OR '/362' OR '/403' OR '/404'   .
          YMIN = YMIN - RT_WA-BETRG.
        WHEN OTHERS.
      ENDCASE.

    ENDIF.
*>>>>>>>>>> END BY YUWEI @26.10.2017 17:30:18 <<<<<<<<<<