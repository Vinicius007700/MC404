    .section data
        x_test_track: .word 73
        y_test_track: .word 1
        z_test_track: .word -19

    .section .text
    .globl _start
    .set SELF_DRIVE_CAR, 0xFFFF0100


    on_GPS:
        addi sp, sp, -4
        sw ra, 0(sp)
        li t0, 1
        sb t0, 0(s0)
        j wait_GPS  

    wait_GPS:
        lb t0, 0(s0)
        bnez t0, wait_GPS
        j end_GPS #acabou a leitura do GPS, se ele for desacionado
        

    end_GPS:
        addi a1, s0, 0x10
        lw t0, 0(a1) # posição X do carrinho

        addi a1, s0, 0x14
        lw t1, 0(a1) # posição Y do carrinho

        addi a1, s0, 0x18
        lw t2, 0(a1) # posição Z do carrinho

        lw ra, 0(sp)
        addi sp, sp, 4
        ret

    release_hand_break:
        li t0, 0
        sb t0, 0x22(s0)       # Escreve 0 no freio de mão
        ret


    forward:
        li t0, 1
        sb t0, 0x21(s0)
        li t0, 0
        sb t0, 0x20(s0)
        ret

    off_motor:
        li t0, 0
        sb t0, 0x21(s0)
        li t0, 1 #liga o freio de mão
        sb t0, 0x22(s0)
        ret


    turn_left:
        li t0, -15
        sb t0, 0x20(s0)
        ret



    turn_right:
        li t0, 15
        sb t0, 0x20(s0)
        ret


    _start:
        li s0, SELF_DRIVE_CAR
        
        
        la t0, x_test_track # t0 = x_track
        lw s1, 0(t0) 

        la t0, z_test_track
        lw s2, 0(t0)
        jal release_hand_break


    _start_loop:
        jal on_GPS

        lw t0, 0x10(s0) # x 
        lw t1, 0x14(s0) # y
        lw t2, 0x18(s0) # z

        bge t2, s2, stop_car

        blt t0, s1, turn_right_loop

        bgt t0, s1, turn_left_loop

        jal forward

        j _start_loop


    stop_car:
        jal off_motor
        li a7, 93
        ecall

    turn_left_loop:
        jal turn_left
        li t0, 1            
        sb t0, 0x21(s0)
        j _start_loop

    turn_right_loop:
        jal turn_right
        li t0, 1            
        sb t0, 0x21(s0)
        j _start_loop








        



