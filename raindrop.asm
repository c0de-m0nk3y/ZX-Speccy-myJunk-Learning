; ASM data file from a ZX-Paintbrush picture with 8 x 8 pixels (= 1 x 1 characters)

; line based output of pixel data:

;raindrop struct ( x,y,speed,colour)
dropsdata:   
    db 104,0,8,0
    db 112,0,0,0
    db 120,0,0,0
    db 128,0,0,0
    db 136,0,0,0
    db 144,0,0,0
    db 152,0,0,0
    db 160,0,0,0
    db 168,0,0,0
    db 176,0,0,0


raindrop0:
db %00000000 
db %00000110
db %00001100 
db %00011000
db %00110000 
db %01110000
db %01110000 
db %00000000

raindrop1:
db %00000011 
db %00000110
db %00001100 
db %00011000
db %00110000 
db %01110000
db %11110000 
db %11111000

dropsdatalength EQU 4
numdrops    EQU 10
dropsdataoffset db 0
dropsloopiterator   db 0