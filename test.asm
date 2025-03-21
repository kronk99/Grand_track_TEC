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
;;se quema la velocidad
%define BOT_X 50
%define BOT_X2 60
%define BOT_Y 180
;;============================================SETUP BOTS=======================================================================
section .bss ;definicion de maquinas de estados 
    botsArr resw 2  ; Almacena la posición de los bots en memoria de video
    bot_state1 resb 1  ; Estado del recorrido del Bot 1
    bot_state2 resb 1  ; Estado del recorrido del Bot 2
    bot_timer1 resb 1
    bot_timer2 resb 1

section .text

    mov ax, VIDEO_MEMORY
    mov es, ax

    ;================================ Inicializar posición de los bots======================================

    mov ax, 100
    mov bx, SCREEN_WIDTH
    mul bx 
    add ax, 125
    mov word [botsArr], ax      ; Bot 1 en (125,100)
    mov word [bot_state1], 0    ; Estado inicial del bot 1

    mov ax, 100
    mul bx
    add ax, 130
    mov word [botsArr + 2], ax  ; Bot 2 en (130,100)
    mov word [bot_state2], 0    ; Estado inicial del bot 2

    ; Inicializar temporizadores de movimiento
    mov byte [bot_timer1], 20 ;velocidades de los bots, timer de cada bot
    mov byte [bot_timer2], 35

game_loop: ;;llama a los bots 
    dec byte [bot_timer1] ;decrementa en 8 bits
    jnz skip_update1 ;llama al update si no es 0 el valor en dir bot_timer
    mov byte [bot_timer1], 50
    call update_bot1
skip_update1:
    dec byte [bot_timer2]
    jnz skip_update2
    mov byte [bot_timer2], 65
    call update_bot2
skip_update2:

    mov cx, 0xFFFF
    delay_loop:
    loop delay_loop

    jmp game_loop

update_bot1:
    mov si, botsArr ;carga la pos en pantallla
    mov ax, [si] ;carga la pos en pantalla , la pos esta en la dir boot array
    cmp ax, 0 ;verifica si es dif de 0 
    je end_bot1 ;si esta en 0 lo mata

    ; Borra píxel anterior
    mov di, ax
    mov byte [es:di], 4

    ; Estado actual
    mov al, [bot_state1]
    cmp al, 0
    je bot1_move_up
    cmp al, 1
    je bot1_move_right
    cmp al, 2
    je bot1_move_down
    jmp end_bot1

bot1_move_up:
    sub di, SCREEN_WIDTH
    cmp di, 55 * SCREEN_WIDTH + 125
    jl bot1_to_right
    ;esto es para pintarlo hasta el estado de moverlo a la derecha
    mov byte [es:di], BOT_COLOR
    mov [si], di
    jmp end_bot1

bot1_to_right:
    mov byte [bot_state1], 1
    mov [si], di ; le actualiza el estado de la direccion
    jmp end_bot1

bot1_move_right:
    inc di
    ; Obtener coordenada X (di % SCREEN_WIDTH)
    mov ax, di
    xor dx, dx
    mov bx, SCREEN_WIDTH
    div bx        ; AX = Y, DX = X
    cmp dx, 195   ; ¿Ya está en columna 195? 195,125
    ja bot1_to_down
    mov byte [es:di], BOT_COLOR
    mov [si], di
    jmp end_bot1


bot1_to_down:
    mov byte [bot_state1], 2
    mov [si], di
    jmp end_bot1

bot1_move_down:
    add di, SCREEN_WIDTH
    ; Obtener coordenada Y (di / SCREEN_WIDTH)
    mov ax, di
    xor dx, dx
    mov bx, SCREEN_WIDTH
    div bx
    cmp ax, 125   ; ¿Ya está en fila 125?
    ja remove_bot1
    mov byte [es:di], BOT_COLOR
    mov [si], di
    jmp end_bot1


remove_bot1:
    mov byte [bot_state1], 3
    mov word [si], 0
end_bot1:
    ret


update_bot2:
    ;1 palabra = 4 
    
    mov si, botsArr + 2 ; cargo en memoria la posicion 0x0000algo , le suma 2 0x00002+algo
    mov ax, [si]   ; aca se trae la posicion x,y de memoria, que es un numero para pintar
    ;en memoria , recuerde posactual = fila*#columnas + col actual.

    ;stand by , recuperar si el codigo muere

    ;cmp ax, 0
    ;je end_bot2

    ; Borra el bot en la posición actual
    mov di, ax
    mov byte [es:di], 4 ;color transparente 
    
    ; Verifica el estado del bot 2
    mov al, [bot_state2] ;trae de memoria lo que haya en bot state
    cmp al, 0 ;compara si el estado es 0
    je moveup
    cmp al,1
    je move_right_bot2
    cmp al,3
    je end_bot2
moveup:
    sub di, SCREEN_WIDTH
    cmp di, 60 * SCREEN_WIDTH + 130  ; Límite (130,60)
    jl switch_to_right_bot2
    ;cuando el estado no sea 0 se mueve a la derecha
    ;esto se cambia cuando hayan mas estados, debido a que siempre va a tener un estado
    ;diferente de 0 al recorrer el mapa
     ; si el estado es 0, se mueve a la derecha

    ; Movimiento vertical hacia arriba
    sub di, SCREEN_WIDTH
    cmp di, 60 * SCREEN_WIDTH + 130  ; Límite (130,60)
    jl switch_to_right_bot2 ;si es menor que 60 , va a cambiar estado a moverme derecha

    mov byte [es:di], BOT_COLOR
    mov [si], di
    jmp end_bot2

switch_to_right_bot2: ;movimiento hacia a la derecha
    mov byte [bot_state2], 1  ; Cambiar a movimiento horizontal
move_right_bot2:
    inc di  ; di tiene la coordenada  x,y , recuerde es un numero completo
    cmp di, 60 * SCREEN_WIDTH + 190  ; Límite (190,60) ;compara si el limite es 190 horizontal
    jg remove_bot2 ;si se pasa, borra el bot

    mov byte [es:di], BOT_COLOR ;lo pinta cuadro a cuadro
    mov [si], di ;guarda la ultima direccion que quede
    jmp end_bot2

remove_bot2:
    mov byte [bot_state2], 3 ;++++++++++ANADI ESTO EL ESTADO 3 ES PARA FINALIZAR Y QUE NO MUERA ++++++++
    mov word [si], 0
end_bot2:
    ret

times 510-($-$$) db 0
dw 0xAA55
