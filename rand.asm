extern printf
extern scanf

global main

section .data
        test2: db "Le resultat: %d ", 10, 0

section .bss
        number: resb 1

section .text

main:

        push rbp

        rdrand ax

        mov rdi, test2
        movzx rsi, ax
        mov rax, 0
        call printf
end:
        mov rax, 60
        mov rdi, 0
        syscall
        ret



