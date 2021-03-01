'                 I2C004.spin
'                 I2C-Protokoll - 4. RTC - Real Time Clock DS-1307 Demo Version 1
'                 DATUM und UHR-ZEIT SCHREIBEN
'                 Umsetzung des HI-Z TriStates in Subroutinen
CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
  SCL = 28                ' Pin fuer Takt-Leitung (Clock)
  SDA = 29                ' Pin fuer Datenleitung
  ACK = 0                 ' Alles ok
  NACK = 1                ' Fehlersignal, Break
                          ' 87654321-Stelle im Byte   
  I2C_RTC = %1101_0000    '  1101000 + RW
                          ' 7 bittige Nummer der RTC
                          ' + Schreiben-Bit
  RTCAddress = $0         ' 1. Register 
  
  
OBJ
  term : "com.serial.terminal"
  
VAR
  byte outpin
  byte ackbit
  byte block
  byte idx 
  byte count
  byte cx

    
PUB main
  term.start(115200)
  term.str(string("    ** RTC - Daten-Schreiben", 13))
  term.str(string("    ** Start-Adresse-High: $0"))
  term.NewLine
  term.str(string("    ** Register 0 - 6 werden gesetzt. "))
  '  Definition von Datum und Uhrzeit - Hexzahlen und BCD sind gleich !
  data[0] := $00             'Sekunden
  data[1] := $31             'Minuten
  data[2] := $14             'Stunden
  data[3] := $01             'Wochentag
  data[4] := $24             'Tag
  data[5] := $01             'Monat
  data[6] := $20             'Jahr 
  block := 7                 ' wieviele Bytes schreiben?
  Start
  Write(I2C_RTC) 
  Write($00)                 ' 
   repeat block
    Write(data[idx])
    term.str(string(" $"))
    term.Hex (data[idx], 2)
    term.str(string(" "))
    idx++
  term.NewLine 
  Stop



 
PUB Start                
   term.str(string("    *** START *** ", 13))                                  
   dira[SCL] := 0                   ' SCL High
   dira[SDA] := 0                   ' SDA High                                  
   dira[SDA] := 1   
   outa[SDA] := 0                   ' SDA Low
   dira[SCL] := 1                                            ' 
   outa[SCL] := 0                   ' SCL Low
     
PUB Write(data1) : ackbit1
   term.str(string("    *** DATA WRITE *** ", 13))
   term.str(string("      "))
   ackbit1 := 0 
   data1 <<= 24
   repeat 8                         ' Output 8 Bits auf SDA
      data1 <-= 1                   ' Bit um 1 Stelle verschieben
      if (data1 & 1)
        dira[SDA] := 0              ' High -> 1
      else
        dira[SDA] := 1
        outa[SDA] := 0              ' Low  -> 0
      dira[SCL] := 0
      dira[SCL] := 1                   
      outa[SCL] := 0
   dira[SDA] := 0                   ' SDA als Input for ACK/NACK
   dira[SCL] := 0
   term.str(string("DATA <- IN: " ))   
   if (ina[SDA] == 0 )
     term.str(string("EEPROM: ACK ! ", 13))
     ackbit1 := 0
   else 
     ackbit1 := 1
   dira[SCL] := 1
   outa[SCL] := 0                   ' CLK Low
   dira[SDA] := 1
   outa[SDA] := 0                   ' SDA Low

PUB Read(ackbit1): data1
   data1 := 0
   dira[SDA]:=0                     ' SDA als Input                                  ' 
   repeat 8                         ' 1 Byte = 8 Bits empfangen
      outa[SCL] := 1                ' solange SCL high ist 
      data1 := (data1 << 1) | ina[SDA]
      outa[SCL] := 0
   outa[SDA] := ackbit1             ' ACK als Empfangsbestaetigung
   term.str(string("*" ))                                     '
   dira[SDA] := 1
   dira[SCL] := 0
   dira[SCL] := 1                   ' SCL von Low zu High zu Low       
   outa[SCL] := 0
   dira[SDA] := 1
   outa[SDA] := 0                   ' SDA auf LOW belassen 

   
PUB Stop
   term.str(string("    *** STOP ***", 13))
   dira[SCL] := 0                   ' SCL auf High
   dira[SDA] := 0                   ' SDA auf High
                                    ' und so belassen


PUB BCD2INT(bcd) : result                 ' BCD in Dezimalwert konvertieren
  result :=((bcd / 16) *10) + (bcd // 16) ' durch 16 entspricht >> 4 
  return result   
  
PUB INT2BCD(wert) : result                 'Dezimalzahl in BCD umwandeln
  ' convert integer to BCD (Binary Coded Decimal)
  result := ((wert / 10) *16) + (wert // 10) 
  return result

DAT
     '160 bytes als Hex-Werte von 0 bis dezimal 
data byte $00,$01,$02,$03,$04,$05,$06