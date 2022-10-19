#include "type.h"
#include "memlayout.h"
#include "riscv.h"
#include "defs.h"
#include "spinlock.h"

#define EOF 0
#define CMD_BUFF 128

extern volatile int panicked;

void uart_putc(char c){
  if(panicked){
      for(;;){}
  }
    while ((ReadReg(LSR) & LM5) == 0){}
    WriteReg(THR,c);
}

void uart_putstr(char* s){
  if(panicked){
    for(;;){
    }
  }
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

int uartgetc() {
  if(ReadReg(LSR) & 0x01){
    // input data is ready.
    return ReadReg(RHR);
  } else {
    return -1;
  }
}

#define CMD_BUFF 128
char cmd[CMD_BUFF];
struct{
  char* name;
  struct spinlock lock;
} plic_lock;

volatile int shellProcessored = 0;

void uartinterrupt(){
    shellProcessored = 1;
    int index = 0;
    for(;;){
      int c = uartgetc();
      if(c == -1){
          break;
      }
      if(c == '\n'){
        shellProcessored = 0;
        break;
      }
      cmd[index] = c;
    }
}

char* getCmd(){
  return cmd;
}

int getShellResult(){
  return shellProcessored;
}