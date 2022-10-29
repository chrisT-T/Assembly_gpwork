mouse_counter dd 0

set_idt_gate:
    ; param n in eax, handler address in ebx
    mov [idt_gate + eax], bx
    shr ebx, 16
    mov [idt_gate + eax + 6], bx
    mov [idt_gate + eax + 2], word 0x08
    mov [idt_gate + eax + 4], byte 0
    mov [idt_gate + eax + 5], byte 0x8e

    ret

isr_install:

    ; ICW 1
    mov eax, 0x11
    out 0x20, al
    out 0xa0, al

    ; ICW 2
    mov eax, 0x20
    out 0x21, al
    mov eax, 0x28
    out 0xa1, al

    ; ICW 3
    mov eax, 0x04
    out 0x21, al
    mov eax, 0x02
    out 0xa1, al

    ; ICW 4
    mov eax, 0x01
    out 0x21, al
    mov eax, 0x01
    out 0xa1, al

    ; OCW 1
    mov al, 00000001b
    out 0x21, al

    ; OCW 2
    mov  al, 0	
    out  0xa1, al		

    ; install keyboard interrupt:  IRQ1
    mov eax, 33 * 8
    mov ebx, irq1
    call set_idt_gate

    ; install keyboard interrupt:  IRQ12
    mov eax, 44 * 8
    mov ebx, irq12
    call set_idt_gate

    mov [idt_register], word 4095 ; 256 * 16 - 1
    
    mov [idt_register + 2], dword idt_gate
    lidt [idt_register]

    call kbc_ready
    mov al, 0x60
    out 0x64, al

    call kbc_ready
    mov al, 0x47
    out 0x60, al
    
    call kbc_ready
    mov al, 0xd4
    out 0x64, al
    
    call kbc_ready
    mov al, 0xf4
    out 0x60, al

    ret

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

kbc_ready:
    kbc_ready_loop:
        in al, 0x64 ;sta
        and al, byte 0x02
        cmp al, 0
        je kbc_ready_ret
        jmp kbc_ready_loop
    kbc_ready_ret:
    ret

irq12:
    cli

    mov al, 0x20
    out 0x20, al
    mov al, 0x20
    out 0xa0, al

    in al, 0x60

    mov ebx, mouse_data
    add ebx, [mouse_counter]
    mov [ebx], al

    add [mouse_counter], dword 1
    cmp [mouse_counter], dword 4
    jne not_mouse_end
        mov [mouse_counter], dword 1
        mov al, [mouse_data + 1]
        call print_byte
        mov al, [mouse_data + 2]
        call print_byte
        mov al, [mouse_data + 3]
        call print_byte
        call print_right
    not_mouse_end:

    iret

irq_common_stub:
    pusha
    mov ax, ds
    push eax
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    push esp
    call irq_handler 
    pop ebx  

    pop ebx
    mov ds, bx
    mov es, bx
    mov fs, bx
    mov gs, bx
    popa
    add esp, 8
    sti
    iret


irq_handler:
    pusha
    mov edx, testintstr
    call print_string
    popa

    mov al, 0x20
    out 0x20, al
    out 0x20, al
    ret

tmp: db '0',0
idt_gate: times 4096 db 0
idt_register: times 6 db 0
testintstr: db "asdfadsfsadf", 0
mouse_data: db 1, 2, 3, 4, 10 dup(0)
scan_code_to_ascii db '?', '?', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', '?', '?', 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', '[', ']', '?', '?', 'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', ';', 39 , '`', '?', 92, 'Z', 'X', 'C', 'V', 'B', 'N', 'M', ',', '.', '/', '?', '?', '?', ' ', 0

%include "boot/print32.asm"
%include "driver/display.asm"