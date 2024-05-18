.section .data
    message_addi_first: .ascii " 00000 000 00010 0010011\n"
    message_addi_second: .ascii " 00000 000 00001 0010011\n"
    message_add: .ascii "0000000 00010 00001 000 00001 0110011\n"
    message_sub: .ascii "0100000 00010 00001 000 00001 0110011\n"
    message_mul: .ascii "0000001 00010 00001 000 00001 0110011\n"
    message_and: .ascii "0000111 00010 00001 000 00001 0110011\n"
    message_or: .ascii "0000110 00010 00001 000 00001 0110011\n"
    message_xor: .ascii "0000100 00010 00001 000 00001 0110011\n"
    
.section .bss
input_buffer : .space 256  # Allocate 256 bytes for input buffer
output_buffer : .space 1024
inter_buffer : .space 256
char_buffer : .space 1 # bunu .dataya koyunca kod mıçıyor, niye lan niye. bunu buraya koymak için 4 saat harcadım ulan niye

.section .text
.global _start

_start:
    # Read input from standard input
    mov $0, %eax          # syscall number for sys_read
    mov $0, %edi          # file descriptor 0 (stdin)
    lea input_buffer(%rip), %rsi  # pointer to the input buffer
    mov $256, %edx         # maximum number of bytes to read
    syscall               # perform the syscall

    // pushl %ebp
    // mov %esp, %ebp
    // sub $40, %esp

    push $'.'
    //we are pushing a dot to the stack to indicate that there is no number in the stack previously
    lea input_buffer(%rip), %r12
    mov $0, %r13
    mov $0, %r9

process:
    #here we are going to examine the input char by char
    // if there is an operation sign we are going to call the corresponding module
    mov $0, %rbx
    movb (%r12), %bl
    cmp $'+', %rbx        # Check if we've parsed all input
    je plus_module
    cmp $'-', %rbx
    je minus_module
    cmp $'^', %rbx
    je xor_module
    cmp $'*', %rbx
    je mult_module
    cmp $'&', %rbx
    je and_module
    cmp $'|', %rbx
    je or_module
    cmp $'\n', %rbx
    je exit_program         
    cmp $' ', %rbx
    je whitespace

    // cmp $0, %rbx
    // je nullz
    // if we come here, it means we have a number

    sub $48, %rbx
    inc %r12
    inc %r13
    pop %r9
    cmp $'.', %r9
    je isdot
    #it means there is a previous number in the stack
    imul $10, %r9
    add %r9, %rbx
    push %rbx
    jmp process
nullz:
    inc %r12
    jmp process
isdot:
    push $'.'
    
    push %rbx
    jmp process
whitespace:
    //since we should consider whitespace as a delimiter, we should check if there is a number in the stack
    inc %r12
    inc %r13
    pop %r9
    cmp $'.', %r9
    je new
    push %r9
    push $'.'
    jmp cont
    new:
    push %r9
    cont:
    jmp process


plus_module:
    //in this module we are going to pop the last two numbers from the stack and add them
    //we pop two times to eliminate the dot in the stack
    //for other operator modules the logic is the same as this one

    inc %r12
    inc %r13
    pop %r8
    pop %r8
    mov %r8, %r14
    mov $12, %r10
    //print the first number in binary
    jmp bit_print_plus_one
    // and then print its machine code of RISCV instructions
    p1:
    mov $1, %rax
    mov $1, %rdi
    lea message_addi_first(%rip), %rsi
    mov $25, %rdx
    syscall
    //do basically the same things for the second number
    pop %r9
    pop %r9
    mov %r9, %r14
    mov $12, %r10
    jmp bit_print_plus_sec
    p2:
    mov $1, %rax
    mov $1, %rdi
    lea message_addi_second(%rip), %rsi
    mov $25, %rdx
    syscall

    add %r8, %r9
    push %r9
    #printing
    //at the end we are going to print the operations RISCV machine code
    mov $1, %rax
    mov $1, %rdi
    lea message_add(%rip), %rsi
    mov $38, %rdx
    syscall
    jmp process
minus_module:
    inc %r12
    inc %r13
    pop %r8
    pop %r8
    mov %r8, %r14
    mov $12, %r10
    jmp bit_print_minus_one
    min1:
    mov $1, %rax
    mov $1, %rdi
    lea message_addi_first(%rip), %rsi
    mov $25, %rdx
    syscall

    pop %r9
    pop %r9
    mov %r9, %r14
    mov $12, %r10
    jmp bit_print_minus_sec
    min2:
    mov $1, %rax
    mov $1, %rdi
    lea message_addi_second(%rip), %rsi
    mov $25, %rdx
    syscall

    sub %r8, %r9
    push %r9
    #printing
    mov $1, %rax
    mov $1, %rdi
    lea message_sub(%rip), %rsi
    mov $38, %rdx
    syscall
    jmp process
mult_module:
    inc %r12
    inc %r13
    pop %r8
    pop %r8
    mov %r8, %r14
    mov $12, %r10
    jmp bit_print_multi_one
    multi1:
    mov $1, %rax
    mov $1, %rdi
    lea message_addi_first(%rip), %rsi
    mov $25, %rdx
    syscall

    pop %r9
    pop %r9
    mov %r9, %r14
    mov $12, %r10
    jmp bit_print_multi_sec
    multi2:
    mov $1, %rax
    mov $1, %rdi
    lea message_addi_second(%rip), %rsi
    mov $25, %rdx
    syscall

    imul %r8, %r9
    push %r9
    #printing
    mov $1, %rax
    mov $1, %rdi
    lea message_mul(%rip), %rsi
    mov $38, %rdx
    syscall
    jmp process
and_module:
    inc %r12
    inc %r13
    pop %r8
    pop %r8
    mov %r8, %r14
    mov $12, %r10
    jmp bit_print_and_one
    and1:
    mov $1, %rax
    mov $1, %rdi
    lea message_addi_first(%rip), %rsi
    mov $25, %rdx
    syscall

    pop %r9
    pop %r9
    mov %r9, %r14
    mov $12, %r10
    jmp bit_print_and_sec
    and2:
    mov $1, %rax
    mov $1, %rdi
    lea message_addi_second(%rip), %rsi
    mov $25, %rdx
    syscall

    and %r8, %r9
    push %r9
    #printing
    mov $1, %rax
    mov $1, %rdi
    lea message_and(%rip), %rsi
    mov $38, %rdx
    syscall
    jmp process
or_module:
    inc %r12
    inc %r13
    pop %r8
    pop %r8
    mov %r8, %r14
    mov $12, %r10
    jmp bit_print_or_one
    or1:
    mov $1, %rax
    mov $1, %rdi
    lea message_addi_first(%rip), %rsi
    mov $25, %rdx
    syscall

    pop %r9
    pop %r9
    mov %r9, %r14
    mov $12, %r10
    jmp bit_print_or_sec
    or2:
    mov $1, %rax
    mov $1, %rdi
    lea message_addi_second(%rip), %rsi
    mov $25, %rdx
    syscall

    or %r8, %r9
    push %r9
    #printing
    mov $1, %rax
    mov $1, %rdi
    lea message_or(%rip), %rsi
    mov $38, %rdx
    syscall
    jmp process
xor_module:
    inc %r12
    inc %r13
    pop %r8
    pop %r8
    mov %r8, %r14
    mov $12, %r10
    jmp bit_print_xor_one
    xor1:
    mov $1, %rax
    mov $1, %rdi
    lea message_addi_first(%rip), %rsi
    mov $25, %rdx
    syscall

    pop %r9
    pop %r9
    mov %r9, %r14
    mov $12, %r10
    jmp bit_print_xor_sec
    xor2:
    mov $1, %rax
    mov $1, %rdi
    lea message_addi_second(%rip), %rsi
    mov $25, %rdx
    syscall

    xor %r8, %r9
    push %r9
    #printing
    mov $1, %rax
    mov $1, %rdi
    lea message_xor(%rip), %rsi
    mov $38, %rdx
    syscall
    jmp process

bit_print_plus_one:
    //here we take a number to print in binary
    //we manipulate the number to get the bits seperately
    //we do it by shifting the number to left at each iteration and then anding it with 2048 (2^12 since we want 12 bits)
    //after and operation we shift the number to right 11 times to get the bit we want
    //and then print it out
    //this logic is followe for each bit printer modules
    mov %r14, %r11
    and $2048, %r11
    shr $11, %r11
    add $48, %r11
    
    mov %r11, char_buffer
    mov $1, %rax        
    mov $1, %rdi       
    lea char_buffer, %rsi      
    mov $1, %rdx
    syscall
    
    shl $1, %r14
    dec %r10
    jnz bit_print_plus_one
    jmp p1

bit_print_plus_sec:
    mov %r14, %r11
    and $2048, %r11
    shr $11, %r11
    add $48, %r11
    
    mov %r11, char_buffer
    mov $1, %rax        
    mov $1, %rdi       
    lea char_buffer, %rsi     
    mov $1, %rdx
    syscall

    shl $1, %r14
    dec %r10
    jnz bit_print_plus_sec
    jmp p2
bit_print_minus_one:
    mov %r14, %r11
    and $2048, %r11
    shr $11, %r11
    add $48, %r11
    
    mov %r11, char_buffer
    mov $1, %rax        
    mov $1, %rdi       
    lea char_buffer, %rsi     
    mov $1, %rdx
    syscall

    shl $1, %r14
    dec %r10
    jnz bit_print_minus_one
    jmp min1
bit_print_minus_sec:
    mov %r14, %r11
    and $2048, %r11
    shr $11, %r11
    add $48, %r11
    
    mov %r11, char_buffer
    mov $1, %rax        
    mov $1, %rdi       
    lea char_buffer, %rsi     
    mov $1, %rdx
    syscall

    shl $1, %r14
    dec %r10
    jnz bit_print_minus_sec
    jmp min2
bit_print_multi_one:

    mov %r14, %r11
    and $2048, %r11
    shr $11, %r11
    add $48, %r11
    
    mov %r11, char_buffer
    mov $1, %rax        
    mov $1, %rdi       
    lea char_buffer, %rsi      
    mov $1, %rdx
    syscall
    
    shl $1, %r14
    dec %r10
    jnz bit_print_multi_one
    jmp multi1
bit_print_multi_sec:

    mov %r14, %r11
    and $2048, %r11
    shr $11, %r11
    add $48, %r11
    
    mov %r11, char_buffer
    mov $1, %rax        
    mov $1, %rdi       
    lea char_buffer, %rsi      
    mov $1, %rdx
    syscall
    
    shl $1, %r14
    dec %r10
    jnz bit_print_multi_sec
    jmp multi2



bit_print_and_one:

    mov %r14, %r11
    and $2048, %r11
    shr $11, %r11
    add $48, %r11
    
    mov %r11, char_buffer
    mov $1, %rax        
    mov $1, %rdi       
    lea char_buffer, %rsi      
    mov $1, %rdx
    syscall
    
    shl $1, %r14
    dec %r10
    jnz bit_print_and_one
    jmp and1
bit_print_and_sec:

    mov %r14, %r11
    and $2048, %r11
    shr $11, %r11
    add $48, %r11
    
    mov %r11, char_buffer
    mov $1, %rax        
    mov $1, %rdi       
    lea char_buffer, %rsi      
    mov $1, %rdx
    syscall
    
    shl $1, %r14
    dec %r10
    jnz bit_print_and_sec
    jmp and2

bit_print_or_one:

    mov %r14, %r11
    and $2048, %r11
    shr $11, %r11
    add $48, %r11
    
    mov %r11, char_buffer
    mov $1, %rax        
    mov $1, %rdi       
    lea char_buffer, %rsi      
    mov $1, %rdx
    syscall
    
    shl $1, %r14
    dec %r10
    jnz bit_print_or_one
    jmp or1
bit_print_or_sec:

    mov %r14, %r11
    and $2048, %r11
    shr $11, %r11
    add $48, %r11
    
    mov %r11, char_buffer
    mov $1, %rax        
    mov $1, %rdi       
    lea char_buffer, %rsi      
    mov $1, %rdx
    syscall
    
    shl $1, %r14
    dec %r10
    jnz bit_print_or_sec
    jmp or2
bit_print_xor_one:

    mov %r14, %r11
    and $2048, %r11
    shr $11, %r11
    add $48, %r11
    
    mov %r11, char_buffer
    mov $1, %rax        
    mov $1, %rdi       
    lea char_buffer, %rsi      
    mov $1, %rdx
    syscall
    
    shl $1, %r14
    dec %r10
    jnz bit_print_xor_one
    jmp xor1
bit_print_xor_sec:

    mov %r14, %r11
    and $2048, %r11
    shr $11, %r11
    add $48, %r11
    
    mov %r11, char_buffer
    mov $1, %rax        
    mov $1, %rdi       
    lea char_buffer, %rsi      
    mov $1, %rdx
    syscall
    
    shl $1, %r14
    dec %r10
    jnz bit_print_xor_sec
    jmp xor2

exit_program:
    # Exit the program
    mov $60, %eax         # syscall number for sys_exit
    xor %edi, %edi        # exit code 0
    syscall

