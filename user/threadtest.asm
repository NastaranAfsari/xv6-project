
user/_threadtest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <acquire_print_lock>:
#define STACK_SIZE 100

// Simple mutex using atomic operations
volatile int print_lock = 0;

void acquire_print_lock() {
   0:	1141                	addi	sp,sp,-16
   2:	e422                	sd	s0,8(sp)
   4:	0800                	addi	s0,sp,16
    while (__sync_lock_test_and_set(&print_lock, 1)) {
   6:	00001717          	auipc	a4,0x1
   a:	02a70713          	addi	a4,a4,42 # 1030 <print_lock>
   e:	4685                	li	a3,1
  10:	87b6                	mv	a5,a3
  12:	0cf727af          	amoswap.w.aq	a5,a5,(a4)
  16:	2781                	sext.w	a5,a5
  18:	ffe5                	bnez	a5,10 <acquire_print_lock+0x10>
        // Busy wait (spin)
    }
}
  1a:	6422                	ld	s0,8(sp)
  1c:	0141                	addi	sp,sp,16
  1e:	8082                	ret

0000000000000020 <release_print_lock>:

void release_print_lock() {
  20:	1141                	addi	sp,sp,-16
  22:	e422                	sd	s0,8(sp)
  24:	0800                	addi	s0,sp,16
    __sync_lock_release(&print_lock);
  26:	00001797          	auipc	a5,0x1
  2a:	00a78793          	addi	a5,a5,10 # 1030 <print_lock>
  2e:	0f50000f          	fence	iorw,ow
  32:	0807a02f          	amoswap.w	zero,zero,(a5)
}
  36:	6422                	ld	s0,8(sp)
  38:	0141                	addi	sp,sp,16
  3a:	8082                	ret

000000000000003c <my_thread>:
struct thread_data {
    int thread_id;
    uint64 start_number;
};

void *my_thread(void *arg) {
  3c:	7179                	addi	sp,sp,-48
  3e:	f406                	sd	ra,40(sp)
  40:	f022                	sd	s0,32(sp)
  42:	ec26                	sd	s1,24(sp)
  44:	e84a                	sd	s2,16(sp)
  46:	e44e                	sd	s3,8(sp)
  48:	1800                	addi	s0,sp,48
  4a:	84aa                	mv	s1,a0
  4c:	4929                	li	s2,10
    for (int i = 0; i < 10; ++i) {
        ((struct thread_data *) arg)->start_number++;
        
        // Acquire lock before printing
        acquire_print_lock();
        printf("thread %d: %lu\n", ((struct thread_data *) arg)->thread_id, ((struct thread_data *) arg)->start_number);
  4e:	00001997          	auipc	s3,0x1
  52:	97298993          	addi	s3,s3,-1678 # 9c0 <malloc+0xfa>
        ((struct thread_data *) arg)->start_number++;
  56:	649c                	ld	a5,8(s1)
  58:	0785                	addi	a5,a5,1
  5a:	e49c                	sd	a5,8(s1)
        acquire_print_lock();
  5c:	fa5ff0ef          	jal	0 <acquire_print_lock>
        printf("thread %d: %lu\n", ((struct thread_data *) arg)->thread_id, ((struct thread_data *) arg)->start_number);
  60:	6490                	ld	a2,8(s1)
  62:	408c                	lw	a1,0(s1)
  64:	854e                	mv	a0,s3
  66:	7ac000ef          	jal	812 <printf>
        release_print_lock();
  6a:	fb7ff0ef          	jal	20 <release_print_lock>
        // Release lock after printing
        
        // Try to yield by calling a system call that trigger scheduling
        yield();  // Sleep for 0 ticks - this should trigger thread scheduling
  6e:	424000ef          	jal	492 <yield>
    for (int i = 0; i < 10; ++i) {
  72:	397d                	addiw	s2,s2,-1
  74:	fe0911e3          	bnez	s2,56 <my_thread+0x1a>
    }
    return (void *) ((struct thread_data *) arg)->start_number;
}
  78:	6488                	ld	a0,8(s1)
  7a:	70a2                	ld	ra,40(sp)
  7c:	7402                	ld	s0,32(sp)
  7e:	64e2                	ld	s1,24(sp)
  80:	6942                	ld	s2,16(sp)
  82:	69a2                	ld	s3,8(sp)
  84:	6145                	addi	sp,sp,48
  86:	8082                	ret

0000000000000088 <main>:


int main(int argc, char *argv[]) {
  88:	b2010113          	addi	sp,sp,-1248
  8c:	4c113c23          	sd	ra,1240(sp)
  90:	4c813823          	sd	s0,1232(sp)
  94:	4c913423          	sd	s1,1224(sp)
  98:	4d213023          	sd	s2,1216(sp)
  9c:	4b313c23          	sd	s3,1208(sp)
  a0:	4e010413          	addi	s0,sp,1248
    // Create thread data structures (static to ensure they persist)
    static struct thread_data data1 = {1, 100};
    static struct thread_data data2 = {2, 200};
    static struct thread_data data3 = {3, 300};
    
    int ta = thread(my_thread, sp1 + STACK_SIZE, (void *) &data1);
  a4:	00001617          	auipc	a2,0x1
  a8:	f5c60613          	addi	a2,a2,-164 # 1000 <data1.2>
  ac:	fd040593          	addi	a1,s0,-48
  b0:	00000517          	auipc	a0,0x0
  b4:	f8c50513          	addi	a0,a0,-116 # 3c <my_thread>
  b8:	3ca000ef          	jal	482 <thread>
  bc:	89aa                	mv	s3,a0
    acquire_print_lock();
  be:	f43ff0ef          	jal	0 <acquire_print_lock>
    printf("NEW THREAD CREATED 1\n");
  c2:	00001517          	auipc	a0,0x1
  c6:	90e50513          	addi	a0,a0,-1778 # 9d0 <malloc+0x10a>
  ca:	748000ef          	jal	812 <printf>
    release_print_lock();
  ce:	f53ff0ef          	jal	20 <release_print_lock>
    
    int tb = thread(my_thread, sp2 + STACK_SIZE, (void *) &data2);
  d2:	00001617          	auipc	a2,0x1
  d6:	f3e60613          	addi	a2,a2,-194 # 1010 <data2.1>
  da:	e4040593          	addi	a1,s0,-448
  de:	00000517          	auipc	a0,0x0
  e2:	f5e50513          	addi	a0,a0,-162 # 3c <my_thread>
  e6:	39c000ef          	jal	482 <thread>
  ea:	892a                	mv	s2,a0
    acquire_print_lock();
  ec:	f15ff0ef          	jal	0 <acquire_print_lock>
    printf("NEW THREAD CREATED 2\n");
  f0:	00001517          	auipc	a0,0x1
  f4:	8f850513          	addi	a0,a0,-1800 # 9e8 <malloc+0x122>
  f8:	71a000ef          	jal	812 <printf>
    release_print_lock();
  fc:	f25ff0ef          	jal	20 <release_print_lock>
    
    int tc = thread(my_thread, sp3 + STACK_SIZE, (void *) &data3);
 100:	00001617          	auipc	a2,0x1
 104:	f2060613          	addi	a2,a2,-224 # 1020 <data3.0>
 108:	cb040593          	addi	a1,s0,-848
 10c:	00000517          	auipc	a0,0x0
 110:	f3050513          	addi	a0,a0,-208 # 3c <my_thread>
 114:	36e000ef          	jal	482 <thread>
 118:	84aa                	mv	s1,a0
    acquire_print_lock();
 11a:	ee7ff0ef          	jal	0 <acquire_print_lock>
    printf("NEW THREAD CREATED 3\n");
 11e:	00001517          	auipc	a0,0x1
 122:	8e250513          	addi	a0,a0,-1822 # a00 <malloc+0x13a>
 126:	6ec000ef          	jal	812 <printf>
    release_print_lock();
 12a:	ef7ff0ef          	jal	20 <release_print_lock>
    
    jointhread(ta);
 12e:	854e                	mv	a0,s3
 130:	35a000ef          	jal	48a <jointhread>
    jointhread(tb);
 134:	854a                	mv	a0,s2
 136:	354000ef          	jal	48a <jointhread>
    jointhread(tc);
 13a:	8526                	mv	a0,s1
 13c:	34e000ef          	jal	48a <jointhread>
    
    acquire_print_lock();
 140:	ec1ff0ef          	jal	0 <acquire_print_lock>
    printf("DONE\n");
 144:	00001517          	auipc	a0,0x1
 148:	8d450513          	addi	a0,a0,-1836 # a18 <malloc+0x152>
 14c:	6c6000ef          	jal	812 <printf>
    release_print_lock();
 150:	ed1ff0ef          	jal	20 <release_print_lock>
 154:	4501                	li	a0,0
 156:	4d813083          	ld	ra,1240(sp)
 15a:	4d013403          	ld	s0,1232(sp)
 15e:	4c813483          	ld	s1,1224(sp)
 162:	4c013903          	ld	s2,1216(sp)
 166:	4b813983          	ld	s3,1208(sp)
 16a:	4e010113          	addi	sp,sp,1248
 16e:	8082                	ret

0000000000000170 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
 170:	1141                	addi	sp,sp,-16
 172:	e406                	sd	ra,8(sp)
 174:	e022                	sd	s0,0(sp)
 176:	0800                	addi	s0,sp,16
  extern int main();
  main();
 178:	f11ff0ef          	jal	88 <main>
  exit(0);
 17c:	4501                	li	a0,0
 17e:	25c000ef          	jal	3da <exit>

0000000000000182 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 182:	1141                	addi	sp,sp,-16
 184:	e422                	sd	s0,8(sp)
 186:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 188:	87aa                	mv	a5,a0
 18a:	0585                	addi	a1,a1,1
 18c:	0785                	addi	a5,a5,1
 18e:	fff5c703          	lbu	a4,-1(a1)
 192:	fee78fa3          	sb	a4,-1(a5)
 196:	fb75                	bnez	a4,18a <strcpy+0x8>
    ;
  return os;
}
 198:	6422                	ld	s0,8(sp)
 19a:	0141                	addi	sp,sp,16
 19c:	8082                	ret

000000000000019e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 19e:	1141                	addi	sp,sp,-16
 1a0:	e422                	sd	s0,8(sp)
 1a2:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1a4:	00054783          	lbu	a5,0(a0)
 1a8:	cb91                	beqz	a5,1bc <strcmp+0x1e>
 1aa:	0005c703          	lbu	a4,0(a1)
 1ae:	00f71763          	bne	a4,a5,1bc <strcmp+0x1e>
    p++, q++;
 1b2:	0505                	addi	a0,a0,1
 1b4:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1b6:	00054783          	lbu	a5,0(a0)
 1ba:	fbe5                	bnez	a5,1aa <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1bc:	0005c503          	lbu	a0,0(a1)
}
 1c0:	40a7853b          	subw	a0,a5,a0
 1c4:	6422                	ld	s0,8(sp)
 1c6:	0141                	addi	sp,sp,16
 1c8:	8082                	ret

00000000000001ca <strlen>:

uint
strlen(const char *s)
{
 1ca:	1141                	addi	sp,sp,-16
 1cc:	e422                	sd	s0,8(sp)
 1ce:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1d0:	00054783          	lbu	a5,0(a0)
 1d4:	cf91                	beqz	a5,1f0 <strlen+0x26>
 1d6:	0505                	addi	a0,a0,1
 1d8:	87aa                	mv	a5,a0
 1da:	86be                	mv	a3,a5
 1dc:	0785                	addi	a5,a5,1
 1de:	fff7c703          	lbu	a4,-1(a5)
 1e2:	ff65                	bnez	a4,1da <strlen+0x10>
 1e4:	40a6853b          	subw	a0,a3,a0
 1e8:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 1ea:	6422                	ld	s0,8(sp)
 1ec:	0141                	addi	sp,sp,16
 1ee:	8082                	ret
  for(n = 0; s[n]; n++)
 1f0:	4501                	li	a0,0
 1f2:	bfe5                	j	1ea <strlen+0x20>

00000000000001f4 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1f4:	1141                	addi	sp,sp,-16
 1f6:	e422                	sd	s0,8(sp)
 1f8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1fa:	ca19                	beqz	a2,210 <memset+0x1c>
 1fc:	87aa                	mv	a5,a0
 1fe:	1602                	slli	a2,a2,0x20
 200:	9201                	srli	a2,a2,0x20
 202:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 206:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 20a:	0785                	addi	a5,a5,1
 20c:	fee79de3          	bne	a5,a4,206 <memset+0x12>
  }
  return dst;
}
 210:	6422                	ld	s0,8(sp)
 212:	0141                	addi	sp,sp,16
 214:	8082                	ret

0000000000000216 <strchr>:

char*
strchr(const char *s, char c)
{
 216:	1141                	addi	sp,sp,-16
 218:	e422                	sd	s0,8(sp)
 21a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 21c:	00054783          	lbu	a5,0(a0)
 220:	cb99                	beqz	a5,236 <strchr+0x20>
    if(*s == c)
 222:	00f58763          	beq	a1,a5,230 <strchr+0x1a>
  for(; *s; s++)
 226:	0505                	addi	a0,a0,1
 228:	00054783          	lbu	a5,0(a0)
 22c:	fbfd                	bnez	a5,222 <strchr+0xc>
      return (char*)s;
  return 0;
 22e:	4501                	li	a0,0
}
 230:	6422                	ld	s0,8(sp)
 232:	0141                	addi	sp,sp,16
 234:	8082                	ret
  return 0;
 236:	4501                	li	a0,0
 238:	bfe5                	j	230 <strchr+0x1a>

000000000000023a <gets>:

char*
gets(char *buf, int max)
{
 23a:	711d                	addi	sp,sp,-96
 23c:	ec86                	sd	ra,88(sp)
 23e:	e8a2                	sd	s0,80(sp)
 240:	e4a6                	sd	s1,72(sp)
 242:	e0ca                	sd	s2,64(sp)
 244:	fc4e                	sd	s3,56(sp)
 246:	f852                	sd	s4,48(sp)
 248:	f456                	sd	s5,40(sp)
 24a:	f05a                	sd	s6,32(sp)
 24c:	ec5e                	sd	s7,24(sp)
 24e:	1080                	addi	s0,sp,96
 250:	8baa                	mv	s7,a0
 252:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 254:	892a                	mv	s2,a0
 256:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 258:	4aa9                	li	s5,10
 25a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 25c:	89a6                	mv	s3,s1
 25e:	2485                	addiw	s1,s1,1
 260:	0344d663          	bge	s1,s4,28c <gets+0x52>
    cc = read(0, &c, 1);
 264:	4605                	li	a2,1
 266:	faf40593          	addi	a1,s0,-81
 26a:	4501                	li	a0,0
 26c:	186000ef          	jal	3f2 <read>
    if(cc < 1)
 270:	00a05e63          	blez	a0,28c <gets+0x52>
    buf[i++] = c;
 274:	faf44783          	lbu	a5,-81(s0)
 278:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 27c:	01578763          	beq	a5,s5,28a <gets+0x50>
 280:	0905                	addi	s2,s2,1
 282:	fd679de3          	bne	a5,s6,25c <gets+0x22>
    buf[i++] = c;
 286:	89a6                	mv	s3,s1
 288:	a011                	j	28c <gets+0x52>
 28a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 28c:	99de                	add	s3,s3,s7
 28e:	00098023          	sb	zero,0(s3)
  return buf;
}
 292:	855e                	mv	a0,s7
 294:	60e6                	ld	ra,88(sp)
 296:	6446                	ld	s0,80(sp)
 298:	64a6                	ld	s1,72(sp)
 29a:	6906                	ld	s2,64(sp)
 29c:	79e2                	ld	s3,56(sp)
 29e:	7a42                	ld	s4,48(sp)
 2a0:	7aa2                	ld	s5,40(sp)
 2a2:	7b02                	ld	s6,32(sp)
 2a4:	6be2                	ld	s7,24(sp)
 2a6:	6125                	addi	sp,sp,96
 2a8:	8082                	ret

00000000000002aa <stat>:

int
stat(const char *n, struct stat *st)
{
 2aa:	1101                	addi	sp,sp,-32
 2ac:	ec06                	sd	ra,24(sp)
 2ae:	e822                	sd	s0,16(sp)
 2b0:	e04a                	sd	s2,0(sp)
 2b2:	1000                	addi	s0,sp,32
 2b4:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2b6:	4581                	li	a1,0
 2b8:	162000ef          	jal	41a <open>
  if(fd < 0)
 2bc:	02054263          	bltz	a0,2e0 <stat+0x36>
 2c0:	e426                	sd	s1,8(sp)
 2c2:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2c4:	85ca                	mv	a1,s2
 2c6:	16c000ef          	jal	432 <fstat>
 2ca:	892a                	mv	s2,a0
  close(fd);
 2cc:	8526                	mv	a0,s1
 2ce:	134000ef          	jal	402 <close>
  return r;
 2d2:	64a2                	ld	s1,8(sp)
}
 2d4:	854a                	mv	a0,s2
 2d6:	60e2                	ld	ra,24(sp)
 2d8:	6442                	ld	s0,16(sp)
 2da:	6902                	ld	s2,0(sp)
 2dc:	6105                	addi	sp,sp,32
 2de:	8082                	ret
    return -1;
 2e0:	597d                	li	s2,-1
 2e2:	bfcd                	j	2d4 <stat+0x2a>

00000000000002e4 <atoi>:

int
atoi(const char *s)
{
 2e4:	1141                	addi	sp,sp,-16
 2e6:	e422                	sd	s0,8(sp)
 2e8:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2ea:	00054683          	lbu	a3,0(a0)
 2ee:	fd06879b          	addiw	a5,a3,-48
 2f2:	0ff7f793          	zext.b	a5,a5
 2f6:	4625                	li	a2,9
 2f8:	02f66863          	bltu	a2,a5,328 <atoi+0x44>
 2fc:	872a                	mv	a4,a0
  n = 0;
 2fe:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 300:	0705                	addi	a4,a4,1
 302:	0025179b          	slliw	a5,a0,0x2
 306:	9fa9                	addw	a5,a5,a0
 308:	0017979b          	slliw	a5,a5,0x1
 30c:	9fb5                	addw	a5,a5,a3
 30e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 312:	00074683          	lbu	a3,0(a4)
 316:	fd06879b          	addiw	a5,a3,-48
 31a:	0ff7f793          	zext.b	a5,a5
 31e:	fef671e3          	bgeu	a2,a5,300 <atoi+0x1c>
  return n;
}
 322:	6422                	ld	s0,8(sp)
 324:	0141                	addi	sp,sp,16
 326:	8082                	ret
  n = 0;
 328:	4501                	li	a0,0
 32a:	bfe5                	j	322 <atoi+0x3e>

000000000000032c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 32c:	1141                	addi	sp,sp,-16
 32e:	e422                	sd	s0,8(sp)
 330:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 332:	02b57463          	bgeu	a0,a1,35a <memmove+0x2e>
    while(n-- > 0)
 336:	00c05f63          	blez	a2,354 <memmove+0x28>
 33a:	1602                	slli	a2,a2,0x20
 33c:	9201                	srli	a2,a2,0x20
 33e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 342:	872a                	mv	a4,a0
      *dst++ = *src++;
 344:	0585                	addi	a1,a1,1
 346:	0705                	addi	a4,a4,1
 348:	fff5c683          	lbu	a3,-1(a1)
 34c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 350:	fef71ae3          	bne	a4,a5,344 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 354:	6422                	ld	s0,8(sp)
 356:	0141                	addi	sp,sp,16
 358:	8082                	ret
    dst += n;
 35a:	00c50733          	add	a4,a0,a2
    src += n;
 35e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 360:	fec05ae3          	blez	a2,354 <memmove+0x28>
 364:	fff6079b          	addiw	a5,a2,-1
 368:	1782                	slli	a5,a5,0x20
 36a:	9381                	srli	a5,a5,0x20
 36c:	fff7c793          	not	a5,a5
 370:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 372:	15fd                	addi	a1,a1,-1
 374:	177d                	addi	a4,a4,-1
 376:	0005c683          	lbu	a3,0(a1)
 37a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 37e:	fee79ae3          	bne	a5,a4,372 <memmove+0x46>
 382:	bfc9                	j	354 <memmove+0x28>

0000000000000384 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 384:	1141                	addi	sp,sp,-16
 386:	e422                	sd	s0,8(sp)
 388:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 38a:	ca05                	beqz	a2,3ba <memcmp+0x36>
 38c:	fff6069b          	addiw	a3,a2,-1
 390:	1682                	slli	a3,a3,0x20
 392:	9281                	srli	a3,a3,0x20
 394:	0685                	addi	a3,a3,1
 396:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 398:	00054783          	lbu	a5,0(a0)
 39c:	0005c703          	lbu	a4,0(a1)
 3a0:	00e79863          	bne	a5,a4,3b0 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3a4:	0505                	addi	a0,a0,1
    p2++;
 3a6:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3a8:	fed518e3          	bne	a0,a3,398 <memcmp+0x14>
  }
  return 0;
 3ac:	4501                	li	a0,0
 3ae:	a019                	j	3b4 <memcmp+0x30>
      return *p1 - *p2;
 3b0:	40e7853b          	subw	a0,a5,a4
}
 3b4:	6422                	ld	s0,8(sp)
 3b6:	0141                	addi	sp,sp,16
 3b8:	8082                	ret
  return 0;
 3ba:	4501                	li	a0,0
 3bc:	bfe5                	j	3b4 <memcmp+0x30>

00000000000003be <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3be:	1141                	addi	sp,sp,-16
 3c0:	e406                	sd	ra,8(sp)
 3c2:	e022                	sd	s0,0(sp)
 3c4:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3c6:	f67ff0ef          	jal	32c <memmove>
}
 3ca:	60a2                	ld	ra,8(sp)
 3cc:	6402                	ld	s0,0(sp)
 3ce:	0141                	addi	sp,sp,16
 3d0:	8082                	ret

00000000000003d2 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3d2:	4885                	li	a7,1
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <exit>:
.global exit
exit:
 li a7, SYS_exit
 3da:	4889                	li	a7,2
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3e2:	488d                	li	a7,3
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3ea:	4891                	li	a7,4
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <read>:
.global read
read:
 li a7, SYS_read
 3f2:	4895                	li	a7,5
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <write>:
.global write
write:
 li a7, SYS_write
 3fa:	48c1                	li	a7,16
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <close>:
.global close
close:
 li a7, SYS_close
 402:	48d5                	li	a7,21
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <kill>:
.global kill
kill:
 li a7, SYS_kill
 40a:	4899                	li	a7,6
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <exec>:
.global exec
exec:
 li a7, SYS_exec
 412:	489d                	li	a7,7
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <open>:
.global open
open:
 li a7, SYS_open
 41a:	48bd                	li	a7,15
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 422:	48c5                	li	a7,17
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 42a:	48c9                	li	a7,18
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 432:	48a1                	li	a7,8
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <link>:
.global link
link:
 li a7, SYS_link
 43a:	48cd                	li	a7,19
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 442:	48d1                	li	a7,20
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 44a:	48a5                	li	a7,9
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <dup>:
.global dup
dup:
 li a7, SYS_dup
 452:	48a9                	li	a7,10
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 45a:	48ad                	li	a7,11
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 462:	48b1                	li	a7,12
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 46a:	48b5                	li	a7,13
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 472:	48b9                	li	a7,14
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <trigger>:
.global trigger
trigger:
 li a7, SYS_trigger
 47a:	48d9                	li	a7,22
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <thread>:
.global thread
thread:
 li a7, SYS_thread
 482:	48dd                	li	a7,23
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <jointhread>:
.global jointhread
jointhread:
 li a7, SYS_jointhread
 48a:	48e1                	li	a7,24
 ecall
 48c:	00000073          	ecall
 ret
 490:	8082                	ret

0000000000000492 <yield>:
.global yield
yield:
 li a7, SYS_yield
 492:	48e5                	li	a7,25
 ecall
 494:	00000073          	ecall
 ret
 498:	8082                	ret

000000000000049a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 49a:	1101                	addi	sp,sp,-32
 49c:	ec06                	sd	ra,24(sp)
 49e:	e822                	sd	s0,16(sp)
 4a0:	1000                	addi	s0,sp,32
 4a2:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4a6:	4605                	li	a2,1
 4a8:	fef40593          	addi	a1,s0,-17
 4ac:	f4fff0ef          	jal	3fa <write>
}
 4b0:	60e2                	ld	ra,24(sp)
 4b2:	6442                	ld	s0,16(sp)
 4b4:	6105                	addi	sp,sp,32
 4b6:	8082                	ret

00000000000004b8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4b8:	7139                	addi	sp,sp,-64
 4ba:	fc06                	sd	ra,56(sp)
 4bc:	f822                	sd	s0,48(sp)
 4be:	f426                	sd	s1,40(sp)
 4c0:	0080                	addi	s0,sp,64
 4c2:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4c4:	c299                	beqz	a3,4ca <printint+0x12>
 4c6:	0805c963          	bltz	a1,558 <printint+0xa0>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4ca:	2581                	sext.w	a1,a1
  neg = 0;
 4cc:	4881                	li	a7,0
 4ce:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4d2:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4d4:	2601                	sext.w	a2,a2
 4d6:	00000517          	auipc	a0,0x0
 4da:	55250513          	addi	a0,a0,1362 # a28 <digits>
 4de:	883a                	mv	a6,a4
 4e0:	2705                	addiw	a4,a4,1
 4e2:	02c5f7bb          	remuw	a5,a1,a2
 4e6:	1782                	slli	a5,a5,0x20
 4e8:	9381                	srli	a5,a5,0x20
 4ea:	97aa                	add	a5,a5,a0
 4ec:	0007c783          	lbu	a5,0(a5)
 4f0:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4f4:	0005879b          	sext.w	a5,a1
 4f8:	02c5d5bb          	divuw	a1,a1,a2
 4fc:	0685                	addi	a3,a3,1
 4fe:	fec7f0e3          	bgeu	a5,a2,4de <printint+0x26>
  if(neg)
 502:	00088c63          	beqz	a7,51a <printint+0x62>
    buf[i++] = '-';
 506:	fd070793          	addi	a5,a4,-48
 50a:	00878733          	add	a4,a5,s0
 50e:	02d00793          	li	a5,45
 512:	fef70823          	sb	a5,-16(a4)
 516:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 51a:	02e05a63          	blez	a4,54e <printint+0x96>
 51e:	f04a                	sd	s2,32(sp)
 520:	ec4e                	sd	s3,24(sp)
 522:	fc040793          	addi	a5,s0,-64
 526:	00e78933          	add	s2,a5,a4
 52a:	fff78993          	addi	s3,a5,-1
 52e:	99ba                	add	s3,s3,a4
 530:	377d                	addiw	a4,a4,-1
 532:	1702                	slli	a4,a4,0x20
 534:	9301                	srli	a4,a4,0x20
 536:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 53a:	fff94583          	lbu	a1,-1(s2)
 53e:	8526                	mv	a0,s1
 540:	f5bff0ef          	jal	49a <putc>
  while(--i >= 0)
 544:	197d                	addi	s2,s2,-1
 546:	ff391ae3          	bne	s2,s3,53a <printint+0x82>
 54a:	7902                	ld	s2,32(sp)
 54c:	69e2                	ld	s3,24(sp)
}
 54e:	70e2                	ld	ra,56(sp)
 550:	7442                	ld	s0,48(sp)
 552:	74a2                	ld	s1,40(sp)
 554:	6121                	addi	sp,sp,64
 556:	8082                	ret
    x = -xx;
 558:	40b005bb          	negw	a1,a1
    neg = 1;
 55c:	4885                	li	a7,1
    x = -xx;
 55e:	bf85                	j	4ce <printint+0x16>

0000000000000560 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 560:	711d                	addi	sp,sp,-96
 562:	ec86                	sd	ra,88(sp)
 564:	e8a2                	sd	s0,80(sp)
 566:	e0ca                	sd	s2,64(sp)
 568:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 56a:	0005c903          	lbu	s2,0(a1)
 56e:	26090863          	beqz	s2,7de <vprintf+0x27e>
 572:	e4a6                	sd	s1,72(sp)
 574:	fc4e                	sd	s3,56(sp)
 576:	f852                	sd	s4,48(sp)
 578:	f456                	sd	s5,40(sp)
 57a:	f05a                	sd	s6,32(sp)
 57c:	ec5e                	sd	s7,24(sp)
 57e:	e862                	sd	s8,16(sp)
 580:	e466                	sd	s9,8(sp)
 582:	8b2a                	mv	s6,a0
 584:	8a2e                	mv	s4,a1
 586:	8bb2                	mv	s7,a2
  state = 0;
 588:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 58a:	4481                	li	s1,0
 58c:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 58e:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 592:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 596:	06c00c93          	li	s9,108
 59a:	a005                	j	5ba <vprintf+0x5a>
        putc(fd, c0);
 59c:	85ca                	mv	a1,s2
 59e:	855a                	mv	a0,s6
 5a0:	efbff0ef          	jal	49a <putc>
 5a4:	a019                	j	5aa <vprintf+0x4a>
    } else if(state == '%'){
 5a6:	03598263          	beq	s3,s5,5ca <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 5aa:	2485                	addiw	s1,s1,1
 5ac:	8726                	mv	a4,s1
 5ae:	009a07b3          	add	a5,s4,s1
 5b2:	0007c903          	lbu	s2,0(a5)
 5b6:	20090c63          	beqz	s2,7ce <vprintf+0x26e>
    c0 = fmt[i] & 0xff;
 5ba:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5be:	fe0994e3          	bnez	s3,5a6 <vprintf+0x46>
      if(c0 == '%'){
 5c2:	fd579de3          	bne	a5,s5,59c <vprintf+0x3c>
        state = '%';
 5c6:	89be                	mv	s3,a5
 5c8:	b7cd                	j	5aa <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 5ca:	00ea06b3          	add	a3,s4,a4
 5ce:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 5d2:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 5d4:	c681                	beqz	a3,5dc <vprintf+0x7c>
 5d6:	9752                	add	a4,a4,s4
 5d8:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 5dc:	03878f63          	beq	a5,s8,61a <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
 5e0:	05978963          	beq	a5,s9,632 <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 5e4:	07500713          	li	a4,117
 5e8:	0ee78363          	beq	a5,a4,6ce <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 5ec:	07800713          	li	a4,120
 5f0:	12e78563          	beq	a5,a4,71a <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 5f4:	07000713          	li	a4,112
 5f8:	14e78a63          	beq	a5,a4,74c <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 5fc:	07300713          	li	a4,115
 600:	18e78a63          	beq	a5,a4,794 <vprintf+0x234>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 604:	02500713          	li	a4,37
 608:	04e79563          	bne	a5,a4,652 <vprintf+0xf2>
        putc(fd, '%');
 60c:	02500593          	li	a1,37
 610:	855a                	mv	a0,s6
 612:	e89ff0ef          	jal	49a <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 616:	4981                	li	s3,0
 618:	bf49                	j	5aa <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 61a:	008b8913          	addi	s2,s7,8
 61e:	4685                	li	a3,1
 620:	4629                	li	a2,10
 622:	000ba583          	lw	a1,0(s7)
 626:	855a                	mv	a0,s6
 628:	e91ff0ef          	jal	4b8 <printint>
 62c:	8bca                	mv	s7,s2
      state = 0;
 62e:	4981                	li	s3,0
 630:	bfad                	j	5aa <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 632:	06400793          	li	a5,100
 636:	02f68963          	beq	a3,a5,668 <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 63a:	06c00793          	li	a5,108
 63e:	04f68263          	beq	a3,a5,682 <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
 642:	07500793          	li	a5,117
 646:	0af68063          	beq	a3,a5,6e6 <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
 64a:	07800793          	li	a5,120
 64e:	0ef68263          	beq	a3,a5,732 <vprintf+0x1d2>
        putc(fd, '%');
 652:	02500593          	li	a1,37
 656:	855a                	mv	a0,s6
 658:	e43ff0ef          	jal	49a <putc>
        putc(fd, c0);
 65c:	85ca                	mv	a1,s2
 65e:	855a                	mv	a0,s6
 660:	e3bff0ef          	jal	49a <putc>
      state = 0;
 664:	4981                	li	s3,0
 666:	b791                	j	5aa <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 668:	008b8913          	addi	s2,s7,8
 66c:	4685                	li	a3,1
 66e:	4629                	li	a2,10
 670:	000ba583          	lw	a1,0(s7)
 674:	855a                	mv	a0,s6
 676:	e43ff0ef          	jal	4b8 <printint>
        i += 1;
 67a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 67c:	8bca                	mv	s7,s2
      state = 0;
 67e:	4981                	li	s3,0
        i += 1;
 680:	b72d                	j	5aa <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 682:	06400793          	li	a5,100
 686:	02f60763          	beq	a2,a5,6b4 <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 68a:	07500793          	li	a5,117
 68e:	06f60963          	beq	a2,a5,700 <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 692:	07800793          	li	a5,120
 696:	faf61ee3          	bne	a2,a5,652 <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 69a:	008b8913          	addi	s2,s7,8
 69e:	4681                	li	a3,0
 6a0:	4641                	li	a2,16
 6a2:	000ba583          	lw	a1,0(s7)
 6a6:	855a                	mv	a0,s6
 6a8:	e11ff0ef          	jal	4b8 <printint>
        i += 2;
 6ac:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6ae:	8bca                	mv	s7,s2
      state = 0;
 6b0:	4981                	li	s3,0
        i += 2;
 6b2:	bde5                	j	5aa <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6b4:	008b8913          	addi	s2,s7,8
 6b8:	4685                	li	a3,1
 6ba:	4629                	li	a2,10
 6bc:	000ba583          	lw	a1,0(s7)
 6c0:	855a                	mv	a0,s6
 6c2:	df7ff0ef          	jal	4b8 <printint>
        i += 2;
 6c6:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6c8:	8bca                	mv	s7,s2
      state = 0;
 6ca:	4981                	li	s3,0
        i += 2;
 6cc:	bdf9                	j	5aa <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
 6ce:	008b8913          	addi	s2,s7,8
 6d2:	4681                	li	a3,0
 6d4:	4629                	li	a2,10
 6d6:	000ba583          	lw	a1,0(s7)
 6da:	855a                	mv	a0,s6
 6dc:	dddff0ef          	jal	4b8 <printint>
 6e0:	8bca                	mv	s7,s2
      state = 0;
 6e2:	4981                	li	s3,0
 6e4:	b5d9                	j	5aa <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6e6:	008b8913          	addi	s2,s7,8
 6ea:	4681                	li	a3,0
 6ec:	4629                	li	a2,10
 6ee:	000ba583          	lw	a1,0(s7)
 6f2:	855a                	mv	a0,s6
 6f4:	dc5ff0ef          	jal	4b8 <printint>
        i += 1;
 6f8:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6fa:	8bca                	mv	s7,s2
      state = 0;
 6fc:	4981                	li	s3,0
        i += 1;
 6fe:	b575                	j	5aa <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 700:	008b8913          	addi	s2,s7,8
 704:	4681                	li	a3,0
 706:	4629                	li	a2,10
 708:	000ba583          	lw	a1,0(s7)
 70c:	855a                	mv	a0,s6
 70e:	dabff0ef          	jal	4b8 <printint>
        i += 2;
 712:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 714:	8bca                	mv	s7,s2
      state = 0;
 716:	4981                	li	s3,0
        i += 2;
 718:	bd49                	j	5aa <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
 71a:	008b8913          	addi	s2,s7,8
 71e:	4681                	li	a3,0
 720:	4641                	li	a2,16
 722:	000ba583          	lw	a1,0(s7)
 726:	855a                	mv	a0,s6
 728:	d91ff0ef          	jal	4b8 <printint>
 72c:	8bca                	mv	s7,s2
      state = 0;
 72e:	4981                	li	s3,0
 730:	bdad                	j	5aa <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 732:	008b8913          	addi	s2,s7,8
 736:	4681                	li	a3,0
 738:	4641                	li	a2,16
 73a:	000ba583          	lw	a1,0(s7)
 73e:	855a                	mv	a0,s6
 740:	d79ff0ef          	jal	4b8 <printint>
        i += 1;
 744:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 746:	8bca                	mv	s7,s2
      state = 0;
 748:	4981                	li	s3,0
        i += 1;
 74a:	b585                	j	5aa <vprintf+0x4a>
 74c:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 74e:	008b8d13          	addi	s10,s7,8
 752:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 756:	03000593          	li	a1,48
 75a:	855a                	mv	a0,s6
 75c:	d3fff0ef          	jal	49a <putc>
  putc(fd, 'x');
 760:	07800593          	li	a1,120
 764:	855a                	mv	a0,s6
 766:	d35ff0ef          	jal	49a <putc>
 76a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 76c:	00000b97          	auipc	s7,0x0
 770:	2bcb8b93          	addi	s7,s7,700 # a28 <digits>
 774:	03c9d793          	srli	a5,s3,0x3c
 778:	97de                	add	a5,a5,s7
 77a:	0007c583          	lbu	a1,0(a5)
 77e:	855a                	mv	a0,s6
 780:	d1bff0ef          	jal	49a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 784:	0992                	slli	s3,s3,0x4
 786:	397d                	addiw	s2,s2,-1
 788:	fe0916e3          	bnez	s2,774 <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
 78c:	8bea                	mv	s7,s10
      state = 0;
 78e:	4981                	li	s3,0
 790:	6d02                	ld	s10,0(sp)
 792:	bd21                	j	5aa <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 794:	008b8993          	addi	s3,s7,8
 798:	000bb903          	ld	s2,0(s7)
 79c:	00090f63          	beqz	s2,7ba <vprintf+0x25a>
        for(; *s; s++)
 7a0:	00094583          	lbu	a1,0(s2)
 7a4:	c195                	beqz	a1,7c8 <vprintf+0x268>
          putc(fd, *s);
 7a6:	855a                	mv	a0,s6
 7a8:	cf3ff0ef          	jal	49a <putc>
        for(; *s; s++)
 7ac:	0905                	addi	s2,s2,1
 7ae:	00094583          	lbu	a1,0(s2)
 7b2:	f9f5                	bnez	a1,7a6 <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 7b4:	8bce                	mv	s7,s3
      state = 0;
 7b6:	4981                	li	s3,0
 7b8:	bbcd                	j	5aa <vprintf+0x4a>
          s = "(null)";
 7ba:	00000917          	auipc	s2,0x0
 7be:	26690913          	addi	s2,s2,614 # a20 <malloc+0x15a>
        for(; *s; s++)
 7c2:	02800593          	li	a1,40
 7c6:	b7c5                	j	7a6 <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 7c8:	8bce                	mv	s7,s3
      state = 0;
 7ca:	4981                	li	s3,0
 7cc:	bbf9                	j	5aa <vprintf+0x4a>
 7ce:	64a6                	ld	s1,72(sp)
 7d0:	79e2                	ld	s3,56(sp)
 7d2:	7a42                	ld	s4,48(sp)
 7d4:	7aa2                	ld	s5,40(sp)
 7d6:	7b02                	ld	s6,32(sp)
 7d8:	6be2                	ld	s7,24(sp)
 7da:	6c42                	ld	s8,16(sp)
 7dc:	6ca2                	ld	s9,8(sp)
    }
  }
}
 7de:	60e6                	ld	ra,88(sp)
 7e0:	6446                	ld	s0,80(sp)
 7e2:	6906                	ld	s2,64(sp)
 7e4:	6125                	addi	sp,sp,96
 7e6:	8082                	ret

00000000000007e8 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7e8:	715d                	addi	sp,sp,-80
 7ea:	ec06                	sd	ra,24(sp)
 7ec:	e822                	sd	s0,16(sp)
 7ee:	1000                	addi	s0,sp,32
 7f0:	e010                	sd	a2,0(s0)
 7f2:	e414                	sd	a3,8(s0)
 7f4:	e818                	sd	a4,16(s0)
 7f6:	ec1c                	sd	a5,24(s0)
 7f8:	03043023          	sd	a6,32(s0)
 7fc:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 800:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 804:	8622                	mv	a2,s0
 806:	d5bff0ef          	jal	560 <vprintf>
}
 80a:	60e2                	ld	ra,24(sp)
 80c:	6442                	ld	s0,16(sp)
 80e:	6161                	addi	sp,sp,80
 810:	8082                	ret

0000000000000812 <printf>:

void
printf(const char *fmt, ...)
{
 812:	711d                	addi	sp,sp,-96
 814:	ec06                	sd	ra,24(sp)
 816:	e822                	sd	s0,16(sp)
 818:	1000                	addi	s0,sp,32
 81a:	e40c                	sd	a1,8(s0)
 81c:	e810                	sd	a2,16(s0)
 81e:	ec14                	sd	a3,24(s0)
 820:	f018                	sd	a4,32(s0)
 822:	f41c                	sd	a5,40(s0)
 824:	03043823          	sd	a6,48(s0)
 828:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 82c:	00840613          	addi	a2,s0,8
 830:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 834:	85aa                	mv	a1,a0
 836:	4505                	li	a0,1
 838:	d29ff0ef          	jal	560 <vprintf>
}
 83c:	60e2                	ld	ra,24(sp)
 83e:	6442                	ld	s0,16(sp)
 840:	6125                	addi	sp,sp,96
 842:	8082                	ret

0000000000000844 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 844:	1141                	addi	sp,sp,-16
 846:	e422                	sd	s0,8(sp)
 848:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 84a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 84e:	00000797          	auipc	a5,0x0
 852:	7ea7b783          	ld	a5,2026(a5) # 1038 <freep>
 856:	a02d                	j	880 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 858:	4618                	lw	a4,8(a2)
 85a:	9f2d                	addw	a4,a4,a1
 85c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 860:	6398                	ld	a4,0(a5)
 862:	6310                	ld	a2,0(a4)
 864:	a83d                	j	8a2 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 866:	ff852703          	lw	a4,-8(a0)
 86a:	9f31                	addw	a4,a4,a2
 86c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 86e:	ff053683          	ld	a3,-16(a0)
 872:	a091                	j	8b6 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 874:	6398                	ld	a4,0(a5)
 876:	00e7e463          	bltu	a5,a4,87e <free+0x3a>
 87a:	00e6ea63          	bltu	a3,a4,88e <free+0x4a>
{
 87e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 880:	fed7fae3          	bgeu	a5,a3,874 <free+0x30>
 884:	6398                	ld	a4,0(a5)
 886:	00e6e463          	bltu	a3,a4,88e <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 88a:	fee7eae3          	bltu	a5,a4,87e <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 88e:	ff852583          	lw	a1,-8(a0)
 892:	6390                	ld	a2,0(a5)
 894:	02059813          	slli	a6,a1,0x20
 898:	01c85713          	srli	a4,a6,0x1c
 89c:	9736                	add	a4,a4,a3
 89e:	fae60de3          	beq	a2,a4,858 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 8a2:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8a6:	4790                	lw	a2,8(a5)
 8a8:	02061593          	slli	a1,a2,0x20
 8ac:	01c5d713          	srli	a4,a1,0x1c
 8b0:	973e                	add	a4,a4,a5
 8b2:	fae68ae3          	beq	a3,a4,866 <free+0x22>
    p->s.ptr = bp->s.ptr;
 8b6:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8b8:	00000717          	auipc	a4,0x0
 8bc:	78f73023          	sd	a5,1920(a4) # 1038 <freep>
}
 8c0:	6422                	ld	s0,8(sp)
 8c2:	0141                	addi	sp,sp,16
 8c4:	8082                	ret

00000000000008c6 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8c6:	7139                	addi	sp,sp,-64
 8c8:	fc06                	sd	ra,56(sp)
 8ca:	f822                	sd	s0,48(sp)
 8cc:	f426                	sd	s1,40(sp)
 8ce:	ec4e                	sd	s3,24(sp)
 8d0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8d2:	02051493          	slli	s1,a0,0x20
 8d6:	9081                	srli	s1,s1,0x20
 8d8:	04bd                	addi	s1,s1,15
 8da:	8091                	srli	s1,s1,0x4
 8dc:	0014899b          	addiw	s3,s1,1
 8e0:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8e2:	00000517          	auipc	a0,0x0
 8e6:	75653503          	ld	a0,1878(a0) # 1038 <freep>
 8ea:	c915                	beqz	a0,91e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ec:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8ee:	4798                	lw	a4,8(a5)
 8f0:	08977a63          	bgeu	a4,s1,984 <malloc+0xbe>
 8f4:	f04a                	sd	s2,32(sp)
 8f6:	e852                	sd	s4,16(sp)
 8f8:	e456                	sd	s5,8(sp)
 8fa:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8fc:	8a4e                	mv	s4,s3
 8fe:	0009871b          	sext.w	a4,s3
 902:	6685                	lui	a3,0x1
 904:	00d77363          	bgeu	a4,a3,90a <malloc+0x44>
 908:	6a05                	lui	s4,0x1
 90a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 90e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 912:	00000917          	auipc	s2,0x0
 916:	72690913          	addi	s2,s2,1830 # 1038 <freep>
  if(p == (char*)-1)
 91a:	5afd                	li	s5,-1
 91c:	a081                	j	95c <malloc+0x96>
 91e:	f04a                	sd	s2,32(sp)
 920:	e852                	sd	s4,16(sp)
 922:	e456                	sd	s5,8(sp)
 924:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 926:	00000797          	auipc	a5,0x0
 92a:	71a78793          	addi	a5,a5,1818 # 1040 <base>
 92e:	00000717          	auipc	a4,0x0
 932:	70f73523          	sd	a5,1802(a4) # 1038 <freep>
 936:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 938:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 93c:	b7c1                	j	8fc <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 93e:	6398                	ld	a4,0(a5)
 940:	e118                	sd	a4,0(a0)
 942:	a8a9                	j	99c <malloc+0xd6>
  hp->s.size = nu;
 944:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 948:	0541                	addi	a0,a0,16
 94a:	efbff0ef          	jal	844 <free>
  return freep;
 94e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 952:	c12d                	beqz	a0,9b4 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 954:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 956:	4798                	lw	a4,8(a5)
 958:	02977263          	bgeu	a4,s1,97c <malloc+0xb6>
    if(p == freep)
 95c:	00093703          	ld	a4,0(s2)
 960:	853e                	mv	a0,a5
 962:	fef719e3          	bne	a4,a5,954 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 966:	8552                	mv	a0,s4
 968:	afbff0ef          	jal	462 <sbrk>
  if(p == (char*)-1)
 96c:	fd551ce3          	bne	a0,s5,944 <malloc+0x7e>
        return 0;
 970:	4501                	li	a0,0
 972:	7902                	ld	s2,32(sp)
 974:	6a42                	ld	s4,16(sp)
 976:	6aa2                	ld	s5,8(sp)
 978:	6b02                	ld	s6,0(sp)
 97a:	a03d                	j	9a8 <malloc+0xe2>
 97c:	7902                	ld	s2,32(sp)
 97e:	6a42                	ld	s4,16(sp)
 980:	6aa2                	ld	s5,8(sp)
 982:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 984:	fae48de3          	beq	s1,a4,93e <malloc+0x78>
        p->s.size -= nunits;
 988:	4137073b          	subw	a4,a4,s3
 98c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 98e:	02071693          	slli	a3,a4,0x20
 992:	01c6d713          	srli	a4,a3,0x1c
 996:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 998:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 99c:	00000717          	auipc	a4,0x0
 9a0:	68a73e23          	sd	a0,1692(a4) # 1038 <freep>
      return (void*)(p + 1);
 9a4:	01078513          	addi	a0,a5,16
  }
}
 9a8:	70e2                	ld	ra,56(sp)
 9aa:	7442                	ld	s0,48(sp)
 9ac:	74a2                	ld	s1,40(sp)
 9ae:	69e2                	ld	s3,24(sp)
 9b0:	6121                	addi	sp,sp,64
 9b2:	8082                	ret
 9b4:	7902                	ld	s2,32(sp)
 9b6:	6a42                	ld	s4,16(sp)
 9b8:	6aa2                	ld	s5,8(sp)
 9ba:	6b02                	ld	s6,0(sp)
 9bc:	b7f5                	j	9a8 <malloc+0xe2>
