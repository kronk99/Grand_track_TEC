[BITS 16]
[ORG 0x7C00]
mov ax, 0013h
int 10h

push 0A000h
pop es   ; ES -> A0000h

mov al, 04h  ; VGA RED
mov cx, 320*200
xor di, di
rep stosb


cli
hlt

times 510-($-$$) db 0

; Boot signature
dw 0AA55h
