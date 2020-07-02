ENTRY_POINT EQU 32768

    org ENTRY_POINT

    org 32768			;we can ORG (or assemble) this code anywhere really
				;a beginner's, unoptimised sprite routine
main:	halt			;this stops the program until the Spectrum is about to refresh the TV screen
				;the HALT is important to avoid sprite flicker, and it slows down the program
	call deletesprite	;we need to delete the old position of the sprite
	call movesprite		;move the sprite! Could be based on player key input or baddy AI
	call drawsprite		;get correct preshifted graphic, and draw it on the screen
	jr main			;loop!
	;
deletesprite:			;we need to delete the old sprite before we draw the new one.  The sprite is 3 bytes wide & 16 pixels high
	ld bc,(xcoord)		;make C=xcoord and B=ycoord, remember LD BC,(xcoord) gets both xcoord and ycoord in one LD as they are adjacent in memory
	call yx2pix		;point DE at the corresponding screen address
	ld b,16			;sprite is 16 lines high
delp:	xor a			;empty A to delete
	ld (de),a		;repeat a total of 3 times
	inc e			;next column along
	ld (de),a
	inc e
	ld (de),a
	dec e
	dec e			;move DE back to start of line
	call nextlinedown	;move DE down one line
	djnz delp		;repeat 16 times
	ret
	;
movesprite:			;very simple routine that just increases the x coordinate
	ld a,(xcoord)
	inc a
	ld (xcoord),a
	cp 232			;check if the sprite has moved all the way to the right (256-24)
	ret c			;return if not
	xor a			;if yes then back to left
	ld (xcoord),a
	ret
	;
drawsprite:
	ld bc,(xcoord)		;make C=xcoord and B=ycoord, remember LD BC,(xcoord) gets both xcoord and ycoord in one LD as they are adjacent in memory
	call yx2pix		;point DE at corresponding screen position
	ld a,(xcoord)		;but we still need to find which preshifted sprite to draw
	and 7			;we have 8 preshifted graphics to choose from, AND 7 isolates these as 0-7
	call getsprite		;point HL at the correct graphic
	ld b,16			;sprite is 16 lines high
dslp:	ld a,(hl)		;take a byte of graphic
	ld (de),a		;and put it on the screen
	inc hl			;next byte of graphic
	inc e			;next column on screen
	ld a,(hl)		;repeat for 3 bytes across
	ld (de),a
	inc hl
	inc e
	ld a,(hl)
	ld (de),a
	inc hl
	dec e
	dec e			;move DE back to left hand side of sprite
	call nextlinedown
	djnz dslp		;repeat for all 16 lines
	ret
	;
xcoord:	db	60
ycoord:	db	70
	;
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
	;
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
	;
getsprite:		;don't worry much about how this works!  Arrive A holding which pixel within a byte (0-7), point HL at correct graphic
	ld h,0		;we need to multiply A by 48, do it in HL
	ld l,a
	add hl,hl	;x2
	add hl,hl	;x4
	add hl,hl	;x8
	add hl,hl	;x16
	ld b,h
	ld c,l		;BC = x 16
	add hl,hl	;x32
	add hl,bc	;x48
	ld bc,spritegraphic
	add hl,bc	;HL now pointing at correct sprite frame
	ret
	;
spritegraphic:		;8 preshifted graphics, each one 3 bytes wide and 16 pixels high, this one a simple square
db 255, 255, 0		;frame 0
db 255, 255, 0
db 255, 255, 0
db 255, 255, 0
db 255, 255, 0
db 255, 255, 0
db 255, 255, 0
db 255, 255, 0
db 255, 255, 0
db 255, 255, 0
db 255, 255, 0
db 255, 255, 0
db 255, 255, 0
db 255, 255, 0
db 255, 255, 0
db 255, 255, 0
;
db 127, 255, 128	;frame 1
db 127, 255, 128
db 127, 255, 128
db 127, 255, 128
db 127, 255, 128
db 127, 255, 128
db 127, 255, 128
db 127, 255, 128
db 127, 255, 128
db 127, 255, 128
db 127, 255, 128
db 127, 255, 128
db 127, 255, 128
db 127, 255, 128
db 127, 255, 128
db 127, 255, 128
;
db 63, 255, 192		;frame 2
db 63, 255, 192
db 63, 255, 192
db 63, 255, 192
db 63, 255, 192
db 63, 255, 192
db 63, 255, 192
db 63, 255, 192
db 63, 255, 192
db 63, 255, 192
db 63, 255, 192
db 63, 255, 192
db 63, 255, 192
db 63, 255, 192
db 63, 255, 192
db 63, 255, 192
;
db 31, 255, 224		;frame 3
db 31, 255, 224
db 31, 255, 224
db 31, 255, 224
db 31, 255, 224
db 31, 255, 224
db 31, 255, 224
db 31, 255, 224
db 31, 255, 224
db 31, 255, 224
db 31, 255, 224
db 31, 255, 224
db 31, 255, 224
db 31, 255, 224
db 31, 255, 224
db 31, 255, 224
;
db 15, 255, 240		;frame 4
db 15, 255, 240
db 15, 255, 240
db 15, 255, 240
db 15, 255, 240
db 15, 255, 240
db 15, 255, 240
db 15, 255, 240
db 15, 255, 240
db 15, 255, 240
db 15, 255, 240
db 15, 255, 240
db 15, 255, 240
db 15, 255, 240
db 15, 255, 240
db 15, 255, 240
;
db 7, 255, 248		;frame 5
db 7, 255, 248
db 7, 255, 248
db 7, 255, 248
db 7, 255, 248
db 7, 255, 248
db 7, 255, 248
db 7, 255, 248
db 7, 255, 248
db 7, 255, 248
db 7, 255, 248
db 7, 255, 248
db 7, 255, 248
db 7, 255, 248
db 7, 255, 248
db 7, 255, 248
;
db 3, 255, 252		;frame 6
db 3, 255, 252
db 3, 255, 252
db 3, 255, 252
db 3, 255, 252
db 3, 255, 252
db 3, 255, 252
db 3, 255, 252
db 3, 255, 252
db 3, 255, 252
db 3, 255, 252
db 3, 255, 252
db 3, 255, 252
db 3, 255, 252
db 3, 255, 252
db 3, 255, 252
;
db 1, 255, 254		;frame 7
db 1, 255, 254
db 1, 255, 254
db 1, 255, 254
db 1, 255, 254
db 1, 255, 254
db 1, 255, 254
db 1, 255, 254
db 1, 255, 254
db 1, 255, 254
db 1, 255, 254
db 1, 255, 254
db 1, 255, 254
db 1, 255, 254
db 1, 255, 254
db 1, 255, 254
;



    end ENTRY_POINT