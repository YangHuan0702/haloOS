.global atmswap
atmswap:
    li t0,1
    amoswap.w.aq t1,t0,0(a0)
    mv a0,t1
    ret
