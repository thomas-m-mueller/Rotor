'                 HIZ01.spin
'                 I2C-Protokoll - EEPROM Demo Version 1
'                 Taktung der Daten- und Clock-Leitung
'                 konventionell mit DIRA:=1 und OUTA:=1
'                 funktioniert auch ohne Pullup-Widerstaende
CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000 
  SCL = 28                ' Pin fuer Takt-Leitung (Clock)
  SDA = 29                ' Pin fuer Datenleitung
  ACK = 0                 ' Alles ok
  NACK = 1                ' Fehlersignal
                          ' 87654321-Bit   
  I2C_EPROM = %1010_0000  ' 1010000 + RW
                          ' 7 bittige Nummer des EEPROMs
  EEAddress = $8000       ' obere 32K im Speicher
                          ' 
OBJ
  term : "com.serial.terminal"

VAR
  byte ackbit  ' Antwort des EEPROMs
  
PUB main | i
  term.start(115200)
  term.str(string("EEPROM -> Vorhanden ?", 13))                                

                   '** START
  outa[SCL] := 1     ' CLOCK auf HIGH
  dira[SCL] := 1
  outa[SDA] := 1     ' DATA auf  HIGH
  dira[SDA] := 1
  outa[SDA] := 0     ' Jetzt DATA auf LOW
  outa[SCL] := 0     '       CLOCK auf LOW
                   '** ADRESSIERUNG CHIP-NUMMER
  outa[SDA] := 1     ' erstes Bit der Chip-Nummer:    1
  outa[SCL] := 1     ' CLOCK auf HIGH
  outa[SCL] := 0     ' CLOCK auf LOW
  outa[SDA] := 0     ' zweites Bit der Chip-Nummer:   0
  outa[SCL] := 1     ' CLOCK auf HIGH
  outa[SCL] := 0     ' CLOCK auf LOW
  outa[SDA] := 1     ' drittes Bit der Chip-Nummer:   1
  outa[SCL] := 1     ' CLOCK auf HIGH
  outa[SCL] := 0     ' CLOCK auf LOW
  outa[SDA] := 0     ' viertes Bit der Chip-Nummer:   0
  outa[SCL] := 1     ' CLOCK auf HIGH
  outa[SCL] := 0     ' CLOCK auf LOW
  outa[SDA] := 0     ' fuenftes Bit der Chip-Nummer:  0
  outa[SCL] := 1     ' CLOCK auf HIGH
  outa[SCL] := 0     ' CLOCK auf LOW
  outa[SDA] := 0     ' sechstes Bit der Chip-Nummer:  0
  outa[SCL] := 1     ' CLOCK auf HIGH
  outa[SCL] := 0     ' CLOCK auf LOW
  outa[SDA] := 0     ' siebentes Bit der Chip-Nummer: 0
  outa[SCL] := 1     ' CLOCK auf HIGH
  outa[SCL] := 0     ' CLOCK auf LOW
  outa[SDA] := 0     ' R/W-Bit fuer Schreib/Lesevorgang: 0
  outa[SCL] := 1     ' CLOCK auf HIGH
  outa[SCL] := 0     ' CLOCK auf LOW
  ackbit    := 1     ' initialisere das ACK-BIT fuer das Input-Signal
  dira[SDA] := 0     ' DATA auf INPUT
  outa[SCL] := 1     ' CLOCK auf HIGH
  ackbit := ina[SDA] ' Signal abfragen
  outa[SCL] := 0     ' CLOCK auf LOW
  outa[SDA] := 0     ' DATA auf LOW 
  dira[SDA] := 1     ' Leitung auf Output
                   ' **STOP
  outa[SCL] := 1     ' Zuerst CLOCK auf HIGH
  outa[SDA] := 1     ' dann DATA auf HIGH
  dira[SCL] := 0     ' je nach Pullups High oder Low
  dira[SDA] := 0     ' je nach Pullups High oder Low
  if (ackbit == ACK)
     term.str(string("EEPROM hat bestaetigt", 13))  
  else
     term.str(string("EEPROM hat nicht bestaetigt", 13))

   
   
