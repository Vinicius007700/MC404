.section .data
    input_buffer: .space 48
    numbers_array: .space 24
    output_buffer: .space 13

.section .text
.globl _start

_start:
    la a1, input_buffer
    li a0, 0        
    li a2, 48       
    li a7, 63       
    ecall     

    la s0, input_buffer    
    la s2, numbers_array   
    li t6, 6                # t6 = qntd num
    li t5, 0                # t5 = num atual
    li t4, 0                # t4 = 0 = positivo
    li t3, 0                # t3 = flag durant leitura
    add t0, a0, a1          # t0 = ultimo caractere

parse_loop:        
    bge s0, t0, check_last_num 
    lb t1, 0(s0)            # t1 = caractere atual
    addi s0, s0, 1      

    li t2, '0'
    blt t1, t2, check_separator
    li t2, '9'
    bgt t1, t2, check_separator
               
    addi t1, t1, -'0'       
    li t2, 10
    mul t5, t5, t2
    add t5, t5, t1
    j parse_loop

check_separator:
    li t2, ' '
    beq t1, t2, store_number
    li t2, '\n'
    beq t1, t2, store_number

    li t2, '-'
    beq t1, t2, set_negative
    li t2, '+'
    beq t1, t2, set_positive
    j parse_loop 

set_negative:
    li t4, 1 
    j parse_loop

set_positive:
    li t4, 0 
    j parse_loop

store_number:
    beqz t4, apply_sign_done
    neg t5, t5

apply_sign_done:
    
    sw t5, 0(s2)        # final array
    addi s2, s2, 4     
    addi t6, t6, -1     # menos um numero
    
    li t5, 0 
    li t4, 0 
    li t3, 0 
    
    beqz t6, end_read 
    j parse_loop

check_last_num:
    beqz t3, end_read 
    j store_number     
        

end_read:

    la s6, numbers_array  
    lw s0, 0(s6)      # s0 = YB
    lw s1, 4(s6)      # s1 = XC
    lw s2, 8(s6)      #  s2 =TA
    lw s3, 12(s6)     #  s3 =TB 
    lw s4, 16(s6)     # s4 = TC
    lw s5, 20(s6)     # s5 = TR

set_distances:
    # da = (TR - TA) * 3 / 10
    sub t0, s5, s2
    li t6, 3
    mul t0, t0, t6
    li t6, 10
    div t0, t0, t6
    mv t3, t0   # da = t0

    # db
    sub t0, s5, s3
    li t6, 3
    mul t0, t0, t6
    li t6, 10
    div t0, t0, t6
    mv t1, t0   # db = t1

    # dc
    sub t0, s5, s4
    li t6, 3
    mul t0, t0, t6
    li t6, 10
    div t0, t0, t6
    mv t2, t0   # dc = t2


set_y:
    # y = (da^2 + YB^2 - db^2) / (2 * YB)
    mv t0, t3     
    mul t3, t3, t3 # t3 = da^2
    mul t4, s0, s0 # t4 = YB^2
    mul t5, t1, t1 # t5 = db^2
    add t3, t3, t4
    sub t3, t3, t5
    slli t4, s0, 1 # 2 * YB
    div t3, t3, t4
    mv a6, t3      # a6 = y

set_x:
    # x = (da^2 + XC^2 - dc^2) / (2 * XC) - usei um raciocínio semelhante para o x
    mul t3, t0, t0 
    mul t4, s1, s1 # t4 = XC^2
    mul t5, t2, t2 # t5 = dc^2
    add t3, t3, t4
    sub t3, t3, t5
    slli t4, s1, 1 # 2 * XC
    div t3, t3, t4
    mv a7, t3      # a7 = x


set_output_buffer:
    la s0, output_buffer
    addi s0, s0, 12   

    
    addi s0, s0, -1
    li t0, '\n'
    sb t0, 0(s0)

    
    mv t1, a6 # t1 = y
    li t3, 4 # 4 = num de algar
    bltz t1, y_is_neg
    li t2, '+'
    j y_loop

y_is_neg:
    li t2, '-'
    neg t1, t1 

    li t3, 4 

y_loop:
    beqz t3, y_store_sign
    addi s0, s0, -1

    li t6, 10
    rem t0, t1, t6
    div t1, t1, t6
    addi t0, t0, '0'
    sb t0, 0(s0)
    addi t3, t3, -1
    j y_loop

y_store_sign:
    addi s0, s0, -1
    sb t2, 0(s0)

 
    addi s0, s0, -1
    li t0, ' '
    sb t0, 0(s0)

    mv t1, a7 # colocar o x em a7
    li t3, 4
    bltz t1, x_is_neg
    li t2, '+'
    j x_loop

x_is_neg:
    li t2, '-'
    neg t1, t1 


x_loop:
    beqz t3, x_store_sign
    addi s0, s0, -1

    li t6, 10
    rem t0, t1, t6
    div t1, t1, t6
    addi t0, t0, '0'
    sb t0, 0(s0)
    addi t3, t3, -1
    j x_loop

x_store_sign:
    addi s0, s0, -1
    sb t2, 0(s0)

print_final:
    li a0, 1
    mv a1, s0 
    li a2, 12 
    li a7, 64
    ecall

exit_program:
    li a7, 93
    li a0, 0
    ecall