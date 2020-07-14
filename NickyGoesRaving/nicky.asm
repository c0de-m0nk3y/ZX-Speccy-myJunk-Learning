    ;Spectrum screen size 256 pixels wide x 192 scan lines
	; 32 x 24 Characters

    ; keyboard ports:
    ; todo fill in the rest.
    ; f7fe 12345
    ; fbfe qwert
    ; fdfe asdfg
    ; fefe shift/z/x/c/v

;NOTE: all player animation states must have exactly 2 frames each

ENTRY_POINT equ 32768
    org ENTRY_POINT

    call 0xdaf ;clear screen, open ch2
    ld a,(bordercolour) ;choose border colour
    call 0x229b ;set border color with chosen value

   
main:

    ;wait for interrupt (ie. wait until the final tv linescan has 
    ;just completed -happens at 50hz) -locks game to 50fps
    halt ;halt x1

    call checktospawnupper ;spawn car after set conditions are met
    call checktospawnlower

    ;second halt instruction, wait until the scanlines finish again 
    ;before redrawing player
    ;(PRO-helps with flicker / CON-game now running @ 25fps)
    halt ;halt x2 

    ;update loop for car array (upper):
    ld b,UP_CARS_MAX ;how many maximum cars can we have?
    ld ix, up_carsdata ;IX= first car's data in array 
    call delcarsloop ;routine that deletes previous frames sprite off screen
    ld b,UP_CARS_MAX ;B=max cars again.    
    ld ix, up_carsdata ;IX=first car again  
    call movecarsloop_u ;routine to move the cars
    ld b,UP_CARS_MAX ;B=max cars again
    ld ix, up_carsdata ;IX=car data again
    ld hl,saloon_r ;HL=sprite bitmap ;;;;todo: come up with a way to make car variant random
    call drawcarsloop ;draws the cars


    ;loop all lower cars and update them
    ld b,LO_CARS_MAX
    ld ix, lo_carsdata
    call delcarsloop
    ld b,LO_CARS_MAX    
    ld ix, lo_carsdata
    call movecarsloop_l
    ld b,LO_CARS_MAX
    ld ix, lo_carsdata
    ld hl,saloon_l ;todo: come up with a way to make car variant random
    call drawcarsloop
    
    halt ;halt x3... game will run @ 17fps !! No more halts!

    ld b, 16 ;num white lines
    ld ix,whitelineproperties
    ld hl,WHITE_LINE
    call drawwhitelinesloop


    ;delete player
    ld ix,playerdata ;ix points at player properties
    call deletesprite
    ;check keys and move if pressed
    call checkkeys ;checks for WASD and moves player if pressed (also changes players animstate value)
    call setcorrectplayerbitmap ;sets hl to first bitmap in each animstate
    ;cycle animation frames
    ld a,(ix+9) ;a=animtimer
    inc a ;increment animTimer
    ld (ix+9),a ;set new value to timer
    cp ANIM_FRAME_LENGTH_TIME
    call nc,gonextanimframe ;if animtimer >= frame length, then go to next frame
    call addanimationoffset ;add the necessary number of bytes to the base bitmap address
    ;draw correct frame
    call drawsprite ;draw sprite in HL
    
    ;IX is already player data, set iy to shop and check for collision
    ld iy,shopdata
    call checkplayerhatshopcollision
    
    ;draw shop (last so it is on top of all sprites)
    ld ix,shopdata
    call deletesprite
    ld hl,hatshop
    call drawsprite

    ld de,backgroundattributes
    ld hl,0x5800
    ld c,24 ;total lines of screen characters
    call paint_bg

    jp main
;;;Main loop ends

;count spawn timer, and spawn when time comes
;upper lane:
checktospawnupper:
    ld a,(carspawntimer_u)
    inc a ;increment spawn timer
    ld (carspawntimer_u),a ;set new value
    push af ;save timer to stack
    ld a,(carspawndelay) ;get delay value
    ld b,a ;store delay in b
    pop af ;get back timer from stack
    cp b ;compare timer with delay
    ret c ;if timer<delay then return
    xor a; A=0
    ld (carspawntimer_u),a ;reset spawn timer
    ld ix,up_carsdata ;ix points to start of cars array
checkalive_upper:    
    ld a,(ix) ;A=isalive?
    cp 0
    push af
    call z, spawncar_upper ;if car not alive, spawn it
    pop af
    cp 0
    ret z ;return after spawning
    cp 255 ;255 is end of car data array
    ret z ;so return if it is 255
    ld bc,UP_CARSDATA_LENGTH ;BC=number of bytes data is a car
    add ix,bc ;more to next car
    jp checkalive_upper ;jump back and spawn next non-alive car
    ret
;
spawncar_upper:
    ld (ix),1 ;set car isAlive to true
    ld (ix+1),0 ;reset position x
    call random_memstep ;get random number for pos y
    and LANE_HEIGHT ;make it a number between 0-lane height
    add a,UPPER_BASE ;add upper base point
    ld (ix+2),a ;set position y
    ld a,(car_minspeed_u)
    ld b,a
    call random_memstep ;get random number for speed
    and CAR_MAX_SPEED_U
    add a,b ;A+=car_minspeed
    res 7,a ;ensure bit7 is reset (speed is a signed number, bit7 set means negative)
    ld (ix+6),a
    ret
;lower lane:
checktospawnlower:
    ld a,(carspawntimer_l)
    inc a ;increment spawn timer
    ld (carspawntimer_l),a ;set new value
    push af ;save timer to stack
    ld a,(carspawndelay) ;get delay value
    ld b,a ;store delay in b
    pop af ;get back timer from stack
    cp b ;compare timer with delay
    ret c ;if timer<delay then return
    xor a; A=0
    ld (carspawntimer_l),a ;reset spawn timer
    ld ix,lo_carsdata ;ix points to start of cars array
checkalive_lower:    
    ld a,(ix) ;A=isalive?
    cp 0
    push af
    call z, spawncar_lower ;if car not alive, spawn it
    pop af
    cp 0
    ret z ;return after spawning
    cp 255 ;255 is end of car data array
    ret z ;so return if it is 255
    ld bc,LO_CARSDATA_LENGTH ;BC=number of bytes data is a car
    add ix,bc ;more to next car
    jp checkalive_lower ;jump back and spawn next non-alive car
    ret
;
spawncar_lower:
    ld (ix),1 ;set car isAlive to true
    ld (ix+1),CAR_MAX_X ;reset position x (to right side)
    call random_memstep ;get random number for pos y
    and LANE_HEIGHT ;make it a number between 0-lane height
    add a,LOWER_BASE ;add lower base point
    ld (ix+2),a ;set position y
    ld a,(car_minspeed_l)
    ld b,a
    call random_memstep ;get random number for speed
    or CAR_MAX_SPEED_L
    add a,b ;A+=car_minspeed  
    ld (ix+6),a
    ret

;DE=bg attributes
;HL=0x5800
;C=24
paint_bg:
    ld b,32 ;cells per line
paintlineloop:
    ld a,(de) ;getcolour from DE
    ld (hl),a ;place into attr memory
    inc hl ;inc HL pointer
    djnz paintlineloop ;loop til B=0
gonextline
    inc de ;inc DE pointer to next attribute
    dec c ;next line in counter
    ld a,0
    cp c ;is C==0?
    jr nz, paint_bg ;if C!=0, then start loop again
    ret ;otherwise finished.

; ;this routine seems to work in that it colors the correct cell
; ;but for some reason it seems to not work when used with the rest of the code for drawing player and painting bg
; ;ix=player
; ;de=0x5800
; paintplayer:
;     ld a,(ix+2) ;get player y
;     ld l,a
;     add hl,hl
;     add hl,hl ;HL= player y cell
;     add hl,de ;+= 0x5800
;     ld a,(ix+1) ;get player x
;     sra a
;     sra a
;     sra a;/8
;     ld e,a
;     ld d,0
;     add hl,de ;+= player x cell
;     ld a,(ix+11) ;get player colour
;     ld (hl),a ;paint the cell
;     ret 

;cycles the anim frame index
;inputs
;IX=player
gonextanimframe:
    ld (ix+9),0 ;animTimer=0 
    ld a,(ix+8) ;get current anim frame
    cp ANIM_CYCLE_LENGTH
    jr c, incframe
    jr nc, resettofirstframe  
incframe:
    inc (ix+8) ;increment frame
    jp endgonext
resettofirstframe:
    ld (ix+8),0 ;set frame property to 0
    jp endgonext
endgonext:
    ret  

;adds to hl the value for the current anim frame
addanimationoffset:
    ld a,(ix+8) ;get current anim frame
    cp 0 ;if 0 dont loop at all
    ret z ;return if =0
    ld b,a ;b=current anim frame
addoffsetloop:
    ld de,NICKY_BYTESPERFRAME
    add hl,de ;increase hl by bytesperframe
    djnz addoffsetloop ;loop until b=0
    ret


;loops through all cars and calls movecarsideways_u on them, if alive
;inputs
;B= max cars (reducing iterator)
;IX=cars data pointer
;upper:
movecarsloop_u:
    ld a,(ix);
    cp 1 ;if isAlive...do move
    call z, domove_u 
    ld de,UP_CARSDATA_LENGTH
    add ix,de
    djnz movecarsloop_u
    ret
domove_u:
    ld a,(ix+1) ;get xpos
    cp CAR_MAX_X 
    jp nc,killcar_u
    call movecarsideways_u
    ret
killcar_u:
    ld (ix),0 ;set car to dead
    ret  
;lower:
movecarsloop_l:
    ld a,(ix);
    cp 1 ;if isAlive...do move
    call z, domove_l 
    ld de,LO_CARSDATA_LENGTH
    add ix,de
    djnz movecarsloop_l
    ret
domove_l:
    ld a,(ix+1) ;get xpos
    cp CAR_MIN_X 
    jp c,killcar_l
    call movecarsideways_l
    ret
killcar_l:
    ld (ix),0 ;set car to dead
    ret

;moves object pointed by IX by it own speed property
;inputs:
;IX=properties of object to move
movecarsideways_u:
    ld a,(ix+1) ;load xpos to a
    add a,(ix+6) ;add speed
    ld (ix+1),a ;set new xpos value
    ret
movecarsideways_l:
    ld a,(ix+1) ;load xpos to a
    add a,(ix+6) ;add speed
    ld (ix+1),a ;set new xpos value
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
    add ix,de ;skip ix to next car data
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

drawwhitelinesloop:
    push bc
    push hl
    call drawsprite
    pop hl
    pop bc
    ld de,WHITE_LINE_DATA_LENGTH
    add ix,de
    djnz drawwhitelinesloop
    ret


; checks state of keys and calls move functions for player
;Inputs:
;IX=object being moved upon keypress
checkkeys:
    ld bc,0xfdfe
    in a, (c) ; reads ports, affects flags, but doesnt store value to a register
    rra  ; outermost bit = key0 = A
    push af
    call nc, moveleft
    pop af
    rra ; outermost bit = key1 = S
    push af
    call nc, movedown
    pop af
    rra ; outermost bit = key2 = D
    push af
    call nc, moveright
    pop af
    ld bc,0xfbfe
    in a, (c)
    rra ; key Q
    push af
    ;call nc, whateverQcando
    pop af
    rra ; key W
    push af
    call nc, moveup
    pop af
    ret


;player movement routines
moveup:
    ld a,(ix+2) ;load ypos to a
    cp MIN_Y ;if a>=MINY
    ret c ;...don't move
    sub (ix+6) ;otherwise subtract speed value from a
    ld (ix+2),a ;set the new value
    ld a,(ix+7) ;get hasHat bool
    cp 0 ;doesnt have hat
    call z, setanim1
    cp 1 ;does have hat
    call z, setanim4
    ret
movedown:
    ld a,(ix+2) ;load ypos to a
    cp MAX_Y
    ret nc 
    add a,(ix+6) ;add speed
    ld (ix+2),a ;set new ypos value
    ld a,(ix+7) ;get hasHat bool
    cp 0 ;doesnt have hat
    call z, setanim2
    cp 1 ;does have hat
    call z, setanim5
    ret
moveleft:
    ld a,(ix+1) ;load xpos to a
    cp 0 ;if a==0...
    ret z ;...return
    sub (ix+6) ;otherwise subtract speed value from a
    ld (ix+1),a ;set the new value
    ret
moveright:
    ld a,(ix+1) ;load ypos to a
    cp MAX_X
    ret nc 
    add a,(ix+6) ;add speed
    ld (ix+1),a ;set new xpos value
    ret

;sets the player animstate variable to chosen value
setanim0:
    ld (ix+5),0 ;set anim state to 0
    ret
setanim1:
    ld (ix+5),1 ;set anim state to 1
    ret
setanim2:
    ld (ix+5),2 ;set anim state to 2
    ret
setanim3:
    ld (ix+5),3 ;set anim state to 3
    ret
setanim4:
    ld (ix+5),4 ;set anim state to 4
    ret
setanim5:
    ld (ix+5),5 ;set anim state to 5
    ret   
setanim6:
    ld (ix+5),6 ;set anim state to 6
    ret   
;function points HL to the player sprite, depending on which anim state he is in
;Inputs:
;IX=player
;Outputs:
;HL=first frame in correct anim sequence.
setcorrectplayerbitmap:
    ld a,(ix+5) ;ld current animstate key into a
    cp 0 ;is it idle (no hat)?
    ld hl,idle_nohat
    ret z
    cp 1 ;is it up (no hat)?
    ld hl,up_nohat
    ret z
    cp 2 ;is it down (no hat)?
    ld hl,down_nohat
    ret z
    cp 3
    ld hl,idle_hat
    ret z
    cp 4 ;is it up (with hat)?
    ld hl,up_hat
    ret z
    cp 5 ;is it down (with hat)?
    ld hl,down_hat
    ret z
    ;; TODO: cp 6 (dancing?)
    ret

;INPUTS:
;IX=player
;IY=hatshop
;DESTROYS: a, bc, hl 
checkplayerhatshopcollision:
    ld a,(ix+1) ;A=player x
    add a,(ix+10) ;A=players right edge
    ld l,(iy+1) ;L=shop x
    cp l ;compare A with B
    ret c ;return if player is past the left side
    ld a,(ix+1) ;A=player x
    ld c,(iy+5) ;C=shop width
    add hl,bc ;add shop width to L
    cp l ;compare A with L
    ret nc ;return if player is past the right side
    ld a,(ix+2) ;A=player y
    add a,(ix+4) ;A+=player height
    ld l,(iy+2) ;L=shop y
    cp l ;compare A with L
    ret c ;return if player is above the shop y
    ;if this far, then its a hit....
    ld (ix+7),1 ;set hat bool to 1
    call setanim5 ;set anim to down with hat;
    call setcorrectplayerbitmap ;change the sprite to hatted sprite
    ret
;
;
;


;
;
;
;; DATA BEGINS
; NOTE: Due to the coding for movement .The 'speed' property must be the 7th data byte on all moving objects

;map-data:
bordercolour db 1
;lanes y constants:
LANE_DIVIDE equ 11
WHITE_LINE
    db 0,0,0,62
    db 62,0,0,0 ;white line
whitelineproperties:
    db 1,0,88,1,8
    db 1,16,88,1,8
    db 1,32,88,1,8
    db 1,48,88,1,8
    db 1,64,88,1,8
    db 1,80,88,1,8
    db 1,96,88,1,8
    db 1,112,88,1,8
    db 1,128,88,1,8
    db 1,144,88,1,8
    db 1,160,88,1,8
    db 1,176,88,1,8
    db 1,192,88,1,8
    db 1,208,88,1,8
    db 1,224,88,1,8
    db 1,240,88,1,8
WHITE_LINE_DATA_LENGTH equ 5
UPPER_BASE equ 28
LOWER_BASE equ 92
LANE_HEIGHT equ 40
; U1 equ 28
; U2 equ 48
; U3 equ 68
; L1 equ 92
; L2 equ 116
; L3 equ 136
MAX_X equ 255-28 ;rightside boundary for player (screenwidth-playerwidth-speed)
MIN_Y equ 0+4 ;upper boundary (0+speed)
MAX_Y equ 192-24 ;bottom boundary for player (screenheight-playerheight-speed)
;note: for moving sprites , data bytes 1-7 must be laid out in order as notes
; if not a moving sprite, bytes 1-5 must be laid out in order.

CAR_MIN_X equ 17
CAR_MAX_X equ 255-28 

;hatshop data:
;isalive?,x,y,sizex,sizey,width (pixels)
shopdata    db 1,(256/2)-16,192-16,4,16,32

;player data format:
;0 isAlive (bool) 1=alive
;1 x
;2 y
;3 sizex (cells)
;4 sizey (lines)
;5 anim state (0=idle,1=up,2=down,3=idle hat,4=up hat,5=down hat,6=down dancing)
;6 move speed
;7 has a hat? (bool) 0=no hat
;8 current anim frame
;9 animtimer
;10 width (pixels)
;11 colour attribute
playerdata  db 1,120,0,3,24,0,8,0,0,0,24,%00101011

;;car data format:
;isAlive (0=dead 1=alive 255=end of car data)
;x
;y
;sizex (cells)
;sizey (lines)
;variant(0=bike,1=car,2=lorry)
;speed
UP_CARS_MAX equ 5
UP_CARSDATA_LENGTH equ 7
up_carsdata
    db 0,0,0,3,16,1,0
    db 0,0,0,3,16,1,0
    db 0,0,0,3,16,1,0
    db 0,0,0,3,16,1,0
    db 0,0,0,3,16,1,0
    db 255 
LO_CARS_MAX equ 5
LO_CARSDATA_LENGTH equ 7
lo_carsdata
    db 0,0,0,3,16,1,-6
    db 0,0,0,3,16,1,-10
    db 0,0,0,3,16,1,-5
    db 0,0,0,3,16,1,-3
    db 0,0,0,3,16,1,-6
    db 255
carspawndelay db 32
carspawntimer_u db 0
carspawntimer_l db 0
CAR_MAX_SPEED_U equ %10000111
CAR_MAX_SPEED_L equ %11111000

; CAR_MAX_SPEED_L equ -6
; CAR_MAX_SPEED_U equ 6
car_minspeed_l db -2
car_minspeed_u db 2



include "sprites/cars/carsprites.asm"
include "sprites/player/nickysprite.asm"
include "sprites/map/mapsprites.asm"
include "util/screentools.asm"
include "util/spritetools.asm"
include "util/randomgenerators.asm"

    end ENTRY_POINT
