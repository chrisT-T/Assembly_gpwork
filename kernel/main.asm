global main

[bits 32]

main:
    call print_esc
    mov edx, testmsg
    call print_string
    call print_enter
    call isr_install
    sti
    jmp $

testmsg: db "Message from 'OS kernel'", 0

%include "cpu/interrupt.asm"