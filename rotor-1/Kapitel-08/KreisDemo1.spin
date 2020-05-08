{{
    
    Dartsellung eines Kreises auf dem Terminal, Version 1.0
 }}
CON
    _clkmode = xtal1 + pll16x
    _xinfreq = 5_000_000

OBJ

    term  : "com.serial.terminal"
    fp    : "math.float"
    fs    : "string.float"

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
    term.Start(115200)   'Terminal-Ausgabe initialisieren
    fp.Start             'Float-Funktionaltaet starten 
                         'Gleitkomma-Zahlen 
    MX := fp.FloatF (24)       'Mittelpunkt X
    MY := fp.FloatF (12)       'Mittelpunkt Y    
    RadiusX := fp.FloatF (16)  ' Radius in X
    RadiusY := fp.FloatF (8)   ' Radius in Y - halbiert 
                               ' zum Ausgleich für unproportionale Ausgabe
                               ' am Terminal 
    PX := fp.FloatF (0)        ' Initialisierung mit 0
    PY := fp.FloatF (0)        ' Ergebnis der COS/SIN-Berechnungen 
                               '     
    term.Str(string("Kreis-Demo: Mittelpunkt: 24 / 12"))
    term.NewLine
    term.NewLine
                               ' Berechnung der Koordinaten
    repeat idx from 0 to 21         ' Umrundung des Kreises in Grad
      Winkel := idx * 10            ' Winkel in 10er-Schritten
      Winkel := fp.FloatF (Winkel)  ' Umwandlung in Float
      PX := fp.AddF (MX, fp.MulF(RadiusX,  fp.Cos (Winkel)))
                                    ' Berechnung der X-Koordinate
      PY := fp.AddF (MY, fp.MulF(RadiusY,  fp.Sin (Winkel)))
                                    ' Berechnung der Y-Koordinate
      X := fp.RoundFInt(PX)         ' Rundungswerte als Integer
      Y := fp.RoundFInt(PY)         ' im byte-Format

      Punkt[PIndex]   := X          ' Speichern der X
                                    ' und Y-Koordinate im Punkt-Array
      Punkt[PIndex+1] := Y
      PIndex := PIndex + 2          ' Index fuer Punkt-Array weiterzaehlen
                            ' Ausgabe des Kreises
    repeat idy from 0 to 20                      ' fuer jede Zeile
      repeat idx from 0 to 40                    ' in jeder Reihe
        repeat PIndex from 0 to 42 step 2        ' pruefen nach passenden Eintrag
          if (Punkt[PIndex] == idx) AND (Punkt[PIndex+1] == idy) 
             term.Char("X")   'X setzen,wenn im Punkte-Array Punkt[] idx und idy enthaelt
             PFlag := 1       ' Punkt wurde ausgegeben - Flag setzen
        if (PFlag == 0)
          term.Char(" ")      ' wenn kein Punkt gefunden wurde - Leerzeichen 
        else 
            PFlag := 0        ' wenn PFlag = 1 dann zuruecksetzen auf 0
      term.NewLine            ' Zeilenumbruch fuer naechste Zeile

{{  --------- AUSGABE ---------
Kreis-Demo: Mittelpunkt: 24 / 12

                                         
                                         
                                         
                                         
                      X   X              
                  X             X        
              X                    X     
                                         
           X                          X  
                                         
         X                             X 
                                         
        X                               X
                                         
        X                                
                                       X 
          X                              
                                     X   
             X                    X      
                 X             X         
                     X   X               

}}
   