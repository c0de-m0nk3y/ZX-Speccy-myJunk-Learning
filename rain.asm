
;Spectrum screen size 256 pixels wide x 192 scan lines
;32 x 24 Characters
;Colour codes:
; 0=Black
; 1=Blue
; 2=Red
; 3=Pink
; 4=Green
; 5=Cyan
; 6=Yellow
; 7=White

;Raindrops simulation
ENTRY_POINT EQU 32768
    org ENTRY_POINT

;init screen
    call 0xdaf ;ROM Routine - clear screen, open ch2
    xor a ;choose border colour code
    call 0x229b ;built in ROM Routine pushes border colour to memory   

;main loop
main:
    halt ;waits for interrupt
dropsposxloop:
		ld a,(dropsloopiterator)
		add a,a ;x2
		add a,a ;x4 (there are four elements of data each block)
		ld (dropsdataoffset),a ;set the correct data offset
		ld a, (dropsloopiterator) ;get the iterator back into a
		inc a ;increment iterator value
		ld (dropsloopiterator),a ;iterator incremented
        ld bc,(dropsdata) ;set bc to be the position values (see raindrop.asm for full struct info)
        ld hl, raindrop0 ;point hl at raindrop0 sprite bitmap data
		ld a,(dropsloopiterator) ;get iterator into a again
		cp numdrops ;compare iterator to numdrops
		jp c, dropsposxloop ;if a < numdrops, jump back.
	xor a ;set a 0 for reseting iterator
	ld (dropsloopiterator),a ;reset the iterator


    jp main ;keep looping forever
    
;draw a 8x8 sprite.
;inputs: 
;   BC=sprite xy (bytes x scanlines / basically pixel x pixel)
;   HL=sprite graphic data
drawsprite8:
    call yx2pix ;takes position data from BC, returns screen mem address in DE
    ld b, 8 ;total lines count (ie. 8x8 sprite) - my routines so far only handle equal square sprites
drawlines:
    ld a, (hl) ;1 byte of graphic at HL into a
    ld (de), a ;put into address de
    inc hl ;move to next byte of sprite graphic data
    call nextlinedown
    djnz drawlines ;jump back if(b!=0)
    ret



yx2pix:		;don't worry about how this works yet! just arrive with arrive with B=y 0-192, C=x 0-255
	ld a,b	;return with DE at corresponding place on the screen
	rra
	rra
	rra
	and %00011000
	or %01000000
	ld d,a
	ld a,b
	and 7
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


include "raindrop.asm"

end ENTRY_POINT
