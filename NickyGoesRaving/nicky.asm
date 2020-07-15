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
    xor a ;start with a black border
    call 0x229b ;set border color with chosen value

main:
    ld a,(gamestate)
    cp 0 
    call z, showmainmenu
    call z, updatemenu
    ret z
    cp 1
    call z, begin_new_road
    cp 2
    call z, begin_new_rave
    jp main

showmainmenu:
    ld a,(menuinitialized)
    cp 1
    ret z ;return if menu is already initialized
    ld a,1
    ld (menuinitialized),a ;set init flag to true
    ;;;;;set up main menu
    ;'nicky goes'
    ld a,22 ;AT code
    rst 16
    ld a,1 ;text ypos
    rst 16
    ld a,11 ;text xpos
    rst 16
    ld de,titlestring
    ld bc,eotitlestring-titlestring
    call 0x203c ; print the string
    ;'1-WASD'
    ld a,22 ;AT code
    rst 16
    ld a,11 ;text ypos
    rst 16
    ld a,10 ;text xpos
    rst 16
    ld de,menustring1
    ld bc,eomenustring1-menustring1
    call 0x203c ; print the string
    ;'2-QZIP'
    ld a,22 ;AT code
    rst 16
    ld a,13 ;text ypos
    rst 16
    ld a,10 ;text xpos
    rst 16
    ld de,menustring2
    ld bc,eomenustring2-menustring2
    call 0x203c ; print the string
    ;'copyright'
    ld a,22 ;AT code
    rst 16
    ld a,21 ;text ypos
    rst 16
    ld a,1 ;text xpos
    rst 16
    ld de,menustringcopyright
    ld bc,eomenustringcopyright-menustringcopyright
    call 0x203c ; print the string
    ;set menu paint colours:
    ld de,menubackgroundattr
    ld hl,0x5800
    ld c,24 ;total lines of screen characters
    call paint_bg
    ret 

updatemenu:
    halt
    ld ix,menu_raving
    call paintmenu
    call checkkeys_menu
    jp updatemenu
    ret

checkkeys_menu:
    ld bc,0xf7fe
    in a, (c)
    rra ;key0 = 1
    push af
    call nc,selectgame1
    pop af
    rra ;key1 = 2
    push af
    call nc,selectgame2
    pop af
    ret


selectgame1:
    call sound_jingle_dontyouforgetaboutme
    pop af ;because it is pushed in the 'check keys menu' function
    ld a,1
    ld (controls_choice),a
    ld (gamestate),a
    jp main

selectgame2:
    call sound_GSharp_0_25
    pop af ;because it is pushed in the 'check keys menu' function
    ld a,2
    ld (controls_choice),a
    dec a ;A=1
    ld (gamestate),a
    jp main




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
    inc de ;inc DE pointer to next attribute
    dec c ;next line in counter
    ld a,0
    cp c ;is C==0?
    jr nz, paint_bg ;if C!=0, then start loop again
    ret ;otherwise finished.

;IX=menu attri pointer (the data is lined up in pairs x and y)
paintmenu:
    ld a,(ix)
    cp 255
    ret z
    ld a,(ix+1) ;A=ypos
    ld l,a
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl ;x32
    ld a,(ix)
    ld e,a
    ld d,0
    add hl,de
    ld de,0x5800
    add hl,de
    push hl
    call random_memstep
    and %00111000
    pop hl
    ld (hl),a ;paint cell with random value
    inc ix 
    inc ix ;move ix forward 2
    jp paintmenu
    ; no return, as it will return above when it hits a value of 255

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

; checks state of keys and calls move functions for player
;Inputs:
;IX=object being moved upon keypress
checkkeys_mode1:
    ld a,(controls_enabled)
    cp 0
    ret z ;return if controls_enabled == false
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
checkkeys_mode2:
    ld a,(controls_enabled)
    cp 0
    ret z ;return if controls_enabled == false
    ld bc,0xfbfe
    in a, (c) ; reads ports, affects flags, but doesnt store value to a register
    rra  ; outermost bit = key0 = Q
    push af
    call nc, moveup
    pop af
    ld bc,0xfefe
    in a, (c)
    rra ; key CAPSHIFT
    push af
    ;call nc, todo: see if we can delete this pushpop
    pop af
    rra ; key Z
    push af
    call nc, movedown
    pop af
    ld bc,0xdffe
    in a, (c) ; reads ports, affects flags, but doesnt store value to a register
    rra  ; outermost bit = key0 = P
    push af
    call nc, moveright
    pop af
    rra  ; outermost bit = key1 = O
    push af
    ; call nc, moveright ;again can it deleted? TODO
    pop af
    rra  ; outermost bit = key2 = I
    push af
    call nc, moveleft
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
    ld a,(ix+7) ;get hat bool
    cp 0 ;if it is still zero we can decrease cash (ie. this happens one time only)
    call z, decreasecash
    ld a,(ix+7) ;get hat bool
    cp 0
    call z,increasescore10
    ld (ix+7),1 ;set hat bool to 1
    call setanim5 ;set anim to down with hat;
    call setcorrectplayerbitmap ;change the sprite to hatted sprite
    
    ret
;
;
;

drawhud:
    ;setup score text position
    ld a,22 ;AT
    rst 16
    xor a ;string ypos
    rst 16
    xor a ;string xpos
    rst 16
    ld de, score_label_string
    ld bc, eoscore_label_string-score_label_string
    call 0x203c
    ;setup cash text position
    ld a,22 ;AT
    rst 16
    xor a ;string ypos
    rst 16
    ld a,27 ;string xpos
    rst 16
    ld de,cash_label_string
    ld bc,eocash_label_string-cash_label_string
    call 0x203c
    ret

;although there are 3 digits for cash, only the middle digit ever changes
decreasecash:
    ld a,(cash_10)
    dec a
    ld (cash_10),a
    add a,ASCII_ZERO
    ld (cash_amount_10),a
    ret

increasescore10:
    ld a,(score_10)
    inc a
    ld (score_10),a
    cp 10
    call z,increasescore100
    jp z,resetscore10
    add a,ASCII_ZERO
    ld (score_amount_10),a
    ret
resetscore10:
    xor a
    ld (score_10),a
    add a,ASCII_ZERO
    ld (score_amount_10),a
    ret
increasescore100:
    ld a,(score_100)
    inc a
    ld (score_100),a
    cp 10
    call z,increasescore1000
    jp z,resetscore100
    add a,ASCII_ZERO
    ld (score_amount_100),a
    ret
resetscore100:
    xor a
    ld (score_100),a
    add a,ASCII_ZERO
    ld (score_amount_100),a
    ret
increasescore1000:
    ld a,(score_1000)
    inc a
    ld (score_1000),a
    cp 10
    call z,increasescore10000
    jp z,resetscore1000
    add a,ASCII_ZERO
    ld (score_amount_1000),a
    ret
resetscore1000:
    xor a
    ld (score_1000),a
    add a,ASCII_ZERO
    ld (score_amount_1000),a
    ret
increasescore10000:
    ld a,(score_10000)
    cp 9
    ret z
    inc a
    ld (score_10000),a
    add a,ASCII_ZERO
    ld (score_amount_10000),a
    ret


;
;
;
;; DATA BEGINS
; NOTE: Due to the coding for movement .The 'speed' property must be the 7th data byte on all moving objects
;note: for moving sprites , data bytes 1-7 must be laid out in order as notes
; if not a moving sprite, bytes 1-5 must be laid out in order.
ASCII_ZERO equ 0x30
score_10 dw 0
score_100 dw 0
score_1000 dw 0
score_10000 dw 0
cash_10 dw 3

;game data:
gamestate db 0 ; (0=main menu, 1=road, 2=rave)
menuinitialized db 0
controls_choice db 0 ; 0=none 1=WASD 2=QZIP

;hud data
score_label_string db 'SCORE: '
score_amount_10000 db ASCII_ZERO
score_amount_1000 db ASCII_ZERO
score_amount_100 db ASCII_ZERO
score_amount_10 db ASCII_ZERO
score_amount_1 db ASCII_ZERO
eoscore_label_string equ $
cash_label_string db 0x60
cash_amount_100 db ASCII_ZERO
cash_amount_10 db ASCII_ZERO + 3
cash_amount_1 db ASCII_ZERO
eocash_label_string equ $


;menu data:
titlestring db 'NICKY GOES'
eotitlestring equ $
menustring1 db '1 - WSAD keys'
eomenustring1 equ $
menustring2 db '2 - QZIP keys'
eomenustring2 equ $
menustringcopyright db 0x7f,' ','Ninkenpoop Studios 1982,2020'
eomenustringcopyright equ $

;map-data:
UPPER_BASE equ 28 ;origin for upper cars (+random offset)
LOWER_BASE equ 96 ;origin for lower cars (+random offset)
LANE_HEIGHT equ 40
LANE_DIVIDE equ 11
WHITE_LINE ;white line bitmap (8x8)
    db 0,0,0,62,62,0,0,0 
whitelineproperties: ;all road lines to be drawn
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

MAX_X equ 255-28 ;rightside boundary for player (screenwidth-playerwidth-speed)
MIN_Y equ 0+4 ;upper boundary (0+speed)
MAX_Y equ 192-24 ;bottom boundary for player (screenheight-playerheight-speed)

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


controls_enabled db 0
HAT_COST equ 10


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


include "rave.asm"
include "road.asm"
include "sprites/cars/carsprites.asm"
include "sprites/characters/willywife.asm"
include "sprites/player/nickysprite.asm"
include "sprites/map/mapsprites.asm"
include "sprites/map/mainmenuattr.asm"
include "util/screentools.asm"
include "util/soundtools.asm"
include "util/spritetools.asm"
include "util/randomgenerators.asm"

    end ENTRY_POINT
