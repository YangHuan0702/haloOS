
src/user/_ls:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
   0:	fe010113          	addi	sp,sp,-32
   4:	00813c23          	sd	s0,24(sp)
   8:	02010413          	addi	s0,sp,32
   c:	00050793          	mv	a5,a0
  10:	feb43023          	sd	a1,-32(s0)
  14:	fef42623          	sw	a5,-20(s0)
  18:	00000793          	li	a5,0
  1c:	00078513          	mv	a0,a5
  20:	01813403          	ld	s0,24(sp)
  24:	02010113          	addi	sp,sp,32
  28:	00008067          	ret
