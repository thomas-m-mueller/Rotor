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
CON
' Konstanten
  _xinfreq = 5_000_000
OBJ
' Objekte - gemeint sind Funktionsbibliotheken
  term: "com.serial" 
VAR
' Definition der Variablen - immer mit 0 initialisiert
  long Zahl
PUB
' Öffentliche Funktionen - Main muss die erste sein
PUB PrintS (anystring)  
PRIV
' Private Funktionen - sie kapseln interne Funktionen
PRIV Berechne (a, b, c)
DAT
' DATA Abschnitt  für Werte-Definitionen und Assembler-Code
Gruss byte "Hallo", 0