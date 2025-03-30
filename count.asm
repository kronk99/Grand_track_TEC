[BITS 16]              ; Indica que el código se ejecuta en modo real de 16 bits
[ORG 0x7C00]           ; Dirección estándar donde el BIOS carga el bootloader (0x7C00)

start:
    ; Configuración inicial de los registros de segmento
    MOV AX, 0x0000     ; Carga 0 en AX
    MOV DS, AX         ; Data Segment = 0
    MOV ES, AX         ; Extra Segment = 0
    MOV SS, AX         ; Stack Segment = 0
    MOV SP, 0x7C00     ; Stack Pointer justo antes del inicio de nuestro código
    
    ; Cambiar a modo gráfico 13h (320x200, 256 colores)
    MOV AX, 0x0013     ; AH=0 (cambiar modo), AL=13h (modo gráfico 320x200)
    INT 0x10           ; Interrupción de servicios de vídeo BIOS
    
    ; Inicializar contador en 0
    MOV BYTE [decenas], 0  ; Inicializar dígito de decenas en 0
    MOV BYTE [unidades], 0 ; Inicializar dígito de unidades en 0
    
    ; Definir posición para dibujar el número (esquina superior izquierda)
    MOV WORD [pos_x], 20   ; Posición X = 20
    MOV WORD [pos_y], 20   ; Posición Y = 20
    MOV BYTE [color], 15   ; Color blanco (15 en paleta estándar)
    
    ; Mostrar mensaje inicial en la pantalla
    MOV AH, 0x02           ; Función para posicionar cursor
    MOV BH, 0              ; Página 0 (pantalla activa)
    MOV DH, 4              ; Fila 4
    MOV DL, 2              ; Columna 2
    INT 0x10               ; Llamar interrupción de vídeo
    
    MOV SI, mensaje_inicio ; Cargar dirección del mensaje en SI
    CALL print_string      ; Llamar a la función para imprimir la cadena
    
main_loop:
    ; Limpiar solo la zona del número (20x10 píxeles)
    MOV CX, [pos_x]        ; Cargar coordenada X en CX
    SUB CX, 10             ; Restar 10 para comenzar 10 píxeles a la izquierda
    MOV DX, [pos_y]        ; Cargar coordenada Y en DX
    SUB DX, 5              ; Comenzar 5 píxeles arriba
    MOV SI, 10             ; SI = altura del área a limpiar (10 píxeles)

clear_y_loop:              ; Bucle para recorrer filas (eje Y)
    MOV DI, 20             ; DI = ancho del área a limpiar (20 píxeles)
    PUSH CX                ; Guardar posición X inicial en la pila
    
clear_x_loop:              ; Bucle para recorrer columnas (eje X)
    MOV AH, 0x0C           ; Función para escribir un píxel
    MOV AL, 0              ; Color negro (0)
    INT 0x10               ; Llamar interrupción para dibujar el píxel
    INC CX                 ; Avanzar a la siguiente posición X
    DEC DI                 ; Decrementar contador de ancho
    JNZ clear_x_loop       ; Si no hemos terminado la fila, repetir
    
    POP CX                 ; Recuperar posición X inicial
    INC DX                 ; Avanzar a la siguiente fila (Y+1)
    DEC SI                 ; Decrementar contador de altura
    JNZ clear_y_loop       ; Si no hemos terminado todas las filas, repetir
    
    ; Posicionar cursor para escribir el contador
    MOV AH, 0x02           ; Función para posicionar cursor
    MOV BH, 0              ; Página 0
    MOV DH, 2              ; Fila 2
    MOV DL, 2              ; Columna 2
    INT 0x10               ; Llamar interrupción
    
    ; Escribir dígito de decenas
    MOV AH, 0x09           ; Función para escribir carácter con atributo
    MOV AL, [decenas]      ; Obtener valor numérico de decenas
    ADD AL, '0'            ; Convertir a ASCII (sumar 48/'0')
    MOV BH, 0              ; Página 0
    MOV BL, [color]        ; Color del carácter
    MOV CX, 1              ; Escribir 1 carácter
    INT 0x10               ; Llamar interrupción
    
    ; Posicionar cursor para el dígito de unidades
    MOV AH, 0x02           ; Función para posicionar cursor
    MOV BH, 0              ; Página 0
    MOV DH, 2              ; Misma fila (2)
    MOV DL, 3              ; Columna 3 (junto a las decenas)
    INT 0x10               ; Llamar interrupción
    
    ; Escribir dígito de unidades
    MOV AH, 0x09           ; Función para escribir carácter con atributo
    MOV AL, [unidades]     ; Obtener valor numérico de unidades
    ADD AL, '0'            ; Convertir a ASCII (sumar 48/'0')
    MOV BH, 0              ; Página 0
    MOV BL, [color]        ; Color del carácter
    MOV CX, 1              ; Escribir 1 carácter
    INT 0x10               ; Llamar interrupción
    
    ; Esperar a que se presione una tecla
    MOV AH, 0x00           ; Función para leer teclado
    INT 0x16               ; Esperar hasta que se presione una tecla
    
    ; Una vez presionada cualquier tecla, incrementar contador
    INC BYTE [unidades]    ; Incrementar dígito de unidades
    CMP BYTE [unidades], 10 ; Comparar si unidades >= 10
    JB update_color        ; Si es menor que 10, saltar a actualizar color
    
    ; Si unidades llegó a 10, ajustar unidades e incrementar decenas
    MOV BYTE [unidades], 0 ; Unidades vuelve a 0
    INC BYTE [decenas]     ; Incrementar dígito de decenas
    
    ; Verificar si decenas excede 9
    CMP BYTE [decenas], 10 ; Comparar si decenas >= 10
    JB update_color        ; Si es menor que 10, saltar a actualizar color
    
    ; Si llegamos a 100, volver a 0
    MOV BYTE [decenas], 0  ; Decenas vuelve a 0
    
update_color:
    ; Cambiar color para efecto visual
    INC BYTE [color]       ; Incrementar valor de color
    CMP BYTE [color], 15   ; Mantener en el rango de 1-15 (evitar negro)
    JB main_loop           ; Si es menor que 15, volver al inicio del bucle
    MOV BYTE [color], 1    ; Volver a color 1 si superamos 15
    
    ; Volver al inicio del bucle
    JMP main_loop          ; Salto incondicional al inicio del bucle principal

; Función para imprimir cadena terminada en cero
print_string:
    PUSH AX                ; Guardar registros que serán modificados
    PUSH BX                ; para restaurarlos al final
    MOV AH, 0x0E           ; Función teletype (escribe carácter y avanza cursor)
    MOV BH, 0              ; Página 0
    MOV BL, 0x0F           ; Color blanco brillante
    
print_loop:
    LODSB                  ; Cargar byte de [SI] en AL e incrementar SI
    TEST AL, AL            ; Verificar si AL es 0 (fin de cadena)
    JZ print_done          ; Si es cero, terminar
    INT 0x10               ; Imprimir carácter
    JMP print_loop         ; Continuar con el siguiente carácter
    
print_done:
    POP BX                 ; Restaurar registros
    POP AX
    RET                    ; Retornar al punto de llamada

; Variables
decenas   db 0             ; Dígito de decenas (inicia en 0)
unidades  db 0             ; Dígito de unidades (inicia en 0)
pos_x     dw 0             ; Posición X para dibujar (word = 16 bits)
pos_y     dw 0             ; Posición Y para dibujar (word = 16 bits)
color     db 15            ; Color actual (byte = 8 bits)
mensaje_inicio db 'Presiona cualquier tecla para incrementar el contador', 0
                           ; String terminado en nulo (0)

; Rellenar hasta 510 bytes y agregar firma de bootloader
times 510-($-$$) db 0      ; Rellenar con ceros hasta completar 510 bytes
dw 0xAA55                  ; Firma de sector de arranque (los últimos 2 bytes)