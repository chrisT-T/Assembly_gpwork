[bits 16]
print16:
    pusha
    mov ah, 0x0e ; tty

print16_loop:
    mov al, [bx]
    cmp al, 0
    je print16_done

    int 0x10 ;
    add bx, 1
    jmp print16_loop
print16_done:
    popa
    ret

[bits 16]
print_endl:
    pusha

    mov ah, 0x0e
    mov al, 0x0a ; newline char
    int 0x10
    mov al, 0x0d ; carriage return
    int 0x10

    popa
    ret

[bits 16]

cls_screen16:
    pusha 

    mov ax, 0x0003
    int 0x10

    popa
    ret