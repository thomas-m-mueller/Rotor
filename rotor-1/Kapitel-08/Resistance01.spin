'Kommentar - einzeilig
{
  Block - Kommentar mit geschwungenen Klammern
  Damit lassen sich Schaltungen
  mit Sonderzeichen des Parallax Fonts
  Δ Ω ≈           ─ │ ┼ ╋ ┤ ├ ┴ ┬ 
  ┫ ┣ ┻ ┳ ┘└ ┐ ┌           
            
  beschreiben           Vdd
                         
                 R1 ┌────┴────┐
         P0 ────┤1   6   5├──NC
                    │         │
         P2 ───────┤2   3   4├──NC
                    └────┬────┘
                         
                        Vss 
  oder Code-Abschnitte
  einfach auskommentieren 
 }
'' TestRcDecay.spin
'' Test RC circuit decay measurements.
CON
   _clkmode = xtal1 + pll8x ' System clock → 80 MHz
   _xinfreq = 5_000_000
OBJ
   pst : "com.serial.terminal" ' Use with Parallax Serial Terminal to
                                    ' display

PUB Init
                     'Start Parallax Serial Terminal; waits 1 s for you to click Enable button
    pst.Start(9600)
                     ' Configure counter module.
    ctra[30..26] := %01000 ' Set mode to "POS detector"
    ctra[5..0] := 4             ' Set APIN to 4 (P4)
    frqa := 1                   ' Increment phsa by 1 for each clock tick
    main                        ' Call the Main method

PUB Main | time
                                '' Repeatedly takes and displays P17 RC decay measurements.

  repeat
                                ' Charge RC circuit.
    dira[4] := outa[4] := 1     ' Set pin to output-high
    waitcnt(clkfreq/100_000 + cnt) ' Wait for circuit to charge
                                   ' Start RC decay measurement. It's automatic after this...
    phsa~ ' Clear the phsa register
    dira[4]~                     ' Pin to input stops charging circuit
                                  ' Optional - do other things during the measurement.
    pst.Str(String(pst#NL, pst#NL, "Zeitmessung: ", pst#NL))
    repeat 22
       pst.Char(".")
       waitcnt(clkfreq/60 + cnt)
                                 ' Measurement has been ready for a while. Adjust ticks between phsa~ & dira[17]~.
    'time := (phsa - 625 -180) #> 0
    time := phsa
                                 ' Display Result
    pst.Str(String(pst#NL, "ticks = "))
    pst.Dec(time)
    waitcnt(clkfreq/2 + cnt)
    
    
    {
       Potentiometer     776 -  21150  tics  
       
       Photozelle         1636 - 112000
       
       Themistor (nur bei wenger Takt rund 11000 Zimmertemperatur)
    }