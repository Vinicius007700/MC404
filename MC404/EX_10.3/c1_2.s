.section .text

.globl my_function

my_function:
    addi sp, sp, -16
    sw ra, 0(sp)
    sw a0, 4(sp)
    sw a1, 8(sp)
    sw a2, 12(sp)

    add a0, a0, a1 #sum 1 = a0+ a1 = t3
    lw a1, 4(sp)
    jal mystery_function #((a+b), )a)

    lw a1, 8(sp)
    sub a0, a1, a0 # b - f
    lw a2, 12(sp) 
    add t4, a0, a2 # = aux


    mv a0, t4
    lw a1, 8(sp)
    addi sp, sp, -4
    sw a0, 0(sp)
    
    jal mystery_function # f(aux, b)
    
    lw t5, 0(sp) # aux = t5
    addi sp, sp, 4

    lw a2, 12(sp)
    sub a0, a2, a0
    add a0, a0, t5


    
    lw ra, 0(sp)
    addi sp, sp, 16

    ret


 
