[BITS 16]
[ORG 0x7C00]

mov ax, 0013h
int 10h  ; Modo de video 320x200 256 colores

push 0A000h
pop es   ; ES -> A0000h

mov al, 04h  ; Color rojo para el fondo
mov cx, 320*200
xor di, di
rep stosb  ; Llena la pantalla con rojo


; Dibujar primera línea negra (y = 50, ancho = 50 píxeles, movida 15 píxeles a la derecha)
mov di, 50 * 320 + 120  ; Nueva posición inicial en (150,50)
mov cx, 80              ; Largo de la línea
mov al, 0               ; Color negro
rep stosb               ; Dibuja la línea

; Dibujar segunda línea negra (y = 65, ancho = 50 píxeles)
mov di, 65 * 320 + 135  ; Calcula la posición inicial en (135,65)
mov cx, 50              ; Largo de la línea
mov al, 0               ; Color negro
rep stosb               ; Dibuja la línea

; Dibujar línea vertical de 70 píxeles donde termina la segunda línea horizontal (x = 185, y = 65)
mov cx, 70              ; Altura de la línea
mov di, 65 * 320 + 185  ; Posición inicial en (185,65)
mov al, 0               ; Color negro
linea_vertical:
mov [es:di], al         ; Pinta un píxel en la posición actual
add di, 320             ; Mueve a la siguiente fila (manteniendo la misma columna)
loop linea_vertical     ; Repite hasta completar la línea

; Dibujar segunda línea vertical de 85 píxeles (x = 200, y = 50)
mov cx, 70              ; Altura de la línea
mov di, 50 * 320 + 200  ; Posición inicial en (200,50)
mov al, 0               ; Color negro
linea_vertical_2:
mov [es:di], al         ; Pinta un píxel en la posición actual
add di, 320             ; Mueve a la siguiente fila (manteniendo la misma columna)
loop linea_vertical_2   ; Repite hasta completar la línea

; Dibujar línea horizontal de 40
; Dibujar línea horizontal de 40 píxeles en (185,135)
mov cx, 40              ; Longitud de la línea
mov di, 135 * 320 + 185 ; Posición inicial en (185,135)
mov al, 0               ; Color negro
linea_horizontal_3:
mov [es:di], al         ; Pinta un píxel
inc di                  ; Mueve a la siguiente posición en la misma fila (derecha)
loop linea_horizontal_3 ; Repite hasta completar la línea

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


; ========================
; Cuadro móvil
; ========================
mov si, 100  ; Posición Y inicial
mov di, 170  ; Posición X inicial

main_loop:
    call draw_square  ; Dibuja el cuadro en la posición actual

    mov ah, 00h       ; Esperar una tecla
    int 16h           ; Leer la tecla

    call erase_square ; Borra el cuadro actual

    cmp ah, 48h       ; Flecha arriba
    je move_up

    cmp ah, 50h       ; Flecha abajo
    je move_down

    cmp ah, 4Bh       ; Flecha izquierda
    je move_left

    cmp ah, 4Dh       ; Flecha derecha
    je move_right

    jmp main_loop     ; Si no es una flecha, sigue esperando

move_up:
    cmp si, 0         ; Límite superior
    jbe main_loop
    sub si, 1
    jmp main_loop

move_down:
    cmp si, 196       ; Límite inferior (200 - 4 del cuadro)
    jae main_loop
    add si, 1
    jmp main_loop

move_left:
    cmp di, 0         ; Límite izquierdo
    jbe main_loop
    sub di, 1
    jmp main_loop

move_right:
    cmp di, 316       ; Límite derecho (320 - 4 del cuadro)
    jae main_loop
    add di, 1
    jmp main_loop

; ========================
; Función para dibujar el cuadro
; ========================
draw_square:
    push si
    push di
    push cx

    mov al, 02h  ; Color verde
    mov bx, si
    mov dx, di
    mov di, bx
    imul di, 320  ; Calcular posición Y
    add di, dx    ; Calcular posición X
    mov cx, 4     ; Altura

draw_fila:
    push cx
    mov cx, 4     ; Ancho
    push di

draw_columna:
    mov [es:di], al
    inc di
    loop draw_columna

    pop di
    add di, 320
    pop cx
    loop draw_fila

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

cli
hlt

times 510-($-$$) db 0
dw 0AA55h  ; Boot signature

