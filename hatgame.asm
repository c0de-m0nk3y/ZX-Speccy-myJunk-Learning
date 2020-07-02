ENTRY_POINT EQU 32768

org ENTRY_POINT

    ;screen memory starts 16384 / 0x4000

    call 0xdaf
    ld b,&1 ;x pos. (in bytes)
    ld c,&15 ;y pos. (in pix)
    call GetColourMemAddress 
    ld a,%00000011
    ld (de),a
    call GetScreenAddress
    ld hl,face
    ld b,8

SpriteNextLine:
    ld a,(hl)
    ld (de),a
    inc hl
    
    call GetNextLine
    djnz SpriteNextLine
    ret


; this function will take input in bc=xy position
; out hl= screen memory address
GetScreenAddress:
    ld a,c
    and %00111000
    rlca
    rlca
    or b
    ld e,a
    ld a,c
    and %00000111
    ld d,a
    ld a,c
    and %11000000
    rrca
    rrca
    rrca
    or d
    or 0x40         ;0x4000 = screen base
    ld d,a
    ret

GetNextLine:
    inc d
    ld a,d
    and %00000111
    ret nz
    ld a,e
    and %00100000
    ld e,a
    ret c
    ld a,d
    sub %00001000
    ld d,a
    ret

; input bc=xy (x in bytes, so 32 across)
; output hl=screen memory address
GetColourMemAddress:
    ld a,c
    and %11000000
    rlca 
    rlca
    add a,0x58
    ld d,a
    ld a,c
    and %00111000
    rlca
    rlca
    add a, b
    ld e,a
    ret 

GetNextColourLine:
    ld a,e
    add a,32
    ld e,a
    ret nc
    inc d
    ret 

include "face.asm" 

end ENTRY_POINT