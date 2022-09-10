
#define STACK_SIZE 1024

#define SSTATUS_SPP (1L << 8)  // Previous mode, 1=Supervisor, 0=User
#define SSTATUS_SPIE (1L << 5) // Supervisor Previous Interrupt Enable
#define SSTATUS_UPIE (1L << 4) // User Previous Interrupt Enable
#define SSTATUS_SIE (1L << 1)  // Supervisor Interrupt Enable
#define SSTATUS_UIE (1L << 0)  // User Interrupt Enable

#define SIE_SEIE (1L << 9) // 外部中断
#define SIE_STIE (1L << 5) // 时间中断
#define SIE_SSIE (1L << 1) // 软件中断


// MSTATUS
#define MSTATUS_MIE (1 << 3)
#define MSTATUS_MPP_MASK (3 << 11) //之前的模式
#define MSTATUS_MPP_M (3L << 11)
#define MSTATUS_MPP_S (1L << 11)
#define MSTATUS_MPP_U (0L << 11)

#define MIE_MTIE (1 << 7)

// virtio mmio interface
#define VIRTIO0 0x10001000
#define VIRTIO0_IRQ 1

// ------------------------------------- UART -----------------------------
#define UART        0x10000000
#define UART0_IRQ 10

#define Reg(reg)    (volatile unsigned char *)(UART + reg)
#define LSR 5
#define RHR 0                 // 接收保持寄存器（用于输入字节）
#define THR 0                 // 发送保持寄存器（用于输出字节）
#define IER 1                 // 中断使能寄存器
#define IER_RX_ENABLE (1<<0)
#define IER_TX_ENABLE (1<<1)
#define ISR 2                 // 中断状态寄存器
#define LCR 3                 // 行控制寄存器
#define LCR_EIGHT_BITS (3<<0)
#define LCR_BAUD_LATCH (1<<7) // 设置波特率的特殊模式
#define FCR 2                 // FIFO控制寄存器
#define FCR_FIFO_ENABLE (1<<0)
#define FCR_FIFO_CLEAR (3<<1) // 清除两个FIFO的内容
#define UART_THR (volatile uint64 *)(UART + 0x00) 
#define UART_RHR (volatile uint64 *)(UART + 0x00) 
#define UART_DLL (volatile uint64 *)(UART + 0x00) 
#define UART_DLM (volatile uint64 *)(UART + 0x01) 
#define UART_IER (volatile uint64 *)(UART + 0x01) 
#define UART_LCR (volatile uint64 *)(UART + 0x03) 
#define UART_LSR (volatile uint64 *)(UART + 0x05) 
#define UART_LSR_EMPTY_MASK 0x40                   
#define ReadReg(reg) (*(Reg(reg)))
#define WriteReg(reg,v) (*(Reg(reg)) = v)
#define LM5 (1<<5)



// --------------------------------------- PLIC ---------------------------------
#define PLIC 0x0c000000L
#define PLIC_PRIORITY (PLIC + 0x0)
#define PLIC_PENDING (PLIC + 0x1000)
#define PLIC_MENABLE(hart) (PLIC + 0x2000 + (hart)*0x100)
#define PLIC_SENABLE(hart) (PLIC + 0x2080 + (hart)*0x100)
#define PLIC_MPRIORITY(hart) (PLIC + 0x200000 + (hart)*0x2000)
#define PLIC_SPRIORITY(hart) (PLIC + 0x201000 + (hart)*0x2000)
#define PLIC_MCLAIM(hart) (PLIC + 0x200004 + (hart)*0x2000)
#define PLIC_SCLAIM(hart) (PLIC + 0x201004 + (hart)*0x2000)


// --------------------------------- CLINT --------------------------------
#define NCPU 8
#define CLINT 0x2000000
#define CLINT_MTIMECMP(hartid) (CLINT + 0x4000 + 8*(hartid))
#define CLINT_MTIME (CLINT + 0xBFF8)
#define INTERVAL 10000000 // 大约是100 ms (xv6)