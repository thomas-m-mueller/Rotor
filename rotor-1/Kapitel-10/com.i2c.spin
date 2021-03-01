{{
  com.i2c.spin                                      Treiber fue I2C-Kommunikation - Original mit Erweiterung
  ┌──────────────────────────────────────────┐
  │ I2C driver in SPIN                       │      This routine requires the use of pull-up resistors on the SDA and SCL lines 
  │ Author: Chris Gadd                       │      Runs entirely in SPIN
  │ Copyright (c) 2013 Chris Gadd            │      Approximately 20Kbps
  │ See end of file for terms of use.        │      Supports clock-stretching by slave devices
  └──────────────────────────────────────────┘

  PUB methods:
    I2C.start(28,29)                                Start the I2C driver using p28 for clock and p29 for data
    \I2C.write(EEPROM,$0123,$45)                    Write $45 to EEPROM address $0123 
    \I2C.write_page(EEPROM,$0123,@Array,500)        Write 500 bytes from Array to EEPROM starting at address $0123
    \I2C.command(Alt,$48)                           Issue command to 'convert D1' to a MS5607 altimeter (Altimeter is the only device, so far discovered, that needs this routine)
    \I2C.read(EEPROM,$0123)                         Read a byte from EEPROM address $0123
    \I2C.read_next(EEPROM)                          Read a byte from EEPROM address $0124 (the next address following a 'read')
    \I2C.read_page(EEPROM,$0123,@Array,500)         Read 500 bytes from an EEPROM starting at address $0123 and store each byte in Array
    \I2C.read_word(EEPROM,$0123)                    Read a big-endian word
    \I2C.read_words(EEPROM,$0123,@Array,500)        Read many big-endian words
    \I2C.arbitrary(out_bfr,out_cnt,in_bfr,in_cnt)   Writes and reads an arbitrary number of bytes from byte arrays, intended for edge-cases that don't use
                                                    register addresses or other peculularities
    └─Note the abort trap
    
    This routine performs ACK polling to determine when a device is ready.
    Routine will abort a transmission if no ACK is received within 10ms of polling - prevents I2C routine from stalling if a device becomes disconnected
     The abort trap "\" must be used by a calling method
    No other ACK testing is performed

    This routine automatically uses two bytes when addressing an EEPROM. 
    EEPROM is the only device, so far discovered, that uses two-byte addresses.
                 
'----------------------------------------------------------------------------------------------------------------------

        ┌─Start─┬─Bit 1─┬─Bit 0─┬─Ack(r)┬─Start─┬─Read──┬─Ack(t)┬─Read──┬──NAK──┬─Stop──┐         
    SCL          
    SDA ─────────────────────  
         
}}                                                                                                                                                
CON
'Device codes
  EEPROM = %0101_0000           ' Device code for 24LC256 EEPROM with all chip select pins tied to ground
  RTC    = %0110_1000           ' Device code for DS1307 real time clock
  LCD    = %0111_1110
  Acc    = %0001_1101           ' Device code for MMA7455L 3-axis accelerometer
  Gyro   = %0110_1001           ' Device code for L3G4200D gyroscope (SDO to Vdd)
  Alt    = %0111_0110           ' Device code for MS5607 altimeter (CS floating)
  Compass= %0001_1110           ' HMC5883L compass
  
  IO     = %0010_0001           ' Device code for CY8C9520A IO port expander (Strong pull-up (330Ω or less on A0))
        ' Pull-up required when using the CY8C9520A EEPROM device, addressed at 101_000a
  MPU    = %0110_1000
  BMP    = %0111_0111           ' Device code for the BMP085 pressure sensor                                   

  ACK    = 0 
  NACK   = 1     
                                    
VAR
  byte  scl,sda       

PUB start(scl_pin,sda_pin) | i
  scl := scl_pin
  sda := sda_pin

  i := 0

  repeat until ina[sda] or i == 20                      ' It's possible that a slave device might be holding SDA low 
    !dira[scl]                                          '  as an ACK.
    i++                                                 ' This attempts to clock the data line high, gives up after 10 clocks
  dira[scl] := 0                                                                  
  
PRI send_start (device, address) | NAK, t

  nak := 1
  t := cnt                                              ' t is used to detect a timeout

  repeat while nak                                      ' Perform ack-polling                                     
    if cnt - t > clkfreq / 100                          ' Check timeout
      abort false                                       ' abort after 10ms if no ack is received 
    I2C_start                                           ' Send start bit and device ID                                                                                                                   
    nak := I2C_write(device << 1)                       ' I2C_write method returns true if nak
' if device & %1111_1000 == EEPROM                      ' This interferes with the ADXL345 alternate address of $53                                              
  if device == EEPROM                                              
    I2C_write(address >> 8)                             ' Send two register bytes if addressing an EEPROM at address $50 only
  I2C_write(address)  
  
PUB I2C_start                                           ' SCL 
  dira[scl] := 0                                        ' SDA 
  waitpeq(|<SCL,|<SCL,0)                                ' wait for clock-stretching    
  dira[sda] := 0                                                          
  dira[sda] := 1
  dira[scl] := 1

PUB I2C_write(data)                                     '   (Write)      (Read ACK or NAK)
                                                        '                      
  data := (data ^ $FF)<< 24                             ' SCL    
  repeat 8                                              ' SDA  ───────            
    dira[sda] := data <-= 1                                                     
    dira[scl] := 0                                                                                                 
    waitpeq(|<SCL,|<SCL,0)                              ' wait for clock-stretching    
    dira[scl] := 1

  dira[sda] := 0
  dira[scl] := 0
  waitpeq(|<SCL,|<SCL,0)                                ' wait for clock-stretching
  result := ina[sda]                                    ' result is true if NAK
  dira[scl] := 1
  

PUB write(device,address,data)                          ' Write a single byte

  send_start(device,address)                            ' Send a start bit, device ID, and register address
  I2C_write(data)                                       ' Send the data byte
  I2C_stop                                              ' Send a stop bit
  result := true
  
PUB write_page(device,address,data_address,bytes)       ' Write many bytes

  send_start(device,address)                            ' Send a start bit, device ID, and register address    
  repeat bytes                                                                                                                         
    I2C_write(byte[data_address])                       ' Send the data byte from an array                     
    data_address++                                                             
  I2C_stop                                              ' Send a stop bit 
  result := true

PUB command(device,comm)                                ' Write the device and address, no data.  Used in the altimeter

  send_start(device,comm)                               ' Send a start bit, device ID, and command
  I2C_stop                                              ' Send a stop bit
  result := true
                                                            
PUB read(device,address)                                ' Read a single byte

  send_start(device,address)                            ' Send a start bit, device ID, and register address  
  I2C_start                                             ' Send a restart
  I2C_write(device << 1 | 1)                            ' Send the device ID with the read bit set
  result := I2C_read                                    ' Read a byte into the result
  I2C_nak                                               ' Send a NAK bit
  I2C_stop                                              ' Send a stop bit

PUB read_next(device)                                   ' Read from next address

  I2C_start                                             ' Send a start bit
  I2C_write(device << 1 | 1)                            ' Send the device ID with the read bit set
  result := I2C_read                                    ' Read a byte into the result 
  I2C_nak                                               ' Send a NAK bit              
  I2C_stop                                              ' Send a stop bit             

PUB read_page(device,address,data_address,bytes)        ' Read many bytes

  send_start(device,address)                            ' Send a start bit, device ID, and register address
  I2C_start                                             ' Send a restart                                      
  I2C_write(device << 1 | 1)                            ' Send the device ID with the read bit set            
  repeat bytes                                                                                                                        
    byte[data_address] := I2C_read                      ' Read a byte into an array
    if bytes-- > 1                                                                                                                    
      I2C_ack                                           ' Send an ACK bit if more bytes are to be read
    else
      I2C_nak                                           ' Otherwise, send a NAK bit
    data_address++                                                              
  I2C_stop                                              ' Send a stop bit
  result := true

PUB read_word(device,address)                           ' Read a single word - written specifically for devices that store readings as high_byte,low_byte ($01,$23)

  send_start(device,address)                            ' Send a start bit, device ID, and register address        
  I2C_start                                             ' Send a restart                                           
  I2C_write(device << 1 | 1)                            ' Send the device ID with the read bit set                 
  result := I2C_read << 8                               ' Read a byte and store in the hi-byte of a word
  I2C_ack                                               ' Send an ACK bit to advance the slave to the low-byte     
  result |= I2C_read                                    ' Read a byte and store in the low-byte of a word          
  I2C_nak                                               ' Send a NAK bit                                
  I2C_stop                                              ' Send a stop bit                                     

PUB read_words(device,address,data_address,words)       ' Read many words - written specifically for devices that store readings as high_byte,low_byte   ($01,$23)
                                                        '  If read into an array using the read_page method, the byte order would be reversed when trying to operate on the word ($2301)
  send_start(device,address)                            ' Send a start bit, device ID, and register address        
  I2C_start                                             ' Send a restart                                           
  I2C_write(device << 1 | 1)                            ' Send the device ID with the read bit set                 
  repeat words                                                                                                                             
    word[data_address] := I2C_read << 8                 ' Read a byte and store in the hi-byte of a word
    I2C_ack                                             ' Send an ACK bit to advance the slave to the low-byte     
    word[data_address] := word[data_address] | I2C_read ' Read a byte and store in the low-byte of a word          
    if words-- > 1                                                                                                                         
      I2C_ack                                           ' Send an ACK bit if more bytes are to be read             
    else                                                                                                                                   
      I2C_nak                                           ' Otherwise, send a NAK bit                                
    data_address += 2                                                                                                                 
  I2C_stop                                              ' Send a stop bit                                     
  dira[sda]~
  result := true      

PUB arbitrary(out_address,out_count,in_address,in_count)' Sends bytes exactly as they're entered into the out_address array
                                                        '  If sending a device address, it must be shifted to 8 bits and a 
  I2C_start                                             '  read/write bit appended
  repeat out_count                                      ' out_address and in_address can point to the same array  
    I2C_write(byte[out_address++])                      '  if using a local array, keep in mind that local variables are longs
  repeat in_count                                       '                                                               
    byte[in_address++] := I2C_read                      ' pub example | i, locals[2]
    if in_count-- > 1                                   '  locals.byte[0] := device << 1 | 1    ' send 7-bit device address with read bit                                                       
      I2C_ack                                           '  arbitrary(@locals,1,@locals,5)       ' write one byte, read five bytes        
    else                                                '  repeat i from 0 to 4                 '          
      I2C_nak                                           '    fds.hex(locals.byte[i],2)          ' display 5 bytes
  I2C_stop                                              '    fds.tx(" ")
  result := true    
             

PUB I2C_wait(device) | ackbit

'' Wartet auf I2C-Addressat
  repeat
    I2C_start
    ackbit := I2C_write(device & $FE)
  until (ackbit == ACK)


PUB I2C_read                                            '      (Read)  
  dira[sda] := 0                                        '             
  repeat 8                                              ' SCL  
    dira[scl] := 0                                      ' SDA ───────
    waitpeq(|<SCL,|<SCL,0)
    result := result << 1 | ina[sda]                    ' return the read byte as result
    dira[scl] := 1
    
PUB I2C_ack                                             ' SCL           
  dira[sda] := 1                                        ' SDA 
  dira[scl] := 0
  waitpeq(|<SCL,|<SCL,0)
  dira[scl] := 1

PUB I2C_nak                                             ' SCL 
  dira[sda] := 0                                        ' SDA 
  dira[scl] := 0
  waitpeq(|<SCL,|<SCL,0)
  dira[scl] := 1

PUB I2C_stop                                            ' SCL 
  dira[sda] := 1                                        ' SDA 
  dira[scl] := 0
  waitpeq(|<SCL,|<SCL,0)
  dira[sda] := 0
        
PUB devicePresent(device) : ackbit
  ' send the deviceAddress and listen for the ACK
   I2C_start
   ackbit := I2C_write(device)
   I2C_stop
   if ackbit == ACK
     return true
   else
     return false                                                                                
DAT
{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   TERMS OF USE: MIT License                                                  │                                                            
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │ 
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
│is furnished to do so, subject to the following conditions:                                                                   │
│                                                                                                                              │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
│                                                                                                                              │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}