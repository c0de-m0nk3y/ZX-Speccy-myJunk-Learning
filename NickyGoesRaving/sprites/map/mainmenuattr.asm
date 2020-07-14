;menu colour attributes

;spells the name of the game in background cells (a la Horace)
menu_nicky:
    ;Nicky
    db 7,1
    db 10,1
    db 12,1
    db 14,1
    db 15,1
    db 16,1
    db 18,1
    db 20,1
    db 22,1
    db 24,1
    db 7,2
    db 8,2
    db 10,2
    db 12,2
    db 14,2
    db 18,2
    db 19,2
    db 22,2
    db 23,2
    db 24,2
    db 7,3
    db 9,3
    db 10,3
    db 12,3
    db 14,3
    db 18,3
    db 20,3
    db 24,3
    db 7,4
    db 10,4
    db 12,4
    db 14,4
    db 15,4
    db 16,4
    db 18,4
    db 20,4
    db 22,4
    db 23,4
    db 24,4
    db 255
menu_goes:
    db 9,6
    db 10,6
    db 14,6
    db 18,6
    db 19,6
    db 22,6
    db 23,6
    db 9,7
    db 13,7
    db 15,7
    db 17,7
    db 21,7
    db 8,8
    db 10,8
    db 11,8
    db 13,8
    db 15,8
    db 17,8
    db 18,8
    db 22,8
    db 9,9
    db 11,9
    db 13,9
    db 15,9
    db 17,9
    db 23,9
    db 9,10
    db 10,10
    db 14,10
    db 18,10
    db 19,10
    db 21,10
    db 22,10
    db 255 ;signals end of data
menu_raving:
    db 4,3
    db 5,3
    db 6,3
    db 7,3
    db 10,3
    db 13,3
    db 15,3
    db 17,3
    db 19,3
    db 22,3
    db 24,3
    db 25,3
    db 26,3
    db 27,3
    db 4,4
    db 7,4
    db 9,4
    db 11,4
    db 13,4
    db 15,4
    db 17,4
    db 19,4
    db 20,4
    db 22,4
    db 24,4
    db 4,5
    db 5,5
    db 6,5
    db 9,5
    db 10,5
    db 11,5
    db 13,5
    db 15,5
    db 17,5
    db 19,5
    db 20,5
    db 21,5
    db 22,5
    db 24,5
    db 26,5
    db 27,5
    db 4,6
    db 7,6
    db 9,6
    db 11,6
    db 13,6
    db 14,6
    db 15,6
    db 17,6
    db 19,6
    db 21,6
    db 22,6
    db 24,6
    db 27,6
    db 4,7
    db 7,7
    db 9,7
    db 11,7
    db 14,7
    db 17,7
    db 19,7
    db 22,7
    db 24,7
    db 25,7
    db 26,7
    db 27,7
    db 255



; colours an entire line each byte
menubackgroundattr:
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
    db %00000111 ;black paper,white ink
    db %00000111 ;black paper,white ink
    db %00000111 ;black paper,white ink
    db %00000111 ;black paper,white ink
    db %00000111 ;black paper,white ink
    db %00000111 ;black paper,white ink

