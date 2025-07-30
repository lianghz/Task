*&---------------------------------------------------------------------*
*&  包含                /SC1/HRMP0064_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  AUTHOR_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM author_check.
  CALL FUNCTION 'HR_CHECK_AUTHORITY_INFTY'
    EXPORTING
      pernr            = peras-pernr
      infty            = '0008'
      subty            = ''
      begda            = pn-begda
      endda            = pn-endda
    TABLES
      i0001            = p0001
    EXCEPTIONS
      no_authorization = 1
      internal_error   = 2
      OTHERS           = 3.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  "权限控制
  IF p0000-stat2 NOT IN pnpstat2.
    RETURN.
  ENDIF.

  IF p0001-bukrs NOT IN pnpbukrs."公司代码
    RETURN.
  ENDIF.

  IF p0001-werks NOT IN pnpwerks."人事范围
    RETURN.
  ENDIF.

  IF p0001-persk NOT IN pnppersk. "员工子组
    RETURN.
  ENDIF.

  IF p0001-btrtl NOT IN pnpbtrtl. "人事子范围
    RETURN.
  ENDIF.

  IF p0001-persg NOT IN pnppersg. "员工组
    RETURN.
  ENDIF.

  IF p0001-abkrs NOT IN pnpabkrs. "工资范围
    RETURN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_PAYROLL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_payroll.
  DATA: lv_rdflg    TYPE c,
        lt_rt       TYPE hrpay99_rt,
        ls_rt       LIKE LINE OF lt_rt,
        lt_crt      TYPE hrpay99_crt,
        lt_bt       TYPE hrpay99_bt,
        lt_wpbp     TYPE hrpay99_wpbp,
        ls_wpbp     LIKE LINE OF lt_wpbp,
        lt_c0       TYPE hrpay99_c0,
        ls_c0       LIKE LINE OF lt_c0,
        lt_c1       TYPE hrpay99_c1,
        ls_c1       LIKE LINE OF lt_c1,
        lt_raw      TYPE /sc1/hrpay99_raw_t,
        ls_raw      LIKE LINE OF lt_raw,
        ls_rt_raw   TYPE /sc1/hrpay99_rt_s,
        ls_wpbp_raw TYPE /sc1/hrpay99_wpbp_s,
        ls_c0_raw   TYPE /sc1/hrpay99_c0_s,
        ls_c1_raw   TYPE /sc1/hrpay99_c1_s,
        lt_rgdir    TYPE STANDARD TABLE OF pc261,
        ls_rgdir    LIKE LINE OF lt_rgdir,
        lt_tax      TYPE STANDARD TABLE OF pc2g1,
        ls_tax      LIKE LINE OF lt_tax,
        lt_phf      TYPE STANDARD TABLE OF pc2g2,
        lt_pi       TYPE STANDARD TABLE OF pc2g2,
        lt_mi       TYPE STANDARD TABLE OF pc2g2,
        lt_ui       TYPE STANDARD TABLE OF pc2g2,
        lt_bi       TYPE STANDARD TABLE OF pc2g2,
        lt_ii       TYPE STANDARD TABLE OF pc2g2,
        lt_sui      TYPE STANDARD TABLE OF pc2su,
        lt_tcrt     TYPE STANDARD TABLE OF pc2g5.

  IF rt_f = 'X' OR rt_h = 'X'.
    lv_rdflg = '2'.
  ELSEIF rt_j = 'X'.
    lv_rdflg = '1'.
  ENDIF.

  gv_period = pn-begda+0(6).

  CALL FUNCTION '/SC1/HRM_GET_PAYROLL_RESULT'
    EXPORTING
      pernr    = pernr-pernr
      abkrs    = p0001-abkrs
      yyyymm   = gv_period
      ocrsn    = p_ocrsn
      payty    = p_payty
      payid    = p_payid
      paydt    = p_paydt
      retro    = 'RAW'
      rdflg    = lv_rdflg
    TABLES
      rt       = lt_rt
      crt      = lt_crt
      bt       = lt_bt
      wpbp     = lt_wpbp
      c0       = lt_c0
      c1       = lt_c1
      raw      = lt_raw
      et_rgdir = lt_rgdir.

  CALL FUNCTION '/SC1/HRM_GET_CN_SI'
    EXPORTING
      im_pernr = pernr-pernr
      im_faper = gv_period
    TABLES
      it_rgdir = lt_rgdir
      et_tax   = lt_tax
      et_phf   = lt_phf
      et_pi    = lt_pi
      et_mi    = lt_mi
      et_ui    = lt_ui
      et_bi    = lt_bi
      et_ii    = lt_ii
      et_sui   = lt_sui
      et_tcrt  = lt_tcrt.

  DATA:lv_last_run TYPE c LENGTH 14,
       lv_run      TYPE c LENGTH 14,
       lv_last_497 TYPE c LENGTH 14,
       lv_tabix    TYPE sy-tabix.

  LOOP AT lt_rgdir INTO ls_rgdir.
    CONCATENATE ls_rgdir-rundt ls_rgdir-runtm INTO lv_run.

    IF lv_last_run IS INITIAL OR lv_run > lv_last_run.
      MOVE lv_run TO lv_last_run.
    ENDIF.
  ENDLOOP.
  "rt表只留下/I04
  LOOP AT lt_rt INTO ls_rt.
    MOVE sy-tabix TO lv_tabix.

    IF ls_rt-lgart = '/I04'.
      CONTINUE.
    ELSE.
      DELETE lt_rt INDEX lv_tabix.
    ENDIF.
  ENDLOOP.

  LOOP AT lt_raw INTO ls_raw.
    LOOP AT ls_raw-rt_raw INTO ls_rt_raw WHERE lgart = '/497'.
      IF ls_rt_raw-ipend  = ls_rt_raw-fpend.
        CONCATENATE ls_rt_raw-rundt ls_rt_raw-runtm INTO lv_run.
        IF lv_run > lv_last_497.
          lv_last_497 = lv_run.
        ENDIF.
      ENDIF.
    ENDLOOP.

    LOOP AT ls_raw-rt_raw INTO ls_rt_raw.
      IF ls_rt_raw-lgart = '/I04'.
        CONTINUE.
      ENDIF.

*** GET THE LAST ENTRY OF /497 FOR THE 'A' STATUS FOR EACH PERIOD (RGDIR-SRTZA)
      IF ls_rt_raw-lgart = '/497'.
        CONCATENATE ls_rt_raw-rundt ls_rt_raw-runtm INTO lv_run.
*        IF L_V_RUN <> L_V_LAST_497 OR LW_RT_RAW-SRTZA <> 'A' OR LW_RT_RAW-IPEND <> LW_RT_RAW-FPEND.
        IF lv_run <> lv_last_497 OR ls_rt_raw-ipend <> ls_rt_raw-fpend OR
          ( ls_rt_raw-ipend < pn-begda OR ls_rt_raw-ipend > pn-endda ). "OHR-1641
          CONTINUE. "SKIP
        ENDIF.
***        IF NOT ( L_V_RUN = L_V_LAST_497 AND LW_RT_RAW-SRTZA = 'A' ).
***          CONTINUE.
***        ENDIF.
      ENDIF.

      IF ls_rt_raw-lgart = '/561' OR ls_rt_raw-lgart = '/4E2'. "OHR-1446 DELETE OR LW_RT_RAW-LGART = '/497'.
        CONCATENATE ls_rt_raw-rundt ls_rt_raw-runtm INTO lv_run.

        IF NOT ( lv_run = lv_last_run ).
          CONTINUE.
        ENDIF.

        IF NOT ( ls_rt_raw-fpend+0(8) = ls_rt_raw-ipend+0(8) AND ls_rt_raw-ipend+0(6) = gv_period ).
          CONTINUE.
        ENDIF.
      ENDIF.

      MOVE-CORRESPONDING ls_rt_raw TO ls_rt.
      APPEND ls_rt TO lt_rt.
    ENDLOOP.

    LOOP AT ls_raw-wpbp_raw INTO ls_wpbp_raw.
      MOVE-CORRESPONDING ls_wpbp_raw TO ls_wpbp.
      APPEND ls_wpbp TO lt_wpbp.
    ENDLOOP.

    LOOP AT ls_raw-c0_raw   INTO ls_c0_raw.
      MOVE-CORRESPONDING ls_c0_raw TO ls_c0.
      APPEND ls_c0 TO lt_c0.
    ENDLOOP.

    LOOP AT ls_raw-c1_raw   INTO ls_c1_raw.
      MOVE-CORRESPONDING ls_c1_raw TO ls_c1.
      APPEND ls_c1 TO lt_c1.
    ENDLOOP.
  ENDLOOP.

  CHECK lt_rt IS NOT INITIAL.

  PERFORM edit_other_field CHANGING gs_output.

  LOOP AT lt_tax INTO ls_tax.
  ENDLOOP.
  PERFORM edit_amt_field USING lt_rt lt_tcrt ls_tax CHANGING gs_output.

  "记录下所有的公司代码以及工资范围
  gs_t001-bukrs = p0001-bukrs.
  COLLECT gs_t001 INTO gt_t001.
  CLEAR:  gs_t001.
  gs_salary_range-abkrs = p0001-abkrs.
  COLLECT gs_salary_range INTO gt_salary_range.
  CLEAR:  gs_salary_range.

  APPEND gs_output TO gt_output.
  CLEAR: gs_output.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  EDIT_OTHER_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GS_OUTPUT  text
*----------------------------------------------------------------------*
FORM edit_other_field  CHANGING ps_output TYPE ty_output.

  "企业名称 登记序号
  READ TABLE gt_taxcname INTO gs_taxcname WITH KEY txare = p0531-txare.
  IF sy-subrc = 0.
    ps_output-company = gs_taxcname-company.
    ps_output-regid   = gs_taxcname-regid.
  ENDIF.
  "工号
  ps_output-pernr = peras-pernr.
  "姓名
  ps_output-sname = p0002-nachn && p0002-vorna.
  "证件类型
  ps_output-ictyp = '居民身份证' .
  "证件号码
  ps_output-icnum = p0185-icnum.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  EDIT_AMT_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_RT  text
*      <--P_GS_OUTPUT  text
*----------------------------------------------------------------------*
FORM edit_amt_field USING pt_rt     TYPE hrpay99_rt
                          pt_tcrt   TYPE hrpaycn_tcrt
                          ps_tax    TYPE pc2g1
                 CHANGING ps_output TYPE ty_output.
  DATA: ls_rt   TYPE pc207,
        ls_tcrt TYPE pc2g5.

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
* 调整 基本养老保险费、基本医疗保险费、失业保险费、住房公积金，为负数则变为0
  IF ps_output-insurance_pen LT 0.
    ps_output-insurance_pen = 0.
  ENDIF.
  IF ps_output-insurance_med LT 0.
    ps_output-insurance_med = 0.
  ENDIF.
  IF ps_output-insurance_une LT 0.
    ps_output-insurance_une = 0.
  ENDIF.
  IF ps_output-fund_house LT 0.
    ps_output-fund_house = 0.
  ENDIF.
* ->OHR-3026 LIYG 20250716 End

  LOOP AT pt_tcrt INTO ls_tcrt WHERE taxgp = ps_tax-taxgp AND cumty = 'Y'.
    CASE ls_tcrt-lgart.
      WHEN '/4S1'."累计子女教育
        ps_output-ttl_childedu = ps_output-ttl_childedu + ls_tcrt-betrg.
      WHEN '/4S2'."累计继续教育
        ps_output-ttl_continueedu = ps_output-ttl_continueedu + ls_tcrt-betrg.
      WHEN '/4S4'."累计住房贷款利息
        ps_output-ttl_load = ps_output-ttl_load + ls_tcrt-betrg.
      WHEN '/4S5'."累计住房租金
        ps_output-ttl_rent = ps_output-ttl_rent + ls_tcrt-betrg.
      WHEN '/4S6'."累计赡养老人
        ps_output-ttl_parental = ps_output-ttl_parental + ls_tcrt-betrg.
      WHEN '/4S7'."累计3岁以下婴幼儿照护
        ps_output-ttl_baby = ps_output-ttl_baby + ls_tcrt-betrg.
      WHEN '/4PD'."累计个人养老金
        ps_output-ttl_pension = ps_output-ttl_pension + ls_tcrt-betrg.
      WHEN OTHERS.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FIELD_INCOME_CUR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_RT  text
*      <--P_PS_OUTPUT_INCOME_CUR  text
*----------------------------------------------------------------------*
FORM field_income_cur USING ps_rt         TYPE pc207
                   CHANGING pv_income_cur TYPE pc207-betrg.

  IF ps_rt-lgart = '/401' OR ps_rt-lgart = '8900' OR ps_rt-lgart = '/405' OR
    ps_rt-lgart = '/313' OR ps_rt-lgart = '8705' OR ps_rt-lgart = '/333' OR
    ps_rt-lgart = '8725' OR ps_rt-lgart = '/323' OR ps_rt-lgart = '8715' OR
    ps_rt-lgart = '8760' OR ps_rt-lgart = '8747' OR ps_rt-lgart = '8747' OR
    ps_rt-lgart = '8650' OR ps_rt-lgart = '8651' OR ps_rt-lgart = '/362' OR
    ps_rt-lgart = '8745' OR ps_rt-lgart = '/4S1' OR ps_rt-lgart = '/4S2' OR
    ps_rt-lgart = '/4S4' OR ps_rt-lgart = '/4S5' OR ps_rt-lgart = '/4S6' OR
    ps_rt-lgart = '/4S7' OR ps_rt-lgart = '/4S7' OR ps_rt-lgart = '/368' OR
    ps_rt-lgart = '8216' OR ps_rt-lgart = '/4PD'. " OHR-3026 LIYG 20250716 Add /4PD
    pv_income_cur = pv_income_cur + ps_rt-betrg.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FIELD_INSURANCE_PEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_RT  text
*      <--P_PS_OUTPUT_INSURANCE_PEN  text
*----------------------------------------------------------------------*
FORM field_insurance_pen USING ps_rt            TYPE pc207
                      CHANGING pv_insurance_pen TYPE pc207-betrg.

  IF ps_rt-lgart = '/313' OR ps_rt-lgart = '8705'.
    pv_insurance_pen = pv_insurance_pen + ps_rt-betrg.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FIELD_INSURANCE_MED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_RT  text
*      <--P_PS_OUTPUT_INSURANCE_MED  text
*----------------------------------------------------------------------*
FORM field_insurance_med USING ps_rt            TYPE pc207
                      CHANGING pv_insurance_med TYPE pc207-betrg.

  IF ps_rt-lgart = '/333' OR ps_rt-lgart = '8725' OR ps_rt-lgart = '8650'.
    pv_insurance_med = pv_insurance_med + ps_rt-betrg.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FIELD_INSURANCE_UNE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_RT  text
*      <--P_PS_OUTPUT_INSURANCE_UNE  text
*----------------------------------------------------------------------*
FORM field_insurance_une USING ps_rt            TYPE pc207
                      CHANGING pv_insurance_une TYPE pc207-betrg.

  IF ps_rt-lgart = '/323' OR ps_rt-lgart = '8715'.
    pv_insurance_une = pv_insurance_une + ps_rt-betrg.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FIELD_FUND_HOUSE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_RT  text
*      <--P_PS_OUTPUT_FUND_HOUSE  text
*----------------------------------------------------------------------*
FORM field_fund_house USING ps_rt         TYPE pc207
                   CHANGING pv_fund_house TYPE pc207-betrg.

  IF ps_rt-lgart = '/362' OR ps_rt-lgart = '8745' OR ps_rt-lgart = '/368'.
    pv_fund_house = pv_fund_house + ps_rt-betrg.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FIELD_FIELD04
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_RT  text
*      <--P_PS_OUTPUT_FIELD04  text
*----------------------------------------------------------------------*
FORM field_field04 USING ps_rt         TYPE pc207
                CHANGING pv_other04    TYPE pc207-betrg.
  IF ps_rt-lgart = '8216'.
    pv_other04 = pv_other04 + ps_rt-betrg.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FIELD_FIELD06
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_RT  text
*      <--P_PS_OUTPUT_FIELD06  text
*----------------------------------------------------------------------*
FORM field_field06 USING ps_rt         TYPE pc207
                CHANGING pv_other06    TYPE pc207-betrg.
  IF ps_rt-lgart = '/4TR'.
    pv_other06 = pv_other06 + ps_rt-betrg.
  ENDIF.
ENDFORM.