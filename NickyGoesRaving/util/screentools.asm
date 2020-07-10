;screen tools
;zx spectrum  pixel data address:0x4000-0x57ff 
;attributes address:0x5800-0x5AFF (22528-23295)

; yz2pix = converts position yx to pixel memory location
;INPUTS:
;HL=yx position
;OUTPUTS:
;DE=screen bitmap memory location
yx2pix:		;arrive with arrive with H=y 0-192, L=x 0-255
	ld a,b	
	rra
	rra
	rra
	and %00011000
	or %01000000
	ld d,a
	ld a,b
	and %00000111
	or d
	ld d,a
	ld a,b
	rla
	rla
	and %11100000
	ld e,a
	ld a,c
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

;
;converts position yx to pixel memory location 
;INPUTS:
;HL=yx position
;OUTPUTS:
;HL=screen attribute memory location (ie. 0x5800 + ((y*32)+x))
yx2attributes:
	ld de,0x5800 ;beginning of colour attribute memory
	ld a,h ;A=y 
	add a,a ;x2
	add a,a ;x4 (we needed to divide by 8 to get cell, then multiply by 32, so it is quicker to just x4)
	ld h,a ;put new value in H
	srl l ; L/2
	srl l ; L/4
	srl l ;	L/8
	add hl,de
	ret
	
