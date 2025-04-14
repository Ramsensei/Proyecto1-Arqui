section .data
    input_file db "input.img", 0
    output_file db "output.img", 0
    error_msg db "Error occurred", 0
    width dw 0
    new_width dw 0          ; New width of the image

section .bss
    input_data resb 65536  ; Reserve space for input data
    output_data resb 65536 ; Reserve space for output data
    printing resb 65536 ; Reserve space for printing

    fd_input resd 1
    fd_output resd 1
    y resw 1                ; Loop variable y
    x resw 1                ; Loop variable x
    ymod3 resw 1            ; y % 3
    _3mymod3 resw 1         ; 3 - ymod3
    ymymod3 resw 1          ; y - ymod3
    yp3mymod3 resw 1        ; y + _3mymod3
    ymymod3tnewwidth resw 1 ; ymymod3 * new_width
    yp3mymod3tnewwidth resw 1 ; yp3mymod3 * new_width
    ytnewwidth resw 1       ; y * new_width
    xt3 resw 1              ; x * 3
    index1 resw 1           ; ymymod3tnewwidth + xt3
    index2 resw 1           ; yp3mymod3tnewwidth + xt3
    index3 resw 1           ; ytnewwidth + xt3
    data1 resb 1            ; output_data[index1]
    data2 resb 1            ; output_data[index2]
    weight1 resw 1          ; _3mymod3 * data1
    weight2 resw 1          ; ymod3 * data2
    sum_weights resw 1      ; weight1 + weight2
    xmod3 resw 1            ; x % 3
    _3mxmod3 resw 1         ; 3 - xmod3
    xmxmod3 resw 1          ; x - xmod3
    xp3mxmod3 resw 1        ; x + _3mxmod3

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
    jge outer_loop2   ; If y >= width, exit loop
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
    ; call PrintNumber
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

outer_loop2:
    mov word [y], 0               ; y = 0
    mov cx, [new_width]     ; cx = new_width (outer loop limit)

loop_y:
    mov bx, [y]              ; Load y

    cmp bx, [new_width]     ; Compare y with new_width
    jge outer_loop3   ; If y >= new_width, exit loop

    mov word [x], 0         ; x = 0 (reset inner loop counter)

loop_x:
    mov ax, [x]
    cmp ax, [width]         ; Compare x with width
    jge next_row2           ; If x >= width, go to next row

    ; Calculate output_data[y * new_width + x * 3]
    mov ax, [y]              ; ax = y
    mul word [new_width]    ; ax = y * new_width
    push ax                 ; Save y * new_width on stack
    mov ax, [x]             ; ax = x
    mov dx, 3               ; dx = 3
    mul dx                  ; dx:ax = x * 3
    pop dx                  ; Restore y * new_width
    add ax, dx              ; ax = y * new_width + x * 3
    mov al, [output_data + eax] ; al = output_data[index]
    cmp al, 0               ; Check if output_data[index] == 0
    jne skip_interpolation  ; If not 0, skip interpolation
    ; call PrintNumber

    ; Interpolation calculations
    xor dx, dx              ; Clear dx
    mov ax, [y]              ; ax = y
    mov cx, 3               ; cx = 3
    div cx                  ; dx = y % 3, ax = y / 3
    mov [ymod3], dx         ; ymod3 = y % 3
    mov ax, 3               ; ax = 3
    sub ax, dx              ; ax = 3 - ymod3
    mov [_3mymod3], ax      ; _3mymod3 = 3 - ymod3
    mov ax, [y]             ; ax = y
    sub ax, [ymod3]         ; ax = y - ymod3
    mov [ymymod3], ax       ; ymymod3 = y - ymod3
    mov ax, [y]             ; ax = y
    add ax, [_3mymod3]      ; ax = y + _3mymod3
    mov [yp3mymod3], ax     ; yp3mymod3 = y + _3mymod3

    ; Calculate ymymod3 * new_width
    mov ax, [ymymod3]       ; ax = ymymod3
    mul word [new_width]    ; ax = ymymod3 * new_width
    mov [ymymod3tnewwidth], ax

    ; Calculate yp3mymod3 * new_width
    mov ax, [yp3mymod3]    ; ax = yp3mymod3
    mul word [new_width]   ; ax = yp3mymod3 * new_width
    mov [yp3mymod3tnewwidth], ax

    ; Calculate y * new_width
    mov ax, [y]            ; ax = y
    mul word [new_width]   ; ax = y * new_width
    mov [ytnewwidth], ax

    ; Calculate x * 3
    mov ax, [x]
    mov cx, 3
    mul cx
    mov [xt3], ax

    ; Calculate indices
    mov ax, [ymymod3tnewwidth]
    add ax, [xt3]
    mov [index1], ax

    mov ax, [yp3mymod3tnewwidth]
    add ax, [xt3]
    mov [index2], ax

    mov ax, [ytnewwidth]
    add ax, [xt3]
    mov [index3], ax

    ; Load data1 and data2
    xor eax, eax
    mov ax, [index1]
    mov al, [output_data + eax]
    mov [data1], al

    xor eax, eax
    mov ax, [index2]
    mov al, [output_data + eax]
    mov [data2], al

    ; Calculate weights
    mov ax, [_3mymod3]
    mul byte [data1]
    mov [weight1], ax

    mov ax, [ymod3]
    mul byte [data2]
    mov [weight2], ax

    ; Calculate sum_weights
    mov ax, [weight1]
    add ax, [weight2]
    mov [sum_weights], ax

    ; Divide sum_weights by 3 and store in output_data[index3]
    mov ax, [sum_weights]
    xor dx, dx
    mov cx, 3
    div cx
    xor edx, edx
    mov dx, [index3]
    mov [output_data + edx], al

    
skip_interpolation:
    add word [x], 1         ; x++
    jmp loop_x              ; Repeat inner loop

next_row2:
    add word [y], 1         ; y++
    jmp loop_y              ; Repeat outer loop

outer_loop3:
    mov word [y], 0               ; y = 0
    mov cx, [new_width]     ; cx = new_width (outer loop limit)

loop_y3:
    mov bx, [y]              ; Load y
    cmp bx, cx              ; Compare y with new_width
    jg end_interpolation  ; If y >= new_width, exit loop

    mov word [x], 0         ; x = 0 (reset inner loop counter)

loop_x3:
    mov ax, [x]
    cmp ax, [new_width]     ; Compare x with new_width
    jge next_row3           ; If x >= new_width, go to next row

    ; Calculate output_data[y * new_width + x]
    mov ax, [y]              ; ax = y
    mul word [new_width]    ; ax = y * new_width
    add ax, [x]             ; ax = y * new_width + x
    mov al, [output_data + eax] ; al = output_data[index]

    cmp al, 0               ; Check if output_data[index] == 0
    jne skip_interpolation3 ; If not 0, skip interpolation

    ; Interpolation calculations
    xor dx, dx              ; Clear dx
    mov ax, [x]             ; ax = x
    mov cx, 3               ; cx = 3
    div cx                  ; dx = x % 3, ax = x / 3
    mov [xmod3], dx         ; xmod3 = x % 3
    mov ax, cx              ; ax = 3
    sub ax, dx              ; ax = 3 - xmod3
    mov [_3mxmod3], ax      ; _3mxmod3 = 3 - xmod3
    mov ax, [x]             ; ax = x
    sub ax, dx              ; ax = x - xmod3
    mov [xmxmod3], ax       ; xmxmod3 = x - xmod3
    add ax, [_3mxmod3]      ; ax = x + _3mxmod3
    mov [xp3mxmod3], ax     ; xp3mxmod3 = x + _3mxmod3

    ; Calculate y * new_width
    mov ax, [y]
    mul word [new_width]
    mov [ytnewwidth], ax

    ; Calculate indices
    mov ax, [ytnewwidth]
    add ax, [xmxmod3]
    mov [index1], ax

    mov ax, [ytnewwidth]
    add ax, [xp3mxmod3]
    mov [index2], ax

    mov ax, [ytnewwidth]
    add ax, [x]
    mov [index3], ax

    ; Load data1 and data2
    xor eax, eax
    mov ax, [index1]
    mov al, [output_data + eax]
    mov [data1], al

    xor eax, eax
    mov ax, [index2]
    mov al, [output_data + eax]
    mov [data2], al

    ; Calculate weights
    mov ax, [_3mxmod3]
    mul byte [data1]
    mov [weight1], ax

    mov ax, [xmod3]
    mul byte [data2]
    mov [weight2], ax

    ; Calculate sum_weights
    mov ax, [weight1]
    add ax, [weight2]
    mov [sum_weights], ax

    ; Divide sum_weights by 3 and store in output_data[index3]
    mov ax, [sum_weights]
    xor dx, dx
    mov cx, 3
    div cx
    xor edx, edx
    mov dx, [index3]
    mov [output_data + edx], al

skip_interpolation3:
    add word [x], 1         ; x++
    jmp loop_x3             ; Repeat inner loop

next_row3:
    add word [y], 1         ; y++
    jmp loop_y3             ; Repeat outer loop

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