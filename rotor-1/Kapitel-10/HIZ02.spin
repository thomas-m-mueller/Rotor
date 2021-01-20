'                 HIZ02.spin
'                 I2C-Protokoll - EEPROM Demo Version 1.0                 
'                 diesmal mit kompletter HIZ-VARIANTE !
'                 kein OUTA[] := 1 mehr, kann entfallen
'                 DIRA[] := 1 soll ersetzt werden durch DIRA[] := 0 

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
   
OBJ
  term : "com.serial.terminal"

VAR
  byte ackbit 'Antwort des EEPROMs
   
PUB main | i
  term.start(115200)
  term.str(string("EEPROM -> Vorhanden ?", 13))                                   

                    '** START
                      ' CLOCK auf HIGH-Z
  dira[SCL] := 0
                      ' DATA auf  HIGH
  dira[SDA] := 0
  outa[SDA] := 0      ' Jetzt DATA auf LOW
  dira[SDA] := 1      ' LOW-OUT
  outa[SCL] := 0      '       CLOCK auf LOW
  dira[SCL] := 1      ' LOW-OUT
                    '** ADRESSIERUNG CHIP-NUMMER
  dira[SDA] := 0         'HI-Z erstes Bit der Chip-Nummer: 1
  dira[SCL] := 0       ' CLOCK auf HIGH-Z
  outa[SCL] := 0       ' CLOCK auf LOW
  dira[SCL] := 1
  outa[SDA] := 0       ' zweites Bit der Chip-Nummer:      0
  dira[SDA] := 1       ' LOW-OUT
                       ' CLOCK auf HIGH -Z
  dira[SCL] := 0
  outa[SCL] := 0       ' CLOCK auf LOW
  dira[SCL] := 1       ' LOW-OUT
                       ' drittes Bit der Chip-Nummer:      1
  dira[SDA] := 0    
                       ' CLOCK auf HIGH -Z
  dira[SCL] := 0       
  outa[SCL] := 0       ' CLOCK auf LOW
  dira[SCL] := 1       ' LOW-OUT             '
  outa[SDA] := 0       ' viertes Bit der Chip-Nummer:      0
  dira[SDA] := 1       ' LOW-OUT               ' 
                       ' CLOCK auf HIGH -Z
  dira[SCL] := 0       ' CLOCK auf HIGH
  outa[SCL] := 0       ' CLOCK auf LOW
  dira[SCL] := 1       ' LOW-OUT
  outa[SDA] := 0       ' fuenftes Bit der Chip-Nummer:     0
  dira[SDA] := 1       ' LOW-OUT
                       ' CLOCK auf HIGH -Z
  dira[SCL] := 0       ' CLOCK auf HIGH 
  outa[SCL] := 0       ' CLOCK auf LOW
  dira[SCL] := 1       ' LOW-OUT
  outa[SDA] := 0       ' sechstes Bit der Chip-Nummer:     0
  dira[SDA] := 1       ' LOW-OUT
                       ' CLOCK auf HIGH -Z  
  dira[SCL] := 0       ' CLOCK auf HIGH 
  outa[SCL] := 0       ' CLOCK auf LOW
  dira[SCL] := 1       ' LOW-OUT
  outa[SDA] := 0       ' siebentes Bit der Chip-Nummer:    0
  dira[SDA] := 1       ' LOW-OUT                       ' 
                       ' CLOCK auf HIGH -Z
  dira[SCL] := 0       ' CLOCK auf HIGH 
  outa[SCL] := 0       ' CLOCK auf LOW
  dira[SCL] := 1       ' LOW-OUT 
  outa[SDA] := 0       ' R/W-Bit fuer Schreib/Lesevorgang: 0
  dira[SDA] := 1       ' LOW OUT
                       ' CLOCK auf HIGH -Z
  dira[SCL] := 0       ' CLOCK auf HIGH 
  outa[SCL] := 0       ' CLOCK auf LOW
  dira[SCL] := 1       ' LOW-OUT                      ' 
  ackbit    := 0       ' initialisere das ACK-BIT fuer das Input-Signal
  dira[SDA] := 0       ' DATA auf INPUT
                       ' CLOCK auf HIGH -Z                       ' 
  dira[SCL] := 0       ' CLOCK auf HIGH
  ackbit := 1
  ackbit := ina[SDA]   ' Signal abfragen
  outa[SCL] := 0       ' CLOCK auf LOW
  dira[SCL] := 1       ' LOW OUT              ' 
  outa[SDA] := 0       ' DATA auf LOW                    '  
  dira[SDA] := 1       ' LOW OUT
                     ' **STOP 
  dira[SCL] := 0       ' Zuerst CLOCK auf HIGH ' 
  dira[SDA] := 0       ' dann DATA auf HIGH
  if (ackbit == ACK)
     term.str(string("EEPROM hat bestaetigt", 13))  
  else
     term.str(string("EEPROM hat nicht bestaetigt", 13))
