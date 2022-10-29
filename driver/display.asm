[bits 32]

VIDEO_ADDRESS equ 0xb8000
MAX_ROWS equ 25
MAX_COLS equ 80
WHITE_ON_BLACK equ 0x0f
REG_SCREEN_CTRL equ 0x3D4
REG_SCREEN_DATA equ 0x3D5
color_mode db 0x0f
background db 0x00


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
    mov bl, [color_mode]
    mov [VIDEO_ADDRESS + eax], bl
    
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

print_delete:
    mov eax, 0
    call get_cursor
    mov ax, [off]
    add ax, 2
    mov bx, ' '
    call set_char
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
    mov bl, 160
    div bl
    mul bl
    mov bx, ax
    call set_cursor
    ret

print_down:
    call get_cursor
    mov ax, [off]
    add ax, 160
    mov bx, ax
    call set_cursor
    ret

print_left:
    call get_cursor
    mov ax, [off]
    sub ax, 2
    mov bx, ax
    call set_cursor
    ret

print_right:
    call get_cursor
    mov ax, [off]
    add ax, 2
    mov bx, ax
    call set_cursor
    ret

print_up:
    call get_cursor
    mov ax, [off]
    sub ax, 160
    mov bx, ax
    call set_cursor
    ret

print_num:
    pusha

    call get_cursor
    mov ax, [off]
    add bl, '0'
    call set_char

    mov ax, [off]
    add ax, 2
    mov bx, ax
    call set_cursor
    
    popa
    ret

print_byte:
    ; param: al: target byte
    mov ah, 0
    mov bh, 100
    div bh
    mov bl, al
    call print_num
    
    mov al, ah
    mov ah, 0
    mov bh, 10
    div bh
    mov bl, al
    call print_num

    mov bl, ah
    call print_num

    ret
;flash the screen with new background color
flash_screen:
    pusha

    mov bl, [color_mode]
    shl bl, 4
    shr bl, 4
    add bl, [background]
    mov [color_mode], bl

    mov al, [MAX_ROWS]
    mov bl, [MAX_COLS]
    mul bl
    mov ecx, eax
    mov bx, 2
    mul bx
    flash_loop:
        sub ax, 2
        pusha
        
        mov bl, [VIDEO_ADDRESS + eax + 1]
        shl bl, 4
        shr bl, 4
        add bl, [background]
        mov [VIDEO_ADDRESS + eax + 1], bl

        popa
    loop flash_loop

    popa
    ret
off dw 0