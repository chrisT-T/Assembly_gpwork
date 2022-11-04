%ifndef KEYBOARD_DRIVER
%define KEYBOARD_DRIVER
; kerboard interrupt handler
irq1:
    cli
    mov eax, 0
    mov al,  0x61
    out 0x20, al 
    in  al,  0x60

    mov bl, al
    cmp bl, 0x80
    ja release
    
    cmp bl, 0x3b
    jne not_f1
    mov bh, 0x0f
    add bh, [background]
    mov [color_mode], bh
    jmp release
    not_f1:

    cmp bl, 0x3c
    jne not_f2
    mov bh, 0x03
    add bh, [background]
    mov [color_mode], bh
    jmp release
    not_f2:

    cmp bl, 0x3d
    jne not_f3
    mov bh, 0x09
    add bh, [background]
    mov [color_mode], bh
    jmp release
    not_f3:

    cmp bl, 0x3e
    jne not_f4
    mov [background], byte 0xf0
    call flash_screen
    jmp release
    not_f4:

    cmp bl, 0x3f
    jne not_f5
    mov [background], byte 0x00
    call flash_screen
    jmp release
    not_f5:

    cmp bl, 0x01 ; esc
    jne not_esc
    call print_esc
    jmp release
    not_esc:

    cmp bl, 0x4b
    jne not_left
    call print_left
    jmp release
    not_left:

    cmp bl, 0x4d
    jne not_right
    call print_right
    jmp release
    not_right:

    cmp bl, 0x48
    jne not_up
    call print_up
    jmp release
    not_up:

    cmp bl, 0x50 ; down
    jne not_down
    call print_down
    jmp release
    not_down:

    cmp bl, 0x53
    jne not_delete
    call print_delete
    jmp release
    not_delete:

    cmp bl, 0x0e ; Backspace
    jne not_backspace
    call print_backspace
    jmp release
    not_backspace:

    cmp bl, 0x1c ; Enter
    jne not_enter
    call print_enter
    jmp release
    not_enter:




    mov ebx, scan_code_to_ascii
    add ebx, eax
    mov esi, ebx
    mov edi, tmp
    movsb
    
    mov [tmp + 1], byte 0
    
    mov edx, tmp
    call print_string

    mov al, 0x20
    out 0x20, al

    release:
    iret

tmp: db '0',0
idt_gate: times 4096 db 0
idt_register: times 6 db 0
scan_code_to_ascii db '?', '?', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', '?', '?', 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', '[', ']', '?', '?', 'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', ';', 39 , '`', '?', 92, 'Z', 'X', 'C', 'V', 'B', 'N', 'M', ',', '.', '/', '?', '?', '?', ' ', 0

%endif