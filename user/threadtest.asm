
user/_threadtest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <my_thread>:
#include "../kernel/proc.h"
#include "../user/user.h"

#define STACK_SIZE  100

void *my_thread(void *arg) {
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
   e:	84aa                	mv	s1,a0
    uint64 number = (uint64) arg;
    for (int i = 0; i < 100; ++i) {
  10:	06450913          	addi	s2,a0,100
        number++;
        printf("thread: %lu\n", number);
  14:	00001997          	auipc	s3,0x1
  18:	93c98993          	addi	s3,s3,-1732 # 950 <malloc+0x106>
        number++;
  1c:	0485                	addi	s1,s1,1
        printf("thread: %lu\n", number);
  1e:	85a6                	mv	a1,s1
  20:	854e                	mv	a0,s3
  22:	774000ef          	jal	796 <printf>
    for (int i = 0; i < 100; ++i) {
  26:	ff249be3          	bne	s1,s2,1c <my_thread+0x1c>
    }
    return (void *) number;
}
  2a:	854a                	mv	a0,s2
  2c:	70a2                	ld	ra,40(sp)
  2e:	7402                	ld	s0,32(sp)
  30:	64e2                	ld	s1,24(sp)
  32:	6942                	ld	s2,16(sp)
  34:	69a2                	ld	s3,8(sp)
  36:	6145                	addi	sp,sp,48
  38:	8082                	ret

000000000000003a <main>:

int main(int argc, char *argv[]) {
  3a:	b2010113          	addi	sp,sp,-1248
  3e:	4c113c23          	sd	ra,1240(sp)
  42:	4c813823          	sd	s0,1232(sp)
  46:	4c913423          	sd	s1,1224(sp)
  4a:	4d213023          	sd	s2,1216(sp)
  4e:	4b313c23          	sd	s3,1208(sp)
  52:	4e010413          	addi	s0,sp,1248
    int sp1[STACK_SIZE], sp2[STACK_SIZE], sp3[STACK_SIZE];
    int ta = thread(my_thread, sp1 + STACK_SIZE, (void *) 100);
  56:	06400613          	li	a2,100
  5a:	fd040593          	addi	a1,s0,-48
  5e:	00000517          	auipc	a0,0x0
  62:	fa250513          	addi	a0,a0,-94 # 0 <my_thread>
  66:	3a8000ef          	jal	40e <thread>
  6a:	89aa                	mv	s3,a0
    printf("NEW THREAD CREATED %d\n", ta);
  6c:	85aa                	mv	a1,a0
  6e:	00001517          	auipc	a0,0x1
  72:	8f250513          	addi	a0,a0,-1806 # 960 <malloc+0x116>
  76:	720000ef          	jal	796 <printf>
    int tb = thread(my_thread, sp2 + STACK_SIZE, (void *) 200);
  7a:	0c800613          	li	a2,200
  7e:	e4040593          	addi	a1,s0,-448
  82:	00000517          	auipc	a0,0x0
  86:	f7e50513          	addi	a0,a0,-130 # 0 <my_thread>
  8a:	384000ef          	jal	40e <thread>
  8e:	892a                	mv	s2,a0
    printf("NEW THREAD CREATED %d\n", tb);
  90:	85aa                	mv	a1,a0
  92:	00001517          	auipc	a0,0x1
  96:	8ce50513          	addi	a0,a0,-1842 # 960 <malloc+0x116>
  9a:	6fc000ef          	jal	796 <printf>
    int tc = thread(my_thread, sp3 + STACK_SIZE, (void *) 300);
  9e:	12c00613          	li	a2,300
  a2:	cb040593          	addi	a1,s0,-848
  a6:	00000517          	auipc	a0,0x0
  aa:	f5a50513          	addi	a0,a0,-166 # 0 <my_thread>
  ae:	360000ef          	jal	40e <thread>
  b2:	84aa                	mv	s1,a0
    printf("NEW THREAD CREATED %d\n", tc);
  b4:	85aa                	mv	a1,a0
  b6:	00001517          	auipc	a0,0x1
  ba:	8aa50513          	addi	a0,a0,-1878 # 960 <malloc+0x116>
  be:	6d8000ef          	jal	796 <printf>
    jointhread(ta);
  c2:	854e                	mv	a0,s3
  c4:	352000ef          	jal	416 <jointhread>
    jointhread(tb);
  c8:	854a                	mv	a0,s2
  ca:	34c000ef          	jal	416 <jointhread>
    jointhread(tc);
  ce:	8526                	mv	a0,s1
  d0:	346000ef          	jal	416 <jointhread>
    printf("DONE\n");
  d4:	00001517          	auipc	a0,0x1
  d8:	8a450513          	addi	a0,a0,-1884 # 978 <malloc+0x12e>
  dc:	6ba000ef          	jal	796 <printf>
}
  e0:	4501                	li	a0,0
  e2:	4d813083          	ld	ra,1240(sp)
  e6:	4d013403          	ld	s0,1232(sp)
  ea:	4c813483          	ld	s1,1224(sp)
  ee:	4c013903          	ld	s2,1216(sp)
  f2:	4b813983          	ld	s3,1208(sp)
  f6:	4e010113          	addi	sp,sp,1248
  fa:	8082                	ret

00000000000000fc <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
  fc:	1141                	addi	sp,sp,-16
  fe:	e406                	sd	ra,8(sp)
 100:	e022                	sd	s0,0(sp)
 102:	0800                	addi	s0,sp,16
  extern int main();
  main();
 104:	f37ff0ef          	jal	3a <main>
  exit(0);
 108:	4501                	li	a0,0
 10a:	25c000ef          	jal	366 <exit>

000000000000010e <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 10e:	1141                	addi	sp,sp,-16
 110:	e422                	sd	s0,8(sp)
 112:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 114:	87aa                	mv	a5,a0
 116:	0585                	addi	a1,a1,1
 118:	0785                	addi	a5,a5,1
 11a:	fff5c703          	lbu	a4,-1(a1)
 11e:	fee78fa3          	sb	a4,-1(a5)
 122:	fb75                	bnez	a4,116 <strcpy+0x8>
    ;
  return os;
}
 124:	6422                	ld	s0,8(sp)
 126:	0141                	addi	sp,sp,16
 128:	8082                	ret

000000000000012a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 12a:	1141                	addi	sp,sp,-16
 12c:	e422                	sd	s0,8(sp)
 12e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 130:	00054783          	lbu	a5,0(a0)
 134:	cb91                	beqz	a5,148 <strcmp+0x1e>
 136:	0005c703          	lbu	a4,0(a1)
 13a:	00f71763          	bne	a4,a5,148 <strcmp+0x1e>
    p++, q++;
 13e:	0505                	addi	a0,a0,1
 140:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 142:	00054783          	lbu	a5,0(a0)
 146:	fbe5                	bnez	a5,136 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 148:	0005c503          	lbu	a0,0(a1)
}
 14c:	40a7853b          	subw	a0,a5,a0
 150:	6422                	ld	s0,8(sp)
 152:	0141                	addi	sp,sp,16
 154:	8082                	ret

0000000000000156 <strlen>:

uint
strlen(const char *s)
{
 156:	1141                	addi	sp,sp,-16
 158:	e422                	sd	s0,8(sp)
 15a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 15c:	00054783          	lbu	a5,0(a0)
 160:	cf91                	beqz	a5,17c <strlen+0x26>
 162:	0505                	addi	a0,a0,1
 164:	87aa                	mv	a5,a0
 166:	86be                	mv	a3,a5
 168:	0785                	addi	a5,a5,1
 16a:	fff7c703          	lbu	a4,-1(a5)
 16e:	ff65                	bnez	a4,166 <strlen+0x10>
 170:	40a6853b          	subw	a0,a3,a0
 174:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 176:	6422                	ld	s0,8(sp)
 178:	0141                	addi	sp,sp,16
 17a:	8082                	ret
  for(n = 0; s[n]; n++)
 17c:	4501                	li	a0,0
 17e:	bfe5                	j	176 <strlen+0x20>

0000000000000180 <memset>:

void*
memset(void *dst, int c, uint n)
{
 180:	1141                	addi	sp,sp,-16
 182:	e422                	sd	s0,8(sp)
 184:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 186:	ca19                	beqz	a2,19c <memset+0x1c>
 188:	87aa                	mv	a5,a0
 18a:	1602                	slli	a2,a2,0x20
 18c:	9201                	srli	a2,a2,0x20
 18e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 192:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 196:	0785                	addi	a5,a5,1
 198:	fee79de3          	bne	a5,a4,192 <memset+0x12>
  }
  return dst;
}
 19c:	6422                	ld	s0,8(sp)
 19e:	0141                	addi	sp,sp,16
 1a0:	8082                	ret

00000000000001a2 <strchr>:

char*
strchr(const char *s, char c)
{
 1a2:	1141                	addi	sp,sp,-16
 1a4:	e422                	sd	s0,8(sp)
 1a6:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1a8:	00054783          	lbu	a5,0(a0)
 1ac:	cb99                	beqz	a5,1c2 <strchr+0x20>
    if(*s == c)
 1ae:	00f58763          	beq	a1,a5,1bc <strchr+0x1a>
  for(; *s; s++)
 1b2:	0505                	addi	a0,a0,1
 1b4:	00054783          	lbu	a5,0(a0)
 1b8:	fbfd                	bnez	a5,1ae <strchr+0xc>
      return (char*)s;
  return 0;
 1ba:	4501                	li	a0,0
}
 1bc:	6422                	ld	s0,8(sp)
 1be:	0141                	addi	sp,sp,16
 1c0:	8082                	ret
  return 0;
 1c2:	4501                	li	a0,0
 1c4:	bfe5                	j	1bc <strchr+0x1a>

00000000000001c6 <gets>:

char*
gets(char *buf, int max)
{
 1c6:	711d                	addi	sp,sp,-96
 1c8:	ec86                	sd	ra,88(sp)
 1ca:	e8a2                	sd	s0,80(sp)
 1cc:	e4a6                	sd	s1,72(sp)
 1ce:	e0ca                	sd	s2,64(sp)
 1d0:	fc4e                	sd	s3,56(sp)
 1d2:	f852                	sd	s4,48(sp)
 1d4:	f456                	sd	s5,40(sp)
 1d6:	f05a                	sd	s6,32(sp)
 1d8:	ec5e                	sd	s7,24(sp)
 1da:	1080                	addi	s0,sp,96
 1dc:	8baa                	mv	s7,a0
 1de:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1e0:	892a                	mv	s2,a0
 1e2:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1e4:	4aa9                	li	s5,10
 1e6:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1e8:	89a6                	mv	s3,s1
 1ea:	2485                	addiw	s1,s1,1
 1ec:	0344d663          	bge	s1,s4,218 <gets+0x52>
    cc = read(0, &c, 1);
 1f0:	4605                	li	a2,1
 1f2:	faf40593          	addi	a1,s0,-81
 1f6:	4501                	li	a0,0
 1f8:	186000ef          	jal	37e <read>
    if(cc < 1)
 1fc:	00a05e63          	blez	a0,218 <gets+0x52>
    buf[i++] = c;
 200:	faf44783          	lbu	a5,-81(s0)
 204:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 208:	01578763          	beq	a5,s5,216 <gets+0x50>
 20c:	0905                	addi	s2,s2,1
 20e:	fd679de3          	bne	a5,s6,1e8 <gets+0x22>
    buf[i++] = c;
 212:	89a6                	mv	s3,s1
 214:	a011                	j	218 <gets+0x52>
 216:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 218:	99de                	add	s3,s3,s7
 21a:	00098023          	sb	zero,0(s3)
  return buf;
}
 21e:	855e                	mv	a0,s7
 220:	60e6                	ld	ra,88(sp)
 222:	6446                	ld	s0,80(sp)
 224:	64a6                	ld	s1,72(sp)
 226:	6906                	ld	s2,64(sp)
 228:	79e2                	ld	s3,56(sp)
 22a:	7a42                	ld	s4,48(sp)
 22c:	7aa2                	ld	s5,40(sp)
 22e:	7b02                	ld	s6,32(sp)
 230:	6be2                	ld	s7,24(sp)
 232:	6125                	addi	sp,sp,96
 234:	8082                	ret

0000000000000236 <stat>:

int
stat(const char *n, struct stat *st)
{
 236:	1101                	addi	sp,sp,-32
 238:	ec06                	sd	ra,24(sp)
 23a:	e822                	sd	s0,16(sp)
 23c:	e04a                	sd	s2,0(sp)
 23e:	1000                	addi	s0,sp,32
 240:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 242:	4581                	li	a1,0
 244:	162000ef          	jal	3a6 <open>
  if(fd < 0)
 248:	02054263          	bltz	a0,26c <stat+0x36>
 24c:	e426                	sd	s1,8(sp)
 24e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 250:	85ca                	mv	a1,s2
 252:	16c000ef          	jal	3be <fstat>
 256:	892a                	mv	s2,a0
  close(fd);
 258:	8526                	mv	a0,s1
 25a:	134000ef          	jal	38e <close>
  return r;
 25e:	64a2                	ld	s1,8(sp)
}
 260:	854a                	mv	a0,s2
 262:	60e2                	ld	ra,24(sp)
 264:	6442                	ld	s0,16(sp)
 266:	6902                	ld	s2,0(sp)
 268:	6105                	addi	sp,sp,32
 26a:	8082                	ret
    return -1;
 26c:	597d                	li	s2,-1
 26e:	bfcd                	j	260 <stat+0x2a>

0000000000000270 <atoi>:

int
atoi(const char *s)
{
 270:	1141                	addi	sp,sp,-16
 272:	e422                	sd	s0,8(sp)
 274:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 276:	00054683          	lbu	a3,0(a0)
 27a:	fd06879b          	addiw	a5,a3,-48
 27e:	0ff7f793          	zext.b	a5,a5
 282:	4625                	li	a2,9
 284:	02f66863          	bltu	a2,a5,2b4 <atoi+0x44>
 288:	872a                	mv	a4,a0
  n = 0;
 28a:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 28c:	0705                	addi	a4,a4,1
 28e:	0025179b          	slliw	a5,a0,0x2
 292:	9fa9                	addw	a5,a5,a0
 294:	0017979b          	slliw	a5,a5,0x1
 298:	9fb5                	addw	a5,a5,a3
 29a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 29e:	00074683          	lbu	a3,0(a4)
 2a2:	fd06879b          	addiw	a5,a3,-48
 2a6:	0ff7f793          	zext.b	a5,a5
 2aa:	fef671e3          	bgeu	a2,a5,28c <atoi+0x1c>
  return n;
}
 2ae:	6422                	ld	s0,8(sp)
 2b0:	0141                	addi	sp,sp,16
 2b2:	8082                	ret
  n = 0;
 2b4:	4501                	li	a0,0
 2b6:	bfe5                	j	2ae <atoi+0x3e>

00000000000002b8 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2b8:	1141                	addi	sp,sp,-16
 2ba:	e422                	sd	s0,8(sp)
 2bc:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2be:	02b57463          	bgeu	a0,a1,2e6 <memmove+0x2e>
    while(n-- > 0)
 2c2:	00c05f63          	blez	a2,2e0 <memmove+0x28>
 2c6:	1602                	slli	a2,a2,0x20
 2c8:	9201                	srli	a2,a2,0x20
 2ca:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2ce:	872a                	mv	a4,a0
      *dst++ = *src++;
 2d0:	0585                	addi	a1,a1,1
 2d2:	0705                	addi	a4,a4,1
 2d4:	fff5c683          	lbu	a3,-1(a1)
 2d8:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2dc:	fef71ae3          	bne	a4,a5,2d0 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2e0:	6422                	ld	s0,8(sp)
 2e2:	0141                	addi	sp,sp,16
 2e4:	8082                	ret
    dst += n;
 2e6:	00c50733          	add	a4,a0,a2
    src += n;
 2ea:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2ec:	fec05ae3          	blez	a2,2e0 <memmove+0x28>
 2f0:	fff6079b          	addiw	a5,a2,-1
 2f4:	1782                	slli	a5,a5,0x20
 2f6:	9381                	srli	a5,a5,0x20
 2f8:	fff7c793          	not	a5,a5
 2fc:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2fe:	15fd                	addi	a1,a1,-1
 300:	177d                	addi	a4,a4,-1
 302:	0005c683          	lbu	a3,0(a1)
 306:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 30a:	fee79ae3          	bne	a5,a4,2fe <memmove+0x46>
 30e:	bfc9                	j	2e0 <memmove+0x28>

0000000000000310 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 310:	1141                	addi	sp,sp,-16
 312:	e422                	sd	s0,8(sp)
 314:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 316:	ca05                	beqz	a2,346 <memcmp+0x36>
 318:	fff6069b          	addiw	a3,a2,-1
 31c:	1682                	slli	a3,a3,0x20
 31e:	9281                	srli	a3,a3,0x20
 320:	0685                	addi	a3,a3,1
 322:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 324:	00054783          	lbu	a5,0(a0)
 328:	0005c703          	lbu	a4,0(a1)
 32c:	00e79863          	bne	a5,a4,33c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 330:	0505                	addi	a0,a0,1
    p2++;
 332:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 334:	fed518e3          	bne	a0,a3,324 <memcmp+0x14>
  }
  return 0;
 338:	4501                	li	a0,0
 33a:	a019                	j	340 <memcmp+0x30>
      return *p1 - *p2;
 33c:	40e7853b          	subw	a0,a5,a4
}
 340:	6422                	ld	s0,8(sp)
 342:	0141                	addi	sp,sp,16
 344:	8082                	ret
  return 0;
 346:	4501                	li	a0,0
 348:	bfe5                	j	340 <memcmp+0x30>

000000000000034a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 34a:	1141                	addi	sp,sp,-16
 34c:	e406                	sd	ra,8(sp)
 34e:	e022                	sd	s0,0(sp)
 350:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 352:	f67ff0ef          	jal	2b8 <memmove>
}
 356:	60a2                	ld	ra,8(sp)
 358:	6402                	ld	s0,0(sp)
 35a:	0141                	addi	sp,sp,16
 35c:	8082                	ret

000000000000035e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 35e:	4885                	li	a7,1
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <exit>:
.global exit
exit:
 li a7, SYS_exit
 366:	4889                	li	a7,2
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <wait>:
.global wait
wait:
 li a7, SYS_wait
 36e:	488d                	li	a7,3
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 376:	4891                	li	a7,4
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <read>:
.global read
read:
 li a7, SYS_read
 37e:	4895                	li	a7,5
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <write>:
.global write
write:
 li a7, SYS_write
 386:	48c1                	li	a7,16
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <close>:
.global close
close:
 li a7, SYS_close
 38e:	48d5                	li	a7,21
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <kill>:
.global kill
kill:
 li a7, SYS_kill
 396:	4899                	li	a7,6
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <exec>:
.global exec
exec:
 li a7, SYS_exec
 39e:	489d                	li	a7,7
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <open>:
.global open
open:
 li a7, SYS_open
 3a6:	48bd                	li	a7,15
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3ae:	48c5                	li	a7,17
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3b6:	48c9                	li	a7,18
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3be:	48a1                	li	a7,8
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <link>:
.global link
link:
 li a7, SYS_link
 3c6:	48cd                	li	a7,19
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3ce:	48d1                	li	a7,20
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3d6:	48a5                	li	a7,9
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <dup>:
.global dup
dup:
 li a7, SYS_dup
 3de:	48a9                	li	a7,10
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3e6:	48ad                	li	a7,11
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3ee:	48b1                	li	a7,12
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3f6:	48b5                	li	a7,13
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3fe:	48b9                	li	a7,14
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <trigger>:
.global trigger
trigger:
 li a7, SYS_trigger
 406:	48d9                	li	a7,22
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <thread>:
.global thread
thread:
 li a7, SYS_thread
 40e:	48dd                	li	a7,23
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <jointhread>:
.global jointhread
jointhread:
 li a7, SYS_jointhread
 416:	48e1                	li	a7,24
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 41e:	1101                	addi	sp,sp,-32
 420:	ec06                	sd	ra,24(sp)
 422:	e822                	sd	s0,16(sp)
 424:	1000                	addi	s0,sp,32
 426:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 42a:	4605                	li	a2,1
 42c:	fef40593          	addi	a1,s0,-17
 430:	f57ff0ef          	jal	386 <write>
}
 434:	60e2                	ld	ra,24(sp)
 436:	6442                	ld	s0,16(sp)
 438:	6105                	addi	sp,sp,32
 43a:	8082                	ret

000000000000043c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 43c:	7139                	addi	sp,sp,-64
 43e:	fc06                	sd	ra,56(sp)
 440:	f822                	sd	s0,48(sp)
 442:	f426                	sd	s1,40(sp)
 444:	0080                	addi	s0,sp,64
 446:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 448:	c299                	beqz	a3,44e <printint+0x12>
 44a:	0805c963          	bltz	a1,4dc <printint+0xa0>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 44e:	2581                	sext.w	a1,a1
  neg = 0;
 450:	4881                	li	a7,0
 452:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 456:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 458:	2601                	sext.w	a2,a2
 45a:	00000517          	auipc	a0,0x0
 45e:	52e50513          	addi	a0,a0,1326 # 988 <digits>
 462:	883a                	mv	a6,a4
 464:	2705                	addiw	a4,a4,1
 466:	02c5f7bb          	remuw	a5,a1,a2
 46a:	1782                	slli	a5,a5,0x20
 46c:	9381                	srli	a5,a5,0x20
 46e:	97aa                	add	a5,a5,a0
 470:	0007c783          	lbu	a5,0(a5)
 474:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 478:	0005879b          	sext.w	a5,a1
 47c:	02c5d5bb          	divuw	a1,a1,a2
 480:	0685                	addi	a3,a3,1
 482:	fec7f0e3          	bgeu	a5,a2,462 <printint+0x26>
  if(neg)
 486:	00088c63          	beqz	a7,49e <printint+0x62>
    buf[i++] = '-';
 48a:	fd070793          	addi	a5,a4,-48
 48e:	00878733          	add	a4,a5,s0
 492:	02d00793          	li	a5,45
 496:	fef70823          	sb	a5,-16(a4)
 49a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 49e:	02e05a63          	blez	a4,4d2 <printint+0x96>
 4a2:	f04a                	sd	s2,32(sp)
 4a4:	ec4e                	sd	s3,24(sp)
 4a6:	fc040793          	addi	a5,s0,-64
 4aa:	00e78933          	add	s2,a5,a4
 4ae:	fff78993          	addi	s3,a5,-1
 4b2:	99ba                	add	s3,s3,a4
 4b4:	377d                	addiw	a4,a4,-1
 4b6:	1702                	slli	a4,a4,0x20
 4b8:	9301                	srli	a4,a4,0x20
 4ba:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4be:	fff94583          	lbu	a1,-1(s2)
 4c2:	8526                	mv	a0,s1
 4c4:	f5bff0ef          	jal	41e <putc>
  while(--i >= 0)
 4c8:	197d                	addi	s2,s2,-1
 4ca:	ff391ae3          	bne	s2,s3,4be <printint+0x82>
 4ce:	7902                	ld	s2,32(sp)
 4d0:	69e2                	ld	s3,24(sp)
}
 4d2:	70e2                	ld	ra,56(sp)
 4d4:	7442                	ld	s0,48(sp)
 4d6:	74a2                	ld	s1,40(sp)
 4d8:	6121                	addi	sp,sp,64
 4da:	8082                	ret
    x = -xx;
 4dc:	40b005bb          	negw	a1,a1
    neg = 1;
 4e0:	4885                	li	a7,1
    x = -xx;
 4e2:	bf85                	j	452 <printint+0x16>

00000000000004e4 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4e4:	711d                	addi	sp,sp,-96
 4e6:	ec86                	sd	ra,88(sp)
 4e8:	e8a2                	sd	s0,80(sp)
 4ea:	e0ca                	sd	s2,64(sp)
 4ec:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4ee:	0005c903          	lbu	s2,0(a1)
 4f2:	26090863          	beqz	s2,762 <vprintf+0x27e>
 4f6:	e4a6                	sd	s1,72(sp)
 4f8:	fc4e                	sd	s3,56(sp)
 4fa:	f852                	sd	s4,48(sp)
 4fc:	f456                	sd	s5,40(sp)
 4fe:	f05a                	sd	s6,32(sp)
 500:	ec5e                	sd	s7,24(sp)
 502:	e862                	sd	s8,16(sp)
 504:	e466                	sd	s9,8(sp)
 506:	8b2a                	mv	s6,a0
 508:	8a2e                	mv	s4,a1
 50a:	8bb2                	mv	s7,a2
  state = 0;
 50c:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 50e:	4481                	li	s1,0
 510:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 512:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 516:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 51a:	06c00c93          	li	s9,108
 51e:	a005                	j	53e <vprintf+0x5a>
        putc(fd, c0);
 520:	85ca                	mv	a1,s2
 522:	855a                	mv	a0,s6
 524:	efbff0ef          	jal	41e <putc>
 528:	a019                	j	52e <vprintf+0x4a>
    } else if(state == '%'){
 52a:	03598263          	beq	s3,s5,54e <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 52e:	2485                	addiw	s1,s1,1
 530:	8726                	mv	a4,s1
 532:	009a07b3          	add	a5,s4,s1
 536:	0007c903          	lbu	s2,0(a5)
 53a:	20090c63          	beqz	s2,752 <vprintf+0x26e>
    c0 = fmt[i] & 0xff;
 53e:	0009079b          	sext.w	a5,s2
    if(state == 0){
 542:	fe0994e3          	bnez	s3,52a <vprintf+0x46>
      if(c0 == '%'){
 546:	fd579de3          	bne	a5,s5,520 <vprintf+0x3c>
        state = '%';
 54a:	89be                	mv	s3,a5
 54c:	b7cd                	j	52e <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 54e:	00ea06b3          	add	a3,s4,a4
 552:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 556:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 558:	c681                	beqz	a3,560 <vprintf+0x7c>
 55a:	9752                	add	a4,a4,s4
 55c:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 560:	03878f63          	beq	a5,s8,59e <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
 564:	05978963          	beq	a5,s9,5b6 <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 568:	07500713          	li	a4,117
 56c:	0ee78363          	beq	a5,a4,652 <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 570:	07800713          	li	a4,120
 574:	12e78563          	beq	a5,a4,69e <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 578:	07000713          	li	a4,112
 57c:	14e78a63          	beq	a5,a4,6d0 <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 580:	07300713          	li	a4,115
 584:	18e78a63          	beq	a5,a4,718 <vprintf+0x234>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 588:	02500713          	li	a4,37
 58c:	04e79563          	bne	a5,a4,5d6 <vprintf+0xf2>
        putc(fd, '%');
 590:	02500593          	li	a1,37
 594:	855a                	mv	a0,s6
 596:	e89ff0ef          	jal	41e <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 59a:	4981                	li	s3,0
 59c:	bf49                	j	52e <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 59e:	008b8913          	addi	s2,s7,8
 5a2:	4685                	li	a3,1
 5a4:	4629                	li	a2,10
 5a6:	000ba583          	lw	a1,0(s7)
 5aa:	855a                	mv	a0,s6
 5ac:	e91ff0ef          	jal	43c <printint>
 5b0:	8bca                	mv	s7,s2
      state = 0;
 5b2:	4981                	li	s3,0
 5b4:	bfad                	j	52e <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 5b6:	06400793          	li	a5,100
 5ba:	02f68963          	beq	a3,a5,5ec <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5be:	06c00793          	li	a5,108
 5c2:	04f68263          	beq	a3,a5,606 <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
 5c6:	07500793          	li	a5,117
 5ca:	0af68063          	beq	a3,a5,66a <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
 5ce:	07800793          	li	a5,120
 5d2:	0ef68263          	beq	a3,a5,6b6 <vprintf+0x1d2>
        putc(fd, '%');
 5d6:	02500593          	li	a1,37
 5da:	855a                	mv	a0,s6
 5dc:	e43ff0ef          	jal	41e <putc>
        putc(fd, c0);
 5e0:	85ca                	mv	a1,s2
 5e2:	855a                	mv	a0,s6
 5e4:	e3bff0ef          	jal	41e <putc>
      state = 0;
 5e8:	4981                	li	s3,0
 5ea:	b791                	j	52e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5ec:	008b8913          	addi	s2,s7,8
 5f0:	4685                	li	a3,1
 5f2:	4629                	li	a2,10
 5f4:	000ba583          	lw	a1,0(s7)
 5f8:	855a                	mv	a0,s6
 5fa:	e43ff0ef          	jal	43c <printint>
        i += 1;
 5fe:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 600:	8bca                	mv	s7,s2
      state = 0;
 602:	4981                	li	s3,0
        i += 1;
 604:	b72d                	j	52e <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 606:	06400793          	li	a5,100
 60a:	02f60763          	beq	a2,a5,638 <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 60e:	07500793          	li	a5,117
 612:	06f60963          	beq	a2,a5,684 <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 616:	07800793          	li	a5,120
 61a:	faf61ee3          	bne	a2,a5,5d6 <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 61e:	008b8913          	addi	s2,s7,8
 622:	4681                	li	a3,0
 624:	4641                	li	a2,16
 626:	000ba583          	lw	a1,0(s7)
 62a:	855a                	mv	a0,s6
 62c:	e11ff0ef          	jal	43c <printint>
        i += 2;
 630:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 632:	8bca                	mv	s7,s2
      state = 0;
 634:	4981                	li	s3,0
        i += 2;
 636:	bde5                	j	52e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 638:	008b8913          	addi	s2,s7,8
 63c:	4685                	li	a3,1
 63e:	4629                	li	a2,10
 640:	000ba583          	lw	a1,0(s7)
 644:	855a                	mv	a0,s6
 646:	df7ff0ef          	jal	43c <printint>
        i += 2;
 64a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 64c:	8bca                	mv	s7,s2
      state = 0;
 64e:	4981                	li	s3,0
        i += 2;
 650:	bdf9                	j	52e <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
 652:	008b8913          	addi	s2,s7,8
 656:	4681                	li	a3,0
 658:	4629                	li	a2,10
 65a:	000ba583          	lw	a1,0(s7)
 65e:	855a                	mv	a0,s6
 660:	dddff0ef          	jal	43c <printint>
 664:	8bca                	mv	s7,s2
      state = 0;
 666:	4981                	li	s3,0
 668:	b5d9                	j	52e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 66a:	008b8913          	addi	s2,s7,8
 66e:	4681                	li	a3,0
 670:	4629                	li	a2,10
 672:	000ba583          	lw	a1,0(s7)
 676:	855a                	mv	a0,s6
 678:	dc5ff0ef          	jal	43c <printint>
        i += 1;
 67c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 67e:	8bca                	mv	s7,s2
      state = 0;
 680:	4981                	li	s3,0
        i += 1;
 682:	b575                	j	52e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 684:	008b8913          	addi	s2,s7,8
 688:	4681                	li	a3,0
 68a:	4629                	li	a2,10
 68c:	000ba583          	lw	a1,0(s7)
 690:	855a                	mv	a0,s6
 692:	dabff0ef          	jal	43c <printint>
        i += 2;
 696:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 698:	8bca                	mv	s7,s2
      state = 0;
 69a:	4981                	li	s3,0
        i += 2;
 69c:	bd49                	j	52e <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
 69e:	008b8913          	addi	s2,s7,8
 6a2:	4681                	li	a3,0
 6a4:	4641                	li	a2,16
 6a6:	000ba583          	lw	a1,0(s7)
 6aa:	855a                	mv	a0,s6
 6ac:	d91ff0ef          	jal	43c <printint>
 6b0:	8bca                	mv	s7,s2
      state = 0;
 6b2:	4981                	li	s3,0
 6b4:	bdad                	j	52e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6b6:	008b8913          	addi	s2,s7,8
 6ba:	4681                	li	a3,0
 6bc:	4641                	li	a2,16
 6be:	000ba583          	lw	a1,0(s7)
 6c2:	855a                	mv	a0,s6
 6c4:	d79ff0ef          	jal	43c <printint>
        i += 1;
 6c8:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6ca:	8bca                	mv	s7,s2
      state = 0;
 6cc:	4981                	li	s3,0
        i += 1;
 6ce:	b585                	j	52e <vprintf+0x4a>
 6d0:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 6d2:	008b8d13          	addi	s10,s7,8
 6d6:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6da:	03000593          	li	a1,48
 6de:	855a                	mv	a0,s6
 6e0:	d3fff0ef          	jal	41e <putc>
  putc(fd, 'x');
 6e4:	07800593          	li	a1,120
 6e8:	855a                	mv	a0,s6
 6ea:	d35ff0ef          	jal	41e <putc>
 6ee:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6f0:	00000b97          	auipc	s7,0x0
 6f4:	298b8b93          	addi	s7,s7,664 # 988 <digits>
 6f8:	03c9d793          	srli	a5,s3,0x3c
 6fc:	97de                	add	a5,a5,s7
 6fe:	0007c583          	lbu	a1,0(a5)
 702:	855a                	mv	a0,s6
 704:	d1bff0ef          	jal	41e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 708:	0992                	slli	s3,s3,0x4
 70a:	397d                	addiw	s2,s2,-1
 70c:	fe0916e3          	bnez	s2,6f8 <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
 710:	8bea                	mv	s7,s10
      state = 0;
 712:	4981                	li	s3,0
 714:	6d02                	ld	s10,0(sp)
 716:	bd21                	j	52e <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 718:	008b8993          	addi	s3,s7,8
 71c:	000bb903          	ld	s2,0(s7)
 720:	00090f63          	beqz	s2,73e <vprintf+0x25a>
        for(; *s; s++)
 724:	00094583          	lbu	a1,0(s2)
 728:	c195                	beqz	a1,74c <vprintf+0x268>
          putc(fd, *s);
 72a:	855a                	mv	a0,s6
 72c:	cf3ff0ef          	jal	41e <putc>
        for(; *s; s++)
 730:	0905                	addi	s2,s2,1
 732:	00094583          	lbu	a1,0(s2)
 736:	f9f5                	bnez	a1,72a <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 738:	8bce                	mv	s7,s3
      state = 0;
 73a:	4981                	li	s3,0
 73c:	bbcd                	j	52e <vprintf+0x4a>
          s = "(null)";
 73e:	00000917          	auipc	s2,0x0
 742:	24290913          	addi	s2,s2,578 # 980 <malloc+0x136>
        for(; *s; s++)
 746:	02800593          	li	a1,40
 74a:	b7c5                	j	72a <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 74c:	8bce                	mv	s7,s3
      state = 0;
 74e:	4981                	li	s3,0
 750:	bbf9                	j	52e <vprintf+0x4a>
 752:	64a6                	ld	s1,72(sp)
 754:	79e2                	ld	s3,56(sp)
 756:	7a42                	ld	s4,48(sp)
 758:	7aa2                	ld	s5,40(sp)
 75a:	7b02                	ld	s6,32(sp)
 75c:	6be2                	ld	s7,24(sp)
 75e:	6c42                	ld	s8,16(sp)
 760:	6ca2                	ld	s9,8(sp)
    }
  }
}
 762:	60e6                	ld	ra,88(sp)
 764:	6446                	ld	s0,80(sp)
 766:	6906                	ld	s2,64(sp)
 768:	6125                	addi	sp,sp,96
 76a:	8082                	ret

000000000000076c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 76c:	715d                	addi	sp,sp,-80
 76e:	ec06                	sd	ra,24(sp)
 770:	e822                	sd	s0,16(sp)
 772:	1000                	addi	s0,sp,32
 774:	e010                	sd	a2,0(s0)
 776:	e414                	sd	a3,8(s0)
 778:	e818                	sd	a4,16(s0)
 77a:	ec1c                	sd	a5,24(s0)
 77c:	03043023          	sd	a6,32(s0)
 780:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 784:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 788:	8622                	mv	a2,s0
 78a:	d5bff0ef          	jal	4e4 <vprintf>
}
 78e:	60e2                	ld	ra,24(sp)
 790:	6442                	ld	s0,16(sp)
 792:	6161                	addi	sp,sp,80
 794:	8082                	ret

0000000000000796 <printf>:

void
printf(const char *fmt, ...)
{
 796:	711d                	addi	sp,sp,-96
 798:	ec06                	sd	ra,24(sp)
 79a:	e822                	sd	s0,16(sp)
 79c:	1000                	addi	s0,sp,32
 79e:	e40c                	sd	a1,8(s0)
 7a0:	e810                	sd	a2,16(s0)
 7a2:	ec14                	sd	a3,24(s0)
 7a4:	f018                	sd	a4,32(s0)
 7a6:	f41c                	sd	a5,40(s0)
 7a8:	03043823          	sd	a6,48(s0)
 7ac:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7b0:	00840613          	addi	a2,s0,8
 7b4:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7b8:	85aa                	mv	a1,a0
 7ba:	4505                	li	a0,1
 7bc:	d29ff0ef          	jal	4e4 <vprintf>
}
 7c0:	60e2                	ld	ra,24(sp)
 7c2:	6442                	ld	s0,16(sp)
 7c4:	6125                	addi	sp,sp,96
 7c6:	8082                	ret

00000000000007c8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7c8:	1141                	addi	sp,sp,-16
 7ca:	e422                	sd	s0,8(sp)
 7cc:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7ce:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7d2:	00001797          	auipc	a5,0x1
 7d6:	82e7b783          	ld	a5,-2002(a5) # 1000 <freep>
 7da:	a02d                	j	804 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7dc:	4618                	lw	a4,8(a2)
 7de:	9f2d                	addw	a4,a4,a1
 7e0:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7e4:	6398                	ld	a4,0(a5)
 7e6:	6310                	ld	a2,0(a4)
 7e8:	a83d                	j	826 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7ea:	ff852703          	lw	a4,-8(a0)
 7ee:	9f31                	addw	a4,a4,a2
 7f0:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7f2:	ff053683          	ld	a3,-16(a0)
 7f6:	a091                	j	83a <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7f8:	6398                	ld	a4,0(a5)
 7fa:	00e7e463          	bltu	a5,a4,802 <free+0x3a>
 7fe:	00e6ea63          	bltu	a3,a4,812 <free+0x4a>
{
 802:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 804:	fed7fae3          	bgeu	a5,a3,7f8 <free+0x30>
 808:	6398                	ld	a4,0(a5)
 80a:	00e6e463          	bltu	a3,a4,812 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 80e:	fee7eae3          	bltu	a5,a4,802 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 812:	ff852583          	lw	a1,-8(a0)
 816:	6390                	ld	a2,0(a5)
 818:	02059813          	slli	a6,a1,0x20
 81c:	01c85713          	srli	a4,a6,0x1c
 820:	9736                	add	a4,a4,a3
 822:	fae60de3          	beq	a2,a4,7dc <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 826:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 82a:	4790                	lw	a2,8(a5)
 82c:	02061593          	slli	a1,a2,0x20
 830:	01c5d713          	srli	a4,a1,0x1c
 834:	973e                	add	a4,a4,a5
 836:	fae68ae3          	beq	a3,a4,7ea <free+0x22>
    p->s.ptr = bp->s.ptr;
 83a:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 83c:	00000717          	auipc	a4,0x0
 840:	7cf73223          	sd	a5,1988(a4) # 1000 <freep>
}
 844:	6422                	ld	s0,8(sp)
 846:	0141                	addi	sp,sp,16
 848:	8082                	ret

000000000000084a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 84a:	7139                	addi	sp,sp,-64
 84c:	fc06                	sd	ra,56(sp)
 84e:	f822                	sd	s0,48(sp)
 850:	f426                	sd	s1,40(sp)
 852:	ec4e                	sd	s3,24(sp)
 854:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 856:	02051493          	slli	s1,a0,0x20
 85a:	9081                	srli	s1,s1,0x20
 85c:	04bd                	addi	s1,s1,15
 85e:	8091                	srli	s1,s1,0x4
 860:	0014899b          	addiw	s3,s1,1
 864:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 866:	00000517          	auipc	a0,0x0
 86a:	79a53503          	ld	a0,1946(a0) # 1000 <freep>
 86e:	c915                	beqz	a0,8a2 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 870:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 872:	4798                	lw	a4,8(a5)
 874:	08977a63          	bgeu	a4,s1,908 <malloc+0xbe>
 878:	f04a                	sd	s2,32(sp)
 87a:	e852                	sd	s4,16(sp)
 87c:	e456                	sd	s5,8(sp)
 87e:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 880:	8a4e                	mv	s4,s3
 882:	0009871b          	sext.w	a4,s3
 886:	6685                	lui	a3,0x1
 888:	00d77363          	bgeu	a4,a3,88e <malloc+0x44>
 88c:	6a05                	lui	s4,0x1
 88e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 892:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 896:	00000917          	auipc	s2,0x0
 89a:	76a90913          	addi	s2,s2,1898 # 1000 <freep>
  if(p == (char*)-1)
 89e:	5afd                	li	s5,-1
 8a0:	a081                	j	8e0 <malloc+0x96>
 8a2:	f04a                	sd	s2,32(sp)
 8a4:	e852                	sd	s4,16(sp)
 8a6:	e456                	sd	s5,8(sp)
 8a8:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8aa:	00000797          	auipc	a5,0x0
 8ae:	76678793          	addi	a5,a5,1894 # 1010 <base>
 8b2:	00000717          	auipc	a4,0x0
 8b6:	74f73723          	sd	a5,1870(a4) # 1000 <freep>
 8ba:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8bc:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8c0:	b7c1                	j	880 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 8c2:	6398                	ld	a4,0(a5)
 8c4:	e118                	sd	a4,0(a0)
 8c6:	a8a9                	j	920 <malloc+0xd6>
  hp->s.size = nu;
 8c8:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8cc:	0541                	addi	a0,a0,16
 8ce:	efbff0ef          	jal	7c8 <free>
  return freep;
 8d2:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8d6:	c12d                	beqz	a0,938 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8d8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8da:	4798                	lw	a4,8(a5)
 8dc:	02977263          	bgeu	a4,s1,900 <malloc+0xb6>
    if(p == freep)
 8e0:	00093703          	ld	a4,0(s2)
 8e4:	853e                	mv	a0,a5
 8e6:	fef719e3          	bne	a4,a5,8d8 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 8ea:	8552                	mv	a0,s4
 8ec:	b03ff0ef          	jal	3ee <sbrk>
  if(p == (char*)-1)
 8f0:	fd551ce3          	bne	a0,s5,8c8 <malloc+0x7e>
        return 0;
 8f4:	4501                	li	a0,0
 8f6:	7902                	ld	s2,32(sp)
 8f8:	6a42                	ld	s4,16(sp)
 8fa:	6aa2                	ld	s5,8(sp)
 8fc:	6b02                	ld	s6,0(sp)
 8fe:	a03d                	j	92c <malloc+0xe2>
 900:	7902                	ld	s2,32(sp)
 902:	6a42                	ld	s4,16(sp)
 904:	6aa2                	ld	s5,8(sp)
 906:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 908:	fae48de3          	beq	s1,a4,8c2 <malloc+0x78>
        p->s.size -= nunits;
 90c:	4137073b          	subw	a4,a4,s3
 910:	c798                	sw	a4,8(a5)
        p += p->s.size;
 912:	02071693          	slli	a3,a4,0x20
 916:	01c6d713          	srli	a4,a3,0x1c
 91a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 91c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 920:	00000717          	auipc	a4,0x0
 924:	6ea73023          	sd	a0,1760(a4) # 1000 <freep>
      return (void*)(p + 1);
 928:	01078513          	addi	a0,a5,16
  }
}
 92c:	70e2                	ld	ra,56(sp)
 92e:	7442                	ld	s0,48(sp)
 930:	74a2                	ld	s1,40(sp)
 932:	69e2                	ld	s3,24(sp)
 934:	6121                	addi	sp,sp,64
 936:	8082                	ret
 938:	7902                	ld	s2,32(sp)
 93a:	6a42                	ld	s4,16(sp)
 93c:	6aa2                	ld	s5,8(sp)
 93e:	6b02                	ld	s6,0(sp)
 940:	b7f5                	j	92c <malloc+0xe2>
