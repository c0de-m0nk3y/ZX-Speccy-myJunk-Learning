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
    halt ;wait for interrupt (ie. wait until the tv linescan has just completed -happens at 50 Mhz) -locks game to 50fps
   
    ;loop all upper cars and update them
    ld b,UP_CARS_MAX
    ld ix, up_carsdata
    call delcarsloop
    ld b,UP_CARS_MAX    
    ld ix, up_carsdata
    call movecarsloop
    ld b,UP_CARS_MAX
    ld ix, up_carsdata
    ld hl,saloon_r ;todo: come up with a way to make car variant random
    call drawcarsloop

    halt ;second halt instruction, wait until the scanlines finish again before redrawing player (PRO-helps with flicker / CON-game now running @ 25 Mhz)
    
    ;loop all lower cars and update them
    ld b,LO_CARS_MAX
    ld ix, lo_carsdata
    call delcarsloop
    ld b,LO_CARS_MAX    
    ld ix, lo_carsdata
    call movecarsloop
    ld b,LO_CARS_MAX
    ld ix, lo_carsdata
    ld hl,saloon_l ;todo: come up with a way to make car variant random
    call drawcarsloop

    ;update player
    ld ix,playerdata ;ix points at player properties
    call deletesprite
    ld hl,idle_nohat ;hl points at sprite bitmap data
    call drawsprite ;draw player

    ;drawshop
    ld ix,shopdata
    call deletesprite
    ld hl,hatshop
    call drawsprite

    jp main

;loops through all cars and calls moveright on them, if alive
;inputs
;B= max cars (reducing iterator)
;IX=cars data pointer
movecarsloop:
    ld a,(ix);
    cp 1 ;if IX==1...do move
    call z, domove 
    ld de,UP_CARSDATA_LENGTH
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
    ld de,UP_CARSDATA_LENGTH
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
    ld de,UP_CARSDATA_LENGTH
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
    ret nc 
    add a,(ix+6) ;add speed
    ld (ix+2),a ;set new ypos value
    ret
moveright:
    ld a,(ix+1) ;load xpos to a
    add a,(ix+6) ;add speed
    ld (ix+1),a ;set new xpos value
    ret




;DATA BEGINS
; NOTE: Due to the coding for movement .The 'speed' property must be the 7th data byte on all moving objects

;map-data:
;lanes y constants:
U1 equ 25
U2 equ 50
U3 equ 75
LANE_DIVIDE equ 100
L1 equ 108
L2 equ 133
L3 equ 158
MAX_Y equ 192-75 ;temporary boundary, stopping movement beyond this point

;note: for moving sprites , data bytes 1-7 must be laid out in order as notes
; if not a moving sprite, bytes 1-5 must be laid out in order.
;hatshop data:
shopdata    db 1,(256/2)-16,192-16,4,16
;player data format:
;isAlive,x,y,sizex (cells),sizey (lines),current anim frame, move speed
playerdata  db 1,0,0,3,24,0,4


;;player data format:
;isAlive
;x
;y
;sizex (cells)
;sizey (lines)
;variant(0=bike,1=car,2=lorry)
;speed
UP_CARS_MAX equ 5
UP_CARSDATA_LENGTH equ 7
up_carsdata
    db 1,0,U1,3,16,1,4
    db 1,0,U2,3,16,1,8
    db 1,0,U3,3,16,1,2
    db 0,0,0,3,16,1,2
    db 0,0,0,3,16,1,2
LO_CARS_MAX equ 5
LO_CARSDATA_LENGTH equ 7
lo_carsdata
    db 1,0,L1,3,16,1,-4
    db 1,0,L2,3,16,1,-8
    db 1,0,L3,3,16,1,-2
    db 0,0,0,3,16,1,-2
    db 0,0,0,3,16,1,-2



include "sprites/cars/carsprites.asm"
include "sprites/player/nickysprite.asm"
include "sprites/map/mapsprites.asm"
include "util/screentools.asm"
include "util/spritetools.asm"

    end ENTRY_POINT
