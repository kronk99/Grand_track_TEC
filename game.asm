BITS 16]
[ORG 0x7C00]
%define SECTOR_AMOUNT 0x20;

mov ax, 0013h
int 10h  ; Modo de video 320x200 256 colores

push 0A000h
pop es   ; ES -> A0000h

mov al, 04h  ; VGA RED
mov cx, 320*200
xor di, di
rep stosb  ; Llena la pantalla con rojo


; ===========================
;           MAPA
; ===========================
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


; ===========================
; Configuración inicial de los bots
; ===========================

%define VIDEO_MEMORY 0xA000
%define SCREEN_WIDTH 320
%define SCREEN_HEIGHT 200
%define BOT_COLOR 0x0F
%define BOT_SPEED1 20
%define BOT_X 50
%define BOT_X2 60
%define BOT_Y 180

section .bss
    botsArr resw 2  ; Almacena la posición de los bots en memoria de video
    bot_state1 resb 1  ; Estado del recorrido del Bot 1
    bot_state2 resb 1  ; Estado del recorrido del Bot 2
    bot_timer1 resb 1
    bot_timer2 resb 1
    player_1_posX  resw 1
    player_1_posY  resw 1

section .text

    mov ax, VIDEO_MEMORY
    mov es, ax

    ; Inicializar posición de los bots
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
    mov byte [bot_timer1], 20
    mov byte [bot_timer2], 35

    mov word [player_1_posX], 165
    mov word [player_1_posY], 165 ;el error puede ser que debo hacer un mov byte


game_loop:
    ;;llama a los bots 
    dec byte [bot_timer1] ;decrementa en 8 bits
    jnz skip_update1 ;llama al update si no es 0 el valor en dir bot_timer
    mov byte [bot_timer1], 50
    call update_bot1
    
    mov bx, [player_1_posY]  ; Posición Y inicial ;cambiar el uso de si y di
    mov dx, [player_1_posX]  ; Posición X inicial
nextkey:
    mov ah, 01h       ; Esperar una tecla
    int 16h           ; Leer la tecla ; si es 0 , entonces ya se presionaron las teclas.
    jz finishkeypressed ; si no se presiono nada , se pone en 0 y hace el salto , osea si ya se proceso la interrupcion.
    mov ah, 00h
    int 0x16
    call handleKeys
    jmp nextkey
finishkeypressed: ;aca se van a actualizar los bots. 
    
    jmp game_loop
    
    ;call erase_square ; Borra el cuadro actual
handleKeys:
    cmp ah, 48h       ; Flecha arriba
    je move_up        ; Cambié jz por je

    cmp ah, 50h       ; Flecha abajo
    je move_down

    cmp ah, 4Bh       ; Flecha izquierda
    je move_left

    cmp ah, 4Dh       ; Flecha derecha
    je move_right

    ret    ; Si no es una flecha, sigue esperando

move_up:
    call erase_square ; Borra el cuadro actual
    sub bx, 1
    mov [player_1_posY],bx
    call colition_checker
    
    call draw_square  ; Dibuja el cuadro en la posición actual
    
    jmp nextkey

move_down:
    call erase_square ; Borra el cuadro actual
    
   
    add bx, 1
    mov [player_1_posY],bx
    call colition_checker

    call draw_square  ; Dibuja el cuadro en la posición actual
    jmp nextkey

move_left:
    call erase_square ; Borra el cuadro actual
   
    sub dx, 1
    mov [player_1_posX],dx 
    call colition_checker
    
    call draw_square  ; Dibuja el cuadro en la posición actual

    jmp nextkey

move_right:
    call erase_square ; Borra el cuadro actual
   
    add dx, 1
    mov [player_1_posX],dx 
    call colition_checker

    call draw_square  ; Dibuja el cuadro en la posición actual
    jmp nextkey

skip_update1:
    dec byte [bot_timer2]
    jnz skip_update2
    mov byte [bot_timer2], 75
    call update_bot2
skip_update2:

    mov cx, 0xFFFF

delay_loop:
    loop delay_loop
    jmp game_loop


; ===========================
;         BOT 1
; ===========================

update_bot1: ; PARA MOVER EL BOT 1
    mov si, botsArr
    mov ax, [si]
    cmp ax, 0
    je end_bot1

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
    cmp al, 3
    je bot1_3
    cmp al, 4
    je bot1_4
    cmp al, 5
    je bot1_5
    cmp al, 6
    je bot1_6
    jmp end_bot1

bot1_move_up: ;de (125,100) a (125,55) HACIA ARRIBA
    sub di, SCREEN_WIDTH
    cmp di, 55 * SCREEN_WIDTH + 125
    jl bot1_to_right ;manda a que se cambie el estado
    mov byte [es:di], BOT_COLOR
    mov [si], di
    jmp end_bot1 ;vuelve a la maquina de estados

bot1_to_right:
    mov byte [bot_state1], 1; cambia el estado
    mov [si], di
    jmp end_bot1; vuelve a la maquina de esta

bot1_move_right: ;2: de (125,55) a (195,55)
    inc di
    ; Obtener coordenada X (di % SCREEN_WIDTH)
    mov ax, di
    xor dx, dx
    mov bx, SCREEN_WIDTH
    div bx        ; AX = Y, DX = X
    cmp dx, 195   ; ¿Ya está en columna 195?
    ja bot1_to_down
    mov byte [es:di], BOT_COLOR
    mov [si], di
    jmp end_bot1


bot1_to_down: ; Cambia el estado
    mov byte [bot_state1], 2
    mov [si], di
    jmp end_bot1 ;vuelvo a la maquina

bot1_move_down: ;3: de (195,55) a (195,125)
    add di, SCREEN_WIDTH
    ; Obtener coordenada Y (di / SCREEN_WIDTH)
    mov ax, di
    xor dx, dx
    mov bx, SCREEN_WIDTH
    div bx
    cmp ax, 125   ; ¿Ya está en fila 125?
    ja bot1_to_3
    mov byte [es:di], BOT_COLOR
    mov [si], di
    jmp end_bot1


bot1_to_3: ; Cambia el estado
    mov byte [bot_state1], 3
    mov [si], di
    jmp end_bot1 ;vuelvo a la maquina

bot1_3: ;3: de (195,55) a (195,125) A LA DERECHA
    inc di
    ; Obtener coordenada X (di % SCREEN_WIDTH)
    mov ax, di
    xor dx, dx
    mov bx, SCREEN_WIDTH
    div bx        ; AX = Y, DX = X
    cmp dx, 235   ; ¿Ya está en columna 2355?
    ja bot1_to_4
    mov byte [es:di], BOT_COLOR
    mov [si], di
    jmp end_bot1

bot1_to_4: ; Cambia el estado
    mov byte [bot_state1], 4
    mov [si], di
    jmp end_bot1 ;vuelvo a la maquina

bot1_4: ;4: de (235,125) a (235,165) A abajo
    add di, SCREEN_WIDTH
    ; Obtener coordenada Y (di / SCREEN_WIDTH)
    mov ax, di
    xor dx, dx
    mov bx, SCREEN_WIDTH
    div bx
    cmp ax, 165   ; ¿Ya está en columna 2355?
    ja bot1_to_5
    mov byte [es:di], BOT_COLOR
    mov [si], di
    jmp end_bot1

bot1_to_5: ; Cambia el estado
    mov byte [bot_state1], 5
    mov [si], di
    jmp end_bot1 ;vuelvo a la maquina

bot1_5: ;5: de (235,165) a (125,165) ALA IZQUIERDA
    dec di
    ; Obtener coordenada X (di % SCREEN_WIDTH)
    mov ax, di
    xor dx, dx
    mov bx, SCREEN_WIDTH
    div bx        ; AX = Y, DX = X
    cmp dx, 125
    ;jbe remove_bot1
    jbe bot1_to_6
    mov byte [es:di], BOT_COLOR
    mov [si], di
    jmp end_bot1

bot1_to_6: ; Cambia el estado
    mov byte [bot_state1], 6
    mov [si], di
    jmp end_bot1 ;vuelvo a la maquina

bot1_6: ;6: de (125,165) a (125,100) ARRIBA
    sub di, SCREEN_WIDTH  ; restar una fila
    ; Obtener coordenada Y (di / SCREEN_WIDTH)
    mov ax, di
    xor dx, dx
    mov bx, SCREEN_WIDTH
    div bx
    cmp ax, 100 ;ya esta en y= 100? , aca ha de estar el error
    jbe bot1_to_1
    mov byte [es:di], BOT_COLOR
    mov [si], di
    jmp end_bot1
bot1_to_1: ;esto me cambia el estado
    mov byte [bot_state1], 0
    mov [si], di
    jmp end_bot1

remove_bot1:
    mov word [si], 0

end_bot1: ; Se llama en las funciones de movimiento para volver a la llamada de la maquina de estados.
    ret




; ===========================
;         BOT 2
; ===========================

update_bot2: ; PARA MOVER EL BOT 2
    mov si, botsArr + 2
    mov ax, [si]
    cmp ax, 0
    je end_bot2

    ; Borra píxel anterior
    mov di, ax
    mov byte [es:di], 4

    ; Estado actual
    mov al, [bot_state2]
    cmp al, 0
    je bot2_move_up
    cmp al, 1
    je bot2_move_right
    cmp al, 2
    je bot2_move_down
    cmp al, 3
    je bot2_3
    cmp al, 4
    je bot2_4
    cmp al, 5
    je bot2_5
    cmp al, 6
    je bot2_6
    jmp end_bot2

bot2_move_up: ; 0 de (130,100) a (130, 60) HACIA ARRIBA
    sub di, SCREEN_WIDTH
    cmp di, 60 * SCREEN_WIDTH + 130
    jl bot2_to_right ;manda a que se cambie el estado
    mov byte [es:di], BOT_COLOR
    mov [si], di
    jmp end_bot2 ;vuelve a la maquina de estados

bot2_to_right:
    mov byte [bot_state2], 1; cambia el estado
    mov [si], di
    jmp end_bot2; vuelve a la maquina de esta

bot2_move_right: ;1: de e (130, 60) a (190, 60)
    inc di
    ; Obtener coordenada X (di % SCREEN_WIDTH)
    mov ax, di
    xor dx, dx
    mov bx, SCREEN_WIDTH
    div bx        ; AX = Y, DX = X
    cmp dx, 190   ; ¿Ya está en columna 190?
    ja bot2_to_down
    mov byte [es:di], BOT_COLOR
    mov [si], di
    jmp end_bot2


bot2_to_down: ; Cambia el estado
    mov byte [bot_state2], 2
    mov [si], di
    jmp end_bot2 ;vuelvo a la maquina

bot2_move_down: ;2: de (190, 60) a (190, 135)
    add di, SCREEN_WIDTH
    ; Obtener coordenada Y (di / SCREEN_WIDTH)
    mov ax, di
    xor dx, dx
    mov bx, SCREEN_WIDTH
    div bx
    cmp ax, 125   ; ¿Ya está en fila 125?
    ja bot2_to_3
    mov byte [es:di], BOT_COLOR
    mov [si], di
    jmp end_bot2


bot2_to_3: ; Cambia el estado
    mov byte [bot_state2], 3
    mov [si], di
    jmp end_bot2 ;vuelvo a la maquina

bot2_3: ;3: de (190, 135) a (225, 135)
    inc di
    ; Obtener coordenada X (di % SCREEN_WIDTH)
    mov ax, di
    xor dx, dx
    mov bx, SCREEN_WIDTH
    div bx        ; AX = Y, DX = X
    cmp dx, 235   ; ¿Ya está en columna 225?
    ja bot2_to_4
    mov byte [es:di], BOT_COLOR
    mov [si], di
    jmp end_bot2

bot2_to_4: ; Cambia el estado
    mov byte [bot_state2], 4
    mov [si], di
    jmp end_bot2 ;vuelvo a la maquina

bot2_4: ;4: de (225, 135) a (225, 170)A abajo
    add di, SCREEN_WIDTH
    ; Obtener coordenada Y (di / SCREEN_WIDTH)
    mov ax, di
    xor dx, dx
    mov bx, SCREEN_WIDTH
    div bx
    cmp ax, 170   ; 
    ja bot2_to_5
    mov byte [es:di], BOT_COLOR
    mov [si], di
    jmp end_bot2

bot2_to_5: ; Cambia el estado
    mov byte [bot_state2], 5
    mov [si], di
    jmp end_bot2 ;vuelvo a la maquina

bot2_5: ;5: de de (225, 170) a (130, 170) ALA IZQUIERDA
    dec di
    ; Obtener coordenada X (di % SCREEN_WIDTH)
    mov ax, di
    xor dx, dx
    mov bx, SCREEN_WIDTH
    div bx        ; AX = Y, DX = X
    cmp dx, 130
    ;jbe remove_bot2
    jbe bot2_to_6
    mov byte [es:di], BOT_COLOR
    mov [si], di
    jmp end_bot2

bot2_to_6: ; Cambia el estado
    mov byte [bot_state2], 6
    mov [si], di
    jmp end_bot2 ;vuelvo a la maquina

bot2_6: ;6: de (125,165) a (125,100) ARRIBA
    sub di, SCREEN_WIDTH  ; restar una fila
    ; Obtener coordenada Y (di / SCREEN_WIDTH)
    mov ax, di
    xor dx, dx
    mov bx, SCREEN_WIDTH
    div bx
    cmp ax, 100
    jbe bot2_to_1
    mov byte [es:di], BOT_COLOR
    mov [si], di
    jmp end_bot2
bot2_to_1: ;esto me cambia el estado
    mov byte [bot_state2], 0
    mov [si], di
    jmp end_bot2
remove_bot2:
    mov word [si], 0

end_bot2: ; Se llama en las funciones de movimiento para volver a la llamada de la maquina de estados.
    ret


; ========================
; Función para dibujar el cuadro
; ========================
draw_square:
    
    mov si ,bx
    mov di, dx 
    push si
    push di
    push cx

    mov al, 02h  ; Color verde
    mov bx, si ;mueve a bx y
    mov dx, di; mueve a dx x
    mov di, bx ; mueve a di, y
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
    ;aca creo que debe de guardar de nuevo en memoria
    ret

; ========================
; Función para borrar el cuadro
; ========================
erase_square:
    ;mov di,[player_1_posX]
    ;mov si, [player_1_posY] 
    mov si ,bx
    mov di, dx 
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
        mov ax ,dx ;dx tiene elv alor de x, bx, tiene el valor de y
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
            mov dx, 165  ; Posición Y inicial
            mov bx, 165  ; Posición X inicial
            mov [player_1_posX] , dx
            mov [player_1_posY] , bx
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

dw 0xAA55