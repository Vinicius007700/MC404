.section .text

.globl operation

operation:
    add t0, a1, a2 # b + c
    sub t0, t0, a5
    add t0, t0, a7
    lw t1, 8(sp)
    add t0, t0, t1
    lw t1, 16(sp)
    sub t0, t0, t1
    mv a0, t0
    ret