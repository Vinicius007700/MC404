.section .data
    input_buffer: .space 64
    numbers_array: .space 80
    output: .space 5 # 4 dígitos + terminador
    space: .asciz " "
    newline: .asciz "\n"



.section .text
.globl _start

_start:

    li a7, 63
    li a0, 0 # file descriptor = 0 (stdin)
    la a1, input_buffer
    li a2, 64 # tamanho máximo da entrada
    ecall

    la s0, input_buffer #ponteiro para o caract atual
    add s1, s0, a0 #ponteiro para o final da entrada
    la s2, numbers_array #ponteiro para a posição atual no array de números
    li s3, 0 #contador de números convertidos
    li t0, 0 #acumulador para o número atual
    li t1, 0 #flag, indica se estamos no meio de um número

int_loop:
    bge s0, s1, end_read
    lb t2, 0(s0) #t2 = caractere atual
    li t3, ' ' 
    beq t2, t3, end_number
    li t3, '\n'
    beq t2, t3, end_number
    
    li t1, 1 #meio de número
    addi t2, t2, -'0'
    li t4, 10 
    mul t0, t0, t4 #acumulador = acumulador * 10
    add t0, t0, t2 #acumulador = acumulador + dígito
    j next_char

end_number:
    beqz t1, next_char # Se a flag for 0, ignora (ex: múltiplos espaços)
    sw t0, 0(s2) #salva no array
    addi s2, s2, 4 #avança o ponteiro do array
    addi s3, s3, 1 #incrementa o contador de números
    li t0, 0 #zera o acumulador
    li t1, 0 #zera a flag
    j next_char

next_char:
    addi s0, s0, 1 #avança para o próximo caractere da entrada
    j int_loop

end_read: # Trata o caso do último número não ser seguido por um espaço.
    beqz t1, process_numbers
    sw t0, 0(s2)
    addi s3, s3, 1

process_numbers:
    la s2, numbers_array #ponteiro para o início do array de números
    li s4, 0 # s4 = contador de números já processados

process_loop:
    bge s4, s3, end_all_numbers # Se já processámos todos, termina.
    
    lw a4, 0(s2) # a4 = número a ser processado
    
    jal square_root # raiz = a5

    mv t0, a5 # Move o resultado para t0 para a função de impressão
    jal print_number # Chama a função de impressão

    # Verifica se é o último número para imprimir ' ' ou '\n'
    addi t1, s4, 1
    beq t1, s3, print_final_newline

    jal print_space
    j after_separator

print_final_newline:
    jal print_newline

after_separator:
    addi s2, s2, 4 # avança para o próximo número no array
    addi s4, s4, 1 # incrementa o contador
    j process_loop

square_root:
    srli a5, a4, 1 # k
    li t1, 10      # t1 = contador de 10 iterações

interation_square_root:
    bnez t1, loop_body
    ret

loop_body:
    div t3, a4, a5 # t3 = N / k
    add t3, a5, t3 # t3 = k + (N / k)
    srli a5, t3, 1 # a5 = novo palpite (k')
    addi t1, t1, -1 
    j interation_square_root

print_number:
    la t2, output
    addi t2, t2, 3          # t2 = ponteiro para a última posição de dígito (unidades)
    li t3, 4                # t3 = contador de 4 dígitos

convert_loop:
    beqz t3, print_string   # Se o contador for zero, termina a conversão
    li t4, 10
    rem t5, t0, t4          # t5 = resto (dígito atual)
    div t0, t0, t4          # t0 = número / 10
    addi t5, t5, '0'        # Converte o dígito para ASCII
    sb t5, 0(t2)            # Guarda o dígito no buffer
    
    addi t2, t2, -1         # Move o ponteiro do buffer para a esquerda
    addi t3, t3, -1         # Decrementa o contador de dígitos
    j convert_loop

print_string:
    li a0, 1
    la a1, output
    li a2, 4
    li a7, 64
    ecall

print_space:
    li a0, 1
    la a1, space
    li a2, 1
    li a7, 64
    ecall
    ret

print_newline:
    li a0, 1
    la a1, newline
    li a2, 1
    li a7, 64
    ecall
    ret

end_all_numbers:
    li a7, 93
    li a0, 0
    ecall

