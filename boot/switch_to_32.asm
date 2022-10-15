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