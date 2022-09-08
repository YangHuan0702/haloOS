

// ------------------------------------- UART -----------------------------
#define UART        0x10000000
#define Reg(reg)    (volatile unsigned char *)(UART + reg)
#define UART_THR 0
#define LSR 5
#define THR 0
#define UART_THR (volatile uint64 *)(UART + 0x00) // THR:transmitter holding register
#define UART_RHR (volatile uint64 *)(UART + 0x00) // RHR:Receive holding register
#define UART_DLL (volatile uint64 *)(UART + 0x00) // LSB of Divisor Latch (write mode)
#define UART_DLM (volatile uint64 *)(UART + 0x01) // MSB of Divisor Latch (write mode)
#define UART_IER (volatile uint64 *)(UART + 0x01) // Interrupt Enable Register
#define UART_LCR (volatile uint64 *)(UART + 0x03) // Line Control Register
#define UART_LSR (volatile uint64 *)(UART + 0x05) // LSR:line status register
#define UART_LSR_EMPTY_MASK 0x40                   // LSR Bit 6: Transmitter empty; both the THR and LSR are empty

#define ReadReg(reg) (*(Reg(reg)))
#define WriteReg(reg,v) (*(Reg(reg)) = v)

// --------------------------------- Common ------------------------------
#define LM5 (1<<5)

#define STACK_SIZE 1024


// --------------------------------- CLINT --------------------------------
#define NCPU 8
#define CLINT 0x2000000
#define CLINT_MTIMECMP(hartid) (CLINT + 0x4000 + 8*(hartid))
#define CLINT_MTIME (CLINT + 0xBFF8)
#define INTERVAL 10000000 // 大约是100 ms (xv6)