

// ------------------------------------- UART -----------------------------
#define UART        0x10000000
#define Reg(reg)    (volatile unsigned char *)(UART + reg)
#define UART_THR 0
#define LSR 5
#define THR 0
 

#define ReadReg(reg) (*(Reg(reg)))
#define WriteReg(reg,v) (*(Reg(reg)) = v)

// --------------------------------- Common ------------------------------
#define LM5 (1<<5)

#define STACK_SIZE 1024


// --------------------------------- CLINT --------------------------------
#define NCPU 8
#define CLINT 0x2000000
#define CLINT_MTIMECMP(hartid) (CLINT + 0x4000 + 4*(hartid))
#define CLINT_MTIME (CLINT + 0xBFF8)
#define INTERVAL 10000000 // 大概是1s