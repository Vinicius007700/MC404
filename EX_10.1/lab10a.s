.section .data
    newline: .asciz "\n"

.section .text
.globl puts
.globl gets
.globl atoi
.globl itoa
.globl linked_list_search
.globl exit

# void puts ( const char *str ); então a0 = *str
puts:
    mv s0, a0  # s0 = pont string
    
    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)

    jal strlen # a0 = len
    mv a2, a0
    lw a1, 4(sp)
    li a0, 1
    li a7, 64
    ecall

break_line:
    la a1, newline
    li a2, 1       
    li a0, 1       
    li a7, 64      
    ecall

    
end_puts:
    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8
    ret

# int strlen(char *str); então a0 = *str
strlen:
    mv t0, a0
strlen_loop:
    lb t1, 0(t0)
    beqz t1, strlen_end
    addi t0, t0, 1
    j strlen_loop
strlen_end:
    sub a0, t0, a0
    ret


# char *gets ( char *str ); então a0 = *str

gets:
    addi sp, sp, -12
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    
    mv s0, a0 # s0 = pont da string
    mv s1, a0 # s1 = pont atual
   
gets_loop:
    mv a1, s1 # a1 é onde eu vou salvar o caractere novo
    li a0, 0
    li a2, 1
    li a7, 63
    ecall

    lb t0, 0(s1)
    li t1, '\n'
    beq t0, t1, end_gets
    addi s1, s1, 1
    j gets_loop

    

end_gets:
    sb zero, 0(s1) 
    mv a0, s0     
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    addi sp, sp, 12
    ret

# int atoi (const char *str); a0 = *str devolve um int
atoi:
    addi sp, sp, -16
    sw ra, 0(sp)
    sw s0, 4(sp)  
    sw s1, 8(sp)       
    sw s2, 12(sp)

    mv s2, a0 # s2 = str
    li s0, 0 # s0 = val acumul
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


    li t1, '0'
    blt t0, t1, atoi_end 
    li t1, '9'
    bgt t0, t1, atoi_end 

    li t1, 10
    mul s0, s0, t1     
    li t1, '0'
    sub t2, t0, t1      
    add s0, s0, t2      

    addi s2, s2, 1      
    j atoi_loop

atoi_end:
    beqz s1, neg_conversion
    j atoi_final
neg_conversion:
    neg s0, s0
atoi_final:
    mv a0, s0  
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    addi sp, sp, 16
    ret


    


# char *itoa ( int value, char *str, int base ); a0 = value, a1 = *str, a2 = base

itoa:
    mv s0, a0 #s0 = int(value)
    mv s1, a1 #s1 = pont string
    mv s2, a2 #s2 = base
    mv s3, a1  #pont atual


    addi sp, sp, -20
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)

    li t0, 10
    li t6, 0 #flag num neg
    li t4, 1 #flag se a conver continua
    


itoa_base_10_neg:   
    bgez s0, itoa_loop #pos continua
    li t0, 10
    bne t0, s2, itoa_loop
    li t6, 1
    neg s0, s0


itoa_loop:
    remu t1, s0, s2    #t1 = resto
    divu s0, s0, s2   #t2 = quo
    
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
    bnez s0, itoa_loop
    beqz t6, itoa_add_null
    li t0, '-'
    sb t0, 0(s3)
    addi s3, s3, 1

itoa_add_null:
    sb zero, 0(s3)
    mv t0, s1 # inicio
    mv t1, s3 #final
    addi t1, t1, -1

itoa_reverse_loop:
    blt t1, t0, itoa_end_conversion
    lb t2, 0(t0)
    lb t3, 0(t1)
    sb t3, 0(t0)
    sb t2, 0(t1)
    addi t0, t0, 1
    addi t1, t1, -1
    j itoa_reverse_loop

itoa_end_conversion:
    mv a0, s1
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    addi sp, sp , 20
    ret

exit:
    li a7, 93
    ecall





#int linked_list_search(Node *head_node, int val);
linked_list_search:
    addi sp, sp, -16
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp) # o index

    li s2, 0
    mv s0, a0
    mv s1, a1
    

linked_loop:
    beqz s0, linked_list_not_find
    lw t0, 0(s0)
    lw t1, 4(s0)
    add t2, t0, t1
    beq t2, s1, linked_loop_find # se é igual acaba a busca

    lw s0, 8(s0)
    addi s2, s2, 1
    j linked_loop

linked_list_not_find:
    li s2, -1
    j linked_loop_find



linked_loop_find:
    mv a0, s2
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    addi sp, sp, 16
    ret
