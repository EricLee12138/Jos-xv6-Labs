
obj/user/testpipe.debug：     文件格式 elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 81 02 00 00       	call   8002b2 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char *msg = "Now is the time for all good men to come to the aid of their party.";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 7c             	sub    $0x7c,%esp
	char buf[100];
	int i, pid, p[2];

	binaryname = "pipereadeof";
  80003b:	c7 05 04 30 80 00 c0 	movl   $0x8023c0,0x803004
  800042:	23 80 00 

	if ((i = pipe(p)) < 0)
  800045:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800048:	50                   	push   %eax
  800049:	e8 cf 1b 00 00       	call   801c1d <pipe>
  80004e:	89 c6                	mov    %eax,%esi
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", i);
  800057:	50                   	push   %eax
  800058:	68 cc 23 80 00       	push   $0x8023cc
  80005d:	6a 0e                	push   $0xe
  80005f:	68 d5 23 80 00       	push   $0x8023d5
  800064:	e8 a9 02 00 00       	call   800312 <_panic>

	if ((pid = fork()) < 0)
  800069:	e8 1a 10 00 00       	call   801088 <fork>
  80006e:	89 c3                	mov    %eax,%ebx
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", i);
  800074:	56                   	push   %esi
  800075:	68 e5 23 80 00       	push   $0x8023e5
  80007a:	6a 11                	push   $0x11
  80007c:	68 d5 23 80 00       	push   $0x8023d5
  800081:	e8 8c 02 00 00       	call   800312 <_panic>

	if (pid == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	0f 85 b8 00 00 00    	jne    800146 <umain+0x113>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[1]);
  80008e:	a1 04 40 80 00       	mov    0x804004,%eax
  800093:	8b 40 48             	mov    0x48(%eax),%eax
  800096:	83 ec 04             	sub    $0x4,%esp
  800099:	ff 75 90             	pushl  -0x70(%ebp)
  80009c:	50                   	push   %eax
  80009d:	68 ee 23 80 00       	push   $0x8023ee
  8000a2:	e8 44 03 00 00       	call   8003eb <cprintf>
		close(p[1]);
  8000a7:	83 c4 04             	add    $0x4,%esp
  8000aa:	ff 75 90             	pushl  -0x70(%ebp)
  8000ad:	e8 2a 13 00 00       	call   8013dc <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  8000b2:	a1 04 40 80 00       	mov    0x804004,%eax
  8000b7:	8b 40 48             	mov    0x48(%eax),%eax
  8000ba:	83 c4 0c             	add    $0xc,%esp
  8000bd:	ff 75 8c             	pushl  -0x74(%ebp)
  8000c0:	50                   	push   %eax
  8000c1:	68 0b 24 80 00       	push   $0x80240b
  8000c6:	e8 20 03 00 00       	call   8003eb <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000cb:	83 c4 0c             	add    $0xc,%esp
  8000ce:	6a 63                	push   $0x63
  8000d0:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000d3:	50                   	push   %eax
  8000d4:	ff 75 8c             	pushl  -0x74(%ebp)
  8000d7:	e8 cd 14 00 00       	call   8015a9 <readn>
  8000dc:	89 c6                	mov    %eax,%esi
		if (i < 0)
  8000de:	83 c4 10             	add    $0x10,%esp
  8000e1:	85 c0                	test   %eax,%eax
  8000e3:	79 12                	jns    8000f7 <umain+0xc4>
			panic("read: %e", i);
  8000e5:	50                   	push   %eax
  8000e6:	68 28 24 80 00       	push   $0x802428
  8000eb:	6a 19                	push   $0x19
  8000ed:	68 d5 23 80 00       	push   $0x8023d5
  8000f2:	e8 1b 02 00 00       	call   800312 <_panic>
		buf[i] = 0;
  8000f7:	c6 44 05 94 00       	movb   $0x0,-0x6c(%ebp,%eax,1)
		if (strcmp(buf, msg) == 0)
  8000fc:	83 ec 08             	sub    $0x8,%esp
  8000ff:	ff 35 00 30 80 00    	pushl  0x803000
  800105:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800108:	50                   	push   %eax
  800109:	e8 8b 09 00 00       	call   800a99 <strcmp>
  80010e:	83 c4 10             	add    $0x10,%esp
  800111:	85 c0                	test   %eax,%eax
  800113:	75 12                	jne    800127 <umain+0xf4>
			cprintf("\npipe read closed properly\n");
  800115:	83 ec 0c             	sub    $0xc,%esp
  800118:	68 31 24 80 00       	push   $0x802431
  80011d:	e8 c9 02 00 00       	call   8003eb <cprintf>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	eb 15                	jmp    80013c <umain+0x109>
		else
			cprintf("\ngot %d bytes: %s\n", i, buf);
  800127:	83 ec 04             	sub    $0x4,%esp
  80012a:	8d 45 94             	lea    -0x6c(%ebp),%eax
  80012d:	50                   	push   %eax
  80012e:	56                   	push   %esi
  80012f:	68 4d 24 80 00       	push   $0x80244d
  800134:	e8 b2 02 00 00       	call   8003eb <cprintf>
  800139:	83 c4 10             	add    $0x10,%esp
		exit();
  80013c:	e8 b7 01 00 00       	call   8002f8 <exit>
  800141:	e9 94 00 00 00       	jmp    8001da <umain+0x1a7>
	} else {
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[0]);
  800146:	a1 04 40 80 00       	mov    0x804004,%eax
  80014b:	8b 40 48             	mov    0x48(%eax),%eax
  80014e:	83 ec 04             	sub    $0x4,%esp
  800151:	ff 75 8c             	pushl  -0x74(%ebp)
  800154:	50                   	push   %eax
  800155:	68 ee 23 80 00       	push   $0x8023ee
  80015a:	e8 8c 02 00 00       	call   8003eb <cprintf>
		close(p[0]);
  80015f:	83 c4 04             	add    $0x4,%esp
  800162:	ff 75 8c             	pushl  -0x74(%ebp)
  800165:	e8 72 12 00 00       	call   8013dc <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  80016a:	a1 04 40 80 00       	mov    0x804004,%eax
  80016f:	8b 40 48             	mov    0x48(%eax),%eax
  800172:	83 c4 0c             	add    $0xc,%esp
  800175:	ff 75 90             	pushl  -0x70(%ebp)
  800178:	50                   	push   %eax
  800179:	68 60 24 80 00       	push   $0x802460
  80017e:	e8 68 02 00 00       	call   8003eb <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  800183:	83 c4 04             	add    $0x4,%esp
  800186:	ff 35 00 30 80 00    	pushl  0x803000
  80018c:	e8 25 08 00 00       	call   8009b6 <strlen>
  800191:	83 c4 0c             	add    $0xc,%esp
  800194:	50                   	push   %eax
  800195:	ff 35 00 30 80 00    	pushl  0x803000
  80019b:	ff 75 90             	pushl  -0x70(%ebp)
  80019e:	e8 4f 14 00 00       	call   8015f2 <write>
  8001a3:	89 c6                	mov    %eax,%esi
  8001a5:	83 c4 04             	add    $0x4,%esp
  8001a8:	ff 35 00 30 80 00    	pushl  0x803000
  8001ae:	e8 03 08 00 00       	call   8009b6 <strlen>
  8001b3:	83 c4 10             	add    $0x10,%esp
  8001b6:	39 c6                	cmp    %eax,%esi
  8001b8:	74 12                	je     8001cc <umain+0x199>
			panic("write: %e", i);
  8001ba:	56                   	push   %esi
  8001bb:	68 7d 24 80 00       	push   $0x80247d
  8001c0:	6a 25                	push   $0x25
  8001c2:	68 d5 23 80 00       	push   $0x8023d5
  8001c7:	e8 46 01 00 00       	call   800312 <_panic>
		close(p[1]);
  8001cc:	83 ec 0c             	sub    $0xc,%esp
  8001cf:	ff 75 90             	pushl  -0x70(%ebp)
  8001d2:	e8 05 12 00 00       	call   8013dc <close>
  8001d7:	83 c4 10             	add    $0x10,%esp
	}
	wait(pid);
  8001da:	83 ec 0c             	sub    $0xc,%esp
  8001dd:	53                   	push   %ebx
  8001de:	e8 c0 1b 00 00       	call   801da3 <wait>

	binaryname = "pipewriteeof";
  8001e3:	c7 05 04 30 80 00 87 	movl   $0x802487,0x803004
  8001ea:	24 80 00 
	if ((i = pipe(p)) < 0)
  8001ed:	8d 45 8c             	lea    -0x74(%ebp),%eax
  8001f0:	89 04 24             	mov    %eax,(%esp)
  8001f3:	e8 25 1a 00 00       	call   801c1d <pipe>
  8001f8:	89 c6                	mov    %eax,%esi
  8001fa:	83 c4 10             	add    $0x10,%esp
  8001fd:	85 c0                	test   %eax,%eax
  8001ff:	79 12                	jns    800213 <umain+0x1e0>
		panic("pipe: %e", i);
  800201:	50                   	push   %eax
  800202:	68 cc 23 80 00       	push   $0x8023cc
  800207:	6a 2c                	push   $0x2c
  800209:	68 d5 23 80 00       	push   $0x8023d5
  80020e:	e8 ff 00 00 00       	call   800312 <_panic>

	if ((pid = fork()) < 0)
  800213:	e8 70 0e 00 00       	call   801088 <fork>
  800218:	89 c3                	mov    %eax,%ebx
  80021a:	85 c0                	test   %eax,%eax
  80021c:	79 12                	jns    800230 <umain+0x1fd>
		panic("fork: %e", i);
  80021e:	56                   	push   %esi
  80021f:	68 e5 23 80 00       	push   $0x8023e5
  800224:	6a 2f                	push   $0x2f
  800226:	68 d5 23 80 00       	push   $0x8023d5
  80022b:	e8 e2 00 00 00       	call   800312 <_panic>

	if (pid == 0) {
  800230:	85 c0                	test   %eax,%eax
  800232:	75 4a                	jne    80027e <umain+0x24b>
		close(p[0]);
  800234:	83 ec 0c             	sub    $0xc,%esp
  800237:	ff 75 8c             	pushl  -0x74(%ebp)
  80023a:	e8 9d 11 00 00       	call   8013dc <close>
  80023f:	83 c4 10             	add    $0x10,%esp
		while (1) {
			cprintf(".");
  800242:	83 ec 0c             	sub    $0xc,%esp
  800245:	68 94 24 80 00       	push   $0x802494
  80024a:	e8 9c 01 00 00       	call   8003eb <cprintf>
			if (write(p[1], "x", 1) != 1)
  80024f:	83 c4 0c             	add    $0xc,%esp
  800252:	6a 01                	push   $0x1
  800254:	68 96 24 80 00       	push   $0x802496
  800259:	ff 75 90             	pushl  -0x70(%ebp)
  80025c:	e8 91 13 00 00       	call   8015f2 <write>
  800261:	83 c4 10             	add    $0x10,%esp
  800264:	83 f8 01             	cmp    $0x1,%eax
  800267:	74 d9                	je     800242 <umain+0x20f>
				break;
		}
		cprintf("\npipe write closed properly\n");
  800269:	83 ec 0c             	sub    $0xc,%esp
  80026c:	68 98 24 80 00       	push   $0x802498
  800271:	e8 75 01 00 00       	call   8003eb <cprintf>
		exit();
  800276:	e8 7d 00 00 00       	call   8002f8 <exit>
  80027b:	83 c4 10             	add    $0x10,%esp
	}
	close(p[0]);
  80027e:	83 ec 0c             	sub    $0xc,%esp
  800281:	ff 75 8c             	pushl  -0x74(%ebp)
  800284:	e8 53 11 00 00       	call   8013dc <close>
	close(p[1]);
  800289:	83 c4 04             	add    $0x4,%esp
  80028c:	ff 75 90             	pushl  -0x70(%ebp)
  80028f:	e8 48 11 00 00       	call   8013dc <close>
	wait(pid);
  800294:	89 1c 24             	mov    %ebx,(%esp)
  800297:	e8 07 1b 00 00       	call   801da3 <wait>

	cprintf("pipe tests passed\n");
  80029c:	c7 04 24 b5 24 80 00 	movl   $0x8024b5,(%esp)
  8002a3:	e8 43 01 00 00       	call   8003eb <cprintf>
}
  8002a8:	83 c4 10             	add    $0x10,%esp
  8002ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002ae:	5b                   	pop    %ebx
  8002af:	5e                   	pop    %esi
  8002b0:	5d                   	pop    %ebp
  8002b1:	c3                   	ret    

008002b2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	56                   	push   %esi
  8002b6:	53                   	push   %ebx
  8002b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002ba:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8002bd:	e8 f2 0a 00 00       	call   800db4 <sys_getenvid>
  8002c2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002c7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8002ca:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002cf:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002d4:	85 db                	test   %ebx,%ebx
  8002d6:	7e 07                	jle    8002df <libmain+0x2d>
		binaryname = argv[0];
  8002d8:	8b 06                	mov    (%esi),%eax
  8002da:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8002df:	83 ec 08             	sub    $0x8,%esp
  8002e2:	56                   	push   %esi
  8002e3:	53                   	push   %ebx
  8002e4:	e8 4a fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8002e9:	e8 0a 00 00 00       	call   8002f8 <exit>
}
  8002ee:	83 c4 10             	add    $0x10,%esp
  8002f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002f4:	5b                   	pop    %ebx
  8002f5:	5e                   	pop    %esi
  8002f6:	5d                   	pop    %ebp
  8002f7:	c3                   	ret    

008002f8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8002fe:	e8 04 11 00 00       	call   801407 <close_all>
	sys_env_destroy(0);
  800303:	83 ec 0c             	sub    $0xc,%esp
  800306:	6a 00                	push   $0x0
  800308:	e8 66 0a 00 00       	call   800d73 <sys_env_destroy>
}
  80030d:	83 c4 10             	add    $0x10,%esp
  800310:	c9                   	leave  
  800311:	c3                   	ret    

00800312 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	56                   	push   %esi
  800316:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800317:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80031a:	8b 35 04 30 80 00    	mov    0x803004,%esi
  800320:	e8 8f 0a 00 00       	call   800db4 <sys_getenvid>
  800325:	83 ec 0c             	sub    $0xc,%esp
  800328:	ff 75 0c             	pushl  0xc(%ebp)
  80032b:	ff 75 08             	pushl  0x8(%ebp)
  80032e:	56                   	push   %esi
  80032f:	50                   	push   %eax
  800330:	68 18 25 80 00       	push   $0x802518
  800335:	e8 b1 00 00 00       	call   8003eb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80033a:	83 c4 18             	add    $0x18,%esp
  80033d:	53                   	push   %ebx
  80033e:	ff 75 10             	pushl  0x10(%ebp)
  800341:	e8 54 00 00 00       	call   80039a <vcprintf>
	cprintf("\n");
  800346:	c7 04 24 09 24 80 00 	movl   $0x802409,(%esp)
  80034d:	e8 99 00 00 00       	call   8003eb <cprintf>
  800352:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800355:	cc                   	int3   
  800356:	eb fd                	jmp    800355 <_panic+0x43>

00800358 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800358:	55                   	push   %ebp
  800359:	89 e5                	mov    %esp,%ebp
  80035b:	53                   	push   %ebx
  80035c:	83 ec 04             	sub    $0x4,%esp
  80035f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800362:	8b 13                	mov    (%ebx),%edx
  800364:	8d 42 01             	lea    0x1(%edx),%eax
  800367:	89 03                	mov    %eax,(%ebx)
  800369:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80036c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800370:	3d ff 00 00 00       	cmp    $0xff,%eax
  800375:	75 1a                	jne    800391 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800377:	83 ec 08             	sub    $0x8,%esp
  80037a:	68 ff 00 00 00       	push   $0xff
  80037f:	8d 43 08             	lea    0x8(%ebx),%eax
  800382:	50                   	push   %eax
  800383:	e8 ae 09 00 00       	call   800d36 <sys_cputs>
		b->idx = 0;
  800388:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80038e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800391:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800395:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800398:	c9                   	leave  
  800399:	c3                   	ret    

0080039a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80039a:	55                   	push   %ebp
  80039b:	89 e5                	mov    %esp,%ebp
  80039d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003a3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003aa:	00 00 00 
	b.cnt = 0;
  8003ad:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003b4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003b7:	ff 75 0c             	pushl  0xc(%ebp)
  8003ba:	ff 75 08             	pushl  0x8(%ebp)
  8003bd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003c3:	50                   	push   %eax
  8003c4:	68 58 03 80 00       	push   $0x800358
  8003c9:	e8 1a 01 00 00       	call   8004e8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003ce:	83 c4 08             	add    $0x8,%esp
  8003d1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003d7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003dd:	50                   	push   %eax
  8003de:	e8 53 09 00 00       	call   800d36 <sys_cputs>

	return b.cnt;
}
  8003e3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003e9:	c9                   	leave  
  8003ea:	c3                   	ret    

008003eb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003eb:	55                   	push   %ebp
  8003ec:	89 e5                	mov    %esp,%ebp
  8003ee:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003f1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003f4:	50                   	push   %eax
  8003f5:	ff 75 08             	pushl  0x8(%ebp)
  8003f8:	e8 9d ff ff ff       	call   80039a <vcprintf>
	va_end(ap);

	return cnt;
}
  8003fd:	c9                   	leave  
  8003fe:	c3                   	ret    

008003ff <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003ff:	55                   	push   %ebp
  800400:	89 e5                	mov    %esp,%ebp
  800402:	57                   	push   %edi
  800403:	56                   	push   %esi
  800404:	53                   	push   %ebx
  800405:	83 ec 1c             	sub    $0x1c,%esp
  800408:	89 c7                	mov    %eax,%edi
  80040a:	89 d6                	mov    %edx,%esi
  80040c:	8b 45 08             	mov    0x8(%ebp),%eax
  80040f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800412:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800415:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800418:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80041b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800420:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800423:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800426:	39 d3                	cmp    %edx,%ebx
  800428:	72 05                	jb     80042f <printnum+0x30>
  80042a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80042d:	77 45                	ja     800474 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80042f:	83 ec 0c             	sub    $0xc,%esp
  800432:	ff 75 18             	pushl  0x18(%ebp)
  800435:	8b 45 14             	mov    0x14(%ebp),%eax
  800438:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80043b:	53                   	push   %ebx
  80043c:	ff 75 10             	pushl  0x10(%ebp)
  80043f:	83 ec 08             	sub    $0x8,%esp
  800442:	ff 75 e4             	pushl  -0x1c(%ebp)
  800445:	ff 75 e0             	pushl  -0x20(%ebp)
  800448:	ff 75 dc             	pushl  -0x24(%ebp)
  80044b:	ff 75 d8             	pushl  -0x28(%ebp)
  80044e:	e8 cd 1c 00 00       	call   802120 <__udivdi3>
  800453:	83 c4 18             	add    $0x18,%esp
  800456:	52                   	push   %edx
  800457:	50                   	push   %eax
  800458:	89 f2                	mov    %esi,%edx
  80045a:	89 f8                	mov    %edi,%eax
  80045c:	e8 9e ff ff ff       	call   8003ff <printnum>
  800461:	83 c4 20             	add    $0x20,%esp
  800464:	eb 18                	jmp    80047e <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800466:	83 ec 08             	sub    $0x8,%esp
  800469:	56                   	push   %esi
  80046a:	ff 75 18             	pushl  0x18(%ebp)
  80046d:	ff d7                	call   *%edi
  80046f:	83 c4 10             	add    $0x10,%esp
  800472:	eb 03                	jmp    800477 <printnum+0x78>
  800474:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800477:	83 eb 01             	sub    $0x1,%ebx
  80047a:	85 db                	test   %ebx,%ebx
  80047c:	7f e8                	jg     800466 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80047e:	83 ec 08             	sub    $0x8,%esp
  800481:	56                   	push   %esi
  800482:	83 ec 04             	sub    $0x4,%esp
  800485:	ff 75 e4             	pushl  -0x1c(%ebp)
  800488:	ff 75 e0             	pushl  -0x20(%ebp)
  80048b:	ff 75 dc             	pushl  -0x24(%ebp)
  80048e:	ff 75 d8             	pushl  -0x28(%ebp)
  800491:	e8 ba 1d 00 00       	call   802250 <__umoddi3>
  800496:	83 c4 14             	add    $0x14,%esp
  800499:	0f be 80 3b 25 80 00 	movsbl 0x80253b(%eax),%eax
  8004a0:	50                   	push   %eax
  8004a1:	ff d7                	call   *%edi
}
  8004a3:	83 c4 10             	add    $0x10,%esp
  8004a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004a9:	5b                   	pop    %ebx
  8004aa:	5e                   	pop    %esi
  8004ab:	5f                   	pop    %edi
  8004ac:	5d                   	pop    %ebp
  8004ad:	c3                   	ret    

008004ae <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004ae:	55                   	push   %ebp
  8004af:	89 e5                	mov    %esp,%ebp
  8004b1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004b4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004b8:	8b 10                	mov    (%eax),%edx
  8004ba:	3b 50 04             	cmp    0x4(%eax),%edx
  8004bd:	73 0a                	jae    8004c9 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004bf:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004c2:	89 08                	mov    %ecx,(%eax)
  8004c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c7:	88 02                	mov    %al,(%edx)
}
  8004c9:	5d                   	pop    %ebp
  8004ca:	c3                   	ret    

008004cb <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004cb:	55                   	push   %ebp
  8004cc:	89 e5                	mov    %esp,%ebp
  8004ce:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004d1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004d4:	50                   	push   %eax
  8004d5:	ff 75 10             	pushl  0x10(%ebp)
  8004d8:	ff 75 0c             	pushl  0xc(%ebp)
  8004db:	ff 75 08             	pushl  0x8(%ebp)
  8004de:	e8 05 00 00 00       	call   8004e8 <vprintfmt>
	va_end(ap);
}
  8004e3:	83 c4 10             	add    $0x10,%esp
  8004e6:	c9                   	leave  
  8004e7:	c3                   	ret    

008004e8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004e8:	55                   	push   %ebp
  8004e9:	89 e5                	mov    %esp,%ebp
  8004eb:	57                   	push   %edi
  8004ec:	56                   	push   %esi
  8004ed:	53                   	push   %ebx
  8004ee:	83 ec 2c             	sub    $0x2c,%esp
  8004f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004fa:	eb 12                	jmp    80050e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004fc:	85 c0                	test   %eax,%eax
  8004fe:	0f 84 42 04 00 00    	je     800946 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  800504:	83 ec 08             	sub    $0x8,%esp
  800507:	53                   	push   %ebx
  800508:	50                   	push   %eax
  800509:	ff d6                	call   *%esi
  80050b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80050e:	83 c7 01             	add    $0x1,%edi
  800511:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800515:	83 f8 25             	cmp    $0x25,%eax
  800518:	75 e2                	jne    8004fc <vprintfmt+0x14>
  80051a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80051e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800525:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80052c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800533:	b9 00 00 00 00       	mov    $0x0,%ecx
  800538:	eb 07                	jmp    800541 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80053d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800541:	8d 47 01             	lea    0x1(%edi),%eax
  800544:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800547:	0f b6 07             	movzbl (%edi),%eax
  80054a:	0f b6 d0             	movzbl %al,%edx
  80054d:	83 e8 23             	sub    $0x23,%eax
  800550:	3c 55                	cmp    $0x55,%al
  800552:	0f 87 d3 03 00 00    	ja     80092b <vprintfmt+0x443>
  800558:	0f b6 c0             	movzbl %al,%eax
  80055b:	ff 24 85 80 26 80 00 	jmp    *0x802680(,%eax,4)
  800562:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800565:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800569:	eb d6                	jmp    800541 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80056e:	b8 00 00 00 00       	mov    $0x0,%eax
  800573:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800576:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800579:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80057d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800580:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800583:	83 f9 09             	cmp    $0x9,%ecx
  800586:	77 3f                	ja     8005c7 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800588:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80058b:	eb e9                	jmp    800576 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80058d:	8b 45 14             	mov    0x14(%ebp),%eax
  800590:	8b 00                	mov    (%eax),%eax
  800592:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800595:	8b 45 14             	mov    0x14(%ebp),%eax
  800598:	8d 40 04             	lea    0x4(%eax),%eax
  80059b:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005a1:	eb 2a                	jmp    8005cd <vprintfmt+0xe5>
  8005a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005a6:	85 c0                	test   %eax,%eax
  8005a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8005ad:	0f 49 d0             	cmovns %eax,%edx
  8005b0:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b6:	eb 89                	jmp    800541 <vprintfmt+0x59>
  8005b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005bb:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005c2:	e9 7a ff ff ff       	jmp    800541 <vprintfmt+0x59>
  8005c7:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005ca:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005cd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005d1:	0f 89 6a ff ff ff    	jns    800541 <vprintfmt+0x59>
				width = precision, precision = -1;
  8005d7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005da:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005dd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005e4:	e9 58 ff ff ff       	jmp    800541 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005e9:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005ef:	e9 4d ff ff ff       	jmp    800541 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f7:	8d 78 04             	lea    0x4(%eax),%edi
  8005fa:	83 ec 08             	sub    $0x8,%esp
  8005fd:	53                   	push   %ebx
  8005fe:	ff 30                	pushl  (%eax)
  800600:	ff d6                	call   *%esi
			break;
  800602:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800605:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800608:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80060b:	e9 fe fe ff ff       	jmp    80050e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800610:	8b 45 14             	mov    0x14(%ebp),%eax
  800613:	8d 78 04             	lea    0x4(%eax),%edi
  800616:	8b 00                	mov    (%eax),%eax
  800618:	99                   	cltd   
  800619:	31 d0                	xor    %edx,%eax
  80061b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80061d:	83 f8 0f             	cmp    $0xf,%eax
  800620:	7f 0b                	jg     80062d <vprintfmt+0x145>
  800622:	8b 14 85 e0 27 80 00 	mov    0x8027e0(,%eax,4),%edx
  800629:	85 d2                	test   %edx,%edx
  80062b:	75 1b                	jne    800648 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  80062d:	50                   	push   %eax
  80062e:	68 53 25 80 00       	push   $0x802553
  800633:	53                   	push   %ebx
  800634:	56                   	push   %esi
  800635:	e8 91 fe ff ff       	call   8004cb <printfmt>
  80063a:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80063d:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800640:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800643:	e9 c6 fe ff ff       	jmp    80050e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800648:	52                   	push   %edx
  800649:	68 7d 29 80 00       	push   $0x80297d
  80064e:	53                   	push   %ebx
  80064f:	56                   	push   %esi
  800650:	e8 76 fe ff ff       	call   8004cb <printfmt>
  800655:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800658:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80065e:	e9 ab fe ff ff       	jmp    80050e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800663:	8b 45 14             	mov    0x14(%ebp),%eax
  800666:	83 c0 04             	add    $0x4,%eax
  800669:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80066c:	8b 45 14             	mov    0x14(%ebp),%eax
  80066f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800671:	85 ff                	test   %edi,%edi
  800673:	b8 4c 25 80 00       	mov    $0x80254c,%eax
  800678:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80067b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80067f:	0f 8e 94 00 00 00    	jle    800719 <vprintfmt+0x231>
  800685:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800689:	0f 84 98 00 00 00    	je     800727 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  80068f:	83 ec 08             	sub    $0x8,%esp
  800692:	ff 75 d0             	pushl  -0x30(%ebp)
  800695:	57                   	push   %edi
  800696:	e8 33 03 00 00       	call   8009ce <strnlen>
  80069b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80069e:	29 c1                	sub    %eax,%ecx
  8006a0:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8006a3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006a6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006ad:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006b0:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b2:	eb 0f                	jmp    8006c3 <vprintfmt+0x1db>
					putch(padc, putdat);
  8006b4:	83 ec 08             	sub    $0x8,%esp
  8006b7:	53                   	push   %ebx
  8006b8:	ff 75 e0             	pushl  -0x20(%ebp)
  8006bb:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006bd:	83 ef 01             	sub    $0x1,%edi
  8006c0:	83 c4 10             	add    $0x10,%esp
  8006c3:	85 ff                	test   %edi,%edi
  8006c5:	7f ed                	jg     8006b4 <vprintfmt+0x1cc>
  8006c7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006ca:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006cd:	85 c9                	test   %ecx,%ecx
  8006cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8006d4:	0f 49 c1             	cmovns %ecx,%eax
  8006d7:	29 c1                	sub    %eax,%ecx
  8006d9:	89 75 08             	mov    %esi,0x8(%ebp)
  8006dc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006df:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006e2:	89 cb                	mov    %ecx,%ebx
  8006e4:	eb 4d                	jmp    800733 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006e6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006ea:	74 1b                	je     800707 <vprintfmt+0x21f>
  8006ec:	0f be c0             	movsbl %al,%eax
  8006ef:	83 e8 20             	sub    $0x20,%eax
  8006f2:	83 f8 5e             	cmp    $0x5e,%eax
  8006f5:	76 10                	jbe    800707 <vprintfmt+0x21f>
					putch('?', putdat);
  8006f7:	83 ec 08             	sub    $0x8,%esp
  8006fa:	ff 75 0c             	pushl  0xc(%ebp)
  8006fd:	6a 3f                	push   $0x3f
  8006ff:	ff 55 08             	call   *0x8(%ebp)
  800702:	83 c4 10             	add    $0x10,%esp
  800705:	eb 0d                	jmp    800714 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800707:	83 ec 08             	sub    $0x8,%esp
  80070a:	ff 75 0c             	pushl  0xc(%ebp)
  80070d:	52                   	push   %edx
  80070e:	ff 55 08             	call   *0x8(%ebp)
  800711:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800714:	83 eb 01             	sub    $0x1,%ebx
  800717:	eb 1a                	jmp    800733 <vprintfmt+0x24b>
  800719:	89 75 08             	mov    %esi,0x8(%ebp)
  80071c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80071f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800722:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800725:	eb 0c                	jmp    800733 <vprintfmt+0x24b>
  800727:	89 75 08             	mov    %esi,0x8(%ebp)
  80072a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80072d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800730:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800733:	83 c7 01             	add    $0x1,%edi
  800736:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80073a:	0f be d0             	movsbl %al,%edx
  80073d:	85 d2                	test   %edx,%edx
  80073f:	74 23                	je     800764 <vprintfmt+0x27c>
  800741:	85 f6                	test   %esi,%esi
  800743:	78 a1                	js     8006e6 <vprintfmt+0x1fe>
  800745:	83 ee 01             	sub    $0x1,%esi
  800748:	79 9c                	jns    8006e6 <vprintfmt+0x1fe>
  80074a:	89 df                	mov    %ebx,%edi
  80074c:	8b 75 08             	mov    0x8(%ebp),%esi
  80074f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800752:	eb 18                	jmp    80076c <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800754:	83 ec 08             	sub    $0x8,%esp
  800757:	53                   	push   %ebx
  800758:	6a 20                	push   $0x20
  80075a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80075c:	83 ef 01             	sub    $0x1,%edi
  80075f:	83 c4 10             	add    $0x10,%esp
  800762:	eb 08                	jmp    80076c <vprintfmt+0x284>
  800764:	89 df                	mov    %ebx,%edi
  800766:	8b 75 08             	mov    0x8(%ebp),%esi
  800769:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80076c:	85 ff                	test   %edi,%edi
  80076e:	7f e4                	jg     800754 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800770:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800773:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800776:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800779:	e9 90 fd ff ff       	jmp    80050e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80077e:	83 f9 01             	cmp    $0x1,%ecx
  800781:	7e 19                	jle    80079c <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800783:	8b 45 14             	mov    0x14(%ebp),%eax
  800786:	8b 50 04             	mov    0x4(%eax),%edx
  800789:	8b 00                	mov    (%eax),%eax
  80078b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80078e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800791:	8b 45 14             	mov    0x14(%ebp),%eax
  800794:	8d 40 08             	lea    0x8(%eax),%eax
  800797:	89 45 14             	mov    %eax,0x14(%ebp)
  80079a:	eb 38                	jmp    8007d4 <vprintfmt+0x2ec>
	else if (lflag)
  80079c:	85 c9                	test   %ecx,%ecx
  80079e:	74 1b                	je     8007bb <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8007a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a3:	8b 00                	mov    (%eax),%eax
  8007a5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a8:	89 c1                	mov    %eax,%ecx
  8007aa:	c1 f9 1f             	sar    $0x1f,%ecx
  8007ad:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b3:	8d 40 04             	lea    0x4(%eax),%eax
  8007b6:	89 45 14             	mov    %eax,0x14(%ebp)
  8007b9:	eb 19                	jmp    8007d4 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8007bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007be:	8b 00                	mov    (%eax),%eax
  8007c0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007c3:	89 c1                	mov    %eax,%ecx
  8007c5:	c1 f9 1f             	sar    $0x1f,%ecx
  8007c8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ce:	8d 40 04             	lea    0x4(%eax),%eax
  8007d1:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007d4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007d7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007da:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007df:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007e3:	0f 89 0e 01 00 00    	jns    8008f7 <vprintfmt+0x40f>
				putch('-', putdat);
  8007e9:	83 ec 08             	sub    $0x8,%esp
  8007ec:	53                   	push   %ebx
  8007ed:	6a 2d                	push   $0x2d
  8007ef:	ff d6                	call   *%esi
				num = -(long long) num;
  8007f1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007f4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007f7:	f7 da                	neg    %edx
  8007f9:	83 d1 00             	adc    $0x0,%ecx
  8007fc:	f7 d9                	neg    %ecx
  8007fe:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800801:	b8 0a 00 00 00       	mov    $0xa,%eax
  800806:	e9 ec 00 00 00       	jmp    8008f7 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80080b:	83 f9 01             	cmp    $0x1,%ecx
  80080e:	7e 18                	jle    800828 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800810:	8b 45 14             	mov    0x14(%ebp),%eax
  800813:	8b 10                	mov    (%eax),%edx
  800815:	8b 48 04             	mov    0x4(%eax),%ecx
  800818:	8d 40 08             	lea    0x8(%eax),%eax
  80081b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80081e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800823:	e9 cf 00 00 00       	jmp    8008f7 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800828:	85 c9                	test   %ecx,%ecx
  80082a:	74 1a                	je     800846 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80082c:	8b 45 14             	mov    0x14(%ebp),%eax
  80082f:	8b 10                	mov    (%eax),%edx
  800831:	b9 00 00 00 00       	mov    $0x0,%ecx
  800836:	8d 40 04             	lea    0x4(%eax),%eax
  800839:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80083c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800841:	e9 b1 00 00 00       	jmp    8008f7 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800846:	8b 45 14             	mov    0x14(%ebp),%eax
  800849:	8b 10                	mov    (%eax),%edx
  80084b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800850:	8d 40 04             	lea    0x4(%eax),%eax
  800853:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800856:	b8 0a 00 00 00       	mov    $0xa,%eax
  80085b:	e9 97 00 00 00       	jmp    8008f7 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800860:	83 ec 08             	sub    $0x8,%esp
  800863:	53                   	push   %ebx
  800864:	6a 58                	push   $0x58
  800866:	ff d6                	call   *%esi
			putch('X', putdat);
  800868:	83 c4 08             	add    $0x8,%esp
  80086b:	53                   	push   %ebx
  80086c:	6a 58                	push   $0x58
  80086e:	ff d6                	call   *%esi
			putch('X', putdat);
  800870:	83 c4 08             	add    $0x8,%esp
  800873:	53                   	push   %ebx
  800874:	6a 58                	push   $0x58
  800876:	ff d6                	call   *%esi
			break;
  800878:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80087b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  80087e:	e9 8b fc ff ff       	jmp    80050e <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800883:	83 ec 08             	sub    $0x8,%esp
  800886:	53                   	push   %ebx
  800887:	6a 30                	push   $0x30
  800889:	ff d6                	call   *%esi
			putch('x', putdat);
  80088b:	83 c4 08             	add    $0x8,%esp
  80088e:	53                   	push   %ebx
  80088f:	6a 78                	push   $0x78
  800891:	ff d6                	call   *%esi
			num = (unsigned long long)
  800893:	8b 45 14             	mov    0x14(%ebp),%eax
  800896:	8b 10                	mov    (%eax),%edx
  800898:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80089d:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008a0:	8d 40 04             	lea    0x4(%eax),%eax
  8008a3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008a6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008ab:	eb 4a                	jmp    8008f7 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008ad:	83 f9 01             	cmp    $0x1,%ecx
  8008b0:	7e 15                	jle    8008c7 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8008b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b5:	8b 10                	mov    (%eax),%edx
  8008b7:	8b 48 04             	mov    0x4(%eax),%ecx
  8008ba:	8d 40 08             	lea    0x8(%eax),%eax
  8008bd:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008c0:	b8 10 00 00 00       	mov    $0x10,%eax
  8008c5:	eb 30                	jmp    8008f7 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8008c7:	85 c9                	test   %ecx,%ecx
  8008c9:	74 17                	je     8008e2 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8008cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ce:	8b 10                	mov    (%eax),%edx
  8008d0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008d5:	8d 40 04             	lea    0x4(%eax),%eax
  8008d8:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008db:	b8 10 00 00 00       	mov    $0x10,%eax
  8008e0:	eb 15                	jmp    8008f7 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8008e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e5:	8b 10                	mov    (%eax),%edx
  8008e7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008ec:	8d 40 04             	lea    0x4(%eax),%eax
  8008ef:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008f2:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008f7:	83 ec 0c             	sub    $0xc,%esp
  8008fa:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008fe:	57                   	push   %edi
  8008ff:	ff 75 e0             	pushl  -0x20(%ebp)
  800902:	50                   	push   %eax
  800903:	51                   	push   %ecx
  800904:	52                   	push   %edx
  800905:	89 da                	mov    %ebx,%edx
  800907:	89 f0                	mov    %esi,%eax
  800909:	e8 f1 fa ff ff       	call   8003ff <printnum>
			break;
  80090e:	83 c4 20             	add    $0x20,%esp
  800911:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800914:	e9 f5 fb ff ff       	jmp    80050e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800919:	83 ec 08             	sub    $0x8,%esp
  80091c:	53                   	push   %ebx
  80091d:	52                   	push   %edx
  80091e:	ff d6                	call   *%esi
			break;
  800920:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800923:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800926:	e9 e3 fb ff ff       	jmp    80050e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80092b:	83 ec 08             	sub    $0x8,%esp
  80092e:	53                   	push   %ebx
  80092f:	6a 25                	push   $0x25
  800931:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800933:	83 c4 10             	add    $0x10,%esp
  800936:	eb 03                	jmp    80093b <vprintfmt+0x453>
  800938:	83 ef 01             	sub    $0x1,%edi
  80093b:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80093f:	75 f7                	jne    800938 <vprintfmt+0x450>
  800941:	e9 c8 fb ff ff       	jmp    80050e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800946:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800949:	5b                   	pop    %ebx
  80094a:	5e                   	pop    %esi
  80094b:	5f                   	pop    %edi
  80094c:	5d                   	pop    %ebp
  80094d:	c3                   	ret    

0080094e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
  800951:	83 ec 18             	sub    $0x18,%esp
  800954:	8b 45 08             	mov    0x8(%ebp),%eax
  800957:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80095a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80095d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800961:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800964:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80096b:	85 c0                	test   %eax,%eax
  80096d:	74 26                	je     800995 <vsnprintf+0x47>
  80096f:	85 d2                	test   %edx,%edx
  800971:	7e 22                	jle    800995 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800973:	ff 75 14             	pushl  0x14(%ebp)
  800976:	ff 75 10             	pushl  0x10(%ebp)
  800979:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80097c:	50                   	push   %eax
  80097d:	68 ae 04 80 00       	push   $0x8004ae
  800982:	e8 61 fb ff ff       	call   8004e8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800987:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80098a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80098d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800990:	83 c4 10             	add    $0x10,%esp
  800993:	eb 05                	jmp    80099a <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800995:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80099a:	c9                   	leave  
  80099b:	c3                   	ret    

0080099c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009a2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009a5:	50                   	push   %eax
  8009a6:	ff 75 10             	pushl  0x10(%ebp)
  8009a9:	ff 75 0c             	pushl  0xc(%ebp)
  8009ac:	ff 75 08             	pushl  0x8(%ebp)
  8009af:	e8 9a ff ff ff       	call   80094e <vsnprintf>
	va_end(ap);

	return rc;
}
  8009b4:	c9                   	leave  
  8009b5:	c3                   	ret    

008009b6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
  8009b9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c1:	eb 03                	jmp    8009c6 <strlen+0x10>
		n++;
  8009c3:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009c6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009ca:	75 f7                	jne    8009c3 <strlen+0xd>
		n++;
	return n;
}
  8009cc:	5d                   	pop    %ebp
  8009cd:	c3                   	ret    

008009ce <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
  8009d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009d4:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8009dc:	eb 03                	jmp    8009e1 <strnlen+0x13>
		n++;
  8009de:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009e1:	39 c2                	cmp    %eax,%edx
  8009e3:	74 08                	je     8009ed <strnlen+0x1f>
  8009e5:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009e9:	75 f3                	jne    8009de <strnlen+0x10>
  8009eb:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009ed:	5d                   	pop    %ebp
  8009ee:	c3                   	ret    

008009ef <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009ef:	55                   	push   %ebp
  8009f0:	89 e5                	mov    %esp,%ebp
  8009f2:	53                   	push   %ebx
  8009f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009f9:	89 c2                	mov    %eax,%edx
  8009fb:	83 c2 01             	add    $0x1,%edx
  8009fe:	83 c1 01             	add    $0x1,%ecx
  800a01:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a05:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a08:	84 db                	test   %bl,%bl
  800a0a:	75 ef                	jne    8009fb <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a0c:	5b                   	pop    %ebx
  800a0d:	5d                   	pop    %ebp
  800a0e:	c3                   	ret    

00800a0f <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a0f:	55                   	push   %ebp
  800a10:	89 e5                	mov    %esp,%ebp
  800a12:	53                   	push   %ebx
  800a13:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a16:	53                   	push   %ebx
  800a17:	e8 9a ff ff ff       	call   8009b6 <strlen>
  800a1c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a1f:	ff 75 0c             	pushl  0xc(%ebp)
  800a22:	01 d8                	add    %ebx,%eax
  800a24:	50                   	push   %eax
  800a25:	e8 c5 ff ff ff       	call   8009ef <strcpy>
	return dst;
}
  800a2a:	89 d8                	mov    %ebx,%eax
  800a2c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a2f:	c9                   	leave  
  800a30:	c3                   	ret    

00800a31 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a31:	55                   	push   %ebp
  800a32:	89 e5                	mov    %esp,%ebp
  800a34:	56                   	push   %esi
  800a35:	53                   	push   %ebx
  800a36:	8b 75 08             	mov    0x8(%ebp),%esi
  800a39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a3c:	89 f3                	mov    %esi,%ebx
  800a3e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a41:	89 f2                	mov    %esi,%edx
  800a43:	eb 0f                	jmp    800a54 <strncpy+0x23>
		*dst++ = *src;
  800a45:	83 c2 01             	add    $0x1,%edx
  800a48:	0f b6 01             	movzbl (%ecx),%eax
  800a4b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a4e:	80 39 01             	cmpb   $0x1,(%ecx)
  800a51:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a54:	39 da                	cmp    %ebx,%edx
  800a56:	75 ed                	jne    800a45 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a58:	89 f0                	mov    %esi,%eax
  800a5a:	5b                   	pop    %ebx
  800a5b:	5e                   	pop    %esi
  800a5c:	5d                   	pop    %ebp
  800a5d:	c3                   	ret    

00800a5e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	56                   	push   %esi
  800a62:	53                   	push   %ebx
  800a63:	8b 75 08             	mov    0x8(%ebp),%esi
  800a66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a69:	8b 55 10             	mov    0x10(%ebp),%edx
  800a6c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a6e:	85 d2                	test   %edx,%edx
  800a70:	74 21                	je     800a93 <strlcpy+0x35>
  800a72:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a76:	89 f2                	mov    %esi,%edx
  800a78:	eb 09                	jmp    800a83 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a7a:	83 c2 01             	add    $0x1,%edx
  800a7d:	83 c1 01             	add    $0x1,%ecx
  800a80:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a83:	39 c2                	cmp    %eax,%edx
  800a85:	74 09                	je     800a90 <strlcpy+0x32>
  800a87:	0f b6 19             	movzbl (%ecx),%ebx
  800a8a:	84 db                	test   %bl,%bl
  800a8c:	75 ec                	jne    800a7a <strlcpy+0x1c>
  800a8e:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a90:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a93:	29 f0                	sub    %esi,%eax
}
  800a95:	5b                   	pop    %ebx
  800a96:	5e                   	pop    %esi
  800a97:	5d                   	pop    %ebp
  800a98:	c3                   	ret    

00800a99 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a99:	55                   	push   %ebp
  800a9a:	89 e5                	mov    %esp,%ebp
  800a9c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a9f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800aa2:	eb 06                	jmp    800aaa <strcmp+0x11>
		p++, q++;
  800aa4:	83 c1 01             	add    $0x1,%ecx
  800aa7:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800aaa:	0f b6 01             	movzbl (%ecx),%eax
  800aad:	84 c0                	test   %al,%al
  800aaf:	74 04                	je     800ab5 <strcmp+0x1c>
  800ab1:	3a 02                	cmp    (%edx),%al
  800ab3:	74 ef                	je     800aa4 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ab5:	0f b6 c0             	movzbl %al,%eax
  800ab8:	0f b6 12             	movzbl (%edx),%edx
  800abb:	29 d0                	sub    %edx,%eax
}
  800abd:	5d                   	pop    %ebp
  800abe:	c3                   	ret    

00800abf <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800abf:	55                   	push   %ebp
  800ac0:	89 e5                	mov    %esp,%ebp
  800ac2:	53                   	push   %ebx
  800ac3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ac9:	89 c3                	mov    %eax,%ebx
  800acb:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ace:	eb 06                	jmp    800ad6 <strncmp+0x17>
		n--, p++, q++;
  800ad0:	83 c0 01             	add    $0x1,%eax
  800ad3:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ad6:	39 d8                	cmp    %ebx,%eax
  800ad8:	74 15                	je     800aef <strncmp+0x30>
  800ada:	0f b6 08             	movzbl (%eax),%ecx
  800add:	84 c9                	test   %cl,%cl
  800adf:	74 04                	je     800ae5 <strncmp+0x26>
  800ae1:	3a 0a                	cmp    (%edx),%cl
  800ae3:	74 eb                	je     800ad0 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ae5:	0f b6 00             	movzbl (%eax),%eax
  800ae8:	0f b6 12             	movzbl (%edx),%edx
  800aeb:	29 d0                	sub    %edx,%eax
  800aed:	eb 05                	jmp    800af4 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800aef:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800af4:	5b                   	pop    %ebx
  800af5:	5d                   	pop    %ebp
  800af6:	c3                   	ret    

00800af7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	8b 45 08             	mov    0x8(%ebp),%eax
  800afd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b01:	eb 07                	jmp    800b0a <strchr+0x13>
		if (*s == c)
  800b03:	38 ca                	cmp    %cl,%dl
  800b05:	74 0f                	je     800b16 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b07:	83 c0 01             	add    $0x1,%eax
  800b0a:	0f b6 10             	movzbl (%eax),%edx
  800b0d:	84 d2                	test   %dl,%dl
  800b0f:	75 f2                	jne    800b03 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b11:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b16:	5d                   	pop    %ebp
  800b17:	c3                   	ret    

00800b18 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b22:	eb 03                	jmp    800b27 <strfind+0xf>
  800b24:	83 c0 01             	add    $0x1,%eax
  800b27:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b2a:	38 ca                	cmp    %cl,%dl
  800b2c:	74 04                	je     800b32 <strfind+0x1a>
  800b2e:	84 d2                	test   %dl,%dl
  800b30:	75 f2                	jne    800b24 <strfind+0xc>
			break;
	return (char *) s;
}
  800b32:	5d                   	pop    %ebp
  800b33:	c3                   	ret    

00800b34 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	57                   	push   %edi
  800b38:	56                   	push   %esi
  800b39:	53                   	push   %ebx
  800b3a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b3d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b40:	85 c9                	test   %ecx,%ecx
  800b42:	74 36                	je     800b7a <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b44:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b4a:	75 28                	jne    800b74 <memset+0x40>
  800b4c:	f6 c1 03             	test   $0x3,%cl
  800b4f:	75 23                	jne    800b74 <memset+0x40>
		c &= 0xFF;
  800b51:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b55:	89 d3                	mov    %edx,%ebx
  800b57:	c1 e3 08             	shl    $0x8,%ebx
  800b5a:	89 d6                	mov    %edx,%esi
  800b5c:	c1 e6 18             	shl    $0x18,%esi
  800b5f:	89 d0                	mov    %edx,%eax
  800b61:	c1 e0 10             	shl    $0x10,%eax
  800b64:	09 f0                	or     %esi,%eax
  800b66:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b68:	89 d8                	mov    %ebx,%eax
  800b6a:	09 d0                	or     %edx,%eax
  800b6c:	c1 e9 02             	shr    $0x2,%ecx
  800b6f:	fc                   	cld    
  800b70:	f3 ab                	rep stos %eax,%es:(%edi)
  800b72:	eb 06                	jmp    800b7a <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b74:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b77:	fc                   	cld    
  800b78:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b7a:	89 f8                	mov    %edi,%eax
  800b7c:	5b                   	pop    %ebx
  800b7d:	5e                   	pop    %esi
  800b7e:	5f                   	pop    %edi
  800b7f:	5d                   	pop    %ebp
  800b80:	c3                   	ret    

00800b81 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	57                   	push   %edi
  800b85:	56                   	push   %esi
  800b86:	8b 45 08             	mov    0x8(%ebp),%eax
  800b89:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b8c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b8f:	39 c6                	cmp    %eax,%esi
  800b91:	73 35                	jae    800bc8 <memmove+0x47>
  800b93:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b96:	39 d0                	cmp    %edx,%eax
  800b98:	73 2e                	jae    800bc8 <memmove+0x47>
		s += n;
		d += n;
  800b9a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b9d:	89 d6                	mov    %edx,%esi
  800b9f:	09 fe                	or     %edi,%esi
  800ba1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ba7:	75 13                	jne    800bbc <memmove+0x3b>
  800ba9:	f6 c1 03             	test   $0x3,%cl
  800bac:	75 0e                	jne    800bbc <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800bae:	83 ef 04             	sub    $0x4,%edi
  800bb1:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bb4:	c1 e9 02             	shr    $0x2,%ecx
  800bb7:	fd                   	std    
  800bb8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bba:	eb 09                	jmp    800bc5 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bbc:	83 ef 01             	sub    $0x1,%edi
  800bbf:	8d 72 ff             	lea    -0x1(%edx),%esi
  800bc2:	fd                   	std    
  800bc3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bc5:	fc                   	cld    
  800bc6:	eb 1d                	jmp    800be5 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bc8:	89 f2                	mov    %esi,%edx
  800bca:	09 c2                	or     %eax,%edx
  800bcc:	f6 c2 03             	test   $0x3,%dl
  800bcf:	75 0f                	jne    800be0 <memmove+0x5f>
  800bd1:	f6 c1 03             	test   $0x3,%cl
  800bd4:	75 0a                	jne    800be0 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800bd6:	c1 e9 02             	shr    $0x2,%ecx
  800bd9:	89 c7                	mov    %eax,%edi
  800bdb:	fc                   	cld    
  800bdc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bde:	eb 05                	jmp    800be5 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800be0:	89 c7                	mov    %eax,%edi
  800be2:	fc                   	cld    
  800be3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800be5:	5e                   	pop    %esi
  800be6:	5f                   	pop    %edi
  800be7:	5d                   	pop    %ebp
  800be8:	c3                   	ret    

00800be9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bec:	ff 75 10             	pushl  0x10(%ebp)
  800bef:	ff 75 0c             	pushl  0xc(%ebp)
  800bf2:	ff 75 08             	pushl  0x8(%ebp)
  800bf5:	e8 87 ff ff ff       	call   800b81 <memmove>
}
  800bfa:	c9                   	leave  
  800bfb:	c3                   	ret    

00800bfc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	56                   	push   %esi
  800c00:	53                   	push   %ebx
  800c01:	8b 45 08             	mov    0x8(%ebp),%eax
  800c04:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c07:	89 c6                	mov    %eax,%esi
  800c09:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c0c:	eb 1a                	jmp    800c28 <memcmp+0x2c>
		if (*s1 != *s2)
  800c0e:	0f b6 08             	movzbl (%eax),%ecx
  800c11:	0f b6 1a             	movzbl (%edx),%ebx
  800c14:	38 d9                	cmp    %bl,%cl
  800c16:	74 0a                	je     800c22 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c18:	0f b6 c1             	movzbl %cl,%eax
  800c1b:	0f b6 db             	movzbl %bl,%ebx
  800c1e:	29 d8                	sub    %ebx,%eax
  800c20:	eb 0f                	jmp    800c31 <memcmp+0x35>
		s1++, s2++;
  800c22:	83 c0 01             	add    $0x1,%eax
  800c25:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c28:	39 f0                	cmp    %esi,%eax
  800c2a:	75 e2                	jne    800c0e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c2c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c31:	5b                   	pop    %ebx
  800c32:	5e                   	pop    %esi
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    

00800c35 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	53                   	push   %ebx
  800c39:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c3c:	89 c1                	mov    %eax,%ecx
  800c3e:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c41:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c45:	eb 0a                	jmp    800c51 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c47:	0f b6 10             	movzbl (%eax),%edx
  800c4a:	39 da                	cmp    %ebx,%edx
  800c4c:	74 07                	je     800c55 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c4e:	83 c0 01             	add    $0x1,%eax
  800c51:	39 c8                	cmp    %ecx,%eax
  800c53:	72 f2                	jb     800c47 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c55:	5b                   	pop    %ebx
  800c56:	5d                   	pop    %ebp
  800c57:	c3                   	ret    

00800c58 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c58:	55                   	push   %ebp
  800c59:	89 e5                	mov    %esp,%ebp
  800c5b:	57                   	push   %edi
  800c5c:	56                   	push   %esi
  800c5d:	53                   	push   %ebx
  800c5e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c61:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c64:	eb 03                	jmp    800c69 <strtol+0x11>
		s++;
  800c66:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c69:	0f b6 01             	movzbl (%ecx),%eax
  800c6c:	3c 20                	cmp    $0x20,%al
  800c6e:	74 f6                	je     800c66 <strtol+0xe>
  800c70:	3c 09                	cmp    $0x9,%al
  800c72:	74 f2                	je     800c66 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c74:	3c 2b                	cmp    $0x2b,%al
  800c76:	75 0a                	jne    800c82 <strtol+0x2a>
		s++;
  800c78:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c7b:	bf 00 00 00 00       	mov    $0x0,%edi
  800c80:	eb 11                	jmp    800c93 <strtol+0x3b>
  800c82:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c87:	3c 2d                	cmp    $0x2d,%al
  800c89:	75 08                	jne    800c93 <strtol+0x3b>
		s++, neg = 1;
  800c8b:	83 c1 01             	add    $0x1,%ecx
  800c8e:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c93:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c99:	75 15                	jne    800cb0 <strtol+0x58>
  800c9b:	80 39 30             	cmpb   $0x30,(%ecx)
  800c9e:	75 10                	jne    800cb0 <strtol+0x58>
  800ca0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ca4:	75 7c                	jne    800d22 <strtol+0xca>
		s += 2, base = 16;
  800ca6:	83 c1 02             	add    $0x2,%ecx
  800ca9:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cae:	eb 16                	jmp    800cc6 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800cb0:	85 db                	test   %ebx,%ebx
  800cb2:	75 12                	jne    800cc6 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cb4:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cb9:	80 39 30             	cmpb   $0x30,(%ecx)
  800cbc:	75 08                	jne    800cc6 <strtol+0x6e>
		s++, base = 8;
  800cbe:	83 c1 01             	add    $0x1,%ecx
  800cc1:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800cc6:	b8 00 00 00 00       	mov    $0x0,%eax
  800ccb:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cce:	0f b6 11             	movzbl (%ecx),%edx
  800cd1:	8d 72 d0             	lea    -0x30(%edx),%esi
  800cd4:	89 f3                	mov    %esi,%ebx
  800cd6:	80 fb 09             	cmp    $0x9,%bl
  800cd9:	77 08                	ja     800ce3 <strtol+0x8b>
			dig = *s - '0';
  800cdb:	0f be d2             	movsbl %dl,%edx
  800cde:	83 ea 30             	sub    $0x30,%edx
  800ce1:	eb 22                	jmp    800d05 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ce3:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ce6:	89 f3                	mov    %esi,%ebx
  800ce8:	80 fb 19             	cmp    $0x19,%bl
  800ceb:	77 08                	ja     800cf5 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ced:	0f be d2             	movsbl %dl,%edx
  800cf0:	83 ea 57             	sub    $0x57,%edx
  800cf3:	eb 10                	jmp    800d05 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800cf5:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cf8:	89 f3                	mov    %esi,%ebx
  800cfa:	80 fb 19             	cmp    $0x19,%bl
  800cfd:	77 16                	ja     800d15 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cff:	0f be d2             	movsbl %dl,%edx
  800d02:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d05:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d08:	7d 0b                	jge    800d15 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800d0a:	83 c1 01             	add    $0x1,%ecx
  800d0d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d11:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d13:	eb b9                	jmp    800cce <strtol+0x76>

	if (endptr)
  800d15:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d19:	74 0d                	je     800d28 <strtol+0xd0>
		*endptr = (char *) s;
  800d1b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d1e:	89 0e                	mov    %ecx,(%esi)
  800d20:	eb 06                	jmp    800d28 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d22:	85 db                	test   %ebx,%ebx
  800d24:	74 98                	je     800cbe <strtol+0x66>
  800d26:	eb 9e                	jmp    800cc6 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d28:	89 c2                	mov    %eax,%edx
  800d2a:	f7 da                	neg    %edx
  800d2c:	85 ff                	test   %edi,%edi
  800d2e:	0f 45 c2             	cmovne %edx,%eax
}
  800d31:	5b                   	pop    %ebx
  800d32:	5e                   	pop    %esi
  800d33:	5f                   	pop    %edi
  800d34:	5d                   	pop    %ebp
  800d35:	c3                   	ret    

00800d36 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d36:	55                   	push   %ebp
  800d37:	89 e5                	mov    %esp,%ebp
  800d39:	57                   	push   %edi
  800d3a:	56                   	push   %esi
  800d3b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800d41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d44:	8b 55 08             	mov    0x8(%ebp),%edx
  800d47:	89 c3                	mov    %eax,%ebx
  800d49:	89 c7                	mov    %eax,%edi
  800d4b:	89 c6                	mov    %eax,%esi
  800d4d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d4f:	5b                   	pop    %ebx
  800d50:	5e                   	pop    %esi
  800d51:	5f                   	pop    %edi
  800d52:	5d                   	pop    %ebp
  800d53:	c3                   	ret    

00800d54 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	57                   	push   %edi
  800d58:	56                   	push   %esi
  800d59:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d5f:	b8 01 00 00 00       	mov    $0x1,%eax
  800d64:	89 d1                	mov    %edx,%ecx
  800d66:	89 d3                	mov    %edx,%ebx
  800d68:	89 d7                	mov    %edx,%edi
  800d6a:	89 d6                	mov    %edx,%esi
  800d6c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d6e:	5b                   	pop    %ebx
  800d6f:	5e                   	pop    %esi
  800d70:	5f                   	pop    %edi
  800d71:	5d                   	pop    %ebp
  800d72:	c3                   	ret    

00800d73 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
  800d76:	57                   	push   %edi
  800d77:	56                   	push   %esi
  800d78:	53                   	push   %ebx
  800d79:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d81:	b8 03 00 00 00       	mov    $0x3,%eax
  800d86:	8b 55 08             	mov    0x8(%ebp),%edx
  800d89:	89 cb                	mov    %ecx,%ebx
  800d8b:	89 cf                	mov    %ecx,%edi
  800d8d:	89 ce                	mov    %ecx,%esi
  800d8f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d91:	85 c0                	test   %eax,%eax
  800d93:	7e 17                	jle    800dac <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d95:	83 ec 0c             	sub    $0xc,%esp
  800d98:	50                   	push   %eax
  800d99:	6a 03                	push   $0x3
  800d9b:	68 3f 28 80 00       	push   $0x80283f
  800da0:	6a 23                	push   $0x23
  800da2:	68 5c 28 80 00       	push   $0x80285c
  800da7:	e8 66 f5 ff ff       	call   800312 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800dac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800daf:	5b                   	pop    %ebx
  800db0:	5e                   	pop    %esi
  800db1:	5f                   	pop    %edi
  800db2:	5d                   	pop    %ebp
  800db3:	c3                   	ret    

00800db4 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800db4:	55                   	push   %ebp
  800db5:	89 e5                	mov    %esp,%ebp
  800db7:	57                   	push   %edi
  800db8:	56                   	push   %esi
  800db9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dba:	ba 00 00 00 00       	mov    $0x0,%edx
  800dbf:	b8 02 00 00 00       	mov    $0x2,%eax
  800dc4:	89 d1                	mov    %edx,%ecx
  800dc6:	89 d3                	mov    %edx,%ebx
  800dc8:	89 d7                	mov    %edx,%edi
  800dca:	89 d6                	mov    %edx,%esi
  800dcc:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800dce:	5b                   	pop    %ebx
  800dcf:	5e                   	pop    %esi
  800dd0:	5f                   	pop    %edi
  800dd1:	5d                   	pop    %ebp
  800dd2:	c3                   	ret    

00800dd3 <sys_yield>:

void
sys_yield(void)
{
  800dd3:	55                   	push   %ebp
  800dd4:	89 e5                	mov    %esp,%ebp
  800dd6:	57                   	push   %edi
  800dd7:	56                   	push   %esi
  800dd8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd9:	ba 00 00 00 00       	mov    $0x0,%edx
  800dde:	b8 0b 00 00 00       	mov    $0xb,%eax
  800de3:	89 d1                	mov    %edx,%ecx
  800de5:	89 d3                	mov    %edx,%ebx
  800de7:	89 d7                	mov    %edx,%edi
  800de9:	89 d6                	mov    %edx,%esi
  800deb:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ded:	5b                   	pop    %ebx
  800dee:	5e                   	pop    %esi
  800def:	5f                   	pop    %edi
  800df0:	5d                   	pop    %ebp
  800df1:	c3                   	ret    

00800df2 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800df2:	55                   	push   %ebp
  800df3:	89 e5                	mov    %esp,%ebp
  800df5:	57                   	push   %edi
  800df6:	56                   	push   %esi
  800df7:	53                   	push   %ebx
  800df8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfb:	be 00 00 00 00       	mov    $0x0,%esi
  800e00:	b8 04 00 00 00       	mov    $0x4,%eax
  800e05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e08:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e0e:	89 f7                	mov    %esi,%edi
  800e10:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e12:	85 c0                	test   %eax,%eax
  800e14:	7e 17                	jle    800e2d <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e16:	83 ec 0c             	sub    $0xc,%esp
  800e19:	50                   	push   %eax
  800e1a:	6a 04                	push   $0x4
  800e1c:	68 3f 28 80 00       	push   $0x80283f
  800e21:	6a 23                	push   $0x23
  800e23:	68 5c 28 80 00       	push   $0x80285c
  800e28:	e8 e5 f4 ff ff       	call   800312 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e30:	5b                   	pop    %ebx
  800e31:	5e                   	pop    %esi
  800e32:	5f                   	pop    %edi
  800e33:	5d                   	pop    %ebp
  800e34:	c3                   	ret    

00800e35 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e35:	55                   	push   %ebp
  800e36:	89 e5                	mov    %esp,%ebp
  800e38:	57                   	push   %edi
  800e39:	56                   	push   %esi
  800e3a:	53                   	push   %ebx
  800e3b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e3e:	b8 05 00 00 00       	mov    $0x5,%eax
  800e43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e46:	8b 55 08             	mov    0x8(%ebp),%edx
  800e49:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e4c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e4f:	8b 75 18             	mov    0x18(%ebp),%esi
  800e52:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e54:	85 c0                	test   %eax,%eax
  800e56:	7e 17                	jle    800e6f <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e58:	83 ec 0c             	sub    $0xc,%esp
  800e5b:	50                   	push   %eax
  800e5c:	6a 05                	push   $0x5
  800e5e:	68 3f 28 80 00       	push   $0x80283f
  800e63:	6a 23                	push   $0x23
  800e65:	68 5c 28 80 00       	push   $0x80285c
  800e6a:	e8 a3 f4 ff ff       	call   800312 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e72:	5b                   	pop    %ebx
  800e73:	5e                   	pop    %esi
  800e74:	5f                   	pop    %edi
  800e75:	5d                   	pop    %ebp
  800e76:	c3                   	ret    

00800e77 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e77:	55                   	push   %ebp
  800e78:	89 e5                	mov    %esp,%ebp
  800e7a:	57                   	push   %edi
  800e7b:	56                   	push   %esi
  800e7c:	53                   	push   %ebx
  800e7d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e80:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e85:	b8 06 00 00 00       	mov    $0x6,%eax
  800e8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e90:	89 df                	mov    %ebx,%edi
  800e92:	89 de                	mov    %ebx,%esi
  800e94:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e96:	85 c0                	test   %eax,%eax
  800e98:	7e 17                	jle    800eb1 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e9a:	83 ec 0c             	sub    $0xc,%esp
  800e9d:	50                   	push   %eax
  800e9e:	6a 06                	push   $0x6
  800ea0:	68 3f 28 80 00       	push   $0x80283f
  800ea5:	6a 23                	push   $0x23
  800ea7:	68 5c 28 80 00       	push   $0x80285c
  800eac:	e8 61 f4 ff ff       	call   800312 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800eb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eb4:	5b                   	pop    %ebx
  800eb5:	5e                   	pop    %esi
  800eb6:	5f                   	pop    %edi
  800eb7:	5d                   	pop    %ebp
  800eb8:	c3                   	ret    

00800eb9 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800eb9:	55                   	push   %ebp
  800eba:	89 e5                	mov    %esp,%ebp
  800ebc:	57                   	push   %edi
  800ebd:	56                   	push   %esi
  800ebe:	53                   	push   %ebx
  800ebf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ec7:	b8 08 00 00 00       	mov    $0x8,%eax
  800ecc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ecf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed2:	89 df                	mov    %ebx,%edi
  800ed4:	89 de                	mov    %ebx,%esi
  800ed6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ed8:	85 c0                	test   %eax,%eax
  800eda:	7e 17                	jle    800ef3 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800edc:	83 ec 0c             	sub    $0xc,%esp
  800edf:	50                   	push   %eax
  800ee0:	6a 08                	push   $0x8
  800ee2:	68 3f 28 80 00       	push   $0x80283f
  800ee7:	6a 23                	push   $0x23
  800ee9:	68 5c 28 80 00       	push   $0x80285c
  800eee:	e8 1f f4 ff ff       	call   800312 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ef3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ef6:	5b                   	pop    %ebx
  800ef7:	5e                   	pop    %esi
  800ef8:	5f                   	pop    %edi
  800ef9:	5d                   	pop    %ebp
  800efa:	c3                   	ret    

00800efb <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	57                   	push   %edi
  800eff:	56                   	push   %esi
  800f00:	53                   	push   %ebx
  800f01:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f04:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f09:	b8 09 00 00 00       	mov    $0x9,%eax
  800f0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f11:	8b 55 08             	mov    0x8(%ebp),%edx
  800f14:	89 df                	mov    %ebx,%edi
  800f16:	89 de                	mov    %ebx,%esi
  800f18:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f1a:	85 c0                	test   %eax,%eax
  800f1c:	7e 17                	jle    800f35 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f1e:	83 ec 0c             	sub    $0xc,%esp
  800f21:	50                   	push   %eax
  800f22:	6a 09                	push   $0x9
  800f24:	68 3f 28 80 00       	push   $0x80283f
  800f29:	6a 23                	push   $0x23
  800f2b:	68 5c 28 80 00       	push   $0x80285c
  800f30:	e8 dd f3 ff ff       	call   800312 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f38:	5b                   	pop    %ebx
  800f39:	5e                   	pop    %esi
  800f3a:	5f                   	pop    %edi
  800f3b:	5d                   	pop    %ebp
  800f3c:	c3                   	ret    

00800f3d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f3d:	55                   	push   %ebp
  800f3e:	89 e5                	mov    %esp,%ebp
  800f40:	57                   	push   %edi
  800f41:	56                   	push   %esi
  800f42:	53                   	push   %ebx
  800f43:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f46:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f4b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f53:	8b 55 08             	mov    0x8(%ebp),%edx
  800f56:	89 df                	mov    %ebx,%edi
  800f58:	89 de                	mov    %ebx,%esi
  800f5a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f5c:	85 c0                	test   %eax,%eax
  800f5e:	7e 17                	jle    800f77 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f60:	83 ec 0c             	sub    $0xc,%esp
  800f63:	50                   	push   %eax
  800f64:	6a 0a                	push   $0xa
  800f66:	68 3f 28 80 00       	push   $0x80283f
  800f6b:	6a 23                	push   $0x23
  800f6d:	68 5c 28 80 00       	push   $0x80285c
  800f72:	e8 9b f3 ff ff       	call   800312 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f7a:	5b                   	pop    %ebx
  800f7b:	5e                   	pop    %esi
  800f7c:	5f                   	pop    %edi
  800f7d:	5d                   	pop    %ebp
  800f7e:	c3                   	ret    

00800f7f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f7f:	55                   	push   %ebp
  800f80:	89 e5                	mov    %esp,%ebp
  800f82:	57                   	push   %edi
  800f83:	56                   	push   %esi
  800f84:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f85:	be 00 00 00 00       	mov    $0x0,%esi
  800f8a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f92:	8b 55 08             	mov    0x8(%ebp),%edx
  800f95:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f98:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f9b:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f9d:	5b                   	pop    %ebx
  800f9e:	5e                   	pop    %esi
  800f9f:	5f                   	pop    %edi
  800fa0:	5d                   	pop    %ebp
  800fa1:	c3                   	ret    

00800fa2 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800fa2:	55                   	push   %ebp
  800fa3:	89 e5                	mov    %esp,%ebp
  800fa5:	57                   	push   %edi
  800fa6:	56                   	push   %esi
  800fa7:	53                   	push   %ebx
  800fa8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fab:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fb0:	b8 0d 00 00 00       	mov    $0xd,%eax
  800fb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb8:	89 cb                	mov    %ecx,%ebx
  800fba:	89 cf                	mov    %ecx,%edi
  800fbc:	89 ce                	mov    %ecx,%esi
  800fbe:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fc0:	85 c0                	test   %eax,%eax
  800fc2:	7e 17                	jle    800fdb <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fc4:	83 ec 0c             	sub    $0xc,%esp
  800fc7:	50                   	push   %eax
  800fc8:	6a 0d                	push   $0xd
  800fca:	68 3f 28 80 00       	push   $0x80283f
  800fcf:	6a 23                	push   $0x23
  800fd1:	68 5c 28 80 00       	push   $0x80285c
  800fd6:	e8 37 f3 ff ff       	call   800312 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fdb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fde:	5b                   	pop    %ebx
  800fdf:	5e                   	pop    %esi
  800fe0:	5f                   	pop    %edi
  800fe1:	5d                   	pop    %ebp
  800fe2:	c3                   	ret    

00800fe3 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800fe3:	55                   	push   %ebp
  800fe4:	89 e5                	mov    %esp,%ebp
  800fe6:	57                   	push   %edi
  800fe7:	56                   	push   %esi
  800fe8:	53                   	push   %ebx
  800fe9:	83 ec 0c             	sub    $0xc,%esp
  800fec:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800fef:	8b 18                	mov    (%eax),%ebx
	uint32_t err = utf->utf_err;
  800ff1:	8b 78 04             	mov    0x4(%eax),%edi
	int r;
	envid_t curenvid = sys_getenvid();
  800ff4:	e8 bb fd ff ff       	call   800db4 <sys_getenvid>
  800ff9:	89 c6                	mov    %eax,%esi
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(err & FEC_WR) && !(uvpt[PGNUM(addr)] & PTE_COW))
  800ffb:	f7 c7 02 00 00 00    	test   $0x2,%edi
  801001:	75 25                	jne    801028 <pgfault+0x45>
  801003:	89 d8                	mov    %ebx,%eax
  801005:	c1 e8 0c             	shr    $0xc,%eax
  801008:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80100f:	f6 c4 08             	test   $0x8,%ah
  801012:	75 14                	jne    801028 <pgfault+0x45>
	    panic("pgfault error: wrong faulting access");
  801014:	83 ec 04             	sub    $0x4,%esp
  801017:	68 6c 28 80 00       	push   $0x80286c
  80101c:	6a 1e                	push   $0x1e
  80101e:	68 91 28 80 00       	push   $0x802891
  801023:	e8 ea f2 ff ff       	call   800312 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	sys_page_alloc(curenvid, PFTEMP, PTE_W | PTE_U | PTE_P);
  801028:	83 ec 04             	sub    $0x4,%esp
  80102b:	6a 07                	push   $0x7
  80102d:	68 00 f0 7f 00       	push   $0x7ff000
  801032:	56                   	push   %esi
  801033:	e8 ba fd ff ff       	call   800df2 <sys_page_alloc>

	addr = (void *)(PGNUM(addr) * PGSIZE);
  801038:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr, PGSIZE);
  80103e:	83 c4 0c             	add    $0xc,%esp
  801041:	68 00 10 00 00       	push   $0x1000
  801046:	53                   	push   %ebx
  801047:	68 00 f0 7f 00       	push   $0x7ff000
  80104c:	e8 30 fb ff ff       	call   800b81 <memmove>

	sys_page_unmap(curenvid, addr);
  801051:	83 c4 08             	add    $0x8,%esp
  801054:	53                   	push   %ebx
  801055:	56                   	push   %esi
  801056:	e8 1c fe ff ff       	call   800e77 <sys_page_unmap>
	sys_page_map(curenvid, PFTEMP, curenvid, addr, PTE_W | PTE_U | PTE_P);
  80105b:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801062:	53                   	push   %ebx
  801063:	56                   	push   %esi
  801064:	68 00 f0 7f 00       	push   $0x7ff000
  801069:	56                   	push   %esi
  80106a:	e8 c6 fd ff ff       	call   800e35 <sys_page_map>
	sys_page_unmap(curenvid, PFTEMP);
  80106f:	83 c4 18             	add    $0x18,%esp
  801072:	68 00 f0 7f 00       	push   $0x7ff000
  801077:	56                   	push   %esi
  801078:	e8 fa fd ff ff       	call   800e77 <sys_page_unmap>
}
  80107d:	83 c4 10             	add    $0x10,%esp
  801080:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801083:	5b                   	pop    %ebx
  801084:	5e                   	pop    %esi
  801085:	5f                   	pop    %edi
  801086:	5d                   	pop    %ebp
  801087:	c3                   	ret    

00801088 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801088:	55                   	push   %ebp
  801089:	89 e5                	mov    %esp,%ebp
  80108b:	57                   	push   %edi
  80108c:	56                   	push   %esi
  80108d:	53                   	push   %ebx
  80108e:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	extern void _pgfault_upcall();
	envid_t new_envid, curenv_id;

	curenv_id = sys_getenvid();
  801091:	e8 1e fd ff ff       	call   800db4 <sys_getenvid>
	set_pgfault_handler(pgfault);
  801096:	83 ec 0c             	sub    $0xc,%esp
  801099:	68 e3 0f 80 00       	push   $0x800fe3
  80109e:	e8 d2 0e 00 00       	call   801f75 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8010a3:	b8 07 00 00 00       	mov    $0x7,%eax
  8010a8:	cd 30                	int    $0x30
  8010aa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8010ad:	89 45 dc             	mov    %eax,-0x24(%ebp)
	new_envid = sys_exofork();

	if (new_envid < 0)
  8010b0:	83 c4 10             	add    $0x10,%esp
  8010b3:	85 c0                	test   %eax,%eax
  8010b5:	79 12                	jns    8010c9 <fork+0x41>
	    panic("fork error: %e", new_envid);
  8010b7:	50                   	push   %eax
  8010b8:	68 9c 28 80 00       	push   $0x80289c
  8010bd:	6a 75                	push   $0x75
  8010bf:	68 91 28 80 00       	push   $0x802891
  8010c4:	e8 49 f2 ff ff       	call   800312 <_panic>
  8010c9:	bf 00 00 80 00       	mov    $0x800000,%edi
	else if (new_envid == 0)
  8010ce:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8010d2:	75 1c                	jne    8010f0 <fork+0x68>
		thisenv = envs + ENVX(sys_getenvid());
  8010d4:	e8 db fc ff ff       	call   800db4 <sys_getenvid>
  8010d9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010de:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010e1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010e6:	a3 04 40 80 00       	mov    %eax,0x804004
  8010eb:	e9 27 01 00 00       	jmp    801217 <fork+0x18f>
	else {

		for (uint32_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
			if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
  8010f0:	89 f8                	mov    %edi,%eax
  8010f2:	c1 e8 16             	shr    $0x16,%eax
  8010f5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010fc:	a8 01                	test   $0x1,%al
  8010fe:	0f 84 d2 00 00 00    	je     8011d6 <fork+0x14e>
  801104:	89 fb                	mov    %edi,%ebx
  801106:	c1 eb 0c             	shr    $0xc,%ebx
  801109:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801110:	a8 01                	test   $0x1,%al
  801112:	0f 84 be 00 00 00    	je     8011d6 <fork+0x14e>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	int perm = PTE_U | PTE_P;
	envid_t curenvid = sys_getenvid();
  801118:	e8 97 fc ff ff       	call   800db4 <sys_getenvid>
  80111d:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  801120:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
		perm |= PTE_COW ;
  801127:	be 05 08 00 00       	mov    $0x805,%esi
	int r;
	int perm = PTE_U | PTE_P;
	envid_t curenvid = sys_getenvid();

	// LAB 4: Your code here.
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  80112c:	a8 02                	test   $0x2,%al
  80112e:	75 1d                	jne    80114d <fork+0xc5>
  801130:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801137:	25 00 08 00 00       	and    $0x800,%eax
		perm |= PTE_COW ;
  80113c:	83 f8 01             	cmp    $0x1,%eax
  80113f:	19 f6                	sbb    %esi,%esi
  801141:	81 e6 00 f8 ff ff    	and    $0xfffff800,%esi
  801147:	81 c6 05 08 00 00    	add    $0x805,%esi

	if (uvpt[pn] & PTE_SHARE)
  80114d:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801154:	25 00 04 00 00       	and    $0x400,%eax
		perm |= PTE_SYSCALL;
  801159:	b8 07 0e 00 00       	mov    $0xe07,%eax
  80115e:	0f 45 f0             	cmovne %eax,%esi

	r = sys_page_map(curenvid, (void *)(pn * PGSIZE),
  801161:	89 d8                	mov    %ebx,%eax
  801163:	c1 e0 0c             	shl    $0xc,%eax
  801166:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801169:	83 ec 0c             	sub    $0xc,%esp
  80116c:	56                   	push   %esi
  80116d:	50                   	push   %eax
  80116e:	ff 75 dc             	pushl  -0x24(%ebp)
  801171:	50                   	push   %eax
  801172:	ff 75 e4             	pushl  -0x1c(%ebp)
  801175:	e8 bb fc ff ff       	call   800e35 <sys_page_map>
				envid, (void *)(pn * PGSIZE), perm);
	if (r < 0)
  80117a:	83 c4 20             	add    $0x20,%esp
  80117d:	85 c0                	test   %eax,%eax
  80117f:	79 12                	jns    801193 <fork+0x10b>
		panic("duppage error: %e", r);
  801181:	50                   	push   %eax
  801182:	68 ab 28 80 00       	push   $0x8028ab
  801187:	6a 4d                	push   $0x4d
  801189:	68 91 28 80 00       	push   $0x802891
  80118e:	e8 7f f1 ff ff       	call   800312 <_panic>
	
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))	{
  801193:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80119a:	a8 02                	test   $0x2,%al
  80119c:	75 0c                	jne    8011aa <fork+0x122>
  80119e:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  8011a5:	f6 c4 08             	test   $0x8,%ah
  8011a8:	74 2c                	je     8011d6 <fork+0x14e>
		r = sys_page_map(curenvid, (void *)(pn * PGSIZE),
  8011aa:	83 ec 0c             	sub    $0xc,%esp
  8011ad:	56                   	push   %esi
  8011ae:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8011b1:	52                   	push   %edx
  8011b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011b5:	50                   	push   %eax
  8011b6:	52                   	push   %edx
  8011b7:	50                   	push   %eax
  8011b8:	e8 78 fc ff ff       	call   800e35 <sys_page_map>
						curenvid, (void *)(pn * PGSIZE), perm);
		if (r < 0)
  8011bd:	83 c4 20             	add    $0x20,%esp
  8011c0:	85 c0                	test   %eax,%eax
  8011c2:	79 12                	jns    8011d6 <fork+0x14e>
			panic("duppage error: %e", r);
  8011c4:	50                   	push   %eax
  8011c5:	68 ab 28 80 00       	push   $0x8028ab
  8011ca:	6a 53                	push   $0x53
  8011cc:	68 91 28 80 00       	push   $0x802891
  8011d1:	e8 3c f1 ff ff       	call   800312 <_panic>
	    panic("fork error: %e", new_envid);
	else if (new_envid == 0)
		thisenv = envs + ENVX(sys_getenvid());
	else {

		for (uint32_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
  8011d6:	81 c7 00 10 00 00    	add    $0x1000,%edi
  8011dc:	81 ff 00 e0 bf ee    	cmp    $0xeebfe000,%edi
  8011e2:	0f 85 08 ff ff ff    	jne    8010f0 <fork+0x68>
			if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
				duppage(new_envid, PGNUM(addr));
		}

		sys_page_alloc(new_envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  8011e8:	83 ec 04             	sub    $0x4,%esp
  8011eb:	6a 07                	push   $0x7
  8011ed:	68 00 f0 bf ee       	push   $0xeebff000
  8011f2:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8011f5:	56                   	push   %esi
  8011f6:	e8 f7 fb ff ff       	call   800df2 <sys_page_alloc>
		sys_env_set_pgfault_upcall(new_envid, _pgfault_upcall);
  8011fb:	83 c4 08             	add    $0x8,%esp
  8011fe:	68 ba 1f 80 00       	push   $0x801fba
  801203:	56                   	push   %esi
  801204:	e8 34 fd ff ff       	call   800f3d <sys_env_set_pgfault_upcall>
		sys_env_set_status(new_envid, ENV_RUNNABLE);
  801209:	83 c4 08             	add    $0x8,%esp
  80120c:	6a 02                	push   $0x2
  80120e:	56                   	push   %esi
  80120f:	e8 a5 fc ff ff       	call   800eb9 <sys_env_set_status>
  801214:	83 c4 10             	add    $0x10,%esp

	}
	return new_envid;
}
  801217:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80121a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80121d:	5b                   	pop    %ebx
  80121e:	5e                   	pop    %esi
  80121f:	5f                   	pop    %edi
  801220:	5d                   	pop    %ebp
  801221:	c3                   	ret    

00801222 <sfork>:

// Challenge!
int
sfork(void)
{
  801222:	55                   	push   %ebp
  801223:	89 e5                	mov    %esp,%ebp
  801225:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801228:	68 bd 28 80 00       	push   $0x8028bd
  80122d:	68 8b 00 00 00       	push   $0x8b
  801232:	68 91 28 80 00       	push   $0x802891
  801237:	e8 d6 f0 ff ff       	call   800312 <_panic>

0080123c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80123c:	55                   	push   %ebp
  80123d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80123f:	8b 45 08             	mov    0x8(%ebp),%eax
  801242:	05 00 00 00 30       	add    $0x30000000,%eax
  801247:	c1 e8 0c             	shr    $0xc,%eax
}
  80124a:	5d                   	pop    %ebp
  80124b:	c3                   	ret    

0080124c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80124c:	55                   	push   %ebp
  80124d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80124f:	8b 45 08             	mov    0x8(%ebp),%eax
  801252:	05 00 00 00 30       	add    $0x30000000,%eax
  801257:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80125c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801261:	5d                   	pop    %ebp
  801262:	c3                   	ret    

00801263 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801263:	55                   	push   %ebp
  801264:	89 e5                	mov    %esp,%ebp
  801266:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801269:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80126e:	89 c2                	mov    %eax,%edx
  801270:	c1 ea 16             	shr    $0x16,%edx
  801273:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80127a:	f6 c2 01             	test   $0x1,%dl
  80127d:	74 11                	je     801290 <fd_alloc+0x2d>
  80127f:	89 c2                	mov    %eax,%edx
  801281:	c1 ea 0c             	shr    $0xc,%edx
  801284:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80128b:	f6 c2 01             	test   $0x1,%dl
  80128e:	75 09                	jne    801299 <fd_alloc+0x36>
			*fd_store = fd;
  801290:	89 01                	mov    %eax,(%ecx)
			return 0;
  801292:	b8 00 00 00 00       	mov    $0x0,%eax
  801297:	eb 17                	jmp    8012b0 <fd_alloc+0x4d>
  801299:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80129e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012a3:	75 c9                	jne    80126e <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012a5:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012ab:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012b0:	5d                   	pop    %ebp
  8012b1:	c3                   	ret    

008012b2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012b2:	55                   	push   %ebp
  8012b3:	89 e5                	mov    %esp,%ebp
  8012b5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012b8:	83 f8 1f             	cmp    $0x1f,%eax
  8012bb:	77 36                	ja     8012f3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012bd:	c1 e0 0c             	shl    $0xc,%eax
  8012c0:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012c5:	89 c2                	mov    %eax,%edx
  8012c7:	c1 ea 16             	shr    $0x16,%edx
  8012ca:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012d1:	f6 c2 01             	test   $0x1,%dl
  8012d4:	74 24                	je     8012fa <fd_lookup+0x48>
  8012d6:	89 c2                	mov    %eax,%edx
  8012d8:	c1 ea 0c             	shr    $0xc,%edx
  8012db:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012e2:	f6 c2 01             	test   $0x1,%dl
  8012e5:	74 1a                	je     801301 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ea:	89 02                	mov    %eax,(%edx)
	return 0;
  8012ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8012f1:	eb 13                	jmp    801306 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012f3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012f8:	eb 0c                	jmp    801306 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012ff:	eb 05                	jmp    801306 <fd_lookup+0x54>
  801301:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801306:	5d                   	pop    %ebp
  801307:	c3                   	ret    

00801308 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801308:	55                   	push   %ebp
  801309:	89 e5                	mov    %esp,%ebp
  80130b:	83 ec 08             	sub    $0x8,%esp
  80130e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801311:	ba 54 29 80 00       	mov    $0x802954,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801316:	eb 13                	jmp    80132b <dev_lookup+0x23>
  801318:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80131b:	39 08                	cmp    %ecx,(%eax)
  80131d:	75 0c                	jne    80132b <dev_lookup+0x23>
			*dev = devtab[i];
  80131f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801322:	89 01                	mov    %eax,(%ecx)
			return 0;
  801324:	b8 00 00 00 00       	mov    $0x0,%eax
  801329:	eb 2e                	jmp    801359 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80132b:	8b 02                	mov    (%edx),%eax
  80132d:	85 c0                	test   %eax,%eax
  80132f:	75 e7                	jne    801318 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801331:	a1 04 40 80 00       	mov    0x804004,%eax
  801336:	8b 40 48             	mov    0x48(%eax),%eax
  801339:	83 ec 04             	sub    $0x4,%esp
  80133c:	51                   	push   %ecx
  80133d:	50                   	push   %eax
  80133e:	68 d4 28 80 00       	push   $0x8028d4
  801343:	e8 a3 f0 ff ff       	call   8003eb <cprintf>
	*dev = 0;
  801348:	8b 45 0c             	mov    0xc(%ebp),%eax
  80134b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801351:	83 c4 10             	add    $0x10,%esp
  801354:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801359:	c9                   	leave  
  80135a:	c3                   	ret    

0080135b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80135b:	55                   	push   %ebp
  80135c:	89 e5                	mov    %esp,%ebp
  80135e:	56                   	push   %esi
  80135f:	53                   	push   %ebx
  801360:	83 ec 10             	sub    $0x10,%esp
  801363:	8b 75 08             	mov    0x8(%ebp),%esi
  801366:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801369:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80136c:	50                   	push   %eax
  80136d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801373:	c1 e8 0c             	shr    $0xc,%eax
  801376:	50                   	push   %eax
  801377:	e8 36 ff ff ff       	call   8012b2 <fd_lookup>
  80137c:	83 c4 08             	add    $0x8,%esp
  80137f:	85 c0                	test   %eax,%eax
  801381:	78 05                	js     801388 <fd_close+0x2d>
	    || fd != fd2)
  801383:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801386:	74 0c                	je     801394 <fd_close+0x39>
		return (must_exist ? r : 0);
  801388:	84 db                	test   %bl,%bl
  80138a:	ba 00 00 00 00       	mov    $0x0,%edx
  80138f:	0f 44 c2             	cmove  %edx,%eax
  801392:	eb 41                	jmp    8013d5 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801394:	83 ec 08             	sub    $0x8,%esp
  801397:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80139a:	50                   	push   %eax
  80139b:	ff 36                	pushl  (%esi)
  80139d:	e8 66 ff ff ff       	call   801308 <dev_lookup>
  8013a2:	89 c3                	mov    %eax,%ebx
  8013a4:	83 c4 10             	add    $0x10,%esp
  8013a7:	85 c0                	test   %eax,%eax
  8013a9:	78 1a                	js     8013c5 <fd_close+0x6a>
		if (dev->dev_close)
  8013ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ae:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013b1:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013b6:	85 c0                	test   %eax,%eax
  8013b8:	74 0b                	je     8013c5 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013ba:	83 ec 0c             	sub    $0xc,%esp
  8013bd:	56                   	push   %esi
  8013be:	ff d0                	call   *%eax
  8013c0:	89 c3                	mov    %eax,%ebx
  8013c2:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013c5:	83 ec 08             	sub    $0x8,%esp
  8013c8:	56                   	push   %esi
  8013c9:	6a 00                	push   $0x0
  8013cb:	e8 a7 fa ff ff       	call   800e77 <sys_page_unmap>
	return r;
  8013d0:	83 c4 10             	add    $0x10,%esp
  8013d3:	89 d8                	mov    %ebx,%eax
}
  8013d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013d8:	5b                   	pop    %ebx
  8013d9:	5e                   	pop    %esi
  8013da:	5d                   	pop    %ebp
  8013db:	c3                   	ret    

008013dc <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013dc:	55                   	push   %ebp
  8013dd:	89 e5                	mov    %esp,%ebp
  8013df:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013e5:	50                   	push   %eax
  8013e6:	ff 75 08             	pushl  0x8(%ebp)
  8013e9:	e8 c4 fe ff ff       	call   8012b2 <fd_lookup>
  8013ee:	83 c4 08             	add    $0x8,%esp
  8013f1:	85 c0                	test   %eax,%eax
  8013f3:	78 10                	js     801405 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013f5:	83 ec 08             	sub    $0x8,%esp
  8013f8:	6a 01                	push   $0x1
  8013fa:	ff 75 f4             	pushl  -0xc(%ebp)
  8013fd:	e8 59 ff ff ff       	call   80135b <fd_close>
  801402:	83 c4 10             	add    $0x10,%esp
}
  801405:	c9                   	leave  
  801406:	c3                   	ret    

00801407 <close_all>:

void
close_all(void)
{
  801407:	55                   	push   %ebp
  801408:	89 e5                	mov    %esp,%ebp
  80140a:	53                   	push   %ebx
  80140b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80140e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801413:	83 ec 0c             	sub    $0xc,%esp
  801416:	53                   	push   %ebx
  801417:	e8 c0 ff ff ff       	call   8013dc <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80141c:	83 c3 01             	add    $0x1,%ebx
  80141f:	83 c4 10             	add    $0x10,%esp
  801422:	83 fb 20             	cmp    $0x20,%ebx
  801425:	75 ec                	jne    801413 <close_all+0xc>
		close(i);
}
  801427:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80142a:	c9                   	leave  
  80142b:	c3                   	ret    

0080142c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80142c:	55                   	push   %ebp
  80142d:	89 e5                	mov    %esp,%ebp
  80142f:	57                   	push   %edi
  801430:	56                   	push   %esi
  801431:	53                   	push   %ebx
  801432:	83 ec 2c             	sub    $0x2c,%esp
  801435:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801438:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80143b:	50                   	push   %eax
  80143c:	ff 75 08             	pushl  0x8(%ebp)
  80143f:	e8 6e fe ff ff       	call   8012b2 <fd_lookup>
  801444:	83 c4 08             	add    $0x8,%esp
  801447:	85 c0                	test   %eax,%eax
  801449:	0f 88 c1 00 00 00    	js     801510 <dup+0xe4>
		return r;
	close(newfdnum);
  80144f:	83 ec 0c             	sub    $0xc,%esp
  801452:	56                   	push   %esi
  801453:	e8 84 ff ff ff       	call   8013dc <close>

	newfd = INDEX2FD(newfdnum);
  801458:	89 f3                	mov    %esi,%ebx
  80145a:	c1 e3 0c             	shl    $0xc,%ebx
  80145d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801463:	83 c4 04             	add    $0x4,%esp
  801466:	ff 75 e4             	pushl  -0x1c(%ebp)
  801469:	e8 de fd ff ff       	call   80124c <fd2data>
  80146e:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801470:	89 1c 24             	mov    %ebx,(%esp)
  801473:	e8 d4 fd ff ff       	call   80124c <fd2data>
  801478:	83 c4 10             	add    $0x10,%esp
  80147b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80147e:	89 f8                	mov    %edi,%eax
  801480:	c1 e8 16             	shr    $0x16,%eax
  801483:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80148a:	a8 01                	test   $0x1,%al
  80148c:	74 37                	je     8014c5 <dup+0x99>
  80148e:	89 f8                	mov    %edi,%eax
  801490:	c1 e8 0c             	shr    $0xc,%eax
  801493:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80149a:	f6 c2 01             	test   $0x1,%dl
  80149d:	74 26                	je     8014c5 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80149f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014a6:	83 ec 0c             	sub    $0xc,%esp
  8014a9:	25 07 0e 00 00       	and    $0xe07,%eax
  8014ae:	50                   	push   %eax
  8014af:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014b2:	6a 00                	push   $0x0
  8014b4:	57                   	push   %edi
  8014b5:	6a 00                	push   $0x0
  8014b7:	e8 79 f9 ff ff       	call   800e35 <sys_page_map>
  8014bc:	89 c7                	mov    %eax,%edi
  8014be:	83 c4 20             	add    $0x20,%esp
  8014c1:	85 c0                	test   %eax,%eax
  8014c3:	78 2e                	js     8014f3 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014c5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014c8:	89 d0                	mov    %edx,%eax
  8014ca:	c1 e8 0c             	shr    $0xc,%eax
  8014cd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014d4:	83 ec 0c             	sub    $0xc,%esp
  8014d7:	25 07 0e 00 00       	and    $0xe07,%eax
  8014dc:	50                   	push   %eax
  8014dd:	53                   	push   %ebx
  8014de:	6a 00                	push   $0x0
  8014e0:	52                   	push   %edx
  8014e1:	6a 00                	push   $0x0
  8014e3:	e8 4d f9 ff ff       	call   800e35 <sys_page_map>
  8014e8:	89 c7                	mov    %eax,%edi
  8014ea:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014ed:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014ef:	85 ff                	test   %edi,%edi
  8014f1:	79 1d                	jns    801510 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014f3:	83 ec 08             	sub    $0x8,%esp
  8014f6:	53                   	push   %ebx
  8014f7:	6a 00                	push   $0x0
  8014f9:	e8 79 f9 ff ff       	call   800e77 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014fe:	83 c4 08             	add    $0x8,%esp
  801501:	ff 75 d4             	pushl  -0x2c(%ebp)
  801504:	6a 00                	push   $0x0
  801506:	e8 6c f9 ff ff       	call   800e77 <sys_page_unmap>
	return r;
  80150b:	83 c4 10             	add    $0x10,%esp
  80150e:	89 f8                	mov    %edi,%eax
}
  801510:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801513:	5b                   	pop    %ebx
  801514:	5e                   	pop    %esi
  801515:	5f                   	pop    %edi
  801516:	5d                   	pop    %ebp
  801517:	c3                   	ret    

00801518 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801518:	55                   	push   %ebp
  801519:	89 e5                	mov    %esp,%ebp
  80151b:	53                   	push   %ebx
  80151c:	83 ec 14             	sub    $0x14,%esp
  80151f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801522:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801525:	50                   	push   %eax
  801526:	53                   	push   %ebx
  801527:	e8 86 fd ff ff       	call   8012b2 <fd_lookup>
  80152c:	83 c4 08             	add    $0x8,%esp
  80152f:	89 c2                	mov    %eax,%edx
  801531:	85 c0                	test   %eax,%eax
  801533:	78 6d                	js     8015a2 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801535:	83 ec 08             	sub    $0x8,%esp
  801538:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80153b:	50                   	push   %eax
  80153c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153f:	ff 30                	pushl  (%eax)
  801541:	e8 c2 fd ff ff       	call   801308 <dev_lookup>
  801546:	83 c4 10             	add    $0x10,%esp
  801549:	85 c0                	test   %eax,%eax
  80154b:	78 4c                	js     801599 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80154d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801550:	8b 42 08             	mov    0x8(%edx),%eax
  801553:	83 e0 03             	and    $0x3,%eax
  801556:	83 f8 01             	cmp    $0x1,%eax
  801559:	75 21                	jne    80157c <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80155b:	a1 04 40 80 00       	mov    0x804004,%eax
  801560:	8b 40 48             	mov    0x48(%eax),%eax
  801563:	83 ec 04             	sub    $0x4,%esp
  801566:	53                   	push   %ebx
  801567:	50                   	push   %eax
  801568:	68 18 29 80 00       	push   $0x802918
  80156d:	e8 79 ee ff ff       	call   8003eb <cprintf>
		return -E_INVAL;
  801572:	83 c4 10             	add    $0x10,%esp
  801575:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80157a:	eb 26                	jmp    8015a2 <read+0x8a>
	}
	if (!dev->dev_read)
  80157c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80157f:	8b 40 08             	mov    0x8(%eax),%eax
  801582:	85 c0                	test   %eax,%eax
  801584:	74 17                	je     80159d <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801586:	83 ec 04             	sub    $0x4,%esp
  801589:	ff 75 10             	pushl  0x10(%ebp)
  80158c:	ff 75 0c             	pushl  0xc(%ebp)
  80158f:	52                   	push   %edx
  801590:	ff d0                	call   *%eax
  801592:	89 c2                	mov    %eax,%edx
  801594:	83 c4 10             	add    $0x10,%esp
  801597:	eb 09                	jmp    8015a2 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801599:	89 c2                	mov    %eax,%edx
  80159b:	eb 05                	jmp    8015a2 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80159d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8015a2:	89 d0                	mov    %edx,%eax
  8015a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a7:	c9                   	leave  
  8015a8:	c3                   	ret    

008015a9 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015a9:	55                   	push   %ebp
  8015aa:	89 e5                	mov    %esp,%ebp
  8015ac:	57                   	push   %edi
  8015ad:	56                   	push   %esi
  8015ae:	53                   	push   %ebx
  8015af:	83 ec 0c             	sub    $0xc,%esp
  8015b2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015b5:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015b8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015bd:	eb 21                	jmp    8015e0 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015bf:	83 ec 04             	sub    $0x4,%esp
  8015c2:	89 f0                	mov    %esi,%eax
  8015c4:	29 d8                	sub    %ebx,%eax
  8015c6:	50                   	push   %eax
  8015c7:	89 d8                	mov    %ebx,%eax
  8015c9:	03 45 0c             	add    0xc(%ebp),%eax
  8015cc:	50                   	push   %eax
  8015cd:	57                   	push   %edi
  8015ce:	e8 45 ff ff ff       	call   801518 <read>
		if (m < 0)
  8015d3:	83 c4 10             	add    $0x10,%esp
  8015d6:	85 c0                	test   %eax,%eax
  8015d8:	78 10                	js     8015ea <readn+0x41>
			return m;
		if (m == 0)
  8015da:	85 c0                	test   %eax,%eax
  8015dc:	74 0a                	je     8015e8 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015de:	01 c3                	add    %eax,%ebx
  8015e0:	39 f3                	cmp    %esi,%ebx
  8015e2:	72 db                	jb     8015bf <readn+0x16>
  8015e4:	89 d8                	mov    %ebx,%eax
  8015e6:	eb 02                	jmp    8015ea <readn+0x41>
  8015e8:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015ed:	5b                   	pop    %ebx
  8015ee:	5e                   	pop    %esi
  8015ef:	5f                   	pop    %edi
  8015f0:	5d                   	pop    %ebp
  8015f1:	c3                   	ret    

008015f2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015f2:	55                   	push   %ebp
  8015f3:	89 e5                	mov    %esp,%ebp
  8015f5:	53                   	push   %ebx
  8015f6:	83 ec 14             	sub    $0x14,%esp
  8015f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ff:	50                   	push   %eax
  801600:	53                   	push   %ebx
  801601:	e8 ac fc ff ff       	call   8012b2 <fd_lookup>
  801606:	83 c4 08             	add    $0x8,%esp
  801609:	89 c2                	mov    %eax,%edx
  80160b:	85 c0                	test   %eax,%eax
  80160d:	78 68                	js     801677 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80160f:	83 ec 08             	sub    $0x8,%esp
  801612:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801615:	50                   	push   %eax
  801616:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801619:	ff 30                	pushl  (%eax)
  80161b:	e8 e8 fc ff ff       	call   801308 <dev_lookup>
  801620:	83 c4 10             	add    $0x10,%esp
  801623:	85 c0                	test   %eax,%eax
  801625:	78 47                	js     80166e <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801627:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80162a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80162e:	75 21                	jne    801651 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801630:	a1 04 40 80 00       	mov    0x804004,%eax
  801635:	8b 40 48             	mov    0x48(%eax),%eax
  801638:	83 ec 04             	sub    $0x4,%esp
  80163b:	53                   	push   %ebx
  80163c:	50                   	push   %eax
  80163d:	68 34 29 80 00       	push   $0x802934
  801642:	e8 a4 ed ff ff       	call   8003eb <cprintf>
		return -E_INVAL;
  801647:	83 c4 10             	add    $0x10,%esp
  80164a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80164f:	eb 26                	jmp    801677 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801651:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801654:	8b 52 0c             	mov    0xc(%edx),%edx
  801657:	85 d2                	test   %edx,%edx
  801659:	74 17                	je     801672 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80165b:	83 ec 04             	sub    $0x4,%esp
  80165e:	ff 75 10             	pushl  0x10(%ebp)
  801661:	ff 75 0c             	pushl  0xc(%ebp)
  801664:	50                   	push   %eax
  801665:	ff d2                	call   *%edx
  801667:	89 c2                	mov    %eax,%edx
  801669:	83 c4 10             	add    $0x10,%esp
  80166c:	eb 09                	jmp    801677 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80166e:	89 c2                	mov    %eax,%edx
  801670:	eb 05                	jmp    801677 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801672:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801677:	89 d0                	mov    %edx,%eax
  801679:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80167c:	c9                   	leave  
  80167d:	c3                   	ret    

0080167e <seek>:

int
seek(int fdnum, off_t offset)
{
  80167e:	55                   	push   %ebp
  80167f:	89 e5                	mov    %esp,%ebp
  801681:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801684:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801687:	50                   	push   %eax
  801688:	ff 75 08             	pushl  0x8(%ebp)
  80168b:	e8 22 fc ff ff       	call   8012b2 <fd_lookup>
  801690:	83 c4 08             	add    $0x8,%esp
  801693:	85 c0                	test   %eax,%eax
  801695:	78 0e                	js     8016a5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801697:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80169a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80169d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016a5:	c9                   	leave  
  8016a6:	c3                   	ret    

008016a7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016a7:	55                   	push   %ebp
  8016a8:	89 e5                	mov    %esp,%ebp
  8016aa:	53                   	push   %ebx
  8016ab:	83 ec 14             	sub    $0x14,%esp
  8016ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016b1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016b4:	50                   	push   %eax
  8016b5:	53                   	push   %ebx
  8016b6:	e8 f7 fb ff ff       	call   8012b2 <fd_lookup>
  8016bb:	83 c4 08             	add    $0x8,%esp
  8016be:	89 c2                	mov    %eax,%edx
  8016c0:	85 c0                	test   %eax,%eax
  8016c2:	78 65                	js     801729 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c4:	83 ec 08             	sub    $0x8,%esp
  8016c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ca:	50                   	push   %eax
  8016cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ce:	ff 30                	pushl  (%eax)
  8016d0:	e8 33 fc ff ff       	call   801308 <dev_lookup>
  8016d5:	83 c4 10             	add    $0x10,%esp
  8016d8:	85 c0                	test   %eax,%eax
  8016da:	78 44                	js     801720 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016df:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016e3:	75 21                	jne    801706 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016e5:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016ea:	8b 40 48             	mov    0x48(%eax),%eax
  8016ed:	83 ec 04             	sub    $0x4,%esp
  8016f0:	53                   	push   %ebx
  8016f1:	50                   	push   %eax
  8016f2:	68 f4 28 80 00       	push   $0x8028f4
  8016f7:	e8 ef ec ff ff       	call   8003eb <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016fc:	83 c4 10             	add    $0x10,%esp
  8016ff:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801704:	eb 23                	jmp    801729 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801706:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801709:	8b 52 18             	mov    0x18(%edx),%edx
  80170c:	85 d2                	test   %edx,%edx
  80170e:	74 14                	je     801724 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801710:	83 ec 08             	sub    $0x8,%esp
  801713:	ff 75 0c             	pushl  0xc(%ebp)
  801716:	50                   	push   %eax
  801717:	ff d2                	call   *%edx
  801719:	89 c2                	mov    %eax,%edx
  80171b:	83 c4 10             	add    $0x10,%esp
  80171e:	eb 09                	jmp    801729 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801720:	89 c2                	mov    %eax,%edx
  801722:	eb 05                	jmp    801729 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801724:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801729:	89 d0                	mov    %edx,%eax
  80172b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80172e:	c9                   	leave  
  80172f:	c3                   	ret    

00801730 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801730:	55                   	push   %ebp
  801731:	89 e5                	mov    %esp,%ebp
  801733:	53                   	push   %ebx
  801734:	83 ec 14             	sub    $0x14,%esp
  801737:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80173a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80173d:	50                   	push   %eax
  80173e:	ff 75 08             	pushl  0x8(%ebp)
  801741:	e8 6c fb ff ff       	call   8012b2 <fd_lookup>
  801746:	83 c4 08             	add    $0x8,%esp
  801749:	89 c2                	mov    %eax,%edx
  80174b:	85 c0                	test   %eax,%eax
  80174d:	78 58                	js     8017a7 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80174f:	83 ec 08             	sub    $0x8,%esp
  801752:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801755:	50                   	push   %eax
  801756:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801759:	ff 30                	pushl  (%eax)
  80175b:	e8 a8 fb ff ff       	call   801308 <dev_lookup>
  801760:	83 c4 10             	add    $0x10,%esp
  801763:	85 c0                	test   %eax,%eax
  801765:	78 37                	js     80179e <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801767:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80176a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80176e:	74 32                	je     8017a2 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801770:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801773:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80177a:	00 00 00 
	stat->st_isdir = 0;
  80177d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801784:	00 00 00 
	stat->st_dev = dev;
  801787:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80178d:	83 ec 08             	sub    $0x8,%esp
  801790:	53                   	push   %ebx
  801791:	ff 75 f0             	pushl  -0x10(%ebp)
  801794:	ff 50 14             	call   *0x14(%eax)
  801797:	89 c2                	mov    %eax,%edx
  801799:	83 c4 10             	add    $0x10,%esp
  80179c:	eb 09                	jmp    8017a7 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80179e:	89 c2                	mov    %eax,%edx
  8017a0:	eb 05                	jmp    8017a7 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017a2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017a7:	89 d0                	mov    %edx,%eax
  8017a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ac:	c9                   	leave  
  8017ad:	c3                   	ret    

008017ae <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017ae:	55                   	push   %ebp
  8017af:	89 e5                	mov    %esp,%ebp
  8017b1:	56                   	push   %esi
  8017b2:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017b3:	83 ec 08             	sub    $0x8,%esp
  8017b6:	6a 00                	push   $0x0
  8017b8:	ff 75 08             	pushl  0x8(%ebp)
  8017bb:	e8 e3 01 00 00       	call   8019a3 <open>
  8017c0:	89 c3                	mov    %eax,%ebx
  8017c2:	83 c4 10             	add    $0x10,%esp
  8017c5:	85 c0                	test   %eax,%eax
  8017c7:	78 1b                	js     8017e4 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017c9:	83 ec 08             	sub    $0x8,%esp
  8017cc:	ff 75 0c             	pushl  0xc(%ebp)
  8017cf:	50                   	push   %eax
  8017d0:	e8 5b ff ff ff       	call   801730 <fstat>
  8017d5:	89 c6                	mov    %eax,%esi
	close(fd);
  8017d7:	89 1c 24             	mov    %ebx,(%esp)
  8017da:	e8 fd fb ff ff       	call   8013dc <close>
	return r;
  8017df:	83 c4 10             	add    $0x10,%esp
  8017e2:	89 f0                	mov    %esi,%eax
}
  8017e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017e7:	5b                   	pop    %ebx
  8017e8:	5e                   	pop    %esi
  8017e9:	5d                   	pop    %ebp
  8017ea:	c3                   	ret    

008017eb <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017eb:	55                   	push   %ebp
  8017ec:	89 e5                	mov    %esp,%ebp
  8017ee:	56                   	push   %esi
  8017ef:	53                   	push   %ebx
  8017f0:	89 c6                	mov    %eax,%esi
  8017f2:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017f4:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017fb:	75 12                	jne    80180f <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017fd:	83 ec 0c             	sub    $0xc,%esp
  801800:	6a 01                	push   $0x1
  801802:	e8 9f 08 00 00       	call   8020a6 <ipc_find_env>
  801807:	a3 00 40 80 00       	mov    %eax,0x804000
  80180c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80180f:	6a 07                	push   $0x7
  801811:	68 00 50 80 00       	push   $0x805000
  801816:	56                   	push   %esi
  801817:	ff 35 00 40 80 00    	pushl  0x804000
  80181d:	e8 30 08 00 00       	call   802052 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801822:	83 c4 0c             	add    $0xc,%esp
  801825:	6a 00                	push   $0x0
  801827:	53                   	push   %ebx
  801828:	6a 00                	push   $0x0
  80182a:	e8 b1 07 00 00       	call   801fe0 <ipc_recv>
}
  80182f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801832:	5b                   	pop    %ebx
  801833:	5e                   	pop    %esi
  801834:	5d                   	pop    %ebp
  801835:	c3                   	ret    

00801836 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801836:	55                   	push   %ebp
  801837:	89 e5                	mov    %esp,%ebp
  801839:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80183c:	8b 45 08             	mov    0x8(%ebp),%eax
  80183f:	8b 40 0c             	mov    0xc(%eax),%eax
  801842:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801847:	8b 45 0c             	mov    0xc(%ebp),%eax
  80184a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80184f:	ba 00 00 00 00       	mov    $0x0,%edx
  801854:	b8 02 00 00 00       	mov    $0x2,%eax
  801859:	e8 8d ff ff ff       	call   8017eb <fsipc>
}
  80185e:	c9                   	leave  
  80185f:	c3                   	ret    

00801860 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801860:	55                   	push   %ebp
  801861:	89 e5                	mov    %esp,%ebp
  801863:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801866:	8b 45 08             	mov    0x8(%ebp),%eax
  801869:	8b 40 0c             	mov    0xc(%eax),%eax
  80186c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801871:	ba 00 00 00 00       	mov    $0x0,%edx
  801876:	b8 06 00 00 00       	mov    $0x6,%eax
  80187b:	e8 6b ff ff ff       	call   8017eb <fsipc>
}
  801880:	c9                   	leave  
  801881:	c3                   	ret    

00801882 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801882:	55                   	push   %ebp
  801883:	89 e5                	mov    %esp,%ebp
  801885:	53                   	push   %ebx
  801886:	83 ec 04             	sub    $0x4,%esp
  801889:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80188c:	8b 45 08             	mov    0x8(%ebp),%eax
  80188f:	8b 40 0c             	mov    0xc(%eax),%eax
  801892:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801897:	ba 00 00 00 00       	mov    $0x0,%edx
  80189c:	b8 05 00 00 00       	mov    $0x5,%eax
  8018a1:	e8 45 ff ff ff       	call   8017eb <fsipc>
  8018a6:	85 c0                	test   %eax,%eax
  8018a8:	78 2c                	js     8018d6 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018aa:	83 ec 08             	sub    $0x8,%esp
  8018ad:	68 00 50 80 00       	push   $0x805000
  8018b2:	53                   	push   %ebx
  8018b3:	e8 37 f1 ff ff       	call   8009ef <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018b8:	a1 80 50 80 00       	mov    0x805080,%eax
  8018bd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018c3:	a1 84 50 80 00       	mov    0x805084,%eax
  8018c8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018ce:	83 c4 10             	add    $0x10,%esp
  8018d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d9:	c9                   	leave  
  8018da:	c3                   	ret    

008018db <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018db:	55                   	push   %ebp
  8018dc:	89 e5                	mov    %esp,%ebp
  8018de:	83 ec 0c             	sub    $0xc,%esp
  8018e1:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	
	int r;

	n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8018e4:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8018e9:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8018ee:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8018f4:	8b 52 0c             	mov    0xc(%edx),%edx
  8018f7:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8018fd:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801902:	50                   	push   %eax
  801903:	ff 75 0c             	pushl  0xc(%ebp)
  801906:	68 08 50 80 00       	push   $0x805008
  80190b:	e8 71 f2 ff ff       	call   800b81 <memmove>
	
	return fsipc(FSREQ_WRITE, NULL);	
  801910:	ba 00 00 00 00       	mov    $0x0,%edx
  801915:	b8 04 00 00 00       	mov    $0x4,%eax
  80191a:	e8 cc fe ff ff       	call   8017eb <fsipc>
}
  80191f:	c9                   	leave  
  801920:	c3                   	ret    

00801921 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801921:	55                   	push   %ebp
  801922:	89 e5                	mov    %esp,%ebp
  801924:	56                   	push   %esi
  801925:	53                   	push   %ebx
  801926:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801929:	8b 45 08             	mov    0x8(%ebp),%eax
  80192c:	8b 40 0c             	mov    0xc(%eax),%eax
  80192f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801934:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80193a:	ba 00 00 00 00       	mov    $0x0,%edx
  80193f:	b8 03 00 00 00       	mov    $0x3,%eax
  801944:	e8 a2 fe ff ff       	call   8017eb <fsipc>
  801949:	89 c3                	mov    %eax,%ebx
  80194b:	85 c0                	test   %eax,%eax
  80194d:	78 4b                	js     80199a <devfile_read+0x79>
		return r;
	assert(r <= n);
  80194f:	39 c6                	cmp    %eax,%esi
  801951:	73 16                	jae    801969 <devfile_read+0x48>
  801953:	68 64 29 80 00       	push   $0x802964
  801958:	68 6b 29 80 00       	push   $0x80296b
  80195d:	6a 7c                	push   $0x7c
  80195f:	68 80 29 80 00       	push   $0x802980
  801964:	e8 a9 e9 ff ff       	call   800312 <_panic>
	assert(r <= PGSIZE);
  801969:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80196e:	7e 16                	jle    801986 <devfile_read+0x65>
  801970:	68 8b 29 80 00       	push   $0x80298b
  801975:	68 6b 29 80 00       	push   $0x80296b
  80197a:	6a 7d                	push   $0x7d
  80197c:	68 80 29 80 00       	push   $0x802980
  801981:	e8 8c e9 ff ff       	call   800312 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801986:	83 ec 04             	sub    $0x4,%esp
  801989:	50                   	push   %eax
  80198a:	68 00 50 80 00       	push   $0x805000
  80198f:	ff 75 0c             	pushl  0xc(%ebp)
  801992:	e8 ea f1 ff ff       	call   800b81 <memmove>
	return r;
  801997:	83 c4 10             	add    $0x10,%esp
}
  80199a:	89 d8                	mov    %ebx,%eax
  80199c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80199f:	5b                   	pop    %ebx
  8019a0:	5e                   	pop    %esi
  8019a1:	5d                   	pop    %ebp
  8019a2:	c3                   	ret    

008019a3 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019a3:	55                   	push   %ebp
  8019a4:	89 e5                	mov    %esp,%ebp
  8019a6:	53                   	push   %ebx
  8019a7:	83 ec 20             	sub    $0x20,%esp
  8019aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019ad:	53                   	push   %ebx
  8019ae:	e8 03 f0 ff ff       	call   8009b6 <strlen>
  8019b3:	83 c4 10             	add    $0x10,%esp
  8019b6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019bb:	7f 67                	jg     801a24 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019bd:	83 ec 0c             	sub    $0xc,%esp
  8019c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019c3:	50                   	push   %eax
  8019c4:	e8 9a f8 ff ff       	call   801263 <fd_alloc>
  8019c9:	83 c4 10             	add    $0x10,%esp
		return r;
  8019cc:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019ce:	85 c0                	test   %eax,%eax
  8019d0:	78 57                	js     801a29 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019d2:	83 ec 08             	sub    $0x8,%esp
  8019d5:	53                   	push   %ebx
  8019d6:	68 00 50 80 00       	push   $0x805000
  8019db:	e8 0f f0 ff ff       	call   8009ef <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019e3:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019eb:	b8 01 00 00 00       	mov    $0x1,%eax
  8019f0:	e8 f6 fd ff ff       	call   8017eb <fsipc>
  8019f5:	89 c3                	mov    %eax,%ebx
  8019f7:	83 c4 10             	add    $0x10,%esp
  8019fa:	85 c0                	test   %eax,%eax
  8019fc:	79 14                	jns    801a12 <open+0x6f>
		fd_close(fd, 0);
  8019fe:	83 ec 08             	sub    $0x8,%esp
  801a01:	6a 00                	push   $0x0
  801a03:	ff 75 f4             	pushl  -0xc(%ebp)
  801a06:	e8 50 f9 ff ff       	call   80135b <fd_close>
		return r;
  801a0b:	83 c4 10             	add    $0x10,%esp
  801a0e:	89 da                	mov    %ebx,%edx
  801a10:	eb 17                	jmp    801a29 <open+0x86>
	}

	return fd2num(fd);
  801a12:	83 ec 0c             	sub    $0xc,%esp
  801a15:	ff 75 f4             	pushl  -0xc(%ebp)
  801a18:	e8 1f f8 ff ff       	call   80123c <fd2num>
  801a1d:	89 c2                	mov    %eax,%edx
  801a1f:	83 c4 10             	add    $0x10,%esp
  801a22:	eb 05                	jmp    801a29 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a24:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a29:	89 d0                	mov    %edx,%eax
  801a2b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a2e:	c9                   	leave  
  801a2f:	c3                   	ret    

00801a30 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a30:	55                   	push   %ebp
  801a31:	89 e5                	mov    %esp,%ebp
  801a33:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a36:	ba 00 00 00 00       	mov    $0x0,%edx
  801a3b:	b8 08 00 00 00       	mov    $0x8,%eax
  801a40:	e8 a6 fd ff ff       	call   8017eb <fsipc>
}
  801a45:	c9                   	leave  
  801a46:	c3                   	ret    

00801a47 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a47:	55                   	push   %ebp
  801a48:	89 e5                	mov    %esp,%ebp
  801a4a:	56                   	push   %esi
  801a4b:	53                   	push   %ebx
  801a4c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a4f:	83 ec 0c             	sub    $0xc,%esp
  801a52:	ff 75 08             	pushl  0x8(%ebp)
  801a55:	e8 f2 f7 ff ff       	call   80124c <fd2data>
  801a5a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a5c:	83 c4 08             	add    $0x8,%esp
  801a5f:	68 97 29 80 00       	push   $0x802997
  801a64:	53                   	push   %ebx
  801a65:	e8 85 ef ff ff       	call   8009ef <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a6a:	8b 46 04             	mov    0x4(%esi),%eax
  801a6d:	2b 06                	sub    (%esi),%eax
  801a6f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a75:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a7c:	00 00 00 
	stat->st_dev = &devpipe;
  801a7f:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801a86:	30 80 00 
	return 0;
}
  801a89:	b8 00 00 00 00       	mov    $0x0,%eax
  801a8e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a91:	5b                   	pop    %ebx
  801a92:	5e                   	pop    %esi
  801a93:	5d                   	pop    %ebp
  801a94:	c3                   	ret    

00801a95 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a95:	55                   	push   %ebp
  801a96:	89 e5                	mov    %esp,%ebp
  801a98:	53                   	push   %ebx
  801a99:	83 ec 0c             	sub    $0xc,%esp
  801a9c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a9f:	53                   	push   %ebx
  801aa0:	6a 00                	push   $0x0
  801aa2:	e8 d0 f3 ff ff       	call   800e77 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801aa7:	89 1c 24             	mov    %ebx,(%esp)
  801aaa:	e8 9d f7 ff ff       	call   80124c <fd2data>
  801aaf:	83 c4 08             	add    $0x8,%esp
  801ab2:	50                   	push   %eax
  801ab3:	6a 00                	push   $0x0
  801ab5:	e8 bd f3 ff ff       	call   800e77 <sys_page_unmap>
}
  801aba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801abd:	c9                   	leave  
  801abe:	c3                   	ret    

00801abf <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801abf:	55                   	push   %ebp
  801ac0:	89 e5                	mov    %esp,%ebp
  801ac2:	57                   	push   %edi
  801ac3:	56                   	push   %esi
  801ac4:	53                   	push   %ebx
  801ac5:	83 ec 1c             	sub    $0x1c,%esp
  801ac8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801acb:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801acd:	a1 04 40 80 00       	mov    0x804004,%eax
  801ad2:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801ad5:	83 ec 0c             	sub    $0xc,%esp
  801ad8:	ff 75 e0             	pushl  -0x20(%ebp)
  801adb:	e8 ff 05 00 00       	call   8020df <pageref>
  801ae0:	89 c3                	mov    %eax,%ebx
  801ae2:	89 3c 24             	mov    %edi,(%esp)
  801ae5:	e8 f5 05 00 00       	call   8020df <pageref>
  801aea:	83 c4 10             	add    $0x10,%esp
  801aed:	39 c3                	cmp    %eax,%ebx
  801aef:	0f 94 c1             	sete   %cl
  801af2:	0f b6 c9             	movzbl %cl,%ecx
  801af5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801af8:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801afe:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b01:	39 ce                	cmp    %ecx,%esi
  801b03:	74 1b                	je     801b20 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b05:	39 c3                	cmp    %eax,%ebx
  801b07:	75 c4                	jne    801acd <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b09:	8b 42 58             	mov    0x58(%edx),%eax
  801b0c:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b0f:	50                   	push   %eax
  801b10:	56                   	push   %esi
  801b11:	68 9e 29 80 00       	push   $0x80299e
  801b16:	e8 d0 e8 ff ff       	call   8003eb <cprintf>
  801b1b:	83 c4 10             	add    $0x10,%esp
  801b1e:	eb ad                	jmp    801acd <_pipeisclosed+0xe>
	}
}
  801b20:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b26:	5b                   	pop    %ebx
  801b27:	5e                   	pop    %esi
  801b28:	5f                   	pop    %edi
  801b29:	5d                   	pop    %ebp
  801b2a:	c3                   	ret    

00801b2b <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b2b:	55                   	push   %ebp
  801b2c:	89 e5                	mov    %esp,%ebp
  801b2e:	57                   	push   %edi
  801b2f:	56                   	push   %esi
  801b30:	53                   	push   %ebx
  801b31:	83 ec 28             	sub    $0x28,%esp
  801b34:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b37:	56                   	push   %esi
  801b38:	e8 0f f7 ff ff       	call   80124c <fd2data>
  801b3d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b3f:	83 c4 10             	add    $0x10,%esp
  801b42:	bf 00 00 00 00       	mov    $0x0,%edi
  801b47:	eb 4b                	jmp    801b94 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b49:	89 da                	mov    %ebx,%edx
  801b4b:	89 f0                	mov    %esi,%eax
  801b4d:	e8 6d ff ff ff       	call   801abf <_pipeisclosed>
  801b52:	85 c0                	test   %eax,%eax
  801b54:	75 48                	jne    801b9e <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b56:	e8 78 f2 ff ff       	call   800dd3 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b5b:	8b 43 04             	mov    0x4(%ebx),%eax
  801b5e:	8b 0b                	mov    (%ebx),%ecx
  801b60:	8d 51 20             	lea    0x20(%ecx),%edx
  801b63:	39 d0                	cmp    %edx,%eax
  801b65:	73 e2                	jae    801b49 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b6a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b6e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b71:	89 c2                	mov    %eax,%edx
  801b73:	c1 fa 1f             	sar    $0x1f,%edx
  801b76:	89 d1                	mov    %edx,%ecx
  801b78:	c1 e9 1b             	shr    $0x1b,%ecx
  801b7b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b7e:	83 e2 1f             	and    $0x1f,%edx
  801b81:	29 ca                	sub    %ecx,%edx
  801b83:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b87:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b8b:	83 c0 01             	add    $0x1,%eax
  801b8e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b91:	83 c7 01             	add    $0x1,%edi
  801b94:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b97:	75 c2                	jne    801b5b <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b99:	8b 45 10             	mov    0x10(%ebp),%eax
  801b9c:	eb 05                	jmp    801ba3 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b9e:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ba3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ba6:	5b                   	pop    %ebx
  801ba7:	5e                   	pop    %esi
  801ba8:	5f                   	pop    %edi
  801ba9:	5d                   	pop    %ebp
  801baa:	c3                   	ret    

00801bab <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bab:	55                   	push   %ebp
  801bac:	89 e5                	mov    %esp,%ebp
  801bae:	57                   	push   %edi
  801baf:	56                   	push   %esi
  801bb0:	53                   	push   %ebx
  801bb1:	83 ec 18             	sub    $0x18,%esp
  801bb4:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801bb7:	57                   	push   %edi
  801bb8:	e8 8f f6 ff ff       	call   80124c <fd2data>
  801bbd:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bbf:	83 c4 10             	add    $0x10,%esp
  801bc2:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bc7:	eb 3d                	jmp    801c06 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801bc9:	85 db                	test   %ebx,%ebx
  801bcb:	74 04                	je     801bd1 <devpipe_read+0x26>
				return i;
  801bcd:	89 d8                	mov    %ebx,%eax
  801bcf:	eb 44                	jmp    801c15 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bd1:	89 f2                	mov    %esi,%edx
  801bd3:	89 f8                	mov    %edi,%eax
  801bd5:	e8 e5 fe ff ff       	call   801abf <_pipeisclosed>
  801bda:	85 c0                	test   %eax,%eax
  801bdc:	75 32                	jne    801c10 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bde:	e8 f0 f1 ff ff       	call   800dd3 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801be3:	8b 06                	mov    (%esi),%eax
  801be5:	3b 46 04             	cmp    0x4(%esi),%eax
  801be8:	74 df                	je     801bc9 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bea:	99                   	cltd   
  801beb:	c1 ea 1b             	shr    $0x1b,%edx
  801bee:	01 d0                	add    %edx,%eax
  801bf0:	83 e0 1f             	and    $0x1f,%eax
  801bf3:	29 d0                	sub    %edx,%eax
  801bf5:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801bfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bfd:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c00:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c03:	83 c3 01             	add    $0x1,%ebx
  801c06:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c09:	75 d8                	jne    801be3 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c0b:	8b 45 10             	mov    0x10(%ebp),%eax
  801c0e:	eb 05                	jmp    801c15 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c10:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c18:	5b                   	pop    %ebx
  801c19:	5e                   	pop    %esi
  801c1a:	5f                   	pop    %edi
  801c1b:	5d                   	pop    %ebp
  801c1c:	c3                   	ret    

00801c1d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c1d:	55                   	push   %ebp
  801c1e:	89 e5                	mov    %esp,%ebp
  801c20:	56                   	push   %esi
  801c21:	53                   	push   %ebx
  801c22:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c25:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c28:	50                   	push   %eax
  801c29:	e8 35 f6 ff ff       	call   801263 <fd_alloc>
  801c2e:	83 c4 10             	add    $0x10,%esp
  801c31:	89 c2                	mov    %eax,%edx
  801c33:	85 c0                	test   %eax,%eax
  801c35:	0f 88 2c 01 00 00    	js     801d67 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c3b:	83 ec 04             	sub    $0x4,%esp
  801c3e:	68 07 04 00 00       	push   $0x407
  801c43:	ff 75 f4             	pushl  -0xc(%ebp)
  801c46:	6a 00                	push   $0x0
  801c48:	e8 a5 f1 ff ff       	call   800df2 <sys_page_alloc>
  801c4d:	83 c4 10             	add    $0x10,%esp
  801c50:	89 c2                	mov    %eax,%edx
  801c52:	85 c0                	test   %eax,%eax
  801c54:	0f 88 0d 01 00 00    	js     801d67 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c5a:	83 ec 0c             	sub    $0xc,%esp
  801c5d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c60:	50                   	push   %eax
  801c61:	e8 fd f5 ff ff       	call   801263 <fd_alloc>
  801c66:	89 c3                	mov    %eax,%ebx
  801c68:	83 c4 10             	add    $0x10,%esp
  801c6b:	85 c0                	test   %eax,%eax
  801c6d:	0f 88 e2 00 00 00    	js     801d55 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c73:	83 ec 04             	sub    $0x4,%esp
  801c76:	68 07 04 00 00       	push   $0x407
  801c7b:	ff 75 f0             	pushl  -0x10(%ebp)
  801c7e:	6a 00                	push   $0x0
  801c80:	e8 6d f1 ff ff       	call   800df2 <sys_page_alloc>
  801c85:	89 c3                	mov    %eax,%ebx
  801c87:	83 c4 10             	add    $0x10,%esp
  801c8a:	85 c0                	test   %eax,%eax
  801c8c:	0f 88 c3 00 00 00    	js     801d55 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c92:	83 ec 0c             	sub    $0xc,%esp
  801c95:	ff 75 f4             	pushl  -0xc(%ebp)
  801c98:	e8 af f5 ff ff       	call   80124c <fd2data>
  801c9d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c9f:	83 c4 0c             	add    $0xc,%esp
  801ca2:	68 07 04 00 00       	push   $0x407
  801ca7:	50                   	push   %eax
  801ca8:	6a 00                	push   $0x0
  801caa:	e8 43 f1 ff ff       	call   800df2 <sys_page_alloc>
  801caf:	89 c3                	mov    %eax,%ebx
  801cb1:	83 c4 10             	add    $0x10,%esp
  801cb4:	85 c0                	test   %eax,%eax
  801cb6:	0f 88 89 00 00 00    	js     801d45 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cbc:	83 ec 0c             	sub    $0xc,%esp
  801cbf:	ff 75 f0             	pushl  -0x10(%ebp)
  801cc2:	e8 85 f5 ff ff       	call   80124c <fd2data>
  801cc7:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cce:	50                   	push   %eax
  801ccf:	6a 00                	push   $0x0
  801cd1:	56                   	push   %esi
  801cd2:	6a 00                	push   $0x0
  801cd4:	e8 5c f1 ff ff       	call   800e35 <sys_page_map>
  801cd9:	89 c3                	mov    %eax,%ebx
  801cdb:	83 c4 20             	add    $0x20,%esp
  801cde:	85 c0                	test   %eax,%eax
  801ce0:	78 55                	js     801d37 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ce2:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801ce8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ceb:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ced:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801cf7:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801cfd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d00:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d02:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d05:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d0c:	83 ec 0c             	sub    $0xc,%esp
  801d0f:	ff 75 f4             	pushl  -0xc(%ebp)
  801d12:	e8 25 f5 ff ff       	call   80123c <fd2num>
  801d17:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d1a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d1c:	83 c4 04             	add    $0x4,%esp
  801d1f:	ff 75 f0             	pushl  -0x10(%ebp)
  801d22:	e8 15 f5 ff ff       	call   80123c <fd2num>
  801d27:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d2a:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d2d:	83 c4 10             	add    $0x10,%esp
  801d30:	ba 00 00 00 00       	mov    $0x0,%edx
  801d35:	eb 30                	jmp    801d67 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d37:	83 ec 08             	sub    $0x8,%esp
  801d3a:	56                   	push   %esi
  801d3b:	6a 00                	push   $0x0
  801d3d:	e8 35 f1 ff ff       	call   800e77 <sys_page_unmap>
  801d42:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d45:	83 ec 08             	sub    $0x8,%esp
  801d48:	ff 75 f0             	pushl  -0x10(%ebp)
  801d4b:	6a 00                	push   $0x0
  801d4d:	e8 25 f1 ff ff       	call   800e77 <sys_page_unmap>
  801d52:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d55:	83 ec 08             	sub    $0x8,%esp
  801d58:	ff 75 f4             	pushl  -0xc(%ebp)
  801d5b:	6a 00                	push   $0x0
  801d5d:	e8 15 f1 ff ff       	call   800e77 <sys_page_unmap>
  801d62:	83 c4 10             	add    $0x10,%esp
  801d65:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d67:	89 d0                	mov    %edx,%eax
  801d69:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d6c:	5b                   	pop    %ebx
  801d6d:	5e                   	pop    %esi
  801d6e:	5d                   	pop    %ebp
  801d6f:	c3                   	ret    

00801d70 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d70:	55                   	push   %ebp
  801d71:	89 e5                	mov    %esp,%ebp
  801d73:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d76:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d79:	50                   	push   %eax
  801d7a:	ff 75 08             	pushl  0x8(%ebp)
  801d7d:	e8 30 f5 ff ff       	call   8012b2 <fd_lookup>
  801d82:	83 c4 10             	add    $0x10,%esp
  801d85:	85 c0                	test   %eax,%eax
  801d87:	78 18                	js     801da1 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d89:	83 ec 0c             	sub    $0xc,%esp
  801d8c:	ff 75 f4             	pushl  -0xc(%ebp)
  801d8f:	e8 b8 f4 ff ff       	call   80124c <fd2data>
	return _pipeisclosed(fd, p);
  801d94:	89 c2                	mov    %eax,%edx
  801d96:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d99:	e8 21 fd ff ff       	call   801abf <_pipeisclosed>
  801d9e:	83 c4 10             	add    $0x10,%esp
}
  801da1:	c9                   	leave  
  801da2:	c3                   	ret    

00801da3 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801da3:	55                   	push   %ebp
  801da4:	89 e5                	mov    %esp,%ebp
  801da6:	56                   	push   %esi
  801da7:	53                   	push   %ebx
  801da8:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801dab:	85 f6                	test   %esi,%esi
  801dad:	75 16                	jne    801dc5 <wait+0x22>
  801daf:	68 b6 29 80 00       	push   $0x8029b6
  801db4:	68 6b 29 80 00       	push   $0x80296b
  801db9:	6a 09                	push   $0x9
  801dbb:	68 c1 29 80 00       	push   $0x8029c1
  801dc0:	e8 4d e5 ff ff       	call   800312 <_panic>
	e = &envs[ENVX(envid)];
  801dc5:	89 f3                	mov    %esi,%ebx
  801dc7:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801dcd:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  801dd0:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  801dd6:	eb 05                	jmp    801ddd <wait+0x3a>
		sys_yield();
  801dd8:	e8 f6 ef ff ff       	call   800dd3 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801ddd:	8b 43 48             	mov    0x48(%ebx),%eax
  801de0:	39 c6                	cmp    %eax,%esi
  801de2:	75 07                	jne    801deb <wait+0x48>
  801de4:	8b 43 54             	mov    0x54(%ebx),%eax
  801de7:	85 c0                	test   %eax,%eax
  801de9:	75 ed                	jne    801dd8 <wait+0x35>
		sys_yield();
}
  801deb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dee:	5b                   	pop    %ebx
  801def:	5e                   	pop    %esi
  801df0:	5d                   	pop    %ebp
  801df1:	c3                   	ret    

00801df2 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801df2:	55                   	push   %ebp
  801df3:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801df5:	b8 00 00 00 00       	mov    $0x0,%eax
  801dfa:	5d                   	pop    %ebp
  801dfb:	c3                   	ret    

00801dfc <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801dfc:	55                   	push   %ebp
  801dfd:	89 e5                	mov    %esp,%ebp
  801dff:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e02:	68 cc 29 80 00       	push   $0x8029cc
  801e07:	ff 75 0c             	pushl  0xc(%ebp)
  801e0a:	e8 e0 eb ff ff       	call   8009ef <strcpy>
	return 0;
}
  801e0f:	b8 00 00 00 00       	mov    $0x0,%eax
  801e14:	c9                   	leave  
  801e15:	c3                   	ret    

00801e16 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e16:	55                   	push   %ebp
  801e17:	89 e5                	mov    %esp,%ebp
  801e19:	57                   	push   %edi
  801e1a:	56                   	push   %esi
  801e1b:	53                   	push   %ebx
  801e1c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e22:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e27:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e2d:	eb 2d                	jmp    801e5c <devcons_write+0x46>
		m = n - tot;
  801e2f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e32:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e34:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e37:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e3c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e3f:	83 ec 04             	sub    $0x4,%esp
  801e42:	53                   	push   %ebx
  801e43:	03 45 0c             	add    0xc(%ebp),%eax
  801e46:	50                   	push   %eax
  801e47:	57                   	push   %edi
  801e48:	e8 34 ed ff ff       	call   800b81 <memmove>
		sys_cputs(buf, m);
  801e4d:	83 c4 08             	add    $0x8,%esp
  801e50:	53                   	push   %ebx
  801e51:	57                   	push   %edi
  801e52:	e8 df ee ff ff       	call   800d36 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e57:	01 de                	add    %ebx,%esi
  801e59:	83 c4 10             	add    $0x10,%esp
  801e5c:	89 f0                	mov    %esi,%eax
  801e5e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e61:	72 cc                	jb     801e2f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e66:	5b                   	pop    %ebx
  801e67:	5e                   	pop    %esi
  801e68:	5f                   	pop    %edi
  801e69:	5d                   	pop    %ebp
  801e6a:	c3                   	ret    

00801e6b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e6b:	55                   	push   %ebp
  801e6c:	89 e5                	mov    %esp,%ebp
  801e6e:	83 ec 08             	sub    $0x8,%esp
  801e71:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e76:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e7a:	74 2a                	je     801ea6 <devcons_read+0x3b>
  801e7c:	eb 05                	jmp    801e83 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e7e:	e8 50 ef ff ff       	call   800dd3 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e83:	e8 cc ee ff ff       	call   800d54 <sys_cgetc>
  801e88:	85 c0                	test   %eax,%eax
  801e8a:	74 f2                	je     801e7e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e8c:	85 c0                	test   %eax,%eax
  801e8e:	78 16                	js     801ea6 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e90:	83 f8 04             	cmp    $0x4,%eax
  801e93:	74 0c                	je     801ea1 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e95:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e98:	88 02                	mov    %al,(%edx)
	return 1;
  801e9a:	b8 01 00 00 00       	mov    $0x1,%eax
  801e9f:	eb 05                	jmp    801ea6 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ea1:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ea6:	c9                   	leave  
  801ea7:	c3                   	ret    

00801ea8 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ea8:	55                   	push   %ebp
  801ea9:	89 e5                	mov    %esp,%ebp
  801eab:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801eae:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb1:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801eb4:	6a 01                	push   $0x1
  801eb6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801eb9:	50                   	push   %eax
  801eba:	e8 77 ee ff ff       	call   800d36 <sys_cputs>
}
  801ebf:	83 c4 10             	add    $0x10,%esp
  801ec2:	c9                   	leave  
  801ec3:	c3                   	ret    

00801ec4 <getchar>:

int
getchar(void)
{
  801ec4:	55                   	push   %ebp
  801ec5:	89 e5                	mov    %esp,%ebp
  801ec7:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801eca:	6a 01                	push   $0x1
  801ecc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ecf:	50                   	push   %eax
  801ed0:	6a 00                	push   $0x0
  801ed2:	e8 41 f6 ff ff       	call   801518 <read>
	if (r < 0)
  801ed7:	83 c4 10             	add    $0x10,%esp
  801eda:	85 c0                	test   %eax,%eax
  801edc:	78 0f                	js     801eed <getchar+0x29>
		return r;
	if (r < 1)
  801ede:	85 c0                	test   %eax,%eax
  801ee0:	7e 06                	jle    801ee8 <getchar+0x24>
		return -E_EOF;
	return c;
  801ee2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ee6:	eb 05                	jmp    801eed <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ee8:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801eed:	c9                   	leave  
  801eee:	c3                   	ret    

00801eef <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801eef:	55                   	push   %ebp
  801ef0:	89 e5                	mov    %esp,%ebp
  801ef2:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ef5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ef8:	50                   	push   %eax
  801ef9:	ff 75 08             	pushl  0x8(%ebp)
  801efc:	e8 b1 f3 ff ff       	call   8012b2 <fd_lookup>
  801f01:	83 c4 10             	add    $0x10,%esp
  801f04:	85 c0                	test   %eax,%eax
  801f06:	78 11                	js     801f19 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f0b:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801f11:	39 10                	cmp    %edx,(%eax)
  801f13:	0f 94 c0             	sete   %al
  801f16:	0f b6 c0             	movzbl %al,%eax
}
  801f19:	c9                   	leave  
  801f1a:	c3                   	ret    

00801f1b <opencons>:

int
opencons(void)
{
  801f1b:	55                   	push   %ebp
  801f1c:	89 e5                	mov    %esp,%ebp
  801f1e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f21:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f24:	50                   	push   %eax
  801f25:	e8 39 f3 ff ff       	call   801263 <fd_alloc>
  801f2a:	83 c4 10             	add    $0x10,%esp
		return r;
  801f2d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f2f:	85 c0                	test   %eax,%eax
  801f31:	78 3e                	js     801f71 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f33:	83 ec 04             	sub    $0x4,%esp
  801f36:	68 07 04 00 00       	push   $0x407
  801f3b:	ff 75 f4             	pushl  -0xc(%ebp)
  801f3e:	6a 00                	push   $0x0
  801f40:	e8 ad ee ff ff       	call   800df2 <sys_page_alloc>
  801f45:	83 c4 10             	add    $0x10,%esp
		return r;
  801f48:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f4a:	85 c0                	test   %eax,%eax
  801f4c:	78 23                	js     801f71 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f4e:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801f54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f57:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f5c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f63:	83 ec 0c             	sub    $0xc,%esp
  801f66:	50                   	push   %eax
  801f67:	e8 d0 f2 ff ff       	call   80123c <fd2num>
  801f6c:	89 c2                	mov    %eax,%edx
  801f6e:	83 c4 10             	add    $0x10,%esp
}
  801f71:	89 d0                	mov    %edx,%eax
  801f73:	c9                   	leave  
  801f74:	c3                   	ret    

00801f75 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f75:	55                   	push   %ebp
  801f76:	89 e5                	mov    %esp,%ebp
  801f78:	53                   	push   %ebx
  801f79:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f7c:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f83:	75 28                	jne    801fad <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		void *va = (void *) (UXSTACKTOP - PGSIZE);
		envid_t envid = sys_getenvid();
  801f85:	e8 2a ee ff ff       	call   800db4 <sys_getenvid>
  801f8a:	89 c3                	mov    %eax,%ebx

		sys_page_alloc(envid, va, PTE_P | PTE_U | PTE_W);
  801f8c:	83 ec 04             	sub    $0x4,%esp
  801f8f:	6a 07                	push   $0x7
  801f91:	68 00 f0 bf ee       	push   $0xeebff000
  801f96:	50                   	push   %eax
  801f97:	e8 56 ee ff ff       	call   800df2 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801f9c:	83 c4 08             	add    $0x8,%esp
  801f9f:	68 ba 1f 80 00       	push   $0x801fba
  801fa4:	53                   	push   %ebx
  801fa5:	e8 93 ef ff ff       	call   800f3d <sys_env_set_pgfault_upcall>
  801faa:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801fad:	8b 45 08             	mov    0x8(%ebp),%eax
  801fb0:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801fb5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fb8:	c9                   	leave  
  801fb9:	c3                   	ret    

00801fba <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp				// function argument: pointer to UTF
  801fba:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801fbb:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801fc0:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801fc2:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp, %ebx		// 40 = size between utf_fault_va ~ utf_regs
  801fc5:	89 e3                	mov    %esp,%ebx
	movl 40(%esp), %eax // point to utf_eip
  801fc7:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %esp // point to utf_esp
  801fcb:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax 			// push eip of utf
  801fcf:	50                   	push   %eax

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx, %esp 	// back to origin exception stack
  801fd0:	89 dc                	mov    %ebx,%esp
	subl $4, 48(%esp) 	// utf_esp - 4
  801fd2:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	popl %eax  			// pop utf_fault_va (ignore)
  801fd7:	58                   	pop    %eax
	popl %eax  			// pop utf_err (ignore)
  801fd8:	58                   	pop    %eax
	popal 				// pop utf_regs 
  801fd9:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4, %esp 		// ignore utf_eip
  801fda:	83 c4 04             	add    $0x4,%esp
	popfl 				// restore utf_eflags to eflags
  801fdd:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp  			// restore %esp = utf_esp
  801fde:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801fdf:	c3                   	ret    

00801fe0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fe0:	55                   	push   %ebp
  801fe1:	89 e5                	mov    %esp,%ebp
  801fe3:	56                   	push   %esi
  801fe4:	53                   	push   %ebx
  801fe5:	8b 75 08             	mov    0x8(%ebp),%esi
  801fe8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801feb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

    if (pg != NULL)
  801fee:	85 c0                	test   %eax,%eax
  801ff0:	74 0e                	je     802000 <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  801ff2:	83 ec 0c             	sub    $0xc,%esp
  801ff5:	50                   	push   %eax
  801ff6:	e8 a7 ef ff ff       	call   800fa2 <sys_ipc_recv>
  801ffb:	83 c4 10             	add    $0x10,%esp
  801ffe:	eb 0d                	jmp    80200d <ipc_recv+0x2d>
	else
        r = sys_ipc_recv((void *)-1);
  802000:	83 ec 0c             	sub    $0xc,%esp
  802003:	6a ff                	push   $0xffffffff
  802005:	e8 98 ef ff ff       	call   800fa2 <sys_ipc_recv>
  80200a:	83 c4 10             	add    $0x10,%esp

	if (r < 0) {
  80200d:	85 c0                	test   %eax,%eax
  80200f:	79 16                	jns    802027 <ipc_recv+0x47>

		if (from_env_store != NULL)
  802011:	85 f6                	test   %esi,%esi
  802013:	74 06                	je     80201b <ipc_recv+0x3b>
			*from_env_store = 0;
  802015:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL)
  80201b:	85 db                	test   %ebx,%ebx
  80201d:	74 2c                	je     80204b <ipc_recv+0x6b>
			*perm_store = 0;
  80201f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802025:	eb 24                	jmp    80204b <ipc_recv+0x6b>
		return r;

	} else {

		if (from_env_store != NULL)
  802027:	85 f6                	test   %esi,%esi
  802029:	74 0a                	je     802035 <ipc_recv+0x55>
			*from_env_store = thisenv->env_ipc_from;
  80202b:	a1 04 40 80 00       	mov    0x804004,%eax
  802030:	8b 40 74             	mov    0x74(%eax),%eax
  802033:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL)
  802035:	85 db                	test   %ebx,%ebx
  802037:	74 0a                	je     802043 <ipc_recv+0x63>
			*perm_store = thisenv->env_ipc_perm;
  802039:	a1 04 40 80 00       	mov    0x804004,%eax
  80203e:	8b 40 78             	mov    0x78(%eax),%eax
  802041:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  802043:	a1 04 40 80 00       	mov    0x804004,%eax
  802048:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  80204b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80204e:	5b                   	pop    %ebx
  80204f:	5e                   	pop    %esi
  802050:	5d                   	pop    %ebp
  802051:	c3                   	ret    

00802052 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802052:	55                   	push   %ebp
  802053:	89 e5                	mov    %esp,%ebp
  802055:	57                   	push   %edi
  802056:	56                   	push   %esi
  802057:	53                   	push   %ebx
  802058:	83 ec 0c             	sub    $0xc,%esp
  80205b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80205e:	8b 75 0c             	mov    0xc(%ebp),%esi
  802061:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

	if (pg == NULL)
  802064:	85 db                	test   %ebx,%ebx
		pg = (void *)-1;	
  802066:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80206b:	0f 44 d8             	cmove  %eax,%ebx

	while (true) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80206e:	ff 75 14             	pushl  0x14(%ebp)
  802071:	53                   	push   %ebx
  802072:	56                   	push   %esi
  802073:	57                   	push   %edi
  802074:	e8 06 ef ff ff       	call   800f7f <sys_ipc_try_send>
		if (r >= 0)
  802079:	83 c4 10             	add    $0x10,%esp
  80207c:	85 c0                	test   %eax,%eax
  80207e:	79 1e                	jns    80209e <ipc_send+0x4c>
			return;
		else if (r != -E_IPC_NOT_RECV)
  802080:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802083:	74 12                	je     802097 <ipc_send+0x45>
			panic("ipc_send error: %e", r);
  802085:	50                   	push   %eax
  802086:	68 d8 29 80 00       	push   $0x8029d8
  80208b:	6a 49                	push   $0x49
  80208d:	68 eb 29 80 00       	push   $0x8029eb
  802092:	e8 7b e2 ff ff       	call   800312 <_panic>
	
		sys_yield();
  802097:	e8 37 ed ff ff       	call   800dd3 <sys_yield>
	}
  80209c:	eb d0                	jmp    80206e <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  80209e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020a1:	5b                   	pop    %ebx
  8020a2:	5e                   	pop    %esi
  8020a3:	5f                   	pop    %edi
  8020a4:	5d                   	pop    %ebp
  8020a5:	c3                   	ret    

008020a6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020a6:	55                   	push   %ebp
  8020a7:	89 e5                	mov    %esp,%ebp
  8020a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020ac:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020b1:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8020b4:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020ba:	8b 52 50             	mov    0x50(%edx),%edx
  8020bd:	39 ca                	cmp    %ecx,%edx
  8020bf:	75 0d                	jne    8020ce <ipc_find_env+0x28>
			return envs[i].env_id;
  8020c1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020c4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020c9:	8b 40 48             	mov    0x48(%eax),%eax
  8020cc:	eb 0f                	jmp    8020dd <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020ce:	83 c0 01             	add    $0x1,%eax
  8020d1:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020d6:	75 d9                	jne    8020b1 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8020d8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020dd:	5d                   	pop    %ebp
  8020de:	c3                   	ret    

008020df <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020df:	55                   	push   %ebp
  8020e0:	89 e5                	mov    %esp,%ebp
  8020e2:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020e5:	89 d0                	mov    %edx,%eax
  8020e7:	c1 e8 16             	shr    $0x16,%eax
  8020ea:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020f1:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020f6:	f6 c1 01             	test   $0x1,%cl
  8020f9:	74 1d                	je     802118 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020fb:	c1 ea 0c             	shr    $0xc,%edx
  8020fe:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802105:	f6 c2 01             	test   $0x1,%dl
  802108:	74 0e                	je     802118 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80210a:	c1 ea 0c             	shr    $0xc,%edx
  80210d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802114:	ef 
  802115:	0f b7 c0             	movzwl %ax,%eax
}
  802118:	5d                   	pop    %ebp
  802119:	c3                   	ret    
  80211a:	66 90                	xchg   %ax,%ax
  80211c:	66 90                	xchg   %ax,%ax
  80211e:	66 90                	xchg   %ax,%ax

00802120 <__udivdi3>:
  802120:	55                   	push   %ebp
  802121:	57                   	push   %edi
  802122:	56                   	push   %esi
  802123:	53                   	push   %ebx
  802124:	83 ec 1c             	sub    $0x1c,%esp
  802127:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80212b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80212f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802133:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802137:	85 f6                	test   %esi,%esi
  802139:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80213d:	89 ca                	mov    %ecx,%edx
  80213f:	89 f8                	mov    %edi,%eax
  802141:	75 3d                	jne    802180 <__udivdi3+0x60>
  802143:	39 cf                	cmp    %ecx,%edi
  802145:	0f 87 c5 00 00 00    	ja     802210 <__udivdi3+0xf0>
  80214b:	85 ff                	test   %edi,%edi
  80214d:	89 fd                	mov    %edi,%ebp
  80214f:	75 0b                	jne    80215c <__udivdi3+0x3c>
  802151:	b8 01 00 00 00       	mov    $0x1,%eax
  802156:	31 d2                	xor    %edx,%edx
  802158:	f7 f7                	div    %edi
  80215a:	89 c5                	mov    %eax,%ebp
  80215c:	89 c8                	mov    %ecx,%eax
  80215e:	31 d2                	xor    %edx,%edx
  802160:	f7 f5                	div    %ebp
  802162:	89 c1                	mov    %eax,%ecx
  802164:	89 d8                	mov    %ebx,%eax
  802166:	89 cf                	mov    %ecx,%edi
  802168:	f7 f5                	div    %ebp
  80216a:	89 c3                	mov    %eax,%ebx
  80216c:	89 d8                	mov    %ebx,%eax
  80216e:	89 fa                	mov    %edi,%edx
  802170:	83 c4 1c             	add    $0x1c,%esp
  802173:	5b                   	pop    %ebx
  802174:	5e                   	pop    %esi
  802175:	5f                   	pop    %edi
  802176:	5d                   	pop    %ebp
  802177:	c3                   	ret    
  802178:	90                   	nop
  802179:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802180:	39 ce                	cmp    %ecx,%esi
  802182:	77 74                	ja     8021f8 <__udivdi3+0xd8>
  802184:	0f bd fe             	bsr    %esi,%edi
  802187:	83 f7 1f             	xor    $0x1f,%edi
  80218a:	0f 84 98 00 00 00    	je     802228 <__udivdi3+0x108>
  802190:	bb 20 00 00 00       	mov    $0x20,%ebx
  802195:	89 f9                	mov    %edi,%ecx
  802197:	89 c5                	mov    %eax,%ebp
  802199:	29 fb                	sub    %edi,%ebx
  80219b:	d3 e6                	shl    %cl,%esi
  80219d:	89 d9                	mov    %ebx,%ecx
  80219f:	d3 ed                	shr    %cl,%ebp
  8021a1:	89 f9                	mov    %edi,%ecx
  8021a3:	d3 e0                	shl    %cl,%eax
  8021a5:	09 ee                	or     %ebp,%esi
  8021a7:	89 d9                	mov    %ebx,%ecx
  8021a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021ad:	89 d5                	mov    %edx,%ebp
  8021af:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021b3:	d3 ed                	shr    %cl,%ebp
  8021b5:	89 f9                	mov    %edi,%ecx
  8021b7:	d3 e2                	shl    %cl,%edx
  8021b9:	89 d9                	mov    %ebx,%ecx
  8021bb:	d3 e8                	shr    %cl,%eax
  8021bd:	09 c2                	or     %eax,%edx
  8021bf:	89 d0                	mov    %edx,%eax
  8021c1:	89 ea                	mov    %ebp,%edx
  8021c3:	f7 f6                	div    %esi
  8021c5:	89 d5                	mov    %edx,%ebp
  8021c7:	89 c3                	mov    %eax,%ebx
  8021c9:	f7 64 24 0c          	mull   0xc(%esp)
  8021cd:	39 d5                	cmp    %edx,%ebp
  8021cf:	72 10                	jb     8021e1 <__udivdi3+0xc1>
  8021d1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8021d5:	89 f9                	mov    %edi,%ecx
  8021d7:	d3 e6                	shl    %cl,%esi
  8021d9:	39 c6                	cmp    %eax,%esi
  8021db:	73 07                	jae    8021e4 <__udivdi3+0xc4>
  8021dd:	39 d5                	cmp    %edx,%ebp
  8021df:	75 03                	jne    8021e4 <__udivdi3+0xc4>
  8021e1:	83 eb 01             	sub    $0x1,%ebx
  8021e4:	31 ff                	xor    %edi,%edi
  8021e6:	89 d8                	mov    %ebx,%eax
  8021e8:	89 fa                	mov    %edi,%edx
  8021ea:	83 c4 1c             	add    $0x1c,%esp
  8021ed:	5b                   	pop    %ebx
  8021ee:	5e                   	pop    %esi
  8021ef:	5f                   	pop    %edi
  8021f0:	5d                   	pop    %ebp
  8021f1:	c3                   	ret    
  8021f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021f8:	31 ff                	xor    %edi,%edi
  8021fa:	31 db                	xor    %ebx,%ebx
  8021fc:	89 d8                	mov    %ebx,%eax
  8021fe:	89 fa                	mov    %edi,%edx
  802200:	83 c4 1c             	add    $0x1c,%esp
  802203:	5b                   	pop    %ebx
  802204:	5e                   	pop    %esi
  802205:	5f                   	pop    %edi
  802206:	5d                   	pop    %ebp
  802207:	c3                   	ret    
  802208:	90                   	nop
  802209:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802210:	89 d8                	mov    %ebx,%eax
  802212:	f7 f7                	div    %edi
  802214:	31 ff                	xor    %edi,%edi
  802216:	89 c3                	mov    %eax,%ebx
  802218:	89 d8                	mov    %ebx,%eax
  80221a:	89 fa                	mov    %edi,%edx
  80221c:	83 c4 1c             	add    $0x1c,%esp
  80221f:	5b                   	pop    %ebx
  802220:	5e                   	pop    %esi
  802221:	5f                   	pop    %edi
  802222:	5d                   	pop    %ebp
  802223:	c3                   	ret    
  802224:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802228:	39 ce                	cmp    %ecx,%esi
  80222a:	72 0c                	jb     802238 <__udivdi3+0x118>
  80222c:	31 db                	xor    %ebx,%ebx
  80222e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802232:	0f 87 34 ff ff ff    	ja     80216c <__udivdi3+0x4c>
  802238:	bb 01 00 00 00       	mov    $0x1,%ebx
  80223d:	e9 2a ff ff ff       	jmp    80216c <__udivdi3+0x4c>
  802242:	66 90                	xchg   %ax,%ax
  802244:	66 90                	xchg   %ax,%ax
  802246:	66 90                	xchg   %ax,%ax
  802248:	66 90                	xchg   %ax,%ax
  80224a:	66 90                	xchg   %ax,%ax
  80224c:	66 90                	xchg   %ax,%ax
  80224e:	66 90                	xchg   %ax,%ax

00802250 <__umoddi3>:
  802250:	55                   	push   %ebp
  802251:	57                   	push   %edi
  802252:	56                   	push   %esi
  802253:	53                   	push   %ebx
  802254:	83 ec 1c             	sub    $0x1c,%esp
  802257:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80225b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80225f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802263:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802267:	85 d2                	test   %edx,%edx
  802269:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80226d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802271:	89 f3                	mov    %esi,%ebx
  802273:	89 3c 24             	mov    %edi,(%esp)
  802276:	89 74 24 04          	mov    %esi,0x4(%esp)
  80227a:	75 1c                	jne    802298 <__umoddi3+0x48>
  80227c:	39 f7                	cmp    %esi,%edi
  80227e:	76 50                	jbe    8022d0 <__umoddi3+0x80>
  802280:	89 c8                	mov    %ecx,%eax
  802282:	89 f2                	mov    %esi,%edx
  802284:	f7 f7                	div    %edi
  802286:	89 d0                	mov    %edx,%eax
  802288:	31 d2                	xor    %edx,%edx
  80228a:	83 c4 1c             	add    $0x1c,%esp
  80228d:	5b                   	pop    %ebx
  80228e:	5e                   	pop    %esi
  80228f:	5f                   	pop    %edi
  802290:	5d                   	pop    %ebp
  802291:	c3                   	ret    
  802292:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802298:	39 f2                	cmp    %esi,%edx
  80229a:	89 d0                	mov    %edx,%eax
  80229c:	77 52                	ja     8022f0 <__umoddi3+0xa0>
  80229e:	0f bd ea             	bsr    %edx,%ebp
  8022a1:	83 f5 1f             	xor    $0x1f,%ebp
  8022a4:	75 5a                	jne    802300 <__umoddi3+0xb0>
  8022a6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8022aa:	0f 82 e0 00 00 00    	jb     802390 <__umoddi3+0x140>
  8022b0:	39 0c 24             	cmp    %ecx,(%esp)
  8022b3:	0f 86 d7 00 00 00    	jbe    802390 <__umoddi3+0x140>
  8022b9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022bd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8022c1:	83 c4 1c             	add    $0x1c,%esp
  8022c4:	5b                   	pop    %ebx
  8022c5:	5e                   	pop    %esi
  8022c6:	5f                   	pop    %edi
  8022c7:	5d                   	pop    %ebp
  8022c8:	c3                   	ret    
  8022c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022d0:	85 ff                	test   %edi,%edi
  8022d2:	89 fd                	mov    %edi,%ebp
  8022d4:	75 0b                	jne    8022e1 <__umoddi3+0x91>
  8022d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022db:	31 d2                	xor    %edx,%edx
  8022dd:	f7 f7                	div    %edi
  8022df:	89 c5                	mov    %eax,%ebp
  8022e1:	89 f0                	mov    %esi,%eax
  8022e3:	31 d2                	xor    %edx,%edx
  8022e5:	f7 f5                	div    %ebp
  8022e7:	89 c8                	mov    %ecx,%eax
  8022e9:	f7 f5                	div    %ebp
  8022eb:	89 d0                	mov    %edx,%eax
  8022ed:	eb 99                	jmp    802288 <__umoddi3+0x38>
  8022ef:	90                   	nop
  8022f0:	89 c8                	mov    %ecx,%eax
  8022f2:	89 f2                	mov    %esi,%edx
  8022f4:	83 c4 1c             	add    $0x1c,%esp
  8022f7:	5b                   	pop    %ebx
  8022f8:	5e                   	pop    %esi
  8022f9:	5f                   	pop    %edi
  8022fa:	5d                   	pop    %ebp
  8022fb:	c3                   	ret    
  8022fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802300:	8b 34 24             	mov    (%esp),%esi
  802303:	bf 20 00 00 00       	mov    $0x20,%edi
  802308:	89 e9                	mov    %ebp,%ecx
  80230a:	29 ef                	sub    %ebp,%edi
  80230c:	d3 e0                	shl    %cl,%eax
  80230e:	89 f9                	mov    %edi,%ecx
  802310:	89 f2                	mov    %esi,%edx
  802312:	d3 ea                	shr    %cl,%edx
  802314:	89 e9                	mov    %ebp,%ecx
  802316:	09 c2                	or     %eax,%edx
  802318:	89 d8                	mov    %ebx,%eax
  80231a:	89 14 24             	mov    %edx,(%esp)
  80231d:	89 f2                	mov    %esi,%edx
  80231f:	d3 e2                	shl    %cl,%edx
  802321:	89 f9                	mov    %edi,%ecx
  802323:	89 54 24 04          	mov    %edx,0x4(%esp)
  802327:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80232b:	d3 e8                	shr    %cl,%eax
  80232d:	89 e9                	mov    %ebp,%ecx
  80232f:	89 c6                	mov    %eax,%esi
  802331:	d3 e3                	shl    %cl,%ebx
  802333:	89 f9                	mov    %edi,%ecx
  802335:	89 d0                	mov    %edx,%eax
  802337:	d3 e8                	shr    %cl,%eax
  802339:	89 e9                	mov    %ebp,%ecx
  80233b:	09 d8                	or     %ebx,%eax
  80233d:	89 d3                	mov    %edx,%ebx
  80233f:	89 f2                	mov    %esi,%edx
  802341:	f7 34 24             	divl   (%esp)
  802344:	89 d6                	mov    %edx,%esi
  802346:	d3 e3                	shl    %cl,%ebx
  802348:	f7 64 24 04          	mull   0x4(%esp)
  80234c:	39 d6                	cmp    %edx,%esi
  80234e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802352:	89 d1                	mov    %edx,%ecx
  802354:	89 c3                	mov    %eax,%ebx
  802356:	72 08                	jb     802360 <__umoddi3+0x110>
  802358:	75 11                	jne    80236b <__umoddi3+0x11b>
  80235a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80235e:	73 0b                	jae    80236b <__umoddi3+0x11b>
  802360:	2b 44 24 04          	sub    0x4(%esp),%eax
  802364:	1b 14 24             	sbb    (%esp),%edx
  802367:	89 d1                	mov    %edx,%ecx
  802369:	89 c3                	mov    %eax,%ebx
  80236b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80236f:	29 da                	sub    %ebx,%edx
  802371:	19 ce                	sbb    %ecx,%esi
  802373:	89 f9                	mov    %edi,%ecx
  802375:	89 f0                	mov    %esi,%eax
  802377:	d3 e0                	shl    %cl,%eax
  802379:	89 e9                	mov    %ebp,%ecx
  80237b:	d3 ea                	shr    %cl,%edx
  80237d:	89 e9                	mov    %ebp,%ecx
  80237f:	d3 ee                	shr    %cl,%esi
  802381:	09 d0                	or     %edx,%eax
  802383:	89 f2                	mov    %esi,%edx
  802385:	83 c4 1c             	add    $0x1c,%esp
  802388:	5b                   	pop    %ebx
  802389:	5e                   	pop    %esi
  80238a:	5f                   	pop    %edi
  80238b:	5d                   	pop    %ebp
  80238c:	c3                   	ret    
  80238d:	8d 76 00             	lea    0x0(%esi),%esi
  802390:	29 f9                	sub    %edi,%ecx
  802392:	19 d6                	sbb    %edx,%esi
  802394:	89 74 24 04          	mov    %esi,0x4(%esp)
  802398:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80239c:	e9 18 ff ff ff       	jmp    8022b9 <__umoddi3+0x69>
