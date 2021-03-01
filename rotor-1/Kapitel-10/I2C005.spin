'                 I2C005.spin
'                 I2C-Protokoll - Suche nach i2C-Busteilnehmern
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
  I2C_EPROM = %0001_111  '  1010000
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
  long block
  long idx 
  byte count
  long cx
    
PUB main
  term.start(115200)
  term.str(string("    ** I2C-Suchroutine", 13))

  term.NewLine
  block := 127 ' max 128 byte pro Schreibvorgang
  idx := 1
  repeat idx from 1 to block 
     Start
     cx := idx << 1 | 0
     Write(cx)
     Stop
     waitcnt(clkfreq/4 + cnt)
     
  term.NewLine
  term.str(string("    ** Suche beendet", 13))
 
PUB Start                 ' SDA goes HIGH to LOW with SCL HIGH

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
   
   if (ina[SDA] == 0 )
     term.str(string("WRITE ! *** " ))
     term.Hex (data1, 4)
     term.NewLine
     term.Bin (data1, 8)
     term.NewLine
     term.str(string("DATA <- IN: " ))
     term.str(string("Antwort: ACK ! ", 13))
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
   
