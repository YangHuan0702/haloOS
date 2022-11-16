
src/user/_ls:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "src/kernel/stat.h"
#include "src/kernel/fcntl.h"
#include "src/user/users.h"


int main(int argc,char *args[]){
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
    printf("Hello ls\n");
   8:	00000517          	auipc	a0,0x0
   c:	25050513          	addi	a0,a0,592 # 258 <printf+0x1b4>
  10:	00000097          	auipc	ra,0x0
  14:	094080e7          	jalr	148(ra) # a4 <printf>
    return 0;
  18:	4501                	li	a0,0
  1a:	60a2                	ld	ra,8(sp)
  1c:	6402                	ld	s0,0(sp)
  1e:	0141                	addi	sp,sp,16
  20:	8082                	ret

0000000000000022 <write>:
  22:	4885                	li	a7,1
  24:	00000073          	ecall
  28:	8082                	ret

000000000000002a <open>:
  2a:	4891                	li	a7,4
  2c:	00000073          	ecall
  30:	8082                	ret

0000000000000032 <dup>:
  32:	488d                	li	a7,3
  34:	00000073          	ecall
  38:	8082                	ret

000000000000003a <exec>:
  3a:	4889                	li	a7,2
  3c:	00000073          	ecall
  40:	8082                	ret

0000000000000042 <wait>:
  42:	4895                	li	a7,5
  44:	00000073          	ecall
  48:	8082                	ret

000000000000004a <mknod>:
  4a:	4899                	li	a7,6
  4c:	00000073          	ecall
  50:	8082                	ret

0000000000000052 <fork>:
  52:	48a1                	li	a7,8
  54:	00000073          	ecall
  58:	8082                	ret

000000000000005a <read>:
  5a:	48a5                	li	a7,9
  5c:	00000073          	ecall
  60:	8082                	ret

0000000000000062 <exit>:
  62:	48a9                	li	a7,10
  64:	00000073          	ecall
  68:	8082                	ret

000000000000006a <sbrk>:
  6a:	48ad                	li	a7,11
  6c:	00000073          	ecall
  70:	8082                	ret

0000000000000072 <fstat>:
  72:	48b1                	li	a7,12
  74:	00000073          	ecall
  78:	8082                	ret

000000000000007a <close>:
  7a:	48b5                	li	a7,13
  7c:	00000073          	ecall
  80:	8082                	ret

0000000000000082 <putc>:

#include <stdarg.h>

static char nums[] = "0123456789abcdef";

void putc(int fd, char c) { 
  82:	1101                	addi	sp,sp,-32
  84:	ec06                	sd	ra,24(sp)
  86:	e822                	sd	s0,16(sp)
  88:	1000                	addi	s0,sp,32
  8a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1); 
  8e:	4605                	li	a2,1
  90:	fef40593          	addi	a1,s0,-17
  94:	00000097          	auipc	ra,0x0
  98:	f8e080e7          	jalr	-114(ra) # 22 <write>
}
  9c:	60e2                	ld	ra,24(sp)
  9e:	6442                	ld	s0,16(sp)
  a0:	6105                	addi	sp,sp,32
  a2:	8082                	ret

00000000000000a4 <printf>:
    for(i = 0; i < (sizeof(uint64) * 2); i++,ptr <<= 4){
        putc(fd,nums[ptr >> (sizeof(uint64) * 8 - 4)]);
    }
}

void printf(const char *s,...){
  a4:	7131                	addi	sp,sp,-192
  a6:	fc86                	sd	ra,120(sp)
  a8:	f8a2                	sd	s0,112(sp)
  aa:	f4a6                	sd	s1,104(sp)
  ac:	f0ca                	sd	s2,96(sp)
  ae:	ecce                	sd	s3,88(sp)
  b0:	e8d2                	sd	s4,80(sp)
  b2:	e4d6                	sd	s5,72(sp)
  b4:	e0da                	sd	s6,64(sp)
  b6:	fc5e                	sd	s7,56(sp)
  b8:	f862                	sd	s8,48(sp)
  ba:	f466                	sd	s9,40(sp)
  bc:	f06a                	sd	s10,32(sp)
  be:	0100                	addi	s0,sp,128
  c0:	e40c                	sd	a1,8(s0)
  c2:	e810                	sd	a2,16(s0)
  c4:	ec14                	sd	a3,24(s0)
  c6:	f018                	sd	a4,32(s0)
  c8:	f41c                	sd	a5,40(s0)
  ca:	03043823          	sd	a6,48(s0)
  ce:	03143c23          	sd	a7,56(s0)
     if(s == 0){
  d2:	16050263          	beqz	a0,236 <printf+0x192>
  d6:	89aa                	mv	s3,a0
        return;
    }
    va_list ap;
    va_start(ap,s);
  d8:	00840793          	addi	a5,s0,8
  dc:	f8f43c23          	sd	a5,-104(s0)
    char *str;
    for(int i = 0; s[i] != 0; i++){
  e0:	00054583          	lbu	a1,0(a0)
  e4:	14058963          	beqz	a1,236 <printf+0x192>
  e8:	4481                	li	s1,0
        char c = s[i];
        if(c != '%'){
  ea:	02500a93          	li	s5,37
        char next = s[++i];
        if(next == 0){
            putc(1,c);
            continue;
        }
        switch (next) {
  ee:	07000c13          	li	s8,112
    putc(fd,'x');
  f2:	4cc1                	li	s9,16
        putc(fd,nums[ptr >> (sizeof(uint64) * 8 - 4)]);
  f4:	00000a17          	auipc	s4,0x0
  f8:	174a0a13          	addi	s4,s4,372 # 268 <nums>
        switch (next) {
  fc:	07300b93          	li	s7,115
 100:	06400b13          	li	s6,100
 104:	a829                	j	11e <printf+0x7a>
            putc(1,c);
 106:	4505                	li	a0,1
 108:	00000097          	auipc	ra,0x0
 10c:	f7a080e7          	jalr	-134(ra) # 82 <putc>
    for(int i = 0; s[i] != 0; i++){
 110:	2485                	addiw	s1,s1,1
 112:	009987b3          	add	a5,s3,s1
 116:	0007c583          	lbu	a1,0(a5)
 11a:	10058e63          	beqz	a1,236 <printf+0x192>
        if(c != '%'){
 11e:	ff5594e3          	bne	a1,s5,106 <printf+0x62>
        char next = s[++i];
 122:	2485                	addiw	s1,s1,1
 124:	009987b3          	add	a5,s3,s1
 128:	0007c583          	lbu	a1,0(a5)
        if(next == 0){
 12c:	cd89                	beqz	a1,146 <printf+0xa2>
        switch (next) {
 12e:	0b858e63          	beq	a1,s8,1ea <printf+0x146>
 132:	09758563          	beq	a1,s7,1bc <printf+0x118>
 136:	01658f63          	beq	a1,s6,154 <printf+0xb0>
        break;
        case 'p':
            printPtr(1,va_arg(ap,uint64));
        break;
        default:
            putc(1,next);
 13a:	4505                	li	a0,1
 13c:	00000097          	auipc	ra,0x0
 140:	f46080e7          	jalr	-186(ra) # 82 <putc>
            break;
 144:	b7f1                	j	110 <printf+0x6c>
            putc(1,c);
 146:	85d6                	mv	a1,s5
 148:	4505                	li	a0,1
 14a:	00000097          	auipc	ra,0x0
 14e:	f38080e7          	jalr	-200(ra) # 82 <putc>
            continue;
 152:	bf7d                	j	110 <printf+0x6c>
            printInt(va_arg(ap,int),1);
 154:	f9843783          	ld	a5,-104(s0)
 158:	00878713          	addi	a4,a5,8
 15c:	f8e43c23          	sd	a4,-104(s0)
 160:	439c                	lw	a5,0(a5)
 162:	f8840613          	addi	a2,s0,-120
    int i = 0;
 166:	4681                	li	a3,0
        buf[i++] = nums[val % 10];
 168:	45a9                	li	a1,10
    } while ((val /= 10) > 0);
 16a:	4825                	li	a6,9
        buf[i++] = nums[val % 10];
 16c:	8536                	mv	a0,a3
 16e:	2685                	addiw	a3,a3,1
 170:	02b7e73b          	remw	a4,a5,a1
 174:	9752                	add	a4,a4,s4
 176:	00074703          	lbu	a4,0(a4)
 17a:	00e60023          	sb	a4,0(a2)
    } while ((val /= 10) > 0);
 17e:	873e                	mv	a4,a5
 180:	02b7c7bb          	divw	a5,a5,a1
 184:	0605                	addi	a2,a2,1
 186:	fee843e3          	blt	a6,a4,16c <printf+0xc8>
    for(i-=1;i >= 0; i--){
 18a:	f80543e3          	bltz	a0,110 <printf+0x6c>
 18e:	f8840793          	addi	a5,s0,-120
 192:	00a78933          	add	s2,a5,a0
 196:	f8740793          	addi	a5,s0,-121
 19a:	00a78d33          	add	s10,a5,a0
 19e:	1502                	slli	a0,a0,0x20
 1a0:	9101                	srli	a0,a0,0x20
 1a2:	40ad0d33          	sub	s10,s10,a0
        putc(1,buf[i]);
 1a6:	00094583          	lbu	a1,0(s2)
 1aa:	4505                	li	a0,1
 1ac:	00000097          	auipc	ra,0x0
 1b0:	ed6080e7          	jalr	-298(ra) # 82 <putc>
    for(i-=1;i >= 0; i--){
 1b4:	197d                	addi	s2,s2,-1
 1b6:	ff2d18e3          	bne	s10,s2,1a6 <printf+0x102>
 1ba:	bf99                	j	110 <printf+0x6c>
            str = va_arg(ap,char*);
 1bc:	f9843783          	ld	a5,-104(s0)
 1c0:	00878713          	addi	a4,a5,8
 1c4:	f8e43c23          	sd	a4,-104(s0)
 1c8:	0007b903          	ld	s2,0(a5)
            if(str){
 1cc:	f40902e3          	beqz	s2,110 <printf+0x6c>
    while (*s) {
 1d0:	00094583          	lbu	a1,0(s2)
 1d4:	dd95                	beqz	a1,110 <printf+0x6c>
        putc(1,*(s++));
 1d6:	0905                	addi	s2,s2,1
 1d8:	4505                	li	a0,1
 1da:	00000097          	auipc	ra,0x0
 1de:	ea8080e7          	jalr	-344(ra) # 82 <putc>
    while (*s) {
 1e2:	00094583          	lbu	a1,0(s2)
 1e6:	f9e5                	bnez	a1,1d6 <printf+0x132>
 1e8:	b725                	j	110 <printf+0x6c>
            printPtr(1,va_arg(ap,uint64));
 1ea:	f9843783          	ld	a5,-104(s0)
 1ee:	00878713          	addi	a4,a5,8
 1f2:	f8e43c23          	sd	a4,-104(s0)
 1f6:	0007bd03          	ld	s10,0(a5)
    putc(fd,'0');
 1fa:	03000593          	li	a1,48
 1fe:	4505                	li	a0,1
 200:	00000097          	auipc	ra,0x0
 204:	e82080e7          	jalr	-382(ra) # 82 <putc>
    putc(fd,'x');
 208:	07800593          	li	a1,120
 20c:	4505                	li	a0,1
 20e:	00000097          	auipc	ra,0x0
 212:	e74080e7          	jalr	-396(ra) # 82 <putc>
 216:	8966                	mv	s2,s9
        putc(fd,nums[ptr >> (sizeof(uint64) * 8 - 4)]);
 218:	03cd5793          	srli	a5,s10,0x3c
 21c:	97d2                	add	a5,a5,s4
 21e:	0007c583          	lbu	a1,0(a5)
 222:	4505                	li	a0,1
 224:	00000097          	auipc	ra,0x0
 228:	e5e080e7          	jalr	-418(ra) # 82 <putc>
    for(i = 0; i < (sizeof(uint64) * 2); i++,ptr <<= 4){
 22c:	0d12                	slli	s10,s10,0x4
 22e:	397d                	addiw	s2,s2,-1
 230:	fe0914e3          	bnez	s2,218 <printf+0x174>
 234:	bdf1                	j	110 <printf+0x6c>
        }
    }
}
 236:	70e6                	ld	ra,120(sp)
 238:	7446                	ld	s0,112(sp)
 23a:	74a6                	ld	s1,104(sp)
 23c:	7906                	ld	s2,96(sp)
 23e:	69e6                	ld	s3,88(sp)
 240:	6a46                	ld	s4,80(sp)
 242:	6aa6                	ld	s5,72(sp)
 244:	6b06                	ld	s6,64(sp)
 246:	7be2                	ld	s7,56(sp)
 248:	7c42                	ld	s8,48(sp)
 24a:	7ca2                	ld	s9,40(sp)
 24c:	7d02                	ld	s10,32(sp)
 24e:	6129                	addi	sp,sp,192
 250:	8082                	ret
