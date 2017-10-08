
obj/user/primespipe.debug：     文件格式 elf32-i386


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
  80002c:	e8 07 02 00 00       	call   800238 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(int fd)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  80003f:	8d 75 e0             	lea    -0x20(%ebp),%esi
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);

	cprintf("%d\n", p);

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800042:	8d 7d d8             	lea    -0x28(%ebp),%edi
{
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  800045:	83 ec 04             	sub    $0x4,%esp
  800048:	6a 04                	push   $0x4
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	e8 de 14 00 00       	call   80152f <readn>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	83 f8 04             	cmp    $0x4,%eax
  800057:	74 20                	je     800079 <primeproc+0x46>
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);
  800059:	83 ec 0c             	sub    $0xc,%esp
  80005c:	85 c0                	test   %eax,%eax
  80005e:	ba 00 00 00 00       	mov    $0x0,%edx
  800063:	0f 4e d0             	cmovle %eax,%edx
  800066:	52                   	push   %edx
  800067:	50                   	push   %eax
  800068:	68 00 23 80 00       	push   $0x802300
  80006d:	6a 15                	push   $0x15
  80006f:	68 2f 23 80 00       	push   $0x80232f
  800074:	e8 1f 02 00 00       	call   800298 <_panic>

	cprintf("%d\n", p);
  800079:	83 ec 08             	sub    $0x8,%esp
  80007c:	ff 75 e0             	pushl  -0x20(%ebp)
  80007f:	68 41 23 80 00       	push   $0x802341
  800084:	e8 e8 02 00 00       	call   800371 <cprintf>

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800089:	89 3c 24             	mov    %edi,(%esp)
  80008c:	e8 12 1b 00 00       	call   801ba3 <pipe>
  800091:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	85 c0                	test   %eax,%eax
  800099:	79 12                	jns    8000ad <primeproc+0x7a>
		panic("pipe: %e", i);
  80009b:	50                   	push   %eax
  80009c:	68 45 23 80 00       	push   $0x802345
  8000a1:	6a 1b                	push   $0x1b
  8000a3:	68 2f 23 80 00       	push   $0x80232f
  8000a8:	e8 eb 01 00 00       	call   800298 <_panic>
	if ((id = fork()) < 0)
  8000ad:	e8 5c 0f 00 00       	call   80100e <fork>
  8000b2:	85 c0                	test   %eax,%eax
  8000b4:	79 12                	jns    8000c8 <primeproc+0x95>
		panic("fork: %e", id);
  8000b6:	50                   	push   %eax
  8000b7:	68 4e 23 80 00       	push   $0x80234e
  8000bc:	6a 1d                	push   $0x1d
  8000be:	68 2f 23 80 00       	push   $0x80232f
  8000c3:	e8 d0 01 00 00       	call   800298 <_panic>
	if (id == 0) {
  8000c8:	85 c0                	test   %eax,%eax
  8000ca:	75 1f                	jne    8000eb <primeproc+0xb8>
		close(fd);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	53                   	push   %ebx
  8000d0:	e8 8d 12 00 00       	call   801362 <close>
		close(pfd[1]);
  8000d5:	83 c4 04             	add    $0x4,%esp
  8000d8:	ff 75 dc             	pushl  -0x24(%ebp)
  8000db:	e8 82 12 00 00       	call   801362 <close>
		fd = pfd[0];
  8000e0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		goto top;
  8000e3:	83 c4 10             	add    $0x10,%esp
  8000e6:	e9 5a ff ff ff       	jmp    800045 <primeproc+0x12>
	}

	close(pfd[0]);
  8000eb:	83 ec 0c             	sub    $0xc,%esp
  8000ee:	ff 75 d8             	pushl  -0x28(%ebp)
  8000f1:	e8 6c 12 00 00       	call   801362 <close>
	wfd = pfd[1];
  8000f6:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8000f9:	83 c4 10             	add    $0x10,%esp

	// filter out multiples of our prime
	for (;;) {
		if ((r=readn(fd, &i, 4)) != 4)
  8000fc:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8000ff:	83 ec 04             	sub    $0x4,%esp
  800102:	6a 04                	push   $0x4
  800104:	56                   	push   %esi
  800105:	53                   	push   %ebx
  800106:	e8 24 14 00 00       	call   80152f <readn>
  80010b:	83 c4 10             	add    $0x10,%esp
  80010e:	83 f8 04             	cmp    $0x4,%eax
  800111:	74 24                	je     800137 <primeproc+0x104>
			panic("primeproc %d readn %d %d %e", p, fd, r, r >= 0 ? 0 : r);
  800113:	83 ec 04             	sub    $0x4,%esp
  800116:	85 c0                	test   %eax,%eax
  800118:	ba 00 00 00 00       	mov    $0x0,%edx
  80011d:	0f 4e d0             	cmovle %eax,%edx
  800120:	52                   	push   %edx
  800121:	50                   	push   %eax
  800122:	53                   	push   %ebx
  800123:	ff 75 e0             	pushl  -0x20(%ebp)
  800126:	68 57 23 80 00       	push   $0x802357
  80012b:	6a 2b                	push   $0x2b
  80012d:	68 2f 23 80 00       	push   $0x80232f
  800132:	e8 61 01 00 00       	call   800298 <_panic>
		if (i%p)
  800137:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80013a:	99                   	cltd   
  80013b:	f7 7d e0             	idivl  -0x20(%ebp)
  80013e:	85 d2                	test   %edx,%edx
  800140:	74 bd                	je     8000ff <primeproc+0xcc>
			if ((r=write(wfd, &i, 4)) != 4)
  800142:	83 ec 04             	sub    $0x4,%esp
  800145:	6a 04                	push   $0x4
  800147:	56                   	push   %esi
  800148:	57                   	push   %edi
  800149:	e8 2a 14 00 00       	call   801578 <write>
  80014e:	83 c4 10             	add    $0x10,%esp
  800151:	83 f8 04             	cmp    $0x4,%eax
  800154:	74 a9                	je     8000ff <primeproc+0xcc>
				panic("primeproc %d write: %d %e", p, r, r >= 0 ? 0 : r);
  800156:	83 ec 08             	sub    $0x8,%esp
  800159:	85 c0                	test   %eax,%eax
  80015b:	ba 00 00 00 00       	mov    $0x0,%edx
  800160:	0f 4e d0             	cmovle %eax,%edx
  800163:	52                   	push   %edx
  800164:	50                   	push   %eax
  800165:	ff 75 e0             	pushl  -0x20(%ebp)
  800168:	68 73 23 80 00       	push   $0x802373
  80016d:	6a 2e                	push   $0x2e
  80016f:	68 2f 23 80 00       	push   $0x80232f
  800174:	e8 1f 01 00 00       	call   800298 <_panic>

00800179 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	53                   	push   %ebx
  80017d:	83 ec 20             	sub    $0x20,%esp
	int i, id, p[2], r;

	binaryname = "primespipe";
  800180:	c7 05 00 30 80 00 8d 	movl   $0x80238d,0x803000
  800187:	23 80 00 

	if ((i=pipe(p)) < 0)
  80018a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80018d:	50                   	push   %eax
  80018e:	e8 10 1a 00 00       	call   801ba3 <pipe>
  800193:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800196:	83 c4 10             	add    $0x10,%esp
  800199:	85 c0                	test   %eax,%eax
  80019b:	79 12                	jns    8001af <umain+0x36>
		panic("pipe: %e", i);
  80019d:	50                   	push   %eax
  80019e:	68 45 23 80 00       	push   $0x802345
  8001a3:	6a 3a                	push   $0x3a
  8001a5:	68 2f 23 80 00       	push   $0x80232f
  8001aa:	e8 e9 00 00 00       	call   800298 <_panic>

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  8001af:	e8 5a 0e 00 00       	call   80100e <fork>
  8001b4:	85 c0                	test   %eax,%eax
  8001b6:	79 12                	jns    8001ca <umain+0x51>
		panic("fork: %e", id);
  8001b8:	50                   	push   %eax
  8001b9:	68 4e 23 80 00       	push   $0x80234e
  8001be:	6a 3e                	push   $0x3e
  8001c0:	68 2f 23 80 00       	push   $0x80232f
  8001c5:	e8 ce 00 00 00       	call   800298 <_panic>

	if (id == 0) {
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	75 16                	jne    8001e4 <umain+0x6b>
		close(p[1]);
  8001ce:	83 ec 0c             	sub    $0xc,%esp
  8001d1:	ff 75 f0             	pushl  -0x10(%ebp)
  8001d4:	e8 89 11 00 00       	call   801362 <close>
		primeproc(p[0]);
  8001d9:	83 c4 04             	add    $0x4,%esp
  8001dc:	ff 75 ec             	pushl  -0x14(%ebp)
  8001df:	e8 4f fe ff ff       	call   800033 <primeproc>
	}

	close(p[0]);
  8001e4:	83 ec 0c             	sub    $0xc,%esp
  8001e7:	ff 75 ec             	pushl  -0x14(%ebp)
  8001ea:	e8 73 11 00 00       	call   801362 <close>

	// feed all the integers through
	for (i=2;; i++)
  8001ef:	c7 45 f4 02 00 00 00 	movl   $0x2,-0xc(%ebp)
  8001f6:	83 c4 10             	add    $0x10,%esp
		if ((r=write(p[1], &i, 4)) != 4)
  8001f9:	8d 5d f4             	lea    -0xc(%ebp),%ebx
  8001fc:	83 ec 04             	sub    $0x4,%esp
  8001ff:	6a 04                	push   $0x4
  800201:	53                   	push   %ebx
  800202:	ff 75 f0             	pushl  -0x10(%ebp)
  800205:	e8 6e 13 00 00       	call   801578 <write>
  80020a:	83 c4 10             	add    $0x10,%esp
  80020d:	83 f8 04             	cmp    $0x4,%eax
  800210:	74 20                	je     800232 <umain+0xb9>
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
  800212:	83 ec 0c             	sub    $0xc,%esp
  800215:	85 c0                	test   %eax,%eax
  800217:	ba 00 00 00 00       	mov    $0x0,%edx
  80021c:	0f 4e d0             	cmovle %eax,%edx
  80021f:	52                   	push   %edx
  800220:	50                   	push   %eax
  800221:	68 98 23 80 00       	push   $0x802398
  800226:	6a 4a                	push   $0x4a
  800228:	68 2f 23 80 00       	push   $0x80232f
  80022d:	e8 66 00 00 00       	call   800298 <_panic>
	}

	close(p[0]);

	// feed all the integers through
	for (i=2;; i++)
  800232:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
		if ((r=write(p[1], &i, 4)) != 4)
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
}
  800236:	eb c4                	jmp    8001fc <umain+0x83>

00800238 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	56                   	push   %esi
  80023c:	53                   	push   %ebx
  80023d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800240:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800243:	e8 f2 0a 00 00       	call   800d3a <sys_getenvid>
  800248:	25 ff 03 00 00       	and    $0x3ff,%eax
  80024d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800250:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800255:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80025a:	85 db                	test   %ebx,%ebx
  80025c:	7e 07                	jle    800265 <libmain+0x2d>
		binaryname = argv[0];
  80025e:	8b 06                	mov    (%esi),%eax
  800260:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800265:	83 ec 08             	sub    $0x8,%esp
  800268:	56                   	push   %esi
  800269:	53                   	push   %ebx
  80026a:	e8 0a ff ff ff       	call   800179 <umain>

	// exit gracefully
	exit();
  80026f:	e8 0a 00 00 00       	call   80027e <exit>
}
  800274:	83 c4 10             	add    $0x10,%esp
  800277:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80027a:	5b                   	pop    %ebx
  80027b:	5e                   	pop    %esi
  80027c:	5d                   	pop    %ebp
  80027d:	c3                   	ret    

0080027e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80027e:	55                   	push   %ebp
  80027f:	89 e5                	mov    %esp,%ebp
  800281:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800284:	e8 04 11 00 00       	call   80138d <close_all>
	sys_env_destroy(0);
  800289:	83 ec 0c             	sub    $0xc,%esp
  80028c:	6a 00                	push   $0x0
  80028e:	e8 66 0a 00 00       	call   800cf9 <sys_env_destroy>
}
  800293:	83 c4 10             	add    $0x10,%esp
  800296:	c9                   	leave  
  800297:	c3                   	ret    

00800298 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	56                   	push   %esi
  80029c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80029d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002a0:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8002a6:	e8 8f 0a 00 00       	call   800d3a <sys_getenvid>
  8002ab:	83 ec 0c             	sub    $0xc,%esp
  8002ae:	ff 75 0c             	pushl  0xc(%ebp)
  8002b1:	ff 75 08             	pushl  0x8(%ebp)
  8002b4:	56                   	push   %esi
  8002b5:	50                   	push   %eax
  8002b6:	68 bc 23 80 00       	push   $0x8023bc
  8002bb:	e8 b1 00 00 00       	call   800371 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002c0:	83 c4 18             	add    $0x18,%esp
  8002c3:	53                   	push   %ebx
  8002c4:	ff 75 10             	pushl  0x10(%ebp)
  8002c7:	e8 54 00 00 00       	call   800320 <vcprintf>
	cprintf("\n");
  8002cc:	c7 04 24 43 23 80 00 	movl   $0x802343,(%esp)
  8002d3:	e8 99 00 00 00       	call   800371 <cprintf>
  8002d8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002db:	cc                   	int3   
  8002dc:	eb fd                	jmp    8002db <_panic+0x43>

008002de <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002de:	55                   	push   %ebp
  8002df:	89 e5                	mov    %esp,%ebp
  8002e1:	53                   	push   %ebx
  8002e2:	83 ec 04             	sub    $0x4,%esp
  8002e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002e8:	8b 13                	mov    (%ebx),%edx
  8002ea:	8d 42 01             	lea    0x1(%edx),%eax
  8002ed:	89 03                	mov    %eax,(%ebx)
  8002ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002f2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002f6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002fb:	75 1a                	jne    800317 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002fd:	83 ec 08             	sub    $0x8,%esp
  800300:	68 ff 00 00 00       	push   $0xff
  800305:	8d 43 08             	lea    0x8(%ebx),%eax
  800308:	50                   	push   %eax
  800309:	e8 ae 09 00 00       	call   800cbc <sys_cputs>
		b->idx = 0;
  80030e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800314:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800317:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80031b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80031e:	c9                   	leave  
  80031f:	c3                   	ret    

00800320 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800329:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800330:	00 00 00 
	b.cnt = 0;
  800333:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80033a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80033d:	ff 75 0c             	pushl  0xc(%ebp)
  800340:	ff 75 08             	pushl  0x8(%ebp)
  800343:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800349:	50                   	push   %eax
  80034a:	68 de 02 80 00       	push   $0x8002de
  80034f:	e8 1a 01 00 00       	call   80046e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800354:	83 c4 08             	add    $0x8,%esp
  800357:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80035d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800363:	50                   	push   %eax
  800364:	e8 53 09 00 00       	call   800cbc <sys_cputs>

	return b.cnt;
}
  800369:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80036f:	c9                   	leave  
  800370:	c3                   	ret    

00800371 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
  800374:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800377:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80037a:	50                   	push   %eax
  80037b:	ff 75 08             	pushl  0x8(%ebp)
  80037e:	e8 9d ff ff ff       	call   800320 <vcprintf>
	va_end(ap);

	return cnt;
}
  800383:	c9                   	leave  
  800384:	c3                   	ret    

00800385 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800385:	55                   	push   %ebp
  800386:	89 e5                	mov    %esp,%ebp
  800388:	57                   	push   %edi
  800389:	56                   	push   %esi
  80038a:	53                   	push   %ebx
  80038b:	83 ec 1c             	sub    $0x1c,%esp
  80038e:	89 c7                	mov    %eax,%edi
  800390:	89 d6                	mov    %edx,%esi
  800392:	8b 45 08             	mov    0x8(%ebp),%eax
  800395:	8b 55 0c             	mov    0xc(%ebp),%edx
  800398:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80039b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80039e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8003a1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003a6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003a9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8003ac:	39 d3                	cmp    %edx,%ebx
  8003ae:	72 05                	jb     8003b5 <printnum+0x30>
  8003b0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003b3:	77 45                	ja     8003fa <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003b5:	83 ec 0c             	sub    $0xc,%esp
  8003b8:	ff 75 18             	pushl  0x18(%ebp)
  8003bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003be:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8003c1:	53                   	push   %ebx
  8003c2:	ff 75 10             	pushl  0x10(%ebp)
  8003c5:	83 ec 08             	sub    $0x8,%esp
  8003c8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003cb:	ff 75 e0             	pushl  -0x20(%ebp)
  8003ce:	ff 75 dc             	pushl  -0x24(%ebp)
  8003d1:	ff 75 d8             	pushl  -0x28(%ebp)
  8003d4:	e8 87 1c 00 00       	call   802060 <__udivdi3>
  8003d9:	83 c4 18             	add    $0x18,%esp
  8003dc:	52                   	push   %edx
  8003dd:	50                   	push   %eax
  8003de:	89 f2                	mov    %esi,%edx
  8003e0:	89 f8                	mov    %edi,%eax
  8003e2:	e8 9e ff ff ff       	call   800385 <printnum>
  8003e7:	83 c4 20             	add    $0x20,%esp
  8003ea:	eb 18                	jmp    800404 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003ec:	83 ec 08             	sub    $0x8,%esp
  8003ef:	56                   	push   %esi
  8003f0:	ff 75 18             	pushl  0x18(%ebp)
  8003f3:	ff d7                	call   *%edi
  8003f5:	83 c4 10             	add    $0x10,%esp
  8003f8:	eb 03                	jmp    8003fd <printnum+0x78>
  8003fa:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003fd:	83 eb 01             	sub    $0x1,%ebx
  800400:	85 db                	test   %ebx,%ebx
  800402:	7f e8                	jg     8003ec <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800404:	83 ec 08             	sub    $0x8,%esp
  800407:	56                   	push   %esi
  800408:	83 ec 04             	sub    $0x4,%esp
  80040b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80040e:	ff 75 e0             	pushl  -0x20(%ebp)
  800411:	ff 75 dc             	pushl  -0x24(%ebp)
  800414:	ff 75 d8             	pushl  -0x28(%ebp)
  800417:	e8 74 1d 00 00       	call   802190 <__umoddi3>
  80041c:	83 c4 14             	add    $0x14,%esp
  80041f:	0f be 80 df 23 80 00 	movsbl 0x8023df(%eax),%eax
  800426:	50                   	push   %eax
  800427:	ff d7                	call   *%edi
}
  800429:	83 c4 10             	add    $0x10,%esp
  80042c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80042f:	5b                   	pop    %ebx
  800430:	5e                   	pop    %esi
  800431:	5f                   	pop    %edi
  800432:	5d                   	pop    %ebp
  800433:	c3                   	ret    

00800434 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800434:	55                   	push   %ebp
  800435:	89 e5                	mov    %esp,%ebp
  800437:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80043a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80043e:	8b 10                	mov    (%eax),%edx
  800440:	3b 50 04             	cmp    0x4(%eax),%edx
  800443:	73 0a                	jae    80044f <sprintputch+0x1b>
		*b->buf++ = ch;
  800445:	8d 4a 01             	lea    0x1(%edx),%ecx
  800448:	89 08                	mov    %ecx,(%eax)
  80044a:	8b 45 08             	mov    0x8(%ebp),%eax
  80044d:	88 02                	mov    %al,(%edx)
}
  80044f:	5d                   	pop    %ebp
  800450:	c3                   	ret    

00800451 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800451:	55                   	push   %ebp
  800452:	89 e5                	mov    %esp,%ebp
  800454:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800457:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80045a:	50                   	push   %eax
  80045b:	ff 75 10             	pushl  0x10(%ebp)
  80045e:	ff 75 0c             	pushl  0xc(%ebp)
  800461:	ff 75 08             	pushl  0x8(%ebp)
  800464:	e8 05 00 00 00       	call   80046e <vprintfmt>
	va_end(ap);
}
  800469:	83 c4 10             	add    $0x10,%esp
  80046c:	c9                   	leave  
  80046d:	c3                   	ret    

0080046e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80046e:	55                   	push   %ebp
  80046f:	89 e5                	mov    %esp,%ebp
  800471:	57                   	push   %edi
  800472:	56                   	push   %esi
  800473:	53                   	push   %ebx
  800474:	83 ec 2c             	sub    $0x2c,%esp
  800477:	8b 75 08             	mov    0x8(%ebp),%esi
  80047a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80047d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800480:	eb 12                	jmp    800494 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800482:	85 c0                	test   %eax,%eax
  800484:	0f 84 42 04 00 00    	je     8008cc <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  80048a:	83 ec 08             	sub    $0x8,%esp
  80048d:	53                   	push   %ebx
  80048e:	50                   	push   %eax
  80048f:	ff d6                	call   *%esi
  800491:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800494:	83 c7 01             	add    $0x1,%edi
  800497:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80049b:	83 f8 25             	cmp    $0x25,%eax
  80049e:	75 e2                	jne    800482 <vprintfmt+0x14>
  8004a0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8004a4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8004ab:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004b2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8004b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8004be:	eb 07                	jmp    8004c7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004c3:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c7:	8d 47 01             	lea    0x1(%edi),%eax
  8004ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004cd:	0f b6 07             	movzbl (%edi),%eax
  8004d0:	0f b6 d0             	movzbl %al,%edx
  8004d3:	83 e8 23             	sub    $0x23,%eax
  8004d6:	3c 55                	cmp    $0x55,%al
  8004d8:	0f 87 d3 03 00 00    	ja     8008b1 <vprintfmt+0x443>
  8004de:	0f b6 c0             	movzbl %al,%eax
  8004e1:	ff 24 85 20 25 80 00 	jmp    *0x802520(,%eax,4)
  8004e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004eb:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004ef:	eb d6                	jmp    8004c7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004fc:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004ff:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800503:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800506:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800509:	83 f9 09             	cmp    $0x9,%ecx
  80050c:	77 3f                	ja     80054d <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80050e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800511:	eb e9                	jmp    8004fc <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800513:	8b 45 14             	mov    0x14(%ebp),%eax
  800516:	8b 00                	mov    (%eax),%eax
  800518:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80051b:	8b 45 14             	mov    0x14(%ebp),%eax
  80051e:	8d 40 04             	lea    0x4(%eax),%eax
  800521:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800524:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800527:	eb 2a                	jmp    800553 <vprintfmt+0xe5>
  800529:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80052c:	85 c0                	test   %eax,%eax
  80052e:	ba 00 00 00 00       	mov    $0x0,%edx
  800533:	0f 49 d0             	cmovns %eax,%edx
  800536:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800539:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80053c:	eb 89                	jmp    8004c7 <vprintfmt+0x59>
  80053e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800541:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800548:	e9 7a ff ff ff       	jmp    8004c7 <vprintfmt+0x59>
  80054d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800550:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800553:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800557:	0f 89 6a ff ff ff    	jns    8004c7 <vprintfmt+0x59>
				width = precision, precision = -1;
  80055d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800560:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800563:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80056a:	e9 58 ff ff ff       	jmp    8004c7 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80056f:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800572:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800575:	e9 4d ff ff ff       	jmp    8004c7 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80057a:	8b 45 14             	mov    0x14(%ebp),%eax
  80057d:	8d 78 04             	lea    0x4(%eax),%edi
  800580:	83 ec 08             	sub    $0x8,%esp
  800583:	53                   	push   %ebx
  800584:	ff 30                	pushl  (%eax)
  800586:	ff d6                	call   *%esi
			break;
  800588:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80058b:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800591:	e9 fe fe ff ff       	jmp    800494 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800596:	8b 45 14             	mov    0x14(%ebp),%eax
  800599:	8d 78 04             	lea    0x4(%eax),%edi
  80059c:	8b 00                	mov    (%eax),%eax
  80059e:	99                   	cltd   
  80059f:	31 d0                	xor    %edx,%eax
  8005a1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005a3:	83 f8 0f             	cmp    $0xf,%eax
  8005a6:	7f 0b                	jg     8005b3 <vprintfmt+0x145>
  8005a8:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  8005af:	85 d2                	test   %edx,%edx
  8005b1:	75 1b                	jne    8005ce <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8005b3:	50                   	push   %eax
  8005b4:	68 f7 23 80 00       	push   $0x8023f7
  8005b9:	53                   	push   %ebx
  8005ba:	56                   	push   %esi
  8005bb:	e8 91 fe ff ff       	call   800451 <printfmt>
  8005c0:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005c3:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005c9:	e9 c6 fe ff ff       	jmp    800494 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005ce:	52                   	push   %edx
  8005cf:	68 1d 28 80 00       	push   $0x80281d
  8005d4:	53                   	push   %ebx
  8005d5:	56                   	push   %esi
  8005d6:	e8 76 fe ff ff       	call   800451 <printfmt>
  8005db:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8005de:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e4:	e9 ab fe ff ff       	jmp    800494 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ec:	83 c0 04             	add    $0x4,%eax
  8005ef:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8005f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f5:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005f7:	85 ff                	test   %edi,%edi
  8005f9:	b8 f0 23 80 00       	mov    $0x8023f0,%eax
  8005fe:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800601:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800605:	0f 8e 94 00 00 00    	jle    80069f <vprintfmt+0x231>
  80060b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80060f:	0f 84 98 00 00 00    	je     8006ad <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800615:	83 ec 08             	sub    $0x8,%esp
  800618:	ff 75 d0             	pushl  -0x30(%ebp)
  80061b:	57                   	push   %edi
  80061c:	e8 33 03 00 00       	call   800954 <strnlen>
  800621:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800624:	29 c1                	sub    %eax,%ecx
  800626:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800629:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80062c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800630:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800633:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800636:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800638:	eb 0f                	jmp    800649 <vprintfmt+0x1db>
					putch(padc, putdat);
  80063a:	83 ec 08             	sub    $0x8,%esp
  80063d:	53                   	push   %ebx
  80063e:	ff 75 e0             	pushl  -0x20(%ebp)
  800641:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800643:	83 ef 01             	sub    $0x1,%edi
  800646:	83 c4 10             	add    $0x10,%esp
  800649:	85 ff                	test   %edi,%edi
  80064b:	7f ed                	jg     80063a <vprintfmt+0x1cc>
  80064d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800650:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800653:	85 c9                	test   %ecx,%ecx
  800655:	b8 00 00 00 00       	mov    $0x0,%eax
  80065a:	0f 49 c1             	cmovns %ecx,%eax
  80065d:	29 c1                	sub    %eax,%ecx
  80065f:	89 75 08             	mov    %esi,0x8(%ebp)
  800662:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800665:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800668:	89 cb                	mov    %ecx,%ebx
  80066a:	eb 4d                	jmp    8006b9 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80066c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800670:	74 1b                	je     80068d <vprintfmt+0x21f>
  800672:	0f be c0             	movsbl %al,%eax
  800675:	83 e8 20             	sub    $0x20,%eax
  800678:	83 f8 5e             	cmp    $0x5e,%eax
  80067b:	76 10                	jbe    80068d <vprintfmt+0x21f>
					putch('?', putdat);
  80067d:	83 ec 08             	sub    $0x8,%esp
  800680:	ff 75 0c             	pushl  0xc(%ebp)
  800683:	6a 3f                	push   $0x3f
  800685:	ff 55 08             	call   *0x8(%ebp)
  800688:	83 c4 10             	add    $0x10,%esp
  80068b:	eb 0d                	jmp    80069a <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80068d:	83 ec 08             	sub    $0x8,%esp
  800690:	ff 75 0c             	pushl  0xc(%ebp)
  800693:	52                   	push   %edx
  800694:	ff 55 08             	call   *0x8(%ebp)
  800697:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80069a:	83 eb 01             	sub    $0x1,%ebx
  80069d:	eb 1a                	jmp    8006b9 <vprintfmt+0x24b>
  80069f:	89 75 08             	mov    %esi,0x8(%ebp)
  8006a2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006a5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006a8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006ab:	eb 0c                	jmp    8006b9 <vprintfmt+0x24b>
  8006ad:	89 75 08             	mov    %esi,0x8(%ebp)
  8006b0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006b3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006b6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006b9:	83 c7 01             	add    $0x1,%edi
  8006bc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006c0:	0f be d0             	movsbl %al,%edx
  8006c3:	85 d2                	test   %edx,%edx
  8006c5:	74 23                	je     8006ea <vprintfmt+0x27c>
  8006c7:	85 f6                	test   %esi,%esi
  8006c9:	78 a1                	js     80066c <vprintfmt+0x1fe>
  8006cb:	83 ee 01             	sub    $0x1,%esi
  8006ce:	79 9c                	jns    80066c <vprintfmt+0x1fe>
  8006d0:	89 df                	mov    %ebx,%edi
  8006d2:	8b 75 08             	mov    0x8(%ebp),%esi
  8006d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006d8:	eb 18                	jmp    8006f2 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006da:	83 ec 08             	sub    $0x8,%esp
  8006dd:	53                   	push   %ebx
  8006de:	6a 20                	push   $0x20
  8006e0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006e2:	83 ef 01             	sub    $0x1,%edi
  8006e5:	83 c4 10             	add    $0x10,%esp
  8006e8:	eb 08                	jmp    8006f2 <vprintfmt+0x284>
  8006ea:	89 df                	mov    %ebx,%edi
  8006ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8006ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006f2:	85 ff                	test   %edi,%edi
  8006f4:	7f e4                	jg     8006da <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006f6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006f9:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006ff:	e9 90 fd ff ff       	jmp    800494 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800704:	83 f9 01             	cmp    $0x1,%ecx
  800707:	7e 19                	jle    800722 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800709:	8b 45 14             	mov    0x14(%ebp),%eax
  80070c:	8b 50 04             	mov    0x4(%eax),%edx
  80070f:	8b 00                	mov    (%eax),%eax
  800711:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800714:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800717:	8b 45 14             	mov    0x14(%ebp),%eax
  80071a:	8d 40 08             	lea    0x8(%eax),%eax
  80071d:	89 45 14             	mov    %eax,0x14(%ebp)
  800720:	eb 38                	jmp    80075a <vprintfmt+0x2ec>
	else if (lflag)
  800722:	85 c9                	test   %ecx,%ecx
  800724:	74 1b                	je     800741 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800726:	8b 45 14             	mov    0x14(%ebp),%eax
  800729:	8b 00                	mov    (%eax),%eax
  80072b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80072e:	89 c1                	mov    %eax,%ecx
  800730:	c1 f9 1f             	sar    $0x1f,%ecx
  800733:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800736:	8b 45 14             	mov    0x14(%ebp),%eax
  800739:	8d 40 04             	lea    0x4(%eax),%eax
  80073c:	89 45 14             	mov    %eax,0x14(%ebp)
  80073f:	eb 19                	jmp    80075a <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800741:	8b 45 14             	mov    0x14(%ebp),%eax
  800744:	8b 00                	mov    (%eax),%eax
  800746:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800749:	89 c1                	mov    %eax,%ecx
  80074b:	c1 f9 1f             	sar    $0x1f,%ecx
  80074e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800751:	8b 45 14             	mov    0x14(%ebp),%eax
  800754:	8d 40 04             	lea    0x4(%eax),%eax
  800757:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80075a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80075d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800760:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800765:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800769:	0f 89 0e 01 00 00    	jns    80087d <vprintfmt+0x40f>
				putch('-', putdat);
  80076f:	83 ec 08             	sub    $0x8,%esp
  800772:	53                   	push   %ebx
  800773:	6a 2d                	push   $0x2d
  800775:	ff d6                	call   *%esi
				num = -(long long) num;
  800777:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80077a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80077d:	f7 da                	neg    %edx
  80077f:	83 d1 00             	adc    $0x0,%ecx
  800782:	f7 d9                	neg    %ecx
  800784:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800787:	b8 0a 00 00 00       	mov    $0xa,%eax
  80078c:	e9 ec 00 00 00       	jmp    80087d <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800791:	83 f9 01             	cmp    $0x1,%ecx
  800794:	7e 18                	jle    8007ae <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800796:	8b 45 14             	mov    0x14(%ebp),%eax
  800799:	8b 10                	mov    (%eax),%edx
  80079b:	8b 48 04             	mov    0x4(%eax),%ecx
  80079e:	8d 40 08             	lea    0x8(%eax),%eax
  8007a1:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8007a4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007a9:	e9 cf 00 00 00       	jmp    80087d <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8007ae:	85 c9                	test   %ecx,%ecx
  8007b0:	74 1a                	je     8007cc <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8007b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b5:	8b 10                	mov    (%eax),%edx
  8007b7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007bc:	8d 40 04             	lea    0x4(%eax),%eax
  8007bf:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8007c2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007c7:	e9 b1 00 00 00       	jmp    80087d <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8007cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cf:	8b 10                	mov    (%eax),%edx
  8007d1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007d6:	8d 40 04             	lea    0x4(%eax),%eax
  8007d9:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8007dc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007e1:	e9 97 00 00 00       	jmp    80087d <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8007e6:	83 ec 08             	sub    $0x8,%esp
  8007e9:	53                   	push   %ebx
  8007ea:	6a 58                	push   $0x58
  8007ec:	ff d6                	call   *%esi
			putch('X', putdat);
  8007ee:	83 c4 08             	add    $0x8,%esp
  8007f1:	53                   	push   %ebx
  8007f2:	6a 58                	push   $0x58
  8007f4:	ff d6                	call   *%esi
			putch('X', putdat);
  8007f6:	83 c4 08             	add    $0x8,%esp
  8007f9:	53                   	push   %ebx
  8007fa:	6a 58                	push   $0x58
  8007fc:	ff d6                	call   *%esi
			break;
  8007fe:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800801:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800804:	e9 8b fc ff ff       	jmp    800494 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800809:	83 ec 08             	sub    $0x8,%esp
  80080c:	53                   	push   %ebx
  80080d:	6a 30                	push   $0x30
  80080f:	ff d6                	call   *%esi
			putch('x', putdat);
  800811:	83 c4 08             	add    $0x8,%esp
  800814:	53                   	push   %ebx
  800815:	6a 78                	push   $0x78
  800817:	ff d6                	call   *%esi
			num = (unsigned long long)
  800819:	8b 45 14             	mov    0x14(%ebp),%eax
  80081c:	8b 10                	mov    (%eax),%edx
  80081e:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800823:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800826:	8d 40 04             	lea    0x4(%eax),%eax
  800829:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80082c:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800831:	eb 4a                	jmp    80087d <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800833:	83 f9 01             	cmp    $0x1,%ecx
  800836:	7e 15                	jle    80084d <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  800838:	8b 45 14             	mov    0x14(%ebp),%eax
  80083b:	8b 10                	mov    (%eax),%edx
  80083d:	8b 48 04             	mov    0x4(%eax),%ecx
  800840:	8d 40 08             	lea    0x8(%eax),%eax
  800843:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800846:	b8 10 00 00 00       	mov    $0x10,%eax
  80084b:	eb 30                	jmp    80087d <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80084d:	85 c9                	test   %ecx,%ecx
  80084f:	74 17                	je     800868 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800851:	8b 45 14             	mov    0x14(%ebp),%eax
  800854:	8b 10                	mov    (%eax),%edx
  800856:	b9 00 00 00 00       	mov    $0x0,%ecx
  80085b:	8d 40 04             	lea    0x4(%eax),%eax
  80085e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800861:	b8 10 00 00 00       	mov    $0x10,%eax
  800866:	eb 15                	jmp    80087d <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800868:	8b 45 14             	mov    0x14(%ebp),%eax
  80086b:	8b 10                	mov    (%eax),%edx
  80086d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800872:	8d 40 04             	lea    0x4(%eax),%eax
  800875:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800878:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80087d:	83 ec 0c             	sub    $0xc,%esp
  800880:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800884:	57                   	push   %edi
  800885:	ff 75 e0             	pushl  -0x20(%ebp)
  800888:	50                   	push   %eax
  800889:	51                   	push   %ecx
  80088a:	52                   	push   %edx
  80088b:	89 da                	mov    %ebx,%edx
  80088d:	89 f0                	mov    %esi,%eax
  80088f:	e8 f1 fa ff ff       	call   800385 <printnum>
			break;
  800894:	83 c4 20             	add    $0x20,%esp
  800897:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80089a:	e9 f5 fb ff ff       	jmp    800494 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80089f:	83 ec 08             	sub    $0x8,%esp
  8008a2:	53                   	push   %ebx
  8008a3:	52                   	push   %edx
  8008a4:	ff d6                	call   *%esi
			break;
  8008a6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008ac:	e9 e3 fb ff ff       	jmp    800494 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008b1:	83 ec 08             	sub    $0x8,%esp
  8008b4:	53                   	push   %ebx
  8008b5:	6a 25                	push   $0x25
  8008b7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008b9:	83 c4 10             	add    $0x10,%esp
  8008bc:	eb 03                	jmp    8008c1 <vprintfmt+0x453>
  8008be:	83 ef 01             	sub    $0x1,%edi
  8008c1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008c5:	75 f7                	jne    8008be <vprintfmt+0x450>
  8008c7:	e9 c8 fb ff ff       	jmp    800494 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008cf:	5b                   	pop    %ebx
  8008d0:	5e                   	pop    %esi
  8008d1:	5f                   	pop    %edi
  8008d2:	5d                   	pop    %ebp
  8008d3:	c3                   	ret    

008008d4 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	83 ec 18             	sub    $0x18,%esp
  8008da:	8b 45 08             	mov    0x8(%ebp),%eax
  8008dd:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008e3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008e7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008f1:	85 c0                	test   %eax,%eax
  8008f3:	74 26                	je     80091b <vsnprintf+0x47>
  8008f5:	85 d2                	test   %edx,%edx
  8008f7:	7e 22                	jle    80091b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008f9:	ff 75 14             	pushl  0x14(%ebp)
  8008fc:	ff 75 10             	pushl  0x10(%ebp)
  8008ff:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800902:	50                   	push   %eax
  800903:	68 34 04 80 00       	push   $0x800434
  800908:	e8 61 fb ff ff       	call   80046e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80090d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800910:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800913:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800916:	83 c4 10             	add    $0x10,%esp
  800919:	eb 05                	jmp    800920 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80091b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800920:	c9                   	leave  
  800921:	c3                   	ret    

00800922 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800928:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80092b:	50                   	push   %eax
  80092c:	ff 75 10             	pushl  0x10(%ebp)
  80092f:	ff 75 0c             	pushl  0xc(%ebp)
  800932:	ff 75 08             	pushl  0x8(%ebp)
  800935:	e8 9a ff ff ff       	call   8008d4 <vsnprintf>
	va_end(ap);

	return rc;
}
  80093a:	c9                   	leave  
  80093b:	c3                   	ret    

0080093c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80093c:	55                   	push   %ebp
  80093d:	89 e5                	mov    %esp,%ebp
  80093f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800942:	b8 00 00 00 00       	mov    $0x0,%eax
  800947:	eb 03                	jmp    80094c <strlen+0x10>
		n++;
  800949:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80094c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800950:	75 f7                	jne    800949 <strlen+0xd>
		n++;
	return n;
}
  800952:	5d                   	pop    %ebp
  800953:	c3                   	ret    

00800954 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800954:	55                   	push   %ebp
  800955:	89 e5                	mov    %esp,%ebp
  800957:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80095a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80095d:	ba 00 00 00 00       	mov    $0x0,%edx
  800962:	eb 03                	jmp    800967 <strnlen+0x13>
		n++;
  800964:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800967:	39 c2                	cmp    %eax,%edx
  800969:	74 08                	je     800973 <strnlen+0x1f>
  80096b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80096f:	75 f3                	jne    800964 <strnlen+0x10>
  800971:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800973:	5d                   	pop    %ebp
  800974:	c3                   	ret    

00800975 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800975:	55                   	push   %ebp
  800976:	89 e5                	mov    %esp,%ebp
  800978:	53                   	push   %ebx
  800979:	8b 45 08             	mov    0x8(%ebp),%eax
  80097c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80097f:	89 c2                	mov    %eax,%edx
  800981:	83 c2 01             	add    $0x1,%edx
  800984:	83 c1 01             	add    $0x1,%ecx
  800987:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80098b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80098e:	84 db                	test   %bl,%bl
  800990:	75 ef                	jne    800981 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800992:	5b                   	pop    %ebx
  800993:	5d                   	pop    %ebp
  800994:	c3                   	ret    

00800995 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	53                   	push   %ebx
  800999:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80099c:	53                   	push   %ebx
  80099d:	e8 9a ff ff ff       	call   80093c <strlen>
  8009a2:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009a5:	ff 75 0c             	pushl  0xc(%ebp)
  8009a8:	01 d8                	add    %ebx,%eax
  8009aa:	50                   	push   %eax
  8009ab:	e8 c5 ff ff ff       	call   800975 <strcpy>
	return dst;
}
  8009b0:	89 d8                	mov    %ebx,%eax
  8009b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009b5:	c9                   	leave  
  8009b6:	c3                   	ret    

008009b7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	56                   	push   %esi
  8009bb:	53                   	push   %ebx
  8009bc:	8b 75 08             	mov    0x8(%ebp),%esi
  8009bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009c2:	89 f3                	mov    %esi,%ebx
  8009c4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009c7:	89 f2                	mov    %esi,%edx
  8009c9:	eb 0f                	jmp    8009da <strncpy+0x23>
		*dst++ = *src;
  8009cb:	83 c2 01             	add    $0x1,%edx
  8009ce:	0f b6 01             	movzbl (%ecx),%eax
  8009d1:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009d4:	80 39 01             	cmpb   $0x1,(%ecx)
  8009d7:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009da:	39 da                	cmp    %ebx,%edx
  8009dc:	75 ed                	jne    8009cb <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009de:	89 f0                	mov    %esi,%eax
  8009e0:	5b                   	pop    %ebx
  8009e1:	5e                   	pop    %esi
  8009e2:	5d                   	pop    %ebp
  8009e3:	c3                   	ret    

008009e4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
  8009e7:	56                   	push   %esi
  8009e8:	53                   	push   %ebx
  8009e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8009ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009ef:	8b 55 10             	mov    0x10(%ebp),%edx
  8009f2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009f4:	85 d2                	test   %edx,%edx
  8009f6:	74 21                	je     800a19 <strlcpy+0x35>
  8009f8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009fc:	89 f2                	mov    %esi,%edx
  8009fe:	eb 09                	jmp    800a09 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a00:	83 c2 01             	add    $0x1,%edx
  800a03:	83 c1 01             	add    $0x1,%ecx
  800a06:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a09:	39 c2                	cmp    %eax,%edx
  800a0b:	74 09                	je     800a16 <strlcpy+0x32>
  800a0d:	0f b6 19             	movzbl (%ecx),%ebx
  800a10:	84 db                	test   %bl,%bl
  800a12:	75 ec                	jne    800a00 <strlcpy+0x1c>
  800a14:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a16:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a19:	29 f0                	sub    %esi,%eax
}
  800a1b:	5b                   	pop    %ebx
  800a1c:	5e                   	pop    %esi
  800a1d:	5d                   	pop    %ebp
  800a1e:	c3                   	ret    

00800a1f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a25:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a28:	eb 06                	jmp    800a30 <strcmp+0x11>
		p++, q++;
  800a2a:	83 c1 01             	add    $0x1,%ecx
  800a2d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a30:	0f b6 01             	movzbl (%ecx),%eax
  800a33:	84 c0                	test   %al,%al
  800a35:	74 04                	je     800a3b <strcmp+0x1c>
  800a37:	3a 02                	cmp    (%edx),%al
  800a39:	74 ef                	je     800a2a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a3b:	0f b6 c0             	movzbl %al,%eax
  800a3e:	0f b6 12             	movzbl (%edx),%edx
  800a41:	29 d0                	sub    %edx,%eax
}
  800a43:	5d                   	pop    %ebp
  800a44:	c3                   	ret    

00800a45 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a45:	55                   	push   %ebp
  800a46:	89 e5                	mov    %esp,%ebp
  800a48:	53                   	push   %ebx
  800a49:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a4f:	89 c3                	mov    %eax,%ebx
  800a51:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a54:	eb 06                	jmp    800a5c <strncmp+0x17>
		n--, p++, q++;
  800a56:	83 c0 01             	add    $0x1,%eax
  800a59:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a5c:	39 d8                	cmp    %ebx,%eax
  800a5e:	74 15                	je     800a75 <strncmp+0x30>
  800a60:	0f b6 08             	movzbl (%eax),%ecx
  800a63:	84 c9                	test   %cl,%cl
  800a65:	74 04                	je     800a6b <strncmp+0x26>
  800a67:	3a 0a                	cmp    (%edx),%cl
  800a69:	74 eb                	je     800a56 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a6b:	0f b6 00             	movzbl (%eax),%eax
  800a6e:	0f b6 12             	movzbl (%edx),%edx
  800a71:	29 d0                	sub    %edx,%eax
  800a73:	eb 05                	jmp    800a7a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a75:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a7a:	5b                   	pop    %ebx
  800a7b:	5d                   	pop    %ebp
  800a7c:	c3                   	ret    

00800a7d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	8b 45 08             	mov    0x8(%ebp),%eax
  800a83:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a87:	eb 07                	jmp    800a90 <strchr+0x13>
		if (*s == c)
  800a89:	38 ca                	cmp    %cl,%dl
  800a8b:	74 0f                	je     800a9c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a8d:	83 c0 01             	add    $0x1,%eax
  800a90:	0f b6 10             	movzbl (%eax),%edx
  800a93:	84 d2                	test   %dl,%dl
  800a95:	75 f2                	jne    800a89 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a97:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a9c:	5d                   	pop    %ebp
  800a9d:	c3                   	ret    

00800a9e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a9e:	55                   	push   %ebp
  800a9f:	89 e5                	mov    %esp,%ebp
  800aa1:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aa8:	eb 03                	jmp    800aad <strfind+0xf>
  800aaa:	83 c0 01             	add    $0x1,%eax
  800aad:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ab0:	38 ca                	cmp    %cl,%dl
  800ab2:	74 04                	je     800ab8 <strfind+0x1a>
  800ab4:	84 d2                	test   %dl,%dl
  800ab6:	75 f2                	jne    800aaa <strfind+0xc>
			break;
	return (char *) s;
}
  800ab8:	5d                   	pop    %ebp
  800ab9:	c3                   	ret    

00800aba <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	57                   	push   %edi
  800abe:	56                   	push   %esi
  800abf:	53                   	push   %ebx
  800ac0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ac3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ac6:	85 c9                	test   %ecx,%ecx
  800ac8:	74 36                	je     800b00 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800aca:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ad0:	75 28                	jne    800afa <memset+0x40>
  800ad2:	f6 c1 03             	test   $0x3,%cl
  800ad5:	75 23                	jne    800afa <memset+0x40>
		c &= 0xFF;
  800ad7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800adb:	89 d3                	mov    %edx,%ebx
  800add:	c1 e3 08             	shl    $0x8,%ebx
  800ae0:	89 d6                	mov    %edx,%esi
  800ae2:	c1 e6 18             	shl    $0x18,%esi
  800ae5:	89 d0                	mov    %edx,%eax
  800ae7:	c1 e0 10             	shl    $0x10,%eax
  800aea:	09 f0                	or     %esi,%eax
  800aec:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800aee:	89 d8                	mov    %ebx,%eax
  800af0:	09 d0                	or     %edx,%eax
  800af2:	c1 e9 02             	shr    $0x2,%ecx
  800af5:	fc                   	cld    
  800af6:	f3 ab                	rep stos %eax,%es:(%edi)
  800af8:	eb 06                	jmp    800b00 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800afa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800afd:	fc                   	cld    
  800afe:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b00:	89 f8                	mov    %edi,%eax
  800b02:	5b                   	pop    %ebx
  800b03:	5e                   	pop    %esi
  800b04:	5f                   	pop    %edi
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    

00800b07 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	57                   	push   %edi
  800b0b:	56                   	push   %esi
  800b0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b12:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b15:	39 c6                	cmp    %eax,%esi
  800b17:	73 35                	jae    800b4e <memmove+0x47>
  800b19:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b1c:	39 d0                	cmp    %edx,%eax
  800b1e:	73 2e                	jae    800b4e <memmove+0x47>
		s += n;
		d += n;
  800b20:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b23:	89 d6                	mov    %edx,%esi
  800b25:	09 fe                	or     %edi,%esi
  800b27:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b2d:	75 13                	jne    800b42 <memmove+0x3b>
  800b2f:	f6 c1 03             	test   $0x3,%cl
  800b32:	75 0e                	jne    800b42 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b34:	83 ef 04             	sub    $0x4,%edi
  800b37:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b3a:	c1 e9 02             	shr    $0x2,%ecx
  800b3d:	fd                   	std    
  800b3e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b40:	eb 09                	jmp    800b4b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b42:	83 ef 01             	sub    $0x1,%edi
  800b45:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b48:	fd                   	std    
  800b49:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b4b:	fc                   	cld    
  800b4c:	eb 1d                	jmp    800b6b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b4e:	89 f2                	mov    %esi,%edx
  800b50:	09 c2                	or     %eax,%edx
  800b52:	f6 c2 03             	test   $0x3,%dl
  800b55:	75 0f                	jne    800b66 <memmove+0x5f>
  800b57:	f6 c1 03             	test   $0x3,%cl
  800b5a:	75 0a                	jne    800b66 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b5c:	c1 e9 02             	shr    $0x2,%ecx
  800b5f:	89 c7                	mov    %eax,%edi
  800b61:	fc                   	cld    
  800b62:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b64:	eb 05                	jmp    800b6b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b66:	89 c7                	mov    %eax,%edi
  800b68:	fc                   	cld    
  800b69:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b6b:	5e                   	pop    %esi
  800b6c:	5f                   	pop    %edi
  800b6d:	5d                   	pop    %ebp
  800b6e:	c3                   	ret    

00800b6f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b6f:	55                   	push   %ebp
  800b70:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b72:	ff 75 10             	pushl  0x10(%ebp)
  800b75:	ff 75 0c             	pushl  0xc(%ebp)
  800b78:	ff 75 08             	pushl  0x8(%ebp)
  800b7b:	e8 87 ff ff ff       	call   800b07 <memmove>
}
  800b80:	c9                   	leave  
  800b81:	c3                   	ret    

00800b82 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	56                   	push   %esi
  800b86:	53                   	push   %ebx
  800b87:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b8d:	89 c6                	mov    %eax,%esi
  800b8f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b92:	eb 1a                	jmp    800bae <memcmp+0x2c>
		if (*s1 != *s2)
  800b94:	0f b6 08             	movzbl (%eax),%ecx
  800b97:	0f b6 1a             	movzbl (%edx),%ebx
  800b9a:	38 d9                	cmp    %bl,%cl
  800b9c:	74 0a                	je     800ba8 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b9e:	0f b6 c1             	movzbl %cl,%eax
  800ba1:	0f b6 db             	movzbl %bl,%ebx
  800ba4:	29 d8                	sub    %ebx,%eax
  800ba6:	eb 0f                	jmp    800bb7 <memcmp+0x35>
		s1++, s2++;
  800ba8:	83 c0 01             	add    $0x1,%eax
  800bab:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bae:	39 f0                	cmp    %esi,%eax
  800bb0:	75 e2                	jne    800b94 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bb2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bb7:	5b                   	pop    %ebx
  800bb8:	5e                   	pop    %esi
  800bb9:	5d                   	pop    %ebp
  800bba:	c3                   	ret    

00800bbb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	53                   	push   %ebx
  800bbf:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bc2:	89 c1                	mov    %eax,%ecx
  800bc4:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800bc7:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bcb:	eb 0a                	jmp    800bd7 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bcd:	0f b6 10             	movzbl (%eax),%edx
  800bd0:	39 da                	cmp    %ebx,%edx
  800bd2:	74 07                	je     800bdb <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bd4:	83 c0 01             	add    $0x1,%eax
  800bd7:	39 c8                	cmp    %ecx,%eax
  800bd9:	72 f2                	jb     800bcd <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bdb:	5b                   	pop    %ebx
  800bdc:	5d                   	pop    %ebp
  800bdd:	c3                   	ret    

00800bde <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	57                   	push   %edi
  800be2:	56                   	push   %esi
  800be3:	53                   	push   %ebx
  800be4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800be7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bea:	eb 03                	jmp    800bef <strtol+0x11>
		s++;
  800bec:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bef:	0f b6 01             	movzbl (%ecx),%eax
  800bf2:	3c 20                	cmp    $0x20,%al
  800bf4:	74 f6                	je     800bec <strtol+0xe>
  800bf6:	3c 09                	cmp    $0x9,%al
  800bf8:	74 f2                	je     800bec <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bfa:	3c 2b                	cmp    $0x2b,%al
  800bfc:	75 0a                	jne    800c08 <strtol+0x2a>
		s++;
  800bfe:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c01:	bf 00 00 00 00       	mov    $0x0,%edi
  800c06:	eb 11                	jmp    800c19 <strtol+0x3b>
  800c08:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c0d:	3c 2d                	cmp    $0x2d,%al
  800c0f:	75 08                	jne    800c19 <strtol+0x3b>
		s++, neg = 1;
  800c11:	83 c1 01             	add    $0x1,%ecx
  800c14:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c19:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c1f:	75 15                	jne    800c36 <strtol+0x58>
  800c21:	80 39 30             	cmpb   $0x30,(%ecx)
  800c24:	75 10                	jne    800c36 <strtol+0x58>
  800c26:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c2a:	75 7c                	jne    800ca8 <strtol+0xca>
		s += 2, base = 16;
  800c2c:	83 c1 02             	add    $0x2,%ecx
  800c2f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c34:	eb 16                	jmp    800c4c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c36:	85 db                	test   %ebx,%ebx
  800c38:	75 12                	jne    800c4c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c3a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c3f:	80 39 30             	cmpb   $0x30,(%ecx)
  800c42:	75 08                	jne    800c4c <strtol+0x6e>
		s++, base = 8;
  800c44:	83 c1 01             	add    $0x1,%ecx
  800c47:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c4c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c51:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c54:	0f b6 11             	movzbl (%ecx),%edx
  800c57:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c5a:	89 f3                	mov    %esi,%ebx
  800c5c:	80 fb 09             	cmp    $0x9,%bl
  800c5f:	77 08                	ja     800c69 <strtol+0x8b>
			dig = *s - '0';
  800c61:	0f be d2             	movsbl %dl,%edx
  800c64:	83 ea 30             	sub    $0x30,%edx
  800c67:	eb 22                	jmp    800c8b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c69:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c6c:	89 f3                	mov    %esi,%ebx
  800c6e:	80 fb 19             	cmp    $0x19,%bl
  800c71:	77 08                	ja     800c7b <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c73:	0f be d2             	movsbl %dl,%edx
  800c76:	83 ea 57             	sub    $0x57,%edx
  800c79:	eb 10                	jmp    800c8b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c7b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c7e:	89 f3                	mov    %esi,%ebx
  800c80:	80 fb 19             	cmp    $0x19,%bl
  800c83:	77 16                	ja     800c9b <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c85:	0f be d2             	movsbl %dl,%edx
  800c88:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c8b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c8e:	7d 0b                	jge    800c9b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c90:	83 c1 01             	add    $0x1,%ecx
  800c93:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c97:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c99:	eb b9                	jmp    800c54 <strtol+0x76>

	if (endptr)
  800c9b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c9f:	74 0d                	je     800cae <strtol+0xd0>
		*endptr = (char *) s;
  800ca1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ca4:	89 0e                	mov    %ecx,(%esi)
  800ca6:	eb 06                	jmp    800cae <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ca8:	85 db                	test   %ebx,%ebx
  800caa:	74 98                	je     800c44 <strtol+0x66>
  800cac:	eb 9e                	jmp    800c4c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cae:	89 c2                	mov    %eax,%edx
  800cb0:	f7 da                	neg    %edx
  800cb2:	85 ff                	test   %edi,%edi
  800cb4:	0f 45 c2             	cmovne %edx,%eax
}
  800cb7:	5b                   	pop    %ebx
  800cb8:	5e                   	pop    %esi
  800cb9:	5f                   	pop    %edi
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    

00800cbc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	57                   	push   %edi
  800cc0:	56                   	push   %esi
  800cc1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc2:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cca:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccd:	89 c3                	mov    %eax,%ebx
  800ccf:	89 c7                	mov    %eax,%edi
  800cd1:	89 c6                	mov    %eax,%esi
  800cd3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cd5:	5b                   	pop    %ebx
  800cd6:	5e                   	pop    %esi
  800cd7:	5f                   	pop    %edi
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    

00800cda <sys_cgetc>:

int
sys_cgetc(void)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	57                   	push   %edi
  800cde:	56                   	push   %esi
  800cdf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce5:	b8 01 00 00 00       	mov    $0x1,%eax
  800cea:	89 d1                	mov    %edx,%ecx
  800cec:	89 d3                	mov    %edx,%ebx
  800cee:	89 d7                	mov    %edx,%edi
  800cf0:	89 d6                	mov    %edx,%esi
  800cf2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cf4:	5b                   	pop    %ebx
  800cf5:	5e                   	pop    %esi
  800cf6:	5f                   	pop    %edi
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    

00800cf9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	57                   	push   %edi
  800cfd:	56                   	push   %esi
  800cfe:	53                   	push   %ebx
  800cff:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d02:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d07:	b8 03 00 00 00       	mov    $0x3,%eax
  800d0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0f:	89 cb                	mov    %ecx,%ebx
  800d11:	89 cf                	mov    %ecx,%edi
  800d13:	89 ce                	mov    %ecx,%esi
  800d15:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d17:	85 c0                	test   %eax,%eax
  800d19:	7e 17                	jle    800d32 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1b:	83 ec 0c             	sub    $0xc,%esp
  800d1e:	50                   	push   %eax
  800d1f:	6a 03                	push   $0x3
  800d21:	68 df 26 80 00       	push   $0x8026df
  800d26:	6a 23                	push   $0x23
  800d28:	68 fc 26 80 00       	push   $0x8026fc
  800d2d:	e8 66 f5 ff ff       	call   800298 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d35:	5b                   	pop    %ebx
  800d36:	5e                   	pop    %esi
  800d37:	5f                   	pop    %edi
  800d38:	5d                   	pop    %ebp
  800d39:	c3                   	ret    

00800d3a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d3a:	55                   	push   %ebp
  800d3b:	89 e5                	mov    %esp,%ebp
  800d3d:	57                   	push   %edi
  800d3e:	56                   	push   %esi
  800d3f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d40:	ba 00 00 00 00       	mov    $0x0,%edx
  800d45:	b8 02 00 00 00       	mov    $0x2,%eax
  800d4a:	89 d1                	mov    %edx,%ecx
  800d4c:	89 d3                	mov    %edx,%ebx
  800d4e:	89 d7                	mov    %edx,%edi
  800d50:	89 d6                	mov    %edx,%esi
  800d52:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d54:	5b                   	pop    %ebx
  800d55:	5e                   	pop    %esi
  800d56:	5f                   	pop    %edi
  800d57:	5d                   	pop    %ebp
  800d58:	c3                   	ret    

00800d59 <sys_yield>:

void
sys_yield(void)
{
  800d59:	55                   	push   %ebp
  800d5a:	89 e5                	mov    %esp,%ebp
  800d5c:	57                   	push   %edi
  800d5d:	56                   	push   %esi
  800d5e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d64:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d69:	89 d1                	mov    %edx,%ecx
  800d6b:	89 d3                	mov    %edx,%ebx
  800d6d:	89 d7                	mov    %edx,%edi
  800d6f:	89 d6                	mov    %edx,%esi
  800d71:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d73:	5b                   	pop    %ebx
  800d74:	5e                   	pop    %esi
  800d75:	5f                   	pop    %edi
  800d76:	5d                   	pop    %ebp
  800d77:	c3                   	ret    

00800d78 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d78:	55                   	push   %ebp
  800d79:	89 e5                	mov    %esp,%ebp
  800d7b:	57                   	push   %edi
  800d7c:	56                   	push   %esi
  800d7d:	53                   	push   %ebx
  800d7e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d81:	be 00 00 00 00       	mov    $0x0,%esi
  800d86:	b8 04 00 00 00       	mov    $0x4,%eax
  800d8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d91:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d94:	89 f7                	mov    %esi,%edi
  800d96:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d98:	85 c0                	test   %eax,%eax
  800d9a:	7e 17                	jle    800db3 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9c:	83 ec 0c             	sub    $0xc,%esp
  800d9f:	50                   	push   %eax
  800da0:	6a 04                	push   $0x4
  800da2:	68 df 26 80 00       	push   $0x8026df
  800da7:	6a 23                	push   $0x23
  800da9:	68 fc 26 80 00       	push   $0x8026fc
  800dae:	e8 e5 f4 ff ff       	call   800298 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800db3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db6:	5b                   	pop    %ebx
  800db7:	5e                   	pop    %esi
  800db8:	5f                   	pop    %edi
  800db9:	5d                   	pop    %ebp
  800dba:	c3                   	ret    

00800dbb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800dbb:	55                   	push   %ebp
  800dbc:	89 e5                	mov    %esp,%ebp
  800dbe:	57                   	push   %edi
  800dbf:	56                   	push   %esi
  800dc0:	53                   	push   %ebx
  800dc1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc4:	b8 05 00 00 00       	mov    $0x5,%eax
  800dc9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dcc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dd2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dd5:	8b 75 18             	mov    0x18(%ebp),%esi
  800dd8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dda:	85 c0                	test   %eax,%eax
  800ddc:	7e 17                	jle    800df5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dde:	83 ec 0c             	sub    $0xc,%esp
  800de1:	50                   	push   %eax
  800de2:	6a 05                	push   $0x5
  800de4:	68 df 26 80 00       	push   $0x8026df
  800de9:	6a 23                	push   $0x23
  800deb:	68 fc 26 80 00       	push   $0x8026fc
  800df0:	e8 a3 f4 ff ff       	call   800298 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800df5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df8:	5b                   	pop    %ebx
  800df9:	5e                   	pop    %esi
  800dfa:	5f                   	pop    %edi
  800dfb:	5d                   	pop    %ebp
  800dfc:	c3                   	ret    

00800dfd <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dfd:	55                   	push   %ebp
  800dfe:	89 e5                	mov    %esp,%ebp
  800e00:	57                   	push   %edi
  800e01:	56                   	push   %esi
  800e02:	53                   	push   %ebx
  800e03:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e06:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e0b:	b8 06 00 00 00       	mov    $0x6,%eax
  800e10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e13:	8b 55 08             	mov    0x8(%ebp),%edx
  800e16:	89 df                	mov    %ebx,%edi
  800e18:	89 de                	mov    %ebx,%esi
  800e1a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e1c:	85 c0                	test   %eax,%eax
  800e1e:	7e 17                	jle    800e37 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e20:	83 ec 0c             	sub    $0xc,%esp
  800e23:	50                   	push   %eax
  800e24:	6a 06                	push   $0x6
  800e26:	68 df 26 80 00       	push   $0x8026df
  800e2b:	6a 23                	push   $0x23
  800e2d:	68 fc 26 80 00       	push   $0x8026fc
  800e32:	e8 61 f4 ff ff       	call   800298 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e3a:	5b                   	pop    %ebx
  800e3b:	5e                   	pop    %esi
  800e3c:	5f                   	pop    %edi
  800e3d:	5d                   	pop    %ebp
  800e3e:	c3                   	ret    

00800e3f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e3f:	55                   	push   %ebp
  800e40:	89 e5                	mov    %esp,%ebp
  800e42:	57                   	push   %edi
  800e43:	56                   	push   %esi
  800e44:	53                   	push   %ebx
  800e45:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e48:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e4d:	b8 08 00 00 00       	mov    $0x8,%eax
  800e52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e55:	8b 55 08             	mov    0x8(%ebp),%edx
  800e58:	89 df                	mov    %ebx,%edi
  800e5a:	89 de                	mov    %ebx,%esi
  800e5c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e5e:	85 c0                	test   %eax,%eax
  800e60:	7e 17                	jle    800e79 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e62:	83 ec 0c             	sub    $0xc,%esp
  800e65:	50                   	push   %eax
  800e66:	6a 08                	push   $0x8
  800e68:	68 df 26 80 00       	push   $0x8026df
  800e6d:	6a 23                	push   $0x23
  800e6f:	68 fc 26 80 00       	push   $0x8026fc
  800e74:	e8 1f f4 ff ff       	call   800298 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e7c:	5b                   	pop    %ebx
  800e7d:	5e                   	pop    %esi
  800e7e:	5f                   	pop    %edi
  800e7f:	5d                   	pop    %ebp
  800e80:	c3                   	ret    

00800e81 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e81:	55                   	push   %ebp
  800e82:	89 e5                	mov    %esp,%ebp
  800e84:	57                   	push   %edi
  800e85:	56                   	push   %esi
  800e86:	53                   	push   %ebx
  800e87:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e8f:	b8 09 00 00 00       	mov    $0x9,%eax
  800e94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e97:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9a:	89 df                	mov    %ebx,%edi
  800e9c:	89 de                	mov    %ebx,%esi
  800e9e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ea0:	85 c0                	test   %eax,%eax
  800ea2:	7e 17                	jle    800ebb <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea4:	83 ec 0c             	sub    $0xc,%esp
  800ea7:	50                   	push   %eax
  800ea8:	6a 09                	push   $0x9
  800eaa:	68 df 26 80 00       	push   $0x8026df
  800eaf:	6a 23                	push   $0x23
  800eb1:	68 fc 26 80 00       	push   $0x8026fc
  800eb6:	e8 dd f3 ff ff       	call   800298 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ebb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ebe:	5b                   	pop    %ebx
  800ebf:	5e                   	pop    %esi
  800ec0:	5f                   	pop    %edi
  800ec1:	5d                   	pop    %ebp
  800ec2:	c3                   	ret    

00800ec3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ec3:	55                   	push   %ebp
  800ec4:	89 e5                	mov    %esp,%ebp
  800ec6:	57                   	push   %edi
  800ec7:	56                   	push   %esi
  800ec8:	53                   	push   %ebx
  800ec9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ecc:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ed1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ed6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed9:	8b 55 08             	mov    0x8(%ebp),%edx
  800edc:	89 df                	mov    %ebx,%edi
  800ede:	89 de                	mov    %ebx,%esi
  800ee0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ee2:	85 c0                	test   %eax,%eax
  800ee4:	7e 17                	jle    800efd <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee6:	83 ec 0c             	sub    $0xc,%esp
  800ee9:	50                   	push   %eax
  800eea:	6a 0a                	push   $0xa
  800eec:	68 df 26 80 00       	push   $0x8026df
  800ef1:	6a 23                	push   $0x23
  800ef3:	68 fc 26 80 00       	push   $0x8026fc
  800ef8:	e8 9b f3 ff ff       	call   800298 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800efd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f00:	5b                   	pop    %ebx
  800f01:	5e                   	pop    %esi
  800f02:	5f                   	pop    %edi
  800f03:	5d                   	pop    %ebp
  800f04:	c3                   	ret    

00800f05 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f05:	55                   	push   %ebp
  800f06:	89 e5                	mov    %esp,%ebp
  800f08:	57                   	push   %edi
  800f09:	56                   	push   %esi
  800f0a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f0b:	be 00 00 00 00       	mov    $0x0,%esi
  800f10:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f18:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f1e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f21:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f23:	5b                   	pop    %ebx
  800f24:	5e                   	pop    %esi
  800f25:	5f                   	pop    %edi
  800f26:	5d                   	pop    %ebp
  800f27:	c3                   	ret    

00800f28 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f28:	55                   	push   %ebp
  800f29:	89 e5                	mov    %esp,%ebp
  800f2b:	57                   	push   %edi
  800f2c:	56                   	push   %esi
  800f2d:	53                   	push   %ebx
  800f2e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f31:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f36:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f3e:	89 cb                	mov    %ecx,%ebx
  800f40:	89 cf                	mov    %ecx,%edi
  800f42:	89 ce                	mov    %ecx,%esi
  800f44:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f46:	85 c0                	test   %eax,%eax
  800f48:	7e 17                	jle    800f61 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f4a:	83 ec 0c             	sub    $0xc,%esp
  800f4d:	50                   	push   %eax
  800f4e:	6a 0d                	push   $0xd
  800f50:	68 df 26 80 00       	push   $0x8026df
  800f55:	6a 23                	push   $0x23
  800f57:	68 fc 26 80 00       	push   $0x8026fc
  800f5c:	e8 37 f3 ff ff       	call   800298 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f64:	5b                   	pop    %ebx
  800f65:	5e                   	pop    %esi
  800f66:	5f                   	pop    %edi
  800f67:	5d                   	pop    %ebp
  800f68:	c3                   	ret    

00800f69 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f69:	55                   	push   %ebp
  800f6a:	89 e5                	mov    %esp,%ebp
  800f6c:	57                   	push   %edi
  800f6d:	56                   	push   %esi
  800f6e:	53                   	push   %ebx
  800f6f:	83 ec 0c             	sub    $0xc,%esp
  800f72:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f75:	8b 18                	mov    (%eax),%ebx
	uint32_t err = utf->utf_err;
  800f77:	8b 78 04             	mov    0x4(%eax),%edi
	int r;
	envid_t curenvid = sys_getenvid();
  800f7a:	e8 bb fd ff ff       	call   800d3a <sys_getenvid>
  800f7f:	89 c6                	mov    %eax,%esi
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(err & FEC_WR) && !(uvpt[PGNUM(addr)] & PTE_COW))
  800f81:	f7 c7 02 00 00 00    	test   $0x2,%edi
  800f87:	75 25                	jne    800fae <pgfault+0x45>
  800f89:	89 d8                	mov    %ebx,%eax
  800f8b:	c1 e8 0c             	shr    $0xc,%eax
  800f8e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f95:	f6 c4 08             	test   $0x8,%ah
  800f98:	75 14                	jne    800fae <pgfault+0x45>
	    panic("pgfault error: wrong faulting access");
  800f9a:	83 ec 04             	sub    $0x4,%esp
  800f9d:	68 0c 27 80 00       	push   $0x80270c
  800fa2:	6a 1e                	push   $0x1e
  800fa4:	68 31 27 80 00       	push   $0x802731
  800fa9:	e8 ea f2 ff ff       	call   800298 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	sys_page_alloc(curenvid, PFTEMP, PTE_W | PTE_U | PTE_P);
  800fae:	83 ec 04             	sub    $0x4,%esp
  800fb1:	6a 07                	push   $0x7
  800fb3:	68 00 f0 7f 00       	push   $0x7ff000
  800fb8:	56                   	push   %esi
  800fb9:	e8 ba fd ff ff       	call   800d78 <sys_page_alloc>

	addr = (void *)(PGNUM(addr) * PGSIZE);
  800fbe:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr, PGSIZE);
  800fc4:	83 c4 0c             	add    $0xc,%esp
  800fc7:	68 00 10 00 00       	push   $0x1000
  800fcc:	53                   	push   %ebx
  800fcd:	68 00 f0 7f 00       	push   $0x7ff000
  800fd2:	e8 30 fb ff ff       	call   800b07 <memmove>

	sys_page_unmap(curenvid, addr);
  800fd7:	83 c4 08             	add    $0x8,%esp
  800fda:	53                   	push   %ebx
  800fdb:	56                   	push   %esi
  800fdc:	e8 1c fe ff ff       	call   800dfd <sys_page_unmap>
	sys_page_map(curenvid, PFTEMP, curenvid, addr, PTE_W | PTE_U | PTE_P);
  800fe1:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800fe8:	53                   	push   %ebx
  800fe9:	56                   	push   %esi
  800fea:	68 00 f0 7f 00       	push   $0x7ff000
  800fef:	56                   	push   %esi
  800ff0:	e8 c6 fd ff ff       	call   800dbb <sys_page_map>
	sys_page_unmap(curenvid, PFTEMP);
  800ff5:	83 c4 18             	add    $0x18,%esp
  800ff8:	68 00 f0 7f 00       	push   $0x7ff000
  800ffd:	56                   	push   %esi
  800ffe:	e8 fa fd ff ff       	call   800dfd <sys_page_unmap>
}
  801003:	83 c4 10             	add    $0x10,%esp
  801006:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801009:	5b                   	pop    %ebx
  80100a:	5e                   	pop    %esi
  80100b:	5f                   	pop    %edi
  80100c:	5d                   	pop    %ebp
  80100d:	c3                   	ret    

0080100e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80100e:	55                   	push   %ebp
  80100f:	89 e5                	mov    %esp,%ebp
  801011:	57                   	push   %edi
  801012:	56                   	push   %esi
  801013:	53                   	push   %ebx
  801014:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	extern void _pgfault_upcall();
	envid_t new_envid, curenv_id;

	curenv_id = sys_getenvid();
  801017:	e8 1e fd ff ff       	call   800d3a <sys_getenvid>
	set_pgfault_handler(pgfault);
  80101c:	83 ec 0c             	sub    $0xc,%esp
  80101f:	68 69 0f 80 00       	push   $0x800f69
  801024:	e8 83 0e 00 00       	call   801eac <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801029:	b8 07 00 00 00       	mov    $0x7,%eax
  80102e:	cd 30                	int    $0x30
  801030:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801033:	89 45 dc             	mov    %eax,-0x24(%ebp)
	new_envid = sys_exofork();

	if (new_envid < 0)
  801036:	83 c4 10             	add    $0x10,%esp
  801039:	85 c0                	test   %eax,%eax
  80103b:	79 12                	jns    80104f <fork+0x41>
	    panic("fork error: %e", new_envid);
  80103d:	50                   	push   %eax
  80103e:	68 3c 27 80 00       	push   $0x80273c
  801043:	6a 75                	push   $0x75
  801045:	68 31 27 80 00       	push   $0x802731
  80104a:	e8 49 f2 ff ff       	call   800298 <_panic>
  80104f:	bf 00 00 80 00       	mov    $0x800000,%edi
	else if (new_envid == 0)
  801054:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801058:	75 1c                	jne    801076 <fork+0x68>
		thisenv = envs + ENVX(sys_getenvid());
  80105a:	e8 db fc ff ff       	call   800d3a <sys_getenvid>
  80105f:	25 ff 03 00 00       	and    $0x3ff,%eax
  801064:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801067:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80106c:	a3 04 40 80 00       	mov    %eax,0x804004
  801071:	e9 27 01 00 00       	jmp    80119d <fork+0x18f>
	else {

		for (uint32_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
			if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
  801076:	89 f8                	mov    %edi,%eax
  801078:	c1 e8 16             	shr    $0x16,%eax
  80107b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801082:	a8 01                	test   $0x1,%al
  801084:	0f 84 d2 00 00 00    	je     80115c <fork+0x14e>
  80108a:	89 fb                	mov    %edi,%ebx
  80108c:	c1 eb 0c             	shr    $0xc,%ebx
  80108f:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801096:	a8 01                	test   $0x1,%al
  801098:	0f 84 be 00 00 00    	je     80115c <fork+0x14e>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	int perm = PTE_U | PTE_P;
	envid_t curenvid = sys_getenvid();
  80109e:	e8 97 fc ff ff       	call   800d3a <sys_getenvid>
  8010a3:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  8010a6:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
		perm |= PTE_COW ;
  8010ad:	be 05 08 00 00       	mov    $0x805,%esi
	int r;
	int perm = PTE_U | PTE_P;
	envid_t curenvid = sys_getenvid();

	// LAB 4: Your code here.
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  8010b2:	a8 02                	test   $0x2,%al
  8010b4:	75 1d                	jne    8010d3 <fork+0xc5>
  8010b6:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  8010bd:	25 00 08 00 00       	and    $0x800,%eax
		perm |= PTE_COW ;
  8010c2:	83 f8 01             	cmp    $0x1,%eax
  8010c5:	19 f6                	sbb    %esi,%esi
  8010c7:	81 e6 00 f8 ff ff    	and    $0xfffff800,%esi
  8010cd:	81 c6 05 08 00 00    	add    $0x805,%esi

	if (uvpt[pn] & PTE_SHARE)
  8010d3:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  8010da:	25 00 04 00 00       	and    $0x400,%eax
		perm |= PTE_SYSCALL;
  8010df:	b8 07 0e 00 00       	mov    $0xe07,%eax
  8010e4:	0f 45 f0             	cmovne %eax,%esi

	r = sys_page_map(curenvid, (void *)(pn * PGSIZE),
  8010e7:	89 d8                	mov    %ebx,%eax
  8010e9:	c1 e0 0c             	shl    $0xc,%eax
  8010ec:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8010ef:	83 ec 0c             	sub    $0xc,%esp
  8010f2:	56                   	push   %esi
  8010f3:	50                   	push   %eax
  8010f4:	ff 75 dc             	pushl  -0x24(%ebp)
  8010f7:	50                   	push   %eax
  8010f8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010fb:	e8 bb fc ff ff       	call   800dbb <sys_page_map>
				envid, (void *)(pn * PGSIZE), perm);
	if (r < 0)
  801100:	83 c4 20             	add    $0x20,%esp
  801103:	85 c0                	test   %eax,%eax
  801105:	79 12                	jns    801119 <fork+0x10b>
		panic("duppage error: %e", r);
  801107:	50                   	push   %eax
  801108:	68 4b 27 80 00       	push   $0x80274b
  80110d:	6a 4d                	push   $0x4d
  80110f:	68 31 27 80 00       	push   $0x802731
  801114:	e8 7f f1 ff ff       	call   800298 <_panic>
	
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))	{
  801119:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801120:	a8 02                	test   $0x2,%al
  801122:	75 0c                	jne    801130 <fork+0x122>
  801124:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80112b:	f6 c4 08             	test   $0x8,%ah
  80112e:	74 2c                	je     80115c <fork+0x14e>
		r = sys_page_map(curenvid, (void *)(pn * PGSIZE),
  801130:	83 ec 0c             	sub    $0xc,%esp
  801133:	56                   	push   %esi
  801134:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801137:	52                   	push   %edx
  801138:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80113b:	50                   	push   %eax
  80113c:	52                   	push   %edx
  80113d:	50                   	push   %eax
  80113e:	e8 78 fc ff ff       	call   800dbb <sys_page_map>
						curenvid, (void *)(pn * PGSIZE), perm);
		if (r < 0)
  801143:	83 c4 20             	add    $0x20,%esp
  801146:	85 c0                	test   %eax,%eax
  801148:	79 12                	jns    80115c <fork+0x14e>
			panic("duppage error: %e", r);
  80114a:	50                   	push   %eax
  80114b:	68 4b 27 80 00       	push   $0x80274b
  801150:	6a 53                	push   $0x53
  801152:	68 31 27 80 00       	push   $0x802731
  801157:	e8 3c f1 ff ff       	call   800298 <_panic>
	    panic("fork error: %e", new_envid);
	else if (new_envid == 0)
		thisenv = envs + ENVX(sys_getenvid());
	else {

		for (uint32_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
  80115c:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801162:	81 ff 00 e0 bf ee    	cmp    $0xeebfe000,%edi
  801168:	0f 85 08 ff ff ff    	jne    801076 <fork+0x68>
			if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
				duppage(new_envid, PGNUM(addr));
		}

		sys_page_alloc(new_envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  80116e:	83 ec 04             	sub    $0x4,%esp
  801171:	6a 07                	push   $0x7
  801173:	68 00 f0 bf ee       	push   $0xeebff000
  801178:	8b 75 d8             	mov    -0x28(%ebp),%esi
  80117b:	56                   	push   %esi
  80117c:	e8 f7 fb ff ff       	call   800d78 <sys_page_alloc>
		sys_env_set_pgfault_upcall(new_envid, _pgfault_upcall);
  801181:	83 c4 08             	add    $0x8,%esp
  801184:	68 f1 1e 80 00       	push   $0x801ef1
  801189:	56                   	push   %esi
  80118a:	e8 34 fd ff ff       	call   800ec3 <sys_env_set_pgfault_upcall>
		sys_env_set_status(new_envid, ENV_RUNNABLE);
  80118f:	83 c4 08             	add    $0x8,%esp
  801192:	6a 02                	push   $0x2
  801194:	56                   	push   %esi
  801195:	e8 a5 fc ff ff       	call   800e3f <sys_env_set_status>
  80119a:	83 c4 10             	add    $0x10,%esp

	}
	return new_envid;
}
  80119d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8011a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a3:	5b                   	pop    %ebx
  8011a4:	5e                   	pop    %esi
  8011a5:	5f                   	pop    %edi
  8011a6:	5d                   	pop    %ebp
  8011a7:	c3                   	ret    

008011a8 <sfork>:

// Challenge!
int
sfork(void)
{
  8011a8:	55                   	push   %ebp
  8011a9:	89 e5                	mov    %esp,%ebp
  8011ab:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011ae:	68 5d 27 80 00       	push   $0x80275d
  8011b3:	68 8b 00 00 00       	push   $0x8b
  8011b8:	68 31 27 80 00       	push   $0x802731
  8011bd:	e8 d6 f0 ff ff       	call   800298 <_panic>

008011c2 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011c2:	55                   	push   %ebp
  8011c3:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c8:	05 00 00 00 30       	add    $0x30000000,%eax
  8011cd:	c1 e8 0c             	shr    $0xc,%eax
}
  8011d0:	5d                   	pop    %ebp
  8011d1:	c3                   	ret    

008011d2 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011d2:	55                   	push   %ebp
  8011d3:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d8:	05 00 00 00 30       	add    $0x30000000,%eax
  8011dd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011e2:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011e7:	5d                   	pop    %ebp
  8011e8:	c3                   	ret    

008011e9 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011e9:	55                   	push   %ebp
  8011ea:	89 e5                	mov    %esp,%ebp
  8011ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011ef:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011f4:	89 c2                	mov    %eax,%edx
  8011f6:	c1 ea 16             	shr    $0x16,%edx
  8011f9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801200:	f6 c2 01             	test   $0x1,%dl
  801203:	74 11                	je     801216 <fd_alloc+0x2d>
  801205:	89 c2                	mov    %eax,%edx
  801207:	c1 ea 0c             	shr    $0xc,%edx
  80120a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801211:	f6 c2 01             	test   $0x1,%dl
  801214:	75 09                	jne    80121f <fd_alloc+0x36>
			*fd_store = fd;
  801216:	89 01                	mov    %eax,(%ecx)
			return 0;
  801218:	b8 00 00 00 00       	mov    $0x0,%eax
  80121d:	eb 17                	jmp    801236 <fd_alloc+0x4d>
  80121f:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801224:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801229:	75 c9                	jne    8011f4 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80122b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801231:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801236:	5d                   	pop    %ebp
  801237:	c3                   	ret    

00801238 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801238:	55                   	push   %ebp
  801239:	89 e5                	mov    %esp,%ebp
  80123b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80123e:	83 f8 1f             	cmp    $0x1f,%eax
  801241:	77 36                	ja     801279 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801243:	c1 e0 0c             	shl    $0xc,%eax
  801246:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80124b:	89 c2                	mov    %eax,%edx
  80124d:	c1 ea 16             	shr    $0x16,%edx
  801250:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801257:	f6 c2 01             	test   $0x1,%dl
  80125a:	74 24                	je     801280 <fd_lookup+0x48>
  80125c:	89 c2                	mov    %eax,%edx
  80125e:	c1 ea 0c             	shr    $0xc,%edx
  801261:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801268:	f6 c2 01             	test   $0x1,%dl
  80126b:	74 1a                	je     801287 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80126d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801270:	89 02                	mov    %eax,(%edx)
	return 0;
  801272:	b8 00 00 00 00       	mov    $0x0,%eax
  801277:	eb 13                	jmp    80128c <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801279:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80127e:	eb 0c                	jmp    80128c <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801280:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801285:	eb 05                	jmp    80128c <fd_lookup+0x54>
  801287:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80128c:	5d                   	pop    %ebp
  80128d:	c3                   	ret    

0080128e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80128e:	55                   	push   %ebp
  80128f:	89 e5                	mov    %esp,%ebp
  801291:	83 ec 08             	sub    $0x8,%esp
  801294:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801297:	ba f4 27 80 00       	mov    $0x8027f4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80129c:	eb 13                	jmp    8012b1 <dev_lookup+0x23>
  80129e:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012a1:	39 08                	cmp    %ecx,(%eax)
  8012a3:	75 0c                	jne    8012b1 <dev_lookup+0x23>
			*dev = devtab[i];
  8012a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012a8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8012af:	eb 2e                	jmp    8012df <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012b1:	8b 02                	mov    (%edx),%eax
  8012b3:	85 c0                	test   %eax,%eax
  8012b5:	75 e7                	jne    80129e <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012b7:	a1 04 40 80 00       	mov    0x804004,%eax
  8012bc:	8b 40 48             	mov    0x48(%eax),%eax
  8012bf:	83 ec 04             	sub    $0x4,%esp
  8012c2:	51                   	push   %ecx
  8012c3:	50                   	push   %eax
  8012c4:	68 74 27 80 00       	push   $0x802774
  8012c9:	e8 a3 f0 ff ff       	call   800371 <cprintf>
	*dev = 0;
  8012ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012d1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012d7:	83 c4 10             	add    $0x10,%esp
  8012da:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012df:	c9                   	leave  
  8012e0:	c3                   	ret    

008012e1 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012e1:	55                   	push   %ebp
  8012e2:	89 e5                	mov    %esp,%ebp
  8012e4:	56                   	push   %esi
  8012e5:	53                   	push   %ebx
  8012e6:	83 ec 10             	sub    $0x10,%esp
  8012e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8012ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f2:	50                   	push   %eax
  8012f3:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012f9:	c1 e8 0c             	shr    $0xc,%eax
  8012fc:	50                   	push   %eax
  8012fd:	e8 36 ff ff ff       	call   801238 <fd_lookup>
  801302:	83 c4 08             	add    $0x8,%esp
  801305:	85 c0                	test   %eax,%eax
  801307:	78 05                	js     80130e <fd_close+0x2d>
	    || fd != fd2)
  801309:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80130c:	74 0c                	je     80131a <fd_close+0x39>
		return (must_exist ? r : 0);
  80130e:	84 db                	test   %bl,%bl
  801310:	ba 00 00 00 00       	mov    $0x0,%edx
  801315:	0f 44 c2             	cmove  %edx,%eax
  801318:	eb 41                	jmp    80135b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80131a:	83 ec 08             	sub    $0x8,%esp
  80131d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801320:	50                   	push   %eax
  801321:	ff 36                	pushl  (%esi)
  801323:	e8 66 ff ff ff       	call   80128e <dev_lookup>
  801328:	89 c3                	mov    %eax,%ebx
  80132a:	83 c4 10             	add    $0x10,%esp
  80132d:	85 c0                	test   %eax,%eax
  80132f:	78 1a                	js     80134b <fd_close+0x6a>
		if (dev->dev_close)
  801331:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801334:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801337:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80133c:	85 c0                	test   %eax,%eax
  80133e:	74 0b                	je     80134b <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801340:	83 ec 0c             	sub    $0xc,%esp
  801343:	56                   	push   %esi
  801344:	ff d0                	call   *%eax
  801346:	89 c3                	mov    %eax,%ebx
  801348:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80134b:	83 ec 08             	sub    $0x8,%esp
  80134e:	56                   	push   %esi
  80134f:	6a 00                	push   $0x0
  801351:	e8 a7 fa ff ff       	call   800dfd <sys_page_unmap>
	return r;
  801356:	83 c4 10             	add    $0x10,%esp
  801359:	89 d8                	mov    %ebx,%eax
}
  80135b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80135e:	5b                   	pop    %ebx
  80135f:	5e                   	pop    %esi
  801360:	5d                   	pop    %ebp
  801361:	c3                   	ret    

00801362 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801362:	55                   	push   %ebp
  801363:	89 e5                	mov    %esp,%ebp
  801365:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801368:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80136b:	50                   	push   %eax
  80136c:	ff 75 08             	pushl  0x8(%ebp)
  80136f:	e8 c4 fe ff ff       	call   801238 <fd_lookup>
  801374:	83 c4 08             	add    $0x8,%esp
  801377:	85 c0                	test   %eax,%eax
  801379:	78 10                	js     80138b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80137b:	83 ec 08             	sub    $0x8,%esp
  80137e:	6a 01                	push   $0x1
  801380:	ff 75 f4             	pushl  -0xc(%ebp)
  801383:	e8 59 ff ff ff       	call   8012e1 <fd_close>
  801388:	83 c4 10             	add    $0x10,%esp
}
  80138b:	c9                   	leave  
  80138c:	c3                   	ret    

0080138d <close_all>:

void
close_all(void)
{
  80138d:	55                   	push   %ebp
  80138e:	89 e5                	mov    %esp,%ebp
  801390:	53                   	push   %ebx
  801391:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801394:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801399:	83 ec 0c             	sub    $0xc,%esp
  80139c:	53                   	push   %ebx
  80139d:	e8 c0 ff ff ff       	call   801362 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013a2:	83 c3 01             	add    $0x1,%ebx
  8013a5:	83 c4 10             	add    $0x10,%esp
  8013a8:	83 fb 20             	cmp    $0x20,%ebx
  8013ab:	75 ec                	jne    801399 <close_all+0xc>
		close(i);
}
  8013ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013b0:	c9                   	leave  
  8013b1:	c3                   	ret    

008013b2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013b2:	55                   	push   %ebp
  8013b3:	89 e5                	mov    %esp,%ebp
  8013b5:	57                   	push   %edi
  8013b6:	56                   	push   %esi
  8013b7:	53                   	push   %ebx
  8013b8:	83 ec 2c             	sub    $0x2c,%esp
  8013bb:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013be:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013c1:	50                   	push   %eax
  8013c2:	ff 75 08             	pushl  0x8(%ebp)
  8013c5:	e8 6e fe ff ff       	call   801238 <fd_lookup>
  8013ca:	83 c4 08             	add    $0x8,%esp
  8013cd:	85 c0                	test   %eax,%eax
  8013cf:	0f 88 c1 00 00 00    	js     801496 <dup+0xe4>
		return r;
	close(newfdnum);
  8013d5:	83 ec 0c             	sub    $0xc,%esp
  8013d8:	56                   	push   %esi
  8013d9:	e8 84 ff ff ff       	call   801362 <close>

	newfd = INDEX2FD(newfdnum);
  8013de:	89 f3                	mov    %esi,%ebx
  8013e0:	c1 e3 0c             	shl    $0xc,%ebx
  8013e3:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013e9:	83 c4 04             	add    $0x4,%esp
  8013ec:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013ef:	e8 de fd ff ff       	call   8011d2 <fd2data>
  8013f4:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013f6:	89 1c 24             	mov    %ebx,(%esp)
  8013f9:	e8 d4 fd ff ff       	call   8011d2 <fd2data>
  8013fe:	83 c4 10             	add    $0x10,%esp
  801401:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801404:	89 f8                	mov    %edi,%eax
  801406:	c1 e8 16             	shr    $0x16,%eax
  801409:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801410:	a8 01                	test   $0x1,%al
  801412:	74 37                	je     80144b <dup+0x99>
  801414:	89 f8                	mov    %edi,%eax
  801416:	c1 e8 0c             	shr    $0xc,%eax
  801419:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801420:	f6 c2 01             	test   $0x1,%dl
  801423:	74 26                	je     80144b <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801425:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80142c:	83 ec 0c             	sub    $0xc,%esp
  80142f:	25 07 0e 00 00       	and    $0xe07,%eax
  801434:	50                   	push   %eax
  801435:	ff 75 d4             	pushl  -0x2c(%ebp)
  801438:	6a 00                	push   $0x0
  80143a:	57                   	push   %edi
  80143b:	6a 00                	push   $0x0
  80143d:	e8 79 f9 ff ff       	call   800dbb <sys_page_map>
  801442:	89 c7                	mov    %eax,%edi
  801444:	83 c4 20             	add    $0x20,%esp
  801447:	85 c0                	test   %eax,%eax
  801449:	78 2e                	js     801479 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80144b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80144e:	89 d0                	mov    %edx,%eax
  801450:	c1 e8 0c             	shr    $0xc,%eax
  801453:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80145a:	83 ec 0c             	sub    $0xc,%esp
  80145d:	25 07 0e 00 00       	and    $0xe07,%eax
  801462:	50                   	push   %eax
  801463:	53                   	push   %ebx
  801464:	6a 00                	push   $0x0
  801466:	52                   	push   %edx
  801467:	6a 00                	push   $0x0
  801469:	e8 4d f9 ff ff       	call   800dbb <sys_page_map>
  80146e:	89 c7                	mov    %eax,%edi
  801470:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801473:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801475:	85 ff                	test   %edi,%edi
  801477:	79 1d                	jns    801496 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801479:	83 ec 08             	sub    $0x8,%esp
  80147c:	53                   	push   %ebx
  80147d:	6a 00                	push   $0x0
  80147f:	e8 79 f9 ff ff       	call   800dfd <sys_page_unmap>
	sys_page_unmap(0, nva);
  801484:	83 c4 08             	add    $0x8,%esp
  801487:	ff 75 d4             	pushl  -0x2c(%ebp)
  80148a:	6a 00                	push   $0x0
  80148c:	e8 6c f9 ff ff       	call   800dfd <sys_page_unmap>
	return r;
  801491:	83 c4 10             	add    $0x10,%esp
  801494:	89 f8                	mov    %edi,%eax
}
  801496:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801499:	5b                   	pop    %ebx
  80149a:	5e                   	pop    %esi
  80149b:	5f                   	pop    %edi
  80149c:	5d                   	pop    %ebp
  80149d:	c3                   	ret    

0080149e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80149e:	55                   	push   %ebp
  80149f:	89 e5                	mov    %esp,%ebp
  8014a1:	53                   	push   %ebx
  8014a2:	83 ec 14             	sub    $0x14,%esp
  8014a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014a8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014ab:	50                   	push   %eax
  8014ac:	53                   	push   %ebx
  8014ad:	e8 86 fd ff ff       	call   801238 <fd_lookup>
  8014b2:	83 c4 08             	add    $0x8,%esp
  8014b5:	89 c2                	mov    %eax,%edx
  8014b7:	85 c0                	test   %eax,%eax
  8014b9:	78 6d                	js     801528 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014bb:	83 ec 08             	sub    $0x8,%esp
  8014be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c1:	50                   	push   %eax
  8014c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c5:	ff 30                	pushl  (%eax)
  8014c7:	e8 c2 fd ff ff       	call   80128e <dev_lookup>
  8014cc:	83 c4 10             	add    $0x10,%esp
  8014cf:	85 c0                	test   %eax,%eax
  8014d1:	78 4c                	js     80151f <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014d3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014d6:	8b 42 08             	mov    0x8(%edx),%eax
  8014d9:	83 e0 03             	and    $0x3,%eax
  8014dc:	83 f8 01             	cmp    $0x1,%eax
  8014df:	75 21                	jne    801502 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014e1:	a1 04 40 80 00       	mov    0x804004,%eax
  8014e6:	8b 40 48             	mov    0x48(%eax),%eax
  8014e9:	83 ec 04             	sub    $0x4,%esp
  8014ec:	53                   	push   %ebx
  8014ed:	50                   	push   %eax
  8014ee:	68 b8 27 80 00       	push   $0x8027b8
  8014f3:	e8 79 ee ff ff       	call   800371 <cprintf>
		return -E_INVAL;
  8014f8:	83 c4 10             	add    $0x10,%esp
  8014fb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801500:	eb 26                	jmp    801528 <read+0x8a>
	}
	if (!dev->dev_read)
  801502:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801505:	8b 40 08             	mov    0x8(%eax),%eax
  801508:	85 c0                	test   %eax,%eax
  80150a:	74 17                	je     801523 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80150c:	83 ec 04             	sub    $0x4,%esp
  80150f:	ff 75 10             	pushl  0x10(%ebp)
  801512:	ff 75 0c             	pushl  0xc(%ebp)
  801515:	52                   	push   %edx
  801516:	ff d0                	call   *%eax
  801518:	89 c2                	mov    %eax,%edx
  80151a:	83 c4 10             	add    $0x10,%esp
  80151d:	eb 09                	jmp    801528 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80151f:	89 c2                	mov    %eax,%edx
  801521:	eb 05                	jmp    801528 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801523:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801528:	89 d0                	mov    %edx,%eax
  80152a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80152d:	c9                   	leave  
  80152e:	c3                   	ret    

0080152f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80152f:	55                   	push   %ebp
  801530:	89 e5                	mov    %esp,%ebp
  801532:	57                   	push   %edi
  801533:	56                   	push   %esi
  801534:	53                   	push   %ebx
  801535:	83 ec 0c             	sub    $0xc,%esp
  801538:	8b 7d 08             	mov    0x8(%ebp),%edi
  80153b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80153e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801543:	eb 21                	jmp    801566 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801545:	83 ec 04             	sub    $0x4,%esp
  801548:	89 f0                	mov    %esi,%eax
  80154a:	29 d8                	sub    %ebx,%eax
  80154c:	50                   	push   %eax
  80154d:	89 d8                	mov    %ebx,%eax
  80154f:	03 45 0c             	add    0xc(%ebp),%eax
  801552:	50                   	push   %eax
  801553:	57                   	push   %edi
  801554:	e8 45 ff ff ff       	call   80149e <read>
		if (m < 0)
  801559:	83 c4 10             	add    $0x10,%esp
  80155c:	85 c0                	test   %eax,%eax
  80155e:	78 10                	js     801570 <readn+0x41>
			return m;
		if (m == 0)
  801560:	85 c0                	test   %eax,%eax
  801562:	74 0a                	je     80156e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801564:	01 c3                	add    %eax,%ebx
  801566:	39 f3                	cmp    %esi,%ebx
  801568:	72 db                	jb     801545 <readn+0x16>
  80156a:	89 d8                	mov    %ebx,%eax
  80156c:	eb 02                	jmp    801570 <readn+0x41>
  80156e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801570:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801573:	5b                   	pop    %ebx
  801574:	5e                   	pop    %esi
  801575:	5f                   	pop    %edi
  801576:	5d                   	pop    %ebp
  801577:	c3                   	ret    

00801578 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801578:	55                   	push   %ebp
  801579:	89 e5                	mov    %esp,%ebp
  80157b:	53                   	push   %ebx
  80157c:	83 ec 14             	sub    $0x14,%esp
  80157f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801582:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801585:	50                   	push   %eax
  801586:	53                   	push   %ebx
  801587:	e8 ac fc ff ff       	call   801238 <fd_lookup>
  80158c:	83 c4 08             	add    $0x8,%esp
  80158f:	89 c2                	mov    %eax,%edx
  801591:	85 c0                	test   %eax,%eax
  801593:	78 68                	js     8015fd <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801595:	83 ec 08             	sub    $0x8,%esp
  801598:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80159b:	50                   	push   %eax
  80159c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80159f:	ff 30                	pushl  (%eax)
  8015a1:	e8 e8 fc ff ff       	call   80128e <dev_lookup>
  8015a6:	83 c4 10             	add    $0x10,%esp
  8015a9:	85 c0                	test   %eax,%eax
  8015ab:	78 47                	js     8015f4 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015b4:	75 21                	jne    8015d7 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015b6:	a1 04 40 80 00       	mov    0x804004,%eax
  8015bb:	8b 40 48             	mov    0x48(%eax),%eax
  8015be:	83 ec 04             	sub    $0x4,%esp
  8015c1:	53                   	push   %ebx
  8015c2:	50                   	push   %eax
  8015c3:	68 d4 27 80 00       	push   $0x8027d4
  8015c8:	e8 a4 ed ff ff       	call   800371 <cprintf>
		return -E_INVAL;
  8015cd:	83 c4 10             	add    $0x10,%esp
  8015d0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015d5:	eb 26                	jmp    8015fd <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015d7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015da:	8b 52 0c             	mov    0xc(%edx),%edx
  8015dd:	85 d2                	test   %edx,%edx
  8015df:	74 17                	je     8015f8 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015e1:	83 ec 04             	sub    $0x4,%esp
  8015e4:	ff 75 10             	pushl  0x10(%ebp)
  8015e7:	ff 75 0c             	pushl  0xc(%ebp)
  8015ea:	50                   	push   %eax
  8015eb:	ff d2                	call   *%edx
  8015ed:	89 c2                	mov    %eax,%edx
  8015ef:	83 c4 10             	add    $0x10,%esp
  8015f2:	eb 09                	jmp    8015fd <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f4:	89 c2                	mov    %eax,%edx
  8015f6:	eb 05                	jmp    8015fd <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015f8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015fd:	89 d0                	mov    %edx,%eax
  8015ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801602:	c9                   	leave  
  801603:	c3                   	ret    

00801604 <seek>:

int
seek(int fdnum, off_t offset)
{
  801604:	55                   	push   %ebp
  801605:	89 e5                	mov    %esp,%ebp
  801607:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80160a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80160d:	50                   	push   %eax
  80160e:	ff 75 08             	pushl  0x8(%ebp)
  801611:	e8 22 fc ff ff       	call   801238 <fd_lookup>
  801616:	83 c4 08             	add    $0x8,%esp
  801619:	85 c0                	test   %eax,%eax
  80161b:	78 0e                	js     80162b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80161d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801620:	8b 55 0c             	mov    0xc(%ebp),%edx
  801623:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801626:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80162b:	c9                   	leave  
  80162c:	c3                   	ret    

0080162d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80162d:	55                   	push   %ebp
  80162e:	89 e5                	mov    %esp,%ebp
  801630:	53                   	push   %ebx
  801631:	83 ec 14             	sub    $0x14,%esp
  801634:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801637:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80163a:	50                   	push   %eax
  80163b:	53                   	push   %ebx
  80163c:	e8 f7 fb ff ff       	call   801238 <fd_lookup>
  801641:	83 c4 08             	add    $0x8,%esp
  801644:	89 c2                	mov    %eax,%edx
  801646:	85 c0                	test   %eax,%eax
  801648:	78 65                	js     8016af <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80164a:	83 ec 08             	sub    $0x8,%esp
  80164d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801650:	50                   	push   %eax
  801651:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801654:	ff 30                	pushl  (%eax)
  801656:	e8 33 fc ff ff       	call   80128e <dev_lookup>
  80165b:	83 c4 10             	add    $0x10,%esp
  80165e:	85 c0                	test   %eax,%eax
  801660:	78 44                	js     8016a6 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801662:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801665:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801669:	75 21                	jne    80168c <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80166b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801670:	8b 40 48             	mov    0x48(%eax),%eax
  801673:	83 ec 04             	sub    $0x4,%esp
  801676:	53                   	push   %ebx
  801677:	50                   	push   %eax
  801678:	68 94 27 80 00       	push   $0x802794
  80167d:	e8 ef ec ff ff       	call   800371 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801682:	83 c4 10             	add    $0x10,%esp
  801685:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80168a:	eb 23                	jmp    8016af <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80168c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80168f:	8b 52 18             	mov    0x18(%edx),%edx
  801692:	85 d2                	test   %edx,%edx
  801694:	74 14                	je     8016aa <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801696:	83 ec 08             	sub    $0x8,%esp
  801699:	ff 75 0c             	pushl  0xc(%ebp)
  80169c:	50                   	push   %eax
  80169d:	ff d2                	call   *%edx
  80169f:	89 c2                	mov    %eax,%edx
  8016a1:	83 c4 10             	add    $0x10,%esp
  8016a4:	eb 09                	jmp    8016af <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a6:	89 c2                	mov    %eax,%edx
  8016a8:	eb 05                	jmp    8016af <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016aa:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016af:	89 d0                	mov    %edx,%eax
  8016b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016b4:	c9                   	leave  
  8016b5:	c3                   	ret    

008016b6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016b6:	55                   	push   %ebp
  8016b7:	89 e5                	mov    %esp,%ebp
  8016b9:	53                   	push   %ebx
  8016ba:	83 ec 14             	sub    $0x14,%esp
  8016bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016c0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016c3:	50                   	push   %eax
  8016c4:	ff 75 08             	pushl  0x8(%ebp)
  8016c7:	e8 6c fb ff ff       	call   801238 <fd_lookup>
  8016cc:	83 c4 08             	add    $0x8,%esp
  8016cf:	89 c2                	mov    %eax,%edx
  8016d1:	85 c0                	test   %eax,%eax
  8016d3:	78 58                	js     80172d <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d5:	83 ec 08             	sub    $0x8,%esp
  8016d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016db:	50                   	push   %eax
  8016dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016df:	ff 30                	pushl  (%eax)
  8016e1:	e8 a8 fb ff ff       	call   80128e <dev_lookup>
  8016e6:	83 c4 10             	add    $0x10,%esp
  8016e9:	85 c0                	test   %eax,%eax
  8016eb:	78 37                	js     801724 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016f0:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016f4:	74 32                	je     801728 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016f6:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016f9:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801700:	00 00 00 
	stat->st_isdir = 0;
  801703:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80170a:	00 00 00 
	stat->st_dev = dev;
  80170d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801713:	83 ec 08             	sub    $0x8,%esp
  801716:	53                   	push   %ebx
  801717:	ff 75 f0             	pushl  -0x10(%ebp)
  80171a:	ff 50 14             	call   *0x14(%eax)
  80171d:	89 c2                	mov    %eax,%edx
  80171f:	83 c4 10             	add    $0x10,%esp
  801722:	eb 09                	jmp    80172d <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801724:	89 c2                	mov    %eax,%edx
  801726:	eb 05                	jmp    80172d <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801728:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80172d:	89 d0                	mov    %edx,%eax
  80172f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801732:	c9                   	leave  
  801733:	c3                   	ret    

00801734 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801734:	55                   	push   %ebp
  801735:	89 e5                	mov    %esp,%ebp
  801737:	56                   	push   %esi
  801738:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801739:	83 ec 08             	sub    $0x8,%esp
  80173c:	6a 00                	push   $0x0
  80173e:	ff 75 08             	pushl  0x8(%ebp)
  801741:	e8 e3 01 00 00       	call   801929 <open>
  801746:	89 c3                	mov    %eax,%ebx
  801748:	83 c4 10             	add    $0x10,%esp
  80174b:	85 c0                	test   %eax,%eax
  80174d:	78 1b                	js     80176a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80174f:	83 ec 08             	sub    $0x8,%esp
  801752:	ff 75 0c             	pushl  0xc(%ebp)
  801755:	50                   	push   %eax
  801756:	e8 5b ff ff ff       	call   8016b6 <fstat>
  80175b:	89 c6                	mov    %eax,%esi
	close(fd);
  80175d:	89 1c 24             	mov    %ebx,(%esp)
  801760:	e8 fd fb ff ff       	call   801362 <close>
	return r;
  801765:	83 c4 10             	add    $0x10,%esp
  801768:	89 f0                	mov    %esi,%eax
}
  80176a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80176d:	5b                   	pop    %ebx
  80176e:	5e                   	pop    %esi
  80176f:	5d                   	pop    %ebp
  801770:	c3                   	ret    

00801771 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801771:	55                   	push   %ebp
  801772:	89 e5                	mov    %esp,%ebp
  801774:	56                   	push   %esi
  801775:	53                   	push   %ebx
  801776:	89 c6                	mov    %eax,%esi
  801778:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80177a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801781:	75 12                	jne    801795 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801783:	83 ec 0c             	sub    $0xc,%esp
  801786:	6a 01                	push   $0x1
  801788:	e8 50 08 00 00       	call   801fdd <ipc_find_env>
  80178d:	a3 00 40 80 00       	mov    %eax,0x804000
  801792:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801795:	6a 07                	push   $0x7
  801797:	68 00 50 80 00       	push   $0x805000
  80179c:	56                   	push   %esi
  80179d:	ff 35 00 40 80 00    	pushl  0x804000
  8017a3:	e8 e1 07 00 00       	call   801f89 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017a8:	83 c4 0c             	add    $0xc,%esp
  8017ab:	6a 00                	push   $0x0
  8017ad:	53                   	push   %ebx
  8017ae:	6a 00                	push   $0x0
  8017b0:	e8 62 07 00 00       	call   801f17 <ipc_recv>
}
  8017b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017b8:	5b                   	pop    %ebx
  8017b9:	5e                   	pop    %esi
  8017ba:	5d                   	pop    %ebp
  8017bb:	c3                   	ret    

008017bc <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017bc:	55                   	push   %ebp
  8017bd:	89 e5                	mov    %esp,%ebp
  8017bf:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c5:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017d0:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8017da:	b8 02 00 00 00       	mov    $0x2,%eax
  8017df:	e8 8d ff ff ff       	call   801771 <fsipc>
}
  8017e4:	c9                   	leave  
  8017e5:	c3                   	ret    

008017e6 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017e6:	55                   	push   %ebp
  8017e7:	89 e5                	mov    %esp,%ebp
  8017e9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ef:	8b 40 0c             	mov    0xc(%eax),%eax
  8017f2:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8017fc:	b8 06 00 00 00       	mov    $0x6,%eax
  801801:	e8 6b ff ff ff       	call   801771 <fsipc>
}
  801806:	c9                   	leave  
  801807:	c3                   	ret    

00801808 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801808:	55                   	push   %ebp
  801809:	89 e5                	mov    %esp,%ebp
  80180b:	53                   	push   %ebx
  80180c:	83 ec 04             	sub    $0x4,%esp
  80180f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801812:	8b 45 08             	mov    0x8(%ebp),%eax
  801815:	8b 40 0c             	mov    0xc(%eax),%eax
  801818:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80181d:	ba 00 00 00 00       	mov    $0x0,%edx
  801822:	b8 05 00 00 00       	mov    $0x5,%eax
  801827:	e8 45 ff ff ff       	call   801771 <fsipc>
  80182c:	85 c0                	test   %eax,%eax
  80182e:	78 2c                	js     80185c <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801830:	83 ec 08             	sub    $0x8,%esp
  801833:	68 00 50 80 00       	push   $0x805000
  801838:	53                   	push   %ebx
  801839:	e8 37 f1 ff ff       	call   800975 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80183e:	a1 80 50 80 00       	mov    0x805080,%eax
  801843:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801849:	a1 84 50 80 00       	mov    0x805084,%eax
  80184e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801854:	83 c4 10             	add    $0x10,%esp
  801857:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80185c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80185f:	c9                   	leave  
  801860:	c3                   	ret    

00801861 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801861:	55                   	push   %ebp
  801862:	89 e5                	mov    %esp,%ebp
  801864:	83 ec 0c             	sub    $0xc,%esp
  801867:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	
	int r;

	n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  80186a:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80186f:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801874:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801877:	8b 55 08             	mov    0x8(%ebp),%edx
  80187a:	8b 52 0c             	mov    0xc(%edx),%edx
  80187d:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801883:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801888:	50                   	push   %eax
  801889:	ff 75 0c             	pushl  0xc(%ebp)
  80188c:	68 08 50 80 00       	push   $0x805008
  801891:	e8 71 f2 ff ff       	call   800b07 <memmove>
	
	return fsipc(FSREQ_WRITE, NULL);	
  801896:	ba 00 00 00 00       	mov    $0x0,%edx
  80189b:	b8 04 00 00 00       	mov    $0x4,%eax
  8018a0:	e8 cc fe ff ff       	call   801771 <fsipc>
}
  8018a5:	c9                   	leave  
  8018a6:	c3                   	ret    

008018a7 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018a7:	55                   	push   %ebp
  8018a8:	89 e5                	mov    %esp,%ebp
  8018aa:	56                   	push   %esi
  8018ab:	53                   	push   %ebx
  8018ac:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018af:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b2:	8b 40 0c             	mov    0xc(%eax),%eax
  8018b5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018ba:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c5:	b8 03 00 00 00       	mov    $0x3,%eax
  8018ca:	e8 a2 fe ff ff       	call   801771 <fsipc>
  8018cf:	89 c3                	mov    %eax,%ebx
  8018d1:	85 c0                	test   %eax,%eax
  8018d3:	78 4b                	js     801920 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018d5:	39 c6                	cmp    %eax,%esi
  8018d7:	73 16                	jae    8018ef <devfile_read+0x48>
  8018d9:	68 04 28 80 00       	push   $0x802804
  8018de:	68 0b 28 80 00       	push   $0x80280b
  8018e3:	6a 7c                	push   $0x7c
  8018e5:	68 20 28 80 00       	push   $0x802820
  8018ea:	e8 a9 e9 ff ff       	call   800298 <_panic>
	assert(r <= PGSIZE);
  8018ef:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018f4:	7e 16                	jle    80190c <devfile_read+0x65>
  8018f6:	68 2b 28 80 00       	push   $0x80282b
  8018fb:	68 0b 28 80 00       	push   $0x80280b
  801900:	6a 7d                	push   $0x7d
  801902:	68 20 28 80 00       	push   $0x802820
  801907:	e8 8c e9 ff ff       	call   800298 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80190c:	83 ec 04             	sub    $0x4,%esp
  80190f:	50                   	push   %eax
  801910:	68 00 50 80 00       	push   $0x805000
  801915:	ff 75 0c             	pushl  0xc(%ebp)
  801918:	e8 ea f1 ff ff       	call   800b07 <memmove>
	return r;
  80191d:	83 c4 10             	add    $0x10,%esp
}
  801920:	89 d8                	mov    %ebx,%eax
  801922:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801925:	5b                   	pop    %ebx
  801926:	5e                   	pop    %esi
  801927:	5d                   	pop    %ebp
  801928:	c3                   	ret    

00801929 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801929:	55                   	push   %ebp
  80192a:	89 e5                	mov    %esp,%ebp
  80192c:	53                   	push   %ebx
  80192d:	83 ec 20             	sub    $0x20,%esp
  801930:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801933:	53                   	push   %ebx
  801934:	e8 03 f0 ff ff       	call   80093c <strlen>
  801939:	83 c4 10             	add    $0x10,%esp
  80193c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801941:	7f 67                	jg     8019aa <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801943:	83 ec 0c             	sub    $0xc,%esp
  801946:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801949:	50                   	push   %eax
  80194a:	e8 9a f8 ff ff       	call   8011e9 <fd_alloc>
  80194f:	83 c4 10             	add    $0x10,%esp
		return r;
  801952:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801954:	85 c0                	test   %eax,%eax
  801956:	78 57                	js     8019af <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801958:	83 ec 08             	sub    $0x8,%esp
  80195b:	53                   	push   %ebx
  80195c:	68 00 50 80 00       	push   $0x805000
  801961:	e8 0f f0 ff ff       	call   800975 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801966:	8b 45 0c             	mov    0xc(%ebp),%eax
  801969:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80196e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801971:	b8 01 00 00 00       	mov    $0x1,%eax
  801976:	e8 f6 fd ff ff       	call   801771 <fsipc>
  80197b:	89 c3                	mov    %eax,%ebx
  80197d:	83 c4 10             	add    $0x10,%esp
  801980:	85 c0                	test   %eax,%eax
  801982:	79 14                	jns    801998 <open+0x6f>
		fd_close(fd, 0);
  801984:	83 ec 08             	sub    $0x8,%esp
  801987:	6a 00                	push   $0x0
  801989:	ff 75 f4             	pushl  -0xc(%ebp)
  80198c:	e8 50 f9 ff ff       	call   8012e1 <fd_close>
		return r;
  801991:	83 c4 10             	add    $0x10,%esp
  801994:	89 da                	mov    %ebx,%edx
  801996:	eb 17                	jmp    8019af <open+0x86>
	}

	return fd2num(fd);
  801998:	83 ec 0c             	sub    $0xc,%esp
  80199b:	ff 75 f4             	pushl  -0xc(%ebp)
  80199e:	e8 1f f8 ff ff       	call   8011c2 <fd2num>
  8019a3:	89 c2                	mov    %eax,%edx
  8019a5:	83 c4 10             	add    $0x10,%esp
  8019a8:	eb 05                	jmp    8019af <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019aa:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019af:	89 d0                	mov    %edx,%eax
  8019b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019b4:	c9                   	leave  
  8019b5:	c3                   	ret    

008019b6 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019b6:	55                   	push   %ebp
  8019b7:	89 e5                	mov    %esp,%ebp
  8019b9:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8019c1:	b8 08 00 00 00       	mov    $0x8,%eax
  8019c6:	e8 a6 fd ff ff       	call   801771 <fsipc>
}
  8019cb:	c9                   	leave  
  8019cc:	c3                   	ret    

008019cd <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019cd:	55                   	push   %ebp
  8019ce:	89 e5                	mov    %esp,%ebp
  8019d0:	56                   	push   %esi
  8019d1:	53                   	push   %ebx
  8019d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019d5:	83 ec 0c             	sub    $0xc,%esp
  8019d8:	ff 75 08             	pushl  0x8(%ebp)
  8019db:	e8 f2 f7 ff ff       	call   8011d2 <fd2data>
  8019e0:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019e2:	83 c4 08             	add    $0x8,%esp
  8019e5:	68 37 28 80 00       	push   $0x802837
  8019ea:	53                   	push   %ebx
  8019eb:	e8 85 ef ff ff       	call   800975 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019f0:	8b 46 04             	mov    0x4(%esi),%eax
  8019f3:	2b 06                	sub    (%esi),%eax
  8019f5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019fb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a02:	00 00 00 
	stat->st_dev = &devpipe;
  801a05:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a0c:	30 80 00 
	return 0;
}
  801a0f:	b8 00 00 00 00       	mov    $0x0,%eax
  801a14:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a17:	5b                   	pop    %ebx
  801a18:	5e                   	pop    %esi
  801a19:	5d                   	pop    %ebp
  801a1a:	c3                   	ret    

00801a1b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a1b:	55                   	push   %ebp
  801a1c:	89 e5                	mov    %esp,%ebp
  801a1e:	53                   	push   %ebx
  801a1f:	83 ec 0c             	sub    $0xc,%esp
  801a22:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a25:	53                   	push   %ebx
  801a26:	6a 00                	push   $0x0
  801a28:	e8 d0 f3 ff ff       	call   800dfd <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a2d:	89 1c 24             	mov    %ebx,(%esp)
  801a30:	e8 9d f7 ff ff       	call   8011d2 <fd2data>
  801a35:	83 c4 08             	add    $0x8,%esp
  801a38:	50                   	push   %eax
  801a39:	6a 00                	push   $0x0
  801a3b:	e8 bd f3 ff ff       	call   800dfd <sys_page_unmap>
}
  801a40:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a43:	c9                   	leave  
  801a44:	c3                   	ret    

00801a45 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a45:	55                   	push   %ebp
  801a46:	89 e5                	mov    %esp,%ebp
  801a48:	57                   	push   %edi
  801a49:	56                   	push   %esi
  801a4a:	53                   	push   %ebx
  801a4b:	83 ec 1c             	sub    $0x1c,%esp
  801a4e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a51:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a53:	a1 04 40 80 00       	mov    0x804004,%eax
  801a58:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a5b:	83 ec 0c             	sub    $0xc,%esp
  801a5e:	ff 75 e0             	pushl  -0x20(%ebp)
  801a61:	e8 b0 05 00 00       	call   802016 <pageref>
  801a66:	89 c3                	mov    %eax,%ebx
  801a68:	89 3c 24             	mov    %edi,(%esp)
  801a6b:	e8 a6 05 00 00       	call   802016 <pageref>
  801a70:	83 c4 10             	add    $0x10,%esp
  801a73:	39 c3                	cmp    %eax,%ebx
  801a75:	0f 94 c1             	sete   %cl
  801a78:	0f b6 c9             	movzbl %cl,%ecx
  801a7b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a7e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a84:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a87:	39 ce                	cmp    %ecx,%esi
  801a89:	74 1b                	je     801aa6 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a8b:	39 c3                	cmp    %eax,%ebx
  801a8d:	75 c4                	jne    801a53 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a8f:	8b 42 58             	mov    0x58(%edx),%eax
  801a92:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a95:	50                   	push   %eax
  801a96:	56                   	push   %esi
  801a97:	68 3e 28 80 00       	push   $0x80283e
  801a9c:	e8 d0 e8 ff ff       	call   800371 <cprintf>
  801aa1:	83 c4 10             	add    $0x10,%esp
  801aa4:	eb ad                	jmp    801a53 <_pipeisclosed+0xe>
	}
}
  801aa6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801aa9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aac:	5b                   	pop    %ebx
  801aad:	5e                   	pop    %esi
  801aae:	5f                   	pop    %edi
  801aaf:	5d                   	pop    %ebp
  801ab0:	c3                   	ret    

00801ab1 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ab1:	55                   	push   %ebp
  801ab2:	89 e5                	mov    %esp,%ebp
  801ab4:	57                   	push   %edi
  801ab5:	56                   	push   %esi
  801ab6:	53                   	push   %ebx
  801ab7:	83 ec 28             	sub    $0x28,%esp
  801aba:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801abd:	56                   	push   %esi
  801abe:	e8 0f f7 ff ff       	call   8011d2 <fd2data>
  801ac3:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ac5:	83 c4 10             	add    $0x10,%esp
  801ac8:	bf 00 00 00 00       	mov    $0x0,%edi
  801acd:	eb 4b                	jmp    801b1a <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801acf:	89 da                	mov    %ebx,%edx
  801ad1:	89 f0                	mov    %esi,%eax
  801ad3:	e8 6d ff ff ff       	call   801a45 <_pipeisclosed>
  801ad8:	85 c0                	test   %eax,%eax
  801ada:	75 48                	jne    801b24 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801adc:	e8 78 f2 ff ff       	call   800d59 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ae1:	8b 43 04             	mov    0x4(%ebx),%eax
  801ae4:	8b 0b                	mov    (%ebx),%ecx
  801ae6:	8d 51 20             	lea    0x20(%ecx),%edx
  801ae9:	39 d0                	cmp    %edx,%eax
  801aeb:	73 e2                	jae    801acf <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801aed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801af0:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801af4:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801af7:	89 c2                	mov    %eax,%edx
  801af9:	c1 fa 1f             	sar    $0x1f,%edx
  801afc:	89 d1                	mov    %edx,%ecx
  801afe:	c1 e9 1b             	shr    $0x1b,%ecx
  801b01:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b04:	83 e2 1f             	and    $0x1f,%edx
  801b07:	29 ca                	sub    %ecx,%edx
  801b09:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b0d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b11:	83 c0 01             	add    $0x1,%eax
  801b14:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b17:	83 c7 01             	add    $0x1,%edi
  801b1a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b1d:	75 c2                	jne    801ae1 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b1f:	8b 45 10             	mov    0x10(%ebp),%eax
  801b22:	eb 05                	jmp    801b29 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b24:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b2c:	5b                   	pop    %ebx
  801b2d:	5e                   	pop    %esi
  801b2e:	5f                   	pop    %edi
  801b2f:	5d                   	pop    %ebp
  801b30:	c3                   	ret    

00801b31 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b31:	55                   	push   %ebp
  801b32:	89 e5                	mov    %esp,%ebp
  801b34:	57                   	push   %edi
  801b35:	56                   	push   %esi
  801b36:	53                   	push   %ebx
  801b37:	83 ec 18             	sub    $0x18,%esp
  801b3a:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b3d:	57                   	push   %edi
  801b3e:	e8 8f f6 ff ff       	call   8011d2 <fd2data>
  801b43:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b45:	83 c4 10             	add    $0x10,%esp
  801b48:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b4d:	eb 3d                	jmp    801b8c <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b4f:	85 db                	test   %ebx,%ebx
  801b51:	74 04                	je     801b57 <devpipe_read+0x26>
				return i;
  801b53:	89 d8                	mov    %ebx,%eax
  801b55:	eb 44                	jmp    801b9b <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b57:	89 f2                	mov    %esi,%edx
  801b59:	89 f8                	mov    %edi,%eax
  801b5b:	e8 e5 fe ff ff       	call   801a45 <_pipeisclosed>
  801b60:	85 c0                	test   %eax,%eax
  801b62:	75 32                	jne    801b96 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b64:	e8 f0 f1 ff ff       	call   800d59 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b69:	8b 06                	mov    (%esi),%eax
  801b6b:	3b 46 04             	cmp    0x4(%esi),%eax
  801b6e:	74 df                	je     801b4f <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b70:	99                   	cltd   
  801b71:	c1 ea 1b             	shr    $0x1b,%edx
  801b74:	01 d0                	add    %edx,%eax
  801b76:	83 e0 1f             	and    $0x1f,%eax
  801b79:	29 d0                	sub    %edx,%eax
  801b7b:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b83:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b86:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b89:	83 c3 01             	add    $0x1,%ebx
  801b8c:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b8f:	75 d8                	jne    801b69 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b91:	8b 45 10             	mov    0x10(%ebp),%eax
  801b94:	eb 05                	jmp    801b9b <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b96:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b9e:	5b                   	pop    %ebx
  801b9f:	5e                   	pop    %esi
  801ba0:	5f                   	pop    %edi
  801ba1:	5d                   	pop    %ebp
  801ba2:	c3                   	ret    

00801ba3 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ba3:	55                   	push   %ebp
  801ba4:	89 e5                	mov    %esp,%ebp
  801ba6:	56                   	push   %esi
  801ba7:	53                   	push   %ebx
  801ba8:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bae:	50                   	push   %eax
  801baf:	e8 35 f6 ff ff       	call   8011e9 <fd_alloc>
  801bb4:	83 c4 10             	add    $0x10,%esp
  801bb7:	89 c2                	mov    %eax,%edx
  801bb9:	85 c0                	test   %eax,%eax
  801bbb:	0f 88 2c 01 00 00    	js     801ced <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bc1:	83 ec 04             	sub    $0x4,%esp
  801bc4:	68 07 04 00 00       	push   $0x407
  801bc9:	ff 75 f4             	pushl  -0xc(%ebp)
  801bcc:	6a 00                	push   $0x0
  801bce:	e8 a5 f1 ff ff       	call   800d78 <sys_page_alloc>
  801bd3:	83 c4 10             	add    $0x10,%esp
  801bd6:	89 c2                	mov    %eax,%edx
  801bd8:	85 c0                	test   %eax,%eax
  801bda:	0f 88 0d 01 00 00    	js     801ced <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801be0:	83 ec 0c             	sub    $0xc,%esp
  801be3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801be6:	50                   	push   %eax
  801be7:	e8 fd f5 ff ff       	call   8011e9 <fd_alloc>
  801bec:	89 c3                	mov    %eax,%ebx
  801bee:	83 c4 10             	add    $0x10,%esp
  801bf1:	85 c0                	test   %eax,%eax
  801bf3:	0f 88 e2 00 00 00    	js     801cdb <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bf9:	83 ec 04             	sub    $0x4,%esp
  801bfc:	68 07 04 00 00       	push   $0x407
  801c01:	ff 75 f0             	pushl  -0x10(%ebp)
  801c04:	6a 00                	push   $0x0
  801c06:	e8 6d f1 ff ff       	call   800d78 <sys_page_alloc>
  801c0b:	89 c3                	mov    %eax,%ebx
  801c0d:	83 c4 10             	add    $0x10,%esp
  801c10:	85 c0                	test   %eax,%eax
  801c12:	0f 88 c3 00 00 00    	js     801cdb <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c18:	83 ec 0c             	sub    $0xc,%esp
  801c1b:	ff 75 f4             	pushl  -0xc(%ebp)
  801c1e:	e8 af f5 ff ff       	call   8011d2 <fd2data>
  801c23:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c25:	83 c4 0c             	add    $0xc,%esp
  801c28:	68 07 04 00 00       	push   $0x407
  801c2d:	50                   	push   %eax
  801c2e:	6a 00                	push   $0x0
  801c30:	e8 43 f1 ff ff       	call   800d78 <sys_page_alloc>
  801c35:	89 c3                	mov    %eax,%ebx
  801c37:	83 c4 10             	add    $0x10,%esp
  801c3a:	85 c0                	test   %eax,%eax
  801c3c:	0f 88 89 00 00 00    	js     801ccb <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c42:	83 ec 0c             	sub    $0xc,%esp
  801c45:	ff 75 f0             	pushl  -0x10(%ebp)
  801c48:	e8 85 f5 ff ff       	call   8011d2 <fd2data>
  801c4d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c54:	50                   	push   %eax
  801c55:	6a 00                	push   $0x0
  801c57:	56                   	push   %esi
  801c58:	6a 00                	push   $0x0
  801c5a:	e8 5c f1 ff ff       	call   800dbb <sys_page_map>
  801c5f:	89 c3                	mov    %eax,%ebx
  801c61:	83 c4 20             	add    $0x20,%esp
  801c64:	85 c0                	test   %eax,%eax
  801c66:	78 55                	js     801cbd <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c68:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c71:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c73:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c76:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c7d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c83:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c86:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c88:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c8b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c92:	83 ec 0c             	sub    $0xc,%esp
  801c95:	ff 75 f4             	pushl  -0xc(%ebp)
  801c98:	e8 25 f5 ff ff       	call   8011c2 <fd2num>
  801c9d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ca0:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ca2:	83 c4 04             	add    $0x4,%esp
  801ca5:	ff 75 f0             	pushl  -0x10(%ebp)
  801ca8:	e8 15 f5 ff ff       	call   8011c2 <fd2num>
  801cad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cb0:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801cb3:	83 c4 10             	add    $0x10,%esp
  801cb6:	ba 00 00 00 00       	mov    $0x0,%edx
  801cbb:	eb 30                	jmp    801ced <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801cbd:	83 ec 08             	sub    $0x8,%esp
  801cc0:	56                   	push   %esi
  801cc1:	6a 00                	push   $0x0
  801cc3:	e8 35 f1 ff ff       	call   800dfd <sys_page_unmap>
  801cc8:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ccb:	83 ec 08             	sub    $0x8,%esp
  801cce:	ff 75 f0             	pushl  -0x10(%ebp)
  801cd1:	6a 00                	push   $0x0
  801cd3:	e8 25 f1 ff ff       	call   800dfd <sys_page_unmap>
  801cd8:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801cdb:	83 ec 08             	sub    $0x8,%esp
  801cde:	ff 75 f4             	pushl  -0xc(%ebp)
  801ce1:	6a 00                	push   $0x0
  801ce3:	e8 15 f1 ff ff       	call   800dfd <sys_page_unmap>
  801ce8:	83 c4 10             	add    $0x10,%esp
  801ceb:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801ced:	89 d0                	mov    %edx,%eax
  801cef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cf2:	5b                   	pop    %ebx
  801cf3:	5e                   	pop    %esi
  801cf4:	5d                   	pop    %ebp
  801cf5:	c3                   	ret    

00801cf6 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cf6:	55                   	push   %ebp
  801cf7:	89 e5                	mov    %esp,%ebp
  801cf9:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cfc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cff:	50                   	push   %eax
  801d00:	ff 75 08             	pushl  0x8(%ebp)
  801d03:	e8 30 f5 ff ff       	call   801238 <fd_lookup>
  801d08:	83 c4 10             	add    $0x10,%esp
  801d0b:	85 c0                	test   %eax,%eax
  801d0d:	78 18                	js     801d27 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d0f:	83 ec 0c             	sub    $0xc,%esp
  801d12:	ff 75 f4             	pushl  -0xc(%ebp)
  801d15:	e8 b8 f4 ff ff       	call   8011d2 <fd2data>
	return _pipeisclosed(fd, p);
  801d1a:	89 c2                	mov    %eax,%edx
  801d1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d1f:	e8 21 fd ff ff       	call   801a45 <_pipeisclosed>
  801d24:	83 c4 10             	add    $0x10,%esp
}
  801d27:	c9                   	leave  
  801d28:	c3                   	ret    

00801d29 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d29:	55                   	push   %ebp
  801d2a:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d2c:	b8 00 00 00 00       	mov    $0x0,%eax
  801d31:	5d                   	pop    %ebp
  801d32:	c3                   	ret    

00801d33 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d33:	55                   	push   %ebp
  801d34:	89 e5                	mov    %esp,%ebp
  801d36:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d39:	68 51 28 80 00       	push   $0x802851
  801d3e:	ff 75 0c             	pushl  0xc(%ebp)
  801d41:	e8 2f ec ff ff       	call   800975 <strcpy>
	return 0;
}
  801d46:	b8 00 00 00 00       	mov    $0x0,%eax
  801d4b:	c9                   	leave  
  801d4c:	c3                   	ret    

00801d4d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d4d:	55                   	push   %ebp
  801d4e:	89 e5                	mov    %esp,%ebp
  801d50:	57                   	push   %edi
  801d51:	56                   	push   %esi
  801d52:	53                   	push   %ebx
  801d53:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d59:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d5e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d64:	eb 2d                	jmp    801d93 <devcons_write+0x46>
		m = n - tot;
  801d66:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d69:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d6b:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d6e:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d73:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d76:	83 ec 04             	sub    $0x4,%esp
  801d79:	53                   	push   %ebx
  801d7a:	03 45 0c             	add    0xc(%ebp),%eax
  801d7d:	50                   	push   %eax
  801d7e:	57                   	push   %edi
  801d7f:	e8 83 ed ff ff       	call   800b07 <memmove>
		sys_cputs(buf, m);
  801d84:	83 c4 08             	add    $0x8,%esp
  801d87:	53                   	push   %ebx
  801d88:	57                   	push   %edi
  801d89:	e8 2e ef ff ff       	call   800cbc <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d8e:	01 de                	add    %ebx,%esi
  801d90:	83 c4 10             	add    $0x10,%esp
  801d93:	89 f0                	mov    %esi,%eax
  801d95:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d98:	72 cc                	jb     801d66 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d9d:	5b                   	pop    %ebx
  801d9e:	5e                   	pop    %esi
  801d9f:	5f                   	pop    %edi
  801da0:	5d                   	pop    %ebp
  801da1:	c3                   	ret    

00801da2 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801da2:	55                   	push   %ebp
  801da3:	89 e5                	mov    %esp,%ebp
  801da5:	83 ec 08             	sub    $0x8,%esp
  801da8:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801dad:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801db1:	74 2a                	je     801ddd <devcons_read+0x3b>
  801db3:	eb 05                	jmp    801dba <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801db5:	e8 9f ef ff ff       	call   800d59 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801dba:	e8 1b ef ff ff       	call   800cda <sys_cgetc>
  801dbf:	85 c0                	test   %eax,%eax
  801dc1:	74 f2                	je     801db5 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801dc3:	85 c0                	test   %eax,%eax
  801dc5:	78 16                	js     801ddd <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801dc7:	83 f8 04             	cmp    $0x4,%eax
  801dca:	74 0c                	je     801dd8 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801dcc:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dcf:	88 02                	mov    %al,(%edx)
	return 1;
  801dd1:	b8 01 00 00 00       	mov    $0x1,%eax
  801dd6:	eb 05                	jmp    801ddd <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801dd8:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ddd:	c9                   	leave  
  801dde:	c3                   	ret    

00801ddf <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ddf:	55                   	push   %ebp
  801de0:	89 e5                	mov    %esp,%ebp
  801de2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801de5:	8b 45 08             	mov    0x8(%ebp),%eax
  801de8:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801deb:	6a 01                	push   $0x1
  801ded:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801df0:	50                   	push   %eax
  801df1:	e8 c6 ee ff ff       	call   800cbc <sys_cputs>
}
  801df6:	83 c4 10             	add    $0x10,%esp
  801df9:	c9                   	leave  
  801dfa:	c3                   	ret    

00801dfb <getchar>:

int
getchar(void)
{
  801dfb:	55                   	push   %ebp
  801dfc:	89 e5                	mov    %esp,%ebp
  801dfe:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e01:	6a 01                	push   $0x1
  801e03:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e06:	50                   	push   %eax
  801e07:	6a 00                	push   $0x0
  801e09:	e8 90 f6 ff ff       	call   80149e <read>
	if (r < 0)
  801e0e:	83 c4 10             	add    $0x10,%esp
  801e11:	85 c0                	test   %eax,%eax
  801e13:	78 0f                	js     801e24 <getchar+0x29>
		return r;
	if (r < 1)
  801e15:	85 c0                	test   %eax,%eax
  801e17:	7e 06                	jle    801e1f <getchar+0x24>
		return -E_EOF;
	return c;
  801e19:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e1d:	eb 05                	jmp    801e24 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e1f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e24:	c9                   	leave  
  801e25:	c3                   	ret    

00801e26 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e26:	55                   	push   %ebp
  801e27:	89 e5                	mov    %esp,%ebp
  801e29:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e2c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e2f:	50                   	push   %eax
  801e30:	ff 75 08             	pushl  0x8(%ebp)
  801e33:	e8 00 f4 ff ff       	call   801238 <fd_lookup>
  801e38:	83 c4 10             	add    $0x10,%esp
  801e3b:	85 c0                	test   %eax,%eax
  801e3d:	78 11                	js     801e50 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e42:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e48:	39 10                	cmp    %edx,(%eax)
  801e4a:	0f 94 c0             	sete   %al
  801e4d:	0f b6 c0             	movzbl %al,%eax
}
  801e50:	c9                   	leave  
  801e51:	c3                   	ret    

00801e52 <opencons>:

int
opencons(void)
{
  801e52:	55                   	push   %ebp
  801e53:	89 e5                	mov    %esp,%ebp
  801e55:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e58:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e5b:	50                   	push   %eax
  801e5c:	e8 88 f3 ff ff       	call   8011e9 <fd_alloc>
  801e61:	83 c4 10             	add    $0x10,%esp
		return r;
  801e64:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e66:	85 c0                	test   %eax,%eax
  801e68:	78 3e                	js     801ea8 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e6a:	83 ec 04             	sub    $0x4,%esp
  801e6d:	68 07 04 00 00       	push   $0x407
  801e72:	ff 75 f4             	pushl  -0xc(%ebp)
  801e75:	6a 00                	push   $0x0
  801e77:	e8 fc ee ff ff       	call   800d78 <sys_page_alloc>
  801e7c:	83 c4 10             	add    $0x10,%esp
		return r;
  801e7f:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e81:	85 c0                	test   %eax,%eax
  801e83:	78 23                	js     801ea8 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e85:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e8e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e90:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e93:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e9a:	83 ec 0c             	sub    $0xc,%esp
  801e9d:	50                   	push   %eax
  801e9e:	e8 1f f3 ff ff       	call   8011c2 <fd2num>
  801ea3:	89 c2                	mov    %eax,%edx
  801ea5:	83 c4 10             	add    $0x10,%esp
}
  801ea8:	89 d0                	mov    %edx,%eax
  801eaa:	c9                   	leave  
  801eab:	c3                   	ret    

00801eac <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801eac:	55                   	push   %ebp
  801ead:	89 e5                	mov    %esp,%ebp
  801eaf:	53                   	push   %ebx
  801eb0:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801eb3:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801eba:	75 28                	jne    801ee4 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		void *va = (void *) (UXSTACKTOP - PGSIZE);
		envid_t envid = sys_getenvid();
  801ebc:	e8 79 ee ff ff       	call   800d3a <sys_getenvid>
  801ec1:	89 c3                	mov    %eax,%ebx

		sys_page_alloc(envid, va, PTE_P | PTE_U | PTE_W);
  801ec3:	83 ec 04             	sub    $0x4,%esp
  801ec6:	6a 07                	push   $0x7
  801ec8:	68 00 f0 bf ee       	push   $0xeebff000
  801ecd:	50                   	push   %eax
  801ece:	e8 a5 ee ff ff       	call   800d78 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801ed3:	83 c4 08             	add    $0x8,%esp
  801ed6:	68 f1 1e 80 00       	push   $0x801ef1
  801edb:	53                   	push   %ebx
  801edc:	e8 e2 ef ff ff       	call   800ec3 <sys_env_set_pgfault_upcall>
  801ee1:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801ee4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee7:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801eec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801eef:	c9                   	leave  
  801ef0:	c3                   	ret    

00801ef1 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp				// function argument: pointer to UTF
  801ef1:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801ef2:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801ef7:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801ef9:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp, %ebx		// 40 = size between utf_fault_va ~ utf_regs
  801efc:	89 e3                	mov    %esp,%ebx
	movl 40(%esp), %eax // point to utf_eip
  801efe:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %esp // point to utf_esp
  801f02:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax 			// push eip of utf
  801f06:	50                   	push   %eax

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx, %esp 	// back to origin exception stack
  801f07:	89 dc                	mov    %ebx,%esp
	subl $4, 48(%esp) 	// utf_esp - 4
  801f09:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	popl %eax  			// pop utf_fault_va (ignore)
  801f0e:	58                   	pop    %eax
	popl %eax  			// pop utf_err (ignore)
  801f0f:	58                   	pop    %eax
	popal 				// pop utf_regs 
  801f10:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4, %esp 		// ignore utf_eip
  801f11:	83 c4 04             	add    $0x4,%esp
	popfl 				// restore utf_eflags to eflags
  801f14:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp  			// restore %esp = utf_esp
  801f15:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f16:	c3                   	ret    

00801f17 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f17:	55                   	push   %ebp
  801f18:	89 e5                	mov    %esp,%ebp
  801f1a:	56                   	push   %esi
  801f1b:	53                   	push   %ebx
  801f1c:	8b 75 08             	mov    0x8(%ebp),%esi
  801f1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f22:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

    if (pg != NULL)
  801f25:	85 c0                	test   %eax,%eax
  801f27:	74 0e                	je     801f37 <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  801f29:	83 ec 0c             	sub    $0xc,%esp
  801f2c:	50                   	push   %eax
  801f2d:	e8 f6 ef ff ff       	call   800f28 <sys_ipc_recv>
  801f32:	83 c4 10             	add    $0x10,%esp
  801f35:	eb 0d                	jmp    801f44 <ipc_recv+0x2d>
	else
        r = sys_ipc_recv((void *)-1);
  801f37:	83 ec 0c             	sub    $0xc,%esp
  801f3a:	6a ff                	push   $0xffffffff
  801f3c:	e8 e7 ef ff ff       	call   800f28 <sys_ipc_recv>
  801f41:	83 c4 10             	add    $0x10,%esp

	if (r < 0) {
  801f44:	85 c0                	test   %eax,%eax
  801f46:	79 16                	jns    801f5e <ipc_recv+0x47>

		if (from_env_store != NULL)
  801f48:	85 f6                	test   %esi,%esi
  801f4a:	74 06                	je     801f52 <ipc_recv+0x3b>
			*from_env_store = 0;
  801f4c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL)
  801f52:	85 db                	test   %ebx,%ebx
  801f54:	74 2c                	je     801f82 <ipc_recv+0x6b>
			*perm_store = 0;
  801f56:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801f5c:	eb 24                	jmp    801f82 <ipc_recv+0x6b>
		return r;

	} else {

		if (from_env_store != NULL)
  801f5e:	85 f6                	test   %esi,%esi
  801f60:	74 0a                	je     801f6c <ipc_recv+0x55>
			*from_env_store = thisenv->env_ipc_from;
  801f62:	a1 04 40 80 00       	mov    0x804004,%eax
  801f67:	8b 40 74             	mov    0x74(%eax),%eax
  801f6a:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL)
  801f6c:	85 db                	test   %ebx,%ebx
  801f6e:	74 0a                	je     801f7a <ipc_recv+0x63>
			*perm_store = thisenv->env_ipc_perm;
  801f70:	a1 04 40 80 00       	mov    0x804004,%eax
  801f75:	8b 40 78             	mov    0x78(%eax),%eax
  801f78:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801f7a:	a1 04 40 80 00       	mov    0x804004,%eax
  801f7f:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801f82:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f85:	5b                   	pop    %ebx
  801f86:	5e                   	pop    %esi
  801f87:	5d                   	pop    %ebp
  801f88:	c3                   	ret    

00801f89 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f89:	55                   	push   %ebp
  801f8a:	89 e5                	mov    %esp,%ebp
  801f8c:	57                   	push   %edi
  801f8d:	56                   	push   %esi
  801f8e:	53                   	push   %ebx
  801f8f:	83 ec 0c             	sub    $0xc,%esp
  801f92:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f95:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f98:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

	if (pg == NULL)
  801f9b:	85 db                	test   %ebx,%ebx
		pg = (void *)-1;	
  801f9d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801fa2:	0f 44 d8             	cmove  %eax,%ebx

	while (true) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801fa5:	ff 75 14             	pushl  0x14(%ebp)
  801fa8:	53                   	push   %ebx
  801fa9:	56                   	push   %esi
  801faa:	57                   	push   %edi
  801fab:	e8 55 ef ff ff       	call   800f05 <sys_ipc_try_send>
		if (r >= 0)
  801fb0:	83 c4 10             	add    $0x10,%esp
  801fb3:	85 c0                	test   %eax,%eax
  801fb5:	79 1e                	jns    801fd5 <ipc_send+0x4c>
			return;
		else if (r != -E_IPC_NOT_RECV)
  801fb7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fba:	74 12                	je     801fce <ipc_send+0x45>
			panic("ipc_send error: %e", r);
  801fbc:	50                   	push   %eax
  801fbd:	68 5d 28 80 00       	push   $0x80285d
  801fc2:	6a 49                	push   $0x49
  801fc4:	68 70 28 80 00       	push   $0x802870
  801fc9:	e8 ca e2 ff ff       	call   800298 <_panic>
	
		sys_yield();
  801fce:	e8 86 ed ff ff       	call   800d59 <sys_yield>
	}
  801fd3:	eb d0                	jmp    801fa5 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  801fd5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fd8:	5b                   	pop    %ebx
  801fd9:	5e                   	pop    %esi
  801fda:	5f                   	pop    %edi
  801fdb:	5d                   	pop    %ebp
  801fdc:	c3                   	ret    

00801fdd <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fdd:	55                   	push   %ebp
  801fde:	89 e5                	mov    %esp,%ebp
  801fe0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fe3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fe8:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801feb:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ff1:	8b 52 50             	mov    0x50(%edx),%edx
  801ff4:	39 ca                	cmp    %ecx,%edx
  801ff6:	75 0d                	jne    802005 <ipc_find_env+0x28>
			return envs[i].env_id;
  801ff8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ffb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802000:	8b 40 48             	mov    0x48(%eax),%eax
  802003:	eb 0f                	jmp    802014 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802005:	83 c0 01             	add    $0x1,%eax
  802008:	3d 00 04 00 00       	cmp    $0x400,%eax
  80200d:	75 d9                	jne    801fe8 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80200f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802014:	5d                   	pop    %ebp
  802015:	c3                   	ret    

00802016 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802016:	55                   	push   %ebp
  802017:	89 e5                	mov    %esp,%ebp
  802019:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80201c:	89 d0                	mov    %edx,%eax
  80201e:	c1 e8 16             	shr    $0x16,%eax
  802021:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802028:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80202d:	f6 c1 01             	test   $0x1,%cl
  802030:	74 1d                	je     80204f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802032:	c1 ea 0c             	shr    $0xc,%edx
  802035:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80203c:	f6 c2 01             	test   $0x1,%dl
  80203f:	74 0e                	je     80204f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802041:	c1 ea 0c             	shr    $0xc,%edx
  802044:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80204b:	ef 
  80204c:	0f b7 c0             	movzwl %ax,%eax
}
  80204f:	5d                   	pop    %ebp
  802050:	c3                   	ret    
  802051:	66 90                	xchg   %ax,%ax
  802053:	66 90                	xchg   %ax,%ax
  802055:	66 90                	xchg   %ax,%ax
  802057:	66 90                	xchg   %ax,%ax
  802059:	66 90                	xchg   %ax,%ax
  80205b:	66 90                	xchg   %ax,%ax
  80205d:	66 90                	xchg   %ax,%ax
  80205f:	90                   	nop

00802060 <__udivdi3>:
  802060:	55                   	push   %ebp
  802061:	57                   	push   %edi
  802062:	56                   	push   %esi
  802063:	53                   	push   %ebx
  802064:	83 ec 1c             	sub    $0x1c,%esp
  802067:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80206b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80206f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802073:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802077:	85 f6                	test   %esi,%esi
  802079:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80207d:	89 ca                	mov    %ecx,%edx
  80207f:	89 f8                	mov    %edi,%eax
  802081:	75 3d                	jne    8020c0 <__udivdi3+0x60>
  802083:	39 cf                	cmp    %ecx,%edi
  802085:	0f 87 c5 00 00 00    	ja     802150 <__udivdi3+0xf0>
  80208b:	85 ff                	test   %edi,%edi
  80208d:	89 fd                	mov    %edi,%ebp
  80208f:	75 0b                	jne    80209c <__udivdi3+0x3c>
  802091:	b8 01 00 00 00       	mov    $0x1,%eax
  802096:	31 d2                	xor    %edx,%edx
  802098:	f7 f7                	div    %edi
  80209a:	89 c5                	mov    %eax,%ebp
  80209c:	89 c8                	mov    %ecx,%eax
  80209e:	31 d2                	xor    %edx,%edx
  8020a0:	f7 f5                	div    %ebp
  8020a2:	89 c1                	mov    %eax,%ecx
  8020a4:	89 d8                	mov    %ebx,%eax
  8020a6:	89 cf                	mov    %ecx,%edi
  8020a8:	f7 f5                	div    %ebp
  8020aa:	89 c3                	mov    %eax,%ebx
  8020ac:	89 d8                	mov    %ebx,%eax
  8020ae:	89 fa                	mov    %edi,%edx
  8020b0:	83 c4 1c             	add    $0x1c,%esp
  8020b3:	5b                   	pop    %ebx
  8020b4:	5e                   	pop    %esi
  8020b5:	5f                   	pop    %edi
  8020b6:	5d                   	pop    %ebp
  8020b7:	c3                   	ret    
  8020b8:	90                   	nop
  8020b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020c0:	39 ce                	cmp    %ecx,%esi
  8020c2:	77 74                	ja     802138 <__udivdi3+0xd8>
  8020c4:	0f bd fe             	bsr    %esi,%edi
  8020c7:	83 f7 1f             	xor    $0x1f,%edi
  8020ca:	0f 84 98 00 00 00    	je     802168 <__udivdi3+0x108>
  8020d0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020d5:	89 f9                	mov    %edi,%ecx
  8020d7:	89 c5                	mov    %eax,%ebp
  8020d9:	29 fb                	sub    %edi,%ebx
  8020db:	d3 e6                	shl    %cl,%esi
  8020dd:	89 d9                	mov    %ebx,%ecx
  8020df:	d3 ed                	shr    %cl,%ebp
  8020e1:	89 f9                	mov    %edi,%ecx
  8020e3:	d3 e0                	shl    %cl,%eax
  8020e5:	09 ee                	or     %ebp,%esi
  8020e7:	89 d9                	mov    %ebx,%ecx
  8020e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020ed:	89 d5                	mov    %edx,%ebp
  8020ef:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020f3:	d3 ed                	shr    %cl,%ebp
  8020f5:	89 f9                	mov    %edi,%ecx
  8020f7:	d3 e2                	shl    %cl,%edx
  8020f9:	89 d9                	mov    %ebx,%ecx
  8020fb:	d3 e8                	shr    %cl,%eax
  8020fd:	09 c2                	or     %eax,%edx
  8020ff:	89 d0                	mov    %edx,%eax
  802101:	89 ea                	mov    %ebp,%edx
  802103:	f7 f6                	div    %esi
  802105:	89 d5                	mov    %edx,%ebp
  802107:	89 c3                	mov    %eax,%ebx
  802109:	f7 64 24 0c          	mull   0xc(%esp)
  80210d:	39 d5                	cmp    %edx,%ebp
  80210f:	72 10                	jb     802121 <__udivdi3+0xc1>
  802111:	8b 74 24 08          	mov    0x8(%esp),%esi
  802115:	89 f9                	mov    %edi,%ecx
  802117:	d3 e6                	shl    %cl,%esi
  802119:	39 c6                	cmp    %eax,%esi
  80211b:	73 07                	jae    802124 <__udivdi3+0xc4>
  80211d:	39 d5                	cmp    %edx,%ebp
  80211f:	75 03                	jne    802124 <__udivdi3+0xc4>
  802121:	83 eb 01             	sub    $0x1,%ebx
  802124:	31 ff                	xor    %edi,%edi
  802126:	89 d8                	mov    %ebx,%eax
  802128:	89 fa                	mov    %edi,%edx
  80212a:	83 c4 1c             	add    $0x1c,%esp
  80212d:	5b                   	pop    %ebx
  80212e:	5e                   	pop    %esi
  80212f:	5f                   	pop    %edi
  802130:	5d                   	pop    %ebp
  802131:	c3                   	ret    
  802132:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802138:	31 ff                	xor    %edi,%edi
  80213a:	31 db                	xor    %ebx,%ebx
  80213c:	89 d8                	mov    %ebx,%eax
  80213e:	89 fa                	mov    %edi,%edx
  802140:	83 c4 1c             	add    $0x1c,%esp
  802143:	5b                   	pop    %ebx
  802144:	5e                   	pop    %esi
  802145:	5f                   	pop    %edi
  802146:	5d                   	pop    %ebp
  802147:	c3                   	ret    
  802148:	90                   	nop
  802149:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802150:	89 d8                	mov    %ebx,%eax
  802152:	f7 f7                	div    %edi
  802154:	31 ff                	xor    %edi,%edi
  802156:	89 c3                	mov    %eax,%ebx
  802158:	89 d8                	mov    %ebx,%eax
  80215a:	89 fa                	mov    %edi,%edx
  80215c:	83 c4 1c             	add    $0x1c,%esp
  80215f:	5b                   	pop    %ebx
  802160:	5e                   	pop    %esi
  802161:	5f                   	pop    %edi
  802162:	5d                   	pop    %ebp
  802163:	c3                   	ret    
  802164:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802168:	39 ce                	cmp    %ecx,%esi
  80216a:	72 0c                	jb     802178 <__udivdi3+0x118>
  80216c:	31 db                	xor    %ebx,%ebx
  80216e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802172:	0f 87 34 ff ff ff    	ja     8020ac <__udivdi3+0x4c>
  802178:	bb 01 00 00 00       	mov    $0x1,%ebx
  80217d:	e9 2a ff ff ff       	jmp    8020ac <__udivdi3+0x4c>
  802182:	66 90                	xchg   %ax,%ax
  802184:	66 90                	xchg   %ax,%ax
  802186:	66 90                	xchg   %ax,%ax
  802188:	66 90                	xchg   %ax,%ax
  80218a:	66 90                	xchg   %ax,%ax
  80218c:	66 90                	xchg   %ax,%ax
  80218e:	66 90                	xchg   %ax,%ax

00802190 <__umoddi3>:
  802190:	55                   	push   %ebp
  802191:	57                   	push   %edi
  802192:	56                   	push   %esi
  802193:	53                   	push   %ebx
  802194:	83 ec 1c             	sub    $0x1c,%esp
  802197:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80219b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80219f:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021a7:	85 d2                	test   %edx,%edx
  8021a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021b1:	89 f3                	mov    %esi,%ebx
  8021b3:	89 3c 24             	mov    %edi,(%esp)
  8021b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021ba:	75 1c                	jne    8021d8 <__umoddi3+0x48>
  8021bc:	39 f7                	cmp    %esi,%edi
  8021be:	76 50                	jbe    802210 <__umoddi3+0x80>
  8021c0:	89 c8                	mov    %ecx,%eax
  8021c2:	89 f2                	mov    %esi,%edx
  8021c4:	f7 f7                	div    %edi
  8021c6:	89 d0                	mov    %edx,%eax
  8021c8:	31 d2                	xor    %edx,%edx
  8021ca:	83 c4 1c             	add    $0x1c,%esp
  8021cd:	5b                   	pop    %ebx
  8021ce:	5e                   	pop    %esi
  8021cf:	5f                   	pop    %edi
  8021d0:	5d                   	pop    %ebp
  8021d1:	c3                   	ret    
  8021d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021d8:	39 f2                	cmp    %esi,%edx
  8021da:	89 d0                	mov    %edx,%eax
  8021dc:	77 52                	ja     802230 <__umoddi3+0xa0>
  8021de:	0f bd ea             	bsr    %edx,%ebp
  8021e1:	83 f5 1f             	xor    $0x1f,%ebp
  8021e4:	75 5a                	jne    802240 <__umoddi3+0xb0>
  8021e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021ea:	0f 82 e0 00 00 00    	jb     8022d0 <__umoddi3+0x140>
  8021f0:	39 0c 24             	cmp    %ecx,(%esp)
  8021f3:	0f 86 d7 00 00 00    	jbe    8022d0 <__umoddi3+0x140>
  8021f9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021fd:	8b 54 24 04          	mov    0x4(%esp),%edx
  802201:	83 c4 1c             	add    $0x1c,%esp
  802204:	5b                   	pop    %ebx
  802205:	5e                   	pop    %esi
  802206:	5f                   	pop    %edi
  802207:	5d                   	pop    %ebp
  802208:	c3                   	ret    
  802209:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802210:	85 ff                	test   %edi,%edi
  802212:	89 fd                	mov    %edi,%ebp
  802214:	75 0b                	jne    802221 <__umoddi3+0x91>
  802216:	b8 01 00 00 00       	mov    $0x1,%eax
  80221b:	31 d2                	xor    %edx,%edx
  80221d:	f7 f7                	div    %edi
  80221f:	89 c5                	mov    %eax,%ebp
  802221:	89 f0                	mov    %esi,%eax
  802223:	31 d2                	xor    %edx,%edx
  802225:	f7 f5                	div    %ebp
  802227:	89 c8                	mov    %ecx,%eax
  802229:	f7 f5                	div    %ebp
  80222b:	89 d0                	mov    %edx,%eax
  80222d:	eb 99                	jmp    8021c8 <__umoddi3+0x38>
  80222f:	90                   	nop
  802230:	89 c8                	mov    %ecx,%eax
  802232:	89 f2                	mov    %esi,%edx
  802234:	83 c4 1c             	add    $0x1c,%esp
  802237:	5b                   	pop    %ebx
  802238:	5e                   	pop    %esi
  802239:	5f                   	pop    %edi
  80223a:	5d                   	pop    %ebp
  80223b:	c3                   	ret    
  80223c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802240:	8b 34 24             	mov    (%esp),%esi
  802243:	bf 20 00 00 00       	mov    $0x20,%edi
  802248:	89 e9                	mov    %ebp,%ecx
  80224a:	29 ef                	sub    %ebp,%edi
  80224c:	d3 e0                	shl    %cl,%eax
  80224e:	89 f9                	mov    %edi,%ecx
  802250:	89 f2                	mov    %esi,%edx
  802252:	d3 ea                	shr    %cl,%edx
  802254:	89 e9                	mov    %ebp,%ecx
  802256:	09 c2                	or     %eax,%edx
  802258:	89 d8                	mov    %ebx,%eax
  80225a:	89 14 24             	mov    %edx,(%esp)
  80225d:	89 f2                	mov    %esi,%edx
  80225f:	d3 e2                	shl    %cl,%edx
  802261:	89 f9                	mov    %edi,%ecx
  802263:	89 54 24 04          	mov    %edx,0x4(%esp)
  802267:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80226b:	d3 e8                	shr    %cl,%eax
  80226d:	89 e9                	mov    %ebp,%ecx
  80226f:	89 c6                	mov    %eax,%esi
  802271:	d3 e3                	shl    %cl,%ebx
  802273:	89 f9                	mov    %edi,%ecx
  802275:	89 d0                	mov    %edx,%eax
  802277:	d3 e8                	shr    %cl,%eax
  802279:	89 e9                	mov    %ebp,%ecx
  80227b:	09 d8                	or     %ebx,%eax
  80227d:	89 d3                	mov    %edx,%ebx
  80227f:	89 f2                	mov    %esi,%edx
  802281:	f7 34 24             	divl   (%esp)
  802284:	89 d6                	mov    %edx,%esi
  802286:	d3 e3                	shl    %cl,%ebx
  802288:	f7 64 24 04          	mull   0x4(%esp)
  80228c:	39 d6                	cmp    %edx,%esi
  80228e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802292:	89 d1                	mov    %edx,%ecx
  802294:	89 c3                	mov    %eax,%ebx
  802296:	72 08                	jb     8022a0 <__umoddi3+0x110>
  802298:	75 11                	jne    8022ab <__umoddi3+0x11b>
  80229a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80229e:	73 0b                	jae    8022ab <__umoddi3+0x11b>
  8022a0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022a4:	1b 14 24             	sbb    (%esp),%edx
  8022a7:	89 d1                	mov    %edx,%ecx
  8022a9:	89 c3                	mov    %eax,%ebx
  8022ab:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022af:	29 da                	sub    %ebx,%edx
  8022b1:	19 ce                	sbb    %ecx,%esi
  8022b3:	89 f9                	mov    %edi,%ecx
  8022b5:	89 f0                	mov    %esi,%eax
  8022b7:	d3 e0                	shl    %cl,%eax
  8022b9:	89 e9                	mov    %ebp,%ecx
  8022bb:	d3 ea                	shr    %cl,%edx
  8022bd:	89 e9                	mov    %ebp,%ecx
  8022bf:	d3 ee                	shr    %cl,%esi
  8022c1:	09 d0                	or     %edx,%eax
  8022c3:	89 f2                	mov    %esi,%edx
  8022c5:	83 c4 1c             	add    $0x1c,%esp
  8022c8:	5b                   	pop    %ebx
  8022c9:	5e                   	pop    %esi
  8022ca:	5f                   	pop    %edi
  8022cb:	5d                   	pop    %ebp
  8022cc:	c3                   	ret    
  8022cd:	8d 76 00             	lea    0x0(%esi),%esi
  8022d0:	29 f9                	sub    %edi,%ecx
  8022d2:	19 d6                	sbb    %edx,%esi
  8022d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022dc:	e9 18 ff ff ff       	jmp    8021f9 <__umoddi3+0x69>
