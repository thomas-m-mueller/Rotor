'                 I2C001.spin
'                 I2C-Protokoll - 1. EEPROM Demo Version 1
'                 LESEN mehrerer Bytes 
'                 Umsetzung des HI-Z TriStates in Subroutinen
CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
  SCL = 28                ' Pin fuer Takt-Leitung (Clock)
  SDA = 29                ' Pin fuer Datenleitung
  ACK = 0                 ' Alles ok
  NACK = 1                ' Fehlersignal, Break
                          ' 87654321-Stelle im Byte   
  I2C_EPROM = %1010_0000  '  1010000 + RW
                          ' 7 bittige Nummer des EEPROMs
                          ' + Schreiben-Bit
  EEAddress = $8000       ' obere 32K im Speicher des EEPROMs
  
  
OBJ
  term : "com.serial.terminal"
  
VAR
  byte data[257]
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
  term.str(string("    ** EEPROM - Block-Lesen", 13))
  term.str(string("    ** EEPROM - Adress-Highbyte: $"))
  HighAdress := EEAddress >> 8 & $FF
  term.Hex ( HighAdress, 2)
  term.NewLine
  term.str(string("    ** EEPROM - Adress-Lowbyte:  $"))
  LowAdress  := EEAddress & $FF
  term.Hex ( LowAdress, 2)
  term.NewLine
  block := 32                 ' wieviele Zeichen lesen ?
  Start
  Write(I2C_EPROM)
  Write(HighAdress)
  Write(LowAdress)
  Start
  Write(I2C_EPROM + 1)
  term.str(string("    *** DATA READ *** ", 13))
  term.str(string("      ")) 
  term.Dec (block)
  term.str(string("->"))                                   
  repeat block - 1                 ' bis auf einmal mit ACK
     data[idx++] := Read(ACK)      ' bestaetigen
  data[idx++] := Read(NACK)        ' NACK als Signal
                                   ' dass Lesevorgang zu Ende ist
  term.str(string(" Mal",13))
  Stop
  Hexmonitor                        'Anzeige des gelesenen Inhalts


 
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

PUB Hexmonitor

  term.NewLine 
  term.Str(string(" "))
  repeat cx from 1 to 65
        term.Str(string("="))
  term.NewLine
  term.str(string(" II  POS  |            HEX-WERTE                     |  ASCII   II", 13))
  term.Str(string(" "))
  repeat cx from 1 to 65
        term.Str(string("="))
  term.NewLine
  idx := 0
  term.str(string(" II "))
  term.Dec (EEAddress + idx)
  term.str(string(" | "))
  repeat block
     if (count == 8)
       term.str(string(" | "))
       repeat cx from 8 to 1
         if (data [idx - cx] > 32) AND (data [idx - cx] < 123)
           term.Char (data [idx - cx])
         else
           term.Char (".")
       term.str(string(" II "))
       term.NewLine
       count := 0 
       term.str(string(" II "))
       term.Dec (EEAddress  + idx)
       term.str(string(" | "))     
     term.str(string(" $"))
     term.Hex(data[idx++],2)
     term.str(string(" "))  
     count++
     if ( idx == block) 
       term.str(string(" | "))
       repeat cx from 8 to 1
         if (data [idx - cx] > 32) AND (data [idx - cx] < 123)
           term.Char (data [idx - cx])
         else
           term.Char (".")
       term.str(string(" II "))     
  term.NewLine
  term.Str(string(" "))
  repeat cx from 1 to 65
        term.Str(string("="))
  term.NewLine
  