'      Blink3b.spin, Version 0.2
'      Laesst 3 LEDs gleichzeitig blinken
'      
'LED rot              R1
'┌────────────────────────┐     
'│     LED gruen      R2      │
'│    ┌──────────────────VSS/GND  
'│    │     LED gelb  R3      │
'│    │     ┌─────────────┘ R = 220 Ω             
'│    │     │        ┌──────────
'└────┼─────┼────────┤P0        
'     │     │        │      PROPELLER
'     └─────┼────────┤P1        
'           │        │                  
'           └────────┤P2          
'                    │                  

CON
 _clkmode    = xtal1 + pll16x
 _xinfreq    =  5_000_000
 DRITTEL_SEK = 30__000_000          'Zaehler fuer Zeitintervall
 VOLLE_SEK   = 80_000_000           'Zaehler fuer Zeitintervall
 ON          = 1                    'Parameter fuer Blink
 OFF         = 0                    'Parameter fuer Blink

VAR 
long SqStack[8*3] 'Stack fuer die Cogs 8 mal 3 long
byte Cogs[7]     ' Index der 8 Cog-IDs
byte LED         ' Nummer der Leuchtdiode                

PUB Main

repeat LED from 0 to 2 
   Cogs[LED] := cognew (Blink(LED,ON), @SqStack[8*LED])  
   ' startet in neuem Cog, dessen Nummer in Cogs[] gespeichert wird
   waitcnt(DRITTEL_SEK + cnt)     ' Pause

repeat LED from 0 to 2 
   repeat 7                        
      waitcnt(VOLLE_SEK + cnt)     ' Pause
   coginit(Cogs[LED], Blink(LED,OFF), @SqStack[8*LED])
   ' ruft den Cog mit der Nummer aus Cogs[] auf und beendet das Blinken mit OFF=0

                                                            ' 
PUB Blink(Pin, OnOff) | CogNummer  ' Funktion zum Ein- und Aussschalten eines Pins
                                   ' mit Start- und Stop-Funktion für Cogs
  CogNummer := CogId
  if (OnOff == 1)
     dira[Pin]~~    ' Pin wird zur Ausgabe eingestellt
     repeat
        waitcnt(VOLLE_SEK + cnt) 
        outa[Pin]~~                    ' Pin High
        waitcnt(VOLLE_SEK + cnt)
        outa[Pin]~                     ' Pin Low
  elseif (OnOff == 0)
     outa[Pin]~ 
     cogstop(CogNummer)
     
     