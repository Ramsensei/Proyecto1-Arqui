section .data
    input_file db "input.img", 0
    output_file db "output.img", 0
    error_msg db "Error occurred", 0
    width dw 0
    new_width dw 0
    x dw 0
    input_data resb 65536  ; Reserve space for input data
    output_data resb 65536 ; Reserve space for output data
    printing resb 65536 ; Reserve space for printing

section .bss
    fd_input resd 1
    fd_output resd 1

section .text
    global _start

_start:
    ; Open input file
    mov eax, 5          ; sys_open
    mov ebx, input_file ; filename
    mov ecx, 0          ; read-only
    int 0x80
    test eax, eax
    js error
    mov [fd_input], eax

    ; Read width from input file
    ; Read first 2 bytes to get width
    mov eax, 3          ; sys_read
    mov ebx, [fd_input] ; file descriptor
    mov ecx, width      ; buffer
    mov edx, 2          ; bytes to read
    int 0x80
    test eax, eax
    js error


    ; Read input file
    mov ax, [width]
    imul ax
    shl edx, 16
    mov dx, ax
    mov eax, 3          ; sys_read
    mov ebx, [fd_input] ; file descriptor
    mov ecx, input_data ; buffer
    int 0x80
    test eax, eax
    js error

    ; Close input file
    mov eax, 6          ; sys_close
    mov ebx, [fd_input] ; file descriptor
    int 0x80
    test eax, eax
    js error

    ; Print input_data
    ; xor eax, eax
    ; mov al, [input_data]
    ; call PrintNumber
    ; mov al, [input_data + 1]
    ; call PrintNumber
    ; mov al, [input_data + 2]
    ; call PrintNumber
    ; mov al, [input_data + 3]
    ; call PrintNumber

    mov ax, [width] ; Load width
    mov dl, ah
    mov dh, al
    mov [width], dx ; Store width in 16-bit variable


    ; Calculate new width
    mov ax, [width]
    imul ax, 3
    sub ax, 2
    mov word [new_width], ax

    ; Perform bilinear interpolation
    call bilinear_interpolation

    ; Open output file
    mov eax, 5          ; sys_open
    mov ebx, output_file ; filename
    mov ecx, 577        ; write-only | create | truncate
    mov edx, 436       ; permissions
    int 0x80
    test eax, eax
    js error
    mov [fd_output], eax

    mov ax, [new_width] ; Load width
    mov dl, ah
    mov dh, al
    mov [new_width], dx ; Store width in 16-bit variable

    ; Write output file
    mov eax, 4          ; sys_write
    mov ebx, [fd_output] ; file descriptor
    mov ecx, new_width ; buffer
    mov edx, 2          ; bytes to write
    int 0x80
    test eax, eax
    js error


    mov ax, [new_width] ; Load width
    mov dl, ah
    mov dh, al
    mov [new_width], dx ; Store width in 16-bit variable
    
    
    ; Write output file
    mov ax, [new_width]
    imul ax
    shl edx, 16
    mov dx, ax
    mov eax, 4          ; sys_write
    mov ebx, [fd_output] ; file descriptor
    mov ecx, output_data ; buffer
    ; mov edx, 8          ; bytes to write
    int 0x80
    test eax, eax
    js error


    ; Close output file
    mov eax, 6          ; sys_close
    mov ebx, [fd_output] ; file descriptor
    int 0x80
    test eax, eax
    js error

    ; Exit program
    mov eax, 1          ; sys_exit
    xor ebx, ebx
    int 0x80

bilinear_interpolation:
    ; Initialize registers
    xor ebx, ebx            ; y = 0
    xor eax, eax            ; x = 0

outer_loop:
    cmp bx, [width]        ; Compare y with width
    jge end_interpolation   ; If y >= width, exit loop
    mov word [x], 0         ; x = 0 (reset inner loop counter)
    
inner_loop:
    xor eax, eax            ; Reset eax
    mov ax, [x]
    cmp ax, [width]        ; Compare x with width
    jge next_row            ; If x >= width, go to next row

    ; call PrintNumber
    ; Calculate input_data offset: y * width + x
    mov ax, bx            ; eax = y
    mul word [width]       ; eax = y * width
    add ax, [x]            ; eax = y * width + x
    ; mov eax, ecx
    ; Load input_data value
    ; call PrintNumber
    mov dl, [input_data + eax] ; dl = input_data[y * width + x]
    ; mov ax, dx
    ; call PrintNumber
    ; call debug_message

    ; Calculate output_data offset: y * new_width * 3 + x * 3
    push dx                 ; Save input_data value on stack
    push bx                ; Save y on stack
    mov ax, bx             ; ax = y
    mul word [new_width]   ; ax = y * new_width
    mov dx, 3              ; dx = 3
    mul dx                 ; dx:ax = y * new_width * 3
    mov bx, ax             ; bx = y * new_width * 3
    mov ax, [x]            ; ax = x
    mov dx, 3              ; dx = 3
    mul dx                 ; dx:ax = x * 3
    add ax, bx             ; ax = y * new_width * 3 + x * 3
    call PrintNumber
    pop bx                 ; Restore y from stack
    pop dx                  ; Restore input_data value


    ; call PrintNumber
    ; Store value in output_data
    mov [output_data + eax], dl ; output_data[y * new_width * 3 + x * 3] = input_data[y * width + x]

    ; Increment x
    add word [x], 1             ; Update x
    jmp inner_loop          ; Repeat inner loop

next_row:
    ; Increment y
    inc bx
    jmp outer_loop          ; Repeat outer loop

end_interpolation:
    ret

error:
    ; Print error message and exit
    mov eax, 4          ; sys_write
    mov ebx, 2          ; stderr
    mov ecx, error_msg
    mov edx, 14
    int 0x80
    mov eax, 1          ; sys_exit
    xor ebx, 1
    int 0x80


PrintNumber:
    push eax
    push ebx
    push ecx
    push edx
    mov ecx, 0
    mov ebx, 10
.loophere:
    mov edx, 0
    div bx                          ;divide by ten

    ; now ax <-- ax/10
    ;     dx <-- ax % 10

    ; print dx
    ; this is one digit, which we have to convert to ASCII
    ; the print routine uses dx and ax, so let's push ax
    ; onto the stack. we clear dx at the beginning of the
    ; loop anyway, so we don't care if we much around with it

    push ax
    add dl, '0'                     ;convert dl to ascii
    pop ax                          ;restore ax
    push dx                         ;digits are in reversed order, must use stack
    inc cx                          ;remember how many digits we pushed to stack
    cmp ax, 0                       ;if ax is zero, we can quit
jnz .loophere

    ;cx is already set
    ;we have to pop the digits from the stack and print them
    mov bx, cx
    mov eax, 0 
.loophere2:
    pop dx                          ;restore digits from last to first
    mov byte [printing + eax], dl
    inc eax                          ;increment the pointer
    loop .loophere2
    mov byte [printing + eax], 10 ;newline
    mov edx, eax
    add edx, 1
    ;print the number
    mov eax, 4
    mov ebx, 1
    mov ecx, printing
    int 0x80
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret


debug_message:
    push eax
    push ebx
    push ecx
    push edx
    ; Print debug message
    mov eax, 4          ; sys_write
    mov ebx, 1          ; stdout
    mov ecx, error_msg
    mov edx, 14         ; length of message
    int 0x80

    pop edx
    pop ecx
    pop ebx
    pop eax
    ret