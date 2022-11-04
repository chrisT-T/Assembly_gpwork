%ifndef MOUSE_DRIVER
%define MOUSE_DRIVER
; mouse interrupt handler
mouse_interrupt_handler:
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
        mov [mouse_action], al
        mov al, [mouse_action]

        cmp [mouse_action], byte 9
        jne not_left_click
            mov edx, Rclick
            call print_string
            mov [background], byte 0x7A378B
            call flash_screen
        not_left_click:

        cmp [mouse_action], byte 10
        jne not_right_click
            mov edx, Lclick
            call print_string
            mov [background], byte 0x00
            call flash_screen
        not_right_click:
        ;call print_byte
        
        ;call print_byte
        ;call print_right
        mov al, [mouse_data + 2]
        add al, [x_move]
        mov [x_move], al
        mov al, [mouse_data + 3]
        add al, [y_move] 
        mov [y_move], al
        cmp [x_move], byte 30
        jl not_move_x
            mov [x_move], byte 0
            call get_cursor
            mov ax, [off]
            mov bl, 160
            div bl
            cmp ah, 157
            jnbe meet_x_right_end
                mov ax, [off]
                add ax, 2
                mov bx, ax
                call set_cursor
            meet_x_right_end:

        not_move_x:
        cmp [x_move], byte 225
        jnl not_move_x_neg
            mov [x_move], byte 0
            call get_cursor
            mov ax, [off]
            mov bl, 160
            div bl
            cmp ah, 3
            jb meet_x_left_end
                mov ax, [off]
                sub ax, 2
                mov bx, ax
                call set_cursor
            meet_x_left_end:

        not_move_x_neg:
        cmp [y_move], byte 225
        jnl not_move_y
            mov [y_move], byte 0
            call get_cursor
            mov ax, [off]
            mov bl, 160
            div bl
            cmp al, 24
            je meet_y_btm_end
                mov ax, [off]
                add ax, 160
                mov bx, ax
                call set_cursor
            meet_y_btm_end:

        not_move_y:
        cmp [y_move], byte 30
        jl not_move_y_neg
            mov [y_move], byte 0
            call get_cursor
            mov ax, [off]
            mov bl, 160
            div bl
            cmp al, 0
            je meet_y_top_end
                mov ax, [off]
                sub ax, 160
                mov bx, ax
                call set_cursor
            meet_y_top_end:

        not_move_y_neg:

    not_mouse_end:

    iret

Rclick: db "Rclick", 0
Lclick: db "Lclick", 0
mouse_data: db 0,0,0,0,0

x_move db 0
y_move db 0
mouse_action db 0
mouse_counter dd 0

%endif