CON
 _clkmode = xtal1 + pll16x
 _xinfreq = 5_000_000


PUB Main

Blink(13)

PUB Blink(Pin)
  dira[Pin]~~ 
  repeat
      waitcnt(80_000_000 + cnt)
      outa[Pin]~~ 
      waitcnt(80_000_000 + cnt)
      outa[Pin]~  