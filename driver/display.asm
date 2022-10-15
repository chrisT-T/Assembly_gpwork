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
    out REG_SCREEN_CTRL, al
    in al, REG_SCREEN_DATA
    mov bl, al

    ; load the low bit of cursor
    mov al, 14
    out REG_SCREEN_CTRL, al
    in al, REG_SCREEN_DATA
    mov bl, al

    mov ax, bx
    mov bl, 2
    mul bl
    mov bx, ax

    popa
    ; result in bx
    ret

set_cursor:
    ; param: offset in bx
    pusha

    mov ax, bx
    mov bl, 2
    div bl
    mov ax, bx

    mov eax, 14
    out REG_SCREEN_CTRL, al
    mov al, bh
    out REG_SCREEN_DATA, al

    mov eax, 15
    out REG_SCREEN_CTRL, al
    mov bh, al
    out REG_SCREEN_DATA, al

    popa
    ret

set_char:
    ; param: eax: position, ebx target char
    mov [VIDEO_ADDRESS + eax], ebx
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
    ;param: eax: pos of 