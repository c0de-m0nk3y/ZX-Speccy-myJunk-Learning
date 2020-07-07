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
    ld ix,playerdata ;ix points at player properties
    call deletesprite
    call moveright
    ld hl,crappyfish ;hl points at crappyfish bitmap data
    call drawsprite ;draw player

    ld ix,d1
    call deletesprite
    call moveright
    ld hl,car1
    call drawsprite

    jp main

;handle movement
;inputs:
;IX=properties of object to move
movedown:
    ld a,(ix+2) ;load ypos to a
    cp MAX_Y
    ret z 
    add a,MOVE_SPEED ;add speed
    ld (ix+2),a ;set new ypos value
    ret

moveright:
    ld a,(ix+1) ;load xpos to a
    add a,MOVE_SPEED ;add speed
    ld (ix+1),a ;set new xpos value
    ret

;deletes a sprite
;inputs:
;IX=properties (must include yx and bitmap size data)
deletesprite:
    ld b,(ix+2) ;B=ypos
    ld c,(ix+1) ;C=xpos
    call yx2pix ;DE=screen mem address for yx
    ld b,(ix+4) ;load b with number of lines in sprite (sizey)
    dec b
spritedellinesloop:
    push bc ;save lines remaining to stack
    ld b,(ix+3) ;a=width (in bytes)
spritedelbytesloop: ;loop if more that 1 byte width for rest of the width
    xor a
    ld (de),a
    inc e
    djnz spritedelbytesloop
    ld b, (ix+3) ; load b with number of bytes width again
spritedelshiftbackloop:
    dec e
    djnz spritedelshiftbackloop
    call nextlinedown
    pop bc ;retrieve lines remaining
    djnz spritedellinesloop ;loop back if not 0
    ret    

;draws a sprite of any size
;inputs:
;HL=sprite bitmap
;IX=properties (must include yx and bitmap size data)
drawsprite:
    ld b,(ix+2) ;B=ypos
    ld c,(ix+1) ;C=xpos
    call yx2pix ;DE=screen mem address for yx
    ld b,(ix+4) ;load b with number of lines in sprite (sizey)
    dec b
spritedrawlinesloop:
    push bc ;save lines remaining to stack
    ld b,(ix+3) ;a=width (in bytes)
spritedrawbytesloop: ;loop if more that 1 byte width for rest of the width
    ld a, (hl)
    ld (de),a
    inc hl
    inc e
    djnz spritedrawbytesloop
    ld b, (ix+3) ; load b with number of bytes width again
spritedrawshiftbackloop:
    dec e
    djnz spritedrawshiftbackloop
    call nextlinedown
    pop bc ;retrieve lines remaining
    djnz spritedrawlinesloop ;loop back if not 0
    ret

;data format:
;isAlive,x,y,sizex (cells),sizey (lines)
playerdata  db 1,85,50,4,32

d1  db 1,0,85,3,24
d2  db 1,0,64,3,24
d3  db 1,0,100,3,24
d4  db 1,0,132,3,24
d5  db 1,0,172,3,24

MOVE_SPEED equ 1
MAX_Y equ 192-32

include "sprites/car1.asm"
include "sprites/sprites.asm"
include "util/screentools.asm"

    end ENTRY_POINT
