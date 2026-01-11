.section .data
    buffer: .space 64
.section .text
.globl _start
.set SERIAL_PORT, 0xFFFF0100
.set BUF_SIZE, 128


_start:
    li s0, SERIAL_PORT

    # jal read_str
    # mv a0, sp
    # jal atoi
    li a0, 255
    la a1, buffer
    li a2, 16
    jal itoa          # converte para hexadecimal

    mv t0, a0          # t0 = ponteiro para 'buffer' (retornado por itoa)

find_null:
    lb t1, 0(t0)       # Carrega o caractere
    beqz t1, add_newline # Se for '\0', encontramos o fim
    addi t0, t0, 1
    j find_null

add_newline:
    li t1, 10          # 10 é o código ASCII para '\n' (newline)
    sb t1, 0(t0)       # Sobrescreve o '\0' com '\n'
    addi t0, t0, 1
    sb zero, 0(t0)     # Adiciona um novo '\0' no final
    jal write_str     # imprime o resultado
    j end_program

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
    li a0, 255
    la a1, buffer
    li a2, 16
    jal itoa
    mv a0, a1
    jal write_str
    j end_program








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
    sb zero, 0(s3)
    li t0, '\n'
    addi s3, s3, 1
    sb t0, 0(s3)
    addi s3, s3, -1
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
    

