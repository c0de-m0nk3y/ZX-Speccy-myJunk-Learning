;functions relating to only RAVE scene

begin_new_rave:
    halt
    call 0xdaf ;cls
    xor a
    call 0x229b ;set border colour
    ld hl,0x5800
    ld c,32
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
    inc hl ;inc HL pointer
    djnz painttransitionlineloop ;loop til B=0
    inc de ;inc DE pointer to next attribute
    dec c ;next line in counter
    ld a,0
    cp c ;is C==0?
    jr nz, paint_transition ;if C!=0, then start loop again
    ret ;otherwise finished.

end_transition:
    call 0xdaf ;cls
    jp play_rave

play_rave:
    jp play_rave