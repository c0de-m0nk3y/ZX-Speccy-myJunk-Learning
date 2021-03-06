; things i want to learn:
; how to work at bits (cp, ld etc for bools for example isalive)
; figure exactly why xy is backwards. (Are bytes in pairs store backwards?)



;tables of vehicles
;5 elements (max vehicles at one time)
; 5 bytes per element
; byte 0: 0=dead, otherwise alive
; byte 1: speed
; byte 2: sprite index (0=pushbike;1=motorbike;2=truck)
; byte 3: x
; byte 4: y (offset from lane-spawn point)
uppervehicles:
    db 0, 1, 0, 0, 0
    db 0, 1, 0, 0, 0
    db 0, 1, 0, 0, 0
    db 0, 1, 0, 0, 0
    db 0, 1, 0, 0, 0
lowervehicles:
    db 0, 5, 0, 0, 0
    db 0, 5, 0, 0, 0
    db 0, 5, 0, 0, 0
    db 0, 5, 0, 0, 0
    db 0, 5, 0, 0, 0

TOTAL_VEHICLE_TYPES EQU %00000011 ;one less to make random number easier
MAX_VEHICLES EQU 0
BYTES_PER_VEHICLE EQU 5



pushbike8: 
    db %00011000
    db %00011001
    db %00011010
    db %11011110
    db %00111010
    db %11111111
    db %10100101
    db %11100111

motorbike:
    db %00000011, %11000000
    db %00000111, %11100000
    db %00000110, %00000000
    db %00000111, %11100000
    db %00001011, %11000000
    db %00000110, %01000000
    db %00001111, %00010100
    db %11001111, %11111100
    ;
    db %01111111, %11111000
    db %00111111, %11111000
    db %01111111, %11111100
    db %11011111, %11110110
    db %10111111, %11101010
    db %10101011, %00101010
    db %11011001, %10110110
    db %01110000, %00011100

truck:
    db %00000000, %00000000, %00000000
    db %00000000, %00000000, %00000000
    db %00000000, %00000000, %00000000
    db %00000000, %00000000, %00000000
    db %00000000, %00000000, %00000000
    db %00000000, %11111111, %00000000
    db %00000000, %11111111, %00000000
    db %00000000, %11111111, %00000000
    db %00000001, %00001111, %00000000
    db %00000011, %00001111, %00000000
    db %00000111, %00001111, %00000000
    db %00001111, %00001111, %00000000
    db %00111111, %00001111, %00000000
    db %11111111, %11111111, %00000000
    db %11111111, %11111111, %11111111
    db %11111111, %11111111, %11111111
    db %11111111, %11111111, %11111111
    db %10000001, %11111111, %11111111
    db %00000000, %11111111, %11100011
    db %00000000, %11111111, %10000001
    db %00000000, %11111111, %00000000
    db %00000000, %00000000, %00000000
    db %10000001, %00000000, %10000001
    db %11000011, %00000000, %11000011

; line based output of attribute data:
truckcolors:
    db %01111000, %01111010, %01111000
    db %01111010, %01001010, %01111010
    db %01000010, %01111010, %01000010
