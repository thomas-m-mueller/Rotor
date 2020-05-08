
{  2. Musik-Demo, mehrere Toene, Version 1.0

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
 frqa := 44_594          ' Wert zur Bestimmung der Frequenz
                        ' FRQ = Frequenz / 0,018626 
 dira[3] := 1           ' APIN als Ausgang
 waitcnt(40_000_000 + cnt) 'halbe Sekunde Dauer

 frqa := 50_055          ' Wert zur Bestimmung der Frequenz
                        ' FRQ = Frequenz / 0,018626 
 dira[3] := 1           ' APIN als Ausgang
 waitcnt(40_000_000 + cnt) 'halbe Sekunde Dauer

 frqa := 39_728          ' Wert zur Bestimmung der Frequenz
                        ' FRQ = Frequenz / 0,018626 
 dira[3] := 1           ' APIN als Ausgang
 waitcnt(40_000_000 + cnt) 'halbe Sekunde Dauer

 frqa := 28_079          ' Wert zur Bestimmung der Frequenz
                        ' FRQ = Frequenz / 0,018626 
 dira[3] := 1           ' APIN als Ausgang
 waitcnt(40_000_000 + cnt) 'halbe Sekunde Dauer
                            ' 
 frqa := 29_763          ' Wert zur Bestimmung der Frequenz
                        ' FRQ = Frequenz / 0,018626 
 dira[3] := 1           ' APIN als Ausgang
 waitcnt(80_000_000 + cnt) 'ganz Sekunde Dauer

{ 
Die abgespielten Notenn mit den Frequenzen:
g' 830,61
a' 932,33
f' 739,99
c  523,25
c' 554,37
}   