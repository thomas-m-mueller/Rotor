
{  Musik-Demo, Toene durch Frequenzen, Version 1.0

 Zaehl-Modul Register

        CTR-Register:               
     ┌────────────────────────────────────────┐
     │31│30..26│25..23│22..15│14..9│ 8..6│5..0│                               │                 
     └────────────────────────────────────────┘ 
     │  │ MODE │PLLDIV│      │BPIN │     │APIN│
         00100                             3
 }
 
CON
 _clkmode    = xtal1 + pll16x
 _xinfreq    =  5_000_000       ' Ergibt clkfreq = 80_000_000
 
PUB Main                '     NCO_single_ended_mode
 ctra[30..26] := %00100 ' Modus fuer ctra "NCO single-ended"
 ctra[5..0] := 3        ' APIN to 4
 frqa := 1_000          ' Wert zur Bestimmung der Frequenz
                        ' FRQ = Frequenz / 0,018626 
 dira[3] := 1           ' APIN als Ausgang
 repeat                 ' Endlosschleife 
