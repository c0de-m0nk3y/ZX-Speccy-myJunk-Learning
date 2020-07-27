;functions relating only to the road scene
begin_new_road:
    call 0xdaf ;cls
    ld a,1
    call 0x229b ;set border colour
    ; todo will have to reinitialize any player / game variables when gameover/new games are allowed
    jp play_road

   
play_road:
    halt ;halt x1

    call checktospawnupper ;spawn car after set conditions are met
    call checktospawnlower

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
    
    ;draw lines on road
    ld b, 16 ;num white lines
    ld ix,whitelineproperties
    ld hl,WHITE_LINE
    call drawwhitelinesloop

    halt ;halt x3... game will run @ 17fps !! No more halts!

    ;delete player
    ld ix,playerdata ;ix points at player properties
    call deletesprite
    ;check keys and move if pressed
    ld a,(controls_choice)
    cp 1
    call z, checkkeys_mode1 ;WASD keys
    ld a,(controls_choice)
    cp 2
    call z, checkkeys_mode2 ;QZIP keys
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
    ;check if player reaches top of screen with the hat on
    ld a,(ix+7) ;hasHat bool
    cp 1
    call z,checklevelcomplete ;if hasHat ==1, check position
    
    ;draw shop (last so it is on top of all sprites)
    ld ix,shopdata
    call deletesprite
    ld hl,hatshop
    call drawsprite

    ld de,backgroundattributes
    ld hl,0x5800
    ld c,24 ;total lines of screen characters
    call paint_bg

    call drawhud 

    

    jp play_road
;;;Main play road loop ends

checklevelcomplete:
    ld a,(ix+2) ;ypos
    cp MIN_Y+1
    ret nc ;return if ypos >= MINY+1
    ld a,2
    ld (gamestate),a ;set gamestate to rave mode
    jp start_new_game_main ;if he has hat, and is at MIN_Y then set gamestate and jump to main

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
    ld a,1
    ld (controls_enabled),a ;set controls enabled to true ;todo: this is a hack! consider making a countdown from game start instead
    ld (ix),a ;set car isAlive to true
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