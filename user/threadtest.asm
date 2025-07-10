
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
  52:	97298993          	addi	s3,s3,-1678 # 9c0 <malloc+0x100>
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
  66:	7a6000ef          	jal	80c <printf>
        release_print_lock();
  6a:	fb7ff0ef          	jal	20 <release_print_lock>
        // Release lock after printing
        
        // Try to yield by calling a system call that trigger scheduling
        sleep(0);  // Sleep for 0 ticks - this should trigger thread scheduling
  6e:	4501                	li	a0,0
  70:	3fc000ef          	jal	46c <sleep>
    for (int i = 0; i < 10; ++i) {
  74:	397d                	addiw	s2,s2,-1
  76:	fe0910e3          	bnez	s2,56 <my_thread+0x1a>
    }
    return (void *) ((struct thread_data *) arg)->start_number;
}
  7a:	6488                	ld	a0,8(s1)
  7c:	70a2                	ld	ra,40(sp)
  7e:	7402                	ld	s0,32(sp)
  80:	64e2                	ld	s1,24(sp)
  82:	6942                	ld	s2,16(sp)
  84:	69a2                	ld	s3,8(sp)
  86:	6145                	addi	sp,sp,48
  88:	8082                	ret

000000000000008a <main>:


int main(int argc, char *argv[]) {
  8a:	b2010113          	addi	sp,sp,-1248
  8e:	4c113c23          	sd	ra,1240(sp)
  92:	4c813823          	sd	s0,1232(sp)
  96:	4c913423          	sd	s1,1224(sp)
  9a:	4d213023          	sd	s2,1216(sp)
  9e:	4b313c23          	sd	s3,1208(sp)
  a2:	4e010413          	addi	s0,sp,1248
    // Create thread data structures (static to ensure they persist)
    static struct thread_data data1 = {1, 100};
    static struct thread_data data2 = {2, 200};
    static struct thread_data data3 = {3, 300};
    
    int ta = thread(my_thread, sp1 + STACK_SIZE, (void *) &data1);
  a6:	00001617          	auipc	a2,0x1
  aa:	f5a60613          	addi	a2,a2,-166 # 1000 <data1.2>
  ae:	fd040593          	addi	a1,s0,-48
  b2:	00000517          	auipc	a0,0x0
  b6:	f8a50513          	addi	a0,a0,-118 # 3c <my_thread>
  ba:	3ca000ef          	jal	484 <thread>
  be:	89aa                	mv	s3,a0
    acquire_print_lock();
  c0:	f41ff0ef          	jal	0 <acquire_print_lock>
    printf("NEW THREAD CREATED 1\n");
  c4:	00001517          	auipc	a0,0x1
  c8:	90c50513          	addi	a0,a0,-1780 # 9d0 <malloc+0x110>
  cc:	740000ef          	jal	80c <printf>
    release_print_lock();
  d0:	f51ff0ef          	jal	20 <release_print_lock>
    
    int tb = thread(my_thread, sp2 + STACK_SIZE, (void *) &data2);
  d4:	00001617          	auipc	a2,0x1
  d8:	f3c60613          	addi	a2,a2,-196 # 1010 <data2.1>
  dc:	e4040593          	addi	a1,s0,-448
  e0:	00000517          	auipc	a0,0x0
  e4:	f5c50513          	addi	a0,a0,-164 # 3c <my_thread>
  e8:	39c000ef          	jal	484 <thread>
  ec:	892a                	mv	s2,a0
    acquire_print_lock();
  ee:	f13ff0ef          	jal	0 <acquire_print_lock>
    printf("NEW THREAD CREATED 2\n");
  f2:	00001517          	auipc	a0,0x1
  f6:	8f650513          	addi	a0,a0,-1802 # 9e8 <malloc+0x128>
  fa:	712000ef          	jal	80c <printf>
    release_print_lock();
  fe:	f23ff0ef          	jal	20 <release_print_lock>
    
    int tc = thread(my_thread, sp3 + STACK_SIZE, (void *) &data3);
 102:	00001617          	auipc	a2,0x1
 106:	f1e60613          	addi	a2,a2,-226 # 1020 <data3.0>
 10a:	cb040593          	addi	a1,s0,-848
 10e:	00000517          	auipc	a0,0x0
 112:	f2e50513          	addi	a0,a0,-210 # 3c <my_thread>
 116:	36e000ef          	jal	484 <thread>
 11a:	84aa                	mv	s1,a0
    acquire_print_lock();
 11c:	ee5ff0ef          	jal	0 <acquire_print_lock>
    printf("NEW THREAD CREATED 3\n");
 120:	00001517          	auipc	a0,0x1
 124:	8e050513          	addi	a0,a0,-1824 # a00 <malloc+0x140>
 128:	6e4000ef          	jal	80c <printf>
    release_print_lock();
 12c:	ef5ff0ef          	jal	20 <release_print_lock>
    
    jointhread(ta);
 130:	854e                	mv	a0,s3
 132:	35a000ef          	jal	48c <jointhread>
    jointhread(tb);
 136:	854a                	mv	a0,s2
 138:	354000ef          	jal	48c <jointhread>
    jointhread(tc);
 13c:	8526                	mv	a0,s1
 13e:	34e000ef          	jal	48c <jointhread>
    
    acquire_print_lock();
 142:	ebfff0ef          	jal	0 <acquire_print_lock>
    printf("DONE\n");
 146:	00001517          	auipc	a0,0x1
 14a:	8d250513          	addi	a0,a0,-1838 # a18 <malloc+0x158>
 14e:	6be000ef          	jal	80c <printf>
    release_print_lock();
 152:	ecfff0ef          	jal	20 <release_print_lock>
 156:	4501                	li	a0,0
 158:	4d813083          	ld	ra,1240(sp)
 15c:	4d013403          	ld	s0,1232(sp)
 160:	4c813483          	ld	s1,1224(sp)
 164:	4c013903          	ld	s2,1216(sp)
 168:	4b813983          	ld	s3,1208(sp)
 16c:	4e010113          	addi	sp,sp,1248
 170:	8082                	ret

0000000000000172 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
 172:	1141                	addi	sp,sp,-16
 174:	e406                	sd	ra,8(sp)
 176:	e022                	sd	s0,0(sp)
 178:	0800                	addi	s0,sp,16
  extern int main();
  main();
 17a:	f11ff0ef          	jal	8a <main>
  exit(0);
 17e:	4501                	li	a0,0
 180:	25c000ef          	jal	3dc <exit>

0000000000000184 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 184:	1141                	addi	sp,sp,-16
 186:	e422                	sd	s0,8(sp)
 188:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 18a:	87aa                	mv	a5,a0
 18c:	0585                	addi	a1,a1,1
 18e:	0785                	addi	a5,a5,1
 190:	fff5c703          	lbu	a4,-1(a1)
 194:	fee78fa3          	sb	a4,-1(a5)
 198:	fb75                	bnez	a4,18c <strcpy+0x8>
    ;
  return os;
}
 19a:	6422                	ld	s0,8(sp)
 19c:	0141                	addi	sp,sp,16
 19e:	8082                	ret

00000000000001a0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1a0:	1141                	addi	sp,sp,-16
 1a2:	e422                	sd	s0,8(sp)
 1a4:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1a6:	00054783          	lbu	a5,0(a0)
 1aa:	cb91                	beqz	a5,1be <strcmp+0x1e>
 1ac:	0005c703          	lbu	a4,0(a1)
 1b0:	00f71763          	bne	a4,a5,1be <strcmp+0x1e>
    p++, q++;
 1b4:	0505                	addi	a0,a0,1
 1b6:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1b8:	00054783          	lbu	a5,0(a0)
 1bc:	fbe5                	bnez	a5,1ac <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1be:	0005c503          	lbu	a0,0(a1)
}
 1c2:	40a7853b          	subw	a0,a5,a0
 1c6:	6422                	ld	s0,8(sp)
 1c8:	0141                	addi	sp,sp,16
 1ca:	8082                	ret

00000000000001cc <strlen>:

uint
strlen(const char *s)
{
 1cc:	1141                	addi	sp,sp,-16
 1ce:	e422                	sd	s0,8(sp)
 1d0:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1d2:	00054783          	lbu	a5,0(a0)
 1d6:	cf91                	beqz	a5,1f2 <strlen+0x26>
 1d8:	0505                	addi	a0,a0,1
 1da:	87aa                	mv	a5,a0
 1dc:	86be                	mv	a3,a5
 1de:	0785                	addi	a5,a5,1
 1e0:	fff7c703          	lbu	a4,-1(a5)
 1e4:	ff65                	bnez	a4,1dc <strlen+0x10>
 1e6:	40a6853b          	subw	a0,a3,a0
 1ea:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 1ec:	6422                	ld	s0,8(sp)
 1ee:	0141                	addi	sp,sp,16
 1f0:	8082                	ret
  for(n = 0; s[n]; n++)
 1f2:	4501                	li	a0,0
 1f4:	bfe5                	j	1ec <strlen+0x20>

00000000000001f6 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1f6:	1141                	addi	sp,sp,-16
 1f8:	e422                	sd	s0,8(sp)
 1fa:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1fc:	ca19                	beqz	a2,212 <memset+0x1c>
 1fe:	87aa                	mv	a5,a0
 200:	1602                	slli	a2,a2,0x20
 202:	9201                	srli	a2,a2,0x20
 204:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 208:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 20c:	0785                	addi	a5,a5,1
 20e:	fee79de3          	bne	a5,a4,208 <memset+0x12>
  }
  return dst;
}
 212:	6422                	ld	s0,8(sp)
 214:	0141                	addi	sp,sp,16
 216:	8082                	ret

0000000000000218 <strchr>:

char*
strchr(const char *s, char c)
{
 218:	1141                	addi	sp,sp,-16
 21a:	e422                	sd	s0,8(sp)
 21c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 21e:	00054783          	lbu	a5,0(a0)
 222:	cb99                	beqz	a5,238 <strchr+0x20>
    if(*s == c)
 224:	00f58763          	beq	a1,a5,232 <strchr+0x1a>
  for(; *s; s++)
 228:	0505                	addi	a0,a0,1
 22a:	00054783          	lbu	a5,0(a0)
 22e:	fbfd                	bnez	a5,224 <strchr+0xc>
      return (char*)s;
  return 0;
 230:	4501                	li	a0,0
}
 232:	6422                	ld	s0,8(sp)
 234:	0141                	addi	sp,sp,16
 236:	8082                	ret
  return 0;
 238:	4501                	li	a0,0
 23a:	bfe5                	j	232 <strchr+0x1a>

000000000000023c <gets>:

char*
gets(char *buf, int max)
{
 23c:	711d                	addi	sp,sp,-96
 23e:	ec86                	sd	ra,88(sp)
 240:	e8a2                	sd	s0,80(sp)
 242:	e4a6                	sd	s1,72(sp)
 244:	e0ca                	sd	s2,64(sp)
 246:	fc4e                	sd	s3,56(sp)
 248:	f852                	sd	s4,48(sp)
 24a:	f456                	sd	s5,40(sp)
 24c:	f05a                	sd	s6,32(sp)
 24e:	ec5e                	sd	s7,24(sp)
 250:	1080                	addi	s0,sp,96
 252:	8baa                	mv	s7,a0
 254:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 256:	892a                	mv	s2,a0
 258:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 25a:	4aa9                	li	s5,10
 25c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 25e:	89a6                	mv	s3,s1
 260:	2485                	addiw	s1,s1,1
 262:	0344d663          	bge	s1,s4,28e <gets+0x52>
    cc = read(0, &c, 1);
 266:	4605                	li	a2,1
 268:	faf40593          	addi	a1,s0,-81
 26c:	4501                	li	a0,0
 26e:	186000ef          	jal	3f4 <read>
    if(cc < 1)
 272:	00a05e63          	blez	a0,28e <gets+0x52>
    buf[i++] = c;
 276:	faf44783          	lbu	a5,-81(s0)
 27a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 27e:	01578763          	beq	a5,s5,28c <gets+0x50>
 282:	0905                	addi	s2,s2,1
 284:	fd679de3          	bne	a5,s6,25e <gets+0x22>
    buf[i++] = c;
 288:	89a6                	mv	s3,s1
 28a:	a011                	j	28e <gets+0x52>
 28c:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 28e:	99de                	add	s3,s3,s7
 290:	00098023          	sb	zero,0(s3)
  return buf;
}
 294:	855e                	mv	a0,s7
 296:	60e6                	ld	ra,88(sp)
 298:	6446                	ld	s0,80(sp)
 29a:	64a6                	ld	s1,72(sp)
 29c:	6906                	ld	s2,64(sp)
 29e:	79e2                	ld	s3,56(sp)
 2a0:	7a42                	ld	s4,48(sp)
 2a2:	7aa2                	ld	s5,40(sp)
 2a4:	7b02                	ld	s6,32(sp)
 2a6:	6be2                	ld	s7,24(sp)
 2a8:	6125                	addi	sp,sp,96
 2aa:	8082                	ret

00000000000002ac <stat>:

int
stat(const char *n, struct stat *st)
{
 2ac:	1101                	addi	sp,sp,-32
 2ae:	ec06                	sd	ra,24(sp)
 2b0:	e822                	sd	s0,16(sp)
 2b2:	e04a                	sd	s2,0(sp)
 2b4:	1000                	addi	s0,sp,32
 2b6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2b8:	4581                	li	a1,0
 2ba:	162000ef          	jal	41c <open>
  if(fd < 0)
 2be:	02054263          	bltz	a0,2e2 <stat+0x36>
 2c2:	e426                	sd	s1,8(sp)
 2c4:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2c6:	85ca                	mv	a1,s2
 2c8:	16c000ef          	jal	434 <fstat>
 2cc:	892a                	mv	s2,a0
  close(fd);
 2ce:	8526                	mv	a0,s1
 2d0:	134000ef          	jal	404 <close>
  return r;
 2d4:	64a2                	ld	s1,8(sp)
}
 2d6:	854a                	mv	a0,s2
 2d8:	60e2                	ld	ra,24(sp)
 2da:	6442                	ld	s0,16(sp)
 2dc:	6902                	ld	s2,0(sp)
 2de:	6105                	addi	sp,sp,32
 2e0:	8082                	ret
    return -1;
 2e2:	597d                	li	s2,-1
 2e4:	bfcd                	j	2d6 <stat+0x2a>

00000000000002e6 <atoi>:

int
atoi(const char *s)
{
 2e6:	1141                	addi	sp,sp,-16
 2e8:	e422                	sd	s0,8(sp)
 2ea:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2ec:	00054683          	lbu	a3,0(a0)
 2f0:	fd06879b          	addiw	a5,a3,-48
 2f4:	0ff7f793          	zext.b	a5,a5
 2f8:	4625                	li	a2,9
 2fa:	02f66863          	bltu	a2,a5,32a <atoi+0x44>
 2fe:	872a                	mv	a4,a0
  n = 0;
 300:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 302:	0705                	addi	a4,a4,1
 304:	0025179b          	slliw	a5,a0,0x2
 308:	9fa9                	addw	a5,a5,a0
 30a:	0017979b          	slliw	a5,a5,0x1
 30e:	9fb5                	addw	a5,a5,a3
 310:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 314:	00074683          	lbu	a3,0(a4)
 318:	fd06879b          	addiw	a5,a3,-48
 31c:	0ff7f793          	zext.b	a5,a5
 320:	fef671e3          	bgeu	a2,a5,302 <atoi+0x1c>
  return n;
}
 324:	6422                	ld	s0,8(sp)
 326:	0141                	addi	sp,sp,16
 328:	8082                	ret
  n = 0;
 32a:	4501                	li	a0,0
 32c:	bfe5                	j	324 <atoi+0x3e>

000000000000032e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 32e:	1141                	addi	sp,sp,-16
 330:	e422                	sd	s0,8(sp)
 332:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 334:	02b57463          	bgeu	a0,a1,35c <memmove+0x2e>
    while(n-- > 0)
 338:	00c05f63          	blez	a2,356 <memmove+0x28>
 33c:	1602                	slli	a2,a2,0x20
 33e:	9201                	srli	a2,a2,0x20
 340:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 344:	872a                	mv	a4,a0
      *dst++ = *src++;
 346:	0585                	addi	a1,a1,1
 348:	0705                	addi	a4,a4,1
 34a:	fff5c683          	lbu	a3,-1(a1)
 34e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 352:	fef71ae3          	bne	a4,a5,346 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 356:	6422                	ld	s0,8(sp)
 358:	0141                	addi	sp,sp,16
 35a:	8082                	ret
    dst += n;
 35c:	00c50733          	add	a4,a0,a2
    src += n;
 360:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 362:	fec05ae3          	blez	a2,356 <memmove+0x28>
 366:	fff6079b          	addiw	a5,a2,-1
 36a:	1782                	slli	a5,a5,0x20
 36c:	9381                	srli	a5,a5,0x20
 36e:	fff7c793          	not	a5,a5
 372:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 374:	15fd                	addi	a1,a1,-1
 376:	177d                	addi	a4,a4,-1
 378:	0005c683          	lbu	a3,0(a1)
 37c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 380:	fee79ae3          	bne	a5,a4,374 <memmove+0x46>
 384:	bfc9                	j	356 <memmove+0x28>

0000000000000386 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 386:	1141                	addi	sp,sp,-16
 388:	e422                	sd	s0,8(sp)
 38a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 38c:	ca05                	beqz	a2,3bc <memcmp+0x36>
 38e:	fff6069b          	addiw	a3,a2,-1
 392:	1682                	slli	a3,a3,0x20
 394:	9281                	srli	a3,a3,0x20
 396:	0685                	addi	a3,a3,1
 398:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 39a:	00054783          	lbu	a5,0(a0)
 39e:	0005c703          	lbu	a4,0(a1)
 3a2:	00e79863          	bne	a5,a4,3b2 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3a6:	0505                	addi	a0,a0,1
    p2++;
 3a8:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3aa:	fed518e3          	bne	a0,a3,39a <memcmp+0x14>
  }
  return 0;
 3ae:	4501                	li	a0,0
 3b0:	a019                	j	3b6 <memcmp+0x30>
      return *p1 - *p2;
 3b2:	40e7853b          	subw	a0,a5,a4
}
 3b6:	6422                	ld	s0,8(sp)
 3b8:	0141                	addi	sp,sp,16
 3ba:	8082                	ret
  return 0;
 3bc:	4501                	li	a0,0
 3be:	bfe5                	j	3b6 <memcmp+0x30>

00000000000003c0 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3c0:	1141                	addi	sp,sp,-16
 3c2:	e406                	sd	ra,8(sp)
 3c4:	e022                	sd	s0,0(sp)
 3c6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3c8:	f67ff0ef          	jal	32e <memmove>
}
 3cc:	60a2                	ld	ra,8(sp)
 3ce:	6402                	ld	s0,0(sp)
 3d0:	0141                	addi	sp,sp,16
 3d2:	8082                	ret

00000000000003d4 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3d4:	4885                	li	a7,1
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <exit>:
.global exit
exit:
 li a7, SYS_exit
 3dc:	4889                	li	a7,2
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3e4:	488d                	li	a7,3
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3ec:	4891                	li	a7,4
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <read>:
.global read
read:
 li a7, SYS_read
 3f4:	4895                	li	a7,5
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <write>:
.global write
write:
 li a7, SYS_write
 3fc:	48c1                	li	a7,16
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <close>:
.global close
close:
 li a7, SYS_close
 404:	48d5                	li	a7,21
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <kill>:
.global kill
kill:
 li a7, SYS_kill
 40c:	4899                	li	a7,6
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <exec>:
.global exec
exec:
 li a7, SYS_exec
 414:	489d                	li	a7,7
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <open>:
.global open
open:
 li a7, SYS_open
 41c:	48bd                	li	a7,15
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 424:	48c5                	li	a7,17
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 42c:	48c9                	li	a7,18
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 434:	48a1                	li	a7,8
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <link>:
.global link
link:
 li a7, SYS_link
 43c:	48cd                	li	a7,19
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 444:	48d1                	li	a7,20
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 44c:	48a5                	li	a7,9
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <dup>:
.global dup
dup:
 li a7, SYS_dup
 454:	48a9                	li	a7,10
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 45c:	48ad                	li	a7,11
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 464:	48b1                	li	a7,12
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 46c:	48b5                	li	a7,13
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 474:	48b9                	li	a7,14
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <trigger>:
.global trigger
trigger:
 li a7, SYS_trigger
 47c:	48d9                	li	a7,22
 ecall
 47e:	00000073          	ecall
 ret
 482:	8082                	ret

0000000000000484 <thread>:
.global thread
thread:
 li a7, SYS_thread
 484:	48dd                	li	a7,23
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <jointhread>:
.global jointhread
jointhread:
 li a7, SYS_jointhread
 48c:	48e1                	li	a7,24
 ecall
 48e:	00000073          	ecall
 ret
 492:	8082                	ret

0000000000000494 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 494:	1101                	addi	sp,sp,-32
 496:	ec06                	sd	ra,24(sp)
 498:	e822                	sd	s0,16(sp)
 49a:	1000                	addi	s0,sp,32
 49c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4a0:	4605                	li	a2,1
 4a2:	fef40593          	addi	a1,s0,-17
 4a6:	f57ff0ef          	jal	3fc <write>
}
 4aa:	60e2                	ld	ra,24(sp)
 4ac:	6442                	ld	s0,16(sp)
 4ae:	6105                	addi	sp,sp,32
 4b0:	8082                	ret

00000000000004b2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4b2:	7139                	addi	sp,sp,-64
 4b4:	fc06                	sd	ra,56(sp)
 4b6:	f822                	sd	s0,48(sp)
 4b8:	f426                	sd	s1,40(sp)
 4ba:	0080                	addi	s0,sp,64
 4bc:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4be:	c299                	beqz	a3,4c4 <printint+0x12>
 4c0:	0805c963          	bltz	a1,552 <printint+0xa0>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4c4:	2581                	sext.w	a1,a1
  neg = 0;
 4c6:	4881                	li	a7,0
 4c8:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4cc:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4ce:	2601                	sext.w	a2,a2
 4d0:	00000517          	auipc	a0,0x0
 4d4:	55850513          	addi	a0,a0,1368 # a28 <digits>
 4d8:	883a                	mv	a6,a4
 4da:	2705                	addiw	a4,a4,1
 4dc:	02c5f7bb          	remuw	a5,a1,a2
 4e0:	1782                	slli	a5,a5,0x20
 4e2:	9381                	srli	a5,a5,0x20
 4e4:	97aa                	add	a5,a5,a0
 4e6:	0007c783          	lbu	a5,0(a5)
 4ea:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4ee:	0005879b          	sext.w	a5,a1
 4f2:	02c5d5bb          	divuw	a1,a1,a2
 4f6:	0685                	addi	a3,a3,1
 4f8:	fec7f0e3          	bgeu	a5,a2,4d8 <printint+0x26>
  if(neg)
 4fc:	00088c63          	beqz	a7,514 <printint+0x62>
    buf[i++] = '-';
 500:	fd070793          	addi	a5,a4,-48
 504:	00878733          	add	a4,a5,s0
 508:	02d00793          	li	a5,45
 50c:	fef70823          	sb	a5,-16(a4)
 510:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 514:	02e05a63          	blez	a4,548 <printint+0x96>
 518:	f04a                	sd	s2,32(sp)
 51a:	ec4e                	sd	s3,24(sp)
 51c:	fc040793          	addi	a5,s0,-64
 520:	00e78933          	add	s2,a5,a4
 524:	fff78993          	addi	s3,a5,-1
 528:	99ba                	add	s3,s3,a4
 52a:	377d                	addiw	a4,a4,-1
 52c:	1702                	slli	a4,a4,0x20
 52e:	9301                	srli	a4,a4,0x20
 530:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 534:	fff94583          	lbu	a1,-1(s2)
 538:	8526                	mv	a0,s1
 53a:	f5bff0ef          	jal	494 <putc>
  while(--i >= 0)
 53e:	197d                	addi	s2,s2,-1
 540:	ff391ae3          	bne	s2,s3,534 <printint+0x82>
 544:	7902                	ld	s2,32(sp)
 546:	69e2                	ld	s3,24(sp)
}
 548:	70e2                	ld	ra,56(sp)
 54a:	7442                	ld	s0,48(sp)
 54c:	74a2                	ld	s1,40(sp)
 54e:	6121                	addi	sp,sp,64
 550:	8082                	ret
    x = -xx;
 552:	40b005bb          	negw	a1,a1
    neg = 1;
 556:	4885                	li	a7,1
    x = -xx;
 558:	bf85                	j	4c8 <printint+0x16>

000000000000055a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 55a:	711d                	addi	sp,sp,-96
 55c:	ec86                	sd	ra,88(sp)
 55e:	e8a2                	sd	s0,80(sp)
 560:	e0ca                	sd	s2,64(sp)
 562:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 564:	0005c903          	lbu	s2,0(a1)
 568:	26090863          	beqz	s2,7d8 <vprintf+0x27e>
 56c:	e4a6                	sd	s1,72(sp)
 56e:	fc4e                	sd	s3,56(sp)
 570:	f852                	sd	s4,48(sp)
 572:	f456                	sd	s5,40(sp)
 574:	f05a                	sd	s6,32(sp)
 576:	ec5e                	sd	s7,24(sp)
 578:	e862                	sd	s8,16(sp)
 57a:	e466                	sd	s9,8(sp)
 57c:	8b2a                	mv	s6,a0
 57e:	8a2e                	mv	s4,a1
 580:	8bb2                	mv	s7,a2
  state = 0;
 582:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 584:	4481                	li	s1,0
 586:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 588:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 58c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 590:	06c00c93          	li	s9,108
 594:	a005                	j	5b4 <vprintf+0x5a>
        putc(fd, c0);
 596:	85ca                	mv	a1,s2
 598:	855a                	mv	a0,s6
 59a:	efbff0ef          	jal	494 <putc>
 59e:	a019                	j	5a4 <vprintf+0x4a>
    } else if(state == '%'){
 5a0:	03598263          	beq	s3,s5,5c4 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 5a4:	2485                	addiw	s1,s1,1
 5a6:	8726                	mv	a4,s1
 5a8:	009a07b3          	add	a5,s4,s1
 5ac:	0007c903          	lbu	s2,0(a5)
 5b0:	20090c63          	beqz	s2,7c8 <vprintf+0x26e>
    c0 = fmt[i] & 0xff;
 5b4:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5b8:	fe0994e3          	bnez	s3,5a0 <vprintf+0x46>
      if(c0 == '%'){
 5bc:	fd579de3          	bne	a5,s5,596 <vprintf+0x3c>
        state = '%';
 5c0:	89be                	mv	s3,a5
 5c2:	b7cd                	j	5a4 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 5c4:	00ea06b3          	add	a3,s4,a4
 5c8:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 5cc:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 5ce:	c681                	beqz	a3,5d6 <vprintf+0x7c>
 5d0:	9752                	add	a4,a4,s4
 5d2:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 5d6:	03878f63          	beq	a5,s8,614 <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
 5da:	05978963          	beq	a5,s9,62c <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 5de:	07500713          	li	a4,117
 5e2:	0ee78363          	beq	a5,a4,6c8 <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 5e6:	07800713          	li	a4,120
 5ea:	12e78563          	beq	a5,a4,714 <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 5ee:	07000713          	li	a4,112
 5f2:	14e78a63          	beq	a5,a4,746 <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 5f6:	07300713          	li	a4,115
 5fa:	18e78a63          	beq	a5,a4,78e <vprintf+0x234>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5fe:	02500713          	li	a4,37
 602:	04e79563          	bne	a5,a4,64c <vprintf+0xf2>
        putc(fd, '%');
 606:	02500593          	li	a1,37
 60a:	855a                	mv	a0,s6
 60c:	e89ff0ef          	jal	494 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 610:	4981                	li	s3,0
 612:	bf49                	j	5a4 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 614:	008b8913          	addi	s2,s7,8
 618:	4685                	li	a3,1
 61a:	4629                	li	a2,10
 61c:	000ba583          	lw	a1,0(s7)
 620:	855a                	mv	a0,s6
 622:	e91ff0ef          	jal	4b2 <printint>
 626:	8bca                	mv	s7,s2
      state = 0;
 628:	4981                	li	s3,0
 62a:	bfad                	j	5a4 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 62c:	06400793          	li	a5,100
 630:	02f68963          	beq	a3,a5,662 <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 634:	06c00793          	li	a5,108
 638:	04f68263          	beq	a3,a5,67c <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
 63c:	07500793          	li	a5,117
 640:	0af68063          	beq	a3,a5,6e0 <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
 644:	07800793          	li	a5,120
 648:	0ef68263          	beq	a3,a5,72c <vprintf+0x1d2>
        putc(fd, '%');
 64c:	02500593          	li	a1,37
 650:	855a                	mv	a0,s6
 652:	e43ff0ef          	jal	494 <putc>
        putc(fd, c0);
 656:	85ca                	mv	a1,s2
 658:	855a                	mv	a0,s6
 65a:	e3bff0ef          	jal	494 <putc>
      state = 0;
 65e:	4981                	li	s3,0
 660:	b791                	j	5a4 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 662:	008b8913          	addi	s2,s7,8
 666:	4685                	li	a3,1
 668:	4629                	li	a2,10
 66a:	000ba583          	lw	a1,0(s7)
 66e:	855a                	mv	a0,s6
 670:	e43ff0ef          	jal	4b2 <printint>
        i += 1;
 674:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 676:	8bca                	mv	s7,s2
      state = 0;
 678:	4981                	li	s3,0
        i += 1;
 67a:	b72d                	j	5a4 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 67c:	06400793          	li	a5,100
 680:	02f60763          	beq	a2,a5,6ae <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 684:	07500793          	li	a5,117
 688:	06f60963          	beq	a2,a5,6fa <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 68c:	07800793          	li	a5,120
 690:	faf61ee3          	bne	a2,a5,64c <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 694:	008b8913          	addi	s2,s7,8
 698:	4681                	li	a3,0
 69a:	4641                	li	a2,16
 69c:	000ba583          	lw	a1,0(s7)
 6a0:	855a                	mv	a0,s6
 6a2:	e11ff0ef          	jal	4b2 <printint>
        i += 2;
 6a6:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6a8:	8bca                	mv	s7,s2
      state = 0;
 6aa:	4981                	li	s3,0
        i += 2;
 6ac:	bde5                	j	5a4 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6ae:	008b8913          	addi	s2,s7,8
 6b2:	4685                	li	a3,1
 6b4:	4629                	li	a2,10
 6b6:	000ba583          	lw	a1,0(s7)
 6ba:	855a                	mv	a0,s6
 6bc:	df7ff0ef          	jal	4b2 <printint>
        i += 2;
 6c0:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6c2:	8bca                	mv	s7,s2
      state = 0;
 6c4:	4981                	li	s3,0
        i += 2;
 6c6:	bdf9                	j	5a4 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
 6c8:	008b8913          	addi	s2,s7,8
 6cc:	4681                	li	a3,0
 6ce:	4629                	li	a2,10
 6d0:	000ba583          	lw	a1,0(s7)
 6d4:	855a                	mv	a0,s6
 6d6:	dddff0ef          	jal	4b2 <printint>
 6da:	8bca                	mv	s7,s2
      state = 0;
 6dc:	4981                	li	s3,0
 6de:	b5d9                	j	5a4 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6e0:	008b8913          	addi	s2,s7,8
 6e4:	4681                	li	a3,0
 6e6:	4629                	li	a2,10
 6e8:	000ba583          	lw	a1,0(s7)
 6ec:	855a                	mv	a0,s6
 6ee:	dc5ff0ef          	jal	4b2 <printint>
        i += 1;
 6f2:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6f4:	8bca                	mv	s7,s2
      state = 0;
 6f6:	4981                	li	s3,0
        i += 1;
 6f8:	b575                	j	5a4 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6fa:	008b8913          	addi	s2,s7,8
 6fe:	4681                	li	a3,0
 700:	4629                	li	a2,10
 702:	000ba583          	lw	a1,0(s7)
 706:	855a                	mv	a0,s6
 708:	dabff0ef          	jal	4b2 <printint>
        i += 2;
 70c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 70e:	8bca                	mv	s7,s2
      state = 0;
 710:	4981                	li	s3,0
        i += 2;
 712:	bd49                	j	5a4 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
 714:	008b8913          	addi	s2,s7,8
 718:	4681                	li	a3,0
 71a:	4641                	li	a2,16
 71c:	000ba583          	lw	a1,0(s7)
 720:	855a                	mv	a0,s6
 722:	d91ff0ef          	jal	4b2 <printint>
 726:	8bca                	mv	s7,s2
      state = 0;
 728:	4981                	li	s3,0
 72a:	bdad                	j	5a4 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 72c:	008b8913          	addi	s2,s7,8
 730:	4681                	li	a3,0
 732:	4641                	li	a2,16
 734:	000ba583          	lw	a1,0(s7)
 738:	855a                	mv	a0,s6
 73a:	d79ff0ef          	jal	4b2 <printint>
        i += 1;
 73e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 740:	8bca                	mv	s7,s2
      state = 0;
 742:	4981                	li	s3,0
        i += 1;
 744:	b585                	j	5a4 <vprintf+0x4a>
 746:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 748:	008b8d13          	addi	s10,s7,8
 74c:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 750:	03000593          	li	a1,48
 754:	855a                	mv	a0,s6
 756:	d3fff0ef          	jal	494 <putc>
  putc(fd, 'x');
 75a:	07800593          	li	a1,120
 75e:	855a                	mv	a0,s6
 760:	d35ff0ef          	jal	494 <putc>
 764:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 766:	00000b97          	auipc	s7,0x0
 76a:	2c2b8b93          	addi	s7,s7,706 # a28 <digits>
 76e:	03c9d793          	srli	a5,s3,0x3c
 772:	97de                	add	a5,a5,s7
 774:	0007c583          	lbu	a1,0(a5)
 778:	855a                	mv	a0,s6
 77a:	d1bff0ef          	jal	494 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 77e:	0992                	slli	s3,s3,0x4
 780:	397d                	addiw	s2,s2,-1
 782:	fe0916e3          	bnez	s2,76e <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
 786:	8bea                	mv	s7,s10
      state = 0;
 788:	4981                	li	s3,0
 78a:	6d02                	ld	s10,0(sp)
 78c:	bd21                	j	5a4 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 78e:	008b8993          	addi	s3,s7,8
 792:	000bb903          	ld	s2,0(s7)
 796:	00090f63          	beqz	s2,7b4 <vprintf+0x25a>
        for(; *s; s++)
 79a:	00094583          	lbu	a1,0(s2)
 79e:	c195                	beqz	a1,7c2 <vprintf+0x268>
          putc(fd, *s);
 7a0:	855a                	mv	a0,s6
 7a2:	cf3ff0ef          	jal	494 <putc>
        for(; *s; s++)
 7a6:	0905                	addi	s2,s2,1
 7a8:	00094583          	lbu	a1,0(s2)
 7ac:	f9f5                	bnez	a1,7a0 <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 7ae:	8bce                	mv	s7,s3
      state = 0;
 7b0:	4981                	li	s3,0
 7b2:	bbcd                	j	5a4 <vprintf+0x4a>
          s = "(null)";
 7b4:	00000917          	auipc	s2,0x0
 7b8:	26c90913          	addi	s2,s2,620 # a20 <malloc+0x160>
        for(; *s; s++)
 7bc:	02800593          	li	a1,40
 7c0:	b7c5                	j	7a0 <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 7c2:	8bce                	mv	s7,s3
      state = 0;
 7c4:	4981                	li	s3,0
 7c6:	bbf9                	j	5a4 <vprintf+0x4a>
 7c8:	64a6                	ld	s1,72(sp)
 7ca:	79e2                	ld	s3,56(sp)
 7cc:	7a42                	ld	s4,48(sp)
 7ce:	7aa2                	ld	s5,40(sp)
 7d0:	7b02                	ld	s6,32(sp)
 7d2:	6be2                	ld	s7,24(sp)
 7d4:	6c42                	ld	s8,16(sp)
 7d6:	6ca2                	ld	s9,8(sp)
    }
  }
}
 7d8:	60e6                	ld	ra,88(sp)
 7da:	6446                	ld	s0,80(sp)
 7dc:	6906                	ld	s2,64(sp)
 7de:	6125                	addi	sp,sp,96
 7e0:	8082                	ret

00000000000007e2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7e2:	715d                	addi	sp,sp,-80
 7e4:	ec06                	sd	ra,24(sp)
 7e6:	e822                	sd	s0,16(sp)
 7e8:	1000                	addi	s0,sp,32
 7ea:	e010                	sd	a2,0(s0)
 7ec:	e414                	sd	a3,8(s0)
 7ee:	e818                	sd	a4,16(s0)
 7f0:	ec1c                	sd	a5,24(s0)
 7f2:	03043023          	sd	a6,32(s0)
 7f6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7fa:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7fe:	8622                	mv	a2,s0
 800:	d5bff0ef          	jal	55a <vprintf>
}
 804:	60e2                	ld	ra,24(sp)
 806:	6442                	ld	s0,16(sp)
 808:	6161                	addi	sp,sp,80
 80a:	8082                	ret

000000000000080c <printf>:

void
printf(const char *fmt, ...)
{
 80c:	711d                	addi	sp,sp,-96
 80e:	ec06                	sd	ra,24(sp)
 810:	e822                	sd	s0,16(sp)
 812:	1000                	addi	s0,sp,32
 814:	e40c                	sd	a1,8(s0)
 816:	e810                	sd	a2,16(s0)
 818:	ec14                	sd	a3,24(s0)
 81a:	f018                	sd	a4,32(s0)
 81c:	f41c                	sd	a5,40(s0)
 81e:	03043823          	sd	a6,48(s0)
 822:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 826:	00840613          	addi	a2,s0,8
 82a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 82e:	85aa                	mv	a1,a0
 830:	4505                	li	a0,1
 832:	d29ff0ef          	jal	55a <vprintf>
}
 836:	60e2                	ld	ra,24(sp)
 838:	6442                	ld	s0,16(sp)
 83a:	6125                	addi	sp,sp,96
 83c:	8082                	ret

000000000000083e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 83e:	1141                	addi	sp,sp,-16
 840:	e422                	sd	s0,8(sp)
 842:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 844:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 848:	00000797          	auipc	a5,0x0
 84c:	7f07b783          	ld	a5,2032(a5) # 1038 <freep>
 850:	a02d                	j	87a <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 852:	4618                	lw	a4,8(a2)
 854:	9f2d                	addw	a4,a4,a1
 856:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 85a:	6398                	ld	a4,0(a5)
 85c:	6310                	ld	a2,0(a4)
 85e:	a83d                	j	89c <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 860:	ff852703          	lw	a4,-8(a0)
 864:	9f31                	addw	a4,a4,a2
 866:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 868:	ff053683          	ld	a3,-16(a0)
 86c:	a091                	j	8b0 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 86e:	6398                	ld	a4,0(a5)
 870:	00e7e463          	bltu	a5,a4,878 <free+0x3a>
 874:	00e6ea63          	bltu	a3,a4,888 <free+0x4a>
{
 878:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 87a:	fed7fae3          	bgeu	a5,a3,86e <free+0x30>
 87e:	6398                	ld	a4,0(a5)
 880:	00e6e463          	bltu	a3,a4,888 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 884:	fee7eae3          	bltu	a5,a4,878 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 888:	ff852583          	lw	a1,-8(a0)
 88c:	6390                	ld	a2,0(a5)
 88e:	02059813          	slli	a6,a1,0x20
 892:	01c85713          	srli	a4,a6,0x1c
 896:	9736                	add	a4,a4,a3
 898:	fae60de3          	beq	a2,a4,852 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 89c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8a0:	4790                	lw	a2,8(a5)
 8a2:	02061593          	slli	a1,a2,0x20
 8a6:	01c5d713          	srli	a4,a1,0x1c
 8aa:	973e                	add	a4,a4,a5
 8ac:	fae68ae3          	beq	a3,a4,860 <free+0x22>
    p->s.ptr = bp->s.ptr;
 8b0:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8b2:	00000717          	auipc	a4,0x0
 8b6:	78f73323          	sd	a5,1926(a4) # 1038 <freep>
}
 8ba:	6422                	ld	s0,8(sp)
 8bc:	0141                	addi	sp,sp,16
 8be:	8082                	ret

00000000000008c0 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8c0:	7139                	addi	sp,sp,-64
 8c2:	fc06                	sd	ra,56(sp)
 8c4:	f822                	sd	s0,48(sp)
 8c6:	f426                	sd	s1,40(sp)
 8c8:	ec4e                	sd	s3,24(sp)
 8ca:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8cc:	02051493          	slli	s1,a0,0x20
 8d0:	9081                	srli	s1,s1,0x20
 8d2:	04bd                	addi	s1,s1,15
 8d4:	8091                	srli	s1,s1,0x4
 8d6:	0014899b          	addiw	s3,s1,1
 8da:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8dc:	00000517          	auipc	a0,0x0
 8e0:	75c53503          	ld	a0,1884(a0) # 1038 <freep>
 8e4:	c915                	beqz	a0,918 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8e6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8e8:	4798                	lw	a4,8(a5)
 8ea:	08977a63          	bgeu	a4,s1,97e <malloc+0xbe>
 8ee:	f04a                	sd	s2,32(sp)
 8f0:	e852                	sd	s4,16(sp)
 8f2:	e456                	sd	s5,8(sp)
 8f4:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8f6:	8a4e                	mv	s4,s3
 8f8:	0009871b          	sext.w	a4,s3
 8fc:	6685                	lui	a3,0x1
 8fe:	00d77363          	bgeu	a4,a3,904 <malloc+0x44>
 902:	6a05                	lui	s4,0x1
 904:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 908:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 90c:	00000917          	auipc	s2,0x0
 910:	72c90913          	addi	s2,s2,1836 # 1038 <freep>
  if(p == (char*)-1)
 914:	5afd                	li	s5,-1
 916:	a081                	j	956 <malloc+0x96>
 918:	f04a                	sd	s2,32(sp)
 91a:	e852                	sd	s4,16(sp)
 91c:	e456                	sd	s5,8(sp)
 91e:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 920:	00000797          	auipc	a5,0x0
 924:	72078793          	addi	a5,a5,1824 # 1040 <base>
 928:	00000717          	auipc	a4,0x0
 92c:	70f73823          	sd	a5,1808(a4) # 1038 <freep>
 930:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 932:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 936:	b7c1                	j	8f6 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 938:	6398                	ld	a4,0(a5)
 93a:	e118                	sd	a4,0(a0)
 93c:	a8a9                	j	996 <malloc+0xd6>
  hp->s.size = nu;
 93e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 942:	0541                	addi	a0,a0,16
 944:	efbff0ef          	jal	83e <free>
  return freep;
 948:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 94c:	c12d                	beqz	a0,9ae <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 94e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 950:	4798                	lw	a4,8(a5)
 952:	02977263          	bgeu	a4,s1,976 <malloc+0xb6>
    if(p == freep)
 956:	00093703          	ld	a4,0(s2)
 95a:	853e                	mv	a0,a5
 95c:	fef719e3          	bne	a4,a5,94e <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 960:	8552                	mv	a0,s4
 962:	b03ff0ef          	jal	464 <sbrk>
  if(p == (char*)-1)
 966:	fd551ce3          	bne	a0,s5,93e <malloc+0x7e>
        return 0;
 96a:	4501                	li	a0,0
 96c:	7902                	ld	s2,32(sp)
 96e:	6a42                	ld	s4,16(sp)
 970:	6aa2                	ld	s5,8(sp)
 972:	6b02                	ld	s6,0(sp)
 974:	a03d                	j	9a2 <malloc+0xe2>
 976:	7902                	ld	s2,32(sp)
 978:	6a42                	ld	s4,16(sp)
 97a:	6aa2                	ld	s5,8(sp)
 97c:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 97e:	fae48de3          	beq	s1,a4,938 <malloc+0x78>
        p->s.size -= nunits;
 982:	4137073b          	subw	a4,a4,s3
 986:	c798                	sw	a4,8(a5)
        p += p->s.size;
 988:	02071693          	slli	a3,a4,0x20
 98c:	01c6d713          	srli	a4,a3,0x1c
 990:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 992:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 996:	00000717          	auipc	a4,0x0
 99a:	6aa73123          	sd	a0,1698(a4) # 1038 <freep>
      return (void*)(p + 1);
 99e:	01078513          	addi	a0,a5,16
  }
}
 9a2:	70e2                	ld	ra,56(sp)
 9a4:	7442                	ld	s0,48(sp)
 9a6:	74a2                	ld	s1,40(sp)
 9a8:	69e2                	ld	s3,24(sp)
 9aa:	6121                	addi	sp,sp,64
 9ac:	8082                	ret
 9ae:	7902                	ld	s2,32(sp)
 9b0:	6a42                	ld	s4,16(sp)
 9b2:	6aa2                	ld	s5,8(sp)
 9b4:	6b02                	ld	s6,0(sp)
 9b6:	b7f5                	j	9a2 <malloc+0xe2>
