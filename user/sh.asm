
user/_sh:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <strstr>:
int fork1(void);  // Fork but panics on failure.
void panic(char*);
struct cmd *parsecmd(char*);
void runcmd(struct cmd*) __attribute__((noreturn));

char* strstr(const char* haystack, const char* needle) {
       0:	1141                	addi	sp,sp,-16
       2:	e422                	sd	s0,8(sp)
       4:	0800                	addi	s0,sp,16
    if (!*needle) return (char*) haystack;
       6:	0005c803          	lbu	a6,0(a1)
       a:	04080163          	beqz	a6,4c <strstr+0x4c>
    for (; *haystack; ++haystack) {
       e:	00054783          	lbu	a5,0(a0)
      12:	eb91                	bnez	a5,26 <strstr+0x26>
                ++h; ++n;
            }
            if (!*n) return (char*) haystack;
        }
    }
    return NULL;
      14:	4501                	li	a0,0
      16:	a81d                	j	4c <strstr+0x4c>
            if (!*n) return (char*) haystack;
      18:	0007c783          	lbu	a5,0(a5)
      1c:	cb85                	beqz	a5,4c <strstr+0x4c>
    for (; *haystack; ++haystack) {
      1e:	0505                	addi	a0,a0,1
      20:	00054783          	lbu	a5,0(a0)
      24:	c39d                	beqz	a5,4a <strstr+0x4a>
        if (*haystack == *needle) {
      26:	fef81ce3          	bne	a6,a5,1e <strstr+0x1e>
            while (*h && *n && *h == *n) {
      2a:	00054703          	lbu	a4,0(a0)
            const char *h = haystack, *n = needle;
      2e:	87ae                	mv	a5,a1
      30:	862a                	mv	a2,a0
            while (*h && *n && *h == *n) {
      32:	d775                	beqz	a4,1e <strstr+0x1e>
      34:	0007c683          	lbu	a3,0(a5)
      38:	ca91                	beqz	a3,4c <strstr+0x4c>
      3a:	fce69fe3          	bne	a3,a4,18 <strstr+0x18>
                ++h; ++n;
      3e:	0605                	addi	a2,a2,1
      40:	0785                	addi	a5,a5,1
            while (*h && *n && *h == *n) {
      42:	00064703          	lbu	a4,0(a2)
      46:	f77d                	bnez	a4,34 <strstr+0x34>
      48:	bfc1                	j	18 <strstr+0x18>
    return NULL;
      4a:	4501                	li	a0,0
}
      4c:	6422                	ld	s0,8(sp)
      4e:	0141                	addi	sp,sp,16
      50:	8082                	ret

0000000000000052 <getcmd>:
  exit(0);
}

int
getcmd(char *buf, int nbuf)
{
      52:	1101                	addi	sp,sp,-32
      54:	ec06                	sd	ra,24(sp)
      56:	e822                	sd	s0,16(sp)
      58:	e426                	sd	s1,8(sp)
      5a:	e04a                	sd	s2,0(sp)
      5c:	1000                	addi	s0,sp,32
      5e:	84aa                	mv	s1,a0
      60:	892e                	mv	s2,a1
  write(2, "zahra-nastaran$ ", 16);
      62:	4641                	li	a2,16
      64:	00001597          	auipc	a1,0x1
      68:	1bc58593          	addi	a1,a1,444 # 1220 <malloc+0x106>
      6c:	4509                	li	a0,2
      6e:	401000ef          	jal	c6e <write>
  memset(buf, 0, nbuf);
      72:	864a                	mv	a2,s2
      74:	4581                	li	a1,0
      76:	8526                	mv	a0,s1
      78:	1f1000ef          	jal	a68 <memset>
  gets(buf, nbuf);
      7c:	85ca                	mv	a1,s2
      7e:	8526                	mv	a0,s1
      80:	22f000ef          	jal	aae <gets>
  if(buf[0] == 0) // EOF
      84:	0004c503          	lbu	a0,0(s1)
      88:	00153513          	seqz	a0,a0
    return -1;
  return 0;
}
      8c:	40a00533          	neg	a0,a0
      90:	60e2                	ld	ra,24(sp)
      92:	6442                	ld	s0,16(sp)
      94:	64a2                	ld	s1,8(sp)
      96:	6902                	ld	s2,0(sp)
      98:	6105                	addi	sp,sp,32
      9a:	8082                	ret

000000000000009c <panic>:
  exit(0);
}

void
panic(char *s)
{
      9c:	1141                	addi	sp,sp,-16
      9e:	e406                	sd	ra,8(sp)
      a0:	e022                	sd	s0,0(sp)
      a2:	0800                	addi	s0,sp,16
      a4:	862a                	mv	a2,a0
  fprintf(2, "%s\n", s);
      a6:	00001597          	auipc	a1,0x1
      aa:	19258593          	addi	a1,a1,402 # 1238 <malloc+0x11e>
      ae:	4509                	li	a0,2
      b0:	78d000ef          	jal	103c <fprintf>
  exit(1);
      b4:	4505                	li	a0,1
      b6:	399000ef          	jal	c4e <exit>

00000000000000ba <fork1>:
}

int
fork1(void)
{
      ba:	1141                	addi	sp,sp,-16
      bc:	e406                	sd	ra,8(sp)
      be:	e022                	sd	s0,0(sp)
      c0:	0800                	addi	s0,sp,16
  int pid;

  pid = fork();
      c2:	385000ef          	jal	c46 <fork>
  if(pid == -1)
      c6:	57fd                	li	a5,-1
      c8:	00f50663          	beq	a0,a5,d4 <fork1+0x1a>
    panic("fork");
  return pid;
}
      cc:	60a2                	ld	ra,8(sp)
      ce:	6402                	ld	s0,0(sp)
      d0:	0141                	addi	sp,sp,16
      d2:	8082                	ret
    panic("fork");
      d4:	00001517          	auipc	a0,0x1
      d8:	16c50513          	addi	a0,a0,364 # 1240 <malloc+0x126>
      dc:	fc1ff0ef          	jal	9c <panic>

00000000000000e0 <runcmd>:
{
      e0:	7179                	addi	sp,sp,-48
      e2:	f406                	sd	ra,40(sp)
      e4:	f022                	sd	s0,32(sp)
      e6:	1800                	addi	s0,sp,48
  if(cmd == 0)
      e8:	c115                	beqz	a0,10c <runcmd+0x2c>
      ea:	ec26                	sd	s1,24(sp)
      ec:	84aa                	mv	s1,a0
  switch(cmd->type){
      ee:	4118                	lw	a4,0(a0)
      f0:	4795                	li	a5,5
      f2:	02e7e163          	bltu	a5,a4,114 <runcmd+0x34>
      f6:	00056783          	lwu	a5,0(a0)
      fa:	078a                	slli	a5,a5,0x2
      fc:	00001717          	auipc	a4,0x1
     100:	24470713          	addi	a4,a4,580 # 1340 <malloc+0x226>
     104:	97ba                	add	a5,a5,a4
     106:	439c                	lw	a5,0(a5)
     108:	97ba                	add	a5,a5,a4
     10a:	8782                	jr	a5
     10c:	ec26                	sd	s1,24(sp)
    exit(1);
     10e:	4505                	li	a0,1
     110:	33f000ef          	jal	c4e <exit>
    panic("runcmd");
     114:	00001517          	auipc	a0,0x1
     118:	13450513          	addi	a0,a0,308 # 1248 <malloc+0x12e>
     11c:	f81ff0ef          	jal	9c <panic>
    if(ecmd->argv[0] == 0)
     120:	6508                	ld	a0,8(a0)
     122:	c105                	beqz	a0,142 <runcmd+0x62>
    exec(ecmd->argv[0], ecmd->argv);
     124:	00848593          	addi	a1,s1,8
     128:	35f000ef          	jal	c86 <exec>
    fprintf(2, "exec %s failed\n", ecmd->argv[0]);
     12c:	6490                	ld	a2,8(s1)
     12e:	00001597          	auipc	a1,0x1
     132:	12258593          	addi	a1,a1,290 # 1250 <malloc+0x136>
     136:	4509                	li	a0,2
     138:	705000ef          	jal	103c <fprintf>
  exit(0);
     13c:	4501                	li	a0,0
     13e:	311000ef          	jal	c4e <exit>
       exit(1);
     142:	4505                	li	a0,1
     144:	30b000ef          	jal	c4e <exit>
    close(rcmd->fd);
     148:	5148                	lw	a0,36(a0)
     14a:	32d000ef          	jal	c76 <close>
    if(open(rcmd->file, rcmd->mode) < 0){
     14e:	508c                	lw	a1,32(s1)
     150:	6888                	ld	a0,16(s1)
     152:	33d000ef          	jal	c8e <open>
     156:	00054563          	bltz	a0,160 <runcmd+0x80>
    runcmd(rcmd->cmd);
     15a:	6488                	ld	a0,8(s1)
     15c:	f85ff0ef          	jal	e0 <runcmd>
      fprintf(2, "open %s failed\n", rcmd->file);
     160:	6890                	ld	a2,16(s1)
     162:	00001597          	auipc	a1,0x1
     166:	0fe58593          	addi	a1,a1,254 # 1260 <malloc+0x146>
     16a:	4509                	li	a0,2
     16c:	6d1000ef          	jal	103c <fprintf>
      exit(1);
     170:	4505                	li	a0,1
     172:	2dd000ef          	jal	c4e <exit>
    if(fork1() == 0)
     176:	f45ff0ef          	jal	ba <fork1>
     17a:	e501                	bnez	a0,182 <runcmd+0xa2>
      runcmd(lcmd->left);
     17c:	6488                	ld	a0,8(s1)
     17e:	f63ff0ef          	jal	e0 <runcmd>
    wait(0);
     182:	4501                	li	a0,0
     184:	2d3000ef          	jal	c56 <wait>
    runcmd(lcmd->right);
     188:	6888                	ld	a0,16(s1)
     18a:	f57ff0ef          	jal	e0 <runcmd>
    if(pipe(p) < 0)
     18e:	fd840513          	addi	a0,s0,-40
     192:	2cd000ef          	jal	c5e <pipe>
     196:	02054763          	bltz	a0,1c4 <runcmd+0xe4>
    if(fork1() == 0){
     19a:	f21ff0ef          	jal	ba <fork1>
     19e:	e90d                	bnez	a0,1d0 <runcmd+0xf0>
      close(1);
     1a0:	4505                	li	a0,1
     1a2:	2d5000ef          	jal	c76 <close>
      dup(p[1]);
     1a6:	fdc42503          	lw	a0,-36(s0)
     1aa:	31d000ef          	jal	cc6 <dup>
      close(p[0]);
     1ae:	fd842503          	lw	a0,-40(s0)
     1b2:	2c5000ef          	jal	c76 <close>
      close(p[1]);
     1b6:	fdc42503          	lw	a0,-36(s0)
     1ba:	2bd000ef          	jal	c76 <close>
      runcmd(pcmd->left);
     1be:	6488                	ld	a0,8(s1)
     1c0:	f21ff0ef          	jal	e0 <runcmd>
      panic("pipe");
     1c4:	00001517          	auipc	a0,0x1
     1c8:	0ac50513          	addi	a0,a0,172 # 1270 <malloc+0x156>
     1cc:	ed1ff0ef          	jal	9c <panic>
    if(fork1() == 0){
     1d0:	eebff0ef          	jal	ba <fork1>
     1d4:	e115                	bnez	a0,1f8 <runcmd+0x118>
      close(0);
     1d6:	2a1000ef          	jal	c76 <close>
      dup(p[0]);
     1da:	fd842503          	lw	a0,-40(s0)
     1de:	2e9000ef          	jal	cc6 <dup>
      close(p[0]);
     1e2:	fd842503          	lw	a0,-40(s0)
     1e6:	291000ef          	jal	c76 <close>
      close(p[1]);
     1ea:	fdc42503          	lw	a0,-36(s0)
     1ee:	289000ef          	jal	c76 <close>
      runcmd(pcmd->right);
     1f2:	6888                	ld	a0,16(s1)
     1f4:	eedff0ef          	jal	e0 <runcmd>
    close(p[0]);
     1f8:	fd842503          	lw	a0,-40(s0)
     1fc:	27b000ef          	jal	c76 <close>
    close(p[1]);
     200:	fdc42503          	lw	a0,-36(s0)
     204:	273000ef          	jal	c76 <close>
    wait(0);
     208:	4501                	li	a0,0
     20a:	24d000ef          	jal	c56 <wait>
    wait(0);
     20e:	4501                	li	a0,0
     210:	247000ef          	jal	c56 <wait>
    break;
     214:	b725                	j	13c <runcmd+0x5c>
    if(fork1() == 0)
     216:	ea5ff0ef          	jal	ba <fork1>
     21a:	f20511e3          	bnez	a0,13c <runcmd+0x5c>
      runcmd(bcmd->cmd);
     21e:	6488                	ld	a0,8(s1)
     220:	ec1ff0ef          	jal	e0 <runcmd>

0000000000000224 <execcmd>:
//PAGEBREAK!
// Constructors

struct cmd*
execcmd(void)
{
     224:	1101                	addi	sp,sp,-32
     226:	ec06                	sd	ra,24(sp)
     228:	e822                	sd	s0,16(sp)
     22a:	e426                	sd	s1,8(sp)
     22c:	1000                	addi	s0,sp,32
  struct execcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     22e:	0a800513          	li	a0,168
     232:	6e9000ef          	jal	111a <malloc>
     236:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     238:	0a800613          	li	a2,168
     23c:	4581                	li	a1,0
     23e:	02b000ef          	jal	a68 <memset>
  cmd->type = EXEC;
     242:	4785                	li	a5,1
     244:	c09c                	sw	a5,0(s1)
  return (struct cmd*)cmd;
}
     246:	8526                	mv	a0,s1
     248:	60e2                	ld	ra,24(sp)
     24a:	6442                	ld	s0,16(sp)
     24c:	64a2                	ld	s1,8(sp)
     24e:	6105                	addi	sp,sp,32
     250:	8082                	ret

0000000000000252 <redircmd>:

struct cmd*
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
     252:	7139                	addi	sp,sp,-64
     254:	fc06                	sd	ra,56(sp)
     256:	f822                	sd	s0,48(sp)
     258:	f426                	sd	s1,40(sp)
     25a:	f04a                	sd	s2,32(sp)
     25c:	ec4e                	sd	s3,24(sp)
     25e:	e852                	sd	s4,16(sp)
     260:	e456                	sd	s5,8(sp)
     262:	e05a                	sd	s6,0(sp)
     264:	0080                	addi	s0,sp,64
     266:	8b2a                	mv	s6,a0
     268:	8aae                	mv	s5,a1
     26a:	8a32                	mv	s4,a2
     26c:	89b6                	mv	s3,a3
     26e:	893a                	mv	s2,a4
  struct redircmd *cmd;

  cmd = malloc(sizeof(*cmd));
     270:	02800513          	li	a0,40
     274:	6a7000ef          	jal	111a <malloc>
     278:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     27a:	02800613          	li	a2,40
     27e:	4581                	li	a1,0
     280:	7e8000ef          	jal	a68 <memset>
  cmd->type = REDIR;
     284:	4789                	li	a5,2
     286:	c09c                	sw	a5,0(s1)
  cmd->cmd = subcmd;
     288:	0164b423          	sd	s6,8(s1)
  cmd->file = file;
     28c:	0154b823          	sd	s5,16(s1)
  cmd->efile = efile;
     290:	0144bc23          	sd	s4,24(s1)
  cmd->mode = mode;
     294:	0334a023          	sw	s3,32(s1)
  cmd->fd = fd;
     298:	0324a223          	sw	s2,36(s1)
  return (struct cmd*)cmd;
}
     29c:	8526                	mv	a0,s1
     29e:	70e2                	ld	ra,56(sp)
     2a0:	7442                	ld	s0,48(sp)
     2a2:	74a2                	ld	s1,40(sp)
     2a4:	7902                	ld	s2,32(sp)
     2a6:	69e2                	ld	s3,24(sp)
     2a8:	6a42                	ld	s4,16(sp)
     2aa:	6aa2                	ld	s5,8(sp)
     2ac:	6b02                	ld	s6,0(sp)
     2ae:	6121                	addi	sp,sp,64
     2b0:	8082                	ret

00000000000002b2 <pipecmd>:

struct cmd*
pipecmd(struct cmd *left, struct cmd *right)
{
     2b2:	7179                	addi	sp,sp,-48
     2b4:	f406                	sd	ra,40(sp)
     2b6:	f022                	sd	s0,32(sp)
     2b8:	ec26                	sd	s1,24(sp)
     2ba:	e84a                	sd	s2,16(sp)
     2bc:	e44e                	sd	s3,8(sp)
     2be:	1800                	addi	s0,sp,48
     2c0:	89aa                	mv	s3,a0
     2c2:	892e                	mv	s2,a1
  struct pipecmd *cmd;

  cmd = malloc(sizeof(*cmd));
     2c4:	4561                	li	a0,24
     2c6:	655000ef          	jal	111a <malloc>
     2ca:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     2cc:	4661                	li	a2,24
     2ce:	4581                	li	a1,0
     2d0:	798000ef          	jal	a68 <memset>
  cmd->type = PIPE;
     2d4:	478d                	li	a5,3
     2d6:	c09c                	sw	a5,0(s1)
  cmd->left = left;
     2d8:	0134b423          	sd	s3,8(s1)
  cmd->right = right;
     2dc:	0124b823          	sd	s2,16(s1)
  return (struct cmd*)cmd;
}
     2e0:	8526                	mv	a0,s1
     2e2:	70a2                	ld	ra,40(sp)
     2e4:	7402                	ld	s0,32(sp)
     2e6:	64e2                	ld	s1,24(sp)
     2e8:	6942                	ld	s2,16(sp)
     2ea:	69a2                	ld	s3,8(sp)
     2ec:	6145                	addi	sp,sp,48
     2ee:	8082                	ret

00000000000002f0 <listcmd>:

struct cmd*
listcmd(struct cmd *left, struct cmd *right)
{
     2f0:	7179                	addi	sp,sp,-48
     2f2:	f406                	sd	ra,40(sp)
     2f4:	f022                	sd	s0,32(sp)
     2f6:	ec26                	sd	s1,24(sp)
     2f8:	e84a                	sd	s2,16(sp)
     2fa:	e44e                	sd	s3,8(sp)
     2fc:	1800                	addi	s0,sp,48
     2fe:	89aa                	mv	s3,a0
     300:	892e                	mv	s2,a1
  struct listcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     302:	4561                	li	a0,24
     304:	617000ef          	jal	111a <malloc>
     308:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     30a:	4661                	li	a2,24
     30c:	4581                	li	a1,0
     30e:	75a000ef          	jal	a68 <memset>
  cmd->type = LIST;
     312:	4791                	li	a5,4
     314:	c09c                	sw	a5,0(s1)
  cmd->left = left;
     316:	0134b423          	sd	s3,8(s1)
  cmd->right = right;
     31a:	0124b823          	sd	s2,16(s1)
  return (struct cmd*)cmd;
}
     31e:	8526                	mv	a0,s1
     320:	70a2                	ld	ra,40(sp)
     322:	7402                	ld	s0,32(sp)
     324:	64e2                	ld	s1,24(sp)
     326:	6942                	ld	s2,16(sp)
     328:	69a2                	ld	s3,8(sp)
     32a:	6145                	addi	sp,sp,48
     32c:	8082                	ret

000000000000032e <backcmd>:

struct cmd*
backcmd(struct cmd *subcmd)
{
     32e:	1101                	addi	sp,sp,-32
     330:	ec06                	sd	ra,24(sp)
     332:	e822                	sd	s0,16(sp)
     334:	e426                	sd	s1,8(sp)
     336:	e04a                	sd	s2,0(sp)
     338:	1000                	addi	s0,sp,32
     33a:	892a                	mv	s2,a0
  struct backcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     33c:	4541                	li	a0,16
     33e:	5dd000ef          	jal	111a <malloc>
     342:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     344:	4641                	li	a2,16
     346:	4581                	li	a1,0
     348:	720000ef          	jal	a68 <memset>
  cmd->type = BACK;
     34c:	4795                	li	a5,5
     34e:	c09c                	sw	a5,0(s1)
  cmd->cmd = subcmd;
     350:	0124b423          	sd	s2,8(s1)
  return (struct cmd*)cmd;
}
     354:	8526                	mv	a0,s1
     356:	60e2                	ld	ra,24(sp)
     358:	6442                	ld	s0,16(sp)
     35a:	64a2                	ld	s1,8(sp)
     35c:	6902                	ld	s2,0(sp)
     35e:	6105                	addi	sp,sp,32
     360:	8082                	ret

0000000000000362 <gettoken>:
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int
gettoken(char **ps, char *es, char **q, char **eq)
{
     362:	7139                	addi	sp,sp,-64
     364:	fc06                	sd	ra,56(sp)
     366:	f822                	sd	s0,48(sp)
     368:	f426                	sd	s1,40(sp)
     36a:	f04a                	sd	s2,32(sp)
     36c:	ec4e                	sd	s3,24(sp)
     36e:	e852                	sd	s4,16(sp)
     370:	e456                	sd	s5,8(sp)
     372:	e05a                	sd	s6,0(sp)
     374:	0080                	addi	s0,sp,64
     376:	8a2a                	mv	s4,a0
     378:	892e                	mv	s2,a1
     37a:	8ab2                	mv	s5,a2
     37c:	8b36                	mv	s6,a3
  char *s;
  int ret;

  s = *ps;
     37e:	6104                	ld	s1,0(a0)
  while(s < es && strchr(whitespace, *s))
     380:	00002997          	auipc	s3,0x2
     384:	c8898993          	addi	s3,s3,-888 # 2008 <whitespace>
     388:	00b4fc63          	bgeu	s1,a1,3a0 <gettoken+0x3e>
     38c:	0004c583          	lbu	a1,0(s1)
     390:	854e                	mv	a0,s3
     392:	6f8000ef          	jal	a8a <strchr>
     396:	c509                	beqz	a0,3a0 <gettoken+0x3e>
    s++;
     398:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     39a:	fe9919e3          	bne	s2,s1,38c <gettoken+0x2a>
     39e:	84ca                	mv	s1,s2
  if(q)
     3a0:	000a8463          	beqz	s5,3a8 <gettoken+0x46>
    *q = s;
     3a4:	009ab023          	sd	s1,0(s5)
  ret = *s;
     3a8:	0004c783          	lbu	a5,0(s1)
     3ac:	00078a9b          	sext.w	s5,a5
  switch(*s){
     3b0:	03c00713          	li	a4,60
     3b4:	06f76463          	bltu	a4,a5,41c <gettoken+0xba>
     3b8:	03a00713          	li	a4,58
     3bc:	00f76e63          	bltu	a4,a5,3d8 <gettoken+0x76>
     3c0:	cf89                	beqz	a5,3da <gettoken+0x78>
     3c2:	02600713          	li	a4,38
     3c6:	00e78963          	beq	a5,a4,3d8 <gettoken+0x76>
     3ca:	fd87879b          	addiw	a5,a5,-40
     3ce:	0ff7f793          	zext.b	a5,a5
     3d2:	4705                	li	a4,1
     3d4:	06f76b63          	bltu	a4,a5,44a <gettoken+0xe8>
  case '(':
  case ')':
  case ';':
  case '&':
  case '<':
    s++;
     3d8:	0485                	addi	s1,s1,1
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
      s++;
    break;
  }
  if(eq)
     3da:	000b0463          	beqz	s6,3e2 <gettoken+0x80>
    *eq = s;
     3de:	009b3023          	sd	s1,0(s6)

  while(s < es && strchr(whitespace, *s))
     3e2:	00002997          	auipc	s3,0x2
     3e6:	c2698993          	addi	s3,s3,-986 # 2008 <whitespace>
     3ea:	0124fc63          	bgeu	s1,s2,402 <gettoken+0xa0>
     3ee:	0004c583          	lbu	a1,0(s1)
     3f2:	854e                	mv	a0,s3
     3f4:	696000ef          	jal	a8a <strchr>
     3f8:	c509                	beqz	a0,402 <gettoken+0xa0>
    s++;
     3fa:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     3fc:	fe9919e3          	bne	s2,s1,3ee <gettoken+0x8c>
     400:	84ca                	mv	s1,s2
  *ps = s;
     402:	009a3023          	sd	s1,0(s4)
  return ret;
}
     406:	8556                	mv	a0,s5
     408:	70e2                	ld	ra,56(sp)
     40a:	7442                	ld	s0,48(sp)
     40c:	74a2                	ld	s1,40(sp)
     40e:	7902                	ld	s2,32(sp)
     410:	69e2                	ld	s3,24(sp)
     412:	6a42                	ld	s4,16(sp)
     414:	6aa2                	ld	s5,8(sp)
     416:	6b02                	ld	s6,0(sp)
     418:	6121                	addi	sp,sp,64
     41a:	8082                	ret
  switch(*s){
     41c:	03e00713          	li	a4,62
     420:	02e79163          	bne	a5,a4,442 <gettoken+0xe0>
    s++;
     424:	00148693          	addi	a3,s1,1
    if(*s == '>'){
     428:	0014c703          	lbu	a4,1(s1)
     42c:	03e00793          	li	a5,62
      s++;
     430:	0489                	addi	s1,s1,2
      ret = '+';
     432:	02b00a93          	li	s5,43
    if(*s == '>'){
     436:	faf702e3          	beq	a4,a5,3da <gettoken+0x78>
    s++;
     43a:	84b6                	mv	s1,a3
  ret = *s;
     43c:	03e00a93          	li	s5,62
     440:	bf69                	j	3da <gettoken+0x78>
  switch(*s){
     442:	07c00713          	li	a4,124
     446:	f8e789e3          	beq	a5,a4,3d8 <gettoken+0x76>
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     44a:	00002997          	auipc	s3,0x2
     44e:	bbe98993          	addi	s3,s3,-1090 # 2008 <whitespace>
     452:	00002a97          	auipc	s5,0x2
     456:	baea8a93          	addi	s5,s5,-1106 # 2000 <symbols>
     45a:	0324fd63          	bgeu	s1,s2,494 <gettoken+0x132>
     45e:	0004c583          	lbu	a1,0(s1)
     462:	854e                	mv	a0,s3
     464:	626000ef          	jal	a8a <strchr>
     468:	e11d                	bnez	a0,48e <gettoken+0x12c>
     46a:	0004c583          	lbu	a1,0(s1)
     46e:	8556                	mv	a0,s5
     470:	61a000ef          	jal	a8a <strchr>
     474:	e911                	bnez	a0,488 <gettoken+0x126>
      s++;
     476:	0485                	addi	s1,s1,1
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     478:	fe9913e3          	bne	s2,s1,45e <gettoken+0xfc>
  if(eq)
     47c:	84ca                	mv	s1,s2
    ret = 'a';
     47e:	06100a93          	li	s5,97
  if(eq)
     482:	f40b1ee3          	bnez	s6,3de <gettoken+0x7c>
     486:	bfb5                	j	402 <gettoken+0xa0>
    ret = 'a';
     488:	06100a93          	li	s5,97
     48c:	b7b9                	j	3da <gettoken+0x78>
     48e:	06100a93          	li	s5,97
     492:	b7a1                	j	3da <gettoken+0x78>
     494:	06100a93          	li	s5,97
  if(eq)
     498:	f40b13e3          	bnez	s6,3de <gettoken+0x7c>
     49c:	b79d                	j	402 <gettoken+0xa0>

000000000000049e <peek>:

int
peek(char **ps, char *es, char *toks)
{
     49e:	7139                	addi	sp,sp,-64
     4a0:	fc06                	sd	ra,56(sp)
     4a2:	f822                	sd	s0,48(sp)
     4a4:	f426                	sd	s1,40(sp)
     4a6:	f04a                	sd	s2,32(sp)
     4a8:	ec4e                	sd	s3,24(sp)
     4aa:	e852                	sd	s4,16(sp)
     4ac:	e456                	sd	s5,8(sp)
     4ae:	0080                	addi	s0,sp,64
     4b0:	8a2a                	mv	s4,a0
     4b2:	892e                	mv	s2,a1
     4b4:	8ab2                	mv	s5,a2
  char *s;

  s = *ps;
     4b6:	6104                	ld	s1,0(a0)
  while(s < es && strchr(whitespace, *s))
     4b8:	00002997          	auipc	s3,0x2
     4bc:	b5098993          	addi	s3,s3,-1200 # 2008 <whitespace>
     4c0:	00b4fc63          	bgeu	s1,a1,4d8 <peek+0x3a>
     4c4:	0004c583          	lbu	a1,0(s1)
     4c8:	854e                	mv	a0,s3
     4ca:	5c0000ef          	jal	a8a <strchr>
     4ce:	c509                	beqz	a0,4d8 <peek+0x3a>
    s++;
     4d0:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     4d2:	fe9919e3          	bne	s2,s1,4c4 <peek+0x26>
     4d6:	84ca                	mv	s1,s2
  *ps = s;
     4d8:	009a3023          	sd	s1,0(s4)
  return *s && strchr(toks, *s);
     4dc:	0004c583          	lbu	a1,0(s1)
     4e0:	4501                	li	a0,0
     4e2:	e991                	bnez	a1,4f6 <peek+0x58>
}
     4e4:	70e2                	ld	ra,56(sp)
     4e6:	7442                	ld	s0,48(sp)
     4e8:	74a2                	ld	s1,40(sp)
     4ea:	7902                	ld	s2,32(sp)
     4ec:	69e2                	ld	s3,24(sp)
     4ee:	6a42                	ld	s4,16(sp)
     4f0:	6aa2                	ld	s5,8(sp)
     4f2:	6121                	addi	sp,sp,64
     4f4:	8082                	ret
  return *s && strchr(toks, *s);
     4f6:	8556                	mv	a0,s5
     4f8:	592000ef          	jal	a8a <strchr>
     4fc:	00a03533          	snez	a0,a0
     500:	b7d5                	j	4e4 <peek+0x46>

0000000000000502 <parseredirs>:
  return cmd;
}

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     502:	711d                	addi	sp,sp,-96
     504:	ec86                	sd	ra,88(sp)
     506:	e8a2                	sd	s0,80(sp)
     508:	e4a6                	sd	s1,72(sp)
     50a:	e0ca                	sd	s2,64(sp)
     50c:	fc4e                	sd	s3,56(sp)
     50e:	f852                	sd	s4,48(sp)
     510:	f456                	sd	s5,40(sp)
     512:	f05a                	sd	s6,32(sp)
     514:	ec5e                	sd	s7,24(sp)
     516:	1080                	addi	s0,sp,96
     518:	8a2a                	mv	s4,a0
     51a:	89ae                	mv	s3,a1
     51c:	8932                	mv	s2,a2
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     51e:	00001a97          	auipc	s5,0x1
     522:	d7aa8a93          	addi	s5,s5,-646 # 1298 <malloc+0x17e>
    tok = gettoken(ps, es, 0, 0);
    if(gettoken(ps, es, &q, &eq) != 'a')
     526:	06100b13          	li	s6,97
      panic("missing file for redirection");
    switch(tok){
     52a:	03c00b93          	li	s7,60
  while(peek(ps, es, "<>")){
     52e:	a00d                	j	550 <parseredirs+0x4e>
      panic("missing file for redirection");
     530:	00001517          	auipc	a0,0x1
     534:	d4850513          	addi	a0,a0,-696 # 1278 <malloc+0x15e>
     538:	b65ff0ef          	jal	9c <panic>
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     53c:	4701                	li	a4,0
     53e:	4681                	li	a3,0
     540:	fa043603          	ld	a2,-96(s0)
     544:	fa843583          	ld	a1,-88(s0)
     548:	8552                	mv	a0,s4
     54a:	d09ff0ef          	jal	252 <redircmd>
     54e:	8a2a                	mv	s4,a0
  while(peek(ps, es, "<>")){
     550:	8656                	mv	a2,s5
     552:	85ca                	mv	a1,s2
     554:	854e                	mv	a0,s3
     556:	f49ff0ef          	jal	49e <peek>
     55a:	c525                	beqz	a0,5c2 <parseredirs+0xc0>
    tok = gettoken(ps, es, 0, 0);
     55c:	4681                	li	a3,0
     55e:	4601                	li	a2,0
     560:	85ca                	mv	a1,s2
     562:	854e                	mv	a0,s3
     564:	dffff0ef          	jal	362 <gettoken>
     568:	84aa                	mv	s1,a0
    if(gettoken(ps, es, &q, &eq) != 'a')
     56a:	fa040693          	addi	a3,s0,-96
     56e:	fa840613          	addi	a2,s0,-88
     572:	85ca                	mv	a1,s2
     574:	854e                	mv	a0,s3
     576:	dedff0ef          	jal	362 <gettoken>
     57a:	fb651be3          	bne	a0,s6,530 <parseredirs+0x2e>
    switch(tok){
     57e:	fb748fe3          	beq	s1,s7,53c <parseredirs+0x3a>
     582:	03e00793          	li	a5,62
     586:	02f48263          	beq	s1,a5,5aa <parseredirs+0xa8>
     58a:	02b00793          	li	a5,43
     58e:	fcf491e3          	bne	s1,a5,550 <parseredirs+0x4e>
      break;
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE|O_TRUNC, 1);
      break;
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     592:	4705                	li	a4,1
     594:	20100693          	li	a3,513
     598:	fa043603          	ld	a2,-96(s0)
     59c:	fa843583          	ld	a1,-88(s0)
     5a0:	8552                	mv	a0,s4
     5a2:	cb1ff0ef          	jal	252 <redircmd>
     5a6:	8a2a                	mv	s4,a0
      break;
     5a8:	b765                	j	550 <parseredirs+0x4e>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE|O_TRUNC, 1);
     5aa:	4705                	li	a4,1
     5ac:	60100693          	li	a3,1537
     5b0:	fa043603          	ld	a2,-96(s0)
     5b4:	fa843583          	ld	a1,-88(s0)
     5b8:	8552                	mv	a0,s4
     5ba:	c99ff0ef          	jal	252 <redircmd>
     5be:	8a2a                	mv	s4,a0
      break;
     5c0:	bf41                	j	550 <parseredirs+0x4e>
    }
  }
  return cmd;
}
     5c2:	8552                	mv	a0,s4
     5c4:	60e6                	ld	ra,88(sp)
     5c6:	6446                	ld	s0,80(sp)
     5c8:	64a6                	ld	s1,72(sp)
     5ca:	6906                	ld	s2,64(sp)
     5cc:	79e2                	ld	s3,56(sp)
     5ce:	7a42                	ld	s4,48(sp)
     5d0:	7aa2                	ld	s5,40(sp)
     5d2:	7b02                	ld	s6,32(sp)
     5d4:	6be2                	ld	s7,24(sp)
     5d6:	6125                	addi	sp,sp,96
     5d8:	8082                	ret

00000000000005da <parseexec>:
  return cmd;
}

struct cmd*
parseexec(char **ps, char *es)
{
     5da:	7159                	addi	sp,sp,-112
     5dc:	f486                	sd	ra,104(sp)
     5de:	f0a2                	sd	s0,96(sp)
     5e0:	eca6                	sd	s1,88(sp)
     5e2:	e0d2                	sd	s4,64(sp)
     5e4:	fc56                	sd	s5,56(sp)
     5e6:	1880                	addi	s0,sp,112
     5e8:	8a2a                	mv	s4,a0
     5ea:	8aae                	mv	s5,a1
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;

  if(peek(ps, es, "("))
     5ec:	00001617          	auipc	a2,0x1
     5f0:	cb460613          	addi	a2,a2,-844 # 12a0 <malloc+0x186>
     5f4:	eabff0ef          	jal	49e <peek>
     5f8:	e915                	bnez	a0,62c <parseexec+0x52>
     5fa:	e8ca                	sd	s2,80(sp)
     5fc:	e4ce                	sd	s3,72(sp)
     5fe:	f85a                	sd	s6,48(sp)
     600:	f45e                	sd	s7,40(sp)
     602:	f062                	sd	s8,32(sp)
     604:	ec66                	sd	s9,24(sp)
     606:	89aa                	mv	s3,a0
    return parseblock(ps, es);

  ret = execcmd();
     608:	c1dff0ef          	jal	224 <execcmd>
     60c:	8c2a                	mv	s8,a0
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
     60e:	8656                	mv	a2,s5
     610:	85d2                	mv	a1,s4
     612:	ef1ff0ef          	jal	502 <parseredirs>
     616:	84aa                	mv	s1,a0
  while(!peek(ps, es, "|)&;")){
     618:	008c0913          	addi	s2,s8,8
     61c:	00001b17          	auipc	s6,0x1
     620:	ca4b0b13          	addi	s6,s6,-860 # 12c0 <malloc+0x1a6>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
      break;
    if(tok != 'a')
     624:	06100c93          	li	s9,97
      panic("syntax");
    cmd->argv[argc] = q;
    cmd->eargv[argc] = eq;
    argc++;
    if(argc >= MAXARGS)
     628:	4ba9                	li	s7,10
  while(!peek(ps, es, "|)&;")){
     62a:	a815                	j	65e <parseexec+0x84>
    return parseblock(ps, es);
     62c:	85d6                	mv	a1,s5
     62e:	8552                	mv	a0,s4
     630:	170000ef          	jal	7a0 <parseblock>
     634:	84aa                	mv	s1,a0
    ret = parseredirs(ret, ps, es);
  }
  cmd->argv[argc] = 0;
  cmd->eargv[argc] = 0;
  return ret;
}
     636:	8526                	mv	a0,s1
     638:	70a6                	ld	ra,104(sp)
     63a:	7406                	ld	s0,96(sp)
     63c:	64e6                	ld	s1,88(sp)
     63e:	6a06                	ld	s4,64(sp)
     640:	7ae2                	ld	s5,56(sp)
     642:	6165                	addi	sp,sp,112
     644:	8082                	ret
      panic("syntax");
     646:	00001517          	auipc	a0,0x1
     64a:	c6250513          	addi	a0,a0,-926 # 12a8 <malloc+0x18e>
     64e:	a4fff0ef          	jal	9c <panic>
    ret = parseredirs(ret, ps, es);
     652:	8656                	mv	a2,s5
     654:	85d2                	mv	a1,s4
     656:	8526                	mv	a0,s1
     658:	eabff0ef          	jal	502 <parseredirs>
     65c:	84aa                	mv	s1,a0
  while(!peek(ps, es, "|)&;")){
     65e:	865a                	mv	a2,s6
     660:	85d6                	mv	a1,s5
     662:	8552                	mv	a0,s4
     664:	e3bff0ef          	jal	49e <peek>
     668:	ed15                	bnez	a0,6a4 <parseexec+0xca>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     66a:	f9040693          	addi	a3,s0,-112
     66e:	f9840613          	addi	a2,s0,-104
     672:	85d6                	mv	a1,s5
     674:	8552                	mv	a0,s4
     676:	cedff0ef          	jal	362 <gettoken>
     67a:	c50d                	beqz	a0,6a4 <parseexec+0xca>
    if(tok != 'a')
     67c:	fd9515e3          	bne	a0,s9,646 <parseexec+0x6c>
    cmd->argv[argc] = q;
     680:	f9843783          	ld	a5,-104(s0)
     684:	00f93023          	sd	a5,0(s2)
    cmd->eargv[argc] = eq;
     688:	f9043783          	ld	a5,-112(s0)
     68c:	04f93823          	sd	a5,80(s2)
    argc++;
     690:	2985                	addiw	s3,s3,1
    if(argc >= MAXARGS)
     692:	0921                	addi	s2,s2,8
     694:	fb799fe3          	bne	s3,s7,652 <parseexec+0x78>
      panic("too many args");
     698:	00001517          	auipc	a0,0x1
     69c:	c1850513          	addi	a0,a0,-1000 # 12b0 <malloc+0x196>
     6a0:	9fdff0ef          	jal	9c <panic>
  cmd->argv[argc] = 0;
     6a4:	098e                	slli	s3,s3,0x3
     6a6:	9c4e                	add	s8,s8,s3
     6a8:	000c3423          	sd	zero,8(s8)
  cmd->eargv[argc] = 0;
     6ac:	040c3c23          	sd	zero,88(s8)
     6b0:	6946                	ld	s2,80(sp)
     6b2:	69a6                	ld	s3,72(sp)
     6b4:	7b42                	ld	s6,48(sp)
     6b6:	7ba2                	ld	s7,40(sp)
     6b8:	7c02                	ld	s8,32(sp)
     6ba:	6ce2                	ld	s9,24(sp)
  return ret;
     6bc:	bfad                	j	636 <parseexec+0x5c>

00000000000006be <parsepipe>:
{
     6be:	7179                	addi	sp,sp,-48
     6c0:	f406                	sd	ra,40(sp)
     6c2:	f022                	sd	s0,32(sp)
     6c4:	ec26                	sd	s1,24(sp)
     6c6:	e84a                	sd	s2,16(sp)
     6c8:	e44e                	sd	s3,8(sp)
     6ca:	1800                	addi	s0,sp,48
     6cc:	892a                	mv	s2,a0
     6ce:	89ae                	mv	s3,a1
  cmd = parseexec(ps, es);
     6d0:	f0bff0ef          	jal	5da <parseexec>
     6d4:	84aa                	mv	s1,a0
  if(peek(ps, es, "|")){
     6d6:	00001617          	auipc	a2,0x1
     6da:	bf260613          	addi	a2,a2,-1038 # 12c8 <malloc+0x1ae>
     6de:	85ce                	mv	a1,s3
     6e0:	854a                	mv	a0,s2
     6e2:	dbdff0ef          	jal	49e <peek>
     6e6:	e909                	bnez	a0,6f8 <parsepipe+0x3a>
}
     6e8:	8526                	mv	a0,s1
     6ea:	70a2                	ld	ra,40(sp)
     6ec:	7402                	ld	s0,32(sp)
     6ee:	64e2                	ld	s1,24(sp)
     6f0:	6942                	ld	s2,16(sp)
     6f2:	69a2                	ld	s3,8(sp)
     6f4:	6145                	addi	sp,sp,48
     6f6:	8082                	ret
    gettoken(ps, es, 0, 0);
     6f8:	4681                	li	a3,0
     6fa:	4601                	li	a2,0
     6fc:	85ce                	mv	a1,s3
     6fe:	854a                	mv	a0,s2
     700:	c63ff0ef          	jal	362 <gettoken>
    cmd = pipecmd(cmd, parsepipe(ps, es));
     704:	85ce                	mv	a1,s3
     706:	854a                	mv	a0,s2
     708:	fb7ff0ef          	jal	6be <parsepipe>
     70c:	85aa                	mv	a1,a0
     70e:	8526                	mv	a0,s1
     710:	ba3ff0ef          	jal	2b2 <pipecmd>
     714:	84aa                	mv	s1,a0
  return cmd;
     716:	bfc9                	j	6e8 <parsepipe+0x2a>

0000000000000718 <parseline>:
{
     718:	7179                	addi	sp,sp,-48
     71a:	f406                	sd	ra,40(sp)
     71c:	f022                	sd	s0,32(sp)
     71e:	ec26                	sd	s1,24(sp)
     720:	e84a                	sd	s2,16(sp)
     722:	e44e                	sd	s3,8(sp)
     724:	e052                	sd	s4,0(sp)
     726:	1800                	addi	s0,sp,48
     728:	892a                	mv	s2,a0
     72a:	89ae                	mv	s3,a1
  cmd = parsepipe(ps, es);
     72c:	f93ff0ef          	jal	6be <parsepipe>
     730:	84aa                	mv	s1,a0
  while(peek(ps, es, "&")){
     732:	00001a17          	auipc	s4,0x1
     736:	b9ea0a13          	addi	s4,s4,-1122 # 12d0 <malloc+0x1b6>
     73a:	a819                	j	750 <parseline+0x38>
    gettoken(ps, es, 0, 0);
     73c:	4681                	li	a3,0
     73e:	4601                	li	a2,0
     740:	85ce                	mv	a1,s3
     742:	854a                	mv	a0,s2
     744:	c1fff0ef          	jal	362 <gettoken>
    cmd = backcmd(cmd);
     748:	8526                	mv	a0,s1
     74a:	be5ff0ef          	jal	32e <backcmd>
     74e:	84aa                	mv	s1,a0
  while(peek(ps, es, "&")){
     750:	8652                	mv	a2,s4
     752:	85ce                	mv	a1,s3
     754:	854a                	mv	a0,s2
     756:	d49ff0ef          	jal	49e <peek>
     75a:	f16d                	bnez	a0,73c <parseline+0x24>
  if(peek(ps, es, ";")){
     75c:	00001617          	auipc	a2,0x1
     760:	b7c60613          	addi	a2,a2,-1156 # 12d8 <malloc+0x1be>
     764:	85ce                	mv	a1,s3
     766:	854a                	mv	a0,s2
     768:	d37ff0ef          	jal	49e <peek>
     76c:	e911                	bnez	a0,780 <parseline+0x68>
}
     76e:	8526                	mv	a0,s1
     770:	70a2                	ld	ra,40(sp)
     772:	7402                	ld	s0,32(sp)
     774:	64e2                	ld	s1,24(sp)
     776:	6942                	ld	s2,16(sp)
     778:	69a2                	ld	s3,8(sp)
     77a:	6a02                	ld	s4,0(sp)
     77c:	6145                	addi	sp,sp,48
     77e:	8082                	ret
    gettoken(ps, es, 0, 0);
     780:	4681                	li	a3,0
     782:	4601                	li	a2,0
     784:	85ce                	mv	a1,s3
     786:	854a                	mv	a0,s2
     788:	bdbff0ef          	jal	362 <gettoken>
    cmd = listcmd(cmd, parseline(ps, es));
     78c:	85ce                	mv	a1,s3
     78e:	854a                	mv	a0,s2
     790:	f89ff0ef          	jal	718 <parseline>
     794:	85aa                	mv	a1,a0
     796:	8526                	mv	a0,s1
     798:	b59ff0ef          	jal	2f0 <listcmd>
     79c:	84aa                	mv	s1,a0
  return cmd;
     79e:	bfc1                	j	76e <parseline+0x56>

00000000000007a0 <parseblock>:
{
     7a0:	7179                	addi	sp,sp,-48
     7a2:	f406                	sd	ra,40(sp)
     7a4:	f022                	sd	s0,32(sp)
     7a6:	ec26                	sd	s1,24(sp)
     7a8:	e84a                	sd	s2,16(sp)
     7aa:	e44e                	sd	s3,8(sp)
     7ac:	1800                	addi	s0,sp,48
     7ae:	84aa                	mv	s1,a0
     7b0:	892e                	mv	s2,a1
  if(!peek(ps, es, "("))
     7b2:	00001617          	auipc	a2,0x1
     7b6:	aee60613          	addi	a2,a2,-1298 # 12a0 <malloc+0x186>
     7ba:	ce5ff0ef          	jal	49e <peek>
     7be:	c539                	beqz	a0,80c <parseblock+0x6c>
  gettoken(ps, es, 0, 0);
     7c0:	4681                	li	a3,0
     7c2:	4601                	li	a2,0
     7c4:	85ca                	mv	a1,s2
     7c6:	8526                	mv	a0,s1
     7c8:	b9bff0ef          	jal	362 <gettoken>
  cmd = parseline(ps, es);
     7cc:	85ca                	mv	a1,s2
     7ce:	8526                	mv	a0,s1
     7d0:	f49ff0ef          	jal	718 <parseline>
     7d4:	89aa                	mv	s3,a0
  if(!peek(ps, es, ")"))
     7d6:	00001617          	auipc	a2,0x1
     7da:	b1a60613          	addi	a2,a2,-1254 # 12f0 <malloc+0x1d6>
     7de:	85ca                	mv	a1,s2
     7e0:	8526                	mv	a0,s1
     7e2:	cbdff0ef          	jal	49e <peek>
     7e6:	c90d                	beqz	a0,818 <parseblock+0x78>
  gettoken(ps, es, 0, 0);
     7e8:	4681                	li	a3,0
     7ea:	4601                	li	a2,0
     7ec:	85ca                	mv	a1,s2
     7ee:	8526                	mv	a0,s1
     7f0:	b73ff0ef          	jal	362 <gettoken>
  cmd = parseredirs(cmd, ps, es);
     7f4:	864a                	mv	a2,s2
     7f6:	85a6                	mv	a1,s1
     7f8:	854e                	mv	a0,s3
     7fa:	d09ff0ef          	jal	502 <parseredirs>
}
     7fe:	70a2                	ld	ra,40(sp)
     800:	7402                	ld	s0,32(sp)
     802:	64e2                	ld	s1,24(sp)
     804:	6942                	ld	s2,16(sp)
     806:	69a2                	ld	s3,8(sp)
     808:	6145                	addi	sp,sp,48
     80a:	8082                	ret
    panic("parseblock");
     80c:	00001517          	auipc	a0,0x1
     810:	ad450513          	addi	a0,a0,-1324 # 12e0 <malloc+0x1c6>
     814:	889ff0ef          	jal	9c <panic>
    panic("syntax - missing )");
     818:	00001517          	auipc	a0,0x1
     81c:	ae050513          	addi	a0,a0,-1312 # 12f8 <malloc+0x1de>
     820:	87dff0ef          	jal	9c <panic>

0000000000000824 <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
     824:	1101                	addi	sp,sp,-32
     826:	ec06                	sd	ra,24(sp)
     828:	e822                	sd	s0,16(sp)
     82a:	e426                	sd	s1,8(sp)
     82c:	1000                	addi	s0,sp,32
     82e:	84aa                	mv	s1,a0
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
     830:	c131                	beqz	a0,874 <nulterminate+0x50>
    return 0;

  switch(cmd->type){
     832:	4118                	lw	a4,0(a0)
     834:	4795                	li	a5,5
     836:	02e7ef63          	bltu	a5,a4,874 <nulterminate+0x50>
     83a:	00056783          	lwu	a5,0(a0)
     83e:	078a                	slli	a5,a5,0x2
     840:	00001717          	auipc	a4,0x1
     844:	b1870713          	addi	a4,a4,-1256 # 1358 <malloc+0x23e>
     848:	97ba                	add	a5,a5,a4
     84a:	439c                	lw	a5,0(a5)
     84c:	97ba                	add	a5,a5,a4
     84e:	8782                	jr	a5
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
     850:	651c                	ld	a5,8(a0)
     852:	c38d                	beqz	a5,874 <nulterminate+0x50>
     854:	01050793          	addi	a5,a0,16
      *ecmd->eargv[i] = 0;
     858:	67b8                	ld	a4,72(a5)
     85a:	00070023          	sb	zero,0(a4)
    for(i=0; ecmd->argv[i]; i++)
     85e:	07a1                	addi	a5,a5,8
     860:	ff87b703          	ld	a4,-8(a5)
     864:	fb75                	bnez	a4,858 <nulterminate+0x34>
     866:	a039                	j	874 <nulterminate+0x50>
    break;

  case REDIR:
    rcmd = (struct redircmd*)cmd;
    nulterminate(rcmd->cmd);
     868:	6508                	ld	a0,8(a0)
     86a:	fbbff0ef          	jal	824 <nulterminate>
    *rcmd->efile = 0;
     86e:	6c9c                	ld	a5,24(s1)
     870:	00078023          	sb	zero,0(a5)
    bcmd = (struct backcmd*)cmd;
    nulterminate(bcmd->cmd);
    break;
  }
  return cmd;
}
     874:	8526                	mv	a0,s1
     876:	60e2                	ld	ra,24(sp)
     878:	6442                	ld	s0,16(sp)
     87a:	64a2                	ld	s1,8(sp)
     87c:	6105                	addi	sp,sp,32
     87e:	8082                	ret
    nulterminate(pcmd->left);
     880:	6508                	ld	a0,8(a0)
     882:	fa3ff0ef          	jal	824 <nulterminate>
    nulterminate(pcmd->right);
     886:	6888                	ld	a0,16(s1)
     888:	f9dff0ef          	jal	824 <nulterminate>
    break;
     88c:	b7e5                	j	874 <nulterminate+0x50>
    nulterminate(lcmd->left);
     88e:	6508                	ld	a0,8(a0)
     890:	f95ff0ef          	jal	824 <nulterminate>
    nulterminate(lcmd->right);
     894:	6888                	ld	a0,16(s1)
     896:	f8fff0ef          	jal	824 <nulterminate>
    break;
     89a:	bfe9                	j	874 <nulterminate+0x50>
    nulterminate(bcmd->cmd);
     89c:	6508                	ld	a0,8(a0)
     89e:	f87ff0ef          	jal	824 <nulterminate>
    break;
     8a2:	bfc9                	j	874 <nulterminate+0x50>

00000000000008a4 <parsecmd>:
{
     8a4:	7179                	addi	sp,sp,-48
     8a6:	f406                	sd	ra,40(sp)
     8a8:	f022                	sd	s0,32(sp)
     8aa:	ec26                	sd	s1,24(sp)
     8ac:	e84a                	sd	s2,16(sp)
     8ae:	1800                	addi	s0,sp,48
     8b0:	fca43c23          	sd	a0,-40(s0)
  es = s + strlen(s);
     8b4:	84aa                	mv	s1,a0
     8b6:	188000ef          	jal	a3e <strlen>
     8ba:	1502                	slli	a0,a0,0x20
     8bc:	9101                	srli	a0,a0,0x20
     8be:	94aa                	add	s1,s1,a0
  cmd = parseline(&s, es);
     8c0:	85a6                	mv	a1,s1
     8c2:	fd840513          	addi	a0,s0,-40
     8c6:	e53ff0ef          	jal	718 <parseline>
     8ca:	892a                	mv	s2,a0
  peek(&s, es, "");
     8cc:	00001617          	auipc	a2,0x1
     8d0:	96460613          	addi	a2,a2,-1692 # 1230 <malloc+0x116>
     8d4:	85a6                	mv	a1,s1
     8d6:	fd840513          	addi	a0,s0,-40
     8da:	bc5ff0ef          	jal	49e <peek>
  if(s != es){
     8de:	fd843603          	ld	a2,-40(s0)
     8e2:	00961c63          	bne	a2,s1,8fa <parsecmd+0x56>
  nulterminate(cmd);
     8e6:	854a                	mv	a0,s2
     8e8:	f3dff0ef          	jal	824 <nulterminate>
}
     8ec:	854a                	mv	a0,s2
     8ee:	70a2                	ld	ra,40(sp)
     8f0:	7402                	ld	s0,32(sp)
     8f2:	64e2                	ld	s1,24(sp)
     8f4:	6942                	ld	s2,16(sp)
     8f6:	6145                	addi	sp,sp,48
     8f8:	8082                	ret
    fprintf(2, "leftovers: %s\n", s);
     8fa:	00001597          	auipc	a1,0x1
     8fe:	a1658593          	addi	a1,a1,-1514 # 1310 <malloc+0x1f6>
     902:	4509                	li	a0,2
     904:	738000ef          	jal	103c <fprintf>
    panic("syntax");
     908:	00001517          	auipc	a0,0x1
     90c:	9a050513          	addi	a0,a0,-1632 # 12a8 <malloc+0x18e>
     910:	f8cff0ef          	jal	9c <panic>

0000000000000914 <main>:
{
     914:	7179                	addi	sp,sp,-48
     916:	f406                	sd	ra,40(sp)
     918:	f022                	sd	s0,32(sp)
     91a:	ec26                	sd	s1,24(sp)
     91c:	e84a                	sd	s2,16(sp)
     91e:	e44e                	sd	s3,8(sp)
     920:	e052                	sd	s4,0(sp)
     922:	1800                	addi	s0,sp,48
  while((fd = open("console", O_RDWR)) >= 0){
     924:	00001497          	auipc	s1,0x1
     928:	9fc48493          	addi	s1,s1,-1540 # 1320 <malloc+0x206>
     92c:	4589                	li	a1,2
     92e:	8526                	mv	a0,s1
     930:	35e000ef          	jal	c8e <open>
     934:	00054763          	bltz	a0,942 <main+0x2e>
    if(fd >= 3){
     938:	4789                	li	a5,2
     93a:	fea7d9e3          	bge	a5,a0,92c <main+0x18>
      close(fd);
     93e:	338000ef          	jal	c76 <close>
  while(getcmd(buf, sizeof(buf)) >= 0){
     942:	00001497          	auipc	s1,0x1
     946:	6de48493          	addi	s1,s1,1758 # 2020 <buf.0>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     94a:	06300913          	li	s2,99
     94e:	02000993          	li	s3,32
     952:	a039                	j	960 <main+0x4c>
    if(fork1() == 0)
     954:	f66ff0ef          	jal	ba <fork1>
     958:	c93d                	beqz	a0,9ce <main+0xba>
    wait(0);
     95a:	4501                	li	a0,0
     95c:	2fa000ef          	jal	c56 <wait>
  while(getcmd(buf, sizeof(buf)) >= 0){
     960:	06400593          	li	a1,100
     964:	8526                	mv	a0,s1
     966:	eecff0ef          	jal	52 <getcmd>
     96a:	06054a63          	bltz	a0,9de <main+0xca>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     96e:	0004c783          	lbu	a5,0(s1)
     972:	ff2791e3          	bne	a5,s2,954 <main+0x40>
     976:	0014c703          	lbu	a4,1(s1)
     97a:	06400793          	li	a5,100
     97e:	fcf71be3          	bne	a4,a5,954 <main+0x40>
     982:	0024c783          	lbu	a5,2(s1)
     986:	fd3797e3          	bne	a5,s3,954 <main+0x40>
      buf[strlen(buf)-1] = 0;  // chop \n
     98a:	00001a17          	auipc	s4,0x1
     98e:	696a0a13          	addi	s4,s4,1686 # 2020 <buf.0>
     992:	8552                	mv	a0,s4
     994:	0aa000ef          	jal	a3e <strlen>
     998:	fff5079b          	addiw	a5,a0,-1
     99c:	1782                	slli	a5,a5,0x20
     99e:	9381                	srli	a5,a5,0x20
     9a0:	9a3e                	add	s4,s4,a5
     9a2:	000a0023          	sb	zero,0(s4)
      if(chdir(buf+3) < 0)
     9a6:	00001517          	auipc	a0,0x1
     9aa:	67d50513          	addi	a0,a0,1661 # 2023 <buf.0+0x3>
     9ae:	310000ef          	jal	cbe <chdir>
     9b2:	fa0557e3          	bgez	a0,960 <main+0x4c>
        fprintf(2, "cannot cd %s\n", buf+3);
     9b6:	00001617          	auipc	a2,0x1
     9ba:	66d60613          	addi	a2,a2,1645 # 2023 <buf.0+0x3>
     9be:	00001597          	auipc	a1,0x1
     9c2:	96a58593          	addi	a1,a1,-1686 # 1328 <malloc+0x20e>
     9c6:	4509                	li	a0,2
     9c8:	674000ef          	jal	103c <fprintf>
     9cc:	bf51                	j	960 <main+0x4c>
      runcmd(parsecmd(buf));
     9ce:	00001517          	auipc	a0,0x1
     9d2:	65250513          	addi	a0,a0,1618 # 2020 <buf.0>
     9d6:	ecfff0ef          	jal	8a4 <parsecmd>
     9da:	f06ff0ef          	jal	e0 <runcmd>
  exit(0);
     9de:	4501                	li	a0,0
     9e0:	26e000ef          	jal	c4e <exit>

00000000000009e4 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
     9e4:	1141                	addi	sp,sp,-16
     9e6:	e406                	sd	ra,8(sp)
     9e8:	e022                	sd	s0,0(sp)
     9ea:	0800                	addi	s0,sp,16
  extern int main();
  main();
     9ec:	f29ff0ef          	jal	914 <main>
  exit(0);
     9f0:	4501                	li	a0,0
     9f2:	25c000ef          	jal	c4e <exit>

00000000000009f6 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
     9f6:	1141                	addi	sp,sp,-16
     9f8:	e422                	sd	s0,8(sp)
     9fa:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     9fc:	87aa                	mv	a5,a0
     9fe:	0585                	addi	a1,a1,1
     a00:	0785                	addi	a5,a5,1
     a02:	fff5c703          	lbu	a4,-1(a1)
     a06:	fee78fa3          	sb	a4,-1(a5)
     a0a:	fb75                	bnez	a4,9fe <strcpy+0x8>
    ;
  return os;
}
     a0c:	6422                	ld	s0,8(sp)
     a0e:	0141                	addi	sp,sp,16
     a10:	8082                	ret

0000000000000a12 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     a12:	1141                	addi	sp,sp,-16
     a14:	e422                	sd	s0,8(sp)
     a16:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     a18:	00054783          	lbu	a5,0(a0)
     a1c:	cb91                	beqz	a5,a30 <strcmp+0x1e>
     a1e:	0005c703          	lbu	a4,0(a1)
     a22:	00f71763          	bne	a4,a5,a30 <strcmp+0x1e>
    p++, q++;
     a26:	0505                	addi	a0,a0,1
     a28:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     a2a:	00054783          	lbu	a5,0(a0)
     a2e:	fbe5                	bnez	a5,a1e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     a30:	0005c503          	lbu	a0,0(a1)
}
     a34:	40a7853b          	subw	a0,a5,a0
     a38:	6422                	ld	s0,8(sp)
     a3a:	0141                	addi	sp,sp,16
     a3c:	8082                	ret

0000000000000a3e <strlen>:

uint
strlen(const char *s)
{
     a3e:	1141                	addi	sp,sp,-16
     a40:	e422                	sd	s0,8(sp)
     a42:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     a44:	00054783          	lbu	a5,0(a0)
     a48:	cf91                	beqz	a5,a64 <strlen+0x26>
     a4a:	0505                	addi	a0,a0,1
     a4c:	87aa                	mv	a5,a0
     a4e:	86be                	mv	a3,a5
     a50:	0785                	addi	a5,a5,1
     a52:	fff7c703          	lbu	a4,-1(a5)
     a56:	ff65                	bnez	a4,a4e <strlen+0x10>
     a58:	40a6853b          	subw	a0,a3,a0
     a5c:	2505                	addiw	a0,a0,1
    ;
  return n;
}
     a5e:	6422                	ld	s0,8(sp)
     a60:	0141                	addi	sp,sp,16
     a62:	8082                	ret
  for(n = 0; s[n]; n++)
     a64:	4501                	li	a0,0
     a66:	bfe5                	j	a5e <strlen+0x20>

0000000000000a68 <memset>:

void*
memset(void *dst, int c, uint n)
{
     a68:	1141                	addi	sp,sp,-16
     a6a:	e422                	sd	s0,8(sp)
     a6c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     a6e:	ca19                	beqz	a2,a84 <memset+0x1c>
     a70:	87aa                	mv	a5,a0
     a72:	1602                	slli	a2,a2,0x20
     a74:	9201                	srli	a2,a2,0x20
     a76:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     a7a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     a7e:	0785                	addi	a5,a5,1
     a80:	fee79de3          	bne	a5,a4,a7a <memset+0x12>
  }
  return dst;
}
     a84:	6422                	ld	s0,8(sp)
     a86:	0141                	addi	sp,sp,16
     a88:	8082                	ret

0000000000000a8a <strchr>:

char*
strchr(const char *s, char c)
{
     a8a:	1141                	addi	sp,sp,-16
     a8c:	e422                	sd	s0,8(sp)
     a8e:	0800                	addi	s0,sp,16
  for(; *s; s++)
     a90:	00054783          	lbu	a5,0(a0)
     a94:	cb99                	beqz	a5,aaa <strchr+0x20>
    if(*s == c)
     a96:	00f58763          	beq	a1,a5,aa4 <strchr+0x1a>
  for(; *s; s++)
     a9a:	0505                	addi	a0,a0,1
     a9c:	00054783          	lbu	a5,0(a0)
     aa0:	fbfd                	bnez	a5,a96 <strchr+0xc>
      return (char*)s;
  return 0;
     aa2:	4501                	li	a0,0
}
     aa4:	6422                	ld	s0,8(sp)
     aa6:	0141                	addi	sp,sp,16
     aa8:	8082                	ret
  return 0;
     aaa:	4501                	li	a0,0
     aac:	bfe5                	j	aa4 <strchr+0x1a>

0000000000000aae <gets>:

char*
gets(char *buf, int max)
{
     aae:	711d                	addi	sp,sp,-96
     ab0:	ec86                	sd	ra,88(sp)
     ab2:	e8a2                	sd	s0,80(sp)
     ab4:	e4a6                	sd	s1,72(sp)
     ab6:	e0ca                	sd	s2,64(sp)
     ab8:	fc4e                	sd	s3,56(sp)
     aba:	f852                	sd	s4,48(sp)
     abc:	f456                	sd	s5,40(sp)
     abe:	f05a                	sd	s6,32(sp)
     ac0:	ec5e                	sd	s7,24(sp)
     ac2:	1080                	addi	s0,sp,96
     ac4:	8baa                	mv	s7,a0
     ac6:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     ac8:	892a                	mv	s2,a0
     aca:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     acc:	4aa9                	li	s5,10
     ace:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     ad0:	89a6                	mv	s3,s1
     ad2:	2485                	addiw	s1,s1,1
     ad4:	0344d663          	bge	s1,s4,b00 <gets+0x52>
    cc = read(0, &c, 1);
     ad8:	4605                	li	a2,1
     ada:	faf40593          	addi	a1,s0,-81
     ade:	4501                	li	a0,0
     ae0:	186000ef          	jal	c66 <read>
    if(cc < 1)
     ae4:	00a05e63          	blez	a0,b00 <gets+0x52>
    buf[i++] = c;
     ae8:	faf44783          	lbu	a5,-81(s0)
     aec:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     af0:	01578763          	beq	a5,s5,afe <gets+0x50>
     af4:	0905                	addi	s2,s2,1
     af6:	fd679de3          	bne	a5,s6,ad0 <gets+0x22>
    buf[i++] = c;
     afa:	89a6                	mv	s3,s1
     afc:	a011                	j	b00 <gets+0x52>
     afe:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     b00:	99de                	add	s3,s3,s7
     b02:	00098023          	sb	zero,0(s3)
  return buf;
}
     b06:	855e                	mv	a0,s7
     b08:	60e6                	ld	ra,88(sp)
     b0a:	6446                	ld	s0,80(sp)
     b0c:	64a6                	ld	s1,72(sp)
     b0e:	6906                	ld	s2,64(sp)
     b10:	79e2                	ld	s3,56(sp)
     b12:	7a42                	ld	s4,48(sp)
     b14:	7aa2                	ld	s5,40(sp)
     b16:	7b02                	ld	s6,32(sp)
     b18:	6be2                	ld	s7,24(sp)
     b1a:	6125                	addi	sp,sp,96
     b1c:	8082                	ret

0000000000000b1e <stat>:

int
stat(const char *n, struct stat *st)
{
     b1e:	1101                	addi	sp,sp,-32
     b20:	ec06                	sd	ra,24(sp)
     b22:	e822                	sd	s0,16(sp)
     b24:	e04a                	sd	s2,0(sp)
     b26:	1000                	addi	s0,sp,32
     b28:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     b2a:	4581                	li	a1,0
     b2c:	162000ef          	jal	c8e <open>
  if(fd < 0)
     b30:	02054263          	bltz	a0,b54 <stat+0x36>
     b34:	e426                	sd	s1,8(sp)
     b36:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     b38:	85ca                	mv	a1,s2
     b3a:	16c000ef          	jal	ca6 <fstat>
     b3e:	892a                	mv	s2,a0
  close(fd);
     b40:	8526                	mv	a0,s1
     b42:	134000ef          	jal	c76 <close>
  return r;
     b46:	64a2                	ld	s1,8(sp)
}
     b48:	854a                	mv	a0,s2
     b4a:	60e2                	ld	ra,24(sp)
     b4c:	6442                	ld	s0,16(sp)
     b4e:	6902                	ld	s2,0(sp)
     b50:	6105                	addi	sp,sp,32
     b52:	8082                	ret
    return -1;
     b54:	597d                	li	s2,-1
     b56:	bfcd                	j	b48 <stat+0x2a>

0000000000000b58 <atoi>:

int
atoi(const char *s)
{
     b58:	1141                	addi	sp,sp,-16
     b5a:	e422                	sd	s0,8(sp)
     b5c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     b5e:	00054683          	lbu	a3,0(a0)
     b62:	fd06879b          	addiw	a5,a3,-48
     b66:	0ff7f793          	zext.b	a5,a5
     b6a:	4625                	li	a2,9
     b6c:	02f66863          	bltu	a2,a5,b9c <atoi+0x44>
     b70:	872a                	mv	a4,a0
  n = 0;
     b72:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
     b74:	0705                	addi	a4,a4,1
     b76:	0025179b          	slliw	a5,a0,0x2
     b7a:	9fa9                	addw	a5,a5,a0
     b7c:	0017979b          	slliw	a5,a5,0x1
     b80:	9fb5                	addw	a5,a5,a3
     b82:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     b86:	00074683          	lbu	a3,0(a4)
     b8a:	fd06879b          	addiw	a5,a3,-48
     b8e:	0ff7f793          	zext.b	a5,a5
     b92:	fef671e3          	bgeu	a2,a5,b74 <atoi+0x1c>
  return n;
}
     b96:	6422                	ld	s0,8(sp)
     b98:	0141                	addi	sp,sp,16
     b9a:	8082                	ret
  n = 0;
     b9c:	4501                	li	a0,0
     b9e:	bfe5                	j	b96 <atoi+0x3e>

0000000000000ba0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     ba0:	1141                	addi	sp,sp,-16
     ba2:	e422                	sd	s0,8(sp)
     ba4:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     ba6:	02b57463          	bgeu	a0,a1,bce <memmove+0x2e>
    while(n-- > 0)
     baa:	00c05f63          	blez	a2,bc8 <memmove+0x28>
     bae:	1602                	slli	a2,a2,0x20
     bb0:	9201                	srli	a2,a2,0x20
     bb2:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     bb6:	872a                	mv	a4,a0
      *dst++ = *src++;
     bb8:	0585                	addi	a1,a1,1
     bba:	0705                	addi	a4,a4,1
     bbc:	fff5c683          	lbu	a3,-1(a1)
     bc0:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     bc4:	fef71ae3          	bne	a4,a5,bb8 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     bc8:	6422                	ld	s0,8(sp)
     bca:	0141                	addi	sp,sp,16
     bcc:	8082                	ret
    dst += n;
     bce:	00c50733          	add	a4,a0,a2
    src += n;
     bd2:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     bd4:	fec05ae3          	blez	a2,bc8 <memmove+0x28>
     bd8:	fff6079b          	addiw	a5,a2,-1
     bdc:	1782                	slli	a5,a5,0x20
     bde:	9381                	srli	a5,a5,0x20
     be0:	fff7c793          	not	a5,a5
     be4:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     be6:	15fd                	addi	a1,a1,-1
     be8:	177d                	addi	a4,a4,-1
     bea:	0005c683          	lbu	a3,0(a1)
     bee:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     bf2:	fee79ae3          	bne	a5,a4,be6 <memmove+0x46>
     bf6:	bfc9                	j	bc8 <memmove+0x28>

0000000000000bf8 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     bf8:	1141                	addi	sp,sp,-16
     bfa:	e422                	sd	s0,8(sp)
     bfc:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     bfe:	ca05                	beqz	a2,c2e <memcmp+0x36>
     c00:	fff6069b          	addiw	a3,a2,-1
     c04:	1682                	slli	a3,a3,0x20
     c06:	9281                	srli	a3,a3,0x20
     c08:	0685                	addi	a3,a3,1
     c0a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     c0c:	00054783          	lbu	a5,0(a0)
     c10:	0005c703          	lbu	a4,0(a1)
     c14:	00e79863          	bne	a5,a4,c24 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     c18:	0505                	addi	a0,a0,1
    p2++;
     c1a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     c1c:	fed518e3          	bne	a0,a3,c0c <memcmp+0x14>
  }
  return 0;
     c20:	4501                	li	a0,0
     c22:	a019                	j	c28 <memcmp+0x30>
      return *p1 - *p2;
     c24:	40e7853b          	subw	a0,a5,a4
}
     c28:	6422                	ld	s0,8(sp)
     c2a:	0141                	addi	sp,sp,16
     c2c:	8082                	ret
  return 0;
     c2e:	4501                	li	a0,0
     c30:	bfe5                	j	c28 <memcmp+0x30>

0000000000000c32 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     c32:	1141                	addi	sp,sp,-16
     c34:	e406                	sd	ra,8(sp)
     c36:	e022                	sd	s0,0(sp)
     c38:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     c3a:	f67ff0ef          	jal	ba0 <memmove>
}
     c3e:	60a2                	ld	ra,8(sp)
     c40:	6402                	ld	s0,0(sp)
     c42:	0141                	addi	sp,sp,16
     c44:	8082                	ret

0000000000000c46 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     c46:	4885                	li	a7,1
 ecall
     c48:	00000073          	ecall
 ret
     c4c:	8082                	ret

0000000000000c4e <exit>:
.global exit
exit:
 li a7, SYS_exit
     c4e:	4889                	li	a7,2
 ecall
     c50:	00000073          	ecall
 ret
     c54:	8082                	ret

0000000000000c56 <wait>:
.global wait
wait:
 li a7, SYS_wait
     c56:	488d                	li	a7,3
 ecall
     c58:	00000073          	ecall
 ret
     c5c:	8082                	ret

0000000000000c5e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     c5e:	4891                	li	a7,4
 ecall
     c60:	00000073          	ecall
 ret
     c64:	8082                	ret

0000000000000c66 <read>:
.global read
read:
 li a7, SYS_read
     c66:	4895                	li	a7,5
 ecall
     c68:	00000073          	ecall
 ret
     c6c:	8082                	ret

0000000000000c6e <write>:
.global write
write:
 li a7, SYS_write
     c6e:	48c1                	li	a7,16
 ecall
     c70:	00000073          	ecall
 ret
     c74:	8082                	ret

0000000000000c76 <close>:
.global close
close:
 li a7, SYS_close
     c76:	48d5                	li	a7,21
 ecall
     c78:	00000073          	ecall
 ret
     c7c:	8082                	ret

0000000000000c7e <kill>:
.global kill
kill:
 li a7, SYS_kill
     c7e:	4899                	li	a7,6
 ecall
     c80:	00000073          	ecall
 ret
     c84:	8082                	ret

0000000000000c86 <exec>:
.global exec
exec:
 li a7, SYS_exec
     c86:	489d                	li	a7,7
 ecall
     c88:	00000073          	ecall
 ret
     c8c:	8082                	ret

0000000000000c8e <open>:
.global open
open:
 li a7, SYS_open
     c8e:	48bd                	li	a7,15
 ecall
     c90:	00000073          	ecall
 ret
     c94:	8082                	ret

0000000000000c96 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     c96:	48c5                	li	a7,17
 ecall
     c98:	00000073          	ecall
 ret
     c9c:	8082                	ret

0000000000000c9e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     c9e:	48c9                	li	a7,18
 ecall
     ca0:	00000073          	ecall
 ret
     ca4:	8082                	ret

0000000000000ca6 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     ca6:	48a1                	li	a7,8
 ecall
     ca8:	00000073          	ecall
 ret
     cac:	8082                	ret

0000000000000cae <link>:
.global link
link:
 li a7, SYS_link
     cae:	48cd                	li	a7,19
 ecall
     cb0:	00000073          	ecall
 ret
     cb4:	8082                	ret

0000000000000cb6 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     cb6:	48d1                	li	a7,20
 ecall
     cb8:	00000073          	ecall
 ret
     cbc:	8082                	ret

0000000000000cbe <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     cbe:	48a5                	li	a7,9
 ecall
     cc0:	00000073          	ecall
 ret
     cc4:	8082                	ret

0000000000000cc6 <dup>:
.global dup
dup:
 li a7, SYS_dup
     cc6:	48a9                	li	a7,10
 ecall
     cc8:	00000073          	ecall
 ret
     ccc:	8082                	ret

0000000000000cce <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     cce:	48ad                	li	a7,11
 ecall
     cd0:	00000073          	ecall
 ret
     cd4:	8082                	ret

0000000000000cd6 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     cd6:	48b1                	li	a7,12
 ecall
     cd8:	00000073          	ecall
 ret
     cdc:	8082                	ret

0000000000000cde <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     cde:	48b5                	li	a7,13
 ecall
     ce0:	00000073          	ecall
 ret
     ce4:	8082                	ret

0000000000000ce6 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     ce6:	48b9                	li	a7,14
 ecall
     ce8:	00000073          	ecall
 ret
     cec:	8082                	ret

0000000000000cee <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     cee:	1101                	addi	sp,sp,-32
     cf0:	ec06                	sd	ra,24(sp)
     cf2:	e822                	sd	s0,16(sp)
     cf4:	1000                	addi	s0,sp,32
     cf6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     cfa:	4605                	li	a2,1
     cfc:	fef40593          	addi	a1,s0,-17
     d00:	f6fff0ef          	jal	c6e <write>
}
     d04:	60e2                	ld	ra,24(sp)
     d06:	6442                	ld	s0,16(sp)
     d08:	6105                	addi	sp,sp,32
     d0a:	8082                	ret

0000000000000d0c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     d0c:	7139                	addi	sp,sp,-64
     d0e:	fc06                	sd	ra,56(sp)
     d10:	f822                	sd	s0,48(sp)
     d12:	f426                	sd	s1,40(sp)
     d14:	0080                	addi	s0,sp,64
     d16:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
     d18:	c299                	beqz	a3,d1e <printint+0x12>
     d1a:	0805c963          	bltz	a1,dac <printint+0xa0>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
     d1e:	2581                	sext.w	a1,a1
  neg = 0;
     d20:	4881                	li	a7,0
     d22:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
     d26:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
     d28:	2601                	sext.w	a2,a2
     d2a:	00000517          	auipc	a0,0x0
     d2e:	64650513          	addi	a0,a0,1606 # 1370 <digits>
     d32:	883a                	mv	a6,a4
     d34:	2705                	addiw	a4,a4,1
     d36:	02c5f7bb          	remuw	a5,a1,a2
     d3a:	1782                	slli	a5,a5,0x20
     d3c:	9381                	srli	a5,a5,0x20
     d3e:	97aa                	add	a5,a5,a0
     d40:	0007c783          	lbu	a5,0(a5)
     d44:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
     d48:	0005879b          	sext.w	a5,a1
     d4c:	02c5d5bb          	divuw	a1,a1,a2
     d50:	0685                	addi	a3,a3,1
     d52:	fec7f0e3          	bgeu	a5,a2,d32 <printint+0x26>
  if(neg)
     d56:	00088c63          	beqz	a7,d6e <printint+0x62>
    buf[i++] = '-';
     d5a:	fd070793          	addi	a5,a4,-48
     d5e:	00878733          	add	a4,a5,s0
     d62:	02d00793          	li	a5,45
     d66:	fef70823          	sb	a5,-16(a4)
     d6a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
     d6e:	02e05a63          	blez	a4,da2 <printint+0x96>
     d72:	f04a                	sd	s2,32(sp)
     d74:	ec4e                	sd	s3,24(sp)
     d76:	fc040793          	addi	a5,s0,-64
     d7a:	00e78933          	add	s2,a5,a4
     d7e:	fff78993          	addi	s3,a5,-1
     d82:	99ba                	add	s3,s3,a4
     d84:	377d                	addiw	a4,a4,-1
     d86:	1702                	slli	a4,a4,0x20
     d88:	9301                	srli	a4,a4,0x20
     d8a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
     d8e:	fff94583          	lbu	a1,-1(s2)
     d92:	8526                	mv	a0,s1
     d94:	f5bff0ef          	jal	cee <putc>
  while(--i >= 0)
     d98:	197d                	addi	s2,s2,-1
     d9a:	ff391ae3          	bne	s2,s3,d8e <printint+0x82>
     d9e:	7902                	ld	s2,32(sp)
     da0:	69e2                	ld	s3,24(sp)
}
     da2:	70e2                	ld	ra,56(sp)
     da4:	7442                	ld	s0,48(sp)
     da6:	74a2                	ld	s1,40(sp)
     da8:	6121                	addi	sp,sp,64
     daa:	8082                	ret
    x = -xx;
     dac:	40b005bb          	negw	a1,a1
    neg = 1;
     db0:	4885                	li	a7,1
    x = -xx;
     db2:	bf85                	j	d22 <printint+0x16>

0000000000000db4 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
     db4:	711d                	addi	sp,sp,-96
     db6:	ec86                	sd	ra,88(sp)
     db8:	e8a2                	sd	s0,80(sp)
     dba:	e0ca                	sd	s2,64(sp)
     dbc:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
     dbe:	0005c903          	lbu	s2,0(a1)
     dc2:	26090863          	beqz	s2,1032 <vprintf+0x27e>
     dc6:	e4a6                	sd	s1,72(sp)
     dc8:	fc4e                	sd	s3,56(sp)
     dca:	f852                	sd	s4,48(sp)
     dcc:	f456                	sd	s5,40(sp)
     dce:	f05a                	sd	s6,32(sp)
     dd0:	ec5e                	sd	s7,24(sp)
     dd2:	e862                	sd	s8,16(sp)
     dd4:	e466                	sd	s9,8(sp)
     dd6:	8b2a                	mv	s6,a0
     dd8:	8a2e                	mv	s4,a1
     dda:	8bb2                	mv	s7,a2
  state = 0;
     ddc:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
     dde:	4481                	li	s1,0
     de0:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
     de2:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
     de6:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
     dea:	06c00c93          	li	s9,108
     dee:	a005                	j	e0e <vprintf+0x5a>
        putc(fd, c0);
     df0:	85ca                	mv	a1,s2
     df2:	855a                	mv	a0,s6
     df4:	efbff0ef          	jal	cee <putc>
     df8:	a019                	j	dfe <vprintf+0x4a>
    } else if(state == '%'){
     dfa:	03598263          	beq	s3,s5,e1e <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
     dfe:	2485                	addiw	s1,s1,1
     e00:	8726                	mv	a4,s1
     e02:	009a07b3          	add	a5,s4,s1
     e06:	0007c903          	lbu	s2,0(a5)
     e0a:	20090c63          	beqz	s2,1022 <vprintf+0x26e>
    c0 = fmt[i] & 0xff;
     e0e:	0009079b          	sext.w	a5,s2
    if(state == 0){
     e12:	fe0994e3          	bnez	s3,dfa <vprintf+0x46>
      if(c0 == '%'){
     e16:	fd579de3          	bne	a5,s5,df0 <vprintf+0x3c>
        state = '%';
     e1a:	89be                	mv	s3,a5
     e1c:	b7cd                	j	dfe <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
     e1e:	00ea06b3          	add	a3,s4,a4
     e22:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
     e26:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
     e28:	c681                	beqz	a3,e30 <vprintf+0x7c>
     e2a:	9752                	add	a4,a4,s4
     e2c:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
     e30:	03878f63          	beq	a5,s8,e6e <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
     e34:	05978963          	beq	a5,s9,e86 <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
     e38:	07500713          	li	a4,117
     e3c:	0ee78363          	beq	a5,a4,f22 <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
     e40:	07800713          	li	a4,120
     e44:	12e78563          	beq	a5,a4,f6e <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
     e48:	07000713          	li	a4,112
     e4c:	14e78a63          	beq	a5,a4,fa0 <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
     e50:	07300713          	li	a4,115
     e54:	18e78a63          	beq	a5,a4,fe8 <vprintf+0x234>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
     e58:	02500713          	li	a4,37
     e5c:	04e79563          	bne	a5,a4,ea6 <vprintf+0xf2>
        putc(fd, '%');
     e60:	02500593          	li	a1,37
     e64:	855a                	mv	a0,s6
     e66:	e89ff0ef          	jal	cee <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
     e6a:	4981                	li	s3,0
     e6c:	bf49                	j	dfe <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
     e6e:	008b8913          	addi	s2,s7,8
     e72:	4685                	li	a3,1
     e74:	4629                	li	a2,10
     e76:	000ba583          	lw	a1,0(s7)
     e7a:	855a                	mv	a0,s6
     e7c:	e91ff0ef          	jal	d0c <printint>
     e80:	8bca                	mv	s7,s2
      state = 0;
     e82:	4981                	li	s3,0
     e84:	bfad                	j	dfe <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
     e86:	06400793          	li	a5,100
     e8a:	02f68963          	beq	a3,a5,ebc <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
     e8e:	06c00793          	li	a5,108
     e92:	04f68263          	beq	a3,a5,ed6 <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
     e96:	07500793          	li	a5,117
     e9a:	0af68063          	beq	a3,a5,f3a <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
     e9e:	07800793          	li	a5,120
     ea2:	0ef68263          	beq	a3,a5,f86 <vprintf+0x1d2>
        putc(fd, '%');
     ea6:	02500593          	li	a1,37
     eaa:	855a                	mv	a0,s6
     eac:	e43ff0ef          	jal	cee <putc>
        putc(fd, c0);
     eb0:	85ca                	mv	a1,s2
     eb2:	855a                	mv	a0,s6
     eb4:	e3bff0ef          	jal	cee <putc>
      state = 0;
     eb8:	4981                	li	s3,0
     eba:	b791                	j	dfe <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
     ebc:	008b8913          	addi	s2,s7,8
     ec0:	4685                	li	a3,1
     ec2:	4629                	li	a2,10
     ec4:	000ba583          	lw	a1,0(s7)
     ec8:	855a                	mv	a0,s6
     eca:	e43ff0ef          	jal	d0c <printint>
        i += 1;
     ece:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
     ed0:	8bca                	mv	s7,s2
      state = 0;
     ed2:	4981                	li	s3,0
        i += 1;
     ed4:	b72d                	j	dfe <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
     ed6:	06400793          	li	a5,100
     eda:	02f60763          	beq	a2,a5,f08 <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
     ede:	07500793          	li	a5,117
     ee2:	06f60963          	beq	a2,a5,f54 <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
     ee6:	07800793          	li	a5,120
     eea:	faf61ee3          	bne	a2,a5,ea6 <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
     eee:	008b8913          	addi	s2,s7,8
     ef2:	4681                	li	a3,0
     ef4:	4641                	li	a2,16
     ef6:	000ba583          	lw	a1,0(s7)
     efa:	855a                	mv	a0,s6
     efc:	e11ff0ef          	jal	d0c <printint>
        i += 2;
     f00:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
     f02:	8bca                	mv	s7,s2
      state = 0;
     f04:	4981                	li	s3,0
        i += 2;
     f06:	bde5                	j	dfe <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
     f08:	008b8913          	addi	s2,s7,8
     f0c:	4685                	li	a3,1
     f0e:	4629                	li	a2,10
     f10:	000ba583          	lw	a1,0(s7)
     f14:	855a                	mv	a0,s6
     f16:	df7ff0ef          	jal	d0c <printint>
        i += 2;
     f1a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
     f1c:	8bca                	mv	s7,s2
      state = 0;
     f1e:	4981                	li	s3,0
        i += 2;
     f20:	bdf9                	j	dfe <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
     f22:	008b8913          	addi	s2,s7,8
     f26:	4681                	li	a3,0
     f28:	4629                	li	a2,10
     f2a:	000ba583          	lw	a1,0(s7)
     f2e:	855a                	mv	a0,s6
     f30:	dddff0ef          	jal	d0c <printint>
     f34:	8bca                	mv	s7,s2
      state = 0;
     f36:	4981                	li	s3,0
     f38:	b5d9                	j	dfe <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
     f3a:	008b8913          	addi	s2,s7,8
     f3e:	4681                	li	a3,0
     f40:	4629                	li	a2,10
     f42:	000ba583          	lw	a1,0(s7)
     f46:	855a                	mv	a0,s6
     f48:	dc5ff0ef          	jal	d0c <printint>
        i += 1;
     f4c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
     f4e:	8bca                	mv	s7,s2
      state = 0;
     f50:	4981                	li	s3,0
        i += 1;
     f52:	b575                	j	dfe <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
     f54:	008b8913          	addi	s2,s7,8
     f58:	4681                	li	a3,0
     f5a:	4629                	li	a2,10
     f5c:	000ba583          	lw	a1,0(s7)
     f60:	855a                	mv	a0,s6
     f62:	dabff0ef          	jal	d0c <printint>
        i += 2;
     f66:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
     f68:	8bca                	mv	s7,s2
      state = 0;
     f6a:	4981                	li	s3,0
        i += 2;
     f6c:	bd49                	j	dfe <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
     f6e:	008b8913          	addi	s2,s7,8
     f72:	4681                	li	a3,0
     f74:	4641                	li	a2,16
     f76:	000ba583          	lw	a1,0(s7)
     f7a:	855a                	mv	a0,s6
     f7c:	d91ff0ef          	jal	d0c <printint>
     f80:	8bca                	mv	s7,s2
      state = 0;
     f82:	4981                	li	s3,0
     f84:	bdad                	j	dfe <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
     f86:	008b8913          	addi	s2,s7,8
     f8a:	4681                	li	a3,0
     f8c:	4641                	li	a2,16
     f8e:	000ba583          	lw	a1,0(s7)
     f92:	855a                	mv	a0,s6
     f94:	d79ff0ef          	jal	d0c <printint>
        i += 1;
     f98:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
     f9a:	8bca                	mv	s7,s2
      state = 0;
     f9c:	4981                	li	s3,0
        i += 1;
     f9e:	b585                	j	dfe <vprintf+0x4a>
     fa0:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
     fa2:	008b8d13          	addi	s10,s7,8
     fa6:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
     faa:	03000593          	li	a1,48
     fae:	855a                	mv	a0,s6
     fb0:	d3fff0ef          	jal	cee <putc>
  putc(fd, 'x');
     fb4:	07800593          	li	a1,120
     fb8:	855a                	mv	a0,s6
     fba:	d35ff0ef          	jal	cee <putc>
     fbe:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
     fc0:	00000b97          	auipc	s7,0x0
     fc4:	3b0b8b93          	addi	s7,s7,944 # 1370 <digits>
     fc8:	03c9d793          	srli	a5,s3,0x3c
     fcc:	97de                	add	a5,a5,s7
     fce:	0007c583          	lbu	a1,0(a5)
     fd2:	855a                	mv	a0,s6
     fd4:	d1bff0ef          	jal	cee <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
     fd8:	0992                	slli	s3,s3,0x4
     fda:	397d                	addiw	s2,s2,-1
     fdc:	fe0916e3          	bnez	s2,fc8 <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
     fe0:	8bea                	mv	s7,s10
      state = 0;
     fe2:	4981                	li	s3,0
     fe4:	6d02                	ld	s10,0(sp)
     fe6:	bd21                	j	dfe <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
     fe8:	008b8993          	addi	s3,s7,8
     fec:	000bb903          	ld	s2,0(s7)
     ff0:	00090f63          	beqz	s2,100e <vprintf+0x25a>
        for(; *s; s++)
     ff4:	00094583          	lbu	a1,0(s2)
     ff8:	c195                	beqz	a1,101c <vprintf+0x268>
          putc(fd, *s);
     ffa:	855a                	mv	a0,s6
     ffc:	cf3ff0ef          	jal	cee <putc>
        for(; *s; s++)
    1000:	0905                	addi	s2,s2,1
    1002:	00094583          	lbu	a1,0(s2)
    1006:	f9f5                	bnez	a1,ffa <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
    1008:	8bce                	mv	s7,s3
      state = 0;
    100a:	4981                	li	s3,0
    100c:	bbcd                	j	dfe <vprintf+0x4a>
          s = "(null)";
    100e:	00000917          	auipc	s2,0x0
    1012:	32a90913          	addi	s2,s2,810 # 1338 <malloc+0x21e>
        for(; *s; s++)
    1016:	02800593          	li	a1,40
    101a:	b7c5                	j	ffa <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
    101c:	8bce                	mv	s7,s3
      state = 0;
    101e:	4981                	li	s3,0
    1020:	bbf9                	j	dfe <vprintf+0x4a>
    1022:	64a6                	ld	s1,72(sp)
    1024:	79e2                	ld	s3,56(sp)
    1026:	7a42                	ld	s4,48(sp)
    1028:	7aa2                	ld	s5,40(sp)
    102a:	7b02                	ld	s6,32(sp)
    102c:	6be2                	ld	s7,24(sp)
    102e:	6c42                	ld	s8,16(sp)
    1030:	6ca2                	ld	s9,8(sp)
    }
  }
}
    1032:	60e6                	ld	ra,88(sp)
    1034:	6446                	ld	s0,80(sp)
    1036:	6906                	ld	s2,64(sp)
    1038:	6125                	addi	sp,sp,96
    103a:	8082                	ret

000000000000103c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    103c:	715d                	addi	sp,sp,-80
    103e:	ec06                	sd	ra,24(sp)
    1040:	e822                	sd	s0,16(sp)
    1042:	1000                	addi	s0,sp,32
    1044:	e010                	sd	a2,0(s0)
    1046:	e414                	sd	a3,8(s0)
    1048:	e818                	sd	a4,16(s0)
    104a:	ec1c                	sd	a5,24(s0)
    104c:	03043023          	sd	a6,32(s0)
    1050:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    1054:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    1058:	8622                	mv	a2,s0
    105a:	d5bff0ef          	jal	db4 <vprintf>
}
    105e:	60e2                	ld	ra,24(sp)
    1060:	6442                	ld	s0,16(sp)
    1062:	6161                	addi	sp,sp,80
    1064:	8082                	ret

0000000000001066 <printf>:

void
printf(const char *fmt, ...)
{
    1066:	711d                	addi	sp,sp,-96
    1068:	ec06                	sd	ra,24(sp)
    106a:	e822                	sd	s0,16(sp)
    106c:	1000                	addi	s0,sp,32
    106e:	e40c                	sd	a1,8(s0)
    1070:	e810                	sd	a2,16(s0)
    1072:	ec14                	sd	a3,24(s0)
    1074:	f018                	sd	a4,32(s0)
    1076:	f41c                	sd	a5,40(s0)
    1078:	03043823          	sd	a6,48(s0)
    107c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    1080:	00840613          	addi	a2,s0,8
    1084:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    1088:	85aa                	mv	a1,a0
    108a:	4505                	li	a0,1
    108c:	d29ff0ef          	jal	db4 <vprintf>
}
    1090:	60e2                	ld	ra,24(sp)
    1092:	6442                	ld	s0,16(sp)
    1094:	6125                	addi	sp,sp,96
    1096:	8082                	ret

0000000000001098 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    1098:	1141                	addi	sp,sp,-16
    109a:	e422                	sd	s0,8(sp)
    109c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    109e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    10a2:	00001797          	auipc	a5,0x1
    10a6:	f6e7b783          	ld	a5,-146(a5) # 2010 <freep>
    10aa:	a02d                	j	10d4 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    10ac:	4618                	lw	a4,8(a2)
    10ae:	9f2d                	addw	a4,a4,a1
    10b0:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    10b4:	6398                	ld	a4,0(a5)
    10b6:	6310                	ld	a2,0(a4)
    10b8:	a83d                	j	10f6 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    10ba:	ff852703          	lw	a4,-8(a0)
    10be:	9f31                	addw	a4,a4,a2
    10c0:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    10c2:	ff053683          	ld	a3,-16(a0)
    10c6:	a091                	j	110a <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    10c8:	6398                	ld	a4,0(a5)
    10ca:	00e7e463          	bltu	a5,a4,10d2 <free+0x3a>
    10ce:	00e6ea63          	bltu	a3,a4,10e2 <free+0x4a>
{
    10d2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    10d4:	fed7fae3          	bgeu	a5,a3,10c8 <free+0x30>
    10d8:	6398                	ld	a4,0(a5)
    10da:	00e6e463          	bltu	a3,a4,10e2 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    10de:	fee7eae3          	bltu	a5,a4,10d2 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
    10e2:	ff852583          	lw	a1,-8(a0)
    10e6:	6390                	ld	a2,0(a5)
    10e8:	02059813          	slli	a6,a1,0x20
    10ec:	01c85713          	srli	a4,a6,0x1c
    10f0:	9736                	add	a4,a4,a3
    10f2:	fae60de3          	beq	a2,a4,10ac <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
    10f6:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    10fa:	4790                	lw	a2,8(a5)
    10fc:	02061593          	slli	a1,a2,0x20
    1100:	01c5d713          	srli	a4,a1,0x1c
    1104:	973e                	add	a4,a4,a5
    1106:	fae68ae3          	beq	a3,a4,10ba <free+0x22>
    p->s.ptr = bp->s.ptr;
    110a:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    110c:	00001717          	auipc	a4,0x1
    1110:	f0f73223          	sd	a5,-252(a4) # 2010 <freep>
}
    1114:	6422                	ld	s0,8(sp)
    1116:	0141                	addi	sp,sp,16
    1118:	8082                	ret

000000000000111a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    111a:	7139                	addi	sp,sp,-64
    111c:	fc06                	sd	ra,56(sp)
    111e:	f822                	sd	s0,48(sp)
    1120:	f426                	sd	s1,40(sp)
    1122:	ec4e                	sd	s3,24(sp)
    1124:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1126:	02051493          	slli	s1,a0,0x20
    112a:	9081                	srli	s1,s1,0x20
    112c:	04bd                	addi	s1,s1,15
    112e:	8091                	srli	s1,s1,0x4
    1130:	0014899b          	addiw	s3,s1,1
    1134:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    1136:	00001517          	auipc	a0,0x1
    113a:	eda53503          	ld	a0,-294(a0) # 2010 <freep>
    113e:	c915                	beqz	a0,1172 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1140:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1142:	4798                	lw	a4,8(a5)
    1144:	08977a63          	bgeu	a4,s1,11d8 <malloc+0xbe>
    1148:	f04a                	sd	s2,32(sp)
    114a:	e852                	sd	s4,16(sp)
    114c:	e456                	sd	s5,8(sp)
    114e:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
    1150:	8a4e                	mv	s4,s3
    1152:	0009871b          	sext.w	a4,s3
    1156:	6685                	lui	a3,0x1
    1158:	00d77363          	bgeu	a4,a3,115e <malloc+0x44>
    115c:	6a05                	lui	s4,0x1
    115e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    1162:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    1166:	00001917          	auipc	s2,0x1
    116a:	eaa90913          	addi	s2,s2,-342 # 2010 <freep>
  if(p == (char*)-1)
    116e:	5afd                	li	s5,-1
    1170:	a081                	j	11b0 <malloc+0x96>
    1172:	f04a                	sd	s2,32(sp)
    1174:	e852                	sd	s4,16(sp)
    1176:	e456                	sd	s5,8(sp)
    1178:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
    117a:	00001797          	auipc	a5,0x1
    117e:	f0e78793          	addi	a5,a5,-242 # 2088 <base>
    1182:	00001717          	auipc	a4,0x1
    1186:	e8f73723          	sd	a5,-370(a4) # 2010 <freep>
    118a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    118c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    1190:	b7c1                	j	1150 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
    1192:	6398                	ld	a4,0(a5)
    1194:	e118                	sd	a4,0(a0)
    1196:	a8a9                	j	11f0 <malloc+0xd6>
  hp->s.size = nu;
    1198:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    119c:	0541                	addi	a0,a0,16
    119e:	efbff0ef          	jal	1098 <free>
  return freep;
    11a2:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    11a6:	c12d                	beqz	a0,1208 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    11a8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    11aa:	4798                	lw	a4,8(a5)
    11ac:	02977263          	bgeu	a4,s1,11d0 <malloc+0xb6>
    if(p == freep)
    11b0:	00093703          	ld	a4,0(s2)
    11b4:	853e                	mv	a0,a5
    11b6:	fef719e3          	bne	a4,a5,11a8 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
    11ba:	8552                	mv	a0,s4
    11bc:	b1bff0ef          	jal	cd6 <sbrk>
  if(p == (char*)-1)
    11c0:	fd551ce3          	bne	a0,s5,1198 <malloc+0x7e>
        return 0;
    11c4:	4501                	li	a0,0
    11c6:	7902                	ld	s2,32(sp)
    11c8:	6a42                	ld	s4,16(sp)
    11ca:	6aa2                	ld	s5,8(sp)
    11cc:	6b02                	ld	s6,0(sp)
    11ce:	a03d                	j	11fc <malloc+0xe2>
    11d0:	7902                	ld	s2,32(sp)
    11d2:	6a42                	ld	s4,16(sp)
    11d4:	6aa2                	ld	s5,8(sp)
    11d6:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
    11d8:	fae48de3          	beq	s1,a4,1192 <malloc+0x78>
        p->s.size -= nunits;
    11dc:	4137073b          	subw	a4,a4,s3
    11e0:	c798                	sw	a4,8(a5)
        p += p->s.size;
    11e2:	02071693          	slli	a3,a4,0x20
    11e6:	01c6d713          	srli	a4,a3,0x1c
    11ea:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    11ec:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    11f0:	00001717          	auipc	a4,0x1
    11f4:	e2a73023          	sd	a0,-480(a4) # 2010 <freep>
      return (void*)(p + 1);
    11f8:	01078513          	addi	a0,a5,16
  }
}
    11fc:	70e2                	ld	ra,56(sp)
    11fe:	7442                	ld	s0,48(sp)
    1200:	74a2                	ld	s1,40(sp)
    1202:	69e2                	ld	s3,24(sp)
    1204:	6121                	addi	sp,sp,64
    1206:	8082                	ret
    1208:	7902                	ld	s2,32(sp)
    120a:	6a42                	ld	s4,16(sp)
    120c:	6aa2                	ld	s5,8(sp)
    120e:	6b02                	ld	s6,0(sp)
    1210:	b7f5                	j	11fc <malloc+0xe2>
