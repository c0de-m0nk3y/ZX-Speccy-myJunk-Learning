    ;Spectrum screen size 256 pixels wide x 192 scan lines
	; 32 x 24 Characters

    ; keyboard ports:
    ; todo fill in the rest.
    ; f7fe 12345
    ; fbfe qwert
    ; fdfe asdfg
    ; fefe shift/z/x/c/v

ENTRY_POINT equ 32768

    org ENTRY_POINT

    call 0xdaf ;clear screen, open ch2
    xor a ;set 0 to zero (border color choice)
    call 0x229b ;set border color with chosen value
main:
    halt
    ld hl,fsprite
    ld ix,playerdata ;pass playerdata address to ix
    call drawplayer
    jp main

;inputs:
;HL=sprite bitmap
;IX=properties
drawplayer:
    
    ld b,(ix+2) ;H=ypos
    ld c,(ix+1) ;L=xpos
    call yx2pix ;DE=screen mem address for yx
    ; ld hl,fsprite ; point HL at crappyfish spritedata
    ld b,(ix+4) ;load b with number of lines in sprite (sizey)
    dec b
playerdrawlinesloop:
    push bc ;save lines remaining to stack
    ld b,(ix+3) ;a=width (in bytes)
playerdrawbytesloop: ;loop if more that 1 byte width for rest of the width
    ld a, (hl)
    ld (de),a
    inc hl
    inc e
    djnz playerdrawbytesloop
    ld b, (ix+3) ; load b with number of bytes width again
shiftbackloop:
    dec e
    djnz shiftbackloop
    call nextlinedown
    pop bc ;retrieve lines remaining
    djnz playerdrawlinesloop ;loop back if not 0

    ret

;player data as follows:
;isAlive,x,y,sizex (bytes),sizey (lines)
playerdata:
    db 1,85,92,4,32

include "sprites.asm"
include "screentools.asm"

    end ENTRY_POINT
