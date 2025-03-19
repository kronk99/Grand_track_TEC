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
;;si y di va a tener las posiciones x,y del jugador 1.
mov si, 165  ; Posición Y inicial
mov di, 165  ; Posición X inicial

main_loop:
    call colition_checker
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

times 510-($-$$) db 0
dw 0AA55h  ; Boot signature

