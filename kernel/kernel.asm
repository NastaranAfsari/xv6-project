
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00008117          	auipc	sp,0x8
    80000004:	a9010113          	addi	sp,sp,-1392 # 80007a90 <stack0>
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
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdda3f>
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
    800000fa:	184020ef          	jal	8000227e <either_copyin>
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
    80000158:	93c50513          	addi	a0,a0,-1732 # 8000fa90 <cons>
    8000015c:	299000ef          	jal	80000bf4 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000160:	00010497          	auipc	s1,0x10
    80000164:	93048493          	addi	s1,s1,-1744 # 8000fa90 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000168:	00010917          	auipc	s2,0x10
    8000016c:	9c090913          	addi	s2,s2,-1600 # 8000fb28 <cons+0x98>
  while(n > 0){
    80000170:	0b305d63          	blez	s3,8000022a <consoleread+0xf4>
    while(cons.r == cons.w){
    80000174:	0984a783          	lw	a5,152(s1)
    80000178:	09c4a703          	lw	a4,156(s1)
    8000017c:	0af71263          	bne	a4,a5,80000220 <consoleread+0xea>
      if(killed(myproc())){
    80000180:	78a010ef          	jal	8000190a <myproc>
    80000184:	78d010ef          	jal	80002110 <killed>
    80000188:	e12d                	bnez	a0,800001ea <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    8000018a:	85a6                	mv	a1,s1
    8000018c:	854a                	mv	a0,s2
    8000018e:	54b010ef          	jal	80001ed8 <sleep>
    while(cons.r == cons.w){
    80000192:	0984a783          	lw	a5,152(s1)
    80000196:	09c4a703          	lw	a4,156(s1)
    8000019a:	fef703e3          	beq	a4,a5,80000180 <consoleread+0x4a>
    8000019e:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001a0:	00010717          	auipc	a4,0x10
    800001a4:	8f070713          	addi	a4,a4,-1808 # 8000fa90 <cons>
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
    800001d2:	062020ef          	jal	80002234 <either_copyout>
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
    800001ee:	8a650513          	addi	a0,a0,-1882 # 8000fa90 <cons>
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
    80000218:	90f72a23          	sw	a5,-1772(a4) # 8000fb28 <cons+0x98>
    8000021c:	6be2                	ld	s7,24(sp)
    8000021e:	a031                	j	8000022a <consoleread+0xf4>
    80000220:	ec5e                	sd	s7,24(sp)
    80000222:	bfbd                	j	800001a0 <consoleread+0x6a>
    80000224:	6be2                	ld	s7,24(sp)
    80000226:	a011                	j	8000022a <consoleread+0xf4>
    80000228:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    8000022a:	00010517          	auipc	a0,0x10
    8000022e:	86650513          	addi	a0,a0,-1946 # 8000fa90 <cons>
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
    80000282:	81250513          	addi	a0,a0,-2030 # 8000fa90 <cons>
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
    800002a0:	028020ef          	jal	800022c8 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002a4:	0000f517          	auipc	a0,0xf
    800002a8:	7ec50513          	addi	a0,a0,2028 # 8000fa90 <cons>
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
    800002c2:	0000f717          	auipc	a4,0xf
    800002c6:	7ce70713          	addi	a4,a4,1998 # 8000fa90 <cons>
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
    800002ec:	7a878793          	addi	a5,a5,1960 # 8000fa90 <cons>
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
    8000031a:	8127a783          	lw	a5,-2030(a5) # 8000fb28 <cons+0x98>
    8000031e:	9f1d                	subw	a4,a4,a5
    80000320:	08000793          	li	a5,128
    80000324:	f8f710e3          	bne	a4,a5,800002a4 <consoleintr+0x32>
    80000328:	a07d                	j	800003d6 <consoleintr+0x164>
    8000032a:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    8000032c:	0000f717          	auipc	a4,0xf
    80000330:	76470713          	addi	a4,a4,1892 # 8000fa90 <cons>
    80000334:	0a072783          	lw	a5,160(a4)
    80000338:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000033c:	0000f497          	auipc	s1,0xf
    80000340:	75448493          	addi	s1,s1,1876 # 8000fa90 <cons>
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
    80000382:	71270713          	addi	a4,a4,1810 # 8000fa90 <cons>
    80000386:	0a072783          	lw	a5,160(a4)
    8000038a:	09c72703          	lw	a4,156(a4)
    8000038e:	f0f70be3          	beq	a4,a5,800002a4 <consoleintr+0x32>
      cons.e--;
    80000392:	37fd                	addiw	a5,a5,-1
    80000394:	0000f717          	auipc	a4,0xf
    80000398:	78f72e23          	sw	a5,1948(a4) # 8000fb30 <cons+0xa0>
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
    800003b6:	6de78793          	addi	a5,a5,1758 # 8000fa90 <cons>
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
    800003da:	74c7ab23          	sw	a2,1878(a5) # 8000fb2c <cons+0x9c>
        wakeup(&cons.r);
    800003de:	0000f517          	auipc	a0,0xf
    800003e2:	74a50513          	addi	a0,a0,1866 # 8000fb28 <cons+0x98>
    800003e6:	33f010ef          	jal	80001f24 <wakeup>
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
    80000400:	69450513          	addi	a0,a0,1684 # 8000fa90 <cons>
    80000404:	770000ef          	jal	80000b74 <initlock>

  uartinit();
    80000408:	3f4000ef          	jal	800007fc <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000040c:	00020797          	auipc	a5,0x20
    80000410:	81c78793          	addi	a5,a5,-2020 # 8001fc28 <devsw>
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
    8000044a:	49a60613          	addi	a2,a2,1178 # 800078e0 <digits>
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
    800004e4:	6707a783          	lw	a5,1648(a5) # 8000fb50 <pr+0x18>
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
    80000530:	60c50513          	addi	a0,a0,1548 # 8000fb38 <pr>
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
    800006f0:	1f4b8b93          	addi	s7,s7,500 # 800078e0 <digits>
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
    8000078a:	3b250513          	addi	a0,a0,946 # 8000fb38 <pr>
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
    800007a4:	3a07a823          	sw	zero,944(a5) # 8000fb50 <pr+0x18>
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
    800007c8:	28f72623          	sw	a5,652(a4) # 80007a50 <panicked>
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
    800007dc:	36048493          	addi	s1,s1,864 # 8000fb38 <pr>
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
    80000844:	31850513          	addi	a0,a0,792 # 8000fb58 <uart_tx_lock>
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
    80000868:	1ec7a783          	lw	a5,492(a5) # 80007a50 <panicked>
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
    8000089e:	1be7b783          	ld	a5,446(a5) # 80007a58 <uart_tx_r>
    800008a2:	00007717          	auipc	a4,0x7
    800008a6:	1be73703          	ld	a4,446(a4) # 80007a60 <uart_tx_w>
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
    800008cc:	290a8a93          	addi	s5,s5,656 # 8000fb58 <uart_tx_lock>
    uart_tx_r += 1;
    800008d0:	00007497          	auipc	s1,0x7
    800008d4:	18848493          	addi	s1,s1,392 # 80007a58 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008d8:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008dc:	00007997          	auipc	s3,0x7
    800008e0:	18498993          	addi	s3,s3,388 # 80007a60 <uart_tx_w>
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
    800008fe:	626010ef          	jal	80001f24 <wakeup>
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
    80000950:	20c50513          	addi	a0,a0,524 # 8000fb58 <uart_tx_lock>
    80000954:	2a0000ef          	jal	80000bf4 <acquire>
  if(panicked){
    80000958:	00007797          	auipc	a5,0x7
    8000095c:	0f87a783          	lw	a5,248(a5) # 80007a50 <panicked>
    80000960:	efbd                	bnez	a5,800009de <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000962:	00007717          	auipc	a4,0x7
    80000966:	0fe73703          	ld	a4,254(a4) # 80007a60 <uart_tx_w>
    8000096a:	00007797          	auipc	a5,0x7
    8000096e:	0ee7b783          	ld	a5,238(a5) # 80007a58 <uart_tx_r>
    80000972:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000976:	0000f997          	auipc	s3,0xf
    8000097a:	1e298993          	addi	s3,s3,482 # 8000fb58 <uart_tx_lock>
    8000097e:	00007497          	auipc	s1,0x7
    80000982:	0da48493          	addi	s1,s1,218 # 80007a58 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000986:	00007917          	auipc	s2,0x7
    8000098a:	0da90913          	addi	s2,s2,218 # 80007a60 <uart_tx_w>
    8000098e:	00e79d63          	bne	a5,a4,800009a8 <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000992:	85ce                	mv	a1,s3
    80000994:	8526                	mv	a0,s1
    80000996:	542010ef          	jal	80001ed8 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000099a:	00093703          	ld	a4,0(s2)
    8000099e:	609c                	ld	a5,0(s1)
    800009a0:	02078793          	addi	a5,a5,32
    800009a4:	fee787e3          	beq	a5,a4,80000992 <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800009a8:	0000f497          	auipc	s1,0xf
    800009ac:	1b048493          	addi	s1,s1,432 # 8000fb58 <uart_tx_lock>
    800009b0:	01f77793          	andi	a5,a4,31
    800009b4:	97a6                	add	a5,a5,s1
    800009b6:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009ba:	0705                	addi	a4,a4,1
    800009bc:	00007797          	auipc	a5,0x7
    800009c0:	0ae7b223          	sd	a4,164(a5) # 80007a60 <uart_tx_w>
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
    80000a24:	13848493          	addi	s1,s1,312 # 8000fb58 <uart_tx_lock>
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
    80000a56:	00020797          	auipc	a5,0x20
    80000a5a:	36a78793          	addi	a5,a5,874 # 80020dc0 <end>
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
    80000a76:	11e90913          	addi	s2,s2,286 # 8000fb90 <kmem>
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
    80000b04:	09050513          	addi	a0,a0,144 # 8000fb90 <kmem>
    80000b08:	06c000ef          	jal	80000b74 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b0c:	45c5                	li	a1,17
    80000b0e:	05ee                	slli	a1,a1,0x1b
    80000b10:	00020517          	auipc	a0,0x20
    80000b14:	2b050513          	addi	a0,a0,688 # 80020dc0 <end>
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
    80000b32:	06248493          	addi	s1,s1,98 # 8000fb90 <kmem>
    80000b36:	8526                	mv	a0,s1
    80000b38:	0bc000ef          	jal	80000bf4 <acquire>
  r = kmem.freelist;
    80000b3c:	6c84                	ld	s1,24(s1)
  if(r)
    80000b3e:	c485                	beqz	s1,80000b66 <kalloc+0x42>
    kmem.freelist = r->next;
    80000b40:	609c                	ld	a5,0(s1)
    80000b42:	0000f517          	auipc	a0,0xf
    80000b46:	04e50513          	addi	a0,a0,78 # 8000fb90 <kmem>
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
    80000b6a:	02a50513          	addi	a0,a0,42 # 8000fb90 <kmem>
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
    80000b9e:	551000ef          	jal	800018ee <mycpu>
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
    80000bcc:	523000ef          	jal	800018ee <mycpu>
    80000bd0:	5d3c                	lw	a5,120(a0)
    80000bd2:	cb99                	beqz	a5,80000be8 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bd4:	51b000ef          	jal	800018ee <mycpu>
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
    80000be8:	507000ef          	jal	800018ee <mycpu>
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
    80000c1c:	4d3000ef          	jal	800018ee <mycpu>
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
    80000c40:	4af000ef          	jal	800018ee <mycpu>
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
    80000d3c:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffde241>
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
    80000e6a:	275000ef          	jal	800018de <cpuid>
     log_message(ERROR, "This is a test error message for the custom logger");
     
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e6e:	00007717          	auipc	a4,0x7
    80000e72:	bfa70713          	addi	a4,a4,-1030 # 80007a68 <started>
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
    80000e82:	25d000ef          	jal	800018de <cpuid>
    80000e86:	85aa                	mv	a1,a0
    80000e88:	00006517          	auipc	a0,0x6
    80000e8c:	30850513          	addi	a0,a0,776 # 80007190 <etext+0x190>
    80000e90:	e32ff0ef          	jal	800004c2 <printf>
    kvminithart();    // turn on paging
    80000e94:	0aa000ef          	jal	80000f3e <kvminithart>
    trapinithart();   // install kernel trap vector
    80000e98:	562010ef          	jal	800023fa <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e9c:	45c040ef          	jal	800052f8 <plicinithart>
  }

  scheduler();        
    80000ea0:	69f000ef          	jal	80001d3e <scheduler>
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
    80000edc:	14d000ef          	jal	80001828 <procinit>
    trapinit();      // trap vectors
    80000ee0:	4f6010ef          	jal	800023d6 <trapinit>
    trapinithart();  // install kernel trap vector
    80000ee4:	516010ef          	jal	800023fa <trapinithart>
    plicinit();      // set up interrupt controller
    80000ee8:	3f6040ef          	jal	800052de <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000eec:	40c040ef          	jal	800052f8 <plicinithart>
    binit();         // buffer cache
    80000ef0:	35b010ef          	jal	80002a4a <binit>
    iinit();         // inode table
    80000ef4:	14c020ef          	jal	80003040 <iinit>
    fileinit();      // file table
    80000ef8:	74d020ef          	jal	80003e44 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000efc:	4ec040ef          	jal	800053e8 <virtio_disk_init>
    userinit();      // first user process
    80000f00:	473000ef          	jal	80001b72 <userinit>
     log_message(INFO, "Welcome to AUT MCS Principles of Operating Systems Course. This message is from a custom logger implemented by 40212004 and 40213035");
    80000f04:	00006597          	auipc	a1,0x6
    80000f08:	19458593          	addi	a1,a1,404 # 80007098 <etext+0x98>
    80000f0c:	4501                	li	a0,0
    80000f0e:	5e5020ef          	jal	80003cf2 <log_message>
     log_message(WARN, "This is a test warning message for the custom logger");
    80000f12:	00006597          	auipc	a1,0x6
    80000f16:	20e58593          	addi	a1,a1,526 # 80007120 <etext+0x120>
    80000f1a:	4505                	li	a0,1
    80000f1c:	5d7020ef          	jal	80003cf2 <log_message>
     log_message(ERROR, "This is a test error message for the custom logger");
    80000f20:	00006597          	auipc	a1,0x6
    80000f24:	23858593          	addi	a1,a1,568 # 80007158 <etext+0x158>
    80000f28:	4509                	li	a0,2
    80000f2a:	5c9020ef          	jal	80003cf2 <log_message>
    __sync_synchronize();
    80000f2e:	0ff0000f          	fence
    started = 1;
    80000f32:	4785                	li	a5,1
    80000f34:	00007717          	auipc	a4,0x7
    80000f38:	b2f72a23          	sw	a5,-1228(a4) # 80007a68 <started>
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
    80000f4c:	b287b783          	ld	a5,-1240(a5) # 80007a70 <kernel_pagetable>
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
    80000fba:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffde237>
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
    800011d8:	88a7be23          	sd	a0,-1892(a5) # 80007a70 <kernel_pagetable>
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
    800017aa:	83a48493          	addi	s1,s1,-1990 # 8000ffe0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    800017ae:	8b26                	mv	s6,s1
    800017b0:	04fa5937          	lui	s2,0x4fa5
    800017b4:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    800017b8:	0932                	slli	s2,s2,0xc
    800017ba:	fa590913          	addi	s2,s2,-91
    800017be:	0932                	slli	s2,s2,0xc
    800017c0:	fa590913          	addi	s2,s2,-91
    800017c4:	0932                	slli	s2,s2,0xc
    800017c6:	fa590913          	addi	s2,s2,-91
    800017ca:	040009b7          	lui	s3,0x4000
    800017ce:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800017d0:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800017d2:	00014a97          	auipc	s5,0x14
    800017d6:	20ea8a93          	addi	s5,s5,526 # 800159e0 <tickslock>
    char *pa = kalloc();
    800017da:	b4aff0ef          	jal	80000b24 <kalloc>
    800017de:	862a                	mv	a2,a0
    if(pa == 0)
    800017e0:	cd15                	beqz	a0,8000181c <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int) (p - proc));
    800017e2:	416485b3          	sub	a1,s1,s6
    800017e6:	858d                	srai	a1,a1,0x3
    800017e8:	032585b3          	mul	a1,a1,s2
    800017ec:	2585                	addiw	a1,a1,1
    800017ee:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017f2:	4719                	li	a4,6
    800017f4:	6685                	lui	a3,0x1
    800017f6:	40b985b3          	sub	a1,s3,a1
    800017fa:	8552                	mv	a0,s4
    800017fc:	8f3ff0ef          	jal	800010ee <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001800:	16848493          	addi	s1,s1,360
    80001804:	fd549be3          	bne	s1,s5,800017da <proc_mapstacks+0x4a>
  }
}
    80001808:	70e2                	ld	ra,56(sp)
    8000180a:	7442                	ld	s0,48(sp)
    8000180c:	74a2                	ld	s1,40(sp)
    8000180e:	7902                	ld	s2,32(sp)
    80001810:	69e2                	ld	s3,24(sp)
    80001812:	6a42                	ld	s4,16(sp)
    80001814:	6aa2                	ld	s5,8(sp)
    80001816:	6b02                	ld	s6,0(sp)
    80001818:	6121                	addi	sp,sp,64
    8000181a:	8082                	ret
      panic("kalloc");
    8000181c:	00006517          	auipc	a0,0x6
    80001820:	ad450513          	addi	a0,a0,-1324 # 800072f0 <etext+0x2f0>
    80001824:	f71fe0ef          	jal	80000794 <panic>

0000000080001828 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80001828:	7139                	addi	sp,sp,-64
    8000182a:	fc06                	sd	ra,56(sp)
    8000182c:	f822                	sd	s0,48(sp)
    8000182e:	f426                	sd	s1,40(sp)
    80001830:	f04a                	sd	s2,32(sp)
    80001832:	ec4e                	sd	s3,24(sp)
    80001834:	e852                	sd	s4,16(sp)
    80001836:	e456                	sd	s5,8(sp)
    80001838:	e05a                	sd	s6,0(sp)
    8000183a:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    8000183c:	00006597          	auipc	a1,0x6
    80001840:	abc58593          	addi	a1,a1,-1348 # 800072f8 <etext+0x2f8>
    80001844:	0000e517          	auipc	a0,0xe
    80001848:	36c50513          	addi	a0,a0,876 # 8000fbb0 <pid_lock>
    8000184c:	b28ff0ef          	jal	80000b74 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001850:	00006597          	auipc	a1,0x6
    80001854:	ab058593          	addi	a1,a1,-1360 # 80007300 <etext+0x300>
    80001858:	0000e517          	auipc	a0,0xe
    8000185c:	37050513          	addi	a0,a0,880 # 8000fbc8 <wait_lock>
    80001860:	b14ff0ef          	jal	80000b74 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001864:	0000e497          	auipc	s1,0xe
    80001868:	77c48493          	addi	s1,s1,1916 # 8000ffe0 <proc>
      initlock(&p->lock, "proc");
    8000186c:	00006b17          	auipc	s6,0x6
    80001870:	aa4b0b13          	addi	s6,s6,-1372 # 80007310 <etext+0x310>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001874:	8aa6                	mv	s5,s1
    80001876:	04fa5937          	lui	s2,0x4fa5
    8000187a:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    8000187e:	0932                	slli	s2,s2,0xc
    80001880:	fa590913          	addi	s2,s2,-91
    80001884:	0932                	slli	s2,s2,0xc
    80001886:	fa590913          	addi	s2,s2,-91
    8000188a:	0932                	slli	s2,s2,0xc
    8000188c:	fa590913          	addi	s2,s2,-91
    80001890:	040009b7          	lui	s3,0x4000
    80001894:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001896:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001898:	00014a17          	auipc	s4,0x14
    8000189c:	148a0a13          	addi	s4,s4,328 # 800159e0 <tickslock>
      initlock(&p->lock, "proc");
    800018a0:	85da                	mv	a1,s6
    800018a2:	8526                	mv	a0,s1
    800018a4:	ad0ff0ef          	jal	80000b74 <initlock>
      p->state = UNUSED;
    800018a8:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    800018ac:	415487b3          	sub	a5,s1,s5
    800018b0:	878d                	srai	a5,a5,0x3
    800018b2:	032787b3          	mul	a5,a5,s2
    800018b6:	2785                	addiw	a5,a5,1
    800018b8:	00d7979b          	slliw	a5,a5,0xd
    800018bc:	40f987b3          	sub	a5,s3,a5
    800018c0:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    800018c2:	16848493          	addi	s1,s1,360
    800018c6:	fd449de3          	bne	s1,s4,800018a0 <procinit+0x78>
  }
}
    800018ca:	70e2                	ld	ra,56(sp)
    800018cc:	7442                	ld	s0,48(sp)
    800018ce:	74a2                	ld	s1,40(sp)
    800018d0:	7902                	ld	s2,32(sp)
    800018d2:	69e2                	ld	s3,24(sp)
    800018d4:	6a42                	ld	s4,16(sp)
    800018d6:	6aa2                	ld	s5,8(sp)
    800018d8:	6b02                	ld	s6,0(sp)
    800018da:	6121                	addi	sp,sp,64
    800018dc:	8082                	ret

00000000800018de <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800018de:	1141                	addi	sp,sp,-16
    800018e0:	e422                	sd	s0,8(sp)
    800018e2:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800018e4:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800018e6:	2501                	sext.w	a0,a0
    800018e8:	6422                	ld	s0,8(sp)
    800018ea:	0141                	addi	sp,sp,16
    800018ec:	8082                	ret

00000000800018ee <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800018ee:	1141                	addi	sp,sp,-16
    800018f0:	e422                	sd	s0,8(sp)
    800018f2:	0800                	addi	s0,sp,16
    800018f4:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800018f6:	2781                	sext.w	a5,a5
    800018f8:	079e                	slli	a5,a5,0x7
  return c;
}
    800018fa:	0000e517          	auipc	a0,0xe
    800018fe:	2e650513          	addi	a0,a0,742 # 8000fbe0 <cpus>
    80001902:	953e                	add	a0,a0,a5
    80001904:	6422                	ld	s0,8(sp)
    80001906:	0141                	addi	sp,sp,16
    80001908:	8082                	ret

000000008000190a <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    8000190a:	1101                	addi	sp,sp,-32
    8000190c:	ec06                	sd	ra,24(sp)
    8000190e:	e822                	sd	s0,16(sp)
    80001910:	e426                	sd	s1,8(sp)
    80001912:	1000                	addi	s0,sp,32
  push_off();
    80001914:	aa0ff0ef          	jal	80000bb4 <push_off>
    80001918:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    8000191a:	2781                	sext.w	a5,a5
    8000191c:	079e                	slli	a5,a5,0x7
    8000191e:	0000e717          	auipc	a4,0xe
    80001922:	29270713          	addi	a4,a4,658 # 8000fbb0 <pid_lock>
    80001926:	97ba                	add	a5,a5,a4
    80001928:	7b84                	ld	s1,48(a5)
  pop_off();
    8000192a:	b0eff0ef          	jal	80000c38 <pop_off>
  return p;
}
    8000192e:	8526                	mv	a0,s1
    80001930:	60e2                	ld	ra,24(sp)
    80001932:	6442                	ld	s0,16(sp)
    80001934:	64a2                	ld	s1,8(sp)
    80001936:	6105                	addi	sp,sp,32
    80001938:	8082                	ret

000000008000193a <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    8000193a:	1141                	addi	sp,sp,-16
    8000193c:	e406                	sd	ra,8(sp)
    8000193e:	e022                	sd	s0,0(sp)
    80001940:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001942:	fc9ff0ef          	jal	8000190a <myproc>
    80001946:	b46ff0ef          	jal	80000c8c <release>

  if (first) {
    8000194a:	00006797          	auipc	a5,0x6
    8000194e:	0b67a783          	lw	a5,182(a5) # 80007a00 <first.1>
    80001952:	e799                	bnez	a5,80001960 <forkret+0x26>
    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
    80001954:	2bf000ef          	jal	80002412 <usertrapret>
}
    80001958:	60a2                	ld	ra,8(sp)
    8000195a:	6402                	ld	s0,0(sp)
    8000195c:	0141                	addi	sp,sp,16
    8000195e:	8082                	ret
    fsinit(ROOTDEV);
    80001960:	4505                	li	a0,1
    80001962:	672010ef          	jal	80002fd4 <fsinit>
    first = 0;
    80001966:	00006797          	auipc	a5,0x6
    8000196a:	0807ad23          	sw	zero,154(a5) # 80007a00 <first.1>
    __sync_synchronize();
    8000196e:	0ff0000f          	fence
    80001972:	b7cd                	j	80001954 <forkret+0x1a>

0000000080001974 <allocpid>:
{
    80001974:	1101                	addi	sp,sp,-32
    80001976:	ec06                	sd	ra,24(sp)
    80001978:	e822                	sd	s0,16(sp)
    8000197a:	e426                	sd	s1,8(sp)
    8000197c:	e04a                	sd	s2,0(sp)
    8000197e:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001980:	0000e917          	auipc	s2,0xe
    80001984:	23090913          	addi	s2,s2,560 # 8000fbb0 <pid_lock>
    80001988:	854a                	mv	a0,s2
    8000198a:	a6aff0ef          	jal	80000bf4 <acquire>
  pid = nextpid;
    8000198e:	00006797          	auipc	a5,0x6
    80001992:	07678793          	addi	a5,a5,118 # 80007a04 <nextpid>
    80001996:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001998:	0014871b          	addiw	a4,s1,1
    8000199c:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    8000199e:	854a                	mv	a0,s2
    800019a0:	aecff0ef          	jal	80000c8c <release>
}
    800019a4:	8526                	mv	a0,s1
    800019a6:	60e2                	ld	ra,24(sp)
    800019a8:	6442                	ld	s0,16(sp)
    800019aa:	64a2                	ld	s1,8(sp)
    800019ac:	6902                	ld	s2,0(sp)
    800019ae:	6105                	addi	sp,sp,32
    800019b0:	8082                	ret

00000000800019b2 <proc_pagetable>:
{
    800019b2:	1101                	addi	sp,sp,-32
    800019b4:	ec06                	sd	ra,24(sp)
    800019b6:	e822                	sd	s0,16(sp)
    800019b8:	e426                	sd	s1,8(sp)
    800019ba:	e04a                	sd	s2,0(sp)
    800019bc:	1000                	addi	s0,sp,32
    800019be:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    800019c0:	8e1ff0ef          	jal	800012a0 <uvmcreate>
    800019c4:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800019c6:	cd05                	beqz	a0,800019fe <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    800019c8:	4729                	li	a4,10
    800019ca:	00004697          	auipc	a3,0x4
    800019ce:	63668693          	addi	a3,a3,1590 # 80006000 <_trampoline>
    800019d2:	6605                	lui	a2,0x1
    800019d4:	040005b7          	lui	a1,0x4000
    800019d8:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019da:	05b2                	slli	a1,a1,0xc
    800019dc:	e62ff0ef          	jal	8000103e <mappages>
    800019e0:	02054663          	bltz	a0,80001a0c <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    800019e4:	4719                	li	a4,6
    800019e6:	05893683          	ld	a3,88(s2)
    800019ea:	6605                	lui	a2,0x1
    800019ec:	020005b7          	lui	a1,0x2000
    800019f0:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    800019f2:	05b6                	slli	a1,a1,0xd
    800019f4:	8526                	mv	a0,s1
    800019f6:	e48ff0ef          	jal	8000103e <mappages>
    800019fa:	00054f63          	bltz	a0,80001a18 <proc_pagetable+0x66>
}
    800019fe:	8526                	mv	a0,s1
    80001a00:	60e2                	ld	ra,24(sp)
    80001a02:	6442                	ld	s0,16(sp)
    80001a04:	64a2                	ld	s1,8(sp)
    80001a06:	6902                	ld	s2,0(sp)
    80001a08:	6105                	addi	sp,sp,32
    80001a0a:	8082                	ret
    uvmfree(pagetable, 0);
    80001a0c:	4581                	li	a1,0
    80001a0e:	8526                	mv	a0,s1
    80001a10:	a5fff0ef          	jal	8000146e <uvmfree>
    return 0;
    80001a14:	4481                	li	s1,0
    80001a16:	b7e5                	j	800019fe <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a18:	4681                	li	a3,0
    80001a1a:	4605                	li	a2,1
    80001a1c:	040005b7          	lui	a1,0x4000
    80001a20:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a22:	05b2                	slli	a1,a1,0xc
    80001a24:	8526                	mv	a0,s1
    80001a26:	fbeff0ef          	jal	800011e4 <uvmunmap>
    uvmfree(pagetable, 0);
    80001a2a:	4581                	li	a1,0
    80001a2c:	8526                	mv	a0,s1
    80001a2e:	a41ff0ef          	jal	8000146e <uvmfree>
    return 0;
    80001a32:	4481                	li	s1,0
    80001a34:	b7e9                	j	800019fe <proc_pagetable+0x4c>

0000000080001a36 <proc_freepagetable>:
{
    80001a36:	1101                	addi	sp,sp,-32
    80001a38:	ec06                	sd	ra,24(sp)
    80001a3a:	e822                	sd	s0,16(sp)
    80001a3c:	e426                	sd	s1,8(sp)
    80001a3e:	e04a                	sd	s2,0(sp)
    80001a40:	1000                	addi	s0,sp,32
    80001a42:	84aa                	mv	s1,a0
    80001a44:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a46:	4681                	li	a3,0
    80001a48:	4605                	li	a2,1
    80001a4a:	040005b7          	lui	a1,0x4000
    80001a4e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a50:	05b2                	slli	a1,a1,0xc
    80001a52:	f92ff0ef          	jal	800011e4 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001a56:	4681                	li	a3,0
    80001a58:	4605                	li	a2,1
    80001a5a:	020005b7          	lui	a1,0x2000
    80001a5e:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a60:	05b6                	slli	a1,a1,0xd
    80001a62:	8526                	mv	a0,s1
    80001a64:	f80ff0ef          	jal	800011e4 <uvmunmap>
  uvmfree(pagetable, sz);
    80001a68:	85ca                	mv	a1,s2
    80001a6a:	8526                	mv	a0,s1
    80001a6c:	a03ff0ef          	jal	8000146e <uvmfree>
}
    80001a70:	60e2                	ld	ra,24(sp)
    80001a72:	6442                	ld	s0,16(sp)
    80001a74:	64a2                	ld	s1,8(sp)
    80001a76:	6902                	ld	s2,0(sp)
    80001a78:	6105                	addi	sp,sp,32
    80001a7a:	8082                	ret

0000000080001a7c <freeproc>:
{
    80001a7c:	1101                	addi	sp,sp,-32
    80001a7e:	ec06                	sd	ra,24(sp)
    80001a80:	e822                	sd	s0,16(sp)
    80001a82:	e426                	sd	s1,8(sp)
    80001a84:	1000                	addi	s0,sp,32
    80001a86:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001a88:	6d28                	ld	a0,88(a0)
    80001a8a:	c119                	beqz	a0,80001a90 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001a8c:	fb7fe0ef          	jal	80000a42 <kfree>
  p->trapframe = 0;
    80001a90:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001a94:	68a8                	ld	a0,80(s1)
    80001a96:	c501                	beqz	a0,80001a9e <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001a98:	64ac                	ld	a1,72(s1)
    80001a9a:	f9dff0ef          	jal	80001a36 <proc_freepagetable>
  p->pagetable = 0;
    80001a9e:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001aa2:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001aa6:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001aaa:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001aae:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001ab2:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001ab6:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001aba:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001abe:	0004ac23          	sw	zero,24(s1)
}
    80001ac2:	60e2                	ld	ra,24(sp)
    80001ac4:	6442                	ld	s0,16(sp)
    80001ac6:	64a2                	ld	s1,8(sp)
    80001ac8:	6105                	addi	sp,sp,32
    80001aca:	8082                	ret

0000000080001acc <allocproc>:
{
    80001acc:	1101                	addi	sp,sp,-32
    80001ace:	ec06                	sd	ra,24(sp)
    80001ad0:	e822                	sd	s0,16(sp)
    80001ad2:	e426                	sd	s1,8(sp)
    80001ad4:	e04a                	sd	s2,0(sp)
    80001ad6:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ad8:	0000e497          	auipc	s1,0xe
    80001adc:	50848493          	addi	s1,s1,1288 # 8000ffe0 <proc>
    80001ae0:	00014917          	auipc	s2,0x14
    80001ae4:	f0090913          	addi	s2,s2,-256 # 800159e0 <tickslock>
    acquire(&p->lock);
    80001ae8:	8526                	mv	a0,s1
    80001aea:	90aff0ef          	jal	80000bf4 <acquire>
    if(p->state == UNUSED) {
    80001aee:	4c9c                	lw	a5,24(s1)
    80001af0:	cb91                	beqz	a5,80001b04 <allocproc+0x38>
      release(&p->lock);
    80001af2:	8526                	mv	a0,s1
    80001af4:	998ff0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001af8:	16848493          	addi	s1,s1,360
    80001afc:	ff2496e3          	bne	s1,s2,80001ae8 <allocproc+0x1c>
  return 0;
    80001b00:	4481                	li	s1,0
    80001b02:	a089                	j	80001b44 <allocproc+0x78>
  p->pid = allocpid();
    80001b04:	e71ff0ef          	jal	80001974 <allocpid>
    80001b08:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001b0a:	4785                	li	a5,1
    80001b0c:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001b0e:	816ff0ef          	jal	80000b24 <kalloc>
    80001b12:	892a                	mv	s2,a0
    80001b14:	eca8                	sd	a0,88(s1)
    80001b16:	cd15                	beqz	a0,80001b52 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001b18:	8526                	mv	a0,s1
    80001b1a:	e99ff0ef          	jal	800019b2 <proc_pagetable>
    80001b1e:	892a                	mv	s2,a0
    80001b20:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001b22:	c121                	beqz	a0,80001b62 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001b24:	07000613          	li	a2,112
    80001b28:	4581                	li	a1,0
    80001b2a:	06048513          	addi	a0,s1,96
    80001b2e:	99aff0ef          	jal	80000cc8 <memset>
  p->context.ra = (uint64)forkret;
    80001b32:	00000797          	auipc	a5,0x0
    80001b36:	e0878793          	addi	a5,a5,-504 # 8000193a <forkret>
    80001b3a:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001b3c:	60bc                	ld	a5,64(s1)
    80001b3e:	6705                	lui	a4,0x1
    80001b40:	97ba                	add	a5,a5,a4
    80001b42:	f4bc                	sd	a5,104(s1)
}
    80001b44:	8526                	mv	a0,s1
    80001b46:	60e2                	ld	ra,24(sp)
    80001b48:	6442                	ld	s0,16(sp)
    80001b4a:	64a2                	ld	s1,8(sp)
    80001b4c:	6902                	ld	s2,0(sp)
    80001b4e:	6105                	addi	sp,sp,32
    80001b50:	8082                	ret
    freeproc(p);
    80001b52:	8526                	mv	a0,s1
    80001b54:	f29ff0ef          	jal	80001a7c <freeproc>
    release(&p->lock);
    80001b58:	8526                	mv	a0,s1
    80001b5a:	932ff0ef          	jal	80000c8c <release>
    return 0;
    80001b5e:	84ca                	mv	s1,s2
    80001b60:	b7d5                	j	80001b44 <allocproc+0x78>
    freeproc(p);
    80001b62:	8526                	mv	a0,s1
    80001b64:	f19ff0ef          	jal	80001a7c <freeproc>
    release(&p->lock);
    80001b68:	8526                	mv	a0,s1
    80001b6a:	922ff0ef          	jal	80000c8c <release>
    return 0;
    80001b6e:	84ca                	mv	s1,s2
    80001b70:	bfd1                	j	80001b44 <allocproc+0x78>

0000000080001b72 <userinit>:
{
    80001b72:	1101                	addi	sp,sp,-32
    80001b74:	ec06                	sd	ra,24(sp)
    80001b76:	e822                	sd	s0,16(sp)
    80001b78:	e426                	sd	s1,8(sp)
    80001b7a:	1000                	addi	s0,sp,32
  p = allocproc();
    80001b7c:	f51ff0ef          	jal	80001acc <allocproc>
    80001b80:	84aa                	mv	s1,a0
  initproc = p;
    80001b82:	00006797          	auipc	a5,0x6
    80001b86:	eea7bb23          	sd	a0,-266(a5) # 80007a78 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001b8a:	03400613          	li	a2,52
    80001b8e:	00006597          	auipc	a1,0x6
    80001b92:	e8258593          	addi	a1,a1,-382 # 80007a10 <initcode>
    80001b96:	6928                	ld	a0,80(a0)
    80001b98:	f2eff0ef          	jal	800012c6 <uvmfirst>
  p->sz = PGSIZE;
    80001b9c:	6785                	lui	a5,0x1
    80001b9e:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001ba0:	6cb8                	ld	a4,88(s1)
    80001ba2:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001ba6:	6cb8                	ld	a4,88(s1)
    80001ba8:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001baa:	4641                	li	a2,16
    80001bac:	00005597          	auipc	a1,0x5
    80001bb0:	76c58593          	addi	a1,a1,1900 # 80007318 <etext+0x318>
    80001bb4:	15848513          	addi	a0,s1,344
    80001bb8:	a4eff0ef          	jal	80000e06 <safestrcpy>
  p->cwd = namei("/");
    80001bbc:	00005517          	auipc	a0,0x5
    80001bc0:	76c50513          	addi	a0,a0,1900 # 80007328 <etext+0x328>
    80001bc4:	51f010ef          	jal	800038e2 <namei>
    80001bc8:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001bcc:	478d                	li	a5,3
    80001bce:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001bd0:	8526                	mv	a0,s1
    80001bd2:	8baff0ef          	jal	80000c8c <release>
}
    80001bd6:	60e2                	ld	ra,24(sp)
    80001bd8:	6442                	ld	s0,16(sp)
    80001bda:	64a2                	ld	s1,8(sp)
    80001bdc:	6105                	addi	sp,sp,32
    80001bde:	8082                	ret

0000000080001be0 <growproc>:
{
    80001be0:	1101                	addi	sp,sp,-32
    80001be2:	ec06                	sd	ra,24(sp)
    80001be4:	e822                	sd	s0,16(sp)
    80001be6:	e426                	sd	s1,8(sp)
    80001be8:	e04a                	sd	s2,0(sp)
    80001bea:	1000                	addi	s0,sp,32
    80001bec:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001bee:	d1dff0ef          	jal	8000190a <myproc>
    80001bf2:	84aa                	mv	s1,a0
  sz = p->sz;
    80001bf4:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001bf6:	01204c63          	bgtz	s2,80001c0e <growproc+0x2e>
  } else if(n < 0){
    80001bfa:	02094463          	bltz	s2,80001c22 <growproc+0x42>
  p->sz = sz;
    80001bfe:	e4ac                	sd	a1,72(s1)
  return 0;
    80001c00:	4501                	li	a0,0
}
    80001c02:	60e2                	ld	ra,24(sp)
    80001c04:	6442                	ld	s0,16(sp)
    80001c06:	64a2                	ld	s1,8(sp)
    80001c08:	6902                	ld	s2,0(sp)
    80001c0a:	6105                	addi	sp,sp,32
    80001c0c:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001c0e:	4691                	li	a3,4
    80001c10:	00b90633          	add	a2,s2,a1
    80001c14:	6928                	ld	a0,80(a0)
    80001c16:	f52ff0ef          	jal	80001368 <uvmalloc>
    80001c1a:	85aa                	mv	a1,a0
    80001c1c:	f16d                	bnez	a0,80001bfe <growproc+0x1e>
      return -1;
    80001c1e:	557d                	li	a0,-1
    80001c20:	b7cd                	j	80001c02 <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001c22:	00b90633          	add	a2,s2,a1
    80001c26:	6928                	ld	a0,80(a0)
    80001c28:	efcff0ef          	jal	80001324 <uvmdealloc>
    80001c2c:	85aa                	mv	a1,a0
    80001c2e:	bfc1                	j	80001bfe <growproc+0x1e>

0000000080001c30 <fork>:
{
    80001c30:	7139                	addi	sp,sp,-64
    80001c32:	fc06                	sd	ra,56(sp)
    80001c34:	f822                	sd	s0,48(sp)
    80001c36:	f04a                	sd	s2,32(sp)
    80001c38:	e456                	sd	s5,8(sp)
    80001c3a:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001c3c:	ccfff0ef          	jal	8000190a <myproc>
    80001c40:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001c42:	e8bff0ef          	jal	80001acc <allocproc>
    80001c46:	0e050a63          	beqz	a0,80001d3a <fork+0x10a>
    80001c4a:	e852                	sd	s4,16(sp)
    80001c4c:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001c4e:	048ab603          	ld	a2,72(s5)
    80001c52:	692c                	ld	a1,80(a0)
    80001c54:	050ab503          	ld	a0,80(s5)
    80001c58:	849ff0ef          	jal	800014a0 <uvmcopy>
    80001c5c:	04054a63          	bltz	a0,80001cb0 <fork+0x80>
    80001c60:	f426                	sd	s1,40(sp)
    80001c62:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001c64:	048ab783          	ld	a5,72(s5)
    80001c68:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001c6c:	058ab683          	ld	a3,88(s5)
    80001c70:	87b6                	mv	a5,a3
    80001c72:	058a3703          	ld	a4,88(s4)
    80001c76:	12068693          	addi	a3,a3,288
    80001c7a:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001c7e:	6788                	ld	a0,8(a5)
    80001c80:	6b8c                	ld	a1,16(a5)
    80001c82:	6f90                	ld	a2,24(a5)
    80001c84:	01073023          	sd	a6,0(a4)
    80001c88:	e708                	sd	a0,8(a4)
    80001c8a:	eb0c                	sd	a1,16(a4)
    80001c8c:	ef10                	sd	a2,24(a4)
    80001c8e:	02078793          	addi	a5,a5,32
    80001c92:	02070713          	addi	a4,a4,32
    80001c96:	fed792e3          	bne	a5,a3,80001c7a <fork+0x4a>
  np->trapframe->a0 = 0;
    80001c9a:	058a3783          	ld	a5,88(s4)
    80001c9e:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001ca2:	0d0a8493          	addi	s1,s5,208
    80001ca6:	0d0a0913          	addi	s2,s4,208
    80001caa:	150a8993          	addi	s3,s5,336
    80001cae:	a831                	j	80001cca <fork+0x9a>
    freeproc(np);
    80001cb0:	8552                	mv	a0,s4
    80001cb2:	dcbff0ef          	jal	80001a7c <freeproc>
    release(&np->lock);
    80001cb6:	8552                	mv	a0,s4
    80001cb8:	fd5fe0ef          	jal	80000c8c <release>
    return -1;
    80001cbc:	597d                	li	s2,-1
    80001cbe:	6a42                	ld	s4,16(sp)
    80001cc0:	a0b5                	j	80001d2c <fork+0xfc>
  for(i = 0; i < NOFILE; i++)
    80001cc2:	04a1                	addi	s1,s1,8
    80001cc4:	0921                	addi	s2,s2,8
    80001cc6:	01348963          	beq	s1,s3,80001cd8 <fork+0xa8>
    if(p->ofile[i])
    80001cca:	6088                	ld	a0,0(s1)
    80001ccc:	d97d                	beqz	a0,80001cc2 <fork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80001cce:	1f8020ef          	jal	80003ec6 <filedup>
    80001cd2:	00a93023          	sd	a0,0(s2)
    80001cd6:	b7f5                	j	80001cc2 <fork+0x92>
  np->cwd = idup(p->cwd);
    80001cd8:	150ab503          	ld	a0,336(s5)
    80001cdc:	4f6010ef          	jal	800031d2 <idup>
    80001ce0:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001ce4:	4641                	li	a2,16
    80001ce6:	158a8593          	addi	a1,s5,344
    80001cea:	158a0513          	addi	a0,s4,344
    80001cee:	918ff0ef          	jal	80000e06 <safestrcpy>
  pid = np->pid;
    80001cf2:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001cf6:	8552                	mv	a0,s4
    80001cf8:	f95fe0ef          	jal	80000c8c <release>
  acquire(&wait_lock);
    80001cfc:	0000e497          	auipc	s1,0xe
    80001d00:	ecc48493          	addi	s1,s1,-308 # 8000fbc8 <wait_lock>
    80001d04:	8526                	mv	a0,s1
    80001d06:	eeffe0ef          	jal	80000bf4 <acquire>
  np->parent = p;
    80001d0a:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001d0e:	8526                	mv	a0,s1
    80001d10:	f7dfe0ef          	jal	80000c8c <release>
  acquire(&np->lock);
    80001d14:	8552                	mv	a0,s4
    80001d16:	edffe0ef          	jal	80000bf4 <acquire>
  np->state = RUNNABLE;
    80001d1a:	478d                	li	a5,3
    80001d1c:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001d20:	8552                	mv	a0,s4
    80001d22:	f6bfe0ef          	jal	80000c8c <release>
  return pid;
    80001d26:	74a2                	ld	s1,40(sp)
    80001d28:	69e2                	ld	s3,24(sp)
    80001d2a:	6a42                	ld	s4,16(sp)
}
    80001d2c:	854a                	mv	a0,s2
    80001d2e:	70e2                	ld	ra,56(sp)
    80001d30:	7442                	ld	s0,48(sp)
    80001d32:	7902                	ld	s2,32(sp)
    80001d34:	6aa2                	ld	s5,8(sp)
    80001d36:	6121                	addi	sp,sp,64
    80001d38:	8082                	ret
    return -1;
    80001d3a:	597d                	li	s2,-1
    80001d3c:	bfc5                	j	80001d2c <fork+0xfc>

0000000080001d3e <scheduler>:
{
    80001d3e:	715d                	addi	sp,sp,-80
    80001d40:	e486                	sd	ra,72(sp)
    80001d42:	e0a2                	sd	s0,64(sp)
    80001d44:	fc26                	sd	s1,56(sp)
    80001d46:	f84a                	sd	s2,48(sp)
    80001d48:	f44e                	sd	s3,40(sp)
    80001d4a:	f052                	sd	s4,32(sp)
    80001d4c:	ec56                	sd	s5,24(sp)
    80001d4e:	e85a                	sd	s6,16(sp)
    80001d50:	e45e                	sd	s7,8(sp)
    80001d52:	e062                	sd	s8,0(sp)
    80001d54:	0880                	addi	s0,sp,80
    80001d56:	8792                	mv	a5,tp
  int id = r_tp();
    80001d58:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001d5a:	00779b13          	slli	s6,a5,0x7
    80001d5e:	0000e717          	auipc	a4,0xe
    80001d62:	e5270713          	addi	a4,a4,-430 # 8000fbb0 <pid_lock>
    80001d66:	975a                	add	a4,a4,s6
    80001d68:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001d6c:	0000e717          	auipc	a4,0xe
    80001d70:	e7c70713          	addi	a4,a4,-388 # 8000fbe8 <cpus+0x8>
    80001d74:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001d76:	4c11                	li	s8,4
        c->proc = p;
    80001d78:	079e                	slli	a5,a5,0x7
    80001d7a:	0000ea17          	auipc	s4,0xe
    80001d7e:	e36a0a13          	addi	s4,s4,-458 # 8000fbb0 <pid_lock>
    80001d82:	9a3e                	add	s4,s4,a5
        found = 1;
    80001d84:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d86:	00014997          	auipc	s3,0x14
    80001d8a:	c5a98993          	addi	s3,s3,-934 # 800159e0 <tickslock>
    80001d8e:	a0a9                	j	80001dd8 <scheduler+0x9a>
      release(&p->lock);
    80001d90:	8526                	mv	a0,s1
    80001d92:	efbfe0ef          	jal	80000c8c <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d96:	16848493          	addi	s1,s1,360
    80001d9a:	03348563          	beq	s1,s3,80001dc4 <scheduler+0x86>
      acquire(&p->lock);
    80001d9e:	8526                	mv	a0,s1
    80001da0:	e55fe0ef          	jal	80000bf4 <acquire>
      if(p->state == RUNNABLE) {
    80001da4:	4c9c                	lw	a5,24(s1)
    80001da6:	ff2795e3          	bne	a5,s2,80001d90 <scheduler+0x52>
        p->state = RUNNING;
    80001daa:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001dae:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001db2:	06048593          	addi	a1,s1,96
    80001db6:	855a                	mv	a0,s6
    80001db8:	5b4000ef          	jal	8000236c <swtch>
        c->proc = 0;
    80001dbc:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001dc0:	8ade                	mv	s5,s7
    80001dc2:	b7f9                	j	80001d90 <scheduler+0x52>
    if(found == 0) {
    80001dc4:	000a9a63          	bnez	s5,80001dd8 <scheduler+0x9a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001dc8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001dcc:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001dd0:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80001dd4:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001dd8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001ddc:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001de0:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001de4:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001de6:	0000e497          	auipc	s1,0xe
    80001dea:	1fa48493          	addi	s1,s1,506 # 8000ffe0 <proc>
      if(p->state == RUNNABLE) {
    80001dee:	490d                	li	s2,3
    80001df0:	b77d                	j	80001d9e <scheduler+0x60>

0000000080001df2 <sched>:
{
    80001df2:	7179                	addi	sp,sp,-48
    80001df4:	f406                	sd	ra,40(sp)
    80001df6:	f022                	sd	s0,32(sp)
    80001df8:	ec26                	sd	s1,24(sp)
    80001dfa:	e84a                	sd	s2,16(sp)
    80001dfc:	e44e                	sd	s3,8(sp)
    80001dfe:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001e00:	b0bff0ef          	jal	8000190a <myproc>
    80001e04:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001e06:	d85fe0ef          	jal	80000b8a <holding>
    80001e0a:	c92d                	beqz	a0,80001e7c <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e0c:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001e0e:	2781                	sext.w	a5,a5
    80001e10:	079e                	slli	a5,a5,0x7
    80001e12:	0000e717          	auipc	a4,0xe
    80001e16:	d9e70713          	addi	a4,a4,-610 # 8000fbb0 <pid_lock>
    80001e1a:	97ba                	add	a5,a5,a4
    80001e1c:	0a87a703          	lw	a4,168(a5)
    80001e20:	4785                	li	a5,1
    80001e22:	06f71363          	bne	a4,a5,80001e88 <sched+0x96>
  if(p->state == RUNNING)
    80001e26:	4c98                	lw	a4,24(s1)
    80001e28:	4791                	li	a5,4
    80001e2a:	06f70563          	beq	a4,a5,80001e94 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e2e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e32:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001e34:	e7b5                	bnez	a5,80001ea0 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e36:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e38:	0000e917          	auipc	s2,0xe
    80001e3c:	d7890913          	addi	s2,s2,-648 # 8000fbb0 <pid_lock>
    80001e40:	2781                	sext.w	a5,a5
    80001e42:	079e                	slli	a5,a5,0x7
    80001e44:	97ca                	add	a5,a5,s2
    80001e46:	0ac7a983          	lw	s3,172(a5)
    80001e4a:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001e4c:	2781                	sext.w	a5,a5
    80001e4e:	079e                	slli	a5,a5,0x7
    80001e50:	0000e597          	auipc	a1,0xe
    80001e54:	d9858593          	addi	a1,a1,-616 # 8000fbe8 <cpus+0x8>
    80001e58:	95be                	add	a1,a1,a5
    80001e5a:	06048513          	addi	a0,s1,96
    80001e5e:	50e000ef          	jal	8000236c <swtch>
    80001e62:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001e64:	2781                	sext.w	a5,a5
    80001e66:	079e                	slli	a5,a5,0x7
    80001e68:	993e                	add	s2,s2,a5
    80001e6a:	0b392623          	sw	s3,172(s2)
}
    80001e6e:	70a2                	ld	ra,40(sp)
    80001e70:	7402                	ld	s0,32(sp)
    80001e72:	64e2                	ld	s1,24(sp)
    80001e74:	6942                	ld	s2,16(sp)
    80001e76:	69a2                	ld	s3,8(sp)
    80001e78:	6145                	addi	sp,sp,48
    80001e7a:	8082                	ret
    panic("sched p->lock");
    80001e7c:	00005517          	auipc	a0,0x5
    80001e80:	4b450513          	addi	a0,a0,1204 # 80007330 <etext+0x330>
    80001e84:	911fe0ef          	jal	80000794 <panic>
    panic("sched locks");
    80001e88:	00005517          	auipc	a0,0x5
    80001e8c:	4b850513          	addi	a0,a0,1208 # 80007340 <etext+0x340>
    80001e90:	905fe0ef          	jal	80000794 <panic>
    panic("sched running");
    80001e94:	00005517          	auipc	a0,0x5
    80001e98:	4bc50513          	addi	a0,a0,1212 # 80007350 <etext+0x350>
    80001e9c:	8f9fe0ef          	jal	80000794 <panic>
    panic("sched interruptible");
    80001ea0:	00005517          	auipc	a0,0x5
    80001ea4:	4c050513          	addi	a0,a0,1216 # 80007360 <etext+0x360>
    80001ea8:	8edfe0ef          	jal	80000794 <panic>

0000000080001eac <yield>:
{
    80001eac:	1101                	addi	sp,sp,-32
    80001eae:	ec06                	sd	ra,24(sp)
    80001eb0:	e822                	sd	s0,16(sp)
    80001eb2:	e426                	sd	s1,8(sp)
    80001eb4:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001eb6:	a55ff0ef          	jal	8000190a <myproc>
    80001eba:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001ebc:	d39fe0ef          	jal	80000bf4 <acquire>
  p->state = RUNNABLE;
    80001ec0:	478d                	li	a5,3
    80001ec2:	cc9c                	sw	a5,24(s1)
  sched();
    80001ec4:	f2fff0ef          	jal	80001df2 <sched>
  release(&p->lock);
    80001ec8:	8526                	mv	a0,s1
    80001eca:	dc3fe0ef          	jal	80000c8c <release>
}
    80001ece:	60e2                	ld	ra,24(sp)
    80001ed0:	6442                	ld	s0,16(sp)
    80001ed2:	64a2                	ld	s1,8(sp)
    80001ed4:	6105                	addi	sp,sp,32
    80001ed6:	8082                	ret

0000000080001ed8 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001ed8:	7179                	addi	sp,sp,-48
    80001eda:	f406                	sd	ra,40(sp)
    80001edc:	f022                	sd	s0,32(sp)
    80001ede:	ec26                	sd	s1,24(sp)
    80001ee0:	e84a                	sd	s2,16(sp)
    80001ee2:	e44e                	sd	s3,8(sp)
    80001ee4:	1800                	addi	s0,sp,48
    80001ee6:	89aa                	mv	s3,a0
    80001ee8:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001eea:	a21ff0ef          	jal	8000190a <myproc>
    80001eee:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001ef0:	d05fe0ef          	jal	80000bf4 <acquire>
  release(lk);
    80001ef4:	854a                	mv	a0,s2
    80001ef6:	d97fe0ef          	jal	80000c8c <release>

  // Go to sleep.
  p->chan = chan;
    80001efa:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001efe:	4789                	li	a5,2
    80001f00:	cc9c                	sw	a5,24(s1)

  sched();
    80001f02:	ef1ff0ef          	jal	80001df2 <sched>

  // Tidy up.
  p->chan = 0;
    80001f06:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001f0a:	8526                	mv	a0,s1
    80001f0c:	d81fe0ef          	jal	80000c8c <release>
  acquire(lk);
    80001f10:	854a                	mv	a0,s2
    80001f12:	ce3fe0ef          	jal	80000bf4 <acquire>
}
    80001f16:	70a2                	ld	ra,40(sp)
    80001f18:	7402                	ld	s0,32(sp)
    80001f1a:	64e2                	ld	s1,24(sp)
    80001f1c:	6942                	ld	s2,16(sp)
    80001f1e:	69a2                	ld	s3,8(sp)
    80001f20:	6145                	addi	sp,sp,48
    80001f22:	8082                	ret

0000000080001f24 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80001f24:	7139                	addi	sp,sp,-64
    80001f26:	fc06                	sd	ra,56(sp)
    80001f28:	f822                	sd	s0,48(sp)
    80001f2a:	f426                	sd	s1,40(sp)
    80001f2c:	f04a                	sd	s2,32(sp)
    80001f2e:	ec4e                	sd	s3,24(sp)
    80001f30:	e852                	sd	s4,16(sp)
    80001f32:	e456                	sd	s5,8(sp)
    80001f34:	0080                	addi	s0,sp,64
    80001f36:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001f38:	0000e497          	auipc	s1,0xe
    80001f3c:	0a848493          	addi	s1,s1,168 # 8000ffe0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001f40:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001f42:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f44:	00014917          	auipc	s2,0x14
    80001f48:	a9c90913          	addi	s2,s2,-1380 # 800159e0 <tickslock>
    80001f4c:	a801                	j	80001f5c <wakeup+0x38>
      }
      release(&p->lock);
    80001f4e:	8526                	mv	a0,s1
    80001f50:	d3dfe0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f54:	16848493          	addi	s1,s1,360
    80001f58:	03248263          	beq	s1,s2,80001f7c <wakeup+0x58>
    if(p != myproc()){
    80001f5c:	9afff0ef          	jal	8000190a <myproc>
    80001f60:	fea48ae3          	beq	s1,a0,80001f54 <wakeup+0x30>
      acquire(&p->lock);
    80001f64:	8526                	mv	a0,s1
    80001f66:	c8ffe0ef          	jal	80000bf4 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001f6a:	4c9c                	lw	a5,24(s1)
    80001f6c:	ff3791e3          	bne	a5,s3,80001f4e <wakeup+0x2a>
    80001f70:	709c                	ld	a5,32(s1)
    80001f72:	fd479ee3          	bne	a5,s4,80001f4e <wakeup+0x2a>
        p->state = RUNNABLE;
    80001f76:	0154ac23          	sw	s5,24(s1)
    80001f7a:	bfd1                	j	80001f4e <wakeup+0x2a>
    }
  }
}
    80001f7c:	70e2                	ld	ra,56(sp)
    80001f7e:	7442                	ld	s0,48(sp)
    80001f80:	74a2                	ld	s1,40(sp)
    80001f82:	7902                	ld	s2,32(sp)
    80001f84:	69e2                	ld	s3,24(sp)
    80001f86:	6a42                	ld	s4,16(sp)
    80001f88:	6aa2                	ld	s5,8(sp)
    80001f8a:	6121                	addi	sp,sp,64
    80001f8c:	8082                	ret

0000000080001f8e <reparent>:
{
    80001f8e:	7179                	addi	sp,sp,-48
    80001f90:	f406                	sd	ra,40(sp)
    80001f92:	f022                	sd	s0,32(sp)
    80001f94:	ec26                	sd	s1,24(sp)
    80001f96:	e84a                	sd	s2,16(sp)
    80001f98:	e44e                	sd	s3,8(sp)
    80001f9a:	e052                	sd	s4,0(sp)
    80001f9c:	1800                	addi	s0,sp,48
    80001f9e:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001fa0:	0000e497          	auipc	s1,0xe
    80001fa4:	04048493          	addi	s1,s1,64 # 8000ffe0 <proc>
      pp->parent = initproc;
    80001fa8:	00006a17          	auipc	s4,0x6
    80001fac:	ad0a0a13          	addi	s4,s4,-1328 # 80007a78 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001fb0:	00014997          	auipc	s3,0x14
    80001fb4:	a3098993          	addi	s3,s3,-1488 # 800159e0 <tickslock>
    80001fb8:	a029                	j	80001fc2 <reparent+0x34>
    80001fba:	16848493          	addi	s1,s1,360
    80001fbe:	01348b63          	beq	s1,s3,80001fd4 <reparent+0x46>
    if(pp->parent == p){
    80001fc2:	7c9c                	ld	a5,56(s1)
    80001fc4:	ff279be3          	bne	a5,s2,80001fba <reparent+0x2c>
      pp->parent = initproc;
    80001fc8:	000a3503          	ld	a0,0(s4)
    80001fcc:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80001fce:	f57ff0ef          	jal	80001f24 <wakeup>
    80001fd2:	b7e5                	j	80001fba <reparent+0x2c>
}
    80001fd4:	70a2                	ld	ra,40(sp)
    80001fd6:	7402                	ld	s0,32(sp)
    80001fd8:	64e2                	ld	s1,24(sp)
    80001fda:	6942                	ld	s2,16(sp)
    80001fdc:	69a2                	ld	s3,8(sp)
    80001fde:	6a02                	ld	s4,0(sp)
    80001fe0:	6145                	addi	sp,sp,48
    80001fe2:	8082                	ret

0000000080001fe4 <exit>:
{
    80001fe4:	7179                	addi	sp,sp,-48
    80001fe6:	f406                	sd	ra,40(sp)
    80001fe8:	f022                	sd	s0,32(sp)
    80001fea:	ec26                	sd	s1,24(sp)
    80001fec:	e84a                	sd	s2,16(sp)
    80001fee:	e44e                	sd	s3,8(sp)
    80001ff0:	e052                	sd	s4,0(sp)
    80001ff2:	1800                	addi	s0,sp,48
    80001ff4:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80001ff6:	915ff0ef          	jal	8000190a <myproc>
    80001ffa:	89aa                	mv	s3,a0
  if(p == initproc)
    80001ffc:	00006797          	auipc	a5,0x6
    80002000:	a7c7b783          	ld	a5,-1412(a5) # 80007a78 <initproc>
    80002004:	0d050493          	addi	s1,a0,208
    80002008:	15050913          	addi	s2,a0,336
    8000200c:	00a79f63          	bne	a5,a0,8000202a <exit+0x46>
    panic("init exiting");
    80002010:	00005517          	auipc	a0,0x5
    80002014:	36850513          	addi	a0,a0,872 # 80007378 <etext+0x378>
    80002018:	f7cfe0ef          	jal	80000794 <panic>
      fileclose(f);
    8000201c:	6f1010ef          	jal	80003f0c <fileclose>
      p->ofile[fd] = 0;
    80002020:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002024:	04a1                	addi	s1,s1,8
    80002026:	01248563          	beq	s1,s2,80002030 <exit+0x4c>
    if(p->ofile[fd]){
    8000202a:	6088                	ld	a0,0(s1)
    8000202c:	f965                	bnez	a0,8000201c <exit+0x38>
    8000202e:	bfdd                	j	80002024 <exit+0x40>
  begin_op();
    80002030:	26f010ef          	jal	80003a9e <begin_op>
  iput(p->cwd);
    80002034:	1509b503          	ld	a0,336(s3)
    80002038:	352010ef          	jal	8000338a <iput>
  end_op();
    8000203c:	2cd010ef          	jal	80003b08 <end_op>
  p->cwd = 0;
    80002040:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002044:	0000e497          	auipc	s1,0xe
    80002048:	b8448493          	addi	s1,s1,-1148 # 8000fbc8 <wait_lock>
    8000204c:	8526                	mv	a0,s1
    8000204e:	ba7fe0ef          	jal	80000bf4 <acquire>
  reparent(p);
    80002052:	854e                	mv	a0,s3
    80002054:	f3bff0ef          	jal	80001f8e <reparent>
  wakeup(p->parent);
    80002058:	0389b503          	ld	a0,56(s3)
    8000205c:	ec9ff0ef          	jal	80001f24 <wakeup>
  acquire(&p->lock);
    80002060:	854e                	mv	a0,s3
    80002062:	b93fe0ef          	jal	80000bf4 <acquire>
  p->xstate = status;
    80002066:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000206a:	4795                	li	a5,5
    8000206c:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002070:	8526                	mv	a0,s1
    80002072:	c1bfe0ef          	jal	80000c8c <release>
  sched();
    80002076:	d7dff0ef          	jal	80001df2 <sched>
  panic("zombie exit");
    8000207a:	00005517          	auipc	a0,0x5
    8000207e:	30e50513          	addi	a0,a0,782 # 80007388 <etext+0x388>
    80002082:	f12fe0ef          	jal	80000794 <panic>

0000000080002086 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002086:	7179                	addi	sp,sp,-48
    80002088:	f406                	sd	ra,40(sp)
    8000208a:	f022                	sd	s0,32(sp)
    8000208c:	ec26                	sd	s1,24(sp)
    8000208e:	e84a                	sd	s2,16(sp)
    80002090:	e44e                	sd	s3,8(sp)
    80002092:	1800                	addi	s0,sp,48
    80002094:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002096:	0000e497          	auipc	s1,0xe
    8000209a:	f4a48493          	addi	s1,s1,-182 # 8000ffe0 <proc>
    8000209e:	00014997          	auipc	s3,0x14
    800020a2:	94298993          	addi	s3,s3,-1726 # 800159e0 <tickslock>
    acquire(&p->lock);
    800020a6:	8526                	mv	a0,s1
    800020a8:	b4dfe0ef          	jal	80000bf4 <acquire>
    if(p->pid == pid){
    800020ac:	589c                	lw	a5,48(s1)
    800020ae:	01278b63          	beq	a5,s2,800020c4 <kill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800020b2:	8526                	mv	a0,s1
    800020b4:	bd9fe0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800020b8:	16848493          	addi	s1,s1,360
    800020bc:	ff3495e3          	bne	s1,s3,800020a6 <kill+0x20>
  }
  return -1;
    800020c0:	557d                	li	a0,-1
    800020c2:	a819                	j	800020d8 <kill+0x52>
      p->killed = 1;
    800020c4:	4785                	li	a5,1
    800020c6:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800020c8:	4c98                	lw	a4,24(s1)
    800020ca:	4789                	li	a5,2
    800020cc:	00f70d63          	beq	a4,a5,800020e6 <kill+0x60>
      release(&p->lock);
    800020d0:	8526                	mv	a0,s1
    800020d2:	bbbfe0ef          	jal	80000c8c <release>
      return 0;
    800020d6:	4501                	li	a0,0
}
    800020d8:	70a2                	ld	ra,40(sp)
    800020da:	7402                	ld	s0,32(sp)
    800020dc:	64e2                	ld	s1,24(sp)
    800020de:	6942                	ld	s2,16(sp)
    800020e0:	69a2                	ld	s3,8(sp)
    800020e2:	6145                	addi	sp,sp,48
    800020e4:	8082                	ret
        p->state = RUNNABLE;
    800020e6:	478d                	li	a5,3
    800020e8:	cc9c                	sw	a5,24(s1)
    800020ea:	b7dd                	j	800020d0 <kill+0x4a>

00000000800020ec <setkilled>:

void
setkilled(struct proc *p)
{
    800020ec:	1101                	addi	sp,sp,-32
    800020ee:	ec06                	sd	ra,24(sp)
    800020f0:	e822                	sd	s0,16(sp)
    800020f2:	e426                	sd	s1,8(sp)
    800020f4:	1000                	addi	s0,sp,32
    800020f6:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020f8:	afdfe0ef          	jal	80000bf4 <acquire>
  p->killed = 1;
    800020fc:	4785                	li	a5,1
    800020fe:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002100:	8526                	mv	a0,s1
    80002102:	b8bfe0ef          	jal	80000c8c <release>
}
    80002106:	60e2                	ld	ra,24(sp)
    80002108:	6442                	ld	s0,16(sp)
    8000210a:	64a2                	ld	s1,8(sp)
    8000210c:	6105                	addi	sp,sp,32
    8000210e:	8082                	ret

0000000080002110 <killed>:

int
killed(struct proc *p)
{
    80002110:	1101                	addi	sp,sp,-32
    80002112:	ec06                	sd	ra,24(sp)
    80002114:	e822                	sd	s0,16(sp)
    80002116:	e426                	sd	s1,8(sp)
    80002118:	e04a                	sd	s2,0(sp)
    8000211a:	1000                	addi	s0,sp,32
    8000211c:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    8000211e:	ad7fe0ef          	jal	80000bf4 <acquire>
  k = p->killed;
    80002122:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002126:	8526                	mv	a0,s1
    80002128:	b65fe0ef          	jal	80000c8c <release>
  return k;
}
    8000212c:	854a                	mv	a0,s2
    8000212e:	60e2                	ld	ra,24(sp)
    80002130:	6442                	ld	s0,16(sp)
    80002132:	64a2                	ld	s1,8(sp)
    80002134:	6902                	ld	s2,0(sp)
    80002136:	6105                	addi	sp,sp,32
    80002138:	8082                	ret

000000008000213a <wait>:
{
    8000213a:	715d                	addi	sp,sp,-80
    8000213c:	e486                	sd	ra,72(sp)
    8000213e:	e0a2                	sd	s0,64(sp)
    80002140:	fc26                	sd	s1,56(sp)
    80002142:	f84a                	sd	s2,48(sp)
    80002144:	f44e                	sd	s3,40(sp)
    80002146:	f052                	sd	s4,32(sp)
    80002148:	ec56                	sd	s5,24(sp)
    8000214a:	e85a                	sd	s6,16(sp)
    8000214c:	e45e                	sd	s7,8(sp)
    8000214e:	e062                	sd	s8,0(sp)
    80002150:	0880                	addi	s0,sp,80
    80002152:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002154:	fb6ff0ef          	jal	8000190a <myproc>
    80002158:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000215a:	0000e517          	auipc	a0,0xe
    8000215e:	a6e50513          	addi	a0,a0,-1426 # 8000fbc8 <wait_lock>
    80002162:	a93fe0ef          	jal	80000bf4 <acquire>
    havekids = 0;
    80002166:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002168:	4a15                	li	s4,5
        havekids = 1;
    8000216a:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000216c:	00014997          	auipc	s3,0x14
    80002170:	87498993          	addi	s3,s3,-1932 # 800159e0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002174:	0000ec17          	auipc	s8,0xe
    80002178:	a54c0c13          	addi	s8,s8,-1452 # 8000fbc8 <wait_lock>
    8000217c:	a871                	j	80002218 <wait+0xde>
          pid = pp->pid;
    8000217e:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002182:	000b0c63          	beqz	s6,8000219a <wait+0x60>
    80002186:	4691                	li	a3,4
    80002188:	02c48613          	addi	a2,s1,44
    8000218c:	85da                	mv	a1,s6
    8000218e:	05093503          	ld	a0,80(s2)
    80002192:	beaff0ef          	jal	8000157c <copyout>
    80002196:	02054b63          	bltz	a0,800021cc <wait+0x92>
          freeproc(pp);
    8000219a:	8526                	mv	a0,s1
    8000219c:	8e1ff0ef          	jal	80001a7c <freeproc>
          release(&pp->lock);
    800021a0:	8526                	mv	a0,s1
    800021a2:	aebfe0ef          	jal	80000c8c <release>
          release(&wait_lock);
    800021a6:	0000e517          	auipc	a0,0xe
    800021aa:	a2250513          	addi	a0,a0,-1502 # 8000fbc8 <wait_lock>
    800021ae:	adffe0ef          	jal	80000c8c <release>
}
    800021b2:	854e                	mv	a0,s3
    800021b4:	60a6                	ld	ra,72(sp)
    800021b6:	6406                	ld	s0,64(sp)
    800021b8:	74e2                	ld	s1,56(sp)
    800021ba:	7942                	ld	s2,48(sp)
    800021bc:	79a2                	ld	s3,40(sp)
    800021be:	7a02                	ld	s4,32(sp)
    800021c0:	6ae2                	ld	s5,24(sp)
    800021c2:	6b42                	ld	s6,16(sp)
    800021c4:	6ba2                	ld	s7,8(sp)
    800021c6:	6c02                	ld	s8,0(sp)
    800021c8:	6161                	addi	sp,sp,80
    800021ca:	8082                	ret
            release(&pp->lock);
    800021cc:	8526                	mv	a0,s1
    800021ce:	abffe0ef          	jal	80000c8c <release>
            release(&wait_lock);
    800021d2:	0000e517          	auipc	a0,0xe
    800021d6:	9f650513          	addi	a0,a0,-1546 # 8000fbc8 <wait_lock>
    800021da:	ab3fe0ef          	jal	80000c8c <release>
            return -1;
    800021de:	59fd                	li	s3,-1
    800021e0:	bfc9                	j	800021b2 <wait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800021e2:	16848493          	addi	s1,s1,360
    800021e6:	03348063          	beq	s1,s3,80002206 <wait+0xcc>
      if(pp->parent == p){
    800021ea:	7c9c                	ld	a5,56(s1)
    800021ec:	ff279be3          	bne	a5,s2,800021e2 <wait+0xa8>
        acquire(&pp->lock);
    800021f0:	8526                	mv	a0,s1
    800021f2:	a03fe0ef          	jal	80000bf4 <acquire>
        if(pp->state == ZOMBIE){
    800021f6:	4c9c                	lw	a5,24(s1)
    800021f8:	f94783e3          	beq	a5,s4,8000217e <wait+0x44>
        release(&pp->lock);
    800021fc:	8526                	mv	a0,s1
    800021fe:	a8ffe0ef          	jal	80000c8c <release>
        havekids = 1;
    80002202:	8756                	mv	a4,s5
    80002204:	bff9                	j	800021e2 <wait+0xa8>
    if(!havekids || killed(p)){
    80002206:	cf19                	beqz	a4,80002224 <wait+0xea>
    80002208:	854a                	mv	a0,s2
    8000220a:	f07ff0ef          	jal	80002110 <killed>
    8000220e:	e919                	bnez	a0,80002224 <wait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002210:	85e2                	mv	a1,s8
    80002212:	854a                	mv	a0,s2
    80002214:	cc5ff0ef          	jal	80001ed8 <sleep>
    havekids = 0;
    80002218:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000221a:	0000e497          	auipc	s1,0xe
    8000221e:	dc648493          	addi	s1,s1,-570 # 8000ffe0 <proc>
    80002222:	b7e1                	j	800021ea <wait+0xb0>
      release(&wait_lock);
    80002224:	0000e517          	auipc	a0,0xe
    80002228:	9a450513          	addi	a0,a0,-1628 # 8000fbc8 <wait_lock>
    8000222c:	a61fe0ef          	jal	80000c8c <release>
      return -1;
    80002230:	59fd                	li	s3,-1
    80002232:	b741                	j	800021b2 <wait+0x78>

0000000080002234 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002234:	7179                	addi	sp,sp,-48
    80002236:	f406                	sd	ra,40(sp)
    80002238:	f022                	sd	s0,32(sp)
    8000223a:	ec26                	sd	s1,24(sp)
    8000223c:	e84a                	sd	s2,16(sp)
    8000223e:	e44e                	sd	s3,8(sp)
    80002240:	e052                	sd	s4,0(sp)
    80002242:	1800                	addi	s0,sp,48
    80002244:	84aa                	mv	s1,a0
    80002246:	892e                	mv	s2,a1
    80002248:	89b2                	mv	s3,a2
    8000224a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000224c:	ebeff0ef          	jal	8000190a <myproc>
  if(user_dst){
    80002250:	cc99                	beqz	s1,8000226e <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002252:	86d2                	mv	a3,s4
    80002254:	864e                	mv	a2,s3
    80002256:	85ca                	mv	a1,s2
    80002258:	6928                	ld	a0,80(a0)
    8000225a:	b22ff0ef          	jal	8000157c <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000225e:	70a2                	ld	ra,40(sp)
    80002260:	7402                	ld	s0,32(sp)
    80002262:	64e2                	ld	s1,24(sp)
    80002264:	6942                	ld	s2,16(sp)
    80002266:	69a2                	ld	s3,8(sp)
    80002268:	6a02                	ld	s4,0(sp)
    8000226a:	6145                	addi	sp,sp,48
    8000226c:	8082                	ret
    memmove((char *)dst, src, len);
    8000226e:	000a061b          	sext.w	a2,s4
    80002272:	85ce                	mv	a1,s3
    80002274:	854a                	mv	a0,s2
    80002276:	aaffe0ef          	jal	80000d24 <memmove>
    return 0;
    8000227a:	8526                	mv	a0,s1
    8000227c:	b7cd                	j	8000225e <either_copyout+0x2a>

000000008000227e <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000227e:	7179                	addi	sp,sp,-48
    80002280:	f406                	sd	ra,40(sp)
    80002282:	f022                	sd	s0,32(sp)
    80002284:	ec26                	sd	s1,24(sp)
    80002286:	e84a                	sd	s2,16(sp)
    80002288:	e44e                	sd	s3,8(sp)
    8000228a:	e052                	sd	s4,0(sp)
    8000228c:	1800                	addi	s0,sp,48
    8000228e:	892a                	mv	s2,a0
    80002290:	84ae                	mv	s1,a1
    80002292:	89b2                	mv	s3,a2
    80002294:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002296:	e74ff0ef          	jal	8000190a <myproc>
  if(user_src){
    8000229a:	cc99                	beqz	s1,800022b8 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    8000229c:	86d2                	mv	a3,s4
    8000229e:	864e                	mv	a2,s3
    800022a0:	85ca                	mv	a1,s2
    800022a2:	6928                	ld	a0,80(a0)
    800022a4:	baeff0ef          	jal	80001652 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800022a8:	70a2                	ld	ra,40(sp)
    800022aa:	7402                	ld	s0,32(sp)
    800022ac:	64e2                	ld	s1,24(sp)
    800022ae:	6942                	ld	s2,16(sp)
    800022b0:	69a2                	ld	s3,8(sp)
    800022b2:	6a02                	ld	s4,0(sp)
    800022b4:	6145                	addi	sp,sp,48
    800022b6:	8082                	ret
    memmove(dst, (char*)src, len);
    800022b8:	000a061b          	sext.w	a2,s4
    800022bc:	85ce                	mv	a1,s3
    800022be:	854a                	mv	a0,s2
    800022c0:	a65fe0ef          	jal	80000d24 <memmove>
    return 0;
    800022c4:	8526                	mv	a0,s1
    800022c6:	b7cd                	j	800022a8 <either_copyin+0x2a>

00000000800022c8 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800022c8:	715d                	addi	sp,sp,-80
    800022ca:	e486                	sd	ra,72(sp)
    800022cc:	e0a2                	sd	s0,64(sp)
    800022ce:	fc26                	sd	s1,56(sp)
    800022d0:	f84a                	sd	s2,48(sp)
    800022d2:	f44e                	sd	s3,40(sp)
    800022d4:	f052                	sd	s4,32(sp)
    800022d6:	ec56                	sd	s5,24(sp)
    800022d8:	e85a                	sd	s6,16(sp)
    800022da:	e45e                	sd	s7,8(sp)
    800022dc:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800022de:	00005517          	auipc	a0,0x5
    800022e2:	d9a50513          	addi	a0,a0,-614 # 80007078 <etext+0x78>
    800022e6:	9dcfe0ef          	jal	800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800022ea:	0000e497          	auipc	s1,0xe
    800022ee:	e4e48493          	addi	s1,s1,-434 # 80010138 <proc+0x158>
    800022f2:	00014917          	auipc	s2,0x14
    800022f6:	84690913          	addi	s2,s2,-1978 # 80015b38 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800022fa:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800022fc:	00005997          	auipc	s3,0x5
    80002300:	09c98993          	addi	s3,s3,156 # 80007398 <etext+0x398>
    printf("%d %s %s", p->pid, state, p->name);
    80002304:	00005a97          	auipc	s5,0x5
    80002308:	09ca8a93          	addi	s5,s5,156 # 800073a0 <etext+0x3a0>
    printf("\n");
    8000230c:	00005a17          	auipc	s4,0x5
    80002310:	d6ca0a13          	addi	s4,s4,-660 # 80007078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002314:	00005b97          	auipc	s7,0x5
    80002318:	5e4b8b93          	addi	s7,s7,1508 # 800078f8 <states.0>
    8000231c:	a829                	j	80002336 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    8000231e:	ed86a583          	lw	a1,-296(a3)
    80002322:	8556                	mv	a0,s5
    80002324:	99efe0ef          	jal	800004c2 <printf>
    printf("\n");
    80002328:	8552                	mv	a0,s4
    8000232a:	998fe0ef          	jal	800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000232e:	16848493          	addi	s1,s1,360
    80002332:	03248263          	beq	s1,s2,80002356 <procdump+0x8e>
    if(p->state == UNUSED)
    80002336:	86a6                	mv	a3,s1
    80002338:	ec04a783          	lw	a5,-320(s1)
    8000233c:	dbed                	beqz	a5,8000232e <procdump+0x66>
      state = "???";
    8000233e:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002340:	fcfb6fe3          	bltu	s6,a5,8000231e <procdump+0x56>
    80002344:	02079713          	slli	a4,a5,0x20
    80002348:	01d75793          	srli	a5,a4,0x1d
    8000234c:	97de                	add	a5,a5,s7
    8000234e:	6390                	ld	a2,0(a5)
    80002350:	f679                	bnez	a2,8000231e <procdump+0x56>
      state = "???";
    80002352:	864e                	mv	a2,s3
    80002354:	b7e9                	j	8000231e <procdump+0x56>
  }
}
    80002356:	60a6                	ld	ra,72(sp)
    80002358:	6406                	ld	s0,64(sp)
    8000235a:	74e2                	ld	s1,56(sp)
    8000235c:	7942                	ld	s2,48(sp)
    8000235e:	79a2                	ld	s3,40(sp)
    80002360:	7a02                	ld	s4,32(sp)
    80002362:	6ae2                	ld	s5,24(sp)
    80002364:	6b42                	ld	s6,16(sp)
    80002366:	6ba2                	ld	s7,8(sp)
    80002368:	6161                	addi	sp,sp,80
    8000236a:	8082                	ret

000000008000236c <swtch>:
    8000236c:	00153023          	sd	ra,0(a0)
    80002370:	00253423          	sd	sp,8(a0)
    80002374:	e900                	sd	s0,16(a0)
    80002376:	ed04                	sd	s1,24(a0)
    80002378:	03253023          	sd	s2,32(a0)
    8000237c:	03353423          	sd	s3,40(a0)
    80002380:	03453823          	sd	s4,48(a0)
    80002384:	03553c23          	sd	s5,56(a0)
    80002388:	05653023          	sd	s6,64(a0)
    8000238c:	05753423          	sd	s7,72(a0)
    80002390:	05853823          	sd	s8,80(a0)
    80002394:	05953c23          	sd	s9,88(a0)
    80002398:	07a53023          	sd	s10,96(a0)
    8000239c:	07b53423          	sd	s11,104(a0)
    800023a0:	0005b083          	ld	ra,0(a1)
    800023a4:	0085b103          	ld	sp,8(a1)
    800023a8:	6980                	ld	s0,16(a1)
    800023aa:	6d84                	ld	s1,24(a1)
    800023ac:	0205b903          	ld	s2,32(a1)
    800023b0:	0285b983          	ld	s3,40(a1)
    800023b4:	0305ba03          	ld	s4,48(a1)
    800023b8:	0385ba83          	ld	s5,56(a1)
    800023bc:	0405bb03          	ld	s6,64(a1)
    800023c0:	0485bb83          	ld	s7,72(a1)
    800023c4:	0505bc03          	ld	s8,80(a1)
    800023c8:	0585bc83          	ld	s9,88(a1)
    800023cc:	0605bd03          	ld	s10,96(a1)
    800023d0:	0685bd83          	ld	s11,104(a1)
    800023d4:	8082                	ret

00000000800023d6 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800023d6:	1141                	addi	sp,sp,-16
    800023d8:	e406                	sd	ra,8(sp)
    800023da:	e022                	sd	s0,0(sp)
    800023dc:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800023de:	00005597          	auipc	a1,0x5
    800023e2:	00258593          	addi	a1,a1,2 # 800073e0 <etext+0x3e0>
    800023e6:	00013517          	auipc	a0,0x13
    800023ea:	5fa50513          	addi	a0,a0,1530 # 800159e0 <tickslock>
    800023ee:	f86fe0ef          	jal	80000b74 <initlock>
}
    800023f2:	60a2                	ld	ra,8(sp)
    800023f4:	6402                	ld	s0,0(sp)
    800023f6:	0141                	addi	sp,sp,16
    800023f8:	8082                	ret

00000000800023fa <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800023fa:	1141                	addi	sp,sp,-16
    800023fc:	e422                	sd	s0,8(sp)
    800023fe:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002400:	00003797          	auipc	a5,0x3
    80002404:	e8078793          	addi	a5,a5,-384 # 80005280 <kernelvec>
    80002408:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000240c:	6422                	ld	s0,8(sp)
    8000240e:	0141                	addi	sp,sp,16
    80002410:	8082                	ret

0000000080002412 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002412:	1141                	addi	sp,sp,-16
    80002414:	e406                	sd	ra,8(sp)
    80002416:	e022                	sd	s0,0(sp)
    80002418:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000241a:	cf0ff0ef          	jal	8000190a <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000241e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002422:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002424:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002428:	00004697          	auipc	a3,0x4
    8000242c:	bd868693          	addi	a3,a3,-1064 # 80006000 <_trampoline>
    80002430:	00004717          	auipc	a4,0x4
    80002434:	bd070713          	addi	a4,a4,-1072 # 80006000 <_trampoline>
    80002438:	8f15                	sub	a4,a4,a3
    8000243a:	040007b7          	lui	a5,0x4000
    8000243e:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002440:	07b2                	slli	a5,a5,0xc
    80002442:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002444:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002448:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000244a:	18002673          	csrr	a2,satp
    8000244e:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002450:	6d30                	ld	a2,88(a0)
    80002452:	6138                	ld	a4,64(a0)
    80002454:	6585                	lui	a1,0x1
    80002456:	972e                	add	a4,a4,a1
    80002458:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000245a:	6d38                	ld	a4,88(a0)
    8000245c:	00000617          	auipc	a2,0x0
    80002460:	11060613          	addi	a2,a2,272 # 8000256c <usertrap>
    80002464:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002466:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002468:	8612                	mv	a2,tp
    8000246a:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000246c:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002470:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002474:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002478:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000247c:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000247e:	6f18                	ld	a4,24(a4)
    80002480:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002484:	6928                	ld	a0,80(a0)
    80002486:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002488:	00004717          	auipc	a4,0x4
    8000248c:	c1470713          	addi	a4,a4,-1004 # 8000609c <userret>
    80002490:	8f15                	sub	a4,a4,a3
    80002492:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002494:	577d                	li	a4,-1
    80002496:	177e                	slli	a4,a4,0x3f
    80002498:	8d59                	or	a0,a0,a4
    8000249a:	9782                	jalr	a5
}
    8000249c:	60a2                	ld	ra,8(sp)
    8000249e:	6402                	ld	s0,0(sp)
    800024a0:	0141                	addi	sp,sp,16
    800024a2:	8082                	ret

00000000800024a4 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800024a4:	1101                	addi	sp,sp,-32
    800024a6:	ec06                	sd	ra,24(sp)
    800024a8:	e822                	sd	s0,16(sp)
    800024aa:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    800024ac:	c32ff0ef          	jal	800018de <cpuid>
    800024b0:	cd11                	beqz	a0,800024cc <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    800024b2:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800024b6:	000f4737          	lui	a4,0xf4
    800024ba:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800024be:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    800024c0:	14d79073          	csrw	stimecmp,a5
}
    800024c4:	60e2                	ld	ra,24(sp)
    800024c6:	6442                	ld	s0,16(sp)
    800024c8:	6105                	addi	sp,sp,32
    800024ca:	8082                	ret
    800024cc:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    800024ce:	00013497          	auipc	s1,0x13
    800024d2:	51248493          	addi	s1,s1,1298 # 800159e0 <tickslock>
    800024d6:	8526                	mv	a0,s1
    800024d8:	f1cfe0ef          	jal	80000bf4 <acquire>
    ticks++;
    800024dc:	00005517          	auipc	a0,0x5
    800024e0:	5a450513          	addi	a0,a0,1444 # 80007a80 <ticks>
    800024e4:	411c                	lw	a5,0(a0)
    800024e6:	2785                	addiw	a5,a5,1
    800024e8:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    800024ea:	a3bff0ef          	jal	80001f24 <wakeup>
    release(&tickslock);
    800024ee:	8526                	mv	a0,s1
    800024f0:	f9cfe0ef          	jal	80000c8c <release>
    800024f4:	64a2                	ld	s1,8(sp)
    800024f6:	bf75                	j	800024b2 <clockintr+0xe>

00000000800024f8 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800024f8:	1101                	addi	sp,sp,-32
    800024fa:	ec06                	sd	ra,24(sp)
    800024fc:	e822                	sd	s0,16(sp)
    800024fe:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002500:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002504:	57fd                	li	a5,-1
    80002506:	17fe                	slli	a5,a5,0x3f
    80002508:	07a5                	addi	a5,a5,9
    8000250a:	00f70c63          	beq	a4,a5,80002522 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    8000250e:	57fd                	li	a5,-1
    80002510:	17fe                	slli	a5,a5,0x3f
    80002512:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002514:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002516:	04f70763          	beq	a4,a5,80002564 <devintr+0x6c>
  }
}
    8000251a:	60e2                	ld	ra,24(sp)
    8000251c:	6442                	ld	s0,16(sp)
    8000251e:	6105                	addi	sp,sp,32
    80002520:	8082                	ret
    80002522:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002524:	609020ef          	jal	8000532c <plic_claim>
    80002528:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000252a:	47a9                	li	a5,10
    8000252c:	00f50963          	beq	a0,a5,8000253e <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    80002530:	4785                	li	a5,1
    80002532:	00f50963          	beq	a0,a5,80002544 <devintr+0x4c>
    return 1;
    80002536:	4505                	li	a0,1
    } else if(irq){
    80002538:	e889                	bnez	s1,8000254a <devintr+0x52>
    8000253a:	64a2                	ld	s1,8(sp)
    8000253c:	bff9                	j	8000251a <devintr+0x22>
      uartintr();
    8000253e:	cc8fe0ef          	jal	80000a06 <uartintr>
    if(irq)
    80002542:	a819                	j	80002558 <devintr+0x60>
      virtio_disk_intr();
    80002544:	2ae030ef          	jal	800057f2 <virtio_disk_intr>
    if(irq)
    80002548:	a801                	j	80002558 <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    8000254a:	85a6                	mv	a1,s1
    8000254c:	00005517          	auipc	a0,0x5
    80002550:	e9c50513          	addi	a0,a0,-356 # 800073e8 <etext+0x3e8>
    80002554:	f6ffd0ef          	jal	800004c2 <printf>
      plic_complete(irq);
    80002558:	8526                	mv	a0,s1
    8000255a:	5f3020ef          	jal	8000534c <plic_complete>
    return 1;
    8000255e:	4505                	li	a0,1
    80002560:	64a2                	ld	s1,8(sp)
    80002562:	bf65                	j	8000251a <devintr+0x22>
    clockintr();
    80002564:	f41ff0ef          	jal	800024a4 <clockintr>
    return 2;
    80002568:	4509                	li	a0,2
    8000256a:	bf45                	j	8000251a <devintr+0x22>

000000008000256c <usertrap>:
{
    8000256c:	1101                	addi	sp,sp,-32
    8000256e:	ec06                	sd	ra,24(sp)
    80002570:	e822                	sd	s0,16(sp)
    80002572:	e426                	sd	s1,8(sp)
    80002574:	e04a                	sd	s2,0(sp)
    80002576:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002578:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000257c:	1007f793          	andi	a5,a5,256
    80002580:	ef85                	bnez	a5,800025b8 <usertrap+0x4c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002582:	00003797          	auipc	a5,0x3
    80002586:	cfe78793          	addi	a5,a5,-770 # 80005280 <kernelvec>
    8000258a:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000258e:	b7cff0ef          	jal	8000190a <myproc>
    80002592:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002594:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002596:	14102773          	csrr	a4,sepc
    8000259a:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000259c:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800025a0:	47a1                	li	a5,8
    800025a2:	02f70163          	beq	a4,a5,800025c4 <usertrap+0x58>
  } else if((which_dev = devintr()) != 0){
    800025a6:	f53ff0ef          	jal	800024f8 <devintr>
    800025aa:	892a                	mv	s2,a0
    800025ac:	c135                	beqz	a0,80002610 <usertrap+0xa4>
  if(killed(p))
    800025ae:	8526                	mv	a0,s1
    800025b0:	b61ff0ef          	jal	80002110 <killed>
    800025b4:	cd1d                	beqz	a0,800025f2 <usertrap+0x86>
    800025b6:	a81d                	j	800025ec <usertrap+0x80>
    panic("usertrap: not from user mode");
    800025b8:	00005517          	auipc	a0,0x5
    800025bc:	e5050513          	addi	a0,a0,-432 # 80007408 <etext+0x408>
    800025c0:	9d4fe0ef          	jal	80000794 <panic>
    if(killed(p))
    800025c4:	b4dff0ef          	jal	80002110 <killed>
    800025c8:	e121                	bnez	a0,80002608 <usertrap+0x9c>
    p->trapframe->epc += 4;
    800025ca:	6cb8                	ld	a4,88(s1)
    800025cc:	6f1c                	ld	a5,24(a4)
    800025ce:	0791                	addi	a5,a5,4
    800025d0:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025d2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800025d6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800025da:	10079073          	csrw	sstatus,a5
    syscall();
    800025de:	248000ef          	jal	80002826 <syscall>
  if(killed(p))
    800025e2:	8526                	mv	a0,s1
    800025e4:	b2dff0ef          	jal	80002110 <killed>
    800025e8:	c901                	beqz	a0,800025f8 <usertrap+0x8c>
    800025ea:	4901                	li	s2,0
    exit(-1);
    800025ec:	557d                	li	a0,-1
    800025ee:	9f7ff0ef          	jal	80001fe4 <exit>
  if(which_dev == 2)
    800025f2:	4789                	li	a5,2
    800025f4:	04f90563          	beq	s2,a5,8000263e <usertrap+0xd2>
  usertrapret();
    800025f8:	e1bff0ef          	jal	80002412 <usertrapret>
}
    800025fc:	60e2                	ld	ra,24(sp)
    800025fe:	6442                	ld	s0,16(sp)
    80002600:	64a2                	ld	s1,8(sp)
    80002602:	6902                	ld	s2,0(sp)
    80002604:	6105                	addi	sp,sp,32
    80002606:	8082                	ret
      exit(-1);
    80002608:	557d                	li	a0,-1
    8000260a:	9dbff0ef          	jal	80001fe4 <exit>
    8000260e:	bf75                	j	800025ca <usertrap+0x5e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002610:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002614:	5890                	lw	a2,48(s1)
    80002616:	00005517          	auipc	a0,0x5
    8000261a:	e1250513          	addi	a0,a0,-494 # 80007428 <etext+0x428>
    8000261e:	ea5fd0ef          	jal	800004c2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002622:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002626:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    8000262a:	00005517          	auipc	a0,0x5
    8000262e:	e2e50513          	addi	a0,a0,-466 # 80007458 <etext+0x458>
    80002632:	e91fd0ef          	jal	800004c2 <printf>
    setkilled(p);
    80002636:	8526                	mv	a0,s1
    80002638:	ab5ff0ef          	jal	800020ec <setkilled>
    8000263c:	b75d                	j	800025e2 <usertrap+0x76>
    yield();
    8000263e:	86fff0ef          	jal	80001eac <yield>
    80002642:	bf5d                	j	800025f8 <usertrap+0x8c>

0000000080002644 <kerneltrap>:
{
    80002644:	7179                	addi	sp,sp,-48
    80002646:	f406                	sd	ra,40(sp)
    80002648:	f022                	sd	s0,32(sp)
    8000264a:	ec26                	sd	s1,24(sp)
    8000264c:	e84a                	sd	s2,16(sp)
    8000264e:	e44e                	sd	s3,8(sp)
    80002650:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002652:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002656:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000265a:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    8000265e:	1004f793          	andi	a5,s1,256
    80002662:	c795                	beqz	a5,8000268e <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002664:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002668:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    8000266a:	eb85                	bnez	a5,8000269a <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    8000266c:	e8dff0ef          	jal	800024f8 <devintr>
    80002670:	c91d                	beqz	a0,800026a6 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80002672:	4789                	li	a5,2
    80002674:	04f50a63          	beq	a0,a5,800026c8 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002678:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000267c:	10049073          	csrw	sstatus,s1
}
    80002680:	70a2                	ld	ra,40(sp)
    80002682:	7402                	ld	s0,32(sp)
    80002684:	64e2                	ld	s1,24(sp)
    80002686:	6942                	ld	s2,16(sp)
    80002688:	69a2                	ld	s3,8(sp)
    8000268a:	6145                	addi	sp,sp,48
    8000268c:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    8000268e:	00005517          	auipc	a0,0x5
    80002692:	df250513          	addi	a0,a0,-526 # 80007480 <etext+0x480>
    80002696:	8fefe0ef          	jal	80000794 <panic>
    panic("kerneltrap: interrupts enabled");
    8000269a:	00005517          	auipc	a0,0x5
    8000269e:	e0e50513          	addi	a0,a0,-498 # 800074a8 <etext+0x4a8>
    800026a2:	8f2fe0ef          	jal	80000794 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800026a6:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800026aa:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    800026ae:	85ce                	mv	a1,s3
    800026b0:	00005517          	auipc	a0,0x5
    800026b4:	e1850513          	addi	a0,a0,-488 # 800074c8 <etext+0x4c8>
    800026b8:	e0bfd0ef          	jal	800004c2 <printf>
    panic("kerneltrap");
    800026bc:	00005517          	auipc	a0,0x5
    800026c0:	e3450513          	addi	a0,a0,-460 # 800074f0 <etext+0x4f0>
    800026c4:	8d0fe0ef          	jal	80000794 <panic>
  if(which_dev == 2 && myproc() != 0)
    800026c8:	a42ff0ef          	jal	8000190a <myproc>
    800026cc:	d555                	beqz	a0,80002678 <kerneltrap+0x34>
    yield();
    800026ce:	fdeff0ef          	jal	80001eac <yield>
    800026d2:	b75d                	j	80002678 <kerneltrap+0x34>

00000000800026d4 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800026d4:	1101                	addi	sp,sp,-32
    800026d6:	ec06                	sd	ra,24(sp)
    800026d8:	e822                	sd	s0,16(sp)
    800026da:	e426                	sd	s1,8(sp)
    800026dc:	1000                	addi	s0,sp,32
    800026de:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800026e0:	a2aff0ef          	jal	8000190a <myproc>
  switch (n) {
    800026e4:	4795                	li	a5,5
    800026e6:	0497e163          	bltu	a5,s1,80002728 <argraw+0x54>
    800026ea:	048a                	slli	s1,s1,0x2
    800026ec:	00005717          	auipc	a4,0x5
    800026f0:	23c70713          	addi	a4,a4,572 # 80007928 <states.0+0x30>
    800026f4:	94ba                	add	s1,s1,a4
    800026f6:	409c                	lw	a5,0(s1)
    800026f8:	97ba                	add	a5,a5,a4
    800026fa:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800026fc:	6d3c                	ld	a5,88(a0)
    800026fe:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002700:	60e2                	ld	ra,24(sp)
    80002702:	6442                	ld	s0,16(sp)
    80002704:	64a2                	ld	s1,8(sp)
    80002706:	6105                	addi	sp,sp,32
    80002708:	8082                	ret
    return p->trapframe->a1;
    8000270a:	6d3c                	ld	a5,88(a0)
    8000270c:	7fa8                	ld	a0,120(a5)
    8000270e:	bfcd                	j	80002700 <argraw+0x2c>
    return p->trapframe->a2;
    80002710:	6d3c                	ld	a5,88(a0)
    80002712:	63c8                	ld	a0,128(a5)
    80002714:	b7f5                	j	80002700 <argraw+0x2c>
    return p->trapframe->a3;
    80002716:	6d3c                	ld	a5,88(a0)
    80002718:	67c8                	ld	a0,136(a5)
    8000271a:	b7dd                	j	80002700 <argraw+0x2c>
    return p->trapframe->a4;
    8000271c:	6d3c                	ld	a5,88(a0)
    8000271e:	6bc8                	ld	a0,144(a5)
    80002720:	b7c5                	j	80002700 <argraw+0x2c>
    return p->trapframe->a5;
    80002722:	6d3c                	ld	a5,88(a0)
    80002724:	6fc8                	ld	a0,152(a5)
    80002726:	bfe9                	j	80002700 <argraw+0x2c>
  panic("argraw");
    80002728:	00005517          	auipc	a0,0x5
    8000272c:	dd850513          	addi	a0,a0,-552 # 80007500 <etext+0x500>
    80002730:	864fe0ef          	jal	80000794 <panic>

0000000080002734 <fetchaddr>:
{
    80002734:	1101                	addi	sp,sp,-32
    80002736:	ec06                	sd	ra,24(sp)
    80002738:	e822                	sd	s0,16(sp)
    8000273a:	e426                	sd	s1,8(sp)
    8000273c:	e04a                	sd	s2,0(sp)
    8000273e:	1000                	addi	s0,sp,32
    80002740:	84aa                	mv	s1,a0
    80002742:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002744:	9c6ff0ef          	jal	8000190a <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002748:	653c                	ld	a5,72(a0)
    8000274a:	02f4f663          	bgeu	s1,a5,80002776 <fetchaddr+0x42>
    8000274e:	00848713          	addi	a4,s1,8
    80002752:	02e7e463          	bltu	a5,a4,8000277a <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002756:	46a1                	li	a3,8
    80002758:	8626                	mv	a2,s1
    8000275a:	85ca                	mv	a1,s2
    8000275c:	6928                	ld	a0,80(a0)
    8000275e:	ef5fe0ef          	jal	80001652 <copyin>
    80002762:	00a03533          	snez	a0,a0
    80002766:	40a00533          	neg	a0,a0
}
    8000276a:	60e2                	ld	ra,24(sp)
    8000276c:	6442                	ld	s0,16(sp)
    8000276e:	64a2                	ld	s1,8(sp)
    80002770:	6902                	ld	s2,0(sp)
    80002772:	6105                	addi	sp,sp,32
    80002774:	8082                	ret
    return -1;
    80002776:	557d                	li	a0,-1
    80002778:	bfcd                	j	8000276a <fetchaddr+0x36>
    8000277a:	557d                	li	a0,-1
    8000277c:	b7fd                	j	8000276a <fetchaddr+0x36>

000000008000277e <fetchstr>:
{
    8000277e:	7179                	addi	sp,sp,-48
    80002780:	f406                	sd	ra,40(sp)
    80002782:	f022                	sd	s0,32(sp)
    80002784:	ec26                	sd	s1,24(sp)
    80002786:	e84a                	sd	s2,16(sp)
    80002788:	e44e                	sd	s3,8(sp)
    8000278a:	1800                	addi	s0,sp,48
    8000278c:	892a                	mv	s2,a0
    8000278e:	84ae                	mv	s1,a1
    80002790:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002792:	978ff0ef          	jal	8000190a <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002796:	86ce                	mv	a3,s3
    80002798:	864a                	mv	a2,s2
    8000279a:	85a6                	mv	a1,s1
    8000279c:	6928                	ld	a0,80(a0)
    8000279e:	f3bfe0ef          	jal	800016d8 <copyinstr>
    800027a2:	00054c63          	bltz	a0,800027ba <fetchstr+0x3c>
  return strlen(buf);
    800027a6:	8526                	mv	a0,s1
    800027a8:	e90fe0ef          	jal	80000e38 <strlen>
}
    800027ac:	70a2                	ld	ra,40(sp)
    800027ae:	7402                	ld	s0,32(sp)
    800027b0:	64e2                	ld	s1,24(sp)
    800027b2:	6942                	ld	s2,16(sp)
    800027b4:	69a2                	ld	s3,8(sp)
    800027b6:	6145                	addi	sp,sp,48
    800027b8:	8082                	ret
    return -1;
    800027ba:	557d                	li	a0,-1
    800027bc:	bfc5                	j	800027ac <fetchstr+0x2e>

00000000800027be <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    800027be:	1101                	addi	sp,sp,-32
    800027c0:	ec06                	sd	ra,24(sp)
    800027c2:	e822                	sd	s0,16(sp)
    800027c4:	e426                	sd	s1,8(sp)
    800027c6:	1000                	addi	s0,sp,32
    800027c8:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800027ca:	f0bff0ef          	jal	800026d4 <argraw>
    800027ce:	c088                	sw	a0,0(s1)
}
    800027d0:	60e2                	ld	ra,24(sp)
    800027d2:	6442                	ld	s0,16(sp)
    800027d4:	64a2                	ld	s1,8(sp)
    800027d6:	6105                	addi	sp,sp,32
    800027d8:	8082                	ret

00000000800027da <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    800027da:	1101                	addi	sp,sp,-32
    800027dc:	ec06                	sd	ra,24(sp)
    800027de:	e822                	sd	s0,16(sp)
    800027e0:	e426                	sd	s1,8(sp)
    800027e2:	1000                	addi	s0,sp,32
    800027e4:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800027e6:	eefff0ef          	jal	800026d4 <argraw>
    800027ea:	e088                	sd	a0,0(s1)
}
    800027ec:	60e2                	ld	ra,24(sp)
    800027ee:	6442                	ld	s0,16(sp)
    800027f0:	64a2                	ld	s1,8(sp)
    800027f2:	6105                	addi	sp,sp,32
    800027f4:	8082                	ret

00000000800027f6 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800027f6:	7179                	addi	sp,sp,-48
    800027f8:	f406                	sd	ra,40(sp)
    800027fa:	f022                	sd	s0,32(sp)
    800027fc:	ec26                	sd	s1,24(sp)
    800027fe:	e84a                	sd	s2,16(sp)
    80002800:	1800                	addi	s0,sp,48
    80002802:	84ae                	mv	s1,a1
    80002804:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002806:	fd840593          	addi	a1,s0,-40
    8000280a:	fd1ff0ef          	jal	800027da <argaddr>
  return fetchstr(addr, buf, max);
    8000280e:	864a                	mv	a2,s2
    80002810:	85a6                	mv	a1,s1
    80002812:	fd843503          	ld	a0,-40(s0)
    80002816:	f69ff0ef          	jal	8000277e <fetchstr>
}
    8000281a:	70a2                	ld	ra,40(sp)
    8000281c:	7402                	ld	s0,32(sp)
    8000281e:	64e2                	ld	s1,24(sp)
    80002820:	6942                	ld	s2,16(sp)
    80002822:	6145                	addi	sp,sp,48
    80002824:	8082                	ret

0000000080002826 <syscall>:
[SYS_trigger] sys_trigger,
};

void
syscall(void)
{
    80002826:	1101                	addi	sp,sp,-32
    80002828:	ec06                	sd	ra,24(sp)
    8000282a:	e822                	sd	s0,16(sp)
    8000282c:	e426                	sd	s1,8(sp)
    8000282e:	e04a                	sd	s2,0(sp)
    80002830:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002832:	8d8ff0ef          	jal	8000190a <myproc>
    80002836:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002838:	05853903          	ld	s2,88(a0)
    8000283c:	0a893783          	ld	a5,168(s2)
    80002840:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002844:	37fd                	addiw	a5,a5,-1
    80002846:	4755                	li	a4,21
    80002848:	00f76f63          	bltu	a4,a5,80002866 <syscall+0x40>
    8000284c:	00369713          	slli	a4,a3,0x3
    80002850:	00005797          	auipc	a5,0x5
    80002854:	0f078793          	addi	a5,a5,240 # 80007940 <syscalls>
    80002858:	97ba                	add	a5,a5,a4
    8000285a:	639c                	ld	a5,0(a5)
    8000285c:	c789                	beqz	a5,80002866 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    8000285e:	9782                	jalr	a5
    80002860:	06a93823          	sd	a0,112(s2)
    80002864:	a829                	j	8000287e <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002866:	15848613          	addi	a2,s1,344
    8000286a:	588c                	lw	a1,48(s1)
    8000286c:	00005517          	auipc	a0,0x5
    80002870:	c9c50513          	addi	a0,a0,-868 # 80007508 <etext+0x508>
    80002874:	c4ffd0ef          	jal	800004c2 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002878:	6cbc                	ld	a5,88(s1)
    8000287a:	577d                	li	a4,-1
    8000287c:	fbb8                	sd	a4,112(a5)
  }
}
    8000287e:	60e2                	ld	ra,24(sp)
    80002880:	6442                	ld	s0,16(sp)
    80002882:	64a2                	ld	s1,8(sp)
    80002884:	6902                	ld	s2,0(sp)
    80002886:	6105                	addi	sp,sp,32
    80002888:	8082                	ret

000000008000288a <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    8000288a:	1101                	addi	sp,sp,-32
    8000288c:	ec06                	sd	ra,24(sp)
    8000288e:	e822                	sd	s0,16(sp)
    80002890:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002892:	fec40593          	addi	a1,s0,-20
    80002896:	4501                	li	a0,0
    80002898:	f27ff0ef          	jal	800027be <argint>
  exit(n);
    8000289c:	fec42503          	lw	a0,-20(s0)
    800028a0:	f44ff0ef          	jal	80001fe4 <exit>
  return 0;  // not reached
}
    800028a4:	4501                	li	a0,0
    800028a6:	60e2                	ld	ra,24(sp)
    800028a8:	6442                	ld	s0,16(sp)
    800028aa:	6105                	addi	sp,sp,32
    800028ac:	8082                	ret

00000000800028ae <sys_getpid>:

uint64
sys_getpid(void)
{
    800028ae:	1141                	addi	sp,sp,-16
    800028b0:	e406                	sd	ra,8(sp)
    800028b2:	e022                	sd	s0,0(sp)
    800028b4:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800028b6:	854ff0ef          	jal	8000190a <myproc>
}
    800028ba:	5908                	lw	a0,48(a0)
    800028bc:	60a2                	ld	ra,8(sp)
    800028be:	6402                	ld	s0,0(sp)
    800028c0:	0141                	addi	sp,sp,16
    800028c2:	8082                	ret

00000000800028c4 <sys_fork>:

uint64
sys_fork(void)
{
    800028c4:	1141                	addi	sp,sp,-16
    800028c6:	e406                	sd	ra,8(sp)
    800028c8:	e022                	sd	s0,0(sp)
    800028ca:	0800                	addi	s0,sp,16
  return fork();
    800028cc:	b64ff0ef          	jal	80001c30 <fork>
}
    800028d0:	60a2                	ld	ra,8(sp)
    800028d2:	6402                	ld	s0,0(sp)
    800028d4:	0141                	addi	sp,sp,16
    800028d6:	8082                	ret

00000000800028d8 <sys_trigger>:

uint64
sys_trigger(void)
{
    800028d8:	1141                	addi	sp,sp,-16
    800028da:	e406                	sd	ra,8(sp)
    800028dc:	e022                	sd	s0,0(sp)
    800028de:	0800                	addi	s0,sp,16
    printf("INFO − This is a log to test a new xv6 system call\n");
    800028e0:	00005517          	auipc	a0,0x5
    800028e4:	c4850513          	addi	a0,a0,-952 # 80007528 <etext+0x528>
    800028e8:	bdbfd0ef          	jal	800004c2 <printf>
    return 0;
}
    800028ec:	4501                	li	a0,0
    800028ee:	60a2                	ld	ra,8(sp)
    800028f0:	6402                	ld	s0,0(sp)
    800028f2:	0141                	addi	sp,sp,16
    800028f4:	8082                	ret

00000000800028f6 <sys_wait>:

uint64
sys_wait(void)
{
    800028f6:	1101                	addi	sp,sp,-32
    800028f8:	ec06                	sd	ra,24(sp)
    800028fa:	e822                	sd	s0,16(sp)
    800028fc:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800028fe:	fe840593          	addi	a1,s0,-24
    80002902:	4501                	li	a0,0
    80002904:	ed7ff0ef          	jal	800027da <argaddr>
  return wait(p);
    80002908:	fe843503          	ld	a0,-24(s0)
    8000290c:	82fff0ef          	jal	8000213a <wait>
}
    80002910:	60e2                	ld	ra,24(sp)
    80002912:	6442                	ld	s0,16(sp)
    80002914:	6105                	addi	sp,sp,32
    80002916:	8082                	ret

0000000080002918 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002918:	7179                	addi	sp,sp,-48
    8000291a:	f406                	sd	ra,40(sp)
    8000291c:	f022                	sd	s0,32(sp)
    8000291e:	ec26                	sd	s1,24(sp)
    80002920:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002922:	fdc40593          	addi	a1,s0,-36
    80002926:	4501                	li	a0,0
    80002928:	e97ff0ef          	jal	800027be <argint>
  addr = myproc()->sz;
    8000292c:	fdffe0ef          	jal	8000190a <myproc>
    80002930:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002932:	fdc42503          	lw	a0,-36(s0)
    80002936:	aaaff0ef          	jal	80001be0 <growproc>
    8000293a:	00054863          	bltz	a0,8000294a <sys_sbrk+0x32>
    return -1;
  return addr;
}
    8000293e:	8526                	mv	a0,s1
    80002940:	70a2                	ld	ra,40(sp)
    80002942:	7402                	ld	s0,32(sp)
    80002944:	64e2                	ld	s1,24(sp)
    80002946:	6145                	addi	sp,sp,48
    80002948:	8082                	ret
    return -1;
    8000294a:	54fd                	li	s1,-1
    8000294c:	bfcd                	j	8000293e <sys_sbrk+0x26>

000000008000294e <sys_sleep>:

uint64
sys_sleep(void)
{
    8000294e:	7139                	addi	sp,sp,-64
    80002950:	fc06                	sd	ra,56(sp)
    80002952:	f822                	sd	s0,48(sp)
    80002954:	f04a                	sd	s2,32(sp)
    80002956:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002958:	fcc40593          	addi	a1,s0,-52
    8000295c:	4501                	li	a0,0
    8000295e:	e61ff0ef          	jal	800027be <argint>
  if(n < 0)
    80002962:	fcc42783          	lw	a5,-52(s0)
    80002966:	0607c763          	bltz	a5,800029d4 <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    8000296a:	00013517          	auipc	a0,0x13
    8000296e:	07650513          	addi	a0,a0,118 # 800159e0 <tickslock>
    80002972:	a82fe0ef          	jal	80000bf4 <acquire>
  ticks0 = ticks;
    80002976:	00005917          	auipc	s2,0x5
    8000297a:	10a92903          	lw	s2,266(s2) # 80007a80 <ticks>
  while(ticks - ticks0 < n){
    8000297e:	fcc42783          	lw	a5,-52(s0)
    80002982:	cf8d                	beqz	a5,800029bc <sys_sleep+0x6e>
    80002984:	f426                	sd	s1,40(sp)
    80002986:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002988:	00013997          	auipc	s3,0x13
    8000298c:	05898993          	addi	s3,s3,88 # 800159e0 <tickslock>
    80002990:	00005497          	auipc	s1,0x5
    80002994:	0f048493          	addi	s1,s1,240 # 80007a80 <ticks>
    if(killed(myproc())){
    80002998:	f73fe0ef          	jal	8000190a <myproc>
    8000299c:	f74ff0ef          	jal	80002110 <killed>
    800029a0:	ed0d                	bnez	a0,800029da <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    800029a2:	85ce                	mv	a1,s3
    800029a4:	8526                	mv	a0,s1
    800029a6:	d32ff0ef          	jal	80001ed8 <sleep>
  while(ticks - ticks0 < n){
    800029aa:	409c                	lw	a5,0(s1)
    800029ac:	412787bb          	subw	a5,a5,s2
    800029b0:	fcc42703          	lw	a4,-52(s0)
    800029b4:	fee7e2e3          	bltu	a5,a4,80002998 <sys_sleep+0x4a>
    800029b8:	74a2                	ld	s1,40(sp)
    800029ba:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    800029bc:	00013517          	auipc	a0,0x13
    800029c0:	02450513          	addi	a0,a0,36 # 800159e0 <tickslock>
    800029c4:	ac8fe0ef          	jal	80000c8c <release>
  return 0;
    800029c8:	4501                	li	a0,0
}
    800029ca:	70e2                	ld	ra,56(sp)
    800029cc:	7442                	ld	s0,48(sp)
    800029ce:	7902                	ld	s2,32(sp)
    800029d0:	6121                	addi	sp,sp,64
    800029d2:	8082                	ret
    n = 0;
    800029d4:	fc042623          	sw	zero,-52(s0)
    800029d8:	bf49                	j	8000296a <sys_sleep+0x1c>
      release(&tickslock);
    800029da:	00013517          	auipc	a0,0x13
    800029de:	00650513          	addi	a0,a0,6 # 800159e0 <tickslock>
    800029e2:	aaafe0ef          	jal	80000c8c <release>
      return -1;
    800029e6:	557d                	li	a0,-1
    800029e8:	74a2                	ld	s1,40(sp)
    800029ea:	69e2                	ld	s3,24(sp)
    800029ec:	bff9                	j	800029ca <sys_sleep+0x7c>

00000000800029ee <sys_kill>:

uint64
sys_kill(void)
{
    800029ee:	1101                	addi	sp,sp,-32
    800029f0:	ec06                	sd	ra,24(sp)
    800029f2:	e822                	sd	s0,16(sp)
    800029f4:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    800029f6:	fec40593          	addi	a1,s0,-20
    800029fa:	4501                	li	a0,0
    800029fc:	dc3ff0ef          	jal	800027be <argint>
  return kill(pid);
    80002a00:	fec42503          	lw	a0,-20(s0)
    80002a04:	e82ff0ef          	jal	80002086 <kill>
}
    80002a08:	60e2                	ld	ra,24(sp)
    80002a0a:	6442                	ld	s0,16(sp)
    80002a0c:	6105                	addi	sp,sp,32
    80002a0e:	8082                	ret

0000000080002a10 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002a10:	1101                	addi	sp,sp,-32
    80002a12:	ec06                	sd	ra,24(sp)
    80002a14:	e822                	sd	s0,16(sp)
    80002a16:	e426                	sd	s1,8(sp)
    80002a18:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002a1a:	00013517          	auipc	a0,0x13
    80002a1e:	fc650513          	addi	a0,a0,-58 # 800159e0 <tickslock>
    80002a22:	9d2fe0ef          	jal	80000bf4 <acquire>
  xticks = ticks;
    80002a26:	00005497          	auipc	s1,0x5
    80002a2a:	05a4a483          	lw	s1,90(s1) # 80007a80 <ticks>
  release(&tickslock);
    80002a2e:	00013517          	auipc	a0,0x13
    80002a32:	fb250513          	addi	a0,a0,-78 # 800159e0 <tickslock>
    80002a36:	a56fe0ef          	jal	80000c8c <release>
  return xticks;
}
    80002a3a:	02049513          	slli	a0,s1,0x20
    80002a3e:	9101                	srli	a0,a0,0x20
    80002a40:	60e2                	ld	ra,24(sp)
    80002a42:	6442                	ld	s0,16(sp)
    80002a44:	64a2                	ld	s1,8(sp)
    80002a46:	6105                	addi	sp,sp,32
    80002a48:	8082                	ret

0000000080002a4a <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002a4a:	7179                	addi	sp,sp,-48
    80002a4c:	f406                	sd	ra,40(sp)
    80002a4e:	f022                	sd	s0,32(sp)
    80002a50:	ec26                	sd	s1,24(sp)
    80002a52:	e84a                	sd	s2,16(sp)
    80002a54:	e44e                	sd	s3,8(sp)
    80002a56:	e052                	sd	s4,0(sp)
    80002a58:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002a5a:	00005597          	auipc	a1,0x5
    80002a5e:	b0658593          	addi	a1,a1,-1274 # 80007560 <etext+0x560>
    80002a62:	00013517          	auipc	a0,0x13
    80002a66:	f9650513          	addi	a0,a0,-106 # 800159f8 <bcache>
    80002a6a:	90afe0ef          	jal	80000b74 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002a6e:	0001b797          	auipc	a5,0x1b
    80002a72:	f8a78793          	addi	a5,a5,-118 # 8001d9f8 <bcache+0x8000>
    80002a76:	0001b717          	auipc	a4,0x1b
    80002a7a:	1ea70713          	addi	a4,a4,490 # 8001dc60 <bcache+0x8268>
    80002a7e:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002a82:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002a86:	00013497          	auipc	s1,0x13
    80002a8a:	f8a48493          	addi	s1,s1,-118 # 80015a10 <bcache+0x18>
    b->next = bcache.head.next;
    80002a8e:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002a90:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002a92:	00005a17          	auipc	s4,0x5
    80002a96:	ad6a0a13          	addi	s4,s4,-1322 # 80007568 <etext+0x568>
    b->next = bcache.head.next;
    80002a9a:	2b893783          	ld	a5,696(s2)
    80002a9e:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002aa0:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002aa4:	85d2                	mv	a1,s4
    80002aa6:	01048513          	addi	a0,s1,16
    80002aaa:	29c010ef          	jal	80003d46 <initsleeplock>
    bcache.head.next->prev = b;
    80002aae:	2b893783          	ld	a5,696(s2)
    80002ab2:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002ab4:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002ab8:	45848493          	addi	s1,s1,1112
    80002abc:	fd349fe3          	bne	s1,s3,80002a9a <binit+0x50>
  }
}
    80002ac0:	70a2                	ld	ra,40(sp)
    80002ac2:	7402                	ld	s0,32(sp)
    80002ac4:	64e2                	ld	s1,24(sp)
    80002ac6:	6942                	ld	s2,16(sp)
    80002ac8:	69a2                	ld	s3,8(sp)
    80002aca:	6a02                	ld	s4,0(sp)
    80002acc:	6145                	addi	sp,sp,48
    80002ace:	8082                	ret

0000000080002ad0 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002ad0:	7179                	addi	sp,sp,-48
    80002ad2:	f406                	sd	ra,40(sp)
    80002ad4:	f022                	sd	s0,32(sp)
    80002ad6:	ec26                	sd	s1,24(sp)
    80002ad8:	e84a                	sd	s2,16(sp)
    80002ada:	e44e                	sd	s3,8(sp)
    80002adc:	1800                	addi	s0,sp,48
    80002ade:	892a                	mv	s2,a0
    80002ae0:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002ae2:	00013517          	auipc	a0,0x13
    80002ae6:	f1650513          	addi	a0,a0,-234 # 800159f8 <bcache>
    80002aea:	90afe0ef          	jal	80000bf4 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002aee:	0001b497          	auipc	s1,0x1b
    80002af2:	1c24b483          	ld	s1,450(s1) # 8001dcb0 <bcache+0x82b8>
    80002af6:	0001b797          	auipc	a5,0x1b
    80002afa:	16a78793          	addi	a5,a5,362 # 8001dc60 <bcache+0x8268>
    80002afe:	02f48b63          	beq	s1,a5,80002b34 <bread+0x64>
    80002b02:	873e                	mv	a4,a5
    80002b04:	a021                	j	80002b0c <bread+0x3c>
    80002b06:	68a4                	ld	s1,80(s1)
    80002b08:	02e48663          	beq	s1,a4,80002b34 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002b0c:	449c                	lw	a5,8(s1)
    80002b0e:	ff279ce3          	bne	a5,s2,80002b06 <bread+0x36>
    80002b12:	44dc                	lw	a5,12(s1)
    80002b14:	ff3799e3          	bne	a5,s3,80002b06 <bread+0x36>
      b->refcnt++;
    80002b18:	40bc                	lw	a5,64(s1)
    80002b1a:	2785                	addiw	a5,a5,1
    80002b1c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002b1e:	00013517          	auipc	a0,0x13
    80002b22:	eda50513          	addi	a0,a0,-294 # 800159f8 <bcache>
    80002b26:	966fe0ef          	jal	80000c8c <release>
      acquiresleep(&b->lock);
    80002b2a:	01048513          	addi	a0,s1,16
    80002b2e:	24e010ef          	jal	80003d7c <acquiresleep>
      return b;
    80002b32:	a889                	j	80002b84 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002b34:	0001b497          	auipc	s1,0x1b
    80002b38:	1744b483          	ld	s1,372(s1) # 8001dca8 <bcache+0x82b0>
    80002b3c:	0001b797          	auipc	a5,0x1b
    80002b40:	12478793          	addi	a5,a5,292 # 8001dc60 <bcache+0x8268>
    80002b44:	00f48863          	beq	s1,a5,80002b54 <bread+0x84>
    80002b48:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002b4a:	40bc                	lw	a5,64(s1)
    80002b4c:	cb91                	beqz	a5,80002b60 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002b4e:	64a4                	ld	s1,72(s1)
    80002b50:	fee49de3          	bne	s1,a4,80002b4a <bread+0x7a>
  panic("bget: no buffers");
    80002b54:	00005517          	auipc	a0,0x5
    80002b58:	a1c50513          	addi	a0,a0,-1508 # 80007570 <etext+0x570>
    80002b5c:	c39fd0ef          	jal	80000794 <panic>
      b->dev = dev;
    80002b60:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002b64:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002b68:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002b6c:	4785                	li	a5,1
    80002b6e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002b70:	00013517          	auipc	a0,0x13
    80002b74:	e8850513          	addi	a0,a0,-376 # 800159f8 <bcache>
    80002b78:	914fe0ef          	jal	80000c8c <release>
      acquiresleep(&b->lock);
    80002b7c:	01048513          	addi	a0,s1,16
    80002b80:	1fc010ef          	jal	80003d7c <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002b84:	409c                	lw	a5,0(s1)
    80002b86:	cb89                	beqz	a5,80002b98 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002b88:	8526                	mv	a0,s1
    80002b8a:	70a2                	ld	ra,40(sp)
    80002b8c:	7402                	ld	s0,32(sp)
    80002b8e:	64e2                	ld	s1,24(sp)
    80002b90:	6942                	ld	s2,16(sp)
    80002b92:	69a2                	ld	s3,8(sp)
    80002b94:	6145                	addi	sp,sp,48
    80002b96:	8082                	ret
    virtio_disk_rw(b, 0);
    80002b98:	4581                	li	a1,0
    80002b9a:	8526                	mv	a0,s1
    80002b9c:	245020ef          	jal	800055e0 <virtio_disk_rw>
    b->valid = 1;
    80002ba0:	4785                	li	a5,1
    80002ba2:	c09c                	sw	a5,0(s1)
  return b;
    80002ba4:	b7d5                	j	80002b88 <bread+0xb8>

0000000080002ba6 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002ba6:	1101                	addi	sp,sp,-32
    80002ba8:	ec06                	sd	ra,24(sp)
    80002baa:	e822                	sd	s0,16(sp)
    80002bac:	e426                	sd	s1,8(sp)
    80002bae:	1000                	addi	s0,sp,32
    80002bb0:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002bb2:	0541                	addi	a0,a0,16
    80002bb4:	246010ef          	jal	80003dfa <holdingsleep>
    80002bb8:	c911                	beqz	a0,80002bcc <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002bba:	4585                	li	a1,1
    80002bbc:	8526                	mv	a0,s1
    80002bbe:	223020ef          	jal	800055e0 <virtio_disk_rw>
}
    80002bc2:	60e2                	ld	ra,24(sp)
    80002bc4:	6442                	ld	s0,16(sp)
    80002bc6:	64a2                	ld	s1,8(sp)
    80002bc8:	6105                	addi	sp,sp,32
    80002bca:	8082                	ret
    panic("bwrite");
    80002bcc:	00005517          	auipc	a0,0x5
    80002bd0:	9bc50513          	addi	a0,a0,-1604 # 80007588 <etext+0x588>
    80002bd4:	bc1fd0ef          	jal	80000794 <panic>

0000000080002bd8 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002bd8:	1101                	addi	sp,sp,-32
    80002bda:	ec06                	sd	ra,24(sp)
    80002bdc:	e822                	sd	s0,16(sp)
    80002bde:	e426                	sd	s1,8(sp)
    80002be0:	e04a                	sd	s2,0(sp)
    80002be2:	1000                	addi	s0,sp,32
    80002be4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002be6:	01050913          	addi	s2,a0,16
    80002bea:	854a                	mv	a0,s2
    80002bec:	20e010ef          	jal	80003dfa <holdingsleep>
    80002bf0:	c135                	beqz	a0,80002c54 <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    80002bf2:	854a                	mv	a0,s2
    80002bf4:	1ce010ef          	jal	80003dc2 <releasesleep>

  acquire(&bcache.lock);
    80002bf8:	00013517          	auipc	a0,0x13
    80002bfc:	e0050513          	addi	a0,a0,-512 # 800159f8 <bcache>
    80002c00:	ff5fd0ef          	jal	80000bf4 <acquire>
  b->refcnt--;
    80002c04:	40bc                	lw	a5,64(s1)
    80002c06:	37fd                	addiw	a5,a5,-1
    80002c08:	0007871b          	sext.w	a4,a5
    80002c0c:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002c0e:	e71d                	bnez	a4,80002c3c <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002c10:	68b8                	ld	a4,80(s1)
    80002c12:	64bc                	ld	a5,72(s1)
    80002c14:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002c16:	68b8                	ld	a4,80(s1)
    80002c18:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002c1a:	0001b797          	auipc	a5,0x1b
    80002c1e:	dde78793          	addi	a5,a5,-546 # 8001d9f8 <bcache+0x8000>
    80002c22:	2b87b703          	ld	a4,696(a5)
    80002c26:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002c28:	0001b717          	auipc	a4,0x1b
    80002c2c:	03870713          	addi	a4,a4,56 # 8001dc60 <bcache+0x8268>
    80002c30:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002c32:	2b87b703          	ld	a4,696(a5)
    80002c36:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002c38:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002c3c:	00013517          	auipc	a0,0x13
    80002c40:	dbc50513          	addi	a0,a0,-580 # 800159f8 <bcache>
    80002c44:	848fe0ef          	jal	80000c8c <release>
}
    80002c48:	60e2                	ld	ra,24(sp)
    80002c4a:	6442                	ld	s0,16(sp)
    80002c4c:	64a2                	ld	s1,8(sp)
    80002c4e:	6902                	ld	s2,0(sp)
    80002c50:	6105                	addi	sp,sp,32
    80002c52:	8082                	ret
    panic("brelse");
    80002c54:	00005517          	auipc	a0,0x5
    80002c58:	93c50513          	addi	a0,a0,-1732 # 80007590 <etext+0x590>
    80002c5c:	b39fd0ef          	jal	80000794 <panic>

0000000080002c60 <bpin>:

void
bpin(struct buf *b) {
    80002c60:	1101                	addi	sp,sp,-32
    80002c62:	ec06                	sd	ra,24(sp)
    80002c64:	e822                	sd	s0,16(sp)
    80002c66:	e426                	sd	s1,8(sp)
    80002c68:	1000                	addi	s0,sp,32
    80002c6a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002c6c:	00013517          	auipc	a0,0x13
    80002c70:	d8c50513          	addi	a0,a0,-628 # 800159f8 <bcache>
    80002c74:	f81fd0ef          	jal	80000bf4 <acquire>
  b->refcnt++;
    80002c78:	40bc                	lw	a5,64(s1)
    80002c7a:	2785                	addiw	a5,a5,1
    80002c7c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002c7e:	00013517          	auipc	a0,0x13
    80002c82:	d7a50513          	addi	a0,a0,-646 # 800159f8 <bcache>
    80002c86:	806fe0ef          	jal	80000c8c <release>
}
    80002c8a:	60e2                	ld	ra,24(sp)
    80002c8c:	6442                	ld	s0,16(sp)
    80002c8e:	64a2                	ld	s1,8(sp)
    80002c90:	6105                	addi	sp,sp,32
    80002c92:	8082                	ret

0000000080002c94 <bunpin>:

void
bunpin(struct buf *b) {
    80002c94:	1101                	addi	sp,sp,-32
    80002c96:	ec06                	sd	ra,24(sp)
    80002c98:	e822                	sd	s0,16(sp)
    80002c9a:	e426                	sd	s1,8(sp)
    80002c9c:	1000                	addi	s0,sp,32
    80002c9e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002ca0:	00013517          	auipc	a0,0x13
    80002ca4:	d5850513          	addi	a0,a0,-680 # 800159f8 <bcache>
    80002ca8:	f4dfd0ef          	jal	80000bf4 <acquire>
  b->refcnt--;
    80002cac:	40bc                	lw	a5,64(s1)
    80002cae:	37fd                	addiw	a5,a5,-1
    80002cb0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002cb2:	00013517          	auipc	a0,0x13
    80002cb6:	d4650513          	addi	a0,a0,-698 # 800159f8 <bcache>
    80002cba:	fd3fd0ef          	jal	80000c8c <release>
}
    80002cbe:	60e2                	ld	ra,24(sp)
    80002cc0:	6442                	ld	s0,16(sp)
    80002cc2:	64a2                	ld	s1,8(sp)
    80002cc4:	6105                	addi	sp,sp,32
    80002cc6:	8082                	ret

0000000080002cc8 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002cc8:	1101                	addi	sp,sp,-32
    80002cca:	ec06                	sd	ra,24(sp)
    80002ccc:	e822                	sd	s0,16(sp)
    80002cce:	e426                	sd	s1,8(sp)
    80002cd0:	e04a                	sd	s2,0(sp)
    80002cd2:	1000                	addi	s0,sp,32
    80002cd4:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002cd6:	00d5d59b          	srliw	a1,a1,0xd
    80002cda:	0001b797          	auipc	a5,0x1b
    80002cde:	3fa7a783          	lw	a5,1018(a5) # 8001e0d4 <sb+0x1c>
    80002ce2:	9dbd                	addw	a1,a1,a5
    80002ce4:	dedff0ef          	jal	80002ad0 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002ce8:	0074f713          	andi	a4,s1,7
    80002cec:	4785                	li	a5,1
    80002cee:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002cf2:	14ce                	slli	s1,s1,0x33
    80002cf4:	90d9                	srli	s1,s1,0x36
    80002cf6:	00950733          	add	a4,a0,s1
    80002cfa:	05874703          	lbu	a4,88(a4)
    80002cfe:	00e7f6b3          	and	a3,a5,a4
    80002d02:	c29d                	beqz	a3,80002d28 <bfree+0x60>
    80002d04:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002d06:	94aa                	add	s1,s1,a0
    80002d08:	fff7c793          	not	a5,a5
    80002d0c:	8f7d                	and	a4,a4,a5
    80002d0e:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002d12:	711000ef          	jal	80003c22 <log_write>
  brelse(bp);
    80002d16:	854a                	mv	a0,s2
    80002d18:	ec1ff0ef          	jal	80002bd8 <brelse>
}
    80002d1c:	60e2                	ld	ra,24(sp)
    80002d1e:	6442                	ld	s0,16(sp)
    80002d20:	64a2                	ld	s1,8(sp)
    80002d22:	6902                	ld	s2,0(sp)
    80002d24:	6105                	addi	sp,sp,32
    80002d26:	8082                	ret
    panic("freeing free block");
    80002d28:	00005517          	auipc	a0,0x5
    80002d2c:	87050513          	addi	a0,a0,-1936 # 80007598 <etext+0x598>
    80002d30:	a65fd0ef          	jal	80000794 <panic>

0000000080002d34 <balloc>:
{
    80002d34:	711d                	addi	sp,sp,-96
    80002d36:	ec86                	sd	ra,88(sp)
    80002d38:	e8a2                	sd	s0,80(sp)
    80002d3a:	e4a6                	sd	s1,72(sp)
    80002d3c:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002d3e:	0001b797          	auipc	a5,0x1b
    80002d42:	37e7a783          	lw	a5,894(a5) # 8001e0bc <sb+0x4>
    80002d46:	0e078f63          	beqz	a5,80002e44 <balloc+0x110>
    80002d4a:	e0ca                	sd	s2,64(sp)
    80002d4c:	fc4e                	sd	s3,56(sp)
    80002d4e:	f852                	sd	s4,48(sp)
    80002d50:	f456                	sd	s5,40(sp)
    80002d52:	f05a                	sd	s6,32(sp)
    80002d54:	ec5e                	sd	s7,24(sp)
    80002d56:	e862                	sd	s8,16(sp)
    80002d58:	e466                	sd	s9,8(sp)
    80002d5a:	8baa                	mv	s7,a0
    80002d5c:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002d5e:	0001bb17          	auipc	s6,0x1b
    80002d62:	35ab0b13          	addi	s6,s6,858 # 8001e0b8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002d66:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002d68:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002d6a:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002d6c:	6c89                	lui	s9,0x2
    80002d6e:	a0b5                	j	80002dda <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002d70:	97ca                	add	a5,a5,s2
    80002d72:	8e55                	or	a2,a2,a3
    80002d74:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002d78:	854a                	mv	a0,s2
    80002d7a:	6a9000ef          	jal	80003c22 <log_write>
        brelse(bp);
    80002d7e:	854a                	mv	a0,s2
    80002d80:	e59ff0ef          	jal	80002bd8 <brelse>
  bp = bread(dev, bno);
    80002d84:	85a6                	mv	a1,s1
    80002d86:	855e                	mv	a0,s7
    80002d88:	d49ff0ef          	jal	80002ad0 <bread>
    80002d8c:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002d8e:	40000613          	li	a2,1024
    80002d92:	4581                	li	a1,0
    80002d94:	05850513          	addi	a0,a0,88
    80002d98:	f31fd0ef          	jal	80000cc8 <memset>
  log_write(bp);
    80002d9c:	854a                	mv	a0,s2
    80002d9e:	685000ef          	jal	80003c22 <log_write>
  brelse(bp);
    80002da2:	854a                	mv	a0,s2
    80002da4:	e35ff0ef          	jal	80002bd8 <brelse>
}
    80002da8:	6906                	ld	s2,64(sp)
    80002daa:	79e2                	ld	s3,56(sp)
    80002dac:	7a42                	ld	s4,48(sp)
    80002dae:	7aa2                	ld	s5,40(sp)
    80002db0:	7b02                	ld	s6,32(sp)
    80002db2:	6be2                	ld	s7,24(sp)
    80002db4:	6c42                	ld	s8,16(sp)
    80002db6:	6ca2                	ld	s9,8(sp)
}
    80002db8:	8526                	mv	a0,s1
    80002dba:	60e6                	ld	ra,88(sp)
    80002dbc:	6446                	ld	s0,80(sp)
    80002dbe:	64a6                	ld	s1,72(sp)
    80002dc0:	6125                	addi	sp,sp,96
    80002dc2:	8082                	ret
    brelse(bp);
    80002dc4:	854a                	mv	a0,s2
    80002dc6:	e13ff0ef          	jal	80002bd8 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002dca:	015c87bb          	addw	a5,s9,s5
    80002dce:	00078a9b          	sext.w	s5,a5
    80002dd2:	004b2703          	lw	a4,4(s6)
    80002dd6:	04eaff63          	bgeu	s5,a4,80002e34 <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    80002dda:	41fad79b          	sraiw	a5,s5,0x1f
    80002dde:	0137d79b          	srliw	a5,a5,0x13
    80002de2:	015787bb          	addw	a5,a5,s5
    80002de6:	40d7d79b          	sraiw	a5,a5,0xd
    80002dea:	01cb2583          	lw	a1,28(s6)
    80002dee:	9dbd                	addw	a1,a1,a5
    80002df0:	855e                	mv	a0,s7
    80002df2:	cdfff0ef          	jal	80002ad0 <bread>
    80002df6:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002df8:	004b2503          	lw	a0,4(s6)
    80002dfc:	000a849b          	sext.w	s1,s5
    80002e00:	8762                	mv	a4,s8
    80002e02:	fca4f1e3          	bgeu	s1,a0,80002dc4 <balloc+0x90>
      m = 1 << (bi % 8);
    80002e06:	00777693          	andi	a3,a4,7
    80002e0a:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002e0e:	41f7579b          	sraiw	a5,a4,0x1f
    80002e12:	01d7d79b          	srliw	a5,a5,0x1d
    80002e16:	9fb9                	addw	a5,a5,a4
    80002e18:	4037d79b          	sraiw	a5,a5,0x3
    80002e1c:	00f90633          	add	a2,s2,a5
    80002e20:	05864603          	lbu	a2,88(a2)
    80002e24:	00c6f5b3          	and	a1,a3,a2
    80002e28:	d5a1                	beqz	a1,80002d70 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002e2a:	2705                	addiw	a4,a4,1
    80002e2c:	2485                	addiw	s1,s1,1
    80002e2e:	fd471ae3          	bne	a4,s4,80002e02 <balloc+0xce>
    80002e32:	bf49                	j	80002dc4 <balloc+0x90>
    80002e34:	6906                	ld	s2,64(sp)
    80002e36:	79e2                	ld	s3,56(sp)
    80002e38:	7a42                	ld	s4,48(sp)
    80002e3a:	7aa2                	ld	s5,40(sp)
    80002e3c:	7b02                	ld	s6,32(sp)
    80002e3e:	6be2                	ld	s7,24(sp)
    80002e40:	6c42                	ld	s8,16(sp)
    80002e42:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    80002e44:	00004517          	auipc	a0,0x4
    80002e48:	76c50513          	addi	a0,a0,1900 # 800075b0 <etext+0x5b0>
    80002e4c:	e76fd0ef          	jal	800004c2 <printf>
  return 0;
    80002e50:	4481                	li	s1,0
    80002e52:	b79d                	j	80002db8 <balloc+0x84>

0000000080002e54 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002e54:	7179                	addi	sp,sp,-48
    80002e56:	f406                	sd	ra,40(sp)
    80002e58:	f022                	sd	s0,32(sp)
    80002e5a:	ec26                	sd	s1,24(sp)
    80002e5c:	e84a                	sd	s2,16(sp)
    80002e5e:	e44e                	sd	s3,8(sp)
    80002e60:	1800                	addi	s0,sp,48
    80002e62:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002e64:	47ad                	li	a5,11
    80002e66:	02b7e663          	bltu	a5,a1,80002e92 <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80002e6a:	02059793          	slli	a5,a1,0x20
    80002e6e:	01e7d593          	srli	a1,a5,0x1e
    80002e72:	00b504b3          	add	s1,a0,a1
    80002e76:	0504a903          	lw	s2,80(s1)
    80002e7a:	06091a63          	bnez	s2,80002eee <bmap+0x9a>
      addr = balloc(ip->dev);
    80002e7e:	4108                	lw	a0,0(a0)
    80002e80:	eb5ff0ef          	jal	80002d34 <balloc>
    80002e84:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002e88:	06090363          	beqz	s2,80002eee <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    80002e8c:	0524a823          	sw	s2,80(s1)
    80002e90:	a8b9                	j	80002eee <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002e92:	ff45849b          	addiw	s1,a1,-12
    80002e96:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80002e9a:	0ff00793          	li	a5,255
    80002e9e:	06e7ee63          	bltu	a5,a4,80002f1a <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80002ea2:	08052903          	lw	s2,128(a0)
    80002ea6:	00091d63          	bnez	s2,80002ec0 <bmap+0x6c>
      addr = balloc(ip->dev);
    80002eaa:	4108                	lw	a0,0(a0)
    80002eac:	e89ff0ef          	jal	80002d34 <balloc>
    80002eb0:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002eb4:	02090d63          	beqz	s2,80002eee <bmap+0x9a>
    80002eb8:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002eba:	0929a023          	sw	s2,128(s3)
    80002ebe:	a011                	j	80002ec2 <bmap+0x6e>
    80002ec0:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80002ec2:	85ca                	mv	a1,s2
    80002ec4:	0009a503          	lw	a0,0(s3)
    80002ec8:	c09ff0ef          	jal	80002ad0 <bread>
    80002ecc:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002ece:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80002ed2:	02049713          	slli	a4,s1,0x20
    80002ed6:	01e75593          	srli	a1,a4,0x1e
    80002eda:	00b784b3          	add	s1,a5,a1
    80002ede:	0004a903          	lw	s2,0(s1)
    80002ee2:	00090e63          	beqz	s2,80002efe <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002ee6:	8552                	mv	a0,s4
    80002ee8:	cf1ff0ef          	jal	80002bd8 <brelse>
    return addr;
    80002eec:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80002eee:	854a                	mv	a0,s2
    80002ef0:	70a2                	ld	ra,40(sp)
    80002ef2:	7402                	ld	s0,32(sp)
    80002ef4:	64e2                	ld	s1,24(sp)
    80002ef6:	6942                	ld	s2,16(sp)
    80002ef8:	69a2                	ld	s3,8(sp)
    80002efa:	6145                	addi	sp,sp,48
    80002efc:	8082                	ret
      addr = balloc(ip->dev);
    80002efe:	0009a503          	lw	a0,0(s3)
    80002f02:	e33ff0ef          	jal	80002d34 <balloc>
    80002f06:	0005091b          	sext.w	s2,a0
      if(addr){
    80002f0a:	fc090ee3          	beqz	s2,80002ee6 <bmap+0x92>
        a[bn] = addr;
    80002f0e:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80002f12:	8552                	mv	a0,s4
    80002f14:	50f000ef          	jal	80003c22 <log_write>
    80002f18:	b7f9                	j	80002ee6 <bmap+0x92>
    80002f1a:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80002f1c:	00004517          	auipc	a0,0x4
    80002f20:	6ac50513          	addi	a0,a0,1708 # 800075c8 <etext+0x5c8>
    80002f24:	871fd0ef          	jal	80000794 <panic>

0000000080002f28 <iget>:
{
    80002f28:	7179                	addi	sp,sp,-48
    80002f2a:	f406                	sd	ra,40(sp)
    80002f2c:	f022                	sd	s0,32(sp)
    80002f2e:	ec26                	sd	s1,24(sp)
    80002f30:	e84a                	sd	s2,16(sp)
    80002f32:	e44e                	sd	s3,8(sp)
    80002f34:	e052                	sd	s4,0(sp)
    80002f36:	1800                	addi	s0,sp,48
    80002f38:	89aa                	mv	s3,a0
    80002f3a:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80002f3c:	0001b517          	auipc	a0,0x1b
    80002f40:	19c50513          	addi	a0,a0,412 # 8001e0d8 <itable>
    80002f44:	cb1fd0ef          	jal	80000bf4 <acquire>
  empty = 0;
    80002f48:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002f4a:	0001b497          	auipc	s1,0x1b
    80002f4e:	1a648493          	addi	s1,s1,422 # 8001e0f0 <itable+0x18>
    80002f52:	0001d697          	auipc	a3,0x1d
    80002f56:	c2e68693          	addi	a3,a3,-978 # 8001fb80 <log>
    80002f5a:	a039                	j	80002f68 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002f5c:	02090963          	beqz	s2,80002f8e <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002f60:	08848493          	addi	s1,s1,136
    80002f64:	02d48863          	beq	s1,a3,80002f94 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80002f68:	449c                	lw	a5,8(s1)
    80002f6a:	fef059e3          	blez	a5,80002f5c <iget+0x34>
    80002f6e:	4098                	lw	a4,0(s1)
    80002f70:	ff3716e3          	bne	a4,s3,80002f5c <iget+0x34>
    80002f74:	40d8                	lw	a4,4(s1)
    80002f76:	ff4713e3          	bne	a4,s4,80002f5c <iget+0x34>
      ip->ref++;
    80002f7a:	2785                	addiw	a5,a5,1
    80002f7c:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80002f7e:	0001b517          	auipc	a0,0x1b
    80002f82:	15a50513          	addi	a0,a0,346 # 8001e0d8 <itable>
    80002f86:	d07fd0ef          	jal	80000c8c <release>
      return ip;
    80002f8a:	8926                	mv	s2,s1
    80002f8c:	a02d                	j	80002fb6 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002f8e:	fbe9                	bnez	a5,80002f60 <iget+0x38>
      empty = ip;
    80002f90:	8926                	mv	s2,s1
    80002f92:	b7f9                	j	80002f60 <iget+0x38>
  if(empty == 0)
    80002f94:	02090a63          	beqz	s2,80002fc8 <iget+0xa0>
  ip->dev = dev;
    80002f98:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80002f9c:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80002fa0:	4785                	li	a5,1
    80002fa2:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80002fa6:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80002faa:	0001b517          	auipc	a0,0x1b
    80002fae:	12e50513          	addi	a0,a0,302 # 8001e0d8 <itable>
    80002fb2:	cdbfd0ef          	jal	80000c8c <release>
}
    80002fb6:	854a                	mv	a0,s2
    80002fb8:	70a2                	ld	ra,40(sp)
    80002fba:	7402                	ld	s0,32(sp)
    80002fbc:	64e2                	ld	s1,24(sp)
    80002fbe:	6942                	ld	s2,16(sp)
    80002fc0:	69a2                	ld	s3,8(sp)
    80002fc2:	6a02                	ld	s4,0(sp)
    80002fc4:	6145                	addi	sp,sp,48
    80002fc6:	8082                	ret
    panic("iget: no inodes");
    80002fc8:	00004517          	auipc	a0,0x4
    80002fcc:	61850513          	addi	a0,a0,1560 # 800075e0 <etext+0x5e0>
    80002fd0:	fc4fd0ef          	jal	80000794 <panic>

0000000080002fd4 <fsinit>:
fsinit(int dev) {
    80002fd4:	7179                	addi	sp,sp,-48
    80002fd6:	f406                	sd	ra,40(sp)
    80002fd8:	f022                	sd	s0,32(sp)
    80002fda:	ec26                	sd	s1,24(sp)
    80002fdc:	e84a                	sd	s2,16(sp)
    80002fde:	e44e                	sd	s3,8(sp)
    80002fe0:	1800                	addi	s0,sp,48
    80002fe2:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80002fe4:	4585                	li	a1,1
    80002fe6:	aebff0ef          	jal	80002ad0 <bread>
    80002fea:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80002fec:	0001b997          	auipc	s3,0x1b
    80002ff0:	0cc98993          	addi	s3,s3,204 # 8001e0b8 <sb>
    80002ff4:	02000613          	li	a2,32
    80002ff8:	05850593          	addi	a1,a0,88
    80002ffc:	854e                	mv	a0,s3
    80002ffe:	d27fd0ef          	jal	80000d24 <memmove>
  brelse(bp);
    80003002:	8526                	mv	a0,s1
    80003004:	bd5ff0ef          	jal	80002bd8 <brelse>
  if(sb.magic != FSMAGIC)
    80003008:	0009a703          	lw	a4,0(s3)
    8000300c:	102037b7          	lui	a5,0x10203
    80003010:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003014:	02f71063          	bne	a4,a5,80003034 <fsinit+0x60>
  initlog(dev, &sb);
    80003018:	0001b597          	auipc	a1,0x1b
    8000301c:	0a058593          	addi	a1,a1,160 # 8001e0b8 <sb>
    80003020:	854a                	mv	a0,s2
    80003022:	1f9000ef          	jal	80003a1a <initlog>
}
    80003026:	70a2                	ld	ra,40(sp)
    80003028:	7402                	ld	s0,32(sp)
    8000302a:	64e2                	ld	s1,24(sp)
    8000302c:	6942                	ld	s2,16(sp)
    8000302e:	69a2                	ld	s3,8(sp)
    80003030:	6145                	addi	sp,sp,48
    80003032:	8082                	ret
    panic("invalid file system");
    80003034:	00004517          	auipc	a0,0x4
    80003038:	5bc50513          	addi	a0,a0,1468 # 800075f0 <etext+0x5f0>
    8000303c:	f58fd0ef          	jal	80000794 <panic>

0000000080003040 <iinit>:
{
    80003040:	7179                	addi	sp,sp,-48
    80003042:	f406                	sd	ra,40(sp)
    80003044:	f022                	sd	s0,32(sp)
    80003046:	ec26                	sd	s1,24(sp)
    80003048:	e84a                	sd	s2,16(sp)
    8000304a:	e44e                	sd	s3,8(sp)
    8000304c:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000304e:	00004597          	auipc	a1,0x4
    80003052:	5ba58593          	addi	a1,a1,1466 # 80007608 <etext+0x608>
    80003056:	0001b517          	auipc	a0,0x1b
    8000305a:	08250513          	addi	a0,a0,130 # 8001e0d8 <itable>
    8000305e:	b17fd0ef          	jal	80000b74 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003062:	0001b497          	auipc	s1,0x1b
    80003066:	09e48493          	addi	s1,s1,158 # 8001e100 <itable+0x28>
    8000306a:	0001d997          	auipc	s3,0x1d
    8000306e:	b2698993          	addi	s3,s3,-1242 # 8001fb90 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003072:	00004917          	auipc	s2,0x4
    80003076:	59e90913          	addi	s2,s2,1438 # 80007610 <etext+0x610>
    8000307a:	85ca                	mv	a1,s2
    8000307c:	8526                	mv	a0,s1
    8000307e:	4c9000ef          	jal	80003d46 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003082:	08848493          	addi	s1,s1,136
    80003086:	ff349ae3          	bne	s1,s3,8000307a <iinit+0x3a>
}
    8000308a:	70a2                	ld	ra,40(sp)
    8000308c:	7402                	ld	s0,32(sp)
    8000308e:	64e2                	ld	s1,24(sp)
    80003090:	6942                	ld	s2,16(sp)
    80003092:	69a2                	ld	s3,8(sp)
    80003094:	6145                	addi	sp,sp,48
    80003096:	8082                	ret

0000000080003098 <ialloc>:
{
    80003098:	7139                	addi	sp,sp,-64
    8000309a:	fc06                	sd	ra,56(sp)
    8000309c:	f822                	sd	s0,48(sp)
    8000309e:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800030a0:	0001b717          	auipc	a4,0x1b
    800030a4:	02472703          	lw	a4,36(a4) # 8001e0c4 <sb+0xc>
    800030a8:	4785                	li	a5,1
    800030aa:	06e7f063          	bgeu	a5,a4,8000310a <ialloc+0x72>
    800030ae:	f426                	sd	s1,40(sp)
    800030b0:	f04a                	sd	s2,32(sp)
    800030b2:	ec4e                	sd	s3,24(sp)
    800030b4:	e852                	sd	s4,16(sp)
    800030b6:	e456                	sd	s5,8(sp)
    800030b8:	e05a                	sd	s6,0(sp)
    800030ba:	8aaa                	mv	s5,a0
    800030bc:	8b2e                	mv	s6,a1
    800030be:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    800030c0:	0001ba17          	auipc	s4,0x1b
    800030c4:	ff8a0a13          	addi	s4,s4,-8 # 8001e0b8 <sb>
    800030c8:	00495593          	srli	a1,s2,0x4
    800030cc:	018a2783          	lw	a5,24(s4)
    800030d0:	9dbd                	addw	a1,a1,a5
    800030d2:	8556                	mv	a0,s5
    800030d4:	9fdff0ef          	jal	80002ad0 <bread>
    800030d8:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800030da:	05850993          	addi	s3,a0,88
    800030de:	00f97793          	andi	a5,s2,15
    800030e2:	079a                	slli	a5,a5,0x6
    800030e4:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800030e6:	00099783          	lh	a5,0(s3)
    800030ea:	cb9d                	beqz	a5,80003120 <ialloc+0x88>
    brelse(bp);
    800030ec:	aedff0ef          	jal	80002bd8 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800030f0:	0905                	addi	s2,s2,1
    800030f2:	00ca2703          	lw	a4,12(s4)
    800030f6:	0009079b          	sext.w	a5,s2
    800030fa:	fce7e7e3          	bltu	a5,a4,800030c8 <ialloc+0x30>
    800030fe:	74a2                	ld	s1,40(sp)
    80003100:	7902                	ld	s2,32(sp)
    80003102:	69e2                	ld	s3,24(sp)
    80003104:	6a42                	ld	s4,16(sp)
    80003106:	6aa2                	ld	s5,8(sp)
    80003108:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    8000310a:	00004517          	auipc	a0,0x4
    8000310e:	50e50513          	addi	a0,a0,1294 # 80007618 <etext+0x618>
    80003112:	bb0fd0ef          	jal	800004c2 <printf>
  return 0;
    80003116:	4501                	li	a0,0
}
    80003118:	70e2                	ld	ra,56(sp)
    8000311a:	7442                	ld	s0,48(sp)
    8000311c:	6121                	addi	sp,sp,64
    8000311e:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003120:	04000613          	li	a2,64
    80003124:	4581                	li	a1,0
    80003126:	854e                	mv	a0,s3
    80003128:	ba1fd0ef          	jal	80000cc8 <memset>
      dip->type = type;
    8000312c:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003130:	8526                	mv	a0,s1
    80003132:	2f1000ef          	jal	80003c22 <log_write>
      brelse(bp);
    80003136:	8526                	mv	a0,s1
    80003138:	aa1ff0ef          	jal	80002bd8 <brelse>
      return iget(dev, inum);
    8000313c:	0009059b          	sext.w	a1,s2
    80003140:	8556                	mv	a0,s5
    80003142:	de7ff0ef          	jal	80002f28 <iget>
    80003146:	74a2                	ld	s1,40(sp)
    80003148:	7902                	ld	s2,32(sp)
    8000314a:	69e2                	ld	s3,24(sp)
    8000314c:	6a42                	ld	s4,16(sp)
    8000314e:	6aa2                	ld	s5,8(sp)
    80003150:	6b02                	ld	s6,0(sp)
    80003152:	b7d9                	j	80003118 <ialloc+0x80>

0000000080003154 <iupdate>:
{
    80003154:	1101                	addi	sp,sp,-32
    80003156:	ec06                	sd	ra,24(sp)
    80003158:	e822                	sd	s0,16(sp)
    8000315a:	e426                	sd	s1,8(sp)
    8000315c:	e04a                	sd	s2,0(sp)
    8000315e:	1000                	addi	s0,sp,32
    80003160:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003162:	415c                	lw	a5,4(a0)
    80003164:	0047d79b          	srliw	a5,a5,0x4
    80003168:	0001b597          	auipc	a1,0x1b
    8000316c:	f685a583          	lw	a1,-152(a1) # 8001e0d0 <sb+0x18>
    80003170:	9dbd                	addw	a1,a1,a5
    80003172:	4108                	lw	a0,0(a0)
    80003174:	95dff0ef          	jal	80002ad0 <bread>
    80003178:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000317a:	05850793          	addi	a5,a0,88
    8000317e:	40d8                	lw	a4,4(s1)
    80003180:	8b3d                	andi	a4,a4,15
    80003182:	071a                	slli	a4,a4,0x6
    80003184:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003186:	04449703          	lh	a4,68(s1)
    8000318a:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000318e:	04649703          	lh	a4,70(s1)
    80003192:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003196:	04849703          	lh	a4,72(s1)
    8000319a:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000319e:	04a49703          	lh	a4,74(s1)
    800031a2:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800031a6:	44f8                	lw	a4,76(s1)
    800031a8:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800031aa:	03400613          	li	a2,52
    800031ae:	05048593          	addi	a1,s1,80
    800031b2:	00c78513          	addi	a0,a5,12
    800031b6:	b6ffd0ef          	jal	80000d24 <memmove>
  log_write(bp);
    800031ba:	854a                	mv	a0,s2
    800031bc:	267000ef          	jal	80003c22 <log_write>
  brelse(bp);
    800031c0:	854a                	mv	a0,s2
    800031c2:	a17ff0ef          	jal	80002bd8 <brelse>
}
    800031c6:	60e2                	ld	ra,24(sp)
    800031c8:	6442                	ld	s0,16(sp)
    800031ca:	64a2                	ld	s1,8(sp)
    800031cc:	6902                	ld	s2,0(sp)
    800031ce:	6105                	addi	sp,sp,32
    800031d0:	8082                	ret

00000000800031d2 <idup>:
{
    800031d2:	1101                	addi	sp,sp,-32
    800031d4:	ec06                	sd	ra,24(sp)
    800031d6:	e822                	sd	s0,16(sp)
    800031d8:	e426                	sd	s1,8(sp)
    800031da:	1000                	addi	s0,sp,32
    800031dc:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800031de:	0001b517          	auipc	a0,0x1b
    800031e2:	efa50513          	addi	a0,a0,-262 # 8001e0d8 <itable>
    800031e6:	a0ffd0ef          	jal	80000bf4 <acquire>
  ip->ref++;
    800031ea:	449c                	lw	a5,8(s1)
    800031ec:	2785                	addiw	a5,a5,1
    800031ee:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800031f0:	0001b517          	auipc	a0,0x1b
    800031f4:	ee850513          	addi	a0,a0,-280 # 8001e0d8 <itable>
    800031f8:	a95fd0ef          	jal	80000c8c <release>
}
    800031fc:	8526                	mv	a0,s1
    800031fe:	60e2                	ld	ra,24(sp)
    80003200:	6442                	ld	s0,16(sp)
    80003202:	64a2                	ld	s1,8(sp)
    80003204:	6105                	addi	sp,sp,32
    80003206:	8082                	ret

0000000080003208 <ilock>:
{
    80003208:	1101                	addi	sp,sp,-32
    8000320a:	ec06                	sd	ra,24(sp)
    8000320c:	e822                	sd	s0,16(sp)
    8000320e:	e426                	sd	s1,8(sp)
    80003210:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003212:	cd19                	beqz	a0,80003230 <ilock+0x28>
    80003214:	84aa                	mv	s1,a0
    80003216:	451c                	lw	a5,8(a0)
    80003218:	00f05c63          	blez	a5,80003230 <ilock+0x28>
  acquiresleep(&ip->lock);
    8000321c:	0541                	addi	a0,a0,16
    8000321e:	35f000ef          	jal	80003d7c <acquiresleep>
  if(ip->valid == 0){
    80003222:	40bc                	lw	a5,64(s1)
    80003224:	cf89                	beqz	a5,8000323e <ilock+0x36>
}
    80003226:	60e2                	ld	ra,24(sp)
    80003228:	6442                	ld	s0,16(sp)
    8000322a:	64a2                	ld	s1,8(sp)
    8000322c:	6105                	addi	sp,sp,32
    8000322e:	8082                	ret
    80003230:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003232:	00004517          	auipc	a0,0x4
    80003236:	3fe50513          	addi	a0,a0,1022 # 80007630 <etext+0x630>
    8000323a:	d5afd0ef          	jal	80000794 <panic>
    8000323e:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003240:	40dc                	lw	a5,4(s1)
    80003242:	0047d79b          	srliw	a5,a5,0x4
    80003246:	0001b597          	auipc	a1,0x1b
    8000324a:	e8a5a583          	lw	a1,-374(a1) # 8001e0d0 <sb+0x18>
    8000324e:	9dbd                	addw	a1,a1,a5
    80003250:	4088                	lw	a0,0(s1)
    80003252:	87fff0ef          	jal	80002ad0 <bread>
    80003256:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003258:	05850593          	addi	a1,a0,88
    8000325c:	40dc                	lw	a5,4(s1)
    8000325e:	8bbd                	andi	a5,a5,15
    80003260:	079a                	slli	a5,a5,0x6
    80003262:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003264:	00059783          	lh	a5,0(a1)
    80003268:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000326c:	00259783          	lh	a5,2(a1)
    80003270:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003274:	00459783          	lh	a5,4(a1)
    80003278:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000327c:	00659783          	lh	a5,6(a1)
    80003280:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003284:	459c                	lw	a5,8(a1)
    80003286:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003288:	03400613          	li	a2,52
    8000328c:	05b1                	addi	a1,a1,12
    8000328e:	05048513          	addi	a0,s1,80
    80003292:	a93fd0ef          	jal	80000d24 <memmove>
    brelse(bp);
    80003296:	854a                	mv	a0,s2
    80003298:	941ff0ef          	jal	80002bd8 <brelse>
    ip->valid = 1;
    8000329c:	4785                	li	a5,1
    8000329e:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800032a0:	04449783          	lh	a5,68(s1)
    800032a4:	c399                	beqz	a5,800032aa <ilock+0xa2>
    800032a6:	6902                	ld	s2,0(sp)
    800032a8:	bfbd                	j	80003226 <ilock+0x1e>
      panic("ilock: no type");
    800032aa:	00004517          	auipc	a0,0x4
    800032ae:	38e50513          	addi	a0,a0,910 # 80007638 <etext+0x638>
    800032b2:	ce2fd0ef          	jal	80000794 <panic>

00000000800032b6 <iunlock>:
{
    800032b6:	1101                	addi	sp,sp,-32
    800032b8:	ec06                	sd	ra,24(sp)
    800032ba:	e822                	sd	s0,16(sp)
    800032bc:	e426                	sd	s1,8(sp)
    800032be:	e04a                	sd	s2,0(sp)
    800032c0:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800032c2:	c505                	beqz	a0,800032ea <iunlock+0x34>
    800032c4:	84aa                	mv	s1,a0
    800032c6:	01050913          	addi	s2,a0,16
    800032ca:	854a                	mv	a0,s2
    800032cc:	32f000ef          	jal	80003dfa <holdingsleep>
    800032d0:	cd09                	beqz	a0,800032ea <iunlock+0x34>
    800032d2:	449c                	lw	a5,8(s1)
    800032d4:	00f05b63          	blez	a5,800032ea <iunlock+0x34>
  releasesleep(&ip->lock);
    800032d8:	854a                	mv	a0,s2
    800032da:	2e9000ef          	jal	80003dc2 <releasesleep>
}
    800032de:	60e2                	ld	ra,24(sp)
    800032e0:	6442                	ld	s0,16(sp)
    800032e2:	64a2                	ld	s1,8(sp)
    800032e4:	6902                	ld	s2,0(sp)
    800032e6:	6105                	addi	sp,sp,32
    800032e8:	8082                	ret
    panic("iunlock");
    800032ea:	00004517          	auipc	a0,0x4
    800032ee:	35e50513          	addi	a0,a0,862 # 80007648 <etext+0x648>
    800032f2:	ca2fd0ef          	jal	80000794 <panic>

00000000800032f6 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800032f6:	7179                	addi	sp,sp,-48
    800032f8:	f406                	sd	ra,40(sp)
    800032fa:	f022                	sd	s0,32(sp)
    800032fc:	ec26                	sd	s1,24(sp)
    800032fe:	e84a                	sd	s2,16(sp)
    80003300:	e44e                	sd	s3,8(sp)
    80003302:	1800                	addi	s0,sp,48
    80003304:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003306:	05050493          	addi	s1,a0,80
    8000330a:	08050913          	addi	s2,a0,128
    8000330e:	a021                	j	80003316 <itrunc+0x20>
    80003310:	0491                	addi	s1,s1,4
    80003312:	01248b63          	beq	s1,s2,80003328 <itrunc+0x32>
    if(ip->addrs[i]){
    80003316:	408c                	lw	a1,0(s1)
    80003318:	dde5                	beqz	a1,80003310 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    8000331a:	0009a503          	lw	a0,0(s3)
    8000331e:	9abff0ef          	jal	80002cc8 <bfree>
      ip->addrs[i] = 0;
    80003322:	0004a023          	sw	zero,0(s1)
    80003326:	b7ed                	j	80003310 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003328:	0809a583          	lw	a1,128(s3)
    8000332c:	ed89                	bnez	a1,80003346 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000332e:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003332:	854e                	mv	a0,s3
    80003334:	e21ff0ef          	jal	80003154 <iupdate>
}
    80003338:	70a2                	ld	ra,40(sp)
    8000333a:	7402                	ld	s0,32(sp)
    8000333c:	64e2                	ld	s1,24(sp)
    8000333e:	6942                	ld	s2,16(sp)
    80003340:	69a2                	ld	s3,8(sp)
    80003342:	6145                	addi	sp,sp,48
    80003344:	8082                	ret
    80003346:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003348:	0009a503          	lw	a0,0(s3)
    8000334c:	f84ff0ef          	jal	80002ad0 <bread>
    80003350:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003352:	05850493          	addi	s1,a0,88
    80003356:	45850913          	addi	s2,a0,1112
    8000335a:	a021                	j	80003362 <itrunc+0x6c>
    8000335c:	0491                	addi	s1,s1,4
    8000335e:	01248963          	beq	s1,s2,80003370 <itrunc+0x7a>
      if(a[j])
    80003362:	408c                	lw	a1,0(s1)
    80003364:	dde5                	beqz	a1,8000335c <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003366:	0009a503          	lw	a0,0(s3)
    8000336a:	95fff0ef          	jal	80002cc8 <bfree>
    8000336e:	b7fd                	j	8000335c <itrunc+0x66>
    brelse(bp);
    80003370:	8552                	mv	a0,s4
    80003372:	867ff0ef          	jal	80002bd8 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003376:	0809a583          	lw	a1,128(s3)
    8000337a:	0009a503          	lw	a0,0(s3)
    8000337e:	94bff0ef          	jal	80002cc8 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003382:	0809a023          	sw	zero,128(s3)
    80003386:	6a02                	ld	s4,0(sp)
    80003388:	b75d                	j	8000332e <itrunc+0x38>

000000008000338a <iput>:
{
    8000338a:	1101                	addi	sp,sp,-32
    8000338c:	ec06                	sd	ra,24(sp)
    8000338e:	e822                	sd	s0,16(sp)
    80003390:	e426                	sd	s1,8(sp)
    80003392:	1000                	addi	s0,sp,32
    80003394:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003396:	0001b517          	auipc	a0,0x1b
    8000339a:	d4250513          	addi	a0,a0,-702 # 8001e0d8 <itable>
    8000339e:	857fd0ef          	jal	80000bf4 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800033a2:	4498                	lw	a4,8(s1)
    800033a4:	4785                	li	a5,1
    800033a6:	02f70063          	beq	a4,a5,800033c6 <iput+0x3c>
  ip->ref--;
    800033aa:	449c                	lw	a5,8(s1)
    800033ac:	37fd                	addiw	a5,a5,-1
    800033ae:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800033b0:	0001b517          	auipc	a0,0x1b
    800033b4:	d2850513          	addi	a0,a0,-728 # 8001e0d8 <itable>
    800033b8:	8d5fd0ef          	jal	80000c8c <release>
}
    800033bc:	60e2                	ld	ra,24(sp)
    800033be:	6442                	ld	s0,16(sp)
    800033c0:	64a2                	ld	s1,8(sp)
    800033c2:	6105                	addi	sp,sp,32
    800033c4:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800033c6:	40bc                	lw	a5,64(s1)
    800033c8:	d3ed                	beqz	a5,800033aa <iput+0x20>
    800033ca:	04a49783          	lh	a5,74(s1)
    800033ce:	fff1                	bnez	a5,800033aa <iput+0x20>
    800033d0:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    800033d2:	01048913          	addi	s2,s1,16
    800033d6:	854a                	mv	a0,s2
    800033d8:	1a5000ef          	jal	80003d7c <acquiresleep>
    release(&itable.lock);
    800033dc:	0001b517          	auipc	a0,0x1b
    800033e0:	cfc50513          	addi	a0,a0,-772 # 8001e0d8 <itable>
    800033e4:	8a9fd0ef          	jal	80000c8c <release>
    itrunc(ip);
    800033e8:	8526                	mv	a0,s1
    800033ea:	f0dff0ef          	jal	800032f6 <itrunc>
    ip->type = 0;
    800033ee:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800033f2:	8526                	mv	a0,s1
    800033f4:	d61ff0ef          	jal	80003154 <iupdate>
    ip->valid = 0;
    800033f8:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800033fc:	854a                	mv	a0,s2
    800033fe:	1c5000ef          	jal	80003dc2 <releasesleep>
    acquire(&itable.lock);
    80003402:	0001b517          	auipc	a0,0x1b
    80003406:	cd650513          	addi	a0,a0,-810 # 8001e0d8 <itable>
    8000340a:	feafd0ef          	jal	80000bf4 <acquire>
    8000340e:	6902                	ld	s2,0(sp)
    80003410:	bf69                	j	800033aa <iput+0x20>

0000000080003412 <iunlockput>:
{
    80003412:	1101                	addi	sp,sp,-32
    80003414:	ec06                	sd	ra,24(sp)
    80003416:	e822                	sd	s0,16(sp)
    80003418:	e426                	sd	s1,8(sp)
    8000341a:	1000                	addi	s0,sp,32
    8000341c:	84aa                	mv	s1,a0
  iunlock(ip);
    8000341e:	e99ff0ef          	jal	800032b6 <iunlock>
  iput(ip);
    80003422:	8526                	mv	a0,s1
    80003424:	f67ff0ef          	jal	8000338a <iput>
}
    80003428:	60e2                	ld	ra,24(sp)
    8000342a:	6442                	ld	s0,16(sp)
    8000342c:	64a2                	ld	s1,8(sp)
    8000342e:	6105                	addi	sp,sp,32
    80003430:	8082                	ret

0000000080003432 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003432:	1141                	addi	sp,sp,-16
    80003434:	e422                	sd	s0,8(sp)
    80003436:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003438:	411c                	lw	a5,0(a0)
    8000343a:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000343c:	415c                	lw	a5,4(a0)
    8000343e:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003440:	04451783          	lh	a5,68(a0)
    80003444:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003448:	04a51783          	lh	a5,74(a0)
    8000344c:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003450:	04c56783          	lwu	a5,76(a0)
    80003454:	e99c                	sd	a5,16(a1)
}
    80003456:	6422                	ld	s0,8(sp)
    80003458:	0141                	addi	sp,sp,16
    8000345a:	8082                	ret

000000008000345c <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000345c:	457c                	lw	a5,76(a0)
    8000345e:	0ed7eb63          	bltu	a5,a3,80003554 <readi+0xf8>
{
    80003462:	7159                	addi	sp,sp,-112
    80003464:	f486                	sd	ra,104(sp)
    80003466:	f0a2                	sd	s0,96(sp)
    80003468:	eca6                	sd	s1,88(sp)
    8000346a:	e0d2                	sd	s4,64(sp)
    8000346c:	fc56                	sd	s5,56(sp)
    8000346e:	f85a                	sd	s6,48(sp)
    80003470:	f45e                	sd	s7,40(sp)
    80003472:	1880                	addi	s0,sp,112
    80003474:	8b2a                	mv	s6,a0
    80003476:	8bae                	mv	s7,a1
    80003478:	8a32                	mv	s4,a2
    8000347a:	84b6                	mv	s1,a3
    8000347c:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    8000347e:	9f35                	addw	a4,a4,a3
    return 0;
    80003480:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003482:	0cd76063          	bltu	a4,a3,80003542 <readi+0xe6>
    80003486:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003488:	00e7f463          	bgeu	a5,a4,80003490 <readi+0x34>
    n = ip->size - off;
    8000348c:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003490:	080a8f63          	beqz	s5,8000352e <readi+0xd2>
    80003494:	e8ca                	sd	s2,80(sp)
    80003496:	f062                	sd	s8,32(sp)
    80003498:	ec66                	sd	s9,24(sp)
    8000349a:	e86a                	sd	s10,16(sp)
    8000349c:	e46e                	sd	s11,8(sp)
    8000349e:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800034a0:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800034a4:	5c7d                	li	s8,-1
    800034a6:	a80d                	j	800034d8 <readi+0x7c>
    800034a8:	020d1d93          	slli	s11,s10,0x20
    800034ac:	020ddd93          	srli	s11,s11,0x20
    800034b0:	05890613          	addi	a2,s2,88
    800034b4:	86ee                	mv	a3,s11
    800034b6:	963a                	add	a2,a2,a4
    800034b8:	85d2                	mv	a1,s4
    800034ba:	855e                	mv	a0,s7
    800034bc:	d79fe0ef          	jal	80002234 <either_copyout>
    800034c0:	05850763          	beq	a0,s8,8000350e <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800034c4:	854a                	mv	a0,s2
    800034c6:	f12ff0ef          	jal	80002bd8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800034ca:	013d09bb          	addw	s3,s10,s3
    800034ce:	009d04bb          	addw	s1,s10,s1
    800034d2:	9a6e                	add	s4,s4,s11
    800034d4:	0559f763          	bgeu	s3,s5,80003522 <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    800034d8:	00a4d59b          	srliw	a1,s1,0xa
    800034dc:	855a                	mv	a0,s6
    800034de:	977ff0ef          	jal	80002e54 <bmap>
    800034e2:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800034e6:	c5b1                	beqz	a1,80003532 <readi+0xd6>
    bp = bread(ip->dev, addr);
    800034e8:	000b2503          	lw	a0,0(s6)
    800034ec:	de4ff0ef          	jal	80002ad0 <bread>
    800034f0:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800034f2:	3ff4f713          	andi	a4,s1,1023
    800034f6:	40ec87bb          	subw	a5,s9,a4
    800034fa:	413a86bb          	subw	a3,s5,s3
    800034fe:	8d3e                	mv	s10,a5
    80003500:	2781                	sext.w	a5,a5
    80003502:	0006861b          	sext.w	a2,a3
    80003506:	faf671e3          	bgeu	a2,a5,800034a8 <readi+0x4c>
    8000350a:	8d36                	mv	s10,a3
    8000350c:	bf71                	j	800034a8 <readi+0x4c>
      brelse(bp);
    8000350e:	854a                	mv	a0,s2
    80003510:	ec8ff0ef          	jal	80002bd8 <brelse>
      tot = -1;
    80003514:	59fd                	li	s3,-1
      break;
    80003516:	6946                	ld	s2,80(sp)
    80003518:	7c02                	ld	s8,32(sp)
    8000351a:	6ce2                	ld	s9,24(sp)
    8000351c:	6d42                	ld	s10,16(sp)
    8000351e:	6da2                	ld	s11,8(sp)
    80003520:	a831                	j	8000353c <readi+0xe0>
    80003522:	6946                	ld	s2,80(sp)
    80003524:	7c02                	ld	s8,32(sp)
    80003526:	6ce2                	ld	s9,24(sp)
    80003528:	6d42                	ld	s10,16(sp)
    8000352a:	6da2                	ld	s11,8(sp)
    8000352c:	a801                	j	8000353c <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000352e:	89d6                	mv	s3,s5
    80003530:	a031                	j	8000353c <readi+0xe0>
    80003532:	6946                	ld	s2,80(sp)
    80003534:	7c02                	ld	s8,32(sp)
    80003536:	6ce2                	ld	s9,24(sp)
    80003538:	6d42                	ld	s10,16(sp)
    8000353a:	6da2                	ld	s11,8(sp)
  }
  return tot;
    8000353c:	0009851b          	sext.w	a0,s3
    80003540:	69a6                	ld	s3,72(sp)
}
    80003542:	70a6                	ld	ra,104(sp)
    80003544:	7406                	ld	s0,96(sp)
    80003546:	64e6                	ld	s1,88(sp)
    80003548:	6a06                	ld	s4,64(sp)
    8000354a:	7ae2                	ld	s5,56(sp)
    8000354c:	7b42                	ld	s6,48(sp)
    8000354e:	7ba2                	ld	s7,40(sp)
    80003550:	6165                	addi	sp,sp,112
    80003552:	8082                	ret
    return 0;
    80003554:	4501                	li	a0,0
}
    80003556:	8082                	ret

0000000080003558 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003558:	457c                	lw	a5,76(a0)
    8000355a:	10d7e063          	bltu	a5,a3,8000365a <writei+0x102>
{
    8000355e:	7159                	addi	sp,sp,-112
    80003560:	f486                	sd	ra,104(sp)
    80003562:	f0a2                	sd	s0,96(sp)
    80003564:	e8ca                	sd	s2,80(sp)
    80003566:	e0d2                	sd	s4,64(sp)
    80003568:	fc56                	sd	s5,56(sp)
    8000356a:	f85a                	sd	s6,48(sp)
    8000356c:	f45e                	sd	s7,40(sp)
    8000356e:	1880                	addi	s0,sp,112
    80003570:	8aaa                	mv	s5,a0
    80003572:	8bae                	mv	s7,a1
    80003574:	8a32                	mv	s4,a2
    80003576:	8936                	mv	s2,a3
    80003578:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000357a:	00e687bb          	addw	a5,a3,a4
    8000357e:	0ed7e063          	bltu	a5,a3,8000365e <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003582:	00043737          	lui	a4,0x43
    80003586:	0cf76e63          	bltu	a4,a5,80003662 <writei+0x10a>
    8000358a:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000358c:	0a0b0f63          	beqz	s6,8000364a <writei+0xf2>
    80003590:	eca6                	sd	s1,88(sp)
    80003592:	f062                	sd	s8,32(sp)
    80003594:	ec66                	sd	s9,24(sp)
    80003596:	e86a                	sd	s10,16(sp)
    80003598:	e46e                	sd	s11,8(sp)
    8000359a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000359c:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800035a0:	5c7d                	li	s8,-1
    800035a2:	a825                	j	800035da <writei+0x82>
    800035a4:	020d1d93          	slli	s11,s10,0x20
    800035a8:	020ddd93          	srli	s11,s11,0x20
    800035ac:	05848513          	addi	a0,s1,88
    800035b0:	86ee                	mv	a3,s11
    800035b2:	8652                	mv	a2,s4
    800035b4:	85de                	mv	a1,s7
    800035b6:	953a                	add	a0,a0,a4
    800035b8:	cc7fe0ef          	jal	8000227e <either_copyin>
    800035bc:	05850a63          	beq	a0,s8,80003610 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    800035c0:	8526                	mv	a0,s1
    800035c2:	660000ef          	jal	80003c22 <log_write>
    brelse(bp);
    800035c6:	8526                	mv	a0,s1
    800035c8:	e10ff0ef          	jal	80002bd8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800035cc:	013d09bb          	addw	s3,s10,s3
    800035d0:	012d093b          	addw	s2,s10,s2
    800035d4:	9a6e                	add	s4,s4,s11
    800035d6:	0569f063          	bgeu	s3,s6,80003616 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    800035da:	00a9559b          	srliw	a1,s2,0xa
    800035de:	8556                	mv	a0,s5
    800035e0:	875ff0ef          	jal	80002e54 <bmap>
    800035e4:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800035e8:	c59d                	beqz	a1,80003616 <writei+0xbe>
    bp = bread(ip->dev, addr);
    800035ea:	000aa503          	lw	a0,0(s5)
    800035ee:	ce2ff0ef          	jal	80002ad0 <bread>
    800035f2:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800035f4:	3ff97713          	andi	a4,s2,1023
    800035f8:	40ec87bb          	subw	a5,s9,a4
    800035fc:	413b06bb          	subw	a3,s6,s3
    80003600:	8d3e                	mv	s10,a5
    80003602:	2781                	sext.w	a5,a5
    80003604:	0006861b          	sext.w	a2,a3
    80003608:	f8f67ee3          	bgeu	a2,a5,800035a4 <writei+0x4c>
    8000360c:	8d36                	mv	s10,a3
    8000360e:	bf59                	j	800035a4 <writei+0x4c>
      brelse(bp);
    80003610:	8526                	mv	a0,s1
    80003612:	dc6ff0ef          	jal	80002bd8 <brelse>
  }

  if(off > ip->size)
    80003616:	04caa783          	lw	a5,76(s5)
    8000361a:	0327fa63          	bgeu	a5,s2,8000364e <writei+0xf6>
    ip->size = off;
    8000361e:	052aa623          	sw	s2,76(s5)
    80003622:	64e6                	ld	s1,88(sp)
    80003624:	7c02                	ld	s8,32(sp)
    80003626:	6ce2                	ld	s9,24(sp)
    80003628:	6d42                	ld	s10,16(sp)
    8000362a:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000362c:	8556                	mv	a0,s5
    8000362e:	b27ff0ef          	jal	80003154 <iupdate>

  return tot;
    80003632:	0009851b          	sext.w	a0,s3
    80003636:	69a6                	ld	s3,72(sp)
}
    80003638:	70a6                	ld	ra,104(sp)
    8000363a:	7406                	ld	s0,96(sp)
    8000363c:	6946                	ld	s2,80(sp)
    8000363e:	6a06                	ld	s4,64(sp)
    80003640:	7ae2                	ld	s5,56(sp)
    80003642:	7b42                	ld	s6,48(sp)
    80003644:	7ba2                	ld	s7,40(sp)
    80003646:	6165                	addi	sp,sp,112
    80003648:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000364a:	89da                	mv	s3,s6
    8000364c:	b7c5                	j	8000362c <writei+0xd4>
    8000364e:	64e6                	ld	s1,88(sp)
    80003650:	7c02                	ld	s8,32(sp)
    80003652:	6ce2                	ld	s9,24(sp)
    80003654:	6d42                	ld	s10,16(sp)
    80003656:	6da2                	ld	s11,8(sp)
    80003658:	bfd1                	j	8000362c <writei+0xd4>
    return -1;
    8000365a:	557d                	li	a0,-1
}
    8000365c:	8082                	ret
    return -1;
    8000365e:	557d                	li	a0,-1
    80003660:	bfe1                	j	80003638 <writei+0xe0>
    return -1;
    80003662:	557d                	li	a0,-1
    80003664:	bfd1                	j	80003638 <writei+0xe0>

0000000080003666 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003666:	1141                	addi	sp,sp,-16
    80003668:	e406                	sd	ra,8(sp)
    8000366a:	e022                	sd	s0,0(sp)
    8000366c:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000366e:	4639                	li	a2,14
    80003670:	f24fd0ef          	jal	80000d94 <strncmp>
}
    80003674:	60a2                	ld	ra,8(sp)
    80003676:	6402                	ld	s0,0(sp)
    80003678:	0141                	addi	sp,sp,16
    8000367a:	8082                	ret

000000008000367c <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000367c:	7139                	addi	sp,sp,-64
    8000367e:	fc06                	sd	ra,56(sp)
    80003680:	f822                	sd	s0,48(sp)
    80003682:	f426                	sd	s1,40(sp)
    80003684:	f04a                	sd	s2,32(sp)
    80003686:	ec4e                	sd	s3,24(sp)
    80003688:	e852                	sd	s4,16(sp)
    8000368a:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000368c:	04451703          	lh	a4,68(a0)
    80003690:	4785                	li	a5,1
    80003692:	00f71a63          	bne	a4,a5,800036a6 <dirlookup+0x2a>
    80003696:	892a                	mv	s2,a0
    80003698:	89ae                	mv	s3,a1
    8000369a:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000369c:	457c                	lw	a5,76(a0)
    8000369e:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800036a0:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800036a2:	e39d                	bnez	a5,800036c8 <dirlookup+0x4c>
    800036a4:	a095                	j	80003708 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    800036a6:	00004517          	auipc	a0,0x4
    800036aa:	faa50513          	addi	a0,a0,-86 # 80007650 <etext+0x650>
    800036ae:	8e6fd0ef          	jal	80000794 <panic>
      panic("dirlookup read");
    800036b2:	00004517          	auipc	a0,0x4
    800036b6:	fb650513          	addi	a0,a0,-74 # 80007668 <etext+0x668>
    800036ba:	8dafd0ef          	jal	80000794 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800036be:	24c1                	addiw	s1,s1,16
    800036c0:	04c92783          	lw	a5,76(s2)
    800036c4:	04f4f163          	bgeu	s1,a5,80003706 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800036c8:	4741                	li	a4,16
    800036ca:	86a6                	mv	a3,s1
    800036cc:	fc040613          	addi	a2,s0,-64
    800036d0:	4581                	li	a1,0
    800036d2:	854a                	mv	a0,s2
    800036d4:	d89ff0ef          	jal	8000345c <readi>
    800036d8:	47c1                	li	a5,16
    800036da:	fcf51ce3          	bne	a0,a5,800036b2 <dirlookup+0x36>
    if(de.inum == 0)
    800036de:	fc045783          	lhu	a5,-64(s0)
    800036e2:	dff1                	beqz	a5,800036be <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    800036e4:	fc240593          	addi	a1,s0,-62
    800036e8:	854e                	mv	a0,s3
    800036ea:	f7dff0ef          	jal	80003666 <namecmp>
    800036ee:	f961                	bnez	a0,800036be <dirlookup+0x42>
      if(poff)
    800036f0:	000a0463          	beqz	s4,800036f8 <dirlookup+0x7c>
        *poff = off;
    800036f4:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800036f8:	fc045583          	lhu	a1,-64(s0)
    800036fc:	00092503          	lw	a0,0(s2)
    80003700:	829ff0ef          	jal	80002f28 <iget>
    80003704:	a011                	j	80003708 <dirlookup+0x8c>
  return 0;
    80003706:	4501                	li	a0,0
}
    80003708:	70e2                	ld	ra,56(sp)
    8000370a:	7442                	ld	s0,48(sp)
    8000370c:	74a2                	ld	s1,40(sp)
    8000370e:	7902                	ld	s2,32(sp)
    80003710:	69e2                	ld	s3,24(sp)
    80003712:	6a42                	ld	s4,16(sp)
    80003714:	6121                	addi	sp,sp,64
    80003716:	8082                	ret

0000000080003718 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003718:	711d                	addi	sp,sp,-96
    8000371a:	ec86                	sd	ra,88(sp)
    8000371c:	e8a2                	sd	s0,80(sp)
    8000371e:	e4a6                	sd	s1,72(sp)
    80003720:	e0ca                	sd	s2,64(sp)
    80003722:	fc4e                	sd	s3,56(sp)
    80003724:	f852                	sd	s4,48(sp)
    80003726:	f456                	sd	s5,40(sp)
    80003728:	f05a                	sd	s6,32(sp)
    8000372a:	ec5e                	sd	s7,24(sp)
    8000372c:	e862                	sd	s8,16(sp)
    8000372e:	e466                	sd	s9,8(sp)
    80003730:	1080                	addi	s0,sp,96
    80003732:	84aa                	mv	s1,a0
    80003734:	8b2e                	mv	s6,a1
    80003736:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003738:	00054703          	lbu	a4,0(a0)
    8000373c:	02f00793          	li	a5,47
    80003740:	00f70e63          	beq	a4,a5,8000375c <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003744:	9c6fe0ef          	jal	8000190a <myproc>
    80003748:	15053503          	ld	a0,336(a0)
    8000374c:	a87ff0ef          	jal	800031d2 <idup>
    80003750:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003752:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003756:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003758:	4b85                	li	s7,1
    8000375a:	a871                	j	800037f6 <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    8000375c:	4585                	li	a1,1
    8000375e:	4505                	li	a0,1
    80003760:	fc8ff0ef          	jal	80002f28 <iget>
    80003764:	8a2a                	mv	s4,a0
    80003766:	b7f5                	j	80003752 <namex+0x3a>
      iunlockput(ip);
    80003768:	8552                	mv	a0,s4
    8000376a:	ca9ff0ef          	jal	80003412 <iunlockput>
      return 0;
    8000376e:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003770:	8552                	mv	a0,s4
    80003772:	60e6                	ld	ra,88(sp)
    80003774:	6446                	ld	s0,80(sp)
    80003776:	64a6                	ld	s1,72(sp)
    80003778:	6906                	ld	s2,64(sp)
    8000377a:	79e2                	ld	s3,56(sp)
    8000377c:	7a42                	ld	s4,48(sp)
    8000377e:	7aa2                	ld	s5,40(sp)
    80003780:	7b02                	ld	s6,32(sp)
    80003782:	6be2                	ld	s7,24(sp)
    80003784:	6c42                	ld	s8,16(sp)
    80003786:	6ca2                	ld	s9,8(sp)
    80003788:	6125                	addi	sp,sp,96
    8000378a:	8082                	ret
      iunlock(ip);
    8000378c:	8552                	mv	a0,s4
    8000378e:	b29ff0ef          	jal	800032b6 <iunlock>
      return ip;
    80003792:	bff9                	j	80003770 <namex+0x58>
      iunlockput(ip);
    80003794:	8552                	mv	a0,s4
    80003796:	c7dff0ef          	jal	80003412 <iunlockput>
      return 0;
    8000379a:	8a4e                	mv	s4,s3
    8000379c:	bfd1                	j	80003770 <namex+0x58>
  len = path - s;
    8000379e:	40998633          	sub	a2,s3,s1
    800037a2:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    800037a6:	099c5063          	bge	s8,s9,80003826 <namex+0x10e>
    memmove(name, s, DIRSIZ);
    800037aa:	4639                	li	a2,14
    800037ac:	85a6                	mv	a1,s1
    800037ae:	8556                	mv	a0,s5
    800037b0:	d74fd0ef          	jal	80000d24 <memmove>
    800037b4:	84ce                	mv	s1,s3
  while(*path == '/')
    800037b6:	0004c783          	lbu	a5,0(s1)
    800037ba:	01279763          	bne	a5,s2,800037c8 <namex+0xb0>
    path++;
    800037be:	0485                	addi	s1,s1,1
  while(*path == '/')
    800037c0:	0004c783          	lbu	a5,0(s1)
    800037c4:	ff278de3          	beq	a5,s2,800037be <namex+0xa6>
    ilock(ip);
    800037c8:	8552                	mv	a0,s4
    800037ca:	a3fff0ef          	jal	80003208 <ilock>
    if(ip->type != T_DIR){
    800037ce:	044a1783          	lh	a5,68(s4)
    800037d2:	f9779be3          	bne	a5,s7,80003768 <namex+0x50>
    if(nameiparent && *path == '\0'){
    800037d6:	000b0563          	beqz	s6,800037e0 <namex+0xc8>
    800037da:	0004c783          	lbu	a5,0(s1)
    800037de:	d7dd                	beqz	a5,8000378c <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    800037e0:	4601                	li	a2,0
    800037e2:	85d6                	mv	a1,s5
    800037e4:	8552                	mv	a0,s4
    800037e6:	e97ff0ef          	jal	8000367c <dirlookup>
    800037ea:	89aa                	mv	s3,a0
    800037ec:	d545                	beqz	a0,80003794 <namex+0x7c>
    iunlockput(ip);
    800037ee:	8552                	mv	a0,s4
    800037f0:	c23ff0ef          	jal	80003412 <iunlockput>
    ip = next;
    800037f4:	8a4e                	mv	s4,s3
  while(*path == '/')
    800037f6:	0004c783          	lbu	a5,0(s1)
    800037fa:	01279763          	bne	a5,s2,80003808 <namex+0xf0>
    path++;
    800037fe:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003800:	0004c783          	lbu	a5,0(s1)
    80003804:	ff278de3          	beq	a5,s2,800037fe <namex+0xe6>
  if(*path == 0)
    80003808:	cb8d                	beqz	a5,8000383a <namex+0x122>
  while(*path != '/' && *path != 0)
    8000380a:	0004c783          	lbu	a5,0(s1)
    8000380e:	89a6                	mv	s3,s1
  len = path - s;
    80003810:	4c81                	li	s9,0
    80003812:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003814:	01278963          	beq	a5,s2,80003826 <namex+0x10e>
    80003818:	d3d9                	beqz	a5,8000379e <namex+0x86>
    path++;
    8000381a:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    8000381c:	0009c783          	lbu	a5,0(s3)
    80003820:	ff279ce3          	bne	a5,s2,80003818 <namex+0x100>
    80003824:	bfad                	j	8000379e <namex+0x86>
    memmove(name, s, len);
    80003826:	2601                	sext.w	a2,a2
    80003828:	85a6                	mv	a1,s1
    8000382a:	8556                	mv	a0,s5
    8000382c:	cf8fd0ef          	jal	80000d24 <memmove>
    name[len] = 0;
    80003830:	9cd6                	add	s9,s9,s5
    80003832:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003836:	84ce                	mv	s1,s3
    80003838:	bfbd                	j	800037b6 <namex+0x9e>
  if(nameiparent){
    8000383a:	f20b0be3          	beqz	s6,80003770 <namex+0x58>
    iput(ip);
    8000383e:	8552                	mv	a0,s4
    80003840:	b4bff0ef          	jal	8000338a <iput>
    return 0;
    80003844:	4a01                	li	s4,0
    80003846:	b72d                	j	80003770 <namex+0x58>

0000000080003848 <dirlink>:
{
    80003848:	7139                	addi	sp,sp,-64
    8000384a:	fc06                	sd	ra,56(sp)
    8000384c:	f822                	sd	s0,48(sp)
    8000384e:	f04a                	sd	s2,32(sp)
    80003850:	ec4e                	sd	s3,24(sp)
    80003852:	e852                	sd	s4,16(sp)
    80003854:	0080                	addi	s0,sp,64
    80003856:	892a                	mv	s2,a0
    80003858:	8a2e                	mv	s4,a1
    8000385a:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000385c:	4601                	li	a2,0
    8000385e:	e1fff0ef          	jal	8000367c <dirlookup>
    80003862:	e535                	bnez	a0,800038ce <dirlink+0x86>
    80003864:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003866:	04c92483          	lw	s1,76(s2)
    8000386a:	c48d                	beqz	s1,80003894 <dirlink+0x4c>
    8000386c:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000386e:	4741                	li	a4,16
    80003870:	86a6                	mv	a3,s1
    80003872:	fc040613          	addi	a2,s0,-64
    80003876:	4581                	li	a1,0
    80003878:	854a                	mv	a0,s2
    8000387a:	be3ff0ef          	jal	8000345c <readi>
    8000387e:	47c1                	li	a5,16
    80003880:	04f51b63          	bne	a0,a5,800038d6 <dirlink+0x8e>
    if(de.inum == 0)
    80003884:	fc045783          	lhu	a5,-64(s0)
    80003888:	c791                	beqz	a5,80003894 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000388a:	24c1                	addiw	s1,s1,16
    8000388c:	04c92783          	lw	a5,76(s2)
    80003890:	fcf4efe3          	bltu	s1,a5,8000386e <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003894:	4639                	li	a2,14
    80003896:	85d2                	mv	a1,s4
    80003898:	fc240513          	addi	a0,s0,-62
    8000389c:	d2efd0ef          	jal	80000dca <strncpy>
  de.inum = inum;
    800038a0:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800038a4:	4741                	li	a4,16
    800038a6:	86a6                	mv	a3,s1
    800038a8:	fc040613          	addi	a2,s0,-64
    800038ac:	4581                	li	a1,0
    800038ae:	854a                	mv	a0,s2
    800038b0:	ca9ff0ef          	jal	80003558 <writei>
    800038b4:	1541                	addi	a0,a0,-16
    800038b6:	00a03533          	snez	a0,a0
    800038ba:	40a00533          	neg	a0,a0
    800038be:	74a2                	ld	s1,40(sp)
}
    800038c0:	70e2                	ld	ra,56(sp)
    800038c2:	7442                	ld	s0,48(sp)
    800038c4:	7902                	ld	s2,32(sp)
    800038c6:	69e2                	ld	s3,24(sp)
    800038c8:	6a42                	ld	s4,16(sp)
    800038ca:	6121                	addi	sp,sp,64
    800038cc:	8082                	ret
    iput(ip);
    800038ce:	abdff0ef          	jal	8000338a <iput>
    return -1;
    800038d2:	557d                	li	a0,-1
    800038d4:	b7f5                	j	800038c0 <dirlink+0x78>
      panic("dirlink read");
    800038d6:	00004517          	auipc	a0,0x4
    800038da:	da250513          	addi	a0,a0,-606 # 80007678 <etext+0x678>
    800038de:	eb7fc0ef          	jal	80000794 <panic>

00000000800038e2 <namei>:

struct inode*
namei(char *path)
{
    800038e2:	1101                	addi	sp,sp,-32
    800038e4:	ec06                	sd	ra,24(sp)
    800038e6:	e822                	sd	s0,16(sp)
    800038e8:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800038ea:	fe040613          	addi	a2,s0,-32
    800038ee:	4581                	li	a1,0
    800038f0:	e29ff0ef          	jal	80003718 <namex>
}
    800038f4:	60e2                	ld	ra,24(sp)
    800038f6:	6442                	ld	s0,16(sp)
    800038f8:	6105                	addi	sp,sp,32
    800038fa:	8082                	ret

00000000800038fc <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800038fc:	1141                	addi	sp,sp,-16
    800038fe:	e406                	sd	ra,8(sp)
    80003900:	e022                	sd	s0,0(sp)
    80003902:	0800                	addi	s0,sp,16
    80003904:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003906:	4585                	li	a1,1
    80003908:	e11ff0ef          	jal	80003718 <namex>
}
    8000390c:	60a2                	ld	ra,8(sp)
    8000390e:	6402                	ld	s0,0(sp)
    80003910:	0141                	addi	sp,sp,16
    80003912:	8082                	ret

0000000080003914 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003914:	1101                	addi	sp,sp,-32
    80003916:	ec06                	sd	ra,24(sp)
    80003918:	e822                	sd	s0,16(sp)
    8000391a:	e426                	sd	s1,8(sp)
    8000391c:	e04a                	sd	s2,0(sp)
    8000391e:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003920:	0001c917          	auipc	s2,0x1c
    80003924:	26090913          	addi	s2,s2,608 # 8001fb80 <log>
    80003928:	01892583          	lw	a1,24(s2)
    8000392c:	02892503          	lw	a0,40(s2)
    80003930:	9a0ff0ef          	jal	80002ad0 <bread>
    80003934:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003936:	02c92603          	lw	a2,44(s2)
    8000393a:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    8000393c:	00c05f63          	blez	a2,8000395a <write_head+0x46>
    80003940:	0001c717          	auipc	a4,0x1c
    80003944:	27070713          	addi	a4,a4,624 # 8001fbb0 <log+0x30>
    80003948:	87aa                	mv	a5,a0
    8000394a:	060a                	slli	a2,a2,0x2
    8000394c:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    8000394e:	4314                	lw	a3,0(a4)
    80003950:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003952:	0711                	addi	a4,a4,4
    80003954:	0791                	addi	a5,a5,4
    80003956:	fec79ce3          	bne	a5,a2,8000394e <write_head+0x3a>
  }
  bwrite(buf);
    8000395a:	8526                	mv	a0,s1
    8000395c:	a4aff0ef          	jal	80002ba6 <bwrite>
  brelse(buf);
    80003960:	8526                	mv	a0,s1
    80003962:	a76ff0ef          	jal	80002bd8 <brelse>
}
    80003966:	60e2                	ld	ra,24(sp)
    80003968:	6442                	ld	s0,16(sp)
    8000396a:	64a2                	ld	s1,8(sp)
    8000396c:	6902                	ld	s2,0(sp)
    8000396e:	6105                	addi	sp,sp,32
    80003970:	8082                	ret

0000000080003972 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003972:	0001c797          	auipc	a5,0x1c
    80003976:	23a7a783          	lw	a5,570(a5) # 8001fbac <log+0x2c>
    8000397a:	08f05f63          	blez	a5,80003a18 <install_trans+0xa6>
{
    8000397e:	7139                	addi	sp,sp,-64
    80003980:	fc06                	sd	ra,56(sp)
    80003982:	f822                	sd	s0,48(sp)
    80003984:	f426                	sd	s1,40(sp)
    80003986:	f04a                	sd	s2,32(sp)
    80003988:	ec4e                	sd	s3,24(sp)
    8000398a:	e852                	sd	s4,16(sp)
    8000398c:	e456                	sd	s5,8(sp)
    8000398e:	e05a                	sd	s6,0(sp)
    80003990:	0080                	addi	s0,sp,64
    80003992:	8b2a                	mv	s6,a0
    80003994:	0001ca97          	auipc	s5,0x1c
    80003998:	21ca8a93          	addi	s5,s5,540 # 8001fbb0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000399c:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000399e:	0001c997          	auipc	s3,0x1c
    800039a2:	1e298993          	addi	s3,s3,482 # 8001fb80 <log>
    800039a6:	a829                	j	800039c0 <install_trans+0x4e>
    brelse(lbuf);
    800039a8:	854a                	mv	a0,s2
    800039aa:	a2eff0ef          	jal	80002bd8 <brelse>
    brelse(dbuf);
    800039ae:	8526                	mv	a0,s1
    800039b0:	a28ff0ef          	jal	80002bd8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800039b4:	2a05                	addiw	s4,s4,1
    800039b6:	0a91                	addi	s5,s5,4
    800039b8:	02c9a783          	lw	a5,44(s3)
    800039bc:	04fa5463          	bge	s4,a5,80003a04 <install_trans+0x92>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800039c0:	0189a583          	lw	a1,24(s3)
    800039c4:	014585bb          	addw	a1,a1,s4
    800039c8:	2585                	addiw	a1,a1,1
    800039ca:	0289a503          	lw	a0,40(s3)
    800039ce:	902ff0ef          	jal	80002ad0 <bread>
    800039d2:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800039d4:	000aa583          	lw	a1,0(s5)
    800039d8:	0289a503          	lw	a0,40(s3)
    800039dc:	8f4ff0ef          	jal	80002ad0 <bread>
    800039e0:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800039e2:	40000613          	li	a2,1024
    800039e6:	05890593          	addi	a1,s2,88
    800039ea:	05850513          	addi	a0,a0,88
    800039ee:	b36fd0ef          	jal	80000d24 <memmove>
    bwrite(dbuf);  // write dst to disk
    800039f2:	8526                	mv	a0,s1
    800039f4:	9b2ff0ef          	jal	80002ba6 <bwrite>
    if(recovering == 0)
    800039f8:	fa0b18e3          	bnez	s6,800039a8 <install_trans+0x36>
      bunpin(dbuf);
    800039fc:	8526                	mv	a0,s1
    800039fe:	a96ff0ef          	jal	80002c94 <bunpin>
    80003a02:	b75d                	j	800039a8 <install_trans+0x36>
}
    80003a04:	70e2                	ld	ra,56(sp)
    80003a06:	7442                	ld	s0,48(sp)
    80003a08:	74a2                	ld	s1,40(sp)
    80003a0a:	7902                	ld	s2,32(sp)
    80003a0c:	69e2                	ld	s3,24(sp)
    80003a0e:	6a42                	ld	s4,16(sp)
    80003a10:	6aa2                	ld	s5,8(sp)
    80003a12:	6b02                	ld	s6,0(sp)
    80003a14:	6121                	addi	sp,sp,64
    80003a16:	8082                	ret
    80003a18:	8082                	ret

0000000080003a1a <initlog>:
{
    80003a1a:	7179                	addi	sp,sp,-48
    80003a1c:	f406                	sd	ra,40(sp)
    80003a1e:	f022                	sd	s0,32(sp)
    80003a20:	ec26                	sd	s1,24(sp)
    80003a22:	e84a                	sd	s2,16(sp)
    80003a24:	e44e                	sd	s3,8(sp)
    80003a26:	1800                	addi	s0,sp,48
    80003a28:	892a                	mv	s2,a0
    80003a2a:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003a2c:	0001c497          	auipc	s1,0x1c
    80003a30:	15448493          	addi	s1,s1,340 # 8001fb80 <log>
    80003a34:	00004597          	auipc	a1,0x4
    80003a38:	c5458593          	addi	a1,a1,-940 # 80007688 <etext+0x688>
    80003a3c:	8526                	mv	a0,s1
    80003a3e:	936fd0ef          	jal	80000b74 <initlock>
  log.start = sb->logstart;
    80003a42:	0149a583          	lw	a1,20(s3)
    80003a46:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003a48:	0109a783          	lw	a5,16(s3)
    80003a4c:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003a4e:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003a52:	854a                	mv	a0,s2
    80003a54:	87cff0ef          	jal	80002ad0 <bread>
  log.lh.n = lh->n;
    80003a58:	4d30                	lw	a2,88(a0)
    80003a5a:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003a5c:	00c05f63          	blez	a2,80003a7a <initlog+0x60>
    80003a60:	87aa                	mv	a5,a0
    80003a62:	0001c717          	auipc	a4,0x1c
    80003a66:	14e70713          	addi	a4,a4,334 # 8001fbb0 <log+0x30>
    80003a6a:	060a                	slli	a2,a2,0x2
    80003a6c:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003a6e:	4ff4                	lw	a3,92(a5)
    80003a70:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003a72:	0791                	addi	a5,a5,4
    80003a74:	0711                	addi	a4,a4,4
    80003a76:	fec79ce3          	bne	a5,a2,80003a6e <initlog+0x54>
  brelse(buf);
    80003a7a:	95eff0ef          	jal	80002bd8 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003a7e:	4505                	li	a0,1
    80003a80:	ef3ff0ef          	jal	80003972 <install_trans>
  log.lh.n = 0;
    80003a84:	0001c797          	auipc	a5,0x1c
    80003a88:	1207a423          	sw	zero,296(a5) # 8001fbac <log+0x2c>
  write_head(); // clear the log
    80003a8c:	e89ff0ef          	jal	80003914 <write_head>
}
    80003a90:	70a2                	ld	ra,40(sp)
    80003a92:	7402                	ld	s0,32(sp)
    80003a94:	64e2                	ld	s1,24(sp)
    80003a96:	6942                	ld	s2,16(sp)
    80003a98:	69a2                	ld	s3,8(sp)
    80003a9a:	6145                	addi	sp,sp,48
    80003a9c:	8082                	ret

0000000080003a9e <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003a9e:	1101                	addi	sp,sp,-32
    80003aa0:	ec06                	sd	ra,24(sp)
    80003aa2:	e822                	sd	s0,16(sp)
    80003aa4:	e426                	sd	s1,8(sp)
    80003aa6:	e04a                	sd	s2,0(sp)
    80003aa8:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003aaa:	0001c517          	auipc	a0,0x1c
    80003aae:	0d650513          	addi	a0,a0,214 # 8001fb80 <log>
    80003ab2:	942fd0ef          	jal	80000bf4 <acquire>
  while(1){
    if(log.committing){
    80003ab6:	0001c497          	auipc	s1,0x1c
    80003aba:	0ca48493          	addi	s1,s1,202 # 8001fb80 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003abe:	4979                	li	s2,30
    80003ac0:	a029                	j	80003aca <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003ac2:	85a6                	mv	a1,s1
    80003ac4:	8526                	mv	a0,s1
    80003ac6:	c12fe0ef          	jal	80001ed8 <sleep>
    if(log.committing){
    80003aca:	50dc                	lw	a5,36(s1)
    80003acc:	fbfd                	bnez	a5,80003ac2 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003ace:	5098                	lw	a4,32(s1)
    80003ad0:	2705                	addiw	a4,a4,1
    80003ad2:	0027179b          	slliw	a5,a4,0x2
    80003ad6:	9fb9                	addw	a5,a5,a4
    80003ad8:	0017979b          	slliw	a5,a5,0x1
    80003adc:	54d4                	lw	a3,44(s1)
    80003ade:	9fb5                	addw	a5,a5,a3
    80003ae0:	00f95763          	bge	s2,a5,80003aee <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003ae4:	85a6                	mv	a1,s1
    80003ae6:	8526                	mv	a0,s1
    80003ae8:	bf0fe0ef          	jal	80001ed8 <sleep>
    80003aec:	bff9                	j	80003aca <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003aee:	0001c517          	auipc	a0,0x1c
    80003af2:	09250513          	addi	a0,a0,146 # 8001fb80 <log>
    80003af6:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80003af8:	994fd0ef          	jal	80000c8c <release>
      break;
    }
  }
}
    80003afc:	60e2                	ld	ra,24(sp)
    80003afe:	6442                	ld	s0,16(sp)
    80003b00:	64a2                	ld	s1,8(sp)
    80003b02:	6902                	ld	s2,0(sp)
    80003b04:	6105                	addi	sp,sp,32
    80003b06:	8082                	ret

0000000080003b08 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003b08:	7139                	addi	sp,sp,-64
    80003b0a:	fc06                	sd	ra,56(sp)
    80003b0c:	f822                	sd	s0,48(sp)
    80003b0e:	f426                	sd	s1,40(sp)
    80003b10:	f04a                	sd	s2,32(sp)
    80003b12:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003b14:	0001c497          	auipc	s1,0x1c
    80003b18:	06c48493          	addi	s1,s1,108 # 8001fb80 <log>
    80003b1c:	8526                	mv	a0,s1
    80003b1e:	8d6fd0ef          	jal	80000bf4 <acquire>
  log.outstanding -= 1;
    80003b22:	509c                	lw	a5,32(s1)
    80003b24:	37fd                	addiw	a5,a5,-1
    80003b26:	0007891b          	sext.w	s2,a5
    80003b2a:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80003b2c:	50dc                	lw	a5,36(s1)
    80003b2e:	ef9d                	bnez	a5,80003b6c <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80003b30:	04091763          	bnez	s2,80003b7e <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003b34:	0001c497          	auipc	s1,0x1c
    80003b38:	04c48493          	addi	s1,s1,76 # 8001fb80 <log>
    80003b3c:	4785                	li	a5,1
    80003b3e:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003b40:	8526                	mv	a0,s1
    80003b42:	94afd0ef          	jal	80000c8c <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003b46:	54dc                	lw	a5,44(s1)
    80003b48:	04f04b63          	bgtz	a5,80003b9e <end_op+0x96>
    acquire(&log.lock);
    80003b4c:	0001c497          	auipc	s1,0x1c
    80003b50:	03448493          	addi	s1,s1,52 # 8001fb80 <log>
    80003b54:	8526                	mv	a0,s1
    80003b56:	89efd0ef          	jal	80000bf4 <acquire>
    log.committing = 0;
    80003b5a:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80003b5e:	8526                	mv	a0,s1
    80003b60:	bc4fe0ef          	jal	80001f24 <wakeup>
    release(&log.lock);
    80003b64:	8526                	mv	a0,s1
    80003b66:	926fd0ef          	jal	80000c8c <release>
}
    80003b6a:	a025                	j	80003b92 <end_op+0x8a>
    80003b6c:	ec4e                	sd	s3,24(sp)
    80003b6e:	e852                	sd	s4,16(sp)
    80003b70:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003b72:	00004517          	auipc	a0,0x4
    80003b76:	b1e50513          	addi	a0,a0,-1250 # 80007690 <etext+0x690>
    80003b7a:	c1bfc0ef          	jal	80000794 <panic>
    wakeup(&log);
    80003b7e:	0001c497          	auipc	s1,0x1c
    80003b82:	00248493          	addi	s1,s1,2 # 8001fb80 <log>
    80003b86:	8526                	mv	a0,s1
    80003b88:	b9cfe0ef          	jal	80001f24 <wakeup>
  release(&log.lock);
    80003b8c:	8526                	mv	a0,s1
    80003b8e:	8fefd0ef          	jal	80000c8c <release>
}
    80003b92:	70e2                	ld	ra,56(sp)
    80003b94:	7442                	ld	s0,48(sp)
    80003b96:	74a2                	ld	s1,40(sp)
    80003b98:	7902                	ld	s2,32(sp)
    80003b9a:	6121                	addi	sp,sp,64
    80003b9c:	8082                	ret
    80003b9e:	ec4e                	sd	s3,24(sp)
    80003ba0:	e852                	sd	s4,16(sp)
    80003ba2:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ba4:	0001ca97          	auipc	s5,0x1c
    80003ba8:	00ca8a93          	addi	s5,s5,12 # 8001fbb0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003bac:	0001ca17          	auipc	s4,0x1c
    80003bb0:	fd4a0a13          	addi	s4,s4,-44 # 8001fb80 <log>
    80003bb4:	018a2583          	lw	a1,24(s4)
    80003bb8:	012585bb          	addw	a1,a1,s2
    80003bbc:	2585                	addiw	a1,a1,1
    80003bbe:	028a2503          	lw	a0,40(s4)
    80003bc2:	f0ffe0ef          	jal	80002ad0 <bread>
    80003bc6:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003bc8:	000aa583          	lw	a1,0(s5)
    80003bcc:	028a2503          	lw	a0,40(s4)
    80003bd0:	f01fe0ef          	jal	80002ad0 <bread>
    80003bd4:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003bd6:	40000613          	li	a2,1024
    80003bda:	05850593          	addi	a1,a0,88
    80003bde:	05848513          	addi	a0,s1,88
    80003be2:	942fd0ef          	jal	80000d24 <memmove>
    bwrite(to);  // write the log
    80003be6:	8526                	mv	a0,s1
    80003be8:	fbffe0ef          	jal	80002ba6 <bwrite>
    brelse(from);
    80003bec:	854e                	mv	a0,s3
    80003bee:	febfe0ef          	jal	80002bd8 <brelse>
    brelse(to);
    80003bf2:	8526                	mv	a0,s1
    80003bf4:	fe5fe0ef          	jal	80002bd8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003bf8:	2905                	addiw	s2,s2,1
    80003bfa:	0a91                	addi	s5,s5,4
    80003bfc:	02ca2783          	lw	a5,44(s4)
    80003c00:	faf94ae3          	blt	s2,a5,80003bb4 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003c04:	d11ff0ef          	jal	80003914 <write_head>
    install_trans(0); // Now install writes to home locations
    80003c08:	4501                	li	a0,0
    80003c0a:	d69ff0ef          	jal	80003972 <install_trans>
    log.lh.n = 0;
    80003c0e:	0001c797          	auipc	a5,0x1c
    80003c12:	f807af23          	sw	zero,-98(a5) # 8001fbac <log+0x2c>
    write_head();    // Erase the transaction from the log
    80003c16:	cffff0ef          	jal	80003914 <write_head>
    80003c1a:	69e2                	ld	s3,24(sp)
    80003c1c:	6a42                	ld	s4,16(sp)
    80003c1e:	6aa2                	ld	s5,8(sp)
    80003c20:	b735                	j	80003b4c <end_op+0x44>

0000000080003c22 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003c22:	1101                	addi	sp,sp,-32
    80003c24:	ec06                	sd	ra,24(sp)
    80003c26:	e822                	sd	s0,16(sp)
    80003c28:	e426                	sd	s1,8(sp)
    80003c2a:	e04a                	sd	s2,0(sp)
    80003c2c:	1000                	addi	s0,sp,32
    80003c2e:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003c30:	0001c917          	auipc	s2,0x1c
    80003c34:	f5090913          	addi	s2,s2,-176 # 8001fb80 <log>
    80003c38:	854a                	mv	a0,s2
    80003c3a:	fbbfc0ef          	jal	80000bf4 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80003c3e:	02c92603          	lw	a2,44(s2)
    80003c42:	47f5                	li	a5,29
    80003c44:	06c7c363          	blt	a5,a2,80003caa <log_write+0x88>
    80003c48:	0001c797          	auipc	a5,0x1c
    80003c4c:	f547a783          	lw	a5,-172(a5) # 8001fb9c <log+0x1c>
    80003c50:	37fd                	addiw	a5,a5,-1
    80003c52:	04f65c63          	bge	a2,a5,80003caa <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003c56:	0001c797          	auipc	a5,0x1c
    80003c5a:	f4a7a783          	lw	a5,-182(a5) # 8001fba0 <log+0x20>
    80003c5e:	04f05c63          	blez	a5,80003cb6 <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003c62:	4781                	li	a5,0
    80003c64:	04c05f63          	blez	a2,80003cc2 <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003c68:	44cc                	lw	a1,12(s1)
    80003c6a:	0001c717          	auipc	a4,0x1c
    80003c6e:	f4670713          	addi	a4,a4,-186 # 8001fbb0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003c72:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003c74:	4314                	lw	a3,0(a4)
    80003c76:	04b68663          	beq	a3,a1,80003cc2 <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    80003c7a:	2785                	addiw	a5,a5,1
    80003c7c:	0711                	addi	a4,a4,4
    80003c7e:	fef61be3          	bne	a2,a5,80003c74 <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003c82:	0621                	addi	a2,a2,8
    80003c84:	060a                	slli	a2,a2,0x2
    80003c86:	0001c797          	auipc	a5,0x1c
    80003c8a:	efa78793          	addi	a5,a5,-262 # 8001fb80 <log>
    80003c8e:	97b2                	add	a5,a5,a2
    80003c90:	44d8                	lw	a4,12(s1)
    80003c92:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003c94:	8526                	mv	a0,s1
    80003c96:	fcbfe0ef          	jal	80002c60 <bpin>
    log.lh.n++;
    80003c9a:	0001c717          	auipc	a4,0x1c
    80003c9e:	ee670713          	addi	a4,a4,-282 # 8001fb80 <log>
    80003ca2:	575c                	lw	a5,44(a4)
    80003ca4:	2785                	addiw	a5,a5,1
    80003ca6:	d75c                	sw	a5,44(a4)
    80003ca8:	a80d                	j	80003cda <log_write+0xb8>
    panic("too big a transaction");
    80003caa:	00004517          	auipc	a0,0x4
    80003cae:	9f650513          	addi	a0,a0,-1546 # 800076a0 <etext+0x6a0>
    80003cb2:	ae3fc0ef          	jal	80000794 <panic>
    panic("log_write outside of trans");
    80003cb6:	00004517          	auipc	a0,0x4
    80003cba:	a0250513          	addi	a0,a0,-1534 # 800076b8 <etext+0x6b8>
    80003cbe:	ad7fc0ef          	jal	80000794 <panic>
  log.lh.block[i] = b->blockno;
    80003cc2:	00878693          	addi	a3,a5,8
    80003cc6:	068a                	slli	a3,a3,0x2
    80003cc8:	0001c717          	auipc	a4,0x1c
    80003ccc:	eb870713          	addi	a4,a4,-328 # 8001fb80 <log>
    80003cd0:	9736                	add	a4,a4,a3
    80003cd2:	44d4                	lw	a3,12(s1)
    80003cd4:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003cd6:	faf60fe3          	beq	a2,a5,80003c94 <log_write+0x72>
  }
  release(&log.lock);
    80003cda:	0001c517          	auipc	a0,0x1c
    80003cde:	ea650513          	addi	a0,a0,-346 # 8001fb80 <log>
    80003ce2:	fabfc0ef          	jal	80000c8c <release>
}
    80003ce6:	60e2                	ld	ra,24(sp)
    80003ce8:	6442                	ld	s0,16(sp)
    80003cea:	64a2                	ld	s1,8(sp)
    80003cec:	6902                	ld	s2,0(sp)
    80003cee:	6105                	addi	sp,sp,32
    80003cf0:	8082                	ret

0000000080003cf2 <log_message>:
#include "riscv.h"
#include "defs.h"
#include "custom_logger.h"

// Implementing the logger function
void log_message(enum log_level level, const char *message) {
    80003cf2:	1141                	addi	sp,sp,-16
    80003cf4:	e406                	sd	ra,8(sp)
    80003cf6:	e022                	sd	s0,0(sp)
    80003cf8:	0800                	addi	s0,sp,16
    // Based on the log level, we print the appropriate prefix.
    switch (level) {
    80003cfa:	4785                	li	a5,1
    80003cfc:	02f50063          	beq	a0,a5,80003d1c <log_message+0x2a>
    80003d00:	4789                	li	a5,2
    80003d02:	02f50463          	beq	a0,a5,80003d2a <log_message+0x38>
    80003d06:	e90d                	bnez	a0,80003d38 <log_message+0x46>
        case INFO:
            printf("[INFO] %s\n", message);
    80003d08:	00004517          	auipc	a0,0x4
    80003d0c:	9d050513          	addi	a0,a0,-1584 # 800076d8 <etext+0x6d8>
    80003d10:	fb2fc0ef          	jal	800004c2 <printf>
            break;
        default:
            printf("[UNKNOWN] %s\n", message); // For possible error
            break;
    }
    80003d14:	60a2                	ld	ra,8(sp)
    80003d16:	6402                	ld	s0,0(sp)
    80003d18:	0141                	addi	sp,sp,16
    80003d1a:	8082                	ret
            printf("[WARN] %s\n", message);
    80003d1c:	00004517          	auipc	a0,0x4
    80003d20:	9cc50513          	addi	a0,a0,-1588 # 800076e8 <etext+0x6e8>
    80003d24:	f9efc0ef          	jal	800004c2 <printf>
            break;
    80003d28:	b7f5                	j	80003d14 <log_message+0x22>
            printf("[ERROR] %s\n", message);
    80003d2a:	00004517          	auipc	a0,0x4
    80003d2e:	9ce50513          	addi	a0,a0,-1586 # 800076f8 <etext+0x6f8>
    80003d32:	f90fc0ef          	jal	800004c2 <printf>
            break;
    80003d36:	bff9                	j	80003d14 <log_message+0x22>
            printf("[UNKNOWN] %s\n", message); // For possible error
    80003d38:	00004517          	auipc	a0,0x4
    80003d3c:	9d050513          	addi	a0,a0,-1584 # 80007708 <etext+0x708>
    80003d40:	f82fc0ef          	jal	800004c2 <printf>
    80003d44:	bfc1                	j	80003d14 <log_message+0x22>

0000000080003d46 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003d46:	1101                	addi	sp,sp,-32
    80003d48:	ec06                	sd	ra,24(sp)
    80003d4a:	e822                	sd	s0,16(sp)
    80003d4c:	e426                	sd	s1,8(sp)
    80003d4e:	e04a                	sd	s2,0(sp)
    80003d50:	1000                	addi	s0,sp,32
    80003d52:	84aa                	mv	s1,a0
    80003d54:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003d56:	00004597          	auipc	a1,0x4
    80003d5a:	9c258593          	addi	a1,a1,-1598 # 80007718 <etext+0x718>
    80003d5e:	0521                	addi	a0,a0,8
    80003d60:	e15fc0ef          	jal	80000b74 <initlock>
  lk->name = name;
    80003d64:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003d68:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003d6c:	0204a423          	sw	zero,40(s1)
}
    80003d70:	60e2                	ld	ra,24(sp)
    80003d72:	6442                	ld	s0,16(sp)
    80003d74:	64a2                	ld	s1,8(sp)
    80003d76:	6902                	ld	s2,0(sp)
    80003d78:	6105                	addi	sp,sp,32
    80003d7a:	8082                	ret

0000000080003d7c <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003d7c:	1101                	addi	sp,sp,-32
    80003d7e:	ec06                	sd	ra,24(sp)
    80003d80:	e822                	sd	s0,16(sp)
    80003d82:	e426                	sd	s1,8(sp)
    80003d84:	e04a                	sd	s2,0(sp)
    80003d86:	1000                	addi	s0,sp,32
    80003d88:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003d8a:	00850913          	addi	s2,a0,8
    80003d8e:	854a                	mv	a0,s2
    80003d90:	e65fc0ef          	jal	80000bf4 <acquire>
  while (lk->locked) {
    80003d94:	409c                	lw	a5,0(s1)
    80003d96:	c799                	beqz	a5,80003da4 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003d98:	85ca                	mv	a1,s2
    80003d9a:	8526                	mv	a0,s1
    80003d9c:	93cfe0ef          	jal	80001ed8 <sleep>
  while (lk->locked) {
    80003da0:	409c                	lw	a5,0(s1)
    80003da2:	fbfd                	bnez	a5,80003d98 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003da4:	4785                	li	a5,1
    80003da6:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003da8:	b63fd0ef          	jal	8000190a <myproc>
    80003dac:	591c                	lw	a5,48(a0)
    80003dae:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003db0:	854a                	mv	a0,s2
    80003db2:	edbfc0ef          	jal	80000c8c <release>
}
    80003db6:	60e2                	ld	ra,24(sp)
    80003db8:	6442                	ld	s0,16(sp)
    80003dba:	64a2                	ld	s1,8(sp)
    80003dbc:	6902                	ld	s2,0(sp)
    80003dbe:	6105                	addi	sp,sp,32
    80003dc0:	8082                	ret

0000000080003dc2 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003dc2:	1101                	addi	sp,sp,-32
    80003dc4:	ec06                	sd	ra,24(sp)
    80003dc6:	e822                	sd	s0,16(sp)
    80003dc8:	e426                	sd	s1,8(sp)
    80003dca:	e04a                	sd	s2,0(sp)
    80003dcc:	1000                	addi	s0,sp,32
    80003dce:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003dd0:	00850913          	addi	s2,a0,8
    80003dd4:	854a                	mv	a0,s2
    80003dd6:	e1ffc0ef          	jal	80000bf4 <acquire>
  lk->locked = 0;
    80003dda:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003dde:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003de2:	8526                	mv	a0,s1
    80003de4:	940fe0ef          	jal	80001f24 <wakeup>
  release(&lk->lk);
    80003de8:	854a                	mv	a0,s2
    80003dea:	ea3fc0ef          	jal	80000c8c <release>
}
    80003dee:	60e2                	ld	ra,24(sp)
    80003df0:	6442                	ld	s0,16(sp)
    80003df2:	64a2                	ld	s1,8(sp)
    80003df4:	6902                	ld	s2,0(sp)
    80003df6:	6105                	addi	sp,sp,32
    80003df8:	8082                	ret

0000000080003dfa <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003dfa:	7179                	addi	sp,sp,-48
    80003dfc:	f406                	sd	ra,40(sp)
    80003dfe:	f022                	sd	s0,32(sp)
    80003e00:	ec26                	sd	s1,24(sp)
    80003e02:	e84a                	sd	s2,16(sp)
    80003e04:	1800                	addi	s0,sp,48
    80003e06:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003e08:	00850913          	addi	s2,a0,8
    80003e0c:	854a                	mv	a0,s2
    80003e0e:	de7fc0ef          	jal	80000bf4 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003e12:	409c                	lw	a5,0(s1)
    80003e14:	ef81                	bnez	a5,80003e2c <holdingsleep+0x32>
    80003e16:	4481                	li	s1,0
  release(&lk->lk);
    80003e18:	854a                	mv	a0,s2
    80003e1a:	e73fc0ef          	jal	80000c8c <release>
  return r;
}
    80003e1e:	8526                	mv	a0,s1
    80003e20:	70a2                	ld	ra,40(sp)
    80003e22:	7402                	ld	s0,32(sp)
    80003e24:	64e2                	ld	s1,24(sp)
    80003e26:	6942                	ld	s2,16(sp)
    80003e28:	6145                	addi	sp,sp,48
    80003e2a:	8082                	ret
    80003e2c:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80003e2e:	0284a983          	lw	s3,40(s1)
    80003e32:	ad9fd0ef          	jal	8000190a <myproc>
    80003e36:	5904                	lw	s1,48(a0)
    80003e38:	413484b3          	sub	s1,s1,s3
    80003e3c:	0014b493          	seqz	s1,s1
    80003e40:	69a2                	ld	s3,8(sp)
    80003e42:	bfd9                	j	80003e18 <holdingsleep+0x1e>

0000000080003e44 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003e44:	1141                	addi	sp,sp,-16
    80003e46:	e406                	sd	ra,8(sp)
    80003e48:	e022                	sd	s0,0(sp)
    80003e4a:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003e4c:	00004597          	auipc	a1,0x4
    80003e50:	8dc58593          	addi	a1,a1,-1828 # 80007728 <etext+0x728>
    80003e54:	0001c517          	auipc	a0,0x1c
    80003e58:	e7450513          	addi	a0,a0,-396 # 8001fcc8 <ftable>
    80003e5c:	d19fc0ef          	jal	80000b74 <initlock>
}
    80003e60:	60a2                	ld	ra,8(sp)
    80003e62:	6402                	ld	s0,0(sp)
    80003e64:	0141                	addi	sp,sp,16
    80003e66:	8082                	ret

0000000080003e68 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80003e68:	1101                	addi	sp,sp,-32
    80003e6a:	ec06                	sd	ra,24(sp)
    80003e6c:	e822                	sd	s0,16(sp)
    80003e6e:	e426                	sd	s1,8(sp)
    80003e70:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80003e72:	0001c517          	auipc	a0,0x1c
    80003e76:	e5650513          	addi	a0,a0,-426 # 8001fcc8 <ftable>
    80003e7a:	d7bfc0ef          	jal	80000bf4 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003e7e:	0001c497          	auipc	s1,0x1c
    80003e82:	e6248493          	addi	s1,s1,-414 # 8001fce0 <ftable+0x18>
    80003e86:	0001d717          	auipc	a4,0x1d
    80003e8a:	dfa70713          	addi	a4,a4,-518 # 80020c80 <disk>
    if(f->ref == 0){
    80003e8e:	40dc                	lw	a5,4(s1)
    80003e90:	cf89                	beqz	a5,80003eaa <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003e92:	02848493          	addi	s1,s1,40
    80003e96:	fee49ce3          	bne	s1,a4,80003e8e <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80003e9a:	0001c517          	auipc	a0,0x1c
    80003e9e:	e2e50513          	addi	a0,a0,-466 # 8001fcc8 <ftable>
    80003ea2:	debfc0ef          	jal	80000c8c <release>
  return 0;
    80003ea6:	4481                	li	s1,0
    80003ea8:	a809                	j	80003eba <filealloc+0x52>
      f->ref = 1;
    80003eaa:	4785                	li	a5,1
    80003eac:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80003eae:	0001c517          	auipc	a0,0x1c
    80003eb2:	e1a50513          	addi	a0,a0,-486 # 8001fcc8 <ftable>
    80003eb6:	dd7fc0ef          	jal	80000c8c <release>
}
    80003eba:	8526                	mv	a0,s1
    80003ebc:	60e2                	ld	ra,24(sp)
    80003ebe:	6442                	ld	s0,16(sp)
    80003ec0:	64a2                	ld	s1,8(sp)
    80003ec2:	6105                	addi	sp,sp,32
    80003ec4:	8082                	ret

0000000080003ec6 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003ec6:	1101                	addi	sp,sp,-32
    80003ec8:	ec06                	sd	ra,24(sp)
    80003eca:	e822                	sd	s0,16(sp)
    80003ecc:	e426                	sd	s1,8(sp)
    80003ece:	1000                	addi	s0,sp,32
    80003ed0:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003ed2:	0001c517          	auipc	a0,0x1c
    80003ed6:	df650513          	addi	a0,a0,-522 # 8001fcc8 <ftable>
    80003eda:	d1bfc0ef          	jal	80000bf4 <acquire>
  if(f->ref < 1)
    80003ede:	40dc                	lw	a5,4(s1)
    80003ee0:	02f05063          	blez	a5,80003f00 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80003ee4:	2785                	addiw	a5,a5,1
    80003ee6:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003ee8:	0001c517          	auipc	a0,0x1c
    80003eec:	de050513          	addi	a0,a0,-544 # 8001fcc8 <ftable>
    80003ef0:	d9dfc0ef          	jal	80000c8c <release>
  return f;
}
    80003ef4:	8526                	mv	a0,s1
    80003ef6:	60e2                	ld	ra,24(sp)
    80003ef8:	6442                	ld	s0,16(sp)
    80003efa:	64a2                	ld	s1,8(sp)
    80003efc:	6105                	addi	sp,sp,32
    80003efe:	8082                	ret
    panic("filedup");
    80003f00:	00004517          	auipc	a0,0x4
    80003f04:	83050513          	addi	a0,a0,-2000 # 80007730 <etext+0x730>
    80003f08:	88dfc0ef          	jal	80000794 <panic>

0000000080003f0c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80003f0c:	7139                	addi	sp,sp,-64
    80003f0e:	fc06                	sd	ra,56(sp)
    80003f10:	f822                	sd	s0,48(sp)
    80003f12:	f426                	sd	s1,40(sp)
    80003f14:	0080                	addi	s0,sp,64
    80003f16:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80003f18:	0001c517          	auipc	a0,0x1c
    80003f1c:	db050513          	addi	a0,a0,-592 # 8001fcc8 <ftable>
    80003f20:	cd5fc0ef          	jal	80000bf4 <acquire>
  if(f->ref < 1)
    80003f24:	40dc                	lw	a5,4(s1)
    80003f26:	04f05a63          	blez	a5,80003f7a <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    80003f2a:	37fd                	addiw	a5,a5,-1
    80003f2c:	0007871b          	sext.w	a4,a5
    80003f30:	c0dc                	sw	a5,4(s1)
    80003f32:	04e04e63          	bgtz	a4,80003f8e <fileclose+0x82>
    80003f36:	f04a                	sd	s2,32(sp)
    80003f38:	ec4e                	sd	s3,24(sp)
    80003f3a:	e852                	sd	s4,16(sp)
    80003f3c:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80003f3e:	0004a903          	lw	s2,0(s1)
    80003f42:	0094ca83          	lbu	s5,9(s1)
    80003f46:	0104ba03          	ld	s4,16(s1)
    80003f4a:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80003f4e:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80003f52:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80003f56:	0001c517          	auipc	a0,0x1c
    80003f5a:	d7250513          	addi	a0,a0,-654 # 8001fcc8 <ftable>
    80003f5e:	d2ffc0ef          	jal	80000c8c <release>

  if(ff.type == FD_PIPE){
    80003f62:	4785                	li	a5,1
    80003f64:	04f90063          	beq	s2,a5,80003fa4 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80003f68:	3979                	addiw	s2,s2,-2
    80003f6a:	4785                	li	a5,1
    80003f6c:	0527f563          	bgeu	a5,s2,80003fb6 <fileclose+0xaa>
    80003f70:	7902                	ld	s2,32(sp)
    80003f72:	69e2                	ld	s3,24(sp)
    80003f74:	6a42                	ld	s4,16(sp)
    80003f76:	6aa2                	ld	s5,8(sp)
    80003f78:	a00d                	j	80003f9a <fileclose+0x8e>
    80003f7a:	f04a                	sd	s2,32(sp)
    80003f7c:	ec4e                	sd	s3,24(sp)
    80003f7e:	e852                	sd	s4,16(sp)
    80003f80:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80003f82:	00003517          	auipc	a0,0x3
    80003f86:	7b650513          	addi	a0,a0,1974 # 80007738 <etext+0x738>
    80003f8a:	80bfc0ef          	jal	80000794 <panic>
    release(&ftable.lock);
    80003f8e:	0001c517          	auipc	a0,0x1c
    80003f92:	d3a50513          	addi	a0,a0,-710 # 8001fcc8 <ftable>
    80003f96:	cf7fc0ef          	jal	80000c8c <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80003f9a:	70e2                	ld	ra,56(sp)
    80003f9c:	7442                	ld	s0,48(sp)
    80003f9e:	74a2                	ld	s1,40(sp)
    80003fa0:	6121                	addi	sp,sp,64
    80003fa2:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80003fa4:	85d6                	mv	a1,s5
    80003fa6:	8552                	mv	a0,s4
    80003fa8:	336000ef          	jal	800042de <pipeclose>
    80003fac:	7902                	ld	s2,32(sp)
    80003fae:	69e2                	ld	s3,24(sp)
    80003fb0:	6a42                	ld	s4,16(sp)
    80003fb2:	6aa2                	ld	s5,8(sp)
    80003fb4:	b7dd                	j	80003f9a <fileclose+0x8e>
    begin_op();
    80003fb6:	ae9ff0ef          	jal	80003a9e <begin_op>
    iput(ff.ip);
    80003fba:	854e                	mv	a0,s3
    80003fbc:	bceff0ef          	jal	8000338a <iput>
    end_op();
    80003fc0:	b49ff0ef          	jal	80003b08 <end_op>
    80003fc4:	7902                	ld	s2,32(sp)
    80003fc6:	69e2                	ld	s3,24(sp)
    80003fc8:	6a42                	ld	s4,16(sp)
    80003fca:	6aa2                	ld	s5,8(sp)
    80003fcc:	b7f9                	j	80003f9a <fileclose+0x8e>

0000000080003fce <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80003fce:	715d                	addi	sp,sp,-80
    80003fd0:	e486                	sd	ra,72(sp)
    80003fd2:	e0a2                	sd	s0,64(sp)
    80003fd4:	fc26                	sd	s1,56(sp)
    80003fd6:	f44e                	sd	s3,40(sp)
    80003fd8:	0880                	addi	s0,sp,80
    80003fda:	84aa                	mv	s1,a0
    80003fdc:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80003fde:	92dfd0ef          	jal	8000190a <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80003fe2:	409c                	lw	a5,0(s1)
    80003fe4:	37f9                	addiw	a5,a5,-2
    80003fe6:	4705                	li	a4,1
    80003fe8:	04f76063          	bltu	a4,a5,80004028 <filestat+0x5a>
    80003fec:	f84a                	sd	s2,48(sp)
    80003fee:	892a                	mv	s2,a0
    ilock(f->ip);
    80003ff0:	6c88                	ld	a0,24(s1)
    80003ff2:	a16ff0ef          	jal	80003208 <ilock>
    stati(f->ip, &st);
    80003ff6:	fb840593          	addi	a1,s0,-72
    80003ffa:	6c88                	ld	a0,24(s1)
    80003ffc:	c36ff0ef          	jal	80003432 <stati>
    iunlock(f->ip);
    80004000:	6c88                	ld	a0,24(s1)
    80004002:	ab4ff0ef          	jal	800032b6 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004006:	46e1                	li	a3,24
    80004008:	fb840613          	addi	a2,s0,-72
    8000400c:	85ce                	mv	a1,s3
    8000400e:	05093503          	ld	a0,80(s2)
    80004012:	d6afd0ef          	jal	8000157c <copyout>
    80004016:	41f5551b          	sraiw	a0,a0,0x1f
    8000401a:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    8000401c:	60a6                	ld	ra,72(sp)
    8000401e:	6406                	ld	s0,64(sp)
    80004020:	74e2                	ld	s1,56(sp)
    80004022:	79a2                	ld	s3,40(sp)
    80004024:	6161                	addi	sp,sp,80
    80004026:	8082                	ret
  return -1;
    80004028:	557d                	li	a0,-1
    8000402a:	bfcd                	j	8000401c <filestat+0x4e>

000000008000402c <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000402c:	7179                	addi	sp,sp,-48
    8000402e:	f406                	sd	ra,40(sp)
    80004030:	f022                	sd	s0,32(sp)
    80004032:	e84a                	sd	s2,16(sp)
    80004034:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004036:	00854783          	lbu	a5,8(a0)
    8000403a:	cfd1                	beqz	a5,800040d6 <fileread+0xaa>
    8000403c:	ec26                	sd	s1,24(sp)
    8000403e:	e44e                	sd	s3,8(sp)
    80004040:	84aa                	mv	s1,a0
    80004042:	89ae                	mv	s3,a1
    80004044:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004046:	411c                	lw	a5,0(a0)
    80004048:	4705                	li	a4,1
    8000404a:	04e78363          	beq	a5,a4,80004090 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000404e:	470d                	li	a4,3
    80004050:	04e78763          	beq	a5,a4,8000409e <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004054:	4709                	li	a4,2
    80004056:	06e79a63          	bne	a5,a4,800040ca <fileread+0x9e>
    ilock(f->ip);
    8000405a:	6d08                	ld	a0,24(a0)
    8000405c:	9acff0ef          	jal	80003208 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004060:	874a                	mv	a4,s2
    80004062:	5094                	lw	a3,32(s1)
    80004064:	864e                	mv	a2,s3
    80004066:	4585                	li	a1,1
    80004068:	6c88                	ld	a0,24(s1)
    8000406a:	bf2ff0ef          	jal	8000345c <readi>
    8000406e:	892a                	mv	s2,a0
    80004070:	00a05563          	blez	a0,8000407a <fileread+0x4e>
      f->off += r;
    80004074:	509c                	lw	a5,32(s1)
    80004076:	9fa9                	addw	a5,a5,a0
    80004078:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000407a:	6c88                	ld	a0,24(s1)
    8000407c:	a3aff0ef          	jal	800032b6 <iunlock>
    80004080:	64e2                	ld	s1,24(sp)
    80004082:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004084:	854a                	mv	a0,s2
    80004086:	70a2                	ld	ra,40(sp)
    80004088:	7402                	ld	s0,32(sp)
    8000408a:	6942                	ld	s2,16(sp)
    8000408c:	6145                	addi	sp,sp,48
    8000408e:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004090:	6908                	ld	a0,16(a0)
    80004092:	388000ef          	jal	8000441a <piperead>
    80004096:	892a                	mv	s2,a0
    80004098:	64e2                	ld	s1,24(sp)
    8000409a:	69a2                	ld	s3,8(sp)
    8000409c:	b7e5                	j	80004084 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000409e:	02451783          	lh	a5,36(a0)
    800040a2:	03079693          	slli	a3,a5,0x30
    800040a6:	92c1                	srli	a3,a3,0x30
    800040a8:	4725                	li	a4,9
    800040aa:	02d76863          	bltu	a4,a3,800040da <fileread+0xae>
    800040ae:	0792                	slli	a5,a5,0x4
    800040b0:	0001c717          	auipc	a4,0x1c
    800040b4:	b7870713          	addi	a4,a4,-1160 # 8001fc28 <devsw>
    800040b8:	97ba                	add	a5,a5,a4
    800040ba:	639c                	ld	a5,0(a5)
    800040bc:	c39d                	beqz	a5,800040e2 <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    800040be:	4505                	li	a0,1
    800040c0:	9782                	jalr	a5
    800040c2:	892a                	mv	s2,a0
    800040c4:	64e2                	ld	s1,24(sp)
    800040c6:	69a2                	ld	s3,8(sp)
    800040c8:	bf75                	j	80004084 <fileread+0x58>
    panic("fileread");
    800040ca:	00003517          	auipc	a0,0x3
    800040ce:	67e50513          	addi	a0,a0,1662 # 80007748 <etext+0x748>
    800040d2:	ec2fc0ef          	jal	80000794 <panic>
    return -1;
    800040d6:	597d                	li	s2,-1
    800040d8:	b775                	j	80004084 <fileread+0x58>
      return -1;
    800040da:	597d                	li	s2,-1
    800040dc:	64e2                	ld	s1,24(sp)
    800040de:	69a2                	ld	s3,8(sp)
    800040e0:	b755                	j	80004084 <fileread+0x58>
    800040e2:	597d                	li	s2,-1
    800040e4:	64e2                	ld	s1,24(sp)
    800040e6:	69a2                	ld	s3,8(sp)
    800040e8:	bf71                	j	80004084 <fileread+0x58>

00000000800040ea <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800040ea:	00954783          	lbu	a5,9(a0)
    800040ee:	10078b63          	beqz	a5,80004204 <filewrite+0x11a>
{
    800040f2:	715d                	addi	sp,sp,-80
    800040f4:	e486                	sd	ra,72(sp)
    800040f6:	e0a2                	sd	s0,64(sp)
    800040f8:	f84a                	sd	s2,48(sp)
    800040fa:	f052                	sd	s4,32(sp)
    800040fc:	e85a                	sd	s6,16(sp)
    800040fe:	0880                	addi	s0,sp,80
    80004100:	892a                	mv	s2,a0
    80004102:	8b2e                	mv	s6,a1
    80004104:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004106:	411c                	lw	a5,0(a0)
    80004108:	4705                	li	a4,1
    8000410a:	02e78763          	beq	a5,a4,80004138 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000410e:	470d                	li	a4,3
    80004110:	02e78863          	beq	a5,a4,80004140 <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004114:	4709                	li	a4,2
    80004116:	0ce79c63          	bne	a5,a4,800041ee <filewrite+0x104>
    8000411a:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000411c:	0ac05863          	blez	a2,800041cc <filewrite+0xe2>
    80004120:	fc26                	sd	s1,56(sp)
    80004122:	ec56                	sd	s5,24(sp)
    80004124:	e45e                	sd	s7,8(sp)
    80004126:	e062                	sd	s8,0(sp)
    int i = 0;
    80004128:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    8000412a:	6b85                	lui	s7,0x1
    8000412c:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004130:	6c05                	lui	s8,0x1
    80004132:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004136:	a8b5                	j	800041b2 <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    80004138:	6908                	ld	a0,16(a0)
    8000413a:	1fc000ef          	jal	80004336 <pipewrite>
    8000413e:	a04d                	j	800041e0 <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004140:	02451783          	lh	a5,36(a0)
    80004144:	03079693          	slli	a3,a5,0x30
    80004148:	92c1                	srli	a3,a3,0x30
    8000414a:	4725                	li	a4,9
    8000414c:	0ad76e63          	bltu	a4,a3,80004208 <filewrite+0x11e>
    80004150:	0792                	slli	a5,a5,0x4
    80004152:	0001c717          	auipc	a4,0x1c
    80004156:	ad670713          	addi	a4,a4,-1322 # 8001fc28 <devsw>
    8000415a:	97ba                	add	a5,a5,a4
    8000415c:	679c                	ld	a5,8(a5)
    8000415e:	c7dd                	beqz	a5,8000420c <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    80004160:	4505                	li	a0,1
    80004162:	9782                	jalr	a5
    80004164:	a8b5                	j	800041e0 <filewrite+0xf6>
      if(n1 > max)
    80004166:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    8000416a:	935ff0ef          	jal	80003a9e <begin_op>
      ilock(f->ip);
    8000416e:	01893503          	ld	a0,24(s2)
    80004172:	896ff0ef          	jal	80003208 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004176:	8756                	mv	a4,s5
    80004178:	02092683          	lw	a3,32(s2)
    8000417c:	01698633          	add	a2,s3,s6
    80004180:	4585                	li	a1,1
    80004182:	01893503          	ld	a0,24(s2)
    80004186:	bd2ff0ef          	jal	80003558 <writei>
    8000418a:	84aa                	mv	s1,a0
    8000418c:	00a05763          	blez	a0,8000419a <filewrite+0xb0>
        f->off += r;
    80004190:	02092783          	lw	a5,32(s2)
    80004194:	9fa9                	addw	a5,a5,a0
    80004196:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000419a:	01893503          	ld	a0,24(s2)
    8000419e:	918ff0ef          	jal	800032b6 <iunlock>
      end_op();
    800041a2:	967ff0ef          	jal	80003b08 <end_op>

      if(r != n1){
    800041a6:	029a9563          	bne	s5,s1,800041d0 <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    800041aa:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800041ae:	0149da63          	bge	s3,s4,800041c2 <filewrite+0xd8>
      int n1 = n - i;
    800041b2:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    800041b6:	0004879b          	sext.w	a5,s1
    800041ba:	fafbd6e3          	bge	s7,a5,80004166 <filewrite+0x7c>
    800041be:	84e2                	mv	s1,s8
    800041c0:	b75d                	j	80004166 <filewrite+0x7c>
    800041c2:	74e2                	ld	s1,56(sp)
    800041c4:	6ae2                	ld	s5,24(sp)
    800041c6:	6ba2                	ld	s7,8(sp)
    800041c8:	6c02                	ld	s8,0(sp)
    800041ca:	a039                	j	800041d8 <filewrite+0xee>
    int i = 0;
    800041cc:	4981                	li	s3,0
    800041ce:	a029                	j	800041d8 <filewrite+0xee>
    800041d0:	74e2                	ld	s1,56(sp)
    800041d2:	6ae2                	ld	s5,24(sp)
    800041d4:	6ba2                	ld	s7,8(sp)
    800041d6:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    800041d8:	033a1c63          	bne	s4,s3,80004210 <filewrite+0x126>
    800041dc:	8552                	mv	a0,s4
    800041de:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    800041e0:	60a6                	ld	ra,72(sp)
    800041e2:	6406                	ld	s0,64(sp)
    800041e4:	7942                	ld	s2,48(sp)
    800041e6:	7a02                	ld	s4,32(sp)
    800041e8:	6b42                	ld	s6,16(sp)
    800041ea:	6161                	addi	sp,sp,80
    800041ec:	8082                	ret
    800041ee:	fc26                	sd	s1,56(sp)
    800041f0:	f44e                	sd	s3,40(sp)
    800041f2:	ec56                	sd	s5,24(sp)
    800041f4:	e45e                	sd	s7,8(sp)
    800041f6:	e062                	sd	s8,0(sp)
    panic("filewrite");
    800041f8:	00003517          	auipc	a0,0x3
    800041fc:	56050513          	addi	a0,a0,1376 # 80007758 <etext+0x758>
    80004200:	d94fc0ef          	jal	80000794 <panic>
    return -1;
    80004204:	557d                	li	a0,-1
}
    80004206:	8082                	ret
      return -1;
    80004208:	557d                	li	a0,-1
    8000420a:	bfd9                	j	800041e0 <filewrite+0xf6>
    8000420c:	557d                	li	a0,-1
    8000420e:	bfc9                	j	800041e0 <filewrite+0xf6>
    ret = (i == n ? n : -1);
    80004210:	557d                	li	a0,-1
    80004212:	79a2                	ld	s3,40(sp)
    80004214:	b7f1                	j	800041e0 <filewrite+0xf6>

0000000080004216 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004216:	7179                	addi	sp,sp,-48
    80004218:	f406                	sd	ra,40(sp)
    8000421a:	f022                	sd	s0,32(sp)
    8000421c:	ec26                	sd	s1,24(sp)
    8000421e:	e052                	sd	s4,0(sp)
    80004220:	1800                	addi	s0,sp,48
    80004222:	84aa                	mv	s1,a0
    80004224:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004226:	0005b023          	sd	zero,0(a1)
    8000422a:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000422e:	c3bff0ef          	jal	80003e68 <filealloc>
    80004232:	e088                	sd	a0,0(s1)
    80004234:	c549                	beqz	a0,800042be <pipealloc+0xa8>
    80004236:	c33ff0ef          	jal	80003e68 <filealloc>
    8000423a:	00aa3023          	sd	a0,0(s4)
    8000423e:	cd25                	beqz	a0,800042b6 <pipealloc+0xa0>
    80004240:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004242:	8e3fc0ef          	jal	80000b24 <kalloc>
    80004246:	892a                	mv	s2,a0
    80004248:	c12d                	beqz	a0,800042aa <pipealloc+0x94>
    8000424a:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    8000424c:	4985                	li	s3,1
    8000424e:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004252:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004256:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000425a:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000425e:	00003597          	auipc	a1,0x3
    80004262:	50a58593          	addi	a1,a1,1290 # 80007768 <etext+0x768>
    80004266:	90ffc0ef          	jal	80000b74 <initlock>
  (*f0)->type = FD_PIPE;
    8000426a:	609c                	ld	a5,0(s1)
    8000426c:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004270:	609c                	ld	a5,0(s1)
    80004272:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004276:	609c                	ld	a5,0(s1)
    80004278:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000427c:	609c                	ld	a5,0(s1)
    8000427e:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004282:	000a3783          	ld	a5,0(s4)
    80004286:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000428a:	000a3783          	ld	a5,0(s4)
    8000428e:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004292:	000a3783          	ld	a5,0(s4)
    80004296:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000429a:	000a3783          	ld	a5,0(s4)
    8000429e:	0127b823          	sd	s2,16(a5)
  return 0;
    800042a2:	4501                	li	a0,0
    800042a4:	6942                	ld	s2,16(sp)
    800042a6:	69a2                	ld	s3,8(sp)
    800042a8:	a01d                	j	800042ce <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800042aa:	6088                	ld	a0,0(s1)
    800042ac:	c119                	beqz	a0,800042b2 <pipealloc+0x9c>
    800042ae:	6942                	ld	s2,16(sp)
    800042b0:	a029                	j	800042ba <pipealloc+0xa4>
    800042b2:	6942                	ld	s2,16(sp)
    800042b4:	a029                	j	800042be <pipealloc+0xa8>
    800042b6:	6088                	ld	a0,0(s1)
    800042b8:	c10d                	beqz	a0,800042da <pipealloc+0xc4>
    fileclose(*f0);
    800042ba:	c53ff0ef          	jal	80003f0c <fileclose>
  if(*f1)
    800042be:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800042c2:	557d                	li	a0,-1
  if(*f1)
    800042c4:	c789                	beqz	a5,800042ce <pipealloc+0xb8>
    fileclose(*f1);
    800042c6:	853e                	mv	a0,a5
    800042c8:	c45ff0ef          	jal	80003f0c <fileclose>
  return -1;
    800042cc:	557d                	li	a0,-1
}
    800042ce:	70a2                	ld	ra,40(sp)
    800042d0:	7402                	ld	s0,32(sp)
    800042d2:	64e2                	ld	s1,24(sp)
    800042d4:	6a02                	ld	s4,0(sp)
    800042d6:	6145                	addi	sp,sp,48
    800042d8:	8082                	ret
  return -1;
    800042da:	557d                	li	a0,-1
    800042dc:	bfcd                	j	800042ce <pipealloc+0xb8>

00000000800042de <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800042de:	1101                	addi	sp,sp,-32
    800042e0:	ec06                	sd	ra,24(sp)
    800042e2:	e822                	sd	s0,16(sp)
    800042e4:	e426                	sd	s1,8(sp)
    800042e6:	e04a                	sd	s2,0(sp)
    800042e8:	1000                	addi	s0,sp,32
    800042ea:	84aa                	mv	s1,a0
    800042ec:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800042ee:	907fc0ef          	jal	80000bf4 <acquire>
  if(writable){
    800042f2:	02090763          	beqz	s2,80004320 <pipeclose+0x42>
    pi->writeopen = 0;
    800042f6:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800042fa:	21848513          	addi	a0,s1,536
    800042fe:	c27fd0ef          	jal	80001f24 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004302:	2204b783          	ld	a5,544(s1)
    80004306:	e785                	bnez	a5,8000432e <pipeclose+0x50>
    release(&pi->lock);
    80004308:	8526                	mv	a0,s1
    8000430a:	983fc0ef          	jal	80000c8c <release>
    kfree((char*)pi);
    8000430e:	8526                	mv	a0,s1
    80004310:	f32fc0ef          	jal	80000a42 <kfree>
  } else
    release(&pi->lock);
}
    80004314:	60e2                	ld	ra,24(sp)
    80004316:	6442                	ld	s0,16(sp)
    80004318:	64a2                	ld	s1,8(sp)
    8000431a:	6902                	ld	s2,0(sp)
    8000431c:	6105                	addi	sp,sp,32
    8000431e:	8082                	ret
    pi->readopen = 0;
    80004320:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004324:	21c48513          	addi	a0,s1,540
    80004328:	bfdfd0ef          	jal	80001f24 <wakeup>
    8000432c:	bfd9                	j	80004302 <pipeclose+0x24>
    release(&pi->lock);
    8000432e:	8526                	mv	a0,s1
    80004330:	95dfc0ef          	jal	80000c8c <release>
}
    80004334:	b7c5                	j	80004314 <pipeclose+0x36>

0000000080004336 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004336:	711d                	addi	sp,sp,-96
    80004338:	ec86                	sd	ra,88(sp)
    8000433a:	e8a2                	sd	s0,80(sp)
    8000433c:	e4a6                	sd	s1,72(sp)
    8000433e:	e0ca                	sd	s2,64(sp)
    80004340:	fc4e                	sd	s3,56(sp)
    80004342:	f852                	sd	s4,48(sp)
    80004344:	f456                	sd	s5,40(sp)
    80004346:	1080                	addi	s0,sp,96
    80004348:	84aa                	mv	s1,a0
    8000434a:	8aae                	mv	s5,a1
    8000434c:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000434e:	dbcfd0ef          	jal	8000190a <myproc>
    80004352:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004354:	8526                	mv	a0,s1
    80004356:	89ffc0ef          	jal	80000bf4 <acquire>
  while(i < n){
    8000435a:	0b405a63          	blez	s4,8000440e <pipewrite+0xd8>
    8000435e:	f05a                	sd	s6,32(sp)
    80004360:	ec5e                	sd	s7,24(sp)
    80004362:	e862                	sd	s8,16(sp)
  int i = 0;
    80004364:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004366:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004368:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000436c:	21c48b93          	addi	s7,s1,540
    80004370:	a81d                	j	800043a6 <pipewrite+0x70>
      release(&pi->lock);
    80004372:	8526                	mv	a0,s1
    80004374:	919fc0ef          	jal	80000c8c <release>
      return -1;
    80004378:	597d                	li	s2,-1
    8000437a:	7b02                	ld	s6,32(sp)
    8000437c:	6be2                	ld	s7,24(sp)
    8000437e:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004380:	854a                	mv	a0,s2
    80004382:	60e6                	ld	ra,88(sp)
    80004384:	6446                	ld	s0,80(sp)
    80004386:	64a6                	ld	s1,72(sp)
    80004388:	6906                	ld	s2,64(sp)
    8000438a:	79e2                	ld	s3,56(sp)
    8000438c:	7a42                	ld	s4,48(sp)
    8000438e:	7aa2                	ld	s5,40(sp)
    80004390:	6125                	addi	sp,sp,96
    80004392:	8082                	ret
      wakeup(&pi->nread);
    80004394:	8562                	mv	a0,s8
    80004396:	b8ffd0ef          	jal	80001f24 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000439a:	85a6                	mv	a1,s1
    8000439c:	855e                	mv	a0,s7
    8000439e:	b3bfd0ef          	jal	80001ed8 <sleep>
  while(i < n){
    800043a2:	05495b63          	bge	s2,s4,800043f8 <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    800043a6:	2204a783          	lw	a5,544(s1)
    800043aa:	d7e1                	beqz	a5,80004372 <pipewrite+0x3c>
    800043ac:	854e                	mv	a0,s3
    800043ae:	d63fd0ef          	jal	80002110 <killed>
    800043b2:	f161                	bnez	a0,80004372 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800043b4:	2184a783          	lw	a5,536(s1)
    800043b8:	21c4a703          	lw	a4,540(s1)
    800043bc:	2007879b          	addiw	a5,a5,512
    800043c0:	fcf70ae3          	beq	a4,a5,80004394 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800043c4:	4685                	li	a3,1
    800043c6:	01590633          	add	a2,s2,s5
    800043ca:	faf40593          	addi	a1,s0,-81
    800043ce:	0509b503          	ld	a0,80(s3)
    800043d2:	a80fd0ef          	jal	80001652 <copyin>
    800043d6:	03650e63          	beq	a0,s6,80004412 <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800043da:	21c4a783          	lw	a5,540(s1)
    800043de:	0017871b          	addiw	a4,a5,1
    800043e2:	20e4ae23          	sw	a4,540(s1)
    800043e6:	1ff7f793          	andi	a5,a5,511
    800043ea:	97a6                	add	a5,a5,s1
    800043ec:	faf44703          	lbu	a4,-81(s0)
    800043f0:	00e78c23          	sb	a4,24(a5)
      i++;
    800043f4:	2905                	addiw	s2,s2,1
    800043f6:	b775                	j	800043a2 <pipewrite+0x6c>
    800043f8:	7b02                	ld	s6,32(sp)
    800043fa:	6be2                	ld	s7,24(sp)
    800043fc:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    800043fe:	21848513          	addi	a0,s1,536
    80004402:	b23fd0ef          	jal	80001f24 <wakeup>
  release(&pi->lock);
    80004406:	8526                	mv	a0,s1
    80004408:	885fc0ef          	jal	80000c8c <release>
  return i;
    8000440c:	bf95                	j	80004380 <pipewrite+0x4a>
  int i = 0;
    8000440e:	4901                	li	s2,0
    80004410:	b7fd                	j	800043fe <pipewrite+0xc8>
    80004412:	7b02                	ld	s6,32(sp)
    80004414:	6be2                	ld	s7,24(sp)
    80004416:	6c42                	ld	s8,16(sp)
    80004418:	b7dd                	j	800043fe <pipewrite+0xc8>

000000008000441a <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000441a:	715d                	addi	sp,sp,-80
    8000441c:	e486                	sd	ra,72(sp)
    8000441e:	e0a2                	sd	s0,64(sp)
    80004420:	fc26                	sd	s1,56(sp)
    80004422:	f84a                	sd	s2,48(sp)
    80004424:	f44e                	sd	s3,40(sp)
    80004426:	f052                	sd	s4,32(sp)
    80004428:	ec56                	sd	s5,24(sp)
    8000442a:	0880                	addi	s0,sp,80
    8000442c:	84aa                	mv	s1,a0
    8000442e:	892e                	mv	s2,a1
    80004430:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004432:	cd8fd0ef          	jal	8000190a <myproc>
    80004436:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004438:	8526                	mv	a0,s1
    8000443a:	fbafc0ef          	jal	80000bf4 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000443e:	2184a703          	lw	a4,536(s1)
    80004442:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004446:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000444a:	02f71563          	bne	a4,a5,80004474 <piperead+0x5a>
    8000444e:	2244a783          	lw	a5,548(s1)
    80004452:	cb85                	beqz	a5,80004482 <piperead+0x68>
    if(killed(pr)){
    80004454:	8552                	mv	a0,s4
    80004456:	cbbfd0ef          	jal	80002110 <killed>
    8000445a:	ed19                	bnez	a0,80004478 <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000445c:	85a6                	mv	a1,s1
    8000445e:	854e                	mv	a0,s3
    80004460:	a79fd0ef          	jal	80001ed8 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004464:	2184a703          	lw	a4,536(s1)
    80004468:	21c4a783          	lw	a5,540(s1)
    8000446c:	fef701e3          	beq	a4,a5,8000444e <piperead+0x34>
    80004470:	e85a                	sd	s6,16(sp)
    80004472:	a809                	j	80004484 <piperead+0x6a>
    80004474:	e85a                	sd	s6,16(sp)
    80004476:	a039                	j	80004484 <piperead+0x6a>
      release(&pi->lock);
    80004478:	8526                	mv	a0,s1
    8000447a:	813fc0ef          	jal	80000c8c <release>
      return -1;
    8000447e:	59fd                	li	s3,-1
    80004480:	a8b1                	j	800044dc <piperead+0xc2>
    80004482:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004484:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004486:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004488:	05505263          	blez	s5,800044cc <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    8000448c:	2184a783          	lw	a5,536(s1)
    80004490:	21c4a703          	lw	a4,540(s1)
    80004494:	02f70c63          	beq	a4,a5,800044cc <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004498:	0017871b          	addiw	a4,a5,1
    8000449c:	20e4ac23          	sw	a4,536(s1)
    800044a0:	1ff7f793          	andi	a5,a5,511
    800044a4:	97a6                	add	a5,a5,s1
    800044a6:	0187c783          	lbu	a5,24(a5)
    800044aa:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800044ae:	4685                	li	a3,1
    800044b0:	fbf40613          	addi	a2,s0,-65
    800044b4:	85ca                	mv	a1,s2
    800044b6:	050a3503          	ld	a0,80(s4)
    800044ba:	8c2fd0ef          	jal	8000157c <copyout>
    800044be:	01650763          	beq	a0,s6,800044cc <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800044c2:	2985                	addiw	s3,s3,1
    800044c4:	0905                	addi	s2,s2,1
    800044c6:	fd3a93e3          	bne	s5,s3,8000448c <piperead+0x72>
    800044ca:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800044cc:	21c48513          	addi	a0,s1,540
    800044d0:	a55fd0ef          	jal	80001f24 <wakeup>
  release(&pi->lock);
    800044d4:	8526                	mv	a0,s1
    800044d6:	fb6fc0ef          	jal	80000c8c <release>
    800044da:	6b42                	ld	s6,16(sp)
  return i;
}
    800044dc:	854e                	mv	a0,s3
    800044de:	60a6                	ld	ra,72(sp)
    800044e0:	6406                	ld	s0,64(sp)
    800044e2:	74e2                	ld	s1,56(sp)
    800044e4:	7942                	ld	s2,48(sp)
    800044e6:	79a2                	ld	s3,40(sp)
    800044e8:	7a02                	ld	s4,32(sp)
    800044ea:	6ae2                	ld	s5,24(sp)
    800044ec:	6161                	addi	sp,sp,80
    800044ee:	8082                	ret

00000000800044f0 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    800044f0:	1141                	addi	sp,sp,-16
    800044f2:	e422                	sd	s0,8(sp)
    800044f4:	0800                	addi	s0,sp,16
    800044f6:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800044f8:	8905                	andi	a0,a0,1
    800044fa:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    800044fc:	8b89                	andi	a5,a5,2
    800044fe:	c399                	beqz	a5,80004504 <flags2perm+0x14>
      perm |= PTE_W;
    80004500:	00456513          	ori	a0,a0,4
    return perm;
}
    80004504:	6422                	ld	s0,8(sp)
    80004506:	0141                	addi	sp,sp,16
    80004508:	8082                	ret

000000008000450a <exec>:

int
exec(char *path, char **argv)
{
    8000450a:	df010113          	addi	sp,sp,-528
    8000450e:	20113423          	sd	ra,520(sp)
    80004512:	20813023          	sd	s0,512(sp)
    80004516:	ffa6                	sd	s1,504(sp)
    80004518:	fbca                	sd	s2,496(sp)
    8000451a:	0c00                	addi	s0,sp,528
    8000451c:	892a                	mv	s2,a0
    8000451e:	dea43c23          	sd	a0,-520(s0)
    80004522:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004526:	be4fd0ef          	jal	8000190a <myproc>
    8000452a:	84aa                	mv	s1,a0

  begin_op();
    8000452c:	d72ff0ef          	jal	80003a9e <begin_op>

  if((ip = namei(path)) == 0){
    80004530:	854a                	mv	a0,s2
    80004532:	bb0ff0ef          	jal	800038e2 <namei>
    80004536:	c931                	beqz	a0,8000458a <exec+0x80>
    80004538:	f3d2                	sd	s4,480(sp)
    8000453a:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000453c:	ccdfe0ef          	jal	80003208 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004540:	04000713          	li	a4,64
    80004544:	4681                	li	a3,0
    80004546:	e5040613          	addi	a2,s0,-432
    8000454a:	4581                	li	a1,0
    8000454c:	8552                	mv	a0,s4
    8000454e:	f0ffe0ef          	jal	8000345c <readi>
    80004552:	04000793          	li	a5,64
    80004556:	00f51a63          	bne	a0,a5,8000456a <exec+0x60>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    8000455a:	e5042703          	lw	a4,-432(s0)
    8000455e:	464c47b7          	lui	a5,0x464c4
    80004562:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004566:	02f70663          	beq	a4,a5,80004592 <exec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000456a:	8552                	mv	a0,s4
    8000456c:	ea7fe0ef          	jal	80003412 <iunlockput>
    end_op();
    80004570:	d98ff0ef          	jal	80003b08 <end_op>
  }
  return -1;
    80004574:	557d                	li	a0,-1
    80004576:	7a1e                	ld	s4,480(sp)
}
    80004578:	20813083          	ld	ra,520(sp)
    8000457c:	20013403          	ld	s0,512(sp)
    80004580:	74fe                	ld	s1,504(sp)
    80004582:	795e                	ld	s2,496(sp)
    80004584:	21010113          	addi	sp,sp,528
    80004588:	8082                	ret
    end_op();
    8000458a:	d7eff0ef          	jal	80003b08 <end_op>
    return -1;
    8000458e:	557d                	li	a0,-1
    80004590:	b7e5                	j	80004578 <exec+0x6e>
    80004592:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004594:	8526                	mv	a0,s1
    80004596:	c1cfd0ef          	jal	800019b2 <proc_pagetable>
    8000459a:	8b2a                	mv	s6,a0
    8000459c:	2c050b63          	beqz	a0,80004872 <exec+0x368>
    800045a0:	f7ce                	sd	s3,488(sp)
    800045a2:	efd6                	sd	s5,472(sp)
    800045a4:	e7de                	sd	s7,456(sp)
    800045a6:	e3e2                	sd	s8,448(sp)
    800045a8:	ff66                	sd	s9,440(sp)
    800045aa:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800045ac:	e7042d03          	lw	s10,-400(s0)
    800045b0:	e8845783          	lhu	a5,-376(s0)
    800045b4:	12078963          	beqz	a5,800046e6 <exec+0x1dc>
    800045b8:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800045ba:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800045bc:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    800045be:	6c85                	lui	s9,0x1
    800045c0:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800045c4:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    800045c8:	6a85                	lui	s5,0x1
    800045ca:	a085                	j	8000462a <exec+0x120>
      panic("loadseg: address should exist");
    800045cc:	00003517          	auipc	a0,0x3
    800045d0:	1a450513          	addi	a0,a0,420 # 80007770 <etext+0x770>
    800045d4:	9c0fc0ef          	jal	80000794 <panic>
    if(sz - i < PGSIZE)
    800045d8:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800045da:	8726                	mv	a4,s1
    800045dc:	012c06bb          	addw	a3,s8,s2
    800045e0:	4581                	li	a1,0
    800045e2:	8552                	mv	a0,s4
    800045e4:	e79fe0ef          	jal	8000345c <readi>
    800045e8:	2501                	sext.w	a0,a0
    800045ea:	24a49a63          	bne	s1,a0,8000483e <exec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    800045ee:	012a893b          	addw	s2,s5,s2
    800045f2:	03397363          	bgeu	s2,s3,80004618 <exec+0x10e>
    pa = walkaddr(pagetable, va + i);
    800045f6:	02091593          	slli	a1,s2,0x20
    800045fa:	9181                	srli	a1,a1,0x20
    800045fc:	95de                	add	a1,a1,s7
    800045fe:	855a                	mv	a0,s6
    80004600:	a01fc0ef          	jal	80001000 <walkaddr>
    80004604:	862a                	mv	a2,a0
    if(pa == 0)
    80004606:	d179                	beqz	a0,800045cc <exec+0xc2>
    if(sz - i < PGSIZE)
    80004608:	412984bb          	subw	s1,s3,s2
    8000460c:	0004879b          	sext.w	a5,s1
    80004610:	fcfcf4e3          	bgeu	s9,a5,800045d8 <exec+0xce>
    80004614:	84d6                	mv	s1,s5
    80004616:	b7c9                	j	800045d8 <exec+0xce>
    sz = sz1;
    80004618:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000461c:	2d85                	addiw	s11,s11,1
    8000461e:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    80004622:	e8845783          	lhu	a5,-376(s0)
    80004626:	08fdd063          	bge	s11,a5,800046a6 <exec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000462a:	2d01                	sext.w	s10,s10
    8000462c:	03800713          	li	a4,56
    80004630:	86ea                	mv	a3,s10
    80004632:	e1840613          	addi	a2,s0,-488
    80004636:	4581                	li	a1,0
    80004638:	8552                	mv	a0,s4
    8000463a:	e23fe0ef          	jal	8000345c <readi>
    8000463e:	03800793          	li	a5,56
    80004642:	1cf51663          	bne	a0,a5,8000480e <exec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    80004646:	e1842783          	lw	a5,-488(s0)
    8000464a:	4705                	li	a4,1
    8000464c:	fce798e3          	bne	a5,a4,8000461c <exec+0x112>
    if(ph.memsz < ph.filesz)
    80004650:	e4043483          	ld	s1,-448(s0)
    80004654:	e3843783          	ld	a5,-456(s0)
    80004658:	1af4ef63          	bltu	s1,a5,80004816 <exec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000465c:	e2843783          	ld	a5,-472(s0)
    80004660:	94be                	add	s1,s1,a5
    80004662:	1af4ee63          	bltu	s1,a5,8000481e <exec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    80004666:	df043703          	ld	a4,-528(s0)
    8000466a:	8ff9                	and	a5,a5,a4
    8000466c:	1a079d63          	bnez	a5,80004826 <exec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004670:	e1c42503          	lw	a0,-484(s0)
    80004674:	e7dff0ef          	jal	800044f0 <flags2perm>
    80004678:	86aa                	mv	a3,a0
    8000467a:	8626                	mv	a2,s1
    8000467c:	85ca                	mv	a1,s2
    8000467e:	855a                	mv	a0,s6
    80004680:	ce9fc0ef          	jal	80001368 <uvmalloc>
    80004684:	e0a43423          	sd	a0,-504(s0)
    80004688:	1a050363          	beqz	a0,8000482e <exec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000468c:	e2843b83          	ld	s7,-472(s0)
    80004690:	e2042c03          	lw	s8,-480(s0)
    80004694:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004698:	00098463          	beqz	s3,800046a0 <exec+0x196>
    8000469c:	4901                	li	s2,0
    8000469e:	bfa1                	j	800045f6 <exec+0xec>
    sz = sz1;
    800046a0:	e0843903          	ld	s2,-504(s0)
    800046a4:	bfa5                	j	8000461c <exec+0x112>
    800046a6:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    800046a8:	8552                	mv	a0,s4
    800046aa:	d69fe0ef          	jal	80003412 <iunlockput>
  end_op();
    800046ae:	c5aff0ef          	jal	80003b08 <end_op>
  p = myproc();
    800046b2:	a58fd0ef          	jal	8000190a <myproc>
    800046b6:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800046b8:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    800046bc:	6985                	lui	s3,0x1
    800046be:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    800046c0:	99ca                	add	s3,s3,s2
    800046c2:	77fd                	lui	a5,0xfffff
    800046c4:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    800046c8:	4691                	li	a3,4
    800046ca:	6609                	lui	a2,0x2
    800046cc:	964e                	add	a2,a2,s3
    800046ce:	85ce                	mv	a1,s3
    800046d0:	855a                	mv	a0,s6
    800046d2:	c97fc0ef          	jal	80001368 <uvmalloc>
    800046d6:	892a                	mv	s2,a0
    800046d8:	e0a43423          	sd	a0,-504(s0)
    800046dc:	e519                	bnez	a0,800046ea <exec+0x1e0>
  if(pagetable)
    800046de:	e1343423          	sd	s3,-504(s0)
    800046e2:	4a01                	li	s4,0
    800046e4:	aab1                	j	80004840 <exec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800046e6:	4901                	li	s2,0
    800046e8:	b7c1                	j	800046a8 <exec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    800046ea:	75f9                	lui	a1,0xffffe
    800046ec:	95aa                	add	a1,a1,a0
    800046ee:	855a                	mv	a0,s6
    800046f0:	e63fc0ef          	jal	80001552 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    800046f4:	7bfd                	lui	s7,0xfffff
    800046f6:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    800046f8:	e0043783          	ld	a5,-512(s0)
    800046fc:	6388                	ld	a0,0(a5)
    800046fe:	cd39                	beqz	a0,8000475c <exec+0x252>
    80004700:	e9040993          	addi	s3,s0,-368
    80004704:	f9040c13          	addi	s8,s0,-112
    80004708:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    8000470a:	f2efc0ef          	jal	80000e38 <strlen>
    8000470e:	0015079b          	addiw	a5,a0,1
    80004712:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004716:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    8000471a:	11796e63          	bltu	s2,s7,80004836 <exec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000471e:	e0043d03          	ld	s10,-512(s0)
    80004722:	000d3a03          	ld	s4,0(s10)
    80004726:	8552                	mv	a0,s4
    80004728:	f10fc0ef          	jal	80000e38 <strlen>
    8000472c:	0015069b          	addiw	a3,a0,1
    80004730:	8652                	mv	a2,s4
    80004732:	85ca                	mv	a1,s2
    80004734:	855a                	mv	a0,s6
    80004736:	e47fc0ef          	jal	8000157c <copyout>
    8000473a:	10054063          	bltz	a0,8000483a <exec+0x330>
    ustack[argc] = sp;
    8000473e:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004742:	0485                	addi	s1,s1,1
    80004744:	008d0793          	addi	a5,s10,8
    80004748:	e0f43023          	sd	a5,-512(s0)
    8000474c:	008d3503          	ld	a0,8(s10)
    80004750:	c909                	beqz	a0,80004762 <exec+0x258>
    if(argc >= MAXARG)
    80004752:	09a1                	addi	s3,s3,8
    80004754:	fb899be3          	bne	s3,s8,8000470a <exec+0x200>
  ip = 0;
    80004758:	4a01                	li	s4,0
    8000475a:	a0dd                	j	80004840 <exec+0x336>
  sp = sz;
    8000475c:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80004760:	4481                	li	s1,0
  ustack[argc] = 0;
    80004762:	00349793          	slli	a5,s1,0x3
    80004766:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffde1d0>
    8000476a:	97a2                	add	a5,a5,s0
    8000476c:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004770:	00148693          	addi	a3,s1,1
    80004774:	068e                	slli	a3,a3,0x3
    80004776:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000477a:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    8000477e:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80004782:	f5796ee3          	bltu	s2,s7,800046de <exec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004786:	e9040613          	addi	a2,s0,-368
    8000478a:	85ca                	mv	a1,s2
    8000478c:	855a                	mv	a0,s6
    8000478e:	deffc0ef          	jal	8000157c <copyout>
    80004792:	0e054263          	bltz	a0,80004876 <exec+0x36c>
  p->trapframe->a1 = sp;
    80004796:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    8000479a:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000479e:	df843783          	ld	a5,-520(s0)
    800047a2:	0007c703          	lbu	a4,0(a5)
    800047a6:	cf11                	beqz	a4,800047c2 <exec+0x2b8>
    800047a8:	0785                	addi	a5,a5,1
    if(*s == '/')
    800047aa:	02f00693          	li	a3,47
    800047ae:	a039                	j	800047bc <exec+0x2b2>
      last = s+1;
    800047b0:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    800047b4:	0785                	addi	a5,a5,1
    800047b6:	fff7c703          	lbu	a4,-1(a5)
    800047ba:	c701                	beqz	a4,800047c2 <exec+0x2b8>
    if(*s == '/')
    800047bc:	fed71ce3          	bne	a4,a3,800047b4 <exec+0x2aa>
    800047c0:	bfc5                	j	800047b0 <exec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    800047c2:	4641                	li	a2,16
    800047c4:	df843583          	ld	a1,-520(s0)
    800047c8:	158a8513          	addi	a0,s5,344
    800047cc:	e3afc0ef          	jal	80000e06 <safestrcpy>
  oldpagetable = p->pagetable;
    800047d0:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800047d4:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    800047d8:	e0843783          	ld	a5,-504(s0)
    800047dc:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800047e0:	058ab783          	ld	a5,88(s5)
    800047e4:	e6843703          	ld	a4,-408(s0)
    800047e8:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800047ea:	058ab783          	ld	a5,88(s5)
    800047ee:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800047f2:	85e6                	mv	a1,s9
    800047f4:	a42fd0ef          	jal	80001a36 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800047f8:	0004851b          	sext.w	a0,s1
    800047fc:	79be                	ld	s3,488(sp)
    800047fe:	7a1e                	ld	s4,480(sp)
    80004800:	6afe                	ld	s5,472(sp)
    80004802:	6b5e                	ld	s6,464(sp)
    80004804:	6bbe                	ld	s7,456(sp)
    80004806:	6c1e                	ld	s8,448(sp)
    80004808:	7cfa                	ld	s9,440(sp)
    8000480a:	7d5a                	ld	s10,432(sp)
    8000480c:	b3b5                	j	80004578 <exec+0x6e>
    8000480e:	e1243423          	sd	s2,-504(s0)
    80004812:	7dba                	ld	s11,424(sp)
    80004814:	a035                	j	80004840 <exec+0x336>
    80004816:	e1243423          	sd	s2,-504(s0)
    8000481a:	7dba                	ld	s11,424(sp)
    8000481c:	a015                	j	80004840 <exec+0x336>
    8000481e:	e1243423          	sd	s2,-504(s0)
    80004822:	7dba                	ld	s11,424(sp)
    80004824:	a831                	j	80004840 <exec+0x336>
    80004826:	e1243423          	sd	s2,-504(s0)
    8000482a:	7dba                	ld	s11,424(sp)
    8000482c:	a811                	j	80004840 <exec+0x336>
    8000482e:	e1243423          	sd	s2,-504(s0)
    80004832:	7dba                	ld	s11,424(sp)
    80004834:	a031                	j	80004840 <exec+0x336>
  ip = 0;
    80004836:	4a01                	li	s4,0
    80004838:	a021                	j	80004840 <exec+0x336>
    8000483a:	4a01                	li	s4,0
  if(pagetable)
    8000483c:	a011                	j	80004840 <exec+0x336>
    8000483e:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80004840:	e0843583          	ld	a1,-504(s0)
    80004844:	855a                	mv	a0,s6
    80004846:	9f0fd0ef          	jal	80001a36 <proc_freepagetable>
  return -1;
    8000484a:	557d                	li	a0,-1
  if(ip){
    8000484c:	000a1b63          	bnez	s4,80004862 <exec+0x358>
    80004850:	79be                	ld	s3,488(sp)
    80004852:	7a1e                	ld	s4,480(sp)
    80004854:	6afe                	ld	s5,472(sp)
    80004856:	6b5e                	ld	s6,464(sp)
    80004858:	6bbe                	ld	s7,456(sp)
    8000485a:	6c1e                	ld	s8,448(sp)
    8000485c:	7cfa                	ld	s9,440(sp)
    8000485e:	7d5a                	ld	s10,432(sp)
    80004860:	bb21                	j	80004578 <exec+0x6e>
    80004862:	79be                	ld	s3,488(sp)
    80004864:	6afe                	ld	s5,472(sp)
    80004866:	6b5e                	ld	s6,464(sp)
    80004868:	6bbe                	ld	s7,456(sp)
    8000486a:	6c1e                	ld	s8,448(sp)
    8000486c:	7cfa                	ld	s9,440(sp)
    8000486e:	7d5a                	ld	s10,432(sp)
    80004870:	b9ed                	j	8000456a <exec+0x60>
    80004872:	6b5e                	ld	s6,464(sp)
    80004874:	b9dd                	j	8000456a <exec+0x60>
  sz = sz1;
    80004876:	e0843983          	ld	s3,-504(s0)
    8000487a:	b595                	j	800046de <exec+0x1d4>

000000008000487c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000487c:	7179                	addi	sp,sp,-48
    8000487e:	f406                	sd	ra,40(sp)
    80004880:	f022                	sd	s0,32(sp)
    80004882:	ec26                	sd	s1,24(sp)
    80004884:	e84a                	sd	s2,16(sp)
    80004886:	1800                	addi	s0,sp,48
    80004888:	892e                	mv	s2,a1
    8000488a:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    8000488c:	fdc40593          	addi	a1,s0,-36
    80004890:	f2ffd0ef          	jal	800027be <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004894:	fdc42703          	lw	a4,-36(s0)
    80004898:	47bd                	li	a5,15
    8000489a:	02e7e963          	bltu	a5,a4,800048cc <argfd+0x50>
    8000489e:	86cfd0ef          	jal	8000190a <myproc>
    800048a2:	fdc42703          	lw	a4,-36(s0)
    800048a6:	01a70793          	addi	a5,a4,26
    800048aa:	078e                	slli	a5,a5,0x3
    800048ac:	953e                	add	a0,a0,a5
    800048ae:	611c                	ld	a5,0(a0)
    800048b0:	c385                	beqz	a5,800048d0 <argfd+0x54>
    return -1;
  if(pfd)
    800048b2:	00090463          	beqz	s2,800048ba <argfd+0x3e>
    *pfd = fd;
    800048b6:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800048ba:	4501                	li	a0,0
  if(pf)
    800048bc:	c091                	beqz	s1,800048c0 <argfd+0x44>
    *pf = f;
    800048be:	e09c                	sd	a5,0(s1)
}
    800048c0:	70a2                	ld	ra,40(sp)
    800048c2:	7402                	ld	s0,32(sp)
    800048c4:	64e2                	ld	s1,24(sp)
    800048c6:	6942                	ld	s2,16(sp)
    800048c8:	6145                	addi	sp,sp,48
    800048ca:	8082                	ret
    return -1;
    800048cc:	557d                	li	a0,-1
    800048ce:	bfcd                	j	800048c0 <argfd+0x44>
    800048d0:	557d                	li	a0,-1
    800048d2:	b7fd                	j	800048c0 <argfd+0x44>

00000000800048d4 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800048d4:	1101                	addi	sp,sp,-32
    800048d6:	ec06                	sd	ra,24(sp)
    800048d8:	e822                	sd	s0,16(sp)
    800048da:	e426                	sd	s1,8(sp)
    800048dc:	1000                	addi	s0,sp,32
    800048de:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800048e0:	82afd0ef          	jal	8000190a <myproc>
    800048e4:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800048e6:	0d050793          	addi	a5,a0,208
    800048ea:	4501                	li	a0,0
    800048ec:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800048ee:	6398                	ld	a4,0(a5)
    800048f0:	cb19                	beqz	a4,80004906 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    800048f2:	2505                	addiw	a0,a0,1
    800048f4:	07a1                	addi	a5,a5,8
    800048f6:	fed51ce3          	bne	a0,a3,800048ee <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800048fa:	557d                	li	a0,-1
}
    800048fc:	60e2                	ld	ra,24(sp)
    800048fe:	6442                	ld	s0,16(sp)
    80004900:	64a2                	ld	s1,8(sp)
    80004902:	6105                	addi	sp,sp,32
    80004904:	8082                	ret
      p->ofile[fd] = f;
    80004906:	01a50793          	addi	a5,a0,26
    8000490a:	078e                	slli	a5,a5,0x3
    8000490c:	963e                	add	a2,a2,a5
    8000490e:	e204                	sd	s1,0(a2)
      return fd;
    80004910:	b7f5                	j	800048fc <fdalloc+0x28>

0000000080004912 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004912:	715d                	addi	sp,sp,-80
    80004914:	e486                	sd	ra,72(sp)
    80004916:	e0a2                	sd	s0,64(sp)
    80004918:	fc26                	sd	s1,56(sp)
    8000491a:	f84a                	sd	s2,48(sp)
    8000491c:	f44e                	sd	s3,40(sp)
    8000491e:	ec56                	sd	s5,24(sp)
    80004920:	e85a                	sd	s6,16(sp)
    80004922:	0880                	addi	s0,sp,80
    80004924:	8b2e                	mv	s6,a1
    80004926:	89b2                	mv	s3,a2
    80004928:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000492a:	fb040593          	addi	a1,s0,-80
    8000492e:	fcffe0ef          	jal	800038fc <nameiparent>
    80004932:	84aa                	mv	s1,a0
    80004934:	10050a63          	beqz	a0,80004a48 <create+0x136>
    return 0;

  ilock(dp);
    80004938:	8d1fe0ef          	jal	80003208 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000493c:	4601                	li	a2,0
    8000493e:	fb040593          	addi	a1,s0,-80
    80004942:	8526                	mv	a0,s1
    80004944:	d39fe0ef          	jal	8000367c <dirlookup>
    80004948:	8aaa                	mv	s5,a0
    8000494a:	c129                	beqz	a0,8000498c <create+0x7a>
    iunlockput(dp);
    8000494c:	8526                	mv	a0,s1
    8000494e:	ac5fe0ef          	jal	80003412 <iunlockput>
    ilock(ip);
    80004952:	8556                	mv	a0,s5
    80004954:	8b5fe0ef          	jal	80003208 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004958:	4789                	li	a5,2
    8000495a:	02fb1463          	bne	s6,a5,80004982 <create+0x70>
    8000495e:	044ad783          	lhu	a5,68(s5)
    80004962:	37f9                	addiw	a5,a5,-2
    80004964:	17c2                	slli	a5,a5,0x30
    80004966:	93c1                	srli	a5,a5,0x30
    80004968:	4705                	li	a4,1
    8000496a:	00f76c63          	bltu	a4,a5,80004982 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    8000496e:	8556                	mv	a0,s5
    80004970:	60a6                	ld	ra,72(sp)
    80004972:	6406                	ld	s0,64(sp)
    80004974:	74e2                	ld	s1,56(sp)
    80004976:	7942                	ld	s2,48(sp)
    80004978:	79a2                	ld	s3,40(sp)
    8000497a:	6ae2                	ld	s5,24(sp)
    8000497c:	6b42                	ld	s6,16(sp)
    8000497e:	6161                	addi	sp,sp,80
    80004980:	8082                	ret
    iunlockput(ip);
    80004982:	8556                	mv	a0,s5
    80004984:	a8ffe0ef          	jal	80003412 <iunlockput>
    return 0;
    80004988:	4a81                	li	s5,0
    8000498a:	b7d5                	j	8000496e <create+0x5c>
    8000498c:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    8000498e:	85da                	mv	a1,s6
    80004990:	4088                	lw	a0,0(s1)
    80004992:	f06fe0ef          	jal	80003098 <ialloc>
    80004996:	8a2a                	mv	s4,a0
    80004998:	cd15                	beqz	a0,800049d4 <create+0xc2>
  ilock(ip);
    8000499a:	86ffe0ef          	jal	80003208 <ilock>
  ip->major = major;
    8000499e:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800049a2:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800049a6:	4905                	li	s2,1
    800049a8:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    800049ac:	8552                	mv	a0,s4
    800049ae:	fa6fe0ef          	jal	80003154 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800049b2:	032b0763          	beq	s6,s2,800049e0 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    800049b6:	004a2603          	lw	a2,4(s4)
    800049ba:	fb040593          	addi	a1,s0,-80
    800049be:	8526                	mv	a0,s1
    800049c0:	e89fe0ef          	jal	80003848 <dirlink>
    800049c4:	06054563          	bltz	a0,80004a2e <create+0x11c>
  iunlockput(dp);
    800049c8:	8526                	mv	a0,s1
    800049ca:	a49fe0ef          	jal	80003412 <iunlockput>
  return ip;
    800049ce:	8ad2                	mv	s5,s4
    800049d0:	7a02                	ld	s4,32(sp)
    800049d2:	bf71                	j	8000496e <create+0x5c>
    iunlockput(dp);
    800049d4:	8526                	mv	a0,s1
    800049d6:	a3dfe0ef          	jal	80003412 <iunlockput>
    return 0;
    800049da:	8ad2                	mv	s5,s4
    800049dc:	7a02                	ld	s4,32(sp)
    800049de:	bf41                	j	8000496e <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800049e0:	004a2603          	lw	a2,4(s4)
    800049e4:	00003597          	auipc	a1,0x3
    800049e8:	dac58593          	addi	a1,a1,-596 # 80007790 <etext+0x790>
    800049ec:	8552                	mv	a0,s4
    800049ee:	e5bfe0ef          	jal	80003848 <dirlink>
    800049f2:	02054e63          	bltz	a0,80004a2e <create+0x11c>
    800049f6:	40d0                	lw	a2,4(s1)
    800049f8:	00003597          	auipc	a1,0x3
    800049fc:	da058593          	addi	a1,a1,-608 # 80007798 <etext+0x798>
    80004a00:	8552                	mv	a0,s4
    80004a02:	e47fe0ef          	jal	80003848 <dirlink>
    80004a06:	02054463          	bltz	a0,80004a2e <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004a0a:	004a2603          	lw	a2,4(s4)
    80004a0e:	fb040593          	addi	a1,s0,-80
    80004a12:	8526                	mv	a0,s1
    80004a14:	e35fe0ef          	jal	80003848 <dirlink>
    80004a18:	00054b63          	bltz	a0,80004a2e <create+0x11c>
    dp->nlink++;  // for ".."
    80004a1c:	04a4d783          	lhu	a5,74(s1)
    80004a20:	2785                	addiw	a5,a5,1
    80004a22:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004a26:	8526                	mv	a0,s1
    80004a28:	f2cfe0ef          	jal	80003154 <iupdate>
    80004a2c:	bf71                	j	800049c8 <create+0xb6>
  ip->nlink = 0;
    80004a2e:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004a32:	8552                	mv	a0,s4
    80004a34:	f20fe0ef          	jal	80003154 <iupdate>
  iunlockput(ip);
    80004a38:	8552                	mv	a0,s4
    80004a3a:	9d9fe0ef          	jal	80003412 <iunlockput>
  iunlockput(dp);
    80004a3e:	8526                	mv	a0,s1
    80004a40:	9d3fe0ef          	jal	80003412 <iunlockput>
  return 0;
    80004a44:	7a02                	ld	s4,32(sp)
    80004a46:	b725                	j	8000496e <create+0x5c>
    return 0;
    80004a48:	8aaa                	mv	s5,a0
    80004a4a:	b715                	j	8000496e <create+0x5c>

0000000080004a4c <sys_dup>:
{
    80004a4c:	7179                	addi	sp,sp,-48
    80004a4e:	f406                	sd	ra,40(sp)
    80004a50:	f022                	sd	s0,32(sp)
    80004a52:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004a54:	fd840613          	addi	a2,s0,-40
    80004a58:	4581                	li	a1,0
    80004a5a:	4501                	li	a0,0
    80004a5c:	e21ff0ef          	jal	8000487c <argfd>
    return -1;
    80004a60:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004a62:	02054363          	bltz	a0,80004a88 <sys_dup+0x3c>
    80004a66:	ec26                	sd	s1,24(sp)
    80004a68:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004a6a:	fd843903          	ld	s2,-40(s0)
    80004a6e:	854a                	mv	a0,s2
    80004a70:	e65ff0ef          	jal	800048d4 <fdalloc>
    80004a74:	84aa                	mv	s1,a0
    return -1;
    80004a76:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004a78:	00054d63          	bltz	a0,80004a92 <sys_dup+0x46>
  filedup(f);
    80004a7c:	854a                	mv	a0,s2
    80004a7e:	c48ff0ef          	jal	80003ec6 <filedup>
  return fd;
    80004a82:	87a6                	mv	a5,s1
    80004a84:	64e2                	ld	s1,24(sp)
    80004a86:	6942                	ld	s2,16(sp)
}
    80004a88:	853e                	mv	a0,a5
    80004a8a:	70a2                	ld	ra,40(sp)
    80004a8c:	7402                	ld	s0,32(sp)
    80004a8e:	6145                	addi	sp,sp,48
    80004a90:	8082                	ret
    80004a92:	64e2                	ld	s1,24(sp)
    80004a94:	6942                	ld	s2,16(sp)
    80004a96:	bfcd                	j	80004a88 <sys_dup+0x3c>

0000000080004a98 <sys_read>:
{
    80004a98:	7179                	addi	sp,sp,-48
    80004a9a:	f406                	sd	ra,40(sp)
    80004a9c:	f022                	sd	s0,32(sp)
    80004a9e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004aa0:	fd840593          	addi	a1,s0,-40
    80004aa4:	4505                	li	a0,1
    80004aa6:	d35fd0ef          	jal	800027da <argaddr>
  argint(2, &n);
    80004aaa:	fe440593          	addi	a1,s0,-28
    80004aae:	4509                	li	a0,2
    80004ab0:	d0ffd0ef          	jal	800027be <argint>
  if(argfd(0, 0, &f) < 0)
    80004ab4:	fe840613          	addi	a2,s0,-24
    80004ab8:	4581                	li	a1,0
    80004aba:	4501                	li	a0,0
    80004abc:	dc1ff0ef          	jal	8000487c <argfd>
    80004ac0:	87aa                	mv	a5,a0
    return -1;
    80004ac2:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004ac4:	0007ca63          	bltz	a5,80004ad8 <sys_read+0x40>
  return fileread(f, p, n);
    80004ac8:	fe442603          	lw	a2,-28(s0)
    80004acc:	fd843583          	ld	a1,-40(s0)
    80004ad0:	fe843503          	ld	a0,-24(s0)
    80004ad4:	d58ff0ef          	jal	8000402c <fileread>
}
    80004ad8:	70a2                	ld	ra,40(sp)
    80004ada:	7402                	ld	s0,32(sp)
    80004adc:	6145                	addi	sp,sp,48
    80004ade:	8082                	ret

0000000080004ae0 <sys_write>:
{
    80004ae0:	7179                	addi	sp,sp,-48
    80004ae2:	f406                	sd	ra,40(sp)
    80004ae4:	f022                	sd	s0,32(sp)
    80004ae6:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004ae8:	fd840593          	addi	a1,s0,-40
    80004aec:	4505                	li	a0,1
    80004aee:	cedfd0ef          	jal	800027da <argaddr>
  argint(2, &n);
    80004af2:	fe440593          	addi	a1,s0,-28
    80004af6:	4509                	li	a0,2
    80004af8:	cc7fd0ef          	jal	800027be <argint>
  if(argfd(0, 0, &f) < 0)
    80004afc:	fe840613          	addi	a2,s0,-24
    80004b00:	4581                	li	a1,0
    80004b02:	4501                	li	a0,0
    80004b04:	d79ff0ef          	jal	8000487c <argfd>
    80004b08:	87aa                	mv	a5,a0
    return -1;
    80004b0a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004b0c:	0007ca63          	bltz	a5,80004b20 <sys_write+0x40>
  return filewrite(f, p, n);
    80004b10:	fe442603          	lw	a2,-28(s0)
    80004b14:	fd843583          	ld	a1,-40(s0)
    80004b18:	fe843503          	ld	a0,-24(s0)
    80004b1c:	dceff0ef          	jal	800040ea <filewrite>
}
    80004b20:	70a2                	ld	ra,40(sp)
    80004b22:	7402                	ld	s0,32(sp)
    80004b24:	6145                	addi	sp,sp,48
    80004b26:	8082                	ret

0000000080004b28 <sys_close>:
{
    80004b28:	1101                	addi	sp,sp,-32
    80004b2a:	ec06                	sd	ra,24(sp)
    80004b2c:	e822                	sd	s0,16(sp)
    80004b2e:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004b30:	fe040613          	addi	a2,s0,-32
    80004b34:	fec40593          	addi	a1,s0,-20
    80004b38:	4501                	li	a0,0
    80004b3a:	d43ff0ef          	jal	8000487c <argfd>
    return -1;
    80004b3e:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004b40:	02054063          	bltz	a0,80004b60 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004b44:	dc7fc0ef          	jal	8000190a <myproc>
    80004b48:	fec42783          	lw	a5,-20(s0)
    80004b4c:	07e9                	addi	a5,a5,26
    80004b4e:	078e                	slli	a5,a5,0x3
    80004b50:	953e                	add	a0,a0,a5
    80004b52:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004b56:	fe043503          	ld	a0,-32(s0)
    80004b5a:	bb2ff0ef          	jal	80003f0c <fileclose>
  return 0;
    80004b5e:	4781                	li	a5,0
}
    80004b60:	853e                	mv	a0,a5
    80004b62:	60e2                	ld	ra,24(sp)
    80004b64:	6442                	ld	s0,16(sp)
    80004b66:	6105                	addi	sp,sp,32
    80004b68:	8082                	ret

0000000080004b6a <sys_fstat>:
{
    80004b6a:	1101                	addi	sp,sp,-32
    80004b6c:	ec06                	sd	ra,24(sp)
    80004b6e:	e822                	sd	s0,16(sp)
    80004b70:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004b72:	fe040593          	addi	a1,s0,-32
    80004b76:	4505                	li	a0,1
    80004b78:	c63fd0ef          	jal	800027da <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004b7c:	fe840613          	addi	a2,s0,-24
    80004b80:	4581                	li	a1,0
    80004b82:	4501                	li	a0,0
    80004b84:	cf9ff0ef          	jal	8000487c <argfd>
    80004b88:	87aa                	mv	a5,a0
    return -1;
    80004b8a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004b8c:	0007c863          	bltz	a5,80004b9c <sys_fstat+0x32>
  return filestat(f, st);
    80004b90:	fe043583          	ld	a1,-32(s0)
    80004b94:	fe843503          	ld	a0,-24(s0)
    80004b98:	c36ff0ef          	jal	80003fce <filestat>
}
    80004b9c:	60e2                	ld	ra,24(sp)
    80004b9e:	6442                	ld	s0,16(sp)
    80004ba0:	6105                	addi	sp,sp,32
    80004ba2:	8082                	ret

0000000080004ba4 <sys_link>:
{
    80004ba4:	7169                	addi	sp,sp,-304
    80004ba6:	f606                	sd	ra,296(sp)
    80004ba8:	f222                	sd	s0,288(sp)
    80004baa:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004bac:	08000613          	li	a2,128
    80004bb0:	ed040593          	addi	a1,s0,-304
    80004bb4:	4501                	li	a0,0
    80004bb6:	c41fd0ef          	jal	800027f6 <argstr>
    return -1;
    80004bba:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004bbc:	0c054e63          	bltz	a0,80004c98 <sys_link+0xf4>
    80004bc0:	08000613          	li	a2,128
    80004bc4:	f5040593          	addi	a1,s0,-176
    80004bc8:	4505                	li	a0,1
    80004bca:	c2dfd0ef          	jal	800027f6 <argstr>
    return -1;
    80004bce:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004bd0:	0c054463          	bltz	a0,80004c98 <sys_link+0xf4>
    80004bd4:	ee26                	sd	s1,280(sp)
  begin_op();
    80004bd6:	ec9fe0ef          	jal	80003a9e <begin_op>
  if((ip = namei(old)) == 0){
    80004bda:	ed040513          	addi	a0,s0,-304
    80004bde:	d05fe0ef          	jal	800038e2 <namei>
    80004be2:	84aa                	mv	s1,a0
    80004be4:	c53d                	beqz	a0,80004c52 <sys_link+0xae>
  ilock(ip);
    80004be6:	e22fe0ef          	jal	80003208 <ilock>
  if(ip->type == T_DIR){
    80004bea:	04449703          	lh	a4,68(s1)
    80004bee:	4785                	li	a5,1
    80004bf0:	06f70663          	beq	a4,a5,80004c5c <sys_link+0xb8>
    80004bf4:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004bf6:	04a4d783          	lhu	a5,74(s1)
    80004bfa:	2785                	addiw	a5,a5,1
    80004bfc:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004c00:	8526                	mv	a0,s1
    80004c02:	d52fe0ef          	jal	80003154 <iupdate>
  iunlock(ip);
    80004c06:	8526                	mv	a0,s1
    80004c08:	eaefe0ef          	jal	800032b6 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004c0c:	fd040593          	addi	a1,s0,-48
    80004c10:	f5040513          	addi	a0,s0,-176
    80004c14:	ce9fe0ef          	jal	800038fc <nameiparent>
    80004c18:	892a                	mv	s2,a0
    80004c1a:	cd21                	beqz	a0,80004c72 <sys_link+0xce>
  ilock(dp);
    80004c1c:	decfe0ef          	jal	80003208 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004c20:	00092703          	lw	a4,0(s2)
    80004c24:	409c                	lw	a5,0(s1)
    80004c26:	04f71363          	bne	a4,a5,80004c6c <sys_link+0xc8>
    80004c2a:	40d0                	lw	a2,4(s1)
    80004c2c:	fd040593          	addi	a1,s0,-48
    80004c30:	854a                	mv	a0,s2
    80004c32:	c17fe0ef          	jal	80003848 <dirlink>
    80004c36:	02054b63          	bltz	a0,80004c6c <sys_link+0xc8>
  iunlockput(dp);
    80004c3a:	854a                	mv	a0,s2
    80004c3c:	fd6fe0ef          	jal	80003412 <iunlockput>
  iput(ip);
    80004c40:	8526                	mv	a0,s1
    80004c42:	f48fe0ef          	jal	8000338a <iput>
  end_op();
    80004c46:	ec3fe0ef          	jal	80003b08 <end_op>
  return 0;
    80004c4a:	4781                	li	a5,0
    80004c4c:	64f2                	ld	s1,280(sp)
    80004c4e:	6952                	ld	s2,272(sp)
    80004c50:	a0a1                	j	80004c98 <sys_link+0xf4>
    end_op();
    80004c52:	eb7fe0ef          	jal	80003b08 <end_op>
    return -1;
    80004c56:	57fd                	li	a5,-1
    80004c58:	64f2                	ld	s1,280(sp)
    80004c5a:	a83d                	j	80004c98 <sys_link+0xf4>
    iunlockput(ip);
    80004c5c:	8526                	mv	a0,s1
    80004c5e:	fb4fe0ef          	jal	80003412 <iunlockput>
    end_op();
    80004c62:	ea7fe0ef          	jal	80003b08 <end_op>
    return -1;
    80004c66:	57fd                	li	a5,-1
    80004c68:	64f2                	ld	s1,280(sp)
    80004c6a:	a03d                	j	80004c98 <sys_link+0xf4>
    iunlockput(dp);
    80004c6c:	854a                	mv	a0,s2
    80004c6e:	fa4fe0ef          	jal	80003412 <iunlockput>
  ilock(ip);
    80004c72:	8526                	mv	a0,s1
    80004c74:	d94fe0ef          	jal	80003208 <ilock>
  ip->nlink--;
    80004c78:	04a4d783          	lhu	a5,74(s1)
    80004c7c:	37fd                	addiw	a5,a5,-1
    80004c7e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004c82:	8526                	mv	a0,s1
    80004c84:	cd0fe0ef          	jal	80003154 <iupdate>
  iunlockput(ip);
    80004c88:	8526                	mv	a0,s1
    80004c8a:	f88fe0ef          	jal	80003412 <iunlockput>
  end_op();
    80004c8e:	e7bfe0ef          	jal	80003b08 <end_op>
  return -1;
    80004c92:	57fd                	li	a5,-1
    80004c94:	64f2                	ld	s1,280(sp)
    80004c96:	6952                	ld	s2,272(sp)
}
    80004c98:	853e                	mv	a0,a5
    80004c9a:	70b2                	ld	ra,296(sp)
    80004c9c:	7412                	ld	s0,288(sp)
    80004c9e:	6155                	addi	sp,sp,304
    80004ca0:	8082                	ret

0000000080004ca2 <sys_unlink>:
{
    80004ca2:	7151                	addi	sp,sp,-240
    80004ca4:	f586                	sd	ra,232(sp)
    80004ca6:	f1a2                	sd	s0,224(sp)
    80004ca8:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004caa:	08000613          	li	a2,128
    80004cae:	f3040593          	addi	a1,s0,-208
    80004cb2:	4501                	li	a0,0
    80004cb4:	b43fd0ef          	jal	800027f6 <argstr>
    80004cb8:	16054063          	bltz	a0,80004e18 <sys_unlink+0x176>
    80004cbc:	eda6                	sd	s1,216(sp)
  begin_op();
    80004cbe:	de1fe0ef          	jal	80003a9e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004cc2:	fb040593          	addi	a1,s0,-80
    80004cc6:	f3040513          	addi	a0,s0,-208
    80004cca:	c33fe0ef          	jal	800038fc <nameiparent>
    80004cce:	84aa                	mv	s1,a0
    80004cd0:	c945                	beqz	a0,80004d80 <sys_unlink+0xde>
  ilock(dp);
    80004cd2:	d36fe0ef          	jal	80003208 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004cd6:	00003597          	auipc	a1,0x3
    80004cda:	aba58593          	addi	a1,a1,-1350 # 80007790 <etext+0x790>
    80004cde:	fb040513          	addi	a0,s0,-80
    80004ce2:	985fe0ef          	jal	80003666 <namecmp>
    80004ce6:	10050e63          	beqz	a0,80004e02 <sys_unlink+0x160>
    80004cea:	00003597          	auipc	a1,0x3
    80004cee:	aae58593          	addi	a1,a1,-1362 # 80007798 <etext+0x798>
    80004cf2:	fb040513          	addi	a0,s0,-80
    80004cf6:	971fe0ef          	jal	80003666 <namecmp>
    80004cfa:	10050463          	beqz	a0,80004e02 <sys_unlink+0x160>
    80004cfe:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004d00:	f2c40613          	addi	a2,s0,-212
    80004d04:	fb040593          	addi	a1,s0,-80
    80004d08:	8526                	mv	a0,s1
    80004d0a:	973fe0ef          	jal	8000367c <dirlookup>
    80004d0e:	892a                	mv	s2,a0
    80004d10:	0e050863          	beqz	a0,80004e00 <sys_unlink+0x15e>
  ilock(ip);
    80004d14:	cf4fe0ef          	jal	80003208 <ilock>
  if(ip->nlink < 1)
    80004d18:	04a91783          	lh	a5,74(s2)
    80004d1c:	06f05763          	blez	a5,80004d8a <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004d20:	04491703          	lh	a4,68(s2)
    80004d24:	4785                	li	a5,1
    80004d26:	06f70963          	beq	a4,a5,80004d98 <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80004d2a:	4641                	li	a2,16
    80004d2c:	4581                	li	a1,0
    80004d2e:	fc040513          	addi	a0,s0,-64
    80004d32:	f97fb0ef          	jal	80000cc8 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004d36:	4741                	li	a4,16
    80004d38:	f2c42683          	lw	a3,-212(s0)
    80004d3c:	fc040613          	addi	a2,s0,-64
    80004d40:	4581                	li	a1,0
    80004d42:	8526                	mv	a0,s1
    80004d44:	815fe0ef          	jal	80003558 <writei>
    80004d48:	47c1                	li	a5,16
    80004d4a:	08f51b63          	bne	a0,a5,80004de0 <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    80004d4e:	04491703          	lh	a4,68(s2)
    80004d52:	4785                	li	a5,1
    80004d54:	08f70d63          	beq	a4,a5,80004dee <sys_unlink+0x14c>
  iunlockput(dp);
    80004d58:	8526                	mv	a0,s1
    80004d5a:	eb8fe0ef          	jal	80003412 <iunlockput>
  ip->nlink--;
    80004d5e:	04a95783          	lhu	a5,74(s2)
    80004d62:	37fd                	addiw	a5,a5,-1
    80004d64:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004d68:	854a                	mv	a0,s2
    80004d6a:	beafe0ef          	jal	80003154 <iupdate>
  iunlockput(ip);
    80004d6e:	854a                	mv	a0,s2
    80004d70:	ea2fe0ef          	jal	80003412 <iunlockput>
  end_op();
    80004d74:	d95fe0ef          	jal	80003b08 <end_op>
  return 0;
    80004d78:	4501                	li	a0,0
    80004d7a:	64ee                	ld	s1,216(sp)
    80004d7c:	694e                	ld	s2,208(sp)
    80004d7e:	a849                	j	80004e10 <sys_unlink+0x16e>
    end_op();
    80004d80:	d89fe0ef          	jal	80003b08 <end_op>
    return -1;
    80004d84:	557d                	li	a0,-1
    80004d86:	64ee                	ld	s1,216(sp)
    80004d88:	a061                	j	80004e10 <sys_unlink+0x16e>
    80004d8a:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80004d8c:	00003517          	auipc	a0,0x3
    80004d90:	a1450513          	addi	a0,a0,-1516 # 800077a0 <etext+0x7a0>
    80004d94:	a01fb0ef          	jal	80000794 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004d98:	04c92703          	lw	a4,76(s2)
    80004d9c:	02000793          	li	a5,32
    80004da0:	f8e7f5e3          	bgeu	a5,a4,80004d2a <sys_unlink+0x88>
    80004da4:	e5ce                	sd	s3,200(sp)
    80004da6:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004daa:	4741                	li	a4,16
    80004dac:	86ce                	mv	a3,s3
    80004dae:	f1840613          	addi	a2,s0,-232
    80004db2:	4581                	li	a1,0
    80004db4:	854a                	mv	a0,s2
    80004db6:	ea6fe0ef          	jal	8000345c <readi>
    80004dba:	47c1                	li	a5,16
    80004dbc:	00f51c63          	bne	a0,a5,80004dd4 <sys_unlink+0x132>
    if(de.inum != 0)
    80004dc0:	f1845783          	lhu	a5,-232(s0)
    80004dc4:	efa1                	bnez	a5,80004e1c <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004dc6:	29c1                	addiw	s3,s3,16
    80004dc8:	04c92783          	lw	a5,76(s2)
    80004dcc:	fcf9efe3          	bltu	s3,a5,80004daa <sys_unlink+0x108>
    80004dd0:	69ae                	ld	s3,200(sp)
    80004dd2:	bfa1                	j	80004d2a <sys_unlink+0x88>
      panic("isdirempty: readi");
    80004dd4:	00003517          	auipc	a0,0x3
    80004dd8:	9e450513          	addi	a0,a0,-1564 # 800077b8 <etext+0x7b8>
    80004ddc:	9b9fb0ef          	jal	80000794 <panic>
    80004de0:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80004de2:	00003517          	auipc	a0,0x3
    80004de6:	9ee50513          	addi	a0,a0,-1554 # 800077d0 <etext+0x7d0>
    80004dea:	9abfb0ef          	jal	80000794 <panic>
    dp->nlink--;
    80004dee:	04a4d783          	lhu	a5,74(s1)
    80004df2:	37fd                	addiw	a5,a5,-1
    80004df4:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004df8:	8526                	mv	a0,s1
    80004dfa:	b5afe0ef          	jal	80003154 <iupdate>
    80004dfe:	bfa9                	j	80004d58 <sys_unlink+0xb6>
    80004e00:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80004e02:	8526                	mv	a0,s1
    80004e04:	e0efe0ef          	jal	80003412 <iunlockput>
  end_op();
    80004e08:	d01fe0ef          	jal	80003b08 <end_op>
  return -1;
    80004e0c:	557d                	li	a0,-1
    80004e0e:	64ee                	ld	s1,216(sp)
}
    80004e10:	70ae                	ld	ra,232(sp)
    80004e12:	740e                	ld	s0,224(sp)
    80004e14:	616d                	addi	sp,sp,240
    80004e16:	8082                	ret
    return -1;
    80004e18:	557d                	li	a0,-1
    80004e1a:	bfdd                	j	80004e10 <sys_unlink+0x16e>
    iunlockput(ip);
    80004e1c:	854a                	mv	a0,s2
    80004e1e:	df4fe0ef          	jal	80003412 <iunlockput>
    goto bad;
    80004e22:	694e                	ld	s2,208(sp)
    80004e24:	69ae                	ld	s3,200(sp)
    80004e26:	bff1                	j	80004e02 <sys_unlink+0x160>

0000000080004e28 <sys_open>:

uint64
sys_open(void)
{
    80004e28:	7131                	addi	sp,sp,-192
    80004e2a:	fd06                	sd	ra,184(sp)
    80004e2c:	f922                	sd	s0,176(sp)
    80004e2e:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80004e30:	f4c40593          	addi	a1,s0,-180
    80004e34:	4505                	li	a0,1
    80004e36:	989fd0ef          	jal	800027be <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004e3a:	08000613          	li	a2,128
    80004e3e:	f5040593          	addi	a1,s0,-176
    80004e42:	4501                	li	a0,0
    80004e44:	9b3fd0ef          	jal	800027f6 <argstr>
    80004e48:	87aa                	mv	a5,a0
    return -1;
    80004e4a:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004e4c:	0a07c263          	bltz	a5,80004ef0 <sys_open+0xc8>
    80004e50:	f526                	sd	s1,168(sp)

  begin_op();
    80004e52:	c4dfe0ef          	jal	80003a9e <begin_op>

  if(omode & O_CREATE){
    80004e56:	f4c42783          	lw	a5,-180(s0)
    80004e5a:	2007f793          	andi	a5,a5,512
    80004e5e:	c3d5                	beqz	a5,80004f02 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80004e60:	4681                	li	a3,0
    80004e62:	4601                	li	a2,0
    80004e64:	4589                	li	a1,2
    80004e66:	f5040513          	addi	a0,s0,-176
    80004e6a:	aa9ff0ef          	jal	80004912 <create>
    80004e6e:	84aa                	mv	s1,a0
    if(ip == 0){
    80004e70:	c541                	beqz	a0,80004ef8 <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004e72:	04449703          	lh	a4,68(s1)
    80004e76:	478d                	li	a5,3
    80004e78:	00f71763          	bne	a4,a5,80004e86 <sys_open+0x5e>
    80004e7c:	0464d703          	lhu	a4,70(s1)
    80004e80:	47a5                	li	a5,9
    80004e82:	0ae7ed63          	bltu	a5,a4,80004f3c <sys_open+0x114>
    80004e86:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004e88:	fe1fe0ef          	jal	80003e68 <filealloc>
    80004e8c:	892a                	mv	s2,a0
    80004e8e:	c179                	beqz	a0,80004f54 <sys_open+0x12c>
    80004e90:	ed4e                	sd	s3,152(sp)
    80004e92:	a43ff0ef          	jal	800048d4 <fdalloc>
    80004e96:	89aa                	mv	s3,a0
    80004e98:	0a054a63          	bltz	a0,80004f4c <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004e9c:	04449703          	lh	a4,68(s1)
    80004ea0:	478d                	li	a5,3
    80004ea2:	0cf70263          	beq	a4,a5,80004f66 <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004ea6:	4789                	li	a5,2
    80004ea8:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80004eac:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80004eb0:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80004eb4:	f4c42783          	lw	a5,-180(s0)
    80004eb8:	0017c713          	xori	a4,a5,1
    80004ebc:	8b05                	andi	a4,a4,1
    80004ebe:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004ec2:	0037f713          	andi	a4,a5,3
    80004ec6:	00e03733          	snez	a4,a4
    80004eca:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80004ece:	4007f793          	andi	a5,a5,1024
    80004ed2:	c791                	beqz	a5,80004ede <sys_open+0xb6>
    80004ed4:	04449703          	lh	a4,68(s1)
    80004ed8:	4789                	li	a5,2
    80004eda:	08f70d63          	beq	a4,a5,80004f74 <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    80004ede:	8526                	mv	a0,s1
    80004ee0:	bd6fe0ef          	jal	800032b6 <iunlock>
  end_op();
    80004ee4:	c25fe0ef          	jal	80003b08 <end_op>

  return fd;
    80004ee8:	854e                	mv	a0,s3
    80004eea:	74aa                	ld	s1,168(sp)
    80004eec:	790a                	ld	s2,160(sp)
    80004eee:	69ea                	ld	s3,152(sp)
}
    80004ef0:	70ea                	ld	ra,184(sp)
    80004ef2:	744a                	ld	s0,176(sp)
    80004ef4:	6129                	addi	sp,sp,192
    80004ef6:	8082                	ret
      end_op();
    80004ef8:	c11fe0ef          	jal	80003b08 <end_op>
      return -1;
    80004efc:	557d                	li	a0,-1
    80004efe:	74aa                	ld	s1,168(sp)
    80004f00:	bfc5                	j	80004ef0 <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    80004f02:	f5040513          	addi	a0,s0,-176
    80004f06:	9ddfe0ef          	jal	800038e2 <namei>
    80004f0a:	84aa                	mv	s1,a0
    80004f0c:	c11d                	beqz	a0,80004f32 <sys_open+0x10a>
    ilock(ip);
    80004f0e:	afafe0ef          	jal	80003208 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80004f12:	04449703          	lh	a4,68(s1)
    80004f16:	4785                	li	a5,1
    80004f18:	f4f71de3          	bne	a4,a5,80004e72 <sys_open+0x4a>
    80004f1c:	f4c42783          	lw	a5,-180(s0)
    80004f20:	d3bd                	beqz	a5,80004e86 <sys_open+0x5e>
      iunlockput(ip);
    80004f22:	8526                	mv	a0,s1
    80004f24:	ceefe0ef          	jal	80003412 <iunlockput>
      end_op();
    80004f28:	be1fe0ef          	jal	80003b08 <end_op>
      return -1;
    80004f2c:	557d                	li	a0,-1
    80004f2e:	74aa                	ld	s1,168(sp)
    80004f30:	b7c1                	j	80004ef0 <sys_open+0xc8>
      end_op();
    80004f32:	bd7fe0ef          	jal	80003b08 <end_op>
      return -1;
    80004f36:	557d                	li	a0,-1
    80004f38:	74aa                	ld	s1,168(sp)
    80004f3a:	bf5d                	j	80004ef0 <sys_open+0xc8>
    iunlockput(ip);
    80004f3c:	8526                	mv	a0,s1
    80004f3e:	cd4fe0ef          	jal	80003412 <iunlockput>
    end_op();
    80004f42:	bc7fe0ef          	jal	80003b08 <end_op>
    return -1;
    80004f46:	557d                	li	a0,-1
    80004f48:	74aa                	ld	s1,168(sp)
    80004f4a:	b75d                	j	80004ef0 <sys_open+0xc8>
      fileclose(f);
    80004f4c:	854a                	mv	a0,s2
    80004f4e:	fbffe0ef          	jal	80003f0c <fileclose>
    80004f52:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80004f54:	8526                	mv	a0,s1
    80004f56:	cbcfe0ef          	jal	80003412 <iunlockput>
    end_op();
    80004f5a:	baffe0ef          	jal	80003b08 <end_op>
    return -1;
    80004f5e:	557d                	li	a0,-1
    80004f60:	74aa                	ld	s1,168(sp)
    80004f62:	790a                	ld	s2,160(sp)
    80004f64:	b771                	j	80004ef0 <sys_open+0xc8>
    f->type = FD_DEVICE;
    80004f66:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80004f6a:	04649783          	lh	a5,70(s1)
    80004f6e:	02f91223          	sh	a5,36(s2)
    80004f72:	bf3d                	j	80004eb0 <sys_open+0x88>
    itrunc(ip);
    80004f74:	8526                	mv	a0,s1
    80004f76:	b80fe0ef          	jal	800032f6 <itrunc>
    80004f7a:	b795                	j	80004ede <sys_open+0xb6>

0000000080004f7c <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80004f7c:	7175                	addi	sp,sp,-144
    80004f7e:	e506                	sd	ra,136(sp)
    80004f80:	e122                	sd	s0,128(sp)
    80004f82:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80004f84:	b1bfe0ef          	jal	80003a9e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80004f88:	08000613          	li	a2,128
    80004f8c:	f7040593          	addi	a1,s0,-144
    80004f90:	4501                	li	a0,0
    80004f92:	865fd0ef          	jal	800027f6 <argstr>
    80004f96:	02054363          	bltz	a0,80004fbc <sys_mkdir+0x40>
    80004f9a:	4681                	li	a3,0
    80004f9c:	4601                	li	a2,0
    80004f9e:	4585                	li	a1,1
    80004fa0:	f7040513          	addi	a0,s0,-144
    80004fa4:	96fff0ef          	jal	80004912 <create>
    80004fa8:	c911                	beqz	a0,80004fbc <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004faa:	c68fe0ef          	jal	80003412 <iunlockput>
  end_op();
    80004fae:	b5bfe0ef          	jal	80003b08 <end_op>
  return 0;
    80004fb2:	4501                	li	a0,0
}
    80004fb4:	60aa                	ld	ra,136(sp)
    80004fb6:	640a                	ld	s0,128(sp)
    80004fb8:	6149                	addi	sp,sp,144
    80004fba:	8082                	ret
    end_op();
    80004fbc:	b4dfe0ef          	jal	80003b08 <end_op>
    return -1;
    80004fc0:	557d                	li	a0,-1
    80004fc2:	bfcd                	j	80004fb4 <sys_mkdir+0x38>

0000000080004fc4 <sys_mknod>:

uint64
sys_mknod(void)
{
    80004fc4:	7135                	addi	sp,sp,-160
    80004fc6:	ed06                	sd	ra,152(sp)
    80004fc8:	e922                	sd	s0,144(sp)
    80004fca:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80004fcc:	ad3fe0ef          	jal	80003a9e <begin_op>
  argint(1, &major);
    80004fd0:	f6c40593          	addi	a1,s0,-148
    80004fd4:	4505                	li	a0,1
    80004fd6:	fe8fd0ef          	jal	800027be <argint>
  argint(2, &minor);
    80004fda:	f6840593          	addi	a1,s0,-152
    80004fde:	4509                	li	a0,2
    80004fe0:	fdefd0ef          	jal	800027be <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004fe4:	08000613          	li	a2,128
    80004fe8:	f7040593          	addi	a1,s0,-144
    80004fec:	4501                	li	a0,0
    80004fee:	809fd0ef          	jal	800027f6 <argstr>
    80004ff2:	02054563          	bltz	a0,8000501c <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80004ff6:	f6841683          	lh	a3,-152(s0)
    80004ffa:	f6c41603          	lh	a2,-148(s0)
    80004ffe:	458d                	li	a1,3
    80005000:	f7040513          	addi	a0,s0,-144
    80005004:	90fff0ef          	jal	80004912 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005008:	c911                	beqz	a0,8000501c <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000500a:	c08fe0ef          	jal	80003412 <iunlockput>
  end_op();
    8000500e:	afbfe0ef          	jal	80003b08 <end_op>
  return 0;
    80005012:	4501                	li	a0,0
}
    80005014:	60ea                	ld	ra,152(sp)
    80005016:	644a                	ld	s0,144(sp)
    80005018:	610d                	addi	sp,sp,160
    8000501a:	8082                	ret
    end_op();
    8000501c:	aedfe0ef          	jal	80003b08 <end_op>
    return -1;
    80005020:	557d                	li	a0,-1
    80005022:	bfcd                	j	80005014 <sys_mknod+0x50>

0000000080005024 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005024:	7135                	addi	sp,sp,-160
    80005026:	ed06                	sd	ra,152(sp)
    80005028:	e922                	sd	s0,144(sp)
    8000502a:	e14a                	sd	s2,128(sp)
    8000502c:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000502e:	8ddfc0ef          	jal	8000190a <myproc>
    80005032:	892a                	mv	s2,a0
  
  begin_op();
    80005034:	a6bfe0ef          	jal	80003a9e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005038:	08000613          	li	a2,128
    8000503c:	f6040593          	addi	a1,s0,-160
    80005040:	4501                	li	a0,0
    80005042:	fb4fd0ef          	jal	800027f6 <argstr>
    80005046:	04054363          	bltz	a0,8000508c <sys_chdir+0x68>
    8000504a:	e526                	sd	s1,136(sp)
    8000504c:	f6040513          	addi	a0,s0,-160
    80005050:	893fe0ef          	jal	800038e2 <namei>
    80005054:	84aa                	mv	s1,a0
    80005056:	c915                	beqz	a0,8000508a <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005058:	9b0fe0ef          	jal	80003208 <ilock>
  if(ip->type != T_DIR){
    8000505c:	04449703          	lh	a4,68(s1)
    80005060:	4785                	li	a5,1
    80005062:	02f71963          	bne	a4,a5,80005094 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005066:	8526                	mv	a0,s1
    80005068:	a4efe0ef          	jal	800032b6 <iunlock>
  iput(p->cwd);
    8000506c:	15093503          	ld	a0,336(s2)
    80005070:	b1afe0ef          	jal	8000338a <iput>
  end_op();
    80005074:	a95fe0ef          	jal	80003b08 <end_op>
  p->cwd = ip;
    80005078:	14993823          	sd	s1,336(s2)
  return 0;
    8000507c:	4501                	li	a0,0
    8000507e:	64aa                	ld	s1,136(sp)
}
    80005080:	60ea                	ld	ra,152(sp)
    80005082:	644a                	ld	s0,144(sp)
    80005084:	690a                	ld	s2,128(sp)
    80005086:	610d                	addi	sp,sp,160
    80005088:	8082                	ret
    8000508a:	64aa                	ld	s1,136(sp)
    end_op();
    8000508c:	a7dfe0ef          	jal	80003b08 <end_op>
    return -1;
    80005090:	557d                	li	a0,-1
    80005092:	b7fd                	j	80005080 <sys_chdir+0x5c>
    iunlockput(ip);
    80005094:	8526                	mv	a0,s1
    80005096:	b7cfe0ef          	jal	80003412 <iunlockput>
    end_op();
    8000509a:	a6ffe0ef          	jal	80003b08 <end_op>
    return -1;
    8000509e:	557d                	li	a0,-1
    800050a0:	64aa                	ld	s1,136(sp)
    800050a2:	bff9                	j	80005080 <sys_chdir+0x5c>

00000000800050a4 <sys_exec>:

uint64
sys_exec(void)
{
    800050a4:	7121                	addi	sp,sp,-448
    800050a6:	ff06                	sd	ra,440(sp)
    800050a8:	fb22                	sd	s0,432(sp)
    800050aa:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800050ac:	e4840593          	addi	a1,s0,-440
    800050b0:	4505                	li	a0,1
    800050b2:	f28fd0ef          	jal	800027da <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800050b6:	08000613          	li	a2,128
    800050ba:	f5040593          	addi	a1,s0,-176
    800050be:	4501                	li	a0,0
    800050c0:	f36fd0ef          	jal	800027f6 <argstr>
    800050c4:	87aa                	mv	a5,a0
    return -1;
    800050c6:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800050c8:	0c07c463          	bltz	a5,80005190 <sys_exec+0xec>
    800050cc:	f726                	sd	s1,424(sp)
    800050ce:	f34a                	sd	s2,416(sp)
    800050d0:	ef4e                	sd	s3,408(sp)
    800050d2:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    800050d4:	10000613          	li	a2,256
    800050d8:	4581                	li	a1,0
    800050da:	e5040513          	addi	a0,s0,-432
    800050de:	bebfb0ef          	jal	80000cc8 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800050e2:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    800050e6:	89a6                	mv	s3,s1
    800050e8:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800050ea:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800050ee:	00391513          	slli	a0,s2,0x3
    800050f2:	e4040593          	addi	a1,s0,-448
    800050f6:	e4843783          	ld	a5,-440(s0)
    800050fa:	953e                	add	a0,a0,a5
    800050fc:	e38fd0ef          	jal	80002734 <fetchaddr>
    80005100:	02054663          	bltz	a0,8000512c <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    80005104:	e4043783          	ld	a5,-448(s0)
    80005108:	c3a9                	beqz	a5,8000514a <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    8000510a:	a1bfb0ef          	jal	80000b24 <kalloc>
    8000510e:	85aa                	mv	a1,a0
    80005110:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005114:	cd01                	beqz	a0,8000512c <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005116:	6605                	lui	a2,0x1
    80005118:	e4043503          	ld	a0,-448(s0)
    8000511c:	e62fd0ef          	jal	8000277e <fetchstr>
    80005120:	00054663          	bltz	a0,8000512c <sys_exec+0x88>
    if(i >= NELEM(argv)){
    80005124:	0905                	addi	s2,s2,1
    80005126:	09a1                	addi	s3,s3,8
    80005128:	fd4913e3          	bne	s2,s4,800050ee <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000512c:	f5040913          	addi	s2,s0,-176
    80005130:	6088                	ld	a0,0(s1)
    80005132:	c931                	beqz	a0,80005186 <sys_exec+0xe2>
    kfree(argv[i]);
    80005134:	90ffb0ef          	jal	80000a42 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005138:	04a1                	addi	s1,s1,8
    8000513a:	ff249be3          	bne	s1,s2,80005130 <sys_exec+0x8c>
  return -1;
    8000513e:	557d                	li	a0,-1
    80005140:	74ba                	ld	s1,424(sp)
    80005142:	791a                	ld	s2,416(sp)
    80005144:	69fa                	ld	s3,408(sp)
    80005146:	6a5a                	ld	s4,400(sp)
    80005148:	a0a1                	j	80005190 <sys_exec+0xec>
      argv[i] = 0;
    8000514a:	0009079b          	sext.w	a5,s2
    8000514e:	078e                	slli	a5,a5,0x3
    80005150:	fd078793          	addi	a5,a5,-48
    80005154:	97a2                	add	a5,a5,s0
    80005156:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    8000515a:	e5040593          	addi	a1,s0,-432
    8000515e:	f5040513          	addi	a0,s0,-176
    80005162:	ba8ff0ef          	jal	8000450a <exec>
    80005166:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005168:	f5040993          	addi	s3,s0,-176
    8000516c:	6088                	ld	a0,0(s1)
    8000516e:	c511                	beqz	a0,8000517a <sys_exec+0xd6>
    kfree(argv[i]);
    80005170:	8d3fb0ef          	jal	80000a42 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005174:	04a1                	addi	s1,s1,8
    80005176:	ff349be3          	bne	s1,s3,8000516c <sys_exec+0xc8>
  return ret;
    8000517a:	854a                	mv	a0,s2
    8000517c:	74ba                	ld	s1,424(sp)
    8000517e:	791a                	ld	s2,416(sp)
    80005180:	69fa                	ld	s3,408(sp)
    80005182:	6a5a                	ld	s4,400(sp)
    80005184:	a031                	j	80005190 <sys_exec+0xec>
  return -1;
    80005186:	557d                	li	a0,-1
    80005188:	74ba                	ld	s1,424(sp)
    8000518a:	791a                	ld	s2,416(sp)
    8000518c:	69fa                	ld	s3,408(sp)
    8000518e:	6a5a                	ld	s4,400(sp)
}
    80005190:	70fa                	ld	ra,440(sp)
    80005192:	745a                	ld	s0,432(sp)
    80005194:	6139                	addi	sp,sp,448
    80005196:	8082                	ret

0000000080005198 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005198:	7139                	addi	sp,sp,-64
    8000519a:	fc06                	sd	ra,56(sp)
    8000519c:	f822                	sd	s0,48(sp)
    8000519e:	f426                	sd	s1,40(sp)
    800051a0:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800051a2:	f68fc0ef          	jal	8000190a <myproc>
    800051a6:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800051a8:	fd840593          	addi	a1,s0,-40
    800051ac:	4501                	li	a0,0
    800051ae:	e2cfd0ef          	jal	800027da <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800051b2:	fc840593          	addi	a1,s0,-56
    800051b6:	fd040513          	addi	a0,s0,-48
    800051ba:	85cff0ef          	jal	80004216 <pipealloc>
    return -1;
    800051be:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800051c0:	0a054463          	bltz	a0,80005268 <sys_pipe+0xd0>
  fd0 = -1;
    800051c4:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800051c8:	fd043503          	ld	a0,-48(s0)
    800051cc:	f08ff0ef          	jal	800048d4 <fdalloc>
    800051d0:	fca42223          	sw	a0,-60(s0)
    800051d4:	08054163          	bltz	a0,80005256 <sys_pipe+0xbe>
    800051d8:	fc843503          	ld	a0,-56(s0)
    800051dc:	ef8ff0ef          	jal	800048d4 <fdalloc>
    800051e0:	fca42023          	sw	a0,-64(s0)
    800051e4:	06054063          	bltz	a0,80005244 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800051e8:	4691                	li	a3,4
    800051ea:	fc440613          	addi	a2,s0,-60
    800051ee:	fd843583          	ld	a1,-40(s0)
    800051f2:	68a8                	ld	a0,80(s1)
    800051f4:	b88fc0ef          	jal	8000157c <copyout>
    800051f8:	00054e63          	bltz	a0,80005214 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800051fc:	4691                	li	a3,4
    800051fe:	fc040613          	addi	a2,s0,-64
    80005202:	fd843583          	ld	a1,-40(s0)
    80005206:	0591                	addi	a1,a1,4
    80005208:	68a8                	ld	a0,80(s1)
    8000520a:	b72fc0ef          	jal	8000157c <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000520e:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005210:	04055c63          	bgez	a0,80005268 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80005214:	fc442783          	lw	a5,-60(s0)
    80005218:	07e9                	addi	a5,a5,26
    8000521a:	078e                	slli	a5,a5,0x3
    8000521c:	97a6                	add	a5,a5,s1
    8000521e:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005222:	fc042783          	lw	a5,-64(s0)
    80005226:	07e9                	addi	a5,a5,26
    80005228:	078e                	slli	a5,a5,0x3
    8000522a:	94be                	add	s1,s1,a5
    8000522c:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005230:	fd043503          	ld	a0,-48(s0)
    80005234:	cd9fe0ef          	jal	80003f0c <fileclose>
    fileclose(wf);
    80005238:	fc843503          	ld	a0,-56(s0)
    8000523c:	cd1fe0ef          	jal	80003f0c <fileclose>
    return -1;
    80005240:	57fd                	li	a5,-1
    80005242:	a01d                	j	80005268 <sys_pipe+0xd0>
    if(fd0 >= 0)
    80005244:	fc442783          	lw	a5,-60(s0)
    80005248:	0007c763          	bltz	a5,80005256 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    8000524c:	07e9                	addi	a5,a5,26
    8000524e:	078e                	slli	a5,a5,0x3
    80005250:	97a6                	add	a5,a5,s1
    80005252:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005256:	fd043503          	ld	a0,-48(s0)
    8000525a:	cb3fe0ef          	jal	80003f0c <fileclose>
    fileclose(wf);
    8000525e:	fc843503          	ld	a0,-56(s0)
    80005262:	cabfe0ef          	jal	80003f0c <fileclose>
    return -1;
    80005266:	57fd                	li	a5,-1
}
    80005268:	853e                	mv	a0,a5
    8000526a:	70e2                	ld	ra,56(sp)
    8000526c:	7442                	ld	s0,48(sp)
    8000526e:	74a2                	ld	s1,40(sp)
    80005270:	6121                	addi	sp,sp,64
    80005272:	8082                	ret
	...

0000000080005280 <kernelvec>:
    80005280:	7111                	addi	sp,sp,-256
    80005282:	e006                	sd	ra,0(sp)
    80005284:	e40a                	sd	sp,8(sp)
    80005286:	e80e                	sd	gp,16(sp)
    80005288:	ec12                	sd	tp,24(sp)
    8000528a:	f016                	sd	t0,32(sp)
    8000528c:	f41a                	sd	t1,40(sp)
    8000528e:	f81e                	sd	t2,48(sp)
    80005290:	e4aa                	sd	a0,72(sp)
    80005292:	e8ae                	sd	a1,80(sp)
    80005294:	ecb2                	sd	a2,88(sp)
    80005296:	f0b6                	sd	a3,96(sp)
    80005298:	f4ba                	sd	a4,104(sp)
    8000529a:	f8be                	sd	a5,112(sp)
    8000529c:	fcc2                	sd	a6,120(sp)
    8000529e:	e146                	sd	a7,128(sp)
    800052a0:	edf2                	sd	t3,216(sp)
    800052a2:	f1f6                	sd	t4,224(sp)
    800052a4:	f5fa                	sd	t5,232(sp)
    800052a6:	f9fe                	sd	t6,240(sp)
    800052a8:	b9cfd0ef          	jal	80002644 <kerneltrap>
    800052ac:	6082                	ld	ra,0(sp)
    800052ae:	6122                	ld	sp,8(sp)
    800052b0:	61c2                	ld	gp,16(sp)
    800052b2:	7282                	ld	t0,32(sp)
    800052b4:	7322                	ld	t1,40(sp)
    800052b6:	73c2                	ld	t2,48(sp)
    800052b8:	6526                	ld	a0,72(sp)
    800052ba:	65c6                	ld	a1,80(sp)
    800052bc:	6666                	ld	a2,88(sp)
    800052be:	7686                	ld	a3,96(sp)
    800052c0:	7726                	ld	a4,104(sp)
    800052c2:	77c6                	ld	a5,112(sp)
    800052c4:	7866                	ld	a6,120(sp)
    800052c6:	688a                	ld	a7,128(sp)
    800052c8:	6e6e                	ld	t3,216(sp)
    800052ca:	7e8e                	ld	t4,224(sp)
    800052cc:	7f2e                	ld	t5,232(sp)
    800052ce:	7fce                	ld	t6,240(sp)
    800052d0:	6111                	addi	sp,sp,256
    800052d2:	10200073          	sret
	...

00000000800052de <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800052de:	1141                	addi	sp,sp,-16
    800052e0:	e422                	sd	s0,8(sp)
    800052e2:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800052e4:	0c0007b7          	lui	a5,0xc000
    800052e8:	4705                	li	a4,1
    800052ea:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800052ec:	0c0007b7          	lui	a5,0xc000
    800052f0:	c3d8                	sw	a4,4(a5)
}
    800052f2:	6422                	ld	s0,8(sp)
    800052f4:	0141                	addi	sp,sp,16
    800052f6:	8082                	ret

00000000800052f8 <plicinithart>:

void
plicinithart(void)
{
    800052f8:	1141                	addi	sp,sp,-16
    800052fa:	e406                	sd	ra,8(sp)
    800052fc:	e022                	sd	s0,0(sp)
    800052fe:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005300:	ddefc0ef          	jal	800018de <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005304:	0085171b          	slliw	a4,a0,0x8
    80005308:	0c0027b7          	lui	a5,0xc002
    8000530c:	97ba                	add	a5,a5,a4
    8000530e:	40200713          	li	a4,1026
    80005312:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005316:	00d5151b          	slliw	a0,a0,0xd
    8000531a:	0c2017b7          	lui	a5,0xc201
    8000531e:	97aa                	add	a5,a5,a0
    80005320:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005324:	60a2                	ld	ra,8(sp)
    80005326:	6402                	ld	s0,0(sp)
    80005328:	0141                	addi	sp,sp,16
    8000532a:	8082                	ret

000000008000532c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000532c:	1141                	addi	sp,sp,-16
    8000532e:	e406                	sd	ra,8(sp)
    80005330:	e022                	sd	s0,0(sp)
    80005332:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005334:	daafc0ef          	jal	800018de <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005338:	00d5151b          	slliw	a0,a0,0xd
    8000533c:	0c2017b7          	lui	a5,0xc201
    80005340:	97aa                	add	a5,a5,a0
  return irq;
}
    80005342:	43c8                	lw	a0,4(a5)
    80005344:	60a2                	ld	ra,8(sp)
    80005346:	6402                	ld	s0,0(sp)
    80005348:	0141                	addi	sp,sp,16
    8000534a:	8082                	ret

000000008000534c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000534c:	1101                	addi	sp,sp,-32
    8000534e:	ec06                	sd	ra,24(sp)
    80005350:	e822                	sd	s0,16(sp)
    80005352:	e426                	sd	s1,8(sp)
    80005354:	1000                	addi	s0,sp,32
    80005356:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005358:	d86fc0ef          	jal	800018de <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000535c:	00d5151b          	slliw	a0,a0,0xd
    80005360:	0c2017b7          	lui	a5,0xc201
    80005364:	97aa                	add	a5,a5,a0
    80005366:	c3c4                	sw	s1,4(a5)
}
    80005368:	60e2                	ld	ra,24(sp)
    8000536a:	6442                	ld	s0,16(sp)
    8000536c:	64a2                	ld	s1,8(sp)
    8000536e:	6105                	addi	sp,sp,32
    80005370:	8082                	ret

0000000080005372 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005372:	1141                	addi	sp,sp,-16
    80005374:	e406                	sd	ra,8(sp)
    80005376:	e022                	sd	s0,0(sp)
    80005378:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000537a:	479d                	li	a5,7
    8000537c:	04a7ca63          	blt	a5,a0,800053d0 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005380:	0001c797          	auipc	a5,0x1c
    80005384:	90078793          	addi	a5,a5,-1792 # 80020c80 <disk>
    80005388:	97aa                	add	a5,a5,a0
    8000538a:	0187c783          	lbu	a5,24(a5)
    8000538e:	e7b9                	bnez	a5,800053dc <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005390:	00451693          	slli	a3,a0,0x4
    80005394:	0001c797          	auipc	a5,0x1c
    80005398:	8ec78793          	addi	a5,a5,-1812 # 80020c80 <disk>
    8000539c:	6398                	ld	a4,0(a5)
    8000539e:	9736                	add	a4,a4,a3
    800053a0:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    800053a4:	6398                	ld	a4,0(a5)
    800053a6:	9736                	add	a4,a4,a3
    800053a8:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800053ac:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800053b0:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800053b4:	97aa                	add	a5,a5,a0
    800053b6:	4705                	li	a4,1
    800053b8:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800053bc:	0001c517          	auipc	a0,0x1c
    800053c0:	8dc50513          	addi	a0,a0,-1828 # 80020c98 <disk+0x18>
    800053c4:	b61fc0ef          	jal	80001f24 <wakeup>
}
    800053c8:	60a2                	ld	ra,8(sp)
    800053ca:	6402                	ld	s0,0(sp)
    800053cc:	0141                	addi	sp,sp,16
    800053ce:	8082                	ret
    panic("free_desc 1");
    800053d0:	00002517          	auipc	a0,0x2
    800053d4:	41050513          	addi	a0,a0,1040 # 800077e0 <etext+0x7e0>
    800053d8:	bbcfb0ef          	jal	80000794 <panic>
    panic("free_desc 2");
    800053dc:	00002517          	auipc	a0,0x2
    800053e0:	41450513          	addi	a0,a0,1044 # 800077f0 <etext+0x7f0>
    800053e4:	bb0fb0ef          	jal	80000794 <panic>

00000000800053e8 <virtio_disk_init>:
{
    800053e8:	1101                	addi	sp,sp,-32
    800053ea:	ec06                	sd	ra,24(sp)
    800053ec:	e822                	sd	s0,16(sp)
    800053ee:	e426                	sd	s1,8(sp)
    800053f0:	e04a                	sd	s2,0(sp)
    800053f2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800053f4:	00002597          	auipc	a1,0x2
    800053f8:	40c58593          	addi	a1,a1,1036 # 80007800 <etext+0x800>
    800053fc:	0001c517          	auipc	a0,0x1c
    80005400:	9ac50513          	addi	a0,a0,-1620 # 80020da8 <disk+0x128>
    80005404:	f70fb0ef          	jal	80000b74 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005408:	100017b7          	lui	a5,0x10001
    8000540c:	4398                	lw	a4,0(a5)
    8000540e:	2701                	sext.w	a4,a4
    80005410:	747277b7          	lui	a5,0x74727
    80005414:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005418:	18f71063          	bne	a4,a5,80005598 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000541c:	100017b7          	lui	a5,0x10001
    80005420:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80005422:	439c                	lw	a5,0(a5)
    80005424:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005426:	4709                	li	a4,2
    80005428:	16e79863          	bne	a5,a4,80005598 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000542c:	100017b7          	lui	a5,0x10001
    80005430:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80005432:	439c                	lw	a5,0(a5)
    80005434:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005436:	16e79163          	bne	a5,a4,80005598 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000543a:	100017b7          	lui	a5,0x10001
    8000543e:	47d8                	lw	a4,12(a5)
    80005440:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005442:	554d47b7          	lui	a5,0x554d4
    80005446:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000544a:	14f71763          	bne	a4,a5,80005598 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000544e:	100017b7          	lui	a5,0x10001
    80005452:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005456:	4705                	li	a4,1
    80005458:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000545a:	470d                	li	a4,3
    8000545c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000545e:	10001737          	lui	a4,0x10001
    80005462:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005464:	c7ffe737          	lui	a4,0xc7ffe
    80005468:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdd99f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000546c:	8ef9                	and	a3,a3,a4
    8000546e:	10001737          	lui	a4,0x10001
    80005472:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005474:	472d                	li	a4,11
    80005476:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005478:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    8000547c:	439c                	lw	a5,0(a5)
    8000547e:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005482:	8ba1                	andi	a5,a5,8
    80005484:	12078063          	beqz	a5,800055a4 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005488:	100017b7          	lui	a5,0x10001
    8000548c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005490:	100017b7          	lui	a5,0x10001
    80005494:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80005498:	439c                	lw	a5,0(a5)
    8000549a:	2781                	sext.w	a5,a5
    8000549c:	10079a63          	bnez	a5,800055b0 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800054a0:	100017b7          	lui	a5,0x10001
    800054a4:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    800054a8:	439c                	lw	a5,0(a5)
    800054aa:	2781                	sext.w	a5,a5
  if(max == 0)
    800054ac:	10078863          	beqz	a5,800055bc <virtio_disk_init+0x1d4>
  if(max < NUM)
    800054b0:	471d                	li	a4,7
    800054b2:	10f77b63          	bgeu	a4,a5,800055c8 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    800054b6:	e6efb0ef          	jal	80000b24 <kalloc>
    800054ba:	0001b497          	auipc	s1,0x1b
    800054be:	7c648493          	addi	s1,s1,1990 # 80020c80 <disk>
    800054c2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800054c4:	e60fb0ef          	jal	80000b24 <kalloc>
    800054c8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800054ca:	e5afb0ef          	jal	80000b24 <kalloc>
    800054ce:	87aa                	mv	a5,a0
    800054d0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800054d2:	6088                	ld	a0,0(s1)
    800054d4:	10050063          	beqz	a0,800055d4 <virtio_disk_init+0x1ec>
    800054d8:	0001b717          	auipc	a4,0x1b
    800054dc:	7b073703          	ld	a4,1968(a4) # 80020c88 <disk+0x8>
    800054e0:	0e070a63          	beqz	a4,800055d4 <virtio_disk_init+0x1ec>
    800054e4:	0e078863          	beqz	a5,800055d4 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    800054e8:	6605                	lui	a2,0x1
    800054ea:	4581                	li	a1,0
    800054ec:	fdcfb0ef          	jal	80000cc8 <memset>
  memset(disk.avail, 0, PGSIZE);
    800054f0:	0001b497          	auipc	s1,0x1b
    800054f4:	79048493          	addi	s1,s1,1936 # 80020c80 <disk>
    800054f8:	6605                	lui	a2,0x1
    800054fa:	4581                	li	a1,0
    800054fc:	6488                	ld	a0,8(s1)
    800054fe:	fcafb0ef          	jal	80000cc8 <memset>
  memset(disk.used, 0, PGSIZE);
    80005502:	6605                	lui	a2,0x1
    80005504:	4581                	li	a1,0
    80005506:	6888                	ld	a0,16(s1)
    80005508:	fc0fb0ef          	jal	80000cc8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000550c:	100017b7          	lui	a5,0x10001
    80005510:	4721                	li	a4,8
    80005512:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005514:	4098                	lw	a4,0(s1)
    80005516:	100017b7          	lui	a5,0x10001
    8000551a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    8000551e:	40d8                	lw	a4,4(s1)
    80005520:	100017b7          	lui	a5,0x10001
    80005524:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005528:	649c                	ld	a5,8(s1)
    8000552a:	0007869b          	sext.w	a3,a5
    8000552e:	10001737          	lui	a4,0x10001
    80005532:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005536:	9781                	srai	a5,a5,0x20
    80005538:	10001737          	lui	a4,0x10001
    8000553c:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005540:	689c                	ld	a5,16(s1)
    80005542:	0007869b          	sext.w	a3,a5
    80005546:	10001737          	lui	a4,0x10001
    8000554a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000554e:	9781                	srai	a5,a5,0x20
    80005550:	10001737          	lui	a4,0x10001
    80005554:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005558:	10001737          	lui	a4,0x10001
    8000555c:	4785                	li	a5,1
    8000555e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005560:	00f48c23          	sb	a5,24(s1)
    80005564:	00f48ca3          	sb	a5,25(s1)
    80005568:	00f48d23          	sb	a5,26(s1)
    8000556c:	00f48da3          	sb	a5,27(s1)
    80005570:	00f48e23          	sb	a5,28(s1)
    80005574:	00f48ea3          	sb	a5,29(s1)
    80005578:	00f48f23          	sb	a5,30(s1)
    8000557c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005580:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005584:	100017b7          	lui	a5,0x10001
    80005588:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    8000558c:	60e2                	ld	ra,24(sp)
    8000558e:	6442                	ld	s0,16(sp)
    80005590:	64a2                	ld	s1,8(sp)
    80005592:	6902                	ld	s2,0(sp)
    80005594:	6105                	addi	sp,sp,32
    80005596:	8082                	ret
    panic("could not find virtio disk");
    80005598:	00002517          	auipc	a0,0x2
    8000559c:	27850513          	addi	a0,a0,632 # 80007810 <etext+0x810>
    800055a0:	9f4fb0ef          	jal	80000794 <panic>
    panic("virtio disk FEATURES_OK unset");
    800055a4:	00002517          	auipc	a0,0x2
    800055a8:	28c50513          	addi	a0,a0,652 # 80007830 <etext+0x830>
    800055ac:	9e8fb0ef          	jal	80000794 <panic>
    panic("virtio disk should not be ready");
    800055b0:	00002517          	auipc	a0,0x2
    800055b4:	2a050513          	addi	a0,a0,672 # 80007850 <etext+0x850>
    800055b8:	9dcfb0ef          	jal	80000794 <panic>
    panic("virtio disk has no queue 0");
    800055bc:	00002517          	auipc	a0,0x2
    800055c0:	2b450513          	addi	a0,a0,692 # 80007870 <etext+0x870>
    800055c4:	9d0fb0ef          	jal	80000794 <panic>
    panic("virtio disk max queue too short");
    800055c8:	00002517          	auipc	a0,0x2
    800055cc:	2c850513          	addi	a0,a0,712 # 80007890 <etext+0x890>
    800055d0:	9c4fb0ef          	jal	80000794 <panic>
    panic("virtio disk kalloc");
    800055d4:	00002517          	auipc	a0,0x2
    800055d8:	2dc50513          	addi	a0,a0,732 # 800078b0 <etext+0x8b0>
    800055dc:	9b8fb0ef          	jal	80000794 <panic>

00000000800055e0 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800055e0:	7159                	addi	sp,sp,-112
    800055e2:	f486                	sd	ra,104(sp)
    800055e4:	f0a2                	sd	s0,96(sp)
    800055e6:	eca6                	sd	s1,88(sp)
    800055e8:	e8ca                	sd	s2,80(sp)
    800055ea:	e4ce                	sd	s3,72(sp)
    800055ec:	e0d2                	sd	s4,64(sp)
    800055ee:	fc56                	sd	s5,56(sp)
    800055f0:	f85a                	sd	s6,48(sp)
    800055f2:	f45e                	sd	s7,40(sp)
    800055f4:	f062                	sd	s8,32(sp)
    800055f6:	ec66                	sd	s9,24(sp)
    800055f8:	1880                	addi	s0,sp,112
    800055fa:	8a2a                	mv	s4,a0
    800055fc:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800055fe:	00c52c83          	lw	s9,12(a0)
    80005602:	001c9c9b          	slliw	s9,s9,0x1
    80005606:	1c82                	slli	s9,s9,0x20
    80005608:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    8000560c:	0001b517          	auipc	a0,0x1b
    80005610:	79c50513          	addi	a0,a0,1948 # 80020da8 <disk+0x128>
    80005614:	de0fb0ef          	jal	80000bf4 <acquire>
  for(int i = 0; i < 3; i++){
    80005618:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    8000561a:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000561c:	0001bb17          	auipc	s6,0x1b
    80005620:	664b0b13          	addi	s6,s6,1636 # 80020c80 <disk>
  for(int i = 0; i < 3; i++){
    80005624:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005626:	0001bc17          	auipc	s8,0x1b
    8000562a:	782c0c13          	addi	s8,s8,1922 # 80020da8 <disk+0x128>
    8000562e:	a8b9                	j	8000568c <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80005630:	00fb0733          	add	a4,s6,a5
    80005634:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80005638:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    8000563a:	0207c563          	bltz	a5,80005664 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    8000563e:	2905                	addiw	s2,s2,1
    80005640:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005642:	05590963          	beq	s2,s5,80005694 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    80005646:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005648:	0001b717          	auipc	a4,0x1b
    8000564c:	63870713          	addi	a4,a4,1592 # 80020c80 <disk>
    80005650:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005652:	01874683          	lbu	a3,24(a4)
    80005656:	fee9                	bnez	a3,80005630 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80005658:	2785                	addiw	a5,a5,1
    8000565a:	0705                	addi	a4,a4,1
    8000565c:	fe979be3          	bne	a5,s1,80005652 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80005660:	57fd                	li	a5,-1
    80005662:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005664:	01205d63          	blez	s2,8000567e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005668:	f9042503          	lw	a0,-112(s0)
    8000566c:	d07ff0ef          	jal	80005372 <free_desc>
      for(int j = 0; j < i; j++)
    80005670:	4785                	li	a5,1
    80005672:	0127d663          	bge	a5,s2,8000567e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005676:	f9442503          	lw	a0,-108(s0)
    8000567a:	cf9ff0ef          	jal	80005372 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000567e:	85e2                	mv	a1,s8
    80005680:	0001b517          	auipc	a0,0x1b
    80005684:	61850513          	addi	a0,a0,1560 # 80020c98 <disk+0x18>
    80005688:	851fc0ef          	jal	80001ed8 <sleep>
  for(int i = 0; i < 3; i++){
    8000568c:	f9040613          	addi	a2,s0,-112
    80005690:	894e                	mv	s2,s3
    80005692:	bf55                	j	80005646 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005694:	f9042503          	lw	a0,-112(s0)
    80005698:	00451693          	slli	a3,a0,0x4

  if(write)
    8000569c:	0001b797          	auipc	a5,0x1b
    800056a0:	5e478793          	addi	a5,a5,1508 # 80020c80 <disk>
    800056a4:	00a50713          	addi	a4,a0,10
    800056a8:	0712                	slli	a4,a4,0x4
    800056aa:	973e                	add	a4,a4,a5
    800056ac:	01703633          	snez	a2,s7
    800056b0:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800056b2:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800056b6:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800056ba:	6398                	ld	a4,0(a5)
    800056bc:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800056be:	0a868613          	addi	a2,a3,168
    800056c2:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800056c4:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800056c6:	6390                	ld	a2,0(a5)
    800056c8:	00d605b3          	add	a1,a2,a3
    800056cc:	4741                	li	a4,16
    800056ce:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800056d0:	4805                	li	a6,1
    800056d2:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    800056d6:	f9442703          	lw	a4,-108(s0)
    800056da:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800056de:	0712                	slli	a4,a4,0x4
    800056e0:	963a                	add	a2,a2,a4
    800056e2:	058a0593          	addi	a1,s4,88
    800056e6:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800056e8:	0007b883          	ld	a7,0(a5)
    800056ec:	9746                	add	a4,a4,a7
    800056ee:	40000613          	li	a2,1024
    800056f2:	c710                	sw	a2,8(a4)
  if(write)
    800056f4:	001bb613          	seqz	a2,s7
    800056f8:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800056fc:	00166613          	ori	a2,a2,1
    80005700:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005704:	f9842583          	lw	a1,-104(s0)
    80005708:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000570c:	00250613          	addi	a2,a0,2
    80005710:	0612                	slli	a2,a2,0x4
    80005712:	963e                	add	a2,a2,a5
    80005714:	577d                	li	a4,-1
    80005716:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000571a:	0592                	slli	a1,a1,0x4
    8000571c:	98ae                	add	a7,a7,a1
    8000571e:	03068713          	addi	a4,a3,48
    80005722:	973e                	add	a4,a4,a5
    80005724:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005728:	6398                	ld	a4,0(a5)
    8000572a:	972e                	add	a4,a4,a1
    8000572c:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005730:	4689                	li	a3,2
    80005732:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005736:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000573a:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    8000573e:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005742:	6794                	ld	a3,8(a5)
    80005744:	0026d703          	lhu	a4,2(a3)
    80005748:	8b1d                	andi	a4,a4,7
    8000574a:	0706                	slli	a4,a4,0x1
    8000574c:	96ba                	add	a3,a3,a4
    8000574e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005752:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005756:	6798                	ld	a4,8(a5)
    80005758:	00275783          	lhu	a5,2(a4)
    8000575c:	2785                	addiw	a5,a5,1
    8000575e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005762:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005766:	100017b7          	lui	a5,0x10001
    8000576a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000576e:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80005772:	0001b917          	auipc	s2,0x1b
    80005776:	63690913          	addi	s2,s2,1590 # 80020da8 <disk+0x128>
  while(b->disk == 1) {
    8000577a:	4485                	li	s1,1
    8000577c:	01079a63          	bne	a5,a6,80005790 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005780:	85ca                	mv	a1,s2
    80005782:	8552                	mv	a0,s4
    80005784:	f54fc0ef          	jal	80001ed8 <sleep>
  while(b->disk == 1) {
    80005788:	004a2783          	lw	a5,4(s4)
    8000578c:	fe978ae3          	beq	a5,s1,80005780 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005790:	f9042903          	lw	s2,-112(s0)
    80005794:	00290713          	addi	a4,s2,2
    80005798:	0712                	slli	a4,a4,0x4
    8000579a:	0001b797          	auipc	a5,0x1b
    8000579e:	4e678793          	addi	a5,a5,1254 # 80020c80 <disk>
    800057a2:	97ba                	add	a5,a5,a4
    800057a4:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800057a8:	0001b997          	auipc	s3,0x1b
    800057ac:	4d898993          	addi	s3,s3,1240 # 80020c80 <disk>
    800057b0:	00491713          	slli	a4,s2,0x4
    800057b4:	0009b783          	ld	a5,0(s3)
    800057b8:	97ba                	add	a5,a5,a4
    800057ba:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800057be:	854a                	mv	a0,s2
    800057c0:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800057c4:	bafff0ef          	jal	80005372 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800057c8:	8885                	andi	s1,s1,1
    800057ca:	f0fd                	bnez	s1,800057b0 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800057cc:	0001b517          	auipc	a0,0x1b
    800057d0:	5dc50513          	addi	a0,a0,1500 # 80020da8 <disk+0x128>
    800057d4:	cb8fb0ef          	jal	80000c8c <release>
}
    800057d8:	70a6                	ld	ra,104(sp)
    800057da:	7406                	ld	s0,96(sp)
    800057dc:	64e6                	ld	s1,88(sp)
    800057de:	6946                	ld	s2,80(sp)
    800057e0:	69a6                	ld	s3,72(sp)
    800057e2:	6a06                	ld	s4,64(sp)
    800057e4:	7ae2                	ld	s5,56(sp)
    800057e6:	7b42                	ld	s6,48(sp)
    800057e8:	7ba2                	ld	s7,40(sp)
    800057ea:	7c02                	ld	s8,32(sp)
    800057ec:	6ce2                	ld	s9,24(sp)
    800057ee:	6165                	addi	sp,sp,112
    800057f0:	8082                	ret

00000000800057f2 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800057f2:	1101                	addi	sp,sp,-32
    800057f4:	ec06                	sd	ra,24(sp)
    800057f6:	e822                	sd	s0,16(sp)
    800057f8:	e426                	sd	s1,8(sp)
    800057fa:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800057fc:	0001b497          	auipc	s1,0x1b
    80005800:	48448493          	addi	s1,s1,1156 # 80020c80 <disk>
    80005804:	0001b517          	auipc	a0,0x1b
    80005808:	5a450513          	addi	a0,a0,1444 # 80020da8 <disk+0x128>
    8000580c:	be8fb0ef          	jal	80000bf4 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005810:	100017b7          	lui	a5,0x10001
    80005814:	53b8                	lw	a4,96(a5)
    80005816:	8b0d                	andi	a4,a4,3
    80005818:	100017b7          	lui	a5,0x10001
    8000581c:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    8000581e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005822:	689c                	ld	a5,16(s1)
    80005824:	0204d703          	lhu	a4,32(s1)
    80005828:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    8000582c:	04f70663          	beq	a4,a5,80005878 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80005830:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005834:	6898                	ld	a4,16(s1)
    80005836:	0204d783          	lhu	a5,32(s1)
    8000583a:	8b9d                	andi	a5,a5,7
    8000583c:	078e                	slli	a5,a5,0x3
    8000583e:	97ba                	add	a5,a5,a4
    80005840:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005842:	00278713          	addi	a4,a5,2
    80005846:	0712                	slli	a4,a4,0x4
    80005848:	9726                	add	a4,a4,s1
    8000584a:	01074703          	lbu	a4,16(a4)
    8000584e:	e321                	bnez	a4,8000588e <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005850:	0789                	addi	a5,a5,2
    80005852:	0792                	slli	a5,a5,0x4
    80005854:	97a6                	add	a5,a5,s1
    80005856:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005858:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000585c:	ec8fc0ef          	jal	80001f24 <wakeup>

    disk.used_idx += 1;
    80005860:	0204d783          	lhu	a5,32(s1)
    80005864:	2785                	addiw	a5,a5,1
    80005866:	17c2                	slli	a5,a5,0x30
    80005868:	93c1                	srli	a5,a5,0x30
    8000586a:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    8000586e:	6898                	ld	a4,16(s1)
    80005870:	00275703          	lhu	a4,2(a4)
    80005874:	faf71ee3          	bne	a4,a5,80005830 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005878:	0001b517          	auipc	a0,0x1b
    8000587c:	53050513          	addi	a0,a0,1328 # 80020da8 <disk+0x128>
    80005880:	c0cfb0ef          	jal	80000c8c <release>
}
    80005884:	60e2                	ld	ra,24(sp)
    80005886:	6442                	ld	s0,16(sp)
    80005888:	64a2                	ld	s1,8(sp)
    8000588a:	6105                	addi	sp,sp,32
    8000588c:	8082                	ret
      panic("virtio_disk_intr status");
    8000588e:	00002517          	auipc	a0,0x2
    80005892:	03a50513          	addi	a0,a0,58 # 800078c8 <etext+0x8c8>
    80005896:	efffa0ef          	jal	80000794 <panic>
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
