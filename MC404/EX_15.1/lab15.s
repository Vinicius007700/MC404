.section .data
    engine:
        .word 10
    hand_brake:
        .word 11
    #line_camera:
     #   .word 12
    get_position:
        .word 15
    x_test_track: 
        .word 73
    y_test_track: 
        .word 1
    z_test_track: 
        .word -19
    actual_x:
        .word 0
    actual_y:
        .word 0
    actual_z:
        .word 0
    .align
    .skip 1024
    stack_main:

    
.text
.set SELF_DRIVE_CAR, 0xFFFF0100
.align 4

int_handler:
###### Syscall and Interrupts handler ######

# <= Implement your syscall handler here
csrr t0, mcause
li t1, 8
beq t0, t1, exceptions

handler_mret:

csrr t0, mepc  # load return address (address of
                # the instruction that invoked the syscall)    
addi t0, t0, 4 # adds 4 to the return address (to return after ecall)
csrw mepc, t0  # stores the return address back on mepc
mret           # Recover remaining context (pc <- mepc)

exceptions:
    lw t0, engine
    beq a7, t0, syscall_engine
    
    lw t0, hand_brake
    beq a7, t0, syscall_hand_brake
    
    #li t0, line_camera
    #beq a7, t0, syscall_line_camera
    
    lw t0, get_position
    beq a7, t0, syscall_get_position
    j handler_mret

syscall_engine:
    addi sp, sp, -12
    sw ra, 0(sp)
    sw a0, 4(sp)
    sw a1, 8(sp)
    jal verify_movement_engine
    li t0, -1
    beq a0, t0, engine_error
    lw a0, 8(sp)

    jal verify_steering_engine
    li t0, -1
    beq a0, t0, engine_error
    
    lw a0, 4(sp)
    jal save_steering_direction_engine
    lw a0, 8(sp)
    jal save_steering_wheel_engine
    li a0, 0


end_syscall_engine:
    lw ra, 0(sp)
    addi sp, sp, 12
    j handler_mret

engine_error:
    li a0, -1
    j end_syscall_engine


save_steering_wheel_engine:
    li s0, SELF_DRIVE_CAR
    sb a0, 0x20(s0)
    ret

save_steering_direction_engine:
    li s0, SELF_DRIVE_CAR
    sb a0, 0x21(s0)
    ret


verify_movement_engine:
    li s0, SELF_DRIVE_CAR
    li t0, 1
    beq a0, t0, end_verify_movement_engine
    mv t1, a0
    neg t1, t1
    beq t1, t0, end_verify_movement_engine
    beqz a0, end_verify_movement_engine
    li a0, -1
    ret

end_verify_movement_engine:
    li a0, 0
    ret

verify_steering_engine:
    li t0, 127
    bgt a0, t0, end_verify_steering_engine_error
    li t0, -127
    blt a0, t0, end_verify_steering_engine_error
    li a0, 0
    ret

end_verify_steering_engine_error:
    li a0, -1
    ret




syscall_hand_brake:
    li t0, 0
    beq a0, t0, stop_hand_break
    li t0, 1
    beq a0, t0, use_hand_break
    li a0, -1
    j handler_mret

use_hand_break:
    li s0, SELF_DRIVE_CAR
    li t0, 1
    sb t0, 0x22(s0)
    li a0, 0
    j handler_mret

stop_hand_break:
    li s0, SELF_DRIVE_CAR
    li t0, 0
    sb t0, 0x22(s0)
    li a0, 0
    j handler_mret



syscall_get_position:
    addi sp, sp, -12
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)

    li s0, SELF_DRIVE_CAR
    jal loads_x_position
    lw a0, 4(sp)
    jal loads_y_position
    lw a0, 8(sp)
    jal loads_z_position
    li a0, 0
    addi sp, sp, 12   
    j handler_mret


loads_x_position:
    lw t0, 0x10(s0)
    sw t0, 0(a0)
    ret

loads_y_position:
    lw t0, 0x14(s0)
    sw t0, 0(a0)
    ret

loads_z_position:
    lw t0, 0x18(s0)
    sw t0, 0(a0)
    ret


    









.globl _start
_start:

    la t0, int_handler  # Load the address of the routine that will handle interrupts
    csrw mtvec, t0      # (and syscalls) on the register MTVEC to set
                        # the interrupt array.

    la sp, stack_main


    csrr t0, mstatus
    li t1, ~0x1800
    and t1, t1, t0
    csrw mstatus, t1

    la t2, user_main
    csrw mepc, t2
    mret




.globl control_logic
control_logic:
    li a7, 11
    li a0, 0
    ecall # liberar freio de mão
    la t0, x_test_track
    lw s1, 0(t0)    # s1 = x_do_destino
    la t0, z_test_track 
    lw s2, 0(t0) # s2 = z_do_destino

    



.globl infinite_loop
infinite_loop:

    la a0, actual_x # a0 = x_track
    la a1, actual_y # a1 = y_track
    la a2, actual_z
    li a7, 15
    ecall #chama get_position

    la s3, actual_x
    la s4, actual_z
    lw t2, 0(s3)
    lw t3, 0(s4)
    

    blt t2, s1, turn_right_loop

    bgt t2, s1, turn_left_loop

    li a7, 10
    li a0, 1
    li a1, 0
    ecall

    j infinite_loop



turn_left_loop:
    li a7, 10
    li a0, 1
    li a1, -16
    ecall
    j infinite_loop

turn_right_loop:
    li a7, 10
    li a0, 1
    li a1, 17
    ecall
    j infinite_loop



stop_car:
    li a0, 0
    li a1, 0
    li a7, 10
    ecall

    li a0, 1
    li a7, 11
    ecall

    j stop_car


