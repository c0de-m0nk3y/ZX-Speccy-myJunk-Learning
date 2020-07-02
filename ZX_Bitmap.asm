ENTRY_POINT EQU 32768

org ENTRY_POINT

	call &daf			;Clear screen and open ch2
	ld b,&10	;Xpos (in bytes)
	ld c,&15			;Ypos (in pixels)

	call GetColMemPos	; Do color for block
	ld a,%00000011
	ld (de),a
	
	call GetScreenPos	;Get Screen Memory pos
	ld hl,hatman		;Sprite Source
	ld b,8				;Lines
SpriteNextLine:
	ld a,(hl)			;Source Byte
	ld (de),a			;Screen Destination
	inc hl				;INC Source (Sprite) Address
	
	call GetNextLine	;Scr Next Line (Alter HL to move down a line)

	djnz SpriteNextLine	;Repeat for next line

	ret					;Finished 

	
;data
include "hatman.asm"

	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
;	_0 _1 _0 Y7 Y6 Y2 Y1 Y0   Y5 Y4 Y3 X4 X3 X2 X1 X0

;	; Input  BC= XY (x=bytes - so 32 across)
;	; output HL= screen mem pos
GetScreenPos:	;return memory pos in HL of screen co-ord B,C (X,Y)
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
	or  &40				;&4000 screen base
	ld d,a
	ret

GetNextLine:			;Move HL down one line
	inc d
	ld a,d
	and   %00000111		;See if we're over the first 3rd
	ret nz
	ld a,e
	add a,%00100000
	ld e,a
	ret c				;See if we're over the 2'nd 3rd
	ld a,d
	sub   %00001000
	ld d,a
	ret

	
; Input  BC= XY (x=bytes - so 32 across)
; output HL= screen mem pos
GetColMemPos:			;YYYYYyyy 	Color ram is in 8x8 tiles 
	ld a,C							;so low three Y bits are ignored
		and %11000000	;YY------
		rlca
		rlca			;------YY
		add a,&58 		;5800 =color ram base
		ld d,a
	ld a,C
	and %00111000		;--YYY---
	rlca
	rlca				;YYY-----
	
	add a,b				;Add Xpos
	ld e,a
	ret



end ENTRY_POINT