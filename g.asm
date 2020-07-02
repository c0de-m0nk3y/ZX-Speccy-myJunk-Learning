;ENTRY_POINT EQU 32768
ENTRY_POINT EQU 0x8000
    ;Spectrum screen size 256 pixels wide x 192 scan lines
    ; keyboard ports:
    ; todo fill in the rest.
    ; f7fe 12345
    ; fbfe qwert
    ; fdfe asdfg
    ; fefe shift/z/x/c/v

    org ENTRY_POINT

    call &daf
				;a beginner's, unoptimised sprite routine
main:	
    halt			;this stops the program until the Spectrum is about to refresh the TV screen
				;the HALT is important to avoid sprite flicker, and it slows down the program
	call deletesprite	;we need to delete the old position of the sprite
	call checkkeys
	call drawsprite		;get correct preshifted graphic, and draw it on the screen
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
	
; movesprite:			;very simple routine that just increases the x coordinate
; 	ld a,(hatmany)
; 	inc a
; 	ld (hatmany),a
; 	cp 176			;check if the sprite has moved all the way to the right (256-16)
; 	ret c			;return if not
; 	xor a			;if yes then back to left
; 	ld (hatmany),a
; 	ret

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
    dec a
    ld (hatmany),a
    ret

movedown:
    ld a, (hatmany)
    cp 176
    ret z
    inc a
    ld (hatmany),a
    ret

moveleft:
    ld a, (hatmanx)
    cp 0
    ret z
    dec a
    ld (hatmanx),a
    ret

moveright:
    ld a, (hatmanx)
    cp 240
    ret z
    inc a
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
    ld hl, hatman
    ret

include "hatman.asm"

    end ENTRY_POINT