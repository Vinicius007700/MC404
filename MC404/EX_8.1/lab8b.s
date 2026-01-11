    .section .data
        input_file: .asciz "image.pgm"
        input_buffer: .space 1050000

    .section .text
    .globl _start

    _start:
        la a0, input_file   
        li a1, 0            
        li a2, 0            
        li a7, 1024          
        ecall

    save_input_buffer:
        mv s0, a0           
        mv a0, s0
        la a1, input_buffer
        li a2, 1050000      
        li a7, 63        
        ecall


        mv s6, a0           
        la s7, input_buffer 
        add s7, s7, s6      # s7 última pos do input_buffer



        la s1, input_buffer

    close_image:
        li a0, 3            # file descriptor (fd) 3
        li a7, 57           # syscall close
        ecall

        jal loop_jump_first_line # Pula P5
        jal jump_line_spaces 

    save_width:
        jal ascii_to_int
        mv s2, t1           # s2 = largura

    save_height:
        jal ascii_to_int
        mv s3, t1           # s3 = altura
        jal jump_line_spaces 
    
    jumpMaxValue:
        jal ascii_to_int
        jal jump_line_spaces

    set_Stack: # Eu resolvi esse problema com pilha
        slli t0, s3, 2 #t0 = s3(alt)*4. O tamanho dos ponteiros. Vou fazer uma lista de lista
        mul t1, s3, s2
        add t2, t1, t0 #t2 = tam de uma matriz
        slli t3, t2, 1 # *2, pois são duas listas

        sub sp, sp, t3 
        mv s8, sp # s8 = o começo lista de m_in

        add s9, sp, t2 # s9 = começo de Mout
        add s10, s8, t0 #s10 = pont para os pixels de mint
        li t3, 0 #cont linhas
        mv t4, s10 #y atual
    
    loop_rows_min:
        bge t3, s3, mout_matrix # se linha>=alt, acabou

        slli t5, t3, 2 #o ponteiro tem 4 bits
        add t6, s8, t5 # t6 é a pos[y] do ponteiro
        sw t4, 0(t6) # salvar o ponteiro da linha
        li t5, 0 # cont col

    col_loop_min:
        bge t5, s2, end_col_min

        lbu t6, 0(s1) #carrega a entrada
        sb t6, 0(t4)
        addi t4, t4, 1 #prox pont de min
        addi s1, s1, 1 #prox input_buffer
        addi t5, t5, 1 #prox col

        j col_loop_min

    end_col_min:
        addi t3, t3, 1 #prox linha
        j loop_rows_min


    mout_matrix:
        add s10, s9, t0 # s10 fim de Mout
                        #s9 comeco de Mout
        li t3, 0  # t3 = cont linhas
        mv t4, s10 # t4 = pos_atual

    loop_rows_mout:
        bge t3, s3, filter #se linha>=alt

        slli t5, t3, 2 #tamanho dos pont
        add t6, s9, t5 # t6 = ender da linha y
        sw t4, 0(t6) # Salva o ender da linha
        li t5, 0 # t5 = cont col

    zero_loop:
        bge t5, s2, end_row_mout  
        sb zero, 0(t4)  # 0 nos pixeis
        addi t4, t4, 1 #+1 end
        addi t5, t5, 1 #+1 col
        j zero_loop

    end_row_mout:
        addi t3, t3, 1 # +1 linha
        j loop_rows_mout


    filter:
        li s4, 1 # y = 1
    
    filter_loop_y:
        addi t0, s3, -1     # t0 = altura - 1
        bge s4, t0, setCanvasSize #aq acabou
    
        li s5, 1 # x = 1, para pular borda
    filter_loop_x:
        addi t0, s2, -1  
        bge s5, t0, filter_next_y 

        li t6, 0 #acumulador soma

    central_pixel:
        mv a1, s4  # a1 = y
        mv a2, s5  # a2 = x
        jal get_pixel_min # a0 = pixel
        slli t0, a0, 3  # t0 = 8 * pixel
        add t6, t6, t0    

    sub_neighborhood:  
        addi a1, s4, -1
        addi a2, s5, -1 #cord = (y-1,x-1)
        jal get_pixel_min # a0 = pixel antigo
        sub t6, t6, a0
        
        addi a1, s4, -1 #cord = (y-1,x)
        mv a2, s5
        jal get_pixel_min
        sub t6, t6, a0
        
        addi a1, s4, -1 #cord = (y-1,x+1)
        addi a2, s5, 1
        jal get_pixel_min
        sub t6, t6, a0
       
        mv a1, s4 # cord = (y,x-1)
        addi a2, s5, -1
        jal get_pixel_min
        sub t6, t6, a0
        
        mv a1, s4 # cord = (y,x+1)
        addi a2, s5, 1
        jal get_pixel_min
        sub t6, t6, a0
       
        addi a1, s4, 1 # cord = (y+1,x-1)
        addi a2, s5, -1
        jal get_pixel_min
        sub t6, t6, a0
        
        addi a1, s4, 1 #cord = (y+1,x)
        mv a2, s5 
        jal get_pixel_min
        sub t6, t6, a0
        
        addi a1, s4, 1 #cord = (y+1,x+1)
        addi a2, s5, 1
        jal get_pixel_min
        sub t6, t6, a0

        blt t6, zero, next_pixel_x # se for 0 ou menor, não vai mudar a nossa matriz
        li t0, 255
        bgt t6, t0, max_255
        j save_filtered_pixel

    max_255:
        li t6, 255

    save_filtered_pixel: 
        slli t0, s4, 2
        add t0, s9, t0
        lw t1, 0(t0)
        add t1, t1, s5 # pegar o endereço da col
        sb t6, 0(t1)

    next_pixel_x:
        addi s5, s5, 1 # x++
        j filter_loop_x

    filter_next_y:
        addi s4, s4, 1  # y++
        j filter_loop_y

    get_pixel_min: #a1 = y, a2 = x, a0 = pixel ant
        slli t0, a1, 2 # t0 = y * 4
        add t0, s8, t0 # t0 = &Min[y]
        lw t0, 0(t0) # t0 = ponteiro para o início da linha y
        
        add t0, t0, a2 # t0 = (x,y)      
        lbu a0, 0(t0)       

        ret

    setCanvasSize:
        mv a0, s2
        mv a1, s3
        li a7, 2201
        ecall
        li s4, 0            # pos y = 0
        
    loop_y:
        bge s4, s3, end_program # Se y cheg a alt
        li s5, 0            # pos x = 0 
    loop_x:
        bge s5, s2, next_y  # Se pos x chega a larg
       
        slli t0, s4, 2      # t0 = y * 4
        add t0, s9, t0      # t0 = &Mout[y]
        lw t1, 0(t0)        # t1 = ponteiro para o início da linha y em Mout
    
        add t1, t1, s5      # t1 = endereço do pixel (x,y)
        lbu t0, 0(t1)       # t0 = valor do pixel (1 byte)

    Red:
        slli t2, t0, 24 # empurra para a esquerda 24 bits

    Green:
        slli t3, t0, 16 # empurra para a esquerda 16 bits
        or t2, t2, t3   

    Blue:
        slli t3, t0, 8
        or t2, t2, t3

    Alpha:
        li t3, 255
        or t2, t2, t3
        
    setPixel:
        mv a0, s5
        mv a1, s4
        mv a2, t2
        li a7, 2200
        ecall
        
        addi s5, s5, 1      # x++
        j loop_x

    next_y:
        addi s4, s4, 1      # y++
        j loop_y


    jump_line_spaces:
        lb t0, 0(s1)
        li t1, '\n'
        beq t0, t1, jump_and_continue
        li t1, ' '
        beq t0, t1, jump_and_continue
        ret 

    jump_and_continue:
        addi s1, s1, 1
        j jump_line_spaces

    ascii_to_int:
        li t1, 0 # t1 = acumulador

    loop_ascii_to_int:
        bge s1, s7, end_ascii_to_int 
        lb t0, 0(s1)
        li t4, '0'
        blt t0, t4, end_ascii_to_int
        li t4, '9'
        bgt t0, t4, end_ascii_to_int


        addi s1, s1, 1
        addi t0, t0, -'0'
        li t4, 10
        mul t1, t1, t4
        add t1, t1, t0
        j loop_ascii_to_int

    end_ascii_to_int:
        addi s1, s1, 1
        ret

    loop_jump_first_line:
        lbu t0, 0(s1)
        addi s1, s1, 1
        li  t1, '\n'
        bne t1, t0, loop_jump_first_line
        ret

    end_program:
        li a7, 93
        li a0, 0
        ecall   