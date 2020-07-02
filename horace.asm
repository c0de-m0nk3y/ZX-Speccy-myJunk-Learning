ENTRY_POINT EQU 0x8000
    ;Spectrum screen size 256 pixels wide x 192 scan lines
	; 32 x 24 Characters

    ; keyboard ports:
    ; todo fill in the rest.
    ; f7fe 12345
    ; fbfe qwert
    ; fdfe asdfg
    ; fefe shift/z/x/c/v

    org ENTRY_POINT

    call 0xdaf
	xor a
	call 0x229b

				;a beginner's, unoptimised sprite routine
main:	
	halt			;the HALT is important to avoid sprite flicker, and it slows down the program
	call deletesprite	;we need to delete the old position of the sprite
	call checkkeys
	call drawsprite		;get correct preshifted graphic, and draw it on the screen
	call getcell
	call colourcells
	jr main			;loop!
	
deletesprite:			;we need to delete the old sprite before we draw the new one.  The sprite is 2 bytes wide & 16 pixels high
	ld bc,(hatmanx)		;make C=hatmanx and B=hatmany, remember LD BC,(hatmanx) gets both hatmanx and hatmany in one LD as they are adjacent in memory
	call yx2pix		;point DE at the corresponding screen address
	ld b,16			;sprite is 16 lines high
delp:	
    xor a			;empty A to delete
	ld (de),a		;repeat a total of 2 times
	inc e			;next column along
	ld (de),a
	dec e			;move DE back to start of line
	call nextlinedown	;move DE down one line
	djnz delp		;repeat 16 times
	ret
	
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

moveup:
    ld a, (hatmany)
    cp 0
    ret z
    sub hatmanspeed
    ld (hatmany),a
    ret

movedown:
    ld a, (hatmany)
    cp 176
    ret z
    add a, hatmanspeed
    ld (hatmany),a
    ret

moveleft:
    ld a, (hatmanx)
    cp 0
    ret z
    sub hatmanspeed
    ld (hatmanx),a
    ret

moveright:
    ld a, (hatmanx)
    cp 240
    ret z
    add a, hatmanspeed
    ld (hatmanx),a
    ret

drawsprite:
	ld bc,(hatmanx)		;make C=hatmanx and B=hatmany, remember LD BC,(hatmanx) gets both hatmanx and hatmany in one LD as they are adjacent in memory
	call yx2pix		;point DE at corresponding screen position
	call getsprite		;point HL at the correct graphic
	ld b,16		;sprite is 16 lines high
dslp:	
    ld a,(hl)		;take a byte of graphic
	ld (de),a		;and put it on the screen
	inc hl			;next byte of graphic
	inc e			;next column on screen
	ld a,(hl)		;repeat for 2 bytes across
	ld (de),a
	inc hl
	dec e			;move DE back to left hand side of sprite
	call nextlinedown
	djnz dslp		;repeat for all 16 lines
	ret


nextlinedown:			;don't worry about how this works yet!
	inc d			;just arrive with DE in the display file
	ld a,d			;and it gets moved down one line
	and 7
	ret nz
	ld a,e
	add a,32
	ld e,a
	ret c
	ld a,d
	sub 8
	ld d,a
	ret
	
yx2pix:		;don't worry about how this works yet! just arrive with arrive with B=y 0-192, C=x 0-255
	ld a,b	;return with DE at corresponding place on the screen
	rra
	rra
	rra
	and 24
	or 64
	ld d,a
	ld a,b
	and 7
	or d
	ld d,a
	ld a,b
	rla
	rla
	and 224
	ld e,a
	ld a,c
	rra
	rra
	rra
	and 31
	or e
	ld e,a
	ret

getsprite:
	ld a, (hatmananimtimer)
	dec a
	ld (hatmananimtimer), a
	cp 0
	call z, animframeends
	ret z
	ld hl,hatman
	ld a, (hatmancurrentframe)
	cp 0
	ret z
	ld hl, hatman+32
    ret

animframeends:
	ld a, (hatmananimdelay)
	ld (hatmananimtimer), a
	call changeanimframe
	ret

; so far this only supports a two frame animation
changeanimframe:
	ld a, (hatmancurrentframe)
	xor %00000001
	ld (hatmancurrentframe), a
	ret

	;C_Div_D:
	;Inputs:
	;     C is the numerator
	;     D is the denominator
	;Outputs:
	;     A is the remainder
	;     B is 0
	;     C is the result of C/D
	;     D,E,H,L are not changed
	;
getcell:
	ld a, (hatmanx)
	ld c, a
	ld a, 8
	ld d, a
	ld b,8
     xor a
       sla c
       rla
       cp d
       jr c,$+4
         inc c
         sub d
       djnz $-8
	ld a,c
	ld (hatmancellx), a
	ld a, (hatmany)
	ld c, a
	ld a, 8
	ld d, a
	ld b,8
     xor a
       sla c
       rla
       cp d
       jr c,$+4
         inc c
         sub d
       djnz $-8
	ld a,c
	ld (hatmancelly), a
     ret

;attribute memory begins at 0x5800
;0x5800 + ((y*32) + x)
colourcells:
	ld de, 0x5800
	ld a, (hatmancelly)
	ld hl, 0
	ld l, a
	add hl,hl ;x2
	add hl,hl ;x4
	add hl,hl ;x8
	add hl,hl ;x16
	add hl,hl ;x32
	ld b,0
	ld a, (hatmancellx)
	ld c,a
	add hl, de
	add hl, bc ; hl now contains exact memory address for colour attributes at players xy
	ld a, (hatmanattributes)
	ld (hl), a
	ld a, (hatmanattributes+1)
	ld b, 0
	ld c, 1
	add hl,bc
	ld (hl), a
	ld a, (hatmanattributes+2)
	ld c, 31
	add hl,bc
	ld (hl),a
	ld a, (hatmanattributes+3)
	ld c, 1
	add hl,bc
	ld (hl),a	

	ret

	
include "hatman.asm"

    end ENTRY_POINT
