#include "type.h"
#include "memlayout.h"
#include "riscv.h"
#include "defs.h"

void uart_putc(char c){
    while ((ReadReg(LSR) & LM5) == 0){}
    WriteReg(THR,c);
}

void uart_putstr(char* s){
    while (*s)
    {
        uart_putc(*s++); 
    }
}


void uartinit(){
  WriteReg(IER, 0x00);

  WriteReg(LCR, LCR_BAUD_LATCH);

  WriteReg(0, 0x03);

  WriteReg(1, 0x00);

  WriteReg(LCR, LCR_EIGHT_BITS);

  // 重置和启用FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);

  // 启用发送和接收中断
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);

//   initlock(&uart_tx_lock, "uart");
}

int uartgetc()
{
  if(ReadReg(LSR) & 0x01){
    // input data is ready.
    return ReadReg(RHR);
  } else {
    return -1;
  }
}

int plic_claim(){
    uint64 cpuid = r_tp();
    int irq = *(uint32*)PLIC_SCLAIM(cpuid);
    return irq;
}


void uartinterrupt(){
    while(1){
        int c = uartgetc();
        if(c == -1){
            break;
        }
        printf("c:%d\n",c);
        uart_putc(c);
    }
}

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


void
complate_irq(int irq)
{
  uint64 hart = r_tp();
  *(uint32*)PLIC_SCLAIM(hart) = irq;
}