
user/_grind:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <do_rand>:
#include "kernel/riscv.h"

// from FreeBSD.
int
do_rand(unsigned long *ctx)
{
       0:	1141                	addi	sp,sp,-16
       2:	e422                	sd	s0,8(sp)
       4:	0800                	addi	s0,sp,16
 * October 1988, p. 1195.
 */
    long hi, lo, x;

    /* Transform to [1, 0x7ffffffe] range. */
    x = (*ctx % 0x7ffffffe) + 1;
       6:	611c                	ld	a5,0(a0)
       8:	80000737          	lui	a4,0x80000
       c:	ffe74713          	xori	a4,a4,-2
      10:	02e7f7b3          	remu	a5,a5,a4
      14:	0785                	addi	a5,a5,1
    hi = x / 127773;
    lo = x % 127773;
      16:	66fd                	lui	a3,0x1f
      18:	31d68693          	addi	a3,a3,797 # 1f31d <base+0x1cf15>
      1c:	02d7e733          	rem	a4,a5,a3
    x = 16807 * lo - 2836 * hi;
      20:	6611                	lui	a2,0x4
      22:	1a760613          	addi	a2,a2,423 # 41a7 <base+0x1d9f>
      26:	02c70733          	mul	a4,a4,a2
    hi = x / 127773;
      2a:	02d7c7b3          	div	a5,a5,a3
    x = 16807 * lo - 2836 * hi;
      2e:	76fd                	lui	a3,0xfffff
      30:	4ec68693          	addi	a3,a3,1260 # fffffffffffff4ec <base+0xffffffffffffd0e4>
      34:	02d787b3          	mul	a5,a5,a3
      38:	97ba                	add	a5,a5,a4
    if (x < 0)
      3a:	0007c963          	bltz	a5,4c <do_rand+0x4c>
        x += 0x7fffffff;
    /* Transform to [0, 0x7ffffffd] range. */
    x--;
      3e:	17fd                	addi	a5,a5,-1
    *ctx = x;
      40:	e11c                	sd	a5,0(a0)
    return (x);
}
      42:	0007851b          	sext.w	a0,a5
      46:	6422                	ld	s0,8(sp)
      48:	0141                	addi	sp,sp,16
      4a:	8082                	ret
        x += 0x7fffffff;
      4c:	80000737          	lui	a4,0x80000
      50:	fff74713          	not	a4,a4
      54:	97ba                	add	a5,a5,a4
      56:	b7e5                	j	3e <do_rand+0x3e>

0000000000000058 <rand>:

unsigned long rand_next = 1;

int
rand(void)
{
      58:	1141                	addi	sp,sp,-16
      5a:	e406                	sd	ra,8(sp)
      5c:	e022                	sd	s0,0(sp)
      5e:	0800                	addi	s0,sp,16
    return (do_rand(&rand_next));
      60:	00002517          	auipc	a0,0x2
      64:	fa050513          	addi	a0,a0,-96 # 2000 <rand_next>
      68:	f99ff0ef          	jal	0 <do_rand>
}
      6c:	60a2                	ld	ra,8(sp)
      6e:	6402                	ld	s0,0(sp)
      70:	0141                	addi	sp,sp,16
      72:	8082                	ret

0000000000000074 <go>:

void
go(int which_child)
{
      74:	7119                	addi	sp,sp,-128
      76:	fc86                	sd	ra,120(sp)
      78:	f8a2                	sd	s0,112(sp)
      7a:	f4a6                	sd	s1,104(sp)
      7c:	e4d6                	sd	s5,72(sp)
      7e:	0100                	addi	s0,sp,128
      80:	84aa                	mv	s1,a0
  int fd = -1;
  static char buf[999];
  char *break0 = sbrk(0);
      82:	4501                	li	a0,0
      84:	353000ef          	jal	bd6 <sbrk>
      88:	8aaa                	mv	s5,a0
  uint64 iters = 0;

  mkdir("grindir");
      8a:	00001517          	auipc	a0,0x1
      8e:	0b650513          	addi	a0,a0,182 # 1140 <malloc+0x106>
      92:	325000ef          	jal	bb6 <mkdir>
  if(chdir("grindir") != 0){
      96:	00001517          	auipc	a0,0x1
      9a:	0aa50513          	addi	a0,a0,170 # 1140 <malloc+0x106>
      9e:	321000ef          	jal	bbe <chdir>
      a2:	cd19                	beqz	a0,c0 <go+0x4c>
      a4:	f0ca                	sd	s2,96(sp)
      a6:	ecce                	sd	s3,88(sp)
      a8:	e8d2                	sd	s4,80(sp)
      aa:	e0da                	sd	s6,64(sp)
      ac:	fc5e                	sd	s7,56(sp)
    printf("grind: chdir grindir failed\n");
      ae:	00001517          	auipc	a0,0x1
      b2:	09a50513          	addi	a0,a0,154 # 1148 <malloc+0x10e>
      b6:	6d1000ef          	jal	f86 <printf>
    exit(1);
      ba:	4505                	li	a0,1
      bc:	293000ef          	jal	b4e <exit>
      c0:	f0ca                	sd	s2,96(sp)
      c2:	ecce                	sd	s3,88(sp)
      c4:	e8d2                	sd	s4,80(sp)
      c6:	e0da                	sd	s6,64(sp)
      c8:	fc5e                	sd	s7,56(sp)
  }
  chdir("/");
      ca:	00001517          	auipc	a0,0x1
      ce:	0a650513          	addi	a0,a0,166 # 1170 <malloc+0x136>
      d2:	2ed000ef          	jal	bbe <chdir>
      d6:	00001997          	auipc	s3,0x1
      da:	0aa98993          	addi	s3,s3,170 # 1180 <malloc+0x146>
      de:	c489                	beqz	s1,e8 <go+0x74>
      e0:	00001997          	auipc	s3,0x1
      e4:	09898993          	addi	s3,s3,152 # 1178 <malloc+0x13e>
  uint64 iters = 0;
      e8:	4481                	li	s1,0
  int fd = -1;
      ea:	5a7d                	li	s4,-1
      ec:	00001917          	auipc	s2,0x1
      f0:	36490913          	addi	s2,s2,868 # 1450 <malloc+0x416>
      f4:	a819                	j	10a <go+0x96>
    iters++;
    if((iters % 500) == 0)
      write(1, which_child?"B":"A", 1);
    int what = rand() % 23;
    if(what == 1){
      close(open("grindir/../a", O_CREATE|O_RDWR));
      f6:	20200593          	li	a1,514
      fa:	00001517          	auipc	a0,0x1
      fe:	08e50513          	addi	a0,a0,142 # 1188 <malloc+0x14e>
     102:	28d000ef          	jal	b8e <open>
     106:	271000ef          	jal	b76 <close>
    iters++;
     10a:	0485                	addi	s1,s1,1
    if((iters % 500) == 0)
     10c:	1f400793          	li	a5,500
     110:	02f4f7b3          	remu	a5,s1,a5
     114:	e791                	bnez	a5,120 <go+0xac>
      write(1, which_child?"B":"A", 1);
     116:	4605                	li	a2,1
     118:	85ce                	mv	a1,s3
     11a:	4505                	li	a0,1
     11c:	253000ef          	jal	b6e <write>
    int what = rand() % 23;
     120:	f39ff0ef          	jal	58 <rand>
     124:	47dd                	li	a5,23
     126:	02f5653b          	remw	a0,a0,a5
     12a:	0005071b          	sext.w	a4,a0
     12e:	47d9                	li	a5,22
     130:	fce7ede3          	bltu	a5,a4,10a <go+0x96>
     134:	02051793          	slli	a5,a0,0x20
     138:	01e7d513          	srli	a0,a5,0x1e
     13c:	954a                	add	a0,a0,s2
     13e:	411c                	lw	a5,0(a0)
     140:	97ca                	add	a5,a5,s2
     142:	8782                	jr	a5
    } else if(what == 2){
      close(open("grindir/../grindir/../b", O_CREATE|O_RDWR));
     144:	20200593          	li	a1,514
     148:	00001517          	auipc	a0,0x1
     14c:	05050513          	addi	a0,a0,80 # 1198 <malloc+0x15e>
     150:	23f000ef          	jal	b8e <open>
     154:	223000ef          	jal	b76 <close>
     158:	bf4d                	j	10a <go+0x96>
    } else if(what == 3){
      unlink("grindir/../a");
     15a:	00001517          	auipc	a0,0x1
     15e:	02e50513          	addi	a0,a0,46 # 1188 <malloc+0x14e>
     162:	23d000ef          	jal	b9e <unlink>
     166:	b755                	j	10a <go+0x96>
    } else if(what == 4){
      if(chdir("grindir") != 0){
     168:	00001517          	auipc	a0,0x1
     16c:	fd850513          	addi	a0,a0,-40 # 1140 <malloc+0x106>
     170:	24f000ef          	jal	bbe <chdir>
     174:	ed11                	bnez	a0,190 <go+0x11c>
        printf("grind: chdir grindir failed\n");
        exit(1);
      }
      unlink("../b");
     176:	00001517          	auipc	a0,0x1
     17a:	03a50513          	addi	a0,a0,58 # 11b0 <malloc+0x176>
     17e:	221000ef          	jal	b9e <unlink>
      chdir("/");
     182:	00001517          	auipc	a0,0x1
     186:	fee50513          	addi	a0,a0,-18 # 1170 <malloc+0x136>
     18a:	235000ef          	jal	bbe <chdir>
     18e:	bfb5                	j	10a <go+0x96>
        printf("grind: chdir grindir failed\n");
     190:	00001517          	auipc	a0,0x1
     194:	fb850513          	addi	a0,a0,-72 # 1148 <malloc+0x10e>
     198:	5ef000ef          	jal	f86 <printf>
        exit(1);
     19c:	4505                	li	a0,1
     19e:	1b1000ef          	jal	b4e <exit>
    } else if(what == 5){
      close(fd);
     1a2:	8552                	mv	a0,s4
     1a4:	1d3000ef          	jal	b76 <close>
      fd = open("/grindir/../a", O_CREATE|O_RDWR);
     1a8:	20200593          	li	a1,514
     1ac:	00001517          	auipc	a0,0x1
     1b0:	00c50513          	addi	a0,a0,12 # 11b8 <malloc+0x17e>
     1b4:	1db000ef          	jal	b8e <open>
     1b8:	8a2a                	mv	s4,a0
     1ba:	bf81                	j	10a <go+0x96>
    } else if(what == 6){
      close(fd);
     1bc:	8552                	mv	a0,s4
     1be:	1b9000ef          	jal	b76 <close>
      fd = open("/./grindir/./../b", O_CREATE|O_RDWR);
     1c2:	20200593          	li	a1,514
     1c6:	00001517          	auipc	a0,0x1
     1ca:	00250513          	addi	a0,a0,2 # 11c8 <malloc+0x18e>
     1ce:	1c1000ef          	jal	b8e <open>
     1d2:	8a2a                	mv	s4,a0
     1d4:	bf1d                	j	10a <go+0x96>
    } else if(what == 7){
      write(fd, buf, sizeof(buf));
     1d6:	3e700613          	li	a2,999
     1da:	00002597          	auipc	a1,0x2
     1de:	e4658593          	addi	a1,a1,-442 # 2020 <buf.0>
     1e2:	8552                	mv	a0,s4
     1e4:	18b000ef          	jal	b6e <write>
     1e8:	b70d                	j	10a <go+0x96>
    } else if(what == 8){
      read(fd, buf, sizeof(buf));
     1ea:	3e700613          	li	a2,999
     1ee:	00002597          	auipc	a1,0x2
     1f2:	e3258593          	addi	a1,a1,-462 # 2020 <buf.0>
     1f6:	8552                	mv	a0,s4
     1f8:	16f000ef          	jal	b66 <read>
     1fc:	b739                	j	10a <go+0x96>
    } else if(what == 9){
      mkdir("grindir/../a");
     1fe:	00001517          	auipc	a0,0x1
     202:	f8a50513          	addi	a0,a0,-118 # 1188 <malloc+0x14e>
     206:	1b1000ef          	jal	bb6 <mkdir>
      close(open("a/../a/./a", O_CREATE|O_RDWR));
     20a:	20200593          	li	a1,514
     20e:	00001517          	auipc	a0,0x1
     212:	fd250513          	addi	a0,a0,-46 # 11e0 <malloc+0x1a6>
     216:	179000ef          	jal	b8e <open>
     21a:	15d000ef          	jal	b76 <close>
      unlink("a/a");
     21e:	00001517          	auipc	a0,0x1
     222:	fd250513          	addi	a0,a0,-46 # 11f0 <malloc+0x1b6>
     226:	179000ef          	jal	b9e <unlink>
     22a:	b5c5                	j	10a <go+0x96>
    } else if(what == 10){
      mkdir("/../b");
     22c:	00001517          	auipc	a0,0x1
     230:	fcc50513          	addi	a0,a0,-52 # 11f8 <malloc+0x1be>
     234:	183000ef          	jal	bb6 <mkdir>
      close(open("grindir/../b/b", O_CREATE|O_RDWR));
     238:	20200593          	li	a1,514
     23c:	00001517          	auipc	a0,0x1
     240:	fc450513          	addi	a0,a0,-60 # 1200 <malloc+0x1c6>
     244:	14b000ef          	jal	b8e <open>
     248:	12f000ef          	jal	b76 <close>
      unlink("b/b");
     24c:	00001517          	auipc	a0,0x1
     250:	fc450513          	addi	a0,a0,-60 # 1210 <malloc+0x1d6>
     254:	14b000ef          	jal	b9e <unlink>
     258:	bd4d                	j	10a <go+0x96>
    } else if(what == 11){
      unlink("b");
     25a:	00001517          	auipc	a0,0x1
     25e:	fbe50513          	addi	a0,a0,-66 # 1218 <malloc+0x1de>
     262:	13d000ef          	jal	b9e <unlink>
      link("../grindir/./../a", "../b");
     266:	00001597          	auipc	a1,0x1
     26a:	f4a58593          	addi	a1,a1,-182 # 11b0 <malloc+0x176>
     26e:	00001517          	auipc	a0,0x1
     272:	fb250513          	addi	a0,a0,-78 # 1220 <malloc+0x1e6>
     276:	139000ef          	jal	bae <link>
     27a:	bd41                	j	10a <go+0x96>
    } else if(what == 12){
      unlink("../grindir/../a");
     27c:	00001517          	auipc	a0,0x1
     280:	fbc50513          	addi	a0,a0,-68 # 1238 <malloc+0x1fe>
     284:	11b000ef          	jal	b9e <unlink>
      link(".././b", "/grindir/../a");
     288:	00001597          	auipc	a1,0x1
     28c:	f3058593          	addi	a1,a1,-208 # 11b8 <malloc+0x17e>
     290:	00001517          	auipc	a0,0x1
     294:	fb850513          	addi	a0,a0,-72 # 1248 <malloc+0x20e>
     298:	117000ef          	jal	bae <link>
     29c:	b5bd                	j	10a <go+0x96>
    } else if(what == 13){
      int pid = fork();
     29e:	0a9000ef          	jal	b46 <fork>
      if(pid == 0){
     2a2:	c519                	beqz	a0,2b0 <go+0x23c>
        exit(0);
      } else if(pid < 0){
     2a4:	00054863          	bltz	a0,2b4 <go+0x240>
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
     2a8:	4501                	li	a0,0
     2aa:	0ad000ef          	jal	b56 <wait>
     2ae:	bdb1                	j	10a <go+0x96>
        exit(0);
     2b0:	09f000ef          	jal	b4e <exit>
        printf("grind: fork failed\n");
     2b4:	00001517          	auipc	a0,0x1
     2b8:	f9c50513          	addi	a0,a0,-100 # 1250 <malloc+0x216>
     2bc:	4cb000ef          	jal	f86 <printf>
        exit(1);
     2c0:	4505                	li	a0,1
     2c2:	08d000ef          	jal	b4e <exit>
    } else if(what == 14){
      int pid = fork();
     2c6:	081000ef          	jal	b46 <fork>
      if(pid == 0){
     2ca:	c519                	beqz	a0,2d8 <go+0x264>
        fork();
        fork();
        exit(0);
      } else if(pid < 0){
     2cc:	00054d63          	bltz	a0,2e6 <go+0x272>
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
     2d0:	4501                	li	a0,0
     2d2:	085000ef          	jal	b56 <wait>
     2d6:	bd15                	j	10a <go+0x96>
        fork();
     2d8:	06f000ef          	jal	b46 <fork>
        fork();
     2dc:	06b000ef          	jal	b46 <fork>
        exit(0);
     2e0:	4501                	li	a0,0
     2e2:	06d000ef          	jal	b4e <exit>
        printf("grind: fork failed\n");
     2e6:	00001517          	auipc	a0,0x1
     2ea:	f6a50513          	addi	a0,a0,-150 # 1250 <malloc+0x216>
     2ee:	499000ef          	jal	f86 <printf>
        exit(1);
     2f2:	4505                	li	a0,1
     2f4:	05b000ef          	jal	b4e <exit>
    } else if(what == 15){
      sbrk(6011);
     2f8:	6505                	lui	a0,0x1
     2fa:	77b50513          	addi	a0,a0,1915 # 177b <digits+0x2cb>
     2fe:	0d9000ef          	jal	bd6 <sbrk>
     302:	b521                	j	10a <go+0x96>
    } else if(what == 16){
      if(sbrk(0) > break0)
     304:	4501                	li	a0,0
     306:	0d1000ef          	jal	bd6 <sbrk>
     30a:	e0aaf0e3          	bgeu	s5,a0,10a <go+0x96>
        sbrk(-(sbrk(0) - break0));
     30e:	4501                	li	a0,0
     310:	0c7000ef          	jal	bd6 <sbrk>
     314:	40aa853b          	subw	a0,s5,a0
     318:	0bf000ef          	jal	bd6 <sbrk>
     31c:	b3fd                	j	10a <go+0x96>
    } else if(what == 17){
      int pid = fork();
     31e:	029000ef          	jal	b46 <fork>
     322:	8b2a                	mv	s6,a0
      if(pid == 0){
     324:	c10d                	beqz	a0,346 <go+0x2d2>
        close(open("a", O_CREATE|O_RDWR));
        exit(0);
      } else if(pid < 0){
     326:	02054d63          	bltz	a0,360 <go+0x2ec>
        printf("grind: fork failed\n");
        exit(1);
      }
      if(chdir("../grindir/..") != 0){
     32a:	00001517          	auipc	a0,0x1
     32e:	f4650513          	addi	a0,a0,-186 # 1270 <malloc+0x236>
     332:	08d000ef          	jal	bbe <chdir>
     336:	ed15                	bnez	a0,372 <go+0x2fe>
        printf("grind: chdir failed\n");
        exit(1);
      }
      kill(pid);
     338:	855a                	mv	a0,s6
     33a:	045000ef          	jal	b7e <kill>
      wait(0);
     33e:	4501                	li	a0,0
     340:	017000ef          	jal	b56 <wait>
     344:	b3d9                	j	10a <go+0x96>
        close(open("a", O_CREATE|O_RDWR));
     346:	20200593          	li	a1,514
     34a:	00001517          	auipc	a0,0x1
     34e:	f1e50513          	addi	a0,a0,-226 # 1268 <malloc+0x22e>
     352:	03d000ef          	jal	b8e <open>
     356:	021000ef          	jal	b76 <close>
        exit(0);
     35a:	4501                	li	a0,0
     35c:	7f2000ef          	jal	b4e <exit>
        printf("grind: fork failed\n");
     360:	00001517          	auipc	a0,0x1
     364:	ef050513          	addi	a0,a0,-272 # 1250 <malloc+0x216>
     368:	41f000ef          	jal	f86 <printf>
        exit(1);
     36c:	4505                	li	a0,1
     36e:	7e0000ef          	jal	b4e <exit>
        printf("grind: chdir failed\n");
     372:	00001517          	auipc	a0,0x1
     376:	f0e50513          	addi	a0,a0,-242 # 1280 <malloc+0x246>
     37a:	40d000ef          	jal	f86 <printf>
        exit(1);
     37e:	4505                	li	a0,1
     380:	7ce000ef          	jal	b4e <exit>
    } else if(what == 18){
      int pid = fork();
     384:	7c2000ef          	jal	b46 <fork>
      if(pid == 0){
     388:	c519                	beqz	a0,396 <go+0x322>
        kill(getpid());
        exit(0);
      } else if(pid < 0){
     38a:	00054d63          	bltz	a0,3a4 <go+0x330>
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
     38e:	4501                	li	a0,0
     390:	7c6000ef          	jal	b56 <wait>
     394:	bb9d                	j	10a <go+0x96>
        kill(getpid());
     396:	039000ef          	jal	bce <getpid>
     39a:	7e4000ef          	jal	b7e <kill>
        exit(0);
     39e:	4501                	li	a0,0
     3a0:	7ae000ef          	jal	b4e <exit>
        printf("grind: fork failed\n");
     3a4:	00001517          	auipc	a0,0x1
     3a8:	eac50513          	addi	a0,a0,-340 # 1250 <malloc+0x216>
     3ac:	3db000ef          	jal	f86 <printf>
        exit(1);
     3b0:	4505                	li	a0,1
     3b2:	79c000ef          	jal	b4e <exit>
    } else if(what == 19){
      int fds[2];
      if(pipe(fds) < 0){
     3b6:	f9840513          	addi	a0,s0,-104
     3ba:	7a4000ef          	jal	b5e <pipe>
     3be:	02054363          	bltz	a0,3e4 <go+0x370>
        printf("grind: pipe failed\n");
        exit(1);
      }
      int pid = fork();
     3c2:	784000ef          	jal	b46 <fork>
      if(pid == 0){
     3c6:	c905                	beqz	a0,3f6 <go+0x382>
          printf("grind: pipe write failed\n");
        char c;
        if(read(fds[0], &c, 1) != 1)
          printf("grind: pipe read failed\n");
        exit(0);
      } else if(pid < 0){
     3c8:	08054263          	bltz	a0,44c <go+0x3d8>
        printf("grind: fork failed\n");
        exit(1);
      }
      close(fds[0]);
     3cc:	f9842503          	lw	a0,-104(s0)
     3d0:	7a6000ef          	jal	b76 <close>
      close(fds[1]);
     3d4:	f9c42503          	lw	a0,-100(s0)
     3d8:	79e000ef          	jal	b76 <close>
      wait(0);
     3dc:	4501                	li	a0,0
     3de:	778000ef          	jal	b56 <wait>
     3e2:	b325                	j	10a <go+0x96>
        printf("grind: pipe failed\n");
     3e4:	00001517          	auipc	a0,0x1
     3e8:	eb450513          	addi	a0,a0,-332 # 1298 <malloc+0x25e>
     3ec:	39b000ef          	jal	f86 <printf>
        exit(1);
     3f0:	4505                	li	a0,1
     3f2:	75c000ef          	jal	b4e <exit>
        fork();
     3f6:	750000ef          	jal	b46 <fork>
        fork();
     3fa:	74c000ef          	jal	b46 <fork>
        if(write(fds[1], "x", 1) != 1)
     3fe:	4605                	li	a2,1
     400:	00001597          	auipc	a1,0x1
     404:	eb058593          	addi	a1,a1,-336 # 12b0 <malloc+0x276>
     408:	f9c42503          	lw	a0,-100(s0)
     40c:	762000ef          	jal	b6e <write>
     410:	4785                	li	a5,1
     412:	00f51f63          	bne	a0,a5,430 <go+0x3bc>
        if(read(fds[0], &c, 1) != 1)
     416:	4605                	li	a2,1
     418:	f9040593          	addi	a1,s0,-112
     41c:	f9842503          	lw	a0,-104(s0)
     420:	746000ef          	jal	b66 <read>
     424:	4785                	li	a5,1
     426:	00f51c63          	bne	a0,a5,43e <go+0x3ca>
        exit(0);
     42a:	4501                	li	a0,0
     42c:	722000ef          	jal	b4e <exit>
          printf("grind: pipe write failed\n");
     430:	00001517          	auipc	a0,0x1
     434:	e8850513          	addi	a0,a0,-376 # 12b8 <malloc+0x27e>
     438:	34f000ef          	jal	f86 <printf>
     43c:	bfe9                	j	416 <go+0x3a2>
          printf("grind: pipe read failed\n");
     43e:	00001517          	auipc	a0,0x1
     442:	e9a50513          	addi	a0,a0,-358 # 12d8 <malloc+0x29e>
     446:	341000ef          	jal	f86 <printf>
     44a:	b7c5                	j	42a <go+0x3b6>
        printf("grind: fork failed\n");
     44c:	00001517          	auipc	a0,0x1
     450:	e0450513          	addi	a0,a0,-508 # 1250 <malloc+0x216>
     454:	333000ef          	jal	f86 <printf>
        exit(1);
     458:	4505                	li	a0,1
     45a:	6f4000ef          	jal	b4e <exit>
    } else if(what == 20){
      int pid = fork();
     45e:	6e8000ef          	jal	b46 <fork>
      if(pid == 0){
     462:	c519                	beqz	a0,470 <go+0x3fc>
        chdir("a");
        unlink("../a");
        fd = open("x", O_CREATE|O_RDWR);
        unlink("x");
        exit(0);
      } else if(pid < 0){
     464:	04054f63          	bltz	a0,4c2 <go+0x44e>
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
     468:	4501                	li	a0,0
     46a:	6ec000ef          	jal	b56 <wait>
     46e:	b971                	j	10a <go+0x96>
        unlink("a");
     470:	00001517          	auipc	a0,0x1
     474:	df850513          	addi	a0,a0,-520 # 1268 <malloc+0x22e>
     478:	726000ef          	jal	b9e <unlink>
        mkdir("a");
     47c:	00001517          	auipc	a0,0x1
     480:	dec50513          	addi	a0,a0,-532 # 1268 <malloc+0x22e>
     484:	732000ef          	jal	bb6 <mkdir>
        chdir("a");
     488:	00001517          	auipc	a0,0x1
     48c:	de050513          	addi	a0,a0,-544 # 1268 <malloc+0x22e>
     490:	72e000ef          	jal	bbe <chdir>
        unlink("../a");
     494:	00001517          	auipc	a0,0x1
     498:	e6450513          	addi	a0,a0,-412 # 12f8 <malloc+0x2be>
     49c:	702000ef          	jal	b9e <unlink>
        fd = open("x", O_CREATE|O_RDWR);
     4a0:	20200593          	li	a1,514
     4a4:	00001517          	auipc	a0,0x1
     4a8:	e0c50513          	addi	a0,a0,-500 # 12b0 <malloc+0x276>
     4ac:	6e2000ef          	jal	b8e <open>
        unlink("x");
     4b0:	00001517          	auipc	a0,0x1
     4b4:	e0050513          	addi	a0,a0,-512 # 12b0 <malloc+0x276>
     4b8:	6e6000ef          	jal	b9e <unlink>
        exit(0);
     4bc:	4501                	li	a0,0
     4be:	690000ef          	jal	b4e <exit>
        printf("grind: fork failed\n");
     4c2:	00001517          	auipc	a0,0x1
     4c6:	d8e50513          	addi	a0,a0,-626 # 1250 <malloc+0x216>
     4ca:	2bd000ef          	jal	f86 <printf>
        exit(1);
     4ce:	4505                	li	a0,1
     4d0:	67e000ef          	jal	b4e <exit>
    } else if(what == 21){
      unlink("c");
     4d4:	00001517          	auipc	a0,0x1
     4d8:	e2c50513          	addi	a0,a0,-468 # 1300 <malloc+0x2c6>
     4dc:	6c2000ef          	jal	b9e <unlink>
      // should always succeed. check that there are free i-nodes,
      // file descriptors, blocks.
      int fd1 = open("c", O_CREATE|O_RDWR);
     4e0:	20200593          	li	a1,514
     4e4:	00001517          	auipc	a0,0x1
     4e8:	e1c50513          	addi	a0,a0,-484 # 1300 <malloc+0x2c6>
     4ec:	6a2000ef          	jal	b8e <open>
     4f0:	8b2a                	mv	s6,a0
      if(fd1 < 0){
     4f2:	04054763          	bltz	a0,540 <go+0x4cc>
        printf("grind: create c failed\n");
        exit(1);
      }
      if(write(fd1, "x", 1) != 1){
     4f6:	4605                	li	a2,1
     4f8:	00001597          	auipc	a1,0x1
     4fc:	db858593          	addi	a1,a1,-584 # 12b0 <malloc+0x276>
     500:	66e000ef          	jal	b6e <write>
     504:	4785                	li	a5,1
     506:	04f51663          	bne	a0,a5,552 <go+0x4de>
        printf("grind: write c failed\n");
        exit(1);
      }
      struct stat st;
      if(fstat(fd1, &st) != 0){
     50a:	f9840593          	addi	a1,s0,-104
     50e:	855a                	mv	a0,s6
     510:	696000ef          	jal	ba6 <fstat>
     514:	e921                	bnez	a0,564 <go+0x4f0>
        printf("grind: fstat failed\n");
        exit(1);
      }
      if(st.size != 1){
     516:	fa843583          	ld	a1,-88(s0)
     51a:	4785                	li	a5,1
     51c:	04f59d63          	bne	a1,a5,576 <go+0x502>
        printf("grind: fstat reports wrong size %d\n", (int)st.size);
        exit(1);
      }
      if(st.ino > 200){
     520:	f9c42583          	lw	a1,-100(s0)
     524:	0c800793          	li	a5,200
     528:	06b7e163          	bltu	a5,a1,58a <go+0x516>
        printf("grind: fstat reports crazy i-number %d\n", st.ino);
        exit(1);
      }
      close(fd1);
     52c:	855a                	mv	a0,s6
     52e:	648000ef          	jal	b76 <close>
      unlink("c");
     532:	00001517          	auipc	a0,0x1
     536:	dce50513          	addi	a0,a0,-562 # 1300 <malloc+0x2c6>
     53a:	664000ef          	jal	b9e <unlink>
     53e:	b6f1                	j	10a <go+0x96>
        printf("grind: create c failed\n");
     540:	00001517          	auipc	a0,0x1
     544:	dc850513          	addi	a0,a0,-568 # 1308 <malloc+0x2ce>
     548:	23f000ef          	jal	f86 <printf>
        exit(1);
     54c:	4505                	li	a0,1
     54e:	600000ef          	jal	b4e <exit>
        printf("grind: write c failed\n");
     552:	00001517          	auipc	a0,0x1
     556:	dce50513          	addi	a0,a0,-562 # 1320 <malloc+0x2e6>
     55a:	22d000ef          	jal	f86 <printf>
        exit(1);
     55e:	4505                	li	a0,1
     560:	5ee000ef          	jal	b4e <exit>
        printf("grind: fstat failed\n");
     564:	00001517          	auipc	a0,0x1
     568:	dd450513          	addi	a0,a0,-556 # 1338 <malloc+0x2fe>
     56c:	21b000ef          	jal	f86 <printf>
        exit(1);
     570:	4505                	li	a0,1
     572:	5dc000ef          	jal	b4e <exit>
        printf("grind: fstat reports wrong size %d\n", (int)st.size);
     576:	2581                	sext.w	a1,a1
     578:	00001517          	auipc	a0,0x1
     57c:	dd850513          	addi	a0,a0,-552 # 1350 <malloc+0x316>
     580:	207000ef          	jal	f86 <printf>
        exit(1);
     584:	4505                	li	a0,1
     586:	5c8000ef          	jal	b4e <exit>
        printf("grind: fstat reports crazy i-number %d\n", st.ino);
     58a:	00001517          	auipc	a0,0x1
     58e:	dee50513          	addi	a0,a0,-530 # 1378 <malloc+0x33e>
     592:	1f5000ef          	jal	f86 <printf>
        exit(1);
     596:	4505                	li	a0,1
     598:	5b6000ef          	jal	b4e <exit>
    } else if(what == 22){
      // echo hi | cat
      int aa[2], bb[2];
      if(pipe(aa) < 0){
     59c:	f8840513          	addi	a0,s0,-120
     5a0:	5be000ef          	jal	b5e <pipe>
     5a4:	0a054563          	bltz	a0,64e <go+0x5da>
        fprintf(2, "grind: pipe failed\n");
        exit(1);
      }
      if(pipe(bb) < 0){
     5a8:	f9040513          	addi	a0,s0,-112
     5ac:	5b2000ef          	jal	b5e <pipe>
     5b0:	0a054963          	bltz	a0,662 <go+0x5ee>
        fprintf(2, "grind: pipe failed\n");
        exit(1);
      }
      int pid1 = fork();
     5b4:	592000ef          	jal	b46 <fork>
      if(pid1 == 0){
     5b8:	cd5d                	beqz	a0,676 <go+0x602>
        close(aa[1]);
        char *args[3] = { "echo", "hi", 0 };
        exec("grindir/../echo", args);
        fprintf(2, "grind: echo: not found\n");
        exit(2);
      } else if(pid1 < 0){
     5ba:	14054263          	bltz	a0,6fe <go+0x68a>
        fprintf(2, "grind: fork failed\n");
        exit(3);
      }
      int pid2 = fork();
     5be:	588000ef          	jal	b46 <fork>
      if(pid2 == 0){
     5c2:	14050863          	beqz	a0,712 <go+0x69e>
        close(bb[1]);
        char *args[2] = { "cat", 0 };
        exec("/cat", args);
        fprintf(2, "grind: cat: not found\n");
        exit(6);
      } else if(pid2 < 0){
     5c6:	1e054663          	bltz	a0,7b2 <go+0x73e>
        fprintf(2, "grind: fork failed\n");
        exit(7);
      }
      close(aa[0]);
     5ca:	f8842503          	lw	a0,-120(s0)
     5ce:	5a8000ef          	jal	b76 <close>
      close(aa[1]);
     5d2:	f8c42503          	lw	a0,-116(s0)
     5d6:	5a0000ef          	jal	b76 <close>
      close(bb[1]);
     5da:	f9442503          	lw	a0,-108(s0)
     5de:	598000ef          	jal	b76 <close>
      char buf[4] = { 0, 0, 0, 0 };
     5e2:	f8042023          	sw	zero,-128(s0)
      read(bb[0], buf+0, 1);
     5e6:	4605                	li	a2,1
     5e8:	f8040593          	addi	a1,s0,-128
     5ec:	f9042503          	lw	a0,-112(s0)
     5f0:	576000ef          	jal	b66 <read>
      read(bb[0], buf+1, 1);
     5f4:	4605                	li	a2,1
     5f6:	f8140593          	addi	a1,s0,-127
     5fa:	f9042503          	lw	a0,-112(s0)
     5fe:	568000ef          	jal	b66 <read>
      read(bb[0], buf+2, 1);
     602:	4605                	li	a2,1
     604:	f8240593          	addi	a1,s0,-126
     608:	f9042503          	lw	a0,-112(s0)
     60c:	55a000ef          	jal	b66 <read>
      close(bb[0]);
     610:	f9042503          	lw	a0,-112(s0)
     614:	562000ef          	jal	b76 <close>
      int st1, st2;
      wait(&st1);
     618:	f8440513          	addi	a0,s0,-124
     61c:	53a000ef          	jal	b56 <wait>
      wait(&st2);
     620:	f9840513          	addi	a0,s0,-104
     624:	532000ef          	jal	b56 <wait>
      if(st1 != 0 || st2 != 0 || strcmp(buf, "hi\n") != 0){
     628:	f8442783          	lw	a5,-124(s0)
     62c:	f9842b83          	lw	s7,-104(s0)
     630:	0177eb33          	or	s6,a5,s7
     634:	180b1963          	bnez	s6,7c6 <go+0x752>
     638:	00001597          	auipc	a1,0x1
     63c:	de058593          	addi	a1,a1,-544 # 1418 <malloc+0x3de>
     640:	f8040513          	addi	a0,s0,-128
     644:	2ce000ef          	jal	912 <strcmp>
     648:	ac0501e3          	beqz	a0,10a <go+0x96>
     64c:	aab5                	j	7c8 <go+0x754>
        fprintf(2, "grind: pipe failed\n");
     64e:	00001597          	auipc	a1,0x1
     652:	c4a58593          	addi	a1,a1,-950 # 1298 <malloc+0x25e>
     656:	4509                	li	a0,2
     658:	105000ef          	jal	f5c <fprintf>
        exit(1);
     65c:	4505                	li	a0,1
     65e:	4f0000ef          	jal	b4e <exit>
        fprintf(2, "grind: pipe failed\n");
     662:	00001597          	auipc	a1,0x1
     666:	c3658593          	addi	a1,a1,-970 # 1298 <malloc+0x25e>
     66a:	4509                	li	a0,2
     66c:	0f1000ef          	jal	f5c <fprintf>
        exit(1);
     670:	4505                	li	a0,1
     672:	4dc000ef          	jal	b4e <exit>
        close(bb[0]);
     676:	f9042503          	lw	a0,-112(s0)
     67a:	4fc000ef          	jal	b76 <close>
        close(bb[1]);
     67e:	f9442503          	lw	a0,-108(s0)
     682:	4f4000ef          	jal	b76 <close>
        close(aa[0]);
     686:	f8842503          	lw	a0,-120(s0)
     68a:	4ec000ef          	jal	b76 <close>
        close(1);
     68e:	4505                	li	a0,1
     690:	4e6000ef          	jal	b76 <close>
        if(dup(aa[1]) != 1){
     694:	f8c42503          	lw	a0,-116(s0)
     698:	52e000ef          	jal	bc6 <dup>
     69c:	4785                	li	a5,1
     69e:	00f50c63          	beq	a0,a5,6b6 <go+0x642>
          fprintf(2, "grind: dup failed\n");
     6a2:	00001597          	auipc	a1,0x1
     6a6:	cfe58593          	addi	a1,a1,-770 # 13a0 <malloc+0x366>
     6aa:	4509                	li	a0,2
     6ac:	0b1000ef          	jal	f5c <fprintf>
          exit(1);
     6b0:	4505                	li	a0,1
     6b2:	49c000ef          	jal	b4e <exit>
        close(aa[1]);
     6b6:	f8c42503          	lw	a0,-116(s0)
     6ba:	4bc000ef          	jal	b76 <close>
        char *args[3] = { "echo", "hi", 0 };
     6be:	00001797          	auipc	a5,0x1
     6c2:	cfa78793          	addi	a5,a5,-774 # 13b8 <malloc+0x37e>
     6c6:	f8f43c23          	sd	a5,-104(s0)
     6ca:	00001797          	auipc	a5,0x1
     6ce:	cf678793          	addi	a5,a5,-778 # 13c0 <malloc+0x386>
     6d2:	faf43023          	sd	a5,-96(s0)
     6d6:	fa043423          	sd	zero,-88(s0)
        exec("grindir/../echo", args);
     6da:	f9840593          	addi	a1,s0,-104
     6de:	00001517          	auipc	a0,0x1
     6e2:	cea50513          	addi	a0,a0,-790 # 13c8 <malloc+0x38e>
     6e6:	4a0000ef          	jal	b86 <exec>
        fprintf(2, "grind: echo: not found\n");
     6ea:	00001597          	auipc	a1,0x1
     6ee:	cee58593          	addi	a1,a1,-786 # 13d8 <malloc+0x39e>
     6f2:	4509                	li	a0,2
     6f4:	069000ef          	jal	f5c <fprintf>
        exit(2);
     6f8:	4509                	li	a0,2
     6fa:	454000ef          	jal	b4e <exit>
        fprintf(2, "grind: fork failed\n");
     6fe:	00001597          	auipc	a1,0x1
     702:	b5258593          	addi	a1,a1,-1198 # 1250 <malloc+0x216>
     706:	4509                	li	a0,2
     708:	055000ef          	jal	f5c <fprintf>
        exit(3);
     70c:	450d                	li	a0,3
     70e:	440000ef          	jal	b4e <exit>
        close(aa[1]);
     712:	f8c42503          	lw	a0,-116(s0)
     716:	460000ef          	jal	b76 <close>
        close(bb[0]);
     71a:	f9042503          	lw	a0,-112(s0)
     71e:	458000ef          	jal	b76 <close>
        close(0);
     722:	4501                	li	a0,0
     724:	452000ef          	jal	b76 <close>
        if(dup(aa[0]) != 0){
     728:	f8842503          	lw	a0,-120(s0)
     72c:	49a000ef          	jal	bc6 <dup>
     730:	c919                	beqz	a0,746 <go+0x6d2>
          fprintf(2, "grind: dup failed\n");
     732:	00001597          	auipc	a1,0x1
     736:	c6e58593          	addi	a1,a1,-914 # 13a0 <malloc+0x366>
     73a:	4509                	li	a0,2
     73c:	021000ef          	jal	f5c <fprintf>
          exit(4);
     740:	4511                	li	a0,4
     742:	40c000ef          	jal	b4e <exit>
        close(aa[0]);
     746:	f8842503          	lw	a0,-120(s0)
     74a:	42c000ef          	jal	b76 <close>
        close(1);
     74e:	4505                	li	a0,1
     750:	426000ef          	jal	b76 <close>
        if(dup(bb[1]) != 1){
     754:	f9442503          	lw	a0,-108(s0)
     758:	46e000ef          	jal	bc6 <dup>
     75c:	4785                	li	a5,1
     75e:	00f50c63          	beq	a0,a5,776 <go+0x702>
          fprintf(2, "grind: dup failed\n");
     762:	00001597          	auipc	a1,0x1
     766:	c3e58593          	addi	a1,a1,-962 # 13a0 <malloc+0x366>
     76a:	4509                	li	a0,2
     76c:	7f0000ef          	jal	f5c <fprintf>
          exit(5);
     770:	4515                	li	a0,5
     772:	3dc000ef          	jal	b4e <exit>
        close(bb[1]);
     776:	f9442503          	lw	a0,-108(s0)
     77a:	3fc000ef          	jal	b76 <close>
        char *args[2] = { "cat", 0 };
     77e:	00001797          	auipc	a5,0x1
     782:	c7278793          	addi	a5,a5,-910 # 13f0 <malloc+0x3b6>
     786:	f8f43c23          	sd	a5,-104(s0)
     78a:	fa043023          	sd	zero,-96(s0)
        exec("/cat", args);
     78e:	f9840593          	addi	a1,s0,-104
     792:	00001517          	auipc	a0,0x1
     796:	c6650513          	addi	a0,a0,-922 # 13f8 <malloc+0x3be>
     79a:	3ec000ef          	jal	b86 <exec>
        fprintf(2, "grind: cat: not found\n");
     79e:	00001597          	auipc	a1,0x1
     7a2:	c6258593          	addi	a1,a1,-926 # 1400 <malloc+0x3c6>
     7a6:	4509                	li	a0,2
     7a8:	7b4000ef          	jal	f5c <fprintf>
        exit(6);
     7ac:	4519                	li	a0,6
     7ae:	3a0000ef          	jal	b4e <exit>
        fprintf(2, "grind: fork failed\n");
     7b2:	00001597          	auipc	a1,0x1
     7b6:	a9e58593          	addi	a1,a1,-1378 # 1250 <malloc+0x216>
     7ba:	4509                	li	a0,2
     7bc:	7a0000ef          	jal	f5c <fprintf>
        exit(7);
     7c0:	451d                	li	a0,7
     7c2:	38c000ef          	jal	b4e <exit>
     7c6:	8b3e                	mv	s6,a5
        printf("grind: exec pipeline failed %d %d \"%s\"\n", st1, st2, buf);
     7c8:	f8040693          	addi	a3,s0,-128
     7cc:	865e                	mv	a2,s7
     7ce:	85da                	mv	a1,s6
     7d0:	00001517          	auipc	a0,0x1
     7d4:	c5050513          	addi	a0,a0,-944 # 1420 <malloc+0x3e6>
     7d8:	7ae000ef          	jal	f86 <printf>
        exit(1);
     7dc:	4505                	li	a0,1
     7de:	370000ef          	jal	b4e <exit>

00000000000007e2 <iter>:
  }
}

void
iter()
{
     7e2:	7179                	addi	sp,sp,-48
     7e4:	f406                	sd	ra,40(sp)
     7e6:	f022                	sd	s0,32(sp)
     7e8:	1800                	addi	s0,sp,48
  unlink("a");
     7ea:	00001517          	auipc	a0,0x1
     7ee:	a7e50513          	addi	a0,a0,-1410 # 1268 <malloc+0x22e>
     7f2:	3ac000ef          	jal	b9e <unlink>
  unlink("b");
     7f6:	00001517          	auipc	a0,0x1
     7fa:	a2250513          	addi	a0,a0,-1502 # 1218 <malloc+0x1de>
     7fe:	3a0000ef          	jal	b9e <unlink>
  
  int pid1 = fork();
     802:	344000ef          	jal	b46 <fork>
  if(pid1 < 0){
     806:	02054163          	bltz	a0,828 <iter+0x46>
     80a:	ec26                	sd	s1,24(sp)
     80c:	84aa                	mv	s1,a0
    printf("grind: fork failed\n");
    exit(1);
  }
  if(pid1 == 0){
     80e:	e905                	bnez	a0,83e <iter+0x5c>
     810:	e84a                	sd	s2,16(sp)
    rand_next ^= 31;
     812:	00001717          	auipc	a4,0x1
     816:	7ee70713          	addi	a4,a4,2030 # 2000 <rand_next>
     81a:	631c                	ld	a5,0(a4)
     81c:	01f7c793          	xori	a5,a5,31
     820:	e31c                	sd	a5,0(a4)
    go(0);
     822:	4501                	li	a0,0
     824:	851ff0ef          	jal	74 <go>
     828:	ec26                	sd	s1,24(sp)
     82a:	e84a                	sd	s2,16(sp)
    printf("grind: fork failed\n");
     82c:	00001517          	auipc	a0,0x1
     830:	a2450513          	addi	a0,a0,-1500 # 1250 <malloc+0x216>
     834:	752000ef          	jal	f86 <printf>
    exit(1);
     838:	4505                	li	a0,1
     83a:	314000ef          	jal	b4e <exit>
     83e:	e84a                	sd	s2,16(sp)
    exit(0);
  }

  int pid2 = fork();
     840:	306000ef          	jal	b46 <fork>
     844:	892a                	mv	s2,a0
  if(pid2 < 0){
     846:	02054063          	bltz	a0,866 <iter+0x84>
    printf("grind: fork failed\n");
    exit(1);
  }
  if(pid2 == 0){
     84a:	e51d                	bnez	a0,878 <iter+0x96>
    rand_next ^= 7177;
     84c:	00001697          	auipc	a3,0x1
     850:	7b468693          	addi	a3,a3,1972 # 2000 <rand_next>
     854:	629c                	ld	a5,0(a3)
     856:	6709                	lui	a4,0x2
     858:	c0970713          	addi	a4,a4,-1015 # 1c09 <digits+0x759>
     85c:	8fb9                	xor	a5,a5,a4
     85e:	e29c                	sd	a5,0(a3)
    go(1);
     860:	4505                	li	a0,1
     862:	813ff0ef          	jal	74 <go>
    printf("grind: fork failed\n");
     866:	00001517          	auipc	a0,0x1
     86a:	9ea50513          	addi	a0,a0,-1558 # 1250 <malloc+0x216>
     86e:	718000ef          	jal	f86 <printf>
    exit(1);
     872:	4505                	li	a0,1
     874:	2da000ef          	jal	b4e <exit>
    exit(0);
  }

  int st1 = -1;
     878:	57fd                	li	a5,-1
     87a:	fcf42e23          	sw	a5,-36(s0)
  wait(&st1);
     87e:	fdc40513          	addi	a0,s0,-36
     882:	2d4000ef          	jal	b56 <wait>
  if(st1 != 0){
     886:	fdc42783          	lw	a5,-36(s0)
     88a:	eb99                	bnez	a5,8a0 <iter+0xbe>
    kill(pid1);
    kill(pid2);
  }
  int st2 = -1;
     88c:	57fd                	li	a5,-1
     88e:	fcf42c23          	sw	a5,-40(s0)
  wait(&st2);
     892:	fd840513          	addi	a0,s0,-40
     896:	2c0000ef          	jal	b56 <wait>

  exit(0);
     89a:	4501                	li	a0,0
     89c:	2b2000ef          	jal	b4e <exit>
    kill(pid1);
     8a0:	8526                	mv	a0,s1
     8a2:	2dc000ef          	jal	b7e <kill>
    kill(pid2);
     8a6:	854a                	mv	a0,s2
     8a8:	2d6000ef          	jal	b7e <kill>
     8ac:	b7c5                	j	88c <iter+0xaa>

00000000000008ae <main>:
}

int
main()
{
     8ae:	1101                	addi	sp,sp,-32
     8b0:	ec06                	sd	ra,24(sp)
     8b2:	e822                	sd	s0,16(sp)
     8b4:	e426                	sd	s1,8(sp)
     8b6:	1000                	addi	s0,sp,32
    }
    if(pid > 0){
      wait(0);
    }
    sleep(20);
    rand_next += 1;
     8b8:	00001497          	auipc	s1,0x1
     8bc:	74848493          	addi	s1,s1,1864 # 2000 <rand_next>
     8c0:	a809                	j	8d2 <main+0x24>
      iter();
     8c2:	f21ff0ef          	jal	7e2 <iter>
    sleep(20);
     8c6:	4551                	li	a0,20
     8c8:	316000ef          	jal	bde <sleep>
    rand_next += 1;
     8cc:	609c                	ld	a5,0(s1)
     8ce:	0785                	addi	a5,a5,1
     8d0:	e09c                	sd	a5,0(s1)
    int pid = fork();
     8d2:	274000ef          	jal	b46 <fork>
    if(pid == 0){
     8d6:	d575                	beqz	a0,8c2 <main+0x14>
    if(pid > 0){
     8d8:	fea057e3          	blez	a0,8c6 <main+0x18>
      wait(0);
     8dc:	4501                	li	a0,0
     8de:	278000ef          	jal	b56 <wait>
     8e2:	b7d5                	j	8c6 <main+0x18>

00000000000008e4 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
     8e4:	1141                	addi	sp,sp,-16
     8e6:	e406                	sd	ra,8(sp)
     8e8:	e022                	sd	s0,0(sp)
     8ea:	0800                	addi	s0,sp,16
  extern int main();
  main();
     8ec:	fc3ff0ef          	jal	8ae <main>
  exit(0);
     8f0:	4501                	li	a0,0
     8f2:	25c000ef          	jal	b4e <exit>

00000000000008f6 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
     8f6:	1141                	addi	sp,sp,-16
     8f8:	e422                	sd	s0,8(sp)
     8fa:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     8fc:	87aa                	mv	a5,a0
     8fe:	0585                	addi	a1,a1,1
     900:	0785                	addi	a5,a5,1
     902:	fff5c703          	lbu	a4,-1(a1)
     906:	fee78fa3          	sb	a4,-1(a5)
     90a:	fb75                	bnez	a4,8fe <strcpy+0x8>
    ;
  return os;
}
     90c:	6422                	ld	s0,8(sp)
     90e:	0141                	addi	sp,sp,16
     910:	8082                	ret

0000000000000912 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     912:	1141                	addi	sp,sp,-16
     914:	e422                	sd	s0,8(sp)
     916:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     918:	00054783          	lbu	a5,0(a0)
     91c:	cb91                	beqz	a5,930 <strcmp+0x1e>
     91e:	0005c703          	lbu	a4,0(a1)
     922:	00f71763          	bne	a4,a5,930 <strcmp+0x1e>
    p++, q++;
     926:	0505                	addi	a0,a0,1
     928:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     92a:	00054783          	lbu	a5,0(a0)
     92e:	fbe5                	bnez	a5,91e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     930:	0005c503          	lbu	a0,0(a1)
}
     934:	40a7853b          	subw	a0,a5,a0
     938:	6422                	ld	s0,8(sp)
     93a:	0141                	addi	sp,sp,16
     93c:	8082                	ret

000000000000093e <strlen>:

uint
strlen(const char *s)
{
     93e:	1141                	addi	sp,sp,-16
     940:	e422                	sd	s0,8(sp)
     942:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     944:	00054783          	lbu	a5,0(a0)
     948:	cf91                	beqz	a5,964 <strlen+0x26>
     94a:	0505                	addi	a0,a0,1
     94c:	87aa                	mv	a5,a0
     94e:	86be                	mv	a3,a5
     950:	0785                	addi	a5,a5,1
     952:	fff7c703          	lbu	a4,-1(a5)
     956:	ff65                	bnez	a4,94e <strlen+0x10>
     958:	40a6853b          	subw	a0,a3,a0
     95c:	2505                	addiw	a0,a0,1
    ;
  return n;
}
     95e:	6422                	ld	s0,8(sp)
     960:	0141                	addi	sp,sp,16
     962:	8082                	ret
  for(n = 0; s[n]; n++)
     964:	4501                	li	a0,0
     966:	bfe5                	j	95e <strlen+0x20>

0000000000000968 <memset>:

void*
memset(void *dst, int c, uint n)
{
     968:	1141                	addi	sp,sp,-16
     96a:	e422                	sd	s0,8(sp)
     96c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     96e:	ca19                	beqz	a2,984 <memset+0x1c>
     970:	87aa                	mv	a5,a0
     972:	1602                	slli	a2,a2,0x20
     974:	9201                	srli	a2,a2,0x20
     976:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     97a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     97e:	0785                	addi	a5,a5,1
     980:	fee79de3          	bne	a5,a4,97a <memset+0x12>
  }
  return dst;
}
     984:	6422                	ld	s0,8(sp)
     986:	0141                	addi	sp,sp,16
     988:	8082                	ret

000000000000098a <strchr>:

char*
strchr(const char *s, char c)
{
     98a:	1141                	addi	sp,sp,-16
     98c:	e422                	sd	s0,8(sp)
     98e:	0800                	addi	s0,sp,16
  for(; *s; s++)
     990:	00054783          	lbu	a5,0(a0)
     994:	cb99                	beqz	a5,9aa <strchr+0x20>
    if(*s == c)
     996:	00f58763          	beq	a1,a5,9a4 <strchr+0x1a>
  for(; *s; s++)
     99a:	0505                	addi	a0,a0,1
     99c:	00054783          	lbu	a5,0(a0)
     9a0:	fbfd                	bnez	a5,996 <strchr+0xc>
      return (char*)s;
  return 0;
     9a2:	4501                	li	a0,0
}
     9a4:	6422                	ld	s0,8(sp)
     9a6:	0141                	addi	sp,sp,16
     9a8:	8082                	ret
  return 0;
     9aa:	4501                	li	a0,0
     9ac:	bfe5                	j	9a4 <strchr+0x1a>

00000000000009ae <gets>:

char*
gets(char *buf, int max)
{
     9ae:	711d                	addi	sp,sp,-96
     9b0:	ec86                	sd	ra,88(sp)
     9b2:	e8a2                	sd	s0,80(sp)
     9b4:	e4a6                	sd	s1,72(sp)
     9b6:	e0ca                	sd	s2,64(sp)
     9b8:	fc4e                	sd	s3,56(sp)
     9ba:	f852                	sd	s4,48(sp)
     9bc:	f456                	sd	s5,40(sp)
     9be:	f05a                	sd	s6,32(sp)
     9c0:	ec5e                	sd	s7,24(sp)
     9c2:	1080                	addi	s0,sp,96
     9c4:	8baa                	mv	s7,a0
     9c6:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     9c8:	892a                	mv	s2,a0
     9ca:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     9cc:	4aa9                	li	s5,10
     9ce:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     9d0:	89a6                	mv	s3,s1
     9d2:	2485                	addiw	s1,s1,1
     9d4:	0344d663          	bge	s1,s4,a00 <gets+0x52>
    cc = read(0, &c, 1);
     9d8:	4605                	li	a2,1
     9da:	faf40593          	addi	a1,s0,-81
     9de:	4501                	li	a0,0
     9e0:	186000ef          	jal	b66 <read>
    if(cc < 1)
     9e4:	00a05e63          	blez	a0,a00 <gets+0x52>
    buf[i++] = c;
     9e8:	faf44783          	lbu	a5,-81(s0)
     9ec:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     9f0:	01578763          	beq	a5,s5,9fe <gets+0x50>
     9f4:	0905                	addi	s2,s2,1
     9f6:	fd679de3          	bne	a5,s6,9d0 <gets+0x22>
    buf[i++] = c;
     9fa:	89a6                	mv	s3,s1
     9fc:	a011                	j	a00 <gets+0x52>
     9fe:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     a00:	99de                	add	s3,s3,s7
     a02:	00098023          	sb	zero,0(s3)
  return buf;
}
     a06:	855e                	mv	a0,s7
     a08:	60e6                	ld	ra,88(sp)
     a0a:	6446                	ld	s0,80(sp)
     a0c:	64a6                	ld	s1,72(sp)
     a0e:	6906                	ld	s2,64(sp)
     a10:	79e2                	ld	s3,56(sp)
     a12:	7a42                	ld	s4,48(sp)
     a14:	7aa2                	ld	s5,40(sp)
     a16:	7b02                	ld	s6,32(sp)
     a18:	6be2                	ld	s7,24(sp)
     a1a:	6125                	addi	sp,sp,96
     a1c:	8082                	ret

0000000000000a1e <stat>:

int
stat(const char *n, struct stat *st)
{
     a1e:	1101                	addi	sp,sp,-32
     a20:	ec06                	sd	ra,24(sp)
     a22:	e822                	sd	s0,16(sp)
     a24:	e04a                	sd	s2,0(sp)
     a26:	1000                	addi	s0,sp,32
     a28:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     a2a:	4581                	li	a1,0
     a2c:	162000ef          	jal	b8e <open>
  if(fd < 0)
     a30:	02054263          	bltz	a0,a54 <stat+0x36>
     a34:	e426                	sd	s1,8(sp)
     a36:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     a38:	85ca                	mv	a1,s2
     a3a:	16c000ef          	jal	ba6 <fstat>
     a3e:	892a                	mv	s2,a0
  close(fd);
     a40:	8526                	mv	a0,s1
     a42:	134000ef          	jal	b76 <close>
  return r;
     a46:	64a2                	ld	s1,8(sp)
}
     a48:	854a                	mv	a0,s2
     a4a:	60e2                	ld	ra,24(sp)
     a4c:	6442                	ld	s0,16(sp)
     a4e:	6902                	ld	s2,0(sp)
     a50:	6105                	addi	sp,sp,32
     a52:	8082                	ret
    return -1;
     a54:	597d                	li	s2,-1
     a56:	bfcd                	j	a48 <stat+0x2a>

0000000000000a58 <atoi>:

int
atoi(const char *s)
{
     a58:	1141                	addi	sp,sp,-16
     a5a:	e422                	sd	s0,8(sp)
     a5c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     a5e:	00054683          	lbu	a3,0(a0)
     a62:	fd06879b          	addiw	a5,a3,-48
     a66:	0ff7f793          	zext.b	a5,a5
     a6a:	4625                	li	a2,9
     a6c:	02f66863          	bltu	a2,a5,a9c <atoi+0x44>
     a70:	872a                	mv	a4,a0
  n = 0;
     a72:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
     a74:	0705                	addi	a4,a4,1
     a76:	0025179b          	slliw	a5,a0,0x2
     a7a:	9fa9                	addw	a5,a5,a0
     a7c:	0017979b          	slliw	a5,a5,0x1
     a80:	9fb5                	addw	a5,a5,a3
     a82:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     a86:	00074683          	lbu	a3,0(a4)
     a8a:	fd06879b          	addiw	a5,a3,-48
     a8e:	0ff7f793          	zext.b	a5,a5
     a92:	fef671e3          	bgeu	a2,a5,a74 <atoi+0x1c>
  return n;
}
     a96:	6422                	ld	s0,8(sp)
     a98:	0141                	addi	sp,sp,16
     a9a:	8082                	ret
  n = 0;
     a9c:	4501                	li	a0,0
     a9e:	bfe5                	j	a96 <atoi+0x3e>

0000000000000aa0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     aa0:	1141                	addi	sp,sp,-16
     aa2:	e422                	sd	s0,8(sp)
     aa4:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     aa6:	02b57463          	bgeu	a0,a1,ace <memmove+0x2e>
    while(n-- > 0)
     aaa:	00c05f63          	blez	a2,ac8 <memmove+0x28>
     aae:	1602                	slli	a2,a2,0x20
     ab0:	9201                	srli	a2,a2,0x20
     ab2:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     ab6:	872a                	mv	a4,a0
      *dst++ = *src++;
     ab8:	0585                	addi	a1,a1,1
     aba:	0705                	addi	a4,a4,1
     abc:	fff5c683          	lbu	a3,-1(a1)
     ac0:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     ac4:	fef71ae3          	bne	a4,a5,ab8 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     ac8:	6422                	ld	s0,8(sp)
     aca:	0141                	addi	sp,sp,16
     acc:	8082                	ret
    dst += n;
     ace:	00c50733          	add	a4,a0,a2
    src += n;
     ad2:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     ad4:	fec05ae3          	blez	a2,ac8 <memmove+0x28>
     ad8:	fff6079b          	addiw	a5,a2,-1
     adc:	1782                	slli	a5,a5,0x20
     ade:	9381                	srli	a5,a5,0x20
     ae0:	fff7c793          	not	a5,a5
     ae4:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     ae6:	15fd                	addi	a1,a1,-1
     ae8:	177d                	addi	a4,a4,-1
     aea:	0005c683          	lbu	a3,0(a1)
     aee:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     af2:	fee79ae3          	bne	a5,a4,ae6 <memmove+0x46>
     af6:	bfc9                	j	ac8 <memmove+0x28>

0000000000000af8 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     af8:	1141                	addi	sp,sp,-16
     afa:	e422                	sd	s0,8(sp)
     afc:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     afe:	ca05                	beqz	a2,b2e <memcmp+0x36>
     b00:	fff6069b          	addiw	a3,a2,-1
     b04:	1682                	slli	a3,a3,0x20
     b06:	9281                	srli	a3,a3,0x20
     b08:	0685                	addi	a3,a3,1
     b0a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     b0c:	00054783          	lbu	a5,0(a0)
     b10:	0005c703          	lbu	a4,0(a1)
     b14:	00e79863          	bne	a5,a4,b24 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     b18:	0505                	addi	a0,a0,1
    p2++;
     b1a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     b1c:	fed518e3          	bne	a0,a3,b0c <memcmp+0x14>
  }
  return 0;
     b20:	4501                	li	a0,0
     b22:	a019                	j	b28 <memcmp+0x30>
      return *p1 - *p2;
     b24:	40e7853b          	subw	a0,a5,a4
}
     b28:	6422                	ld	s0,8(sp)
     b2a:	0141                	addi	sp,sp,16
     b2c:	8082                	ret
  return 0;
     b2e:	4501                	li	a0,0
     b30:	bfe5                	j	b28 <memcmp+0x30>

0000000000000b32 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     b32:	1141                	addi	sp,sp,-16
     b34:	e406                	sd	ra,8(sp)
     b36:	e022                	sd	s0,0(sp)
     b38:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     b3a:	f67ff0ef          	jal	aa0 <memmove>
}
     b3e:	60a2                	ld	ra,8(sp)
     b40:	6402                	ld	s0,0(sp)
     b42:	0141                	addi	sp,sp,16
     b44:	8082                	ret

0000000000000b46 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     b46:	4885                	li	a7,1
 ecall
     b48:	00000073          	ecall
 ret
     b4c:	8082                	ret

0000000000000b4e <exit>:
.global exit
exit:
 li a7, SYS_exit
     b4e:	4889                	li	a7,2
 ecall
     b50:	00000073          	ecall
 ret
     b54:	8082                	ret

0000000000000b56 <wait>:
.global wait
wait:
 li a7, SYS_wait
     b56:	488d                	li	a7,3
 ecall
     b58:	00000073          	ecall
 ret
     b5c:	8082                	ret

0000000000000b5e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     b5e:	4891                	li	a7,4
 ecall
     b60:	00000073          	ecall
 ret
     b64:	8082                	ret

0000000000000b66 <read>:
.global read
read:
 li a7, SYS_read
     b66:	4895                	li	a7,5
 ecall
     b68:	00000073          	ecall
 ret
     b6c:	8082                	ret

0000000000000b6e <write>:
.global write
write:
 li a7, SYS_write
     b6e:	48c1                	li	a7,16
 ecall
     b70:	00000073          	ecall
 ret
     b74:	8082                	ret

0000000000000b76 <close>:
.global close
close:
 li a7, SYS_close
     b76:	48d5                	li	a7,21
 ecall
     b78:	00000073          	ecall
 ret
     b7c:	8082                	ret

0000000000000b7e <kill>:
.global kill
kill:
 li a7, SYS_kill
     b7e:	4899                	li	a7,6
 ecall
     b80:	00000073          	ecall
 ret
     b84:	8082                	ret

0000000000000b86 <exec>:
.global exec
exec:
 li a7, SYS_exec
     b86:	489d                	li	a7,7
 ecall
     b88:	00000073          	ecall
 ret
     b8c:	8082                	ret

0000000000000b8e <open>:
.global open
open:
 li a7, SYS_open
     b8e:	48bd                	li	a7,15
 ecall
     b90:	00000073          	ecall
 ret
     b94:	8082                	ret

0000000000000b96 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     b96:	48c5                	li	a7,17
 ecall
     b98:	00000073          	ecall
 ret
     b9c:	8082                	ret

0000000000000b9e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     b9e:	48c9                	li	a7,18
 ecall
     ba0:	00000073          	ecall
 ret
     ba4:	8082                	ret

0000000000000ba6 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     ba6:	48a1                	li	a7,8
 ecall
     ba8:	00000073          	ecall
 ret
     bac:	8082                	ret

0000000000000bae <link>:
.global link
link:
 li a7, SYS_link
     bae:	48cd                	li	a7,19
 ecall
     bb0:	00000073          	ecall
 ret
     bb4:	8082                	ret

0000000000000bb6 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     bb6:	48d1                	li	a7,20
 ecall
     bb8:	00000073          	ecall
 ret
     bbc:	8082                	ret

0000000000000bbe <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     bbe:	48a5                	li	a7,9
 ecall
     bc0:	00000073          	ecall
 ret
     bc4:	8082                	ret

0000000000000bc6 <dup>:
.global dup
dup:
 li a7, SYS_dup
     bc6:	48a9                	li	a7,10
 ecall
     bc8:	00000073          	ecall
 ret
     bcc:	8082                	ret

0000000000000bce <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     bce:	48ad                	li	a7,11
 ecall
     bd0:	00000073          	ecall
 ret
     bd4:	8082                	ret

0000000000000bd6 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     bd6:	48b1                	li	a7,12
 ecall
     bd8:	00000073          	ecall
 ret
     bdc:	8082                	ret

0000000000000bde <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     bde:	48b5                	li	a7,13
 ecall
     be0:	00000073          	ecall
 ret
     be4:	8082                	ret

0000000000000be6 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     be6:	48b9                	li	a7,14
 ecall
     be8:	00000073          	ecall
 ret
     bec:	8082                	ret

0000000000000bee <trigger>:
.global trigger
trigger:
 li a7, SYS_trigger
     bee:	48d9                	li	a7,22
 ecall
     bf0:	00000073          	ecall
 ret
     bf4:	8082                	ret

0000000000000bf6 <thread>:
.global thread
thread:
 li a7, SYS_thread
     bf6:	48dd                	li	a7,23
 ecall
     bf8:	00000073          	ecall
 ret
     bfc:	8082                	ret

0000000000000bfe <jointhread>:
.global jointhread
jointhread:
 li a7, SYS_jointhread
     bfe:	48e1                	li	a7,24
 ecall
     c00:	00000073          	ecall
 ret
     c04:	8082                	ret

0000000000000c06 <yield>:
.global yield
yield:
 li a7, SYS_yield
     c06:	48e5                	li	a7,25
 ecall
     c08:	00000073          	ecall
 ret
     c0c:	8082                	ret

0000000000000c0e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     c0e:	1101                	addi	sp,sp,-32
     c10:	ec06                	sd	ra,24(sp)
     c12:	e822                	sd	s0,16(sp)
     c14:	1000                	addi	s0,sp,32
     c16:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     c1a:	4605                	li	a2,1
     c1c:	fef40593          	addi	a1,s0,-17
     c20:	f4fff0ef          	jal	b6e <write>
}
     c24:	60e2                	ld	ra,24(sp)
     c26:	6442                	ld	s0,16(sp)
     c28:	6105                	addi	sp,sp,32
     c2a:	8082                	ret

0000000000000c2c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     c2c:	7139                	addi	sp,sp,-64
     c2e:	fc06                	sd	ra,56(sp)
     c30:	f822                	sd	s0,48(sp)
     c32:	f426                	sd	s1,40(sp)
     c34:	0080                	addi	s0,sp,64
     c36:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
     c38:	c299                	beqz	a3,c3e <printint+0x12>
     c3a:	0805c963          	bltz	a1,ccc <printint+0xa0>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
     c3e:	2581                	sext.w	a1,a1
  neg = 0;
     c40:	4881                	li	a7,0
     c42:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
     c46:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
     c48:	2601                	sext.w	a2,a2
     c4a:	00001517          	auipc	a0,0x1
     c4e:	86650513          	addi	a0,a0,-1946 # 14b0 <digits>
     c52:	883a                	mv	a6,a4
     c54:	2705                	addiw	a4,a4,1
     c56:	02c5f7bb          	remuw	a5,a1,a2
     c5a:	1782                	slli	a5,a5,0x20
     c5c:	9381                	srli	a5,a5,0x20
     c5e:	97aa                	add	a5,a5,a0
     c60:	0007c783          	lbu	a5,0(a5)
     c64:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
     c68:	0005879b          	sext.w	a5,a1
     c6c:	02c5d5bb          	divuw	a1,a1,a2
     c70:	0685                	addi	a3,a3,1
     c72:	fec7f0e3          	bgeu	a5,a2,c52 <printint+0x26>
  if(neg)
     c76:	00088c63          	beqz	a7,c8e <printint+0x62>
    buf[i++] = '-';
     c7a:	fd070793          	addi	a5,a4,-48
     c7e:	00878733          	add	a4,a5,s0
     c82:	02d00793          	li	a5,45
     c86:	fef70823          	sb	a5,-16(a4)
     c8a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
     c8e:	02e05a63          	blez	a4,cc2 <printint+0x96>
     c92:	f04a                	sd	s2,32(sp)
     c94:	ec4e                	sd	s3,24(sp)
     c96:	fc040793          	addi	a5,s0,-64
     c9a:	00e78933          	add	s2,a5,a4
     c9e:	fff78993          	addi	s3,a5,-1
     ca2:	99ba                	add	s3,s3,a4
     ca4:	377d                	addiw	a4,a4,-1
     ca6:	1702                	slli	a4,a4,0x20
     ca8:	9301                	srli	a4,a4,0x20
     caa:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
     cae:	fff94583          	lbu	a1,-1(s2)
     cb2:	8526                	mv	a0,s1
     cb4:	f5bff0ef          	jal	c0e <putc>
  while(--i >= 0)
     cb8:	197d                	addi	s2,s2,-1
     cba:	ff391ae3          	bne	s2,s3,cae <printint+0x82>
     cbe:	7902                	ld	s2,32(sp)
     cc0:	69e2                	ld	s3,24(sp)
}
     cc2:	70e2                	ld	ra,56(sp)
     cc4:	7442                	ld	s0,48(sp)
     cc6:	74a2                	ld	s1,40(sp)
     cc8:	6121                	addi	sp,sp,64
     cca:	8082                	ret
    x = -xx;
     ccc:	40b005bb          	negw	a1,a1
    neg = 1;
     cd0:	4885                	li	a7,1
    x = -xx;
     cd2:	bf85                	j	c42 <printint+0x16>

0000000000000cd4 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
     cd4:	711d                	addi	sp,sp,-96
     cd6:	ec86                	sd	ra,88(sp)
     cd8:	e8a2                	sd	s0,80(sp)
     cda:	e0ca                	sd	s2,64(sp)
     cdc:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
     cde:	0005c903          	lbu	s2,0(a1)
     ce2:	26090863          	beqz	s2,f52 <vprintf+0x27e>
     ce6:	e4a6                	sd	s1,72(sp)
     ce8:	fc4e                	sd	s3,56(sp)
     cea:	f852                	sd	s4,48(sp)
     cec:	f456                	sd	s5,40(sp)
     cee:	f05a                	sd	s6,32(sp)
     cf0:	ec5e                	sd	s7,24(sp)
     cf2:	e862                	sd	s8,16(sp)
     cf4:	e466                	sd	s9,8(sp)
     cf6:	8b2a                	mv	s6,a0
     cf8:	8a2e                	mv	s4,a1
     cfa:	8bb2                	mv	s7,a2
  state = 0;
     cfc:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
     cfe:	4481                	li	s1,0
     d00:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
     d02:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
     d06:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
     d0a:	06c00c93          	li	s9,108
     d0e:	a005                	j	d2e <vprintf+0x5a>
        putc(fd, c0);
     d10:	85ca                	mv	a1,s2
     d12:	855a                	mv	a0,s6
     d14:	efbff0ef          	jal	c0e <putc>
     d18:	a019                	j	d1e <vprintf+0x4a>
    } else if(state == '%'){
     d1a:	03598263          	beq	s3,s5,d3e <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
     d1e:	2485                	addiw	s1,s1,1
     d20:	8726                	mv	a4,s1
     d22:	009a07b3          	add	a5,s4,s1
     d26:	0007c903          	lbu	s2,0(a5)
     d2a:	20090c63          	beqz	s2,f42 <vprintf+0x26e>
    c0 = fmt[i] & 0xff;
     d2e:	0009079b          	sext.w	a5,s2
    if(state == 0){
     d32:	fe0994e3          	bnez	s3,d1a <vprintf+0x46>
      if(c0 == '%'){
     d36:	fd579de3          	bne	a5,s5,d10 <vprintf+0x3c>
        state = '%';
     d3a:	89be                	mv	s3,a5
     d3c:	b7cd                	j	d1e <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
     d3e:	00ea06b3          	add	a3,s4,a4
     d42:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
     d46:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
     d48:	c681                	beqz	a3,d50 <vprintf+0x7c>
     d4a:	9752                	add	a4,a4,s4
     d4c:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
     d50:	03878f63          	beq	a5,s8,d8e <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
     d54:	05978963          	beq	a5,s9,da6 <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
     d58:	07500713          	li	a4,117
     d5c:	0ee78363          	beq	a5,a4,e42 <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
     d60:	07800713          	li	a4,120
     d64:	12e78563          	beq	a5,a4,e8e <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
     d68:	07000713          	li	a4,112
     d6c:	14e78a63          	beq	a5,a4,ec0 <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
     d70:	07300713          	li	a4,115
     d74:	18e78a63          	beq	a5,a4,f08 <vprintf+0x234>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
     d78:	02500713          	li	a4,37
     d7c:	04e79563          	bne	a5,a4,dc6 <vprintf+0xf2>
        putc(fd, '%');
     d80:	02500593          	li	a1,37
     d84:	855a                	mv	a0,s6
     d86:	e89ff0ef          	jal	c0e <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
     d8a:	4981                	li	s3,0
     d8c:	bf49                	j	d1e <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
     d8e:	008b8913          	addi	s2,s7,8
     d92:	4685                	li	a3,1
     d94:	4629                	li	a2,10
     d96:	000ba583          	lw	a1,0(s7)
     d9a:	855a                	mv	a0,s6
     d9c:	e91ff0ef          	jal	c2c <printint>
     da0:	8bca                	mv	s7,s2
      state = 0;
     da2:	4981                	li	s3,0
     da4:	bfad                	j	d1e <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
     da6:	06400793          	li	a5,100
     daa:	02f68963          	beq	a3,a5,ddc <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
     dae:	06c00793          	li	a5,108
     db2:	04f68263          	beq	a3,a5,df6 <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
     db6:	07500793          	li	a5,117
     dba:	0af68063          	beq	a3,a5,e5a <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
     dbe:	07800793          	li	a5,120
     dc2:	0ef68263          	beq	a3,a5,ea6 <vprintf+0x1d2>
        putc(fd, '%');
     dc6:	02500593          	li	a1,37
     dca:	855a                	mv	a0,s6
     dcc:	e43ff0ef          	jal	c0e <putc>
        putc(fd, c0);
     dd0:	85ca                	mv	a1,s2
     dd2:	855a                	mv	a0,s6
     dd4:	e3bff0ef          	jal	c0e <putc>
      state = 0;
     dd8:	4981                	li	s3,0
     dda:	b791                	j	d1e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
     ddc:	008b8913          	addi	s2,s7,8
     de0:	4685                	li	a3,1
     de2:	4629                	li	a2,10
     de4:	000ba583          	lw	a1,0(s7)
     de8:	855a                	mv	a0,s6
     dea:	e43ff0ef          	jal	c2c <printint>
        i += 1;
     dee:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
     df0:	8bca                	mv	s7,s2
      state = 0;
     df2:	4981                	li	s3,0
        i += 1;
     df4:	b72d                	j	d1e <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
     df6:	06400793          	li	a5,100
     dfa:	02f60763          	beq	a2,a5,e28 <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
     dfe:	07500793          	li	a5,117
     e02:	06f60963          	beq	a2,a5,e74 <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
     e06:	07800793          	li	a5,120
     e0a:	faf61ee3          	bne	a2,a5,dc6 <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
     e0e:	008b8913          	addi	s2,s7,8
     e12:	4681                	li	a3,0
     e14:	4641                	li	a2,16
     e16:	000ba583          	lw	a1,0(s7)
     e1a:	855a                	mv	a0,s6
     e1c:	e11ff0ef          	jal	c2c <printint>
        i += 2;
     e20:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
     e22:	8bca                	mv	s7,s2
      state = 0;
     e24:	4981                	li	s3,0
        i += 2;
     e26:	bde5                	j	d1e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
     e28:	008b8913          	addi	s2,s7,8
     e2c:	4685                	li	a3,1
     e2e:	4629                	li	a2,10
     e30:	000ba583          	lw	a1,0(s7)
     e34:	855a                	mv	a0,s6
     e36:	df7ff0ef          	jal	c2c <printint>
        i += 2;
     e3a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
     e3c:	8bca                	mv	s7,s2
      state = 0;
     e3e:	4981                	li	s3,0
        i += 2;
     e40:	bdf9                	j	d1e <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
     e42:	008b8913          	addi	s2,s7,8
     e46:	4681                	li	a3,0
     e48:	4629                	li	a2,10
     e4a:	000ba583          	lw	a1,0(s7)
     e4e:	855a                	mv	a0,s6
     e50:	dddff0ef          	jal	c2c <printint>
     e54:	8bca                	mv	s7,s2
      state = 0;
     e56:	4981                	li	s3,0
     e58:	b5d9                	j	d1e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
     e5a:	008b8913          	addi	s2,s7,8
     e5e:	4681                	li	a3,0
     e60:	4629                	li	a2,10
     e62:	000ba583          	lw	a1,0(s7)
     e66:	855a                	mv	a0,s6
     e68:	dc5ff0ef          	jal	c2c <printint>
        i += 1;
     e6c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
     e6e:	8bca                	mv	s7,s2
      state = 0;
     e70:	4981                	li	s3,0
        i += 1;
     e72:	b575                	j	d1e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
     e74:	008b8913          	addi	s2,s7,8
     e78:	4681                	li	a3,0
     e7a:	4629                	li	a2,10
     e7c:	000ba583          	lw	a1,0(s7)
     e80:	855a                	mv	a0,s6
     e82:	dabff0ef          	jal	c2c <printint>
        i += 2;
     e86:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
     e88:	8bca                	mv	s7,s2
      state = 0;
     e8a:	4981                	li	s3,0
        i += 2;
     e8c:	bd49                	j	d1e <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
     e8e:	008b8913          	addi	s2,s7,8
     e92:	4681                	li	a3,0
     e94:	4641                	li	a2,16
     e96:	000ba583          	lw	a1,0(s7)
     e9a:	855a                	mv	a0,s6
     e9c:	d91ff0ef          	jal	c2c <printint>
     ea0:	8bca                	mv	s7,s2
      state = 0;
     ea2:	4981                	li	s3,0
     ea4:	bdad                	j	d1e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
     ea6:	008b8913          	addi	s2,s7,8
     eaa:	4681                	li	a3,0
     eac:	4641                	li	a2,16
     eae:	000ba583          	lw	a1,0(s7)
     eb2:	855a                	mv	a0,s6
     eb4:	d79ff0ef          	jal	c2c <printint>
        i += 1;
     eb8:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
     eba:	8bca                	mv	s7,s2
      state = 0;
     ebc:	4981                	li	s3,0
        i += 1;
     ebe:	b585                	j	d1e <vprintf+0x4a>
     ec0:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
     ec2:	008b8d13          	addi	s10,s7,8
     ec6:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
     eca:	03000593          	li	a1,48
     ece:	855a                	mv	a0,s6
     ed0:	d3fff0ef          	jal	c0e <putc>
  putc(fd, 'x');
     ed4:	07800593          	li	a1,120
     ed8:	855a                	mv	a0,s6
     eda:	d35ff0ef          	jal	c0e <putc>
     ede:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
     ee0:	00000b97          	auipc	s7,0x0
     ee4:	5d0b8b93          	addi	s7,s7,1488 # 14b0 <digits>
     ee8:	03c9d793          	srli	a5,s3,0x3c
     eec:	97de                	add	a5,a5,s7
     eee:	0007c583          	lbu	a1,0(a5)
     ef2:	855a                	mv	a0,s6
     ef4:	d1bff0ef          	jal	c0e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
     ef8:	0992                	slli	s3,s3,0x4
     efa:	397d                	addiw	s2,s2,-1
     efc:	fe0916e3          	bnez	s2,ee8 <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
     f00:	8bea                	mv	s7,s10
      state = 0;
     f02:	4981                	li	s3,0
     f04:	6d02                	ld	s10,0(sp)
     f06:	bd21                	j	d1e <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
     f08:	008b8993          	addi	s3,s7,8
     f0c:	000bb903          	ld	s2,0(s7)
     f10:	00090f63          	beqz	s2,f2e <vprintf+0x25a>
        for(; *s; s++)
     f14:	00094583          	lbu	a1,0(s2)
     f18:	c195                	beqz	a1,f3c <vprintf+0x268>
          putc(fd, *s);
     f1a:	855a                	mv	a0,s6
     f1c:	cf3ff0ef          	jal	c0e <putc>
        for(; *s; s++)
     f20:	0905                	addi	s2,s2,1
     f22:	00094583          	lbu	a1,0(s2)
     f26:	f9f5                	bnez	a1,f1a <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
     f28:	8bce                	mv	s7,s3
      state = 0;
     f2a:	4981                	li	s3,0
     f2c:	bbcd                	j	d1e <vprintf+0x4a>
          s = "(null)";
     f2e:	00000917          	auipc	s2,0x0
     f32:	51a90913          	addi	s2,s2,1306 # 1448 <malloc+0x40e>
        for(; *s; s++)
     f36:	02800593          	li	a1,40
     f3a:	b7c5                	j	f1a <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
     f3c:	8bce                	mv	s7,s3
      state = 0;
     f3e:	4981                	li	s3,0
     f40:	bbf9                	j	d1e <vprintf+0x4a>
     f42:	64a6                	ld	s1,72(sp)
     f44:	79e2                	ld	s3,56(sp)
     f46:	7a42                	ld	s4,48(sp)
     f48:	7aa2                	ld	s5,40(sp)
     f4a:	7b02                	ld	s6,32(sp)
     f4c:	6be2                	ld	s7,24(sp)
     f4e:	6c42                	ld	s8,16(sp)
     f50:	6ca2                	ld	s9,8(sp)
    }
  }
}
     f52:	60e6                	ld	ra,88(sp)
     f54:	6446                	ld	s0,80(sp)
     f56:	6906                	ld	s2,64(sp)
     f58:	6125                	addi	sp,sp,96
     f5a:	8082                	ret

0000000000000f5c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
     f5c:	715d                	addi	sp,sp,-80
     f5e:	ec06                	sd	ra,24(sp)
     f60:	e822                	sd	s0,16(sp)
     f62:	1000                	addi	s0,sp,32
     f64:	e010                	sd	a2,0(s0)
     f66:	e414                	sd	a3,8(s0)
     f68:	e818                	sd	a4,16(s0)
     f6a:	ec1c                	sd	a5,24(s0)
     f6c:	03043023          	sd	a6,32(s0)
     f70:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
     f74:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
     f78:	8622                	mv	a2,s0
     f7a:	d5bff0ef          	jal	cd4 <vprintf>
}
     f7e:	60e2                	ld	ra,24(sp)
     f80:	6442                	ld	s0,16(sp)
     f82:	6161                	addi	sp,sp,80
     f84:	8082                	ret

0000000000000f86 <printf>:

void
printf(const char *fmt, ...)
{
     f86:	711d                	addi	sp,sp,-96
     f88:	ec06                	sd	ra,24(sp)
     f8a:	e822                	sd	s0,16(sp)
     f8c:	1000                	addi	s0,sp,32
     f8e:	e40c                	sd	a1,8(s0)
     f90:	e810                	sd	a2,16(s0)
     f92:	ec14                	sd	a3,24(s0)
     f94:	f018                	sd	a4,32(s0)
     f96:	f41c                	sd	a5,40(s0)
     f98:	03043823          	sd	a6,48(s0)
     f9c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
     fa0:	00840613          	addi	a2,s0,8
     fa4:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
     fa8:	85aa                	mv	a1,a0
     faa:	4505                	li	a0,1
     fac:	d29ff0ef          	jal	cd4 <vprintf>
}
     fb0:	60e2                	ld	ra,24(sp)
     fb2:	6442                	ld	s0,16(sp)
     fb4:	6125                	addi	sp,sp,96
     fb6:	8082                	ret

0000000000000fb8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
     fb8:	1141                	addi	sp,sp,-16
     fba:	e422                	sd	s0,8(sp)
     fbc:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
     fbe:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
     fc2:	00001797          	auipc	a5,0x1
     fc6:	04e7b783          	ld	a5,78(a5) # 2010 <freep>
     fca:	a02d                	j	ff4 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
     fcc:	4618                	lw	a4,8(a2)
     fce:	9f2d                	addw	a4,a4,a1
     fd0:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
     fd4:	6398                	ld	a4,0(a5)
     fd6:	6310                	ld	a2,0(a4)
     fd8:	a83d                	j	1016 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
     fda:	ff852703          	lw	a4,-8(a0)
     fde:	9f31                	addw	a4,a4,a2
     fe0:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
     fe2:	ff053683          	ld	a3,-16(a0)
     fe6:	a091                	j	102a <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
     fe8:	6398                	ld	a4,0(a5)
     fea:	00e7e463          	bltu	a5,a4,ff2 <free+0x3a>
     fee:	00e6ea63          	bltu	a3,a4,1002 <free+0x4a>
{
     ff2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
     ff4:	fed7fae3          	bgeu	a5,a3,fe8 <free+0x30>
     ff8:	6398                	ld	a4,0(a5)
     ffa:	00e6e463          	bltu	a3,a4,1002 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
     ffe:	fee7eae3          	bltu	a5,a4,ff2 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
    1002:	ff852583          	lw	a1,-8(a0)
    1006:	6390                	ld	a2,0(a5)
    1008:	02059813          	slli	a6,a1,0x20
    100c:	01c85713          	srli	a4,a6,0x1c
    1010:	9736                	add	a4,a4,a3
    1012:	fae60de3          	beq	a2,a4,fcc <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
    1016:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    101a:	4790                	lw	a2,8(a5)
    101c:	02061593          	slli	a1,a2,0x20
    1020:	01c5d713          	srli	a4,a1,0x1c
    1024:	973e                	add	a4,a4,a5
    1026:	fae68ae3          	beq	a3,a4,fda <free+0x22>
    p->s.ptr = bp->s.ptr;
    102a:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    102c:	00001717          	auipc	a4,0x1
    1030:	fef73223          	sd	a5,-28(a4) # 2010 <freep>
}
    1034:	6422                	ld	s0,8(sp)
    1036:	0141                	addi	sp,sp,16
    1038:	8082                	ret

000000000000103a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    103a:	7139                	addi	sp,sp,-64
    103c:	fc06                	sd	ra,56(sp)
    103e:	f822                	sd	s0,48(sp)
    1040:	f426                	sd	s1,40(sp)
    1042:	ec4e                	sd	s3,24(sp)
    1044:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1046:	02051493          	slli	s1,a0,0x20
    104a:	9081                	srli	s1,s1,0x20
    104c:	04bd                	addi	s1,s1,15
    104e:	8091                	srli	s1,s1,0x4
    1050:	0014899b          	addiw	s3,s1,1
    1054:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    1056:	00001517          	auipc	a0,0x1
    105a:	fba53503          	ld	a0,-70(a0) # 2010 <freep>
    105e:	c915                	beqz	a0,1092 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1060:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1062:	4798                	lw	a4,8(a5)
    1064:	08977a63          	bgeu	a4,s1,10f8 <malloc+0xbe>
    1068:	f04a                	sd	s2,32(sp)
    106a:	e852                	sd	s4,16(sp)
    106c:	e456                	sd	s5,8(sp)
    106e:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
    1070:	8a4e                	mv	s4,s3
    1072:	0009871b          	sext.w	a4,s3
    1076:	6685                	lui	a3,0x1
    1078:	00d77363          	bgeu	a4,a3,107e <malloc+0x44>
    107c:	6a05                	lui	s4,0x1
    107e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    1082:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    1086:	00001917          	auipc	s2,0x1
    108a:	f8a90913          	addi	s2,s2,-118 # 2010 <freep>
  if(p == (char*)-1)
    108e:	5afd                	li	s5,-1
    1090:	a081                	j	10d0 <malloc+0x96>
    1092:	f04a                	sd	s2,32(sp)
    1094:	e852                	sd	s4,16(sp)
    1096:	e456                	sd	s5,8(sp)
    1098:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
    109a:	00001797          	auipc	a5,0x1
    109e:	36e78793          	addi	a5,a5,878 # 2408 <base>
    10a2:	00001717          	auipc	a4,0x1
    10a6:	f6f73723          	sd	a5,-146(a4) # 2010 <freep>
    10aa:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    10ac:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    10b0:	b7c1                	j	1070 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
    10b2:	6398                	ld	a4,0(a5)
    10b4:	e118                	sd	a4,0(a0)
    10b6:	a8a9                	j	1110 <malloc+0xd6>
  hp->s.size = nu;
    10b8:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    10bc:	0541                	addi	a0,a0,16
    10be:	efbff0ef          	jal	fb8 <free>
  return freep;
    10c2:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    10c6:	c12d                	beqz	a0,1128 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    10c8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    10ca:	4798                	lw	a4,8(a5)
    10cc:	02977263          	bgeu	a4,s1,10f0 <malloc+0xb6>
    if(p == freep)
    10d0:	00093703          	ld	a4,0(s2)
    10d4:	853e                	mv	a0,a5
    10d6:	fef719e3          	bne	a4,a5,10c8 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
    10da:	8552                	mv	a0,s4
    10dc:	afbff0ef          	jal	bd6 <sbrk>
  if(p == (char*)-1)
    10e0:	fd551ce3          	bne	a0,s5,10b8 <malloc+0x7e>
        return 0;
    10e4:	4501                	li	a0,0
    10e6:	7902                	ld	s2,32(sp)
    10e8:	6a42                	ld	s4,16(sp)
    10ea:	6aa2                	ld	s5,8(sp)
    10ec:	6b02                	ld	s6,0(sp)
    10ee:	a03d                	j	111c <malloc+0xe2>
    10f0:	7902                	ld	s2,32(sp)
    10f2:	6a42                	ld	s4,16(sp)
    10f4:	6aa2                	ld	s5,8(sp)
    10f6:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
    10f8:	fae48de3          	beq	s1,a4,10b2 <malloc+0x78>
        p->s.size -= nunits;
    10fc:	4137073b          	subw	a4,a4,s3
    1100:	c798                	sw	a4,8(a5)
        p += p->s.size;
    1102:	02071693          	slli	a3,a4,0x20
    1106:	01c6d713          	srli	a4,a3,0x1c
    110a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    110c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    1110:	00001717          	auipc	a4,0x1
    1114:	f0a73023          	sd	a0,-256(a4) # 2010 <freep>
      return (void*)(p + 1);
    1118:	01078513          	addi	a0,a5,16
  }
}
    111c:	70e2                	ld	ra,56(sp)
    111e:	7442                	ld	s0,48(sp)
    1120:	74a2                	ld	s1,40(sp)
    1122:	69e2                	ld	s3,24(sp)
    1124:	6121                	addi	sp,sp,64
    1126:	8082                	ret
    1128:	7902                	ld	s2,32(sp)
    112a:	6a42                	ld	s4,16(sp)
    112c:	6aa2                	ld	s5,8(sp)
    112e:	6b02                	ld	s6,0(sp)
    1130:	b7f5                	j	111c <malloc+0xe2>
