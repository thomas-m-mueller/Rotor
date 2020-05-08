'Prototyp "Willkommen"-Programm, Version 0.2
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
  
PUB Main
  
  term.Start (115200)           'Initiieren mit 115200
  term.Str (string("Willkommen !"))
 