;functions relating to only RAVE scene

;main loop for rave scene
play_rave:
    ;increment step timer and do step when its time.
    ld a,(steptimer)
    inc a
    ld (steptimer),a
    cp STEP_TIME_DELAY
    call z, dostep
    ld ix,wifedata
    call spawnwives ;checks each frame if wife must spawn
    ld hl,willywife
    ld ix,wifedata
    call drawwives

    jp play_rave
;;;; MAIN LOOP ENDS RAVE

begin_new_rave:
    halt
    call sound_jingle_dontyouforgetaboutme
    call 0xdaf ;cls
    xor a
    call 0x229b ;set border colour
    ld hl,0x5AFF
    ld c,24
    call paint_transition
    jp end_transition

;HL=0x5800
;C=24
paint_transition:
    halt
    halt
    halt
    halt
    ld b,32 ;cells per line
    push hl
    call random_memstep ;get random value
    pop hl
painttransitionlineloop:   
    ld (hl),a ;place into attr memory
    dec hl ;inc HL pointer
    djnz painttransitionlineloop ;loop til B=0
    inc de ;inc DE pointer to next attribute
    dec c ;next line in counter
    ld a,0
    cp c ;is C==0?
    jr nz, paint_transition ;if C!=0, then start loop again
    ret ;otherwise finished.

end_transition:
    ld b,50 ; how long to pause for
wait_to_end:
    halt
    djnz wait_to_end
    call 0xdaf ;cls
    jp play_rave



dostep:
    ld a,(steps_travelled)
    inc a
    ld (steps_travelled),a ;increment steps_travelled
    ld a,(steptimer)
    xor a
    ld (steptimer),a ;reset step timer
    ret
    
;IX=wives data
spawnwives:
    ld a,(ix)
    cp 255
    ret z ; if ix=255 , this is my special end of array code, so return.
    ld a,(ix) 
    cp 1
    jp z, spawnnext_wife ;if not alive, go to next
    ld a,(ix+5)
    ld e,a ;E=spawndist
    ld a,(steps_travelled)
    cp e ;compare steps_travelled with spawndist
    call z, spawn_wife ;if they are equal, spawn a wife
spawnnext_wife:
    ld a,WIFE_DATA_LENGTH
    ld d,0
    ld e,a
    add ix,de
    jp spawnwives
spawn_wife:
    ld (ix),1
    jp spawnnext_wife

drawwives:
    ld a,(ix)
    cp 255
    ret z ; if ix=255 , this is my special end of array code, so return.
    ld a,(ix) 
    cp 0
    jp z, drawnext_wife ;if not alive, go to next
    call drawsprite
drawnext_wife:
    ld a,WIFE_DATA_LENGTH
    ld d,0
    ld e,a
    add ix,de
    jp drawwives


steps_travelled dw 0 ;this will be incremented each frame
STEP_TIME_DELAY equ 25 
steptimer db 0

wife_gap db 50 ;gap between wives, will decrease in harder levels
;
;255=end of array
;isAlive,x,y,sizex (cells),sizey (lines),spawndist
wifedata: ;15 wives! (in pairs!)
    db 0, 180, 192-24, 3, 24, 2
    db 0, 170, 192-24, 3, 24, 4
    db 0, 160, 192-24, 3, 24, 6
    db 0, 150, 192-24, 3, 24, 8
    db 255 ;end array
WIFE_DATA_LENGTH equ 6