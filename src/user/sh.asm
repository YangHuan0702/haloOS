
src/user/_sh:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
//     }
//     buf[i+1] = '\0';
//     return 0;
// }

int main(){
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
    printf("$ ");
   8:	00000517          	auipc	a0,0x0
   c:	24850513          	addi	a0,a0,584 # 250 <printf+0x1b4>
  10:	00000097          	auipc	ra,0x0
  14:	08c080e7          	jalr	140(ra) # 9c <printf>
    for(;;){
  18:	a001                	j	18 <main+0x18>

000000000000001a <write>:
  1a:	4885                	li	a7,1
  1c:	00000073          	ecall
  20:	8082                	ret

0000000000000022 <open>:
  22:	4891                	li	a7,4
  24:	00000073          	ecall
  28:	8082                	ret

000000000000002a <dup>:
  2a:	488d                	li	a7,3
  2c:	00000073          	ecall
  30:	8082                	ret

0000000000000032 <exec>:
  32:	4889                	li	a7,2
  34:	00000073          	ecall
  38:	8082                	ret

000000000000003a <wait>:
  3a:	4895                	li	a7,5
  3c:	00000073          	ecall
  40:	8082                	ret

0000000000000042 <mknod>:
  42:	4899                	li	a7,6
  44:	00000073          	ecall
  48:	8082                	ret

000000000000004a <fork>:
  4a:	48a1                	li	a7,8
  4c:	00000073          	ecall
  50:	8082                	ret

0000000000000052 <read>:
  52:	48a5                	li	a7,9
  54:	00000073          	ecall
  58:	8082                	ret

000000000000005a <exit>:
  5a:	48a9                	li	a7,10
  5c:	00000073          	ecall
  60:	8082                	ret

0000000000000062 <sbrk>:
  62:	48ad                	li	a7,11
  64:	00000073          	ecall
  68:	8082                	ret

000000000000006a <fstat>:
  6a:	48b1                	li	a7,12
  6c:	00000073          	ecall
  70:	8082                	ret

0000000000000072 <close>:
  72:	48b5                	li	a7,13
  74:	00000073          	ecall
  78:	8082                	ret

000000000000007a <putc>:

#include <stdarg.h>

static char nums[] = "0123456789abcdef";

void putc(int fd, char c) { 
  7a:	1101                	addi	sp,sp,-32
  7c:	ec06                	sd	ra,24(sp)
  7e:	e822                	sd	s0,16(sp)
  80:	1000                	addi	s0,sp,32
  82:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1); 
  86:	4605                	li	a2,1
  88:	fef40593          	addi	a1,s0,-17
  8c:	00000097          	auipc	ra,0x0
  90:	f8e080e7          	jalr	-114(ra) # 1a <write>
}
  94:	60e2                	ld	ra,24(sp)
  96:	6442                	ld	s0,16(sp)
  98:	6105                	addi	sp,sp,32
  9a:	8082                	ret

000000000000009c <printf>:
    for(i = 0; i < (sizeof(uint64) * 2); i++,ptr <<= 4){
        putc(fd,nums[ptr >> (sizeof(uint64) * 8 - 4)]);
    }
}

void printf(const char *s,...){
  9c:	7131                	addi	sp,sp,-192
  9e:	fc86                	sd	ra,120(sp)
  a0:	f8a2                	sd	s0,112(sp)
  a2:	f4a6                	sd	s1,104(sp)
  a4:	f0ca                	sd	s2,96(sp)
  a6:	ecce                	sd	s3,88(sp)
  a8:	e8d2                	sd	s4,80(sp)
  aa:	e4d6                	sd	s5,72(sp)
  ac:	e0da                	sd	s6,64(sp)
  ae:	fc5e                	sd	s7,56(sp)
  b0:	f862                	sd	s8,48(sp)
  b2:	f466                	sd	s9,40(sp)
  b4:	f06a                	sd	s10,32(sp)
  b6:	0100                	addi	s0,sp,128
  b8:	e40c                	sd	a1,8(s0)
  ba:	e810                	sd	a2,16(s0)
  bc:	ec14                	sd	a3,24(s0)
  be:	f018                	sd	a4,32(s0)
  c0:	f41c                	sd	a5,40(s0)
  c2:	03043823          	sd	a6,48(s0)
  c6:	03143c23          	sd	a7,56(s0)
     if(s == 0){
  ca:	16050263          	beqz	a0,22e <printf+0x192>
  ce:	89aa                	mv	s3,a0
        return;
    }
    va_list ap;
    va_start(ap,s);
  d0:	00840793          	addi	a5,s0,8
  d4:	f8f43c23          	sd	a5,-104(s0)
    char *str;
    for(int i = 0; s[i] != 0; i++){
  d8:	00054583          	lbu	a1,0(a0)
  dc:	14058963          	beqz	a1,22e <printf+0x192>
  e0:	4481                	li	s1,0
        char c = s[i];
        if(c != '%'){
  e2:	02500a93          	li	s5,37
        char next = s[++i];
        if(next == 0){
            putc(1,c);
            continue;
        }
        switch (next) {
  e6:	07000c13          	li	s8,112
    putc(fd,'x');
  ea:	4cc1                	li	s9,16
        putc(fd,nums[ptr >> (sizeof(uint64) * 8 - 4)]);
  ec:	00000a17          	auipc	s4,0x0
  f0:	16ca0a13          	addi	s4,s4,364 # 258 <nums>
        switch (next) {
  f4:	07300b93          	li	s7,115
  f8:	06400b13          	li	s6,100
  fc:	a829                	j	116 <printf+0x7a>
            putc(1,c);
  fe:	4505                	li	a0,1
 100:	00000097          	auipc	ra,0x0
 104:	f7a080e7          	jalr	-134(ra) # 7a <putc>
    for(int i = 0; s[i] != 0; i++){
 108:	2485                	addiw	s1,s1,1
 10a:	009987b3          	add	a5,s3,s1
 10e:	0007c583          	lbu	a1,0(a5)
 112:	10058e63          	beqz	a1,22e <printf+0x192>
        if(c != '%'){
 116:	ff5594e3          	bne	a1,s5,fe <printf+0x62>
        char next = s[++i];
 11a:	2485                	addiw	s1,s1,1
 11c:	009987b3          	add	a5,s3,s1
 120:	0007c583          	lbu	a1,0(a5)
        if(next == 0){
 124:	cd89                	beqz	a1,13e <printf+0xa2>
        switch (next) {
 126:	0b858e63          	beq	a1,s8,1e2 <printf+0x146>
 12a:	09758563          	beq	a1,s7,1b4 <printf+0x118>
 12e:	01658f63          	beq	a1,s6,14c <printf+0xb0>
        break;
        case 'p':
            printPtr(1,va_arg(ap,uint64));
        break;
        default:
            putc(1,next);
 132:	4505                	li	a0,1
 134:	00000097          	auipc	ra,0x0
 138:	f46080e7          	jalr	-186(ra) # 7a <putc>
            break;
 13c:	b7f1                	j	108 <printf+0x6c>
            putc(1,c);
 13e:	85d6                	mv	a1,s5
 140:	4505                	li	a0,1
 142:	00000097          	auipc	ra,0x0
 146:	f38080e7          	jalr	-200(ra) # 7a <putc>
            continue;
 14a:	bf7d                	j	108 <printf+0x6c>
            printInt(va_arg(ap,int),1);
 14c:	f9843783          	ld	a5,-104(s0)
 150:	00878713          	addi	a4,a5,8
 154:	f8e43c23          	sd	a4,-104(s0)
 158:	439c                	lw	a5,0(a5)
 15a:	f8840613          	addi	a2,s0,-120
    int i = 0;
 15e:	4681                	li	a3,0
        buf[i++] = nums[val % 10];
 160:	45a9                	li	a1,10
    } while ((val /= 10) > 0);
 162:	4825                	li	a6,9
        buf[i++] = nums[val % 10];
 164:	8536                	mv	a0,a3
 166:	2685                	addiw	a3,a3,1
 168:	02b7e73b          	remw	a4,a5,a1
 16c:	9752                	add	a4,a4,s4
 16e:	00074703          	lbu	a4,0(a4)
 172:	00e60023          	sb	a4,0(a2)
    } while ((val /= 10) > 0);
 176:	873e                	mv	a4,a5
 178:	02b7c7bb          	divw	a5,a5,a1
 17c:	0605                	addi	a2,a2,1
 17e:	fee843e3          	blt	a6,a4,164 <printf+0xc8>
    for(i-=1;i >= 0; i--){
 182:	f80543e3          	bltz	a0,108 <printf+0x6c>
 186:	f8840793          	addi	a5,s0,-120
 18a:	00a78933          	add	s2,a5,a0
 18e:	f8740793          	addi	a5,s0,-121
 192:	00a78d33          	add	s10,a5,a0
 196:	1502                	slli	a0,a0,0x20
 198:	9101                	srli	a0,a0,0x20
 19a:	40ad0d33          	sub	s10,s10,a0
        putc(1,buf[i]);
 19e:	00094583          	lbu	a1,0(s2)
 1a2:	4505                	li	a0,1
 1a4:	00000097          	auipc	ra,0x0
 1a8:	ed6080e7          	jalr	-298(ra) # 7a <putc>
    for(i-=1;i >= 0; i--){
 1ac:	197d                	addi	s2,s2,-1
 1ae:	ff2d18e3          	bne	s10,s2,19e <printf+0x102>
 1b2:	bf99                	j	108 <printf+0x6c>
            str = va_arg(ap,char*);
 1b4:	f9843783          	ld	a5,-104(s0)
 1b8:	00878713          	addi	a4,a5,8
 1bc:	f8e43c23          	sd	a4,-104(s0)
 1c0:	0007b903          	ld	s2,0(a5)
            if(str){
 1c4:	f40902e3          	beqz	s2,108 <printf+0x6c>
    while (*s) {
 1c8:	00094583          	lbu	a1,0(s2)
 1cc:	dd95                	beqz	a1,108 <printf+0x6c>
        putc(1,*(s++));
 1ce:	0905                	addi	s2,s2,1
 1d0:	4505                	li	a0,1
 1d2:	00000097          	auipc	ra,0x0
 1d6:	ea8080e7          	jalr	-344(ra) # 7a <putc>
    while (*s) {
 1da:	00094583          	lbu	a1,0(s2)
 1de:	f9e5                	bnez	a1,1ce <printf+0x132>
 1e0:	b725                	j	108 <printf+0x6c>
            printPtr(1,va_arg(ap,uint64));
 1e2:	f9843783          	ld	a5,-104(s0)
 1e6:	00878713          	addi	a4,a5,8
 1ea:	f8e43c23          	sd	a4,-104(s0)
 1ee:	0007bd03          	ld	s10,0(a5)
    putc(fd,'0');
 1f2:	03000593          	li	a1,48
 1f6:	4505                	li	a0,1
 1f8:	00000097          	auipc	ra,0x0
 1fc:	e82080e7          	jalr	-382(ra) # 7a <putc>
    putc(fd,'x');
 200:	07800593          	li	a1,120
 204:	4505                	li	a0,1
 206:	00000097          	auipc	ra,0x0
 20a:	e74080e7          	jalr	-396(ra) # 7a <putc>
 20e:	8966                	mv	s2,s9
        putc(fd,nums[ptr >> (sizeof(uint64) * 8 - 4)]);
 210:	03cd5793          	srli	a5,s10,0x3c
 214:	97d2                	add	a5,a5,s4
 216:	0007c583          	lbu	a1,0(a5)
 21a:	4505                	li	a0,1
 21c:	00000097          	auipc	ra,0x0
 220:	e5e080e7          	jalr	-418(ra) # 7a <putc>
    for(i = 0; i < (sizeof(uint64) * 2); i++,ptr <<= 4){
 224:	0d12                	slli	s10,s10,0x4
 226:	397d                	addiw	s2,s2,-1
 228:	fe0914e3          	bnez	s2,210 <printf+0x174>
 22c:	bdf1                	j	108 <printf+0x6c>
        }
    }
}
 22e:	70e6                	ld	ra,120(sp)
 230:	7446                	ld	s0,112(sp)
 232:	74a6                	ld	s1,104(sp)
 234:	7906                	ld	s2,96(sp)
 236:	69e6                	ld	s3,88(sp)
 238:	6a46                	ld	s4,80(sp)
 23a:	6aa6                	ld	s5,72(sp)
 23c:	6b06                	ld	s6,64(sp)
 23e:	7be2                	ld	s7,56(sp)
 240:	7c42                	ld	s8,48(sp)
 242:	7ca2                	ld	s9,40(sp)
 244:	7d02                	ld	s10,32(sp)
 246:	6129                	addi	sp,sp,192
 248:	8082                	ret
