
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
    80000e9c:	12d040ef          	jal	800057c8 <plicinithart>
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
    80000ee8:	0c7040ef          	jal	800057ae <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000eec:	0dd040ef          	jal	800057c8 <plicinithart>
    binit();         // buffer cache
    80000ef0:	028020ef          	jal	80002f18 <binit>
    iinit();         // inode table
    80000ef4:	61a020ef          	jal	8000350e <iinit>
    fileinit();      // file table
    80000ef8:	41a030ef          	jal	80004312 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000efc:	1bd040ef          	jal	800058b8 <virtio_disk_init>
    userinit();      // first user process
    80000f00:	731000ef          	jal	80001e30 <userinit>
     log_message(INFO, "Welcome to AUT MCS Principles of Operating Systems Course. This message is from a custom logger implemented by 40212004 and 40213035");
    80000f04:	00006597          	auipc	a1,0x6
    80000f08:	19458593          	addi	a1,a1,404 # 80007098 <etext+0x98>
    80000f0c:	4501                	li	a0,0
    80000f0e:	2b2030ef          	jal	800041c0 <log_message>
     log_message(WARN, "This is a test warning message for the custom logger");
    80000f12:	00006597          	auipc	a1,0x6
    80000f16:	20e58593          	addi	a1,a1,526 # 80007120 <etext+0x120>
    80000f1a:	4505                	li	a0,1
    80000f1c:	2a4030ef          	jal	800041c0 <log_message>
     log_message(ERROR, "This is a test error message for the custom logger");
    80000f20:	00006597          	auipc	a1,0x6
    80000f24:	23858593          	addi	a1,a1,568 # 80007158 <etext+0x158>
    80000f28:	4509                	li	a0,2
    80000f2a:	296030ef          	jal	800041c0 <log_message>
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
    8000195a:	349010ef          	jal	800034a2 <fsinit>
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
    80001e82:	72f010ef          	jal	80003db0 <namei>
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
    80001f8c:	408020ef          	jal	80004394 <filedup>
    80001f90:	00a93023          	sd	a0,0(s2)
    80001f94:	b7f5                	j	80001f80 <fork+0x92>
  np->cwd = idup(p->cwd);
    80001f96:	150ab503          	ld	a0,336(s5)
    80001f9a:	706010ef          	jal	800036a0 <idup>
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
    8000235a:	080020ef          	jal	800043da <fileclose>
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
    8000236e:	3ff010ef          	jal	80003f6c <begin_op>
  iput(p->cwd);
    80002372:	1509b503          	ld	a0,336(s3)
    80002376:	4e2010ef          	jal	80003858 <iput>
  end_op();
    8000237a:	45d010ef          	jal	80003fd6 <end_op>
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
    800027a8:	fac78793          	addi	a5,a5,-84 # 80005750 <kernelvec>
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
    800028c8:	735020ef          	jal	800057fc <plic_claim>
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
    800028e8:	3da030ef          	jal	80005cc2 <virtio_disk_intr>
    if(irq)
    800028ec:	a801                	j	800028fc <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    800028ee:	85a6                	mv	a1,s1
    800028f0:	00005517          	auipc	a0,0x5
    800028f4:	af850513          	addi	a0,a0,-1288 # 800073e8 <etext+0x3e8>
    800028f8:	bcbfd0ef          	jal	800004c2 <printf>
      plic_complete(irq);
    800028fc:	8526                	mv	a0,s1
    800028fe:	71f020ef          	jal	8000581c <plic_complete>
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
    8000292a:	e2a78793          	addi	a5,a5,-470 # 80005750 <kernelvec>
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
[SYS_yield] sys_yield,

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
    80002c3c:	4761                	li	a4,24
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

0000000080002d7c <sys_yield>:

uint64
sys_yield(void) {
    80002d7c:	1141                	addi	sp,sp,-16
    80002d7e:	e406                	sd	ra,8(sp)
    80002d80:	e022                	sd	s0,0(sp)
    80002d82:	0800                	addi	s0,sp,16
    yield();
    80002d84:	beeff0ef          	jal	80002172 <yield>
    return 0;
}
    80002d88:	4501                	li	a0,0
    80002d8a:	60a2                	ld	ra,8(sp)
    80002d8c:	6402                	ld	s0,0(sp)
    80002d8e:	0141                	addi	sp,sp,16
    80002d90:	8082                	ret

0000000080002d92 <sys_wait>:


uint64
sys_wait(void)
{
    80002d92:	1101                	addi	sp,sp,-32
    80002d94:	ec06                	sd	ra,24(sp)
    80002d96:	e822                	sd	s0,16(sp)
    80002d98:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002d9a:	fe840593          	addi	a1,s0,-24
    80002d9e:	4501                	li	a0,0
    80002da0:	e31ff0ef          	jal	80002bd0 <argaddr>
  return wait(p);
    80002da4:	fe843503          	ld	a0,-24(s0)
    80002da8:	f36ff0ef          	jal	800024de <wait>
}
    80002dac:	60e2                	ld	ra,24(sp)
    80002dae:	6442                	ld	s0,16(sp)
    80002db0:	6105                	addi	sp,sp,32
    80002db2:	8082                	ret

0000000080002db4 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002db4:	7179                	addi	sp,sp,-48
    80002db6:	f406                	sd	ra,40(sp)
    80002db8:	f022                	sd	s0,32(sp)
    80002dba:	ec26                	sd	s1,24(sp)
    80002dbc:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002dbe:	fdc40593          	addi	a1,s0,-36
    80002dc2:	4501                	li	a0,0
    80002dc4:	df1ff0ef          	jal	80002bb4 <argint>
  addr = myproc()->sz;
    80002dc8:	b3bfe0ef          	jal	80001902 <myproc>
    80002dcc:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002dce:	fdc42503          	lw	a0,-36(s0)
    80002dd2:	8ccff0ef          	jal	80001e9e <growproc>
    80002dd6:	00054863          	bltz	a0,80002de6 <sys_sbrk+0x32>
    return -1;
  return addr;
}
    80002dda:	8526                	mv	a0,s1
    80002ddc:	70a2                	ld	ra,40(sp)
    80002dde:	7402                	ld	s0,32(sp)
    80002de0:	64e2                	ld	s1,24(sp)
    80002de2:	6145                	addi	sp,sp,48
    80002de4:	8082                	ret
    return -1;
    80002de6:	54fd                	li	s1,-1
    80002de8:	bfcd                	j	80002dda <sys_sbrk+0x26>

0000000080002dea <sys_sleep>:

uint64
sys_sleep(void)
{
    80002dea:	7139                	addi	sp,sp,-64
    80002dec:	fc06                	sd	ra,56(sp)
    80002dee:	f822                	sd	s0,48(sp)
    80002df0:	f04a                	sd	s2,32(sp)
    80002df2:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002df4:	fcc40593          	addi	a1,s0,-52
    80002df8:	4501                	li	a0,0
    80002dfa:	dbbff0ef          	jal	80002bb4 <argint>
  if(n < 0)
    80002dfe:	fcc42783          	lw	a5,-52(s0)
    80002e02:	0607cf63          	bltz	a5,80002e80 <sys_sleep+0x96>
    n = 0;
  acquire(&tickslock);
    80002e06:	00015517          	auipc	a0,0x15
    80002e0a:	e2a50513          	addi	a0,a0,-470 # 80017c30 <tickslock>
    80002e0e:	de7fd0ef          	jal	80000bf4 <acquire>
  ticks0 = ticks;
    80002e12:	00005917          	auipc	s2,0x5
    80002e16:	cbe92903          	lw	s2,-834(s2) # 80007ad0 <ticks>
  if (myproc()->current_thread) {
    80002e1a:	ae9fe0ef          	jal	80001902 <myproc>
    80002e1e:	1e853783          	ld	a5,488(a0)
    80002e22:	e3b5                	bnez	a5,80002e86 <sys_sleep+0x9c>
    80002e24:	f426                	sd	s1,40(sp)
    80002e26:	ec4e                	sd	s3,24(sp)
      release(&tickslock);
      sleepthread(n, ticks0);
      return 0;
  }

  while(ticks - ticks0 < n){
    80002e28:	00005797          	auipc	a5,0x5
    80002e2c:	ca87a783          	lw	a5,-856(a5) # 80007ad0 <ticks>
    80002e30:	412787bb          	subw	a5,a5,s2
    80002e34:	fcc42703          	lw	a4,-52(s0)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002e38:	00015997          	auipc	s3,0x15
    80002e3c:	df898993          	addi	s3,s3,-520 # 80017c30 <tickslock>
    80002e40:	00005497          	auipc	s1,0x5
    80002e44:	c9048493          	addi	s1,s1,-880 # 80007ad0 <ticks>
  while(ticks - ticks0 < n){
    80002e48:	02e7f263          	bgeu	a5,a4,80002e6c <sys_sleep+0x82>
    if(killed(myproc())){
    80002e4c:	ab7fe0ef          	jal	80001902 <myproc>
    80002e50:	e64ff0ef          	jal	800024b4 <killed>
    80002e54:	e931                	bnez	a0,80002ea8 <sys_sleep+0xbe>
    sleep(&ticks, &tickslock);
    80002e56:	85ce                	mv	a1,s3
    80002e58:	8526                	mv	a0,s1
    80002e5a:	bbcff0ef          	jal	80002216 <sleep>
  while(ticks - ticks0 < n){
    80002e5e:	409c                	lw	a5,0(s1)
    80002e60:	412787bb          	subw	a5,a5,s2
    80002e64:	fcc42703          	lw	a4,-52(s0)
    80002e68:	fee7e2e3          	bltu	a5,a4,80002e4c <sys_sleep+0x62>
  }
  release(&tickslock);
    80002e6c:	00015517          	auipc	a0,0x15
    80002e70:	dc450513          	addi	a0,a0,-572 # 80017c30 <tickslock>
    80002e74:	e19fd0ef          	jal	80000c8c <release>
  return 0;
    80002e78:	4501                	li	a0,0
    80002e7a:	74a2                	ld	s1,40(sp)
    80002e7c:	69e2                	ld	s3,24(sp)
    80002e7e:	a005                	j	80002e9e <sys_sleep+0xb4>
    n = 0;
    80002e80:	fc042623          	sw	zero,-52(s0)
    80002e84:	b749                	j	80002e06 <sys_sleep+0x1c>
      release(&tickslock);
    80002e86:	00015517          	auipc	a0,0x15
    80002e8a:	daa50513          	addi	a0,a0,-598 # 80017c30 <tickslock>
    80002e8e:	dfffd0ef          	jal	80000c8c <release>
      sleepthread(n, ticks0);
    80002e92:	85ca                	mv	a1,s2
    80002e94:	fcc42503          	lw	a0,-52(s0)
    80002e98:	c85fe0ef          	jal	80001b1c <sleepthread>
      return 0;
    80002e9c:	4501                	li	a0,0
}
    80002e9e:	70e2                	ld	ra,56(sp)
    80002ea0:	7442                	ld	s0,48(sp)
    80002ea2:	7902                	ld	s2,32(sp)
    80002ea4:	6121                	addi	sp,sp,64
    80002ea6:	8082                	ret
      release(&tickslock);
    80002ea8:	00015517          	auipc	a0,0x15
    80002eac:	d8850513          	addi	a0,a0,-632 # 80017c30 <tickslock>
    80002eb0:	dddfd0ef          	jal	80000c8c <release>
      return -1;
    80002eb4:	557d                	li	a0,-1
    80002eb6:	74a2                	ld	s1,40(sp)
    80002eb8:	69e2                	ld	s3,24(sp)
    80002eba:	b7d5                	j	80002e9e <sys_sleep+0xb4>

0000000080002ebc <sys_kill>:


uint64
sys_kill(void)
{
    80002ebc:	1101                	addi	sp,sp,-32
    80002ebe:	ec06                	sd	ra,24(sp)
    80002ec0:	e822                	sd	s0,16(sp)
    80002ec2:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002ec4:	fec40593          	addi	a1,s0,-20
    80002ec8:	4501                	li	a0,0
    80002eca:	cebff0ef          	jal	80002bb4 <argint>
  return kill(pid);
    80002ece:	fec42503          	lw	a0,-20(s0)
    80002ed2:	cf2ff0ef          	jal	800023c4 <kill>
}
    80002ed6:	60e2                	ld	ra,24(sp)
    80002ed8:	6442                	ld	s0,16(sp)
    80002eda:	6105                	addi	sp,sp,32
    80002edc:	8082                	ret

0000000080002ede <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002ede:	1101                	addi	sp,sp,-32
    80002ee0:	ec06                	sd	ra,24(sp)
    80002ee2:	e822                	sd	s0,16(sp)
    80002ee4:	e426                	sd	s1,8(sp)
    80002ee6:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002ee8:	00015517          	auipc	a0,0x15
    80002eec:	d4850513          	addi	a0,a0,-696 # 80017c30 <tickslock>
    80002ef0:	d05fd0ef          	jal	80000bf4 <acquire>
  xticks = ticks;
    80002ef4:	00005497          	auipc	s1,0x5
    80002ef8:	bdc4a483          	lw	s1,-1060(s1) # 80007ad0 <ticks>
  release(&tickslock);
    80002efc:	00015517          	auipc	a0,0x15
    80002f00:	d3450513          	addi	a0,a0,-716 # 80017c30 <tickslock>
    80002f04:	d89fd0ef          	jal	80000c8c <release>
  return xticks;
}
    80002f08:	02049513          	slli	a0,s1,0x20
    80002f0c:	9101                	srli	a0,a0,0x20
    80002f0e:	60e2                	ld	ra,24(sp)
    80002f10:	6442                	ld	s0,16(sp)
    80002f12:	64a2                	ld	s1,8(sp)
    80002f14:	6105                	addi	sp,sp,32
    80002f16:	8082                	ret

0000000080002f18 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002f18:	7179                	addi	sp,sp,-48
    80002f1a:	f406                	sd	ra,40(sp)
    80002f1c:	f022                	sd	s0,32(sp)
    80002f1e:	ec26                	sd	s1,24(sp)
    80002f20:	e84a                	sd	s2,16(sp)
    80002f22:	e44e                	sd	s3,8(sp)
    80002f24:	e052                	sd	s4,0(sp)
    80002f26:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002f28:	00004597          	auipc	a1,0x4
    80002f2c:	67858593          	addi	a1,a1,1656 # 800075a0 <etext+0x5a0>
    80002f30:	00015517          	auipc	a0,0x15
    80002f34:	d1850513          	addi	a0,a0,-744 # 80017c48 <bcache>
    80002f38:	c3dfd0ef          	jal	80000b74 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002f3c:	0001d797          	auipc	a5,0x1d
    80002f40:	d0c78793          	addi	a5,a5,-756 # 8001fc48 <bcache+0x8000>
    80002f44:	0001d717          	auipc	a4,0x1d
    80002f48:	f6c70713          	addi	a4,a4,-148 # 8001feb0 <bcache+0x8268>
    80002f4c:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002f50:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f54:	00015497          	auipc	s1,0x15
    80002f58:	d0c48493          	addi	s1,s1,-756 # 80017c60 <bcache+0x18>
    b->next = bcache.head.next;
    80002f5c:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002f5e:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002f60:	00004a17          	auipc	s4,0x4
    80002f64:	648a0a13          	addi	s4,s4,1608 # 800075a8 <etext+0x5a8>
    b->next = bcache.head.next;
    80002f68:	2b893783          	ld	a5,696(s2)
    80002f6c:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002f6e:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002f72:	85d2                	mv	a1,s4
    80002f74:	01048513          	addi	a0,s1,16
    80002f78:	29c010ef          	jal	80004214 <initsleeplock>
    bcache.head.next->prev = b;
    80002f7c:	2b893783          	ld	a5,696(s2)
    80002f80:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002f82:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f86:	45848493          	addi	s1,s1,1112
    80002f8a:	fd349fe3          	bne	s1,s3,80002f68 <binit+0x50>
  }
}
    80002f8e:	70a2                	ld	ra,40(sp)
    80002f90:	7402                	ld	s0,32(sp)
    80002f92:	64e2                	ld	s1,24(sp)
    80002f94:	6942                	ld	s2,16(sp)
    80002f96:	69a2                	ld	s3,8(sp)
    80002f98:	6a02                	ld	s4,0(sp)
    80002f9a:	6145                	addi	sp,sp,48
    80002f9c:	8082                	ret

0000000080002f9e <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002f9e:	7179                	addi	sp,sp,-48
    80002fa0:	f406                	sd	ra,40(sp)
    80002fa2:	f022                	sd	s0,32(sp)
    80002fa4:	ec26                	sd	s1,24(sp)
    80002fa6:	e84a                	sd	s2,16(sp)
    80002fa8:	e44e                	sd	s3,8(sp)
    80002faa:	1800                	addi	s0,sp,48
    80002fac:	892a                	mv	s2,a0
    80002fae:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002fb0:	00015517          	auipc	a0,0x15
    80002fb4:	c9850513          	addi	a0,a0,-872 # 80017c48 <bcache>
    80002fb8:	c3dfd0ef          	jal	80000bf4 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002fbc:	0001d497          	auipc	s1,0x1d
    80002fc0:	f444b483          	ld	s1,-188(s1) # 8001ff00 <bcache+0x82b8>
    80002fc4:	0001d797          	auipc	a5,0x1d
    80002fc8:	eec78793          	addi	a5,a5,-276 # 8001feb0 <bcache+0x8268>
    80002fcc:	02f48b63          	beq	s1,a5,80003002 <bread+0x64>
    80002fd0:	873e                	mv	a4,a5
    80002fd2:	a021                	j	80002fda <bread+0x3c>
    80002fd4:	68a4                	ld	s1,80(s1)
    80002fd6:	02e48663          	beq	s1,a4,80003002 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002fda:	449c                	lw	a5,8(s1)
    80002fdc:	ff279ce3          	bne	a5,s2,80002fd4 <bread+0x36>
    80002fe0:	44dc                	lw	a5,12(s1)
    80002fe2:	ff3799e3          	bne	a5,s3,80002fd4 <bread+0x36>
      b->refcnt++;
    80002fe6:	40bc                	lw	a5,64(s1)
    80002fe8:	2785                	addiw	a5,a5,1
    80002fea:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002fec:	00015517          	auipc	a0,0x15
    80002ff0:	c5c50513          	addi	a0,a0,-932 # 80017c48 <bcache>
    80002ff4:	c99fd0ef          	jal	80000c8c <release>
      acquiresleep(&b->lock);
    80002ff8:	01048513          	addi	a0,s1,16
    80002ffc:	24e010ef          	jal	8000424a <acquiresleep>
      return b;
    80003000:	a889                	j	80003052 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003002:	0001d497          	auipc	s1,0x1d
    80003006:	ef64b483          	ld	s1,-266(s1) # 8001fef8 <bcache+0x82b0>
    8000300a:	0001d797          	auipc	a5,0x1d
    8000300e:	ea678793          	addi	a5,a5,-346 # 8001feb0 <bcache+0x8268>
    80003012:	00f48863          	beq	s1,a5,80003022 <bread+0x84>
    80003016:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003018:	40bc                	lw	a5,64(s1)
    8000301a:	cb91                	beqz	a5,8000302e <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000301c:	64a4                	ld	s1,72(s1)
    8000301e:	fee49de3          	bne	s1,a4,80003018 <bread+0x7a>
  panic("bget: no buffers");
    80003022:	00004517          	auipc	a0,0x4
    80003026:	58e50513          	addi	a0,a0,1422 # 800075b0 <etext+0x5b0>
    8000302a:	f6afd0ef          	jal	80000794 <panic>
      b->dev = dev;
    8000302e:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003032:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003036:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000303a:	4785                	li	a5,1
    8000303c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000303e:	00015517          	auipc	a0,0x15
    80003042:	c0a50513          	addi	a0,a0,-1014 # 80017c48 <bcache>
    80003046:	c47fd0ef          	jal	80000c8c <release>
      acquiresleep(&b->lock);
    8000304a:	01048513          	addi	a0,s1,16
    8000304e:	1fc010ef          	jal	8000424a <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003052:	409c                	lw	a5,0(s1)
    80003054:	cb89                	beqz	a5,80003066 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003056:	8526                	mv	a0,s1
    80003058:	70a2                	ld	ra,40(sp)
    8000305a:	7402                	ld	s0,32(sp)
    8000305c:	64e2                	ld	s1,24(sp)
    8000305e:	6942                	ld	s2,16(sp)
    80003060:	69a2                	ld	s3,8(sp)
    80003062:	6145                	addi	sp,sp,48
    80003064:	8082                	ret
    virtio_disk_rw(b, 0);
    80003066:	4581                	li	a1,0
    80003068:	8526                	mv	a0,s1
    8000306a:	247020ef          	jal	80005ab0 <virtio_disk_rw>
    b->valid = 1;
    8000306e:	4785                	li	a5,1
    80003070:	c09c                	sw	a5,0(s1)
  return b;
    80003072:	b7d5                	j	80003056 <bread+0xb8>

0000000080003074 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003074:	1101                	addi	sp,sp,-32
    80003076:	ec06                	sd	ra,24(sp)
    80003078:	e822                	sd	s0,16(sp)
    8000307a:	e426                	sd	s1,8(sp)
    8000307c:	1000                	addi	s0,sp,32
    8000307e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003080:	0541                	addi	a0,a0,16
    80003082:	246010ef          	jal	800042c8 <holdingsleep>
    80003086:	c911                	beqz	a0,8000309a <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003088:	4585                	li	a1,1
    8000308a:	8526                	mv	a0,s1
    8000308c:	225020ef          	jal	80005ab0 <virtio_disk_rw>
}
    80003090:	60e2                	ld	ra,24(sp)
    80003092:	6442                	ld	s0,16(sp)
    80003094:	64a2                	ld	s1,8(sp)
    80003096:	6105                	addi	sp,sp,32
    80003098:	8082                	ret
    panic("bwrite");
    8000309a:	00004517          	auipc	a0,0x4
    8000309e:	52e50513          	addi	a0,a0,1326 # 800075c8 <etext+0x5c8>
    800030a2:	ef2fd0ef          	jal	80000794 <panic>

00000000800030a6 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800030a6:	1101                	addi	sp,sp,-32
    800030a8:	ec06                	sd	ra,24(sp)
    800030aa:	e822                	sd	s0,16(sp)
    800030ac:	e426                	sd	s1,8(sp)
    800030ae:	e04a                	sd	s2,0(sp)
    800030b0:	1000                	addi	s0,sp,32
    800030b2:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800030b4:	01050913          	addi	s2,a0,16
    800030b8:	854a                	mv	a0,s2
    800030ba:	20e010ef          	jal	800042c8 <holdingsleep>
    800030be:	c135                	beqz	a0,80003122 <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    800030c0:	854a                	mv	a0,s2
    800030c2:	1ce010ef          	jal	80004290 <releasesleep>

  acquire(&bcache.lock);
    800030c6:	00015517          	auipc	a0,0x15
    800030ca:	b8250513          	addi	a0,a0,-1150 # 80017c48 <bcache>
    800030ce:	b27fd0ef          	jal	80000bf4 <acquire>
  b->refcnt--;
    800030d2:	40bc                	lw	a5,64(s1)
    800030d4:	37fd                	addiw	a5,a5,-1
    800030d6:	0007871b          	sext.w	a4,a5
    800030da:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800030dc:	e71d                	bnez	a4,8000310a <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800030de:	68b8                	ld	a4,80(s1)
    800030e0:	64bc                	ld	a5,72(s1)
    800030e2:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    800030e4:	68b8                	ld	a4,80(s1)
    800030e6:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800030e8:	0001d797          	auipc	a5,0x1d
    800030ec:	b6078793          	addi	a5,a5,-1184 # 8001fc48 <bcache+0x8000>
    800030f0:	2b87b703          	ld	a4,696(a5)
    800030f4:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800030f6:	0001d717          	auipc	a4,0x1d
    800030fa:	dba70713          	addi	a4,a4,-582 # 8001feb0 <bcache+0x8268>
    800030fe:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003100:	2b87b703          	ld	a4,696(a5)
    80003104:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003106:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000310a:	00015517          	auipc	a0,0x15
    8000310e:	b3e50513          	addi	a0,a0,-1218 # 80017c48 <bcache>
    80003112:	b7bfd0ef          	jal	80000c8c <release>
}
    80003116:	60e2                	ld	ra,24(sp)
    80003118:	6442                	ld	s0,16(sp)
    8000311a:	64a2                	ld	s1,8(sp)
    8000311c:	6902                	ld	s2,0(sp)
    8000311e:	6105                	addi	sp,sp,32
    80003120:	8082                	ret
    panic("brelse");
    80003122:	00004517          	auipc	a0,0x4
    80003126:	4ae50513          	addi	a0,a0,1198 # 800075d0 <etext+0x5d0>
    8000312a:	e6afd0ef          	jal	80000794 <panic>

000000008000312e <bpin>:

void
bpin(struct buf *b) {
    8000312e:	1101                	addi	sp,sp,-32
    80003130:	ec06                	sd	ra,24(sp)
    80003132:	e822                	sd	s0,16(sp)
    80003134:	e426                	sd	s1,8(sp)
    80003136:	1000                	addi	s0,sp,32
    80003138:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000313a:	00015517          	auipc	a0,0x15
    8000313e:	b0e50513          	addi	a0,a0,-1266 # 80017c48 <bcache>
    80003142:	ab3fd0ef          	jal	80000bf4 <acquire>
  b->refcnt++;
    80003146:	40bc                	lw	a5,64(s1)
    80003148:	2785                	addiw	a5,a5,1
    8000314a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000314c:	00015517          	auipc	a0,0x15
    80003150:	afc50513          	addi	a0,a0,-1284 # 80017c48 <bcache>
    80003154:	b39fd0ef          	jal	80000c8c <release>
}
    80003158:	60e2                	ld	ra,24(sp)
    8000315a:	6442                	ld	s0,16(sp)
    8000315c:	64a2                	ld	s1,8(sp)
    8000315e:	6105                	addi	sp,sp,32
    80003160:	8082                	ret

0000000080003162 <bunpin>:

void
bunpin(struct buf *b) {
    80003162:	1101                	addi	sp,sp,-32
    80003164:	ec06                	sd	ra,24(sp)
    80003166:	e822                	sd	s0,16(sp)
    80003168:	e426                	sd	s1,8(sp)
    8000316a:	1000                	addi	s0,sp,32
    8000316c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000316e:	00015517          	auipc	a0,0x15
    80003172:	ada50513          	addi	a0,a0,-1318 # 80017c48 <bcache>
    80003176:	a7ffd0ef          	jal	80000bf4 <acquire>
  b->refcnt--;
    8000317a:	40bc                	lw	a5,64(s1)
    8000317c:	37fd                	addiw	a5,a5,-1
    8000317e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003180:	00015517          	auipc	a0,0x15
    80003184:	ac850513          	addi	a0,a0,-1336 # 80017c48 <bcache>
    80003188:	b05fd0ef          	jal	80000c8c <release>
}
    8000318c:	60e2                	ld	ra,24(sp)
    8000318e:	6442                	ld	s0,16(sp)
    80003190:	64a2                	ld	s1,8(sp)
    80003192:	6105                	addi	sp,sp,32
    80003194:	8082                	ret

0000000080003196 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003196:	1101                	addi	sp,sp,-32
    80003198:	ec06                	sd	ra,24(sp)
    8000319a:	e822                	sd	s0,16(sp)
    8000319c:	e426                	sd	s1,8(sp)
    8000319e:	e04a                	sd	s2,0(sp)
    800031a0:	1000                	addi	s0,sp,32
    800031a2:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800031a4:	00d5d59b          	srliw	a1,a1,0xd
    800031a8:	0001d797          	auipc	a5,0x1d
    800031ac:	17c7a783          	lw	a5,380(a5) # 80020324 <sb+0x1c>
    800031b0:	9dbd                	addw	a1,a1,a5
    800031b2:	dedff0ef          	jal	80002f9e <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800031b6:	0074f713          	andi	a4,s1,7
    800031ba:	4785                	li	a5,1
    800031bc:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800031c0:	14ce                	slli	s1,s1,0x33
    800031c2:	90d9                	srli	s1,s1,0x36
    800031c4:	00950733          	add	a4,a0,s1
    800031c8:	05874703          	lbu	a4,88(a4)
    800031cc:	00e7f6b3          	and	a3,a5,a4
    800031d0:	c29d                	beqz	a3,800031f6 <bfree+0x60>
    800031d2:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800031d4:	94aa                	add	s1,s1,a0
    800031d6:	fff7c793          	not	a5,a5
    800031da:	8f7d                	and	a4,a4,a5
    800031dc:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800031e0:	711000ef          	jal	800040f0 <log_write>
  brelse(bp);
    800031e4:	854a                	mv	a0,s2
    800031e6:	ec1ff0ef          	jal	800030a6 <brelse>
}
    800031ea:	60e2                	ld	ra,24(sp)
    800031ec:	6442                	ld	s0,16(sp)
    800031ee:	64a2                	ld	s1,8(sp)
    800031f0:	6902                	ld	s2,0(sp)
    800031f2:	6105                	addi	sp,sp,32
    800031f4:	8082                	ret
    panic("freeing free block");
    800031f6:	00004517          	auipc	a0,0x4
    800031fa:	3e250513          	addi	a0,a0,994 # 800075d8 <etext+0x5d8>
    800031fe:	d96fd0ef          	jal	80000794 <panic>

0000000080003202 <balloc>:
{
    80003202:	711d                	addi	sp,sp,-96
    80003204:	ec86                	sd	ra,88(sp)
    80003206:	e8a2                	sd	s0,80(sp)
    80003208:	e4a6                	sd	s1,72(sp)
    8000320a:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000320c:	0001d797          	auipc	a5,0x1d
    80003210:	1007a783          	lw	a5,256(a5) # 8002030c <sb+0x4>
    80003214:	0e078f63          	beqz	a5,80003312 <balloc+0x110>
    80003218:	e0ca                	sd	s2,64(sp)
    8000321a:	fc4e                	sd	s3,56(sp)
    8000321c:	f852                	sd	s4,48(sp)
    8000321e:	f456                	sd	s5,40(sp)
    80003220:	f05a                	sd	s6,32(sp)
    80003222:	ec5e                	sd	s7,24(sp)
    80003224:	e862                	sd	s8,16(sp)
    80003226:	e466                	sd	s9,8(sp)
    80003228:	8baa                	mv	s7,a0
    8000322a:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000322c:	0001db17          	auipc	s6,0x1d
    80003230:	0dcb0b13          	addi	s6,s6,220 # 80020308 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003234:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003236:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003238:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000323a:	6c89                	lui	s9,0x2
    8000323c:	a0b5                	j	800032a8 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000323e:	97ca                	add	a5,a5,s2
    80003240:	8e55                	or	a2,a2,a3
    80003242:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003246:	854a                	mv	a0,s2
    80003248:	6a9000ef          	jal	800040f0 <log_write>
        brelse(bp);
    8000324c:	854a                	mv	a0,s2
    8000324e:	e59ff0ef          	jal	800030a6 <brelse>
  bp = bread(dev, bno);
    80003252:	85a6                	mv	a1,s1
    80003254:	855e                	mv	a0,s7
    80003256:	d49ff0ef          	jal	80002f9e <bread>
    8000325a:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000325c:	40000613          	li	a2,1024
    80003260:	4581                	li	a1,0
    80003262:	05850513          	addi	a0,a0,88
    80003266:	a63fd0ef          	jal	80000cc8 <memset>
  log_write(bp);
    8000326a:	854a                	mv	a0,s2
    8000326c:	685000ef          	jal	800040f0 <log_write>
  brelse(bp);
    80003270:	854a                	mv	a0,s2
    80003272:	e35ff0ef          	jal	800030a6 <brelse>
}
    80003276:	6906                	ld	s2,64(sp)
    80003278:	79e2                	ld	s3,56(sp)
    8000327a:	7a42                	ld	s4,48(sp)
    8000327c:	7aa2                	ld	s5,40(sp)
    8000327e:	7b02                	ld	s6,32(sp)
    80003280:	6be2                	ld	s7,24(sp)
    80003282:	6c42                	ld	s8,16(sp)
    80003284:	6ca2                	ld	s9,8(sp)
}
    80003286:	8526                	mv	a0,s1
    80003288:	60e6                	ld	ra,88(sp)
    8000328a:	6446                	ld	s0,80(sp)
    8000328c:	64a6                	ld	s1,72(sp)
    8000328e:	6125                	addi	sp,sp,96
    80003290:	8082                	ret
    brelse(bp);
    80003292:	854a                	mv	a0,s2
    80003294:	e13ff0ef          	jal	800030a6 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003298:	015c87bb          	addw	a5,s9,s5
    8000329c:	00078a9b          	sext.w	s5,a5
    800032a0:	004b2703          	lw	a4,4(s6)
    800032a4:	04eaff63          	bgeu	s5,a4,80003302 <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    800032a8:	41fad79b          	sraiw	a5,s5,0x1f
    800032ac:	0137d79b          	srliw	a5,a5,0x13
    800032b0:	015787bb          	addw	a5,a5,s5
    800032b4:	40d7d79b          	sraiw	a5,a5,0xd
    800032b8:	01cb2583          	lw	a1,28(s6)
    800032bc:	9dbd                	addw	a1,a1,a5
    800032be:	855e                	mv	a0,s7
    800032c0:	cdfff0ef          	jal	80002f9e <bread>
    800032c4:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032c6:	004b2503          	lw	a0,4(s6)
    800032ca:	000a849b          	sext.w	s1,s5
    800032ce:	8762                	mv	a4,s8
    800032d0:	fca4f1e3          	bgeu	s1,a0,80003292 <balloc+0x90>
      m = 1 << (bi % 8);
    800032d4:	00777693          	andi	a3,a4,7
    800032d8:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800032dc:	41f7579b          	sraiw	a5,a4,0x1f
    800032e0:	01d7d79b          	srliw	a5,a5,0x1d
    800032e4:	9fb9                	addw	a5,a5,a4
    800032e6:	4037d79b          	sraiw	a5,a5,0x3
    800032ea:	00f90633          	add	a2,s2,a5
    800032ee:	05864603          	lbu	a2,88(a2)
    800032f2:	00c6f5b3          	and	a1,a3,a2
    800032f6:	d5a1                	beqz	a1,8000323e <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032f8:	2705                	addiw	a4,a4,1
    800032fa:	2485                	addiw	s1,s1,1
    800032fc:	fd471ae3          	bne	a4,s4,800032d0 <balloc+0xce>
    80003300:	bf49                	j	80003292 <balloc+0x90>
    80003302:	6906                	ld	s2,64(sp)
    80003304:	79e2                	ld	s3,56(sp)
    80003306:	7a42                	ld	s4,48(sp)
    80003308:	7aa2                	ld	s5,40(sp)
    8000330a:	7b02                	ld	s6,32(sp)
    8000330c:	6be2                	ld	s7,24(sp)
    8000330e:	6c42                	ld	s8,16(sp)
    80003310:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    80003312:	00004517          	auipc	a0,0x4
    80003316:	2de50513          	addi	a0,a0,734 # 800075f0 <etext+0x5f0>
    8000331a:	9a8fd0ef          	jal	800004c2 <printf>
  return 0;
    8000331e:	4481                	li	s1,0
    80003320:	b79d                	j	80003286 <balloc+0x84>

0000000080003322 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003322:	7179                	addi	sp,sp,-48
    80003324:	f406                	sd	ra,40(sp)
    80003326:	f022                	sd	s0,32(sp)
    80003328:	ec26                	sd	s1,24(sp)
    8000332a:	e84a                	sd	s2,16(sp)
    8000332c:	e44e                	sd	s3,8(sp)
    8000332e:	1800                	addi	s0,sp,48
    80003330:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003332:	47ad                	li	a5,11
    80003334:	02b7e663          	bltu	a5,a1,80003360 <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80003338:	02059793          	slli	a5,a1,0x20
    8000333c:	01e7d593          	srli	a1,a5,0x1e
    80003340:	00b504b3          	add	s1,a0,a1
    80003344:	0504a903          	lw	s2,80(s1)
    80003348:	06091a63          	bnez	s2,800033bc <bmap+0x9a>
      addr = balloc(ip->dev);
    8000334c:	4108                	lw	a0,0(a0)
    8000334e:	eb5ff0ef          	jal	80003202 <balloc>
    80003352:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003356:	06090363          	beqz	s2,800033bc <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    8000335a:	0524a823          	sw	s2,80(s1)
    8000335e:	a8b9                	j	800033bc <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003360:	ff45849b          	addiw	s1,a1,-12
    80003364:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003368:	0ff00793          	li	a5,255
    8000336c:	06e7ee63          	bltu	a5,a4,800033e8 <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003370:	08052903          	lw	s2,128(a0)
    80003374:	00091d63          	bnez	s2,8000338e <bmap+0x6c>
      addr = balloc(ip->dev);
    80003378:	4108                	lw	a0,0(a0)
    8000337a:	e89ff0ef          	jal	80003202 <balloc>
    8000337e:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003382:	02090d63          	beqz	s2,800033bc <bmap+0x9a>
    80003386:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003388:	0929a023          	sw	s2,128(s3)
    8000338c:	a011                	j	80003390 <bmap+0x6e>
    8000338e:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003390:	85ca                	mv	a1,s2
    80003392:	0009a503          	lw	a0,0(s3)
    80003396:	c09ff0ef          	jal	80002f9e <bread>
    8000339a:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000339c:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800033a0:	02049713          	slli	a4,s1,0x20
    800033a4:	01e75593          	srli	a1,a4,0x1e
    800033a8:	00b784b3          	add	s1,a5,a1
    800033ac:	0004a903          	lw	s2,0(s1)
    800033b0:	00090e63          	beqz	s2,800033cc <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800033b4:	8552                	mv	a0,s4
    800033b6:	cf1ff0ef          	jal	800030a6 <brelse>
    return addr;
    800033ba:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800033bc:	854a                	mv	a0,s2
    800033be:	70a2                	ld	ra,40(sp)
    800033c0:	7402                	ld	s0,32(sp)
    800033c2:	64e2                	ld	s1,24(sp)
    800033c4:	6942                	ld	s2,16(sp)
    800033c6:	69a2                	ld	s3,8(sp)
    800033c8:	6145                	addi	sp,sp,48
    800033ca:	8082                	ret
      addr = balloc(ip->dev);
    800033cc:	0009a503          	lw	a0,0(s3)
    800033d0:	e33ff0ef          	jal	80003202 <balloc>
    800033d4:	0005091b          	sext.w	s2,a0
      if(addr){
    800033d8:	fc090ee3          	beqz	s2,800033b4 <bmap+0x92>
        a[bn] = addr;
    800033dc:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800033e0:	8552                	mv	a0,s4
    800033e2:	50f000ef          	jal	800040f0 <log_write>
    800033e6:	b7f9                	j	800033b4 <bmap+0x92>
    800033e8:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    800033ea:	00004517          	auipc	a0,0x4
    800033ee:	21e50513          	addi	a0,a0,542 # 80007608 <etext+0x608>
    800033f2:	ba2fd0ef          	jal	80000794 <panic>

00000000800033f6 <iget>:
{
    800033f6:	7179                	addi	sp,sp,-48
    800033f8:	f406                	sd	ra,40(sp)
    800033fa:	f022                	sd	s0,32(sp)
    800033fc:	ec26                	sd	s1,24(sp)
    800033fe:	e84a                	sd	s2,16(sp)
    80003400:	e44e                	sd	s3,8(sp)
    80003402:	e052                	sd	s4,0(sp)
    80003404:	1800                	addi	s0,sp,48
    80003406:	89aa                	mv	s3,a0
    80003408:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000340a:	0001d517          	auipc	a0,0x1d
    8000340e:	f1e50513          	addi	a0,a0,-226 # 80020328 <itable>
    80003412:	fe2fd0ef          	jal	80000bf4 <acquire>
  empty = 0;
    80003416:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003418:	0001d497          	auipc	s1,0x1d
    8000341c:	f2848493          	addi	s1,s1,-216 # 80020340 <itable+0x18>
    80003420:	0001f697          	auipc	a3,0x1f
    80003424:	9b068693          	addi	a3,a3,-1616 # 80021dd0 <log>
    80003428:	a039                	j	80003436 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000342a:	02090963          	beqz	s2,8000345c <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000342e:	08848493          	addi	s1,s1,136
    80003432:	02d48863          	beq	s1,a3,80003462 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003436:	449c                	lw	a5,8(s1)
    80003438:	fef059e3          	blez	a5,8000342a <iget+0x34>
    8000343c:	4098                	lw	a4,0(s1)
    8000343e:	ff3716e3          	bne	a4,s3,8000342a <iget+0x34>
    80003442:	40d8                	lw	a4,4(s1)
    80003444:	ff4713e3          	bne	a4,s4,8000342a <iget+0x34>
      ip->ref++;
    80003448:	2785                	addiw	a5,a5,1
    8000344a:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000344c:	0001d517          	auipc	a0,0x1d
    80003450:	edc50513          	addi	a0,a0,-292 # 80020328 <itable>
    80003454:	839fd0ef          	jal	80000c8c <release>
      return ip;
    80003458:	8926                	mv	s2,s1
    8000345a:	a02d                	j	80003484 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000345c:	fbe9                	bnez	a5,8000342e <iget+0x38>
      empty = ip;
    8000345e:	8926                	mv	s2,s1
    80003460:	b7f9                	j	8000342e <iget+0x38>
  if(empty == 0)
    80003462:	02090a63          	beqz	s2,80003496 <iget+0xa0>
  ip->dev = dev;
    80003466:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000346a:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000346e:	4785                	li	a5,1
    80003470:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003474:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003478:	0001d517          	auipc	a0,0x1d
    8000347c:	eb050513          	addi	a0,a0,-336 # 80020328 <itable>
    80003480:	80dfd0ef          	jal	80000c8c <release>
}
    80003484:	854a                	mv	a0,s2
    80003486:	70a2                	ld	ra,40(sp)
    80003488:	7402                	ld	s0,32(sp)
    8000348a:	64e2                	ld	s1,24(sp)
    8000348c:	6942                	ld	s2,16(sp)
    8000348e:	69a2                	ld	s3,8(sp)
    80003490:	6a02                	ld	s4,0(sp)
    80003492:	6145                	addi	sp,sp,48
    80003494:	8082                	ret
    panic("iget: no inodes");
    80003496:	00004517          	auipc	a0,0x4
    8000349a:	18a50513          	addi	a0,a0,394 # 80007620 <etext+0x620>
    8000349e:	af6fd0ef          	jal	80000794 <panic>

00000000800034a2 <fsinit>:
fsinit(int dev) {
    800034a2:	7179                	addi	sp,sp,-48
    800034a4:	f406                	sd	ra,40(sp)
    800034a6:	f022                	sd	s0,32(sp)
    800034a8:	ec26                	sd	s1,24(sp)
    800034aa:	e84a                	sd	s2,16(sp)
    800034ac:	e44e                	sd	s3,8(sp)
    800034ae:	1800                	addi	s0,sp,48
    800034b0:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800034b2:	4585                	li	a1,1
    800034b4:	aebff0ef          	jal	80002f9e <bread>
    800034b8:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800034ba:	0001d997          	auipc	s3,0x1d
    800034be:	e4e98993          	addi	s3,s3,-434 # 80020308 <sb>
    800034c2:	02000613          	li	a2,32
    800034c6:	05850593          	addi	a1,a0,88
    800034ca:	854e                	mv	a0,s3
    800034cc:	859fd0ef          	jal	80000d24 <memmove>
  brelse(bp);
    800034d0:	8526                	mv	a0,s1
    800034d2:	bd5ff0ef          	jal	800030a6 <brelse>
  if(sb.magic != FSMAGIC)
    800034d6:	0009a703          	lw	a4,0(s3)
    800034da:	102037b7          	lui	a5,0x10203
    800034de:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800034e2:	02f71063          	bne	a4,a5,80003502 <fsinit+0x60>
  initlog(dev, &sb);
    800034e6:	0001d597          	auipc	a1,0x1d
    800034ea:	e2258593          	addi	a1,a1,-478 # 80020308 <sb>
    800034ee:	854a                	mv	a0,s2
    800034f0:	1f9000ef          	jal	80003ee8 <initlog>
}
    800034f4:	70a2                	ld	ra,40(sp)
    800034f6:	7402                	ld	s0,32(sp)
    800034f8:	64e2                	ld	s1,24(sp)
    800034fa:	6942                	ld	s2,16(sp)
    800034fc:	69a2                	ld	s3,8(sp)
    800034fe:	6145                	addi	sp,sp,48
    80003500:	8082                	ret
    panic("invalid file system");
    80003502:	00004517          	auipc	a0,0x4
    80003506:	12e50513          	addi	a0,a0,302 # 80007630 <etext+0x630>
    8000350a:	a8afd0ef          	jal	80000794 <panic>

000000008000350e <iinit>:
{
    8000350e:	7179                	addi	sp,sp,-48
    80003510:	f406                	sd	ra,40(sp)
    80003512:	f022                	sd	s0,32(sp)
    80003514:	ec26                	sd	s1,24(sp)
    80003516:	e84a                	sd	s2,16(sp)
    80003518:	e44e                	sd	s3,8(sp)
    8000351a:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000351c:	00004597          	auipc	a1,0x4
    80003520:	12c58593          	addi	a1,a1,300 # 80007648 <etext+0x648>
    80003524:	0001d517          	auipc	a0,0x1d
    80003528:	e0450513          	addi	a0,a0,-508 # 80020328 <itable>
    8000352c:	e48fd0ef          	jal	80000b74 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003530:	0001d497          	auipc	s1,0x1d
    80003534:	e2048493          	addi	s1,s1,-480 # 80020350 <itable+0x28>
    80003538:	0001f997          	auipc	s3,0x1f
    8000353c:	8a898993          	addi	s3,s3,-1880 # 80021de0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003540:	00004917          	auipc	s2,0x4
    80003544:	11090913          	addi	s2,s2,272 # 80007650 <etext+0x650>
    80003548:	85ca                	mv	a1,s2
    8000354a:	8526                	mv	a0,s1
    8000354c:	4c9000ef          	jal	80004214 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003550:	08848493          	addi	s1,s1,136
    80003554:	ff349ae3          	bne	s1,s3,80003548 <iinit+0x3a>
}
    80003558:	70a2                	ld	ra,40(sp)
    8000355a:	7402                	ld	s0,32(sp)
    8000355c:	64e2                	ld	s1,24(sp)
    8000355e:	6942                	ld	s2,16(sp)
    80003560:	69a2                	ld	s3,8(sp)
    80003562:	6145                	addi	sp,sp,48
    80003564:	8082                	ret

0000000080003566 <ialloc>:
{
    80003566:	7139                	addi	sp,sp,-64
    80003568:	fc06                	sd	ra,56(sp)
    8000356a:	f822                	sd	s0,48(sp)
    8000356c:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    8000356e:	0001d717          	auipc	a4,0x1d
    80003572:	da672703          	lw	a4,-602(a4) # 80020314 <sb+0xc>
    80003576:	4785                	li	a5,1
    80003578:	06e7f063          	bgeu	a5,a4,800035d8 <ialloc+0x72>
    8000357c:	f426                	sd	s1,40(sp)
    8000357e:	f04a                	sd	s2,32(sp)
    80003580:	ec4e                	sd	s3,24(sp)
    80003582:	e852                	sd	s4,16(sp)
    80003584:	e456                	sd	s5,8(sp)
    80003586:	e05a                	sd	s6,0(sp)
    80003588:	8aaa                	mv	s5,a0
    8000358a:	8b2e                	mv	s6,a1
    8000358c:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000358e:	0001da17          	auipc	s4,0x1d
    80003592:	d7aa0a13          	addi	s4,s4,-646 # 80020308 <sb>
    80003596:	00495593          	srli	a1,s2,0x4
    8000359a:	018a2783          	lw	a5,24(s4)
    8000359e:	9dbd                	addw	a1,a1,a5
    800035a0:	8556                	mv	a0,s5
    800035a2:	9fdff0ef          	jal	80002f9e <bread>
    800035a6:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800035a8:	05850993          	addi	s3,a0,88
    800035ac:	00f97793          	andi	a5,s2,15
    800035b0:	079a                	slli	a5,a5,0x6
    800035b2:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800035b4:	00099783          	lh	a5,0(s3)
    800035b8:	cb9d                	beqz	a5,800035ee <ialloc+0x88>
    brelse(bp);
    800035ba:	aedff0ef          	jal	800030a6 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800035be:	0905                	addi	s2,s2,1
    800035c0:	00ca2703          	lw	a4,12(s4)
    800035c4:	0009079b          	sext.w	a5,s2
    800035c8:	fce7e7e3          	bltu	a5,a4,80003596 <ialloc+0x30>
    800035cc:	74a2                	ld	s1,40(sp)
    800035ce:	7902                	ld	s2,32(sp)
    800035d0:	69e2                	ld	s3,24(sp)
    800035d2:	6a42                	ld	s4,16(sp)
    800035d4:	6aa2                	ld	s5,8(sp)
    800035d6:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800035d8:	00004517          	auipc	a0,0x4
    800035dc:	08050513          	addi	a0,a0,128 # 80007658 <etext+0x658>
    800035e0:	ee3fc0ef          	jal	800004c2 <printf>
  return 0;
    800035e4:	4501                	li	a0,0
}
    800035e6:	70e2                	ld	ra,56(sp)
    800035e8:	7442                	ld	s0,48(sp)
    800035ea:	6121                	addi	sp,sp,64
    800035ec:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800035ee:	04000613          	li	a2,64
    800035f2:	4581                	li	a1,0
    800035f4:	854e                	mv	a0,s3
    800035f6:	ed2fd0ef          	jal	80000cc8 <memset>
      dip->type = type;
    800035fa:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800035fe:	8526                	mv	a0,s1
    80003600:	2f1000ef          	jal	800040f0 <log_write>
      brelse(bp);
    80003604:	8526                	mv	a0,s1
    80003606:	aa1ff0ef          	jal	800030a6 <brelse>
      return iget(dev, inum);
    8000360a:	0009059b          	sext.w	a1,s2
    8000360e:	8556                	mv	a0,s5
    80003610:	de7ff0ef          	jal	800033f6 <iget>
    80003614:	74a2                	ld	s1,40(sp)
    80003616:	7902                	ld	s2,32(sp)
    80003618:	69e2                	ld	s3,24(sp)
    8000361a:	6a42                	ld	s4,16(sp)
    8000361c:	6aa2                	ld	s5,8(sp)
    8000361e:	6b02                	ld	s6,0(sp)
    80003620:	b7d9                	j	800035e6 <ialloc+0x80>

0000000080003622 <iupdate>:
{
    80003622:	1101                	addi	sp,sp,-32
    80003624:	ec06                	sd	ra,24(sp)
    80003626:	e822                	sd	s0,16(sp)
    80003628:	e426                	sd	s1,8(sp)
    8000362a:	e04a                	sd	s2,0(sp)
    8000362c:	1000                	addi	s0,sp,32
    8000362e:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003630:	415c                	lw	a5,4(a0)
    80003632:	0047d79b          	srliw	a5,a5,0x4
    80003636:	0001d597          	auipc	a1,0x1d
    8000363a:	cea5a583          	lw	a1,-790(a1) # 80020320 <sb+0x18>
    8000363e:	9dbd                	addw	a1,a1,a5
    80003640:	4108                	lw	a0,0(a0)
    80003642:	95dff0ef          	jal	80002f9e <bread>
    80003646:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003648:	05850793          	addi	a5,a0,88
    8000364c:	40d8                	lw	a4,4(s1)
    8000364e:	8b3d                	andi	a4,a4,15
    80003650:	071a                	slli	a4,a4,0x6
    80003652:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003654:	04449703          	lh	a4,68(s1)
    80003658:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000365c:	04649703          	lh	a4,70(s1)
    80003660:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003664:	04849703          	lh	a4,72(s1)
    80003668:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000366c:	04a49703          	lh	a4,74(s1)
    80003670:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003674:	44f8                	lw	a4,76(s1)
    80003676:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003678:	03400613          	li	a2,52
    8000367c:	05048593          	addi	a1,s1,80
    80003680:	00c78513          	addi	a0,a5,12
    80003684:	ea0fd0ef          	jal	80000d24 <memmove>
  log_write(bp);
    80003688:	854a                	mv	a0,s2
    8000368a:	267000ef          	jal	800040f0 <log_write>
  brelse(bp);
    8000368e:	854a                	mv	a0,s2
    80003690:	a17ff0ef          	jal	800030a6 <brelse>
}
    80003694:	60e2                	ld	ra,24(sp)
    80003696:	6442                	ld	s0,16(sp)
    80003698:	64a2                	ld	s1,8(sp)
    8000369a:	6902                	ld	s2,0(sp)
    8000369c:	6105                	addi	sp,sp,32
    8000369e:	8082                	ret

00000000800036a0 <idup>:
{
    800036a0:	1101                	addi	sp,sp,-32
    800036a2:	ec06                	sd	ra,24(sp)
    800036a4:	e822                	sd	s0,16(sp)
    800036a6:	e426                	sd	s1,8(sp)
    800036a8:	1000                	addi	s0,sp,32
    800036aa:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800036ac:	0001d517          	auipc	a0,0x1d
    800036b0:	c7c50513          	addi	a0,a0,-900 # 80020328 <itable>
    800036b4:	d40fd0ef          	jal	80000bf4 <acquire>
  ip->ref++;
    800036b8:	449c                	lw	a5,8(s1)
    800036ba:	2785                	addiw	a5,a5,1
    800036bc:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800036be:	0001d517          	auipc	a0,0x1d
    800036c2:	c6a50513          	addi	a0,a0,-918 # 80020328 <itable>
    800036c6:	dc6fd0ef          	jal	80000c8c <release>
}
    800036ca:	8526                	mv	a0,s1
    800036cc:	60e2                	ld	ra,24(sp)
    800036ce:	6442                	ld	s0,16(sp)
    800036d0:	64a2                	ld	s1,8(sp)
    800036d2:	6105                	addi	sp,sp,32
    800036d4:	8082                	ret

00000000800036d6 <ilock>:
{
    800036d6:	1101                	addi	sp,sp,-32
    800036d8:	ec06                	sd	ra,24(sp)
    800036da:	e822                	sd	s0,16(sp)
    800036dc:	e426                	sd	s1,8(sp)
    800036de:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800036e0:	cd19                	beqz	a0,800036fe <ilock+0x28>
    800036e2:	84aa                	mv	s1,a0
    800036e4:	451c                	lw	a5,8(a0)
    800036e6:	00f05c63          	blez	a5,800036fe <ilock+0x28>
  acquiresleep(&ip->lock);
    800036ea:	0541                	addi	a0,a0,16
    800036ec:	35f000ef          	jal	8000424a <acquiresleep>
  if(ip->valid == 0){
    800036f0:	40bc                	lw	a5,64(s1)
    800036f2:	cf89                	beqz	a5,8000370c <ilock+0x36>
}
    800036f4:	60e2                	ld	ra,24(sp)
    800036f6:	6442                	ld	s0,16(sp)
    800036f8:	64a2                	ld	s1,8(sp)
    800036fa:	6105                	addi	sp,sp,32
    800036fc:	8082                	ret
    800036fe:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003700:	00004517          	auipc	a0,0x4
    80003704:	f7050513          	addi	a0,a0,-144 # 80007670 <etext+0x670>
    80003708:	88cfd0ef          	jal	80000794 <panic>
    8000370c:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000370e:	40dc                	lw	a5,4(s1)
    80003710:	0047d79b          	srliw	a5,a5,0x4
    80003714:	0001d597          	auipc	a1,0x1d
    80003718:	c0c5a583          	lw	a1,-1012(a1) # 80020320 <sb+0x18>
    8000371c:	9dbd                	addw	a1,a1,a5
    8000371e:	4088                	lw	a0,0(s1)
    80003720:	87fff0ef          	jal	80002f9e <bread>
    80003724:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003726:	05850593          	addi	a1,a0,88
    8000372a:	40dc                	lw	a5,4(s1)
    8000372c:	8bbd                	andi	a5,a5,15
    8000372e:	079a                	slli	a5,a5,0x6
    80003730:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003732:	00059783          	lh	a5,0(a1)
    80003736:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000373a:	00259783          	lh	a5,2(a1)
    8000373e:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003742:	00459783          	lh	a5,4(a1)
    80003746:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000374a:	00659783          	lh	a5,6(a1)
    8000374e:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003752:	459c                	lw	a5,8(a1)
    80003754:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003756:	03400613          	li	a2,52
    8000375a:	05b1                	addi	a1,a1,12
    8000375c:	05048513          	addi	a0,s1,80
    80003760:	dc4fd0ef          	jal	80000d24 <memmove>
    brelse(bp);
    80003764:	854a                	mv	a0,s2
    80003766:	941ff0ef          	jal	800030a6 <brelse>
    ip->valid = 1;
    8000376a:	4785                	li	a5,1
    8000376c:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000376e:	04449783          	lh	a5,68(s1)
    80003772:	c399                	beqz	a5,80003778 <ilock+0xa2>
    80003774:	6902                	ld	s2,0(sp)
    80003776:	bfbd                	j	800036f4 <ilock+0x1e>
      panic("ilock: no type");
    80003778:	00004517          	auipc	a0,0x4
    8000377c:	f0050513          	addi	a0,a0,-256 # 80007678 <etext+0x678>
    80003780:	814fd0ef          	jal	80000794 <panic>

0000000080003784 <iunlock>:
{
    80003784:	1101                	addi	sp,sp,-32
    80003786:	ec06                	sd	ra,24(sp)
    80003788:	e822                	sd	s0,16(sp)
    8000378a:	e426                	sd	s1,8(sp)
    8000378c:	e04a                	sd	s2,0(sp)
    8000378e:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003790:	c505                	beqz	a0,800037b8 <iunlock+0x34>
    80003792:	84aa                	mv	s1,a0
    80003794:	01050913          	addi	s2,a0,16
    80003798:	854a                	mv	a0,s2
    8000379a:	32f000ef          	jal	800042c8 <holdingsleep>
    8000379e:	cd09                	beqz	a0,800037b8 <iunlock+0x34>
    800037a0:	449c                	lw	a5,8(s1)
    800037a2:	00f05b63          	blez	a5,800037b8 <iunlock+0x34>
  releasesleep(&ip->lock);
    800037a6:	854a                	mv	a0,s2
    800037a8:	2e9000ef          	jal	80004290 <releasesleep>
}
    800037ac:	60e2                	ld	ra,24(sp)
    800037ae:	6442                	ld	s0,16(sp)
    800037b0:	64a2                	ld	s1,8(sp)
    800037b2:	6902                	ld	s2,0(sp)
    800037b4:	6105                	addi	sp,sp,32
    800037b6:	8082                	ret
    panic("iunlock");
    800037b8:	00004517          	auipc	a0,0x4
    800037bc:	ed050513          	addi	a0,a0,-304 # 80007688 <etext+0x688>
    800037c0:	fd5fc0ef          	jal	80000794 <panic>

00000000800037c4 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800037c4:	7179                	addi	sp,sp,-48
    800037c6:	f406                	sd	ra,40(sp)
    800037c8:	f022                	sd	s0,32(sp)
    800037ca:	ec26                	sd	s1,24(sp)
    800037cc:	e84a                	sd	s2,16(sp)
    800037ce:	e44e                	sd	s3,8(sp)
    800037d0:	1800                	addi	s0,sp,48
    800037d2:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800037d4:	05050493          	addi	s1,a0,80
    800037d8:	08050913          	addi	s2,a0,128
    800037dc:	a021                	j	800037e4 <itrunc+0x20>
    800037de:	0491                	addi	s1,s1,4
    800037e0:	01248b63          	beq	s1,s2,800037f6 <itrunc+0x32>
    if(ip->addrs[i]){
    800037e4:	408c                	lw	a1,0(s1)
    800037e6:	dde5                	beqz	a1,800037de <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800037e8:	0009a503          	lw	a0,0(s3)
    800037ec:	9abff0ef          	jal	80003196 <bfree>
      ip->addrs[i] = 0;
    800037f0:	0004a023          	sw	zero,0(s1)
    800037f4:	b7ed                	j	800037de <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800037f6:	0809a583          	lw	a1,128(s3)
    800037fa:	ed89                	bnez	a1,80003814 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800037fc:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003800:	854e                	mv	a0,s3
    80003802:	e21ff0ef          	jal	80003622 <iupdate>
}
    80003806:	70a2                	ld	ra,40(sp)
    80003808:	7402                	ld	s0,32(sp)
    8000380a:	64e2                	ld	s1,24(sp)
    8000380c:	6942                	ld	s2,16(sp)
    8000380e:	69a2                	ld	s3,8(sp)
    80003810:	6145                	addi	sp,sp,48
    80003812:	8082                	ret
    80003814:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003816:	0009a503          	lw	a0,0(s3)
    8000381a:	f84ff0ef          	jal	80002f9e <bread>
    8000381e:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003820:	05850493          	addi	s1,a0,88
    80003824:	45850913          	addi	s2,a0,1112
    80003828:	a021                	j	80003830 <itrunc+0x6c>
    8000382a:	0491                	addi	s1,s1,4
    8000382c:	01248963          	beq	s1,s2,8000383e <itrunc+0x7a>
      if(a[j])
    80003830:	408c                	lw	a1,0(s1)
    80003832:	dde5                	beqz	a1,8000382a <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003834:	0009a503          	lw	a0,0(s3)
    80003838:	95fff0ef          	jal	80003196 <bfree>
    8000383c:	b7fd                	j	8000382a <itrunc+0x66>
    brelse(bp);
    8000383e:	8552                	mv	a0,s4
    80003840:	867ff0ef          	jal	800030a6 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003844:	0809a583          	lw	a1,128(s3)
    80003848:	0009a503          	lw	a0,0(s3)
    8000384c:	94bff0ef          	jal	80003196 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003850:	0809a023          	sw	zero,128(s3)
    80003854:	6a02                	ld	s4,0(sp)
    80003856:	b75d                	j	800037fc <itrunc+0x38>

0000000080003858 <iput>:
{
    80003858:	1101                	addi	sp,sp,-32
    8000385a:	ec06                	sd	ra,24(sp)
    8000385c:	e822                	sd	s0,16(sp)
    8000385e:	e426                	sd	s1,8(sp)
    80003860:	1000                	addi	s0,sp,32
    80003862:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003864:	0001d517          	auipc	a0,0x1d
    80003868:	ac450513          	addi	a0,a0,-1340 # 80020328 <itable>
    8000386c:	b88fd0ef          	jal	80000bf4 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003870:	4498                	lw	a4,8(s1)
    80003872:	4785                	li	a5,1
    80003874:	02f70063          	beq	a4,a5,80003894 <iput+0x3c>
  ip->ref--;
    80003878:	449c                	lw	a5,8(s1)
    8000387a:	37fd                	addiw	a5,a5,-1
    8000387c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000387e:	0001d517          	auipc	a0,0x1d
    80003882:	aaa50513          	addi	a0,a0,-1366 # 80020328 <itable>
    80003886:	c06fd0ef          	jal	80000c8c <release>
}
    8000388a:	60e2                	ld	ra,24(sp)
    8000388c:	6442                	ld	s0,16(sp)
    8000388e:	64a2                	ld	s1,8(sp)
    80003890:	6105                	addi	sp,sp,32
    80003892:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003894:	40bc                	lw	a5,64(s1)
    80003896:	d3ed                	beqz	a5,80003878 <iput+0x20>
    80003898:	04a49783          	lh	a5,74(s1)
    8000389c:	fff1                	bnez	a5,80003878 <iput+0x20>
    8000389e:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    800038a0:	01048913          	addi	s2,s1,16
    800038a4:	854a                	mv	a0,s2
    800038a6:	1a5000ef          	jal	8000424a <acquiresleep>
    release(&itable.lock);
    800038aa:	0001d517          	auipc	a0,0x1d
    800038ae:	a7e50513          	addi	a0,a0,-1410 # 80020328 <itable>
    800038b2:	bdafd0ef          	jal	80000c8c <release>
    itrunc(ip);
    800038b6:	8526                	mv	a0,s1
    800038b8:	f0dff0ef          	jal	800037c4 <itrunc>
    ip->type = 0;
    800038bc:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800038c0:	8526                	mv	a0,s1
    800038c2:	d61ff0ef          	jal	80003622 <iupdate>
    ip->valid = 0;
    800038c6:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800038ca:	854a                	mv	a0,s2
    800038cc:	1c5000ef          	jal	80004290 <releasesleep>
    acquire(&itable.lock);
    800038d0:	0001d517          	auipc	a0,0x1d
    800038d4:	a5850513          	addi	a0,a0,-1448 # 80020328 <itable>
    800038d8:	b1cfd0ef          	jal	80000bf4 <acquire>
    800038dc:	6902                	ld	s2,0(sp)
    800038de:	bf69                	j	80003878 <iput+0x20>

00000000800038e0 <iunlockput>:
{
    800038e0:	1101                	addi	sp,sp,-32
    800038e2:	ec06                	sd	ra,24(sp)
    800038e4:	e822                	sd	s0,16(sp)
    800038e6:	e426                	sd	s1,8(sp)
    800038e8:	1000                	addi	s0,sp,32
    800038ea:	84aa                	mv	s1,a0
  iunlock(ip);
    800038ec:	e99ff0ef          	jal	80003784 <iunlock>
  iput(ip);
    800038f0:	8526                	mv	a0,s1
    800038f2:	f67ff0ef          	jal	80003858 <iput>
}
    800038f6:	60e2                	ld	ra,24(sp)
    800038f8:	6442                	ld	s0,16(sp)
    800038fa:	64a2                	ld	s1,8(sp)
    800038fc:	6105                	addi	sp,sp,32
    800038fe:	8082                	ret

0000000080003900 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003900:	1141                	addi	sp,sp,-16
    80003902:	e422                	sd	s0,8(sp)
    80003904:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003906:	411c                	lw	a5,0(a0)
    80003908:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000390a:	415c                	lw	a5,4(a0)
    8000390c:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000390e:	04451783          	lh	a5,68(a0)
    80003912:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003916:	04a51783          	lh	a5,74(a0)
    8000391a:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000391e:	04c56783          	lwu	a5,76(a0)
    80003922:	e99c                	sd	a5,16(a1)
}
    80003924:	6422                	ld	s0,8(sp)
    80003926:	0141                	addi	sp,sp,16
    80003928:	8082                	ret

000000008000392a <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000392a:	457c                	lw	a5,76(a0)
    8000392c:	0ed7eb63          	bltu	a5,a3,80003a22 <readi+0xf8>
{
    80003930:	7159                	addi	sp,sp,-112
    80003932:	f486                	sd	ra,104(sp)
    80003934:	f0a2                	sd	s0,96(sp)
    80003936:	eca6                	sd	s1,88(sp)
    80003938:	e0d2                	sd	s4,64(sp)
    8000393a:	fc56                	sd	s5,56(sp)
    8000393c:	f85a                	sd	s6,48(sp)
    8000393e:	f45e                	sd	s7,40(sp)
    80003940:	1880                	addi	s0,sp,112
    80003942:	8b2a                	mv	s6,a0
    80003944:	8bae                	mv	s7,a1
    80003946:	8a32                	mv	s4,a2
    80003948:	84b6                	mv	s1,a3
    8000394a:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    8000394c:	9f35                	addw	a4,a4,a3
    return 0;
    8000394e:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003950:	0cd76063          	bltu	a4,a3,80003a10 <readi+0xe6>
    80003954:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003956:	00e7f463          	bgeu	a5,a4,8000395e <readi+0x34>
    n = ip->size - off;
    8000395a:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000395e:	080a8f63          	beqz	s5,800039fc <readi+0xd2>
    80003962:	e8ca                	sd	s2,80(sp)
    80003964:	f062                	sd	s8,32(sp)
    80003966:	ec66                	sd	s9,24(sp)
    80003968:	e86a                	sd	s10,16(sp)
    8000396a:	e46e                	sd	s11,8(sp)
    8000396c:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000396e:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003972:	5c7d                	li	s8,-1
    80003974:	a80d                	j	800039a6 <readi+0x7c>
    80003976:	020d1d93          	slli	s11,s10,0x20
    8000397a:	020ddd93          	srli	s11,s11,0x20
    8000397e:	05890613          	addi	a2,s2,88
    80003982:	86ee                	mv	a3,s11
    80003984:	963a                	add	a2,a2,a4
    80003986:	85d2                	mv	a1,s4
    80003988:	855e                	mv	a0,s7
    8000398a:	c4ffe0ef          	jal	800025d8 <either_copyout>
    8000398e:	05850763          	beq	a0,s8,800039dc <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003992:	854a                	mv	a0,s2
    80003994:	f12ff0ef          	jal	800030a6 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003998:	013d09bb          	addw	s3,s10,s3
    8000399c:	009d04bb          	addw	s1,s10,s1
    800039a0:	9a6e                	add	s4,s4,s11
    800039a2:	0559f763          	bgeu	s3,s5,800039f0 <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    800039a6:	00a4d59b          	srliw	a1,s1,0xa
    800039aa:	855a                	mv	a0,s6
    800039ac:	977ff0ef          	jal	80003322 <bmap>
    800039b0:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800039b4:	c5b1                	beqz	a1,80003a00 <readi+0xd6>
    bp = bread(ip->dev, addr);
    800039b6:	000b2503          	lw	a0,0(s6)
    800039ba:	de4ff0ef          	jal	80002f9e <bread>
    800039be:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800039c0:	3ff4f713          	andi	a4,s1,1023
    800039c4:	40ec87bb          	subw	a5,s9,a4
    800039c8:	413a86bb          	subw	a3,s5,s3
    800039cc:	8d3e                	mv	s10,a5
    800039ce:	2781                	sext.w	a5,a5
    800039d0:	0006861b          	sext.w	a2,a3
    800039d4:	faf671e3          	bgeu	a2,a5,80003976 <readi+0x4c>
    800039d8:	8d36                	mv	s10,a3
    800039da:	bf71                	j	80003976 <readi+0x4c>
      brelse(bp);
    800039dc:	854a                	mv	a0,s2
    800039de:	ec8ff0ef          	jal	800030a6 <brelse>
      tot = -1;
    800039e2:	59fd                	li	s3,-1
      break;
    800039e4:	6946                	ld	s2,80(sp)
    800039e6:	7c02                	ld	s8,32(sp)
    800039e8:	6ce2                	ld	s9,24(sp)
    800039ea:	6d42                	ld	s10,16(sp)
    800039ec:	6da2                	ld	s11,8(sp)
    800039ee:	a831                	j	80003a0a <readi+0xe0>
    800039f0:	6946                	ld	s2,80(sp)
    800039f2:	7c02                	ld	s8,32(sp)
    800039f4:	6ce2                	ld	s9,24(sp)
    800039f6:	6d42                	ld	s10,16(sp)
    800039f8:	6da2                	ld	s11,8(sp)
    800039fa:	a801                	j	80003a0a <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800039fc:	89d6                	mv	s3,s5
    800039fe:	a031                	j	80003a0a <readi+0xe0>
    80003a00:	6946                	ld	s2,80(sp)
    80003a02:	7c02                	ld	s8,32(sp)
    80003a04:	6ce2                	ld	s9,24(sp)
    80003a06:	6d42                	ld	s10,16(sp)
    80003a08:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003a0a:	0009851b          	sext.w	a0,s3
    80003a0e:	69a6                	ld	s3,72(sp)
}
    80003a10:	70a6                	ld	ra,104(sp)
    80003a12:	7406                	ld	s0,96(sp)
    80003a14:	64e6                	ld	s1,88(sp)
    80003a16:	6a06                	ld	s4,64(sp)
    80003a18:	7ae2                	ld	s5,56(sp)
    80003a1a:	7b42                	ld	s6,48(sp)
    80003a1c:	7ba2                	ld	s7,40(sp)
    80003a1e:	6165                	addi	sp,sp,112
    80003a20:	8082                	ret
    return 0;
    80003a22:	4501                	li	a0,0
}
    80003a24:	8082                	ret

0000000080003a26 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a26:	457c                	lw	a5,76(a0)
    80003a28:	10d7e063          	bltu	a5,a3,80003b28 <writei+0x102>
{
    80003a2c:	7159                	addi	sp,sp,-112
    80003a2e:	f486                	sd	ra,104(sp)
    80003a30:	f0a2                	sd	s0,96(sp)
    80003a32:	e8ca                	sd	s2,80(sp)
    80003a34:	e0d2                	sd	s4,64(sp)
    80003a36:	fc56                	sd	s5,56(sp)
    80003a38:	f85a                	sd	s6,48(sp)
    80003a3a:	f45e                	sd	s7,40(sp)
    80003a3c:	1880                	addi	s0,sp,112
    80003a3e:	8aaa                	mv	s5,a0
    80003a40:	8bae                	mv	s7,a1
    80003a42:	8a32                	mv	s4,a2
    80003a44:	8936                	mv	s2,a3
    80003a46:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003a48:	00e687bb          	addw	a5,a3,a4
    80003a4c:	0ed7e063          	bltu	a5,a3,80003b2c <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003a50:	00043737          	lui	a4,0x43
    80003a54:	0cf76e63          	bltu	a4,a5,80003b30 <writei+0x10a>
    80003a58:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a5a:	0a0b0f63          	beqz	s6,80003b18 <writei+0xf2>
    80003a5e:	eca6                	sd	s1,88(sp)
    80003a60:	f062                	sd	s8,32(sp)
    80003a62:	ec66                	sd	s9,24(sp)
    80003a64:	e86a                	sd	s10,16(sp)
    80003a66:	e46e                	sd	s11,8(sp)
    80003a68:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a6a:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003a6e:	5c7d                	li	s8,-1
    80003a70:	a825                	j	80003aa8 <writei+0x82>
    80003a72:	020d1d93          	slli	s11,s10,0x20
    80003a76:	020ddd93          	srli	s11,s11,0x20
    80003a7a:	05848513          	addi	a0,s1,88
    80003a7e:	86ee                	mv	a3,s11
    80003a80:	8652                	mv	a2,s4
    80003a82:	85de                	mv	a1,s7
    80003a84:	953a                	add	a0,a0,a4
    80003a86:	b9dfe0ef          	jal	80002622 <either_copyin>
    80003a8a:	05850a63          	beq	a0,s8,80003ade <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003a8e:	8526                	mv	a0,s1
    80003a90:	660000ef          	jal	800040f0 <log_write>
    brelse(bp);
    80003a94:	8526                	mv	a0,s1
    80003a96:	e10ff0ef          	jal	800030a6 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a9a:	013d09bb          	addw	s3,s10,s3
    80003a9e:	012d093b          	addw	s2,s10,s2
    80003aa2:	9a6e                	add	s4,s4,s11
    80003aa4:	0569f063          	bgeu	s3,s6,80003ae4 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80003aa8:	00a9559b          	srliw	a1,s2,0xa
    80003aac:	8556                	mv	a0,s5
    80003aae:	875ff0ef          	jal	80003322 <bmap>
    80003ab2:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003ab6:	c59d                	beqz	a1,80003ae4 <writei+0xbe>
    bp = bread(ip->dev, addr);
    80003ab8:	000aa503          	lw	a0,0(s5)
    80003abc:	ce2ff0ef          	jal	80002f9e <bread>
    80003ac0:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ac2:	3ff97713          	andi	a4,s2,1023
    80003ac6:	40ec87bb          	subw	a5,s9,a4
    80003aca:	413b06bb          	subw	a3,s6,s3
    80003ace:	8d3e                	mv	s10,a5
    80003ad0:	2781                	sext.w	a5,a5
    80003ad2:	0006861b          	sext.w	a2,a3
    80003ad6:	f8f67ee3          	bgeu	a2,a5,80003a72 <writei+0x4c>
    80003ada:	8d36                	mv	s10,a3
    80003adc:	bf59                	j	80003a72 <writei+0x4c>
      brelse(bp);
    80003ade:	8526                	mv	a0,s1
    80003ae0:	dc6ff0ef          	jal	800030a6 <brelse>
  }

  if(off > ip->size)
    80003ae4:	04caa783          	lw	a5,76(s5)
    80003ae8:	0327fa63          	bgeu	a5,s2,80003b1c <writei+0xf6>
    ip->size = off;
    80003aec:	052aa623          	sw	s2,76(s5)
    80003af0:	64e6                	ld	s1,88(sp)
    80003af2:	7c02                	ld	s8,32(sp)
    80003af4:	6ce2                	ld	s9,24(sp)
    80003af6:	6d42                	ld	s10,16(sp)
    80003af8:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003afa:	8556                	mv	a0,s5
    80003afc:	b27ff0ef          	jal	80003622 <iupdate>

  return tot;
    80003b00:	0009851b          	sext.w	a0,s3
    80003b04:	69a6                	ld	s3,72(sp)
}
    80003b06:	70a6                	ld	ra,104(sp)
    80003b08:	7406                	ld	s0,96(sp)
    80003b0a:	6946                	ld	s2,80(sp)
    80003b0c:	6a06                	ld	s4,64(sp)
    80003b0e:	7ae2                	ld	s5,56(sp)
    80003b10:	7b42                	ld	s6,48(sp)
    80003b12:	7ba2                	ld	s7,40(sp)
    80003b14:	6165                	addi	sp,sp,112
    80003b16:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b18:	89da                	mv	s3,s6
    80003b1a:	b7c5                	j	80003afa <writei+0xd4>
    80003b1c:	64e6                	ld	s1,88(sp)
    80003b1e:	7c02                	ld	s8,32(sp)
    80003b20:	6ce2                	ld	s9,24(sp)
    80003b22:	6d42                	ld	s10,16(sp)
    80003b24:	6da2                	ld	s11,8(sp)
    80003b26:	bfd1                	j	80003afa <writei+0xd4>
    return -1;
    80003b28:	557d                	li	a0,-1
}
    80003b2a:	8082                	ret
    return -1;
    80003b2c:	557d                	li	a0,-1
    80003b2e:	bfe1                	j	80003b06 <writei+0xe0>
    return -1;
    80003b30:	557d                	li	a0,-1
    80003b32:	bfd1                	j	80003b06 <writei+0xe0>

0000000080003b34 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003b34:	1141                	addi	sp,sp,-16
    80003b36:	e406                	sd	ra,8(sp)
    80003b38:	e022                	sd	s0,0(sp)
    80003b3a:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003b3c:	4639                	li	a2,14
    80003b3e:	a56fd0ef          	jal	80000d94 <strncmp>
}
    80003b42:	60a2                	ld	ra,8(sp)
    80003b44:	6402                	ld	s0,0(sp)
    80003b46:	0141                	addi	sp,sp,16
    80003b48:	8082                	ret

0000000080003b4a <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003b4a:	7139                	addi	sp,sp,-64
    80003b4c:	fc06                	sd	ra,56(sp)
    80003b4e:	f822                	sd	s0,48(sp)
    80003b50:	f426                	sd	s1,40(sp)
    80003b52:	f04a                	sd	s2,32(sp)
    80003b54:	ec4e                	sd	s3,24(sp)
    80003b56:	e852                	sd	s4,16(sp)
    80003b58:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003b5a:	04451703          	lh	a4,68(a0)
    80003b5e:	4785                	li	a5,1
    80003b60:	00f71a63          	bne	a4,a5,80003b74 <dirlookup+0x2a>
    80003b64:	892a                	mv	s2,a0
    80003b66:	89ae                	mv	s3,a1
    80003b68:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b6a:	457c                	lw	a5,76(a0)
    80003b6c:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003b6e:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b70:	e39d                	bnez	a5,80003b96 <dirlookup+0x4c>
    80003b72:	a095                	j	80003bd6 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80003b74:	00004517          	auipc	a0,0x4
    80003b78:	b1c50513          	addi	a0,a0,-1252 # 80007690 <etext+0x690>
    80003b7c:	c19fc0ef          	jal	80000794 <panic>
      panic("dirlookup read");
    80003b80:	00004517          	auipc	a0,0x4
    80003b84:	b2850513          	addi	a0,a0,-1240 # 800076a8 <etext+0x6a8>
    80003b88:	c0dfc0ef          	jal	80000794 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b8c:	24c1                	addiw	s1,s1,16
    80003b8e:	04c92783          	lw	a5,76(s2)
    80003b92:	04f4f163          	bgeu	s1,a5,80003bd4 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b96:	4741                	li	a4,16
    80003b98:	86a6                	mv	a3,s1
    80003b9a:	fc040613          	addi	a2,s0,-64
    80003b9e:	4581                	li	a1,0
    80003ba0:	854a                	mv	a0,s2
    80003ba2:	d89ff0ef          	jal	8000392a <readi>
    80003ba6:	47c1                	li	a5,16
    80003ba8:	fcf51ce3          	bne	a0,a5,80003b80 <dirlookup+0x36>
    if(de.inum == 0)
    80003bac:	fc045783          	lhu	a5,-64(s0)
    80003bb0:	dff1                	beqz	a5,80003b8c <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80003bb2:	fc240593          	addi	a1,s0,-62
    80003bb6:	854e                	mv	a0,s3
    80003bb8:	f7dff0ef          	jal	80003b34 <namecmp>
    80003bbc:	f961                	bnez	a0,80003b8c <dirlookup+0x42>
      if(poff)
    80003bbe:	000a0463          	beqz	s4,80003bc6 <dirlookup+0x7c>
        *poff = off;
    80003bc2:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003bc6:	fc045583          	lhu	a1,-64(s0)
    80003bca:	00092503          	lw	a0,0(s2)
    80003bce:	829ff0ef          	jal	800033f6 <iget>
    80003bd2:	a011                	j	80003bd6 <dirlookup+0x8c>
  return 0;
    80003bd4:	4501                	li	a0,0
}
    80003bd6:	70e2                	ld	ra,56(sp)
    80003bd8:	7442                	ld	s0,48(sp)
    80003bda:	74a2                	ld	s1,40(sp)
    80003bdc:	7902                	ld	s2,32(sp)
    80003bde:	69e2                	ld	s3,24(sp)
    80003be0:	6a42                	ld	s4,16(sp)
    80003be2:	6121                	addi	sp,sp,64
    80003be4:	8082                	ret

0000000080003be6 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003be6:	711d                	addi	sp,sp,-96
    80003be8:	ec86                	sd	ra,88(sp)
    80003bea:	e8a2                	sd	s0,80(sp)
    80003bec:	e4a6                	sd	s1,72(sp)
    80003bee:	e0ca                	sd	s2,64(sp)
    80003bf0:	fc4e                	sd	s3,56(sp)
    80003bf2:	f852                	sd	s4,48(sp)
    80003bf4:	f456                	sd	s5,40(sp)
    80003bf6:	f05a                	sd	s6,32(sp)
    80003bf8:	ec5e                	sd	s7,24(sp)
    80003bfa:	e862                	sd	s8,16(sp)
    80003bfc:	e466                	sd	s9,8(sp)
    80003bfe:	1080                	addi	s0,sp,96
    80003c00:	84aa                	mv	s1,a0
    80003c02:	8b2e                	mv	s6,a1
    80003c04:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003c06:	00054703          	lbu	a4,0(a0)
    80003c0a:	02f00793          	li	a5,47
    80003c0e:	00f70e63          	beq	a4,a5,80003c2a <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003c12:	cf1fd0ef          	jal	80001902 <myproc>
    80003c16:	15053503          	ld	a0,336(a0)
    80003c1a:	a87ff0ef          	jal	800036a0 <idup>
    80003c1e:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003c20:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003c24:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003c26:	4b85                	li	s7,1
    80003c28:	a871                	j	80003cc4 <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    80003c2a:	4585                	li	a1,1
    80003c2c:	4505                	li	a0,1
    80003c2e:	fc8ff0ef          	jal	800033f6 <iget>
    80003c32:	8a2a                	mv	s4,a0
    80003c34:	b7f5                	j	80003c20 <namex+0x3a>
      iunlockput(ip);
    80003c36:	8552                	mv	a0,s4
    80003c38:	ca9ff0ef          	jal	800038e0 <iunlockput>
      return 0;
    80003c3c:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003c3e:	8552                	mv	a0,s4
    80003c40:	60e6                	ld	ra,88(sp)
    80003c42:	6446                	ld	s0,80(sp)
    80003c44:	64a6                	ld	s1,72(sp)
    80003c46:	6906                	ld	s2,64(sp)
    80003c48:	79e2                	ld	s3,56(sp)
    80003c4a:	7a42                	ld	s4,48(sp)
    80003c4c:	7aa2                	ld	s5,40(sp)
    80003c4e:	7b02                	ld	s6,32(sp)
    80003c50:	6be2                	ld	s7,24(sp)
    80003c52:	6c42                	ld	s8,16(sp)
    80003c54:	6ca2                	ld	s9,8(sp)
    80003c56:	6125                	addi	sp,sp,96
    80003c58:	8082                	ret
      iunlock(ip);
    80003c5a:	8552                	mv	a0,s4
    80003c5c:	b29ff0ef          	jal	80003784 <iunlock>
      return ip;
    80003c60:	bff9                	j	80003c3e <namex+0x58>
      iunlockput(ip);
    80003c62:	8552                	mv	a0,s4
    80003c64:	c7dff0ef          	jal	800038e0 <iunlockput>
      return 0;
    80003c68:	8a4e                	mv	s4,s3
    80003c6a:	bfd1                	j	80003c3e <namex+0x58>
  len = path - s;
    80003c6c:	40998633          	sub	a2,s3,s1
    80003c70:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003c74:	099c5063          	bge	s8,s9,80003cf4 <namex+0x10e>
    memmove(name, s, DIRSIZ);
    80003c78:	4639                	li	a2,14
    80003c7a:	85a6                	mv	a1,s1
    80003c7c:	8556                	mv	a0,s5
    80003c7e:	8a6fd0ef          	jal	80000d24 <memmove>
    80003c82:	84ce                	mv	s1,s3
  while(*path == '/')
    80003c84:	0004c783          	lbu	a5,0(s1)
    80003c88:	01279763          	bne	a5,s2,80003c96 <namex+0xb0>
    path++;
    80003c8c:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003c8e:	0004c783          	lbu	a5,0(s1)
    80003c92:	ff278de3          	beq	a5,s2,80003c8c <namex+0xa6>
    ilock(ip);
    80003c96:	8552                	mv	a0,s4
    80003c98:	a3fff0ef          	jal	800036d6 <ilock>
    if(ip->type != T_DIR){
    80003c9c:	044a1783          	lh	a5,68(s4)
    80003ca0:	f9779be3          	bne	a5,s7,80003c36 <namex+0x50>
    if(nameiparent && *path == '\0'){
    80003ca4:	000b0563          	beqz	s6,80003cae <namex+0xc8>
    80003ca8:	0004c783          	lbu	a5,0(s1)
    80003cac:	d7dd                	beqz	a5,80003c5a <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003cae:	4601                	li	a2,0
    80003cb0:	85d6                	mv	a1,s5
    80003cb2:	8552                	mv	a0,s4
    80003cb4:	e97ff0ef          	jal	80003b4a <dirlookup>
    80003cb8:	89aa                	mv	s3,a0
    80003cba:	d545                	beqz	a0,80003c62 <namex+0x7c>
    iunlockput(ip);
    80003cbc:	8552                	mv	a0,s4
    80003cbe:	c23ff0ef          	jal	800038e0 <iunlockput>
    ip = next;
    80003cc2:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003cc4:	0004c783          	lbu	a5,0(s1)
    80003cc8:	01279763          	bne	a5,s2,80003cd6 <namex+0xf0>
    path++;
    80003ccc:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003cce:	0004c783          	lbu	a5,0(s1)
    80003cd2:	ff278de3          	beq	a5,s2,80003ccc <namex+0xe6>
  if(*path == 0)
    80003cd6:	cb8d                	beqz	a5,80003d08 <namex+0x122>
  while(*path != '/' && *path != 0)
    80003cd8:	0004c783          	lbu	a5,0(s1)
    80003cdc:	89a6                	mv	s3,s1
  len = path - s;
    80003cde:	4c81                	li	s9,0
    80003ce0:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003ce2:	01278963          	beq	a5,s2,80003cf4 <namex+0x10e>
    80003ce6:	d3d9                	beqz	a5,80003c6c <namex+0x86>
    path++;
    80003ce8:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003cea:	0009c783          	lbu	a5,0(s3)
    80003cee:	ff279ce3          	bne	a5,s2,80003ce6 <namex+0x100>
    80003cf2:	bfad                	j	80003c6c <namex+0x86>
    memmove(name, s, len);
    80003cf4:	2601                	sext.w	a2,a2
    80003cf6:	85a6                	mv	a1,s1
    80003cf8:	8556                	mv	a0,s5
    80003cfa:	82afd0ef          	jal	80000d24 <memmove>
    name[len] = 0;
    80003cfe:	9cd6                	add	s9,s9,s5
    80003d00:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003d04:	84ce                	mv	s1,s3
    80003d06:	bfbd                	j	80003c84 <namex+0x9e>
  if(nameiparent){
    80003d08:	f20b0be3          	beqz	s6,80003c3e <namex+0x58>
    iput(ip);
    80003d0c:	8552                	mv	a0,s4
    80003d0e:	b4bff0ef          	jal	80003858 <iput>
    return 0;
    80003d12:	4a01                	li	s4,0
    80003d14:	b72d                	j	80003c3e <namex+0x58>

0000000080003d16 <dirlink>:
{
    80003d16:	7139                	addi	sp,sp,-64
    80003d18:	fc06                	sd	ra,56(sp)
    80003d1a:	f822                	sd	s0,48(sp)
    80003d1c:	f04a                	sd	s2,32(sp)
    80003d1e:	ec4e                	sd	s3,24(sp)
    80003d20:	e852                	sd	s4,16(sp)
    80003d22:	0080                	addi	s0,sp,64
    80003d24:	892a                	mv	s2,a0
    80003d26:	8a2e                	mv	s4,a1
    80003d28:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003d2a:	4601                	li	a2,0
    80003d2c:	e1fff0ef          	jal	80003b4a <dirlookup>
    80003d30:	e535                	bnez	a0,80003d9c <dirlink+0x86>
    80003d32:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d34:	04c92483          	lw	s1,76(s2)
    80003d38:	c48d                	beqz	s1,80003d62 <dirlink+0x4c>
    80003d3a:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d3c:	4741                	li	a4,16
    80003d3e:	86a6                	mv	a3,s1
    80003d40:	fc040613          	addi	a2,s0,-64
    80003d44:	4581                	li	a1,0
    80003d46:	854a                	mv	a0,s2
    80003d48:	be3ff0ef          	jal	8000392a <readi>
    80003d4c:	47c1                	li	a5,16
    80003d4e:	04f51b63          	bne	a0,a5,80003da4 <dirlink+0x8e>
    if(de.inum == 0)
    80003d52:	fc045783          	lhu	a5,-64(s0)
    80003d56:	c791                	beqz	a5,80003d62 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d58:	24c1                	addiw	s1,s1,16
    80003d5a:	04c92783          	lw	a5,76(s2)
    80003d5e:	fcf4efe3          	bltu	s1,a5,80003d3c <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003d62:	4639                	li	a2,14
    80003d64:	85d2                	mv	a1,s4
    80003d66:	fc240513          	addi	a0,s0,-62
    80003d6a:	860fd0ef          	jal	80000dca <strncpy>
  de.inum = inum;
    80003d6e:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d72:	4741                	li	a4,16
    80003d74:	86a6                	mv	a3,s1
    80003d76:	fc040613          	addi	a2,s0,-64
    80003d7a:	4581                	li	a1,0
    80003d7c:	854a                	mv	a0,s2
    80003d7e:	ca9ff0ef          	jal	80003a26 <writei>
    80003d82:	1541                	addi	a0,a0,-16
    80003d84:	00a03533          	snez	a0,a0
    80003d88:	40a00533          	neg	a0,a0
    80003d8c:	74a2                	ld	s1,40(sp)
}
    80003d8e:	70e2                	ld	ra,56(sp)
    80003d90:	7442                	ld	s0,48(sp)
    80003d92:	7902                	ld	s2,32(sp)
    80003d94:	69e2                	ld	s3,24(sp)
    80003d96:	6a42                	ld	s4,16(sp)
    80003d98:	6121                	addi	sp,sp,64
    80003d9a:	8082                	ret
    iput(ip);
    80003d9c:	abdff0ef          	jal	80003858 <iput>
    return -1;
    80003da0:	557d                	li	a0,-1
    80003da2:	b7f5                	j	80003d8e <dirlink+0x78>
      panic("dirlink read");
    80003da4:	00004517          	auipc	a0,0x4
    80003da8:	91450513          	addi	a0,a0,-1772 # 800076b8 <etext+0x6b8>
    80003dac:	9e9fc0ef          	jal	80000794 <panic>

0000000080003db0 <namei>:

struct inode*
namei(char *path)
{
    80003db0:	1101                	addi	sp,sp,-32
    80003db2:	ec06                	sd	ra,24(sp)
    80003db4:	e822                	sd	s0,16(sp)
    80003db6:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003db8:	fe040613          	addi	a2,s0,-32
    80003dbc:	4581                	li	a1,0
    80003dbe:	e29ff0ef          	jal	80003be6 <namex>
}
    80003dc2:	60e2                	ld	ra,24(sp)
    80003dc4:	6442                	ld	s0,16(sp)
    80003dc6:	6105                	addi	sp,sp,32
    80003dc8:	8082                	ret

0000000080003dca <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003dca:	1141                	addi	sp,sp,-16
    80003dcc:	e406                	sd	ra,8(sp)
    80003dce:	e022                	sd	s0,0(sp)
    80003dd0:	0800                	addi	s0,sp,16
    80003dd2:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003dd4:	4585                	li	a1,1
    80003dd6:	e11ff0ef          	jal	80003be6 <namex>
}
    80003dda:	60a2                	ld	ra,8(sp)
    80003ddc:	6402                	ld	s0,0(sp)
    80003dde:	0141                	addi	sp,sp,16
    80003de0:	8082                	ret

0000000080003de2 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003de2:	1101                	addi	sp,sp,-32
    80003de4:	ec06                	sd	ra,24(sp)
    80003de6:	e822                	sd	s0,16(sp)
    80003de8:	e426                	sd	s1,8(sp)
    80003dea:	e04a                	sd	s2,0(sp)
    80003dec:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003dee:	0001e917          	auipc	s2,0x1e
    80003df2:	fe290913          	addi	s2,s2,-30 # 80021dd0 <log>
    80003df6:	01892583          	lw	a1,24(s2)
    80003dfa:	02892503          	lw	a0,40(s2)
    80003dfe:	9a0ff0ef          	jal	80002f9e <bread>
    80003e02:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003e04:	02c92603          	lw	a2,44(s2)
    80003e08:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003e0a:	00c05f63          	blez	a2,80003e28 <write_head+0x46>
    80003e0e:	0001e717          	auipc	a4,0x1e
    80003e12:	ff270713          	addi	a4,a4,-14 # 80021e00 <log+0x30>
    80003e16:	87aa                	mv	a5,a0
    80003e18:	060a                	slli	a2,a2,0x2
    80003e1a:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003e1c:	4314                	lw	a3,0(a4)
    80003e1e:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003e20:	0711                	addi	a4,a4,4
    80003e22:	0791                	addi	a5,a5,4
    80003e24:	fec79ce3          	bne	a5,a2,80003e1c <write_head+0x3a>
  }
  bwrite(buf);
    80003e28:	8526                	mv	a0,s1
    80003e2a:	a4aff0ef          	jal	80003074 <bwrite>
  brelse(buf);
    80003e2e:	8526                	mv	a0,s1
    80003e30:	a76ff0ef          	jal	800030a6 <brelse>
}
    80003e34:	60e2                	ld	ra,24(sp)
    80003e36:	6442                	ld	s0,16(sp)
    80003e38:	64a2                	ld	s1,8(sp)
    80003e3a:	6902                	ld	s2,0(sp)
    80003e3c:	6105                	addi	sp,sp,32
    80003e3e:	8082                	ret

0000000080003e40 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e40:	0001e797          	auipc	a5,0x1e
    80003e44:	fbc7a783          	lw	a5,-68(a5) # 80021dfc <log+0x2c>
    80003e48:	08f05f63          	blez	a5,80003ee6 <install_trans+0xa6>
{
    80003e4c:	7139                	addi	sp,sp,-64
    80003e4e:	fc06                	sd	ra,56(sp)
    80003e50:	f822                	sd	s0,48(sp)
    80003e52:	f426                	sd	s1,40(sp)
    80003e54:	f04a                	sd	s2,32(sp)
    80003e56:	ec4e                	sd	s3,24(sp)
    80003e58:	e852                	sd	s4,16(sp)
    80003e5a:	e456                	sd	s5,8(sp)
    80003e5c:	e05a                	sd	s6,0(sp)
    80003e5e:	0080                	addi	s0,sp,64
    80003e60:	8b2a                	mv	s6,a0
    80003e62:	0001ea97          	auipc	s5,0x1e
    80003e66:	f9ea8a93          	addi	s5,s5,-98 # 80021e00 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e6a:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003e6c:	0001e997          	auipc	s3,0x1e
    80003e70:	f6498993          	addi	s3,s3,-156 # 80021dd0 <log>
    80003e74:	a829                	j	80003e8e <install_trans+0x4e>
    brelse(lbuf);
    80003e76:	854a                	mv	a0,s2
    80003e78:	a2eff0ef          	jal	800030a6 <brelse>
    brelse(dbuf);
    80003e7c:	8526                	mv	a0,s1
    80003e7e:	a28ff0ef          	jal	800030a6 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e82:	2a05                	addiw	s4,s4,1
    80003e84:	0a91                	addi	s5,s5,4
    80003e86:	02c9a783          	lw	a5,44(s3)
    80003e8a:	04fa5463          	bge	s4,a5,80003ed2 <install_trans+0x92>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003e8e:	0189a583          	lw	a1,24(s3)
    80003e92:	014585bb          	addw	a1,a1,s4
    80003e96:	2585                	addiw	a1,a1,1
    80003e98:	0289a503          	lw	a0,40(s3)
    80003e9c:	902ff0ef          	jal	80002f9e <bread>
    80003ea0:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003ea2:	000aa583          	lw	a1,0(s5)
    80003ea6:	0289a503          	lw	a0,40(s3)
    80003eaa:	8f4ff0ef          	jal	80002f9e <bread>
    80003eae:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003eb0:	40000613          	li	a2,1024
    80003eb4:	05890593          	addi	a1,s2,88
    80003eb8:	05850513          	addi	a0,a0,88
    80003ebc:	e69fc0ef          	jal	80000d24 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003ec0:	8526                	mv	a0,s1
    80003ec2:	9b2ff0ef          	jal	80003074 <bwrite>
    if(recovering == 0)
    80003ec6:	fa0b18e3          	bnez	s6,80003e76 <install_trans+0x36>
      bunpin(dbuf);
    80003eca:	8526                	mv	a0,s1
    80003ecc:	a96ff0ef          	jal	80003162 <bunpin>
    80003ed0:	b75d                	j	80003e76 <install_trans+0x36>
}
    80003ed2:	70e2                	ld	ra,56(sp)
    80003ed4:	7442                	ld	s0,48(sp)
    80003ed6:	74a2                	ld	s1,40(sp)
    80003ed8:	7902                	ld	s2,32(sp)
    80003eda:	69e2                	ld	s3,24(sp)
    80003edc:	6a42                	ld	s4,16(sp)
    80003ede:	6aa2                	ld	s5,8(sp)
    80003ee0:	6b02                	ld	s6,0(sp)
    80003ee2:	6121                	addi	sp,sp,64
    80003ee4:	8082                	ret
    80003ee6:	8082                	ret

0000000080003ee8 <initlog>:
{
    80003ee8:	7179                	addi	sp,sp,-48
    80003eea:	f406                	sd	ra,40(sp)
    80003eec:	f022                	sd	s0,32(sp)
    80003eee:	ec26                	sd	s1,24(sp)
    80003ef0:	e84a                	sd	s2,16(sp)
    80003ef2:	e44e                	sd	s3,8(sp)
    80003ef4:	1800                	addi	s0,sp,48
    80003ef6:	892a                	mv	s2,a0
    80003ef8:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003efa:	0001e497          	auipc	s1,0x1e
    80003efe:	ed648493          	addi	s1,s1,-298 # 80021dd0 <log>
    80003f02:	00003597          	auipc	a1,0x3
    80003f06:	7c658593          	addi	a1,a1,1990 # 800076c8 <etext+0x6c8>
    80003f0a:	8526                	mv	a0,s1
    80003f0c:	c69fc0ef          	jal	80000b74 <initlock>
  log.start = sb->logstart;
    80003f10:	0149a583          	lw	a1,20(s3)
    80003f14:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003f16:	0109a783          	lw	a5,16(s3)
    80003f1a:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003f1c:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003f20:	854a                	mv	a0,s2
    80003f22:	87cff0ef          	jal	80002f9e <bread>
  log.lh.n = lh->n;
    80003f26:	4d30                	lw	a2,88(a0)
    80003f28:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003f2a:	00c05f63          	blez	a2,80003f48 <initlog+0x60>
    80003f2e:	87aa                	mv	a5,a0
    80003f30:	0001e717          	auipc	a4,0x1e
    80003f34:	ed070713          	addi	a4,a4,-304 # 80021e00 <log+0x30>
    80003f38:	060a                	slli	a2,a2,0x2
    80003f3a:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003f3c:	4ff4                	lw	a3,92(a5)
    80003f3e:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003f40:	0791                	addi	a5,a5,4
    80003f42:	0711                	addi	a4,a4,4
    80003f44:	fec79ce3          	bne	a5,a2,80003f3c <initlog+0x54>
  brelse(buf);
    80003f48:	95eff0ef          	jal	800030a6 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003f4c:	4505                	li	a0,1
    80003f4e:	ef3ff0ef          	jal	80003e40 <install_trans>
  log.lh.n = 0;
    80003f52:	0001e797          	auipc	a5,0x1e
    80003f56:	ea07a523          	sw	zero,-342(a5) # 80021dfc <log+0x2c>
  write_head(); // clear the log
    80003f5a:	e89ff0ef          	jal	80003de2 <write_head>
}
    80003f5e:	70a2                	ld	ra,40(sp)
    80003f60:	7402                	ld	s0,32(sp)
    80003f62:	64e2                	ld	s1,24(sp)
    80003f64:	6942                	ld	s2,16(sp)
    80003f66:	69a2                	ld	s3,8(sp)
    80003f68:	6145                	addi	sp,sp,48
    80003f6a:	8082                	ret

0000000080003f6c <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003f6c:	1101                	addi	sp,sp,-32
    80003f6e:	ec06                	sd	ra,24(sp)
    80003f70:	e822                	sd	s0,16(sp)
    80003f72:	e426                	sd	s1,8(sp)
    80003f74:	e04a                	sd	s2,0(sp)
    80003f76:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003f78:	0001e517          	auipc	a0,0x1e
    80003f7c:	e5850513          	addi	a0,a0,-424 # 80021dd0 <log>
    80003f80:	c75fc0ef          	jal	80000bf4 <acquire>
  while(1){
    if(log.committing){
    80003f84:	0001e497          	auipc	s1,0x1e
    80003f88:	e4c48493          	addi	s1,s1,-436 # 80021dd0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003f8c:	4979                	li	s2,30
    80003f8e:	a029                	j	80003f98 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003f90:	85a6                	mv	a1,s1
    80003f92:	8526                	mv	a0,s1
    80003f94:	a82fe0ef          	jal	80002216 <sleep>
    if(log.committing){
    80003f98:	50dc                	lw	a5,36(s1)
    80003f9a:	fbfd                	bnez	a5,80003f90 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003f9c:	5098                	lw	a4,32(s1)
    80003f9e:	2705                	addiw	a4,a4,1
    80003fa0:	0027179b          	slliw	a5,a4,0x2
    80003fa4:	9fb9                	addw	a5,a5,a4
    80003fa6:	0017979b          	slliw	a5,a5,0x1
    80003faa:	54d4                	lw	a3,44(s1)
    80003fac:	9fb5                	addw	a5,a5,a3
    80003fae:	00f95763          	bge	s2,a5,80003fbc <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003fb2:	85a6                	mv	a1,s1
    80003fb4:	8526                	mv	a0,s1
    80003fb6:	a60fe0ef          	jal	80002216 <sleep>
    80003fba:	bff9                	j	80003f98 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003fbc:	0001e517          	auipc	a0,0x1e
    80003fc0:	e1450513          	addi	a0,a0,-492 # 80021dd0 <log>
    80003fc4:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80003fc6:	cc7fc0ef          	jal	80000c8c <release>
      break;
    }
  }
}
    80003fca:	60e2                	ld	ra,24(sp)
    80003fcc:	6442                	ld	s0,16(sp)
    80003fce:	64a2                	ld	s1,8(sp)
    80003fd0:	6902                	ld	s2,0(sp)
    80003fd2:	6105                	addi	sp,sp,32
    80003fd4:	8082                	ret

0000000080003fd6 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003fd6:	7139                	addi	sp,sp,-64
    80003fd8:	fc06                	sd	ra,56(sp)
    80003fda:	f822                	sd	s0,48(sp)
    80003fdc:	f426                	sd	s1,40(sp)
    80003fde:	f04a                	sd	s2,32(sp)
    80003fe0:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003fe2:	0001e497          	auipc	s1,0x1e
    80003fe6:	dee48493          	addi	s1,s1,-530 # 80021dd0 <log>
    80003fea:	8526                	mv	a0,s1
    80003fec:	c09fc0ef          	jal	80000bf4 <acquire>
  log.outstanding -= 1;
    80003ff0:	509c                	lw	a5,32(s1)
    80003ff2:	37fd                	addiw	a5,a5,-1
    80003ff4:	0007891b          	sext.w	s2,a5
    80003ff8:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80003ffa:	50dc                	lw	a5,36(s1)
    80003ffc:	ef9d                	bnez	a5,8000403a <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80003ffe:	04091763          	bnez	s2,8000404c <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80004002:	0001e497          	auipc	s1,0x1e
    80004006:	dce48493          	addi	s1,s1,-562 # 80021dd0 <log>
    8000400a:	4785                	li	a5,1
    8000400c:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000400e:	8526                	mv	a0,s1
    80004010:	c7dfc0ef          	jal	80000c8c <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004014:	54dc                	lw	a5,44(s1)
    80004016:	04f04b63          	bgtz	a5,8000406c <end_op+0x96>
    acquire(&log.lock);
    8000401a:	0001e497          	auipc	s1,0x1e
    8000401e:	db648493          	addi	s1,s1,-586 # 80021dd0 <log>
    80004022:	8526                	mv	a0,s1
    80004024:	bd1fc0ef          	jal	80000bf4 <acquire>
    log.committing = 0;
    80004028:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000402c:	8526                	mv	a0,s1
    8000402e:	a34fe0ef          	jal	80002262 <wakeup>
    release(&log.lock);
    80004032:	8526                	mv	a0,s1
    80004034:	c59fc0ef          	jal	80000c8c <release>
}
    80004038:	a025                	j	80004060 <end_op+0x8a>
    8000403a:	ec4e                	sd	s3,24(sp)
    8000403c:	e852                	sd	s4,16(sp)
    8000403e:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80004040:	00003517          	auipc	a0,0x3
    80004044:	69050513          	addi	a0,a0,1680 # 800076d0 <etext+0x6d0>
    80004048:	f4cfc0ef          	jal	80000794 <panic>
    wakeup(&log);
    8000404c:	0001e497          	auipc	s1,0x1e
    80004050:	d8448493          	addi	s1,s1,-636 # 80021dd0 <log>
    80004054:	8526                	mv	a0,s1
    80004056:	a0cfe0ef          	jal	80002262 <wakeup>
  release(&log.lock);
    8000405a:	8526                	mv	a0,s1
    8000405c:	c31fc0ef          	jal	80000c8c <release>
}
    80004060:	70e2                	ld	ra,56(sp)
    80004062:	7442                	ld	s0,48(sp)
    80004064:	74a2                	ld	s1,40(sp)
    80004066:	7902                	ld	s2,32(sp)
    80004068:	6121                	addi	sp,sp,64
    8000406a:	8082                	ret
    8000406c:	ec4e                	sd	s3,24(sp)
    8000406e:	e852                	sd	s4,16(sp)
    80004070:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80004072:	0001ea97          	auipc	s5,0x1e
    80004076:	d8ea8a93          	addi	s5,s5,-626 # 80021e00 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000407a:	0001ea17          	auipc	s4,0x1e
    8000407e:	d56a0a13          	addi	s4,s4,-682 # 80021dd0 <log>
    80004082:	018a2583          	lw	a1,24(s4)
    80004086:	012585bb          	addw	a1,a1,s2
    8000408a:	2585                	addiw	a1,a1,1
    8000408c:	028a2503          	lw	a0,40(s4)
    80004090:	f0ffe0ef          	jal	80002f9e <bread>
    80004094:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004096:	000aa583          	lw	a1,0(s5)
    8000409a:	028a2503          	lw	a0,40(s4)
    8000409e:	f01fe0ef          	jal	80002f9e <bread>
    800040a2:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800040a4:	40000613          	li	a2,1024
    800040a8:	05850593          	addi	a1,a0,88
    800040ac:	05848513          	addi	a0,s1,88
    800040b0:	c75fc0ef          	jal	80000d24 <memmove>
    bwrite(to);  // write the log
    800040b4:	8526                	mv	a0,s1
    800040b6:	fbffe0ef          	jal	80003074 <bwrite>
    brelse(from);
    800040ba:	854e                	mv	a0,s3
    800040bc:	febfe0ef          	jal	800030a6 <brelse>
    brelse(to);
    800040c0:	8526                	mv	a0,s1
    800040c2:	fe5fe0ef          	jal	800030a6 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800040c6:	2905                	addiw	s2,s2,1
    800040c8:	0a91                	addi	s5,s5,4
    800040ca:	02ca2783          	lw	a5,44(s4)
    800040ce:	faf94ae3          	blt	s2,a5,80004082 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800040d2:	d11ff0ef          	jal	80003de2 <write_head>
    install_trans(0); // Now install writes to home locations
    800040d6:	4501                	li	a0,0
    800040d8:	d69ff0ef          	jal	80003e40 <install_trans>
    log.lh.n = 0;
    800040dc:	0001e797          	auipc	a5,0x1e
    800040e0:	d207a023          	sw	zero,-736(a5) # 80021dfc <log+0x2c>
    write_head();    // Erase the transaction from the log
    800040e4:	cffff0ef          	jal	80003de2 <write_head>
    800040e8:	69e2                	ld	s3,24(sp)
    800040ea:	6a42                	ld	s4,16(sp)
    800040ec:	6aa2                	ld	s5,8(sp)
    800040ee:	b735                	j	8000401a <end_op+0x44>

00000000800040f0 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800040f0:	1101                	addi	sp,sp,-32
    800040f2:	ec06                	sd	ra,24(sp)
    800040f4:	e822                	sd	s0,16(sp)
    800040f6:	e426                	sd	s1,8(sp)
    800040f8:	e04a                	sd	s2,0(sp)
    800040fa:	1000                	addi	s0,sp,32
    800040fc:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800040fe:	0001e917          	auipc	s2,0x1e
    80004102:	cd290913          	addi	s2,s2,-814 # 80021dd0 <log>
    80004106:	854a                	mv	a0,s2
    80004108:	aedfc0ef          	jal	80000bf4 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000410c:	02c92603          	lw	a2,44(s2)
    80004110:	47f5                	li	a5,29
    80004112:	06c7c363          	blt	a5,a2,80004178 <log_write+0x88>
    80004116:	0001e797          	auipc	a5,0x1e
    8000411a:	cd67a783          	lw	a5,-810(a5) # 80021dec <log+0x1c>
    8000411e:	37fd                	addiw	a5,a5,-1
    80004120:	04f65c63          	bge	a2,a5,80004178 <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004124:	0001e797          	auipc	a5,0x1e
    80004128:	ccc7a783          	lw	a5,-820(a5) # 80021df0 <log+0x20>
    8000412c:	04f05c63          	blez	a5,80004184 <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004130:	4781                	li	a5,0
    80004132:	04c05f63          	blez	a2,80004190 <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004136:	44cc                	lw	a1,12(s1)
    80004138:	0001e717          	auipc	a4,0x1e
    8000413c:	cc870713          	addi	a4,a4,-824 # 80021e00 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004140:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004142:	4314                	lw	a3,0(a4)
    80004144:	04b68663          	beq	a3,a1,80004190 <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    80004148:	2785                	addiw	a5,a5,1
    8000414a:	0711                	addi	a4,a4,4
    8000414c:	fef61be3          	bne	a2,a5,80004142 <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004150:	0621                	addi	a2,a2,8
    80004152:	060a                	slli	a2,a2,0x2
    80004154:	0001e797          	auipc	a5,0x1e
    80004158:	c7c78793          	addi	a5,a5,-900 # 80021dd0 <log>
    8000415c:	97b2                	add	a5,a5,a2
    8000415e:	44d8                	lw	a4,12(s1)
    80004160:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004162:	8526                	mv	a0,s1
    80004164:	fcbfe0ef          	jal	8000312e <bpin>
    log.lh.n++;
    80004168:	0001e717          	auipc	a4,0x1e
    8000416c:	c6870713          	addi	a4,a4,-920 # 80021dd0 <log>
    80004170:	575c                	lw	a5,44(a4)
    80004172:	2785                	addiw	a5,a5,1
    80004174:	d75c                	sw	a5,44(a4)
    80004176:	a80d                	j	800041a8 <log_write+0xb8>
    panic("too big a transaction");
    80004178:	00003517          	auipc	a0,0x3
    8000417c:	56850513          	addi	a0,a0,1384 # 800076e0 <etext+0x6e0>
    80004180:	e14fc0ef          	jal	80000794 <panic>
    panic("log_write outside of trans");
    80004184:	00003517          	auipc	a0,0x3
    80004188:	57450513          	addi	a0,a0,1396 # 800076f8 <etext+0x6f8>
    8000418c:	e08fc0ef          	jal	80000794 <panic>
  log.lh.block[i] = b->blockno;
    80004190:	00878693          	addi	a3,a5,8
    80004194:	068a                	slli	a3,a3,0x2
    80004196:	0001e717          	auipc	a4,0x1e
    8000419a:	c3a70713          	addi	a4,a4,-966 # 80021dd0 <log>
    8000419e:	9736                	add	a4,a4,a3
    800041a0:	44d4                	lw	a3,12(s1)
    800041a2:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800041a4:	faf60fe3          	beq	a2,a5,80004162 <log_write+0x72>
  }
  release(&log.lock);
    800041a8:	0001e517          	auipc	a0,0x1e
    800041ac:	c2850513          	addi	a0,a0,-984 # 80021dd0 <log>
    800041b0:	addfc0ef          	jal	80000c8c <release>
}
    800041b4:	60e2                	ld	ra,24(sp)
    800041b6:	6442                	ld	s0,16(sp)
    800041b8:	64a2                	ld	s1,8(sp)
    800041ba:	6902                	ld	s2,0(sp)
    800041bc:	6105                	addi	sp,sp,32
    800041be:	8082                	ret

00000000800041c0 <log_message>:
#include "riscv.h"
#include "defs.h"
#include "custom_logger.h"

// Implementing the logger function
void log_message(enum log_level level, const char *message) {
    800041c0:	1141                	addi	sp,sp,-16
    800041c2:	e406                	sd	ra,8(sp)
    800041c4:	e022                	sd	s0,0(sp)
    800041c6:	0800                	addi	s0,sp,16
    // Based on the log level, we print the appropriate prefix.
    switch (level) {
    800041c8:	4785                	li	a5,1
    800041ca:	02f50063          	beq	a0,a5,800041ea <log_message+0x2a>
    800041ce:	4789                	li	a5,2
    800041d0:	02f50463          	beq	a0,a5,800041f8 <log_message+0x38>
    800041d4:	e90d                	bnez	a0,80004206 <log_message+0x46>
        case INFO:
            printf("[INFO] %s\n", message);
    800041d6:	00003517          	auipc	a0,0x3
    800041da:	54250513          	addi	a0,a0,1346 # 80007718 <etext+0x718>
    800041de:	ae4fc0ef          	jal	800004c2 <printf>
            break;
        default:
            printf("[UNKNOWN] %s\n", message); // For possible error
            break;
    }
    800041e2:	60a2                	ld	ra,8(sp)
    800041e4:	6402                	ld	s0,0(sp)
    800041e6:	0141                	addi	sp,sp,16
    800041e8:	8082                	ret
            printf("[WARN] %s\n", message);
    800041ea:	00003517          	auipc	a0,0x3
    800041ee:	53e50513          	addi	a0,a0,1342 # 80007728 <etext+0x728>
    800041f2:	ad0fc0ef          	jal	800004c2 <printf>
            break;
    800041f6:	b7f5                	j	800041e2 <log_message+0x22>
            printf("[ERROR] %s\n", message);
    800041f8:	00003517          	auipc	a0,0x3
    800041fc:	54050513          	addi	a0,a0,1344 # 80007738 <etext+0x738>
    80004200:	ac2fc0ef          	jal	800004c2 <printf>
            break;
    80004204:	bff9                	j	800041e2 <log_message+0x22>
            printf("[UNKNOWN] %s\n", message); // For possible error
    80004206:	00003517          	auipc	a0,0x3
    8000420a:	54250513          	addi	a0,a0,1346 # 80007748 <etext+0x748>
    8000420e:	ab4fc0ef          	jal	800004c2 <printf>
    80004212:	bfc1                	j	800041e2 <log_message+0x22>

0000000080004214 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004214:	1101                	addi	sp,sp,-32
    80004216:	ec06                	sd	ra,24(sp)
    80004218:	e822                	sd	s0,16(sp)
    8000421a:	e426                	sd	s1,8(sp)
    8000421c:	e04a                	sd	s2,0(sp)
    8000421e:	1000                	addi	s0,sp,32
    80004220:	84aa                	mv	s1,a0
    80004222:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004224:	00003597          	auipc	a1,0x3
    80004228:	53458593          	addi	a1,a1,1332 # 80007758 <etext+0x758>
    8000422c:	0521                	addi	a0,a0,8
    8000422e:	947fc0ef          	jal	80000b74 <initlock>
  lk->name = name;
    80004232:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004236:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000423a:	0204a423          	sw	zero,40(s1)
}
    8000423e:	60e2                	ld	ra,24(sp)
    80004240:	6442                	ld	s0,16(sp)
    80004242:	64a2                	ld	s1,8(sp)
    80004244:	6902                	ld	s2,0(sp)
    80004246:	6105                	addi	sp,sp,32
    80004248:	8082                	ret

000000008000424a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000424a:	1101                	addi	sp,sp,-32
    8000424c:	ec06                	sd	ra,24(sp)
    8000424e:	e822                	sd	s0,16(sp)
    80004250:	e426                	sd	s1,8(sp)
    80004252:	e04a                	sd	s2,0(sp)
    80004254:	1000                	addi	s0,sp,32
    80004256:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004258:	00850913          	addi	s2,a0,8
    8000425c:	854a                	mv	a0,s2
    8000425e:	997fc0ef          	jal	80000bf4 <acquire>
  while (lk->locked) {
    80004262:	409c                	lw	a5,0(s1)
    80004264:	c799                	beqz	a5,80004272 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80004266:	85ca                	mv	a1,s2
    80004268:	8526                	mv	a0,s1
    8000426a:	fadfd0ef          	jal	80002216 <sleep>
  while (lk->locked) {
    8000426e:	409c                	lw	a5,0(s1)
    80004270:	fbfd                	bnez	a5,80004266 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004272:	4785                	li	a5,1
    80004274:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004276:	e8cfd0ef          	jal	80001902 <myproc>
    8000427a:	591c                	lw	a5,48(a0)
    8000427c:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000427e:	854a                	mv	a0,s2
    80004280:	a0dfc0ef          	jal	80000c8c <release>
}
    80004284:	60e2                	ld	ra,24(sp)
    80004286:	6442                	ld	s0,16(sp)
    80004288:	64a2                	ld	s1,8(sp)
    8000428a:	6902                	ld	s2,0(sp)
    8000428c:	6105                	addi	sp,sp,32
    8000428e:	8082                	ret

0000000080004290 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004290:	1101                	addi	sp,sp,-32
    80004292:	ec06                	sd	ra,24(sp)
    80004294:	e822                	sd	s0,16(sp)
    80004296:	e426                	sd	s1,8(sp)
    80004298:	e04a                	sd	s2,0(sp)
    8000429a:	1000                	addi	s0,sp,32
    8000429c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000429e:	00850913          	addi	s2,a0,8
    800042a2:	854a                	mv	a0,s2
    800042a4:	951fc0ef          	jal	80000bf4 <acquire>
  lk->locked = 0;
    800042a8:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800042ac:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800042b0:	8526                	mv	a0,s1
    800042b2:	fb1fd0ef          	jal	80002262 <wakeup>
  release(&lk->lk);
    800042b6:	854a                	mv	a0,s2
    800042b8:	9d5fc0ef          	jal	80000c8c <release>
}
    800042bc:	60e2                	ld	ra,24(sp)
    800042be:	6442                	ld	s0,16(sp)
    800042c0:	64a2                	ld	s1,8(sp)
    800042c2:	6902                	ld	s2,0(sp)
    800042c4:	6105                	addi	sp,sp,32
    800042c6:	8082                	ret

00000000800042c8 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800042c8:	7179                	addi	sp,sp,-48
    800042ca:	f406                	sd	ra,40(sp)
    800042cc:	f022                	sd	s0,32(sp)
    800042ce:	ec26                	sd	s1,24(sp)
    800042d0:	e84a                	sd	s2,16(sp)
    800042d2:	1800                	addi	s0,sp,48
    800042d4:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800042d6:	00850913          	addi	s2,a0,8
    800042da:	854a                	mv	a0,s2
    800042dc:	919fc0ef          	jal	80000bf4 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800042e0:	409c                	lw	a5,0(s1)
    800042e2:	ef81                	bnez	a5,800042fa <holdingsleep+0x32>
    800042e4:	4481                	li	s1,0
  release(&lk->lk);
    800042e6:	854a                	mv	a0,s2
    800042e8:	9a5fc0ef          	jal	80000c8c <release>
  return r;
}
    800042ec:	8526                	mv	a0,s1
    800042ee:	70a2                	ld	ra,40(sp)
    800042f0:	7402                	ld	s0,32(sp)
    800042f2:	64e2                	ld	s1,24(sp)
    800042f4:	6942                	ld	s2,16(sp)
    800042f6:	6145                	addi	sp,sp,48
    800042f8:	8082                	ret
    800042fa:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    800042fc:	0284a983          	lw	s3,40(s1)
    80004300:	e02fd0ef          	jal	80001902 <myproc>
    80004304:	5904                	lw	s1,48(a0)
    80004306:	413484b3          	sub	s1,s1,s3
    8000430a:	0014b493          	seqz	s1,s1
    8000430e:	69a2                	ld	s3,8(sp)
    80004310:	bfd9                	j	800042e6 <holdingsleep+0x1e>

0000000080004312 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004312:	1141                	addi	sp,sp,-16
    80004314:	e406                	sd	ra,8(sp)
    80004316:	e022                	sd	s0,0(sp)
    80004318:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000431a:	00003597          	auipc	a1,0x3
    8000431e:	44e58593          	addi	a1,a1,1102 # 80007768 <etext+0x768>
    80004322:	0001e517          	auipc	a0,0x1e
    80004326:	bf650513          	addi	a0,a0,-1034 # 80021f18 <ftable>
    8000432a:	84bfc0ef          	jal	80000b74 <initlock>
}
    8000432e:	60a2                	ld	ra,8(sp)
    80004330:	6402                	ld	s0,0(sp)
    80004332:	0141                	addi	sp,sp,16
    80004334:	8082                	ret

0000000080004336 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004336:	1101                	addi	sp,sp,-32
    80004338:	ec06                	sd	ra,24(sp)
    8000433a:	e822                	sd	s0,16(sp)
    8000433c:	e426                	sd	s1,8(sp)
    8000433e:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004340:	0001e517          	auipc	a0,0x1e
    80004344:	bd850513          	addi	a0,a0,-1064 # 80021f18 <ftable>
    80004348:	8adfc0ef          	jal	80000bf4 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000434c:	0001e497          	auipc	s1,0x1e
    80004350:	be448493          	addi	s1,s1,-1052 # 80021f30 <ftable+0x18>
    80004354:	0001f717          	auipc	a4,0x1f
    80004358:	b7c70713          	addi	a4,a4,-1156 # 80022ed0 <disk>
    if(f->ref == 0){
    8000435c:	40dc                	lw	a5,4(s1)
    8000435e:	cf89                	beqz	a5,80004378 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004360:	02848493          	addi	s1,s1,40
    80004364:	fee49ce3          	bne	s1,a4,8000435c <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004368:	0001e517          	auipc	a0,0x1e
    8000436c:	bb050513          	addi	a0,a0,-1104 # 80021f18 <ftable>
    80004370:	91dfc0ef          	jal	80000c8c <release>
  return 0;
    80004374:	4481                	li	s1,0
    80004376:	a809                	j	80004388 <filealloc+0x52>
      f->ref = 1;
    80004378:	4785                	li	a5,1
    8000437a:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000437c:	0001e517          	auipc	a0,0x1e
    80004380:	b9c50513          	addi	a0,a0,-1124 # 80021f18 <ftable>
    80004384:	909fc0ef          	jal	80000c8c <release>
}
    80004388:	8526                	mv	a0,s1
    8000438a:	60e2                	ld	ra,24(sp)
    8000438c:	6442                	ld	s0,16(sp)
    8000438e:	64a2                	ld	s1,8(sp)
    80004390:	6105                	addi	sp,sp,32
    80004392:	8082                	ret

0000000080004394 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004394:	1101                	addi	sp,sp,-32
    80004396:	ec06                	sd	ra,24(sp)
    80004398:	e822                	sd	s0,16(sp)
    8000439a:	e426                	sd	s1,8(sp)
    8000439c:	1000                	addi	s0,sp,32
    8000439e:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800043a0:	0001e517          	auipc	a0,0x1e
    800043a4:	b7850513          	addi	a0,a0,-1160 # 80021f18 <ftable>
    800043a8:	84dfc0ef          	jal	80000bf4 <acquire>
  if(f->ref < 1)
    800043ac:	40dc                	lw	a5,4(s1)
    800043ae:	02f05063          	blez	a5,800043ce <filedup+0x3a>
    panic("filedup");
  f->ref++;
    800043b2:	2785                	addiw	a5,a5,1
    800043b4:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800043b6:	0001e517          	auipc	a0,0x1e
    800043ba:	b6250513          	addi	a0,a0,-1182 # 80021f18 <ftable>
    800043be:	8cffc0ef          	jal	80000c8c <release>
  return f;
}
    800043c2:	8526                	mv	a0,s1
    800043c4:	60e2                	ld	ra,24(sp)
    800043c6:	6442                	ld	s0,16(sp)
    800043c8:	64a2                	ld	s1,8(sp)
    800043ca:	6105                	addi	sp,sp,32
    800043cc:	8082                	ret
    panic("filedup");
    800043ce:	00003517          	auipc	a0,0x3
    800043d2:	3a250513          	addi	a0,a0,930 # 80007770 <etext+0x770>
    800043d6:	bbefc0ef          	jal	80000794 <panic>

00000000800043da <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800043da:	7139                	addi	sp,sp,-64
    800043dc:	fc06                	sd	ra,56(sp)
    800043de:	f822                	sd	s0,48(sp)
    800043e0:	f426                	sd	s1,40(sp)
    800043e2:	0080                	addi	s0,sp,64
    800043e4:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800043e6:	0001e517          	auipc	a0,0x1e
    800043ea:	b3250513          	addi	a0,a0,-1230 # 80021f18 <ftable>
    800043ee:	807fc0ef          	jal	80000bf4 <acquire>
  if(f->ref < 1)
    800043f2:	40dc                	lw	a5,4(s1)
    800043f4:	04f05a63          	blez	a5,80004448 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    800043f8:	37fd                	addiw	a5,a5,-1
    800043fa:	0007871b          	sext.w	a4,a5
    800043fe:	c0dc                	sw	a5,4(s1)
    80004400:	04e04e63          	bgtz	a4,8000445c <fileclose+0x82>
    80004404:	f04a                	sd	s2,32(sp)
    80004406:	ec4e                	sd	s3,24(sp)
    80004408:	e852                	sd	s4,16(sp)
    8000440a:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000440c:	0004a903          	lw	s2,0(s1)
    80004410:	0094ca83          	lbu	s5,9(s1)
    80004414:	0104ba03          	ld	s4,16(s1)
    80004418:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000441c:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004420:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004424:	0001e517          	auipc	a0,0x1e
    80004428:	af450513          	addi	a0,a0,-1292 # 80021f18 <ftable>
    8000442c:	861fc0ef          	jal	80000c8c <release>

  if(ff.type == FD_PIPE){
    80004430:	4785                	li	a5,1
    80004432:	04f90063          	beq	s2,a5,80004472 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004436:	3979                	addiw	s2,s2,-2
    80004438:	4785                	li	a5,1
    8000443a:	0527f563          	bgeu	a5,s2,80004484 <fileclose+0xaa>
    8000443e:	7902                	ld	s2,32(sp)
    80004440:	69e2                	ld	s3,24(sp)
    80004442:	6a42                	ld	s4,16(sp)
    80004444:	6aa2                	ld	s5,8(sp)
    80004446:	a00d                	j	80004468 <fileclose+0x8e>
    80004448:	f04a                	sd	s2,32(sp)
    8000444a:	ec4e                	sd	s3,24(sp)
    8000444c:	e852                	sd	s4,16(sp)
    8000444e:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004450:	00003517          	auipc	a0,0x3
    80004454:	32850513          	addi	a0,a0,808 # 80007778 <etext+0x778>
    80004458:	b3cfc0ef          	jal	80000794 <panic>
    release(&ftable.lock);
    8000445c:	0001e517          	auipc	a0,0x1e
    80004460:	abc50513          	addi	a0,a0,-1348 # 80021f18 <ftable>
    80004464:	829fc0ef          	jal	80000c8c <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004468:	70e2                	ld	ra,56(sp)
    8000446a:	7442                	ld	s0,48(sp)
    8000446c:	74a2                	ld	s1,40(sp)
    8000446e:	6121                	addi	sp,sp,64
    80004470:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004472:	85d6                	mv	a1,s5
    80004474:	8552                	mv	a0,s4
    80004476:	336000ef          	jal	800047ac <pipeclose>
    8000447a:	7902                	ld	s2,32(sp)
    8000447c:	69e2                	ld	s3,24(sp)
    8000447e:	6a42                	ld	s4,16(sp)
    80004480:	6aa2                	ld	s5,8(sp)
    80004482:	b7dd                	j	80004468 <fileclose+0x8e>
    begin_op();
    80004484:	ae9ff0ef          	jal	80003f6c <begin_op>
    iput(ff.ip);
    80004488:	854e                	mv	a0,s3
    8000448a:	bceff0ef          	jal	80003858 <iput>
    end_op();
    8000448e:	b49ff0ef          	jal	80003fd6 <end_op>
    80004492:	7902                	ld	s2,32(sp)
    80004494:	69e2                	ld	s3,24(sp)
    80004496:	6a42                	ld	s4,16(sp)
    80004498:	6aa2                	ld	s5,8(sp)
    8000449a:	b7f9                	j	80004468 <fileclose+0x8e>

000000008000449c <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000449c:	715d                	addi	sp,sp,-80
    8000449e:	e486                	sd	ra,72(sp)
    800044a0:	e0a2                	sd	s0,64(sp)
    800044a2:	fc26                	sd	s1,56(sp)
    800044a4:	f44e                	sd	s3,40(sp)
    800044a6:	0880                	addi	s0,sp,80
    800044a8:	84aa                	mv	s1,a0
    800044aa:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800044ac:	c56fd0ef          	jal	80001902 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800044b0:	409c                	lw	a5,0(s1)
    800044b2:	37f9                	addiw	a5,a5,-2
    800044b4:	4705                	li	a4,1
    800044b6:	04f76063          	bltu	a4,a5,800044f6 <filestat+0x5a>
    800044ba:	f84a                	sd	s2,48(sp)
    800044bc:	892a                	mv	s2,a0
    ilock(f->ip);
    800044be:	6c88                	ld	a0,24(s1)
    800044c0:	a16ff0ef          	jal	800036d6 <ilock>
    stati(f->ip, &st);
    800044c4:	fb840593          	addi	a1,s0,-72
    800044c8:	6c88                	ld	a0,24(s1)
    800044ca:	c36ff0ef          	jal	80003900 <stati>
    iunlock(f->ip);
    800044ce:	6c88                	ld	a0,24(s1)
    800044d0:	ab4ff0ef          	jal	80003784 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800044d4:	46e1                	li	a3,24
    800044d6:	fb840613          	addi	a2,s0,-72
    800044da:	85ce                	mv	a1,s3
    800044dc:	05093503          	ld	a0,80(s2)
    800044e0:	89cfd0ef          	jal	8000157c <copyout>
    800044e4:	41f5551b          	sraiw	a0,a0,0x1f
    800044e8:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800044ea:	60a6                	ld	ra,72(sp)
    800044ec:	6406                	ld	s0,64(sp)
    800044ee:	74e2                	ld	s1,56(sp)
    800044f0:	79a2                	ld	s3,40(sp)
    800044f2:	6161                	addi	sp,sp,80
    800044f4:	8082                	ret
  return -1;
    800044f6:	557d                	li	a0,-1
    800044f8:	bfcd                	j	800044ea <filestat+0x4e>

00000000800044fa <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800044fa:	7179                	addi	sp,sp,-48
    800044fc:	f406                	sd	ra,40(sp)
    800044fe:	f022                	sd	s0,32(sp)
    80004500:	e84a                	sd	s2,16(sp)
    80004502:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004504:	00854783          	lbu	a5,8(a0)
    80004508:	cfd1                	beqz	a5,800045a4 <fileread+0xaa>
    8000450a:	ec26                	sd	s1,24(sp)
    8000450c:	e44e                	sd	s3,8(sp)
    8000450e:	84aa                	mv	s1,a0
    80004510:	89ae                	mv	s3,a1
    80004512:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004514:	411c                	lw	a5,0(a0)
    80004516:	4705                	li	a4,1
    80004518:	04e78363          	beq	a5,a4,8000455e <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000451c:	470d                	li	a4,3
    8000451e:	04e78763          	beq	a5,a4,8000456c <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004522:	4709                	li	a4,2
    80004524:	06e79a63          	bne	a5,a4,80004598 <fileread+0x9e>
    ilock(f->ip);
    80004528:	6d08                	ld	a0,24(a0)
    8000452a:	9acff0ef          	jal	800036d6 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000452e:	874a                	mv	a4,s2
    80004530:	5094                	lw	a3,32(s1)
    80004532:	864e                	mv	a2,s3
    80004534:	4585                	li	a1,1
    80004536:	6c88                	ld	a0,24(s1)
    80004538:	bf2ff0ef          	jal	8000392a <readi>
    8000453c:	892a                	mv	s2,a0
    8000453e:	00a05563          	blez	a0,80004548 <fileread+0x4e>
      f->off += r;
    80004542:	509c                	lw	a5,32(s1)
    80004544:	9fa9                	addw	a5,a5,a0
    80004546:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004548:	6c88                	ld	a0,24(s1)
    8000454a:	a3aff0ef          	jal	80003784 <iunlock>
    8000454e:	64e2                	ld	s1,24(sp)
    80004550:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004552:	854a                	mv	a0,s2
    80004554:	70a2                	ld	ra,40(sp)
    80004556:	7402                	ld	s0,32(sp)
    80004558:	6942                	ld	s2,16(sp)
    8000455a:	6145                	addi	sp,sp,48
    8000455c:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000455e:	6908                	ld	a0,16(a0)
    80004560:	388000ef          	jal	800048e8 <piperead>
    80004564:	892a                	mv	s2,a0
    80004566:	64e2                	ld	s1,24(sp)
    80004568:	69a2                	ld	s3,8(sp)
    8000456a:	b7e5                	j	80004552 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000456c:	02451783          	lh	a5,36(a0)
    80004570:	03079693          	slli	a3,a5,0x30
    80004574:	92c1                	srli	a3,a3,0x30
    80004576:	4725                	li	a4,9
    80004578:	02d76863          	bltu	a4,a3,800045a8 <fileread+0xae>
    8000457c:	0792                	slli	a5,a5,0x4
    8000457e:	0001e717          	auipc	a4,0x1e
    80004582:	8fa70713          	addi	a4,a4,-1798 # 80021e78 <devsw>
    80004586:	97ba                	add	a5,a5,a4
    80004588:	639c                	ld	a5,0(a5)
    8000458a:	c39d                	beqz	a5,800045b0 <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    8000458c:	4505                	li	a0,1
    8000458e:	9782                	jalr	a5
    80004590:	892a                	mv	s2,a0
    80004592:	64e2                	ld	s1,24(sp)
    80004594:	69a2                	ld	s3,8(sp)
    80004596:	bf75                	j	80004552 <fileread+0x58>
    panic("fileread");
    80004598:	00003517          	auipc	a0,0x3
    8000459c:	1f050513          	addi	a0,a0,496 # 80007788 <etext+0x788>
    800045a0:	9f4fc0ef          	jal	80000794 <panic>
    return -1;
    800045a4:	597d                	li	s2,-1
    800045a6:	b775                	j	80004552 <fileread+0x58>
      return -1;
    800045a8:	597d                	li	s2,-1
    800045aa:	64e2                	ld	s1,24(sp)
    800045ac:	69a2                	ld	s3,8(sp)
    800045ae:	b755                	j	80004552 <fileread+0x58>
    800045b0:	597d                	li	s2,-1
    800045b2:	64e2                	ld	s1,24(sp)
    800045b4:	69a2                	ld	s3,8(sp)
    800045b6:	bf71                	j	80004552 <fileread+0x58>

00000000800045b8 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800045b8:	00954783          	lbu	a5,9(a0)
    800045bc:	10078b63          	beqz	a5,800046d2 <filewrite+0x11a>
{
    800045c0:	715d                	addi	sp,sp,-80
    800045c2:	e486                	sd	ra,72(sp)
    800045c4:	e0a2                	sd	s0,64(sp)
    800045c6:	f84a                	sd	s2,48(sp)
    800045c8:	f052                	sd	s4,32(sp)
    800045ca:	e85a                	sd	s6,16(sp)
    800045cc:	0880                	addi	s0,sp,80
    800045ce:	892a                	mv	s2,a0
    800045d0:	8b2e                	mv	s6,a1
    800045d2:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800045d4:	411c                	lw	a5,0(a0)
    800045d6:	4705                	li	a4,1
    800045d8:	02e78763          	beq	a5,a4,80004606 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800045dc:	470d                	li	a4,3
    800045de:	02e78863          	beq	a5,a4,8000460e <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800045e2:	4709                	li	a4,2
    800045e4:	0ce79c63          	bne	a5,a4,800046bc <filewrite+0x104>
    800045e8:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800045ea:	0ac05863          	blez	a2,8000469a <filewrite+0xe2>
    800045ee:	fc26                	sd	s1,56(sp)
    800045f0:	ec56                	sd	s5,24(sp)
    800045f2:	e45e                	sd	s7,8(sp)
    800045f4:	e062                	sd	s8,0(sp)
    int i = 0;
    800045f6:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    800045f8:	6b85                	lui	s7,0x1
    800045fa:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800045fe:	6c05                	lui	s8,0x1
    80004600:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004604:	a8b5                	j	80004680 <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    80004606:	6908                	ld	a0,16(a0)
    80004608:	1fc000ef          	jal	80004804 <pipewrite>
    8000460c:	a04d                	j	800046ae <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000460e:	02451783          	lh	a5,36(a0)
    80004612:	03079693          	slli	a3,a5,0x30
    80004616:	92c1                	srli	a3,a3,0x30
    80004618:	4725                	li	a4,9
    8000461a:	0ad76e63          	bltu	a4,a3,800046d6 <filewrite+0x11e>
    8000461e:	0792                	slli	a5,a5,0x4
    80004620:	0001e717          	auipc	a4,0x1e
    80004624:	85870713          	addi	a4,a4,-1960 # 80021e78 <devsw>
    80004628:	97ba                	add	a5,a5,a4
    8000462a:	679c                	ld	a5,8(a5)
    8000462c:	c7dd                	beqz	a5,800046da <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    8000462e:	4505                	li	a0,1
    80004630:	9782                	jalr	a5
    80004632:	a8b5                	j	800046ae <filewrite+0xf6>
      if(n1 > max)
    80004634:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004638:	935ff0ef          	jal	80003f6c <begin_op>
      ilock(f->ip);
    8000463c:	01893503          	ld	a0,24(s2)
    80004640:	896ff0ef          	jal	800036d6 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004644:	8756                	mv	a4,s5
    80004646:	02092683          	lw	a3,32(s2)
    8000464a:	01698633          	add	a2,s3,s6
    8000464e:	4585                	li	a1,1
    80004650:	01893503          	ld	a0,24(s2)
    80004654:	bd2ff0ef          	jal	80003a26 <writei>
    80004658:	84aa                	mv	s1,a0
    8000465a:	00a05763          	blez	a0,80004668 <filewrite+0xb0>
        f->off += r;
    8000465e:	02092783          	lw	a5,32(s2)
    80004662:	9fa9                	addw	a5,a5,a0
    80004664:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004668:	01893503          	ld	a0,24(s2)
    8000466c:	918ff0ef          	jal	80003784 <iunlock>
      end_op();
    80004670:	967ff0ef          	jal	80003fd6 <end_op>

      if(r != n1){
    80004674:	029a9563          	bne	s5,s1,8000469e <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    80004678:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000467c:	0149da63          	bge	s3,s4,80004690 <filewrite+0xd8>
      int n1 = n - i;
    80004680:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80004684:	0004879b          	sext.w	a5,s1
    80004688:	fafbd6e3          	bge	s7,a5,80004634 <filewrite+0x7c>
    8000468c:	84e2                	mv	s1,s8
    8000468e:	b75d                	j	80004634 <filewrite+0x7c>
    80004690:	74e2                	ld	s1,56(sp)
    80004692:	6ae2                	ld	s5,24(sp)
    80004694:	6ba2                	ld	s7,8(sp)
    80004696:	6c02                	ld	s8,0(sp)
    80004698:	a039                	j	800046a6 <filewrite+0xee>
    int i = 0;
    8000469a:	4981                	li	s3,0
    8000469c:	a029                	j	800046a6 <filewrite+0xee>
    8000469e:	74e2                	ld	s1,56(sp)
    800046a0:	6ae2                	ld	s5,24(sp)
    800046a2:	6ba2                	ld	s7,8(sp)
    800046a4:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    800046a6:	033a1c63          	bne	s4,s3,800046de <filewrite+0x126>
    800046aa:	8552                	mv	a0,s4
    800046ac:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    800046ae:	60a6                	ld	ra,72(sp)
    800046b0:	6406                	ld	s0,64(sp)
    800046b2:	7942                	ld	s2,48(sp)
    800046b4:	7a02                	ld	s4,32(sp)
    800046b6:	6b42                	ld	s6,16(sp)
    800046b8:	6161                	addi	sp,sp,80
    800046ba:	8082                	ret
    800046bc:	fc26                	sd	s1,56(sp)
    800046be:	f44e                	sd	s3,40(sp)
    800046c0:	ec56                	sd	s5,24(sp)
    800046c2:	e45e                	sd	s7,8(sp)
    800046c4:	e062                	sd	s8,0(sp)
    panic("filewrite");
    800046c6:	00003517          	auipc	a0,0x3
    800046ca:	0d250513          	addi	a0,a0,210 # 80007798 <etext+0x798>
    800046ce:	8c6fc0ef          	jal	80000794 <panic>
    return -1;
    800046d2:	557d                	li	a0,-1
}
    800046d4:	8082                	ret
      return -1;
    800046d6:	557d                	li	a0,-1
    800046d8:	bfd9                	j	800046ae <filewrite+0xf6>
    800046da:	557d                	li	a0,-1
    800046dc:	bfc9                	j	800046ae <filewrite+0xf6>
    ret = (i == n ? n : -1);
    800046de:	557d                	li	a0,-1
    800046e0:	79a2                	ld	s3,40(sp)
    800046e2:	b7f1                	j	800046ae <filewrite+0xf6>

00000000800046e4 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800046e4:	7179                	addi	sp,sp,-48
    800046e6:	f406                	sd	ra,40(sp)
    800046e8:	f022                	sd	s0,32(sp)
    800046ea:	ec26                	sd	s1,24(sp)
    800046ec:	e052                	sd	s4,0(sp)
    800046ee:	1800                	addi	s0,sp,48
    800046f0:	84aa                	mv	s1,a0
    800046f2:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800046f4:	0005b023          	sd	zero,0(a1)
    800046f8:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800046fc:	c3bff0ef          	jal	80004336 <filealloc>
    80004700:	e088                	sd	a0,0(s1)
    80004702:	c549                	beqz	a0,8000478c <pipealloc+0xa8>
    80004704:	c33ff0ef          	jal	80004336 <filealloc>
    80004708:	00aa3023          	sd	a0,0(s4)
    8000470c:	cd25                	beqz	a0,80004784 <pipealloc+0xa0>
    8000470e:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004710:	c14fc0ef          	jal	80000b24 <kalloc>
    80004714:	892a                	mv	s2,a0
    80004716:	c12d                	beqz	a0,80004778 <pipealloc+0x94>
    80004718:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    8000471a:	4985                	li	s3,1
    8000471c:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004720:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004724:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004728:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000472c:	00003597          	auipc	a1,0x3
    80004730:	07c58593          	addi	a1,a1,124 # 800077a8 <etext+0x7a8>
    80004734:	c40fc0ef          	jal	80000b74 <initlock>
  (*f0)->type = FD_PIPE;
    80004738:	609c                	ld	a5,0(s1)
    8000473a:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000473e:	609c                	ld	a5,0(s1)
    80004740:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004744:	609c                	ld	a5,0(s1)
    80004746:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000474a:	609c                	ld	a5,0(s1)
    8000474c:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004750:	000a3783          	ld	a5,0(s4)
    80004754:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004758:	000a3783          	ld	a5,0(s4)
    8000475c:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004760:	000a3783          	ld	a5,0(s4)
    80004764:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004768:	000a3783          	ld	a5,0(s4)
    8000476c:	0127b823          	sd	s2,16(a5)
  return 0;
    80004770:	4501                	li	a0,0
    80004772:	6942                	ld	s2,16(sp)
    80004774:	69a2                	ld	s3,8(sp)
    80004776:	a01d                	j	8000479c <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004778:	6088                	ld	a0,0(s1)
    8000477a:	c119                	beqz	a0,80004780 <pipealloc+0x9c>
    8000477c:	6942                	ld	s2,16(sp)
    8000477e:	a029                	j	80004788 <pipealloc+0xa4>
    80004780:	6942                	ld	s2,16(sp)
    80004782:	a029                	j	8000478c <pipealloc+0xa8>
    80004784:	6088                	ld	a0,0(s1)
    80004786:	c10d                	beqz	a0,800047a8 <pipealloc+0xc4>
    fileclose(*f0);
    80004788:	c53ff0ef          	jal	800043da <fileclose>
  if(*f1)
    8000478c:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004790:	557d                	li	a0,-1
  if(*f1)
    80004792:	c789                	beqz	a5,8000479c <pipealloc+0xb8>
    fileclose(*f1);
    80004794:	853e                	mv	a0,a5
    80004796:	c45ff0ef          	jal	800043da <fileclose>
  return -1;
    8000479a:	557d                	li	a0,-1
}
    8000479c:	70a2                	ld	ra,40(sp)
    8000479e:	7402                	ld	s0,32(sp)
    800047a0:	64e2                	ld	s1,24(sp)
    800047a2:	6a02                	ld	s4,0(sp)
    800047a4:	6145                	addi	sp,sp,48
    800047a6:	8082                	ret
  return -1;
    800047a8:	557d                	li	a0,-1
    800047aa:	bfcd                	j	8000479c <pipealloc+0xb8>

00000000800047ac <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800047ac:	1101                	addi	sp,sp,-32
    800047ae:	ec06                	sd	ra,24(sp)
    800047b0:	e822                	sd	s0,16(sp)
    800047b2:	e426                	sd	s1,8(sp)
    800047b4:	e04a                	sd	s2,0(sp)
    800047b6:	1000                	addi	s0,sp,32
    800047b8:	84aa                	mv	s1,a0
    800047ba:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800047bc:	c38fc0ef          	jal	80000bf4 <acquire>
  if(writable){
    800047c0:	02090763          	beqz	s2,800047ee <pipeclose+0x42>
    pi->writeopen = 0;
    800047c4:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800047c8:	21848513          	addi	a0,s1,536
    800047cc:	a97fd0ef          	jal	80002262 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800047d0:	2204b783          	ld	a5,544(s1)
    800047d4:	e785                	bnez	a5,800047fc <pipeclose+0x50>
    release(&pi->lock);
    800047d6:	8526                	mv	a0,s1
    800047d8:	cb4fc0ef          	jal	80000c8c <release>
    kfree((char*)pi);
    800047dc:	8526                	mv	a0,s1
    800047de:	a64fc0ef          	jal	80000a42 <kfree>
  } else
    release(&pi->lock);
}
    800047e2:	60e2                	ld	ra,24(sp)
    800047e4:	6442                	ld	s0,16(sp)
    800047e6:	64a2                	ld	s1,8(sp)
    800047e8:	6902                	ld	s2,0(sp)
    800047ea:	6105                	addi	sp,sp,32
    800047ec:	8082                	ret
    pi->readopen = 0;
    800047ee:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800047f2:	21c48513          	addi	a0,s1,540
    800047f6:	a6dfd0ef          	jal	80002262 <wakeup>
    800047fa:	bfd9                	j	800047d0 <pipeclose+0x24>
    release(&pi->lock);
    800047fc:	8526                	mv	a0,s1
    800047fe:	c8efc0ef          	jal	80000c8c <release>
}
    80004802:	b7c5                	j	800047e2 <pipeclose+0x36>

0000000080004804 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004804:	711d                	addi	sp,sp,-96
    80004806:	ec86                	sd	ra,88(sp)
    80004808:	e8a2                	sd	s0,80(sp)
    8000480a:	e4a6                	sd	s1,72(sp)
    8000480c:	e0ca                	sd	s2,64(sp)
    8000480e:	fc4e                	sd	s3,56(sp)
    80004810:	f852                	sd	s4,48(sp)
    80004812:	f456                	sd	s5,40(sp)
    80004814:	1080                	addi	s0,sp,96
    80004816:	84aa                	mv	s1,a0
    80004818:	8aae                	mv	s5,a1
    8000481a:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000481c:	8e6fd0ef          	jal	80001902 <myproc>
    80004820:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004822:	8526                	mv	a0,s1
    80004824:	bd0fc0ef          	jal	80000bf4 <acquire>
  while(i < n){
    80004828:	0b405a63          	blez	s4,800048dc <pipewrite+0xd8>
    8000482c:	f05a                	sd	s6,32(sp)
    8000482e:	ec5e                	sd	s7,24(sp)
    80004830:	e862                	sd	s8,16(sp)
  int i = 0;
    80004832:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004834:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004836:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000483a:	21c48b93          	addi	s7,s1,540
    8000483e:	a81d                	j	80004874 <pipewrite+0x70>
      release(&pi->lock);
    80004840:	8526                	mv	a0,s1
    80004842:	c4afc0ef          	jal	80000c8c <release>
      return -1;
    80004846:	597d                	li	s2,-1
    80004848:	7b02                	ld	s6,32(sp)
    8000484a:	6be2                	ld	s7,24(sp)
    8000484c:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000484e:	854a                	mv	a0,s2
    80004850:	60e6                	ld	ra,88(sp)
    80004852:	6446                	ld	s0,80(sp)
    80004854:	64a6                	ld	s1,72(sp)
    80004856:	6906                	ld	s2,64(sp)
    80004858:	79e2                	ld	s3,56(sp)
    8000485a:	7a42                	ld	s4,48(sp)
    8000485c:	7aa2                	ld	s5,40(sp)
    8000485e:	6125                	addi	sp,sp,96
    80004860:	8082                	ret
      wakeup(&pi->nread);
    80004862:	8562                	mv	a0,s8
    80004864:	9fffd0ef          	jal	80002262 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004868:	85a6                	mv	a1,s1
    8000486a:	855e                	mv	a0,s7
    8000486c:	9abfd0ef          	jal	80002216 <sleep>
  while(i < n){
    80004870:	05495b63          	bge	s2,s4,800048c6 <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    80004874:	2204a783          	lw	a5,544(s1)
    80004878:	d7e1                	beqz	a5,80004840 <pipewrite+0x3c>
    8000487a:	854e                	mv	a0,s3
    8000487c:	c39fd0ef          	jal	800024b4 <killed>
    80004880:	f161                	bnez	a0,80004840 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004882:	2184a783          	lw	a5,536(s1)
    80004886:	21c4a703          	lw	a4,540(s1)
    8000488a:	2007879b          	addiw	a5,a5,512
    8000488e:	fcf70ae3          	beq	a4,a5,80004862 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004892:	4685                	li	a3,1
    80004894:	01590633          	add	a2,s2,s5
    80004898:	faf40593          	addi	a1,s0,-81
    8000489c:	0509b503          	ld	a0,80(s3)
    800048a0:	db3fc0ef          	jal	80001652 <copyin>
    800048a4:	03650e63          	beq	a0,s6,800048e0 <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800048a8:	21c4a783          	lw	a5,540(s1)
    800048ac:	0017871b          	addiw	a4,a5,1
    800048b0:	20e4ae23          	sw	a4,540(s1)
    800048b4:	1ff7f793          	andi	a5,a5,511
    800048b8:	97a6                	add	a5,a5,s1
    800048ba:	faf44703          	lbu	a4,-81(s0)
    800048be:	00e78c23          	sb	a4,24(a5)
      i++;
    800048c2:	2905                	addiw	s2,s2,1
    800048c4:	b775                	j	80004870 <pipewrite+0x6c>
    800048c6:	7b02                	ld	s6,32(sp)
    800048c8:	6be2                	ld	s7,24(sp)
    800048ca:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    800048cc:	21848513          	addi	a0,s1,536
    800048d0:	993fd0ef          	jal	80002262 <wakeup>
  release(&pi->lock);
    800048d4:	8526                	mv	a0,s1
    800048d6:	bb6fc0ef          	jal	80000c8c <release>
  return i;
    800048da:	bf95                	j	8000484e <pipewrite+0x4a>
  int i = 0;
    800048dc:	4901                	li	s2,0
    800048de:	b7fd                	j	800048cc <pipewrite+0xc8>
    800048e0:	7b02                	ld	s6,32(sp)
    800048e2:	6be2                	ld	s7,24(sp)
    800048e4:	6c42                	ld	s8,16(sp)
    800048e6:	b7dd                	j	800048cc <pipewrite+0xc8>

00000000800048e8 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800048e8:	715d                	addi	sp,sp,-80
    800048ea:	e486                	sd	ra,72(sp)
    800048ec:	e0a2                	sd	s0,64(sp)
    800048ee:	fc26                	sd	s1,56(sp)
    800048f0:	f84a                	sd	s2,48(sp)
    800048f2:	f44e                	sd	s3,40(sp)
    800048f4:	f052                	sd	s4,32(sp)
    800048f6:	ec56                	sd	s5,24(sp)
    800048f8:	0880                	addi	s0,sp,80
    800048fa:	84aa                	mv	s1,a0
    800048fc:	892e                	mv	s2,a1
    800048fe:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004900:	802fd0ef          	jal	80001902 <myproc>
    80004904:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004906:	8526                	mv	a0,s1
    80004908:	aecfc0ef          	jal	80000bf4 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000490c:	2184a703          	lw	a4,536(s1)
    80004910:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004914:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004918:	02f71563          	bne	a4,a5,80004942 <piperead+0x5a>
    8000491c:	2244a783          	lw	a5,548(s1)
    80004920:	cb85                	beqz	a5,80004950 <piperead+0x68>
    if(killed(pr)){
    80004922:	8552                	mv	a0,s4
    80004924:	b91fd0ef          	jal	800024b4 <killed>
    80004928:	ed19                	bnez	a0,80004946 <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000492a:	85a6                	mv	a1,s1
    8000492c:	854e                	mv	a0,s3
    8000492e:	8e9fd0ef          	jal	80002216 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004932:	2184a703          	lw	a4,536(s1)
    80004936:	21c4a783          	lw	a5,540(s1)
    8000493a:	fef701e3          	beq	a4,a5,8000491c <piperead+0x34>
    8000493e:	e85a                	sd	s6,16(sp)
    80004940:	a809                	j	80004952 <piperead+0x6a>
    80004942:	e85a                	sd	s6,16(sp)
    80004944:	a039                	j	80004952 <piperead+0x6a>
      release(&pi->lock);
    80004946:	8526                	mv	a0,s1
    80004948:	b44fc0ef          	jal	80000c8c <release>
      return -1;
    8000494c:	59fd                	li	s3,-1
    8000494e:	a8b1                	j	800049aa <piperead+0xc2>
    80004950:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004952:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004954:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004956:	05505263          	blez	s5,8000499a <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    8000495a:	2184a783          	lw	a5,536(s1)
    8000495e:	21c4a703          	lw	a4,540(s1)
    80004962:	02f70c63          	beq	a4,a5,8000499a <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004966:	0017871b          	addiw	a4,a5,1
    8000496a:	20e4ac23          	sw	a4,536(s1)
    8000496e:	1ff7f793          	andi	a5,a5,511
    80004972:	97a6                	add	a5,a5,s1
    80004974:	0187c783          	lbu	a5,24(a5)
    80004978:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000497c:	4685                	li	a3,1
    8000497e:	fbf40613          	addi	a2,s0,-65
    80004982:	85ca                	mv	a1,s2
    80004984:	050a3503          	ld	a0,80(s4)
    80004988:	bf5fc0ef          	jal	8000157c <copyout>
    8000498c:	01650763          	beq	a0,s6,8000499a <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004990:	2985                	addiw	s3,s3,1
    80004992:	0905                	addi	s2,s2,1
    80004994:	fd3a93e3          	bne	s5,s3,8000495a <piperead+0x72>
    80004998:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000499a:	21c48513          	addi	a0,s1,540
    8000499e:	8c5fd0ef          	jal	80002262 <wakeup>
  release(&pi->lock);
    800049a2:	8526                	mv	a0,s1
    800049a4:	ae8fc0ef          	jal	80000c8c <release>
    800049a8:	6b42                	ld	s6,16(sp)
  return i;
}
    800049aa:	854e                	mv	a0,s3
    800049ac:	60a6                	ld	ra,72(sp)
    800049ae:	6406                	ld	s0,64(sp)
    800049b0:	74e2                	ld	s1,56(sp)
    800049b2:	7942                	ld	s2,48(sp)
    800049b4:	79a2                	ld	s3,40(sp)
    800049b6:	7a02                	ld	s4,32(sp)
    800049b8:	6ae2                	ld	s5,24(sp)
    800049ba:	6161                	addi	sp,sp,80
    800049bc:	8082                	ret

00000000800049be <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    800049be:	1141                	addi	sp,sp,-16
    800049c0:	e422                	sd	s0,8(sp)
    800049c2:	0800                	addi	s0,sp,16
    800049c4:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800049c6:	8905                	andi	a0,a0,1
    800049c8:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    800049ca:	8b89                	andi	a5,a5,2
    800049cc:	c399                	beqz	a5,800049d2 <flags2perm+0x14>
      perm |= PTE_W;
    800049ce:	00456513          	ori	a0,a0,4
    return perm;
}
    800049d2:	6422                	ld	s0,8(sp)
    800049d4:	0141                	addi	sp,sp,16
    800049d6:	8082                	ret

00000000800049d8 <exec>:

int
exec(char *path, char **argv)
{
    800049d8:	df010113          	addi	sp,sp,-528
    800049dc:	20113423          	sd	ra,520(sp)
    800049e0:	20813023          	sd	s0,512(sp)
    800049e4:	ffa6                	sd	s1,504(sp)
    800049e6:	fbca                	sd	s2,496(sp)
    800049e8:	0c00                	addi	s0,sp,528
    800049ea:	892a                	mv	s2,a0
    800049ec:	dea43c23          	sd	a0,-520(s0)
    800049f0:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800049f4:	f0ffc0ef          	jal	80001902 <myproc>
    800049f8:	84aa                	mv	s1,a0

  begin_op();
    800049fa:	d72ff0ef          	jal	80003f6c <begin_op>

  if((ip = namei(path)) == 0){
    800049fe:	854a                	mv	a0,s2
    80004a00:	bb0ff0ef          	jal	80003db0 <namei>
    80004a04:	c931                	beqz	a0,80004a58 <exec+0x80>
    80004a06:	f3d2                	sd	s4,480(sp)
    80004a08:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004a0a:	ccdfe0ef          	jal	800036d6 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004a0e:	04000713          	li	a4,64
    80004a12:	4681                	li	a3,0
    80004a14:	e5040613          	addi	a2,s0,-432
    80004a18:	4581                	li	a1,0
    80004a1a:	8552                	mv	a0,s4
    80004a1c:	f0ffe0ef          	jal	8000392a <readi>
    80004a20:	04000793          	li	a5,64
    80004a24:	00f51a63          	bne	a0,a5,80004a38 <exec+0x60>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004a28:	e5042703          	lw	a4,-432(s0)
    80004a2c:	464c47b7          	lui	a5,0x464c4
    80004a30:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004a34:	02f70663          	beq	a4,a5,80004a60 <exec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004a38:	8552                	mv	a0,s4
    80004a3a:	ea7fe0ef          	jal	800038e0 <iunlockput>
    end_op();
    80004a3e:	d98ff0ef          	jal	80003fd6 <end_op>
  }
  return -1;
    80004a42:	557d                	li	a0,-1
    80004a44:	7a1e                	ld	s4,480(sp)
}
    80004a46:	20813083          	ld	ra,520(sp)
    80004a4a:	20013403          	ld	s0,512(sp)
    80004a4e:	74fe                	ld	s1,504(sp)
    80004a50:	795e                	ld	s2,496(sp)
    80004a52:	21010113          	addi	sp,sp,528
    80004a56:	8082                	ret
    end_op();
    80004a58:	d7eff0ef          	jal	80003fd6 <end_op>
    return -1;
    80004a5c:	557d                	li	a0,-1
    80004a5e:	b7e5                	j	80004a46 <exec+0x6e>
    80004a60:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004a62:	8526                	mv	a0,s1
    80004a64:	9e8fd0ef          	jal	80001c4c <proc_pagetable>
    80004a68:	8b2a                	mv	s6,a0
    80004a6a:	2c050b63          	beqz	a0,80004d40 <exec+0x368>
    80004a6e:	f7ce                	sd	s3,488(sp)
    80004a70:	efd6                	sd	s5,472(sp)
    80004a72:	e7de                	sd	s7,456(sp)
    80004a74:	e3e2                	sd	s8,448(sp)
    80004a76:	ff66                	sd	s9,440(sp)
    80004a78:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004a7a:	e7042d03          	lw	s10,-400(s0)
    80004a7e:	e8845783          	lhu	a5,-376(s0)
    80004a82:	12078963          	beqz	a5,80004bb4 <exec+0x1dc>
    80004a86:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004a88:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004a8a:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80004a8c:	6c85                	lui	s9,0x1
    80004a8e:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004a92:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004a96:	6a85                	lui	s5,0x1
    80004a98:	a085                	j	80004af8 <exec+0x120>
      panic("loadseg: address should exist");
    80004a9a:	00003517          	auipc	a0,0x3
    80004a9e:	d1650513          	addi	a0,a0,-746 # 800077b0 <etext+0x7b0>
    80004aa2:	cf3fb0ef          	jal	80000794 <panic>
    if(sz - i < PGSIZE)
    80004aa6:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004aa8:	8726                	mv	a4,s1
    80004aaa:	012c06bb          	addw	a3,s8,s2
    80004aae:	4581                	li	a1,0
    80004ab0:	8552                	mv	a0,s4
    80004ab2:	e79fe0ef          	jal	8000392a <readi>
    80004ab6:	2501                	sext.w	a0,a0
    80004ab8:	24a49a63          	bne	s1,a0,80004d0c <exec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    80004abc:	012a893b          	addw	s2,s5,s2
    80004ac0:	03397363          	bgeu	s2,s3,80004ae6 <exec+0x10e>
    pa = walkaddr(pagetable, va + i);
    80004ac4:	02091593          	slli	a1,s2,0x20
    80004ac8:	9181                	srli	a1,a1,0x20
    80004aca:	95de                	add	a1,a1,s7
    80004acc:	855a                	mv	a0,s6
    80004ace:	d32fc0ef          	jal	80001000 <walkaddr>
    80004ad2:	862a                	mv	a2,a0
    if(pa == 0)
    80004ad4:	d179                	beqz	a0,80004a9a <exec+0xc2>
    if(sz - i < PGSIZE)
    80004ad6:	412984bb          	subw	s1,s3,s2
    80004ada:	0004879b          	sext.w	a5,s1
    80004ade:	fcfcf4e3          	bgeu	s9,a5,80004aa6 <exec+0xce>
    80004ae2:	84d6                	mv	s1,s5
    80004ae4:	b7c9                	j	80004aa6 <exec+0xce>
    sz = sz1;
    80004ae6:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004aea:	2d85                	addiw	s11,s11,1
    80004aec:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    80004af0:	e8845783          	lhu	a5,-376(s0)
    80004af4:	08fdd063          	bge	s11,a5,80004b74 <exec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004af8:	2d01                	sext.w	s10,s10
    80004afa:	03800713          	li	a4,56
    80004afe:	86ea                	mv	a3,s10
    80004b00:	e1840613          	addi	a2,s0,-488
    80004b04:	4581                	li	a1,0
    80004b06:	8552                	mv	a0,s4
    80004b08:	e23fe0ef          	jal	8000392a <readi>
    80004b0c:	03800793          	li	a5,56
    80004b10:	1cf51663          	bne	a0,a5,80004cdc <exec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    80004b14:	e1842783          	lw	a5,-488(s0)
    80004b18:	4705                	li	a4,1
    80004b1a:	fce798e3          	bne	a5,a4,80004aea <exec+0x112>
    if(ph.memsz < ph.filesz)
    80004b1e:	e4043483          	ld	s1,-448(s0)
    80004b22:	e3843783          	ld	a5,-456(s0)
    80004b26:	1af4ef63          	bltu	s1,a5,80004ce4 <exec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004b2a:	e2843783          	ld	a5,-472(s0)
    80004b2e:	94be                	add	s1,s1,a5
    80004b30:	1af4ee63          	bltu	s1,a5,80004cec <exec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    80004b34:	df043703          	ld	a4,-528(s0)
    80004b38:	8ff9                	and	a5,a5,a4
    80004b3a:	1a079d63          	bnez	a5,80004cf4 <exec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004b3e:	e1c42503          	lw	a0,-484(s0)
    80004b42:	e7dff0ef          	jal	800049be <flags2perm>
    80004b46:	86aa                	mv	a3,a0
    80004b48:	8626                	mv	a2,s1
    80004b4a:	85ca                	mv	a1,s2
    80004b4c:	855a                	mv	a0,s6
    80004b4e:	81bfc0ef          	jal	80001368 <uvmalloc>
    80004b52:	e0a43423          	sd	a0,-504(s0)
    80004b56:	1a050363          	beqz	a0,80004cfc <exec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004b5a:	e2843b83          	ld	s7,-472(s0)
    80004b5e:	e2042c03          	lw	s8,-480(s0)
    80004b62:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004b66:	00098463          	beqz	s3,80004b6e <exec+0x196>
    80004b6a:	4901                	li	s2,0
    80004b6c:	bfa1                	j	80004ac4 <exec+0xec>
    sz = sz1;
    80004b6e:	e0843903          	ld	s2,-504(s0)
    80004b72:	bfa5                	j	80004aea <exec+0x112>
    80004b74:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80004b76:	8552                	mv	a0,s4
    80004b78:	d69fe0ef          	jal	800038e0 <iunlockput>
  end_op();
    80004b7c:	c5aff0ef          	jal	80003fd6 <end_op>
  p = myproc();
    80004b80:	d83fc0ef          	jal	80001902 <myproc>
    80004b84:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004b86:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80004b8a:	6985                	lui	s3,0x1
    80004b8c:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004b8e:	99ca                	add	s3,s3,s2
    80004b90:	77fd                	lui	a5,0xfffff
    80004b92:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004b96:	4691                	li	a3,4
    80004b98:	6609                	lui	a2,0x2
    80004b9a:	964e                	add	a2,a2,s3
    80004b9c:	85ce                	mv	a1,s3
    80004b9e:	855a                	mv	a0,s6
    80004ba0:	fc8fc0ef          	jal	80001368 <uvmalloc>
    80004ba4:	892a                	mv	s2,a0
    80004ba6:	e0a43423          	sd	a0,-504(s0)
    80004baa:	e519                	bnez	a0,80004bb8 <exec+0x1e0>
  if(pagetable)
    80004bac:	e1343423          	sd	s3,-504(s0)
    80004bb0:	4a01                	li	s4,0
    80004bb2:	aab1                	j	80004d0e <exec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004bb4:	4901                	li	s2,0
    80004bb6:	b7c1                	j	80004b76 <exec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004bb8:	75f9                	lui	a1,0xffffe
    80004bba:	95aa                	add	a1,a1,a0
    80004bbc:	855a                	mv	a0,s6
    80004bbe:	995fc0ef          	jal	80001552 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004bc2:	7bfd                	lui	s7,0xfffff
    80004bc4:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80004bc6:	e0043783          	ld	a5,-512(s0)
    80004bca:	6388                	ld	a0,0(a5)
    80004bcc:	cd39                	beqz	a0,80004c2a <exec+0x252>
    80004bce:	e9040993          	addi	s3,s0,-368
    80004bd2:	f9040c13          	addi	s8,s0,-112
    80004bd6:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004bd8:	a60fc0ef          	jal	80000e38 <strlen>
    80004bdc:	0015079b          	addiw	a5,a0,1
    80004be0:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004be4:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004be8:	11796e63          	bltu	s2,s7,80004d04 <exec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004bec:	e0043d03          	ld	s10,-512(s0)
    80004bf0:	000d3a03          	ld	s4,0(s10)
    80004bf4:	8552                	mv	a0,s4
    80004bf6:	a42fc0ef          	jal	80000e38 <strlen>
    80004bfa:	0015069b          	addiw	a3,a0,1
    80004bfe:	8652                	mv	a2,s4
    80004c00:	85ca                	mv	a1,s2
    80004c02:	855a                	mv	a0,s6
    80004c04:	979fc0ef          	jal	8000157c <copyout>
    80004c08:	10054063          	bltz	a0,80004d08 <exec+0x330>
    ustack[argc] = sp;
    80004c0c:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004c10:	0485                	addi	s1,s1,1
    80004c12:	008d0793          	addi	a5,s10,8
    80004c16:	e0f43023          	sd	a5,-512(s0)
    80004c1a:	008d3503          	ld	a0,8(s10)
    80004c1e:	c909                	beqz	a0,80004c30 <exec+0x258>
    if(argc >= MAXARG)
    80004c20:	09a1                	addi	s3,s3,8
    80004c22:	fb899be3          	bne	s3,s8,80004bd8 <exec+0x200>
  ip = 0;
    80004c26:	4a01                	li	s4,0
    80004c28:	a0dd                	j	80004d0e <exec+0x336>
  sp = sz;
    80004c2a:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80004c2e:	4481                	li	s1,0
  ustack[argc] = 0;
    80004c30:	00349793          	slli	a5,s1,0x3
    80004c34:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdbf80>
    80004c38:	97a2                	add	a5,a5,s0
    80004c3a:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004c3e:	00148693          	addi	a3,s1,1
    80004c42:	068e                	slli	a3,a3,0x3
    80004c44:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004c48:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004c4c:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80004c50:	f5796ee3          	bltu	s2,s7,80004bac <exec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004c54:	e9040613          	addi	a2,s0,-368
    80004c58:	85ca                	mv	a1,s2
    80004c5a:	855a                	mv	a0,s6
    80004c5c:	921fc0ef          	jal	8000157c <copyout>
    80004c60:	0e054263          	bltz	a0,80004d44 <exec+0x36c>
  p->trapframe->a1 = sp;
    80004c64:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004c68:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004c6c:	df843783          	ld	a5,-520(s0)
    80004c70:	0007c703          	lbu	a4,0(a5)
    80004c74:	cf11                	beqz	a4,80004c90 <exec+0x2b8>
    80004c76:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004c78:	02f00693          	li	a3,47
    80004c7c:	a039                	j	80004c8a <exec+0x2b2>
      last = s+1;
    80004c7e:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004c82:	0785                	addi	a5,a5,1
    80004c84:	fff7c703          	lbu	a4,-1(a5)
    80004c88:	c701                	beqz	a4,80004c90 <exec+0x2b8>
    if(*s == '/')
    80004c8a:	fed71ce3          	bne	a4,a3,80004c82 <exec+0x2aa>
    80004c8e:	bfc5                	j	80004c7e <exec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    80004c90:	4641                	li	a2,16
    80004c92:	df843583          	ld	a1,-520(s0)
    80004c96:	158a8513          	addi	a0,s5,344
    80004c9a:	96cfc0ef          	jal	80000e06 <safestrcpy>
  oldpagetable = p->pagetable;
    80004c9e:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004ca2:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004ca6:	e0843783          	ld	a5,-504(s0)
    80004caa:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004cae:	058ab783          	ld	a5,88(s5)
    80004cb2:	e6843703          	ld	a4,-408(s0)
    80004cb6:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004cb8:	058ab783          	ld	a5,88(s5)
    80004cbc:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004cc0:	85e6                	mv	a1,s9
    80004cc2:	80efd0ef          	jal	80001cd0 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004cc6:	0004851b          	sext.w	a0,s1
    80004cca:	79be                	ld	s3,488(sp)
    80004ccc:	7a1e                	ld	s4,480(sp)
    80004cce:	6afe                	ld	s5,472(sp)
    80004cd0:	6b5e                	ld	s6,464(sp)
    80004cd2:	6bbe                	ld	s7,456(sp)
    80004cd4:	6c1e                	ld	s8,448(sp)
    80004cd6:	7cfa                	ld	s9,440(sp)
    80004cd8:	7d5a                	ld	s10,432(sp)
    80004cda:	b3b5                	j	80004a46 <exec+0x6e>
    80004cdc:	e1243423          	sd	s2,-504(s0)
    80004ce0:	7dba                	ld	s11,424(sp)
    80004ce2:	a035                	j	80004d0e <exec+0x336>
    80004ce4:	e1243423          	sd	s2,-504(s0)
    80004ce8:	7dba                	ld	s11,424(sp)
    80004cea:	a015                	j	80004d0e <exec+0x336>
    80004cec:	e1243423          	sd	s2,-504(s0)
    80004cf0:	7dba                	ld	s11,424(sp)
    80004cf2:	a831                	j	80004d0e <exec+0x336>
    80004cf4:	e1243423          	sd	s2,-504(s0)
    80004cf8:	7dba                	ld	s11,424(sp)
    80004cfa:	a811                	j	80004d0e <exec+0x336>
    80004cfc:	e1243423          	sd	s2,-504(s0)
    80004d00:	7dba                	ld	s11,424(sp)
    80004d02:	a031                	j	80004d0e <exec+0x336>
  ip = 0;
    80004d04:	4a01                	li	s4,0
    80004d06:	a021                	j	80004d0e <exec+0x336>
    80004d08:	4a01                	li	s4,0
  if(pagetable)
    80004d0a:	a011                	j	80004d0e <exec+0x336>
    80004d0c:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80004d0e:	e0843583          	ld	a1,-504(s0)
    80004d12:	855a                	mv	a0,s6
    80004d14:	fbdfc0ef          	jal	80001cd0 <proc_freepagetable>
  return -1;
    80004d18:	557d                	li	a0,-1
  if(ip){
    80004d1a:	000a1b63          	bnez	s4,80004d30 <exec+0x358>
    80004d1e:	79be                	ld	s3,488(sp)
    80004d20:	7a1e                	ld	s4,480(sp)
    80004d22:	6afe                	ld	s5,472(sp)
    80004d24:	6b5e                	ld	s6,464(sp)
    80004d26:	6bbe                	ld	s7,456(sp)
    80004d28:	6c1e                	ld	s8,448(sp)
    80004d2a:	7cfa                	ld	s9,440(sp)
    80004d2c:	7d5a                	ld	s10,432(sp)
    80004d2e:	bb21                	j	80004a46 <exec+0x6e>
    80004d30:	79be                	ld	s3,488(sp)
    80004d32:	6afe                	ld	s5,472(sp)
    80004d34:	6b5e                	ld	s6,464(sp)
    80004d36:	6bbe                	ld	s7,456(sp)
    80004d38:	6c1e                	ld	s8,448(sp)
    80004d3a:	7cfa                	ld	s9,440(sp)
    80004d3c:	7d5a                	ld	s10,432(sp)
    80004d3e:	b9ed                	j	80004a38 <exec+0x60>
    80004d40:	6b5e                	ld	s6,464(sp)
    80004d42:	b9dd                	j	80004a38 <exec+0x60>
  sz = sz1;
    80004d44:	e0843983          	ld	s3,-504(s0)
    80004d48:	b595                	j	80004bac <exec+0x1d4>

0000000080004d4a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004d4a:	7179                	addi	sp,sp,-48
    80004d4c:	f406                	sd	ra,40(sp)
    80004d4e:	f022                	sd	s0,32(sp)
    80004d50:	ec26                	sd	s1,24(sp)
    80004d52:	e84a                	sd	s2,16(sp)
    80004d54:	1800                	addi	s0,sp,48
    80004d56:	892e                	mv	s2,a1
    80004d58:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004d5a:	fdc40593          	addi	a1,s0,-36
    80004d5e:	e57fd0ef          	jal	80002bb4 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004d62:	fdc42703          	lw	a4,-36(s0)
    80004d66:	47bd                	li	a5,15
    80004d68:	02e7e963          	bltu	a5,a4,80004d9a <argfd+0x50>
    80004d6c:	b97fc0ef          	jal	80001902 <myproc>
    80004d70:	fdc42703          	lw	a4,-36(s0)
    80004d74:	01a70793          	addi	a5,a4,26
    80004d78:	078e                	slli	a5,a5,0x3
    80004d7a:	953e                	add	a0,a0,a5
    80004d7c:	611c                	ld	a5,0(a0)
    80004d7e:	c385                	beqz	a5,80004d9e <argfd+0x54>
    return -1;
  if(pfd)
    80004d80:	00090463          	beqz	s2,80004d88 <argfd+0x3e>
    *pfd = fd;
    80004d84:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004d88:	4501                	li	a0,0
  if(pf)
    80004d8a:	c091                	beqz	s1,80004d8e <argfd+0x44>
    *pf = f;
    80004d8c:	e09c                	sd	a5,0(s1)
}
    80004d8e:	70a2                	ld	ra,40(sp)
    80004d90:	7402                	ld	s0,32(sp)
    80004d92:	64e2                	ld	s1,24(sp)
    80004d94:	6942                	ld	s2,16(sp)
    80004d96:	6145                	addi	sp,sp,48
    80004d98:	8082                	ret
    return -1;
    80004d9a:	557d                	li	a0,-1
    80004d9c:	bfcd                	j	80004d8e <argfd+0x44>
    80004d9e:	557d                	li	a0,-1
    80004da0:	b7fd                	j	80004d8e <argfd+0x44>

0000000080004da2 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004da2:	1101                	addi	sp,sp,-32
    80004da4:	ec06                	sd	ra,24(sp)
    80004da6:	e822                	sd	s0,16(sp)
    80004da8:	e426                	sd	s1,8(sp)
    80004daa:	1000                	addi	s0,sp,32
    80004dac:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004dae:	b55fc0ef          	jal	80001902 <myproc>
    80004db2:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004db4:	0d050793          	addi	a5,a0,208
    80004db8:	4501                	li	a0,0
    80004dba:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004dbc:	6398                	ld	a4,0(a5)
    80004dbe:	cb19                	beqz	a4,80004dd4 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004dc0:	2505                	addiw	a0,a0,1
    80004dc2:	07a1                	addi	a5,a5,8
    80004dc4:	fed51ce3          	bne	a0,a3,80004dbc <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004dc8:	557d                	li	a0,-1
}
    80004dca:	60e2                	ld	ra,24(sp)
    80004dcc:	6442                	ld	s0,16(sp)
    80004dce:	64a2                	ld	s1,8(sp)
    80004dd0:	6105                	addi	sp,sp,32
    80004dd2:	8082                	ret
      p->ofile[fd] = f;
    80004dd4:	01a50793          	addi	a5,a0,26
    80004dd8:	078e                	slli	a5,a5,0x3
    80004dda:	963e                	add	a2,a2,a5
    80004ddc:	e204                	sd	s1,0(a2)
      return fd;
    80004dde:	b7f5                	j	80004dca <fdalloc+0x28>

0000000080004de0 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004de0:	715d                	addi	sp,sp,-80
    80004de2:	e486                	sd	ra,72(sp)
    80004de4:	e0a2                	sd	s0,64(sp)
    80004de6:	fc26                	sd	s1,56(sp)
    80004de8:	f84a                	sd	s2,48(sp)
    80004dea:	f44e                	sd	s3,40(sp)
    80004dec:	ec56                	sd	s5,24(sp)
    80004dee:	e85a                	sd	s6,16(sp)
    80004df0:	0880                	addi	s0,sp,80
    80004df2:	8b2e                	mv	s6,a1
    80004df4:	89b2                	mv	s3,a2
    80004df6:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004df8:	fb040593          	addi	a1,s0,-80
    80004dfc:	fcffe0ef          	jal	80003dca <nameiparent>
    80004e00:	84aa                	mv	s1,a0
    80004e02:	10050a63          	beqz	a0,80004f16 <create+0x136>
    return 0;

  ilock(dp);
    80004e06:	8d1fe0ef          	jal	800036d6 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004e0a:	4601                	li	a2,0
    80004e0c:	fb040593          	addi	a1,s0,-80
    80004e10:	8526                	mv	a0,s1
    80004e12:	d39fe0ef          	jal	80003b4a <dirlookup>
    80004e16:	8aaa                	mv	s5,a0
    80004e18:	c129                	beqz	a0,80004e5a <create+0x7a>
    iunlockput(dp);
    80004e1a:	8526                	mv	a0,s1
    80004e1c:	ac5fe0ef          	jal	800038e0 <iunlockput>
    ilock(ip);
    80004e20:	8556                	mv	a0,s5
    80004e22:	8b5fe0ef          	jal	800036d6 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004e26:	4789                	li	a5,2
    80004e28:	02fb1463          	bne	s6,a5,80004e50 <create+0x70>
    80004e2c:	044ad783          	lhu	a5,68(s5)
    80004e30:	37f9                	addiw	a5,a5,-2
    80004e32:	17c2                	slli	a5,a5,0x30
    80004e34:	93c1                	srli	a5,a5,0x30
    80004e36:	4705                	li	a4,1
    80004e38:	00f76c63          	bltu	a4,a5,80004e50 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004e3c:	8556                	mv	a0,s5
    80004e3e:	60a6                	ld	ra,72(sp)
    80004e40:	6406                	ld	s0,64(sp)
    80004e42:	74e2                	ld	s1,56(sp)
    80004e44:	7942                	ld	s2,48(sp)
    80004e46:	79a2                	ld	s3,40(sp)
    80004e48:	6ae2                	ld	s5,24(sp)
    80004e4a:	6b42                	ld	s6,16(sp)
    80004e4c:	6161                	addi	sp,sp,80
    80004e4e:	8082                	ret
    iunlockput(ip);
    80004e50:	8556                	mv	a0,s5
    80004e52:	a8ffe0ef          	jal	800038e0 <iunlockput>
    return 0;
    80004e56:	4a81                	li	s5,0
    80004e58:	b7d5                	j	80004e3c <create+0x5c>
    80004e5a:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80004e5c:	85da                	mv	a1,s6
    80004e5e:	4088                	lw	a0,0(s1)
    80004e60:	f06fe0ef          	jal	80003566 <ialloc>
    80004e64:	8a2a                	mv	s4,a0
    80004e66:	cd15                	beqz	a0,80004ea2 <create+0xc2>
  ilock(ip);
    80004e68:	86ffe0ef          	jal	800036d6 <ilock>
  ip->major = major;
    80004e6c:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004e70:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004e74:	4905                	li	s2,1
    80004e76:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004e7a:	8552                	mv	a0,s4
    80004e7c:	fa6fe0ef          	jal	80003622 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004e80:	032b0763          	beq	s6,s2,80004eae <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004e84:	004a2603          	lw	a2,4(s4)
    80004e88:	fb040593          	addi	a1,s0,-80
    80004e8c:	8526                	mv	a0,s1
    80004e8e:	e89fe0ef          	jal	80003d16 <dirlink>
    80004e92:	06054563          	bltz	a0,80004efc <create+0x11c>
  iunlockput(dp);
    80004e96:	8526                	mv	a0,s1
    80004e98:	a49fe0ef          	jal	800038e0 <iunlockput>
  return ip;
    80004e9c:	8ad2                	mv	s5,s4
    80004e9e:	7a02                	ld	s4,32(sp)
    80004ea0:	bf71                	j	80004e3c <create+0x5c>
    iunlockput(dp);
    80004ea2:	8526                	mv	a0,s1
    80004ea4:	a3dfe0ef          	jal	800038e0 <iunlockput>
    return 0;
    80004ea8:	8ad2                	mv	s5,s4
    80004eaa:	7a02                	ld	s4,32(sp)
    80004eac:	bf41                	j	80004e3c <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004eae:	004a2603          	lw	a2,4(s4)
    80004eb2:	00003597          	auipc	a1,0x3
    80004eb6:	91e58593          	addi	a1,a1,-1762 # 800077d0 <etext+0x7d0>
    80004eba:	8552                	mv	a0,s4
    80004ebc:	e5bfe0ef          	jal	80003d16 <dirlink>
    80004ec0:	02054e63          	bltz	a0,80004efc <create+0x11c>
    80004ec4:	40d0                	lw	a2,4(s1)
    80004ec6:	00003597          	auipc	a1,0x3
    80004eca:	91258593          	addi	a1,a1,-1774 # 800077d8 <etext+0x7d8>
    80004ece:	8552                	mv	a0,s4
    80004ed0:	e47fe0ef          	jal	80003d16 <dirlink>
    80004ed4:	02054463          	bltz	a0,80004efc <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004ed8:	004a2603          	lw	a2,4(s4)
    80004edc:	fb040593          	addi	a1,s0,-80
    80004ee0:	8526                	mv	a0,s1
    80004ee2:	e35fe0ef          	jal	80003d16 <dirlink>
    80004ee6:	00054b63          	bltz	a0,80004efc <create+0x11c>
    dp->nlink++;  // for ".."
    80004eea:	04a4d783          	lhu	a5,74(s1)
    80004eee:	2785                	addiw	a5,a5,1
    80004ef0:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004ef4:	8526                	mv	a0,s1
    80004ef6:	f2cfe0ef          	jal	80003622 <iupdate>
    80004efa:	bf71                	j	80004e96 <create+0xb6>
  ip->nlink = 0;
    80004efc:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004f00:	8552                	mv	a0,s4
    80004f02:	f20fe0ef          	jal	80003622 <iupdate>
  iunlockput(ip);
    80004f06:	8552                	mv	a0,s4
    80004f08:	9d9fe0ef          	jal	800038e0 <iunlockput>
  iunlockput(dp);
    80004f0c:	8526                	mv	a0,s1
    80004f0e:	9d3fe0ef          	jal	800038e0 <iunlockput>
  return 0;
    80004f12:	7a02                	ld	s4,32(sp)
    80004f14:	b725                	j	80004e3c <create+0x5c>
    return 0;
    80004f16:	8aaa                	mv	s5,a0
    80004f18:	b715                	j	80004e3c <create+0x5c>

0000000080004f1a <sys_dup>:
{
    80004f1a:	7179                	addi	sp,sp,-48
    80004f1c:	f406                	sd	ra,40(sp)
    80004f1e:	f022                	sd	s0,32(sp)
    80004f20:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004f22:	fd840613          	addi	a2,s0,-40
    80004f26:	4581                	li	a1,0
    80004f28:	4501                	li	a0,0
    80004f2a:	e21ff0ef          	jal	80004d4a <argfd>
    return -1;
    80004f2e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004f30:	02054363          	bltz	a0,80004f56 <sys_dup+0x3c>
    80004f34:	ec26                	sd	s1,24(sp)
    80004f36:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004f38:	fd843903          	ld	s2,-40(s0)
    80004f3c:	854a                	mv	a0,s2
    80004f3e:	e65ff0ef          	jal	80004da2 <fdalloc>
    80004f42:	84aa                	mv	s1,a0
    return -1;
    80004f44:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004f46:	00054d63          	bltz	a0,80004f60 <sys_dup+0x46>
  filedup(f);
    80004f4a:	854a                	mv	a0,s2
    80004f4c:	c48ff0ef          	jal	80004394 <filedup>
  return fd;
    80004f50:	87a6                	mv	a5,s1
    80004f52:	64e2                	ld	s1,24(sp)
    80004f54:	6942                	ld	s2,16(sp)
}
    80004f56:	853e                	mv	a0,a5
    80004f58:	70a2                	ld	ra,40(sp)
    80004f5a:	7402                	ld	s0,32(sp)
    80004f5c:	6145                	addi	sp,sp,48
    80004f5e:	8082                	ret
    80004f60:	64e2                	ld	s1,24(sp)
    80004f62:	6942                	ld	s2,16(sp)
    80004f64:	bfcd                	j	80004f56 <sys_dup+0x3c>

0000000080004f66 <sys_read>:
{
    80004f66:	7179                	addi	sp,sp,-48
    80004f68:	f406                	sd	ra,40(sp)
    80004f6a:	f022                	sd	s0,32(sp)
    80004f6c:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004f6e:	fd840593          	addi	a1,s0,-40
    80004f72:	4505                	li	a0,1
    80004f74:	c5dfd0ef          	jal	80002bd0 <argaddr>
  argint(2, &n);
    80004f78:	fe440593          	addi	a1,s0,-28
    80004f7c:	4509                	li	a0,2
    80004f7e:	c37fd0ef          	jal	80002bb4 <argint>
  if(argfd(0, 0, &f) < 0)
    80004f82:	fe840613          	addi	a2,s0,-24
    80004f86:	4581                	li	a1,0
    80004f88:	4501                	li	a0,0
    80004f8a:	dc1ff0ef          	jal	80004d4a <argfd>
    80004f8e:	87aa                	mv	a5,a0
    return -1;
    80004f90:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004f92:	0007ca63          	bltz	a5,80004fa6 <sys_read+0x40>
  return fileread(f, p, n);
    80004f96:	fe442603          	lw	a2,-28(s0)
    80004f9a:	fd843583          	ld	a1,-40(s0)
    80004f9e:	fe843503          	ld	a0,-24(s0)
    80004fa2:	d58ff0ef          	jal	800044fa <fileread>
}
    80004fa6:	70a2                	ld	ra,40(sp)
    80004fa8:	7402                	ld	s0,32(sp)
    80004faa:	6145                	addi	sp,sp,48
    80004fac:	8082                	ret

0000000080004fae <sys_write>:
{
    80004fae:	7179                	addi	sp,sp,-48
    80004fb0:	f406                	sd	ra,40(sp)
    80004fb2:	f022                	sd	s0,32(sp)
    80004fb4:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004fb6:	fd840593          	addi	a1,s0,-40
    80004fba:	4505                	li	a0,1
    80004fbc:	c15fd0ef          	jal	80002bd0 <argaddr>
  argint(2, &n);
    80004fc0:	fe440593          	addi	a1,s0,-28
    80004fc4:	4509                	li	a0,2
    80004fc6:	beffd0ef          	jal	80002bb4 <argint>
  if(argfd(0, 0, &f) < 0)
    80004fca:	fe840613          	addi	a2,s0,-24
    80004fce:	4581                	li	a1,0
    80004fd0:	4501                	li	a0,0
    80004fd2:	d79ff0ef          	jal	80004d4a <argfd>
    80004fd6:	87aa                	mv	a5,a0
    return -1;
    80004fd8:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004fda:	0007ca63          	bltz	a5,80004fee <sys_write+0x40>
  return filewrite(f, p, n);
    80004fde:	fe442603          	lw	a2,-28(s0)
    80004fe2:	fd843583          	ld	a1,-40(s0)
    80004fe6:	fe843503          	ld	a0,-24(s0)
    80004fea:	dceff0ef          	jal	800045b8 <filewrite>
}
    80004fee:	70a2                	ld	ra,40(sp)
    80004ff0:	7402                	ld	s0,32(sp)
    80004ff2:	6145                	addi	sp,sp,48
    80004ff4:	8082                	ret

0000000080004ff6 <sys_close>:
{
    80004ff6:	1101                	addi	sp,sp,-32
    80004ff8:	ec06                	sd	ra,24(sp)
    80004ffa:	e822                	sd	s0,16(sp)
    80004ffc:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004ffe:	fe040613          	addi	a2,s0,-32
    80005002:	fec40593          	addi	a1,s0,-20
    80005006:	4501                	li	a0,0
    80005008:	d43ff0ef          	jal	80004d4a <argfd>
    return -1;
    8000500c:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000500e:	02054063          	bltz	a0,8000502e <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80005012:	8f1fc0ef          	jal	80001902 <myproc>
    80005016:	fec42783          	lw	a5,-20(s0)
    8000501a:	07e9                	addi	a5,a5,26
    8000501c:	078e                	slli	a5,a5,0x3
    8000501e:	953e                	add	a0,a0,a5
    80005020:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005024:	fe043503          	ld	a0,-32(s0)
    80005028:	bb2ff0ef          	jal	800043da <fileclose>
  return 0;
    8000502c:	4781                	li	a5,0
}
    8000502e:	853e                	mv	a0,a5
    80005030:	60e2                	ld	ra,24(sp)
    80005032:	6442                	ld	s0,16(sp)
    80005034:	6105                	addi	sp,sp,32
    80005036:	8082                	ret

0000000080005038 <sys_fstat>:
{
    80005038:	1101                	addi	sp,sp,-32
    8000503a:	ec06                	sd	ra,24(sp)
    8000503c:	e822                	sd	s0,16(sp)
    8000503e:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005040:	fe040593          	addi	a1,s0,-32
    80005044:	4505                	li	a0,1
    80005046:	b8bfd0ef          	jal	80002bd0 <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000504a:	fe840613          	addi	a2,s0,-24
    8000504e:	4581                	li	a1,0
    80005050:	4501                	li	a0,0
    80005052:	cf9ff0ef          	jal	80004d4a <argfd>
    80005056:	87aa                	mv	a5,a0
    return -1;
    80005058:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000505a:	0007c863          	bltz	a5,8000506a <sys_fstat+0x32>
  return filestat(f, st);
    8000505e:	fe043583          	ld	a1,-32(s0)
    80005062:	fe843503          	ld	a0,-24(s0)
    80005066:	c36ff0ef          	jal	8000449c <filestat>
}
    8000506a:	60e2                	ld	ra,24(sp)
    8000506c:	6442                	ld	s0,16(sp)
    8000506e:	6105                	addi	sp,sp,32
    80005070:	8082                	ret

0000000080005072 <sys_link>:
{
    80005072:	7169                	addi	sp,sp,-304
    80005074:	f606                	sd	ra,296(sp)
    80005076:	f222                	sd	s0,288(sp)
    80005078:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000507a:	08000613          	li	a2,128
    8000507e:	ed040593          	addi	a1,s0,-304
    80005082:	4501                	li	a0,0
    80005084:	b69fd0ef          	jal	80002bec <argstr>
    return -1;
    80005088:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000508a:	0c054e63          	bltz	a0,80005166 <sys_link+0xf4>
    8000508e:	08000613          	li	a2,128
    80005092:	f5040593          	addi	a1,s0,-176
    80005096:	4505                	li	a0,1
    80005098:	b55fd0ef          	jal	80002bec <argstr>
    return -1;
    8000509c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000509e:	0c054463          	bltz	a0,80005166 <sys_link+0xf4>
    800050a2:	ee26                	sd	s1,280(sp)
  begin_op();
    800050a4:	ec9fe0ef          	jal	80003f6c <begin_op>
  if((ip = namei(old)) == 0){
    800050a8:	ed040513          	addi	a0,s0,-304
    800050ac:	d05fe0ef          	jal	80003db0 <namei>
    800050b0:	84aa                	mv	s1,a0
    800050b2:	c53d                	beqz	a0,80005120 <sys_link+0xae>
  ilock(ip);
    800050b4:	e22fe0ef          	jal	800036d6 <ilock>
  if(ip->type == T_DIR){
    800050b8:	04449703          	lh	a4,68(s1)
    800050bc:	4785                	li	a5,1
    800050be:	06f70663          	beq	a4,a5,8000512a <sys_link+0xb8>
    800050c2:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    800050c4:	04a4d783          	lhu	a5,74(s1)
    800050c8:	2785                	addiw	a5,a5,1
    800050ca:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800050ce:	8526                	mv	a0,s1
    800050d0:	d52fe0ef          	jal	80003622 <iupdate>
  iunlock(ip);
    800050d4:	8526                	mv	a0,s1
    800050d6:	eaefe0ef          	jal	80003784 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800050da:	fd040593          	addi	a1,s0,-48
    800050de:	f5040513          	addi	a0,s0,-176
    800050e2:	ce9fe0ef          	jal	80003dca <nameiparent>
    800050e6:	892a                	mv	s2,a0
    800050e8:	cd21                	beqz	a0,80005140 <sys_link+0xce>
  ilock(dp);
    800050ea:	decfe0ef          	jal	800036d6 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800050ee:	00092703          	lw	a4,0(s2)
    800050f2:	409c                	lw	a5,0(s1)
    800050f4:	04f71363          	bne	a4,a5,8000513a <sys_link+0xc8>
    800050f8:	40d0                	lw	a2,4(s1)
    800050fa:	fd040593          	addi	a1,s0,-48
    800050fe:	854a                	mv	a0,s2
    80005100:	c17fe0ef          	jal	80003d16 <dirlink>
    80005104:	02054b63          	bltz	a0,8000513a <sys_link+0xc8>
  iunlockput(dp);
    80005108:	854a                	mv	a0,s2
    8000510a:	fd6fe0ef          	jal	800038e0 <iunlockput>
  iput(ip);
    8000510e:	8526                	mv	a0,s1
    80005110:	f48fe0ef          	jal	80003858 <iput>
  end_op();
    80005114:	ec3fe0ef          	jal	80003fd6 <end_op>
  return 0;
    80005118:	4781                	li	a5,0
    8000511a:	64f2                	ld	s1,280(sp)
    8000511c:	6952                	ld	s2,272(sp)
    8000511e:	a0a1                	j	80005166 <sys_link+0xf4>
    end_op();
    80005120:	eb7fe0ef          	jal	80003fd6 <end_op>
    return -1;
    80005124:	57fd                	li	a5,-1
    80005126:	64f2                	ld	s1,280(sp)
    80005128:	a83d                	j	80005166 <sys_link+0xf4>
    iunlockput(ip);
    8000512a:	8526                	mv	a0,s1
    8000512c:	fb4fe0ef          	jal	800038e0 <iunlockput>
    end_op();
    80005130:	ea7fe0ef          	jal	80003fd6 <end_op>
    return -1;
    80005134:	57fd                	li	a5,-1
    80005136:	64f2                	ld	s1,280(sp)
    80005138:	a03d                	j	80005166 <sys_link+0xf4>
    iunlockput(dp);
    8000513a:	854a                	mv	a0,s2
    8000513c:	fa4fe0ef          	jal	800038e0 <iunlockput>
  ilock(ip);
    80005140:	8526                	mv	a0,s1
    80005142:	d94fe0ef          	jal	800036d6 <ilock>
  ip->nlink--;
    80005146:	04a4d783          	lhu	a5,74(s1)
    8000514a:	37fd                	addiw	a5,a5,-1
    8000514c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005150:	8526                	mv	a0,s1
    80005152:	cd0fe0ef          	jal	80003622 <iupdate>
  iunlockput(ip);
    80005156:	8526                	mv	a0,s1
    80005158:	f88fe0ef          	jal	800038e0 <iunlockput>
  end_op();
    8000515c:	e7bfe0ef          	jal	80003fd6 <end_op>
  return -1;
    80005160:	57fd                	li	a5,-1
    80005162:	64f2                	ld	s1,280(sp)
    80005164:	6952                	ld	s2,272(sp)
}
    80005166:	853e                	mv	a0,a5
    80005168:	70b2                	ld	ra,296(sp)
    8000516a:	7412                	ld	s0,288(sp)
    8000516c:	6155                	addi	sp,sp,304
    8000516e:	8082                	ret

0000000080005170 <sys_unlink>:
{
    80005170:	7151                	addi	sp,sp,-240
    80005172:	f586                	sd	ra,232(sp)
    80005174:	f1a2                	sd	s0,224(sp)
    80005176:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005178:	08000613          	li	a2,128
    8000517c:	f3040593          	addi	a1,s0,-208
    80005180:	4501                	li	a0,0
    80005182:	a6bfd0ef          	jal	80002bec <argstr>
    80005186:	16054063          	bltz	a0,800052e6 <sys_unlink+0x176>
    8000518a:	eda6                	sd	s1,216(sp)
  begin_op();
    8000518c:	de1fe0ef          	jal	80003f6c <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005190:	fb040593          	addi	a1,s0,-80
    80005194:	f3040513          	addi	a0,s0,-208
    80005198:	c33fe0ef          	jal	80003dca <nameiparent>
    8000519c:	84aa                	mv	s1,a0
    8000519e:	c945                	beqz	a0,8000524e <sys_unlink+0xde>
  ilock(dp);
    800051a0:	d36fe0ef          	jal	800036d6 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800051a4:	00002597          	auipc	a1,0x2
    800051a8:	62c58593          	addi	a1,a1,1580 # 800077d0 <etext+0x7d0>
    800051ac:	fb040513          	addi	a0,s0,-80
    800051b0:	985fe0ef          	jal	80003b34 <namecmp>
    800051b4:	10050e63          	beqz	a0,800052d0 <sys_unlink+0x160>
    800051b8:	00002597          	auipc	a1,0x2
    800051bc:	62058593          	addi	a1,a1,1568 # 800077d8 <etext+0x7d8>
    800051c0:	fb040513          	addi	a0,s0,-80
    800051c4:	971fe0ef          	jal	80003b34 <namecmp>
    800051c8:	10050463          	beqz	a0,800052d0 <sys_unlink+0x160>
    800051cc:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    800051ce:	f2c40613          	addi	a2,s0,-212
    800051d2:	fb040593          	addi	a1,s0,-80
    800051d6:	8526                	mv	a0,s1
    800051d8:	973fe0ef          	jal	80003b4a <dirlookup>
    800051dc:	892a                	mv	s2,a0
    800051de:	0e050863          	beqz	a0,800052ce <sys_unlink+0x15e>
  ilock(ip);
    800051e2:	cf4fe0ef          	jal	800036d6 <ilock>
  if(ip->nlink < 1)
    800051e6:	04a91783          	lh	a5,74(s2)
    800051ea:	06f05763          	blez	a5,80005258 <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800051ee:	04491703          	lh	a4,68(s2)
    800051f2:	4785                	li	a5,1
    800051f4:	06f70963          	beq	a4,a5,80005266 <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    800051f8:	4641                	li	a2,16
    800051fa:	4581                	li	a1,0
    800051fc:	fc040513          	addi	a0,s0,-64
    80005200:	ac9fb0ef          	jal	80000cc8 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005204:	4741                	li	a4,16
    80005206:	f2c42683          	lw	a3,-212(s0)
    8000520a:	fc040613          	addi	a2,s0,-64
    8000520e:	4581                	li	a1,0
    80005210:	8526                	mv	a0,s1
    80005212:	815fe0ef          	jal	80003a26 <writei>
    80005216:	47c1                	li	a5,16
    80005218:	08f51b63          	bne	a0,a5,800052ae <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    8000521c:	04491703          	lh	a4,68(s2)
    80005220:	4785                	li	a5,1
    80005222:	08f70d63          	beq	a4,a5,800052bc <sys_unlink+0x14c>
  iunlockput(dp);
    80005226:	8526                	mv	a0,s1
    80005228:	eb8fe0ef          	jal	800038e0 <iunlockput>
  ip->nlink--;
    8000522c:	04a95783          	lhu	a5,74(s2)
    80005230:	37fd                	addiw	a5,a5,-1
    80005232:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005236:	854a                	mv	a0,s2
    80005238:	beafe0ef          	jal	80003622 <iupdate>
  iunlockput(ip);
    8000523c:	854a                	mv	a0,s2
    8000523e:	ea2fe0ef          	jal	800038e0 <iunlockput>
  end_op();
    80005242:	d95fe0ef          	jal	80003fd6 <end_op>
  return 0;
    80005246:	4501                	li	a0,0
    80005248:	64ee                	ld	s1,216(sp)
    8000524a:	694e                	ld	s2,208(sp)
    8000524c:	a849                	j	800052de <sys_unlink+0x16e>
    end_op();
    8000524e:	d89fe0ef          	jal	80003fd6 <end_op>
    return -1;
    80005252:	557d                	li	a0,-1
    80005254:	64ee                	ld	s1,216(sp)
    80005256:	a061                	j	800052de <sys_unlink+0x16e>
    80005258:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    8000525a:	00002517          	auipc	a0,0x2
    8000525e:	58650513          	addi	a0,a0,1414 # 800077e0 <etext+0x7e0>
    80005262:	d32fb0ef          	jal	80000794 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005266:	04c92703          	lw	a4,76(s2)
    8000526a:	02000793          	li	a5,32
    8000526e:	f8e7f5e3          	bgeu	a5,a4,800051f8 <sys_unlink+0x88>
    80005272:	e5ce                	sd	s3,200(sp)
    80005274:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005278:	4741                	li	a4,16
    8000527a:	86ce                	mv	a3,s3
    8000527c:	f1840613          	addi	a2,s0,-232
    80005280:	4581                	li	a1,0
    80005282:	854a                	mv	a0,s2
    80005284:	ea6fe0ef          	jal	8000392a <readi>
    80005288:	47c1                	li	a5,16
    8000528a:	00f51c63          	bne	a0,a5,800052a2 <sys_unlink+0x132>
    if(de.inum != 0)
    8000528e:	f1845783          	lhu	a5,-232(s0)
    80005292:	efa1                	bnez	a5,800052ea <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005294:	29c1                	addiw	s3,s3,16
    80005296:	04c92783          	lw	a5,76(s2)
    8000529a:	fcf9efe3          	bltu	s3,a5,80005278 <sys_unlink+0x108>
    8000529e:	69ae                	ld	s3,200(sp)
    800052a0:	bfa1                	j	800051f8 <sys_unlink+0x88>
      panic("isdirempty: readi");
    800052a2:	00002517          	auipc	a0,0x2
    800052a6:	55650513          	addi	a0,a0,1366 # 800077f8 <etext+0x7f8>
    800052aa:	ceafb0ef          	jal	80000794 <panic>
    800052ae:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    800052b0:	00002517          	auipc	a0,0x2
    800052b4:	56050513          	addi	a0,a0,1376 # 80007810 <etext+0x810>
    800052b8:	cdcfb0ef          	jal	80000794 <panic>
    dp->nlink--;
    800052bc:	04a4d783          	lhu	a5,74(s1)
    800052c0:	37fd                	addiw	a5,a5,-1
    800052c2:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800052c6:	8526                	mv	a0,s1
    800052c8:	b5afe0ef          	jal	80003622 <iupdate>
    800052cc:	bfa9                	j	80005226 <sys_unlink+0xb6>
    800052ce:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    800052d0:	8526                	mv	a0,s1
    800052d2:	e0efe0ef          	jal	800038e0 <iunlockput>
  end_op();
    800052d6:	d01fe0ef          	jal	80003fd6 <end_op>
  return -1;
    800052da:	557d                	li	a0,-1
    800052dc:	64ee                	ld	s1,216(sp)
}
    800052de:	70ae                	ld	ra,232(sp)
    800052e0:	740e                	ld	s0,224(sp)
    800052e2:	616d                	addi	sp,sp,240
    800052e4:	8082                	ret
    return -1;
    800052e6:	557d                	li	a0,-1
    800052e8:	bfdd                	j	800052de <sys_unlink+0x16e>
    iunlockput(ip);
    800052ea:	854a                	mv	a0,s2
    800052ec:	df4fe0ef          	jal	800038e0 <iunlockput>
    goto bad;
    800052f0:	694e                	ld	s2,208(sp)
    800052f2:	69ae                	ld	s3,200(sp)
    800052f4:	bff1                	j	800052d0 <sys_unlink+0x160>

00000000800052f6 <sys_open>:

uint64
sys_open(void)
{
    800052f6:	7131                	addi	sp,sp,-192
    800052f8:	fd06                	sd	ra,184(sp)
    800052fa:	f922                	sd	s0,176(sp)
    800052fc:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800052fe:	f4c40593          	addi	a1,s0,-180
    80005302:	4505                	li	a0,1
    80005304:	8b1fd0ef          	jal	80002bb4 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005308:	08000613          	li	a2,128
    8000530c:	f5040593          	addi	a1,s0,-176
    80005310:	4501                	li	a0,0
    80005312:	8dbfd0ef          	jal	80002bec <argstr>
    80005316:	87aa                	mv	a5,a0
    return -1;
    80005318:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000531a:	0a07c263          	bltz	a5,800053be <sys_open+0xc8>
    8000531e:	f526                	sd	s1,168(sp)

  begin_op();
    80005320:	c4dfe0ef          	jal	80003f6c <begin_op>

  if(omode & O_CREATE){
    80005324:	f4c42783          	lw	a5,-180(s0)
    80005328:	2007f793          	andi	a5,a5,512
    8000532c:	c3d5                	beqz	a5,800053d0 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    8000532e:	4681                	li	a3,0
    80005330:	4601                	li	a2,0
    80005332:	4589                	li	a1,2
    80005334:	f5040513          	addi	a0,s0,-176
    80005338:	aa9ff0ef          	jal	80004de0 <create>
    8000533c:	84aa                	mv	s1,a0
    if(ip == 0){
    8000533e:	c541                	beqz	a0,800053c6 <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005340:	04449703          	lh	a4,68(s1)
    80005344:	478d                	li	a5,3
    80005346:	00f71763          	bne	a4,a5,80005354 <sys_open+0x5e>
    8000534a:	0464d703          	lhu	a4,70(s1)
    8000534e:	47a5                	li	a5,9
    80005350:	0ae7ed63          	bltu	a5,a4,8000540a <sys_open+0x114>
    80005354:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005356:	fe1fe0ef          	jal	80004336 <filealloc>
    8000535a:	892a                	mv	s2,a0
    8000535c:	c179                	beqz	a0,80005422 <sys_open+0x12c>
    8000535e:	ed4e                	sd	s3,152(sp)
    80005360:	a43ff0ef          	jal	80004da2 <fdalloc>
    80005364:	89aa                	mv	s3,a0
    80005366:	0a054a63          	bltz	a0,8000541a <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000536a:	04449703          	lh	a4,68(s1)
    8000536e:	478d                	li	a5,3
    80005370:	0cf70263          	beq	a4,a5,80005434 <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005374:	4789                	li	a5,2
    80005376:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    8000537a:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    8000537e:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005382:	f4c42783          	lw	a5,-180(s0)
    80005386:	0017c713          	xori	a4,a5,1
    8000538a:	8b05                	andi	a4,a4,1
    8000538c:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005390:	0037f713          	andi	a4,a5,3
    80005394:	00e03733          	snez	a4,a4
    80005398:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000539c:	4007f793          	andi	a5,a5,1024
    800053a0:	c791                	beqz	a5,800053ac <sys_open+0xb6>
    800053a2:	04449703          	lh	a4,68(s1)
    800053a6:	4789                	li	a5,2
    800053a8:	08f70d63          	beq	a4,a5,80005442 <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    800053ac:	8526                	mv	a0,s1
    800053ae:	bd6fe0ef          	jal	80003784 <iunlock>
  end_op();
    800053b2:	c25fe0ef          	jal	80003fd6 <end_op>

  return fd;
    800053b6:	854e                	mv	a0,s3
    800053b8:	74aa                	ld	s1,168(sp)
    800053ba:	790a                	ld	s2,160(sp)
    800053bc:	69ea                	ld	s3,152(sp)
}
    800053be:	70ea                	ld	ra,184(sp)
    800053c0:	744a                	ld	s0,176(sp)
    800053c2:	6129                	addi	sp,sp,192
    800053c4:	8082                	ret
      end_op();
    800053c6:	c11fe0ef          	jal	80003fd6 <end_op>
      return -1;
    800053ca:	557d                	li	a0,-1
    800053cc:	74aa                	ld	s1,168(sp)
    800053ce:	bfc5                	j	800053be <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    800053d0:	f5040513          	addi	a0,s0,-176
    800053d4:	9ddfe0ef          	jal	80003db0 <namei>
    800053d8:	84aa                	mv	s1,a0
    800053da:	c11d                	beqz	a0,80005400 <sys_open+0x10a>
    ilock(ip);
    800053dc:	afafe0ef          	jal	800036d6 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800053e0:	04449703          	lh	a4,68(s1)
    800053e4:	4785                	li	a5,1
    800053e6:	f4f71de3          	bne	a4,a5,80005340 <sys_open+0x4a>
    800053ea:	f4c42783          	lw	a5,-180(s0)
    800053ee:	d3bd                	beqz	a5,80005354 <sys_open+0x5e>
      iunlockput(ip);
    800053f0:	8526                	mv	a0,s1
    800053f2:	ceefe0ef          	jal	800038e0 <iunlockput>
      end_op();
    800053f6:	be1fe0ef          	jal	80003fd6 <end_op>
      return -1;
    800053fa:	557d                	li	a0,-1
    800053fc:	74aa                	ld	s1,168(sp)
    800053fe:	b7c1                	j	800053be <sys_open+0xc8>
      end_op();
    80005400:	bd7fe0ef          	jal	80003fd6 <end_op>
      return -1;
    80005404:	557d                	li	a0,-1
    80005406:	74aa                	ld	s1,168(sp)
    80005408:	bf5d                	j	800053be <sys_open+0xc8>
    iunlockput(ip);
    8000540a:	8526                	mv	a0,s1
    8000540c:	cd4fe0ef          	jal	800038e0 <iunlockput>
    end_op();
    80005410:	bc7fe0ef          	jal	80003fd6 <end_op>
    return -1;
    80005414:	557d                	li	a0,-1
    80005416:	74aa                	ld	s1,168(sp)
    80005418:	b75d                	j	800053be <sys_open+0xc8>
      fileclose(f);
    8000541a:	854a                	mv	a0,s2
    8000541c:	fbffe0ef          	jal	800043da <fileclose>
    80005420:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005422:	8526                	mv	a0,s1
    80005424:	cbcfe0ef          	jal	800038e0 <iunlockput>
    end_op();
    80005428:	baffe0ef          	jal	80003fd6 <end_op>
    return -1;
    8000542c:	557d                	li	a0,-1
    8000542e:	74aa                	ld	s1,168(sp)
    80005430:	790a                	ld	s2,160(sp)
    80005432:	b771                	j	800053be <sys_open+0xc8>
    f->type = FD_DEVICE;
    80005434:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005438:	04649783          	lh	a5,70(s1)
    8000543c:	02f91223          	sh	a5,36(s2)
    80005440:	bf3d                	j	8000537e <sys_open+0x88>
    itrunc(ip);
    80005442:	8526                	mv	a0,s1
    80005444:	b80fe0ef          	jal	800037c4 <itrunc>
    80005448:	b795                	j	800053ac <sys_open+0xb6>

000000008000544a <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000544a:	7175                	addi	sp,sp,-144
    8000544c:	e506                	sd	ra,136(sp)
    8000544e:	e122                	sd	s0,128(sp)
    80005450:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005452:	b1bfe0ef          	jal	80003f6c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005456:	08000613          	li	a2,128
    8000545a:	f7040593          	addi	a1,s0,-144
    8000545e:	4501                	li	a0,0
    80005460:	f8cfd0ef          	jal	80002bec <argstr>
    80005464:	02054363          	bltz	a0,8000548a <sys_mkdir+0x40>
    80005468:	4681                	li	a3,0
    8000546a:	4601                	li	a2,0
    8000546c:	4585                	li	a1,1
    8000546e:	f7040513          	addi	a0,s0,-144
    80005472:	96fff0ef          	jal	80004de0 <create>
    80005476:	c911                	beqz	a0,8000548a <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005478:	c68fe0ef          	jal	800038e0 <iunlockput>
  end_op();
    8000547c:	b5bfe0ef          	jal	80003fd6 <end_op>
  return 0;
    80005480:	4501                	li	a0,0
}
    80005482:	60aa                	ld	ra,136(sp)
    80005484:	640a                	ld	s0,128(sp)
    80005486:	6149                	addi	sp,sp,144
    80005488:	8082                	ret
    end_op();
    8000548a:	b4dfe0ef          	jal	80003fd6 <end_op>
    return -1;
    8000548e:	557d                	li	a0,-1
    80005490:	bfcd                	j	80005482 <sys_mkdir+0x38>

0000000080005492 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005492:	7135                	addi	sp,sp,-160
    80005494:	ed06                	sd	ra,152(sp)
    80005496:	e922                	sd	s0,144(sp)
    80005498:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000549a:	ad3fe0ef          	jal	80003f6c <begin_op>
  argint(1, &major);
    8000549e:	f6c40593          	addi	a1,s0,-148
    800054a2:	4505                	li	a0,1
    800054a4:	f10fd0ef          	jal	80002bb4 <argint>
  argint(2, &minor);
    800054a8:	f6840593          	addi	a1,s0,-152
    800054ac:	4509                	li	a0,2
    800054ae:	f06fd0ef          	jal	80002bb4 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800054b2:	08000613          	li	a2,128
    800054b6:	f7040593          	addi	a1,s0,-144
    800054ba:	4501                	li	a0,0
    800054bc:	f30fd0ef          	jal	80002bec <argstr>
    800054c0:	02054563          	bltz	a0,800054ea <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800054c4:	f6841683          	lh	a3,-152(s0)
    800054c8:	f6c41603          	lh	a2,-148(s0)
    800054cc:	458d                	li	a1,3
    800054ce:	f7040513          	addi	a0,s0,-144
    800054d2:	90fff0ef          	jal	80004de0 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800054d6:	c911                	beqz	a0,800054ea <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800054d8:	c08fe0ef          	jal	800038e0 <iunlockput>
  end_op();
    800054dc:	afbfe0ef          	jal	80003fd6 <end_op>
  return 0;
    800054e0:	4501                	li	a0,0
}
    800054e2:	60ea                	ld	ra,152(sp)
    800054e4:	644a                	ld	s0,144(sp)
    800054e6:	610d                	addi	sp,sp,160
    800054e8:	8082                	ret
    end_op();
    800054ea:	aedfe0ef          	jal	80003fd6 <end_op>
    return -1;
    800054ee:	557d                	li	a0,-1
    800054f0:	bfcd                	j	800054e2 <sys_mknod+0x50>

00000000800054f2 <sys_chdir>:

uint64
sys_chdir(void)
{
    800054f2:	7135                	addi	sp,sp,-160
    800054f4:	ed06                	sd	ra,152(sp)
    800054f6:	e922                	sd	s0,144(sp)
    800054f8:	e14a                	sd	s2,128(sp)
    800054fa:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800054fc:	c06fc0ef          	jal	80001902 <myproc>
    80005500:	892a                	mv	s2,a0
  
  begin_op();
    80005502:	a6bfe0ef          	jal	80003f6c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005506:	08000613          	li	a2,128
    8000550a:	f6040593          	addi	a1,s0,-160
    8000550e:	4501                	li	a0,0
    80005510:	edcfd0ef          	jal	80002bec <argstr>
    80005514:	04054363          	bltz	a0,8000555a <sys_chdir+0x68>
    80005518:	e526                	sd	s1,136(sp)
    8000551a:	f6040513          	addi	a0,s0,-160
    8000551e:	893fe0ef          	jal	80003db0 <namei>
    80005522:	84aa                	mv	s1,a0
    80005524:	c915                	beqz	a0,80005558 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005526:	9b0fe0ef          	jal	800036d6 <ilock>
  if(ip->type != T_DIR){
    8000552a:	04449703          	lh	a4,68(s1)
    8000552e:	4785                	li	a5,1
    80005530:	02f71963          	bne	a4,a5,80005562 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005534:	8526                	mv	a0,s1
    80005536:	a4efe0ef          	jal	80003784 <iunlock>
  iput(p->cwd);
    8000553a:	15093503          	ld	a0,336(s2)
    8000553e:	b1afe0ef          	jal	80003858 <iput>
  end_op();
    80005542:	a95fe0ef          	jal	80003fd6 <end_op>
  p->cwd = ip;
    80005546:	14993823          	sd	s1,336(s2)
  return 0;
    8000554a:	4501                	li	a0,0
    8000554c:	64aa                	ld	s1,136(sp)
}
    8000554e:	60ea                	ld	ra,152(sp)
    80005550:	644a                	ld	s0,144(sp)
    80005552:	690a                	ld	s2,128(sp)
    80005554:	610d                	addi	sp,sp,160
    80005556:	8082                	ret
    80005558:	64aa                	ld	s1,136(sp)
    end_op();
    8000555a:	a7dfe0ef          	jal	80003fd6 <end_op>
    return -1;
    8000555e:	557d                	li	a0,-1
    80005560:	b7fd                	j	8000554e <sys_chdir+0x5c>
    iunlockput(ip);
    80005562:	8526                	mv	a0,s1
    80005564:	b7cfe0ef          	jal	800038e0 <iunlockput>
    end_op();
    80005568:	a6ffe0ef          	jal	80003fd6 <end_op>
    return -1;
    8000556c:	557d                	li	a0,-1
    8000556e:	64aa                	ld	s1,136(sp)
    80005570:	bff9                	j	8000554e <sys_chdir+0x5c>

0000000080005572 <sys_exec>:

uint64
sys_exec(void)
{
    80005572:	7121                	addi	sp,sp,-448
    80005574:	ff06                	sd	ra,440(sp)
    80005576:	fb22                	sd	s0,432(sp)
    80005578:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    8000557a:	e4840593          	addi	a1,s0,-440
    8000557e:	4505                	li	a0,1
    80005580:	e50fd0ef          	jal	80002bd0 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005584:	08000613          	li	a2,128
    80005588:	f5040593          	addi	a1,s0,-176
    8000558c:	4501                	li	a0,0
    8000558e:	e5efd0ef          	jal	80002bec <argstr>
    80005592:	87aa                	mv	a5,a0
    return -1;
    80005594:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005596:	0c07c463          	bltz	a5,8000565e <sys_exec+0xec>
    8000559a:	f726                	sd	s1,424(sp)
    8000559c:	f34a                	sd	s2,416(sp)
    8000559e:	ef4e                	sd	s3,408(sp)
    800055a0:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    800055a2:	10000613          	li	a2,256
    800055a6:	4581                	li	a1,0
    800055a8:	e5040513          	addi	a0,s0,-432
    800055ac:	f1cfb0ef          	jal	80000cc8 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800055b0:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    800055b4:	89a6                	mv	s3,s1
    800055b6:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800055b8:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800055bc:	00391513          	slli	a0,s2,0x3
    800055c0:	e4040593          	addi	a1,s0,-448
    800055c4:	e4843783          	ld	a5,-440(s0)
    800055c8:	953e                	add	a0,a0,a5
    800055ca:	d60fd0ef          	jal	80002b2a <fetchaddr>
    800055ce:	02054663          	bltz	a0,800055fa <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    800055d2:	e4043783          	ld	a5,-448(s0)
    800055d6:	c3a9                	beqz	a5,80005618 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800055d8:	d4cfb0ef          	jal	80000b24 <kalloc>
    800055dc:	85aa                	mv	a1,a0
    800055de:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800055e2:	cd01                	beqz	a0,800055fa <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800055e4:	6605                	lui	a2,0x1
    800055e6:	e4043503          	ld	a0,-448(s0)
    800055ea:	d8afd0ef          	jal	80002b74 <fetchstr>
    800055ee:	00054663          	bltz	a0,800055fa <sys_exec+0x88>
    if(i >= NELEM(argv)){
    800055f2:	0905                	addi	s2,s2,1
    800055f4:	09a1                	addi	s3,s3,8
    800055f6:	fd4913e3          	bne	s2,s4,800055bc <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800055fa:	f5040913          	addi	s2,s0,-176
    800055fe:	6088                	ld	a0,0(s1)
    80005600:	c931                	beqz	a0,80005654 <sys_exec+0xe2>
    kfree(argv[i]);
    80005602:	c40fb0ef          	jal	80000a42 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005606:	04a1                	addi	s1,s1,8
    80005608:	ff249be3          	bne	s1,s2,800055fe <sys_exec+0x8c>
  return -1;
    8000560c:	557d                	li	a0,-1
    8000560e:	74ba                	ld	s1,424(sp)
    80005610:	791a                	ld	s2,416(sp)
    80005612:	69fa                	ld	s3,408(sp)
    80005614:	6a5a                	ld	s4,400(sp)
    80005616:	a0a1                	j	8000565e <sys_exec+0xec>
      argv[i] = 0;
    80005618:	0009079b          	sext.w	a5,s2
    8000561c:	078e                	slli	a5,a5,0x3
    8000561e:	fd078793          	addi	a5,a5,-48
    80005622:	97a2                	add	a5,a5,s0
    80005624:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80005628:	e5040593          	addi	a1,s0,-432
    8000562c:	f5040513          	addi	a0,s0,-176
    80005630:	ba8ff0ef          	jal	800049d8 <exec>
    80005634:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005636:	f5040993          	addi	s3,s0,-176
    8000563a:	6088                	ld	a0,0(s1)
    8000563c:	c511                	beqz	a0,80005648 <sys_exec+0xd6>
    kfree(argv[i]);
    8000563e:	c04fb0ef          	jal	80000a42 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005642:	04a1                	addi	s1,s1,8
    80005644:	ff349be3          	bne	s1,s3,8000563a <sys_exec+0xc8>
  return ret;
    80005648:	854a                	mv	a0,s2
    8000564a:	74ba                	ld	s1,424(sp)
    8000564c:	791a                	ld	s2,416(sp)
    8000564e:	69fa                	ld	s3,408(sp)
    80005650:	6a5a                	ld	s4,400(sp)
    80005652:	a031                	j	8000565e <sys_exec+0xec>
  return -1;
    80005654:	557d                	li	a0,-1
    80005656:	74ba                	ld	s1,424(sp)
    80005658:	791a                	ld	s2,416(sp)
    8000565a:	69fa                	ld	s3,408(sp)
    8000565c:	6a5a                	ld	s4,400(sp)
}
    8000565e:	70fa                	ld	ra,440(sp)
    80005660:	745a                	ld	s0,432(sp)
    80005662:	6139                	addi	sp,sp,448
    80005664:	8082                	ret

0000000080005666 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005666:	7139                	addi	sp,sp,-64
    80005668:	fc06                	sd	ra,56(sp)
    8000566a:	f822                	sd	s0,48(sp)
    8000566c:	f426                	sd	s1,40(sp)
    8000566e:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005670:	a92fc0ef          	jal	80001902 <myproc>
    80005674:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005676:	fd840593          	addi	a1,s0,-40
    8000567a:	4501                	li	a0,0
    8000567c:	d54fd0ef          	jal	80002bd0 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005680:	fc840593          	addi	a1,s0,-56
    80005684:	fd040513          	addi	a0,s0,-48
    80005688:	85cff0ef          	jal	800046e4 <pipealloc>
    return -1;
    8000568c:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000568e:	0a054463          	bltz	a0,80005736 <sys_pipe+0xd0>
  fd0 = -1;
    80005692:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005696:	fd043503          	ld	a0,-48(s0)
    8000569a:	f08ff0ef          	jal	80004da2 <fdalloc>
    8000569e:	fca42223          	sw	a0,-60(s0)
    800056a2:	08054163          	bltz	a0,80005724 <sys_pipe+0xbe>
    800056a6:	fc843503          	ld	a0,-56(s0)
    800056aa:	ef8ff0ef          	jal	80004da2 <fdalloc>
    800056ae:	fca42023          	sw	a0,-64(s0)
    800056b2:	06054063          	bltz	a0,80005712 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800056b6:	4691                	li	a3,4
    800056b8:	fc440613          	addi	a2,s0,-60
    800056bc:	fd843583          	ld	a1,-40(s0)
    800056c0:	68a8                	ld	a0,80(s1)
    800056c2:	ebbfb0ef          	jal	8000157c <copyout>
    800056c6:	00054e63          	bltz	a0,800056e2 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800056ca:	4691                	li	a3,4
    800056cc:	fc040613          	addi	a2,s0,-64
    800056d0:	fd843583          	ld	a1,-40(s0)
    800056d4:	0591                	addi	a1,a1,4
    800056d6:	68a8                	ld	a0,80(s1)
    800056d8:	ea5fb0ef          	jal	8000157c <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800056dc:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800056de:	04055c63          	bgez	a0,80005736 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    800056e2:	fc442783          	lw	a5,-60(s0)
    800056e6:	07e9                	addi	a5,a5,26
    800056e8:	078e                	slli	a5,a5,0x3
    800056ea:	97a6                	add	a5,a5,s1
    800056ec:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800056f0:	fc042783          	lw	a5,-64(s0)
    800056f4:	07e9                	addi	a5,a5,26
    800056f6:	078e                	slli	a5,a5,0x3
    800056f8:	94be                	add	s1,s1,a5
    800056fa:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800056fe:	fd043503          	ld	a0,-48(s0)
    80005702:	cd9fe0ef          	jal	800043da <fileclose>
    fileclose(wf);
    80005706:	fc843503          	ld	a0,-56(s0)
    8000570a:	cd1fe0ef          	jal	800043da <fileclose>
    return -1;
    8000570e:	57fd                	li	a5,-1
    80005710:	a01d                	j	80005736 <sys_pipe+0xd0>
    if(fd0 >= 0)
    80005712:	fc442783          	lw	a5,-60(s0)
    80005716:	0007c763          	bltz	a5,80005724 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    8000571a:	07e9                	addi	a5,a5,26
    8000571c:	078e                	slli	a5,a5,0x3
    8000571e:	97a6                	add	a5,a5,s1
    80005720:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005724:	fd043503          	ld	a0,-48(s0)
    80005728:	cb3fe0ef          	jal	800043da <fileclose>
    fileclose(wf);
    8000572c:	fc843503          	ld	a0,-56(s0)
    80005730:	cabfe0ef          	jal	800043da <fileclose>
    return -1;
    80005734:	57fd                	li	a5,-1
}
    80005736:	853e                	mv	a0,a5
    80005738:	70e2                	ld	ra,56(sp)
    8000573a:	7442                	ld	s0,48(sp)
    8000573c:	74a2                	ld	s1,40(sp)
    8000573e:	6121                	addi	sp,sp,64
    80005740:	8082                	ret
	...

0000000080005750 <kernelvec>:
    80005750:	7111                	addi	sp,sp,-256
    80005752:	e006                	sd	ra,0(sp)
    80005754:	e40a                	sd	sp,8(sp)
    80005756:	e80e                	sd	gp,16(sp)
    80005758:	ec12                	sd	tp,24(sp)
    8000575a:	f016                	sd	t0,32(sp)
    8000575c:	f41a                	sd	t1,40(sp)
    8000575e:	f81e                	sd	t2,48(sp)
    80005760:	e4aa                	sd	a0,72(sp)
    80005762:	e8ae                	sd	a1,80(sp)
    80005764:	ecb2                	sd	a2,88(sp)
    80005766:	f0b6                	sd	a3,96(sp)
    80005768:	f4ba                	sd	a4,104(sp)
    8000576a:	f8be                	sd	a5,112(sp)
    8000576c:	fcc2                	sd	a6,120(sp)
    8000576e:	e146                	sd	a7,128(sp)
    80005770:	edf2                	sd	t3,216(sp)
    80005772:	f1f6                	sd	t4,224(sp)
    80005774:	f5fa                	sd	t5,232(sp)
    80005776:	f9fe                	sd	t6,240(sp)
    80005778:	ac2fd0ef          	jal	80002a3a <kerneltrap>
    8000577c:	6082                	ld	ra,0(sp)
    8000577e:	6122                	ld	sp,8(sp)
    80005780:	61c2                	ld	gp,16(sp)
    80005782:	7282                	ld	t0,32(sp)
    80005784:	7322                	ld	t1,40(sp)
    80005786:	73c2                	ld	t2,48(sp)
    80005788:	6526                	ld	a0,72(sp)
    8000578a:	65c6                	ld	a1,80(sp)
    8000578c:	6666                	ld	a2,88(sp)
    8000578e:	7686                	ld	a3,96(sp)
    80005790:	7726                	ld	a4,104(sp)
    80005792:	77c6                	ld	a5,112(sp)
    80005794:	7866                	ld	a6,120(sp)
    80005796:	688a                	ld	a7,128(sp)
    80005798:	6e6e                	ld	t3,216(sp)
    8000579a:	7e8e                	ld	t4,224(sp)
    8000579c:	7f2e                	ld	t5,232(sp)
    8000579e:	7fce                	ld	t6,240(sp)
    800057a0:	6111                	addi	sp,sp,256
    800057a2:	10200073          	sret
	...

00000000800057ae <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800057ae:	1141                	addi	sp,sp,-16
    800057b0:	e422                	sd	s0,8(sp)
    800057b2:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800057b4:	0c0007b7          	lui	a5,0xc000
    800057b8:	4705                	li	a4,1
    800057ba:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800057bc:	0c0007b7          	lui	a5,0xc000
    800057c0:	c3d8                	sw	a4,4(a5)
}
    800057c2:	6422                	ld	s0,8(sp)
    800057c4:	0141                	addi	sp,sp,16
    800057c6:	8082                	ret

00000000800057c8 <plicinithart>:

void
plicinithart(void)
{
    800057c8:	1141                	addi	sp,sp,-16
    800057ca:	e406                	sd	ra,8(sp)
    800057cc:	e022                	sd	s0,0(sp)
    800057ce:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800057d0:	906fc0ef          	jal	800018d6 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800057d4:	0085171b          	slliw	a4,a0,0x8
    800057d8:	0c0027b7          	lui	a5,0xc002
    800057dc:	97ba                	add	a5,a5,a4
    800057de:	40200713          	li	a4,1026
    800057e2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800057e6:	00d5151b          	slliw	a0,a0,0xd
    800057ea:	0c2017b7          	lui	a5,0xc201
    800057ee:	97aa                	add	a5,a5,a0
    800057f0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800057f4:	60a2                	ld	ra,8(sp)
    800057f6:	6402                	ld	s0,0(sp)
    800057f8:	0141                	addi	sp,sp,16
    800057fa:	8082                	ret

00000000800057fc <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800057fc:	1141                	addi	sp,sp,-16
    800057fe:	e406                	sd	ra,8(sp)
    80005800:	e022                	sd	s0,0(sp)
    80005802:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005804:	8d2fc0ef          	jal	800018d6 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005808:	00d5151b          	slliw	a0,a0,0xd
    8000580c:	0c2017b7          	lui	a5,0xc201
    80005810:	97aa                	add	a5,a5,a0
  return irq;
}
    80005812:	43c8                	lw	a0,4(a5)
    80005814:	60a2                	ld	ra,8(sp)
    80005816:	6402                	ld	s0,0(sp)
    80005818:	0141                	addi	sp,sp,16
    8000581a:	8082                	ret

000000008000581c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000581c:	1101                	addi	sp,sp,-32
    8000581e:	ec06                	sd	ra,24(sp)
    80005820:	e822                	sd	s0,16(sp)
    80005822:	e426                	sd	s1,8(sp)
    80005824:	1000                	addi	s0,sp,32
    80005826:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005828:	8aefc0ef          	jal	800018d6 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000582c:	00d5151b          	slliw	a0,a0,0xd
    80005830:	0c2017b7          	lui	a5,0xc201
    80005834:	97aa                	add	a5,a5,a0
    80005836:	c3c4                	sw	s1,4(a5)
}
    80005838:	60e2                	ld	ra,24(sp)
    8000583a:	6442                	ld	s0,16(sp)
    8000583c:	64a2                	ld	s1,8(sp)
    8000583e:	6105                	addi	sp,sp,32
    80005840:	8082                	ret

0000000080005842 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005842:	1141                	addi	sp,sp,-16
    80005844:	e406                	sd	ra,8(sp)
    80005846:	e022                	sd	s0,0(sp)
    80005848:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000584a:	479d                	li	a5,7
    8000584c:	04a7ca63          	blt	a5,a0,800058a0 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005850:	0001d797          	auipc	a5,0x1d
    80005854:	68078793          	addi	a5,a5,1664 # 80022ed0 <disk>
    80005858:	97aa                	add	a5,a5,a0
    8000585a:	0187c783          	lbu	a5,24(a5)
    8000585e:	e7b9                	bnez	a5,800058ac <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005860:	00451693          	slli	a3,a0,0x4
    80005864:	0001d797          	auipc	a5,0x1d
    80005868:	66c78793          	addi	a5,a5,1644 # 80022ed0 <disk>
    8000586c:	6398                	ld	a4,0(a5)
    8000586e:	9736                	add	a4,a4,a3
    80005870:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005874:	6398                	ld	a4,0(a5)
    80005876:	9736                	add	a4,a4,a3
    80005878:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000587c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005880:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005884:	97aa                	add	a5,a5,a0
    80005886:	4705                	li	a4,1
    80005888:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000588c:	0001d517          	auipc	a0,0x1d
    80005890:	65c50513          	addi	a0,a0,1628 # 80022ee8 <disk+0x18>
    80005894:	9cffc0ef          	jal	80002262 <wakeup>
}
    80005898:	60a2                	ld	ra,8(sp)
    8000589a:	6402                	ld	s0,0(sp)
    8000589c:	0141                	addi	sp,sp,16
    8000589e:	8082                	ret
    panic("free_desc 1");
    800058a0:	00002517          	auipc	a0,0x2
    800058a4:	f8050513          	addi	a0,a0,-128 # 80007820 <etext+0x820>
    800058a8:	eedfa0ef          	jal	80000794 <panic>
    panic("free_desc 2");
    800058ac:	00002517          	auipc	a0,0x2
    800058b0:	f8450513          	addi	a0,a0,-124 # 80007830 <etext+0x830>
    800058b4:	ee1fa0ef          	jal	80000794 <panic>

00000000800058b8 <virtio_disk_init>:
{
    800058b8:	1101                	addi	sp,sp,-32
    800058ba:	ec06                	sd	ra,24(sp)
    800058bc:	e822                	sd	s0,16(sp)
    800058be:	e426                	sd	s1,8(sp)
    800058c0:	e04a                	sd	s2,0(sp)
    800058c2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800058c4:	00002597          	auipc	a1,0x2
    800058c8:	f7c58593          	addi	a1,a1,-132 # 80007840 <etext+0x840>
    800058cc:	0001d517          	auipc	a0,0x1d
    800058d0:	72c50513          	addi	a0,a0,1836 # 80022ff8 <disk+0x128>
    800058d4:	aa0fb0ef          	jal	80000b74 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800058d8:	100017b7          	lui	a5,0x10001
    800058dc:	4398                	lw	a4,0(a5)
    800058de:	2701                	sext.w	a4,a4
    800058e0:	747277b7          	lui	a5,0x74727
    800058e4:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800058e8:	18f71063          	bne	a4,a5,80005a68 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800058ec:	100017b7          	lui	a5,0x10001
    800058f0:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    800058f2:	439c                	lw	a5,0(a5)
    800058f4:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800058f6:	4709                	li	a4,2
    800058f8:	16e79863          	bne	a5,a4,80005a68 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800058fc:	100017b7          	lui	a5,0x10001
    80005900:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80005902:	439c                	lw	a5,0(a5)
    80005904:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005906:	16e79163          	bne	a5,a4,80005a68 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000590a:	100017b7          	lui	a5,0x10001
    8000590e:	47d8                	lw	a4,12(a5)
    80005910:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005912:	554d47b7          	lui	a5,0x554d4
    80005916:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000591a:	14f71763          	bne	a4,a5,80005a68 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000591e:	100017b7          	lui	a5,0x10001
    80005922:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005926:	4705                	li	a4,1
    80005928:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000592a:	470d                	li	a4,3
    8000592c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000592e:	10001737          	lui	a4,0x10001
    80005932:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005934:	c7ffe737          	lui	a4,0xc7ffe
    80005938:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdb74f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000593c:	8ef9                	and	a3,a3,a4
    8000593e:	10001737          	lui	a4,0x10001
    80005942:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005944:	472d                	li	a4,11
    80005946:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005948:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    8000594c:	439c                	lw	a5,0(a5)
    8000594e:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005952:	8ba1                	andi	a5,a5,8
    80005954:	12078063          	beqz	a5,80005a74 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005958:	100017b7          	lui	a5,0x10001
    8000595c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005960:	100017b7          	lui	a5,0x10001
    80005964:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80005968:	439c                	lw	a5,0(a5)
    8000596a:	2781                	sext.w	a5,a5
    8000596c:	10079a63          	bnez	a5,80005a80 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005970:	100017b7          	lui	a5,0x10001
    80005974:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80005978:	439c                	lw	a5,0(a5)
    8000597a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000597c:	10078863          	beqz	a5,80005a8c <virtio_disk_init+0x1d4>
  if(max < NUM)
    80005980:	471d                	li	a4,7
    80005982:	10f77b63          	bgeu	a4,a5,80005a98 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80005986:	99efb0ef          	jal	80000b24 <kalloc>
    8000598a:	0001d497          	auipc	s1,0x1d
    8000598e:	54648493          	addi	s1,s1,1350 # 80022ed0 <disk>
    80005992:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005994:	990fb0ef          	jal	80000b24 <kalloc>
    80005998:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000599a:	98afb0ef          	jal	80000b24 <kalloc>
    8000599e:	87aa                	mv	a5,a0
    800059a0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800059a2:	6088                	ld	a0,0(s1)
    800059a4:	10050063          	beqz	a0,80005aa4 <virtio_disk_init+0x1ec>
    800059a8:	0001d717          	auipc	a4,0x1d
    800059ac:	53073703          	ld	a4,1328(a4) # 80022ed8 <disk+0x8>
    800059b0:	0e070a63          	beqz	a4,80005aa4 <virtio_disk_init+0x1ec>
    800059b4:	0e078863          	beqz	a5,80005aa4 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    800059b8:	6605                	lui	a2,0x1
    800059ba:	4581                	li	a1,0
    800059bc:	b0cfb0ef          	jal	80000cc8 <memset>
  memset(disk.avail, 0, PGSIZE);
    800059c0:	0001d497          	auipc	s1,0x1d
    800059c4:	51048493          	addi	s1,s1,1296 # 80022ed0 <disk>
    800059c8:	6605                	lui	a2,0x1
    800059ca:	4581                	li	a1,0
    800059cc:	6488                	ld	a0,8(s1)
    800059ce:	afafb0ef          	jal	80000cc8 <memset>
  memset(disk.used, 0, PGSIZE);
    800059d2:	6605                	lui	a2,0x1
    800059d4:	4581                	li	a1,0
    800059d6:	6888                	ld	a0,16(s1)
    800059d8:	af0fb0ef          	jal	80000cc8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800059dc:	100017b7          	lui	a5,0x10001
    800059e0:	4721                	li	a4,8
    800059e2:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800059e4:	4098                	lw	a4,0(s1)
    800059e6:	100017b7          	lui	a5,0x10001
    800059ea:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800059ee:	40d8                	lw	a4,4(s1)
    800059f0:	100017b7          	lui	a5,0x10001
    800059f4:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800059f8:	649c                	ld	a5,8(s1)
    800059fa:	0007869b          	sext.w	a3,a5
    800059fe:	10001737          	lui	a4,0x10001
    80005a02:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005a06:	9781                	srai	a5,a5,0x20
    80005a08:	10001737          	lui	a4,0x10001
    80005a0c:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005a10:	689c                	ld	a5,16(s1)
    80005a12:	0007869b          	sext.w	a3,a5
    80005a16:	10001737          	lui	a4,0x10001
    80005a1a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005a1e:	9781                	srai	a5,a5,0x20
    80005a20:	10001737          	lui	a4,0x10001
    80005a24:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005a28:	10001737          	lui	a4,0x10001
    80005a2c:	4785                	li	a5,1
    80005a2e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005a30:	00f48c23          	sb	a5,24(s1)
    80005a34:	00f48ca3          	sb	a5,25(s1)
    80005a38:	00f48d23          	sb	a5,26(s1)
    80005a3c:	00f48da3          	sb	a5,27(s1)
    80005a40:	00f48e23          	sb	a5,28(s1)
    80005a44:	00f48ea3          	sb	a5,29(s1)
    80005a48:	00f48f23          	sb	a5,30(s1)
    80005a4c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005a50:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005a54:	100017b7          	lui	a5,0x10001
    80005a58:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    80005a5c:	60e2                	ld	ra,24(sp)
    80005a5e:	6442                	ld	s0,16(sp)
    80005a60:	64a2                	ld	s1,8(sp)
    80005a62:	6902                	ld	s2,0(sp)
    80005a64:	6105                	addi	sp,sp,32
    80005a66:	8082                	ret
    panic("could not find virtio disk");
    80005a68:	00002517          	auipc	a0,0x2
    80005a6c:	de850513          	addi	a0,a0,-536 # 80007850 <etext+0x850>
    80005a70:	d25fa0ef          	jal	80000794 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005a74:	00002517          	auipc	a0,0x2
    80005a78:	dfc50513          	addi	a0,a0,-516 # 80007870 <etext+0x870>
    80005a7c:	d19fa0ef          	jal	80000794 <panic>
    panic("virtio disk should not be ready");
    80005a80:	00002517          	auipc	a0,0x2
    80005a84:	e1050513          	addi	a0,a0,-496 # 80007890 <etext+0x890>
    80005a88:	d0dfa0ef          	jal	80000794 <panic>
    panic("virtio disk has no queue 0");
    80005a8c:	00002517          	auipc	a0,0x2
    80005a90:	e2450513          	addi	a0,a0,-476 # 800078b0 <etext+0x8b0>
    80005a94:	d01fa0ef          	jal	80000794 <panic>
    panic("virtio disk max queue too short");
    80005a98:	00002517          	auipc	a0,0x2
    80005a9c:	e3850513          	addi	a0,a0,-456 # 800078d0 <etext+0x8d0>
    80005aa0:	cf5fa0ef          	jal	80000794 <panic>
    panic("virtio disk kalloc");
    80005aa4:	00002517          	auipc	a0,0x2
    80005aa8:	e4c50513          	addi	a0,a0,-436 # 800078f0 <etext+0x8f0>
    80005aac:	ce9fa0ef          	jal	80000794 <panic>

0000000080005ab0 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005ab0:	7159                	addi	sp,sp,-112
    80005ab2:	f486                	sd	ra,104(sp)
    80005ab4:	f0a2                	sd	s0,96(sp)
    80005ab6:	eca6                	sd	s1,88(sp)
    80005ab8:	e8ca                	sd	s2,80(sp)
    80005aba:	e4ce                	sd	s3,72(sp)
    80005abc:	e0d2                	sd	s4,64(sp)
    80005abe:	fc56                	sd	s5,56(sp)
    80005ac0:	f85a                	sd	s6,48(sp)
    80005ac2:	f45e                	sd	s7,40(sp)
    80005ac4:	f062                	sd	s8,32(sp)
    80005ac6:	ec66                	sd	s9,24(sp)
    80005ac8:	1880                	addi	s0,sp,112
    80005aca:	8a2a                	mv	s4,a0
    80005acc:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005ace:	00c52c83          	lw	s9,12(a0)
    80005ad2:	001c9c9b          	slliw	s9,s9,0x1
    80005ad6:	1c82                	slli	s9,s9,0x20
    80005ad8:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80005adc:	0001d517          	auipc	a0,0x1d
    80005ae0:	51c50513          	addi	a0,a0,1308 # 80022ff8 <disk+0x128>
    80005ae4:	910fb0ef          	jal	80000bf4 <acquire>
  for(int i = 0; i < 3; i++){
    80005ae8:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005aea:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005aec:	0001db17          	auipc	s6,0x1d
    80005af0:	3e4b0b13          	addi	s6,s6,996 # 80022ed0 <disk>
  for(int i = 0; i < 3; i++){
    80005af4:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005af6:	0001dc17          	auipc	s8,0x1d
    80005afa:	502c0c13          	addi	s8,s8,1282 # 80022ff8 <disk+0x128>
    80005afe:	a8b9                	j	80005b5c <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80005b00:	00fb0733          	add	a4,s6,a5
    80005b04:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80005b08:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005b0a:	0207c563          	bltz	a5,80005b34 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    80005b0e:	2905                	addiw	s2,s2,1
    80005b10:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005b12:	05590963          	beq	s2,s5,80005b64 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    80005b16:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005b18:	0001d717          	auipc	a4,0x1d
    80005b1c:	3b870713          	addi	a4,a4,952 # 80022ed0 <disk>
    80005b20:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005b22:	01874683          	lbu	a3,24(a4)
    80005b26:	fee9                	bnez	a3,80005b00 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80005b28:	2785                	addiw	a5,a5,1
    80005b2a:	0705                	addi	a4,a4,1
    80005b2c:	fe979be3          	bne	a5,s1,80005b22 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80005b30:	57fd                	li	a5,-1
    80005b32:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005b34:	01205d63          	blez	s2,80005b4e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005b38:	f9042503          	lw	a0,-112(s0)
    80005b3c:	d07ff0ef          	jal	80005842 <free_desc>
      for(int j = 0; j < i; j++)
    80005b40:	4785                	li	a5,1
    80005b42:	0127d663          	bge	a5,s2,80005b4e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005b46:	f9442503          	lw	a0,-108(s0)
    80005b4a:	cf9ff0ef          	jal	80005842 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005b4e:	85e2                	mv	a1,s8
    80005b50:	0001d517          	auipc	a0,0x1d
    80005b54:	39850513          	addi	a0,a0,920 # 80022ee8 <disk+0x18>
    80005b58:	ebefc0ef          	jal	80002216 <sleep>
  for(int i = 0; i < 3; i++){
    80005b5c:	f9040613          	addi	a2,s0,-112
    80005b60:	894e                	mv	s2,s3
    80005b62:	bf55                	j	80005b16 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005b64:	f9042503          	lw	a0,-112(s0)
    80005b68:	00451693          	slli	a3,a0,0x4

  if(write)
    80005b6c:	0001d797          	auipc	a5,0x1d
    80005b70:	36478793          	addi	a5,a5,868 # 80022ed0 <disk>
    80005b74:	00a50713          	addi	a4,a0,10
    80005b78:	0712                	slli	a4,a4,0x4
    80005b7a:	973e                	add	a4,a4,a5
    80005b7c:	01703633          	snez	a2,s7
    80005b80:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005b82:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005b86:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005b8a:	6398                	ld	a4,0(a5)
    80005b8c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005b8e:	0a868613          	addi	a2,a3,168
    80005b92:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005b94:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005b96:	6390                	ld	a2,0(a5)
    80005b98:	00d605b3          	add	a1,a2,a3
    80005b9c:	4741                	li	a4,16
    80005b9e:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005ba0:	4805                	li	a6,1
    80005ba2:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80005ba6:	f9442703          	lw	a4,-108(s0)
    80005baa:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005bae:	0712                	slli	a4,a4,0x4
    80005bb0:	963a                	add	a2,a2,a4
    80005bb2:	058a0593          	addi	a1,s4,88
    80005bb6:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005bb8:	0007b883          	ld	a7,0(a5)
    80005bbc:	9746                	add	a4,a4,a7
    80005bbe:	40000613          	li	a2,1024
    80005bc2:	c710                	sw	a2,8(a4)
  if(write)
    80005bc4:	001bb613          	seqz	a2,s7
    80005bc8:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005bcc:	00166613          	ori	a2,a2,1
    80005bd0:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005bd4:	f9842583          	lw	a1,-104(s0)
    80005bd8:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005bdc:	00250613          	addi	a2,a0,2
    80005be0:	0612                	slli	a2,a2,0x4
    80005be2:	963e                	add	a2,a2,a5
    80005be4:	577d                	li	a4,-1
    80005be6:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005bea:	0592                	slli	a1,a1,0x4
    80005bec:	98ae                	add	a7,a7,a1
    80005bee:	03068713          	addi	a4,a3,48
    80005bf2:	973e                	add	a4,a4,a5
    80005bf4:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005bf8:	6398                	ld	a4,0(a5)
    80005bfa:	972e                	add	a4,a4,a1
    80005bfc:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005c00:	4689                	li	a3,2
    80005c02:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005c06:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005c0a:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    80005c0e:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005c12:	6794                	ld	a3,8(a5)
    80005c14:	0026d703          	lhu	a4,2(a3)
    80005c18:	8b1d                	andi	a4,a4,7
    80005c1a:	0706                	slli	a4,a4,0x1
    80005c1c:	96ba                	add	a3,a3,a4
    80005c1e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005c22:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005c26:	6798                	ld	a4,8(a5)
    80005c28:	00275783          	lhu	a5,2(a4)
    80005c2c:	2785                	addiw	a5,a5,1
    80005c2e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005c32:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005c36:	100017b7          	lui	a5,0x10001
    80005c3a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005c3e:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80005c42:	0001d917          	auipc	s2,0x1d
    80005c46:	3b690913          	addi	s2,s2,950 # 80022ff8 <disk+0x128>
  while(b->disk == 1) {
    80005c4a:	4485                	li	s1,1
    80005c4c:	01079a63          	bne	a5,a6,80005c60 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005c50:	85ca                	mv	a1,s2
    80005c52:	8552                	mv	a0,s4
    80005c54:	dc2fc0ef          	jal	80002216 <sleep>
  while(b->disk == 1) {
    80005c58:	004a2783          	lw	a5,4(s4)
    80005c5c:	fe978ae3          	beq	a5,s1,80005c50 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005c60:	f9042903          	lw	s2,-112(s0)
    80005c64:	00290713          	addi	a4,s2,2
    80005c68:	0712                	slli	a4,a4,0x4
    80005c6a:	0001d797          	auipc	a5,0x1d
    80005c6e:	26678793          	addi	a5,a5,614 # 80022ed0 <disk>
    80005c72:	97ba                	add	a5,a5,a4
    80005c74:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005c78:	0001d997          	auipc	s3,0x1d
    80005c7c:	25898993          	addi	s3,s3,600 # 80022ed0 <disk>
    80005c80:	00491713          	slli	a4,s2,0x4
    80005c84:	0009b783          	ld	a5,0(s3)
    80005c88:	97ba                	add	a5,a5,a4
    80005c8a:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005c8e:	854a                	mv	a0,s2
    80005c90:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005c94:	bafff0ef          	jal	80005842 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005c98:	8885                	andi	s1,s1,1
    80005c9a:	f0fd                	bnez	s1,80005c80 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005c9c:	0001d517          	auipc	a0,0x1d
    80005ca0:	35c50513          	addi	a0,a0,860 # 80022ff8 <disk+0x128>
    80005ca4:	fe9fa0ef          	jal	80000c8c <release>
}
    80005ca8:	70a6                	ld	ra,104(sp)
    80005caa:	7406                	ld	s0,96(sp)
    80005cac:	64e6                	ld	s1,88(sp)
    80005cae:	6946                	ld	s2,80(sp)
    80005cb0:	69a6                	ld	s3,72(sp)
    80005cb2:	6a06                	ld	s4,64(sp)
    80005cb4:	7ae2                	ld	s5,56(sp)
    80005cb6:	7b42                	ld	s6,48(sp)
    80005cb8:	7ba2                	ld	s7,40(sp)
    80005cba:	7c02                	ld	s8,32(sp)
    80005cbc:	6ce2                	ld	s9,24(sp)
    80005cbe:	6165                	addi	sp,sp,112
    80005cc0:	8082                	ret

0000000080005cc2 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005cc2:	1101                	addi	sp,sp,-32
    80005cc4:	ec06                	sd	ra,24(sp)
    80005cc6:	e822                	sd	s0,16(sp)
    80005cc8:	e426                	sd	s1,8(sp)
    80005cca:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005ccc:	0001d497          	auipc	s1,0x1d
    80005cd0:	20448493          	addi	s1,s1,516 # 80022ed0 <disk>
    80005cd4:	0001d517          	auipc	a0,0x1d
    80005cd8:	32450513          	addi	a0,a0,804 # 80022ff8 <disk+0x128>
    80005cdc:	f19fa0ef          	jal	80000bf4 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005ce0:	100017b7          	lui	a5,0x10001
    80005ce4:	53b8                	lw	a4,96(a5)
    80005ce6:	8b0d                	andi	a4,a4,3
    80005ce8:	100017b7          	lui	a5,0x10001
    80005cec:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    80005cee:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005cf2:	689c                	ld	a5,16(s1)
    80005cf4:	0204d703          	lhu	a4,32(s1)
    80005cf8:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005cfc:	04f70663          	beq	a4,a5,80005d48 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80005d00:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005d04:	6898                	ld	a4,16(s1)
    80005d06:	0204d783          	lhu	a5,32(s1)
    80005d0a:	8b9d                	andi	a5,a5,7
    80005d0c:	078e                	slli	a5,a5,0x3
    80005d0e:	97ba                	add	a5,a5,a4
    80005d10:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005d12:	00278713          	addi	a4,a5,2
    80005d16:	0712                	slli	a4,a4,0x4
    80005d18:	9726                	add	a4,a4,s1
    80005d1a:	01074703          	lbu	a4,16(a4)
    80005d1e:	e321                	bnez	a4,80005d5e <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005d20:	0789                	addi	a5,a5,2
    80005d22:	0792                	slli	a5,a5,0x4
    80005d24:	97a6                	add	a5,a5,s1
    80005d26:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005d28:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005d2c:	d36fc0ef          	jal	80002262 <wakeup>

    disk.used_idx += 1;
    80005d30:	0204d783          	lhu	a5,32(s1)
    80005d34:	2785                	addiw	a5,a5,1
    80005d36:	17c2                	slli	a5,a5,0x30
    80005d38:	93c1                	srli	a5,a5,0x30
    80005d3a:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005d3e:	6898                	ld	a4,16(s1)
    80005d40:	00275703          	lhu	a4,2(a4)
    80005d44:	faf71ee3          	bne	a4,a5,80005d00 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005d48:	0001d517          	auipc	a0,0x1d
    80005d4c:	2b050513          	addi	a0,a0,688 # 80022ff8 <disk+0x128>
    80005d50:	f3dfa0ef          	jal	80000c8c <release>
}
    80005d54:	60e2                	ld	ra,24(sp)
    80005d56:	6442                	ld	s0,16(sp)
    80005d58:	64a2                	ld	s1,8(sp)
    80005d5a:	6105                	addi	sp,sp,32
    80005d5c:	8082                	ret
      panic("virtio_disk_intr status");
    80005d5e:	00002517          	auipc	a0,0x2
    80005d62:	baa50513          	addi	a0,a0,-1110 # 80007908 <etext+0x908>
    80005d66:	a2ffa0ef          	jal	80000794 <panic>
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
