'                 I2C008.spin
'                 I2C-Protokoll - 8.Startprogramm Version 1
'                 Ausgabe von Hallo und Uhrzeit
'                 unter Verwendung von Standard-Bibliotheken
'                 Umsetzung des HI-Z TriStates in Subroutinen

CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000                     ' use 5MHz crystal
  CLK_FREQ = ((_clkmode - xtal1) >> 6) * _xinfreq
  MS_001   = CLK_FREQ / 1_000              '  mili-Sekunde
  US_001   = CLK_FREQ / 1_000_000          '  micro-Sekunde

  SDA     = 29                                                
  SCL     = 28

  EEPROM_Addresse = $A0                 ' $50 + Schreiben-Bit (0)
  LCD_Addresse = $7E                    ' $3F + Schreiben-Bit (0)
  RTC_Addresse = $D0                    ' $68 + Schreiben-Bit (0)                               ' 
  LCD_WIDTH    = 16 
  
  LED_Pin = 13                          ' Blinkede LED
  
OBJ

  lcd :  "display.lcd.i2c"
  bus:   "com.i2c"
 

VAR
byte lcd_ok
byte rtc_ok
byte Sekunden
byte Minuten
byte Stunden
byte data[8]
byte idx
byte block

PUB Main 

Blink(LED_Pin, 2)                        ' Propeller startet

bus.start (SCL,SDA)
if bus.devicePresent(LCD_Addresse)       ' LCD da ?
   lcd.start(SCL, SDA, LCD_Addresse)        
   lcd.backlight(false)
   lcd_ok := 1
if bus.devicePresent(RTC_Addresse)       ' RTC da ?
   Blink(LED_Pin, 2)
   Uhrzeit
   Stunden := data[2]
   Sekunden := data[0]
   Minuten  := data[1]
   rtc_ok := 1

if ((rtc_ok == 0) OR (lcd_ok == 0))   ' Wenn nicht vorhanden       
    Blink(LED_Pin, 100)
else 
   lcd.start(SCL, SDA, LCD_Addresse)   ' 1. Zeile
   lcd.backlight(true)
   lcd.cmd(lcd#LCD_CLS)
   lcd.move_cursor(0, 0)
   lcd.str(@banner1)
                                       ' 2. Zeile   
   lcd.move_cursor(0, 1)
   lcd.str(@banner2)
   lcd.hex (Stunden, 2)
   lcd.out (":")
   lcd.hex (Minuten, 2)
   pause(5000)
   lcd.backlight(false)      
   Blink(LED_Pin, 1)
    
PUB pause(ms) | t

'' Delay program in milliseconds

  if (ms < 1)                                                   ' delay must be > 0
    return
  else
    t := cnt - 1776                                             ' sync with system counter
    repeat ms                                                   ' run delay
      waitcnt(t += MS_001)
    

PUB Uhrzeit 
  idx := 0
  block := 7                 ' wieviele Zeichen lesen ?
  bus.I2C_start
  bus.I2C_write(RTC_Addresse)  
  bus.I2C_write(0)                    ' 
  bus.I2C_start
  bus.I2C_write(RTC_Addresse + 1)
  repeat block - 1                 ' bis auf einmal mit ACK
     data[idx++] := bus.I2C_read 
     bus.I2C_ack                   ' bestaetigen                                            ' 
  data[idx++] := bus.I2C_read
  bus.I2C_nak                     ' NACK als Signal
  bus.I2C_stop                                        ' 
                                           '  
PUB Blink(Pin, Times)
  dira[Pin]~~ 
  repeat Times
      waitcnt(80_000_000 + cnt)
      outa[Pin]~~ 
      waitcnt(80_000_000 + cnt)
      outa[Pin]~  
        
DAT

  banner1       byte    "  Hallo Tom !  ", 0 
  banner2       byte    "  Es ist ", 0

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

}}  