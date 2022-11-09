CC = riscv64-unknown-elf-gcc
#CFLAGS = -nostdlib -fno-builtin -mcmodel=medany -march=rv32ima -mabi=ilp32
CFLAGS = -Wall -Werror -O -fno-omit-frame-pointer -ggdb -MD
CFLAGS += -nostdlib -mcmodel=medany -fno-common -ffreestanding
CFLAGS += $(shell $(CC) -fno-stack-protector -E -x c /dev/null >/dev/null 2>&1 && echo -fno-stack-protector)

QEMU = qemu-system-riscv64
QFLAGS = -nographic -smp 4 -m 128M -machine virt -bios none
# -D ./kernelLog -d out_asm,in_asm,exec,cpu
# virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0
CFLAGS += -mno-relax -I.

OBJS = \
		 src/kernel/entry.o \
		 src/kernel/start.o \
		 src/kernel/kernelvec.o \
		 src/kernel/main.o \
		 src/kernel/print.o \
		 src/kernel/swtch.o \
		 src/kernel/proc.o \
		 src/kernel/memlayout.o \
		 src/kernel/trap.o \
		 src/kernel/spinlock.o \
		 src/kernel/atomic.o \
		 src/kernel/plic.o \
		 src/kernel/virt.o \
		 src/kernel/util.o \
		 src/kernel/sleeplock.o \
		 src/kernel/fs.o \
		 src/kernel/file.o \
		 src/kernel/console.o \
		 src/kernel/exec.o \
		 src/kernel/spaceswap.o \
		 src/kernel/syscall.o \
		 src/kernel/sysfile.o \
		 src/kernel/sysproc.o \
		 src/kernel/argsutil.o \
		 src/kernel/trampoline.o \
		 src/kernel/vm.o \

-include src/kernel/*.d src/user/*.d

USERS = \
		src/user/_ls\
		src/user/_init\
		src/user/_sh\

.PRECIOUS: %.o

XCFLAGS += -DSOL_HALO -DLAB_HALO
CFLAGS += $(XCFLAGS)

src/kernel/%.o: src/kernel/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

GDBPORT = $(shell expr `id -u` % 5000 + 25000)
QEMUGDB = $(shell if $(QEMU) -help | grep -q '^-gdb'; \
	then echo "-gdb tcp::$(GDBPORT)"; \
	else echo "-s -p $(GDBPORT)"; fi)

.gdbinit: .gdbinit.tmpl-riscv
	sed "s/:1234/:$(GDBPORT)/" < $^ > $@

qemu-gdb: src/kernel/kernel .gdbinit fs.img
	@echo "*** Now run 'gdb' in another window." 1>&2
	$(QEMU) $(QEMUOPTS) -S $(QEMUGDB)

OBJDUMP = riscv64-unknown-elf-objdump
OBJCOPY = riscv64-unknown-elf-objcopy
LD = riscv64-unknown-elf-ld

LDFLAGS = -z max-page-size=4096

ULIB = src/user/sysc.o src/user/printf.o src/user/str.o

_%: %.o $(ULIB)
	$(LD) $(LDFLAGS) -N -e main -Ttext 0 -o $@ $^
	$(OBJDUMP) -S $@ > $*.asm
	$(OBJDUMP) -t $@ | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > $*.sym

all: os.elf

CPUS = 1

QEMUOPTS = -machine virt -bios none -kernel src/kernel/kernel -m 128M -smp $(CPUS) -nographic
QEMUOPTS += -drive file=fs.img,if=none,format=raw,id=x0
QEMUOPTS += -device virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0

initcode: src/user/initcode.S
	$(CC) $(CFLAGS) -march=rv64g -nostdinc -I. -Ikernel -c src/user/initcode.S -o src/user/initcode.o
	$(LD) $(LDFLAGS) -N -e start -Ttext 0 -o src/user/initcode.out src/user/initcode.o
	$(OBJCOPY) -S -O binary src/user/initcode.out src/user/initcode
	$(OBJDUMP) -S src/user/initcode.o > src/user/initcode.asm

kernel: $(OBJS) src/kernel/os.ld fs.img initcode
	$(LD) -z max-page-size=4096 -T src/kernel/os.ld -o src/kernel/kernel $(OBJS)
	$(OBJDUMP) -S src/kernel/kernel > src/kernel/kernel.asm 
	$(OBJDUMP) -t src/kernel/kernel | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > src/kernel/kernel.sym

qemu: kernel fs.img
	$(QEMU) $(QEMUOPTS)
	
src/mkfs: src/mkfs.c src/kernel/fs.h src/kernel/file.h src/kernel/stat.h
	gcc -Werror -Wall -I. -o src/mkfs src/mkfs.c

fs.img:	src/mkfs $(USERS)
	src/mkfs fs.img $(USERS)

#hdd.dsk:
#	dd if=/dev/urandom of=hdd.dsk bs=1M count=32
#os.elf: src/start.S src/kernel/swtch.S src/main.c $(OBJS)
#	$(CC) $(CFLAGS) -T src/os.ld -o os.elf $^

gdb: src/kernel/kernel
	riscv64-unknown-elf-gdb src/kernel/kernel

# fs
#QFLAGS += -drive if=none,format=raw,file=hdd.dsk,id=x0
#QFLAGS += -device virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0

# qemu: $(TARGET) fs.img
# 	@qemu-system-riscv64 -M ? | grep virt >/dev/null || exit
# 	@echo "Press Ctrl-A and then X to exit QEMU"
# 	$(QEMU) $(QFLAGS) -kernel src/kernel/kernel

clean:
	rm -f *.elf src/kernel/*.o src/kernel/kernel src/kernel/kernel.asm src/kernel/kernel.sym
	rm -f src/user/*.o src/user/*.sym src/user/*.asm $(USERS)
	rm -rf src/user/initcode src/user/*.out
	rm -rf src/kernel/*.d src/user/*.d
