; keyboard ports:
    ; todo fill in the rest.
    ; f7fe 12345
    ; fbfe qwert
    ; fdfe asdfg
    ; fefe shift/z/x/c/v


ENTRY_POINT equ 32678

    org ENTRY_POINT

    call 0xDAF ;clear screen, open ch2
    ld a,1
    call 0x229b ;set border colour to A
    

main:
    halt ;50hz

    ;increment timer
    ld ix,fooddata
    ld a,(timer_fooddrop)
    inc a
    ld (timer_fooddrop),a
    cp FOOD_DROP_INTERVAL_1 
    call nc, spawn_food

    ld ix,fooddata
    call delete_foods
    
    ld ix,fooddata
    call move_foods
    ld ix,fooddata
    call draw_foods

    halt ;25fps
    ld hl,playersprite ;point HL at bitmap data
    ld ix,playerdata ;point IX at playerdata
    call deletesprite
    call checkkeyinput
    call drawsprite 

    

    ld a,0x16 ;ASCII 'AT' Code
    rst 16
    ld a,SCORE_LABEL_POS_Y
    rst 16
    ld a,SCORE_LABEL_POS_X
    rst 16
    call printhud


    jp main



;check for keypresses, and call movement on character when press detected
checkkeyinput:
    ld bc,0xfdfe
    in a,(c) 
    rra ;key0 = A
    push af
    call nc, moveleft
    pop af
    rra ; key1 = S
    push af
    ; call nc, something that S key does
    pop af
    rra ;key2 = D
    push af
    call nc, moveright
    pop af
    ret


;IX=data pointer
moveleft:
    ld a,(ix+1) ;get xpos
    cp 0 ; compare A with Zero
    ret z ; is A == 0, if so return.
    ld a,(ix+1) ;get xpos
    sub (ix+5) ;subtract speed
    ld (ix+1),a ;set the new value to xpos
    ret
moveright:
    ld a,(ix+1) ;get xpos
    cp MAX_X ; compare A with MAX_X
    ret nc ; is A >= MAX_X, if so return.
    ld a,(ix+1) ;get xpos
    add a,(ix+5) ;add speed
    ld (ix+1),a ;set the new value to xpos
    ret
movedown:
    ld a,(ix+2) ;get ypos
    cp MAX_Y
    call nc, killfood
    ret nc
    add a,(ix+5) ;add speed
    ld (ix+2),a ;set new ypos value
    ret

;kills the food in IX
killfood:
    ld (ix),0 ;set isAlive to 0
    ld (ix+2),0 ;set ypos to 0
    ret

;put a random number into A
;steps through Spectrum ROM memory gets a random 8bit number
;loop is restricted to the first 8k or ROM
randomnumber:
    ld hl,(randomseed)
    ld a,h
    and %00011111
    ld h,a ;Make sure HL <= 8092 (memory after 8092 is predictable)
    ld a,(hl) ;get the random number from where HL is pointing
    inc hl
    ld (randomseed),hl
    ret

;spawn a food that is not already alive
;INPUTS:
;IX=Pointer to fooddata
spawn_food:
    ld a,0 ;make A=0
    ld (timer_fooddrop),a
    ld a,(ix)
    cp 255 ;is it at end of array
    ret z
    cp 1 ;is it alive?
    jp z, spawn_skiptonextfood ;if not alive, skip draw function
    ld (ix),1 ;Spawn the food.
spawn_getrand:
    call randomnumber ;put rand number into A register
    cp MAX_X
    jp nc, spawn_getrand
    ld (ix+1),a
    ret
spawn_skiptonextfood:    
    ld bc,FOOD_DATA_LENGTH ;BC=food data in bytes
    add ix,bc ; add fooddata length to ix
    jp spawn_food ;loop back
    

;loops all foods, checks if isAlive
;if it is, draws it
;INPUTS:
;IX=Pointer to fooddata
delete_foods:
    ld a,(ix)
    cp 255 ;is it at end of array
    ret z
    cp 0 ;is it not alive?
    jp z, delete_skiptonextfood ;if not alive, skip draw function
    call deletesprite ;delete it
delete_skiptonextfood:    
    ld bc,FOOD_DATA_LENGTH ;BC=food data in bytes
    add ix,bc ; add fooddata length to ix
    jp delete_foods ;loop back


;loops all foods, checks if isAlive
;if it is, moves it
;INPUTS:
;IX=Pointer to fooddata
move_foods:
    ld a,(ix)
    cp 255 ;is it at end of array
    ret z
    cp 0 ;is it not alive?
    jp z, move_skiptonextfood ;if not alive, skip draw function
    call movedown ;draw it
    push iy
    ld iy,playerdata
    call checkburgercollidesplayer
    pop iy
move_skiptonextfood:    
    ld bc,FOOD_DATA_LENGTH ;BC=food data in bytes
    add ix,bc ; add fooddata length to ix
    jp move_foods ;loop back
    

;loops all foods, checks if isAlive
;if it is, draws it
;INPUTS:
;IX=Pointer to fooddata
draw_foods:
    ld a,(ix)
    cp 255 ;is it at end of array
    ret z
    cp 0 ;is it not alive?
    jp z, draw_skiptonextfood ;if not alive, skip draw function
    ld hl,burgersprite ;HL=sprite bitmap
    call drawsprite ;draw it
draw_skiptonextfood:    
    ld bc,FOOD_DATA_LENGTH ;BC=food data in bytes
    add ix,bc ; add fooddata length to ix
    jp draw_foods ;loop back
    
printhud:
    ld de,scorelabelstring
    ld bc,EO_SCORE_LABEL-scorelabelstring
    call 0x203c ;looks in DE for string data, and prints for length BC
    ret


;;;;;; TODO: Collision only works when moving. Score is showing invalid characters
;INPUTS:
;IX=food data (of the specific food in array)
;IY=player data
checkburgercollidesplayer:
    ld a,(iy+1) ;A=player x
    add a,(iy+7) ;A=players width (pix)
    ld l,(ix+1) ;L=food x
    cp l ;compare A with L
    ret c ;return if food is past the left side
    ld a,(iy+1) ;A=player x
    ld b,0 ;TODO: is this needed?
    ld c,(ix+7) ;C=food width
    add hl,bc ;add food width to L
    cp l ;compare A with L
    ret nc ;return if food is past the right side
    ld a,(ix+2) ;A=food y
    add a,(ix+4) ;A+=food height
    ld l,(iy+2) ;L=player y
    cp l ;compare A with L
    ret c ;return if food is above the player y
    
    ;if this far, then its a hit....
    call killfood
    call increasescore_1
    ret

;call increasescore_1, which then handles calculation for higher scores
;no inputs needed.
increasescore_1:
    ld a,(score_1)
    inc a
    ld (score_1),a ;score_1 += 1
    cp 10
    call z, increasescore_10
    jp z, resetscore_1
    add a,ASCII_ZERO
    ld (score_1),a
    ret
resetscore_1:
    xor a ;A=0
    add a, ASCII_ZERO
    ld (score_1),a
    ret

increasescore_10:
    ld a,(score_10)
    inc a
    ld (score_10),a ;score_10 += 1
    cp 10
    call z, increasescore_100
    jp z, resetscore_10
    add a,ASCII_ZERO
    ld (score_10),a
    ret
resetscore_10:
    xor a ;A=0
    add a, ASCII_ZERO
    ld (score_10),a
    ret

increasescore_100:
    ld a,(score_100)
    inc a
    ld (score_100),a ;score_100 += 1
    cp 10
    call z, increasescore_1000
    jp z, resetscore_100
    add a,ASCII_ZERO
    ld (score_100),a
    ret
resetscore_100:
    xor a ;A=0
    add a, ASCII_ZERO
    ld (score_100),a
    ret

increasescore_1000:
    ld a,(score_1000)
    cp 9
    ret z ;if A==9, return.
    inc a ;otherwise increment score
    add a, ASCII_ZERO
    ld (score_1000),a ;set the value in data
    ret


;;;;; DATA BEGINS ;;;;;

PLAYER_START_X equ 128-8
; PLAYER_START_Y equ 192-8
PLAYER_START_Y equ 172-8
MAX_X equ 256-25
MAX_Y equ 192-18
ASCII_ZERO equ 0x30

FOOD_DROP_INTERVAL_1 equ 10
FOOD_DROP_INTERVAL_2 equ 90 
timer_fooddrop db 0


;data format:
;isAlive,x,y,width (cells),height (lines),movespeed, width (pixels)
playerdata:
    db 1,PLAYER_START_X,PLAYER_START_Y,2,8,4,16

FOOD_DATA_LENGTH equ 8
;data format:
;isAlive,x,y,width (cells),height (lines),movespeed,type(0=burger,1=apple),width(pixels)
fooddata:
    db 0,0,0,2,8,1,0,16
    db 0,0,0,2,8,1,0,16
    db 0,0,0,2,8,1,0,16
    db 255


scorelabelstring db 'SCORE:'
score_1000 db ASCII_ZERO
score_100 db ASCII_ZERO
score_10 db ASCII_ZERO
score_1 db ASCII_ZERO
EO_SCORE_LABEL equ $

SCORE_LABEL_POS_X equ 2
SCORE_LABEL_POS_Y equ 0

randomseed dw 0

playersprite:
    db %11111111, %11111111
    db %10000000, %00000001
    db %10001000, %00010001
    db %10001000, %00010001
    db %10000000, %00000001
    db %10100000, %00000101
    db %10111111, %11111101
    db %10000000, %00000001

burgersprite:
    db %01111111, %11111110
    db %11111111, %11111111
    db %11111111, %11111111
    db %00000000, %00000000
    db %00000000, %00000000
    db %11111111, %11111111
    db %01111111, %11111110
    db %00111111, %11111100

include "util/screentools.asm"
include "util/spritetools.asm"


    end ENTRY_POINT