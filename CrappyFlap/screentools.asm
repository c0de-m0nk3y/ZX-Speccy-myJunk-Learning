;screen tools
; yz2pix = converts position yx to pixel memory location

yx2pix:		;don't worry about how this works yet! just arrive with arrive with H=y 0-192, L=x 0-255
	ld a,h	;return with DE at corresponding place on the screen
	rra
	rra
	rra
	and %00011000
	or %01000000
	ld d,a
	ld a,h
	and %00000111
	or d
	ld d,a
	ld a,h
	rla
	rla
	and %11100000
	ld e,a
	ld a,l
	rra
	rra
	rra
	and %00011111
	or e
	ld e,a
	ret

;moves DE down one line, taking into account if it crosses a Character square in Spectrum screen space
nextlinedown:			
	inc d			
	ld a,d			
	and %00000111
	ret nz
	ld a,e
	add a,%00100000
	ld e,a
	ret c
	ld a,d
	sub 8
	ld d,a
	ret

inchl:
	inc hl
	ret