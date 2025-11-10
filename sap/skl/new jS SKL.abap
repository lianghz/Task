

*>>>>> OHR-XXXX begin
  DATA: BJD1 TYPE     betpe,
        BJD2 TYPE     betpe,
        BJD3 TYPE     betpe.
*<<<<< OHR-XXXX end    
    
    WHEN 'NJ20'.

      READ TABLE var WITH KEY lgart  =  'JSB1'.
      JSB1  =  var-betpe.

      READ TABLE var WITH KEY lgart  =  'JSB2'.
      JSB2  =  var-betpe.

      READ TABLE var WITH KEY lgart  =  'JSB3'.
      JSB3  =  var-betpe.


      READ TABLE var WITH KEY lgart  =  'JBD1'.
      JBD1  =  var-betpe.

      READ TABLE var WITH KEY lgart  =  'JBD2'.
      JBD2  =  var-betpe.

      IF l_count > 0 AND l_count <= JBD1.

        l_betpe  =  100000 * JSB1.
        BJD1 = L_CURRENT.
        BJD2 = 0.
        BJD3 = 0.

      ELSEIF l_count > JBD1 AND l_count <= JBD2.

        IF l_previous  >= JBD1.
          l_betpe  =  100000 * JSB2.

          BJD1 = 0.
          BJD2 = L_CURRENT.
          BJD3 = 0.     
        ELSE.
          l_betpe  = 100000 * ( ( JBD1 - l_previous ) * JSB1 +
                  ( l_current - JBD1 + l_previous ) * JSB2 ) / l_current.

          BJD1 = JBD1 - l_previous.
          BJD2 = l_current - JBD1 + l_previous.
          BJD3 = 0. 
        ENDIF.

      ELSEIF l_count > JBD2.

        IF l_previous  >= JBD2.

          l_betpe  =  100000 * JSB3.
          BJD1 = 0.
          BJD2 = 0.
          BJD3 = l_current.          

        ELSE.

          l_betpe  = 100000 * ( ( JBD2 - l_previous ) * JSB2 +
                  ( l_current - JBD2 + l_previous ) * JSB3 ) / l_current.
          BJD1 = 0.
          BJD2 = JBD2 - l_previous.
          BJD3 = l_current - JBD2 + l_previous.                  

        ENDIF.

      ENDIF.

      READ TABLE var WITH KEY lgart  =  'BJD1'.
      IF sy-subrc <> 0.
        CLEAR wa_var.
        wa_var-lgart  =  'BJD1'.
        wa_var-betpe  =  BJD1.
        APPEND wa_var TO var.
        CLEAR wa_var.
      ENDIF.

      READ TABLE var WITH KEY lgart  =  'BJD2'.
      IF sy-subrc <> 0.
        CLEAR wa_var.
        wa_var-lgart  =  'BJD2'.
        wa_var-betpe  =  BJD2.
        APPEND wa_var TO var.
        CLEAR wa_var.
      ENDIF.

      READ TABLE var WITH KEY lgart  =  'BJD3'.
      IF sy-subrc <> 0.
        CLEAR wa_var.
        wa_var-lgart  =  'BJD3'.
        wa_var-betpe  =  BJD3.
        APPEND wa_var TO var.
        CLEAR wa_var.
      ENDIF.
