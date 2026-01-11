.section .bss
my_array:
    .space 400

.section .text

.globl fill_array_int
.globl fill_array_short
.globl fill_array_char

fill_array_int:
    addi sp, sp, -408
    sw ra, 404(sp)
    mv t2, sp
    li t0, 100
    li t1, 0    

loop_fill_array:
    bge t1, t0, call_mystery
    sw t1, 0(t2)
    addi t1, t1, 1
    addi t2, t2, 4
    j loop_fill_array

call_mystery:
    mv a0, sp
    jal mystery_function_int
    lw ra, 404(sp)
    addi sp, sp, 408
    ret

fill_array_short:
    addi sp, sp, -204
    sw ra, 200(sp)
    mv t2, sp
    li t0, 100
    li t1, 0    

loop_fill_array_short:
    bge t1, t0, call_mystery_short
    sh t1, 0(t2)
    addi t1, t1, 1
    addi t2, t2, 2
    j loop_fill_array_short

call_mystery_short:
    mv a0, sp
    jal mystery_function_short
    lw ra, 200(sp)
    addi sp, sp, 204
    ret
    
fill_array_char:
    addi sp, sp, -101
    sw ra, 100(sp)
    
    mv t2, sp
    li t0, 100
    li t1, 0    

loop_fill_array_char:
    bge t1, t0, call_mystery_char
    sb t1, 0(t2)
    addi t1, t1, 1
    addi t2, t2, 1
    j loop_fill_array_char

call_mystery_char:
    mv a0, sp
    jal mystery_function_char
    lw ra, 100(sp)
    addi sp, sp, 101
    ret

