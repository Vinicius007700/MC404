# Arquivo: solution.s
# Descrição: Solução para o exercício "Custom Search on a Linked List".
# O programa lê uma string da entrada, converte-a para um número inteiro,
# percorre uma lista ligada e imprime o índice do primeiro nó cuja soma
# de valores é igual ao número lido. Se não encontrar, imprime -1.

.section .data
    input_buffer: .space 10      # Buffer para ler a string de entrada
    output_buffer: .space 12     # Buffer para converter o resultado para string
    newline: .asciz "\n"

.section .text
.globl _start

_start:
    # --- 1. Ler a string da entrada (STDIN) ---
    li   a0, 0              # 0 = stdin
    la   a1, input_buffer
    li   a2, 10             # Tamanho do buffer
    li   a7, 63             # syscall read
    ecall

    # --- 2. Converter a string para inteiro (Parsing) ---
    la   s0, input_buffer   # s0 = ponteiro para o caractere atual
    add  s1, s0, a0         # s1 = ponteiro para o fim da string lida
    li   s2, 0              # s2 = número acumulado
    li   s3, 0              # s3 = flag de número negativo

parse_loop:
    bge  s0, s1, parse_done # Se chegamos ao fim, termina o parse.
    lb   t0, 0(s0)          # t0 = caractere atual
    addi s0, s0, 1

    li   t1, '-'
    beq  t0, t1, set_negative

    li   t1, '0'
    blt  t0, t1, parse_loop # Ignora caracteres não numéricos (exceto '-')
    li   t1, '9'
    bgt  t0, t1, parse_loop

    # Converte caractere para dígito e acumula
    addi t0, t0, -'0'
    li   t1, 10
    mul  s2, s2, t1
    add  s2, s2, t0
    j    parse_loop

set_negative:
    li   s3, 1              # Marca que o número é negativo
    j    parse_loop

parse_done:
    beqz s3, search_start   # Se não for negativo, pode começar a busca
    neg  s2, s2             # Aplica o sinal negativo

search_start:
    # --- 3. Iniciar a busca na lista ligada ---
    # O número alvo já está em s2.
    la   a0, head_node      # Argumento 1: endereço do primeiro nó
    mv   a1, s2             # Argumento 2: valor alvo
    jal  linked_list_search

    # O resultado (índice ou -1) está em a0.
    # --- 5. Imprimir o resultado ---
    jal  print_integer

    j    exit

# -----------------------------------------------------------------------------
# linked_list_search: Encontra o índice do primeiro nó.
# Argumentos:
#   a0: Endereço do nó inicial (head_node).
#   a1: Valor alvo para a soma.
# Retorno:
#   a0: O índice do nó (>=0), ou -1 se não for encontrado.
# -----------------------------------------------------------------------------
linked_list_search:
    mv   s1, a0             # s1 = ponteiro para o nó atual
    mv   s0, a1             # s0 = valor alvo
    li   s2, 0              # s2 = índice

loop_start:
    beqz s1, not_found

    lw   t0, 0(s1)      # t0 = current_node->VAL1
    lw   t1, 4(s1)      # t1 = current_node->VAL2
    add  t2, t0, t1     # t2 = VAL1 + VAL2

    beq  t2, s0, found  # Se (soma == alvo), encontramos.

    addi s2, s2, 1      # Incrementa o índice: index++.
    lw   s1, 8(s1)      # Atualiza o ponteiro: s1 = current_node->NEXT.
    j    loop_start     # Volta para o início do loop.

found:
    mv   a0, s2         # Move o índice para o registrador de retorno a0.
    ret

not_found:
    li   a0, -1
    ret

# -----------------------------------------------------------------------------
# print_integer: Converte um inteiro para string e o imprime.
# Argumento:
#   a0: O número a ser impresso.
# -----------------------------------------------------------------------------
print_integer:
    addi sp, sp, -16
    sw   ra, 0(sp)
    sw   s0, 4(sp)
    sw   s1, 8(sp)
    sw   a0, 12(sp)         # Salva o número original

    mv   s0, a0             # s0 = número a converter
    la   s1, output_buffer
    add  s1, s1, 10         # Aponta para o fim do buffer
    sb   zero, 1(s1)        # Coloca o terminador nulo

    bnez s0, check_negative # Se for 0, caso especial
    li   t0, '0'
    sb   t0, 0(s1)
    addi s1, s1, -1
    j    print_string

check_negative:
    bgez s0, convert_loop
    neg  s0, s0

convert_loop:
    beqz s0, add_sign
    li   t1, 10
    rem  t3, s0, t1         # CORREÇÃO: Usa t3 para guardar o resto (dígito).
    div  s0, s0, t1
    # A instrução 'div' pode corromper t0, por isso usamos t3.
    addi t3, t3, '0'        # Converte o dígito (de t3) para ASCII.
    sb   t3, 0(s1)
    addi s1, s1, -1
    j    convert_loop

add_sign:
    lw   a0, 12(sp)         # Recupera o número original
    blt  a0, zero, add_minus_sign
    j    print_string
add_minus_sign:
    li   t0, '-'
    sb   t0, 0(s1)
    addi s1, s1, -1

print_string:
    addi s1, s1, 1
    la   s2, output_buffer
    add  s2, s2, 11
    sub  a2, s2, s1         # a2 = tamanho da string
    li   a0, 1              # 1 = stdout
    mv   a1, s1             # a1 = endereço da string
    li   a7, 64             # syscall write
    ecall

    la   a1, newline        # Imprime uma nova linha
    li   a2, 1
    ecall

    lw   ra, 0(sp)
    lw   s0, 4(sp)
    lw   s1, 8(sp)
    addi sp, sp, 16
    ret

exit:
    li   a7, 93             # syscall exit
    ecall