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
    ;update player
    ld ix,playerdata ;ix points at player properties
    call deletesprite
    call movedown
    ld hl,nickysprite ;hl points at sprite bitmap data
    call drawsprite ;draw player

    ;loop all enemies and update them
    ld b,MAX_CARS
    ld iy, carsdata
    ;call delcarsloop
    ;call movecarsloop
    ld hl,car1
    call drawcarsloop


    jp main

;loops through all cars and calls moveright on them, if alive
;inputs
;B= max cars (reducing iterator)
;IY=cars data pointer
movecarsloop:
    ld a,(iy) ;A=car[i].isAlive?
    cp 1; compare 1 (is alive)
    call z, domove
    ld de,CARSDATA_LENGTH
    add iy,de
    djnz movecarsloop
    ret
domove:
    ld d,iyh
    ld e,iyl
    ld ixh,d
    ld ixl,e
    call moveright
    ret

;loops through all cars and calls deletesprite on them, if alive
;inputs
;B= max cars (reducing iterator)
;IY=cars data pointer
delcarsloop:
    ld a,(iy) ;A=car[i].isAlive?
    cp 1; compare 1 (is alive)
    call z, dodelete
    ld de,CARSDATA_LENGTH
    add iy,de
    djnz delcarsloop
    ret
dodelete:
    ld d,iyh
    ld e,iyl
    ld ixh,d
    ld ixl,e
    call deletesprite
    ret

;loops through all cars and calls drawsprite on them, if alive
;inputs
;B= max cars (reducing iterator)
;IY=cars data pointer
drawcarsloop:
    ld a,(iy) ;A=car[i].isAlive?
    cp 1; compare 1 (is alive)
    call z, dodraw
    ld de,CARSDATA_LENGTH
    add iy,de
    djnz drawcarsloop
    ret
dodraw:
    ld d,iyh
    ld e,iyl
    ld ixh,d
    ld ixl,e
    call drawsprite
    ret



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




;
;data format:
;isAlive,x,y,sizex (cells),sizey (lines)
playerdata  db 1,85,50,4,48

MAX_CARS equ 10

CARSDATA_LENGTH equ 5
carsdata
    db 0,0,0,4,32
    db 0,0,0,4,32
    db 1,20,20,3,24
    db 0,0,0,4,32
    db 0,0,0,4,32
    db 0,0,0,4,32
    db 0,0,0,4,32
    db 0,0,0,4,32
    db 0,0,0,4,32
    db 0,0,0,4,32


MOVE_SPEED equ 1
MAX_Y equ 192-48

include "sprites/car1.asm"
include "sprites/nickysprite.asm"
include "sprites/sprites.asm"
include "util/screentools.asm"
include "util/spritetools.asm"

    end ENTRY_POINT
