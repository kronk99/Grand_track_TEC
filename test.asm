[BITS 16]
[ORG 0x7C00]

mov ax, 0013h
int 10h  ; Modo de video 320x200 256 colores

push 0A000h
pop es   ; ES -> A0000h

mov al, 04h  ; VGA RED
mov cx, 320*200
xor di, di
rep stosb  ; Llena la pantalla con rojo

; Dibujar las líneas del mapa
mov di, 50 * 320 + 120
mov cx, 80
mov al, 0
rep stosb

mov di, 65 * 320 + 135
mov cx, 50
mov al, 0
rep stosb

mov cx, 70
mov di, 65 * 320 + 185
mov al, 0
linea_vertical:
mov [es:di], al
add di, 320
loop linea_vertical

mov cx, 70
mov di, 50 * 320 + 200
mov al, 0
linea_vertical_2:
mov [es:di], al
add di, 320
loop linea_vertical_2

mov cx, 40
mov di, 135 * 320 + 185
mov al, 0
linea_horizontal_3:
mov [es:di], al
inc di
loop linea_horizontal_3


; Dibujar línea horizontal de 40 píxeles en (200,120)
mov cx, 40              ; Longitud de la línea
mov di, 120 * 320 + 200 ; Posición inicial en (200,120)
mov al, 0               ; Color negro
linea_horizontal_4:
mov [es:di], al         ; Pinta un píxel
inc di                  ; Mueve a la siguiente posición en la misma fila (derecha)
loop linea_horizontal_4 ; Repite hasta completar la línea


mov cx, 25              ; Altura de la línea
mov di, 135 * 320 + 225 ; Posición inicial en (225,135)
mov al, 0               ; Color negro
linea_vertical_3:
mov [es:di], al         ; Pinta un píxel en la posición actual
add di, 320             ; Mueve a la siguiente fila (misma columna)
loop linea_vertical_3   ; Repite hasta completar la línea


mov cx, 55              ; Altura de la línea
mov di, 120 * 320 + 240 ; Posición inicial en (240,120)
mov al, 0               ; Color negro
linea_vertical_4:
mov [es:di], al         ; Pinta un píxel en la posición actual
add di, 320             ; Mueve a la siguiente fila (misma columna)
loop linea_vertical_4   ; Repite hasta completar la línea

; Línea vertical desde (135,65) hasta (135,159)
mov cx, 95              ; Altura de la línea
mov di, 65 * 320 + 135  ; Posición inicial en (135,65)
mov al, 0               ; Color negro
linea_vertical_5:
    mov [es:di], al     ; Pinta un píxel en la posición actual
    add di, 320         ; Mueve a la siguiente fila (misma columna)
    loop linea_vertical_5   ; Repite hasta completar la línea

; Línea horizontal conectando linea_vertical_5 con linea_vertical_3
mov cx, 90              ; Longitud de la línea
mov di, 159 * 320 + 135 ; Posición inicial en (135,159)
mov al, 0               ; Color negro
linea_horizontal_7:
    mov [es:di], al     ; Pinta un píxel en la posición actual
    inc di              ; Mueve a la derecha en la misma fila
    loop linea_horizontal_7   ; Repite hasta completar la línea

; Línea vertical desde (120,50) hasta (240,174)
mov cx, 125             ; Altura de la línea
mov di, 50 * 320 + 120  ; Posición inicial en (120,50)
mov al, 0               ; Color negro
linea_vertical_6:
    mov [es:di], al     ; Pinta un píxel en la posición actual
    add di, 320         ; Mueve a la siguiente fila (misma columna)
    loop linea_vertical_6   ; Repite hasta completar la línea


; Línea horizontal conectando linea_vertical_6 con la línea en (120,50)
mov cx, 120              ; Longitud de la línea
mov di, 174 * 320 + 120 ; Posición inicial en (120,174)
mov al, 0               ; Color negro
linea_horizontal_8:
    mov [es:di], al     ; Pinta un píxel en la posición actual
    inc di              ; Mueve a la derecha en la misma fila
    loop linea_horizontal_8   ; Repite hasta completar la línea

mov cx, 15              ; Longitud de la línea
mov di, 100 * 320 + 120  ; Posición inicial en (120,100)
mov al, 1               ; Color azul en modo 13h (VGA 256 colores)
linea_meta:
    mov [es:di], al     ; Pinta un píxel en la posición actual
    inc di              ; Mueve a la derecha en la misma fila
    loop linea_meta   ; Repite hasta completar la línea

; Configuración inicial de los bots
%define VIDEO_MEMORY 0xA000
%define SCREEN_WIDTH 320
%define SCREEN_HEIGHT 200
%define BOT_COLOR 0x0F
%define BOT_SPEED1 20
%define BOT_X 50
%define BOT_X2 60
%define BOT_Y 180

section .bss
    botsArr resw 2
    bot_timer1 resb 1
    bot_timer2 resb 1

section .text

    mov ax, VIDEO_MEMORY
    mov es, ax

    mov ax, 100
    mov bx, SCREEN_WIDTH
    mul bx
    add ax, 125
    mov word [botsArr], ax
    mov ax, 100
    mul bx
    add ax, 130
    mov word [botsArr + 2], ax

    mov byte [bot_timer1], 20
    mov byte [bot_timer2], 35

game_loop:
    dec byte [bot_timer1]
    jnz skip_update1
    mov byte [bot_timer1], 20
    call update_bot1
skip_update1:
    dec byte [bot_timer2]
    jnz skip_update2
    mov byte [bot_timer2], 35
    call update_bot2
skip_update2:

    mov cx, 0xFFFF
    delay_loop:
    loop delay_loop

    jmp game_loop

update_bot1:
    mov si, botsArr
    mov ax, [si]
    cmp ax, 0
    je end_bot1

    mov di, ax
    mov byte [es:di], 4

    sub di, SCREEN_WIDTH
    cmp di, (BOT_Y - 50) * SCREEN_WIDTH
    jl remove_bot1

    mov byte [es:di], BOT_COLOR
    mov [si], di
    jmp end_bot1

remove_bot1:
    mov word [si], 0

end_bot1:
    ret

update_bot2:
    mov si, botsArr + 2
    mov ax, [si]
    cmp ax, 0
    je end_bot2

    mov di, ax
    mov byte [es:di], 4

    sub di, SCREEN_WIDTH
    cmp di, (BOT_Y - 50) * SCREEN_WIDTH
    jl remove_bot2

    mov byte [es:di], BOT_COLOR
    mov [si], di
    jmp end_bot2

remove_bot2:
    mov word [si], 0

end_bot2:
    ret

times 510-($-$$) db 0
dw 0xAA55
