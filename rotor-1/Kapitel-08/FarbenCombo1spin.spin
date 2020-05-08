'      FarbenCombo1.spin, Version 1.0
'      Laesst RGB-LED verschiedene Farben darstellen
'      
'      
'               ┌───────────────┐             
'      RGB-LED┌─┤     R1        │
'┌────────────┼─────────────┼┤VSS/GND    
'│            │ │     R2        │
'│    ┌───────┼─────────────┤ 
'│    │       │ │     R3        │
'│    │     ┌─┼─────────────┘ R = 220 Ω             
'│    │     │ └─┘    ┌───────────────────────┐
'└────┼─────┼────────┤P0        
'     │     │        │       PROPELLER
'     └─────┼────────┤P1        
'           │        │                  
'           └────────┤P2          
'                    │                       
'                    
CON
 _clkmode = xtal1 + pll16x      ' System Takt → 80 MHz
 _xinfreq = 5_000_000


VAR 
long SqStack[300*3]              'Stack fuer die Cogs 8 mal 3 long
                    
PUB Main
cognew(RedPwm, @SqStack)            ' Erster Cog fuer Rot
cognew(GreenPwm, @SqStack[300])     ' Zweiter Cog fuer Gruen
cognew(BluePwm, @SqStack[300*2])    ' Dritter Cog fuer Blau

PUB RedPwm | tc, t, tHa

  ctra[30..26] := %00100           ' Configure Counter A to NCO
  ctra[5..0] := 0                  ' Set counter output signal to P0
  frqa := 1                        ' Add 1 to phsa with each clock cycle
  dira[0]~~                        ' P0 auf Ausgang
                                   ' Festlegung der Zeitkonstante
  tC := 4_000                      ' Zyklus                         
  tHa := 1000                      ' define tHa
  t := cnt                         ' Mark counter time
                          
  repeat                           ' Repeat PWM signal
    phsa := -tHa                   ' Set up the pulse
    t += tC                        ' Calculate next cycle repeat
    waitcnt(t)                     ' Wait for next cycle
                                   ' 
PUB GreenPwm | tc, t, tHa

  ctra[30..26] := %00100  ' Configure Counter A to NCO
  ctra[5..0] := 1               ' Set counter output signal to P1
  frqa := 1                       ' Add 1 to phsa with each clock cycle
  dira[1]~~                      ' P1 &#8594; output 
                     ' Determine time increment
  tC := 4_000                  ' Use time increment to set up cycle time                          
  tHa :=2000                  ' define tHa
  t := cnt                        ' Mark counter time
                          
  repeat                         ' Repeat PWM signal
    phsa := -tHa              ' Set up the pulse
    t += tC                     ' Calculate next cycle repeat
    waitcnt(t)                  ' Wait for next cycle
                                ' 
PUB BluePwm | tc, t, tHa

  ctra[30..26] := %00100  ' Configure Counter A to NCO
  ctra[5..0] := 2               ' Set counter output signal to P1
  frqa := 1                       ' Add 1 to phsa with each clock cycle
  dira[2]~~                      ' P1 &#8594; output 
                     ' Determine time increment
  tC := 4_000                  ' Use time increment to set up cycle time                          
  tHa := 2000                    ' define tHa
  t := cnt                        ' Mark counter time
                          
  repeat                         ' Repeat PWM signal
    phsa := -tHa              ' Set up the pulse
    t += tC                     ' Calculate next cycle repeat
    waitcnt(t)                  ' Wait for next cycle