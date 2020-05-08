'Prototyp "Willkommen"-Programm, Version 0.7
CON   ' Konstanten
  _xinfreq = 5_000_000
  _clkmode = xtal1 + pll16x        ' Multiplikator 16
                                   
OBJ   ' Funktionsbibliotheken
  term: "com.serial.terminal"   ' Ein/Ausgabe Terminal
                                
VAR   ' Definition der Variablen - immer mit 0 initialisiert
  byte Namen[50]      ' Zeichenkette für Eingabe
  byte Zeichen        ' Wert fuer Anzahl der Zeichen
  byte Index          ' Index in der Zeichenkette
  byte Gefunden       ' Gefundene Buchstaben
  byte Fehler         ' Indikator für Falscheingabe
  
PUB Main 
  term.Start (115200)           'Initiieren mit 115200
  term.Str (string("Willkommen !"))
  term.NewLine                        'Zeile umbrechen
  repeat                          ' Wiederhole Eingabe
    if (Zeichen == 0)                 
        term.Str (string("Wie ist Dein Name?"))
    elseif (Fehler == 1)          
        term.Str (string("Bitte gib den Namen richtig ein !")) 
    elseif (Gefunden < 3)          
        term.Str (string("Bitte gib den Namen richtig ein !")) 
    term.NewLine
                     ' Namen wird in max 49 Zeichen erfasst
                     ' und die Anzahl in Zeichen gespeichert
    Zeichen := term.ReadLine (@Namen, 49)
    Gefunden := 0    ' innerhalb der Schleife wieder auf 0
    Fehler   := 0         
    if (Zeichen > 0) ' verhindert dass Zeichen kleiner 0 wird
        repeat Index from 0 to (Zeichen - 1)
            case Namen[Index]
                45 .. 46: ' Bindestrich, Punkt - gueltig 
                65 .. 90:  Gefunden++
                97 .. 122: Gefunden++
                32:        'Leerzeichen - gueltig aber kein Buchstabe                       
                other:     Fehler := 1           
  while ((Zeichen == 0) OR (Gefunden < 3) OR (Fehler == 1)) 
       'solange keine Zeichen oder zuwenig Buchstaben oder Fehleingabe
  term.Str (string("Hallo "))
  term.Str (@Namen)                       ' Namen ausgeben
  term.NewLine

  term.Str (string("Dein Name hat "))
  term.Dec (Gefunden)                     ' Anzahl der Buchstaben
  term.Str (string(" Buchstaben"))