'                 I2C007.spin
'                 I2C-Protokoll - 7.LCD - Demo Version 1
'                 mit Standard-Bibliotheken
'                 Umsetzung des HI-Z TriStates in Subroutinen
'' == Basiert auf: =================================================================================
''
''   File....... jm_twi_lcd_demo.spin
''   Author..... Jon "JonnyMac" McPhalen  
''               Copyright (c) 2010-2013 Jon McPhalen
''               -- see below for terms of use
''   E-mail..... jon@jonmcphalen.com
''   Updated.... 06 APR 2013 
''
'' =================================================================================================
CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000                                          ' use 5MHz crystal
  CLK_FREQ = ((_clkmode - xtal1) >> 6) * _xinfreq
  MS_001   = CLK_FREQ / 1_000                                   'mili-Sekunde
  US_001   = CLK_FREQ / 1_000_000                               'nano-Sekunde

  SDA     = 29                                                
  SCL     = 28

  LCD_Addresse = $7E                    ' $3F + Schreiben-Bit (0)
  LCD_WIDTH    = 16
  
OBJ

  lcd :  "display.lcd.i2c"
  term : "com.serial.terminal"


VAR


pub main | idx, pos, frame, char, newchar, tf, tc

  lcd.start(SCL, SDA, LCD_Addresse)                                ' start i2c lcd

  lcd.set_char(0, @mouth0)                                      ' define custom characters
  lcd.set_char(1, @mouth1)
  lcd.set_char(2, @mouth2)
  lcd.set_char(3, @smile)  

  repeat
    lcd.cmd(lcd#LCD_CLS)
    pause(250)

    ' scroll on 1st line
    
    repeat pos from 0 to 16
      lcd.move_cursor(0, 0)
      lcd.sub_str(@banner1, pos, LCD_WIDTH)
      pause(75)

    ' animate 2nd line
    
    repeat pos from 0 to 15                                     ' scroll through all chars
      char := byte[@banner2][pos]                               ' get char from banner2
      repeat frame from 1 to 5                                  ' loop through animation frames
        lcd.move_cursor(pos, 1)                                 ' position cursor
        newchar := lookup(frame : 0, 1, 2, 1, char)             ' get char for frame
        lcd.out(newchar)                                        ' write it
        pause(75)                                               ' short, inter-frame delay
         
    pause(2000)                                                 ' hold for 2 seconds

    
    ' numeric formatting demo

    lcd.cmd(lcd#LCD_CLS)

    repeat tf from 95_0 to 105_0
      tc := (tf - 32_0) * 5 / 9
      lcd.move_cursor(0, 0)
      lcd.rjdec(tf / 10, 3, " ")
      lcd.out(".")
      lcd.out("0" + (tf // 10))
      lcd.out("F")
      lcd.move_cursor(0, 1)
      lcd.rjdec(tc / 10, 3, " ")
      lcd.out(".")
      lcd.out("0" + (tc // 10))
      lcd.out("C")
      pause(100)      

      
    ' backlight control

    repeat 3
      lcd.backlight(false)
      pause(500)
      lcd.backlight(true)
      pause(500)      
    
pub pause(ms) | t

'' Delay program in milliseconds

  if (ms < 1)                                                   ' delay must be > 0
    return
  else
    t := cnt - 1776                                             ' sync with system counter
    repeat ms                                                   ' run delay
      waitcnt(t += MS_001)
    

        
DAT

  mouth0        byte    $0E, $1F, $1C, $18, $1C, $1F, $0E, $00
  mouth1        byte    $0E, $1F, $1F, $18, $1F, $1F, $0E, $00
  mouth2        byte    $0E, $1F, $1F, $1F, $1F, $1F, $0E, $00
  smile         byte    $00, $0A, $0A, $00, $11, $0E, $06, $00

  banner1       byte    $20, $20, $20, $20, $20, $20, $20, $20
                byte    $20, $20, $20, $20, $20, $20, $20, $20
                byte    $52, $4F, $54, $4F, $52, $2D, $31, $20  ' R O T O R - 1
                byte    $20, $52, $55, $4C, $45, $53, $21, $03  ' R U L E S
                byte    $00

  banner2       byte    "  I2C LCD DEMO  ", 0 


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