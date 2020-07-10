;mapsprites
;all game environment sprites

; ASM data file from a ZX-Paintbrush picture with 32 x 16 pixels (= 4 x 2 characters)

; line based output of pixel data:
hatshop:
    db %00001111, %11111111, %11111111, %11111111
    db %00010001, %11110001, %11100011, %11000011
    db %00100011, %11100011, %11000111, %10000101
    db %01000111, %11000111, %10001111, %00001001
    db %10001111, %10001111, %00011110, %00010001
    db %11111111, %11111111, %11111111, %11100001
    db %10000000, %00000000, %00000000, %00100001
    db %10100010, %11110111, %11011110, %10100001
    db %10100010, %10010001, %00010000, %10100001
    db %10100010, %10010001, %00010000, %10100001
    db %10100010, %10010001, %00011110, %10100001
    db %10111110, %11110001, %00000010, %10100001
    db %10100010, %10010001, %00000010, %10100010
    db %10100010, %10010001, %00000010, %00100100
    db %10100010, %10010001, %00011110, %10101000
    db %10000000, %00000000, %00000000, %00110000

;8x8 colour attribute data (only changes each line)
backgroundattributes:
    db %00111000 ;white paper,black ink
    db %00111000 ;white paper,black ink
    db %00111000 ;white paper,black ink
    db %00000111 ;black paper,white ink
    db %00000111 ;black paper,white ink
    db %00000111 ;black paper,white ink
    db %00000111 ;black paper,white ink
    db %00000111 ;black paper,white ink
    db %00000111 ;black paper,white ink
    db %00000111 ;black paper,white ink
    db %00000111 ;black paper,white ink
    db %00000111 ;black paper,white ink
    db %00000111 ;black paper,white ink
    db %00000111 ;black paper,white ink
    db %00000111 ;black paper,white ink
    db %00000111 ;black paper,white ink
    db %00000111 ;black paper,white ink
    db %00000111 ;black paper,white ink
    db %00000111 ;black paper,white ink
    db %00000111 ;black paper,white ink
    db %00000111 ;black paper,white ink
    db %00111000 ;white paper,black ink
    db %00111000 ;white paper,black ink
    db %00111000 ;white paper,black ink
    