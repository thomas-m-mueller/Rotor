'      Blink3.spin, Version 1.0
'      Laesst 3 LEDs gleichzeitig blinken
'      
'LED rot
'┌──────────────────────────┐     
'│     LED gruen              │
'│    ┌────────────────────VSS  
'│    │     LED gelb          │
'│    │     ┌───────────────┘              
'│    │     │     R1 ┌──────────┐
'└────┼─────┼──────┤P0        │
'     │     │     R2 │           PROPELLER
'     └─────┼──────┤P1        
'           │     R3 │           R = 220 Ω         
'           └──────┤P2          
'                    │                  
CON
 _clkmode    = xtal1 + pll16x
 _xinfreq    =  5_000_000
 DRITTEL_SEK = 30_000_000    ' Konstante fuer eine Drittel-Sekunde
 VOLLE_SEK   = 80_000_000    ' Konstante fuer eine Sekunde 

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