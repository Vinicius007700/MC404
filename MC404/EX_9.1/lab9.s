.section .data
    input_buffer: .space 12
    output_buffer: .space 12
    newline: .asciz "\n"

.section .text
.globl _start

_start:
    li a0, 0             
    la a1, input_buffer    
    li a2, 12              
    li a7, 63              
    ecall


    la s0, input_buffer    
    add s1, s0, a0         
    li s2, 0              
    li s3, 0    # flag se o num é negativo

ascii_to_int:
    bge s0, s1, end_conversion

    lb t0, 0(s0)            # t0 = caractere atual
    addi s0, s0, 1        

    li t1, '-'
    beq t0, t1, set_negative

    li t1, '+'
    beq t0, t1, ascii_to_int 

    li t1, '0'
    blt t0, t1, end_conversion 
    li t1, '9'
    bgt t0, t1, end_conversion  

    addi t0, t0, -'0'

    li t1, 10
    mul s2, s2, t1
    add s2, s2, t0
    j ascii_to_int

set_negative:
    li s3, 1              
    j ascii_to_int

end_conversion:
    beqz s3, end_read # se o num é positivo, pula a linha de baixo
    neg s2, s2         

end_read:
    li s4, 0                # s4 = pos atual
    la s5, head_node        # s5 = pont nó atual

search_loop: #a0 recebe a pos do nó
    beqz s5, not_found # pont = 0 == NULL

    lw t0, 0(s5)            
    lw t1, 4(s5)         

    add t2, t0, t1 #t2 é a soma dos nós

    
    beq t2, s2, found   #se igual achamos e para a busca  


    addi s4, s4, 1          
    lw s5, 8(s5)            # Temos 2 num de 4 bits cada no nó 
    j search_loop

found:
    mv a0, s4              
    j print_result

not_found:
    li a0, -1


print_result:
    mv s6, a0               
    la s7, output_buffer
    add s7, s7, 10  #apont para o fim do buffer    
          
    bnez s6, check_sign
    li t0, '0'
    sb t0, 0(s7)
    addi s7, s7, -1
    j print_string

check_sign:
    bgez s6, conversion_loop
    neg s6, s6

conversion_loop:
    beqz s6, add_sign
    li t0, 10
    rem t1, s6, t0         
    div s6, s6, t0         
    addi t1, t1, '0'       
    sb t1, 0(s7)           
    addi s7, s7, -1        
    j conversion_loop

add_sign: #colocar -, se for -1
    bltz a0, add_negative
    j print_string

add_negative:
    li t0, '-'
    sb t0, 0(s7)
    addi s7, s7, -1

print_string:
    addi s7, s7, 1

    
    la t0, output_buffer
    add t0, t0, 11
    sub a2, t0, s7       # a2 = tamanho da string
    li a0, 1                
    mv a1, s7            
    li a7, 64               
    ecall

    li a0, 1
    la a1, newline
    li a2, 1
    li a7, 64
    ecall

exit_program:
    li a7, 93
    li a0, 0               
    ecall

    