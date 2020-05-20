'             DACDemo1.spin, Version 1.0
{{      Duty Cycle - Digital Analog Wandlung
                    
                   100 KΩ               
            APIN ───┳──────
                  22pF 
                         
                      GND
}}

CON
   _clkmode       = xtal1 + pll16x   ' 80 MHz
   _xinfreq       = 5_000_000

VAR long parameter

PUB go | x
  cognew(@entry, @parameter)      'startup DAC cog and point to DAC value
  repeat
    repeat x from 0 to period     'loop over the entire scale
      parameter := $20C49B * x    '$1_0000_0000 / period * x <- provides full scale voltage
      waitcnt(1000000 +cnt)          'wait 1000 awhile before changing the value
                                  '
DAT
        org
  entry mov dira, diraval         'set APIN to output
        mov ctra, ctraval         'establish counter A mode and APIN
        mov time, cnt             'record current time
        add time, period          'establish next period
  :loop rdlong value, par         'get an up to date duty cycle
        waitcnt time, period      'wait until next period
        mov frqa, value           'update the duty cycle
        jmp #:loop                'do it again
                   '
diraval long |< 0                 'APIN direction
ctraval long %00110 << 26 + 0     'NCO/PWM APIN=0 {BPIN=1} <-not used
period  long 2000                 '2000 = 40kHz period (_clkfreq / period)
time    res 1
value   res 1