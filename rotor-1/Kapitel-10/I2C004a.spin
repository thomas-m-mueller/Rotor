'                 I2C004a.spin
'                 I2C-Protokoll - 4. RTC - Real Time Clock DS-1307 Demo Version 1
'                 SRAM SCHREIBEN
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
  term.str(string("    ** Start-Adresse: $08"))
  term.NewLine
  term.str(string("    *** SRAM wird geschrieben. "))

  Start
  Write(I2C_RTC) 
  Write($08)                 ' 
   repeat 56
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
     '160 bytes als Hex-Werte von 0 bis dezimal 159
data byte $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F
     byte $10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1A,$1B,$1C,$1D,$1E,$1F
     byte $20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$2A,$2B,$2C,$2D,$2E,$2F
     byte $30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$3A,$3B,$3C,$3D,$3E,$3F  
     byte $40,$41,$42,$43,$44,$45,$46,$47,$48,$49,$4A,$4B,$4C,$4D,$4E,$4F
     byte $50,$51,$52,$53,$54,$55,$56,$57,$58,$59,$5A,$5B,$5C,$5D,$5E,$5F