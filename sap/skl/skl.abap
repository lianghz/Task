*&---------------------------------------------------------------------*
*&  包括                YHRPYOP01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  OPY_ACT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM opy_act .

  DATA: l_date  TYPE     dats,
        l_begda TYPE     dats,
        l_endda TYPE     dats,
        l_werks TYPE     persa,
        l_conar TYPE     pcn_conar,
        l_years TYPE     cmp_noyrs,
        l_betrg TYPE     pad_amt7s.

  SORT wpbp BY begda ASCENDING.
  READ TABLE wpbp INDEX 1.

  l_date   =  wpbp-begda.

  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = l_date
    IMPORTING
      last_day_of_month = l_endda
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CONCATENATE l_endda+0(6) '01' INTO l_begda.

  CALL FUNCTION '/SC1/HRM_GET_ACTIVE_YEAR'
    EXPORTING
      im_pernr = pernr-pernr
      im_date  = l_endda
      im_begda = wpbp-begda
      im_endda = wpbp-endda
    IMPORTING
      ex_years = l_years.

  vargt = l_years.
  PERFORM fillvargt.

ENDFORM.                    " OPY_ACT

*&---------------------------------------------------------------------*
*&      Form  OPY_JGR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM opy_jgr.

  DATA: lv_objid TYPE plog-objid,
        lt_p9802 TYPE STANDARD TABLE OF p9802 WITH HEADER LINE,
        ls_p0001 TYPE p0001.

  CLEAR: lt_p9802[], vargt.

  LOOP AT p0001  INTO ls_p0001 WHERE begda <= wpbp-endda
                               AND   endda >= wpbp-begda.

    lv_objid = ls_p0001-stell.

    CALL FUNCTION 'RH_READ_INFTY_NNNN'
      EXPORTING
        plvar                 = '01'
        otype                 = 'C'
        objid                 = lv_objid
        infty                 = '9802'
        begda                 = ls_p0001-endda
        endda                 = ls_p0001-endda
      TABLES
        innnn                 = lt_p9802
      EXCEPTIONS
        nothing_found         = 1
        wrong_condition       = 2
        infotyp_not_supported = 3
        wrong_parameters      = 4
        OTHERS                = 5.
    IF sy-subrc = 0 AND lines( lt_p9802[] ) >= 1.
      SORT lt_p9802 BY endda DESCENDING.
      vargt = lt_p9802[ 1 ]-/sc1/pa_posgrade.
    ENDIF.

    EXIT.
  ENDLOOP.

  PERFORM fillvargt.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  OPY_TWP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM opy_twp.

  DATA wpbp_begda LIKE wpbp-begda.                          "WGYK007243
  DATA l_pernr TYPE persno.
  PERFORM pos-wpbpznr USING ot-apznr.
  CASE op+5(5).
    WHEN 'CTYMO'. vargt = calcmolga.   "Molga
    WHEN 'PAYSB'. vargt = aper-abkrs.  "Abrechnungskreis
    WHEN 'COMPY'.
      vargt = wpbp-bukrs.              "Buchungskreis.
      TRANSLATE vargt(4) USING ' *'.
    WHEN 'PLANT'.
      vargt = wpbp-werks.              "Werk.
      TRANSLATE vargt(4) USING ' *'.
    WHEN 'COSTC'.                      "Kostenstelle.
      IF vargtlen GT 0 OR vargtoff GT 0.
        ASSIGN wpbp-kostl+vargtoff(vargtlen) TO <gfs>.
        CLEAR: vargtlen, vargtoff.
        vargt = <gfs>.
      ELSE.
        vargt = wpbp-kostl.
      ENDIF.
    WHEN 'COSTD'.
      vargt = wpbp-kostvjn.            "cost distribution
      IF vargt EQ space. vargt = '*'. ENDIF.
    WHEN 'EMPLR'.
      vargt = wpbp-ansvh.              "Anstellungsverhaeltnis
      IF vargt EQ space. vargt = '**'. ENDIF.
    WHEN 'PLTSC'.
      vargt = wpbp-btrtl.              "Betriebsteil.
      TRANSLATE vargt(4) USING ' *'.
    WHEN 'PERSG'. vargt = wpbp-persg.  "Personengruppe.
    WHEN 'PERSB'. vargt = wpbp-persk.  "Personenkreis.
    WHEN 'JOBNO'.
      vargt = wpbp-stell.              "Stelle
      IF vargt EQ space. vargt = '********'. ENDIF.
    WHEN 'SHIFT'.
      vargt = wpbp-schkz.              "Schichtkennzeichen.
      IF vargt EQ space. vargt = '********'. ENDIF.
    WHEN 'TIMER'.
      vargt = wpbp-zterf.              "ZeiTerfassung
      IF vargt EQ space. vargt = '*'. ENDIF.
    WHEN 'ABART'. vargt = wpbp-abart.
    WHEN 'TRFAR'.
      vargt = wpbp-trfar.
      IF vargt IS INITIAL. vargt = '**'. ENDIF.         "XFG note 432670
    WHEN 'ITRFA'.
      PERFORM re510a USING calcmolga wpbp-trfar.
      IF t510a-itrfa NE space.
        vargt = t510a-itrfa.
      ELSE.
        vargt = '**'.
      ENDIF.
    WHEN 'TRFGB'.
      vargt = wpbp-trfgb.
      IF vargt IS INITIAL. vargt = '**'. ENDIF.         "XFG note 432670
    WHEN 'TRFGR'.
      vargt = wpbp-trfgr.
      IF vargt IS INITIAL. vargt = '********'. ENDIF.   "XFG note 432670
    WHEN 'TRFST'.
      vargt = wpbp-trfst.
      IF vargt EQ space. vargt = '**'. ENDIF.
    WHEN 'ATIND'. "additional time indicator
      PROVIDE kztim FROM p0007
             BETWEEN wpbp-begda AND wpbp-endda.
        vargt = p0007-kztim.
      ENDPROVIDE.
      IF vargt EQ space.
        vargt = '*'.
      ENDIF.
    WHEN 'PARTT'.
      PROVIDE teilk FROM p0007 BETWEEN wpbp-begda AND wpbp-endda.
        vargt = p0007-teilk.
        EXIT.
      ENDPROVIDE.
      IF vargt EQ space.
        vargt = '*'.
      ENDIF.
    WHEN 'WWEEK'.
      PROVIDE wweek FROM p0007 BETWEEN wpbp-begda AND wpbp-endda."
        vargt = p0007-wweek.
        EXIT.
      ENDPROVIDE.
      IF vargt EQ space.
        vargt = '*'.
      ENDIF.
    WHEN 'ORGEH'. vargt = wpbp-orgeh.
    WHEN 'PARTN'.
      PROVIDE subty partn FROM p0008
                          BETWEEN wpbp-begda AND wpbp-endda
                          WHERE p0008-subty = '0   '.
        vargt = p0008-partn.
        EXIT.
      ENDPROVIDE.
      IF vargt EQ space.
        vargt = '**'.
      ENDIF.
    WHEN 'MASSN'.                                           "WGYK007243

      DATA: l_begda TYPE sy-datum,
            l_endda TYPE sy-datum.
      PERFORM last-wpbp.                                    "WGYK007243
      CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
        EXPORTING
          day_in            = wpbp-endda
        IMPORTING
          last_day_of_month = l_endda
        EXCEPTIONS
          day_in_no_date    = 1
          OTHERS            = 2.

      CONCATENATE l_endda+0(6) '01' INTO l_begda.

      LOOP AT p0000 WHERE begda >= l_begda
                    AND   begda <= l_endda
                    AND   massn  = 'Z9'.
      ENDLOOP.                                              "WGYK007243
      IF sy-subrc = 0.                                      "WGYK007243
        vargt = p0000-massn.                                "WGYK007243
      ENDIF.                                                "WGYK007243
      IF vargt EQ space. vargt = '**'. ENDIF.               "WGYK007243
    WHEN 'MAS1G'.                                           "WGYK007243
      PERFORM last-wpbp.                                    "WGYK007243
      wpbp_begda = wpbp-endda + 1.                          "WGYK007243
      LOOP AT p0000 WHERE begda = wpbp_begda. ENDLOOP.      "WGYK007243
      IF sy-subrc = 0.                                      "WGYK007243
        vargt = p0000-massg.                                "WGYK007243
      ENDIF.                                                "WGYK007243
      IF vargt EQ space. vargt = '**'. ENDIF.               "WGYK007243
    WHEN 'INWID'.                                           "AHRK048045
*     Employees of some EEsubgroups take part in incentive wages
      PERFORM re503 USING wpbp-persg wpbp-persk.            "AHRK048045
      IF NOT t503-inwid IS INITIAL.                         "AHRK048045
        vargt = t503-inwid.                                 "AHRK048045
      ELSE.                                                 "AHRK048045
        vargt = '*'.                                        "AHRK048045
      ENDIF.                                                "AHRK048045
    WHEN OTHERS.
      char11 = 'WPBP-'.
      char11+5(5) = op+5(5).                                "YUIK117551
      ASSIGN (char11) TO <gfs>.
      IF sy-subrc EQ 0.
        vargt = <gfs>.
        IF vargt EQ space.                                  "YUIK122313
          DESCRIBE FIELD <gfs> LENGTH pack IN CHARACTER MODE.        "UC
          DO pack TIMES VARYING char FROM vargt(1) NEXT vargt+1(1)
            RANGE vargt.                                             "UC
            char = '*'.                                     "YUIK122313
          ENDDO.                                            "YUIK122313
        ENDIF.                                              "YUIK122313
      ELSE.
        PERFORM log_op_err IN PROGRAM h99plog0 TABLES error_ptext
                           USING  op i52c5.
        PERFORM errors TABLES error_ptext.
      ENDIF.
  ENDCASE.
  PERFORM fillvargt.                   "variables Argument füllen.

ENDFORM.                    "OPY_TWP

*&---------------------------------------------------------------------*
*&      Form  OPY_FAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM opy_fat.

*>>>>>>>>>> ADD BY YUWEI @26.10.2017 14:20:38 >>>>>>>>>>：
*   0015额外性支付中
*06  入离职及病/事/旷/产/工伤折算  的返回值为56.
*07  入离职及假期折算（除调休） 的返回值为57.
*08  日标准基数折算   的返回值为58.
*
*   0014经常性支付中：
*06  入离职及病/事/旷/产/工伤折算  的返回值为46.
*07  入离职及假期折算（除调休） 的返回值为47.
*08  日标准基数折算   的返回值为48.
*>>>>>>>>>> END BY YUWEI @26.10.2017 14:20:38 <<<<<<<<<<

  DATA: lt       TYPE   TABLE OF pc207.
  DATA: wa       TYPE   pc207.
  DATA: jt       TYPE   TABLE OF pc207.
  DATA: ja       TYPE   pc207.
  DATA: l_lgart  TYPE   pc207-lgart.
  DATA: l_apznr  TYPE   pc205-apznr.
  DATA: l_divi   TYPE   pc207-anzhl.
  DATA: l_anzhl  TYPE   pc207-anzhl.
  DATA: l_mawd   TYPE   pc207-anzhl.
  DATA: l_temp   TYPE   pc207-anzhl.
  DATA: l_count  TYPE   i.
  DATA: sytabix  TYPE   sy-tabix.
  DATA: l_vargt(8).

  IF it-cntr1  =  '15'.  "0015信息类型的工资项

    IF it-cntr2  =  '01'.   "入离职
      l_vargt  =  '51'.
    ELSEIF it-cntr2 = '02'.  "病事假
      l_vargt  =  '52'.
    ELSEIF it-cntr2 = '03'.   "入离职+病事假
      l_vargt  =  '53'.
    ELSEIF it-cntr2 = '05'.   "入离职及假期折算(除年假/调休
      l_vargt  =  '55'.
    ELSEIF it-cntr2 = '06'.
      l_vargt  =  '56'.
    ELSEIF it-cntr2 = '07'.
      l_vargt  =  '57'.
    ELSEIF it-cntr2 = '08'.
      l_vargt  =  '58'.
    ELSE.                        "不折算
      l_vargt  =  '59'.
    ENDIF.

  ELSE.

    LOOP AT p0014  WHERE lgart  = it-lgart
                   AND   begda <= wpbp-endda
                   AND   endda >= wpbp-begda.

      IF p0014-preas  =  '01'.      "入离职
        l_vargt  =  '41'.
      ELSEIF p0014-preas = '02'.    "病事假
        l_vargt  =  '42'.
      ELSEIF p0014-preas = '03'.    "入离职+病事假
        l_vargt  =  '43'.
      ELSEIF p0014-preas = '04'.     "月中折算
        l_vargt  =  '44'.
      ELSEIF p0014-preas = '05'.     "入离职及假期折算(除年假/调休
        l_vargt  =  '45'.
      ELSEIF p0014-preas = '06'.
        l_vargt  =  '46'.
      ELSEIF p0014-preas = '07'.
        l_vargt  =  '47'.
      ELSEIF p0014-preas = '08'.
        l_vargt  =  '48'.
      ELSE.                          "不折算
        l_vargt  =  '49'.
      ENDIF.

      EXIT.

    ENDLOOP.

    IF l_vargt IS INITIAL.

      LOOP AT p0008  WHERE begda <= wpbp-endda
                     AND   endda >= wpbp-begda
                     AND   ( lga01 = it-lgart OR
                             lga02 = it-lgart OR
                             lga03 = it-lgart OR
                             lga04 = it-lgart OR
                             lga05 = it-lgart OR
                             lga06 = it-lgart OR
                             lga07 = it-lgart OR
                             lga08 = it-lgart OR
                             lga09 = it-lgart OR
                             lga10 = it-lgart ).
        l_vargt  =  '81'.
        EXIT.

      ENDLOOP.

      IF l_vargt  IS INITIAL.

        l_vargt  =  '99'.

      ENDIF.

    ENDIF.

  ENDIF.

  IF l_vargt  =  '41' OR
     l_vargt  =  '43' OR
     l_vargt  =  '44' OR
     l_vargt  =  '81'.

    l_lgart  =  it-lgart.
    l_apznr  =  it-apznr.

    REFRESH: lt, jt.
    CLEAR  : wa, ja, l_divi, l_anzhl.

    READ TABLE var WITH KEY lgart  =  'MAWD'.

    l_mawd  =  var-anzhl.
    l_temp  =  var-anzhl.

    LOOP AT it INTO wa
               WHERE lgart   =   l_lgart
               AND   cntr1   <>  '15'.

      l_divi  =  wa-betpe.
      l_anzhl =  l_anzhl  +  wa-anzhl.
      APPEND wa TO lt.

      READ TABLE jt INTO ja WITH KEY betrg  =  wa-betrg.

      IF sy-subrc = 0.

        ja-anzhl  =  ja-anzhl  +  wa-anzhl.
        MODIFY jt FROM ja INDEX sy-tabix.

      ELSE.

        APPEND wa TO jt.

      ENDIF.

      CLEAR: wa, ja.

    ENDLOOP.

    IF l_divi <> l_anzhl.

      IF l_divi > l_mawd.

        IF l_anzhl > l_mawd.

          l_temp  =  l_temp  -  l_divi  +  l_anzhl.

        ELSE.

          l_temp  =  l_anzhl.

        ENDIF.

      ELSE.

        l_temp  =  l_temp  -  l_divi  +  l_anzhl.

      ENDIF.

    ENDIF.

    IF l_divi  >  l_mawd.  "大月

      SORT jt BY betrg DESCENDING.

      READ TABLE jt INDEX 1 INTO ja.

      IF ja-anzhl > l_mawd.                                 "大于21.75

        SORT lt BY betrg ASCENDING.
        LOOP AT lt INTO wa.

          sytabix = sy-tabix.
          l_temp  =  l_temp  -  wa-anzhl.

          IF l_temp < 0.

            wa-anzhl  =  wa-anzhl  +  l_temp.
            MODIFY lt FROM wa INDEX sytabix.
            l_temp    =  0.

          ENDIF.

        ENDLOOP.

      ELSE.                                                 "小于21.75

        SORT lt BY betrg DESCENDING.

        LOOP AT lt INTO wa.

          sytabix = sy-tabix.

          IF l_temp > 0 .

            l_temp  =  l_temp  -  wa-anzhl.

            IF l_temp < 0.

              wa-anzhl  =  wa-anzhl  +  l_temp.

              MODIFY lt FROM wa INDEX sytabix.

              l_temp  =  0.

            ENDIF.

          ELSE.

            wa-anzhl  =  0.
            MODIFY lt FROM wa INDEX sytabix.

          ENDIF.

        ENDLOOP.

      ENDIF.

    ELSE.   "小月

      SORT lt BY betrg ASCENDING.
      DESCRIBE TABLE lt LINES l_count.

      LOOP AT lt INTO wa.

        sytabix  =  sy-tabix.
        l_temp  =  l_temp  -  wa-anzhl.

        IF sytabix  =  l_count.

          wa-anzhl  =  wa-anzhl  +  l_temp.
          MODIFY lt FROM wa INDEX sytabix.

        ENDIF.

      ENDLOOP.

    ENDIF.

    CLEAR: wa, it.

    READ TABLE lt INTO wa WITH KEY lgart  =  l_lgart
                                   apznr  =  l_apznr.

    wa-betpe  =  wa-anzhl  *  100000  /  l_mawd.

    MOVE-CORRESPONDING wa TO it.
    MOVE-CORRESPONDING wa TO ot.
    APPEND ot.

    CLEAR: wa, ja.
    REFRESH: lt, jt.

  ELSE.

    MOVE-CORRESPONDING it TO ot.
    APPEND ot.

  ENDIF.

  vargt  =  '1'.
  PERFORM fillvargt.

ENDFORM.                    "OPY_FA

*&---------------------------------------------------------------------*
*&      Form  OPY_SPG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM opy_spg.

  DATA: l_betrg  TYPE   betrg,
        l_anzhl  TYPE   anzhl,
        l_betpe  TYPE   betpe,
        t7cn13   TYPE   t7cn13,
        it_7cn13 TYPE   TABLE OF t7cn13,
        wa       TYPE   pc207.

  LOOP AT p0532 WHERE subty  = '0001'
                AND   begda <= wpbp-endda
                AND   endda >= wpbp-endda.

    EXIT.

  ENDLOOP.

  SELECT * FROM t7cn13
            INTO     CORRESPONDING FIELDS OF TABLE it_7cn13
            WHERE    infty   =  '0530'
            AND      conar   =  p0532-conar.

  SORT it_7cn13 BY cyear DESCENDING.
  READ TABLE it_7cn13 INDEX 1 INTO t7cn13.

  CASE p0532-conar.

    WHEN 'GZ'.

      READ TABLE it INTO wa  WITH KEY lgart  = '8110'
                             apznr  = it-apznr.
      l_betrg = wa-betrg.

      IF l_betrg > t7cn13-salar.

        l_betrg = t7cn13-salar.

      ENDIF.

    WHEN 'SZ'.

      READ TABLE it INTO wa  WITH KEY lgart  = '8110'
                             apznr  = it-apznr.
      l_betrg = wa-betrg.

    WHEN OTHERS.

      READ TABLE var WITH KEY lgart = '/I04'.
      l_betrg = var-betrg.

  ENDCASE.

  l_betpe  =  it-betpe * -1 .

  READ TABLE var WITH KEY lgart = 'BJXS'.
  l_anzhl = 1 - var-betpe.

  var-lgart = 'GDBJ'.
  var-betpe = l_anzhl * l_betpe.
  var-anzhl = 0.
  var-betrg = l_betrg * l_betpe * l_anzhl / 100000.
  APPEND var.
  CLEAR var.

  vargt = '1'.
  PERFORM fillvargt.

ENDFORM.                    "OPY_SPG

*&---------------------------------------------------------------------*
*&      Form  opy_pbp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM opy_pbp.

*>>>>>>>>>> ADD BY YUWEI @26.10.2017 14:20:38 >>>>>>>>>>：
*   0015额外性支付中
*06  入离职及病/事/旷/产/工伤折算  的返回值为56.
*07  入离职及假期折算（除调休） 的返回值为57.
*08  日标准基数折算   的返回值为58.
*
*   0014经常性支付中：
*06  入离职及病/事/旷/产/工伤折算  的返回值为46.
*07  入离职及假期折算（除调休） 的返回值为47.
*08  日标准基数折算   的返回值为48.
*>>>>>>>>>> END BY YUWEI @26.10.2017 14:20:38 <<<<<<<<<<

  IF op+5(5) = 'SPLIT'.

    IF p0014-preas  =  '01'. "入离职
      vargt  =  '41'.
    ELSEIF p0014-preas  =  '02'. "病事假
      vargt  =  '42'.
    ELSEIF p0014-preas  =  '03'. "入离职+病事假
      vargt  =  '43'.
    ELSEIF p0014-preas  =  '04'. "月中折算
      vargt  =  '44'.
    ELSEIF p0014-preas  =  '05'. "入离职及假期折算(除年假/调休
      vargt  =  '45'.
    ELSEIF  p0014-preas  = '06'.
      vargt  =  '46'.
    ELSEIF  p0014-preas  = '07'.
      vargt  =  '47'.
    ELSEIF  p0014-preas  = '08'.
      vargt  =  '48'.
    ELSE.
      vargt  =  '49'.  "0014不需要拆分的工资项
    ENDIF.

  ELSEIF op+5(5) = 'SPLET'.

    IF p0015-preas  =  '01'.   "入离职
      vargt  =  '51'.
    ELSEIF  p0015-preas  =  '02'. "病事假
      vargt  =  '52'.
    ELSEIF p0015-preas  =  '03'.  "入离职+病事假
      vargt  =  '53'.
    ELSEIF p0015-preas  =  '05'.  "入离职及假期折算(除年假/调休
      vargt  =  '55'.
    ELSEIF  p0015-preas = '06'.
      vargt  =  '56'.
    ELSEIF  p0015-preas = '07'.
      vargt  =  '57'.
    ELSEIF  p0015-preas = '08'.
      vargt  =  '58'.
    ELSE.
      vargt  =  '59'.
    ENDIF.

  ENDIF.

  PERFORM fillvargt.

ENDFORM.                    "opy_pbp

*&---------------------------------------------------------------------*
*&      Form  OPY_APZ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM opy_apz.

*>>>>>>>>>> ADD BY YUWEI @26.10.2017 14:20:38 >>>>>>>>>>
*   0015额外性支付中：
*06  入离职及病/事/旷/产/工伤折算  的返回值为56.
*07  入离职及假期折算（除调休） 的返回值为57.
*08  日标准基数折算   的返回值为58.
*
*   0014经常性支付中：
*06  入离职及病/事/旷/产/工伤折算  的返回值为46.
*07  入离职及假期折算（除调休） 的返回值为47.
*08  日标准基数折算   的返回值为48.
*>>>>>>>>>> END BY YUWEI @09.11.2017 16:20:08 <<<<<<<<<<

  IF it-cntr1  =  '15'.  "0015信息类型的工资项

    IF it-cntr2  =  '01'.   "入离职
      vargt  =  '51'.
    ELSEIF it-cntr2 = '02'.  "病事假
      vargt  =  '52'.
    ELSEIF it-cntr2 = '03'.   "入离职+病事假
      vargt  =  '53'.
    ELSEIF it-cntr2 = '05'.   "入离职及假期折算(除年假/调休)
      vargt  =  '55'.
    ELSEIF it-cntr2 = '06'.
      vargt  =  '56'.
    ELSEIF it-cntr2 = '07'.
      vargt  =  '57'.
    ELSEIF it-cntr2 = '08'.
      vargt  =  '58'.
    ELSE.                        "不折算
      vargt  =  '59'.
    ENDIF.

  ELSE.

    LOOP AT p0014  WHERE lgart  = it-lgart
                   AND   begda <= wpbp-endda
                   AND   endda >= wpbp-begda.

      IF p0014-preas  =  '01'.      "入离职
        vargt  =  '41'.
      ELSEIF p0014-preas = '02'.    "病事假
        vargt  =  '42'.
      ELSEIF p0014-preas = '03'.    "入离职+病事假
        vargt  =  '43'.
      ELSEIF p0014-preas = '04'.     "月中折算
        vargt  =  '44'.
      ELSEIF p0014-preas = '05'.     "入离职及假期折算(除年假/调休)
        vargt  =  '45'.
      ELSEIF p0014-preas = '06'.
        vargt  =  '46'.
      ELSEIF p0014-preas = '07'.
        vargt  =  '47'.
      ELSEIF p0014-preas = '08'.
        vargt  =  '48'.
      ELSE.                          "不折算
        vargt  =  '49'.
      ENDIF.

      EXIT.

    ENDLOOP.

    IF vargt IS INITIAL.

      LOOP AT p0008  WHERE begda <= wpbp-endda
                     AND   endda >= wpbp-begda
                     AND   ( lga01 = it-lgart OR
                             lga02 = it-lgart OR
                             lga03 = it-lgart OR
                             lga04 = it-lgart OR
                             lga05 = it-lgart OR
                             lga06 = it-lgart OR
                             lga07 = it-lgart OR
                             lga08 = it-lgart OR
                             lga09 = it-lgart OR
                             lga10 = it-lgart ).
        vargt  =  '81'.
        EXIT.

      ENDLOOP.

      IF vargt  IS INITIAL.

        vargt  =  '99'.

      ENDIF.

    ENDIF.

  ENDIF.

  PERFORM fillvargt.

ENDFORM.                    "OPY_APZ

*&---------------------------------------------------------------------*
*&      Form  opy_skl
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM opy_skl .

  DATA: l_date     TYPE     dats,
        l_begda    TYPE     dats,
        l_endda    TYPE     dats,
        l_werks    TYPE     persa,
        l_count    TYPE     abwtg,
        l_current  TYPE     abwtg,
        l_previous TYPE     abwtg,
        l_p2001    TYPE     TABLE OF p2001 WITH HEADER LINE,
        l_p2010    TYPE     TABLE OF p2010 WITH HEADER LINE,
        wa_var     TYPE     hrvar.

  DATA: cdb1    TYPE     betpe,
        cdb2    TYPE     betpe,
        cdb3    TYPE     betpe,
        cdb4    TYPE     betpe,
        xmb1    TYPE     betpe,
        xmb2    TYPE     betpe,
        xmb3    TYPE     betpe,
        l_betpe TYPE     betpe.
*>>>>> OHR-3010 begin ins
  DATA: xbd1 TYPE     betpe,
        xbd2 TYPE     betpe.
*<<<<< OHR-3010 end ins

*>>>>> OHR-3035 begin
  DATA: jbd1 TYPE     betpe,
        jsb1 TYPE     betpe,
        jsb2 TYPE     betpe.
*<<<<< OHR-3035 end

  SORT wpbp BY begda ASCENDING.
  READ TABLE wpbp INDEX 1.

  l_date   =  wpbp-begda.

  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = l_date
    IMPORTING
      last_day_of_month = l_endda
    EXCEPTIONS
      day_in_no_date    = 1
      OTHERS            = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CONCATENATE l_endda+0(4) '0101' INTO l_begda.
  CONCATENATE l_endda+0(6) '01' INTO l_date.

  SELECT * FROM  pa2001
           INTO  CORRESPONDING FIELDS OF TABLE l_p2001
           WHERE pernr  =  pernr-pernr
           AND   begda <=  l_endda
           AND   endda >=  l_begda
           AND   subty  =  '0200'.
*>>>>> OHR-3035 begin
  IF pernr-btrtl = 'NJ20'.
    SELECT * FROM  pa2001
            APPENDING CORRESPONDING FIELDS OF TABLE l_p2001
            WHERE pernr  =  pernr-pernr
            AND   begda <=  l_endda
            AND   endda >=  l_begda
            AND   subty  =  '0105'.
  ENDIF.
*<<<<< OHR-3035 end
  SELECT * FROM  pa2010
           INTO  CORRESPONDING FIELDS OF TABLE l_p2010
           WHERE pernr  =  pernr-pernr
           AND   begda <=  l_endda
           AND   endda >=  l_begda
           AND   subty  =  '8A23'.

  CLEAR l_count.

  LOOP AT l_p2010.

    l_count = l_count + l_p2010-anzhl.

  ENDLOOP.

  LOOP AT l_p2001.

    IF l_p2001-begda < l_begda.

      l_p2001-begda = l_begda.

    ENDIF.

    IF l_p2001-endda > l_endda.

      l_p2001-endda = l_endda.

    ENDIF.

    IF l_p2001-beguz IS NOT INITIAL AND
       l_p2001-enduz IS NOT INITIAL.

      l_count = l_count + l_p2001-abwtg.

    ELSE.

      l_count = l_count + l_p2001-endda - l_p2001-begda + 1.

    ENDIF.

    IF l_p2001-begda < l_date AND l_p2001-endda > l_date.

      l_p2001-begda = l_date.

    ENDIF.

    IF l_p2001-begda >= l_date.

      IF l_p2001-beguz IS NOT INITIAL AND
         l_p2001-enduz IS NOT INITIAL.

        l_current = l_current + l_p2001-abwtg.

      ELSE.

        l_current = l_current + l_p2001-endda - l_p2001-begda + 1.

      ENDIF.

    ENDIF.

  ENDLOOP.

  l_previous  =  l_count  -  l_current.

  CLEAR vargt.

  CASE pernr-btrtl.

    WHEN 'BJ10'.

      READ TABLE var WITH KEY lgart  =  'CDB1'.
      cdb1  =  var-betpe.

      READ TABLE var WITH KEY lgart  =  'CDB2'.
      cdb2  =  var-betpe.

      READ TABLE var WITH KEY lgart  =  'CDB3'.
      cdb3  =  var-betpe.

      READ TABLE var WITH KEY lgart  =  'CDB4'.
      cdb4  =  var-betpe.

      IF l_count > 0 AND l_count <= 30.

        l_betpe  =  100000 * cdb1.

      ELSEIF l_count > 30 AND l_count <= 90.


        IF l_previous  >= 30.

          l_betpe  =  100000 * cdb2.

        ELSE.

          l_betpe  = 100000 * ( ( 30 - l_previous ) * cdb1 +
                  ( l_current - 30 + l_previous ) * cdb2 ) / l_current.

        ENDIF.


      ELSEIF l_count > 90 AND l_count <= 180.

        IF l_previous  >= 90.

          l_betpe  =  100000 * cdb3.

        ELSE.

          l_betpe  = 100000 * ( ( 90 - l_previous ) * cdb2 +
                  ( l_current - 90 + l_previous ) * cdb3 ) / l_current.

        ENDIF.


      ELSEIF l_count > 180.

        IF l_previous  >= 180.

          l_betpe  =  100000 * cdb4.

        ELSE.

          l_betpe  = 100000 * ( ( 180 - l_previous ) * cdb3 +
                  ( l_current - 180 + l_previous ) * cdb4 ) / l_current.

        ENDIF.


      ENDIF.

*>>>>> OHR-3035 begin
*病假基本工资计算规则-JS
    WHEN 'NJ20'.
      READ TABLE var WITH KEY lgart  =  'JSB1'.
      jsb1  =  var-betpe.

      READ TABLE var WITH KEY lgart  =  'JSB2'.
      jsb2  =  var-betpe.

      READ TABLE var WITH KEY lgart  =  'JSB3'.
      jsb3  =  var-betpe.

      READ TABLE var WITH KEY lgart  =  'JBD1'.
      jbd1  =  var-betpe.

      IF l_count > 0 AND l_count <= jbd1.

        l_betpe  =  100000 * jsb1.

      ELSEIF l_count > jbd1.

        IF l_previous  >= jbd1.

          l_betpe  =  100000 * jsb2.

        ELSE.

          l_betpe  = 100000 * ( ( jbd1 - l_previous ) * jsb1 +
                  ( l_current - jbd1 + l_previous ) * jsb2 ) / l_current.

        ENDIF.

      ENDIF.
*<<<<< OHR-3035 end

    WHEN 'XM70'.

      READ TABLE var WITH KEY lgart  =  'XMB1'.
      xmb1  =  var-betpe.

      READ TABLE var WITH KEY lgart  =  'XMB2'.
      xmb2  =  var-betpe.

      READ TABLE var WITH KEY lgart  =  'XMB3'.
      xmb3  =  var-betpe.


      READ TABLE var WITH KEY lgart  =  'XBD1'.
      xbd1  =  var-betpe.

      READ TABLE var WITH KEY lgart  =  'XBD2'.
      xbd2  =  var-betpe.

      IF l_count > 0 AND l_count <= xbd1.

        l_betpe  =  100000 * xmb1.

      ELSEIF l_count > xbd1 AND l_count <= xbd2.

        IF l_previous  >= xbd1.

          l_betpe  =  100000 * xmb2.

        ELSE.

          l_betpe  = 100000 * ( ( xbd1 - l_previous ) * xmb1 +
                  ( l_current - xbd1 + l_previous ) * xmb2 ) / l_current.

        ENDIF.

      ELSEIF l_count > xbd2.

        IF l_previous  >= xbd2.

          l_betpe  =  100000 * xmb3.

        ELSE.

          l_betpe  = 100000 * ( ( xbd2 - l_previous ) * xmb2 +
                  ( l_current - xbd2 + l_previous ) * xmb3 ) / l_current.

        ENDIF.

      ENDIF.
*<<<<< OHR-3010 end ins

  ENDCASE.

  READ TABLE var WITH KEY lgart  =  'BJXS'.

  IF sy-subrc <> 0.

    CLEAR wa_var.
    wa_var-lgart  =  'BJXS'.
    wa_var-betpe  =  l_betpe.
    APPEND wa_var TO var.
    CLEAR wa_var.

  ENDIF.

  vargt  =  '1'.

  PERFORM fillvargt.

ENDFORM.                    "opy_skl

*&---------------------------------------------------------------------*
*&      Form  OPY_RND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM opy_rnd.

  DATA: ls_it   LIKE it,
        ls_wpbp LIKE wpbp,
        l_ymawd TYPE t511k-kwert,
        l_totwd LIKE it-anzhl,
        l_adjmt LIKE it-betrg.

  CASE op-modif.
    WHEN '?'.  " Determine if the current wage type is the same for all splits

      IF it-apznr IS INITIAL."if current wage type has no WPBP split - 'No rounding'
        vargt = 'N'.

      ELSE. "if wage type in other splits missing or amount <> current split - 'No rounding'

        vargt = 'Y'.
        LOOP AT wpbp INTO ls_wpbp WHERE apznr <> it-apznr.
          READ TABLE it INTO ls_it WITH KEY abart = it-abart
                                            lgart = it-lgart.
          IF sy-subrc = 0.
            IF it-betrg <> ls_it-betrg.
              vargt = 'N'.
            ENDIF.
          ELSE.
            vargt = 'N'.
          ENDIF.

        ENDLOOP.

      ENDIF.

      PERFORM fillvargt.

    WHEN '>'.   " Check if wage types from all splits adds to 21.75
      " applies only to P0008 wage types ( P99 = 2)

*      Get Monthly working day - 21.75
      PERFORM get-cdatum.
      PERFORM re511k USING calcmolga 'YMAWD' cdatum.
      l_ymawd = t511k-kwert.

      CLEAR l_totwd.
      LOOP AT it INTO ls_it WHERE abart = it-abart
                            AND   lgart = it-lgart.
        ADD ls_it-anzhl TO l_totwd.
      ENDLOOP.

      IF l_totwd = l_ymawd.                                 "21.75
        vargt = 'Y'.
      ELSE.
        vargt = 'N'.
      ENDIF.

      PERFORM fillvargt.

    WHEN '='.   " Get Rounding adjustment = current IT-BETRG - all splits for OT-BETRG

      LOOP AT ot INTO ls_it WHERE abart = it-abart
                            AND   lgart = it-lgart.
        SUBTRACT ls_it-betrg FROM l_adjmt.
      ENDLOOP.

      ADD it-betrg TO l_adjmt.

      CLEAR: ot-anzhl,
             ot-betpe.

      ot-betrg = l_adjmt.

  ENDCASE.



ENDFORM.                    "OPY_RND


*&---------------------------------------------------------------------*
*&      Form  OPY_RCR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM opy_rcr.

  DATA : ls_crt       LIKE LINE OF tcrt.
  DATA : lv_tabix     TYPE sytabix.

  LOOP AT tcrt INTO ls_crt.
    lv_tabix = sy-tabix.

    IF ls_crt-cumty = 'Y' AND ls_crt-taxgp = tax-taxgp.
      DELETE tcrt INDEX lv_tabix.
    ENDIF.
  ENDLOOP.

ENDFORM.                    "OPY_RCR


*&---------------------------------------------------------------------*
*&      Form  OPY_ATC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM opy_atc.

  LOOP AT tax.
  ENDLOOP.

  IF ot-anzhl NE 0 OR ot-betrg NE 0.

    tcrt-taxgp = tax-taxgp.
    tcrt-betrg = ot-betrg.
    tcrt-cumty = op-modif.

    IF op-lgart = '*'.
      tcrt-lgart = ot-lgart.
    ELSE.
      tcrt-lgart = op-lgart.
    ENDIF.

    COLLECT tcrt.
  ENDIF.


ENDFORM.                    "OPY_ATC


*&---------------------------------------------------------------------*
*&      Form  OP_AM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM op_am.

  "Part 1: Get Num
  CASE op+4(1).
    WHEN 'T'.  " TCRT, cumty = 'Y', current tax group, wage type
      CLEAR pfeld.
      LOOP AT tcrt WHERE cumty = 'Y'
                   AND   taxgp = tax-taxgp
                   AND   lgart = op+5(4).
        pfeld = tcrt-betrg.
      ENDLOOP.
  ENDCASE.

  "Part 2: Mathematic equation
  arith1 = ot-betrg. arith2 = pfeld.
  PERFORM arith USING op+3(1).
  ot-betrg = arith1.

ENDFORM.                    "OP_AM