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
    ld hl,heart
    ld (23675), hl

forever
    ld a, 0x90
    rst 16
    jp forever

include "customcharacters.asm"
end ENTRY_POINT
