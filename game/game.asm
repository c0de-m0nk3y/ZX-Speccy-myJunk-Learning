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
    call start

main
    halt
    call deletesprites
    ;call sloppyclearscreen
    call update
    ;call debug
    jp main

sloppyclearscreen:
    call 0xdaf ;clear screen + open ch2
    ret

debug:
    call random
    rst 16

start:
    ;init screen
    call 0xdaf ;clear screen + open ch2
    ld a,3 ;choose border colour code
    call 0x229b ;sets border colour to a
    ret

;just deletes everything, no need to worry about screen memory layout
deletesprites:
    ;delete upper cars
    ld ix,uppervehicles
    ld b, MAX_VEHICLES
delcarsupperloop:
    push bc
    ld a,(ix)
    cp 0
    jr z,skipcarupper
    ld b,(ix+4)
    ld c,(ix+3)
    call yx2pix
    ld a,(ix+2)
    cp 0 ;pushbike
    call z, delsprite8
    cp 1 ;motorbike
    call z, delsprite16
    cp 2 ;truck
    call z, delsprite24
skipcarupper:
    pop bc
    djnz delcarsupperloop
    ret

delsprite8:
    push bc
    ld b, 8
del8loop:
    push af
    xor a
    ld (de),a
    call nextlinedown
    djnz del8loop
    pop af
    pop bc
    ret

delsprite16:
    push bc
    ld b, 16
del16loop:
    push af
    xor a
    ld (de),a
    inc e ;repeat because 2 bytes width
    ld (de),a
    dec e
    call nextlinedown
    djnz del16loop
    pop af
    pop bc
    ret

delsprite24:
    push bc
    ld b, 24
del24loop:
    push af
    xor a
    ld (de),a
    inc e ;repeat because 2 bytes width
    ld (de),a
    inc e ; repeat for the 3rd byte across
    ld (de),a
    dec e
    dec e
    call nextlinedown
    djnz del16loop
    pop af
    pop bc
    ret

update:
    ;update upper cars
    ld ix,uppervehicles
    ld b,MAX_VEHICLES
uppercarsupdateloop:
    dec b
    ld a,(ix) ;check 'isAlive'
    cp 0
    
    call z,checktospawncar ;if=0, check to see if random decides to spawn car
    jr z,loopnextupdate ;if=0, jp to next car
    push bc ;save b to stack
    ld a,(ix+3) ;get pos x into a
    add a,(ix+1) ;apply speed to it
    ld (ix+3),a ;set the new pos x
    ld b,(ix+4) ;get y pos, ready for sprite drawing routine
    ld c,(ix+3) ;get x pos also
    ld a, (ix+2) ;next we care about the 3rd byte, the sprite index
    cp 0 ;pushbike
    call z, ldbike
    call z, drawsprite8
    cp 1 ;motorbike
    call z,ldmotorbike
    call z, drawsprite16
    cp 2 ;truck
    call z, ldtruck
    call z, drawsprite24
    pop bc ;get back b from stack
    ld a,b ;check if b=0...
    cp 0
    jr nz, loopnextupdate ;...and loop if not
endupdateloop:
    ret

loopnextupdate:
    ld de,BYTES_PER_VEHICLE ;get number of bytes in each vehicles data
    add ix,de ;increase ix by that many bytes, ready to next car
    ld a,b
    cp 0
    jr nz, uppercarsupdateloop
    jr z, endupdateloop

checktospawncar:
    call random ;put random number in a
    ld c,a ;move random value into c 
    ld a,(currentspawnchance)
    cp c ;compare with difficulty currentspawnchance
    call c, spawncarupper ;if a < spawnchance, then spawn
    ret

spawncarupper:
    ld b, MAX_VEHICLES
    ld ix,uppervehicles
alivecheck:
    ld a,(ix)
    cp 0
    jr z, spawnit
    ld de, BYTES_PER_VEHICLE
    add ix,de
    djnz alivecheck
    ret
spawnit:
    ld a,1
    ld (ix),a ; set isalive to 1 for this car
    call random ;set a to random number
    and TOTAL_VEHICLE_TYPES
    ld (ix+2),a ;set random vehicle TOTAL_VEHICLE_TYPES
    call random ;set a to rand number
    ld a, UPPER_LANE_X
    ld (ix+3), a ;set pos x to correct position
    call random
    ;add a, UPPER_LANE_Y ; add the upperlane y base point
    ld (ix+4),a ;set pos y
    ret


ldbike:
    ld hl,pushbike8
    ret

ldmotorbike:
    ld hl,motorbike
    ret

ldtruck:
    ld hl,truck
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




; Simple pseudo-random number generator.
; Steps a pointer through the ROM (held in seed), returning
; the contents of the byte at that location.
;inputs: none
;outputs: a = random number
random: 
    ld hl,(seed) ; Pointer
    ld a,h
    and %00011111 ; keep it within first 8k of ROM.
    ld h,a
    ld a,(hl) ; Get "random" number from location.
    inc hl ; Increment pointer.
    ld (seed),hl
    ret
seed defw 0



currentspawnchance  db 1
UPPER_LANE_X  EQU 0
UPPER_LANE_Y  EQU 50

include "screentools.asm"
include "vehicles.asm"
end ENTRY_POINT
