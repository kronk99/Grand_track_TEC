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
    
    ; Inicializar contador en 90
    MOV BYTE [decenas], 9     ; Inicializar dígito de decenas
    MOV BYTE [unidades], 0    ; Inicializar dígito de unidades
    
    ; Definir posición para dibujar el número (esquina superior izquierda)
    MOV WORD [pos_x], 20     ; Nueva posición X (más cerca del borde izquierdo)
    MOV WORD [pos_y], 20     ; Nueva posición Y (más cerca del borde superior)
    MOV BYTE [color], 15     ; Color blanco
    
main_loop:
    ; Limpiar solo la zona del número (20x10 píxeles - más pequeño que antes)
    MOV CX, [pos_x]          ; Coordenada X
    SUB CX, 10               ; 10 píxeles a la izquierda (reducido)
    MOV DX, [pos_y]          ; Coordenada Y 
    SUB DX, 5                ; 5 píxeles arriba (reducido)
    MOV SI, 10               ; Altura del área a limpiar (reducido)
clear_y_loop:
    MOV DI, 20               ; Ancho del área a limpiar (reducido)
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
    
    ; Posicionar cursor para escribir el tiempo (ajustado a esquina superior izquierda)
    MOV AH, 0x02             ; Función para posicionar cursor
    MOV BH, 0                ; Página 0
    MOV DH, 2                ; Fila 2 (cerca del borde superior)
    MOV DL, 2                ; Columna 2 (cerca del borde izquierdo)
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
    
    ; Esperar aproximadamente 1 segundo utilizando la interrupción de BIOS
    MOV AH, 0x86            ; Función BIOS - WAIT
    MOV CX, 0x000F          ; Parte alta del contador (microsegundos)
    MOV DX, 0x4240          ; Parte baja del contador (1,000,000 microsegundos = 1 segundo)
    INT 0x15                ; Llamar a interrupción de espera
    
    ; En caso de que el INT 15h/AH=86h no esté disponible
    CMP AH, 0x86            ; Verificar si BIOS devolvió error
    JNE use_delay_loop
    JMP after_delay
    
use_delay_loop:
    ; Bucle de retraso calibrado para aproximadamente 1 segundo
    MOV CX, 0x001F          ; Ajustar según la velocidad del CPU
outer_loop:
    PUSH CX
    MOV CX, 0xFFFF
inner_loop:
    NOP                     ; No operation - consume un ciclo de CPU
    NOP
    NOP
    NOP
    LOOP inner_loop         ; Decrementa CX y salta si no es cero
    POP CX
    LOOP outer_loop         ; Bucle externo
    
after_delay:
    ; Cambiar color para efecto visual
    INC BYTE [color]
    CMP BYTE [color], 15    ; Mantener en el rango de 1-15 (evitar negro)
    JB color_ok
    MOV BYTE [color], 1     ; Volver a color 1 si superamos 15
color_ok:
    
    ; Decrementar contador
    DEC BYTE [unidades]     ; Decrementar unidades
    CMP BYTE [unidades], 0  ; Si unidades < 0
    JGE check_end           ; Si no es negativo, continuar
    
    ; Ajustar unidades y decrementar decenas
    MOV BYTE [unidades], 9  ; Unidades vuelve a 9
    DEC BYTE [decenas]      ; Decrementar decenas
    
check_end:
    ; Verificar si terminamos (00)
    CMP BYTE [decenas], 0
    JNE main_loop           ; Si decenas no es 0, continuar
    
    CMP BYTE [unidades], 0
    JNE main_loop           ; Si unidades no es 0, continuar
    
    ; Si llegamos aquí, hemos llegado a 00
    JMP done
    
done:
    ; Mostrar mensaje final (ajustado para aparecer debajo de los números)
    MOV AH, 0x02             ; Posicionar cursor
    MOV BH, 0                ; Página 0
    MOV DH, 4                ; Dos líneas debajo del número
    MOV DL, 2                ; Misma columna que los números
    INT 0x10
    
    MOV SI, mensaje_fin
    CALL print_string
    
    ; Detener sistema
    CLI
    HLT
    JMP $                    ; Bucle infinito por si acaso

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
decenas   db 9               ; Dígito de decenas (9)
unidades  db 0               ; Dígito de unidades (0)
pos_x     dw 0               ; Posición X para dibujar
pos_y     dw 0               ; Posición Y para dibujar
color     db 15              ; Color actual (blanco)
mensaje_fin db 'Cuenta regresiva finalizada!', 0

; Rellenar hasta 510 bytes y agregar firma de bootloader
times 510-($-$$) db 0
dw 0xAA55                    ; Firma de sector de arranque