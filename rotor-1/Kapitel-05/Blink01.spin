CON
 _clkmode = xtal1 + pll16x
 _xinfreq = 5_000_000

OBJ
  pin  : "Input Output Pins"
  time : "Timing"

PUB Blink26

  repeat
    pin.High(13)
    time.Pause(500)   
    pin.Low(13)
    time.Pause(500)

    
    