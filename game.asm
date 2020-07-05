ENTRY_POINT EQU 32768

    org ENTRY_POINT

;Spectrum screen size 256 pixels wide x 192 scan lines
;32 x 24 Characters
;
;Colour codes:
; 0=Black
; 1=Blue
; 2=Red
; 3=Pink
; 4=Green
; 5=Cyan
; 6=Yellow
; 7=White
;
; keyboard ports:
; todo fill in the rest.
; f7fe 12345
; fbfe qwert
; fdfe asdfg
; fefe shift/z/x/c/v
;
; 0: start of ROM
; 654: ROM routine which returns keypress (0-39) in E register, or 255 if nothing pressed.
; 949: BEEPER routine. Set the duration in DE and the pitch in HL.
; 3503: ROM routine to clear the screen, setting it to the colour in (23693).
; 6683: Displays the value in the BC register pair, up to a value of 9999.
; 8252: Displays a string at address DE with length BC on the screen.
; 8859: ROM routine to set the border colour to the value in the accumulator.
; 15616: address of ROM font, 96 chars * 8 bytes.
; 16384: 256x192 pixel display
; 22528: 32x24 colour attributes
; 23296: 48K printer buffer, 128K system variables
; 23552: 48K system variables
; 23606: pointer to font, minus 256. (256 = 32 * 8 bytes, 32 is the code for first printable character)
; 23560: ASCII code of the last keypress.
; 23672: clock, incremented 50 times per second.
; 23675: UDG system variable (144/0x90 is first ascii code for UDGs)
; 23693: PAPER/INK/BRIGHT colour.
; 23695: PAPER/INK/BRIGHT colour.
; 23734: I/O channels
; 23755: BASIC area, followed by space for machine code programs. Extra hardware may move this.
; 24000: Arguably the lowest realistic starting point for a game, allowing 41536 bytes.
; 32767: last byte of RAM on a 16K Spectrum.
; 32768: Beginning of uncontended, faster RAM.
; 65535: last byte of RAM on a 48K Spectrum

;initialization of app:
    call 0xdaf ;clear screen + open ch2
    ld a,3 ;choose border colour code
    call 0x229b ;sets border colour to a

main
    halt
    call start
    call update
    jp main

start:
    ;todo: come up with a way to randomise when they spawn
    
    ret

update:
    ;update cars
    ld ix,uppervehicles
    ld b,maxvehicles
uppercarsloop:
    dec b
    ld a, (ix) ;check 'isAlive'
    cp 0
    call z,carloopiterate ;if=0, jp to next car
    push bc ;save b to stack
    ld a,(ix+4) ;load bc with this vehicles xy
    ld b,a
    ld a,(ix+5)
    ld b,a
    ld a, (ix+2) ;next we care about the 3rd byte, the sprite index
    cp 0 ;pushbike
    ld hl,pushbike8
    call z, drawsprite8
    cp 1 ;motorbike
    ld hl,motorbike
    call z, drawsprite16
    cp 2 ;truck
    ld hl,truck
    call z, drawsprite24
    pop bc ;get back b from stack
    ld a,b ;check if b=0...
    cp 0
    jp nz, carloopiterate ;...and loop if not
    ret

carloopiterate:
    ld de, bytespervehicle ;get number of bytes in each vehicles data
    add ix,de ;increase ix by that many bytes, ready to next car
    jp uppercarsloop
    ret
;draw a 8x8 sprite.
;inputs: 
;   BC=sprite xy (bytes x scanlines / basically pixel x pixel)
;   HL=sprite graphic data
drawsprite8:
    call yx2pix ;takes position data from BC, returns screen mem address in DE
    ld b, 8 ;total lines count (ie. 8x8 sprite) - my routines so far only handle equal square sprites
drawlines8:
    ld a, (hl) ;1 byte of graphic at HL into a
    ld (de), a ;put into address de
    inc hl ;move to next byte of sprite graphic data
    call nextlinedown
    djnz drawlines8 ;jump back if(b!=0)
    ret

;draw a 16x16 sprite.
;inputs: 
;   BC=sprite xy (bytes x scanlines / basically pixel x pixel)
;   HL=sprite graphic data
drawsprite16:
    call yx2pix ;takes position data from BC, returns screen mem address in DE
    ld b, 16 ;total lines count (ie. 8x8 sprite) - my routines so far only handle equal square sprites
drawlines16:
    ld a, (hl) ;1 byte of graphic at HL into a
    ld (de), a ;put into address de
    inc hl ;move to next byte of sprite graphic data
    inc e ;e is the x position (i think lol) so this moves to next char space to the right
    ld a,(hl) ;put next byte of graphic into a
    ld (de),a ;put it on screen
    inc hl
    dec e   
    call nextlinedown
    djnz drawlines16 ;jump back if(b!=0)
    ret

;draw a 24x24 sprite.
;inputs: 
;   BC=sprite xy (bytes x scanlines / basically pixel x pixel)
;   HL=sprite graphic data
drawsprite24:
    call yx2pix ;takes position data from BC, returns screen mem address in DE
    ld b, 24 ;total lines count (ie. 8x8 sprite) - my routines so far only handle equal square sprites
drawlines24:
    ld a, (hl) ;1 byte of graphic at HL into a
    ld (de), a ;put into address de
    inc hl ;move to next byte of sprite graphic data
    inc e ;e is the x position (i think lol) so this moves to next char space to the right
    ld a,(hl) ;put next byte of graphic into a
    ld (de),a ;put it on screen
    inc hl
    inc e
    ld a,(hl) ;put next byte of graphic into a
    ld (de),a ;put it on screen
    inc hl
    dec e   
    dec e
    call nextlinedown
    djnz drawlines24 ;jump back if(b!=0)
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

upperlanex  db 0
upperlaney  db 50
include "vehicles.asm"
end ENTRY_POINT
