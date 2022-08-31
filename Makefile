CC = riscv64-unknown-elf-gcc
CFLAGS = -nostdlib -fno-builtin -mcmodel=medany -march=rv32ima -mabi=ilp32

QEMU = qemu-system-riscv32
QFLAGS = -nographic -smp 4 -machine virt -bios none

OBJDUMP = riscv64-unknown-elf-objdump

kernel = src/kernel/memlayout.c \
		 src/kernel/memlayout.h \
		 src/kernel/defs.h \
		 src/kernel/print.c \
		 src/kernel/proc.h \
		 src/kernel/proc.h \
		 src/kernel/riscv.h \
		 src/kernel/type.h \


all: os.elf



os.elf: src/start.S src/kernel/swtch.S src/main.c ${kernel}
	$(CC) $(CFLAGS) -T src/os.ld -o os.elf $^


qemu: $(TARGET)
	@qemu-system-riscv64 -M ? | grep virt >/dev/null || exit
	@echo "Press Ctrl-A and then X to exit QEMU"
	$(QEMU) $(QFLAGS) -kernel os.elf

clean:
	rm -f *.elf
