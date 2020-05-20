' Demoprogramm fuer POS-Detector-Modus des Propeller, Version 1.0
{
        

 P4 ─────┳───────────┐
          │ Poti      │
          └ 10KΩ   0.10 μF 
            │         │
             100Ω    │
                     
           GND       GND
 }

CON
   ' _clkmode = xtal1 + pll16x      ' System clock → 80 MHz
   _clkmode = xtal1 + pll8x      ' System clock → 40 MHz
   _xinfreq = 5_000_000
   
OBJ
   term : "com.serial.terminal"                                       ' display

VAR
    long time 
   
PUB Main
                     
    term.Start(115200)            ' Terminalausgabe starten
                                  ' 
                                  ' Konfiguration des Zaehlers
    ctra[30..26] := %01000        ' mit POS-Detector
    ctra[5..0] := 4               ' APIN = P4
    frqa := 1                     ' Pro Tick 1 addieren
    Detect                        ' Mess-Funktion aufrufen
                                  ' 

PUB Detect 

  repeat                          ' Dauerschleife
                         'Phase 1 - Aufladen
    dira[4]~~                      ' Pin 4 auf Ausgang setzen
    outa[4]~~                      ' P4 wird High, dh. Kondensator
                                   ' wird aufgeladen
    waitcnt(clkfreq/10_000 + cnt) ' Zeit zum Aufladen
                                   ' 
                         'Phase 2 - Entladen und Zaehlen                                
    phsa~                          ' phsa = 0
    dira[4]~                       ' Pin 4 auf Eingang
                                    
    term.Str(String(term#NL, term#NL, "Zeitmessung: "))
    repeat 15
       term.Char(".")
       waitcnt(clkfreq/60 + cnt)    ' Pause 
    
    time := phsa                    ' Zaehler auslesen
                                    ' 
    if (time > 6000000)             ' Wenn zu hoch, dann Fehler
       term.Str(String(term#NL, "Messfehler! "))
    else
      term.Dec(time)                ' Anzahl der Ticks
      term.Str(String(term#NL))
      'time := time - 735 #> 0       ' Korrekturwert ( fuer 80 MHz!)
      time := time - 720  #> 0       ' Korrekturwert ( fuer 40 MHz!)
                                     ' begrenz auf 0                             ' 
      term.Str(String(term#NL, "Wiederstand: "))

    repeat 15
       term.Char(".")
       waitcnt(clkfreq/60 + cnt)    ' Pause 

    'term.Dec(((time*100)/239))      ' Umrechnung Ticks zu Ohm
                                    ' (fuer 80 MHz!)
    term.Dec(((time*100)/119))      ' Umrechnung Ticks zu Ohm
                                    ' (fuer 40 MHz!)
    waitcnt(clkfreq/2 + cnt)        ' Pause 
    
    