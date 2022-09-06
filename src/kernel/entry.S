.equ STACK_SIZE, 8192
.global _entry
_entry:
    csrr t0, mhartid               
    slli t0, t0, 10                 
    la   sp, stacks + STACK_SIZE    
    add  sp, sp, t0                 
    # park harts with id != 0
    csrr a0, mhartid                
    bnez a0, park                   
    j    start                   
park:
    wfi
    j park
stacks:
    .skip STACK_SIZE * 4            