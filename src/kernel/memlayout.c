#include "type.h"
#include "memlayout.h"
#include "riscv.h"
#include "defs.h"
#include "spinlock.h"

#define EOF 0
#define CMD_BUFF 128

extern volatile int panicked;
struct spinlock uart_tx_lock;

#define UART_TX_BUF_SIZE 32
char uart_tx_buf[UART_TX_BUF_SIZE];
uint64 uart_tx_w;
uint64 uart_tx_r;

void uartstart();



void uartputc(char c){
  acquire(&uart_tx_lock);
  if(panicked){
      for(;;){}
  }
  
  while (1) {
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
        sleep(&uart_tx_r,&uart_tx_lock);
    }else{
      uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
      uart_tx_w += 1;
      uartstart();
      release(&uart_tx_lock);
      return;
    }
  }
}

void uart_putc(char c){
  consputc(c);
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

  initlock(&uart_tx_lock, "uart");
}

int uartgetc() {
  if(ReadReg(LSR) & 0x01){
    // input data is ready.
    return ReadReg(RHR);
  } else {
    return -1;
  }
}

struct{
  char* name;
  struct spinlock lock;
} plic_lock;


void uartstart(){
  while (1) {
    if(uart_tx_r == uart_tx_w){
      return;
    }

    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
        // UART 发送保持寄存器已满，当它准备好接收一个新字节时它会中断
        return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    uart_tx_r+=1;
    wakeup(&uart_tx_r);
    WriteReg(THR, c);
  }
}

void uartputc_sync(int c){
  push_off();
  if(panicked){
    for (;;){
    }
  }
  while ((ReadReg(LSR) & LSR_TX_IDLE) == 0){
  }
  WriteReg(THR,c);  
  pop_off();
}

void uartinterrupt(){
    for(;;){
      int c = uartgetc();
      if(c == -1){
          break;
      }
      consoleintr(c);
    }
    acquire(&uart_tx_lock);
    uartstart();
    release(&uart_tx_lock);
}

void consputc(int c){
    if(c == BACKSPACE){
        uartputc_sync('\b');
        uartputc_sync(' ');
        uartputc_sync('\b');
    }else{
        uartputc_sync(c);
    }
}
