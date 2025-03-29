[BITS 16]
[ORG 0x7C00]   ; Dirección estándar donde el BIOS carga el bootloader

start:
    ; Configuración inicial
    MOV AX, 0x0000
    MOV DS, AX
    MOV ES, AX
    MOV SS, AX
    MOV SP, 0x7C00      ; Configurar stack pointer justo antes de nuestro código
    
    ; Cambiar a modo gráfico 13h (320x200, 256 colores)
    MOV AX, 0x0013      ; Modo gráfico 13h
    INT 0x10
    
    ; Inicializar contador en 0
    MOV BYTE [decenas], 0     ; Inicializar dígito de decenas
    MOV BYTE [unidades], 0    ; Inicializar dígito de unidades
    
    ; Definir posición para dibujar el número (esquina superior izquierda)
    MOV WORD [pos_x], 20     ; Posición X 
    MOV WORD [pos_y], 20     ; Posición Y
    MOV BYTE [color], 15     ; Color blanco
    
    ; Mostrar mensaje inicial
    MOV AH, 0x02             ; Posicionar cursor
    MOV BH, 0                ; Página 0
    MOV DH, 4                ; Fila 4
    MOV DL, 2                ; Columna 2
    INT 0x10
    
    MOV SI, mensaje_inicio
    CALL print_string
    
main_loop:
    ; Limpiar solo la zona del número (20x10 píxeles)
    MOV CX, [pos_x]          ; Coordenada X
    SUB CX, 10               ; 10 píxeles a la izquierda
    MOV DX, [pos_y]          ; Coordenada Y 
    SUB DX, 5                ; 5 píxeles arriba
    MOV SI, 10               ; Altura del área a limpiar
clear_y_loop:
    MOV DI, 20               ; Ancho del área a limpiar
    PUSH CX
clear_x_loop:
    MOV AH, 0x0C             ; Función para escribir píxel
    MOV AL, 0                ; Color negro
    INT 0x10                 ; Escribir píxel
    INC CX                   ; Siguiente X
    DEC DI                   ; Decrementar contador de ancho
    JNZ clear_x_loop         ; Si no hemos terminado con esta fila
    POP CX                   ; Recuperar X inicial
    INC DX                   ; Siguiente Y
    DEC SI                   ; Decrementar contador de altura
    JNZ clear_y_loop         ; Si no hemos terminado con todas las filas
    
    ; Posicionar cursor para escribir el contador
    MOV AH, 0x02             ; Función para posicionar cursor
    MOV BH, 0                ; Página 0
    MOV DH, 2                ; Fila 2
    MOV DL, 2                ; Columna 2
    INT 0x10
    
    ; Escribir decenas
    MOV AH, 0x09             ; Función para escribir carácter con atributo
    MOV AL, [decenas]        ; Obtener decenas
    ADD AL, '0'              ; Convertir a ASCII
    MOV BH, 0                ; Página 0
    MOV BL, [color]          ; Color del carácter
    MOV CX, 1                ; Escribir 1 carácter
    INT 0x10
    
    ; Posicionar cursor para unidades
    MOV AH, 0x02             ; Función para posicionar cursor
    MOV BH, 0                ; Página 0
    MOV DH, 2                ; Misma fila
    MOV DL, 3                ; Columna para unidades (junto a decenas)
    INT 0x10
    
    ; Escribir unidades
    MOV AH, 0x09             ; Función para escribir carácter con atributo
    MOV AL, [unidades]       ; Obtener unidades
    ADD AL, '0'              ; Convertir a ASCII
    MOV BH, 0                ; Página 0
    MOV BL, [color]          ; Color del carácter
    MOV CX, 1                ; Escribir 1 carácter
    INT 0x10
    
    ; Esperar a que se presione una tecla
    MOV AH, 0x00            ; Función para leer teclado
    INT 0x16                ; Esperar tecla
    
    ; Una vez presionada cualquier tecla, incrementar contador
    INC BYTE [unidades]     ; Incrementar unidades
    CMP BYTE [unidades], 10 ; Si unidades >= 10
    JB update_color         ; Si es menor que 10, solo actualizar color
    
    ; Ajustar unidades e incrementar decenas
    MOV BYTE [unidades], 0  ; Unidades vuelve a 0
    INC BYTE [decenas]      ; Incrementar decenas
    
    ; Verificar si decenas excede 9
    CMP BYTE [decenas], 10
    JB update_color         ; Si es menor que 10, continuar
    
    ; Si llegamos a 100, volver a 0
    MOV BYTE [decenas], 0
    
update_color:
    ; Cambiar color para efecto visual
    INC BYTE [color]
    CMP BYTE [color], 15    ; Mantener en el rango de 1-15 (evitar negro)
    JB main_loop
    MOV BYTE [color], 1     ; Volver a color 1 si superamos 15
    
    ; Volver al inicio del bucle
    JMP main_loop

; Función para imprimir cadena
print_string:
    PUSH AX
    PUSH BX
    MOV AH, 0x0E             ; Función teletype
    MOV BH, 0                ; Página 0
    MOV BL, 0x0F             ; Color blanco
print_loop:
    LODSB                    ; Cargar byte de [SI] en AL e incrementar SI
    TEST AL, AL              ; Verificar si es 0 (fin de cadena)
    JZ print_done
    INT 0x10                 ; Imprimir carácter
    JMP print_loop
print_done:
    POP BX
    POP AX
    RET

; Variables
decenas   db 0               ; Dígito de decenas (inicia en 0)
unidades  db 0               ; Dígito de unidades (inicia en 0)
pos_x     dw 0               ; Posición X para dibujar
pos_y     dw 0               ; Posición Y para dibujar
color     db 15              ; Color actual (blanco)
mensaje_inicio db 'Presiona cualquier tecla para incrementar el contador', 0

; Rellenar hasta 510 bytes y agregar firma de bootloader
times 510-($-$$) db 0
dw 0xAA55                    ; Firma de sector de arranque