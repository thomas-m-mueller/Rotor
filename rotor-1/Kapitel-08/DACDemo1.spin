'             DACDemo1.spin, Version 1.0
{{      Duty Cycle - Digital Analog Wandlung
                    
                  220 Ω               
            APIN ───┳──────┐ LED
                 22 pF       │
                                 
                      GND      GND
}}

CON
   _clkmode       = xtal1 + pll8x   ' -> Systemtakt 40 MHz
   _xinfreq       = 5_000_000

OBJ
   term : "com.serial.terminal"       

VAR
  long  Teiler
  long  Skala                
                             
PUB  Start

  term.Start(115200)          ' Terminalausgabe starten
  Skala := $200_0000          ' = 33,554.432
                              ' (2 hoch 32 durch 128) 
  ctra[30..26] := %00110      'Modus: Duty Cycle
  ctra[5..0]  := 0            'Output-Pin
  dira[0]~~                   'APIN auf Ausgang 
  phsa := 0                     
  frqa := 0                                        
  repeat 
    term.Str(String(term#NL,"Dutyanteil  -- Hexwert in FRQA",term#NL)) 
    repeat Teiler from 0 to 128  step 4   ' Wir zählen den Teiler hoch
                                          ' in 4er Schritten
      frqa := Teiler * Skala              ' berechnen "Duty" neu
      term.Dec(Teiler)                    ' aktueller Teiler
      term.Str(String("          --   ")) 
      term.Hex (frqa,8)                   ' Hexwert im FRQA-Register
      term.NewLine
      waitcnt(10_000_000 + cnt)             ' und warten ein wenig
    term.Str(String("         Hoechste Volt: 1,84",term#NL))