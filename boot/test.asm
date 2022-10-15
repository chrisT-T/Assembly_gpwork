[org 0x7c00]
KERNEL_OFFSET equ 0x1000 
mov [BOOT_DRIVE], dl

mov bx, test_string
call print16
call cls_screen16
call load_kernel
call switch_32_bit
jmp $

%include "boot/print16.asm"
%include "boot/print32.asm"
%include "boot/gdt.asm"
%include "boot/switch_to_32.asm"
%include "boot/disk.asm"

[bits 16]
load_kernel:
    mov bx, KERNEL_OFFSET ; Read from disk and store in 0x1000
    mov dh, 31
    mov dl, [BOOT_DRIVE]
    call disk_load
    ret

[bits 32]
begin_pm:
    mov ebx, test32_string
    call print32
    call KERNEL_OFFSET
    jmp $

BOOT_DRIVE db 0
test32_string: db "Msg from N", 0
test_string: db "Msg from NASM", 0

times 510 - ($-$$) db 0
dw 0xaa55