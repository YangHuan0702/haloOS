CC = riscv64-unknown-elf-gcc
#CFLAGS = -nostdlib -fno-builtin -mcmodel=medany -march=rv32ima -mabi=ilp32
CFLAGS = -nostdlib -fno-builtin -mcmodel=medany -march=rv64g -fno-common -ffreestanding

QEMU = qemu-system-riscv64
QFLAGS = -nographic -smp 4 -m 128M -machine virt -bios none -D ./kernelLog -d out_asm,in_asm,exec,cpu
# -D ./kernelLog -d out_asm,in_asm,exec,cpu
# virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0
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
		 src/kernel/entry.o \
		 src/kernel/start.o \
		 src/kernel/kernelvec.o \
		 src/kernel/main.o \
		 src/kernel/print.o \
		 src/kernel/proc.o \
		 src/kernel/swtch.o \
		 src/kernel/memlayout.o \
		 src/kernel/trap.o \
		 src/kernel/spinlock.o \
		 src/kernel/atomic.o \

.PRECIOUS: %.o


src/kernel/%.o: src/kernel/%.c
	$(CC) $(CFLAGS) -c -o $@ $<


OBJDUMP = riscv64-unknown-elf-objdump
LD = riscv64-unknown-elf-ld

all: os.elf

kernel: $(OBJS) src/kernel/os.ld
	$(LD) -z max-page-size=4096 -T src/kernel/os.ld -o src/kernel/kernel $(OBJS)
	$(OBJDUMP) -S src/kernel/kernel > src/kernel/kernel.asm


QEMUOPTS = -machine virt -bios none -kernel src/kernel/kernel -m 128M -smp 1 -nographic
#QEMUOPTS += -drive file=fs.img,if=none,format=raw,id=x0
#QEMUOPTS += -drive if=none,format=raw,id=x0
#QEMUOPTS += -device virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0
#os.elf: src/start.S src/kernel/swtch.S src/main.c $(OBJS)
#	$(CC) $(CFLAGS) -T src/os.ld -o os.elf $^

gdb: src/kernel/kernel
	$(QEMU) $(QEMUOPTS) -S -gdb tcp::25000

qemu: $(TARGET)
	@qemu-system-riscv64 -M ? | grep virt >/dev/null || exit
	@echo "Press Ctrl-A and then X to exit QEMU"
	$(QEMU) $(QFLAGS) -kernel src/kernel/kernel

clean:
	rm -f *.elf src/kernel/*.o src/kernel/kernel src/kernel/kernel.asm
