global main



[bits 32]

main:
    mov ebx, testmsg
    call print32
    call clr_screen
    mov edx, testmsg2
    call print_string
    call isr_install
    sti
    jmp $

testmsg: db "Kernel Msg", 0
testmsg2: db "Kernel Msg2 hhahahaha", 0

%include "cpu/isr.asm"