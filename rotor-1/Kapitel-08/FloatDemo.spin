{{
    Calculate a  table of frequency from their corresponding notes.

        f(x) = f0 * (a)^n where f0 = 440, n = note, a = (2)^(1/12)
}}
CON
    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000

OBJ

    term  : "com.serial.terminal"
    fp    : "math.float"
    fs    : "string.float"
    num   : "string.integer"


VAR
    long MX
    long MY
    long PX
    long PY
    long RadiusX
    long RadiusY
    long Winkel
    byte idx
    byte idy
    long X
    long Y
    byte Punkt[24*2]
    byte PIndex
    byte PFlag


PUB Main 

    term.Start(115200)
    fp.Start
 
    
    MX := fp.FloatF (20)    'Mittelpunkt
    MY := fp.FloatF (10) 
    
    RadiusX := fp.FloatF (16)   
    RadiusY := fp.FloatF (8)  
    
    PX := fp.FloatF (1)
    PY := fp.FloatF (1)
 
    
    term.Str(string("X-Koordinate  ## Y-Koordinate "))
    term.NewLine
    term.NewLine
    repeat idx from 0 to 24
      Winkel := idx * 10
      Winkel := fp.FloatF (Winkel)
      PX := fp.AddF (MX, fp.MulF(RadiusX,  fp.Cos (Winkel)))
      PY := fp.AddF (MY, fp.MulF(RadiusY,  fp.Sin (Winkel)))
      term.Str(fs.FloatToString(Winkel))
      term.Str(string(" -> "))
      term.Str(fs.FloatToString(PX))
      term.Str(string(" ## "))
      term.Str(fs.FloatToString(PY))
      term.Str(string(" gerundet "))
      X := fp.RoundFInt(PX)
      Y := fp.RoundFInt(PY)
      term.Str(num.Dec(idx))
      term.Str(string(" : "))      
      term.Str(num.Dec(X))
      term.Str(string(" ~~ "))
      term.Str(num.Dec(Y))
      term.NewLine

      Punkt[PIndex]   := X
      Punkt[PIndex+1] := Y
      PIndex := PIndex + 2
      
    repeat PIndex from 0 to 46 step 2 
       term.Dec (PIndex)
       term.Str(string(" --> "))
       term.Dec (Punkt[PIndex])
       term.Str(string(" ## "))
       term.Dec (Punkt[PIndex+1])
       term.NewLine          




    repeat idy from 0 to 20
      repeat idx from 0 to 40
        repeat PIndex from 0 to 24 
          if (Punkt[PIndex] == idx) AND (Punkt[PIndex+1] == idy)
             term.Char("*")
             PFlag := 1
        if (PFlag == 0)
          term.Char(".") 
        else 
            PFlag := 0
      term.NewLine 
   