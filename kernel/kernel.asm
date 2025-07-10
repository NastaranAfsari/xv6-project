
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00008117          	auipc	sp,0x8
    80000004:	ae010113          	addi	sp,sp,-1312 # 80007ae0 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	04a000ef          	jal	80000060 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000022:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000026:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002a:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    8000002e:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000032:	577d                	li	a4,-1
    80000034:	177e                	slli	a4,a4,0x3f
    80000036:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80000038:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003c:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000040:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000044:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    80000048:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004c:	000f4737          	lui	a4,0xf4
    80000050:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000054:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000056:	14d79073          	csrw	stimecmp,a5
}
    8000005a:	6422                	ld	s0,8(sp)
    8000005c:	0141                	addi	sp,sp,16
    8000005e:	8082                	ret

0000000080000060 <start>:
{
    80000060:	1141                	addi	sp,sp,-16
    80000062:	e406                	sd	ra,8(sp)
    80000064:	e022                	sd	s0,0(sp)
    80000066:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000006c:	7779                	lui	a4,0xffffe
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdb7ef>
    80000072:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000074:	6705                	lui	a4,0x1
    80000076:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000007c:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000080:	00001797          	auipc	a5,0x1
    80000084:	de278793          	addi	a5,a5,-542 # 80000e62 <main>
    80000088:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    8000008c:	4781                	li	a5,0
    8000008e:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000092:	67c1                	lui	a5,0x10
    80000094:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80000096:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009a:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    8000009e:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000a2:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000a6:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000aa:	57fd                	li	a5,-1
    800000ac:	83a9                	srli	a5,a5,0xa
    800000ae:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b2:	47bd                	li	a5,15
    800000b4:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000b8:	f65ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000bc:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c4:	30200073          	mret
}
    800000c8:	60a2                	ld	ra,8(sp)
    800000ca:	6402                	ld	s0,0(sp)
    800000cc:	0141                	addi	sp,sp,16
    800000ce:	8082                	ret

00000000800000d0 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d0:	715d                	addi	sp,sp,-80
    800000d2:	e486                	sd	ra,72(sp)
    800000d4:	e0a2                	sd	s0,64(sp)
    800000d6:	f84a                	sd	s2,48(sp)
    800000d8:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    800000da:	04c05263          	blez	a2,8000011e <consolewrite+0x4e>
    800000de:	fc26                	sd	s1,56(sp)
    800000e0:	f44e                	sd	s3,40(sp)
    800000e2:	f052                	sd	s4,32(sp)
    800000e4:	ec56                	sd	s5,24(sp)
    800000e6:	8a2a                	mv	s4,a0
    800000e8:	84ae                	mv	s1,a1
    800000ea:	89b2                	mv	s3,a2
    800000ec:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    800000ee:	5afd                	li	s5,-1
    800000f0:	4685                	li	a3,1
    800000f2:	8626                	mv	a2,s1
    800000f4:	85d2                	mv	a1,s4
    800000f6:	fbf40513          	addi	a0,s0,-65
    800000fa:	528020ef          	jal	80002622 <either_copyin>
    800000fe:	03550263          	beq	a0,s5,80000122 <consolewrite+0x52>
      break;
    uartputc(c);
    80000102:	fbf44503          	lbu	a0,-65(s0)
    80000106:	035000ef          	jal	8000093a <uartputc>
  for(i = 0; i < n; i++){
    8000010a:	2905                	addiw	s2,s2,1
    8000010c:	0485                	addi	s1,s1,1
    8000010e:	ff2991e3          	bne	s3,s2,800000f0 <consolewrite+0x20>
    80000112:	894e                	mv	s2,s3
    80000114:	74e2                	ld	s1,56(sp)
    80000116:	79a2                	ld	s3,40(sp)
    80000118:	7a02                	ld	s4,32(sp)
    8000011a:	6ae2                	ld	s5,24(sp)
    8000011c:	a039                	j	8000012a <consolewrite+0x5a>
    8000011e:	4901                	li	s2,0
    80000120:	a029                	j	8000012a <consolewrite+0x5a>
    80000122:	74e2                	ld	s1,56(sp)
    80000124:	79a2                	ld	s3,40(sp)
    80000126:	7a02                	ld	s4,32(sp)
    80000128:	6ae2                	ld	s5,24(sp)
  }

  return i;
}
    8000012a:	854a                	mv	a0,s2
    8000012c:	60a6                	ld	ra,72(sp)
    8000012e:	6406                	ld	s0,64(sp)
    80000130:	7942                	ld	s2,48(sp)
    80000132:	6161                	addi	sp,sp,80
    80000134:	8082                	ret

0000000080000136 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000136:	711d                	addi	sp,sp,-96
    80000138:	ec86                	sd	ra,88(sp)
    8000013a:	e8a2                	sd	s0,80(sp)
    8000013c:	e4a6                	sd	s1,72(sp)
    8000013e:	e0ca                	sd	s2,64(sp)
    80000140:	fc4e                	sd	s3,56(sp)
    80000142:	f852                	sd	s4,48(sp)
    80000144:	f456                	sd	s5,40(sp)
    80000146:	f05a                	sd	s6,32(sp)
    80000148:	1080                	addi	s0,sp,96
    8000014a:	8aaa                	mv	s5,a0
    8000014c:	8a2e                	mv	s4,a1
    8000014e:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000150:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000154:	00010517          	auipc	a0,0x10
    80000158:	98c50513          	addi	a0,a0,-1652 # 8000fae0 <cons>
    8000015c:	299000ef          	jal	80000bf4 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000160:	00010497          	auipc	s1,0x10
    80000164:	98048493          	addi	s1,s1,-1664 # 8000fae0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000168:	00010917          	auipc	s2,0x10
    8000016c:	a1090913          	addi	s2,s2,-1520 # 8000fb78 <cons+0x98>
  while(n > 0){
    80000170:	0b305d63          	blez	s3,8000022a <consoleread+0xf4>
    while(cons.r == cons.w){
    80000174:	0984a783          	lw	a5,152(s1)
    80000178:	09c4a703          	lw	a4,156(s1)
    8000017c:	0af71263          	bne	a4,a5,80000220 <consoleread+0xea>
      if(killed(myproc())){
    80000180:	782010ef          	jal	80001902 <myproc>
    80000184:	330020ef          	jal	800024b4 <killed>
    80000188:	e12d                	bnez	a0,800001ea <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    8000018a:	85a6                	mv	a1,s1
    8000018c:	854a                	mv	a0,s2
    8000018e:	088020ef          	jal	80002216 <sleep>
    while(cons.r == cons.w){
    80000192:	0984a783          	lw	a5,152(s1)
    80000196:	09c4a703          	lw	a4,156(s1)
    8000019a:	fef703e3          	beq	a4,a5,80000180 <consoleread+0x4a>
    8000019e:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001a0:	00010717          	auipc	a4,0x10
    800001a4:	94070713          	addi	a4,a4,-1728 # 8000fae0 <cons>
    800001a8:	0017869b          	addiw	a3,a5,1
    800001ac:	08d72c23          	sw	a3,152(a4)
    800001b0:	07f7f693          	andi	a3,a5,127
    800001b4:	9736                	add	a4,a4,a3
    800001b6:	01874703          	lbu	a4,24(a4)
    800001ba:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001be:	4691                	li	a3,4
    800001c0:	04db8663          	beq	s7,a3,8000020c <consoleread+0xd6>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    800001c4:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001c8:	4685                	li	a3,1
    800001ca:	faf40613          	addi	a2,s0,-81
    800001ce:	85d2                	mv	a1,s4
    800001d0:	8556                	mv	a0,s5
    800001d2:	406020ef          	jal	800025d8 <either_copyout>
    800001d6:	57fd                	li	a5,-1
    800001d8:	04f50863          	beq	a0,a5,80000228 <consoleread+0xf2>
      break;

    dst++;
    800001dc:	0a05                	addi	s4,s4,1
    --n;
    800001de:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    800001e0:	47a9                	li	a5,10
    800001e2:	04fb8d63          	beq	s7,a5,8000023c <consoleread+0x106>
    800001e6:	6be2                	ld	s7,24(sp)
    800001e8:	b761                	j	80000170 <consoleread+0x3a>
        release(&cons.lock);
    800001ea:	00010517          	auipc	a0,0x10
    800001ee:	8f650513          	addi	a0,a0,-1802 # 8000fae0 <cons>
    800001f2:	29b000ef          	jal	80000c8c <release>
        return -1;
    800001f6:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    800001f8:	60e6                	ld	ra,88(sp)
    800001fa:	6446                	ld	s0,80(sp)
    800001fc:	64a6                	ld	s1,72(sp)
    800001fe:	6906                	ld	s2,64(sp)
    80000200:	79e2                	ld	s3,56(sp)
    80000202:	7a42                	ld	s4,48(sp)
    80000204:	7aa2                	ld	s5,40(sp)
    80000206:	7b02                	ld	s6,32(sp)
    80000208:	6125                	addi	sp,sp,96
    8000020a:	8082                	ret
      if(n < target){
    8000020c:	0009871b          	sext.w	a4,s3
    80000210:	01677a63          	bgeu	a4,s6,80000224 <consoleread+0xee>
        cons.r--;
    80000214:	00010717          	auipc	a4,0x10
    80000218:	96f72223          	sw	a5,-1692(a4) # 8000fb78 <cons+0x98>
    8000021c:	6be2                	ld	s7,24(sp)
    8000021e:	a031                	j	8000022a <consoleread+0xf4>
    80000220:	ec5e                	sd	s7,24(sp)
    80000222:	bfbd                	j	800001a0 <consoleread+0x6a>
    80000224:	6be2                	ld	s7,24(sp)
    80000226:	a011                	j	8000022a <consoleread+0xf4>
    80000228:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    8000022a:	00010517          	auipc	a0,0x10
    8000022e:	8b650513          	addi	a0,a0,-1866 # 8000fae0 <cons>
    80000232:	25b000ef          	jal	80000c8c <release>
  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	bf7d                	j	800001f8 <consoleread+0xc2>
    8000023c:	6be2                	ld	s7,24(sp)
    8000023e:	b7f5                	j	8000022a <consoleread+0xf4>

0000000080000240 <consputc>:
{
    80000240:	1141                	addi	sp,sp,-16
    80000242:	e406                	sd	ra,8(sp)
    80000244:	e022                	sd	s0,0(sp)
    80000246:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000248:	10000793          	li	a5,256
    8000024c:	00f50863          	beq	a0,a5,8000025c <consputc+0x1c>
    uartputc_sync(c);
    80000250:	604000ef          	jal	80000854 <uartputc_sync>
}
    80000254:	60a2                	ld	ra,8(sp)
    80000256:	6402                	ld	s0,0(sp)
    80000258:	0141                	addi	sp,sp,16
    8000025a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000025c:	4521                	li	a0,8
    8000025e:	5f6000ef          	jal	80000854 <uartputc_sync>
    80000262:	02000513          	li	a0,32
    80000266:	5ee000ef          	jal	80000854 <uartputc_sync>
    8000026a:	4521                	li	a0,8
    8000026c:	5e8000ef          	jal	80000854 <uartputc_sync>
    80000270:	b7d5                	j	80000254 <consputc+0x14>

0000000080000272 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80000272:	1101                	addi	sp,sp,-32
    80000274:	ec06                	sd	ra,24(sp)
    80000276:	e822                	sd	s0,16(sp)
    80000278:	e426                	sd	s1,8(sp)
    8000027a:	1000                	addi	s0,sp,32
    8000027c:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    8000027e:	00010517          	auipc	a0,0x10
    80000282:	86250513          	addi	a0,a0,-1950 # 8000fae0 <cons>
    80000286:	16f000ef          	jal	80000bf4 <acquire>

  switch(c){
    8000028a:	47d5                	li	a5,21
    8000028c:	08f48f63          	beq	s1,a5,8000032a <consoleintr+0xb8>
    80000290:	0297c563          	blt	a5,s1,800002ba <consoleintr+0x48>
    80000294:	47a1                	li	a5,8
    80000296:	0ef48463          	beq	s1,a5,8000037e <consoleintr+0x10c>
    8000029a:	47c1                	li	a5,16
    8000029c:	10f49563          	bne	s1,a5,800003a6 <consoleintr+0x134>
  case C('P'):  // Print process list.
    procdump();
    800002a0:	3cc020ef          	jal	8000266c <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002a4:	00010517          	auipc	a0,0x10
    800002a8:	83c50513          	addi	a0,a0,-1988 # 8000fae0 <cons>
    800002ac:	1e1000ef          	jal	80000c8c <release>
}
    800002b0:	60e2                	ld	ra,24(sp)
    800002b2:	6442                	ld	s0,16(sp)
    800002b4:	64a2                	ld	s1,8(sp)
    800002b6:	6105                	addi	sp,sp,32
    800002b8:	8082                	ret
  switch(c){
    800002ba:	07f00793          	li	a5,127
    800002be:	0cf48063          	beq	s1,a5,8000037e <consoleintr+0x10c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002c2:	00010717          	auipc	a4,0x10
    800002c6:	81e70713          	addi	a4,a4,-2018 # 8000fae0 <cons>
    800002ca:	0a072783          	lw	a5,160(a4)
    800002ce:	09872703          	lw	a4,152(a4)
    800002d2:	9f99                	subw	a5,a5,a4
    800002d4:	07f00713          	li	a4,127
    800002d8:	fcf766e3          	bltu	a4,a5,800002a4 <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    800002dc:	47b5                	li	a5,13
    800002de:	0cf48763          	beq	s1,a5,800003ac <consoleintr+0x13a>
      consputc(c);
    800002e2:	8526                	mv	a0,s1
    800002e4:	f5dff0ef          	jal	80000240 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800002e8:	0000f797          	auipc	a5,0xf
    800002ec:	7f878793          	addi	a5,a5,2040 # 8000fae0 <cons>
    800002f0:	0a07a683          	lw	a3,160(a5)
    800002f4:	0016871b          	addiw	a4,a3,1
    800002f8:	0007061b          	sext.w	a2,a4
    800002fc:	0ae7a023          	sw	a4,160(a5)
    80000300:	07f6f693          	andi	a3,a3,127
    80000304:	97b6                	add	a5,a5,a3
    80000306:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000030a:	47a9                	li	a5,10
    8000030c:	0cf48563          	beq	s1,a5,800003d6 <consoleintr+0x164>
    80000310:	4791                	li	a5,4
    80000312:	0cf48263          	beq	s1,a5,800003d6 <consoleintr+0x164>
    80000316:	00010797          	auipc	a5,0x10
    8000031a:	8627a783          	lw	a5,-1950(a5) # 8000fb78 <cons+0x98>
    8000031e:	9f1d                	subw	a4,a4,a5
    80000320:	08000793          	li	a5,128
    80000324:	f8f710e3          	bne	a4,a5,800002a4 <consoleintr+0x32>
    80000328:	a07d                	j	800003d6 <consoleintr+0x164>
    8000032a:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    8000032c:	0000f717          	auipc	a4,0xf
    80000330:	7b470713          	addi	a4,a4,1972 # 8000fae0 <cons>
    80000334:	0a072783          	lw	a5,160(a4)
    80000338:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000033c:	0000f497          	auipc	s1,0xf
    80000340:	7a448493          	addi	s1,s1,1956 # 8000fae0 <cons>
    while(cons.e != cons.w &&
    80000344:	4929                	li	s2,10
    80000346:	02f70863          	beq	a4,a5,80000376 <consoleintr+0x104>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000034a:	37fd                	addiw	a5,a5,-1
    8000034c:	07f7f713          	andi	a4,a5,127
    80000350:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80000352:	01874703          	lbu	a4,24(a4)
    80000356:	03270263          	beq	a4,s2,8000037a <consoleintr+0x108>
      cons.e--;
    8000035a:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    8000035e:	10000513          	li	a0,256
    80000362:	edfff0ef          	jal	80000240 <consputc>
    while(cons.e != cons.w &&
    80000366:	0a04a783          	lw	a5,160(s1)
    8000036a:	09c4a703          	lw	a4,156(s1)
    8000036e:	fcf71ee3          	bne	a4,a5,8000034a <consoleintr+0xd8>
    80000372:	6902                	ld	s2,0(sp)
    80000374:	bf05                	j	800002a4 <consoleintr+0x32>
    80000376:	6902                	ld	s2,0(sp)
    80000378:	b735                	j	800002a4 <consoleintr+0x32>
    8000037a:	6902                	ld	s2,0(sp)
    8000037c:	b725                	j	800002a4 <consoleintr+0x32>
    if(cons.e != cons.w){
    8000037e:	0000f717          	auipc	a4,0xf
    80000382:	76270713          	addi	a4,a4,1890 # 8000fae0 <cons>
    80000386:	0a072783          	lw	a5,160(a4)
    8000038a:	09c72703          	lw	a4,156(a4)
    8000038e:	f0f70be3          	beq	a4,a5,800002a4 <consoleintr+0x32>
      cons.e--;
    80000392:	37fd                	addiw	a5,a5,-1
    80000394:	0000f717          	auipc	a4,0xf
    80000398:	7ef72623          	sw	a5,2028(a4) # 8000fb80 <cons+0xa0>
      consputc(BACKSPACE);
    8000039c:	10000513          	li	a0,256
    800003a0:	ea1ff0ef          	jal	80000240 <consputc>
    800003a4:	b701                	j	800002a4 <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003a6:	ee048fe3          	beqz	s1,800002a4 <consoleintr+0x32>
    800003aa:	bf21                	j	800002c2 <consoleintr+0x50>
      consputc(c);
    800003ac:	4529                	li	a0,10
    800003ae:	e93ff0ef          	jal	80000240 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003b2:	0000f797          	auipc	a5,0xf
    800003b6:	72e78793          	addi	a5,a5,1838 # 8000fae0 <cons>
    800003ba:	0a07a703          	lw	a4,160(a5)
    800003be:	0017069b          	addiw	a3,a4,1
    800003c2:	0006861b          	sext.w	a2,a3
    800003c6:	0ad7a023          	sw	a3,160(a5)
    800003ca:	07f77713          	andi	a4,a4,127
    800003ce:	97ba                	add	a5,a5,a4
    800003d0:	4729                	li	a4,10
    800003d2:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    800003d6:	0000f797          	auipc	a5,0xf
    800003da:	7ac7a323          	sw	a2,1958(a5) # 8000fb7c <cons+0x9c>
        wakeup(&cons.r);
    800003de:	0000f517          	auipc	a0,0xf
    800003e2:	79a50513          	addi	a0,a0,1946 # 8000fb78 <cons+0x98>
    800003e6:	67d010ef          	jal	80002262 <wakeup>
    800003ea:	bd6d                	j	800002a4 <consoleintr+0x32>

00000000800003ec <consoleinit>:

void
consoleinit(void)
{
    800003ec:	1141                	addi	sp,sp,-16
    800003ee:	e406                	sd	ra,8(sp)
    800003f0:	e022                	sd	s0,0(sp)
    800003f2:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    800003f4:	00007597          	auipc	a1,0x7
    800003f8:	c0c58593          	addi	a1,a1,-1012 # 80007000 <etext>
    800003fc:	0000f517          	auipc	a0,0xf
    80000400:	6e450513          	addi	a0,a0,1764 # 8000fae0 <cons>
    80000404:	770000ef          	jal	80000b74 <initlock>

  uartinit();
    80000408:	3f4000ef          	jal	800007fc <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000040c:	00022797          	auipc	a5,0x22
    80000410:	a6c78793          	addi	a5,a5,-1428 # 80021e78 <devsw>
    80000414:	00000717          	auipc	a4,0x0
    80000418:	d2270713          	addi	a4,a4,-734 # 80000136 <consoleread>
    8000041c:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000041e:	00000717          	auipc	a4,0x0
    80000422:	cb270713          	addi	a4,a4,-846 # 800000d0 <consolewrite>
    80000426:	ef98                	sd	a4,24(a5)
}
    80000428:	60a2                	ld	ra,8(sp)
    8000042a:	6402                	ld	s0,0(sp)
    8000042c:	0141                	addi	sp,sp,16
    8000042e:	8082                	ret

0000000080000430 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000430:	7179                	addi	sp,sp,-48
    80000432:	f406                	sd	ra,40(sp)
    80000434:	f022                	sd	s0,32(sp)
    80000436:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80000438:	c219                	beqz	a2,8000043e <printint+0xe>
    8000043a:	08054063          	bltz	a0,800004ba <printint+0x8a>
    x = -xx;
  else
    x = xx;
    8000043e:	4881                	li	a7,0
    80000440:	fd040693          	addi	a3,s0,-48

  i = 0;
    80000444:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    80000446:	00007617          	auipc	a2,0x7
    8000044a:	4da60613          	addi	a2,a2,1242 # 80007920 <digits>
    8000044e:	883e                	mv	a6,a5
    80000450:	2785                	addiw	a5,a5,1
    80000452:	02b57733          	remu	a4,a0,a1
    80000456:	9732                	add	a4,a4,a2
    80000458:	00074703          	lbu	a4,0(a4)
    8000045c:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    80000460:	872a                	mv	a4,a0
    80000462:	02b55533          	divu	a0,a0,a1
    80000466:	0685                	addi	a3,a3,1
    80000468:	feb773e3          	bgeu	a4,a1,8000044e <printint+0x1e>

  if(sign)
    8000046c:	00088a63          	beqz	a7,80000480 <printint+0x50>
    buf[i++] = '-';
    80000470:	1781                	addi	a5,a5,-32
    80000472:	97a2                	add	a5,a5,s0
    80000474:	02d00713          	li	a4,45
    80000478:	fee78823          	sb	a4,-16(a5)
    8000047c:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    80000480:	02f05963          	blez	a5,800004b2 <printint+0x82>
    80000484:	ec26                	sd	s1,24(sp)
    80000486:	e84a                	sd	s2,16(sp)
    80000488:	fd040713          	addi	a4,s0,-48
    8000048c:	00f704b3          	add	s1,a4,a5
    80000490:	fff70913          	addi	s2,a4,-1
    80000494:	993e                	add	s2,s2,a5
    80000496:	37fd                	addiw	a5,a5,-1
    80000498:	1782                	slli	a5,a5,0x20
    8000049a:	9381                	srli	a5,a5,0x20
    8000049c:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800004a0:	fff4c503          	lbu	a0,-1(s1)
    800004a4:	d9dff0ef          	jal	80000240 <consputc>
  while(--i >= 0)
    800004a8:	14fd                	addi	s1,s1,-1
    800004aa:	ff249be3          	bne	s1,s2,800004a0 <printint+0x70>
    800004ae:	64e2                	ld	s1,24(sp)
    800004b0:	6942                	ld	s2,16(sp)
}
    800004b2:	70a2                	ld	ra,40(sp)
    800004b4:	7402                	ld	s0,32(sp)
    800004b6:	6145                	addi	sp,sp,48
    800004b8:	8082                	ret
    x = -xx;
    800004ba:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004be:	4885                	li	a7,1
    x = -xx;
    800004c0:	b741                	j	80000440 <printint+0x10>

00000000800004c2 <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004c2:	7155                	addi	sp,sp,-208
    800004c4:	e506                	sd	ra,136(sp)
    800004c6:	e122                	sd	s0,128(sp)
    800004c8:	f0d2                	sd	s4,96(sp)
    800004ca:	0900                	addi	s0,sp,144
    800004cc:	8a2a                	mv	s4,a0
    800004ce:	e40c                	sd	a1,8(s0)
    800004d0:	e810                	sd	a2,16(s0)
    800004d2:	ec14                	sd	a3,24(s0)
    800004d4:	f018                	sd	a4,32(s0)
    800004d6:	f41c                	sd	a5,40(s0)
    800004d8:	03043823          	sd	a6,48(s0)
    800004dc:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2, locking;
  char *s;

  locking = pr.locking;
    800004e0:	0000f797          	auipc	a5,0xf
    800004e4:	6c07a783          	lw	a5,1728(a5) # 8000fba0 <pr+0x18>
    800004e8:	f6f43c23          	sd	a5,-136(s0)
  if(locking)
    800004ec:	e3a1                	bnez	a5,8000052c <printf+0x6a>
    acquire(&pr.lock);

  va_start(ap, fmt);
    800004ee:	00840793          	addi	a5,s0,8
    800004f2:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    800004f6:	00054503          	lbu	a0,0(a0)
    800004fa:	26050763          	beqz	a0,80000768 <printf+0x2a6>
    800004fe:	fca6                	sd	s1,120(sp)
    80000500:	f8ca                	sd	s2,112(sp)
    80000502:	f4ce                	sd	s3,104(sp)
    80000504:	ecd6                	sd	s5,88(sp)
    80000506:	e8da                	sd	s6,80(sp)
    80000508:	e0e2                	sd	s8,64(sp)
    8000050a:	fc66                	sd	s9,56(sp)
    8000050c:	f86a                	sd	s10,48(sp)
    8000050e:	f46e                	sd	s11,40(sp)
    80000510:	4981                	li	s3,0
    if(cx != '%'){
    80000512:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    80000516:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    8000051a:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    8000051e:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80000522:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80000526:	07000d93          	li	s11,112
    8000052a:	a815                	j	8000055e <printf+0x9c>
    acquire(&pr.lock);
    8000052c:	0000f517          	auipc	a0,0xf
    80000530:	65c50513          	addi	a0,a0,1628 # 8000fb88 <pr>
    80000534:	6c0000ef          	jal	80000bf4 <acquire>
  va_start(ap, fmt);
    80000538:	00840793          	addi	a5,s0,8
    8000053c:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000540:	000a4503          	lbu	a0,0(s4)
    80000544:	fd4d                	bnez	a0,800004fe <printf+0x3c>
    80000546:	a481                	j	80000786 <printf+0x2c4>
      consputc(cx);
    80000548:	cf9ff0ef          	jal	80000240 <consputc>
      continue;
    8000054c:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000054e:	0014899b          	addiw	s3,s1,1
    80000552:	013a07b3          	add	a5,s4,s3
    80000556:	0007c503          	lbu	a0,0(a5)
    8000055a:	1e050b63          	beqz	a0,80000750 <printf+0x28e>
    if(cx != '%'){
    8000055e:	ff5515e3          	bne	a0,s5,80000548 <printf+0x86>
    i++;
    80000562:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    80000566:	009a07b3          	add	a5,s4,s1
    8000056a:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    8000056e:	1e090163          	beqz	s2,80000750 <printf+0x28e>
    80000572:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    80000576:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    80000578:	c789                	beqz	a5,80000582 <printf+0xc0>
    8000057a:	009a0733          	add	a4,s4,s1
    8000057e:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    80000582:	03690763          	beq	s2,s6,800005b0 <printf+0xee>
    } else if(c0 == 'l' && c1 == 'd'){
    80000586:	05890163          	beq	s2,s8,800005c8 <printf+0x106>
    } else if(c0 == 'u'){
    8000058a:	0d990b63          	beq	s2,s9,80000660 <printf+0x19e>
    } else if(c0 == 'x'){
    8000058e:	13a90163          	beq	s2,s10,800006b0 <printf+0x1ee>
    } else if(c0 == 'p'){
    80000592:	13b90b63          	beq	s2,s11,800006c8 <printf+0x206>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 's'){
    80000596:	07300793          	li	a5,115
    8000059a:	16f90a63          	beq	s2,a5,8000070e <printf+0x24c>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    8000059e:	1b590463          	beq	s2,s5,80000746 <printf+0x284>
      consputc('%');
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    800005a2:	8556                	mv	a0,s5
    800005a4:	c9dff0ef          	jal	80000240 <consputc>
      consputc(c0);
    800005a8:	854a                	mv	a0,s2
    800005aa:	c97ff0ef          	jal	80000240 <consputc>
    800005ae:	b745                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, int), 10, 1);
    800005b0:	f8843783          	ld	a5,-120(s0)
    800005b4:	00878713          	addi	a4,a5,8
    800005b8:	f8e43423          	sd	a4,-120(s0)
    800005bc:	4605                	li	a2,1
    800005be:	45a9                	li	a1,10
    800005c0:	4388                	lw	a0,0(a5)
    800005c2:	e6fff0ef          	jal	80000430 <printint>
    800005c6:	b761                	j	8000054e <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'd'){
    800005c8:	03678663          	beq	a5,s6,800005f4 <printf+0x132>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800005cc:	05878263          	beq	a5,s8,80000610 <printf+0x14e>
    } else if(c0 == 'l' && c1 == 'u'){
    800005d0:	0b978463          	beq	a5,s9,80000678 <printf+0x1b6>
    } else if(c0 == 'l' && c1 == 'x'){
    800005d4:	fda797e3          	bne	a5,s10,800005a2 <printf+0xe0>
      printint(va_arg(ap, uint64), 16, 0);
    800005d8:	f8843783          	ld	a5,-120(s0)
    800005dc:	00878713          	addi	a4,a5,8
    800005e0:	f8e43423          	sd	a4,-120(s0)
    800005e4:	4601                	li	a2,0
    800005e6:	45c1                	li	a1,16
    800005e8:	6388                	ld	a0,0(a5)
    800005ea:	e47ff0ef          	jal	80000430 <printint>
      i += 1;
    800005ee:	0029849b          	addiw	s1,s3,2
    800005f2:	bfb1                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    800005f4:	f8843783          	ld	a5,-120(s0)
    800005f8:	00878713          	addi	a4,a5,8
    800005fc:	f8e43423          	sd	a4,-120(s0)
    80000600:	4605                	li	a2,1
    80000602:	45a9                	li	a1,10
    80000604:	6388                	ld	a0,0(a5)
    80000606:	e2bff0ef          	jal	80000430 <printint>
      i += 1;
    8000060a:	0029849b          	addiw	s1,s3,2
    8000060e:	b781                	j	8000054e <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    80000610:	06400793          	li	a5,100
    80000614:	02f68863          	beq	a3,a5,80000644 <printf+0x182>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80000618:	07500793          	li	a5,117
    8000061c:	06f68c63          	beq	a3,a5,80000694 <printf+0x1d2>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    80000620:	07800793          	li	a5,120
    80000624:	f6f69fe3          	bne	a3,a5,800005a2 <printf+0xe0>
      printint(va_arg(ap, uint64), 16, 0);
    80000628:	f8843783          	ld	a5,-120(s0)
    8000062c:	00878713          	addi	a4,a5,8
    80000630:	f8e43423          	sd	a4,-120(s0)
    80000634:	4601                	li	a2,0
    80000636:	45c1                	li	a1,16
    80000638:	6388                	ld	a0,0(a5)
    8000063a:	df7ff0ef          	jal	80000430 <printint>
      i += 2;
    8000063e:	0039849b          	addiw	s1,s3,3
    80000642:	b731                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    80000644:	f8843783          	ld	a5,-120(s0)
    80000648:	00878713          	addi	a4,a5,8
    8000064c:	f8e43423          	sd	a4,-120(s0)
    80000650:	4605                	li	a2,1
    80000652:	45a9                	li	a1,10
    80000654:	6388                	ld	a0,0(a5)
    80000656:	ddbff0ef          	jal	80000430 <printint>
      i += 2;
    8000065a:	0039849b          	addiw	s1,s3,3
    8000065e:	bdc5                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, int), 10, 0);
    80000660:	f8843783          	ld	a5,-120(s0)
    80000664:	00878713          	addi	a4,a5,8
    80000668:	f8e43423          	sd	a4,-120(s0)
    8000066c:	4601                	li	a2,0
    8000066e:	45a9                	li	a1,10
    80000670:	4388                	lw	a0,0(a5)
    80000672:	dbfff0ef          	jal	80000430 <printint>
    80000676:	bde1                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    80000678:	f8843783          	ld	a5,-120(s0)
    8000067c:	00878713          	addi	a4,a5,8
    80000680:	f8e43423          	sd	a4,-120(s0)
    80000684:	4601                	li	a2,0
    80000686:	45a9                	li	a1,10
    80000688:	6388                	ld	a0,0(a5)
    8000068a:	da7ff0ef          	jal	80000430 <printint>
      i += 1;
    8000068e:	0029849b          	addiw	s1,s3,2
    80000692:	bd75                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    80000694:	f8843783          	ld	a5,-120(s0)
    80000698:	00878713          	addi	a4,a5,8
    8000069c:	f8e43423          	sd	a4,-120(s0)
    800006a0:	4601                	li	a2,0
    800006a2:	45a9                	li	a1,10
    800006a4:	6388                	ld	a0,0(a5)
    800006a6:	d8bff0ef          	jal	80000430 <printint>
      i += 2;
    800006aa:	0039849b          	addiw	s1,s3,3
    800006ae:	b545                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, int), 16, 0);
    800006b0:	f8843783          	ld	a5,-120(s0)
    800006b4:	00878713          	addi	a4,a5,8
    800006b8:	f8e43423          	sd	a4,-120(s0)
    800006bc:	4601                	li	a2,0
    800006be:	45c1                	li	a1,16
    800006c0:	4388                	lw	a0,0(a5)
    800006c2:	d6fff0ef          	jal	80000430 <printint>
    800006c6:	b561                	j	8000054e <printf+0x8c>
    800006c8:	e4de                	sd	s7,72(sp)
      printptr(va_arg(ap, uint64));
    800006ca:	f8843783          	ld	a5,-120(s0)
    800006ce:	00878713          	addi	a4,a5,8
    800006d2:	f8e43423          	sd	a4,-120(s0)
    800006d6:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006da:	03000513          	li	a0,48
    800006de:	b63ff0ef          	jal	80000240 <consputc>
  consputc('x');
    800006e2:	07800513          	li	a0,120
    800006e6:	b5bff0ef          	jal	80000240 <consputc>
    800006ea:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006ec:	00007b97          	auipc	s7,0x7
    800006f0:	234b8b93          	addi	s7,s7,564 # 80007920 <digits>
    800006f4:	03c9d793          	srli	a5,s3,0x3c
    800006f8:	97de                	add	a5,a5,s7
    800006fa:	0007c503          	lbu	a0,0(a5)
    800006fe:	b43ff0ef          	jal	80000240 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80000702:	0992                	slli	s3,s3,0x4
    80000704:	397d                	addiw	s2,s2,-1
    80000706:	fe0917e3          	bnez	s2,800006f4 <printf+0x232>
    8000070a:	6ba6                	ld	s7,72(sp)
    8000070c:	b589                	j	8000054e <printf+0x8c>
      if((s = va_arg(ap, char*)) == 0)
    8000070e:	f8843783          	ld	a5,-120(s0)
    80000712:	00878713          	addi	a4,a5,8
    80000716:	f8e43423          	sd	a4,-120(s0)
    8000071a:	0007b903          	ld	s2,0(a5)
    8000071e:	00090d63          	beqz	s2,80000738 <printf+0x276>
      for(; *s; s++)
    80000722:	00094503          	lbu	a0,0(s2)
    80000726:	e20504e3          	beqz	a0,8000054e <printf+0x8c>
        consputc(*s);
    8000072a:	b17ff0ef          	jal	80000240 <consputc>
      for(; *s; s++)
    8000072e:	0905                	addi	s2,s2,1
    80000730:	00094503          	lbu	a0,0(s2)
    80000734:	f97d                	bnez	a0,8000072a <printf+0x268>
    80000736:	bd21                	j	8000054e <printf+0x8c>
        s = "(null)";
    80000738:	00007917          	auipc	s2,0x7
    8000073c:	8d090913          	addi	s2,s2,-1840 # 80007008 <etext+0x8>
      for(; *s; s++)
    80000740:	02800513          	li	a0,40
    80000744:	b7dd                	j	8000072a <printf+0x268>
      consputc('%');
    80000746:	02500513          	li	a0,37
    8000074a:	af7ff0ef          	jal	80000240 <consputc>
    8000074e:	b501                	j	8000054e <printf+0x8c>
    }
#endif
  }
  va_end(ap);

  if(locking)
    80000750:	f7843783          	ld	a5,-136(s0)
    80000754:	e385                	bnez	a5,80000774 <printf+0x2b2>
    80000756:	74e6                	ld	s1,120(sp)
    80000758:	7946                	ld	s2,112(sp)
    8000075a:	79a6                	ld	s3,104(sp)
    8000075c:	6ae6                	ld	s5,88(sp)
    8000075e:	6b46                	ld	s6,80(sp)
    80000760:	6c06                	ld	s8,64(sp)
    80000762:	7ce2                	ld	s9,56(sp)
    80000764:	7d42                	ld	s10,48(sp)
    80000766:	7da2                	ld	s11,40(sp)
    release(&pr.lock);

  return 0;
}
    80000768:	4501                	li	a0,0
    8000076a:	60aa                	ld	ra,136(sp)
    8000076c:	640a                	ld	s0,128(sp)
    8000076e:	7a06                	ld	s4,96(sp)
    80000770:	6169                	addi	sp,sp,208
    80000772:	8082                	ret
    80000774:	74e6                	ld	s1,120(sp)
    80000776:	7946                	ld	s2,112(sp)
    80000778:	79a6                	ld	s3,104(sp)
    8000077a:	6ae6                	ld	s5,88(sp)
    8000077c:	6b46                	ld	s6,80(sp)
    8000077e:	6c06                	ld	s8,64(sp)
    80000780:	7ce2                	ld	s9,56(sp)
    80000782:	7d42                	ld	s10,48(sp)
    80000784:	7da2                	ld	s11,40(sp)
    release(&pr.lock);
    80000786:	0000f517          	auipc	a0,0xf
    8000078a:	40250513          	addi	a0,a0,1026 # 8000fb88 <pr>
    8000078e:	4fe000ef          	jal	80000c8c <release>
    80000792:	bfd9                	j	80000768 <printf+0x2a6>

0000000080000794 <panic>:

void
panic(char *s)
{
    80000794:	1101                	addi	sp,sp,-32
    80000796:	ec06                	sd	ra,24(sp)
    80000798:	e822                	sd	s0,16(sp)
    8000079a:	e426                	sd	s1,8(sp)
    8000079c:	1000                	addi	s0,sp,32
    8000079e:	84aa                	mv	s1,a0
  pr.locking = 0;
    800007a0:	0000f797          	auipc	a5,0xf
    800007a4:	4007a023          	sw	zero,1024(a5) # 8000fba0 <pr+0x18>
  printf("panic: ");
    800007a8:	00007517          	auipc	a0,0x7
    800007ac:	87050513          	addi	a0,a0,-1936 # 80007018 <etext+0x18>
    800007b0:	d13ff0ef          	jal	800004c2 <printf>
  printf("%s\n", s);
    800007b4:	85a6                	mv	a1,s1
    800007b6:	00007517          	auipc	a0,0x7
    800007ba:	86a50513          	addi	a0,a0,-1942 # 80007020 <etext+0x20>
    800007be:	d05ff0ef          	jal	800004c2 <printf>
  panicked = 1; // freeze uart output from other CPUs
    800007c2:	4785                	li	a5,1
    800007c4:	00007717          	auipc	a4,0x7
    800007c8:	2cf72e23          	sw	a5,732(a4) # 80007aa0 <panicked>
  for(;;)
    800007cc:	a001                	j	800007cc <panic+0x38>

00000000800007ce <printfinit>:
    ;
}

void
printfinit(void)
{
    800007ce:	1101                	addi	sp,sp,-32
    800007d0:	ec06                	sd	ra,24(sp)
    800007d2:	e822                	sd	s0,16(sp)
    800007d4:	e426                	sd	s1,8(sp)
    800007d6:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    800007d8:	0000f497          	auipc	s1,0xf
    800007dc:	3b048493          	addi	s1,s1,944 # 8000fb88 <pr>
    800007e0:	00007597          	auipc	a1,0x7
    800007e4:	84858593          	addi	a1,a1,-1976 # 80007028 <etext+0x28>
    800007e8:	8526                	mv	a0,s1
    800007ea:	38a000ef          	jal	80000b74 <initlock>
  pr.locking = 1;
    800007ee:	4785                	li	a5,1
    800007f0:	cc9c                	sw	a5,24(s1)
}
    800007f2:	60e2                	ld	ra,24(sp)
    800007f4:	6442                	ld	s0,16(sp)
    800007f6:	64a2                	ld	s1,8(sp)
    800007f8:	6105                	addi	sp,sp,32
    800007fa:	8082                	ret

00000000800007fc <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007fc:	1141                	addi	sp,sp,-16
    800007fe:	e406                	sd	ra,8(sp)
    80000800:	e022                	sd	s0,0(sp)
    80000802:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000804:	100007b7          	lui	a5,0x10000
    80000808:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    8000080c:	10000737          	lui	a4,0x10000
    80000810:	f8000693          	li	a3,-128
    80000814:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000818:	468d                	li	a3,3
    8000081a:	10000637          	lui	a2,0x10000
    8000081e:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000822:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80000826:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000082a:	10000737          	lui	a4,0x10000
    8000082e:	461d                	li	a2,7
    80000830:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000834:	00d780a3          	sb	a3,1(a5)

  initlock(&uart_tx_lock, "uart");
    80000838:	00006597          	auipc	a1,0x6
    8000083c:	7f858593          	addi	a1,a1,2040 # 80007030 <etext+0x30>
    80000840:	0000f517          	auipc	a0,0xf
    80000844:	36850513          	addi	a0,a0,872 # 8000fba8 <uart_tx_lock>
    80000848:	32c000ef          	jal	80000b74 <initlock>
}
    8000084c:	60a2                	ld	ra,8(sp)
    8000084e:	6402                	ld	s0,0(sp)
    80000850:	0141                	addi	sp,sp,16
    80000852:	8082                	ret

0000000080000854 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000854:	1101                	addi	sp,sp,-32
    80000856:	ec06                	sd	ra,24(sp)
    80000858:	e822                	sd	s0,16(sp)
    8000085a:	e426                	sd	s1,8(sp)
    8000085c:	1000                	addi	s0,sp,32
    8000085e:	84aa                	mv	s1,a0
  push_off();
    80000860:	354000ef          	jal	80000bb4 <push_off>

  if(panicked){
    80000864:	00007797          	auipc	a5,0x7
    80000868:	23c7a783          	lw	a5,572(a5) # 80007aa0 <panicked>
    8000086c:	e795                	bnez	a5,80000898 <uartputc_sync+0x44>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000086e:	10000737          	lui	a4,0x10000
    80000872:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000874:	00074783          	lbu	a5,0(a4)
    80000878:	0207f793          	andi	a5,a5,32
    8000087c:	dfe5                	beqz	a5,80000874 <uartputc_sync+0x20>
    ;
  WriteReg(THR, c);
    8000087e:	0ff4f513          	zext.b	a0,s1
    80000882:	100007b7          	lui	a5,0x10000
    80000886:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    8000088a:	3ae000ef          	jal	80000c38 <pop_off>
}
    8000088e:	60e2                	ld	ra,24(sp)
    80000890:	6442                	ld	s0,16(sp)
    80000892:	64a2                	ld	s1,8(sp)
    80000894:	6105                	addi	sp,sp,32
    80000896:	8082                	ret
    for(;;)
    80000898:	a001                	j	80000898 <uartputc_sync+0x44>

000000008000089a <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000089a:	00007797          	auipc	a5,0x7
    8000089e:	20e7b783          	ld	a5,526(a5) # 80007aa8 <uart_tx_r>
    800008a2:	00007717          	auipc	a4,0x7
    800008a6:	20e73703          	ld	a4,526(a4) # 80007ab0 <uart_tx_w>
    800008aa:	08f70263          	beq	a4,a5,8000092e <uartstart+0x94>
{
    800008ae:	7139                	addi	sp,sp,-64
    800008b0:	fc06                	sd	ra,56(sp)
    800008b2:	f822                	sd	s0,48(sp)
    800008b4:	f426                	sd	s1,40(sp)
    800008b6:	f04a                	sd	s2,32(sp)
    800008b8:	ec4e                	sd	s3,24(sp)
    800008ba:	e852                	sd	s4,16(sp)
    800008bc:	e456                	sd	s5,8(sp)
    800008be:	e05a                	sd	s6,0(sp)
    800008c0:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      ReadReg(ISR);
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008c2:	10000937          	lui	s2,0x10000
    800008c6:	0915                	addi	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008c8:	0000fa97          	auipc	s5,0xf
    800008cc:	2e0a8a93          	addi	s5,s5,736 # 8000fba8 <uart_tx_lock>
    uart_tx_r += 1;
    800008d0:	00007497          	auipc	s1,0x7
    800008d4:	1d848493          	addi	s1,s1,472 # 80007aa8 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008d8:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008dc:	00007997          	auipc	s3,0x7
    800008e0:	1d498993          	addi	s3,s3,468 # 80007ab0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008e4:	00094703          	lbu	a4,0(s2)
    800008e8:	02077713          	andi	a4,a4,32
    800008ec:	c71d                	beqz	a4,8000091a <uartstart+0x80>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008ee:	01f7f713          	andi	a4,a5,31
    800008f2:	9756                	add	a4,a4,s5
    800008f4:	01874b03          	lbu	s6,24(a4)
    uart_tx_r += 1;
    800008f8:	0785                	addi	a5,a5,1
    800008fa:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    800008fc:	8526                	mv	a0,s1
    800008fe:	165010ef          	jal	80002262 <wakeup>
    WriteReg(THR, c);
    80000902:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    80000906:	609c                	ld	a5,0(s1)
    80000908:	0009b703          	ld	a4,0(s3)
    8000090c:	fcf71ce3          	bne	a4,a5,800008e4 <uartstart+0x4a>
      ReadReg(ISR);
    80000910:	100007b7          	lui	a5,0x10000
    80000914:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80000916:	0007c783          	lbu	a5,0(a5)
  }
}
    8000091a:	70e2                	ld	ra,56(sp)
    8000091c:	7442                	ld	s0,48(sp)
    8000091e:	74a2                	ld	s1,40(sp)
    80000920:	7902                	ld	s2,32(sp)
    80000922:	69e2                	ld	s3,24(sp)
    80000924:	6a42                	ld	s4,16(sp)
    80000926:	6aa2                	ld	s5,8(sp)
    80000928:	6b02                	ld	s6,0(sp)
    8000092a:	6121                	addi	sp,sp,64
    8000092c:	8082                	ret
      ReadReg(ISR);
    8000092e:	100007b7          	lui	a5,0x10000
    80000932:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80000934:	0007c783          	lbu	a5,0(a5)
      return;
    80000938:	8082                	ret

000000008000093a <uartputc>:
{
    8000093a:	7179                	addi	sp,sp,-48
    8000093c:	f406                	sd	ra,40(sp)
    8000093e:	f022                	sd	s0,32(sp)
    80000940:	ec26                	sd	s1,24(sp)
    80000942:	e84a                	sd	s2,16(sp)
    80000944:	e44e                	sd	s3,8(sp)
    80000946:	e052                	sd	s4,0(sp)
    80000948:	1800                	addi	s0,sp,48
    8000094a:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    8000094c:	0000f517          	auipc	a0,0xf
    80000950:	25c50513          	addi	a0,a0,604 # 8000fba8 <uart_tx_lock>
    80000954:	2a0000ef          	jal	80000bf4 <acquire>
  if(panicked){
    80000958:	00007797          	auipc	a5,0x7
    8000095c:	1487a783          	lw	a5,328(a5) # 80007aa0 <panicked>
    80000960:	efbd                	bnez	a5,800009de <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000962:	00007717          	auipc	a4,0x7
    80000966:	14e73703          	ld	a4,334(a4) # 80007ab0 <uart_tx_w>
    8000096a:	00007797          	auipc	a5,0x7
    8000096e:	13e7b783          	ld	a5,318(a5) # 80007aa8 <uart_tx_r>
    80000972:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000976:	0000f997          	auipc	s3,0xf
    8000097a:	23298993          	addi	s3,s3,562 # 8000fba8 <uart_tx_lock>
    8000097e:	00007497          	auipc	s1,0x7
    80000982:	12a48493          	addi	s1,s1,298 # 80007aa8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000986:	00007917          	auipc	s2,0x7
    8000098a:	12a90913          	addi	s2,s2,298 # 80007ab0 <uart_tx_w>
    8000098e:	00e79d63          	bne	a5,a4,800009a8 <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000992:	85ce                	mv	a1,s3
    80000994:	8526                	mv	a0,s1
    80000996:	081010ef          	jal	80002216 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000099a:	00093703          	ld	a4,0(s2)
    8000099e:	609c                	ld	a5,0(s1)
    800009a0:	02078793          	addi	a5,a5,32
    800009a4:	fee787e3          	beq	a5,a4,80000992 <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800009a8:	0000f497          	auipc	s1,0xf
    800009ac:	20048493          	addi	s1,s1,512 # 8000fba8 <uart_tx_lock>
    800009b0:	01f77793          	andi	a5,a4,31
    800009b4:	97a6                	add	a5,a5,s1
    800009b6:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009ba:	0705                	addi	a4,a4,1
    800009bc:	00007797          	auipc	a5,0x7
    800009c0:	0ee7ba23          	sd	a4,244(a5) # 80007ab0 <uart_tx_w>
  uartstart();
    800009c4:	ed7ff0ef          	jal	8000089a <uartstart>
  release(&uart_tx_lock);
    800009c8:	8526                	mv	a0,s1
    800009ca:	2c2000ef          	jal	80000c8c <release>
}
    800009ce:	70a2                	ld	ra,40(sp)
    800009d0:	7402                	ld	s0,32(sp)
    800009d2:	64e2                	ld	s1,24(sp)
    800009d4:	6942                	ld	s2,16(sp)
    800009d6:	69a2                	ld	s3,8(sp)
    800009d8:	6a02                	ld	s4,0(sp)
    800009da:	6145                	addi	sp,sp,48
    800009dc:	8082                	ret
    for(;;)
    800009de:	a001                	j	800009de <uartputc+0xa4>

00000000800009e0 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009e0:	1141                	addi	sp,sp,-16
    800009e2:	e422                	sd	s0,8(sp)
    800009e4:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009e6:	100007b7          	lui	a5,0x10000
    800009ea:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009ec:	0007c783          	lbu	a5,0(a5)
    800009f0:	8b85                	andi	a5,a5,1
    800009f2:	cb81                	beqz	a5,80000a02 <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    800009f4:	100007b7          	lui	a5,0x10000
    800009f8:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009fc:	6422                	ld	s0,8(sp)
    800009fe:	0141                	addi	sp,sp,16
    80000a00:	8082                	ret
    return -1;
    80000a02:	557d                	li	a0,-1
    80000a04:	bfe5                	j	800009fc <uartgetc+0x1c>

0000000080000a06 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000a06:	1101                	addi	sp,sp,-32
    80000a08:	ec06                	sd	ra,24(sp)
    80000a0a:	e822                	sd	s0,16(sp)
    80000a0c:	e426                	sd	s1,8(sp)
    80000a0e:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a10:	54fd                	li	s1,-1
    80000a12:	a019                	j	80000a18 <uartintr+0x12>
      break;
    consoleintr(c);
    80000a14:	85fff0ef          	jal	80000272 <consoleintr>
    int c = uartgetc();
    80000a18:	fc9ff0ef          	jal	800009e0 <uartgetc>
    if(c == -1)
    80000a1c:	fe951ce3          	bne	a0,s1,80000a14 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a20:	0000f497          	auipc	s1,0xf
    80000a24:	18848493          	addi	s1,s1,392 # 8000fba8 <uart_tx_lock>
    80000a28:	8526                	mv	a0,s1
    80000a2a:	1ca000ef          	jal	80000bf4 <acquire>
  uartstart();
    80000a2e:	e6dff0ef          	jal	8000089a <uartstart>
  release(&uart_tx_lock);
    80000a32:	8526                	mv	a0,s1
    80000a34:	258000ef          	jal	80000c8c <release>
}
    80000a38:	60e2                	ld	ra,24(sp)
    80000a3a:	6442                	ld	s0,16(sp)
    80000a3c:	64a2                	ld	s1,8(sp)
    80000a3e:	6105                	addi	sp,sp,32
    80000a40:	8082                	ret

0000000080000a42 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a42:	1101                	addi	sp,sp,-32
    80000a44:	ec06                	sd	ra,24(sp)
    80000a46:	e822                	sd	s0,16(sp)
    80000a48:	e426                	sd	s1,8(sp)
    80000a4a:	e04a                	sd	s2,0(sp)
    80000a4c:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a4e:	03451793          	slli	a5,a0,0x34
    80000a52:	e7a9                	bnez	a5,80000a9c <kfree+0x5a>
    80000a54:	84aa                	mv	s1,a0
    80000a56:	00022797          	auipc	a5,0x22
    80000a5a:	5ba78793          	addi	a5,a5,1466 # 80023010 <end>
    80000a5e:	02f56f63          	bltu	a0,a5,80000a9c <kfree+0x5a>
    80000a62:	47c5                	li	a5,17
    80000a64:	07ee                	slli	a5,a5,0x1b
    80000a66:	02f57b63          	bgeu	a0,a5,80000a9c <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a6a:	6605                	lui	a2,0x1
    80000a6c:	4585                	li	a1,1
    80000a6e:	25a000ef          	jal	80000cc8 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a72:	0000f917          	auipc	s2,0xf
    80000a76:	16e90913          	addi	s2,s2,366 # 8000fbe0 <kmem>
    80000a7a:	854a                	mv	a0,s2
    80000a7c:	178000ef          	jal	80000bf4 <acquire>
  r->next = kmem.freelist;
    80000a80:	01893783          	ld	a5,24(s2)
    80000a84:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a86:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a8a:	854a                	mv	a0,s2
    80000a8c:	200000ef          	jal	80000c8c <release>
}
    80000a90:	60e2                	ld	ra,24(sp)
    80000a92:	6442                	ld	s0,16(sp)
    80000a94:	64a2                	ld	s1,8(sp)
    80000a96:	6902                	ld	s2,0(sp)
    80000a98:	6105                	addi	sp,sp,32
    80000a9a:	8082                	ret
    panic("kfree");
    80000a9c:	00006517          	auipc	a0,0x6
    80000aa0:	59c50513          	addi	a0,a0,1436 # 80007038 <etext+0x38>
    80000aa4:	cf1ff0ef          	jal	80000794 <panic>

0000000080000aa8 <freerange>:
{
    80000aa8:	7179                	addi	sp,sp,-48
    80000aaa:	f406                	sd	ra,40(sp)
    80000aac:	f022                	sd	s0,32(sp)
    80000aae:	ec26                	sd	s1,24(sp)
    80000ab0:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000ab2:	6785                	lui	a5,0x1
    80000ab4:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ab8:	00e504b3          	add	s1,a0,a4
    80000abc:	777d                	lui	a4,0xfffff
    80000abe:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ac0:	94be                	add	s1,s1,a5
    80000ac2:	0295e263          	bltu	a1,s1,80000ae6 <freerange+0x3e>
    80000ac6:	e84a                	sd	s2,16(sp)
    80000ac8:	e44e                	sd	s3,8(sp)
    80000aca:	e052                	sd	s4,0(sp)
    80000acc:	892e                	mv	s2,a1
    kfree(p);
    80000ace:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ad0:	6985                	lui	s3,0x1
    kfree(p);
    80000ad2:	01448533          	add	a0,s1,s4
    80000ad6:	f6dff0ef          	jal	80000a42 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ada:	94ce                	add	s1,s1,s3
    80000adc:	fe997be3          	bgeu	s2,s1,80000ad2 <freerange+0x2a>
    80000ae0:	6942                	ld	s2,16(sp)
    80000ae2:	69a2                	ld	s3,8(sp)
    80000ae4:	6a02                	ld	s4,0(sp)
}
    80000ae6:	70a2                	ld	ra,40(sp)
    80000ae8:	7402                	ld	s0,32(sp)
    80000aea:	64e2                	ld	s1,24(sp)
    80000aec:	6145                	addi	sp,sp,48
    80000aee:	8082                	ret

0000000080000af0 <kinit>:
{
    80000af0:	1141                	addi	sp,sp,-16
    80000af2:	e406                	sd	ra,8(sp)
    80000af4:	e022                	sd	s0,0(sp)
    80000af6:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000af8:	00006597          	auipc	a1,0x6
    80000afc:	54858593          	addi	a1,a1,1352 # 80007040 <etext+0x40>
    80000b00:	0000f517          	auipc	a0,0xf
    80000b04:	0e050513          	addi	a0,a0,224 # 8000fbe0 <kmem>
    80000b08:	06c000ef          	jal	80000b74 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b0c:	45c5                	li	a1,17
    80000b0e:	05ee                	slli	a1,a1,0x1b
    80000b10:	00022517          	auipc	a0,0x22
    80000b14:	50050513          	addi	a0,a0,1280 # 80023010 <end>
    80000b18:	f91ff0ef          	jal	80000aa8 <freerange>
}
    80000b1c:	60a2                	ld	ra,8(sp)
    80000b1e:	6402                	ld	s0,0(sp)
    80000b20:	0141                	addi	sp,sp,16
    80000b22:	8082                	ret

0000000080000b24 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b24:	1101                	addi	sp,sp,-32
    80000b26:	ec06                	sd	ra,24(sp)
    80000b28:	e822                	sd	s0,16(sp)
    80000b2a:	e426                	sd	s1,8(sp)
    80000b2c:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b2e:	0000f497          	auipc	s1,0xf
    80000b32:	0b248493          	addi	s1,s1,178 # 8000fbe0 <kmem>
    80000b36:	8526                	mv	a0,s1
    80000b38:	0bc000ef          	jal	80000bf4 <acquire>
  r = kmem.freelist;
    80000b3c:	6c84                	ld	s1,24(s1)
  if(r)
    80000b3e:	c485                	beqz	s1,80000b66 <kalloc+0x42>
    kmem.freelist = r->next;
    80000b40:	609c                	ld	a5,0(s1)
    80000b42:	0000f517          	auipc	a0,0xf
    80000b46:	09e50513          	addi	a0,a0,158 # 8000fbe0 <kmem>
    80000b4a:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b4c:	140000ef          	jal	80000c8c <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b50:	6605                	lui	a2,0x1
    80000b52:	4595                	li	a1,5
    80000b54:	8526                	mv	a0,s1
    80000b56:	172000ef          	jal	80000cc8 <memset>
  return (void*)r;
}
    80000b5a:	8526                	mv	a0,s1
    80000b5c:	60e2                	ld	ra,24(sp)
    80000b5e:	6442                	ld	s0,16(sp)
    80000b60:	64a2                	ld	s1,8(sp)
    80000b62:	6105                	addi	sp,sp,32
    80000b64:	8082                	ret
  release(&kmem.lock);
    80000b66:	0000f517          	auipc	a0,0xf
    80000b6a:	07a50513          	addi	a0,a0,122 # 8000fbe0 <kmem>
    80000b6e:	11e000ef          	jal	80000c8c <release>
  if(r)
    80000b72:	b7e5                	j	80000b5a <kalloc+0x36>

0000000080000b74 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b74:	1141                	addi	sp,sp,-16
    80000b76:	e422                	sd	s0,8(sp)
    80000b78:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b7a:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b7c:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b80:	00053823          	sd	zero,16(a0)
}
    80000b84:	6422                	ld	s0,8(sp)
    80000b86:	0141                	addi	sp,sp,16
    80000b88:	8082                	ret

0000000080000b8a <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b8a:	411c                	lw	a5,0(a0)
    80000b8c:	e399                	bnez	a5,80000b92 <holding+0x8>
    80000b8e:	4501                	li	a0,0
  return r;
}
    80000b90:	8082                	ret
{
    80000b92:	1101                	addi	sp,sp,-32
    80000b94:	ec06                	sd	ra,24(sp)
    80000b96:	e822                	sd	s0,16(sp)
    80000b98:	e426                	sd	s1,8(sp)
    80000b9a:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b9c:	6904                	ld	s1,16(a0)
    80000b9e:	549000ef          	jal	800018e6 <mycpu>
    80000ba2:	40a48533          	sub	a0,s1,a0
    80000ba6:	00153513          	seqz	a0,a0
}
    80000baa:	60e2                	ld	ra,24(sp)
    80000bac:	6442                	ld	s0,16(sp)
    80000bae:	64a2                	ld	s1,8(sp)
    80000bb0:	6105                	addi	sp,sp,32
    80000bb2:	8082                	ret

0000000080000bb4 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bb4:	1101                	addi	sp,sp,-32
    80000bb6:	ec06                	sd	ra,24(sp)
    80000bb8:	e822                	sd	s0,16(sp)
    80000bba:	e426                	sd	s1,8(sp)
    80000bbc:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bbe:	100024f3          	csrr	s1,sstatus
    80000bc2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bc6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bc8:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000bcc:	51b000ef          	jal	800018e6 <mycpu>
    80000bd0:	5d3c                	lw	a5,120(a0)
    80000bd2:	cb99                	beqz	a5,80000be8 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bd4:	513000ef          	jal	800018e6 <mycpu>
    80000bd8:	5d3c                	lw	a5,120(a0)
    80000bda:	2785                	addiw	a5,a5,1
    80000bdc:	dd3c                	sw	a5,120(a0)
}
    80000bde:	60e2                	ld	ra,24(sp)
    80000be0:	6442                	ld	s0,16(sp)
    80000be2:	64a2                	ld	s1,8(sp)
    80000be4:	6105                	addi	sp,sp,32
    80000be6:	8082                	ret
    mycpu()->intena = old;
    80000be8:	4ff000ef          	jal	800018e6 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bec:	8085                	srli	s1,s1,0x1
    80000bee:	8885                	andi	s1,s1,1
    80000bf0:	dd64                	sw	s1,124(a0)
    80000bf2:	b7cd                	j	80000bd4 <push_off+0x20>

0000000080000bf4 <acquire>:
{
    80000bf4:	1101                	addi	sp,sp,-32
    80000bf6:	ec06                	sd	ra,24(sp)
    80000bf8:	e822                	sd	s0,16(sp)
    80000bfa:	e426                	sd	s1,8(sp)
    80000bfc:	1000                	addi	s0,sp,32
    80000bfe:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c00:	fb5ff0ef          	jal	80000bb4 <push_off>
  if(holding(lk))
    80000c04:	8526                	mv	a0,s1
    80000c06:	f85ff0ef          	jal	80000b8a <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c0a:	4705                	li	a4,1
  if(holding(lk))
    80000c0c:	e105                	bnez	a0,80000c2c <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c0e:	87ba                	mv	a5,a4
    80000c10:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c14:	2781                	sext.w	a5,a5
    80000c16:	ffe5                	bnez	a5,80000c0e <acquire+0x1a>
  __sync_synchronize();
    80000c18:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c1c:	4cb000ef          	jal	800018e6 <mycpu>
    80000c20:	e888                	sd	a0,16(s1)
}
    80000c22:	60e2                	ld	ra,24(sp)
    80000c24:	6442                	ld	s0,16(sp)
    80000c26:	64a2                	ld	s1,8(sp)
    80000c28:	6105                	addi	sp,sp,32
    80000c2a:	8082                	ret
    panic("acquire");
    80000c2c:	00006517          	auipc	a0,0x6
    80000c30:	41c50513          	addi	a0,a0,1052 # 80007048 <etext+0x48>
    80000c34:	b61ff0ef          	jal	80000794 <panic>

0000000080000c38 <pop_off>:

void
pop_off(void)
{
    80000c38:	1141                	addi	sp,sp,-16
    80000c3a:	e406                	sd	ra,8(sp)
    80000c3c:	e022                	sd	s0,0(sp)
    80000c3e:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c40:	4a7000ef          	jal	800018e6 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c44:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c48:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c4a:	e78d                	bnez	a5,80000c74 <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c4c:	5d3c                	lw	a5,120(a0)
    80000c4e:	02f05963          	blez	a5,80000c80 <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80000c52:	37fd                	addiw	a5,a5,-1
    80000c54:	0007871b          	sext.w	a4,a5
    80000c58:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c5a:	eb09                	bnez	a4,80000c6c <pop_off+0x34>
    80000c5c:	5d7c                	lw	a5,124(a0)
    80000c5e:	c799                	beqz	a5,80000c6c <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c60:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c64:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c68:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c6c:	60a2                	ld	ra,8(sp)
    80000c6e:	6402                	ld	s0,0(sp)
    80000c70:	0141                	addi	sp,sp,16
    80000c72:	8082                	ret
    panic("pop_off - interruptible");
    80000c74:	00006517          	auipc	a0,0x6
    80000c78:	3dc50513          	addi	a0,a0,988 # 80007050 <etext+0x50>
    80000c7c:	b19ff0ef          	jal	80000794 <panic>
    panic("pop_off");
    80000c80:	00006517          	auipc	a0,0x6
    80000c84:	3e850513          	addi	a0,a0,1000 # 80007068 <etext+0x68>
    80000c88:	b0dff0ef          	jal	80000794 <panic>

0000000080000c8c <release>:
{
    80000c8c:	1101                	addi	sp,sp,-32
    80000c8e:	ec06                	sd	ra,24(sp)
    80000c90:	e822                	sd	s0,16(sp)
    80000c92:	e426                	sd	s1,8(sp)
    80000c94:	1000                	addi	s0,sp,32
    80000c96:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c98:	ef3ff0ef          	jal	80000b8a <holding>
    80000c9c:	c105                	beqz	a0,80000cbc <release+0x30>
  lk->cpu = 0;
    80000c9e:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca2:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca6:	0f50000f          	fence	iorw,ow
    80000caa:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cae:	f8bff0ef          	jal	80000c38 <pop_off>
}
    80000cb2:	60e2                	ld	ra,24(sp)
    80000cb4:	6442                	ld	s0,16(sp)
    80000cb6:	64a2                	ld	s1,8(sp)
    80000cb8:	6105                	addi	sp,sp,32
    80000cba:	8082                	ret
    panic("release");
    80000cbc:	00006517          	auipc	a0,0x6
    80000cc0:	3b450513          	addi	a0,a0,948 # 80007070 <etext+0x70>
    80000cc4:	ad1ff0ef          	jal	80000794 <panic>

0000000080000cc8 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cc8:	1141                	addi	sp,sp,-16
    80000cca:	e422                	sd	s0,8(sp)
    80000ccc:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cce:	ca19                	beqz	a2,80000ce4 <memset+0x1c>
    80000cd0:	87aa                	mv	a5,a0
    80000cd2:	1602                	slli	a2,a2,0x20
    80000cd4:	9201                	srli	a2,a2,0x20
    80000cd6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cda:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cde:	0785                	addi	a5,a5,1
    80000ce0:	fee79de3          	bne	a5,a4,80000cda <memset+0x12>
  }
  return dst;
}
    80000ce4:	6422                	ld	s0,8(sp)
    80000ce6:	0141                	addi	sp,sp,16
    80000ce8:	8082                	ret

0000000080000cea <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cea:	1141                	addi	sp,sp,-16
    80000cec:	e422                	sd	s0,8(sp)
    80000cee:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cf0:	ca05                	beqz	a2,80000d20 <memcmp+0x36>
    80000cf2:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000cf6:	1682                	slli	a3,a3,0x20
    80000cf8:	9281                	srli	a3,a3,0x20
    80000cfa:	0685                	addi	a3,a3,1
    80000cfc:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000cfe:	00054783          	lbu	a5,0(a0)
    80000d02:	0005c703          	lbu	a4,0(a1)
    80000d06:	00e79863          	bne	a5,a4,80000d16 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d0a:	0505                	addi	a0,a0,1
    80000d0c:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d0e:	fed518e3          	bne	a0,a3,80000cfe <memcmp+0x14>
  }

  return 0;
    80000d12:	4501                	li	a0,0
    80000d14:	a019                	j	80000d1a <memcmp+0x30>
      return *s1 - *s2;
    80000d16:	40e7853b          	subw	a0,a5,a4
}
    80000d1a:	6422                	ld	s0,8(sp)
    80000d1c:	0141                	addi	sp,sp,16
    80000d1e:	8082                	ret
  return 0;
    80000d20:	4501                	li	a0,0
    80000d22:	bfe5                	j	80000d1a <memcmp+0x30>

0000000080000d24 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d24:	1141                	addi	sp,sp,-16
    80000d26:	e422                	sd	s0,8(sp)
    80000d28:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d2a:	c205                	beqz	a2,80000d4a <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d2c:	02a5e263          	bltu	a1,a0,80000d50 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d30:	1602                	slli	a2,a2,0x20
    80000d32:	9201                	srli	a2,a2,0x20
    80000d34:	00c587b3          	add	a5,a1,a2
{
    80000d38:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d3a:	0585                	addi	a1,a1,1
    80000d3c:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdbff1>
    80000d3e:	fff5c683          	lbu	a3,-1(a1)
    80000d42:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d46:	feb79ae3          	bne	a5,a1,80000d3a <memmove+0x16>

  return dst;
}
    80000d4a:	6422                	ld	s0,8(sp)
    80000d4c:	0141                	addi	sp,sp,16
    80000d4e:	8082                	ret
  if(s < d && s + n > d){
    80000d50:	02061693          	slli	a3,a2,0x20
    80000d54:	9281                	srli	a3,a3,0x20
    80000d56:	00d58733          	add	a4,a1,a3
    80000d5a:	fce57be3          	bgeu	a0,a4,80000d30 <memmove+0xc>
    d += n;
    80000d5e:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d60:	fff6079b          	addiw	a5,a2,-1
    80000d64:	1782                	slli	a5,a5,0x20
    80000d66:	9381                	srli	a5,a5,0x20
    80000d68:	fff7c793          	not	a5,a5
    80000d6c:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d6e:	177d                	addi	a4,a4,-1
    80000d70:	16fd                	addi	a3,a3,-1
    80000d72:	00074603          	lbu	a2,0(a4)
    80000d76:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d7a:	fef71ae3          	bne	a4,a5,80000d6e <memmove+0x4a>
    80000d7e:	b7f1                	j	80000d4a <memmove+0x26>

0000000080000d80 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d80:	1141                	addi	sp,sp,-16
    80000d82:	e406                	sd	ra,8(sp)
    80000d84:	e022                	sd	s0,0(sp)
    80000d86:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d88:	f9dff0ef          	jal	80000d24 <memmove>
}
    80000d8c:	60a2                	ld	ra,8(sp)
    80000d8e:	6402                	ld	s0,0(sp)
    80000d90:	0141                	addi	sp,sp,16
    80000d92:	8082                	ret

0000000080000d94 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d94:	1141                	addi	sp,sp,-16
    80000d96:	e422                	sd	s0,8(sp)
    80000d98:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000d9a:	ce11                	beqz	a2,80000db6 <strncmp+0x22>
    80000d9c:	00054783          	lbu	a5,0(a0)
    80000da0:	cf89                	beqz	a5,80000dba <strncmp+0x26>
    80000da2:	0005c703          	lbu	a4,0(a1)
    80000da6:	00f71a63          	bne	a4,a5,80000dba <strncmp+0x26>
    n--, p++, q++;
    80000daa:	367d                	addiw	a2,a2,-1
    80000dac:	0505                	addi	a0,a0,1
    80000dae:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000db0:	f675                	bnez	a2,80000d9c <strncmp+0x8>
  if(n == 0)
    return 0;
    80000db2:	4501                	li	a0,0
    80000db4:	a801                	j	80000dc4 <strncmp+0x30>
    80000db6:	4501                	li	a0,0
    80000db8:	a031                	j	80000dc4 <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000dba:	00054503          	lbu	a0,0(a0)
    80000dbe:	0005c783          	lbu	a5,0(a1)
    80000dc2:	9d1d                	subw	a0,a0,a5
}
    80000dc4:	6422                	ld	s0,8(sp)
    80000dc6:	0141                	addi	sp,sp,16
    80000dc8:	8082                	ret

0000000080000dca <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dca:	1141                	addi	sp,sp,-16
    80000dcc:	e422                	sd	s0,8(sp)
    80000dce:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000dd0:	87aa                	mv	a5,a0
    80000dd2:	86b2                	mv	a3,a2
    80000dd4:	367d                	addiw	a2,a2,-1
    80000dd6:	02d05563          	blez	a3,80000e00 <strncpy+0x36>
    80000dda:	0785                	addi	a5,a5,1
    80000ddc:	0005c703          	lbu	a4,0(a1)
    80000de0:	fee78fa3          	sb	a4,-1(a5)
    80000de4:	0585                	addi	a1,a1,1
    80000de6:	f775                	bnez	a4,80000dd2 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000de8:	873e                	mv	a4,a5
    80000dea:	9fb5                	addw	a5,a5,a3
    80000dec:	37fd                	addiw	a5,a5,-1
    80000dee:	00c05963          	blez	a2,80000e00 <strncpy+0x36>
    *s++ = 0;
    80000df2:	0705                	addi	a4,a4,1
    80000df4:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000df8:	40e786bb          	subw	a3,a5,a4
    80000dfc:	fed04be3          	bgtz	a3,80000df2 <strncpy+0x28>
  return os;
}
    80000e00:	6422                	ld	s0,8(sp)
    80000e02:	0141                	addi	sp,sp,16
    80000e04:	8082                	ret

0000000080000e06 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e06:	1141                	addi	sp,sp,-16
    80000e08:	e422                	sd	s0,8(sp)
    80000e0a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e0c:	02c05363          	blez	a2,80000e32 <safestrcpy+0x2c>
    80000e10:	fff6069b          	addiw	a3,a2,-1
    80000e14:	1682                	slli	a3,a3,0x20
    80000e16:	9281                	srli	a3,a3,0x20
    80000e18:	96ae                	add	a3,a3,a1
    80000e1a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e1c:	00d58963          	beq	a1,a3,80000e2e <safestrcpy+0x28>
    80000e20:	0585                	addi	a1,a1,1
    80000e22:	0785                	addi	a5,a5,1
    80000e24:	fff5c703          	lbu	a4,-1(a1)
    80000e28:	fee78fa3          	sb	a4,-1(a5)
    80000e2c:	fb65                	bnez	a4,80000e1c <safestrcpy+0x16>
    ;
  *s = 0;
    80000e2e:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e32:	6422                	ld	s0,8(sp)
    80000e34:	0141                	addi	sp,sp,16
    80000e36:	8082                	ret

0000000080000e38 <strlen>:

int
strlen(const char *s)
{
    80000e38:	1141                	addi	sp,sp,-16
    80000e3a:	e422                	sd	s0,8(sp)
    80000e3c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e3e:	00054783          	lbu	a5,0(a0)
    80000e42:	cf91                	beqz	a5,80000e5e <strlen+0x26>
    80000e44:	0505                	addi	a0,a0,1
    80000e46:	87aa                	mv	a5,a0
    80000e48:	86be                	mv	a3,a5
    80000e4a:	0785                	addi	a5,a5,1
    80000e4c:	fff7c703          	lbu	a4,-1(a5)
    80000e50:	ff65                	bnez	a4,80000e48 <strlen+0x10>
    80000e52:	40a6853b          	subw	a0,a3,a0
    80000e56:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000e58:	6422                	ld	s0,8(sp)
    80000e5a:	0141                	addi	sp,sp,16
    80000e5c:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e5e:	4501                	li	a0,0
    80000e60:	bfe5                	j	80000e58 <strlen+0x20>

0000000080000e62 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e62:	1141                	addi	sp,sp,-16
    80000e64:	e406                	sd	ra,8(sp)
    80000e66:	e022                	sd	s0,0(sp)
    80000e68:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e6a:	26d000ef          	jal	800018d6 <cpuid>
     log_message(ERROR, "This is a test error message for the custom logger");
     
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e6e:	00007717          	auipc	a4,0x7
    80000e72:	c4a70713          	addi	a4,a4,-950 # 80007ab8 <started>
  if(cpuid() == 0){
    80000e76:	c51d                	beqz	a0,80000ea4 <main+0x42>
    while(started == 0)
    80000e78:	431c                	lw	a5,0(a4)
    80000e7a:	2781                	sext.w	a5,a5
    80000e7c:	dff5                	beqz	a5,80000e78 <main+0x16>
      ;
    __sync_synchronize();
    80000e7e:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e82:	255000ef          	jal	800018d6 <cpuid>
    80000e86:	85aa                	mv	a1,a0
    80000e88:	00006517          	auipc	a0,0x6
    80000e8c:	30850513          	addi	a0,a0,776 # 80007190 <etext+0x190>
    80000e90:	e32ff0ef          	jal	800004c2 <printf>
    kvminithart();    // turn on paging
    80000e94:	0aa000ef          	jal	80000f3e <kvminithart>
    trapinithart();   // install kernel trap vector
    80000e98:	107010ef          	jal	8000279e <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e9c:	10d040ef          	jal	800057a8 <plicinithart>
  }

  scheduler();        
    80000ea0:	15c010ef          	jal	80001ffc <scheduler>
    consoleinit();
    80000ea4:	d48ff0ef          	jal	800003ec <consoleinit>
    printfinit();
    80000ea8:	927ff0ef          	jal	800007ce <printfinit>
    printf("\n");
    80000eac:	00006517          	auipc	a0,0x6
    80000eb0:	1cc50513          	addi	a0,a0,460 # 80007078 <etext+0x78>
    80000eb4:	e0eff0ef          	jal	800004c2 <printf>
    printf("xv6 kernel is booting\n");
    80000eb8:	00006517          	auipc	a0,0x6
    80000ebc:	1c850513          	addi	a0,a0,456 # 80007080 <etext+0x80>
    80000ec0:	e02ff0ef          	jal	800004c2 <printf>
    printf("\n");
    80000ec4:	00006517          	auipc	a0,0x6
    80000ec8:	1b450513          	addi	a0,a0,436 # 80007078 <etext+0x78>
    80000ecc:	df6ff0ef          	jal	800004c2 <printf>
    kinit();         // physical page allocator
    80000ed0:	c21ff0ef          	jal	80000af0 <kinit>
    kvminit();       // create kernel page table
    80000ed4:	2f4000ef          	jal	800011c8 <kvminit>
    kvminithart();   // turn on paging
    80000ed8:	066000ef          	jal	80000f3e <kvminithart>
    procinit();      // process table
    80000edc:	147000ef          	jal	80001822 <procinit>
    trapinit();      // trap vectors
    80000ee0:	09b010ef          	jal	8000277a <trapinit>
    trapinithart();  // install kernel trap vector
    80000ee4:	0bb010ef          	jal	8000279e <trapinithart>
    plicinit();      // set up interrupt controller
    80000ee8:	0a7040ef          	jal	8000578e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000eec:	0bd040ef          	jal	800057a8 <plicinithart>
    binit();         // buffer cache
    80000ef0:	012020ef          	jal	80002f02 <binit>
    iinit();         // inode table
    80000ef4:	604020ef          	jal	800034f8 <iinit>
    fileinit();      // file table
    80000ef8:	404030ef          	jal	800042fc <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000efc:	19d040ef          	jal	80005898 <virtio_disk_init>
    userinit();      // first user process
    80000f00:	731000ef          	jal	80001e30 <userinit>
     log_message(INFO, "Welcome to AUT MCS Principles of Operating Systems Course. This message is from a custom logger implemented by 40212004 and 40213035");
    80000f04:	00006597          	auipc	a1,0x6
    80000f08:	19458593          	addi	a1,a1,404 # 80007098 <etext+0x98>
    80000f0c:	4501                	li	a0,0
    80000f0e:	29c030ef          	jal	800041aa <log_message>
     log_message(WARN, "This is a test warning message for the custom logger");
    80000f12:	00006597          	auipc	a1,0x6
    80000f16:	20e58593          	addi	a1,a1,526 # 80007120 <etext+0x120>
    80000f1a:	4505                	li	a0,1
    80000f1c:	28e030ef          	jal	800041aa <log_message>
     log_message(ERROR, "This is a test error message for the custom logger");
    80000f20:	00006597          	auipc	a1,0x6
    80000f24:	23858593          	addi	a1,a1,568 # 80007158 <etext+0x158>
    80000f28:	4509                	li	a0,2
    80000f2a:	280030ef          	jal	800041aa <log_message>
    __sync_synchronize();
    80000f2e:	0ff0000f          	fence
    started = 1;
    80000f32:	4785                	li	a5,1
    80000f34:	00007717          	auipc	a4,0x7
    80000f38:	b8f72223          	sw	a5,-1148(a4) # 80007ab8 <started>
    80000f3c:	b795                	j	80000ea0 <main+0x3e>

0000000080000f3e <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f3e:	1141                	addi	sp,sp,-16
    80000f40:	e422                	sd	s0,8(sp)
    80000f42:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f44:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f48:	00007797          	auipc	a5,0x7
    80000f4c:	b787b783          	ld	a5,-1160(a5) # 80007ac0 <kernel_pagetable>
    80000f50:	83b1                	srli	a5,a5,0xc
    80000f52:	577d                	li	a4,-1
    80000f54:	177e                	slli	a4,a4,0x3f
    80000f56:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f58:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000f5c:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f60:	6422                	ld	s0,8(sp)
    80000f62:	0141                	addi	sp,sp,16
    80000f64:	8082                	ret

0000000080000f66 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f66:	7139                	addi	sp,sp,-64
    80000f68:	fc06                	sd	ra,56(sp)
    80000f6a:	f822                	sd	s0,48(sp)
    80000f6c:	f426                	sd	s1,40(sp)
    80000f6e:	f04a                	sd	s2,32(sp)
    80000f70:	ec4e                	sd	s3,24(sp)
    80000f72:	e852                	sd	s4,16(sp)
    80000f74:	e456                	sd	s5,8(sp)
    80000f76:	e05a                	sd	s6,0(sp)
    80000f78:	0080                	addi	s0,sp,64
    80000f7a:	84aa                	mv	s1,a0
    80000f7c:	89ae                	mv	s3,a1
    80000f7e:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000f80:	57fd                	li	a5,-1
    80000f82:	83e9                	srli	a5,a5,0x1a
    80000f84:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000f86:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000f88:	02b7fc63          	bgeu	a5,a1,80000fc0 <walk+0x5a>
    panic("walk");
    80000f8c:	00006517          	auipc	a0,0x6
    80000f90:	21c50513          	addi	a0,a0,540 # 800071a8 <etext+0x1a8>
    80000f94:	801ff0ef          	jal	80000794 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000f98:	060a8263          	beqz	s5,80000ffc <walk+0x96>
    80000f9c:	b89ff0ef          	jal	80000b24 <kalloc>
    80000fa0:	84aa                	mv	s1,a0
    80000fa2:	c139                	beqz	a0,80000fe8 <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000fa4:	6605                	lui	a2,0x1
    80000fa6:	4581                	li	a1,0
    80000fa8:	d21ff0ef          	jal	80000cc8 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000fac:	00c4d793          	srli	a5,s1,0xc
    80000fb0:	07aa                	slli	a5,a5,0xa
    80000fb2:	0017e793          	ori	a5,a5,1
    80000fb6:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000fba:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdbfe7>
    80000fbc:	036a0063          	beq	s4,s6,80000fdc <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80000fc0:	0149d933          	srl	s2,s3,s4
    80000fc4:	1ff97913          	andi	s2,s2,511
    80000fc8:	090e                	slli	s2,s2,0x3
    80000fca:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000fcc:	00093483          	ld	s1,0(s2)
    80000fd0:	0014f793          	andi	a5,s1,1
    80000fd4:	d3f1                	beqz	a5,80000f98 <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000fd6:	80a9                	srli	s1,s1,0xa
    80000fd8:	04b2                	slli	s1,s1,0xc
    80000fda:	b7c5                	j	80000fba <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80000fdc:	00c9d513          	srli	a0,s3,0xc
    80000fe0:	1ff57513          	andi	a0,a0,511
    80000fe4:	050e                	slli	a0,a0,0x3
    80000fe6:	9526                	add	a0,a0,s1
}
    80000fe8:	70e2                	ld	ra,56(sp)
    80000fea:	7442                	ld	s0,48(sp)
    80000fec:	74a2                	ld	s1,40(sp)
    80000fee:	7902                	ld	s2,32(sp)
    80000ff0:	69e2                	ld	s3,24(sp)
    80000ff2:	6a42                	ld	s4,16(sp)
    80000ff4:	6aa2                	ld	s5,8(sp)
    80000ff6:	6b02                	ld	s6,0(sp)
    80000ff8:	6121                	addi	sp,sp,64
    80000ffa:	8082                	ret
        return 0;
    80000ffc:	4501                	li	a0,0
    80000ffe:	b7ed                	j	80000fe8 <walk+0x82>

0000000080001000 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001000:	57fd                	li	a5,-1
    80001002:	83e9                	srli	a5,a5,0x1a
    80001004:	00b7f463          	bgeu	a5,a1,8000100c <walkaddr+0xc>
    return 0;
    80001008:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    8000100a:	8082                	ret
{
    8000100c:	1141                	addi	sp,sp,-16
    8000100e:	e406                	sd	ra,8(sp)
    80001010:	e022                	sd	s0,0(sp)
    80001012:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001014:	4601                	li	a2,0
    80001016:	f51ff0ef          	jal	80000f66 <walk>
  if(pte == 0)
    8000101a:	c105                	beqz	a0,8000103a <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    8000101c:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000101e:	0117f693          	andi	a3,a5,17
    80001022:	4745                	li	a4,17
    return 0;
    80001024:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001026:	00e68663          	beq	a3,a4,80001032 <walkaddr+0x32>
}
    8000102a:	60a2                	ld	ra,8(sp)
    8000102c:	6402                	ld	s0,0(sp)
    8000102e:	0141                	addi	sp,sp,16
    80001030:	8082                	ret
  pa = PTE2PA(*pte);
    80001032:	83a9                	srli	a5,a5,0xa
    80001034:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001038:	bfcd                	j	8000102a <walkaddr+0x2a>
    return 0;
    8000103a:	4501                	li	a0,0
    8000103c:	b7fd                	j	8000102a <walkaddr+0x2a>

000000008000103e <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000103e:	715d                	addi	sp,sp,-80
    80001040:	e486                	sd	ra,72(sp)
    80001042:	e0a2                	sd	s0,64(sp)
    80001044:	fc26                	sd	s1,56(sp)
    80001046:	f84a                	sd	s2,48(sp)
    80001048:	f44e                	sd	s3,40(sp)
    8000104a:	f052                	sd	s4,32(sp)
    8000104c:	ec56                	sd	s5,24(sp)
    8000104e:	e85a                	sd	s6,16(sp)
    80001050:	e45e                	sd	s7,8(sp)
    80001052:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001054:	03459793          	slli	a5,a1,0x34
    80001058:	e7a9                	bnez	a5,800010a2 <mappages+0x64>
    8000105a:	8aaa                	mv	s5,a0
    8000105c:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    8000105e:	03461793          	slli	a5,a2,0x34
    80001062:	e7b1                	bnez	a5,800010ae <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    80001064:	ca39                	beqz	a2,800010ba <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    80001066:	77fd                	lui	a5,0xfffff
    80001068:	963e                	add	a2,a2,a5
    8000106a:	00b609b3          	add	s3,a2,a1
  a = va;
    8000106e:	892e                	mv	s2,a1
    80001070:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001074:	6b85                	lui	s7,0x1
    80001076:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    8000107a:	4605                	li	a2,1
    8000107c:	85ca                	mv	a1,s2
    8000107e:	8556                	mv	a0,s5
    80001080:	ee7ff0ef          	jal	80000f66 <walk>
    80001084:	c539                	beqz	a0,800010d2 <mappages+0x94>
    if(*pte & PTE_V)
    80001086:	611c                	ld	a5,0(a0)
    80001088:	8b85                	andi	a5,a5,1
    8000108a:	ef95                	bnez	a5,800010c6 <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000108c:	80b1                	srli	s1,s1,0xc
    8000108e:	04aa                	slli	s1,s1,0xa
    80001090:	0164e4b3          	or	s1,s1,s6
    80001094:	0014e493          	ori	s1,s1,1
    80001098:	e104                	sd	s1,0(a0)
    if(a == last)
    8000109a:	05390863          	beq	s2,s3,800010ea <mappages+0xac>
    a += PGSIZE;
    8000109e:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800010a0:	bfd9                	j	80001076 <mappages+0x38>
    panic("mappages: va not aligned");
    800010a2:	00006517          	auipc	a0,0x6
    800010a6:	10e50513          	addi	a0,a0,270 # 800071b0 <etext+0x1b0>
    800010aa:	eeaff0ef          	jal	80000794 <panic>
    panic("mappages: size not aligned");
    800010ae:	00006517          	auipc	a0,0x6
    800010b2:	12250513          	addi	a0,a0,290 # 800071d0 <etext+0x1d0>
    800010b6:	edeff0ef          	jal	80000794 <panic>
    panic("mappages: size");
    800010ba:	00006517          	auipc	a0,0x6
    800010be:	13650513          	addi	a0,a0,310 # 800071f0 <etext+0x1f0>
    800010c2:	ed2ff0ef          	jal	80000794 <panic>
      panic("mappages: remap");
    800010c6:	00006517          	auipc	a0,0x6
    800010ca:	13a50513          	addi	a0,a0,314 # 80007200 <etext+0x200>
    800010ce:	ec6ff0ef          	jal	80000794 <panic>
      return -1;
    800010d2:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800010d4:	60a6                	ld	ra,72(sp)
    800010d6:	6406                	ld	s0,64(sp)
    800010d8:	74e2                	ld	s1,56(sp)
    800010da:	7942                	ld	s2,48(sp)
    800010dc:	79a2                	ld	s3,40(sp)
    800010de:	7a02                	ld	s4,32(sp)
    800010e0:	6ae2                	ld	s5,24(sp)
    800010e2:	6b42                	ld	s6,16(sp)
    800010e4:	6ba2                	ld	s7,8(sp)
    800010e6:	6161                	addi	sp,sp,80
    800010e8:	8082                	ret
  return 0;
    800010ea:	4501                	li	a0,0
    800010ec:	b7e5                	j	800010d4 <mappages+0x96>

00000000800010ee <kvmmap>:
{
    800010ee:	1141                	addi	sp,sp,-16
    800010f0:	e406                	sd	ra,8(sp)
    800010f2:	e022                	sd	s0,0(sp)
    800010f4:	0800                	addi	s0,sp,16
    800010f6:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800010f8:	86b2                	mv	a3,a2
    800010fa:	863e                	mv	a2,a5
    800010fc:	f43ff0ef          	jal	8000103e <mappages>
    80001100:	e509                	bnez	a0,8000110a <kvmmap+0x1c>
}
    80001102:	60a2                	ld	ra,8(sp)
    80001104:	6402                	ld	s0,0(sp)
    80001106:	0141                	addi	sp,sp,16
    80001108:	8082                	ret
    panic("kvmmap");
    8000110a:	00006517          	auipc	a0,0x6
    8000110e:	10650513          	addi	a0,a0,262 # 80007210 <etext+0x210>
    80001112:	e82ff0ef          	jal	80000794 <panic>

0000000080001116 <kvmmake>:
{
    80001116:	1101                	addi	sp,sp,-32
    80001118:	ec06                	sd	ra,24(sp)
    8000111a:	e822                	sd	s0,16(sp)
    8000111c:	e426                	sd	s1,8(sp)
    8000111e:	e04a                	sd	s2,0(sp)
    80001120:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001122:	a03ff0ef          	jal	80000b24 <kalloc>
    80001126:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001128:	6605                	lui	a2,0x1
    8000112a:	4581                	li	a1,0
    8000112c:	b9dff0ef          	jal	80000cc8 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001130:	4719                	li	a4,6
    80001132:	6685                	lui	a3,0x1
    80001134:	10000637          	lui	a2,0x10000
    80001138:	100005b7          	lui	a1,0x10000
    8000113c:	8526                	mv	a0,s1
    8000113e:	fb1ff0ef          	jal	800010ee <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001142:	4719                	li	a4,6
    80001144:	6685                	lui	a3,0x1
    80001146:	10001637          	lui	a2,0x10001
    8000114a:	100015b7          	lui	a1,0x10001
    8000114e:	8526                	mv	a0,s1
    80001150:	f9fff0ef          	jal	800010ee <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    80001154:	4719                	li	a4,6
    80001156:	040006b7          	lui	a3,0x4000
    8000115a:	0c000637          	lui	a2,0xc000
    8000115e:	0c0005b7          	lui	a1,0xc000
    80001162:	8526                	mv	a0,s1
    80001164:	f8bff0ef          	jal	800010ee <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001168:	00006917          	auipc	s2,0x6
    8000116c:	e9890913          	addi	s2,s2,-360 # 80007000 <etext>
    80001170:	4729                	li	a4,10
    80001172:	80006697          	auipc	a3,0x80006
    80001176:	e8e68693          	addi	a3,a3,-370 # 7000 <_entry-0x7fff9000>
    8000117a:	4605                	li	a2,1
    8000117c:	067e                	slli	a2,a2,0x1f
    8000117e:	85b2                	mv	a1,a2
    80001180:	8526                	mv	a0,s1
    80001182:	f6dff0ef          	jal	800010ee <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001186:	46c5                	li	a3,17
    80001188:	06ee                	slli	a3,a3,0x1b
    8000118a:	4719                	li	a4,6
    8000118c:	412686b3          	sub	a3,a3,s2
    80001190:	864a                	mv	a2,s2
    80001192:	85ca                	mv	a1,s2
    80001194:	8526                	mv	a0,s1
    80001196:	f59ff0ef          	jal	800010ee <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000119a:	4729                	li	a4,10
    8000119c:	6685                	lui	a3,0x1
    8000119e:	00005617          	auipc	a2,0x5
    800011a2:	e6260613          	addi	a2,a2,-414 # 80006000 <_trampoline>
    800011a6:	040005b7          	lui	a1,0x4000
    800011aa:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800011ac:	05b2                	slli	a1,a1,0xc
    800011ae:	8526                	mv	a0,s1
    800011b0:	f3fff0ef          	jal	800010ee <kvmmap>
  proc_mapstacks(kpgtbl);
    800011b4:	8526                	mv	a0,s1
    800011b6:	5da000ef          	jal	80001790 <proc_mapstacks>
}
    800011ba:	8526                	mv	a0,s1
    800011bc:	60e2                	ld	ra,24(sp)
    800011be:	6442                	ld	s0,16(sp)
    800011c0:	64a2                	ld	s1,8(sp)
    800011c2:	6902                	ld	s2,0(sp)
    800011c4:	6105                	addi	sp,sp,32
    800011c6:	8082                	ret

00000000800011c8 <kvminit>:
{
    800011c8:	1141                	addi	sp,sp,-16
    800011ca:	e406                	sd	ra,8(sp)
    800011cc:	e022                	sd	s0,0(sp)
    800011ce:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800011d0:	f47ff0ef          	jal	80001116 <kvmmake>
    800011d4:	00007797          	auipc	a5,0x7
    800011d8:	8ea7b623          	sd	a0,-1812(a5) # 80007ac0 <kernel_pagetable>
}
    800011dc:	60a2                	ld	ra,8(sp)
    800011de:	6402                	ld	s0,0(sp)
    800011e0:	0141                	addi	sp,sp,16
    800011e2:	8082                	ret

00000000800011e4 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800011e4:	715d                	addi	sp,sp,-80
    800011e6:	e486                	sd	ra,72(sp)
    800011e8:	e0a2                	sd	s0,64(sp)
    800011ea:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800011ec:	03459793          	slli	a5,a1,0x34
    800011f0:	e39d                	bnez	a5,80001216 <uvmunmap+0x32>
    800011f2:	f84a                	sd	s2,48(sp)
    800011f4:	f44e                	sd	s3,40(sp)
    800011f6:	f052                	sd	s4,32(sp)
    800011f8:	ec56                	sd	s5,24(sp)
    800011fa:	e85a                	sd	s6,16(sp)
    800011fc:	e45e                	sd	s7,8(sp)
    800011fe:	8a2a                	mv	s4,a0
    80001200:	892e                	mv	s2,a1
    80001202:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001204:	0632                	slli	a2,a2,0xc
    80001206:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000120a:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000120c:	6b05                	lui	s6,0x1
    8000120e:	0735ff63          	bgeu	a1,s3,8000128c <uvmunmap+0xa8>
    80001212:	fc26                	sd	s1,56(sp)
    80001214:	a0a9                	j	8000125e <uvmunmap+0x7a>
    80001216:	fc26                	sd	s1,56(sp)
    80001218:	f84a                	sd	s2,48(sp)
    8000121a:	f44e                	sd	s3,40(sp)
    8000121c:	f052                	sd	s4,32(sp)
    8000121e:	ec56                	sd	s5,24(sp)
    80001220:	e85a                	sd	s6,16(sp)
    80001222:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    80001224:	00006517          	auipc	a0,0x6
    80001228:	ff450513          	addi	a0,a0,-12 # 80007218 <etext+0x218>
    8000122c:	d68ff0ef          	jal	80000794 <panic>
      panic("uvmunmap: walk");
    80001230:	00006517          	auipc	a0,0x6
    80001234:	00050513          	mv	a0,a0
    80001238:	d5cff0ef          	jal	80000794 <panic>
      panic("uvmunmap: not mapped");
    8000123c:	00006517          	auipc	a0,0x6
    80001240:	00450513          	addi	a0,a0,4 # 80007240 <etext+0x240>
    80001244:	d50ff0ef          	jal	80000794 <panic>
      panic("uvmunmap: not a leaf");
    80001248:	00006517          	auipc	a0,0x6
    8000124c:	01050513          	addi	a0,a0,16 # 80007258 <etext+0x258>
    80001250:	d44ff0ef          	jal	80000794 <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    80001254:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001258:	995a                	add	s2,s2,s6
    8000125a:	03397863          	bgeu	s2,s3,8000128a <uvmunmap+0xa6>
    if((pte = walk(pagetable, a, 0)) == 0)
    8000125e:	4601                	li	a2,0
    80001260:	85ca                	mv	a1,s2
    80001262:	8552                	mv	a0,s4
    80001264:	d03ff0ef          	jal	80000f66 <walk>
    80001268:	84aa                	mv	s1,a0
    8000126a:	d179                	beqz	a0,80001230 <uvmunmap+0x4c>
    if((*pte & PTE_V) == 0)
    8000126c:	6108                	ld	a0,0(a0)
    8000126e:	00157793          	andi	a5,a0,1
    80001272:	d7e9                	beqz	a5,8000123c <uvmunmap+0x58>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001274:	3ff57793          	andi	a5,a0,1023
    80001278:	fd7788e3          	beq	a5,s7,80001248 <uvmunmap+0x64>
    if(do_free){
    8000127c:	fc0a8ce3          	beqz	s5,80001254 <uvmunmap+0x70>
      uint64 pa = PTE2PA(*pte);
    80001280:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001282:	0532                	slli	a0,a0,0xc
    80001284:	fbeff0ef          	jal	80000a42 <kfree>
    80001288:	b7f1                	j	80001254 <uvmunmap+0x70>
    8000128a:	74e2                	ld	s1,56(sp)
    8000128c:	7942                	ld	s2,48(sp)
    8000128e:	79a2                	ld	s3,40(sp)
    80001290:	7a02                	ld	s4,32(sp)
    80001292:	6ae2                	ld	s5,24(sp)
    80001294:	6b42                	ld	s6,16(sp)
    80001296:	6ba2                	ld	s7,8(sp)
  }
}
    80001298:	60a6                	ld	ra,72(sp)
    8000129a:	6406                	ld	s0,64(sp)
    8000129c:	6161                	addi	sp,sp,80
    8000129e:	8082                	ret

00000000800012a0 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800012a0:	1101                	addi	sp,sp,-32
    800012a2:	ec06                	sd	ra,24(sp)
    800012a4:	e822                	sd	s0,16(sp)
    800012a6:	e426                	sd	s1,8(sp)
    800012a8:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800012aa:	87bff0ef          	jal	80000b24 <kalloc>
    800012ae:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800012b0:	c509                	beqz	a0,800012ba <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800012b2:	6605                	lui	a2,0x1
    800012b4:	4581                	li	a1,0
    800012b6:	a13ff0ef          	jal	80000cc8 <memset>
  return pagetable;
}
    800012ba:	8526                	mv	a0,s1
    800012bc:	60e2                	ld	ra,24(sp)
    800012be:	6442                	ld	s0,16(sp)
    800012c0:	64a2                	ld	s1,8(sp)
    800012c2:	6105                	addi	sp,sp,32
    800012c4:	8082                	ret

00000000800012c6 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    800012c6:	7179                	addi	sp,sp,-48
    800012c8:	f406                	sd	ra,40(sp)
    800012ca:	f022                	sd	s0,32(sp)
    800012cc:	ec26                	sd	s1,24(sp)
    800012ce:	e84a                	sd	s2,16(sp)
    800012d0:	e44e                	sd	s3,8(sp)
    800012d2:	e052                	sd	s4,0(sp)
    800012d4:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800012d6:	6785                	lui	a5,0x1
    800012d8:	04f67063          	bgeu	a2,a5,80001318 <uvmfirst+0x52>
    800012dc:	8a2a                	mv	s4,a0
    800012de:	89ae                	mv	s3,a1
    800012e0:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800012e2:	843ff0ef          	jal	80000b24 <kalloc>
    800012e6:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800012e8:	6605                	lui	a2,0x1
    800012ea:	4581                	li	a1,0
    800012ec:	9ddff0ef          	jal	80000cc8 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800012f0:	4779                	li	a4,30
    800012f2:	86ca                	mv	a3,s2
    800012f4:	6605                	lui	a2,0x1
    800012f6:	4581                	li	a1,0
    800012f8:	8552                	mv	a0,s4
    800012fa:	d45ff0ef          	jal	8000103e <mappages>
  memmove(mem, src, sz);
    800012fe:	8626                	mv	a2,s1
    80001300:	85ce                	mv	a1,s3
    80001302:	854a                	mv	a0,s2
    80001304:	a21ff0ef          	jal	80000d24 <memmove>
}
    80001308:	70a2                	ld	ra,40(sp)
    8000130a:	7402                	ld	s0,32(sp)
    8000130c:	64e2                	ld	s1,24(sp)
    8000130e:	6942                	ld	s2,16(sp)
    80001310:	69a2                	ld	s3,8(sp)
    80001312:	6a02                	ld	s4,0(sp)
    80001314:	6145                	addi	sp,sp,48
    80001316:	8082                	ret
    panic("uvmfirst: more than a page");
    80001318:	00006517          	auipc	a0,0x6
    8000131c:	f5850513          	addi	a0,a0,-168 # 80007270 <etext+0x270>
    80001320:	c74ff0ef          	jal	80000794 <panic>

0000000080001324 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001324:	1101                	addi	sp,sp,-32
    80001326:	ec06                	sd	ra,24(sp)
    80001328:	e822                	sd	s0,16(sp)
    8000132a:	e426                	sd	s1,8(sp)
    8000132c:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000132e:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001330:	00b67d63          	bgeu	a2,a1,8000134a <uvmdealloc+0x26>
    80001334:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001336:	6785                	lui	a5,0x1
    80001338:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000133a:	00f60733          	add	a4,a2,a5
    8000133e:	76fd                	lui	a3,0xfffff
    80001340:	8f75                	and	a4,a4,a3
    80001342:	97ae                	add	a5,a5,a1
    80001344:	8ff5                	and	a5,a5,a3
    80001346:	00f76863          	bltu	a4,a5,80001356 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000134a:	8526                	mv	a0,s1
    8000134c:	60e2                	ld	ra,24(sp)
    8000134e:	6442                	ld	s0,16(sp)
    80001350:	64a2                	ld	s1,8(sp)
    80001352:	6105                	addi	sp,sp,32
    80001354:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001356:	8f99                	sub	a5,a5,a4
    80001358:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000135a:	4685                	li	a3,1
    8000135c:	0007861b          	sext.w	a2,a5
    80001360:	85ba                	mv	a1,a4
    80001362:	e83ff0ef          	jal	800011e4 <uvmunmap>
    80001366:	b7d5                	j	8000134a <uvmdealloc+0x26>

0000000080001368 <uvmalloc>:
  if(newsz < oldsz)
    80001368:	08b66f63          	bltu	a2,a1,80001406 <uvmalloc+0x9e>
{
    8000136c:	7139                	addi	sp,sp,-64
    8000136e:	fc06                	sd	ra,56(sp)
    80001370:	f822                	sd	s0,48(sp)
    80001372:	ec4e                	sd	s3,24(sp)
    80001374:	e852                	sd	s4,16(sp)
    80001376:	e456                	sd	s5,8(sp)
    80001378:	0080                	addi	s0,sp,64
    8000137a:	8aaa                	mv	s5,a0
    8000137c:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000137e:	6785                	lui	a5,0x1
    80001380:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001382:	95be                	add	a1,a1,a5
    80001384:	77fd                	lui	a5,0xfffff
    80001386:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000138a:	08c9f063          	bgeu	s3,a2,8000140a <uvmalloc+0xa2>
    8000138e:	f426                	sd	s1,40(sp)
    80001390:	f04a                	sd	s2,32(sp)
    80001392:	e05a                	sd	s6,0(sp)
    80001394:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001396:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    8000139a:	f8aff0ef          	jal	80000b24 <kalloc>
    8000139e:	84aa                	mv	s1,a0
    if(mem == 0){
    800013a0:	c515                	beqz	a0,800013cc <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    800013a2:	6605                	lui	a2,0x1
    800013a4:	4581                	li	a1,0
    800013a6:	923ff0ef          	jal	80000cc8 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800013aa:	875a                	mv	a4,s6
    800013ac:	86a6                	mv	a3,s1
    800013ae:	6605                	lui	a2,0x1
    800013b0:	85ca                	mv	a1,s2
    800013b2:	8556                	mv	a0,s5
    800013b4:	c8bff0ef          	jal	8000103e <mappages>
    800013b8:	e915                	bnez	a0,800013ec <uvmalloc+0x84>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800013ba:	6785                	lui	a5,0x1
    800013bc:	993e                	add	s2,s2,a5
    800013be:	fd496ee3          	bltu	s2,s4,8000139a <uvmalloc+0x32>
  return newsz;
    800013c2:	8552                	mv	a0,s4
    800013c4:	74a2                	ld	s1,40(sp)
    800013c6:	7902                	ld	s2,32(sp)
    800013c8:	6b02                	ld	s6,0(sp)
    800013ca:	a811                	j	800013de <uvmalloc+0x76>
      uvmdealloc(pagetable, a, oldsz);
    800013cc:	864e                	mv	a2,s3
    800013ce:	85ca                	mv	a1,s2
    800013d0:	8556                	mv	a0,s5
    800013d2:	f53ff0ef          	jal	80001324 <uvmdealloc>
      return 0;
    800013d6:	4501                	li	a0,0
    800013d8:	74a2                	ld	s1,40(sp)
    800013da:	7902                	ld	s2,32(sp)
    800013dc:	6b02                	ld	s6,0(sp)
}
    800013de:	70e2                	ld	ra,56(sp)
    800013e0:	7442                	ld	s0,48(sp)
    800013e2:	69e2                	ld	s3,24(sp)
    800013e4:	6a42                	ld	s4,16(sp)
    800013e6:	6aa2                	ld	s5,8(sp)
    800013e8:	6121                	addi	sp,sp,64
    800013ea:	8082                	ret
      kfree(mem);
    800013ec:	8526                	mv	a0,s1
    800013ee:	e54ff0ef          	jal	80000a42 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800013f2:	864e                	mv	a2,s3
    800013f4:	85ca                	mv	a1,s2
    800013f6:	8556                	mv	a0,s5
    800013f8:	f2dff0ef          	jal	80001324 <uvmdealloc>
      return 0;
    800013fc:	4501                	li	a0,0
    800013fe:	74a2                	ld	s1,40(sp)
    80001400:	7902                	ld	s2,32(sp)
    80001402:	6b02                	ld	s6,0(sp)
    80001404:	bfe9                	j	800013de <uvmalloc+0x76>
    return oldsz;
    80001406:	852e                	mv	a0,a1
}
    80001408:	8082                	ret
  return newsz;
    8000140a:	8532                	mv	a0,a2
    8000140c:	bfc9                	j	800013de <uvmalloc+0x76>

000000008000140e <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    8000140e:	7179                	addi	sp,sp,-48
    80001410:	f406                	sd	ra,40(sp)
    80001412:	f022                	sd	s0,32(sp)
    80001414:	ec26                	sd	s1,24(sp)
    80001416:	e84a                	sd	s2,16(sp)
    80001418:	e44e                	sd	s3,8(sp)
    8000141a:	e052                	sd	s4,0(sp)
    8000141c:	1800                	addi	s0,sp,48
    8000141e:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001420:	84aa                	mv	s1,a0
    80001422:	6905                	lui	s2,0x1
    80001424:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001426:	4985                	li	s3,1
    80001428:	a819                	j	8000143e <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000142a:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    8000142c:	00c79513          	slli	a0,a5,0xc
    80001430:	fdfff0ef          	jal	8000140e <freewalk>
      pagetable[i] = 0;
    80001434:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001438:	04a1                	addi	s1,s1,8
    8000143a:	01248f63          	beq	s1,s2,80001458 <freewalk+0x4a>
    pte_t pte = pagetable[i];
    8000143e:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001440:	00f7f713          	andi	a4,a5,15
    80001444:	ff3703e3          	beq	a4,s3,8000142a <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001448:	8b85                	andi	a5,a5,1
    8000144a:	d7fd                	beqz	a5,80001438 <freewalk+0x2a>
      panic("freewalk: leaf");
    8000144c:	00006517          	auipc	a0,0x6
    80001450:	e4450513          	addi	a0,a0,-444 # 80007290 <etext+0x290>
    80001454:	b40ff0ef          	jal	80000794 <panic>
    }
  }
  kfree((void*)pagetable);
    80001458:	8552                	mv	a0,s4
    8000145a:	de8ff0ef          	jal	80000a42 <kfree>
}
    8000145e:	70a2                	ld	ra,40(sp)
    80001460:	7402                	ld	s0,32(sp)
    80001462:	64e2                	ld	s1,24(sp)
    80001464:	6942                	ld	s2,16(sp)
    80001466:	69a2                	ld	s3,8(sp)
    80001468:	6a02                	ld	s4,0(sp)
    8000146a:	6145                	addi	sp,sp,48
    8000146c:	8082                	ret

000000008000146e <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000146e:	1101                	addi	sp,sp,-32
    80001470:	ec06                	sd	ra,24(sp)
    80001472:	e822                	sd	s0,16(sp)
    80001474:	e426                	sd	s1,8(sp)
    80001476:	1000                	addi	s0,sp,32
    80001478:	84aa                	mv	s1,a0
  if(sz > 0)
    8000147a:	e989                	bnez	a1,8000148c <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000147c:	8526                	mv	a0,s1
    8000147e:	f91ff0ef          	jal	8000140e <freewalk>
}
    80001482:	60e2                	ld	ra,24(sp)
    80001484:	6442                	ld	s0,16(sp)
    80001486:	64a2                	ld	s1,8(sp)
    80001488:	6105                	addi	sp,sp,32
    8000148a:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000148c:	6785                	lui	a5,0x1
    8000148e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001490:	95be                	add	a1,a1,a5
    80001492:	4685                	li	a3,1
    80001494:	00c5d613          	srli	a2,a1,0xc
    80001498:	4581                	li	a1,0
    8000149a:	d4bff0ef          	jal	800011e4 <uvmunmap>
    8000149e:	bff9                	j	8000147c <uvmfree+0xe>

00000000800014a0 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800014a0:	c65d                	beqz	a2,8000154e <uvmcopy+0xae>
{
    800014a2:	715d                	addi	sp,sp,-80
    800014a4:	e486                	sd	ra,72(sp)
    800014a6:	e0a2                	sd	s0,64(sp)
    800014a8:	fc26                	sd	s1,56(sp)
    800014aa:	f84a                	sd	s2,48(sp)
    800014ac:	f44e                	sd	s3,40(sp)
    800014ae:	f052                	sd	s4,32(sp)
    800014b0:	ec56                	sd	s5,24(sp)
    800014b2:	e85a                	sd	s6,16(sp)
    800014b4:	e45e                	sd	s7,8(sp)
    800014b6:	0880                	addi	s0,sp,80
    800014b8:	8b2a                	mv	s6,a0
    800014ba:	8aae                	mv	s5,a1
    800014bc:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800014be:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    800014c0:	4601                	li	a2,0
    800014c2:	85ce                	mv	a1,s3
    800014c4:	855a                	mv	a0,s6
    800014c6:	aa1ff0ef          	jal	80000f66 <walk>
    800014ca:	c121                	beqz	a0,8000150a <uvmcopy+0x6a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800014cc:	6118                	ld	a4,0(a0)
    800014ce:	00177793          	andi	a5,a4,1
    800014d2:	c3b1                	beqz	a5,80001516 <uvmcopy+0x76>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800014d4:	00a75593          	srli	a1,a4,0xa
    800014d8:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800014dc:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800014e0:	e44ff0ef          	jal	80000b24 <kalloc>
    800014e4:	892a                	mv	s2,a0
    800014e6:	c129                	beqz	a0,80001528 <uvmcopy+0x88>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800014e8:	6605                	lui	a2,0x1
    800014ea:	85de                	mv	a1,s7
    800014ec:	839ff0ef          	jal	80000d24 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800014f0:	8726                	mv	a4,s1
    800014f2:	86ca                	mv	a3,s2
    800014f4:	6605                	lui	a2,0x1
    800014f6:	85ce                	mv	a1,s3
    800014f8:	8556                	mv	a0,s5
    800014fa:	b45ff0ef          	jal	8000103e <mappages>
    800014fe:	e115                	bnez	a0,80001522 <uvmcopy+0x82>
  for(i = 0; i < sz; i += PGSIZE){
    80001500:	6785                	lui	a5,0x1
    80001502:	99be                	add	s3,s3,a5
    80001504:	fb49eee3          	bltu	s3,s4,800014c0 <uvmcopy+0x20>
    80001508:	a805                	j	80001538 <uvmcopy+0x98>
      panic("uvmcopy: pte should exist");
    8000150a:	00006517          	auipc	a0,0x6
    8000150e:	d9650513          	addi	a0,a0,-618 # 800072a0 <etext+0x2a0>
    80001512:	a82ff0ef          	jal	80000794 <panic>
      panic("uvmcopy: page not present");
    80001516:	00006517          	auipc	a0,0x6
    8000151a:	daa50513          	addi	a0,a0,-598 # 800072c0 <etext+0x2c0>
    8000151e:	a76ff0ef          	jal	80000794 <panic>
      kfree(mem);
    80001522:	854a                	mv	a0,s2
    80001524:	d1eff0ef          	jal	80000a42 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001528:	4685                	li	a3,1
    8000152a:	00c9d613          	srli	a2,s3,0xc
    8000152e:	4581                	li	a1,0
    80001530:	8556                	mv	a0,s5
    80001532:	cb3ff0ef          	jal	800011e4 <uvmunmap>
  return -1;
    80001536:	557d                	li	a0,-1
}
    80001538:	60a6                	ld	ra,72(sp)
    8000153a:	6406                	ld	s0,64(sp)
    8000153c:	74e2                	ld	s1,56(sp)
    8000153e:	7942                	ld	s2,48(sp)
    80001540:	79a2                	ld	s3,40(sp)
    80001542:	7a02                	ld	s4,32(sp)
    80001544:	6ae2                	ld	s5,24(sp)
    80001546:	6b42                	ld	s6,16(sp)
    80001548:	6ba2                	ld	s7,8(sp)
    8000154a:	6161                	addi	sp,sp,80
    8000154c:	8082                	ret
  return 0;
    8000154e:	4501                	li	a0,0
}
    80001550:	8082                	ret

0000000080001552 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001552:	1141                	addi	sp,sp,-16
    80001554:	e406                	sd	ra,8(sp)
    80001556:	e022                	sd	s0,0(sp)
    80001558:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000155a:	4601                	li	a2,0
    8000155c:	a0bff0ef          	jal	80000f66 <walk>
  if(pte == 0)
    80001560:	c901                	beqz	a0,80001570 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001562:	611c                	ld	a5,0(a0)
    80001564:	9bbd                	andi	a5,a5,-17
    80001566:	e11c                	sd	a5,0(a0)
}
    80001568:	60a2                	ld	ra,8(sp)
    8000156a:	6402                	ld	s0,0(sp)
    8000156c:	0141                	addi	sp,sp,16
    8000156e:	8082                	ret
    panic("uvmclear");
    80001570:	00006517          	auipc	a0,0x6
    80001574:	d7050513          	addi	a0,a0,-656 # 800072e0 <etext+0x2e0>
    80001578:	a1cff0ef          	jal	80000794 <panic>

000000008000157c <copyout>:
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  pte_t *pte;

  while(len > 0){
    8000157c:	cad1                	beqz	a3,80001610 <copyout+0x94>
{
    8000157e:	711d                	addi	sp,sp,-96
    80001580:	ec86                	sd	ra,88(sp)
    80001582:	e8a2                	sd	s0,80(sp)
    80001584:	e4a6                	sd	s1,72(sp)
    80001586:	fc4e                	sd	s3,56(sp)
    80001588:	f456                	sd	s5,40(sp)
    8000158a:	f05a                	sd	s6,32(sp)
    8000158c:	ec5e                	sd	s7,24(sp)
    8000158e:	1080                	addi	s0,sp,96
    80001590:	8baa                	mv	s7,a0
    80001592:	8aae                	mv	s5,a1
    80001594:	8b32                	mv	s6,a2
    80001596:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001598:	74fd                	lui	s1,0xfffff
    8000159a:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    8000159c:	57fd                	li	a5,-1
    8000159e:	83e9                	srli	a5,a5,0x1a
    800015a0:	0697ea63          	bltu	a5,s1,80001614 <copyout+0x98>
    800015a4:	e0ca                	sd	s2,64(sp)
    800015a6:	f852                	sd	s4,48(sp)
    800015a8:	e862                	sd	s8,16(sp)
    800015aa:	e466                	sd	s9,8(sp)
    800015ac:	e06a                	sd	s10,0(sp)
      return -1;
    pte = walk(pagetable, va0, 0);
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    800015ae:	4cd5                	li	s9,21
    800015b0:	6d05                	lui	s10,0x1
    if(va0 >= MAXVA)
    800015b2:	8c3e                	mv	s8,a5
    800015b4:	a025                	j	800015dc <copyout+0x60>
       (*pte & PTE_W) == 0)
      return -1;
    pa0 = PTE2PA(*pte);
    800015b6:	83a9                	srli	a5,a5,0xa
    800015b8:	07b2                	slli	a5,a5,0xc
    n = PGSIZE - (dstva - va0);
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800015ba:	409a8533          	sub	a0,s5,s1
    800015be:	0009061b          	sext.w	a2,s2
    800015c2:	85da                	mv	a1,s6
    800015c4:	953e                	add	a0,a0,a5
    800015c6:	f5eff0ef          	jal	80000d24 <memmove>

    len -= n;
    800015ca:	412989b3          	sub	s3,s3,s2
    src += n;
    800015ce:	9b4a                	add	s6,s6,s2
  while(len > 0){
    800015d0:	02098963          	beqz	s3,80001602 <copyout+0x86>
    if(va0 >= MAXVA)
    800015d4:	054c6263          	bltu	s8,s4,80001618 <copyout+0x9c>
    800015d8:	84d2                	mv	s1,s4
    800015da:	8ad2                	mv	s5,s4
    pte = walk(pagetable, va0, 0);
    800015dc:	4601                	li	a2,0
    800015de:	85a6                	mv	a1,s1
    800015e0:	855e                	mv	a0,s7
    800015e2:	985ff0ef          	jal	80000f66 <walk>
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    800015e6:	c121                	beqz	a0,80001626 <copyout+0xaa>
    800015e8:	611c                	ld	a5,0(a0)
    800015ea:	0157f713          	andi	a4,a5,21
    800015ee:	05971b63          	bne	a4,s9,80001644 <copyout+0xc8>
    n = PGSIZE - (dstva - va0);
    800015f2:	01a48a33          	add	s4,s1,s10
    800015f6:	415a0933          	sub	s2,s4,s5
    if(n > len)
    800015fa:	fb29fee3          	bgeu	s3,s2,800015b6 <copyout+0x3a>
    800015fe:	894e                	mv	s2,s3
    80001600:	bf5d                	j	800015b6 <copyout+0x3a>
    dstva = va0 + PGSIZE;
  }
  return 0;
    80001602:	4501                	li	a0,0
    80001604:	6906                	ld	s2,64(sp)
    80001606:	7a42                	ld	s4,48(sp)
    80001608:	6c42                	ld	s8,16(sp)
    8000160a:	6ca2                	ld	s9,8(sp)
    8000160c:	6d02                	ld	s10,0(sp)
    8000160e:	a015                	j	80001632 <copyout+0xb6>
    80001610:	4501                	li	a0,0
}
    80001612:	8082                	ret
      return -1;
    80001614:	557d                	li	a0,-1
    80001616:	a831                	j	80001632 <copyout+0xb6>
    80001618:	557d                	li	a0,-1
    8000161a:	6906                	ld	s2,64(sp)
    8000161c:	7a42                	ld	s4,48(sp)
    8000161e:	6c42                	ld	s8,16(sp)
    80001620:	6ca2                	ld	s9,8(sp)
    80001622:	6d02                	ld	s10,0(sp)
    80001624:	a039                	j	80001632 <copyout+0xb6>
      return -1;
    80001626:	557d                	li	a0,-1
    80001628:	6906                	ld	s2,64(sp)
    8000162a:	7a42                	ld	s4,48(sp)
    8000162c:	6c42                	ld	s8,16(sp)
    8000162e:	6ca2                	ld	s9,8(sp)
    80001630:	6d02                	ld	s10,0(sp)
}
    80001632:	60e6                	ld	ra,88(sp)
    80001634:	6446                	ld	s0,80(sp)
    80001636:	64a6                	ld	s1,72(sp)
    80001638:	79e2                	ld	s3,56(sp)
    8000163a:	7aa2                	ld	s5,40(sp)
    8000163c:	7b02                	ld	s6,32(sp)
    8000163e:	6be2                	ld	s7,24(sp)
    80001640:	6125                	addi	sp,sp,96
    80001642:	8082                	ret
      return -1;
    80001644:	557d                	li	a0,-1
    80001646:	6906                	ld	s2,64(sp)
    80001648:	7a42                	ld	s4,48(sp)
    8000164a:	6c42                	ld	s8,16(sp)
    8000164c:	6ca2                	ld	s9,8(sp)
    8000164e:	6d02                	ld	s10,0(sp)
    80001650:	b7cd                	j	80001632 <copyout+0xb6>

0000000080001652 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001652:	c6a5                	beqz	a3,800016ba <copyin+0x68>
{
    80001654:	715d                	addi	sp,sp,-80
    80001656:	e486                	sd	ra,72(sp)
    80001658:	e0a2                	sd	s0,64(sp)
    8000165a:	fc26                	sd	s1,56(sp)
    8000165c:	f84a                	sd	s2,48(sp)
    8000165e:	f44e                	sd	s3,40(sp)
    80001660:	f052                	sd	s4,32(sp)
    80001662:	ec56                	sd	s5,24(sp)
    80001664:	e85a                	sd	s6,16(sp)
    80001666:	e45e                	sd	s7,8(sp)
    80001668:	e062                	sd	s8,0(sp)
    8000166a:	0880                	addi	s0,sp,80
    8000166c:	8b2a                	mv	s6,a0
    8000166e:	8a2e                	mv	s4,a1
    80001670:	8c32                	mv	s8,a2
    80001672:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001674:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001676:	6a85                	lui	s5,0x1
    80001678:	a00d                	j	8000169a <copyin+0x48>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000167a:	018505b3          	add	a1,a0,s8
    8000167e:	0004861b          	sext.w	a2,s1
    80001682:	412585b3          	sub	a1,a1,s2
    80001686:	8552                	mv	a0,s4
    80001688:	e9cff0ef          	jal	80000d24 <memmove>

    len -= n;
    8000168c:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001690:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001692:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001696:	02098063          	beqz	s3,800016b6 <copyin+0x64>
    va0 = PGROUNDDOWN(srcva);
    8000169a:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000169e:	85ca                	mv	a1,s2
    800016a0:	855a                	mv	a0,s6
    800016a2:	95fff0ef          	jal	80001000 <walkaddr>
    if(pa0 == 0)
    800016a6:	cd01                	beqz	a0,800016be <copyin+0x6c>
    n = PGSIZE - (srcva - va0);
    800016a8:	418904b3          	sub	s1,s2,s8
    800016ac:	94d6                	add	s1,s1,s5
    if(n > len)
    800016ae:	fc99f6e3          	bgeu	s3,s1,8000167a <copyin+0x28>
    800016b2:	84ce                	mv	s1,s3
    800016b4:	b7d9                	j	8000167a <copyin+0x28>
  }
  return 0;
    800016b6:	4501                	li	a0,0
    800016b8:	a021                	j	800016c0 <copyin+0x6e>
    800016ba:	4501                	li	a0,0
}
    800016bc:	8082                	ret
      return -1;
    800016be:	557d                	li	a0,-1
}
    800016c0:	60a6                	ld	ra,72(sp)
    800016c2:	6406                	ld	s0,64(sp)
    800016c4:	74e2                	ld	s1,56(sp)
    800016c6:	7942                	ld	s2,48(sp)
    800016c8:	79a2                	ld	s3,40(sp)
    800016ca:	7a02                	ld	s4,32(sp)
    800016cc:	6ae2                	ld	s5,24(sp)
    800016ce:	6b42                	ld	s6,16(sp)
    800016d0:	6ba2                	ld	s7,8(sp)
    800016d2:	6c02                	ld	s8,0(sp)
    800016d4:	6161                	addi	sp,sp,80
    800016d6:	8082                	ret

00000000800016d8 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800016d8:	c6dd                	beqz	a3,80001786 <copyinstr+0xae>
{
    800016da:	715d                	addi	sp,sp,-80
    800016dc:	e486                	sd	ra,72(sp)
    800016de:	e0a2                	sd	s0,64(sp)
    800016e0:	fc26                	sd	s1,56(sp)
    800016e2:	f84a                	sd	s2,48(sp)
    800016e4:	f44e                	sd	s3,40(sp)
    800016e6:	f052                	sd	s4,32(sp)
    800016e8:	ec56                	sd	s5,24(sp)
    800016ea:	e85a                	sd	s6,16(sp)
    800016ec:	e45e                	sd	s7,8(sp)
    800016ee:	0880                	addi	s0,sp,80
    800016f0:	8a2a                	mv	s4,a0
    800016f2:	8b2e                	mv	s6,a1
    800016f4:	8bb2                	mv	s7,a2
    800016f6:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    800016f8:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800016fa:	6985                	lui	s3,0x1
    800016fc:	a825                	j	80001734 <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800016fe:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001702:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001704:	37fd                	addiw	a5,a5,-1
    80001706:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    8000170a:	60a6                	ld	ra,72(sp)
    8000170c:	6406                	ld	s0,64(sp)
    8000170e:	74e2                	ld	s1,56(sp)
    80001710:	7942                	ld	s2,48(sp)
    80001712:	79a2                	ld	s3,40(sp)
    80001714:	7a02                	ld	s4,32(sp)
    80001716:	6ae2                	ld	s5,24(sp)
    80001718:	6b42                	ld	s6,16(sp)
    8000171a:	6ba2                	ld	s7,8(sp)
    8000171c:	6161                	addi	sp,sp,80
    8000171e:	8082                	ret
    80001720:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    80001724:	9742                	add	a4,a4,a6
      --max;
    80001726:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    8000172a:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    8000172e:	04e58463          	beq	a1,a4,80001776 <copyinstr+0x9e>
{
    80001732:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    80001734:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001738:	85a6                	mv	a1,s1
    8000173a:	8552                	mv	a0,s4
    8000173c:	8c5ff0ef          	jal	80001000 <walkaddr>
    if(pa0 == 0)
    80001740:	cd0d                	beqz	a0,8000177a <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    80001742:	417486b3          	sub	a3,s1,s7
    80001746:	96ce                	add	a3,a3,s3
    if(n > max)
    80001748:	00d97363          	bgeu	s2,a3,8000174e <copyinstr+0x76>
    8000174c:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    8000174e:	955e                	add	a0,a0,s7
    80001750:	8d05                	sub	a0,a0,s1
    while(n > 0){
    80001752:	c695                	beqz	a3,8000177e <copyinstr+0xa6>
    80001754:	87da                	mv	a5,s6
    80001756:	885a                	mv	a6,s6
      if(*p == '\0'){
    80001758:	41650633          	sub	a2,a0,s6
    while(n > 0){
    8000175c:	96da                	add	a3,a3,s6
    8000175e:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001760:	00f60733          	add	a4,a2,a5
    80001764:	00074703          	lbu	a4,0(a4)
    80001768:	db59                	beqz	a4,800016fe <copyinstr+0x26>
        *dst = *p;
    8000176a:	00e78023          	sb	a4,0(a5)
      dst++;
    8000176e:	0785                	addi	a5,a5,1
    while(n > 0){
    80001770:	fed797e3          	bne	a5,a3,8000175e <copyinstr+0x86>
    80001774:	b775                	j	80001720 <copyinstr+0x48>
    80001776:	4781                	li	a5,0
    80001778:	b771                	j	80001704 <copyinstr+0x2c>
      return -1;
    8000177a:	557d                	li	a0,-1
    8000177c:	b779                	j	8000170a <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    8000177e:	6b85                	lui	s7,0x1
    80001780:	9ba6                	add	s7,s7,s1
    80001782:	87da                	mv	a5,s6
    80001784:	b77d                	j	80001732 <copyinstr+0x5a>
  int got_null = 0;
    80001786:	4781                	li	a5,0
  if(got_null){
    80001788:	37fd                	addiw	a5,a5,-1
    8000178a:	0007851b          	sext.w	a0,a5
}
    8000178e:	8082                	ret

0000000080001790 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001790:	7139                	addi	sp,sp,-64
    80001792:	fc06                	sd	ra,56(sp)
    80001794:	f822                	sd	s0,48(sp)
    80001796:	f426                	sd	s1,40(sp)
    80001798:	f04a                	sd	s2,32(sp)
    8000179a:	ec4e                	sd	s3,24(sp)
    8000179c:	e852                	sd	s4,16(sp)
    8000179e:	e456                	sd	s5,8(sp)
    800017a0:	e05a                	sd	s6,0(sp)
    800017a2:	0080                	addi	s0,sp,64
    800017a4:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    800017a6:	0000f497          	auipc	s1,0xf
    800017aa:	88a48493          	addi	s1,s1,-1910 # 80010030 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    800017ae:	8b26                	mv	s6,s1
    800017b0:	bdef8937          	lui	s2,0xbdef8
    800017b4:	bdf90913          	addi	s2,s2,-1057 # ffffffffbdef7bdf <end+0xffffffff3ded4bcf>
    800017b8:	093e                	slli	s2,s2,0xf
    800017ba:	bdf90913          	addi	s2,s2,-1057
    800017be:	093e                	slli	s2,s2,0xf
    800017c0:	bdf90913          	addi	s2,s2,-1057
    800017c4:	040009b7          	lui	s3,0x4000
    800017c8:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800017ca:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800017cc:	00016a97          	auipc	s5,0x16
    800017d0:	464a8a93          	addi	s5,s5,1124 # 80017c30 <tickslock>
    char *pa = kalloc();
    800017d4:	b50ff0ef          	jal	80000b24 <kalloc>
    800017d8:	862a                	mv	a2,a0
    if(pa == 0)
    800017da:	cd15                	beqz	a0,80001816 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    800017dc:	416485b3          	sub	a1,s1,s6
    800017e0:	8591                	srai	a1,a1,0x4
    800017e2:	032585b3          	mul	a1,a1,s2
    800017e6:	2585                	addiw	a1,a1,1
    800017e8:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017ec:	4719                	li	a4,6
    800017ee:	6685                	lui	a3,0x1
    800017f0:	40b985b3          	sub	a1,s3,a1
    800017f4:	8552                	mv	a0,s4
    800017f6:	8f9ff0ef          	jal	800010ee <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800017fa:	1f048493          	addi	s1,s1,496
    800017fe:	fd549be3          	bne	s1,s5,800017d4 <proc_mapstacks+0x44>
  }
}
    80001802:	70e2                	ld	ra,56(sp)
    80001804:	7442                	ld	s0,48(sp)
    80001806:	74a2                	ld	s1,40(sp)
    80001808:	7902                	ld	s2,32(sp)
    8000180a:	69e2                	ld	s3,24(sp)
    8000180c:	6a42                	ld	s4,16(sp)
    8000180e:	6aa2                	ld	s5,8(sp)
    80001810:	6b02                	ld	s6,0(sp)
    80001812:	6121                	addi	sp,sp,64
    80001814:	8082                	ret
      panic("kalloc");
    80001816:	00006517          	auipc	a0,0x6
    8000181a:	ada50513          	addi	a0,a0,-1318 # 800072f0 <etext+0x2f0>
    8000181e:	f77fe0ef          	jal	80000794 <panic>

0000000080001822 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80001822:	7139                	addi	sp,sp,-64
    80001824:	fc06                	sd	ra,56(sp)
    80001826:	f822                	sd	s0,48(sp)
    80001828:	f426                	sd	s1,40(sp)
    8000182a:	f04a                	sd	s2,32(sp)
    8000182c:	ec4e                	sd	s3,24(sp)
    8000182e:	e852                	sd	s4,16(sp)
    80001830:	e456                	sd	s5,8(sp)
    80001832:	e05a                	sd	s6,0(sp)
    80001834:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001836:	00006597          	auipc	a1,0x6
    8000183a:	ac258593          	addi	a1,a1,-1342 # 800072f8 <etext+0x2f8>
    8000183e:	0000e517          	auipc	a0,0xe
    80001842:	3c250513          	addi	a0,a0,962 # 8000fc00 <pid_lock>
    80001846:	b2eff0ef          	jal	80000b74 <initlock>
  initlock(&wait_lock, "wait_lock");
    8000184a:	00006597          	auipc	a1,0x6
    8000184e:	ab658593          	addi	a1,a1,-1354 # 80007300 <etext+0x300>
    80001852:	0000e517          	auipc	a0,0xe
    80001856:	3c650513          	addi	a0,a0,966 # 8000fc18 <wait_lock>
    8000185a:	b1aff0ef          	jal	80000b74 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000185e:	0000e497          	auipc	s1,0xe
    80001862:	7d248493          	addi	s1,s1,2002 # 80010030 <proc>
      initlock(&p->lock, "proc");
    80001866:	00006b17          	auipc	s6,0x6
    8000186a:	aaab0b13          	addi	s6,s6,-1366 # 80007310 <etext+0x310>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    8000186e:	8aa6                	mv	s5,s1
    80001870:	bdef8937          	lui	s2,0xbdef8
    80001874:	bdf90913          	addi	s2,s2,-1057 # ffffffffbdef7bdf <end+0xffffffff3ded4bcf>
    80001878:	093e                	slli	s2,s2,0xf
    8000187a:	bdf90913          	addi	s2,s2,-1057
    8000187e:	093e                	slli	s2,s2,0xf
    80001880:	bdf90913          	addi	s2,s2,-1057
    80001884:	040009b7          	lui	s3,0x4000
    80001888:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000188a:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000188c:	00016a17          	auipc	s4,0x16
    80001890:	3a4a0a13          	addi	s4,s4,932 # 80017c30 <tickslock>
      initlock(&p->lock, "proc");
    80001894:	85da                	mv	a1,s6
    80001896:	8526                	mv	a0,s1
    80001898:	adcff0ef          	jal	80000b74 <initlock>
      p->state = UNUSED;
    8000189c:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    800018a0:	415487b3          	sub	a5,s1,s5
    800018a4:	8791                	srai	a5,a5,0x4
    800018a6:	032787b3          	mul	a5,a5,s2
    800018aa:	2785                	addiw	a5,a5,1
    800018ac:	00d7979b          	slliw	a5,a5,0xd
    800018b0:	40f987b3          	sub	a5,s3,a5
    800018b4:	e0bc                	sd	a5,64(s1)
      p->current_thread = 0; // Initialize current_thread to indicate no active thread
    800018b6:	1e04b423          	sd	zero,488(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    800018ba:	1f048493          	addi	s1,s1,496
    800018be:	fd449be3          	bne	s1,s4,80001894 <procinit+0x72>
  }
}
    800018c2:	70e2                	ld	ra,56(sp)
    800018c4:	7442                	ld	s0,48(sp)
    800018c6:	74a2                	ld	s1,40(sp)
    800018c8:	7902                	ld	s2,32(sp)
    800018ca:	69e2                	ld	s3,24(sp)
    800018cc:	6a42                	ld	s4,16(sp)
    800018ce:	6aa2                	ld	s5,8(sp)
    800018d0:	6b02                	ld	s6,0(sp)
    800018d2:	6121                	addi	sp,sp,64
    800018d4:	8082                	ret

00000000800018d6 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800018d6:	1141                	addi	sp,sp,-16
    800018d8:	e422                	sd	s0,8(sp)
    800018da:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800018dc:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800018de:	2501                	sext.w	a0,a0
    800018e0:	6422                	ld	s0,8(sp)
    800018e2:	0141                	addi	sp,sp,16
    800018e4:	8082                	ret

00000000800018e6 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800018e6:	1141                	addi	sp,sp,-16
    800018e8:	e422                	sd	s0,8(sp)
    800018ea:	0800                	addi	s0,sp,16
    800018ec:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800018ee:	2781                	sext.w	a5,a5
    800018f0:	079e                	slli	a5,a5,0x7
  return c;
}
    800018f2:	0000e517          	auipc	a0,0xe
    800018f6:	33e50513          	addi	a0,a0,830 # 8000fc30 <cpus>
    800018fa:	953e                	add	a0,a0,a5
    800018fc:	6422                	ld	s0,8(sp)
    800018fe:	0141                	addi	sp,sp,16
    80001900:	8082                	ret

0000000080001902 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001902:	1101                	addi	sp,sp,-32
    80001904:	ec06                	sd	ra,24(sp)
    80001906:	e822                	sd	s0,16(sp)
    80001908:	e426                	sd	s1,8(sp)
    8000190a:	1000                	addi	s0,sp,32
  push_off();
    8000190c:	aa8ff0ef          	jal	80000bb4 <push_off>
    80001910:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001912:	2781                	sext.w	a5,a5
    80001914:	079e                	slli	a5,a5,0x7
    80001916:	0000e717          	auipc	a4,0xe
    8000191a:	2ea70713          	addi	a4,a4,746 # 8000fc00 <pid_lock>
    8000191e:	97ba                	add	a5,a5,a4
    80001920:	7b84                	ld	s1,48(a5)
  pop_off();
    80001922:	b16ff0ef          	jal	80000c38 <pop_off>
  return p;
}
    80001926:	8526                	mv	a0,s1
    80001928:	60e2                	ld	ra,24(sp)
    8000192a:	6442                	ld	s0,16(sp)
    8000192c:	64a2                	ld	s1,8(sp)
    8000192e:	6105                	addi	sp,sp,32
    80001930:	8082                	ret

0000000080001932 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001932:	1141                	addi	sp,sp,-16
    80001934:	e406                	sd	ra,8(sp)
    80001936:	e022                	sd	s0,0(sp)
    80001938:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    8000193a:	fc9ff0ef          	jal	80001902 <myproc>
    8000193e:	b4eff0ef          	jal	80000c8c <release>

  if (first) {
    80001942:	00006797          	auipc	a5,0x6
    80001946:	10e7a783          	lw	a5,270(a5) # 80007a50 <first.1>
    8000194a:	e799                	bnez	a5,80001958 <forkret+0x26>
    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
    8000194c:	66b000ef          	jal	800027b6 <usertrapret>
}
    80001950:	60a2                	ld	ra,8(sp)
    80001952:	6402                	ld	s0,0(sp)
    80001954:	0141                	addi	sp,sp,16
    80001956:	8082                	ret
    fsinit(ROOTDEV);
    80001958:	4505                	li	a0,1
    8000195a:	333010ef          	jal	8000348c <fsinit>
    first = 0;
    8000195e:	00006797          	auipc	a5,0x6
    80001962:	0e07a923          	sw	zero,242(a5) # 80007a50 <first.1>
    __sync_synchronize();
    80001966:	0ff0000f          	fence
    8000196a:	b7cd                	j	8000194c <forkret+0x1a>

000000008000196c <freethread>:
freethread(struct thread *t) {
    8000196c:	1101                	addi	sp,sp,-32
    8000196e:	ec06                	sd	ra,24(sp)
    80001970:	e822                	sd	s0,16(sp)
    80001972:	e426                	sd	s1,8(sp)
    80001974:	1000                	addi	s0,sp,32
    80001976:	84aa                	mv	s1,a0
    t->state = THREAD_UNUSED;
    80001978:	00052023          	sw	zero,0(a0)
    if (t->trapframe)
    8000197c:	6508                	ld	a0,8(a0)
    8000197e:	c119                	beqz	a0,80001984 <freethread+0x18>
        kfree((void*)t->trapframe);
    80001980:	8c2ff0ef          	jal	80000a42 <kfree>
    t->trapframe = 0;
    80001984:	0004b423          	sd	zero,8(s1)
    t->id = 0;
    80001988:	0004a823          	sw	zero,16(s1)
    t->join = 0;
    8000198c:	0004aa23          	sw	zero,20(s1)
}
    80001990:	60e2                	ld	ra,24(sp)
    80001992:	6442                	ld	s0,16(sp)
    80001994:	64a2                	ld	s1,8(sp)
    80001996:	6105                	addi	sp,sp,32
    80001998:	8082                	ret

000000008000199a <initthread>:
initthread(struct proc *p) {
    8000199a:	7179                	addi	sp,sp,-48
    8000199c:	f406                	sd	ra,40(sp)
    8000199e:	f022                	sd	s0,32(sp)
    800019a0:	ec26                	sd	s1,24(sp)
    800019a2:	e84a                	sd	s2,16(sp)
    800019a4:	1800                	addi	s0,sp,48
    800019a6:	84aa                	mv	s1,a0
    if (!p->current_thread) {
    800019a8:	1e853783          	ld	a5,488(a0)
    800019ac:	cb91                	beqz	a5,800019c0 <initthread+0x26>
    return p->current_thread;
    800019ae:	1e84b903          	ld	s2,488(s1)
}
    800019b2:	854a                	mv	a0,s2
    800019b4:	70a2                	ld	ra,40(sp)
    800019b6:	7402                	ld	s0,32(sp)
    800019b8:	64e2                	ld	s1,24(sp)
    800019ba:	6942                	ld	s2,16(sp)
    800019bc:	6145                	addi	sp,sp,48
    800019be:	8082                	ret
    800019c0:	e44e                	sd	s3,8(sp)
            p->threads[i].trapframe = 0;
    800019c2:	16053823          	sd	zero,368(a0)
            freethread(&p->threads[i]);
    800019c6:	16850993          	addi	s3,a0,360
    800019ca:	854e                	mv	a0,s3
    800019cc:	fa1ff0ef          	jal	8000196c <freethread>
            p->threads[i].trapframe = 0;
    800019d0:	1804b823          	sd	zero,400(s1)
            freethread(&p->threads[i]);
    800019d4:	18848513          	addi	a0,s1,392
    800019d8:	f95ff0ef          	jal	8000196c <freethread>
            p->threads[i].trapframe = 0;
    800019dc:	1a04b823          	sd	zero,432(s1)
            freethread(&p->threads[i]);
    800019e0:	1a848513          	addi	a0,s1,424
    800019e4:	f89ff0ef          	jal	8000196c <freethread>
            p->threads[i].trapframe = 0;
    800019e8:	1c04b823          	sd	zero,464(s1)
            freethread(&p->threads[i]);
    800019ec:	1c848513          	addi	a0,s1,456
    800019f0:	f7dff0ef          	jal	8000196c <freethread>
        t->id = p->pid;
    800019f4:	589c                	lw	a5,48(s1)
    800019f6:	16f4ac23          	sw	a5,376(s1)
        if ((t->trapframe = (struct trapframe *)kalloc()) == 0) {
    800019fa:	92aff0ef          	jal	80000b24 <kalloc>
    800019fe:	892a                	mv	s2,a0
    80001a00:	16a4b823          	sd	a0,368(s1)
    80001a04:	c901                	beqz	a0,80001a14 <initthread+0x7a>
        t->state = THREAD_RUNNING;
    80001a06:	4789                	li	a5,2
    80001a08:	16f4a423          	sw	a5,360(s1)
        p->current_thread = t;
    80001a0c:	1f34b423          	sd	s3,488(s1)
    80001a10:	69a2                	ld	s3,8(sp)
    80001a12:	bf71                	j	800019ae <initthread+0x14>
            freethread(t);
    80001a14:	854e                	mv	a0,s3
    80001a16:	f57ff0ef          	jal	8000196c <freethread>
            return 0;
    80001a1a:	69a2                	ld	s3,8(sp)
    80001a1c:	bf59                	j	800019b2 <initthread+0x18>

0000000080001a1e <thread_schd>:
    if (!p->current_thread) {
    80001a1e:	1e853783          	ld	a5,488(a0)
    80001a22:	cbed                	beqz	a5,80001b14 <thread_schd+0xf6>
thread_schd(struct proc *p) {
    80001a24:	1101                	addi	sp,sp,-32
    80001a26:	ec06                	sd	ra,24(sp)
    80001a28:	e822                	sd	s0,16(sp)
    80001a2a:	e426                	sd	s1,8(sp)
    80001a2c:	e04a                	sd	s2,0(sp)
    80001a2e:	1000                	addi	s0,sp,32
    80001a30:	84aa                	mv	s1,a0
    if (p->current_thread->state == THREAD_RUNNING) {
    80001a32:	4394                	lw	a3,0(a5)
    80001a34:	4709                	li	a4,2
    80001a36:	02e68c63          	beq	a3,a4,80001a6e <thread_schd+0x50>
    acquire(&tickslock);
    80001a3a:	00016517          	auipc	a0,0x16
    80001a3e:	1f650513          	addi	a0,a0,502 # 80017c30 <tickslock>
    80001a42:	9b2ff0ef          	jal	80000bf4 <acquire>
    uint ticks0 = ticks;
    80001a46:	00006917          	auipc	s2,0x6
    80001a4a:	08a92903          	lw	s2,138(s2) # 80007ad0 <ticks>
    release(&tickslock);
    80001a4e:	00016517          	auipc	a0,0x16
    80001a52:	1e250513          	addi	a0,a0,482 # 80017c30 <tickslock>
    80001a56:	a36ff0ef          	jal	80000c8c <release>
    struct thread *t = p->current_thread + 1;
    80001a5a:	1e84b803          	ld	a6,488(s1)
    80001a5e:	02080793          	addi	a5,a6,32
    80001a62:	4711                	li	a4,4
        if (t >= p->threads + NTHREAD) {
    80001a64:	1e848593          	addi	a1,s1,488
        if (t->state == THREAD_RUNNABLE) {
    80001a68:	4605                	li	a2,1
        } else if (t->state == THREAD_SLEEPING && ticks0 - t->sleep_tick0 >= t->sleep_n) {
    80001a6a:	4511                	li	a0,4
    80001a6c:	a829                	j	80001a86 <thread_schd+0x68>
        p->current_thread->state = THREAD_RUNNABLE;
    80001a6e:	4705                	li	a4,1
    80001a70:	c398                	sw	a4,0(a5)
    80001a72:	b7e1                	j	80001a3a <thread_schd+0x1c>
        if (t->state == THREAD_RUNNABLE) {
    80001a74:	4394                	lw	a3,0(a5)
    80001a76:	02c68463          	beq	a3,a2,80001a9e <thread_schd+0x80>
        } else if (t->state == THREAD_SLEEPING && ticks0 - t->sleep_tick0 >= t->sleep_n) {
    80001a7a:	00a68b63          	beq	a3,a0,80001a90 <thread_schd+0x72>
    for (int i = 0; i < NTHREAD; i++, t++) {
    80001a7e:	02078793          	addi	a5,a5,32
    80001a82:	377d                	addiw	a4,a4,-1
    80001a84:	c349                	beqz	a4,80001b06 <thread_schd+0xe8>
        if (t >= p->threads + NTHREAD) {
    80001a86:	feb7e7e3          	bltu	a5,a1,80001a74 <thread_schd+0x56>
            t = p->threads;
    80001a8a:	16848793          	addi	a5,s1,360
    80001a8e:	b7dd                	j	80001a74 <thread_schd+0x56>
        } else if (t->state == THREAD_SLEEPING && ticks0 - t->sleep_tick0 >= t->sleep_n) {
    80001a90:	4fd4                	lw	a3,28(a5)
    80001a92:	40d906bb          	subw	a3,s2,a3
    80001a96:	0187a883          	lw	a7,24(a5)
    80001a9a:	ff16e2e3          	bltu	a3,a7,80001a7e <thread_schd+0x60>
    } else if (p->current_thread != next) {
    80001a9e:	06f80d63          	beq	a6,a5,80001b18 <thread_schd+0xfa>
        next->state = THREAD_RUNNING;
    80001aa2:	4709                	li	a4,2
    80001aa4:	c398                	sw	a4,0(a5)
        struct thread *t = p->current_thread;
    80001aa6:	1e84b703          	ld	a4,488(s1)
        p->current_thread = next;
    80001aaa:	1ef4b423          	sd	a5,488(s1)
        if (t->trapframe) {
    80001aae:	6714                	ld	a3,8(a4)
    80001ab0:	c685                	beqz	a3,80001ad8 <thread_schd+0xba>
            *t->trapframe = *p->trapframe;
    80001ab2:	6cb8                	ld	a4,88(s1)
    80001ab4:	12070893          	addi	a7,a4,288
    80001ab8:	00073803          	ld	a6,0(a4)
    80001abc:	6708                	ld	a0,8(a4)
    80001abe:	6b0c                	ld	a1,16(a4)
    80001ac0:	6f10                	ld	a2,24(a4)
    80001ac2:	0106b023          	sd	a6,0(a3) # 1000 <_entry-0x7ffff000>
    80001ac6:	e688                	sd	a0,8(a3)
    80001ac8:	ea8c                	sd	a1,16(a3)
    80001aca:	ee90                	sd	a2,24(a3)
    80001acc:	02070713          	addi	a4,a4,32
    80001ad0:	02068693          	addi	a3,a3,32
    80001ad4:	ff1712e3          	bne	a4,a7,80001ab8 <thread_schd+0x9a>
        *p->trapframe = *next->trapframe;
    80001ad8:	6794                	ld	a3,8(a5)
    80001ada:	87b6                	mv	a5,a3
    80001adc:	6cb8                	ld	a4,88(s1)
    80001ade:	12068693          	addi	a3,a3,288
    80001ae2:	0007b803          	ld	a6,0(a5)
    80001ae6:	6788                	ld	a0,8(a5)
    80001ae8:	6b8c                	ld	a1,16(a5)
    80001aea:	6f90                	ld	a2,24(a5)
    80001aec:	01073023          	sd	a6,0(a4)
    80001af0:	e708                	sd	a0,8(a4)
    80001af2:	eb0c                	sd	a1,16(a4)
    80001af4:	ef10                	sd	a2,24(a4)
    80001af6:	02078793          	addi	a5,a5,32
    80001afa:	02070713          	addi	a4,a4,32
    80001afe:	fed792e3          	bne	a5,a3,80001ae2 <thread_schd+0xc4>
    return 1;
    80001b02:	4505                	li	a0,1
    80001b04:	a011                	j	80001b08 <thread_schd+0xea>
        return 0;
    80001b06:	4501                	li	a0,0
}
    80001b08:	60e2                	ld	ra,24(sp)
    80001b0a:	6442                	ld	s0,16(sp)
    80001b0c:	64a2                	ld	s1,8(sp)
    80001b0e:	6902                	ld	s2,0(sp)
    80001b10:	6105                	addi	sp,sp,32
    80001b12:	8082                	ret
        return 1;
    80001b14:	4505                	li	a0,1
}
    80001b16:	8082                	ret
    return 1;
    80001b18:	4505                	li	a0,1
    80001b1a:	b7fd                	j	80001b08 <thread_schd+0xea>

0000000080001b1c <sleepthread>:
sleepthread(int n, uint ticks0) {
    80001b1c:	1101                	addi	sp,sp,-32
    80001b1e:	ec06                	sd	ra,24(sp)
    80001b20:	e822                	sd	s0,16(sp)
    80001b22:	e426                	sd	s1,8(sp)
    80001b24:	e04a                	sd	s2,0(sp)
    80001b26:	1000                	addi	s0,sp,32
    80001b28:	892a                	mv	s2,a0
    80001b2a:	84ae                	mv	s1,a1
    struct thread *t = myproc()->current_thread;
    80001b2c:	dd7ff0ef          	jal	80001902 <myproc>
    80001b30:	1e853783          	ld	a5,488(a0)
    t->sleep_n = n;
    80001b34:	0127ac23          	sw	s2,24(a5)
    t->sleep_tick0 = ticks0;
    80001b38:	cfc4                	sw	s1,28(a5)
    t->state = THREAD_SLEEPING;
    80001b3a:	4711                	li	a4,4
    80001b3c:	c398                	sw	a4,0(a5)
    thread_schd(myproc());
    80001b3e:	dc5ff0ef          	jal	80001902 <myproc>
    80001b42:	eddff0ef          	jal	80001a1e <thread_schd>
}
    80001b46:	60e2                	ld	ra,24(sp)
    80001b48:	6442                	ld	s0,16(sp)
    80001b4a:	64a2                	ld	s1,8(sp)
    80001b4c:	6902                	ld	s2,0(sp)
    80001b4e:	6105                	addi	sp,sp,32
    80001b50:	8082                	ret

0000000080001b52 <allocpid>:
{
    80001b52:	1101                	addi	sp,sp,-32
    80001b54:	ec06                	sd	ra,24(sp)
    80001b56:	e822                	sd	s0,16(sp)
    80001b58:	e426                	sd	s1,8(sp)
    80001b5a:	e04a                	sd	s2,0(sp)
    80001b5c:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001b5e:	0000e917          	auipc	s2,0xe
    80001b62:	0a290913          	addi	s2,s2,162 # 8000fc00 <pid_lock>
    80001b66:	854a                	mv	a0,s2
    80001b68:	88cff0ef          	jal	80000bf4 <acquire>
  pid = nextpid;
    80001b6c:	00006797          	auipc	a5,0x6
    80001b70:	ee878793          	addi	a5,a5,-280 # 80007a54 <nextpid>
    80001b74:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001b76:	0014871b          	addiw	a4,s1,1
    80001b7a:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001b7c:	854a                	mv	a0,s2
    80001b7e:	90eff0ef          	jal	80000c8c <release>
}
    80001b82:	8526                	mv	a0,s1
    80001b84:	60e2                	ld	ra,24(sp)
    80001b86:	6442                	ld	s0,16(sp)
    80001b88:	64a2                	ld	s1,8(sp)
    80001b8a:	6902                	ld	s2,0(sp)
    80001b8c:	6105                	addi	sp,sp,32
    80001b8e:	8082                	ret

0000000080001b90 <allocthread>:
allocthread(uint64 start_thread, uint64 stack_address, uint64 arg) {
    80001b90:	7139                	addi	sp,sp,-64
    80001b92:	fc06                	sd	ra,56(sp)
    80001b94:	f822                	sd	s0,48(sp)
    80001b96:	f426                	sd	s1,40(sp)
    80001b98:	f04a                	sd	s2,32(sp)
    80001b9a:	e852                	sd	s4,16(sp)
    80001b9c:	e456                	sd	s5,8(sp)
    80001b9e:	e05a                	sd	s6,0(sp)
    80001ba0:	0080                	addi	s0,sp,64
    80001ba2:	8a2a                	mv	s4,a0
    80001ba4:	8b2e                	mv	s6,a1
    80001ba6:	8ab2                	mv	s5,a2
    struct proc *p = myproc();
    80001ba8:	d5bff0ef          	jal	80001902 <myproc>
    80001bac:	892a                	mv	s2,a0
    if (!initthread(p))
    80001bae:	dedff0ef          	jal	8000199a <initthread>
    80001bb2:	84aa                	mv	s1,a0
    80001bb4:	cd11                	beqz	a0,80001bd0 <allocthread+0x40>
    for (struct thread *t = p->threads; t < p->threads + NTHREAD; t++) {
    80001bb6:	16890493          	addi	s1,s2,360
    80001bba:	1e890713          	addi	a4,s2,488
    80001bbe:	08e4f563          	bgeu	s1,a4,80001c48 <allocthread+0xb8>
        if (t->state == THREAD_UNUSED) {
    80001bc2:	409c                	lw	a5,0(s1)
    80001bc4:	c385                	beqz	a5,80001be4 <allocthread+0x54>
    for (struct thread *t = p->threads; t < p->threads + NTHREAD; t++) {
    80001bc6:	02048493          	addi	s1,s1,32
    80001bca:	fee49ce3          	bne	s1,a4,80001bc2 <allocthread+0x32>
    return 0;
    80001bce:	4481                	li	s1,0
}
    80001bd0:	8526                	mv	a0,s1
    80001bd2:	70e2                	ld	ra,56(sp)
    80001bd4:	7442                	ld	s0,48(sp)
    80001bd6:	74a2                	ld	s1,40(sp)
    80001bd8:	7902                	ld	s2,32(sp)
    80001bda:	6a42                	ld	s4,16(sp)
    80001bdc:	6aa2                	ld	s5,8(sp)
    80001bde:	6b02                	ld	s6,0(sp)
    80001be0:	6121                	addi	sp,sp,64
    80001be2:	8082                	ret
    80001be4:	ec4e                	sd	s3,24(sp)
            t->id = allocpid();
    80001be6:	f6dff0ef          	jal	80001b52 <allocpid>
    80001bea:	c888                	sw	a0,16(s1)
            if ((t->trapframe = (struct trapframe *)kalloc()) == 0) {
    80001bec:	f39fe0ef          	jal	80000b24 <kalloc>
    80001bf0:	89aa                	mv	s3,a0
    80001bf2:	e488                	sd	a0,8(s1)
    80001bf4:	c521                	beqz	a0,80001c3c <allocthread+0xac>
            t->state = THREAD_RUNNABLE;
    80001bf6:	4785                	li	a5,1
    80001bf8:	c09c                	sw	a5,0(s1)
            *t->trapframe = *p->trapframe;
    80001bfa:	05893703          	ld	a4,88(s2)
    80001bfe:	87aa                	mv	a5,a0
    80001c00:	12070813          	addi	a6,a4,288
    80001c04:	6308                	ld	a0,0(a4)
    80001c06:	670c                	ld	a1,8(a4)
    80001c08:	6b10                	ld	a2,16(a4)
    80001c0a:	6f14                	ld	a3,24(a4)
    80001c0c:	e388                	sd	a0,0(a5)
    80001c0e:	e78c                	sd	a1,8(a5)
    80001c10:	eb90                	sd	a2,16(a5)
    80001c12:	ef94                	sd	a3,24(a5)
    80001c14:	02070713          	addi	a4,a4,32
    80001c18:	02078793          	addi	a5,a5,32
    80001c1c:	ff0714e3          	bne	a4,a6,80001c04 <allocthread+0x74>
            t->trapframe->sp = stack_address;
    80001c20:	649c                	ld	a5,8(s1)
    80001c22:	0367b823          	sd	s6,48(a5)
            t->trapframe->a0 = arg;
    80001c26:	649c                	ld	a5,8(s1)
    80001c28:	0757b823          	sd	s5,112(a5)
            t->trapframe->ra = -1;
    80001c2c:	649c                	ld	a5,8(s1)
    80001c2e:	577d                	li	a4,-1
    80001c30:	f798                	sd	a4,40(a5)
            t->trapframe->epc = start_thread;
    80001c32:	649c                	ld	a5,8(s1)
    80001c34:	0147bc23          	sd	s4,24(a5)
            return t;
    80001c38:	69e2                	ld	s3,24(sp)
    80001c3a:	bf59                	j	80001bd0 <allocthread+0x40>
                freethread(t);
    80001c3c:	8526                	mv	a0,s1
    80001c3e:	d2fff0ef          	jal	8000196c <freethread>
    return 0;
    80001c42:	84ce                	mv	s1,s3
                break;
    80001c44:	69e2                	ld	s3,24(sp)
    80001c46:	b769                	j	80001bd0 <allocthread+0x40>
    return 0;
    80001c48:	4481                	li	s1,0
    80001c4a:	b759                	j	80001bd0 <allocthread+0x40>

0000000080001c4c <proc_pagetable>:
{
    80001c4c:	1101                	addi	sp,sp,-32
    80001c4e:	ec06                	sd	ra,24(sp)
    80001c50:	e822                	sd	s0,16(sp)
    80001c52:	e426                	sd	s1,8(sp)
    80001c54:	e04a                	sd	s2,0(sp)
    80001c56:	1000                	addi	s0,sp,32
    80001c58:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001c5a:	e46ff0ef          	jal	800012a0 <uvmcreate>
    80001c5e:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001c60:	cd05                	beqz	a0,80001c98 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001c62:	4729                	li	a4,10
    80001c64:	00004697          	auipc	a3,0x4
    80001c68:	39c68693          	addi	a3,a3,924 # 80006000 <_trampoline>
    80001c6c:	6605                	lui	a2,0x1
    80001c6e:	040005b7          	lui	a1,0x4000
    80001c72:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c74:	05b2                	slli	a1,a1,0xc
    80001c76:	bc8ff0ef          	jal	8000103e <mappages>
    80001c7a:	02054663          	bltz	a0,80001ca6 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001c7e:	4719                	li	a4,6
    80001c80:	05893683          	ld	a3,88(s2)
    80001c84:	6605                	lui	a2,0x1
    80001c86:	020005b7          	lui	a1,0x2000
    80001c8a:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001c8c:	05b6                	slli	a1,a1,0xd
    80001c8e:	8526                	mv	a0,s1
    80001c90:	baeff0ef          	jal	8000103e <mappages>
    80001c94:	00054f63          	bltz	a0,80001cb2 <proc_pagetable+0x66>
}
    80001c98:	8526                	mv	a0,s1
    80001c9a:	60e2                	ld	ra,24(sp)
    80001c9c:	6442                	ld	s0,16(sp)
    80001c9e:	64a2                	ld	s1,8(sp)
    80001ca0:	6902                	ld	s2,0(sp)
    80001ca2:	6105                	addi	sp,sp,32
    80001ca4:	8082                	ret
    uvmfree(pagetable, 0);
    80001ca6:	4581                	li	a1,0
    80001ca8:	8526                	mv	a0,s1
    80001caa:	fc4ff0ef          	jal	8000146e <uvmfree>
    return 0;
    80001cae:	4481                	li	s1,0
    80001cb0:	b7e5                	j	80001c98 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001cb2:	4681                	li	a3,0
    80001cb4:	4605                	li	a2,1
    80001cb6:	040005b7          	lui	a1,0x4000
    80001cba:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001cbc:	05b2                	slli	a1,a1,0xc
    80001cbe:	8526                	mv	a0,s1
    80001cc0:	d24ff0ef          	jal	800011e4 <uvmunmap>
    uvmfree(pagetable, 0);
    80001cc4:	4581                	li	a1,0
    80001cc6:	8526                	mv	a0,s1
    80001cc8:	fa6ff0ef          	jal	8000146e <uvmfree>
    return 0;
    80001ccc:	4481                	li	s1,0
    80001cce:	b7e9                	j	80001c98 <proc_pagetable+0x4c>

0000000080001cd0 <proc_freepagetable>:
{
    80001cd0:	1101                	addi	sp,sp,-32
    80001cd2:	ec06                	sd	ra,24(sp)
    80001cd4:	e822                	sd	s0,16(sp)
    80001cd6:	e426                	sd	s1,8(sp)
    80001cd8:	e04a                	sd	s2,0(sp)
    80001cda:	1000                	addi	s0,sp,32
    80001cdc:	84aa                	mv	s1,a0
    80001cde:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ce0:	4681                	li	a3,0
    80001ce2:	4605                	li	a2,1
    80001ce4:	040005b7          	lui	a1,0x4000
    80001ce8:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001cea:	05b2                	slli	a1,a1,0xc
    80001cec:	cf8ff0ef          	jal	800011e4 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001cf0:	4681                	li	a3,0
    80001cf2:	4605                	li	a2,1
    80001cf4:	020005b7          	lui	a1,0x2000
    80001cf8:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001cfa:	05b6                	slli	a1,a1,0xd
    80001cfc:	8526                	mv	a0,s1
    80001cfe:	ce6ff0ef          	jal	800011e4 <uvmunmap>
  uvmfree(pagetable, sz);
    80001d02:	85ca                	mv	a1,s2
    80001d04:	8526                	mv	a0,s1
    80001d06:	f68ff0ef          	jal	8000146e <uvmfree>
}
    80001d0a:	60e2                	ld	ra,24(sp)
    80001d0c:	6442                	ld	s0,16(sp)
    80001d0e:	64a2                	ld	s1,8(sp)
    80001d10:	6902                	ld	s2,0(sp)
    80001d12:	6105                	addi	sp,sp,32
    80001d14:	8082                	ret

0000000080001d16 <freeproc>:
{
    80001d16:	1101                	addi	sp,sp,-32
    80001d18:	ec06                	sd	ra,24(sp)
    80001d1a:	e822                	sd	s0,16(sp)
    80001d1c:	e426                	sd	s1,8(sp)
    80001d1e:	1000                	addi	s0,sp,32
    80001d20:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001d22:	6d28                	ld	a0,88(a0)
    80001d24:	c119                	beqz	a0,80001d2a <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001d26:	d1dfe0ef          	jal	80000a42 <kfree>
  p->trapframe = 0;
    80001d2a:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001d2e:	68a8                	ld	a0,80(s1)
    80001d30:	c501                	beqz	a0,80001d38 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001d32:	64ac                	ld	a1,72(s1)
    80001d34:	f9dff0ef          	jal	80001cd0 <proc_freepagetable>
  p->pagetable = 0;
    80001d38:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001d3c:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001d40:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001d44:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001d48:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001d4c:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001d50:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001d54:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001d58:	0004ac23          	sw	zero,24(s1)
      freethread(&p->threads[i]);
    80001d5c:	16848513          	addi	a0,s1,360
    80001d60:	c0dff0ef          	jal	8000196c <freethread>
    80001d64:	18848513          	addi	a0,s1,392
    80001d68:	c05ff0ef          	jal	8000196c <freethread>
    80001d6c:	1a848513          	addi	a0,s1,424
    80001d70:	bfdff0ef          	jal	8000196c <freethread>
    80001d74:	1c848513          	addi	a0,s1,456
    80001d78:	bf5ff0ef          	jal	8000196c <freethread>
  p->current_thread = 0; // Reset current_thread to null
    80001d7c:	1e04b423          	sd	zero,488(s1)
}
    80001d80:	60e2                	ld	ra,24(sp)
    80001d82:	6442                	ld	s0,16(sp)
    80001d84:	64a2                	ld	s1,8(sp)
    80001d86:	6105                	addi	sp,sp,32
    80001d88:	8082                	ret

0000000080001d8a <allocproc>:
{
    80001d8a:	1101                	addi	sp,sp,-32
    80001d8c:	ec06                	sd	ra,24(sp)
    80001d8e:	e822                	sd	s0,16(sp)
    80001d90:	e426                	sd	s1,8(sp)
    80001d92:	e04a                	sd	s2,0(sp)
    80001d94:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d96:	0000e497          	auipc	s1,0xe
    80001d9a:	29a48493          	addi	s1,s1,666 # 80010030 <proc>
    80001d9e:	00016917          	auipc	s2,0x16
    80001da2:	e9290913          	addi	s2,s2,-366 # 80017c30 <tickslock>
    acquire(&p->lock);
    80001da6:	8526                	mv	a0,s1
    80001da8:	e4dfe0ef          	jal	80000bf4 <acquire>
    if(p->state == UNUSED) {
    80001dac:	4c9c                	lw	a5,24(s1)
    80001dae:	cb91                	beqz	a5,80001dc2 <allocproc+0x38>
      release(&p->lock);
    80001db0:	8526                	mv	a0,s1
    80001db2:	edbfe0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001db6:	1f048493          	addi	s1,s1,496
    80001dba:	ff2496e3          	bne	s1,s2,80001da6 <allocproc+0x1c>
  return 0;
    80001dbe:	4481                	li	s1,0
    80001dc0:	a089                	j	80001e02 <allocproc+0x78>
  p->pid = allocpid();
    80001dc2:	d91ff0ef          	jal	80001b52 <allocpid>
    80001dc6:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001dc8:	4785                	li	a5,1
    80001dca:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001dcc:	d59fe0ef          	jal	80000b24 <kalloc>
    80001dd0:	892a                	mv	s2,a0
    80001dd2:	eca8                	sd	a0,88(s1)
    80001dd4:	cd15                	beqz	a0,80001e10 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001dd6:	8526                	mv	a0,s1
    80001dd8:	e75ff0ef          	jal	80001c4c <proc_pagetable>
    80001ddc:	892a                	mv	s2,a0
    80001dde:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001de0:	c121                	beqz	a0,80001e20 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001de2:	07000613          	li	a2,112
    80001de6:	4581                	li	a1,0
    80001de8:	06048513          	addi	a0,s1,96
    80001dec:	eddfe0ef          	jal	80000cc8 <memset>
  p->context.ra = (uint64)forkret;
    80001df0:	00000797          	auipc	a5,0x0
    80001df4:	b4278793          	addi	a5,a5,-1214 # 80001932 <forkret>
    80001df8:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001dfa:	60bc                	ld	a5,64(s1)
    80001dfc:	6705                	lui	a4,0x1
    80001dfe:	97ba                	add	a5,a5,a4
    80001e00:	f4bc                	sd	a5,104(s1)
}
    80001e02:	8526                	mv	a0,s1
    80001e04:	60e2                	ld	ra,24(sp)
    80001e06:	6442                	ld	s0,16(sp)
    80001e08:	64a2                	ld	s1,8(sp)
    80001e0a:	6902                	ld	s2,0(sp)
    80001e0c:	6105                	addi	sp,sp,32
    80001e0e:	8082                	ret
    freeproc(p);
    80001e10:	8526                	mv	a0,s1
    80001e12:	f05ff0ef          	jal	80001d16 <freeproc>
    release(&p->lock);
    80001e16:	8526                	mv	a0,s1
    80001e18:	e75fe0ef          	jal	80000c8c <release>
    return 0;
    80001e1c:	84ca                	mv	s1,s2
    80001e1e:	b7d5                	j	80001e02 <allocproc+0x78>
    freeproc(p);
    80001e20:	8526                	mv	a0,s1
    80001e22:	ef5ff0ef          	jal	80001d16 <freeproc>
    release(&p->lock);
    80001e26:	8526                	mv	a0,s1
    80001e28:	e65fe0ef          	jal	80000c8c <release>
    return 0;
    80001e2c:	84ca                	mv	s1,s2
    80001e2e:	bfd1                	j	80001e02 <allocproc+0x78>

0000000080001e30 <userinit>:
{
    80001e30:	1101                	addi	sp,sp,-32
    80001e32:	ec06                	sd	ra,24(sp)
    80001e34:	e822                	sd	s0,16(sp)
    80001e36:	e426                	sd	s1,8(sp)
    80001e38:	1000                	addi	s0,sp,32
  p = allocproc();
    80001e3a:	f51ff0ef          	jal	80001d8a <allocproc>
    80001e3e:	84aa                	mv	s1,a0
  initproc = p;
    80001e40:	00006797          	auipc	a5,0x6
    80001e44:	c8a7b423          	sd	a0,-888(a5) # 80007ac8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001e48:	03400613          	li	a2,52
    80001e4c:	00006597          	auipc	a1,0x6
    80001e50:	c1458593          	addi	a1,a1,-1004 # 80007a60 <initcode>
    80001e54:	6928                	ld	a0,80(a0)
    80001e56:	c70ff0ef          	jal	800012c6 <uvmfirst>
  p->sz = PGSIZE;
    80001e5a:	6785                	lui	a5,0x1
    80001e5c:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001e5e:	6cb8                	ld	a4,88(s1)
    80001e60:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001e64:	6cb8                	ld	a4,88(s1)
    80001e66:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001e68:	4641                	li	a2,16
    80001e6a:	00005597          	auipc	a1,0x5
    80001e6e:	4ae58593          	addi	a1,a1,1198 # 80007318 <etext+0x318>
    80001e72:	15848513          	addi	a0,s1,344
    80001e76:	f91fe0ef          	jal	80000e06 <safestrcpy>
  p->cwd = namei("/");
    80001e7a:	00005517          	auipc	a0,0x5
    80001e7e:	4ae50513          	addi	a0,a0,1198 # 80007328 <etext+0x328>
    80001e82:	719010ef          	jal	80003d9a <namei>
    80001e86:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001e8a:	478d                	li	a5,3
    80001e8c:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001e8e:	8526                	mv	a0,s1
    80001e90:	dfdfe0ef          	jal	80000c8c <release>
}
    80001e94:	60e2                	ld	ra,24(sp)
    80001e96:	6442                	ld	s0,16(sp)
    80001e98:	64a2                	ld	s1,8(sp)
    80001e9a:	6105                	addi	sp,sp,32
    80001e9c:	8082                	ret

0000000080001e9e <growproc>:
{
    80001e9e:	1101                	addi	sp,sp,-32
    80001ea0:	ec06                	sd	ra,24(sp)
    80001ea2:	e822                	sd	s0,16(sp)
    80001ea4:	e426                	sd	s1,8(sp)
    80001ea6:	e04a                	sd	s2,0(sp)
    80001ea8:	1000                	addi	s0,sp,32
    80001eaa:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001eac:	a57ff0ef          	jal	80001902 <myproc>
    80001eb0:	84aa                	mv	s1,a0
  sz = p->sz;
    80001eb2:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001eb4:	01204c63          	bgtz	s2,80001ecc <growproc+0x2e>
  } else if(n < 0){
    80001eb8:	02094463          	bltz	s2,80001ee0 <growproc+0x42>
  p->sz = sz;
    80001ebc:	e4ac                	sd	a1,72(s1)
  return 0;
    80001ebe:	4501                	li	a0,0
}
    80001ec0:	60e2                	ld	ra,24(sp)
    80001ec2:	6442                	ld	s0,16(sp)
    80001ec4:	64a2                	ld	s1,8(sp)
    80001ec6:	6902                	ld	s2,0(sp)
    80001ec8:	6105                	addi	sp,sp,32
    80001eca:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001ecc:	4691                	li	a3,4
    80001ece:	00b90633          	add	a2,s2,a1
    80001ed2:	6928                	ld	a0,80(a0)
    80001ed4:	c94ff0ef          	jal	80001368 <uvmalloc>
    80001ed8:	85aa                	mv	a1,a0
    80001eda:	f16d                	bnez	a0,80001ebc <growproc+0x1e>
      return -1;
    80001edc:	557d                	li	a0,-1
    80001ede:	b7cd                	j	80001ec0 <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001ee0:	00b90633          	add	a2,s2,a1
    80001ee4:	6928                	ld	a0,80(a0)
    80001ee6:	c3eff0ef          	jal	80001324 <uvmdealloc>
    80001eea:	85aa                	mv	a1,a0
    80001eec:	bfc1                	j	80001ebc <growproc+0x1e>

0000000080001eee <fork>:
{
    80001eee:	7139                	addi	sp,sp,-64
    80001ef0:	fc06                	sd	ra,56(sp)
    80001ef2:	f822                	sd	s0,48(sp)
    80001ef4:	f04a                	sd	s2,32(sp)
    80001ef6:	e456                	sd	s5,8(sp)
    80001ef8:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001efa:	a09ff0ef          	jal	80001902 <myproc>
    80001efe:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001f00:	e8bff0ef          	jal	80001d8a <allocproc>
    80001f04:	0e050a63          	beqz	a0,80001ff8 <fork+0x10a>
    80001f08:	e852                	sd	s4,16(sp)
    80001f0a:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001f0c:	048ab603          	ld	a2,72(s5)
    80001f10:	692c                	ld	a1,80(a0)
    80001f12:	050ab503          	ld	a0,80(s5)
    80001f16:	d8aff0ef          	jal	800014a0 <uvmcopy>
    80001f1a:	04054a63          	bltz	a0,80001f6e <fork+0x80>
    80001f1e:	f426                	sd	s1,40(sp)
    80001f20:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001f22:	048ab783          	ld	a5,72(s5)
    80001f26:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001f2a:	058ab683          	ld	a3,88(s5)
    80001f2e:	87b6                	mv	a5,a3
    80001f30:	058a3703          	ld	a4,88(s4)
    80001f34:	12068693          	addi	a3,a3,288
    80001f38:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001f3c:	6788                	ld	a0,8(a5)
    80001f3e:	6b8c                	ld	a1,16(a5)
    80001f40:	6f90                	ld	a2,24(a5)
    80001f42:	01073023          	sd	a6,0(a4)
    80001f46:	e708                	sd	a0,8(a4)
    80001f48:	eb0c                	sd	a1,16(a4)
    80001f4a:	ef10                	sd	a2,24(a4)
    80001f4c:	02078793          	addi	a5,a5,32
    80001f50:	02070713          	addi	a4,a4,32
    80001f54:	fed792e3          	bne	a5,a3,80001f38 <fork+0x4a>
  np->trapframe->a0 = 0;
    80001f58:	058a3783          	ld	a5,88(s4)
    80001f5c:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001f60:	0d0a8493          	addi	s1,s5,208
    80001f64:	0d0a0913          	addi	s2,s4,208
    80001f68:	150a8993          	addi	s3,s5,336
    80001f6c:	a831                	j	80001f88 <fork+0x9a>
    freeproc(np);
    80001f6e:	8552                	mv	a0,s4
    80001f70:	da7ff0ef          	jal	80001d16 <freeproc>
    release(&np->lock);
    80001f74:	8552                	mv	a0,s4
    80001f76:	d17fe0ef          	jal	80000c8c <release>
    return -1;
    80001f7a:	597d                	li	s2,-1
    80001f7c:	6a42                	ld	s4,16(sp)
    80001f7e:	a0b5                	j	80001fea <fork+0xfc>
  for(i = 0; i < NOFILE; i++)
    80001f80:	04a1                	addi	s1,s1,8
    80001f82:	0921                	addi	s2,s2,8
    80001f84:	01348963          	beq	s1,s3,80001f96 <fork+0xa8>
    if(p->ofile[i])
    80001f88:	6088                	ld	a0,0(s1)
    80001f8a:	d97d                	beqz	a0,80001f80 <fork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80001f8c:	3f2020ef          	jal	8000437e <filedup>
    80001f90:	00a93023          	sd	a0,0(s2)
    80001f94:	b7f5                	j	80001f80 <fork+0x92>
  np->cwd = idup(p->cwd);
    80001f96:	150ab503          	ld	a0,336(s5)
    80001f9a:	6f0010ef          	jal	8000368a <idup>
    80001f9e:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001fa2:	4641                	li	a2,16
    80001fa4:	158a8593          	addi	a1,s5,344
    80001fa8:	158a0513          	addi	a0,s4,344
    80001fac:	e5bfe0ef          	jal	80000e06 <safestrcpy>
  pid = np->pid;
    80001fb0:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001fb4:	8552                	mv	a0,s4
    80001fb6:	cd7fe0ef          	jal	80000c8c <release>
  acquire(&wait_lock);
    80001fba:	0000e497          	auipc	s1,0xe
    80001fbe:	c5e48493          	addi	s1,s1,-930 # 8000fc18 <wait_lock>
    80001fc2:	8526                	mv	a0,s1
    80001fc4:	c31fe0ef          	jal	80000bf4 <acquire>
  np->parent = p;
    80001fc8:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001fcc:	8526                	mv	a0,s1
    80001fce:	cbffe0ef          	jal	80000c8c <release>
  acquire(&np->lock);
    80001fd2:	8552                	mv	a0,s4
    80001fd4:	c21fe0ef          	jal	80000bf4 <acquire>
  np->state = RUNNABLE;
    80001fd8:	478d                	li	a5,3
    80001fda:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001fde:	8552                	mv	a0,s4
    80001fe0:	cadfe0ef          	jal	80000c8c <release>
  return pid;
    80001fe4:	74a2                	ld	s1,40(sp)
    80001fe6:	69e2                	ld	s3,24(sp)
    80001fe8:	6a42                	ld	s4,16(sp)
}
    80001fea:	854a                	mv	a0,s2
    80001fec:	70e2                	ld	ra,56(sp)
    80001fee:	7442                	ld	s0,48(sp)
    80001ff0:	7902                	ld	s2,32(sp)
    80001ff2:	6aa2                	ld	s5,8(sp)
    80001ff4:	6121                	addi	sp,sp,64
    80001ff6:	8082                	ret
    return -1;
    80001ff8:	597d                	li	s2,-1
    80001ffa:	bfc5                	j	80001fea <fork+0xfc>

0000000080001ffc <scheduler>:
{
    80001ffc:	715d                	addi	sp,sp,-80
    80001ffe:	e486                	sd	ra,72(sp)
    80002000:	e0a2                	sd	s0,64(sp)
    80002002:	fc26                	sd	s1,56(sp)
    80002004:	f84a                	sd	s2,48(sp)
    80002006:	f44e                	sd	s3,40(sp)
    80002008:	f052                	sd	s4,32(sp)
    8000200a:	ec56                	sd	s5,24(sp)
    8000200c:	e85a                	sd	s6,16(sp)
    8000200e:	e45e                	sd	s7,8(sp)
    80002010:	e062                	sd	s8,0(sp)
    80002012:	0880                	addi	s0,sp,80
    80002014:	8792                	mv	a5,tp
  int id = r_tp();
    80002016:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002018:	00779b13          	slli	s6,a5,0x7
    8000201c:	0000e717          	auipc	a4,0xe
    80002020:	be470713          	addi	a4,a4,-1052 # 8000fc00 <pid_lock>
    80002024:	975a                	add	a4,a4,s6
    80002026:	02073823          	sd	zero,48(a4)
            swtch(&c->context, &p->context);
    8000202a:	0000e717          	auipc	a4,0xe
    8000202e:	c0e70713          	addi	a4,a4,-1010 # 8000fc38 <cpus+0x8>
    80002032:	9b3a                	add	s6,s6,a4
            p->state = RUNNING;
    80002034:	4c11                	li	s8,4
            c->proc = p;
    80002036:	079e                	slli	a5,a5,0x7
    80002038:	0000ea17          	auipc	s4,0xe
    8000203c:	bc8a0a13          	addi	s4,s4,-1080 # 8000fc00 <pid_lock>
    80002040:	9a3e                	add	s4,s4,a5
            found = 1;
    80002042:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80002044:	00016997          	auipc	s3,0x16
    80002048:	bec98993          	addi	s3,s3,-1044 # 80017c30 <tickslock>
    8000204c:	a889                	j	8000209e <scheduler+0xa2>
      release(&p->lock);
    8000204e:	8526                	mv	a0,s1
    80002050:	c3dfe0ef          	jal	80000c8c <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80002054:	1f048493          	addi	s1,s1,496
    80002058:	03348963          	beq	s1,s3,8000208a <scheduler+0x8e>
      acquire(&p->lock);
    8000205c:	8526                	mv	a0,s1
    8000205e:	b97fe0ef          	jal	80000bf4 <acquire>
      if(p->state == RUNNABLE) {
    80002062:	4c9c                	lw	a5,24(s1)
    80002064:	ff2795e3          	bne	a5,s2,8000204e <scheduler+0x52>
        if (thread_schd(p)) {
    80002068:	8526                	mv	a0,s1
    8000206a:	9b5ff0ef          	jal	80001a1e <thread_schd>
    8000206e:	d165                	beqz	a0,8000204e <scheduler+0x52>
            p->state = RUNNING;
    80002070:	0184ac23          	sw	s8,24(s1)
            c->proc = p;
    80002074:	029a3823          	sd	s1,48(s4)
            swtch(&c->context, &p->context);
    80002078:	06048593          	addi	a1,s1,96
    8000207c:	855a                	mv	a0,s6
    8000207e:	692000ef          	jal	80002710 <swtch>
            c->proc = 0;
    80002082:	020a3823          	sd	zero,48(s4)
            found = 1;
    80002086:	8ade                	mv	s5,s7
    80002088:	b7d9                	j	8000204e <scheduler+0x52>
    if(found == 0) {
    8000208a:	000a9a63          	bnez	s5,8000209e <scheduler+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000208e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002092:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002096:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    8000209a:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000209e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800020a2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800020a6:	10079073          	csrw	sstatus,a5
    int found = 0;
    800020aa:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    800020ac:	0000e497          	auipc	s1,0xe
    800020b0:	f8448493          	addi	s1,s1,-124 # 80010030 <proc>
      if(p->state == RUNNABLE) {
    800020b4:	490d                	li	s2,3
    800020b6:	b75d                	j	8000205c <scheduler+0x60>

00000000800020b8 <sched>:
{
    800020b8:	7179                	addi	sp,sp,-48
    800020ba:	f406                	sd	ra,40(sp)
    800020bc:	f022                	sd	s0,32(sp)
    800020be:	ec26                	sd	s1,24(sp)
    800020c0:	e84a                	sd	s2,16(sp)
    800020c2:	e44e                	sd	s3,8(sp)
    800020c4:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800020c6:	83dff0ef          	jal	80001902 <myproc>
    800020ca:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800020cc:	abffe0ef          	jal	80000b8a <holding>
    800020d0:	c92d                	beqz	a0,80002142 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    800020d2:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800020d4:	2781                	sext.w	a5,a5
    800020d6:	079e                	slli	a5,a5,0x7
    800020d8:	0000e717          	auipc	a4,0xe
    800020dc:	b2870713          	addi	a4,a4,-1240 # 8000fc00 <pid_lock>
    800020e0:	97ba                	add	a5,a5,a4
    800020e2:	0a87a703          	lw	a4,168(a5)
    800020e6:	4785                	li	a5,1
    800020e8:	06f71363          	bne	a4,a5,8000214e <sched+0x96>
  if(p->state == RUNNING)
    800020ec:	4c98                	lw	a4,24(s1)
    800020ee:	4791                	li	a5,4
    800020f0:	06f70563          	beq	a4,a5,8000215a <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020f4:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800020f8:	8b89                	andi	a5,a5,2
  if(intr_get())
    800020fa:	e7b5                	bnez	a5,80002166 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    800020fc:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800020fe:	0000e917          	auipc	s2,0xe
    80002102:	b0290913          	addi	s2,s2,-1278 # 8000fc00 <pid_lock>
    80002106:	2781                	sext.w	a5,a5
    80002108:	079e                	slli	a5,a5,0x7
    8000210a:	97ca                	add	a5,a5,s2
    8000210c:	0ac7a983          	lw	s3,172(a5)
    80002110:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002112:	2781                	sext.w	a5,a5
    80002114:	079e                	slli	a5,a5,0x7
    80002116:	0000e597          	auipc	a1,0xe
    8000211a:	b2258593          	addi	a1,a1,-1246 # 8000fc38 <cpus+0x8>
    8000211e:	95be                	add	a1,a1,a5
    80002120:	06048513          	addi	a0,s1,96
    80002124:	5ec000ef          	jal	80002710 <swtch>
    80002128:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000212a:	2781                	sext.w	a5,a5
    8000212c:	079e                	slli	a5,a5,0x7
    8000212e:	993e                	add	s2,s2,a5
    80002130:	0b392623          	sw	s3,172(s2)
}
    80002134:	70a2                	ld	ra,40(sp)
    80002136:	7402                	ld	s0,32(sp)
    80002138:	64e2                	ld	s1,24(sp)
    8000213a:	6942                	ld	s2,16(sp)
    8000213c:	69a2                	ld	s3,8(sp)
    8000213e:	6145                	addi	sp,sp,48
    80002140:	8082                	ret
    panic("sched p->lock");
    80002142:	00005517          	auipc	a0,0x5
    80002146:	1ee50513          	addi	a0,a0,494 # 80007330 <etext+0x330>
    8000214a:	e4afe0ef          	jal	80000794 <panic>
    panic("sched locks");
    8000214e:	00005517          	auipc	a0,0x5
    80002152:	1f250513          	addi	a0,a0,498 # 80007340 <etext+0x340>
    80002156:	e3efe0ef          	jal	80000794 <panic>
    panic("sched running");
    8000215a:	00005517          	auipc	a0,0x5
    8000215e:	1f650513          	addi	a0,a0,502 # 80007350 <etext+0x350>
    80002162:	e32fe0ef          	jal	80000794 <panic>
    panic("sched interruptible");
    80002166:	00005517          	auipc	a0,0x5
    8000216a:	1fa50513          	addi	a0,a0,506 # 80007360 <etext+0x360>
    8000216e:	e26fe0ef          	jal	80000794 <panic>

0000000080002172 <yield>:
{
    80002172:	1101                	addi	sp,sp,-32
    80002174:	ec06                	sd	ra,24(sp)
    80002176:	e822                	sd	s0,16(sp)
    80002178:	e426                	sd	s1,8(sp)
    8000217a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000217c:	f86ff0ef          	jal	80001902 <myproc>
    80002180:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002182:	a73fe0ef          	jal	80000bf4 <acquire>
  p->state = RUNNABLE;
    80002186:	478d                	li	a5,3
    80002188:	cc9c                	sw	a5,24(s1)
  sched();
    8000218a:	f2fff0ef          	jal	800020b8 <sched>
  release(&p->lock);
    8000218e:	8526                	mv	a0,s1
    80002190:	afdfe0ef          	jal	80000c8c <release>
}
    80002194:	60e2                	ld	ra,24(sp)
    80002196:	6442                	ld	s0,16(sp)
    80002198:	64a2                	ld	s1,8(sp)
    8000219a:	6105                	addi	sp,sp,32
    8000219c:	8082                	ret

000000008000219e <jointhread>:
jointhread(uint join_id) {
    8000219e:	1101                	addi	sp,sp,-32
    800021a0:	ec06                	sd	ra,24(sp)
    800021a2:	e822                	sd	s0,16(sp)
    800021a4:	e426                	sd	s1,8(sp)
    800021a6:	1000                	addi	s0,sp,32
    800021a8:	84aa                	mv	s1,a0
    struct proc *p = myproc();
    800021aa:	f58ff0ef          	jal	80001902 <myproc>
    struct thread *t = p->current_thread;
    800021ae:	1e853803          	ld	a6,488(a0)
    if (!t)
    800021b2:	04080c63          	beqz	a6,8000220a <jointhread+0x6c>
    uint current_id = join_id;
    800021b6:	8626                	mv	a2,s1
    int found = 0;
    800021b8:	4301                	li	t1,0
        for (int i = 0; i < NTHREAD; i++) {
    800021ba:	4881                	li	a7,0
    800021bc:	4591                	li	a1,4
                found = 1;
    800021be:	4e05                	li	t3,1
    800021c0:	a031                	j	800021cc <jointhread+0x2e>
                current_id = p->threads[i].join;
    800021c2:	0796                	slli	a5,a5,0x5
    800021c4:	97aa                	add	a5,a5,a0
    800021c6:	17c7a603          	lw	a2,380(a5)
                found = 1;
    800021ca:	8372                	mv	t1,t3
    while (current_id != 0) {
    800021cc:	c205                	beqz	a2,800021ec <jointhread+0x4e>
        if (current_id == t->id)
    800021ce:	01082783          	lw	a5,16(a6)
    800021d2:	02c78e63          	beq	a5,a2,8000220e <jointhread+0x70>
    800021d6:	17850713          	addi	a4,a0,376
        for (int i = 0; i < NTHREAD; i++) {
    800021da:	87c6                	mv	a5,a7
            if (p->threads[i].id == target_id) {
    800021dc:	4314                	lw	a3,0(a4)
    800021de:	fec682e3          	beq	a3,a2,800021c2 <jointhread+0x24>
        for (int i = 0; i < NTHREAD; i++) {
    800021e2:	2785                	addiw	a5,a5,1
    800021e4:	02070713          	addi	a4,a4,32
    800021e8:	feb79ae3          	bne	a5,a1,800021dc <jointhread+0x3e>
    if (!found)
    800021ec:	02030363          	beqz	t1,80002212 <jointhread+0x74>
    t->join = join_id;
    800021f0:	00982a23          	sw	s1,20(a6)
    t->state = THREAD_JOINED;
    800021f4:	478d                	li	a5,3
    800021f6:	00f82023          	sw	a5,0(a6)
    yield();
    800021fa:	f79ff0ef          	jal	80002172 <yield>
    return 0;
    800021fe:	4501                	li	a0,0
}
    80002200:	60e2                	ld	ra,24(sp)
    80002202:	6442                	ld	s0,16(sp)
    80002204:	64a2                	ld	s1,8(sp)
    80002206:	6105                	addi	sp,sp,32
    80002208:	8082                	ret
        return -3;
    8000220a:	5575                	li	a0,-3
    8000220c:	bfd5                	j	80002200 <jointhread+0x62>
            return -1; // deadlock
    8000220e:	557d                	li	a0,-1
    80002210:	bfc5                	j	80002200 <jointhread+0x62>
        return -2;
    80002212:	5579                	li	a0,-2
    80002214:	b7f5                	j	80002200 <jointhread+0x62>

0000000080002216 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002216:	7179                	addi	sp,sp,-48
    80002218:	f406                	sd	ra,40(sp)
    8000221a:	f022                	sd	s0,32(sp)
    8000221c:	ec26                	sd	s1,24(sp)
    8000221e:	e84a                	sd	s2,16(sp)
    80002220:	e44e                	sd	s3,8(sp)
    80002222:	1800                	addi	s0,sp,48
    80002224:	89aa                	mv	s3,a0
    80002226:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002228:	edaff0ef          	jal	80001902 <myproc>
    8000222c:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000222e:	9c7fe0ef          	jal	80000bf4 <acquire>
  release(lk);
    80002232:	854a                	mv	a0,s2
    80002234:	a59fe0ef          	jal	80000c8c <release>

  // Go to sleep.
  p->chan = chan;
    80002238:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000223c:	4789                	li	a5,2
    8000223e:	cc9c                	sw	a5,24(s1)

  sched();
    80002240:	e79ff0ef          	jal	800020b8 <sched>

  // Tidy up.
  p->chan = 0;
    80002244:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002248:	8526                	mv	a0,s1
    8000224a:	a43fe0ef          	jal	80000c8c <release>
  acquire(lk);
    8000224e:	854a                	mv	a0,s2
    80002250:	9a5fe0ef          	jal	80000bf4 <acquire>
}
    80002254:	70a2                	ld	ra,40(sp)
    80002256:	7402                	ld	s0,32(sp)
    80002258:	64e2                	ld	s1,24(sp)
    8000225a:	6942                	ld	s2,16(sp)
    8000225c:	69a2                	ld	s3,8(sp)
    8000225e:	6145                	addi	sp,sp,48
    80002260:	8082                	ret

0000000080002262 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002262:	7139                	addi	sp,sp,-64
    80002264:	fc06                	sd	ra,56(sp)
    80002266:	f822                	sd	s0,48(sp)
    80002268:	f426                	sd	s1,40(sp)
    8000226a:	f04a                	sd	s2,32(sp)
    8000226c:	ec4e                	sd	s3,24(sp)
    8000226e:	e852                	sd	s4,16(sp)
    80002270:	e456                	sd	s5,8(sp)
    80002272:	0080                	addi	s0,sp,64
    80002274:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002276:	0000e497          	auipc	s1,0xe
    8000227a:	dba48493          	addi	s1,s1,-582 # 80010030 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    8000227e:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002280:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002282:	00016917          	auipc	s2,0x16
    80002286:	9ae90913          	addi	s2,s2,-1618 # 80017c30 <tickslock>
    8000228a:	a801                	j	8000229a <wakeup+0x38>
      }
      release(&p->lock);
    8000228c:	8526                	mv	a0,s1
    8000228e:	9fffe0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002292:	1f048493          	addi	s1,s1,496
    80002296:	03248263          	beq	s1,s2,800022ba <wakeup+0x58>
    if(p != myproc()){
    8000229a:	e68ff0ef          	jal	80001902 <myproc>
    8000229e:	fea48ae3          	beq	s1,a0,80002292 <wakeup+0x30>
      acquire(&p->lock);
    800022a2:	8526                	mv	a0,s1
    800022a4:	951fe0ef          	jal	80000bf4 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800022a8:	4c9c                	lw	a5,24(s1)
    800022aa:	ff3791e3          	bne	a5,s3,8000228c <wakeup+0x2a>
    800022ae:	709c                	ld	a5,32(s1)
    800022b0:	fd479ee3          	bne	a5,s4,8000228c <wakeup+0x2a>
        p->state = RUNNABLE;
    800022b4:	0154ac23          	sw	s5,24(s1)
    800022b8:	bfd1                	j	8000228c <wakeup+0x2a>
    }
  }
}
    800022ba:	70e2                	ld	ra,56(sp)
    800022bc:	7442                	ld	s0,48(sp)
    800022be:	74a2                	ld	s1,40(sp)
    800022c0:	7902                	ld	s2,32(sp)
    800022c2:	69e2                	ld	s3,24(sp)
    800022c4:	6a42                	ld	s4,16(sp)
    800022c6:	6aa2                	ld	s5,8(sp)
    800022c8:	6121                	addi	sp,sp,64
    800022ca:	8082                	ret

00000000800022cc <reparent>:
{
    800022cc:	7179                	addi	sp,sp,-48
    800022ce:	f406                	sd	ra,40(sp)
    800022d0:	f022                	sd	s0,32(sp)
    800022d2:	ec26                	sd	s1,24(sp)
    800022d4:	e84a                	sd	s2,16(sp)
    800022d6:	e44e                	sd	s3,8(sp)
    800022d8:	e052                	sd	s4,0(sp)
    800022da:	1800                	addi	s0,sp,48
    800022dc:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800022de:	0000e497          	auipc	s1,0xe
    800022e2:	d5248493          	addi	s1,s1,-686 # 80010030 <proc>
      pp->parent = initproc;
    800022e6:	00005a17          	auipc	s4,0x5
    800022ea:	7e2a0a13          	addi	s4,s4,2018 # 80007ac8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800022ee:	00016997          	auipc	s3,0x16
    800022f2:	94298993          	addi	s3,s3,-1726 # 80017c30 <tickslock>
    800022f6:	a029                	j	80002300 <reparent+0x34>
    800022f8:	1f048493          	addi	s1,s1,496
    800022fc:	01348b63          	beq	s1,s3,80002312 <reparent+0x46>
    if(pp->parent == p){
    80002300:	7c9c                	ld	a5,56(s1)
    80002302:	ff279be3          	bne	a5,s2,800022f8 <reparent+0x2c>
      pp->parent = initproc;
    80002306:	000a3503          	ld	a0,0(s4)
    8000230a:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000230c:	f57ff0ef          	jal	80002262 <wakeup>
    80002310:	b7e5                	j	800022f8 <reparent+0x2c>
}
    80002312:	70a2                	ld	ra,40(sp)
    80002314:	7402                	ld	s0,32(sp)
    80002316:	64e2                	ld	s1,24(sp)
    80002318:	6942                	ld	s2,16(sp)
    8000231a:	69a2                	ld	s3,8(sp)
    8000231c:	6a02                	ld	s4,0(sp)
    8000231e:	6145                	addi	sp,sp,48
    80002320:	8082                	ret

0000000080002322 <exit>:
{
    80002322:	7179                	addi	sp,sp,-48
    80002324:	f406                	sd	ra,40(sp)
    80002326:	f022                	sd	s0,32(sp)
    80002328:	ec26                	sd	s1,24(sp)
    8000232a:	e84a                	sd	s2,16(sp)
    8000232c:	e44e                	sd	s3,8(sp)
    8000232e:	e052                	sd	s4,0(sp)
    80002330:	1800                	addi	s0,sp,48
    80002332:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002334:	dceff0ef          	jal	80001902 <myproc>
    80002338:	89aa                	mv	s3,a0
  if(p == initproc)
    8000233a:	00005797          	auipc	a5,0x5
    8000233e:	78e7b783          	ld	a5,1934(a5) # 80007ac8 <initproc>
    80002342:	0d050493          	addi	s1,a0,208
    80002346:	15050913          	addi	s2,a0,336
    8000234a:	00a79f63          	bne	a5,a0,80002368 <exit+0x46>
    panic("init exiting");
    8000234e:	00005517          	auipc	a0,0x5
    80002352:	02a50513          	addi	a0,a0,42 # 80007378 <etext+0x378>
    80002356:	c3efe0ef          	jal	80000794 <panic>
      fileclose(f);
    8000235a:	06a020ef          	jal	800043c4 <fileclose>
      p->ofile[fd] = 0;
    8000235e:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002362:	04a1                	addi	s1,s1,8
    80002364:	01248563          	beq	s1,s2,8000236e <exit+0x4c>
    if(p->ofile[fd]){
    80002368:	6088                	ld	a0,0(s1)
    8000236a:	f965                	bnez	a0,8000235a <exit+0x38>
    8000236c:	bfdd                	j	80002362 <exit+0x40>
  begin_op();
    8000236e:	3e9010ef          	jal	80003f56 <begin_op>
  iput(p->cwd);
    80002372:	1509b503          	ld	a0,336(s3)
    80002376:	4cc010ef          	jal	80003842 <iput>
  end_op();
    8000237a:	447010ef          	jal	80003fc0 <end_op>
  p->cwd = 0;
    8000237e:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002382:	0000e497          	auipc	s1,0xe
    80002386:	89648493          	addi	s1,s1,-1898 # 8000fc18 <wait_lock>
    8000238a:	8526                	mv	a0,s1
    8000238c:	869fe0ef          	jal	80000bf4 <acquire>
  reparent(p);
    80002390:	854e                	mv	a0,s3
    80002392:	f3bff0ef          	jal	800022cc <reparent>
  wakeup(p->parent);
    80002396:	0389b503          	ld	a0,56(s3)
    8000239a:	ec9ff0ef          	jal	80002262 <wakeup>
  acquire(&p->lock);
    8000239e:	854e                	mv	a0,s3
    800023a0:	855fe0ef          	jal	80000bf4 <acquire>
  p->xstate = status;
    800023a4:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800023a8:	4795                	li	a5,5
    800023aa:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800023ae:	8526                	mv	a0,s1
    800023b0:	8ddfe0ef          	jal	80000c8c <release>
  sched();
    800023b4:	d05ff0ef          	jal	800020b8 <sched>
  panic("zombie exit");
    800023b8:	00005517          	auipc	a0,0x5
    800023bc:	fd050513          	addi	a0,a0,-48 # 80007388 <etext+0x388>
    800023c0:	bd4fe0ef          	jal	80000794 <panic>

00000000800023c4 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800023c4:	7179                	addi	sp,sp,-48
    800023c6:	f406                	sd	ra,40(sp)
    800023c8:	f022                	sd	s0,32(sp)
    800023ca:	ec26                	sd	s1,24(sp)
    800023cc:	e84a                	sd	s2,16(sp)
    800023ce:	e44e                	sd	s3,8(sp)
    800023d0:	1800                	addi	s0,sp,48
    800023d2:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800023d4:	0000e497          	auipc	s1,0xe
    800023d8:	c5c48493          	addi	s1,s1,-932 # 80010030 <proc>
    800023dc:	00016997          	auipc	s3,0x16
    800023e0:	85498993          	addi	s3,s3,-1964 # 80017c30 <tickslock>
    acquire(&p->lock);
    800023e4:	8526                	mv	a0,s1
    800023e6:	80ffe0ef          	jal	80000bf4 <acquire>
    if(p->pid == pid){
    800023ea:	589c                	lw	a5,48(s1)
    800023ec:	01278b63          	beq	a5,s2,80002402 <kill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800023f0:	8526                	mv	a0,s1
    800023f2:	89bfe0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800023f6:	1f048493          	addi	s1,s1,496
    800023fa:	ff3495e3          	bne	s1,s3,800023e4 <kill+0x20>
  }
  return -1;
    800023fe:	557d                	li	a0,-1
    80002400:	a819                	j	80002416 <kill+0x52>
      p->killed = 1;
    80002402:	4785                	li	a5,1
    80002404:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002406:	4c98                	lw	a4,24(s1)
    80002408:	4789                	li	a5,2
    8000240a:	00f70d63          	beq	a4,a5,80002424 <kill+0x60>
      release(&p->lock);
    8000240e:	8526                	mv	a0,s1
    80002410:	87dfe0ef          	jal	80000c8c <release>
      return 0;
    80002414:	4501                	li	a0,0
}
    80002416:	70a2                	ld	ra,40(sp)
    80002418:	7402                	ld	s0,32(sp)
    8000241a:	64e2                	ld	s1,24(sp)
    8000241c:	6942                	ld	s2,16(sp)
    8000241e:	69a2                	ld	s3,8(sp)
    80002420:	6145                	addi	sp,sp,48
    80002422:	8082                	ret
        p->state = RUNNABLE;
    80002424:	478d                	li	a5,3
    80002426:	cc9c                	sw	a5,24(s1)
    80002428:	b7dd                	j	8000240e <kill+0x4a>

000000008000242a <setkilled>:

void
setkilled(struct proc *p)
{
    8000242a:	1101                	addi	sp,sp,-32
    8000242c:	ec06                	sd	ra,24(sp)
    8000242e:	e822                	sd	s0,16(sp)
    80002430:	e426                	sd	s1,8(sp)
    80002432:	1000                	addi	s0,sp,32
    80002434:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002436:	fbefe0ef          	jal	80000bf4 <acquire>
  p->killed = 1;
    8000243a:	4785                	li	a5,1
    8000243c:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000243e:	8526                	mv	a0,s1
    80002440:	84dfe0ef          	jal	80000c8c <release>
}
    80002444:	60e2                	ld	ra,24(sp)
    80002446:	6442                	ld	s0,16(sp)
    80002448:	64a2                	ld	s1,8(sp)
    8000244a:	6105                	addi	sp,sp,32
    8000244c:	8082                	ret

000000008000244e <exitthread>:
exitthread() {
    8000244e:	1101                	addi	sp,sp,-32
    80002450:	ec06                	sd	ra,24(sp)
    80002452:	e822                	sd	s0,16(sp)
    80002454:	e426                	sd	s1,8(sp)
    80002456:	1000                	addi	s0,sp,32
    struct proc *p = myproc();
    80002458:	caaff0ef          	jal	80001902 <myproc>
    8000245c:	84aa                	mv	s1,a0
    for (struct thread *t = p->threads; t < p->threads + NTHREAD; t++) {
    8000245e:	16850793          	addi	a5,a0,360
    80002462:	1e850693          	addi	a3,a0,488
    80002466:	02d7f663          	bgeu	a5,a3,80002492 <exitthread+0x44>
    uint id = p->current_thread->id;
    8000246a:	1e853703          	ld	a4,488(a0)
    8000246e:	4b0c                	lw	a1,16(a4)
        if (t->state == THREAD_JOINED && t->join == id) {
    80002470:	460d                	li	a2,3
    80002472:	a029                	j	8000247c <exitthread+0x2e>
    for (struct thread *t = p->threads; t < p->threads + NTHREAD; t++) {
    80002474:	02078793          	addi	a5,a5,32
    80002478:	00d78d63          	beq	a5,a3,80002492 <exitthread+0x44>
        if (t->state == THREAD_JOINED && t->join == id) {
    8000247c:	4398                	lw	a4,0(a5)
    8000247e:	fec71be3          	bne	a4,a2,80002474 <exitthread+0x26>
    80002482:	4bd8                	lw	a4,20(a5)
    80002484:	feb718e3          	bne	a4,a1,80002474 <exitthread+0x26>
            t->join = 0;
    80002488:	0007aa23          	sw	zero,20(a5)
            t->state = THREAD_RUNNABLE;
    8000248c:	4705                	li	a4,1
    8000248e:	c398                	sw	a4,0(a5)
    80002490:	b7d5                	j	80002474 <exitthread+0x26>
    freethread(p->current_thread);
    80002492:	1e84b503          	ld	a0,488(s1)
    80002496:	cd6ff0ef          	jal	8000196c <freethread>
    if (!thread_schd(p))
    8000249a:	8526                	mv	a0,s1
    8000249c:	d82ff0ef          	jal	80001a1e <thread_schd>
    800024a0:	c511                	beqz	a0,800024ac <exitthread+0x5e>
}
    800024a2:	60e2                	ld	ra,24(sp)
    800024a4:	6442                	ld	s0,16(sp)
    800024a6:	64a2                	ld	s1,8(sp)
    800024a8:	6105                	addi	sp,sp,32
    800024aa:	8082                	ret
        setkilled(p);
    800024ac:	8526                	mv	a0,s1
    800024ae:	f7dff0ef          	jal	8000242a <setkilled>
}
    800024b2:	bfc5                	j	800024a2 <exitthread+0x54>

00000000800024b4 <killed>:

int
killed(struct proc *p)
{
    800024b4:	1101                	addi	sp,sp,-32
    800024b6:	ec06                	sd	ra,24(sp)
    800024b8:	e822                	sd	s0,16(sp)
    800024ba:	e426                	sd	s1,8(sp)
    800024bc:	e04a                	sd	s2,0(sp)
    800024be:	1000                	addi	s0,sp,32
    800024c0:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800024c2:	f32fe0ef          	jal	80000bf4 <acquire>
  k = p->killed;
    800024c6:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800024ca:	8526                	mv	a0,s1
    800024cc:	fc0fe0ef          	jal	80000c8c <release>
  return k;
}
    800024d0:	854a                	mv	a0,s2
    800024d2:	60e2                	ld	ra,24(sp)
    800024d4:	6442                	ld	s0,16(sp)
    800024d6:	64a2                	ld	s1,8(sp)
    800024d8:	6902                	ld	s2,0(sp)
    800024da:	6105                	addi	sp,sp,32
    800024dc:	8082                	ret

00000000800024de <wait>:
{
    800024de:	715d                	addi	sp,sp,-80
    800024e0:	e486                	sd	ra,72(sp)
    800024e2:	e0a2                	sd	s0,64(sp)
    800024e4:	fc26                	sd	s1,56(sp)
    800024e6:	f84a                	sd	s2,48(sp)
    800024e8:	f44e                	sd	s3,40(sp)
    800024ea:	f052                	sd	s4,32(sp)
    800024ec:	ec56                	sd	s5,24(sp)
    800024ee:	e85a                	sd	s6,16(sp)
    800024f0:	e45e                	sd	s7,8(sp)
    800024f2:	e062                	sd	s8,0(sp)
    800024f4:	0880                	addi	s0,sp,80
    800024f6:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800024f8:	c0aff0ef          	jal	80001902 <myproc>
    800024fc:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800024fe:	0000d517          	auipc	a0,0xd
    80002502:	71a50513          	addi	a0,a0,1818 # 8000fc18 <wait_lock>
    80002506:	eeefe0ef          	jal	80000bf4 <acquire>
    havekids = 0;
    8000250a:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    8000250c:	4a15                	li	s4,5
        havekids = 1;
    8000250e:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002510:	00015997          	auipc	s3,0x15
    80002514:	72098993          	addi	s3,s3,1824 # 80017c30 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002518:	0000dc17          	auipc	s8,0xd
    8000251c:	700c0c13          	addi	s8,s8,1792 # 8000fc18 <wait_lock>
    80002520:	a871                	j	800025bc <wait+0xde>
          pid = pp->pid;
    80002522:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002526:	000b0c63          	beqz	s6,8000253e <wait+0x60>
    8000252a:	4691                	li	a3,4
    8000252c:	02c48613          	addi	a2,s1,44
    80002530:	85da                	mv	a1,s6
    80002532:	05093503          	ld	a0,80(s2)
    80002536:	846ff0ef          	jal	8000157c <copyout>
    8000253a:	02054b63          	bltz	a0,80002570 <wait+0x92>
          freeproc(pp);
    8000253e:	8526                	mv	a0,s1
    80002540:	fd6ff0ef          	jal	80001d16 <freeproc>
          release(&pp->lock);
    80002544:	8526                	mv	a0,s1
    80002546:	f46fe0ef          	jal	80000c8c <release>
          release(&wait_lock);
    8000254a:	0000d517          	auipc	a0,0xd
    8000254e:	6ce50513          	addi	a0,a0,1742 # 8000fc18 <wait_lock>
    80002552:	f3afe0ef          	jal	80000c8c <release>
}
    80002556:	854e                	mv	a0,s3
    80002558:	60a6                	ld	ra,72(sp)
    8000255a:	6406                	ld	s0,64(sp)
    8000255c:	74e2                	ld	s1,56(sp)
    8000255e:	7942                	ld	s2,48(sp)
    80002560:	79a2                	ld	s3,40(sp)
    80002562:	7a02                	ld	s4,32(sp)
    80002564:	6ae2                	ld	s5,24(sp)
    80002566:	6b42                	ld	s6,16(sp)
    80002568:	6ba2                	ld	s7,8(sp)
    8000256a:	6c02                	ld	s8,0(sp)
    8000256c:	6161                	addi	sp,sp,80
    8000256e:	8082                	ret
            release(&pp->lock);
    80002570:	8526                	mv	a0,s1
    80002572:	f1afe0ef          	jal	80000c8c <release>
            release(&wait_lock);
    80002576:	0000d517          	auipc	a0,0xd
    8000257a:	6a250513          	addi	a0,a0,1698 # 8000fc18 <wait_lock>
    8000257e:	f0efe0ef          	jal	80000c8c <release>
            return -1;
    80002582:	59fd                	li	s3,-1
    80002584:	bfc9                	j	80002556 <wait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002586:	1f048493          	addi	s1,s1,496
    8000258a:	03348063          	beq	s1,s3,800025aa <wait+0xcc>
      if(pp->parent == p){
    8000258e:	7c9c                	ld	a5,56(s1)
    80002590:	ff279be3          	bne	a5,s2,80002586 <wait+0xa8>
        acquire(&pp->lock);
    80002594:	8526                	mv	a0,s1
    80002596:	e5efe0ef          	jal	80000bf4 <acquire>
        if(pp->state == ZOMBIE){
    8000259a:	4c9c                	lw	a5,24(s1)
    8000259c:	f94783e3          	beq	a5,s4,80002522 <wait+0x44>
        release(&pp->lock);
    800025a0:	8526                	mv	a0,s1
    800025a2:	eeafe0ef          	jal	80000c8c <release>
        havekids = 1;
    800025a6:	8756                	mv	a4,s5
    800025a8:	bff9                	j	80002586 <wait+0xa8>
    if(!havekids || killed(p)){
    800025aa:	cf19                	beqz	a4,800025c8 <wait+0xea>
    800025ac:	854a                	mv	a0,s2
    800025ae:	f07ff0ef          	jal	800024b4 <killed>
    800025b2:	e919                	bnez	a0,800025c8 <wait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800025b4:	85e2                	mv	a1,s8
    800025b6:	854a                	mv	a0,s2
    800025b8:	c5fff0ef          	jal	80002216 <sleep>
    havekids = 0;
    800025bc:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800025be:	0000e497          	auipc	s1,0xe
    800025c2:	a7248493          	addi	s1,s1,-1422 # 80010030 <proc>
    800025c6:	b7e1                	j	8000258e <wait+0xb0>
      release(&wait_lock);
    800025c8:	0000d517          	auipc	a0,0xd
    800025cc:	65050513          	addi	a0,a0,1616 # 8000fc18 <wait_lock>
    800025d0:	ebcfe0ef          	jal	80000c8c <release>
      return -1;
    800025d4:	59fd                	li	s3,-1
    800025d6:	b741                	j	80002556 <wait+0x78>

00000000800025d8 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800025d8:	7179                	addi	sp,sp,-48
    800025da:	f406                	sd	ra,40(sp)
    800025dc:	f022                	sd	s0,32(sp)
    800025de:	ec26                	sd	s1,24(sp)
    800025e0:	e84a                	sd	s2,16(sp)
    800025e2:	e44e                	sd	s3,8(sp)
    800025e4:	e052                	sd	s4,0(sp)
    800025e6:	1800                	addi	s0,sp,48
    800025e8:	84aa                	mv	s1,a0
    800025ea:	892e                	mv	s2,a1
    800025ec:	89b2                	mv	s3,a2
    800025ee:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800025f0:	b12ff0ef          	jal	80001902 <myproc>
  if(user_dst){
    800025f4:	cc99                	beqz	s1,80002612 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    800025f6:	86d2                	mv	a3,s4
    800025f8:	864e                	mv	a2,s3
    800025fa:	85ca                	mv	a1,s2
    800025fc:	6928                	ld	a0,80(a0)
    800025fe:	f7ffe0ef          	jal	8000157c <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002602:	70a2                	ld	ra,40(sp)
    80002604:	7402                	ld	s0,32(sp)
    80002606:	64e2                	ld	s1,24(sp)
    80002608:	6942                	ld	s2,16(sp)
    8000260a:	69a2                	ld	s3,8(sp)
    8000260c:	6a02                	ld	s4,0(sp)
    8000260e:	6145                	addi	sp,sp,48
    80002610:	8082                	ret
    memmove((char *)dst, src, len);
    80002612:	000a061b          	sext.w	a2,s4
    80002616:	85ce                	mv	a1,s3
    80002618:	854a                	mv	a0,s2
    8000261a:	f0afe0ef          	jal	80000d24 <memmove>
    return 0;
    8000261e:	8526                	mv	a0,s1
    80002620:	b7cd                	j	80002602 <either_copyout+0x2a>

0000000080002622 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002622:	7179                	addi	sp,sp,-48
    80002624:	f406                	sd	ra,40(sp)
    80002626:	f022                	sd	s0,32(sp)
    80002628:	ec26                	sd	s1,24(sp)
    8000262a:	e84a                	sd	s2,16(sp)
    8000262c:	e44e                	sd	s3,8(sp)
    8000262e:	e052                	sd	s4,0(sp)
    80002630:	1800                	addi	s0,sp,48
    80002632:	892a                	mv	s2,a0
    80002634:	84ae                	mv	s1,a1
    80002636:	89b2                	mv	s3,a2
    80002638:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000263a:	ac8ff0ef          	jal	80001902 <myproc>
  if(user_src){
    8000263e:	cc99                	beqz	s1,8000265c <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002640:	86d2                	mv	a3,s4
    80002642:	864e                	mv	a2,s3
    80002644:	85ca                	mv	a1,s2
    80002646:	6928                	ld	a0,80(a0)
    80002648:	80aff0ef          	jal	80001652 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000264c:	70a2                	ld	ra,40(sp)
    8000264e:	7402                	ld	s0,32(sp)
    80002650:	64e2                	ld	s1,24(sp)
    80002652:	6942                	ld	s2,16(sp)
    80002654:	69a2                	ld	s3,8(sp)
    80002656:	6a02                	ld	s4,0(sp)
    80002658:	6145                	addi	sp,sp,48
    8000265a:	8082                	ret
    memmove(dst, (char*)src, len);
    8000265c:	000a061b          	sext.w	a2,s4
    80002660:	85ce                	mv	a1,s3
    80002662:	854a                	mv	a0,s2
    80002664:	ec0fe0ef          	jal	80000d24 <memmove>
    return 0;
    80002668:	8526                	mv	a0,s1
    8000266a:	b7cd                	j	8000264c <either_copyin+0x2a>

000000008000266c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000266c:	715d                	addi	sp,sp,-80
    8000266e:	e486                	sd	ra,72(sp)
    80002670:	e0a2                	sd	s0,64(sp)
    80002672:	fc26                	sd	s1,56(sp)
    80002674:	f84a                	sd	s2,48(sp)
    80002676:	f44e                	sd	s3,40(sp)
    80002678:	f052                	sd	s4,32(sp)
    8000267a:	ec56                	sd	s5,24(sp)
    8000267c:	e85a                	sd	s6,16(sp)
    8000267e:	e45e                	sd	s7,8(sp)
    80002680:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002682:	00005517          	auipc	a0,0x5
    80002686:	9f650513          	addi	a0,a0,-1546 # 80007078 <etext+0x78>
    8000268a:	e39fd0ef          	jal	800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000268e:	0000e497          	auipc	s1,0xe
    80002692:	afa48493          	addi	s1,s1,-1286 # 80010188 <proc+0x158>
    80002696:	00015917          	auipc	s2,0x15
    8000269a:	6f290913          	addi	s2,s2,1778 # 80017d88 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000269e:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800026a0:	00005997          	auipc	s3,0x5
    800026a4:	cf898993          	addi	s3,s3,-776 # 80007398 <etext+0x398>
    printf("%d %s %s", p->pid, state, p->name);
    800026a8:	00005a97          	auipc	s5,0x5
    800026ac:	cf8a8a93          	addi	s5,s5,-776 # 800073a0 <etext+0x3a0>
    printf("\n");
    800026b0:	00005a17          	auipc	s4,0x5
    800026b4:	9c8a0a13          	addi	s4,s4,-1592 # 80007078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026b8:	00005b97          	auipc	s7,0x5
    800026bc:	280b8b93          	addi	s7,s7,640 # 80007938 <states.0>
    800026c0:	a829                	j	800026da <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    800026c2:	ed86a583          	lw	a1,-296(a3)
    800026c6:	8556                	mv	a0,s5
    800026c8:	dfbfd0ef          	jal	800004c2 <printf>
    printf("\n");
    800026cc:	8552                	mv	a0,s4
    800026ce:	df5fd0ef          	jal	800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800026d2:	1f048493          	addi	s1,s1,496
    800026d6:	03248263          	beq	s1,s2,800026fa <procdump+0x8e>
    if(p->state == UNUSED)
    800026da:	86a6                	mv	a3,s1
    800026dc:	ec04a783          	lw	a5,-320(s1)
    800026e0:	dbed                	beqz	a5,800026d2 <procdump+0x66>
      state = "???";
    800026e2:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026e4:	fcfb6fe3          	bltu	s6,a5,800026c2 <procdump+0x56>
    800026e8:	02079713          	slli	a4,a5,0x20
    800026ec:	01d75793          	srli	a5,a4,0x1d
    800026f0:	97de                	add	a5,a5,s7
    800026f2:	6390                	ld	a2,0(a5)
    800026f4:	f679                	bnez	a2,800026c2 <procdump+0x56>
      state = "???";
    800026f6:	864e                	mv	a2,s3
    800026f8:	b7e9                	j	800026c2 <procdump+0x56>
  }
}
    800026fa:	60a6                	ld	ra,72(sp)
    800026fc:	6406                	ld	s0,64(sp)
    800026fe:	74e2                	ld	s1,56(sp)
    80002700:	7942                	ld	s2,48(sp)
    80002702:	79a2                	ld	s3,40(sp)
    80002704:	7a02                	ld	s4,32(sp)
    80002706:	6ae2                	ld	s5,24(sp)
    80002708:	6b42                	ld	s6,16(sp)
    8000270a:	6ba2                	ld	s7,8(sp)
    8000270c:	6161                	addi	sp,sp,80
    8000270e:	8082                	ret

0000000080002710 <swtch>:
    80002710:	00153023          	sd	ra,0(a0)
    80002714:	00253423          	sd	sp,8(a0)
    80002718:	e900                	sd	s0,16(a0)
    8000271a:	ed04                	sd	s1,24(a0)
    8000271c:	03253023          	sd	s2,32(a0)
    80002720:	03353423          	sd	s3,40(a0)
    80002724:	03453823          	sd	s4,48(a0)
    80002728:	03553c23          	sd	s5,56(a0)
    8000272c:	05653023          	sd	s6,64(a0)
    80002730:	05753423          	sd	s7,72(a0)
    80002734:	05853823          	sd	s8,80(a0)
    80002738:	05953c23          	sd	s9,88(a0)
    8000273c:	07a53023          	sd	s10,96(a0)
    80002740:	07b53423          	sd	s11,104(a0)
    80002744:	0005b083          	ld	ra,0(a1)
    80002748:	0085b103          	ld	sp,8(a1)
    8000274c:	6980                	ld	s0,16(a1)
    8000274e:	6d84                	ld	s1,24(a1)
    80002750:	0205b903          	ld	s2,32(a1)
    80002754:	0285b983          	ld	s3,40(a1)
    80002758:	0305ba03          	ld	s4,48(a1)
    8000275c:	0385ba83          	ld	s5,56(a1)
    80002760:	0405bb03          	ld	s6,64(a1)
    80002764:	0485bb83          	ld	s7,72(a1)
    80002768:	0505bc03          	ld	s8,80(a1)
    8000276c:	0585bc83          	ld	s9,88(a1)
    80002770:	0605bd03          	ld	s10,96(a1)
    80002774:	0685bd83          	ld	s11,104(a1)
    80002778:	8082                	ret

000000008000277a <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000277a:	1141                	addi	sp,sp,-16
    8000277c:	e406                	sd	ra,8(sp)
    8000277e:	e022                	sd	s0,0(sp)
    80002780:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002782:	00005597          	auipc	a1,0x5
    80002786:	c5e58593          	addi	a1,a1,-930 # 800073e0 <etext+0x3e0>
    8000278a:	00015517          	auipc	a0,0x15
    8000278e:	4a650513          	addi	a0,a0,1190 # 80017c30 <tickslock>
    80002792:	be2fe0ef          	jal	80000b74 <initlock>
}
    80002796:	60a2                	ld	ra,8(sp)
    80002798:	6402                	ld	s0,0(sp)
    8000279a:	0141                	addi	sp,sp,16
    8000279c:	8082                	ret

000000008000279e <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000279e:	1141                	addi	sp,sp,-16
    800027a0:	e422                	sd	s0,8(sp)
    800027a2:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800027a4:	00003797          	auipc	a5,0x3
    800027a8:	f8c78793          	addi	a5,a5,-116 # 80005730 <kernelvec>
    800027ac:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800027b0:	6422                	ld	s0,8(sp)
    800027b2:	0141                	addi	sp,sp,16
    800027b4:	8082                	ret

00000000800027b6 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800027b6:	1141                	addi	sp,sp,-16
    800027b8:	e406                	sd	ra,8(sp)
    800027ba:	e022                	sd	s0,0(sp)
    800027bc:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800027be:	944ff0ef          	jal	80001902 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027c2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800027c6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800027c8:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800027cc:	00004697          	auipc	a3,0x4
    800027d0:	83468693          	addi	a3,a3,-1996 # 80006000 <_trampoline>
    800027d4:	00004717          	auipc	a4,0x4
    800027d8:	82c70713          	addi	a4,a4,-2004 # 80006000 <_trampoline>
    800027dc:	8f15                	sub	a4,a4,a3
    800027de:	040007b7          	lui	a5,0x4000
    800027e2:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    800027e4:	07b2                	slli	a5,a5,0xc
    800027e6:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800027e8:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800027ec:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800027ee:	18002673          	csrr	a2,satp
    800027f2:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800027f4:	6d30                	ld	a2,88(a0)
    800027f6:	6138                	ld	a4,64(a0)
    800027f8:	6585                	lui	a1,0x1
    800027fa:	972e                	add	a4,a4,a1
    800027fc:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800027fe:	6d38                	ld	a4,88(a0)
    80002800:	00000617          	auipc	a2,0x0
    80002804:	11060613          	addi	a2,a2,272 # 80002910 <usertrap>
    80002808:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000280a:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000280c:	8612                	mv	a2,tp
    8000280e:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002810:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002814:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002818:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000281c:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002820:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002822:	6f18                	ld	a4,24(a4)
    80002824:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002828:	6928                	ld	a0,80(a0)
    8000282a:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    8000282c:	00004717          	auipc	a4,0x4
    80002830:	87070713          	addi	a4,a4,-1936 # 8000609c <userret>
    80002834:	8f15                	sub	a4,a4,a3
    80002836:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002838:	577d                	li	a4,-1
    8000283a:	177e                	slli	a4,a4,0x3f
    8000283c:	8d59                	or	a0,a0,a4
    8000283e:	9782                	jalr	a5
}
    80002840:	60a2                	ld	ra,8(sp)
    80002842:	6402                	ld	s0,0(sp)
    80002844:	0141                	addi	sp,sp,16
    80002846:	8082                	ret

0000000080002848 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002848:	1101                	addi	sp,sp,-32
    8000284a:	ec06                	sd	ra,24(sp)
    8000284c:	e822                	sd	s0,16(sp)
    8000284e:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80002850:	886ff0ef          	jal	800018d6 <cpuid>
    80002854:	cd11                	beqz	a0,80002870 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002856:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    8000285a:	000f4737          	lui	a4,0xf4
    8000285e:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002862:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002864:	14d79073          	csrw	stimecmp,a5
}
    80002868:	60e2                	ld	ra,24(sp)
    8000286a:	6442                	ld	s0,16(sp)
    8000286c:	6105                	addi	sp,sp,32
    8000286e:	8082                	ret
    80002870:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    80002872:	00015497          	auipc	s1,0x15
    80002876:	3be48493          	addi	s1,s1,958 # 80017c30 <tickslock>
    8000287a:	8526                	mv	a0,s1
    8000287c:	b78fe0ef          	jal	80000bf4 <acquire>
    ticks++;
    80002880:	00005517          	auipc	a0,0x5
    80002884:	25050513          	addi	a0,a0,592 # 80007ad0 <ticks>
    80002888:	411c                	lw	a5,0(a0)
    8000288a:	2785                	addiw	a5,a5,1
    8000288c:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    8000288e:	9d5ff0ef          	jal	80002262 <wakeup>
    release(&tickslock);
    80002892:	8526                	mv	a0,s1
    80002894:	bf8fe0ef          	jal	80000c8c <release>
    80002898:	64a2                	ld	s1,8(sp)
    8000289a:	bf75                	j	80002856 <clockintr+0xe>

000000008000289c <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000289c:	1101                	addi	sp,sp,-32
    8000289e:	ec06                	sd	ra,24(sp)
    800028a0:	e822                	sd	s0,16(sp)
    800028a2:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028a4:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    800028a8:	57fd                	li	a5,-1
    800028aa:	17fe                	slli	a5,a5,0x3f
    800028ac:	07a5                	addi	a5,a5,9
    800028ae:	00f70c63          	beq	a4,a5,800028c6 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    800028b2:	57fd                	li	a5,-1
    800028b4:	17fe                	slli	a5,a5,0x3f
    800028b6:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    800028b8:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    800028ba:	04f70763          	beq	a4,a5,80002908 <devintr+0x6c>
  }
}
    800028be:	60e2                	ld	ra,24(sp)
    800028c0:	6442                	ld	s0,16(sp)
    800028c2:	6105                	addi	sp,sp,32
    800028c4:	8082                	ret
    800028c6:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    800028c8:	715020ef          	jal	800057dc <plic_claim>
    800028cc:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800028ce:	47a9                	li	a5,10
    800028d0:	00f50963          	beq	a0,a5,800028e2 <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    800028d4:	4785                	li	a5,1
    800028d6:	00f50963          	beq	a0,a5,800028e8 <devintr+0x4c>
    return 1;
    800028da:	4505                	li	a0,1
    } else if(irq){
    800028dc:	e889                	bnez	s1,800028ee <devintr+0x52>
    800028de:	64a2                	ld	s1,8(sp)
    800028e0:	bff9                	j	800028be <devintr+0x22>
      uartintr();
    800028e2:	924fe0ef          	jal	80000a06 <uartintr>
    if(irq)
    800028e6:	a819                	j	800028fc <devintr+0x60>
      virtio_disk_intr();
    800028e8:	3ba030ef          	jal	80005ca2 <virtio_disk_intr>
    if(irq)
    800028ec:	a801                	j	800028fc <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    800028ee:	85a6                	mv	a1,s1
    800028f0:	00005517          	auipc	a0,0x5
    800028f4:	af850513          	addi	a0,a0,-1288 # 800073e8 <etext+0x3e8>
    800028f8:	bcbfd0ef          	jal	800004c2 <printf>
      plic_complete(irq);
    800028fc:	8526                	mv	a0,s1
    800028fe:	6ff020ef          	jal	800057fc <plic_complete>
    return 1;
    80002902:	4505                	li	a0,1
    80002904:	64a2                	ld	s1,8(sp)
    80002906:	bf65                	j	800028be <devintr+0x22>
    clockintr();
    80002908:	f41ff0ef          	jal	80002848 <clockintr>
    return 2;
    8000290c:	4509                	li	a0,2
    8000290e:	bf45                	j	800028be <devintr+0x22>

0000000080002910 <usertrap>:
{
    80002910:	1101                	addi	sp,sp,-32
    80002912:	ec06                	sd	ra,24(sp)
    80002914:	e822                	sd	s0,16(sp)
    80002916:	e426                	sd	s1,8(sp)
    80002918:	e04a                	sd	s2,0(sp)
    8000291a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000291c:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002920:	1007f793          	andi	a5,a5,256
    80002924:	e3c1                	bnez	a5,800029a4 <usertrap+0x94>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002926:	00003797          	auipc	a5,0x3
    8000292a:	e0a78793          	addi	a5,a5,-502 # 80005730 <kernelvec>
    8000292e:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002932:	fd1fe0ef          	jal	80001902 <myproc>
    80002936:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002938:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000293a:	14102773          	csrr	a4,sepc
    8000293e:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002940:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002944:	47a1                	li	a5,8
    80002946:	06f70563          	beq	a4,a5,800029b0 <usertrap+0xa0>
  } else if((which_dev = devintr()) != 0){
    8000294a:	f53ff0ef          	jal	8000289c <devintr>
    8000294e:	892a                	mv	s2,a0
    80002950:	e571                	bnez	a0,80002a1c <usertrap+0x10c>
  } else if (p->current_thread && p->current_thread->id != p->pid) {
    80002952:	1e84b783          	ld	a5,488(s1)
    80002956:	cfc1                	beqz	a5,800029ee <usertrap+0xde>
    80002958:	4b94                	lw	a3,16(a5)
    8000295a:	5890                	lw	a2,48(s1)
    8000295c:	0006079b          	sext.w	a5,a2
    80002960:	08f68763          	beq	a3,a5,800029ee <usertrap+0xde>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002964:	141027f3          	csrr	a5,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002968:	14302773          	csrr	a4,stval
    if (r_sepc() != r_stval() || r_scause() != 0xc) {
    8000296c:	00f71763          	bne	a4,a5,8000297a <usertrap+0x6a>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002970:	14202773          	csrr	a4,scause
    80002974:	47b1                	li	a5,12
    80002976:	02f70463          	beq	a4,a5,8000299e <usertrap+0x8e>
    8000297a:	142025f3          	csrr	a1,scause
        printf("usertrap(): thread unexpected scause 0x%lx pid=%d tid=%d\n", r_scause(), p->pid, p->current_thread->id);
    8000297e:	00005517          	auipc	a0,0x5
    80002982:	aaa50513          	addi	a0,a0,-1366 # 80007428 <etext+0x428>
    80002986:	b3dfd0ef          	jal	800004c2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000298a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000298e:	14302673          	csrr	a2,stval
        printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002992:	00005517          	auipc	a0,0x5
    80002996:	ad650513          	addi	a0,a0,-1322 # 80007468 <etext+0x468>
    8000299a:	b29fd0ef          	jal	800004c2 <printf>
    exitthread();
    8000299e:	ab1ff0ef          	jal	8000244e <exitthread>
    800029a2:	a035                	j	800029ce <usertrap+0xbe>
    panic("usertrap: not from user mode");
    800029a4:	00005517          	auipc	a0,0x5
    800029a8:	a6450513          	addi	a0,a0,-1436 # 80007408 <etext+0x408>
    800029ac:	de9fd0ef          	jal	80000794 <panic>
    if(killed(p))
    800029b0:	b05ff0ef          	jal	800024b4 <killed>
    800029b4:	e90d                	bnez	a0,800029e6 <usertrap+0xd6>
    p->trapframe->epc += 4;
    800029b6:	6cb8                	ld	a4,88(s1)
    800029b8:	6f1c                	ld	a5,24(a4)
    800029ba:	0791                	addi	a5,a5,4
    800029bc:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029be:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800029c2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029c6:	10079073          	csrw	sstatus,a5
    syscall();
    800029ca:	252000ef          	jal	80002c1c <syscall>
  if(killed(p))
    800029ce:	8526                	mv	a0,s1
    800029d0:	ae5ff0ef          	jal	800024b4 <killed>
    800029d4:	e929                	bnez	a0,80002a26 <usertrap+0x116>
  usertrapret();
    800029d6:	de1ff0ef          	jal	800027b6 <usertrapret>
}
    800029da:	60e2                	ld	ra,24(sp)
    800029dc:	6442                	ld	s0,16(sp)
    800029de:	64a2                	ld	s1,8(sp)
    800029e0:	6902                	ld	s2,0(sp)
    800029e2:	6105                	addi	sp,sp,32
    800029e4:	8082                	ret
      exit(-1);
    800029e6:	557d                	li	a0,-1
    800029e8:	93bff0ef          	jal	80002322 <exit>
    800029ec:	b7e9                	j	800029b6 <usertrap+0xa6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029ee:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    800029f2:	5890                	lw	a2,48(s1)
    800029f4:	00005517          	auipc	a0,0x5
    800029f8:	a9c50513          	addi	a0,a0,-1380 # 80007490 <etext+0x490>
    800029fc:	ac7fd0ef          	jal	800004c2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a00:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002a04:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002a08:	00005517          	auipc	a0,0x5
    80002a0c:	a6050513          	addi	a0,a0,-1440 # 80007468 <etext+0x468>
    80002a10:	ab3fd0ef          	jal	800004c2 <printf>
    setkilled(p);
    80002a14:	8526                	mv	a0,s1
    80002a16:	a15ff0ef          	jal	8000242a <setkilled>
    80002a1a:	bf55                	j	800029ce <usertrap+0xbe>
  if(killed(p))
    80002a1c:	8526                	mv	a0,s1
    80002a1e:	a97ff0ef          	jal	800024b4 <killed>
    80002a22:	c511                	beqz	a0,80002a2e <usertrap+0x11e>
    80002a24:	a011                	j	80002a28 <usertrap+0x118>
    80002a26:	4901                	li	s2,0
    exit(-1);
    80002a28:	557d                	li	a0,-1
    80002a2a:	8f9ff0ef          	jal	80002322 <exit>
  if(which_dev == 2)
    80002a2e:	4789                	li	a5,2
    80002a30:	faf913e3          	bne	s2,a5,800029d6 <usertrap+0xc6>
    yield();
    80002a34:	f3eff0ef          	jal	80002172 <yield>
    80002a38:	bf79                	j	800029d6 <usertrap+0xc6>

0000000080002a3a <kerneltrap>:
{
    80002a3a:	7179                	addi	sp,sp,-48
    80002a3c:	f406                	sd	ra,40(sp)
    80002a3e:	f022                	sd	s0,32(sp)
    80002a40:	ec26                	sd	s1,24(sp)
    80002a42:	e84a                	sd	s2,16(sp)
    80002a44:	e44e                	sd	s3,8(sp)
    80002a46:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a48:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a4c:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a50:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002a54:	1004f793          	andi	a5,s1,256
    80002a58:	c795                	beqz	a5,80002a84 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a5a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002a5e:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002a60:	eb85                	bnez	a5,80002a90 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80002a62:	e3bff0ef          	jal	8000289c <devintr>
    80002a66:	c91d                	beqz	a0,80002a9c <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80002a68:	4789                	li	a5,2
    80002a6a:	04f50a63          	beq	a0,a5,80002abe <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a6e:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a72:	10049073          	csrw	sstatus,s1
}
    80002a76:	70a2                	ld	ra,40(sp)
    80002a78:	7402                	ld	s0,32(sp)
    80002a7a:	64e2                	ld	s1,24(sp)
    80002a7c:	6942                	ld	s2,16(sp)
    80002a7e:	69a2                	ld	s3,8(sp)
    80002a80:	6145                	addi	sp,sp,48
    80002a82:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002a84:	00005517          	auipc	a0,0x5
    80002a88:	a3c50513          	addi	a0,a0,-1476 # 800074c0 <etext+0x4c0>
    80002a8c:	d09fd0ef          	jal	80000794 <panic>
    panic("kerneltrap: interrupts enabled");
    80002a90:	00005517          	auipc	a0,0x5
    80002a94:	a5850513          	addi	a0,a0,-1448 # 800074e8 <etext+0x4e8>
    80002a98:	cfdfd0ef          	jal	80000794 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a9c:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002aa0:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002aa4:	85ce                	mv	a1,s3
    80002aa6:	00005517          	auipc	a0,0x5
    80002aaa:	a6250513          	addi	a0,a0,-1438 # 80007508 <etext+0x508>
    80002aae:	a15fd0ef          	jal	800004c2 <printf>
    panic("kerneltrap");
    80002ab2:	00005517          	auipc	a0,0x5
    80002ab6:	a7e50513          	addi	a0,a0,-1410 # 80007530 <etext+0x530>
    80002aba:	cdbfd0ef          	jal	80000794 <panic>
  if(which_dev == 2 && myproc() != 0)
    80002abe:	e45fe0ef          	jal	80001902 <myproc>
    80002ac2:	d555                	beqz	a0,80002a6e <kerneltrap+0x34>
    yield();
    80002ac4:	eaeff0ef          	jal	80002172 <yield>
    80002ac8:	b75d                	j	80002a6e <kerneltrap+0x34>

0000000080002aca <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002aca:	1101                	addi	sp,sp,-32
    80002acc:	ec06                	sd	ra,24(sp)
    80002ace:	e822                	sd	s0,16(sp)
    80002ad0:	e426                	sd	s1,8(sp)
    80002ad2:	1000                	addi	s0,sp,32
    80002ad4:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002ad6:	e2dfe0ef          	jal	80001902 <myproc>
  switch (n) {
    80002ada:	4795                	li	a5,5
    80002adc:	0497e163          	bltu	a5,s1,80002b1e <argraw+0x54>
    80002ae0:	048a                	slli	s1,s1,0x2
    80002ae2:	00005717          	auipc	a4,0x5
    80002ae6:	e8670713          	addi	a4,a4,-378 # 80007968 <states.0+0x30>
    80002aea:	94ba                	add	s1,s1,a4
    80002aec:	409c                	lw	a5,0(s1)
    80002aee:	97ba                	add	a5,a5,a4
    80002af0:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002af2:	6d3c                	ld	a5,88(a0)
    80002af4:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002af6:	60e2                	ld	ra,24(sp)
    80002af8:	6442                	ld	s0,16(sp)
    80002afa:	64a2                	ld	s1,8(sp)
    80002afc:	6105                	addi	sp,sp,32
    80002afe:	8082                	ret
    return p->trapframe->a1;
    80002b00:	6d3c                	ld	a5,88(a0)
    80002b02:	7fa8                	ld	a0,120(a5)
    80002b04:	bfcd                	j	80002af6 <argraw+0x2c>
    return p->trapframe->a2;
    80002b06:	6d3c                	ld	a5,88(a0)
    80002b08:	63c8                	ld	a0,128(a5)
    80002b0a:	b7f5                	j	80002af6 <argraw+0x2c>
    return p->trapframe->a3;
    80002b0c:	6d3c                	ld	a5,88(a0)
    80002b0e:	67c8                	ld	a0,136(a5)
    80002b10:	b7dd                	j	80002af6 <argraw+0x2c>
    return p->trapframe->a4;
    80002b12:	6d3c                	ld	a5,88(a0)
    80002b14:	6bc8                	ld	a0,144(a5)
    80002b16:	b7c5                	j	80002af6 <argraw+0x2c>
    return p->trapframe->a5;
    80002b18:	6d3c                	ld	a5,88(a0)
    80002b1a:	6fc8                	ld	a0,152(a5)
    80002b1c:	bfe9                	j	80002af6 <argraw+0x2c>
  panic("argraw");
    80002b1e:	00005517          	auipc	a0,0x5
    80002b22:	a2250513          	addi	a0,a0,-1502 # 80007540 <etext+0x540>
    80002b26:	c6ffd0ef          	jal	80000794 <panic>

0000000080002b2a <fetchaddr>:
{
    80002b2a:	1101                	addi	sp,sp,-32
    80002b2c:	ec06                	sd	ra,24(sp)
    80002b2e:	e822                	sd	s0,16(sp)
    80002b30:	e426                	sd	s1,8(sp)
    80002b32:	e04a                	sd	s2,0(sp)
    80002b34:	1000                	addi	s0,sp,32
    80002b36:	84aa                	mv	s1,a0
    80002b38:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002b3a:	dc9fe0ef          	jal	80001902 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002b3e:	653c                	ld	a5,72(a0)
    80002b40:	02f4f663          	bgeu	s1,a5,80002b6c <fetchaddr+0x42>
    80002b44:	00848713          	addi	a4,s1,8
    80002b48:	02e7e463          	bltu	a5,a4,80002b70 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002b4c:	46a1                	li	a3,8
    80002b4e:	8626                	mv	a2,s1
    80002b50:	85ca                	mv	a1,s2
    80002b52:	6928                	ld	a0,80(a0)
    80002b54:	afffe0ef          	jal	80001652 <copyin>
    80002b58:	00a03533          	snez	a0,a0
    80002b5c:	40a00533          	neg	a0,a0
}
    80002b60:	60e2                	ld	ra,24(sp)
    80002b62:	6442                	ld	s0,16(sp)
    80002b64:	64a2                	ld	s1,8(sp)
    80002b66:	6902                	ld	s2,0(sp)
    80002b68:	6105                	addi	sp,sp,32
    80002b6a:	8082                	ret
    return -1;
    80002b6c:	557d                	li	a0,-1
    80002b6e:	bfcd                	j	80002b60 <fetchaddr+0x36>
    80002b70:	557d                	li	a0,-1
    80002b72:	b7fd                	j	80002b60 <fetchaddr+0x36>

0000000080002b74 <fetchstr>:
{
    80002b74:	7179                	addi	sp,sp,-48
    80002b76:	f406                	sd	ra,40(sp)
    80002b78:	f022                	sd	s0,32(sp)
    80002b7a:	ec26                	sd	s1,24(sp)
    80002b7c:	e84a                	sd	s2,16(sp)
    80002b7e:	e44e                	sd	s3,8(sp)
    80002b80:	1800                	addi	s0,sp,48
    80002b82:	892a                	mv	s2,a0
    80002b84:	84ae                	mv	s1,a1
    80002b86:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002b88:	d7bfe0ef          	jal	80001902 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002b8c:	86ce                	mv	a3,s3
    80002b8e:	864a                	mv	a2,s2
    80002b90:	85a6                	mv	a1,s1
    80002b92:	6928                	ld	a0,80(a0)
    80002b94:	b45fe0ef          	jal	800016d8 <copyinstr>
    80002b98:	00054c63          	bltz	a0,80002bb0 <fetchstr+0x3c>
  return strlen(buf);
    80002b9c:	8526                	mv	a0,s1
    80002b9e:	a9afe0ef          	jal	80000e38 <strlen>
}
    80002ba2:	70a2                	ld	ra,40(sp)
    80002ba4:	7402                	ld	s0,32(sp)
    80002ba6:	64e2                	ld	s1,24(sp)
    80002ba8:	6942                	ld	s2,16(sp)
    80002baa:	69a2                	ld	s3,8(sp)
    80002bac:	6145                	addi	sp,sp,48
    80002bae:	8082                	ret
    return -1;
    80002bb0:	557d                	li	a0,-1
    80002bb2:	bfc5                	j	80002ba2 <fetchstr+0x2e>

0000000080002bb4 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002bb4:	1101                	addi	sp,sp,-32
    80002bb6:	ec06                	sd	ra,24(sp)
    80002bb8:	e822                	sd	s0,16(sp)
    80002bba:	e426                	sd	s1,8(sp)
    80002bbc:	1000                	addi	s0,sp,32
    80002bbe:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002bc0:	f0bff0ef          	jal	80002aca <argraw>
    80002bc4:	c088                	sw	a0,0(s1)
}
    80002bc6:	60e2                	ld	ra,24(sp)
    80002bc8:	6442                	ld	s0,16(sp)
    80002bca:	64a2                	ld	s1,8(sp)
    80002bcc:	6105                	addi	sp,sp,32
    80002bce:	8082                	ret

0000000080002bd0 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002bd0:	1101                	addi	sp,sp,-32
    80002bd2:	ec06                	sd	ra,24(sp)
    80002bd4:	e822                	sd	s0,16(sp)
    80002bd6:	e426                	sd	s1,8(sp)
    80002bd8:	1000                	addi	s0,sp,32
    80002bda:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002bdc:	eefff0ef          	jal	80002aca <argraw>
    80002be0:	e088                	sd	a0,0(s1)
}
    80002be2:	60e2                	ld	ra,24(sp)
    80002be4:	6442                	ld	s0,16(sp)
    80002be6:	64a2                	ld	s1,8(sp)
    80002be8:	6105                	addi	sp,sp,32
    80002bea:	8082                	ret

0000000080002bec <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002bec:	7179                	addi	sp,sp,-48
    80002bee:	f406                	sd	ra,40(sp)
    80002bf0:	f022                	sd	s0,32(sp)
    80002bf2:	ec26                	sd	s1,24(sp)
    80002bf4:	e84a                	sd	s2,16(sp)
    80002bf6:	1800                	addi	s0,sp,48
    80002bf8:	84ae                	mv	s1,a1
    80002bfa:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002bfc:	fd840593          	addi	a1,s0,-40
    80002c00:	fd1ff0ef          	jal	80002bd0 <argaddr>
  return fetchstr(addr, buf, max);
    80002c04:	864a                	mv	a2,s2
    80002c06:	85a6                	mv	a1,s1
    80002c08:	fd843503          	ld	a0,-40(s0)
    80002c0c:	f69ff0ef          	jal	80002b74 <fetchstr>
}
    80002c10:	70a2                	ld	ra,40(sp)
    80002c12:	7402                	ld	s0,32(sp)
    80002c14:	64e2                	ld	s1,24(sp)
    80002c16:	6942                	ld	s2,16(sp)
    80002c18:	6145                	addi	sp,sp,48
    80002c1a:	8082                	ret

0000000080002c1c <syscall>:
[SYS_thread]      sys_thread,
[SYS_jointhread]  sys_jointhread,
};

void
syscall(void) {
    80002c1c:	1101                	addi	sp,sp,-32
    80002c1e:	ec06                	sd	ra,24(sp)
    80002c20:	e822                	sd	s0,16(sp)
    80002c22:	e426                	sd	s1,8(sp)
    80002c24:	e04a                	sd	s2,0(sp)
    80002c26:	1000                	addi	s0,sp,32
    int num;
    struct proc *p = myproc();
    80002c28:	cdbfe0ef          	jal	80001902 <myproc>
    80002c2c:	84aa                	mv	s1,a0
    struct thread *oldt = p->current_thread;
    80002c2e:	1e853903          	ld	s2,488(a0)
    uint64 ret;

    num = p->trapframe->a7;
    80002c32:	6d3c                	ld	a5,88(a0)
    80002c34:	77dc                	ld	a5,168(a5)
    80002c36:	0007869b          	sext.w	a3,a5
    if (num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002c3a:	37fd                	addiw	a5,a5,-1
    80002c3c:	475d                	li	a4,23
    80002c3e:	00f76d63          	bltu	a4,a5,80002c58 <syscall+0x3c>
    80002c42:	00369713          	slli	a4,a3,0x3
    80002c46:	00005797          	auipc	a5,0x5
    80002c4a:	d3a78793          	addi	a5,a5,-710 # 80007980 <syscalls>
    80002c4e:	97ba                	add	a5,a5,a4
    80002c50:	639c                	ld	a5,0(a5)
    80002c52:	c399                	beqz	a5,80002c58 <syscall+0x3c>
        // Use num to lookup the system call function for num, call it,
        // and store its return value in p->trapframe->a0
        ret = syscalls[num]();
    80002c54:	9782                	jalr	a5
    80002c56:	a819                	j	80002c6c <syscall+0x50>
    } else {
        printf("%d %s: unknown sys call %d\n",
    80002c58:	15848613          	addi	a2,s1,344
    80002c5c:	588c                	lw	a1,48(s1)
    80002c5e:	00005517          	auipc	a0,0x5
    80002c62:	8ea50513          	addi	a0,a0,-1814 # 80007548 <etext+0x548>
    80002c66:	85dfd0ef          	jal	800004c2 <printf>
               p->pid, p->name, num);
        ret = -1;
    80002c6a:	557d                	li	a0,-1
    }

    struct thread *newt = p->current_thread;
    80002c6c:	1e84b783          	ld	a5,488(s1)
    if (oldt != newt) {
    80002c70:	00f90b63          	beq	s2,a5,80002c86 <syscall+0x6a>
        if (!oldt)
    80002c74:	02090163          	beqz	s2,80002c96 <syscall+0x7a>
            oldt = &p->threads[0];
        oldt->trapframe->a0 = ret;
    80002c78:	00893783          	ld	a5,8(s2)
    80002c7c:	fba8                	sd	a0,112(a5)
    }
    if (oldt == newt || p->current_thread == oldt) {
    80002c7e:	1e84b783          	ld	a5,488(s1)
    80002c82:	01279463          	bne	a5,s2,80002c8a <syscall+0x6e>
        p->trapframe->a0 = ret;
    80002c86:	6cbc                	ld	a5,88(s1)
    80002c88:	fba8                	sd	a0,112(a5)
    }
}
    80002c8a:	60e2                	ld	ra,24(sp)
    80002c8c:	6442                	ld	s0,16(sp)
    80002c8e:	64a2                	ld	s1,8(sp)
    80002c90:	6902                	ld	s2,0(sp)
    80002c92:	6105                	addi	sp,sp,32
    80002c94:	8082                	ret
            oldt = &p->threads[0];
    80002c96:	16848913          	addi	s2,s1,360
        oldt->trapframe->a0 = ret;
    80002c9a:	1704b703          	ld	a4,368(s1)
    80002c9e:	fb28                	sd	a0,112(a4)
    if (oldt == newt || p->current_thread == oldt) {
    80002ca0:	fd279fe3          	bne	a5,s2,80002c7e <syscall+0x62>
    80002ca4:	b7cd                	j	80002c86 <syscall+0x6a>

0000000080002ca6 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002ca6:	1101                	addi	sp,sp,-32
    80002ca8:	ec06                	sd	ra,24(sp)
    80002caa:	e822                	sd	s0,16(sp)
    80002cac:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002cae:	fec40593          	addi	a1,s0,-20
    80002cb2:	4501                	li	a0,0
    80002cb4:	f01ff0ef          	jal	80002bb4 <argint>
  exit(n);
    80002cb8:	fec42503          	lw	a0,-20(s0)
    80002cbc:	e66ff0ef          	jal	80002322 <exit>
  return 0;  // not reached
}
    80002cc0:	4501                	li	a0,0
    80002cc2:	60e2                	ld	ra,24(sp)
    80002cc4:	6442                	ld	s0,16(sp)
    80002cc6:	6105                	addi	sp,sp,32
    80002cc8:	8082                	ret

0000000080002cca <sys_getpid>:

uint64
sys_getpid(void)
{
    80002cca:	1141                	addi	sp,sp,-16
    80002ccc:	e406                	sd	ra,8(sp)
    80002cce:	e022                	sd	s0,0(sp)
    80002cd0:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002cd2:	c31fe0ef          	jal	80001902 <myproc>
}
    80002cd6:	5908                	lw	a0,48(a0)
    80002cd8:	60a2                	ld	ra,8(sp)
    80002cda:	6402                	ld	s0,0(sp)
    80002cdc:	0141                	addi	sp,sp,16
    80002cde:	8082                	ret

0000000080002ce0 <sys_fork>:

uint64
sys_fork(void)
{
    80002ce0:	1141                	addi	sp,sp,-16
    80002ce2:	e406                	sd	ra,8(sp)
    80002ce4:	e022                	sd	s0,0(sp)
    80002ce6:	0800                	addi	s0,sp,16
  return fork();
    80002ce8:	a06ff0ef          	jal	80001eee <fork>
}
    80002cec:	60a2                	ld	ra,8(sp)
    80002cee:	6402                	ld	s0,0(sp)
    80002cf0:	0141                	addi	sp,sp,16
    80002cf2:	8082                	ret

0000000080002cf4 <sys_trigger>:

uint64
sys_trigger(void)
{
    80002cf4:	1141                	addi	sp,sp,-16
    80002cf6:	e406                	sd	ra,8(sp)
    80002cf8:	e022                	sd	s0,0(sp)
    80002cfa:	0800                	addi	s0,sp,16
    printf("INFO − This is a log to test a new xv6 system call\n");
    80002cfc:	00005517          	auipc	a0,0x5
    80002d00:	86c50513          	addi	a0,a0,-1940 # 80007568 <etext+0x568>
    80002d04:	fbefd0ef          	jal	800004c2 <printf>
    return 0;
}
    80002d08:	4501                	li	a0,0
    80002d0a:	60a2                	ld	ra,8(sp)
    80002d0c:	6402                	ld	s0,0(sp)
    80002d0e:	0141                	addi	sp,sp,16
    80002d10:	8082                	ret

0000000080002d12 <sys_thread>:
uint64
sys_thread(void) {
    80002d12:	7179                	addi	sp,sp,-48
    80002d14:	f406                	sd	ra,40(sp)
    80002d16:	f022                	sd	s0,32(sp)
    80002d18:	1800                	addi	s0,sp,48
    uint64 start_thread, stack_address, arg;
    argaddr(0, &start_thread);
    80002d1a:	fe840593          	addi	a1,s0,-24
    80002d1e:	4501                	li	a0,0
    80002d20:	eb1ff0ef          	jal	80002bd0 <argaddr>
    argaddr(1, &stack_address);
    80002d24:	fe040593          	addi	a1,s0,-32
    80002d28:	4505                	li	a0,1
    80002d2a:	ea7ff0ef          	jal	80002bd0 <argaddr>
    argaddr(2, &arg);
    80002d2e:	fd840593          	addi	a1,s0,-40
    80002d32:	4509                	li	a0,2
    80002d34:	e9dff0ef          	jal	80002bd0 <argaddr>
    struct thread *t = allocthread(start_thread, stack_address, arg);
    80002d38:	fd843603          	ld	a2,-40(s0)
    80002d3c:	fe043583          	ld	a1,-32(s0)
    80002d40:	fe843503          	ld	a0,-24(s0)
    80002d44:	e4dfe0ef          	jal	80001b90 <allocthread>
    80002d48:	87aa                	mv	a5,a0
    return t ? t->id : 0;
    80002d4a:	4501                	li	a0,0
    80002d4c:	c399                	beqz	a5,80002d52 <sys_thread+0x40>
    80002d4e:	0107e503          	lwu	a0,16(a5)
}
    80002d52:	70a2                	ld	ra,40(sp)
    80002d54:	7402                	ld	s0,32(sp)
    80002d56:	6145                	addi	sp,sp,48
    80002d58:	8082                	ret

0000000080002d5a <sys_jointhread>:

uint64
sys_jointhread(void) {
    80002d5a:	1101                	addi	sp,sp,-32
    80002d5c:	ec06                	sd	ra,24(sp)
    80002d5e:	e822                	sd	s0,16(sp)
    80002d60:	1000                	addi	s0,sp,32
    int id;
    argint(0, &id);
    80002d62:	fec40593          	addi	a1,s0,-20
    80002d66:	4501                	li	a0,0
    80002d68:	e4dff0ef          	jal	80002bb4 <argint>
    return jointhread(id);
    80002d6c:	fec42503          	lw	a0,-20(s0)
    80002d70:	c2eff0ef          	jal	8000219e <jointhread>
}
    80002d74:	60e2                	ld	ra,24(sp)
    80002d76:	6442                	ld	s0,16(sp)
    80002d78:	6105                	addi	sp,sp,32
    80002d7a:	8082                	ret

0000000080002d7c <sys_wait>:


uint64
sys_wait(void)
{
    80002d7c:	1101                	addi	sp,sp,-32
    80002d7e:	ec06                	sd	ra,24(sp)
    80002d80:	e822                	sd	s0,16(sp)
    80002d82:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002d84:	fe840593          	addi	a1,s0,-24
    80002d88:	4501                	li	a0,0
    80002d8a:	e47ff0ef          	jal	80002bd0 <argaddr>
  return wait(p);
    80002d8e:	fe843503          	ld	a0,-24(s0)
    80002d92:	f4cff0ef          	jal	800024de <wait>
}
    80002d96:	60e2                	ld	ra,24(sp)
    80002d98:	6442                	ld	s0,16(sp)
    80002d9a:	6105                	addi	sp,sp,32
    80002d9c:	8082                	ret

0000000080002d9e <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002d9e:	7179                	addi	sp,sp,-48
    80002da0:	f406                	sd	ra,40(sp)
    80002da2:	f022                	sd	s0,32(sp)
    80002da4:	ec26                	sd	s1,24(sp)
    80002da6:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002da8:	fdc40593          	addi	a1,s0,-36
    80002dac:	4501                	li	a0,0
    80002dae:	e07ff0ef          	jal	80002bb4 <argint>
  addr = myproc()->sz;
    80002db2:	b51fe0ef          	jal	80001902 <myproc>
    80002db6:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002db8:	fdc42503          	lw	a0,-36(s0)
    80002dbc:	8e2ff0ef          	jal	80001e9e <growproc>
    80002dc0:	00054863          	bltz	a0,80002dd0 <sys_sbrk+0x32>
    return -1;
  return addr;
}
    80002dc4:	8526                	mv	a0,s1
    80002dc6:	70a2                	ld	ra,40(sp)
    80002dc8:	7402                	ld	s0,32(sp)
    80002dca:	64e2                	ld	s1,24(sp)
    80002dcc:	6145                	addi	sp,sp,48
    80002dce:	8082                	ret
    return -1;
    80002dd0:	54fd                	li	s1,-1
    80002dd2:	bfcd                	j	80002dc4 <sys_sbrk+0x26>

0000000080002dd4 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002dd4:	7139                	addi	sp,sp,-64
    80002dd6:	fc06                	sd	ra,56(sp)
    80002dd8:	f822                	sd	s0,48(sp)
    80002dda:	f04a                	sd	s2,32(sp)
    80002ddc:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002dde:	fcc40593          	addi	a1,s0,-52
    80002de2:	4501                	li	a0,0
    80002de4:	dd1ff0ef          	jal	80002bb4 <argint>
  if(n < 0)
    80002de8:	fcc42783          	lw	a5,-52(s0)
    80002dec:	0607cf63          	bltz	a5,80002e6a <sys_sleep+0x96>
    n = 0;
  acquire(&tickslock);
    80002df0:	00015517          	auipc	a0,0x15
    80002df4:	e4050513          	addi	a0,a0,-448 # 80017c30 <tickslock>
    80002df8:	dfdfd0ef          	jal	80000bf4 <acquire>
  ticks0 = ticks;
    80002dfc:	00005917          	auipc	s2,0x5
    80002e00:	cd492903          	lw	s2,-812(s2) # 80007ad0 <ticks>
  if (myproc()->current_thread) {
    80002e04:	afffe0ef          	jal	80001902 <myproc>
    80002e08:	1e853783          	ld	a5,488(a0)
    80002e0c:	e3b5                	bnez	a5,80002e70 <sys_sleep+0x9c>
    80002e0e:	f426                	sd	s1,40(sp)
    80002e10:	ec4e                	sd	s3,24(sp)
      release(&tickslock);
      sleepthread(n, ticks0);
      return 0;
  }

  while(ticks - ticks0 < n){
    80002e12:	00005797          	auipc	a5,0x5
    80002e16:	cbe7a783          	lw	a5,-834(a5) # 80007ad0 <ticks>
    80002e1a:	412787bb          	subw	a5,a5,s2
    80002e1e:	fcc42703          	lw	a4,-52(s0)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002e22:	00015997          	auipc	s3,0x15
    80002e26:	e0e98993          	addi	s3,s3,-498 # 80017c30 <tickslock>
    80002e2a:	00005497          	auipc	s1,0x5
    80002e2e:	ca648493          	addi	s1,s1,-858 # 80007ad0 <ticks>
  while(ticks - ticks0 < n){
    80002e32:	02e7f263          	bgeu	a5,a4,80002e56 <sys_sleep+0x82>
    if(killed(myproc())){
    80002e36:	acdfe0ef          	jal	80001902 <myproc>
    80002e3a:	e7aff0ef          	jal	800024b4 <killed>
    80002e3e:	e931                	bnez	a0,80002e92 <sys_sleep+0xbe>
    sleep(&ticks, &tickslock);
    80002e40:	85ce                	mv	a1,s3
    80002e42:	8526                	mv	a0,s1
    80002e44:	bd2ff0ef          	jal	80002216 <sleep>
  while(ticks - ticks0 < n){
    80002e48:	409c                	lw	a5,0(s1)
    80002e4a:	412787bb          	subw	a5,a5,s2
    80002e4e:	fcc42703          	lw	a4,-52(s0)
    80002e52:	fee7e2e3          	bltu	a5,a4,80002e36 <sys_sleep+0x62>
  }
  release(&tickslock);
    80002e56:	00015517          	auipc	a0,0x15
    80002e5a:	dda50513          	addi	a0,a0,-550 # 80017c30 <tickslock>
    80002e5e:	e2ffd0ef          	jal	80000c8c <release>
  return 0;
    80002e62:	4501                	li	a0,0
    80002e64:	74a2                	ld	s1,40(sp)
    80002e66:	69e2                	ld	s3,24(sp)
    80002e68:	a005                	j	80002e88 <sys_sleep+0xb4>
    n = 0;
    80002e6a:	fc042623          	sw	zero,-52(s0)
    80002e6e:	b749                	j	80002df0 <sys_sleep+0x1c>
      release(&tickslock);
    80002e70:	00015517          	auipc	a0,0x15
    80002e74:	dc050513          	addi	a0,a0,-576 # 80017c30 <tickslock>
    80002e78:	e15fd0ef          	jal	80000c8c <release>
      sleepthread(n, ticks0);
    80002e7c:	85ca                	mv	a1,s2
    80002e7e:	fcc42503          	lw	a0,-52(s0)
    80002e82:	c9bfe0ef          	jal	80001b1c <sleepthread>
      return 0;
    80002e86:	4501                	li	a0,0
}
    80002e88:	70e2                	ld	ra,56(sp)
    80002e8a:	7442                	ld	s0,48(sp)
    80002e8c:	7902                	ld	s2,32(sp)
    80002e8e:	6121                	addi	sp,sp,64
    80002e90:	8082                	ret
      release(&tickslock);
    80002e92:	00015517          	auipc	a0,0x15
    80002e96:	d9e50513          	addi	a0,a0,-610 # 80017c30 <tickslock>
    80002e9a:	df3fd0ef          	jal	80000c8c <release>
      return -1;
    80002e9e:	557d                	li	a0,-1
    80002ea0:	74a2                	ld	s1,40(sp)
    80002ea2:	69e2                	ld	s3,24(sp)
    80002ea4:	b7d5                	j	80002e88 <sys_sleep+0xb4>

0000000080002ea6 <sys_kill>:


uint64
sys_kill(void)
{
    80002ea6:	1101                	addi	sp,sp,-32
    80002ea8:	ec06                	sd	ra,24(sp)
    80002eaa:	e822                	sd	s0,16(sp)
    80002eac:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002eae:	fec40593          	addi	a1,s0,-20
    80002eb2:	4501                	li	a0,0
    80002eb4:	d01ff0ef          	jal	80002bb4 <argint>
  return kill(pid);
    80002eb8:	fec42503          	lw	a0,-20(s0)
    80002ebc:	d08ff0ef          	jal	800023c4 <kill>
}
    80002ec0:	60e2                	ld	ra,24(sp)
    80002ec2:	6442                	ld	s0,16(sp)
    80002ec4:	6105                	addi	sp,sp,32
    80002ec6:	8082                	ret

0000000080002ec8 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002ec8:	1101                	addi	sp,sp,-32
    80002eca:	ec06                	sd	ra,24(sp)
    80002ecc:	e822                	sd	s0,16(sp)
    80002ece:	e426                	sd	s1,8(sp)
    80002ed0:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002ed2:	00015517          	auipc	a0,0x15
    80002ed6:	d5e50513          	addi	a0,a0,-674 # 80017c30 <tickslock>
    80002eda:	d1bfd0ef          	jal	80000bf4 <acquire>
  xticks = ticks;
    80002ede:	00005497          	auipc	s1,0x5
    80002ee2:	bf24a483          	lw	s1,-1038(s1) # 80007ad0 <ticks>
  release(&tickslock);
    80002ee6:	00015517          	auipc	a0,0x15
    80002eea:	d4a50513          	addi	a0,a0,-694 # 80017c30 <tickslock>
    80002eee:	d9ffd0ef          	jal	80000c8c <release>
  return xticks;
}
    80002ef2:	02049513          	slli	a0,s1,0x20
    80002ef6:	9101                	srli	a0,a0,0x20
    80002ef8:	60e2                	ld	ra,24(sp)
    80002efa:	6442                	ld	s0,16(sp)
    80002efc:	64a2                	ld	s1,8(sp)
    80002efe:	6105                	addi	sp,sp,32
    80002f00:	8082                	ret

0000000080002f02 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002f02:	7179                	addi	sp,sp,-48
    80002f04:	f406                	sd	ra,40(sp)
    80002f06:	f022                	sd	s0,32(sp)
    80002f08:	ec26                	sd	s1,24(sp)
    80002f0a:	e84a                	sd	s2,16(sp)
    80002f0c:	e44e                	sd	s3,8(sp)
    80002f0e:	e052                	sd	s4,0(sp)
    80002f10:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002f12:	00004597          	auipc	a1,0x4
    80002f16:	68e58593          	addi	a1,a1,1678 # 800075a0 <etext+0x5a0>
    80002f1a:	00015517          	auipc	a0,0x15
    80002f1e:	d2e50513          	addi	a0,a0,-722 # 80017c48 <bcache>
    80002f22:	c53fd0ef          	jal	80000b74 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002f26:	0001d797          	auipc	a5,0x1d
    80002f2a:	d2278793          	addi	a5,a5,-734 # 8001fc48 <bcache+0x8000>
    80002f2e:	0001d717          	auipc	a4,0x1d
    80002f32:	f8270713          	addi	a4,a4,-126 # 8001feb0 <bcache+0x8268>
    80002f36:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002f3a:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f3e:	00015497          	auipc	s1,0x15
    80002f42:	d2248493          	addi	s1,s1,-734 # 80017c60 <bcache+0x18>
    b->next = bcache.head.next;
    80002f46:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002f48:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002f4a:	00004a17          	auipc	s4,0x4
    80002f4e:	65ea0a13          	addi	s4,s4,1630 # 800075a8 <etext+0x5a8>
    b->next = bcache.head.next;
    80002f52:	2b893783          	ld	a5,696(s2)
    80002f56:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002f58:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002f5c:	85d2                	mv	a1,s4
    80002f5e:	01048513          	addi	a0,s1,16
    80002f62:	29c010ef          	jal	800041fe <initsleeplock>
    bcache.head.next->prev = b;
    80002f66:	2b893783          	ld	a5,696(s2)
    80002f6a:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002f6c:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f70:	45848493          	addi	s1,s1,1112
    80002f74:	fd349fe3          	bne	s1,s3,80002f52 <binit+0x50>
  }
}
    80002f78:	70a2                	ld	ra,40(sp)
    80002f7a:	7402                	ld	s0,32(sp)
    80002f7c:	64e2                	ld	s1,24(sp)
    80002f7e:	6942                	ld	s2,16(sp)
    80002f80:	69a2                	ld	s3,8(sp)
    80002f82:	6a02                	ld	s4,0(sp)
    80002f84:	6145                	addi	sp,sp,48
    80002f86:	8082                	ret

0000000080002f88 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002f88:	7179                	addi	sp,sp,-48
    80002f8a:	f406                	sd	ra,40(sp)
    80002f8c:	f022                	sd	s0,32(sp)
    80002f8e:	ec26                	sd	s1,24(sp)
    80002f90:	e84a                	sd	s2,16(sp)
    80002f92:	e44e                	sd	s3,8(sp)
    80002f94:	1800                	addi	s0,sp,48
    80002f96:	892a                	mv	s2,a0
    80002f98:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002f9a:	00015517          	auipc	a0,0x15
    80002f9e:	cae50513          	addi	a0,a0,-850 # 80017c48 <bcache>
    80002fa2:	c53fd0ef          	jal	80000bf4 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002fa6:	0001d497          	auipc	s1,0x1d
    80002faa:	f5a4b483          	ld	s1,-166(s1) # 8001ff00 <bcache+0x82b8>
    80002fae:	0001d797          	auipc	a5,0x1d
    80002fb2:	f0278793          	addi	a5,a5,-254 # 8001feb0 <bcache+0x8268>
    80002fb6:	02f48b63          	beq	s1,a5,80002fec <bread+0x64>
    80002fba:	873e                	mv	a4,a5
    80002fbc:	a021                	j	80002fc4 <bread+0x3c>
    80002fbe:	68a4                	ld	s1,80(s1)
    80002fc0:	02e48663          	beq	s1,a4,80002fec <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002fc4:	449c                	lw	a5,8(s1)
    80002fc6:	ff279ce3          	bne	a5,s2,80002fbe <bread+0x36>
    80002fca:	44dc                	lw	a5,12(s1)
    80002fcc:	ff3799e3          	bne	a5,s3,80002fbe <bread+0x36>
      b->refcnt++;
    80002fd0:	40bc                	lw	a5,64(s1)
    80002fd2:	2785                	addiw	a5,a5,1
    80002fd4:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002fd6:	00015517          	auipc	a0,0x15
    80002fda:	c7250513          	addi	a0,a0,-910 # 80017c48 <bcache>
    80002fde:	caffd0ef          	jal	80000c8c <release>
      acquiresleep(&b->lock);
    80002fe2:	01048513          	addi	a0,s1,16
    80002fe6:	24e010ef          	jal	80004234 <acquiresleep>
      return b;
    80002fea:	a889                	j	8000303c <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002fec:	0001d497          	auipc	s1,0x1d
    80002ff0:	f0c4b483          	ld	s1,-244(s1) # 8001fef8 <bcache+0x82b0>
    80002ff4:	0001d797          	auipc	a5,0x1d
    80002ff8:	ebc78793          	addi	a5,a5,-324 # 8001feb0 <bcache+0x8268>
    80002ffc:	00f48863          	beq	s1,a5,8000300c <bread+0x84>
    80003000:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003002:	40bc                	lw	a5,64(s1)
    80003004:	cb91                	beqz	a5,80003018 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003006:	64a4                	ld	s1,72(s1)
    80003008:	fee49de3          	bne	s1,a4,80003002 <bread+0x7a>
  panic("bget: no buffers");
    8000300c:	00004517          	auipc	a0,0x4
    80003010:	5a450513          	addi	a0,a0,1444 # 800075b0 <etext+0x5b0>
    80003014:	f80fd0ef          	jal	80000794 <panic>
      b->dev = dev;
    80003018:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000301c:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003020:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003024:	4785                	li	a5,1
    80003026:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003028:	00015517          	auipc	a0,0x15
    8000302c:	c2050513          	addi	a0,a0,-992 # 80017c48 <bcache>
    80003030:	c5dfd0ef          	jal	80000c8c <release>
      acquiresleep(&b->lock);
    80003034:	01048513          	addi	a0,s1,16
    80003038:	1fc010ef          	jal	80004234 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000303c:	409c                	lw	a5,0(s1)
    8000303e:	cb89                	beqz	a5,80003050 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003040:	8526                	mv	a0,s1
    80003042:	70a2                	ld	ra,40(sp)
    80003044:	7402                	ld	s0,32(sp)
    80003046:	64e2                	ld	s1,24(sp)
    80003048:	6942                	ld	s2,16(sp)
    8000304a:	69a2                	ld	s3,8(sp)
    8000304c:	6145                	addi	sp,sp,48
    8000304e:	8082                	ret
    virtio_disk_rw(b, 0);
    80003050:	4581                	li	a1,0
    80003052:	8526                	mv	a0,s1
    80003054:	23d020ef          	jal	80005a90 <virtio_disk_rw>
    b->valid = 1;
    80003058:	4785                	li	a5,1
    8000305a:	c09c                	sw	a5,0(s1)
  return b;
    8000305c:	b7d5                	j	80003040 <bread+0xb8>

000000008000305e <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000305e:	1101                	addi	sp,sp,-32
    80003060:	ec06                	sd	ra,24(sp)
    80003062:	e822                	sd	s0,16(sp)
    80003064:	e426                	sd	s1,8(sp)
    80003066:	1000                	addi	s0,sp,32
    80003068:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000306a:	0541                	addi	a0,a0,16
    8000306c:	246010ef          	jal	800042b2 <holdingsleep>
    80003070:	c911                	beqz	a0,80003084 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003072:	4585                	li	a1,1
    80003074:	8526                	mv	a0,s1
    80003076:	21b020ef          	jal	80005a90 <virtio_disk_rw>
}
    8000307a:	60e2                	ld	ra,24(sp)
    8000307c:	6442                	ld	s0,16(sp)
    8000307e:	64a2                	ld	s1,8(sp)
    80003080:	6105                	addi	sp,sp,32
    80003082:	8082                	ret
    panic("bwrite");
    80003084:	00004517          	auipc	a0,0x4
    80003088:	54450513          	addi	a0,a0,1348 # 800075c8 <etext+0x5c8>
    8000308c:	f08fd0ef          	jal	80000794 <panic>

0000000080003090 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003090:	1101                	addi	sp,sp,-32
    80003092:	ec06                	sd	ra,24(sp)
    80003094:	e822                	sd	s0,16(sp)
    80003096:	e426                	sd	s1,8(sp)
    80003098:	e04a                	sd	s2,0(sp)
    8000309a:	1000                	addi	s0,sp,32
    8000309c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000309e:	01050913          	addi	s2,a0,16
    800030a2:	854a                	mv	a0,s2
    800030a4:	20e010ef          	jal	800042b2 <holdingsleep>
    800030a8:	c135                	beqz	a0,8000310c <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    800030aa:	854a                	mv	a0,s2
    800030ac:	1ce010ef          	jal	8000427a <releasesleep>

  acquire(&bcache.lock);
    800030b0:	00015517          	auipc	a0,0x15
    800030b4:	b9850513          	addi	a0,a0,-1128 # 80017c48 <bcache>
    800030b8:	b3dfd0ef          	jal	80000bf4 <acquire>
  b->refcnt--;
    800030bc:	40bc                	lw	a5,64(s1)
    800030be:	37fd                	addiw	a5,a5,-1
    800030c0:	0007871b          	sext.w	a4,a5
    800030c4:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800030c6:	e71d                	bnez	a4,800030f4 <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800030c8:	68b8                	ld	a4,80(s1)
    800030ca:	64bc                	ld	a5,72(s1)
    800030cc:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    800030ce:	68b8                	ld	a4,80(s1)
    800030d0:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800030d2:	0001d797          	auipc	a5,0x1d
    800030d6:	b7678793          	addi	a5,a5,-1162 # 8001fc48 <bcache+0x8000>
    800030da:	2b87b703          	ld	a4,696(a5)
    800030de:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800030e0:	0001d717          	auipc	a4,0x1d
    800030e4:	dd070713          	addi	a4,a4,-560 # 8001feb0 <bcache+0x8268>
    800030e8:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800030ea:	2b87b703          	ld	a4,696(a5)
    800030ee:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800030f0:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800030f4:	00015517          	auipc	a0,0x15
    800030f8:	b5450513          	addi	a0,a0,-1196 # 80017c48 <bcache>
    800030fc:	b91fd0ef          	jal	80000c8c <release>
}
    80003100:	60e2                	ld	ra,24(sp)
    80003102:	6442                	ld	s0,16(sp)
    80003104:	64a2                	ld	s1,8(sp)
    80003106:	6902                	ld	s2,0(sp)
    80003108:	6105                	addi	sp,sp,32
    8000310a:	8082                	ret
    panic("brelse");
    8000310c:	00004517          	auipc	a0,0x4
    80003110:	4c450513          	addi	a0,a0,1220 # 800075d0 <etext+0x5d0>
    80003114:	e80fd0ef          	jal	80000794 <panic>

0000000080003118 <bpin>:

void
bpin(struct buf *b) {
    80003118:	1101                	addi	sp,sp,-32
    8000311a:	ec06                	sd	ra,24(sp)
    8000311c:	e822                	sd	s0,16(sp)
    8000311e:	e426                	sd	s1,8(sp)
    80003120:	1000                	addi	s0,sp,32
    80003122:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003124:	00015517          	auipc	a0,0x15
    80003128:	b2450513          	addi	a0,a0,-1244 # 80017c48 <bcache>
    8000312c:	ac9fd0ef          	jal	80000bf4 <acquire>
  b->refcnt++;
    80003130:	40bc                	lw	a5,64(s1)
    80003132:	2785                	addiw	a5,a5,1
    80003134:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003136:	00015517          	auipc	a0,0x15
    8000313a:	b1250513          	addi	a0,a0,-1262 # 80017c48 <bcache>
    8000313e:	b4ffd0ef          	jal	80000c8c <release>
}
    80003142:	60e2                	ld	ra,24(sp)
    80003144:	6442                	ld	s0,16(sp)
    80003146:	64a2                	ld	s1,8(sp)
    80003148:	6105                	addi	sp,sp,32
    8000314a:	8082                	ret

000000008000314c <bunpin>:

void
bunpin(struct buf *b) {
    8000314c:	1101                	addi	sp,sp,-32
    8000314e:	ec06                	sd	ra,24(sp)
    80003150:	e822                	sd	s0,16(sp)
    80003152:	e426                	sd	s1,8(sp)
    80003154:	1000                	addi	s0,sp,32
    80003156:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003158:	00015517          	auipc	a0,0x15
    8000315c:	af050513          	addi	a0,a0,-1296 # 80017c48 <bcache>
    80003160:	a95fd0ef          	jal	80000bf4 <acquire>
  b->refcnt--;
    80003164:	40bc                	lw	a5,64(s1)
    80003166:	37fd                	addiw	a5,a5,-1
    80003168:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000316a:	00015517          	auipc	a0,0x15
    8000316e:	ade50513          	addi	a0,a0,-1314 # 80017c48 <bcache>
    80003172:	b1bfd0ef          	jal	80000c8c <release>
}
    80003176:	60e2                	ld	ra,24(sp)
    80003178:	6442                	ld	s0,16(sp)
    8000317a:	64a2                	ld	s1,8(sp)
    8000317c:	6105                	addi	sp,sp,32
    8000317e:	8082                	ret

0000000080003180 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003180:	1101                	addi	sp,sp,-32
    80003182:	ec06                	sd	ra,24(sp)
    80003184:	e822                	sd	s0,16(sp)
    80003186:	e426                	sd	s1,8(sp)
    80003188:	e04a                	sd	s2,0(sp)
    8000318a:	1000                	addi	s0,sp,32
    8000318c:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000318e:	00d5d59b          	srliw	a1,a1,0xd
    80003192:	0001d797          	auipc	a5,0x1d
    80003196:	1927a783          	lw	a5,402(a5) # 80020324 <sb+0x1c>
    8000319a:	9dbd                	addw	a1,a1,a5
    8000319c:	dedff0ef          	jal	80002f88 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800031a0:	0074f713          	andi	a4,s1,7
    800031a4:	4785                	li	a5,1
    800031a6:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800031aa:	14ce                	slli	s1,s1,0x33
    800031ac:	90d9                	srli	s1,s1,0x36
    800031ae:	00950733          	add	a4,a0,s1
    800031b2:	05874703          	lbu	a4,88(a4)
    800031b6:	00e7f6b3          	and	a3,a5,a4
    800031ba:	c29d                	beqz	a3,800031e0 <bfree+0x60>
    800031bc:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800031be:	94aa                	add	s1,s1,a0
    800031c0:	fff7c793          	not	a5,a5
    800031c4:	8f7d                	and	a4,a4,a5
    800031c6:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800031ca:	711000ef          	jal	800040da <log_write>
  brelse(bp);
    800031ce:	854a                	mv	a0,s2
    800031d0:	ec1ff0ef          	jal	80003090 <brelse>
}
    800031d4:	60e2                	ld	ra,24(sp)
    800031d6:	6442                	ld	s0,16(sp)
    800031d8:	64a2                	ld	s1,8(sp)
    800031da:	6902                	ld	s2,0(sp)
    800031dc:	6105                	addi	sp,sp,32
    800031de:	8082                	ret
    panic("freeing free block");
    800031e0:	00004517          	auipc	a0,0x4
    800031e4:	3f850513          	addi	a0,a0,1016 # 800075d8 <etext+0x5d8>
    800031e8:	dacfd0ef          	jal	80000794 <panic>

00000000800031ec <balloc>:
{
    800031ec:	711d                	addi	sp,sp,-96
    800031ee:	ec86                	sd	ra,88(sp)
    800031f0:	e8a2                	sd	s0,80(sp)
    800031f2:	e4a6                	sd	s1,72(sp)
    800031f4:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800031f6:	0001d797          	auipc	a5,0x1d
    800031fa:	1167a783          	lw	a5,278(a5) # 8002030c <sb+0x4>
    800031fe:	0e078f63          	beqz	a5,800032fc <balloc+0x110>
    80003202:	e0ca                	sd	s2,64(sp)
    80003204:	fc4e                	sd	s3,56(sp)
    80003206:	f852                	sd	s4,48(sp)
    80003208:	f456                	sd	s5,40(sp)
    8000320a:	f05a                	sd	s6,32(sp)
    8000320c:	ec5e                	sd	s7,24(sp)
    8000320e:	e862                	sd	s8,16(sp)
    80003210:	e466                	sd	s9,8(sp)
    80003212:	8baa                	mv	s7,a0
    80003214:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003216:	0001db17          	auipc	s6,0x1d
    8000321a:	0f2b0b13          	addi	s6,s6,242 # 80020308 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000321e:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003220:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003222:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003224:	6c89                	lui	s9,0x2
    80003226:	a0b5                	j	80003292 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003228:	97ca                	add	a5,a5,s2
    8000322a:	8e55                	or	a2,a2,a3
    8000322c:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003230:	854a                	mv	a0,s2
    80003232:	6a9000ef          	jal	800040da <log_write>
        brelse(bp);
    80003236:	854a                	mv	a0,s2
    80003238:	e59ff0ef          	jal	80003090 <brelse>
  bp = bread(dev, bno);
    8000323c:	85a6                	mv	a1,s1
    8000323e:	855e                	mv	a0,s7
    80003240:	d49ff0ef          	jal	80002f88 <bread>
    80003244:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003246:	40000613          	li	a2,1024
    8000324a:	4581                	li	a1,0
    8000324c:	05850513          	addi	a0,a0,88
    80003250:	a79fd0ef          	jal	80000cc8 <memset>
  log_write(bp);
    80003254:	854a                	mv	a0,s2
    80003256:	685000ef          	jal	800040da <log_write>
  brelse(bp);
    8000325a:	854a                	mv	a0,s2
    8000325c:	e35ff0ef          	jal	80003090 <brelse>
}
    80003260:	6906                	ld	s2,64(sp)
    80003262:	79e2                	ld	s3,56(sp)
    80003264:	7a42                	ld	s4,48(sp)
    80003266:	7aa2                	ld	s5,40(sp)
    80003268:	7b02                	ld	s6,32(sp)
    8000326a:	6be2                	ld	s7,24(sp)
    8000326c:	6c42                	ld	s8,16(sp)
    8000326e:	6ca2                	ld	s9,8(sp)
}
    80003270:	8526                	mv	a0,s1
    80003272:	60e6                	ld	ra,88(sp)
    80003274:	6446                	ld	s0,80(sp)
    80003276:	64a6                	ld	s1,72(sp)
    80003278:	6125                	addi	sp,sp,96
    8000327a:	8082                	ret
    brelse(bp);
    8000327c:	854a                	mv	a0,s2
    8000327e:	e13ff0ef          	jal	80003090 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003282:	015c87bb          	addw	a5,s9,s5
    80003286:	00078a9b          	sext.w	s5,a5
    8000328a:	004b2703          	lw	a4,4(s6)
    8000328e:	04eaff63          	bgeu	s5,a4,800032ec <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    80003292:	41fad79b          	sraiw	a5,s5,0x1f
    80003296:	0137d79b          	srliw	a5,a5,0x13
    8000329a:	015787bb          	addw	a5,a5,s5
    8000329e:	40d7d79b          	sraiw	a5,a5,0xd
    800032a2:	01cb2583          	lw	a1,28(s6)
    800032a6:	9dbd                	addw	a1,a1,a5
    800032a8:	855e                	mv	a0,s7
    800032aa:	cdfff0ef          	jal	80002f88 <bread>
    800032ae:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032b0:	004b2503          	lw	a0,4(s6)
    800032b4:	000a849b          	sext.w	s1,s5
    800032b8:	8762                	mv	a4,s8
    800032ba:	fca4f1e3          	bgeu	s1,a0,8000327c <balloc+0x90>
      m = 1 << (bi % 8);
    800032be:	00777693          	andi	a3,a4,7
    800032c2:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800032c6:	41f7579b          	sraiw	a5,a4,0x1f
    800032ca:	01d7d79b          	srliw	a5,a5,0x1d
    800032ce:	9fb9                	addw	a5,a5,a4
    800032d0:	4037d79b          	sraiw	a5,a5,0x3
    800032d4:	00f90633          	add	a2,s2,a5
    800032d8:	05864603          	lbu	a2,88(a2)
    800032dc:	00c6f5b3          	and	a1,a3,a2
    800032e0:	d5a1                	beqz	a1,80003228 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032e2:	2705                	addiw	a4,a4,1
    800032e4:	2485                	addiw	s1,s1,1
    800032e6:	fd471ae3          	bne	a4,s4,800032ba <balloc+0xce>
    800032ea:	bf49                	j	8000327c <balloc+0x90>
    800032ec:	6906                	ld	s2,64(sp)
    800032ee:	79e2                	ld	s3,56(sp)
    800032f0:	7a42                	ld	s4,48(sp)
    800032f2:	7aa2                	ld	s5,40(sp)
    800032f4:	7b02                	ld	s6,32(sp)
    800032f6:	6be2                	ld	s7,24(sp)
    800032f8:	6c42                	ld	s8,16(sp)
    800032fa:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    800032fc:	00004517          	auipc	a0,0x4
    80003300:	2f450513          	addi	a0,a0,756 # 800075f0 <etext+0x5f0>
    80003304:	9befd0ef          	jal	800004c2 <printf>
  return 0;
    80003308:	4481                	li	s1,0
    8000330a:	b79d                	j	80003270 <balloc+0x84>

000000008000330c <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000330c:	7179                	addi	sp,sp,-48
    8000330e:	f406                	sd	ra,40(sp)
    80003310:	f022                	sd	s0,32(sp)
    80003312:	ec26                	sd	s1,24(sp)
    80003314:	e84a                	sd	s2,16(sp)
    80003316:	e44e                	sd	s3,8(sp)
    80003318:	1800                	addi	s0,sp,48
    8000331a:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000331c:	47ad                	li	a5,11
    8000331e:	02b7e663          	bltu	a5,a1,8000334a <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80003322:	02059793          	slli	a5,a1,0x20
    80003326:	01e7d593          	srli	a1,a5,0x1e
    8000332a:	00b504b3          	add	s1,a0,a1
    8000332e:	0504a903          	lw	s2,80(s1)
    80003332:	06091a63          	bnez	s2,800033a6 <bmap+0x9a>
      addr = balloc(ip->dev);
    80003336:	4108                	lw	a0,0(a0)
    80003338:	eb5ff0ef          	jal	800031ec <balloc>
    8000333c:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003340:	06090363          	beqz	s2,800033a6 <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    80003344:	0524a823          	sw	s2,80(s1)
    80003348:	a8b9                	j	800033a6 <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000334a:	ff45849b          	addiw	s1,a1,-12
    8000334e:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003352:	0ff00793          	li	a5,255
    80003356:	06e7ee63          	bltu	a5,a4,800033d2 <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000335a:	08052903          	lw	s2,128(a0)
    8000335e:	00091d63          	bnez	s2,80003378 <bmap+0x6c>
      addr = balloc(ip->dev);
    80003362:	4108                	lw	a0,0(a0)
    80003364:	e89ff0ef          	jal	800031ec <balloc>
    80003368:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000336c:	02090d63          	beqz	s2,800033a6 <bmap+0x9a>
    80003370:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003372:	0929a023          	sw	s2,128(s3)
    80003376:	a011                	j	8000337a <bmap+0x6e>
    80003378:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    8000337a:	85ca                	mv	a1,s2
    8000337c:	0009a503          	lw	a0,0(s3)
    80003380:	c09ff0ef          	jal	80002f88 <bread>
    80003384:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003386:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000338a:	02049713          	slli	a4,s1,0x20
    8000338e:	01e75593          	srli	a1,a4,0x1e
    80003392:	00b784b3          	add	s1,a5,a1
    80003396:	0004a903          	lw	s2,0(s1)
    8000339a:	00090e63          	beqz	s2,800033b6 <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000339e:	8552                	mv	a0,s4
    800033a0:	cf1ff0ef          	jal	80003090 <brelse>
    return addr;
    800033a4:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800033a6:	854a                	mv	a0,s2
    800033a8:	70a2                	ld	ra,40(sp)
    800033aa:	7402                	ld	s0,32(sp)
    800033ac:	64e2                	ld	s1,24(sp)
    800033ae:	6942                	ld	s2,16(sp)
    800033b0:	69a2                	ld	s3,8(sp)
    800033b2:	6145                	addi	sp,sp,48
    800033b4:	8082                	ret
      addr = balloc(ip->dev);
    800033b6:	0009a503          	lw	a0,0(s3)
    800033ba:	e33ff0ef          	jal	800031ec <balloc>
    800033be:	0005091b          	sext.w	s2,a0
      if(addr){
    800033c2:	fc090ee3          	beqz	s2,8000339e <bmap+0x92>
        a[bn] = addr;
    800033c6:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800033ca:	8552                	mv	a0,s4
    800033cc:	50f000ef          	jal	800040da <log_write>
    800033d0:	b7f9                	j	8000339e <bmap+0x92>
    800033d2:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    800033d4:	00004517          	auipc	a0,0x4
    800033d8:	23450513          	addi	a0,a0,564 # 80007608 <etext+0x608>
    800033dc:	bb8fd0ef          	jal	80000794 <panic>

00000000800033e0 <iget>:
{
    800033e0:	7179                	addi	sp,sp,-48
    800033e2:	f406                	sd	ra,40(sp)
    800033e4:	f022                	sd	s0,32(sp)
    800033e6:	ec26                	sd	s1,24(sp)
    800033e8:	e84a                	sd	s2,16(sp)
    800033ea:	e44e                	sd	s3,8(sp)
    800033ec:	e052                	sd	s4,0(sp)
    800033ee:	1800                	addi	s0,sp,48
    800033f0:	89aa                	mv	s3,a0
    800033f2:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800033f4:	0001d517          	auipc	a0,0x1d
    800033f8:	f3450513          	addi	a0,a0,-204 # 80020328 <itable>
    800033fc:	ff8fd0ef          	jal	80000bf4 <acquire>
  empty = 0;
    80003400:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003402:	0001d497          	auipc	s1,0x1d
    80003406:	f3e48493          	addi	s1,s1,-194 # 80020340 <itable+0x18>
    8000340a:	0001f697          	auipc	a3,0x1f
    8000340e:	9c668693          	addi	a3,a3,-1594 # 80021dd0 <log>
    80003412:	a039                	j	80003420 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003414:	02090963          	beqz	s2,80003446 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003418:	08848493          	addi	s1,s1,136
    8000341c:	02d48863          	beq	s1,a3,8000344c <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003420:	449c                	lw	a5,8(s1)
    80003422:	fef059e3          	blez	a5,80003414 <iget+0x34>
    80003426:	4098                	lw	a4,0(s1)
    80003428:	ff3716e3          	bne	a4,s3,80003414 <iget+0x34>
    8000342c:	40d8                	lw	a4,4(s1)
    8000342e:	ff4713e3          	bne	a4,s4,80003414 <iget+0x34>
      ip->ref++;
    80003432:	2785                	addiw	a5,a5,1
    80003434:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003436:	0001d517          	auipc	a0,0x1d
    8000343a:	ef250513          	addi	a0,a0,-270 # 80020328 <itable>
    8000343e:	84ffd0ef          	jal	80000c8c <release>
      return ip;
    80003442:	8926                	mv	s2,s1
    80003444:	a02d                	j	8000346e <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003446:	fbe9                	bnez	a5,80003418 <iget+0x38>
      empty = ip;
    80003448:	8926                	mv	s2,s1
    8000344a:	b7f9                	j	80003418 <iget+0x38>
  if(empty == 0)
    8000344c:	02090a63          	beqz	s2,80003480 <iget+0xa0>
  ip->dev = dev;
    80003450:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003454:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003458:	4785                	li	a5,1
    8000345a:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000345e:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003462:	0001d517          	auipc	a0,0x1d
    80003466:	ec650513          	addi	a0,a0,-314 # 80020328 <itable>
    8000346a:	823fd0ef          	jal	80000c8c <release>
}
    8000346e:	854a                	mv	a0,s2
    80003470:	70a2                	ld	ra,40(sp)
    80003472:	7402                	ld	s0,32(sp)
    80003474:	64e2                	ld	s1,24(sp)
    80003476:	6942                	ld	s2,16(sp)
    80003478:	69a2                	ld	s3,8(sp)
    8000347a:	6a02                	ld	s4,0(sp)
    8000347c:	6145                	addi	sp,sp,48
    8000347e:	8082                	ret
    panic("iget: no inodes");
    80003480:	00004517          	auipc	a0,0x4
    80003484:	1a050513          	addi	a0,a0,416 # 80007620 <etext+0x620>
    80003488:	b0cfd0ef          	jal	80000794 <panic>

000000008000348c <fsinit>:
fsinit(int dev) {
    8000348c:	7179                	addi	sp,sp,-48
    8000348e:	f406                	sd	ra,40(sp)
    80003490:	f022                	sd	s0,32(sp)
    80003492:	ec26                	sd	s1,24(sp)
    80003494:	e84a                	sd	s2,16(sp)
    80003496:	e44e                	sd	s3,8(sp)
    80003498:	1800                	addi	s0,sp,48
    8000349a:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000349c:	4585                	li	a1,1
    8000349e:	aebff0ef          	jal	80002f88 <bread>
    800034a2:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800034a4:	0001d997          	auipc	s3,0x1d
    800034a8:	e6498993          	addi	s3,s3,-412 # 80020308 <sb>
    800034ac:	02000613          	li	a2,32
    800034b0:	05850593          	addi	a1,a0,88
    800034b4:	854e                	mv	a0,s3
    800034b6:	86ffd0ef          	jal	80000d24 <memmove>
  brelse(bp);
    800034ba:	8526                	mv	a0,s1
    800034bc:	bd5ff0ef          	jal	80003090 <brelse>
  if(sb.magic != FSMAGIC)
    800034c0:	0009a703          	lw	a4,0(s3)
    800034c4:	102037b7          	lui	a5,0x10203
    800034c8:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800034cc:	02f71063          	bne	a4,a5,800034ec <fsinit+0x60>
  initlog(dev, &sb);
    800034d0:	0001d597          	auipc	a1,0x1d
    800034d4:	e3858593          	addi	a1,a1,-456 # 80020308 <sb>
    800034d8:	854a                	mv	a0,s2
    800034da:	1f9000ef          	jal	80003ed2 <initlog>
}
    800034de:	70a2                	ld	ra,40(sp)
    800034e0:	7402                	ld	s0,32(sp)
    800034e2:	64e2                	ld	s1,24(sp)
    800034e4:	6942                	ld	s2,16(sp)
    800034e6:	69a2                	ld	s3,8(sp)
    800034e8:	6145                	addi	sp,sp,48
    800034ea:	8082                	ret
    panic("invalid file system");
    800034ec:	00004517          	auipc	a0,0x4
    800034f0:	14450513          	addi	a0,a0,324 # 80007630 <etext+0x630>
    800034f4:	aa0fd0ef          	jal	80000794 <panic>

00000000800034f8 <iinit>:
{
    800034f8:	7179                	addi	sp,sp,-48
    800034fa:	f406                	sd	ra,40(sp)
    800034fc:	f022                	sd	s0,32(sp)
    800034fe:	ec26                	sd	s1,24(sp)
    80003500:	e84a                	sd	s2,16(sp)
    80003502:	e44e                	sd	s3,8(sp)
    80003504:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003506:	00004597          	auipc	a1,0x4
    8000350a:	14258593          	addi	a1,a1,322 # 80007648 <etext+0x648>
    8000350e:	0001d517          	auipc	a0,0x1d
    80003512:	e1a50513          	addi	a0,a0,-486 # 80020328 <itable>
    80003516:	e5efd0ef          	jal	80000b74 <initlock>
  for(i = 0; i < NINODE; i++) {
    8000351a:	0001d497          	auipc	s1,0x1d
    8000351e:	e3648493          	addi	s1,s1,-458 # 80020350 <itable+0x28>
    80003522:	0001f997          	auipc	s3,0x1f
    80003526:	8be98993          	addi	s3,s3,-1858 # 80021de0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000352a:	00004917          	auipc	s2,0x4
    8000352e:	12690913          	addi	s2,s2,294 # 80007650 <etext+0x650>
    80003532:	85ca                	mv	a1,s2
    80003534:	8526                	mv	a0,s1
    80003536:	4c9000ef          	jal	800041fe <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000353a:	08848493          	addi	s1,s1,136
    8000353e:	ff349ae3          	bne	s1,s3,80003532 <iinit+0x3a>
}
    80003542:	70a2                	ld	ra,40(sp)
    80003544:	7402                	ld	s0,32(sp)
    80003546:	64e2                	ld	s1,24(sp)
    80003548:	6942                	ld	s2,16(sp)
    8000354a:	69a2                	ld	s3,8(sp)
    8000354c:	6145                	addi	sp,sp,48
    8000354e:	8082                	ret

0000000080003550 <ialloc>:
{
    80003550:	7139                	addi	sp,sp,-64
    80003552:	fc06                	sd	ra,56(sp)
    80003554:	f822                	sd	s0,48(sp)
    80003556:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003558:	0001d717          	auipc	a4,0x1d
    8000355c:	dbc72703          	lw	a4,-580(a4) # 80020314 <sb+0xc>
    80003560:	4785                	li	a5,1
    80003562:	06e7f063          	bgeu	a5,a4,800035c2 <ialloc+0x72>
    80003566:	f426                	sd	s1,40(sp)
    80003568:	f04a                	sd	s2,32(sp)
    8000356a:	ec4e                	sd	s3,24(sp)
    8000356c:	e852                	sd	s4,16(sp)
    8000356e:	e456                	sd	s5,8(sp)
    80003570:	e05a                	sd	s6,0(sp)
    80003572:	8aaa                	mv	s5,a0
    80003574:	8b2e                	mv	s6,a1
    80003576:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003578:	0001da17          	auipc	s4,0x1d
    8000357c:	d90a0a13          	addi	s4,s4,-624 # 80020308 <sb>
    80003580:	00495593          	srli	a1,s2,0x4
    80003584:	018a2783          	lw	a5,24(s4)
    80003588:	9dbd                	addw	a1,a1,a5
    8000358a:	8556                	mv	a0,s5
    8000358c:	9fdff0ef          	jal	80002f88 <bread>
    80003590:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003592:	05850993          	addi	s3,a0,88
    80003596:	00f97793          	andi	a5,s2,15
    8000359a:	079a                	slli	a5,a5,0x6
    8000359c:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000359e:	00099783          	lh	a5,0(s3)
    800035a2:	cb9d                	beqz	a5,800035d8 <ialloc+0x88>
    brelse(bp);
    800035a4:	aedff0ef          	jal	80003090 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800035a8:	0905                	addi	s2,s2,1
    800035aa:	00ca2703          	lw	a4,12(s4)
    800035ae:	0009079b          	sext.w	a5,s2
    800035b2:	fce7e7e3          	bltu	a5,a4,80003580 <ialloc+0x30>
    800035b6:	74a2                	ld	s1,40(sp)
    800035b8:	7902                	ld	s2,32(sp)
    800035ba:	69e2                	ld	s3,24(sp)
    800035bc:	6a42                	ld	s4,16(sp)
    800035be:	6aa2                	ld	s5,8(sp)
    800035c0:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800035c2:	00004517          	auipc	a0,0x4
    800035c6:	09650513          	addi	a0,a0,150 # 80007658 <etext+0x658>
    800035ca:	ef9fc0ef          	jal	800004c2 <printf>
  return 0;
    800035ce:	4501                	li	a0,0
}
    800035d0:	70e2                	ld	ra,56(sp)
    800035d2:	7442                	ld	s0,48(sp)
    800035d4:	6121                	addi	sp,sp,64
    800035d6:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800035d8:	04000613          	li	a2,64
    800035dc:	4581                	li	a1,0
    800035de:	854e                	mv	a0,s3
    800035e0:	ee8fd0ef          	jal	80000cc8 <memset>
      dip->type = type;
    800035e4:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800035e8:	8526                	mv	a0,s1
    800035ea:	2f1000ef          	jal	800040da <log_write>
      brelse(bp);
    800035ee:	8526                	mv	a0,s1
    800035f0:	aa1ff0ef          	jal	80003090 <brelse>
      return iget(dev, inum);
    800035f4:	0009059b          	sext.w	a1,s2
    800035f8:	8556                	mv	a0,s5
    800035fa:	de7ff0ef          	jal	800033e0 <iget>
    800035fe:	74a2                	ld	s1,40(sp)
    80003600:	7902                	ld	s2,32(sp)
    80003602:	69e2                	ld	s3,24(sp)
    80003604:	6a42                	ld	s4,16(sp)
    80003606:	6aa2                	ld	s5,8(sp)
    80003608:	6b02                	ld	s6,0(sp)
    8000360a:	b7d9                	j	800035d0 <ialloc+0x80>

000000008000360c <iupdate>:
{
    8000360c:	1101                	addi	sp,sp,-32
    8000360e:	ec06                	sd	ra,24(sp)
    80003610:	e822                	sd	s0,16(sp)
    80003612:	e426                	sd	s1,8(sp)
    80003614:	e04a                	sd	s2,0(sp)
    80003616:	1000                	addi	s0,sp,32
    80003618:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000361a:	415c                	lw	a5,4(a0)
    8000361c:	0047d79b          	srliw	a5,a5,0x4
    80003620:	0001d597          	auipc	a1,0x1d
    80003624:	d005a583          	lw	a1,-768(a1) # 80020320 <sb+0x18>
    80003628:	9dbd                	addw	a1,a1,a5
    8000362a:	4108                	lw	a0,0(a0)
    8000362c:	95dff0ef          	jal	80002f88 <bread>
    80003630:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003632:	05850793          	addi	a5,a0,88
    80003636:	40d8                	lw	a4,4(s1)
    80003638:	8b3d                	andi	a4,a4,15
    8000363a:	071a                	slli	a4,a4,0x6
    8000363c:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000363e:	04449703          	lh	a4,68(s1)
    80003642:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003646:	04649703          	lh	a4,70(s1)
    8000364a:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000364e:	04849703          	lh	a4,72(s1)
    80003652:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003656:	04a49703          	lh	a4,74(s1)
    8000365a:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000365e:	44f8                	lw	a4,76(s1)
    80003660:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003662:	03400613          	li	a2,52
    80003666:	05048593          	addi	a1,s1,80
    8000366a:	00c78513          	addi	a0,a5,12
    8000366e:	eb6fd0ef          	jal	80000d24 <memmove>
  log_write(bp);
    80003672:	854a                	mv	a0,s2
    80003674:	267000ef          	jal	800040da <log_write>
  brelse(bp);
    80003678:	854a                	mv	a0,s2
    8000367a:	a17ff0ef          	jal	80003090 <brelse>
}
    8000367e:	60e2                	ld	ra,24(sp)
    80003680:	6442                	ld	s0,16(sp)
    80003682:	64a2                	ld	s1,8(sp)
    80003684:	6902                	ld	s2,0(sp)
    80003686:	6105                	addi	sp,sp,32
    80003688:	8082                	ret

000000008000368a <idup>:
{
    8000368a:	1101                	addi	sp,sp,-32
    8000368c:	ec06                	sd	ra,24(sp)
    8000368e:	e822                	sd	s0,16(sp)
    80003690:	e426                	sd	s1,8(sp)
    80003692:	1000                	addi	s0,sp,32
    80003694:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003696:	0001d517          	auipc	a0,0x1d
    8000369a:	c9250513          	addi	a0,a0,-878 # 80020328 <itable>
    8000369e:	d56fd0ef          	jal	80000bf4 <acquire>
  ip->ref++;
    800036a2:	449c                	lw	a5,8(s1)
    800036a4:	2785                	addiw	a5,a5,1
    800036a6:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800036a8:	0001d517          	auipc	a0,0x1d
    800036ac:	c8050513          	addi	a0,a0,-896 # 80020328 <itable>
    800036b0:	ddcfd0ef          	jal	80000c8c <release>
}
    800036b4:	8526                	mv	a0,s1
    800036b6:	60e2                	ld	ra,24(sp)
    800036b8:	6442                	ld	s0,16(sp)
    800036ba:	64a2                	ld	s1,8(sp)
    800036bc:	6105                	addi	sp,sp,32
    800036be:	8082                	ret

00000000800036c0 <ilock>:
{
    800036c0:	1101                	addi	sp,sp,-32
    800036c2:	ec06                	sd	ra,24(sp)
    800036c4:	e822                	sd	s0,16(sp)
    800036c6:	e426                	sd	s1,8(sp)
    800036c8:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800036ca:	cd19                	beqz	a0,800036e8 <ilock+0x28>
    800036cc:	84aa                	mv	s1,a0
    800036ce:	451c                	lw	a5,8(a0)
    800036d0:	00f05c63          	blez	a5,800036e8 <ilock+0x28>
  acquiresleep(&ip->lock);
    800036d4:	0541                	addi	a0,a0,16
    800036d6:	35f000ef          	jal	80004234 <acquiresleep>
  if(ip->valid == 0){
    800036da:	40bc                	lw	a5,64(s1)
    800036dc:	cf89                	beqz	a5,800036f6 <ilock+0x36>
}
    800036de:	60e2                	ld	ra,24(sp)
    800036e0:	6442                	ld	s0,16(sp)
    800036e2:	64a2                	ld	s1,8(sp)
    800036e4:	6105                	addi	sp,sp,32
    800036e6:	8082                	ret
    800036e8:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800036ea:	00004517          	auipc	a0,0x4
    800036ee:	f8650513          	addi	a0,a0,-122 # 80007670 <etext+0x670>
    800036f2:	8a2fd0ef          	jal	80000794 <panic>
    800036f6:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800036f8:	40dc                	lw	a5,4(s1)
    800036fa:	0047d79b          	srliw	a5,a5,0x4
    800036fe:	0001d597          	auipc	a1,0x1d
    80003702:	c225a583          	lw	a1,-990(a1) # 80020320 <sb+0x18>
    80003706:	9dbd                	addw	a1,a1,a5
    80003708:	4088                	lw	a0,0(s1)
    8000370a:	87fff0ef          	jal	80002f88 <bread>
    8000370e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003710:	05850593          	addi	a1,a0,88
    80003714:	40dc                	lw	a5,4(s1)
    80003716:	8bbd                	andi	a5,a5,15
    80003718:	079a                	slli	a5,a5,0x6
    8000371a:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000371c:	00059783          	lh	a5,0(a1)
    80003720:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003724:	00259783          	lh	a5,2(a1)
    80003728:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000372c:	00459783          	lh	a5,4(a1)
    80003730:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003734:	00659783          	lh	a5,6(a1)
    80003738:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000373c:	459c                	lw	a5,8(a1)
    8000373e:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003740:	03400613          	li	a2,52
    80003744:	05b1                	addi	a1,a1,12
    80003746:	05048513          	addi	a0,s1,80
    8000374a:	ddafd0ef          	jal	80000d24 <memmove>
    brelse(bp);
    8000374e:	854a                	mv	a0,s2
    80003750:	941ff0ef          	jal	80003090 <brelse>
    ip->valid = 1;
    80003754:	4785                	li	a5,1
    80003756:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003758:	04449783          	lh	a5,68(s1)
    8000375c:	c399                	beqz	a5,80003762 <ilock+0xa2>
    8000375e:	6902                	ld	s2,0(sp)
    80003760:	bfbd                	j	800036de <ilock+0x1e>
      panic("ilock: no type");
    80003762:	00004517          	auipc	a0,0x4
    80003766:	f1650513          	addi	a0,a0,-234 # 80007678 <etext+0x678>
    8000376a:	82afd0ef          	jal	80000794 <panic>

000000008000376e <iunlock>:
{
    8000376e:	1101                	addi	sp,sp,-32
    80003770:	ec06                	sd	ra,24(sp)
    80003772:	e822                	sd	s0,16(sp)
    80003774:	e426                	sd	s1,8(sp)
    80003776:	e04a                	sd	s2,0(sp)
    80003778:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000377a:	c505                	beqz	a0,800037a2 <iunlock+0x34>
    8000377c:	84aa                	mv	s1,a0
    8000377e:	01050913          	addi	s2,a0,16
    80003782:	854a                	mv	a0,s2
    80003784:	32f000ef          	jal	800042b2 <holdingsleep>
    80003788:	cd09                	beqz	a0,800037a2 <iunlock+0x34>
    8000378a:	449c                	lw	a5,8(s1)
    8000378c:	00f05b63          	blez	a5,800037a2 <iunlock+0x34>
  releasesleep(&ip->lock);
    80003790:	854a                	mv	a0,s2
    80003792:	2e9000ef          	jal	8000427a <releasesleep>
}
    80003796:	60e2                	ld	ra,24(sp)
    80003798:	6442                	ld	s0,16(sp)
    8000379a:	64a2                	ld	s1,8(sp)
    8000379c:	6902                	ld	s2,0(sp)
    8000379e:	6105                	addi	sp,sp,32
    800037a0:	8082                	ret
    panic("iunlock");
    800037a2:	00004517          	auipc	a0,0x4
    800037a6:	ee650513          	addi	a0,a0,-282 # 80007688 <etext+0x688>
    800037aa:	febfc0ef          	jal	80000794 <panic>

00000000800037ae <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800037ae:	7179                	addi	sp,sp,-48
    800037b0:	f406                	sd	ra,40(sp)
    800037b2:	f022                	sd	s0,32(sp)
    800037b4:	ec26                	sd	s1,24(sp)
    800037b6:	e84a                	sd	s2,16(sp)
    800037b8:	e44e                	sd	s3,8(sp)
    800037ba:	1800                	addi	s0,sp,48
    800037bc:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800037be:	05050493          	addi	s1,a0,80
    800037c2:	08050913          	addi	s2,a0,128
    800037c6:	a021                	j	800037ce <itrunc+0x20>
    800037c8:	0491                	addi	s1,s1,4
    800037ca:	01248b63          	beq	s1,s2,800037e0 <itrunc+0x32>
    if(ip->addrs[i]){
    800037ce:	408c                	lw	a1,0(s1)
    800037d0:	dde5                	beqz	a1,800037c8 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800037d2:	0009a503          	lw	a0,0(s3)
    800037d6:	9abff0ef          	jal	80003180 <bfree>
      ip->addrs[i] = 0;
    800037da:	0004a023          	sw	zero,0(s1)
    800037de:	b7ed                	j	800037c8 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800037e0:	0809a583          	lw	a1,128(s3)
    800037e4:	ed89                	bnez	a1,800037fe <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800037e6:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800037ea:	854e                	mv	a0,s3
    800037ec:	e21ff0ef          	jal	8000360c <iupdate>
}
    800037f0:	70a2                	ld	ra,40(sp)
    800037f2:	7402                	ld	s0,32(sp)
    800037f4:	64e2                	ld	s1,24(sp)
    800037f6:	6942                	ld	s2,16(sp)
    800037f8:	69a2                	ld	s3,8(sp)
    800037fa:	6145                	addi	sp,sp,48
    800037fc:	8082                	ret
    800037fe:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003800:	0009a503          	lw	a0,0(s3)
    80003804:	f84ff0ef          	jal	80002f88 <bread>
    80003808:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000380a:	05850493          	addi	s1,a0,88
    8000380e:	45850913          	addi	s2,a0,1112
    80003812:	a021                	j	8000381a <itrunc+0x6c>
    80003814:	0491                	addi	s1,s1,4
    80003816:	01248963          	beq	s1,s2,80003828 <itrunc+0x7a>
      if(a[j])
    8000381a:	408c                	lw	a1,0(s1)
    8000381c:	dde5                	beqz	a1,80003814 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    8000381e:	0009a503          	lw	a0,0(s3)
    80003822:	95fff0ef          	jal	80003180 <bfree>
    80003826:	b7fd                	j	80003814 <itrunc+0x66>
    brelse(bp);
    80003828:	8552                	mv	a0,s4
    8000382a:	867ff0ef          	jal	80003090 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000382e:	0809a583          	lw	a1,128(s3)
    80003832:	0009a503          	lw	a0,0(s3)
    80003836:	94bff0ef          	jal	80003180 <bfree>
    ip->addrs[NDIRECT] = 0;
    8000383a:	0809a023          	sw	zero,128(s3)
    8000383e:	6a02                	ld	s4,0(sp)
    80003840:	b75d                	j	800037e6 <itrunc+0x38>

0000000080003842 <iput>:
{
    80003842:	1101                	addi	sp,sp,-32
    80003844:	ec06                	sd	ra,24(sp)
    80003846:	e822                	sd	s0,16(sp)
    80003848:	e426                	sd	s1,8(sp)
    8000384a:	1000                	addi	s0,sp,32
    8000384c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000384e:	0001d517          	auipc	a0,0x1d
    80003852:	ada50513          	addi	a0,a0,-1318 # 80020328 <itable>
    80003856:	b9efd0ef          	jal	80000bf4 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000385a:	4498                	lw	a4,8(s1)
    8000385c:	4785                	li	a5,1
    8000385e:	02f70063          	beq	a4,a5,8000387e <iput+0x3c>
  ip->ref--;
    80003862:	449c                	lw	a5,8(s1)
    80003864:	37fd                	addiw	a5,a5,-1
    80003866:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003868:	0001d517          	auipc	a0,0x1d
    8000386c:	ac050513          	addi	a0,a0,-1344 # 80020328 <itable>
    80003870:	c1cfd0ef          	jal	80000c8c <release>
}
    80003874:	60e2                	ld	ra,24(sp)
    80003876:	6442                	ld	s0,16(sp)
    80003878:	64a2                	ld	s1,8(sp)
    8000387a:	6105                	addi	sp,sp,32
    8000387c:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000387e:	40bc                	lw	a5,64(s1)
    80003880:	d3ed                	beqz	a5,80003862 <iput+0x20>
    80003882:	04a49783          	lh	a5,74(s1)
    80003886:	fff1                	bnez	a5,80003862 <iput+0x20>
    80003888:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    8000388a:	01048913          	addi	s2,s1,16
    8000388e:	854a                	mv	a0,s2
    80003890:	1a5000ef          	jal	80004234 <acquiresleep>
    release(&itable.lock);
    80003894:	0001d517          	auipc	a0,0x1d
    80003898:	a9450513          	addi	a0,a0,-1388 # 80020328 <itable>
    8000389c:	bf0fd0ef          	jal	80000c8c <release>
    itrunc(ip);
    800038a0:	8526                	mv	a0,s1
    800038a2:	f0dff0ef          	jal	800037ae <itrunc>
    ip->type = 0;
    800038a6:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800038aa:	8526                	mv	a0,s1
    800038ac:	d61ff0ef          	jal	8000360c <iupdate>
    ip->valid = 0;
    800038b0:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800038b4:	854a                	mv	a0,s2
    800038b6:	1c5000ef          	jal	8000427a <releasesleep>
    acquire(&itable.lock);
    800038ba:	0001d517          	auipc	a0,0x1d
    800038be:	a6e50513          	addi	a0,a0,-1426 # 80020328 <itable>
    800038c2:	b32fd0ef          	jal	80000bf4 <acquire>
    800038c6:	6902                	ld	s2,0(sp)
    800038c8:	bf69                	j	80003862 <iput+0x20>

00000000800038ca <iunlockput>:
{
    800038ca:	1101                	addi	sp,sp,-32
    800038cc:	ec06                	sd	ra,24(sp)
    800038ce:	e822                	sd	s0,16(sp)
    800038d0:	e426                	sd	s1,8(sp)
    800038d2:	1000                	addi	s0,sp,32
    800038d4:	84aa                	mv	s1,a0
  iunlock(ip);
    800038d6:	e99ff0ef          	jal	8000376e <iunlock>
  iput(ip);
    800038da:	8526                	mv	a0,s1
    800038dc:	f67ff0ef          	jal	80003842 <iput>
}
    800038e0:	60e2                	ld	ra,24(sp)
    800038e2:	6442                	ld	s0,16(sp)
    800038e4:	64a2                	ld	s1,8(sp)
    800038e6:	6105                	addi	sp,sp,32
    800038e8:	8082                	ret

00000000800038ea <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800038ea:	1141                	addi	sp,sp,-16
    800038ec:	e422                	sd	s0,8(sp)
    800038ee:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800038f0:	411c                	lw	a5,0(a0)
    800038f2:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800038f4:	415c                	lw	a5,4(a0)
    800038f6:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800038f8:	04451783          	lh	a5,68(a0)
    800038fc:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003900:	04a51783          	lh	a5,74(a0)
    80003904:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003908:	04c56783          	lwu	a5,76(a0)
    8000390c:	e99c                	sd	a5,16(a1)
}
    8000390e:	6422                	ld	s0,8(sp)
    80003910:	0141                	addi	sp,sp,16
    80003912:	8082                	ret

0000000080003914 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003914:	457c                	lw	a5,76(a0)
    80003916:	0ed7eb63          	bltu	a5,a3,80003a0c <readi+0xf8>
{
    8000391a:	7159                	addi	sp,sp,-112
    8000391c:	f486                	sd	ra,104(sp)
    8000391e:	f0a2                	sd	s0,96(sp)
    80003920:	eca6                	sd	s1,88(sp)
    80003922:	e0d2                	sd	s4,64(sp)
    80003924:	fc56                	sd	s5,56(sp)
    80003926:	f85a                	sd	s6,48(sp)
    80003928:	f45e                	sd	s7,40(sp)
    8000392a:	1880                	addi	s0,sp,112
    8000392c:	8b2a                	mv	s6,a0
    8000392e:	8bae                	mv	s7,a1
    80003930:	8a32                	mv	s4,a2
    80003932:	84b6                	mv	s1,a3
    80003934:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003936:	9f35                	addw	a4,a4,a3
    return 0;
    80003938:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000393a:	0cd76063          	bltu	a4,a3,800039fa <readi+0xe6>
    8000393e:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003940:	00e7f463          	bgeu	a5,a4,80003948 <readi+0x34>
    n = ip->size - off;
    80003944:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003948:	080a8f63          	beqz	s5,800039e6 <readi+0xd2>
    8000394c:	e8ca                	sd	s2,80(sp)
    8000394e:	f062                	sd	s8,32(sp)
    80003950:	ec66                	sd	s9,24(sp)
    80003952:	e86a                	sd	s10,16(sp)
    80003954:	e46e                	sd	s11,8(sp)
    80003956:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003958:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000395c:	5c7d                	li	s8,-1
    8000395e:	a80d                	j	80003990 <readi+0x7c>
    80003960:	020d1d93          	slli	s11,s10,0x20
    80003964:	020ddd93          	srli	s11,s11,0x20
    80003968:	05890613          	addi	a2,s2,88
    8000396c:	86ee                	mv	a3,s11
    8000396e:	963a                	add	a2,a2,a4
    80003970:	85d2                	mv	a1,s4
    80003972:	855e                	mv	a0,s7
    80003974:	c65fe0ef          	jal	800025d8 <either_copyout>
    80003978:	05850763          	beq	a0,s8,800039c6 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    8000397c:	854a                	mv	a0,s2
    8000397e:	f12ff0ef          	jal	80003090 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003982:	013d09bb          	addw	s3,s10,s3
    80003986:	009d04bb          	addw	s1,s10,s1
    8000398a:	9a6e                	add	s4,s4,s11
    8000398c:	0559f763          	bgeu	s3,s5,800039da <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    80003990:	00a4d59b          	srliw	a1,s1,0xa
    80003994:	855a                	mv	a0,s6
    80003996:	977ff0ef          	jal	8000330c <bmap>
    8000399a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000399e:	c5b1                	beqz	a1,800039ea <readi+0xd6>
    bp = bread(ip->dev, addr);
    800039a0:	000b2503          	lw	a0,0(s6)
    800039a4:	de4ff0ef          	jal	80002f88 <bread>
    800039a8:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800039aa:	3ff4f713          	andi	a4,s1,1023
    800039ae:	40ec87bb          	subw	a5,s9,a4
    800039b2:	413a86bb          	subw	a3,s5,s3
    800039b6:	8d3e                	mv	s10,a5
    800039b8:	2781                	sext.w	a5,a5
    800039ba:	0006861b          	sext.w	a2,a3
    800039be:	faf671e3          	bgeu	a2,a5,80003960 <readi+0x4c>
    800039c2:	8d36                	mv	s10,a3
    800039c4:	bf71                	j	80003960 <readi+0x4c>
      brelse(bp);
    800039c6:	854a                	mv	a0,s2
    800039c8:	ec8ff0ef          	jal	80003090 <brelse>
      tot = -1;
    800039cc:	59fd                	li	s3,-1
      break;
    800039ce:	6946                	ld	s2,80(sp)
    800039d0:	7c02                	ld	s8,32(sp)
    800039d2:	6ce2                	ld	s9,24(sp)
    800039d4:	6d42                	ld	s10,16(sp)
    800039d6:	6da2                	ld	s11,8(sp)
    800039d8:	a831                	j	800039f4 <readi+0xe0>
    800039da:	6946                	ld	s2,80(sp)
    800039dc:	7c02                	ld	s8,32(sp)
    800039de:	6ce2                	ld	s9,24(sp)
    800039e0:	6d42                	ld	s10,16(sp)
    800039e2:	6da2                	ld	s11,8(sp)
    800039e4:	a801                	j	800039f4 <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800039e6:	89d6                	mv	s3,s5
    800039e8:	a031                	j	800039f4 <readi+0xe0>
    800039ea:	6946                	ld	s2,80(sp)
    800039ec:	7c02                	ld	s8,32(sp)
    800039ee:	6ce2                	ld	s9,24(sp)
    800039f0:	6d42                	ld	s10,16(sp)
    800039f2:	6da2                	ld	s11,8(sp)
  }
  return tot;
    800039f4:	0009851b          	sext.w	a0,s3
    800039f8:	69a6                	ld	s3,72(sp)
}
    800039fa:	70a6                	ld	ra,104(sp)
    800039fc:	7406                	ld	s0,96(sp)
    800039fe:	64e6                	ld	s1,88(sp)
    80003a00:	6a06                	ld	s4,64(sp)
    80003a02:	7ae2                	ld	s5,56(sp)
    80003a04:	7b42                	ld	s6,48(sp)
    80003a06:	7ba2                	ld	s7,40(sp)
    80003a08:	6165                	addi	sp,sp,112
    80003a0a:	8082                	ret
    return 0;
    80003a0c:	4501                	li	a0,0
}
    80003a0e:	8082                	ret

0000000080003a10 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a10:	457c                	lw	a5,76(a0)
    80003a12:	10d7e063          	bltu	a5,a3,80003b12 <writei+0x102>
{
    80003a16:	7159                	addi	sp,sp,-112
    80003a18:	f486                	sd	ra,104(sp)
    80003a1a:	f0a2                	sd	s0,96(sp)
    80003a1c:	e8ca                	sd	s2,80(sp)
    80003a1e:	e0d2                	sd	s4,64(sp)
    80003a20:	fc56                	sd	s5,56(sp)
    80003a22:	f85a                	sd	s6,48(sp)
    80003a24:	f45e                	sd	s7,40(sp)
    80003a26:	1880                	addi	s0,sp,112
    80003a28:	8aaa                	mv	s5,a0
    80003a2a:	8bae                	mv	s7,a1
    80003a2c:	8a32                	mv	s4,a2
    80003a2e:	8936                	mv	s2,a3
    80003a30:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003a32:	00e687bb          	addw	a5,a3,a4
    80003a36:	0ed7e063          	bltu	a5,a3,80003b16 <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003a3a:	00043737          	lui	a4,0x43
    80003a3e:	0cf76e63          	bltu	a4,a5,80003b1a <writei+0x10a>
    80003a42:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a44:	0a0b0f63          	beqz	s6,80003b02 <writei+0xf2>
    80003a48:	eca6                	sd	s1,88(sp)
    80003a4a:	f062                	sd	s8,32(sp)
    80003a4c:	ec66                	sd	s9,24(sp)
    80003a4e:	e86a                	sd	s10,16(sp)
    80003a50:	e46e                	sd	s11,8(sp)
    80003a52:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a54:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003a58:	5c7d                	li	s8,-1
    80003a5a:	a825                	j	80003a92 <writei+0x82>
    80003a5c:	020d1d93          	slli	s11,s10,0x20
    80003a60:	020ddd93          	srli	s11,s11,0x20
    80003a64:	05848513          	addi	a0,s1,88
    80003a68:	86ee                	mv	a3,s11
    80003a6a:	8652                	mv	a2,s4
    80003a6c:	85de                	mv	a1,s7
    80003a6e:	953a                	add	a0,a0,a4
    80003a70:	bb3fe0ef          	jal	80002622 <either_copyin>
    80003a74:	05850a63          	beq	a0,s8,80003ac8 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003a78:	8526                	mv	a0,s1
    80003a7a:	660000ef          	jal	800040da <log_write>
    brelse(bp);
    80003a7e:	8526                	mv	a0,s1
    80003a80:	e10ff0ef          	jal	80003090 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a84:	013d09bb          	addw	s3,s10,s3
    80003a88:	012d093b          	addw	s2,s10,s2
    80003a8c:	9a6e                	add	s4,s4,s11
    80003a8e:	0569f063          	bgeu	s3,s6,80003ace <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80003a92:	00a9559b          	srliw	a1,s2,0xa
    80003a96:	8556                	mv	a0,s5
    80003a98:	875ff0ef          	jal	8000330c <bmap>
    80003a9c:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003aa0:	c59d                	beqz	a1,80003ace <writei+0xbe>
    bp = bread(ip->dev, addr);
    80003aa2:	000aa503          	lw	a0,0(s5)
    80003aa6:	ce2ff0ef          	jal	80002f88 <bread>
    80003aaa:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003aac:	3ff97713          	andi	a4,s2,1023
    80003ab0:	40ec87bb          	subw	a5,s9,a4
    80003ab4:	413b06bb          	subw	a3,s6,s3
    80003ab8:	8d3e                	mv	s10,a5
    80003aba:	2781                	sext.w	a5,a5
    80003abc:	0006861b          	sext.w	a2,a3
    80003ac0:	f8f67ee3          	bgeu	a2,a5,80003a5c <writei+0x4c>
    80003ac4:	8d36                	mv	s10,a3
    80003ac6:	bf59                	j	80003a5c <writei+0x4c>
      brelse(bp);
    80003ac8:	8526                	mv	a0,s1
    80003aca:	dc6ff0ef          	jal	80003090 <brelse>
  }

  if(off > ip->size)
    80003ace:	04caa783          	lw	a5,76(s5)
    80003ad2:	0327fa63          	bgeu	a5,s2,80003b06 <writei+0xf6>
    ip->size = off;
    80003ad6:	052aa623          	sw	s2,76(s5)
    80003ada:	64e6                	ld	s1,88(sp)
    80003adc:	7c02                	ld	s8,32(sp)
    80003ade:	6ce2                	ld	s9,24(sp)
    80003ae0:	6d42                	ld	s10,16(sp)
    80003ae2:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003ae4:	8556                	mv	a0,s5
    80003ae6:	b27ff0ef          	jal	8000360c <iupdate>

  return tot;
    80003aea:	0009851b          	sext.w	a0,s3
    80003aee:	69a6                	ld	s3,72(sp)
}
    80003af0:	70a6                	ld	ra,104(sp)
    80003af2:	7406                	ld	s0,96(sp)
    80003af4:	6946                	ld	s2,80(sp)
    80003af6:	6a06                	ld	s4,64(sp)
    80003af8:	7ae2                	ld	s5,56(sp)
    80003afa:	7b42                	ld	s6,48(sp)
    80003afc:	7ba2                	ld	s7,40(sp)
    80003afe:	6165                	addi	sp,sp,112
    80003b00:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b02:	89da                	mv	s3,s6
    80003b04:	b7c5                	j	80003ae4 <writei+0xd4>
    80003b06:	64e6                	ld	s1,88(sp)
    80003b08:	7c02                	ld	s8,32(sp)
    80003b0a:	6ce2                	ld	s9,24(sp)
    80003b0c:	6d42                	ld	s10,16(sp)
    80003b0e:	6da2                	ld	s11,8(sp)
    80003b10:	bfd1                	j	80003ae4 <writei+0xd4>
    return -1;
    80003b12:	557d                	li	a0,-1
}
    80003b14:	8082                	ret
    return -1;
    80003b16:	557d                	li	a0,-1
    80003b18:	bfe1                	j	80003af0 <writei+0xe0>
    return -1;
    80003b1a:	557d                	li	a0,-1
    80003b1c:	bfd1                	j	80003af0 <writei+0xe0>

0000000080003b1e <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003b1e:	1141                	addi	sp,sp,-16
    80003b20:	e406                	sd	ra,8(sp)
    80003b22:	e022                	sd	s0,0(sp)
    80003b24:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003b26:	4639                	li	a2,14
    80003b28:	a6cfd0ef          	jal	80000d94 <strncmp>
}
    80003b2c:	60a2                	ld	ra,8(sp)
    80003b2e:	6402                	ld	s0,0(sp)
    80003b30:	0141                	addi	sp,sp,16
    80003b32:	8082                	ret

0000000080003b34 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003b34:	7139                	addi	sp,sp,-64
    80003b36:	fc06                	sd	ra,56(sp)
    80003b38:	f822                	sd	s0,48(sp)
    80003b3a:	f426                	sd	s1,40(sp)
    80003b3c:	f04a                	sd	s2,32(sp)
    80003b3e:	ec4e                	sd	s3,24(sp)
    80003b40:	e852                	sd	s4,16(sp)
    80003b42:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003b44:	04451703          	lh	a4,68(a0)
    80003b48:	4785                	li	a5,1
    80003b4a:	00f71a63          	bne	a4,a5,80003b5e <dirlookup+0x2a>
    80003b4e:	892a                	mv	s2,a0
    80003b50:	89ae                	mv	s3,a1
    80003b52:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b54:	457c                	lw	a5,76(a0)
    80003b56:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003b58:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b5a:	e39d                	bnez	a5,80003b80 <dirlookup+0x4c>
    80003b5c:	a095                	j	80003bc0 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80003b5e:	00004517          	auipc	a0,0x4
    80003b62:	b3250513          	addi	a0,a0,-1230 # 80007690 <etext+0x690>
    80003b66:	c2ffc0ef          	jal	80000794 <panic>
      panic("dirlookup read");
    80003b6a:	00004517          	auipc	a0,0x4
    80003b6e:	b3e50513          	addi	a0,a0,-1218 # 800076a8 <etext+0x6a8>
    80003b72:	c23fc0ef          	jal	80000794 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b76:	24c1                	addiw	s1,s1,16
    80003b78:	04c92783          	lw	a5,76(s2)
    80003b7c:	04f4f163          	bgeu	s1,a5,80003bbe <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b80:	4741                	li	a4,16
    80003b82:	86a6                	mv	a3,s1
    80003b84:	fc040613          	addi	a2,s0,-64
    80003b88:	4581                	li	a1,0
    80003b8a:	854a                	mv	a0,s2
    80003b8c:	d89ff0ef          	jal	80003914 <readi>
    80003b90:	47c1                	li	a5,16
    80003b92:	fcf51ce3          	bne	a0,a5,80003b6a <dirlookup+0x36>
    if(de.inum == 0)
    80003b96:	fc045783          	lhu	a5,-64(s0)
    80003b9a:	dff1                	beqz	a5,80003b76 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80003b9c:	fc240593          	addi	a1,s0,-62
    80003ba0:	854e                	mv	a0,s3
    80003ba2:	f7dff0ef          	jal	80003b1e <namecmp>
    80003ba6:	f961                	bnez	a0,80003b76 <dirlookup+0x42>
      if(poff)
    80003ba8:	000a0463          	beqz	s4,80003bb0 <dirlookup+0x7c>
        *poff = off;
    80003bac:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003bb0:	fc045583          	lhu	a1,-64(s0)
    80003bb4:	00092503          	lw	a0,0(s2)
    80003bb8:	829ff0ef          	jal	800033e0 <iget>
    80003bbc:	a011                	j	80003bc0 <dirlookup+0x8c>
  return 0;
    80003bbe:	4501                	li	a0,0
}
    80003bc0:	70e2                	ld	ra,56(sp)
    80003bc2:	7442                	ld	s0,48(sp)
    80003bc4:	74a2                	ld	s1,40(sp)
    80003bc6:	7902                	ld	s2,32(sp)
    80003bc8:	69e2                	ld	s3,24(sp)
    80003bca:	6a42                	ld	s4,16(sp)
    80003bcc:	6121                	addi	sp,sp,64
    80003bce:	8082                	ret

0000000080003bd0 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003bd0:	711d                	addi	sp,sp,-96
    80003bd2:	ec86                	sd	ra,88(sp)
    80003bd4:	e8a2                	sd	s0,80(sp)
    80003bd6:	e4a6                	sd	s1,72(sp)
    80003bd8:	e0ca                	sd	s2,64(sp)
    80003bda:	fc4e                	sd	s3,56(sp)
    80003bdc:	f852                	sd	s4,48(sp)
    80003bde:	f456                	sd	s5,40(sp)
    80003be0:	f05a                	sd	s6,32(sp)
    80003be2:	ec5e                	sd	s7,24(sp)
    80003be4:	e862                	sd	s8,16(sp)
    80003be6:	e466                	sd	s9,8(sp)
    80003be8:	1080                	addi	s0,sp,96
    80003bea:	84aa                	mv	s1,a0
    80003bec:	8b2e                	mv	s6,a1
    80003bee:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003bf0:	00054703          	lbu	a4,0(a0)
    80003bf4:	02f00793          	li	a5,47
    80003bf8:	00f70e63          	beq	a4,a5,80003c14 <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003bfc:	d07fd0ef          	jal	80001902 <myproc>
    80003c00:	15053503          	ld	a0,336(a0)
    80003c04:	a87ff0ef          	jal	8000368a <idup>
    80003c08:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003c0a:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003c0e:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003c10:	4b85                	li	s7,1
    80003c12:	a871                	j	80003cae <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    80003c14:	4585                	li	a1,1
    80003c16:	4505                	li	a0,1
    80003c18:	fc8ff0ef          	jal	800033e0 <iget>
    80003c1c:	8a2a                	mv	s4,a0
    80003c1e:	b7f5                	j	80003c0a <namex+0x3a>
      iunlockput(ip);
    80003c20:	8552                	mv	a0,s4
    80003c22:	ca9ff0ef          	jal	800038ca <iunlockput>
      return 0;
    80003c26:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003c28:	8552                	mv	a0,s4
    80003c2a:	60e6                	ld	ra,88(sp)
    80003c2c:	6446                	ld	s0,80(sp)
    80003c2e:	64a6                	ld	s1,72(sp)
    80003c30:	6906                	ld	s2,64(sp)
    80003c32:	79e2                	ld	s3,56(sp)
    80003c34:	7a42                	ld	s4,48(sp)
    80003c36:	7aa2                	ld	s5,40(sp)
    80003c38:	7b02                	ld	s6,32(sp)
    80003c3a:	6be2                	ld	s7,24(sp)
    80003c3c:	6c42                	ld	s8,16(sp)
    80003c3e:	6ca2                	ld	s9,8(sp)
    80003c40:	6125                	addi	sp,sp,96
    80003c42:	8082                	ret
      iunlock(ip);
    80003c44:	8552                	mv	a0,s4
    80003c46:	b29ff0ef          	jal	8000376e <iunlock>
      return ip;
    80003c4a:	bff9                	j	80003c28 <namex+0x58>
      iunlockput(ip);
    80003c4c:	8552                	mv	a0,s4
    80003c4e:	c7dff0ef          	jal	800038ca <iunlockput>
      return 0;
    80003c52:	8a4e                	mv	s4,s3
    80003c54:	bfd1                	j	80003c28 <namex+0x58>
  len = path - s;
    80003c56:	40998633          	sub	a2,s3,s1
    80003c5a:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003c5e:	099c5063          	bge	s8,s9,80003cde <namex+0x10e>
    memmove(name, s, DIRSIZ);
    80003c62:	4639                	li	a2,14
    80003c64:	85a6                	mv	a1,s1
    80003c66:	8556                	mv	a0,s5
    80003c68:	8bcfd0ef          	jal	80000d24 <memmove>
    80003c6c:	84ce                	mv	s1,s3
  while(*path == '/')
    80003c6e:	0004c783          	lbu	a5,0(s1)
    80003c72:	01279763          	bne	a5,s2,80003c80 <namex+0xb0>
    path++;
    80003c76:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003c78:	0004c783          	lbu	a5,0(s1)
    80003c7c:	ff278de3          	beq	a5,s2,80003c76 <namex+0xa6>
    ilock(ip);
    80003c80:	8552                	mv	a0,s4
    80003c82:	a3fff0ef          	jal	800036c0 <ilock>
    if(ip->type != T_DIR){
    80003c86:	044a1783          	lh	a5,68(s4)
    80003c8a:	f9779be3          	bne	a5,s7,80003c20 <namex+0x50>
    if(nameiparent && *path == '\0'){
    80003c8e:	000b0563          	beqz	s6,80003c98 <namex+0xc8>
    80003c92:	0004c783          	lbu	a5,0(s1)
    80003c96:	d7dd                	beqz	a5,80003c44 <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003c98:	4601                	li	a2,0
    80003c9a:	85d6                	mv	a1,s5
    80003c9c:	8552                	mv	a0,s4
    80003c9e:	e97ff0ef          	jal	80003b34 <dirlookup>
    80003ca2:	89aa                	mv	s3,a0
    80003ca4:	d545                	beqz	a0,80003c4c <namex+0x7c>
    iunlockput(ip);
    80003ca6:	8552                	mv	a0,s4
    80003ca8:	c23ff0ef          	jal	800038ca <iunlockput>
    ip = next;
    80003cac:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003cae:	0004c783          	lbu	a5,0(s1)
    80003cb2:	01279763          	bne	a5,s2,80003cc0 <namex+0xf0>
    path++;
    80003cb6:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003cb8:	0004c783          	lbu	a5,0(s1)
    80003cbc:	ff278de3          	beq	a5,s2,80003cb6 <namex+0xe6>
  if(*path == 0)
    80003cc0:	cb8d                	beqz	a5,80003cf2 <namex+0x122>
  while(*path != '/' && *path != 0)
    80003cc2:	0004c783          	lbu	a5,0(s1)
    80003cc6:	89a6                	mv	s3,s1
  len = path - s;
    80003cc8:	4c81                	li	s9,0
    80003cca:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003ccc:	01278963          	beq	a5,s2,80003cde <namex+0x10e>
    80003cd0:	d3d9                	beqz	a5,80003c56 <namex+0x86>
    path++;
    80003cd2:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003cd4:	0009c783          	lbu	a5,0(s3)
    80003cd8:	ff279ce3          	bne	a5,s2,80003cd0 <namex+0x100>
    80003cdc:	bfad                	j	80003c56 <namex+0x86>
    memmove(name, s, len);
    80003cde:	2601                	sext.w	a2,a2
    80003ce0:	85a6                	mv	a1,s1
    80003ce2:	8556                	mv	a0,s5
    80003ce4:	840fd0ef          	jal	80000d24 <memmove>
    name[len] = 0;
    80003ce8:	9cd6                	add	s9,s9,s5
    80003cea:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003cee:	84ce                	mv	s1,s3
    80003cf0:	bfbd                	j	80003c6e <namex+0x9e>
  if(nameiparent){
    80003cf2:	f20b0be3          	beqz	s6,80003c28 <namex+0x58>
    iput(ip);
    80003cf6:	8552                	mv	a0,s4
    80003cf8:	b4bff0ef          	jal	80003842 <iput>
    return 0;
    80003cfc:	4a01                	li	s4,0
    80003cfe:	b72d                	j	80003c28 <namex+0x58>

0000000080003d00 <dirlink>:
{
    80003d00:	7139                	addi	sp,sp,-64
    80003d02:	fc06                	sd	ra,56(sp)
    80003d04:	f822                	sd	s0,48(sp)
    80003d06:	f04a                	sd	s2,32(sp)
    80003d08:	ec4e                	sd	s3,24(sp)
    80003d0a:	e852                	sd	s4,16(sp)
    80003d0c:	0080                	addi	s0,sp,64
    80003d0e:	892a                	mv	s2,a0
    80003d10:	8a2e                	mv	s4,a1
    80003d12:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003d14:	4601                	li	a2,0
    80003d16:	e1fff0ef          	jal	80003b34 <dirlookup>
    80003d1a:	e535                	bnez	a0,80003d86 <dirlink+0x86>
    80003d1c:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d1e:	04c92483          	lw	s1,76(s2)
    80003d22:	c48d                	beqz	s1,80003d4c <dirlink+0x4c>
    80003d24:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d26:	4741                	li	a4,16
    80003d28:	86a6                	mv	a3,s1
    80003d2a:	fc040613          	addi	a2,s0,-64
    80003d2e:	4581                	li	a1,0
    80003d30:	854a                	mv	a0,s2
    80003d32:	be3ff0ef          	jal	80003914 <readi>
    80003d36:	47c1                	li	a5,16
    80003d38:	04f51b63          	bne	a0,a5,80003d8e <dirlink+0x8e>
    if(de.inum == 0)
    80003d3c:	fc045783          	lhu	a5,-64(s0)
    80003d40:	c791                	beqz	a5,80003d4c <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d42:	24c1                	addiw	s1,s1,16
    80003d44:	04c92783          	lw	a5,76(s2)
    80003d48:	fcf4efe3          	bltu	s1,a5,80003d26 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003d4c:	4639                	li	a2,14
    80003d4e:	85d2                	mv	a1,s4
    80003d50:	fc240513          	addi	a0,s0,-62
    80003d54:	876fd0ef          	jal	80000dca <strncpy>
  de.inum = inum;
    80003d58:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d5c:	4741                	li	a4,16
    80003d5e:	86a6                	mv	a3,s1
    80003d60:	fc040613          	addi	a2,s0,-64
    80003d64:	4581                	li	a1,0
    80003d66:	854a                	mv	a0,s2
    80003d68:	ca9ff0ef          	jal	80003a10 <writei>
    80003d6c:	1541                	addi	a0,a0,-16
    80003d6e:	00a03533          	snez	a0,a0
    80003d72:	40a00533          	neg	a0,a0
    80003d76:	74a2                	ld	s1,40(sp)
}
    80003d78:	70e2                	ld	ra,56(sp)
    80003d7a:	7442                	ld	s0,48(sp)
    80003d7c:	7902                	ld	s2,32(sp)
    80003d7e:	69e2                	ld	s3,24(sp)
    80003d80:	6a42                	ld	s4,16(sp)
    80003d82:	6121                	addi	sp,sp,64
    80003d84:	8082                	ret
    iput(ip);
    80003d86:	abdff0ef          	jal	80003842 <iput>
    return -1;
    80003d8a:	557d                	li	a0,-1
    80003d8c:	b7f5                	j	80003d78 <dirlink+0x78>
      panic("dirlink read");
    80003d8e:	00004517          	auipc	a0,0x4
    80003d92:	92a50513          	addi	a0,a0,-1750 # 800076b8 <etext+0x6b8>
    80003d96:	9fffc0ef          	jal	80000794 <panic>

0000000080003d9a <namei>:

struct inode*
namei(char *path)
{
    80003d9a:	1101                	addi	sp,sp,-32
    80003d9c:	ec06                	sd	ra,24(sp)
    80003d9e:	e822                	sd	s0,16(sp)
    80003da0:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003da2:	fe040613          	addi	a2,s0,-32
    80003da6:	4581                	li	a1,0
    80003da8:	e29ff0ef          	jal	80003bd0 <namex>
}
    80003dac:	60e2                	ld	ra,24(sp)
    80003dae:	6442                	ld	s0,16(sp)
    80003db0:	6105                	addi	sp,sp,32
    80003db2:	8082                	ret

0000000080003db4 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003db4:	1141                	addi	sp,sp,-16
    80003db6:	e406                	sd	ra,8(sp)
    80003db8:	e022                	sd	s0,0(sp)
    80003dba:	0800                	addi	s0,sp,16
    80003dbc:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003dbe:	4585                	li	a1,1
    80003dc0:	e11ff0ef          	jal	80003bd0 <namex>
}
    80003dc4:	60a2                	ld	ra,8(sp)
    80003dc6:	6402                	ld	s0,0(sp)
    80003dc8:	0141                	addi	sp,sp,16
    80003dca:	8082                	ret

0000000080003dcc <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003dcc:	1101                	addi	sp,sp,-32
    80003dce:	ec06                	sd	ra,24(sp)
    80003dd0:	e822                	sd	s0,16(sp)
    80003dd2:	e426                	sd	s1,8(sp)
    80003dd4:	e04a                	sd	s2,0(sp)
    80003dd6:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003dd8:	0001e917          	auipc	s2,0x1e
    80003ddc:	ff890913          	addi	s2,s2,-8 # 80021dd0 <log>
    80003de0:	01892583          	lw	a1,24(s2)
    80003de4:	02892503          	lw	a0,40(s2)
    80003de8:	9a0ff0ef          	jal	80002f88 <bread>
    80003dec:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003dee:	02c92603          	lw	a2,44(s2)
    80003df2:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003df4:	00c05f63          	blez	a2,80003e12 <write_head+0x46>
    80003df8:	0001e717          	auipc	a4,0x1e
    80003dfc:	00870713          	addi	a4,a4,8 # 80021e00 <log+0x30>
    80003e00:	87aa                	mv	a5,a0
    80003e02:	060a                	slli	a2,a2,0x2
    80003e04:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003e06:	4314                	lw	a3,0(a4)
    80003e08:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003e0a:	0711                	addi	a4,a4,4
    80003e0c:	0791                	addi	a5,a5,4
    80003e0e:	fec79ce3          	bne	a5,a2,80003e06 <write_head+0x3a>
  }
  bwrite(buf);
    80003e12:	8526                	mv	a0,s1
    80003e14:	a4aff0ef          	jal	8000305e <bwrite>
  brelse(buf);
    80003e18:	8526                	mv	a0,s1
    80003e1a:	a76ff0ef          	jal	80003090 <brelse>
}
    80003e1e:	60e2                	ld	ra,24(sp)
    80003e20:	6442                	ld	s0,16(sp)
    80003e22:	64a2                	ld	s1,8(sp)
    80003e24:	6902                	ld	s2,0(sp)
    80003e26:	6105                	addi	sp,sp,32
    80003e28:	8082                	ret

0000000080003e2a <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e2a:	0001e797          	auipc	a5,0x1e
    80003e2e:	fd27a783          	lw	a5,-46(a5) # 80021dfc <log+0x2c>
    80003e32:	08f05f63          	blez	a5,80003ed0 <install_trans+0xa6>
{
    80003e36:	7139                	addi	sp,sp,-64
    80003e38:	fc06                	sd	ra,56(sp)
    80003e3a:	f822                	sd	s0,48(sp)
    80003e3c:	f426                	sd	s1,40(sp)
    80003e3e:	f04a                	sd	s2,32(sp)
    80003e40:	ec4e                	sd	s3,24(sp)
    80003e42:	e852                	sd	s4,16(sp)
    80003e44:	e456                	sd	s5,8(sp)
    80003e46:	e05a                	sd	s6,0(sp)
    80003e48:	0080                	addi	s0,sp,64
    80003e4a:	8b2a                	mv	s6,a0
    80003e4c:	0001ea97          	auipc	s5,0x1e
    80003e50:	fb4a8a93          	addi	s5,s5,-76 # 80021e00 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e54:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003e56:	0001e997          	auipc	s3,0x1e
    80003e5a:	f7a98993          	addi	s3,s3,-134 # 80021dd0 <log>
    80003e5e:	a829                	j	80003e78 <install_trans+0x4e>
    brelse(lbuf);
    80003e60:	854a                	mv	a0,s2
    80003e62:	a2eff0ef          	jal	80003090 <brelse>
    brelse(dbuf);
    80003e66:	8526                	mv	a0,s1
    80003e68:	a28ff0ef          	jal	80003090 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e6c:	2a05                	addiw	s4,s4,1
    80003e6e:	0a91                	addi	s5,s5,4
    80003e70:	02c9a783          	lw	a5,44(s3)
    80003e74:	04fa5463          	bge	s4,a5,80003ebc <install_trans+0x92>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003e78:	0189a583          	lw	a1,24(s3)
    80003e7c:	014585bb          	addw	a1,a1,s4
    80003e80:	2585                	addiw	a1,a1,1
    80003e82:	0289a503          	lw	a0,40(s3)
    80003e86:	902ff0ef          	jal	80002f88 <bread>
    80003e8a:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003e8c:	000aa583          	lw	a1,0(s5)
    80003e90:	0289a503          	lw	a0,40(s3)
    80003e94:	8f4ff0ef          	jal	80002f88 <bread>
    80003e98:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003e9a:	40000613          	li	a2,1024
    80003e9e:	05890593          	addi	a1,s2,88
    80003ea2:	05850513          	addi	a0,a0,88
    80003ea6:	e7ffc0ef          	jal	80000d24 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003eaa:	8526                	mv	a0,s1
    80003eac:	9b2ff0ef          	jal	8000305e <bwrite>
    if(recovering == 0)
    80003eb0:	fa0b18e3          	bnez	s6,80003e60 <install_trans+0x36>
      bunpin(dbuf);
    80003eb4:	8526                	mv	a0,s1
    80003eb6:	a96ff0ef          	jal	8000314c <bunpin>
    80003eba:	b75d                	j	80003e60 <install_trans+0x36>
}
    80003ebc:	70e2                	ld	ra,56(sp)
    80003ebe:	7442                	ld	s0,48(sp)
    80003ec0:	74a2                	ld	s1,40(sp)
    80003ec2:	7902                	ld	s2,32(sp)
    80003ec4:	69e2                	ld	s3,24(sp)
    80003ec6:	6a42                	ld	s4,16(sp)
    80003ec8:	6aa2                	ld	s5,8(sp)
    80003eca:	6b02                	ld	s6,0(sp)
    80003ecc:	6121                	addi	sp,sp,64
    80003ece:	8082                	ret
    80003ed0:	8082                	ret

0000000080003ed2 <initlog>:
{
    80003ed2:	7179                	addi	sp,sp,-48
    80003ed4:	f406                	sd	ra,40(sp)
    80003ed6:	f022                	sd	s0,32(sp)
    80003ed8:	ec26                	sd	s1,24(sp)
    80003eda:	e84a                	sd	s2,16(sp)
    80003edc:	e44e                	sd	s3,8(sp)
    80003ede:	1800                	addi	s0,sp,48
    80003ee0:	892a                	mv	s2,a0
    80003ee2:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003ee4:	0001e497          	auipc	s1,0x1e
    80003ee8:	eec48493          	addi	s1,s1,-276 # 80021dd0 <log>
    80003eec:	00003597          	auipc	a1,0x3
    80003ef0:	7dc58593          	addi	a1,a1,2012 # 800076c8 <etext+0x6c8>
    80003ef4:	8526                	mv	a0,s1
    80003ef6:	c7ffc0ef          	jal	80000b74 <initlock>
  log.start = sb->logstart;
    80003efa:	0149a583          	lw	a1,20(s3)
    80003efe:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003f00:	0109a783          	lw	a5,16(s3)
    80003f04:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003f06:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003f0a:	854a                	mv	a0,s2
    80003f0c:	87cff0ef          	jal	80002f88 <bread>
  log.lh.n = lh->n;
    80003f10:	4d30                	lw	a2,88(a0)
    80003f12:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003f14:	00c05f63          	blez	a2,80003f32 <initlog+0x60>
    80003f18:	87aa                	mv	a5,a0
    80003f1a:	0001e717          	auipc	a4,0x1e
    80003f1e:	ee670713          	addi	a4,a4,-282 # 80021e00 <log+0x30>
    80003f22:	060a                	slli	a2,a2,0x2
    80003f24:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003f26:	4ff4                	lw	a3,92(a5)
    80003f28:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003f2a:	0791                	addi	a5,a5,4
    80003f2c:	0711                	addi	a4,a4,4
    80003f2e:	fec79ce3          	bne	a5,a2,80003f26 <initlog+0x54>
  brelse(buf);
    80003f32:	95eff0ef          	jal	80003090 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003f36:	4505                	li	a0,1
    80003f38:	ef3ff0ef          	jal	80003e2a <install_trans>
  log.lh.n = 0;
    80003f3c:	0001e797          	auipc	a5,0x1e
    80003f40:	ec07a023          	sw	zero,-320(a5) # 80021dfc <log+0x2c>
  write_head(); // clear the log
    80003f44:	e89ff0ef          	jal	80003dcc <write_head>
}
    80003f48:	70a2                	ld	ra,40(sp)
    80003f4a:	7402                	ld	s0,32(sp)
    80003f4c:	64e2                	ld	s1,24(sp)
    80003f4e:	6942                	ld	s2,16(sp)
    80003f50:	69a2                	ld	s3,8(sp)
    80003f52:	6145                	addi	sp,sp,48
    80003f54:	8082                	ret

0000000080003f56 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003f56:	1101                	addi	sp,sp,-32
    80003f58:	ec06                	sd	ra,24(sp)
    80003f5a:	e822                	sd	s0,16(sp)
    80003f5c:	e426                	sd	s1,8(sp)
    80003f5e:	e04a                	sd	s2,0(sp)
    80003f60:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003f62:	0001e517          	auipc	a0,0x1e
    80003f66:	e6e50513          	addi	a0,a0,-402 # 80021dd0 <log>
    80003f6a:	c8bfc0ef          	jal	80000bf4 <acquire>
  while(1){
    if(log.committing){
    80003f6e:	0001e497          	auipc	s1,0x1e
    80003f72:	e6248493          	addi	s1,s1,-414 # 80021dd0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003f76:	4979                	li	s2,30
    80003f78:	a029                	j	80003f82 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003f7a:	85a6                	mv	a1,s1
    80003f7c:	8526                	mv	a0,s1
    80003f7e:	a98fe0ef          	jal	80002216 <sleep>
    if(log.committing){
    80003f82:	50dc                	lw	a5,36(s1)
    80003f84:	fbfd                	bnez	a5,80003f7a <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003f86:	5098                	lw	a4,32(s1)
    80003f88:	2705                	addiw	a4,a4,1
    80003f8a:	0027179b          	slliw	a5,a4,0x2
    80003f8e:	9fb9                	addw	a5,a5,a4
    80003f90:	0017979b          	slliw	a5,a5,0x1
    80003f94:	54d4                	lw	a3,44(s1)
    80003f96:	9fb5                	addw	a5,a5,a3
    80003f98:	00f95763          	bge	s2,a5,80003fa6 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003f9c:	85a6                	mv	a1,s1
    80003f9e:	8526                	mv	a0,s1
    80003fa0:	a76fe0ef          	jal	80002216 <sleep>
    80003fa4:	bff9                	j	80003f82 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003fa6:	0001e517          	auipc	a0,0x1e
    80003faa:	e2a50513          	addi	a0,a0,-470 # 80021dd0 <log>
    80003fae:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80003fb0:	cddfc0ef          	jal	80000c8c <release>
      break;
    }
  }
}
    80003fb4:	60e2                	ld	ra,24(sp)
    80003fb6:	6442                	ld	s0,16(sp)
    80003fb8:	64a2                	ld	s1,8(sp)
    80003fba:	6902                	ld	s2,0(sp)
    80003fbc:	6105                	addi	sp,sp,32
    80003fbe:	8082                	ret

0000000080003fc0 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003fc0:	7139                	addi	sp,sp,-64
    80003fc2:	fc06                	sd	ra,56(sp)
    80003fc4:	f822                	sd	s0,48(sp)
    80003fc6:	f426                	sd	s1,40(sp)
    80003fc8:	f04a                	sd	s2,32(sp)
    80003fca:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003fcc:	0001e497          	auipc	s1,0x1e
    80003fd0:	e0448493          	addi	s1,s1,-508 # 80021dd0 <log>
    80003fd4:	8526                	mv	a0,s1
    80003fd6:	c1ffc0ef          	jal	80000bf4 <acquire>
  log.outstanding -= 1;
    80003fda:	509c                	lw	a5,32(s1)
    80003fdc:	37fd                	addiw	a5,a5,-1
    80003fde:	0007891b          	sext.w	s2,a5
    80003fe2:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80003fe4:	50dc                	lw	a5,36(s1)
    80003fe6:	ef9d                	bnez	a5,80004024 <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80003fe8:	04091763          	bnez	s2,80004036 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003fec:	0001e497          	auipc	s1,0x1e
    80003ff0:	de448493          	addi	s1,s1,-540 # 80021dd0 <log>
    80003ff4:	4785                	li	a5,1
    80003ff6:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003ff8:	8526                	mv	a0,s1
    80003ffa:	c93fc0ef          	jal	80000c8c <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003ffe:	54dc                	lw	a5,44(s1)
    80004000:	04f04b63          	bgtz	a5,80004056 <end_op+0x96>
    acquire(&log.lock);
    80004004:	0001e497          	auipc	s1,0x1e
    80004008:	dcc48493          	addi	s1,s1,-564 # 80021dd0 <log>
    8000400c:	8526                	mv	a0,s1
    8000400e:	be7fc0ef          	jal	80000bf4 <acquire>
    log.committing = 0;
    80004012:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004016:	8526                	mv	a0,s1
    80004018:	a4afe0ef          	jal	80002262 <wakeup>
    release(&log.lock);
    8000401c:	8526                	mv	a0,s1
    8000401e:	c6ffc0ef          	jal	80000c8c <release>
}
    80004022:	a025                	j	8000404a <end_op+0x8a>
    80004024:	ec4e                	sd	s3,24(sp)
    80004026:	e852                	sd	s4,16(sp)
    80004028:	e456                	sd	s5,8(sp)
    panic("log.committing");
    8000402a:	00003517          	auipc	a0,0x3
    8000402e:	6a650513          	addi	a0,a0,1702 # 800076d0 <etext+0x6d0>
    80004032:	f62fc0ef          	jal	80000794 <panic>
    wakeup(&log);
    80004036:	0001e497          	auipc	s1,0x1e
    8000403a:	d9a48493          	addi	s1,s1,-614 # 80021dd0 <log>
    8000403e:	8526                	mv	a0,s1
    80004040:	a22fe0ef          	jal	80002262 <wakeup>
  release(&log.lock);
    80004044:	8526                	mv	a0,s1
    80004046:	c47fc0ef          	jal	80000c8c <release>
}
    8000404a:	70e2                	ld	ra,56(sp)
    8000404c:	7442                	ld	s0,48(sp)
    8000404e:	74a2                	ld	s1,40(sp)
    80004050:	7902                	ld	s2,32(sp)
    80004052:	6121                	addi	sp,sp,64
    80004054:	8082                	ret
    80004056:	ec4e                	sd	s3,24(sp)
    80004058:	e852                	sd	s4,16(sp)
    8000405a:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    8000405c:	0001ea97          	auipc	s5,0x1e
    80004060:	da4a8a93          	addi	s5,s5,-604 # 80021e00 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004064:	0001ea17          	auipc	s4,0x1e
    80004068:	d6ca0a13          	addi	s4,s4,-660 # 80021dd0 <log>
    8000406c:	018a2583          	lw	a1,24(s4)
    80004070:	012585bb          	addw	a1,a1,s2
    80004074:	2585                	addiw	a1,a1,1
    80004076:	028a2503          	lw	a0,40(s4)
    8000407a:	f0ffe0ef          	jal	80002f88 <bread>
    8000407e:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004080:	000aa583          	lw	a1,0(s5)
    80004084:	028a2503          	lw	a0,40(s4)
    80004088:	f01fe0ef          	jal	80002f88 <bread>
    8000408c:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000408e:	40000613          	li	a2,1024
    80004092:	05850593          	addi	a1,a0,88
    80004096:	05848513          	addi	a0,s1,88
    8000409a:	c8bfc0ef          	jal	80000d24 <memmove>
    bwrite(to);  // write the log
    8000409e:	8526                	mv	a0,s1
    800040a0:	fbffe0ef          	jal	8000305e <bwrite>
    brelse(from);
    800040a4:	854e                	mv	a0,s3
    800040a6:	febfe0ef          	jal	80003090 <brelse>
    brelse(to);
    800040aa:	8526                	mv	a0,s1
    800040ac:	fe5fe0ef          	jal	80003090 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800040b0:	2905                	addiw	s2,s2,1
    800040b2:	0a91                	addi	s5,s5,4
    800040b4:	02ca2783          	lw	a5,44(s4)
    800040b8:	faf94ae3          	blt	s2,a5,8000406c <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800040bc:	d11ff0ef          	jal	80003dcc <write_head>
    install_trans(0); // Now install writes to home locations
    800040c0:	4501                	li	a0,0
    800040c2:	d69ff0ef          	jal	80003e2a <install_trans>
    log.lh.n = 0;
    800040c6:	0001e797          	auipc	a5,0x1e
    800040ca:	d207ab23          	sw	zero,-714(a5) # 80021dfc <log+0x2c>
    write_head();    // Erase the transaction from the log
    800040ce:	cffff0ef          	jal	80003dcc <write_head>
    800040d2:	69e2                	ld	s3,24(sp)
    800040d4:	6a42                	ld	s4,16(sp)
    800040d6:	6aa2                	ld	s5,8(sp)
    800040d8:	b735                	j	80004004 <end_op+0x44>

00000000800040da <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800040da:	1101                	addi	sp,sp,-32
    800040dc:	ec06                	sd	ra,24(sp)
    800040de:	e822                	sd	s0,16(sp)
    800040e0:	e426                	sd	s1,8(sp)
    800040e2:	e04a                	sd	s2,0(sp)
    800040e4:	1000                	addi	s0,sp,32
    800040e6:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800040e8:	0001e917          	auipc	s2,0x1e
    800040ec:	ce890913          	addi	s2,s2,-792 # 80021dd0 <log>
    800040f0:	854a                	mv	a0,s2
    800040f2:	b03fc0ef          	jal	80000bf4 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800040f6:	02c92603          	lw	a2,44(s2)
    800040fa:	47f5                	li	a5,29
    800040fc:	06c7c363          	blt	a5,a2,80004162 <log_write+0x88>
    80004100:	0001e797          	auipc	a5,0x1e
    80004104:	cec7a783          	lw	a5,-788(a5) # 80021dec <log+0x1c>
    80004108:	37fd                	addiw	a5,a5,-1
    8000410a:	04f65c63          	bge	a2,a5,80004162 <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000410e:	0001e797          	auipc	a5,0x1e
    80004112:	ce27a783          	lw	a5,-798(a5) # 80021df0 <log+0x20>
    80004116:	04f05c63          	blez	a5,8000416e <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000411a:	4781                	li	a5,0
    8000411c:	04c05f63          	blez	a2,8000417a <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004120:	44cc                	lw	a1,12(s1)
    80004122:	0001e717          	auipc	a4,0x1e
    80004126:	cde70713          	addi	a4,a4,-802 # 80021e00 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000412a:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000412c:	4314                	lw	a3,0(a4)
    8000412e:	04b68663          	beq	a3,a1,8000417a <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    80004132:	2785                	addiw	a5,a5,1
    80004134:	0711                	addi	a4,a4,4
    80004136:	fef61be3          	bne	a2,a5,8000412c <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000413a:	0621                	addi	a2,a2,8
    8000413c:	060a                	slli	a2,a2,0x2
    8000413e:	0001e797          	auipc	a5,0x1e
    80004142:	c9278793          	addi	a5,a5,-878 # 80021dd0 <log>
    80004146:	97b2                	add	a5,a5,a2
    80004148:	44d8                	lw	a4,12(s1)
    8000414a:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000414c:	8526                	mv	a0,s1
    8000414e:	fcbfe0ef          	jal	80003118 <bpin>
    log.lh.n++;
    80004152:	0001e717          	auipc	a4,0x1e
    80004156:	c7e70713          	addi	a4,a4,-898 # 80021dd0 <log>
    8000415a:	575c                	lw	a5,44(a4)
    8000415c:	2785                	addiw	a5,a5,1
    8000415e:	d75c                	sw	a5,44(a4)
    80004160:	a80d                	j	80004192 <log_write+0xb8>
    panic("too big a transaction");
    80004162:	00003517          	auipc	a0,0x3
    80004166:	57e50513          	addi	a0,a0,1406 # 800076e0 <etext+0x6e0>
    8000416a:	e2afc0ef          	jal	80000794 <panic>
    panic("log_write outside of trans");
    8000416e:	00003517          	auipc	a0,0x3
    80004172:	58a50513          	addi	a0,a0,1418 # 800076f8 <etext+0x6f8>
    80004176:	e1efc0ef          	jal	80000794 <panic>
  log.lh.block[i] = b->blockno;
    8000417a:	00878693          	addi	a3,a5,8
    8000417e:	068a                	slli	a3,a3,0x2
    80004180:	0001e717          	auipc	a4,0x1e
    80004184:	c5070713          	addi	a4,a4,-944 # 80021dd0 <log>
    80004188:	9736                	add	a4,a4,a3
    8000418a:	44d4                	lw	a3,12(s1)
    8000418c:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000418e:	faf60fe3          	beq	a2,a5,8000414c <log_write+0x72>
  }
  release(&log.lock);
    80004192:	0001e517          	auipc	a0,0x1e
    80004196:	c3e50513          	addi	a0,a0,-962 # 80021dd0 <log>
    8000419a:	af3fc0ef          	jal	80000c8c <release>
}
    8000419e:	60e2                	ld	ra,24(sp)
    800041a0:	6442                	ld	s0,16(sp)
    800041a2:	64a2                	ld	s1,8(sp)
    800041a4:	6902                	ld	s2,0(sp)
    800041a6:	6105                	addi	sp,sp,32
    800041a8:	8082                	ret

00000000800041aa <log_message>:
#include "riscv.h"
#include "defs.h"
#include "custom_logger.h"

// Implementing the logger function
void log_message(enum log_level level, const char *message) {
    800041aa:	1141                	addi	sp,sp,-16
    800041ac:	e406                	sd	ra,8(sp)
    800041ae:	e022                	sd	s0,0(sp)
    800041b0:	0800                	addi	s0,sp,16
    // Based on the log level, we print the appropriate prefix.
    switch (level) {
    800041b2:	4785                	li	a5,1
    800041b4:	02f50063          	beq	a0,a5,800041d4 <log_message+0x2a>
    800041b8:	4789                	li	a5,2
    800041ba:	02f50463          	beq	a0,a5,800041e2 <log_message+0x38>
    800041be:	e90d                	bnez	a0,800041f0 <log_message+0x46>
        case INFO:
            printf("[INFO] %s\n", message);
    800041c0:	00003517          	auipc	a0,0x3
    800041c4:	55850513          	addi	a0,a0,1368 # 80007718 <etext+0x718>
    800041c8:	afafc0ef          	jal	800004c2 <printf>
            break;
        default:
            printf("[UNKNOWN] %s\n", message); // For possible error
            break;
    }
    800041cc:	60a2                	ld	ra,8(sp)
    800041ce:	6402                	ld	s0,0(sp)
    800041d0:	0141                	addi	sp,sp,16
    800041d2:	8082                	ret
            printf("[WARN] %s\n", message);
    800041d4:	00003517          	auipc	a0,0x3
    800041d8:	55450513          	addi	a0,a0,1364 # 80007728 <etext+0x728>
    800041dc:	ae6fc0ef          	jal	800004c2 <printf>
            break;
    800041e0:	b7f5                	j	800041cc <log_message+0x22>
            printf("[ERROR] %s\n", message);
    800041e2:	00003517          	auipc	a0,0x3
    800041e6:	55650513          	addi	a0,a0,1366 # 80007738 <etext+0x738>
    800041ea:	ad8fc0ef          	jal	800004c2 <printf>
            break;
    800041ee:	bff9                	j	800041cc <log_message+0x22>
            printf("[UNKNOWN] %s\n", message); // For possible error
    800041f0:	00003517          	auipc	a0,0x3
    800041f4:	55850513          	addi	a0,a0,1368 # 80007748 <etext+0x748>
    800041f8:	acafc0ef          	jal	800004c2 <printf>
    800041fc:	bfc1                	j	800041cc <log_message+0x22>

00000000800041fe <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800041fe:	1101                	addi	sp,sp,-32
    80004200:	ec06                	sd	ra,24(sp)
    80004202:	e822                	sd	s0,16(sp)
    80004204:	e426                	sd	s1,8(sp)
    80004206:	e04a                	sd	s2,0(sp)
    80004208:	1000                	addi	s0,sp,32
    8000420a:	84aa                	mv	s1,a0
    8000420c:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000420e:	00003597          	auipc	a1,0x3
    80004212:	54a58593          	addi	a1,a1,1354 # 80007758 <etext+0x758>
    80004216:	0521                	addi	a0,a0,8
    80004218:	95dfc0ef          	jal	80000b74 <initlock>
  lk->name = name;
    8000421c:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004220:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004224:	0204a423          	sw	zero,40(s1)
}
    80004228:	60e2                	ld	ra,24(sp)
    8000422a:	6442                	ld	s0,16(sp)
    8000422c:	64a2                	ld	s1,8(sp)
    8000422e:	6902                	ld	s2,0(sp)
    80004230:	6105                	addi	sp,sp,32
    80004232:	8082                	ret

0000000080004234 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004234:	1101                	addi	sp,sp,-32
    80004236:	ec06                	sd	ra,24(sp)
    80004238:	e822                	sd	s0,16(sp)
    8000423a:	e426                	sd	s1,8(sp)
    8000423c:	e04a                	sd	s2,0(sp)
    8000423e:	1000                	addi	s0,sp,32
    80004240:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004242:	00850913          	addi	s2,a0,8
    80004246:	854a                	mv	a0,s2
    80004248:	9adfc0ef          	jal	80000bf4 <acquire>
  while (lk->locked) {
    8000424c:	409c                	lw	a5,0(s1)
    8000424e:	c799                	beqz	a5,8000425c <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80004250:	85ca                	mv	a1,s2
    80004252:	8526                	mv	a0,s1
    80004254:	fc3fd0ef          	jal	80002216 <sleep>
  while (lk->locked) {
    80004258:	409c                	lw	a5,0(s1)
    8000425a:	fbfd                	bnez	a5,80004250 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    8000425c:	4785                	li	a5,1
    8000425e:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004260:	ea2fd0ef          	jal	80001902 <myproc>
    80004264:	591c                	lw	a5,48(a0)
    80004266:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004268:	854a                	mv	a0,s2
    8000426a:	a23fc0ef          	jal	80000c8c <release>
}
    8000426e:	60e2                	ld	ra,24(sp)
    80004270:	6442                	ld	s0,16(sp)
    80004272:	64a2                	ld	s1,8(sp)
    80004274:	6902                	ld	s2,0(sp)
    80004276:	6105                	addi	sp,sp,32
    80004278:	8082                	ret

000000008000427a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000427a:	1101                	addi	sp,sp,-32
    8000427c:	ec06                	sd	ra,24(sp)
    8000427e:	e822                	sd	s0,16(sp)
    80004280:	e426                	sd	s1,8(sp)
    80004282:	e04a                	sd	s2,0(sp)
    80004284:	1000                	addi	s0,sp,32
    80004286:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004288:	00850913          	addi	s2,a0,8
    8000428c:	854a                	mv	a0,s2
    8000428e:	967fc0ef          	jal	80000bf4 <acquire>
  lk->locked = 0;
    80004292:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004296:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000429a:	8526                	mv	a0,s1
    8000429c:	fc7fd0ef          	jal	80002262 <wakeup>
  release(&lk->lk);
    800042a0:	854a                	mv	a0,s2
    800042a2:	9ebfc0ef          	jal	80000c8c <release>
}
    800042a6:	60e2                	ld	ra,24(sp)
    800042a8:	6442                	ld	s0,16(sp)
    800042aa:	64a2                	ld	s1,8(sp)
    800042ac:	6902                	ld	s2,0(sp)
    800042ae:	6105                	addi	sp,sp,32
    800042b0:	8082                	ret

00000000800042b2 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800042b2:	7179                	addi	sp,sp,-48
    800042b4:	f406                	sd	ra,40(sp)
    800042b6:	f022                	sd	s0,32(sp)
    800042b8:	ec26                	sd	s1,24(sp)
    800042ba:	e84a                	sd	s2,16(sp)
    800042bc:	1800                	addi	s0,sp,48
    800042be:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800042c0:	00850913          	addi	s2,a0,8
    800042c4:	854a                	mv	a0,s2
    800042c6:	92ffc0ef          	jal	80000bf4 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800042ca:	409c                	lw	a5,0(s1)
    800042cc:	ef81                	bnez	a5,800042e4 <holdingsleep+0x32>
    800042ce:	4481                	li	s1,0
  release(&lk->lk);
    800042d0:	854a                	mv	a0,s2
    800042d2:	9bbfc0ef          	jal	80000c8c <release>
  return r;
}
    800042d6:	8526                	mv	a0,s1
    800042d8:	70a2                	ld	ra,40(sp)
    800042da:	7402                	ld	s0,32(sp)
    800042dc:	64e2                	ld	s1,24(sp)
    800042de:	6942                	ld	s2,16(sp)
    800042e0:	6145                	addi	sp,sp,48
    800042e2:	8082                	ret
    800042e4:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    800042e6:	0284a983          	lw	s3,40(s1)
    800042ea:	e18fd0ef          	jal	80001902 <myproc>
    800042ee:	5904                	lw	s1,48(a0)
    800042f0:	413484b3          	sub	s1,s1,s3
    800042f4:	0014b493          	seqz	s1,s1
    800042f8:	69a2                	ld	s3,8(sp)
    800042fa:	bfd9                	j	800042d0 <holdingsleep+0x1e>

00000000800042fc <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800042fc:	1141                	addi	sp,sp,-16
    800042fe:	e406                	sd	ra,8(sp)
    80004300:	e022                	sd	s0,0(sp)
    80004302:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004304:	00003597          	auipc	a1,0x3
    80004308:	46458593          	addi	a1,a1,1124 # 80007768 <etext+0x768>
    8000430c:	0001e517          	auipc	a0,0x1e
    80004310:	c0c50513          	addi	a0,a0,-1012 # 80021f18 <ftable>
    80004314:	861fc0ef          	jal	80000b74 <initlock>
}
    80004318:	60a2                	ld	ra,8(sp)
    8000431a:	6402                	ld	s0,0(sp)
    8000431c:	0141                	addi	sp,sp,16
    8000431e:	8082                	ret

0000000080004320 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004320:	1101                	addi	sp,sp,-32
    80004322:	ec06                	sd	ra,24(sp)
    80004324:	e822                	sd	s0,16(sp)
    80004326:	e426                	sd	s1,8(sp)
    80004328:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000432a:	0001e517          	auipc	a0,0x1e
    8000432e:	bee50513          	addi	a0,a0,-1042 # 80021f18 <ftable>
    80004332:	8c3fc0ef          	jal	80000bf4 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004336:	0001e497          	auipc	s1,0x1e
    8000433a:	bfa48493          	addi	s1,s1,-1030 # 80021f30 <ftable+0x18>
    8000433e:	0001f717          	auipc	a4,0x1f
    80004342:	b9270713          	addi	a4,a4,-1134 # 80022ed0 <disk>
    if(f->ref == 0){
    80004346:	40dc                	lw	a5,4(s1)
    80004348:	cf89                	beqz	a5,80004362 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000434a:	02848493          	addi	s1,s1,40
    8000434e:	fee49ce3          	bne	s1,a4,80004346 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004352:	0001e517          	auipc	a0,0x1e
    80004356:	bc650513          	addi	a0,a0,-1082 # 80021f18 <ftable>
    8000435a:	933fc0ef          	jal	80000c8c <release>
  return 0;
    8000435e:	4481                	li	s1,0
    80004360:	a809                	j	80004372 <filealloc+0x52>
      f->ref = 1;
    80004362:	4785                	li	a5,1
    80004364:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004366:	0001e517          	auipc	a0,0x1e
    8000436a:	bb250513          	addi	a0,a0,-1102 # 80021f18 <ftable>
    8000436e:	91ffc0ef          	jal	80000c8c <release>
}
    80004372:	8526                	mv	a0,s1
    80004374:	60e2                	ld	ra,24(sp)
    80004376:	6442                	ld	s0,16(sp)
    80004378:	64a2                	ld	s1,8(sp)
    8000437a:	6105                	addi	sp,sp,32
    8000437c:	8082                	ret

000000008000437e <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000437e:	1101                	addi	sp,sp,-32
    80004380:	ec06                	sd	ra,24(sp)
    80004382:	e822                	sd	s0,16(sp)
    80004384:	e426                	sd	s1,8(sp)
    80004386:	1000                	addi	s0,sp,32
    80004388:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000438a:	0001e517          	auipc	a0,0x1e
    8000438e:	b8e50513          	addi	a0,a0,-1138 # 80021f18 <ftable>
    80004392:	863fc0ef          	jal	80000bf4 <acquire>
  if(f->ref < 1)
    80004396:	40dc                	lw	a5,4(s1)
    80004398:	02f05063          	blez	a5,800043b8 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    8000439c:	2785                	addiw	a5,a5,1
    8000439e:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800043a0:	0001e517          	auipc	a0,0x1e
    800043a4:	b7850513          	addi	a0,a0,-1160 # 80021f18 <ftable>
    800043a8:	8e5fc0ef          	jal	80000c8c <release>
  return f;
}
    800043ac:	8526                	mv	a0,s1
    800043ae:	60e2                	ld	ra,24(sp)
    800043b0:	6442                	ld	s0,16(sp)
    800043b2:	64a2                	ld	s1,8(sp)
    800043b4:	6105                	addi	sp,sp,32
    800043b6:	8082                	ret
    panic("filedup");
    800043b8:	00003517          	auipc	a0,0x3
    800043bc:	3b850513          	addi	a0,a0,952 # 80007770 <etext+0x770>
    800043c0:	bd4fc0ef          	jal	80000794 <panic>

00000000800043c4 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800043c4:	7139                	addi	sp,sp,-64
    800043c6:	fc06                	sd	ra,56(sp)
    800043c8:	f822                	sd	s0,48(sp)
    800043ca:	f426                	sd	s1,40(sp)
    800043cc:	0080                	addi	s0,sp,64
    800043ce:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800043d0:	0001e517          	auipc	a0,0x1e
    800043d4:	b4850513          	addi	a0,a0,-1208 # 80021f18 <ftable>
    800043d8:	81dfc0ef          	jal	80000bf4 <acquire>
  if(f->ref < 1)
    800043dc:	40dc                	lw	a5,4(s1)
    800043de:	04f05a63          	blez	a5,80004432 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    800043e2:	37fd                	addiw	a5,a5,-1
    800043e4:	0007871b          	sext.w	a4,a5
    800043e8:	c0dc                	sw	a5,4(s1)
    800043ea:	04e04e63          	bgtz	a4,80004446 <fileclose+0x82>
    800043ee:	f04a                	sd	s2,32(sp)
    800043f0:	ec4e                	sd	s3,24(sp)
    800043f2:	e852                	sd	s4,16(sp)
    800043f4:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800043f6:	0004a903          	lw	s2,0(s1)
    800043fa:	0094ca83          	lbu	s5,9(s1)
    800043fe:	0104ba03          	ld	s4,16(s1)
    80004402:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004406:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000440a:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000440e:	0001e517          	auipc	a0,0x1e
    80004412:	b0a50513          	addi	a0,a0,-1270 # 80021f18 <ftable>
    80004416:	877fc0ef          	jal	80000c8c <release>

  if(ff.type == FD_PIPE){
    8000441a:	4785                	li	a5,1
    8000441c:	04f90063          	beq	s2,a5,8000445c <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004420:	3979                	addiw	s2,s2,-2
    80004422:	4785                	li	a5,1
    80004424:	0527f563          	bgeu	a5,s2,8000446e <fileclose+0xaa>
    80004428:	7902                	ld	s2,32(sp)
    8000442a:	69e2                	ld	s3,24(sp)
    8000442c:	6a42                	ld	s4,16(sp)
    8000442e:	6aa2                	ld	s5,8(sp)
    80004430:	a00d                	j	80004452 <fileclose+0x8e>
    80004432:	f04a                	sd	s2,32(sp)
    80004434:	ec4e                	sd	s3,24(sp)
    80004436:	e852                	sd	s4,16(sp)
    80004438:	e456                	sd	s5,8(sp)
    panic("fileclose");
    8000443a:	00003517          	auipc	a0,0x3
    8000443e:	33e50513          	addi	a0,a0,830 # 80007778 <etext+0x778>
    80004442:	b52fc0ef          	jal	80000794 <panic>
    release(&ftable.lock);
    80004446:	0001e517          	auipc	a0,0x1e
    8000444a:	ad250513          	addi	a0,a0,-1326 # 80021f18 <ftable>
    8000444e:	83ffc0ef          	jal	80000c8c <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004452:	70e2                	ld	ra,56(sp)
    80004454:	7442                	ld	s0,48(sp)
    80004456:	74a2                	ld	s1,40(sp)
    80004458:	6121                	addi	sp,sp,64
    8000445a:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000445c:	85d6                	mv	a1,s5
    8000445e:	8552                	mv	a0,s4
    80004460:	336000ef          	jal	80004796 <pipeclose>
    80004464:	7902                	ld	s2,32(sp)
    80004466:	69e2                	ld	s3,24(sp)
    80004468:	6a42                	ld	s4,16(sp)
    8000446a:	6aa2                	ld	s5,8(sp)
    8000446c:	b7dd                	j	80004452 <fileclose+0x8e>
    begin_op();
    8000446e:	ae9ff0ef          	jal	80003f56 <begin_op>
    iput(ff.ip);
    80004472:	854e                	mv	a0,s3
    80004474:	bceff0ef          	jal	80003842 <iput>
    end_op();
    80004478:	b49ff0ef          	jal	80003fc0 <end_op>
    8000447c:	7902                	ld	s2,32(sp)
    8000447e:	69e2                	ld	s3,24(sp)
    80004480:	6a42                	ld	s4,16(sp)
    80004482:	6aa2                	ld	s5,8(sp)
    80004484:	b7f9                	j	80004452 <fileclose+0x8e>

0000000080004486 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004486:	715d                	addi	sp,sp,-80
    80004488:	e486                	sd	ra,72(sp)
    8000448a:	e0a2                	sd	s0,64(sp)
    8000448c:	fc26                	sd	s1,56(sp)
    8000448e:	f44e                	sd	s3,40(sp)
    80004490:	0880                	addi	s0,sp,80
    80004492:	84aa                	mv	s1,a0
    80004494:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004496:	c6cfd0ef          	jal	80001902 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000449a:	409c                	lw	a5,0(s1)
    8000449c:	37f9                	addiw	a5,a5,-2
    8000449e:	4705                	li	a4,1
    800044a0:	04f76063          	bltu	a4,a5,800044e0 <filestat+0x5a>
    800044a4:	f84a                	sd	s2,48(sp)
    800044a6:	892a                	mv	s2,a0
    ilock(f->ip);
    800044a8:	6c88                	ld	a0,24(s1)
    800044aa:	a16ff0ef          	jal	800036c0 <ilock>
    stati(f->ip, &st);
    800044ae:	fb840593          	addi	a1,s0,-72
    800044b2:	6c88                	ld	a0,24(s1)
    800044b4:	c36ff0ef          	jal	800038ea <stati>
    iunlock(f->ip);
    800044b8:	6c88                	ld	a0,24(s1)
    800044ba:	ab4ff0ef          	jal	8000376e <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800044be:	46e1                	li	a3,24
    800044c0:	fb840613          	addi	a2,s0,-72
    800044c4:	85ce                	mv	a1,s3
    800044c6:	05093503          	ld	a0,80(s2)
    800044ca:	8b2fd0ef          	jal	8000157c <copyout>
    800044ce:	41f5551b          	sraiw	a0,a0,0x1f
    800044d2:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800044d4:	60a6                	ld	ra,72(sp)
    800044d6:	6406                	ld	s0,64(sp)
    800044d8:	74e2                	ld	s1,56(sp)
    800044da:	79a2                	ld	s3,40(sp)
    800044dc:	6161                	addi	sp,sp,80
    800044de:	8082                	ret
  return -1;
    800044e0:	557d                	li	a0,-1
    800044e2:	bfcd                	j	800044d4 <filestat+0x4e>

00000000800044e4 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800044e4:	7179                	addi	sp,sp,-48
    800044e6:	f406                	sd	ra,40(sp)
    800044e8:	f022                	sd	s0,32(sp)
    800044ea:	e84a                	sd	s2,16(sp)
    800044ec:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800044ee:	00854783          	lbu	a5,8(a0)
    800044f2:	cfd1                	beqz	a5,8000458e <fileread+0xaa>
    800044f4:	ec26                	sd	s1,24(sp)
    800044f6:	e44e                	sd	s3,8(sp)
    800044f8:	84aa                	mv	s1,a0
    800044fa:	89ae                	mv	s3,a1
    800044fc:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800044fe:	411c                	lw	a5,0(a0)
    80004500:	4705                	li	a4,1
    80004502:	04e78363          	beq	a5,a4,80004548 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004506:	470d                	li	a4,3
    80004508:	04e78763          	beq	a5,a4,80004556 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000450c:	4709                	li	a4,2
    8000450e:	06e79a63          	bne	a5,a4,80004582 <fileread+0x9e>
    ilock(f->ip);
    80004512:	6d08                	ld	a0,24(a0)
    80004514:	9acff0ef          	jal	800036c0 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004518:	874a                	mv	a4,s2
    8000451a:	5094                	lw	a3,32(s1)
    8000451c:	864e                	mv	a2,s3
    8000451e:	4585                	li	a1,1
    80004520:	6c88                	ld	a0,24(s1)
    80004522:	bf2ff0ef          	jal	80003914 <readi>
    80004526:	892a                	mv	s2,a0
    80004528:	00a05563          	blez	a0,80004532 <fileread+0x4e>
      f->off += r;
    8000452c:	509c                	lw	a5,32(s1)
    8000452e:	9fa9                	addw	a5,a5,a0
    80004530:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004532:	6c88                	ld	a0,24(s1)
    80004534:	a3aff0ef          	jal	8000376e <iunlock>
    80004538:	64e2                	ld	s1,24(sp)
    8000453a:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    8000453c:	854a                	mv	a0,s2
    8000453e:	70a2                	ld	ra,40(sp)
    80004540:	7402                	ld	s0,32(sp)
    80004542:	6942                	ld	s2,16(sp)
    80004544:	6145                	addi	sp,sp,48
    80004546:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004548:	6908                	ld	a0,16(a0)
    8000454a:	388000ef          	jal	800048d2 <piperead>
    8000454e:	892a                	mv	s2,a0
    80004550:	64e2                	ld	s1,24(sp)
    80004552:	69a2                	ld	s3,8(sp)
    80004554:	b7e5                	j	8000453c <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004556:	02451783          	lh	a5,36(a0)
    8000455a:	03079693          	slli	a3,a5,0x30
    8000455e:	92c1                	srli	a3,a3,0x30
    80004560:	4725                	li	a4,9
    80004562:	02d76863          	bltu	a4,a3,80004592 <fileread+0xae>
    80004566:	0792                	slli	a5,a5,0x4
    80004568:	0001e717          	auipc	a4,0x1e
    8000456c:	91070713          	addi	a4,a4,-1776 # 80021e78 <devsw>
    80004570:	97ba                	add	a5,a5,a4
    80004572:	639c                	ld	a5,0(a5)
    80004574:	c39d                	beqz	a5,8000459a <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    80004576:	4505                	li	a0,1
    80004578:	9782                	jalr	a5
    8000457a:	892a                	mv	s2,a0
    8000457c:	64e2                	ld	s1,24(sp)
    8000457e:	69a2                	ld	s3,8(sp)
    80004580:	bf75                	j	8000453c <fileread+0x58>
    panic("fileread");
    80004582:	00003517          	auipc	a0,0x3
    80004586:	20650513          	addi	a0,a0,518 # 80007788 <etext+0x788>
    8000458a:	a0afc0ef          	jal	80000794 <panic>
    return -1;
    8000458e:	597d                	li	s2,-1
    80004590:	b775                	j	8000453c <fileread+0x58>
      return -1;
    80004592:	597d                	li	s2,-1
    80004594:	64e2                	ld	s1,24(sp)
    80004596:	69a2                	ld	s3,8(sp)
    80004598:	b755                	j	8000453c <fileread+0x58>
    8000459a:	597d                	li	s2,-1
    8000459c:	64e2                	ld	s1,24(sp)
    8000459e:	69a2                	ld	s3,8(sp)
    800045a0:	bf71                	j	8000453c <fileread+0x58>

00000000800045a2 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800045a2:	00954783          	lbu	a5,9(a0)
    800045a6:	10078b63          	beqz	a5,800046bc <filewrite+0x11a>
{
    800045aa:	715d                	addi	sp,sp,-80
    800045ac:	e486                	sd	ra,72(sp)
    800045ae:	e0a2                	sd	s0,64(sp)
    800045b0:	f84a                	sd	s2,48(sp)
    800045b2:	f052                	sd	s4,32(sp)
    800045b4:	e85a                	sd	s6,16(sp)
    800045b6:	0880                	addi	s0,sp,80
    800045b8:	892a                	mv	s2,a0
    800045ba:	8b2e                	mv	s6,a1
    800045bc:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800045be:	411c                	lw	a5,0(a0)
    800045c0:	4705                	li	a4,1
    800045c2:	02e78763          	beq	a5,a4,800045f0 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800045c6:	470d                	li	a4,3
    800045c8:	02e78863          	beq	a5,a4,800045f8 <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800045cc:	4709                	li	a4,2
    800045ce:	0ce79c63          	bne	a5,a4,800046a6 <filewrite+0x104>
    800045d2:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800045d4:	0ac05863          	blez	a2,80004684 <filewrite+0xe2>
    800045d8:	fc26                	sd	s1,56(sp)
    800045da:	ec56                	sd	s5,24(sp)
    800045dc:	e45e                	sd	s7,8(sp)
    800045de:	e062                	sd	s8,0(sp)
    int i = 0;
    800045e0:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    800045e2:	6b85                	lui	s7,0x1
    800045e4:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800045e8:	6c05                	lui	s8,0x1
    800045ea:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800045ee:	a8b5                	j	8000466a <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    800045f0:	6908                	ld	a0,16(a0)
    800045f2:	1fc000ef          	jal	800047ee <pipewrite>
    800045f6:	a04d                	j	80004698 <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800045f8:	02451783          	lh	a5,36(a0)
    800045fc:	03079693          	slli	a3,a5,0x30
    80004600:	92c1                	srli	a3,a3,0x30
    80004602:	4725                	li	a4,9
    80004604:	0ad76e63          	bltu	a4,a3,800046c0 <filewrite+0x11e>
    80004608:	0792                	slli	a5,a5,0x4
    8000460a:	0001e717          	auipc	a4,0x1e
    8000460e:	86e70713          	addi	a4,a4,-1938 # 80021e78 <devsw>
    80004612:	97ba                	add	a5,a5,a4
    80004614:	679c                	ld	a5,8(a5)
    80004616:	c7dd                	beqz	a5,800046c4 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    80004618:	4505                	li	a0,1
    8000461a:	9782                	jalr	a5
    8000461c:	a8b5                	j	80004698 <filewrite+0xf6>
      if(n1 > max)
    8000461e:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004622:	935ff0ef          	jal	80003f56 <begin_op>
      ilock(f->ip);
    80004626:	01893503          	ld	a0,24(s2)
    8000462a:	896ff0ef          	jal	800036c0 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000462e:	8756                	mv	a4,s5
    80004630:	02092683          	lw	a3,32(s2)
    80004634:	01698633          	add	a2,s3,s6
    80004638:	4585                	li	a1,1
    8000463a:	01893503          	ld	a0,24(s2)
    8000463e:	bd2ff0ef          	jal	80003a10 <writei>
    80004642:	84aa                	mv	s1,a0
    80004644:	00a05763          	blez	a0,80004652 <filewrite+0xb0>
        f->off += r;
    80004648:	02092783          	lw	a5,32(s2)
    8000464c:	9fa9                	addw	a5,a5,a0
    8000464e:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004652:	01893503          	ld	a0,24(s2)
    80004656:	918ff0ef          	jal	8000376e <iunlock>
      end_op();
    8000465a:	967ff0ef          	jal	80003fc0 <end_op>

      if(r != n1){
    8000465e:	029a9563          	bne	s5,s1,80004688 <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    80004662:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004666:	0149da63          	bge	s3,s4,8000467a <filewrite+0xd8>
      int n1 = n - i;
    8000466a:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    8000466e:	0004879b          	sext.w	a5,s1
    80004672:	fafbd6e3          	bge	s7,a5,8000461e <filewrite+0x7c>
    80004676:	84e2                	mv	s1,s8
    80004678:	b75d                	j	8000461e <filewrite+0x7c>
    8000467a:	74e2                	ld	s1,56(sp)
    8000467c:	6ae2                	ld	s5,24(sp)
    8000467e:	6ba2                	ld	s7,8(sp)
    80004680:	6c02                	ld	s8,0(sp)
    80004682:	a039                	j	80004690 <filewrite+0xee>
    int i = 0;
    80004684:	4981                	li	s3,0
    80004686:	a029                	j	80004690 <filewrite+0xee>
    80004688:	74e2                	ld	s1,56(sp)
    8000468a:	6ae2                	ld	s5,24(sp)
    8000468c:	6ba2                	ld	s7,8(sp)
    8000468e:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    80004690:	033a1c63          	bne	s4,s3,800046c8 <filewrite+0x126>
    80004694:	8552                	mv	a0,s4
    80004696:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004698:	60a6                	ld	ra,72(sp)
    8000469a:	6406                	ld	s0,64(sp)
    8000469c:	7942                	ld	s2,48(sp)
    8000469e:	7a02                	ld	s4,32(sp)
    800046a0:	6b42                	ld	s6,16(sp)
    800046a2:	6161                	addi	sp,sp,80
    800046a4:	8082                	ret
    800046a6:	fc26                	sd	s1,56(sp)
    800046a8:	f44e                	sd	s3,40(sp)
    800046aa:	ec56                	sd	s5,24(sp)
    800046ac:	e45e                	sd	s7,8(sp)
    800046ae:	e062                	sd	s8,0(sp)
    panic("filewrite");
    800046b0:	00003517          	auipc	a0,0x3
    800046b4:	0e850513          	addi	a0,a0,232 # 80007798 <etext+0x798>
    800046b8:	8dcfc0ef          	jal	80000794 <panic>
    return -1;
    800046bc:	557d                	li	a0,-1
}
    800046be:	8082                	ret
      return -1;
    800046c0:	557d                	li	a0,-1
    800046c2:	bfd9                	j	80004698 <filewrite+0xf6>
    800046c4:	557d                	li	a0,-1
    800046c6:	bfc9                	j	80004698 <filewrite+0xf6>
    ret = (i == n ? n : -1);
    800046c8:	557d                	li	a0,-1
    800046ca:	79a2                	ld	s3,40(sp)
    800046cc:	b7f1                	j	80004698 <filewrite+0xf6>

00000000800046ce <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800046ce:	7179                	addi	sp,sp,-48
    800046d0:	f406                	sd	ra,40(sp)
    800046d2:	f022                	sd	s0,32(sp)
    800046d4:	ec26                	sd	s1,24(sp)
    800046d6:	e052                	sd	s4,0(sp)
    800046d8:	1800                	addi	s0,sp,48
    800046da:	84aa                	mv	s1,a0
    800046dc:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800046de:	0005b023          	sd	zero,0(a1)
    800046e2:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800046e6:	c3bff0ef          	jal	80004320 <filealloc>
    800046ea:	e088                	sd	a0,0(s1)
    800046ec:	c549                	beqz	a0,80004776 <pipealloc+0xa8>
    800046ee:	c33ff0ef          	jal	80004320 <filealloc>
    800046f2:	00aa3023          	sd	a0,0(s4)
    800046f6:	cd25                	beqz	a0,8000476e <pipealloc+0xa0>
    800046f8:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800046fa:	c2afc0ef          	jal	80000b24 <kalloc>
    800046fe:	892a                	mv	s2,a0
    80004700:	c12d                	beqz	a0,80004762 <pipealloc+0x94>
    80004702:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004704:	4985                	li	s3,1
    80004706:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000470a:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000470e:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004712:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004716:	00003597          	auipc	a1,0x3
    8000471a:	09258593          	addi	a1,a1,146 # 800077a8 <etext+0x7a8>
    8000471e:	c56fc0ef          	jal	80000b74 <initlock>
  (*f0)->type = FD_PIPE;
    80004722:	609c                	ld	a5,0(s1)
    80004724:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004728:	609c                	ld	a5,0(s1)
    8000472a:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000472e:	609c                	ld	a5,0(s1)
    80004730:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004734:	609c                	ld	a5,0(s1)
    80004736:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000473a:	000a3783          	ld	a5,0(s4)
    8000473e:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004742:	000a3783          	ld	a5,0(s4)
    80004746:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000474a:	000a3783          	ld	a5,0(s4)
    8000474e:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004752:	000a3783          	ld	a5,0(s4)
    80004756:	0127b823          	sd	s2,16(a5)
  return 0;
    8000475a:	4501                	li	a0,0
    8000475c:	6942                	ld	s2,16(sp)
    8000475e:	69a2                	ld	s3,8(sp)
    80004760:	a01d                	j	80004786 <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004762:	6088                	ld	a0,0(s1)
    80004764:	c119                	beqz	a0,8000476a <pipealloc+0x9c>
    80004766:	6942                	ld	s2,16(sp)
    80004768:	a029                	j	80004772 <pipealloc+0xa4>
    8000476a:	6942                	ld	s2,16(sp)
    8000476c:	a029                	j	80004776 <pipealloc+0xa8>
    8000476e:	6088                	ld	a0,0(s1)
    80004770:	c10d                	beqz	a0,80004792 <pipealloc+0xc4>
    fileclose(*f0);
    80004772:	c53ff0ef          	jal	800043c4 <fileclose>
  if(*f1)
    80004776:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000477a:	557d                	li	a0,-1
  if(*f1)
    8000477c:	c789                	beqz	a5,80004786 <pipealloc+0xb8>
    fileclose(*f1);
    8000477e:	853e                	mv	a0,a5
    80004780:	c45ff0ef          	jal	800043c4 <fileclose>
  return -1;
    80004784:	557d                	li	a0,-1
}
    80004786:	70a2                	ld	ra,40(sp)
    80004788:	7402                	ld	s0,32(sp)
    8000478a:	64e2                	ld	s1,24(sp)
    8000478c:	6a02                	ld	s4,0(sp)
    8000478e:	6145                	addi	sp,sp,48
    80004790:	8082                	ret
  return -1;
    80004792:	557d                	li	a0,-1
    80004794:	bfcd                	j	80004786 <pipealloc+0xb8>

0000000080004796 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004796:	1101                	addi	sp,sp,-32
    80004798:	ec06                	sd	ra,24(sp)
    8000479a:	e822                	sd	s0,16(sp)
    8000479c:	e426                	sd	s1,8(sp)
    8000479e:	e04a                	sd	s2,0(sp)
    800047a0:	1000                	addi	s0,sp,32
    800047a2:	84aa                	mv	s1,a0
    800047a4:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800047a6:	c4efc0ef          	jal	80000bf4 <acquire>
  if(writable){
    800047aa:	02090763          	beqz	s2,800047d8 <pipeclose+0x42>
    pi->writeopen = 0;
    800047ae:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800047b2:	21848513          	addi	a0,s1,536
    800047b6:	aadfd0ef          	jal	80002262 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800047ba:	2204b783          	ld	a5,544(s1)
    800047be:	e785                	bnez	a5,800047e6 <pipeclose+0x50>
    release(&pi->lock);
    800047c0:	8526                	mv	a0,s1
    800047c2:	ccafc0ef          	jal	80000c8c <release>
    kfree((char*)pi);
    800047c6:	8526                	mv	a0,s1
    800047c8:	a7afc0ef          	jal	80000a42 <kfree>
  } else
    release(&pi->lock);
}
    800047cc:	60e2                	ld	ra,24(sp)
    800047ce:	6442                	ld	s0,16(sp)
    800047d0:	64a2                	ld	s1,8(sp)
    800047d2:	6902                	ld	s2,0(sp)
    800047d4:	6105                	addi	sp,sp,32
    800047d6:	8082                	ret
    pi->readopen = 0;
    800047d8:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800047dc:	21c48513          	addi	a0,s1,540
    800047e0:	a83fd0ef          	jal	80002262 <wakeup>
    800047e4:	bfd9                	j	800047ba <pipeclose+0x24>
    release(&pi->lock);
    800047e6:	8526                	mv	a0,s1
    800047e8:	ca4fc0ef          	jal	80000c8c <release>
}
    800047ec:	b7c5                	j	800047cc <pipeclose+0x36>

00000000800047ee <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800047ee:	711d                	addi	sp,sp,-96
    800047f0:	ec86                	sd	ra,88(sp)
    800047f2:	e8a2                	sd	s0,80(sp)
    800047f4:	e4a6                	sd	s1,72(sp)
    800047f6:	e0ca                	sd	s2,64(sp)
    800047f8:	fc4e                	sd	s3,56(sp)
    800047fa:	f852                	sd	s4,48(sp)
    800047fc:	f456                	sd	s5,40(sp)
    800047fe:	1080                	addi	s0,sp,96
    80004800:	84aa                	mv	s1,a0
    80004802:	8aae                	mv	s5,a1
    80004804:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004806:	8fcfd0ef          	jal	80001902 <myproc>
    8000480a:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    8000480c:	8526                	mv	a0,s1
    8000480e:	be6fc0ef          	jal	80000bf4 <acquire>
  while(i < n){
    80004812:	0b405a63          	blez	s4,800048c6 <pipewrite+0xd8>
    80004816:	f05a                	sd	s6,32(sp)
    80004818:	ec5e                	sd	s7,24(sp)
    8000481a:	e862                	sd	s8,16(sp)
  int i = 0;
    8000481c:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000481e:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004820:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004824:	21c48b93          	addi	s7,s1,540
    80004828:	a81d                	j	8000485e <pipewrite+0x70>
      release(&pi->lock);
    8000482a:	8526                	mv	a0,s1
    8000482c:	c60fc0ef          	jal	80000c8c <release>
      return -1;
    80004830:	597d                	li	s2,-1
    80004832:	7b02                	ld	s6,32(sp)
    80004834:	6be2                	ld	s7,24(sp)
    80004836:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004838:	854a                	mv	a0,s2
    8000483a:	60e6                	ld	ra,88(sp)
    8000483c:	6446                	ld	s0,80(sp)
    8000483e:	64a6                	ld	s1,72(sp)
    80004840:	6906                	ld	s2,64(sp)
    80004842:	79e2                	ld	s3,56(sp)
    80004844:	7a42                	ld	s4,48(sp)
    80004846:	7aa2                	ld	s5,40(sp)
    80004848:	6125                	addi	sp,sp,96
    8000484a:	8082                	ret
      wakeup(&pi->nread);
    8000484c:	8562                	mv	a0,s8
    8000484e:	a15fd0ef          	jal	80002262 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004852:	85a6                	mv	a1,s1
    80004854:	855e                	mv	a0,s7
    80004856:	9c1fd0ef          	jal	80002216 <sleep>
  while(i < n){
    8000485a:	05495b63          	bge	s2,s4,800048b0 <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    8000485e:	2204a783          	lw	a5,544(s1)
    80004862:	d7e1                	beqz	a5,8000482a <pipewrite+0x3c>
    80004864:	854e                	mv	a0,s3
    80004866:	c4ffd0ef          	jal	800024b4 <killed>
    8000486a:	f161                	bnez	a0,8000482a <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000486c:	2184a783          	lw	a5,536(s1)
    80004870:	21c4a703          	lw	a4,540(s1)
    80004874:	2007879b          	addiw	a5,a5,512
    80004878:	fcf70ae3          	beq	a4,a5,8000484c <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000487c:	4685                	li	a3,1
    8000487e:	01590633          	add	a2,s2,s5
    80004882:	faf40593          	addi	a1,s0,-81
    80004886:	0509b503          	ld	a0,80(s3)
    8000488a:	dc9fc0ef          	jal	80001652 <copyin>
    8000488e:	03650e63          	beq	a0,s6,800048ca <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004892:	21c4a783          	lw	a5,540(s1)
    80004896:	0017871b          	addiw	a4,a5,1
    8000489a:	20e4ae23          	sw	a4,540(s1)
    8000489e:	1ff7f793          	andi	a5,a5,511
    800048a2:	97a6                	add	a5,a5,s1
    800048a4:	faf44703          	lbu	a4,-81(s0)
    800048a8:	00e78c23          	sb	a4,24(a5)
      i++;
    800048ac:	2905                	addiw	s2,s2,1
    800048ae:	b775                	j	8000485a <pipewrite+0x6c>
    800048b0:	7b02                	ld	s6,32(sp)
    800048b2:	6be2                	ld	s7,24(sp)
    800048b4:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    800048b6:	21848513          	addi	a0,s1,536
    800048ba:	9a9fd0ef          	jal	80002262 <wakeup>
  release(&pi->lock);
    800048be:	8526                	mv	a0,s1
    800048c0:	bccfc0ef          	jal	80000c8c <release>
  return i;
    800048c4:	bf95                	j	80004838 <pipewrite+0x4a>
  int i = 0;
    800048c6:	4901                	li	s2,0
    800048c8:	b7fd                	j	800048b6 <pipewrite+0xc8>
    800048ca:	7b02                	ld	s6,32(sp)
    800048cc:	6be2                	ld	s7,24(sp)
    800048ce:	6c42                	ld	s8,16(sp)
    800048d0:	b7dd                	j	800048b6 <pipewrite+0xc8>

00000000800048d2 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800048d2:	715d                	addi	sp,sp,-80
    800048d4:	e486                	sd	ra,72(sp)
    800048d6:	e0a2                	sd	s0,64(sp)
    800048d8:	fc26                	sd	s1,56(sp)
    800048da:	f84a                	sd	s2,48(sp)
    800048dc:	f44e                	sd	s3,40(sp)
    800048de:	f052                	sd	s4,32(sp)
    800048e0:	ec56                	sd	s5,24(sp)
    800048e2:	0880                	addi	s0,sp,80
    800048e4:	84aa                	mv	s1,a0
    800048e6:	892e                	mv	s2,a1
    800048e8:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800048ea:	818fd0ef          	jal	80001902 <myproc>
    800048ee:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800048f0:	8526                	mv	a0,s1
    800048f2:	b02fc0ef          	jal	80000bf4 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800048f6:	2184a703          	lw	a4,536(s1)
    800048fa:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800048fe:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004902:	02f71563          	bne	a4,a5,8000492c <piperead+0x5a>
    80004906:	2244a783          	lw	a5,548(s1)
    8000490a:	cb85                	beqz	a5,8000493a <piperead+0x68>
    if(killed(pr)){
    8000490c:	8552                	mv	a0,s4
    8000490e:	ba7fd0ef          	jal	800024b4 <killed>
    80004912:	ed19                	bnez	a0,80004930 <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004914:	85a6                	mv	a1,s1
    80004916:	854e                	mv	a0,s3
    80004918:	8fffd0ef          	jal	80002216 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000491c:	2184a703          	lw	a4,536(s1)
    80004920:	21c4a783          	lw	a5,540(s1)
    80004924:	fef701e3          	beq	a4,a5,80004906 <piperead+0x34>
    80004928:	e85a                	sd	s6,16(sp)
    8000492a:	a809                	j	8000493c <piperead+0x6a>
    8000492c:	e85a                	sd	s6,16(sp)
    8000492e:	a039                	j	8000493c <piperead+0x6a>
      release(&pi->lock);
    80004930:	8526                	mv	a0,s1
    80004932:	b5afc0ef          	jal	80000c8c <release>
      return -1;
    80004936:	59fd                	li	s3,-1
    80004938:	a8b1                	j	80004994 <piperead+0xc2>
    8000493a:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000493c:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000493e:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004940:	05505263          	blez	s5,80004984 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80004944:	2184a783          	lw	a5,536(s1)
    80004948:	21c4a703          	lw	a4,540(s1)
    8000494c:	02f70c63          	beq	a4,a5,80004984 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004950:	0017871b          	addiw	a4,a5,1
    80004954:	20e4ac23          	sw	a4,536(s1)
    80004958:	1ff7f793          	andi	a5,a5,511
    8000495c:	97a6                	add	a5,a5,s1
    8000495e:	0187c783          	lbu	a5,24(a5)
    80004962:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004966:	4685                	li	a3,1
    80004968:	fbf40613          	addi	a2,s0,-65
    8000496c:	85ca                	mv	a1,s2
    8000496e:	050a3503          	ld	a0,80(s4)
    80004972:	c0bfc0ef          	jal	8000157c <copyout>
    80004976:	01650763          	beq	a0,s6,80004984 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000497a:	2985                	addiw	s3,s3,1
    8000497c:	0905                	addi	s2,s2,1
    8000497e:	fd3a93e3          	bne	s5,s3,80004944 <piperead+0x72>
    80004982:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004984:	21c48513          	addi	a0,s1,540
    80004988:	8dbfd0ef          	jal	80002262 <wakeup>
  release(&pi->lock);
    8000498c:	8526                	mv	a0,s1
    8000498e:	afefc0ef          	jal	80000c8c <release>
    80004992:	6b42                	ld	s6,16(sp)
  return i;
}
    80004994:	854e                	mv	a0,s3
    80004996:	60a6                	ld	ra,72(sp)
    80004998:	6406                	ld	s0,64(sp)
    8000499a:	74e2                	ld	s1,56(sp)
    8000499c:	7942                	ld	s2,48(sp)
    8000499e:	79a2                	ld	s3,40(sp)
    800049a0:	7a02                	ld	s4,32(sp)
    800049a2:	6ae2                	ld	s5,24(sp)
    800049a4:	6161                	addi	sp,sp,80
    800049a6:	8082                	ret

00000000800049a8 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    800049a8:	1141                	addi	sp,sp,-16
    800049aa:	e422                	sd	s0,8(sp)
    800049ac:	0800                	addi	s0,sp,16
    800049ae:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800049b0:	8905                	andi	a0,a0,1
    800049b2:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    800049b4:	8b89                	andi	a5,a5,2
    800049b6:	c399                	beqz	a5,800049bc <flags2perm+0x14>
      perm |= PTE_W;
    800049b8:	00456513          	ori	a0,a0,4
    return perm;
}
    800049bc:	6422                	ld	s0,8(sp)
    800049be:	0141                	addi	sp,sp,16
    800049c0:	8082                	ret

00000000800049c2 <exec>:

int
exec(char *path, char **argv)
{
    800049c2:	df010113          	addi	sp,sp,-528
    800049c6:	20113423          	sd	ra,520(sp)
    800049ca:	20813023          	sd	s0,512(sp)
    800049ce:	ffa6                	sd	s1,504(sp)
    800049d0:	fbca                	sd	s2,496(sp)
    800049d2:	0c00                	addi	s0,sp,528
    800049d4:	892a                	mv	s2,a0
    800049d6:	dea43c23          	sd	a0,-520(s0)
    800049da:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800049de:	f25fc0ef          	jal	80001902 <myproc>
    800049e2:	84aa                	mv	s1,a0

  begin_op();
    800049e4:	d72ff0ef          	jal	80003f56 <begin_op>

  if((ip = namei(path)) == 0){
    800049e8:	854a                	mv	a0,s2
    800049ea:	bb0ff0ef          	jal	80003d9a <namei>
    800049ee:	c931                	beqz	a0,80004a42 <exec+0x80>
    800049f0:	f3d2                	sd	s4,480(sp)
    800049f2:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800049f4:	ccdfe0ef          	jal	800036c0 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800049f8:	04000713          	li	a4,64
    800049fc:	4681                	li	a3,0
    800049fe:	e5040613          	addi	a2,s0,-432
    80004a02:	4581                	li	a1,0
    80004a04:	8552                	mv	a0,s4
    80004a06:	f0ffe0ef          	jal	80003914 <readi>
    80004a0a:	04000793          	li	a5,64
    80004a0e:	00f51a63          	bne	a0,a5,80004a22 <exec+0x60>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004a12:	e5042703          	lw	a4,-432(s0)
    80004a16:	464c47b7          	lui	a5,0x464c4
    80004a1a:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004a1e:	02f70663          	beq	a4,a5,80004a4a <exec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004a22:	8552                	mv	a0,s4
    80004a24:	ea7fe0ef          	jal	800038ca <iunlockput>
    end_op();
    80004a28:	d98ff0ef          	jal	80003fc0 <end_op>
  }
  return -1;
    80004a2c:	557d                	li	a0,-1
    80004a2e:	7a1e                	ld	s4,480(sp)
}
    80004a30:	20813083          	ld	ra,520(sp)
    80004a34:	20013403          	ld	s0,512(sp)
    80004a38:	74fe                	ld	s1,504(sp)
    80004a3a:	795e                	ld	s2,496(sp)
    80004a3c:	21010113          	addi	sp,sp,528
    80004a40:	8082                	ret
    end_op();
    80004a42:	d7eff0ef          	jal	80003fc0 <end_op>
    return -1;
    80004a46:	557d                	li	a0,-1
    80004a48:	b7e5                	j	80004a30 <exec+0x6e>
    80004a4a:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004a4c:	8526                	mv	a0,s1
    80004a4e:	9fefd0ef          	jal	80001c4c <proc_pagetable>
    80004a52:	8b2a                	mv	s6,a0
    80004a54:	2c050b63          	beqz	a0,80004d2a <exec+0x368>
    80004a58:	f7ce                	sd	s3,488(sp)
    80004a5a:	efd6                	sd	s5,472(sp)
    80004a5c:	e7de                	sd	s7,456(sp)
    80004a5e:	e3e2                	sd	s8,448(sp)
    80004a60:	ff66                	sd	s9,440(sp)
    80004a62:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004a64:	e7042d03          	lw	s10,-400(s0)
    80004a68:	e8845783          	lhu	a5,-376(s0)
    80004a6c:	12078963          	beqz	a5,80004b9e <exec+0x1dc>
    80004a70:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004a72:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004a74:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80004a76:	6c85                	lui	s9,0x1
    80004a78:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004a7c:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004a80:	6a85                	lui	s5,0x1
    80004a82:	a085                	j	80004ae2 <exec+0x120>
      panic("loadseg: address should exist");
    80004a84:	00003517          	auipc	a0,0x3
    80004a88:	d2c50513          	addi	a0,a0,-724 # 800077b0 <etext+0x7b0>
    80004a8c:	d09fb0ef          	jal	80000794 <panic>
    if(sz - i < PGSIZE)
    80004a90:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004a92:	8726                	mv	a4,s1
    80004a94:	012c06bb          	addw	a3,s8,s2
    80004a98:	4581                	li	a1,0
    80004a9a:	8552                	mv	a0,s4
    80004a9c:	e79fe0ef          	jal	80003914 <readi>
    80004aa0:	2501                	sext.w	a0,a0
    80004aa2:	24a49a63          	bne	s1,a0,80004cf6 <exec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    80004aa6:	012a893b          	addw	s2,s5,s2
    80004aaa:	03397363          	bgeu	s2,s3,80004ad0 <exec+0x10e>
    pa = walkaddr(pagetable, va + i);
    80004aae:	02091593          	slli	a1,s2,0x20
    80004ab2:	9181                	srli	a1,a1,0x20
    80004ab4:	95de                	add	a1,a1,s7
    80004ab6:	855a                	mv	a0,s6
    80004ab8:	d48fc0ef          	jal	80001000 <walkaddr>
    80004abc:	862a                	mv	a2,a0
    if(pa == 0)
    80004abe:	d179                	beqz	a0,80004a84 <exec+0xc2>
    if(sz - i < PGSIZE)
    80004ac0:	412984bb          	subw	s1,s3,s2
    80004ac4:	0004879b          	sext.w	a5,s1
    80004ac8:	fcfcf4e3          	bgeu	s9,a5,80004a90 <exec+0xce>
    80004acc:	84d6                	mv	s1,s5
    80004ace:	b7c9                	j	80004a90 <exec+0xce>
    sz = sz1;
    80004ad0:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004ad4:	2d85                	addiw	s11,s11,1
    80004ad6:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    80004ada:	e8845783          	lhu	a5,-376(s0)
    80004ade:	08fdd063          	bge	s11,a5,80004b5e <exec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004ae2:	2d01                	sext.w	s10,s10
    80004ae4:	03800713          	li	a4,56
    80004ae8:	86ea                	mv	a3,s10
    80004aea:	e1840613          	addi	a2,s0,-488
    80004aee:	4581                	li	a1,0
    80004af0:	8552                	mv	a0,s4
    80004af2:	e23fe0ef          	jal	80003914 <readi>
    80004af6:	03800793          	li	a5,56
    80004afa:	1cf51663          	bne	a0,a5,80004cc6 <exec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    80004afe:	e1842783          	lw	a5,-488(s0)
    80004b02:	4705                	li	a4,1
    80004b04:	fce798e3          	bne	a5,a4,80004ad4 <exec+0x112>
    if(ph.memsz < ph.filesz)
    80004b08:	e4043483          	ld	s1,-448(s0)
    80004b0c:	e3843783          	ld	a5,-456(s0)
    80004b10:	1af4ef63          	bltu	s1,a5,80004cce <exec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004b14:	e2843783          	ld	a5,-472(s0)
    80004b18:	94be                	add	s1,s1,a5
    80004b1a:	1af4ee63          	bltu	s1,a5,80004cd6 <exec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    80004b1e:	df043703          	ld	a4,-528(s0)
    80004b22:	8ff9                	and	a5,a5,a4
    80004b24:	1a079d63          	bnez	a5,80004cde <exec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004b28:	e1c42503          	lw	a0,-484(s0)
    80004b2c:	e7dff0ef          	jal	800049a8 <flags2perm>
    80004b30:	86aa                	mv	a3,a0
    80004b32:	8626                	mv	a2,s1
    80004b34:	85ca                	mv	a1,s2
    80004b36:	855a                	mv	a0,s6
    80004b38:	831fc0ef          	jal	80001368 <uvmalloc>
    80004b3c:	e0a43423          	sd	a0,-504(s0)
    80004b40:	1a050363          	beqz	a0,80004ce6 <exec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004b44:	e2843b83          	ld	s7,-472(s0)
    80004b48:	e2042c03          	lw	s8,-480(s0)
    80004b4c:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004b50:	00098463          	beqz	s3,80004b58 <exec+0x196>
    80004b54:	4901                	li	s2,0
    80004b56:	bfa1                	j	80004aae <exec+0xec>
    sz = sz1;
    80004b58:	e0843903          	ld	s2,-504(s0)
    80004b5c:	bfa5                	j	80004ad4 <exec+0x112>
    80004b5e:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80004b60:	8552                	mv	a0,s4
    80004b62:	d69fe0ef          	jal	800038ca <iunlockput>
  end_op();
    80004b66:	c5aff0ef          	jal	80003fc0 <end_op>
  p = myproc();
    80004b6a:	d99fc0ef          	jal	80001902 <myproc>
    80004b6e:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004b70:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80004b74:	6985                	lui	s3,0x1
    80004b76:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004b78:	99ca                	add	s3,s3,s2
    80004b7a:	77fd                	lui	a5,0xfffff
    80004b7c:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004b80:	4691                	li	a3,4
    80004b82:	6609                	lui	a2,0x2
    80004b84:	964e                	add	a2,a2,s3
    80004b86:	85ce                	mv	a1,s3
    80004b88:	855a                	mv	a0,s6
    80004b8a:	fdefc0ef          	jal	80001368 <uvmalloc>
    80004b8e:	892a                	mv	s2,a0
    80004b90:	e0a43423          	sd	a0,-504(s0)
    80004b94:	e519                	bnez	a0,80004ba2 <exec+0x1e0>
  if(pagetable)
    80004b96:	e1343423          	sd	s3,-504(s0)
    80004b9a:	4a01                	li	s4,0
    80004b9c:	aab1                	j	80004cf8 <exec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004b9e:	4901                	li	s2,0
    80004ba0:	b7c1                	j	80004b60 <exec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004ba2:	75f9                	lui	a1,0xffffe
    80004ba4:	95aa                	add	a1,a1,a0
    80004ba6:	855a                	mv	a0,s6
    80004ba8:	9abfc0ef          	jal	80001552 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004bac:	7bfd                	lui	s7,0xfffff
    80004bae:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80004bb0:	e0043783          	ld	a5,-512(s0)
    80004bb4:	6388                	ld	a0,0(a5)
    80004bb6:	cd39                	beqz	a0,80004c14 <exec+0x252>
    80004bb8:	e9040993          	addi	s3,s0,-368
    80004bbc:	f9040c13          	addi	s8,s0,-112
    80004bc0:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004bc2:	a76fc0ef          	jal	80000e38 <strlen>
    80004bc6:	0015079b          	addiw	a5,a0,1
    80004bca:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004bce:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004bd2:	11796e63          	bltu	s2,s7,80004cee <exec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004bd6:	e0043d03          	ld	s10,-512(s0)
    80004bda:	000d3a03          	ld	s4,0(s10)
    80004bde:	8552                	mv	a0,s4
    80004be0:	a58fc0ef          	jal	80000e38 <strlen>
    80004be4:	0015069b          	addiw	a3,a0,1
    80004be8:	8652                	mv	a2,s4
    80004bea:	85ca                	mv	a1,s2
    80004bec:	855a                	mv	a0,s6
    80004bee:	98ffc0ef          	jal	8000157c <copyout>
    80004bf2:	10054063          	bltz	a0,80004cf2 <exec+0x330>
    ustack[argc] = sp;
    80004bf6:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004bfa:	0485                	addi	s1,s1,1
    80004bfc:	008d0793          	addi	a5,s10,8
    80004c00:	e0f43023          	sd	a5,-512(s0)
    80004c04:	008d3503          	ld	a0,8(s10)
    80004c08:	c909                	beqz	a0,80004c1a <exec+0x258>
    if(argc >= MAXARG)
    80004c0a:	09a1                	addi	s3,s3,8
    80004c0c:	fb899be3          	bne	s3,s8,80004bc2 <exec+0x200>
  ip = 0;
    80004c10:	4a01                	li	s4,0
    80004c12:	a0dd                	j	80004cf8 <exec+0x336>
  sp = sz;
    80004c14:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80004c18:	4481                	li	s1,0
  ustack[argc] = 0;
    80004c1a:	00349793          	slli	a5,s1,0x3
    80004c1e:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdbf80>
    80004c22:	97a2                	add	a5,a5,s0
    80004c24:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004c28:	00148693          	addi	a3,s1,1
    80004c2c:	068e                	slli	a3,a3,0x3
    80004c2e:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004c32:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004c36:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80004c3a:	f5796ee3          	bltu	s2,s7,80004b96 <exec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004c3e:	e9040613          	addi	a2,s0,-368
    80004c42:	85ca                	mv	a1,s2
    80004c44:	855a                	mv	a0,s6
    80004c46:	937fc0ef          	jal	8000157c <copyout>
    80004c4a:	0e054263          	bltz	a0,80004d2e <exec+0x36c>
  p->trapframe->a1 = sp;
    80004c4e:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004c52:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004c56:	df843783          	ld	a5,-520(s0)
    80004c5a:	0007c703          	lbu	a4,0(a5)
    80004c5e:	cf11                	beqz	a4,80004c7a <exec+0x2b8>
    80004c60:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004c62:	02f00693          	li	a3,47
    80004c66:	a039                	j	80004c74 <exec+0x2b2>
      last = s+1;
    80004c68:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004c6c:	0785                	addi	a5,a5,1
    80004c6e:	fff7c703          	lbu	a4,-1(a5)
    80004c72:	c701                	beqz	a4,80004c7a <exec+0x2b8>
    if(*s == '/')
    80004c74:	fed71ce3          	bne	a4,a3,80004c6c <exec+0x2aa>
    80004c78:	bfc5                	j	80004c68 <exec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    80004c7a:	4641                	li	a2,16
    80004c7c:	df843583          	ld	a1,-520(s0)
    80004c80:	158a8513          	addi	a0,s5,344
    80004c84:	982fc0ef          	jal	80000e06 <safestrcpy>
  oldpagetable = p->pagetable;
    80004c88:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004c8c:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004c90:	e0843783          	ld	a5,-504(s0)
    80004c94:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004c98:	058ab783          	ld	a5,88(s5)
    80004c9c:	e6843703          	ld	a4,-408(s0)
    80004ca0:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004ca2:	058ab783          	ld	a5,88(s5)
    80004ca6:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004caa:	85e6                	mv	a1,s9
    80004cac:	824fd0ef          	jal	80001cd0 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004cb0:	0004851b          	sext.w	a0,s1
    80004cb4:	79be                	ld	s3,488(sp)
    80004cb6:	7a1e                	ld	s4,480(sp)
    80004cb8:	6afe                	ld	s5,472(sp)
    80004cba:	6b5e                	ld	s6,464(sp)
    80004cbc:	6bbe                	ld	s7,456(sp)
    80004cbe:	6c1e                	ld	s8,448(sp)
    80004cc0:	7cfa                	ld	s9,440(sp)
    80004cc2:	7d5a                	ld	s10,432(sp)
    80004cc4:	b3b5                	j	80004a30 <exec+0x6e>
    80004cc6:	e1243423          	sd	s2,-504(s0)
    80004cca:	7dba                	ld	s11,424(sp)
    80004ccc:	a035                	j	80004cf8 <exec+0x336>
    80004cce:	e1243423          	sd	s2,-504(s0)
    80004cd2:	7dba                	ld	s11,424(sp)
    80004cd4:	a015                	j	80004cf8 <exec+0x336>
    80004cd6:	e1243423          	sd	s2,-504(s0)
    80004cda:	7dba                	ld	s11,424(sp)
    80004cdc:	a831                	j	80004cf8 <exec+0x336>
    80004cde:	e1243423          	sd	s2,-504(s0)
    80004ce2:	7dba                	ld	s11,424(sp)
    80004ce4:	a811                	j	80004cf8 <exec+0x336>
    80004ce6:	e1243423          	sd	s2,-504(s0)
    80004cea:	7dba                	ld	s11,424(sp)
    80004cec:	a031                	j	80004cf8 <exec+0x336>
  ip = 0;
    80004cee:	4a01                	li	s4,0
    80004cf0:	a021                	j	80004cf8 <exec+0x336>
    80004cf2:	4a01                	li	s4,0
  if(pagetable)
    80004cf4:	a011                	j	80004cf8 <exec+0x336>
    80004cf6:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80004cf8:	e0843583          	ld	a1,-504(s0)
    80004cfc:	855a                	mv	a0,s6
    80004cfe:	fd3fc0ef          	jal	80001cd0 <proc_freepagetable>
  return -1;
    80004d02:	557d                	li	a0,-1
  if(ip){
    80004d04:	000a1b63          	bnez	s4,80004d1a <exec+0x358>
    80004d08:	79be                	ld	s3,488(sp)
    80004d0a:	7a1e                	ld	s4,480(sp)
    80004d0c:	6afe                	ld	s5,472(sp)
    80004d0e:	6b5e                	ld	s6,464(sp)
    80004d10:	6bbe                	ld	s7,456(sp)
    80004d12:	6c1e                	ld	s8,448(sp)
    80004d14:	7cfa                	ld	s9,440(sp)
    80004d16:	7d5a                	ld	s10,432(sp)
    80004d18:	bb21                	j	80004a30 <exec+0x6e>
    80004d1a:	79be                	ld	s3,488(sp)
    80004d1c:	6afe                	ld	s5,472(sp)
    80004d1e:	6b5e                	ld	s6,464(sp)
    80004d20:	6bbe                	ld	s7,456(sp)
    80004d22:	6c1e                	ld	s8,448(sp)
    80004d24:	7cfa                	ld	s9,440(sp)
    80004d26:	7d5a                	ld	s10,432(sp)
    80004d28:	b9ed                	j	80004a22 <exec+0x60>
    80004d2a:	6b5e                	ld	s6,464(sp)
    80004d2c:	b9dd                	j	80004a22 <exec+0x60>
  sz = sz1;
    80004d2e:	e0843983          	ld	s3,-504(s0)
    80004d32:	b595                	j	80004b96 <exec+0x1d4>

0000000080004d34 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004d34:	7179                	addi	sp,sp,-48
    80004d36:	f406                	sd	ra,40(sp)
    80004d38:	f022                	sd	s0,32(sp)
    80004d3a:	ec26                	sd	s1,24(sp)
    80004d3c:	e84a                	sd	s2,16(sp)
    80004d3e:	1800                	addi	s0,sp,48
    80004d40:	892e                	mv	s2,a1
    80004d42:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004d44:	fdc40593          	addi	a1,s0,-36
    80004d48:	e6dfd0ef          	jal	80002bb4 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004d4c:	fdc42703          	lw	a4,-36(s0)
    80004d50:	47bd                	li	a5,15
    80004d52:	02e7e963          	bltu	a5,a4,80004d84 <argfd+0x50>
    80004d56:	badfc0ef          	jal	80001902 <myproc>
    80004d5a:	fdc42703          	lw	a4,-36(s0)
    80004d5e:	01a70793          	addi	a5,a4,26
    80004d62:	078e                	slli	a5,a5,0x3
    80004d64:	953e                	add	a0,a0,a5
    80004d66:	611c                	ld	a5,0(a0)
    80004d68:	c385                	beqz	a5,80004d88 <argfd+0x54>
    return -1;
  if(pfd)
    80004d6a:	00090463          	beqz	s2,80004d72 <argfd+0x3e>
    *pfd = fd;
    80004d6e:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004d72:	4501                	li	a0,0
  if(pf)
    80004d74:	c091                	beqz	s1,80004d78 <argfd+0x44>
    *pf = f;
    80004d76:	e09c                	sd	a5,0(s1)
}
    80004d78:	70a2                	ld	ra,40(sp)
    80004d7a:	7402                	ld	s0,32(sp)
    80004d7c:	64e2                	ld	s1,24(sp)
    80004d7e:	6942                	ld	s2,16(sp)
    80004d80:	6145                	addi	sp,sp,48
    80004d82:	8082                	ret
    return -1;
    80004d84:	557d                	li	a0,-1
    80004d86:	bfcd                	j	80004d78 <argfd+0x44>
    80004d88:	557d                	li	a0,-1
    80004d8a:	b7fd                	j	80004d78 <argfd+0x44>

0000000080004d8c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004d8c:	1101                	addi	sp,sp,-32
    80004d8e:	ec06                	sd	ra,24(sp)
    80004d90:	e822                	sd	s0,16(sp)
    80004d92:	e426                	sd	s1,8(sp)
    80004d94:	1000                	addi	s0,sp,32
    80004d96:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004d98:	b6bfc0ef          	jal	80001902 <myproc>
    80004d9c:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004d9e:	0d050793          	addi	a5,a0,208
    80004da2:	4501                	li	a0,0
    80004da4:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004da6:	6398                	ld	a4,0(a5)
    80004da8:	cb19                	beqz	a4,80004dbe <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004daa:	2505                	addiw	a0,a0,1
    80004dac:	07a1                	addi	a5,a5,8
    80004dae:	fed51ce3          	bne	a0,a3,80004da6 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004db2:	557d                	li	a0,-1
}
    80004db4:	60e2                	ld	ra,24(sp)
    80004db6:	6442                	ld	s0,16(sp)
    80004db8:	64a2                	ld	s1,8(sp)
    80004dba:	6105                	addi	sp,sp,32
    80004dbc:	8082                	ret
      p->ofile[fd] = f;
    80004dbe:	01a50793          	addi	a5,a0,26
    80004dc2:	078e                	slli	a5,a5,0x3
    80004dc4:	963e                	add	a2,a2,a5
    80004dc6:	e204                	sd	s1,0(a2)
      return fd;
    80004dc8:	b7f5                	j	80004db4 <fdalloc+0x28>

0000000080004dca <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004dca:	715d                	addi	sp,sp,-80
    80004dcc:	e486                	sd	ra,72(sp)
    80004dce:	e0a2                	sd	s0,64(sp)
    80004dd0:	fc26                	sd	s1,56(sp)
    80004dd2:	f84a                	sd	s2,48(sp)
    80004dd4:	f44e                	sd	s3,40(sp)
    80004dd6:	ec56                	sd	s5,24(sp)
    80004dd8:	e85a                	sd	s6,16(sp)
    80004dda:	0880                	addi	s0,sp,80
    80004ddc:	8b2e                	mv	s6,a1
    80004dde:	89b2                	mv	s3,a2
    80004de0:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004de2:	fb040593          	addi	a1,s0,-80
    80004de6:	fcffe0ef          	jal	80003db4 <nameiparent>
    80004dea:	84aa                	mv	s1,a0
    80004dec:	10050a63          	beqz	a0,80004f00 <create+0x136>
    return 0;

  ilock(dp);
    80004df0:	8d1fe0ef          	jal	800036c0 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004df4:	4601                	li	a2,0
    80004df6:	fb040593          	addi	a1,s0,-80
    80004dfa:	8526                	mv	a0,s1
    80004dfc:	d39fe0ef          	jal	80003b34 <dirlookup>
    80004e00:	8aaa                	mv	s5,a0
    80004e02:	c129                	beqz	a0,80004e44 <create+0x7a>
    iunlockput(dp);
    80004e04:	8526                	mv	a0,s1
    80004e06:	ac5fe0ef          	jal	800038ca <iunlockput>
    ilock(ip);
    80004e0a:	8556                	mv	a0,s5
    80004e0c:	8b5fe0ef          	jal	800036c0 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004e10:	4789                	li	a5,2
    80004e12:	02fb1463          	bne	s6,a5,80004e3a <create+0x70>
    80004e16:	044ad783          	lhu	a5,68(s5)
    80004e1a:	37f9                	addiw	a5,a5,-2
    80004e1c:	17c2                	slli	a5,a5,0x30
    80004e1e:	93c1                	srli	a5,a5,0x30
    80004e20:	4705                	li	a4,1
    80004e22:	00f76c63          	bltu	a4,a5,80004e3a <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004e26:	8556                	mv	a0,s5
    80004e28:	60a6                	ld	ra,72(sp)
    80004e2a:	6406                	ld	s0,64(sp)
    80004e2c:	74e2                	ld	s1,56(sp)
    80004e2e:	7942                	ld	s2,48(sp)
    80004e30:	79a2                	ld	s3,40(sp)
    80004e32:	6ae2                	ld	s5,24(sp)
    80004e34:	6b42                	ld	s6,16(sp)
    80004e36:	6161                	addi	sp,sp,80
    80004e38:	8082                	ret
    iunlockput(ip);
    80004e3a:	8556                	mv	a0,s5
    80004e3c:	a8ffe0ef          	jal	800038ca <iunlockput>
    return 0;
    80004e40:	4a81                	li	s5,0
    80004e42:	b7d5                	j	80004e26 <create+0x5c>
    80004e44:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80004e46:	85da                	mv	a1,s6
    80004e48:	4088                	lw	a0,0(s1)
    80004e4a:	f06fe0ef          	jal	80003550 <ialloc>
    80004e4e:	8a2a                	mv	s4,a0
    80004e50:	cd15                	beqz	a0,80004e8c <create+0xc2>
  ilock(ip);
    80004e52:	86ffe0ef          	jal	800036c0 <ilock>
  ip->major = major;
    80004e56:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004e5a:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004e5e:	4905                	li	s2,1
    80004e60:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004e64:	8552                	mv	a0,s4
    80004e66:	fa6fe0ef          	jal	8000360c <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004e6a:	032b0763          	beq	s6,s2,80004e98 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004e6e:	004a2603          	lw	a2,4(s4)
    80004e72:	fb040593          	addi	a1,s0,-80
    80004e76:	8526                	mv	a0,s1
    80004e78:	e89fe0ef          	jal	80003d00 <dirlink>
    80004e7c:	06054563          	bltz	a0,80004ee6 <create+0x11c>
  iunlockput(dp);
    80004e80:	8526                	mv	a0,s1
    80004e82:	a49fe0ef          	jal	800038ca <iunlockput>
  return ip;
    80004e86:	8ad2                	mv	s5,s4
    80004e88:	7a02                	ld	s4,32(sp)
    80004e8a:	bf71                	j	80004e26 <create+0x5c>
    iunlockput(dp);
    80004e8c:	8526                	mv	a0,s1
    80004e8e:	a3dfe0ef          	jal	800038ca <iunlockput>
    return 0;
    80004e92:	8ad2                	mv	s5,s4
    80004e94:	7a02                	ld	s4,32(sp)
    80004e96:	bf41                	j	80004e26 <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004e98:	004a2603          	lw	a2,4(s4)
    80004e9c:	00003597          	auipc	a1,0x3
    80004ea0:	93458593          	addi	a1,a1,-1740 # 800077d0 <etext+0x7d0>
    80004ea4:	8552                	mv	a0,s4
    80004ea6:	e5bfe0ef          	jal	80003d00 <dirlink>
    80004eaa:	02054e63          	bltz	a0,80004ee6 <create+0x11c>
    80004eae:	40d0                	lw	a2,4(s1)
    80004eb0:	00003597          	auipc	a1,0x3
    80004eb4:	92858593          	addi	a1,a1,-1752 # 800077d8 <etext+0x7d8>
    80004eb8:	8552                	mv	a0,s4
    80004eba:	e47fe0ef          	jal	80003d00 <dirlink>
    80004ebe:	02054463          	bltz	a0,80004ee6 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004ec2:	004a2603          	lw	a2,4(s4)
    80004ec6:	fb040593          	addi	a1,s0,-80
    80004eca:	8526                	mv	a0,s1
    80004ecc:	e35fe0ef          	jal	80003d00 <dirlink>
    80004ed0:	00054b63          	bltz	a0,80004ee6 <create+0x11c>
    dp->nlink++;  // for ".."
    80004ed4:	04a4d783          	lhu	a5,74(s1)
    80004ed8:	2785                	addiw	a5,a5,1
    80004eda:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004ede:	8526                	mv	a0,s1
    80004ee0:	f2cfe0ef          	jal	8000360c <iupdate>
    80004ee4:	bf71                	j	80004e80 <create+0xb6>
  ip->nlink = 0;
    80004ee6:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004eea:	8552                	mv	a0,s4
    80004eec:	f20fe0ef          	jal	8000360c <iupdate>
  iunlockput(ip);
    80004ef0:	8552                	mv	a0,s4
    80004ef2:	9d9fe0ef          	jal	800038ca <iunlockput>
  iunlockput(dp);
    80004ef6:	8526                	mv	a0,s1
    80004ef8:	9d3fe0ef          	jal	800038ca <iunlockput>
  return 0;
    80004efc:	7a02                	ld	s4,32(sp)
    80004efe:	b725                	j	80004e26 <create+0x5c>
    return 0;
    80004f00:	8aaa                	mv	s5,a0
    80004f02:	b715                	j	80004e26 <create+0x5c>

0000000080004f04 <sys_dup>:
{
    80004f04:	7179                	addi	sp,sp,-48
    80004f06:	f406                	sd	ra,40(sp)
    80004f08:	f022                	sd	s0,32(sp)
    80004f0a:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004f0c:	fd840613          	addi	a2,s0,-40
    80004f10:	4581                	li	a1,0
    80004f12:	4501                	li	a0,0
    80004f14:	e21ff0ef          	jal	80004d34 <argfd>
    return -1;
    80004f18:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004f1a:	02054363          	bltz	a0,80004f40 <sys_dup+0x3c>
    80004f1e:	ec26                	sd	s1,24(sp)
    80004f20:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004f22:	fd843903          	ld	s2,-40(s0)
    80004f26:	854a                	mv	a0,s2
    80004f28:	e65ff0ef          	jal	80004d8c <fdalloc>
    80004f2c:	84aa                	mv	s1,a0
    return -1;
    80004f2e:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004f30:	00054d63          	bltz	a0,80004f4a <sys_dup+0x46>
  filedup(f);
    80004f34:	854a                	mv	a0,s2
    80004f36:	c48ff0ef          	jal	8000437e <filedup>
  return fd;
    80004f3a:	87a6                	mv	a5,s1
    80004f3c:	64e2                	ld	s1,24(sp)
    80004f3e:	6942                	ld	s2,16(sp)
}
    80004f40:	853e                	mv	a0,a5
    80004f42:	70a2                	ld	ra,40(sp)
    80004f44:	7402                	ld	s0,32(sp)
    80004f46:	6145                	addi	sp,sp,48
    80004f48:	8082                	ret
    80004f4a:	64e2                	ld	s1,24(sp)
    80004f4c:	6942                	ld	s2,16(sp)
    80004f4e:	bfcd                	j	80004f40 <sys_dup+0x3c>

0000000080004f50 <sys_read>:
{
    80004f50:	7179                	addi	sp,sp,-48
    80004f52:	f406                	sd	ra,40(sp)
    80004f54:	f022                	sd	s0,32(sp)
    80004f56:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004f58:	fd840593          	addi	a1,s0,-40
    80004f5c:	4505                	li	a0,1
    80004f5e:	c73fd0ef          	jal	80002bd0 <argaddr>
  argint(2, &n);
    80004f62:	fe440593          	addi	a1,s0,-28
    80004f66:	4509                	li	a0,2
    80004f68:	c4dfd0ef          	jal	80002bb4 <argint>
  if(argfd(0, 0, &f) < 0)
    80004f6c:	fe840613          	addi	a2,s0,-24
    80004f70:	4581                	li	a1,0
    80004f72:	4501                	li	a0,0
    80004f74:	dc1ff0ef          	jal	80004d34 <argfd>
    80004f78:	87aa                	mv	a5,a0
    return -1;
    80004f7a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004f7c:	0007ca63          	bltz	a5,80004f90 <sys_read+0x40>
  return fileread(f, p, n);
    80004f80:	fe442603          	lw	a2,-28(s0)
    80004f84:	fd843583          	ld	a1,-40(s0)
    80004f88:	fe843503          	ld	a0,-24(s0)
    80004f8c:	d58ff0ef          	jal	800044e4 <fileread>
}
    80004f90:	70a2                	ld	ra,40(sp)
    80004f92:	7402                	ld	s0,32(sp)
    80004f94:	6145                	addi	sp,sp,48
    80004f96:	8082                	ret

0000000080004f98 <sys_write>:
{
    80004f98:	7179                	addi	sp,sp,-48
    80004f9a:	f406                	sd	ra,40(sp)
    80004f9c:	f022                	sd	s0,32(sp)
    80004f9e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004fa0:	fd840593          	addi	a1,s0,-40
    80004fa4:	4505                	li	a0,1
    80004fa6:	c2bfd0ef          	jal	80002bd0 <argaddr>
  argint(2, &n);
    80004faa:	fe440593          	addi	a1,s0,-28
    80004fae:	4509                	li	a0,2
    80004fb0:	c05fd0ef          	jal	80002bb4 <argint>
  if(argfd(0, 0, &f) < 0)
    80004fb4:	fe840613          	addi	a2,s0,-24
    80004fb8:	4581                	li	a1,0
    80004fba:	4501                	li	a0,0
    80004fbc:	d79ff0ef          	jal	80004d34 <argfd>
    80004fc0:	87aa                	mv	a5,a0
    return -1;
    80004fc2:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004fc4:	0007ca63          	bltz	a5,80004fd8 <sys_write+0x40>
  return filewrite(f, p, n);
    80004fc8:	fe442603          	lw	a2,-28(s0)
    80004fcc:	fd843583          	ld	a1,-40(s0)
    80004fd0:	fe843503          	ld	a0,-24(s0)
    80004fd4:	dceff0ef          	jal	800045a2 <filewrite>
}
    80004fd8:	70a2                	ld	ra,40(sp)
    80004fda:	7402                	ld	s0,32(sp)
    80004fdc:	6145                	addi	sp,sp,48
    80004fde:	8082                	ret

0000000080004fe0 <sys_close>:
{
    80004fe0:	1101                	addi	sp,sp,-32
    80004fe2:	ec06                	sd	ra,24(sp)
    80004fe4:	e822                	sd	s0,16(sp)
    80004fe6:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004fe8:	fe040613          	addi	a2,s0,-32
    80004fec:	fec40593          	addi	a1,s0,-20
    80004ff0:	4501                	li	a0,0
    80004ff2:	d43ff0ef          	jal	80004d34 <argfd>
    return -1;
    80004ff6:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004ff8:	02054063          	bltz	a0,80005018 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004ffc:	907fc0ef          	jal	80001902 <myproc>
    80005000:	fec42783          	lw	a5,-20(s0)
    80005004:	07e9                	addi	a5,a5,26
    80005006:	078e                	slli	a5,a5,0x3
    80005008:	953e                	add	a0,a0,a5
    8000500a:	00053023          	sd	zero,0(a0)
  fileclose(f);
    8000500e:	fe043503          	ld	a0,-32(s0)
    80005012:	bb2ff0ef          	jal	800043c4 <fileclose>
  return 0;
    80005016:	4781                	li	a5,0
}
    80005018:	853e                	mv	a0,a5
    8000501a:	60e2                	ld	ra,24(sp)
    8000501c:	6442                	ld	s0,16(sp)
    8000501e:	6105                	addi	sp,sp,32
    80005020:	8082                	ret

0000000080005022 <sys_fstat>:
{
    80005022:	1101                	addi	sp,sp,-32
    80005024:	ec06                	sd	ra,24(sp)
    80005026:	e822                	sd	s0,16(sp)
    80005028:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000502a:	fe040593          	addi	a1,s0,-32
    8000502e:	4505                	li	a0,1
    80005030:	ba1fd0ef          	jal	80002bd0 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005034:	fe840613          	addi	a2,s0,-24
    80005038:	4581                	li	a1,0
    8000503a:	4501                	li	a0,0
    8000503c:	cf9ff0ef          	jal	80004d34 <argfd>
    80005040:	87aa                	mv	a5,a0
    return -1;
    80005042:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005044:	0007c863          	bltz	a5,80005054 <sys_fstat+0x32>
  return filestat(f, st);
    80005048:	fe043583          	ld	a1,-32(s0)
    8000504c:	fe843503          	ld	a0,-24(s0)
    80005050:	c36ff0ef          	jal	80004486 <filestat>
}
    80005054:	60e2                	ld	ra,24(sp)
    80005056:	6442                	ld	s0,16(sp)
    80005058:	6105                	addi	sp,sp,32
    8000505a:	8082                	ret

000000008000505c <sys_link>:
{
    8000505c:	7169                	addi	sp,sp,-304
    8000505e:	f606                	sd	ra,296(sp)
    80005060:	f222                	sd	s0,288(sp)
    80005062:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005064:	08000613          	li	a2,128
    80005068:	ed040593          	addi	a1,s0,-304
    8000506c:	4501                	li	a0,0
    8000506e:	b7ffd0ef          	jal	80002bec <argstr>
    return -1;
    80005072:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005074:	0c054e63          	bltz	a0,80005150 <sys_link+0xf4>
    80005078:	08000613          	li	a2,128
    8000507c:	f5040593          	addi	a1,s0,-176
    80005080:	4505                	li	a0,1
    80005082:	b6bfd0ef          	jal	80002bec <argstr>
    return -1;
    80005086:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005088:	0c054463          	bltz	a0,80005150 <sys_link+0xf4>
    8000508c:	ee26                	sd	s1,280(sp)
  begin_op();
    8000508e:	ec9fe0ef          	jal	80003f56 <begin_op>
  if((ip = namei(old)) == 0){
    80005092:	ed040513          	addi	a0,s0,-304
    80005096:	d05fe0ef          	jal	80003d9a <namei>
    8000509a:	84aa                	mv	s1,a0
    8000509c:	c53d                	beqz	a0,8000510a <sys_link+0xae>
  ilock(ip);
    8000509e:	e22fe0ef          	jal	800036c0 <ilock>
  if(ip->type == T_DIR){
    800050a2:	04449703          	lh	a4,68(s1)
    800050a6:	4785                	li	a5,1
    800050a8:	06f70663          	beq	a4,a5,80005114 <sys_link+0xb8>
    800050ac:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    800050ae:	04a4d783          	lhu	a5,74(s1)
    800050b2:	2785                	addiw	a5,a5,1
    800050b4:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800050b8:	8526                	mv	a0,s1
    800050ba:	d52fe0ef          	jal	8000360c <iupdate>
  iunlock(ip);
    800050be:	8526                	mv	a0,s1
    800050c0:	eaefe0ef          	jal	8000376e <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800050c4:	fd040593          	addi	a1,s0,-48
    800050c8:	f5040513          	addi	a0,s0,-176
    800050cc:	ce9fe0ef          	jal	80003db4 <nameiparent>
    800050d0:	892a                	mv	s2,a0
    800050d2:	cd21                	beqz	a0,8000512a <sys_link+0xce>
  ilock(dp);
    800050d4:	decfe0ef          	jal	800036c0 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800050d8:	00092703          	lw	a4,0(s2)
    800050dc:	409c                	lw	a5,0(s1)
    800050de:	04f71363          	bne	a4,a5,80005124 <sys_link+0xc8>
    800050e2:	40d0                	lw	a2,4(s1)
    800050e4:	fd040593          	addi	a1,s0,-48
    800050e8:	854a                	mv	a0,s2
    800050ea:	c17fe0ef          	jal	80003d00 <dirlink>
    800050ee:	02054b63          	bltz	a0,80005124 <sys_link+0xc8>
  iunlockput(dp);
    800050f2:	854a                	mv	a0,s2
    800050f4:	fd6fe0ef          	jal	800038ca <iunlockput>
  iput(ip);
    800050f8:	8526                	mv	a0,s1
    800050fa:	f48fe0ef          	jal	80003842 <iput>
  end_op();
    800050fe:	ec3fe0ef          	jal	80003fc0 <end_op>
  return 0;
    80005102:	4781                	li	a5,0
    80005104:	64f2                	ld	s1,280(sp)
    80005106:	6952                	ld	s2,272(sp)
    80005108:	a0a1                	j	80005150 <sys_link+0xf4>
    end_op();
    8000510a:	eb7fe0ef          	jal	80003fc0 <end_op>
    return -1;
    8000510e:	57fd                	li	a5,-1
    80005110:	64f2                	ld	s1,280(sp)
    80005112:	a83d                	j	80005150 <sys_link+0xf4>
    iunlockput(ip);
    80005114:	8526                	mv	a0,s1
    80005116:	fb4fe0ef          	jal	800038ca <iunlockput>
    end_op();
    8000511a:	ea7fe0ef          	jal	80003fc0 <end_op>
    return -1;
    8000511e:	57fd                	li	a5,-1
    80005120:	64f2                	ld	s1,280(sp)
    80005122:	a03d                	j	80005150 <sys_link+0xf4>
    iunlockput(dp);
    80005124:	854a                	mv	a0,s2
    80005126:	fa4fe0ef          	jal	800038ca <iunlockput>
  ilock(ip);
    8000512a:	8526                	mv	a0,s1
    8000512c:	d94fe0ef          	jal	800036c0 <ilock>
  ip->nlink--;
    80005130:	04a4d783          	lhu	a5,74(s1)
    80005134:	37fd                	addiw	a5,a5,-1
    80005136:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000513a:	8526                	mv	a0,s1
    8000513c:	cd0fe0ef          	jal	8000360c <iupdate>
  iunlockput(ip);
    80005140:	8526                	mv	a0,s1
    80005142:	f88fe0ef          	jal	800038ca <iunlockput>
  end_op();
    80005146:	e7bfe0ef          	jal	80003fc0 <end_op>
  return -1;
    8000514a:	57fd                	li	a5,-1
    8000514c:	64f2                	ld	s1,280(sp)
    8000514e:	6952                	ld	s2,272(sp)
}
    80005150:	853e                	mv	a0,a5
    80005152:	70b2                	ld	ra,296(sp)
    80005154:	7412                	ld	s0,288(sp)
    80005156:	6155                	addi	sp,sp,304
    80005158:	8082                	ret

000000008000515a <sys_unlink>:
{
    8000515a:	7151                	addi	sp,sp,-240
    8000515c:	f586                	sd	ra,232(sp)
    8000515e:	f1a2                	sd	s0,224(sp)
    80005160:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005162:	08000613          	li	a2,128
    80005166:	f3040593          	addi	a1,s0,-208
    8000516a:	4501                	li	a0,0
    8000516c:	a81fd0ef          	jal	80002bec <argstr>
    80005170:	16054063          	bltz	a0,800052d0 <sys_unlink+0x176>
    80005174:	eda6                	sd	s1,216(sp)
  begin_op();
    80005176:	de1fe0ef          	jal	80003f56 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000517a:	fb040593          	addi	a1,s0,-80
    8000517e:	f3040513          	addi	a0,s0,-208
    80005182:	c33fe0ef          	jal	80003db4 <nameiparent>
    80005186:	84aa                	mv	s1,a0
    80005188:	c945                	beqz	a0,80005238 <sys_unlink+0xde>
  ilock(dp);
    8000518a:	d36fe0ef          	jal	800036c0 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000518e:	00002597          	auipc	a1,0x2
    80005192:	64258593          	addi	a1,a1,1602 # 800077d0 <etext+0x7d0>
    80005196:	fb040513          	addi	a0,s0,-80
    8000519a:	985fe0ef          	jal	80003b1e <namecmp>
    8000519e:	10050e63          	beqz	a0,800052ba <sys_unlink+0x160>
    800051a2:	00002597          	auipc	a1,0x2
    800051a6:	63658593          	addi	a1,a1,1590 # 800077d8 <etext+0x7d8>
    800051aa:	fb040513          	addi	a0,s0,-80
    800051ae:	971fe0ef          	jal	80003b1e <namecmp>
    800051b2:	10050463          	beqz	a0,800052ba <sys_unlink+0x160>
    800051b6:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    800051b8:	f2c40613          	addi	a2,s0,-212
    800051bc:	fb040593          	addi	a1,s0,-80
    800051c0:	8526                	mv	a0,s1
    800051c2:	973fe0ef          	jal	80003b34 <dirlookup>
    800051c6:	892a                	mv	s2,a0
    800051c8:	0e050863          	beqz	a0,800052b8 <sys_unlink+0x15e>
  ilock(ip);
    800051cc:	cf4fe0ef          	jal	800036c0 <ilock>
  if(ip->nlink < 1)
    800051d0:	04a91783          	lh	a5,74(s2)
    800051d4:	06f05763          	blez	a5,80005242 <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800051d8:	04491703          	lh	a4,68(s2)
    800051dc:	4785                	li	a5,1
    800051de:	06f70963          	beq	a4,a5,80005250 <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    800051e2:	4641                	li	a2,16
    800051e4:	4581                	li	a1,0
    800051e6:	fc040513          	addi	a0,s0,-64
    800051ea:	adffb0ef          	jal	80000cc8 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800051ee:	4741                	li	a4,16
    800051f0:	f2c42683          	lw	a3,-212(s0)
    800051f4:	fc040613          	addi	a2,s0,-64
    800051f8:	4581                	li	a1,0
    800051fa:	8526                	mv	a0,s1
    800051fc:	815fe0ef          	jal	80003a10 <writei>
    80005200:	47c1                	li	a5,16
    80005202:	08f51b63          	bne	a0,a5,80005298 <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    80005206:	04491703          	lh	a4,68(s2)
    8000520a:	4785                	li	a5,1
    8000520c:	08f70d63          	beq	a4,a5,800052a6 <sys_unlink+0x14c>
  iunlockput(dp);
    80005210:	8526                	mv	a0,s1
    80005212:	eb8fe0ef          	jal	800038ca <iunlockput>
  ip->nlink--;
    80005216:	04a95783          	lhu	a5,74(s2)
    8000521a:	37fd                	addiw	a5,a5,-1
    8000521c:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005220:	854a                	mv	a0,s2
    80005222:	beafe0ef          	jal	8000360c <iupdate>
  iunlockput(ip);
    80005226:	854a                	mv	a0,s2
    80005228:	ea2fe0ef          	jal	800038ca <iunlockput>
  end_op();
    8000522c:	d95fe0ef          	jal	80003fc0 <end_op>
  return 0;
    80005230:	4501                	li	a0,0
    80005232:	64ee                	ld	s1,216(sp)
    80005234:	694e                	ld	s2,208(sp)
    80005236:	a849                	j	800052c8 <sys_unlink+0x16e>
    end_op();
    80005238:	d89fe0ef          	jal	80003fc0 <end_op>
    return -1;
    8000523c:	557d                	li	a0,-1
    8000523e:	64ee                	ld	s1,216(sp)
    80005240:	a061                	j	800052c8 <sys_unlink+0x16e>
    80005242:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80005244:	00002517          	auipc	a0,0x2
    80005248:	59c50513          	addi	a0,a0,1436 # 800077e0 <etext+0x7e0>
    8000524c:	d48fb0ef          	jal	80000794 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005250:	04c92703          	lw	a4,76(s2)
    80005254:	02000793          	li	a5,32
    80005258:	f8e7f5e3          	bgeu	a5,a4,800051e2 <sys_unlink+0x88>
    8000525c:	e5ce                	sd	s3,200(sp)
    8000525e:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005262:	4741                	li	a4,16
    80005264:	86ce                	mv	a3,s3
    80005266:	f1840613          	addi	a2,s0,-232
    8000526a:	4581                	li	a1,0
    8000526c:	854a                	mv	a0,s2
    8000526e:	ea6fe0ef          	jal	80003914 <readi>
    80005272:	47c1                	li	a5,16
    80005274:	00f51c63          	bne	a0,a5,8000528c <sys_unlink+0x132>
    if(de.inum != 0)
    80005278:	f1845783          	lhu	a5,-232(s0)
    8000527c:	efa1                	bnez	a5,800052d4 <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000527e:	29c1                	addiw	s3,s3,16
    80005280:	04c92783          	lw	a5,76(s2)
    80005284:	fcf9efe3          	bltu	s3,a5,80005262 <sys_unlink+0x108>
    80005288:	69ae                	ld	s3,200(sp)
    8000528a:	bfa1                	j	800051e2 <sys_unlink+0x88>
      panic("isdirempty: readi");
    8000528c:	00002517          	auipc	a0,0x2
    80005290:	56c50513          	addi	a0,a0,1388 # 800077f8 <etext+0x7f8>
    80005294:	d00fb0ef          	jal	80000794 <panic>
    80005298:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    8000529a:	00002517          	auipc	a0,0x2
    8000529e:	57650513          	addi	a0,a0,1398 # 80007810 <etext+0x810>
    800052a2:	cf2fb0ef          	jal	80000794 <panic>
    dp->nlink--;
    800052a6:	04a4d783          	lhu	a5,74(s1)
    800052aa:	37fd                	addiw	a5,a5,-1
    800052ac:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800052b0:	8526                	mv	a0,s1
    800052b2:	b5afe0ef          	jal	8000360c <iupdate>
    800052b6:	bfa9                	j	80005210 <sys_unlink+0xb6>
    800052b8:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    800052ba:	8526                	mv	a0,s1
    800052bc:	e0efe0ef          	jal	800038ca <iunlockput>
  end_op();
    800052c0:	d01fe0ef          	jal	80003fc0 <end_op>
  return -1;
    800052c4:	557d                	li	a0,-1
    800052c6:	64ee                	ld	s1,216(sp)
}
    800052c8:	70ae                	ld	ra,232(sp)
    800052ca:	740e                	ld	s0,224(sp)
    800052cc:	616d                	addi	sp,sp,240
    800052ce:	8082                	ret
    return -1;
    800052d0:	557d                	li	a0,-1
    800052d2:	bfdd                	j	800052c8 <sys_unlink+0x16e>
    iunlockput(ip);
    800052d4:	854a                	mv	a0,s2
    800052d6:	df4fe0ef          	jal	800038ca <iunlockput>
    goto bad;
    800052da:	694e                	ld	s2,208(sp)
    800052dc:	69ae                	ld	s3,200(sp)
    800052de:	bff1                	j	800052ba <sys_unlink+0x160>

00000000800052e0 <sys_open>:

uint64
sys_open(void)
{
    800052e0:	7131                	addi	sp,sp,-192
    800052e2:	fd06                	sd	ra,184(sp)
    800052e4:	f922                	sd	s0,176(sp)
    800052e6:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800052e8:	f4c40593          	addi	a1,s0,-180
    800052ec:	4505                	li	a0,1
    800052ee:	8c7fd0ef          	jal	80002bb4 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800052f2:	08000613          	li	a2,128
    800052f6:	f5040593          	addi	a1,s0,-176
    800052fa:	4501                	li	a0,0
    800052fc:	8f1fd0ef          	jal	80002bec <argstr>
    80005300:	87aa                	mv	a5,a0
    return -1;
    80005302:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005304:	0a07c263          	bltz	a5,800053a8 <sys_open+0xc8>
    80005308:	f526                	sd	s1,168(sp)

  begin_op();
    8000530a:	c4dfe0ef          	jal	80003f56 <begin_op>

  if(omode & O_CREATE){
    8000530e:	f4c42783          	lw	a5,-180(s0)
    80005312:	2007f793          	andi	a5,a5,512
    80005316:	c3d5                	beqz	a5,800053ba <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80005318:	4681                	li	a3,0
    8000531a:	4601                	li	a2,0
    8000531c:	4589                	li	a1,2
    8000531e:	f5040513          	addi	a0,s0,-176
    80005322:	aa9ff0ef          	jal	80004dca <create>
    80005326:	84aa                	mv	s1,a0
    if(ip == 0){
    80005328:	c541                	beqz	a0,800053b0 <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000532a:	04449703          	lh	a4,68(s1)
    8000532e:	478d                	li	a5,3
    80005330:	00f71763          	bne	a4,a5,8000533e <sys_open+0x5e>
    80005334:	0464d703          	lhu	a4,70(s1)
    80005338:	47a5                	li	a5,9
    8000533a:	0ae7ed63          	bltu	a5,a4,800053f4 <sys_open+0x114>
    8000533e:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005340:	fe1fe0ef          	jal	80004320 <filealloc>
    80005344:	892a                	mv	s2,a0
    80005346:	c179                	beqz	a0,8000540c <sys_open+0x12c>
    80005348:	ed4e                	sd	s3,152(sp)
    8000534a:	a43ff0ef          	jal	80004d8c <fdalloc>
    8000534e:	89aa                	mv	s3,a0
    80005350:	0a054a63          	bltz	a0,80005404 <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005354:	04449703          	lh	a4,68(s1)
    80005358:	478d                	li	a5,3
    8000535a:	0cf70263          	beq	a4,a5,8000541e <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000535e:	4789                	li	a5,2
    80005360:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005364:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005368:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    8000536c:	f4c42783          	lw	a5,-180(s0)
    80005370:	0017c713          	xori	a4,a5,1
    80005374:	8b05                	andi	a4,a4,1
    80005376:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000537a:	0037f713          	andi	a4,a5,3
    8000537e:	00e03733          	snez	a4,a4
    80005382:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005386:	4007f793          	andi	a5,a5,1024
    8000538a:	c791                	beqz	a5,80005396 <sys_open+0xb6>
    8000538c:	04449703          	lh	a4,68(s1)
    80005390:	4789                	li	a5,2
    80005392:	08f70d63          	beq	a4,a5,8000542c <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    80005396:	8526                	mv	a0,s1
    80005398:	bd6fe0ef          	jal	8000376e <iunlock>
  end_op();
    8000539c:	c25fe0ef          	jal	80003fc0 <end_op>

  return fd;
    800053a0:	854e                	mv	a0,s3
    800053a2:	74aa                	ld	s1,168(sp)
    800053a4:	790a                	ld	s2,160(sp)
    800053a6:	69ea                	ld	s3,152(sp)
}
    800053a8:	70ea                	ld	ra,184(sp)
    800053aa:	744a                	ld	s0,176(sp)
    800053ac:	6129                	addi	sp,sp,192
    800053ae:	8082                	ret
      end_op();
    800053b0:	c11fe0ef          	jal	80003fc0 <end_op>
      return -1;
    800053b4:	557d                	li	a0,-1
    800053b6:	74aa                	ld	s1,168(sp)
    800053b8:	bfc5                	j	800053a8 <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    800053ba:	f5040513          	addi	a0,s0,-176
    800053be:	9ddfe0ef          	jal	80003d9a <namei>
    800053c2:	84aa                	mv	s1,a0
    800053c4:	c11d                	beqz	a0,800053ea <sys_open+0x10a>
    ilock(ip);
    800053c6:	afafe0ef          	jal	800036c0 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800053ca:	04449703          	lh	a4,68(s1)
    800053ce:	4785                	li	a5,1
    800053d0:	f4f71de3          	bne	a4,a5,8000532a <sys_open+0x4a>
    800053d4:	f4c42783          	lw	a5,-180(s0)
    800053d8:	d3bd                	beqz	a5,8000533e <sys_open+0x5e>
      iunlockput(ip);
    800053da:	8526                	mv	a0,s1
    800053dc:	ceefe0ef          	jal	800038ca <iunlockput>
      end_op();
    800053e0:	be1fe0ef          	jal	80003fc0 <end_op>
      return -1;
    800053e4:	557d                	li	a0,-1
    800053e6:	74aa                	ld	s1,168(sp)
    800053e8:	b7c1                	j	800053a8 <sys_open+0xc8>
      end_op();
    800053ea:	bd7fe0ef          	jal	80003fc0 <end_op>
      return -1;
    800053ee:	557d                	li	a0,-1
    800053f0:	74aa                	ld	s1,168(sp)
    800053f2:	bf5d                	j	800053a8 <sys_open+0xc8>
    iunlockput(ip);
    800053f4:	8526                	mv	a0,s1
    800053f6:	cd4fe0ef          	jal	800038ca <iunlockput>
    end_op();
    800053fa:	bc7fe0ef          	jal	80003fc0 <end_op>
    return -1;
    800053fe:	557d                	li	a0,-1
    80005400:	74aa                	ld	s1,168(sp)
    80005402:	b75d                	j	800053a8 <sys_open+0xc8>
      fileclose(f);
    80005404:	854a                	mv	a0,s2
    80005406:	fbffe0ef          	jal	800043c4 <fileclose>
    8000540a:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    8000540c:	8526                	mv	a0,s1
    8000540e:	cbcfe0ef          	jal	800038ca <iunlockput>
    end_op();
    80005412:	baffe0ef          	jal	80003fc0 <end_op>
    return -1;
    80005416:	557d                	li	a0,-1
    80005418:	74aa                	ld	s1,168(sp)
    8000541a:	790a                	ld	s2,160(sp)
    8000541c:	b771                	j	800053a8 <sys_open+0xc8>
    f->type = FD_DEVICE;
    8000541e:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005422:	04649783          	lh	a5,70(s1)
    80005426:	02f91223          	sh	a5,36(s2)
    8000542a:	bf3d                	j	80005368 <sys_open+0x88>
    itrunc(ip);
    8000542c:	8526                	mv	a0,s1
    8000542e:	b80fe0ef          	jal	800037ae <itrunc>
    80005432:	b795                	j	80005396 <sys_open+0xb6>

0000000080005434 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005434:	7175                	addi	sp,sp,-144
    80005436:	e506                	sd	ra,136(sp)
    80005438:	e122                	sd	s0,128(sp)
    8000543a:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000543c:	b1bfe0ef          	jal	80003f56 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005440:	08000613          	li	a2,128
    80005444:	f7040593          	addi	a1,s0,-144
    80005448:	4501                	li	a0,0
    8000544a:	fa2fd0ef          	jal	80002bec <argstr>
    8000544e:	02054363          	bltz	a0,80005474 <sys_mkdir+0x40>
    80005452:	4681                	li	a3,0
    80005454:	4601                	li	a2,0
    80005456:	4585                	li	a1,1
    80005458:	f7040513          	addi	a0,s0,-144
    8000545c:	96fff0ef          	jal	80004dca <create>
    80005460:	c911                	beqz	a0,80005474 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005462:	c68fe0ef          	jal	800038ca <iunlockput>
  end_op();
    80005466:	b5bfe0ef          	jal	80003fc0 <end_op>
  return 0;
    8000546a:	4501                	li	a0,0
}
    8000546c:	60aa                	ld	ra,136(sp)
    8000546e:	640a                	ld	s0,128(sp)
    80005470:	6149                	addi	sp,sp,144
    80005472:	8082                	ret
    end_op();
    80005474:	b4dfe0ef          	jal	80003fc0 <end_op>
    return -1;
    80005478:	557d                	li	a0,-1
    8000547a:	bfcd                	j	8000546c <sys_mkdir+0x38>

000000008000547c <sys_mknod>:

uint64
sys_mknod(void)
{
    8000547c:	7135                	addi	sp,sp,-160
    8000547e:	ed06                	sd	ra,152(sp)
    80005480:	e922                	sd	s0,144(sp)
    80005482:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005484:	ad3fe0ef          	jal	80003f56 <begin_op>
  argint(1, &major);
    80005488:	f6c40593          	addi	a1,s0,-148
    8000548c:	4505                	li	a0,1
    8000548e:	f26fd0ef          	jal	80002bb4 <argint>
  argint(2, &minor);
    80005492:	f6840593          	addi	a1,s0,-152
    80005496:	4509                	li	a0,2
    80005498:	f1cfd0ef          	jal	80002bb4 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000549c:	08000613          	li	a2,128
    800054a0:	f7040593          	addi	a1,s0,-144
    800054a4:	4501                	li	a0,0
    800054a6:	f46fd0ef          	jal	80002bec <argstr>
    800054aa:	02054563          	bltz	a0,800054d4 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800054ae:	f6841683          	lh	a3,-152(s0)
    800054b2:	f6c41603          	lh	a2,-148(s0)
    800054b6:	458d                	li	a1,3
    800054b8:	f7040513          	addi	a0,s0,-144
    800054bc:	90fff0ef          	jal	80004dca <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800054c0:	c911                	beqz	a0,800054d4 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800054c2:	c08fe0ef          	jal	800038ca <iunlockput>
  end_op();
    800054c6:	afbfe0ef          	jal	80003fc0 <end_op>
  return 0;
    800054ca:	4501                	li	a0,0
}
    800054cc:	60ea                	ld	ra,152(sp)
    800054ce:	644a                	ld	s0,144(sp)
    800054d0:	610d                	addi	sp,sp,160
    800054d2:	8082                	ret
    end_op();
    800054d4:	aedfe0ef          	jal	80003fc0 <end_op>
    return -1;
    800054d8:	557d                	li	a0,-1
    800054da:	bfcd                	j	800054cc <sys_mknod+0x50>

00000000800054dc <sys_chdir>:

uint64
sys_chdir(void)
{
    800054dc:	7135                	addi	sp,sp,-160
    800054de:	ed06                	sd	ra,152(sp)
    800054e0:	e922                	sd	s0,144(sp)
    800054e2:	e14a                	sd	s2,128(sp)
    800054e4:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800054e6:	c1cfc0ef          	jal	80001902 <myproc>
    800054ea:	892a                	mv	s2,a0
  
  begin_op();
    800054ec:	a6bfe0ef          	jal	80003f56 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800054f0:	08000613          	li	a2,128
    800054f4:	f6040593          	addi	a1,s0,-160
    800054f8:	4501                	li	a0,0
    800054fa:	ef2fd0ef          	jal	80002bec <argstr>
    800054fe:	04054363          	bltz	a0,80005544 <sys_chdir+0x68>
    80005502:	e526                	sd	s1,136(sp)
    80005504:	f6040513          	addi	a0,s0,-160
    80005508:	893fe0ef          	jal	80003d9a <namei>
    8000550c:	84aa                	mv	s1,a0
    8000550e:	c915                	beqz	a0,80005542 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005510:	9b0fe0ef          	jal	800036c0 <ilock>
  if(ip->type != T_DIR){
    80005514:	04449703          	lh	a4,68(s1)
    80005518:	4785                	li	a5,1
    8000551a:	02f71963          	bne	a4,a5,8000554c <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000551e:	8526                	mv	a0,s1
    80005520:	a4efe0ef          	jal	8000376e <iunlock>
  iput(p->cwd);
    80005524:	15093503          	ld	a0,336(s2)
    80005528:	b1afe0ef          	jal	80003842 <iput>
  end_op();
    8000552c:	a95fe0ef          	jal	80003fc0 <end_op>
  p->cwd = ip;
    80005530:	14993823          	sd	s1,336(s2)
  return 0;
    80005534:	4501                	li	a0,0
    80005536:	64aa                	ld	s1,136(sp)
}
    80005538:	60ea                	ld	ra,152(sp)
    8000553a:	644a                	ld	s0,144(sp)
    8000553c:	690a                	ld	s2,128(sp)
    8000553e:	610d                	addi	sp,sp,160
    80005540:	8082                	ret
    80005542:	64aa                	ld	s1,136(sp)
    end_op();
    80005544:	a7dfe0ef          	jal	80003fc0 <end_op>
    return -1;
    80005548:	557d                	li	a0,-1
    8000554a:	b7fd                	j	80005538 <sys_chdir+0x5c>
    iunlockput(ip);
    8000554c:	8526                	mv	a0,s1
    8000554e:	b7cfe0ef          	jal	800038ca <iunlockput>
    end_op();
    80005552:	a6ffe0ef          	jal	80003fc0 <end_op>
    return -1;
    80005556:	557d                	li	a0,-1
    80005558:	64aa                	ld	s1,136(sp)
    8000555a:	bff9                	j	80005538 <sys_chdir+0x5c>

000000008000555c <sys_exec>:

uint64
sys_exec(void)
{
    8000555c:	7121                	addi	sp,sp,-448
    8000555e:	ff06                	sd	ra,440(sp)
    80005560:	fb22                	sd	s0,432(sp)
    80005562:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005564:	e4840593          	addi	a1,s0,-440
    80005568:	4505                	li	a0,1
    8000556a:	e66fd0ef          	jal	80002bd0 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000556e:	08000613          	li	a2,128
    80005572:	f5040593          	addi	a1,s0,-176
    80005576:	4501                	li	a0,0
    80005578:	e74fd0ef          	jal	80002bec <argstr>
    8000557c:	87aa                	mv	a5,a0
    return -1;
    8000557e:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005580:	0c07c463          	bltz	a5,80005648 <sys_exec+0xec>
    80005584:	f726                	sd	s1,424(sp)
    80005586:	f34a                	sd	s2,416(sp)
    80005588:	ef4e                	sd	s3,408(sp)
    8000558a:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    8000558c:	10000613          	li	a2,256
    80005590:	4581                	li	a1,0
    80005592:	e5040513          	addi	a0,s0,-432
    80005596:	f32fb0ef          	jal	80000cc8 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    8000559a:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    8000559e:	89a6                	mv	s3,s1
    800055a0:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800055a2:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800055a6:	00391513          	slli	a0,s2,0x3
    800055aa:	e4040593          	addi	a1,s0,-448
    800055ae:	e4843783          	ld	a5,-440(s0)
    800055b2:	953e                	add	a0,a0,a5
    800055b4:	d76fd0ef          	jal	80002b2a <fetchaddr>
    800055b8:	02054663          	bltz	a0,800055e4 <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    800055bc:	e4043783          	ld	a5,-448(s0)
    800055c0:	c3a9                	beqz	a5,80005602 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800055c2:	d62fb0ef          	jal	80000b24 <kalloc>
    800055c6:	85aa                	mv	a1,a0
    800055c8:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800055cc:	cd01                	beqz	a0,800055e4 <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800055ce:	6605                	lui	a2,0x1
    800055d0:	e4043503          	ld	a0,-448(s0)
    800055d4:	da0fd0ef          	jal	80002b74 <fetchstr>
    800055d8:	00054663          	bltz	a0,800055e4 <sys_exec+0x88>
    if(i >= NELEM(argv)){
    800055dc:	0905                	addi	s2,s2,1
    800055de:	09a1                	addi	s3,s3,8
    800055e0:	fd4913e3          	bne	s2,s4,800055a6 <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800055e4:	f5040913          	addi	s2,s0,-176
    800055e8:	6088                	ld	a0,0(s1)
    800055ea:	c931                	beqz	a0,8000563e <sys_exec+0xe2>
    kfree(argv[i]);
    800055ec:	c56fb0ef          	jal	80000a42 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800055f0:	04a1                	addi	s1,s1,8
    800055f2:	ff249be3          	bne	s1,s2,800055e8 <sys_exec+0x8c>
  return -1;
    800055f6:	557d                	li	a0,-1
    800055f8:	74ba                	ld	s1,424(sp)
    800055fa:	791a                	ld	s2,416(sp)
    800055fc:	69fa                	ld	s3,408(sp)
    800055fe:	6a5a                	ld	s4,400(sp)
    80005600:	a0a1                	j	80005648 <sys_exec+0xec>
      argv[i] = 0;
    80005602:	0009079b          	sext.w	a5,s2
    80005606:	078e                	slli	a5,a5,0x3
    80005608:	fd078793          	addi	a5,a5,-48
    8000560c:	97a2                	add	a5,a5,s0
    8000560e:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80005612:	e5040593          	addi	a1,s0,-432
    80005616:	f5040513          	addi	a0,s0,-176
    8000561a:	ba8ff0ef          	jal	800049c2 <exec>
    8000561e:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005620:	f5040993          	addi	s3,s0,-176
    80005624:	6088                	ld	a0,0(s1)
    80005626:	c511                	beqz	a0,80005632 <sys_exec+0xd6>
    kfree(argv[i]);
    80005628:	c1afb0ef          	jal	80000a42 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000562c:	04a1                	addi	s1,s1,8
    8000562e:	ff349be3          	bne	s1,s3,80005624 <sys_exec+0xc8>
  return ret;
    80005632:	854a                	mv	a0,s2
    80005634:	74ba                	ld	s1,424(sp)
    80005636:	791a                	ld	s2,416(sp)
    80005638:	69fa                	ld	s3,408(sp)
    8000563a:	6a5a                	ld	s4,400(sp)
    8000563c:	a031                	j	80005648 <sys_exec+0xec>
  return -1;
    8000563e:	557d                	li	a0,-1
    80005640:	74ba                	ld	s1,424(sp)
    80005642:	791a                	ld	s2,416(sp)
    80005644:	69fa                	ld	s3,408(sp)
    80005646:	6a5a                	ld	s4,400(sp)
}
    80005648:	70fa                	ld	ra,440(sp)
    8000564a:	745a                	ld	s0,432(sp)
    8000564c:	6139                	addi	sp,sp,448
    8000564e:	8082                	ret

0000000080005650 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005650:	7139                	addi	sp,sp,-64
    80005652:	fc06                	sd	ra,56(sp)
    80005654:	f822                	sd	s0,48(sp)
    80005656:	f426                	sd	s1,40(sp)
    80005658:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000565a:	aa8fc0ef          	jal	80001902 <myproc>
    8000565e:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005660:	fd840593          	addi	a1,s0,-40
    80005664:	4501                	li	a0,0
    80005666:	d6afd0ef          	jal	80002bd0 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    8000566a:	fc840593          	addi	a1,s0,-56
    8000566e:	fd040513          	addi	a0,s0,-48
    80005672:	85cff0ef          	jal	800046ce <pipealloc>
    return -1;
    80005676:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005678:	0a054463          	bltz	a0,80005720 <sys_pipe+0xd0>
  fd0 = -1;
    8000567c:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005680:	fd043503          	ld	a0,-48(s0)
    80005684:	f08ff0ef          	jal	80004d8c <fdalloc>
    80005688:	fca42223          	sw	a0,-60(s0)
    8000568c:	08054163          	bltz	a0,8000570e <sys_pipe+0xbe>
    80005690:	fc843503          	ld	a0,-56(s0)
    80005694:	ef8ff0ef          	jal	80004d8c <fdalloc>
    80005698:	fca42023          	sw	a0,-64(s0)
    8000569c:	06054063          	bltz	a0,800056fc <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800056a0:	4691                	li	a3,4
    800056a2:	fc440613          	addi	a2,s0,-60
    800056a6:	fd843583          	ld	a1,-40(s0)
    800056aa:	68a8                	ld	a0,80(s1)
    800056ac:	ed1fb0ef          	jal	8000157c <copyout>
    800056b0:	00054e63          	bltz	a0,800056cc <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800056b4:	4691                	li	a3,4
    800056b6:	fc040613          	addi	a2,s0,-64
    800056ba:	fd843583          	ld	a1,-40(s0)
    800056be:	0591                	addi	a1,a1,4
    800056c0:	68a8                	ld	a0,80(s1)
    800056c2:	ebbfb0ef          	jal	8000157c <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800056c6:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800056c8:	04055c63          	bgez	a0,80005720 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    800056cc:	fc442783          	lw	a5,-60(s0)
    800056d0:	07e9                	addi	a5,a5,26
    800056d2:	078e                	slli	a5,a5,0x3
    800056d4:	97a6                	add	a5,a5,s1
    800056d6:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800056da:	fc042783          	lw	a5,-64(s0)
    800056de:	07e9                	addi	a5,a5,26
    800056e0:	078e                	slli	a5,a5,0x3
    800056e2:	94be                	add	s1,s1,a5
    800056e4:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800056e8:	fd043503          	ld	a0,-48(s0)
    800056ec:	cd9fe0ef          	jal	800043c4 <fileclose>
    fileclose(wf);
    800056f0:	fc843503          	ld	a0,-56(s0)
    800056f4:	cd1fe0ef          	jal	800043c4 <fileclose>
    return -1;
    800056f8:	57fd                	li	a5,-1
    800056fa:	a01d                	j	80005720 <sys_pipe+0xd0>
    if(fd0 >= 0)
    800056fc:	fc442783          	lw	a5,-60(s0)
    80005700:	0007c763          	bltz	a5,8000570e <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80005704:	07e9                	addi	a5,a5,26
    80005706:	078e                	slli	a5,a5,0x3
    80005708:	97a6                	add	a5,a5,s1
    8000570a:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000570e:	fd043503          	ld	a0,-48(s0)
    80005712:	cb3fe0ef          	jal	800043c4 <fileclose>
    fileclose(wf);
    80005716:	fc843503          	ld	a0,-56(s0)
    8000571a:	cabfe0ef          	jal	800043c4 <fileclose>
    return -1;
    8000571e:	57fd                	li	a5,-1
}
    80005720:	853e                	mv	a0,a5
    80005722:	70e2                	ld	ra,56(sp)
    80005724:	7442                	ld	s0,48(sp)
    80005726:	74a2                	ld	s1,40(sp)
    80005728:	6121                	addi	sp,sp,64
    8000572a:	8082                	ret
    8000572c:	0000                	unimp
	...

0000000080005730 <kernelvec>:
    80005730:	7111                	addi	sp,sp,-256
    80005732:	e006                	sd	ra,0(sp)
    80005734:	e40a                	sd	sp,8(sp)
    80005736:	e80e                	sd	gp,16(sp)
    80005738:	ec12                	sd	tp,24(sp)
    8000573a:	f016                	sd	t0,32(sp)
    8000573c:	f41a                	sd	t1,40(sp)
    8000573e:	f81e                	sd	t2,48(sp)
    80005740:	e4aa                	sd	a0,72(sp)
    80005742:	e8ae                	sd	a1,80(sp)
    80005744:	ecb2                	sd	a2,88(sp)
    80005746:	f0b6                	sd	a3,96(sp)
    80005748:	f4ba                	sd	a4,104(sp)
    8000574a:	f8be                	sd	a5,112(sp)
    8000574c:	fcc2                	sd	a6,120(sp)
    8000574e:	e146                	sd	a7,128(sp)
    80005750:	edf2                	sd	t3,216(sp)
    80005752:	f1f6                	sd	t4,224(sp)
    80005754:	f5fa                	sd	t5,232(sp)
    80005756:	f9fe                	sd	t6,240(sp)
    80005758:	ae2fd0ef          	jal	80002a3a <kerneltrap>
    8000575c:	6082                	ld	ra,0(sp)
    8000575e:	6122                	ld	sp,8(sp)
    80005760:	61c2                	ld	gp,16(sp)
    80005762:	7282                	ld	t0,32(sp)
    80005764:	7322                	ld	t1,40(sp)
    80005766:	73c2                	ld	t2,48(sp)
    80005768:	6526                	ld	a0,72(sp)
    8000576a:	65c6                	ld	a1,80(sp)
    8000576c:	6666                	ld	a2,88(sp)
    8000576e:	7686                	ld	a3,96(sp)
    80005770:	7726                	ld	a4,104(sp)
    80005772:	77c6                	ld	a5,112(sp)
    80005774:	7866                	ld	a6,120(sp)
    80005776:	688a                	ld	a7,128(sp)
    80005778:	6e6e                	ld	t3,216(sp)
    8000577a:	7e8e                	ld	t4,224(sp)
    8000577c:	7f2e                	ld	t5,232(sp)
    8000577e:	7fce                	ld	t6,240(sp)
    80005780:	6111                	addi	sp,sp,256
    80005782:	10200073          	sret
	...

000000008000578e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000578e:	1141                	addi	sp,sp,-16
    80005790:	e422                	sd	s0,8(sp)
    80005792:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005794:	0c0007b7          	lui	a5,0xc000
    80005798:	4705                	li	a4,1
    8000579a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000579c:	0c0007b7          	lui	a5,0xc000
    800057a0:	c3d8                	sw	a4,4(a5)
}
    800057a2:	6422                	ld	s0,8(sp)
    800057a4:	0141                	addi	sp,sp,16
    800057a6:	8082                	ret

00000000800057a8 <plicinithart>:

void
plicinithart(void)
{
    800057a8:	1141                	addi	sp,sp,-16
    800057aa:	e406                	sd	ra,8(sp)
    800057ac:	e022                	sd	s0,0(sp)
    800057ae:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800057b0:	926fc0ef          	jal	800018d6 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800057b4:	0085171b          	slliw	a4,a0,0x8
    800057b8:	0c0027b7          	lui	a5,0xc002
    800057bc:	97ba                	add	a5,a5,a4
    800057be:	40200713          	li	a4,1026
    800057c2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800057c6:	00d5151b          	slliw	a0,a0,0xd
    800057ca:	0c2017b7          	lui	a5,0xc201
    800057ce:	97aa                	add	a5,a5,a0
    800057d0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800057d4:	60a2                	ld	ra,8(sp)
    800057d6:	6402                	ld	s0,0(sp)
    800057d8:	0141                	addi	sp,sp,16
    800057da:	8082                	ret

00000000800057dc <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800057dc:	1141                	addi	sp,sp,-16
    800057de:	e406                	sd	ra,8(sp)
    800057e0:	e022                	sd	s0,0(sp)
    800057e2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800057e4:	8f2fc0ef          	jal	800018d6 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800057e8:	00d5151b          	slliw	a0,a0,0xd
    800057ec:	0c2017b7          	lui	a5,0xc201
    800057f0:	97aa                	add	a5,a5,a0
  return irq;
}
    800057f2:	43c8                	lw	a0,4(a5)
    800057f4:	60a2                	ld	ra,8(sp)
    800057f6:	6402                	ld	s0,0(sp)
    800057f8:	0141                	addi	sp,sp,16
    800057fa:	8082                	ret

00000000800057fc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800057fc:	1101                	addi	sp,sp,-32
    800057fe:	ec06                	sd	ra,24(sp)
    80005800:	e822                	sd	s0,16(sp)
    80005802:	e426                	sd	s1,8(sp)
    80005804:	1000                	addi	s0,sp,32
    80005806:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005808:	8cefc0ef          	jal	800018d6 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000580c:	00d5151b          	slliw	a0,a0,0xd
    80005810:	0c2017b7          	lui	a5,0xc201
    80005814:	97aa                	add	a5,a5,a0
    80005816:	c3c4                	sw	s1,4(a5)
}
    80005818:	60e2                	ld	ra,24(sp)
    8000581a:	6442                	ld	s0,16(sp)
    8000581c:	64a2                	ld	s1,8(sp)
    8000581e:	6105                	addi	sp,sp,32
    80005820:	8082                	ret

0000000080005822 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005822:	1141                	addi	sp,sp,-16
    80005824:	e406                	sd	ra,8(sp)
    80005826:	e022                	sd	s0,0(sp)
    80005828:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000582a:	479d                	li	a5,7
    8000582c:	04a7ca63          	blt	a5,a0,80005880 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005830:	0001d797          	auipc	a5,0x1d
    80005834:	6a078793          	addi	a5,a5,1696 # 80022ed0 <disk>
    80005838:	97aa                	add	a5,a5,a0
    8000583a:	0187c783          	lbu	a5,24(a5)
    8000583e:	e7b9                	bnez	a5,8000588c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005840:	00451693          	slli	a3,a0,0x4
    80005844:	0001d797          	auipc	a5,0x1d
    80005848:	68c78793          	addi	a5,a5,1676 # 80022ed0 <disk>
    8000584c:	6398                	ld	a4,0(a5)
    8000584e:	9736                	add	a4,a4,a3
    80005850:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005854:	6398                	ld	a4,0(a5)
    80005856:	9736                	add	a4,a4,a3
    80005858:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000585c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005860:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005864:	97aa                	add	a5,a5,a0
    80005866:	4705                	li	a4,1
    80005868:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000586c:	0001d517          	auipc	a0,0x1d
    80005870:	67c50513          	addi	a0,a0,1660 # 80022ee8 <disk+0x18>
    80005874:	9effc0ef          	jal	80002262 <wakeup>
}
    80005878:	60a2                	ld	ra,8(sp)
    8000587a:	6402                	ld	s0,0(sp)
    8000587c:	0141                	addi	sp,sp,16
    8000587e:	8082                	ret
    panic("free_desc 1");
    80005880:	00002517          	auipc	a0,0x2
    80005884:	fa050513          	addi	a0,a0,-96 # 80007820 <etext+0x820>
    80005888:	f0dfa0ef          	jal	80000794 <panic>
    panic("free_desc 2");
    8000588c:	00002517          	auipc	a0,0x2
    80005890:	fa450513          	addi	a0,a0,-92 # 80007830 <etext+0x830>
    80005894:	f01fa0ef          	jal	80000794 <panic>

0000000080005898 <virtio_disk_init>:
{
    80005898:	1101                	addi	sp,sp,-32
    8000589a:	ec06                	sd	ra,24(sp)
    8000589c:	e822                	sd	s0,16(sp)
    8000589e:	e426                	sd	s1,8(sp)
    800058a0:	e04a                	sd	s2,0(sp)
    800058a2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800058a4:	00002597          	auipc	a1,0x2
    800058a8:	f9c58593          	addi	a1,a1,-100 # 80007840 <etext+0x840>
    800058ac:	0001d517          	auipc	a0,0x1d
    800058b0:	74c50513          	addi	a0,a0,1868 # 80022ff8 <disk+0x128>
    800058b4:	ac0fb0ef          	jal	80000b74 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800058b8:	100017b7          	lui	a5,0x10001
    800058bc:	4398                	lw	a4,0(a5)
    800058be:	2701                	sext.w	a4,a4
    800058c0:	747277b7          	lui	a5,0x74727
    800058c4:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800058c8:	18f71063          	bne	a4,a5,80005a48 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800058cc:	100017b7          	lui	a5,0x10001
    800058d0:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    800058d2:	439c                	lw	a5,0(a5)
    800058d4:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800058d6:	4709                	li	a4,2
    800058d8:	16e79863          	bne	a5,a4,80005a48 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800058dc:	100017b7          	lui	a5,0x10001
    800058e0:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    800058e2:	439c                	lw	a5,0(a5)
    800058e4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800058e6:	16e79163          	bne	a5,a4,80005a48 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800058ea:	100017b7          	lui	a5,0x10001
    800058ee:	47d8                	lw	a4,12(a5)
    800058f0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800058f2:	554d47b7          	lui	a5,0x554d4
    800058f6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800058fa:	14f71763          	bne	a4,a5,80005a48 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    800058fe:	100017b7          	lui	a5,0x10001
    80005902:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005906:	4705                	li	a4,1
    80005908:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000590a:	470d                	li	a4,3
    8000590c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000590e:	10001737          	lui	a4,0x10001
    80005912:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005914:	c7ffe737          	lui	a4,0xc7ffe
    80005918:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdb74f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000591c:	8ef9                	and	a3,a3,a4
    8000591e:	10001737          	lui	a4,0x10001
    80005922:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005924:	472d                	li	a4,11
    80005926:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005928:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    8000592c:	439c                	lw	a5,0(a5)
    8000592e:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005932:	8ba1                	andi	a5,a5,8
    80005934:	12078063          	beqz	a5,80005a54 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005938:	100017b7          	lui	a5,0x10001
    8000593c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005940:	100017b7          	lui	a5,0x10001
    80005944:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80005948:	439c                	lw	a5,0(a5)
    8000594a:	2781                	sext.w	a5,a5
    8000594c:	10079a63          	bnez	a5,80005a60 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005950:	100017b7          	lui	a5,0x10001
    80005954:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80005958:	439c                	lw	a5,0(a5)
    8000595a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000595c:	10078863          	beqz	a5,80005a6c <virtio_disk_init+0x1d4>
  if(max < NUM)
    80005960:	471d                	li	a4,7
    80005962:	10f77b63          	bgeu	a4,a5,80005a78 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80005966:	9befb0ef          	jal	80000b24 <kalloc>
    8000596a:	0001d497          	auipc	s1,0x1d
    8000596e:	56648493          	addi	s1,s1,1382 # 80022ed0 <disk>
    80005972:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005974:	9b0fb0ef          	jal	80000b24 <kalloc>
    80005978:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000597a:	9aafb0ef          	jal	80000b24 <kalloc>
    8000597e:	87aa                	mv	a5,a0
    80005980:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005982:	6088                	ld	a0,0(s1)
    80005984:	10050063          	beqz	a0,80005a84 <virtio_disk_init+0x1ec>
    80005988:	0001d717          	auipc	a4,0x1d
    8000598c:	55073703          	ld	a4,1360(a4) # 80022ed8 <disk+0x8>
    80005990:	0e070a63          	beqz	a4,80005a84 <virtio_disk_init+0x1ec>
    80005994:	0e078863          	beqz	a5,80005a84 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80005998:	6605                	lui	a2,0x1
    8000599a:	4581                	li	a1,0
    8000599c:	b2cfb0ef          	jal	80000cc8 <memset>
  memset(disk.avail, 0, PGSIZE);
    800059a0:	0001d497          	auipc	s1,0x1d
    800059a4:	53048493          	addi	s1,s1,1328 # 80022ed0 <disk>
    800059a8:	6605                	lui	a2,0x1
    800059aa:	4581                	li	a1,0
    800059ac:	6488                	ld	a0,8(s1)
    800059ae:	b1afb0ef          	jal	80000cc8 <memset>
  memset(disk.used, 0, PGSIZE);
    800059b2:	6605                	lui	a2,0x1
    800059b4:	4581                	li	a1,0
    800059b6:	6888                	ld	a0,16(s1)
    800059b8:	b10fb0ef          	jal	80000cc8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800059bc:	100017b7          	lui	a5,0x10001
    800059c0:	4721                	li	a4,8
    800059c2:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800059c4:	4098                	lw	a4,0(s1)
    800059c6:	100017b7          	lui	a5,0x10001
    800059ca:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800059ce:	40d8                	lw	a4,4(s1)
    800059d0:	100017b7          	lui	a5,0x10001
    800059d4:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800059d8:	649c                	ld	a5,8(s1)
    800059da:	0007869b          	sext.w	a3,a5
    800059de:	10001737          	lui	a4,0x10001
    800059e2:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800059e6:	9781                	srai	a5,a5,0x20
    800059e8:	10001737          	lui	a4,0x10001
    800059ec:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800059f0:	689c                	ld	a5,16(s1)
    800059f2:	0007869b          	sext.w	a3,a5
    800059f6:	10001737          	lui	a4,0x10001
    800059fa:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800059fe:	9781                	srai	a5,a5,0x20
    80005a00:	10001737          	lui	a4,0x10001
    80005a04:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005a08:	10001737          	lui	a4,0x10001
    80005a0c:	4785                	li	a5,1
    80005a0e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005a10:	00f48c23          	sb	a5,24(s1)
    80005a14:	00f48ca3          	sb	a5,25(s1)
    80005a18:	00f48d23          	sb	a5,26(s1)
    80005a1c:	00f48da3          	sb	a5,27(s1)
    80005a20:	00f48e23          	sb	a5,28(s1)
    80005a24:	00f48ea3          	sb	a5,29(s1)
    80005a28:	00f48f23          	sb	a5,30(s1)
    80005a2c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005a30:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005a34:	100017b7          	lui	a5,0x10001
    80005a38:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    80005a3c:	60e2                	ld	ra,24(sp)
    80005a3e:	6442                	ld	s0,16(sp)
    80005a40:	64a2                	ld	s1,8(sp)
    80005a42:	6902                	ld	s2,0(sp)
    80005a44:	6105                	addi	sp,sp,32
    80005a46:	8082                	ret
    panic("could not find virtio disk");
    80005a48:	00002517          	auipc	a0,0x2
    80005a4c:	e0850513          	addi	a0,a0,-504 # 80007850 <etext+0x850>
    80005a50:	d45fa0ef          	jal	80000794 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005a54:	00002517          	auipc	a0,0x2
    80005a58:	e1c50513          	addi	a0,a0,-484 # 80007870 <etext+0x870>
    80005a5c:	d39fa0ef          	jal	80000794 <panic>
    panic("virtio disk should not be ready");
    80005a60:	00002517          	auipc	a0,0x2
    80005a64:	e3050513          	addi	a0,a0,-464 # 80007890 <etext+0x890>
    80005a68:	d2dfa0ef          	jal	80000794 <panic>
    panic("virtio disk has no queue 0");
    80005a6c:	00002517          	auipc	a0,0x2
    80005a70:	e4450513          	addi	a0,a0,-444 # 800078b0 <etext+0x8b0>
    80005a74:	d21fa0ef          	jal	80000794 <panic>
    panic("virtio disk max queue too short");
    80005a78:	00002517          	auipc	a0,0x2
    80005a7c:	e5850513          	addi	a0,a0,-424 # 800078d0 <etext+0x8d0>
    80005a80:	d15fa0ef          	jal	80000794 <panic>
    panic("virtio disk kalloc");
    80005a84:	00002517          	auipc	a0,0x2
    80005a88:	e6c50513          	addi	a0,a0,-404 # 800078f0 <etext+0x8f0>
    80005a8c:	d09fa0ef          	jal	80000794 <panic>

0000000080005a90 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005a90:	7159                	addi	sp,sp,-112
    80005a92:	f486                	sd	ra,104(sp)
    80005a94:	f0a2                	sd	s0,96(sp)
    80005a96:	eca6                	sd	s1,88(sp)
    80005a98:	e8ca                	sd	s2,80(sp)
    80005a9a:	e4ce                	sd	s3,72(sp)
    80005a9c:	e0d2                	sd	s4,64(sp)
    80005a9e:	fc56                	sd	s5,56(sp)
    80005aa0:	f85a                	sd	s6,48(sp)
    80005aa2:	f45e                	sd	s7,40(sp)
    80005aa4:	f062                	sd	s8,32(sp)
    80005aa6:	ec66                	sd	s9,24(sp)
    80005aa8:	1880                	addi	s0,sp,112
    80005aaa:	8a2a                	mv	s4,a0
    80005aac:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005aae:	00c52c83          	lw	s9,12(a0)
    80005ab2:	001c9c9b          	slliw	s9,s9,0x1
    80005ab6:	1c82                	slli	s9,s9,0x20
    80005ab8:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80005abc:	0001d517          	auipc	a0,0x1d
    80005ac0:	53c50513          	addi	a0,a0,1340 # 80022ff8 <disk+0x128>
    80005ac4:	930fb0ef          	jal	80000bf4 <acquire>
  for(int i = 0; i < 3; i++){
    80005ac8:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005aca:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005acc:	0001db17          	auipc	s6,0x1d
    80005ad0:	404b0b13          	addi	s6,s6,1028 # 80022ed0 <disk>
  for(int i = 0; i < 3; i++){
    80005ad4:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005ad6:	0001dc17          	auipc	s8,0x1d
    80005ada:	522c0c13          	addi	s8,s8,1314 # 80022ff8 <disk+0x128>
    80005ade:	a8b9                	j	80005b3c <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80005ae0:	00fb0733          	add	a4,s6,a5
    80005ae4:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80005ae8:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005aea:	0207c563          	bltz	a5,80005b14 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    80005aee:	2905                	addiw	s2,s2,1
    80005af0:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005af2:	05590963          	beq	s2,s5,80005b44 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    80005af6:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005af8:	0001d717          	auipc	a4,0x1d
    80005afc:	3d870713          	addi	a4,a4,984 # 80022ed0 <disk>
    80005b00:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005b02:	01874683          	lbu	a3,24(a4)
    80005b06:	fee9                	bnez	a3,80005ae0 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80005b08:	2785                	addiw	a5,a5,1
    80005b0a:	0705                	addi	a4,a4,1
    80005b0c:	fe979be3          	bne	a5,s1,80005b02 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80005b10:	57fd                	li	a5,-1
    80005b12:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005b14:	01205d63          	blez	s2,80005b2e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005b18:	f9042503          	lw	a0,-112(s0)
    80005b1c:	d07ff0ef          	jal	80005822 <free_desc>
      for(int j = 0; j < i; j++)
    80005b20:	4785                	li	a5,1
    80005b22:	0127d663          	bge	a5,s2,80005b2e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005b26:	f9442503          	lw	a0,-108(s0)
    80005b2a:	cf9ff0ef          	jal	80005822 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005b2e:	85e2                	mv	a1,s8
    80005b30:	0001d517          	auipc	a0,0x1d
    80005b34:	3b850513          	addi	a0,a0,952 # 80022ee8 <disk+0x18>
    80005b38:	edefc0ef          	jal	80002216 <sleep>
  for(int i = 0; i < 3; i++){
    80005b3c:	f9040613          	addi	a2,s0,-112
    80005b40:	894e                	mv	s2,s3
    80005b42:	bf55                	j	80005af6 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005b44:	f9042503          	lw	a0,-112(s0)
    80005b48:	00451693          	slli	a3,a0,0x4

  if(write)
    80005b4c:	0001d797          	auipc	a5,0x1d
    80005b50:	38478793          	addi	a5,a5,900 # 80022ed0 <disk>
    80005b54:	00a50713          	addi	a4,a0,10
    80005b58:	0712                	slli	a4,a4,0x4
    80005b5a:	973e                	add	a4,a4,a5
    80005b5c:	01703633          	snez	a2,s7
    80005b60:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005b62:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005b66:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005b6a:	6398                	ld	a4,0(a5)
    80005b6c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005b6e:	0a868613          	addi	a2,a3,168
    80005b72:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005b74:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005b76:	6390                	ld	a2,0(a5)
    80005b78:	00d605b3          	add	a1,a2,a3
    80005b7c:	4741                	li	a4,16
    80005b7e:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005b80:	4805                	li	a6,1
    80005b82:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80005b86:	f9442703          	lw	a4,-108(s0)
    80005b8a:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005b8e:	0712                	slli	a4,a4,0x4
    80005b90:	963a                	add	a2,a2,a4
    80005b92:	058a0593          	addi	a1,s4,88
    80005b96:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005b98:	0007b883          	ld	a7,0(a5)
    80005b9c:	9746                	add	a4,a4,a7
    80005b9e:	40000613          	li	a2,1024
    80005ba2:	c710                	sw	a2,8(a4)
  if(write)
    80005ba4:	001bb613          	seqz	a2,s7
    80005ba8:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005bac:	00166613          	ori	a2,a2,1
    80005bb0:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005bb4:	f9842583          	lw	a1,-104(s0)
    80005bb8:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005bbc:	00250613          	addi	a2,a0,2
    80005bc0:	0612                	slli	a2,a2,0x4
    80005bc2:	963e                	add	a2,a2,a5
    80005bc4:	577d                	li	a4,-1
    80005bc6:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005bca:	0592                	slli	a1,a1,0x4
    80005bcc:	98ae                	add	a7,a7,a1
    80005bce:	03068713          	addi	a4,a3,48
    80005bd2:	973e                	add	a4,a4,a5
    80005bd4:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005bd8:	6398                	ld	a4,0(a5)
    80005bda:	972e                	add	a4,a4,a1
    80005bdc:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005be0:	4689                	li	a3,2
    80005be2:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005be6:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005bea:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    80005bee:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005bf2:	6794                	ld	a3,8(a5)
    80005bf4:	0026d703          	lhu	a4,2(a3)
    80005bf8:	8b1d                	andi	a4,a4,7
    80005bfa:	0706                	slli	a4,a4,0x1
    80005bfc:	96ba                	add	a3,a3,a4
    80005bfe:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005c02:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005c06:	6798                	ld	a4,8(a5)
    80005c08:	00275783          	lhu	a5,2(a4)
    80005c0c:	2785                	addiw	a5,a5,1
    80005c0e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005c12:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005c16:	100017b7          	lui	a5,0x10001
    80005c1a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005c1e:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80005c22:	0001d917          	auipc	s2,0x1d
    80005c26:	3d690913          	addi	s2,s2,982 # 80022ff8 <disk+0x128>
  while(b->disk == 1) {
    80005c2a:	4485                	li	s1,1
    80005c2c:	01079a63          	bne	a5,a6,80005c40 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005c30:	85ca                	mv	a1,s2
    80005c32:	8552                	mv	a0,s4
    80005c34:	de2fc0ef          	jal	80002216 <sleep>
  while(b->disk == 1) {
    80005c38:	004a2783          	lw	a5,4(s4)
    80005c3c:	fe978ae3          	beq	a5,s1,80005c30 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005c40:	f9042903          	lw	s2,-112(s0)
    80005c44:	00290713          	addi	a4,s2,2
    80005c48:	0712                	slli	a4,a4,0x4
    80005c4a:	0001d797          	auipc	a5,0x1d
    80005c4e:	28678793          	addi	a5,a5,646 # 80022ed0 <disk>
    80005c52:	97ba                	add	a5,a5,a4
    80005c54:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005c58:	0001d997          	auipc	s3,0x1d
    80005c5c:	27898993          	addi	s3,s3,632 # 80022ed0 <disk>
    80005c60:	00491713          	slli	a4,s2,0x4
    80005c64:	0009b783          	ld	a5,0(s3)
    80005c68:	97ba                	add	a5,a5,a4
    80005c6a:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005c6e:	854a                	mv	a0,s2
    80005c70:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005c74:	bafff0ef          	jal	80005822 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005c78:	8885                	andi	s1,s1,1
    80005c7a:	f0fd                	bnez	s1,80005c60 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005c7c:	0001d517          	auipc	a0,0x1d
    80005c80:	37c50513          	addi	a0,a0,892 # 80022ff8 <disk+0x128>
    80005c84:	808fb0ef          	jal	80000c8c <release>
}
    80005c88:	70a6                	ld	ra,104(sp)
    80005c8a:	7406                	ld	s0,96(sp)
    80005c8c:	64e6                	ld	s1,88(sp)
    80005c8e:	6946                	ld	s2,80(sp)
    80005c90:	69a6                	ld	s3,72(sp)
    80005c92:	6a06                	ld	s4,64(sp)
    80005c94:	7ae2                	ld	s5,56(sp)
    80005c96:	7b42                	ld	s6,48(sp)
    80005c98:	7ba2                	ld	s7,40(sp)
    80005c9a:	7c02                	ld	s8,32(sp)
    80005c9c:	6ce2                	ld	s9,24(sp)
    80005c9e:	6165                	addi	sp,sp,112
    80005ca0:	8082                	ret

0000000080005ca2 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005ca2:	1101                	addi	sp,sp,-32
    80005ca4:	ec06                	sd	ra,24(sp)
    80005ca6:	e822                	sd	s0,16(sp)
    80005ca8:	e426                	sd	s1,8(sp)
    80005caa:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005cac:	0001d497          	auipc	s1,0x1d
    80005cb0:	22448493          	addi	s1,s1,548 # 80022ed0 <disk>
    80005cb4:	0001d517          	auipc	a0,0x1d
    80005cb8:	34450513          	addi	a0,a0,836 # 80022ff8 <disk+0x128>
    80005cbc:	f39fa0ef          	jal	80000bf4 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005cc0:	100017b7          	lui	a5,0x10001
    80005cc4:	53b8                	lw	a4,96(a5)
    80005cc6:	8b0d                	andi	a4,a4,3
    80005cc8:	100017b7          	lui	a5,0x10001
    80005ccc:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    80005cce:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005cd2:	689c                	ld	a5,16(s1)
    80005cd4:	0204d703          	lhu	a4,32(s1)
    80005cd8:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005cdc:	04f70663          	beq	a4,a5,80005d28 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80005ce0:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005ce4:	6898                	ld	a4,16(s1)
    80005ce6:	0204d783          	lhu	a5,32(s1)
    80005cea:	8b9d                	andi	a5,a5,7
    80005cec:	078e                	slli	a5,a5,0x3
    80005cee:	97ba                	add	a5,a5,a4
    80005cf0:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005cf2:	00278713          	addi	a4,a5,2
    80005cf6:	0712                	slli	a4,a4,0x4
    80005cf8:	9726                	add	a4,a4,s1
    80005cfa:	01074703          	lbu	a4,16(a4)
    80005cfe:	e321                	bnez	a4,80005d3e <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005d00:	0789                	addi	a5,a5,2
    80005d02:	0792                	slli	a5,a5,0x4
    80005d04:	97a6                	add	a5,a5,s1
    80005d06:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005d08:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005d0c:	d56fc0ef          	jal	80002262 <wakeup>

    disk.used_idx += 1;
    80005d10:	0204d783          	lhu	a5,32(s1)
    80005d14:	2785                	addiw	a5,a5,1
    80005d16:	17c2                	slli	a5,a5,0x30
    80005d18:	93c1                	srli	a5,a5,0x30
    80005d1a:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005d1e:	6898                	ld	a4,16(s1)
    80005d20:	00275703          	lhu	a4,2(a4)
    80005d24:	faf71ee3          	bne	a4,a5,80005ce0 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005d28:	0001d517          	auipc	a0,0x1d
    80005d2c:	2d050513          	addi	a0,a0,720 # 80022ff8 <disk+0x128>
    80005d30:	f5dfa0ef          	jal	80000c8c <release>
}
    80005d34:	60e2                	ld	ra,24(sp)
    80005d36:	6442                	ld	s0,16(sp)
    80005d38:	64a2                	ld	s1,8(sp)
    80005d3a:	6105                	addi	sp,sp,32
    80005d3c:	8082                	ret
      panic("virtio_disk_intr status");
    80005d3e:	00002517          	auipc	a0,0x2
    80005d42:	bca50513          	addi	a0,a0,-1078 # 80007908 <etext+0x908>
    80005d46:	a4ffa0ef          	jal	80000794 <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	8282                	jr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060ae:	0536                	slli	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0)
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...
