    WHEN 'XM70'.

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

      ELSEIF l_count > JBD1 AND l_count <= JBD2.

        IF l_previous  >= JBD1.

          l_betpe  =  100000 * JSB2.

        ELSE.

          l_betpe  = 100000 * ( ( JBD1 - l_previous ) * JSB1 +
                  ( l_current - JBD1 + l_previous ) * JSB2 ) / l_current.

        ENDIF.

      ELSEIF l_count > JBD2.

        IF l_previous  >= JBD2.

          l_betpe  =  100000 * JSB3.

        ELSE.

          l_betpe  = 100000 * ( ( JBD2 - l_previous ) * JSB2 +
                  ( l_current - JBD2 + l_previous ) * JSB3 ) / l_current.

        ENDIF.

      ENDIF.