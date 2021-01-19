'                    BCD01.spin
'                    Programm zur Kodierung von BCD-Zahlen 
'                    
'                    
'                    
CON
   _xinfreq = 5_000_000
   _clkmode = xtal1 + pll16x        ' Multiplikator 16

VAR
   long Wert
   long BCD
   long DEZ

   byte TSD
   byte HDT
   byte ZNR
   byte ENR

   byte VRT
   byte DRT
   byte ZTE
   byte ERS  
  
OBJ
   term : "com.serial.terminal"

PUB Start

   term.start(115_200)                          'Terminal initialisieen
   term.Clear 
   term.NewLine                                  
   term.Str(string("***     BCD-KONVERTIERUNG     ***",13))
   term.Str(string("        Dezimal -> BCD",13))
   term.NewLine
   Wert := 1234                                ' maximal 4 Stellen
   term.Str(string("Wert = "))
   term.Dec (Wert)
   term.NewLine

   TSD  := Wert / 1000
   term.Str(string("       Tausender  = "))
   term.Dec (TSD)
   term.Str(string(", Nibble = "))
   term.Bin (TSD, 4)
   term.NewLine
   HDT  := ( Wert - (TSD *1000) ) / 100
   term.Str(string("       Hunderter  = "))
   term.Dec (HDT)
   term.Str(string(", Nibble = "))
   term.Bin (HDT, 4)
   term.NewLine
   ZNR  := ( Wert - (TSD *1000) - (HDT * 100) ) / 10
   term.Str(string("       Zehner     = "))
   term.Dec (ZNR)
   term.Str(string(", Nibble = "))
   term.Bin (ZNR, 4)
   term.NewLine
   ENR  := ( Wert - (TSD *1000) - (HDT * 100) - (ZNR *10) )
   term.Str(string("       Einer      = "))
   term.Dec (ENR)
   term.Str(string(", Nibble = "))
   term.Bin (ENR, 4)
   term.NewLine
   term.NewLine
   BCD := ((TSD)<<12 | (HDT)<<8 | (ZNR)<<4 | (ENR))
   term.Str(string(" -> BCD-Code = "))
   term.Bin (BCD, 16)
   term.NewLine      
   term.Str(string(" -> entspricht der Dezimalzahl = "))
   term.Dec (BCD)
   term.NewLine
   term.NewLine
   term.NewLine      
   term.Str(string("***     BCD-KONVERTIERUNG     ***",13))
   term.Str(string("        BCD -> Dezimal",13))
   term.NewLine
                                 ' maximal 4 Stellen
   term.Str(string("Wert = "))
   term.Dec (BCD)
   term.NewLine
   VRT := ( BCD & %1111_0000_0000_0000 ) >> 12 
   term.Str(string("       Tausender     = "))
   term.Dec (VRT)
   term.NewLine
   DRT := ( BCD & %0000_1111_0000_0000 ) >> 8 
   term.Str(string("       Hunderter     = "))
   term.Dec (DRT)
   term.NewLine
   ZTE := ( BCD & %0000_0000_1111_0000 ) >> 4 
   term.Str(string("       Zehner        = "))
   term.Dec (ZTE)
   term.NewLine
   ERS := ( BCD & %0000_0000_0000_1111 ) 
   term.Str(string("       Einer         = "))
   term.Dec (ERS)
   term.NewLine
   DEZ := VRT*1000+DRT*100+ZTE*10+ERS
    term.Str(string(" -> Dezimalzahl = "))
   term.Dec (DEZ)
