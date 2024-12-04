section .data
newline db 0x0a, 0x00          ; Newline character for output
nl_len equ $ - newline          ; Length of newline
nums db '0123456789'
prime_msg db ' is prime.', 0
not_prime_msg db ' is not prime.', 0

section .bss
num resq 1                  ; Reserve space for the current number

section .text
global _start

_start:
    mov rdi, 1                  ; Start with number 1

check_next:
    cmp rdi, 100                ; Check if number >= 100
    jge done                    ; If it’s 100 or greater, exit loop

    mov rsi, rdi                ; Copy current number to rsi (for prime checking)
    call is_prime               ; Call is_prime function to check primality

    ; Print number and whether it's prime or not
    call print_number

    cmp rax, 1                  ; If prime (rax = 1), print " is prime."
    je print_prime

    ; Otherwise, print " is not prime."
    mov rsi, not_prime_msg
    call print_string
    jmp print_newline

print_prime:
    mov rsi, prime_msg          ; Print " is prime."
    call print_string
    jmp print_newline

print_newline:
    mov rsi, newline
    call print_string           ; Print newline
    inc rdi                     ; Increment the number
    jmp check_next              ; Check next number

done:
    mov rax, 60                 ; Exit syscall
    xor rdi, rdi                ; Return code 0
    syscall

is_prime:
    ; Check if the number in rsi is prime
    ; rsi holds the number to check
    
    ; If number is 1, it’s not prime
    cmp rsi, 1
    je not_prime_label

    ; Initialize divisor
    mov rbx, 2
    mov rdx, rsi                ; Copy the number to rdx (dividend)

    ; Check divisibility up to sqrt(n) approximation
    ; We'll use a simple loop to check divisibility up to rsi / 2
check_divisibility:
    cmp rbx, rdx
    jge prime_label             ; If divisor >= number, it’s prime

    ; Divide rdx by rbx, remainder goes to rax, quotient to rdx
    mov rax, rdx
    xor rdx, rdx                ; Clear remainder
    div rbx                      ; rdx = rdx % rbx, rax = rdx / rbx

    cmp rdx, 0                  ; If remainder is 0, number is divisible
    je not_prime_label          ; If divisible, number is not prime

    inc rbx                     ; Otherwise, try next divisor
    jmp check_divisibility

prime_label:
    mov rax, 1                  ; Set rax to 1 (prime)
    ret

not_prime_label:
    mov rax, 0                  ; Set rax to 0 (not prime)
    ret

print_number:
    ; Print the current number in rdi
    mov rax, rdi
    ; Convert number to string for printing
    mov rcx, nums
    add rcx, rdi                ; Add rdi to point to correct digit
    mov rbx, 1
    mov rdx, 1
    mov rax, 4                  ; Syscall for write
    int 0x80
    ret

print_string:
    ; Print the string pointed to by rsi
    mov rdx, 0
find_end:
    cmp byte [rsi + rdx], 0
    je print_string_end
    inc rdx
    jmp find_end

print_string_end:
    mov rbx, 1
    mov rax, 4                  ; Syscall for write
    int 0x80
    ret
