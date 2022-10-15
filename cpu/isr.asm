
set_idt_gate:
    ; param n in eax, handler address in ebx
    
    mov [idt_gate + 264], bx
    shr ebx, 16
    mov [idt_gate + 264 + 6], bx
    mov [idt_gate + 264 + 2], word 0x08
    mov [idt_gate + 264 + 4], byte 0
    mov [idt_gate + 264 + 5], byte 0x8e

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
    mov al, 11111101b
    out 0x21, al

    ; install keyboard interrupt:  IRQ1
    mov eax, 33
    mov ebx, irq1
    call set_idt_gate

    mov [idt_register], word 4095 ; 256 * 16 - 1
    
    mov [idt_register + 2], dword idt_gate
    lidt [idt_register]
    
    ret

irq1:
    cli
    mov ebx, testintstr
    call print32
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
    iret


irq_handler:
    mov ebx, testintstr
    call print32
    mov eax, 0x20
    out 0x20, al
    ret

tmp: db 0,0
idt_gate: times 4096 db 0
idt_register: times 6 db 0
testintstr: db "asdfadsfsadf", 0
%include "boot/print32.asm"