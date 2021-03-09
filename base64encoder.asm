SECTION .data           ; Section containing initialised data
    Base64Table: db "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

    Base64Str:         db "===="
    Base64StrLen:      equ $-Base64Str

SECTION .bss            ; Section containing uninitialized data
    InBufLen:   equ 3
    InBuf:      resb InBufLen

SECTION .text           ; Section containing code

global _start           ; Linker needs this to find the entry point!

_start:

read:
    ; Read from stdin to InBuf
    mov rax, 0                      ; sys_read
    mov rdi, 0                      ; file descriptor: stdin
    mov rsi, InBuf                  ; destination buffer
    mov rdx, InBufLen               ; maximum # of bytes to read
    syscall

    mov r8, rax                     ; save this for later

    xor rax, rax
    xor rbx, rbx

    mov rbx, [InBuf]
    mov al, bl
    shl rax, 8
    shr rbx, 8
    mov al, bl
    shl rax, 8
    shr rbx, 8
    mov al, bl
    mov rbx, rax

    cmp r8, 0                      ; length of bytes read in r8, did we receive any bytes?
    je exit                         ; if length = 0: exit the program
    cmp r8, 2
    je mask3
    cmp r8, 1
    je mask2

mask4:

    mov rax, rbx
    and rax, 0x3F
    mov al, byte [Base64Table+rax]
    mov [Base64Str+3], al

mask3:

    mov rax, rbx
    shr rax, 6
    and rax, 0x3F
    mov al, byte [Base64Table+rax]
    mov [Base64Str+2], al

mask2:

    mov rax, rbx
    shr rax, 12
    and rax, 0x3F
    mov al, byte [Base64Table+rax]
    mov [Base64Str+1], al

mask1:

    mov rax, rbx
    shr rax, 18
    and rax, 0x3F
    mov al, byte [Base64Table+rax]
    mov [Base64Str], al



    ; Write a line to stdout
    mov rax, 1                      ; sys_write
    mov rdi, 1                      ; file descriptor: stdout
    mov rsi, Base64Str                ; source buffer
    mov rdx, Base64StrLen            ; # of bytes to write
    syscall

    mov qword [Base64Str], "===="
    jmp read

exit:

    mov rax, 60         ; Code for exit
    mov rdi, 0          ; Return a code of zero
    syscall             ; Make kernel call