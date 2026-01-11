.section .text

.globl operation

operation:
    # a0 = a, a1 = b, a2 = c
    # a3 = d, a4 = e, a5 = f, 
    #a6 = g, a7 = h
    #0(sp)= i, 4(sp) = j, 8(sp) = k
    #12(sp) = l, 16(sp) = m, 20(sp) = n
    # só inverter
    addi sp, sp, -28
    sw ra, 24(sp)
    mv t0, a0 #pega o a
    lw t1, 48(sp) # pega o n
    mv a0, t1
    sw t0, 20(sp)
    
    mv t0, a1
    lw t1, 44(sp)
    mv a1, t1
    sw t0, 16(sp)

    mv t0, a2
    lw t1, 40(sp)
    mv a2, t1
    sw t0, 12(sp)

    mv t0, a3
    lw t1, 36(sp)
    mv a3, t1
    sw t0, 8(sp)

    mv t0, a4
    lw t1, 32(sp)
    mv a4, t1
    sw t0, 4(sp)

    mv t0, a5
    lw t1, 28(sp)
    mv a5, t1
    sw t0, 0(sp)

    mv t0, a6
    mv a6, a7
    mv a7, t0


   
    jal mystery_function
    lw ra, 24(sp)
    addi sp, sp, 28
    ret

