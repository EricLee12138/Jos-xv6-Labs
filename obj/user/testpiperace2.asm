
obj/user/testpiperace2.debug：     文件格式 elf32-i386


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
  80002c:	e8 a5 01 00 00       	call   8001d6 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 38             	sub    $0x38,%esp
	int p[2], r, i;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for pipeisclosed race...\n");
  80003c:	68 80 22 80 00       	push   $0x802280
  800041:	e8 c9 02 00 00       	call   80030f <cprintf>
	if ((r = pipe(p)) < 0)
  800046:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800049:	89 04 24             	mov    %eax,(%esp)
  80004c:	e8 f0 1a 00 00       	call   801b41 <pipe>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	85 c0                	test   %eax,%eax
  800056:	79 12                	jns    80006a <umain+0x37>
		panic("pipe: %e", r);
  800058:	50                   	push   %eax
  800059:	68 ce 22 80 00       	push   $0x8022ce
  80005e:	6a 0d                	push   $0xd
  800060:	68 d7 22 80 00       	push   $0x8022d7
  800065:	e8 cc 01 00 00       	call   800236 <_panic>
	if ((r = fork()) < 0)
  80006a:	e8 3d 0f 00 00       	call   800fac <fork>
  80006f:	89 c6                	mov    %eax,%esi
  800071:	85 c0                	test   %eax,%eax
  800073:	79 12                	jns    800087 <umain+0x54>
		panic("fork: %e", r);
  800075:	50                   	push   %eax
  800076:	68 ec 22 80 00       	push   $0x8022ec
  80007b:	6a 0f                	push   $0xf
  80007d:	68 d7 22 80 00       	push   $0x8022d7
  800082:	e8 af 01 00 00       	call   800236 <_panic>
	if (r == 0) {
  800087:	85 c0                	test   %eax,%eax
  800089:	75 76                	jne    800101 <umain+0xce>
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800091:	e8 6a 12 00 00       	call   801300 <close>
  800096:	83 c4 10             	add    $0x10,%esp
		for (i = 0; i < 200; i++) {
  800099:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (i % 10 == 0)
  80009e:	bf 67 66 66 66       	mov    $0x66666667,%edi
  8000a3:	89 d8                	mov    %ebx,%eax
  8000a5:	f7 ef                	imul   %edi
  8000a7:	c1 fa 02             	sar    $0x2,%edx
  8000aa:	89 d8                	mov    %ebx,%eax
  8000ac:	c1 f8 1f             	sar    $0x1f,%eax
  8000af:	29 c2                	sub    %eax,%edx
  8000b1:	8d 04 92             	lea    (%edx,%edx,4),%eax
  8000b4:	01 c0                	add    %eax,%eax
  8000b6:	39 c3                	cmp    %eax,%ebx
  8000b8:	75 11                	jne    8000cb <umain+0x98>
				cprintf("%d.", i);
  8000ba:	83 ec 08             	sub    $0x8,%esp
  8000bd:	53                   	push   %ebx
  8000be:	68 f5 22 80 00       	push   $0x8022f5
  8000c3:	e8 47 02 00 00       	call   80030f <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
			// dup, then close.  yield so that other guy will
			// see us while we're between them.
			dup(p[0], 10);
  8000cb:	83 ec 08             	sub    $0x8,%esp
  8000ce:	6a 0a                	push   $0xa
  8000d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8000d3:	e8 78 12 00 00       	call   801350 <dup>
			sys_yield();
  8000d8:	e8 1a 0c 00 00       	call   800cf7 <sys_yield>
			close(10);
  8000dd:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  8000e4:	e8 17 12 00 00       	call   801300 <close>
			sys_yield();
  8000e9:	e8 09 0c 00 00       	call   800cf7 <sys_yield>
	if (r == 0) {
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
		for (i = 0; i < 200; i++) {
  8000ee:	83 c3 01             	add    $0x1,%ebx
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	81 fb c8 00 00 00    	cmp    $0xc8,%ebx
  8000fa:	75 a7                	jne    8000a3 <umain+0x70>
			dup(p[0], 10);
			sys_yield();
			close(10);
			sys_yield();
		}
		exit();
  8000fc:	e8 1b 01 00 00       	call   80021c <exit>
	// pageref(p[0]) and gets 3, then it will return true when
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
  800101:	89 f0                	mov    %esi,%eax
  800103:	25 ff 03 00 00       	and    $0x3ff,%eax
	while (kid->env_status == ENV_RUNNABLE)
  800108:	8d 3c 85 00 00 00 00 	lea    0x0(,%eax,4),%edi
  80010f:	c1 e0 07             	shl    $0x7,%eax
  800112:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800115:	eb 2f                	jmp    800146 <umain+0x113>
		if (pipeisclosed(p[0]) != 0) {
  800117:	83 ec 0c             	sub    $0xc,%esp
  80011a:	ff 75 e0             	pushl  -0x20(%ebp)
  80011d:	e8 72 1b 00 00       	call   801c94 <pipeisclosed>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	74 28                	je     800151 <umain+0x11e>
			cprintf("\nRACE: pipe appears closed\n");
  800129:	83 ec 0c             	sub    $0xc,%esp
  80012c:	68 f9 22 80 00       	push   $0x8022f9
  800131:	e8 d9 01 00 00       	call   80030f <cprintf>
			sys_env_destroy(r);
  800136:	89 34 24             	mov    %esi,(%esp)
  800139:	e8 59 0b 00 00       	call   800c97 <sys_env_destroy>
			exit();
  80013e:	e8 d9 00 00 00       	call   80021c <exit>
  800143:	83 c4 10             	add    $0x10,%esp
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
	while (kid->env_status == ENV_RUNNABLE)
  800146:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800149:	29 fb                	sub    %edi,%ebx
  80014b:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  800151:	8b 43 54             	mov    0x54(%ebx),%eax
  800154:	83 f8 02             	cmp    $0x2,%eax
  800157:	74 be                	je     800117 <umain+0xe4>
		if (pipeisclosed(p[0]) != 0) {
			cprintf("\nRACE: pipe appears closed\n");
			sys_env_destroy(r);
			exit();
		}
	cprintf("child done with loop\n");
  800159:	83 ec 0c             	sub    $0xc,%esp
  80015c:	68 15 23 80 00       	push   $0x802315
  800161:	e8 a9 01 00 00       	call   80030f <cprintf>
	if (pipeisclosed(p[0]))
  800166:	83 c4 04             	add    $0x4,%esp
  800169:	ff 75 e0             	pushl  -0x20(%ebp)
  80016c:	e8 23 1b 00 00       	call   801c94 <pipeisclosed>
  800171:	83 c4 10             	add    $0x10,%esp
  800174:	85 c0                	test   %eax,%eax
  800176:	74 14                	je     80018c <umain+0x159>
		panic("somehow the other end of p[0] got closed!");
  800178:	83 ec 04             	sub    $0x4,%esp
  80017b:	68 a4 22 80 00       	push   $0x8022a4
  800180:	6a 40                	push   $0x40
  800182:	68 d7 22 80 00       	push   $0x8022d7
  800187:	e8 aa 00 00 00       	call   800236 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  80018c:	83 ec 08             	sub    $0x8,%esp
  80018f:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800192:	50                   	push   %eax
  800193:	ff 75 e0             	pushl  -0x20(%ebp)
  800196:	e8 3b 10 00 00       	call   8011d6 <fd_lookup>
  80019b:	83 c4 10             	add    $0x10,%esp
  80019e:	85 c0                	test   %eax,%eax
  8001a0:	79 12                	jns    8001b4 <umain+0x181>
		panic("cannot look up p[0]: %e", r);
  8001a2:	50                   	push   %eax
  8001a3:	68 2b 23 80 00       	push   $0x80232b
  8001a8:	6a 42                	push   $0x42
  8001aa:	68 d7 22 80 00       	push   $0x8022d7
  8001af:	e8 82 00 00 00       	call   800236 <_panic>
	(void) fd2data(fd);
  8001b4:	83 ec 0c             	sub    $0xc,%esp
  8001b7:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ba:	e8 b1 0f 00 00       	call   801170 <fd2data>
	cprintf("race didn't happen\n");
  8001bf:	c7 04 24 43 23 80 00 	movl   $0x802343,(%esp)
  8001c6:	e8 44 01 00 00       	call   80030f <cprintf>
}
  8001cb:	83 c4 10             	add    $0x10,%esp
  8001ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d1:	5b                   	pop    %ebx
  8001d2:	5e                   	pop    %esi
  8001d3:	5f                   	pop    %edi
  8001d4:	5d                   	pop    %ebp
  8001d5:	c3                   	ret    

008001d6 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001d6:	55                   	push   %ebp
  8001d7:	89 e5                	mov    %esp,%ebp
  8001d9:	56                   	push   %esi
  8001da:	53                   	push   %ebx
  8001db:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001de:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001e1:	e8 f2 0a 00 00       	call   800cd8 <sys_getenvid>
  8001e6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001eb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001ee:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001f3:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001f8:	85 db                	test   %ebx,%ebx
  8001fa:	7e 07                	jle    800203 <libmain+0x2d>
		binaryname = argv[0];
  8001fc:	8b 06                	mov    (%esi),%eax
  8001fe:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800203:	83 ec 08             	sub    $0x8,%esp
  800206:	56                   	push   %esi
  800207:	53                   	push   %ebx
  800208:	e8 26 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80020d:	e8 0a 00 00 00       	call   80021c <exit>
}
  800212:	83 c4 10             	add    $0x10,%esp
  800215:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800218:	5b                   	pop    %ebx
  800219:	5e                   	pop    %esi
  80021a:	5d                   	pop    %ebp
  80021b:	c3                   	ret    

0080021c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800222:	e8 04 11 00 00       	call   80132b <close_all>
	sys_env_destroy(0);
  800227:	83 ec 0c             	sub    $0xc,%esp
  80022a:	6a 00                	push   $0x0
  80022c:	e8 66 0a 00 00       	call   800c97 <sys_env_destroy>
}
  800231:	83 c4 10             	add    $0x10,%esp
  800234:	c9                   	leave  
  800235:	c3                   	ret    

00800236 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	56                   	push   %esi
  80023a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80023b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80023e:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800244:	e8 8f 0a 00 00       	call   800cd8 <sys_getenvid>
  800249:	83 ec 0c             	sub    $0xc,%esp
  80024c:	ff 75 0c             	pushl  0xc(%ebp)
  80024f:	ff 75 08             	pushl  0x8(%ebp)
  800252:	56                   	push   %esi
  800253:	50                   	push   %eax
  800254:	68 64 23 80 00       	push   $0x802364
  800259:	e8 b1 00 00 00       	call   80030f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80025e:	83 c4 18             	add    $0x18,%esp
  800261:	53                   	push   %ebx
  800262:	ff 75 10             	pushl  0x10(%ebp)
  800265:	e8 54 00 00 00       	call   8002be <vcprintf>
	cprintf("\n");
  80026a:	c7 04 24 ef 27 80 00 	movl   $0x8027ef,(%esp)
  800271:	e8 99 00 00 00       	call   80030f <cprintf>
  800276:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800279:	cc                   	int3   
  80027a:	eb fd                	jmp    800279 <_panic+0x43>

0080027c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	53                   	push   %ebx
  800280:	83 ec 04             	sub    $0x4,%esp
  800283:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800286:	8b 13                	mov    (%ebx),%edx
  800288:	8d 42 01             	lea    0x1(%edx),%eax
  80028b:	89 03                	mov    %eax,(%ebx)
  80028d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800290:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800294:	3d ff 00 00 00       	cmp    $0xff,%eax
  800299:	75 1a                	jne    8002b5 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80029b:	83 ec 08             	sub    $0x8,%esp
  80029e:	68 ff 00 00 00       	push   $0xff
  8002a3:	8d 43 08             	lea    0x8(%ebx),%eax
  8002a6:	50                   	push   %eax
  8002a7:	e8 ae 09 00 00       	call   800c5a <sys_cputs>
		b->idx = 0;
  8002ac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002b2:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002b5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002bc:	c9                   	leave  
  8002bd:	c3                   	ret    

008002be <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
  8002c1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002c7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002ce:	00 00 00 
	b.cnt = 0;
  8002d1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002d8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002db:	ff 75 0c             	pushl  0xc(%ebp)
  8002de:	ff 75 08             	pushl  0x8(%ebp)
  8002e1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002e7:	50                   	push   %eax
  8002e8:	68 7c 02 80 00       	push   $0x80027c
  8002ed:	e8 1a 01 00 00       	call   80040c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002f2:	83 c4 08             	add    $0x8,%esp
  8002f5:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002fb:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800301:	50                   	push   %eax
  800302:	e8 53 09 00 00       	call   800c5a <sys_cputs>

	return b.cnt;
}
  800307:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80030d:	c9                   	leave  
  80030e:	c3                   	ret    

0080030f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
  800312:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800315:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800318:	50                   	push   %eax
  800319:	ff 75 08             	pushl  0x8(%ebp)
  80031c:	e8 9d ff ff ff       	call   8002be <vcprintf>
	va_end(ap);

	return cnt;
}
  800321:	c9                   	leave  
  800322:	c3                   	ret    

00800323 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	57                   	push   %edi
  800327:	56                   	push   %esi
  800328:	53                   	push   %ebx
  800329:	83 ec 1c             	sub    $0x1c,%esp
  80032c:	89 c7                	mov    %eax,%edi
  80032e:	89 d6                	mov    %edx,%esi
  800330:	8b 45 08             	mov    0x8(%ebp),%eax
  800333:	8b 55 0c             	mov    0xc(%ebp),%edx
  800336:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800339:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80033c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80033f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800344:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800347:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80034a:	39 d3                	cmp    %edx,%ebx
  80034c:	72 05                	jb     800353 <printnum+0x30>
  80034e:	39 45 10             	cmp    %eax,0x10(%ebp)
  800351:	77 45                	ja     800398 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800353:	83 ec 0c             	sub    $0xc,%esp
  800356:	ff 75 18             	pushl  0x18(%ebp)
  800359:	8b 45 14             	mov    0x14(%ebp),%eax
  80035c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80035f:	53                   	push   %ebx
  800360:	ff 75 10             	pushl  0x10(%ebp)
  800363:	83 ec 08             	sub    $0x8,%esp
  800366:	ff 75 e4             	pushl  -0x1c(%ebp)
  800369:	ff 75 e0             	pushl  -0x20(%ebp)
  80036c:	ff 75 dc             	pushl  -0x24(%ebp)
  80036f:	ff 75 d8             	pushl  -0x28(%ebp)
  800372:	e8 79 1c 00 00       	call   801ff0 <__udivdi3>
  800377:	83 c4 18             	add    $0x18,%esp
  80037a:	52                   	push   %edx
  80037b:	50                   	push   %eax
  80037c:	89 f2                	mov    %esi,%edx
  80037e:	89 f8                	mov    %edi,%eax
  800380:	e8 9e ff ff ff       	call   800323 <printnum>
  800385:	83 c4 20             	add    $0x20,%esp
  800388:	eb 18                	jmp    8003a2 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80038a:	83 ec 08             	sub    $0x8,%esp
  80038d:	56                   	push   %esi
  80038e:	ff 75 18             	pushl  0x18(%ebp)
  800391:	ff d7                	call   *%edi
  800393:	83 c4 10             	add    $0x10,%esp
  800396:	eb 03                	jmp    80039b <printnum+0x78>
  800398:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80039b:	83 eb 01             	sub    $0x1,%ebx
  80039e:	85 db                	test   %ebx,%ebx
  8003a0:	7f e8                	jg     80038a <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003a2:	83 ec 08             	sub    $0x8,%esp
  8003a5:	56                   	push   %esi
  8003a6:	83 ec 04             	sub    $0x4,%esp
  8003a9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8003af:	ff 75 dc             	pushl  -0x24(%ebp)
  8003b2:	ff 75 d8             	pushl  -0x28(%ebp)
  8003b5:	e8 66 1d 00 00       	call   802120 <__umoddi3>
  8003ba:	83 c4 14             	add    $0x14,%esp
  8003bd:	0f be 80 87 23 80 00 	movsbl 0x802387(%eax),%eax
  8003c4:	50                   	push   %eax
  8003c5:	ff d7                	call   *%edi
}
  8003c7:	83 c4 10             	add    $0x10,%esp
  8003ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003cd:	5b                   	pop    %ebx
  8003ce:	5e                   	pop    %esi
  8003cf:	5f                   	pop    %edi
  8003d0:	5d                   	pop    %ebp
  8003d1:	c3                   	ret    

008003d2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003d2:	55                   	push   %ebp
  8003d3:	89 e5                	mov    %esp,%ebp
  8003d5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003d8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003dc:	8b 10                	mov    (%eax),%edx
  8003de:	3b 50 04             	cmp    0x4(%eax),%edx
  8003e1:	73 0a                	jae    8003ed <sprintputch+0x1b>
		*b->buf++ = ch;
  8003e3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003e6:	89 08                	mov    %ecx,(%eax)
  8003e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003eb:	88 02                	mov    %al,(%edx)
}
  8003ed:	5d                   	pop    %ebp
  8003ee:	c3                   	ret    

008003ef <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003ef:	55                   	push   %ebp
  8003f0:	89 e5                	mov    %esp,%ebp
  8003f2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003f5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003f8:	50                   	push   %eax
  8003f9:	ff 75 10             	pushl  0x10(%ebp)
  8003fc:	ff 75 0c             	pushl  0xc(%ebp)
  8003ff:	ff 75 08             	pushl  0x8(%ebp)
  800402:	e8 05 00 00 00       	call   80040c <vprintfmt>
	va_end(ap);
}
  800407:	83 c4 10             	add    $0x10,%esp
  80040a:	c9                   	leave  
  80040b:	c3                   	ret    

0080040c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80040c:	55                   	push   %ebp
  80040d:	89 e5                	mov    %esp,%ebp
  80040f:	57                   	push   %edi
  800410:	56                   	push   %esi
  800411:	53                   	push   %ebx
  800412:	83 ec 2c             	sub    $0x2c,%esp
  800415:	8b 75 08             	mov    0x8(%ebp),%esi
  800418:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80041b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80041e:	eb 12                	jmp    800432 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800420:	85 c0                	test   %eax,%eax
  800422:	0f 84 42 04 00 00    	je     80086a <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  800428:	83 ec 08             	sub    $0x8,%esp
  80042b:	53                   	push   %ebx
  80042c:	50                   	push   %eax
  80042d:	ff d6                	call   *%esi
  80042f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800432:	83 c7 01             	add    $0x1,%edi
  800435:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800439:	83 f8 25             	cmp    $0x25,%eax
  80043c:	75 e2                	jne    800420 <vprintfmt+0x14>
  80043e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800442:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800449:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800450:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800457:	b9 00 00 00 00       	mov    $0x0,%ecx
  80045c:	eb 07                	jmp    800465 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800461:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800465:	8d 47 01             	lea    0x1(%edi),%eax
  800468:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80046b:	0f b6 07             	movzbl (%edi),%eax
  80046e:	0f b6 d0             	movzbl %al,%edx
  800471:	83 e8 23             	sub    $0x23,%eax
  800474:	3c 55                	cmp    $0x55,%al
  800476:	0f 87 d3 03 00 00    	ja     80084f <vprintfmt+0x443>
  80047c:	0f b6 c0             	movzbl %al,%eax
  80047f:	ff 24 85 c0 24 80 00 	jmp    *0x8024c0(,%eax,4)
  800486:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800489:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80048d:	eb d6                	jmp    800465 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800492:	b8 00 00 00 00       	mov    $0x0,%eax
  800497:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80049a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80049d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8004a1:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8004a4:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8004a7:	83 f9 09             	cmp    $0x9,%ecx
  8004aa:	77 3f                	ja     8004eb <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004ac:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004af:	eb e9                	jmp    80049a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b4:	8b 00                	mov    (%eax),%eax
  8004b6:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bc:	8d 40 04             	lea    0x4(%eax),%eax
  8004bf:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004c5:	eb 2a                	jmp    8004f1 <vprintfmt+0xe5>
  8004c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004ca:	85 c0                	test   %eax,%eax
  8004cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d1:	0f 49 d0             	cmovns %eax,%edx
  8004d4:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004da:	eb 89                	jmp    800465 <vprintfmt+0x59>
  8004dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004df:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004e6:	e9 7a ff ff ff       	jmp    800465 <vprintfmt+0x59>
  8004eb:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004ee:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004f1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004f5:	0f 89 6a ff ff ff    	jns    800465 <vprintfmt+0x59>
				width = precision, precision = -1;
  8004fb:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800501:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800508:	e9 58 ff ff ff       	jmp    800465 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80050d:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800510:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800513:	e9 4d ff ff ff       	jmp    800465 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800518:	8b 45 14             	mov    0x14(%ebp),%eax
  80051b:	8d 78 04             	lea    0x4(%eax),%edi
  80051e:	83 ec 08             	sub    $0x8,%esp
  800521:	53                   	push   %ebx
  800522:	ff 30                	pushl  (%eax)
  800524:	ff d6                	call   *%esi
			break;
  800526:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800529:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80052f:	e9 fe fe ff ff       	jmp    800432 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800534:	8b 45 14             	mov    0x14(%ebp),%eax
  800537:	8d 78 04             	lea    0x4(%eax),%edi
  80053a:	8b 00                	mov    (%eax),%eax
  80053c:	99                   	cltd   
  80053d:	31 d0                	xor    %edx,%eax
  80053f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800541:	83 f8 0f             	cmp    $0xf,%eax
  800544:	7f 0b                	jg     800551 <vprintfmt+0x145>
  800546:	8b 14 85 20 26 80 00 	mov    0x802620(,%eax,4),%edx
  80054d:	85 d2                	test   %edx,%edx
  80054f:	75 1b                	jne    80056c <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800551:	50                   	push   %eax
  800552:	68 9f 23 80 00       	push   $0x80239f
  800557:	53                   	push   %ebx
  800558:	56                   	push   %esi
  800559:	e8 91 fe ff ff       	call   8003ef <printfmt>
  80055e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800561:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800564:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800567:	e9 c6 fe ff ff       	jmp    800432 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80056c:	52                   	push   %edx
  80056d:	68 bd 27 80 00       	push   $0x8027bd
  800572:	53                   	push   %ebx
  800573:	56                   	push   %esi
  800574:	e8 76 fe ff ff       	call   8003ef <printfmt>
  800579:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80057c:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800582:	e9 ab fe ff ff       	jmp    800432 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800587:	8b 45 14             	mov    0x14(%ebp),%eax
  80058a:	83 c0 04             	add    $0x4,%eax
  80058d:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800590:	8b 45 14             	mov    0x14(%ebp),%eax
  800593:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800595:	85 ff                	test   %edi,%edi
  800597:	b8 98 23 80 00       	mov    $0x802398,%eax
  80059c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80059f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005a3:	0f 8e 94 00 00 00    	jle    80063d <vprintfmt+0x231>
  8005a9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005ad:	0f 84 98 00 00 00    	je     80064b <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b3:	83 ec 08             	sub    $0x8,%esp
  8005b6:	ff 75 d0             	pushl  -0x30(%ebp)
  8005b9:	57                   	push   %edi
  8005ba:	e8 33 03 00 00       	call   8008f2 <strnlen>
  8005bf:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005c2:	29 c1                	sub    %eax,%ecx
  8005c4:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8005c7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005ca:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005ce:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005d1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005d4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d6:	eb 0f                	jmp    8005e7 <vprintfmt+0x1db>
					putch(padc, putdat);
  8005d8:	83 ec 08             	sub    $0x8,%esp
  8005db:	53                   	push   %ebx
  8005dc:	ff 75 e0             	pushl  -0x20(%ebp)
  8005df:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e1:	83 ef 01             	sub    $0x1,%edi
  8005e4:	83 c4 10             	add    $0x10,%esp
  8005e7:	85 ff                	test   %edi,%edi
  8005e9:	7f ed                	jg     8005d8 <vprintfmt+0x1cc>
  8005eb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005ee:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8005f1:	85 c9                	test   %ecx,%ecx
  8005f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8005f8:	0f 49 c1             	cmovns %ecx,%eax
  8005fb:	29 c1                	sub    %eax,%ecx
  8005fd:	89 75 08             	mov    %esi,0x8(%ebp)
  800600:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800603:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800606:	89 cb                	mov    %ecx,%ebx
  800608:	eb 4d                	jmp    800657 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80060a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80060e:	74 1b                	je     80062b <vprintfmt+0x21f>
  800610:	0f be c0             	movsbl %al,%eax
  800613:	83 e8 20             	sub    $0x20,%eax
  800616:	83 f8 5e             	cmp    $0x5e,%eax
  800619:	76 10                	jbe    80062b <vprintfmt+0x21f>
					putch('?', putdat);
  80061b:	83 ec 08             	sub    $0x8,%esp
  80061e:	ff 75 0c             	pushl  0xc(%ebp)
  800621:	6a 3f                	push   $0x3f
  800623:	ff 55 08             	call   *0x8(%ebp)
  800626:	83 c4 10             	add    $0x10,%esp
  800629:	eb 0d                	jmp    800638 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80062b:	83 ec 08             	sub    $0x8,%esp
  80062e:	ff 75 0c             	pushl  0xc(%ebp)
  800631:	52                   	push   %edx
  800632:	ff 55 08             	call   *0x8(%ebp)
  800635:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800638:	83 eb 01             	sub    $0x1,%ebx
  80063b:	eb 1a                	jmp    800657 <vprintfmt+0x24b>
  80063d:	89 75 08             	mov    %esi,0x8(%ebp)
  800640:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800643:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800646:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800649:	eb 0c                	jmp    800657 <vprintfmt+0x24b>
  80064b:	89 75 08             	mov    %esi,0x8(%ebp)
  80064e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800651:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800654:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800657:	83 c7 01             	add    $0x1,%edi
  80065a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80065e:	0f be d0             	movsbl %al,%edx
  800661:	85 d2                	test   %edx,%edx
  800663:	74 23                	je     800688 <vprintfmt+0x27c>
  800665:	85 f6                	test   %esi,%esi
  800667:	78 a1                	js     80060a <vprintfmt+0x1fe>
  800669:	83 ee 01             	sub    $0x1,%esi
  80066c:	79 9c                	jns    80060a <vprintfmt+0x1fe>
  80066e:	89 df                	mov    %ebx,%edi
  800670:	8b 75 08             	mov    0x8(%ebp),%esi
  800673:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800676:	eb 18                	jmp    800690 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800678:	83 ec 08             	sub    $0x8,%esp
  80067b:	53                   	push   %ebx
  80067c:	6a 20                	push   $0x20
  80067e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800680:	83 ef 01             	sub    $0x1,%edi
  800683:	83 c4 10             	add    $0x10,%esp
  800686:	eb 08                	jmp    800690 <vprintfmt+0x284>
  800688:	89 df                	mov    %ebx,%edi
  80068a:	8b 75 08             	mov    0x8(%ebp),%esi
  80068d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800690:	85 ff                	test   %edi,%edi
  800692:	7f e4                	jg     800678 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800694:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800697:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80069d:	e9 90 fd ff ff       	jmp    800432 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006a2:	83 f9 01             	cmp    $0x1,%ecx
  8006a5:	7e 19                	jle    8006c0 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8006a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006aa:	8b 50 04             	mov    0x4(%eax),%edx
  8006ad:	8b 00                	mov    (%eax),%eax
  8006af:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006b2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b8:	8d 40 08             	lea    0x8(%eax),%eax
  8006bb:	89 45 14             	mov    %eax,0x14(%ebp)
  8006be:	eb 38                	jmp    8006f8 <vprintfmt+0x2ec>
	else if (lflag)
  8006c0:	85 c9                	test   %ecx,%ecx
  8006c2:	74 1b                	je     8006df <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8006c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c7:	8b 00                	mov    (%eax),%eax
  8006c9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006cc:	89 c1                	mov    %eax,%ecx
  8006ce:	c1 f9 1f             	sar    $0x1f,%ecx
  8006d1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d7:	8d 40 04             	lea    0x4(%eax),%eax
  8006da:	89 45 14             	mov    %eax,0x14(%ebp)
  8006dd:	eb 19                	jmp    8006f8 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8006df:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e2:	8b 00                	mov    (%eax),%eax
  8006e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e7:	89 c1                	mov    %eax,%ecx
  8006e9:	c1 f9 1f             	sar    $0x1f,%ecx
  8006ec:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f2:	8d 40 04             	lea    0x4(%eax),%eax
  8006f5:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006f8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006fb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006fe:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800703:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800707:	0f 89 0e 01 00 00    	jns    80081b <vprintfmt+0x40f>
				putch('-', putdat);
  80070d:	83 ec 08             	sub    $0x8,%esp
  800710:	53                   	push   %ebx
  800711:	6a 2d                	push   $0x2d
  800713:	ff d6                	call   *%esi
				num = -(long long) num;
  800715:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800718:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80071b:	f7 da                	neg    %edx
  80071d:	83 d1 00             	adc    $0x0,%ecx
  800720:	f7 d9                	neg    %ecx
  800722:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800725:	b8 0a 00 00 00       	mov    $0xa,%eax
  80072a:	e9 ec 00 00 00       	jmp    80081b <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80072f:	83 f9 01             	cmp    $0x1,%ecx
  800732:	7e 18                	jle    80074c <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800734:	8b 45 14             	mov    0x14(%ebp),%eax
  800737:	8b 10                	mov    (%eax),%edx
  800739:	8b 48 04             	mov    0x4(%eax),%ecx
  80073c:	8d 40 08             	lea    0x8(%eax),%eax
  80073f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800742:	b8 0a 00 00 00       	mov    $0xa,%eax
  800747:	e9 cf 00 00 00       	jmp    80081b <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80074c:	85 c9                	test   %ecx,%ecx
  80074e:	74 1a                	je     80076a <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800750:	8b 45 14             	mov    0x14(%ebp),%eax
  800753:	8b 10                	mov    (%eax),%edx
  800755:	b9 00 00 00 00       	mov    $0x0,%ecx
  80075a:	8d 40 04             	lea    0x4(%eax),%eax
  80075d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800760:	b8 0a 00 00 00       	mov    $0xa,%eax
  800765:	e9 b1 00 00 00       	jmp    80081b <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80076a:	8b 45 14             	mov    0x14(%ebp),%eax
  80076d:	8b 10                	mov    (%eax),%edx
  80076f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800774:	8d 40 04             	lea    0x4(%eax),%eax
  800777:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80077a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80077f:	e9 97 00 00 00       	jmp    80081b <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800784:	83 ec 08             	sub    $0x8,%esp
  800787:	53                   	push   %ebx
  800788:	6a 58                	push   $0x58
  80078a:	ff d6                	call   *%esi
			putch('X', putdat);
  80078c:	83 c4 08             	add    $0x8,%esp
  80078f:	53                   	push   %ebx
  800790:	6a 58                	push   $0x58
  800792:	ff d6                	call   *%esi
			putch('X', putdat);
  800794:	83 c4 08             	add    $0x8,%esp
  800797:	53                   	push   %ebx
  800798:	6a 58                	push   $0x58
  80079a:	ff d6                	call   *%esi
			break;
  80079c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8007a2:	e9 8b fc ff ff       	jmp    800432 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8007a7:	83 ec 08             	sub    $0x8,%esp
  8007aa:	53                   	push   %ebx
  8007ab:	6a 30                	push   $0x30
  8007ad:	ff d6                	call   *%esi
			putch('x', putdat);
  8007af:	83 c4 08             	add    $0x8,%esp
  8007b2:	53                   	push   %ebx
  8007b3:	6a 78                	push   $0x78
  8007b5:	ff d6                	call   *%esi
			num = (unsigned long long)
  8007b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ba:	8b 10                	mov    (%eax),%edx
  8007bc:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007c1:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007c4:	8d 40 04             	lea    0x4(%eax),%eax
  8007c7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007ca:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007cf:	eb 4a                	jmp    80081b <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007d1:	83 f9 01             	cmp    $0x1,%ecx
  8007d4:	7e 15                	jle    8007eb <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8007d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d9:	8b 10                	mov    (%eax),%edx
  8007db:	8b 48 04             	mov    0x4(%eax),%ecx
  8007de:	8d 40 08             	lea    0x8(%eax),%eax
  8007e1:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8007e4:	b8 10 00 00 00       	mov    $0x10,%eax
  8007e9:	eb 30                	jmp    80081b <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8007eb:	85 c9                	test   %ecx,%ecx
  8007ed:	74 17                	je     800806 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8007ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f2:	8b 10                	mov    (%eax),%edx
  8007f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007f9:	8d 40 04             	lea    0x4(%eax),%eax
  8007fc:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8007ff:	b8 10 00 00 00       	mov    $0x10,%eax
  800804:	eb 15                	jmp    80081b <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800806:	8b 45 14             	mov    0x14(%ebp),%eax
  800809:	8b 10                	mov    (%eax),%edx
  80080b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800810:	8d 40 04             	lea    0x4(%eax),%eax
  800813:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800816:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80081b:	83 ec 0c             	sub    $0xc,%esp
  80081e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800822:	57                   	push   %edi
  800823:	ff 75 e0             	pushl  -0x20(%ebp)
  800826:	50                   	push   %eax
  800827:	51                   	push   %ecx
  800828:	52                   	push   %edx
  800829:	89 da                	mov    %ebx,%edx
  80082b:	89 f0                	mov    %esi,%eax
  80082d:	e8 f1 fa ff ff       	call   800323 <printnum>
			break;
  800832:	83 c4 20             	add    $0x20,%esp
  800835:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800838:	e9 f5 fb ff ff       	jmp    800432 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80083d:	83 ec 08             	sub    $0x8,%esp
  800840:	53                   	push   %ebx
  800841:	52                   	push   %edx
  800842:	ff d6                	call   *%esi
			break;
  800844:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800847:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80084a:	e9 e3 fb ff ff       	jmp    800432 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80084f:	83 ec 08             	sub    $0x8,%esp
  800852:	53                   	push   %ebx
  800853:	6a 25                	push   $0x25
  800855:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800857:	83 c4 10             	add    $0x10,%esp
  80085a:	eb 03                	jmp    80085f <vprintfmt+0x453>
  80085c:	83 ef 01             	sub    $0x1,%edi
  80085f:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800863:	75 f7                	jne    80085c <vprintfmt+0x450>
  800865:	e9 c8 fb ff ff       	jmp    800432 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80086a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80086d:	5b                   	pop    %ebx
  80086e:	5e                   	pop    %esi
  80086f:	5f                   	pop    %edi
  800870:	5d                   	pop    %ebp
  800871:	c3                   	ret    

00800872 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	83 ec 18             	sub    $0x18,%esp
  800878:	8b 45 08             	mov    0x8(%ebp),%eax
  80087b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80087e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800881:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800885:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800888:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80088f:	85 c0                	test   %eax,%eax
  800891:	74 26                	je     8008b9 <vsnprintf+0x47>
  800893:	85 d2                	test   %edx,%edx
  800895:	7e 22                	jle    8008b9 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800897:	ff 75 14             	pushl  0x14(%ebp)
  80089a:	ff 75 10             	pushl  0x10(%ebp)
  80089d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008a0:	50                   	push   %eax
  8008a1:	68 d2 03 80 00       	push   $0x8003d2
  8008a6:	e8 61 fb ff ff       	call   80040c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008ae:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008b4:	83 c4 10             	add    $0x10,%esp
  8008b7:	eb 05                	jmp    8008be <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008be:	c9                   	leave  
  8008bf:	c3                   	ret    

008008c0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008c6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008c9:	50                   	push   %eax
  8008ca:	ff 75 10             	pushl  0x10(%ebp)
  8008cd:	ff 75 0c             	pushl  0xc(%ebp)
  8008d0:	ff 75 08             	pushl  0x8(%ebp)
  8008d3:	e8 9a ff ff ff       	call   800872 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008d8:	c9                   	leave  
  8008d9:	c3                   	ret    

008008da <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008da:	55                   	push   %ebp
  8008db:	89 e5                	mov    %esp,%ebp
  8008dd:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e5:	eb 03                	jmp    8008ea <strlen+0x10>
		n++;
  8008e7:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008ea:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008ee:	75 f7                	jne    8008e7 <strlen+0xd>
		n++;
	return n;
}
  8008f0:	5d                   	pop    %ebp
  8008f1:	c3                   	ret    

008008f2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008f8:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008fb:	ba 00 00 00 00       	mov    $0x0,%edx
  800900:	eb 03                	jmp    800905 <strnlen+0x13>
		n++;
  800902:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800905:	39 c2                	cmp    %eax,%edx
  800907:	74 08                	je     800911 <strnlen+0x1f>
  800909:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80090d:	75 f3                	jne    800902 <strnlen+0x10>
  80090f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800911:	5d                   	pop    %ebp
  800912:	c3                   	ret    

00800913 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800913:	55                   	push   %ebp
  800914:	89 e5                	mov    %esp,%ebp
  800916:	53                   	push   %ebx
  800917:	8b 45 08             	mov    0x8(%ebp),%eax
  80091a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80091d:	89 c2                	mov    %eax,%edx
  80091f:	83 c2 01             	add    $0x1,%edx
  800922:	83 c1 01             	add    $0x1,%ecx
  800925:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800929:	88 5a ff             	mov    %bl,-0x1(%edx)
  80092c:	84 db                	test   %bl,%bl
  80092e:	75 ef                	jne    80091f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800930:	5b                   	pop    %ebx
  800931:	5d                   	pop    %ebp
  800932:	c3                   	ret    

00800933 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
  800936:	53                   	push   %ebx
  800937:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80093a:	53                   	push   %ebx
  80093b:	e8 9a ff ff ff       	call   8008da <strlen>
  800940:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800943:	ff 75 0c             	pushl  0xc(%ebp)
  800946:	01 d8                	add    %ebx,%eax
  800948:	50                   	push   %eax
  800949:	e8 c5 ff ff ff       	call   800913 <strcpy>
	return dst;
}
  80094e:	89 d8                	mov    %ebx,%eax
  800950:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800953:	c9                   	leave  
  800954:	c3                   	ret    

00800955 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	56                   	push   %esi
  800959:	53                   	push   %ebx
  80095a:	8b 75 08             	mov    0x8(%ebp),%esi
  80095d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800960:	89 f3                	mov    %esi,%ebx
  800962:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800965:	89 f2                	mov    %esi,%edx
  800967:	eb 0f                	jmp    800978 <strncpy+0x23>
		*dst++ = *src;
  800969:	83 c2 01             	add    $0x1,%edx
  80096c:	0f b6 01             	movzbl (%ecx),%eax
  80096f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800972:	80 39 01             	cmpb   $0x1,(%ecx)
  800975:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800978:	39 da                	cmp    %ebx,%edx
  80097a:	75 ed                	jne    800969 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80097c:	89 f0                	mov    %esi,%eax
  80097e:	5b                   	pop    %ebx
  80097f:	5e                   	pop    %esi
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	56                   	push   %esi
  800986:	53                   	push   %ebx
  800987:	8b 75 08             	mov    0x8(%ebp),%esi
  80098a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80098d:	8b 55 10             	mov    0x10(%ebp),%edx
  800990:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800992:	85 d2                	test   %edx,%edx
  800994:	74 21                	je     8009b7 <strlcpy+0x35>
  800996:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80099a:	89 f2                	mov    %esi,%edx
  80099c:	eb 09                	jmp    8009a7 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80099e:	83 c2 01             	add    $0x1,%edx
  8009a1:	83 c1 01             	add    $0x1,%ecx
  8009a4:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009a7:	39 c2                	cmp    %eax,%edx
  8009a9:	74 09                	je     8009b4 <strlcpy+0x32>
  8009ab:	0f b6 19             	movzbl (%ecx),%ebx
  8009ae:	84 db                	test   %bl,%bl
  8009b0:	75 ec                	jne    80099e <strlcpy+0x1c>
  8009b2:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009b4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009b7:	29 f0                	sub    %esi,%eax
}
  8009b9:	5b                   	pop    %ebx
  8009ba:	5e                   	pop    %esi
  8009bb:	5d                   	pop    %ebp
  8009bc:	c3                   	ret    

008009bd <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009c3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009c6:	eb 06                	jmp    8009ce <strcmp+0x11>
		p++, q++;
  8009c8:	83 c1 01             	add    $0x1,%ecx
  8009cb:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009ce:	0f b6 01             	movzbl (%ecx),%eax
  8009d1:	84 c0                	test   %al,%al
  8009d3:	74 04                	je     8009d9 <strcmp+0x1c>
  8009d5:	3a 02                	cmp    (%edx),%al
  8009d7:	74 ef                	je     8009c8 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009d9:	0f b6 c0             	movzbl %al,%eax
  8009dc:	0f b6 12             	movzbl (%edx),%edx
  8009df:	29 d0                	sub    %edx,%eax
}
  8009e1:	5d                   	pop    %ebp
  8009e2:	c3                   	ret    

008009e3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009e3:	55                   	push   %ebp
  8009e4:	89 e5                	mov    %esp,%ebp
  8009e6:	53                   	push   %ebx
  8009e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ed:	89 c3                	mov    %eax,%ebx
  8009ef:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009f2:	eb 06                	jmp    8009fa <strncmp+0x17>
		n--, p++, q++;
  8009f4:	83 c0 01             	add    $0x1,%eax
  8009f7:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009fa:	39 d8                	cmp    %ebx,%eax
  8009fc:	74 15                	je     800a13 <strncmp+0x30>
  8009fe:	0f b6 08             	movzbl (%eax),%ecx
  800a01:	84 c9                	test   %cl,%cl
  800a03:	74 04                	je     800a09 <strncmp+0x26>
  800a05:	3a 0a                	cmp    (%edx),%cl
  800a07:	74 eb                	je     8009f4 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a09:	0f b6 00             	movzbl (%eax),%eax
  800a0c:	0f b6 12             	movzbl (%edx),%edx
  800a0f:	29 d0                	sub    %edx,%eax
  800a11:	eb 05                	jmp    800a18 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a13:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a18:	5b                   	pop    %ebx
  800a19:	5d                   	pop    %ebp
  800a1a:	c3                   	ret    

00800a1b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a1b:	55                   	push   %ebp
  800a1c:	89 e5                	mov    %esp,%ebp
  800a1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a21:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a25:	eb 07                	jmp    800a2e <strchr+0x13>
		if (*s == c)
  800a27:	38 ca                	cmp    %cl,%dl
  800a29:	74 0f                	je     800a3a <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a2b:	83 c0 01             	add    $0x1,%eax
  800a2e:	0f b6 10             	movzbl (%eax),%edx
  800a31:	84 d2                	test   %dl,%dl
  800a33:	75 f2                	jne    800a27 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a35:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a3a:	5d                   	pop    %ebp
  800a3b:	c3                   	ret    

00800a3c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a3c:	55                   	push   %ebp
  800a3d:	89 e5                	mov    %esp,%ebp
  800a3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a42:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a46:	eb 03                	jmp    800a4b <strfind+0xf>
  800a48:	83 c0 01             	add    $0x1,%eax
  800a4b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a4e:	38 ca                	cmp    %cl,%dl
  800a50:	74 04                	je     800a56 <strfind+0x1a>
  800a52:	84 d2                	test   %dl,%dl
  800a54:	75 f2                	jne    800a48 <strfind+0xc>
			break;
	return (char *) s;
}
  800a56:	5d                   	pop    %ebp
  800a57:	c3                   	ret    

00800a58 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a58:	55                   	push   %ebp
  800a59:	89 e5                	mov    %esp,%ebp
  800a5b:	57                   	push   %edi
  800a5c:	56                   	push   %esi
  800a5d:	53                   	push   %ebx
  800a5e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a61:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a64:	85 c9                	test   %ecx,%ecx
  800a66:	74 36                	je     800a9e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a68:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a6e:	75 28                	jne    800a98 <memset+0x40>
  800a70:	f6 c1 03             	test   $0x3,%cl
  800a73:	75 23                	jne    800a98 <memset+0x40>
		c &= 0xFF;
  800a75:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a79:	89 d3                	mov    %edx,%ebx
  800a7b:	c1 e3 08             	shl    $0x8,%ebx
  800a7e:	89 d6                	mov    %edx,%esi
  800a80:	c1 e6 18             	shl    $0x18,%esi
  800a83:	89 d0                	mov    %edx,%eax
  800a85:	c1 e0 10             	shl    $0x10,%eax
  800a88:	09 f0                	or     %esi,%eax
  800a8a:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a8c:	89 d8                	mov    %ebx,%eax
  800a8e:	09 d0                	or     %edx,%eax
  800a90:	c1 e9 02             	shr    $0x2,%ecx
  800a93:	fc                   	cld    
  800a94:	f3 ab                	rep stos %eax,%es:(%edi)
  800a96:	eb 06                	jmp    800a9e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a98:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9b:	fc                   	cld    
  800a9c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a9e:	89 f8                	mov    %edi,%eax
  800aa0:	5b                   	pop    %ebx
  800aa1:	5e                   	pop    %esi
  800aa2:	5f                   	pop    %edi
  800aa3:	5d                   	pop    %ebp
  800aa4:	c3                   	ret    

00800aa5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800aa5:	55                   	push   %ebp
  800aa6:	89 e5                	mov    %esp,%ebp
  800aa8:	57                   	push   %edi
  800aa9:	56                   	push   %esi
  800aaa:	8b 45 08             	mov    0x8(%ebp),%eax
  800aad:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ab0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ab3:	39 c6                	cmp    %eax,%esi
  800ab5:	73 35                	jae    800aec <memmove+0x47>
  800ab7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aba:	39 d0                	cmp    %edx,%eax
  800abc:	73 2e                	jae    800aec <memmove+0x47>
		s += n;
		d += n;
  800abe:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac1:	89 d6                	mov    %edx,%esi
  800ac3:	09 fe                	or     %edi,%esi
  800ac5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800acb:	75 13                	jne    800ae0 <memmove+0x3b>
  800acd:	f6 c1 03             	test   $0x3,%cl
  800ad0:	75 0e                	jne    800ae0 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800ad2:	83 ef 04             	sub    $0x4,%edi
  800ad5:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ad8:	c1 e9 02             	shr    $0x2,%ecx
  800adb:	fd                   	std    
  800adc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ade:	eb 09                	jmp    800ae9 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ae0:	83 ef 01             	sub    $0x1,%edi
  800ae3:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ae6:	fd                   	std    
  800ae7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ae9:	fc                   	cld    
  800aea:	eb 1d                	jmp    800b09 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aec:	89 f2                	mov    %esi,%edx
  800aee:	09 c2                	or     %eax,%edx
  800af0:	f6 c2 03             	test   $0x3,%dl
  800af3:	75 0f                	jne    800b04 <memmove+0x5f>
  800af5:	f6 c1 03             	test   $0x3,%cl
  800af8:	75 0a                	jne    800b04 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800afa:	c1 e9 02             	shr    $0x2,%ecx
  800afd:	89 c7                	mov    %eax,%edi
  800aff:	fc                   	cld    
  800b00:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b02:	eb 05                	jmp    800b09 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b04:	89 c7                	mov    %eax,%edi
  800b06:	fc                   	cld    
  800b07:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b09:	5e                   	pop    %esi
  800b0a:	5f                   	pop    %edi
  800b0b:	5d                   	pop    %ebp
  800b0c:	c3                   	ret    

00800b0d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b0d:	55                   	push   %ebp
  800b0e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b10:	ff 75 10             	pushl  0x10(%ebp)
  800b13:	ff 75 0c             	pushl  0xc(%ebp)
  800b16:	ff 75 08             	pushl  0x8(%ebp)
  800b19:	e8 87 ff ff ff       	call   800aa5 <memmove>
}
  800b1e:	c9                   	leave  
  800b1f:	c3                   	ret    

00800b20 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	56                   	push   %esi
  800b24:	53                   	push   %ebx
  800b25:	8b 45 08             	mov    0x8(%ebp),%eax
  800b28:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b2b:	89 c6                	mov    %eax,%esi
  800b2d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b30:	eb 1a                	jmp    800b4c <memcmp+0x2c>
		if (*s1 != *s2)
  800b32:	0f b6 08             	movzbl (%eax),%ecx
  800b35:	0f b6 1a             	movzbl (%edx),%ebx
  800b38:	38 d9                	cmp    %bl,%cl
  800b3a:	74 0a                	je     800b46 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b3c:	0f b6 c1             	movzbl %cl,%eax
  800b3f:	0f b6 db             	movzbl %bl,%ebx
  800b42:	29 d8                	sub    %ebx,%eax
  800b44:	eb 0f                	jmp    800b55 <memcmp+0x35>
		s1++, s2++;
  800b46:	83 c0 01             	add    $0x1,%eax
  800b49:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b4c:	39 f0                	cmp    %esi,%eax
  800b4e:	75 e2                	jne    800b32 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b50:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b55:	5b                   	pop    %ebx
  800b56:	5e                   	pop    %esi
  800b57:	5d                   	pop    %ebp
  800b58:	c3                   	ret    

00800b59 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b59:	55                   	push   %ebp
  800b5a:	89 e5                	mov    %esp,%ebp
  800b5c:	53                   	push   %ebx
  800b5d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b60:	89 c1                	mov    %eax,%ecx
  800b62:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b65:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b69:	eb 0a                	jmp    800b75 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b6b:	0f b6 10             	movzbl (%eax),%edx
  800b6e:	39 da                	cmp    %ebx,%edx
  800b70:	74 07                	je     800b79 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b72:	83 c0 01             	add    $0x1,%eax
  800b75:	39 c8                	cmp    %ecx,%eax
  800b77:	72 f2                	jb     800b6b <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b79:	5b                   	pop    %ebx
  800b7a:	5d                   	pop    %ebp
  800b7b:	c3                   	ret    

00800b7c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	57                   	push   %edi
  800b80:	56                   	push   %esi
  800b81:	53                   	push   %ebx
  800b82:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b85:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b88:	eb 03                	jmp    800b8d <strtol+0x11>
		s++;
  800b8a:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b8d:	0f b6 01             	movzbl (%ecx),%eax
  800b90:	3c 20                	cmp    $0x20,%al
  800b92:	74 f6                	je     800b8a <strtol+0xe>
  800b94:	3c 09                	cmp    $0x9,%al
  800b96:	74 f2                	je     800b8a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b98:	3c 2b                	cmp    $0x2b,%al
  800b9a:	75 0a                	jne    800ba6 <strtol+0x2a>
		s++;
  800b9c:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b9f:	bf 00 00 00 00       	mov    $0x0,%edi
  800ba4:	eb 11                	jmp    800bb7 <strtol+0x3b>
  800ba6:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bab:	3c 2d                	cmp    $0x2d,%al
  800bad:	75 08                	jne    800bb7 <strtol+0x3b>
		s++, neg = 1;
  800baf:	83 c1 01             	add    $0x1,%ecx
  800bb2:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bb7:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bbd:	75 15                	jne    800bd4 <strtol+0x58>
  800bbf:	80 39 30             	cmpb   $0x30,(%ecx)
  800bc2:	75 10                	jne    800bd4 <strtol+0x58>
  800bc4:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bc8:	75 7c                	jne    800c46 <strtol+0xca>
		s += 2, base = 16;
  800bca:	83 c1 02             	add    $0x2,%ecx
  800bcd:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bd2:	eb 16                	jmp    800bea <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800bd4:	85 db                	test   %ebx,%ebx
  800bd6:	75 12                	jne    800bea <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bd8:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bdd:	80 39 30             	cmpb   $0x30,(%ecx)
  800be0:	75 08                	jne    800bea <strtol+0x6e>
		s++, base = 8;
  800be2:	83 c1 01             	add    $0x1,%ecx
  800be5:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800bea:	b8 00 00 00 00       	mov    $0x0,%eax
  800bef:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bf2:	0f b6 11             	movzbl (%ecx),%edx
  800bf5:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bf8:	89 f3                	mov    %esi,%ebx
  800bfa:	80 fb 09             	cmp    $0x9,%bl
  800bfd:	77 08                	ja     800c07 <strtol+0x8b>
			dig = *s - '0';
  800bff:	0f be d2             	movsbl %dl,%edx
  800c02:	83 ea 30             	sub    $0x30,%edx
  800c05:	eb 22                	jmp    800c29 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c07:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c0a:	89 f3                	mov    %esi,%ebx
  800c0c:	80 fb 19             	cmp    $0x19,%bl
  800c0f:	77 08                	ja     800c19 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c11:	0f be d2             	movsbl %dl,%edx
  800c14:	83 ea 57             	sub    $0x57,%edx
  800c17:	eb 10                	jmp    800c29 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c19:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c1c:	89 f3                	mov    %esi,%ebx
  800c1e:	80 fb 19             	cmp    $0x19,%bl
  800c21:	77 16                	ja     800c39 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c23:	0f be d2             	movsbl %dl,%edx
  800c26:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c29:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c2c:	7d 0b                	jge    800c39 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c2e:	83 c1 01             	add    $0x1,%ecx
  800c31:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c35:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c37:	eb b9                	jmp    800bf2 <strtol+0x76>

	if (endptr)
  800c39:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c3d:	74 0d                	je     800c4c <strtol+0xd0>
		*endptr = (char *) s;
  800c3f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c42:	89 0e                	mov    %ecx,(%esi)
  800c44:	eb 06                	jmp    800c4c <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c46:	85 db                	test   %ebx,%ebx
  800c48:	74 98                	je     800be2 <strtol+0x66>
  800c4a:	eb 9e                	jmp    800bea <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c4c:	89 c2                	mov    %eax,%edx
  800c4e:	f7 da                	neg    %edx
  800c50:	85 ff                	test   %edi,%edi
  800c52:	0f 45 c2             	cmovne %edx,%eax
}
  800c55:	5b                   	pop    %ebx
  800c56:	5e                   	pop    %esi
  800c57:	5f                   	pop    %edi
  800c58:	5d                   	pop    %ebp
  800c59:	c3                   	ret    

00800c5a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	57                   	push   %edi
  800c5e:	56                   	push   %esi
  800c5f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c60:	b8 00 00 00 00       	mov    $0x0,%eax
  800c65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c68:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6b:	89 c3                	mov    %eax,%ebx
  800c6d:	89 c7                	mov    %eax,%edi
  800c6f:	89 c6                	mov    %eax,%esi
  800c71:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c73:	5b                   	pop    %ebx
  800c74:	5e                   	pop    %esi
  800c75:	5f                   	pop    %edi
  800c76:	5d                   	pop    %ebp
  800c77:	c3                   	ret    

00800c78 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c78:	55                   	push   %ebp
  800c79:	89 e5                	mov    %esp,%ebp
  800c7b:	57                   	push   %edi
  800c7c:	56                   	push   %esi
  800c7d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c83:	b8 01 00 00 00       	mov    $0x1,%eax
  800c88:	89 d1                	mov    %edx,%ecx
  800c8a:	89 d3                	mov    %edx,%ebx
  800c8c:	89 d7                	mov    %edx,%edi
  800c8e:	89 d6                	mov    %edx,%esi
  800c90:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c92:	5b                   	pop    %ebx
  800c93:	5e                   	pop    %esi
  800c94:	5f                   	pop    %edi
  800c95:	5d                   	pop    %ebp
  800c96:	c3                   	ret    

00800c97 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	57                   	push   %edi
  800c9b:	56                   	push   %esi
  800c9c:	53                   	push   %ebx
  800c9d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ca5:	b8 03 00 00 00       	mov    $0x3,%eax
  800caa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cad:	89 cb                	mov    %ecx,%ebx
  800caf:	89 cf                	mov    %ecx,%edi
  800cb1:	89 ce                	mov    %ecx,%esi
  800cb3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb5:	85 c0                	test   %eax,%eax
  800cb7:	7e 17                	jle    800cd0 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb9:	83 ec 0c             	sub    $0xc,%esp
  800cbc:	50                   	push   %eax
  800cbd:	6a 03                	push   $0x3
  800cbf:	68 7f 26 80 00       	push   $0x80267f
  800cc4:	6a 23                	push   $0x23
  800cc6:	68 9c 26 80 00       	push   $0x80269c
  800ccb:	e8 66 f5 ff ff       	call   800236 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd3:	5b                   	pop    %ebx
  800cd4:	5e                   	pop    %esi
  800cd5:	5f                   	pop    %edi
  800cd6:	5d                   	pop    %ebp
  800cd7:	c3                   	ret    

00800cd8 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cd8:	55                   	push   %ebp
  800cd9:	89 e5                	mov    %esp,%ebp
  800cdb:	57                   	push   %edi
  800cdc:	56                   	push   %esi
  800cdd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cde:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce3:	b8 02 00 00 00       	mov    $0x2,%eax
  800ce8:	89 d1                	mov    %edx,%ecx
  800cea:	89 d3                	mov    %edx,%ebx
  800cec:	89 d7                	mov    %edx,%edi
  800cee:	89 d6                	mov    %edx,%esi
  800cf0:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cf2:	5b                   	pop    %ebx
  800cf3:	5e                   	pop    %esi
  800cf4:	5f                   	pop    %edi
  800cf5:	5d                   	pop    %ebp
  800cf6:	c3                   	ret    

00800cf7 <sys_yield>:

void
sys_yield(void)
{
  800cf7:	55                   	push   %ebp
  800cf8:	89 e5                	mov    %esp,%ebp
  800cfa:	57                   	push   %edi
  800cfb:	56                   	push   %esi
  800cfc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfd:	ba 00 00 00 00       	mov    $0x0,%edx
  800d02:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d07:	89 d1                	mov    %edx,%ecx
  800d09:	89 d3                	mov    %edx,%ebx
  800d0b:	89 d7                	mov    %edx,%edi
  800d0d:	89 d6                	mov    %edx,%esi
  800d0f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d11:	5b                   	pop    %ebx
  800d12:	5e                   	pop    %esi
  800d13:	5f                   	pop    %edi
  800d14:	5d                   	pop    %ebp
  800d15:	c3                   	ret    

00800d16 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d16:	55                   	push   %ebp
  800d17:	89 e5                	mov    %esp,%ebp
  800d19:	57                   	push   %edi
  800d1a:	56                   	push   %esi
  800d1b:	53                   	push   %ebx
  800d1c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1f:	be 00 00 00 00       	mov    $0x0,%esi
  800d24:	b8 04 00 00 00       	mov    $0x4,%eax
  800d29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d32:	89 f7                	mov    %esi,%edi
  800d34:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d36:	85 c0                	test   %eax,%eax
  800d38:	7e 17                	jle    800d51 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3a:	83 ec 0c             	sub    $0xc,%esp
  800d3d:	50                   	push   %eax
  800d3e:	6a 04                	push   $0x4
  800d40:	68 7f 26 80 00       	push   $0x80267f
  800d45:	6a 23                	push   $0x23
  800d47:	68 9c 26 80 00       	push   $0x80269c
  800d4c:	e8 e5 f4 ff ff       	call   800236 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d54:	5b                   	pop    %ebx
  800d55:	5e                   	pop    %esi
  800d56:	5f                   	pop    %edi
  800d57:	5d                   	pop    %ebp
  800d58:	c3                   	ret    

00800d59 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d59:	55                   	push   %ebp
  800d5a:	89 e5                	mov    %esp,%ebp
  800d5c:	57                   	push   %edi
  800d5d:	56                   	push   %esi
  800d5e:	53                   	push   %ebx
  800d5f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d62:	b8 05 00 00 00       	mov    $0x5,%eax
  800d67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d70:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d73:	8b 75 18             	mov    0x18(%ebp),%esi
  800d76:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d78:	85 c0                	test   %eax,%eax
  800d7a:	7e 17                	jle    800d93 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7c:	83 ec 0c             	sub    $0xc,%esp
  800d7f:	50                   	push   %eax
  800d80:	6a 05                	push   $0x5
  800d82:	68 7f 26 80 00       	push   $0x80267f
  800d87:	6a 23                	push   $0x23
  800d89:	68 9c 26 80 00       	push   $0x80269c
  800d8e:	e8 a3 f4 ff ff       	call   800236 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d96:	5b                   	pop    %ebx
  800d97:	5e                   	pop    %esi
  800d98:	5f                   	pop    %edi
  800d99:	5d                   	pop    %ebp
  800d9a:	c3                   	ret    

00800d9b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d9b:	55                   	push   %ebp
  800d9c:	89 e5                	mov    %esp,%ebp
  800d9e:	57                   	push   %edi
  800d9f:	56                   	push   %esi
  800da0:	53                   	push   %ebx
  800da1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da9:	b8 06 00 00 00       	mov    $0x6,%eax
  800dae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db1:	8b 55 08             	mov    0x8(%ebp),%edx
  800db4:	89 df                	mov    %ebx,%edi
  800db6:	89 de                	mov    %ebx,%esi
  800db8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dba:	85 c0                	test   %eax,%eax
  800dbc:	7e 17                	jle    800dd5 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dbe:	83 ec 0c             	sub    $0xc,%esp
  800dc1:	50                   	push   %eax
  800dc2:	6a 06                	push   $0x6
  800dc4:	68 7f 26 80 00       	push   $0x80267f
  800dc9:	6a 23                	push   $0x23
  800dcb:	68 9c 26 80 00       	push   $0x80269c
  800dd0:	e8 61 f4 ff ff       	call   800236 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dd5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd8:	5b                   	pop    %ebx
  800dd9:	5e                   	pop    %esi
  800dda:	5f                   	pop    %edi
  800ddb:	5d                   	pop    %ebp
  800ddc:	c3                   	ret    

00800ddd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ddd:	55                   	push   %ebp
  800dde:	89 e5                	mov    %esp,%ebp
  800de0:	57                   	push   %edi
  800de1:	56                   	push   %esi
  800de2:	53                   	push   %ebx
  800de3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800deb:	b8 08 00 00 00       	mov    $0x8,%eax
  800df0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df3:	8b 55 08             	mov    0x8(%ebp),%edx
  800df6:	89 df                	mov    %ebx,%edi
  800df8:	89 de                	mov    %ebx,%esi
  800dfa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dfc:	85 c0                	test   %eax,%eax
  800dfe:	7e 17                	jle    800e17 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e00:	83 ec 0c             	sub    $0xc,%esp
  800e03:	50                   	push   %eax
  800e04:	6a 08                	push   $0x8
  800e06:	68 7f 26 80 00       	push   $0x80267f
  800e0b:	6a 23                	push   $0x23
  800e0d:	68 9c 26 80 00       	push   $0x80269c
  800e12:	e8 1f f4 ff ff       	call   800236 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e17:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1a:	5b                   	pop    %ebx
  800e1b:	5e                   	pop    %esi
  800e1c:	5f                   	pop    %edi
  800e1d:	5d                   	pop    %ebp
  800e1e:	c3                   	ret    

00800e1f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e1f:	55                   	push   %ebp
  800e20:	89 e5                	mov    %esp,%ebp
  800e22:	57                   	push   %edi
  800e23:	56                   	push   %esi
  800e24:	53                   	push   %ebx
  800e25:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e28:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e2d:	b8 09 00 00 00       	mov    $0x9,%eax
  800e32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e35:	8b 55 08             	mov    0x8(%ebp),%edx
  800e38:	89 df                	mov    %ebx,%edi
  800e3a:	89 de                	mov    %ebx,%esi
  800e3c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e3e:	85 c0                	test   %eax,%eax
  800e40:	7e 17                	jle    800e59 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e42:	83 ec 0c             	sub    $0xc,%esp
  800e45:	50                   	push   %eax
  800e46:	6a 09                	push   $0x9
  800e48:	68 7f 26 80 00       	push   $0x80267f
  800e4d:	6a 23                	push   $0x23
  800e4f:	68 9c 26 80 00       	push   $0x80269c
  800e54:	e8 dd f3 ff ff       	call   800236 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e5c:	5b                   	pop    %ebx
  800e5d:	5e                   	pop    %esi
  800e5e:	5f                   	pop    %edi
  800e5f:	5d                   	pop    %ebp
  800e60:	c3                   	ret    

00800e61 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e61:	55                   	push   %ebp
  800e62:	89 e5                	mov    %esp,%ebp
  800e64:	57                   	push   %edi
  800e65:	56                   	push   %esi
  800e66:	53                   	push   %ebx
  800e67:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e6f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e77:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7a:	89 df                	mov    %ebx,%edi
  800e7c:	89 de                	mov    %ebx,%esi
  800e7e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e80:	85 c0                	test   %eax,%eax
  800e82:	7e 17                	jle    800e9b <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e84:	83 ec 0c             	sub    $0xc,%esp
  800e87:	50                   	push   %eax
  800e88:	6a 0a                	push   $0xa
  800e8a:	68 7f 26 80 00       	push   $0x80267f
  800e8f:	6a 23                	push   $0x23
  800e91:	68 9c 26 80 00       	push   $0x80269c
  800e96:	e8 9b f3 ff ff       	call   800236 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e9e:	5b                   	pop    %ebx
  800e9f:	5e                   	pop    %esi
  800ea0:	5f                   	pop    %edi
  800ea1:	5d                   	pop    %ebp
  800ea2:	c3                   	ret    

00800ea3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
  800ea6:	57                   	push   %edi
  800ea7:	56                   	push   %esi
  800ea8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea9:	be 00 00 00 00       	mov    $0x0,%esi
  800eae:	b8 0c 00 00 00       	mov    $0xc,%eax
  800eb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ebc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ebf:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ec1:	5b                   	pop    %ebx
  800ec2:	5e                   	pop    %esi
  800ec3:	5f                   	pop    %edi
  800ec4:	5d                   	pop    %ebp
  800ec5:	c3                   	ret    

00800ec6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ec6:	55                   	push   %ebp
  800ec7:	89 e5                	mov    %esp,%ebp
  800ec9:	57                   	push   %edi
  800eca:	56                   	push   %esi
  800ecb:	53                   	push   %ebx
  800ecc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ecf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ed4:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ed9:	8b 55 08             	mov    0x8(%ebp),%edx
  800edc:	89 cb                	mov    %ecx,%ebx
  800ede:	89 cf                	mov    %ecx,%edi
  800ee0:	89 ce                	mov    %ecx,%esi
  800ee2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ee4:	85 c0                	test   %eax,%eax
  800ee6:	7e 17                	jle    800eff <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee8:	83 ec 0c             	sub    $0xc,%esp
  800eeb:	50                   	push   %eax
  800eec:	6a 0d                	push   $0xd
  800eee:	68 7f 26 80 00       	push   $0x80267f
  800ef3:	6a 23                	push   $0x23
  800ef5:	68 9c 26 80 00       	push   $0x80269c
  800efa:	e8 37 f3 ff ff       	call   800236 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800eff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f02:	5b                   	pop    %ebx
  800f03:	5e                   	pop    %esi
  800f04:	5f                   	pop    %edi
  800f05:	5d                   	pop    %ebp
  800f06:	c3                   	ret    

00800f07 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f07:	55                   	push   %ebp
  800f08:	89 e5                	mov    %esp,%ebp
  800f0a:	57                   	push   %edi
  800f0b:	56                   	push   %esi
  800f0c:	53                   	push   %ebx
  800f0d:	83 ec 0c             	sub    $0xc,%esp
  800f10:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f13:	8b 18                	mov    (%eax),%ebx
	uint32_t err = utf->utf_err;
  800f15:	8b 78 04             	mov    0x4(%eax),%edi
	int r;
	envid_t curenvid = sys_getenvid();
  800f18:	e8 bb fd ff ff       	call   800cd8 <sys_getenvid>
  800f1d:	89 c6                	mov    %eax,%esi
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(err & FEC_WR) && !(uvpt[PGNUM(addr)] & PTE_COW))
  800f1f:	f7 c7 02 00 00 00    	test   $0x2,%edi
  800f25:	75 25                	jne    800f4c <pgfault+0x45>
  800f27:	89 d8                	mov    %ebx,%eax
  800f29:	c1 e8 0c             	shr    $0xc,%eax
  800f2c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f33:	f6 c4 08             	test   $0x8,%ah
  800f36:	75 14                	jne    800f4c <pgfault+0x45>
	    panic("pgfault error: wrong faulting access");
  800f38:	83 ec 04             	sub    $0x4,%esp
  800f3b:	68 ac 26 80 00       	push   $0x8026ac
  800f40:	6a 1e                	push   $0x1e
  800f42:	68 d1 26 80 00       	push   $0x8026d1
  800f47:	e8 ea f2 ff ff       	call   800236 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	sys_page_alloc(curenvid, PFTEMP, PTE_W | PTE_U | PTE_P);
  800f4c:	83 ec 04             	sub    $0x4,%esp
  800f4f:	6a 07                	push   $0x7
  800f51:	68 00 f0 7f 00       	push   $0x7ff000
  800f56:	56                   	push   %esi
  800f57:	e8 ba fd ff ff       	call   800d16 <sys_page_alloc>

	addr = (void *)(PGNUM(addr) * PGSIZE);
  800f5c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr, PGSIZE);
  800f62:	83 c4 0c             	add    $0xc,%esp
  800f65:	68 00 10 00 00       	push   $0x1000
  800f6a:	53                   	push   %ebx
  800f6b:	68 00 f0 7f 00       	push   $0x7ff000
  800f70:	e8 30 fb ff ff       	call   800aa5 <memmove>

	sys_page_unmap(curenvid, addr);
  800f75:	83 c4 08             	add    $0x8,%esp
  800f78:	53                   	push   %ebx
  800f79:	56                   	push   %esi
  800f7a:	e8 1c fe ff ff       	call   800d9b <sys_page_unmap>
	sys_page_map(curenvid, PFTEMP, curenvid, addr, PTE_W | PTE_U | PTE_P);
  800f7f:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f86:	53                   	push   %ebx
  800f87:	56                   	push   %esi
  800f88:	68 00 f0 7f 00       	push   $0x7ff000
  800f8d:	56                   	push   %esi
  800f8e:	e8 c6 fd ff ff       	call   800d59 <sys_page_map>
	sys_page_unmap(curenvid, PFTEMP);
  800f93:	83 c4 18             	add    $0x18,%esp
  800f96:	68 00 f0 7f 00       	push   $0x7ff000
  800f9b:	56                   	push   %esi
  800f9c:	e8 fa fd ff ff       	call   800d9b <sys_page_unmap>
}
  800fa1:	83 c4 10             	add    $0x10,%esp
  800fa4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fa7:	5b                   	pop    %ebx
  800fa8:	5e                   	pop    %esi
  800fa9:	5f                   	pop    %edi
  800faa:	5d                   	pop    %ebp
  800fab:	c3                   	ret    

00800fac <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fac:	55                   	push   %ebp
  800fad:	89 e5                	mov    %esp,%ebp
  800faf:	57                   	push   %edi
  800fb0:	56                   	push   %esi
  800fb1:	53                   	push   %ebx
  800fb2:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	extern void _pgfault_upcall();
	envid_t new_envid, curenv_id;

	curenv_id = sys_getenvid();
  800fb5:	e8 1e fd ff ff       	call   800cd8 <sys_getenvid>
	set_pgfault_handler(pgfault);
  800fba:	83 ec 0c             	sub    $0xc,%esp
  800fbd:	68 07 0f 80 00       	push   $0x800f07
  800fc2:	e8 83 0e 00 00       	call   801e4a <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800fc7:	b8 07 00 00 00       	mov    $0x7,%eax
  800fcc:	cd 30                	int    $0x30
  800fce:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800fd1:	89 45 dc             	mov    %eax,-0x24(%ebp)
	new_envid = sys_exofork();

	if (new_envid < 0)
  800fd4:	83 c4 10             	add    $0x10,%esp
  800fd7:	85 c0                	test   %eax,%eax
  800fd9:	79 12                	jns    800fed <fork+0x41>
	    panic("fork error: %e", new_envid);
  800fdb:	50                   	push   %eax
  800fdc:	68 dc 26 80 00       	push   $0x8026dc
  800fe1:	6a 75                	push   $0x75
  800fe3:	68 d1 26 80 00       	push   $0x8026d1
  800fe8:	e8 49 f2 ff ff       	call   800236 <_panic>
  800fed:	bf 00 00 80 00       	mov    $0x800000,%edi
	else if (new_envid == 0)
  800ff2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800ff6:	75 1c                	jne    801014 <fork+0x68>
		thisenv = envs + ENVX(sys_getenvid());
  800ff8:	e8 db fc ff ff       	call   800cd8 <sys_getenvid>
  800ffd:	25 ff 03 00 00       	and    $0x3ff,%eax
  801002:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801005:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80100a:	a3 04 40 80 00       	mov    %eax,0x804004
  80100f:	e9 27 01 00 00       	jmp    80113b <fork+0x18f>
	else {

		for (uint32_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
			if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
  801014:	89 f8                	mov    %edi,%eax
  801016:	c1 e8 16             	shr    $0x16,%eax
  801019:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801020:	a8 01                	test   $0x1,%al
  801022:	0f 84 d2 00 00 00    	je     8010fa <fork+0x14e>
  801028:	89 fb                	mov    %edi,%ebx
  80102a:	c1 eb 0c             	shr    $0xc,%ebx
  80102d:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801034:	a8 01                	test   $0x1,%al
  801036:	0f 84 be 00 00 00    	je     8010fa <fork+0x14e>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	int perm = PTE_U | PTE_P;
	envid_t curenvid = sys_getenvid();
  80103c:	e8 97 fc ff ff       	call   800cd8 <sys_getenvid>
  801041:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  801044:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
		perm |= PTE_COW ;
  80104b:	be 05 08 00 00       	mov    $0x805,%esi
	int r;
	int perm = PTE_U | PTE_P;
	envid_t curenvid = sys_getenvid();

	// LAB 4: Your code here.
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  801050:	a8 02                	test   $0x2,%al
  801052:	75 1d                	jne    801071 <fork+0xc5>
  801054:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80105b:	25 00 08 00 00       	and    $0x800,%eax
		perm |= PTE_COW ;
  801060:	83 f8 01             	cmp    $0x1,%eax
  801063:	19 f6                	sbb    %esi,%esi
  801065:	81 e6 00 f8 ff ff    	and    $0xfffff800,%esi
  80106b:	81 c6 05 08 00 00    	add    $0x805,%esi

	if (uvpt[pn] & PTE_SHARE)
  801071:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801078:	25 00 04 00 00       	and    $0x400,%eax
		perm |= PTE_SYSCALL;
  80107d:	b8 07 0e 00 00       	mov    $0xe07,%eax
  801082:	0f 45 f0             	cmovne %eax,%esi

	r = sys_page_map(curenvid, (void *)(pn * PGSIZE),
  801085:	89 d8                	mov    %ebx,%eax
  801087:	c1 e0 0c             	shl    $0xc,%eax
  80108a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80108d:	83 ec 0c             	sub    $0xc,%esp
  801090:	56                   	push   %esi
  801091:	50                   	push   %eax
  801092:	ff 75 dc             	pushl  -0x24(%ebp)
  801095:	50                   	push   %eax
  801096:	ff 75 e4             	pushl  -0x1c(%ebp)
  801099:	e8 bb fc ff ff       	call   800d59 <sys_page_map>
				envid, (void *)(pn * PGSIZE), perm);
	if (r < 0)
  80109e:	83 c4 20             	add    $0x20,%esp
  8010a1:	85 c0                	test   %eax,%eax
  8010a3:	79 12                	jns    8010b7 <fork+0x10b>
		panic("duppage error: %e", r);
  8010a5:	50                   	push   %eax
  8010a6:	68 eb 26 80 00       	push   $0x8026eb
  8010ab:	6a 4d                	push   $0x4d
  8010ad:	68 d1 26 80 00       	push   $0x8026d1
  8010b2:	e8 7f f1 ff ff       	call   800236 <_panic>
	
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))	{
  8010b7:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  8010be:	a8 02                	test   $0x2,%al
  8010c0:	75 0c                	jne    8010ce <fork+0x122>
  8010c2:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  8010c9:	f6 c4 08             	test   $0x8,%ah
  8010cc:	74 2c                	je     8010fa <fork+0x14e>
		r = sys_page_map(curenvid, (void *)(pn * PGSIZE),
  8010ce:	83 ec 0c             	sub    $0xc,%esp
  8010d1:	56                   	push   %esi
  8010d2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8010d5:	52                   	push   %edx
  8010d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010d9:	50                   	push   %eax
  8010da:	52                   	push   %edx
  8010db:	50                   	push   %eax
  8010dc:	e8 78 fc ff ff       	call   800d59 <sys_page_map>
						curenvid, (void *)(pn * PGSIZE), perm);
		if (r < 0)
  8010e1:	83 c4 20             	add    $0x20,%esp
  8010e4:	85 c0                	test   %eax,%eax
  8010e6:	79 12                	jns    8010fa <fork+0x14e>
			panic("duppage error: %e", r);
  8010e8:	50                   	push   %eax
  8010e9:	68 eb 26 80 00       	push   $0x8026eb
  8010ee:	6a 53                	push   $0x53
  8010f0:	68 d1 26 80 00       	push   $0x8026d1
  8010f5:	e8 3c f1 ff ff       	call   800236 <_panic>
	    panic("fork error: %e", new_envid);
	else if (new_envid == 0)
		thisenv = envs + ENVX(sys_getenvid());
	else {

		for (uint32_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
  8010fa:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801100:	81 ff 00 e0 bf ee    	cmp    $0xeebfe000,%edi
  801106:	0f 85 08 ff ff ff    	jne    801014 <fork+0x68>
			if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
				duppage(new_envid, PGNUM(addr));
		}

		sys_page_alloc(new_envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  80110c:	83 ec 04             	sub    $0x4,%esp
  80110f:	6a 07                	push   $0x7
  801111:	68 00 f0 bf ee       	push   $0xeebff000
  801116:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801119:	56                   	push   %esi
  80111a:	e8 f7 fb ff ff       	call   800d16 <sys_page_alloc>
		sys_env_set_pgfault_upcall(new_envid, _pgfault_upcall);
  80111f:	83 c4 08             	add    $0x8,%esp
  801122:	68 8f 1e 80 00       	push   $0x801e8f
  801127:	56                   	push   %esi
  801128:	e8 34 fd ff ff       	call   800e61 <sys_env_set_pgfault_upcall>
		sys_env_set_status(new_envid, ENV_RUNNABLE);
  80112d:	83 c4 08             	add    $0x8,%esp
  801130:	6a 02                	push   $0x2
  801132:	56                   	push   %esi
  801133:	e8 a5 fc ff ff       	call   800ddd <sys_env_set_status>
  801138:	83 c4 10             	add    $0x10,%esp

	}
	return new_envid;
}
  80113b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80113e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801141:	5b                   	pop    %ebx
  801142:	5e                   	pop    %esi
  801143:	5f                   	pop    %edi
  801144:	5d                   	pop    %ebp
  801145:	c3                   	ret    

00801146 <sfork>:

// Challenge!
int
sfork(void)
{
  801146:	55                   	push   %ebp
  801147:	89 e5                	mov    %esp,%ebp
  801149:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80114c:	68 fd 26 80 00       	push   $0x8026fd
  801151:	68 8b 00 00 00       	push   $0x8b
  801156:	68 d1 26 80 00       	push   $0x8026d1
  80115b:	e8 d6 f0 ff ff       	call   800236 <_panic>

00801160 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801160:	55                   	push   %ebp
  801161:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801163:	8b 45 08             	mov    0x8(%ebp),%eax
  801166:	05 00 00 00 30       	add    $0x30000000,%eax
  80116b:	c1 e8 0c             	shr    $0xc,%eax
}
  80116e:	5d                   	pop    %ebp
  80116f:	c3                   	ret    

00801170 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801170:	55                   	push   %ebp
  801171:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801173:	8b 45 08             	mov    0x8(%ebp),%eax
  801176:	05 00 00 00 30       	add    $0x30000000,%eax
  80117b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801180:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801185:	5d                   	pop    %ebp
  801186:	c3                   	ret    

00801187 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801187:	55                   	push   %ebp
  801188:	89 e5                	mov    %esp,%ebp
  80118a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80118d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801192:	89 c2                	mov    %eax,%edx
  801194:	c1 ea 16             	shr    $0x16,%edx
  801197:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80119e:	f6 c2 01             	test   $0x1,%dl
  8011a1:	74 11                	je     8011b4 <fd_alloc+0x2d>
  8011a3:	89 c2                	mov    %eax,%edx
  8011a5:	c1 ea 0c             	shr    $0xc,%edx
  8011a8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011af:	f6 c2 01             	test   $0x1,%dl
  8011b2:	75 09                	jne    8011bd <fd_alloc+0x36>
			*fd_store = fd;
  8011b4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8011bb:	eb 17                	jmp    8011d4 <fd_alloc+0x4d>
  8011bd:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011c2:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011c7:	75 c9                	jne    801192 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011c9:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011cf:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011d4:	5d                   	pop    %ebp
  8011d5:	c3                   	ret    

008011d6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011d6:	55                   	push   %ebp
  8011d7:	89 e5                	mov    %esp,%ebp
  8011d9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011dc:	83 f8 1f             	cmp    $0x1f,%eax
  8011df:	77 36                	ja     801217 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011e1:	c1 e0 0c             	shl    $0xc,%eax
  8011e4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011e9:	89 c2                	mov    %eax,%edx
  8011eb:	c1 ea 16             	shr    $0x16,%edx
  8011ee:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011f5:	f6 c2 01             	test   $0x1,%dl
  8011f8:	74 24                	je     80121e <fd_lookup+0x48>
  8011fa:	89 c2                	mov    %eax,%edx
  8011fc:	c1 ea 0c             	shr    $0xc,%edx
  8011ff:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801206:	f6 c2 01             	test   $0x1,%dl
  801209:	74 1a                	je     801225 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80120b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80120e:	89 02                	mov    %eax,(%edx)
	return 0;
  801210:	b8 00 00 00 00       	mov    $0x0,%eax
  801215:	eb 13                	jmp    80122a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801217:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80121c:	eb 0c                	jmp    80122a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80121e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801223:	eb 05                	jmp    80122a <fd_lookup+0x54>
  801225:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80122a:	5d                   	pop    %ebp
  80122b:	c3                   	ret    

0080122c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80122c:	55                   	push   %ebp
  80122d:	89 e5                	mov    %esp,%ebp
  80122f:	83 ec 08             	sub    $0x8,%esp
  801232:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801235:	ba 94 27 80 00       	mov    $0x802794,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80123a:	eb 13                	jmp    80124f <dev_lookup+0x23>
  80123c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80123f:	39 08                	cmp    %ecx,(%eax)
  801241:	75 0c                	jne    80124f <dev_lookup+0x23>
			*dev = devtab[i];
  801243:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801246:	89 01                	mov    %eax,(%ecx)
			return 0;
  801248:	b8 00 00 00 00       	mov    $0x0,%eax
  80124d:	eb 2e                	jmp    80127d <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80124f:	8b 02                	mov    (%edx),%eax
  801251:	85 c0                	test   %eax,%eax
  801253:	75 e7                	jne    80123c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801255:	a1 04 40 80 00       	mov    0x804004,%eax
  80125a:	8b 40 48             	mov    0x48(%eax),%eax
  80125d:	83 ec 04             	sub    $0x4,%esp
  801260:	51                   	push   %ecx
  801261:	50                   	push   %eax
  801262:	68 14 27 80 00       	push   $0x802714
  801267:	e8 a3 f0 ff ff       	call   80030f <cprintf>
	*dev = 0;
  80126c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80126f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801275:	83 c4 10             	add    $0x10,%esp
  801278:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80127d:	c9                   	leave  
  80127e:	c3                   	ret    

0080127f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80127f:	55                   	push   %ebp
  801280:	89 e5                	mov    %esp,%ebp
  801282:	56                   	push   %esi
  801283:	53                   	push   %ebx
  801284:	83 ec 10             	sub    $0x10,%esp
  801287:	8b 75 08             	mov    0x8(%ebp),%esi
  80128a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80128d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801290:	50                   	push   %eax
  801291:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801297:	c1 e8 0c             	shr    $0xc,%eax
  80129a:	50                   	push   %eax
  80129b:	e8 36 ff ff ff       	call   8011d6 <fd_lookup>
  8012a0:	83 c4 08             	add    $0x8,%esp
  8012a3:	85 c0                	test   %eax,%eax
  8012a5:	78 05                	js     8012ac <fd_close+0x2d>
	    || fd != fd2)
  8012a7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012aa:	74 0c                	je     8012b8 <fd_close+0x39>
		return (must_exist ? r : 0);
  8012ac:	84 db                	test   %bl,%bl
  8012ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8012b3:	0f 44 c2             	cmove  %edx,%eax
  8012b6:	eb 41                	jmp    8012f9 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012b8:	83 ec 08             	sub    $0x8,%esp
  8012bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012be:	50                   	push   %eax
  8012bf:	ff 36                	pushl  (%esi)
  8012c1:	e8 66 ff ff ff       	call   80122c <dev_lookup>
  8012c6:	89 c3                	mov    %eax,%ebx
  8012c8:	83 c4 10             	add    $0x10,%esp
  8012cb:	85 c0                	test   %eax,%eax
  8012cd:	78 1a                	js     8012e9 <fd_close+0x6a>
		if (dev->dev_close)
  8012cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d2:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012d5:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012da:	85 c0                	test   %eax,%eax
  8012dc:	74 0b                	je     8012e9 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012de:	83 ec 0c             	sub    $0xc,%esp
  8012e1:	56                   	push   %esi
  8012e2:	ff d0                	call   *%eax
  8012e4:	89 c3                	mov    %eax,%ebx
  8012e6:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012e9:	83 ec 08             	sub    $0x8,%esp
  8012ec:	56                   	push   %esi
  8012ed:	6a 00                	push   $0x0
  8012ef:	e8 a7 fa ff ff       	call   800d9b <sys_page_unmap>
	return r;
  8012f4:	83 c4 10             	add    $0x10,%esp
  8012f7:	89 d8                	mov    %ebx,%eax
}
  8012f9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012fc:	5b                   	pop    %ebx
  8012fd:	5e                   	pop    %esi
  8012fe:	5d                   	pop    %ebp
  8012ff:	c3                   	ret    

00801300 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801300:	55                   	push   %ebp
  801301:	89 e5                	mov    %esp,%ebp
  801303:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801306:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801309:	50                   	push   %eax
  80130a:	ff 75 08             	pushl  0x8(%ebp)
  80130d:	e8 c4 fe ff ff       	call   8011d6 <fd_lookup>
  801312:	83 c4 08             	add    $0x8,%esp
  801315:	85 c0                	test   %eax,%eax
  801317:	78 10                	js     801329 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801319:	83 ec 08             	sub    $0x8,%esp
  80131c:	6a 01                	push   $0x1
  80131e:	ff 75 f4             	pushl  -0xc(%ebp)
  801321:	e8 59 ff ff ff       	call   80127f <fd_close>
  801326:	83 c4 10             	add    $0x10,%esp
}
  801329:	c9                   	leave  
  80132a:	c3                   	ret    

0080132b <close_all>:

void
close_all(void)
{
  80132b:	55                   	push   %ebp
  80132c:	89 e5                	mov    %esp,%ebp
  80132e:	53                   	push   %ebx
  80132f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801332:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801337:	83 ec 0c             	sub    $0xc,%esp
  80133a:	53                   	push   %ebx
  80133b:	e8 c0 ff ff ff       	call   801300 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801340:	83 c3 01             	add    $0x1,%ebx
  801343:	83 c4 10             	add    $0x10,%esp
  801346:	83 fb 20             	cmp    $0x20,%ebx
  801349:	75 ec                	jne    801337 <close_all+0xc>
		close(i);
}
  80134b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80134e:	c9                   	leave  
  80134f:	c3                   	ret    

00801350 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801350:	55                   	push   %ebp
  801351:	89 e5                	mov    %esp,%ebp
  801353:	57                   	push   %edi
  801354:	56                   	push   %esi
  801355:	53                   	push   %ebx
  801356:	83 ec 2c             	sub    $0x2c,%esp
  801359:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80135c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80135f:	50                   	push   %eax
  801360:	ff 75 08             	pushl  0x8(%ebp)
  801363:	e8 6e fe ff ff       	call   8011d6 <fd_lookup>
  801368:	83 c4 08             	add    $0x8,%esp
  80136b:	85 c0                	test   %eax,%eax
  80136d:	0f 88 c1 00 00 00    	js     801434 <dup+0xe4>
		return r;
	close(newfdnum);
  801373:	83 ec 0c             	sub    $0xc,%esp
  801376:	56                   	push   %esi
  801377:	e8 84 ff ff ff       	call   801300 <close>

	newfd = INDEX2FD(newfdnum);
  80137c:	89 f3                	mov    %esi,%ebx
  80137e:	c1 e3 0c             	shl    $0xc,%ebx
  801381:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801387:	83 c4 04             	add    $0x4,%esp
  80138a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80138d:	e8 de fd ff ff       	call   801170 <fd2data>
  801392:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801394:	89 1c 24             	mov    %ebx,(%esp)
  801397:	e8 d4 fd ff ff       	call   801170 <fd2data>
  80139c:	83 c4 10             	add    $0x10,%esp
  80139f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013a2:	89 f8                	mov    %edi,%eax
  8013a4:	c1 e8 16             	shr    $0x16,%eax
  8013a7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013ae:	a8 01                	test   $0x1,%al
  8013b0:	74 37                	je     8013e9 <dup+0x99>
  8013b2:	89 f8                	mov    %edi,%eax
  8013b4:	c1 e8 0c             	shr    $0xc,%eax
  8013b7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013be:	f6 c2 01             	test   $0x1,%dl
  8013c1:	74 26                	je     8013e9 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013c3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013ca:	83 ec 0c             	sub    $0xc,%esp
  8013cd:	25 07 0e 00 00       	and    $0xe07,%eax
  8013d2:	50                   	push   %eax
  8013d3:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013d6:	6a 00                	push   $0x0
  8013d8:	57                   	push   %edi
  8013d9:	6a 00                	push   $0x0
  8013db:	e8 79 f9 ff ff       	call   800d59 <sys_page_map>
  8013e0:	89 c7                	mov    %eax,%edi
  8013e2:	83 c4 20             	add    $0x20,%esp
  8013e5:	85 c0                	test   %eax,%eax
  8013e7:	78 2e                	js     801417 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013e9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013ec:	89 d0                	mov    %edx,%eax
  8013ee:	c1 e8 0c             	shr    $0xc,%eax
  8013f1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013f8:	83 ec 0c             	sub    $0xc,%esp
  8013fb:	25 07 0e 00 00       	and    $0xe07,%eax
  801400:	50                   	push   %eax
  801401:	53                   	push   %ebx
  801402:	6a 00                	push   $0x0
  801404:	52                   	push   %edx
  801405:	6a 00                	push   $0x0
  801407:	e8 4d f9 ff ff       	call   800d59 <sys_page_map>
  80140c:	89 c7                	mov    %eax,%edi
  80140e:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801411:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801413:	85 ff                	test   %edi,%edi
  801415:	79 1d                	jns    801434 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801417:	83 ec 08             	sub    $0x8,%esp
  80141a:	53                   	push   %ebx
  80141b:	6a 00                	push   $0x0
  80141d:	e8 79 f9 ff ff       	call   800d9b <sys_page_unmap>
	sys_page_unmap(0, nva);
  801422:	83 c4 08             	add    $0x8,%esp
  801425:	ff 75 d4             	pushl  -0x2c(%ebp)
  801428:	6a 00                	push   $0x0
  80142a:	e8 6c f9 ff ff       	call   800d9b <sys_page_unmap>
	return r;
  80142f:	83 c4 10             	add    $0x10,%esp
  801432:	89 f8                	mov    %edi,%eax
}
  801434:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801437:	5b                   	pop    %ebx
  801438:	5e                   	pop    %esi
  801439:	5f                   	pop    %edi
  80143a:	5d                   	pop    %ebp
  80143b:	c3                   	ret    

0080143c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80143c:	55                   	push   %ebp
  80143d:	89 e5                	mov    %esp,%ebp
  80143f:	53                   	push   %ebx
  801440:	83 ec 14             	sub    $0x14,%esp
  801443:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801446:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801449:	50                   	push   %eax
  80144a:	53                   	push   %ebx
  80144b:	e8 86 fd ff ff       	call   8011d6 <fd_lookup>
  801450:	83 c4 08             	add    $0x8,%esp
  801453:	89 c2                	mov    %eax,%edx
  801455:	85 c0                	test   %eax,%eax
  801457:	78 6d                	js     8014c6 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801459:	83 ec 08             	sub    $0x8,%esp
  80145c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80145f:	50                   	push   %eax
  801460:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801463:	ff 30                	pushl  (%eax)
  801465:	e8 c2 fd ff ff       	call   80122c <dev_lookup>
  80146a:	83 c4 10             	add    $0x10,%esp
  80146d:	85 c0                	test   %eax,%eax
  80146f:	78 4c                	js     8014bd <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801471:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801474:	8b 42 08             	mov    0x8(%edx),%eax
  801477:	83 e0 03             	and    $0x3,%eax
  80147a:	83 f8 01             	cmp    $0x1,%eax
  80147d:	75 21                	jne    8014a0 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80147f:	a1 04 40 80 00       	mov    0x804004,%eax
  801484:	8b 40 48             	mov    0x48(%eax),%eax
  801487:	83 ec 04             	sub    $0x4,%esp
  80148a:	53                   	push   %ebx
  80148b:	50                   	push   %eax
  80148c:	68 58 27 80 00       	push   $0x802758
  801491:	e8 79 ee ff ff       	call   80030f <cprintf>
		return -E_INVAL;
  801496:	83 c4 10             	add    $0x10,%esp
  801499:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80149e:	eb 26                	jmp    8014c6 <read+0x8a>
	}
	if (!dev->dev_read)
  8014a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014a3:	8b 40 08             	mov    0x8(%eax),%eax
  8014a6:	85 c0                	test   %eax,%eax
  8014a8:	74 17                	je     8014c1 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014aa:	83 ec 04             	sub    $0x4,%esp
  8014ad:	ff 75 10             	pushl  0x10(%ebp)
  8014b0:	ff 75 0c             	pushl  0xc(%ebp)
  8014b3:	52                   	push   %edx
  8014b4:	ff d0                	call   *%eax
  8014b6:	89 c2                	mov    %eax,%edx
  8014b8:	83 c4 10             	add    $0x10,%esp
  8014bb:	eb 09                	jmp    8014c6 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014bd:	89 c2                	mov    %eax,%edx
  8014bf:	eb 05                	jmp    8014c6 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014c1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014c6:	89 d0                	mov    %edx,%eax
  8014c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014cb:	c9                   	leave  
  8014cc:	c3                   	ret    

008014cd <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014cd:	55                   	push   %ebp
  8014ce:	89 e5                	mov    %esp,%ebp
  8014d0:	57                   	push   %edi
  8014d1:	56                   	push   %esi
  8014d2:	53                   	push   %ebx
  8014d3:	83 ec 0c             	sub    $0xc,%esp
  8014d6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014d9:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014dc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014e1:	eb 21                	jmp    801504 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014e3:	83 ec 04             	sub    $0x4,%esp
  8014e6:	89 f0                	mov    %esi,%eax
  8014e8:	29 d8                	sub    %ebx,%eax
  8014ea:	50                   	push   %eax
  8014eb:	89 d8                	mov    %ebx,%eax
  8014ed:	03 45 0c             	add    0xc(%ebp),%eax
  8014f0:	50                   	push   %eax
  8014f1:	57                   	push   %edi
  8014f2:	e8 45 ff ff ff       	call   80143c <read>
		if (m < 0)
  8014f7:	83 c4 10             	add    $0x10,%esp
  8014fa:	85 c0                	test   %eax,%eax
  8014fc:	78 10                	js     80150e <readn+0x41>
			return m;
		if (m == 0)
  8014fe:	85 c0                	test   %eax,%eax
  801500:	74 0a                	je     80150c <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801502:	01 c3                	add    %eax,%ebx
  801504:	39 f3                	cmp    %esi,%ebx
  801506:	72 db                	jb     8014e3 <readn+0x16>
  801508:	89 d8                	mov    %ebx,%eax
  80150a:	eb 02                	jmp    80150e <readn+0x41>
  80150c:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80150e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801511:	5b                   	pop    %ebx
  801512:	5e                   	pop    %esi
  801513:	5f                   	pop    %edi
  801514:	5d                   	pop    %ebp
  801515:	c3                   	ret    

00801516 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801516:	55                   	push   %ebp
  801517:	89 e5                	mov    %esp,%ebp
  801519:	53                   	push   %ebx
  80151a:	83 ec 14             	sub    $0x14,%esp
  80151d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801520:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801523:	50                   	push   %eax
  801524:	53                   	push   %ebx
  801525:	e8 ac fc ff ff       	call   8011d6 <fd_lookup>
  80152a:	83 c4 08             	add    $0x8,%esp
  80152d:	89 c2                	mov    %eax,%edx
  80152f:	85 c0                	test   %eax,%eax
  801531:	78 68                	js     80159b <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801533:	83 ec 08             	sub    $0x8,%esp
  801536:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801539:	50                   	push   %eax
  80153a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153d:	ff 30                	pushl  (%eax)
  80153f:	e8 e8 fc ff ff       	call   80122c <dev_lookup>
  801544:	83 c4 10             	add    $0x10,%esp
  801547:	85 c0                	test   %eax,%eax
  801549:	78 47                	js     801592 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80154b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80154e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801552:	75 21                	jne    801575 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801554:	a1 04 40 80 00       	mov    0x804004,%eax
  801559:	8b 40 48             	mov    0x48(%eax),%eax
  80155c:	83 ec 04             	sub    $0x4,%esp
  80155f:	53                   	push   %ebx
  801560:	50                   	push   %eax
  801561:	68 74 27 80 00       	push   $0x802774
  801566:	e8 a4 ed ff ff       	call   80030f <cprintf>
		return -E_INVAL;
  80156b:	83 c4 10             	add    $0x10,%esp
  80156e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801573:	eb 26                	jmp    80159b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801575:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801578:	8b 52 0c             	mov    0xc(%edx),%edx
  80157b:	85 d2                	test   %edx,%edx
  80157d:	74 17                	je     801596 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80157f:	83 ec 04             	sub    $0x4,%esp
  801582:	ff 75 10             	pushl  0x10(%ebp)
  801585:	ff 75 0c             	pushl  0xc(%ebp)
  801588:	50                   	push   %eax
  801589:	ff d2                	call   *%edx
  80158b:	89 c2                	mov    %eax,%edx
  80158d:	83 c4 10             	add    $0x10,%esp
  801590:	eb 09                	jmp    80159b <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801592:	89 c2                	mov    %eax,%edx
  801594:	eb 05                	jmp    80159b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801596:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80159b:	89 d0                	mov    %edx,%eax
  80159d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a0:	c9                   	leave  
  8015a1:	c3                   	ret    

008015a2 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015a2:	55                   	push   %ebp
  8015a3:	89 e5                	mov    %esp,%ebp
  8015a5:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015a8:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015ab:	50                   	push   %eax
  8015ac:	ff 75 08             	pushl  0x8(%ebp)
  8015af:	e8 22 fc ff ff       	call   8011d6 <fd_lookup>
  8015b4:	83 c4 08             	add    $0x8,%esp
  8015b7:	85 c0                	test   %eax,%eax
  8015b9:	78 0e                	js     8015c9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015c1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015c9:	c9                   	leave  
  8015ca:	c3                   	ret    

008015cb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015cb:	55                   	push   %ebp
  8015cc:	89 e5                	mov    %esp,%ebp
  8015ce:	53                   	push   %ebx
  8015cf:	83 ec 14             	sub    $0x14,%esp
  8015d2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015d5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015d8:	50                   	push   %eax
  8015d9:	53                   	push   %ebx
  8015da:	e8 f7 fb ff ff       	call   8011d6 <fd_lookup>
  8015df:	83 c4 08             	add    $0x8,%esp
  8015e2:	89 c2                	mov    %eax,%edx
  8015e4:	85 c0                	test   %eax,%eax
  8015e6:	78 65                	js     80164d <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e8:	83 ec 08             	sub    $0x8,%esp
  8015eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ee:	50                   	push   %eax
  8015ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015f2:	ff 30                	pushl  (%eax)
  8015f4:	e8 33 fc ff ff       	call   80122c <dev_lookup>
  8015f9:	83 c4 10             	add    $0x10,%esp
  8015fc:	85 c0                	test   %eax,%eax
  8015fe:	78 44                	js     801644 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801600:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801603:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801607:	75 21                	jne    80162a <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801609:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80160e:	8b 40 48             	mov    0x48(%eax),%eax
  801611:	83 ec 04             	sub    $0x4,%esp
  801614:	53                   	push   %ebx
  801615:	50                   	push   %eax
  801616:	68 34 27 80 00       	push   $0x802734
  80161b:	e8 ef ec ff ff       	call   80030f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801620:	83 c4 10             	add    $0x10,%esp
  801623:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801628:	eb 23                	jmp    80164d <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80162a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80162d:	8b 52 18             	mov    0x18(%edx),%edx
  801630:	85 d2                	test   %edx,%edx
  801632:	74 14                	je     801648 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801634:	83 ec 08             	sub    $0x8,%esp
  801637:	ff 75 0c             	pushl  0xc(%ebp)
  80163a:	50                   	push   %eax
  80163b:	ff d2                	call   *%edx
  80163d:	89 c2                	mov    %eax,%edx
  80163f:	83 c4 10             	add    $0x10,%esp
  801642:	eb 09                	jmp    80164d <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801644:	89 c2                	mov    %eax,%edx
  801646:	eb 05                	jmp    80164d <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801648:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80164d:	89 d0                	mov    %edx,%eax
  80164f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801652:	c9                   	leave  
  801653:	c3                   	ret    

00801654 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801654:	55                   	push   %ebp
  801655:	89 e5                	mov    %esp,%ebp
  801657:	53                   	push   %ebx
  801658:	83 ec 14             	sub    $0x14,%esp
  80165b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80165e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801661:	50                   	push   %eax
  801662:	ff 75 08             	pushl  0x8(%ebp)
  801665:	e8 6c fb ff ff       	call   8011d6 <fd_lookup>
  80166a:	83 c4 08             	add    $0x8,%esp
  80166d:	89 c2                	mov    %eax,%edx
  80166f:	85 c0                	test   %eax,%eax
  801671:	78 58                	js     8016cb <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801673:	83 ec 08             	sub    $0x8,%esp
  801676:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801679:	50                   	push   %eax
  80167a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80167d:	ff 30                	pushl  (%eax)
  80167f:	e8 a8 fb ff ff       	call   80122c <dev_lookup>
  801684:	83 c4 10             	add    $0x10,%esp
  801687:	85 c0                	test   %eax,%eax
  801689:	78 37                	js     8016c2 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80168b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80168e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801692:	74 32                	je     8016c6 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801694:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801697:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80169e:	00 00 00 
	stat->st_isdir = 0;
  8016a1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016a8:	00 00 00 
	stat->st_dev = dev;
  8016ab:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016b1:	83 ec 08             	sub    $0x8,%esp
  8016b4:	53                   	push   %ebx
  8016b5:	ff 75 f0             	pushl  -0x10(%ebp)
  8016b8:	ff 50 14             	call   *0x14(%eax)
  8016bb:	89 c2                	mov    %eax,%edx
  8016bd:	83 c4 10             	add    $0x10,%esp
  8016c0:	eb 09                	jmp    8016cb <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c2:	89 c2                	mov    %eax,%edx
  8016c4:	eb 05                	jmp    8016cb <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016c6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016cb:	89 d0                	mov    %edx,%eax
  8016cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d0:	c9                   	leave  
  8016d1:	c3                   	ret    

008016d2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016d2:	55                   	push   %ebp
  8016d3:	89 e5                	mov    %esp,%ebp
  8016d5:	56                   	push   %esi
  8016d6:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016d7:	83 ec 08             	sub    $0x8,%esp
  8016da:	6a 00                	push   $0x0
  8016dc:	ff 75 08             	pushl  0x8(%ebp)
  8016df:	e8 e3 01 00 00       	call   8018c7 <open>
  8016e4:	89 c3                	mov    %eax,%ebx
  8016e6:	83 c4 10             	add    $0x10,%esp
  8016e9:	85 c0                	test   %eax,%eax
  8016eb:	78 1b                	js     801708 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016ed:	83 ec 08             	sub    $0x8,%esp
  8016f0:	ff 75 0c             	pushl  0xc(%ebp)
  8016f3:	50                   	push   %eax
  8016f4:	e8 5b ff ff ff       	call   801654 <fstat>
  8016f9:	89 c6                	mov    %eax,%esi
	close(fd);
  8016fb:	89 1c 24             	mov    %ebx,(%esp)
  8016fe:	e8 fd fb ff ff       	call   801300 <close>
	return r;
  801703:	83 c4 10             	add    $0x10,%esp
  801706:	89 f0                	mov    %esi,%eax
}
  801708:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80170b:	5b                   	pop    %ebx
  80170c:	5e                   	pop    %esi
  80170d:	5d                   	pop    %ebp
  80170e:	c3                   	ret    

0080170f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80170f:	55                   	push   %ebp
  801710:	89 e5                	mov    %esp,%ebp
  801712:	56                   	push   %esi
  801713:	53                   	push   %ebx
  801714:	89 c6                	mov    %eax,%esi
  801716:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801718:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80171f:	75 12                	jne    801733 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801721:	83 ec 0c             	sub    $0xc,%esp
  801724:	6a 01                	push   $0x1
  801726:	e8 50 08 00 00       	call   801f7b <ipc_find_env>
  80172b:	a3 00 40 80 00       	mov    %eax,0x804000
  801730:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801733:	6a 07                	push   $0x7
  801735:	68 00 50 80 00       	push   $0x805000
  80173a:	56                   	push   %esi
  80173b:	ff 35 00 40 80 00    	pushl  0x804000
  801741:	e8 e1 07 00 00       	call   801f27 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801746:	83 c4 0c             	add    $0xc,%esp
  801749:	6a 00                	push   $0x0
  80174b:	53                   	push   %ebx
  80174c:	6a 00                	push   $0x0
  80174e:	e8 62 07 00 00       	call   801eb5 <ipc_recv>
}
  801753:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801756:	5b                   	pop    %ebx
  801757:	5e                   	pop    %esi
  801758:	5d                   	pop    %ebp
  801759:	c3                   	ret    

0080175a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80175a:	55                   	push   %ebp
  80175b:	89 e5                	mov    %esp,%ebp
  80175d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801760:	8b 45 08             	mov    0x8(%ebp),%eax
  801763:	8b 40 0c             	mov    0xc(%eax),%eax
  801766:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80176b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80176e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801773:	ba 00 00 00 00       	mov    $0x0,%edx
  801778:	b8 02 00 00 00       	mov    $0x2,%eax
  80177d:	e8 8d ff ff ff       	call   80170f <fsipc>
}
  801782:	c9                   	leave  
  801783:	c3                   	ret    

00801784 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801784:	55                   	push   %ebp
  801785:	89 e5                	mov    %esp,%ebp
  801787:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80178a:	8b 45 08             	mov    0x8(%ebp),%eax
  80178d:	8b 40 0c             	mov    0xc(%eax),%eax
  801790:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801795:	ba 00 00 00 00       	mov    $0x0,%edx
  80179a:	b8 06 00 00 00       	mov    $0x6,%eax
  80179f:	e8 6b ff ff ff       	call   80170f <fsipc>
}
  8017a4:	c9                   	leave  
  8017a5:	c3                   	ret    

008017a6 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017a6:	55                   	push   %ebp
  8017a7:	89 e5                	mov    %esp,%ebp
  8017a9:	53                   	push   %ebx
  8017aa:	83 ec 04             	sub    $0x4,%esp
  8017ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b3:	8b 40 0c             	mov    0xc(%eax),%eax
  8017b6:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c0:	b8 05 00 00 00       	mov    $0x5,%eax
  8017c5:	e8 45 ff ff ff       	call   80170f <fsipc>
  8017ca:	85 c0                	test   %eax,%eax
  8017cc:	78 2c                	js     8017fa <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017ce:	83 ec 08             	sub    $0x8,%esp
  8017d1:	68 00 50 80 00       	push   $0x805000
  8017d6:	53                   	push   %ebx
  8017d7:	e8 37 f1 ff ff       	call   800913 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017dc:	a1 80 50 80 00       	mov    0x805080,%eax
  8017e1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017e7:	a1 84 50 80 00       	mov    0x805084,%eax
  8017ec:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017f2:	83 c4 10             	add    $0x10,%esp
  8017f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017fd:	c9                   	leave  
  8017fe:	c3                   	ret    

008017ff <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017ff:	55                   	push   %ebp
  801800:	89 e5                	mov    %esp,%ebp
  801802:	83 ec 0c             	sub    $0xc,%esp
  801805:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	
	int r;

	n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801808:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80180d:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801812:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801815:	8b 55 08             	mov    0x8(%ebp),%edx
  801818:	8b 52 0c             	mov    0xc(%edx),%edx
  80181b:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801821:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801826:	50                   	push   %eax
  801827:	ff 75 0c             	pushl  0xc(%ebp)
  80182a:	68 08 50 80 00       	push   $0x805008
  80182f:	e8 71 f2 ff ff       	call   800aa5 <memmove>
	
	return fsipc(FSREQ_WRITE, NULL);	
  801834:	ba 00 00 00 00       	mov    $0x0,%edx
  801839:	b8 04 00 00 00       	mov    $0x4,%eax
  80183e:	e8 cc fe ff ff       	call   80170f <fsipc>
}
  801843:	c9                   	leave  
  801844:	c3                   	ret    

00801845 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801845:	55                   	push   %ebp
  801846:	89 e5                	mov    %esp,%ebp
  801848:	56                   	push   %esi
  801849:	53                   	push   %ebx
  80184a:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80184d:	8b 45 08             	mov    0x8(%ebp),%eax
  801850:	8b 40 0c             	mov    0xc(%eax),%eax
  801853:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801858:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80185e:	ba 00 00 00 00       	mov    $0x0,%edx
  801863:	b8 03 00 00 00       	mov    $0x3,%eax
  801868:	e8 a2 fe ff ff       	call   80170f <fsipc>
  80186d:	89 c3                	mov    %eax,%ebx
  80186f:	85 c0                	test   %eax,%eax
  801871:	78 4b                	js     8018be <devfile_read+0x79>
		return r;
	assert(r <= n);
  801873:	39 c6                	cmp    %eax,%esi
  801875:	73 16                	jae    80188d <devfile_read+0x48>
  801877:	68 a4 27 80 00       	push   $0x8027a4
  80187c:	68 ab 27 80 00       	push   $0x8027ab
  801881:	6a 7c                	push   $0x7c
  801883:	68 c0 27 80 00       	push   $0x8027c0
  801888:	e8 a9 e9 ff ff       	call   800236 <_panic>
	assert(r <= PGSIZE);
  80188d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801892:	7e 16                	jle    8018aa <devfile_read+0x65>
  801894:	68 cb 27 80 00       	push   $0x8027cb
  801899:	68 ab 27 80 00       	push   $0x8027ab
  80189e:	6a 7d                	push   $0x7d
  8018a0:	68 c0 27 80 00       	push   $0x8027c0
  8018a5:	e8 8c e9 ff ff       	call   800236 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018aa:	83 ec 04             	sub    $0x4,%esp
  8018ad:	50                   	push   %eax
  8018ae:	68 00 50 80 00       	push   $0x805000
  8018b3:	ff 75 0c             	pushl  0xc(%ebp)
  8018b6:	e8 ea f1 ff ff       	call   800aa5 <memmove>
	return r;
  8018bb:	83 c4 10             	add    $0x10,%esp
}
  8018be:	89 d8                	mov    %ebx,%eax
  8018c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c3:	5b                   	pop    %ebx
  8018c4:	5e                   	pop    %esi
  8018c5:	5d                   	pop    %ebp
  8018c6:	c3                   	ret    

008018c7 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018c7:	55                   	push   %ebp
  8018c8:	89 e5                	mov    %esp,%ebp
  8018ca:	53                   	push   %ebx
  8018cb:	83 ec 20             	sub    $0x20,%esp
  8018ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018d1:	53                   	push   %ebx
  8018d2:	e8 03 f0 ff ff       	call   8008da <strlen>
  8018d7:	83 c4 10             	add    $0x10,%esp
  8018da:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018df:	7f 67                	jg     801948 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018e1:	83 ec 0c             	sub    $0xc,%esp
  8018e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018e7:	50                   	push   %eax
  8018e8:	e8 9a f8 ff ff       	call   801187 <fd_alloc>
  8018ed:	83 c4 10             	add    $0x10,%esp
		return r;
  8018f0:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018f2:	85 c0                	test   %eax,%eax
  8018f4:	78 57                	js     80194d <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018f6:	83 ec 08             	sub    $0x8,%esp
  8018f9:	53                   	push   %ebx
  8018fa:	68 00 50 80 00       	push   $0x805000
  8018ff:	e8 0f f0 ff ff       	call   800913 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801904:	8b 45 0c             	mov    0xc(%ebp),%eax
  801907:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80190c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80190f:	b8 01 00 00 00       	mov    $0x1,%eax
  801914:	e8 f6 fd ff ff       	call   80170f <fsipc>
  801919:	89 c3                	mov    %eax,%ebx
  80191b:	83 c4 10             	add    $0x10,%esp
  80191e:	85 c0                	test   %eax,%eax
  801920:	79 14                	jns    801936 <open+0x6f>
		fd_close(fd, 0);
  801922:	83 ec 08             	sub    $0x8,%esp
  801925:	6a 00                	push   $0x0
  801927:	ff 75 f4             	pushl  -0xc(%ebp)
  80192a:	e8 50 f9 ff ff       	call   80127f <fd_close>
		return r;
  80192f:	83 c4 10             	add    $0x10,%esp
  801932:	89 da                	mov    %ebx,%edx
  801934:	eb 17                	jmp    80194d <open+0x86>
	}

	return fd2num(fd);
  801936:	83 ec 0c             	sub    $0xc,%esp
  801939:	ff 75 f4             	pushl  -0xc(%ebp)
  80193c:	e8 1f f8 ff ff       	call   801160 <fd2num>
  801941:	89 c2                	mov    %eax,%edx
  801943:	83 c4 10             	add    $0x10,%esp
  801946:	eb 05                	jmp    80194d <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801948:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80194d:	89 d0                	mov    %edx,%eax
  80194f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801952:	c9                   	leave  
  801953:	c3                   	ret    

00801954 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801954:	55                   	push   %ebp
  801955:	89 e5                	mov    %esp,%ebp
  801957:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80195a:	ba 00 00 00 00       	mov    $0x0,%edx
  80195f:	b8 08 00 00 00       	mov    $0x8,%eax
  801964:	e8 a6 fd ff ff       	call   80170f <fsipc>
}
  801969:	c9                   	leave  
  80196a:	c3                   	ret    

0080196b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80196b:	55                   	push   %ebp
  80196c:	89 e5                	mov    %esp,%ebp
  80196e:	56                   	push   %esi
  80196f:	53                   	push   %ebx
  801970:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801973:	83 ec 0c             	sub    $0xc,%esp
  801976:	ff 75 08             	pushl  0x8(%ebp)
  801979:	e8 f2 f7 ff ff       	call   801170 <fd2data>
  80197e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801980:	83 c4 08             	add    $0x8,%esp
  801983:	68 d7 27 80 00       	push   $0x8027d7
  801988:	53                   	push   %ebx
  801989:	e8 85 ef ff ff       	call   800913 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80198e:	8b 46 04             	mov    0x4(%esi),%eax
  801991:	2b 06                	sub    (%esi),%eax
  801993:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801999:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019a0:	00 00 00 
	stat->st_dev = &devpipe;
  8019a3:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8019aa:	30 80 00 
	return 0;
}
  8019ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019b5:	5b                   	pop    %ebx
  8019b6:	5e                   	pop    %esi
  8019b7:	5d                   	pop    %ebp
  8019b8:	c3                   	ret    

008019b9 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019b9:	55                   	push   %ebp
  8019ba:	89 e5                	mov    %esp,%ebp
  8019bc:	53                   	push   %ebx
  8019bd:	83 ec 0c             	sub    $0xc,%esp
  8019c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019c3:	53                   	push   %ebx
  8019c4:	6a 00                	push   $0x0
  8019c6:	e8 d0 f3 ff ff       	call   800d9b <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019cb:	89 1c 24             	mov    %ebx,(%esp)
  8019ce:	e8 9d f7 ff ff       	call   801170 <fd2data>
  8019d3:	83 c4 08             	add    $0x8,%esp
  8019d6:	50                   	push   %eax
  8019d7:	6a 00                	push   $0x0
  8019d9:	e8 bd f3 ff ff       	call   800d9b <sys_page_unmap>
}
  8019de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019e1:	c9                   	leave  
  8019e2:	c3                   	ret    

008019e3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019e3:	55                   	push   %ebp
  8019e4:	89 e5                	mov    %esp,%ebp
  8019e6:	57                   	push   %edi
  8019e7:	56                   	push   %esi
  8019e8:	53                   	push   %ebx
  8019e9:	83 ec 1c             	sub    $0x1c,%esp
  8019ec:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8019ef:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019f1:	a1 04 40 80 00       	mov    0x804004,%eax
  8019f6:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8019f9:	83 ec 0c             	sub    $0xc,%esp
  8019fc:	ff 75 e0             	pushl  -0x20(%ebp)
  8019ff:	e8 b0 05 00 00       	call   801fb4 <pageref>
  801a04:	89 c3                	mov    %eax,%ebx
  801a06:	89 3c 24             	mov    %edi,(%esp)
  801a09:	e8 a6 05 00 00       	call   801fb4 <pageref>
  801a0e:	83 c4 10             	add    $0x10,%esp
  801a11:	39 c3                	cmp    %eax,%ebx
  801a13:	0f 94 c1             	sete   %cl
  801a16:	0f b6 c9             	movzbl %cl,%ecx
  801a19:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a1c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a22:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a25:	39 ce                	cmp    %ecx,%esi
  801a27:	74 1b                	je     801a44 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a29:	39 c3                	cmp    %eax,%ebx
  801a2b:	75 c4                	jne    8019f1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a2d:	8b 42 58             	mov    0x58(%edx),%eax
  801a30:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a33:	50                   	push   %eax
  801a34:	56                   	push   %esi
  801a35:	68 de 27 80 00       	push   $0x8027de
  801a3a:	e8 d0 e8 ff ff       	call   80030f <cprintf>
  801a3f:	83 c4 10             	add    $0x10,%esp
  801a42:	eb ad                	jmp    8019f1 <_pipeisclosed+0xe>
	}
}
  801a44:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a4a:	5b                   	pop    %ebx
  801a4b:	5e                   	pop    %esi
  801a4c:	5f                   	pop    %edi
  801a4d:	5d                   	pop    %ebp
  801a4e:	c3                   	ret    

00801a4f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a4f:	55                   	push   %ebp
  801a50:	89 e5                	mov    %esp,%ebp
  801a52:	57                   	push   %edi
  801a53:	56                   	push   %esi
  801a54:	53                   	push   %ebx
  801a55:	83 ec 28             	sub    $0x28,%esp
  801a58:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a5b:	56                   	push   %esi
  801a5c:	e8 0f f7 ff ff       	call   801170 <fd2data>
  801a61:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a63:	83 c4 10             	add    $0x10,%esp
  801a66:	bf 00 00 00 00       	mov    $0x0,%edi
  801a6b:	eb 4b                	jmp    801ab8 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a6d:	89 da                	mov    %ebx,%edx
  801a6f:	89 f0                	mov    %esi,%eax
  801a71:	e8 6d ff ff ff       	call   8019e3 <_pipeisclosed>
  801a76:	85 c0                	test   %eax,%eax
  801a78:	75 48                	jne    801ac2 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a7a:	e8 78 f2 ff ff       	call   800cf7 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a7f:	8b 43 04             	mov    0x4(%ebx),%eax
  801a82:	8b 0b                	mov    (%ebx),%ecx
  801a84:	8d 51 20             	lea    0x20(%ecx),%edx
  801a87:	39 d0                	cmp    %edx,%eax
  801a89:	73 e2                	jae    801a6d <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a8e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a92:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a95:	89 c2                	mov    %eax,%edx
  801a97:	c1 fa 1f             	sar    $0x1f,%edx
  801a9a:	89 d1                	mov    %edx,%ecx
  801a9c:	c1 e9 1b             	shr    $0x1b,%ecx
  801a9f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801aa2:	83 e2 1f             	and    $0x1f,%edx
  801aa5:	29 ca                	sub    %ecx,%edx
  801aa7:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801aab:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801aaf:	83 c0 01             	add    $0x1,%eax
  801ab2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ab5:	83 c7 01             	add    $0x1,%edi
  801ab8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801abb:	75 c2                	jne    801a7f <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801abd:	8b 45 10             	mov    0x10(%ebp),%eax
  801ac0:	eb 05                	jmp    801ac7 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ac2:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801ac7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aca:	5b                   	pop    %ebx
  801acb:	5e                   	pop    %esi
  801acc:	5f                   	pop    %edi
  801acd:	5d                   	pop    %ebp
  801ace:	c3                   	ret    

00801acf <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801acf:	55                   	push   %ebp
  801ad0:	89 e5                	mov    %esp,%ebp
  801ad2:	57                   	push   %edi
  801ad3:	56                   	push   %esi
  801ad4:	53                   	push   %ebx
  801ad5:	83 ec 18             	sub    $0x18,%esp
  801ad8:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801adb:	57                   	push   %edi
  801adc:	e8 8f f6 ff ff       	call   801170 <fd2data>
  801ae1:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ae3:	83 c4 10             	add    $0x10,%esp
  801ae6:	bb 00 00 00 00       	mov    $0x0,%ebx
  801aeb:	eb 3d                	jmp    801b2a <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801aed:	85 db                	test   %ebx,%ebx
  801aef:	74 04                	je     801af5 <devpipe_read+0x26>
				return i;
  801af1:	89 d8                	mov    %ebx,%eax
  801af3:	eb 44                	jmp    801b39 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801af5:	89 f2                	mov    %esi,%edx
  801af7:	89 f8                	mov    %edi,%eax
  801af9:	e8 e5 fe ff ff       	call   8019e3 <_pipeisclosed>
  801afe:	85 c0                	test   %eax,%eax
  801b00:	75 32                	jne    801b34 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b02:	e8 f0 f1 ff ff       	call   800cf7 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b07:	8b 06                	mov    (%esi),%eax
  801b09:	3b 46 04             	cmp    0x4(%esi),%eax
  801b0c:	74 df                	je     801aed <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b0e:	99                   	cltd   
  801b0f:	c1 ea 1b             	shr    $0x1b,%edx
  801b12:	01 d0                	add    %edx,%eax
  801b14:	83 e0 1f             	and    $0x1f,%eax
  801b17:	29 d0                	sub    %edx,%eax
  801b19:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b21:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b24:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b27:	83 c3 01             	add    $0x1,%ebx
  801b2a:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b2d:	75 d8                	jne    801b07 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b2f:	8b 45 10             	mov    0x10(%ebp),%eax
  801b32:	eb 05                	jmp    801b39 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b34:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b3c:	5b                   	pop    %ebx
  801b3d:	5e                   	pop    %esi
  801b3e:	5f                   	pop    %edi
  801b3f:	5d                   	pop    %ebp
  801b40:	c3                   	ret    

00801b41 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b41:	55                   	push   %ebp
  801b42:	89 e5                	mov    %esp,%ebp
  801b44:	56                   	push   %esi
  801b45:	53                   	push   %ebx
  801b46:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b49:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b4c:	50                   	push   %eax
  801b4d:	e8 35 f6 ff ff       	call   801187 <fd_alloc>
  801b52:	83 c4 10             	add    $0x10,%esp
  801b55:	89 c2                	mov    %eax,%edx
  801b57:	85 c0                	test   %eax,%eax
  801b59:	0f 88 2c 01 00 00    	js     801c8b <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b5f:	83 ec 04             	sub    $0x4,%esp
  801b62:	68 07 04 00 00       	push   $0x407
  801b67:	ff 75 f4             	pushl  -0xc(%ebp)
  801b6a:	6a 00                	push   $0x0
  801b6c:	e8 a5 f1 ff ff       	call   800d16 <sys_page_alloc>
  801b71:	83 c4 10             	add    $0x10,%esp
  801b74:	89 c2                	mov    %eax,%edx
  801b76:	85 c0                	test   %eax,%eax
  801b78:	0f 88 0d 01 00 00    	js     801c8b <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b7e:	83 ec 0c             	sub    $0xc,%esp
  801b81:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b84:	50                   	push   %eax
  801b85:	e8 fd f5 ff ff       	call   801187 <fd_alloc>
  801b8a:	89 c3                	mov    %eax,%ebx
  801b8c:	83 c4 10             	add    $0x10,%esp
  801b8f:	85 c0                	test   %eax,%eax
  801b91:	0f 88 e2 00 00 00    	js     801c79 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b97:	83 ec 04             	sub    $0x4,%esp
  801b9a:	68 07 04 00 00       	push   $0x407
  801b9f:	ff 75 f0             	pushl  -0x10(%ebp)
  801ba2:	6a 00                	push   $0x0
  801ba4:	e8 6d f1 ff ff       	call   800d16 <sys_page_alloc>
  801ba9:	89 c3                	mov    %eax,%ebx
  801bab:	83 c4 10             	add    $0x10,%esp
  801bae:	85 c0                	test   %eax,%eax
  801bb0:	0f 88 c3 00 00 00    	js     801c79 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801bb6:	83 ec 0c             	sub    $0xc,%esp
  801bb9:	ff 75 f4             	pushl  -0xc(%ebp)
  801bbc:	e8 af f5 ff ff       	call   801170 <fd2data>
  801bc1:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bc3:	83 c4 0c             	add    $0xc,%esp
  801bc6:	68 07 04 00 00       	push   $0x407
  801bcb:	50                   	push   %eax
  801bcc:	6a 00                	push   $0x0
  801bce:	e8 43 f1 ff ff       	call   800d16 <sys_page_alloc>
  801bd3:	89 c3                	mov    %eax,%ebx
  801bd5:	83 c4 10             	add    $0x10,%esp
  801bd8:	85 c0                	test   %eax,%eax
  801bda:	0f 88 89 00 00 00    	js     801c69 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801be0:	83 ec 0c             	sub    $0xc,%esp
  801be3:	ff 75 f0             	pushl  -0x10(%ebp)
  801be6:	e8 85 f5 ff ff       	call   801170 <fd2data>
  801beb:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801bf2:	50                   	push   %eax
  801bf3:	6a 00                	push   $0x0
  801bf5:	56                   	push   %esi
  801bf6:	6a 00                	push   $0x0
  801bf8:	e8 5c f1 ff ff       	call   800d59 <sys_page_map>
  801bfd:	89 c3                	mov    %eax,%ebx
  801bff:	83 c4 20             	add    $0x20,%esp
  801c02:	85 c0                	test   %eax,%eax
  801c04:	78 55                	js     801c5b <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c06:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c0f:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c11:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c14:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c1b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c21:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c24:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c26:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c29:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c30:	83 ec 0c             	sub    $0xc,%esp
  801c33:	ff 75 f4             	pushl  -0xc(%ebp)
  801c36:	e8 25 f5 ff ff       	call   801160 <fd2num>
  801c3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c3e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c40:	83 c4 04             	add    $0x4,%esp
  801c43:	ff 75 f0             	pushl  -0x10(%ebp)
  801c46:	e8 15 f5 ff ff       	call   801160 <fd2num>
  801c4b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c4e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c51:	83 c4 10             	add    $0x10,%esp
  801c54:	ba 00 00 00 00       	mov    $0x0,%edx
  801c59:	eb 30                	jmp    801c8b <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c5b:	83 ec 08             	sub    $0x8,%esp
  801c5e:	56                   	push   %esi
  801c5f:	6a 00                	push   $0x0
  801c61:	e8 35 f1 ff ff       	call   800d9b <sys_page_unmap>
  801c66:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c69:	83 ec 08             	sub    $0x8,%esp
  801c6c:	ff 75 f0             	pushl  -0x10(%ebp)
  801c6f:	6a 00                	push   $0x0
  801c71:	e8 25 f1 ff ff       	call   800d9b <sys_page_unmap>
  801c76:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c79:	83 ec 08             	sub    $0x8,%esp
  801c7c:	ff 75 f4             	pushl  -0xc(%ebp)
  801c7f:	6a 00                	push   $0x0
  801c81:	e8 15 f1 ff ff       	call   800d9b <sys_page_unmap>
  801c86:	83 c4 10             	add    $0x10,%esp
  801c89:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c8b:	89 d0                	mov    %edx,%eax
  801c8d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c90:	5b                   	pop    %ebx
  801c91:	5e                   	pop    %esi
  801c92:	5d                   	pop    %ebp
  801c93:	c3                   	ret    

00801c94 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c94:	55                   	push   %ebp
  801c95:	89 e5                	mov    %esp,%ebp
  801c97:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c9a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c9d:	50                   	push   %eax
  801c9e:	ff 75 08             	pushl  0x8(%ebp)
  801ca1:	e8 30 f5 ff ff       	call   8011d6 <fd_lookup>
  801ca6:	83 c4 10             	add    $0x10,%esp
  801ca9:	85 c0                	test   %eax,%eax
  801cab:	78 18                	js     801cc5 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801cad:	83 ec 0c             	sub    $0xc,%esp
  801cb0:	ff 75 f4             	pushl  -0xc(%ebp)
  801cb3:	e8 b8 f4 ff ff       	call   801170 <fd2data>
	return _pipeisclosed(fd, p);
  801cb8:	89 c2                	mov    %eax,%edx
  801cba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cbd:	e8 21 fd ff ff       	call   8019e3 <_pipeisclosed>
  801cc2:	83 c4 10             	add    $0x10,%esp
}
  801cc5:	c9                   	leave  
  801cc6:	c3                   	ret    

00801cc7 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801cc7:	55                   	push   %ebp
  801cc8:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801cca:	b8 00 00 00 00       	mov    $0x0,%eax
  801ccf:	5d                   	pop    %ebp
  801cd0:	c3                   	ret    

00801cd1 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801cd1:	55                   	push   %ebp
  801cd2:	89 e5                	mov    %esp,%ebp
  801cd4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801cd7:	68 f6 27 80 00       	push   $0x8027f6
  801cdc:	ff 75 0c             	pushl  0xc(%ebp)
  801cdf:	e8 2f ec ff ff       	call   800913 <strcpy>
	return 0;
}
  801ce4:	b8 00 00 00 00       	mov    $0x0,%eax
  801ce9:	c9                   	leave  
  801cea:	c3                   	ret    

00801ceb <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ceb:	55                   	push   %ebp
  801cec:	89 e5                	mov    %esp,%ebp
  801cee:	57                   	push   %edi
  801cef:	56                   	push   %esi
  801cf0:	53                   	push   %ebx
  801cf1:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cf7:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cfc:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d02:	eb 2d                	jmp    801d31 <devcons_write+0x46>
		m = n - tot;
  801d04:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d07:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d09:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d0c:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d11:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d14:	83 ec 04             	sub    $0x4,%esp
  801d17:	53                   	push   %ebx
  801d18:	03 45 0c             	add    0xc(%ebp),%eax
  801d1b:	50                   	push   %eax
  801d1c:	57                   	push   %edi
  801d1d:	e8 83 ed ff ff       	call   800aa5 <memmove>
		sys_cputs(buf, m);
  801d22:	83 c4 08             	add    $0x8,%esp
  801d25:	53                   	push   %ebx
  801d26:	57                   	push   %edi
  801d27:	e8 2e ef ff ff       	call   800c5a <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d2c:	01 de                	add    %ebx,%esi
  801d2e:	83 c4 10             	add    $0x10,%esp
  801d31:	89 f0                	mov    %esi,%eax
  801d33:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d36:	72 cc                	jb     801d04 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d3b:	5b                   	pop    %ebx
  801d3c:	5e                   	pop    %esi
  801d3d:	5f                   	pop    %edi
  801d3e:	5d                   	pop    %ebp
  801d3f:	c3                   	ret    

00801d40 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d40:	55                   	push   %ebp
  801d41:	89 e5                	mov    %esp,%ebp
  801d43:	83 ec 08             	sub    $0x8,%esp
  801d46:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d4b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d4f:	74 2a                	je     801d7b <devcons_read+0x3b>
  801d51:	eb 05                	jmp    801d58 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d53:	e8 9f ef ff ff       	call   800cf7 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d58:	e8 1b ef ff ff       	call   800c78 <sys_cgetc>
  801d5d:	85 c0                	test   %eax,%eax
  801d5f:	74 f2                	je     801d53 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d61:	85 c0                	test   %eax,%eax
  801d63:	78 16                	js     801d7b <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d65:	83 f8 04             	cmp    $0x4,%eax
  801d68:	74 0c                	je     801d76 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d6a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d6d:	88 02                	mov    %al,(%edx)
	return 1;
  801d6f:	b8 01 00 00 00       	mov    $0x1,%eax
  801d74:	eb 05                	jmp    801d7b <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d76:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d7b:	c9                   	leave  
  801d7c:	c3                   	ret    

00801d7d <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d7d:	55                   	push   %ebp
  801d7e:	89 e5                	mov    %esp,%ebp
  801d80:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d83:	8b 45 08             	mov    0x8(%ebp),%eax
  801d86:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d89:	6a 01                	push   $0x1
  801d8b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d8e:	50                   	push   %eax
  801d8f:	e8 c6 ee ff ff       	call   800c5a <sys_cputs>
}
  801d94:	83 c4 10             	add    $0x10,%esp
  801d97:	c9                   	leave  
  801d98:	c3                   	ret    

00801d99 <getchar>:

int
getchar(void)
{
  801d99:	55                   	push   %ebp
  801d9a:	89 e5                	mov    %esp,%ebp
  801d9c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d9f:	6a 01                	push   $0x1
  801da1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801da4:	50                   	push   %eax
  801da5:	6a 00                	push   $0x0
  801da7:	e8 90 f6 ff ff       	call   80143c <read>
	if (r < 0)
  801dac:	83 c4 10             	add    $0x10,%esp
  801daf:	85 c0                	test   %eax,%eax
  801db1:	78 0f                	js     801dc2 <getchar+0x29>
		return r;
	if (r < 1)
  801db3:	85 c0                	test   %eax,%eax
  801db5:	7e 06                	jle    801dbd <getchar+0x24>
		return -E_EOF;
	return c;
  801db7:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801dbb:	eb 05                	jmp    801dc2 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801dbd:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801dc2:	c9                   	leave  
  801dc3:	c3                   	ret    

00801dc4 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801dc4:	55                   	push   %ebp
  801dc5:	89 e5                	mov    %esp,%ebp
  801dc7:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dcd:	50                   	push   %eax
  801dce:	ff 75 08             	pushl  0x8(%ebp)
  801dd1:	e8 00 f4 ff ff       	call   8011d6 <fd_lookup>
  801dd6:	83 c4 10             	add    $0x10,%esp
  801dd9:	85 c0                	test   %eax,%eax
  801ddb:	78 11                	js     801dee <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ddd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801de0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801de6:	39 10                	cmp    %edx,(%eax)
  801de8:	0f 94 c0             	sete   %al
  801deb:	0f b6 c0             	movzbl %al,%eax
}
  801dee:	c9                   	leave  
  801def:	c3                   	ret    

00801df0 <opencons>:

int
opencons(void)
{
  801df0:	55                   	push   %ebp
  801df1:	89 e5                	mov    %esp,%ebp
  801df3:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801df6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801df9:	50                   	push   %eax
  801dfa:	e8 88 f3 ff ff       	call   801187 <fd_alloc>
  801dff:	83 c4 10             	add    $0x10,%esp
		return r;
  801e02:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e04:	85 c0                	test   %eax,%eax
  801e06:	78 3e                	js     801e46 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e08:	83 ec 04             	sub    $0x4,%esp
  801e0b:	68 07 04 00 00       	push   $0x407
  801e10:	ff 75 f4             	pushl  -0xc(%ebp)
  801e13:	6a 00                	push   $0x0
  801e15:	e8 fc ee ff ff       	call   800d16 <sys_page_alloc>
  801e1a:	83 c4 10             	add    $0x10,%esp
		return r;
  801e1d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e1f:	85 c0                	test   %eax,%eax
  801e21:	78 23                	js     801e46 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e23:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e29:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e2c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e31:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e38:	83 ec 0c             	sub    $0xc,%esp
  801e3b:	50                   	push   %eax
  801e3c:	e8 1f f3 ff ff       	call   801160 <fd2num>
  801e41:	89 c2                	mov    %eax,%edx
  801e43:	83 c4 10             	add    $0x10,%esp
}
  801e46:	89 d0                	mov    %edx,%eax
  801e48:	c9                   	leave  
  801e49:	c3                   	ret    

00801e4a <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e4a:	55                   	push   %ebp
  801e4b:	89 e5                	mov    %esp,%ebp
  801e4d:	53                   	push   %ebx
  801e4e:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801e51:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e58:	75 28                	jne    801e82 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		void *va = (void *) (UXSTACKTOP - PGSIZE);
		envid_t envid = sys_getenvid();
  801e5a:	e8 79 ee ff ff       	call   800cd8 <sys_getenvid>
  801e5f:	89 c3                	mov    %eax,%ebx

		sys_page_alloc(envid, va, PTE_P | PTE_U | PTE_W);
  801e61:	83 ec 04             	sub    $0x4,%esp
  801e64:	6a 07                	push   $0x7
  801e66:	68 00 f0 bf ee       	push   $0xeebff000
  801e6b:	50                   	push   %eax
  801e6c:	e8 a5 ee ff ff       	call   800d16 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801e71:	83 c4 08             	add    $0x8,%esp
  801e74:	68 8f 1e 80 00       	push   $0x801e8f
  801e79:	53                   	push   %ebx
  801e7a:	e8 e2 ef ff ff       	call   800e61 <sys_env_set_pgfault_upcall>
  801e7f:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e82:	8b 45 08             	mov    0x8(%ebp),%eax
  801e85:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801e8a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e8d:	c9                   	leave  
  801e8e:	c3                   	ret    

00801e8f <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp				// function argument: pointer to UTF
  801e8f:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e90:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e95:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e97:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp, %ebx		// 40 = size between utf_fault_va ~ utf_regs
  801e9a:	89 e3                	mov    %esp,%ebx
	movl 40(%esp), %eax // point to utf_eip
  801e9c:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %esp // point to utf_esp
  801ea0:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax 			// push eip of utf
  801ea4:	50                   	push   %eax

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx, %esp 	// back to origin exception stack
  801ea5:	89 dc                	mov    %ebx,%esp
	subl $4, 48(%esp) 	// utf_esp - 4
  801ea7:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	popl %eax  			// pop utf_fault_va (ignore)
  801eac:	58                   	pop    %eax
	popl %eax  			// pop utf_err (ignore)
  801ead:	58                   	pop    %eax
	popal 				// pop utf_regs 
  801eae:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4, %esp 		// ignore utf_eip
  801eaf:	83 c4 04             	add    $0x4,%esp
	popfl 				// restore utf_eflags to eflags
  801eb2:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp  			// restore %esp = utf_esp
  801eb3:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801eb4:	c3                   	ret    

00801eb5 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801eb5:	55                   	push   %ebp
  801eb6:	89 e5                	mov    %esp,%ebp
  801eb8:	56                   	push   %esi
  801eb9:	53                   	push   %ebx
  801eba:	8b 75 08             	mov    0x8(%ebp),%esi
  801ebd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ec0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

    if (pg != NULL)
  801ec3:	85 c0                	test   %eax,%eax
  801ec5:	74 0e                	je     801ed5 <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  801ec7:	83 ec 0c             	sub    $0xc,%esp
  801eca:	50                   	push   %eax
  801ecb:	e8 f6 ef ff ff       	call   800ec6 <sys_ipc_recv>
  801ed0:	83 c4 10             	add    $0x10,%esp
  801ed3:	eb 0d                	jmp    801ee2 <ipc_recv+0x2d>
	else
        r = sys_ipc_recv((void *)-1);
  801ed5:	83 ec 0c             	sub    $0xc,%esp
  801ed8:	6a ff                	push   $0xffffffff
  801eda:	e8 e7 ef ff ff       	call   800ec6 <sys_ipc_recv>
  801edf:	83 c4 10             	add    $0x10,%esp

	if (r < 0) {
  801ee2:	85 c0                	test   %eax,%eax
  801ee4:	79 16                	jns    801efc <ipc_recv+0x47>

		if (from_env_store != NULL)
  801ee6:	85 f6                	test   %esi,%esi
  801ee8:	74 06                	je     801ef0 <ipc_recv+0x3b>
			*from_env_store = 0;
  801eea:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL)
  801ef0:	85 db                	test   %ebx,%ebx
  801ef2:	74 2c                	je     801f20 <ipc_recv+0x6b>
			*perm_store = 0;
  801ef4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801efa:	eb 24                	jmp    801f20 <ipc_recv+0x6b>
		return r;

	} else {

		if (from_env_store != NULL)
  801efc:	85 f6                	test   %esi,%esi
  801efe:	74 0a                	je     801f0a <ipc_recv+0x55>
			*from_env_store = thisenv->env_ipc_from;
  801f00:	a1 04 40 80 00       	mov    0x804004,%eax
  801f05:	8b 40 74             	mov    0x74(%eax),%eax
  801f08:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL)
  801f0a:	85 db                	test   %ebx,%ebx
  801f0c:	74 0a                	je     801f18 <ipc_recv+0x63>
			*perm_store = thisenv->env_ipc_perm;
  801f0e:	a1 04 40 80 00       	mov    0x804004,%eax
  801f13:	8b 40 78             	mov    0x78(%eax),%eax
  801f16:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801f18:	a1 04 40 80 00       	mov    0x804004,%eax
  801f1d:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801f20:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f23:	5b                   	pop    %ebx
  801f24:	5e                   	pop    %esi
  801f25:	5d                   	pop    %ebp
  801f26:	c3                   	ret    

00801f27 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f27:	55                   	push   %ebp
  801f28:	89 e5                	mov    %esp,%ebp
  801f2a:	57                   	push   %edi
  801f2b:	56                   	push   %esi
  801f2c:	53                   	push   %ebx
  801f2d:	83 ec 0c             	sub    $0xc,%esp
  801f30:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f33:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f36:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

	if (pg == NULL)
  801f39:	85 db                	test   %ebx,%ebx
		pg = (void *)-1;	
  801f3b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801f40:	0f 44 d8             	cmove  %eax,%ebx

	while (true) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801f43:	ff 75 14             	pushl  0x14(%ebp)
  801f46:	53                   	push   %ebx
  801f47:	56                   	push   %esi
  801f48:	57                   	push   %edi
  801f49:	e8 55 ef ff ff       	call   800ea3 <sys_ipc_try_send>
		if (r >= 0)
  801f4e:	83 c4 10             	add    $0x10,%esp
  801f51:	85 c0                	test   %eax,%eax
  801f53:	79 1e                	jns    801f73 <ipc_send+0x4c>
			return;
		else if (r != -E_IPC_NOT_RECV)
  801f55:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f58:	74 12                	je     801f6c <ipc_send+0x45>
			panic("ipc_send error: %e", r);
  801f5a:	50                   	push   %eax
  801f5b:	68 02 28 80 00       	push   $0x802802
  801f60:	6a 49                	push   $0x49
  801f62:	68 15 28 80 00       	push   $0x802815
  801f67:	e8 ca e2 ff ff       	call   800236 <_panic>
	
		sys_yield();
  801f6c:	e8 86 ed ff ff       	call   800cf7 <sys_yield>
	}
  801f71:	eb d0                	jmp    801f43 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  801f73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f76:	5b                   	pop    %ebx
  801f77:	5e                   	pop    %esi
  801f78:	5f                   	pop    %edi
  801f79:	5d                   	pop    %ebp
  801f7a:	c3                   	ret    

00801f7b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f7b:	55                   	push   %ebp
  801f7c:	89 e5                	mov    %esp,%ebp
  801f7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f81:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f86:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f89:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f8f:	8b 52 50             	mov    0x50(%edx),%edx
  801f92:	39 ca                	cmp    %ecx,%edx
  801f94:	75 0d                	jne    801fa3 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f96:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f99:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f9e:	8b 40 48             	mov    0x48(%eax),%eax
  801fa1:	eb 0f                	jmp    801fb2 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fa3:	83 c0 01             	add    $0x1,%eax
  801fa6:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fab:	75 d9                	jne    801f86 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801fad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fb2:	5d                   	pop    %ebp
  801fb3:	c3                   	ret    

00801fb4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fb4:	55                   	push   %ebp
  801fb5:	89 e5                	mov    %esp,%ebp
  801fb7:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fba:	89 d0                	mov    %edx,%eax
  801fbc:	c1 e8 16             	shr    $0x16,%eax
  801fbf:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fc6:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fcb:	f6 c1 01             	test   $0x1,%cl
  801fce:	74 1d                	je     801fed <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fd0:	c1 ea 0c             	shr    $0xc,%edx
  801fd3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fda:	f6 c2 01             	test   $0x1,%dl
  801fdd:	74 0e                	je     801fed <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fdf:	c1 ea 0c             	shr    $0xc,%edx
  801fe2:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fe9:	ef 
  801fea:	0f b7 c0             	movzwl %ax,%eax
}
  801fed:	5d                   	pop    %ebp
  801fee:	c3                   	ret    
  801fef:	90                   	nop

00801ff0 <__udivdi3>:
  801ff0:	55                   	push   %ebp
  801ff1:	57                   	push   %edi
  801ff2:	56                   	push   %esi
  801ff3:	53                   	push   %ebx
  801ff4:	83 ec 1c             	sub    $0x1c,%esp
  801ff7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801ffb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802003:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802007:	85 f6                	test   %esi,%esi
  802009:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80200d:	89 ca                	mov    %ecx,%edx
  80200f:	89 f8                	mov    %edi,%eax
  802011:	75 3d                	jne    802050 <__udivdi3+0x60>
  802013:	39 cf                	cmp    %ecx,%edi
  802015:	0f 87 c5 00 00 00    	ja     8020e0 <__udivdi3+0xf0>
  80201b:	85 ff                	test   %edi,%edi
  80201d:	89 fd                	mov    %edi,%ebp
  80201f:	75 0b                	jne    80202c <__udivdi3+0x3c>
  802021:	b8 01 00 00 00       	mov    $0x1,%eax
  802026:	31 d2                	xor    %edx,%edx
  802028:	f7 f7                	div    %edi
  80202a:	89 c5                	mov    %eax,%ebp
  80202c:	89 c8                	mov    %ecx,%eax
  80202e:	31 d2                	xor    %edx,%edx
  802030:	f7 f5                	div    %ebp
  802032:	89 c1                	mov    %eax,%ecx
  802034:	89 d8                	mov    %ebx,%eax
  802036:	89 cf                	mov    %ecx,%edi
  802038:	f7 f5                	div    %ebp
  80203a:	89 c3                	mov    %eax,%ebx
  80203c:	89 d8                	mov    %ebx,%eax
  80203e:	89 fa                	mov    %edi,%edx
  802040:	83 c4 1c             	add    $0x1c,%esp
  802043:	5b                   	pop    %ebx
  802044:	5e                   	pop    %esi
  802045:	5f                   	pop    %edi
  802046:	5d                   	pop    %ebp
  802047:	c3                   	ret    
  802048:	90                   	nop
  802049:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802050:	39 ce                	cmp    %ecx,%esi
  802052:	77 74                	ja     8020c8 <__udivdi3+0xd8>
  802054:	0f bd fe             	bsr    %esi,%edi
  802057:	83 f7 1f             	xor    $0x1f,%edi
  80205a:	0f 84 98 00 00 00    	je     8020f8 <__udivdi3+0x108>
  802060:	bb 20 00 00 00       	mov    $0x20,%ebx
  802065:	89 f9                	mov    %edi,%ecx
  802067:	89 c5                	mov    %eax,%ebp
  802069:	29 fb                	sub    %edi,%ebx
  80206b:	d3 e6                	shl    %cl,%esi
  80206d:	89 d9                	mov    %ebx,%ecx
  80206f:	d3 ed                	shr    %cl,%ebp
  802071:	89 f9                	mov    %edi,%ecx
  802073:	d3 e0                	shl    %cl,%eax
  802075:	09 ee                	or     %ebp,%esi
  802077:	89 d9                	mov    %ebx,%ecx
  802079:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80207d:	89 d5                	mov    %edx,%ebp
  80207f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802083:	d3 ed                	shr    %cl,%ebp
  802085:	89 f9                	mov    %edi,%ecx
  802087:	d3 e2                	shl    %cl,%edx
  802089:	89 d9                	mov    %ebx,%ecx
  80208b:	d3 e8                	shr    %cl,%eax
  80208d:	09 c2                	or     %eax,%edx
  80208f:	89 d0                	mov    %edx,%eax
  802091:	89 ea                	mov    %ebp,%edx
  802093:	f7 f6                	div    %esi
  802095:	89 d5                	mov    %edx,%ebp
  802097:	89 c3                	mov    %eax,%ebx
  802099:	f7 64 24 0c          	mull   0xc(%esp)
  80209d:	39 d5                	cmp    %edx,%ebp
  80209f:	72 10                	jb     8020b1 <__udivdi3+0xc1>
  8020a1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8020a5:	89 f9                	mov    %edi,%ecx
  8020a7:	d3 e6                	shl    %cl,%esi
  8020a9:	39 c6                	cmp    %eax,%esi
  8020ab:	73 07                	jae    8020b4 <__udivdi3+0xc4>
  8020ad:	39 d5                	cmp    %edx,%ebp
  8020af:	75 03                	jne    8020b4 <__udivdi3+0xc4>
  8020b1:	83 eb 01             	sub    $0x1,%ebx
  8020b4:	31 ff                	xor    %edi,%edi
  8020b6:	89 d8                	mov    %ebx,%eax
  8020b8:	89 fa                	mov    %edi,%edx
  8020ba:	83 c4 1c             	add    $0x1c,%esp
  8020bd:	5b                   	pop    %ebx
  8020be:	5e                   	pop    %esi
  8020bf:	5f                   	pop    %edi
  8020c0:	5d                   	pop    %ebp
  8020c1:	c3                   	ret    
  8020c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020c8:	31 ff                	xor    %edi,%edi
  8020ca:	31 db                	xor    %ebx,%ebx
  8020cc:	89 d8                	mov    %ebx,%eax
  8020ce:	89 fa                	mov    %edi,%edx
  8020d0:	83 c4 1c             	add    $0x1c,%esp
  8020d3:	5b                   	pop    %ebx
  8020d4:	5e                   	pop    %esi
  8020d5:	5f                   	pop    %edi
  8020d6:	5d                   	pop    %ebp
  8020d7:	c3                   	ret    
  8020d8:	90                   	nop
  8020d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020e0:	89 d8                	mov    %ebx,%eax
  8020e2:	f7 f7                	div    %edi
  8020e4:	31 ff                	xor    %edi,%edi
  8020e6:	89 c3                	mov    %eax,%ebx
  8020e8:	89 d8                	mov    %ebx,%eax
  8020ea:	89 fa                	mov    %edi,%edx
  8020ec:	83 c4 1c             	add    $0x1c,%esp
  8020ef:	5b                   	pop    %ebx
  8020f0:	5e                   	pop    %esi
  8020f1:	5f                   	pop    %edi
  8020f2:	5d                   	pop    %ebp
  8020f3:	c3                   	ret    
  8020f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020f8:	39 ce                	cmp    %ecx,%esi
  8020fa:	72 0c                	jb     802108 <__udivdi3+0x118>
  8020fc:	31 db                	xor    %ebx,%ebx
  8020fe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802102:	0f 87 34 ff ff ff    	ja     80203c <__udivdi3+0x4c>
  802108:	bb 01 00 00 00       	mov    $0x1,%ebx
  80210d:	e9 2a ff ff ff       	jmp    80203c <__udivdi3+0x4c>
  802112:	66 90                	xchg   %ax,%ax
  802114:	66 90                	xchg   %ax,%ax
  802116:	66 90                	xchg   %ax,%ax
  802118:	66 90                	xchg   %ax,%ax
  80211a:	66 90                	xchg   %ax,%ax
  80211c:	66 90                	xchg   %ax,%ax
  80211e:	66 90                	xchg   %ax,%ax

00802120 <__umoddi3>:
  802120:	55                   	push   %ebp
  802121:	57                   	push   %edi
  802122:	56                   	push   %esi
  802123:	53                   	push   %ebx
  802124:	83 ec 1c             	sub    $0x1c,%esp
  802127:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80212b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80212f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802133:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802137:	85 d2                	test   %edx,%edx
  802139:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80213d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802141:	89 f3                	mov    %esi,%ebx
  802143:	89 3c 24             	mov    %edi,(%esp)
  802146:	89 74 24 04          	mov    %esi,0x4(%esp)
  80214a:	75 1c                	jne    802168 <__umoddi3+0x48>
  80214c:	39 f7                	cmp    %esi,%edi
  80214e:	76 50                	jbe    8021a0 <__umoddi3+0x80>
  802150:	89 c8                	mov    %ecx,%eax
  802152:	89 f2                	mov    %esi,%edx
  802154:	f7 f7                	div    %edi
  802156:	89 d0                	mov    %edx,%eax
  802158:	31 d2                	xor    %edx,%edx
  80215a:	83 c4 1c             	add    $0x1c,%esp
  80215d:	5b                   	pop    %ebx
  80215e:	5e                   	pop    %esi
  80215f:	5f                   	pop    %edi
  802160:	5d                   	pop    %ebp
  802161:	c3                   	ret    
  802162:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802168:	39 f2                	cmp    %esi,%edx
  80216a:	89 d0                	mov    %edx,%eax
  80216c:	77 52                	ja     8021c0 <__umoddi3+0xa0>
  80216e:	0f bd ea             	bsr    %edx,%ebp
  802171:	83 f5 1f             	xor    $0x1f,%ebp
  802174:	75 5a                	jne    8021d0 <__umoddi3+0xb0>
  802176:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80217a:	0f 82 e0 00 00 00    	jb     802260 <__umoddi3+0x140>
  802180:	39 0c 24             	cmp    %ecx,(%esp)
  802183:	0f 86 d7 00 00 00    	jbe    802260 <__umoddi3+0x140>
  802189:	8b 44 24 08          	mov    0x8(%esp),%eax
  80218d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802191:	83 c4 1c             	add    $0x1c,%esp
  802194:	5b                   	pop    %ebx
  802195:	5e                   	pop    %esi
  802196:	5f                   	pop    %edi
  802197:	5d                   	pop    %ebp
  802198:	c3                   	ret    
  802199:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021a0:	85 ff                	test   %edi,%edi
  8021a2:	89 fd                	mov    %edi,%ebp
  8021a4:	75 0b                	jne    8021b1 <__umoddi3+0x91>
  8021a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021ab:	31 d2                	xor    %edx,%edx
  8021ad:	f7 f7                	div    %edi
  8021af:	89 c5                	mov    %eax,%ebp
  8021b1:	89 f0                	mov    %esi,%eax
  8021b3:	31 d2                	xor    %edx,%edx
  8021b5:	f7 f5                	div    %ebp
  8021b7:	89 c8                	mov    %ecx,%eax
  8021b9:	f7 f5                	div    %ebp
  8021bb:	89 d0                	mov    %edx,%eax
  8021bd:	eb 99                	jmp    802158 <__umoddi3+0x38>
  8021bf:	90                   	nop
  8021c0:	89 c8                	mov    %ecx,%eax
  8021c2:	89 f2                	mov    %esi,%edx
  8021c4:	83 c4 1c             	add    $0x1c,%esp
  8021c7:	5b                   	pop    %ebx
  8021c8:	5e                   	pop    %esi
  8021c9:	5f                   	pop    %edi
  8021ca:	5d                   	pop    %ebp
  8021cb:	c3                   	ret    
  8021cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	8b 34 24             	mov    (%esp),%esi
  8021d3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021d8:	89 e9                	mov    %ebp,%ecx
  8021da:	29 ef                	sub    %ebp,%edi
  8021dc:	d3 e0                	shl    %cl,%eax
  8021de:	89 f9                	mov    %edi,%ecx
  8021e0:	89 f2                	mov    %esi,%edx
  8021e2:	d3 ea                	shr    %cl,%edx
  8021e4:	89 e9                	mov    %ebp,%ecx
  8021e6:	09 c2                	or     %eax,%edx
  8021e8:	89 d8                	mov    %ebx,%eax
  8021ea:	89 14 24             	mov    %edx,(%esp)
  8021ed:	89 f2                	mov    %esi,%edx
  8021ef:	d3 e2                	shl    %cl,%edx
  8021f1:	89 f9                	mov    %edi,%ecx
  8021f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021f7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021fb:	d3 e8                	shr    %cl,%eax
  8021fd:	89 e9                	mov    %ebp,%ecx
  8021ff:	89 c6                	mov    %eax,%esi
  802201:	d3 e3                	shl    %cl,%ebx
  802203:	89 f9                	mov    %edi,%ecx
  802205:	89 d0                	mov    %edx,%eax
  802207:	d3 e8                	shr    %cl,%eax
  802209:	89 e9                	mov    %ebp,%ecx
  80220b:	09 d8                	or     %ebx,%eax
  80220d:	89 d3                	mov    %edx,%ebx
  80220f:	89 f2                	mov    %esi,%edx
  802211:	f7 34 24             	divl   (%esp)
  802214:	89 d6                	mov    %edx,%esi
  802216:	d3 e3                	shl    %cl,%ebx
  802218:	f7 64 24 04          	mull   0x4(%esp)
  80221c:	39 d6                	cmp    %edx,%esi
  80221e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802222:	89 d1                	mov    %edx,%ecx
  802224:	89 c3                	mov    %eax,%ebx
  802226:	72 08                	jb     802230 <__umoddi3+0x110>
  802228:	75 11                	jne    80223b <__umoddi3+0x11b>
  80222a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80222e:	73 0b                	jae    80223b <__umoddi3+0x11b>
  802230:	2b 44 24 04          	sub    0x4(%esp),%eax
  802234:	1b 14 24             	sbb    (%esp),%edx
  802237:	89 d1                	mov    %edx,%ecx
  802239:	89 c3                	mov    %eax,%ebx
  80223b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80223f:	29 da                	sub    %ebx,%edx
  802241:	19 ce                	sbb    %ecx,%esi
  802243:	89 f9                	mov    %edi,%ecx
  802245:	89 f0                	mov    %esi,%eax
  802247:	d3 e0                	shl    %cl,%eax
  802249:	89 e9                	mov    %ebp,%ecx
  80224b:	d3 ea                	shr    %cl,%edx
  80224d:	89 e9                	mov    %ebp,%ecx
  80224f:	d3 ee                	shr    %cl,%esi
  802251:	09 d0                	or     %edx,%eax
  802253:	89 f2                	mov    %esi,%edx
  802255:	83 c4 1c             	add    $0x1c,%esp
  802258:	5b                   	pop    %ebx
  802259:	5e                   	pop    %esi
  80225a:	5f                   	pop    %edi
  80225b:	5d                   	pop    %ebp
  80225c:	c3                   	ret    
  80225d:	8d 76 00             	lea    0x0(%esi),%esi
  802260:	29 f9                	sub    %edi,%ecx
  802262:	19 d6                	sbb    %edx,%esi
  802264:	89 74 24 04          	mov    %esi,0x4(%esp)
  802268:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80226c:	e9 18 ff ff ff       	jmp    802189 <__umoddi3+0x69>
