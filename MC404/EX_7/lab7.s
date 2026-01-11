.section .data
    input_buffer: .space 30
    numbers_array: .space 4
    output_buffer: .space 20

.section .text
.globl _start

_start:
    li a7, 63
    la a1, input_buffer
    li a2, 30
    ecall

parse_first_line:
    la s0, input_buffer
    la s2, numbers_array
    li s5, 4
    
parse_loop:
    beq s5, zero, encoding_task
    lb t1, 0(s0)
    addi s0, s0, 1
    
    li t2, '0'
    blt t1, t2, parse_loop
    li t2, '9'
    bgt t1, t2, parse_loop
    
    addi t1, t1, -'0'
    sb t1, 0(s2)
    addi s2, s2, 1
    addi s5, s5, -1
    j parse_loop

encoding_task:
    la s6, numbers_array
    lb s1, 0(s6)      # s1 = d1
    lb s2, 1(s6)      # s2 = d2
    lb s3, 2(s6)      # s3 = d3
    lb s4, 3(s6)      # s4 = d4

    xor t1, s1, s2
    xor t1, t1, s4    # t1 = p1
    xor t2, s1, s3
    xor t2, t2, s4    # t2 = p2
    xor t3, s2, s3
    xor t3, t3, s4    # t3 = p3
    
    la s0, output_buffer   
    
    mv a0, t1; jal store_char # p1
    mv a0, t2; jal store_char # p2
    mv a0, s1; jal store_char # d1
    mv a0, t3; jal store_char # p3
    mv a0, s2; jal store_char # d2
    mv a0, s3; jal store_char # d3
    mv a0, s4; jal store_char # d4
    

    li t0, '\n'
    sb t0, 0(s0)
    addi s0, s0, 1

    la s1, input_buffer
find_newline:
    lb t1, 0(s1)
    li t2, '\n'
    beq t1, t2, newline_found
    addi s1, s1, 1
    j find_newline
store_char:
    addi t0, a0, '0' 
    sb t0, 0(s0)    
    addi s0, s0, 1   
    ret              

newline_found:# ao encontrarmos uma linha nova, iremos para a última linha de entrada
    addi s1, s1, 1
    
    li a0, 0; jal read_convert; 
    mv s2, a0  # p1'
    
    li a0, 1; 
    jal read_convert; 
    mv s3, a0  # p2'

    li a0, 2; 
    jal read_convert; 
    mv s4, a0  # d1'

    li a0, 3; 
    jal read_convert; 
    mv s5, a0  # p3'

    li a0, 4; 
    jal read_convert; 
    mv s6, a0  # d2'

    li a0, 5; 
    jal read_convert; 
    mv s7, a0  # d3'

    li a0, 6; 
    jal read_convert; 
    mv s8, a0  # d4'

save_encoding_numbers:   
    addi t0, s4, '0'; 
    sb t0, 0(s0); 
    addi s0, s0, 1

    addi t0, s6, '0'; 
    sb t0, 0(s0); 
    addi s0, s0, 1
    
    addi t0, s7, '0'; 
    sb t0, 0(s0); 
    addi s0, s0, 1
    
    addi t0, s8, '0'; 
    sb t0, 0(s0); 
    addi s0, s0, 1

    li t0, '\n';   
    sb t0, 0(s0); 
    addi s0, s0, 1

decoding_task:
    xor t0, s2, s4; 
    xor t0, t0, s6; 
    xor t0, t0, s8
    xor t1, s3, s4; 
    xor t1, t1, s7; 
    xor t1, t1, s8
    xor t2, s5, s6; 
    xor t2, t2, s7; 
    xor t2, t2, s8
    or t0, t0, t1
    or t0, t0, t2


save_decoding_numbers:
    addi t0, t0, '0'; 
    sb t0, 0(s0); 
    addi s0, s0, 1

    li t0, '\n';      
    sb t0, 0(s0)



print_final:
    li a7, 64
    li a0, 1
    la a1, output_buffer
    li a2, 15
    ecall

end_program:
    li a7, 93
    li a0, 0
    ecall

read_convert:
    add t0, s1, a0   
    lb a0, 0(t0)     
    addi a0, a0, -'0'
    ret
