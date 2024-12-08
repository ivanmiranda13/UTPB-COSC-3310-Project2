section .data
newline db 0x0a
nl_len equ $ - newline
nums db '123456789101112131415161718192021222324252627282930313233343536373839404142434445464748495051525354555657585960616263646566676869707172737475767778798081828384858687888990919293949596979899'

is_prime_msg db " is prime.", 0x0a, 0x00
is_prime_len equ $ - is_prime_msg
not_prime_msg db " is not prime.", 0x0a, 0x00
not_prime_len equ $ - not_prime_msg

section .text
global _start

_start:
	; Initialize loop
	loop_init:
		xor r10, r10           ; Index for the `nums` array (start from 0)
		mov r11, 1             ; Counter for the current number (1 to 99)

	loop_head:
		cmp r10, 189           ; Check if we've reached the end of the array
		jge loop_exit          ; Exit loop if done

		; Print the number
		mov rcx, nums
		add rcx, r10           ; Point to the current number in `nums`
		mov rdx, 1
		cmp r10, 9
		jl print_number
		add rdx, 1
		print_number:
		mov rbx, 1
		mov rax, 4
		add r10, rdx           ; Update index in `nums`
		int 0x80

		; Check if the current number is prime
		mov r12, r11           ; Save the current number in r12
		call is_prime          ; Check if prime (result in rax: 1 = prime, 0 = not prime)

		; Print " is prime." or " is not prime."
		cmp rax, 1          ; Check the result of `is_prime`
		je print_prime
		mov rcx, not_prime_msg
		mov rdx, not_prime_len
		jmp print_end

	print_prime:
		mov rcx, is_prime_msg
		mov rdx, is_prime_len

	print_end:
		mov rbx, 1
		mov rax, 4
		int 0x80

		; Print a newline
		mov rdx, nl_len
		mov rcx, newline
		mov rbx, 1
		mov rax, 4
		int 0x80

		; Increment the counter
		inc r11                ; Move to the next number
		jmp loop_head

	loop_exit:
		mov rax, 1
		int 0x80

; Subroutine to check if a number is prime
; Input: r12 = number to check
; Output: rax = 1 if prime, 0 if not
is_prime:
	xor rax, rax             ; Default to not prime (rax = 0)
	cmp r12, 2               ; Numbers less than 2 are not prime
	jl not_prime
	cmp r12, 2               ; 2 is prime
	je prime

	mov r13, 2               ; Start divisor at 2
is_prime_loop:
	xor rdx, rdx             ; Clear remainder
	mov rax, r12             ; Load the number into rax
	mov rbx, r13
	div rbx                  ; Divide r12 by r13 (quotient in rax, remainder in rdx)
	cmp rdx, 0            ; Check if remainder is 0
	je not_prime                  ; If divisible, not prime

	inc r13                  ; Check the next divisor
	mov rbx, r13
	mov rax, r13
	mul rbx                  ; r13 * r13 (square of divisor)
	cmp rax, r12             ; Stop if divisor squared > number
	jg prime                 ; If no divisors found, it's prime
	jmp is_prime_loop

not_prime:
  mov rax, 0
  ret
prime:
	mov rax, 1
	ret ; Set as prime
