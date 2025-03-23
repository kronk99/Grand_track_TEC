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
    player_1_posX  resb 1
    player_1_posY  resb 1

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
    ;==============PLAYERS POSITION SETTINGS=================================================
    mov byte [bot_timer1], 20 ;velocidades de los bots, timer de cada bot
    mov byte [bot_timer2], 35
    ;
    mov si, 165  ; Posición Y inicial
    mov di, 165  ; Posición X inicial
    
    mov [player_1_posX], si
    mov [player_1_posY], di


game_loop: ;;llama a los bots 
    dec byte [bot_timer1] ;decrementa en 8 bits
    jnz skip_update1 ;llama al update si no es 0 el valor en dir bot_timer
    mov byte [bot_timer1], 50
    call update_bot1
    ;cargo las posiciones de los jugadores antes de checkear las interrupciones, colisiones
    ;y demas cosas

    mov si, [player_1_posX]  ; Posición Y inicial
    mov di, [player_1_posY]  ; Posición X inicial

    call colition_checker
    call draw_square  ; Dibuja el cuadro en la posición actual


    

    mov ah, 0x00       ; Esperar una tecla
    int 16h           ; Leer la tecla

    call erase_square ; Borra el cuadro actual

    cmp ah, 0x4d       ; Flecha arriba
    je move_up


    jmp game_loop     ; Si no es una flecha, sigue esperando
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

move_up:
    cmp si, 0         ; Límite superior
    jbe game_loop
    sub si, 1
    mov [player_1_posX],si
    jmp game_loop

move_down:
    cmp si, 196       ; Límite inferior (200 - 4 del cuadro)
    jae game_loop
    add si, 1
    mov [player_1_posX],si
    jmp game_loop

move_left:
    cmp di, 0         ; Límite izquierdo
    jbe game_loop
    sub di, 1
    mov [player_1_posX],di 
    jmp game_loop

move_right:
    cmp di, 316       ; Límite derecho (320 - 4 del cuadro)
    jae game_loop
    add di, 1
    mov [player_1_posX],di  ; Posición Y inicial
     
    jmp game_loop

; ========================
; Función para dibujar el cuadro
; ========================
draw_square:
    push si
    push di
    push cx

    mov al, 02h  ; Color verde
    mov bx, si ;mueve a bx si
    mov dx, di; mueve a dx di
    mov di, bx ; mueve a di, si
    imul di, 320  ; Calcular posición Y, multiplicacion con signo , obtengo pos en memoria
    add di, dx    ; Calcular posición X, a di le suma dx , le sumo
    ;en x para encontrar pos x en memoria de video
    mov cx, 4     ; Altura

draw_fila:
    push cx ;empujo 4 a la pila
    mov cx, 4     ; Ancho
    push di ;mete en el stack mi posicion actual en la matriz de video.
    ;recuerde , se agarra fila *320 +col para obtener posicion actual.

draw_columna:; pinta horizontalmente.
    mov [es:di], al
    inc di
    loop draw_columna ;loopea hasta pintar 4 pixeles , loop usa cx , que es el contador.

    pop di ;devuelve mi posicion actual en la pila
    add di, 320 ;le suma 320 para cambiar de fila,
    pop cx ;devuelve el valor de cx, osea el contador
    loop draw_fila ;decrementa en 1 el valor de cx, por eso lo meto en la pila de nuevo
    ;al regresar con push cx, el valor seria 3.

    pop cx
    pop di
    pop si
    ret

; ========================
; Función para borrar el cuadro
; ========================
erase_square:
    push si
    push di
    push cx

    mov al, 04h  ; Color de fondo (rojo)
    mov bx, si
    mov dx, di
    mov di, bx
    imul di, 320
    add di, dx
    mov cx, 4

erase_fila:
    push cx
    mov cx, 4
    push di

erase_columna:
    mov [es:di], al
    inc di
    loop erase_columna

    pop di
    add di, 320
    pop cx
    loop erase_fila

    pop cx
    pop di
    pop si
    ret
colition_checker:;muevo los valores del jugador 1
        mov ax ,di
        mov bx ,si
        cmp ax, 200
        jae colition_segment_2 ;compara si es mayor que la linea x 200
        ;si no hace las siguientes comparaciones del segmento 1
        cmp ax , 120
        jbe collition ;salta a collition si x es menor que 120, limite izquierdo
        ;si no sigue comparando con el limite de abajo
        cmp bx , 174 ;compara la y actual con 174. linea horizontal de abajo , limite inferior
        jae collition ;si es mayor, entonces colision
        ;comparo ahora con el limite superior:
        cmp bx , 50 ;comparo con el limite superior
        jbe collition ;si es menor, colision

        ;si no hubo colision en lo anterior entonces ahora checke para el segmento 4
        ;=====================segment collition 4 ===================================
        ;para el segmento 2 solo tiene sentido checkear si x esta en el rango x de
        ;las lineas horizontales 2 y 7
        
        cmp ax, 135 ;comparo el primer x1 horizontal
        jb return ;si es menor ,no tiene sentido checkear ; si es mayor , checkea el otro punto
        cmp ax, 185 
        jbe segment_4_vertical ;si es menor o igual , checkeo verticales
        ;si no es menor, es que es mayor y paso a checkear segmento 5
        ; ========================SEGMENT COLLITION 5=============================
        segment_5:
            cmp bx, 159 ;valor anterior 174
            ja return ;si es mayor, no hay colision
            
            cmp bx, 135 ;compara con la linea horizontal 3 , el y
            jb return ;si es menor, no tiene sentido la colision se va va a colition
            ;si no salta implica que es mayor, checkeo a ver si es menor a la linea baja 
            ;del segmento 5, linea horizontal 7
        ;si no , si hay colision.
        collition:
            mov si, 165  ; Posición Y inicial
            mov di, 165  ; Posición X inicial
        return: 
            ret
        
        segment_4_vertical:
            cmp bx, 65
            jb return
            cmp bx, 159
            jbe collition
            ret



        colition_segment_2:
            cmp ax,240
            jae collition ;si es mayor que 240 collisiona
            ;si no , verifico que no sea mayor a 120
            cmp bx, 120
            jbe collition  ; si es menor, entonces colisiona
            ;si no entonces checkea el segmento 3

        colition_segment_3:
            cmp ax, 225
            ja return ;si es mayor , retorna  ,si no checkeo arriba y abajo de cuadro 3
        ;  ;checkeo arriba
            cmp bx, 159
            ja return
            cmp bx, 135
            jae collition
        ret

cli
hlt

;times 510-($-$$) db 0
dw 0xAA55