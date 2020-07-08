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
    ; ;this is a test car:
    ; ld ix,carsdata ;ix points at player properties
    ; call deletesprite
    ; call movedown
    ; ld hl,car1 ;hl points at sprite bitmap data
    ; call drawsprite ;draw player

    ;loop all enemies and update them
    ld b,MAX_CARS
    ld ix, carsdata
    call delcarsloop
    ld b,MAX_CARS    
    ld ix, carsdata
    call movecarsloop
    ld b,MAX_CARS
    ld ix, carsdata
    ld hl,car1
    call drawcarsloop

    ;update player
    ld ix,playerdata ;ix points at player properties
    call deletesprite
    call movedown
    ld hl,nickysprite ;hl points at sprite bitmap data
    call drawsprite ;draw player

    jp main

;loops through all cars and calls moveright on them, if alive
;inputs
;B= max cars (reducing iterator)
;IX=cars data pointer
movecarsloop:
    ld a,(ix);
    cp 1 ;if IX==1...do move
    call z, domove 
    ld de,CARSDATA_LENGTH
    add ix,de
    djnz movecarsloop
    ret
domove:
    call moveright
    ret

;loops through all cars and calls deletesprite on them, if alive
;inputs
;B= max cars (reducing iterator)
;IX=cars data pointer
delcarsloop:
    ld a,(ix) ;A=car[i].isAlive?
    cp 1; compare 1 (is alive)
    call z, dodelete
    ld de,CARSDATA_LENGTH
    add ix,de   
    djnz delcarsloop
    ret
dodelete:
    push bc
    call deletesprite
    pop bc
    ret

;loops through all cars and calls drawsprite on them, if alive
;inputs
;B= max cars (reducing iterator)
;IX=cars data pointer
drawcarsloop:
    ld a,(ix) ;A=car[i].isAlive?
    cp 1; compare 1 (is alive)
    call z, dodraw
    ld de,CARSDATA_LENGTH
    add ix,de
    djnz drawcarsloop
    ret
dodraw:
    push bc
    push hl
    call drawsprite
    pop hl
    pop bc
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

MAX_CARS equ 5

CARSDATA_LENGTH equ 5
carsdata
    db 1,0,128,3,24
    db 0,0,0,3,24
    db 0,0,0,3,24
    db 1,0,0,3,24
    db 1,0,64,3,24
    


MOVE_SPEED equ 1
MAX_Y equ 192-48

include "sprites/car1.asm"
include "sprites/nickysprite.asm"
include "sprites/sprites.asm"
include "util/screentools.asm"
include "util/spritetools.asm"

    end ENTRY_POINT
