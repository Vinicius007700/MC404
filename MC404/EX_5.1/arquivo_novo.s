# Este código integra a lógica original do utilizador com as correções essenciais
# de inicialização da pilha e uma função de impressão formatada robusta.

.section .data
    input_buffer: .space 64
    numbers_array: .space 80
    # Buffer para a conversão de um único número para uma string de 4 dígitos
    four_digit_buffer: .space 5 # 4 dígitos + terminador
    space: .asciz " "
    newline: .asciz "\n"

# Secção para dados não inicializados, como a pilha.
.section .bss
    .space 1024                  # Aloca 1KB para a pilha
stack_top:                       # Rótulo para o topo da pilha

.section .text
.globl _start

_start:
    # --- Secção 0: Inicializar o Stack Pointer (Ponteiro da Pilha) ---
    # É crucial apontar o SP para uma zona de memória válida e alocada.
    la sp, stack_top

    # --- Secção 1: Ler a entrada do utilizador (lógica original) ---
    li a7, 63
    li a0, 0 # file descriptor = 0 (stdin)
    la a1, input_buffer
    li a2, 64 # tamanho máximo da entrada
    ecall
    blez a0, exit_program # Se nada foi lido, sai.

    # --- Secção 2: Converter a String para um Array de Inteiros (lógica original) ---
    la s0, input_buffer #ponteiro para o caract atual
    add s1, s0, a0 #ponteiro para o final da entrada
    la s2, numbers_array #ponteiro para a posição atual no array de números
    li s3, 0 #contador de números convertidos
    li t0, 0 #acumulador para o número atual
    li t1, 0 #flag, indica se estamos no meio de um número

int_loop:
    bge s0, s1, end_parse
    lb t2, 0(s0) #t2 = caractere atual
    li t3, ' ' 
    beq t2, t3, end_number
    li t3, '\n'
    beq t2, t3, end_number
    
    li t1, 1 #meio de número
    addi t2, t2, -'0' # Converte de ASCII para inteiro
    li t4, 10 # t4 = 10
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

end_parse: # Trata o caso do último número não ser seguido por um espaço.
    beqz t1, process_numbers
    sw t0, 0(s2)
    addi s3, s3, 1

process_numbers:
    # --- Secção 3: Loop Principal - Processa cada número do array ---
    la s2, numbers_array #ponteiro para o início do array de números
    li s4, 0 # s4 = contador de números já processados

process_loop:
    bge s4, s3, exit_program # Se já processámos todos, termina.
    
    lw a4, 0(s2) # a4 = número a ser processado
    
    jal calc_square_root # O resultado da raiz volta em a5

    mv t0, a5 # Move o resultado para t0 para a função de impressão
    jal print_integer_4_digit

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

# --- Função para Calcular a Raiz Quadrada Inteira (lógica original adaptada) ---
# Argumento: a4 = O número N
# Retorno:   a5 = A raiz quadrada de N
calc_square_root:
    blez a4, return_zero_root
    li t0, 1
    beq a4, t0, return_one_root
    
    # Inicia o cálculo
    li t1, 0 # t1 = contador de iterações
    li t2, 10 # max de interações
    srli a5, a4, 1 # Palpite inicial: a5 = N / 2

iteration_sqrt:
    beq t1, t2, return_sqrt # Se atingiu o máximo de iterações, retorna.
    beqz a5, return_sqrt # Evita divisão por zero se o palpite for 0
    
    div t3, a4, a5 # t3 = N / palpite
    add t3, a5, t3 # t3 = palpite + (N / palpite)
    srli a5, t3, 1 # Novo palpite = t3 / 2
    
    addi t1, t1, 1 # incrementa o contador de passos
    j iteration_sqrt
return_zero_root:
    li a5, 0
    ret
return_one_root:
    li a5, 1
    ret
return_sqrt:
    ret

# --- Função para Imprimir um Inteiro com 4 Dígitos ---
# Converte o número para uma string de 4 dígitos num buffer e depois imprime.
# Argumento: t0 = número a imprimir
print_integer_4_digit:
    addi sp, sp, -20
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw t1, 16(sp)

    mv s0, t0               # s0 = número a converter
    la s1, four_digit_buffer
    addi s1, s1, 3          # Aponta para a última posição de dígito (unidades)
    li s2, 4                # s2 = contador de 4 dígitos

convert_loop:
    beqz s2, print_string   # Se o contador for zero, termina a conversão
    
    li t1, 10
    rem t0, s0, t1          # t0 = resto (dígito atual)
    div s0, s0, t1          # s0 = número / 10
    addi t0, t0, '0'        # Converte o dígito para ASCII
    sb t0, 0(s1)            # Guarda o dígito no buffer
    
    addi s1, s1, -1         # Move o ponteiro do buffer para a esquerda
    addi s2, s2, -1         # Decrementa o contador de dígitos
    j convert_loop

print_string:
    li a0, 1
    la a1, four_digit_buffer
    li a2, 4
    li a7, 64
    ecall

    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw t1, 16(sp)
    addi sp, sp, 20
    ret

# --- Funções Auxiliares de Impressão ---
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

# --- Fim do Programa ---
exit_program:
    li a7, 93
    li a0, 0
    ecall

