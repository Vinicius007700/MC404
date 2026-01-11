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
        li a0, 3           
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

    setCanvasSize:
        mv a0, s2
        mv a1, s3
        li a7, 2201
        ecall

        li s4, 0            # y = 0
        
    loop_y:
        bge s4, s3, end_program # Se y cheg a alt
        li s5, 0            # x = 0 
    loop_x:
        bge s5, s2, next_y  # Se x chega a larg
       
        
        lbu t0, 0(s1) 
        addi s1, s1, 1
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
        blt t0, t4, end_ascii_to_int #fora de intervalos válidos
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