global main

%include "driver/display.asm"


[bits 32]

main:
    mov ebx, testmsg
    call print32
    call clr_screen
    mov ebx, testmsg2
    call print32
    call isr_install
    sti
    jmp $

testmsg: db "Kernel Msg", 0
testmsg2: db "Kernel Msg2", 0

%include "cpu/isr.asm"