'                 I2C002.spin
'                 I2C-Protokoll - 2. EEPROM Demo Version 1
'                 SCHREIBEN mehrerer Bytes 
'                 Umsetzung des HI-Z TriStates in Subroutinen
'
CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
  SCL = 28                ' Pin fuer Takt-Leitung (Clock)
  SDA = 29                ' Pin fuer Datenleitung
  ACK = 0                 ' Alles ok
  NACK = 1                ' Fehlersignal  
                          ' 87654321-Bit   
  I2C_EPROM = %1010_0000  '  1010000
                          ' 7 bittige Nummer des EEPROMs
                          ' + Schreiben-Bit
  EEAddress = $8000       'obere  32K
  
  
OBJ
  term : "com.serial.terminal"
  
VAR
  byte outpin
  byte ackbit
  byte HighAdress
  byte LowAdress
  byte block
  byte idx 
  byte count
  byte cx
    
PUB main
  term.start(115200)
  term.str(string("    ** EEPROM - Block-Schreib-Routiene", 13))
  term.str(string("    ** EEPROM - Adress-Highbyte: "))
  HighAdress := EEAddress >> 8 & $FF
  term.Hex ( HighAdress, 4)
  term.NewLine
  term.str(string("    ** EEPROM - Adress-Lowbyte:  "))
  LowAdress  := EEAddress & $FF
  term.Hex ( LowAdress, 4)
  term.NewLine
  block := 128 ' max 128 byte pro Schreibvorgang
  Start
  Write(I2C_EPROM)
  Write(HighAdress)
  Write(LowAdress)
  term.NewLine
  term.str(string("          *** DATA Block Write *** ", 13))
  term.str(string("                 ")) 
  term.Dec (block)
  term.str(string(" mal",13))
  idx := 16
  term.str(string("          *** DATA -> EEPROM  *** ", 13))
  ' term.Dec (EEAddress + idx)
  ' term.str(string(" | "))
  repeat block
    Write(data[idx])
    term.str(string(" $"))
    term.Hex (data[idx], 2)
    term.str(string(" "))
    idx++
  term.NewLine 
  Stop

  idx := 0
  term.NewLine
  
 
 
PUB Start                 ' SDA goes HIGH to LOW with SCL HIGH
   term.NewLine
   term.NewLine
   term.str(string("          *** START *** ", 13))
   OUTA[SCL] := 1                         ' Initially drive SCL HIGH
   ' term.str(string("CLOCK-HIGH - "))
   DIRA[SCL] := 1
   OUTA[SDA] := 1                         ' Initially drive SDA HIGH
   ' term.str(string("DATA-HIGH [1] "))                                    ' 
   DIRA[SDA] := 1
   OUTA[SDA] := 0                          ' Now drive SDA LOW
   ' term.str(string("DATA-LOW  [0] ",13))
   OUTA[SCL] := 0                          ' Leave SCL LOW
   ' term.str(string("CLOCK-LOW - "))
     
PUB Write(data1) : ackbit1
  
   ackbit1 := 0 
   data1 <<= 24
   repeat 8                            ' Output data to SDA
      outa[SDA] := (data1 <-= 1) & 1
      if (data1 & 1)
       ' term.str(string("[1] "))
      else
       ' term.str(string("[0] "))
      OUTA[SCL] := 1                      ' Toggle SCL from LOW to HIGH to LOW
      ' term.str(string("CLOCK-HIGH ", 13))
      OUTA[SCL] := 0
      ' term.str(string("CLOCK-LOW - "))
   DIRA[SDA] := 0                          ' Set SDA to input for ACK/NAK
'   term.NewLine
   OUTA[SCL] := 1
   ' term.str(string("              - CLOCK-HIGH ", 13))
                    ' Sample SDA when SCL is HIGH
   ' term.str(string("DATA <- IN: " ))
   if (ina[SDA] == 0 )
     ' term.str(string("EEPROM: ACK ! ", 13))
     ackbit1 := 0
   else 
     ackbit1 := 1
   OUTA[SCL] := 0
   ' term.str(string("CLOCK-LOW - "))
   OUTA[SDA] := 0                          ' Leave SDA driven LOW
   ' term.str(string("DATA-LOW  [0] "))
   DIRA[SDA] := 1

PUB Read(ackbit1): data1
 '  term.NewLine
 '  term.NewLine
 '  term.str(string("          *** DATA READ *** ", 13))
 '  term.str(string("             ")) 
   data1 := 0
   DIRA[SDA] := 0                          ' Make SDA an input
   ' term.str(string("DATA-LOW  [0]", 13))                                   ' 
   repeat 8                            ' Receive data from SDA
      OUTA[SCL] := 1                      ' Sample SDA when SCL is HIGH
     ' term.str(string("CLOCK-HIGH - "))
      if (ina[SDA])
       ' term.str(string("EEPROM:DATA-HIGH [1] - "))
      else
       ' term.str(string("EEPROM:DATA-LOW  [0] - "))                                 ' 
      data1 := (data1 << 1) | ina[SDA]
     ' term.Dec (data1)
     ' term.NewLine
      OUTA[SCL] := 0
     ' term.str(string("CLOCK-LOW ",13))
   outa[SDA] := ackbit1                 ' Output ACK/NAK to SDA
 '  term.str(string("NACK->OUT! - "))                                     '
   DIRA[SDA] := 1
   'term.str(string("DATA-HIGH [1] - "))
   OUTA[SCL] := 1                              'Toggle SCL from LOW to HIGH to LOW
   'term.str(string("CLOCK-HIGH ", 13))        
   OUTA[SCL] := 0
  ' term.str(string("CLOCK-LOW  - "))
   OUTA[SDA] := 0                          ' Leave SDA driven LOW
  ' term.str(string("DATA-LOW  [0]"))
   
PUB Stop
   term.NewLine
   term.NewLine
   term.str(string("          *** STOP ***", 13))
   OUTA[SCL] := 1                         ' Drive SCL HIGH
   ' term.str(string("CLOCK-HIGH - "))
   OUTA[SDA] := 1                         '  then SDA HIGH
   ' term.str(string("DATA-HIGH [1] - "))
   DIRA[SCL] := 0                          ' Now let them float
   ' term.str(string("CLOCK-LOW ",13))
   DIRA[SDA] := 0                          ' If pullups present, they'll stay HIGH
   ' term.str(string("DATA-LOW  [0] ",13))
    
PUB devicePresent(deviceAddress) : ackbit1
  ' send the deviceAddress and listen for the ACK
   Start
   ackbit1 := Write(deviceAddress | 0)
   Stop
   if ackbit1 == ACK
     return true
   else
     return false 
   
   
DAT
     '160 bytes als Hex-Werte von 0 bis dezimal 159
data byte $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F
     byte $10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1A,$1B,$1C,$1D,$1E,$1F
     byte $20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$2A,$2B,$2C,$2D,$2E,$2F
     byte $30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$3A,$3B,$3C,$3D,$3E,$3F  
     byte $40,$41,$42,$43,$44,$45,$46,$47,$48,$49,$4A,$4B,$4C,$4D,$4E,$4F
     byte $50,$51,$52,$53,$54,$55,$56,$57,$58,$59,$5A,$5B,$5C,$5D,$5E,$5F
     byte $60,$61,$62,$63,$64,$65,$66,$67,$68,$69,$6A,$6B,$6C,$6D,$6E,$6F
     byte $70,$71,$72,$73,$74,$75,$76,$77,$78,$79,$7A,$7B,$7C,$7D,$7E,$7F
     byte $80,$81,$82,$83,$84,$85,$86,$87,$88,$89,$8A,$8B,$8C,$8D,$8E,$8F  
     byte $90,$91,$92,$93,$94,$95,$96,$97,$98,$99,$9A,$9B,$9C,$9D,$9E,$9F  