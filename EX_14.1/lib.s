.section .bss
.align 4
prog_stack:
    .skip 1024
prog_stack_end:

isr_stack:
    .skip 1024
isr_stack_end:

    .align 4
    .globl _system_time

_system_time:
    .word 0

    .section .text
    .align 2

    .set GPT, 0xFFFF0100    
    .set MIDI, 0xFFFF0300  

    .globl _start
_start:
   
    la sp, prog_stack_end


    la t0, isr_stack_end
    csrw mscratch, t0

    #Mudança 1
    la t0, isr
    csrw mtvec, t0

 
    csrr t0, mie
    li t2, 0x800          
    or t0, t0, t2
    csrw mie, t0

 
    csrr t0, mstatus
    ori t0, t0, 0x8  
    csrw mstatus, t0


    li s0, GPT
    jal define_timer
    jal begin_timer


    jal main

    
    j exit


    .globl isr
isr:

    csrrw sp, mscratch, sp

    addi sp, sp, -64        
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw a0, 16(sp)
    sw a1, 20(sp)
    sw a2, 24(sp)
    sw t0, 28(sp)
    sw t1, 32(sp)

    
    la t1, _system_time
    lw t0, 0(t1)
    addi t0, t0, 1
    sw t0, 0(t1)

  
    li s0, GPT
    jal interruption_GPT


    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw a0, 16(sp)
    lw a1, 20(sp)
    lw a2, 24(sp)
    lw t0, 28(sp)
    lw t1, 32(sp)
    addi sp, sp, 64

    csrrw sp, mscratch, sp

    mret


exit:
    li a7, 93
    ecall


define_timer:
    li t5, 100
    sw t5, 0x08(s0)
    ret

begin_timer:
    li t5, 1
    sw t5, 0x00(s0)
    ret

interruption_GPT:
    li t5, 1
    sw t5, 0x08(s0)
    ret

# void play_note(int ch, int inst, int note, int vel, int dur)
    .globl play_note
play_note:

    addi sp, sp, -20
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)

  
    li s1, MIDI

  
    mv s0, a0    # ch
    mv s2, a2    # note
    mv s3, a3    # vel

   
    sh a1, 2(s1)   # inst
    sb s2, 4(s1)   # note
    sb s3, 5(s1)   # vel
    sh a4, 6(s1)   # dur
    sb s0, 0(s1)   # ch 


    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    addi sp, sp, 20
    ret
