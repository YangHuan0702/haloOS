CC = riscv64-unknown-elf-gcc
#CFLAGS = -nostdlib -fno-builtin -mcmodel=medany -march=rv32ima -mabi=ilp32
CFLAGS = -nostdlib -fno-builtin -mcmodel=medany -march=rv64g -fno-common -ffreestanding

QEMU = qemu-system-riscv64
QFLAGS = -nographic -smp 4 -machine virt -bios none

CFLAGS += -mno-relax -I.

# kernel = src/kernel/memlayout.c \
#		 src/kernel/memlayout.h \
#		 src/kernel/defs.h \
#		 src/kernel/print.c \
#		 src/kernel/proc.h \
#		 src/kernel/proc.h \
#		 src/kernel/riscv.h \
#		 src/kernel/type.h \

OBJS = \
		 src/kernel/start.o \
		 src/kernel/print.o \
		 src/kernel/proc.o \
		 src/kernel/swtch.o \
		 src/kernel/memlayout.o \
		 src/kernel/main.o \

src/kernel/%.o: src/kernel/%.c
	$(CC) $(CFLAGS) -c -o $@ $<


OBJDUMP = riscv64-unknown-elf-objdump
LD = riscv64-unknown-elf-ld

all: os.elf

kernel: $(OBJS) src/kernel/os.ld
	$(LD) -z max-page-size=4096 -T src/kernel/os.ld -o src/kernel/kernel $(OBJS)
	$(OBJDUMP) -S src/kernel/kernel > src/kernel/kernel.asm


#os.elf: src/start.S src/kernel/swtch.S src/main.c $(OBJS)
#	$(CC) $(CFLAGS) -T src/os.ld -o os.elf $^


qemu: $(TARGET)
	@qemu-system-riscv64 -M ? | grep virt >/dev/null || exit
	@echo "Press Ctrl-A and then X to exit QEMU"
	$(QEMU) $(QFLAGS) -kernel src/kernel/kernel

clean:
	rm -f *.elf src/kernel/*.o src/kernel/kernel src/kernel/kernel.asm
