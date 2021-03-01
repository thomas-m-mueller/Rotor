'                 I2C006.spin
'                 I2C-Protokoll - 6.LCD - Demo Version 1
'                 Initialisieren, Cursor-Steuerung, Text ausgeben
'                 Verzögerte und vereinfachte Routinen
'                 Umsetzung des HI-Z TriStates in Subroutinen
'                 
'                ---       LCD-HD44780U-Register   ---
'                     DATENLEITUNGEN:          |STEUERLEITUNGEN:
'          |                 |                 |
'          |  DB7 DB6 DB5 DB4| DB3 DB2 DB1 DB0 |BL E  RW  RS
'          |                 |                 |
'                   Mapping durch PCF8574A 
'          |                 |                 |
'          |   4-Bit-Modus   |  x   x   x   x  |BL E  RW  RS
'          |                 |                   | |   |   |
'          |                 |  v----------------+ |   |   |  Backlight 0=off, 1=on
'          |                 |      v--------------+   |   |  Enable Datenuebernahme 0->1
'          |                 |          v--------------+   |  Schreiben=0, Lesen=1 
'          |                 |              v--------------+  Registerselect 1=D-RAM, 
'          |                 |                 |                             0=Kommando
'  BEFEHL  |                 |                 |
'  8-Bit   :  0   0   1   1  |  1   X   0   0  |  unteres Nibble plus Steuerregister
'  4-Bit   :  0   0   1   0  |  1   X   0   0  |  unteres Nibble       ''
' Multi-      0   1   1   1  |  1   X   0   0  |  oberes  Nibble       ''
' Line     :  1   0   0   0  |  1   X   0   0  |  unteres Nibble       ''
'  Auto-      0   0   0   0  |  1   X   0   0  |  oberes  Nibble       ''
'Increment :  0   1   1   0  |  1   X   0   0  |  unteres Nibble       ''                                                          
'  Display,   0   0   0   0  |  1   X   0   0  |  oberes  Nibble       ''
'Cursor on :  1   1   1   0  |  1   X   0   0  |  unteres Nibble       ''  
'  Clear      0   0   0   0  |  1   X   0   0  |  unteres Nibble       '' 
'   Screen :  0   0   0   1  |  1   X   0   0  |  oberes  Nibble       ''  
'   Buch-     0   1   0   0  |  1   X   0   1  |  oberes  Nibble       ''
'stabe H   :  1   0   0   0  |  1   X   0   1  |  unteres Nibble       '' 
'

CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
  
  CLK_FREQ = ((_clkmode - xtal1) >> 6) * _xinfreq
  MS_001   = CLK_FREQ / 1_000                                   'mili-Sekunde

  SCL = 28                ' Pin fuer Takt-Leitung (Clock)
  SDA = 29                ' Pin fuer Datenleitung
  ACK = 0                 ' Alles ok
  NACK = 1                ' Fehlersignal, Break
  
  I2C_Adr = $7E           ' %0111 1110    PCF8574A-Chip
                          '  
  RS_MASK = %0000_0001
  E_MASK  = %0000_0100
  BL_MASK = %0000_1000
  
OBJ

   term : "com.serial.terminal"

VAR
  byte data_byte
  byte high_nibble
  byte low_nibble
  byte ctrlbits
  
  long ms001

PUB Main

  term.start(115200)
  
  term.Clear   
    
                                         ' Initializes LCD using 4-bit interface via PCA8574
  ms001 := clkfreq / 1_000               ' calcutate ticks/ms

  ctrlbits := %0000_1000                  ' BL-MASK - backlight on, others 0

  term.str(string("    ** LCD-INIT", 13)) 
  Pause(500)                              ' allow power-up
  term.str(string("** 8-Bit-Mode: 0000_0011 ", 13))
  high_nibble:= (%0011 << 4)       
  term.Bin (high_nibble, 8)  
  term.Str (string(8,8,8,8,"=> MSb | Steuerbits = ")) 
  term.Bin ((high_nibble | ctrlbits), 8)                                                 
  data_byte := (high_nibble & $F0) | (ctrlbits & %1001)      ' force E and RW low

  Wait(I2C_Adr)
  Write(data_byte)           
  Stop 
  Wait(I2C_Adr)                           
  Write(data_byte | E_MASK)                ' High to Low, %0000_0100
  Stop 
  Wait(I2C_Adr)                                                          ' 
  Write(data_byte)
  Stop
  Pause(500)
  
    term.str(string(13,"** 8-Bit-Mode: 0000_0011 ", 13))
  high_nibble:= (%0011 << 4)
  term.Bin (high_nibble, 8)  
  term.Str (string(8,8,8,8,"=> MSb | Steuerbits = ")) 
  term.Bin ((high_nibble | ctrlbits), 8)                                                 
  data_byte := (high_nibble & $F0) | (ctrlbits & %1001)      ' force E and RW low

  Wait(I2C_Adr)
  Write(data_byte)           
  Stop 
  Wait(I2C_Adr)                            ' setup nibble
  Write(data_byte | E_MASK)                ' High to Low, %0000_0100
  Stop 
  Wait(I2C_Adr)                                                          ' 
  Write(data_byte)
  Stop
  Pause(500)

  term.str(string(13,"** 8-Bit-Mode: 0000_0011 ", 13))
  high_nibble:= (%0011 << 4)
  term.Bin (high_nibble, 8)  
  term.Str (string(8,8,8,8,"=> MSb | Steuerbits = ")) 
  term.Bin ((high_nibble | ctrlbits), 8)                                                 
  data_byte := (high_nibble & $F0) | (ctrlbits & %1001)      ' force E and RW low

  Wait(I2C_Adr)
  Write(data_byte)           
  Stop 
  Wait(I2C_Adr)                            ' setup nibble
  Write(data_byte | E_MASK)                ' High to Low, %0000_0100
  Stop 
  Wait(I2C_Adr)                                                          ' 
  Write(data_byte)
  Stop
  Pause(500)

  
  term.str(string(13,"** 4-Bit-Mode: 0000_0010", 13))
  high_nibble:=(%0010 << 4)
  term.Bin (high_nibble, 8)  
  term.Str (string(8,8,8,8,"=> MSb | Steuerbits = ")) 
  term.Bin ((high_nibble | ctrlbits), 8)                 ' 4-bit mode 
  data_byte := (high_nibble & $F0) | (ctrlbits & %1001)
  
  Wait(I2C_Adr)
  Write(data_byte)           
  Stop 
  Wait(I2C_Adr)                            ' setup nibble
  Write(data_byte | E_MASK)                ' High to Low, %0000_0100
  Stop 
  Wait(I2C_Adr)                                                          ' 
  Write(data_byte)
  Stop
  Pause(500)
                                              ' multi-line
  ctrlbits &= !(%0000_0001)                   'RS-Mask
  term.str(string(13,"** Multiline-Mode: 0010_1000", 13)) 
  high_nibble := (%0010_1000 & $F0)
  term.Bin (high_nibble, 8)  
  term.Str (string(8,8,8,8,"=> MSb | Steuerbits = ")) 
  term.Bin ((high_nibble | ctrlbits), 8) 
  data_byte := (high_nibble & $F0) | (ctrlbits & %1001)
  
  Wait(I2C_Adr)
  Write(data_byte)           
  Stop 
  Wait(I2C_Adr)                            ' setup nibble
  Write(data_byte | E_MASK)                ' High to Low, %0000_0100
  Stop 
  Wait(I2C_Adr)                                                          ' 
  Write(data_byte)
  Stop
  Pause(500)
      
  ctrlbits &= !(%0000_0001)
  low_nibble:= ((%0010_1000  << 4) & $F0)
  term.NewLine
  term.Bin (low_nibble, 8)  
  term.Str (string(8,8,8,8,"=> LSb | Steuerbits = ")) 
  term.Bin ((low_nibble | ctrlbits), 8)
  data_byte := (low_nibble & $F0) | (ctrlbits & %1001)
  
  Wait(I2C_Adr)
  Write(data_byte)           
  Stop 
  Wait(I2C_Adr)                            ' setup nibble
  Write(data_byte | E_MASK)                ' High to Low, %0000_0100
  Stop 
  Wait(I2C_Adr)                                                          ' 
  Write(data_byte)
  Stop
  Pause(500)
   
  ctrlbits &= !(%0000_0001)                            ' RS-MASK 
  high_nibble := (%0000_0110 & $F0)                              ' auto-increment cursor
  term.str(string(13,"** Auto-Increment: 0000_0110", 13))
  term.Bin (high_nibble, 8)  
  term.Str (string(8,8,8,8,"=> MSb | Steuerbits = ")) 
  term.Bin ((high_nibble | ctrlbits), 8)
  data_byte := (high_nibble & $F0) | (ctrlbits & %1001)
  
  Wait(I2C_Adr)
  Write(data_byte)           
  Stop 
  Wait(I2C_Adr)                            ' setup nibble
  Write(data_byte | E_MASK)                ' High to Low, %0000_0100
  Stop 
  Wait(I2C_Adr)                                                          ' 
  Write(data_byte)
  Stop
  Pause(500)
  
  
  ctrlbits &= !(%0000_0001)                      ' RS-MASK
  low_nibble:= ((%0000_0110 << 4) & $F0)
  term.NewLine
  term.Bin (low_nibble, 8)  
  term.Str (string(8,8,8,8,"=> LSb | Steuerbits = ")) 
  term.Bin ((low_nibble | ctrlbits), 8)
  data_byte := (low_nibble & $F0) | (ctrlbits & %1001)
  
  Wait(I2C_Adr)
  Write(data_byte)           
  Stop 
  Wait(I2C_Adr)                            ' setup nibble
  Write(data_byte | E_MASK)                ' High to Low, %0000_0100
  Stop 
  Wait(I2C_Adr)                                                          ' 
  Write(data_byte)
  Stop
  Pause(500)
            
                                                            ' display on, no cursor
  ctrlbits &= !(%0000_0001)                               'RS-Mask
  term.str(string(13,"**  Display, Cursor on: 0000_1110", 13))
  high_nibble := (%0000_1110  & $F0)
  term.Bin (high_nibble, 8)  
  term.Str (string(8,8,8,8,"=> MSb | Steuerbits = ")) 
  term.Bin ((high_nibble | ctrlbits), 8)
  data_byte := (high_nibble & $F0) | (ctrlbits & %1001)
  
  Wait(I2C_Adr)
  Write(data_byte)           
  Stop 
  Wait(I2C_Adr)                            ' setup nibble
  Write(data_byte | E_MASK)                ' High to Low, %0000_0100
  Stop 
  Wait(I2C_Adr)                                                          ' 
  Write(data_byte)
  Stop
  Pause(500)
            
 
  low_nibble := ((%0000_1110  << 4) & $F0)
  term.NewLine
  term.Bin (low_nibble, 8)  
  term.Str (string(8,8,8,8,"=> LSb | Steuerbits = ")) 
  term.Bin ((low_nibble | ctrlbits), 8)
  data_byte := (low_nibble & $F0) | (ctrlbits & %1001)
  
  Wait(I2C_Adr)
  Write(data_byte)           
  Stop 
  Wait(I2C_Adr)                            ' setup nibble
  Write(data_byte | E_MASK)                ' High to Low, %0000_0100
  Stop 
  Wait(I2C_Adr)                                                          ' 
  Write(data_byte)
  Stop
  Pause(500)
                                                ' LCD cls
  ctrlbits &= !(%0000_0001)                     ' RS low
  term.str(string(13,"** LCD-CLS", 13))
  high_nibble := ($1 & $F0)
  term.Bin (high_nibble, 8)  
  term.Str (string(8,8,8,8,"=> MSb | Steuerbits = ")) 
  term.Bin ((high_nibble | ctrlbits), 8)
  data_byte := (high_nibble & $F0) | (ctrlbits & %1001)
  
  
  Wait(I2C_Adr)
  Write(data_byte)           
  Stop 
  Wait(I2C_Adr)                            ' setup nibble
  Write(data_byte | E_MASK)                ' High to Low, %0000_0100
  Stop 
  Wait(I2C_Adr)                                                          ' 
  Write(data_byte)
  Stop
  Pause(500)
  
    
  low_nibble := (($1 << 4) & $F0)
  term.NewLine
  term.Bin (low_nibble, 8)  
  term.Str (string(8,8,8,8,"=> LSb | Steuerbits = ")) 
  term.Bin ((low_nibble | ctrlbits), 8)
  data_byte := (low_nibble & $F0) | (ctrlbits & %1001)
  
  
  Wait(I2C_Adr)
  Write(data_byte)           
  Stop 
  Wait(I2C_Adr)                            ' setup nibble
  Write(data_byte | E_MASK)                ' High to Low, %0000_0100
  Stop 
  Wait(I2C_Adr)                                                          ' 
  Write(data_byte)
  Stop
  Pause(500)
  
                                                ' Char out
  ctrlbits |= (%0000_0001)                      ' RS high
  term.str(string(13,"** Buchstabe H: 0100 1000", 13))
  high_nibble := ($48 & $F0)
  term.Bin (high_nibble , 8)  
  term.Str (string(8,8,8,8,"=> MSb | Steuerbits = ")) 
  term.Bin ((high_nibble | ctrlbits), 8)
  data_byte := (high_nibble & $F0) | (ctrlbits & %1001)
  
  Wait(I2C_Adr)
  Write(data_byte)           
  Stop 
  Wait(I2C_Adr)                            ' setup nibble
  Write(data_byte | E_MASK)                ' High to Low, %0000_0100
  Stop 
  Wait(I2C_Adr)                                                          ' 
  Write(data_byte)
  Stop
  Pause(500)
    
  low_nibble:= (($48 << 4) & $F0)
  term.NewLine
  term.Bin (low_nibble, 8)  
  term.Str (string(8,8,8,8,"=> LSb | Steuerbits = ")) 
  term.Bin ((low_nibble | ctrlbits), 8)
  data_byte := (low_nibble & $F0) | (ctrlbits & %1001)
  
  Wait(I2C_Adr)
  Write(data_byte)           
  Stop 
  Wait(I2C_Adr)                            ' setup nibble
  Write(data_byte | E_MASK)                ' High to Low, %0000_0100
  Stop 
  Wait(I2C_Adr)                                                          ' 
  Write(data_byte)
  Stop
  Pause(500)
                                                             ' Char out
  ctrlbits |= (%0000_0001)                                  ' RS high
  term.str(string(13,"** Buchstabe i: 0110 1001", 13))
  high_nibble := ($69 & $F0)
  term.Bin (high_nibble, 8)  
  term.Str (string(8,8,8,8,"=> MSb | Steuerbits = ")) 
  term.Bin ((high_nibble | ctrlbits), 8)
  data_byte := (high_nibble & $F0) | (ctrlbits & %1001)
  
  Wait(I2C_Adr)
  Write(data_byte)           
  Stop 
  Wait(I2C_Adr)                            ' setup nibble
  Write(data_byte | E_MASK)                ' High to Low, %0000_0100
  Stop 
  Wait(I2C_Adr)                                                          ' 
  Write(data_byte)
  Stop
  Pause(500)
  
    
  low_nibble := (($69 << 4) & $F0)
  term.NewLine
  term.Bin (low_nibble, 8)  
  term.Str (string(8,8,8,8,"=> LSb | Steuerbits = ")) 
  term.Bin ((low_nibble | ctrlbits), 8)
  data_byte := (low_nibble & $F0) | (ctrlbits & %1001)
  
  Wait(I2C_Adr)
  Write(data_byte)           
  Stop 
  Wait(I2C_Adr)                            ' setup nibble
  Write(data_byte | E_MASK)                ' High to Low, %0000_0100
  Stop 
  Wait(I2C_Adr)                                                          ' 
  Write(data_byte)
  Stop
  Pause(500)
                                           'loger look
  Pause(5000)

  ctrlbits &= !BL_MASK                       ' bachlight false
  ctrlbits &= !RS_MASK                       ' RS low
  high_nibble := 0
  data_byte := (high_nibble & $F0) | (ctrlbits & %1001)
  term.str(string(13,"** Backlight OFF", 13))
  
  Wait(I2C_Adr)
  Write(data_byte)           
  Stop 
  Wait(I2C_Adr)                            ' setup nibble
  Write(data_byte | E_MASK)                ' High to Low, %0000_0100
  Stop 
  Wait(I2C_Adr)                                                          ' 
  Write(data_byte)
  Stop
  Pause(500)
 
  low_nibble := ((0 << 4) & $F0)
  data_byte := (low_nibble & $F0) | (ctrlbits & %1001)
    
  Wait(I2C_Adr)
  Write(data_byte)           
  Stop 
  Wait(I2C_Adr)                            ' setup nibble
  Write(data_byte | E_MASK)                ' High to Low, %0000_0100
  Stop 
  Wait(I2C_Adr)                                                          ' 
  Write(data_byte)
  Stop
  Pause(500)
 
 
  
Pub Pause(ms) | t
                                     '' Delay program in milliseconds
  if (ms < 1)                         ' delay must be > 0
    return  
  else
    t := cnt - 1776                   ' sync with system counter
    repeat ms                         ' run delay
      waitcnt(t += MS_001)
    
PUB Start                                                  
   dira[SCL] := 0                   ' SCL High
   dira[SDA] := 0                   ' SDA High                                  
   dira[SDA] := 1   
   outa[SDA] := 0                   ' SDA Low
   dira[SCL] := 1                                            ' 
   outa[SCL] := 0                   ' SCL Low


PUB Write(data1) : ackbit1
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
   if (ina[SDA] == 0 )
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
   outa[SDA] := ackbit1             ' ACK als Empfangsbestaetigung                                  '
   dira[SDA] := 1
   dira[SCL] := 0
   dira[SCL] := 1                   ' SCL von Low zu High zu Low       
   outa[SCL] := 0
   dira[SDA] := 1
   outa[SDA] := 0                   ' SDA auf LOW belassen 


PUB Wait(id) | ackbit

'' Wartet auf I2C-Addressat
  repeat
    Start
    ackbit := write(id & $FE)
  until (ackbit == ACK)
 
   
PUB Stop
   dira[SCL] := 0                   ' SCL auf High
   dira[SDA] := 0                   ' SDA auf High
                                    ' und so belassen
  
        
DAT

{{

  Terms of Use: MIT License

  Permission is hereby granted, free of charge, to any person obtaining a copy of this
  software and associated documentation files (the "Software"), to deal in the Software
  without restriction, including without limitation the rights to use, copy, modify,
  merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
  permit persons to whom the Software is furnished to do so, subject to the following
  conditions:

  The above copyright notice and this permission notice shall be included in all copies
  or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
  PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
  CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
  OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.



INSTRUCTION SET
   ┌──────────────────────┬───┬───┬─────┬───┬───┬───┬───┬───┬───┬───┬───┬─────┬─────────────────────────────────────────────────────────────────────┐
   │  INSTRUCTION         │R/S│R/W│     │DB7│DB6│DB5│DB4│DB3│DB2│DB1│DB0│     │ Description                                                         │
   ├──────────────────────┼───┼───┼─────┼───┼───┼───┼───┼───┼───┼───┼───┼─────┼─────────────────────────────────────────────────────────────────────┤
   │ CLEAR DISPLAY        │ 0 │ 0 │     │ 0 │ 0 │ 0 │ 0 │ 0 │ 0 │ 0 │ 1 │     │ Clears display and returns cursor to the home position (address 0). │
   │                      │   │   │     │   │   │   │   │   │   │   │   │     │                                                                     │
   │ CURSOR HOME          │ 0 │ 0 │     │ 0 │ 0 │ 0 │ 0 │ 0 │ 0 │ 1 │ * │     │ Returns cursor to home position (address 0). Also returns display   │
   │                      │   │   │     │   │   │   │   │   │   │   │   │     │ being shifted to the original position.                             │
   │                      │   │   │     │   │   │   │   │   │   │   │   │     │                                                                     │
   │ ENTRY MODE SET       │ 0 │ 0 │     │ 0 │ 0 │ 0 │ 0 │ 0 │ 1 │I/D│ S │     │ Sets cursor move direction (I/D), specifies to shift the display(S) │
   │                      │   │   │     │   │   │   │   │   │   │   │   │     │ These operations are performed during data read/write.              │
   │                      │   │   │     │   │   │   │   │   │   │   │   │     │                                                                     │
   │ DISPLAY ON/OFF       │ 0 │ 0 │     │ 0 │ 0 │ 0 │ 0 │ 1 │ D │ C │ B │     │ Sets On/Off of all display (D), cursor On/Off (C) and blink of      │
   │ CONTROL              │   │   │     │   │   │   │   │   │   │   │   │     │ cursor position character (B).                                      │
   │                      │   │   │     │   │   │   │   │   │   │   │   │     │                                                                     │
   │ CURSOR/DISPLAY       │ 0 │ 0 │     │ 0 │ 0 │ 0 │ 1 │S/C│R/L│ * │ * │     │ Sets cursor-move or display-shift (S/C), shift direction (R/L).     │
   │ SHIFT                │   │   │     │   │   │   │   │   │   │   │   │     │                                                                     │
   │                      │   │   │     │   │   │   │   │   │   │   │   │     │                                                                     │
   │ FUNCTION SET         │ 0 │ 0 │     │ 0 │ 0 │ 1 │ DL│ N │ F │ * │ * │     │ Sets interface data length (DL), number of display line (N) and     │
   │                      │   │   │     │   │   │   │   │   │   │   │   │     │ character font(F).                                                  │
   │                      │   │   │     │   │   │   │   │   │   │   │   │     │                                                                     │
   │ SET CGRAM ADDRESS    │ 0 │ 0 │     │ 0 │ 1 │      CGRAM ADDRESS    │     │ Sets the CGRAM address. CGRAM data is sent and received after       │
   │                      │   │   │     │   │   │   │   │   │   │   │   │     │ this setting.                                                       │
   │                      │   │   │     │   │   │   │   │   │   │   │   │     │                                                                     │
   │ SET DDRAM ADDRESS    │ 0 │ 0 │     │ 1 │       DDRAM ADDRESS       │     │ Sets the DDRAM address. DDRAM data is sent and received after       │                                                             
   │                      │   │   │     │   │   │   │   │   │   │   │   │     │ this setting.                                                       │
   │                      │   │   │     │   │   │   │   │   │   │   │   │     │                                                                     │
   │ READ BUSY FLAG AND   │ 0 │ 1 │     │ BF│    CGRAM/DDRAM ADDRESS    │     │ Reads Busy-flag (BF) indicating internal operation is being         │
   │ ADDRESS COUNTER      │   │   │     │   │   │   │   │   │   │   │   │     │ performed and reads CGRAM or DDRAM address counter contents.        │
   │                      │   │   │     │   │   │   │   │   │   │   │   │     │                                                                     │
   │ WRITE TO CGRAM OR    │ 1 │ 0 │     │         WRITE DATA            │     │ Writes data to CGRAM or DDRAM.                                      │
   │ DDRAM                │   │   │     │   │   │   │   │   │   │   │   │     │                                                                     │
   │                      │   │   │     │   │   │   │   │   │   │   │   │     │                                                                     │
   │ READ FROM CGRAM OR   │ 1 │ 1 │     │          READ DATA            │     │ Reads data from CGRAM or DDRAM.                                     │
   │ DDRAM                │   │   │     │   │   │   │   │   │   │   │   │     │                                                                     │
   │                      │   │   │     │   │   │   │   │   │   │   │   │     │                                                                     │
   └──────────────────────┴───┴───┴─────┴───┴───┴───┴───┴───┴───┴───┴───┴─────┴─────────────────────────────────────────────────────────────────────┘
   Remarks :
            * = 0 OR 1
        DDRAM = Display Data Ram
                Corresponds to cursor position                  
        CGRAM = Character Generator Ram        

   ┌──────────┬──────────────────────────────────────────────────────────────────────┐
   │ BIT NAME │                          SETTING STATUS                              │                                                              
   ├──────────┼─────────────────────────────────┬────────────────────────────────────┤
   │  I/D     │ 0 = Decrement cursor position   │ 1 = Increment cursor position      │
   │  S       │ 0 = No display shift            │ 1 = Display shift                  │
   │  D       │ 0 = Display off                 │ 1 = Display on                     │
   │  C       │ 0 = Cursor off                  │ 1 = Cursor on                      │
   │  B       │ 0 = Cursor blink off            │ 1 = Cursor blink on                │
   │  S/C     │ 0 = Move cursor                 │ 1 = Shift display                  │
   │  R/L     │ 0 = Shift left                  │ 1 = Shift right                    │
   │  DL      │ 0 = 4-bit interface             │ 1 = 8-bit interface                │
   │  N       │ 0 = 1/8 or 1/11 Duty (1 line)   │ 1 = 1/16 Duty (2 lines)            │
   │  F       │ 0 = 5x7 dots                    │ 1 = 5x10 dots                      │
   │  BF      │ 0 = Can accept instruction      │ 1 = Internal operation in progress │
   └──────────┴─────────────────────────────────┴────────────────────────────────────┘

   DDRAM ADDRESS USAGE FOR A 1-LINE DISPLAY
   
    00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39   <- CHARACTER POSITION
   ┌──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┐
   │00│01│02│03│04│05│06│07│08│09│0A│0B│0C│0D│0E│0F│10│11│12│13│14│15│16│17│18│19│1A│1B│1C│1D│1E│1F│20│21│22│23│24│25│26│27│  <- ROW0 DDRAM ADDRESS
   └──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┘

   DDRAM ADDRESS USAGE FOR A 2-LINE DISPLAY

    00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39   <- CHARACTER POSITION
   ┌──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┐
   │00│01│02│03│04│05│06│07│08│09│0A│0B│0C│0D│0E│0F│10│11│12│13│14│15│16│17│18│19│1A│1B│1C│1D│1E│1F│20│21│22│23│24│25│26│27│  <- ROW0 DDRAM ADDRESS
   │40│41│42│43│44│45│46│47│48│49│4A│4B│4C│4D│4E│4F│50│51│52│53│54│55│56│57│58│59│5A│5B│5C│5D│5E│5F│60│61│62│63│64│65│66│67│  <- ROW1 DDRAM ADDRESS
   └──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┘

   DDRAM ADDRESS USAGE FOR A 4-LINE DISPLAY

    00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19   <- CHARACTER POSITION
   ┌──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┐
   │00│01│02│03│04│05│06│07│08│09│0A│0B│0C│0D│0E│0F│10│11│12│13│  <- ROW0 DDRAM ADDRESS
   │40│41│42│43│44│45│46│47│48│49│4A│4B│4C│4D│4E│4F│50│51│52│53│  <- ROW1 DDRAM ADDRESS
   │14│15│16│17│18│19│1A│1B│1C│1D│1E│1F│20│21│22│23│24│25│26│27│  <- ROW2 DDRAM ADDRESS
   │54│55│56│57│58│59│5A│5B│5C│5D│5E│5F│60│61│62│63│64│65│66│67│  <- ROW3 DDRAM ADDRESS
   └──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┘
  

}}  