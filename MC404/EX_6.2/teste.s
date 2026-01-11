.section .data
input_buffer:   .space 48
numbers_array:  .space 24    # 6 words (YB, XC, TA, TB, TC, TR)
output_buffer:  .space 13    # CORREÇÃO: Buffer para "+xxxx +yyyy\n\0"

.section .text
.globl _start
_start:
    # --- 1. Ler toda a entrada para um buffer ---
    la a1, input_buffer
    li a0, 0          # fd = stdin
    li a2, 48         # max bytes
    li a7, 63         # sys_read
    ecall
    mv s1, a0         # s1 = bytes lidos

    # --- 2. Parser: extrair 6 inteiros com sinal para numbers_array ---
    la s0, input_buffer   # ponteiro de leitura
    la s2, numbers_array  # ponteiro de escrita
    li t6, 6              # contador de números a ler
    li t5, 0              # acumulador do número atual
    li t4, 0              # flag de sinal (0=positivo, 1=negativo)
    li t3, 0              # flag se está lendo um número

parse_loop:
    la t0, input_buffer
    add t0, t0, s1        # t0 = ponteiro final
    bge s0, t0, check_last_num # se fim do buffer, processa último número

    lb t1, 0(s0)          # t1 = caractere atual
    addi s0, s0, 1        # avança ponteiro

    # Verifica se é um dígito
    li t2, '0'
    blt t1, t2, check_separator
    li t2, '9'
    bgt t1, t2, check_separator

    # É um dígito, acumula
    li t3, 1              # está lendo um número
    addi t1, t1, -'0'
    li t2, 10
    mul t5, t5, t2
    add t5, t5, t1
    j parse_loop

check_separator:
    # Não é dígito, verifica se é um separador (espaço ou \n)
    li t2, ' '
    beq t1, t2, store_number
    li t2, '\n'
    beq t1, t2, store_number

    # Verifica se é um sinal
    li t2, '-'
    beq t1, t2, set_negative
    li t2, '+'
    beq t1, t2, set_positive
    j parse_loop # Ignora outros caracteres

set_negative:
    li t4, 1
    j parse_loop
set_positive:
    li t4, 0
    j parse_loop

store_number:
    beqz t3, parse_loop # Se não estava lendo um número, ignora (ex: múltiplos espaços)
    beqz t4, apply_sign_done
    neg t5, t5
apply_sign_done:
    sw t5, 0(s2)
    addi s2, s2, 4
    addi t6, t6, -1
    li t5, 0 # zera acumulador
    li t4, 0 # zera sinal
    li t3, 0 # zera flag de leitura
    beqz t6, parse_done
    j parse_loop

check_last_num:
    beqz t3, parse_done # Se não estava lendo um número no final, termina
    j store_number

parse_done:
    # --- 3. Carregar valores e calcular distâncias ---
    la s6, numbers_array  # CORREÇÃO: Usar s6 como ponteiro para não sobrescrever s2
    lw s0, 0(s6)      # YB
    lw s1, 4(s6)      # XC
    lw s2, 8(s6)      # TA
    lw s3, 12(s6)     # TB
    lw s4, 16(s6)     # TC
    lw s5, 20(s6)     # TR

    # da = (TR - TA) * 3 / 10
    sub t0, s5, s2
    li t6, 3
    mul t0, t0, t6
    li t6, 10
    div t0, t0, t6
    mv t3, t0   # CORREÇÃO: Salva 'da' em t3 para não ser sobrescrito

    # db = (TR - TB) * 3 / 10
    sub t0, s5, s3
    li t6, 3
    mul t0, t0, t6
    li t6, 10
    div t0, t0, t6
    mv t1, t0   # Salva 'db' em t1

    # dc = (TR - TC) * 3 / 10
    sub t0, s5, s4
    li t6, 3
    mul t0, t0, t6
    li t6, 10
    div t0, t0, t6
    mv t2, t0   # Salva 'dc' em t2

    # --- 4. Calcular y e x ---
    # y = (da^2 + YB^2 - db^2) / (2 * YB)
    mv t0, t3      # CORREÇÃO: Salva 'da' em t0 antes que t3 seja modificado

    mul t3, t3, t3 # t3 = da^2
    mul t4, s0, s0 # t4 = YB^2
    mul t5, t1, t1 # t5 = db^2
    add t3, t3, t4
    sub t3, t3, t5
    slli t4, s0, 1 # 2 * YB
    div t3, t3, t4
    mv a6, t3      # a6 = y

    # x = (da^2 + XC^2 - dc^2) / (2 * XC)
    mul t3, t0, t0 # CORREÇÃO: Usa o valor salvo de 'da' para calcular da^2
    mul t4, s1, s1 # t4 = XC^2
    mul t5, t2, t2 # t5 = dc^2
    add t3, t3, t4
    sub t3, t3, t5   # CORREÇÃO: Subtrair dc^2 (t5) em vez de XC^2 (t4)
    slli t4, s1, 1 # 2 * XC
    div t3, t3, t4
    mv a7, t3      # a7 = x

    # --- 5. Formatar e imprimir a saída ---
    # Constrói a string "±xxxx ±yyyy\n" de trás para frente no buffer
    la s0, output_buffer
    addi s0, s0, 12   # CORREÇÃO: Ponteiro para o final do buffer

    # Nova linha
    addi s0, s0, -1
    li t0, '\n'
    sb t0, 0(s0)

    # Formatar Y (a6)
    mv t1, a6
    bltz t1, y_is_neg
    li t2, '+'
    j format_y_digits
y_is_neg:
    li t2, '-'
    neg t1, t1
format_y_digits:
    li t3, 4 # 4 dígitos
y_loop:
    beqz t3, y_store_sign
    addi s0, s0, -1
    li t6, 10
    rem t4, t1, t6
    div t1, t1, t6
    addi t4, t4, '0'
    sb t4, 0(s0)
    addi t3, t3, -1
    j y_loop
y_store_sign:
    addi s0, s0, -1
    sb t2, 0(s0)

    # Espaço
    addi s0, s0, -1
    li t0, ' '
    sb t0, 0(s0)

    # Formatar X (a7)
    mv t1, a7
    bltz t1, x_is_neg
    li t2, '+'
    j format_x_digits
x_is_neg:
    li t2, '-'
    neg t1, t1
format_x_digits:
    li t3, 4 # 4 dígitos
x_loop:
    beqz t3, x_store_sign
    addi s0, s0, -1
    li t6, 10
    rem t4, t1, t6
    div t1, t1, t6
    addi t4, t4, '0'
    sb t4, 0(s0)
    addi t3, t3, -1
    j x_loop
x_store_sign:
    addi s0, s0, -1
    sb t2, 0(s0)

print_final:
    li a0, 1
    addi a1, output_buffer # O ponteiro s0 agora aponta para o início da string
    li a2, 12
    li a7, 64
    ecall

exit_program:
    li a7, 93
    li a0, 0
    ecall














        


        

        

        
        
        
