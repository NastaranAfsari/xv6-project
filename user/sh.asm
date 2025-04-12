
user/_sh:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <strstr>:
int fork1(void);  // Fork but panics on failure.
void panic(char*);
struct cmd *parsecmd(char*);
void runcmd(struct cmd*) __attribute__((noreturn));

char* strstr(const char* haystack, const char* needle) {
       0:	1141                	addi	sp,sp,-16
       2:	e406                	sd	ra,8(sp)
       4:	e022                	sd	s0,0(sp)
       6:	0800                	addi	s0,sp,16
    if (!*needle) return (char*) haystack;
       8:	0005c803          	lbu	a6,0(a1)
       c:	04080163          	beqz	a6,4e <strstr+0x4e>
    for (; *haystack; ++haystack) {
      10:	00054783          	lbu	a5,0(a0)
      14:	eb91                	bnez	a5,28 <strstr+0x28>
                ++h; ++n;
            }
            if (!*n) return (char*) haystack;
        }
    }
    return NULL;
      16:	4501                	li	a0,0
      18:	a81d                	j	4e <strstr+0x4e>
            if (!*n) return (char*) haystack;
      1a:	0007c783          	lbu	a5,0(a5)
      1e:	cb85                	beqz	a5,4e <strstr+0x4e>
    for (; *haystack; ++haystack) {
      20:	0505                	addi	a0,a0,1
      22:	00054783          	lbu	a5,0(a0)
      26:	c39d                	beqz	a5,4c <strstr+0x4c>
        if (*haystack == *needle) {
      28:	fef81ce3          	bne	a6,a5,20 <strstr+0x20>
            while (*h && *n && *h == *n) {
      2c:	00054703          	lbu	a4,0(a0)
            const char *h = haystack, *n = needle;
      30:	87ae                	mv	a5,a1
      32:	862a                	mv	a2,a0
            while (*h && *n && *h == *n) {
      34:	d775                	beqz	a4,20 <strstr+0x20>
      36:	0007c683          	lbu	a3,0(a5)
      3a:	ca91                	beqz	a3,4e <strstr+0x4e>
      3c:	fce69fe3          	bne	a3,a4,1a <strstr+0x1a>
                ++h; ++n;
      40:	0605                	addi	a2,a2,1
      42:	0785                	addi	a5,a5,1
            while (*h && *n && *h == *n) {
      44:	00064703          	lbu	a4,0(a2)
      48:	f77d                	bnez	a4,36 <strstr+0x36>
      4a:	bfc1                	j	1a <strstr+0x1a>
    return NULL;
      4c:	4501                	li	a0,0
}
      4e:	60a2                	ld	ra,8(sp)
      50:	6402                	ld	s0,0(sp)
      52:	0141                	addi	sp,sp,16
      54:	8082                	ret

0000000000000056 <getcmd>:
  exit(0);
}

int
getcmd(char *buf, int nbuf)
{
      56:	1101                	addi	sp,sp,-32
      58:	ec06                	sd	ra,24(sp)
      5a:	e822                	sd	s0,16(sp)
      5c:	e426                	sd	s1,8(sp)
      5e:	e04a                	sd	s2,0(sp)
      60:	1000                	addi	s0,sp,32
      62:	84aa                	mv	s1,a0
      64:	892e                	mv	s2,a1
  write(2, "$ ", 2);
      66:	4609                	li	a2,2
      68:	00001597          	auipc	a1,0x1
      6c:	43858593          	addi	a1,a1,1080 # 14a0 <malloc+0xfe>
      70:	8532                	mv	a0,a2
      72:	697000ef          	jal	f08 <write>
  memset(buf, 0, nbuf);
      76:	864a                	mv	a2,s2
      78:	4581                	li	a1,0
      7a:	8526                	mv	a0,s1
      7c:	45f000ef          	jal	cda <memset>
  gets(buf, nbuf);
      80:	85ca                	mv	a1,s2
      82:	8526                	mv	a0,s1
      84:	4a5000ef          	jal	d28 <gets>
  if(buf[0] == 0) // EOF
      88:	0004c503          	lbu	a0,0(s1)
      8c:	00153513          	seqz	a0,a0
    return -1;
  return 0;
}
      90:	40a0053b          	negw	a0,a0
      94:	60e2                	ld	ra,24(sp)
      96:	6442                	ld	s0,16(sp)
      98:	64a2                	ld	s1,8(sp)
      9a:	6902                	ld	s2,0(sp)
      9c:	6105                	addi	sp,sp,32
      9e:	8082                	ret

00000000000000a0 <panic>:
  exit(0);
}

void
panic(char *s)
{
      a0:	1141                	addi	sp,sp,-16
      a2:	e406                	sd	ra,8(sp)
      a4:	e022                	sd	s0,0(sp)
      a6:	0800                	addi	s0,sp,16
      a8:	862a                	mv	a2,a0
  fprintf(2, "%s\n", s);
      aa:	00001597          	auipc	a1,0x1
      ae:	40658593          	addi	a1,a1,1030 # 14b0 <malloc+0x10e>
      b2:	4509                	li	a0,2
      b4:	20c010ef          	jal	12c0 <fprintf>
  exit(1);
      b8:	4505                	li	a0,1
      ba:	62f000ef          	jal	ee8 <exit>

00000000000000be <fork1>:
}

int
fork1(void)
{
      be:	1141                	addi	sp,sp,-16
      c0:	e406                	sd	ra,8(sp)
      c2:	e022                	sd	s0,0(sp)
      c4:	0800                	addi	s0,sp,16
  int pid;

  pid = fork();
      c6:	61b000ef          	jal	ee0 <fork>
  if(pid == -1)
      ca:	57fd                	li	a5,-1
      cc:	00f50663          	beq	a0,a5,d8 <fork1+0x1a>
    panic("fork");
  return pid;
}
      d0:	60a2                	ld	ra,8(sp)
      d2:	6402                	ld	s0,0(sp)
      d4:	0141                	addi	sp,sp,16
      d6:	8082                	ret
    panic("fork");
      d8:	00001517          	auipc	a0,0x1
      dc:	3e050513          	addi	a0,a0,992 # 14b8 <malloc+0x116>
      e0:	fc1ff0ef          	jal	a0 <panic>

00000000000000e4 <runcmd>:
{
      e4:	d9010113          	addi	sp,sp,-624
      e8:	26113423          	sd	ra,616(sp)
      ec:	26813023          	sd	s0,608(sp)
      f0:	1c80                	addi	s0,sp,624
  if(cmd == 0)
      f2:	c51d                	beqz	a0,120 <runcmd+0x3c>
      f4:	24913c23          	sd	s1,600(sp)
      f8:	25213823          	sd	s2,592(sp)
      fc:	25413023          	sd	s4,576(sp)
     100:	84aa                	mv	s1,a0
  switch(cmd->type){
     102:	00052903          	lw	s2,0(a0)
     106:	4795                	li	a5,5
     108:	0527e163          	bltu	a5,s2,14a <runcmd+0x66>
     10c:	00291793          	slli	a5,s2,0x2
     110:	00001717          	auipc	a4,0x1
     114:	4f870713          	addi	a4,a4,1272 # 1608 <malloc+0x266>
     118:	97ba                	add	a5,a5,a4
     11a:	439c                	lw	a5,0(a5)
     11c:	97ba                	add	a5,a5,a4
     11e:	8782                	jr	a5
     120:	24913c23          	sd	s1,600(sp)
     124:	25213823          	sd	s2,592(sp)
     128:	25313423          	sd	s3,584(sp)
     12c:	25413023          	sd	s4,576(sp)
     130:	23513c23          	sd	s5,568(sp)
     134:	23613823          	sd	s6,560(sp)
     138:	23713423          	sd	s7,552(sp)
     13c:	23813023          	sd	s8,544(sp)
     140:	21913c23          	sd	s9,536(sp)
    exit(1);
     144:	4505                	li	a0,1
     146:	5a3000ef          	jal	ee8 <exit>
     14a:	25313423          	sd	s3,584(sp)
     14e:	23513c23          	sd	s5,568(sp)
     152:	23613823          	sd	s6,560(sp)
     156:	23713423          	sd	s7,552(sp)
     15a:	23813023          	sd	s8,544(sp)
     15e:	21913c23          	sd	s9,536(sp)
    panic("runcmd");
     162:	00001517          	auipc	a0,0x1
     166:	35e50513          	addi	a0,a0,862 # 14c0 <malloc+0x11e>
     16a:	f37ff0ef          	jal	a0 <panic>
    if (ecmd->argv[0][0] == '!' && strcmp(ecmd->argv[0] + 1, "echo") == 0) {
     16e:	00853a03          	ld	s4,8(a0)
     172:	000a4703          	lbu	a4,0(s4)
     176:	02100793          	li	a5,33
     17a:	02f70c63          	beq	a4,a5,1b2 <runcmd+0xce>
    exec(ecmd->argv[0], ecmd->argv);
     17e:	00848593          	addi	a1,s1,8
     182:	8552                	mv	a0,s4
     184:	59d000ef          	jal	f20 <exec>
    fprintf(2, "exec %s failed\n", ecmd->argv[0]);
     188:	6490                	ld	a2,8(s1)
     18a:	00001597          	auipc	a1,0x1
     18e:	38e58593          	addi	a1,a1,910 # 1518 <malloc+0x176>
     192:	4509                	li	a0,2
     194:	12c010ef          	jal	12c0 <fprintf>
    break;
     198:	25313423          	sd	s3,584(sp)
     19c:	23513c23          	sd	s5,568(sp)
     1a0:	23613823          	sd	s6,560(sp)
     1a4:	23713423          	sd	s7,552(sp)
     1a8:	23813023          	sd	s8,544(sp)
     1ac:	21913c23          	sd	s9,536(sp)
     1b0:	ac69                	j	44a <runcmd+0x366>
     1b2:	25313423          	sd	s3,584(sp)
    if (ecmd->argv[0][0] == '!' && strcmp(ecmd->argv[0] + 1, "echo") == 0) {
     1b6:	00001597          	auipc	a1,0x1
     1ba:	31258593          	addi	a1,a1,786 # 14c8 <malloc+0x126>
     1be:	001a0513          	addi	a0,s4,1
     1c2:	2bb000ef          	jal	c7c <strcmp>
     1c6:	89aa                	mv	s3,a0
     1c8:	e961                	bnez	a0,298 <runcmd+0x1b4>
     1ca:	23513c23          	sd	s5,568(sp)
     1ce:	23613823          	sd	s6,560(sp)
     1d2:	23713423          	sd	s7,552(sp)
     1d6:	23813023          	sd	s8,544(sp)
     1da:	21913c23          	sd	s9,536(sp)
        char buf[513] = {0};
     1de:	20100613          	li	a2,513
     1e2:	4581                	li	a1,0
     1e4:	d9040513          	addi	a0,s0,-624
     1e8:	2f3000ef          	jal	cda <memset>
        for (int i = 1; ecmd->argv[i] != 0; i++) {
     1ec:	04c1                	addi	s1,s1,16
            if (total + len + 1 >= sizeof(buf)) {
     1ee:	20000b13          	li	s6,512
            if (i > 1) {
     1f2:	4c05                	li	s8,1
                buf[total++] = ' ';
     1f4:	02000c93          	li	s9,32
            strcpy(buf + total, ecmd->argv[i]);
     1f8:	d9040b93          	addi	s7,s0,-624
        for (int i = 1; ecmd->argv[i] != 0; i++) {
     1fc:	a025                	j	224 <runcmd+0x140>
                printf("Message too long\n");
     1fe:	00001517          	auipc	a0,0x1
     202:	2d250513          	addi	a0,a0,722 # 14d0 <malloc+0x12e>
     206:	0e4010ef          	jal	12ea <printf>
                exit(1);
     20a:	4505                	li	a0,1
     20c:	4dd000ef          	jal	ee8 <exit>
            strcpy(buf + total, ecmd->argv[i]);
     210:	000ab583          	ld	a1,0(s5)
     214:	013b8533          	add	a0,s7,s3
     218:	245000ef          	jal	c5c <strcpy>
            total += len;
     21c:	014989bb          	addw	s3,s3,s4
        for (int i = 1; ecmd->argv[i] != 0; i++) {
     220:	2905                	addiw	s2,s2,1
     222:	04a1                	addi	s1,s1,8
     224:	8aa6                	mv	s5,s1
     226:	6088                	ld	a0,0(s1)
     228:	c115                	beqz	a0,24c <runcmd+0x168>
            int len = strlen(ecmd->argv[i]);
     22a:	283000ef          	jal	cac <strlen>
     22e:	8a2a                	mv	s4,a0
            if (total + len + 1 >= sizeof(buf)) {
     230:	00a987bb          	addw	a5,s3,a0
     234:	2785                	addiw	a5,a5,1
     236:	fcfb64e3          	bltu	s6,a5,1fe <runcmd+0x11a>
            if (i > 1) {
     23a:	fd2c5be3          	bge	s8,s2,210 <runcmd+0x12c>
                buf[total++] = ' ';
     23e:	fa098793          	addi	a5,s3,-96
     242:	97a2                	add	a5,a5,s0
     244:	df978823          	sb	s9,-528(a5)
     248:	2985                	addiw	s3,s3,1
     24a:	b7d9                	j	210 <runcmd+0x12c>
        if (total == 0) {
     24c:	02098463          	beqz	s3,274 <runcmd+0x190>
        } else if (strstr(buf, "os") != NULL) {
     250:	00001597          	auipc	a1,0x1
     254:	2b058593          	addi	a1,a1,688 # 1500 <malloc+0x15e>
     258:	d9040513          	addi	a0,s0,-624
     25c:	da5ff0ef          	jal	0 <strstr>
     260:	c11d                	beqz	a0,286 <runcmd+0x1a2>
                  printf("\033[34m%s\033[0m\n", buf);
     262:	d9040593          	addi	a1,s0,-624
     266:	00001517          	auipc	a0,0x1
     26a:	2a250513          	addi	a0,a0,674 # 1508 <malloc+0x166>
     26e:	07c010ef          	jal	12ea <printf>
     272:	aae1                	j	44a <runcmd+0x366>
            printf("No message provided.\n");
     274:	00001517          	auipc	a0,0x1
     278:	27450513          	addi	a0,a0,628 # 14e8 <malloc+0x146>
     27c:	06e010ef          	jal	12ea <printf>
            exit(1);
     280:	4505                	li	a0,1
     282:	467000ef          	jal	ee8 <exit>
            printf("%s\n", buf);
     286:	d9040593          	addi	a1,s0,-624
     28a:	00001517          	auipc	a0,0x1
     28e:	22650513          	addi	a0,a0,550 # 14b0 <malloc+0x10e>
     292:	058010ef          	jal	12ea <printf>
        break;
     296:	aa55                	j	44a <runcmd+0x366>
     298:	24813983          	ld	s3,584(sp)
     29c:	b5cd                	j	17e <runcmd+0x9a>
    close(rcmd->fd);
     29e:	5148                	lw	a0,36(a0)
     2a0:	471000ef          	jal	f10 <close>
    if(open(rcmd->file, rcmd->mode) < 0){
     2a4:	508c                	lw	a1,32(s1)
     2a6:	6888                	ld	a0,16(s1)
     2a8:	481000ef          	jal	f28 <open>
     2ac:	02054163          	bltz	a0,2ce <runcmd+0x1ea>
     2b0:	25313423          	sd	s3,584(sp)
     2b4:	23513c23          	sd	s5,568(sp)
     2b8:	23613823          	sd	s6,560(sp)
     2bc:	23713423          	sd	s7,552(sp)
     2c0:	23813023          	sd	s8,544(sp)
     2c4:	21913c23          	sd	s9,536(sp)
    runcmd(rcmd->cmd);
     2c8:	6488                	ld	a0,8(s1)
     2ca:	e1bff0ef          	jal	e4 <runcmd>
     2ce:	25313423          	sd	s3,584(sp)
     2d2:	23513c23          	sd	s5,568(sp)
     2d6:	23613823          	sd	s6,560(sp)
     2da:	23713423          	sd	s7,552(sp)
     2de:	23813023          	sd	s8,544(sp)
     2e2:	21913c23          	sd	s9,536(sp)
      fprintf(2, "open %s failed\n", rcmd->file);
     2e6:	6890                	ld	a2,16(s1)
     2e8:	00001597          	auipc	a1,0x1
     2ec:	24058593          	addi	a1,a1,576 # 1528 <malloc+0x186>
     2f0:	4509                	li	a0,2
     2f2:	7cf000ef          	jal	12c0 <fprintf>
      exit(1);
     2f6:	4505                	li	a0,1
     2f8:	3f1000ef          	jal	ee8 <exit>
    if(fork1() == 0)
     2fc:	dc3ff0ef          	jal	be <fork1>
     300:	e105                	bnez	a0,320 <runcmd+0x23c>
     302:	25313423          	sd	s3,584(sp)
     306:	23513c23          	sd	s5,568(sp)
     30a:	23613823          	sd	s6,560(sp)
     30e:	23713423          	sd	s7,552(sp)
     312:	23813023          	sd	s8,544(sp)
     316:	21913c23          	sd	s9,536(sp)
      runcmd(lcmd->left);
     31a:	6488                	ld	a0,8(s1)
     31c:	dc9ff0ef          	jal	e4 <runcmd>
     320:	25313423          	sd	s3,584(sp)
     324:	23513c23          	sd	s5,568(sp)
     328:	23613823          	sd	s6,560(sp)
     32c:	23713423          	sd	s7,552(sp)
     330:	23813023          	sd	s8,544(sp)
     334:	21913c23          	sd	s9,536(sp)
    wait(0);
     338:	4501                	li	a0,0
     33a:	3b7000ef          	jal	ef0 <wait>
    runcmd(lcmd->right);
     33e:	6888                	ld	a0,16(s1)
     340:	da5ff0ef          	jal	e4 <runcmd>
    if(pipe(p) < 0)
     344:	f9840513          	addi	a0,s0,-104
     348:	3b1000ef          	jal	ef8 <pipe>
     34c:	04054363          	bltz	a0,392 <runcmd+0x2ae>
    if(fork1() == 0){
     350:	d6fff0ef          	jal	be <fork1>
     354:	e12d                	bnez	a0,3b6 <runcmd+0x2d2>
     356:	25313423          	sd	s3,584(sp)
     35a:	23513c23          	sd	s5,568(sp)
     35e:	23613823          	sd	s6,560(sp)
     362:	23713423          	sd	s7,552(sp)
     366:	23813023          	sd	s8,544(sp)
     36a:	21913c23          	sd	s9,536(sp)
      close(1);
     36e:	4505                	li	a0,1
     370:	3a1000ef          	jal	f10 <close>
      dup(p[1]);
     374:	f9c42503          	lw	a0,-100(s0)
     378:	3e9000ef          	jal	f60 <dup>
      close(p[0]);
     37c:	f9842503          	lw	a0,-104(s0)
     380:	391000ef          	jal	f10 <close>
      close(p[1]);
     384:	f9c42503          	lw	a0,-100(s0)
     388:	389000ef          	jal	f10 <close>
      runcmd(pcmd->left);
     38c:	6488                	ld	a0,8(s1)
     38e:	d57ff0ef          	jal	e4 <runcmd>
     392:	25313423          	sd	s3,584(sp)
     396:	23513c23          	sd	s5,568(sp)
     39a:	23613823          	sd	s6,560(sp)
     39e:	23713423          	sd	s7,552(sp)
     3a2:	23813023          	sd	s8,544(sp)
     3a6:	21913c23          	sd	s9,536(sp)
      panic("pipe");
     3aa:	00001517          	auipc	a0,0x1
     3ae:	18e50513          	addi	a0,a0,398 # 1538 <malloc+0x196>
     3b2:	cefff0ef          	jal	a0 <panic>
    if(fork1() == 0){
     3b6:	d09ff0ef          	jal	be <fork1>
     3ba:	ed15                	bnez	a0,3f6 <runcmd+0x312>
     3bc:	25313423          	sd	s3,584(sp)
     3c0:	23513c23          	sd	s5,568(sp)
     3c4:	23613823          	sd	s6,560(sp)
     3c8:	23713423          	sd	s7,552(sp)
     3cc:	23813023          	sd	s8,544(sp)
     3d0:	21913c23          	sd	s9,536(sp)
      close(0);
     3d4:	33d000ef          	jal	f10 <close>
      dup(p[0]);
     3d8:	f9842503          	lw	a0,-104(s0)
     3dc:	385000ef          	jal	f60 <dup>
      close(p[0]);
     3e0:	f9842503          	lw	a0,-104(s0)
     3e4:	32d000ef          	jal	f10 <close>
      close(p[1]);
     3e8:	f9c42503          	lw	a0,-100(s0)
     3ec:	325000ef          	jal	f10 <close>
      runcmd(pcmd->right);
     3f0:	6888                	ld	a0,16(s1)
     3f2:	cf3ff0ef          	jal	e4 <runcmd>
    close(p[0]);
     3f6:	f9842503          	lw	a0,-104(s0)
     3fa:	317000ef          	jal	f10 <close>
    close(p[1]);
     3fe:	f9c42503          	lw	a0,-100(s0)
     402:	30f000ef          	jal	f10 <close>
    wait(0);
     406:	4501                	li	a0,0
     408:	2e9000ef          	jal	ef0 <wait>
    wait(0);
     40c:	4501                	li	a0,0
     40e:	2e3000ef          	jal	ef0 <wait>
    break;
     412:	25313423          	sd	s3,584(sp)
     416:	23513c23          	sd	s5,568(sp)
     41a:	23613823          	sd	s6,560(sp)
     41e:	23713423          	sd	s7,552(sp)
     422:	23813023          	sd	s8,544(sp)
     426:	21913c23          	sd	s9,536(sp)
     42a:	a005                	j	44a <runcmd+0x366>
    if(fork1() == 0)
     42c:	c93ff0ef          	jal	be <fork1>
     430:	c105                	beqz	a0,450 <runcmd+0x36c>
     432:	25313423          	sd	s3,584(sp)
     436:	23513c23          	sd	s5,568(sp)
     43a:	23613823          	sd	s6,560(sp)
     43e:	23713423          	sd	s7,552(sp)
     442:	23813023          	sd	s8,544(sp)
     446:	21913c23          	sd	s9,536(sp)
  exit(0);
     44a:	4501                	li	a0,0
     44c:	29d000ef          	jal	ee8 <exit>
     450:	25313423          	sd	s3,584(sp)
     454:	23513c23          	sd	s5,568(sp)
     458:	23613823          	sd	s6,560(sp)
     45c:	23713423          	sd	s7,552(sp)
     460:	23813023          	sd	s8,544(sp)
     464:	21913c23          	sd	s9,536(sp)
      runcmd(bcmd->cmd);
     468:	6488                	ld	a0,8(s1)
     46a:	c7bff0ef          	jal	e4 <runcmd>

000000000000046e <execcmd>:
//PAGEBREAK!
// Constructors

struct cmd*
execcmd(void)
{
     46e:	1101                	addi	sp,sp,-32
     470:	ec06                	sd	ra,24(sp)
     472:	e822                	sd	s0,16(sp)
     474:	e426                	sd	s1,8(sp)
     476:	1000                	addi	s0,sp,32
  struct execcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     478:	0a800513          	li	a0,168
     47c:	727000ef          	jal	13a2 <malloc>
     480:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     482:	0a800613          	li	a2,168
     486:	4581                	li	a1,0
     488:	053000ef          	jal	cda <memset>
  cmd->type = EXEC;
     48c:	4785                	li	a5,1
     48e:	c09c                	sw	a5,0(s1)
  return (struct cmd*)cmd;
}
     490:	8526                	mv	a0,s1
     492:	60e2                	ld	ra,24(sp)
     494:	6442                	ld	s0,16(sp)
     496:	64a2                	ld	s1,8(sp)
     498:	6105                	addi	sp,sp,32
     49a:	8082                	ret

000000000000049c <redircmd>:

struct cmd*
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
     49c:	7139                	addi	sp,sp,-64
     49e:	fc06                	sd	ra,56(sp)
     4a0:	f822                	sd	s0,48(sp)
     4a2:	f426                	sd	s1,40(sp)
     4a4:	f04a                	sd	s2,32(sp)
     4a6:	ec4e                	sd	s3,24(sp)
     4a8:	e852                	sd	s4,16(sp)
     4aa:	e456                	sd	s5,8(sp)
     4ac:	e05a                	sd	s6,0(sp)
     4ae:	0080                	addi	s0,sp,64
     4b0:	8b2a                	mv	s6,a0
     4b2:	8aae                	mv	s5,a1
     4b4:	8a32                	mv	s4,a2
     4b6:	89b6                	mv	s3,a3
     4b8:	893a                	mv	s2,a4
  struct redircmd *cmd;

  cmd = malloc(sizeof(*cmd));
     4ba:	02800513          	li	a0,40
     4be:	6e5000ef          	jal	13a2 <malloc>
     4c2:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     4c4:	02800613          	li	a2,40
     4c8:	4581                	li	a1,0
     4ca:	011000ef          	jal	cda <memset>
  cmd->type = REDIR;
     4ce:	4789                	li	a5,2
     4d0:	c09c                	sw	a5,0(s1)
  cmd->cmd = subcmd;
     4d2:	0164b423          	sd	s6,8(s1)
  cmd->file = file;
     4d6:	0154b823          	sd	s5,16(s1)
  cmd->efile = efile;
     4da:	0144bc23          	sd	s4,24(s1)
  cmd->mode = mode;
     4de:	0334a023          	sw	s3,32(s1)
  cmd->fd = fd;
     4e2:	0324a223          	sw	s2,36(s1)
  return (struct cmd*)cmd;
}
     4e6:	8526                	mv	a0,s1
     4e8:	70e2                	ld	ra,56(sp)
     4ea:	7442                	ld	s0,48(sp)
     4ec:	74a2                	ld	s1,40(sp)
     4ee:	7902                	ld	s2,32(sp)
     4f0:	69e2                	ld	s3,24(sp)
     4f2:	6a42                	ld	s4,16(sp)
     4f4:	6aa2                	ld	s5,8(sp)
     4f6:	6b02                	ld	s6,0(sp)
     4f8:	6121                	addi	sp,sp,64
     4fa:	8082                	ret

00000000000004fc <pipecmd>:

struct cmd*
pipecmd(struct cmd *left, struct cmd *right)
{
     4fc:	7179                	addi	sp,sp,-48
     4fe:	f406                	sd	ra,40(sp)
     500:	f022                	sd	s0,32(sp)
     502:	ec26                	sd	s1,24(sp)
     504:	e84a                	sd	s2,16(sp)
     506:	e44e                	sd	s3,8(sp)
     508:	1800                	addi	s0,sp,48
     50a:	89aa                	mv	s3,a0
     50c:	892e                	mv	s2,a1
  struct pipecmd *cmd;

  cmd = malloc(sizeof(*cmd));
     50e:	4561                	li	a0,24
     510:	693000ef          	jal	13a2 <malloc>
     514:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     516:	4661                	li	a2,24
     518:	4581                	li	a1,0
     51a:	7c0000ef          	jal	cda <memset>
  cmd->type = PIPE;
     51e:	478d                	li	a5,3
     520:	c09c                	sw	a5,0(s1)
  cmd->left = left;
     522:	0134b423          	sd	s3,8(s1)
  cmd->right = right;
     526:	0124b823          	sd	s2,16(s1)
  return (struct cmd*)cmd;
}
     52a:	8526                	mv	a0,s1
     52c:	70a2                	ld	ra,40(sp)
     52e:	7402                	ld	s0,32(sp)
     530:	64e2                	ld	s1,24(sp)
     532:	6942                	ld	s2,16(sp)
     534:	69a2                	ld	s3,8(sp)
     536:	6145                	addi	sp,sp,48
     538:	8082                	ret

000000000000053a <listcmd>:

struct cmd*
listcmd(struct cmd *left, struct cmd *right)
{
     53a:	7179                	addi	sp,sp,-48
     53c:	f406                	sd	ra,40(sp)
     53e:	f022                	sd	s0,32(sp)
     540:	ec26                	sd	s1,24(sp)
     542:	e84a                	sd	s2,16(sp)
     544:	e44e                	sd	s3,8(sp)
     546:	1800                	addi	s0,sp,48
     548:	89aa                	mv	s3,a0
     54a:	892e                	mv	s2,a1
  struct listcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     54c:	4561                	li	a0,24
     54e:	655000ef          	jal	13a2 <malloc>
     552:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     554:	4661                	li	a2,24
     556:	4581                	li	a1,0
     558:	782000ef          	jal	cda <memset>
  cmd->type = LIST;
     55c:	4791                	li	a5,4
     55e:	c09c                	sw	a5,0(s1)
  cmd->left = left;
     560:	0134b423          	sd	s3,8(s1)
  cmd->right = right;
     564:	0124b823          	sd	s2,16(s1)
  return (struct cmd*)cmd;
}
     568:	8526                	mv	a0,s1
     56a:	70a2                	ld	ra,40(sp)
     56c:	7402                	ld	s0,32(sp)
     56e:	64e2                	ld	s1,24(sp)
     570:	6942                	ld	s2,16(sp)
     572:	69a2                	ld	s3,8(sp)
     574:	6145                	addi	sp,sp,48
     576:	8082                	ret

0000000000000578 <backcmd>:

struct cmd*
backcmd(struct cmd *subcmd)
{
     578:	1101                	addi	sp,sp,-32
     57a:	ec06                	sd	ra,24(sp)
     57c:	e822                	sd	s0,16(sp)
     57e:	e426                	sd	s1,8(sp)
     580:	e04a                	sd	s2,0(sp)
     582:	1000                	addi	s0,sp,32
     584:	892a                	mv	s2,a0
  struct backcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     586:	4541                	li	a0,16
     588:	61b000ef          	jal	13a2 <malloc>
     58c:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     58e:	4641                	li	a2,16
     590:	4581                	li	a1,0
     592:	748000ef          	jal	cda <memset>
  cmd->type = BACK;
     596:	4795                	li	a5,5
     598:	c09c                	sw	a5,0(s1)
  cmd->cmd = subcmd;
     59a:	0124b423          	sd	s2,8(s1)
  return (struct cmd*)cmd;
}
     59e:	8526                	mv	a0,s1
     5a0:	60e2                	ld	ra,24(sp)
     5a2:	6442                	ld	s0,16(sp)
     5a4:	64a2                	ld	s1,8(sp)
     5a6:	6902                	ld	s2,0(sp)
     5a8:	6105                	addi	sp,sp,32
     5aa:	8082                	ret

00000000000005ac <gettoken>:
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int
gettoken(char **ps, char *es, char **q, char **eq)
{
     5ac:	7139                	addi	sp,sp,-64
     5ae:	fc06                	sd	ra,56(sp)
     5b0:	f822                	sd	s0,48(sp)
     5b2:	f426                	sd	s1,40(sp)
     5b4:	f04a                	sd	s2,32(sp)
     5b6:	ec4e                	sd	s3,24(sp)
     5b8:	e852                	sd	s4,16(sp)
     5ba:	e456                	sd	s5,8(sp)
     5bc:	e05a                	sd	s6,0(sp)
     5be:	0080                	addi	s0,sp,64
     5c0:	8a2a                	mv	s4,a0
     5c2:	892e                	mv	s2,a1
     5c4:	8ab2                	mv	s5,a2
     5c6:	8b36                	mv	s6,a3
  char *s;
  int ret;

  s = *ps;
     5c8:	6104                	ld	s1,0(a0)
  while(s < es && strchr(whitespace, *s))
     5ca:	00002997          	auipc	s3,0x2
     5ce:	a3e98993          	addi	s3,s3,-1474 # 2008 <whitespace>
     5d2:	00b4fc63          	bgeu	s1,a1,5ea <gettoken+0x3e>
     5d6:	0004c583          	lbu	a1,0(s1)
     5da:	854e                	mv	a0,s3
     5dc:	724000ef          	jal	d00 <strchr>
     5e0:	c509                	beqz	a0,5ea <gettoken+0x3e>
    s++;
     5e2:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     5e4:	fe9919e3          	bne	s2,s1,5d6 <gettoken+0x2a>
     5e8:	84ca                	mv	s1,s2
  if(q)
     5ea:	000a8463          	beqz	s5,5f2 <gettoken+0x46>
    *q = s;
     5ee:	009ab023          	sd	s1,0(s5)
  ret = *s;
     5f2:	0004c783          	lbu	a5,0(s1)
     5f6:	00078a9b          	sext.w	s5,a5
  switch(*s){
     5fa:	03c00713          	li	a4,60
     5fe:	06f76463          	bltu	a4,a5,666 <gettoken+0xba>
     602:	03a00713          	li	a4,58
     606:	00f76e63          	bltu	a4,a5,622 <gettoken+0x76>
     60a:	cf89                	beqz	a5,624 <gettoken+0x78>
     60c:	02600713          	li	a4,38
     610:	00e78963          	beq	a5,a4,622 <gettoken+0x76>
     614:	fd87879b          	addiw	a5,a5,-40
     618:	0ff7f793          	zext.b	a5,a5
     61c:	4705                	li	a4,1
     61e:	06f76b63          	bltu	a4,a5,694 <gettoken+0xe8>
  case '(':
  case ')':
  case ';':
  case '&':
  case '<':
    s++;
     622:	0485                	addi	s1,s1,1
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
      s++;
    break;
  }
  if(eq)
     624:	000b0463          	beqz	s6,62c <gettoken+0x80>
    *eq = s;
     628:	009b3023          	sd	s1,0(s6)

  while(s < es && strchr(whitespace, *s))
     62c:	00002997          	auipc	s3,0x2
     630:	9dc98993          	addi	s3,s3,-1572 # 2008 <whitespace>
     634:	0124fc63          	bgeu	s1,s2,64c <gettoken+0xa0>
     638:	0004c583          	lbu	a1,0(s1)
     63c:	854e                	mv	a0,s3
     63e:	6c2000ef          	jal	d00 <strchr>
     642:	c509                	beqz	a0,64c <gettoken+0xa0>
    s++;
     644:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     646:	fe9919e3          	bne	s2,s1,638 <gettoken+0x8c>
     64a:	84ca                	mv	s1,s2
  *ps = s;
     64c:	009a3023          	sd	s1,0(s4)
  return ret;
}
     650:	8556                	mv	a0,s5
     652:	70e2                	ld	ra,56(sp)
     654:	7442                	ld	s0,48(sp)
     656:	74a2                	ld	s1,40(sp)
     658:	7902                	ld	s2,32(sp)
     65a:	69e2                	ld	s3,24(sp)
     65c:	6a42                	ld	s4,16(sp)
     65e:	6aa2                	ld	s5,8(sp)
     660:	6b02                	ld	s6,0(sp)
     662:	6121                	addi	sp,sp,64
     664:	8082                	ret
  switch(*s){
     666:	03e00713          	li	a4,62
     66a:	02e79163          	bne	a5,a4,68c <gettoken+0xe0>
    s++;
     66e:	00148693          	addi	a3,s1,1
    if(*s == '>'){
     672:	0014c703          	lbu	a4,1(s1)
     676:	03e00793          	li	a5,62
      s++;
     67a:	0489                	addi	s1,s1,2
      ret = '+';
     67c:	02b00a93          	li	s5,43
    if(*s == '>'){
     680:	faf702e3          	beq	a4,a5,624 <gettoken+0x78>
    s++;
     684:	84b6                	mv	s1,a3
  ret = *s;
     686:	03e00a93          	li	s5,62
     68a:	bf69                	j	624 <gettoken+0x78>
  switch(*s){
     68c:	07c00713          	li	a4,124
     690:	f8e789e3          	beq	a5,a4,622 <gettoken+0x76>
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     694:	00002997          	auipc	s3,0x2
     698:	97498993          	addi	s3,s3,-1676 # 2008 <whitespace>
     69c:	00002a97          	auipc	s5,0x2
     6a0:	964a8a93          	addi	s5,s5,-1692 # 2000 <symbols>
     6a4:	0324fd63          	bgeu	s1,s2,6de <gettoken+0x132>
     6a8:	0004c583          	lbu	a1,0(s1)
     6ac:	854e                	mv	a0,s3
     6ae:	652000ef          	jal	d00 <strchr>
     6b2:	e11d                	bnez	a0,6d8 <gettoken+0x12c>
     6b4:	0004c583          	lbu	a1,0(s1)
     6b8:	8556                	mv	a0,s5
     6ba:	646000ef          	jal	d00 <strchr>
     6be:	e911                	bnez	a0,6d2 <gettoken+0x126>
      s++;
     6c0:	0485                	addi	s1,s1,1
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     6c2:	fe9913e3          	bne	s2,s1,6a8 <gettoken+0xfc>
  if(eq)
     6c6:	84ca                	mv	s1,s2
    ret = 'a';
     6c8:	06100a93          	li	s5,97
  if(eq)
     6cc:	f40b1ee3          	bnez	s6,628 <gettoken+0x7c>
     6d0:	bfb5                	j	64c <gettoken+0xa0>
    ret = 'a';
     6d2:	06100a93          	li	s5,97
     6d6:	b7b9                	j	624 <gettoken+0x78>
     6d8:	06100a93          	li	s5,97
     6dc:	b7a1                	j	624 <gettoken+0x78>
     6de:	06100a93          	li	s5,97
  if(eq)
     6e2:	f40b13e3          	bnez	s6,628 <gettoken+0x7c>
     6e6:	b79d                	j	64c <gettoken+0xa0>

00000000000006e8 <peek>:

int
peek(char **ps, char *es, char *toks)
{
     6e8:	7139                	addi	sp,sp,-64
     6ea:	fc06                	sd	ra,56(sp)
     6ec:	f822                	sd	s0,48(sp)
     6ee:	f426                	sd	s1,40(sp)
     6f0:	f04a                	sd	s2,32(sp)
     6f2:	ec4e                	sd	s3,24(sp)
     6f4:	e852                	sd	s4,16(sp)
     6f6:	e456                	sd	s5,8(sp)
     6f8:	0080                	addi	s0,sp,64
     6fa:	8a2a                	mv	s4,a0
     6fc:	892e                	mv	s2,a1
     6fe:	8ab2                	mv	s5,a2
  char *s;

  s = *ps;
     700:	6104                	ld	s1,0(a0)
  while(s < es && strchr(whitespace, *s))
     702:	00002997          	auipc	s3,0x2
     706:	90698993          	addi	s3,s3,-1786 # 2008 <whitespace>
     70a:	00b4fc63          	bgeu	s1,a1,722 <peek+0x3a>
     70e:	0004c583          	lbu	a1,0(s1)
     712:	854e                	mv	a0,s3
     714:	5ec000ef          	jal	d00 <strchr>
     718:	c509                	beqz	a0,722 <peek+0x3a>
    s++;
     71a:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     71c:	fe9919e3          	bne	s2,s1,70e <peek+0x26>
     720:	84ca                	mv	s1,s2
  *ps = s;
     722:	009a3023          	sd	s1,0(s4)
  return *s && strchr(toks, *s);
     726:	0004c583          	lbu	a1,0(s1)
     72a:	4501                	li	a0,0
     72c:	e991                	bnez	a1,740 <peek+0x58>
}
     72e:	70e2                	ld	ra,56(sp)
     730:	7442                	ld	s0,48(sp)
     732:	74a2                	ld	s1,40(sp)
     734:	7902                	ld	s2,32(sp)
     736:	69e2                	ld	s3,24(sp)
     738:	6a42                	ld	s4,16(sp)
     73a:	6aa2                	ld	s5,8(sp)
     73c:	6121                	addi	sp,sp,64
     73e:	8082                	ret
  return *s && strchr(toks, *s);
     740:	8556                	mv	a0,s5
     742:	5be000ef          	jal	d00 <strchr>
     746:	00a03533          	snez	a0,a0
     74a:	b7d5                	j	72e <peek+0x46>

000000000000074c <parseredirs>:
  return cmd;
}

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     74c:	7159                	addi	sp,sp,-112
     74e:	f486                	sd	ra,104(sp)
     750:	f0a2                	sd	s0,96(sp)
     752:	eca6                	sd	s1,88(sp)
     754:	e8ca                	sd	s2,80(sp)
     756:	e4ce                	sd	s3,72(sp)
     758:	e0d2                	sd	s4,64(sp)
     75a:	fc56                	sd	s5,56(sp)
     75c:	f85a                	sd	s6,48(sp)
     75e:	f45e                	sd	s7,40(sp)
     760:	f062                	sd	s8,32(sp)
     762:	ec66                	sd	s9,24(sp)
     764:	1880                	addi	s0,sp,112
     766:	8a2a                	mv	s4,a0
     768:	89ae                	mv	s3,a1
     76a:	8932                	mv	s2,a2
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     76c:	00001b17          	auipc	s6,0x1
     770:	df4b0b13          	addi	s6,s6,-524 # 1560 <malloc+0x1be>
    tok = gettoken(ps, es, 0, 0);
    if(gettoken(ps, es, &q, &eq) != 'a')
     774:	f9040c93          	addi	s9,s0,-112
     778:	f9840c13          	addi	s8,s0,-104
     77c:	06100b93          	li	s7,97
  while(peek(ps, es, "<>")){
     780:	a00d                	j	7a2 <parseredirs+0x56>
      panic("missing file for redirection");
     782:	00001517          	auipc	a0,0x1
     786:	dbe50513          	addi	a0,a0,-578 # 1540 <malloc+0x19e>
     78a:	917ff0ef          	jal	a0 <panic>
    switch(tok){
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     78e:	4701                	li	a4,0
     790:	4681                	li	a3,0
     792:	f9043603          	ld	a2,-112(s0)
     796:	f9843583          	ld	a1,-104(s0)
     79a:	8552                	mv	a0,s4
     79c:	d01ff0ef          	jal	49c <redircmd>
     7a0:	8a2a                	mv	s4,a0
    switch(tok){
     7a2:	03c00a93          	li	s5,60
  while(peek(ps, es, "<>")){
     7a6:	865a                	mv	a2,s6
     7a8:	85ca                	mv	a1,s2
     7aa:	854e                	mv	a0,s3
     7ac:	f3dff0ef          	jal	6e8 <peek>
     7b0:	c135                	beqz	a0,814 <parseredirs+0xc8>
    tok = gettoken(ps, es, 0, 0);
     7b2:	4681                	li	a3,0
     7b4:	4601                	li	a2,0
     7b6:	85ca                	mv	a1,s2
     7b8:	854e                	mv	a0,s3
     7ba:	df3ff0ef          	jal	5ac <gettoken>
     7be:	84aa                	mv	s1,a0
    if(gettoken(ps, es, &q, &eq) != 'a')
     7c0:	86e6                	mv	a3,s9
     7c2:	8662                	mv	a2,s8
     7c4:	85ca                	mv	a1,s2
     7c6:	854e                	mv	a0,s3
     7c8:	de5ff0ef          	jal	5ac <gettoken>
     7cc:	fb751be3          	bne	a0,s7,782 <parseredirs+0x36>
    switch(tok){
     7d0:	fb548fe3          	beq	s1,s5,78e <parseredirs+0x42>
     7d4:	03e00793          	li	a5,62
     7d8:	02f48263          	beq	s1,a5,7fc <parseredirs+0xb0>
     7dc:	02b00793          	li	a5,43
     7e0:	fcf493e3          	bne	s1,a5,7a6 <parseredirs+0x5a>
      break;
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE|O_TRUNC, 1);
      break;
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     7e4:	4705                	li	a4,1
     7e6:	20100693          	li	a3,513
     7ea:	f9043603          	ld	a2,-112(s0)
     7ee:	f9843583          	ld	a1,-104(s0)
     7f2:	8552                	mv	a0,s4
     7f4:	ca9ff0ef          	jal	49c <redircmd>
     7f8:	8a2a                	mv	s4,a0
      break;
     7fa:	b765                	j	7a2 <parseredirs+0x56>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE|O_TRUNC, 1);
     7fc:	4705                	li	a4,1
     7fe:	60100693          	li	a3,1537
     802:	f9043603          	ld	a2,-112(s0)
     806:	f9843583          	ld	a1,-104(s0)
     80a:	8552                	mv	a0,s4
     80c:	c91ff0ef          	jal	49c <redircmd>
     810:	8a2a                	mv	s4,a0
      break;
     812:	bf41                	j	7a2 <parseredirs+0x56>
    }
  }
  return cmd;
}
     814:	8552                	mv	a0,s4
     816:	70a6                	ld	ra,104(sp)
     818:	7406                	ld	s0,96(sp)
     81a:	64e6                	ld	s1,88(sp)
     81c:	6946                	ld	s2,80(sp)
     81e:	69a6                	ld	s3,72(sp)
     820:	6a06                	ld	s4,64(sp)
     822:	7ae2                	ld	s5,56(sp)
     824:	7b42                	ld	s6,48(sp)
     826:	7ba2                	ld	s7,40(sp)
     828:	7c02                	ld	s8,32(sp)
     82a:	6ce2                	ld	s9,24(sp)
     82c:	6165                	addi	sp,sp,112
     82e:	8082                	ret

0000000000000830 <parseexec>:
  return cmd;
}

struct cmd*
parseexec(char **ps, char *es)
{
     830:	7119                	addi	sp,sp,-128
     832:	fc86                	sd	ra,120(sp)
     834:	f8a2                	sd	s0,112(sp)
     836:	f4a6                	sd	s1,104(sp)
     838:	e8d2                	sd	s4,80(sp)
     83a:	e4d6                	sd	s5,72(sp)
     83c:	0100                	addi	s0,sp,128
     83e:	8a2a                	mv	s4,a0
     840:	8aae                	mv	s5,a1
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;

  if(peek(ps, es, "("))
     842:	00001617          	auipc	a2,0x1
     846:	d2660613          	addi	a2,a2,-730 # 1568 <malloc+0x1c6>
     84a:	e9fff0ef          	jal	6e8 <peek>
     84e:	e121                	bnez	a0,88e <parseexec+0x5e>
     850:	f0ca                	sd	s2,96(sp)
     852:	ecce                	sd	s3,88(sp)
     854:	e0da                	sd	s6,64(sp)
     856:	fc5e                	sd	s7,56(sp)
     858:	f862                	sd	s8,48(sp)
     85a:	f466                	sd	s9,40(sp)
     85c:	f06a                	sd	s10,32(sp)
     85e:	ec6e                	sd	s11,24(sp)
     860:	89aa                	mv	s3,a0
    return parseblock(ps, es);

  ret = execcmd();
     862:	c0dff0ef          	jal	46e <execcmd>
     866:	8daa                	mv	s11,a0
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
     868:	8656                	mv	a2,s5
     86a:	85d2                	mv	a1,s4
     86c:	ee1ff0ef          	jal	74c <parseredirs>
     870:	84aa                	mv	s1,a0
  while(!peek(ps, es, "|)&;")){
     872:	008d8913          	addi	s2,s11,8
     876:	00001b17          	auipc	s6,0x1
     87a:	d12b0b13          	addi	s6,s6,-750 # 1588 <malloc+0x1e6>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     87e:	f8040c13          	addi	s8,s0,-128
     882:	f8840b93          	addi	s7,s0,-120
      break;
    if(tok != 'a')
     886:	06100d13          	li	s10,97
      panic("syntax");
    cmd->argv[argc] = q;
    cmd->eargv[argc] = eq;
    argc++;
    if(argc >= MAXARGS)
     88a:	4ca9                	li	s9,10
  while(!peek(ps, es, "|)&;")){
     88c:	a815                	j	8c0 <parseexec+0x90>
    return parseblock(ps, es);
     88e:	85d6                	mv	a1,s5
     890:	8552                	mv	a0,s4
     892:	170000ef          	jal	a02 <parseblock>
     896:	84aa                	mv	s1,a0
    ret = parseredirs(ret, ps, es);
  }
  cmd->argv[argc] = 0;
  cmd->eargv[argc] = 0;
  return ret;
}
     898:	8526                	mv	a0,s1
     89a:	70e6                	ld	ra,120(sp)
     89c:	7446                	ld	s0,112(sp)
     89e:	74a6                	ld	s1,104(sp)
     8a0:	6a46                	ld	s4,80(sp)
     8a2:	6aa6                	ld	s5,72(sp)
     8a4:	6109                	addi	sp,sp,128
     8a6:	8082                	ret
      panic("syntax");
     8a8:	00001517          	auipc	a0,0x1
     8ac:	cc850513          	addi	a0,a0,-824 # 1570 <malloc+0x1ce>
     8b0:	ff0ff0ef          	jal	a0 <panic>
    ret = parseredirs(ret, ps, es);
     8b4:	8656                	mv	a2,s5
     8b6:	85d2                	mv	a1,s4
     8b8:	8526                	mv	a0,s1
     8ba:	e93ff0ef          	jal	74c <parseredirs>
     8be:	84aa                	mv	s1,a0
  while(!peek(ps, es, "|)&;")){
     8c0:	865a                	mv	a2,s6
     8c2:	85d6                	mv	a1,s5
     8c4:	8552                	mv	a0,s4
     8c6:	e23ff0ef          	jal	6e8 <peek>
     8ca:	ed05                	bnez	a0,902 <parseexec+0xd2>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     8cc:	86e2                	mv	a3,s8
     8ce:	865e                	mv	a2,s7
     8d0:	85d6                	mv	a1,s5
     8d2:	8552                	mv	a0,s4
     8d4:	cd9ff0ef          	jal	5ac <gettoken>
     8d8:	c50d                	beqz	a0,902 <parseexec+0xd2>
    if(tok != 'a')
     8da:	fda517e3          	bne	a0,s10,8a8 <parseexec+0x78>
    cmd->argv[argc] = q;
     8de:	f8843783          	ld	a5,-120(s0)
     8e2:	00f93023          	sd	a5,0(s2)
    cmd->eargv[argc] = eq;
     8e6:	f8043783          	ld	a5,-128(s0)
     8ea:	04f93823          	sd	a5,80(s2)
    argc++;
     8ee:	2985                	addiw	s3,s3,1
    if(argc >= MAXARGS)
     8f0:	0921                	addi	s2,s2,8
     8f2:	fd9991e3          	bne	s3,s9,8b4 <parseexec+0x84>
      panic("too many args");
     8f6:	00001517          	auipc	a0,0x1
     8fa:	c8250513          	addi	a0,a0,-894 # 1578 <malloc+0x1d6>
     8fe:	fa2ff0ef          	jal	a0 <panic>
  cmd->argv[argc] = 0;
     902:	098e                	slli	s3,s3,0x3
     904:	9dce                	add	s11,s11,s3
     906:	000db423          	sd	zero,8(s11)
  cmd->eargv[argc] = 0;
     90a:	040dbc23          	sd	zero,88(s11)
     90e:	7906                	ld	s2,96(sp)
     910:	69e6                	ld	s3,88(sp)
     912:	6b06                	ld	s6,64(sp)
     914:	7be2                	ld	s7,56(sp)
     916:	7c42                	ld	s8,48(sp)
     918:	7ca2                	ld	s9,40(sp)
     91a:	7d02                	ld	s10,32(sp)
     91c:	6de2                	ld	s11,24(sp)
  return ret;
     91e:	bfad                	j	898 <parseexec+0x68>

0000000000000920 <parsepipe>:
{
     920:	7179                	addi	sp,sp,-48
     922:	f406                	sd	ra,40(sp)
     924:	f022                	sd	s0,32(sp)
     926:	ec26                	sd	s1,24(sp)
     928:	e84a                	sd	s2,16(sp)
     92a:	e44e                	sd	s3,8(sp)
     92c:	1800                	addi	s0,sp,48
     92e:	892a                	mv	s2,a0
     930:	89ae                	mv	s3,a1
  cmd = parseexec(ps, es);
     932:	effff0ef          	jal	830 <parseexec>
     936:	84aa                	mv	s1,a0
  if(peek(ps, es, "|")){
     938:	00001617          	auipc	a2,0x1
     93c:	c5860613          	addi	a2,a2,-936 # 1590 <malloc+0x1ee>
     940:	85ce                	mv	a1,s3
     942:	854a                	mv	a0,s2
     944:	da5ff0ef          	jal	6e8 <peek>
     948:	e909                	bnez	a0,95a <parsepipe+0x3a>
}
     94a:	8526                	mv	a0,s1
     94c:	70a2                	ld	ra,40(sp)
     94e:	7402                	ld	s0,32(sp)
     950:	64e2                	ld	s1,24(sp)
     952:	6942                	ld	s2,16(sp)
     954:	69a2                	ld	s3,8(sp)
     956:	6145                	addi	sp,sp,48
     958:	8082                	ret
    gettoken(ps, es, 0, 0);
     95a:	4681                	li	a3,0
     95c:	4601                	li	a2,0
     95e:	85ce                	mv	a1,s3
     960:	854a                	mv	a0,s2
     962:	c4bff0ef          	jal	5ac <gettoken>
    cmd = pipecmd(cmd, parsepipe(ps, es));
     966:	85ce                	mv	a1,s3
     968:	854a                	mv	a0,s2
     96a:	fb7ff0ef          	jal	920 <parsepipe>
     96e:	85aa                	mv	a1,a0
     970:	8526                	mv	a0,s1
     972:	b8bff0ef          	jal	4fc <pipecmd>
     976:	84aa                	mv	s1,a0
  return cmd;
     978:	bfc9                	j	94a <parsepipe+0x2a>

000000000000097a <parseline>:
{
     97a:	7179                	addi	sp,sp,-48
     97c:	f406                	sd	ra,40(sp)
     97e:	f022                	sd	s0,32(sp)
     980:	ec26                	sd	s1,24(sp)
     982:	e84a                	sd	s2,16(sp)
     984:	e44e                	sd	s3,8(sp)
     986:	e052                	sd	s4,0(sp)
     988:	1800                	addi	s0,sp,48
     98a:	892a                	mv	s2,a0
     98c:	89ae                	mv	s3,a1
  cmd = parsepipe(ps, es);
     98e:	f93ff0ef          	jal	920 <parsepipe>
     992:	84aa                	mv	s1,a0
  while(peek(ps, es, "&")){
     994:	00001a17          	auipc	s4,0x1
     998:	c04a0a13          	addi	s4,s4,-1020 # 1598 <malloc+0x1f6>
     99c:	a819                	j	9b2 <parseline+0x38>
    gettoken(ps, es, 0, 0);
     99e:	4681                	li	a3,0
     9a0:	4601                	li	a2,0
     9a2:	85ce                	mv	a1,s3
     9a4:	854a                	mv	a0,s2
     9a6:	c07ff0ef          	jal	5ac <gettoken>
    cmd = backcmd(cmd);
     9aa:	8526                	mv	a0,s1
     9ac:	bcdff0ef          	jal	578 <backcmd>
     9b0:	84aa                	mv	s1,a0
  while(peek(ps, es, "&")){
     9b2:	8652                	mv	a2,s4
     9b4:	85ce                	mv	a1,s3
     9b6:	854a                	mv	a0,s2
     9b8:	d31ff0ef          	jal	6e8 <peek>
     9bc:	f16d                	bnez	a0,99e <parseline+0x24>
  if(peek(ps, es, ";")){
     9be:	00001617          	auipc	a2,0x1
     9c2:	be260613          	addi	a2,a2,-1054 # 15a0 <malloc+0x1fe>
     9c6:	85ce                	mv	a1,s3
     9c8:	854a                	mv	a0,s2
     9ca:	d1fff0ef          	jal	6e8 <peek>
     9ce:	e911                	bnez	a0,9e2 <parseline+0x68>
}
     9d0:	8526                	mv	a0,s1
     9d2:	70a2                	ld	ra,40(sp)
     9d4:	7402                	ld	s0,32(sp)
     9d6:	64e2                	ld	s1,24(sp)
     9d8:	6942                	ld	s2,16(sp)
     9da:	69a2                	ld	s3,8(sp)
     9dc:	6a02                	ld	s4,0(sp)
     9de:	6145                	addi	sp,sp,48
     9e0:	8082                	ret
    gettoken(ps, es, 0, 0);
     9e2:	4681                	li	a3,0
     9e4:	4601                	li	a2,0
     9e6:	85ce                	mv	a1,s3
     9e8:	854a                	mv	a0,s2
     9ea:	bc3ff0ef          	jal	5ac <gettoken>
    cmd = listcmd(cmd, parseline(ps, es));
     9ee:	85ce                	mv	a1,s3
     9f0:	854a                	mv	a0,s2
     9f2:	f89ff0ef          	jal	97a <parseline>
     9f6:	85aa                	mv	a1,a0
     9f8:	8526                	mv	a0,s1
     9fa:	b41ff0ef          	jal	53a <listcmd>
     9fe:	84aa                	mv	s1,a0
  return cmd;
     a00:	bfc1                	j	9d0 <parseline+0x56>

0000000000000a02 <parseblock>:
{
     a02:	7179                	addi	sp,sp,-48
     a04:	f406                	sd	ra,40(sp)
     a06:	f022                	sd	s0,32(sp)
     a08:	ec26                	sd	s1,24(sp)
     a0a:	e84a                	sd	s2,16(sp)
     a0c:	e44e                	sd	s3,8(sp)
     a0e:	1800                	addi	s0,sp,48
     a10:	84aa                	mv	s1,a0
     a12:	892e                	mv	s2,a1
  if(!peek(ps, es, "("))
     a14:	00001617          	auipc	a2,0x1
     a18:	b5460613          	addi	a2,a2,-1196 # 1568 <malloc+0x1c6>
     a1c:	ccdff0ef          	jal	6e8 <peek>
     a20:	c539                	beqz	a0,a6e <parseblock+0x6c>
  gettoken(ps, es, 0, 0);
     a22:	4681                	li	a3,0
     a24:	4601                	li	a2,0
     a26:	85ca                	mv	a1,s2
     a28:	8526                	mv	a0,s1
     a2a:	b83ff0ef          	jal	5ac <gettoken>
  cmd = parseline(ps, es);
     a2e:	85ca                	mv	a1,s2
     a30:	8526                	mv	a0,s1
     a32:	f49ff0ef          	jal	97a <parseline>
     a36:	89aa                	mv	s3,a0
  if(!peek(ps, es, ")"))
     a38:	00001617          	auipc	a2,0x1
     a3c:	b8060613          	addi	a2,a2,-1152 # 15b8 <malloc+0x216>
     a40:	85ca                	mv	a1,s2
     a42:	8526                	mv	a0,s1
     a44:	ca5ff0ef          	jal	6e8 <peek>
     a48:	c90d                	beqz	a0,a7a <parseblock+0x78>
  gettoken(ps, es, 0, 0);
     a4a:	4681                	li	a3,0
     a4c:	4601                	li	a2,0
     a4e:	85ca                	mv	a1,s2
     a50:	8526                	mv	a0,s1
     a52:	b5bff0ef          	jal	5ac <gettoken>
  cmd = parseredirs(cmd, ps, es);
     a56:	864a                	mv	a2,s2
     a58:	85a6                	mv	a1,s1
     a5a:	854e                	mv	a0,s3
     a5c:	cf1ff0ef          	jal	74c <parseredirs>
}
     a60:	70a2                	ld	ra,40(sp)
     a62:	7402                	ld	s0,32(sp)
     a64:	64e2                	ld	s1,24(sp)
     a66:	6942                	ld	s2,16(sp)
     a68:	69a2                	ld	s3,8(sp)
     a6a:	6145                	addi	sp,sp,48
     a6c:	8082                	ret
    panic("parseblock");
     a6e:	00001517          	auipc	a0,0x1
     a72:	b3a50513          	addi	a0,a0,-1222 # 15a8 <malloc+0x206>
     a76:	e2aff0ef          	jal	a0 <panic>
    panic("syntax - missing )");
     a7a:	00001517          	auipc	a0,0x1
     a7e:	b4650513          	addi	a0,a0,-1210 # 15c0 <malloc+0x21e>
     a82:	e1eff0ef          	jal	a0 <panic>

0000000000000a86 <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
     a86:	1101                	addi	sp,sp,-32
     a88:	ec06                	sd	ra,24(sp)
     a8a:	e822                	sd	s0,16(sp)
     a8c:	e426                	sd	s1,8(sp)
     a8e:	1000                	addi	s0,sp,32
     a90:	84aa                	mv	s1,a0
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
     a92:	c131                	beqz	a0,ad6 <nulterminate+0x50>
    return 0;

  switch(cmd->type){
     a94:	4118                	lw	a4,0(a0)
     a96:	4795                	li	a5,5
     a98:	02e7ef63          	bltu	a5,a4,ad6 <nulterminate+0x50>
     a9c:	00056783          	lwu	a5,0(a0)
     aa0:	078a                	slli	a5,a5,0x2
     aa2:	00001717          	auipc	a4,0x1
     aa6:	b7e70713          	addi	a4,a4,-1154 # 1620 <malloc+0x27e>
     aaa:	97ba                	add	a5,a5,a4
     aac:	439c                	lw	a5,0(a5)
     aae:	97ba                	add	a5,a5,a4
     ab0:	8782                	jr	a5
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
     ab2:	651c                	ld	a5,8(a0)
     ab4:	c38d                	beqz	a5,ad6 <nulterminate+0x50>
     ab6:	01050793          	addi	a5,a0,16
      *ecmd->eargv[i] = 0;
     aba:	67b8                	ld	a4,72(a5)
     abc:	00070023          	sb	zero,0(a4)
    for(i=0; ecmd->argv[i]; i++)
     ac0:	07a1                	addi	a5,a5,8
     ac2:	ff87b703          	ld	a4,-8(a5)
     ac6:	fb75                	bnez	a4,aba <nulterminate+0x34>
     ac8:	a039                	j	ad6 <nulterminate+0x50>
    break;

  case REDIR:
    rcmd = (struct redircmd*)cmd;
    nulterminate(rcmd->cmd);
     aca:	6508                	ld	a0,8(a0)
     acc:	fbbff0ef          	jal	a86 <nulterminate>
    *rcmd->efile = 0;
     ad0:	6c9c                	ld	a5,24(s1)
     ad2:	00078023          	sb	zero,0(a5)
    bcmd = (struct backcmd*)cmd;
    nulterminate(bcmd->cmd);
    break;
  }
  return cmd;
}
     ad6:	8526                	mv	a0,s1
     ad8:	60e2                	ld	ra,24(sp)
     ada:	6442                	ld	s0,16(sp)
     adc:	64a2                	ld	s1,8(sp)
     ade:	6105                	addi	sp,sp,32
     ae0:	8082                	ret
    nulterminate(pcmd->left);
     ae2:	6508                	ld	a0,8(a0)
     ae4:	fa3ff0ef          	jal	a86 <nulterminate>
    nulterminate(pcmd->right);
     ae8:	6888                	ld	a0,16(s1)
     aea:	f9dff0ef          	jal	a86 <nulterminate>
    break;
     aee:	b7e5                	j	ad6 <nulterminate+0x50>
    nulterminate(lcmd->left);
     af0:	6508                	ld	a0,8(a0)
     af2:	f95ff0ef          	jal	a86 <nulterminate>
    nulterminate(lcmd->right);
     af6:	6888                	ld	a0,16(s1)
     af8:	f8fff0ef          	jal	a86 <nulterminate>
    break;
     afc:	bfe9                	j	ad6 <nulterminate+0x50>
    nulterminate(bcmd->cmd);
     afe:	6508                	ld	a0,8(a0)
     b00:	f87ff0ef          	jal	a86 <nulterminate>
    break;
     b04:	bfc9                	j	ad6 <nulterminate+0x50>

0000000000000b06 <parsecmd>:
{
     b06:	7139                	addi	sp,sp,-64
     b08:	fc06                	sd	ra,56(sp)
     b0a:	f822                	sd	s0,48(sp)
     b0c:	f426                	sd	s1,40(sp)
     b0e:	f04a                	sd	s2,32(sp)
     b10:	ec4e                	sd	s3,24(sp)
     b12:	0080                	addi	s0,sp,64
     b14:	fca43423          	sd	a0,-56(s0)
  es = s + strlen(s);
     b18:	84aa                	mv	s1,a0
     b1a:	192000ef          	jal	cac <strlen>
     b1e:	1502                	slli	a0,a0,0x20
     b20:	9101                	srli	a0,a0,0x20
     b22:	94aa                	add	s1,s1,a0
  cmd = parseline(&s, es);
     b24:	fc840993          	addi	s3,s0,-56
     b28:	85a6                	mv	a1,s1
     b2a:	854e                	mv	a0,s3
     b2c:	e4fff0ef          	jal	97a <parseline>
     b30:	892a                	mv	s2,a0
  peek(&s, es, "");
     b32:	00001617          	auipc	a2,0x1
     b36:	97660613          	addi	a2,a2,-1674 # 14a8 <malloc+0x106>
     b3a:	85a6                	mv	a1,s1
     b3c:	854e                	mv	a0,s3
     b3e:	babff0ef          	jal	6e8 <peek>
  if(s != es){
     b42:	fc843603          	ld	a2,-56(s0)
     b46:	00961d63          	bne	a2,s1,b60 <parsecmd+0x5a>
  nulterminate(cmd);
     b4a:	854a                	mv	a0,s2
     b4c:	f3bff0ef          	jal	a86 <nulterminate>
}
     b50:	854a                	mv	a0,s2
     b52:	70e2                	ld	ra,56(sp)
     b54:	7442                	ld	s0,48(sp)
     b56:	74a2                	ld	s1,40(sp)
     b58:	7902                	ld	s2,32(sp)
     b5a:	69e2                	ld	s3,24(sp)
     b5c:	6121                	addi	sp,sp,64
     b5e:	8082                	ret
    fprintf(2, "leftovers: %s\n", s);
     b60:	00001597          	auipc	a1,0x1
     b64:	a7858593          	addi	a1,a1,-1416 # 15d8 <malloc+0x236>
     b68:	4509                	li	a0,2
     b6a:	756000ef          	jal	12c0 <fprintf>
    panic("syntax");
     b6e:	00001517          	auipc	a0,0x1
     b72:	a0250513          	addi	a0,a0,-1534 # 1570 <malloc+0x1ce>
     b76:	d2aff0ef          	jal	a0 <panic>

0000000000000b7a <main>:
{
     b7a:	7139                	addi	sp,sp,-64
     b7c:	fc06                	sd	ra,56(sp)
     b7e:	f822                	sd	s0,48(sp)
     b80:	f426                	sd	s1,40(sp)
     b82:	f04a                	sd	s2,32(sp)
     b84:	ec4e                	sd	s3,24(sp)
     b86:	e852                	sd	s4,16(sp)
     b88:	e456                	sd	s5,8(sp)
     b8a:	0080                	addi	s0,sp,64
  while((fd = open("console", O_RDWR)) >= 0){
     b8c:	4489                	li	s1,2
     b8e:	00001917          	auipc	s2,0x1
     b92:	a5a90913          	addi	s2,s2,-1446 # 15e8 <malloc+0x246>
     b96:	85a6                	mv	a1,s1
     b98:	854a                	mv	a0,s2
     b9a:	38e000ef          	jal	f28 <open>
     b9e:	00054663          	bltz	a0,baa <main+0x30>
    if(fd >= 3){
     ba2:	fea4dae3          	bge	s1,a0,b96 <main+0x1c>
      close(fd);
     ba6:	36a000ef          	jal	f10 <close>
  while(getcmd(buf, sizeof(buf)) >= 0){
     baa:	00001497          	auipc	s1,0x1
     bae:	47648493          	addi	s1,s1,1142 # 2020 <buf.0>
     bb2:	06400913          	li	s2,100
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     bb6:	06300993          	li	s3,99
     bba:	02000a13          	li	s4,32
     bbe:	a039                	j	bcc <main+0x52>
    if(fork1() == 0)
     bc0:	cfeff0ef          	jal	be <fork1>
     bc4:	c925                	beqz	a0,c34 <main+0xba>
    wait(0);
     bc6:	4501                	li	a0,0
     bc8:	328000ef          	jal	ef0 <wait>
  while(getcmd(buf, sizeof(buf)) >= 0){
     bcc:	85ca                	mv	a1,s2
     bce:	8526                	mv	a0,s1
     bd0:	c86ff0ef          	jal	56 <getcmd>
     bd4:	06054863          	bltz	a0,c44 <main+0xca>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     bd8:	0004c783          	lbu	a5,0(s1)
     bdc:	ff3792e3          	bne	a5,s3,bc0 <main+0x46>
     be0:	0014c783          	lbu	a5,1(s1)
     be4:	fd279ee3          	bne	a5,s2,bc0 <main+0x46>
     be8:	0024c783          	lbu	a5,2(s1)
     bec:	fd479ae3          	bne	a5,s4,bc0 <main+0x46>
      buf[strlen(buf)-1] = 0;  // chop \n
     bf0:	00001a97          	auipc	s5,0x1
     bf4:	430a8a93          	addi	s5,s5,1072 # 2020 <buf.0>
     bf8:	8556                	mv	a0,s5
     bfa:	0b2000ef          	jal	cac <strlen>
     bfe:	fff5079b          	addiw	a5,a0,-1
     c02:	1782                	slli	a5,a5,0x20
     c04:	9381                	srli	a5,a5,0x20
     c06:	9abe                	add	s5,s5,a5
     c08:	000a8023          	sb	zero,0(s5)
      if(chdir(buf+3) < 0)
     c0c:	00001517          	auipc	a0,0x1
     c10:	41750513          	addi	a0,a0,1047 # 2023 <buf.0+0x3>
     c14:	344000ef          	jal	f58 <chdir>
     c18:	fa055ae3          	bgez	a0,bcc <main+0x52>
        fprintf(2, "cannot cd %s\n", buf+3);
     c1c:	00001617          	auipc	a2,0x1
     c20:	40760613          	addi	a2,a2,1031 # 2023 <buf.0+0x3>
     c24:	00001597          	auipc	a1,0x1
     c28:	9cc58593          	addi	a1,a1,-1588 # 15f0 <malloc+0x24e>
     c2c:	4509                	li	a0,2
     c2e:	692000ef          	jal	12c0 <fprintf>
     c32:	bf69                	j	bcc <main+0x52>
      runcmd(parsecmd(buf));
     c34:	00001517          	auipc	a0,0x1
     c38:	3ec50513          	addi	a0,a0,1004 # 2020 <buf.0>
     c3c:	ecbff0ef          	jal	b06 <parsecmd>
     c40:	ca4ff0ef          	jal	e4 <runcmd>
  exit(0);
     c44:	4501                	li	a0,0
     c46:	2a2000ef          	jal	ee8 <exit>

0000000000000c4a <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
     c4a:	1141                	addi	sp,sp,-16
     c4c:	e406                	sd	ra,8(sp)
     c4e:	e022                	sd	s0,0(sp)
     c50:	0800                	addi	s0,sp,16
  extern int main();
  main();
     c52:	f29ff0ef          	jal	b7a <main>
  exit(0);
     c56:	4501                	li	a0,0
     c58:	290000ef          	jal	ee8 <exit>

0000000000000c5c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
     c5c:	1141                	addi	sp,sp,-16
     c5e:	e406                	sd	ra,8(sp)
     c60:	e022                	sd	s0,0(sp)
     c62:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     c64:	87aa                	mv	a5,a0
     c66:	0585                	addi	a1,a1,1
     c68:	0785                	addi	a5,a5,1
     c6a:	fff5c703          	lbu	a4,-1(a1)
     c6e:	fee78fa3          	sb	a4,-1(a5)
     c72:	fb75                	bnez	a4,c66 <strcpy+0xa>
    ;
  return os;
}
     c74:	60a2                	ld	ra,8(sp)
     c76:	6402                	ld	s0,0(sp)
     c78:	0141                	addi	sp,sp,16
     c7a:	8082                	ret

0000000000000c7c <strcmp>:

int
strcmp(const char *p, const char *q)
{
     c7c:	1141                	addi	sp,sp,-16
     c7e:	e406                	sd	ra,8(sp)
     c80:	e022                	sd	s0,0(sp)
     c82:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     c84:	00054783          	lbu	a5,0(a0)
     c88:	cb91                	beqz	a5,c9c <strcmp+0x20>
     c8a:	0005c703          	lbu	a4,0(a1)
     c8e:	00f71763          	bne	a4,a5,c9c <strcmp+0x20>
    p++, q++;
     c92:	0505                	addi	a0,a0,1
     c94:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     c96:	00054783          	lbu	a5,0(a0)
     c9a:	fbe5                	bnez	a5,c8a <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
     c9c:	0005c503          	lbu	a0,0(a1)
}
     ca0:	40a7853b          	subw	a0,a5,a0
     ca4:	60a2                	ld	ra,8(sp)
     ca6:	6402                	ld	s0,0(sp)
     ca8:	0141                	addi	sp,sp,16
     caa:	8082                	ret

0000000000000cac <strlen>:

uint
strlen(const char *s)
{
     cac:	1141                	addi	sp,sp,-16
     cae:	e406                	sd	ra,8(sp)
     cb0:	e022                	sd	s0,0(sp)
     cb2:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     cb4:	00054783          	lbu	a5,0(a0)
     cb8:	cf99                	beqz	a5,cd6 <strlen+0x2a>
     cba:	0505                	addi	a0,a0,1
     cbc:	87aa                	mv	a5,a0
     cbe:	86be                	mv	a3,a5
     cc0:	0785                	addi	a5,a5,1
     cc2:	fff7c703          	lbu	a4,-1(a5)
     cc6:	ff65                	bnez	a4,cbe <strlen+0x12>
     cc8:	40a6853b          	subw	a0,a3,a0
     ccc:	2505                	addiw	a0,a0,1
    ;
  return n;
}
     cce:	60a2                	ld	ra,8(sp)
     cd0:	6402                	ld	s0,0(sp)
     cd2:	0141                	addi	sp,sp,16
     cd4:	8082                	ret
  for(n = 0; s[n]; n++)
     cd6:	4501                	li	a0,0
     cd8:	bfdd                	j	cce <strlen+0x22>

0000000000000cda <memset>:

void*
memset(void *dst, int c, uint n)
{
     cda:	1141                	addi	sp,sp,-16
     cdc:	e406                	sd	ra,8(sp)
     cde:	e022                	sd	s0,0(sp)
     ce0:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     ce2:	ca19                	beqz	a2,cf8 <memset+0x1e>
     ce4:	87aa                	mv	a5,a0
     ce6:	1602                	slli	a2,a2,0x20
     ce8:	9201                	srli	a2,a2,0x20
     cea:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     cee:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     cf2:	0785                	addi	a5,a5,1
     cf4:	fee79de3          	bne	a5,a4,cee <memset+0x14>
  }
  return dst;
}
     cf8:	60a2                	ld	ra,8(sp)
     cfa:	6402                	ld	s0,0(sp)
     cfc:	0141                	addi	sp,sp,16
     cfe:	8082                	ret

0000000000000d00 <strchr>:

char*
strchr(const char *s, char c)
{
     d00:	1141                	addi	sp,sp,-16
     d02:	e406                	sd	ra,8(sp)
     d04:	e022                	sd	s0,0(sp)
     d06:	0800                	addi	s0,sp,16
  for(; *s; s++)
     d08:	00054783          	lbu	a5,0(a0)
     d0c:	cf81                	beqz	a5,d24 <strchr+0x24>
    if(*s == c)
     d0e:	00f58763          	beq	a1,a5,d1c <strchr+0x1c>
  for(; *s; s++)
     d12:	0505                	addi	a0,a0,1
     d14:	00054783          	lbu	a5,0(a0)
     d18:	fbfd                	bnez	a5,d0e <strchr+0xe>
      return (char*)s;
  return 0;
     d1a:	4501                	li	a0,0
}
     d1c:	60a2                	ld	ra,8(sp)
     d1e:	6402                	ld	s0,0(sp)
     d20:	0141                	addi	sp,sp,16
     d22:	8082                	ret
  return 0;
     d24:	4501                	li	a0,0
     d26:	bfdd                	j	d1c <strchr+0x1c>

0000000000000d28 <gets>:

char*
gets(char *buf, int max)
{
     d28:	7159                	addi	sp,sp,-112
     d2a:	f486                	sd	ra,104(sp)
     d2c:	f0a2                	sd	s0,96(sp)
     d2e:	eca6                	sd	s1,88(sp)
     d30:	e8ca                	sd	s2,80(sp)
     d32:	e4ce                	sd	s3,72(sp)
     d34:	e0d2                	sd	s4,64(sp)
     d36:	fc56                	sd	s5,56(sp)
     d38:	f85a                	sd	s6,48(sp)
     d3a:	f45e                	sd	s7,40(sp)
     d3c:	f062                	sd	s8,32(sp)
     d3e:	ec66                	sd	s9,24(sp)
     d40:	e86a                	sd	s10,16(sp)
     d42:	1880                	addi	s0,sp,112
     d44:	8caa                	mv	s9,a0
     d46:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     d48:	892a                	mv	s2,a0
     d4a:	4481                	li	s1,0
    cc = read(0, &c, 1);
     d4c:	f9f40b13          	addi	s6,s0,-97
     d50:	4a85                	li	s5,1
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     d52:	4ba9                	li	s7,10
     d54:	4c35                	li	s8,13
  for(i=0; i+1 < max; ){
     d56:	8d26                	mv	s10,s1
     d58:	0014899b          	addiw	s3,s1,1
     d5c:	84ce                	mv	s1,s3
     d5e:	0349d563          	bge	s3,s4,d88 <gets+0x60>
    cc = read(0, &c, 1);
     d62:	8656                	mv	a2,s5
     d64:	85da                	mv	a1,s6
     d66:	4501                	li	a0,0
     d68:	198000ef          	jal	f00 <read>
    if(cc < 1)
     d6c:	00a05e63          	blez	a0,d88 <gets+0x60>
    buf[i++] = c;
     d70:	f9f44783          	lbu	a5,-97(s0)
     d74:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     d78:	01778763          	beq	a5,s7,d86 <gets+0x5e>
     d7c:	0905                	addi	s2,s2,1
     d7e:	fd879ce3          	bne	a5,s8,d56 <gets+0x2e>
    buf[i++] = c;
     d82:	8d4e                	mv	s10,s3
     d84:	a011                	j	d88 <gets+0x60>
     d86:	8d4e                	mv	s10,s3
      break;
  }
  buf[i] = '\0';
     d88:	9d66                	add	s10,s10,s9
     d8a:	000d0023          	sb	zero,0(s10)
  return buf;
}
     d8e:	8566                	mv	a0,s9
     d90:	70a6                	ld	ra,104(sp)
     d92:	7406                	ld	s0,96(sp)
     d94:	64e6                	ld	s1,88(sp)
     d96:	6946                	ld	s2,80(sp)
     d98:	69a6                	ld	s3,72(sp)
     d9a:	6a06                	ld	s4,64(sp)
     d9c:	7ae2                	ld	s5,56(sp)
     d9e:	7b42                	ld	s6,48(sp)
     da0:	7ba2                	ld	s7,40(sp)
     da2:	7c02                	ld	s8,32(sp)
     da4:	6ce2                	ld	s9,24(sp)
     da6:	6d42                	ld	s10,16(sp)
     da8:	6165                	addi	sp,sp,112
     daa:	8082                	ret

0000000000000dac <stat>:

int
stat(const char *n, struct stat *st)
{
     dac:	1101                	addi	sp,sp,-32
     dae:	ec06                	sd	ra,24(sp)
     db0:	e822                	sd	s0,16(sp)
     db2:	e04a                	sd	s2,0(sp)
     db4:	1000                	addi	s0,sp,32
     db6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     db8:	4581                	li	a1,0
     dba:	16e000ef          	jal	f28 <open>
  if(fd < 0)
     dbe:	02054263          	bltz	a0,de2 <stat+0x36>
     dc2:	e426                	sd	s1,8(sp)
     dc4:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     dc6:	85ca                	mv	a1,s2
     dc8:	178000ef          	jal	f40 <fstat>
     dcc:	892a                	mv	s2,a0
  close(fd);
     dce:	8526                	mv	a0,s1
     dd0:	140000ef          	jal	f10 <close>
  return r;
     dd4:	64a2                	ld	s1,8(sp)
}
     dd6:	854a                	mv	a0,s2
     dd8:	60e2                	ld	ra,24(sp)
     dda:	6442                	ld	s0,16(sp)
     ddc:	6902                	ld	s2,0(sp)
     dde:	6105                	addi	sp,sp,32
     de0:	8082                	ret
    return -1;
     de2:	597d                	li	s2,-1
     de4:	bfcd                	j	dd6 <stat+0x2a>

0000000000000de6 <atoi>:

int
atoi(const char *s)
{
     de6:	1141                	addi	sp,sp,-16
     de8:	e406                	sd	ra,8(sp)
     dea:	e022                	sd	s0,0(sp)
     dec:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     dee:	00054683          	lbu	a3,0(a0)
     df2:	fd06879b          	addiw	a5,a3,-48
     df6:	0ff7f793          	zext.b	a5,a5
     dfa:	4625                	li	a2,9
     dfc:	02f66963          	bltu	a2,a5,e2e <atoi+0x48>
     e00:	872a                	mv	a4,a0
  n = 0;
     e02:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
     e04:	0705                	addi	a4,a4,1
     e06:	0025179b          	slliw	a5,a0,0x2
     e0a:	9fa9                	addw	a5,a5,a0
     e0c:	0017979b          	slliw	a5,a5,0x1
     e10:	9fb5                	addw	a5,a5,a3
     e12:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     e16:	00074683          	lbu	a3,0(a4)
     e1a:	fd06879b          	addiw	a5,a3,-48
     e1e:	0ff7f793          	zext.b	a5,a5
     e22:	fef671e3          	bgeu	a2,a5,e04 <atoi+0x1e>
  return n;
}
     e26:	60a2                	ld	ra,8(sp)
     e28:	6402                	ld	s0,0(sp)
     e2a:	0141                	addi	sp,sp,16
     e2c:	8082                	ret
  n = 0;
     e2e:	4501                	li	a0,0
     e30:	bfdd                	j	e26 <atoi+0x40>

0000000000000e32 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     e32:	1141                	addi	sp,sp,-16
     e34:	e406                	sd	ra,8(sp)
     e36:	e022                	sd	s0,0(sp)
     e38:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     e3a:	02b57563          	bgeu	a0,a1,e64 <memmove+0x32>
    while(n-- > 0)
     e3e:	00c05f63          	blez	a2,e5c <memmove+0x2a>
     e42:	1602                	slli	a2,a2,0x20
     e44:	9201                	srli	a2,a2,0x20
     e46:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     e4a:	872a                	mv	a4,a0
      *dst++ = *src++;
     e4c:	0585                	addi	a1,a1,1
     e4e:	0705                	addi	a4,a4,1
     e50:	fff5c683          	lbu	a3,-1(a1)
     e54:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     e58:	fee79ae3          	bne	a5,a4,e4c <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     e5c:	60a2                	ld	ra,8(sp)
     e5e:	6402                	ld	s0,0(sp)
     e60:	0141                	addi	sp,sp,16
     e62:	8082                	ret
    dst += n;
     e64:	00c50733          	add	a4,a0,a2
    src += n;
     e68:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     e6a:	fec059e3          	blez	a2,e5c <memmove+0x2a>
     e6e:	fff6079b          	addiw	a5,a2,-1
     e72:	1782                	slli	a5,a5,0x20
     e74:	9381                	srli	a5,a5,0x20
     e76:	fff7c793          	not	a5,a5
     e7a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     e7c:	15fd                	addi	a1,a1,-1
     e7e:	177d                	addi	a4,a4,-1
     e80:	0005c683          	lbu	a3,0(a1)
     e84:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     e88:	fef71ae3          	bne	a4,a5,e7c <memmove+0x4a>
     e8c:	bfc1                	j	e5c <memmove+0x2a>

0000000000000e8e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     e8e:	1141                	addi	sp,sp,-16
     e90:	e406                	sd	ra,8(sp)
     e92:	e022                	sd	s0,0(sp)
     e94:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     e96:	ca0d                	beqz	a2,ec8 <memcmp+0x3a>
     e98:	fff6069b          	addiw	a3,a2,-1
     e9c:	1682                	slli	a3,a3,0x20
     e9e:	9281                	srli	a3,a3,0x20
     ea0:	0685                	addi	a3,a3,1
     ea2:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     ea4:	00054783          	lbu	a5,0(a0)
     ea8:	0005c703          	lbu	a4,0(a1)
     eac:	00e79863          	bne	a5,a4,ebc <memcmp+0x2e>
      return *p1 - *p2;
    }
    p1++;
     eb0:	0505                	addi	a0,a0,1
    p2++;
     eb2:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     eb4:	fed518e3          	bne	a0,a3,ea4 <memcmp+0x16>
  }
  return 0;
     eb8:	4501                	li	a0,0
     eba:	a019                	j	ec0 <memcmp+0x32>
      return *p1 - *p2;
     ebc:	40e7853b          	subw	a0,a5,a4
}
     ec0:	60a2                	ld	ra,8(sp)
     ec2:	6402                	ld	s0,0(sp)
     ec4:	0141                	addi	sp,sp,16
     ec6:	8082                	ret
  return 0;
     ec8:	4501                	li	a0,0
     eca:	bfdd                	j	ec0 <memcmp+0x32>

0000000000000ecc <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     ecc:	1141                	addi	sp,sp,-16
     ece:	e406                	sd	ra,8(sp)
     ed0:	e022                	sd	s0,0(sp)
     ed2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     ed4:	f5fff0ef          	jal	e32 <memmove>
}
     ed8:	60a2                	ld	ra,8(sp)
     eda:	6402                	ld	s0,0(sp)
     edc:	0141                	addi	sp,sp,16
     ede:	8082                	ret

0000000000000ee0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     ee0:	4885                	li	a7,1
 ecall
     ee2:	00000073          	ecall
 ret
     ee6:	8082                	ret

0000000000000ee8 <exit>:
.global exit
exit:
 li a7, SYS_exit
     ee8:	4889                	li	a7,2
 ecall
     eea:	00000073          	ecall
 ret
     eee:	8082                	ret

0000000000000ef0 <wait>:
.global wait
wait:
 li a7, SYS_wait
     ef0:	488d                	li	a7,3
 ecall
     ef2:	00000073          	ecall
 ret
     ef6:	8082                	ret

0000000000000ef8 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     ef8:	4891                	li	a7,4
 ecall
     efa:	00000073          	ecall
 ret
     efe:	8082                	ret

0000000000000f00 <read>:
.global read
read:
 li a7, SYS_read
     f00:	4895                	li	a7,5
 ecall
     f02:	00000073          	ecall
 ret
     f06:	8082                	ret

0000000000000f08 <write>:
.global write
write:
 li a7, SYS_write
     f08:	48c1                	li	a7,16
 ecall
     f0a:	00000073          	ecall
 ret
     f0e:	8082                	ret

0000000000000f10 <close>:
.global close
close:
 li a7, SYS_close
     f10:	48d5                	li	a7,21
 ecall
     f12:	00000073          	ecall
 ret
     f16:	8082                	ret

0000000000000f18 <kill>:
.global kill
kill:
 li a7, SYS_kill
     f18:	4899                	li	a7,6
 ecall
     f1a:	00000073          	ecall
 ret
     f1e:	8082                	ret

0000000000000f20 <exec>:
.global exec
exec:
 li a7, SYS_exec
     f20:	489d                	li	a7,7
 ecall
     f22:	00000073          	ecall
 ret
     f26:	8082                	ret

0000000000000f28 <open>:
.global open
open:
 li a7, SYS_open
     f28:	48bd                	li	a7,15
 ecall
     f2a:	00000073          	ecall
 ret
     f2e:	8082                	ret

0000000000000f30 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     f30:	48c5                	li	a7,17
 ecall
     f32:	00000073          	ecall
 ret
     f36:	8082                	ret

0000000000000f38 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     f38:	48c9                	li	a7,18
 ecall
     f3a:	00000073          	ecall
 ret
     f3e:	8082                	ret

0000000000000f40 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     f40:	48a1                	li	a7,8
 ecall
     f42:	00000073          	ecall
 ret
     f46:	8082                	ret

0000000000000f48 <link>:
.global link
link:
 li a7, SYS_link
     f48:	48cd                	li	a7,19
 ecall
     f4a:	00000073          	ecall
 ret
     f4e:	8082                	ret

0000000000000f50 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     f50:	48d1                	li	a7,20
 ecall
     f52:	00000073          	ecall
 ret
     f56:	8082                	ret

0000000000000f58 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     f58:	48a5                	li	a7,9
 ecall
     f5a:	00000073          	ecall
 ret
     f5e:	8082                	ret

0000000000000f60 <dup>:
.global dup
dup:
 li a7, SYS_dup
     f60:	48a9                	li	a7,10
 ecall
     f62:	00000073          	ecall
 ret
     f66:	8082                	ret

0000000000000f68 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     f68:	48ad                	li	a7,11
 ecall
     f6a:	00000073          	ecall
 ret
     f6e:	8082                	ret

0000000000000f70 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     f70:	48b1                	li	a7,12
 ecall
     f72:	00000073          	ecall
 ret
     f76:	8082                	ret

0000000000000f78 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     f78:	48b5                	li	a7,13
 ecall
     f7a:	00000073          	ecall
 ret
     f7e:	8082                	ret

0000000000000f80 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     f80:	48b9                	li	a7,14
 ecall
     f82:	00000073          	ecall
 ret
     f86:	8082                	ret

0000000000000f88 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     f88:	1101                	addi	sp,sp,-32
     f8a:	ec06                	sd	ra,24(sp)
     f8c:	e822                	sd	s0,16(sp)
     f8e:	1000                	addi	s0,sp,32
     f90:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     f94:	4605                	li	a2,1
     f96:	fef40593          	addi	a1,s0,-17
     f9a:	f6fff0ef          	jal	f08 <write>
}
     f9e:	60e2                	ld	ra,24(sp)
     fa0:	6442                	ld	s0,16(sp)
     fa2:	6105                	addi	sp,sp,32
     fa4:	8082                	ret

0000000000000fa6 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     fa6:	7139                	addi	sp,sp,-64
     fa8:	fc06                	sd	ra,56(sp)
     faa:	f822                	sd	s0,48(sp)
     fac:	f426                	sd	s1,40(sp)
     fae:	f04a                	sd	s2,32(sp)
     fb0:	ec4e                	sd	s3,24(sp)
     fb2:	0080                	addi	s0,sp,64
     fb4:	892a                	mv	s2,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
     fb6:	c299                	beqz	a3,fbc <printint+0x16>
     fb8:	0605ce63          	bltz	a1,1034 <printint+0x8e>
  neg = 0;
     fbc:	4e01                	li	t3,0
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
     fbe:	fc040313          	addi	t1,s0,-64
  neg = 0;
     fc2:	869a                	mv	a3,t1
  i = 0;
     fc4:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
     fc6:	00000817          	auipc	a6,0x0
     fca:	67280813          	addi	a6,a6,1650 # 1638 <digits>
     fce:	88be                	mv	a7,a5
     fd0:	0017851b          	addiw	a0,a5,1
     fd4:	87aa                	mv	a5,a0
     fd6:	02c5f73b          	remuw	a4,a1,a2
     fda:	1702                	slli	a4,a4,0x20
     fdc:	9301                	srli	a4,a4,0x20
     fde:	9742                	add	a4,a4,a6
     fe0:	00074703          	lbu	a4,0(a4)
     fe4:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
     fe8:	872e                	mv	a4,a1
     fea:	02c5d5bb          	divuw	a1,a1,a2
     fee:	0685                	addi	a3,a3,1
     ff0:	fcc77fe3          	bgeu	a4,a2,fce <printint+0x28>
  if(neg)
     ff4:	000e0c63          	beqz	t3,100c <printint+0x66>
    buf[i++] = '-';
     ff8:	fd050793          	addi	a5,a0,-48
     ffc:	00878533          	add	a0,a5,s0
    1000:	02d00793          	li	a5,45
    1004:	fef50823          	sb	a5,-16(a0)
    1008:	0028879b          	addiw	a5,a7,2

  while(--i >= 0)
    100c:	fff7899b          	addiw	s3,a5,-1
    1010:	006784b3          	add	s1,a5,t1
    putc(fd, buf[i]);
    1014:	fff4c583          	lbu	a1,-1(s1)
    1018:	854a                	mv	a0,s2
    101a:	f6fff0ef          	jal	f88 <putc>
  while(--i >= 0)
    101e:	39fd                	addiw	s3,s3,-1
    1020:	14fd                	addi	s1,s1,-1
    1022:	fe09d9e3          	bgez	s3,1014 <printint+0x6e>
}
    1026:	70e2                	ld	ra,56(sp)
    1028:	7442                	ld	s0,48(sp)
    102a:	74a2                	ld	s1,40(sp)
    102c:	7902                	ld	s2,32(sp)
    102e:	69e2                	ld	s3,24(sp)
    1030:	6121                	addi	sp,sp,64
    1032:	8082                	ret
    x = -xx;
    1034:	40b005bb          	negw	a1,a1
    neg = 1;
    1038:	4e05                	li	t3,1
    x = -xx;
    103a:	b751                	j	fbe <printint+0x18>

000000000000103c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    103c:	711d                	addi	sp,sp,-96
    103e:	ec86                	sd	ra,88(sp)
    1040:	e8a2                	sd	s0,80(sp)
    1042:	e4a6                	sd	s1,72(sp)
    1044:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    1046:	0005c483          	lbu	s1,0(a1)
    104a:	26048663          	beqz	s1,12b6 <vprintf+0x27a>
    104e:	e0ca                	sd	s2,64(sp)
    1050:	fc4e                	sd	s3,56(sp)
    1052:	f852                	sd	s4,48(sp)
    1054:	f456                	sd	s5,40(sp)
    1056:	f05a                	sd	s6,32(sp)
    1058:	ec5e                	sd	s7,24(sp)
    105a:	e862                	sd	s8,16(sp)
    105c:	e466                	sd	s9,8(sp)
    105e:	8b2a                	mv	s6,a0
    1060:	8a2e                	mv	s4,a1
    1062:	8bb2                	mv	s7,a2
  state = 0;
    1064:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
    1066:	4901                	li	s2,0
    1068:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
    106a:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
    106e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
    1072:	06c00c93          	li	s9,108
    1076:	a00d                	j	1098 <vprintf+0x5c>
        putc(fd, c0);
    1078:	85a6                	mv	a1,s1
    107a:	855a                	mv	a0,s6
    107c:	f0dff0ef          	jal	f88 <putc>
    1080:	a019                	j	1086 <vprintf+0x4a>
    } else if(state == '%'){
    1082:	03598363          	beq	s3,s5,10a8 <vprintf+0x6c>
  for(i = 0; fmt[i]; i++){
    1086:	0019079b          	addiw	a5,s2,1
    108a:	893e                	mv	s2,a5
    108c:	873e                	mv	a4,a5
    108e:	97d2                	add	a5,a5,s4
    1090:	0007c483          	lbu	s1,0(a5)
    1094:	20048963          	beqz	s1,12a6 <vprintf+0x26a>
    c0 = fmt[i] & 0xff;
    1098:	0004879b          	sext.w	a5,s1
    if(state == 0){
    109c:	fe0993e3          	bnez	s3,1082 <vprintf+0x46>
      if(c0 == '%'){
    10a0:	fd579ce3          	bne	a5,s5,1078 <vprintf+0x3c>
        state = '%';
    10a4:	89be                	mv	s3,a5
    10a6:	b7c5                	j	1086 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
    10a8:	00ea06b3          	add	a3,s4,a4
    10ac:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
    10b0:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
    10b2:	c681                	beqz	a3,10ba <vprintf+0x7e>
    10b4:	9752                	add	a4,a4,s4
    10b6:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
    10ba:	03878e63          	beq	a5,s8,10f6 <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
    10be:	05978863          	beq	a5,s9,110e <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
    10c2:	07500713          	li	a4,117
    10c6:	0ee78263          	beq	a5,a4,11aa <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
    10ca:	07800713          	li	a4,120
    10ce:	12e78463          	beq	a5,a4,11f6 <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
    10d2:	07000713          	li	a4,112
    10d6:	14e78963          	beq	a5,a4,1228 <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
    10da:	07300713          	li	a4,115
    10de:	18e78863          	beq	a5,a4,126e <vprintf+0x232>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
    10e2:	02500713          	li	a4,37
    10e6:	04e79463          	bne	a5,a4,112e <vprintf+0xf2>
        putc(fd, '%');
    10ea:	85ba                	mv	a1,a4
    10ec:	855a                	mv	a0,s6
    10ee:	e9bff0ef          	jal	f88 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
    10f2:	4981                	li	s3,0
    10f4:	bf49                	j	1086 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
    10f6:	008b8493          	addi	s1,s7,8
    10fa:	4685                	li	a3,1
    10fc:	4629                	li	a2,10
    10fe:	000ba583          	lw	a1,0(s7)
    1102:	855a                	mv	a0,s6
    1104:	ea3ff0ef          	jal	fa6 <printint>
    1108:	8ba6                	mv	s7,s1
      state = 0;
    110a:	4981                	li	s3,0
    110c:	bfad                	j	1086 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
    110e:	06400793          	li	a5,100
    1112:	02f68963          	beq	a3,a5,1144 <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    1116:	06c00793          	li	a5,108
    111a:	04f68263          	beq	a3,a5,115e <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
    111e:	07500793          	li	a5,117
    1122:	0af68063          	beq	a3,a5,11c2 <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
    1126:	07800793          	li	a5,120
    112a:	0ef68263          	beq	a3,a5,120e <vprintf+0x1d2>
        putc(fd, '%');
    112e:	02500593          	li	a1,37
    1132:	855a                	mv	a0,s6
    1134:	e55ff0ef          	jal	f88 <putc>
        putc(fd, c0);
    1138:	85a6                	mv	a1,s1
    113a:	855a                	mv	a0,s6
    113c:	e4dff0ef          	jal	f88 <putc>
      state = 0;
    1140:	4981                	li	s3,0
    1142:	b791                	j	1086 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
    1144:	008b8493          	addi	s1,s7,8
    1148:	4685                	li	a3,1
    114a:	4629                	li	a2,10
    114c:	000ba583          	lw	a1,0(s7)
    1150:	855a                	mv	a0,s6
    1152:	e55ff0ef          	jal	fa6 <printint>
        i += 1;
    1156:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
    1158:	8ba6                	mv	s7,s1
      state = 0;
    115a:	4981                	li	s3,0
        i += 1;
    115c:	b72d                	j	1086 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    115e:	06400793          	li	a5,100
    1162:	02f60763          	beq	a2,a5,1190 <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    1166:	07500793          	li	a5,117
    116a:	06f60963          	beq	a2,a5,11dc <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    116e:	07800793          	li	a5,120
    1172:	faf61ee3          	bne	a2,a5,112e <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
    1176:	008b8493          	addi	s1,s7,8
    117a:	4681                	li	a3,0
    117c:	4641                	li	a2,16
    117e:	000ba583          	lw	a1,0(s7)
    1182:	855a                	mv	a0,s6
    1184:	e23ff0ef          	jal	fa6 <printint>
        i += 2;
    1188:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
    118a:	8ba6                	mv	s7,s1
      state = 0;
    118c:	4981                	li	s3,0
        i += 2;
    118e:	bde5                	j	1086 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
    1190:	008b8493          	addi	s1,s7,8
    1194:	4685                	li	a3,1
    1196:	4629                	li	a2,10
    1198:	000ba583          	lw	a1,0(s7)
    119c:	855a                	mv	a0,s6
    119e:	e09ff0ef          	jal	fa6 <printint>
        i += 2;
    11a2:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
    11a4:	8ba6                	mv	s7,s1
      state = 0;
    11a6:	4981                	li	s3,0
        i += 2;
    11a8:	bdf9                	j	1086 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
    11aa:	008b8493          	addi	s1,s7,8
    11ae:	4681                	li	a3,0
    11b0:	4629                	li	a2,10
    11b2:	000ba583          	lw	a1,0(s7)
    11b6:	855a                	mv	a0,s6
    11b8:	defff0ef          	jal	fa6 <printint>
    11bc:	8ba6                	mv	s7,s1
      state = 0;
    11be:	4981                	li	s3,0
    11c0:	b5d9                	j	1086 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
    11c2:	008b8493          	addi	s1,s7,8
    11c6:	4681                	li	a3,0
    11c8:	4629                	li	a2,10
    11ca:	000ba583          	lw	a1,0(s7)
    11ce:	855a                	mv	a0,s6
    11d0:	dd7ff0ef          	jal	fa6 <printint>
        i += 1;
    11d4:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
    11d6:	8ba6                	mv	s7,s1
      state = 0;
    11d8:	4981                	li	s3,0
        i += 1;
    11da:	b575                	j	1086 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
    11dc:	008b8493          	addi	s1,s7,8
    11e0:	4681                	li	a3,0
    11e2:	4629                	li	a2,10
    11e4:	000ba583          	lw	a1,0(s7)
    11e8:	855a                	mv	a0,s6
    11ea:	dbdff0ef          	jal	fa6 <printint>
        i += 2;
    11ee:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
    11f0:	8ba6                	mv	s7,s1
      state = 0;
    11f2:	4981                	li	s3,0
        i += 2;
    11f4:	bd49                	j	1086 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
    11f6:	008b8493          	addi	s1,s7,8
    11fa:	4681                	li	a3,0
    11fc:	4641                	li	a2,16
    11fe:	000ba583          	lw	a1,0(s7)
    1202:	855a                	mv	a0,s6
    1204:	da3ff0ef          	jal	fa6 <printint>
    1208:	8ba6                	mv	s7,s1
      state = 0;
    120a:	4981                	li	s3,0
    120c:	bdad                	j	1086 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
    120e:	008b8493          	addi	s1,s7,8
    1212:	4681                	li	a3,0
    1214:	4641                	li	a2,16
    1216:	000ba583          	lw	a1,0(s7)
    121a:	855a                	mv	a0,s6
    121c:	d8bff0ef          	jal	fa6 <printint>
        i += 1;
    1220:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
    1222:	8ba6                	mv	s7,s1
      state = 0;
    1224:	4981                	li	s3,0
        i += 1;
    1226:	b585                	j	1086 <vprintf+0x4a>
    1228:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
    122a:	008b8d13          	addi	s10,s7,8
    122e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
    1232:	03000593          	li	a1,48
    1236:	855a                	mv	a0,s6
    1238:	d51ff0ef          	jal	f88 <putc>
  putc(fd, 'x');
    123c:	07800593          	li	a1,120
    1240:	855a                	mv	a0,s6
    1242:	d47ff0ef          	jal	f88 <putc>
    1246:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    1248:	00000b97          	auipc	s7,0x0
    124c:	3f0b8b93          	addi	s7,s7,1008 # 1638 <digits>
    1250:	03c9d793          	srli	a5,s3,0x3c
    1254:	97de                	add	a5,a5,s7
    1256:	0007c583          	lbu	a1,0(a5)
    125a:	855a                	mv	a0,s6
    125c:	d2dff0ef          	jal	f88 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    1260:	0992                	slli	s3,s3,0x4
    1262:	34fd                	addiw	s1,s1,-1
    1264:	f4f5                	bnez	s1,1250 <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
    1266:	8bea                	mv	s7,s10
      state = 0;
    1268:	4981                	li	s3,0
    126a:	6d02                	ld	s10,0(sp)
    126c:	bd29                	j	1086 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
    126e:	008b8993          	addi	s3,s7,8
    1272:	000bb483          	ld	s1,0(s7)
    1276:	cc91                	beqz	s1,1292 <vprintf+0x256>
        for(; *s; s++)
    1278:	0004c583          	lbu	a1,0(s1)
    127c:	c195                	beqz	a1,12a0 <vprintf+0x264>
          putc(fd, *s);
    127e:	855a                	mv	a0,s6
    1280:	d09ff0ef          	jal	f88 <putc>
        for(; *s; s++)
    1284:	0485                	addi	s1,s1,1
    1286:	0004c583          	lbu	a1,0(s1)
    128a:	f9f5                	bnez	a1,127e <vprintf+0x242>
        if((s = va_arg(ap, char*)) == 0)
    128c:	8bce                	mv	s7,s3
      state = 0;
    128e:	4981                	li	s3,0
    1290:	bbdd                	j	1086 <vprintf+0x4a>
          s = "(null)";
    1292:	00000497          	auipc	s1,0x0
    1296:	36e48493          	addi	s1,s1,878 # 1600 <malloc+0x25e>
        for(; *s; s++)
    129a:	02800593          	li	a1,40
    129e:	b7c5                	j	127e <vprintf+0x242>
        if((s = va_arg(ap, char*)) == 0)
    12a0:	8bce                	mv	s7,s3
      state = 0;
    12a2:	4981                	li	s3,0
    12a4:	b3cd                	j	1086 <vprintf+0x4a>
    12a6:	6906                	ld	s2,64(sp)
    12a8:	79e2                	ld	s3,56(sp)
    12aa:	7a42                	ld	s4,48(sp)
    12ac:	7aa2                	ld	s5,40(sp)
    12ae:	7b02                	ld	s6,32(sp)
    12b0:	6be2                	ld	s7,24(sp)
    12b2:	6c42                	ld	s8,16(sp)
    12b4:	6ca2                	ld	s9,8(sp)
    }
  }
}
    12b6:	60e6                	ld	ra,88(sp)
    12b8:	6446                	ld	s0,80(sp)
    12ba:	64a6                	ld	s1,72(sp)
    12bc:	6125                	addi	sp,sp,96
    12be:	8082                	ret

00000000000012c0 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    12c0:	715d                	addi	sp,sp,-80
    12c2:	ec06                	sd	ra,24(sp)
    12c4:	e822                	sd	s0,16(sp)
    12c6:	1000                	addi	s0,sp,32
    12c8:	e010                	sd	a2,0(s0)
    12ca:	e414                	sd	a3,8(s0)
    12cc:	e818                	sd	a4,16(s0)
    12ce:	ec1c                	sd	a5,24(s0)
    12d0:	03043023          	sd	a6,32(s0)
    12d4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    12d8:	8622                	mv	a2,s0
    12da:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    12de:	d5fff0ef          	jal	103c <vprintf>
}
    12e2:	60e2                	ld	ra,24(sp)
    12e4:	6442                	ld	s0,16(sp)
    12e6:	6161                	addi	sp,sp,80
    12e8:	8082                	ret

00000000000012ea <printf>:

void
printf(const char *fmt, ...)
{
    12ea:	711d                	addi	sp,sp,-96
    12ec:	ec06                	sd	ra,24(sp)
    12ee:	e822                	sd	s0,16(sp)
    12f0:	1000                	addi	s0,sp,32
    12f2:	e40c                	sd	a1,8(s0)
    12f4:	e810                	sd	a2,16(s0)
    12f6:	ec14                	sd	a3,24(s0)
    12f8:	f018                	sd	a4,32(s0)
    12fa:	f41c                	sd	a5,40(s0)
    12fc:	03043823          	sd	a6,48(s0)
    1300:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    1304:	00840613          	addi	a2,s0,8
    1308:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    130c:	85aa                	mv	a1,a0
    130e:	4505                	li	a0,1
    1310:	d2dff0ef          	jal	103c <vprintf>
}
    1314:	60e2                	ld	ra,24(sp)
    1316:	6442                	ld	s0,16(sp)
    1318:	6125                	addi	sp,sp,96
    131a:	8082                	ret

000000000000131c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    131c:	1141                	addi	sp,sp,-16
    131e:	e406                	sd	ra,8(sp)
    1320:	e022                	sd	s0,0(sp)
    1322:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    1324:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1328:	00001797          	auipc	a5,0x1
    132c:	ce87b783          	ld	a5,-792(a5) # 2010 <freep>
    1330:	a02d                	j	135a <free+0x3e>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    1332:	4618                	lw	a4,8(a2)
    1334:	9f2d                	addw	a4,a4,a1
    1336:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    133a:	6398                	ld	a4,0(a5)
    133c:	6310                	ld	a2,0(a4)
    133e:	a83d                	j	137c <free+0x60>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    1340:	ff852703          	lw	a4,-8(a0)
    1344:	9f31                	addw	a4,a4,a2
    1346:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    1348:	ff053683          	ld	a3,-16(a0)
    134c:	a091                	j	1390 <free+0x74>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    134e:	6398                	ld	a4,0(a5)
    1350:	00e7e463          	bltu	a5,a4,1358 <free+0x3c>
    1354:	00e6ea63          	bltu	a3,a4,1368 <free+0x4c>
{
    1358:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    135a:	fed7fae3          	bgeu	a5,a3,134e <free+0x32>
    135e:	6398                	ld	a4,0(a5)
    1360:	00e6e463          	bltu	a3,a4,1368 <free+0x4c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1364:	fee7eae3          	bltu	a5,a4,1358 <free+0x3c>
  if(bp + bp->s.size == p->s.ptr){
    1368:	ff852583          	lw	a1,-8(a0)
    136c:	6390                	ld	a2,0(a5)
    136e:	02059813          	slli	a6,a1,0x20
    1372:	01c85713          	srli	a4,a6,0x1c
    1376:	9736                	add	a4,a4,a3
    1378:	fae60de3          	beq	a2,a4,1332 <free+0x16>
    bp->s.ptr = p->s.ptr->s.ptr;
    137c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    1380:	4790                	lw	a2,8(a5)
    1382:	02061593          	slli	a1,a2,0x20
    1386:	01c5d713          	srli	a4,a1,0x1c
    138a:	973e                	add	a4,a4,a5
    138c:	fae68ae3          	beq	a3,a4,1340 <free+0x24>
    p->s.ptr = bp->s.ptr;
    1390:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    1392:	00001717          	auipc	a4,0x1
    1396:	c6f73f23          	sd	a5,-898(a4) # 2010 <freep>
}
    139a:	60a2                	ld	ra,8(sp)
    139c:	6402                	ld	s0,0(sp)
    139e:	0141                	addi	sp,sp,16
    13a0:	8082                	ret

00000000000013a2 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    13a2:	7139                	addi	sp,sp,-64
    13a4:	fc06                	sd	ra,56(sp)
    13a6:	f822                	sd	s0,48(sp)
    13a8:	f04a                	sd	s2,32(sp)
    13aa:	ec4e                	sd	s3,24(sp)
    13ac:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    13ae:	02051993          	slli	s3,a0,0x20
    13b2:	0209d993          	srli	s3,s3,0x20
    13b6:	09bd                	addi	s3,s3,15
    13b8:	0049d993          	srli	s3,s3,0x4
    13bc:	2985                	addiw	s3,s3,1
    13be:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
    13c0:	00001517          	auipc	a0,0x1
    13c4:	c5053503          	ld	a0,-944(a0) # 2010 <freep>
    13c8:	c905                	beqz	a0,13f8 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    13ca:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    13cc:	4798                	lw	a4,8(a5)
    13ce:	09377663          	bgeu	a4,s3,145a <malloc+0xb8>
    13d2:	f426                	sd	s1,40(sp)
    13d4:	e852                	sd	s4,16(sp)
    13d6:	e456                	sd	s5,8(sp)
    13d8:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
    13da:	8a4e                	mv	s4,s3
    13dc:	6705                	lui	a4,0x1
    13de:	00e9f363          	bgeu	s3,a4,13e4 <malloc+0x42>
    13e2:	6a05                	lui	s4,0x1
    13e4:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    13e8:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    13ec:	00001497          	auipc	s1,0x1
    13f0:	c2448493          	addi	s1,s1,-988 # 2010 <freep>
  if(p == (char*)-1)
    13f4:	5afd                	li	s5,-1
    13f6:	a83d                	j	1434 <malloc+0x92>
    13f8:	f426                	sd	s1,40(sp)
    13fa:	e852                	sd	s4,16(sp)
    13fc:	e456                	sd	s5,8(sp)
    13fe:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
    1400:	00001797          	auipc	a5,0x1
    1404:	c8878793          	addi	a5,a5,-888 # 2088 <base>
    1408:	00001717          	auipc	a4,0x1
    140c:	c0f73423          	sd	a5,-1016(a4) # 2010 <freep>
    1410:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    1412:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    1416:	b7d1                	j	13da <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
    1418:	6398                	ld	a4,0(a5)
    141a:	e118                	sd	a4,0(a0)
    141c:	a899                	j	1472 <malloc+0xd0>
  hp->s.size = nu;
    141e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    1422:	0541                	addi	a0,a0,16
    1424:	ef9ff0ef          	jal	131c <free>
  return freep;
    1428:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
    142a:	c125                	beqz	a0,148a <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    142c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    142e:	4798                	lw	a4,8(a5)
    1430:	03277163          	bgeu	a4,s2,1452 <malloc+0xb0>
    if(p == freep)
    1434:	6098                	ld	a4,0(s1)
    1436:	853e                	mv	a0,a5
    1438:	fef71ae3          	bne	a4,a5,142c <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
    143c:	8552                	mv	a0,s4
    143e:	b33ff0ef          	jal	f70 <sbrk>
  if(p == (char*)-1)
    1442:	fd551ee3          	bne	a0,s5,141e <malloc+0x7c>
        return 0;
    1446:	4501                	li	a0,0
    1448:	74a2                	ld	s1,40(sp)
    144a:	6a42                	ld	s4,16(sp)
    144c:	6aa2                	ld	s5,8(sp)
    144e:	6b02                	ld	s6,0(sp)
    1450:	a03d                	j	147e <malloc+0xdc>
    1452:	74a2                	ld	s1,40(sp)
    1454:	6a42                	ld	s4,16(sp)
    1456:	6aa2                	ld	s5,8(sp)
    1458:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
    145a:	fae90fe3          	beq	s2,a4,1418 <malloc+0x76>
        p->s.size -= nunits;
    145e:	4137073b          	subw	a4,a4,s3
    1462:	c798                	sw	a4,8(a5)
        p += p->s.size;
    1464:	02071693          	slli	a3,a4,0x20
    1468:	01c6d713          	srli	a4,a3,0x1c
    146c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    146e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    1472:	00001717          	auipc	a4,0x1
    1476:	b8a73f23          	sd	a0,-1122(a4) # 2010 <freep>
      return (void*)(p + 1);
    147a:	01078513          	addi	a0,a5,16
  }
}
    147e:	70e2                	ld	ra,56(sp)
    1480:	7442                	ld	s0,48(sp)
    1482:	7902                	ld	s2,32(sp)
    1484:	69e2                	ld	s3,24(sp)
    1486:	6121                	addi	sp,sp,64
    1488:	8082                	ret
    148a:	74a2                	ld	s1,40(sp)
    148c:	6a42                	ld	s4,16(sp)
    148e:	6aa2                	ld	s5,8(sp)
    1490:	6b02                	ld	s6,0(sp)
    1492:	b7f5                	j	147e <malloc+0xdc>
