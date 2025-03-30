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
    
    ; Inicializar contador en 90 (cuenta regresiva)
    MOV BYTE [decenas], 9  ; Inicializar dígito de decenas en 9
    MOV BYTE [unidades], 0 ; Inicializar dígito de unidades en 0
    
    ; Definir posición para dibujar el número (esquina superior izquierda)
    MOV WORD [pos_x], 20   ; Posición X = 20 (cerca del borde izquierdo)
    MOV WORD [pos_y], 20   ; Posición Y = 20 (cerca del borde superior)
    MOV BYTE [color], 15   ; Color blanco (15 en paleta estándar)
    
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
    
    ; Posicionar cursor para escribir el tiempo (contador regresivo)
    MOV AH, 0x02           ; Función para posicionar cursor
    MOV BH, 0              ; Página 0
    MOV DH, 2              ; Fila 2 (cerca del borde superior)
    MOV DL, 2              ; Columna 2 (cerca del borde izquierdo)
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
    
    ; Esperar aproximadamente 1 segundo utilizando la interrupción de BIOS
    MOV AH, 0x86           ; Función BIOS - WAIT (espera)
    MOV CX, 0x000F         ; Parte alta del contador (microsegundos)
    MOV DX, 0x4240         ; Parte baja del contador (1,000,000 microsegundos = 1 segundo)
    INT 0x15               ; Llamar a interrupción de espera
    
    ; En caso de que el INT 15h/AH=86h no esté disponible
    CMP AH, 0x86           ; Verificar si BIOS devolvió error
    JNE use_delay_loop     ; Si hubo error, usar bucle de retraso alternativo
    JMP after_delay        ; Si no hubo error, saltar a después del retraso
    
use_delay_loop:            ; Método alternativo de retraso
    ; Bucle de retraso calibrado para aproximadamente 1 segundo
    MOV CX, 0x001F         ; Ajustar según la velocidad del CPU (contador externo)
outer_loop:                ; Etiqueta para bucle externo
    PUSH CX                ; Guardar contador externo
    MOV CX, 0xFFFF         ; Valor máximo para contador interno (65535)
inner_loop:                ; Etiqueta para bucle interno
    NOP                    ; No operation - consume un ciclo de CPU
    NOP                    ; Múltiples NOPs para hacer el retraso más largo
    NOP
    NOP
    LOOP inner_loop        ; Decrementa CX y salta si no es cero (bucle interno)
    POP CX                 ; Recuperar contador externo
    LOOP outer_loop        ; Bucle externo (31 iteraciones del bucle interno)
    
after_delay:               ; Continuar después del retraso
    ; Cambiar color para efecto visual
    INC BYTE [color]       ; Incrementar valor de color
    CMP BYTE [color], 15   ; Mantener en el rango de 1-15 (evitar negro)
    JB color_ok            ; Si es menor que 15, continuar
    MOV BYTE [color], 1    ; Volver a color 1 si superamos 15
color_ok:                  ; Etiqueta para continuar después de ajustar color
    
    ; Decrementar contador (cuenta regresiva)
    DEC BYTE [unidades]    ; Decrementar dígito de unidades
    CMP BYTE [unidades], 0 ; Comparar si unidades < 0
    JGE check_end          ; Si no es negativo, verificar si terminamos
    
    ; Ajustar unidades y decrementar decenas
    MOV BYTE [unidades], 9 ; Unidades vuelve a 9
    DEC BYTE [decenas]     ; Decrementar dígito de decenas
    
check_end:                 ; Verificar si hemos llegado a 00
    ; Verificar si terminamos (00)
    CMP BYTE [decenas], 0  ; Comprobar si decenas = 0
    JNE main_loop          ; Si decenas no es 0, continuar con el bucle
    
    CMP BYTE [unidades], 0 ; Comprobar si unidades = 0
    JNE main_loop          ; Si unidades no es 0, continuar con el bucle
    
    ; Si llegamos aquí, hemos llegado a 00 (fin de la cuenta regresiva)
    JMP done               ; Saltar a la rutina final
    
done:                      ; Rutina final cuando la cuenta llega a 00
    ; Mostrar mensaje final
    MOV AH, 0x02           ; Posicionar cursor
    MOV BH, 0              ; Página 0
    MOV DH, 4              ; Fila 4 (dos líneas debajo del número)
    MOV DL, 2              ; Columna 2 (misma alineación que el número)
    INT 0x10               ; Llamar interrupción
    
    MOV SI, mensaje_fin    ; Cargar dirección del mensaje final
    CALL print_string      ; Llamar a la función para imprimir cadena
    
    ; Detener sistema
    CLI                    ; Clear Interrupt Flag (deshabilitar interrupciones)
    HLT                    ; Halt processor (detener procesador)
    JMP $                  ; Bucle infinito por si acaso HLT no funciona

; Función para imprimir cadena terminada en cero
print_string:
    PUSH AX                ; Guardar registros que serán modificados
    PUSH BX
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
decenas   db 9             ; Dígito de decenas (inicia en 9)
unidades  db 0             ; Dígito de unidades (inicia en 0)
pos_x     dw 0             ; Posición X para dibujar (word = 16 bits)
pos_y     dw 0             ; Posición Y para dibujar (word = 16 bits)
color     db 15            ; Color actual (byte = 8 bits)
mensaje_fin db 'Cuenta regresiva finalizada!', 0  ; Mensaje final terminado en nulo (0)

; Rellenar hasta 510 bytes y agregar firma de bootloader
times 510-($-$$) db 0      ; Rellenar con ceros hasta completar 510 bytes
dw 0xAA55                  ; Firma de sector de arranque (los últimos 2 bytes)