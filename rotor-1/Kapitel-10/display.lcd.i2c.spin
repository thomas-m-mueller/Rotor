

'  display.lcd.i2c.spin Bibliothek fuer LCD-Displays mit I2C Modul PCF8574 oder PCF8574A
'  ROTOR Feb 2021
'' =================================================================================================
''
''   File....... jm_twi_lcd.spin
''   Purpose.... LCD via I2C using 
''   Author..... Jon "JonnyMac" McPhalen  
''               Copyright (c) 2010-2013 Jon McPhalen
''               -- see below for terms of use
''   E-mail..... jon@jonmcphalen.com
''   Started.... 
''   Updated.... 06 APR 2013 
''
'' =================================================================================================

{

  LCD is configure with 4-bit buss.

  Bit assignments for byte written to PCA8574 

    lcdbyte.7 = D7
    lcdbyte.6 = D6
    lcdbyte.5 = D5
    lcdbyte.4 = D4
    lcdbyte.3 = Backlight control
    lcdbyte.2 = E
    lcdbyte.1 = RW
    lcdbyte.0 = RS


  This code uses open-drain output which requires pull-ups on the SDA and SCL pins.
  If using the 5v interface to the LCD, use additional 4.7K pull-ups on the Propeller
  side to assist the weak pull-ups on the LCD module.

  JonnyMac has not tested the 3.3v SCL/SDA connection on the LCD.    
    
}


CON
  
  LCD_CLS     = $01                                             ' clear the LCD 
  LCD_HOME    = $02                                             ' move cursor home
  LCD_CRSR_LF = $10                                             ' move cursor left 
  LCD_CRSR_RT = $14                                             ' move cursor right 
  LCD_DISP_LF = $18                                             ' shift display left 
  LCD_DISP_RT = $1C                                             ' shift chars right 
                                                                 
  LCD_CGRAM   = $40                                             ' character ram
  LCD_DDRAM   = $80                                             ' display ram
                                                                 
  LCD_LINE0   = LCD_DDRAM | $00                                 ' cursor positions for col 1
  LCD_LINE1   = LCD_DDRAM | $40
  LCD_LINE2   = LCD_DDRAM | $14
  LCD_LINE3   = LCD_DDRAM | $54

  #0, CRSR_NONE, CRSR_ULINE, CRSR_BLINK, CRSR_UBLNK             ' cursor types


  RS_MASK = %0000_0001
  RW_MASK = %0000_0010                                          ' not used!
  E_MASK  = %0000_0100
  BL_MASK = %0000_1000
  

obj

    i2c: "com.i2c"

VAR

  long  ms001                                                   ' ticks in 1ms

  byte  devid                                                   ' PCA8574 address
  byte  ctrlbits                                                ' bl, e, rw, rs
  byte  dispctrl                                                ' display control bits
  

PUB start(sclpin, sdapin, device) 

'' Initializes LCD driver using I2C buss
'' -- device is 0 to 7 (set by jumpers on LCD; on = 0)

  ms001 := clkfreq / 1_000                                      ' calcutate ticks/ms

  i2c.start(sclpin, sdapin)                                    ' connect to i2c buss 
  devid := Device
  lcd_init                                                      ' initialize lcd for 4-bit mode
  

con

pub clear

  cmd(LCD_CLS)


pub home

  cmd(LCD_HOME)


pub left

  cmd(LCD_CRSR_LF)


pub right

  cmd(LCD_CRSR_RT)


pub line(lnum)

  case lnum
    0: cmd(LCD_LINE0)
    1: cmd(LCD_LINE1)
    2: cmd(LCD_LINE2)
    3: cmd(LCD_LINE3)


pub pad(pchar, n)

'' Print pchar n times from current position

  if (n > 0)
    repeat n
      out(pchar)


con
    
pub cmd(c)

'' Write command byte to LCD

  ctrlbits &= !RS_MASK                                          ' RS low
  wr_lcd(c)
  

pub out(c)

'' Write character byte to LCD

  ctrlbits |= RS_MASK                                           ' RS high
  wr_lcd(c)


pub outx(c, n)

'' Print character n times

  if (n > 0)                                                    ' valid?
    repeat n
      out(c)
      

pub str(p_str)

'' Print z-string
'  -- borrowed from FullDuplexSerial

  repeat strsize(p_str)
    out(byte[p_str++])


pub sub_str(p_str, idx, len) | c

'' Prints part of string
'' -- p_str is pointer to start of string
'' -- idx is starting index of sub-string (0 to strsize()-1)
'' -- len is # of chars to print

  p_str += idx
  repeat len
    c := byte[p_str++]
    if (c <> 0)
      out(c)
    else
      quit

 
pub dec(value) | i, x

'' Print a decimal number
'  -- borrowed from FullDuplexSerial
                                                                             
  x := (value == negx)                                                         
  if (value < 0)
    value := ||(value+x)                                                     
    out("-")

  i := 1_000_000_000                                                         

  repeat 10                                                                  
    if value => i                                                            
      out(value / i + "0" + x*(i == 1))                                      
      value //= i                                                            
      result~~                                                               
    elseif result or (i == 1)
      out("0")                                                               
    i /= 10  

    
pub rjdec(val, width, pchar) | tmpval, padwidth

'' Print right-justified decimal value
'' -- val is value to print
'' -- width is width of (space padded) field for value

'  Original code by Dave Hein
'  -- modifications by Jon McPhalen

  if (val => 0)                                                 ' if positive
    tmpval := val                                               '  copy value
    padwidth := width - 1                                       '  make room for 1 digit
  else                                                           
    if (val == negx)                                            '  if max negative
      tmpval := posx                                            '    use max positive for width
    else                                                        '  else
      tmpval := -val                                            '    make positive
    padwidth := width - 2                                       '  make room for sign and 1 digit
                                                                 
  repeat while (tmpval => 10)                                   ' adjust pad for value width > 1
    padwidth--
    tmpval /= 10
     
  repeat padwidth                                               ' print pad
    out(pchar)

  dec(val)                                                      ' print value

 
pub hex(value, digits)

'' Print a hexadecimal number
'  -- borrowed from FullDuplexSerial

  digits := 1 #> digits <# 8

  value <<= (8 - digits) << 2
  repeat digits
    out(lookupz((value <-= 4) & $F : "0".."9", "A".."F"))


pub bin(value, digits)

'' Print a binary number
'  -- borrowed from FullDuplexSerial

  digits := 1 #> digits <# 32

  value <<= (32 - digits)
  repeat digits
    out((value <-= 1) & 1 + "0")


pub set_char(n, p_char)

'' Write character map data to CGRAM
'' -- n is the custom character # (0..7)
'' -- p_char is the address of the bytes that define the character

  if ((n => 0) and (n < 8))                                     ' legal char # (0..7)?
    cmd(LCD_CGRAM + (n << 3))                                   ' move cursor
    repeat 8                                                    ' output character data
      out(byte[p_char++])
    return true
  else
    return false


pub display(ison)

  if ison
    dispctrl := dispctrl |  %0000_0100                          ' display bit on
  else
    dispctrl := dispctrl & !%0000_0100                          ' display bit off

  cmd(dispctrl)
  

pub cursor(mode) | cbits, ok

'' Sets LCD cursor style: off (0), underline (1), blinking bkg (2), uline+bkg (3)

  if ((mode => CRSR_NONE) and (mode =< CRSR_UBLNK))
    cbits := lookupz(mode : %0000_1000, %0000_1010, %0000_1001, %0000_1011)
    dispctrl := dispctrl & %0000_1100 | cbits
    cmd(dispctrl)
    return true
  else
    return false  


pub move_cursor(x, y) 

'' Moves DDRAM cursor to column, row position
'' -- home position is indexed as 0, 0

  case y
    0 : cmd(LCD_LINE0 + x)
    1 : cmd(LCD_LINE1 + x)
    2 : cmd(LCD_LINE2 + x)
    3 : cmd(LCD_LINE3 + x)


pub wr_mem(addr, src, n)

'' Writes n bytes from src to addr in display

  cmd(addr)                                                     ' setup where to write
  repeat n
    out(byte[src++])


pub backlight(setting)

'' Enables (non-zero) or disables (zero) backlight

  if (setting)
    ctrlbits |= BL_MASK
  else
    ctrlbits &= !BL_MASK

  cmd(dispctrl)                                                 ' refresh bl bit
    
  
PUB lcd_init

' Initializes LCD using 4-bit interface via PCA8574

  ctrlbits := BL_MASK                                           ' backlight on, others 0

  waitcnt((ms001 * 15) + cnt)                                   ' allow power-up
  wr_4bits(%0011 << 4)                                          ' 8-bit mode
  
  waitcnt((ms001 * 5) + cnt)
  wr_4bits(%0011 << 4)
  
  waitcnt((ms001 >> 2) + cnt)                                   ' 250us
  wr_4bits(%0011 << 4)
  
  wr_4bits(%0010 << 4)                                          ' 4-bit mode 
  
  cmd(%0010_1000)                                               ' multi-line
  cmd(%0000_0110)                                               ' auto-increment cursor
  dispctrl := %0000_1100                                        ' display on, no cursor
  cmd(dispctrl)
  cmd(LCD_CLS)


pri wr_lcd(b) | work

' Writes byte b to LCD via PCA8574 using 4-bit interface

  wr_4bits(b & $F0)                                             ' high nibble
  wr_4bits((b << 4) & $F0)                                      ' low nibble
  
  if ((b == LCD_CLS) or (b == LCD_HOME))
    waitcnt((ms001 * 3) + cnt)                                  ' use 3ms for CLS and HOME
  else
    waitcnt((ms001 >> 4) + cnt)                                 ' else 63us


pri wr_4bits(b)

'' Write b[7..4] to lcd with ctrlbits[3..0] (backlight, e, rw, rs)

  b := (b & $F0) | (ctrlbits & %1001)                           ' force E and RW low

  i2c_out(b)                                                    ' setup nibble
  i2c_out(b | E_MASK)                                           ' blip lcd.e
  i2c_out(b)
  

pri i2c_out(b)

'' Write byte to LCD via PCA8574 

  i2c.I2C_wait(devid)
  i2c.I2C_write (b)          
  i2c.I2C_stop

  
dat

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