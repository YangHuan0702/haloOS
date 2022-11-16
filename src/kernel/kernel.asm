
src/kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00008117          	auipc	sp,0x8
    80000004:	17010113          	addi	sp,sp,368 # 80008170 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	ra,8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timer_init>:
    w_tp(r_mhartid());

    asm volatile("mret");
}

void timer_init(){
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
    asm volatile("csrw mstatus, %0" : : "r" (x));
}

static inline uint64 r_mhartid(){
    uint64 x;
    asm volatile("csrr %0,mhartid": "=r"(x));
    80000022:	f14026f3          	csrr	a3,mhartid
    uint64 hartid = r_mhartid();
    // 设置下一个时钟周期
    *(uint64*)CLINT_MTIMECMP(hartid) = *(uint64*)CLINT_MTIME + INTERVAL;
    80000026:	004017b7          	lui	a5,0x401
    8000002a:	80078793          	addi	a5,a5,-2048 # 400800 <_entry-0x7fbff800>
    8000002e:	97b6                	add	a5,a5,a3
    80000030:	078e                	slli	a5,a5,0x3
    80000032:	0200c737          	lui	a4,0x200c
    80000036:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003a:	000f4637          	lui	a2,0xf4
    8000003e:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000042:	9732                	add	a4,a4,a2
    80000044:	e398                	sd	a4,0(a5)

    uint64 *scratch = &timer_scratch[hartid][0];
    80000046:	00269713          	slli	a4,a3,0x2
    8000004a:	9736                	add	a4,a4,a3
    8000004c:	00371693          	slli	a3,a4,0x3
    80000050:	00008717          	auipc	a4,0x8
    80000054:	fe070713          	addi	a4,a4,-32 # 80008030 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
    scratch[3] = CLINT_MTIMECMP(hartid);
    8000005a:	ef1c                	sd	a5,24(a4)
    scratch[4] = INTERVAL;
    8000005c:	f310                	sd	a2,32(a4)
    asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
    asm volatile("csrw mtvec, %0" : : "r"(x));
    80000062:	00000797          	auipc	a5,0x0
    80000066:	12e78793          	addi	a5,a5,302 # 80000190 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
    return x;
}

static inline uint64 r_mstatus(){
    uint64 x;
    asm volatile("csrr %0,mstatus" : "=r"(x));
    8000006e:	300027f3          	csrr	a5,mstatus
    w_mscratch((uint64)scratch);

    w_mtvec((uint64)timervec);

    w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
    asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
    asm volatile("csrw mie,%0" :: "r"(x));
}

static inline uint64 r_mie(){
    uint64 x;
    asm volatile("csrr %0,mie" : "=r"(x));
    8000007a:	304027f3          	csrr	a5,mie

    w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
    asm volatile("csrw mie,%0" :: "r"(x));
    80000082:	30479073          	csrw	mie,a5
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	addi	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
void start(){
    8000008c:	1141                	addi	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	addi	s0,sp,16
    asm volatile("csrr %0,mstatus" : "=r"(x));
    80000094:	300027f3          	csrr	a5,mstatus
    x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffddecf>
    8000009e:	8ff9                	and	a5,a5,a4
    x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
    asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
    asm volatile("csrw mepc,%0" : : "r"(x));
    800000ac:	00000797          	auipc	a5,0x0
    800000b0:	10e78793          	addi	a5,a5,270 # 800001ba <main>
    800000b4:	34179073          	csrw	mepc,a5
    asm volatile("csrw satp,%0" :: "r"(x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
    asm volatile("csrw medeleg,%0"::"r"(x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	addi	a5,a5,-1
    800000c2:	30279073          	csrw	medeleg,a5
    asm volatile("csrw mideleg,%0"::"r"(x));
    800000c6:	30379073          	csrw	mideleg,a5
    asm volatile("csrr %0,sie":"=r"(x));
    800000ca:	104027f3          	csrr	a5,sie
    w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE); // 开启S Model下的中断处理
    800000ce:	2227e793          	ori	a5,a5,546
    asm volatile("csrw sie,%0"::"r"(x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srli	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
    timer_init();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timer_init>
    asm volatile("csrr %0,mhartid": "=r"(x));
    800000ec:	f14027f3          	csrr	a5,mhartid
    asm volatile("mv tp,%0"::"r"(x));
    800000f0:	823e                	mv	tp,a5
    asm volatile("mret");
    800000f2:	30200073          	mret
}
    800000f6:	60a2                	ld	ra,8(sp)
    800000f8:	6402                	ld	s0,0(sp)
    800000fa:	0141                	addi	sp,sp,16
    800000fc:	8082                	ret
	...

0000000080000100 <kernelvec>:
    80000100:	7111                	addi	sp,sp,-256
    80000102:	e006                	sd	ra,0(sp)
    80000104:	e40a                	sd	sp,8(sp)
    80000106:	e80e                	sd	gp,16(sp)
    80000108:	ec12                	sd	tp,24(sp)
    8000010a:	f016                	sd	t0,32(sp)
    8000010c:	f41a                	sd	t1,40(sp)
    8000010e:	f81e                	sd	t2,48(sp)
    80000110:	fc22                	sd	s0,56(sp)
    80000112:	e0a6                	sd	s1,64(sp)
    80000114:	e4aa                	sd	a0,72(sp)
    80000116:	e8ae                	sd	a1,80(sp)
    80000118:	ecb2                	sd	a2,88(sp)
    8000011a:	f0b6                	sd	a3,96(sp)
    8000011c:	f4ba                	sd	a4,104(sp)
    8000011e:	f8be                	sd	a5,112(sp)
    80000120:	fcc2                	sd	a6,120(sp)
    80000122:	e146                	sd	a7,128(sp)
    80000124:	e54a                	sd	s2,136(sp)
    80000126:	e94e                	sd	s3,144(sp)
    80000128:	ed52                	sd	s4,152(sp)
    8000012a:	f156                	sd	s5,160(sp)
    8000012c:	f55a                	sd	s6,168(sp)
    8000012e:	f95e                	sd	s7,176(sp)
    80000130:	fd62                	sd	s8,184(sp)
    80000132:	e1e6                	sd	s9,192(sp)
    80000134:	e5ea                	sd	s10,200(sp)
    80000136:	e9ee                	sd	s11,208(sp)
    80000138:	edf2                	sd	t3,216(sp)
    8000013a:	f1f6                	sd	t4,224(sp)
    8000013c:	f5fa                	sd	t5,232(sp)
    8000013e:	f9fe                	sd	t6,240(sp)
    80000140:	574010ef          	jal	ra,800016b4 <kerneltrap>
    80000144:	6082                	ld	ra,0(sp)
    80000146:	6122                	ld	sp,8(sp)
    80000148:	61c2                	ld	gp,16(sp)
    8000014a:	7282                	ld	t0,32(sp)
    8000014c:	7322                	ld	t1,40(sp)
    8000014e:	73c2                	ld	t2,48(sp)
    80000150:	7462                	ld	s0,56(sp)
    80000152:	6486                	ld	s1,64(sp)
    80000154:	6526                	ld	a0,72(sp)
    80000156:	65c6                	ld	a1,80(sp)
    80000158:	6666                	ld	a2,88(sp)
    8000015a:	7686                	ld	a3,96(sp)
    8000015c:	7726                	ld	a4,104(sp)
    8000015e:	77c6                	ld	a5,112(sp)
    80000160:	7866                	ld	a6,120(sp)
    80000162:	688a                	ld	a7,128(sp)
    80000164:	692a                	ld	s2,136(sp)
    80000166:	69ca                	ld	s3,144(sp)
    80000168:	6a6a                	ld	s4,152(sp)
    8000016a:	7a8a                	ld	s5,160(sp)
    8000016c:	7b2a                	ld	s6,168(sp)
    8000016e:	7bca                	ld	s7,176(sp)
    80000170:	7c6a                	ld	s8,184(sp)
    80000172:	6c8e                	ld	s9,192(sp)
    80000174:	6d2e                	ld	s10,200(sp)
    80000176:	6dce                	ld	s11,208(sp)
    80000178:	6e6e                	ld	t3,216(sp)
    8000017a:	7e8e                	ld	t4,224(sp)
    8000017c:	7f2e                	ld	t5,232(sp)
    8000017e:	7fce                	ld	t6,240(sp)
    80000180:	6111                	addi	sp,sp,256
    80000182:	10200073          	sret
    80000186:	00000013          	nop
    8000018a:	00000013          	nop
    8000018e:	0001                	nop

0000000080000190 <timervec>:
    80000190:	34051573          	csrrw	a0,mscratch,a0
    80000194:	e10c                	sd	a1,0(a0)
    80000196:	e510                	sd	a2,8(a0)
    80000198:	e914                	sd	a3,16(a0)
    8000019a:	6d0c                	ld	a1,24(a0)
    8000019c:	7110                	ld	a2,32(a0)
    8000019e:	6194                	ld	a3,0(a1)
    800001a0:	96b2                	add	a3,a3,a2
    800001a2:	e194                	sd	a3,0(a1)
    800001a4:	4589                	li	a1,2
    800001a6:	14459073          	csrw	sip,a1
    800001aa:	610c                	ld	a1,0(a0)
    800001ac:	6510                	ld	a2,8(a0)
    800001ae:	6914                	ld	a3,16(a0)
    800001b0:	34051573          	csrrw	a0,mscratch,a0
    800001b4:	30200073          	mret
	...

00000000800001ba <main>:
#include "defs.h"
#include "riscv.h"

volatile static int started = 0;

int main(){
    800001ba:	1141                	addi	sp,sp,-16
    800001bc:	e406                	sd	ra,8(sp)
    800001be:	e022                	sd	s0,0(sp)
    800001c0:	0800                	addi	s0,sp,16
    if(cpuid() == 0){
    800001c2:	00000097          	auipc	ra,0x0
    800001c6:	3b4080e7          	jalr	948(ra) # 80000576 <cpuid>
        userinit();
        __sync_synchronize();
        printf("OS: Start\n");
        started = 1;
    }else{
        while (started == 0) {
    800001ca:	00008717          	auipc	a4,0x8
    800001ce:	e3670713          	addi	a4,a4,-458 # 80008000 <started>
    if(cpuid() == 0){
    800001d2:	c51d                	beqz	a0,80000200 <main+0x46>
        while (started == 0) {
    800001d4:	431c                	lw	a5,0(a4)
    800001d6:	2781                	sext.w	a5,a5
    800001d8:	dff5                	beqz	a5,800001d4 <main+0x1a>
        }
        __sync_synchronize();
    800001da:	0ff0000f          	fence
        trapinit();   
    800001de:	00001097          	auipc	ra,0x1
    800001e2:	592080e7          	jalr	1426(ra) # 80001770 <trapinit>
        plicinithart();
    800001e6:	00001097          	auipc	ra,0x1
    800001ea:	772080e7          	jalr	1906(ra) # 80001958 <plicinithart>
    }
    scheduler();
    800001ee:	00001097          	auipc	ra,0x1
    800001f2:	9e6080e7          	jalr	-1562(ra) # 80000bd4 <scheduler>
    return 0;
    800001f6:	4501                	li	a0,0
    800001f8:	60a2                	ld	ra,8(sp)
    800001fa:	6402                	ld	s0,0(sp)
    800001fc:	0141                	addi	sp,sp,16
    800001fe:	8082                	ret
        consoleinit();
    80000200:	00003097          	auipc	ra,0x3
    80000204:	292080e7          	jalr	658(ra) # 80003492 <consoleinit>
        printinit();
    80000208:	00000097          	auipc	ra,0x0
    8000020c:	078080e7          	jalr	120(ra) # 80000280 <printinit>
        trapinit();
    80000210:	00001097          	auipc	ra,0x1
    80000214:	560080e7          	jalr	1376(ra) # 80001770 <trapinit>
        plicinit();
    80000218:	00001097          	auipc	ra,0x1
    8000021c:	72a080e7          	jalr	1834(ra) # 80001942 <plicinit>
        plicinithart();
    80000220:	00001097          	auipc	ra,0x1
    80000224:	738080e7          	jalr	1848(ra) # 80001958 <plicinithart>
        kinit();
    80000228:	00005097          	auipc	ra,0x5
    8000022c:	8ac080e7          	jalr	-1876(ra) # 80004ad4 <kinit>
        initproc();
    80000230:	00000097          	auipc	ra,0x0
    80000234:	51c080e7          	jalr	1308(ra) # 8000074c <initproc>
        init_bcache();
    80000238:	00002097          	auipc	ra,0x2
    8000023c:	f9e080e7          	jalr	-98(ra) # 800021d6 <init_bcache>
        init_inodecache();
    80000240:	00002097          	auipc	ra,0x2
    80000244:	024080e7          	jalr	36(ra) # 80002264 <init_inodecache>
        init_filecache();
    80000248:	00003097          	auipc	ra,0x3
    8000024c:	df8080e7          	jalr	-520(ra) # 80003040 <init_filecache>
        virtio_disk_init();
    80000250:	00002097          	auipc	ra,0x2
    80000254:	a90080e7          	jalr	-1392(ra) # 80001ce0 <virtio_disk_init>
        userinit();
    80000258:	00001097          	auipc	ra,0x1
    8000025c:	c0a080e7          	jalr	-1014(ra) # 80000e62 <userinit>
        __sync_synchronize();
    80000260:	0ff0000f          	fence
        printf("OS: Start\n");
    80000264:	00007517          	auipc	a0,0x7
    80000268:	dac50513          	addi	a0,a0,-596 # 80007010 <etext+0x10>
    8000026c:	00000097          	auipc	ra,0x0
    80000270:	04e080e7          	jalr	78(ra) # 800002ba <printf>
        started = 1;
    80000274:	4785                	li	a5,1
    80000276:	00008717          	auipc	a4,0x8
    8000027a:	d8f72523          	sw	a5,-630(a4) # 80008000 <started>
    8000027e:	bf85                	j	800001ee <main+0x34>

0000000080000280 <printinit>:
    int locking;
} pr;

volatile int panicked = 0;

void printinit(){
    80000280:	1101                	addi	sp,sp,-32
    80000282:	ec06                	sd	ra,24(sp)
    80000284:	e822                	sd	s0,16(sp)
    80000286:	e426                	sd	s1,8(sp)
    80000288:	1000                	addi	s0,sp,32
    uartinit();
    8000028a:	00001097          	auipc	ra,0x1
    8000028e:	ed0080e7          	jalr	-304(ra) # 8000115a <uartinit>
    initlock(&pr.slock,"pr");
    80000292:	00010497          	auipc	s1,0x10
    80000296:	ede48493          	addi	s1,s1,-290 # 80010170 <pr>
    8000029a:	00007597          	auipc	a1,0x7
    8000029e:	d8658593          	addi	a1,a1,-634 # 80007020 <etext+0x20>
    800002a2:	8526                	mv	a0,s1
    800002a4:	00001097          	auipc	ra,0x1
    800002a8:	500080e7          	jalr	1280(ra) # 800017a4 <initlock>
    pr.locking = 1;
    800002ac:	4785                	li	a5,1
    800002ae:	cc9c                	sw	a5,24(s1)
}
    800002b0:	60e2                	ld	ra,24(sp)
    800002b2:	6442                	ld	s0,16(sp)
    800002b4:	64a2                	ld	s1,8(sp)
    800002b6:	6105                	addi	sp,sp,32
    800002b8:	8082                	ret

00000000800002ba <printf>:
//     char *nextLine = "\n";
//     uart_putstr(s);
//     uart_putstr(nextLine);
// }

void printf(char *s, ...){
    800002ba:	7155                	addi	sp,sp,-208
    800002bc:	e506                	sd	ra,136(sp)
    800002be:	e122                	sd	s0,128(sp)
    800002c0:	fca6                	sd	s1,120(sp)
    800002c2:	f8ca                	sd	s2,112(sp)
    800002c4:	f4ce                	sd	s3,104(sp)
    800002c6:	f0d2                	sd	s4,96(sp)
    800002c8:	ecd6                	sd	s5,88(sp)
    800002ca:	e8da                	sd	s6,80(sp)
    800002cc:	e4de                	sd	s7,72(sp)
    800002ce:	e0e2                	sd	s8,64(sp)
    800002d0:	fc66                	sd	s9,56(sp)
    800002d2:	f86a                	sd	s10,48(sp)
    800002d4:	f46e                	sd	s11,40(sp)
    800002d6:	0900                	addi	s0,sp,144
    800002d8:	8a2a                	mv	s4,a0
    800002da:	e40c                	sd	a1,8(s0)
    800002dc:	e810                	sd	a2,16(s0)
    800002de:	ec14                	sd	a3,24(s0)
    800002e0:	f018                	sd	a4,32(s0)
    800002e2:	f41c                	sd	a5,40(s0)
    800002e4:	03043823          	sd	a6,48(s0)
    800002e8:	03143c23          	sd	a7,56(s0)
    int locking = pr.locking;
    800002ec:	00010c97          	auipc	s9,0x10
    800002f0:	e9ccac83          	lw	s9,-356(s9) # 80010188 <pr+0x18>
    if(locking){
    800002f4:	020c9963          	bnez	s9,80000326 <printf+0x6c>
        acquire(&pr.slock);
    }
    va_list ap;
    va_start(ap,s);
    800002f8:	00840793          	addi	a5,s0,8
    800002fc:	f8f43423          	sd	a5,-120(s0)
    char *str;
    for(int i = 0; s[i] != 0; i++){
    80000300:	00054503          	lbu	a0,0(a0)
    80000304:	16050163          	beqz	a0,80000466 <printf+0x1ac>
    80000308:	4481                	li	s1,0
        char c = s[i];
        if(c != '%'){
    8000030a:	02500a93          	li	s5,37
        char next = s[++i];
        if(next == 0){
            uart_putc(c);
            continue;
        }
        switch (next) {
    8000030e:	07000c13          	li	s8,112
    uart_putc('x');
    80000312:	4d41                	li	s10,16
        uart_putc(nums[ptr >> (sizeof(uint64) * 8 - 4)]);
    80000314:	00007997          	auipc	s3,0x7
    80000318:	d1c98993          	addi	s3,s3,-740 # 80007030 <nums>
        switch (next) {
    8000031c:	07300b93          	li	s7,115
    80000320:	06400b13          	li	s6,100
    80000324:	a099                	j	8000036a <printf+0xb0>
        acquire(&pr.slock);
    80000326:	00010517          	auipc	a0,0x10
    8000032a:	e4a50513          	addi	a0,a0,-438 # 80010170 <pr>
    8000032e:	00001097          	auipc	ra,0x1
    80000332:	502080e7          	jalr	1282(ra) # 80001830 <acquire>
    va_start(ap,s);
    80000336:	00840793          	addi	a5,s0,8
    8000033a:	f8f43423          	sd	a5,-120(s0)
    for(int i = 0; s[i] != 0; i++){
    8000033e:	000a4503          	lbu	a0,0(s4)
    80000342:	f179                	bnez	a0,80000308 <printf+0x4e>
            uart_putc(next);
            break;
        }
    }    
    if(locking){
        release(&pr.slock);
    80000344:	00010517          	auipc	a0,0x10
    80000348:	e2c50513          	addi	a0,a0,-468 # 80010170 <pr>
    8000034c:	00001097          	auipc	ra,0x1
    80000350:	5a6080e7          	jalr	1446(ra) # 800018f2 <release>
    }
}
    80000354:	aa09                	j	80000466 <printf+0x1ac>
            uart_putc(c);
    80000356:	00001097          	auipc	ra,0x1
    8000035a:	09e080e7          	jalr	158(ra) # 800013f4 <uart_putc>
    for(int i = 0; s[i] != 0; i++){
    8000035e:	2485                	addiw	s1,s1,1
    80000360:	009a07b3          	add	a5,s4,s1
    80000364:	0007c503          	lbu	a0,0(a5) # 10000 <_entry-0x7fff0000>
    80000368:	cd6d                	beqz	a0,80000462 <printf+0x1a8>
        if(c != '%'){
    8000036a:	ff5516e3          	bne	a0,s5,80000356 <printf+0x9c>
        char next = s[++i];
    8000036e:	2485                	addiw	s1,s1,1
    80000370:	009a07b3          	add	a5,s4,s1
    80000374:	0007c503          	lbu	a0,0(a5)
        if(next == 0){
    80000378:	cd01                	beqz	a0,80000390 <printf+0xd6>
        switch (next) {
    8000037a:	0b850163          	beq	a0,s8,8000041c <printf+0x162>
    8000037e:	09750263          	beq	a0,s7,80000402 <printf+0x148>
    80000382:	01650d63          	beq	a0,s6,8000039c <printf+0xe2>
            uart_putc(next);
    80000386:	00001097          	auipc	ra,0x1
    8000038a:	06e080e7          	jalr	110(ra) # 800013f4 <uart_putc>
            break;
    8000038e:	bfc1                	j	8000035e <printf+0xa4>
            uart_putc(c);
    80000390:	8556                	mv	a0,s5
    80000392:	00001097          	auipc	ra,0x1
    80000396:	062080e7          	jalr	98(ra) # 800013f4 <uart_putc>
            continue;
    8000039a:	b7d1                	j	8000035e <printf+0xa4>
            printInt(va_arg(ap,int),1);
    8000039c:	f8843783          	ld	a5,-120(s0)
    800003a0:	00878713          	addi	a4,a5,8
    800003a4:	f8e43423          	sd	a4,-120(s0)
    800003a8:	439c                	lw	a5,0(a5)
    800003aa:	f7840613          	addi	a2,s0,-136
    int i = 0;
    800003ae:	4681                	li	a3,0
        buf[i++] = nums[val % 10];        
    800003b0:	45a9                	li	a1,10
    } while ((val /= 10) > 0);
    800003b2:	4825                	li	a6,9
        buf[i++] = nums[val % 10];        
    800003b4:	8536                	mv	a0,a3
    800003b6:	2685                	addiw	a3,a3,1
    800003b8:	02b7e73b          	remw	a4,a5,a1
    800003bc:	974e                	add	a4,a4,s3
    800003be:	00074703          	lbu	a4,0(a4)
    800003c2:	00e60023          	sb	a4,0(a2)
    } while ((val /= 10) > 0);
    800003c6:	873e                	mv	a4,a5
    800003c8:	02b7c7bb          	divw	a5,a5,a1
    800003cc:	0605                	addi	a2,a2,1
    800003ce:	fee843e3          	blt	a6,a4,800003b4 <printf+0xfa>
    for(i-=1;i >= 0; i--){
    800003d2:	f80546e3          	bltz	a0,8000035e <printf+0xa4>
    800003d6:	f7840793          	addi	a5,s0,-136
    800003da:	00a78933          	add	s2,a5,a0
    800003de:	f7740793          	addi	a5,s0,-137
    800003e2:	00a78db3          	add	s11,a5,a0
    800003e6:	1502                	slli	a0,a0,0x20
    800003e8:	9101                	srli	a0,a0,0x20
    800003ea:	40ad8db3          	sub	s11,s11,a0
        uart_putc(buf[i]);
    800003ee:	00094503          	lbu	a0,0(s2)
    800003f2:	00001097          	auipc	ra,0x1
    800003f6:	002080e7          	jalr	2(ra) # 800013f4 <uart_putc>
    for(i-=1;i >= 0; i--){
    800003fa:	197d                	addi	s2,s2,-1
    800003fc:	ffb919e3          	bne	s2,s11,800003ee <printf+0x134>
    80000400:	bfb9                	j	8000035e <printf+0xa4>
            str = va_arg(ap,char*);
    80000402:	f8843783          	ld	a5,-120(s0)
    80000406:	00878713          	addi	a4,a5,8
    8000040a:	f8e43423          	sd	a4,-120(s0)
    8000040e:	6388                	ld	a0,0(a5)
            if(str){
    80000410:	d539                	beqz	a0,8000035e <printf+0xa4>
    uart_putstr(s);
    80000412:	00001097          	auipc	ra,0x1
    80000416:	ffa080e7          	jalr	-6(ra) # 8000140c <uart_putstr>
}
    8000041a:	b791                	j	8000035e <printf+0xa4>
            printPtr(va_arg(ap,uint64));
    8000041c:	f8843783          	ld	a5,-120(s0)
    80000420:	00878713          	addi	a4,a5,8
    80000424:	f8e43423          	sd	a4,-120(s0)
    80000428:	0007bd83          	ld	s11,0(a5)
    uart_putc('0');
    8000042c:	03000513          	li	a0,48
    80000430:	00001097          	auipc	ra,0x1
    80000434:	fc4080e7          	jalr	-60(ra) # 800013f4 <uart_putc>
    uart_putc('x');
    80000438:	07800513          	li	a0,120
    8000043c:	00001097          	auipc	ra,0x1
    80000440:	fb8080e7          	jalr	-72(ra) # 800013f4 <uart_putc>
    80000444:	896a                	mv	s2,s10
        uart_putc(nums[ptr >> (sizeof(uint64) * 8 - 4)]);
    80000446:	03cdd793          	srli	a5,s11,0x3c
    8000044a:	97ce                	add	a5,a5,s3
    8000044c:	0007c503          	lbu	a0,0(a5)
    80000450:	00001097          	auipc	ra,0x1
    80000454:	fa4080e7          	jalr	-92(ra) # 800013f4 <uart_putc>
    for(int i = 0; i < (sizeof(uint64) * 2); i++,ptr <<= 4){
    80000458:	0d92                	slli	s11,s11,0x4
    8000045a:	397d                	addiw	s2,s2,-1
    8000045c:	fe0915e3          	bnez	s2,80000446 <printf+0x18c>
    80000460:	bdfd                	j	8000035e <printf+0xa4>
    if(locking){
    80000462:	ee0c91e3          	bnez	s9,80000344 <printf+0x8a>
}
    80000466:	60aa                	ld	ra,136(sp)
    80000468:	640a                	ld	s0,128(sp)
    8000046a:	74e6                	ld	s1,120(sp)
    8000046c:	7946                	ld	s2,112(sp)
    8000046e:	79a6                	ld	s3,104(sp)
    80000470:	7a06                	ld	s4,96(sp)
    80000472:	6ae6                	ld	s5,88(sp)
    80000474:	6b46                	ld	s6,80(sp)
    80000476:	6ba6                	ld	s7,72(sp)
    80000478:	6c06                	ld	s8,64(sp)
    8000047a:	7ce2                	ld	s9,56(sp)
    8000047c:	7d42                	ld	s10,48(sp)
    8000047e:	7da2                	ld	s11,40(sp)
    80000480:	6169                	addi	sp,sp,208
    80000482:	8082                	ret

0000000080000484 <panic>:


void panic(char *str){
    80000484:	1101                	addi	sp,sp,-32
    80000486:	ec06                	sd	ra,24(sp)
    80000488:	e822                	sd	s0,16(sp)
    8000048a:	e426                	sd	s1,8(sp)
    8000048c:	1000                	addi	s0,sp,32
    8000048e:	84aa                	mv	s1,a0

    pr.locking = 0;
    80000490:	00010797          	auipc	a5,0x10
    80000494:	ce07ac23          	sw	zero,-776(a5) # 80010188 <pr+0x18>
    uart_putstr(s);
    80000498:	00007517          	auipc	a0,0x7
    8000049c:	b9050513          	addi	a0,a0,-1136 # 80007028 <etext+0x28>
    800004a0:	00001097          	auipc	ra,0x1
    800004a4:	f6c080e7          	jalr	-148(ra) # 8000140c <uart_putstr>
    800004a8:	8526                	mv	a0,s1
    800004aa:	00001097          	auipc	ra,0x1
    800004ae:	f62080e7          	jalr	-158(ra) # 8000140c <uart_putstr>
    800004b2:	00007517          	auipc	a0,0x7
    800004b6:	52e50513          	addi	a0,a0,1326 # 800079e0 <syscalls+0x1a0>
    800004ba:	00001097          	auipc	ra,0x1
    800004be:	f52080e7          	jalr	-174(ra) # 8000140c <uart_putstr>
    print("panic:");
    print(str);
    print("\n");
    panicked = 1;
    800004c2:	4785                	li	a5,1
    800004c4:	00008717          	auipc	a4,0x8
    800004c8:	b4f72023          	sw	a5,-1216(a4) # 80008004 <panicked>
    for(;;){
    800004cc:	a001                	j	800004cc <panic+0x48>

00000000800004ce <swtch>:
    800004ce:	00153023          	sd	ra,0(a0)
    800004d2:	00253423          	sd	sp,8(a0)
    800004d6:	e900                	sd	s0,16(a0)
    800004d8:	ed04                	sd	s1,24(a0)
    800004da:	03253023          	sd	s2,32(a0)
    800004de:	03353423          	sd	s3,40(a0)
    800004e2:	03453823          	sd	s4,48(a0)
    800004e6:	03553c23          	sd	s5,56(a0)
    800004ea:	05653023          	sd	s6,64(a0)
    800004ee:	05753423          	sd	s7,72(a0)
    800004f2:	05853823          	sd	s8,80(a0)
    800004f6:	05953c23          	sd	s9,88(a0)
    800004fa:	07a53023          	sd	s10,96(a0)
    800004fe:	07b53423          	sd	s11,104(a0)
    80000502:	0005b083          	ld	ra,0(a1)
    80000506:	0085b103          	ld	sp,8(a1)
    8000050a:	6980                	ld	s0,16(a1)
    8000050c:	6d84                	ld	s1,24(a1)
    8000050e:	0205b903          	ld	s2,32(a1)
    80000512:	0285b983          	ld	s3,40(a1)
    80000516:	0305ba03          	ld	s4,48(a1)
    8000051a:	0385ba83          	ld	s5,56(a1)
    8000051e:	0405bb03          	ld	s6,64(a1)
    80000522:	0485bb83          	ld	s7,72(a1)
    80000526:	0505bc03          	ld	s8,80(a1)
    8000052a:	0585bc83          	ld	s9,88(a1)
    8000052e:	0605bd03          	ld	s10,96(a1)
    80000532:	0685bd83          	ld	s11,104(a1)
    80000536:	8082                	ret

0000000080000538 <freeproc>:
	p->sz = sz;
	return 0;
}


static void freeproc(struct proc *p){
    80000538:	1101                	addi	sp,sp,-32
    8000053a:	ec06                	sd	ra,24(sp)
    8000053c:	e822                	sd	s0,16(sp)
    8000053e:	e426                	sd	s1,8(sp)
    80000540:	1000                	addi	s0,sp,32
    80000542:	84aa                	mv	s1,a0
	if(p->trapframe){
    80000544:	7128                	ld	a0,96(a0)
    80000546:	c509                	beqz	a0,80000550 <freeproc+0x18>
		// kfree
		kfree(p->trapframe);
    80000548:	00004097          	auipc	ra,0x4
    8000054c:	fc4080e7          	jalr	-60(ra) # 8000450c <kfree>
	}
	p->trapframe = 0;
    80000550:	0604b023          	sd	zero,96(s1)
	p->pid = 0;
    80000554:	0204a823          	sw	zero,48(s1)
	p->chan = 0;
    80000558:	0404b823          	sd	zero,80(s1)
	p->parent = 0;
    8000055c:	0404b023          	sd	zero,64(s1)
	p->name[0] = 0;
    80000560:	02048023          	sb	zero,32(s1)
	p->killed = 0;
    80000564:	0204aa23          	sw	zero,52(s1)
	p->state = UNUSED;
    80000568:	0004a023          	sw	zero,0(s1)
}
    8000056c:	60e2                	ld	ra,24(sp)
    8000056e:	6442                	ld	s0,16(sp)
    80000570:	64a2                	ld	s1,8(sp)
    80000572:	6105                	addi	sp,sp,32
    80000574:	8082                	ret

0000000080000576 <cpuid>:
int cpuid(){
    80000576:	1141                	addi	sp,sp,-16
    80000578:	e422                	sd	s0,8(sp)
    8000057a:	0800                	addi	s0,sp,16
    asm volatile("mv %0,tp":"=r"(x));
    8000057c:	8512                	mv	a0,tp
}
    8000057e:	2501                	sext.w	a0,a0
    80000580:	6422                	ld	s0,8(sp)
    80000582:	0141                	addi	sp,sp,16
    80000584:	8082                	ret

0000000080000586 <mycpu>:
struct cpu* mycpu(){
    80000586:	1141                	addi	sp,sp,-16
    80000588:	e422                	sd	s0,8(sp)
    8000058a:	0800                	addi	s0,sp,16
    8000058c:	8792                	mv	a5,tp
	return &cpus[id];
    8000058e:	2781                	sext.w	a5,a5
    80000590:	079e                	slli	a5,a5,0x7
}
    80000592:	00010517          	auipc	a0,0x10
    80000596:	bfe50513          	addi	a0,a0,-1026 # 80010190 <cpus>
    8000059a:	953e                	add	a0,a0,a5
    8000059c:	6422                	ld	s0,8(sp)
    8000059e:	0141                	addi	sp,sp,16
    800005a0:	8082                	ret

00000000800005a2 <myproc>:
struct proc* myproc(){
    800005a2:	1101                	addi	sp,sp,-32
    800005a4:	ec06                	sd	ra,24(sp)
    800005a6:	e822                	sd	s0,16(sp)
    800005a8:	e426                	sd	s1,8(sp)
    800005aa:	1000                	addi	s0,sp,32
	push_off();
    800005ac:	00001097          	auipc	ra,0x1
    800005b0:	238080e7          	jalr	568(ra) # 800017e4 <push_off>
    800005b4:	8792                	mv	a5,tp
	struct proc *p = cpu->p;
    800005b6:	2781                	sext.w	a5,a5
    800005b8:	079e                	slli	a5,a5,0x7
    800005ba:	00010717          	auipc	a4,0x10
    800005be:	bd670713          	addi	a4,a4,-1066 # 80010190 <cpus>
    800005c2:	97ba                	add	a5,a5,a4
    800005c4:	6384                	ld	s1,0(a5)
	pop_off();
    800005c6:	00001097          	auipc	ra,0x1
    800005ca:	2c0080e7          	jalr	704(ra) # 80001886 <pop_off>
}
    800005ce:	8526                	mv	a0,s1
    800005d0:	60e2                	ld	ra,24(sp)
    800005d2:	6442                	ld	s0,16(sp)
    800005d4:	64a2                	ld	s1,8(sp)
    800005d6:	6105                	addi	sp,sp,32
    800005d8:	8082                	ret

00000000800005da <forkret>:
void forkret(){
    800005da:	1141                	addi	sp,sp,-16
    800005dc:	e406                	sd	ra,8(sp)
    800005de:	e022                	sd	s0,0(sp)
    800005e0:	0800                	addi	s0,sp,16
	release(&myproc()->slock);
    800005e2:	00000097          	auipc	ra,0x0
    800005e6:	fc0080e7          	jalr	-64(ra) # 800005a2 <myproc>
    800005ea:	0521                	addi	a0,a0,8
    800005ec:	00001097          	auipc	ra,0x1
    800005f0:	306080e7          	jalr	774(ra) # 800018f2 <release>
	if(firstinit){
    800005f4:	00007797          	auipc	a5,0x7
    800005f8:	60c7a783          	lw	a5,1548(a5) # 80007c00 <firstinit.1503>
    800005fc:	eb89                	bnez	a5,8000060e <forkret+0x34>
	usertrapret();
    800005fe:	00001097          	auipc	ra,0x1
    80000602:	e46080e7          	jalr	-442(ra) # 80001444 <usertrapret>
}
    80000606:	60a2                	ld	ra,8(sp)
    80000608:	6402                	ld	s0,0(sp)
    8000060a:	0141                	addi	sp,sp,16
    8000060c:	8082                	ret
		firstinit = 0;
    8000060e:	00007797          	auipc	a5,0x7
    80000612:	5e07a923          	sw	zero,1522(a5) # 80007c00 <firstinit.1503>
		initfs(ROOTDEV);
    80000616:	4505                	li	a0,1
    80000618:	00002097          	auipc	ra,0x2
    8000061c:	f34080e7          	jalr	-204(ra) # 8000254c <initfs>
    80000620:	bff9                	j	800005fe <forkret+0x24>

0000000080000622 <wakeup>:
void wakeup(void *chan){
    80000622:	7139                	addi	sp,sp,-64
    80000624:	fc06                	sd	ra,56(sp)
    80000626:	f822                	sd	s0,48(sp)
    80000628:	f426                	sd	s1,40(sp)
    8000062a:	f04a                	sd	s2,32(sp)
    8000062c:	ec4e                	sd	s3,24(sp)
    8000062e:	e852                	sd	s4,16(sp)
    80000630:	e456                	sd	s5,8(sp)
    80000632:	e05a                	sd	s6,0(sp)
    80000634:	0080                	addi	s0,sp,64
    80000636:	8aaa                	mv	s5,a0
	for(p = procs;p < procs+NPROC; p++){
    80000638:	00010497          	auipc	s1,0x10
    8000063c:	f8848493          	addi	s1,s1,-120 # 800105c0 <procs>
			if(p->state == SLEEPING && p->chan == chan){
    80000640:	4a09                	li	s4,2
				p->state = RUNNABLE;
    80000642:	4b0d                	li	s6,3
	for(p = procs;p < procs+NPROC; p++){
    80000644:	00016997          	auipc	s3,0x16
    80000648:	97c98993          	addi	s3,s3,-1668 # 80015fc0 <uart_tx_lock>
    8000064c:	a821                	j	80000664 <wakeup+0x42>
				p->state = RUNNABLE;
    8000064e:	0164a023          	sw	s6,0(s1)
			release(&p->slock);
    80000652:	854a                	mv	a0,s2
    80000654:	00001097          	auipc	ra,0x1
    80000658:	29e080e7          	jalr	670(ra) # 800018f2 <release>
	for(p = procs;p < procs+NPROC; p++){
    8000065c:	16848493          	addi	s1,s1,360
    80000660:	03348663          	beq	s1,s3,8000068c <wakeup+0x6a>
		if(p != myproc()){
    80000664:	00000097          	auipc	ra,0x0
    80000668:	f3e080e7          	jalr	-194(ra) # 800005a2 <myproc>
    8000066c:	fea488e3          	beq	s1,a0,8000065c <wakeup+0x3a>
			acquire(&p->slock);
    80000670:	00848913          	addi	s2,s1,8
    80000674:	854a                	mv	a0,s2
    80000676:	00001097          	auipc	ra,0x1
    8000067a:	1ba080e7          	jalr	442(ra) # 80001830 <acquire>
			if(p->state == SLEEPING && p->chan == chan){
    8000067e:	409c                	lw	a5,0(s1)
    80000680:	fd4799e3          	bne	a5,s4,80000652 <wakeup+0x30>
    80000684:	68bc                	ld	a5,80(s1)
    80000686:	fd5796e3          	bne	a5,s5,80000652 <wakeup+0x30>
    8000068a:	b7d1                	j	8000064e <wakeup+0x2c>
}
    8000068c:	70e2                	ld	ra,56(sp)
    8000068e:	7442                	ld	s0,48(sp)
    80000690:	74a2                	ld	s1,40(sp)
    80000692:	7902                	ld	s2,32(sp)
    80000694:	69e2                	ld	s3,24(sp)
    80000696:	6a42                	ld	s4,16(sp)
    80000698:	6aa2                	ld	s5,8(sp)
    8000069a:	6b02                	ld	s6,0(sp)
    8000069c:	6121                	addi	sp,sp,64
    8000069e:	8082                	ret

00000000800006a0 <procdump>:
{
    800006a0:	715d                	addi	sp,sp,-80
    800006a2:	e486                	sd	ra,72(sp)
    800006a4:	e0a2                	sd	s0,64(sp)
    800006a6:	fc26                	sd	s1,56(sp)
    800006a8:	f84a                	sd	s2,48(sp)
    800006aa:	f44e                	sd	s3,40(sp)
    800006ac:	f052                	sd	s4,32(sp)
    800006ae:	ec56                	sd	s5,24(sp)
    800006b0:	e85a                	sd	s6,16(sp)
    800006b2:	e45e                	sd	s7,8(sp)
    800006b4:	0880                	addi	s0,sp,80
  printf("\n");
    800006b6:	00007517          	auipc	a0,0x7
    800006ba:	32a50513          	addi	a0,a0,810 # 800079e0 <syscalls+0x1a0>
    800006be:	00000097          	auipc	ra,0x0
    800006c2:	bfc080e7          	jalr	-1028(ra) # 800002ba <printf>
  for(p = procs; p < &procs[NPROC]; p++){
    800006c6:	00010497          	auipc	s1,0x10
    800006ca:	f1a48493          	addi	s1,s1,-230 # 800105e0 <procs+0x20>
    800006ce:	00016917          	auipc	s2,0x16
    800006d2:	91290913          	addi	s2,s2,-1774 # 80015fe0 <uart_tx_buf+0x8>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800006d6:	4b15                	li	s6,5
      state = "???";
    800006d8:	00007997          	auipc	s3,0x7
    800006dc:	97098993          	addi	s3,s3,-1680 # 80007048 <nums+0x18>
    printf("%d %s %s", p->pid, state, p->name);
    800006e0:	00007a97          	auipc	s5,0x7
    800006e4:	970a8a93          	addi	s5,s5,-1680 # 80007050 <nums+0x20>
    printf("\n");
    800006e8:	00007a17          	auipc	s4,0x7
    800006ec:	2f8a0a13          	addi	s4,s4,760 # 800079e0 <syscalls+0x1a0>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800006f0:	00007b97          	auipc	s7,0x7
    800006f4:	b28b8b93          	addi	s7,s7,-1240 # 80007218 <states.1524>
    800006f8:	a005                	j	80000718 <procdump+0x78>
    printf("%d %s %s", p->pid, state, p->name);
    800006fa:	4a8c                	lw	a1,16(a3)
    800006fc:	8556                	mv	a0,s5
    800006fe:	00000097          	auipc	ra,0x0
    80000702:	bbc080e7          	jalr	-1092(ra) # 800002ba <printf>
    printf("\n");
    80000706:	8552                	mv	a0,s4
    80000708:	00000097          	auipc	ra,0x0
    8000070c:	bb2080e7          	jalr	-1102(ra) # 800002ba <printf>
  for(p = procs; p < &procs[NPROC]; p++){
    80000710:	16848493          	addi	s1,s1,360
    80000714:	03248163          	beq	s1,s2,80000736 <procdump+0x96>
    if(p->state == UNUSED)
    80000718:	86a6                	mv	a3,s1
    8000071a:	fe04a783          	lw	a5,-32(s1)
    8000071e:	dbed                	beqz	a5,80000710 <procdump+0x70>
      state = "???";
    80000720:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80000722:	fcfb6ce3          	bltu	s6,a5,800006fa <procdump+0x5a>
    80000726:	1782                	slli	a5,a5,0x20
    80000728:	9381                	srli	a5,a5,0x20
    8000072a:	078e                	slli	a5,a5,0x3
    8000072c:	97de                	add	a5,a5,s7
    8000072e:	6390                	ld	a2,0(a5)
    80000730:	f669                	bnez	a2,800006fa <procdump+0x5a>
      state = "???";
    80000732:	864e                	mv	a2,s3
    80000734:	b7d9                	j	800006fa <procdump+0x5a>
}
    80000736:	60a6                	ld	ra,72(sp)
    80000738:	6406                	ld	s0,64(sp)
    8000073a:	74e2                	ld	s1,56(sp)
    8000073c:	7942                	ld	s2,48(sp)
    8000073e:	79a2                	ld	s3,40(sp)
    80000740:	7a02                	ld	s4,32(sp)
    80000742:	6ae2                	ld	s5,24(sp)
    80000744:	6b42                	ld	s6,16(sp)
    80000746:	6ba2                	ld	s7,8(sp)
    80000748:	6161                	addi	sp,sp,80
    8000074a:	8082                	ret

000000008000074c <initproc>:
void initproc(){
    8000074c:	7139                	addi	sp,sp,-64
    8000074e:	fc06                	sd	ra,56(sp)
    80000750:	f822                	sd	s0,48(sp)
    80000752:	f426                	sd	s1,40(sp)
    80000754:	f04a                	sd	s2,32(sp)
    80000756:	ec4e                	sd	s3,24(sp)
    80000758:	e852                	sd	s4,16(sp)
    8000075a:	e456                	sd	s5,8(sp)
    8000075c:	e05a                	sd	s6,0(sp)
    8000075e:	0080                	addi	s0,sp,64
	initlock(&pid_lock, "nextpid");
    80000760:	00007597          	auipc	a1,0x7
    80000764:	90058593          	addi	a1,a1,-1792 # 80007060 <nums+0x30>
    80000768:	00010517          	auipc	a0,0x10
    8000076c:	e2850513          	addi	a0,a0,-472 # 80010590 <pid_lock>
    80000770:	00001097          	auipc	ra,0x1
    80000774:	034080e7          	jalr	52(ra) # 800017a4 <initlock>
  	initlock(&wait_lock, "wait_lock");	
    80000778:	00007597          	auipc	a1,0x7
    8000077c:	8f058593          	addi	a1,a1,-1808 # 80007068 <nums+0x38>
    80000780:	00010517          	auipc	a0,0x10
    80000784:	e2850513          	addi	a0,a0,-472 # 800105a8 <wait_lock>
    80000788:	00001097          	auipc	ra,0x1
    8000078c:	01c080e7          	jalr	28(ra) # 800017a4 <initlock>
	for(p = procs; p < &procs[NPROC]; p++){
    80000790:	00010497          	auipc	s1,0x10
    80000794:	e3048493          	addi	s1,s1,-464 # 800105c0 <procs>
		initlock(&p->slock,"proc");
    80000798:	00007b17          	auipc	s6,0x7
    8000079c:	8e0b0b13          	addi	s6,s6,-1824 # 80007078 <nums+0x48>
		p->kstack = KSTACK((int) (p - procs));
    800007a0:	8aa6                	mv	s5,s1
    800007a2:	00007a17          	auipc	s4,0x7
    800007a6:	85ea0a13          	addi	s4,s4,-1954 # 80007000 <etext>
    800007aa:	04000937          	lui	s2,0x4000
    800007ae:	197d                	addi	s2,s2,-1
    800007b0:	0932                	slli	s2,s2,0xc
	for(p = procs; p < &procs[NPROC]; p++){
    800007b2:	00016997          	auipc	s3,0x16
    800007b6:	80e98993          	addi	s3,s3,-2034 # 80015fc0 <uart_tx_lock>
		initlock(&p->slock,"proc");
    800007ba:	85da                	mv	a1,s6
    800007bc:	00848513          	addi	a0,s1,8
    800007c0:	00001097          	auipc	ra,0x1
    800007c4:	fe4080e7          	jalr	-28(ra) # 800017a4 <initlock>
		p->kstack = KSTACK((int) (p - procs));
    800007c8:	415487b3          	sub	a5,s1,s5
    800007cc:	878d                	srai	a5,a5,0x3
    800007ce:	000a3703          	ld	a4,0(s4)
    800007d2:	02e787b3          	mul	a5,a5,a4
    800007d6:	2785                	addiw	a5,a5,1
    800007d8:	00d7979b          	slliw	a5,a5,0xd
    800007dc:	40f907b3          	sub	a5,s2,a5
    800007e0:	e4bc                	sd	a5,72(s1)
	for(p = procs; p < &procs[NPROC]; p++){
    800007e2:	16848493          	addi	s1,s1,360
    800007e6:	fd349ae3          	bne	s1,s3,800007ba <initproc+0x6e>
}
    800007ea:	70e2                	ld	ra,56(sp)
    800007ec:	7442                	ld	s0,48(sp)
    800007ee:	74a2                	ld	s1,40(sp)
    800007f0:	7902                	ld	s2,32(sp)
    800007f2:	69e2                	ld	s3,24(sp)
    800007f4:	6a42                	ld	s4,16(sp)
    800007f6:	6aa2                	ld	s5,8(sp)
    800007f8:	6b02                	ld	s6,0(sp)
    800007fa:	6121                	addi	sp,sp,64
    800007fc:	8082                	ret

00000000800007fe <allocpid>:
int allocpid(){
    800007fe:	1101                	addi	sp,sp,-32
    80000800:	ec06                	sd	ra,24(sp)
    80000802:	e822                	sd	s0,16(sp)
    80000804:	e426                	sd	s1,8(sp)
    80000806:	e04a                	sd	s2,0(sp)
    80000808:	1000                	addi	s0,sp,32
	acquire(&pid_lock);
    8000080a:	00010917          	auipc	s2,0x10
    8000080e:	d8690913          	addi	s2,s2,-634 # 80010590 <pid_lock>
    80000812:	854a                	mv	a0,s2
    80000814:	00001097          	auipc	ra,0x1
    80000818:	01c080e7          	jalr	28(ra) # 80001830 <acquire>
	pid = nextPid++;
    8000081c:	00007497          	auipc	s1,0x7
    80000820:	3e84a483          	lw	s1,1000(s1) # 80007c04 <nextPid>
    80000824:	0014879b          	addiw	a5,s1,1
    80000828:	00007717          	auipc	a4,0x7
    8000082c:	3cf72e23          	sw	a5,988(a4) # 80007c04 <nextPid>
	release(&pid_lock);
    80000830:	854a                	mv	a0,s2
    80000832:	00001097          	auipc	ra,0x1
    80000836:	0c0080e7          	jalr	192(ra) # 800018f2 <release>
}
    8000083a:	8526                	mv	a0,s1
    8000083c:	60e2                	ld	ra,24(sp)
    8000083e:	6442                	ld	s0,16(sp)
    80000840:	64a2                	ld	s1,8(sp)
    80000842:	6902                	ld	s2,0(sp)
    80000844:	6105                	addi	sp,sp,32
    80000846:	8082                	ret

0000000080000848 <growproc>:
int growproc(int n){
    80000848:	7179                	addi	sp,sp,-48
    8000084a:	f406                	sd	ra,40(sp)
    8000084c:	f022                	sd	s0,32(sp)
    8000084e:	ec26                	sd	s1,24(sp)
    80000850:	e84a                	sd	s2,16(sp)
    80000852:	e44e                	sd	s3,8(sp)
    80000854:	e052                	sd	s4,0(sp)
    80000856:	1800                	addi	s0,sp,48
    80000858:	84aa                	mv	s1,a0
	struct proc *p = myproc();
    8000085a:	00000097          	auipc	ra,0x0
    8000085e:	d48080e7          	jalr	-696(ra) # 800005a2 <myproc>
    80000862:	892a                	mv	s2,a0
	uint sz = p->sz;
    80000864:	05853a03          	ld	s4,88(a0)
    80000868:	000a099b          	sext.w	s3,s4
	if(n > 0){
    8000086c:	02904263          	bgtz	s1,80000890 <growproc+0x48>
	}else if(n < 0){
    80000870:	0404c163          	bltz	s1,800008b2 <growproc+0x6a>
	p->sz = sz;
    80000874:	02099613          	slli	a2,s3,0x20
    80000878:	9201                	srli	a2,a2,0x20
    8000087a:	04c93c23          	sd	a2,88(s2)
	return 0;
    8000087e:	4501                	li	a0,0
}
    80000880:	70a2                	ld	ra,40(sp)
    80000882:	7402                	ld	s0,32(sp)
    80000884:	64e2                	ld	s1,24(sp)
    80000886:	6942                	ld	s2,16(sp)
    80000888:	69a2                	ld	s3,8(sp)
    8000088a:	6a02                	ld	s4,0(sp)
    8000088c:	6145                	addi	sp,sp,48
    8000088e:	8082                	ret
		if((sz ==  uvmalloc(p->pagetable,sz,sz+n)) == 0){
    80000890:	1a02                	slli	s4,s4,0x20
    80000892:	020a5a13          	srli	s4,s4,0x20
    80000896:	0134863b          	addw	a2,s1,s3
    8000089a:	1602                	slli	a2,a2,0x20
    8000089c:	9201                	srli	a2,a2,0x20
    8000089e:	85d2                	mv	a1,s4
    800008a0:	7528                	ld	a0,104(a0)
    800008a2:	00004097          	auipc	ra,0x4
    800008a6:	526080e7          	jalr	1318(ra) # 80004dc8 <uvmalloc>
    800008aa:	fd4505e3          	beq	a0,s4,80000874 <growproc+0x2c>
			return -1;
    800008ae:	557d                	li	a0,-1
    800008b0:	bfc1                	j	80000880 <growproc+0x38>
		sz = uvmalloc(p->pagetable,sz,sz+n);
    800008b2:	0134863b          	addw	a2,s1,s3
    800008b6:	1602                	slli	a2,a2,0x20
    800008b8:	9201                	srli	a2,a2,0x20
    800008ba:	020a1593          	slli	a1,s4,0x20
    800008be:	9181                	srli	a1,a1,0x20
    800008c0:	7528                	ld	a0,104(a0)
    800008c2:	00004097          	auipc	ra,0x4
    800008c6:	506080e7          	jalr	1286(ra) # 80004dc8 <uvmalloc>
    800008ca:	0005099b          	sext.w	s3,a0
    800008ce:	b75d                	j	80000874 <growproc+0x2c>

00000000800008d0 <proc_mapstacks>:


void proc_mapstacks(pagetable_t pg){
    800008d0:	715d                	addi	sp,sp,-80
    800008d2:	e486                	sd	ra,72(sp)
    800008d4:	e0a2                	sd	s0,64(sp)
    800008d6:	fc26                	sd	s1,56(sp)
    800008d8:	f84a                	sd	s2,48(sp)
    800008da:	f44e                	sd	s3,40(sp)
    800008dc:	f052                	sd	s4,32(sp)
    800008de:	ec56                	sd	s5,24(sp)
    800008e0:	e85a                	sd	s6,16(sp)
    800008e2:	e45e                	sd	s7,8(sp)
    800008e4:	e062                	sd	s8,0(sp)
    800008e6:	0880                	addi	s0,sp,80
    800008e8:	8a2a                	mv	s4,a0
	struct proc *p;
	for(p = procs; p < &procs[NPROC]; p++){
    800008ea:	00010917          	auipc	s2,0x10
    800008ee:	cd690913          	addi	s2,s2,-810 # 800105c0 <procs>
		char *pa = kalloc();
		if(pa == 0){
			panic("proc_mapstacks kalloc...\n");
    800008f2:	00006c17          	auipc	s8,0x6
    800008f6:	78ec0c13          	addi	s8,s8,1934 # 80007080 <nums+0x50>
		}
		uint64 va = KSTACK((int) (p - procs));
    800008fa:	8bca                	mv	s7,s2
    800008fc:	00006b17          	auipc	s6,0x6
    80000900:	704b0b13          	addi	s6,s6,1796 # 80007000 <etext>
    80000904:	040009b7          	lui	s3,0x4000
    80000908:	19fd                	addi	s3,s3,-1
    8000090a:	09b2                	slli	s3,s3,0xc
	for(p = procs; p < &procs[NPROC]; p++){
    8000090c:	00015a97          	auipc	s5,0x15
    80000910:	6b4a8a93          	addi	s5,s5,1716 # 80015fc0 <uart_tx_lock>
    80000914:	a80d                	j	80000946 <proc_mapstacks+0x76>
		uint64 va = KSTACK((int) (p - procs));
    80000916:	417905b3          	sub	a1,s2,s7
    8000091a:	858d                	srai	a1,a1,0x3
    8000091c:	000b3783          	ld	a5,0(s6)
    80000920:	02f585b3          	mul	a1,a1,a5
    80000924:	2585                	addiw	a1,a1,1
    80000926:	00d5959b          	slliw	a1,a1,0xd
		kvmmap(pg, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000092a:	4719                	li	a4,6
    8000092c:	6685                	lui	a3,0x1
    8000092e:	8626                	mv	a2,s1
    80000930:	40b985b3          	sub	a1,s3,a1
    80000934:	8552                	mv	a0,s4
    80000936:	00004097          	auipc	ra,0x4
    8000093a:	e58080e7          	jalr	-424(ra) # 8000478e <kvmmap>
	for(p = procs; p < &procs[NPROC]; p++){
    8000093e:	16890913          	addi	s2,s2,360
    80000942:	01590e63          	beq	s2,s5,8000095e <proc_mapstacks+0x8e>
		char *pa = kalloc();
    80000946:	00004097          	auipc	ra,0x4
    8000094a:	c88080e7          	jalr	-888(ra) # 800045ce <kalloc>
    8000094e:	84aa                	mv	s1,a0
		if(pa == 0){
    80000950:	f179                	bnez	a0,80000916 <proc_mapstacks+0x46>
			panic("proc_mapstacks kalloc...\n");
    80000952:	8562                	mv	a0,s8
    80000954:	00000097          	auipc	ra,0x0
    80000958:	b30080e7          	jalr	-1232(ra) # 80000484 <panic>
    8000095c:	bf6d                	j	80000916 <proc_mapstacks+0x46>
	}
}
    8000095e:	60a6                	ld	ra,72(sp)
    80000960:	6406                	ld	s0,64(sp)
    80000962:	74e2                	ld	s1,56(sp)
    80000964:	7942                	ld	s2,48(sp)
    80000966:	79a2                	ld	s3,40(sp)
    80000968:	7a02                	ld	s4,32(sp)
    8000096a:	6ae2                	ld	s5,24(sp)
    8000096c:	6b42                	ld	s6,16(sp)
    8000096e:	6ba2                	ld	s7,8(sp)
    80000970:	6c02                	ld	s8,0(sp)
    80000972:	6161                	addi	sp,sp,80
    80000974:	8082                	ret

0000000080000976 <sched>:
	}
}



void sched(){
    80000976:	7179                	addi	sp,sp,-48
    80000978:	f406                	sd	ra,40(sp)
    8000097a:	f022                	sd	s0,32(sp)
    8000097c:	ec26                	sd	s1,24(sp)
    8000097e:	e84a                	sd	s2,16(sp)
    80000980:	e44e                	sd	s3,8(sp)
    80000982:	1800                	addi	s0,sp,48
	struct proc *p = myproc();
    80000984:	00000097          	auipc	ra,0x0
    80000988:	c1e080e7          	jalr	-994(ra) # 800005a2 <myproc>
    8000098c:	892a                	mv	s2,a0
	if(!holdinglock(&p->slock)){
    8000098e:	0521                	addi	a0,a0,8
    80000990:	00001097          	auipc	ra,0x1
    80000994:	e26080e7          	jalr	-474(ra) # 800017b6 <holdinglock>
    80000998:	cd21                	beqz	a0,800009f0 <sched+0x7a>
		panic("sched holdinglock \n");
	}
	if(p->state == RUNNING){
    8000099a:	00092703          	lw	a4,0(s2)
    8000099e:	4791                	li	a5,4
    800009a0:	06f70163          	beq	a4,a5,80000a02 <sched+0x8c>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800009a4:	100027f3          	csrr	a5,sstatus
    return (r_sstatus() & SSTATUS_SIE) != 0;
    800009a8:	8b89                	andi	a5,a5,2
		panic("sched p.state is Running \n");
	}
	if(intr_get()){
    800009aa:	e7ad                	bnez	a5,80000a14 <sched+0x9e>
    asm volatile("mv %0,tp":"=r"(x));
    800009ac:	8792                	mv	a5,tp
		panic("sched interruptible");
	}

	int intena = mycpu()->intena;
    800009ae:	0000f497          	auipc	s1,0xf
    800009b2:	7e248493          	addi	s1,s1,2018 # 80010190 <cpus>
    800009b6:	2781                	sext.w	a5,a5
    800009b8:	079e                	slli	a5,a5,0x7
    800009ba:	97a6                	add	a5,a5,s1
    800009bc:	07c7a983          	lw	s3,124(a5)
    800009c0:	8592                	mv	a1,tp
	swtch(&p->cont, &mycpu()->context);
    800009c2:	2581                	sext.w	a1,a1
    800009c4:	059e                	slli	a1,a1,0x7
    800009c6:	05a1                	addi	a1,a1,8
    800009c8:	95a6                	add	a1,a1,s1
    800009ca:	07090513          	addi	a0,s2,112
    800009ce:	00000097          	auipc	ra,0x0
    800009d2:	b00080e7          	jalr	-1280(ra) # 800004ce <swtch>
    800009d6:	8792                	mv	a5,tp
	mycpu()->intena = intena;
    800009d8:	2781                	sext.w	a5,a5
    800009da:	079e                	slli	a5,a5,0x7
    800009dc:	94be                	add	s1,s1,a5
    800009de:	0734ae23          	sw	s3,124(s1)
}
    800009e2:	70a2                	ld	ra,40(sp)
    800009e4:	7402                	ld	s0,32(sp)
    800009e6:	64e2                	ld	s1,24(sp)
    800009e8:	6942                	ld	s2,16(sp)
    800009ea:	69a2                	ld	s3,8(sp)
    800009ec:	6145                	addi	sp,sp,48
    800009ee:	8082                	ret
		panic("sched holdinglock \n");
    800009f0:	00006517          	auipc	a0,0x6
    800009f4:	6b050513          	addi	a0,a0,1712 # 800070a0 <nums+0x70>
    800009f8:	00000097          	auipc	ra,0x0
    800009fc:	a8c080e7          	jalr	-1396(ra) # 80000484 <panic>
    80000a00:	bf69                	j	8000099a <sched+0x24>
		panic("sched p.state is Running \n");
    80000a02:	00006517          	auipc	a0,0x6
    80000a06:	6b650513          	addi	a0,a0,1718 # 800070b8 <nums+0x88>
    80000a0a:	00000097          	auipc	ra,0x0
    80000a0e:	a7a080e7          	jalr	-1414(ra) # 80000484 <panic>
    80000a12:	bf49                	j	800009a4 <sched+0x2e>
		panic("sched interruptible");
    80000a14:	00006517          	auipc	a0,0x6
    80000a18:	6c450513          	addi	a0,a0,1732 # 800070d8 <nums+0xa8>
    80000a1c:	00000097          	auipc	ra,0x0
    80000a20:	a68080e7          	jalr	-1432(ra) # 80000484 <panic>
    80000a24:	b761                	j	800009ac <sched+0x36>

0000000080000a26 <sleep>:


void sleep(void *p,struct spinlock *lk){
    80000a26:	7179                	addi	sp,sp,-48
    80000a28:	f406                	sd	ra,40(sp)
    80000a2a:	f022                	sd	s0,32(sp)
    80000a2c:	ec26                	sd	s1,24(sp)
    80000a2e:	e84a                	sd	s2,16(sp)
    80000a30:	e44e                	sd	s3,8(sp)
    80000a32:	e052                	sd	s4,0(sp)
    80000a34:	1800                	addi	s0,sp,48
    80000a36:	89aa                	mv	s3,a0
    80000a38:	892e                	mv	s2,a1
	struct proc *pc = myproc();
    80000a3a:	00000097          	auipc	ra,0x0
    80000a3e:	b68080e7          	jalr	-1176(ra) # 800005a2 <myproc>
    80000a42:	84aa                	mv	s1,a0

	acquire(&pc->slock);
    80000a44:	00850a13          	addi	s4,a0,8
    80000a48:	8552                	mv	a0,s4
    80000a4a:	00001097          	auipc	ra,0x1
    80000a4e:	de6080e7          	jalr	-538(ra) # 80001830 <acquire>
	release(lk);
    80000a52:	854a                	mv	a0,s2
    80000a54:	00001097          	auipc	ra,0x1
    80000a58:	e9e080e7          	jalr	-354(ra) # 800018f2 <release>
	pc->chan = p;
    80000a5c:	0534b823          	sd	s3,80(s1)
	pc->state = SLEEPING;
    80000a60:	4789                	li	a5,2
    80000a62:	c09c                	sw	a5,0(s1)

	sched();
    80000a64:	00000097          	auipc	ra,0x0
    80000a68:	f12080e7          	jalr	-238(ra) # 80000976 <sched>

	pc->chan = 0;
    80000a6c:	0404b823          	sd	zero,80(s1)
	release(&pc->slock);
    80000a70:	8552                	mv	a0,s4
    80000a72:	00001097          	auipc	ra,0x1
    80000a76:	e80080e7          	jalr	-384(ra) # 800018f2 <release>
	acquire(lk);
    80000a7a:	854a                	mv	a0,s2
    80000a7c:	00001097          	auipc	ra,0x1
    80000a80:	db4080e7          	jalr	-588(ra) # 80001830 <acquire>
}
    80000a84:	70a2                	ld	ra,40(sp)
    80000a86:	7402                	ld	s0,32(sp)
    80000a88:	64e2                	ld	s1,24(sp)
    80000a8a:	6942                	ld	s2,16(sp)
    80000a8c:	69a2                	ld	s3,8(sp)
    80000a8e:	6a02                	ld	s4,0(sp)
    80000a90:	6145                	addi	sp,sp,48
    80000a92:	8082                	ret

0000000080000a94 <wait>:
int wait(uint64 addr){
    80000a94:	711d                	addi	sp,sp,-96
    80000a96:	ec86                	sd	ra,88(sp)
    80000a98:	e8a2                	sd	s0,80(sp)
    80000a9a:	e4a6                	sd	s1,72(sp)
    80000a9c:	e0ca                	sd	s2,64(sp)
    80000a9e:	fc4e                	sd	s3,56(sp)
    80000aa0:	f852                	sd	s4,48(sp)
    80000aa2:	f456                	sd	s5,40(sp)
    80000aa4:	f05a                	sd	s6,32(sp)
    80000aa6:	ec5e                	sd	s7,24(sp)
    80000aa8:	e862                	sd	s8,16(sp)
    80000aaa:	e466                	sd	s9,8(sp)
    80000aac:	1080                	addi	s0,sp,96
    80000aae:	8baa                	mv	s7,a0
	struct proc *p = myproc();
    80000ab0:	00000097          	auipc	ra,0x0
    80000ab4:	af2080e7          	jalr	-1294(ra) # 800005a2 <myproc>
    80000ab8:	892a                	mv	s2,a0
	acquire(&wait_lock);
    80000aba:	00010517          	auipc	a0,0x10
    80000abe:	aee50513          	addi	a0,a0,-1298 # 800105a8 <wait_lock>
    80000ac2:	00001097          	auipc	ra,0x1
    80000ac6:	d6e080e7          	jalr	-658(ra) # 80001830 <acquire>
		havekids = 0;
    80000aca:	4c01                	li	s8,0
				if(np->state == ZOMBIE){
    80000acc:	4a95                	li	s5,5
		for(np = procs; np < &procs[NPROC]; np++){
    80000ace:	00015997          	auipc	s3,0x15
    80000ad2:	4f298993          	addi	s3,s3,1266 # 80015fc0 <uart_tx_lock>
				havekids = 1;
    80000ad6:	4b05                	li	s6,1
		sleep(p,&wait_lock);
    80000ad8:	00010c97          	auipc	s9,0x10
    80000adc:	ad0c8c93          	addi	s9,s9,-1328 # 800105a8 <wait_lock>
		for(np = procs; np < &procs[NPROC]; np++){
    80000ae0:	00010497          	auipc	s1,0x10
    80000ae4:	ae048493          	addi	s1,s1,-1312 # 800105c0 <procs>
		havekids = 0;
    80000ae8:	8762                	mv	a4,s8
    80000aea:	a8bd                	j	80000b68 <wait+0xd4>
					pid = np->pid;
    80000aec:	0304a983          	lw	s3,48(s1)
					if(addr != 0 && copyoutpg(p->pagetable, addr, (char *)&np->xstate,
    80000af0:	000b8e63          	beqz	s7,80000b0c <wait+0x78>
    80000af4:	4691                	li	a3,4
    80000af6:	03848613          	addi	a2,s1,56
    80000afa:	85de                	mv	a1,s7
    80000afc:	06893503          	ld	a0,104(s2)
    80000b00:	00003097          	auipc	ra,0x3
    80000b04:	fbc080e7          	jalr	-68(ra) # 80003abc <copyoutpg>
    80000b08:	02054563          	bltz	a0,80000b32 <wait+0x9e>
					freeproc(np);
    80000b0c:	8526                	mv	a0,s1
    80000b0e:	00000097          	auipc	ra,0x0
    80000b12:	a2a080e7          	jalr	-1494(ra) # 80000538 <freeproc>
					release(&np->slock);
    80000b16:	8552                	mv	a0,s4
    80000b18:	00001097          	auipc	ra,0x1
    80000b1c:	dda080e7          	jalr	-550(ra) # 800018f2 <release>
					release(&wait_lock);
    80000b20:	00010517          	auipc	a0,0x10
    80000b24:	a8850513          	addi	a0,a0,-1400 # 800105a8 <wait_lock>
    80000b28:	00001097          	auipc	ra,0x1
    80000b2c:	dca080e7          	jalr	-566(ra) # 800018f2 <release>
					return pid;
    80000b30:	a8ad                	j	80000baa <wait+0x116>
						release(&np->slock);
    80000b32:	8552                	mv	a0,s4
    80000b34:	00001097          	auipc	ra,0x1
    80000b38:	dbe080e7          	jalr	-578(ra) # 800018f2 <release>
						release(&wait_lock);
    80000b3c:	00010517          	auipc	a0,0x10
    80000b40:	a6c50513          	addi	a0,a0,-1428 # 800105a8 <wait_lock>
    80000b44:	00001097          	auipc	ra,0x1
    80000b48:	dae080e7          	jalr	-594(ra) # 800018f2 <release>
						panic("wait:copyoutpg -1");
    80000b4c:	00006517          	auipc	a0,0x6
    80000b50:	5a450513          	addi	a0,a0,1444 # 800070f0 <nums+0xc0>
    80000b54:	00000097          	auipc	ra,0x0
    80000b58:	930080e7          	jalr	-1744(ra) # 80000484 <panic>
						return -1;
    80000b5c:	59fd                	li	s3,-1
    80000b5e:	a0b1                	j	80000baa <wait+0x116>
		for(np = procs; np < &procs[NPROC]; np++){
    80000b60:	16848493          	addi	s1,s1,360
    80000b64:	03348663          	beq	s1,s3,80000b90 <wait+0xfc>
			if(np->parent == p){
    80000b68:	60bc                	ld	a5,64(s1)
    80000b6a:	ff279be3          	bne	a5,s2,80000b60 <wait+0xcc>
				acquire(&np->slock);
    80000b6e:	00848a13          	addi	s4,s1,8
    80000b72:	8552                	mv	a0,s4
    80000b74:	00001097          	auipc	ra,0x1
    80000b78:	cbc080e7          	jalr	-836(ra) # 80001830 <acquire>
				if(np->state == ZOMBIE){
    80000b7c:	409c                	lw	a5,0(s1)
    80000b7e:	f75787e3          	beq	a5,s5,80000aec <wait+0x58>
				release(&np->slock);
    80000b82:	8552                	mv	a0,s4
    80000b84:	00001097          	auipc	ra,0x1
    80000b88:	d6e080e7          	jalr	-658(ra) # 800018f2 <release>
				havekids = 1;
    80000b8c:	875a                	mv	a4,s6
    80000b8e:	bfc9                	j	80000b60 <wait+0xcc>
		if(!havekids || p->killed){
    80000b90:	c701                	beqz	a4,80000b98 <wait+0x104>
    80000b92:	03492783          	lw	a5,52(s2)
    80000b96:	cb85                	beqz	a5,80000bc6 <wait+0x132>
			release(&wait_lock);	
    80000b98:	00010517          	auipc	a0,0x10
    80000b9c:	a1050513          	addi	a0,a0,-1520 # 800105a8 <wait_lock>
    80000ba0:	00001097          	auipc	ra,0x1
    80000ba4:	d52080e7          	jalr	-686(ra) # 800018f2 <release>
			return -1;
    80000ba8:	59fd                	li	s3,-1
}
    80000baa:	854e                	mv	a0,s3
    80000bac:	60e6                	ld	ra,88(sp)
    80000bae:	6446                	ld	s0,80(sp)
    80000bb0:	64a6                	ld	s1,72(sp)
    80000bb2:	6906                	ld	s2,64(sp)
    80000bb4:	79e2                	ld	s3,56(sp)
    80000bb6:	7a42                	ld	s4,48(sp)
    80000bb8:	7aa2                	ld	s5,40(sp)
    80000bba:	7b02                	ld	s6,32(sp)
    80000bbc:	6be2                	ld	s7,24(sp)
    80000bbe:	6c42                	ld	s8,16(sp)
    80000bc0:	6ca2                	ld	s9,8(sp)
    80000bc2:	6125                	addi	sp,sp,96
    80000bc4:	8082                	ret
		sleep(p,&wait_lock);
    80000bc6:	85e6                	mv	a1,s9
    80000bc8:	854a                	mv	a0,s2
    80000bca:	00000097          	auipc	ra,0x0
    80000bce:	e5c080e7          	jalr	-420(ra) # 80000a26 <sleep>
		havekids = 0;
    80000bd2:	b739                	j	80000ae0 <wait+0x4c>

0000000080000bd4 <scheduler>:

void scheduler(){
    80000bd4:	715d                	addi	sp,sp,-80
    80000bd6:	e486                	sd	ra,72(sp)
    80000bd8:	e0a2                	sd	s0,64(sp)
    80000bda:	fc26                	sd	s1,56(sp)
    80000bdc:	f84a                	sd	s2,48(sp)
    80000bde:	f44e                	sd	s3,40(sp)
    80000be0:	f052                	sd	s4,32(sp)
    80000be2:	ec56                	sd	s5,24(sp)
    80000be4:	e85a                	sd	s6,16(sp)
    80000be6:	e45e                	sd	s7,8(sp)
    80000be8:	0880                	addi	s0,sp,80
    80000bea:	8792                	mv	a5,tp
	int cpuid = r_tp();
    80000bec:	2781                	sext.w	a5,a5
	struct proc *p;
	struct cpu *c = mycpu();
	c->p = 0;
    80000bee:	0000fb17          	auipc	s6,0xf
    80000bf2:	5a2b0b13          	addi	s6,s6,1442 # 80010190 <cpus>
    80000bf6:	00779713          	slli	a4,a5,0x7
    80000bfa:	00eb06b3          	add	a3,s6,a4
    80000bfe:	0006b023          	sd	zero,0(a3) # 1000 <_entry-0x7ffff000>
		for(p = procs; p < &procs[NPROC];p++){
			acquire(&p->slock);
			if(p->state == RUNNABLE){
				p->state = RUNNING;
				c->p = p;
				swtch(&c->context,&p->cont);
    80000c02:	0721                	addi	a4,a4,8
    80000c04:	9b3a                	add	s6,s6,a4
			if(p->state == RUNNABLE){
    80000c06:	4a0d                	li	s4,3
				p->state = RUNNING;
    80000c08:	4b91                	li	s7,4
				c->p = p;
    80000c0a:	8ab6                	mv	s5,a3
		for(p = procs; p < &procs[NPROC];p++){
    80000c0c:	00015997          	auipc	s3,0x15
    80000c10:	3b498993          	addi	s3,s3,948 # 80015fc0 <uart_tx_lock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c14:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c18:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c1c:	10079073          	csrw	sstatus,a5
    80000c20:	00010497          	auipc	s1,0x10
    80000c24:	9a048493          	addi	s1,s1,-1632 # 800105c0 <procs>
    80000c28:	a03d                	j	80000c56 <scheduler+0x82>
				p->state = RUNNING;
    80000c2a:	0174a023          	sw	s7,0(s1)
				c->p = p;
    80000c2e:	009ab023          	sd	s1,0(s5)
				swtch(&c->context,&p->cont);
    80000c32:	07048593          	addi	a1,s1,112
    80000c36:	855a                	mv	a0,s6
    80000c38:	00000097          	auipc	ra,0x0
    80000c3c:	896080e7          	jalr	-1898(ra) # 800004ce <swtch>
				c->p = 0;
    80000c40:	000ab023          	sd	zero,0(s5)
			}
			release(&p->slock);
    80000c44:	854a                	mv	a0,s2
    80000c46:	00001097          	auipc	ra,0x1
    80000c4a:	cac080e7          	jalr	-852(ra) # 800018f2 <release>
		for(p = procs; p < &procs[NPROC];p++){
    80000c4e:	16848493          	addi	s1,s1,360
    80000c52:	fd3481e3          	beq	s1,s3,80000c14 <scheduler+0x40>
			acquire(&p->slock);
    80000c56:	00848913          	addi	s2,s1,8
    80000c5a:	854a                	mv	a0,s2
    80000c5c:	00001097          	auipc	ra,0x1
    80000c60:	bd4080e7          	jalr	-1068(ra) # 80001830 <acquire>
			if(p->state == RUNNABLE){
    80000c64:	409c                	lw	a5,0(s1)
    80000c66:	fd479fe3          	bne	a5,s4,80000c44 <scheduler+0x70>
    80000c6a:	b7c1                	j	80000c2a <scheduler+0x56>

0000000080000c6c <yield>:
		}
	}
}


void yield(){
    80000c6c:	1101                	addi	sp,sp,-32
    80000c6e:	ec06                	sd	ra,24(sp)
    80000c70:	e822                	sd	s0,16(sp)
    80000c72:	e426                	sd	s1,8(sp)
    80000c74:	e04a                	sd	s2,0(sp)
    80000c76:	1000                	addi	s0,sp,32
	struct proc *p = myproc();
    80000c78:	00000097          	auipc	ra,0x0
    80000c7c:	92a080e7          	jalr	-1750(ra) # 800005a2 <myproc>
    80000c80:	84aa                	mv	s1,a0
	acquire(&p->slock);
    80000c82:	00850913          	addi	s2,a0,8
    80000c86:	854a                	mv	a0,s2
    80000c88:	00001097          	auipc	ra,0x1
    80000c8c:	ba8080e7          	jalr	-1112(ra) # 80001830 <acquire>
	p->state = RUNNABLE;
    80000c90:	478d                	li	a5,3
    80000c92:	c09c                	sw	a5,0(s1)
	sched();
    80000c94:	00000097          	auipc	ra,0x0
    80000c98:	ce2080e7          	jalr	-798(ra) # 80000976 <sched>
	release(&p->slock);
    80000c9c:	854a                	mv	a0,s2
    80000c9e:	00001097          	auipc	ra,0x1
    80000ca2:	c54080e7          	jalr	-940(ra) # 800018f2 <release>
}
    80000ca6:	60e2                	ld	ra,24(sp)
    80000ca8:	6442                	ld	s0,16(sp)
    80000caa:	64a2                	ld	s1,8(sp)
    80000cac:	6902                	ld	s2,0(sp)
    80000cae:	6105                	addi	sp,sp,32
    80000cb0:	8082                	ret

0000000080000cb2 <proc_pagetable>:

pagetable_t proc_pagetable(struct proc *p){
    80000cb2:	1101                	addi	sp,sp,-32
    80000cb4:	ec06                	sd	ra,24(sp)
    80000cb6:	e822                	sd	s0,16(sp)
    80000cb8:	e426                	sd	s1,8(sp)
    80000cba:	e04a                	sd	s2,0(sp)
    80000cbc:	1000                	addi	s0,sp,32
    80000cbe:	892a                	mv	s2,a0
	pagetable_t pagetable;

	pagetable = uvmcreate();
    80000cc0:	00004097          	auipc	ra,0x4
    80000cc4:	226080e7          	jalr	550(ra) # 80004ee6 <uvmcreate>
    80000cc8:	84aa                	mv	s1,a0
	if(pagetable == 0){
    80000cca:	c921                	beqz	a0,80000d1a <proc_pagetable+0x68>
		panic("proc_pagetable: uvmcreate");
	}
	if(mappages(pagetable, TRAMPOLINE, PGSIZE,(uint64)trampoline, PTE_R | PTE_X) < 0){
    80000ccc:	4729                	li	a4,10
    80000cce:	00005697          	auipc	a3,0x5
    80000cd2:	33268693          	addi	a3,a3,818 # 80006000 <_trampoline>
    80000cd6:	6605                	lui	a2,0x1
    80000cd8:	040005b7          	lui	a1,0x4000
    80000cdc:	15fd                	addi	a1,a1,-1
    80000cde:	05b2                	slli	a1,a1,0xc
    80000ce0:	8526                	mv	a0,s1
    80000ce2:	00004097          	auipc	ra,0x4
    80000ce6:	9f6080e7          	jalr	-1546(ra) # 800046d8 <mappages>
    80000cea:	04054163          	bltz	a0,80000d2c <proc_pagetable+0x7a>
		panic("------proc_pagetable : trampoline");
		uvmfree(pagetable, 0);
    	return 0;
	}

	if(mappages(pagetable, TRAPFRAME, PGSIZE,(uint64)(p->trapframe), PTE_R | PTE_W) < 0){
    80000cee:	4719                	li	a4,6
    80000cf0:	06093683          	ld	a3,96(s2)
    80000cf4:	6605                	lui	a2,0x1
    80000cf6:	020005b7          	lui	a1,0x2000
    80000cfa:	15fd                	addi	a1,a1,-1
    80000cfc:	05b6                	slli	a1,a1,0xd
    80000cfe:	8526                	mv	a0,s1
    80000d00:	00004097          	auipc	ra,0x4
    80000d04:	9d8080e7          	jalr	-1576(ra) # 800046d8 <mappages>
    80000d08:	04054263          	bltz	a0,80000d4c <proc_pagetable+0x9a>
		panic("------proc_pagetable : p->trapframe");
		uvmfree(pagetable, 0);
    	return 0;
	};
	return pagetable;
}
    80000d0c:	8526                	mv	a0,s1
    80000d0e:	60e2                	ld	ra,24(sp)
    80000d10:	6442                	ld	s0,16(sp)
    80000d12:	64a2                	ld	s1,8(sp)
    80000d14:	6902                	ld	s2,0(sp)
    80000d16:	6105                	addi	sp,sp,32
    80000d18:	8082                	ret
		panic("proc_pagetable: uvmcreate");
    80000d1a:	00006517          	auipc	a0,0x6
    80000d1e:	3ee50513          	addi	a0,a0,1006 # 80007108 <nums+0xd8>
    80000d22:	fffff097          	auipc	ra,0xfffff
    80000d26:	762080e7          	jalr	1890(ra) # 80000484 <panic>
    80000d2a:	b74d                	j	80000ccc <proc_pagetable+0x1a>
		panic("------proc_pagetable : trampoline");
    80000d2c:	00006517          	auipc	a0,0x6
    80000d30:	3fc50513          	addi	a0,a0,1020 # 80007128 <nums+0xf8>
    80000d34:	fffff097          	auipc	ra,0xfffff
    80000d38:	750080e7          	jalr	1872(ra) # 80000484 <panic>
		uvmfree(pagetable, 0);
    80000d3c:	4581                	li	a1,0
    80000d3e:	8526                	mv	a0,s1
    80000d40:	00004097          	auipc	ra,0x4
    80000d44:	ed2080e7          	jalr	-302(ra) # 80004c12 <uvmfree>
    	return 0;
    80000d48:	4481                	li	s1,0
    80000d4a:	b7c9                	j	80000d0c <proc_pagetable+0x5a>
		panic("------proc_pagetable : p->trapframe");
    80000d4c:	00006517          	auipc	a0,0x6
    80000d50:	40450513          	addi	a0,a0,1028 # 80007150 <nums+0x120>
    80000d54:	fffff097          	auipc	ra,0xfffff
    80000d58:	730080e7          	jalr	1840(ra) # 80000484 <panic>
		uvmfree(pagetable, 0);
    80000d5c:	4581                	li	a1,0
    80000d5e:	8526                	mv	a0,s1
    80000d60:	00004097          	auipc	ra,0x4
    80000d64:	eb2080e7          	jalr	-334(ra) # 80004c12 <uvmfree>
    	return 0;
    80000d68:	4481                	li	s1,0
    80000d6a:	b74d                	j	80000d0c <proc_pagetable+0x5a>

0000000080000d6c <allocproc>:

static struct proc* allocproc(){
    80000d6c:	7179                	addi	sp,sp,-48
    80000d6e:	f406                	sd	ra,40(sp)
    80000d70:	f022                	sd	s0,32(sp)
    80000d72:	ec26                	sd	s1,24(sp)
    80000d74:	e84a                	sd	s2,16(sp)
    80000d76:	e44e                	sd	s3,8(sp)
    80000d78:	1800                	addi	s0,sp,48
	struct proc *p;

	for(p = procs; p < &procs[NPROC]; p++){
    80000d7a:	00010497          	auipc	s1,0x10
    80000d7e:	84648493          	addi	s1,s1,-1978 # 800105c0 <procs>
    80000d82:	00015997          	auipc	s3,0x15
    80000d86:	23e98993          	addi	s3,s3,574 # 80015fc0 <uart_tx_lock>
		acquire(&p->slock);
    80000d8a:	00848913          	addi	s2,s1,8
    80000d8e:	854a                	mv	a0,s2
    80000d90:	00001097          	auipc	ra,0x1
    80000d94:	aa0080e7          	jalr	-1376(ra) # 80001830 <acquire>
		if(p->state == UNUSED){
    80000d98:	409c                	lw	a5,0(s1)
    80000d9a:	cf81                	beqz	a5,80000db2 <allocproc+0x46>
			memset(&p->cont,0,sizeof(p->cont));
			p->cont.ra = (uint64) forkret;
			p->cont.sp = p->kstack + PGSIZE;
			return p;
		}
		release(&p->slock);	
    80000d9c:	854a                	mv	a0,s2
    80000d9e:	00001097          	auipc	ra,0x1
    80000da2:	b54080e7          	jalr	-1196(ra) # 800018f2 <release>
	for(p = procs; p < &procs[NPROC]; p++){
    80000da6:	16848493          	addi	s1,s1,360
    80000daa:	ff3490e3          	bne	s1,s3,80000d8a <allocproc+0x1e>
	}
	return 0;
    80000dae:	4481                	li	s1,0
    80000db0:	a889                	j	80000e02 <allocproc+0x96>
			p->pid = allocpid();
    80000db2:	00000097          	auipc	ra,0x0
    80000db6:	a4c080e7          	jalr	-1460(ra) # 800007fe <allocpid>
    80000dba:	d888                	sw	a0,48(s1)
			p->state = USED;
    80000dbc:	4785                	li	a5,1
    80000dbe:	c09c                	sw	a5,0(s1)
			if((p->trapframe = (struct trapframe*)kalloc()) == 0){
    80000dc0:	00004097          	auipc	ra,0x4
    80000dc4:	80e080e7          	jalr	-2034(ra) # 800045ce <kalloc>
    80000dc8:	89aa                	mv	s3,a0
    80000dca:	f0a8                	sd	a0,96(s1)
    80000dcc:	c139                	beqz	a0,80000e12 <allocproc+0xa6>
			p->pagetable = proc_pagetable(p);
    80000dce:	8526                	mv	a0,s1
    80000dd0:	00000097          	auipc	ra,0x0
    80000dd4:	ee2080e7          	jalr	-286(ra) # 80000cb2 <proc_pagetable>
    80000dd8:	89aa                	mv	s3,a0
    80000dda:	f4a8                	sd	a0,104(s1)
			if(p->pagetable == 0){
    80000ddc:	cd39                	beqz	a0,80000e3a <allocproc+0xce>
			memset(&p->cont,0,sizeof(p->cont));
    80000dde:	07000613          	li	a2,112
    80000de2:	4581                	li	a1,0
    80000de4:	07048513          	addi	a0,s1,112
    80000de8:	00001097          	auipc	ra,0x1
    80000dec:	162080e7          	jalr	354(ra) # 80001f4a <memset>
			p->cont.ra = (uint64) forkret;
    80000df0:	fffff797          	auipc	a5,0xfffff
    80000df4:	7ea78793          	addi	a5,a5,2026 # 800005da <forkret>
    80000df8:	f8bc                	sd	a5,112(s1)
			p->cont.sp = p->kstack + PGSIZE;
    80000dfa:	64bc                	ld	a5,72(s1)
    80000dfc:	6705                	lui	a4,0x1
    80000dfe:	97ba                	add	a5,a5,a4
    80000e00:	fcbc                	sd	a5,120(s1)
}
    80000e02:	8526                	mv	a0,s1
    80000e04:	70a2                	ld	ra,40(sp)
    80000e06:	7402                	ld	s0,32(sp)
    80000e08:	64e2                	ld	s1,24(sp)
    80000e0a:	6942                	ld	s2,16(sp)
    80000e0c:	69a2                	ld	s3,8(sp)
    80000e0e:	6145                	addi	sp,sp,48
    80000e10:	8082                	ret
				panic("alloc p->trapframe panic...\n");
    80000e12:	00006517          	auipc	a0,0x6
    80000e16:	36650513          	addi	a0,a0,870 # 80007178 <nums+0x148>
    80000e1a:	fffff097          	auipc	ra,0xfffff
    80000e1e:	66a080e7          	jalr	1642(ra) # 80000484 <panic>
				freeproc(p);
    80000e22:	8526                	mv	a0,s1
    80000e24:	fffff097          	auipc	ra,0xfffff
    80000e28:	714080e7          	jalr	1812(ra) # 80000538 <freeproc>
   				release(&p->slock);
    80000e2c:	854a                	mv	a0,s2
    80000e2e:	00001097          	auipc	ra,0x1
    80000e32:	ac4080e7          	jalr	-1340(ra) # 800018f2 <release>
				return 0;
    80000e36:	84ce                	mv	s1,s3
    80000e38:	b7e9                	j	80000e02 <allocproc+0x96>
				freeproc(p);
    80000e3a:	8526                	mv	a0,s1
    80000e3c:	fffff097          	auipc	ra,0xfffff
    80000e40:	6fc080e7          	jalr	1788(ra) # 80000538 <freeproc>
   				release(&p->slock);
    80000e44:	854a                	mv	a0,s2
    80000e46:	00001097          	auipc	ra,0x1
    80000e4a:	aac080e7          	jalr	-1364(ra) # 800018f2 <release>
				panic("alloproc proc_pagetable alloced panic");
    80000e4e:	00006517          	auipc	a0,0x6
    80000e52:	34a50513          	addi	a0,a0,842 # 80007198 <nums+0x168>
    80000e56:	fffff097          	auipc	ra,0xfffff
    80000e5a:	62e080e7          	jalr	1582(ra) # 80000484 <panic>
				return 0;
    80000e5e:	84ce                	mv	s1,s3
    80000e60:	b74d                	j	80000e02 <allocproc+0x96>

0000000080000e62 <userinit>:

void userinit(){
    80000e62:	1101                	addi	sp,sp,-32
    80000e64:	ec06                	sd	ra,24(sp)
    80000e66:	e822                	sd	s0,16(sp)
    80000e68:	e426                	sd	s1,8(sp)
    80000e6a:	1000                	addi	s0,sp,32
	struct proc *p = allocproc();
    80000e6c:	00000097          	auipc	ra,0x0
    80000e70:	f00080e7          	jalr	-256(ra) # 80000d6c <allocproc>
    80000e74:	84aa                	mv	s1,a0
	initp = p;
    80000e76:	00007797          	auipc	a5,0x7
    80000e7a:	18a7b923          	sd	a0,402(a5) # 80008008 <initp>

	uvminit(p->pagetable, initcode, sizeof(initcode));
    80000e7e:	03400613          	li	a2,52
    80000e82:	00007597          	auipc	a1,0x7
    80000e86:	d8e58593          	addi	a1,a1,-626 # 80007c10 <initcode>
    80000e8a:	7528                	ld	a0,104(a0)
    80000e8c:	00004097          	auipc	ra,0x4
    80000e90:	fe6080e7          	jalr	-26(ra) # 80004e72 <uvminit>
	p->sz = PGSIZE;
    80000e94:	6785                	lui	a5,0x1
    80000e96:	ecbc                	sd	a5,88(s1)

	p->trapframe->epc = 0;
    80000e98:	70b8                	ld	a4,96(s1)
    80000e9a:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
	p->trapframe->sp = PGSIZE;
    80000e9e:	70b8                	ld	a4,96(s1)
    80000ea0:	fb1c                	sd	a5,48(a4)
	
	safestrcpy(p->name,"initcode",sizeof(p->name));
    80000ea2:	4641                	li	a2,16
    80000ea4:	00006597          	auipc	a1,0x6
    80000ea8:	31c58593          	addi	a1,a1,796 # 800071c0 <nums+0x190>
    80000eac:	02048513          	addi	a0,s1,32
    80000eb0:	00003097          	auipc	ra,0x3
    80000eb4:	d44080e7          	jalr	-700(ra) # 80003bf4 <safestrcpy>
	p->pwd = rooti();
    80000eb8:	00001097          	auipc	ra,0x1
    80000ebc:	5d8080e7          	jalr	1496(ra) # 80002490 <rooti>
    80000ec0:	16a4b023          	sd	a0,352(s1)

	p->state = RUNNABLE;
    80000ec4:	478d                	li	a5,3
    80000ec6:	c09c                	sw	a5,0(s1)
	release(&p->slock);	
    80000ec8:	00848513          	addi	a0,s1,8
    80000ecc:	00001097          	auipc	ra,0x1
    80000ed0:	a26080e7          	jalr	-1498(ra) # 800018f2 <release>
}
    80000ed4:	60e2                	ld	ra,24(sp)
    80000ed6:	6442                	ld	s0,16(sp)
    80000ed8:	64a2                	ld	s1,8(sp)
    80000eda:	6105                	addi	sp,sp,32
    80000edc:	8082                	ret

0000000080000ede <reparent>:

void reparent(struct proc *p){
    80000ede:	7179                	addi	sp,sp,-48
    80000ee0:	f406                	sd	ra,40(sp)
    80000ee2:	f022                	sd	s0,32(sp)
    80000ee4:	ec26                	sd	s1,24(sp)
    80000ee6:	e84a                	sd	s2,16(sp)
    80000ee8:	e44e                	sd	s3,8(sp)
    80000eea:	e052                	sd	s4,0(sp)
    80000eec:	1800                	addi	s0,sp,48
    80000eee:	892a                	mv	s2,a0
	struct proc *pp;
	for(pp = procs; pp < &procs[NPROC];pp++){
    80000ef0:	0000f497          	auipc	s1,0xf
    80000ef4:	6d048493          	addi	s1,s1,1744 # 800105c0 <procs>
		if(pp->parent == p){
			pp->parent = initp;
    80000ef8:	00007a17          	auipc	s4,0x7
    80000efc:	110a0a13          	addi	s4,s4,272 # 80008008 <initp>
	for(pp = procs; pp < &procs[NPROC];pp++){
    80000f00:	00015997          	auipc	s3,0x15
    80000f04:	0c098993          	addi	s3,s3,192 # 80015fc0 <uart_tx_lock>
    80000f08:	a029                	j	80000f12 <reparent+0x34>
    80000f0a:	16848493          	addi	s1,s1,360
    80000f0e:	01348d63          	beq	s1,s3,80000f28 <reparent+0x4a>
		if(pp->parent == p){
    80000f12:	60bc                	ld	a5,64(s1)
    80000f14:	ff279be3          	bne	a5,s2,80000f0a <reparent+0x2c>
			pp->parent = initp;
    80000f18:	000a3503          	ld	a0,0(s4)
    80000f1c:	e0a8                	sd	a0,64(s1)
			wakeup(initp);
    80000f1e:	fffff097          	auipc	ra,0xfffff
    80000f22:	704080e7          	jalr	1796(ra) # 80000622 <wakeup>
    80000f26:	b7d5                	j	80000f0a <reparent+0x2c>
		}
	}
}
    80000f28:	70a2                	ld	ra,40(sp)
    80000f2a:	7402                	ld	s0,32(sp)
    80000f2c:	64e2                	ld	s1,24(sp)
    80000f2e:	6942                	ld	s2,16(sp)
    80000f30:	69a2                	ld	s3,8(sp)
    80000f32:	6a02                	ld	s4,0(sp)
    80000f34:	6145                	addi	sp,sp,48
    80000f36:	8082                	ret

0000000080000f38 <exit>:

void exit(int n){
    80000f38:	7179                	addi	sp,sp,-48
    80000f3a:	f406                	sd	ra,40(sp)
    80000f3c:	f022                	sd	s0,32(sp)
    80000f3e:	ec26                	sd	s1,24(sp)
    80000f40:	e84a                	sd	s2,16(sp)
    80000f42:	e44e                	sd	s3,8(sp)
    80000f44:	e052                	sd	s4,0(sp)
    80000f46:	1800                	addi	s0,sp,48
    80000f48:	8a2a                	mv	s4,a0
	struct proc *p = myproc();
    80000f4a:	fffff097          	auipc	ra,0xfffff
    80000f4e:	658080e7          	jalr	1624(ra) # 800005a2 <myproc>
    80000f52:	89aa                	mv	s3,a0
	if(p == initp){
    80000f54:	00007797          	auipc	a5,0x7
    80000f58:	0b47b783          	ld	a5,180(a5) # 80008008 <initp>
    80000f5c:	00a78763          	beq	a5,a0,80000f6a <exit+0x32>
		panic("init proc exit");
	}
	for(int fd = 0;fd < OPENFILE;fd++){
    80000f60:	0e098493          	addi	s1,s3,224
    80000f64:	16098913          	addi	s2,s3,352
    80000f68:	a01d                	j	80000f8e <exit+0x56>
		panic("init proc exit");
    80000f6a:	00006517          	auipc	a0,0x6
    80000f6e:	26650513          	addi	a0,a0,614 # 800071d0 <nums+0x1a0>
    80000f72:	fffff097          	auipc	ra,0xfffff
    80000f76:	512080e7          	jalr	1298(ra) # 80000484 <panic>
    80000f7a:	b7dd                	j	80000f60 <exit+0x28>
		if(p->openfs[fd]){
			fileclose(p->openfs[fd]);
    80000f7c:	00002097          	auipc	ra,0x2
    80000f80:	176080e7          	jalr	374(ra) # 800030f2 <fileclose>
			p->openfs[fd] = 0;
    80000f84:	0004b023          	sd	zero,0(s1)
	for(int fd = 0;fd < OPENFILE;fd++){
    80000f88:	04a1                	addi	s1,s1,8
    80000f8a:	01248563          	beq	s1,s2,80000f94 <exit+0x5c>
		if(p->openfs[fd]){
    80000f8e:	6088                	ld	a0,0(s1)
    80000f90:	f575                	bnez	a0,80000f7c <exit+0x44>
    80000f92:	bfdd                	j	80000f88 <exit+0x50>
		}
	}

	iput(p->pwd);
    80000f94:	1609b503          	ld	a0,352(s3)
    80000f98:	00002097          	auipc	ra,0x2
    80000f9c:	d6e080e7          	jalr	-658(ra) # 80002d06 <iput>
	p->pwd = 0;
    80000fa0:	1609b023          	sd	zero,352(s3)

	acquire(&wait_lock);
    80000fa4:	0000f497          	auipc	s1,0xf
    80000fa8:	60448493          	addi	s1,s1,1540 # 800105a8 <wait_lock>
    80000fac:	8526                	mv	a0,s1
    80000fae:	00001097          	auipc	ra,0x1
    80000fb2:	882080e7          	jalr	-1918(ra) # 80001830 <acquire>

	reparent(p);
    80000fb6:	854e                	mv	a0,s3
    80000fb8:	00000097          	auipc	ra,0x0
    80000fbc:	f26080e7          	jalr	-218(ra) # 80000ede <reparent>
	wakeup(p->parent);
    80000fc0:	0409b503          	ld	a0,64(s3)
    80000fc4:	fffff097          	auipc	ra,0xfffff
    80000fc8:	65e080e7          	jalr	1630(ra) # 80000622 <wakeup>

	acquire(&p->slock);
    80000fcc:	00898513          	addi	a0,s3,8
    80000fd0:	00001097          	auipc	ra,0x1
    80000fd4:	860080e7          	jalr	-1952(ra) # 80001830 <acquire>
	p->xstate = n;
    80000fd8:	0349ac23          	sw	s4,56(s3)
	p->state = ZOMBIE;
    80000fdc:	4795                	li	a5,5
    80000fde:	00f9a023          	sw	a5,0(s3)
	
	release(&wait_lock);
    80000fe2:	8526                	mv	a0,s1
    80000fe4:	00001097          	auipc	ra,0x1
    80000fe8:	90e080e7          	jalr	-1778(ra) # 800018f2 <release>
	sched();
    80000fec:	00000097          	auipc	ra,0x0
    80000ff0:	98a080e7          	jalr	-1654(ra) # 80000976 <sched>
	panic("proc exit");
    80000ff4:	00006517          	auipc	a0,0x6
    80000ff8:	1ec50513          	addi	a0,a0,492 # 800071e0 <nums+0x1b0>
    80000ffc:	fffff097          	auipc	ra,0xfffff
    80001000:	488080e7          	jalr	1160(ra) # 80000484 <panic>
}
    80001004:	70a2                	ld	ra,40(sp)
    80001006:	7402                	ld	s0,32(sp)
    80001008:	64e2                	ld	s1,24(sp)
    8000100a:	6942                	ld	s2,16(sp)
    8000100c:	69a2                	ld	s3,8(sp)
    8000100e:	6a02                	ld	s4,0(sp)
    80001010:	6145                	addi	sp,sp,48
    80001012:	8082                	ret

0000000080001014 <fork>:

int fork(){
    80001014:	7139                	addi	sp,sp,-64
    80001016:	fc06                	sd	ra,56(sp)
    80001018:	f822                	sd	s0,48(sp)
    8000101a:	f426                	sd	s1,40(sp)
    8000101c:	f04a                	sd	s2,32(sp)
    8000101e:	ec4e                	sd	s3,24(sp)
    80001020:	e852                	sd	s4,16(sp)
    80001022:	e456                	sd	s5,8(sp)
    80001024:	0080                	addi	s0,sp,64
	struct proc *now = myproc();
    80001026:	fffff097          	auipc	ra,0xfffff
    8000102a:	57c080e7          	jalr	1404(ra) # 800005a2 <myproc>
    8000102e:	892a                	mv	s2,a0
	struct proc *p = allocproc();
    80001030:	00000097          	auipc	ra,0x0
    80001034:	d3c080e7          	jalr	-708(ra) # 80000d6c <allocproc>
	if(p == 0){
    80001038:	10050f63          	beqz	a0,80001156 <fork+0x142>
    8000103c:	89aa                	mv	s3,a0
		return -1;
	}
	if(uvmcopy(now->pagetable,p->pagetable,now->sz) < 0){
    8000103e:	05893603          	ld	a2,88(s2)
    80001042:	752c                	ld	a1,104(a0)
    80001044:	06893503          	ld	a0,104(s2)
    80001048:	00004097          	auipc	ra,0x4
    8000104c:	c02080e7          	jalr	-1022(ra) # 80004c4a <uvmcopy>
    80001050:	04054663          	bltz	a0,8000109c <fork+0x88>
		freeproc(p);
		release(&p->slock);
		return -1;
	}
	p->sz = now->sz;
    80001054:	05893783          	ld	a5,88(s2)
    80001058:	04f9bc23          	sd	a5,88(s3)
	*(p->trapframe) = *(now->trapframe);
    8000105c:	06093683          	ld	a3,96(s2)
    80001060:	87b6                	mv	a5,a3
    80001062:	0609b703          	ld	a4,96(s3)
    80001066:	12068693          	addi	a3,a3,288
    8000106a:	0007b803          	ld	a6,0(a5)
    8000106e:	6788                	ld	a0,8(a5)
    80001070:	6b8c                	ld	a1,16(a5)
    80001072:	6f90                	ld	a2,24(a5)
    80001074:	01073023          	sd	a6,0(a4)
    80001078:	e708                	sd	a0,8(a4)
    8000107a:	eb0c                	sd	a1,16(a4)
    8000107c:	ef10                	sd	a2,24(a4)
    8000107e:	02078793          	addi	a5,a5,32
    80001082:	02070713          	addi	a4,a4,32
    80001086:	fed792e3          	bne	a5,a3,8000106a <fork+0x56>

	p->trapframe->a0 = 0;
    8000108a:	0609b783          	ld	a5,96(s3)
    8000108e:	0607b823          	sd	zero,112(a5)
    80001092:	0e000493          	li	s1,224
	for(int i = 0; i < OPENFILE; i++){
    80001096:	16000a13          	li	s4,352
    8000109a:	a805                	j	800010ca <fork+0xb6>
		freeproc(p);
    8000109c:	854e                	mv	a0,s3
    8000109e:	fffff097          	auipc	ra,0xfffff
    800010a2:	49a080e7          	jalr	1178(ra) # 80000538 <freeproc>
		release(&p->slock);
    800010a6:	00898513          	addi	a0,s3,8
    800010aa:	00001097          	auipc	ra,0x1
    800010ae:	848080e7          	jalr	-1976(ra) # 800018f2 <release>
		return -1;
    800010b2:	5afd                	li	s5,-1
    800010b4:	a079                	j	80001142 <fork+0x12e>
		if(now->openfs[i]){
			p->openfs[i] = filedup(now->openfs[i]);
    800010b6:	00002097          	auipc	ra,0x2
    800010ba:	19e080e7          	jalr	414(ra) # 80003254 <filedup>
    800010be:	009987b3          	add	a5,s3,s1
    800010c2:	e388                	sd	a0,0(a5)
	for(int i = 0; i < OPENFILE; i++){
    800010c4:	04a1                	addi	s1,s1,8
    800010c6:	01448763          	beq	s1,s4,800010d4 <fork+0xc0>
		if(now->openfs[i]){
    800010ca:	009907b3          	add	a5,s2,s1
    800010ce:	6388                	ld	a0,0(a5)
    800010d0:	f17d                	bnez	a0,800010b6 <fork+0xa2>
    800010d2:	bfcd                	j	800010c4 <fork+0xb0>
		}
	}
	p->pwd = idup(now->pwd);
    800010d4:	16093503          	ld	a0,352(s2)
    800010d8:	00001097          	auipc	ra,0x1
    800010dc:	0c0080e7          	jalr	192(ra) # 80002198 <idup>
    800010e0:	16a9b023          	sd	a0,352(s3)

	safestrcpy(p->name,now->name,sizeof(now->name));
    800010e4:	4641                	li	a2,16
    800010e6:	02090593          	addi	a1,s2,32
    800010ea:	02098513          	addi	a0,s3,32
    800010ee:	00003097          	auipc	ra,0x3
    800010f2:	b06080e7          	jalr	-1274(ra) # 80003bf4 <safestrcpy>
	int pid = p->pid;
    800010f6:	0309aa83          	lw	s5,48(s3)

	release(&p->slock);
    800010fa:	00898493          	addi	s1,s3,8
    800010fe:	8526                	mv	a0,s1
    80001100:	00000097          	auipc	ra,0x0
    80001104:	7f2080e7          	jalr	2034(ra) # 800018f2 <release>

	acquire(&wait_lock);
    80001108:	0000fa17          	auipc	s4,0xf
    8000110c:	4a0a0a13          	addi	s4,s4,1184 # 800105a8 <wait_lock>
    80001110:	8552                	mv	a0,s4
    80001112:	00000097          	auipc	ra,0x0
    80001116:	71e080e7          	jalr	1822(ra) # 80001830 <acquire>
	p->parent = now;
    8000111a:	0529b023          	sd	s2,64(s3)
	release(&wait_lock);
    8000111e:	8552                	mv	a0,s4
    80001120:	00000097          	auipc	ra,0x0
    80001124:	7d2080e7          	jalr	2002(ra) # 800018f2 <release>

	acquire(&p->slock);
    80001128:	8526                	mv	a0,s1
    8000112a:	00000097          	auipc	ra,0x0
    8000112e:	706080e7          	jalr	1798(ra) # 80001830 <acquire>
	p->state = RUNNABLE;
    80001132:	478d                	li	a5,3
    80001134:	00f9a023          	sw	a5,0(s3)
	release(&p->slock);
    80001138:	8526                	mv	a0,s1
    8000113a:	00000097          	auipc	ra,0x0
    8000113e:	7b8080e7          	jalr	1976(ra) # 800018f2 <release>
	return pid;
}
    80001142:	8556                	mv	a0,s5
    80001144:	70e2                	ld	ra,56(sp)
    80001146:	7442                	ld	s0,48(sp)
    80001148:	74a2                	ld	s1,40(sp)
    8000114a:	7902                	ld	s2,32(sp)
    8000114c:	69e2                	ld	s3,24(sp)
    8000114e:	6a42                	ld	s4,16(sp)
    80001150:	6aa2                	ld	s5,8(sp)
    80001152:	6121                	addi	sp,sp,64
    80001154:	8082                	ret
		return -1;
    80001156:	5afd                	li	s5,-1
    80001158:	b7ed                	j	80001142 <fork+0x12e>

000000008000115a <uartinit>:
        uart_putc(*s++); 
    }
}


void uartinit(){
    8000115a:	1141                	addi	sp,sp,-16
    8000115c:	e406                	sd	ra,8(sp)
    8000115e:	e022                	sd	s0,0(sp)
    80001160:	0800                	addi	s0,sp,16
  WriteReg(IER, 0x00);
    80001162:	100007b7          	lui	a5,0x10000
    80001166:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  WriteReg(LCR, LCR_BAUD_LATCH);
    8000116a:	f8000713          	li	a4,-128
    8000116e:	00e781a3          	sb	a4,3(a5)

  WriteReg(0, 0x03);
    80001172:	470d                	li	a4,3
    80001174:	00e78023          	sb	a4,0(a5)

  WriteReg(1, 0x00);
    80001178:	000780a3          	sb	zero,1(a5)

  WriteReg(LCR, LCR_EIGHT_BITS);
    8000117c:	00e781a3          	sb	a4,3(a5)

  // 重置和启用FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80001180:	469d                	li	a3,7
    80001182:	00d78123          	sb	a3,2(a5)

  // 启用发送和接收中断
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80001186:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    8000118a:	00006597          	auipc	a1,0x6
    8000118e:	0be58593          	addi	a1,a1,190 # 80007248 <states.1524+0x30>
    80001192:	00015517          	auipc	a0,0x15
    80001196:	e2e50513          	addi	a0,a0,-466 # 80015fc0 <uart_tx_lock>
    8000119a:	00000097          	auipc	ra,0x0
    8000119e:	60a080e7          	jalr	1546(ra) # 800017a4 <initlock>
}
    800011a2:	60a2                	ld	ra,8(sp)
    800011a4:	6402                	ld	s0,0(sp)
    800011a6:	0141                	addi	sp,sp,16
    800011a8:	8082                	ret

00000000800011aa <uartgetc>:

int uartgetc() {
    800011aa:	1141                	addi	sp,sp,-16
    800011ac:	e422                	sd	s0,8(sp)
    800011ae:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800011b0:	100007b7          	lui	a5,0x10000
    800011b4:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800011b8:	8b85                	andi	a5,a5,1
    800011ba:	cb91                	beqz	a5,800011ce <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    800011bc:	100007b7          	lui	a5,0x10000
    800011c0:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    800011c4:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    800011c8:	6422                	ld	s0,8(sp)
    800011ca:	0141                	addi	sp,sp,16
    800011cc:	8082                	ret
    return -1;
    800011ce:	557d                	li	a0,-1
    800011d0:	bfe5                	j	800011c8 <uartgetc+0x1e>

00000000800011d2 <uartstart>:
} plic_lock;


void uartstart(){
  while (1) {
    if(uart_tx_r == uart_tx_w){
    800011d2:	00007717          	auipc	a4,0x7
    800011d6:	e3e73703          	ld	a4,-450(a4) # 80008010 <uart_tx_r>
    800011da:	00007797          	auipc	a5,0x7
    800011de:	e3e7b783          	ld	a5,-450(a5) # 80008018 <uart_tx_w>
    800011e2:	06f70c63          	beq	a4,a5,8000125a <uartstart+0x88>
void uartstart(){
    800011e6:	7139                	addi	sp,sp,-64
    800011e8:	fc06                	sd	ra,56(sp)
    800011ea:	f822                	sd	s0,48(sp)
    800011ec:	f426                	sd	s1,40(sp)
    800011ee:	f04a                	sd	s2,32(sp)
    800011f0:	ec4e                	sd	s3,24(sp)
    800011f2:	e852                	sd	s4,16(sp)
    800011f4:	e456                	sd	s5,8(sp)
    800011f6:	0080                	addi	s0,sp,64
      return;
    }

    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800011f8:	10000937          	lui	s2,0x10000
        // UART 发送保持寄存器已满，当它准备好接收一个新字节时它会中断
        return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800011fc:	00015a17          	auipc	s4,0x15
    80001200:	dc4a0a13          	addi	s4,s4,-572 # 80015fc0 <uart_tx_lock>
    uart_tx_r+=1;
    80001204:	00007497          	auipc	s1,0x7
    80001208:	e0c48493          	addi	s1,s1,-500 # 80008010 <uart_tx_r>
    if(uart_tx_r == uart_tx_w){
    8000120c:	00007997          	auipc	s3,0x7
    80001210:	e0c98993          	addi	s3,s3,-500 # 80008018 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80001214:	00594783          	lbu	a5,5(s2) # 10000005 <_entry-0x6ffffffb>
    80001218:	0ff7f793          	andi	a5,a5,255
    8000121c:	0207f793          	andi	a5,a5,32
    80001220:	c785                	beqz	a5,80001248 <uartstart+0x76>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80001222:	01f77793          	andi	a5,a4,31
    80001226:	97d2                	add	a5,a5,s4
    80001228:	0187ca83          	lbu	s5,24(a5)
    uart_tx_r+=1;
    8000122c:	0705                	addi	a4,a4,1
    8000122e:	e098                	sd	a4,0(s1)
    wakeup(&uart_tx_r);
    80001230:	8526                	mv	a0,s1
    80001232:	fffff097          	auipc	ra,0xfffff
    80001236:	3f0080e7          	jalr	1008(ra) # 80000622 <wakeup>
    WriteReg(THR, c);
    8000123a:	01590023          	sb	s5,0(s2)
    if(uart_tx_r == uart_tx_w){
    8000123e:	6098                	ld	a4,0(s1)
    80001240:	0009b783          	ld	a5,0(s3)
    80001244:	fcf718e3          	bne	a4,a5,80001214 <uartstart+0x42>
  }
}
    80001248:	70e2                	ld	ra,56(sp)
    8000124a:	7442                	ld	s0,48(sp)
    8000124c:	74a2                	ld	s1,40(sp)
    8000124e:	7902                	ld	s2,32(sp)
    80001250:	69e2                	ld	s3,24(sp)
    80001252:	6a42                	ld	s4,16(sp)
    80001254:	6aa2                	ld	s5,8(sp)
    80001256:	6121                	addi	sp,sp,64
    80001258:	8082                	ret
    8000125a:	8082                	ret

000000008000125c <uartputc>:
void uartputc(char c){
    8000125c:	7179                	addi	sp,sp,-48
    8000125e:	f406                	sd	ra,40(sp)
    80001260:	f022                	sd	s0,32(sp)
    80001262:	ec26                	sd	s1,24(sp)
    80001264:	e84a                	sd	s2,16(sp)
    80001266:	e44e                	sd	s3,8(sp)
    80001268:	e052                	sd	s4,0(sp)
    8000126a:	1800                	addi	s0,sp,48
    8000126c:	89aa                	mv	s3,a0
  acquire(&uart_tx_lock);
    8000126e:	00015517          	auipc	a0,0x15
    80001272:	d5250513          	addi	a0,a0,-686 # 80015fc0 <uart_tx_lock>
    80001276:	00000097          	auipc	ra,0x0
    8000127a:	5ba080e7          	jalr	1466(ra) # 80001830 <acquire>
  if(panicked){
    8000127e:	00007797          	auipc	a5,0x7
    80001282:	d867a783          	lw	a5,-634(a5) # 80008004 <panicked>
    80001286:	c391                	beqz	a5,8000128a <uartputc+0x2e>
      for(;;){}
    80001288:	a001                	j	80001288 <uartputc+0x2c>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000128a:	00007797          	auipc	a5,0x7
    8000128e:	d8e7b783          	ld	a5,-626(a5) # 80008018 <uart_tx_w>
    80001292:	00007717          	auipc	a4,0x7
    80001296:	d7e73703          	ld	a4,-642(a4) # 80008010 <uart_tx_r>
    8000129a:	02070713          	addi	a4,a4,32
    8000129e:	02f71b63          	bne	a4,a5,800012d4 <uartputc+0x78>
        sleep(&uart_tx_r,&uart_tx_lock);
    800012a2:	00015a17          	auipc	s4,0x15
    800012a6:	d1ea0a13          	addi	s4,s4,-738 # 80015fc0 <uart_tx_lock>
    800012aa:	00007497          	auipc	s1,0x7
    800012ae:	d6648493          	addi	s1,s1,-666 # 80008010 <uart_tx_r>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800012b2:	00007917          	auipc	s2,0x7
    800012b6:	d6690913          	addi	s2,s2,-666 # 80008018 <uart_tx_w>
        sleep(&uart_tx_r,&uart_tx_lock);
    800012ba:	85d2                	mv	a1,s4
    800012bc:	8526                	mv	a0,s1
    800012be:	fffff097          	auipc	ra,0xfffff
    800012c2:	768080e7          	jalr	1896(ra) # 80000a26 <sleep>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800012c6:	00093783          	ld	a5,0(s2)
    800012ca:	6098                	ld	a4,0(s1)
    800012cc:	02070713          	addi	a4,a4,32
    800012d0:	fef705e3          	beq	a4,a5,800012ba <uartputc+0x5e>
      uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800012d4:	00015497          	auipc	s1,0x15
    800012d8:	cec48493          	addi	s1,s1,-788 # 80015fc0 <uart_tx_lock>
    800012dc:	01f7f713          	andi	a4,a5,31
    800012e0:	9726                	add	a4,a4,s1
    800012e2:	01370c23          	sb	s3,24(a4)
      uart_tx_w += 1;
    800012e6:	0785                	addi	a5,a5,1
    800012e8:	00007717          	auipc	a4,0x7
    800012ec:	d2f73823          	sd	a5,-720(a4) # 80008018 <uart_tx_w>
      uartstart();
    800012f0:	00000097          	auipc	ra,0x0
    800012f4:	ee2080e7          	jalr	-286(ra) # 800011d2 <uartstart>
      release(&uart_tx_lock);
    800012f8:	8526                	mv	a0,s1
    800012fa:	00000097          	auipc	ra,0x0
    800012fe:	5f8080e7          	jalr	1528(ra) # 800018f2 <release>
}
    80001302:	70a2                	ld	ra,40(sp)
    80001304:	7402                	ld	s0,32(sp)
    80001306:	64e2                	ld	s1,24(sp)
    80001308:	6942                	ld	s2,16(sp)
    8000130a:	69a2                	ld	s3,8(sp)
    8000130c:	6a02                	ld	s4,0(sp)
    8000130e:	6145                	addi	sp,sp,48
    80001310:	8082                	ret

0000000080001312 <uartputc_sync>:

void uartputc_sync(int c){
    80001312:	1101                	addi	sp,sp,-32
    80001314:	ec06                	sd	ra,24(sp)
    80001316:	e822                	sd	s0,16(sp)
    80001318:	e426                	sd	s1,8(sp)
    8000131a:	1000                	addi	s0,sp,32
    8000131c:	84aa                	mv	s1,a0
  push_off();
    8000131e:	00000097          	auipc	ra,0x0
    80001322:	4c6080e7          	jalr	1222(ra) # 800017e4 <push_off>
  if(panicked){
    80001326:	00007797          	auipc	a5,0x7
    8000132a:	cde7a783          	lw	a5,-802(a5) # 80008004 <panicked>
    for (;;){
    }
  }
  while ((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000132e:	10000737          	lui	a4,0x10000
  if(panicked){
    80001332:	c391                	beqz	a5,80001336 <uartputc_sync+0x24>
    for (;;){
    80001334:	a001                	j	80001334 <uartputc_sync+0x22>
  while ((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80001336:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    8000133a:	0ff7f793          	andi	a5,a5,255
    8000133e:	0207f793          	andi	a5,a5,32
    80001342:	dbf5                	beqz	a5,80001336 <uartputc_sync+0x24>
  }
  WriteReg(THR,c);  
    80001344:	0ff4f793          	andi	a5,s1,255
    80001348:	10000737          	lui	a4,0x10000
    8000134c:	00f70023          	sb	a5,0(a4) # 10000000 <_entry-0x70000000>
  pop_off();
    80001350:	00000097          	auipc	ra,0x0
    80001354:	536080e7          	jalr	1334(ra) # 80001886 <pop_off>
}
    80001358:	60e2                	ld	ra,24(sp)
    8000135a:	6442                	ld	s0,16(sp)
    8000135c:	64a2                	ld	s1,8(sp)
    8000135e:	6105                	addi	sp,sp,32
    80001360:	8082                	ret

0000000080001362 <uartinterrupt>:

void uartinterrupt(){
    80001362:	1101                	addi	sp,sp,-32
    80001364:	ec06                	sd	ra,24(sp)
    80001366:	e822                	sd	s0,16(sp)
    80001368:	e426                	sd	s1,8(sp)
    8000136a:	1000                	addi	s0,sp,32
    for(;;){
      int c = uartgetc();
      if(c == -1){
    8000136c:	54fd                	li	s1,-1
      int c = uartgetc();
    8000136e:	00000097          	auipc	ra,0x0
    80001372:	e3c080e7          	jalr	-452(ra) # 800011aa <uartgetc>
      if(c == -1){
    80001376:	00950763          	beq	a0,s1,80001384 <uartinterrupt+0x22>
          break;
      }
      consoleintr(c);
    8000137a:	00002097          	auipc	ra,0x2
    8000137e:	15c080e7          	jalr	348(ra) # 800034d6 <consoleintr>
    for(;;){
    80001382:	b7f5                	j	8000136e <uartinterrupt+0xc>
    }
    acquire(&uart_tx_lock);
    80001384:	00015497          	auipc	s1,0x15
    80001388:	c3c48493          	addi	s1,s1,-964 # 80015fc0 <uart_tx_lock>
    8000138c:	8526                	mv	a0,s1
    8000138e:	00000097          	auipc	ra,0x0
    80001392:	4a2080e7          	jalr	1186(ra) # 80001830 <acquire>
    uartstart();
    80001396:	00000097          	auipc	ra,0x0
    8000139a:	e3c080e7          	jalr	-452(ra) # 800011d2 <uartstart>
    release(&uart_tx_lock);
    8000139e:	8526                	mv	a0,s1
    800013a0:	00000097          	auipc	ra,0x0
    800013a4:	552080e7          	jalr	1362(ra) # 800018f2 <release>
}
    800013a8:	60e2                	ld	ra,24(sp)
    800013aa:	6442                	ld	s0,16(sp)
    800013ac:	64a2                	ld	s1,8(sp)
    800013ae:	6105                	addi	sp,sp,32
    800013b0:	8082                	ret

00000000800013b2 <consputc>:

void consputc(int c){
    800013b2:	1141                	addi	sp,sp,-16
    800013b4:	e406                	sd	ra,8(sp)
    800013b6:	e022                	sd	s0,0(sp)
    800013b8:	0800                	addi	s0,sp,16
    if(c == BACKSPACE){
    800013ba:	10000793          	li	a5,256
    800013be:	00f50a63          	beq	a0,a5,800013d2 <consputc+0x20>
        uartputc_sync('\b');
        uartputc_sync(' ');
        uartputc_sync('\b');
    }else{
        uartputc_sync(c);
    800013c2:	00000097          	auipc	ra,0x0
    800013c6:	f50080e7          	jalr	-176(ra) # 80001312 <uartputc_sync>
    }
}
    800013ca:	60a2                	ld	ra,8(sp)
    800013cc:	6402                	ld	s0,0(sp)
    800013ce:	0141                	addi	sp,sp,16
    800013d0:	8082                	ret
        uartputc_sync('\b');
    800013d2:	4521                	li	a0,8
    800013d4:	00000097          	auipc	ra,0x0
    800013d8:	f3e080e7          	jalr	-194(ra) # 80001312 <uartputc_sync>
        uartputc_sync(' ');
    800013dc:	02000513          	li	a0,32
    800013e0:	00000097          	auipc	ra,0x0
    800013e4:	f32080e7          	jalr	-206(ra) # 80001312 <uartputc_sync>
        uartputc_sync('\b');
    800013e8:	4521                	li	a0,8
    800013ea:	00000097          	auipc	ra,0x0
    800013ee:	f28080e7          	jalr	-216(ra) # 80001312 <uartputc_sync>
    800013f2:	bfe1                	j	800013ca <consputc+0x18>

00000000800013f4 <uart_putc>:
void uart_putc(char c){
    800013f4:	1141                	addi	sp,sp,-16
    800013f6:	e406                	sd	ra,8(sp)
    800013f8:	e022                	sd	s0,0(sp)
    800013fa:	0800                	addi	s0,sp,16
  consputc(c);
    800013fc:	00000097          	auipc	ra,0x0
    80001400:	fb6080e7          	jalr	-74(ra) # 800013b2 <consputc>
}
    80001404:	60a2                	ld	ra,8(sp)
    80001406:	6402                	ld	s0,0(sp)
    80001408:	0141                	addi	sp,sp,16
    8000140a:	8082                	ret

000000008000140c <uart_putstr>:
  if(panicked){
    8000140c:	00007797          	auipc	a5,0x7
    80001410:	bf87a783          	lw	a5,-1032(a5) # 80008004 <panicked>
    80001414:	e79d                	bnez	a5,80001442 <uart_putstr+0x36>
void uart_putstr(char* s){
    80001416:	1101                	addi	sp,sp,-32
    80001418:	ec06                	sd	ra,24(sp)
    8000141a:	e822                	sd	s0,16(sp)
    8000141c:	e426                	sd	s1,8(sp)
    8000141e:	1000                	addi	s0,sp,32
    80001420:	84aa                	mv	s1,a0
    while (*s)
    80001422:	00054503          	lbu	a0,0(a0)
    80001426:	c909                	beqz	a0,80001438 <uart_putstr+0x2c>
        uart_putc(*s++); 
    80001428:	0485                	addi	s1,s1,1
  consputc(c);
    8000142a:	00000097          	auipc	ra,0x0
    8000142e:	f88080e7          	jalr	-120(ra) # 800013b2 <consputc>
    while (*s)
    80001432:	0004c503          	lbu	a0,0(s1)
    80001436:	f96d                	bnez	a0,80001428 <uart_putstr+0x1c>
}
    80001438:	60e2                	ld	ra,24(sp)
    8000143a:	6442                	ld	s0,16(sp)
    8000143c:	64a2                	ld	s1,8(sp)
    8000143e:	6105                	addi	sp,sp,32
    80001440:	8082                	ret
    for(;;){
    80001442:	a001                	j	80001442 <uart_putstr+0x36>

0000000080001444 <usertrapret>:

extern char trampoline[], uservec[], userret[];

void usertrap();

void usertrapret(){
    80001444:	1141                	addi	sp,sp,-16
    80001446:	e406                	sd	ra,8(sp)
    80001448:	e022                	sd	s0,0(sp)
    8000144a:	0800                	addi	s0,sp,16
    struct proc *p = myproc();
    8000144c:	fffff097          	auipc	ra,0xfffff
    80001450:	156080e7          	jalr	342(ra) # 800005a2 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001454:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001458:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000145a:	10079073          	csrw	sstatus,a5

    intr_off();

    w_stvec(TRAMPOLINE + (uservec - trampoline));
    8000145e:	00005617          	auipc	a2,0x5
    80001462:	ba260613          	addi	a2,a2,-1118 # 80006000 <_trampoline>
    80001466:	00005697          	auipc	a3,0x5
    8000146a:	b9a68693          	addi	a3,a3,-1126 # 80006000 <_trampoline>
    8000146e:	8e91                	sub	a3,a3,a2
    80001470:	040007b7          	lui	a5,0x4000
    80001474:	17fd                	addi	a5,a5,-1
    80001476:	07b2                	slli	a5,a5,0xc
    80001478:	96be                	add	a3,a3,a5
    asm volatile("csrw stvec, %0" : : "r" (x));
    8000147a:	10569073          	csrw	stvec,a3

    p->trapframe->kernel_satp = r_satp();
    8000147e:	7138                	ld	a4,96(a0)
    asm volatile("csrr %0,satp":"=r"(x));
    80001480:	180026f3          	csrr	a3,satp
    80001484:	e314                	sd	a3,0(a4)
    p->trapframe->kernel_sp = p->kstack + PGSIZE;
    80001486:	7138                	ld	a4,96(a0)
    80001488:	6534                	ld	a3,72(a0)
    8000148a:	6585                	lui	a1,0x1
    8000148c:	96ae                	add	a3,a3,a1
    8000148e:	e714                	sd	a3,8(a4)
    p->trapframe->kernel_trap = (uint64)usertrap;
    80001490:	7138                	ld	a4,96(a0)
    80001492:	00000697          	auipc	a3,0x0
    80001496:	13868693          	addi	a3,a3,312 # 800015ca <usertrap>
    8000149a:	eb14                	sd	a3,16(a4)
    p->trapframe->kernel_hartid = r_tp();
    8000149c:	7138                	ld	a4,96(a0)
    asm volatile("mv %0,tp":"=r"(x));
    8000149e:	8692                	mv	a3,tp
    800014a0:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800014a2:	100026f3          	csrr	a3,sstatus

    unsigned long x = r_sstatus();
    x &= ~SSTATUS_SPP;
    800014a6:	eff6f693          	andi	a3,a3,-257
    x |= SSTATUS_SPIE;
    800014aa:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800014ae:	10069073          	csrw	sstatus,a3
    w_sstatus(x);

    w_sepc(p->trapframe->epc);
    800014b2:	7138                	ld	a4,96(a0)
    asm volatile("csrw sepc,%0"::"r"(x));
    800014b4:	6f18                	ld	a4,24(a4)
    800014b6:	14171073          	csrw	sepc,a4
    uint64 satp = MAKE_SATP(p->pagetable);
    800014ba:	752c                	ld	a1,104(a0)
    800014bc:	81b1                	srli	a1,a1,0xc
    
    uint64 fn = TRAMPOLINE + (userret - trampoline);
    800014be:	00005717          	auipc	a4,0x5
    800014c2:	bd270713          	addi	a4,a4,-1070 # 80006090 <userret>
    800014c6:	8f11                	sub	a4,a4,a2
    800014c8:	97ba                	add	a5,a5,a4
    ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    800014ca:	577d                	li	a4,-1
    800014cc:	177e                	slli	a4,a4,0x3f
    800014ce:	8dd9                	or	a1,a1,a4
    800014d0:	02000537          	lui	a0,0x2000
    800014d4:	157d                	addi	a0,a0,-1
    800014d6:	0536                	slli	a0,a0,0xd
    800014d8:	9782                	jalr	a5
}
    800014da:	60a2                	ld	ra,8(sp)
    800014dc:	6402                	ld	s0,0(sp)
    800014de:	0141                	addi	sp,sp,16
    800014e0:	8082                	ret

00000000800014e2 <clockintr>:

void clockintr(){
    800014e2:	1101                	addi	sp,sp,-32
    800014e4:	ec06                	sd	ra,24(sp)
    800014e6:	e822                	sd	s0,16(sp)
    800014e8:	e426                	sd	s1,8(sp)
    800014ea:	1000                	addi	s0,sp,32
    acquire(&slock);
    800014ec:	00015497          	auipc	s1,0x15
    800014f0:	b2c48493          	addi	s1,s1,-1236 # 80016018 <slock>
    800014f4:	8526                	mv	a0,s1
    800014f6:	00000097          	auipc	ra,0x0
    800014fa:	33a080e7          	jalr	826(ra) # 80001830 <acquire>
    ticks++;
    800014fe:	00007517          	auipc	a0,0x7
    80001502:	b2250513          	addi	a0,a0,-1246 # 80008020 <ticks>
    80001506:	411c                	lw	a5,0(a0)
    80001508:	2785                	addiw	a5,a5,1
    8000150a:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    8000150c:	fffff097          	auipc	ra,0xfffff
    80001510:	116080e7          	jalr	278(ra) # 80000622 <wakeup>
    release(&slock);
    80001514:	8526                	mv	a0,s1
    80001516:	00000097          	auipc	ra,0x0
    8000151a:	3dc080e7          	jalr	988(ra) # 800018f2 <release>
}
    8000151e:	60e2                	ld	ra,24(sp)
    80001520:	6442                	ld	s0,16(sp)
    80001522:	64a2                	ld	s1,8(sp)
    80001524:	6105                	addi	sp,sp,32
    80001526:	8082                	ret

0000000080001528 <devintr>:


int devintr(){
    80001528:	1101                	addi	sp,sp,-32
    8000152a:	ec06                	sd	ra,24(sp)
    8000152c:	e822                	sd	s0,16(sp)
    8000152e:	e426                	sd	s1,8(sp)
    80001530:	1000                	addi	s0,sp,32
    asm volatile("csrr %0,scause":"=r"(x));
    80001532:	14202773          	csrr	a4,scause
     uint64 scause = r_scause();
     if((scause & 0x8000000000000000) && (scause & 0xff) == 9){
    80001536:	00074d63          	bltz	a4,80001550 <devintr+0x28>
        }
        if(irq){
            complate_irq(irq);
        }
        return 1;
     }else if(scause == 0x8000000000000001L){
    8000153a:	57fd                	li	a5,-1
    8000153c:	17fe                	slli	a5,a5,0x3f
    8000153e:	0785                	addi	a5,a5,1
            clockintr();
        } 
        w_sip(r_sip() & ~2);
        return 2;
     }else{
        return 0;
    80001540:	4501                	li	a0,0
     }else if(scause == 0x8000000000000001L){
    80001542:	06f70363          	beq	a4,a5,800015a8 <devintr+0x80>
    }
}
    80001546:	60e2                	ld	ra,24(sp)
    80001548:	6442                	ld	s0,16(sp)
    8000154a:	64a2                	ld	s1,8(sp)
    8000154c:	6105                	addi	sp,sp,32
    8000154e:	8082                	ret
     if((scause & 0x8000000000000000) && (scause & 0xff) == 9){
    80001550:	0ff77793          	andi	a5,a4,255
    80001554:	46a5                	li	a3,9
    80001556:	fed792e3          	bne	a5,a3,8000153a <devintr+0x12>
        int irq = plic_claim();
    8000155a:	00000097          	auipc	ra,0x0
    8000155e:	42c080e7          	jalr	1068(ra) # 80001986 <plic_claim>
    80001562:	84aa                	mv	s1,a0
        if(irq == UART0_IRQ){
    80001564:	47a9                	li	a5,10
    80001566:	02f50163          	beq	a0,a5,80001588 <devintr+0x60>
        }else if(irq == VIRTIO0_IRQ){
    8000156a:	4785                	li	a5,1
    8000156c:	02f50363          	beq	a0,a5,80001592 <devintr+0x6a>
            printf("unknow irq:%d\n",irq);
    80001570:	85aa                	mv	a1,a0
    80001572:	00006517          	auipc	a0,0x6
    80001576:	cde50513          	addi	a0,a0,-802 # 80007250 <states.1524+0x38>
    8000157a:	fffff097          	auipc	ra,0xfffff
    8000157e:	d40080e7          	jalr	-704(ra) # 800002ba <printf>
        return 1;
    80001582:	4505                	li	a0,1
        if(irq){
    80001584:	d0e9                	beqz	s1,80001546 <devintr+0x1e>
    80001586:	a811                	j	8000159a <devintr+0x72>
            uartinterrupt();
    80001588:	00000097          	auipc	ra,0x0
    8000158c:	dda080e7          	jalr	-550(ra) # 80001362 <uartinterrupt>
    80001590:	a029                	j	8000159a <devintr+0x72>
            virtio_disk_isr();
    80001592:	00001097          	auipc	ra,0x1
    80001596:	8c0080e7          	jalr	-1856(ra) # 80001e52 <virtio_disk_isr>
            complate_irq(irq);
    8000159a:	8526                	mv	a0,s1
    8000159c:	00000097          	auipc	ra,0x0
    800015a0:	404080e7          	jalr	1028(ra) # 800019a0 <complate_irq>
        return 1;
    800015a4:	4505                	li	a0,1
    800015a6:	b745                	j	80001546 <devintr+0x1e>
        if(cpuid() == 0){
    800015a8:	fffff097          	auipc	ra,0xfffff
    800015ac:	fce080e7          	jalr	-50(ra) # 80000576 <cpuid>
    800015b0:	c901                	beqz	a0,800015c0 <devintr+0x98>
    asm volatile("csrr %0,sip" : "=r"(x));
    800015b2:	144027f3          	csrr	a5,sip
        w_sip(r_sip() & ~2);
    800015b6:	9bf5                	andi	a5,a5,-3
    asm volatile("csrw sip,%0"::"r"(x));
    800015b8:	14479073          	csrw	sip,a5
        return 2;
    800015bc:	4509                	li	a0,2
    800015be:	b761                	j	80001546 <devintr+0x1e>
            clockintr();
    800015c0:	00000097          	auipc	ra,0x0
    800015c4:	f22080e7          	jalr	-222(ra) # 800014e2 <clockintr>
    800015c8:	b7ed                	j	800015b2 <devintr+0x8a>

00000000800015ca <usertrap>:
    w_stvec((uint64)kernelvec);
    initlock(&slock,"trap");
}


void usertrap(){
    800015ca:	1101                	addi	sp,sp,-32
    800015cc:	ec06                	sd	ra,24(sp)
    800015ce:	e822                	sd	s0,16(sp)
    800015d0:	e426                	sd	s1,8(sp)
    800015d2:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800015d4:	100027f3          	csrr	a5,sstatus
    int which_dev = 0;
    if((r_sstatus() & SSTATUS_SPP) != 0){
    800015d8:	1007f793          	andi	a5,a5,256
    800015dc:	efb1                	bnez	a5,80001638 <usertrap+0x6e>
    asm volatile("csrw stvec, %0" : : "r" (x));
    800015de:	fffff797          	auipc	a5,0xfffff
    800015e2:	b2278793          	addi	a5,a5,-1246 # 80000100 <kernelvec>
    800015e6:	10579073          	csrw	stvec,a5
        panic("usertrap: not from user mode");
    }
    w_stvec((uint64)kernelvec);
    struct proc *p = myproc();
    800015ea:	fffff097          	auipc	ra,0xfffff
    800015ee:	fb8080e7          	jalr	-72(ra) # 800005a2 <myproc>
    800015f2:	84aa                	mv	s1,a0
    p->trapframe->epc = r_sepc();
    800015f4:	713c                	ld	a5,96(a0)
    asm volatile("csrr %0,sepc":"=r"(x));
    800015f6:	14102773          	csrr	a4,sepc
    800015fa:	ef98                	sd	a4,24(a5)
    asm volatile("csrr %0,scause":"=r"(x));
    800015fc:	14202773          	csrr	a4,scause
    if(r_scause() == 8){
    80001600:	47a1                	li	a5,8
    80001602:	04f71a63          	bne	a4,a5,80001656 <usertrap+0x8c>
        if(p->killed){
    80001606:	595c                	lw	a5,52(a0)
    80001608:	e3a9                	bnez	a5,8000164a <usertrap+0x80>
            exit(-1);
        }
        p->trapframe->epc += 4;
    8000160a:	70b8                	ld	a4,96(s1)
    8000160c:	6f1c                	ld	a5,24(a4)
    8000160e:	0791                	addi	a5,a5,4
    80001610:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001612:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001616:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000161a:	10079073          	csrw	sstatus,a5
        intr_on();
        syscall();
    8000161e:	00002097          	auipc	ra,0x2
    80001622:	748080e7          	jalr	1864(ra) # 80003d66 <syscall>
        p->killed = 1;
    }
    if(which_dev == 2){
        yield();
    }
    usertrapret();
    80001626:	00000097          	auipc	ra,0x0
    8000162a:	e1e080e7          	jalr	-482(ra) # 80001444 <usertrapret>
    8000162e:	60e2                	ld	ra,24(sp)
    80001630:	6442                	ld	s0,16(sp)
    80001632:	64a2                	ld	s1,8(sp)
    80001634:	6105                	addi	sp,sp,32
    80001636:	8082                	ret
        panic("usertrap: not from user mode");
    80001638:	00006517          	auipc	a0,0x6
    8000163c:	c2850513          	addi	a0,a0,-984 # 80007260 <states.1524+0x48>
    80001640:	fffff097          	auipc	ra,0xfffff
    80001644:	e44080e7          	jalr	-444(ra) # 80000484 <panic>
    80001648:	bf59                	j	800015de <usertrap+0x14>
            exit(-1);
    8000164a:	557d                	li	a0,-1
    8000164c:	00000097          	auipc	ra,0x0
    80001650:	8ec080e7          	jalr	-1812(ra) # 80000f38 <exit>
    80001654:	bf5d                	j	8000160a <usertrap+0x40>
    }else if((which_dev = devintr()) != 0){
    80001656:	00000097          	auipc	ra,0x0
    8000165a:	ed2080e7          	jalr	-302(ra) # 80001528 <devintr>
    8000165e:	c909                	beqz	a0,80001670 <usertrap+0xa6>
    if(which_dev == 2){
    80001660:	4789                	li	a5,2
    80001662:	fcf512e3          	bne	a0,a5,80001626 <usertrap+0x5c>
        yield();
    80001666:	fffff097          	auipc	ra,0xfffff
    8000166a:	606080e7          	jalr	1542(ra) # 80000c6c <yield>
    8000166e:	bf65                	j	80001626 <usertrap+0x5c>
    asm volatile("csrr %0,scause":"=r"(x));
    80001670:	142025f3          	csrr	a1,scause
        printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80001674:	5890                	lw	a2,48(s1)
    80001676:	00006517          	auipc	a0,0x6
    8000167a:	c0a50513          	addi	a0,a0,-1014 # 80007280 <states.1524+0x68>
    8000167e:	fffff097          	auipc	ra,0xfffff
    80001682:	c3c080e7          	jalr	-964(ra) # 800002ba <printf>
    asm volatile("csrr %0,sepc":"=r"(x));
    80001686:	141025f3          	csrr	a1,sepc
    asm volatile("csrr %0,stval":"=r"(x));
    8000168a:	14302673          	csrr	a2,stval
        printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000168e:	00006517          	auipc	a0,0x6
    80001692:	c2250513          	addi	a0,a0,-990 # 800072b0 <states.1524+0x98>
    80001696:	fffff097          	auipc	ra,0xfffff
    8000169a:	c24080e7          	jalr	-988(ra) # 800002ba <printf>
        panic("user trap\n");
    8000169e:	00006517          	auipc	a0,0x6
    800016a2:	c3250513          	addi	a0,a0,-974 # 800072d0 <states.1524+0xb8>
    800016a6:	fffff097          	auipc	ra,0xfffff
    800016aa:	dde080e7          	jalr	-546(ra) # 80000484 <panic>
        p->killed = 1;
    800016ae:	4785                	li	a5,1
    800016b0:	d8dc                	sw	a5,52(s1)
    if(which_dev == 2){
    800016b2:	bf95                	j	80001626 <usertrap+0x5c>

00000000800016b4 <kerneltrap>:
void kerneltrap(){
    800016b4:	1101                	addi	sp,sp,-32
    800016b6:	ec06                	sd	ra,24(sp)
    800016b8:	e822                	sd	s0,16(sp)
    800016ba:	e426                	sd	s1,8(sp)
    800016bc:	e04a                	sd	s2,0(sp)
    800016be:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800016c0:	100024f3          	csrr	s1,sstatus
    asm volatile("csrr %0,sepc":"=r"(x));
    800016c4:	14102973          	csrr	s2,sepc
    if((sstatus & SSTATUS_SPP) == 0){
    800016c8:	1004f793          	andi	a5,s1,256
    800016cc:	c79d                	beqz	a5,800016fa <kerneltrap+0x46>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800016ce:	100027f3          	csrr	a5,sstatus
    if((r_sstatus() & SSTATUS_SIE) != 0){
    800016d2:	8b89                	andi	a5,a5,2
    800016d4:	ef85                	bnez	a5,8000170c <kerneltrap+0x58>
    if((which_dev = devintr()) == 0){
    800016d6:	00000097          	auipc	ra,0x0
    800016da:	e52080e7          	jalr	-430(ra) # 80001528 <devintr>
    800016de:	c121                	beqz	a0,8000171e <kerneltrap+0x6a>
    if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING){
    800016e0:	4789                	li	a5,2
    800016e2:	06f50563          	beq	a0,a5,8000174c <kerneltrap+0x98>
    asm volatile("csrw sepc,%0"::"r"(x));
    800016e6:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800016ea:	10049073          	csrw	sstatus,s1
}
    800016ee:	60e2                	ld	ra,24(sp)
    800016f0:	6442                	ld	s0,16(sp)
    800016f2:	64a2                	ld	s1,8(sp)
    800016f4:	6902                	ld	s2,0(sp)
    800016f6:	6105                	addi	sp,sp,32
    800016f8:	8082                	ret
        printf("kerneltrap: interrupt from U Model\n");
    800016fa:	00006517          	auipc	a0,0x6
    800016fe:	be650513          	addi	a0,a0,-1050 # 800072e0 <states.1524+0xc8>
    80001702:	fffff097          	auipc	ra,0xfffff
    80001706:	bb8080e7          	jalr	-1096(ra) # 800002ba <printf>
        return;
    8000170a:	b7d5                	j	800016ee <kerneltrap+0x3a>
        printf("kerneltrap: Handle kernel interrupts SIE cannot be set\n");
    8000170c:	00006517          	auipc	a0,0x6
    80001710:	bfc50513          	addi	a0,a0,-1028 # 80007308 <states.1524+0xf0>
    80001714:	fffff097          	auipc	ra,0xfffff
    80001718:	ba6080e7          	jalr	-1114(ra) # 800002ba <printf>
        return;
    8000171c:	bfc9                	j	800016ee <kerneltrap+0x3a>
    asm volatile("csrr %0,sepc":"=r"(x));
    8000171e:	141025f3          	csrr	a1,sepc
    asm volatile("csrr %0,stval":"=r"(x));
    80001722:	14302673          	csrr	a2,stval
    asm volatile("csrr %0,scause":"=r"(x));
    80001726:	142026f3          	csrr	a3,scause
        printf("sepc=%p stval=%p scause=%d\n", r_sepc(), r_stval(),r_scause());
    8000172a:	00006517          	auipc	a0,0x6
    8000172e:	c1650513          	addi	a0,a0,-1002 # 80007340 <states.1524+0x128>
    80001732:	fffff097          	auipc	ra,0xfffff
    80001736:	b88080e7          	jalr	-1144(ra) # 800002ba <printf>
        panic("kernel trap\n");
    8000173a:	00006517          	auipc	a0,0x6
    8000173e:	c2650513          	addi	a0,a0,-986 # 80007360 <states.1524+0x148>
    80001742:	fffff097          	auipc	ra,0xfffff
    80001746:	d42080e7          	jalr	-702(ra) # 80000484 <panic>
    if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING){
    8000174a:	bf71                	j	800016e6 <kerneltrap+0x32>
    8000174c:	fffff097          	auipc	ra,0xfffff
    80001750:	e56080e7          	jalr	-426(ra) # 800005a2 <myproc>
    80001754:	d949                	beqz	a0,800016e6 <kerneltrap+0x32>
    80001756:	fffff097          	auipc	ra,0xfffff
    8000175a:	e4c080e7          	jalr	-436(ra) # 800005a2 <myproc>
    8000175e:	4118                	lw	a4,0(a0)
    80001760:	4791                	li	a5,4
    80001762:	f8f712e3          	bne	a4,a5,800016e6 <kerneltrap+0x32>
        yield();
    80001766:	fffff097          	auipc	ra,0xfffff
    8000176a:	506080e7          	jalr	1286(ra) # 80000c6c <yield>
    8000176e:	bfa5                	j	800016e6 <kerneltrap+0x32>

0000000080001770 <trapinit>:
void trapinit(){
    80001770:	1141                	addi	sp,sp,-16
    80001772:	e406                	sd	ra,8(sp)
    80001774:	e022                	sd	s0,0(sp)
    80001776:	0800                	addi	s0,sp,16
    asm volatile("csrw stvec, %0" : : "r" (x));
    80001778:	fffff797          	auipc	a5,0xfffff
    8000177c:	98878793          	addi	a5,a5,-1656 # 80000100 <kernelvec>
    80001780:	10579073          	csrw	stvec,a5
    initlock(&slock,"trap");
    80001784:	00006597          	auipc	a1,0x6
    80001788:	bec58593          	addi	a1,a1,-1044 # 80007370 <states.1524+0x158>
    8000178c:	00015517          	auipc	a0,0x15
    80001790:	88c50513          	addi	a0,a0,-1908 # 80016018 <slock>
    80001794:	00000097          	auipc	ra,0x0
    80001798:	010080e7          	jalr	16(ra) # 800017a4 <initlock>
}
    8000179c:	60a2                	ld	ra,8(sp)
    8000179e:	6402                	ld	s0,0(sp)
    800017a0:	0141                	addi	sp,sp,16
    800017a2:	8082                	ret

00000000800017a4 <initlock>:
#include "riscv.h"

extern int atmswap(uint *lock);


void initlock(struct spinlock *lock,char *name){
    800017a4:	1141                	addi	sp,sp,-16
    800017a6:	e422                	sd	s0,8(sp)
    800017a8:	0800                	addi	s0,sp,16
    lock->name = name;
    800017aa:	e50c                	sd	a1,8(a0)
    lock->locked = 0;
    800017ac:	00052023          	sw	zero,0(a0)
}
    800017b0:	6422                	ld	s0,8(sp)
    800017b2:	0141                	addi	sp,sp,16
    800017b4:	8082                	ret

00000000800017b6 <holdinglock>:

int holdinglock(struct spinlock *lk){
    int r = (lk->locked && lk->cpu == mycpu());
    800017b6:	411c                	lw	a5,0(a0)
    800017b8:	e399                	bnez	a5,800017be <holdinglock+0x8>
    800017ba:	4501                	li	a0,0
    return r;
}
    800017bc:	8082                	ret
int holdinglock(struct spinlock *lk){
    800017be:	1101                	addi	sp,sp,-32
    800017c0:	ec06                	sd	ra,24(sp)
    800017c2:	e822                	sd	s0,16(sp)
    800017c4:	e426                	sd	s1,8(sp)
    800017c6:	1000                	addi	s0,sp,32
    int r = (lk->locked && lk->cpu == mycpu());
    800017c8:	6904                	ld	s1,16(a0)
    800017ca:	fffff097          	auipc	ra,0xfffff
    800017ce:	dbc080e7          	jalr	-580(ra) # 80000586 <mycpu>
    800017d2:	40a48533          	sub	a0,s1,a0
    800017d6:	00153513          	seqz	a0,a0
}
    800017da:	60e2                	ld	ra,24(sp)
    800017dc:	6442                	ld	s0,16(sp)
    800017de:	64a2                	ld	s1,8(sp)
    800017e0:	6105                	addi	sp,sp,32
    800017e2:	8082                	ret

00000000800017e4 <push_off>:
}




void push_off() {
    800017e4:	1101                	addi	sp,sp,-32
    800017e6:	ec06                	sd	ra,24(sp)
    800017e8:	e822                	sd	s0,16(sp)
    800017ea:	e426                	sd	s1,8(sp)
    800017ec:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800017ee:	100024f3          	csrr	s1,sstatus
    800017f2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800017f6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800017f8:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    800017fc:	fffff097          	auipc	ra,0xfffff
    80001800:	d8a080e7          	jalr	-630(ra) # 80000586 <mycpu>
    80001804:	5d3c                	lw	a5,120(a0)
    80001806:	cf89                	beqz	a5,80001820 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80001808:	fffff097          	auipc	ra,0xfffff
    8000180c:	d7e080e7          	jalr	-642(ra) # 80000586 <mycpu>
    80001810:	5d3c                	lw	a5,120(a0)
    80001812:	2785                	addiw	a5,a5,1
    80001814:	dd3c                	sw	a5,120(a0)
}
    80001816:	60e2                	ld	ra,24(sp)
    80001818:	6442                	ld	s0,16(sp)
    8000181a:	64a2                	ld	s1,8(sp)
    8000181c:	6105                	addi	sp,sp,32
    8000181e:	8082                	ret
    mycpu()->intena = old;
    80001820:	fffff097          	auipc	ra,0xfffff
    80001824:	d66080e7          	jalr	-666(ra) # 80000586 <mycpu>
    return (r_sstatus() & SSTATUS_SIE) != 0;
    80001828:	8085                	srli	s1,s1,0x1
    8000182a:	8885                	andi	s1,s1,1
    8000182c:	dd64                	sw	s1,124(a0)
    8000182e:	bfe9                	j	80001808 <push_off+0x24>

0000000080001830 <acquire>:
void acquire(struct spinlock *lock){
    80001830:	1101                	addi	sp,sp,-32
    80001832:	ec06                	sd	ra,24(sp)
    80001834:	e822                	sd	s0,16(sp)
    80001836:	e426                	sd	s1,8(sp)
    80001838:	1000                	addi	s0,sp,32
    8000183a:	84aa                	mv	s1,a0
    push_off();
    8000183c:	00000097          	auipc	ra,0x0
    80001840:	fa8080e7          	jalr	-88(ra) # 800017e4 <push_off>
    if(holdinglock(lock)){
    80001844:	8526                	mv	a0,s1
    80001846:	00000097          	auipc	ra,0x0
    8000184a:	f70080e7          	jalr	-144(ra) # 800017b6 <holdinglock>
    8000184e:	e11d                	bnez	a0,80001874 <acquire+0x44>
    while (atmswap(&lock->locked) != 0){}
    80001850:	8526                	mv	a0,s1
    80001852:	00000097          	auipc	ra,0x0
    80001856:	0e6080e7          	jalr	230(ra) # 80001938 <atmswap>
    8000185a:	f97d                	bnez	a0,80001850 <acquire+0x20>
    __sync_synchronize();
    8000185c:	0ff0000f          	fence
    lock->cpu = mycpu();
    80001860:	fffff097          	auipc	ra,0xfffff
    80001864:	d26080e7          	jalr	-730(ra) # 80000586 <mycpu>
    80001868:	e888                	sd	a0,16(s1)
}
    8000186a:	60e2                	ld	ra,24(sp)
    8000186c:	6442                	ld	s0,16(sp)
    8000186e:	64a2                	ld	s1,8(sp)
    80001870:	6105                	addi	sp,sp,32
    80001872:	8082                	ret
        panic("acquire...\n");
    80001874:	00006517          	auipc	a0,0x6
    80001878:	b0450513          	addi	a0,a0,-1276 # 80007378 <states.1524+0x160>
    8000187c:	fffff097          	auipc	ra,0xfffff
    80001880:	c08080e7          	jalr	-1016(ra) # 80000484 <panic>
    80001884:	b7f1                	j	80001850 <acquire+0x20>

0000000080001886 <pop_off>:

void pop_off() {
    80001886:	1101                	addi	sp,sp,-32
    80001888:	ec06                	sd	ra,24(sp)
    8000188a:	e822                	sd	s0,16(sp)
    8000188c:	e426                	sd	s1,8(sp)
    8000188e:	1000                	addi	s0,sp,32
  struct cpu *c = mycpu();
    80001890:	fffff097          	auipc	ra,0xfffff
    80001894:	cf6080e7          	jalr	-778(ra) # 80000586 <mycpu>
    80001898:	84aa                	mv	s1,a0
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000189a:	100027f3          	csrr	a5,sstatus
    return (r_sstatus() & SSTATUS_SIE) != 0;
    8000189e:	8b89                	andi	a5,a5,2
  if(intr_get())
    800018a0:	e79d                	bnez	a5,800018ce <pop_off+0x48>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    800018a2:	5cbc                	lw	a5,120(s1)
    800018a4:	02f05e63          	blez	a5,800018e0 <pop_off+0x5a>
    panic("pop_off");
  c->noff -= 1;
    800018a8:	5cbc                	lw	a5,120(s1)
    800018aa:	37fd                	addiw	a5,a5,-1
    800018ac:	0007871b          	sext.w	a4,a5
    800018b0:	dcbc                	sw	a5,120(s1)
  if(c->noff == 0 && c->intena)
    800018b2:	eb09                	bnez	a4,800018c4 <pop_off+0x3e>
    800018b4:	5cfc                	lw	a5,124(s1)
    800018b6:	c799                	beqz	a5,800018c4 <pop_off+0x3e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800018b8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800018bc:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800018c0:	10079073          	csrw	sstatus,a5
    intr_on();
}
    800018c4:	60e2                	ld	ra,24(sp)
    800018c6:	6442                	ld	s0,16(sp)
    800018c8:	64a2                	ld	s1,8(sp)
    800018ca:	6105                	addi	sp,sp,32
    800018cc:	8082                	ret
    panic("pop_off - interruptible");
    800018ce:	00006517          	auipc	a0,0x6
    800018d2:	aba50513          	addi	a0,a0,-1350 # 80007388 <states.1524+0x170>
    800018d6:	fffff097          	auipc	ra,0xfffff
    800018da:	bae080e7          	jalr	-1106(ra) # 80000484 <panic>
    800018de:	b7d1                	j	800018a2 <pop_off+0x1c>
    panic("pop_off");
    800018e0:	00006517          	auipc	a0,0x6
    800018e4:	ac050513          	addi	a0,a0,-1344 # 800073a0 <states.1524+0x188>
    800018e8:	fffff097          	auipc	ra,0xfffff
    800018ec:	b9c080e7          	jalr	-1124(ra) # 80000484 <panic>
    800018f0:	bf65                	j	800018a8 <pop_off+0x22>

00000000800018f2 <release>:
void release(struct spinlock *lock){
    800018f2:	1101                	addi	sp,sp,-32
    800018f4:	ec06                	sd	ra,24(sp)
    800018f6:	e822                	sd	s0,16(sp)
    800018f8:	e426                	sd	s1,8(sp)
    800018fa:	1000                	addi	s0,sp,32
    800018fc:	84aa                	mv	s1,a0
    if(!holdinglock(lock)){
    800018fe:	00000097          	auipc	ra,0x0
    80001902:	eb8080e7          	jalr	-328(ra) # 800017b6 <holdinglock>
    80001906:	c105                	beqz	a0,80001926 <release+0x34>
    lock->cpu = 0;
    80001908:	0004b823          	sd	zero,16(s1)
    __sync_synchronize();
    8000190c:	0ff0000f          	fence
    lock->locked = 0;
    80001910:	0004a023          	sw	zero,0(s1)
    pop_off();
    80001914:	00000097          	auipc	ra,0x0
    80001918:	f72080e7          	jalr	-142(ra) # 80001886 <pop_off>
}
    8000191c:	60e2                	ld	ra,24(sp)
    8000191e:	6442                	ld	s0,16(sp)
    80001920:	64a2                	ld	s1,8(sp)
    80001922:	6105                	addi	sp,sp,32
    80001924:	8082                	ret
        panic("release...\n");
    80001926:	00006517          	auipc	a0,0x6
    8000192a:	a8250513          	addi	a0,a0,-1406 # 800073a8 <states.1524+0x190>
    8000192e:	fffff097          	auipc	ra,0xfffff
    80001932:	b56080e7          	jalr	-1194(ra) # 80000484 <panic>
    80001936:	bfc9                	j	80001908 <release+0x16>

0000000080001938 <atmswap>:
    80001938:	4285                	li	t0,1
    8000193a:	0c55232f          	amoswap.w.aq	t1,t0,(a0)
    8000193e:	851a                	mv	a0,t1
    80001940:	8082                	ret

0000000080001942 <plicinit>:
#include "riscv.h"
#include "memlayout.h"


void plicinit()
{
    80001942:	1141                	addi	sp,sp,-16
    80001944:	e422                	sd	s0,8(sp)
    80001946:	0800                	addi	s0,sp,16
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80001948:	0c0007b7          	lui	a5,0xc000
    8000194c:	4705                	li	a4,1
    8000194e:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80001950:	c3d8                	sw	a4,4(a5)
}
    80001952:	6422                	ld	s0,8(sp)
    80001954:	0141                	addi	sp,sp,16
    80001956:	8082                	ret

0000000080001958 <plicinithart>:

void plicinithart()
{
    80001958:	1141                	addi	sp,sp,-16
    8000195a:	e422                	sd	s0,8(sp)
    8000195c:	0800                	addi	s0,sp,16
    asm volatile("mv %0,tp":"=r"(x));
    8000195e:	8792                	mv	a5,tp
  int hart = r_tp();
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80001960:	0087969b          	slliw	a3,a5,0x8
    80001964:	0c002737          	lui	a4,0xc002
    80001968:	9736                	add	a4,a4,a3
    8000196a:	40200693          	li	a3,1026
    8000196e:	08d72023          	sw	a3,128(a4) # c002080 <_entry-0x73ffdf80>
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80001972:	00d7979b          	slliw	a5,a5,0xd
    80001976:	0c201737          	lui	a4,0xc201
    8000197a:	97ba                	add	a5,a5,a4
    8000197c:	0007a023          	sw	zero,0(a5) # c000000 <_entry-0x74000000>
}
    80001980:	6422                	ld	s0,8(sp)
    80001982:	0141                	addi	sp,sp,16
    80001984:	8082                	ret

0000000080001986 <plic_claim>:


int plic_claim(){
    80001986:	1141                	addi	sp,sp,-16
    80001988:	e422                	sd	s0,8(sp)
    8000198a:	0800                	addi	s0,sp,16
    8000198c:	8792                	mv	a5,tp
    uint64 cpuid = r_tp();
    int irq = *(uint32*)PLIC_SCLAIM(cpuid);
    8000198e:	00d79713          	slli	a4,a5,0xd
    80001992:	0c2017b7          	lui	a5,0xc201
    80001996:	97ba                	add	a5,a5,a4
    return irq;
}
    80001998:	43c8                	lw	a0,4(a5)
    8000199a:	6422                	ld	s0,8(sp)
    8000199c:	0141                	addi	sp,sp,16
    8000199e:	8082                	ret

00000000800019a0 <complate_irq>:


void
complate_irq(int irq)
{
    800019a0:	1141                	addi	sp,sp,-16
    800019a2:	e422                	sd	s0,8(sp)
    800019a4:	0800                	addi	s0,sp,16
    800019a6:	8792                	mv	a5,tp
  uint64 hart = r_tp();
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800019a8:	00d79713          	slli	a4,a5,0xd
    800019ac:	0c2017b7          	lui	a5,0xc201
    800019b0:	97ba                	add	a5,a5,a4
    800019b2:	c3c8                	sw	a0,4(a5)
    800019b4:	6422                	ld	s0,8(sp)
    800019b6:	0141                	addi	sp,sp,16
    800019b8:	8082                	ret

00000000800019ba <free_desc>:
  return -1;
}

//将描述符标记为空闲
static void free_desc(int i)
{
    800019ba:	1141                	addi	sp,sp,-16
    800019bc:	e406                	sd	ra,8(sp)
    800019be:	e022                	sd	s0,0(sp)
    800019c0:	0800                	addi	s0,sp,16
  if(i >= NUM){
    800019c2:	479d                	li	a5,7
    800019c4:	06a7c963          	blt	a5,a0,80001a36 <free_desc+0x7c>
    printf("free_desc 1");
    return;
  }
  if(disk.free[i]){
    800019c8:	00015797          	auipc	a5,0x15
    800019cc:	63878793          	addi	a5,a5,1592 # 80017000 <disk>
    800019d0:	00a78733          	add	a4,a5,a0
    800019d4:	6789                	lui	a5,0x2
    800019d6:	97ba                	add	a5,a5,a4
    800019d8:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    800019dc:	e7b5                	bnez	a5,80001a48 <free_desc+0x8e>
    printf("free_desc 2");
    return;
  }
  disk.desc[i].addr = 0;
    800019de:	00451793          	slli	a5,a0,0x4
    800019e2:	00017717          	auipc	a4,0x17
    800019e6:	61e70713          	addi	a4,a4,1566 # 80019000 <disk+0x2000>
    800019ea:	6314                	ld	a3,0(a4)
    800019ec:	96be                	add	a3,a3,a5
    800019ee:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    800019f2:	6314                	ld	a3,0(a4)
    800019f4:	96be                	add	a3,a3,a5
    800019f6:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    800019fa:	6314                	ld	a3,0(a4)
    800019fc:	96be                	add	a3,a3,a5
    800019fe:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    80001a02:	6318                	ld	a4,0(a4)
    80001a04:	97ba                	add	a5,a5,a4
    80001a06:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80001a0a:	00015797          	auipc	a5,0x15
    80001a0e:	5f678793          	addi	a5,a5,1526 # 80017000 <disk>
    80001a12:	97aa                	add	a5,a5,a0
    80001a14:	6509                	lui	a0,0x2
    80001a16:	953e                	add	a0,a0,a5
    80001a18:	4785                	li	a5,1
    80001a1a:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80001a1e:	00017517          	auipc	a0,0x17
    80001a22:	5fa50513          	addi	a0,a0,1530 # 80019018 <disk+0x2018>
    80001a26:	fffff097          	auipc	ra,0xfffff
    80001a2a:	bfc080e7          	jalr	-1028(ra) # 80000622 <wakeup>
}
    80001a2e:	60a2                	ld	ra,8(sp)
    80001a30:	6402                	ld	s0,0(sp)
    80001a32:	0141                	addi	sp,sp,16
    80001a34:	8082                	ret
    printf("free_desc 1");
    80001a36:	00006517          	auipc	a0,0x6
    80001a3a:	98250513          	addi	a0,a0,-1662 # 800073b8 <states.1524+0x1a0>
    80001a3e:	fffff097          	auipc	ra,0xfffff
    80001a42:	87c080e7          	jalr	-1924(ra) # 800002ba <printf>
    return;
    80001a46:	b7e5                	j	80001a2e <free_desc+0x74>
    printf("free_desc 2");
    80001a48:	00006517          	auipc	a0,0x6
    80001a4c:	98050513          	addi	a0,a0,-1664 # 800073c8 <states.1524+0x1b0>
    80001a50:	fffff097          	auipc	ra,0xfffff
    80001a54:	86a080e7          	jalr	-1942(ra) # 800002ba <printf>
    return;
    80001a58:	bfd9                	j	80001a2e <free_desc+0x74>

0000000080001a5a <virt_disk_rw>:
      break;
    }
  }
}

void virt_disk_rw(struct buf *b, int write) {
    80001a5a:	7159                	addi	sp,sp,-112
    80001a5c:	f486                	sd	ra,104(sp)
    80001a5e:	f0a2                	sd	s0,96(sp)
    80001a60:	eca6                	sd	s1,88(sp)
    80001a62:	e8ca                	sd	s2,80(sp)
    80001a64:	e4ce                	sd	s3,72(sp)
    80001a66:	e0d2                	sd	s4,64(sp)
    80001a68:	fc56                	sd	s5,56(sp)
    80001a6a:	f85a                	sd	s6,48(sp)
    80001a6c:	f45e                	sd	s7,40(sp)
    80001a6e:	f062                	sd	s8,32(sp)
    80001a70:	ec66                	sd	s9,24(sp)
    80001a72:	e86a                	sd	s10,16(sp)
    80001a74:	1880                	addi	s0,sp,112
    80001a76:	892a                	mv	s2,a0
    80001a78:	8d2e                	mv	s10,a1
    // 指定写入的扇区
    uint64 sector = b->blockno * (BSIZE / 512); 
    80001a7a:	00c52c83          	lw	s9,12(a0)
    80001a7e:	001c9c9b          	slliw	s9,s9,0x1
    80001a82:	1c82                	slli	s9,s9,0x20
    80001a84:	020cdc93          	srli	s9,s9,0x20

    acquire(&disk.disklock);
    80001a88:	00017517          	auipc	a0,0x17
    80001a8c:	6a050513          	addi	a0,a0,1696 # 80019128 <disk+0x2128>
    80001a90:	00000097          	auipc	ra,0x0
    80001a94:	da0080e7          	jalr	-608(ra) # 80001830 <acquire>
  for(int i = 0; i < 3; i++){
    80001a98:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80001a9a:	4c21                	li	s8,8
      disk.free[i] = 0;
    80001a9c:	00015b97          	auipc	s7,0x15
    80001aa0:	564b8b93          	addi	s7,s7,1380 # 80017000 <disk>
    80001aa4:	6b09                	lui	s6,0x2
  for(int i = 0; i < 3; i++){
    80001aa6:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    80001aa8:	8a4e                	mv	s4,s3
  for(int i = 0; i < 3; i++){
    80001aaa:	f9040713          	addi	a4,s0,-112
    80001aae:	84ce                	mv	s1,s3
    80001ab0:	a829                	j	80001aca <virt_disk_rw+0x70>
      disk.free[i] = 0;
    80001ab2:	00fb86b3          	add	a3,s7,a5
    80001ab6:	96da                	add	a3,a3,s6
    80001ab8:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80001abc:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    80001abe:	0207c563          	bltz	a5,80001ae8 <virt_disk_rw+0x8e>
  for(int i = 0; i < 3; i++){
    80001ac2:	2485                	addiw	s1,s1,1
    80001ac4:	0711                	addi	a4,a4,4
    80001ac6:	19548963          	beq	s1,s5,80001c58 <virt_disk_rw+0x1fe>
    idx[i] = alloc_desc();
    80001aca:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80001acc:	00017697          	auipc	a3,0x17
    80001ad0:	54c68693          	addi	a3,a3,1356 # 80019018 <disk+0x2018>
    80001ad4:	87d2                	mv	a5,s4
    if(disk.free[i]){
    80001ad6:	0006c583          	lbu	a1,0(a3)
    80001ada:	fde1                	bnez	a1,80001ab2 <virt_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80001adc:	2785                	addiw	a5,a5,1
    80001ade:	0685                	addi	a3,a3,1
    80001ae0:	ff879be3          	bne	a5,s8,80001ad6 <virt_disk_rw+0x7c>
    idx[i] = alloc_desc();
    80001ae4:	57fd                	li	a5,-1
    80001ae6:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++){
    80001ae8:	fc9051e3          	blez	s1,80001aaa <virt_disk_rw+0x50>
        free_desc(idx[j]);
    80001aec:	f9042503          	lw	a0,-112(s0)
    80001af0:	00000097          	auipc	ra,0x0
    80001af4:	eca080e7          	jalr	-310(ra) # 800019ba <free_desc>
      for(int j = 0; j < i; j++){
    80001af8:	4785                	li	a5,1
    80001afa:	fa97d8e3          	bge	a5,s1,80001aaa <virt_disk_rw+0x50>
        free_desc(idx[j]);
    80001afe:	f9442503          	lw	a0,-108(s0)
    80001b02:	00000097          	auipc	ra,0x0
    80001b06:	eb8080e7          	jalr	-328(ra) # 800019ba <free_desc>
      for(int j = 0; j < i; j++){
    80001b0a:	4789                	li	a5,2
    80001b0c:	f897dfe3          	bge	a5,s1,80001aaa <virt_disk_rw+0x50>
        free_desc(idx[j]);
    80001b10:	f9842503          	lw	a0,-104(s0)
    80001b14:	00000097          	auipc	ra,0x0
    80001b18:	ea6080e7          	jalr	-346(ra) # 800019ba <free_desc>
      for(int j = 0; j < i; j++){
    80001b1c:	b779                	j	80001aaa <virt_disk_rw+0x50>
    disk.desc[idx[0]].next = idx[1];

    disk.desc[idx[1]].addr = (uint64)b->data;
    disk.desc[idx[1]].len = BSIZE;
    if (write){
        disk.desc[idx[1]].flags = 0; // 设备读取 b->data
    80001b1e:	00017697          	auipc	a3,0x17
    80001b22:	4e26b683          	ld	a3,1250(a3) # 80019000 <disk+0x2000>
    80001b26:	96ba                	add	a3,a3,a4
    80001b28:	00069623          	sh	zero,12(a3)
    }else{
        disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // 设备写入 b->data
    }
    disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80001b2c:	00015817          	auipc	a6,0x15
    80001b30:	4d480813          	addi	a6,a6,1236 # 80017000 <disk>
    80001b34:	00017697          	auipc	a3,0x17
    80001b38:	4cc68693          	addi	a3,a3,1228 # 80019000 <disk+0x2000>
    80001b3c:	6290                	ld	a2,0(a3)
    80001b3e:	963a                	add	a2,a2,a4
    80001b40:	00c65583          	lhu	a1,12(a2)
    80001b44:	0015e593          	ori	a1,a1,1
    80001b48:	00b61623          	sh	a1,12(a2)
    disk.desc[idx[1]].next = idx[2];
    80001b4c:	f9842603          	lw	a2,-104(s0)
    80001b50:	628c                	ld	a1,0(a3)
    80001b52:	972e                	add	a4,a4,a1
    80001b54:	00c71723          	sh	a2,14(a4)

    disk.info[idx[0]].status = 0xff;
    80001b58:	20050593          	addi	a1,a0,512
    80001b5c:	0592                	slli	a1,a1,0x4
    80001b5e:	95c2                	add	a1,a1,a6
    80001b60:	577d                	li	a4,-1
    80001b62:	02e58423          	sb	a4,40(a1)
    disk.desc[idx[2]].addr = (uint64)&disk.info[idx[0]].status;
    80001b66:	00461713          	slli	a4,a2,0x4
    80001b6a:	6290                	ld	a2,0(a3)
    80001b6c:	963a                	add	a2,a2,a4
    80001b6e:	02878793          	addi	a5,a5,40
    80001b72:	97c2                	add	a5,a5,a6
    80001b74:	e21c                	sd	a5,0(a2)
    disk.desc[idx[2]].len = 1;
    80001b76:	629c                	ld	a5,0(a3)
    80001b78:	97ba                	add	a5,a5,a4
    80001b7a:	4605                	li	a2,1
    80001b7c:	c790                	sw	a2,8(a5)
    disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // 设备写入状态
    80001b7e:	629c                	ld	a5,0(a3)
    80001b80:	97ba                	add	a5,a5,a4
    80001b82:	4809                	li	a6,2
    80001b84:	01079623          	sh	a6,12(a5)
    disk.desc[idx[2]].next = 0;
    80001b88:	629c                	ld	a5,0(a3)
    80001b8a:	973e                	add	a4,a4,a5
    80001b8c:	00071723          	sh	zero,14(a4)

    // 为 virtio_disk_intr() 记录结构 buf
    b->disk = 1;
    80001b90:	00c92223          	sw	a2,4(s2)
    disk.info[idx[0]].b = b;
    80001b94:	0325b023          	sd	s2,32(a1)

    // 告诉设备我们的描述符链中的第一个索引
    disk.avail->ring[disk.avail->index % NUM] = idx[0];
    80001b98:	6698                	ld	a4,8(a3)
    80001b9a:	00275783          	lhu	a5,2(a4)
    80001b9e:	8b9d                	andi	a5,a5,7
    80001ba0:	0786                	slli	a5,a5,0x1
    80001ba2:	97ba                	add	a5,a5,a4
    80001ba4:	00a79223          	sh	a0,4(a5)

    __sync_synchronize();
    80001ba8:	0ff0000f          	fence

    //告诉设备另一个可用ring条目可用
    disk.avail->index += 1; // not % NUM ...
    80001bac:	6698                	ld	a4,8(a3)
    80001bae:	00275783          	lhu	a5,2(a4)
    80001bb2:	2785                	addiw	a5,a5,1
    80001bb4:	00f71123          	sh	a5,2(a4)

    __sync_synchronize();
    80001bb8:	0ff0000f          	fence


    *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; //当我们将0写入queue_notify时，设备会立即启动
    80001bbc:	100017b7          	lui	a5,0x10001
    80001bc0:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>
    while (b->disk == 1) {
    80001bc4:	00492783          	lw	a5,4(s2)
    80001bc8:	02c79163          	bne	a5,a2,80001bea <virt_disk_rw+0x190>
      sleep(b, &disk.disklock);
    80001bcc:	00017997          	auipc	s3,0x17
    80001bd0:	55c98993          	addi	s3,s3,1372 # 80019128 <disk+0x2128>
    while (b->disk == 1) {
    80001bd4:	4485                	li	s1,1
      sleep(b, &disk.disklock);
    80001bd6:	85ce                	mv	a1,s3
    80001bd8:	854a                	mv	a0,s2
    80001bda:	fffff097          	auipc	ra,0xfffff
    80001bde:	e4c080e7          	jalr	-436(ra) # 80000a26 <sleep>
    while (b->disk == 1) {
    80001be2:	00492783          	lw	a5,4(s2)
    80001be6:	fe9788e3          	beq	a5,s1,80001bd6 <virt_disk_rw+0x17c>
    }

    disk.info[idx[0]].b = 0;
    80001bea:	f9042903          	lw	s2,-112(s0)
    80001bee:	20090793          	addi	a5,s2,512
    80001bf2:	00479713          	slli	a4,a5,0x4
    80001bf6:	00015797          	auipc	a5,0x15
    80001bfa:	40a78793          	addi	a5,a5,1034 # 80017000 <disk>
    80001bfe:	97ba                	add	a5,a5,a4
    80001c00:	0207b023          	sd	zero,32(a5)
    int flag = disk.desc[i].flags;
    80001c04:	00017997          	auipc	s3,0x17
    80001c08:	3fc98993          	addi	s3,s3,1020 # 80019000 <disk+0x2000>
    80001c0c:	00491713          	slli	a4,s2,0x4
    80001c10:	0009b783          	ld	a5,0(s3)
    80001c14:	97ba                	add	a5,a5,a4
    80001c16:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80001c1a:	854a                	mv	a0,s2
    80001c1c:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80001c20:	00000097          	auipc	ra,0x0
    80001c24:	d9a080e7          	jalr	-614(ra) # 800019ba <free_desc>
    if (flag & VRING_DESC_F_NEXT){
    80001c28:	8885                	andi	s1,s1,1
    80001c2a:	f0ed                	bnez	s1,80001c0c <virt_disk_rw+0x1b2>
    free_chain(idx[0]);

    release(&disk.disklock);
    80001c2c:	00017517          	auipc	a0,0x17
    80001c30:	4fc50513          	addi	a0,a0,1276 # 80019128 <disk+0x2128>
    80001c34:	00000097          	auipc	ra,0x0
    80001c38:	cbe080e7          	jalr	-834(ra) # 800018f2 <release>
}
    80001c3c:	70a6                	ld	ra,104(sp)
    80001c3e:	7406                	ld	s0,96(sp)
    80001c40:	64e6                	ld	s1,88(sp)
    80001c42:	6946                	ld	s2,80(sp)
    80001c44:	69a6                	ld	s3,72(sp)
    80001c46:	6a06                	ld	s4,64(sp)
    80001c48:	7ae2                	ld	s5,56(sp)
    80001c4a:	7b42                	ld	s6,48(sp)
    80001c4c:	7ba2                	ld	s7,40(sp)
    80001c4e:	7c02                	ld	s8,32(sp)
    80001c50:	6ce2                	ld	s9,24(sp)
    80001c52:	6d42                	ld	s10,16(sp)
    80001c54:	6165                	addi	sp,sp,112
    80001c56:	8082                	ret
    struct virt_blk_req *buf0 = &disk.ops[idx[0]];
    80001c58:	f9042503          	lw	a0,-112(s0)
    80001c5c:	20050793          	addi	a5,a0,512
    80001c60:	0792                	slli	a5,a5,0x4
    if (write){
    80001c62:	00015817          	auipc	a6,0x15
    80001c66:	39e80813          	addi	a6,a6,926 # 80017000 <disk>
    80001c6a:	00f80733          	add	a4,a6,a5
    80001c6e:	01a036b3          	snez	a3,s10
    80001c72:	0ad72423          	sw	a3,168(a4)
    buf0->reserved = 0;             // 保留部分用于将标头填充到 16 个字节，并将32位扇区字段移动到正确的位置。
    80001c76:	0a072623          	sw	zero,172(a4)
    buf0->sector = sector;          // 指定我们要修改的扇区
    80001c7a:	0b973823          	sd	s9,176(a4)
    disk.desc[idx[0]].addr = (uint64) buf0;
    80001c7e:	7679                	lui	a2,0xffffe
    80001c80:	963e                	add	a2,a2,a5
    80001c82:	00017697          	auipc	a3,0x17
    80001c86:	37e68693          	addi	a3,a3,894 # 80019000 <disk+0x2000>
    80001c8a:	6298                	ld	a4,0(a3)
    80001c8c:	9732                	add	a4,a4,a2
    struct virt_blk_req *buf0 = &disk.ops[idx[0]];
    80001c8e:	0a878593          	addi	a1,a5,168
    80001c92:	95c2                	add	a1,a1,a6
    disk.desc[idx[0]].addr = (uint64) buf0;
    80001c94:	e30c                	sd	a1,0(a4)
    disk.desc[idx[0]].len = sizeof(struct virt_blk_req);
    80001c96:	6298                	ld	a4,0(a3)
    80001c98:	9732                	add	a4,a4,a2
    80001c9a:	45c1                	li	a1,16
    80001c9c:	c70c                	sw	a1,8(a4)
    disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80001c9e:	6298                	ld	a4,0(a3)
    80001ca0:	9732                	add	a4,a4,a2
    80001ca2:	4585                	li	a1,1
    80001ca4:	00b71623          	sh	a1,12(a4)
    disk.desc[idx[0]].next = idx[1];
    80001ca8:	f9442703          	lw	a4,-108(s0)
    80001cac:	628c                	ld	a1,0(a3)
    80001cae:	962e                	add	a2,a2,a1
    80001cb0:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffdd6de>
    disk.desc[idx[1]].addr = (uint64)b->data;
    80001cb4:	0712                	slli	a4,a4,0x4
    80001cb6:	6290                	ld	a2,0(a3)
    80001cb8:	963a                	add	a2,a2,a4
    80001cba:	05890593          	addi	a1,s2,88
    80001cbe:	e20c                	sd	a1,0(a2)
    disk.desc[idx[1]].len = BSIZE;
    80001cc0:	6294                	ld	a3,0(a3)
    80001cc2:	96ba                	add	a3,a3,a4
    80001cc4:	40000613          	li	a2,1024
    80001cc8:	c690                	sw	a2,8(a3)
    if (write){
    80001cca:	e40d1ae3          	bnez	s10,80001b1e <virt_disk_rw+0xc4>
        disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // 设备写入 b->data
    80001cce:	00017697          	auipc	a3,0x17
    80001cd2:	3326b683          	ld	a3,818(a3) # 80019000 <disk+0x2000>
    80001cd6:	96ba                	add	a3,a3,a4
    80001cd8:	4609                	li	a2,2
    80001cda:	00c69623          	sh	a2,12(a3)
    80001cde:	b5b9                	j	80001b2c <virt_disk_rw+0xd2>

0000000080001ce0 <virtio_disk_init>:


void virtio_disk_init() {
    80001ce0:	1101                	addi	sp,sp,-32
    80001ce2:	ec06                	sd	ra,24(sp)
    80001ce4:	e822                	sd	s0,16(sp)
    80001ce6:	e426                	sd	s1,8(sp)
    80001ce8:	1000                	addi	s0,sp,32
  uint32 status = 0;

  initlock(&disk.disklock, "virtlock");
    80001cea:	00005597          	auipc	a1,0x5
    80001cee:	6ee58593          	addi	a1,a1,1774 # 800073d8 <states.1524+0x1c0>
    80001cf2:	00017517          	auipc	a0,0x17
    80001cf6:	43650513          	addi	a0,a0,1078 # 80019128 <disk+0x2128>
    80001cfa:	00000097          	auipc	ra,0x0
    80001cfe:	aaa080e7          	jalr	-1366(ra) # 800017a4 <initlock>

  //校验磁盘是否存在
  uint64 magic = *R(VIRTIO_MMIO_MAGIC_VALUE);
    80001d02:	100014b7          	lui	s1,0x10001
    80001d06:	408c                	lw	a1,0(s1)
  uint64 ver = *R(VIRTIO_MMIO_VERSION);
    80001d08:	40d0                	lw	a2,4(s1)
  uint64 deviceId = *R(VIRTIO_MMIO_DEVICE_ID);
    80001d0a:	4494                	lw	a3,8(s1)
  uint64 vendor = *R(VIRTIO_MMIO_VENDOR_ID);
    80001d0c:	44d8                	lw	a4,12(s1)
  printf("magic:%p,ver:%d,deviceId:%d,vendor:%p\n",magic,ver,deviceId,vendor);
    80001d0e:	1702                	slli	a4,a4,0x20
    80001d10:	9301                	srli	a4,a4,0x20
    80001d12:	1682                	slli	a3,a3,0x20
    80001d14:	9281                	srli	a3,a3,0x20
    80001d16:	1602                	slli	a2,a2,0x20
    80001d18:	9201                	srli	a2,a2,0x20
    80001d1a:	1582                	slli	a1,a1,0x20
    80001d1c:	9181                	srli	a1,a1,0x20
    80001d1e:	00005517          	auipc	a0,0x5
    80001d22:	6ca50513          	addi	a0,a0,1738 # 800073e8 <states.1524+0x1d0>
    80001d26:	ffffe097          	auipc	ra,0xffffe
    80001d2a:	594080e7          	jalr	1428(ra) # 800002ba <printf>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||     // virtio-v1.1[4.2.2.2] The driver MUST ignore a device with MagicValue which is not 0x74726976
    80001d2e:	4098                	lw	a4,0(s1)
    80001d30:	2701                	sext.w	a4,a4
    80001d32:	747277b7          	lui	a5,0x74727
    80001d36:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80001d3a:	02f71a63          	bne	a4,a5,80001d6e <virtio_disk_init+0x8e>
     *R(VIRTIO_MMIO_VERSION) != 1 ||              
    80001d3e:	100017b7          	lui	a5,0x10001
    80001d42:	43dc                	lw	a5,4(a5)
    80001d44:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||     // virtio-v1.1[4.2.2.2] The driver MUST ignore a device with MagicValue which is not 0x74726976
    80001d46:	4705                	li	a4,1
    80001d48:	02e79363          	bne	a5,a4,80001d6e <virtio_disk_init+0x8e>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80001d4c:	100017b7          	lui	a5,0x10001
    80001d50:	479c                	lw	a5,8(a5)
    80001d52:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||              
    80001d54:	4709                	li	a4,2
    80001d56:	00e79c63          	bne	a5,a4,80001d6e <virtio_disk_init+0x8e>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551) {
    80001d5a:	100017b7          	lui	a5,0x10001
    80001d5e:	47d8                	lw	a4,12(a5)
    80001d60:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80001d62:	554d47b7          	lui	a5,0x554d4
    80001d66:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80001d6a:	00f70f63          	beq	a4,a5,80001d88 <virtio_disk_init+0xa8>
    printf("could not find virtio disk");
    80001d6e:	00005517          	auipc	a0,0x5
    80001d72:	6a250513          	addi	a0,a0,1698 # 80007410 <states.1524+0x1f8>
    80001d76:	ffffe097          	auipc	ra,0xffffe
    80001d7a:	544080e7          	jalr	1348(ra) # 800002ba <printf>

  // 所有 NUM 描述符开始未使用
  for(int i = 0; i < NUM; i++){
    disk.free[i] = 1;
  }
}
    80001d7e:	60e2                	ld	ra,24(sp)
    80001d80:	6442                	ld	s0,16(sp)
    80001d82:	64a2                	ld	s1,8(sp)
    80001d84:	6105                	addi	sp,sp,32
    80001d86:	8082                	ret
  *R(VIRTIO_MMIO_STATUS) = status;
    80001d88:	100017b7          	lui	a5,0x10001
    80001d8c:	4705                	li	a4,1
    80001d8e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80001d90:	470d                	li	a4,3
    80001d92:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80001d94:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80001d96:	c7ffe737          	lui	a4,0xc7ffe
    80001d9a:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdde2f>
    80001d9e:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80001da0:	2701                	sext.w	a4,a4
    80001da2:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80001da4:	472d                	li	a4,11
    80001da6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80001da8:	473d                	li	a4,15
    80001daa:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80001dac:	6705                	lui	a4,0x1
    80001dae:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80001db0:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80001db4:	5bdc                	lw	a5,52(a5)
    80001db6:	2781                	sext.w	a5,a5
  if(max == 0){
    80001db8:	cbbd                	beqz	a5,80001e2e <virtio_disk_init+0x14e>
  if(max < NUM){
    80001dba:	471d                	li	a4,7
    80001dbc:	08f77263          	bgeu	a4,a5,80001e40 <virtio_disk_init+0x160>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80001dc0:	100014b7          	lui	s1,0x10001
    80001dc4:	47a1                	li	a5,8
    80001dc6:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80001dc8:	6609                	lui	a2,0x2
    80001dca:	4581                	li	a1,0
    80001dcc:	00015517          	auipc	a0,0x15
    80001dd0:	23450513          	addi	a0,a0,564 # 80017000 <disk>
    80001dd4:	00000097          	auipc	ra,0x0
    80001dd8:	176080e7          	jalr	374(ra) # 80001f4a <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80001ddc:	00015717          	auipc	a4,0x15
    80001de0:	22470713          	addi	a4,a4,548 # 80017000 <disk>
    80001de4:	00c75793          	srli	a5,a4,0xc
    80001de8:	2781                	sext.w	a5,a5
    80001dea:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virt_desc *) disk.pages;
    80001dec:	00017797          	auipc	a5,0x17
    80001df0:	21478793          	addi	a5,a5,532 # 80019000 <disk+0x2000>
    80001df4:	e398                	sd	a4,0(a5)
  disk.avail = (struct virt_avail *)(disk.pages + NUM*sizeof(struct virt_desc));
    80001df6:	00015717          	auipc	a4,0x15
    80001dfa:	28a70713          	addi	a4,a4,650 # 80017080 <disk+0x80>
    80001dfe:	e798                	sd	a4,8(a5)
  disk.used = (struct virt_used *) (disk.pages + PGSIZE);
    80001e00:	00016717          	auipc	a4,0x16
    80001e04:	20070713          	addi	a4,a4,512 # 80018000 <disk+0x1000>
    80001e08:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80001e0a:	4705                	li	a4,1
    80001e0c:	00e78c23          	sb	a4,24(a5)
    80001e10:	00e78ca3          	sb	a4,25(a5)
    80001e14:	00e78d23          	sb	a4,26(a5)
    80001e18:	00e78da3          	sb	a4,27(a5)
    80001e1c:	00e78e23          	sb	a4,28(a5)
    80001e20:	00e78ea3          	sb	a4,29(a5)
    80001e24:	00e78f23          	sb	a4,30(a5)
    80001e28:	00e78fa3          	sb	a4,31(a5)
  for(int i = 0; i < NUM; i++){
    80001e2c:	bf89                	j	80001d7e <virtio_disk_init+0x9e>
    printf("virtio disk has no queue 0");
    80001e2e:	00005517          	auipc	a0,0x5
    80001e32:	60250513          	addi	a0,a0,1538 # 80007430 <states.1524+0x218>
    80001e36:	ffffe097          	auipc	ra,0xffffe
    80001e3a:	484080e7          	jalr	1156(ra) # 800002ba <printf>
    return;
    80001e3e:	b781                	j	80001d7e <virtio_disk_init+0x9e>
    printf("virtio disk max queue too short");
    80001e40:	00005517          	auipc	a0,0x5
    80001e44:	61050513          	addi	a0,a0,1552 # 80007450 <states.1524+0x238>
    80001e48:	ffffe097          	auipc	ra,0xffffe
    80001e4c:	472080e7          	jalr	1138(ra) # 800002ba <printf>
    return;
    80001e50:	b73d                	j	80001d7e <virtio_disk_init+0x9e>

0000000080001e52 <virtio_disk_isr>:

void virtio_disk_isr()
{

  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80001e52:	10001737          	lui	a4,0x10001
    80001e56:	533c                	lw	a5,96(a4)
    80001e58:	8b8d                	andi	a5,a5,3
    80001e5a:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80001e5c:	0ff0000f          	fence

  while (disk.used_idx != disk.used->idx) {
    80001e60:	00017797          	auipc	a5,0x17
    80001e64:	1a078793          	addi	a5,a5,416 # 80019000 <disk+0x2000>
    80001e68:	6b94                	ld	a3,16(a5)
    80001e6a:	0a07d703          	lhu	a4,160(a5)
    80001e6e:	0026d783          	lhu	a5,2(a3)
    80001e72:	0cf70b63          	beq	a4,a5,80001f48 <virtio_disk_isr+0xf6>
{
    80001e76:	715d                	addi	sp,sp,-80
    80001e78:	e486                	sd	ra,72(sp)
    80001e7a:	e0a2                	sd	s0,64(sp)
    80001e7c:	fc26                	sd	s1,56(sp)
    80001e7e:	f84a                	sd	s2,48(sp)
    80001e80:	f44e                	sd	s3,40(sp)
    80001e82:	f052                	sd	s4,32(sp)
    80001e84:	ec56                	sd	s5,24(sp)
    80001e86:	e85a                	sd	s6,16(sp)
    80001e88:	e45e                	sd	s7,8(sp)
    80001e8a:	0880                	addi	s0,sp,80
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80001e8c:	00015917          	auipc	s2,0x15
    80001e90:	17490913          	addi	s2,s2,372 # 80017000 <disk>
    80001e94:	00017497          	auipc	s1,0x17
    80001e98:	16c48493          	addi	s1,s1,364 # 80019000 <disk+0x2000>
    if (disk.info[id].status != 0){
      printf("virtio_disk_intr status");
    80001e9c:	00005997          	auipc	s3,0x5
    80001ea0:	5d498993          	addi	s3,s3,1492 # 80007470 <states.1524+0x258>
    }
    struct buf *b = disk.info[id].b;
    if(b == 0){
      printf("id :%d\n",id);
    80001ea4:	00005a97          	auipc	s5,0x5
    80001ea8:	5e4a8a93          	addi	s5,s5,1508 # 80007488 <states.1524+0x270>
      panic("virtio_disk_isr: buf is empty");
    80001eac:	00005a17          	auipc	s4,0x5
    80001eb0:	5e4a0a13          	addi	s4,s4,1508 # 80007490 <states.1524+0x278>
    80001eb4:	a089                	j	80001ef6 <virtio_disk_isr+0xa4>
      printf("virtio_disk_intr status");
    80001eb6:	854e                	mv	a0,s3
    80001eb8:	ffffe097          	auipc	ra,0xffffe
    80001ebc:	402080e7          	jalr	1026(ra) # 800002ba <printf>
    struct buf *b = disk.info[id].b;
    80001ec0:	200b0793          	addi	a5,s6,512 # 2200 <_entry-0x7fffde00>
    80001ec4:	0792                	slli	a5,a5,0x4
    80001ec6:	97ca                	add	a5,a5,s2
    80001ec8:	0207bb83          	ld	s7,32(a5)
    if(b == 0){
    80001ecc:	040b8763          	beqz	s7,80001f1a <virtio_disk_isr+0xc8>
    }
    b->disk = 0;
    80001ed0:	000ba223          	sw	zero,4(s7)
    wakeup(b);
    80001ed4:	855e                	mv	a0,s7
    80001ed6:	ffffe097          	auipc	ra,0xffffe
    80001eda:	74c080e7          	jalr	1868(ra) # 80000622 <wakeup>
    disk.used_idx += 1;
    80001ede:	0a04d783          	lhu	a5,160(s1)
    80001ee2:	2785                	addiw	a5,a5,1
    80001ee4:	17c2                	slli	a5,a5,0x30
    80001ee6:	93c1                	srli	a5,a5,0x30
    80001ee8:	0af49023          	sh	a5,160(s1)
  while (disk.used_idx != disk.used->idx) {
    80001eec:	6898                	ld	a4,16(s1)
    80001eee:	00275703          	lhu	a4,2(a4) # 10001002 <_entry-0x6fffeffe>
    80001ef2:	04f70063          	beq	a4,a5,80001f32 <virtio_disk_isr+0xe0>
    __sync_synchronize();
    80001ef6:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80001efa:	6898                	ld	a4,16(s1)
    80001efc:	0a04d783          	lhu	a5,160(s1)
    80001f00:	8b9d                	andi	a5,a5,7
    80001f02:	078e                	slli	a5,a5,0x3
    80001f04:	97ba                	add	a5,a5,a4
    80001f06:	0047ab03          	lw	s6,4(a5)
    if (disk.info[id].status != 0){
    80001f0a:	200b0793          	addi	a5,s6,512
    80001f0e:	0792                	slli	a5,a5,0x4
    80001f10:	97ca                	add	a5,a5,s2
    80001f12:	0287c783          	lbu	a5,40(a5)
    80001f16:	d7cd                	beqz	a5,80001ec0 <virtio_disk_isr+0x6e>
    80001f18:	bf79                	j	80001eb6 <virtio_disk_isr+0x64>
      printf("id :%d\n",id);
    80001f1a:	85da                	mv	a1,s6
    80001f1c:	8556                	mv	a0,s5
    80001f1e:	ffffe097          	auipc	ra,0xffffe
    80001f22:	39c080e7          	jalr	924(ra) # 800002ba <printf>
      panic("virtio_disk_isr: buf is empty");
    80001f26:	8552                	mv	a0,s4
    80001f28:	ffffe097          	auipc	ra,0xffffe
    80001f2c:	55c080e7          	jalr	1372(ra) # 80000484 <panic>
    80001f30:	b745                	j	80001ed0 <virtio_disk_isr+0x7e>
  }

    80001f32:	60a6                	ld	ra,72(sp)
    80001f34:	6406                	ld	s0,64(sp)
    80001f36:	74e2                	ld	s1,56(sp)
    80001f38:	7942                	ld	s2,48(sp)
    80001f3a:	79a2                	ld	s3,40(sp)
    80001f3c:	7a02                	ld	s4,32(sp)
    80001f3e:	6ae2                	ld	s5,24(sp)
    80001f40:	6b42                	ld	s6,16(sp)
    80001f42:	6ba2                	ld	s7,8(sp)
    80001f44:	6161                	addi	sp,sp,80
    80001f46:	8082                	ret
    80001f48:	8082                	ret

0000000080001f4a <memset>:
#include "type.h"

char* memset(void *target,int val,int end){
    80001f4a:	1141                	addi	sp,sp,-16
    80001f4c:	e422                	sd	s0,8(sp)
    80001f4e:	0800                	addi	s0,sp,16
    char *upd = (char*) target;
    for(int i = 0;i < end; i++){
    80001f50:	00c05e63          	blez	a2,80001f6c <memset+0x22>
    80001f54:	87aa                	mv	a5,a0
    80001f56:	fff6071b          	addiw	a4,a2,-1
    80001f5a:	1702                	slli	a4,a4,0x20
    80001f5c:	9301                	srli	a4,a4,0x20
    80001f5e:	972a                	add	a4,a4,a0
        upd[i] = val;
    80001f60:	00b78023          	sb	a1,0(a5)
    for(int i = 0;i < end; i++){
    80001f64:	86be                	mv	a3,a5
    80001f66:	0785                	addi	a5,a5,1
    80001f68:	fee69ce3          	bne	a3,a4,80001f60 <memset+0x16>
    }
    return upd;
}
    80001f6c:	6422                	ld	s0,8(sp)
    80001f6e:	0141                	addi	sp,sp,16
    80001f70:	8082                	ret

0000000080001f72 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80001f72:	1141                	addi	sp,sp,-16
    80001f74:	e422                	sd	s0,8(sp)
    80001f76:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0){
    80001f78:	c215                	beqz	a2,80001f9c <memmove+0x2a>
    return dst;
  }
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80001f7a:	02a5e463          	bltu	a1,a0,80001fa2 <memmove+0x30>
    d += n;
    while(n-- > 0){
      *--d = *--s;
    }
  } else{
    while(n-- > 0){
    80001f7e:	fff6079b          	addiw	a5,a2,-1
    80001f82:	1782                	slli	a5,a5,0x20
    80001f84:	9381                	srli	a5,a5,0x20
    80001f86:	0785                	addi	a5,a5,1
    80001f88:	97ae                	add	a5,a5,a1
    80001f8a:	872a                	mv	a4,a0
      *d++ = *s++;
    80001f8c:	0585                	addi	a1,a1,1
    80001f8e:	0705                	addi	a4,a4,1
    80001f90:	fff5c683          	lbu	a3,-1(a1)
    80001f94:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0){
    80001f98:	fef59ae3          	bne	a1,a5,80001f8c <memmove+0x1a>
    }
  }
  return dst;
}
    80001f9c:	6422                	ld	s0,8(sp)
    80001f9e:	0141                	addi	sp,sp,16
    80001fa0:	8082                	ret
  if(s < d && s + n > d){
    80001fa2:	02061693          	slli	a3,a2,0x20
    80001fa6:	9281                	srli	a3,a3,0x20
    80001fa8:	00d58733          	add	a4,a1,a3
    80001fac:	fce579e3          	bgeu	a0,a4,80001f7e <memmove+0xc>
    d += n;
    80001fb0:	96aa                	add	a3,a3,a0
    while(n-- > 0){
    80001fb2:	fff6079b          	addiw	a5,a2,-1
    80001fb6:	1782                	slli	a5,a5,0x20
    80001fb8:	9381                	srli	a5,a5,0x20
    80001fba:	fff7c793          	not	a5,a5
    80001fbe:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80001fc0:	177d                	addi	a4,a4,-1
    80001fc2:	16fd                	addi	a3,a3,-1
    80001fc4:	00074603          	lbu	a2,0(a4)
    80001fc8:	00c68023          	sb	a2,0(a3)
    while(n-- > 0){
    80001fcc:	fee79ae3          	bne	a5,a4,80001fc0 <memmove+0x4e>
    80001fd0:	b7f1                	j	80001f9c <memmove+0x2a>

0000000080001fd2 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80001fd2:	1141                	addi	sp,sp,-16
    80001fd4:	e422                	sd	s0,8(sp)
    80001fd6:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80001fd8:	ce11                	beqz	a2,80001ff4 <strncmp+0x22>
    80001fda:	00054783          	lbu	a5,0(a0)
    80001fde:	cf89                	beqz	a5,80001ff8 <strncmp+0x26>
    80001fe0:	0005c703          	lbu	a4,0(a1)
    80001fe4:	00f71a63          	bne	a4,a5,80001ff8 <strncmp+0x26>
    n--, p++, q++;
    80001fe8:	367d                	addiw	a2,a2,-1
    80001fea:	0505                	addi	a0,a0,1
    80001fec:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80001fee:	f675                	bnez	a2,80001fda <strncmp+0x8>
  if(n == 0)
    return 0;
    80001ff0:	4501                	li	a0,0
    80001ff2:	a809                	j	80002004 <strncmp+0x32>
    80001ff4:	4501                	li	a0,0
    80001ff6:	a039                	j	80002004 <strncmp+0x32>
  if(n == 0)
    80001ff8:	ca09                	beqz	a2,8000200a <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80001ffa:	00054503          	lbu	a0,0(a0)
    80001ffe:	0005c783          	lbu	a5,0(a1)
    80002002:	9d1d                	subw	a0,a0,a5
}
    80002004:	6422                	ld	s0,8(sp)
    80002006:	0141                	addi	sp,sp,16
    80002008:	8082                	ret
    return 0;
    8000200a:	4501                	li	a0,0
    8000200c:	bfe5                	j	80002004 <strncmp+0x32>

000000008000200e <strlen>:

uint
strlen(const char *s)
{
    8000200e:	1141                	addi	sp,sp,-16
    80002010:	e422                	sd	s0,8(sp)
    80002012:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80002014:	00054783          	lbu	a5,0(a0)
    80002018:	cf91                	beqz	a5,80002034 <strlen+0x26>
    8000201a:	0505                	addi	a0,a0,1
    8000201c:	87aa                	mv	a5,a0
    8000201e:	4685                	li	a3,1
    80002020:	9e89                	subw	a3,a3,a0
    80002022:	00f6853b          	addw	a0,a3,a5
    80002026:	0785                	addi	a5,a5,1
    80002028:	fff7c703          	lbu	a4,-1(a5)
    8000202c:	fb7d                	bnez	a4,80002022 <strlen+0x14>
    ;
  return n;
}
    8000202e:	6422                	ld	s0,8(sp)
    80002030:	0141                	addi	sp,sp,16
    80002032:	8082                	ret
  for(n = 0; s[n]; n++)
    80002034:	4501                	li	a0,0
    80002036:	bfe5                	j	8000202e <strlen+0x20>

0000000080002038 <strncpy>:


char*
strncpy(char *s, const char *t, int n)
{
    80002038:	1141                	addi	sp,sp,-16
    8000203a:	e422                	sd	s0,8(sp)
    8000203c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    8000203e:	872a                	mv	a4,a0
    80002040:	8832                	mv	a6,a2
    80002042:	367d                	addiw	a2,a2,-1
    80002044:	01005963          	blez	a6,80002056 <strncpy+0x1e>
    80002048:	0705                	addi	a4,a4,1
    8000204a:	0005c783          	lbu	a5,0(a1)
    8000204e:	fef70fa3          	sb	a5,-1(a4)
    80002052:	0585                	addi	a1,a1,1
    80002054:	f7f5                	bnez	a5,80002040 <strncpy+0x8>
    ;
  while(n-- > 0)
    80002056:	86ba                	mv	a3,a4
    80002058:	00c05c63          	blez	a2,80002070 <strncpy+0x38>
    *s++ = 0;
    8000205c:	0685                	addi	a3,a3,1
    8000205e:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80002062:	fff6c793          	not	a5,a3
    80002066:	9fb9                	addw	a5,a5,a4
    80002068:	010787bb          	addw	a5,a5,a6
    8000206c:	fef048e3          	bgtz	a5,8000205c <strncpy+0x24>
  return os;
    80002070:	6422                	ld	s0,8(sp)
    80002072:	0141                	addi	sp,sp,16
    80002074:	8082                	ret

0000000080002076 <sleep_initlock>:
#include "spinlock.h"
#include "sleeplock.h"
#include "file.h"
#include "proc.h"

void sleep_initlock(struct sleeplock* sl,char* name){
    80002076:	1101                	addi	sp,sp,-32
    80002078:	ec06                	sd	ra,24(sp)
    8000207a:	e822                	sd	s0,16(sp)
    8000207c:	e426                	sd	s1,8(sp)
    8000207e:	e04a                	sd	s2,0(sp)
    80002080:	1000                	addi	s0,sp,32
    80002082:	84aa                	mv	s1,a0
    80002084:	892e                	mv	s2,a1
    initlock(&sl->splock,name);
    80002086:	0521                	addi	a0,a0,8
    80002088:	fffff097          	auipc	ra,0xfffff
    8000208c:	71c080e7          	jalr	1820(ra) # 800017a4 <initlock>
    sl->name = name;
    80002090:	0324b023          	sd	s2,32(s1)
    sl->locked = 0;
    80002094:	0004a023          	sw	zero,0(s1)
    sl->pid = 0;
    80002098:	0204a423          	sw	zero,40(s1)
}
    8000209c:	60e2                	ld	ra,24(sp)
    8000209e:	6442                	ld	s0,16(sp)
    800020a0:	64a2                	ld	s1,8(sp)
    800020a2:	6902                	ld	s2,0(sp)
    800020a4:	6105                	addi	sp,sp,32
    800020a6:	8082                	ret

00000000800020a8 <sleep_lock>:

void sleep_lock(struct sleeplock *sl){
    800020a8:	1101                	addi	sp,sp,-32
    800020aa:	ec06                	sd	ra,24(sp)
    800020ac:	e822                	sd	s0,16(sp)
    800020ae:	e426                	sd	s1,8(sp)
    800020b0:	e04a                	sd	s2,0(sp)
    800020b2:	1000                	addi	s0,sp,32
    800020b4:	84aa                	mv	s1,a0
    acquire(&sl->splock);
    800020b6:	00850913          	addi	s2,a0,8
    800020ba:	854a                	mv	a0,s2
    800020bc:	fffff097          	auipc	ra,0xfffff
    800020c0:	774080e7          	jalr	1908(ra) # 80001830 <acquire>
    while (sl->locked) {
    800020c4:	409c                	lw	a5,0(s1)
    800020c6:	cb89                	beqz	a5,800020d8 <sleep_lock+0x30>
        sleep(sl,&sl->splock);
    800020c8:	85ca                	mv	a1,s2
    800020ca:	8526                	mv	a0,s1
    800020cc:	fffff097          	auipc	ra,0xfffff
    800020d0:	95a080e7          	jalr	-1702(ra) # 80000a26 <sleep>
    while (sl->locked) {
    800020d4:	409c                	lw	a5,0(s1)
    800020d6:	fbed                	bnez	a5,800020c8 <sleep_lock+0x20>
    }
    sl->locked = 1;
    800020d8:	4785                	li	a5,1
    800020da:	c09c                	sw	a5,0(s1)
    sl->pid = myproc()->pid;
    800020dc:	ffffe097          	auipc	ra,0xffffe
    800020e0:	4c6080e7          	jalr	1222(ra) # 800005a2 <myproc>
    800020e4:	591c                	lw	a5,48(a0)
    800020e6:	d49c                	sw	a5,40(s1)
    release(&sl->splock);
    800020e8:	854a                	mv	a0,s2
    800020ea:	00000097          	auipc	ra,0x0
    800020ee:	808080e7          	jalr	-2040(ra) # 800018f2 <release>
}
    800020f2:	60e2                	ld	ra,24(sp)
    800020f4:	6442                	ld	s0,16(sp)
    800020f6:	64a2                	ld	s1,8(sp)
    800020f8:	6902                	ld	s2,0(sp)
    800020fa:	6105                	addi	sp,sp,32
    800020fc:	8082                	ret

00000000800020fe <sleep_unlock>:

void sleep_unlock(struct sleeplock *sl){
    800020fe:	1101                	addi	sp,sp,-32
    80002100:	ec06                	sd	ra,24(sp)
    80002102:	e822                	sd	s0,16(sp)
    80002104:	e426                	sd	s1,8(sp)
    80002106:	e04a                	sd	s2,0(sp)
    80002108:	1000                	addi	s0,sp,32
    8000210a:	84aa                	mv	s1,a0
    acquire(&sl->splock);
    8000210c:	00850913          	addi	s2,a0,8
    80002110:	854a                	mv	a0,s2
    80002112:	fffff097          	auipc	ra,0xfffff
    80002116:	71e080e7          	jalr	1822(ra) # 80001830 <acquire>
    sl->locked = 0;
    8000211a:	0004a023          	sw	zero,0(s1)
    sl->pid = 0;
    8000211e:	0204a423          	sw	zero,40(s1)
    wakeup(sl);
    80002122:	8526                	mv	a0,s1
    80002124:	ffffe097          	auipc	ra,0xffffe
    80002128:	4fe080e7          	jalr	1278(ra) # 80000622 <wakeup>
    release(&sl->splock);
    8000212c:	854a                	mv	a0,s2
    8000212e:	fffff097          	auipc	ra,0xfffff
    80002132:	7c4080e7          	jalr	1988(ra) # 800018f2 <release>
}
    80002136:	60e2                	ld	ra,24(sp)
    80002138:	6442                	ld	s0,16(sp)
    8000213a:	64a2                	ld	s1,8(sp)
    8000213c:	6902                	ld	s2,0(sp)
    8000213e:	6105                	addi	sp,sp,32
    80002140:	8082                	ret

0000000080002142 <holdingsleep>:

int holdingsleep(struct sleeplock *sl){
    80002142:	7179                	addi	sp,sp,-48
    80002144:	f406                	sd	ra,40(sp)
    80002146:	f022                	sd	s0,32(sp)
    80002148:	ec26                	sd	s1,24(sp)
    8000214a:	e84a                	sd	s2,16(sp)
    8000214c:	e44e                	sd	s3,8(sp)
    8000214e:	1800                	addi	s0,sp,48
    80002150:	84aa                	mv	s1,a0
    int r;
    acquire(&sl->splock);
    80002152:	00850913          	addi	s2,a0,8
    80002156:	854a                	mv	a0,s2
    80002158:	fffff097          	auipc	ra,0xfffff
    8000215c:	6d8080e7          	jalr	1752(ra) # 80001830 <acquire>
    r = sl->locked && (sl->pid == myproc()->pid);
    80002160:	409c                	lw	a5,0(s1)
    80002162:	ef99                	bnez	a5,80002180 <holdingsleep+0x3e>
    80002164:	4481                	li	s1,0
    release(&sl->splock);
    80002166:	854a                	mv	a0,s2
    80002168:	fffff097          	auipc	ra,0xfffff
    8000216c:	78a080e7          	jalr	1930(ra) # 800018f2 <release>
    return r;
    80002170:	8526                	mv	a0,s1
    80002172:	70a2                	ld	ra,40(sp)
    80002174:	7402                	ld	s0,32(sp)
    80002176:	64e2                	ld	s1,24(sp)
    80002178:	6942                	ld	s2,16(sp)
    8000217a:	69a2                	ld	s3,8(sp)
    8000217c:	6145                	addi	sp,sp,48
    8000217e:	8082                	ret
    r = sl->locked && (sl->pid == myproc()->pid);
    80002180:	0284a983          	lw	s3,40(s1)
    80002184:	ffffe097          	auipc	ra,0xffffe
    80002188:	41e080e7          	jalr	1054(ra) # 800005a2 <myproc>
    8000218c:	5904                	lw	s1,48(a0)
    8000218e:	413484b3          	sub	s1,s1,s3
    80002192:	0014b493          	seqz	s1,s1
    80002196:	bfc1                	j	80002166 <holdingsleep+0x24>

0000000080002198 <idup>:
    memmove(sb,f->data,sizeof(*sb));
    brelease(f);
}


struct inode* idup(struct inode *target){
    80002198:	1101                	addi	sp,sp,-32
    8000219a:	ec06                	sd	ra,24(sp)
    8000219c:	e822                	sd	s0,16(sp)
    8000219e:	e426                	sd	s1,8(sp)
    800021a0:	1000                	addi	s0,sp,32
    800021a2:	84aa                	mv	s1,a0
    acquire(&inodecache.slock);
    800021a4:	00018517          	auipc	a0,0x18
    800021a8:	e8450513          	addi	a0,a0,-380 # 8001a028 <inodecache>
    800021ac:	fffff097          	auipc	ra,0xfffff
    800021b0:	684080e7          	jalr	1668(ra) # 80001830 <acquire>
    target->ref++;
    800021b4:	449c                	lw	a5,8(s1)
    800021b6:	2785                	addiw	a5,a5,1
    800021b8:	c49c                	sw	a5,8(s1)
    release(&inodecache.slock);
    800021ba:	00018517          	auipc	a0,0x18
    800021be:	e6e50513          	addi	a0,a0,-402 # 8001a028 <inodecache>
    800021c2:	fffff097          	auipc	ra,0xfffff
    800021c6:	730080e7          	jalr	1840(ra) # 800018f2 <release>
    return target;
}
    800021ca:	8526                	mv	a0,s1
    800021cc:	60e2                	ld	ra,24(sp)
    800021ce:	6442                	ld	s0,16(sp)
    800021d0:	64a2                	ld	s1,8(sp)
    800021d2:	6105                	addi	sp,sp,32
    800021d4:	8082                	ret

00000000800021d6 <init_bcache>:
        panic("invalid file system");
    }
    // log init
}

void init_bcache() {
    800021d6:	7179                	addi	sp,sp,-48
    800021d8:	f406                	sd	ra,40(sp)
    800021da:	f022                	sd	s0,32(sp)
    800021dc:	ec26                	sd	s1,24(sp)
    800021de:	e84a                	sd	s2,16(sp)
    800021e0:	e44e                	sd	s3,8(sp)
    800021e2:	e052                	sd	s4,0(sp)
    800021e4:	1800                	addi	s0,sp,48
    initlock(&bcache.slock,"bcache");
    800021e6:	00005597          	auipc	a1,0x5
    800021ea:	2ca58593          	addi	a1,a1,714 # 800074b0 <states.1524+0x298>
    800021ee:	00019517          	auipc	a0,0x19
    800021f2:	f5250513          	addi	a0,a0,-174 # 8001b140 <bcache>
    800021f6:	fffff097          	auipc	ra,0xfffff
    800021fa:	5ae080e7          	jalr	1454(ra) # 800017a4 <initlock>
    bcache.head.prev = &bcache.head;
    800021fe:	0001d797          	auipc	a5,0x1d
    80002202:	f4278793          	addi	a5,a5,-190 # 8001f140 <bcache+0x4000>
    80002206:	0001d717          	auipc	a4,0x1d
    8000220a:	4d270713          	addi	a4,a4,1234 # 8001f6d8 <bcache+0x4598>
    8000220e:	5ee7b023          	sd	a4,1504(a5)
    bcache.head.next = &bcache.head;
    80002212:	5ee7b423          	sd	a4,1512(a5)

    struct buf *b;
    for(b = bcache.bufs; b < bcache.bufs+NBUF;b++){
    80002216:	00019497          	auipc	s1,0x19
    8000221a:	f4248493          	addi	s1,s1,-190 # 8001b158 <bcache+0x18>
        b->next = bcache.head.next;
    8000221e:	893e                	mv	s2,a5
        b->prev = &bcache.head;
    80002220:	89ba                	mv	s3,a4
        sleep_initlock(&b->sk, "buffer");
    80002222:	00005a17          	auipc	s4,0x5
    80002226:	296a0a13          	addi	s4,s4,662 # 800074b8 <states.1524+0x2a0>
        b->next = bcache.head.next;
    8000222a:	5e893783          	ld	a5,1512(s2)
    8000222e:	e8bc                	sd	a5,80(s1)
        b->prev = &bcache.head;
    80002230:	0534b423          	sd	s3,72(s1)
        sleep_initlock(&b->sk, "buffer");
    80002234:	85d2                	mv	a1,s4
    80002236:	01048513          	addi	a0,s1,16
    8000223a:	00000097          	auipc	ra,0x0
    8000223e:	e3c080e7          	jalr	-452(ra) # 80002076 <sleep_initlock>
        bcache.head.next->prev = b;
    80002242:	5e893783          	ld	a5,1512(s2)
    80002246:	e7a4                	sd	s1,72(a5)
        bcache.head.next = b;
    80002248:	5e993423          	sd	s1,1512(s2)
    for(b = bcache.bufs; b < bcache.bufs+NBUF;b++){
    8000224c:	45848493          	addi	s1,s1,1112
    80002250:	fd349de3          	bne	s1,s3,8000222a <init_bcache+0x54>
    }
}
    80002254:	70a2                	ld	ra,40(sp)
    80002256:	7402                	ld	s0,32(sp)
    80002258:	64e2                	ld	s1,24(sp)
    8000225a:	6942                	ld	s2,16(sp)
    8000225c:	69a2                	ld	s3,8(sp)
    8000225e:	6a02                	ld	s4,0(sp)
    80002260:	6145                	addi	sp,sp,48
    80002262:	8082                	ret

0000000080002264 <init_inodecache>:

void init_inodecache() {
    80002264:	7179                	addi	sp,sp,-48
    80002266:	f406                	sd	ra,40(sp)
    80002268:	f022                	sd	s0,32(sp)
    8000226a:	ec26                	sd	s1,24(sp)
    8000226c:	e84a                	sd	s2,16(sp)
    8000226e:	e44e                	sd	s3,8(sp)
    80002270:	1800                	addi	s0,sp,48
    initlock(&inodecache.slock,"inodecache");
    80002272:	00005597          	auipc	a1,0x5
    80002276:	24e58593          	addi	a1,a1,590 # 800074c0 <states.1524+0x2a8>
    8000227a:	00018517          	auipc	a0,0x18
    8000227e:	dae50513          	addi	a0,a0,-594 # 8001a028 <inodecache>
    80002282:	fffff097          	auipc	ra,0xfffff
    80002286:	522080e7          	jalr	1314(ra) # 800017a4 <initlock>
    for(int i = 0; i < INODES; i++){
    8000228a:	00018497          	auipc	s1,0x18
    8000228e:	dc648493          	addi	s1,s1,-570 # 8001a050 <inodecache+0x28>
    80002292:	00019997          	auipc	s3,0x19
    80002296:	ebe98993          	addi	s3,s3,-322 # 8001b150 <bcache+0x10>
        inodecache.inodes[i].ref = 0;
        inodecache.inodes[i].vaild = 0;
        sleep_initlock(&inodecache.inodes[i].splock,"inode");        
    8000229a:	00005917          	auipc	s2,0x5
    8000229e:	23690913          	addi	s2,s2,566 # 800074d0 <states.1524+0x2b8>
        inodecache.inodes[i].ref = 0;
    800022a2:	fe04ac23          	sw	zero,-8(s1)
        inodecache.inodes[i].vaild = 0;
    800022a6:	0204a823          	sw	zero,48(s1)
        sleep_initlock(&inodecache.inodes[i].splock,"inode");        
    800022aa:	85ca                	mv	a1,s2
    800022ac:	8526                	mv	a0,s1
    800022ae:	00000097          	auipc	ra,0x0
    800022b2:	dc8080e7          	jalr	-568(ra) # 80002076 <sleep_initlock>
    for(int i = 0; i < INODES; i++){
    800022b6:	08848493          	addi	s1,s1,136
    800022ba:	ff3494e3          	bne	s1,s3,800022a2 <init_inodecache+0x3e>
    }
}
    800022be:	70a2                	ld	ra,40(sp)
    800022c0:	7402                	ld	s0,32(sp)
    800022c2:	64e2                	ld	s1,24(sp)
    800022c4:	6942                	ld	s2,16(sp)
    800022c6:	69a2                	ld	s3,8(sp)
    800022c8:	6145                	addi	sp,sp,48
    800022ca:	8082                	ret

00000000800022cc <bread>:
    panic("bget panic..\n");
    return 0;
}


struct buf* bread(uint dev,uint blockno){
    800022cc:	7179                	addi	sp,sp,-48
    800022ce:	f406                	sd	ra,40(sp)
    800022d0:	f022                	sd	s0,32(sp)
    800022d2:	ec26                	sd	s1,24(sp)
    800022d4:	e84a                	sd	s2,16(sp)
    800022d6:	e44e                	sd	s3,8(sp)
    800022d8:	1800                	addi	s0,sp,48
    800022da:	89aa                	mv	s3,a0
    800022dc:	892e                	mv	s2,a1
    acquire(&bcache.slock);
    800022de:	00019517          	auipc	a0,0x19
    800022e2:	e6250513          	addi	a0,a0,-414 # 8001b140 <bcache>
    800022e6:	fffff097          	auipc	ra,0xfffff
    800022ea:	54a080e7          	jalr	1354(ra) # 80001830 <acquire>
    for(r = bcache.head.next; r != &bcache.head; r = r->next){
    800022ee:	0001d497          	auipc	s1,0x1d
    800022f2:	43a4b483          	ld	s1,1082(s1) # 8001f728 <bcache+0x45e8>
    800022f6:	0001d797          	auipc	a5,0x1d
    800022fa:	3e278793          	addi	a5,a5,994 # 8001f6d8 <bcache+0x4598>
    800022fe:	02f48f63          	beq	s1,a5,8000233c <bread+0x70>
    80002302:	873e                	mv	a4,a5
    80002304:	a021                	j	8000230c <bread+0x40>
    80002306:	68a4                	ld	s1,80(s1)
    80002308:	02e48a63          	beq	s1,a4,8000233c <bread+0x70>
        if(r->dev == dev && r->blockno == blockno){
    8000230c:	449c                	lw	a5,8(s1)
    8000230e:	ff379ce3          	bne	a5,s3,80002306 <bread+0x3a>
    80002312:	44dc                	lw	a5,12(s1)
    80002314:	ff2799e3          	bne	a5,s2,80002306 <bread+0x3a>
            r->refcnt++;
    80002318:	40bc                	lw	a5,64(s1)
    8000231a:	2785                	addiw	a5,a5,1
    8000231c:	c0bc                	sw	a5,64(s1)
            release(&bcache.slock);
    8000231e:	00019517          	auipc	a0,0x19
    80002322:	e2250513          	addi	a0,a0,-478 # 8001b140 <bcache>
    80002326:	fffff097          	auipc	ra,0xfffff
    8000232a:	5cc080e7          	jalr	1484(ra) # 800018f2 <release>
            sleep_lock(&r->sk);
    8000232e:	01048513          	addi	a0,s1,16
    80002332:	00000097          	auipc	ra,0x0
    80002336:	d76080e7          	jalr	-650(ra) # 800020a8 <sleep_lock>
            return r;
    8000233a:	a091                	j	8000237e <bread+0xb2>
    for(r = bcache.head.prev; r != &bcache.head; r = r->prev){
    8000233c:	0001d497          	auipc	s1,0x1d
    80002340:	3e44b483          	ld	s1,996(s1) # 8001f720 <bcache+0x45e0>
    80002344:	0001d797          	auipc	a5,0x1d
    80002348:	39478793          	addi	a5,a5,916 # 8001f6d8 <bcache+0x4598>
    8000234c:	00f48863          	beq	s1,a5,8000235c <bread+0x90>
    80002350:	873e                	mv	a4,a5
        if(r->refcnt == 0){
    80002352:	40bc                	lw	a5,64(s1)
    80002354:	cf9d                	beqz	a5,80002392 <bread+0xc6>
    for(r = bcache.head.prev; r != &bcache.head; r = r->prev){
    80002356:	64a4                	ld	s1,72(s1)
    80002358:	fee49de3          	bne	s1,a4,80002352 <bread+0x86>
    release(&bcache.slock);
    8000235c:	00019517          	auipc	a0,0x19
    80002360:	de450513          	addi	a0,a0,-540 # 8001b140 <bcache>
    80002364:	fffff097          	auipc	ra,0xfffff
    80002368:	58e080e7          	jalr	1422(ra) # 800018f2 <release>
    panic("bget panic..\n");
    8000236c:	00005517          	auipc	a0,0x5
    80002370:	16c50513          	addi	a0,a0,364 # 800074d8 <states.1524+0x2c0>
    80002374:	ffffe097          	auipc	ra,0xffffe
    80002378:	110080e7          	jalr	272(ra) # 80000484 <panic>
    return 0;
    8000237c:	4481                	li	s1,0
    struct buf *r;
    r = bget(dev,blockno);
    if(!r->vaild){
    8000237e:	409c                	lw	a5,0(s1)
    80002380:	c3a1                	beqz	a5,800023c0 <bread+0xf4>
        virt_disk_rw(r, 0);
        r->vaild = 1;
    }
    return r; 
}
    80002382:	8526                	mv	a0,s1
    80002384:	70a2                	ld	ra,40(sp)
    80002386:	7402                	ld	s0,32(sp)
    80002388:	64e2                	ld	s1,24(sp)
    8000238a:	6942                	ld	s2,16(sp)
    8000238c:	69a2                	ld	s3,8(sp)
    8000238e:	6145                	addi	sp,sp,48
    80002390:	8082                	ret
            r->refcnt = 1;
    80002392:	4785                	li	a5,1
    80002394:	c0bc                	sw	a5,64(s1)
            r->vaild = 0;
    80002396:	0004a023          	sw	zero,0(s1)
            r->dev =dev;
    8000239a:	0134a423          	sw	s3,8(s1)
            r->blockno = blockno;
    8000239e:	0124a623          	sw	s2,12(s1)
            release(&bcache.slock);
    800023a2:	00019517          	auipc	a0,0x19
    800023a6:	d9e50513          	addi	a0,a0,-610 # 8001b140 <bcache>
    800023aa:	fffff097          	auipc	ra,0xfffff
    800023ae:	548080e7          	jalr	1352(ra) # 800018f2 <release>
            sleep_lock(&r->sk);
    800023b2:	01048513          	addi	a0,s1,16
    800023b6:	00000097          	auipc	ra,0x0
    800023ba:	cf2080e7          	jalr	-782(ra) # 800020a8 <sleep_lock>
            return r;
    800023be:	b7c1                	j	8000237e <bread+0xb2>
        virt_disk_rw(r, 0);
    800023c0:	4581                	li	a1,0
    800023c2:	8526                	mv	a0,s1
    800023c4:	fffff097          	auipc	ra,0xfffff
    800023c8:	696080e7          	jalr	1686(ra) # 80001a5a <virt_disk_rw>
        r->vaild = 1;
    800023cc:	4785                	li	a5,1
    800023ce:	c09c                	sw	a5,0(s1)
    return r; 
    800023d0:	bf4d                	j	80002382 <bread+0xb6>

00000000800023d2 <iget>:
    }
    return tot;
}


struct inode* iget(uint dev,uint inum){
    800023d2:	7179                	addi	sp,sp,-48
    800023d4:	f406                	sd	ra,40(sp)
    800023d6:	f022                	sd	s0,32(sp)
    800023d8:	ec26                	sd	s1,24(sp)
    800023da:	e84a                	sd	s2,16(sp)
    800023dc:	e44e                	sd	s3,8(sp)
    800023de:	e052                	sd	s4,0(sp)
    800023e0:	1800                	addi	s0,sp,48
    800023e2:	89aa                	mv	s3,a0
    800023e4:	8a2e                	mv	s4,a1
    acquire(&inodecache.slock);
    800023e6:	00018517          	auipc	a0,0x18
    800023ea:	c4250513          	addi	a0,a0,-958 # 8001a028 <inodecache>
    800023ee:	fffff097          	auipc	ra,0xfffff
    800023f2:	442080e7          	jalr	1090(ra) # 80001830 <acquire>
    struct inode* i;
    struct inode* r = 0;
    800023f6:	4901                	li	s2,0
    for(i = &inodecache.inodes[0]; i < &inodecache.inodes[INODES]; i++){
    800023f8:	00018497          	auipc	s1,0x18
    800023fc:	c4848493          	addi	s1,s1,-952 # 8001a040 <inodecache+0x18>
    80002400:	00019697          	auipc	a3,0x19
    80002404:	d4068693          	addi	a3,a3,-704 # 8001b140 <bcache>
    80002408:	a801                	j	80002418 <iget+0x46>
        if(i->ref > 0 && i->dev == dev && i->inum == inum){
            i->ref++;
            release(&inodecache.slock);
            return i;
        }
        if(i->ref == 0 && r == 0){
    8000240a:	e399                	bnez	a5,80002410 <iget+0x3e>
    8000240c:	02090b63          	beqz	s2,80002442 <iget+0x70>
    for(i = &inodecache.inodes[0]; i < &inodecache.inodes[INODES]; i++){
    80002410:	08848493          	addi	s1,s1,136
    80002414:	02d48963          	beq	s1,a3,80002446 <iget+0x74>
        if(i->ref > 0 && i->dev == dev && i->inum == inum){
    80002418:	449c                	lw	a5,8(s1)
    8000241a:	fef058e3          	blez	a5,8000240a <iget+0x38>
    8000241e:	4098                	lw	a4,0(s1)
    80002420:	ff3718e3          	bne	a4,s3,80002410 <iget+0x3e>
    80002424:	40d8                	lw	a4,4(s1)
    80002426:	ff4715e3          	bne	a4,s4,80002410 <iget+0x3e>
            i->ref++;
    8000242a:	2785                	addiw	a5,a5,1
    8000242c:	c49c                	sw	a5,8(s1)
            release(&inodecache.slock);
    8000242e:	00018517          	auipc	a0,0x18
    80002432:	bfa50513          	addi	a0,a0,-1030 # 8001a028 <inodecache>
    80002436:	fffff097          	auipc	ra,0xfffff
    8000243a:	4bc080e7          	jalr	1212(ra) # 800018f2 <release>
            return i;
    8000243e:	8926                	mv	s2,s1
    80002440:	a035                	j	8000246c <iget+0x9a>
        if(i->ref == 0 && r == 0){
    80002442:	8926                	mv	s2,s1
    80002444:	b7f1                	j	80002410 <iget+0x3e>
            r = i;
        }
    }
    if(r == 0){
    80002446:	02090c63          	beqz	s2,8000247e <iget+0xac>
        panic("iget panic");
    }
    i = r;
    i->dev = dev;
    8000244a:	01392023          	sw	s3,0(s2)
    i->inum = inum;
    8000244e:	01492223          	sw	s4,4(s2)
    i->ref = 1;
    80002452:	4785                	li	a5,1
    80002454:	00f92423          	sw	a5,8(s2)
    i->vaild = 0;
    80002458:	04092023          	sw	zero,64(s2)
    release(&inodecache.slock);
    8000245c:	00018517          	auipc	a0,0x18
    80002460:	bcc50513          	addi	a0,a0,-1076 # 8001a028 <inodecache>
    80002464:	fffff097          	auipc	ra,0xfffff
    80002468:	48e080e7          	jalr	1166(ra) # 800018f2 <release>
    return i;
}
    8000246c:	854a                	mv	a0,s2
    8000246e:	70a2                	ld	ra,40(sp)
    80002470:	7402                	ld	s0,32(sp)
    80002472:	64e2                	ld	s1,24(sp)
    80002474:	6942                	ld	s2,16(sp)
    80002476:	69a2                	ld	s3,8(sp)
    80002478:	6a02                	ld	s4,0(sp)
    8000247a:	6145                	addi	sp,sp,48
    8000247c:	8082                	ret
        panic("iget panic");
    8000247e:	00005517          	auipc	a0,0x5
    80002482:	06a50513          	addi	a0,a0,106 # 800074e8 <states.1524+0x2d0>
    80002486:	ffffe097          	auipc	ra,0xffffe
    8000248a:	ffe080e7          	jalr	-2(ra) # 80000484 <panic>
    8000248e:	bf75                	j	8000244a <iget+0x78>

0000000080002490 <rooti>:

struct inode* rooti(){
    80002490:	1141                	addi	sp,sp,-16
    80002492:	e406                	sd	ra,8(sp)
    80002494:	e022                	sd	s0,0(sp)
    80002496:	0800                	addi	s0,sp,16
    return iget(ROOTDEV,ROOTINO);
    80002498:	4585                	li	a1,1
    8000249a:	4505                	li	a0,1
    8000249c:	00000097          	auipc	ra,0x0
    800024a0:	f36080e7          	jalr	-202(ra) # 800023d2 <iget>
}
    800024a4:	60a2                	ld	ra,8(sp)
    800024a6:	6402                	ld	s0,0(sp)
    800024a8:	0141                	addi	sp,sp,16
    800024aa:	8082                	ret

00000000800024ac <brelease>:
        }
    }
    return 0;    
}

void brelease(struct buf *b){
    800024ac:	1101                	addi	sp,sp,-32
    800024ae:	ec06                	sd	ra,24(sp)
    800024b0:	e822                	sd	s0,16(sp)
    800024b2:	e426                	sd	s1,8(sp)
    800024b4:	e04a                	sd	s2,0(sp)
    800024b6:	1000                	addi	s0,sp,32
    800024b8:	84aa                	mv	s1,a0
    if(!holdingsleep(&b->sk)){
    800024ba:	01050913          	addi	s2,a0,16
    800024be:	854a                	mv	a0,s2
    800024c0:	00000097          	auipc	ra,0x0
    800024c4:	c82080e7          	jalr	-894(ra) # 80002142 <holdingsleep>
    800024c8:	c92d                	beqz	a0,8000253a <brelease+0x8e>
        panic("brelease holdingsleep panic\n");
    }
    sleep_unlock(&b->sk);
    800024ca:	854a                	mv	a0,s2
    800024cc:	00000097          	auipc	ra,0x0
    800024d0:	c32080e7          	jalr	-974(ra) # 800020fe <sleep_unlock>

    acquire(&bcache.slock);
    800024d4:	00019517          	auipc	a0,0x19
    800024d8:	c6c50513          	addi	a0,a0,-916 # 8001b140 <bcache>
    800024dc:	fffff097          	auipc	ra,0xfffff
    800024e0:	354080e7          	jalr	852(ra) # 80001830 <acquire>

    b->refcnt--;
    800024e4:	40bc                	lw	a5,64(s1)
    800024e6:	37fd                	addiw	a5,a5,-1
    800024e8:	0007871b          	sext.w	a4,a5
    800024ec:	c0bc                	sw	a5,64(s1)
    if (b->refcnt == 0) {
    800024ee:	eb05                	bnez	a4,8000251e <brelease+0x72>
        b->next->prev = b->prev;
    800024f0:	68bc                	ld	a5,80(s1)
    800024f2:	64b8                	ld	a4,72(s1)
    800024f4:	e7b8                	sd	a4,72(a5)
        b->prev->next = b->next;
    800024f6:	64bc                	ld	a5,72(s1)
    800024f8:	68b8                	ld	a4,80(s1)
    800024fa:	ebb8                	sd	a4,80(a5)
        b->next = bcache.head.next;
    800024fc:	0001d797          	auipc	a5,0x1d
    80002500:	c4478793          	addi	a5,a5,-956 # 8001f140 <bcache+0x4000>
    80002504:	5e87b703          	ld	a4,1512(a5)
    80002508:	e8b8                	sd	a4,80(s1)
        b->prev = &bcache.head;
    8000250a:	0001d717          	auipc	a4,0x1d
    8000250e:	1ce70713          	addi	a4,a4,462 # 8001f6d8 <bcache+0x4598>
    80002512:	e4b8                	sd	a4,72(s1)
        bcache.head.next->prev = b;
    80002514:	5e87b703          	ld	a4,1512(a5)
    80002518:	e724                	sd	s1,72(a4)
        bcache.head.next = b;
    8000251a:	5e97b423          	sd	s1,1512(a5)
    }

    release(&bcache.slock);
    8000251e:	00019517          	auipc	a0,0x19
    80002522:	c2250513          	addi	a0,a0,-990 # 8001b140 <bcache>
    80002526:	fffff097          	auipc	ra,0xfffff
    8000252a:	3cc080e7          	jalr	972(ra) # 800018f2 <release>
}
    8000252e:	60e2                	ld	ra,24(sp)
    80002530:	6442                	ld	s0,16(sp)
    80002532:	64a2                	ld	s1,8(sp)
    80002534:	6902                	ld	s2,0(sp)
    80002536:	6105                	addi	sp,sp,32
    80002538:	8082                	ret
        panic("brelease holdingsleep panic\n");
    8000253a:	00005517          	auipc	a0,0x5
    8000253e:	fbe50513          	addi	a0,a0,-66 # 800074f8 <states.1524+0x2e0>
    80002542:	ffffe097          	auipc	ra,0xffffe
    80002546:	f42080e7          	jalr	-190(ra) # 80000484 <panic>
    8000254a:	b741                	j	800024ca <brelease+0x1e>

000000008000254c <initfs>:
void initfs(int dev){
    8000254c:	1101                	addi	sp,sp,-32
    8000254e:	ec06                	sd	ra,24(sp)
    80002550:	e822                	sd	s0,16(sp)
    80002552:	e426                	sd	s1,8(sp)
    80002554:	e04a                	sd	s2,0(sp)
    80002556:	1000                	addi	s0,sp,32
    struct buf *f = bread(dev,1);
    80002558:	4585                	li	a1,1
    8000255a:	00000097          	auipc	ra,0x0
    8000255e:	d72080e7          	jalr	-654(ra) # 800022cc <bread>
    80002562:	84aa                	mv	s1,a0
    memmove(sb,f->data,sizeof(*sb));
    80002564:	00018917          	auipc	s2,0x18
    80002568:	a9c90913          	addi	s2,s2,-1380 # 8001a000 <sb>
    8000256c:	02400613          	li	a2,36
    80002570:	05850593          	addi	a1,a0,88
    80002574:	854a                	mv	a0,s2
    80002576:	00000097          	auipc	ra,0x0
    8000257a:	9fc080e7          	jalr	-1540(ra) # 80001f72 <memmove>
    brelease(f);
    8000257e:	8526                	mv	a0,s1
    80002580:	00000097          	auipc	ra,0x0
    80002584:	f2c080e7          	jalr	-212(ra) # 800024ac <brelease>
    if(sb.magic != FSMAGIC){
    80002588:	00092703          	lw	a4,0(s2)
    8000258c:	102037b7          	lui	a5,0x10203
    80002590:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80002594:	00f71863          	bne	a4,a5,800025a4 <initfs+0x58>
}
    80002598:	60e2                	ld	ra,24(sp)
    8000259a:	6442                	ld	s0,16(sp)
    8000259c:	64a2                	ld	s1,8(sp)
    8000259e:	6902                	ld	s2,0(sp)
    800025a0:	6105                	addi	sp,sp,32
    800025a2:	8082                	ret
        panic("invalid file system");
    800025a4:	00005517          	auipc	a0,0x5
    800025a8:	f7450513          	addi	a0,a0,-140 # 80007518 <states.1524+0x300>
    800025ac:	ffffe097          	auipc	ra,0xffffe
    800025b0:	ed8080e7          	jalr	-296(ra) # 80000484 <panic>
}
    800025b4:	b7d5                	j	80002598 <initfs+0x4c>

00000000800025b6 <balloc>:
static uint balloc(uint dev){
    800025b6:	715d                	addi	sp,sp,-80
    800025b8:	e486                	sd	ra,72(sp)
    800025ba:	e0a2                	sd	s0,64(sp)
    800025bc:	fc26                	sd	s1,56(sp)
    800025be:	f84a                	sd	s2,48(sp)
    800025c0:	f44e                	sd	s3,40(sp)
    800025c2:	f052                	sd	s4,32(sp)
    800025c4:	ec56                	sd	s5,24(sp)
    800025c6:	e85a                	sd	s6,16(sp)
    800025c8:	e45e                	sd	s7,8(sp)
    800025ca:	e062                	sd	s8,0(sp)
    800025cc:	0880                	addi	s0,sp,80
    for(int b = 0; b < sb.size; b += BPB){
    800025ce:	00018797          	auipc	a5,0x18
    800025d2:	a367a783          	lw	a5,-1482(a5) # 8001a004 <sb+0x4>
    800025d6:	cfcd                	beqz	a5,80002690 <balloc+0xda>
    800025d8:	8b2a                	mv	s6,a0
    800025da:	4a01                	li	s4,0
        struct buf *bp = bread(dev,BMAPBLOCK(b,sb));
    800025dc:	00018a97          	auipc	s5,0x18
    800025e0:	a24a8a93          	addi	s5,s5,-1500 # 8001a000 <sb>
        for(int bi = 0; bi < BPB && b + bi < sb.size;bi++){
    800025e4:	4b81                	li	s7,0
            int m = 1 << (bi % 8);
    800025e6:	4905                	li	s2,1
        for(int bi = 0; bi < BPB && b + bi < sb.size;bi++){
    800025e8:	6989                	lui	s3,0x2
    for(int b = 0; b < sb.size; b += BPB){
    800025ea:	6c09                	lui	s8,0x2
    800025ec:	a091                	j	80002630 <balloc+0x7a>
                bp->data[bi/8] |= m;
    800025ee:	972a                	add	a4,a4,a0
    800025f0:	8fd5                	or	a5,a5,a3
    800025f2:	04f70c23          	sb	a5,88(a4)
                brelease(bp);
    800025f6:	00000097          	auipc	ra,0x0
    800025fa:	eb6080e7          	jalr	-330(ra) # 800024ac <brelease>
}
    800025fe:	8526                	mv	a0,s1
    80002600:	60a6                	ld	ra,72(sp)
    80002602:	6406                	ld	s0,64(sp)
    80002604:	74e2                	ld	s1,56(sp)
    80002606:	7942                	ld	s2,48(sp)
    80002608:	79a2                	ld	s3,40(sp)
    8000260a:	7a02                	ld	s4,32(sp)
    8000260c:	6ae2                	ld	s5,24(sp)
    8000260e:	6b42                	ld	s6,16(sp)
    80002610:	6ba2                	ld	s7,8(sp)
    80002612:	6c02                	ld	s8,0(sp)
    80002614:	6161                	addi	sp,sp,80
    80002616:	8082                	ret
        brelease(bp);
    80002618:	00000097          	auipc	ra,0x0
    8000261c:	e94080e7          	jalr	-364(ra) # 800024ac <brelease>
    for(int b = 0; b < sb.size; b += BPB){
    80002620:	014c07bb          	addw	a5,s8,s4
    80002624:	00078a1b          	sext.w	s4,a5
    80002628:	004aa703          	lw	a4,4(s5)
    8000262c:	06ea7263          	bgeu	s4,a4,80002690 <balloc+0xda>
        struct buf *bp = bread(dev,BMAPBLOCK(b,sb));
    80002630:	41fa579b          	sraiw	a5,s4,0x1f
    80002634:	0137d79b          	srliw	a5,a5,0x13
    80002638:	014787bb          	addw	a5,a5,s4
    8000263c:	40d7d79b          	sraiw	a5,a5,0xd
    80002640:	01caa583          	lw	a1,28(s5)
    80002644:	9dbd                	addw	a1,a1,a5
    80002646:	855a                	mv	a0,s6
    80002648:	00000097          	auipc	ra,0x0
    8000264c:	c84080e7          	jalr	-892(ra) # 800022cc <bread>
        for(int bi = 0; bi < BPB && b + bi < sb.size;bi++){
    80002650:	004aa803          	lw	a6,4(s5)
    80002654:	000a049b          	sext.w	s1,s4
    80002658:	865e                	mv	a2,s7
    8000265a:	fb04ffe3          	bgeu	s1,a6,80002618 <balloc+0x62>
            int m = 1 << (bi % 8);
    8000265e:	41f6579b          	sraiw	a5,a2,0x1f
    80002662:	01d7d69b          	srliw	a3,a5,0x1d
    80002666:	00c6873b          	addw	a4,a3,a2
    8000266a:	00777793          	andi	a5,a4,7
    8000266e:	9f95                	subw	a5,a5,a3
    80002670:	00f917bb          	sllw	a5,s2,a5
            if((bp->data[bi/8] & m) == 0){
    80002674:	4037571b          	sraiw	a4,a4,0x3
    80002678:	00e506b3          	add	a3,a0,a4
    8000267c:	0586c683          	lbu	a3,88(a3)
    80002680:	00d7f5b3          	and	a1,a5,a3
    80002684:	d5ad                	beqz	a1,800025ee <balloc+0x38>
        for(int bi = 0; bi < BPB && b + bi < sb.size;bi++){
    80002686:	2605                	addiw	a2,a2,1
    80002688:	2485                	addiw	s1,s1,1
    8000268a:	fd3618e3          	bne	a2,s3,8000265a <balloc+0xa4>
    8000268e:	b769                	j	80002618 <balloc+0x62>
    panic("balloc panic...\n");
    80002690:	00005517          	auipc	a0,0x5
    80002694:	ea050513          	addi	a0,a0,-352 # 80007530 <states.1524+0x318>
    80002698:	ffffe097          	auipc	ra,0xffffe
    8000269c:	dec080e7          	jalr	-532(ra) # 80000484 <panic>
    return -1;
    800026a0:	54fd                	li	s1,-1
    800026a2:	bfb1                	j	800025fe <balloc+0x48>

00000000800026a4 <bmap>:
static uint bmap(struct inode* ip,uint n){
    800026a4:	7179                	addi	sp,sp,-48
    800026a6:	f406                	sd	ra,40(sp)
    800026a8:	f022                	sd	s0,32(sp)
    800026aa:	ec26                	sd	s1,24(sp)
    800026ac:	e84a                	sd	s2,16(sp)
    800026ae:	e44e                	sd	s3,8(sp)
    800026b0:	e052                	sd	s4,0(sp)
    800026b2:	1800                	addi	s0,sp,48
    800026b4:	892a                	mv	s2,a0
    if(n < NDIRECT){
    800026b6:	47ad                	li	a5,11
    800026b8:	04b7fe63          	bgeu	a5,a1,80002714 <bmap+0x70>
    n -= NDIRECT;
    800026bc:	ff45849b          	addiw	s1,a1,-12
    800026c0:	0004871b          	sext.w	a4,s1
    if(n < NINDIRECT){
    800026c4:	0ff00793          	li	a5,255
    800026c8:	08e7ee63          	bltu	a5,a4,80002764 <bmap+0xc0>
        if((addr = ip->addrs[NDIRECT]) == 0){
    800026cc:	08052583          	lw	a1,128(a0)
    800026d0:	c5ad                	beqz	a1,8000273a <bmap+0x96>
        struct buf *bp = bread(ip->dev, addr);
    800026d2:	00092503          	lw	a0,0(s2)
    800026d6:	00000097          	auipc	ra,0x0
    800026da:	bf6080e7          	jalr	-1034(ra) # 800022cc <bread>
    800026de:	8a2a                	mv	s4,a0
        uint *a = (uint*)bp->data;
    800026e0:	05850793          	addi	a5,a0,88
        if((addr = a[n]) == 0){
    800026e4:	02049593          	slli	a1,s1,0x20
    800026e8:	9181                	srli	a1,a1,0x20
    800026ea:	058a                	slli	a1,a1,0x2
    800026ec:	00b784b3          	add	s1,a5,a1
    800026f0:	0004a983          	lw	s3,0(s1)
    800026f4:	04098d63          	beqz	s3,8000274e <bmap+0xaa>
        brelease(bp);
    800026f8:	8552                	mv	a0,s4
    800026fa:	00000097          	auipc	ra,0x0
    800026fe:	db2080e7          	jalr	-590(ra) # 800024ac <brelease>
}
    80002702:	854e                	mv	a0,s3
    80002704:	70a2                	ld	ra,40(sp)
    80002706:	7402                	ld	s0,32(sp)
    80002708:	64e2                	ld	s1,24(sp)
    8000270a:	6942                	ld	s2,16(sp)
    8000270c:	69a2                	ld	s3,8(sp)
    8000270e:	6a02                	ld	s4,0(sp)
    80002710:	6145                	addi	sp,sp,48
    80002712:	8082                	ret
        if((addr = ip->addrs[n]) == 0){
    80002714:	02059493          	slli	s1,a1,0x20
    80002718:	9081                	srli	s1,s1,0x20
    8000271a:	048a                	slli	s1,s1,0x2
    8000271c:	94aa                	add	s1,s1,a0
    8000271e:	0504a983          	lw	s3,80(s1)
    80002722:	fe0990e3          	bnez	s3,80002702 <bmap+0x5e>
            addr = ip->addrs[n] = balloc(ip->dev);
    80002726:	4108                	lw	a0,0(a0)
    80002728:	00000097          	auipc	ra,0x0
    8000272c:	e8e080e7          	jalr	-370(ra) # 800025b6 <balloc>
    80002730:	0005099b          	sext.w	s3,a0
    80002734:	0534a823          	sw	s3,80(s1)
    80002738:	b7e9                	j	80002702 <bmap+0x5e>
            ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    8000273a:	4108                	lw	a0,0(a0)
    8000273c:	00000097          	auipc	ra,0x0
    80002740:	e7a080e7          	jalr	-390(ra) # 800025b6 <balloc>
    80002744:	0005059b          	sext.w	a1,a0
    80002748:	08b92023          	sw	a1,128(s2)
    8000274c:	b759                	j	800026d2 <bmap+0x2e>
            a[n] = addr = balloc(ip->dev);
    8000274e:	00092503          	lw	a0,0(s2)
    80002752:	00000097          	auipc	ra,0x0
    80002756:	e64080e7          	jalr	-412(ra) # 800025b6 <balloc>
    8000275a:	0005099b          	sext.w	s3,a0
    8000275e:	0134a023          	sw	s3,0(s1)
    80002762:	bf59                	j	800026f8 <bmap+0x54>
    panic("bmap panic...\n");
    80002764:	00005517          	auipc	a0,0x5
    80002768:	de450513          	addi	a0,a0,-540 # 80007548 <states.1524+0x330>
    8000276c:	ffffe097          	auipc	ra,0xffffe
    80002770:	d18080e7          	jalr	-744(ra) # 80000484 <panic>
    return 0;
    80002774:	4981                	li	s3,0
    80002776:	b771                	j	80002702 <bmap+0x5e>

0000000080002778 <readi>:
int readi(struct inode* ip,int user_dst,uint64 dst,uint off,uint n){
    80002778:	7119                	addi	sp,sp,-128
    8000277a:	fc86                	sd	ra,120(sp)
    8000277c:	f8a2                	sd	s0,112(sp)
    8000277e:	f4a6                	sd	s1,104(sp)
    80002780:	f0ca                	sd	s2,96(sp)
    80002782:	ecce                	sd	s3,88(sp)
    80002784:	e8d2                	sd	s4,80(sp)
    80002786:	e4d6                	sd	s5,72(sp)
    80002788:	e0da                	sd	s6,64(sp)
    8000278a:	fc5e                	sd	s7,56(sp)
    8000278c:	f862                	sd	s8,48(sp)
    8000278e:	f466                	sd	s9,40(sp)
    80002790:	f06a                	sd	s10,32(sp)
    80002792:	ec6e                	sd	s11,24(sp)
    80002794:	0100                	addi	s0,sp,128
    80002796:	f8b43423          	sd	a1,-120(s0)
    if(off > ip->size || off + n < off) {
    8000279a:	457c                	lw	a5,76(a0)
    8000279c:	0cd7ee63          	bltu	a5,a3,80002878 <readi+0x100>
    800027a0:	8baa                	mv	s7,a0
    800027a2:	89b2                	mv	s3,a2
    800027a4:	8b3a                	mv	s6,a4
    800027a6:	9f35                	addw	a4,a4,a3
        return 0;
    800027a8:	4501                	li	a0,0
    if(off > ip->size || off + n < off) {
    800027aa:	0ad76663          	bltu	a4,a3,80002856 <readi+0xde>
    if(off + n > ip->size) {
    800027ae:	00e7f463          	bgeu	a5,a4,800027b6 <readi+0x3e>
        n = ip->size - off;
    800027b2:	40d78b3b          	subw	s6,a5,a3
    for(tot = 0; tot < n; tot+=m,dst+=m){
    800027b6:	0a0b0f63          	beqz	s6,80002874 <readi+0xfc>
        b = bread(ip->dev,bmap(ip,off/BSIZE));
    800027ba:	00a6dd9b          	srliw	s11,a3,0xa
    for(tot = 0; tot < n; tot+=m,dst+=m){
    800027be:	4901                	li	s2,0
        m = min(n - tot,BSIZE - off % BSIZE);
    800027c0:	3ff6f693          	andi	a3,a3,1023
    800027c4:	40000793          	li	a5,1024
    800027c8:	9f95                	subw	a5,a5,a3
    800027ca:	00078d1b          	sext.w	s10,a5
    800027ce:	f8f42223          	sw	a5,-124(s0)
        if(either_copyout(user_dst,dst,b->data + (off % BSIZE),m) == -1){
    800027d2:	02069a93          	slli	s5,a3,0x20
    800027d6:	020ada93          	srli	s5,s5,0x20
    800027da:	5cfd                	li	s9,-1
    800027dc:	a825                	j	80002814 <readi+0x9c>
    800027de:	020a1c13          	slli	s8,s4,0x20
    800027e2:	020c5c13          	srli	s8,s8,0x20
    800027e6:	05848613          	addi	a2,s1,88
    800027ea:	86e2                	mv	a3,s8
    800027ec:	9656                	add	a2,a2,s5
    800027ee:	85ce                	mv	a1,s3
    800027f0:	f8843503          	ld	a0,-120(s0)
    800027f4:	00001097          	auipc	ra,0x1
    800027f8:	354080e7          	jalr	852(ra) # 80003b48 <either_copyout>
    800027fc:	05950563          	beq	a0,s9,80002846 <readi+0xce>
        brelease(b);
    80002800:	8526                	mv	a0,s1
    80002802:	00000097          	auipc	ra,0x0
    80002806:	caa080e7          	jalr	-854(ra) # 800024ac <brelease>
    for(tot = 0; tot < n; tot+=m,dst+=m){
    8000280a:	012a093b          	addw	s2,s4,s2
    8000280e:	99e2                	add	s3,s3,s8
    80002810:	05697163          	bgeu	s2,s6,80002852 <readi+0xda>
        b = bread(ip->dev,bmap(ip,off/BSIZE));
    80002814:	000ba483          	lw	s1,0(s7)
    80002818:	85ee                	mv	a1,s11
    8000281a:	855e                	mv	a0,s7
    8000281c:	00000097          	auipc	ra,0x0
    80002820:	e88080e7          	jalr	-376(ra) # 800026a4 <bmap>
    80002824:	0005059b          	sext.w	a1,a0
    80002828:	8526                	mv	a0,s1
    8000282a:	00000097          	auipc	ra,0x0
    8000282e:	aa2080e7          	jalr	-1374(ra) # 800022cc <bread>
    80002832:	84aa                	mv	s1,a0
        m = min(n - tot,BSIZE - off % BSIZE);
    80002834:	412b07bb          	subw	a5,s6,s2
    80002838:	8a3e                	mv	s4,a5
    8000283a:	2781                	sext.w	a5,a5
    8000283c:	fafd71e3          	bgeu	s10,a5,800027de <readi+0x66>
    80002840:	f8442a03          	lw	s4,-124(s0)
    80002844:	bf69                	j	800027de <readi+0x66>
            brelease(b);
    80002846:	8526                	mv	a0,s1
    80002848:	00000097          	auipc	ra,0x0
    8000284c:	c64080e7          	jalr	-924(ra) # 800024ac <brelease>
            tot = -1;
    80002850:	597d                	li	s2,-1
    return tot;
    80002852:	0009051b          	sext.w	a0,s2
}
    80002856:	70e6                	ld	ra,120(sp)
    80002858:	7446                	ld	s0,112(sp)
    8000285a:	74a6                	ld	s1,104(sp)
    8000285c:	7906                	ld	s2,96(sp)
    8000285e:	69e6                	ld	s3,88(sp)
    80002860:	6a46                	ld	s4,80(sp)
    80002862:	6aa6                	ld	s5,72(sp)
    80002864:	6b06                	ld	s6,64(sp)
    80002866:	7be2                	ld	s7,56(sp)
    80002868:	7c42                	ld	s8,48(sp)
    8000286a:	7ca2                	ld	s9,40(sp)
    8000286c:	7d02                	ld	s10,32(sp)
    8000286e:	6de2                	ld	s11,24(sp)
    80002870:	6109                	addi	sp,sp,128
    80002872:	8082                	ret
    for(tot = 0; tot < n; tot+=m,dst+=m){
    80002874:	895a                	mv	s2,s6
    80002876:	bff1                	j	80002852 <readi+0xda>
        return 0;
    80002878:	4501                	li	a0,0
    8000287a:	bff1                	j	80002856 <readi+0xde>

000000008000287c <inodeByName>:
    for(off = 0; off < ip->size; off += sizeof(de)){
    8000287c:	457c                	lw	a5,76(a0)
    8000287e:	c7c1                	beqz	a5,80002906 <inodeByName+0x8a>
struct inode* inodeByName(struct inode* ip,char* name){
    80002880:	7139                	addi	sp,sp,-64
    80002882:	fc06                	sd	ra,56(sp)
    80002884:	f822                	sd	s0,48(sp)
    80002886:	f426                	sd	s1,40(sp)
    80002888:	f04a                	sd	s2,32(sp)
    8000288a:	ec4e                	sd	s3,24(sp)
    8000288c:	e852                	sd	s4,16(sp)
    8000288e:	0080                	addi	s0,sp,64
    80002890:	892a                	mv	s2,a0
    80002892:	89ae                	mv	s3,a1
    for(off = 0; off < ip->size; off += sizeof(de)){
    80002894:	4481                	li	s1,0
            panic("inodeByName panic...\n");
    80002896:	00005a17          	auipc	s4,0x5
    8000289a:	cc2a0a13          	addi	s4,s4,-830 # 80007558 <states.1524+0x340>
    8000289e:	a025                	j	800028c6 <inodeByName+0x4a>
    800028a0:	8552                	mv	a0,s4
    800028a2:	ffffe097          	auipc	ra,0xffffe
    800028a6:	be2080e7          	jalr	-1054(ra) # 80000484 <panic>
        if(strncmp(name,de.name,DIRSIZ) == 0){
    800028aa:	4639                	li	a2,14
    800028ac:	fc240593          	addi	a1,s0,-62
    800028b0:	854e                	mv	a0,s3
    800028b2:	fffff097          	auipc	ra,0xfffff
    800028b6:	720080e7          	jalr	1824(ra) # 80001fd2 <strncmp>
    800028ba:	c505                	beqz	a0,800028e2 <inodeByName+0x66>
    for(off = 0; off < ip->size; off += sizeof(de)){
    800028bc:	24c1                	addiw	s1,s1,16
    800028be:	04c92783          	lw	a5,76(s2)
    800028c2:	04f4f063          	bgeu	s1,a5,80002902 <inodeByName+0x86>
        if(readi(ip,0,(uint64)&de,off,sizeof(de)) != sizeof(de)){
    800028c6:	4741                	li	a4,16
    800028c8:	86a6                	mv	a3,s1
    800028ca:	fc040613          	addi	a2,s0,-64
    800028ce:	4581                	li	a1,0
    800028d0:	854a                	mv	a0,s2
    800028d2:	00000097          	auipc	ra,0x0
    800028d6:	ea6080e7          	jalr	-346(ra) # 80002778 <readi>
    800028da:	47c1                	li	a5,16
    800028dc:	fcf507e3          	beq	a0,a5,800028aa <inodeByName+0x2e>
    800028e0:	b7c1                	j	800028a0 <inodeByName+0x24>
            return iget(ip->dev,de.inum);
    800028e2:	fc045583          	lhu	a1,-64(s0)
    800028e6:	00092503          	lw	a0,0(s2)
    800028ea:	00000097          	auipc	ra,0x0
    800028ee:	ae8080e7          	jalr	-1304(ra) # 800023d2 <iget>
}
    800028f2:	70e2                	ld	ra,56(sp)
    800028f4:	7442                	ld	s0,48(sp)
    800028f6:	74a2                	ld	s1,40(sp)
    800028f8:	7902                	ld	s2,32(sp)
    800028fa:	69e2                	ld	s3,24(sp)
    800028fc:	6a42                	ld	s4,16(sp)
    800028fe:	6121                	addi	sp,sp,64
    80002900:	8082                	ret
    return 0;    
    80002902:	4501                	li	a0,0
    80002904:	b7fd                	j	800028f2 <inodeByName+0x76>
    80002906:	4501                	li	a0,0
}
    80002908:	8082                	ret

000000008000290a <bfree>:
        brelease(b);
        i->vaild = 0;
    }
}

static void bfree(int dev,uint b){
    8000290a:	7179                	addi	sp,sp,-48
    8000290c:	f406                	sd	ra,40(sp)
    8000290e:	f022                	sd	s0,32(sp)
    80002910:	ec26                	sd	s1,24(sp)
    80002912:	e84a                	sd	s2,16(sp)
    80002914:	e44e                	sd	s3,8(sp)
    80002916:	1800                	addi	s0,sp,48
    80002918:	84ae                	mv	s1,a1
    struct buf *bp = bread(dev,BBLOCK(b,sb));
    8000291a:	00d5d59b          	srliw	a1,a1,0xd
    8000291e:	00017797          	auipc	a5,0x17
    80002922:	6fe7a783          	lw	a5,1790(a5) # 8001a01c <sb+0x1c>
    80002926:	9dbd                	addw	a1,a1,a5
    80002928:	00000097          	auipc	ra,0x0
    8000292c:	9a4080e7          	jalr	-1628(ra) # 800022cc <bread>
    80002930:	89aa                	mv	s3,a0
    int bi = b % BPB;
    int m = 1 << (bi % 8);
    80002932:	0074f793          	andi	a5,s1,7
    80002936:	4905                	li	s2,1
    80002938:	00f9193b          	sllw	s2,s2,a5
    if((bp->data[bi/8] & m) == 0){
    8000293c:	14ce                	slli	s1,s1,0x33
    8000293e:	90d9                	srli	s1,s1,0x36
    80002940:	009507b3          	add	a5,a0,s1
    80002944:	0587c783          	lbu	a5,88(a5)
    80002948:	00f977b3          	and	a5,s2,a5
    8000294c:	c795                	beqz	a5,80002978 <bfree+0x6e>
        panic("freeing free block");
    }
    bp->data[bi/8] &= ~m;
    8000294e:	94ce                	add	s1,s1,s3
    80002950:	fff94913          	not	s2,s2
    80002954:	0584c783          	lbu	a5,88(s1)
    80002958:	00f97933          	and	s2,s2,a5
    8000295c:	05248c23          	sb	s2,88(s1)
    // TODO log write
    brelease(bp);
    80002960:	854e                	mv	a0,s3
    80002962:	00000097          	auipc	ra,0x0
    80002966:	b4a080e7          	jalr	-1206(ra) # 800024ac <brelease>
}
    8000296a:	70a2                	ld	ra,40(sp)
    8000296c:	7402                	ld	s0,32(sp)
    8000296e:	64e2                	ld	s1,24(sp)
    80002970:	6942                	ld	s2,16(sp)
    80002972:	69a2                	ld	s3,8(sp)
    80002974:	6145                	addi	sp,sp,48
    80002976:	8082                	ret
        panic("freeing free block");
    80002978:	00005517          	auipc	a0,0x5
    8000297c:	bf850513          	addi	a0,a0,-1032 # 80007570 <states.1524+0x358>
    80002980:	ffffe097          	auipc	ra,0xffffe
    80002984:	b04080e7          	jalr	-1276(ra) # 80000484 <panic>
    80002988:	b7d9                	j	8000294e <bfree+0x44>

000000008000298a <bwrite>:
void bwrite(struct buf *b){
    8000298a:	1101                	addi	sp,sp,-32
    8000298c:	ec06                	sd	ra,24(sp)
    8000298e:	e822                	sd	s0,16(sp)
    80002990:	e426                	sd	s1,8(sp)
    80002992:	1000                	addi	s0,sp,32
    80002994:	84aa                	mv	s1,a0
    if(!holdingsleep(&b->sk)){
    80002996:	0541                	addi	a0,a0,16
    80002998:	fffff097          	auipc	ra,0xfffff
    8000299c:	7aa080e7          	jalr	1962(ra) # 80002142 <holdingsleep>
    800029a0:	cd01                	beqz	a0,800029b8 <bwrite+0x2e>
    virt_disk_rw(b,1);
    800029a2:	4585                	li	a1,1
    800029a4:	8526                	mv	a0,s1
    800029a6:	fffff097          	auipc	ra,0xfffff
    800029aa:	0b4080e7          	jalr	180(ra) # 80001a5a <virt_disk_rw>
}
    800029ae:	60e2                	ld	ra,24(sp)
    800029b0:	6442                	ld	s0,16(sp)
    800029b2:	64a2                	ld	s1,8(sp)
    800029b4:	6105                	addi	sp,sp,32
    800029b6:	8082                	ret
        panic("bwrite");
    800029b8:	00005517          	auipc	a0,0x5
    800029bc:	bd050513          	addi	a0,a0,-1072 # 80007588 <states.1524+0x370>
    800029c0:	ffffe097          	auipc	ra,0xffffe
    800029c4:	ac4080e7          	jalr	-1340(ra) # 80000484 <panic>
    800029c8:	bfe9                	j	800029a2 <bwrite+0x18>

00000000800029ca <ilock>:
void ilock(struct inode* i){
    800029ca:	1101                	addi	sp,sp,-32
    800029cc:	ec06                	sd	ra,24(sp)
    800029ce:	e822                	sd	s0,16(sp)
    800029d0:	e426                	sd	s1,8(sp)
    800029d2:	e04a                	sd	s2,0(sp)
    800029d4:	1000                	addi	s0,sp,32
    800029d6:	84aa                	mv	s1,a0
    if(i == 0 || i->ref < 1){
    800029d8:	c501                	beqz	a0,800029e0 <ilock+0x16>
    800029da:	451c                	lw	a5,8(a0)
    800029dc:	00f04a63          	bgtz	a5,800029f0 <ilock+0x26>
        panic("ilock");
    800029e0:	00005517          	auipc	a0,0x5
    800029e4:	bb050513          	addi	a0,a0,-1104 # 80007590 <states.1524+0x378>
    800029e8:	ffffe097          	auipc	ra,0xffffe
    800029ec:	a9c080e7          	jalr	-1380(ra) # 80000484 <panic>
    sleep_lock(&i->splock);
    800029f0:	01048513          	addi	a0,s1,16
    800029f4:	fffff097          	auipc	ra,0xfffff
    800029f8:	6b4080e7          	jalr	1716(ra) # 800020a8 <sleep_lock>
    if(i->vaild == 0){
    800029fc:	40bc                	lw	a5,64(s1)
    800029fe:	c799                	beqz	a5,80002a0c <ilock+0x42>
}
    80002a00:	60e2                	ld	ra,24(sp)
    80002a02:	6442                	ld	s0,16(sp)
    80002a04:	64a2                	ld	s1,8(sp)
    80002a06:	6902                	ld	s2,0(sp)
    80002a08:	6105                	addi	sp,sp,32
    80002a0a:	8082                	ret
        b = bread(i->dev,IBLOCK(i->inum,sb));
    80002a0c:	40dc                	lw	a5,4(s1)
    80002a0e:	0047d79b          	srliw	a5,a5,0x4
    80002a12:	00017597          	auipc	a1,0x17
    80002a16:	6065a583          	lw	a1,1542(a1) # 8001a018 <sb+0x18>
    80002a1a:	9dbd                	addw	a1,a1,a5
    80002a1c:	4088                	lw	a0,0(s1)
    80002a1e:	00000097          	auipc	ra,0x0
    80002a22:	8ae080e7          	jalr	-1874(ra) # 800022cc <bread>
    80002a26:	892a                	mv	s2,a0
        dip = (struct dinode*) b->data + i->inum % IPB;
    80002a28:	05850593          	addi	a1,a0,88
    80002a2c:	40dc                	lw	a5,4(s1)
    80002a2e:	8bbd                	andi	a5,a5,15
    80002a30:	079a                	slli	a5,a5,0x6
    80002a32:	95be                	add	a1,a1,a5
        i->type = dip->type;
    80002a34:	00059783          	lh	a5,0(a1)
    80002a38:	04f49223          	sh	a5,68(s1)
        i->size = dip->size;
    80002a3c:	459c                	lw	a5,8(a1)
    80002a3e:	c4fc                	sw	a5,76(s1)
        i->major = dip->major;
    80002a40:	00259783          	lh	a5,2(a1)
    80002a44:	04f49323          	sh	a5,70(s1)
        i->minor = dip->minor;
    80002a48:	00459783          	lh	a5,4(a1)
    80002a4c:	04f49423          	sh	a5,72(s1)
        i->nlink = dip->nlink;
    80002a50:	00659783          	lh	a5,6(a1)
    80002a54:	04f49523          	sh	a5,74(s1)
        memmove(i->addrs,dip->addrs,sizeof(i->addrs));
    80002a58:	03400613          	li	a2,52
    80002a5c:	05b1                	addi	a1,a1,12
    80002a5e:	05048513          	addi	a0,s1,80
    80002a62:	fffff097          	auipc	ra,0xfffff
    80002a66:	510080e7          	jalr	1296(ra) # 80001f72 <memmove>
        brelease(b);
    80002a6a:	854a                	mv	a0,s2
    80002a6c:	00000097          	auipc	ra,0x0
    80002a70:	a40080e7          	jalr	-1472(ra) # 800024ac <brelease>
        i->vaild = 0;
    80002a74:	0404a023          	sw	zero,64(s1)
}
    80002a78:	b761                	j	80002a00 <ilock+0x36>

0000000080002a7a <iname>:
struct inode* iname(char *name){
    80002a7a:	1101                	addi	sp,sp,-32
    80002a7c:	ec06                	sd	ra,24(sp)
    80002a7e:	e822                	sd	s0,16(sp)
    80002a80:	e426                	sd	s1,8(sp)
    80002a82:	e04a                	sd	s2,0(sp)
    80002a84:	1000                	addi	s0,sp,32
    80002a86:	892a                	mv	s2,a0
    struct inode *dp = iget(ROOTDEV,ROOTINO);
    80002a88:	4585                	li	a1,1
    80002a8a:	4505                	li	a0,1
    80002a8c:	00000097          	auipc	ra,0x0
    80002a90:	946080e7          	jalr	-1722(ra) # 800023d2 <iget>
    80002a94:	84aa                	mv	s1,a0
    ilock(dp);
    80002a96:	00000097          	auipc	ra,0x0
    80002a9a:	f34080e7          	jalr	-204(ra) # 800029ca <ilock>
    i = inodeByName(dp,name);
    80002a9e:	85ca                	mv	a1,s2
    80002aa0:	8526                	mv	a0,s1
    80002aa2:	00000097          	auipc	ra,0x0
    80002aa6:	dda080e7          	jalr	-550(ra) # 8000287c <inodeByName>
    80002aaa:	892a                	mv	s2,a0
    sleep_unlock(&dp->splock);
    80002aac:	01048513          	addi	a0,s1,16
    80002ab0:	fffff097          	auipc	ra,0xfffff
    80002ab4:	64e080e7          	jalr	1614(ra) # 800020fe <sleep_unlock>
}
    80002ab8:	854a                	mv	a0,s2
    80002aba:	60e2                	ld	ra,24(sp)
    80002abc:	6442                	ld	s0,16(sp)
    80002abe:	64a2                	ld	s1,8(sp)
    80002ac0:	6902                	ld	s2,0(sp)
    80002ac2:	6105                	addi	sp,sp,32
    80002ac4:	8082                	ret

0000000080002ac6 <iunlock>:
    } 
    ip->size = 0;
    iupdate(ip);
}

void iunlock(struct inode *i){
    80002ac6:	1101                	addi	sp,sp,-32
    80002ac8:	ec06                	sd	ra,24(sp)
    80002aca:	e822                	sd	s0,16(sp)
    80002acc:	e426                	sd	s1,8(sp)
    80002ace:	1000                	addi	s0,sp,32
    80002ad0:	84aa                	mv	s1,a0
    if( i == 0 || !holdingsleep(&i->splock) || i->ref < 1){
    80002ad2:	c911                	beqz	a0,80002ae6 <iunlock+0x20>
    80002ad4:	0541                	addi	a0,a0,16
    80002ad6:	fffff097          	auipc	ra,0xfffff
    80002ada:	66c080e7          	jalr	1644(ra) # 80002142 <holdingsleep>
    80002ade:	c501                	beqz	a0,80002ae6 <iunlock+0x20>
    80002ae0:	449c                	lw	a5,8(s1)
    80002ae2:	00f04a63          	bgtz	a5,80002af6 <iunlock+0x30>
        panic("iunlock");
    80002ae6:	00005517          	auipc	a0,0x5
    80002aea:	ab250513          	addi	a0,a0,-1358 # 80007598 <states.1524+0x380>
    80002aee:	ffffe097          	auipc	ra,0xffffe
    80002af2:	996080e7          	jalr	-1642(ra) # 80000484 <panic>
    }
    sleep_unlock(&i->splock);
    80002af6:	01048513          	addi	a0,s1,16
    80002afa:	fffff097          	auipc	ra,0xfffff
    80002afe:	604080e7          	jalr	1540(ra) # 800020fe <sleep_unlock>
}
    80002b02:	60e2                	ld	ra,24(sp)
    80002b04:	6442                	ld	s0,16(sp)
    80002b06:	64a2                	ld	s1,8(sp)
    80002b08:	6105                	addi	sp,sp,32
    80002b0a:	8082                	ret

0000000080002b0c <ialloc>:

struct inode* ialloc(uint dev,short type) {
    int inum;
    struct buf *bp;
    struct dinode *d;
    for(inum = 0;inum < sb.ninodes; inum++){
    80002b0c:	00017797          	auipc	a5,0x17
    80002b10:	5007a783          	lw	a5,1280(a5) # 8001a00c <sb+0xc>
    80002b14:	cbdd                	beqz	a5,80002bca <ialloc+0xbe>
struct inode* ialloc(uint dev,short type) {
    80002b16:	715d                	addi	sp,sp,-80
    80002b18:	e486                	sd	ra,72(sp)
    80002b1a:	e0a2                	sd	s0,64(sp)
    80002b1c:	fc26                	sd	s1,56(sp)
    80002b1e:	f84a                	sd	s2,48(sp)
    80002b20:	f44e                	sd	s3,40(sp)
    80002b22:	f052                	sd	s4,32(sp)
    80002b24:	ec56                	sd	s5,24(sp)
    80002b26:	e85a                	sd	s6,16(sp)
    80002b28:	e45e                	sd	s7,8(sp)
    80002b2a:	0880                	addi	s0,sp,80
    80002b2c:	8aaa                	mv	s5,a0
    80002b2e:	8bae                	mv	s7,a1
    for(inum = 0;inum < sb.ninodes; inum++){
    80002b30:	4481                	li	s1,0
        bp = bread(dev,IBLOCK(inum,sb));
    80002b32:	00017a17          	auipc	s4,0x17
    80002b36:	4cea0a13          	addi	s4,s4,1230 # 8001a000 <sb>
    80002b3a:	00048b1b          	sext.w	s6,s1
    80002b3e:	0044d593          	srli	a1,s1,0x4
    80002b42:	018a2783          	lw	a5,24(s4)
    80002b46:	9dbd                	addw	a1,a1,a5
    80002b48:	8556                	mv	a0,s5
    80002b4a:	fffff097          	auipc	ra,0xfffff
    80002b4e:	782080e7          	jalr	1922(ra) # 800022cc <bread>
    80002b52:	892a                	mv	s2,a0
        d = (struct dinode*)bp->data + inum % IPB;
    80002b54:	05850993          	addi	s3,a0,88
    80002b58:	00f4f793          	andi	a5,s1,15
    80002b5c:	079a                	slli	a5,a5,0x6
    80002b5e:	99be                	add	s3,s3,a5
        if(d->type == 0){
    80002b60:	00099783          	lh	a5,0(s3) # 2000 <_entry-0x7fffe000>
    80002b64:	cf91                	beqz	a5,80002b80 <ialloc+0x74>
            d->type = type;
            bwrite(bp);
            brelease(bp);
            return iget(dev,inum);
        }
        brelease(bp);
    80002b66:	00000097          	auipc	ra,0x0
    80002b6a:	946080e7          	jalr	-1722(ra) # 800024ac <brelease>
    for(inum = 0;inum < sb.ninodes; inum++){
    80002b6e:	0485                	addi	s1,s1,1
    80002b70:	00ca2703          	lw	a4,12(s4)
    80002b74:	0004879b          	sext.w	a5,s1
    80002b78:	fce7e1e3          	bltu	a5,a4,80002b3a <ialloc+0x2e>
    }
    return 0;
    80002b7c:	4501                	li	a0,0
    80002b7e:	a81d                	j	80002bb4 <ialloc+0xa8>
            memset(d,0,sizeof(*d));
    80002b80:	04000613          	li	a2,64
    80002b84:	4581                	li	a1,0
    80002b86:	854e                	mv	a0,s3
    80002b88:	fffff097          	auipc	ra,0xfffff
    80002b8c:	3c2080e7          	jalr	962(ra) # 80001f4a <memset>
            d->type = type;
    80002b90:	01799023          	sh	s7,0(s3)
            bwrite(bp);
    80002b94:	854a                	mv	a0,s2
    80002b96:	00000097          	auipc	ra,0x0
    80002b9a:	df4080e7          	jalr	-524(ra) # 8000298a <bwrite>
            brelease(bp);
    80002b9e:	854a                	mv	a0,s2
    80002ba0:	00000097          	auipc	ra,0x0
    80002ba4:	90c080e7          	jalr	-1780(ra) # 800024ac <brelease>
            return iget(dev,inum);
    80002ba8:	85da                	mv	a1,s6
    80002baa:	8556                	mv	a0,s5
    80002bac:	00000097          	auipc	ra,0x0
    80002bb0:	826080e7          	jalr	-2010(ra) # 800023d2 <iget>
}
    80002bb4:	60a6                	ld	ra,72(sp)
    80002bb6:	6406                	ld	s0,64(sp)
    80002bb8:	74e2                	ld	s1,56(sp)
    80002bba:	7942                	ld	s2,48(sp)
    80002bbc:	79a2                	ld	s3,40(sp)
    80002bbe:	7a02                	ld	s4,32(sp)
    80002bc0:	6ae2                	ld	s5,24(sp)
    80002bc2:	6b42                	ld	s6,16(sp)
    80002bc4:	6ba2                	ld	s7,8(sp)
    80002bc6:	6161                	addi	sp,sp,80
    80002bc8:	8082                	ret
    return 0;
    80002bca:	4501                	li	a0,0
}
    80002bcc:	8082                	ret

0000000080002bce <iupdate>:

void iupdate(struct inode *ip){
    80002bce:	1101                	addi	sp,sp,-32
    80002bd0:	ec06                	sd	ra,24(sp)
    80002bd2:	e822                	sd	s0,16(sp)
    80002bd4:	e426                	sd	s1,8(sp)
    80002bd6:	e04a                	sd	s2,0(sp)
    80002bd8:	1000                	addi	s0,sp,32
    80002bda:	84aa                	mv	s1,a0
    struct buf *b = bread(ip->dev,IBLOCK(ip->inum,sb));
    80002bdc:	415c                	lw	a5,4(a0)
    80002bde:	0047d79b          	srliw	a5,a5,0x4
    80002be2:	00017597          	auipc	a1,0x17
    80002be6:	4365a583          	lw	a1,1078(a1) # 8001a018 <sb+0x18>
    80002bea:	9dbd                	addw	a1,a1,a5
    80002bec:	4108                	lw	a0,0(a0)
    80002bee:	fffff097          	auipc	ra,0xfffff
    80002bf2:	6de080e7          	jalr	1758(ra) # 800022cc <bread>
    80002bf6:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode*)b->data + ip->inum%IPB;
    80002bf8:	05850793          	addi	a5,a0,88
    80002bfc:	40c8                	lw	a0,4(s1)
    80002bfe:	893d                	andi	a0,a0,15
    80002c00:	051a                	slli	a0,a0,0x6
    80002c02:	953e                	add	a0,a0,a5
    dip->type = ip->type;
    80002c04:	04449703          	lh	a4,68(s1)
    80002c08:	00e51023          	sh	a4,0(a0)
    dip->major = ip->major;
    80002c0c:	04649703          	lh	a4,70(s1)
    80002c10:	00e51123          	sh	a4,2(a0)
    dip->minor = ip->minor;
    80002c14:	04849703          	lh	a4,72(s1)
    80002c18:	00e51223          	sh	a4,4(a0)
    dip->nlink = ip->nlink;
    80002c1c:	04a49703          	lh	a4,74(s1)
    80002c20:	00e51323          	sh	a4,6(a0)
    dip->size = ip->size;
    80002c24:	44f8                	lw	a4,76(s1)
    80002c26:	c518                	sw	a4,8(a0)
    memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80002c28:	03400613          	li	a2,52
    80002c2c:	05048593          	addi	a1,s1,80
    80002c30:	0531                	addi	a0,a0,12
    80002c32:	fffff097          	auipc	ra,0xfffff
    80002c36:	340080e7          	jalr	832(ra) # 80001f72 <memmove>
    // TODO : already write to cache buf , now should write to log 
    bwrite(b);
    80002c3a:	854a                	mv	a0,s2
    80002c3c:	00000097          	auipc	ra,0x0
    80002c40:	d4e080e7          	jalr	-690(ra) # 8000298a <bwrite>
    brelease(b);
    80002c44:	854a                	mv	a0,s2
    80002c46:	00000097          	auipc	ra,0x0
    80002c4a:	866080e7          	jalr	-1946(ra) # 800024ac <brelease>
}
    80002c4e:	60e2                	ld	ra,24(sp)
    80002c50:	6442                	ld	s0,16(sp)
    80002c52:	64a2                	ld	s1,8(sp)
    80002c54:	6902                	ld	s2,0(sp)
    80002c56:	6105                	addi	sp,sp,32
    80002c58:	8082                	ret

0000000080002c5a <itrunc>:
void itrunc(struct inode *ip){
    80002c5a:	7179                	addi	sp,sp,-48
    80002c5c:	f406                	sd	ra,40(sp)
    80002c5e:	f022                	sd	s0,32(sp)
    80002c60:	ec26                	sd	s1,24(sp)
    80002c62:	e84a                	sd	s2,16(sp)
    80002c64:	e44e                	sd	s3,8(sp)
    80002c66:	e052                	sd	s4,0(sp)
    80002c68:	1800                	addi	s0,sp,48
    80002c6a:	892a                	mv	s2,a0
    for(int i =0;i < NDIRECT;i++){
    80002c6c:	05050493          	addi	s1,a0,80
    80002c70:	08050993          	addi	s3,a0,128
    80002c74:	a821                	j	80002c8c <itrunc+0x32>
            bfree(ip->dev,ip->addrs[i]);
    80002c76:	00092503          	lw	a0,0(s2)
    80002c7a:	00000097          	auipc	ra,0x0
    80002c7e:	c90080e7          	jalr	-880(ra) # 8000290a <bfree>
            ip->addrs[i] = 0;
    80002c82:	0004a023          	sw	zero,0(s1)
    for(int i =0;i < NDIRECT;i++){
    80002c86:	0491                	addi	s1,s1,4
    80002c88:	01348563          	beq	s1,s3,80002c92 <itrunc+0x38>
        if(ip->addrs[i]){
    80002c8c:	408c                	lw	a1,0(s1)
    80002c8e:	dde5                	beqz	a1,80002c86 <itrunc+0x2c>
    80002c90:	b7dd                	j	80002c76 <itrunc+0x1c>
    if(ip->addrs[NDIRECT]){
    80002c92:	08092583          	lw	a1,128(s2)
    80002c96:	e185                	bnez	a1,80002cb6 <itrunc+0x5c>
    ip->size = 0;
    80002c98:	04092623          	sw	zero,76(s2)
    iupdate(ip);
    80002c9c:	854a                	mv	a0,s2
    80002c9e:	00000097          	auipc	ra,0x0
    80002ca2:	f30080e7          	jalr	-208(ra) # 80002bce <iupdate>
}
    80002ca6:	70a2                	ld	ra,40(sp)
    80002ca8:	7402                	ld	s0,32(sp)
    80002caa:	64e2                	ld	s1,24(sp)
    80002cac:	6942                	ld	s2,16(sp)
    80002cae:	69a2                	ld	s3,8(sp)
    80002cb0:	6a02                	ld	s4,0(sp)
    80002cb2:	6145                	addi	sp,sp,48
    80002cb4:	8082                	ret
        b = bread(ip->dev,ip->addrs[NDIRECT]);
    80002cb6:	00092503          	lw	a0,0(s2)
    80002cba:	fffff097          	auipc	ra,0xfffff
    80002cbe:	612080e7          	jalr	1554(ra) # 800022cc <bread>
    80002cc2:	8a2a                	mv	s4,a0
        for(int i = 0; i < NDIRECT;i++){
    80002cc4:	05850493          	addi	s1,a0,88
    80002cc8:	08850993          	addi	s3,a0,136
    80002ccc:	a811                	j	80002ce0 <itrunc+0x86>
                bfree(ip->dev,a[i]);
    80002cce:	00092503          	lw	a0,0(s2)
    80002cd2:	00000097          	auipc	ra,0x0
    80002cd6:	c38080e7          	jalr	-968(ra) # 8000290a <bfree>
        for(int i = 0; i < NDIRECT;i++){
    80002cda:	0491                	addi	s1,s1,4
    80002cdc:	01348563          	beq	s1,s3,80002ce6 <itrunc+0x8c>
            if(a[i]){
    80002ce0:	408c                	lw	a1,0(s1)
    80002ce2:	dde5                	beqz	a1,80002cda <itrunc+0x80>
    80002ce4:	b7ed                	j	80002cce <itrunc+0x74>
        brelease(b);
    80002ce6:	8552                	mv	a0,s4
    80002ce8:	fffff097          	auipc	ra,0xfffff
    80002cec:	7c4080e7          	jalr	1988(ra) # 800024ac <brelease>
        bfree(ip->dev,ip->addrs[NDIRECT]);
    80002cf0:	08092583          	lw	a1,128(s2)
    80002cf4:	00092503          	lw	a0,0(s2)
    80002cf8:	00000097          	auipc	ra,0x0
    80002cfc:	c12080e7          	jalr	-1006(ra) # 8000290a <bfree>
        ip->addrs[NDIRECT] = 0;
    80002d00:	08092023          	sw	zero,128(s2)
    80002d04:	bf51                	j	80002c98 <itrunc+0x3e>

0000000080002d06 <iput>:
void iput(struct inode *i){
    80002d06:	1101                	addi	sp,sp,-32
    80002d08:	ec06                	sd	ra,24(sp)
    80002d0a:	e822                	sd	s0,16(sp)
    80002d0c:	e426                	sd	s1,8(sp)
    80002d0e:	e04a                	sd	s2,0(sp)
    80002d10:	1000                	addi	s0,sp,32
    80002d12:	84aa                	mv	s1,a0
    acquire(&inodecache.slock);
    80002d14:	00017517          	auipc	a0,0x17
    80002d18:	31450513          	addi	a0,a0,788 # 8001a028 <inodecache>
    80002d1c:	fffff097          	auipc	ra,0xfffff
    80002d20:	b14080e7          	jalr	-1260(ra) # 80001830 <acquire>
    if(i->ref == 1 && i->vaild && i->nlink == 0){
    80002d24:	4498                	lw	a4,8(s1)
    80002d26:	4785                	li	a5,1
    80002d28:	02f70363          	beq	a4,a5,80002d4e <iput+0x48>
    i->ref --;
    80002d2c:	449c                	lw	a5,8(s1)
    80002d2e:	37fd                	addiw	a5,a5,-1
    80002d30:	c49c                	sw	a5,8(s1)
    release(&inodecache.slock);
    80002d32:	00017517          	auipc	a0,0x17
    80002d36:	2f650513          	addi	a0,a0,758 # 8001a028 <inodecache>
    80002d3a:	fffff097          	auipc	ra,0xfffff
    80002d3e:	bb8080e7          	jalr	-1096(ra) # 800018f2 <release>
}
    80002d42:	60e2                	ld	ra,24(sp)
    80002d44:	6442                	ld	s0,16(sp)
    80002d46:	64a2                	ld	s1,8(sp)
    80002d48:	6902                	ld	s2,0(sp)
    80002d4a:	6105                	addi	sp,sp,32
    80002d4c:	8082                	ret
    if(i->ref == 1 && i->vaild && i->nlink == 0){
    80002d4e:	40bc                	lw	a5,64(s1)
    80002d50:	dff1                	beqz	a5,80002d2c <iput+0x26>
    80002d52:	04a49783          	lh	a5,74(s1)
    80002d56:	fbf9                	bnez	a5,80002d2c <iput+0x26>
        sleep_lock(&i->splock);
    80002d58:	01048913          	addi	s2,s1,16
    80002d5c:	854a                	mv	a0,s2
    80002d5e:	fffff097          	auipc	ra,0xfffff
    80002d62:	34a080e7          	jalr	842(ra) # 800020a8 <sleep_lock>
        release(&inodecache.slock);
    80002d66:	00017517          	auipc	a0,0x17
    80002d6a:	2c250513          	addi	a0,a0,706 # 8001a028 <inodecache>
    80002d6e:	fffff097          	auipc	ra,0xfffff
    80002d72:	b84080e7          	jalr	-1148(ra) # 800018f2 <release>
        itrunc(i);
    80002d76:	8526                	mv	a0,s1
    80002d78:	00000097          	auipc	ra,0x0
    80002d7c:	ee2080e7          	jalr	-286(ra) # 80002c5a <itrunc>
        i->type = 0;
    80002d80:	04049223          	sh	zero,68(s1)
        iupdate(i);
    80002d84:	8526                	mv	a0,s1
    80002d86:	00000097          	auipc	ra,0x0
    80002d8a:	e48080e7          	jalr	-440(ra) # 80002bce <iupdate>
        i->vaild = 0;
    80002d8e:	0404a023          	sw	zero,64(s1)
        sleep_unlock(&i->splock);
    80002d92:	854a                	mv	a0,s2
    80002d94:	fffff097          	auipc	ra,0xfffff
    80002d98:	36a080e7          	jalr	874(ra) # 800020fe <sleep_unlock>
        acquire(&inodecache.slock);
    80002d9c:	00017517          	auipc	a0,0x17
    80002da0:	28c50513          	addi	a0,a0,652 # 8001a028 <inodecache>
    80002da4:	fffff097          	auipc	ra,0xfffff
    80002da8:	a8c080e7          	jalr	-1396(ra) # 80001830 <acquire>
    80002dac:	b741                	j	80002d2c <iput+0x26>

0000000080002dae <iunlockput>:
void iunlockput(struct inode *ip){
    80002dae:	1101                	addi	sp,sp,-32
    80002db0:	ec06                	sd	ra,24(sp)
    80002db2:	e822                	sd	s0,16(sp)
    80002db4:	e426                	sd	s1,8(sp)
    80002db6:	1000                	addi	s0,sp,32
    80002db8:	84aa                	mv	s1,a0
    iunlock(ip);
    80002dba:	00000097          	auipc	ra,0x0
    80002dbe:	d0c080e7          	jalr	-756(ra) # 80002ac6 <iunlock>
    iput(ip);
    80002dc2:	8526                	mv	a0,s1
    80002dc4:	00000097          	auipc	ra,0x0
    80002dc8:	f42080e7          	jalr	-190(ra) # 80002d06 <iput>
}
    80002dcc:	60e2                	ld	ra,24(sp)
    80002dce:	6442                	ld	s0,16(sp)
    80002dd0:	64a2                	ld	s1,8(sp)
    80002dd2:	6105                	addi	sp,sp,32
    80002dd4:	8082                	ret

0000000080002dd6 <rootsub>:
struct inode* rootsub(char *name){
    80002dd6:	1101                	addi	sp,sp,-32
    80002dd8:	ec06                	sd	ra,24(sp)
    80002dda:	e822                	sd	s0,16(sp)
    80002ddc:	e426                	sd	s1,8(sp)
    80002dde:	e04a                	sd	s2,0(sp)
    80002de0:	1000                	addi	s0,sp,32
    80002de2:	892a                	mv	s2,a0
    struct inode *root = rooti();
    80002de4:	fffff097          	auipc	ra,0xfffff
    80002de8:	6ac080e7          	jalr	1708(ra) # 80002490 <rooti>
    80002dec:	84aa                	mv	s1,a0
    ilock(root);
    80002dee:	00000097          	auipc	ra,0x0
    80002df2:	bdc080e7          	jalr	-1060(ra) # 800029ca <ilock>
    struct inode *sub = inodeByName(root,name);
    80002df6:	85ca                	mv	a1,s2
    80002df8:	8526                	mv	a0,s1
    80002dfa:	00000097          	auipc	ra,0x0
    80002dfe:	a82080e7          	jalr	-1406(ra) # 8000287c <inodeByName>
    80002e02:	892a                	mv	s2,a0
    iunlockput(root);
    80002e04:	8526                	mv	a0,s1
    80002e06:	00000097          	auipc	ra,0x0
    80002e0a:	fa8080e7          	jalr	-88(ra) # 80002dae <iunlockput>
}
    80002e0e:	854a                	mv	a0,s2
    80002e10:	60e2                	ld	ra,24(sp)
    80002e12:	6442                	ld	s0,16(sp)
    80002e14:	64a2                	ld	s1,8(sp)
    80002e16:	6902                	ld	s2,0(sp)
    80002e18:	6105                	addi	sp,sp,32
    80002e1a:	8082                	ret

0000000080002e1c <writei>:

int writei(struct inode *ip,int user_src,uint64 src,uint off, uint n){
    80002e1c:	7159                	addi	sp,sp,-112
    80002e1e:	f486                	sd	ra,104(sp)
    80002e20:	f0a2                	sd	s0,96(sp)
    80002e22:	eca6                	sd	s1,88(sp)
    80002e24:	e8ca                	sd	s2,80(sp)
    80002e26:	e4ce                	sd	s3,72(sp)
    80002e28:	e0d2                	sd	s4,64(sp)
    80002e2a:	fc56                	sd	s5,56(sp)
    80002e2c:	f85a                	sd	s6,48(sp)
    80002e2e:	f45e                	sd	s7,40(sp)
    80002e30:	f062                	sd	s8,32(sp)
    80002e32:	ec66                	sd	s9,24(sp)
    80002e34:	e86a                	sd	s10,16(sp)
    80002e36:	e46e                	sd	s11,8(sp)
    80002e38:	1880                	addi	s0,sp,112
    if(off > ip->size || off + n < off){
    80002e3a:	457c                	lw	a5,76(a0)
    80002e3c:	02d7e763          	bltu	a5,a3,80002e6a <writei+0x4e>
    80002e40:	8aaa                	mv	s5,a0
    80002e42:	8c2e                	mv	s8,a1
    80002e44:	8a32                	mv	s4,a2
    80002e46:	89b6                	mv	s3,a3
    80002e48:	8b3a                	mv	s6,a4
    80002e4a:	00e687bb          	addw	a5,a3,a4
    80002e4e:	00d7ee63          	bltu	a5,a3,80002e6a <writei+0x4e>
        printf("off > ip->size || off + n < off \n");
        return -1;
    }
    if(off + n > MAXFILE){
    80002e52:	10c00713          	li	a4,268
    80002e56:	02f76463          	bltu	a4,a5,80002e7e <writei+0x62>
        printf("off + n > MAXFILE \n");
        return -1;
    }
    int tot,m;
    for(tot = 0; tot < n;tot += m,off += m,src += m){
    80002e5a:	4b81                	li	s7,0
    80002e5c:	4481                	li	s1,0
        struct buf *bp = bread(ip->dev,bmap(ip,off/BSIZE));
        m = min(n-tot,BSIZE - off % BSIZE);
    80002e5e:	40000d13          	li	s10,1024
        if(either_copyin(bp->data+(off%BSIZE),user_src,src,m) == -1){
    80002e62:	5cfd                	li	s9,-1
    for(tot = 0; tot < n;tot += m,off += m,src += m){
    80002e64:	060b1963          	bnez	s6,80002ed6 <writei+0xba>
    80002e68:	a8c9                	j	80002f3a <writei+0x11e>
        printf("off > ip->size || off + n < off \n");
    80002e6a:	00004517          	auipc	a0,0x4
    80002e6e:	73650513          	addi	a0,a0,1846 # 800075a0 <states.1524+0x388>
    80002e72:	ffffd097          	auipc	ra,0xffffd
    80002e76:	448080e7          	jalr	1096(ra) # 800002ba <printf>
        return -1;
    80002e7a:	5bfd                	li	s7,-1
    80002e7c:	a0e1                	j	80002f44 <writei+0x128>
        printf("off + n > MAXFILE \n");
    80002e7e:	00004517          	auipc	a0,0x4
    80002e82:	74a50513          	addi	a0,a0,1866 # 800075c8 <states.1524+0x3b0>
    80002e86:	ffffd097          	auipc	ra,0xffffd
    80002e8a:	434080e7          	jalr	1076(ra) # 800002ba <printf>
        return -1;
    80002e8e:	5bfd                	li	s7,-1
    80002e90:	a855                	j	80002f44 <writei+0x128>
        m = min(n-tot,BSIZE - off % BSIZE);
    80002e92:	000d849b          	sext.w	s1,s11
        if(either_copyin(bp->data+(off%BSIZE),user_src,src,m) == -1){
    80002e96:	05890513          	addi	a0,s2,88
    80002e9a:	86a6                	mv	a3,s1
    80002e9c:	8652                	mv	a2,s4
    80002e9e:	85e2                	mv	a1,s8
    80002ea0:	953e                	add	a0,a0,a5
    80002ea2:	00001097          	auipc	ra,0x1
    80002ea6:	cfc080e7          	jalr	-772(ra) # 80003b9e <either_copyin>
    80002eaa:	07950563          	beq	a0,s9,80002f14 <writei+0xf8>
            brelease(bp);
            panic("writi:either_copy\n");
            break;
        }
        // log
        bwrite(bp);
    80002eae:	854a                	mv	a0,s2
    80002eb0:	00000097          	auipc	ra,0x0
    80002eb4:	ada080e7          	jalr	-1318(ra) # 8000298a <bwrite>
        brelease(bp);
    80002eb8:	854a                	mv	a0,s2
    80002eba:	fffff097          	auipc	ra,0xfffff
    80002ebe:	5f2080e7          	jalr	1522(ra) # 800024ac <brelease>
    for(tot = 0; tot < n;tot += m,off += m,src += m){
    80002ec2:	017d87bb          	addw	a5,s11,s7
    80002ec6:	00078b9b          	sext.w	s7,a5
    80002eca:	013d89bb          	addw	s3,s11,s3
    80002ece:	9a26                	add	s4,s4,s1
    80002ed0:	84de                	mv	s1,s7
    80002ed2:	056bfe63          	bgeu	s7,s6,80002f2e <writei+0x112>
        struct buf *bp = bread(ip->dev,bmap(ip,off/BSIZE));
    80002ed6:	000aa903          	lw	s2,0(s5)
    80002eda:	00a9d59b          	srliw	a1,s3,0xa
    80002ede:	8556                	mv	a0,s5
    80002ee0:	fffff097          	auipc	ra,0xfffff
    80002ee4:	7c4080e7          	jalr	1988(ra) # 800026a4 <bmap>
    80002ee8:	0005059b          	sext.w	a1,a0
    80002eec:	854a                	mv	a0,s2
    80002eee:	fffff097          	auipc	ra,0xfffff
    80002ef2:	3de080e7          	jalr	990(ra) # 800022cc <bread>
    80002ef6:	892a                	mv	s2,a0
        m = min(n-tot,BSIZE - off % BSIZE);
    80002ef8:	3ff9f793          	andi	a5,s3,1023
    80002efc:	409b04bb          	subw	s1,s6,s1
    80002f00:	40fd073b          	subw	a4,s10,a5
    80002f04:	8da6                	mv	s11,s1
    80002f06:	2481                	sext.w	s1,s1
    80002f08:	0007069b          	sext.w	a3,a4
    80002f0c:	f896f3e3          	bgeu	a3,s1,80002e92 <writei+0x76>
    80002f10:	8dba                	mv	s11,a4
    80002f12:	b741                	j	80002e92 <writei+0x76>
            brelease(bp);
    80002f14:	854a                	mv	a0,s2
    80002f16:	fffff097          	auipc	ra,0xfffff
    80002f1a:	596080e7          	jalr	1430(ra) # 800024ac <brelease>
            panic("writi:either_copy\n");
    80002f1e:	00004517          	auipc	a0,0x4
    80002f22:	6c250513          	addi	a0,a0,1730 # 800075e0 <states.1524+0x3c8>
    80002f26:	ffffd097          	auipc	ra,0xffffd
    80002f2a:	55e080e7          	jalr	1374(ra) # 80000484 <panic>
    }
    if(off > ip->size){
    80002f2e:	04caa783          	lw	a5,76(s5)
    80002f32:	0137f463          	bgeu	a5,s3,80002f3a <writei+0x11e>
        ip->size = off;
    80002f36:	053aa623          	sw	s3,76(s5)
    }
    iupdate(ip);
    80002f3a:	8556                	mv	a0,s5
    80002f3c:	00000097          	auipc	ra,0x0
    80002f40:	c92080e7          	jalr	-878(ra) # 80002bce <iupdate>
    return tot;
}
    80002f44:	855e                	mv	a0,s7
    80002f46:	70a6                	ld	ra,104(sp)
    80002f48:	7406                	ld	s0,96(sp)
    80002f4a:	64e6                	ld	s1,88(sp)
    80002f4c:	6946                	ld	s2,80(sp)
    80002f4e:	69a6                	ld	s3,72(sp)
    80002f50:	6a06                	ld	s4,64(sp)
    80002f52:	7ae2                	ld	s5,56(sp)
    80002f54:	7b42                	ld	s6,48(sp)
    80002f56:	7ba2                	ld	s7,40(sp)
    80002f58:	7c02                	ld	s8,32(sp)
    80002f5a:	6ce2                	ld	s9,24(sp)
    80002f5c:	6d42                	ld	s10,16(sp)
    80002f5e:	6da2                	ld	s11,8(sp)
    80002f60:	6165                	addi	sp,sp,112
    80002f62:	8082                	ret

0000000080002f64 <dirlink>:


int dirlink(struct inode *dp,char *path,short inum){
    80002f64:	715d                	addi	sp,sp,-80
    80002f66:	e486                	sd	ra,72(sp)
    80002f68:	e0a2                	sd	s0,64(sp)
    80002f6a:	fc26                	sd	s1,56(sp)
    80002f6c:	f84a                	sd	s2,48(sp)
    80002f6e:	f44e                	sd	s3,40(sp)
    80002f70:	f052                	sd	s4,32(sp)
    80002f72:	ec56                	sd	s5,24(sp)
    80002f74:	0880                	addi	s0,sp,80
    80002f76:	892a                	mv	s2,a0
    80002f78:	8aae                	mv	s5,a1
    80002f7a:	8a32                	mv	s4,a2
    struct dirent dir;
    
    int off;
    for(off = 0; off < dp->size; off += sizeof(dir)){
    80002f7c:	4564                	lw	s1,76(a0)
    80002f7e:	c0b1                	beqz	s1,80002fc2 <dirlink+0x5e>
    80002f80:	4481                	li	s1,0
        if(readi(dp,0,(uint64)&dir,off,sizeof(dir)) != sizeof(dir)){
            panic("dirlink panic...\n");
    80002f82:	00004997          	auipc	s3,0x4
    80002f86:	67698993          	addi	s3,s3,1654 # 800075f8 <states.1524+0x3e0>
    80002f8a:	a831                	j	80002fa6 <dirlink+0x42>
    80002f8c:	854e                	mv	a0,s3
    80002f8e:	ffffd097          	auipc	ra,0xffffd
    80002f92:	4f6080e7          	jalr	1270(ra) # 80000484 <panic>
        }
        if(dir.inum == 0){
    80002f96:	fb045783          	lhu	a5,-80(s0)
    80002f9a:	c785                	beqz	a5,80002fc2 <dirlink+0x5e>
    for(off = 0; off < dp->size; off += sizeof(dir)){
    80002f9c:	24c1                	addiw	s1,s1,16
    80002f9e:	04c92783          	lw	a5,76(s2)
    80002fa2:	02f4f063          	bgeu	s1,a5,80002fc2 <dirlink+0x5e>
        if(readi(dp,0,(uint64)&dir,off,sizeof(dir)) != sizeof(dir)){
    80002fa6:	4741                	li	a4,16
    80002fa8:	86a6                	mv	a3,s1
    80002faa:	fb040613          	addi	a2,s0,-80
    80002fae:	4581                	li	a1,0
    80002fb0:	854a                	mv	a0,s2
    80002fb2:	fffff097          	auipc	ra,0xfffff
    80002fb6:	7c6080e7          	jalr	1990(ra) # 80002778 <readi>
    80002fba:	47c1                	li	a5,16
    80002fbc:	fcf50de3          	beq	a0,a5,80002f96 <dirlink+0x32>
    80002fc0:	b7f1                	j	80002f8c <dirlink+0x28>
            break;
        }
    }

    strncpy(dir.name,path,DIRSIZ);
    80002fc2:	4639                	li	a2,14
    80002fc4:	85d6                	mv	a1,s5
    80002fc6:	fb240513          	addi	a0,s0,-78
    80002fca:	fffff097          	auipc	ra,0xfffff
    80002fce:	06e080e7          	jalr	110(ra) # 80002038 <strncpy>
    dir.inum = inum;
    80002fd2:	fb441823          	sh	s4,-80(s0)
    if(writei(dp,0,(uint64)&dir,off,sizeof(dir)) != sizeof(dir)){
    80002fd6:	4741                	li	a4,16
    80002fd8:	86a6                	mv	a3,s1
    80002fda:	fb040613          	addi	a2,s0,-80
    80002fde:	4581                	li	a1,0
    80002fe0:	854a                	mv	a0,s2
    80002fe2:	00000097          	auipc	ra,0x0
    80002fe6:	e3a080e7          	jalr	-454(ra) # 80002e1c <writei>
    80002fea:	47c1                	li	a5,16
    80002fec:	00f51c63          	bne	a0,a5,80003004 <dirlink+0xa0>
        panic("dirlink writei");
    };
    return 0;
}
    80002ff0:	4501                	li	a0,0
    80002ff2:	60a6                	ld	ra,72(sp)
    80002ff4:	6406                	ld	s0,64(sp)
    80002ff6:	74e2                	ld	s1,56(sp)
    80002ff8:	7942                	ld	s2,48(sp)
    80002ffa:	79a2                	ld	s3,40(sp)
    80002ffc:	7a02                	ld	s4,32(sp)
    80002ffe:	6ae2                	ld	s5,24(sp)
    80003000:	6161                	addi	sp,sp,80
    80003002:	8082                	ret
        panic("dirlink writei");
    80003004:	00004517          	auipc	a0,0x4
    80003008:	60c50513          	addi	a0,a0,1548 # 80007610 <states.1524+0x3f8>
    8000300c:	ffffd097          	auipc	ra,0xffffd
    80003010:	478080e7          	jalr	1144(ra) # 80000484 <panic>
    80003014:	bff1                	j	80002ff0 <dirlink+0x8c>

0000000080003016 <stati>:


void stati(struct inode *i,struct stat *s){
    80003016:	1141                	addi	sp,sp,-16
    80003018:	e422                	sd	s0,8(sp)
    8000301a:	0800                	addi	s0,sp,16
    s->dev = i->dev;
    8000301c:	411c                	lw	a5,0(a0)
    8000301e:	c19c                	sw	a5,0(a1)
    s->ino = i->inum;
    80003020:	415c                	lw	a5,4(a0)
    80003022:	c1dc                	sw	a5,4(a1)
    s->type = i->type;
    80003024:	04451783          	lh	a5,68(a0)
    80003028:	00f59423          	sh	a5,8(a1)
    s->nlink = i->nlink;
    8000302c:	04a51783          	lh	a5,74(a0)
    80003030:	00f59523          	sh	a5,10(a1)
    s->size = i->size;
    80003034:	04c56783          	lwu	a5,76(a0)
    80003038:	e99c                	sd	a5,16(a1)
    8000303a:	6422                	ld	s0,8(sp)
    8000303c:	0141                	addi	sp,sp,16
    8000303e:	8082                	ret

0000000080003040 <init_filecache>:
struct {
    struct spinlock slock;
    struct file files[NFILE];
} filecache;

void init_filecache(){
    80003040:	1141                	addi	sp,sp,-16
    80003042:	e406                	sd	ra,8(sp)
    80003044:	e022                	sd	s0,0(sp)
    80003046:	0800                	addi	s0,sp,16
    initlock(&filecache.slock,"filecache");
    80003048:	00004597          	auipc	a1,0x4
    8000304c:	5d858593          	addi	a1,a1,1496 # 80007620 <states.1524+0x408>
    80003050:	0001d517          	auipc	a0,0x1d
    80003054:	b8050513          	addi	a0,a0,-1152 # 8001fbd0 <filecache>
    80003058:	ffffe097          	auipc	ra,0xffffe
    8000305c:	74c080e7          	jalr	1868(ra) # 800017a4 <initlock>
    for(int i = 0;i < NFILE;i++){
    80003060:	0001d797          	auipc	a5,0x1d
    80003064:	b8878793          	addi	a5,a5,-1144 # 8001fbe8 <filecache+0x18>
    80003068:	0001e717          	auipc	a4,0x1e
    8000306c:	80070713          	addi	a4,a4,-2048 # 80020868 <cons>
        filecache.files[i].type = FD_NONE;
    80003070:	0007a023          	sw	zero,0(a5)
        filecache.files[i].ref = 0;
    80003074:	0007a223          	sw	zero,4(a5)
    for(int i = 0;i < NFILE;i++){
    80003078:	02078793          	addi	a5,a5,32
    8000307c:	fee79ae3          	bne	a5,a4,80003070 <init_filecache+0x30>
    }
}
    80003080:	60a2                	ld	ra,8(sp)
    80003082:	6402                	ld	s0,0(sp)
    80003084:	0141                	addi	sp,sp,16
    80003086:	8082                	ret

0000000080003088 <filealloc>:

struct file* filealloc(){
    80003088:	1101                	addi	sp,sp,-32
    8000308a:	ec06                	sd	ra,24(sp)
    8000308c:	e822                	sd	s0,16(sp)
    8000308e:	e426                	sd	s1,8(sp)
    80003090:	1000                	addi	s0,sp,32
    struct file *f;
    acquire(&filecache.slock);
    80003092:	0001d517          	auipc	a0,0x1d
    80003096:	b3e50513          	addi	a0,a0,-1218 # 8001fbd0 <filecache>
    8000309a:	ffffe097          	auipc	ra,0xffffe
    8000309e:	796080e7          	jalr	1942(ra) # 80001830 <acquire>
    for(f = filecache.files; f < filecache.files + NFILE; f++){
    800030a2:	0001d497          	auipc	s1,0x1d
    800030a6:	b4648493          	addi	s1,s1,-1210 # 8001fbe8 <filecache+0x18>
    800030aa:	0001d717          	auipc	a4,0x1d
    800030ae:	7be70713          	addi	a4,a4,1982 # 80020868 <cons>
        if(f->ref == 0){
    800030b2:	40dc                	lw	a5,4(s1)
    800030b4:	cf99                	beqz	a5,800030d2 <filealloc+0x4a>
    for(f = filecache.files; f < filecache.files + NFILE; f++){
    800030b6:	02048493          	addi	s1,s1,32
    800030ba:	fee49ce3          	bne	s1,a4,800030b2 <filealloc+0x2a>
        f->ref = 1;
        release(&filecache.slock);
        return f;
        }
    }
    release(&filecache.slock);
    800030be:	0001d517          	auipc	a0,0x1d
    800030c2:	b1250513          	addi	a0,a0,-1262 # 8001fbd0 <filecache>
    800030c6:	fffff097          	auipc	ra,0xfffff
    800030ca:	82c080e7          	jalr	-2004(ra) # 800018f2 <release>
    return 0;
    800030ce:	4481                	li	s1,0
    800030d0:	a819                	j	800030e6 <filealloc+0x5e>
        f->ref = 1;
    800030d2:	4785                	li	a5,1
    800030d4:	c0dc                	sw	a5,4(s1)
        release(&filecache.slock);
    800030d6:	0001d517          	auipc	a0,0x1d
    800030da:	afa50513          	addi	a0,a0,-1286 # 8001fbd0 <filecache>
    800030de:	fffff097          	auipc	ra,0xfffff
    800030e2:	814080e7          	jalr	-2028(ra) # 800018f2 <release>
}
    800030e6:	8526                	mv	a0,s1
    800030e8:	60e2                	ld	ra,24(sp)
    800030ea:	6442                	ld	s0,16(sp)
    800030ec:	64a2                	ld	s1,8(sp)
    800030ee:	6105                	addi	sp,sp,32
    800030f0:	8082                	ret

00000000800030f2 <fileclose>:

void fileclose(struct file *f){
    800030f2:	7179                	addi	sp,sp,-48
    800030f4:	f406                	sd	ra,40(sp)
    800030f6:	f022                	sd	s0,32(sp)
    800030f8:	ec26                	sd	s1,24(sp)
    800030fa:	e84a                	sd	s2,16(sp)
    800030fc:	e44e                	sd	s3,8(sp)
    800030fe:	1800                	addi	s0,sp,48
    80003100:	84aa                	mv	s1,a0
    acquire(&filecache.slock);
    80003102:	0001d517          	auipc	a0,0x1d
    80003106:	ace50513          	addi	a0,a0,-1330 # 8001fbd0 <filecache>
    8000310a:	ffffe097          	auipc	ra,0xffffe
    8000310e:	726080e7          	jalr	1830(ra) # 80001830 <acquire>
    if(f->ref < 1){
    80003112:	40dc                	lw	a5,4(s1)
    80003114:	04f05363          	blez	a5,8000315a <fileclose+0x68>
        panic("fileclose f ref < 1");
    }
    if(--f->ref > 0){
    80003118:	40dc                	lw	a5,4(s1)
    8000311a:	37fd                	addiw	a5,a5,-1
    8000311c:	0007871b          	sext.w	a4,a5
    80003120:	c0dc                	sw	a5,4(s1)
    80003122:	04e04563          	bgtz	a4,8000316c <fileclose+0x7a>
        release(&filecache.slock);
        return;
    }
    struct file ff = *f;
    80003126:	0004a903          	lw	s2,0(s1)
    8000312a:	0104b983          	ld	s3,16(s1)
    f->ref = 0;
    8000312e:	0004a223          	sw	zero,4(s1)
    f->type = FD_NONE;
    80003132:	0004a023          	sw	zero,0(s1)
    release(&filecache.slock);
    80003136:	0001d517          	auipc	a0,0x1d
    8000313a:	a9a50513          	addi	a0,a0,-1382 # 8001fbd0 <filecache>
    8000313e:	ffffe097          	auipc	ra,0xffffe
    80003142:	7b4080e7          	jalr	1972(ra) # 800018f2 <release>

    if(ff.type == FD_PIPE){
    80003146:	3979                	addiw	s2,s2,-2
    80003148:	4785                	li	a5,1
    8000314a:	0327e963          	bltu	a5,s2,8000317c <fileclose+0x8a>

    }else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
        iput(ff.ip);
    8000314e:	854e                	mv	a0,s3
    80003150:	00000097          	auipc	ra,0x0
    80003154:	bb6080e7          	jalr	-1098(ra) # 80002d06 <iput>
    80003158:	a015                	j	8000317c <fileclose+0x8a>
        panic("fileclose f ref < 1");
    8000315a:	00004517          	auipc	a0,0x4
    8000315e:	4d650513          	addi	a0,a0,1238 # 80007630 <states.1524+0x418>
    80003162:	ffffd097          	auipc	ra,0xffffd
    80003166:	322080e7          	jalr	802(ra) # 80000484 <panic>
    8000316a:	b77d                	j	80003118 <fileclose+0x26>
        release(&filecache.slock);
    8000316c:	0001d517          	auipc	a0,0x1d
    80003170:	a6450513          	addi	a0,a0,-1436 # 8001fbd0 <filecache>
    80003174:	ffffe097          	auipc	ra,0xffffe
    80003178:	77e080e7          	jalr	1918(ra) # 800018f2 <release>
    }
}
    8000317c:	70a2                	ld	ra,40(sp)
    8000317e:	7402                	ld	s0,32(sp)
    80003180:	64e2                	ld	s1,24(sp)
    80003182:	6942                	ld	s2,16(sp)
    80003184:	69a2                	ld	s3,8(sp)
    80003186:	6145                	addi	sp,sp,48
    80003188:	8082                	ret

000000008000318a <filewrite>:

int filewrite(struct file *f,uint64 p,int n){
    if(f->writable == 0){
    8000318a:	00954703          	lbu	a4,9(a0)
    8000318e:	c335                	beqz	a4,800031f2 <filewrite+0x68>
    80003190:	87aa                	mv	a5,a0
        return -1;
    }
    int ret = 0;
    if(f->type == FD_PIPE){
    80003192:	4118                	lw	a4,0(a0)
    80003194:	4685                	li	a3,1
        ret = 1;
    80003196:	4505                	li	a0,1
    if(f->type == FD_PIPE){
    80003198:	06d70363          	beq	a4,a3,800031fe <filewrite+0x74>
int filewrite(struct file *f,uint64 p,int n){
    8000319c:	1141                	addi	sp,sp,-16
    8000319e:	e406                	sd	ra,8(sp)
    800031a0:	e022                	sd	s0,0(sp)
    800031a2:	0800                	addi	s0,sp,16
    }else if(f->type == FD_DEVICE){
    800031a4:	468d                	li	a3,3
    800031a6:	00d70a63          	beq	a4,a3,800031ba <filewrite+0x30>
        if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write){
           return -1;
        }
        ret = devsw[f->major].write(1, p, n);
    }else if(f->type == FD_INODE){
    800031aa:	4789                	li	a5,2
    int ret = 0;
    800031ac:	4501                	li	a0,0
    }else if(f->type == FD_INODE){
    800031ae:	02f71863          	bne	a4,a5,800031de <filewrite+0x54>
       
    }else{
        panic("filewrite");
    }
    return ret;
}
    800031b2:	60a2                	ld	ra,8(sp)
    800031b4:	6402                	ld	s0,0(sp)
    800031b6:	0141                	addi	sp,sp,16
    800031b8:	8082                	ret
        if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write){
    800031ba:	01c79783          	lh	a5,28(a5)
    800031be:	03079693          	slli	a3,a5,0x30
    800031c2:	92c1                	srli	a3,a3,0x30
    800031c4:	4725                	li	a4,9
    800031c6:	02d76863          	bltu	a4,a3,800031f6 <filewrite+0x6c>
    800031ca:	0792                	slli	a5,a5,0x4
    800031cc:	0001d717          	auipc	a4,0x1d
    800031d0:	96470713          	addi	a4,a4,-1692 # 8001fb30 <devsw>
    800031d4:	97ba                	add	a5,a5,a4
    800031d6:	679c                	ld	a5,8(a5)
    800031d8:	c38d                	beqz	a5,800031fa <filewrite+0x70>
        ret = devsw[f->major].write(1, p, n);
    800031da:	9782                	jalr	a5
    800031dc:	bfd9                	j	800031b2 <filewrite+0x28>
        panic("filewrite");
    800031de:	00004517          	auipc	a0,0x4
    800031e2:	46a50513          	addi	a0,a0,1130 # 80007648 <states.1524+0x430>
    800031e6:	ffffd097          	auipc	ra,0xffffd
    800031ea:	29e080e7          	jalr	670(ra) # 80000484 <panic>
    int ret = 0;
    800031ee:	4501                	li	a0,0
    800031f0:	b7c9                	j	800031b2 <filewrite+0x28>
        return -1;
    800031f2:	557d                	li	a0,-1
    800031f4:	8082                	ret
           return -1;
    800031f6:	557d                	li	a0,-1
    800031f8:	bf6d                	j	800031b2 <filewrite+0x28>
    800031fa:	557d                	li	a0,-1
    800031fc:	bf5d                	j	800031b2 <filewrite+0x28>
}
    800031fe:	8082                	ret

0000000080003200 <fileread>:

int fileread(struct file *f,uint64 p,int n){
    if(f->readable == 0){
    80003200:	00854703          	lbu	a4,8(a0)
    80003204:	c331                	beqz	a4,80003248 <fileread+0x48>
    80003206:	87aa                	mv	a5,a0
        return -1;
    }
    int ret = 0;
    if(f->type == T_DEVICE){
    80003208:	4114                	lw	a3,0(a0)
    8000320a:	470d                	li	a4,3
    int ret = 0;
    8000320c:	4501                	li	a0,0
    if(f->type == T_DEVICE){
    8000320e:	00e68363          	beq	a3,a4,80003214 <fileread+0x14>
            return -1;
        }
        ret = devsw[f->major].read(1,p,n);
    }
    return ret;
}
    80003212:	8082                	ret
        if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read){
    80003214:	01c79783          	lh	a5,28(a5)
    80003218:	03079693          	slli	a3,a5,0x30
    8000321c:	92c1                	srli	a3,a3,0x30
    8000321e:	4725                	li	a4,9
    80003220:	02d76663          	bltu	a4,a3,8000324c <fileread+0x4c>
    80003224:	0792                	slli	a5,a5,0x4
    80003226:	0001d717          	auipc	a4,0x1d
    8000322a:	90a70713          	addi	a4,a4,-1782 # 8001fb30 <devsw>
    8000322e:	97ba                	add	a5,a5,a4
    80003230:	639c                	ld	a5,0(a5)
    80003232:	cf99                	beqz	a5,80003250 <fileread+0x50>
int fileread(struct file *f,uint64 p,int n){
    80003234:	1141                	addi	sp,sp,-16
    80003236:	e406                	sd	ra,8(sp)
    80003238:	e022                	sd	s0,0(sp)
    8000323a:	0800                	addi	s0,sp,16
        ret = devsw[f->major].read(1,p,n);
    8000323c:	4505                	li	a0,1
    8000323e:	9782                	jalr	a5
}
    80003240:	60a2                	ld	ra,8(sp)
    80003242:	6402                	ld	s0,0(sp)
    80003244:	0141                	addi	sp,sp,16
    80003246:	8082                	ret
        return -1;
    80003248:	557d                	li	a0,-1
    8000324a:	8082                	ret
            return -1;
    8000324c:	557d                	li	a0,-1
    8000324e:	8082                	ret
    80003250:	557d                	li	a0,-1
    80003252:	8082                	ret

0000000080003254 <filedup>:


struct  file* filedup(struct file* f){
    80003254:	1101                	addi	sp,sp,-32
    80003256:	ec06                	sd	ra,24(sp)
    80003258:	e822                	sd	s0,16(sp)
    8000325a:	e426                	sd	s1,8(sp)
    8000325c:	1000                	addi	s0,sp,32
    8000325e:	84aa                	mv	s1,a0
    acquire(&filecache.slock);
    80003260:	0001d517          	auipc	a0,0x1d
    80003264:	97050513          	addi	a0,a0,-1680 # 8001fbd0 <filecache>
    80003268:	ffffe097          	auipc	ra,0xffffe
    8000326c:	5c8080e7          	jalr	1480(ra) # 80001830 <acquire>
    if(f->ref < 1){
    80003270:	40dc                	lw	a5,4(s1)
    80003272:	02f05363          	blez	a5,80003298 <filedup+0x44>
        panic("filedup | target file ref < 1..");
    }
    f->ref++;
    80003276:	40dc                	lw	a5,4(s1)
    80003278:	2785                	addiw	a5,a5,1
    8000327a:	c0dc                	sw	a5,4(s1)
    release(&filecache.slock);
    8000327c:	0001d517          	auipc	a0,0x1d
    80003280:	95450513          	addi	a0,a0,-1708 # 8001fbd0 <filecache>
    80003284:	ffffe097          	auipc	ra,0xffffe
    80003288:	66e080e7          	jalr	1646(ra) # 800018f2 <release>
    return f;
} 
    8000328c:	8526                	mv	a0,s1
    8000328e:	60e2                	ld	ra,24(sp)
    80003290:	6442                	ld	s0,16(sp)
    80003292:	64a2                	ld	s1,8(sp)
    80003294:	6105                	addi	sp,sp,32
    80003296:	8082                	ret
        panic("filedup | target file ref < 1..");
    80003298:	00004517          	auipc	a0,0x4
    8000329c:	3c050513          	addi	a0,a0,960 # 80007658 <states.1524+0x440>
    800032a0:	ffffd097          	auipc	ra,0xffffd
    800032a4:	1e4080e7          	jalr	484(ra) # 80000484 <panic>
    800032a8:	b7f9                	j	80003276 <filedup+0x22>

00000000800032aa <filestat>:

uint64 filestat(struct file *f,uint64 addr){
    800032aa:	715d                	addi	sp,sp,-80
    800032ac:	e486                	sd	ra,72(sp)
    800032ae:	e0a2                	sd	s0,64(sp)
    800032b0:	fc26                	sd	s1,56(sp)
    800032b2:	f84a                	sd	s2,48(sp)
    800032b4:	f44e                	sd	s3,40(sp)
    800032b6:	0880                	addi	s0,sp,80
    800032b8:	84aa                	mv	s1,a0
    800032ba:	89ae                	mv	s3,a1
    struct proc *p = myproc();
    800032bc:	ffffd097          	auipc	ra,0xffffd
    800032c0:	2e6080e7          	jalr	742(ra) # 800005a2 <myproc>
    struct stat st;
    if(f->type == FD_INODE || f->type == FD_DEVICE){
    800032c4:	409c                	lw	a5,0(s1)
    800032c6:	37f9                	addiw	a5,a5,-2
    800032c8:	4705                	li	a4,1
    800032ca:	00f77a63          	bgeu	a4,a5,800032de <filestat+0x34>
    if(copyoutpg(p->pagetable, addr, (char *)&st, sizeof(st)) < 0){
      return -1;
    }
    return 0;
  }
  return -1;
    800032ce:	557d                	li	a0,-1
    800032d0:	60a6                	ld	ra,72(sp)
    800032d2:	6406                	ld	s0,64(sp)
    800032d4:	74e2                	ld	s1,56(sp)
    800032d6:	7942                	ld	s2,48(sp)
    800032d8:	79a2                	ld	s3,40(sp)
    800032da:	6161                	addi	sp,sp,80
    800032dc:	8082                	ret
    800032de:	892a                	mv	s2,a0
    ilock(f->ip);
    800032e0:	6888                	ld	a0,16(s1)
    800032e2:	fffff097          	auipc	ra,0xfffff
    800032e6:	6e8080e7          	jalr	1768(ra) # 800029ca <ilock>
    stati(f->ip, &st);
    800032ea:	fb840593          	addi	a1,s0,-72
    800032ee:	6888                	ld	a0,16(s1)
    800032f0:	00000097          	auipc	ra,0x0
    800032f4:	d26080e7          	jalr	-730(ra) # 80003016 <stati>
    iunlock(f->ip);
    800032f8:	6888                	ld	a0,16(s1)
    800032fa:	fffff097          	auipc	ra,0xfffff
    800032fe:	7cc080e7          	jalr	1996(ra) # 80002ac6 <iunlock>
    if(copyoutpg(p->pagetable, addr, (char *)&st, sizeof(st)) < 0){
    80003302:	46e1                	li	a3,24
    80003304:	fb840613          	addi	a2,s0,-72
    80003308:	85ce                	mv	a1,s3
    8000330a:	06893503          	ld	a0,104(s2)
    8000330e:	00000097          	auipc	ra,0x0
    80003312:	7ae080e7          	jalr	1966(ra) # 80003abc <copyoutpg>
    80003316:	957d                	srai	a0,a0,0x3f
    80003318:	bf65                	j	800032d0 <filestat+0x26>

000000008000331a <consolewrite>:
    uint r;
    uint w;
    uint e;
} cons;

int consolewrite(int user_src,uint64 src,int n){
    8000331a:	715d                	addi	sp,sp,-80
    8000331c:	e486                	sd	ra,72(sp)
    8000331e:	e0a2                	sd	s0,64(sp)
    80003320:	fc26                	sd	s1,56(sp)
    80003322:	f84a                	sd	s2,48(sp)
    80003324:	f44e                	sd	s3,40(sp)
    80003326:	f052                	sd	s4,32(sp)
    80003328:	ec56                	sd	s5,24(sp)
    8000332a:	0880                	addi	s0,sp,80
    int i;
    for(i = 0; i< n;i++){
    8000332c:	04c05663          	blez	a2,80003378 <consolewrite+0x5e>
    80003330:	8a2a                	mv	s4,a0
    80003332:	84ae                	mv	s1,a1
    80003334:	89b2                	mv	s3,a2
    80003336:	4901                	li	s2,0
        char c;
        if(either_copyin(&c,user_src,src+i,1) == -1){
    80003338:	5afd                	li	s5,-1
    8000333a:	4685                	li	a3,1
    8000333c:	8626                	mv	a2,s1
    8000333e:	85d2                	mv	a1,s4
    80003340:	fbf40513          	addi	a0,s0,-65
    80003344:	00001097          	auipc	ra,0x1
    80003348:	85a080e7          	jalr	-1958(ra) # 80003b9e <either_copyin>
    8000334c:	01550c63          	beq	a0,s5,80003364 <consolewrite+0x4a>
            break;
        }
        uartputc(c);
    80003350:	fbf44503          	lbu	a0,-65(s0)
    80003354:	ffffe097          	auipc	ra,0xffffe
    80003358:	f08080e7          	jalr	-248(ra) # 8000125c <uartputc>
    for(i = 0; i< n;i++){
    8000335c:	2905                	addiw	s2,s2,1
    8000335e:	0485                	addi	s1,s1,1
    80003360:	fd299de3          	bne	s3,s2,8000333a <consolewrite+0x20>
    }
    return i;
}
    80003364:	854a                	mv	a0,s2
    80003366:	60a6                	ld	ra,72(sp)
    80003368:	6406                	ld	s0,64(sp)
    8000336a:	74e2                	ld	s1,56(sp)
    8000336c:	7942                	ld	s2,48(sp)
    8000336e:	79a2                	ld	s3,40(sp)
    80003370:	7a02                	ld	s4,32(sp)
    80003372:	6ae2                	ld	s5,24(sp)
    80003374:	6161                	addi	sp,sp,80
    80003376:	8082                	ret
    for(i = 0; i< n;i++){
    80003378:	4901                	li	s2,0
    8000337a:	b7ed                	j	80003364 <consolewrite+0x4a>

000000008000337c <consoleread>:

int consoleread(int user_dst,uint64 dst,int n){
    8000337c:	7119                	addi	sp,sp,-128
    8000337e:	fc86                	sd	ra,120(sp)
    80003380:	f8a2                	sd	s0,112(sp)
    80003382:	f4a6                	sd	s1,104(sp)
    80003384:	f0ca                	sd	s2,96(sp)
    80003386:	ecce                	sd	s3,88(sp)
    80003388:	e8d2                	sd	s4,80(sp)
    8000338a:	e4d6                	sd	s5,72(sp)
    8000338c:	e0da                	sd	s6,64(sp)
    8000338e:	fc5e                	sd	s7,56(sp)
    80003390:	f862                	sd	s8,48(sp)
    80003392:	f466                	sd	s9,40(sp)
    80003394:	f06a                	sd	s10,32(sp)
    80003396:	ec6e                	sd	s11,24(sp)
    80003398:	0100                	addi	s0,sp,128
    8000339a:	8b2a                	mv	s6,a0
    8000339c:	8aae                	mv	s5,a1
    8000339e:	8a32                	mv	s4,a2
    acquire(&cons.slock);
    800033a0:	0001d517          	auipc	a0,0x1d
    800033a4:	4c850513          	addi	a0,a0,1224 # 80020868 <cons>
    800033a8:	ffffe097          	auipc	ra,0xffffe
    800033ac:	488080e7          	jalr	1160(ra) # 80001830 <acquire>

    int target = n;
    while (n > 0) {
    800033b0:	09405663          	blez	s4,8000343c <consoleread+0xc0>
    800033b4:	8bd2                	mv	s7,s4
        while (cons.r == cons.w) {
    800033b6:	0001d497          	auipc	s1,0x1d
    800033ba:	4b248493          	addi	s1,s1,1202 # 80020868 <cons>
            if(myproc()->killed) {
                release(&cons.slock);
                return -1;
            }
            sleep(&cons.r, &cons.slock);
    800033be:	89a6                	mv	s3,s1
    800033c0:	0001d917          	auipc	s2,0x1d
    800033c4:	54090913          	addi	s2,s2,1344 # 80020900 <cons+0x98>
        }
        char c = cons.buf[cons.r++ % INPUT_MAX];
        if(c == C('D')){
    800033c8:	4c91                	li	s9,4
                cons.r --;
            }
            break;
        }
        char cbuf = c;
        if(either_copyout(user_dst, dst, &cbuf, 1) == -1){
    800033ca:	5d7d                	li	s10,-1
            break;
        }

        dst++;
        --n;
        if(c == '\n'){
    800033cc:	4da9                	li	s11,10
        while (cons.r == cons.w) {
    800033ce:	0984a783          	lw	a5,152(s1)
    800033d2:	09c4a703          	lw	a4,156(s1)
    800033d6:	02f71463          	bne	a4,a5,800033fe <consoleread+0x82>
            if(myproc()->killed) {
    800033da:	ffffd097          	auipc	ra,0xffffd
    800033de:	1c8080e7          	jalr	456(ra) # 800005a2 <myproc>
    800033e2:	595c                	lw	a5,52(a0)
    800033e4:	eba5                	bnez	a5,80003454 <consoleread+0xd8>
            sleep(&cons.r, &cons.slock);
    800033e6:	85ce                	mv	a1,s3
    800033e8:	854a                	mv	a0,s2
    800033ea:	ffffd097          	auipc	ra,0xffffd
    800033ee:	63c080e7          	jalr	1596(ra) # 80000a26 <sleep>
        while (cons.r == cons.w) {
    800033f2:	0984a783          	lw	a5,152(s1)
    800033f6:	09c4a703          	lw	a4,156(s1)
    800033fa:	fef700e3          	beq	a4,a5,800033da <consoleread+0x5e>
        char c = cons.buf[cons.r++ % INPUT_MAX];
    800033fe:	0017871b          	addiw	a4,a5,1
    80003402:	08e4ac23          	sw	a4,152(s1)
    80003406:	07f7f713          	andi	a4,a5,127
    8000340a:	9726                	add	a4,a4,s1
    8000340c:	01874c03          	lbu	s8,24(a4)
        if(c == C('D')){
    80003410:	079c0a63          	beq	s8,s9,80003484 <consoleread+0x108>
        char cbuf = c;
    80003414:	f98407a3          	sb	s8,-113(s0)
        if(either_copyout(user_dst, dst, &cbuf, 1) == -1){
    80003418:	4685                	li	a3,1
    8000341a:	f8f40613          	addi	a2,s0,-113
    8000341e:	85d6                	mv	a1,s5
    80003420:	855a                	mv	a0,s6
    80003422:	00000097          	auipc	ra,0x0
    80003426:	726080e7          	jalr	1830(ra) # 80003b48 <either_copyout>
    8000342a:	01a50a63          	beq	a0,s10,8000343e <consoleread+0xc2>
        dst++;
    8000342e:	0a85                	addi	s5,s5,1
        --n;
    80003430:	3bfd                	addiw	s7,s7,-1
        if(c == '\n'){
    80003432:	01bc0663          	beq	s8,s11,8000343e <consoleread+0xc2>
    while (n > 0) {
    80003436:	f80b9ce3          	bnez	s7,800033ce <consoleread+0x52>
    8000343a:	a011                	j	8000343e <consoleread+0xc2>
    8000343c:	8bd2                	mv	s7,s4
            break;
        }
    }
    release(&cons.slock);
    8000343e:	0001d517          	auipc	a0,0x1d
    80003442:	42a50513          	addi	a0,a0,1066 # 80020868 <cons>
    80003446:	ffffe097          	auipc	ra,0xffffe
    8000344a:	4ac080e7          	jalr	1196(ra) # 800018f2 <release>
    return target - n;
    8000344e:	417a053b          	subw	a0,s4,s7
    80003452:	a811                	j	80003466 <consoleread+0xea>
                release(&cons.slock);
    80003454:	0001d517          	auipc	a0,0x1d
    80003458:	41450513          	addi	a0,a0,1044 # 80020868 <cons>
    8000345c:	ffffe097          	auipc	ra,0xffffe
    80003460:	496080e7          	jalr	1174(ra) # 800018f2 <release>
                return -1;
    80003464:	557d                	li	a0,-1
}
    80003466:	70e6                	ld	ra,120(sp)
    80003468:	7446                	ld	s0,112(sp)
    8000346a:	74a6                	ld	s1,104(sp)
    8000346c:	7906                	ld	s2,96(sp)
    8000346e:	69e6                	ld	s3,88(sp)
    80003470:	6a46                	ld	s4,80(sp)
    80003472:	6aa6                	ld	s5,72(sp)
    80003474:	6b06                	ld	s6,64(sp)
    80003476:	7be2                	ld	s7,56(sp)
    80003478:	7c42                	ld	s8,48(sp)
    8000347a:	7ca2                	ld	s9,40(sp)
    8000347c:	7d02                	ld	s10,32(sp)
    8000347e:	6de2                	ld	s11,24(sp)
    80003480:	6109                	addi	sp,sp,128
    80003482:	8082                	ret
            if(n < target){
    80003484:	fb4bdde3          	bge	s7,s4,8000343e <consoleread+0xc2>
                cons.r --;
    80003488:	0001d717          	auipc	a4,0x1d
    8000348c:	46f72c23          	sw	a5,1144(a4) # 80020900 <cons+0x98>
    80003490:	b77d                	j	8000343e <consoleread+0xc2>

0000000080003492 <consoleinit>:

void consoleinit(){
    80003492:	1141                	addi	sp,sp,-16
    80003494:	e406                	sd	ra,8(sp)
    80003496:	e022                	sd	s0,0(sp)
    80003498:	0800                	addi	s0,sp,16
    initlock(&cons.slock,"console");
    8000349a:	00004597          	auipc	a1,0x4
    8000349e:	1de58593          	addi	a1,a1,478 # 80007678 <states.1524+0x460>
    800034a2:	0001d517          	auipc	a0,0x1d
    800034a6:	3c650513          	addi	a0,a0,966 # 80020868 <cons>
    800034aa:	ffffe097          	auipc	ra,0xffffe
    800034ae:	2fa080e7          	jalr	762(ra) # 800017a4 <initlock>

    devsw[CONSOLE].read = consoleread;
    800034b2:	0001c797          	auipc	a5,0x1c
    800034b6:	67e78793          	addi	a5,a5,1662 # 8001fb30 <devsw>
    800034ba:	00000717          	auipc	a4,0x0
    800034be:	ec270713          	addi	a4,a4,-318 # 8000337c <consoleread>
    800034c2:	eb98                	sd	a4,16(a5)
    devsw[CONSOLE].write = consolewrite;
    800034c4:	00000717          	auipc	a4,0x0
    800034c8:	e5670713          	addi	a4,a4,-426 # 8000331a <consolewrite>
    800034cc:	ef98                	sd	a4,24(a5)
}
    800034ce:	60a2                	ld	ra,8(sp)
    800034d0:	6402                	ld	s0,0(sp)
    800034d2:	0141                	addi	sp,sp,16
    800034d4:	8082                	ret

00000000800034d6 <consoleintr>:



void consoleintr(int c){
    800034d6:	1101                	addi	sp,sp,-32
    800034d8:	ec06                	sd	ra,24(sp)
    800034da:	e822                	sd	s0,16(sp)
    800034dc:	e426                	sd	s1,8(sp)
    800034de:	e04a                	sd	s2,0(sp)
    800034e0:	1000                	addi	s0,sp,32
    800034e2:	84aa                	mv	s1,a0
    acquire(&cons.slock);
    800034e4:	0001d517          	auipc	a0,0x1d
    800034e8:	38450513          	addi	a0,a0,900 # 80020868 <cons>
    800034ec:	ffffe097          	auipc	ra,0xffffe
    800034f0:	344080e7          	jalr	836(ra) # 80001830 <acquire>
    switch (c) {
    800034f4:	47d5                	li	a5,21
    800034f6:	08f48063          	beq	s1,a5,80003576 <consoleintr+0xa0>
    800034fa:	07f00793          	li	a5,127
    800034fe:	0cf48263          	beq	s1,a5,800035c2 <consoleintr+0xec>
    80003502:	47a1                	li	a5,8
    80003504:	0af48f63          	beq	s1,a5,800035c2 <consoleintr+0xec>
            cons.e--;
            consputc(BACKSPACE);
        }
        break;
    default:
        if(c != 0 && cons.e - cons.r < INPUT_MAX){
    80003508:	c4f9                	beqz	s1,800035d6 <consoleintr+0x100>
    8000350a:	0001d717          	auipc	a4,0x1d
    8000350e:	35e70713          	addi	a4,a4,862 # 80020868 <cons>
    80003512:	0a072783          	lw	a5,160(a4)
    80003516:	09872703          	lw	a4,152(a4)
    8000351a:	9f99                	subw	a5,a5,a4
    8000351c:	07f00713          	li	a4,127
    80003520:	0af76b63          	bltu	a4,a5,800035d6 <consoleintr+0x100>
            c = (c == '\r') ? '\n' : c;
    80003524:	47b5                	li	a5,13
    80003526:	0ef48263          	beq	s1,a5,8000360a <consoleintr+0x134>
            consputc(c);
    8000352a:	8526                	mv	a0,s1
    8000352c:	ffffe097          	auipc	ra,0xffffe
    80003530:	e86080e7          	jalr	-378(ra) # 800013b2 <consputc>
            cons.buf[cons.e++ % INPUT_MAX] = c;
    80003534:	0001d797          	auipc	a5,0x1d
    80003538:	33478793          	addi	a5,a5,820 # 80020868 <cons>
    8000353c:	0a07a703          	lw	a4,160(a5)
    80003540:	0017069b          	addiw	a3,a4,1
    80003544:	0006861b          	sext.w	a2,a3
    80003548:	0ad7a023          	sw	a3,160(a5)
    8000354c:	07f77713          	andi	a4,a4,127
    80003550:	97ba                	add	a5,a5,a4
    80003552:	00978c23          	sb	s1,24(a5)
            if((c == '\n' || c == C('D')) || cons.e == cons.r + INPUT_MAX){
    80003556:	47a9                	li	a5,10
    80003558:	0ef48063          	beq	s1,a5,80003638 <consoleintr+0x162>
    8000355c:	4791                	li	a5,4
    8000355e:	0cf48d63          	beq	s1,a5,80003638 <consoleintr+0x162>
    80003562:	0001d797          	auipc	a5,0x1d
    80003566:	39e7a783          	lw	a5,926(a5) # 80020900 <cons+0x98>
    8000356a:	0807879b          	addiw	a5,a5,128
    8000356e:	06f61463          	bne	a2,a5,800035d6 <consoleintr+0x100>
            cons.buf[cons.e++ % INPUT_MAX] = c;
    80003572:	863e                	mv	a2,a5
    80003574:	a0d1                	j	80003638 <consoleintr+0x162>
        while(cons.e != cons.w &&
    80003576:	0001d717          	auipc	a4,0x1d
    8000357a:	2f270713          	addi	a4,a4,754 # 80020868 <cons>
    8000357e:	0a072783          	lw	a5,160(a4)
    80003582:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_MAX] != '\n'){
    80003586:	0001d497          	auipc	s1,0x1d
    8000358a:	2e248493          	addi	s1,s1,738 # 80020868 <cons>
        while(cons.e != cons.w &&
    8000358e:	4929                	li	s2,10
    80003590:	04f70363          	beq	a4,a5,800035d6 <consoleintr+0x100>
          cons.buf[(cons.e-1) % INPUT_MAX] != '\n'){
    80003594:	37fd                	addiw	a5,a5,-1
    80003596:	07f7f713          	andi	a4,a5,127
    8000359a:	9726                	add	a4,a4,s1
        while(cons.e != cons.w &&
    8000359c:	01874703          	lbu	a4,24(a4)
    800035a0:	03270b63          	beq	a4,s2,800035d6 <consoleintr+0x100>
            cons.e--;
    800035a4:	0af4a023          	sw	a5,160(s1)
            consputc(BACKSPACE);
    800035a8:	10000513          	li	a0,256
    800035ac:	ffffe097          	auipc	ra,0xffffe
    800035b0:	e06080e7          	jalr	-506(ra) # 800013b2 <consputc>
        while(cons.e != cons.w &&
    800035b4:	0a04a783          	lw	a5,160(s1)
    800035b8:	09c4a703          	lw	a4,156(s1)
    800035bc:	fcf71ce3          	bne	a4,a5,80003594 <consoleintr+0xbe>
    800035c0:	a819                	j	800035d6 <consoleintr+0x100>
        if(cons.e != cons.w){
    800035c2:	0001d717          	auipc	a4,0x1d
    800035c6:	2a670713          	addi	a4,a4,678 # 80020868 <cons>
    800035ca:	0a072783          	lw	a5,160(a4)
    800035ce:	09c72703          	lw	a4,156(a4)
    800035d2:	02f71063          	bne	a4,a5,800035f2 <consoleintr+0x11c>
                wakeup(&cons.r);
            }
        }
        break;
    }
    release(&cons.slock);
    800035d6:	0001d517          	auipc	a0,0x1d
    800035da:	29250513          	addi	a0,a0,658 # 80020868 <cons>
    800035de:	ffffe097          	auipc	ra,0xffffe
    800035e2:	314080e7          	jalr	788(ra) # 800018f2 <release>
}
    800035e6:	60e2                	ld	ra,24(sp)
    800035e8:	6442                	ld	s0,16(sp)
    800035ea:	64a2                	ld	s1,8(sp)
    800035ec:	6902                	ld	s2,0(sp)
    800035ee:	6105                	addi	sp,sp,32
    800035f0:	8082                	ret
            cons.e--;
    800035f2:	37fd                	addiw	a5,a5,-1
    800035f4:	0001d717          	auipc	a4,0x1d
    800035f8:	30f72a23          	sw	a5,788(a4) # 80020908 <cons+0xa0>
            consputc(BACKSPACE);
    800035fc:	10000513          	li	a0,256
    80003600:	ffffe097          	auipc	ra,0xffffe
    80003604:	db2080e7          	jalr	-590(ra) # 800013b2 <consputc>
    80003608:	b7f9                	j	800035d6 <consoleintr+0x100>
            consputc(c);
    8000360a:	4529                	li	a0,10
    8000360c:	ffffe097          	auipc	ra,0xffffe
    80003610:	da6080e7          	jalr	-602(ra) # 800013b2 <consputc>
            cons.buf[cons.e++ % INPUT_MAX] = c;
    80003614:	0001d797          	auipc	a5,0x1d
    80003618:	25478793          	addi	a5,a5,596 # 80020868 <cons>
    8000361c:	0a07a703          	lw	a4,160(a5)
    80003620:	0017069b          	addiw	a3,a4,1
    80003624:	0006861b          	sext.w	a2,a3
    80003628:	0ad7a023          	sw	a3,160(a5)
    8000362c:	07f77713          	andi	a4,a4,127
    80003630:	97ba                	add	a5,a5,a4
    80003632:	4729                	li	a4,10
    80003634:	00e78c23          	sb	a4,24(a5)
                cons.w = cons.e;
    80003638:	0001d797          	auipc	a5,0x1d
    8000363c:	2cc7a623          	sw	a2,716(a5) # 80020904 <cons+0x9c>
                wakeup(&cons.r);
    80003640:	0001d517          	auipc	a0,0x1d
    80003644:	2c050513          	addi	a0,a0,704 # 80020900 <cons+0x98>
    80003648:	ffffd097          	auipc	ra,0xffffd
    8000364c:	fda080e7          	jalr	-38(ra) # 80000622 <wakeup>
    80003650:	b759                	j	800035d6 <consoleintr+0x100>

0000000080003652 <exec>:
        }
    }
    return 0;
}

int exec(char *path,char** argv){
    80003652:	de010113          	addi	sp,sp,-544
    80003656:	20113c23          	sd	ra,536(sp)
    8000365a:	20813823          	sd	s0,528(sp)
    8000365e:	20913423          	sd	s1,520(sp)
    80003662:	21213023          	sd	s2,512(sp)
    80003666:	ffce                	sd	s3,504(sp)
    80003668:	fbd2                	sd	s4,496(sp)
    8000366a:	f7d6                	sd	s5,488(sp)
    8000366c:	f3da                	sd	s6,480(sp)
    8000366e:	efde                	sd	s7,472(sp)
    80003670:	ebe2                	sd	s8,464(sp)
    80003672:	e7e6                	sd	s9,456(sp)
    80003674:	e3ea                	sd	s10,448(sp)
    80003676:	ff6e                	sd	s11,440(sp)
    80003678:	1400                	addi	s0,sp,544
    8000367a:	8aae                	mv	s5,a1
    if(*path == '/'){
    8000367c:	00054783          	lbu	a5,0(a0)
        path+=1;
    80003680:	fd178793          	addi	a5,a5,-47
    80003684:	0017b793          	seqz	a5,a5
    80003688:	97aa                	add	a5,a5,a0
    8000368a:	def43c23          	sd	a5,-520(s0)
    }
    struct inode *app = rootsub(path);
    8000368e:	853e                	mv	a0,a5
    80003690:	fffff097          	auipc	ra,0xfffff
    80003694:	746080e7          	jalr	1862(ra) # 80002dd6 <rootsub>
    80003698:	e0a43423          	sd	a0,-504(s0)
    ilock(app);
    8000369c:	fffff097          	auipc	ra,0xfffff
    800036a0:	32e080e7          	jalr	814(ra) # 800029ca <ilock>
    struct proc *p = myproc(); 
    800036a4:	ffffd097          	auipc	ra,0xffffd
    800036a8:	efe080e7          	jalr	-258(ra) # 800005a2 <myproc>
    800036ac:	dea43423          	sd	a0,-536(s0)

    pagetable_t pagetable = proc_pagetable(p);
    800036b0:	ffffd097          	auipc	ra,0xffffd
    800036b4:	602080e7          	jalr	1538(ra) # 80000cb2 <proc_pagetable>
    800036b8:	8b2a                	mv	s6,a0
    if(pagetable == 0){
    800036ba:	c539                	beqz	a0,80003708 <exec+0xb6>
    }
    uint64 sz = 0;

    struct elfhdr elf;
    struct proghdr ph;
    if(readi(app,0,(uint64)&elf,0,sizeof(elf)) != sizeof(elf)){
    800036bc:	04000713          	li	a4,64
    800036c0:	4681                	li	a3,0
    800036c2:	f5040613          	addi	a2,s0,-176
    800036c6:	4581                	li	a1,0
    800036c8:	e0843503          	ld	a0,-504(s0)
    800036cc:	fffff097          	auipc	ra,0xfffff
    800036d0:	0ac080e7          	jalr	172(ra) # 80002778 <readi>
    800036d4:	04000793          	li	a5,64
    800036d8:	04f51163          	bne	a0,a5,8000371a <exec+0xc8>
        panic("readi panic");
    }
    if(elf.magic != ELF_MAGIC){
    800036dc:	f5042703          	lw	a4,-176(s0)
    800036e0:	464c47b7          	lui	a5,0x464c4
    800036e4:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800036e8:	04f71263          	bne	a4,a5,8000372c <exec+0xda>
        panic("ELF MAGIC Panic");
    }
    int i,off;
    for(i=0,off=elf.phoff; i< elf.phnum;i++,off+=sizeof(ph)){
    800036ec:	f7042983          	lw	s3,-144(s0)
    800036f0:	f8845783          	lhu	a5,-120(s0)
    800036f4:	cff5                	beqz	a5,800037f0 <exec+0x19e>
    800036f6:	4b81                	li	s7,0
    uint64 sz = 0;
    800036f8:	e0043023          	sd	zero,-512(s0)
        uint64 sz1;
        if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0){
            panic("loadseg uvmalloc panic");
        }
        sz = sz1;
        if((ph.vaddr % PGSIZE) != 0){
    800036fc:	6c05                	lui	s8,0x1
    800036fe:	fffc0793          	addi	a5,s8,-1 # fff <_entry-0x7ffff001>
    80003702:	def43823          	sd	a5,-528(s0)
    80003706:	a4c1                	j	800039c6 <exec+0x374>
        panic("exec proc_pagetable panic\n");
    80003708:	00004517          	auipc	a0,0x4
    8000370c:	f7850513          	addi	a0,a0,-136 # 80007680 <states.1524+0x468>
    80003710:	ffffd097          	auipc	ra,0xffffd
    80003714:	d74080e7          	jalr	-652(ra) # 80000484 <panic>
    80003718:	b755                	j	800036bc <exec+0x6a>
        panic("readi panic");
    8000371a:	00004517          	auipc	a0,0x4
    8000371e:	f8650513          	addi	a0,a0,-122 # 800076a0 <states.1524+0x488>
    80003722:	ffffd097          	auipc	ra,0xffffd
    80003726:	d62080e7          	jalr	-670(ra) # 80000484 <panic>
    8000372a:	bf4d                	j	800036dc <exec+0x8a>
        panic("ELF MAGIC Panic");
    8000372c:	00004517          	auipc	a0,0x4
    80003730:	f8450513          	addi	a0,a0,-124 # 800076b0 <states.1524+0x498>
    80003734:	ffffd097          	auipc	ra,0xffffd
    80003738:	d50080e7          	jalr	-688(ra) # 80000484 <panic>
    8000373c:	bf45                	j	800036ec <exec+0x9a>
            panic("readi from proghdr panic...\n");
    8000373e:	00004517          	auipc	a0,0x4
    80003742:	f8250513          	addi	a0,a0,-126 # 800076c0 <states.1524+0x4a8>
    80003746:	ffffd097          	auipc	ra,0xffffd
    8000374a:	d3e080e7          	jalr	-706(ra) # 80000484 <panic>
    8000374e:	ac69                	j	800039e8 <exec+0x396>
            panic("exec() ph.memsz < ph.filesz...\n");
    80003750:	00004517          	auipc	a0,0x4
    80003754:	f9050513          	addi	a0,a0,-112 # 800076e0 <states.1524+0x4c8>
    80003758:	ffffd097          	auipc	ra,0xffffd
    8000375c:	d2c080e7          	jalr	-724(ra) # 80000484 <panic>
    80003760:	ac79                	j	800039fe <exec+0x3ac>
            panic("exec() ph.vaddr + ph.memsz < ph.vaddr...\n");
    80003762:	00004517          	auipc	a0,0x4
    80003766:	f9e50513          	addi	a0,a0,-98 # 80007700 <states.1524+0x4e8>
    8000376a:	ffffd097          	auipc	ra,0xffffd
    8000376e:	d1a080e7          	jalr	-742(ra) # 80000484 <panic>
    80003772:	ac69                	j	80003a0c <exec+0x3ba>
            panic("loadseg uvmalloc panic");
    80003774:	00004517          	auipc	a0,0x4
    80003778:	fbc50513          	addi	a0,a0,-68 # 80007730 <states.1524+0x518>
    8000377c:	ffffd097          	auipc	ra,0xffffd
    80003780:	d08080e7          	jalr	-760(ra) # 80000484 <panic>
    80003784:	a465                	j	80003a2c <exec+0x3da>
            panic("exec:(ph.vaddr %% PGSIZE) != 0");
    80003786:	00004517          	auipc	a0,0x4
    8000378a:	fc250513          	addi	a0,a0,-62 # 80007748 <states.1524+0x530>
    8000378e:	ffffd097          	auipc	ra,0xffffd
    80003792:	cf6080e7          	jalr	-778(ra) # 80000484 <panic>
    80003796:	a455                	j	80003a3a <exec+0x3e8>
            panic("loadseg: address should exist");
    80003798:	00004517          	auipc	a0,0x4
    8000379c:	fd050513          	addi	a0,a0,-48 # 80007768 <states.1524+0x550>
    800037a0:	ffffd097          	auipc	ra,0xffffd
    800037a4:	ce4080e7          	jalr	-796(ra) # 80000484 <panic>
    800037a8:	a83d                	j	800037e6 <exec+0x194>
    800037aa:	00070d9b          	sext.w	s11,a4
        if(readi(ip,0,(uint64)pa,off+i,n) != n){
    800037ae:	876e                	mv	a4,s11
    800037b0:	409c86bb          	subw	a3,s9,s1
    800037b4:	864a                	mv	a2,s2
    800037b6:	4581                	li	a1,0
    800037b8:	e0843503          	ld	a0,-504(s0)
    800037bc:	fffff097          	auipc	ra,0xfffff
    800037c0:	fbc080e7          	jalr	-68(ra) # 80002778 <readi>
    800037c4:	1ead9263          	bne	s11,a0,800039a8 <exec+0x356>
    for(int i = 0; i < sz;i += PGSIZE){
    800037c8:	77fd                	lui	a5,0xfffff
    800037ca:	94be                	add	s1,s1,a5
    800037cc:	409a07b3          	sub	a5,s4,s1
    800037d0:	1f47f463          	bgeu	a5,s4,800039b8 <exec+0x366>
        uint64 pa = walkaddr(pagetable,va + i);
    800037d4:	409d05b3          	sub	a1,s10,s1
    800037d8:	855a                	mv	a0,s6
    800037da:	00001097          	auipc	ra,0x1
    800037de:	26e080e7          	jalr	622(ra) # 80004a48 <walkaddr>
    800037e2:	892a                	mv	s2,a0
        if(pa == 0){
    800037e4:	d955                	beqz	a0,80003798 <exec+0x146>
        if(sz - i  < PGSIZE){
    800037e6:	8726                	mv	a4,s1
    800037e8:	fd84e1e3          	bltu	s1,s8,800037aa <exec+0x158>
    800037ec:	8762                	mv	a4,s8
    800037ee:	bf75                	j	800037aa <exec+0x158>
    uint64 sz = 0;
    800037f0:	e0043023          	sd	zero,-512(s0)
        }
        if(loadseg(pagetable,ph.vaddr,app,ph,ph.off,ph.filesz) < 0){
            panic("loadseg panic");
        }
    }
    iunlockput(app);
    800037f4:	e0843503          	ld	a0,-504(s0)
    800037f8:	fffff097          	auipc	ra,0xfffff
    800037fc:	5b6080e7          	jalr	1462(ra) # 80002dae <iunlockput>
    uint64 oldsz = p->sz;
    80003800:	de843783          	ld	a5,-536(s0)
    80003804:	6fbc                	ld	a5,88(a5)
    80003806:	e0f43423          	sd	a5,-504(s0)

    sz = PGROUNDUP(sz);
    8000380a:	6585                	lui	a1,0x1
    8000380c:	15fd                	addi	a1,a1,-1
    8000380e:	e0043783          	ld	a5,-512(s0)
    80003812:	95be                	add	a1,a1,a5
    80003814:	77fd                	lui	a5,0xfffff
    80003816:	8dfd                	and	a1,a1,a5
    uint64 sz1;
    if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0){
    80003818:	6609                	lui	a2,0x2
    8000381a:	962e                	add	a2,a2,a1
    8000381c:	855a                	mv	a0,s6
    8000381e:	00001097          	auipc	ra,0x1
    80003822:	5aa080e7          	jalr	1450(ra) # 80004dc8 <uvmalloc>
    80003826:	8c2a                	mv	s8,a0
    80003828:	cd15                	beqz	a0,80003864 <exec+0x212>
        panic("----");
    }
    sz = sz1;
    uvmclear(pagetable, sz-2*PGSIZE);
    8000382a:	75f9                	lui	a1,0xffffe
    8000382c:	95aa                	add	a1,a1,a0
    8000382e:	855a                	mv	a0,s6
    80003830:	00001097          	auipc	ra,0x1
    80003834:	066080e7          	jalr	102(ra) # 80004896 <uvmclear>
    uint64 sp = sz;
    uint64 stackbase = sp - PGSIZE;
    80003838:	7bfd                	lui	s7,0xfffff
    8000383a:	9be2                	add	s7,s7,s8

    uint64 argc = 0;
    uint64 ustack[MAXARG];
    if(argv){
    8000383c:	0c0a8b63          	beqz	s5,80003912 <exec+0x2c0>
        for(argc = 0; argv[argc]; argc++) {
    80003840:	000ab783          	ld	a5,0(s5)
    80003844:	10078f63          	beqz	a5,80003962 <exec+0x310>
    80003848:	e1840a13          	addi	s4,s0,-488
    uint64 sp = sz;
    8000384c:	84e2                	mv	s1,s8
        for(argc = 0; argv[argc]; argc++) {
    8000384e:	4901                	li	s2,0
                panic("argc >= MAXARG");
            }
            sp -= strlen(argv[argc]) + 1;
            sp -= sp % 16; // riscv sp must be 16-byte aligned
            if(sp < stackbase){
                panic("exec:sp < stackbase");
    80003850:	00004d97          	auipc	s11,0x4
    80003854:	f50d8d93          	addi	s11,s11,-176 # 800077a0 <states.1524+0x588>
            if(argc >= MAXARG){
    80003858:	4cfd                	li	s9,31
                panic("argc >= MAXARG");
    8000385a:	00004d17          	auipc	s10,0x4
    8000385e:	f36d0d13          	addi	s10,s10,-202 # 80007790 <states.1524+0x578>
    80003862:	a82d                	j	8000389c <exec+0x24a>
        panic("----");
    80003864:	00004517          	auipc	a0,0x4
    80003868:	f2450513          	addi	a0,a0,-220 # 80007788 <states.1524+0x570>
    8000386c:	ffffd097          	auipc	ra,0xffffd
    80003870:	c18080e7          	jalr	-1000(ra) # 80000484 <panic>
    uvmclear(pagetable, sz-2*PGSIZE);
    80003874:	75f9                	lui	a1,0xffffe
    80003876:	855a                	mv	a0,s6
    80003878:	00001097          	auipc	ra,0x1
    8000387c:	01e080e7          	jalr	30(ra) # 80004896 <uvmclear>
    if(argv){
    80003880:	100a8f63          	beqz	s5,8000399e <exec+0x34c>
        for(argc = 0; argv[argc]; argc++) {
    80003884:	000ab783          	ld	a5,0(s5)
    uint64 stackbase = sp - PGSIZE;
    80003888:	7bfd                	lui	s7,0xfffff
        for(argc = 0; argv[argc]; argc++) {
    8000388a:	ffdd                	bnez	a5,80003848 <exec+0x1f6>
                panic("exec:copyout");
            }
            ustack[argc] = sp;
        }
    }
    ustack[argc] = 0;
    8000388c:	e0043c23          	sd	zero,-488(s0)
    sp -= (argc+1) * sizeof(uint64);
    80003890:	ff8c0493          	addi	s1,s8,-8
    sp -= sp % 16;
    80003894:	98c1                	andi	s1,s1,-16
    sp -= (argc+1) * sizeof(uint64);
    80003896:	4921                	li	s2,8
    80003898:	a869                	j	80003932 <exec+0x2e0>
    8000389a:	0a21                	addi	s4,s4,8
            sp -= strlen(argv[argc]) + 1;
    8000389c:	000ab503          	ld	a0,0(s5)
    800038a0:	ffffe097          	auipc	ra,0xffffe
    800038a4:	76e080e7          	jalr	1902(ra) # 8000200e <strlen>
    800038a8:	2505                	addiw	a0,a0,1
    800038aa:	8c89                	sub	s1,s1,a0
            sp -= sp % 16; // riscv sp must be 16-byte aligned
    800038ac:	98c1                	andi	s1,s1,-16
            if(sp < stackbase){
    800038ae:	0574e363          	bltu	s1,s7,800038f4 <exec+0x2a2>
            if(copyoutpg(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0){
    800038b2:	000ab983          	ld	s3,0(s5)
    800038b6:	854e                	mv	a0,s3
    800038b8:	ffffe097          	auipc	ra,0xffffe
    800038bc:	756080e7          	jalr	1878(ra) # 8000200e <strlen>
    800038c0:	0015069b          	addiw	a3,a0,1
    800038c4:	864e                	mv	a2,s3
    800038c6:	85a6                	mv	a1,s1
    800038c8:	855a                	mv	a0,s6
    800038ca:	00000097          	auipc	ra,0x0
    800038ce:	1f2080e7          	jalr	498(ra) # 80003abc <copyoutpg>
    800038d2:	02054763          	bltz	a0,80003900 <exec+0x2ae>
            ustack[argc] = sp;
    800038d6:	009a3023          	sd	s1,0(s4)
        for(argc = 0; argv[argc]; argc++) {
    800038da:	0905                	addi	s2,s2,1
    800038dc:	0aa1                	addi	s5,s5,8
    800038de:	000ab783          	ld	a5,0(s5)
    800038e2:	cb95                	beqz	a5,80003916 <exec+0x2c4>
            if(argc >= MAXARG){
    800038e4:	fb2cfbe3          	bgeu	s9,s2,8000389a <exec+0x248>
                panic("argc >= MAXARG");
    800038e8:	856a                	mv	a0,s10
    800038ea:	ffffd097          	auipc	ra,0xffffd
    800038ee:	b9a080e7          	jalr	-1126(ra) # 80000484 <panic>
    800038f2:	b765                	j	8000389a <exec+0x248>
                panic("exec:sp < stackbase");
    800038f4:	856e                	mv	a0,s11
    800038f6:	ffffd097          	auipc	ra,0xffffd
    800038fa:	b8e080e7          	jalr	-1138(ra) # 80000484 <panic>
    800038fe:	bf55                	j	800038b2 <exec+0x260>
                panic("exec:copyout");
    80003900:	00004517          	auipc	a0,0x4
    80003904:	eb850513          	addi	a0,a0,-328 # 800077b8 <states.1524+0x5a0>
    80003908:	ffffd097          	auipc	ra,0xffffd
    8000390c:	b7c080e7          	jalr	-1156(ra) # 80000484 <panic>
    80003910:	b7d9                	j	800038d6 <exec+0x284>
    uint64 sp = sz;
    80003912:	84e2                	mv	s1,s8
    uint64 argc = 0;
    80003914:	4901                	li	s2,0
    ustack[argc] = 0;
    80003916:	00391793          	slli	a5,s2,0x3
    8000391a:	f9040713          	addi	a4,s0,-112
    8000391e:	97ba                	add	a5,a5,a4
    80003920:	e807b423          	sd	zero,-376(a5) # ffffffffffffee88 <end+0xffffffff7ffde558>
    sp -= (argc+1) * sizeof(uint64);
    80003924:	0905                	addi	s2,s2,1
    80003926:	090e                	slli	s2,s2,0x3
    80003928:	412484b3          	sub	s1,s1,s2
    sp -= sp % 16;
    8000392c:	98c1                	andi	s1,s1,-16
    if(sp < stackbase){
    8000392e:	0374ed63          	bltu	s1,s7,80003968 <exec+0x316>
        panic("if(sp < stackbase)");
    }
    if(copyoutpg(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0){
    80003932:	86ca                	mv	a3,s2
    80003934:	e1840613          	addi	a2,s0,-488
    80003938:	85a6                	mv	a1,s1
    8000393a:	855a                	mv	a0,s6
    8000393c:	00000097          	auipc	ra,0x0
    80003940:	180080e7          	jalr	384(ra) # 80003abc <copyoutpg>
    80003944:	02054b63          	bltz	a0,8000397a <exec+0x328>
        panic("exec:copyout");     
    }
    p->trapframe->a1 = sp;
    80003948:	de843783          	ld	a5,-536(s0)
    8000394c:	73bc                	ld	a5,96(a5)
    8000394e:	ffa4                	sd	s1,120(a5)

    char *s,*last;
    for(last=s=path; *s; s++){
    80003950:	df843783          	ld	a5,-520(s0)
    80003954:	0007c703          	lbu	a4,0(a5)
    80003958:	cf75                	beqz	a4,80003a54 <exec+0x402>
    8000395a:	0785                	addi	a5,a5,1
        if(*s == '/'){
    8000395c:	02f00693          	li	a3,47
    80003960:	a815                	j	80003994 <exec+0x342>
    uint64 sp = sz;
    80003962:	84e2                	mv	s1,s8
        for(argc = 0; argv[argc]; argc++) {
    80003964:	4901                	li	s2,0
    80003966:	bf45                	j	80003916 <exec+0x2c4>
        panic("if(sp < stackbase)");
    80003968:	00004517          	auipc	a0,0x4
    8000396c:	e6050513          	addi	a0,a0,-416 # 800077c8 <states.1524+0x5b0>
    80003970:	ffffd097          	auipc	ra,0xffffd
    80003974:	b14080e7          	jalr	-1260(ra) # 80000484 <panic>
    80003978:	bf6d                	j	80003932 <exec+0x2e0>
        panic("exec:copyout");     
    8000397a:	00004517          	auipc	a0,0x4
    8000397e:	e3e50513          	addi	a0,a0,-450 # 800077b8 <states.1524+0x5a0>
    80003982:	ffffd097          	auipc	ra,0xffffd
    80003986:	b02080e7          	jalr	-1278(ra) # 80000484 <panic>
    8000398a:	bf7d                	j	80003948 <exec+0x2f6>
    for(last=s=path; *s; s++){
    8000398c:	0785                	addi	a5,a5,1
    8000398e:	fff7c703          	lbu	a4,-1(a5)
    80003992:	c369                	beqz	a4,80003a54 <exec+0x402>
        if(*s == '/'){
    80003994:	fed71ce3          	bne	a4,a3,8000398c <exec+0x33a>
            last = s+1;
    80003998:	def43c23          	sd	a5,-520(s0)
    8000399c:	bfc5                	j	8000398c <exec+0x33a>
    ustack[argc] = 0;
    8000399e:	e0043c23          	sd	zero,-488(s0)
    sp -= sp % 16;
    800039a2:	54c1                	li	s1,-16
    sp -= (argc+1) * sizeof(uint64);
    800039a4:	4921                	li	s2,8
    800039a6:	b771                	j	80003932 <exec+0x2e0>
            panic("loadseg panic");
    800039a8:	00004517          	auipc	a0,0x4
    800039ac:	e3850513          	addi	a0,a0,-456 # 800077e0 <states.1524+0x5c8>
    800039b0:	ffffd097          	auipc	ra,0xffffd
    800039b4:	ad4080e7          	jalr	-1324(ra) # 80000484 <panic>
    for(i=0,off=elf.phoff; i< elf.phnum;i++,off+=sizeof(ph)){
    800039b8:	2b85                	addiw	s7,s7,1
    800039ba:	0389899b          	addiw	s3,s3,56
    800039be:	f8845783          	lhu	a5,-120(s0)
    800039c2:	e2fbd9e3          	bge	s7,a5,800037f4 <exec+0x1a2>
        if(readi(app,0,(uint64)&ph,off,sizeof(ph)) != sizeof(ph)){
    800039c6:	2981                	sext.w	s3,s3
    800039c8:	03800713          	li	a4,56
    800039cc:	86ce                	mv	a3,s3
    800039ce:	f1840613          	addi	a2,s0,-232
    800039d2:	4581                	li	a1,0
    800039d4:	e0843503          	ld	a0,-504(s0)
    800039d8:	fffff097          	auipc	ra,0xfffff
    800039dc:	da0080e7          	jalr	-608(ra) # 80002778 <readi>
    800039e0:	03800793          	li	a5,56
    800039e4:	d4f51de3          	bne	a0,a5,8000373e <exec+0xec>
        if(ph.type!= ELF_PROG_LOAD){
    800039e8:	f1842783          	lw	a5,-232(s0)
    800039ec:	4705                	li	a4,1
    800039ee:	fce795e3          	bne	a5,a4,800039b8 <exec+0x366>
        if(ph.memsz < ph.filesz){
    800039f2:	f4043703          	ld	a4,-192(s0)
    800039f6:	f3843783          	ld	a5,-200(s0)
    800039fa:	d4f76be3          	bltu	a4,a5,80003750 <exec+0xfe>
        if(ph.vaddr + ph.memsz < ph.vaddr){
    800039fe:	f2843703          	ld	a4,-216(s0)
    80003a02:	f4043783          	ld	a5,-192(s0)
    80003a06:	97ba                	add	a5,a5,a4
    80003a08:	d4e7ede3          	bltu	a5,a4,80003762 <exec+0x110>
        if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0){
    80003a0c:	f2843603          	ld	a2,-216(s0)
    80003a10:	f4043783          	ld	a5,-192(s0)
    80003a14:	963e                	add	a2,a2,a5
    80003a16:	e0043583          	ld	a1,-512(s0)
    80003a1a:	855a                	mv	a0,s6
    80003a1c:	00001097          	auipc	ra,0x1
    80003a20:	3ac080e7          	jalr	940(ra) # 80004dc8 <uvmalloc>
    80003a24:	e0a43023          	sd	a0,-512(s0)
    80003a28:	d40506e3          	beqz	a0,80003774 <exec+0x122>
        if((ph.vaddr % PGSIZE) != 0){
    80003a2c:	f2843783          	ld	a5,-216(s0)
    80003a30:	df043703          	ld	a4,-528(s0)
    80003a34:	8ff9                	and	a5,a5,a4
    80003a36:	d40798e3          	bnez	a5,80003786 <exec+0x134>
        if(loadseg(pagetable,ph.vaddr,app,ph,ph.off,ph.filesz) < 0){
    80003a3a:	f2843d03          	ld	s10,-216(s0)
    80003a3e:	f2043c83          	ld	s9,-224(s0)
    80003a42:	f3843a03          	ld	s4,-200(s0)
    for(int i = 0; i < sz;i += PGSIZE){
    80003a46:	f60a09e3          	beqz	s4,800039b8 <exec+0x366>
    80003a4a:	84d2                	mv	s1,s4
        uint64 pa = walkaddr(pagetable,va + i);
    80003a4c:	9d52                	add	s10,s10,s4
        if(readi(ip,0,(uint64)pa,off+i,n) != n){
    80003a4e:	014c8cbb          	addw	s9,s9,s4
    80003a52:	b349                	j	800037d4 <exec+0x182>
        }
    }
    safestrcpy(p->name, last, sizeof(p->name));
    80003a54:	4641                	li	a2,16
    80003a56:	df843583          	ld	a1,-520(s0)
    80003a5a:	de843903          	ld	s2,-536(s0)
    80003a5e:	02090513          	addi	a0,s2,32
    80003a62:	00000097          	auipc	ra,0x0
    80003a66:	192080e7          	jalr	402(ra) # 80003bf4 <safestrcpy>

    pagetable_t oldpagetable = p->pagetable;
    80003a6a:	06893503          	ld	a0,104(s2)
    p->pagetable = pagetable;
    80003a6e:	07693423          	sd	s6,104(s2)
    p->sz = sz;
    80003a72:	05893c23          	sd	s8,88(s2)
    p->trapframe->epc = elf.entry;
    80003a76:	06093783          	ld	a5,96(s2)
    80003a7a:	f6843703          	ld	a4,-152(s0)
    80003a7e:	ef98                	sd	a4,24(a5)
    p->trapframe->sp = sp;
    80003a80:	06093783          	ld	a5,96(s2)
    80003a84:	fb84                	sd	s1,48(a5)
    proc_freepagetable(oldpagetable, oldsz);
    80003a86:	e0843583          	ld	a1,-504(s0)
    80003a8a:	00001097          	auipc	ra,0x1
    80003a8e:	2a4080e7          	jalr	676(ra) # 80004d2e <proc_freepagetable>
    return 0;
    80003a92:	4501                	li	a0,0
    80003a94:	21813083          	ld	ra,536(sp)
    80003a98:	21013403          	ld	s0,528(sp)
    80003a9c:	20813483          	ld	s1,520(sp)
    80003aa0:	20013903          	ld	s2,512(sp)
    80003aa4:	79fe                	ld	s3,504(sp)
    80003aa6:	7a5e                	ld	s4,496(sp)
    80003aa8:	7abe                	ld	s5,488(sp)
    80003aaa:	7b1e                	ld	s6,480(sp)
    80003aac:	6bfe                	ld	s7,472(sp)
    80003aae:	6c5e                	ld	s8,464(sp)
    80003ab0:	6cbe                	ld	s9,456(sp)
    80003ab2:	6d1e                	ld	s10,448(sp)
    80003ab4:	7dfa                	ld	s11,440(sp)
    80003ab6:	22010113          	addi	sp,sp,544
    80003aba:	8082                	ret

0000000080003abc <copyoutpg>:
#include "proc.h"

int copyoutpg(pagetable_t pagetable, uint64 dstva, char *src, uint64 len) {
  uint64 n, va0, pa0;

  while(len > 0){
    80003abc:	c6bd                	beqz	a3,80003b2a <copyoutpg+0x6e>
int copyoutpg(pagetable_t pagetable, uint64 dstva, char *src, uint64 len) {
    80003abe:	715d                	addi	sp,sp,-80
    80003ac0:	e486                	sd	ra,72(sp)
    80003ac2:	e0a2                	sd	s0,64(sp)
    80003ac4:	fc26                	sd	s1,56(sp)
    80003ac6:	f84a                	sd	s2,48(sp)
    80003ac8:	f44e                	sd	s3,40(sp)
    80003aca:	f052                	sd	s4,32(sp)
    80003acc:	ec56                	sd	s5,24(sp)
    80003ace:	e85a                	sd	s6,16(sp)
    80003ad0:	e45e                	sd	s7,8(sp)
    80003ad2:	e062                	sd	s8,0(sp)
    80003ad4:	0880                	addi	s0,sp,80
    80003ad6:	8b2a                	mv	s6,a0
    80003ad8:	8c2e                	mv	s8,a1
    80003ada:	8a32                	mv	s4,a2
    80003adc:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80003ade:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80003ae0:	6a85                	lui	s5,0x1
    80003ae2:	a015                	j	80003b06 <copyoutpg+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80003ae4:	9562                	add	a0,a0,s8
    80003ae6:	0004861b          	sext.w	a2,s1
    80003aea:	85d2                	mv	a1,s4
    80003aec:	41250533          	sub	a0,a0,s2
    80003af0:	ffffe097          	auipc	ra,0xffffe
    80003af4:	482080e7          	jalr	1154(ra) # 80001f72 <memmove>

    len -= n;
    80003af8:	409989b3          	sub	s3,s3,s1
    src += n;
    80003afc:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80003afe:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80003b02:	02098263          	beqz	s3,80003b26 <copyoutpg+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80003b06:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80003b0a:	85ca                	mv	a1,s2
    80003b0c:	855a                	mv	a0,s6
    80003b0e:	00001097          	auipc	ra,0x1
    80003b12:	f3a080e7          	jalr	-198(ra) # 80004a48 <walkaddr>
    if(pa0 == 0)
    80003b16:	cd01                	beqz	a0,80003b2e <copyoutpg+0x72>
    n = PGSIZE - (dstva - va0);
    80003b18:	418904b3          	sub	s1,s2,s8
    80003b1c:	94d6                	add	s1,s1,s5
    if(n > len)
    80003b1e:	fc99f3e3          	bgeu	s3,s1,80003ae4 <copyoutpg+0x28>
    80003b22:	84ce                	mv	s1,s3
    80003b24:	b7c1                	j	80003ae4 <copyoutpg+0x28>
  }
  return 0;
    80003b26:	4501                	li	a0,0
    80003b28:	a021                	j	80003b30 <copyoutpg+0x74>
    80003b2a:	4501                	li	a0,0
}
    80003b2c:	8082                	ret
      return -1;
    80003b2e:	557d                	li	a0,-1
}
    80003b30:	60a6                	ld	ra,72(sp)
    80003b32:	6406                	ld	s0,64(sp)
    80003b34:	74e2                	ld	s1,56(sp)
    80003b36:	7942                	ld	s2,48(sp)
    80003b38:	79a2                	ld	s3,40(sp)
    80003b3a:	7a02                	ld	s4,32(sp)
    80003b3c:	6ae2                	ld	s5,24(sp)
    80003b3e:	6b42                	ld	s6,16(sp)
    80003b40:	6ba2                	ld	s7,8(sp)
    80003b42:	6c02                	ld	s8,0(sp)
    80003b44:	6161                	addi	sp,sp,80
    80003b46:	8082                	ret

0000000080003b48 <either_copyout>:

int either_copyout(int user_dst,uint64 dst,void *src,uint64 len){
    80003b48:	7179                	addi	sp,sp,-48
    80003b4a:	f406                	sd	ra,40(sp)
    80003b4c:	f022                	sd	s0,32(sp)
    80003b4e:	ec26                	sd	s1,24(sp)
    80003b50:	e84a                	sd	s2,16(sp)
    80003b52:	e44e                	sd	s3,8(sp)
    80003b54:	e052                	sd	s4,0(sp)
    80003b56:	1800                	addi	s0,sp,48
    80003b58:	84aa                	mv	s1,a0
    80003b5a:	892e                	mv	s2,a1
    80003b5c:	89b2                	mv	s3,a2
    80003b5e:	8a36                	mv	s4,a3
    struct proc *p = myproc();
    80003b60:	ffffd097          	auipc	ra,0xffffd
    80003b64:	a42080e7          	jalr	-1470(ra) # 800005a2 <myproc>
    if(user_dst){
    80003b68:	c08d                	beqz	s1,80003b8a <either_copyout+0x42>
        // kernel -> user
        return copyoutpg(p->pagetable, dst, src, len);
    80003b6a:	86d2                	mv	a3,s4
    80003b6c:	864e                	mv	a2,s3
    80003b6e:	85ca                	mv	a1,s2
    80003b70:	7528                	ld	a0,104(a0)
    80003b72:	00000097          	auipc	ra,0x0
    80003b76:	f4a080e7          	jalr	-182(ra) # 80003abc <copyoutpg>
    }else{
        memmove((char*)dst,src,len);
        return 0;
    }
    return -1;
}
    80003b7a:	70a2                	ld	ra,40(sp)
    80003b7c:	7402                	ld	s0,32(sp)
    80003b7e:	64e2                	ld	s1,24(sp)
    80003b80:	6942                	ld	s2,16(sp)
    80003b82:	69a2                	ld	s3,8(sp)
    80003b84:	6a02                	ld	s4,0(sp)
    80003b86:	6145                	addi	sp,sp,48
    80003b88:	8082                	ret
        memmove((char*)dst,src,len);
    80003b8a:	000a061b          	sext.w	a2,s4
    80003b8e:	85ce                	mv	a1,s3
    80003b90:	854a                	mv	a0,s2
    80003b92:	ffffe097          	auipc	ra,0xffffe
    80003b96:	3e0080e7          	jalr	992(ra) # 80001f72 <memmove>
        return 0;
    80003b9a:	8526                	mv	a0,s1
    80003b9c:	bff9                	j	80003b7a <either_copyout+0x32>

0000000080003b9e <either_copyin>:

int either_copyin(void *dst,int user_src,uint64 src,uint64 len) {
    80003b9e:	7179                	addi	sp,sp,-48
    80003ba0:	f406                	sd	ra,40(sp)
    80003ba2:	f022                	sd	s0,32(sp)
    80003ba4:	ec26                	sd	s1,24(sp)
    80003ba6:	e84a                	sd	s2,16(sp)
    80003ba8:	e44e                	sd	s3,8(sp)
    80003baa:	e052                	sd	s4,0(sp)
    80003bac:	1800                	addi	s0,sp,48
    80003bae:	892a                	mv	s2,a0
    80003bb0:	84ae                	mv	s1,a1
    80003bb2:	89b2                	mv	s3,a2
    80003bb4:	8a36                	mv	s4,a3
    struct proc *p  = myproc();
    80003bb6:	ffffd097          	auipc	ra,0xffffd
    80003bba:	9ec080e7          	jalr	-1556(ra) # 800005a2 <myproc>
    if(user_src){
    80003bbe:	c08d                	beqz	s1,80003be0 <either_copyin+0x42>
        // user -> kernel
        return copyin(p->pagetable, dst, src, len);
    80003bc0:	86d2                	mv	a3,s4
    80003bc2:	864e                	mv	a2,s3
    80003bc4:	85ca                	mv	a1,s2
    80003bc6:	7528                	ld	a0,104(a0)
    80003bc8:	00001097          	auipc	ra,0x1
    80003bcc:	360080e7          	jalr	864(ra) # 80004f28 <copyin>
    }else{
        memmove(dst,(char*)src,len);
        return 0;
    }
    return -1;
}
    80003bd0:	70a2                	ld	ra,40(sp)
    80003bd2:	7402                	ld	s0,32(sp)
    80003bd4:	64e2                	ld	s1,24(sp)
    80003bd6:	6942                	ld	s2,16(sp)
    80003bd8:	69a2                	ld	s3,8(sp)
    80003bda:	6a02                	ld	s4,0(sp)
    80003bdc:	6145                	addi	sp,sp,48
    80003bde:	8082                	ret
        memmove(dst,(char*)src,len);
    80003be0:	000a061b          	sext.w	a2,s4
    80003be4:	85ce                	mv	a1,s3
    80003be6:	854a                	mv	a0,s2
    80003be8:	ffffe097          	auipc	ra,0xffffe
    80003bec:	38a080e7          	jalr	906(ra) # 80001f72 <memmove>
        return 0;
    80003bf0:	8526                	mv	a0,s1
    80003bf2:	bff9                	j	80003bd0 <either_copyin+0x32>

0000000080003bf4 <safestrcpy>:

char* safestrcpy(char *s, const char *t, int n) {
    80003bf4:	1141                	addi	sp,sp,-16
    80003bf6:	e422                	sd	s0,8(sp)
    80003bf8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80003bfa:	02c05363          	blez	a2,80003c20 <safestrcpy+0x2c>
    80003bfe:	fff6069b          	addiw	a3,a2,-1
    80003c02:	1682                	slli	a3,a3,0x20
    80003c04:	9281                	srli	a3,a3,0x20
    80003c06:	96ae                	add	a3,a3,a1
    80003c08:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80003c0a:	00d58963          	beq	a1,a3,80003c1c <safestrcpy+0x28>
    80003c0e:	0585                	addi	a1,a1,1
    80003c10:	0785                	addi	a5,a5,1
    80003c12:	fff5c703          	lbu	a4,-1(a1) # ffffffffffffdfff <end+0xffffffff7ffdd6cf>
    80003c16:	fee78fa3          	sb	a4,-1(a5)
    80003c1a:	fb65                	bnez	a4,80003c0a <safestrcpy+0x16>
    ;
  *s = 0;
    80003c1c:	00078023          	sb	zero,0(a5)
  return os;
    80003c20:	6422                	ld	s0,8(sp)
    80003c22:	0141                	addi	sp,sp,16
    80003c24:	8082                	ret

0000000080003c26 <argraw>:
#include "syscall.h"
#include "spinlock.h"
#include "file.h"
#include "proc.h"

static uint64 argraw(int n) {
    80003c26:	1101                	addi	sp,sp,-32
    80003c28:	ec06                	sd	ra,24(sp)
    80003c2a:	e822                	sd	s0,16(sp)
    80003c2c:	e426                	sd	s1,8(sp)
    80003c2e:	1000                	addi	s0,sp,32
    80003c30:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80003c32:	ffffd097          	auipc	ra,0xffffd
    80003c36:	970080e7          	jalr	-1680(ra) # 800005a2 <myproc>
  switch (n) {
    80003c3a:	4795                	li	a5,5
    80003c3c:	0497e163          	bltu	a5,s1,80003c7e <argraw+0x58>
    80003c40:	048a                	slli	s1,s1,0x2
    80003c42:	00004717          	auipc	a4,0x4
    80003c46:	be670713          	addi	a4,a4,-1050 # 80007828 <states.1524+0x610>
    80003c4a:	94ba                	add	s1,s1,a4
    80003c4c:	409c                	lw	a5,0(s1)
    80003c4e:	97ba                	add	a5,a5,a4
    80003c50:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80003c52:	713c                	ld	a5,96(a0)
    80003c54:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80003c56:	60e2                	ld	ra,24(sp)
    80003c58:	6442                	ld	s0,16(sp)
    80003c5a:	64a2                	ld	s1,8(sp)
    80003c5c:	6105                	addi	sp,sp,32
    80003c5e:	8082                	ret
    return p->trapframe->a1;
    80003c60:	713c                	ld	a5,96(a0)
    80003c62:	7fa8                	ld	a0,120(a5)
    80003c64:	bfcd                	j	80003c56 <argraw+0x30>
    return p->trapframe->a2;
    80003c66:	713c                	ld	a5,96(a0)
    80003c68:	63c8                	ld	a0,128(a5)
    80003c6a:	b7f5                	j	80003c56 <argraw+0x30>
    return p->trapframe->a3;
    80003c6c:	713c                	ld	a5,96(a0)
    80003c6e:	67c8                	ld	a0,136(a5)
    80003c70:	b7dd                	j	80003c56 <argraw+0x30>
    return p->trapframe->a4;
    80003c72:	713c                	ld	a5,96(a0)
    80003c74:	6bc8                	ld	a0,144(a5)
    80003c76:	b7c5                	j	80003c56 <argraw+0x30>
    return p->trapframe->a5;
    80003c78:	713c                	ld	a5,96(a0)
    80003c7a:	6fc8                	ld	a0,152(a5)
    80003c7c:	bfe9                	j	80003c56 <argraw+0x30>
  panic("argraw");
    80003c7e:	00004517          	auipc	a0,0x4
    80003c82:	b7250513          	addi	a0,a0,-1166 # 800077f0 <states.1524+0x5d8>
    80003c86:	ffffc097          	auipc	ra,0xffffc
    80003c8a:	7fe080e7          	jalr	2046(ra) # 80000484 <panic>
  return -1;
    80003c8e:	557d                	li	a0,-1
    80003c90:	b7d9                	j	80003c56 <argraw+0x30>

0000000080003c92 <fetchstr>:

int fetchstr(uint64 addr, char *buf, int max) {
    80003c92:	7179                	addi	sp,sp,-48
    80003c94:	f406                	sd	ra,40(sp)
    80003c96:	f022                	sd	s0,32(sp)
    80003c98:	ec26                	sd	s1,24(sp)
    80003c9a:	e84a                	sd	s2,16(sp)
    80003c9c:	e44e                	sd	s3,8(sp)
    80003c9e:	1800                	addi	s0,sp,48
    80003ca0:	84aa                	mv	s1,a0
    80003ca2:	892e                	mv	s2,a1
    80003ca4:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80003ca6:	ffffd097          	auipc	ra,0xffffd
    80003caa:	8fc080e7          	jalr	-1796(ra) # 800005a2 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80003cae:	86ce                	mv	a3,s3
    80003cb0:	8626                	mv	a2,s1
    80003cb2:	85ca                	mv	a1,s2
    80003cb4:	7528                	ld	a0,104(a0)
    80003cb6:	00001097          	auipc	ra,0x1
    80003cba:	310080e7          	jalr	784(ra) # 80004fc6 <copyinstr>
  if(err < 0){
    80003cbe:	02054063          	bltz	a0,80003cde <fetchstr+0x4c>
    panic("fetchstr err < 0");
    return err;
  }
  return strlen(buf);
    80003cc2:	854a                	mv	a0,s2
    80003cc4:	ffffe097          	auipc	ra,0xffffe
    80003cc8:	34a080e7          	jalr	842(ra) # 8000200e <strlen>
    80003ccc:	84aa                	mv	s1,a0
}
    80003cce:	8526                	mv	a0,s1
    80003cd0:	70a2                	ld	ra,40(sp)
    80003cd2:	7402                	ld	s0,32(sp)
    80003cd4:	64e2                	ld	s1,24(sp)
    80003cd6:	6942                	ld	s2,16(sp)
    80003cd8:	69a2                	ld	s3,8(sp)
    80003cda:	6145                	addi	sp,sp,48
    80003cdc:	8082                	ret
    80003cde:	84aa                	mv	s1,a0
    panic("fetchstr err < 0");
    80003ce0:	00004517          	auipc	a0,0x4
    80003ce4:	b1850513          	addi	a0,a0,-1256 # 800077f8 <states.1524+0x5e0>
    80003ce8:	ffffc097          	auipc	ra,0xffffc
    80003cec:	79c080e7          	jalr	1948(ra) # 80000484 <panic>
    return err;
    80003cf0:	bff9                	j	80003cce <fetchstr+0x3c>

0000000080003cf2 <argstr>:

int argstr(int num,char *buf,int size){
    80003cf2:	1101                	addi	sp,sp,-32
    80003cf4:	ec06                	sd	ra,24(sp)
    80003cf6:	e822                	sd	s0,16(sp)
    80003cf8:	e426                	sd	s1,8(sp)
    80003cfa:	e04a                	sd	s2,0(sp)
    80003cfc:	1000                	addi	s0,sp,32
    80003cfe:	84ae                	mv	s1,a1
    80003d00:	8932                	mv	s2,a2
}

int
argaddr(int n, uint64 *ip)
{
  *ip = argraw(n);
    80003d02:	00000097          	auipc	ra,0x0
    80003d06:	f24080e7          	jalr	-220(ra) # 80003c26 <argraw>
    return fetchstr(addr,buf,size);
    80003d0a:	864a                	mv	a2,s2
    80003d0c:	85a6                	mv	a1,s1
    80003d0e:	00000097          	auipc	ra,0x0
    80003d12:	f84080e7          	jalr	-124(ra) # 80003c92 <fetchstr>
}
    80003d16:	60e2                	ld	ra,24(sp)
    80003d18:	6442                	ld	s0,16(sp)
    80003d1a:	64a2                	ld	s1,8(sp)
    80003d1c:	6902                	ld	s2,0(sp)
    80003d1e:	6105                	addi	sp,sp,32
    80003d20:	8082                	ret

0000000080003d22 <argint>:
int argint(int n,int *ip){
    80003d22:	1101                	addi	sp,sp,-32
    80003d24:	ec06                	sd	ra,24(sp)
    80003d26:	e822                	sd	s0,16(sp)
    80003d28:	e426                	sd	s1,8(sp)
    80003d2a:	1000                	addi	s0,sp,32
    80003d2c:	84ae                	mv	s1,a1
    *ip = argraw(n);
    80003d2e:	00000097          	auipc	ra,0x0
    80003d32:	ef8080e7          	jalr	-264(ra) # 80003c26 <argraw>
    80003d36:	c088                	sw	a0,0(s1)
}
    80003d38:	4501                	li	a0,0
    80003d3a:	60e2                	ld	ra,24(sp)
    80003d3c:	6442                	ld	s0,16(sp)
    80003d3e:	64a2                	ld	s1,8(sp)
    80003d40:	6105                	addi	sp,sp,32
    80003d42:	8082                	ret

0000000080003d44 <argaddr>:
{
    80003d44:	1101                	addi	sp,sp,-32
    80003d46:	ec06                	sd	ra,24(sp)
    80003d48:	e822                	sd	s0,16(sp)
    80003d4a:	e426                	sd	s1,8(sp)
    80003d4c:	1000                	addi	s0,sp,32
    80003d4e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003d50:	00000097          	auipc	ra,0x0
    80003d54:	ed6080e7          	jalr	-298(ra) # 80003c26 <argraw>
    80003d58:	e088                	sd	a0,0(s1)
  return 0;
}
    80003d5a:	4501                	li	a0,0
    80003d5c:	60e2                	ld	ra,24(sp)
    80003d5e:	6442                	ld	s0,16(sp)
    80003d60:	64a2                	ld	s1,8(sp)
    80003d62:	6105                	addi	sp,sp,32
    80003d64:	8082                	ret

0000000080003d66 <syscall>:
    [SYS_SBRK]      sys_sbrk,
    [SYS_FSTAT]     sys_fstat,
    [SYS_CLOSE]     sys_close,
};

void syscall(){
    80003d66:	1101                	addi	sp,sp,-32
    80003d68:	ec06                	sd	ra,24(sp)
    80003d6a:	e822                	sd	s0,16(sp)
    80003d6c:	e426                	sd	s1,8(sp)
    80003d6e:	e04a                	sd	s2,0(sp)
    80003d70:	1000                	addi	s0,sp,32
    int num;
    struct proc *proc = myproc();
    80003d72:	ffffd097          	auipc	ra,0xffffd
    80003d76:	830080e7          	jalr	-2000(ra) # 800005a2 <myproc>
    80003d7a:	84aa                	mv	s1,a0
    num = proc->trapframe->a7;
    80003d7c:	06053903          	ld	s2,96(a0)
    80003d80:	0a893783          	ld	a5,168(s2)
    80003d84:	0007859b          	sext.w	a1,a5
    if(num > 0 && num < NELEM(syscalls) && syscalls[num]){
    80003d88:	37fd                	addiw	a5,a5,-1
    80003d8a:	4731                	li	a4,12
    80003d8c:	00f76f63          	bltu	a4,a5,80003daa <syscall+0x44>
    80003d90:	00359713          	slli	a4,a1,0x3
    80003d94:	00004797          	auipc	a5,0x4
    80003d98:	aac78793          	addi	a5,a5,-1364 # 80007840 <syscalls>
    80003d9c:	97ba                	add	a5,a5,a4
    80003d9e:	639c                	ld	a5,0(a5)
    80003da0:	c789                	beqz	a5,80003daa <syscall+0x44>
        proc->trapframe->a0 = syscalls[num]();
    80003da2:	9782                	jalr	a5
    80003da4:	06a93823          	sd	a0,112(s2)
    80003da8:	a821                	j	80003dc0 <syscall+0x5a>
    }else{
        printf("syscall %d not exist \n",num);
    80003daa:	00004517          	auipc	a0,0x4
    80003dae:	a6650513          	addi	a0,a0,-1434 # 80007810 <states.1524+0x5f8>
    80003db2:	ffffc097          	auipc	ra,0xffffc
    80003db6:	508080e7          	jalr	1288(ra) # 800002ba <printf>
        proc->trapframe->a0 = -1;
    80003dba:	70bc                	ld	a5,96(s1)
    80003dbc:	577d                	li	a4,-1
    80003dbe:	fbb8                	sd	a4,112(a5)
    }
}
    80003dc0:	60e2                	ld	ra,24(sp)
    80003dc2:	6442                	ld	s0,16(sp)
    80003dc4:	64a2                	ld	s1,8(sp)
    80003dc6:	6902                	ld	s2,0(sp)
    80003dc8:	6105                	addi	sp,sp,32
    80003dca:	8082                	ret

0000000080003dcc <argfd>:
        return -1;
    }
    return 0;
}

static int argfd(int n,int *pfd,struct file **fe){
    80003dcc:	7139                	addi	sp,sp,-64
    80003dce:	fc06                	sd	ra,56(sp)
    80003dd0:	f822                	sd	s0,48(sp)
    80003dd2:	f426                	sd	s1,40(sp)
    80003dd4:	f04a                	sd	s2,32(sp)
    80003dd6:	ec4e                	sd	s3,24(sp)
    80003dd8:	0080                	addi	s0,sp,64
    80003dda:	89ae                	mv	s3,a1
    80003ddc:	8932                	mv	s2,a2
    int fd;
    struct file *f;
    if(argint(n,&fd) != 0){
    80003dde:	fcc40593          	addi	a1,s0,-52
    80003de2:	00000097          	auipc	ra,0x0
    80003de6:	f40080e7          	jalr	-192(ra) # 80003d22 <argint>
    80003dea:	e139                	bnez	a0,80003e30 <argfd+0x64>
    80003dec:	84aa                	mv	s1,a0
        return -1;
    }
    if(fd < 0 || fd >= OPENFILE || (f = myproc()->openfs[fd]) == 0){
    80003dee:	fcc42703          	lw	a4,-52(s0)
    80003df2:	47bd                	li	a5,15
    80003df4:	04e7e063          	bltu	a5,a4,80003e34 <argfd+0x68>
    80003df8:	ffffc097          	auipc	ra,0xffffc
    80003dfc:	7aa080e7          	jalr	1962(ra) # 800005a2 <myproc>
    80003e00:	fcc42703          	lw	a4,-52(s0)
    80003e04:	01c70793          	addi	a5,a4,28
    80003e08:	078e                	slli	a5,a5,0x3
    80003e0a:	953e                	add	a0,a0,a5
    80003e0c:	611c                	ld	a5,0(a0)
    80003e0e:	c78d                	beqz	a5,80003e38 <argfd+0x6c>
        return -1;
    }
    if(pfd){
    80003e10:	00098463          	beqz	s3,80003e18 <argfd+0x4c>
        *pfd = fd;
    80003e14:	00e9a023          	sw	a4,0(s3)
    }
    if(fe){
    80003e18:	00090463          	beqz	s2,80003e20 <argfd+0x54>
        *fe = f;
    80003e1c:	00f93023          	sd	a5,0(s2)
    }
    return 0;
}
    80003e20:	8526                	mv	a0,s1
    80003e22:	70e2                	ld	ra,56(sp)
    80003e24:	7442                	ld	s0,48(sp)
    80003e26:	74a2                	ld	s1,40(sp)
    80003e28:	7902                	ld	s2,32(sp)
    80003e2a:	69e2                	ld	s3,24(sp)
    80003e2c:	6121                	addi	sp,sp,64
    80003e2e:	8082                	ret
        return -1;
    80003e30:	54fd                	li	s1,-1
    80003e32:	b7fd                	j	80003e20 <argfd+0x54>
        return -1;
    80003e34:	54fd                	li	s1,-1
    80003e36:	b7ed                	j	80003e20 <argfd+0x54>
    80003e38:	54fd                	li	s1,-1
    80003e3a:	b7dd                	j	80003e20 <argfd+0x54>

0000000080003e3c <create>:
    }
    filedup(f);
    return fd;
}

static struct inode* create(char *path,short type,short major,short minor){
    80003e3c:	7139                	addi	sp,sp,-64
    80003e3e:	fc06                	sd	ra,56(sp)
    80003e40:	f822                	sd	s0,48(sp)
    80003e42:	f426                	sd	s1,40(sp)
    80003e44:	f04a                	sd	s2,32(sp)
    80003e46:	ec4e                	sd	s3,24(sp)
    80003e48:	e852                	sd	s4,16(sp)
    80003e4a:	e456                	sd	s5,8(sp)
    80003e4c:	e05a                	sd	s6,0(sp)
    80003e4e:	0080                	addi	s0,sp,64
    80003e50:	892a                	mv	s2,a0
    80003e52:	8a2e                	mv	s4,a1
    80003e54:	8ab2                	mv	s5,a2
    80003e56:	8b36                	mv	s6,a3
    struct inode *ip,*dp;
    dp = rooti();
    80003e58:	ffffe097          	auipc	ra,0xffffe
    80003e5c:	638080e7          	jalr	1592(ra) # 80002490 <rooti>
    80003e60:	89aa                	mv	s3,a0
    ilock(dp);
    80003e62:	fffff097          	auipc	ra,0xfffff
    80003e66:	b68080e7          	jalr	-1176(ra) # 800029ca <ilock>
    if(*path == '/'){
    80003e6a:	00094783          	lbu	a5,0(s2)
        path++;
    80003e6e:	fd178793          	addi	a5,a5,-47
    80003e72:	0017b793          	seqz	a5,a5
    80003e76:	993e                	add	s2,s2,a5
    }
    if((ip = inodeByName(dp,path)) != 0){
    80003e78:	85ca                	mv	a1,s2
    80003e7a:	854e                	mv	a0,s3
    80003e7c:	fffff097          	auipc	ra,0xfffff
    80003e80:	a00080e7          	jalr	-1536(ra) # 8000287c <inodeByName>
    80003e84:	c519                	beqz	a0,80003e92 <create+0x56>
    80003e86:	84aa                	mv	s1,a0
        if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE)){
    80003e88:	000a079b          	sext.w	a5,s4
    80003e8c:	4709                	li	a4,2
    80003e8e:	06e78963          	beq	a5,a4,80003f00 <create+0xc4>
            return ip;
        }
    }
    if((ip = ialloc(dp->dev,type)) == 0){
    80003e92:	85d2                	mv	a1,s4
    80003e94:	0009a503          	lw	a0,0(s3)
    80003e98:	fffff097          	auipc	ra,0xfffff
    80003e9c:	c74080e7          	jalr	-908(ra) # 80002b0c <ialloc>
    80003ea0:	84aa                	mv	s1,a0
    80003ea2:	c155                	beqz	a0,80003f46 <create+0x10a>
        panic("fs.c create >> ialloc panic..\n");
    }
    ilock(ip);
    80003ea4:	8526                	mv	a0,s1
    80003ea6:	fffff097          	auipc	ra,0xfffff
    80003eaa:	b24080e7          	jalr	-1244(ra) # 800029ca <ilock>
    ip->major = major;
    80003eae:	05549323          	sh	s5,70(s1)
    ip->minor = minor;
    80003eb2:	05649423          	sh	s6,72(s1)
    ip->nlink = 1;
    80003eb6:	4a85                	li	s5,1
    80003eb8:	05549523          	sh	s5,74(s1)
    iupdate(ip);
    80003ebc:	8526                	mv	a0,s1
    80003ebe:	fffff097          	auipc	ra,0xfffff
    80003ec2:	d10080e7          	jalr	-752(ra) # 80002bce <iupdate>

    if(type == T_DIR){
    80003ec6:	2a01                	sext.w	s4,s4
    80003ec8:	095a0963          	beq	s4,s5,80003f5a <create+0x11e>
        if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0){
            panic("create dots");
        }
    }

    if(dirlink(dp,path,ip->inum) < 0){
    80003ecc:	00449603          	lh	a2,4(s1)
    80003ed0:	85ca                	mv	a1,s2
    80003ed2:	854e                	mv	a0,s3
    80003ed4:	fffff097          	auipc	ra,0xfffff
    80003ed8:	090080e7          	jalr	144(ra) # 80002f64 <dirlink>
    80003edc:	0c054763          	bltz	a0,80003faa <create+0x16e>
        panic("create >> dirline panic...\n");
    }
    iunlockput(dp);
    80003ee0:	854e                	mv	a0,s3
    80003ee2:	fffff097          	auipc	ra,0xfffff
    80003ee6:	ecc080e7          	jalr	-308(ra) # 80002dae <iunlockput>
    return ip;
}
    80003eea:	8526                	mv	a0,s1
    80003eec:	70e2                	ld	ra,56(sp)
    80003eee:	7442                	ld	s0,48(sp)
    80003ef0:	74a2                	ld	s1,40(sp)
    80003ef2:	7902                	ld	s2,32(sp)
    80003ef4:	69e2                	ld	s3,24(sp)
    80003ef6:	6a42                	ld	s4,16(sp)
    80003ef8:	6aa2                	ld	s5,8(sp)
    80003efa:	6b02                	ld	s6,0(sp)
    80003efc:	6121                	addi	sp,sp,64
    80003efe:	8082                	ret
        if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE)){
    80003f00:	04455783          	lhu	a5,68(a0)
    80003f04:	37f9                	addiw	a5,a5,-2
    80003f06:	17c2                	slli	a5,a5,0x30
    80003f08:	93c1                	srli	a5,a5,0x30
    80003f0a:	4705                	li	a4,1
    80003f0c:	fcf77fe3          	bgeu	a4,a5,80003eea <create+0xae>
    if((ip = ialloc(dp->dev,type)) == 0){
    80003f10:	4589                	li	a1,2
    80003f12:	0009a503          	lw	a0,0(s3)
    80003f16:	fffff097          	auipc	ra,0xfffff
    80003f1a:	bf6080e7          	jalr	-1034(ra) # 80002b0c <ialloc>
    80003f1e:	84aa                	mv	s1,a0
    80003f20:	c11d                	beqz	a0,80003f46 <create+0x10a>
    ilock(ip);
    80003f22:	8526                	mv	a0,s1
    80003f24:	fffff097          	auipc	ra,0xfffff
    80003f28:	aa6080e7          	jalr	-1370(ra) # 800029ca <ilock>
    ip->major = major;
    80003f2c:	05549323          	sh	s5,70(s1)
    ip->minor = minor;
    80003f30:	05649423          	sh	s6,72(s1)
    ip->nlink = 1;
    80003f34:	4785                	li	a5,1
    80003f36:	04f49523          	sh	a5,74(s1)
    iupdate(ip);
    80003f3a:	8526                	mv	a0,s1
    80003f3c:	fffff097          	auipc	ra,0xfffff
    80003f40:	c92080e7          	jalr	-878(ra) # 80002bce <iupdate>
    if(type == T_DIR){
    80003f44:	b761                	j	80003ecc <create+0x90>
        panic("fs.c create >> ialloc panic..\n");
    80003f46:	00004517          	auipc	a0,0x4
    80003f4a:	96a50513          	addi	a0,a0,-1686 # 800078b0 <syscalls+0x70>
    80003f4e:	ffffc097          	auipc	ra,0xffffc
    80003f52:	536080e7          	jalr	1334(ra) # 80000484 <panic>
    80003f56:	4481                	li	s1,0
    80003f58:	b7b1                	j	80003ea4 <create+0x68>
        iupdate(dp);
    80003f5a:	854e                	mv	a0,s3
    80003f5c:	fffff097          	auipc	ra,0xfffff
    80003f60:	c72080e7          	jalr	-910(ra) # 80002bce <iupdate>
        if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0){
    80003f64:	00449603          	lh	a2,4(s1)
    80003f68:	00004597          	auipc	a1,0x4
    80003f6c:	96858593          	addi	a1,a1,-1688 # 800078d0 <syscalls+0x90>
    80003f70:	8526                	mv	a0,s1
    80003f72:	fffff097          	auipc	ra,0xfffff
    80003f76:	ff2080e7          	jalr	-14(ra) # 80002f64 <dirlink>
    80003f7a:	00054f63          	bltz	a0,80003f98 <create+0x15c>
    80003f7e:	00499603          	lh	a2,4(s3)
    80003f82:	00004597          	auipc	a1,0x4
    80003f86:	95658593          	addi	a1,a1,-1706 # 800078d8 <syscalls+0x98>
    80003f8a:	8526                	mv	a0,s1
    80003f8c:	fffff097          	auipc	ra,0xfffff
    80003f90:	fd8080e7          	jalr	-40(ra) # 80002f64 <dirlink>
    80003f94:	f2055ce3          	bgez	a0,80003ecc <create+0x90>
            panic("create dots");
    80003f98:	00004517          	auipc	a0,0x4
    80003f9c:	94850513          	addi	a0,a0,-1720 # 800078e0 <syscalls+0xa0>
    80003fa0:	ffffc097          	auipc	ra,0xffffc
    80003fa4:	4e4080e7          	jalr	1252(ra) # 80000484 <panic>
    80003fa8:	b715                	j	80003ecc <create+0x90>
        panic("create >> dirline panic...\n");
    80003faa:	00004517          	auipc	a0,0x4
    80003fae:	94650513          	addi	a0,a0,-1722 # 800078f0 <syscalls+0xb0>
    80003fb2:	ffffc097          	auipc	ra,0xffffc
    80003fb6:	4d2080e7          	jalr	1234(ra) # 80000484 <panic>
    80003fba:	b71d                	j	80003ee0 <create+0xa4>

0000000080003fbc <fetchaddr>:
int fetchaddr(uint64 addr,uint64 *ip){
    80003fbc:	1101                	addi	sp,sp,-32
    80003fbe:	ec06                	sd	ra,24(sp)
    80003fc0:	e822                	sd	s0,16(sp)
    80003fc2:	e426                	sd	s1,8(sp)
    80003fc4:	e04a                	sd	s2,0(sp)
    80003fc6:	1000                	addi	s0,sp,32
    80003fc8:	84aa                	mv	s1,a0
    80003fca:	892e                	mv	s2,a1
    struct proc *p = myproc();
    80003fcc:	ffffc097          	auipc	ra,0xffffc
    80003fd0:	5d6080e7          	jalr	1494(ra) # 800005a2 <myproc>
    if(addr >= p->sz || addr+sizeof(uint64) > p->sz){
    80003fd4:	6d3c                	ld	a5,88(a0)
    80003fd6:	02f4f563          	bgeu	s1,a5,80004000 <fetchaddr+0x44>
    80003fda:	00848713          	addi	a4,s1,8
    80003fde:	02e7e163          	bltu	a5,a4,80004000 <fetchaddr+0x44>
    if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0){
    80003fe2:	46a1                	li	a3,8
    80003fe4:	8626                	mv	a2,s1
    80003fe6:	85ca                	mv	a1,s2
    80003fe8:	7528                	ld	a0,104(a0)
    80003fea:	00001097          	auipc	ra,0x1
    80003fee:	f3e080e7          	jalr	-194(ra) # 80004f28 <copyin>
    80003ff2:	e10d                	bnez	a0,80004014 <fetchaddr+0x58>
}
    80003ff4:	60e2                	ld	ra,24(sp)
    80003ff6:	6442                	ld	s0,16(sp)
    80003ff8:	64a2                	ld	s1,8(sp)
    80003ffa:	6902                	ld	s2,0(sp)
    80003ffc:	6105                	addi	sp,sp,32
    80003ffe:	8082                	ret
        panic("fetchaddr:addr >= p->sz || addr+sizeof(uint64) > p->sz");
    80004000:	00004517          	auipc	a0,0x4
    80004004:	91050513          	addi	a0,a0,-1776 # 80007910 <syscalls+0xd0>
    80004008:	ffffc097          	auipc	ra,0xffffc
    8000400c:	47c080e7          	jalr	1148(ra) # 80000484 <panic>
        return -1;
    80004010:	557d                	li	a0,-1
    80004012:	b7cd                	j	80003ff4 <fetchaddr+0x38>
        panic("fetchaddr:copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0");
    80004014:	00004517          	auipc	a0,0x4
    80004018:	93450513          	addi	a0,a0,-1740 # 80007948 <syscalls+0x108>
    8000401c:	ffffc097          	auipc	ra,0xffffc
    80004020:	468080e7          	jalr	1128(ra) # 80000484 <panic>
        return -1;
    80004024:	557d                	li	a0,-1
    80004026:	b7f9                	j	80003ff4 <fetchaddr+0x38>

0000000080004028 <sys_read>:
uint64 sys_read(){
    80004028:	7179                	addi	sp,sp,-48
    8000402a:	f406                	sd	ra,40(sp)
    8000402c:	f022                	sd	s0,32(sp)
    8000402e:	1800                	addi	s0,sp,48
    if(argfd(0,0,&f) < 0 || argint(2,&sz) < 0 || argaddr(1,&p) < 0){
    80004030:	fd840613          	addi	a2,s0,-40
    80004034:	4581                	li	a1,0
    80004036:	4501                	li	a0,0
    80004038:	00000097          	auipc	ra,0x0
    8000403c:	d94080e7          	jalr	-620(ra) # 80003dcc <argfd>
    80004040:	00054b63          	bltz	a0,80004056 <sys_read+0x2e>
    80004044:	fec40593          	addi	a1,s0,-20
    80004048:	4509                	li	a0,2
    8000404a:	00000097          	auipc	ra,0x0
    8000404e:	cd8080e7          	jalr	-808(ra) # 80003d22 <argint>
    80004052:	02055863          	bgez	a0,80004082 <sys_read+0x5a>
        panic("sys_read param failure\n");
    80004056:	00004517          	auipc	a0,0x4
    8000405a:	93a50513          	addi	a0,a0,-1734 # 80007990 <syscalls+0x150>
    8000405e:	ffffc097          	auipc	ra,0xffffc
    80004062:	426080e7          	jalr	1062(ra) # 80000484 <panic>
    return fileread(f,p,sz);
    80004066:	fec42603          	lw	a2,-20(s0)
    8000406a:	fe043583          	ld	a1,-32(s0)
    8000406e:	fd843503          	ld	a0,-40(s0)
    80004072:	fffff097          	auipc	ra,0xfffff
    80004076:	18e080e7          	jalr	398(ra) # 80003200 <fileread>
}
    8000407a:	70a2                	ld	ra,40(sp)
    8000407c:	7402                	ld	s0,32(sp)
    8000407e:	6145                	addi	sp,sp,48
    80004080:	8082                	ret
    if(argfd(0,0,&f) < 0 || argint(2,&sz) < 0 || argaddr(1,&p) < 0){
    80004082:	fe040593          	addi	a1,s0,-32
    80004086:	4505                	li	a0,1
    80004088:	00000097          	auipc	ra,0x0
    8000408c:	cbc080e7          	jalr	-836(ra) # 80003d44 <argaddr>
    80004090:	fc055be3          	bgez	a0,80004066 <sys_read+0x3e>
    80004094:	b7c9                	j	80004056 <sys_read+0x2e>

0000000080004096 <sys_exec>:
uint64 sys_exec(){
    80004096:	7135                	addi	sp,sp,-160
    80004098:	ed06                	sd	ra,152(sp)
    8000409a:	e922                	sd	s0,144(sp)
    8000409c:	e526                	sd	s1,136(sp)
    8000409e:	1100                	addi	s0,sp,160
    if(argstr(0,name,MAXPATH) < 0) {
    800040a0:	08000613          	li	a2,128
    800040a4:	f6040593          	addi	a1,s0,-160
    800040a8:	4501                	li	a0,0
    800040aa:	00000097          	auipc	ra,0x0
    800040ae:	c48080e7          	jalr	-952(ra) # 80003cf2 <argstr>
    800040b2:	87aa                	mv	a5,a0
        return -1;
    800040b4:	557d                	li	a0,-1
    if(argstr(0,name,MAXPATH) < 0) {
    800040b6:	0207cf63          	bltz	a5,800040f4 <sys_exec+0x5e>
    printf("exec: %s,p.name:%s,p.id:%d\n",name,myproc()->name,myproc()->pid);
    800040ba:	ffffc097          	auipc	ra,0xffffc
    800040be:	4e8080e7          	jalr	1256(ra) # 800005a2 <myproc>
    800040c2:	84aa                	mv	s1,a0
    800040c4:	ffffc097          	auipc	ra,0xffffc
    800040c8:	4de080e7          	jalr	1246(ra) # 800005a2 <myproc>
    800040cc:	5914                	lw	a3,48(a0)
    800040ce:	02048613          	addi	a2,s1,32
    800040d2:	f6040593          	addi	a1,s0,-160
    800040d6:	00004517          	auipc	a0,0x4
    800040da:	8d250513          	addi	a0,a0,-1838 # 800079a8 <syscalls+0x168>
    800040de:	ffffc097          	auipc	ra,0xffffc
    800040e2:	1dc080e7          	jalr	476(ra) # 800002ba <printf>
    int ret = exec(name,0);
    800040e6:	4581                	li	a1,0
    800040e8:	f6040513          	addi	a0,s0,-160
    800040ec:	fffff097          	auipc	ra,0xfffff
    800040f0:	566080e7          	jalr	1382(ra) # 80003652 <exec>
}
    800040f4:	60ea                	ld	ra,152(sp)
    800040f6:	644a                	ld	s0,144(sp)
    800040f8:	64aa                	ld	s1,136(sp)
    800040fa:	610d                	addi	sp,sp,160
    800040fc:	8082                	ret

00000000800040fe <sys_fstat>:
uint64 sys_fstat(){
    800040fe:	1101                	addi	sp,sp,-32
    80004100:	ec06                	sd	ra,24(sp)
    80004102:	e822                	sd	s0,16(sp)
    80004104:	1000                	addi	s0,sp,32
    if(argfd(0,0,&f) < 0 || argaddr(1,&st) < 0){
    80004106:	fe840613          	addi	a2,s0,-24
    8000410a:	4581                	li	a1,0
    8000410c:	4501                	li	a0,0
    8000410e:	00000097          	auipc	ra,0x0
    80004112:	cbe080e7          	jalr	-834(ra) # 80003dcc <argfd>
        return -1;
    80004116:	57fd                	li	a5,-1
    if(argfd(0,0,&f) < 0 || argaddr(1,&st) < 0){
    80004118:	02054563          	bltz	a0,80004142 <sys_fstat+0x44>
    8000411c:	fe040593          	addi	a1,s0,-32
    80004120:	4505                	li	a0,1
    80004122:	00000097          	auipc	ra,0x0
    80004126:	c22080e7          	jalr	-990(ra) # 80003d44 <argaddr>
        return -1;
    8000412a:	57fd                	li	a5,-1
    if(argfd(0,0,&f) < 0 || argaddr(1,&st) < 0){
    8000412c:	00054b63          	bltz	a0,80004142 <sys_fstat+0x44>
    return filestat(f,st);
    80004130:	fe043583          	ld	a1,-32(s0)
    80004134:	fe843503          	ld	a0,-24(s0)
    80004138:	fffff097          	auipc	ra,0xfffff
    8000413c:	172080e7          	jalr	370(ra) # 800032aa <filestat>
    80004140:	87aa                	mv	a5,a0
}
    80004142:	853e                	mv	a0,a5
    80004144:	60e2                	ld	ra,24(sp)
    80004146:	6442                	ld	s0,16(sp)
    80004148:	6105                	addi	sp,sp,32
    8000414a:	8082                	ret

000000008000414c <sys_close>:
uint64 sys_close(){
    8000414c:	1101                	addi	sp,sp,-32
    8000414e:	ec06                	sd	ra,24(sp)
    80004150:	e822                	sd	s0,16(sp)
    80004152:	1000                	addi	s0,sp,32
    if(argfd(0,&fd,&f) < 0){
    80004154:	fe040613          	addi	a2,s0,-32
    80004158:	fec40593          	addi	a1,s0,-20
    8000415c:	4501                	li	a0,0
    8000415e:	00000097          	auipc	ra,0x0
    80004162:	c6e080e7          	jalr	-914(ra) # 80003dcc <argfd>
        return -1;
    80004166:	57fd                	li	a5,-1
    if(argfd(0,&fd,&f) < 0){
    80004168:	02054463          	bltz	a0,80004190 <sys_close+0x44>
    myproc()->openfs[fd] = 0;
    8000416c:	ffffc097          	auipc	ra,0xffffc
    80004170:	436080e7          	jalr	1078(ra) # 800005a2 <myproc>
    80004174:	fec42783          	lw	a5,-20(s0)
    80004178:	07f1                	addi	a5,a5,28
    8000417a:	078e                	slli	a5,a5,0x3
    8000417c:	97aa                	add	a5,a5,a0
    8000417e:	0007b023          	sd	zero,0(a5)
    fileclose(f);
    80004182:	fe043503          	ld	a0,-32(s0)
    80004186:	fffff097          	auipc	ra,0xfffff
    8000418a:	f6c080e7          	jalr	-148(ra) # 800030f2 <fileclose>
    return 0;
    8000418e:	4781                	li	a5,0
}
    80004190:	853e                	mv	a0,a5
    80004192:	60e2                	ld	ra,24(sp)
    80004194:	6442                	ld	s0,16(sp)
    80004196:	6105                	addi	sp,sp,32
    80004198:	8082                	ret

000000008000419a <sys_dup>:
uint64 sys_dup(){
    8000419a:	7179                	addi	sp,sp,-48
    8000419c:	f406                	sd	ra,40(sp)
    8000419e:	f022                	sd	s0,32(sp)
    800041a0:	ec26                	sd	s1,24(sp)
    800041a2:	e84a                	sd	s2,16(sp)
    800041a4:	1800                	addi	s0,sp,48
    if(argfd(0,0,&f) < 0){
    800041a6:	fd840613          	addi	a2,s0,-40
    800041aa:	4581                	li	a1,0
    800041ac:	4501                	li	a0,0
    800041ae:	00000097          	auipc	ra,0x0
    800041b2:	c1e080e7          	jalr	-994(ra) # 80003dcc <argfd>
        return -1;
    800041b6:	54fd                	li	s1,-1
    if(argfd(0,0,&f) < 0){
    800041b8:	04054263          	bltz	a0,800041fc <sys_dup+0x62>
    if((fd = fdalloc(f)) < 0){
    800041bc:	fd843903          	ld	s2,-40(s0)
    struct proc *p = myproc();
    800041c0:	ffffc097          	auipc	ra,0xffffc
    800041c4:	3e2080e7          	jalr	994(ra) # 800005a2 <myproc>
    for(fd = 0; fd < OPENFILE;fd++){
    800041c8:	0e050793          	addi	a5,a0,224
    800041cc:	4481                	li	s1,0
    800041ce:	46c1                	li	a3,16
        if(p->openfs[fd] == 0){
    800041d0:	6398                	ld	a4,0(a5)
    800041d2:	c719                	beqz	a4,800041e0 <sys_dup+0x46>
    for(fd = 0; fd < OPENFILE;fd++){
    800041d4:	2485                	addiw	s1,s1,1
    800041d6:	07a1                	addi	a5,a5,8
    800041d8:	fed49ce3          	bne	s1,a3,800041d0 <sys_dup+0x36>
        return -1;
    800041dc:	54fd                	li	s1,-1
    800041de:	a839                	j	800041fc <sys_dup+0x62>
            p->openfs[fd] = f;
    800041e0:	01c48793          	addi	a5,s1,28
    800041e4:	078e                	slli	a5,a5,0x3
    800041e6:	953e                	add	a0,a0,a5
    800041e8:	01253023          	sd	s2,0(a0)
    if((fd = fdalloc(f)) < 0){
    800041ec:	0004cf63          	bltz	s1,8000420a <sys_dup+0x70>
    filedup(f);
    800041f0:	fd843503          	ld	a0,-40(s0)
    800041f4:	fffff097          	auipc	ra,0xfffff
    800041f8:	060080e7          	jalr	96(ra) # 80003254 <filedup>
}
    800041fc:	8526                	mv	a0,s1
    800041fe:	70a2                	ld	ra,40(sp)
    80004200:	7402                	ld	s0,32(sp)
    80004202:	64e2                	ld	s1,24(sp)
    80004204:	6942                	ld	s2,16(sp)
    80004206:	6145                	addi	sp,sp,48
    80004208:	8082                	ret
        return -1;
    8000420a:	54fd                	li	s1,-1
    8000420c:	bfc5                	j	800041fc <sys_dup+0x62>

000000008000420e <sys_mknod>:

uint64 sys_mknod(){
    8000420e:	7135                	addi	sp,sp,-160
    80004210:	ed06                	sd	ra,152(sp)
    80004212:	e922                	sd	s0,144(sp)
    80004214:	1100                	addi	s0,sp,160
    struct inode *ip;
    char path[MAXPATH];
    int major, minor;
    if(argstr(0, path, MAXPATH) < 0 || argint(1, &major) < 0 || argint(2, &minor) < 0 ||
    80004216:	08000613          	li	a2,128
    8000421a:	f7040593          	addi	a1,s0,-144
    8000421e:	4501                	li	a0,0
    80004220:	00000097          	auipc	ra,0x0
    80004224:	ad2080e7          	jalr	-1326(ra) # 80003cf2 <argstr>
    80004228:	04054663          	bltz	a0,80004274 <sys_mknod+0x66>
    8000422c:	f6c40593          	addi	a1,s0,-148
    80004230:	4505                	li	a0,1
    80004232:	00000097          	auipc	ra,0x0
    80004236:	af0080e7          	jalr	-1296(ra) # 80003d22 <argint>
    8000423a:	02054d63          	bltz	a0,80004274 <sys_mknod+0x66>
    8000423e:	f6840593          	addi	a1,s0,-152
    80004242:	4509                	li	a0,2
    80004244:	00000097          	auipc	ra,0x0
    80004248:	ade080e7          	jalr	-1314(ra) # 80003d22 <argint>
    8000424c:	02054463          	bltz	a0,80004274 <sys_mknod+0x66>
        (ip = create(path, T_DEVICE, major, minor)) == 0){
    80004250:	f6841683          	lh	a3,-152(s0)
    80004254:	f6c41603          	lh	a2,-148(s0)
    80004258:	458d                	li	a1,3
    8000425a:	f7040513          	addi	a0,s0,-144
    8000425e:	00000097          	auipc	ra,0x0
    80004262:	bde080e7          	jalr	-1058(ra) # 80003e3c <create>
    if(argstr(0, path, MAXPATH) < 0 || argint(1, &major) < 0 || argint(2, &minor) < 0 ||
    80004266:	c519                	beqz	a0,80004274 <sys_mknod+0x66>
        panic("sys_mknod");
        return -1;
    }
    iunlockput(ip);
    80004268:	fffff097          	auipc	ra,0xfffff
    8000426c:	b46080e7          	jalr	-1210(ra) # 80002dae <iunlockput>
    return 0;
    80004270:	4501                	li	a0,0
    80004272:	a811                	j	80004286 <sys_mknod+0x78>
        panic("sys_mknod");
    80004274:	00003517          	auipc	a0,0x3
    80004278:	75450513          	addi	a0,a0,1876 # 800079c8 <syscalls+0x188>
    8000427c:	ffffc097          	auipc	ra,0xffffc
    80004280:	208080e7          	jalr	520(ra) # 80000484 <panic>
        return -1;
    80004284:	557d                	li	a0,-1
}
    80004286:	60ea                	ld	ra,152(sp)
    80004288:	644a                	ld	s0,144(sp)
    8000428a:	610d                	addi	sp,sp,160
    8000428c:	8082                	ret

000000008000428e <sys_write>:

uint64 sys_write() {
    8000428e:	7179                	addi	sp,sp,-48
    80004290:	f406                	sd	ra,40(sp)
    80004292:	f022                	sd	s0,32(sp)
    80004294:	1800                	addi	s0,sp,48
    struct file *f;
    int n;
    uint64 p;
    if(argfd(0,0,&f) < 0 || argint(2,&n) < 0 || argaddr(1,&p) < 0){
    80004296:	fe840613          	addi	a2,s0,-24
    8000429a:	4581                	li	a1,0
    8000429c:	4501                	li	a0,0
    8000429e:	00000097          	auipc	ra,0x0
    800042a2:	b2e080e7          	jalr	-1234(ra) # 80003dcc <argfd>
        return -1;
    800042a6:	57fd                	li	a5,-1
    if(argfd(0,0,&f) < 0 || argint(2,&n) < 0 || argaddr(1,&p) < 0){
    800042a8:	04054163          	bltz	a0,800042ea <sys_write+0x5c>
    800042ac:	fe440593          	addi	a1,s0,-28
    800042b0:	4509                	li	a0,2
    800042b2:	00000097          	auipc	ra,0x0
    800042b6:	a70080e7          	jalr	-1424(ra) # 80003d22 <argint>
        return -1;
    800042ba:	57fd                	li	a5,-1
    if(argfd(0,0,&f) < 0 || argint(2,&n) < 0 || argaddr(1,&p) < 0){
    800042bc:	02054763          	bltz	a0,800042ea <sys_write+0x5c>
    800042c0:	fd840593          	addi	a1,s0,-40
    800042c4:	4505                	li	a0,1
    800042c6:	00000097          	auipc	ra,0x0
    800042ca:	a7e080e7          	jalr	-1410(ra) # 80003d44 <argaddr>
        return -1;
    800042ce:	57fd                	li	a5,-1
    if(argfd(0,0,&f) < 0 || argint(2,&n) < 0 || argaddr(1,&p) < 0){
    800042d0:	00054d63          	bltz	a0,800042ea <sys_write+0x5c>
    }
    return filewrite(f,p,n);
    800042d4:	fe442603          	lw	a2,-28(s0)
    800042d8:	fd843583          	ld	a1,-40(s0)
    800042dc:	fe843503          	ld	a0,-24(s0)
    800042e0:	fffff097          	auipc	ra,0xfffff
    800042e4:	eaa080e7          	jalr	-342(ra) # 8000318a <filewrite>
    800042e8:	87aa                	mv	a5,a0
}
    800042ea:	853e                	mv	a0,a5
    800042ec:	70a2                	ld	ra,40(sp)
    800042ee:	7402                	ld	s0,32(sp)
    800042f0:	6145                	addi	sp,sp,48
    800042f2:	8082                	ret

00000000800042f4 <sys_open>:

uint64 sys_open(){
    800042f4:	7131                	addi	sp,sp,-192
    800042f6:	fd06                	sd	ra,184(sp)
    800042f8:	f922                	sd	s0,176(sp)
    800042fa:	f526                	sd	s1,168(sp)
    800042fc:	f14a                	sd	s2,160(sp)
    800042fe:	ed4e                	sd	s3,152(sp)
    80004300:	0180                	addi	s0,sp,192
    char path[MAXPATH];
    int fd,model;
    int n;
    if((n = argstr(0,path,MAXPATH)) < 0 || argint(1,&model) < 0){
    80004302:	08000613          	li	a2,128
    80004306:	f5040593          	addi	a1,s0,-176
    8000430a:	4501                	li	a0,0
    8000430c:	00000097          	auipc	ra,0x0
    80004310:	9e6080e7          	jalr	-1562(ra) # 80003cf2 <argstr>
        return -1;
    80004314:	54fd                	li	s1,-1
    if((n = argstr(0,path,MAXPATH)) < 0 || argint(1,&model) < 0){
    80004316:	10054663          	bltz	a0,80004422 <sys_open+0x12e>
    8000431a:	f4c40593          	addi	a1,s0,-180
    8000431e:	4505                	li	a0,1
    80004320:	00000097          	auipc	ra,0x0
    80004324:	a02080e7          	jalr	-1534(ra) # 80003d22 <argint>
    80004328:	10054c63          	bltz	a0,80004440 <sys_open+0x14c>
    }
    struct inode *ip;

    if(model & O_CREATE){
    8000432c:	f4c42783          	lw	a5,-180(s0)
    80004330:	2007f793          	andi	a5,a5,512
    80004334:	cf91                	beqz	a5,80004350 <sys_open+0x5c>
        // create file
        ip = create(path,T_FILE,0,0);
    80004336:	4681                	li	a3,0
    80004338:	4601                	li	a2,0
    8000433a:	4589                	li	a1,2
    8000433c:	f5040513          	addi	a0,s0,-176
    80004340:	00000097          	auipc	ra,0x0
    80004344:	afc080e7          	jalr	-1284(ra) # 80003e3c <create>
    80004348:	892a                	mv	s2,a0
        if(ip == 0){
    8000434a:	e919                	bnez	a0,80004360 <sys_open+0x6c>
            return -1;
    8000434c:	54fd                	li	s1,-1
    8000434e:	a8d1                	j	80004422 <sys_open+0x12e>
        }
    }else{
        ip = iname(path);
    80004350:	f5040513          	addi	a0,s0,-176
    80004354:	ffffe097          	auipc	ra,0xffffe
    80004358:	726080e7          	jalr	1830(ra) # 80002a7a <iname>
    8000435c:	892a                	mv	s2,a0
        if(ip == 0){
    8000435e:	c939                	beqz	a0,800043b4 <sys_open+0xc0>
            printf("ip == 0 \n");
            return -1;
        }
    }
    ilock(ip);
    80004360:	854a                	mv	a0,s2
    80004362:	ffffe097          	auipc	ra,0xffffe
    80004366:	668080e7          	jalr	1640(ra) # 800029ca <ilock>

    if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000436a:	04491703          	lh	a4,68(s2)
    8000436e:	478d                	li	a5,3
    80004370:	00f71763          	bne	a4,a5,8000437e <sys_open+0x8a>
    80004374:	04695703          	lhu	a4,70(s2)
    80004378:	47a5                	li	a5,9
    8000437a:	04e7e763          	bltu	a5,a4,800043c8 <sys_open+0xd4>
        panic("open: ip type error\n");
        return -1;
    }

    struct file *f;
    if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000437e:	fffff097          	auipc	ra,0xfffff
    80004382:	d0a080e7          	jalr	-758(ra) # 80003088 <filealloc>
    80004386:	89aa                	mv	s3,a0
    80004388:	cd19                	beqz	a0,800043a6 <sys_open+0xb2>
    struct proc *p = myproc();
    8000438a:	ffffc097          	auipc	ra,0xffffc
    8000438e:	218080e7          	jalr	536(ra) # 800005a2 <myproc>
    for(fd = 0; fd < OPENFILE;fd++){
    80004392:	0e050793          	addi	a5,a0,224
    80004396:	4481                	li	s1,0
    80004398:	46c1                	li	a3,16
        if(p->openfs[fd] == 0){
    8000439a:	6398                	ld	a4,0(a5)
    8000439c:	c321                	beqz	a4,800043dc <sys_open+0xe8>
    for(fd = 0; fd < OPENFILE;fd++){
    8000439e:	2485                	addiw	s1,s1,1
    800043a0:	07a1                	addi	a5,a5,8
    800043a2:	fed49ce3          	bne	s1,a3,8000439a <sys_open+0xa6>
        fileclose(f);
    800043a6:	854e                	mv	a0,s3
    800043a8:	fffff097          	auipc	ra,0xfffff
    800043ac:	d4a080e7          	jalr	-694(ra) # 800030f2 <fileclose>
        return -1;
    800043b0:	54fd                	li	s1,-1
    800043b2:	a885                	j	80004422 <sys_open+0x12e>
            printf("ip == 0 \n");
    800043b4:	00003517          	auipc	a0,0x3
    800043b8:	62450513          	addi	a0,a0,1572 # 800079d8 <syscalls+0x198>
    800043bc:	ffffc097          	auipc	ra,0xffffc
    800043c0:	efe080e7          	jalr	-258(ra) # 800002ba <printf>
            return -1;
    800043c4:	54fd                	li	s1,-1
    800043c6:	a8b1                	j	80004422 <sys_open+0x12e>
        panic("open: ip type error\n");
    800043c8:	00003517          	auipc	a0,0x3
    800043cc:	62050513          	addi	a0,a0,1568 # 800079e8 <syscalls+0x1a8>
    800043d0:	ffffc097          	auipc	ra,0xffffc
    800043d4:	0b4080e7          	jalr	180(ra) # 80000484 <panic>
        return -1;
    800043d8:	54fd                	li	s1,-1
    800043da:	a0a1                	j	80004422 <sys_open+0x12e>
            p->openfs[fd] = f;
    800043dc:	01c48793          	addi	a5,s1,28
    800043e0:	078e                	slli	a5,a5,0x3
    800043e2:	953e                	add	a0,a0,a5
    800043e4:	01353023          	sd	s3,0(a0)
    if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800043e8:	fa04cfe3          	bltz	s1,800043a6 <sys_open+0xb2>
    }

    if(ip->type == T_DEVICE){
    800043ec:	04491703          	lh	a4,68(s2)
    800043f0:	478d                	li	a5,3
    800043f2:	04f70063          	beq	a4,a5,80004432 <sys_open+0x13e>
        f->type = FD_DEVICE;
        f->major = ip->major;
    }else{
       f->type = FD_INODE;
    800043f6:	4789                	li	a5,2
    800043f8:	00f9a023          	sw	a5,0(s3)
       f->off = 0;
    800043fc:	0009ac23          	sw	zero,24(s3)
    }
    f->ip = ip;
    80004400:	0129b823          	sd	s2,16(s3)
    f->readable = !(model & O_WRONLY);
    80004404:	f4c42783          	lw	a5,-180(s0)
    80004408:	0017c713          	xori	a4,a5,1
    8000440c:	8b05                	andi	a4,a4,1
    8000440e:	00e98423          	sb	a4,8(s3)
    f->writable = (model & O_WRONLY) | (model & O_RDWR);
    80004412:	8b8d                	andi	a5,a5,3
    80004414:	00f984a3          	sb	a5,9(s3)
    iunlock(ip);
    80004418:	854a                	mv	a0,s2
    8000441a:	ffffe097          	auipc	ra,0xffffe
    8000441e:	6ac080e7          	jalr	1708(ra) # 80002ac6 <iunlock>
    return fd;
    80004422:	8526                	mv	a0,s1
    80004424:	70ea                	ld	ra,184(sp)
    80004426:	744a                	ld	s0,176(sp)
    80004428:	74aa                	ld	s1,168(sp)
    8000442a:	790a                	ld	s2,160(sp)
    8000442c:	69ea                	ld	s3,152(sp)
    8000442e:	6129                	addi	sp,sp,192
    80004430:	8082                	ret
        f->type = FD_DEVICE;
    80004432:	00f9a023          	sw	a5,0(s3)
        f->major = ip->major;
    80004436:	04691783          	lh	a5,70(s2)
    8000443a:	00f99e23          	sh	a5,28(s3)
    8000443e:	b7c9                	j	80004400 <sys_open+0x10c>
        return -1;
    80004440:	54fd                	li	s1,-1
    80004442:	b7c5                	j	80004422 <sys_open+0x12e>

0000000080004444 <sys_wait>:
#include "fs.h"
#include "defs.h"
#include "file.h"
#include "proc.h"

uint64 sys_wait(){
    80004444:	1101                	addi	sp,sp,-32
    80004446:	ec06                	sd	ra,24(sp)
    80004448:	e822                	sd	s0,16(sp)
    8000444a:	1000                	addi	s0,sp,32
    uint64 p;
    if(argaddr(0,&p) < 0){
    8000444c:	fe840593          	addi	a1,s0,-24
    80004450:	4501                	li	a0,0
    80004452:	00000097          	auipc	ra,0x0
    80004456:	8f2080e7          	jalr	-1806(ra) # 80003d44 <argaddr>
    8000445a:	87aa                	mv	a5,a0
        return -1;
    8000445c:	557d                	li	a0,-1
    if(argaddr(0,&p) < 0){
    8000445e:	0007c863          	bltz	a5,8000446e <sys_wait+0x2a>
    }
    return wait(p);
    80004462:	fe843503          	ld	a0,-24(s0)
    80004466:	ffffc097          	auipc	ra,0xffffc
    8000446a:	62e080e7          	jalr	1582(ra) # 80000a94 <wait>
}
    8000446e:	60e2                	ld	ra,24(sp)
    80004470:	6442                	ld	s0,16(sp)
    80004472:	6105                	addi	sp,sp,32
    80004474:	8082                	ret

0000000080004476 <sys_fork>:


uint64 sys_fork(){
    80004476:	1141                	addi	sp,sp,-16
    80004478:	e406                	sd	ra,8(sp)
    8000447a:	e022                	sd	s0,0(sp)
    8000447c:	0800                	addi	s0,sp,16
    return fork();
    8000447e:	ffffd097          	auipc	ra,0xffffd
    80004482:	b96080e7          	jalr	-1130(ra) # 80001014 <fork>
}
    80004486:	60a2                	ld	ra,8(sp)
    80004488:	6402                	ld	s0,0(sp)
    8000448a:	0141                	addi	sp,sp,16
    8000448c:	8082                	ret

000000008000448e <sys_exit>:

uint64 sys_exit() {
    8000448e:	1101                	addi	sp,sp,-32
    80004490:	ec06                	sd	ra,24(sp)
    80004492:	e822                	sd	s0,16(sp)
    80004494:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0){
    80004496:	fec40593          	addi	a1,s0,-20
    8000449a:	4501                	li	a0,0
    8000449c:	00000097          	auipc	ra,0x0
    800044a0:	886080e7          	jalr	-1914(ra) # 80003d22 <argint>
    return -1;
    800044a4:	57fd                	li	a5,-1
  if(argint(0, &n) < 0){
    800044a6:	00054963          	bltz	a0,800044b8 <sys_exit+0x2a>
  }
  exit(n);
    800044aa:	fec42503          	lw	a0,-20(s0)
    800044ae:	ffffd097          	auipc	ra,0xffffd
    800044b2:	a8a080e7          	jalr	-1398(ra) # 80000f38 <exit>
  return 0;
    800044b6:	4781                	li	a5,0
}
    800044b8:	853e                	mv	a0,a5
    800044ba:	60e2                	ld	ra,24(sp)
    800044bc:	6442                	ld	s0,16(sp)
    800044be:	6105                	addi	sp,sp,32
    800044c0:	8082                	ret

00000000800044c2 <sys_sbrk>:


uint64 sys_sbrk(){
    800044c2:	7179                	addi	sp,sp,-48
    800044c4:	f406                	sd	ra,40(sp)
    800044c6:	f022                	sd	s0,32(sp)
    800044c8:	ec26                	sd	s1,24(sp)
    800044ca:	1800                	addi	s0,sp,48
  int n;
  if(argint(0,&n) < 0){
    800044cc:	fdc40593          	addi	a1,s0,-36
    800044d0:	4501                	li	a0,0
    800044d2:	00000097          	auipc	ra,0x0
    800044d6:	850080e7          	jalr	-1968(ra) # 80003d22 <argint>
    800044da:	87aa                	mv	a5,a0
    return -1;
    800044dc:	557d                	li	a0,-1
  if(argint(0,&n) < 0){
    800044de:	0207c063          	bltz	a5,800044fe <sys_sbrk+0x3c>
  }
  int addr = myproc()->sz;
    800044e2:	ffffc097          	auipc	ra,0xffffc
    800044e6:	0c0080e7          	jalr	192(ra) # 800005a2 <myproc>
    800044ea:	4d24                	lw	s1,88(a0)
  if(growproc(n) < 0){
    800044ec:	fdc42503          	lw	a0,-36(s0)
    800044f0:	ffffc097          	auipc	ra,0xffffc
    800044f4:	358080e7          	jalr	856(ra) # 80000848 <growproc>
    800044f8:	00054863          	bltz	a0,80004508 <sys_sbrk+0x46>
    return -1;
  }
  return addr;
    800044fc:	8526                	mv	a0,s1
    800044fe:	70a2                	ld	ra,40(sp)
    80004500:	7402                	ld	s0,32(sp)
    80004502:	64e2                	ld	s1,24(sp)
    80004504:	6145                	addi	sp,sp,48
    80004506:	8082                	ret
    return -1;
    80004508:	557d                	li	a0,-1
    8000450a:	bfd5                	j	800044fe <sys_sbrk+0x3c>

000000008000450c <kfree>:
struct {
    struct spinlock lk;
    struct run *freelist;
} kmem;

void kfree(void *pa){
    8000450c:	1101                	addi	sp,sp,-32
    8000450e:	ec06                	sd	ra,24(sp)
    80004510:	e822                	sd	s0,16(sp)
    80004512:	e426                	sd	s1,8(sp)
    80004514:	e04a                	sd	s2,0(sp)
    80004516:	1000                	addi	s0,sp,32
    80004518:	84aa                	mv	s1,a0
    struct run *r;
    if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP){
    8000451a:	03451793          	slli	a5,a0,0x34
    8000451e:	eb99                	bnez	a5,80004534 <kfree+0x28>
    80004520:	0001c797          	auipc	a5,0x1c
    80004524:	41078793          	addi	a5,a5,1040 # 80020930 <end>
    80004528:	00f56663          	bltu	a0,a5,80004534 <kfree+0x28>
    8000452c:	47c5                	li	a5,17
    8000452e:	07ee                	slli	a5,a5,0x1b
    80004530:	00f56a63          	bltu	a0,a5,80004544 <kfree+0x38>
        panic("kfree");
    80004534:	00003517          	auipc	a0,0x3
    80004538:	4cc50513          	addi	a0,a0,1228 # 80007a00 <syscalls+0x1c0>
    8000453c:	ffffc097          	auipc	ra,0xffffc
    80004540:	f48080e7          	jalr	-184(ra) # 80000484 <panic>
    }
    memset(pa,1,PGSIZE);
    80004544:	6605                	lui	a2,0x1
    80004546:	4585                	li	a1,1
    80004548:	8526                	mv	a0,s1
    8000454a:	ffffe097          	auipc	ra,0xffffe
    8000454e:	a00080e7          	jalr	-1536(ra) # 80001f4a <memset>

    r = (struct run*)pa;
    acquire(&kmem.lk);
    80004552:	0001c917          	auipc	s2,0x1c
    80004556:	3be90913          	addi	s2,s2,958 # 80020910 <kmem>
    8000455a:	854a                	mv	a0,s2
    8000455c:	ffffd097          	auipc	ra,0xffffd
    80004560:	2d4080e7          	jalr	724(ra) # 80001830 <acquire>
    r->next = kmem.freelist;
    80004564:	01893783          	ld	a5,24(s2)
    80004568:	e09c                	sd	a5,0(s1)
    kmem.freelist = r;
    8000456a:	00993c23          	sd	s1,24(s2)
    release(&kmem.lk);
    8000456e:	854a                	mv	a0,s2
    80004570:	ffffd097          	auipc	ra,0xffffd
    80004574:	382080e7          	jalr	898(ra) # 800018f2 <release>
}
    80004578:	60e2                	ld	ra,24(sp)
    8000457a:	6442                	ld	s0,16(sp)
    8000457c:	64a2                	ld	s1,8(sp)
    8000457e:	6902                	ld	s2,0(sp)
    80004580:	6105                	addi	sp,sp,32
    80004582:	8082                	ret

0000000080004584 <freerange>:


void
freerange(void *pa_start, void *pa_end)
{
    80004584:	7179                	addi	sp,sp,-48
    80004586:	f406                	sd	ra,40(sp)
    80004588:	f022                	sd	s0,32(sp)
    8000458a:	ec26                	sd	s1,24(sp)
    8000458c:	e84a                	sd	s2,16(sp)
    8000458e:	e44e                	sd	s3,8(sp)
    80004590:	e052                	sd	s4,0(sp)
    80004592:	1800                	addi	s0,sp,48
  char *p;
  p = (char*)PGROUNDUP((uint64)pa_start);
    80004594:	6785                	lui	a5,0x1
    80004596:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    8000459a:	94aa                	add	s1,s1,a0
    8000459c:	757d                	lui	a0,0xfffff
    8000459e:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800045a0:	94be                	add	s1,s1,a5
    800045a2:	0095ee63          	bltu	a1,s1,800045be <freerange+0x3a>
    800045a6:	892e                	mv	s2,a1
    kfree(p);
    800045a8:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800045aa:	6985                	lui	s3,0x1
    kfree(p);
    800045ac:	01448533          	add	a0,s1,s4
    800045b0:	00000097          	auipc	ra,0x0
    800045b4:	f5c080e7          	jalr	-164(ra) # 8000450c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800045b8:	94ce                	add	s1,s1,s3
    800045ba:	fe9979e3          	bgeu	s2,s1,800045ac <freerange+0x28>
}
    800045be:	70a2                	ld	ra,40(sp)
    800045c0:	7402                	ld	s0,32(sp)
    800045c2:	64e2                	ld	s1,24(sp)
    800045c4:	6942                	ld	s2,16(sp)
    800045c6:	69a2                	ld	s3,8(sp)
    800045c8:	6a02                	ld	s4,0(sp)
    800045ca:	6145                	addi	sp,sp,48
    800045cc:	8082                	ret

00000000800045ce <kalloc>:

void* kalloc(void)
{
    800045ce:	1101                	addi	sp,sp,-32
    800045d0:	ec06                	sd	ra,24(sp)
    800045d2:	e822                	sd	s0,16(sp)
    800045d4:	e426                	sd	s1,8(sp)
    800045d6:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lk);
    800045d8:	0001c497          	auipc	s1,0x1c
    800045dc:	33848493          	addi	s1,s1,824 # 80020910 <kmem>
    800045e0:	8526                	mv	a0,s1
    800045e2:	ffffd097          	auipc	ra,0xffffd
    800045e6:	24e080e7          	jalr	590(ra) # 80001830 <acquire>
  r = kmem.freelist;
    800045ea:	6c84                	ld	s1,24(s1)
  if(r){
    800045ec:	c885                	beqz	s1,8000461c <kalloc+0x4e>
    kmem.freelist = r->next;
    800045ee:	609c                	ld	a5,0(s1)
    800045f0:	0001c517          	auipc	a0,0x1c
    800045f4:	32050513          	addi	a0,a0,800 # 80020910 <kmem>
    800045f8:	ed1c                	sd	a5,24(a0)
  }
  release(&kmem.lk);
    800045fa:	ffffd097          	auipc	ra,0xffffd
    800045fe:	2f8080e7          	jalr	760(ra) # 800018f2 <release>

  if(r){
    memset((char*)r, 5, PGSIZE);
    80004602:	6605                	lui	a2,0x1
    80004604:	4595                	li	a1,5
    80004606:	8526                	mv	a0,s1
    80004608:	ffffe097          	auipc	ra,0xffffe
    8000460c:	942080e7          	jalr	-1726(ra) # 80001f4a <memset>
  }
  return (void*)r;
}
    80004610:	8526                	mv	a0,s1
    80004612:	60e2                	ld	ra,24(sp)
    80004614:	6442                	ld	s0,16(sp)
    80004616:	64a2                	ld	s1,8(sp)
    80004618:	6105                	addi	sp,sp,32
    8000461a:	8082                	ret
  release(&kmem.lk);
    8000461c:	0001c517          	auipc	a0,0x1c
    80004620:	2f450513          	addi	a0,a0,756 # 80020910 <kmem>
    80004624:	ffffd097          	auipc	ra,0xffffd
    80004628:	2ce080e7          	jalr	718(ra) # 800018f2 <release>
  if(r){
    8000462c:	b7d5                	j	80004610 <kalloc+0x42>

000000008000462e <walk>:


pte_t* walk(pagetable_t pagetable, uint64 va, int alloc) {
    8000462e:	7139                	addi	sp,sp,-64
    80004630:	fc06                	sd	ra,56(sp)
    80004632:	f822                	sd	s0,48(sp)
    80004634:	f426                	sd	s1,40(sp)
    80004636:	f04a                	sd	s2,32(sp)
    80004638:	ec4e                	sd	s3,24(sp)
    8000463a:	e852                	sd	s4,16(sp)
    8000463c:	e456                	sd	s5,8(sp)
    8000463e:	e05a                	sd	s6,0(sp)
    80004640:	0080                	addi	s0,sp,64
    80004642:	84aa                	mv	s1,a0
    80004644:	89ae                	mv	s3,a1
    80004646:	8ab2                	mv	s5,a2
  if(va >= MAXVA){
    80004648:	57fd                	li	a5,-1
    8000464a:	83e9                	srli	a5,a5,0x1a
    8000464c:	00b7e563          	bltu	a5,a1,80004656 <walk+0x28>
pte_t* walk(pagetable_t pagetable, uint64 va, int alloc) {
    80004650:	4a79                	li	s4,30
    panic("walk");
  }
  for(int level = 2; level > 0; level--) {
    80004652:	4b31                	li	s6,12
    80004654:	a091                	j	80004698 <walk+0x6a>
    panic("walk");
    80004656:	00003517          	auipc	a0,0x3
    8000465a:	3b250513          	addi	a0,a0,946 # 80007a08 <syscalls+0x1c8>
    8000465e:	ffffc097          	auipc	ra,0xffffc
    80004662:	e26080e7          	jalr	-474(ra) # 80000484 <panic>
    80004666:	b7ed                	j	80004650 <walk+0x22>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80004668:	060a8663          	beqz	s5,800046d4 <walk+0xa6>
    8000466c:	00000097          	auipc	ra,0x0
    80004670:	f62080e7          	jalr	-158(ra) # 800045ce <kalloc>
    80004674:	84aa                	mv	s1,a0
    80004676:	c529                	beqz	a0,800046c0 <walk+0x92>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80004678:	6605                	lui	a2,0x1
    8000467a:	4581                	li	a1,0
    8000467c:	ffffe097          	auipc	ra,0xffffe
    80004680:	8ce080e7          	jalr	-1842(ra) # 80001f4a <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80004684:	00c4d793          	srli	a5,s1,0xc
    80004688:	07aa                	slli	a5,a5,0xa
    8000468a:	0017e793          	ori	a5,a5,1
    8000468e:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80004692:	3a5d                	addiw	s4,s4,-9
    80004694:	036a0063          	beq	s4,s6,800046b4 <walk+0x86>
    pte_t *pte = &pagetable[PX(level, va)];
    80004698:	0149d933          	srl	s2,s3,s4
    8000469c:	1ff97913          	andi	s2,s2,511
    800046a0:	090e                	slli	s2,s2,0x3
    800046a2:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800046a4:	00093483          	ld	s1,0(s2)
    800046a8:	0014f793          	andi	a5,s1,1
    800046ac:	dfd5                	beqz	a5,80004668 <walk+0x3a>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800046ae:	80a9                	srli	s1,s1,0xa
    800046b0:	04b2                	slli	s1,s1,0xc
    800046b2:	b7c5                	j	80004692 <walk+0x64>
    }
  }
  return &pagetable[PX(0, va)];
    800046b4:	00c9d513          	srli	a0,s3,0xc
    800046b8:	1ff57513          	andi	a0,a0,511
    800046bc:	050e                	slli	a0,a0,0x3
    800046be:	9526                	add	a0,a0,s1
}
    800046c0:	70e2                	ld	ra,56(sp)
    800046c2:	7442                	ld	s0,48(sp)
    800046c4:	74a2                	ld	s1,40(sp)
    800046c6:	7902                	ld	s2,32(sp)
    800046c8:	69e2                	ld	s3,24(sp)
    800046ca:	6a42                	ld	s4,16(sp)
    800046cc:	6aa2                	ld	s5,8(sp)
    800046ce:	6b02                	ld	s6,0(sp)
    800046d0:	6121                	addi	sp,sp,64
    800046d2:	8082                	ret
        return 0;
    800046d4:	4501                	li	a0,0
    800046d6:	b7ed                	j	800046c0 <walk+0x92>

00000000800046d8 <mappages>:


int mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800046d8:	711d                	addi	sp,sp,-96
    800046da:	ec86                	sd	ra,88(sp)
    800046dc:	e8a2                	sd	s0,80(sp)
    800046de:	e4a6                	sd	s1,72(sp)
    800046e0:	e0ca                	sd	s2,64(sp)
    800046e2:	fc4e                	sd	s3,56(sp)
    800046e4:	f852                	sd	s4,48(sp)
    800046e6:	f456                	sd	s5,40(sp)
    800046e8:	f05a                	sd	s6,32(sp)
    800046ea:	ec5e                	sd	s7,24(sp)
    800046ec:	e862                	sd	s8,16(sp)
    800046ee:	e466                	sd	s9,8(sp)
    800046f0:	1080                	addi	s0,sp,96
    800046f2:	8b2a                	mv	s6,a0
    800046f4:	8a2e                	mv	s4,a1
    800046f6:	8932                	mv	s2,a2
    800046f8:	8ab6                	mv	s5,a3
    800046fa:	8bba                	mv	s7,a4
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800046fc:	c20d                	beqz	a2,8000471e <mappages+0x46>
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800046fe:	77fd                	lui	a5,0xfffff
    80004700:	00fa76b3          	and	a3,s4,a5
  last = PGROUNDDOWN(va + size - 1);
    80004704:	1a7d                	addi	s4,s4,-1
    80004706:	9a4a                	add	s4,s4,s2
    80004708:	00fa7a33          	and	s4,s4,a5
  a = PGROUNDDOWN(va);
    8000470c:	89b6                	mv	s3,a3
    8000470e:	40da8ab3          	sub	s5,s5,a3
  for(;;){
    if((pte = walk(pagetable, a, 1)) == 0)
      return -1;
    if(*pte & PTE_V)
      panic("mappages: remap");
    80004712:	00003c97          	auipc	s9,0x3
    80004716:	30ec8c93          	addi	s9,s9,782 # 80007a20 <syscalls+0x1e0>
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    8000471a:	6c05                	lui	s8,0x1
    8000471c:	a815                	j	80004750 <mappages+0x78>
    panic("mappages: size");
    8000471e:	00003517          	auipc	a0,0x3
    80004722:	2f250513          	addi	a0,a0,754 # 80007a10 <syscalls+0x1d0>
    80004726:	ffffc097          	auipc	ra,0xffffc
    8000472a:	d5e080e7          	jalr	-674(ra) # 80000484 <panic>
    8000472e:	bfc1                	j	800046fe <mappages+0x26>
      panic("mappages: remap");
    80004730:	8566                	mv	a0,s9
    80004732:	ffffc097          	auipc	ra,0xffffc
    80004736:	d52080e7          	jalr	-686(ra) # 80000484 <panic>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000473a:	80b1                	srli	s1,s1,0xc
    8000473c:	04aa                	slli	s1,s1,0xa
    8000473e:	0174e4b3          	or	s1,s1,s7
    80004742:	0014e493          	ori	s1,s1,1
    80004746:	00993023          	sd	s1,0(s2)
    if(a == last)
    8000474a:	05498063          	beq	s3,s4,8000478a <mappages+0xb2>
    a += PGSIZE;
    8000474e:	99e2                	add	s3,s3,s8
  for(;;){
    80004750:	013a84b3          	add	s1,s5,s3
    if((pte = walk(pagetable, a, 1)) == 0)
    80004754:	4605                	li	a2,1
    80004756:	85ce                	mv	a1,s3
    80004758:	855a                	mv	a0,s6
    8000475a:	00000097          	auipc	ra,0x0
    8000475e:	ed4080e7          	jalr	-300(ra) # 8000462e <walk>
    80004762:	892a                	mv	s2,a0
    80004764:	c509                	beqz	a0,8000476e <mappages+0x96>
    if(*pte & PTE_V)
    80004766:	611c                	ld	a5,0(a0)
    80004768:	8b85                	andi	a5,a5,1
    8000476a:	dbe1                	beqz	a5,8000473a <mappages+0x62>
    8000476c:	b7d1                	j	80004730 <mappages+0x58>
      return -1;
    8000476e:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80004770:	60e6                	ld	ra,88(sp)
    80004772:	6446                	ld	s0,80(sp)
    80004774:	64a6                	ld	s1,72(sp)
    80004776:	6906                	ld	s2,64(sp)
    80004778:	79e2                	ld	s3,56(sp)
    8000477a:	7a42                	ld	s4,48(sp)
    8000477c:	7aa2                	ld	s5,40(sp)
    8000477e:	7b02                	ld	s6,32(sp)
    80004780:	6be2                	ld	s7,24(sp)
    80004782:	6c42                	ld	s8,16(sp)
    80004784:	6ca2                	ld	s9,8(sp)
    80004786:	6125                	addi	sp,sp,96
    80004788:	8082                	ret
  return 0;
    8000478a:	4501                	li	a0,0
    8000478c:	b7d5                	j	80004770 <mappages+0x98>

000000008000478e <kvmmap>:


void kvmmap(pagetable_t kpg,uint64 va,uint64 pa,uint64 sz,int perm){
    8000478e:	1141                	addi	sp,sp,-16
    80004790:	e406                	sd	ra,8(sp)
    80004792:	e022                	sd	s0,0(sp)
    80004794:	0800                	addi	s0,sp,16
    80004796:	87b6                	mv	a5,a3
    if(mappages(kpg,va,sz,pa,perm) != 0){
    80004798:	86b2                	mv	a3,a2
    8000479a:	863e                	mv	a2,a5
    8000479c:	00000097          	auipc	ra,0x0
    800047a0:	f3c080e7          	jalr	-196(ra) # 800046d8 <mappages>
    800047a4:	e509                	bnez	a0,800047ae <kvmmap+0x20>
        panic("kvmmap");
    }
}
    800047a6:	60a2                	ld	ra,8(sp)
    800047a8:	6402                	ld	s0,0(sp)
    800047aa:	0141                	addi	sp,sp,16
    800047ac:	8082                	ret
        panic("kvmmap");
    800047ae:	00003517          	auipc	a0,0x3
    800047b2:	28250513          	addi	a0,a0,642 # 80007a30 <syscalls+0x1f0>
    800047b6:	ffffc097          	auipc	ra,0xffffc
    800047ba:	cce080e7          	jalr	-818(ra) # 80000484 <panic>
}
    800047be:	b7e5                	j	800047a6 <kvmmap+0x18>

00000000800047c0 <kvmmake>:

pagetable_t kvmmake(){
    800047c0:	1101                	addi	sp,sp,-32
    800047c2:	ec06                	sd	ra,24(sp)
    800047c4:	e822                	sd	s0,16(sp)
    800047c6:	e426                	sd	s1,8(sp)
    800047c8:	e04a                	sd	s2,0(sp)
    800047ca:	1000                	addi	s0,sp,32
    pagetable_t kpg;
    kpg = (pagetable_t) kalloc();
    800047cc:	00000097          	auipc	ra,0x0
    800047d0:	e02080e7          	jalr	-510(ra) # 800045ce <kalloc>
    800047d4:	84aa                	mv	s1,a0
    
    memset(kpg,0,PGSIZE);
    800047d6:	6605                	lui	a2,0x1
    800047d8:	4581                	li	a1,0
    800047da:	ffffd097          	auipc	ra,0xffffd
    800047de:	770080e7          	jalr	1904(ra) # 80001f4a <memset>

    kvmmap(kpg, UART, UART, PGSIZE, PTE_R | PTE_W);
    800047e2:	4719                	li	a4,6
    800047e4:	6685                	lui	a3,0x1
    800047e6:	10000637          	lui	a2,0x10000
    800047ea:	100005b7          	lui	a1,0x10000
    800047ee:	8526                	mv	a0,s1
    800047f0:	00000097          	auipc	ra,0x0
    800047f4:	f9e080e7          	jalr	-98(ra) # 8000478e <kvmmap>

    kvmmap(kpg, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800047f8:	4719                	li	a4,6
    800047fa:	6685                	lui	a3,0x1
    800047fc:	10001637          	lui	a2,0x10001
    80004800:	100015b7          	lui	a1,0x10001
    80004804:	8526                	mv	a0,s1
    80004806:	00000097          	auipc	ra,0x0
    8000480a:	f88080e7          	jalr	-120(ra) # 8000478e <kvmmap>

    kvmmap(kpg, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    8000480e:	4719                	li	a4,6
    80004810:	004006b7          	lui	a3,0x400
    80004814:	0c000637          	lui	a2,0xc000
    80004818:	0c0005b7          	lui	a1,0xc000
    8000481c:	8526                	mv	a0,s1
    8000481e:	00000097          	auipc	ra,0x0
    80004822:	f70080e7          	jalr	-144(ra) # 8000478e <kvmmap>
    
    kvmmap(kpg, KERNELBASE, KERNELBASE, (uint64)etext-KERNELBASE, PTE_R | PTE_X);
    80004826:	00002917          	auipc	s2,0x2
    8000482a:	7da90913          	addi	s2,s2,2010 # 80007000 <etext>
    8000482e:	4729                	li	a4,10
    80004830:	80002697          	auipc	a3,0x80002
    80004834:	7d068693          	addi	a3,a3,2000 # 7000 <_entry-0x7fff9000>
    80004838:	4605                	li	a2,1
    8000483a:	067e                	slli	a2,a2,0x1f
    8000483c:	85b2                	mv	a1,a2
    8000483e:	8526                	mv	a0,s1
    80004840:	00000097          	auipc	ra,0x0
    80004844:	f4e080e7          	jalr	-178(ra) # 8000478e <kvmmap>

    kvmmap(kpg, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80004848:	4719                	li	a4,6
    8000484a:	46c5                	li	a3,17
    8000484c:	06ee                	slli	a3,a3,0x1b
    8000484e:	412686b3          	sub	a3,a3,s2
    80004852:	864a                	mv	a2,s2
    80004854:	85ca                	mv	a1,s2
    80004856:	8526                	mv	a0,s1
    80004858:	00000097          	auipc	ra,0x0
    8000485c:	f36080e7          	jalr	-202(ra) # 8000478e <kvmmap>

    kvmmap(kpg, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80004860:	4729                	li	a4,10
    80004862:	6685                	lui	a3,0x1
    80004864:	00001617          	auipc	a2,0x1
    80004868:	79c60613          	addi	a2,a2,1948 # 80006000 <_trampoline>
    8000486c:	040005b7          	lui	a1,0x4000
    80004870:	15fd                	addi	a1,a1,-1
    80004872:	05b2                	slli	a1,a1,0xc
    80004874:	8526                	mv	a0,s1
    80004876:	00000097          	auipc	ra,0x0
    8000487a:	f18080e7          	jalr	-232(ra) # 8000478e <kvmmap>
    
    proc_mapstacks(kpg);
    8000487e:	8526                	mv	a0,s1
    80004880:	ffffc097          	auipc	ra,0xffffc
    80004884:	050080e7          	jalr	80(ra) # 800008d0 <proc_mapstacks>

    return kpg;
}
    80004888:	8526                	mv	a0,s1
    8000488a:	60e2                	ld	ra,24(sp)
    8000488c:	6442                	ld	s0,16(sp)
    8000488e:	64a2                	ld	s1,8(sp)
    80004890:	6902                	ld	s2,0(sp)
    80004892:	6105                	addi	sp,sp,32
    80004894:	8082                	ret

0000000080004896 <uvmclear>:

void uvmclear(pagetable_t pagetable,uint64 va){
    80004896:	1101                	addi	sp,sp,-32
    80004898:	ec06                	sd	ra,24(sp)
    8000489a:	e822                	sd	s0,16(sp)
    8000489c:	e426                	sd	s1,8(sp)
    8000489e:	1000                	addi	s0,sp,32
    pte_t *pte;
    pte = walk(pagetable,va,0);
    800048a0:	4601                	li	a2,0
    800048a2:	00000097          	auipc	ra,0x0
    800048a6:	d8c080e7          	jalr	-628(ra) # 8000462e <walk>
    800048aa:	84aa                	mv	s1,a0
    if(pte == 0){
    800048ac:	c909                	beqz	a0,800048be <uvmclear+0x28>
        panic("uvmclear");
    }
    *pte &= ~PTE_U;
    800048ae:	609c                	ld	a5,0(s1)
    800048b0:	9bbd                	andi	a5,a5,-17
    800048b2:	e09c                	sd	a5,0(s1)
}
    800048b4:	60e2                	ld	ra,24(sp)
    800048b6:	6442                	ld	s0,16(sp)
    800048b8:	64a2                	ld	s1,8(sp)
    800048ba:	6105                	addi	sp,sp,32
    800048bc:	8082                	ret
        panic("uvmclear");
    800048be:	00003517          	auipc	a0,0x3
    800048c2:	17a50513          	addi	a0,a0,378 # 80007a38 <syscalls+0x1f8>
    800048c6:	ffffc097          	auipc	ra,0xffffc
    800048ca:	bbe080e7          	jalr	-1090(ra) # 80000484 <panic>
    800048ce:	b7c5                	j	800048ae <uvmclear+0x18>

00000000800048d0 <freewalk>:
  freewalk(pagetable);
}

void
freewalk(pagetable_t pagetable)
{
    800048d0:	7139                	addi	sp,sp,-64
    800048d2:	fc06                	sd	ra,56(sp)
    800048d4:	f822                	sd	s0,48(sp)
    800048d6:	f426                	sd	s1,40(sp)
    800048d8:	f04a                	sd	s2,32(sp)
    800048da:	ec4e                	sd	s3,24(sp)
    800048dc:	e852                	sd	s4,16(sp)
    800048de:	e456                	sd	s5,8(sp)
    800048e0:	0080                	addi	s0,sp,64
    800048e2:	8aaa                	mv	s5,a0
  for(int i = 0; i < 512; i++){
    800048e4:	84aa                	mv	s1,a0
    800048e6:	6905                	lui	s2,0x1
    800048e8:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800048ea:	4985                	li	s3,1
      uint64 child = PTE2PA(pte);
      freewalk((pagetable_t)child);
      pagetable[i] = 0;
    } else if(pte & PTE_V){
      panic("freewalk: leaf");
    800048ec:	00003a17          	auipc	s4,0x3
    800048f0:	15ca0a13          	addi	s4,s4,348 # 80007a48 <syscalls+0x208>
    800048f4:	a015                	j	80004918 <freewalk+0x48>
      uint64 child = PTE2PA(pte);
    800048f6:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800048f8:	0532                	slli	a0,a0,0xc
    800048fa:	00000097          	auipc	ra,0x0
    800048fe:	fd6080e7          	jalr	-42(ra) # 800048d0 <freewalk>
      pagetable[i] = 0;
    80004902:	0004b023          	sd	zero,0(s1)
    80004906:	a031                	j	80004912 <freewalk+0x42>
      panic("freewalk: leaf");
    80004908:	8552                	mv	a0,s4
    8000490a:	ffffc097          	auipc	ra,0xffffc
    8000490e:	b7a080e7          	jalr	-1158(ra) # 80000484 <panic>
  for(int i = 0; i < 512; i++){
    80004912:	04a1                	addi	s1,s1,8
    80004914:	01248a63          	beq	s1,s2,80004928 <freewalk+0x58>
    pte_t pte = pagetable[i];
    80004918:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000491a:	00f57793          	andi	a5,a0,15
    8000491e:	fd378ce3          	beq	a5,s3,800048f6 <freewalk+0x26>
    } else if(pte & PTE_V){
    80004922:	8905                	andi	a0,a0,1
    80004924:	d57d                	beqz	a0,80004912 <freewalk+0x42>
    80004926:	b7cd                	j	80004908 <freewalk+0x38>
    }
  }
  kfree((void*)pagetable);
    80004928:	8556                	mv	a0,s5
    8000492a:	00000097          	auipc	ra,0x0
    8000492e:	be2080e7          	jalr	-1054(ra) # 8000450c <kfree>
}
    80004932:	70e2                	ld	ra,56(sp)
    80004934:	7442                	ld	s0,48(sp)
    80004936:	74a2                	ld	s1,40(sp)
    80004938:	7902                	ld	s2,32(sp)
    8000493a:	69e2                	ld	s3,24(sp)
    8000493c:	6a42                	ld	s4,16(sp)
    8000493e:	6aa2                	ld	s5,8(sp)
    80004940:	6121                	addi	sp,sp,64
    80004942:	8082                	ret

0000000080004944 <uvmcpy>:
    pte_t *pte;
    uint64 pa,i;
    uint flags;
    char *mem;

    for(i = 0; i < sz; i += PGSIZE) {
    80004944:	10060063          	beqz	a2,80004a44 <uvmcpy+0x100>
int uvmcpy(pagetable_t old,pagetable_t new,uint64 sz){
    80004948:	7159                	addi	sp,sp,-112
    8000494a:	f486                	sd	ra,104(sp)
    8000494c:	f0a2                	sd	s0,96(sp)
    8000494e:	eca6                	sd	s1,88(sp)
    80004950:	e8ca                	sd	s2,80(sp)
    80004952:	e4ce                	sd	s3,72(sp)
    80004954:	e0d2                	sd	s4,64(sp)
    80004956:	fc56                	sd	s5,56(sp)
    80004958:	f85a                	sd	s6,48(sp)
    8000495a:	f45e                	sd	s7,40(sp)
    8000495c:	f062                	sd	s8,32(sp)
    8000495e:	ec66                	sd	s9,24(sp)
    80004960:	e86a                	sd	s10,16(sp)
    80004962:	e46e                	sd	s11,8(sp)
    80004964:	1880                	addi	s0,sp,112
    80004966:	8a2a                	mv	s4,a0
    80004968:	8aae                	mv	s5,a1
    8000496a:	89b2                	mv	s3,a2
    for(i = 0; i < sz; i += PGSIZE) {
    8000496c:	4901                	li	s2,0
        if((pte = walk(old,i,0)) == 0){
            panic("uvmcpy walk\n");
    8000496e:	00003c97          	auipc	s9,0x3
    80004972:	0eac8c93          	addi	s9,s9,234 # 80007a58 <syscalls+0x218>
        }
        if((*pte & PTE_V) == 0){
            panic("uvmcpy: page not present\n");
    80004976:	00003b97          	auipc	s7,0x3
    8000497a:	0f2b8b93          	addi	s7,s7,242 # 80007a68 <syscalls+0x228>
        }
        pa = PTE2PA(*pte);
        flags = PTE_FLAGS(*pte);
        if((mem = kalloc()) == 0){
            panic("uvmcpy: kalloc\n");
    8000497e:	00003c17          	auipc	s8,0x3
    80004982:	10ac0c13          	addi	s8,s8,266 # 80007a88 <syscalls+0x248>
        }
        memmove(mem,(char*)pa,PGSIZE);
        if(mappages(new,i,PGSIZE,(uint64)mem,flags) != 0){
            kfree(mem);
            panic("uvmcpy mappages\n");
    80004986:	00003b17          	auipc	s6,0x3
    8000498a:	112b0b13          	addi	s6,s6,274 # 80007a98 <syscalls+0x258>
    8000498e:	a089                	j	800049d0 <uvmcpy+0x8c>
            panic("uvmcpy walk\n");
    80004990:	8566                	mv	a0,s9
    80004992:	ffffc097          	auipc	ra,0xffffc
    80004996:	af2080e7          	jalr	-1294(ra) # 80000484 <panic>
    8000499a:	a0a1                	j	800049e2 <uvmcpy+0x9e>
            panic("uvmcpy: page not present\n");
    8000499c:	855e                	mv	a0,s7
    8000499e:	ffffc097          	auipc	ra,0xffffc
    800049a2:	ae6080e7          	jalr	-1306(ra) # 80000484 <panic>
    800049a6:	a089                	j	800049e8 <uvmcpy+0xa4>
            panic("uvmcpy: kalloc\n");
    800049a8:	8562                	mv	a0,s8
    800049aa:	ffffc097          	auipc	ra,0xffffc
    800049ae:	ada080e7          	jalr	-1318(ra) # 80000484 <panic>
    800049b2:	a0b9                	j	80004a00 <uvmcpy+0xbc>
            kfree(mem);
    800049b4:	8526                	mv	a0,s1
    800049b6:	00000097          	auipc	ra,0x0
    800049ba:	b56080e7          	jalr	-1194(ra) # 8000450c <kfree>
            panic("uvmcpy mappages\n");
    800049be:	855a                	mv	a0,s6
    800049c0:	ffffc097          	auipc	ra,0xffffc
    800049c4:	ac4080e7          	jalr	-1340(ra) # 80000484 <panic>
    for(i = 0; i < sz; i += PGSIZE) {
    800049c8:	6785                	lui	a5,0x1
    800049ca:	993e                	add	s2,s2,a5
    800049cc:	05397c63          	bgeu	s2,s3,80004a24 <uvmcpy+0xe0>
        if((pte = walk(old,i,0)) == 0){
    800049d0:	4601                	li	a2,0
    800049d2:	85ca                	mv	a1,s2
    800049d4:	8552                	mv	a0,s4
    800049d6:	00000097          	auipc	ra,0x0
    800049da:	c58080e7          	jalr	-936(ra) # 8000462e <walk>
    800049de:	84aa                	mv	s1,a0
    800049e0:	d945                	beqz	a0,80004990 <uvmcpy+0x4c>
        if((*pte & PTE_V) == 0){
    800049e2:	609c                	ld	a5,0(s1)
    800049e4:	8b85                	andi	a5,a5,1
    800049e6:	dbdd                	beqz	a5,8000499c <uvmcpy+0x58>
        pa = PTE2PA(*pte);
    800049e8:	6098                	ld	a4,0(s1)
    800049ea:	00a75d13          	srli	s10,a4,0xa
    800049ee:	0d32                	slli	s10,s10,0xc
        flags = PTE_FLAGS(*pte);
    800049f0:	3ff77d93          	andi	s11,a4,1023
        if((mem = kalloc()) == 0){
    800049f4:	00000097          	auipc	ra,0x0
    800049f8:	bda080e7          	jalr	-1062(ra) # 800045ce <kalloc>
    800049fc:	84aa                	mv	s1,a0
    800049fe:	d54d                	beqz	a0,800049a8 <uvmcpy+0x64>
        memmove(mem,(char*)pa,PGSIZE);
    80004a00:	6605                	lui	a2,0x1
    80004a02:	85ea                	mv	a1,s10
    80004a04:	8526                	mv	a0,s1
    80004a06:	ffffd097          	auipc	ra,0xffffd
    80004a0a:	56c080e7          	jalr	1388(ra) # 80001f72 <memmove>
        if(mappages(new,i,PGSIZE,(uint64)mem,flags) != 0){
    80004a0e:	876e                	mv	a4,s11
    80004a10:	86a6                	mv	a3,s1
    80004a12:	6605                	lui	a2,0x1
    80004a14:	85ca                	mv	a1,s2
    80004a16:	8556                	mv	a0,s5
    80004a18:	00000097          	auipc	ra,0x0
    80004a1c:	cc0080e7          	jalr	-832(ra) # 800046d8 <mappages>
    80004a20:	d545                	beqz	a0,800049c8 <uvmcpy+0x84>
    80004a22:	bf49                	j	800049b4 <uvmcpy+0x70>
        }
    }
    return 0;
}
    80004a24:	4501                	li	a0,0
    80004a26:	70a6                	ld	ra,104(sp)
    80004a28:	7406                	ld	s0,96(sp)
    80004a2a:	64e6                	ld	s1,88(sp)
    80004a2c:	6946                	ld	s2,80(sp)
    80004a2e:	69a6                	ld	s3,72(sp)
    80004a30:	6a06                	ld	s4,64(sp)
    80004a32:	7ae2                	ld	s5,56(sp)
    80004a34:	7b42                	ld	s6,48(sp)
    80004a36:	7ba2                	ld	s7,40(sp)
    80004a38:	7c02                	ld	s8,32(sp)
    80004a3a:	6ce2                	ld	s9,24(sp)
    80004a3c:	6d42                	ld	s10,16(sp)
    80004a3e:	6da2                	ld	s11,8(sp)
    80004a40:	6165                	addi	sp,sp,112
    80004a42:	8082                	ret
    80004a44:	4501                	li	a0,0
    80004a46:	8082                	ret

0000000080004a48 <walkaddr>:
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
  uvmfree(pagetable, sz);
}

uint64 walkaddr(pagetable_t pagetable, uint64 va) {
    80004a48:	1101                	addi	sp,sp,-32
    80004a4a:	ec06                	sd	ra,24(sp)
    80004a4c:	e822                	sd	s0,16(sp)
    80004a4e:	e426                	sd	s1,8(sp)
    80004a50:	1000                	addi	s0,sp,32
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA){
    80004a52:	57fd                	li	a5,-1
    80004a54:	83e9                	srli	a5,a5,0x1a
    return 0;
    80004a56:	4481                	li	s1,0
  if(va >= MAXVA){
    80004a58:	00b7f863          	bgeu	a5,a1,80004a68 <walkaddr+0x20>
  pa = PTE2PA(*pte);
  if(pa == 0){
    panic("walkaddr: pa is zero");
  }
  return pa;
}
    80004a5c:	8526                	mv	a0,s1
    80004a5e:	60e2                	ld	ra,24(sp)
    80004a60:	6442                	ld	s0,16(sp)
    80004a62:	64a2                	ld	s1,8(sp)
    80004a64:	6105                	addi	sp,sp,32
    80004a66:	8082                	ret
  pte = walk(pagetable, va, 0);
    80004a68:	4601                	li	a2,0
    80004a6a:	00000097          	auipc	ra,0x0
    80004a6e:	bc4080e7          	jalr	-1084(ra) # 8000462e <walk>
  if(pte == 0){
    80004a72:	c50d                	beqz	a0,80004a9c <walkaddr+0x54>
  if((*pte & PTE_V) == 0){
    80004a74:	611c                	ld	a5,0(a0)
    80004a76:	0017f493          	andi	s1,a5,1
    80004a7a:	c89d                	beqz	s1,80004ab0 <walkaddr+0x68>
  if((*pte & PTE_U) == 0){
    80004a7c:	0107f493          	andi	s1,a5,16
    80004a80:	c0a9                	beqz	s1,80004ac2 <walkaddr+0x7a>
  pa = PTE2PA(*pte);
    80004a82:	00a7d493          	srli	s1,a5,0xa
    80004a86:	04b2                	slli	s1,s1,0xc
  if(pa == 0){
    80004a88:	f8f1                	bnez	s1,80004a5c <walkaddr+0x14>
    panic("walkaddr: pa is zero");
    80004a8a:	00003517          	auipc	a0,0x3
    80004a8e:	05650513          	addi	a0,a0,86 # 80007ae0 <syscalls+0x2a0>
    80004a92:	ffffc097          	auipc	ra,0xffffc
    80004a96:	9f2080e7          	jalr	-1550(ra) # 80000484 <panic>
    80004a9a:	b7c9                	j	80004a5c <walkaddr+0x14>
    panic("walkaddr:pte:0");
    80004a9c:	00003517          	auipc	a0,0x3
    80004aa0:	01450513          	addi	a0,a0,20 # 80007ab0 <syscalls+0x270>
    80004aa4:	ffffc097          	auipc	ra,0xffffc
    80004aa8:	9e0080e7          	jalr	-1568(ra) # 80000484 <panic>
    return 0;
    80004aac:	4481                	li	s1,0
    80004aae:	b77d                	j	80004a5c <walkaddr+0x14>
    panic("walkaddr:PTE_V");
    80004ab0:	00003517          	auipc	a0,0x3
    80004ab4:	01050513          	addi	a0,a0,16 # 80007ac0 <syscalls+0x280>
    80004ab8:	ffffc097          	auipc	ra,0xffffc
    80004abc:	9cc080e7          	jalr	-1588(ra) # 80000484 <panic>
    return 0;
    80004ac0:	bf71                	j	80004a5c <walkaddr+0x14>
    panic("walkaddr:PTE_U");
    80004ac2:	00003517          	auipc	a0,0x3
    80004ac6:	00e50513          	addi	a0,a0,14 # 80007ad0 <syscalls+0x290>
    80004aca:	ffffc097          	auipc	ra,0xffffc
    80004ace:	9ba080e7          	jalr	-1606(ra) # 80000484 <panic>
    return 0;
    80004ad2:	b769                	j	80004a5c <walkaddr+0x14>

0000000080004ad4 <kinit>:


void kinit(){
    80004ad4:	1141                	addi	sp,sp,-16
    80004ad6:	e406                	sd	ra,8(sp)
    80004ad8:	e022                	sd	s0,0(sp)
    80004ada:	0800                	addi	s0,sp,16
    initlock(&kmem.lk,"kmem");
    80004adc:	00003597          	auipc	a1,0x3
    80004ae0:	01c58593          	addi	a1,a1,28 # 80007af8 <syscalls+0x2b8>
    80004ae4:	0001c517          	auipc	a0,0x1c
    80004ae8:	e2c50513          	addi	a0,a0,-468 # 80020910 <kmem>
    80004aec:	ffffd097          	auipc	ra,0xffffd
    80004af0:	cb8080e7          	jalr	-840(ra) # 800017a4 <initlock>
    freerange(end,(void*)PHYSTOP);
    80004af4:	45c5                	li	a1,17
    80004af6:	05ee                	slli	a1,a1,0x1b
    80004af8:	0001c517          	auipc	a0,0x1c
    80004afc:	e3850513          	addi	a0,a0,-456 # 80020930 <end>
    80004b00:	00000097          	auipc	ra,0x0
    80004b04:	a84080e7          	jalr	-1404(ra) # 80004584 <freerange>

    kernel_pagetable = kvmmake();
    80004b08:	00000097          	auipc	ra,0x0
    80004b0c:	cb8080e7          	jalr	-840(ra) # 800047c0 <kvmmake>
    80004b10:	00003797          	auipc	a5,0x3
    80004b14:	50a7bc23          	sd	a0,1304(a5) # 80008028 <kernel_pagetable>

    w_satp(MAKE_SATP(kernel_pagetable));
    80004b18:	8131                	srli	a0,a0,0xc
    80004b1a:	57fd                	li	a5,-1
    80004b1c:	17fe                	slli	a5,a5,0x3f
    80004b1e:	8d5d                	or	a0,a0,a5
    asm volatile("csrw satp,%0" :: "r"(x));
    80004b20:	18051073          	csrw	satp,a0
    asm volatile("sfence.vma zero, zero");
    80004b24:	12000073          	sfence.vma
    sfence_vma();
}
    80004b28:	60a2                	ld	ra,8(sp)
    80004b2a:	6402                	ld	s0,0(sp)
    80004b2c:	0141                	addi	sp,sp,16
    80004b2e:	8082                	ret

0000000080004b30 <uvmunmap>:
  }
  return newsz;
}

void uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80004b30:	711d                	addi	sp,sp,-96
    80004b32:	ec86                	sd	ra,88(sp)
    80004b34:	e8a2                	sd	s0,80(sp)
    80004b36:	e4a6                	sd	s1,72(sp)
    80004b38:	e0ca                	sd	s2,64(sp)
    80004b3a:	fc4e                	sd	s3,56(sp)
    80004b3c:	f852                	sd	s4,48(sp)
    80004b3e:	f456                	sd	s5,40(sp)
    80004b40:	f05a                	sd	s6,32(sp)
    80004b42:	ec5e                	sd	s7,24(sp)
    80004b44:	e862                	sd	s8,16(sp)
    80004b46:	e466                	sd	s9,8(sp)
    80004b48:	e06a                	sd	s10,0(sp)
    80004b4a:	1080                	addi	s0,sp,96
    80004b4c:	8a2a                	mv	s4,a0
    80004b4e:	892e                	mv	s2,a1
    80004b50:	89b2                	mv	s3,a2
    80004b52:	8ab6                	mv	s5,a3
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80004b54:	03459793          	slli	a5,a1,0x34
    80004b58:	e785                	bnez	a5,80004b80 <uvmunmap+0x50>
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80004b5a:	09b2                	slli	s3,s3,0xc
    80004b5c:	99ca                	add	s3,s3,s2
    80004b5e:	09397c63          	bgeu	s2,s3,80004bf6 <uvmunmap+0xc6>
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    80004b62:	00003d17          	auipc	s10,0x3
    80004b66:	fb6d0d13          	addi	s10,s10,-74 # 80007b18 <syscalls+0x2d8>
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    80004b6a:	00003c17          	auipc	s8,0x3
    80004b6e:	fbec0c13          	addi	s8,s8,-66 # 80007b28 <syscalls+0x2e8>
    if(PTE_FLAGS(*pte) == PTE_V)
    80004b72:	4b85                	li	s7,1
      panic("uvmunmap: not a leaf");
    80004b74:	00003c97          	auipc	s9,0x3
    80004b78:	fccc8c93          	addi	s9,s9,-52 # 80007b40 <syscalls+0x300>
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80004b7c:	6b05                	lui	s6,0x1
    80004b7e:	a881                	j	80004bce <uvmunmap+0x9e>
    panic("uvmunmap: not aligned");
    80004b80:	00003517          	auipc	a0,0x3
    80004b84:	f8050513          	addi	a0,a0,-128 # 80007b00 <syscalls+0x2c0>
    80004b88:	ffffc097          	auipc	ra,0xffffc
    80004b8c:	8fc080e7          	jalr	-1796(ra) # 80000484 <panic>
    80004b90:	b7e9                	j	80004b5a <uvmunmap+0x2a>
      panic("uvmunmap: walk");
    80004b92:	856a                	mv	a0,s10
    80004b94:	ffffc097          	auipc	ra,0xffffc
    80004b98:	8f0080e7          	jalr	-1808(ra) # 80000484 <panic>
    80004b9c:	a091                	j	80004be0 <uvmunmap+0xb0>
      panic("uvmunmap: not mapped");
    80004b9e:	8562                	mv	a0,s8
    80004ba0:	ffffc097          	auipc	ra,0xffffc
    80004ba4:	8e4080e7          	jalr	-1820(ra) # 80000484 <panic>
    80004ba8:	a83d                	j	80004be6 <uvmunmap+0xb6>
      panic("uvmunmap: not a leaf");
    80004baa:	8566                	mv	a0,s9
    80004bac:	ffffc097          	auipc	ra,0xffffc
    80004bb0:	8d8080e7          	jalr	-1832(ra) # 80000484 <panic>
    80004bb4:	a835                	j	80004bf0 <uvmunmap+0xc0>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
    80004bb6:	6088                	ld	a0,0(s1)
    80004bb8:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80004bba:	0532                	slli	a0,a0,0xc
    80004bbc:	00000097          	auipc	ra,0x0
    80004bc0:	950080e7          	jalr	-1712(ra) # 8000450c <kfree>
    }
    *pte = 0;
    80004bc4:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80004bc8:	995a                	add	s2,s2,s6
    80004bca:	03397663          	bgeu	s2,s3,80004bf6 <uvmunmap+0xc6>
    if((pte = walk(pagetable, a, 0)) == 0)
    80004bce:	4601                	li	a2,0
    80004bd0:	85ca                	mv	a1,s2
    80004bd2:	8552                	mv	a0,s4
    80004bd4:	00000097          	auipc	ra,0x0
    80004bd8:	a5a080e7          	jalr	-1446(ra) # 8000462e <walk>
    80004bdc:	84aa                	mv	s1,a0
    80004bde:	d955                	beqz	a0,80004b92 <uvmunmap+0x62>
    if((*pte & PTE_V) == 0)
    80004be0:	609c                	ld	a5,0(s1)
    80004be2:	8b85                	andi	a5,a5,1
    80004be4:	dfcd                	beqz	a5,80004b9e <uvmunmap+0x6e>
    if(PTE_FLAGS(*pte) == PTE_V)
    80004be6:	609c                	ld	a5,0(s1)
    80004be8:	3ff7f793          	andi	a5,a5,1023
    80004bec:	fb778fe3          	beq	a5,s7,80004baa <uvmunmap+0x7a>
    if(do_free){
    80004bf0:	fc0a8ae3          	beqz	s5,80004bc4 <uvmunmap+0x94>
    80004bf4:	b7c9                	j	80004bb6 <uvmunmap+0x86>
  }
}
    80004bf6:	60e6                	ld	ra,88(sp)
    80004bf8:	6446                	ld	s0,80(sp)
    80004bfa:	64a6                	ld	s1,72(sp)
    80004bfc:	6906                	ld	s2,64(sp)
    80004bfe:	79e2                	ld	s3,56(sp)
    80004c00:	7a42                	ld	s4,48(sp)
    80004c02:	7aa2                	ld	s5,40(sp)
    80004c04:	7b02                	ld	s6,32(sp)
    80004c06:	6be2                	ld	s7,24(sp)
    80004c08:	6c42                	ld	s8,16(sp)
    80004c0a:	6ca2                	ld	s9,8(sp)
    80004c0c:	6d02                	ld	s10,0(sp)
    80004c0e:	6125                	addi	sp,sp,96
    80004c10:	8082                	ret

0000000080004c12 <uvmfree>:
uvmfree(pagetable_t pagetable, uint64 sz) {
    80004c12:	1101                	addi	sp,sp,-32
    80004c14:	ec06                	sd	ra,24(sp)
    80004c16:	e822                	sd	s0,16(sp)
    80004c18:	e426                	sd	s1,8(sp)
    80004c1a:	1000                	addi	s0,sp,32
    80004c1c:	84aa                	mv	s1,a0
  if(sz > 0){
    80004c1e:	e999                	bnez	a1,80004c34 <uvmfree+0x22>
  freewalk(pagetable);
    80004c20:	8526                	mv	a0,s1
    80004c22:	00000097          	auipc	ra,0x0
    80004c26:	cae080e7          	jalr	-850(ra) # 800048d0 <freewalk>
}
    80004c2a:	60e2                	ld	ra,24(sp)
    80004c2c:	6442                	ld	s0,16(sp)
    80004c2e:	64a2                	ld	s1,8(sp)
    80004c30:	6105                	addi	sp,sp,32
    80004c32:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80004c34:	6605                	lui	a2,0x1
    80004c36:	167d                	addi	a2,a2,-1
    80004c38:	962e                	add	a2,a2,a1
    80004c3a:	4685                	li	a3,1
    80004c3c:	8231                	srli	a2,a2,0xc
    80004c3e:	4581                	li	a1,0
    80004c40:	00000097          	auipc	ra,0x0
    80004c44:	ef0080e7          	jalr	-272(ra) # 80004b30 <uvmunmap>
    80004c48:	bfe1                	j	80004c20 <uvmfree+0xe>

0000000080004c4a <uvmcopy>:
  for(i = 0; i < sz; i += PGSIZE){
    80004c4a:	c265                	beqz	a2,80004d2a <uvmcopy+0xe0>
{
    80004c4c:	711d                	addi	sp,sp,-96
    80004c4e:	ec86                	sd	ra,88(sp)
    80004c50:	e8a2                	sd	s0,80(sp)
    80004c52:	e4a6                	sd	s1,72(sp)
    80004c54:	e0ca                	sd	s2,64(sp)
    80004c56:	fc4e                	sd	s3,56(sp)
    80004c58:	f852                	sd	s4,48(sp)
    80004c5a:	f456                	sd	s5,40(sp)
    80004c5c:	f05a                	sd	s6,32(sp)
    80004c5e:	ec5e                	sd	s7,24(sp)
    80004c60:	e862                	sd	s8,16(sp)
    80004c62:	e466                	sd	s9,8(sp)
    80004c64:	1080                	addi	s0,sp,96
    80004c66:	8aaa                	mv	s5,a0
    80004c68:	8a2e                	mv	s4,a1
    80004c6a:	89b2                	mv	s3,a2
  for(i = 0; i < sz; i += PGSIZE){
    80004c6c:	4901                	li	s2,0
      panic("uvmcopy: pte should exist");
    80004c6e:	00003b97          	auipc	s7,0x3
    80004c72:	eeab8b93          	addi	s7,s7,-278 # 80007b58 <syscalls+0x318>
      panic("uvmcopy: page not present");
    80004c76:	00003b17          	auipc	s6,0x3
    80004c7a:	f02b0b13          	addi	s6,s6,-254 # 80007b78 <syscalls+0x338>
    80004c7e:	a8a9                	j	80004cd8 <uvmcopy+0x8e>
      panic("uvmcopy: pte should exist");
    80004c80:	855e                	mv	a0,s7
    80004c82:	ffffc097          	auipc	ra,0xffffc
    80004c86:	802080e7          	jalr	-2046(ra) # 80000484 <panic>
    80004c8a:	a085                	j	80004cea <uvmcopy+0xa0>
      panic("uvmcopy: page not present");
    80004c8c:	855a                	mv	a0,s6
    80004c8e:	ffffb097          	auipc	ra,0xffffb
    80004c92:	7f6080e7          	jalr	2038(ra) # 80000484 <panic>
    pa = PTE2PA(*pte);
    80004c96:	6098                	ld	a4,0(s1)
    80004c98:	00a75593          	srli	a1,a4,0xa
    80004c9c:	00c59c93          	slli	s9,a1,0xc
    flags = PTE_FLAGS(*pte);
    80004ca0:	3ff77c13          	andi	s8,a4,1023
    if((mem = kalloc()) == 0){
    80004ca4:	00000097          	auipc	ra,0x0
    80004ca8:	92a080e7          	jalr	-1750(ra) # 800045ce <kalloc>
    80004cac:	84aa                	mv	s1,a0
    80004cae:	c539                	beqz	a0,80004cfc <uvmcopy+0xb2>
    memmove(mem, (char*)pa, PGSIZE);
    80004cb0:	6605                	lui	a2,0x1
    80004cb2:	85e6                	mv	a1,s9
    80004cb4:	ffffd097          	auipc	ra,0xffffd
    80004cb8:	2be080e7          	jalr	702(ra) # 80001f72 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80004cbc:	8762                	mv	a4,s8
    80004cbe:	86a6                	mv	a3,s1
    80004cc0:	6605                	lui	a2,0x1
    80004cc2:	85ca                	mv	a1,s2
    80004cc4:	8552                	mv	a0,s4
    80004cc6:	00000097          	auipc	ra,0x0
    80004cca:	a12080e7          	jalr	-1518(ra) # 800046d8 <mappages>
    80004cce:	e115                	bnez	a0,80004cf2 <uvmcopy+0xa8>
  for(i = 0; i < sz; i += PGSIZE){
    80004cd0:	6785                	lui	a5,0x1
    80004cd2:	993e                	add	s2,s2,a5
    80004cd4:	03397e63          	bgeu	s2,s3,80004d10 <uvmcopy+0xc6>
    if((pte = walk(old, i, 0)) == 0)
    80004cd8:	4601                	li	a2,0
    80004cda:	85ca                	mv	a1,s2
    80004cdc:	8556                	mv	a0,s5
    80004cde:	00000097          	auipc	ra,0x0
    80004ce2:	950080e7          	jalr	-1712(ra) # 8000462e <walk>
    80004ce6:	84aa                	mv	s1,a0
    80004ce8:	dd41                	beqz	a0,80004c80 <uvmcopy+0x36>
    if((*pte & PTE_V) == 0)
    80004cea:	609c                	ld	a5,0(s1)
    80004cec:	8b85                	andi	a5,a5,1
    80004cee:	f7c5                	bnez	a5,80004c96 <uvmcopy+0x4c>
    80004cf0:	bf71                	j	80004c8c <uvmcopy+0x42>
      kfree(mem);
    80004cf2:	8526                	mv	a0,s1
    80004cf4:	00000097          	auipc	ra,0x0
    80004cf8:	818080e7          	jalr	-2024(ra) # 8000450c <kfree>
  uvmunmap(new, 0, i / PGSIZE, 1);
    80004cfc:	4685                	li	a3,1
    80004cfe:	00c95613          	srli	a2,s2,0xc
    80004d02:	4581                	li	a1,0
    80004d04:	8552                	mv	a0,s4
    80004d06:	00000097          	auipc	ra,0x0
    80004d0a:	e2a080e7          	jalr	-470(ra) # 80004b30 <uvmunmap>
  return -1;
    80004d0e:	557d                	li	a0,-1
}
    80004d10:	60e6                	ld	ra,88(sp)
    80004d12:	6446                	ld	s0,80(sp)
    80004d14:	64a6                	ld	s1,72(sp)
    80004d16:	6906                	ld	s2,64(sp)
    80004d18:	79e2                	ld	s3,56(sp)
    80004d1a:	7a42                	ld	s4,48(sp)
    80004d1c:	7aa2                	ld	s5,40(sp)
    80004d1e:	7b02                	ld	s6,32(sp)
    80004d20:	6be2                	ld	s7,24(sp)
    80004d22:	6c42                	ld	s8,16(sp)
    80004d24:	6ca2                	ld	s9,8(sp)
    80004d26:	6125                	addi	sp,sp,96
    80004d28:	8082                	ret
  return 0;
    80004d2a:	4501                	li	a0,0
}
    80004d2c:	8082                	ret

0000000080004d2e <proc_freepagetable>:
{
    80004d2e:	1101                	addi	sp,sp,-32
    80004d30:	ec06                	sd	ra,24(sp)
    80004d32:	e822                	sd	s0,16(sp)
    80004d34:	e426                	sd	s1,8(sp)
    80004d36:	e04a                	sd	s2,0(sp)
    80004d38:	1000                	addi	s0,sp,32
    80004d3a:	84aa                	mv	s1,a0
    80004d3c:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80004d3e:	4681                	li	a3,0
    80004d40:	4605                	li	a2,1
    80004d42:	040005b7          	lui	a1,0x4000
    80004d46:	15fd                	addi	a1,a1,-1
    80004d48:	05b2                	slli	a1,a1,0xc
    80004d4a:	00000097          	auipc	ra,0x0
    80004d4e:	de6080e7          	jalr	-538(ra) # 80004b30 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80004d52:	4681                	li	a3,0
    80004d54:	4605                	li	a2,1
    80004d56:	020005b7          	lui	a1,0x2000
    80004d5a:	15fd                	addi	a1,a1,-1
    80004d5c:	05b6                	slli	a1,a1,0xd
    80004d5e:	8526                	mv	a0,s1
    80004d60:	00000097          	auipc	ra,0x0
    80004d64:	dd0080e7          	jalr	-560(ra) # 80004b30 <uvmunmap>
  uvmfree(pagetable, sz);
    80004d68:	85ca                	mv	a1,s2
    80004d6a:	8526                	mv	a0,s1
    80004d6c:	00000097          	auipc	ra,0x0
    80004d70:	ea6080e7          	jalr	-346(ra) # 80004c12 <uvmfree>
}
    80004d74:	60e2                	ld	ra,24(sp)
    80004d76:	6442                	ld	s0,16(sp)
    80004d78:	64a2                	ld	s1,8(sp)
    80004d7a:	6902                	ld	s2,0(sp)
    80004d7c:	6105                	addi	sp,sp,32
    80004d7e:	8082                	ret

0000000080004d80 <uvmdealloc>:



uint64 uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz){
    80004d80:	1101                	addi	sp,sp,-32
    80004d82:	ec06                	sd	ra,24(sp)
    80004d84:	e822                	sd	s0,16(sp)
    80004d86:	e426                	sd	s1,8(sp)
    80004d88:	1000                	addi	s0,sp,32
    if(newsz >= oldsz){
        return oldsz;
    80004d8a:	84ae                	mv	s1,a1
    if(newsz >= oldsz){
    80004d8c:	00b67d63          	bgeu	a2,a1,80004da6 <uvmdealloc+0x26>
    80004d90:	84b2                	mv	s1,a2
    }

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80004d92:	6785                	lui	a5,0x1
    80004d94:	17fd                	addi	a5,a5,-1
    80004d96:	00f60733          	add	a4,a2,a5
    80004d9a:	767d                	lui	a2,0xfffff
    80004d9c:	8f71                	and	a4,a4,a2
    80004d9e:	97ae                	add	a5,a5,a1
    80004da0:	8ff1                	and	a5,a5,a2
    80004da2:	00f76863          	bltu	a4,a5,80004db2 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }
  return newsz;
}
    80004da6:	8526                	mv	a0,s1
    80004da8:	60e2                	ld	ra,24(sp)
    80004daa:	6442                	ld	s0,16(sp)
    80004dac:	64a2                	ld	s1,8(sp)
    80004dae:	6105                	addi	sp,sp,32
    80004db0:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80004db2:	8f99                	sub	a5,a5,a4
    80004db4:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80004db6:	4685                	li	a3,1
    80004db8:	0007861b          	sext.w	a2,a5
    80004dbc:	85ba                	mv	a1,a4
    80004dbe:	00000097          	auipc	ra,0x0
    80004dc2:	d72080e7          	jalr	-654(ra) # 80004b30 <uvmunmap>
    80004dc6:	b7c5                	j	80004da6 <uvmdealloc+0x26>

0000000080004dc8 <uvmalloc>:
  if(newsz < oldsz)
    80004dc8:	0ab66163          	bltu	a2,a1,80004e6a <uvmalloc+0xa2>
uint64 uvmalloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz) {
    80004dcc:	7139                	addi	sp,sp,-64
    80004dce:	fc06                	sd	ra,56(sp)
    80004dd0:	f822                	sd	s0,48(sp)
    80004dd2:	f426                	sd	s1,40(sp)
    80004dd4:	f04a                	sd	s2,32(sp)
    80004dd6:	ec4e                	sd	s3,24(sp)
    80004dd8:	e852                	sd	s4,16(sp)
    80004dda:	e456                	sd	s5,8(sp)
    80004ddc:	0080                	addi	s0,sp,64
    80004dde:	8aaa                	mv	s5,a0
    80004de0:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80004de2:	6985                	lui	s3,0x1
    80004de4:	19fd                	addi	s3,s3,-1
    80004de6:	95ce                	add	a1,a1,s3
    80004de8:	79fd                	lui	s3,0xfffff
    80004dea:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80004dee:	08c9f063          	bgeu	s3,a2,80004e6e <uvmalloc+0xa6>
    80004df2:	894e                	mv	s2,s3
    mem = kalloc();
    80004df4:	fffff097          	auipc	ra,0xfffff
    80004df8:	7da080e7          	jalr	2010(ra) # 800045ce <kalloc>
    80004dfc:	84aa                	mv	s1,a0
    if(mem == 0){
    80004dfe:	c51d                	beqz	a0,80004e2c <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80004e00:	6605                	lui	a2,0x1
    80004e02:	4581                	li	a1,0
    80004e04:	ffffd097          	auipc	ra,0xffffd
    80004e08:	146080e7          	jalr	326(ra) # 80001f4a <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80004e0c:	4779                	li	a4,30
    80004e0e:	86a6                	mv	a3,s1
    80004e10:	6605                	lui	a2,0x1
    80004e12:	85ca                	mv	a1,s2
    80004e14:	8556                	mv	a0,s5
    80004e16:	00000097          	auipc	ra,0x0
    80004e1a:	8c2080e7          	jalr	-1854(ra) # 800046d8 <mappages>
    80004e1e:	e905                	bnez	a0,80004e4e <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80004e20:	6785                	lui	a5,0x1
    80004e22:	993e                	add	s2,s2,a5
    80004e24:	fd4968e3          	bltu	s2,s4,80004df4 <uvmalloc+0x2c>
  return newsz;
    80004e28:	8552                	mv	a0,s4
    80004e2a:	a809                	j	80004e3c <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80004e2c:	864e                	mv	a2,s3
    80004e2e:	85ca                	mv	a1,s2
    80004e30:	8556                	mv	a0,s5
    80004e32:	00000097          	auipc	ra,0x0
    80004e36:	f4e080e7          	jalr	-178(ra) # 80004d80 <uvmdealloc>
      return 0;
    80004e3a:	4501                	li	a0,0
}
    80004e3c:	70e2                	ld	ra,56(sp)
    80004e3e:	7442                	ld	s0,48(sp)
    80004e40:	74a2                	ld	s1,40(sp)
    80004e42:	7902                	ld	s2,32(sp)
    80004e44:	69e2                	ld	s3,24(sp)
    80004e46:	6a42                	ld	s4,16(sp)
    80004e48:	6aa2                	ld	s5,8(sp)
    80004e4a:	6121                	addi	sp,sp,64
    80004e4c:	8082                	ret
      kfree(mem);
    80004e4e:	8526                	mv	a0,s1
    80004e50:	fffff097          	auipc	ra,0xfffff
    80004e54:	6bc080e7          	jalr	1724(ra) # 8000450c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80004e58:	864e                	mv	a2,s3
    80004e5a:	85ca                	mv	a1,s2
    80004e5c:	8556                	mv	a0,s5
    80004e5e:	00000097          	auipc	ra,0x0
    80004e62:	f22080e7          	jalr	-222(ra) # 80004d80 <uvmdealloc>
      return 0;
    80004e66:	4501                	li	a0,0
    80004e68:	bfd1                	j	80004e3c <uvmalloc+0x74>
    return oldsz;
    80004e6a:	852e                	mv	a0,a1
}
    80004e6c:	8082                	ret
  return newsz;
    80004e6e:	8532                	mv	a0,a2
    80004e70:	b7f1                	j	80004e3c <uvmalloc+0x74>

0000000080004e72 <uvminit>:

void uvminit(pagetable_t pagetable,uchar* src,uint sz){
    80004e72:	7179                	addi	sp,sp,-48
    80004e74:	f406                	sd	ra,40(sp)
    80004e76:	f022                	sd	s0,32(sp)
    80004e78:	ec26                	sd	s1,24(sp)
    80004e7a:	e84a                	sd	s2,16(sp)
    80004e7c:	e44e                	sd	s3,8(sp)
    80004e7e:	e052                	sd	s4,0(sp)
    80004e80:	1800                	addi	s0,sp,48
    80004e82:	8a2a                	mv	s4,a0
    80004e84:	89ae                	mv	s3,a1
    80004e86:	8932                	mv	s2,a2
    char *mem;
    if(sz > PGSIZE){
    80004e88:	6785                	lui	a5,0x1
    80004e8a:	04c7e563          	bltu	a5,a2,80004ed4 <uvminit+0x62>
        panic("inituvm: more than a page");
    }    
    mem = kalloc();
    80004e8e:	fffff097          	auipc	ra,0xfffff
    80004e92:	740080e7          	jalr	1856(ra) # 800045ce <kalloc>
    80004e96:	84aa                	mv	s1,a0
    memset(mem,0,PGSIZE);
    80004e98:	6605                	lui	a2,0x1
    80004e9a:	4581                	li	a1,0
    80004e9c:	ffffd097          	auipc	ra,0xffffd
    80004ea0:	0ae080e7          	jalr	174(ra) # 80001f4a <memset>
    mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80004ea4:	4779                	li	a4,30
    80004ea6:	86a6                	mv	a3,s1
    80004ea8:	6605                	lui	a2,0x1
    80004eaa:	4581                	li	a1,0
    80004eac:	8552                	mv	a0,s4
    80004eae:	00000097          	auipc	ra,0x0
    80004eb2:	82a080e7          	jalr	-2006(ra) # 800046d8 <mappages>
    memmove(mem, src, sz);
    80004eb6:	864a                	mv	a2,s2
    80004eb8:	85ce                	mv	a1,s3
    80004eba:	8526                	mv	a0,s1
    80004ebc:	ffffd097          	auipc	ra,0xffffd
    80004ec0:	0b6080e7          	jalr	182(ra) # 80001f72 <memmove>
}
    80004ec4:	70a2                	ld	ra,40(sp)
    80004ec6:	7402                	ld	s0,32(sp)
    80004ec8:	64e2                	ld	s1,24(sp)
    80004eca:	6942                	ld	s2,16(sp)
    80004ecc:	69a2                	ld	s3,8(sp)
    80004ece:	6a02                	ld	s4,0(sp)
    80004ed0:	6145                	addi	sp,sp,48
    80004ed2:	8082                	ret
        panic("inituvm: more than a page");
    80004ed4:	00003517          	auipc	a0,0x3
    80004ed8:	cc450513          	addi	a0,a0,-828 # 80007b98 <syscalls+0x358>
    80004edc:	ffffb097          	auipc	ra,0xffffb
    80004ee0:	5a8080e7          	jalr	1448(ra) # 80000484 <panic>
    80004ee4:	b76d                	j	80004e8e <uvminit+0x1c>

0000000080004ee6 <uvmcreate>:

pagetable_t uvmcreate(){
    80004ee6:	1101                	addi	sp,sp,-32
    80004ee8:	ec06                	sd	ra,24(sp)
    80004eea:	e822                	sd	s0,16(sp)
    80004eec:	e426                	sd	s1,8(sp)
    80004eee:	1000                	addi	s0,sp,32
    pagetable_t pagetable;
    pagetable = (pagetable_t) kalloc();
    80004ef0:	fffff097          	auipc	ra,0xfffff
    80004ef4:	6de080e7          	jalr	1758(ra) # 800045ce <kalloc>
    80004ef8:	84aa                	mv	s1,a0

    if(pagetable == 0){ 
    80004efa:	cd11                	beqz	a0,80004f16 <uvmcreate+0x30>
        panic("uvmcreate kalloc panic..\n");
    }    
    memset(pagetable,0,PGSIZE);
    80004efc:	6605                	lui	a2,0x1
    80004efe:	4581                	li	a1,0
    80004f00:	8526                	mv	a0,s1
    80004f02:	ffffd097          	auipc	ra,0xffffd
    80004f06:	048080e7          	jalr	72(ra) # 80001f4a <memset>
    return pagetable;
}
    80004f0a:	8526                	mv	a0,s1
    80004f0c:	60e2                	ld	ra,24(sp)
    80004f0e:	6442                	ld	s0,16(sp)
    80004f10:	64a2                	ld	s1,8(sp)
    80004f12:	6105                	addi	sp,sp,32
    80004f14:	8082                	ret
        panic("uvmcreate kalloc panic..\n");
    80004f16:	00003517          	auipc	a0,0x3
    80004f1a:	ca250513          	addi	a0,a0,-862 # 80007bb8 <syscalls+0x378>
    80004f1e:	ffffb097          	auipc	ra,0xffffb
    80004f22:	566080e7          	jalr	1382(ra) # 80000484 <panic>
    80004f26:	bfd9                	j	80004efc <uvmcreate+0x16>

0000000080004f28 <copyin>:

int copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len) {
  uint64 n, va0, pa0;
  while(len > 0){
    80004f28:	cec9                	beqz	a3,80004fc2 <copyin+0x9a>
int copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len) {
    80004f2a:	715d                	addi	sp,sp,-80
    80004f2c:	e486                	sd	ra,72(sp)
    80004f2e:	e0a2                	sd	s0,64(sp)
    80004f30:	fc26                	sd	s1,56(sp)
    80004f32:	f84a                	sd	s2,48(sp)
    80004f34:	f44e                	sd	s3,40(sp)
    80004f36:	f052                	sd	s4,32(sp)
    80004f38:	ec56                	sd	s5,24(sp)
    80004f3a:	e85a                	sd	s6,16(sp)
    80004f3c:	e45e                	sd	s7,8(sp)
    80004f3e:	e062                	sd	s8,0(sp)
    80004f40:	0880                	addi	s0,sp,80
    80004f42:	8b2a                	mv	s6,a0
    80004f44:	8a2e                	mv	s4,a1
    80004f46:	8c32                	mv	s8,a2
    80004f48:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80004f4a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0){
      panic("copyin:pa0 == 0\n");
      return -1;
    }
    n = PGSIZE - (srcva + va0);
    80004f4c:	6a85                	lui	s5,0x1
    80004f4e:	a0b9                	j	80004f9c <copyin+0x74>
      panic("copyin:pa0 == 0\n");
    80004f50:	00003517          	auipc	a0,0x3
    80004f54:	c8850513          	addi	a0,a0,-888 # 80007bd8 <syscalls+0x398>
    80004f58:	ffffb097          	auipc	ra,0xffffb
    80004f5c:	52c080e7          	jalr	1324(ra) # 80000484 <panic>
      return -1;
    80004f60:	557d                	li	a0,-1
    len -= n;
    dst += n;
    srcva = va0 + PGSIZE;
  }
  return 0;
}
    80004f62:	60a6                	ld	ra,72(sp)
    80004f64:	6406                	ld	s0,64(sp)
    80004f66:	74e2                	ld	s1,56(sp)
    80004f68:	7942                	ld	s2,48(sp)
    80004f6a:	79a2                	ld	s3,40(sp)
    80004f6c:	7a02                	ld	s4,32(sp)
    80004f6e:	6ae2                	ld	s5,24(sp)
    80004f70:	6b42                	ld	s6,16(sp)
    80004f72:	6ba2                	ld	s7,8(sp)
    80004f74:	6c02                	ld	s8,0(sp)
    80004f76:	6161                	addi	sp,sp,80
    80004f78:	8082                	ret
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80004f7a:	9562                	add	a0,a0,s8
    80004f7c:	0004861b          	sext.w	a2,s1
    80004f80:	412505b3          	sub	a1,a0,s2
    80004f84:	8552                	mv	a0,s4
    80004f86:	ffffd097          	auipc	ra,0xffffd
    80004f8a:	fec080e7          	jalr	-20(ra) # 80001f72 <memmove>
    len -= n;
    80004f8e:	409989b3          	sub	s3,s3,s1
    dst += n;
    80004f92:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80004f94:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80004f98:	02098363          	beqz	s3,80004fbe <copyin+0x96>
    va0 = PGROUNDDOWN(srcva);
    80004f9c:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80004fa0:	85ca                	mv	a1,s2
    80004fa2:	855a                	mv	a0,s6
    80004fa4:	00000097          	auipc	ra,0x0
    80004fa8:	aa4080e7          	jalr	-1372(ra) # 80004a48 <walkaddr>
    if(pa0 == 0){
    80004fac:	d155                	beqz	a0,80004f50 <copyin+0x28>
    n = PGSIZE - (srcva + va0);
    80004fae:	418a84b3          	sub	s1,s5,s8
    80004fb2:	412484b3          	sub	s1,s1,s2
    if(n > len)
    80004fb6:	fc99f2e3          	bgeu	s3,s1,80004f7a <copyin+0x52>
    80004fba:	84ce                	mv	s1,s3
    80004fbc:	bf7d                	j	80004f7a <copyin+0x52>
  return 0;
    80004fbe:	4501                	li	a0,0
    80004fc0:	b74d                	j	80004f62 <copyin+0x3a>
    80004fc2:	4501                	li	a0,0
}
    80004fc4:	8082                	ret

0000000080004fc6 <copyinstr>:

int copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max) {
    80004fc6:	715d                	addi	sp,sp,-80
    80004fc8:	e486                	sd	ra,72(sp)
    80004fca:	e0a2                	sd	s0,64(sp)
    80004fcc:	fc26                	sd	s1,56(sp)
    80004fce:	f84a                	sd	s2,48(sp)
    80004fd0:	f44e                	sd	s3,40(sp)
    80004fd2:	f052                	sd	s4,32(sp)
    80004fd4:	ec56                	sd	s5,24(sp)
    80004fd6:	e85a                	sd	s6,16(sp)
    80004fd8:	e45e                	sd	s7,8(sp)
    80004fda:	0880                	addi	s0,sp,80
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80004fdc:	c2d9                	beqz	a3,80005062 <copyinstr+0x9c>
    80004fde:	8a2a                	mv	s4,a0
    80004fe0:	8b2e                	mv	s6,a1
    80004fe2:	8bb2                	mv	s7,a2
    80004fe4:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80004fe6:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0){
      return -1;
    }
    n = PGSIZE - (srcva - va0);
    80004fe8:	6985                	lui	s3,0x1
    80004fea:	a015                	j	8000500e <copyinstr+0x48>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80004fec:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    return 0;
    80004ff0:	4501                	li	a0,0
  } else {
    printf("got_null = 1\n");
    return -1;
  }
}
    80004ff2:	60a6                	ld	ra,72(sp)
    80004ff4:	6406                	ld	s0,64(sp)
    80004ff6:	74e2                	ld	s1,56(sp)
    80004ff8:	7942                	ld	s2,48(sp)
    80004ffa:	79a2                	ld	s3,40(sp)
    80004ffc:	7a02                	ld	s4,32(sp)
    80004ffe:	6ae2                	ld	s5,24(sp)
    80005000:	6b42                	ld	s6,16(sp)
    80005002:	6ba2                	ld	s7,8(sp)
    80005004:	6161                	addi	sp,sp,80
    80005006:	8082                	ret
    srcva = va0 + PGSIZE;
    80005008:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    8000500c:	c8b9                	beqz	s1,80005062 <copyinstr+0x9c>
    va0 = PGROUNDDOWN(srcva);
    8000500e:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80005012:	85ca                	mv	a1,s2
    80005014:	8552                	mv	a0,s4
    80005016:	00000097          	auipc	ra,0x0
    8000501a:	a32080e7          	jalr	-1486(ra) # 80004a48 <walkaddr>
    if(pa0 == 0){
    8000501e:	c121                	beqz	a0,8000505e <copyinstr+0x98>
    n = PGSIZE - (srcva - va0);
    80005020:	41790833          	sub	a6,s2,s7
    80005024:	984e                	add	a6,a6,s3
    if(n > max)
    80005026:	0104f363          	bgeu	s1,a6,8000502c <copyinstr+0x66>
    8000502a:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    8000502c:	955e                	add	a0,a0,s7
    8000502e:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80005032:	fc080be3          	beqz	a6,80005008 <copyinstr+0x42>
    80005036:	985a                	add	a6,a6,s6
    80005038:	87da                	mv	a5,s6
      if(*p == '\0'){
    8000503a:	41650633          	sub	a2,a0,s6
    8000503e:	14fd                	addi	s1,s1,-1
    80005040:	9b26                	add	s6,s6,s1
    80005042:	00f60733          	add	a4,a2,a5
    80005046:	00074703          	lbu	a4,0(a4)
    8000504a:	d34d                	beqz	a4,80004fec <copyinstr+0x26>
        *dst = *p;
    8000504c:	00e78023          	sb	a4,0(a5)
      --max;
    80005050:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80005054:	0785                	addi	a5,a5,1
    while(n > 0){
    80005056:	ff0796e3          	bne	a5,a6,80005042 <copyinstr+0x7c>
      dst++;
    8000505a:	8b42                	mv	s6,a6
    8000505c:	b775                	j	80005008 <copyinstr+0x42>
      return -1;
    8000505e:	557d                	li	a0,-1
    80005060:	bf49                	j	80004ff2 <copyinstr+0x2c>
    printf("got_null = 1\n");
    80005062:	00003517          	auipc	a0,0x3
    80005066:	b8e50513          	addi	a0,a0,-1138 # 80007bf0 <syscalls+0x3b0>
    8000506a:	ffffb097          	auipc	ra,0xffffb
    8000506e:	250080e7          	jalr	592(ra) # 800002ba <printf>
    return -1;
    80005072:	557d                	li	a0,-1
    80005074:	bfbd                	j	80004ff2 <copyinstr+0x2c>
	...

0000000080006000 <_trampoline>:
    80006000:	14051573          	csrrw	a0,sscratch,a0
    80006004:	02153423          	sd	ra,40(a0)
    80006008:	02253823          	sd	sp,48(a0)
    8000600c:	02353c23          	sd	gp,56(a0)
    80006010:	04453023          	sd	tp,64(a0)
    80006014:	04553423          	sd	t0,72(a0)
    80006018:	04653823          	sd	t1,80(a0)
    8000601c:	04753c23          	sd	t2,88(a0)
    80006020:	f120                	sd	s0,96(a0)
    80006022:	f524                	sd	s1,104(a0)
    80006024:	fd2c                	sd	a1,120(a0)
    80006026:	e150                	sd	a2,128(a0)
    80006028:	e554                	sd	a3,136(a0)
    8000602a:	e958                	sd	a4,144(a0)
    8000602c:	ed5c                	sd	a5,152(a0)
    8000602e:	0b053023          	sd	a6,160(a0)
    80006032:	0b153423          	sd	a7,168(a0)
    80006036:	0b253823          	sd	s2,176(a0)
    8000603a:	0b353c23          	sd	s3,184(a0)
    8000603e:	0d453023          	sd	s4,192(a0)
    80006042:	0d553423          	sd	s5,200(a0)
    80006046:	0d653823          	sd	s6,208(a0)
    8000604a:	0d753c23          	sd	s7,216(a0)
    8000604e:	0f853023          	sd	s8,224(a0)
    80006052:	0f953423          	sd	s9,232(a0)
    80006056:	0fa53823          	sd	s10,240(a0)
    8000605a:	0fb53c23          	sd	s11,248(a0)
    8000605e:	11c53023          	sd	t3,256(a0)
    80006062:	11d53423          	sd	t4,264(a0)
    80006066:	11e53823          	sd	t5,272(a0)
    8000606a:	11f53c23          	sd	t6,280(a0)
    8000606e:	140022f3          	csrr	t0,sscratch
    80006072:	06553823          	sd	t0,112(a0)
    80006076:	00853103          	ld	sp,8(a0)
    8000607a:	02053203          	ld	tp,32(a0)
    8000607e:	01053283          	ld	t0,16(a0)
    80006082:	00053303          	ld	t1,0(a0)
    80006086:	18031073          	csrw	satp,t1
    8000608a:	12000073          	sfence.vma
    8000608e:	8282                	jr	t0

0000000080006090 <userret>:
    80006090:	18059073          	csrw	satp,a1
    80006094:	12000073          	sfence.vma
    80006098:	07053283          	ld	t0,112(a0)
    8000609c:	14029073          	csrw	sscratch,t0
    800060a0:	02853083          	ld	ra,40(a0)
    800060a4:	03053103          	ld	sp,48(a0)
    800060a8:	03853183          	ld	gp,56(a0)
    800060ac:	04053203          	ld	tp,64(a0)
    800060b0:	04853283          	ld	t0,72(a0)
    800060b4:	05053303          	ld	t1,80(a0)
    800060b8:	05853383          	ld	t2,88(a0)
    800060bc:	7120                	ld	s0,96(a0)
    800060be:	7524                	ld	s1,104(a0)
    800060c0:	7d2c                	ld	a1,120(a0)
    800060c2:	6150                	ld	a2,128(a0)
    800060c4:	6554                	ld	a3,136(a0)
    800060c6:	6958                	ld	a4,144(a0)
    800060c8:	6d5c                	ld	a5,152(a0)
    800060ca:	0a053803          	ld	a6,160(a0)
    800060ce:	0a853883          	ld	a7,168(a0)
    800060d2:	0b053903          	ld	s2,176(a0)
    800060d6:	0b853983          	ld	s3,184(a0)
    800060da:	0c053a03          	ld	s4,192(a0)
    800060de:	0c853a83          	ld	s5,200(a0)
    800060e2:	0d053b03          	ld	s6,208(a0)
    800060e6:	0d853b83          	ld	s7,216(a0)
    800060ea:	0e053c03          	ld	s8,224(a0)
    800060ee:	0e853c83          	ld	s9,232(a0)
    800060f2:	0f053d03          	ld	s10,240(a0)
    800060f6:	0f853d83          	ld	s11,248(a0)
    800060fa:	10053e03          	ld	t3,256(a0)
    800060fe:	10853e83          	ld	t4,264(a0)
    80006102:	11053f03          	ld	t5,272(a0)
    80006106:	11853f83          	ld	t6,280(a0)
    8000610a:	14051573          	csrrw	a0,sscratch,a0
    8000610e:	10200073          	sret
	...
