ENTRY_POINT EQU 32768
org ENTRY_POINT


; hello cunt!

    call 0xdaf
loop 
    ld de,string ; address of string
    ld bc,eostr-string ; length of string to print
    call 8252 ; print our string
    jp loop ; repeat until screen is full


string  defb 'Hello you fucking cunt'
        defb 13
eostr   equ $

end ENTRY_POINT