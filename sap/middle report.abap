  LOOP AT pt_rt INTO ls_rt.
    CASE ls_rt-lgart.
*     WHEN '8705' OR '8725' OR '8715' OR '8747' OR '8650' OR '8651' OR '8745' OR '/368'. " OHR-3026 LIYG 20250716 注释
      WHEN '8705' OR '8725' OR '8715' OR '8747' OR '8650' OR '8745' OR '/368'.           " OHR-3026 LIYG 20250716 Mark
        ls_rt-betrg = - ls_rt-betrg.
      WHEN OTHERS.
    ENDCASE.
    "本期收入
    PERFORM field_income_cur USING ls_rt CHANGING ps_output-income_cur.
    "本期免税收入

    "基本养老保险费
    PERFORM field_insurance_pen USING ls_rt CHANGING ps_output-insurance_pen.
    "基本医疗保险费
    PERFORM field_insurance_med USING ls_rt CHANGING ps_output-insurance_med.
    "失业保险费
    PERFORM field_insurance_une USING ls_rt CHANGING ps_output-insurance_une.
    "住房公积金
    PERFORM field_fund_house USING ls_rt CHANGING ps_output-fund_house.
    "其他
    PERFORM field_field04 USING ls_rt CHANGING ps_output-field04.
    "减免税额
    PERFORM field_field06 USING ls_rt CHANGING ps_output-field06.
  ENDLOOP.

  * <-OHR-3026 LIYG 20250716 Begin
* 调整 基本养老保险费、基本医疗保险费、失业保险费、住房公积金，为负数则，先加入到本期收入中，然后再变为0
  IF ps_output-insurance_pen LT 0.
    ps_output-income_cur = ps_output-income_cur - ps_output-insurance_pen.
    ps_output-insurance_pen = 0.
  ENDIF.
  IF ps_output-insurance_med LT 0.
    ps_output-income_cur = ps_output-income_cur - ps_output-insurance_med.
    ps_output-insurance_med = 0.
  ENDIF.
  IF ps_output-insurance_une LT 0.
    ps_output-income_cur = ps_output-income_cur - ps_output-insurance_une.
    ps_output-insurance_une = 0.
  ENDIF.
  IF ps_output-fund_house LT 0.
    ps_output-income_cur = ps_output-income_cur - ps_output-fund_house.
    ps_output-fund_house = 0.
  ENDIF.
*如果 本期收入是小于0，变为0
  IF ps_output-income_cur LT 0.
    ps_output-income_cur = 0.
  ENDIF.


  FORM field_fund_house USING ps_rt         TYPE pc207
                   CHANGING pv_fund_house TYPE pc207-betrg.

* IF ps_rt-lgart = '/362' OR ps_rt-lgart = '8745' OR ps_rt-lgart = '/368'. " OHR-3026(2) LIYG 20250801 注释
  IF ps_rt-lgart = '/362' OR ps_rt-lgart = '8745'.                         " OHR-3026(2) LIYG 20250801 Mark
    pv_fund_house = pv_fund_house + ps_rt-betrg.
  ENDIF.

ENDFORM.

* ->OHR-3026 LIYG 20250716 End



" FORM field_income_cur USING ps_rt         TYPE pc207
"                    CHANGING pv_income_cur TYPE pc207-betrg.

"     IF ps_rt-lgart = '/401' OR ps_rt-lgart = '8900' OR ps_rt-lgart = '/405' OR
"         ps_rt-lgart = '/313' OR ps_rt-lgart = '8705' OR ps_rt-lgart = '/333' OR
"         ps_rt-lgart = '8725' OR ps_rt-lgart = '/323' OR ps_rt-lgart = '8715' OR
"         ps_rt-lgart = '8760' OR ps_rt-lgart = '8747' OR ps_rt-lgart = '8747' OR
"         ps_rt-lgart = '8650' OR ps_rt-lgart = '8651' OR ps_rt-lgart = '/362' OR
"         ps_rt-lgart = '8745' OR ps_rt-lgart = '/4S1' OR ps_rt-lgart = '/4S2' OR
"         ps_rt-lgart = '/4S4' OR ps_rt-lgart = '/4S5' OR ps_rt-lgart = '/4S6' OR
"         ps_rt-lgart = '/4S7' OR ps_rt-lgart = '/4S7' OR ps_rt-lgart = '/368' OR
"         ps_rt-lgart = '8216' OR ps_rt-lgart = '/4PD'. " OHR-3026 LIYG 20250716 Add /4PD
"         pv_income_cur = pv_income_cur + ps_rt-betrg.
"     ENDIF.

" ENDFORM.

" FORM field_income_cur USING ps_rt         TYPE pc207
"                    CHANGING pv_income_cur TYPE pc207-betrg.

"     IF ps_rt-lgart = '/101' OR ps_rt-lgart = '8910' OR ps_rt-lgart = '8900' OR
"         ps_rt-lgart = '/405' OR ps_rt-lgart = '/368' OR ps_rt-lgart = '8350'.
"         pv_income_cur = pv_income_cur + ps_rt-betrg.
"     ENDIF.

"     IF ps_rt-lgart = '8221' OR ps_rt-lgart = '8241' OR ps_rt-lgart = '8280' OR
"         ps_rt-lgart = '8500' OR ps_rt-lgart = '8125' OR ps_rt-lgart = '8510'.
"         pv_income_cur = pv_income_cur - ps_rt-betrg.
"     ENDIF.

" ENDFORM.

" * <-OHR-3026 LIYG 20250716 Begin
" * 调整 基本养老保险费、基本医疗保险费、失业保险费、住房公积金，为负数则变为0
"   IF ps_output-insurance_pen LT 0.
"     ps_output-insurance_pen = 0.
"   ENDIF.
"   IF ps_output-insurance_med LT 0.
"     ps_output-insurance_med = 0.
"   ENDIF.
"   IF ps_output-insurance_une LT 0.
"     ps_output-insurance_une = 0.
"   ENDIF.
"   IF ps_output-fund_house LT 0.
"     ps_output-fund_house = 0.
"   ENDIF.



        " ps_rt-lgart = '/313' OR ps_rt-lgart = '8705' OR ps_rt-lgart = '/333' OR
        " ps_rt-lgart = '8725' OR ps_rt-lgart = '8650' OR ps_rt-lgart = '/323' OR
        " ps_rt-lgart = '8715' OR ps_rt-lgart = '/362' OR ps_rt-lgart = '8745'.