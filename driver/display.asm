[bits 32]

VIDEO_ADDRESS equ 0xb8000
MAX_ROWS equ 25
MAX_COLS equ 80
WHITE_ON_BLACK equ 0x0f
REG_SCREEN_CTRL equ 0x3D4
REG_SCREEN_DATA equ 0x3D5


get_cursor:
    pusha

    ; load the high bit of cursor
    mov al, 14
    mov dx, REG_SCREEN_CTRL
    out dx, al
    mov dx, REG_SCREEN_DATA 
    in al, dx
    mov bh, al

    ; load the low bit of cursor
    mov al, 15
    mov dx, REG_SCREEN_CTRL
    out dx, al
    mov dx, REG_SCREEN_DATA
    in al, dx
    mov bl, al
    shl bx, 1
    mov [off], bx
    popa
    ; result in bx
    ret

set_cursor:
    ; param: offset in bx
    pusha

    shr bx, 1

    mov al, 14
    mov dx, REG_SCREEN_CTRL
    out dx, al
    mov al, bh
    mov dx, REG_SCREEN_DATA
    out dx, al

    mov al, 15
    mov dx, REG_SCREEN_CTRL
    out dx, al
    mov al, bl
    mov dx, REG_SCREEN_DATA
    out dx, al

    popa
    ret

set_char:
    ; param: eax: position, bl target char
    mov [VIDEO_ADDRESS + eax], bx
    inc eax
    mov [VIDEO_ADDRESS + eax], byte WHITE_ON_BLACK
    
    ret

clr_screen:
    pusha

    mov al, [MAX_ROWS]
    mov bl, [MAX_COLS]
    mul bl
    mov ecx, eax

    cls_loop:
        dec ax
        pusha

        mov bx, 2
        mul bx
        mov ebx, ' '
        call set_char

        popa
    loop cls_loop

    mov bx, 0
    call set_cursor

    popa
    ret

print_string:

    call get_cursor
    mov bx, [off]
    mov eax, 0
    mov ax, bx

    ; mov eax, 10

    L1:
        mov bx, [edx]
        cmp bl, 0
        je PRINT_LOOP_END

        call set_char
        add eax, 1
        add edx, 1

        jmp L1
    PRINT_LOOP_END:
    add ax, 1
    mov bx, ax
    call set_cursor
    ret

print_backspace:
    mov eax, 0
    call get_cursor
    mov ax, [off]
    mov bx, ' '
    sub ax, 2
    call set_char

    mov bx, [off]
    sub bx, 2
    call set_cursor

    ret

print_enter:
    call get_cursor
    mov ax, [off]
    add ax, 160
    mov bx, ax
    call set_cursor
    ret
off dw 0