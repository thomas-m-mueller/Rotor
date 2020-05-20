'             ADCDemo1.spin, Version 1.0
{{           Analog Digital Wandlung
                     Vdd
                      ┬
                 100K22pF
   Analog Input ───╋──┳──── INP_PIN P6
                 22pF └── FB_PIN  P5
                         100K
                     GND
}}

CON
   _clkmode       = xtal1 + pll8x   ' 40 MHz
   _xinfreq       = 5_000_000

OBJ

  term : "com.serial.terminal" 

VAR

  long  Wert                  'ADC - Messwert.

PUB  Start

  term.Start(115200)          'Start der Terminal-Ausgabe.
  repeat
    DoADC                     ' Messfunktion aufrufen
    term.Str (string(" Gemessener Wert: "))
    term.Dec (Wert)
    term.NewLine
    waitcnt(clkfreq/2 + cnt)  'Pause

PUB  DoADC
  ctra[30..26] := %01001      'Modus: POS Detector with Feedback
  ctra[5..0]  := 6            'Input-Pin
  dira[6]~                    'auf Eingang
  ctra[13..9] := 5            'Feedback-Pin
  dira[5]~~                   'auf Ausgang
  frqa := 1                   'Addiere 1 mit jedem Taktzyklus
  
  phsa := 0                   ' Zähler auf 0
  waitcnt(512 + cnt)          ' warte 512 
  Wert := phsa  
   
    

' 
