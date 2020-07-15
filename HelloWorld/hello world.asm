ENTRY_POINT equ 32768

    org ENTRY_POINT

    ld a,2
    call 5633
loop:
    ld de,hellostring ;pointing de to hellostring
    ld bc,endofhellostring-hellostring ;bc=length of string
    call 8252 ; call routine to print.
    jp loop ;loop forever




hellostring     db 'Hello world!'
                db 13

endofhellostring equ $

    end ENTRY_POINT