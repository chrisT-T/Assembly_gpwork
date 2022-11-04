[org 0x7c00]
KERNEL_OFFSET equ 0x1000 
mov [BOOT_DRIVE], dl

call load_kernel
call switch_32_bit
jmp $

%include "boot/gdt.asm"

[bits 16]
load_disk:
    pusha
        mov ah, 0x02
        mov al, dh
        mov cl, 0x02 ; 0x01 is mbr
        mov dh, 0x00

        int 0x13
    popa
    ret

[bits 16]
load_kernel:
    mov bx, KERNEL_OFFSET ; Read from disk and store in 0x1000
    mov dh, 31
    mov dl, [BOOT_DRIVE]

    call load_disk
    ret

[bits 32]
begin_pm:
    call KERNEL_OFFSET
    jmp $

[bits 16]
switch_32_bit:
    cli
    lgdt [gdt_descriptor]
    ; set a bit of control register
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    
    jmp CODE_SEG:init_protect_mode

[bits 32]
init_protect_mode:
    mov ax, DATA_SEG
    
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; set the stack position
    mov ebp, 0x90000 
    mov esp, ebp
    
    call begin_pm

BOOT_DRIVE db 0

times 510 - ($-$$) db 0
dw 0xaa55