.section .text
.globl node_creation

node_creation:
    addi sp, sp, -13
    mv t5, sp
    sw ra, 12(sp)
    
    li t0, 30
    sw t0, 0(t5)
    addi t5, t5, 4
    
    li t0, 25
    sb t0, 0(t5)
    addi t5, t5, 1
    
    li t0, 64
    sb t0, 0(t5)
    addi t5, t5, 1

    li t0, -12
    sh t0, 0(t5)
    
    mv a0, sp
    jal mystery_function
    lw ra, 12(sp)
    addi sp, sp, 13
    ret

