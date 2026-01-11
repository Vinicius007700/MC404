.section .text
.globl node_op

node_op:
    lw t0, 0(a0) # t0 = int a
    lb t1, 4(a0) # t1 = char b
    lb t2, 5(a0) # t2 = char c
    lh t3, 6(a0) # t3 = short d
    add t0, t0, t1
    sub t0, t0, t2
    add t0, t0, t3
    mv a0, t0
    ret