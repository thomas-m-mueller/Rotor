'Prototyp "Willkommen"-Programm, Version 0.6
CON
' Konstanten
  _xinfreq = 5_000_000
  _clkmode = xtal1 + pll16x        ' Multiplikator 16
OBJ
' Objekte - gemeint sind Funktionsbibliotheken
  term: "com.serial.terminal"   ' Ein/Ausgabe Terminal
VAR
' Definition der Variablen - immer mit 0 initialisiert
  byte Namen[50]            ' Zeichenkette für Eingabe
  byte Buchstaben     ' Wert für Anzahl der Buchstaben
  byte Index          ' Index in der Zeichenkette
  byte Gefunden       ' Gefundene Buchstaben
  
PUB Main
  term.Start (115200)           'Initiieren mit 115200
  term.Str (string("Willkommen !"))
  term.NewLine                        'Zeile umbrechen
  repeat                          ' Wiederhole Eingabe
    term.Str (string("Wie ist Dein Name?"))
    term.NewLine
                 ' Namen wird in max 49 Zeichen erfasst
             ' und die Anzahl in Buchstaben gespeichert
    Buchstaben := term.ReadLine (@Namen, 49)
  while(Buchstaben == 0)     ' Solange keine Buchstaben
  term.Str (string("Hallo "))
  term.Str (@Namen)           '           Namen ausgeben
  term.NewLine
  repeat Index from 0 to (Buchstaben - 1)
       if (Namen[Index] > 64) AND (Namen[Index] < 91)
          Gefunden := Gefunden + 1
       elseif (Namen[Index] > 96) AND (Namen[Index] < 123)
          Gefunden++
  term.Str (string("Dein Name hat "))
  term.Dec (Gefunden)        '   Anzahl der Buchstaben 
  term.Str (string(" Buchstaben"))