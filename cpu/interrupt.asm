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

    ; OCW 1, only interrupt 1, 2 open
    ; 1: keyboard interrupt
    ; 2: connect the second chip
    mov al, 11111001b
    out 0x21, al

    ; OCW 2, only interrupt 4 open
    ; 4: mouse interrupt
    mov  al, 11101111b	
    out  0xa1, al		

    ; install keyboard interrupt:  IRQ1
    mov eax, (32 + 1) * 8
    mov ebx, keyboard_interrupt_handler
    call set_idt_gate

    ; install mouse interrupt:  IRQ12
    mov eax, (32 + 12) * 8
    mov ebx, mouse_interrupt_handler
    call set_idt_gate

    mov [idt_register], word 256 * 16 - 1
    mov [idt_register + 2], dword idt_gate

    lidt [idt_register]

    call init_keyboard_circuit

    ret

; wait until the keyboard circuit ready
kbc_ready:
    kbc_ready_loop:
        in al, 0x64 ;sta
        and al, byte 0x02
        cmp al, 0
        je kbc_ready_ret
        jmp kbc_ready_loop
    kbc_ready_ret:
    ret

; send control cmd to port, initialize the keyboard circuit to use mouse
init_keyboard_circuit:
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


%include "driver/display.asm"
%include "driver/mouse.asm"
%include "driver/kerboard.asm"