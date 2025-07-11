
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
  if (!*needle) return (char*)haystack;
       6:	0005c783          	lbu	a5,0(a1)
       a:	cf95                	beqz	a5,46 <strstr+0x46>

  for (; *haystack; haystack++) {
       c:	00054783          	lbu	a5,0(a0)
      10:	eb91                	bnez	a5,24 <strstr+0x24>
      n++;
    }
    if (!*n) return (char*)haystack;
  }

  return 0;
      12:	4501                	li	a0,0
      14:	a80d                	j	46 <strstr+0x46>
    if (!*n) return (char*)haystack;
      16:	0007c783          	lbu	a5,0(a5)
      1a:	c795                	beqz	a5,46 <strstr+0x46>
  for (; *haystack; haystack++) {
      1c:	0505                	addi	a0,a0,1
      1e:	00054783          	lbu	a5,0(a0)
      22:	c38d                	beqz	a5,44 <strstr+0x44>
    while (*h && *n && *h == *n) {
      24:	00054703          	lbu	a4,0(a0)
    const char *h = haystack, *n = needle;
      28:	87ae                	mv	a5,a1
      2a:	862a                	mv	a2,a0
    while (*h && *n && *h == *n) {
      2c:	db65                	beqz	a4,1c <strstr+0x1c>
      2e:	0007c683          	lbu	a3,0(a5)
      32:	ca91                	beqz	a3,46 <strstr+0x46>
      34:	fee691e3          	bne	a3,a4,16 <strstr+0x16>
      h++;
      38:	0605                	addi	a2,a2,1
      n++;
      3a:	0785                	addi	a5,a5,1
    while (*h && *n && *h == *n) {
      3c:	00064703          	lbu	a4,0(a2)
      40:	f77d                	bnez	a4,2e <strstr+0x2e>
      42:	bfd1                	j	16 <strstr+0x16>
  return 0;
      44:	4501                	li	a0,0
}
      46:	6422                	ld	s0,8(sp)
      48:	0141                	addi	sp,sp,16
      4a:	8082                	ret

000000000000004c <strcat>:

char *strcat(char *dest, const char *src) {
      4c:	1101                	addi	sp,sp,-32
      4e:	ec06                	sd	ra,24(sp)
      50:	e822                	sd	s0,16(sp)
      52:	e426                	sd	s1,8(sp)
      54:	e04a                	sd	s2,0(sp)
      56:	1000                	addi	s0,sp,32
      58:	892a                	mv	s2,a0
      5a:	84ae                	mv	s1,a1
  char *ptr = dest + strlen(dest);
      5c:	3e5000ef          	jal	c40 <strlen>
      60:	02051793          	slli	a5,a0,0x20
      64:	9381                	srli	a5,a5,0x20
      66:	97ca                	add	a5,a5,s2
  while (*src != '\0') {
      68:	0004c703          	lbu	a4,0(s1)
      6c:	cb01                	beqz	a4,7c <strcat+0x30>
    *ptr++ = *src++;
      6e:	0485                	addi	s1,s1,1
      70:	0785                	addi	a5,a5,1
      72:	fee78fa3          	sb	a4,-1(a5)
  while (*src != '\0') {
      76:	0004c703          	lbu	a4,0(s1)
      7a:	fb75                	bnez	a4,6e <strcat+0x22>
  }
  *ptr = '\0';
      7c:	00078023          	sb	zero,0(a5)
  return dest;
}
      80:	854a                	mv	a0,s2
      82:	60e2                	ld	ra,24(sp)
      84:	6442                	ld	s0,16(sp)
      86:	64a2                	ld	s1,8(sp)
      88:	6902                	ld	s2,0(sp)
      8a:	6105                	addi	sp,sp,32
      8c:	8082                	ret

000000000000008e <getcmd>:
  exit(0);
}

int
getcmd(char *buf, int nbuf)
{
      8e:	1101                	addi	sp,sp,-32
      90:	ec06                	sd	ra,24(sp)
      92:	e822                	sd	s0,16(sp)
      94:	e426                	sd	s1,8(sp)
      96:	e04a                	sd	s2,0(sp)
      98:	1000                	addi	s0,sp,32
      9a:	84aa                	mv	s1,a0
      9c:	892e                	mv	s2,a1
  write(2, "xahra-nastaran$ ", 16);
      9e:	4641                	li	a2,16
      a0:	00001597          	auipc	a1,0x1
      a4:	3a058593          	addi	a1,a1,928 # 1440 <malloc+0x104>
      a8:	4509                	li	a0,2
      aa:	5c7000ef          	jal	e70 <write>
  memset(buf, 0, nbuf);
      ae:	864a                	mv	a2,s2
      b0:	4581                	li	a1,0
      b2:	8526                	mv	a0,s1
      b4:	3b7000ef          	jal	c6a <memset>
  gets(buf, nbuf);
      b8:	85ca                	mv	a1,s2
      ba:	8526                	mv	a0,s1
      bc:	3f5000ef          	jal	cb0 <gets>
  if(buf[0] == 0) // EOF
      c0:	0004c503          	lbu	a0,0(s1)
      c4:	00153513          	seqz	a0,a0
    return -1;
  return 0;
}
      c8:	40a00533          	neg	a0,a0
      cc:	60e2                	ld	ra,24(sp)
      ce:	6442                	ld	s0,16(sp)
      d0:	64a2                	ld	s1,8(sp)
      d2:	6902                	ld	s2,0(sp)
      d4:	6105                	addi	sp,sp,32
      d6:	8082                	ret

00000000000000d8 <panic>:
  exit(0);
}

void
panic(char *s)
{
      d8:	1141                	addi	sp,sp,-16
      da:	e406                	sd	ra,8(sp)
      dc:	e022                	sd	s0,0(sp)
      de:	0800                	addi	s0,sp,16
      e0:	862a                	mv	a2,a0
  fprintf(2, "%s\n", s);
      e2:	00001597          	auipc	a1,0x1
      e6:	37658593          	addi	a1,a1,886 # 1458 <malloc+0x11c>
      ea:	4509                	li	a0,2
      ec:	172010ef          	jal	125e <fprintf>
  exit(1);
      f0:	4505                	li	a0,1
      f2:	55f000ef          	jal	e50 <exit>

00000000000000f6 <fork1>:
}

int
fork1(void)
{
      f6:	1141                	addi	sp,sp,-16
      f8:	e406                	sd	ra,8(sp)
      fa:	e022                	sd	s0,0(sp)
      fc:	0800                	addi	s0,sp,16
  int pid;

  pid = fork();
      fe:	54b000ef          	jal	e48 <fork>
  if(pid == -1)
     102:	57fd                	li	a5,-1
     104:	00f50663          	beq	a0,a5,110 <fork1+0x1a>
    panic("fork");
  return pid;
}
     108:	60a2                	ld	ra,8(sp)
     10a:	6402                	ld	s0,0(sp)
     10c:	0141                	addi	sp,sp,16
     10e:	8082                	ret
    panic("fork");
     110:	00001517          	auipc	a0,0x1
     114:	35050513          	addi	a0,a0,848 # 1460 <malloc+0x124>
     118:	fc1ff0ef          	jal	d8 <panic>

000000000000011c <runcmd>:
{
     11c:	db010113          	addi	sp,sp,-592
     120:	24113423          	sd	ra,584(sp)
     124:	24813023          	sd	s0,576(sp)
     128:	0c80                	addi	s0,sp,592
  if(cmd == 0)
     12a:	c51d                	beqz	a0,158 <runcmd+0x3c>
     12c:	22913c23          	sd	s1,568(sp)
     130:	23213823          	sd	s2,560(sp)
     134:	23413023          	sd	s4,544(sp)
     138:	84aa                	mv	s1,a0
  switch(cmd->type){
     13a:	4118                	lw	a4,0(a0)
     13c:	4795                	li	a5,5
     13e:	02e7ec63          	bltu	a5,a4,176 <runcmd+0x5a>
     142:	00056783          	lwu	a5,0(a0)
     146:	078a                	slli	a5,a5,0x2
     148:	00001717          	auipc	a4,0x1
     14c:	47070713          	addi	a4,a4,1136 # 15b8 <malloc+0x27c>
     150:	97ba                	add	a5,a5,a4
     152:	439c                	lw	a5,0(a5)
     154:	97ba                	add	a5,a5,a4
     156:	8782                	jr	a5
     158:	22913c23          	sd	s1,568(sp)
     15c:	23213823          	sd	s2,560(sp)
     160:	23313423          	sd	s3,552(sp)
     164:	23413023          	sd	s4,544(sp)
     168:	21513c23          	sd	s5,536(sp)
     16c:	21613823          	sd	s6,528(sp)
    exit(1);
     170:	4505                	li	a0,1
     172:	4df000ef          	jal	e50 <exit>
     176:	23313423          	sd	s3,552(sp)
     17a:	21513c23          	sd	s5,536(sp)
     17e:	21613823          	sd	s6,528(sp)
    panic("runcmd");
     182:	00001517          	auipc	a0,0x1
     186:	2e650513          	addi	a0,a0,742 # 1468 <malloc+0x12c>
     18a:	f4fff0ef          	jal	d8 <panic>
        if (ecmd->argv[0] == 0)
     18e:	00853903          	ld	s2,8(a0)
     192:	04090163          	beqz	s2,1d4 <runcmd+0xb8>
        if (strcmp(ecmd->argv[0], "!") == 0) {
     196:	00001597          	auipc	a1,0x1
     19a:	2da58593          	addi	a1,a1,730 # 1470 <malloc+0x134>
     19e:	854a                	mv	a0,s2
     1a0:	275000ef          	jal	c14 <strcmp>
     1a4:	8a2a                	mv	s4,a0
     1a6:	10051c63          	bnez	a0,2be <runcmd+0x1a2>
     1aa:	23313423          	sd	s3,552(sp)
     1ae:	21513c23          	sd	s5,536(sp)
     1b2:	21613823          	sd	s6,528(sp)
          char msg[513] = {0};
     1b6:	20100613          	li	a2,513
     1ba:	4581                	li	a1,0
     1bc:	db040513          	addi	a0,s0,-592
     1c0:	2ab000ef          	jal	c6a <memset>
        if (ecmd->argv[1] == 0) {
     1c4:	689c                	ld	a5,16(s1)
     1c6:	c385                	beqz	a5,1e6 <runcmd+0xca>
     1c8:	04c1                	addi	s1,s1,16
          if (strlen(msg) + strlen(ecmd->argv[i]) + 1 > 512) {
     1ca:	20000a93          	li	s5,512
              strcat(msg, " ");
     1ce:	02000b13          	li	s6,32
     1d2:	a82d                	j	20c <runcmd+0xf0>
     1d4:	23313423          	sd	s3,552(sp)
     1d8:	21513c23          	sd	s5,536(sp)
     1dc:	21613823          	sd	s6,528(sp)
          exit(1);
     1e0:	4505                	li	a0,1
     1e2:	46f000ef          	jal	e50 <exit>
            printf("No message provided\n");
     1e6:	00001517          	auipc	a0,0x1
     1ea:	29250513          	addi	a0,a0,658 # 1478 <malloc+0x13c>
     1ee:	09a010ef          	jal	1288 <printf>
            exit(0);
     1f2:	4501                	li	a0,0
     1f4:	45d000ef          	jal	e50 <exit>
              printf("Message too long\n");
     1f8:	00001517          	auipc	a0,0x1
     1fc:	29850513          	addi	a0,a0,664 # 1490 <malloc+0x154>
     200:	088010ef          	jal	1288 <printf>
              exit(0);
     204:	4501                	li	a0,0
     206:	44b000ef          	jal	e50 <exit>
     20a:	04a1                	addi	s1,s1,8
        for (int i = 1; ecmd->argv[i] != 0; i++) {
     20c:	89a6                	mv	s3,s1
     20e:	609c                	ld	a5,0(s1)
     210:	c7a1                	beqz	a5,258 <runcmd+0x13c>
          if (strlen(msg) + strlen(ecmd->argv[i]) + 1 > 512) {
     212:	db040513          	addi	a0,s0,-592
     216:	22b000ef          	jal	c40 <strlen>
     21a:	0005091b          	sext.w	s2,a0
     21e:	6088                	ld	a0,0(s1)
     220:	221000ef          	jal	c40 <strlen>
     224:	00a9093b          	addw	s2,s2,a0
     228:	2905                	addiw	s2,s2,1
     22a:	fd2ae7e3          	bltu	s5,s2,1f8 <runcmd+0xdc>
            strcat(msg, ecmd->argv[i]);
     22e:	0009b583          	ld	a1,0(s3)
     232:	db040513          	addi	a0,s0,-592
     236:	e17ff0ef          	jal	4c <strcat>
            if (ecmd->argv[i+1] != 0)
     23a:	0089b783          	ld	a5,8(s3)
     23e:	d7f1                	beqz	a5,20a <runcmd+0xee>
              strcat(msg, " ");
     240:	db040513          	addi	a0,s0,-592
     244:	1fd000ef          	jal	c40 <strlen>
     248:	db040793          	addi	a5,s0,-592
     24c:	953e                	add	a0,a0,a5
     24e:	01650023          	sb	s6,0(a0)
     252:	000500a3          	sb	zero,1(a0)
     256:	bf55                	j	20a <runcmd+0xee>
            if (msg[i] == 'o' && msg[i+1] == 's') {
     258:	06f00493          	li	s1,111
                printf("%c", msg[i]);
     25c:	00001917          	auipc	s2,0x1
     260:	26490913          	addi	s2,s2,612 # 14c0 <malloc+0x184>
            if (msg[i] == 'o' && msg[i+1] == 's') {
     264:	07300993          	li	s3,115
     268:	a029                	j	272 <runcmd+0x156>
                printf("%c", msg[i]);
     26a:	854a                	mv	a0,s2
     26c:	01c010ef          	jal	1288 <printf>
                i++;
     270:	2a05                	addiw	s4,s4,1
        for (int i = 0; msg[i] != '\0'; ) {
     272:	fc0a0793          	addi	a5,s4,-64
     276:	97a2                	add	a5,a5,s0
     278:	df07c583          	lbu	a1,-528(a5)
     27c:	c985                	beqz	a1,2ac <runcmd+0x190>
            if (msg[i] == 'o' && msg[i+1] == 's') {
     27e:	fe9596e3          	bne	a1,s1,26a <runcmd+0x14e>
     282:	001a079b          	addiw	a5,s4,1
     286:	fc078793          	addi	a5,a5,-64
     28a:	97a2                	add	a5,a5,s0
     28c:	df07c783          	lbu	a5,-528(a5)
     290:	fd379de3          	bne	a5,s3,26a <runcmd+0x14e>
            printf("\033[34m%s\033[0m" , "os");
     294:	00001597          	auipc	a1,0x1
     298:	21458593          	addi	a1,a1,532 # 14a8 <malloc+0x16c>
     29c:	00001517          	auipc	a0,0x1
     2a0:	21450513          	addi	a0,a0,532 # 14b0 <malloc+0x174>
     2a4:	7e5000ef          	jal	1288 <printf>
                i += 2;
     2a8:	2a09                	addiw	s4,s4,2
     2aa:	b7e1                	j	272 <runcmd+0x156>
            printf("\n");
     2ac:	00001517          	auipc	a0,0x1
     2b0:	1f450513          	addi	a0,a0,500 # 14a0 <malloc+0x164>
     2b4:	7d5000ef          	jal	1288 <printf>
          exit(0);
     2b8:	4501                	li	a0,0
     2ba:	397000ef          	jal	e50 <exit>
        exec(ecmd->argv[0], ecmd->argv);
     2be:	00848593          	addi	a1,s1,8
     2c2:	854a                	mv	a0,s2
     2c4:	3c5000ef          	jal	e88 <exec>
        fprintf(2, "exec %s failed\n", ecmd->argv[0]);
     2c8:	6490                	ld	a2,8(s1)
     2ca:	00001597          	auipc	a1,0x1
     2ce:	1fe58593          	addi	a1,a1,510 # 14c8 <malloc+0x18c>
     2d2:	4509                	li	a0,2
     2d4:	78b000ef          	jal	125e <fprintf>
        break;
     2d8:	a22d                	j	402 <runcmd+0x2e6>
    close(rcmd->fd);
     2da:	5148                	lw	a0,36(a0)
     2dc:	39d000ef          	jal	e78 <close>
    if(open(rcmd->file, rcmd->mode) < 0){
     2e0:	508c                	lw	a1,32(s1)
     2e2:	6888                	ld	a0,16(s1)
     2e4:	3ad000ef          	jal	e90 <open>
     2e8:	00054b63          	bltz	a0,2fe <runcmd+0x1e2>
     2ec:	23313423          	sd	s3,552(sp)
     2f0:	21513c23          	sd	s5,536(sp)
     2f4:	21613823          	sd	s6,528(sp)
    runcmd(rcmd->cmd);
     2f8:	6488                	ld	a0,8(s1)
     2fa:	e23ff0ef          	jal	11c <runcmd>
     2fe:	23313423          	sd	s3,552(sp)
     302:	21513c23          	sd	s5,536(sp)
     306:	21613823          	sd	s6,528(sp)
      fprintf(2, "open %s failed\n", rcmd->file);
     30a:	6890                	ld	a2,16(s1)
     30c:	00001597          	auipc	a1,0x1
     310:	1cc58593          	addi	a1,a1,460 # 14d8 <malloc+0x19c>
     314:	4509                	li	a0,2
     316:	749000ef          	jal	125e <fprintf>
      exit(1);
     31a:	4505                	li	a0,1
     31c:	335000ef          	jal	e50 <exit>
    if(fork1() == 0)
     320:	dd7ff0ef          	jal	f6 <fork1>
     324:	e911                	bnez	a0,338 <runcmd+0x21c>
     326:	23313423          	sd	s3,552(sp)
     32a:	21513c23          	sd	s5,536(sp)
     32e:	21613823          	sd	s6,528(sp)
      runcmd(lcmd->left);
     332:	6488                	ld	a0,8(s1)
     334:	de9ff0ef          	jal	11c <runcmd>
     338:	23313423          	sd	s3,552(sp)
     33c:	21513c23          	sd	s5,536(sp)
     340:	21613823          	sd	s6,528(sp)
    wait(0);
     344:	4501                	li	a0,0
     346:	313000ef          	jal	e58 <wait>
    runcmd(lcmd->right);
     34a:	6888                	ld	a0,16(s1)
     34c:	dd1ff0ef          	jal	11c <runcmd>
    if(pipe(p) < 0)
     350:	fb840513          	addi	a0,s0,-72
     354:	30d000ef          	jal	e60 <pipe>
     358:	02054d63          	bltz	a0,392 <runcmd+0x276>
    if(fork1() == 0){
     35c:	d9bff0ef          	jal	f6 <fork1>
     360:	e529                	bnez	a0,3aa <runcmd+0x28e>
     362:	23313423          	sd	s3,552(sp)
     366:	21513c23          	sd	s5,536(sp)
     36a:	21613823          	sd	s6,528(sp)
      close(1);
     36e:	4505                	li	a0,1
     370:	309000ef          	jal	e78 <close>
      dup(p[1]);
     374:	fbc42503          	lw	a0,-68(s0)
     378:	351000ef          	jal	ec8 <dup>
      close(p[0]);
     37c:	fb842503          	lw	a0,-72(s0)
     380:	2f9000ef          	jal	e78 <close>
      close(p[1]);
     384:	fbc42503          	lw	a0,-68(s0)
     388:	2f1000ef          	jal	e78 <close>
      runcmd(pcmd->left);
     38c:	6488                	ld	a0,8(s1)
     38e:	d8fff0ef          	jal	11c <runcmd>
     392:	23313423          	sd	s3,552(sp)
     396:	21513c23          	sd	s5,536(sp)
     39a:	21613823          	sd	s6,528(sp)
      panic("pipe");
     39e:	00001517          	auipc	a0,0x1
     3a2:	14a50513          	addi	a0,a0,330 # 14e8 <malloc+0x1ac>
     3a6:	d33ff0ef          	jal	d8 <panic>
    if(fork1() == 0){
     3aa:	d4dff0ef          	jal	f6 <fork1>
     3ae:	e905                	bnez	a0,3de <runcmd+0x2c2>
     3b0:	23313423          	sd	s3,552(sp)
     3b4:	21513c23          	sd	s5,536(sp)
     3b8:	21613823          	sd	s6,528(sp)
      close(0);
     3bc:	2bd000ef          	jal	e78 <close>
      dup(p[0]);
     3c0:	fb842503          	lw	a0,-72(s0)
     3c4:	305000ef          	jal	ec8 <dup>
      close(p[0]);
     3c8:	fb842503          	lw	a0,-72(s0)
     3cc:	2ad000ef          	jal	e78 <close>
      close(p[1]);
     3d0:	fbc42503          	lw	a0,-68(s0)
     3d4:	2a5000ef          	jal	e78 <close>
      runcmd(pcmd->right);
     3d8:	6888                	ld	a0,16(s1)
     3da:	d43ff0ef          	jal	11c <runcmd>
    close(p[0]);
     3de:	fb842503          	lw	a0,-72(s0)
     3e2:	297000ef          	jal	e78 <close>
    close(p[1]);
     3e6:	fbc42503          	lw	a0,-68(s0)
     3ea:	28f000ef          	jal	e78 <close>
    wait(0);
     3ee:	4501                	li	a0,0
     3f0:	269000ef          	jal	e58 <wait>
    wait(0);
     3f4:	4501                	li	a0,0
     3f6:	263000ef          	jal	e58 <wait>
    break;
     3fa:	a021                	j	402 <runcmd+0x2e6>
    if(fork1() == 0)
     3fc:	cfbff0ef          	jal	f6 <fork1>
     400:	c911                	beqz	a0,414 <runcmd+0x2f8>
     402:	23313423          	sd	s3,552(sp)
     406:	21513c23          	sd	s5,536(sp)
     40a:	21613823          	sd	s6,528(sp)
  exit(0);
     40e:	4501                	li	a0,0
     410:	241000ef          	jal	e50 <exit>
     414:	23313423          	sd	s3,552(sp)
     418:	21513c23          	sd	s5,536(sp)
     41c:	21613823          	sd	s6,528(sp)
      runcmd(bcmd->cmd);
     420:	6488                	ld	a0,8(s1)
     422:	cfbff0ef          	jal	11c <runcmd>

0000000000000426 <execcmd>:
//PAGEBREAK!
// Constructors

struct cmd*
execcmd(void)
{
     426:	1101                	addi	sp,sp,-32
     428:	ec06                	sd	ra,24(sp)
     42a:	e822                	sd	s0,16(sp)
     42c:	e426                	sd	s1,8(sp)
     42e:	1000                	addi	s0,sp,32
  struct execcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     430:	0a800513          	li	a0,168
     434:	709000ef          	jal	133c <malloc>
     438:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     43a:	0a800613          	li	a2,168
     43e:	4581                	li	a1,0
     440:	02b000ef          	jal	c6a <memset>
  cmd->type = EXEC;
     444:	4785                	li	a5,1
     446:	c09c                	sw	a5,0(s1)
  return (struct cmd*)cmd;
}
     448:	8526                	mv	a0,s1
     44a:	60e2                	ld	ra,24(sp)
     44c:	6442                	ld	s0,16(sp)
     44e:	64a2                	ld	s1,8(sp)
     450:	6105                	addi	sp,sp,32
     452:	8082                	ret

0000000000000454 <redircmd>:

struct cmd*
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
     454:	7139                	addi	sp,sp,-64
     456:	fc06                	sd	ra,56(sp)
     458:	f822                	sd	s0,48(sp)
     45a:	f426                	sd	s1,40(sp)
     45c:	f04a                	sd	s2,32(sp)
     45e:	ec4e                	sd	s3,24(sp)
     460:	e852                	sd	s4,16(sp)
     462:	e456                	sd	s5,8(sp)
     464:	e05a                	sd	s6,0(sp)
     466:	0080                	addi	s0,sp,64
     468:	8b2a                	mv	s6,a0
     46a:	8aae                	mv	s5,a1
     46c:	8a32                	mv	s4,a2
     46e:	89b6                	mv	s3,a3
     470:	893a                	mv	s2,a4
  struct redircmd *cmd;

  cmd = malloc(sizeof(*cmd));
     472:	02800513          	li	a0,40
     476:	6c7000ef          	jal	133c <malloc>
     47a:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     47c:	02800613          	li	a2,40
     480:	4581                	li	a1,0
     482:	7e8000ef          	jal	c6a <memset>
  cmd->type = REDIR;
     486:	4789                	li	a5,2
     488:	c09c                	sw	a5,0(s1)
  cmd->cmd = subcmd;
     48a:	0164b423          	sd	s6,8(s1)
  cmd->file = file;
     48e:	0154b823          	sd	s5,16(s1)
  cmd->efile = efile;
     492:	0144bc23          	sd	s4,24(s1)
  cmd->mode = mode;
     496:	0334a023          	sw	s3,32(s1)
  cmd->fd = fd;
     49a:	0324a223          	sw	s2,36(s1)
  return (struct cmd*)cmd;
}
     49e:	8526                	mv	a0,s1
     4a0:	70e2                	ld	ra,56(sp)
     4a2:	7442                	ld	s0,48(sp)
     4a4:	74a2                	ld	s1,40(sp)
     4a6:	7902                	ld	s2,32(sp)
     4a8:	69e2                	ld	s3,24(sp)
     4aa:	6a42                	ld	s4,16(sp)
     4ac:	6aa2                	ld	s5,8(sp)
     4ae:	6b02                	ld	s6,0(sp)
     4b0:	6121                	addi	sp,sp,64
     4b2:	8082                	ret

00000000000004b4 <pipecmd>:

struct cmd*
pipecmd(struct cmd *left, struct cmd *right)
{
     4b4:	7179                	addi	sp,sp,-48
     4b6:	f406                	sd	ra,40(sp)
     4b8:	f022                	sd	s0,32(sp)
     4ba:	ec26                	sd	s1,24(sp)
     4bc:	e84a                	sd	s2,16(sp)
     4be:	e44e                	sd	s3,8(sp)
     4c0:	1800                	addi	s0,sp,48
     4c2:	89aa                	mv	s3,a0
     4c4:	892e                	mv	s2,a1
  struct pipecmd *cmd;

  cmd = malloc(sizeof(*cmd));
     4c6:	4561                	li	a0,24
     4c8:	675000ef          	jal	133c <malloc>
     4cc:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     4ce:	4661                	li	a2,24
     4d0:	4581                	li	a1,0
     4d2:	798000ef          	jal	c6a <memset>
  cmd->type = PIPE;
     4d6:	478d                	li	a5,3
     4d8:	c09c                	sw	a5,0(s1)
  cmd->left = left;
     4da:	0134b423          	sd	s3,8(s1)
  cmd->right = right;
     4de:	0124b823          	sd	s2,16(s1)
  return (struct cmd*)cmd;
}
     4e2:	8526                	mv	a0,s1
     4e4:	70a2                	ld	ra,40(sp)
     4e6:	7402                	ld	s0,32(sp)
     4e8:	64e2                	ld	s1,24(sp)
     4ea:	6942                	ld	s2,16(sp)
     4ec:	69a2                	ld	s3,8(sp)
     4ee:	6145                	addi	sp,sp,48
     4f0:	8082                	ret

00000000000004f2 <listcmd>:

struct cmd*
listcmd(struct cmd *left, struct cmd *right)
{
     4f2:	7179                	addi	sp,sp,-48
     4f4:	f406                	sd	ra,40(sp)
     4f6:	f022                	sd	s0,32(sp)
     4f8:	ec26                	sd	s1,24(sp)
     4fa:	e84a                	sd	s2,16(sp)
     4fc:	e44e                	sd	s3,8(sp)
     4fe:	1800                	addi	s0,sp,48
     500:	89aa                	mv	s3,a0
     502:	892e                	mv	s2,a1
  struct listcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     504:	4561                	li	a0,24
     506:	637000ef          	jal	133c <malloc>
     50a:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     50c:	4661                	li	a2,24
     50e:	4581                	li	a1,0
     510:	75a000ef          	jal	c6a <memset>
  cmd->type = LIST;
     514:	4791                	li	a5,4
     516:	c09c                	sw	a5,0(s1)
  cmd->left = left;
     518:	0134b423          	sd	s3,8(s1)
  cmd->right = right;
     51c:	0124b823          	sd	s2,16(s1)
  return (struct cmd*)cmd;
}
     520:	8526                	mv	a0,s1
     522:	70a2                	ld	ra,40(sp)
     524:	7402                	ld	s0,32(sp)
     526:	64e2                	ld	s1,24(sp)
     528:	6942                	ld	s2,16(sp)
     52a:	69a2                	ld	s3,8(sp)
     52c:	6145                	addi	sp,sp,48
     52e:	8082                	ret

0000000000000530 <backcmd>:

struct cmd*
backcmd(struct cmd *subcmd)
{
     530:	1101                	addi	sp,sp,-32
     532:	ec06                	sd	ra,24(sp)
     534:	e822                	sd	s0,16(sp)
     536:	e426                	sd	s1,8(sp)
     538:	e04a                	sd	s2,0(sp)
     53a:	1000                	addi	s0,sp,32
     53c:	892a                	mv	s2,a0
  struct backcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     53e:	4541                	li	a0,16
     540:	5fd000ef          	jal	133c <malloc>
     544:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     546:	4641                	li	a2,16
     548:	4581                	li	a1,0
     54a:	720000ef          	jal	c6a <memset>
  cmd->type = BACK;
     54e:	4795                	li	a5,5
     550:	c09c                	sw	a5,0(s1)
  cmd->cmd = subcmd;
     552:	0124b423          	sd	s2,8(s1)
  return (struct cmd*)cmd;
}
     556:	8526                	mv	a0,s1
     558:	60e2                	ld	ra,24(sp)
     55a:	6442                	ld	s0,16(sp)
     55c:	64a2                	ld	s1,8(sp)
     55e:	6902                	ld	s2,0(sp)
     560:	6105                	addi	sp,sp,32
     562:	8082                	ret

0000000000000564 <gettoken>:
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int
gettoken(char **ps, char *es, char **q, char **eq)
{
     564:	7139                	addi	sp,sp,-64
     566:	fc06                	sd	ra,56(sp)
     568:	f822                	sd	s0,48(sp)
     56a:	f426                	sd	s1,40(sp)
     56c:	f04a                	sd	s2,32(sp)
     56e:	ec4e                	sd	s3,24(sp)
     570:	e852                	sd	s4,16(sp)
     572:	e456                	sd	s5,8(sp)
     574:	e05a                	sd	s6,0(sp)
     576:	0080                	addi	s0,sp,64
     578:	8a2a                	mv	s4,a0
     57a:	892e                	mv	s2,a1
     57c:	8ab2                	mv	s5,a2
     57e:	8b36                	mv	s6,a3
  char *s;
  int ret;

  s = *ps;
     580:	6104                	ld	s1,0(a0)
  while(s < es && strchr(whitespace, *s))
     582:	00002997          	auipc	s3,0x2
     586:	a8698993          	addi	s3,s3,-1402 # 2008 <whitespace>
     58a:	00b4fc63          	bgeu	s1,a1,5a2 <gettoken+0x3e>
     58e:	0004c583          	lbu	a1,0(s1)
     592:	854e                	mv	a0,s3
     594:	6f8000ef          	jal	c8c <strchr>
     598:	c509                	beqz	a0,5a2 <gettoken+0x3e>
    s++;
     59a:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     59c:	fe9919e3          	bne	s2,s1,58e <gettoken+0x2a>
     5a0:	84ca                	mv	s1,s2
  if(q)
     5a2:	000a8463          	beqz	s5,5aa <gettoken+0x46>
    *q = s;
     5a6:	009ab023          	sd	s1,0(s5)
  ret = *s;
     5aa:	0004c783          	lbu	a5,0(s1)
     5ae:	00078a9b          	sext.w	s5,a5
  switch(*s){
     5b2:	03c00713          	li	a4,60
     5b6:	06f76463          	bltu	a4,a5,61e <gettoken+0xba>
     5ba:	03a00713          	li	a4,58
     5be:	00f76e63          	bltu	a4,a5,5da <gettoken+0x76>
     5c2:	cf89                	beqz	a5,5dc <gettoken+0x78>
     5c4:	02600713          	li	a4,38
     5c8:	00e78963          	beq	a5,a4,5da <gettoken+0x76>
     5cc:	fd87879b          	addiw	a5,a5,-40
     5d0:	0ff7f793          	zext.b	a5,a5
     5d4:	4705                	li	a4,1
     5d6:	06f76b63          	bltu	a4,a5,64c <gettoken+0xe8>
  case '(':
  case ')':
  case ';':
  case '&':
  case '<':
    s++;
     5da:	0485                	addi	s1,s1,1
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
      s++;
    break;
  }
  if(eq)
     5dc:	000b0463          	beqz	s6,5e4 <gettoken+0x80>
    *eq = s;
     5e0:	009b3023          	sd	s1,0(s6)

  while(s < es && strchr(whitespace, *s))
     5e4:	00002997          	auipc	s3,0x2
     5e8:	a2498993          	addi	s3,s3,-1500 # 2008 <whitespace>
     5ec:	0124fc63          	bgeu	s1,s2,604 <gettoken+0xa0>
     5f0:	0004c583          	lbu	a1,0(s1)
     5f4:	854e                	mv	a0,s3
     5f6:	696000ef          	jal	c8c <strchr>
     5fa:	c509                	beqz	a0,604 <gettoken+0xa0>
    s++;
     5fc:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     5fe:	fe9919e3          	bne	s2,s1,5f0 <gettoken+0x8c>
     602:	84ca                	mv	s1,s2
  *ps = s;
     604:	009a3023          	sd	s1,0(s4)
  return ret;
}
     608:	8556                	mv	a0,s5
     60a:	70e2                	ld	ra,56(sp)
     60c:	7442                	ld	s0,48(sp)
     60e:	74a2                	ld	s1,40(sp)
     610:	7902                	ld	s2,32(sp)
     612:	69e2                	ld	s3,24(sp)
     614:	6a42                	ld	s4,16(sp)
     616:	6aa2                	ld	s5,8(sp)
     618:	6b02                	ld	s6,0(sp)
     61a:	6121                	addi	sp,sp,64
     61c:	8082                	ret
  switch(*s){
     61e:	03e00713          	li	a4,62
     622:	02e79163          	bne	a5,a4,644 <gettoken+0xe0>
    s++;
     626:	00148693          	addi	a3,s1,1
    if(*s == '>'){
     62a:	0014c703          	lbu	a4,1(s1)
     62e:	03e00793          	li	a5,62
      s++;
     632:	0489                	addi	s1,s1,2
      ret = '+';
     634:	02b00a93          	li	s5,43
    if(*s == '>'){
     638:	faf702e3          	beq	a4,a5,5dc <gettoken+0x78>
    s++;
     63c:	84b6                	mv	s1,a3
  ret = *s;
     63e:	03e00a93          	li	s5,62
     642:	bf69                	j	5dc <gettoken+0x78>
  switch(*s){
     644:	07c00713          	li	a4,124
     648:	f8e789e3          	beq	a5,a4,5da <gettoken+0x76>
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     64c:	00002997          	auipc	s3,0x2
     650:	9bc98993          	addi	s3,s3,-1604 # 2008 <whitespace>
     654:	00002a97          	auipc	s5,0x2
     658:	9aca8a93          	addi	s5,s5,-1620 # 2000 <symbols>
     65c:	0324fd63          	bgeu	s1,s2,696 <gettoken+0x132>
     660:	0004c583          	lbu	a1,0(s1)
     664:	854e                	mv	a0,s3
     666:	626000ef          	jal	c8c <strchr>
     66a:	e11d                	bnez	a0,690 <gettoken+0x12c>
     66c:	0004c583          	lbu	a1,0(s1)
     670:	8556                	mv	a0,s5
     672:	61a000ef          	jal	c8c <strchr>
     676:	e911                	bnez	a0,68a <gettoken+0x126>
      s++;
     678:	0485                	addi	s1,s1,1
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     67a:	fe9913e3          	bne	s2,s1,660 <gettoken+0xfc>
  if(eq)
     67e:	84ca                	mv	s1,s2
    ret = 'a';
     680:	06100a93          	li	s5,97
  if(eq)
     684:	f40b1ee3          	bnez	s6,5e0 <gettoken+0x7c>
     688:	bfb5                	j	604 <gettoken+0xa0>
    ret = 'a';
     68a:	06100a93          	li	s5,97
     68e:	b7b9                	j	5dc <gettoken+0x78>
     690:	06100a93          	li	s5,97
     694:	b7a1                	j	5dc <gettoken+0x78>
     696:	06100a93          	li	s5,97
  if(eq)
     69a:	f40b13e3          	bnez	s6,5e0 <gettoken+0x7c>
     69e:	b79d                	j	604 <gettoken+0xa0>

00000000000006a0 <peek>:

int
peek(char **ps, char *es, char *toks)
{
     6a0:	7139                	addi	sp,sp,-64
     6a2:	fc06                	sd	ra,56(sp)
     6a4:	f822                	sd	s0,48(sp)
     6a6:	f426                	sd	s1,40(sp)
     6a8:	f04a                	sd	s2,32(sp)
     6aa:	ec4e                	sd	s3,24(sp)
     6ac:	e852                	sd	s4,16(sp)
     6ae:	e456                	sd	s5,8(sp)
     6b0:	0080                	addi	s0,sp,64
     6b2:	8a2a                	mv	s4,a0
     6b4:	892e                	mv	s2,a1
     6b6:	8ab2                	mv	s5,a2
  char *s;

  s = *ps;
     6b8:	6104                	ld	s1,0(a0)
  while(s < es && strchr(whitespace, *s))
     6ba:	00002997          	auipc	s3,0x2
     6be:	94e98993          	addi	s3,s3,-1714 # 2008 <whitespace>
     6c2:	00b4fc63          	bgeu	s1,a1,6da <peek+0x3a>
     6c6:	0004c583          	lbu	a1,0(s1)
     6ca:	854e                	mv	a0,s3
     6cc:	5c0000ef          	jal	c8c <strchr>
     6d0:	c509                	beqz	a0,6da <peek+0x3a>
    s++;
     6d2:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     6d4:	fe9919e3          	bne	s2,s1,6c6 <peek+0x26>
     6d8:	84ca                	mv	s1,s2
  *ps = s;
     6da:	009a3023          	sd	s1,0(s4)
  return *s && strchr(toks, *s);
     6de:	0004c583          	lbu	a1,0(s1)
     6e2:	4501                	li	a0,0
     6e4:	e991                	bnez	a1,6f8 <peek+0x58>
}
     6e6:	70e2                	ld	ra,56(sp)
     6e8:	7442                	ld	s0,48(sp)
     6ea:	74a2                	ld	s1,40(sp)
     6ec:	7902                	ld	s2,32(sp)
     6ee:	69e2                	ld	s3,24(sp)
     6f0:	6a42                	ld	s4,16(sp)
     6f2:	6aa2                	ld	s5,8(sp)
     6f4:	6121                	addi	sp,sp,64
     6f6:	8082                	ret
  return *s && strchr(toks, *s);
     6f8:	8556                	mv	a0,s5
     6fa:	592000ef          	jal	c8c <strchr>
     6fe:	00a03533          	snez	a0,a0
     702:	b7d5                	j	6e6 <peek+0x46>

0000000000000704 <parseredirs>:
  return cmd;
}

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     704:	711d                	addi	sp,sp,-96
     706:	ec86                	sd	ra,88(sp)
     708:	e8a2                	sd	s0,80(sp)
     70a:	e4a6                	sd	s1,72(sp)
     70c:	e0ca                	sd	s2,64(sp)
     70e:	fc4e                	sd	s3,56(sp)
     710:	f852                	sd	s4,48(sp)
     712:	f456                	sd	s5,40(sp)
     714:	f05a                	sd	s6,32(sp)
     716:	ec5e                	sd	s7,24(sp)
     718:	1080                	addi	s0,sp,96
     71a:	8a2a                	mv	s4,a0
     71c:	89ae                	mv	s3,a1
     71e:	8932                	mv	s2,a2
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     720:	00001a97          	auipc	s5,0x1
     724:	df0a8a93          	addi	s5,s5,-528 # 1510 <malloc+0x1d4>
    tok = gettoken(ps, es, 0, 0);
    if(gettoken(ps, es, &q, &eq) != 'a')
     728:	06100b13          	li	s6,97
      panic("missing file for redirection");
    switch(tok){
     72c:	03c00b93          	li	s7,60
  while(peek(ps, es, "<>")){
     730:	a00d                	j	752 <parseredirs+0x4e>
      panic("missing file for redirection");
     732:	00001517          	auipc	a0,0x1
     736:	dbe50513          	addi	a0,a0,-578 # 14f0 <malloc+0x1b4>
     73a:	99fff0ef          	jal	d8 <panic>
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     73e:	4701                	li	a4,0
     740:	4681                	li	a3,0
     742:	fa043603          	ld	a2,-96(s0)
     746:	fa843583          	ld	a1,-88(s0)
     74a:	8552                	mv	a0,s4
     74c:	d09ff0ef          	jal	454 <redircmd>
     750:	8a2a                	mv	s4,a0
  while(peek(ps, es, "<>")){
     752:	8656                	mv	a2,s5
     754:	85ca                	mv	a1,s2
     756:	854e                	mv	a0,s3
     758:	f49ff0ef          	jal	6a0 <peek>
     75c:	c525                	beqz	a0,7c4 <parseredirs+0xc0>
    tok = gettoken(ps, es, 0, 0);
     75e:	4681                	li	a3,0
     760:	4601                	li	a2,0
     762:	85ca                	mv	a1,s2
     764:	854e                	mv	a0,s3
     766:	dffff0ef          	jal	564 <gettoken>
     76a:	84aa                	mv	s1,a0
    if(gettoken(ps, es, &q, &eq) != 'a')
     76c:	fa040693          	addi	a3,s0,-96
     770:	fa840613          	addi	a2,s0,-88
     774:	85ca                	mv	a1,s2
     776:	854e                	mv	a0,s3
     778:	dedff0ef          	jal	564 <gettoken>
     77c:	fb651be3          	bne	a0,s6,732 <parseredirs+0x2e>
    switch(tok){
     780:	fb748fe3          	beq	s1,s7,73e <parseredirs+0x3a>
     784:	03e00793          	li	a5,62
     788:	02f48263          	beq	s1,a5,7ac <parseredirs+0xa8>
     78c:	02b00793          	li	a5,43
     790:	fcf491e3          	bne	s1,a5,752 <parseredirs+0x4e>
      break;
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE|O_TRUNC, 1);
      break;
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     794:	4705                	li	a4,1
     796:	20100693          	li	a3,513
     79a:	fa043603          	ld	a2,-96(s0)
     79e:	fa843583          	ld	a1,-88(s0)
     7a2:	8552                	mv	a0,s4
     7a4:	cb1ff0ef          	jal	454 <redircmd>
     7a8:	8a2a                	mv	s4,a0
      break;
     7aa:	b765                	j	752 <parseredirs+0x4e>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE|O_TRUNC, 1);
     7ac:	4705                	li	a4,1
     7ae:	60100693          	li	a3,1537
     7b2:	fa043603          	ld	a2,-96(s0)
     7b6:	fa843583          	ld	a1,-88(s0)
     7ba:	8552                	mv	a0,s4
     7bc:	c99ff0ef          	jal	454 <redircmd>
     7c0:	8a2a                	mv	s4,a0
      break;
     7c2:	bf41                	j	752 <parseredirs+0x4e>
    }
  }
  return cmd;
}
     7c4:	8552                	mv	a0,s4
     7c6:	60e6                	ld	ra,88(sp)
     7c8:	6446                	ld	s0,80(sp)
     7ca:	64a6                	ld	s1,72(sp)
     7cc:	6906                	ld	s2,64(sp)
     7ce:	79e2                	ld	s3,56(sp)
     7d0:	7a42                	ld	s4,48(sp)
     7d2:	7aa2                	ld	s5,40(sp)
     7d4:	7b02                	ld	s6,32(sp)
     7d6:	6be2                	ld	s7,24(sp)
     7d8:	6125                	addi	sp,sp,96
     7da:	8082                	ret

00000000000007dc <parseexec>:
  return cmd;
}

struct cmd*
parseexec(char **ps, char *es)
{
     7dc:	7159                	addi	sp,sp,-112
     7de:	f486                	sd	ra,104(sp)
     7e0:	f0a2                	sd	s0,96(sp)
     7e2:	eca6                	sd	s1,88(sp)
     7e4:	e0d2                	sd	s4,64(sp)
     7e6:	fc56                	sd	s5,56(sp)
     7e8:	1880                	addi	s0,sp,112
     7ea:	8a2a                	mv	s4,a0
     7ec:	8aae                	mv	s5,a1
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;

  if(peek(ps, es, "("))
     7ee:	00001617          	auipc	a2,0x1
     7f2:	d2a60613          	addi	a2,a2,-726 # 1518 <malloc+0x1dc>
     7f6:	eabff0ef          	jal	6a0 <peek>
     7fa:	e915                	bnez	a0,82e <parseexec+0x52>
     7fc:	e8ca                	sd	s2,80(sp)
     7fe:	e4ce                	sd	s3,72(sp)
     800:	f85a                	sd	s6,48(sp)
     802:	f45e                	sd	s7,40(sp)
     804:	f062                	sd	s8,32(sp)
     806:	ec66                	sd	s9,24(sp)
     808:	89aa                	mv	s3,a0
    return parseblock(ps, es);

  ret = execcmd();
     80a:	c1dff0ef          	jal	426 <execcmd>
     80e:	8c2a                	mv	s8,a0
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
     810:	8656                	mv	a2,s5
     812:	85d2                	mv	a1,s4
     814:	ef1ff0ef          	jal	704 <parseredirs>
     818:	84aa                	mv	s1,a0
  while(!peek(ps, es, "|)&;")){
     81a:	008c0913          	addi	s2,s8,8
     81e:	00001b17          	auipc	s6,0x1
     822:	d1ab0b13          	addi	s6,s6,-742 # 1538 <malloc+0x1fc>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
      break;
    if(tok != 'a')
     826:	06100c93          	li	s9,97
      panic("syntax");
    cmd->argv[argc] = q;
    cmd->eargv[argc] = eq;
    argc++;
    if(argc >= MAXARGS)
     82a:	4ba9                	li	s7,10
  while(!peek(ps, es, "|)&;")){
     82c:	a815                	j	860 <parseexec+0x84>
    return parseblock(ps, es);
     82e:	85d6                	mv	a1,s5
     830:	8552                	mv	a0,s4
     832:	170000ef          	jal	9a2 <parseblock>
     836:	84aa                	mv	s1,a0
    ret = parseredirs(ret, ps, es);
  }
  cmd->argv[argc] = 0;
  cmd->eargv[argc] = 0;
  return ret;
}
     838:	8526                	mv	a0,s1
     83a:	70a6                	ld	ra,104(sp)
     83c:	7406                	ld	s0,96(sp)
     83e:	64e6                	ld	s1,88(sp)
     840:	6a06                	ld	s4,64(sp)
     842:	7ae2                	ld	s5,56(sp)
     844:	6165                	addi	sp,sp,112
     846:	8082                	ret
      panic("syntax");
     848:	00001517          	auipc	a0,0x1
     84c:	cd850513          	addi	a0,a0,-808 # 1520 <malloc+0x1e4>
     850:	889ff0ef          	jal	d8 <panic>
    ret = parseredirs(ret, ps, es);
     854:	8656                	mv	a2,s5
     856:	85d2                	mv	a1,s4
     858:	8526                	mv	a0,s1
     85a:	eabff0ef          	jal	704 <parseredirs>
     85e:	84aa                	mv	s1,a0
  while(!peek(ps, es, "|)&;")){
     860:	865a                	mv	a2,s6
     862:	85d6                	mv	a1,s5
     864:	8552                	mv	a0,s4
     866:	e3bff0ef          	jal	6a0 <peek>
     86a:	ed15                	bnez	a0,8a6 <parseexec+0xca>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     86c:	f9040693          	addi	a3,s0,-112
     870:	f9840613          	addi	a2,s0,-104
     874:	85d6                	mv	a1,s5
     876:	8552                	mv	a0,s4
     878:	cedff0ef          	jal	564 <gettoken>
     87c:	c50d                	beqz	a0,8a6 <parseexec+0xca>
    if(tok != 'a')
     87e:	fd9515e3          	bne	a0,s9,848 <parseexec+0x6c>
    cmd->argv[argc] = q;
     882:	f9843783          	ld	a5,-104(s0)
     886:	00f93023          	sd	a5,0(s2)
    cmd->eargv[argc] = eq;
     88a:	f9043783          	ld	a5,-112(s0)
     88e:	04f93823          	sd	a5,80(s2)
    argc++;
     892:	2985                	addiw	s3,s3,1
    if(argc >= MAXARGS)
     894:	0921                	addi	s2,s2,8
     896:	fb799fe3          	bne	s3,s7,854 <parseexec+0x78>
      panic("too many args");
     89a:	00001517          	auipc	a0,0x1
     89e:	c8e50513          	addi	a0,a0,-882 # 1528 <malloc+0x1ec>
     8a2:	837ff0ef          	jal	d8 <panic>
  cmd->argv[argc] = 0;
     8a6:	098e                	slli	s3,s3,0x3
     8a8:	9c4e                	add	s8,s8,s3
     8aa:	000c3423          	sd	zero,8(s8)
  cmd->eargv[argc] = 0;
     8ae:	040c3c23          	sd	zero,88(s8)
     8b2:	6946                	ld	s2,80(sp)
     8b4:	69a6                	ld	s3,72(sp)
     8b6:	7b42                	ld	s6,48(sp)
     8b8:	7ba2                	ld	s7,40(sp)
     8ba:	7c02                	ld	s8,32(sp)
     8bc:	6ce2                	ld	s9,24(sp)
  return ret;
     8be:	bfad                	j	838 <parseexec+0x5c>

00000000000008c0 <parsepipe>:
{
     8c0:	7179                	addi	sp,sp,-48
     8c2:	f406                	sd	ra,40(sp)
     8c4:	f022                	sd	s0,32(sp)
     8c6:	ec26                	sd	s1,24(sp)
     8c8:	e84a                	sd	s2,16(sp)
     8ca:	e44e                	sd	s3,8(sp)
     8cc:	1800                	addi	s0,sp,48
     8ce:	892a                	mv	s2,a0
     8d0:	89ae                	mv	s3,a1
  cmd = parseexec(ps, es);
     8d2:	f0bff0ef          	jal	7dc <parseexec>
     8d6:	84aa                	mv	s1,a0
  if(peek(ps, es, "|")){
     8d8:	00001617          	auipc	a2,0x1
     8dc:	c6860613          	addi	a2,a2,-920 # 1540 <malloc+0x204>
     8e0:	85ce                	mv	a1,s3
     8e2:	854a                	mv	a0,s2
     8e4:	dbdff0ef          	jal	6a0 <peek>
     8e8:	e909                	bnez	a0,8fa <parsepipe+0x3a>
}
     8ea:	8526                	mv	a0,s1
     8ec:	70a2                	ld	ra,40(sp)
     8ee:	7402                	ld	s0,32(sp)
     8f0:	64e2                	ld	s1,24(sp)
     8f2:	6942                	ld	s2,16(sp)
     8f4:	69a2                	ld	s3,8(sp)
     8f6:	6145                	addi	sp,sp,48
     8f8:	8082                	ret
    gettoken(ps, es, 0, 0);
     8fa:	4681                	li	a3,0
     8fc:	4601                	li	a2,0
     8fe:	85ce                	mv	a1,s3
     900:	854a                	mv	a0,s2
     902:	c63ff0ef          	jal	564 <gettoken>
    cmd = pipecmd(cmd, parsepipe(ps, es));
     906:	85ce                	mv	a1,s3
     908:	854a                	mv	a0,s2
     90a:	fb7ff0ef          	jal	8c0 <parsepipe>
     90e:	85aa                	mv	a1,a0
     910:	8526                	mv	a0,s1
     912:	ba3ff0ef          	jal	4b4 <pipecmd>
     916:	84aa                	mv	s1,a0
  return cmd;
     918:	bfc9                	j	8ea <parsepipe+0x2a>

000000000000091a <parseline>:
{
     91a:	7179                	addi	sp,sp,-48
     91c:	f406                	sd	ra,40(sp)
     91e:	f022                	sd	s0,32(sp)
     920:	ec26                	sd	s1,24(sp)
     922:	e84a                	sd	s2,16(sp)
     924:	e44e                	sd	s3,8(sp)
     926:	e052                	sd	s4,0(sp)
     928:	1800                	addi	s0,sp,48
     92a:	892a                	mv	s2,a0
     92c:	89ae                	mv	s3,a1
  cmd = parsepipe(ps, es);
     92e:	f93ff0ef          	jal	8c0 <parsepipe>
     932:	84aa                	mv	s1,a0
  while(peek(ps, es, "&")){
     934:	00001a17          	auipc	s4,0x1
     938:	c14a0a13          	addi	s4,s4,-1004 # 1548 <malloc+0x20c>
     93c:	a819                	j	952 <parseline+0x38>
    gettoken(ps, es, 0, 0);
     93e:	4681                	li	a3,0
     940:	4601                	li	a2,0
     942:	85ce                	mv	a1,s3
     944:	854a                	mv	a0,s2
     946:	c1fff0ef          	jal	564 <gettoken>
    cmd = backcmd(cmd);
     94a:	8526                	mv	a0,s1
     94c:	be5ff0ef          	jal	530 <backcmd>
     950:	84aa                	mv	s1,a0
  while(peek(ps, es, "&")){
     952:	8652                	mv	a2,s4
     954:	85ce                	mv	a1,s3
     956:	854a                	mv	a0,s2
     958:	d49ff0ef          	jal	6a0 <peek>
     95c:	f16d                	bnez	a0,93e <parseline+0x24>
  if(peek(ps, es, ";")){
     95e:	00001617          	auipc	a2,0x1
     962:	bf260613          	addi	a2,a2,-1038 # 1550 <malloc+0x214>
     966:	85ce                	mv	a1,s3
     968:	854a                	mv	a0,s2
     96a:	d37ff0ef          	jal	6a0 <peek>
     96e:	e911                	bnez	a0,982 <parseline+0x68>
}
     970:	8526                	mv	a0,s1
     972:	70a2                	ld	ra,40(sp)
     974:	7402                	ld	s0,32(sp)
     976:	64e2                	ld	s1,24(sp)
     978:	6942                	ld	s2,16(sp)
     97a:	69a2                	ld	s3,8(sp)
     97c:	6a02                	ld	s4,0(sp)
     97e:	6145                	addi	sp,sp,48
     980:	8082                	ret
    gettoken(ps, es, 0, 0);
     982:	4681                	li	a3,0
     984:	4601                	li	a2,0
     986:	85ce                	mv	a1,s3
     988:	854a                	mv	a0,s2
     98a:	bdbff0ef          	jal	564 <gettoken>
    cmd = listcmd(cmd, parseline(ps, es));
     98e:	85ce                	mv	a1,s3
     990:	854a                	mv	a0,s2
     992:	f89ff0ef          	jal	91a <parseline>
     996:	85aa                	mv	a1,a0
     998:	8526                	mv	a0,s1
     99a:	b59ff0ef          	jal	4f2 <listcmd>
     99e:	84aa                	mv	s1,a0
  return cmd;
     9a0:	bfc1                	j	970 <parseline+0x56>

00000000000009a2 <parseblock>:
{
     9a2:	7179                	addi	sp,sp,-48
     9a4:	f406                	sd	ra,40(sp)
     9a6:	f022                	sd	s0,32(sp)
     9a8:	ec26                	sd	s1,24(sp)
     9aa:	e84a                	sd	s2,16(sp)
     9ac:	e44e                	sd	s3,8(sp)
     9ae:	1800                	addi	s0,sp,48
     9b0:	84aa                	mv	s1,a0
     9b2:	892e                	mv	s2,a1
  if(!peek(ps, es, "("))
     9b4:	00001617          	auipc	a2,0x1
     9b8:	b6460613          	addi	a2,a2,-1180 # 1518 <malloc+0x1dc>
     9bc:	ce5ff0ef          	jal	6a0 <peek>
     9c0:	c539                	beqz	a0,a0e <parseblock+0x6c>
  gettoken(ps, es, 0, 0);
     9c2:	4681                	li	a3,0
     9c4:	4601                	li	a2,0
     9c6:	85ca                	mv	a1,s2
     9c8:	8526                	mv	a0,s1
     9ca:	b9bff0ef          	jal	564 <gettoken>
  cmd = parseline(ps, es);
     9ce:	85ca                	mv	a1,s2
     9d0:	8526                	mv	a0,s1
     9d2:	f49ff0ef          	jal	91a <parseline>
     9d6:	89aa                	mv	s3,a0
  if(!peek(ps, es, ")"))
     9d8:	00001617          	auipc	a2,0x1
     9dc:	b9060613          	addi	a2,a2,-1136 # 1568 <malloc+0x22c>
     9e0:	85ca                	mv	a1,s2
     9e2:	8526                	mv	a0,s1
     9e4:	cbdff0ef          	jal	6a0 <peek>
     9e8:	c90d                	beqz	a0,a1a <parseblock+0x78>
  gettoken(ps, es, 0, 0);
     9ea:	4681                	li	a3,0
     9ec:	4601                	li	a2,0
     9ee:	85ca                	mv	a1,s2
     9f0:	8526                	mv	a0,s1
     9f2:	b73ff0ef          	jal	564 <gettoken>
  cmd = parseredirs(cmd, ps, es);
     9f6:	864a                	mv	a2,s2
     9f8:	85a6                	mv	a1,s1
     9fa:	854e                	mv	a0,s3
     9fc:	d09ff0ef          	jal	704 <parseredirs>
}
     a00:	70a2                	ld	ra,40(sp)
     a02:	7402                	ld	s0,32(sp)
     a04:	64e2                	ld	s1,24(sp)
     a06:	6942                	ld	s2,16(sp)
     a08:	69a2                	ld	s3,8(sp)
     a0a:	6145                	addi	sp,sp,48
     a0c:	8082                	ret
    panic("parseblock");
     a0e:	00001517          	auipc	a0,0x1
     a12:	b4a50513          	addi	a0,a0,-1206 # 1558 <malloc+0x21c>
     a16:	ec2ff0ef          	jal	d8 <panic>
    panic("syntax - missing )");
     a1a:	00001517          	auipc	a0,0x1
     a1e:	b5650513          	addi	a0,a0,-1194 # 1570 <malloc+0x234>
     a22:	eb6ff0ef          	jal	d8 <panic>

0000000000000a26 <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
     a26:	1101                	addi	sp,sp,-32
     a28:	ec06                	sd	ra,24(sp)
     a2a:	e822                	sd	s0,16(sp)
     a2c:	e426                	sd	s1,8(sp)
     a2e:	1000                	addi	s0,sp,32
     a30:	84aa                	mv	s1,a0
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
     a32:	c131                	beqz	a0,a76 <nulterminate+0x50>
    return 0;

  switch(cmd->type){
     a34:	4118                	lw	a4,0(a0)
     a36:	4795                	li	a5,5
     a38:	02e7ef63          	bltu	a5,a4,a76 <nulterminate+0x50>
     a3c:	00056783          	lwu	a5,0(a0)
     a40:	078a                	slli	a5,a5,0x2
     a42:	00001717          	auipc	a4,0x1
     a46:	b8e70713          	addi	a4,a4,-1138 # 15d0 <malloc+0x294>
     a4a:	97ba                	add	a5,a5,a4
     a4c:	439c                	lw	a5,0(a5)
     a4e:	97ba                	add	a5,a5,a4
     a50:	8782                	jr	a5
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
     a52:	651c                	ld	a5,8(a0)
     a54:	c38d                	beqz	a5,a76 <nulterminate+0x50>
     a56:	01050793          	addi	a5,a0,16
      *ecmd->eargv[i] = 0;
     a5a:	67b8                	ld	a4,72(a5)
     a5c:	00070023          	sb	zero,0(a4)
    for(i=0; ecmd->argv[i]; i++)
     a60:	07a1                	addi	a5,a5,8
     a62:	ff87b703          	ld	a4,-8(a5)
     a66:	fb75                	bnez	a4,a5a <nulterminate+0x34>
     a68:	a039                	j	a76 <nulterminate+0x50>
    break;

  case REDIR:
    rcmd = (struct redircmd*)cmd;
    nulterminate(rcmd->cmd);
     a6a:	6508                	ld	a0,8(a0)
     a6c:	fbbff0ef          	jal	a26 <nulterminate>
    *rcmd->efile = 0;
     a70:	6c9c                	ld	a5,24(s1)
     a72:	00078023          	sb	zero,0(a5)
    bcmd = (struct backcmd*)cmd;
    nulterminate(bcmd->cmd);
    break;
  }
  return cmd;
}
     a76:	8526                	mv	a0,s1
     a78:	60e2                	ld	ra,24(sp)
     a7a:	6442                	ld	s0,16(sp)
     a7c:	64a2                	ld	s1,8(sp)
     a7e:	6105                	addi	sp,sp,32
     a80:	8082                	ret
    nulterminate(pcmd->left);
     a82:	6508                	ld	a0,8(a0)
     a84:	fa3ff0ef          	jal	a26 <nulterminate>
    nulterminate(pcmd->right);
     a88:	6888                	ld	a0,16(s1)
     a8a:	f9dff0ef          	jal	a26 <nulterminate>
    break;
     a8e:	b7e5                	j	a76 <nulterminate+0x50>
    nulterminate(lcmd->left);
     a90:	6508                	ld	a0,8(a0)
     a92:	f95ff0ef          	jal	a26 <nulterminate>
    nulterminate(lcmd->right);
     a96:	6888                	ld	a0,16(s1)
     a98:	f8fff0ef          	jal	a26 <nulterminate>
    break;
     a9c:	bfe9                	j	a76 <nulterminate+0x50>
    nulterminate(bcmd->cmd);
     a9e:	6508                	ld	a0,8(a0)
     aa0:	f87ff0ef          	jal	a26 <nulterminate>
    break;
     aa4:	bfc9                	j	a76 <nulterminate+0x50>

0000000000000aa6 <parsecmd>:
{
     aa6:	7179                	addi	sp,sp,-48
     aa8:	f406                	sd	ra,40(sp)
     aaa:	f022                	sd	s0,32(sp)
     aac:	ec26                	sd	s1,24(sp)
     aae:	e84a                	sd	s2,16(sp)
     ab0:	1800                	addi	s0,sp,48
     ab2:	fca43c23          	sd	a0,-40(s0)
  es = s + strlen(s);
     ab6:	84aa                	mv	s1,a0
     ab8:	188000ef          	jal	c40 <strlen>
     abc:	1502                	slli	a0,a0,0x20
     abe:	9101                	srli	a0,a0,0x20
     ac0:	94aa                	add	s1,s1,a0
  cmd = parseline(&s, es);
     ac2:	85a6                	mv	a1,s1
     ac4:	fd840513          	addi	a0,s0,-40
     ac8:	e53ff0ef          	jal	91a <parseline>
     acc:	892a                	mv	s2,a0
  peek(&s, es, "");
     ace:	00001617          	auipc	a2,0x1
     ad2:	98260613          	addi	a2,a2,-1662 # 1450 <malloc+0x114>
     ad6:	85a6                	mv	a1,s1
     ad8:	fd840513          	addi	a0,s0,-40
     adc:	bc5ff0ef          	jal	6a0 <peek>
  if(s != es){
     ae0:	fd843603          	ld	a2,-40(s0)
     ae4:	00961c63          	bne	a2,s1,afc <parsecmd+0x56>
  nulterminate(cmd);
     ae8:	854a                	mv	a0,s2
     aea:	f3dff0ef          	jal	a26 <nulterminate>
}
     aee:	854a                	mv	a0,s2
     af0:	70a2                	ld	ra,40(sp)
     af2:	7402                	ld	s0,32(sp)
     af4:	64e2                	ld	s1,24(sp)
     af6:	6942                	ld	s2,16(sp)
     af8:	6145                	addi	sp,sp,48
     afa:	8082                	ret
    fprintf(2, "leftovers: %s\n", s);
     afc:	00001597          	auipc	a1,0x1
     b00:	a8c58593          	addi	a1,a1,-1396 # 1588 <malloc+0x24c>
     b04:	4509                	li	a0,2
     b06:	758000ef          	jal	125e <fprintf>
    panic("syntax");
     b0a:	00001517          	auipc	a0,0x1
     b0e:	a1650513          	addi	a0,a0,-1514 # 1520 <malloc+0x1e4>
     b12:	dc6ff0ef          	jal	d8 <panic>

0000000000000b16 <main>:
{
     b16:	7179                	addi	sp,sp,-48
     b18:	f406                	sd	ra,40(sp)
     b1a:	f022                	sd	s0,32(sp)
     b1c:	ec26                	sd	s1,24(sp)
     b1e:	e84a                	sd	s2,16(sp)
     b20:	e44e                	sd	s3,8(sp)
     b22:	e052                	sd	s4,0(sp)
     b24:	1800                	addi	s0,sp,48
  while((fd = open("console", O_RDWR)) >= 0){
     b26:	00001497          	auipc	s1,0x1
     b2a:	a7248493          	addi	s1,s1,-1422 # 1598 <malloc+0x25c>
     b2e:	4589                	li	a1,2
     b30:	8526                	mv	a0,s1
     b32:	35e000ef          	jal	e90 <open>
     b36:	00054763          	bltz	a0,b44 <main+0x2e>
    if(fd >= 3){
     b3a:	4789                	li	a5,2
     b3c:	fea7d9e3          	bge	a5,a0,b2e <main+0x18>
      close(fd);
     b40:	338000ef          	jal	e78 <close>
  while(getcmd(buf, sizeof(buf)) >= 0){
     b44:	00001497          	auipc	s1,0x1
     b48:	4dc48493          	addi	s1,s1,1244 # 2020 <buf.0>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     b4c:	06300913          	li	s2,99
     b50:	02000993          	li	s3,32
     b54:	a039                	j	b62 <main+0x4c>
    if(fork1() == 0)
     b56:	da0ff0ef          	jal	f6 <fork1>
     b5a:	c93d                	beqz	a0,bd0 <main+0xba>
    wait(0);
     b5c:	4501                	li	a0,0
     b5e:	2fa000ef          	jal	e58 <wait>
  while(getcmd(buf, sizeof(buf)) >= 0){
     b62:	06400593          	li	a1,100
     b66:	8526                	mv	a0,s1
     b68:	d26ff0ef          	jal	8e <getcmd>
     b6c:	06054a63          	bltz	a0,be0 <main+0xca>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     b70:	0004c783          	lbu	a5,0(s1)
     b74:	ff2791e3          	bne	a5,s2,b56 <main+0x40>
     b78:	0014c703          	lbu	a4,1(s1)
     b7c:	06400793          	li	a5,100
     b80:	fcf71be3          	bne	a4,a5,b56 <main+0x40>
     b84:	0024c783          	lbu	a5,2(s1)
     b88:	fd3797e3          	bne	a5,s3,b56 <main+0x40>
      buf[strlen(buf)-1] = 0;  // chop \n
     b8c:	00001a17          	auipc	s4,0x1
     b90:	494a0a13          	addi	s4,s4,1172 # 2020 <buf.0>
     b94:	8552                	mv	a0,s4
     b96:	0aa000ef          	jal	c40 <strlen>
     b9a:	fff5079b          	addiw	a5,a0,-1
     b9e:	1782                	slli	a5,a5,0x20
     ba0:	9381                	srli	a5,a5,0x20
     ba2:	9a3e                	add	s4,s4,a5
     ba4:	000a0023          	sb	zero,0(s4)
      if(chdir(buf+3) < 0)
     ba8:	00001517          	auipc	a0,0x1
     bac:	47b50513          	addi	a0,a0,1147 # 2023 <buf.0+0x3>
     bb0:	310000ef          	jal	ec0 <chdir>
     bb4:	fa0557e3          	bgez	a0,b62 <main+0x4c>
        fprintf(2, "cannot cd %s\n", buf+3);
     bb8:	00001617          	auipc	a2,0x1
     bbc:	46b60613          	addi	a2,a2,1131 # 2023 <buf.0+0x3>
     bc0:	00001597          	auipc	a1,0x1
     bc4:	9e058593          	addi	a1,a1,-1568 # 15a0 <malloc+0x264>
     bc8:	4509                	li	a0,2
     bca:	694000ef          	jal	125e <fprintf>
     bce:	bf51                	j	b62 <main+0x4c>
      runcmd(parsecmd(buf));
     bd0:	00001517          	auipc	a0,0x1
     bd4:	45050513          	addi	a0,a0,1104 # 2020 <buf.0>
     bd8:	ecfff0ef          	jal	aa6 <parsecmd>
     bdc:	d40ff0ef          	jal	11c <runcmd>
  exit(0);
     be0:	4501                	li	a0,0
     be2:	26e000ef          	jal	e50 <exit>

0000000000000be6 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
     be6:	1141                	addi	sp,sp,-16
     be8:	e406                	sd	ra,8(sp)
     bea:	e022                	sd	s0,0(sp)
     bec:	0800                	addi	s0,sp,16
  extern int main();
  main();
     bee:	f29ff0ef          	jal	b16 <main>
  exit(0);
     bf2:	4501                	li	a0,0
     bf4:	25c000ef          	jal	e50 <exit>

0000000000000bf8 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
     bf8:	1141                	addi	sp,sp,-16
     bfa:	e422                	sd	s0,8(sp)
     bfc:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     bfe:	87aa                	mv	a5,a0
     c00:	0585                	addi	a1,a1,1
     c02:	0785                	addi	a5,a5,1
     c04:	fff5c703          	lbu	a4,-1(a1)
     c08:	fee78fa3          	sb	a4,-1(a5)
     c0c:	fb75                	bnez	a4,c00 <strcpy+0x8>
    ;
  return os;
}
     c0e:	6422                	ld	s0,8(sp)
     c10:	0141                	addi	sp,sp,16
     c12:	8082                	ret

0000000000000c14 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     c14:	1141                	addi	sp,sp,-16
     c16:	e422                	sd	s0,8(sp)
     c18:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     c1a:	00054783          	lbu	a5,0(a0)
     c1e:	cb91                	beqz	a5,c32 <strcmp+0x1e>
     c20:	0005c703          	lbu	a4,0(a1)
     c24:	00f71763          	bne	a4,a5,c32 <strcmp+0x1e>
    p++, q++;
     c28:	0505                	addi	a0,a0,1
     c2a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     c2c:	00054783          	lbu	a5,0(a0)
     c30:	fbe5                	bnez	a5,c20 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     c32:	0005c503          	lbu	a0,0(a1)
}
     c36:	40a7853b          	subw	a0,a5,a0
     c3a:	6422                	ld	s0,8(sp)
     c3c:	0141                	addi	sp,sp,16
     c3e:	8082                	ret

0000000000000c40 <strlen>:

uint
strlen(const char *s)
{
     c40:	1141                	addi	sp,sp,-16
     c42:	e422                	sd	s0,8(sp)
     c44:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     c46:	00054783          	lbu	a5,0(a0)
     c4a:	cf91                	beqz	a5,c66 <strlen+0x26>
     c4c:	0505                	addi	a0,a0,1
     c4e:	87aa                	mv	a5,a0
     c50:	86be                	mv	a3,a5
     c52:	0785                	addi	a5,a5,1
     c54:	fff7c703          	lbu	a4,-1(a5)
     c58:	ff65                	bnez	a4,c50 <strlen+0x10>
     c5a:	40a6853b          	subw	a0,a3,a0
     c5e:	2505                	addiw	a0,a0,1
    ;
  return n;
}
     c60:	6422                	ld	s0,8(sp)
     c62:	0141                	addi	sp,sp,16
     c64:	8082                	ret
  for(n = 0; s[n]; n++)
     c66:	4501                	li	a0,0
     c68:	bfe5                	j	c60 <strlen+0x20>

0000000000000c6a <memset>:

void*
memset(void *dst, int c, uint n)
{
     c6a:	1141                	addi	sp,sp,-16
     c6c:	e422                	sd	s0,8(sp)
     c6e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     c70:	ca19                	beqz	a2,c86 <memset+0x1c>
     c72:	87aa                	mv	a5,a0
     c74:	1602                	slli	a2,a2,0x20
     c76:	9201                	srli	a2,a2,0x20
     c78:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     c7c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     c80:	0785                	addi	a5,a5,1
     c82:	fee79de3          	bne	a5,a4,c7c <memset+0x12>
  }
  return dst;
}
     c86:	6422                	ld	s0,8(sp)
     c88:	0141                	addi	sp,sp,16
     c8a:	8082                	ret

0000000000000c8c <strchr>:

char*
strchr(const char *s, char c)
{
     c8c:	1141                	addi	sp,sp,-16
     c8e:	e422                	sd	s0,8(sp)
     c90:	0800                	addi	s0,sp,16
  for(; *s; s++)
     c92:	00054783          	lbu	a5,0(a0)
     c96:	cb99                	beqz	a5,cac <strchr+0x20>
    if(*s == c)
     c98:	00f58763          	beq	a1,a5,ca6 <strchr+0x1a>
  for(; *s; s++)
     c9c:	0505                	addi	a0,a0,1
     c9e:	00054783          	lbu	a5,0(a0)
     ca2:	fbfd                	bnez	a5,c98 <strchr+0xc>
      return (char*)s;
  return 0;
     ca4:	4501                	li	a0,0
}
     ca6:	6422                	ld	s0,8(sp)
     ca8:	0141                	addi	sp,sp,16
     caa:	8082                	ret
  return 0;
     cac:	4501                	li	a0,0
     cae:	bfe5                	j	ca6 <strchr+0x1a>

0000000000000cb0 <gets>:

char*
gets(char *buf, int max)
{
     cb0:	711d                	addi	sp,sp,-96
     cb2:	ec86                	sd	ra,88(sp)
     cb4:	e8a2                	sd	s0,80(sp)
     cb6:	e4a6                	sd	s1,72(sp)
     cb8:	e0ca                	sd	s2,64(sp)
     cba:	fc4e                	sd	s3,56(sp)
     cbc:	f852                	sd	s4,48(sp)
     cbe:	f456                	sd	s5,40(sp)
     cc0:	f05a                	sd	s6,32(sp)
     cc2:	ec5e                	sd	s7,24(sp)
     cc4:	1080                	addi	s0,sp,96
     cc6:	8baa                	mv	s7,a0
     cc8:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     cca:	892a                	mv	s2,a0
     ccc:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     cce:	4aa9                	li	s5,10
     cd0:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     cd2:	89a6                	mv	s3,s1
     cd4:	2485                	addiw	s1,s1,1
     cd6:	0344d663          	bge	s1,s4,d02 <gets+0x52>
    cc = read(0, &c, 1);
     cda:	4605                	li	a2,1
     cdc:	faf40593          	addi	a1,s0,-81
     ce0:	4501                	li	a0,0
     ce2:	186000ef          	jal	e68 <read>
    if(cc < 1)
     ce6:	00a05e63          	blez	a0,d02 <gets+0x52>
    buf[i++] = c;
     cea:	faf44783          	lbu	a5,-81(s0)
     cee:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     cf2:	01578763          	beq	a5,s5,d00 <gets+0x50>
     cf6:	0905                	addi	s2,s2,1
     cf8:	fd679de3          	bne	a5,s6,cd2 <gets+0x22>
    buf[i++] = c;
     cfc:	89a6                	mv	s3,s1
     cfe:	a011                	j	d02 <gets+0x52>
     d00:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     d02:	99de                	add	s3,s3,s7
     d04:	00098023          	sb	zero,0(s3)
  return buf;
}
     d08:	855e                	mv	a0,s7
     d0a:	60e6                	ld	ra,88(sp)
     d0c:	6446                	ld	s0,80(sp)
     d0e:	64a6                	ld	s1,72(sp)
     d10:	6906                	ld	s2,64(sp)
     d12:	79e2                	ld	s3,56(sp)
     d14:	7a42                	ld	s4,48(sp)
     d16:	7aa2                	ld	s5,40(sp)
     d18:	7b02                	ld	s6,32(sp)
     d1a:	6be2                	ld	s7,24(sp)
     d1c:	6125                	addi	sp,sp,96
     d1e:	8082                	ret

0000000000000d20 <stat>:

int
stat(const char *n, struct stat *st)
{
     d20:	1101                	addi	sp,sp,-32
     d22:	ec06                	sd	ra,24(sp)
     d24:	e822                	sd	s0,16(sp)
     d26:	e04a                	sd	s2,0(sp)
     d28:	1000                	addi	s0,sp,32
     d2a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     d2c:	4581                	li	a1,0
     d2e:	162000ef          	jal	e90 <open>
  if(fd < 0)
     d32:	02054263          	bltz	a0,d56 <stat+0x36>
     d36:	e426                	sd	s1,8(sp)
     d38:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     d3a:	85ca                	mv	a1,s2
     d3c:	16c000ef          	jal	ea8 <fstat>
     d40:	892a                	mv	s2,a0
  close(fd);
     d42:	8526                	mv	a0,s1
     d44:	134000ef          	jal	e78 <close>
  return r;
     d48:	64a2                	ld	s1,8(sp)
}
     d4a:	854a                	mv	a0,s2
     d4c:	60e2                	ld	ra,24(sp)
     d4e:	6442                	ld	s0,16(sp)
     d50:	6902                	ld	s2,0(sp)
     d52:	6105                	addi	sp,sp,32
     d54:	8082                	ret
    return -1;
     d56:	597d                	li	s2,-1
     d58:	bfcd                	j	d4a <stat+0x2a>

0000000000000d5a <atoi>:

int
atoi(const char *s)
{
     d5a:	1141                	addi	sp,sp,-16
     d5c:	e422                	sd	s0,8(sp)
     d5e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     d60:	00054683          	lbu	a3,0(a0)
     d64:	fd06879b          	addiw	a5,a3,-48
     d68:	0ff7f793          	zext.b	a5,a5
     d6c:	4625                	li	a2,9
     d6e:	02f66863          	bltu	a2,a5,d9e <atoi+0x44>
     d72:	872a                	mv	a4,a0
  n = 0;
     d74:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
     d76:	0705                	addi	a4,a4,1
     d78:	0025179b          	slliw	a5,a0,0x2
     d7c:	9fa9                	addw	a5,a5,a0
     d7e:	0017979b          	slliw	a5,a5,0x1
     d82:	9fb5                	addw	a5,a5,a3
     d84:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     d88:	00074683          	lbu	a3,0(a4)
     d8c:	fd06879b          	addiw	a5,a3,-48
     d90:	0ff7f793          	zext.b	a5,a5
     d94:	fef671e3          	bgeu	a2,a5,d76 <atoi+0x1c>
  return n;
}
     d98:	6422                	ld	s0,8(sp)
     d9a:	0141                	addi	sp,sp,16
     d9c:	8082                	ret
  n = 0;
     d9e:	4501                	li	a0,0
     da0:	bfe5                	j	d98 <atoi+0x3e>

0000000000000da2 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     da2:	1141                	addi	sp,sp,-16
     da4:	e422                	sd	s0,8(sp)
     da6:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     da8:	02b57463          	bgeu	a0,a1,dd0 <memmove+0x2e>
    while(n-- > 0)
     dac:	00c05f63          	blez	a2,dca <memmove+0x28>
     db0:	1602                	slli	a2,a2,0x20
     db2:	9201                	srli	a2,a2,0x20
     db4:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     db8:	872a                	mv	a4,a0
      *dst++ = *src++;
     dba:	0585                	addi	a1,a1,1
     dbc:	0705                	addi	a4,a4,1
     dbe:	fff5c683          	lbu	a3,-1(a1)
     dc2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     dc6:	fef71ae3          	bne	a4,a5,dba <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     dca:	6422                	ld	s0,8(sp)
     dcc:	0141                	addi	sp,sp,16
     dce:	8082                	ret
    dst += n;
     dd0:	00c50733          	add	a4,a0,a2
    src += n;
     dd4:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     dd6:	fec05ae3          	blez	a2,dca <memmove+0x28>
     dda:	fff6079b          	addiw	a5,a2,-1
     dde:	1782                	slli	a5,a5,0x20
     de0:	9381                	srli	a5,a5,0x20
     de2:	fff7c793          	not	a5,a5
     de6:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     de8:	15fd                	addi	a1,a1,-1
     dea:	177d                	addi	a4,a4,-1
     dec:	0005c683          	lbu	a3,0(a1)
     df0:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     df4:	fee79ae3          	bne	a5,a4,de8 <memmove+0x46>
     df8:	bfc9                	j	dca <memmove+0x28>

0000000000000dfa <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     dfa:	1141                	addi	sp,sp,-16
     dfc:	e422                	sd	s0,8(sp)
     dfe:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     e00:	ca05                	beqz	a2,e30 <memcmp+0x36>
     e02:	fff6069b          	addiw	a3,a2,-1
     e06:	1682                	slli	a3,a3,0x20
     e08:	9281                	srli	a3,a3,0x20
     e0a:	0685                	addi	a3,a3,1
     e0c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     e0e:	00054783          	lbu	a5,0(a0)
     e12:	0005c703          	lbu	a4,0(a1)
     e16:	00e79863          	bne	a5,a4,e26 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     e1a:	0505                	addi	a0,a0,1
    p2++;
     e1c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     e1e:	fed518e3          	bne	a0,a3,e0e <memcmp+0x14>
  }
  return 0;
     e22:	4501                	li	a0,0
     e24:	a019                	j	e2a <memcmp+0x30>
      return *p1 - *p2;
     e26:	40e7853b          	subw	a0,a5,a4
}
     e2a:	6422                	ld	s0,8(sp)
     e2c:	0141                	addi	sp,sp,16
     e2e:	8082                	ret
  return 0;
     e30:	4501                	li	a0,0
     e32:	bfe5                	j	e2a <memcmp+0x30>

0000000000000e34 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     e34:	1141                	addi	sp,sp,-16
     e36:	e406                	sd	ra,8(sp)
     e38:	e022                	sd	s0,0(sp)
     e3a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     e3c:	f67ff0ef          	jal	da2 <memmove>
}
     e40:	60a2                	ld	ra,8(sp)
     e42:	6402                	ld	s0,0(sp)
     e44:	0141                	addi	sp,sp,16
     e46:	8082                	ret

0000000000000e48 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     e48:	4885                	li	a7,1
 ecall
     e4a:	00000073          	ecall
 ret
     e4e:	8082                	ret

0000000000000e50 <exit>:
.global exit
exit:
 li a7, SYS_exit
     e50:	4889                	li	a7,2
 ecall
     e52:	00000073          	ecall
 ret
     e56:	8082                	ret

0000000000000e58 <wait>:
.global wait
wait:
 li a7, SYS_wait
     e58:	488d                	li	a7,3
 ecall
     e5a:	00000073          	ecall
 ret
     e5e:	8082                	ret

0000000000000e60 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     e60:	4891                	li	a7,4
 ecall
     e62:	00000073          	ecall
 ret
     e66:	8082                	ret

0000000000000e68 <read>:
.global read
read:
 li a7, SYS_read
     e68:	4895                	li	a7,5
 ecall
     e6a:	00000073          	ecall
 ret
     e6e:	8082                	ret

0000000000000e70 <write>:
.global write
write:
 li a7, SYS_write
     e70:	48c1                	li	a7,16
 ecall
     e72:	00000073          	ecall
 ret
     e76:	8082                	ret

0000000000000e78 <close>:
.global close
close:
 li a7, SYS_close
     e78:	48d5                	li	a7,21
 ecall
     e7a:	00000073          	ecall
 ret
     e7e:	8082                	ret

0000000000000e80 <kill>:
.global kill
kill:
 li a7, SYS_kill
     e80:	4899                	li	a7,6
 ecall
     e82:	00000073          	ecall
 ret
     e86:	8082                	ret

0000000000000e88 <exec>:
.global exec
exec:
 li a7, SYS_exec
     e88:	489d                	li	a7,7
 ecall
     e8a:	00000073          	ecall
 ret
     e8e:	8082                	ret

0000000000000e90 <open>:
.global open
open:
 li a7, SYS_open
     e90:	48bd                	li	a7,15
 ecall
     e92:	00000073          	ecall
 ret
     e96:	8082                	ret

0000000000000e98 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     e98:	48c5                	li	a7,17
 ecall
     e9a:	00000073          	ecall
 ret
     e9e:	8082                	ret

0000000000000ea0 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     ea0:	48c9                	li	a7,18
 ecall
     ea2:	00000073          	ecall
 ret
     ea6:	8082                	ret

0000000000000ea8 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     ea8:	48a1                	li	a7,8
 ecall
     eaa:	00000073          	ecall
 ret
     eae:	8082                	ret

0000000000000eb0 <link>:
.global link
link:
 li a7, SYS_link
     eb0:	48cd                	li	a7,19
 ecall
     eb2:	00000073          	ecall
 ret
     eb6:	8082                	ret

0000000000000eb8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     eb8:	48d1                	li	a7,20
 ecall
     eba:	00000073          	ecall
 ret
     ebe:	8082                	ret

0000000000000ec0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     ec0:	48a5                	li	a7,9
 ecall
     ec2:	00000073          	ecall
 ret
     ec6:	8082                	ret

0000000000000ec8 <dup>:
.global dup
dup:
 li a7, SYS_dup
     ec8:	48a9                	li	a7,10
 ecall
     eca:	00000073          	ecall
 ret
     ece:	8082                	ret

0000000000000ed0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     ed0:	48ad                	li	a7,11
 ecall
     ed2:	00000073          	ecall
 ret
     ed6:	8082                	ret

0000000000000ed8 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     ed8:	48b1                	li	a7,12
 ecall
     eda:	00000073          	ecall
 ret
     ede:	8082                	ret

0000000000000ee0 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     ee0:	48b5                	li	a7,13
 ecall
     ee2:	00000073          	ecall
 ret
     ee6:	8082                	ret

0000000000000ee8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     ee8:	48b9                	li	a7,14
 ecall
     eea:	00000073          	ecall
 ret
     eee:	8082                	ret

0000000000000ef0 <trigger>:
.global trigger
trigger:
 li a7, SYS_trigger
     ef0:	48d9                	li	a7,22
 ecall
     ef2:	00000073          	ecall
 ret
     ef6:	8082                	ret

0000000000000ef8 <thread>:
.global thread
thread:
 li a7, SYS_thread
     ef8:	48dd                	li	a7,23
 ecall
     efa:	00000073          	ecall
 ret
     efe:	8082                	ret

0000000000000f00 <jointhread>:
.global jointhread
jointhread:
 li a7, SYS_jointhread
     f00:	48e1                	li	a7,24
 ecall
     f02:	00000073          	ecall
 ret
     f06:	8082                	ret

0000000000000f08 <yield>:
.global yield
yield:
 li a7, SYS_yield
     f08:	48e5                	li	a7,25
 ecall
     f0a:	00000073          	ecall
 ret
     f0e:	8082                	ret

0000000000000f10 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     f10:	1101                	addi	sp,sp,-32
     f12:	ec06                	sd	ra,24(sp)
     f14:	e822                	sd	s0,16(sp)
     f16:	1000                	addi	s0,sp,32
     f18:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     f1c:	4605                	li	a2,1
     f1e:	fef40593          	addi	a1,s0,-17
     f22:	f4fff0ef          	jal	e70 <write>
}
     f26:	60e2                	ld	ra,24(sp)
     f28:	6442                	ld	s0,16(sp)
     f2a:	6105                	addi	sp,sp,32
     f2c:	8082                	ret

0000000000000f2e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     f2e:	7139                	addi	sp,sp,-64
     f30:	fc06                	sd	ra,56(sp)
     f32:	f822                	sd	s0,48(sp)
     f34:	f426                	sd	s1,40(sp)
     f36:	0080                	addi	s0,sp,64
     f38:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
     f3a:	c299                	beqz	a3,f40 <printint+0x12>
     f3c:	0805c963          	bltz	a1,fce <printint+0xa0>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
     f40:	2581                	sext.w	a1,a1
  neg = 0;
     f42:	4881                	li	a7,0
     f44:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
     f48:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
     f4a:	2601                	sext.w	a2,a2
     f4c:	00000517          	auipc	a0,0x0
     f50:	69c50513          	addi	a0,a0,1692 # 15e8 <digits>
     f54:	883a                	mv	a6,a4
     f56:	2705                	addiw	a4,a4,1
     f58:	02c5f7bb          	remuw	a5,a1,a2
     f5c:	1782                	slli	a5,a5,0x20
     f5e:	9381                	srli	a5,a5,0x20
     f60:	97aa                	add	a5,a5,a0
     f62:	0007c783          	lbu	a5,0(a5)
     f66:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
     f6a:	0005879b          	sext.w	a5,a1
     f6e:	02c5d5bb          	divuw	a1,a1,a2
     f72:	0685                	addi	a3,a3,1
     f74:	fec7f0e3          	bgeu	a5,a2,f54 <printint+0x26>
  if(neg)
     f78:	00088c63          	beqz	a7,f90 <printint+0x62>
    buf[i++] = '-';
     f7c:	fd070793          	addi	a5,a4,-48
     f80:	00878733          	add	a4,a5,s0
     f84:	02d00793          	li	a5,45
     f88:	fef70823          	sb	a5,-16(a4)
     f8c:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
     f90:	02e05a63          	blez	a4,fc4 <printint+0x96>
     f94:	f04a                	sd	s2,32(sp)
     f96:	ec4e                	sd	s3,24(sp)
     f98:	fc040793          	addi	a5,s0,-64
     f9c:	00e78933          	add	s2,a5,a4
     fa0:	fff78993          	addi	s3,a5,-1
     fa4:	99ba                	add	s3,s3,a4
     fa6:	377d                	addiw	a4,a4,-1
     fa8:	1702                	slli	a4,a4,0x20
     faa:	9301                	srli	a4,a4,0x20
     fac:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
     fb0:	fff94583          	lbu	a1,-1(s2)
     fb4:	8526                	mv	a0,s1
     fb6:	f5bff0ef          	jal	f10 <putc>
  while(--i >= 0)
     fba:	197d                	addi	s2,s2,-1
     fbc:	ff391ae3          	bne	s2,s3,fb0 <printint+0x82>
     fc0:	7902                	ld	s2,32(sp)
     fc2:	69e2                	ld	s3,24(sp)
}
     fc4:	70e2                	ld	ra,56(sp)
     fc6:	7442                	ld	s0,48(sp)
     fc8:	74a2                	ld	s1,40(sp)
     fca:	6121                	addi	sp,sp,64
     fcc:	8082                	ret
    x = -xx;
     fce:	40b005bb          	negw	a1,a1
    neg = 1;
     fd2:	4885                	li	a7,1
    x = -xx;
     fd4:	bf85                	j	f44 <printint+0x16>

0000000000000fd6 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
     fd6:	711d                	addi	sp,sp,-96
     fd8:	ec86                	sd	ra,88(sp)
     fda:	e8a2                	sd	s0,80(sp)
     fdc:	e0ca                	sd	s2,64(sp)
     fde:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
     fe0:	0005c903          	lbu	s2,0(a1)
     fe4:	26090863          	beqz	s2,1254 <vprintf+0x27e>
     fe8:	e4a6                	sd	s1,72(sp)
     fea:	fc4e                	sd	s3,56(sp)
     fec:	f852                	sd	s4,48(sp)
     fee:	f456                	sd	s5,40(sp)
     ff0:	f05a                	sd	s6,32(sp)
     ff2:	ec5e                	sd	s7,24(sp)
     ff4:	e862                	sd	s8,16(sp)
     ff6:	e466                	sd	s9,8(sp)
     ff8:	8b2a                	mv	s6,a0
     ffa:	8a2e                	mv	s4,a1
     ffc:	8bb2                	mv	s7,a2
  state = 0;
     ffe:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
    1000:	4481                	li	s1,0
    1002:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
    1004:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
    1008:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
    100c:	06c00c93          	li	s9,108
    1010:	a005                	j	1030 <vprintf+0x5a>
        putc(fd, c0);
    1012:	85ca                	mv	a1,s2
    1014:	855a                	mv	a0,s6
    1016:	efbff0ef          	jal	f10 <putc>
    101a:	a019                	j	1020 <vprintf+0x4a>
    } else if(state == '%'){
    101c:	03598263          	beq	s3,s5,1040 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
    1020:	2485                	addiw	s1,s1,1
    1022:	8726                	mv	a4,s1
    1024:	009a07b3          	add	a5,s4,s1
    1028:	0007c903          	lbu	s2,0(a5)
    102c:	20090c63          	beqz	s2,1244 <vprintf+0x26e>
    c0 = fmt[i] & 0xff;
    1030:	0009079b          	sext.w	a5,s2
    if(state == 0){
    1034:	fe0994e3          	bnez	s3,101c <vprintf+0x46>
      if(c0 == '%'){
    1038:	fd579de3          	bne	a5,s5,1012 <vprintf+0x3c>
        state = '%';
    103c:	89be                	mv	s3,a5
    103e:	b7cd                	j	1020 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
    1040:	00ea06b3          	add	a3,s4,a4
    1044:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
    1048:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
    104a:	c681                	beqz	a3,1052 <vprintf+0x7c>
    104c:	9752                	add	a4,a4,s4
    104e:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
    1052:	03878f63          	beq	a5,s8,1090 <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
    1056:	05978963          	beq	a5,s9,10a8 <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
    105a:	07500713          	li	a4,117
    105e:	0ee78363          	beq	a5,a4,1144 <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
    1062:	07800713          	li	a4,120
    1066:	12e78563          	beq	a5,a4,1190 <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
    106a:	07000713          	li	a4,112
    106e:	14e78a63          	beq	a5,a4,11c2 <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
    1072:	07300713          	li	a4,115
    1076:	18e78a63          	beq	a5,a4,120a <vprintf+0x234>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
    107a:	02500713          	li	a4,37
    107e:	04e79563          	bne	a5,a4,10c8 <vprintf+0xf2>
        putc(fd, '%');
    1082:	02500593          	li	a1,37
    1086:	855a                	mv	a0,s6
    1088:	e89ff0ef          	jal	f10 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
    108c:	4981                	li	s3,0
    108e:	bf49                	j	1020 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
    1090:	008b8913          	addi	s2,s7,8
    1094:	4685                	li	a3,1
    1096:	4629                	li	a2,10
    1098:	000ba583          	lw	a1,0(s7)
    109c:	855a                	mv	a0,s6
    109e:	e91ff0ef          	jal	f2e <printint>
    10a2:	8bca                	mv	s7,s2
      state = 0;
    10a4:	4981                	li	s3,0
    10a6:	bfad                	j	1020 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
    10a8:	06400793          	li	a5,100
    10ac:	02f68963          	beq	a3,a5,10de <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    10b0:	06c00793          	li	a5,108
    10b4:	04f68263          	beq	a3,a5,10f8 <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
    10b8:	07500793          	li	a5,117
    10bc:	0af68063          	beq	a3,a5,115c <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
    10c0:	07800793          	li	a5,120
    10c4:	0ef68263          	beq	a3,a5,11a8 <vprintf+0x1d2>
        putc(fd, '%');
    10c8:	02500593          	li	a1,37
    10cc:	855a                	mv	a0,s6
    10ce:	e43ff0ef          	jal	f10 <putc>
        putc(fd, c0);
    10d2:	85ca                	mv	a1,s2
    10d4:	855a                	mv	a0,s6
    10d6:	e3bff0ef          	jal	f10 <putc>
      state = 0;
    10da:	4981                	li	s3,0
    10dc:	b791                	j	1020 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
    10de:	008b8913          	addi	s2,s7,8
    10e2:	4685                	li	a3,1
    10e4:	4629                	li	a2,10
    10e6:	000ba583          	lw	a1,0(s7)
    10ea:	855a                	mv	a0,s6
    10ec:	e43ff0ef          	jal	f2e <printint>
        i += 1;
    10f0:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
    10f2:	8bca                	mv	s7,s2
      state = 0;
    10f4:	4981                	li	s3,0
        i += 1;
    10f6:	b72d                	j	1020 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    10f8:	06400793          	li	a5,100
    10fc:	02f60763          	beq	a2,a5,112a <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    1100:	07500793          	li	a5,117
    1104:	06f60963          	beq	a2,a5,1176 <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    1108:	07800793          	li	a5,120
    110c:	faf61ee3          	bne	a2,a5,10c8 <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
    1110:	008b8913          	addi	s2,s7,8
    1114:	4681                	li	a3,0
    1116:	4641                	li	a2,16
    1118:	000ba583          	lw	a1,0(s7)
    111c:	855a                	mv	a0,s6
    111e:	e11ff0ef          	jal	f2e <printint>
        i += 2;
    1122:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
    1124:	8bca                	mv	s7,s2
      state = 0;
    1126:	4981                	li	s3,0
        i += 2;
    1128:	bde5                	j	1020 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
    112a:	008b8913          	addi	s2,s7,8
    112e:	4685                	li	a3,1
    1130:	4629                	li	a2,10
    1132:	000ba583          	lw	a1,0(s7)
    1136:	855a                	mv	a0,s6
    1138:	df7ff0ef          	jal	f2e <printint>
        i += 2;
    113c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
    113e:	8bca                	mv	s7,s2
      state = 0;
    1140:	4981                	li	s3,0
        i += 2;
    1142:	bdf9                	j	1020 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
    1144:	008b8913          	addi	s2,s7,8
    1148:	4681                	li	a3,0
    114a:	4629                	li	a2,10
    114c:	000ba583          	lw	a1,0(s7)
    1150:	855a                	mv	a0,s6
    1152:	dddff0ef          	jal	f2e <printint>
    1156:	8bca                	mv	s7,s2
      state = 0;
    1158:	4981                	li	s3,0
    115a:	b5d9                	j	1020 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
    115c:	008b8913          	addi	s2,s7,8
    1160:	4681                	li	a3,0
    1162:	4629                	li	a2,10
    1164:	000ba583          	lw	a1,0(s7)
    1168:	855a                	mv	a0,s6
    116a:	dc5ff0ef          	jal	f2e <printint>
        i += 1;
    116e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
    1170:	8bca                	mv	s7,s2
      state = 0;
    1172:	4981                	li	s3,0
        i += 1;
    1174:	b575                	j	1020 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
    1176:	008b8913          	addi	s2,s7,8
    117a:	4681                	li	a3,0
    117c:	4629                	li	a2,10
    117e:	000ba583          	lw	a1,0(s7)
    1182:	855a                	mv	a0,s6
    1184:	dabff0ef          	jal	f2e <printint>
        i += 2;
    1188:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
    118a:	8bca                	mv	s7,s2
      state = 0;
    118c:	4981                	li	s3,0
        i += 2;
    118e:	bd49                	j	1020 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
    1190:	008b8913          	addi	s2,s7,8
    1194:	4681                	li	a3,0
    1196:	4641                	li	a2,16
    1198:	000ba583          	lw	a1,0(s7)
    119c:	855a                	mv	a0,s6
    119e:	d91ff0ef          	jal	f2e <printint>
    11a2:	8bca                	mv	s7,s2
      state = 0;
    11a4:	4981                	li	s3,0
    11a6:	bdad                	j	1020 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
    11a8:	008b8913          	addi	s2,s7,8
    11ac:	4681                	li	a3,0
    11ae:	4641                	li	a2,16
    11b0:	000ba583          	lw	a1,0(s7)
    11b4:	855a                	mv	a0,s6
    11b6:	d79ff0ef          	jal	f2e <printint>
        i += 1;
    11ba:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
    11bc:	8bca                	mv	s7,s2
      state = 0;
    11be:	4981                	li	s3,0
        i += 1;
    11c0:	b585                	j	1020 <vprintf+0x4a>
    11c2:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
    11c4:	008b8d13          	addi	s10,s7,8
    11c8:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
    11cc:	03000593          	li	a1,48
    11d0:	855a                	mv	a0,s6
    11d2:	d3fff0ef          	jal	f10 <putc>
  putc(fd, 'x');
    11d6:	07800593          	li	a1,120
    11da:	855a                	mv	a0,s6
    11dc:	d35ff0ef          	jal	f10 <putc>
    11e0:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    11e2:	00000b97          	auipc	s7,0x0
    11e6:	406b8b93          	addi	s7,s7,1030 # 15e8 <digits>
    11ea:	03c9d793          	srli	a5,s3,0x3c
    11ee:	97de                	add	a5,a5,s7
    11f0:	0007c583          	lbu	a1,0(a5)
    11f4:	855a                	mv	a0,s6
    11f6:	d1bff0ef          	jal	f10 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    11fa:	0992                	slli	s3,s3,0x4
    11fc:	397d                	addiw	s2,s2,-1
    11fe:	fe0916e3          	bnez	s2,11ea <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
    1202:	8bea                	mv	s7,s10
      state = 0;
    1204:	4981                	li	s3,0
    1206:	6d02                	ld	s10,0(sp)
    1208:	bd21                	j	1020 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
    120a:	008b8993          	addi	s3,s7,8
    120e:	000bb903          	ld	s2,0(s7)
    1212:	00090f63          	beqz	s2,1230 <vprintf+0x25a>
        for(; *s; s++)
    1216:	00094583          	lbu	a1,0(s2)
    121a:	c195                	beqz	a1,123e <vprintf+0x268>
          putc(fd, *s);
    121c:	855a                	mv	a0,s6
    121e:	cf3ff0ef          	jal	f10 <putc>
        for(; *s; s++)
    1222:	0905                	addi	s2,s2,1
    1224:	00094583          	lbu	a1,0(s2)
    1228:	f9f5                	bnez	a1,121c <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
    122a:	8bce                	mv	s7,s3
      state = 0;
    122c:	4981                	li	s3,0
    122e:	bbcd                	j	1020 <vprintf+0x4a>
          s = "(null)";
    1230:	00000917          	auipc	s2,0x0
    1234:	38090913          	addi	s2,s2,896 # 15b0 <malloc+0x274>
        for(; *s; s++)
    1238:	02800593          	li	a1,40
    123c:	b7c5                	j	121c <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
    123e:	8bce                	mv	s7,s3
      state = 0;
    1240:	4981                	li	s3,0
    1242:	bbf9                	j	1020 <vprintf+0x4a>
    1244:	64a6                	ld	s1,72(sp)
    1246:	79e2                	ld	s3,56(sp)
    1248:	7a42                	ld	s4,48(sp)
    124a:	7aa2                	ld	s5,40(sp)
    124c:	7b02                	ld	s6,32(sp)
    124e:	6be2                	ld	s7,24(sp)
    1250:	6c42                	ld	s8,16(sp)
    1252:	6ca2                	ld	s9,8(sp)
    }
  }
}
    1254:	60e6                	ld	ra,88(sp)
    1256:	6446                	ld	s0,80(sp)
    1258:	6906                	ld	s2,64(sp)
    125a:	6125                	addi	sp,sp,96
    125c:	8082                	ret

000000000000125e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    125e:	715d                	addi	sp,sp,-80
    1260:	ec06                	sd	ra,24(sp)
    1262:	e822                	sd	s0,16(sp)
    1264:	1000                	addi	s0,sp,32
    1266:	e010                	sd	a2,0(s0)
    1268:	e414                	sd	a3,8(s0)
    126a:	e818                	sd	a4,16(s0)
    126c:	ec1c                	sd	a5,24(s0)
    126e:	03043023          	sd	a6,32(s0)
    1272:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    1276:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    127a:	8622                	mv	a2,s0
    127c:	d5bff0ef          	jal	fd6 <vprintf>
}
    1280:	60e2                	ld	ra,24(sp)
    1282:	6442                	ld	s0,16(sp)
    1284:	6161                	addi	sp,sp,80
    1286:	8082                	ret

0000000000001288 <printf>:

void
printf(const char *fmt, ...)
{
    1288:	711d                	addi	sp,sp,-96
    128a:	ec06                	sd	ra,24(sp)
    128c:	e822                	sd	s0,16(sp)
    128e:	1000                	addi	s0,sp,32
    1290:	e40c                	sd	a1,8(s0)
    1292:	e810                	sd	a2,16(s0)
    1294:	ec14                	sd	a3,24(s0)
    1296:	f018                	sd	a4,32(s0)
    1298:	f41c                	sd	a5,40(s0)
    129a:	03043823          	sd	a6,48(s0)
    129e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    12a2:	00840613          	addi	a2,s0,8
    12a6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    12aa:	85aa                	mv	a1,a0
    12ac:	4505                	li	a0,1
    12ae:	d29ff0ef          	jal	fd6 <vprintf>
}
    12b2:	60e2                	ld	ra,24(sp)
    12b4:	6442                	ld	s0,16(sp)
    12b6:	6125                	addi	sp,sp,96
    12b8:	8082                	ret

00000000000012ba <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    12ba:	1141                	addi	sp,sp,-16
    12bc:	e422                	sd	s0,8(sp)
    12be:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    12c0:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    12c4:	00001797          	auipc	a5,0x1
    12c8:	d4c7b783          	ld	a5,-692(a5) # 2010 <freep>
    12cc:	a02d                	j	12f6 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    12ce:	4618                	lw	a4,8(a2)
    12d0:	9f2d                	addw	a4,a4,a1
    12d2:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    12d6:	6398                	ld	a4,0(a5)
    12d8:	6310                	ld	a2,0(a4)
    12da:	a83d                	j	1318 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    12dc:	ff852703          	lw	a4,-8(a0)
    12e0:	9f31                	addw	a4,a4,a2
    12e2:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    12e4:	ff053683          	ld	a3,-16(a0)
    12e8:	a091                	j	132c <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    12ea:	6398                	ld	a4,0(a5)
    12ec:	00e7e463          	bltu	a5,a4,12f4 <free+0x3a>
    12f0:	00e6ea63          	bltu	a3,a4,1304 <free+0x4a>
{
    12f4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    12f6:	fed7fae3          	bgeu	a5,a3,12ea <free+0x30>
    12fa:	6398                	ld	a4,0(a5)
    12fc:	00e6e463          	bltu	a3,a4,1304 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1300:	fee7eae3          	bltu	a5,a4,12f4 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
    1304:	ff852583          	lw	a1,-8(a0)
    1308:	6390                	ld	a2,0(a5)
    130a:	02059813          	slli	a6,a1,0x20
    130e:	01c85713          	srli	a4,a6,0x1c
    1312:	9736                	add	a4,a4,a3
    1314:	fae60de3          	beq	a2,a4,12ce <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
    1318:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    131c:	4790                	lw	a2,8(a5)
    131e:	02061593          	slli	a1,a2,0x20
    1322:	01c5d713          	srli	a4,a1,0x1c
    1326:	973e                	add	a4,a4,a5
    1328:	fae68ae3          	beq	a3,a4,12dc <free+0x22>
    p->s.ptr = bp->s.ptr;
    132c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    132e:	00001717          	auipc	a4,0x1
    1332:	cef73123          	sd	a5,-798(a4) # 2010 <freep>
}
    1336:	6422                	ld	s0,8(sp)
    1338:	0141                	addi	sp,sp,16
    133a:	8082                	ret

000000000000133c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    133c:	7139                	addi	sp,sp,-64
    133e:	fc06                	sd	ra,56(sp)
    1340:	f822                	sd	s0,48(sp)
    1342:	f426                	sd	s1,40(sp)
    1344:	ec4e                	sd	s3,24(sp)
    1346:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1348:	02051493          	slli	s1,a0,0x20
    134c:	9081                	srli	s1,s1,0x20
    134e:	04bd                	addi	s1,s1,15
    1350:	8091                	srli	s1,s1,0x4
    1352:	0014899b          	addiw	s3,s1,1
    1356:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    1358:	00001517          	auipc	a0,0x1
    135c:	cb853503          	ld	a0,-840(a0) # 2010 <freep>
    1360:	c915                	beqz	a0,1394 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1362:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1364:	4798                	lw	a4,8(a5)
    1366:	08977a63          	bgeu	a4,s1,13fa <malloc+0xbe>
    136a:	f04a                	sd	s2,32(sp)
    136c:	e852                	sd	s4,16(sp)
    136e:	e456                	sd	s5,8(sp)
    1370:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
    1372:	8a4e                	mv	s4,s3
    1374:	0009871b          	sext.w	a4,s3
    1378:	6685                	lui	a3,0x1
    137a:	00d77363          	bgeu	a4,a3,1380 <malloc+0x44>
    137e:	6a05                	lui	s4,0x1
    1380:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    1384:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    1388:	00001917          	auipc	s2,0x1
    138c:	c8890913          	addi	s2,s2,-888 # 2010 <freep>
  if(p == (char*)-1)
    1390:	5afd                	li	s5,-1
    1392:	a081                	j	13d2 <malloc+0x96>
    1394:	f04a                	sd	s2,32(sp)
    1396:	e852                	sd	s4,16(sp)
    1398:	e456                	sd	s5,8(sp)
    139a:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
    139c:	00001797          	auipc	a5,0x1
    13a0:	cec78793          	addi	a5,a5,-788 # 2088 <base>
    13a4:	00001717          	auipc	a4,0x1
    13a8:	c6f73623          	sd	a5,-916(a4) # 2010 <freep>
    13ac:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    13ae:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    13b2:	b7c1                	j	1372 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
    13b4:	6398                	ld	a4,0(a5)
    13b6:	e118                	sd	a4,0(a0)
    13b8:	a8a9                	j	1412 <malloc+0xd6>
  hp->s.size = nu;
    13ba:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    13be:	0541                	addi	a0,a0,16
    13c0:	efbff0ef          	jal	12ba <free>
  return freep;
    13c4:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    13c8:	c12d                	beqz	a0,142a <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    13ca:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    13cc:	4798                	lw	a4,8(a5)
    13ce:	02977263          	bgeu	a4,s1,13f2 <malloc+0xb6>
    if(p == freep)
    13d2:	00093703          	ld	a4,0(s2)
    13d6:	853e                	mv	a0,a5
    13d8:	fef719e3          	bne	a4,a5,13ca <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
    13dc:	8552                	mv	a0,s4
    13de:	afbff0ef          	jal	ed8 <sbrk>
  if(p == (char*)-1)
    13e2:	fd551ce3          	bne	a0,s5,13ba <malloc+0x7e>
        return 0;
    13e6:	4501                	li	a0,0
    13e8:	7902                	ld	s2,32(sp)
    13ea:	6a42                	ld	s4,16(sp)
    13ec:	6aa2                	ld	s5,8(sp)
    13ee:	6b02                	ld	s6,0(sp)
    13f0:	a03d                	j	141e <malloc+0xe2>
    13f2:	7902                	ld	s2,32(sp)
    13f4:	6a42                	ld	s4,16(sp)
    13f6:	6aa2                	ld	s5,8(sp)
    13f8:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
    13fa:	fae48de3          	beq	s1,a4,13b4 <malloc+0x78>
        p->s.size -= nunits;
    13fe:	4137073b          	subw	a4,a4,s3
    1402:	c798                	sw	a4,8(a5)
        p += p->s.size;
    1404:	02071693          	slli	a3,a4,0x20
    1408:	01c6d713          	srli	a4,a3,0x1c
    140c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    140e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    1412:	00001717          	auipc	a4,0x1
    1416:	bea73f23          	sd	a0,-1026(a4) # 2010 <freep>
      return (void*)(p + 1);
    141a:	01078513          	addi	a0,a5,16
  }
}
    141e:	70e2                	ld	ra,56(sp)
    1420:	7442                	ld	s0,48(sp)
    1422:	74a2                	ld	s1,40(sp)
    1424:	69e2                	ld	s3,24(sp)
    1426:	6121                	addi	sp,sp,64
    1428:	8082                	ret
    142a:	7902                	ld	s2,32(sp)
    142c:	6a42                	ld	s4,16(sp)
    142e:	6aa2                	ld	s5,8(sp)
    1430:	6b02                	ld	s6,0(sp)
    1432:	b7f5                	j	141e <malloc+0xe2>
