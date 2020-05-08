'      Blink3a.spin, Version 0.1
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
 DRITTEL_SEK = 30__000_000
 VOLLE_SEK   = 80_000_000

VAR 
long SqStack0[8] ' Stack fuer den ersten Cog
long SqStack1[8] ' Stack fuer den zweiten Cog
long SqStack2[8] ' Stack fuer den dritten Cog

PUB Main

cognew (Blink(0), @SqStack0)  ' startet Ein/Aus mit Pin P0 in neuem Cog
waitcnt(DRITTEL_SEK + cnt)     ' Pause
cognew (Blink(1), @SqStack1)  ' startet Ein/Aus mit Pin P1 in neuem Cog
waitcnt(DRITTEL_SEK + cnt)     ' Pause
cognew (Blink(2), @SqStack2)  ' startet Ein/Aus mit Pin P2 in neuem Cog


PUB Blink(Pin)   ' Funktion zum Ein- und Aussschalten eines speziellen Pins
  dira[Pin]~~    ' Pin wird zur Ausgabe eingestellt
  repeat
      waitcnt(VOLLE_SEK + cnt) 
      outa[Pin]~~                    ' Pin High
      waitcnt(VOLLE_SEK + cnt)
      outa[Pin]~                     ' Pin Low