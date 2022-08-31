

// ------------------------------------- UART -----------------------------
#define UART        0x10000000
#define Reg(reg)    (volatile unsigned char *)(UART + reg)
#define UART_THR 0
#define LSR 5
#define THR 0
 

#define ReadReg(reg) (*(Reg(reg)))
#define WriteReg(reg,v) (*(Reg(reg)) = v)


void uart_putstr(char* s);
void uart_putc(char c);

// --------------------------------- Common ------------------------------
#define LM5 (1<<5)