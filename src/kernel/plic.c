#include "type.h"
#include "defs.h"
#include "riscv.h"
#include "memlayout.h"


void plicinit()
{
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
}

void plicinithart()
{
  int hart = r_tp();
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
}


int plic_claim(){
    uint64 cpuid = r_tp();
    int irq = *(uint32*)PLIC_SCLAIM(cpuid);
    return irq;
}


void
complate_irq(int irq)
{
  uint64 hart = r_tp();
  *(uint32*)PLIC_SCLAIM(hart) = irq;
}