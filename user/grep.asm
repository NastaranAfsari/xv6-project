
user/_grep:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <matchstar>:
  return 0;
}

// matchstar: search for c*re at beginning of text
int matchstar(int c, char *re, char *text)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	e052                	sd	s4,0(sp)
   e:	1800                	addi	s0,sp,48
  10:	892a                	mv	s2,a0
  12:	89ae                	mv	s3,a1
  14:	84b2                	mv	s1,a2
  do{  // a * matches zero or more instances
    if(matchhere(re, text))
      return 1;
  }while(*text!='\0' && (*text++==c || c=='.'));
  16:	02e00a13          	li	s4,46
    if(matchhere(re, text))
  1a:	85a6                	mv	a1,s1
  1c:	854e                	mv	a0,s3
  1e:	02c000ef          	jal	4a <matchhere>
  22:	e919                	bnez	a0,38 <matchstar+0x38>
  }while(*text!='\0' && (*text++==c || c=='.'));
  24:	0004c783          	lbu	a5,0(s1)
  28:	cb89                	beqz	a5,3a <matchstar+0x3a>
  2a:	0485                	addi	s1,s1,1
  2c:	2781                	sext.w	a5,a5
  2e:	ff2786e3          	beq	a5,s2,1a <matchstar+0x1a>
  32:	ff4904e3          	beq	s2,s4,1a <matchstar+0x1a>
  36:	a011                	j	3a <matchstar+0x3a>
      return 1;
  38:	4505                	li	a0,1
  return 0;
}
  3a:	70a2                	ld	ra,40(sp)
  3c:	7402                	ld	s0,32(sp)
  3e:	64e2                	ld	s1,24(sp)
  40:	6942                	ld	s2,16(sp)
  42:	69a2                	ld	s3,8(sp)
  44:	6a02                	ld	s4,0(sp)
  46:	6145                	addi	sp,sp,48
  48:	8082                	ret

000000000000004a <matchhere>:
  if(re[0] == '\0')
  4a:	00054703          	lbu	a4,0(a0)
  4e:	c73d                	beqz	a4,bc <matchhere+0x72>
{
  50:	1141                	addi	sp,sp,-16
  52:	e406                	sd	ra,8(sp)
  54:	e022                	sd	s0,0(sp)
  56:	0800                	addi	s0,sp,16
  58:	87aa                	mv	a5,a0
  if(re[1] == '*')
  5a:	00154683          	lbu	a3,1(a0)
  5e:	02a00613          	li	a2,42
  62:	02c68563          	beq	a3,a2,8c <matchhere+0x42>
  if(re[0] == '$' && re[1] == '\0')
  66:	02400613          	li	a2,36
  6a:	02c70863          	beq	a4,a2,9a <matchhere+0x50>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  6e:	0005c683          	lbu	a3,0(a1)
  return 0;
  72:	4501                	li	a0,0
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  74:	ca81                	beqz	a3,84 <matchhere+0x3a>
  76:	02e00613          	li	a2,46
  7a:	02c70b63          	beq	a4,a2,b0 <matchhere+0x66>
  return 0;
  7e:	4501                	li	a0,0
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  80:	02d70863          	beq	a4,a3,b0 <matchhere+0x66>
}
  84:	60a2                	ld	ra,8(sp)
  86:	6402                	ld	s0,0(sp)
  88:	0141                	addi	sp,sp,16
  8a:	8082                	ret
    return matchstar(re[0], re+2, text);
  8c:	862e                	mv	a2,a1
  8e:	00250593          	addi	a1,a0,2
  92:	853a                	mv	a0,a4
  94:	f6dff0ef          	jal	0 <matchstar>
  98:	b7f5                	j	84 <matchhere+0x3a>
  if(re[0] == '$' && re[1] == '\0')
  9a:	c691                	beqz	a3,a6 <matchhere+0x5c>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  9c:	0005c683          	lbu	a3,0(a1)
  a0:	fef9                	bnez	a3,7e <matchhere+0x34>
  return 0;
  a2:	4501                	li	a0,0
  a4:	b7c5                	j	84 <matchhere+0x3a>
    return *text == '\0';
  a6:	0005c503          	lbu	a0,0(a1)
  aa:	00153513          	seqz	a0,a0
  ae:	bfd9                	j	84 <matchhere+0x3a>
    return matchhere(re+1, text+1);
  b0:	0585                	addi	a1,a1,1
  b2:	00178513          	addi	a0,a5,1
  b6:	f95ff0ef          	jal	4a <matchhere>
  ba:	b7e9                	j	84 <matchhere+0x3a>
    return 1;
  bc:	4505                	li	a0,1
}
  be:	8082                	ret

00000000000000c0 <match>:
{
  c0:	1101                	addi	sp,sp,-32
  c2:	ec06                	sd	ra,24(sp)
  c4:	e822                	sd	s0,16(sp)
  c6:	e426                	sd	s1,8(sp)
  c8:	e04a                	sd	s2,0(sp)
  ca:	1000                	addi	s0,sp,32
  cc:	892a                	mv	s2,a0
  ce:	84ae                	mv	s1,a1
  if(re[0] == '^')
  d0:	00054703          	lbu	a4,0(a0)
  d4:	05e00793          	li	a5,94
  d8:	00f70c63          	beq	a4,a5,f0 <match+0x30>
    if(matchhere(re, text))
  dc:	85a6                	mv	a1,s1
  de:	854a                	mv	a0,s2
  e0:	f6bff0ef          	jal	4a <matchhere>
  e4:	e911                	bnez	a0,f8 <match+0x38>
  }while(*text++ != '\0');
  e6:	0485                	addi	s1,s1,1
  e8:	fff4c783          	lbu	a5,-1(s1)
  ec:	fbe5                	bnez	a5,dc <match+0x1c>
  ee:	a031                	j	fa <match+0x3a>
    return matchhere(re+1, text);
  f0:	0505                	addi	a0,a0,1
  f2:	f59ff0ef          	jal	4a <matchhere>
  f6:	a011                	j	fa <match+0x3a>
      return 1;
  f8:	4505                	li	a0,1
}
  fa:	60e2                	ld	ra,24(sp)
  fc:	6442                	ld	s0,16(sp)
  fe:	64a2                	ld	s1,8(sp)
 100:	6902                	ld	s2,0(sp)
 102:	6105                	addi	sp,sp,32
 104:	8082                	ret

0000000000000106 <grep>:
{
 106:	715d                	addi	sp,sp,-80
 108:	e486                	sd	ra,72(sp)
 10a:	e0a2                	sd	s0,64(sp)
 10c:	fc26                	sd	s1,56(sp)
 10e:	f84a                	sd	s2,48(sp)
 110:	f44e                	sd	s3,40(sp)
 112:	f052                	sd	s4,32(sp)
 114:	ec56                	sd	s5,24(sp)
 116:	e85a                	sd	s6,16(sp)
 118:	e45e                	sd	s7,8(sp)
 11a:	e062                	sd	s8,0(sp)
 11c:	0880                	addi	s0,sp,80
 11e:	89aa                	mv	s3,a0
 120:	8b2e                	mv	s6,a1
  m = 0;
 122:	4a01                	li	s4,0
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
 124:	3ff00b93          	li	s7,1023
 128:	00001a97          	auipc	s5,0x1
 12c:	ee8a8a93          	addi	s5,s5,-280 # 1010 <buf>
 130:	a835                	j	16c <grep+0x66>
      p = q+1;
 132:	00148913          	addi	s2,s1,1
    while((q = strchr(p, '\n')) != 0){
 136:	45a9                	li	a1,10
 138:	854a                	mv	a0,s2
 13a:	1c6000ef          	jal	300 <strchr>
 13e:	84aa                	mv	s1,a0
 140:	c505                	beqz	a0,168 <grep+0x62>
      *q = 0;
 142:	00048023          	sb	zero,0(s1)
      if(match(pattern, p)){
 146:	85ca                	mv	a1,s2
 148:	854e                	mv	a0,s3
 14a:	f77ff0ef          	jal	c0 <match>
 14e:	d175                	beqz	a0,132 <grep+0x2c>
        *q = '\n';
 150:	47a9                	li	a5,10
 152:	00f48023          	sb	a5,0(s1)
        write(1, p, q+1 - p);
 156:	00148613          	addi	a2,s1,1
 15a:	4126063b          	subw	a2,a2,s2
 15e:	85ca                	mv	a1,s2
 160:	4505                	li	a0,1
 162:	382000ef          	jal	4e4 <write>
 166:	b7f1                	j	132 <grep+0x2c>
    if(m > 0){
 168:	03404563          	bgtz	s4,192 <grep+0x8c>
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
 16c:	414b863b          	subw	a2,s7,s4
 170:	014a85b3          	add	a1,s5,s4
 174:	855a                	mv	a0,s6
 176:	366000ef          	jal	4dc <read>
 17a:	02a05963          	blez	a0,1ac <grep+0xa6>
    m += n;
 17e:	00aa0c3b          	addw	s8,s4,a0
 182:	000c0a1b          	sext.w	s4,s8
    buf[m] = '\0';
 186:	014a87b3          	add	a5,s5,s4
 18a:	00078023          	sb	zero,0(a5)
    p = buf;
 18e:	8956                	mv	s2,s5
    while((q = strchr(p, '\n')) != 0){
 190:	b75d                	j	136 <grep+0x30>
      m -= p - buf;
 192:	00001517          	auipc	a0,0x1
 196:	e7e50513          	addi	a0,a0,-386 # 1010 <buf>
 19a:	40a90a33          	sub	s4,s2,a0
 19e:	414c0a3b          	subw	s4,s8,s4
      memmove(buf, p, m);
 1a2:	8652                	mv	a2,s4
 1a4:	85ca                	mv	a1,s2
 1a6:	270000ef          	jal	416 <memmove>
 1aa:	b7c9                	j	16c <grep+0x66>
}
 1ac:	60a6                	ld	ra,72(sp)
 1ae:	6406                	ld	s0,64(sp)
 1b0:	74e2                	ld	s1,56(sp)
 1b2:	7942                	ld	s2,48(sp)
 1b4:	79a2                	ld	s3,40(sp)
 1b6:	7a02                	ld	s4,32(sp)
 1b8:	6ae2                	ld	s5,24(sp)
 1ba:	6b42                	ld	s6,16(sp)
 1bc:	6ba2                	ld	s7,8(sp)
 1be:	6c02                	ld	s8,0(sp)
 1c0:	6161                	addi	sp,sp,80
 1c2:	8082                	ret

00000000000001c4 <main>:
{
 1c4:	7179                	addi	sp,sp,-48
 1c6:	f406                	sd	ra,40(sp)
 1c8:	f022                	sd	s0,32(sp)
 1ca:	ec26                	sd	s1,24(sp)
 1cc:	e84a                	sd	s2,16(sp)
 1ce:	e44e                	sd	s3,8(sp)
 1d0:	e052                	sd	s4,0(sp)
 1d2:	1800                	addi	s0,sp,48
  if(argc <= 1){
 1d4:	4785                	li	a5,1
 1d6:	04a7d663          	bge	a5,a0,222 <main+0x5e>
  pattern = argv[1];
 1da:	0085ba03          	ld	s4,8(a1)
  if(argc <= 2){
 1de:	4789                	li	a5,2
 1e0:	04a7db63          	bge	a5,a0,236 <main+0x72>
 1e4:	01058913          	addi	s2,a1,16
 1e8:	ffd5099b          	addiw	s3,a0,-3
 1ec:	02099793          	slli	a5,s3,0x20
 1f0:	01d7d993          	srli	s3,a5,0x1d
 1f4:	05e1                	addi	a1,a1,24
 1f6:	99ae                	add	s3,s3,a1
    if((fd = open(argv[i], O_RDONLY)) < 0){
 1f8:	4581                	li	a1,0
 1fa:	00093503          	ld	a0,0(s2)
 1fe:	306000ef          	jal	504 <open>
 202:	84aa                	mv	s1,a0
 204:	04054063          	bltz	a0,244 <main+0x80>
    grep(pattern, fd);
 208:	85aa                	mv	a1,a0
 20a:	8552                	mv	a0,s4
 20c:	efbff0ef          	jal	106 <grep>
    close(fd);
 210:	8526                	mv	a0,s1
 212:	2da000ef          	jal	4ec <close>
  for(i = 2; i < argc; i++){
 216:	0921                	addi	s2,s2,8
 218:	ff3910e3          	bne	s2,s3,1f8 <main+0x34>
  exit(0);
 21c:	4501                	li	a0,0
 21e:	2a6000ef          	jal	4c4 <exit>
    fprintf(2, "usage: grep pattern [file ...]\n");
 222:	00001597          	auipc	a1,0x1
 226:	88e58593          	addi	a1,a1,-1906 # ab0 <malloc+0x100>
 22a:	4509                	li	a0,2
 22c:	6a6000ef          	jal	8d2 <fprintf>
    exit(1);
 230:	4505                	li	a0,1
 232:	292000ef          	jal	4c4 <exit>
    grep(pattern, 0);
 236:	4581                	li	a1,0
 238:	8552                	mv	a0,s4
 23a:	ecdff0ef          	jal	106 <grep>
    exit(0);
 23e:	4501                	li	a0,0
 240:	284000ef          	jal	4c4 <exit>
      printf("grep: cannot open %s\n", argv[i]);
 244:	00093583          	ld	a1,0(s2)
 248:	00001517          	auipc	a0,0x1
 24c:	88850513          	addi	a0,a0,-1912 # ad0 <malloc+0x120>
 250:	6ac000ef          	jal	8fc <printf>
      exit(1);
 254:	4505                	li	a0,1
 256:	26e000ef          	jal	4c4 <exit>

000000000000025a <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
 25a:	1141                	addi	sp,sp,-16
 25c:	e406                	sd	ra,8(sp)
 25e:	e022                	sd	s0,0(sp)
 260:	0800                	addi	s0,sp,16
  extern int main();
  main();
 262:	f63ff0ef          	jal	1c4 <main>
  exit(0);
 266:	4501                	li	a0,0
 268:	25c000ef          	jal	4c4 <exit>

000000000000026c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 26c:	1141                	addi	sp,sp,-16
 26e:	e422                	sd	s0,8(sp)
 270:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 272:	87aa                	mv	a5,a0
 274:	0585                	addi	a1,a1,1
 276:	0785                	addi	a5,a5,1
 278:	fff5c703          	lbu	a4,-1(a1)
 27c:	fee78fa3          	sb	a4,-1(a5)
 280:	fb75                	bnez	a4,274 <strcpy+0x8>
    ;
  return os;
}
 282:	6422                	ld	s0,8(sp)
 284:	0141                	addi	sp,sp,16
 286:	8082                	ret

0000000000000288 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 288:	1141                	addi	sp,sp,-16
 28a:	e422                	sd	s0,8(sp)
 28c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 28e:	00054783          	lbu	a5,0(a0)
 292:	cb91                	beqz	a5,2a6 <strcmp+0x1e>
 294:	0005c703          	lbu	a4,0(a1)
 298:	00f71763          	bne	a4,a5,2a6 <strcmp+0x1e>
    p++, q++;
 29c:	0505                	addi	a0,a0,1
 29e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 2a0:	00054783          	lbu	a5,0(a0)
 2a4:	fbe5                	bnez	a5,294 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 2a6:	0005c503          	lbu	a0,0(a1)
}
 2aa:	40a7853b          	subw	a0,a5,a0
 2ae:	6422                	ld	s0,8(sp)
 2b0:	0141                	addi	sp,sp,16
 2b2:	8082                	ret

00000000000002b4 <strlen>:

uint
strlen(const char *s)
{
 2b4:	1141                	addi	sp,sp,-16
 2b6:	e422                	sd	s0,8(sp)
 2b8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 2ba:	00054783          	lbu	a5,0(a0)
 2be:	cf91                	beqz	a5,2da <strlen+0x26>
 2c0:	0505                	addi	a0,a0,1
 2c2:	87aa                	mv	a5,a0
 2c4:	86be                	mv	a3,a5
 2c6:	0785                	addi	a5,a5,1
 2c8:	fff7c703          	lbu	a4,-1(a5)
 2cc:	ff65                	bnez	a4,2c4 <strlen+0x10>
 2ce:	40a6853b          	subw	a0,a3,a0
 2d2:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 2d4:	6422                	ld	s0,8(sp)
 2d6:	0141                	addi	sp,sp,16
 2d8:	8082                	ret
  for(n = 0; s[n]; n++)
 2da:	4501                	li	a0,0
 2dc:	bfe5                	j	2d4 <strlen+0x20>

00000000000002de <memset>:

void*
memset(void *dst, int c, uint n)
{
 2de:	1141                	addi	sp,sp,-16
 2e0:	e422                	sd	s0,8(sp)
 2e2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2e4:	ca19                	beqz	a2,2fa <memset+0x1c>
 2e6:	87aa                	mv	a5,a0
 2e8:	1602                	slli	a2,a2,0x20
 2ea:	9201                	srli	a2,a2,0x20
 2ec:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 2f0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 2f4:	0785                	addi	a5,a5,1
 2f6:	fee79de3          	bne	a5,a4,2f0 <memset+0x12>
  }
  return dst;
}
 2fa:	6422                	ld	s0,8(sp)
 2fc:	0141                	addi	sp,sp,16
 2fe:	8082                	ret

0000000000000300 <strchr>:

char*
strchr(const char *s, char c)
{
 300:	1141                	addi	sp,sp,-16
 302:	e422                	sd	s0,8(sp)
 304:	0800                	addi	s0,sp,16
  for(; *s; s++)
 306:	00054783          	lbu	a5,0(a0)
 30a:	cb99                	beqz	a5,320 <strchr+0x20>
    if(*s == c)
 30c:	00f58763          	beq	a1,a5,31a <strchr+0x1a>
  for(; *s; s++)
 310:	0505                	addi	a0,a0,1
 312:	00054783          	lbu	a5,0(a0)
 316:	fbfd                	bnez	a5,30c <strchr+0xc>
      return (char*)s;
  return 0;
 318:	4501                	li	a0,0
}
 31a:	6422                	ld	s0,8(sp)
 31c:	0141                	addi	sp,sp,16
 31e:	8082                	ret
  return 0;
 320:	4501                	li	a0,0
 322:	bfe5                	j	31a <strchr+0x1a>

0000000000000324 <gets>:

char*
gets(char *buf, int max)
{
 324:	711d                	addi	sp,sp,-96
 326:	ec86                	sd	ra,88(sp)
 328:	e8a2                	sd	s0,80(sp)
 32a:	e4a6                	sd	s1,72(sp)
 32c:	e0ca                	sd	s2,64(sp)
 32e:	fc4e                	sd	s3,56(sp)
 330:	f852                	sd	s4,48(sp)
 332:	f456                	sd	s5,40(sp)
 334:	f05a                	sd	s6,32(sp)
 336:	ec5e                	sd	s7,24(sp)
 338:	1080                	addi	s0,sp,96
 33a:	8baa                	mv	s7,a0
 33c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 33e:	892a                	mv	s2,a0
 340:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 342:	4aa9                	li	s5,10
 344:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 346:	89a6                	mv	s3,s1
 348:	2485                	addiw	s1,s1,1
 34a:	0344d663          	bge	s1,s4,376 <gets+0x52>
    cc = read(0, &c, 1);
 34e:	4605                	li	a2,1
 350:	faf40593          	addi	a1,s0,-81
 354:	4501                	li	a0,0
 356:	186000ef          	jal	4dc <read>
    if(cc < 1)
 35a:	00a05e63          	blez	a0,376 <gets+0x52>
    buf[i++] = c;
 35e:	faf44783          	lbu	a5,-81(s0)
 362:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 366:	01578763          	beq	a5,s5,374 <gets+0x50>
 36a:	0905                	addi	s2,s2,1
 36c:	fd679de3          	bne	a5,s6,346 <gets+0x22>
    buf[i++] = c;
 370:	89a6                	mv	s3,s1
 372:	a011                	j	376 <gets+0x52>
 374:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 376:	99de                	add	s3,s3,s7
 378:	00098023          	sb	zero,0(s3)
  return buf;
}
 37c:	855e                	mv	a0,s7
 37e:	60e6                	ld	ra,88(sp)
 380:	6446                	ld	s0,80(sp)
 382:	64a6                	ld	s1,72(sp)
 384:	6906                	ld	s2,64(sp)
 386:	79e2                	ld	s3,56(sp)
 388:	7a42                	ld	s4,48(sp)
 38a:	7aa2                	ld	s5,40(sp)
 38c:	7b02                	ld	s6,32(sp)
 38e:	6be2                	ld	s7,24(sp)
 390:	6125                	addi	sp,sp,96
 392:	8082                	ret

0000000000000394 <stat>:

int
stat(const char *n, struct stat *st)
{
 394:	1101                	addi	sp,sp,-32
 396:	ec06                	sd	ra,24(sp)
 398:	e822                	sd	s0,16(sp)
 39a:	e04a                	sd	s2,0(sp)
 39c:	1000                	addi	s0,sp,32
 39e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3a0:	4581                	li	a1,0
 3a2:	162000ef          	jal	504 <open>
  if(fd < 0)
 3a6:	02054263          	bltz	a0,3ca <stat+0x36>
 3aa:	e426                	sd	s1,8(sp)
 3ac:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3ae:	85ca                	mv	a1,s2
 3b0:	16c000ef          	jal	51c <fstat>
 3b4:	892a                	mv	s2,a0
  close(fd);
 3b6:	8526                	mv	a0,s1
 3b8:	134000ef          	jal	4ec <close>
  return r;
 3bc:	64a2                	ld	s1,8(sp)
}
 3be:	854a                	mv	a0,s2
 3c0:	60e2                	ld	ra,24(sp)
 3c2:	6442                	ld	s0,16(sp)
 3c4:	6902                	ld	s2,0(sp)
 3c6:	6105                	addi	sp,sp,32
 3c8:	8082                	ret
    return -1;
 3ca:	597d                	li	s2,-1
 3cc:	bfcd                	j	3be <stat+0x2a>

00000000000003ce <atoi>:

int
atoi(const char *s)
{
 3ce:	1141                	addi	sp,sp,-16
 3d0:	e422                	sd	s0,8(sp)
 3d2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3d4:	00054683          	lbu	a3,0(a0)
 3d8:	fd06879b          	addiw	a5,a3,-48
 3dc:	0ff7f793          	zext.b	a5,a5
 3e0:	4625                	li	a2,9
 3e2:	02f66863          	bltu	a2,a5,412 <atoi+0x44>
 3e6:	872a                	mv	a4,a0
  n = 0;
 3e8:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 3ea:	0705                	addi	a4,a4,1
 3ec:	0025179b          	slliw	a5,a0,0x2
 3f0:	9fa9                	addw	a5,a5,a0
 3f2:	0017979b          	slliw	a5,a5,0x1
 3f6:	9fb5                	addw	a5,a5,a3
 3f8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3fc:	00074683          	lbu	a3,0(a4)
 400:	fd06879b          	addiw	a5,a3,-48
 404:	0ff7f793          	zext.b	a5,a5
 408:	fef671e3          	bgeu	a2,a5,3ea <atoi+0x1c>
  return n;
}
 40c:	6422                	ld	s0,8(sp)
 40e:	0141                	addi	sp,sp,16
 410:	8082                	ret
  n = 0;
 412:	4501                	li	a0,0
 414:	bfe5                	j	40c <atoi+0x3e>

0000000000000416 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 416:	1141                	addi	sp,sp,-16
 418:	e422                	sd	s0,8(sp)
 41a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 41c:	02b57463          	bgeu	a0,a1,444 <memmove+0x2e>
    while(n-- > 0)
 420:	00c05f63          	blez	a2,43e <memmove+0x28>
 424:	1602                	slli	a2,a2,0x20
 426:	9201                	srli	a2,a2,0x20
 428:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 42c:	872a                	mv	a4,a0
      *dst++ = *src++;
 42e:	0585                	addi	a1,a1,1
 430:	0705                	addi	a4,a4,1
 432:	fff5c683          	lbu	a3,-1(a1)
 436:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 43a:	fef71ae3          	bne	a4,a5,42e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 43e:	6422                	ld	s0,8(sp)
 440:	0141                	addi	sp,sp,16
 442:	8082                	ret
    dst += n;
 444:	00c50733          	add	a4,a0,a2
    src += n;
 448:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 44a:	fec05ae3          	blez	a2,43e <memmove+0x28>
 44e:	fff6079b          	addiw	a5,a2,-1
 452:	1782                	slli	a5,a5,0x20
 454:	9381                	srli	a5,a5,0x20
 456:	fff7c793          	not	a5,a5
 45a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 45c:	15fd                	addi	a1,a1,-1
 45e:	177d                	addi	a4,a4,-1
 460:	0005c683          	lbu	a3,0(a1)
 464:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 468:	fee79ae3          	bne	a5,a4,45c <memmove+0x46>
 46c:	bfc9                	j	43e <memmove+0x28>

000000000000046e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 46e:	1141                	addi	sp,sp,-16
 470:	e422                	sd	s0,8(sp)
 472:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 474:	ca05                	beqz	a2,4a4 <memcmp+0x36>
 476:	fff6069b          	addiw	a3,a2,-1
 47a:	1682                	slli	a3,a3,0x20
 47c:	9281                	srli	a3,a3,0x20
 47e:	0685                	addi	a3,a3,1
 480:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 482:	00054783          	lbu	a5,0(a0)
 486:	0005c703          	lbu	a4,0(a1)
 48a:	00e79863          	bne	a5,a4,49a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 48e:	0505                	addi	a0,a0,1
    p2++;
 490:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 492:	fed518e3          	bne	a0,a3,482 <memcmp+0x14>
  }
  return 0;
 496:	4501                	li	a0,0
 498:	a019                	j	49e <memcmp+0x30>
      return *p1 - *p2;
 49a:	40e7853b          	subw	a0,a5,a4
}
 49e:	6422                	ld	s0,8(sp)
 4a0:	0141                	addi	sp,sp,16
 4a2:	8082                	ret
  return 0;
 4a4:	4501                	li	a0,0
 4a6:	bfe5                	j	49e <memcmp+0x30>

00000000000004a8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4a8:	1141                	addi	sp,sp,-16
 4aa:	e406                	sd	ra,8(sp)
 4ac:	e022                	sd	s0,0(sp)
 4ae:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4b0:	f67ff0ef          	jal	416 <memmove>
}
 4b4:	60a2                	ld	ra,8(sp)
 4b6:	6402                	ld	s0,0(sp)
 4b8:	0141                	addi	sp,sp,16
 4ba:	8082                	ret

00000000000004bc <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4bc:	4885                	li	a7,1
 ecall
 4be:	00000073          	ecall
 ret
 4c2:	8082                	ret

00000000000004c4 <exit>:
.global exit
exit:
 li a7, SYS_exit
 4c4:	4889                	li	a7,2
 ecall
 4c6:	00000073          	ecall
 ret
 4ca:	8082                	ret

00000000000004cc <wait>:
.global wait
wait:
 li a7, SYS_wait
 4cc:	488d                	li	a7,3
 ecall
 4ce:	00000073          	ecall
 ret
 4d2:	8082                	ret

00000000000004d4 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4d4:	4891                	li	a7,4
 ecall
 4d6:	00000073          	ecall
 ret
 4da:	8082                	ret

00000000000004dc <read>:
.global read
read:
 li a7, SYS_read
 4dc:	4895                	li	a7,5
 ecall
 4de:	00000073          	ecall
 ret
 4e2:	8082                	ret

00000000000004e4 <write>:
.global write
write:
 li a7, SYS_write
 4e4:	48c1                	li	a7,16
 ecall
 4e6:	00000073          	ecall
 ret
 4ea:	8082                	ret

00000000000004ec <close>:
.global close
close:
 li a7, SYS_close
 4ec:	48d5                	li	a7,21
 ecall
 4ee:	00000073          	ecall
 ret
 4f2:	8082                	ret

00000000000004f4 <kill>:
.global kill
kill:
 li a7, SYS_kill
 4f4:	4899                	li	a7,6
 ecall
 4f6:	00000073          	ecall
 ret
 4fa:	8082                	ret

00000000000004fc <exec>:
.global exec
exec:
 li a7, SYS_exec
 4fc:	489d                	li	a7,7
 ecall
 4fe:	00000073          	ecall
 ret
 502:	8082                	ret

0000000000000504 <open>:
.global open
open:
 li a7, SYS_open
 504:	48bd                	li	a7,15
 ecall
 506:	00000073          	ecall
 ret
 50a:	8082                	ret

000000000000050c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 50c:	48c5                	li	a7,17
 ecall
 50e:	00000073          	ecall
 ret
 512:	8082                	ret

0000000000000514 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 514:	48c9                	li	a7,18
 ecall
 516:	00000073          	ecall
 ret
 51a:	8082                	ret

000000000000051c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 51c:	48a1                	li	a7,8
 ecall
 51e:	00000073          	ecall
 ret
 522:	8082                	ret

0000000000000524 <link>:
.global link
link:
 li a7, SYS_link
 524:	48cd                	li	a7,19
 ecall
 526:	00000073          	ecall
 ret
 52a:	8082                	ret

000000000000052c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 52c:	48d1                	li	a7,20
 ecall
 52e:	00000073          	ecall
 ret
 532:	8082                	ret

0000000000000534 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 534:	48a5                	li	a7,9
 ecall
 536:	00000073          	ecall
 ret
 53a:	8082                	ret

000000000000053c <dup>:
.global dup
dup:
 li a7, SYS_dup
 53c:	48a9                	li	a7,10
 ecall
 53e:	00000073          	ecall
 ret
 542:	8082                	ret

0000000000000544 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 544:	48ad                	li	a7,11
 ecall
 546:	00000073          	ecall
 ret
 54a:	8082                	ret

000000000000054c <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 54c:	48b1                	li	a7,12
 ecall
 54e:	00000073          	ecall
 ret
 552:	8082                	ret

0000000000000554 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 554:	48b5                	li	a7,13
 ecall
 556:	00000073          	ecall
 ret
 55a:	8082                	ret

000000000000055c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 55c:	48b9                	li	a7,14
 ecall
 55e:	00000073          	ecall
 ret
 562:	8082                	ret

0000000000000564 <trigger>:
.global trigger
trigger:
 li a7, SYS_trigger
 564:	48d9                	li	a7,22
 ecall
 566:	00000073          	ecall
 ret
 56a:	8082                	ret

000000000000056c <thread>:
.global thread
thread:
 li a7, SYS_thread
 56c:	48dd                	li	a7,23
 ecall
 56e:	00000073          	ecall
 ret
 572:	8082                	ret

0000000000000574 <jointhread>:
.global jointhread
jointhread:
 li a7, SYS_jointhread
 574:	48e1                	li	a7,24
 ecall
 576:	00000073          	ecall
 ret
 57a:	8082                	ret

000000000000057c <yield>:
.global yield
yield:
 li a7, SYS_yield
 57c:	48e5                	li	a7,25
 ecall
 57e:	00000073          	ecall
 ret
 582:	8082                	ret

0000000000000584 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 584:	1101                	addi	sp,sp,-32
 586:	ec06                	sd	ra,24(sp)
 588:	e822                	sd	s0,16(sp)
 58a:	1000                	addi	s0,sp,32
 58c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 590:	4605                	li	a2,1
 592:	fef40593          	addi	a1,s0,-17
 596:	f4fff0ef          	jal	4e4 <write>
}
 59a:	60e2                	ld	ra,24(sp)
 59c:	6442                	ld	s0,16(sp)
 59e:	6105                	addi	sp,sp,32
 5a0:	8082                	ret

00000000000005a2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5a2:	7139                	addi	sp,sp,-64
 5a4:	fc06                	sd	ra,56(sp)
 5a6:	f822                	sd	s0,48(sp)
 5a8:	f426                	sd	s1,40(sp)
 5aa:	0080                	addi	s0,sp,64
 5ac:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 5ae:	c299                	beqz	a3,5b4 <printint+0x12>
 5b0:	0805c963          	bltz	a1,642 <printint+0xa0>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 5b4:	2581                	sext.w	a1,a1
  neg = 0;
 5b6:	4881                	li	a7,0
 5b8:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 5bc:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 5be:	2601                	sext.w	a2,a2
 5c0:	00000517          	auipc	a0,0x0
 5c4:	53050513          	addi	a0,a0,1328 # af0 <digits>
 5c8:	883a                	mv	a6,a4
 5ca:	2705                	addiw	a4,a4,1
 5cc:	02c5f7bb          	remuw	a5,a1,a2
 5d0:	1782                	slli	a5,a5,0x20
 5d2:	9381                	srli	a5,a5,0x20
 5d4:	97aa                	add	a5,a5,a0
 5d6:	0007c783          	lbu	a5,0(a5)
 5da:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 5de:	0005879b          	sext.w	a5,a1
 5e2:	02c5d5bb          	divuw	a1,a1,a2
 5e6:	0685                	addi	a3,a3,1
 5e8:	fec7f0e3          	bgeu	a5,a2,5c8 <printint+0x26>
  if(neg)
 5ec:	00088c63          	beqz	a7,604 <printint+0x62>
    buf[i++] = '-';
 5f0:	fd070793          	addi	a5,a4,-48
 5f4:	00878733          	add	a4,a5,s0
 5f8:	02d00793          	li	a5,45
 5fc:	fef70823          	sb	a5,-16(a4)
 600:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 604:	02e05a63          	blez	a4,638 <printint+0x96>
 608:	f04a                	sd	s2,32(sp)
 60a:	ec4e                	sd	s3,24(sp)
 60c:	fc040793          	addi	a5,s0,-64
 610:	00e78933          	add	s2,a5,a4
 614:	fff78993          	addi	s3,a5,-1
 618:	99ba                	add	s3,s3,a4
 61a:	377d                	addiw	a4,a4,-1
 61c:	1702                	slli	a4,a4,0x20
 61e:	9301                	srli	a4,a4,0x20
 620:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 624:	fff94583          	lbu	a1,-1(s2)
 628:	8526                	mv	a0,s1
 62a:	f5bff0ef          	jal	584 <putc>
  while(--i >= 0)
 62e:	197d                	addi	s2,s2,-1
 630:	ff391ae3          	bne	s2,s3,624 <printint+0x82>
 634:	7902                	ld	s2,32(sp)
 636:	69e2                	ld	s3,24(sp)
}
 638:	70e2                	ld	ra,56(sp)
 63a:	7442                	ld	s0,48(sp)
 63c:	74a2                	ld	s1,40(sp)
 63e:	6121                	addi	sp,sp,64
 640:	8082                	ret
    x = -xx;
 642:	40b005bb          	negw	a1,a1
    neg = 1;
 646:	4885                	li	a7,1
    x = -xx;
 648:	bf85                	j	5b8 <printint+0x16>

000000000000064a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 64a:	711d                	addi	sp,sp,-96
 64c:	ec86                	sd	ra,88(sp)
 64e:	e8a2                	sd	s0,80(sp)
 650:	e0ca                	sd	s2,64(sp)
 652:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 654:	0005c903          	lbu	s2,0(a1)
 658:	26090863          	beqz	s2,8c8 <vprintf+0x27e>
 65c:	e4a6                	sd	s1,72(sp)
 65e:	fc4e                	sd	s3,56(sp)
 660:	f852                	sd	s4,48(sp)
 662:	f456                	sd	s5,40(sp)
 664:	f05a                	sd	s6,32(sp)
 666:	ec5e                	sd	s7,24(sp)
 668:	e862                	sd	s8,16(sp)
 66a:	e466                	sd	s9,8(sp)
 66c:	8b2a                	mv	s6,a0
 66e:	8a2e                	mv	s4,a1
 670:	8bb2                	mv	s7,a2
  state = 0;
 672:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 674:	4481                	li	s1,0
 676:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 678:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 67c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 680:	06c00c93          	li	s9,108
 684:	a005                	j	6a4 <vprintf+0x5a>
        putc(fd, c0);
 686:	85ca                	mv	a1,s2
 688:	855a                	mv	a0,s6
 68a:	efbff0ef          	jal	584 <putc>
 68e:	a019                	j	694 <vprintf+0x4a>
    } else if(state == '%'){
 690:	03598263          	beq	s3,s5,6b4 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 694:	2485                	addiw	s1,s1,1
 696:	8726                	mv	a4,s1
 698:	009a07b3          	add	a5,s4,s1
 69c:	0007c903          	lbu	s2,0(a5)
 6a0:	20090c63          	beqz	s2,8b8 <vprintf+0x26e>
    c0 = fmt[i] & 0xff;
 6a4:	0009079b          	sext.w	a5,s2
    if(state == 0){
 6a8:	fe0994e3          	bnez	s3,690 <vprintf+0x46>
      if(c0 == '%'){
 6ac:	fd579de3          	bne	a5,s5,686 <vprintf+0x3c>
        state = '%';
 6b0:	89be                	mv	s3,a5
 6b2:	b7cd                	j	694 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 6b4:	00ea06b3          	add	a3,s4,a4
 6b8:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 6bc:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 6be:	c681                	beqz	a3,6c6 <vprintf+0x7c>
 6c0:	9752                	add	a4,a4,s4
 6c2:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 6c6:	03878f63          	beq	a5,s8,704 <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
 6ca:	05978963          	beq	a5,s9,71c <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 6ce:	07500713          	li	a4,117
 6d2:	0ee78363          	beq	a5,a4,7b8 <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 6d6:	07800713          	li	a4,120
 6da:	12e78563          	beq	a5,a4,804 <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 6de:	07000713          	li	a4,112
 6e2:	14e78a63          	beq	a5,a4,836 <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 6e6:	07300713          	li	a4,115
 6ea:	18e78a63          	beq	a5,a4,87e <vprintf+0x234>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 6ee:	02500713          	li	a4,37
 6f2:	04e79563          	bne	a5,a4,73c <vprintf+0xf2>
        putc(fd, '%');
 6f6:	02500593          	li	a1,37
 6fa:	855a                	mv	a0,s6
 6fc:	e89ff0ef          	jal	584 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 700:	4981                	li	s3,0
 702:	bf49                	j	694 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 704:	008b8913          	addi	s2,s7,8
 708:	4685                	li	a3,1
 70a:	4629                	li	a2,10
 70c:	000ba583          	lw	a1,0(s7)
 710:	855a                	mv	a0,s6
 712:	e91ff0ef          	jal	5a2 <printint>
 716:	8bca                	mv	s7,s2
      state = 0;
 718:	4981                	li	s3,0
 71a:	bfad                	j	694 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 71c:	06400793          	li	a5,100
 720:	02f68963          	beq	a3,a5,752 <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 724:	06c00793          	li	a5,108
 728:	04f68263          	beq	a3,a5,76c <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
 72c:	07500793          	li	a5,117
 730:	0af68063          	beq	a3,a5,7d0 <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
 734:	07800793          	li	a5,120
 738:	0ef68263          	beq	a3,a5,81c <vprintf+0x1d2>
        putc(fd, '%');
 73c:	02500593          	li	a1,37
 740:	855a                	mv	a0,s6
 742:	e43ff0ef          	jal	584 <putc>
        putc(fd, c0);
 746:	85ca                	mv	a1,s2
 748:	855a                	mv	a0,s6
 74a:	e3bff0ef          	jal	584 <putc>
      state = 0;
 74e:	4981                	li	s3,0
 750:	b791                	j	694 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 752:	008b8913          	addi	s2,s7,8
 756:	4685                	li	a3,1
 758:	4629                	li	a2,10
 75a:	000ba583          	lw	a1,0(s7)
 75e:	855a                	mv	a0,s6
 760:	e43ff0ef          	jal	5a2 <printint>
        i += 1;
 764:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 766:	8bca                	mv	s7,s2
      state = 0;
 768:	4981                	li	s3,0
        i += 1;
 76a:	b72d                	j	694 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 76c:	06400793          	li	a5,100
 770:	02f60763          	beq	a2,a5,79e <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 774:	07500793          	li	a5,117
 778:	06f60963          	beq	a2,a5,7ea <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 77c:	07800793          	li	a5,120
 780:	faf61ee3          	bne	a2,a5,73c <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 784:	008b8913          	addi	s2,s7,8
 788:	4681                	li	a3,0
 78a:	4641                	li	a2,16
 78c:	000ba583          	lw	a1,0(s7)
 790:	855a                	mv	a0,s6
 792:	e11ff0ef          	jal	5a2 <printint>
        i += 2;
 796:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 798:	8bca                	mv	s7,s2
      state = 0;
 79a:	4981                	li	s3,0
        i += 2;
 79c:	bde5                	j	694 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 79e:	008b8913          	addi	s2,s7,8
 7a2:	4685                	li	a3,1
 7a4:	4629                	li	a2,10
 7a6:	000ba583          	lw	a1,0(s7)
 7aa:	855a                	mv	a0,s6
 7ac:	df7ff0ef          	jal	5a2 <printint>
        i += 2;
 7b0:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 7b2:	8bca                	mv	s7,s2
      state = 0;
 7b4:	4981                	li	s3,0
        i += 2;
 7b6:	bdf9                	j	694 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
 7b8:	008b8913          	addi	s2,s7,8
 7bc:	4681                	li	a3,0
 7be:	4629                	li	a2,10
 7c0:	000ba583          	lw	a1,0(s7)
 7c4:	855a                	mv	a0,s6
 7c6:	dddff0ef          	jal	5a2 <printint>
 7ca:	8bca                	mv	s7,s2
      state = 0;
 7cc:	4981                	li	s3,0
 7ce:	b5d9                	j	694 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7d0:	008b8913          	addi	s2,s7,8
 7d4:	4681                	li	a3,0
 7d6:	4629                	li	a2,10
 7d8:	000ba583          	lw	a1,0(s7)
 7dc:	855a                	mv	a0,s6
 7de:	dc5ff0ef          	jal	5a2 <printint>
        i += 1;
 7e2:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 7e4:	8bca                	mv	s7,s2
      state = 0;
 7e6:	4981                	li	s3,0
        i += 1;
 7e8:	b575                	j	694 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7ea:	008b8913          	addi	s2,s7,8
 7ee:	4681                	li	a3,0
 7f0:	4629                	li	a2,10
 7f2:	000ba583          	lw	a1,0(s7)
 7f6:	855a                	mv	a0,s6
 7f8:	dabff0ef          	jal	5a2 <printint>
        i += 2;
 7fc:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 7fe:	8bca                	mv	s7,s2
      state = 0;
 800:	4981                	li	s3,0
        i += 2;
 802:	bd49                	j	694 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
 804:	008b8913          	addi	s2,s7,8
 808:	4681                	li	a3,0
 80a:	4641                	li	a2,16
 80c:	000ba583          	lw	a1,0(s7)
 810:	855a                	mv	a0,s6
 812:	d91ff0ef          	jal	5a2 <printint>
 816:	8bca                	mv	s7,s2
      state = 0;
 818:	4981                	li	s3,0
 81a:	bdad                	j	694 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 81c:	008b8913          	addi	s2,s7,8
 820:	4681                	li	a3,0
 822:	4641                	li	a2,16
 824:	000ba583          	lw	a1,0(s7)
 828:	855a                	mv	a0,s6
 82a:	d79ff0ef          	jal	5a2 <printint>
        i += 1;
 82e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 830:	8bca                	mv	s7,s2
      state = 0;
 832:	4981                	li	s3,0
        i += 1;
 834:	b585                	j	694 <vprintf+0x4a>
 836:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 838:	008b8d13          	addi	s10,s7,8
 83c:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 840:	03000593          	li	a1,48
 844:	855a                	mv	a0,s6
 846:	d3fff0ef          	jal	584 <putc>
  putc(fd, 'x');
 84a:	07800593          	li	a1,120
 84e:	855a                	mv	a0,s6
 850:	d35ff0ef          	jal	584 <putc>
 854:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 856:	00000b97          	auipc	s7,0x0
 85a:	29ab8b93          	addi	s7,s7,666 # af0 <digits>
 85e:	03c9d793          	srli	a5,s3,0x3c
 862:	97de                	add	a5,a5,s7
 864:	0007c583          	lbu	a1,0(a5)
 868:	855a                	mv	a0,s6
 86a:	d1bff0ef          	jal	584 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 86e:	0992                	slli	s3,s3,0x4
 870:	397d                	addiw	s2,s2,-1
 872:	fe0916e3          	bnez	s2,85e <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
 876:	8bea                	mv	s7,s10
      state = 0;
 878:	4981                	li	s3,0
 87a:	6d02                	ld	s10,0(sp)
 87c:	bd21                	j	694 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 87e:	008b8993          	addi	s3,s7,8
 882:	000bb903          	ld	s2,0(s7)
 886:	00090f63          	beqz	s2,8a4 <vprintf+0x25a>
        for(; *s; s++)
 88a:	00094583          	lbu	a1,0(s2)
 88e:	c195                	beqz	a1,8b2 <vprintf+0x268>
          putc(fd, *s);
 890:	855a                	mv	a0,s6
 892:	cf3ff0ef          	jal	584 <putc>
        for(; *s; s++)
 896:	0905                	addi	s2,s2,1
 898:	00094583          	lbu	a1,0(s2)
 89c:	f9f5                	bnez	a1,890 <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 89e:	8bce                	mv	s7,s3
      state = 0;
 8a0:	4981                	li	s3,0
 8a2:	bbcd                	j	694 <vprintf+0x4a>
          s = "(null)";
 8a4:	00000917          	auipc	s2,0x0
 8a8:	24490913          	addi	s2,s2,580 # ae8 <malloc+0x138>
        for(; *s; s++)
 8ac:	02800593          	li	a1,40
 8b0:	b7c5                	j	890 <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 8b2:	8bce                	mv	s7,s3
      state = 0;
 8b4:	4981                	li	s3,0
 8b6:	bbf9                	j	694 <vprintf+0x4a>
 8b8:	64a6                	ld	s1,72(sp)
 8ba:	79e2                	ld	s3,56(sp)
 8bc:	7a42                	ld	s4,48(sp)
 8be:	7aa2                	ld	s5,40(sp)
 8c0:	7b02                	ld	s6,32(sp)
 8c2:	6be2                	ld	s7,24(sp)
 8c4:	6c42                	ld	s8,16(sp)
 8c6:	6ca2                	ld	s9,8(sp)
    }
  }
}
 8c8:	60e6                	ld	ra,88(sp)
 8ca:	6446                	ld	s0,80(sp)
 8cc:	6906                	ld	s2,64(sp)
 8ce:	6125                	addi	sp,sp,96
 8d0:	8082                	ret

00000000000008d2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 8d2:	715d                	addi	sp,sp,-80
 8d4:	ec06                	sd	ra,24(sp)
 8d6:	e822                	sd	s0,16(sp)
 8d8:	1000                	addi	s0,sp,32
 8da:	e010                	sd	a2,0(s0)
 8dc:	e414                	sd	a3,8(s0)
 8de:	e818                	sd	a4,16(s0)
 8e0:	ec1c                	sd	a5,24(s0)
 8e2:	03043023          	sd	a6,32(s0)
 8e6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8ea:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8ee:	8622                	mv	a2,s0
 8f0:	d5bff0ef          	jal	64a <vprintf>
}
 8f4:	60e2                	ld	ra,24(sp)
 8f6:	6442                	ld	s0,16(sp)
 8f8:	6161                	addi	sp,sp,80
 8fa:	8082                	ret

00000000000008fc <printf>:

void
printf(const char *fmt, ...)
{
 8fc:	711d                	addi	sp,sp,-96
 8fe:	ec06                	sd	ra,24(sp)
 900:	e822                	sd	s0,16(sp)
 902:	1000                	addi	s0,sp,32
 904:	e40c                	sd	a1,8(s0)
 906:	e810                	sd	a2,16(s0)
 908:	ec14                	sd	a3,24(s0)
 90a:	f018                	sd	a4,32(s0)
 90c:	f41c                	sd	a5,40(s0)
 90e:	03043823          	sd	a6,48(s0)
 912:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 916:	00840613          	addi	a2,s0,8
 91a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 91e:	85aa                	mv	a1,a0
 920:	4505                	li	a0,1
 922:	d29ff0ef          	jal	64a <vprintf>
}
 926:	60e2                	ld	ra,24(sp)
 928:	6442                	ld	s0,16(sp)
 92a:	6125                	addi	sp,sp,96
 92c:	8082                	ret

000000000000092e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 92e:	1141                	addi	sp,sp,-16
 930:	e422                	sd	s0,8(sp)
 932:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 934:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 938:	00000797          	auipc	a5,0x0
 93c:	6c87b783          	ld	a5,1736(a5) # 1000 <freep>
 940:	a02d                	j	96a <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 942:	4618                	lw	a4,8(a2)
 944:	9f2d                	addw	a4,a4,a1
 946:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 94a:	6398                	ld	a4,0(a5)
 94c:	6310                	ld	a2,0(a4)
 94e:	a83d                	j	98c <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 950:	ff852703          	lw	a4,-8(a0)
 954:	9f31                	addw	a4,a4,a2
 956:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 958:	ff053683          	ld	a3,-16(a0)
 95c:	a091                	j	9a0 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 95e:	6398                	ld	a4,0(a5)
 960:	00e7e463          	bltu	a5,a4,968 <free+0x3a>
 964:	00e6ea63          	bltu	a3,a4,978 <free+0x4a>
{
 968:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 96a:	fed7fae3          	bgeu	a5,a3,95e <free+0x30>
 96e:	6398                	ld	a4,0(a5)
 970:	00e6e463          	bltu	a3,a4,978 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 974:	fee7eae3          	bltu	a5,a4,968 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 978:	ff852583          	lw	a1,-8(a0)
 97c:	6390                	ld	a2,0(a5)
 97e:	02059813          	slli	a6,a1,0x20
 982:	01c85713          	srli	a4,a6,0x1c
 986:	9736                	add	a4,a4,a3
 988:	fae60de3          	beq	a2,a4,942 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 98c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 990:	4790                	lw	a2,8(a5)
 992:	02061593          	slli	a1,a2,0x20
 996:	01c5d713          	srli	a4,a1,0x1c
 99a:	973e                	add	a4,a4,a5
 99c:	fae68ae3          	beq	a3,a4,950 <free+0x22>
    p->s.ptr = bp->s.ptr;
 9a0:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 9a2:	00000717          	auipc	a4,0x0
 9a6:	64f73f23          	sd	a5,1630(a4) # 1000 <freep>
}
 9aa:	6422                	ld	s0,8(sp)
 9ac:	0141                	addi	sp,sp,16
 9ae:	8082                	ret

00000000000009b0 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 9b0:	7139                	addi	sp,sp,-64
 9b2:	fc06                	sd	ra,56(sp)
 9b4:	f822                	sd	s0,48(sp)
 9b6:	f426                	sd	s1,40(sp)
 9b8:	ec4e                	sd	s3,24(sp)
 9ba:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9bc:	02051493          	slli	s1,a0,0x20
 9c0:	9081                	srli	s1,s1,0x20
 9c2:	04bd                	addi	s1,s1,15
 9c4:	8091                	srli	s1,s1,0x4
 9c6:	0014899b          	addiw	s3,s1,1
 9ca:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 9cc:	00000517          	auipc	a0,0x0
 9d0:	63453503          	ld	a0,1588(a0) # 1000 <freep>
 9d4:	c915                	beqz	a0,a08 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9d6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9d8:	4798                	lw	a4,8(a5)
 9da:	08977a63          	bgeu	a4,s1,a6e <malloc+0xbe>
 9de:	f04a                	sd	s2,32(sp)
 9e0:	e852                	sd	s4,16(sp)
 9e2:	e456                	sd	s5,8(sp)
 9e4:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 9e6:	8a4e                	mv	s4,s3
 9e8:	0009871b          	sext.w	a4,s3
 9ec:	6685                	lui	a3,0x1
 9ee:	00d77363          	bgeu	a4,a3,9f4 <malloc+0x44>
 9f2:	6a05                	lui	s4,0x1
 9f4:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9f8:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 9fc:	00000917          	auipc	s2,0x0
 a00:	60490913          	addi	s2,s2,1540 # 1000 <freep>
  if(p == (char*)-1)
 a04:	5afd                	li	s5,-1
 a06:	a081                	j	a46 <malloc+0x96>
 a08:	f04a                	sd	s2,32(sp)
 a0a:	e852                	sd	s4,16(sp)
 a0c:	e456                	sd	s5,8(sp)
 a0e:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 a10:	00001797          	auipc	a5,0x1
 a14:	a0078793          	addi	a5,a5,-1536 # 1410 <base>
 a18:	00000717          	auipc	a4,0x0
 a1c:	5ef73423          	sd	a5,1512(a4) # 1000 <freep>
 a20:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a22:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a26:	b7c1                	j	9e6 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 a28:	6398                	ld	a4,0(a5)
 a2a:	e118                	sd	a4,0(a0)
 a2c:	a8a9                	j	a86 <malloc+0xd6>
  hp->s.size = nu;
 a2e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a32:	0541                	addi	a0,a0,16
 a34:	efbff0ef          	jal	92e <free>
  return freep;
 a38:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a3c:	c12d                	beqz	a0,a9e <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a3e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a40:	4798                	lw	a4,8(a5)
 a42:	02977263          	bgeu	a4,s1,a66 <malloc+0xb6>
    if(p == freep)
 a46:	00093703          	ld	a4,0(s2)
 a4a:	853e                	mv	a0,a5
 a4c:	fef719e3          	bne	a4,a5,a3e <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 a50:	8552                	mv	a0,s4
 a52:	afbff0ef          	jal	54c <sbrk>
  if(p == (char*)-1)
 a56:	fd551ce3          	bne	a0,s5,a2e <malloc+0x7e>
        return 0;
 a5a:	4501                	li	a0,0
 a5c:	7902                	ld	s2,32(sp)
 a5e:	6a42                	ld	s4,16(sp)
 a60:	6aa2                	ld	s5,8(sp)
 a62:	6b02                	ld	s6,0(sp)
 a64:	a03d                	j	a92 <malloc+0xe2>
 a66:	7902                	ld	s2,32(sp)
 a68:	6a42                	ld	s4,16(sp)
 a6a:	6aa2                	ld	s5,8(sp)
 a6c:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 a6e:	fae48de3          	beq	s1,a4,a28 <malloc+0x78>
        p->s.size -= nunits;
 a72:	4137073b          	subw	a4,a4,s3
 a76:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a78:	02071693          	slli	a3,a4,0x20
 a7c:	01c6d713          	srli	a4,a3,0x1c
 a80:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a82:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a86:	00000717          	auipc	a4,0x0
 a8a:	56a73d23          	sd	a0,1402(a4) # 1000 <freep>
      return (void*)(p + 1);
 a8e:	01078513          	addi	a0,a5,16
  }
}
 a92:	70e2                	ld	ra,56(sp)
 a94:	7442                	ld	s0,48(sp)
 a96:	74a2                	ld	s1,40(sp)
 a98:	69e2                	ld	s3,24(sp)
 a9a:	6121                	addi	sp,sp,64
 a9c:	8082                	ret
 a9e:	7902                	ld	s2,32(sp)
 aa0:	6a42                	ld	s4,16(sp)
 aa2:	6aa2                	ld	s5,8(sp)
 aa4:	6b02                	ld	s6,0(sp)
 aa6:	b7f5                	j	a92 <malloc+0xe2>
