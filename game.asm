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



    call 0xdaf ;clear screen + open ch2
    ld a,3 ;choose border colour code
    call 0x229b ;sets border colour to a

forever
    jp forever


end ENTRY_POINT
