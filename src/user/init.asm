
src/user/_init:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "src/kernel/fcntl.h"
#include "src/user/users.h"

char *argv[] = { "sh", 0 };

int main() {
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
  int pid, wpid;
  if(open("console", O_RDWR) < 0) {
   c:	4589                	li	a1,2
   e:	00000517          	auipc	a0,0x0
  12:	31a50513          	addi	a0,a0,794 # 328 <printf+0x1ae>
  16:	00000097          	auipc	ra,0x0
  1a:	0ea080e7          	jalr	234(ra) # 100 <open>
  1e:	06054363          	bltz	a0,84 <main+0x84>
    mknod("console", 1, 0);
    open("console", O_RDWR);
  }
  dup(0);  // stdout
  22:	4501                	li	a0,0
  24:	00000097          	auipc	ra,0x0
  28:	0e4080e7          	jalr	228(ra) # 108 <dup>
  dup(0);  // stderr
  2c:	4501                	li	a0,0
  2e:	00000097          	auipc	ra,0x0
  32:	0da080e7          	jalr	218(ra) # 108 <dup>
  for(;;) {
      printf("init: starting sh\n");
  36:	00000917          	auipc	s2,0x0
  3a:	2fa90913          	addi	s2,s2,762 # 330 <printf+0x1b6>
  3e:	854a                	mv	a0,s2
  40:	00000097          	auipc	ra,0x0
  44:	13a080e7          	jalr	314(ra) # 17a <printf>
      pid = fork();
  48:	00000097          	auipc	ra,0x0
  4c:	0e0080e7          	jalr	224(ra) # 128 <fork>
  50:	84aa                	mv	s1,a0
      if(pid < 0){
  52:	04054d63          	bltz	a0,ac <main+0xac>
        printf("init: fork failed\n");
        exit(1);
      }
      if(pid == 0){
  56:	c925                	beqz	a0,c6 <main+0xc6>
        exec("sh", argv);
        printf("init: exec sh failed\n");
        exit(1);
      }
      for(;;){
        wpid = wait((int *) 0);
  58:	4501                	li	a0,0
  5a:	00000097          	auipc	ra,0x0
  5e:	0be080e7          	jalr	190(ra) # 118 <wait>
        if(wpid == pid){
  62:	fca48ee3          	beq	s1,a0,3e <main+0x3e>
          break;
        } else if(wpid < 0){
  66:	fe0559e3          	bgez	a0,58 <main+0x58>
          printf("init: wait returned an error\n");
  6a:	00000517          	auipc	a0,0x0
  6e:	31650513          	addi	a0,a0,790 # 380 <printf+0x206>
  72:	00000097          	auipc	ra,0x0
  76:	108080e7          	jalr	264(ra) # 17a <printf>
          exit(1);
  7a:	4505                	li	a0,1
  7c:	00000097          	auipc	ra,0x0
  80:	0bc080e7          	jalr	188(ra) # 138 <exit>
    mknod("console", 1, 0);
  84:	4601                	li	a2,0
  86:	4585                	li	a1,1
  88:	00000517          	auipc	a0,0x0
  8c:	2a050513          	addi	a0,a0,672 # 328 <printf+0x1ae>
  90:	00000097          	auipc	ra,0x0
  94:	090080e7          	jalr	144(ra) # 120 <mknod>
    open("console", O_RDWR);
  98:	4589                	li	a1,2
  9a:	00000517          	auipc	a0,0x0
  9e:	28e50513          	addi	a0,a0,654 # 328 <printf+0x1ae>
  a2:	00000097          	auipc	ra,0x0
  a6:	05e080e7          	jalr	94(ra) # 100 <open>
  aa:	bfa5                	j	22 <main+0x22>
        printf("init: fork failed\n");
  ac:	00000517          	auipc	a0,0x0
  b0:	29c50513          	addi	a0,a0,668 # 348 <printf+0x1ce>
  b4:	00000097          	auipc	ra,0x0
  b8:	0c6080e7          	jalr	198(ra) # 17a <printf>
        exit(1);
  bc:	4505                	li	a0,1
  be:	00000097          	auipc	ra,0x0
  c2:	07a080e7          	jalr	122(ra) # 138 <exit>
        exec("sh", argv);
  c6:	00000597          	auipc	a1,0x0
  ca:	2f258593          	addi	a1,a1,754 # 3b8 <argv>
  ce:	00000517          	auipc	a0,0x0
  d2:	29250513          	addi	a0,a0,658 # 360 <printf+0x1e6>
  d6:	00000097          	auipc	ra,0x0
  da:	03a080e7          	jalr	58(ra) # 110 <exec>
        printf("init: exec sh failed\n");
  de:	00000517          	auipc	a0,0x0
  e2:	28a50513          	addi	a0,a0,650 # 368 <printf+0x1ee>
  e6:	00000097          	auipc	ra,0x0
  ea:	094080e7          	jalr	148(ra) # 17a <printf>
        exit(1);
  ee:	4505                	li	a0,1
  f0:	00000097          	auipc	ra,0x0
  f4:	048080e7          	jalr	72(ra) # 138 <exit>

00000000000000f8 <write>:
  f8:	4885                	li	a7,1
  fa:	00000073          	ecall
  fe:	8082                	ret

0000000000000100 <open>:
 100:	4891                	li	a7,4
 102:	00000073          	ecall
 106:	8082                	ret

0000000000000108 <dup>:
 108:	488d                	li	a7,3
 10a:	00000073          	ecall
 10e:	8082                	ret

0000000000000110 <exec>:
 110:	4889                	li	a7,2
 112:	00000073          	ecall
 116:	8082                	ret

0000000000000118 <wait>:
 118:	4895                	li	a7,5
 11a:	00000073          	ecall
 11e:	8082                	ret

0000000000000120 <mknod>:
 120:	4899                	li	a7,6
 122:	00000073          	ecall
 126:	8082                	ret

0000000000000128 <fork>:
 128:	48a1                	li	a7,8
 12a:	00000073          	ecall
 12e:	8082                	ret

0000000000000130 <read>:
 130:	48a5                	li	a7,9
 132:	00000073          	ecall
 136:	8082                	ret

0000000000000138 <exit>:
 138:	48a9                	li	a7,10
 13a:	00000073          	ecall
 13e:	8082                	ret

0000000000000140 <sbrk>:
 140:	48ad                	li	a7,11
 142:	00000073          	ecall
 146:	8082                	ret

0000000000000148 <fstat>:
 148:	48b1                	li	a7,12
 14a:	00000073          	ecall
 14e:	8082                	ret

0000000000000150 <close>:
 150:	48b5                	li	a7,13
 152:	00000073          	ecall
 156:	8082                	ret

0000000000000158 <putc>:

#include <stdarg.h>

static char nums[] = "0123456789abcdef";

void putc(int fd, char c) { 
 158:	1101                	addi	sp,sp,-32
 15a:	ec06                	sd	ra,24(sp)
 15c:	e822                	sd	s0,16(sp)
 15e:	1000                	addi	s0,sp,32
 160:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1); 
 164:	4605                	li	a2,1
 166:	fef40593          	addi	a1,s0,-17
 16a:	00000097          	auipc	ra,0x0
 16e:	f8e080e7          	jalr	-114(ra) # f8 <write>
}
 172:	60e2                	ld	ra,24(sp)
 174:	6442                	ld	s0,16(sp)
 176:	6105                	addi	sp,sp,32
 178:	8082                	ret

000000000000017a <printf>:
    for(i = 0; i < (sizeof(uint64) * 2); i++,ptr <<= 4){
        putc(fd,nums[ptr >> (sizeof(uint64) * 8 - 4)]);
    }
}

void printf(const char *s,...){
 17a:	7131                	addi	sp,sp,-192
 17c:	fc86                	sd	ra,120(sp)
 17e:	f8a2                	sd	s0,112(sp)
 180:	f4a6                	sd	s1,104(sp)
 182:	f0ca                	sd	s2,96(sp)
 184:	ecce                	sd	s3,88(sp)
 186:	e8d2                	sd	s4,80(sp)
 188:	e4d6                	sd	s5,72(sp)
 18a:	e0da                	sd	s6,64(sp)
 18c:	fc5e                	sd	s7,56(sp)
 18e:	f862                	sd	s8,48(sp)
 190:	f466                	sd	s9,40(sp)
 192:	f06a                	sd	s10,32(sp)
 194:	0100                	addi	s0,sp,128
 196:	e40c                	sd	a1,8(s0)
 198:	e810                	sd	a2,16(s0)
 19a:	ec14                	sd	a3,24(s0)
 19c:	f018                	sd	a4,32(s0)
 19e:	f41c                	sd	a5,40(s0)
 1a0:	03043823          	sd	a6,48(s0)
 1a4:	03143c23          	sd	a7,56(s0)
     if(s == 0){
 1a8:	16050263          	beqz	a0,30c <printf+0x192>
 1ac:	89aa                	mv	s3,a0
        return;
    }
    va_list ap;
    va_start(ap,s);
 1ae:	00840793          	addi	a5,s0,8
 1b2:	f8f43c23          	sd	a5,-104(s0)
    char *str;
    for(int i = 0; s[i] != 0; i++){
 1b6:	00054583          	lbu	a1,0(a0)
 1ba:	14058963          	beqz	a1,30c <printf+0x192>
 1be:	4481                	li	s1,0
        char c = s[i];
        if(c != '%'){
 1c0:	02500a93          	li	s5,37
        char next = s[++i];
        if(next == 0){
            putc(1,c);
            continue;
        }
        switch (next) {
 1c4:	07000c13          	li	s8,112
    putc(fd,'x');
 1c8:	4cc1                	li	s9,16
        putc(fd,nums[ptr >> (sizeof(uint64) * 8 - 4)]);
 1ca:	00000a17          	auipc	s4,0x0
 1ce:	1d6a0a13          	addi	s4,s4,470 # 3a0 <nums>
        switch (next) {
 1d2:	07300b93          	li	s7,115
 1d6:	06400b13          	li	s6,100
 1da:	a829                	j	1f4 <printf+0x7a>
            putc(1,c);
 1dc:	4505                	li	a0,1
 1de:	00000097          	auipc	ra,0x0
 1e2:	f7a080e7          	jalr	-134(ra) # 158 <putc>
    for(int i = 0; s[i] != 0; i++){
 1e6:	2485                	addiw	s1,s1,1
 1e8:	009987b3          	add	a5,s3,s1
 1ec:	0007c583          	lbu	a1,0(a5)
 1f0:	10058e63          	beqz	a1,30c <printf+0x192>
        if(c != '%'){
 1f4:	ff5594e3          	bne	a1,s5,1dc <printf+0x62>
        char next = s[++i];
 1f8:	2485                	addiw	s1,s1,1
 1fa:	009987b3          	add	a5,s3,s1
 1fe:	0007c583          	lbu	a1,0(a5)
        if(next == 0){
 202:	cd89                	beqz	a1,21c <printf+0xa2>
        switch (next) {
 204:	0b858e63          	beq	a1,s8,2c0 <printf+0x146>
 208:	09758563          	beq	a1,s7,292 <printf+0x118>
 20c:	01658f63          	beq	a1,s6,22a <printf+0xb0>
        break;
        case 'p':
            printPtr(1,va_arg(ap,uint64));
        break;
        default:
            putc(1,next);
 210:	4505                	li	a0,1
 212:	00000097          	auipc	ra,0x0
 216:	f46080e7          	jalr	-186(ra) # 158 <putc>
            break;
 21a:	b7f1                	j	1e6 <printf+0x6c>
            putc(1,c);
 21c:	85d6                	mv	a1,s5
 21e:	4505                	li	a0,1
 220:	00000097          	auipc	ra,0x0
 224:	f38080e7          	jalr	-200(ra) # 158 <putc>
            continue;
 228:	bf7d                	j	1e6 <printf+0x6c>
            printInt(va_arg(ap,int),1);
 22a:	f9843783          	ld	a5,-104(s0)
 22e:	00878713          	addi	a4,a5,8
 232:	f8e43c23          	sd	a4,-104(s0)
 236:	439c                	lw	a5,0(a5)
 238:	f8840613          	addi	a2,s0,-120
    int i = 0;
 23c:	4681                	li	a3,0
        buf[i++] = nums[val % 10];
 23e:	45a9                	li	a1,10
    } while ((val /= 10) > 0);
 240:	4825                	li	a6,9
        buf[i++] = nums[val % 10];
 242:	8536                	mv	a0,a3
 244:	2685                	addiw	a3,a3,1
 246:	02b7e73b          	remw	a4,a5,a1
 24a:	9752                	add	a4,a4,s4
 24c:	00074703          	lbu	a4,0(a4)
 250:	00e60023          	sb	a4,0(a2)
    } while ((val /= 10) > 0);
 254:	873e                	mv	a4,a5
 256:	02b7c7bb          	divw	a5,a5,a1
 25a:	0605                	addi	a2,a2,1
 25c:	fee843e3          	blt	a6,a4,242 <printf+0xc8>
    for(i-=1;i >= 0; i--){
 260:	f80543e3          	bltz	a0,1e6 <printf+0x6c>
 264:	f8840793          	addi	a5,s0,-120
 268:	00a78933          	add	s2,a5,a0
 26c:	f8740793          	addi	a5,s0,-121
 270:	00a78d33          	add	s10,a5,a0
 274:	1502                	slli	a0,a0,0x20
 276:	9101                	srli	a0,a0,0x20
 278:	40ad0d33          	sub	s10,s10,a0
        putc(1,buf[i]);
 27c:	00094583          	lbu	a1,0(s2)
 280:	4505                	li	a0,1
 282:	00000097          	auipc	ra,0x0
 286:	ed6080e7          	jalr	-298(ra) # 158 <putc>
    for(i-=1;i >= 0; i--){
 28a:	197d                	addi	s2,s2,-1
 28c:	ff2d18e3          	bne	s10,s2,27c <printf+0x102>
 290:	bf99                	j	1e6 <printf+0x6c>
            str = va_arg(ap,char*);
 292:	f9843783          	ld	a5,-104(s0)
 296:	00878713          	addi	a4,a5,8
 29a:	f8e43c23          	sd	a4,-104(s0)
 29e:	0007b903          	ld	s2,0(a5)
            if(str){
 2a2:	f40902e3          	beqz	s2,1e6 <printf+0x6c>
    while (*s) {
 2a6:	00094583          	lbu	a1,0(s2)
 2aa:	dd95                	beqz	a1,1e6 <printf+0x6c>
        putc(1,*(s++));
 2ac:	0905                	addi	s2,s2,1
 2ae:	4505                	li	a0,1
 2b0:	00000097          	auipc	ra,0x0
 2b4:	ea8080e7          	jalr	-344(ra) # 158 <putc>
    while (*s) {
 2b8:	00094583          	lbu	a1,0(s2)
 2bc:	f9e5                	bnez	a1,2ac <printf+0x132>
 2be:	b725                	j	1e6 <printf+0x6c>
            printPtr(1,va_arg(ap,uint64));
 2c0:	f9843783          	ld	a5,-104(s0)
 2c4:	00878713          	addi	a4,a5,8
 2c8:	f8e43c23          	sd	a4,-104(s0)
 2cc:	0007bd03          	ld	s10,0(a5)
    putc(fd,'0');
 2d0:	03000593          	li	a1,48
 2d4:	4505                	li	a0,1
 2d6:	00000097          	auipc	ra,0x0
 2da:	e82080e7          	jalr	-382(ra) # 158 <putc>
    putc(fd,'x');
 2de:	07800593          	li	a1,120
 2e2:	4505                	li	a0,1
 2e4:	00000097          	auipc	ra,0x0
 2e8:	e74080e7          	jalr	-396(ra) # 158 <putc>
 2ec:	8966                	mv	s2,s9
        putc(fd,nums[ptr >> (sizeof(uint64) * 8 - 4)]);
 2ee:	03cd5793          	srli	a5,s10,0x3c
 2f2:	97d2                	add	a5,a5,s4
 2f4:	0007c583          	lbu	a1,0(a5)
 2f8:	4505                	li	a0,1
 2fa:	00000097          	auipc	ra,0x0
 2fe:	e5e080e7          	jalr	-418(ra) # 158 <putc>
    for(i = 0; i < (sizeof(uint64) * 2); i++,ptr <<= 4){
 302:	0d12                	slli	s10,s10,0x4
 304:	397d                	addiw	s2,s2,-1
 306:	fe0914e3          	bnez	s2,2ee <printf+0x174>
 30a:	bdf1                	j	1e6 <printf+0x6c>
        }
    }
}
 30c:	70e6                	ld	ra,120(sp)
 30e:	7446                	ld	s0,112(sp)
 310:	74a6                	ld	s1,104(sp)
 312:	7906                	ld	s2,96(sp)
 314:	69e6                	ld	s3,88(sp)
 316:	6a46                	ld	s4,80(sp)
 318:	6aa6                	ld	s5,72(sp)
 31a:	6b06                	ld	s6,64(sp)
 31c:	7be2                	ld	s7,56(sp)
 31e:	7c42                	ld	s8,48(sp)
 320:	7ca2                	ld	s9,40(sp)
 322:	7d02                	ld	s10,32(sp)
 324:	6129                	addi	sp,sp,192
 326:	8082                	ret
