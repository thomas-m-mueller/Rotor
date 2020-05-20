' "Willkommen"-Programm,mit optischem Feedback - Version 2.0
' "Willkommen009.spin"
CON   ' Konstanten
  _xinfreq = 5_000_000
  _clkmode = xtal1 + pll16x        ' Multiplikator 16
  ZEHNTEL_SEK = 10__000_000
  VOLLE_SEK   = 80_000_000  
                                   
OBJ   ' Funktionsbibliotheken
  term: "com.serial.terminal"   ' Ein/Ausgabe Terminal
                                
VAR   ' Definition der Variablen - immer mit 0 initialisiert
  byte Namen[50]      ' Zeichenkette für Eingabe
  byte Zeichen        ' Wert fuer Anzahl der Zeichen
  byte Index          ' Index in der Zeichenkette
  byte Gefunden       ' Gefundene Buchstaben
  byte Fehler         ' Indikator für Falscheingabe
  byte R_Hoehe        ' Anzahl der Zeilen fuer Rahmen
  byte R_Breite       ' Anzahl der Zeichen fuer Rahmen
  byte Abstand        ' Abstand zwischen Zeilen und Rahmen
  byte x              ' Zaehler in Schleifen
  byte y              ' Zaehler in Schleifen
                      ' 
  long SqStack1[20] 'Stack fuer 1. Cog 20 long
  long SqStack2[20] 'Stack fuer 2. Cog 20 long
  long SqStack3[20] 'Stack fuer 3. Cog 20 long
  byte GREEN        'Cog-Nummer fuer Aktiv()
  byte YELLOW       'Cog-Nummer fuer Taste()
  byte RED          'Cog-Nummer fuer Alarm()
  byte AlarmFlag    'Signal für Alarm()
  
PUB Main ' Hauptprogramm
                       'Gruene LED einschalten:
  GREEN  := cognew (Aktiv(1), @SqStack1)
                       'Gelbe LED-Funktion initialisieren:
  YELLOW := cognew (Taste(@Namen,@AlarmFlag,2), @SqStack2)
                       'Rote LED-Funktion initialisieren:
  RED    := cognew (Alarm(@AlarmFlag,0), @SqStack3)
  term.Start (115200)       ' Initiieren Terminal mit 115200 Baud
  R_Hoehe := 10             ' 10 Zeilen  in der Hoehe
  R_Breite := 40            ' 40 Zeichen in der Breite
  Abstand := 2              ' 2 Zeilen bzw. Spalten als Standard  
  Pos00                     ' Gehe in die linke obere Ecke des Bildschirms
  term.NewLine
  Rahmen(R_Hoehe,R_Breite)  ' Zeichne den Rahmen 40 mal 15
  Pos00 
  Ident                     ' Ruecke um 2 Spalten (Abstand) ein
  PrintS(@gruss, Abstand)   ' Fuege "Willkommen!" ein            
  PrintS(@frage, Abstand)   ' Fuege "Wie ist Dein Name ?" ein                     
  repeat                    ' Wiederhole Eingabe
    Pos00
    term.MoveDown (R_Hoehe)       'Gehe in Zeile unter dem Rahmen
    PrintS(string(">:"), Abstand) 'Prompt ausgeben 
    if (Zeichen > 0)              ' Nur wenn Zeichen eingegeben wurden
      term.MoveRight (Zeichen)    ' Bewege Cursor um Zeichen nach rechts
      repeat y from 1 to Zeichen  ' Zeichen mit Backspace loeschen
          term.Str    (string(term#BS))
                                  ' Namen wird in max 49 Zeichen erfasst
                                  ' und die Anzahl in Zeichen gespeichert
    AlarmFlag := 0              ' Alarm zuruecksetzen
    bytefill(@Namen,0,49)       ' Eingabepuffer Namen mit 0 leeren
    Zeichen := term.ReadLine (@Namen, 49)
    term.MoveUp(R_Hoehe + 2)
    term.MoveLeft (R_Breite+1)
    Gefunden := 0    ' innerhalb der Schleife wieder auf 0
    Fehler   := 0   
    if (Zeichen > 0) ' verhindert dass Zeichen kleiner 0 wird            ' 
        repeat Index from 0 to (Zeichen - 1)
            case Namen[Index]
                45 .. 46: ' Bindestrich, Punkt - gueltig 
                65 .. 90:  Gefunden++    ' Grossbuchstaben
                           AlarmFlag := 0
                97 .. 122: Gefunden++    ' Kleinbuchstaben
                           AlarmFlag := 0
                32:        'Leerzeichen - gueltig aber kein Buchstabe                       
                other:     Fehler := 1   ' ungueltiges Zeichen
    if (Zeichen == 0) ' ->Fehler: Leerzeile eingegeben
        Pos00
        Ident
        Abstand := 0        ' Ausgabe in selber Zeile 
        PrintS (@keinz, Abstand)
        AlarmFlag := 1      ' Flag fuer Alarm-Funktion
        Abstand := 2
    elseif (Fehler == 1) ' ->Fehler: Sondezeichen im Namen
        Pos00
        Ident
        Abstand := 0               
        PrintS (@sonder, Abstand)
        AlarmFlag := 1      ' Flag fuer Alarm-Funktion
        Abstand := 2 
    elseif (Gefunden < 3) '->Fehler: zuwenig Buchstaben     
        Pos00
        Ident
        Abstand := 0        
        PrintS (@buchsz, Abstand)
        AlarmFlag := 1       ' Flag fuer Alarm-Funktion
        Abstand := 2           
  while ((Zeichen == 0) OR (Gefunden < 3) OR (Fehler == 1)) 
  'repeat solange keine Zeichen oder zuwenig Buchstaben oder Fehleingabe
  Pos00
  Ident
  Abstand := 0        
  PrintS (@loesch, Abstand) ' Letzte Meldung wird geloescht
  Abstand := 2 
  Pos00
  Ident
  term.MoveDown (Abstand * 2) 
  PrintS (@hallo, Abstand)
  PrintS (@Namen, 0)         ' Namen ausgeben
  Pos00
  Ident
  term.MoveDown (Abstand * 3)
  PrintS (@name, Abstand)    ' fuege "Dein Name hat " ein
  PrintZ (Gefunden)          ' Anzahl der Buchstaben
  PrintS (@buchst,0)         ' fuege " Buchstaben" ein
  Pos00
  cogstop (GREEN)            'Aktiv() beenden
  cogstop (YELLOW)           'Taste() beenden
  cogstop (RED)              'Alarm() beenden
  
PUB Pos00
    term.Position (0,0)
    
PUB Ident
    term.MoveRight (Abstand)

PUB Rahmen(Zeilen,Breite)              'Funktion zum Ausgeben eines Rahmens
    term.Str    (string("+"))          'erste Zeile
    repeat x from 1 to Breite
        term.Str    (string("-"))
    term.Str    (string("+"))
    term.NewLine
    repeat y from 1 to Zeilen - 1       ' Mittelstueck
      term.Str    (string("|"))
      repeat x from 1 to Breite         ' Zeilen
        term.Str    (string(" "))
      term.Str    (string("|"))
      term.NewLine
    term.Str    (string("+")) 
    repeat x from 1 to Breite           'letzte Zeile
        term.Str    (string("-"))
    term.Str    (string("+"))
    term.NewLine
    
PUB PrintS (anystring, down)              ' Funktion zur Textausgabe
    term.MoveDown (down)
    term.MoveRight ((strsize(anystring))) ' Zeichenanzahl
    repeat y from 1 to strsize(anystring) ' Zeichen mit Backspace loeschen
      term.Str    (string(term#BS))         
    term.Str (anystring)                  ' Zeichen ausgeben                                     
                                                                                           
PUB PrintZ (number) | positions           ' Funktion zur Zahlenausgabe
    if (number > 9)
      positions := 2
    else 
      positions := 1     
    term.MoveRight (positions) 
    repeat y from 1 to positions        ' Zeichen mit Backspace loeschen
      term.Str    (string(term#BS))         
    term.Dec (number)                     ' Zahl ausgeben
 
PUB Aktiv (Pin)   'Gruene LED leuchtet bis zum Ende des Programms
   dira[Pin]~~ 
   repeat
     outa[Pin]~~       
     waitcnt(ZEHNTEL_SEK + cnt)
     outa[Pin]~ 

PUB Taste (bufferptr, alarmflagptr, Pin)  | counter
          ' bufferptr zeigt auf Namen[]
          ' alarmflag zeigt auf AlarmFlag 
  counter := 0 
  dira[Pin]~~ 
  repeat 
    if byte[bufferptr + counter] > 0 ' prueft Namen[counter] 
       outa[Pin]~~       
       waitcnt(ZEHNTEL_SEK + cnt)
       outa[Pin]~ 
       counter++                     ' naechste Speicherzelle
    if byte[alarmflagptr] > 0
       counter := 0                  ' nach Fehler Zaehler auf 0
 
PUB Alarm (bufferptr, Pin) 
          ' bufferptr zeigt auf AlarmFlag 
  dira[Pin]~~ 
  repeat   
    if byte[bufferptr] > 0  ' AlarmFlag == 1 ?
       repeat 3
          outa[Pin]~~       
          waitcnt(VOLLE_SEK + cnt)
          outa[Pin]~ 
          waitcnt(VOLLE_SEK + cnt)
 
DAT
gruss  byte "            Willkommen !",0
frage  byte "Wie ist Dein Name ?",0
keinz  byte "   Du hast noch nichts eingegeben ! ",0
sonder byte "     Bitte keine Sonderzeichen !    ",0
buchsz byte "        Der Name ist zu kurz !      ",0
loesch byte "                                    ",0    
hallo  byte "Hallo ",0
name   byte "Dein Name hat ",0 
buchst byte " Buchstaben",0 

'                              Pinbelegung:
'LED rot              R1
'┌────────────────────────┐     
'│     LED gruen      R2      │
'│    ┌──────────────────VSS/GND  
'│    │     LED gelb  R3      │
'│    │     ┌─────────────┘ R = 220 Ω             
'│    │     │        ┌──────────
'└────┼─────┼────────┤P0        
'     │     │        │      PROPELLER
'     └─────┼────────┤P1        
'           │        │                  
'           └────────┤P2          
'                    │  