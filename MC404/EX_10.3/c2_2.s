.section .text
.globl middle_value_int
.globl middle_value_short
.globl middle_value_char
.globl value_matrix
.section .text


#int middle_value_int(int *array, int n){
middle_value_int:
    slli a1, a1, 1
    add t0, a0, a1
    lw a0, 0(t0)
    ret

middle_value_short:
    srli a1, a1, 1
    slli a1, a1, 1
    add t0, a0, a1
    lh a0, 0(t0)
    ret

middle_value_char:
    srli a1, a1, 1
    add t0, a0, a1
    lb a0, 0(t0)
    ret
#int value_matrix(int matrix[12][42], int r, int c){
value_matrix:
    li t1, 42
    slli t1, t1, 2
    mul t0, a1, t1               #cada linha tem 42 numeros (42 * 4). 
    slli t2, a2, 2
    add t0, t0, t2
    add t0, a0, t0
    lw a0, 0(t0)
    ret
