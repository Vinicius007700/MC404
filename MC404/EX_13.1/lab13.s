.data
    buffer_1: .space 64
    buffer_2: .space 64
    

.section .text
.globl _start
.set SERIAL_PORT, 0xFFFF0100
.set BUF_SIZE, 128


_start:
    addi sp, sp, -BUF_SIZE
    li s0, SERIAL_PORT
    mv a0, sp
    jal read_str
    mv a0, sp
    jal atoi
    mv t0, a0
    li t1, 1
    
    beq t0, t1, operation_1
    
    li t1, 2    
    beq t0, t1, operation_2

    li t1, 3
    beq t0, t1, operation_3
    
    li t1, 4
    beq t0, t1, operation_4


operation_1:
    mv a0, sp
    jal read_str #str em *a0
    mv a0, sp
    jal write_str
    j end_program

operation_2:
    mv a0, sp
    jal read_str
    mv a0, sp
    jal reverse_str
    mv a0, sp
    jal write_str
    j end_program

operation_3:
    mv a0, sp
    jal read_str
    mv a0, sp
    jal atoi
    la a1, buffer_1
    li a2, 16
    jal itoa ## char *itoa ( int value, char *str, int base ); a0 = value, a1 = *str, a2 = 16
    jal write_str
    j end_program


operation_4:

    mv a0, sp
    addi a0, a0, 20 
    jal read_str    
    
    mv s1, a0      
    mv a0, s1       
    jal atoi
           
    mv s2, a0       
    mv s1, a1       

    mv a0, s1       
    jal det_sign   
    mv s3, a1      
    mv s1, a0     

    mv a0, s1     
    jal atoi       
    mv s4, a0      

    mv a0, s3
    mv a1, s2
    mv a2, s4
    jal calculate
    
    # O resultado está em a0
    la a1, buffer_1
    li a2, 10
    jal itoa
    jal write_str

    
    j end_program


    
    
    
calculate: #
    addi sp, sp, -4
    sw ra, 0(sp)
    
    beqz a0, operation_minus

    li t0, 1
    beq t0, a0, operation_plus

    li t0, 2
    beq t0, a0, operation_mul

    li t0, 3
    beq t0, a0, operation_div

operation_minus:
    sub a0, a1, a2
    j end_calculate

operation_plus:
    add a0, a1, a2
    j end_calculate

operation_mul:
    mul a0, a1, a2
    j end_calculate

operation_div:
    div a0, a1, a2
    j end_calculate
end_calculate:
    lw ra, 0(sp)
    addi sp, sp, 4
    ret


det_sign:
    addi sp, sp, -4
    sw ra, 0(sp)
    
    lb t0, 0(a0)
    addi a0, a0, 1
    
    li t1, ' '
    beq t0, t1, det_sign

    li t1, '-'
    beq t0, t1, sign_minus

    li t1, '+'
    beq t0, t1, sign_plus
    
    li t1, '*'
    beq t0, t1, sign_mul

    li t1, '/'
    beq t0, t1, sign_div

sign_minus:
    li a1, 0
    j end_det_sign




sign_plus:
    li a1, 1
    j end_det_sign


sign_mul:
    li a1, 2
    j end_det_sign

sign_div:
    li a1, 3
    j end_det_sign

end_det_sign:
    addi a0, a0, 1
    lw ra, 0(sp)
    addi sp, sp, 4
    ret
    


    


split_str:
    addi sp, sp, -4
    sw ra, 0(sp)
    li a1, 0 #acumulador do num


loop_split_str:
    lb t0, 0(a0)
    beqz t0, end_split_str
    li t0, 10
    beq t0, t1, end_split_str
    li t0, ' '
    beq t0, t1, end_split_str
    li t1, '0'
    blt t0, t1, end_split_str
    li t1, '9'
    bgt t0, t1, end_split_str
    addi a1, a1, 1
    j loop_split_str

end_split_str:
    lw ra, 0(sp)
    addi sp, sp, 4
    ret #ret a0 = nova str/ a1 = novo num






write_str:
    addi sp, sp, -8
    sw ra, 0(sp)
    sw s1, 4(sp)

    mv s1, a0

write_loop:
    lb t0, 0(s1)    # Carrega char da string
    beqz t0, end_write # Termina no '\0'

wait_write:
    lb t1, 0(s0)
    bnez t1, wait_write
    # 2. Escreve o caractere em 0x01
    sb t0, 1(s0)
    # 3. Aciona a escrita
    li t0, 1
    sb t0, 0(s0)


    addi s1, s1, 1  # Avança ponteiro da string
    j write_loop







end_write:
    lw ra, 0(sp)
    lw s1, 4(sp)
    addi sp, sp, 8
    ret




read_str:
    
    addi sp, sp, -8
    sw ra, 4(sp)
    sw s1, 0(sp)
    
    mv s1, a0
    
   

 

loop_read:
    li t0, 1
    sb t0, 0x02(s0)

wait_read:
    lb t0, 0x02(s0)
    bnez t0, wait_read
    
    lb t0, 0x03(s0)
    beqz t0, loop_read # Ignora se for 0 (stdin vazia)
    sb t0, 0(s1)
    addi s1, s1, 1

    li t1, 10
    beq t0, t1, end_read
    j loop_read
    
    # # Se for \0 (stdin vazia), apenas espera de novo
    # beq t0, zero, read_loop



end_read:
    sb zero, 0(s1)
    #mv a0, sp
    lw ra, 4(sp)
    lw s1, 0(sp)

    addi sp, sp, 8
    ret

atoi:
    addi sp, sp, -16
    sw ra, 0(sp)
    sw s3, 4(sp)  
    sw s1, 8(sp)       
    sw s2, 12(sp)

    mv s2, a0 # s2 = str
    li s3, 0 # s3 = val acumul
    li s1, 1  # flag sinal

    lb t0, 0(s2)       
    li t1, '-'
    beq t0, t1, atoi_neg #ver se é negativo

    j atoi_loop        

atoi_neg:
    li s1, 0
    addi s2, s2, 1
    

atoi_loop:
    lb t0, 0(s2)        
    beqz t0, atoi_end   

    li t1, 10
    beq t0, t1, atoi_end 


    li t1, '0'
    blt t0, t1, atoi_end 
    li t1, '9'
    bgt t0, t1, atoi_end 

    li t1, 10
    mul s3, s3, t1     
    li t1, '0'
    sub t2, t0, t1      
    add s3, s3, t2      

    addi s2, s2, 1      
    j atoi_loop

atoi_end:
    beqz s1, neg_conversion
    j atoi_final

neg_conversion:
    neg s3, s3

atoi_final:
    mv a0, s3
    mv a1, s2
    lw ra, 0(sp)
    lw s3, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    addi sp, sp, 16
    ret

reverse_str:
    addi sp, sp, -4
    sw ra, 0(sp)
    mv t0, a0 # t0 = começo
    mv t1, a0 # t1 = fim

find_final_str:
    lb t2, 0(t1)
    beqz t2, prepare_reverse
    li t3, 10
    beq t2, t3, prepare_reverse
    addi t1, t1, 1
    j find_final_str

prepare_reverse:
    addi t1, t1, -1
loop_reverse:
    blt t1, t0, end_reverse
    lb t2, 0(t0)
    lb t3, 0(t1)
    sb t3, 0(t0)
    sb t2, 0(t1)
    addi t0, t0, 1
    addi t1, t1, -1
    j loop_reverse

end_reverse:
    lw ra, 0(sp)
    addi sp, sp, 4
    ret


itoa:

    addi sp, sp, -20
    sw ra, 0(sp)
    sw s4, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)

    mv s4, a0 #s0 = int(value)
    mv s1, a1 #s1 = pont string
    mv s2, a2 #s2 = base
    mv s3, a1  #pont atual

    li t0, 10
    li t6, 0 #flag num neg
    li t4, 1 #flag se a conver continua
    


itoa_base_10_neg:   
    bgez s4, itoa_loop #pos continua
    li t0, 10
    bne t0, s2, itoa_loop
    li t6, 1
    neg s4, s4


itoa_loop:
    remu t1, s4, s2    #t1 = resto
    divu s4, s4, s2   #t2 = quo
    
    li t2, 10
    blt t1, t2, itoa_digit

                      
    addi t1, t1, -10
    addi t1, t1, 'A'
    
    j itoa_store

itoa_digit:
    addi t1, t1, '0'

itoa_store:    
    sb t1, 0(s3)
    addi s3, s3, 1
    bnez s4, itoa_loop
    beqz t6, itoa_add_null
    li t0, '-'
    sb t0, 0(s3)
    addi s3, s3, 1

itoa_add_null:
    li t0, 10          # Carrega 10 ('\n')
    sb t0, 0(s3)
    addi s3, s3, 1
    sb zero, 0(s3)
    mv a0, s1
    jal reverse_str
    mv a0, s1
    lw ra, 0(sp)
    lw s4, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    addi sp, sp , 20
    ret




end_program:
    addi sp, sp, BUF_SIZE
    li a0, 0
    li a7, 93
    ecall
    

