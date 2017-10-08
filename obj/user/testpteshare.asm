
obj/user/testpteshare.debug：     文件格式 elf32-i386


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
  80002c:	e8 47 01 00 00       	call   800178 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <childofspawn>:
	breakpoint();
}

void
childofspawn(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	strcpy(VA, msg2);
  800039:	ff 35 00 30 80 00    	pushl  0x803000
  80003f:	68 00 00 00 a0       	push   $0xa0000000
  800044:	e8 6c 08 00 00       	call   8008b5 <strcpy>
	exit();
  800049:	e8 70 01 00 00       	call   8001be <exit>
}
  80004e:	83 c4 10             	add    $0x10,%esp
  800051:	c9                   	leave  
  800052:	c3                   	ret    

00800053 <umain>:

void childofspawn(void);

void
umain(int argc, char **argv)
{
  800053:	55                   	push   %ebp
  800054:	89 e5                	mov    %esp,%ebp
  800056:	53                   	push   %ebx
  800057:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (argc != 0)
  80005a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80005e:	74 05                	je     800065 <umain+0x12>
		childofspawn();
  800060:	e8 ce ff ff ff       	call   800033 <childofspawn>

	if ((r = sys_page_alloc(0, VA, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800065:	83 ec 04             	sub    $0x4,%esp
  800068:	68 07 04 00 00       	push   $0x407
  80006d:	68 00 00 00 a0       	push   $0xa0000000
  800072:	6a 00                	push   $0x0
  800074:	e8 3f 0c 00 00       	call   800cb8 <sys_page_alloc>
  800079:	83 c4 10             	add    $0x10,%esp
  80007c:	85 c0                	test   %eax,%eax
  80007e:	79 12                	jns    800092 <umain+0x3f>
		panic("sys_page_alloc: %e", r);
  800080:	50                   	push   %eax
  800081:	68 2c 28 80 00       	push   $0x80282c
  800086:	6a 13                	push   $0x13
  800088:	68 3f 28 80 00       	push   $0x80283f
  80008d:	e8 46 01 00 00       	call   8001d8 <_panic>

	// check fork
	if ((r = fork()) < 0)
  800092:	e8 b7 0e 00 00       	call   800f4e <fork>
  800097:	89 c3                	mov    %eax,%ebx
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 12                	jns    8000af <umain+0x5c>
		panic("fork: %e", r);
  80009d:	50                   	push   %eax
  80009e:	68 53 28 80 00       	push   $0x802853
  8000a3:	6a 17                	push   $0x17
  8000a5:	68 3f 28 80 00       	push   $0x80283f
  8000aa:	e8 29 01 00 00       	call   8001d8 <_panic>
	if (r == 0) {
  8000af:	85 c0                	test   %eax,%eax
  8000b1:	75 1b                	jne    8000ce <umain+0x7b>
		strcpy(VA, msg);
  8000b3:	83 ec 08             	sub    $0x8,%esp
  8000b6:	ff 35 04 30 80 00    	pushl  0x803004
  8000bc:	68 00 00 00 a0       	push   $0xa0000000
  8000c1:	e8 ef 07 00 00       	call   8008b5 <strcpy>
		exit();
  8000c6:	e8 f3 00 00 00       	call   8001be <exit>
  8000cb:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	53                   	push   %ebx
  8000d2:	e8 2e 21 00 00       	call   802205 <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000d7:	83 c4 08             	add    $0x8,%esp
  8000da:	ff 35 04 30 80 00    	pushl  0x803004
  8000e0:	68 00 00 00 a0       	push   $0xa0000000
  8000e5:	e8 75 08 00 00       	call   80095f <strcmp>
  8000ea:	83 c4 08             	add    $0x8,%esp
  8000ed:	85 c0                	test   %eax,%eax
  8000ef:	ba 26 28 80 00       	mov    $0x802826,%edx
  8000f4:	b8 20 28 80 00       	mov    $0x802820,%eax
  8000f9:	0f 45 c2             	cmovne %edx,%eax
  8000fc:	50                   	push   %eax
  8000fd:	68 5c 28 80 00       	push   $0x80285c
  800102:	e8 aa 01 00 00       	call   8002b1 <cprintf>

	// check spawn
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  800107:	6a 00                	push   $0x0
  800109:	68 77 28 80 00       	push   $0x802877
  80010e:	68 7c 28 80 00       	push   $0x80287c
  800113:	68 7b 28 80 00       	push   $0x80287b
  800118:	e8 19 1d 00 00       	call   801e36 <spawnl>
  80011d:	83 c4 20             	add    $0x20,%esp
  800120:	85 c0                	test   %eax,%eax
  800122:	79 12                	jns    800136 <umain+0xe3>
		panic("spawn: %e", r);
  800124:	50                   	push   %eax
  800125:	68 89 28 80 00       	push   $0x802889
  80012a:	6a 21                	push   $0x21
  80012c:	68 3f 28 80 00       	push   $0x80283f
  800131:	e8 a2 00 00 00       	call   8001d8 <_panic>
	wait(r);
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	50                   	push   %eax
  80013a:	e8 c6 20 00 00       	call   802205 <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  80013f:	83 c4 08             	add    $0x8,%esp
  800142:	ff 35 00 30 80 00    	pushl  0x803000
  800148:	68 00 00 00 a0       	push   $0xa0000000
  80014d:	e8 0d 08 00 00       	call   80095f <strcmp>
  800152:	83 c4 08             	add    $0x8,%esp
  800155:	85 c0                	test   %eax,%eax
  800157:	ba 26 28 80 00       	mov    $0x802826,%edx
  80015c:	b8 20 28 80 00       	mov    $0x802820,%eax
  800161:	0f 45 c2             	cmovne %edx,%eax
  800164:	50                   	push   %eax
  800165:	68 93 28 80 00       	push   $0x802893
  80016a:	e8 42 01 00 00       	call   8002b1 <cprintf>
static __inline uint64_t read_tsc(void) __attribute__((always_inline));

static __inline void
breakpoint(void)
{
	__asm __volatile("int3");
  80016f:	cc                   	int3   

	breakpoint();
}
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800176:	c9                   	leave  
  800177:	c3                   	ret    

00800178 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	56                   	push   %esi
  80017c:	53                   	push   %ebx
  80017d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800180:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800183:	e8 f2 0a 00 00       	call   800c7a <sys_getenvid>
  800188:	25 ff 03 00 00       	and    $0x3ff,%eax
  80018d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800190:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800195:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80019a:	85 db                	test   %ebx,%ebx
  80019c:	7e 07                	jle    8001a5 <libmain+0x2d>
		binaryname = argv[0];
  80019e:	8b 06                	mov    (%esi),%eax
  8001a0:	a3 08 30 80 00       	mov    %eax,0x803008

	// call user main routine
	umain(argc, argv);
  8001a5:	83 ec 08             	sub    $0x8,%esp
  8001a8:	56                   	push   %esi
  8001a9:	53                   	push   %ebx
  8001aa:	e8 a4 fe ff ff       	call   800053 <umain>

	// exit gracefully
	exit();
  8001af:	e8 0a 00 00 00       	call   8001be <exit>
}
  8001b4:	83 c4 10             	add    $0x10,%esp
  8001b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001ba:	5b                   	pop    %ebx
  8001bb:	5e                   	pop    %esi
  8001bc:	5d                   	pop    %ebp
  8001bd:	c3                   	ret    

008001be <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001be:	55                   	push   %ebp
  8001bf:	89 e5                	mov    %esp,%ebp
  8001c1:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001c4:	e8 04 11 00 00       	call   8012cd <close_all>
	sys_env_destroy(0);
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	6a 00                	push   $0x0
  8001ce:	e8 66 0a 00 00       	call   800c39 <sys_env_destroy>
}
  8001d3:	83 c4 10             	add    $0x10,%esp
  8001d6:	c9                   	leave  
  8001d7:	c3                   	ret    

008001d8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	56                   	push   %esi
  8001dc:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001dd:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001e0:	8b 35 08 30 80 00    	mov    0x803008,%esi
  8001e6:	e8 8f 0a 00 00       	call   800c7a <sys_getenvid>
  8001eb:	83 ec 0c             	sub    $0xc,%esp
  8001ee:	ff 75 0c             	pushl  0xc(%ebp)
  8001f1:	ff 75 08             	pushl  0x8(%ebp)
  8001f4:	56                   	push   %esi
  8001f5:	50                   	push   %eax
  8001f6:	68 d8 28 80 00       	push   $0x8028d8
  8001fb:	e8 b1 00 00 00       	call   8002b1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800200:	83 c4 18             	add    $0x18,%esp
  800203:	53                   	push   %ebx
  800204:	ff 75 10             	pushl  0x10(%ebp)
  800207:	e8 54 00 00 00       	call   800260 <vcprintf>
	cprintf("\n");
  80020c:	c7 04 24 08 2e 80 00 	movl   $0x802e08,(%esp)
  800213:	e8 99 00 00 00       	call   8002b1 <cprintf>
  800218:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80021b:	cc                   	int3   
  80021c:	eb fd                	jmp    80021b <_panic+0x43>

0080021e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80021e:	55                   	push   %ebp
  80021f:	89 e5                	mov    %esp,%ebp
  800221:	53                   	push   %ebx
  800222:	83 ec 04             	sub    $0x4,%esp
  800225:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800228:	8b 13                	mov    (%ebx),%edx
  80022a:	8d 42 01             	lea    0x1(%edx),%eax
  80022d:	89 03                	mov    %eax,(%ebx)
  80022f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800232:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800236:	3d ff 00 00 00       	cmp    $0xff,%eax
  80023b:	75 1a                	jne    800257 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80023d:	83 ec 08             	sub    $0x8,%esp
  800240:	68 ff 00 00 00       	push   $0xff
  800245:	8d 43 08             	lea    0x8(%ebx),%eax
  800248:	50                   	push   %eax
  800249:	e8 ae 09 00 00       	call   800bfc <sys_cputs>
		b->idx = 0;
  80024e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800254:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800257:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80025b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80025e:	c9                   	leave  
  80025f:	c3                   	ret    

00800260 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800269:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800270:	00 00 00 
	b.cnt = 0;
  800273:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80027a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80027d:	ff 75 0c             	pushl  0xc(%ebp)
  800280:	ff 75 08             	pushl  0x8(%ebp)
  800283:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800289:	50                   	push   %eax
  80028a:	68 1e 02 80 00       	push   $0x80021e
  80028f:	e8 1a 01 00 00       	call   8003ae <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800294:	83 c4 08             	add    $0x8,%esp
  800297:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80029d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002a3:	50                   	push   %eax
  8002a4:	e8 53 09 00 00       	call   800bfc <sys_cputs>

	return b.cnt;
}
  8002a9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002af:	c9                   	leave  
  8002b0:	c3                   	ret    

008002b1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002b7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002ba:	50                   	push   %eax
  8002bb:	ff 75 08             	pushl  0x8(%ebp)
  8002be:	e8 9d ff ff ff       	call   800260 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002c3:	c9                   	leave  
  8002c4:	c3                   	ret    

008002c5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002c5:	55                   	push   %ebp
  8002c6:	89 e5                	mov    %esp,%ebp
  8002c8:	57                   	push   %edi
  8002c9:	56                   	push   %esi
  8002ca:	53                   	push   %ebx
  8002cb:	83 ec 1c             	sub    $0x1c,%esp
  8002ce:	89 c7                	mov    %eax,%edi
  8002d0:	89 d6                	mov    %edx,%esi
  8002d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002db:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002de:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002e9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002ec:	39 d3                	cmp    %edx,%ebx
  8002ee:	72 05                	jb     8002f5 <printnum+0x30>
  8002f0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002f3:	77 45                	ja     80033a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f5:	83 ec 0c             	sub    $0xc,%esp
  8002f8:	ff 75 18             	pushl  0x18(%ebp)
  8002fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8002fe:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800301:	53                   	push   %ebx
  800302:	ff 75 10             	pushl  0x10(%ebp)
  800305:	83 ec 08             	sub    $0x8,%esp
  800308:	ff 75 e4             	pushl  -0x1c(%ebp)
  80030b:	ff 75 e0             	pushl  -0x20(%ebp)
  80030e:	ff 75 dc             	pushl  -0x24(%ebp)
  800311:	ff 75 d8             	pushl  -0x28(%ebp)
  800314:	e8 67 22 00 00       	call   802580 <__udivdi3>
  800319:	83 c4 18             	add    $0x18,%esp
  80031c:	52                   	push   %edx
  80031d:	50                   	push   %eax
  80031e:	89 f2                	mov    %esi,%edx
  800320:	89 f8                	mov    %edi,%eax
  800322:	e8 9e ff ff ff       	call   8002c5 <printnum>
  800327:	83 c4 20             	add    $0x20,%esp
  80032a:	eb 18                	jmp    800344 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80032c:	83 ec 08             	sub    $0x8,%esp
  80032f:	56                   	push   %esi
  800330:	ff 75 18             	pushl  0x18(%ebp)
  800333:	ff d7                	call   *%edi
  800335:	83 c4 10             	add    $0x10,%esp
  800338:	eb 03                	jmp    80033d <printnum+0x78>
  80033a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80033d:	83 eb 01             	sub    $0x1,%ebx
  800340:	85 db                	test   %ebx,%ebx
  800342:	7f e8                	jg     80032c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800344:	83 ec 08             	sub    $0x8,%esp
  800347:	56                   	push   %esi
  800348:	83 ec 04             	sub    $0x4,%esp
  80034b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80034e:	ff 75 e0             	pushl  -0x20(%ebp)
  800351:	ff 75 dc             	pushl  -0x24(%ebp)
  800354:	ff 75 d8             	pushl  -0x28(%ebp)
  800357:	e8 54 23 00 00       	call   8026b0 <__umoddi3>
  80035c:	83 c4 14             	add    $0x14,%esp
  80035f:	0f be 80 fb 28 80 00 	movsbl 0x8028fb(%eax),%eax
  800366:	50                   	push   %eax
  800367:	ff d7                	call   *%edi
}
  800369:	83 c4 10             	add    $0x10,%esp
  80036c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80036f:	5b                   	pop    %ebx
  800370:	5e                   	pop    %esi
  800371:	5f                   	pop    %edi
  800372:	5d                   	pop    %ebp
  800373:	c3                   	ret    

00800374 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800374:	55                   	push   %ebp
  800375:	89 e5                	mov    %esp,%ebp
  800377:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80037a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80037e:	8b 10                	mov    (%eax),%edx
  800380:	3b 50 04             	cmp    0x4(%eax),%edx
  800383:	73 0a                	jae    80038f <sprintputch+0x1b>
		*b->buf++ = ch;
  800385:	8d 4a 01             	lea    0x1(%edx),%ecx
  800388:	89 08                	mov    %ecx,(%eax)
  80038a:	8b 45 08             	mov    0x8(%ebp),%eax
  80038d:	88 02                	mov    %al,(%edx)
}
  80038f:	5d                   	pop    %ebp
  800390:	c3                   	ret    

00800391 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800391:	55                   	push   %ebp
  800392:	89 e5                	mov    %esp,%ebp
  800394:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800397:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80039a:	50                   	push   %eax
  80039b:	ff 75 10             	pushl  0x10(%ebp)
  80039e:	ff 75 0c             	pushl  0xc(%ebp)
  8003a1:	ff 75 08             	pushl  0x8(%ebp)
  8003a4:	e8 05 00 00 00       	call   8003ae <vprintfmt>
	va_end(ap);
}
  8003a9:	83 c4 10             	add    $0x10,%esp
  8003ac:	c9                   	leave  
  8003ad:	c3                   	ret    

008003ae <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003ae:	55                   	push   %ebp
  8003af:	89 e5                	mov    %esp,%ebp
  8003b1:	57                   	push   %edi
  8003b2:	56                   	push   %esi
  8003b3:	53                   	push   %ebx
  8003b4:	83 ec 2c             	sub    $0x2c,%esp
  8003b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8003ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003bd:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003c0:	eb 12                	jmp    8003d4 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003c2:	85 c0                	test   %eax,%eax
  8003c4:	0f 84 42 04 00 00    	je     80080c <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8003ca:	83 ec 08             	sub    $0x8,%esp
  8003cd:	53                   	push   %ebx
  8003ce:	50                   	push   %eax
  8003cf:	ff d6                	call   *%esi
  8003d1:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003d4:	83 c7 01             	add    $0x1,%edi
  8003d7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003db:	83 f8 25             	cmp    $0x25,%eax
  8003de:	75 e2                	jne    8003c2 <vprintfmt+0x14>
  8003e0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003e4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003eb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003f2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003fe:	eb 07                	jmp    800407 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800400:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800403:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800407:	8d 47 01             	lea    0x1(%edi),%eax
  80040a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80040d:	0f b6 07             	movzbl (%edi),%eax
  800410:	0f b6 d0             	movzbl %al,%edx
  800413:	83 e8 23             	sub    $0x23,%eax
  800416:	3c 55                	cmp    $0x55,%al
  800418:	0f 87 d3 03 00 00    	ja     8007f1 <vprintfmt+0x443>
  80041e:	0f b6 c0             	movzbl %al,%eax
  800421:	ff 24 85 40 2a 80 00 	jmp    *0x802a40(,%eax,4)
  800428:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80042b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80042f:	eb d6                	jmp    800407 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800431:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800434:	b8 00 00 00 00       	mov    $0x0,%eax
  800439:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80043c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80043f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800443:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800446:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800449:	83 f9 09             	cmp    $0x9,%ecx
  80044c:	77 3f                	ja     80048d <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80044e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800451:	eb e9                	jmp    80043c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800453:	8b 45 14             	mov    0x14(%ebp),%eax
  800456:	8b 00                	mov    (%eax),%eax
  800458:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80045b:	8b 45 14             	mov    0x14(%ebp),%eax
  80045e:	8d 40 04             	lea    0x4(%eax),%eax
  800461:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800464:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800467:	eb 2a                	jmp    800493 <vprintfmt+0xe5>
  800469:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80046c:	85 c0                	test   %eax,%eax
  80046e:	ba 00 00 00 00       	mov    $0x0,%edx
  800473:	0f 49 d0             	cmovns %eax,%edx
  800476:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800479:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80047c:	eb 89                	jmp    800407 <vprintfmt+0x59>
  80047e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800481:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800488:	e9 7a ff ff ff       	jmp    800407 <vprintfmt+0x59>
  80048d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800490:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800493:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800497:	0f 89 6a ff ff ff    	jns    800407 <vprintfmt+0x59>
				width = precision, precision = -1;
  80049d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004a0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004aa:	e9 58 ff ff ff       	jmp    800407 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004af:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004b5:	e9 4d ff ff ff       	jmp    800407 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bd:	8d 78 04             	lea    0x4(%eax),%edi
  8004c0:	83 ec 08             	sub    $0x8,%esp
  8004c3:	53                   	push   %ebx
  8004c4:	ff 30                	pushl  (%eax)
  8004c6:	ff d6                	call   *%esi
			break;
  8004c8:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004cb:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004d1:	e9 fe fe ff ff       	jmp    8003d4 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d9:	8d 78 04             	lea    0x4(%eax),%edi
  8004dc:	8b 00                	mov    (%eax),%eax
  8004de:	99                   	cltd   
  8004df:	31 d0                	xor    %edx,%eax
  8004e1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004e3:	83 f8 0f             	cmp    $0xf,%eax
  8004e6:	7f 0b                	jg     8004f3 <vprintfmt+0x145>
  8004e8:	8b 14 85 a0 2b 80 00 	mov    0x802ba0(,%eax,4),%edx
  8004ef:	85 d2                	test   %edx,%edx
  8004f1:	75 1b                	jne    80050e <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8004f3:	50                   	push   %eax
  8004f4:	68 13 29 80 00       	push   $0x802913
  8004f9:	53                   	push   %ebx
  8004fa:	56                   	push   %esi
  8004fb:	e8 91 fe ff ff       	call   800391 <printfmt>
  800500:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800503:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800506:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800509:	e9 c6 fe ff ff       	jmp    8003d4 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80050e:	52                   	push   %edx
  80050f:	68 39 2d 80 00       	push   $0x802d39
  800514:	53                   	push   %ebx
  800515:	56                   	push   %esi
  800516:	e8 76 fe ff ff       	call   800391 <printfmt>
  80051b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80051e:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800521:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800524:	e9 ab fe ff ff       	jmp    8003d4 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800529:	8b 45 14             	mov    0x14(%ebp),%eax
  80052c:	83 c0 04             	add    $0x4,%eax
  80052f:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800532:	8b 45 14             	mov    0x14(%ebp),%eax
  800535:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800537:	85 ff                	test   %edi,%edi
  800539:	b8 0c 29 80 00       	mov    $0x80290c,%eax
  80053e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800541:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800545:	0f 8e 94 00 00 00    	jle    8005df <vprintfmt+0x231>
  80054b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80054f:	0f 84 98 00 00 00    	je     8005ed <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800555:	83 ec 08             	sub    $0x8,%esp
  800558:	ff 75 d0             	pushl  -0x30(%ebp)
  80055b:	57                   	push   %edi
  80055c:	e8 33 03 00 00       	call   800894 <strnlen>
  800561:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800564:	29 c1                	sub    %eax,%ecx
  800566:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800569:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80056c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800570:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800573:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800576:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800578:	eb 0f                	jmp    800589 <vprintfmt+0x1db>
					putch(padc, putdat);
  80057a:	83 ec 08             	sub    $0x8,%esp
  80057d:	53                   	push   %ebx
  80057e:	ff 75 e0             	pushl  -0x20(%ebp)
  800581:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800583:	83 ef 01             	sub    $0x1,%edi
  800586:	83 c4 10             	add    $0x10,%esp
  800589:	85 ff                	test   %edi,%edi
  80058b:	7f ed                	jg     80057a <vprintfmt+0x1cc>
  80058d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800590:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800593:	85 c9                	test   %ecx,%ecx
  800595:	b8 00 00 00 00       	mov    $0x0,%eax
  80059a:	0f 49 c1             	cmovns %ecx,%eax
  80059d:	29 c1                	sub    %eax,%ecx
  80059f:	89 75 08             	mov    %esi,0x8(%ebp)
  8005a2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005a5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005a8:	89 cb                	mov    %ecx,%ebx
  8005aa:	eb 4d                	jmp    8005f9 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005ac:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005b0:	74 1b                	je     8005cd <vprintfmt+0x21f>
  8005b2:	0f be c0             	movsbl %al,%eax
  8005b5:	83 e8 20             	sub    $0x20,%eax
  8005b8:	83 f8 5e             	cmp    $0x5e,%eax
  8005bb:	76 10                	jbe    8005cd <vprintfmt+0x21f>
					putch('?', putdat);
  8005bd:	83 ec 08             	sub    $0x8,%esp
  8005c0:	ff 75 0c             	pushl  0xc(%ebp)
  8005c3:	6a 3f                	push   $0x3f
  8005c5:	ff 55 08             	call   *0x8(%ebp)
  8005c8:	83 c4 10             	add    $0x10,%esp
  8005cb:	eb 0d                	jmp    8005da <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8005cd:	83 ec 08             	sub    $0x8,%esp
  8005d0:	ff 75 0c             	pushl  0xc(%ebp)
  8005d3:	52                   	push   %edx
  8005d4:	ff 55 08             	call   *0x8(%ebp)
  8005d7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005da:	83 eb 01             	sub    $0x1,%ebx
  8005dd:	eb 1a                	jmp    8005f9 <vprintfmt+0x24b>
  8005df:	89 75 08             	mov    %esi,0x8(%ebp)
  8005e2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005e5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005e8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005eb:	eb 0c                	jmp    8005f9 <vprintfmt+0x24b>
  8005ed:	89 75 08             	mov    %esi,0x8(%ebp)
  8005f0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005f3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005f6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005f9:	83 c7 01             	add    $0x1,%edi
  8005fc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800600:	0f be d0             	movsbl %al,%edx
  800603:	85 d2                	test   %edx,%edx
  800605:	74 23                	je     80062a <vprintfmt+0x27c>
  800607:	85 f6                	test   %esi,%esi
  800609:	78 a1                	js     8005ac <vprintfmt+0x1fe>
  80060b:	83 ee 01             	sub    $0x1,%esi
  80060e:	79 9c                	jns    8005ac <vprintfmt+0x1fe>
  800610:	89 df                	mov    %ebx,%edi
  800612:	8b 75 08             	mov    0x8(%ebp),%esi
  800615:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800618:	eb 18                	jmp    800632 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80061a:	83 ec 08             	sub    $0x8,%esp
  80061d:	53                   	push   %ebx
  80061e:	6a 20                	push   $0x20
  800620:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800622:	83 ef 01             	sub    $0x1,%edi
  800625:	83 c4 10             	add    $0x10,%esp
  800628:	eb 08                	jmp    800632 <vprintfmt+0x284>
  80062a:	89 df                	mov    %ebx,%edi
  80062c:	8b 75 08             	mov    0x8(%ebp),%esi
  80062f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800632:	85 ff                	test   %edi,%edi
  800634:	7f e4                	jg     80061a <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800636:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800639:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80063f:	e9 90 fd ff ff       	jmp    8003d4 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800644:	83 f9 01             	cmp    $0x1,%ecx
  800647:	7e 19                	jle    800662 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800649:	8b 45 14             	mov    0x14(%ebp),%eax
  80064c:	8b 50 04             	mov    0x4(%eax),%edx
  80064f:	8b 00                	mov    (%eax),%eax
  800651:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800654:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800657:	8b 45 14             	mov    0x14(%ebp),%eax
  80065a:	8d 40 08             	lea    0x8(%eax),%eax
  80065d:	89 45 14             	mov    %eax,0x14(%ebp)
  800660:	eb 38                	jmp    80069a <vprintfmt+0x2ec>
	else if (lflag)
  800662:	85 c9                	test   %ecx,%ecx
  800664:	74 1b                	je     800681 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800666:	8b 45 14             	mov    0x14(%ebp),%eax
  800669:	8b 00                	mov    (%eax),%eax
  80066b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80066e:	89 c1                	mov    %eax,%ecx
  800670:	c1 f9 1f             	sar    $0x1f,%ecx
  800673:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800676:	8b 45 14             	mov    0x14(%ebp),%eax
  800679:	8d 40 04             	lea    0x4(%eax),%eax
  80067c:	89 45 14             	mov    %eax,0x14(%ebp)
  80067f:	eb 19                	jmp    80069a <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800681:	8b 45 14             	mov    0x14(%ebp),%eax
  800684:	8b 00                	mov    (%eax),%eax
  800686:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800689:	89 c1                	mov    %eax,%ecx
  80068b:	c1 f9 1f             	sar    $0x1f,%ecx
  80068e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800691:	8b 45 14             	mov    0x14(%ebp),%eax
  800694:	8d 40 04             	lea    0x4(%eax),%eax
  800697:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80069a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80069d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006a0:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006a5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006a9:	0f 89 0e 01 00 00    	jns    8007bd <vprintfmt+0x40f>
				putch('-', putdat);
  8006af:	83 ec 08             	sub    $0x8,%esp
  8006b2:	53                   	push   %ebx
  8006b3:	6a 2d                	push   $0x2d
  8006b5:	ff d6                	call   *%esi
				num = -(long long) num;
  8006b7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006ba:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006bd:	f7 da                	neg    %edx
  8006bf:	83 d1 00             	adc    $0x0,%ecx
  8006c2:	f7 d9                	neg    %ecx
  8006c4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006c7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006cc:	e9 ec 00 00 00       	jmp    8007bd <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006d1:	83 f9 01             	cmp    $0x1,%ecx
  8006d4:	7e 18                	jle    8006ee <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8006d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d9:	8b 10                	mov    (%eax),%edx
  8006db:	8b 48 04             	mov    0x4(%eax),%ecx
  8006de:	8d 40 08             	lea    0x8(%eax),%eax
  8006e1:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8006e4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006e9:	e9 cf 00 00 00       	jmp    8007bd <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006ee:	85 c9                	test   %ecx,%ecx
  8006f0:	74 1a                	je     80070c <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8006f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f5:	8b 10                	mov    (%eax),%edx
  8006f7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006fc:	8d 40 04             	lea    0x4(%eax),%eax
  8006ff:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800702:	b8 0a 00 00 00       	mov    $0xa,%eax
  800707:	e9 b1 00 00 00       	jmp    8007bd <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80070c:	8b 45 14             	mov    0x14(%ebp),%eax
  80070f:	8b 10                	mov    (%eax),%edx
  800711:	b9 00 00 00 00       	mov    $0x0,%ecx
  800716:	8d 40 04             	lea    0x4(%eax),%eax
  800719:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80071c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800721:	e9 97 00 00 00       	jmp    8007bd <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800726:	83 ec 08             	sub    $0x8,%esp
  800729:	53                   	push   %ebx
  80072a:	6a 58                	push   $0x58
  80072c:	ff d6                	call   *%esi
			putch('X', putdat);
  80072e:	83 c4 08             	add    $0x8,%esp
  800731:	53                   	push   %ebx
  800732:	6a 58                	push   $0x58
  800734:	ff d6                	call   *%esi
			putch('X', putdat);
  800736:	83 c4 08             	add    $0x8,%esp
  800739:	53                   	push   %ebx
  80073a:	6a 58                	push   $0x58
  80073c:	ff d6                	call   *%esi
			break;
  80073e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800741:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800744:	e9 8b fc ff ff       	jmp    8003d4 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800749:	83 ec 08             	sub    $0x8,%esp
  80074c:	53                   	push   %ebx
  80074d:	6a 30                	push   $0x30
  80074f:	ff d6                	call   *%esi
			putch('x', putdat);
  800751:	83 c4 08             	add    $0x8,%esp
  800754:	53                   	push   %ebx
  800755:	6a 78                	push   $0x78
  800757:	ff d6                	call   *%esi
			num = (unsigned long long)
  800759:	8b 45 14             	mov    0x14(%ebp),%eax
  80075c:	8b 10                	mov    (%eax),%edx
  80075e:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800763:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800766:	8d 40 04             	lea    0x4(%eax),%eax
  800769:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80076c:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800771:	eb 4a                	jmp    8007bd <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800773:	83 f9 01             	cmp    $0x1,%ecx
  800776:	7e 15                	jle    80078d <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  800778:	8b 45 14             	mov    0x14(%ebp),%eax
  80077b:	8b 10                	mov    (%eax),%edx
  80077d:	8b 48 04             	mov    0x4(%eax),%ecx
  800780:	8d 40 08             	lea    0x8(%eax),%eax
  800783:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800786:	b8 10 00 00 00       	mov    $0x10,%eax
  80078b:	eb 30                	jmp    8007bd <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80078d:	85 c9                	test   %ecx,%ecx
  80078f:	74 17                	je     8007a8 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800791:	8b 45 14             	mov    0x14(%ebp),%eax
  800794:	8b 10                	mov    (%eax),%edx
  800796:	b9 00 00 00 00       	mov    $0x0,%ecx
  80079b:	8d 40 04             	lea    0x4(%eax),%eax
  80079e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8007a1:	b8 10 00 00 00       	mov    $0x10,%eax
  8007a6:	eb 15                	jmp    8007bd <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8007a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ab:	8b 10                	mov    (%eax),%edx
  8007ad:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007b2:	8d 40 04             	lea    0x4(%eax),%eax
  8007b5:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8007b8:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007bd:	83 ec 0c             	sub    $0xc,%esp
  8007c0:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007c4:	57                   	push   %edi
  8007c5:	ff 75 e0             	pushl  -0x20(%ebp)
  8007c8:	50                   	push   %eax
  8007c9:	51                   	push   %ecx
  8007ca:	52                   	push   %edx
  8007cb:	89 da                	mov    %ebx,%edx
  8007cd:	89 f0                	mov    %esi,%eax
  8007cf:	e8 f1 fa ff ff       	call   8002c5 <printnum>
			break;
  8007d4:	83 c4 20             	add    $0x20,%esp
  8007d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007da:	e9 f5 fb ff ff       	jmp    8003d4 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007df:	83 ec 08             	sub    $0x8,%esp
  8007e2:	53                   	push   %ebx
  8007e3:	52                   	push   %edx
  8007e4:	ff d6                	call   *%esi
			break;
  8007e6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007ec:	e9 e3 fb ff ff       	jmp    8003d4 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007f1:	83 ec 08             	sub    $0x8,%esp
  8007f4:	53                   	push   %ebx
  8007f5:	6a 25                	push   $0x25
  8007f7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007f9:	83 c4 10             	add    $0x10,%esp
  8007fc:	eb 03                	jmp    800801 <vprintfmt+0x453>
  8007fe:	83 ef 01             	sub    $0x1,%edi
  800801:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800805:	75 f7                	jne    8007fe <vprintfmt+0x450>
  800807:	e9 c8 fb ff ff       	jmp    8003d4 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80080c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80080f:	5b                   	pop    %ebx
  800810:	5e                   	pop    %esi
  800811:	5f                   	pop    %edi
  800812:	5d                   	pop    %ebp
  800813:	c3                   	ret    

00800814 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800814:	55                   	push   %ebp
  800815:	89 e5                	mov    %esp,%ebp
  800817:	83 ec 18             	sub    $0x18,%esp
  80081a:	8b 45 08             	mov    0x8(%ebp),%eax
  80081d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800820:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800823:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800827:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80082a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800831:	85 c0                	test   %eax,%eax
  800833:	74 26                	je     80085b <vsnprintf+0x47>
  800835:	85 d2                	test   %edx,%edx
  800837:	7e 22                	jle    80085b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800839:	ff 75 14             	pushl  0x14(%ebp)
  80083c:	ff 75 10             	pushl  0x10(%ebp)
  80083f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800842:	50                   	push   %eax
  800843:	68 74 03 80 00       	push   $0x800374
  800848:	e8 61 fb ff ff       	call   8003ae <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80084d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800850:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800853:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800856:	83 c4 10             	add    $0x10,%esp
  800859:	eb 05                	jmp    800860 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80085b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800860:	c9                   	leave  
  800861:	c3                   	ret    

00800862 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800868:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80086b:	50                   	push   %eax
  80086c:	ff 75 10             	pushl  0x10(%ebp)
  80086f:	ff 75 0c             	pushl  0xc(%ebp)
  800872:	ff 75 08             	pushl  0x8(%ebp)
  800875:	e8 9a ff ff ff       	call   800814 <vsnprintf>
	va_end(ap);

	return rc;
}
  80087a:	c9                   	leave  
  80087b:	c3                   	ret    

0080087c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800882:	b8 00 00 00 00       	mov    $0x0,%eax
  800887:	eb 03                	jmp    80088c <strlen+0x10>
		n++;
  800889:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80088c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800890:	75 f7                	jne    800889 <strlen+0xd>
		n++;
	return n;
}
  800892:	5d                   	pop    %ebp
  800893:	c3                   	ret    

00800894 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80089a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80089d:	ba 00 00 00 00       	mov    $0x0,%edx
  8008a2:	eb 03                	jmp    8008a7 <strnlen+0x13>
		n++;
  8008a4:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008a7:	39 c2                	cmp    %eax,%edx
  8008a9:	74 08                	je     8008b3 <strnlen+0x1f>
  8008ab:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008af:	75 f3                	jne    8008a4 <strnlen+0x10>
  8008b1:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008b3:	5d                   	pop    %ebp
  8008b4:	c3                   	ret    

008008b5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008b5:	55                   	push   %ebp
  8008b6:	89 e5                	mov    %esp,%ebp
  8008b8:	53                   	push   %ebx
  8008b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008bf:	89 c2                	mov    %eax,%edx
  8008c1:	83 c2 01             	add    $0x1,%edx
  8008c4:	83 c1 01             	add    $0x1,%ecx
  8008c7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008cb:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008ce:	84 db                	test   %bl,%bl
  8008d0:	75 ef                	jne    8008c1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008d2:	5b                   	pop    %ebx
  8008d3:	5d                   	pop    %ebp
  8008d4:	c3                   	ret    

008008d5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
  8008d8:	53                   	push   %ebx
  8008d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008dc:	53                   	push   %ebx
  8008dd:	e8 9a ff ff ff       	call   80087c <strlen>
  8008e2:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008e5:	ff 75 0c             	pushl  0xc(%ebp)
  8008e8:	01 d8                	add    %ebx,%eax
  8008ea:	50                   	push   %eax
  8008eb:	e8 c5 ff ff ff       	call   8008b5 <strcpy>
	return dst;
}
  8008f0:	89 d8                	mov    %ebx,%eax
  8008f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008f5:	c9                   	leave  
  8008f6:	c3                   	ret    

008008f7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	56                   	push   %esi
  8008fb:	53                   	push   %ebx
  8008fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800902:	89 f3                	mov    %esi,%ebx
  800904:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800907:	89 f2                	mov    %esi,%edx
  800909:	eb 0f                	jmp    80091a <strncpy+0x23>
		*dst++ = *src;
  80090b:	83 c2 01             	add    $0x1,%edx
  80090e:	0f b6 01             	movzbl (%ecx),%eax
  800911:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800914:	80 39 01             	cmpb   $0x1,(%ecx)
  800917:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80091a:	39 da                	cmp    %ebx,%edx
  80091c:	75 ed                	jne    80090b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80091e:	89 f0                	mov    %esi,%eax
  800920:	5b                   	pop    %ebx
  800921:	5e                   	pop    %esi
  800922:	5d                   	pop    %ebp
  800923:	c3                   	ret    

00800924 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	56                   	push   %esi
  800928:	53                   	push   %ebx
  800929:	8b 75 08             	mov    0x8(%ebp),%esi
  80092c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80092f:	8b 55 10             	mov    0x10(%ebp),%edx
  800932:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800934:	85 d2                	test   %edx,%edx
  800936:	74 21                	je     800959 <strlcpy+0x35>
  800938:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80093c:	89 f2                	mov    %esi,%edx
  80093e:	eb 09                	jmp    800949 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800940:	83 c2 01             	add    $0x1,%edx
  800943:	83 c1 01             	add    $0x1,%ecx
  800946:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800949:	39 c2                	cmp    %eax,%edx
  80094b:	74 09                	je     800956 <strlcpy+0x32>
  80094d:	0f b6 19             	movzbl (%ecx),%ebx
  800950:	84 db                	test   %bl,%bl
  800952:	75 ec                	jne    800940 <strlcpy+0x1c>
  800954:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800956:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800959:	29 f0                	sub    %esi,%eax
}
  80095b:	5b                   	pop    %ebx
  80095c:	5e                   	pop    %esi
  80095d:	5d                   	pop    %ebp
  80095e:	c3                   	ret    

0080095f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800965:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800968:	eb 06                	jmp    800970 <strcmp+0x11>
		p++, q++;
  80096a:	83 c1 01             	add    $0x1,%ecx
  80096d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800970:	0f b6 01             	movzbl (%ecx),%eax
  800973:	84 c0                	test   %al,%al
  800975:	74 04                	je     80097b <strcmp+0x1c>
  800977:	3a 02                	cmp    (%edx),%al
  800979:	74 ef                	je     80096a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80097b:	0f b6 c0             	movzbl %al,%eax
  80097e:	0f b6 12             	movzbl (%edx),%edx
  800981:	29 d0                	sub    %edx,%eax
}
  800983:	5d                   	pop    %ebp
  800984:	c3                   	ret    

00800985 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800985:	55                   	push   %ebp
  800986:	89 e5                	mov    %esp,%ebp
  800988:	53                   	push   %ebx
  800989:	8b 45 08             	mov    0x8(%ebp),%eax
  80098c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098f:	89 c3                	mov    %eax,%ebx
  800991:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800994:	eb 06                	jmp    80099c <strncmp+0x17>
		n--, p++, q++;
  800996:	83 c0 01             	add    $0x1,%eax
  800999:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80099c:	39 d8                	cmp    %ebx,%eax
  80099e:	74 15                	je     8009b5 <strncmp+0x30>
  8009a0:	0f b6 08             	movzbl (%eax),%ecx
  8009a3:	84 c9                	test   %cl,%cl
  8009a5:	74 04                	je     8009ab <strncmp+0x26>
  8009a7:	3a 0a                	cmp    (%edx),%cl
  8009a9:	74 eb                	je     800996 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ab:	0f b6 00             	movzbl (%eax),%eax
  8009ae:	0f b6 12             	movzbl (%edx),%edx
  8009b1:	29 d0                	sub    %edx,%eax
  8009b3:	eb 05                	jmp    8009ba <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009b5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009ba:	5b                   	pop    %ebx
  8009bb:	5d                   	pop    %ebp
  8009bc:	c3                   	ret    

008009bd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c7:	eb 07                	jmp    8009d0 <strchr+0x13>
		if (*s == c)
  8009c9:	38 ca                	cmp    %cl,%dl
  8009cb:	74 0f                	je     8009dc <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009cd:	83 c0 01             	add    $0x1,%eax
  8009d0:	0f b6 10             	movzbl (%eax),%edx
  8009d3:	84 d2                	test   %dl,%dl
  8009d5:	75 f2                	jne    8009c9 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009dc:	5d                   	pop    %ebp
  8009dd:	c3                   	ret    

008009de <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009e8:	eb 03                	jmp    8009ed <strfind+0xf>
  8009ea:	83 c0 01             	add    $0x1,%eax
  8009ed:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009f0:	38 ca                	cmp    %cl,%dl
  8009f2:	74 04                	je     8009f8 <strfind+0x1a>
  8009f4:	84 d2                	test   %dl,%dl
  8009f6:	75 f2                	jne    8009ea <strfind+0xc>
			break;
	return (char *) s;
}
  8009f8:	5d                   	pop    %ebp
  8009f9:	c3                   	ret    

008009fa <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	57                   	push   %edi
  8009fe:	56                   	push   %esi
  8009ff:	53                   	push   %ebx
  800a00:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a03:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a06:	85 c9                	test   %ecx,%ecx
  800a08:	74 36                	je     800a40 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a0a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a10:	75 28                	jne    800a3a <memset+0x40>
  800a12:	f6 c1 03             	test   $0x3,%cl
  800a15:	75 23                	jne    800a3a <memset+0x40>
		c &= 0xFF;
  800a17:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a1b:	89 d3                	mov    %edx,%ebx
  800a1d:	c1 e3 08             	shl    $0x8,%ebx
  800a20:	89 d6                	mov    %edx,%esi
  800a22:	c1 e6 18             	shl    $0x18,%esi
  800a25:	89 d0                	mov    %edx,%eax
  800a27:	c1 e0 10             	shl    $0x10,%eax
  800a2a:	09 f0                	or     %esi,%eax
  800a2c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a2e:	89 d8                	mov    %ebx,%eax
  800a30:	09 d0                	or     %edx,%eax
  800a32:	c1 e9 02             	shr    $0x2,%ecx
  800a35:	fc                   	cld    
  800a36:	f3 ab                	rep stos %eax,%es:(%edi)
  800a38:	eb 06                	jmp    800a40 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3d:	fc                   	cld    
  800a3e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a40:	89 f8                	mov    %edi,%eax
  800a42:	5b                   	pop    %ebx
  800a43:	5e                   	pop    %esi
  800a44:	5f                   	pop    %edi
  800a45:	5d                   	pop    %ebp
  800a46:	c3                   	ret    

00800a47 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	57                   	push   %edi
  800a4b:	56                   	push   %esi
  800a4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a52:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a55:	39 c6                	cmp    %eax,%esi
  800a57:	73 35                	jae    800a8e <memmove+0x47>
  800a59:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a5c:	39 d0                	cmp    %edx,%eax
  800a5e:	73 2e                	jae    800a8e <memmove+0x47>
		s += n;
		d += n;
  800a60:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a63:	89 d6                	mov    %edx,%esi
  800a65:	09 fe                	or     %edi,%esi
  800a67:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a6d:	75 13                	jne    800a82 <memmove+0x3b>
  800a6f:	f6 c1 03             	test   $0x3,%cl
  800a72:	75 0e                	jne    800a82 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a74:	83 ef 04             	sub    $0x4,%edi
  800a77:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a7a:	c1 e9 02             	shr    $0x2,%ecx
  800a7d:	fd                   	std    
  800a7e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a80:	eb 09                	jmp    800a8b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a82:	83 ef 01             	sub    $0x1,%edi
  800a85:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a88:	fd                   	std    
  800a89:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a8b:	fc                   	cld    
  800a8c:	eb 1d                	jmp    800aab <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a8e:	89 f2                	mov    %esi,%edx
  800a90:	09 c2                	or     %eax,%edx
  800a92:	f6 c2 03             	test   $0x3,%dl
  800a95:	75 0f                	jne    800aa6 <memmove+0x5f>
  800a97:	f6 c1 03             	test   $0x3,%cl
  800a9a:	75 0a                	jne    800aa6 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a9c:	c1 e9 02             	shr    $0x2,%ecx
  800a9f:	89 c7                	mov    %eax,%edi
  800aa1:	fc                   	cld    
  800aa2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa4:	eb 05                	jmp    800aab <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800aa6:	89 c7                	mov    %eax,%edi
  800aa8:	fc                   	cld    
  800aa9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aab:	5e                   	pop    %esi
  800aac:	5f                   	pop    %edi
  800aad:	5d                   	pop    %ebp
  800aae:	c3                   	ret    

00800aaf <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aaf:	55                   	push   %ebp
  800ab0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ab2:	ff 75 10             	pushl  0x10(%ebp)
  800ab5:	ff 75 0c             	pushl  0xc(%ebp)
  800ab8:	ff 75 08             	pushl  0x8(%ebp)
  800abb:	e8 87 ff ff ff       	call   800a47 <memmove>
}
  800ac0:	c9                   	leave  
  800ac1:	c3                   	ret    

00800ac2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ac2:	55                   	push   %ebp
  800ac3:	89 e5                	mov    %esp,%ebp
  800ac5:	56                   	push   %esi
  800ac6:	53                   	push   %ebx
  800ac7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aca:	8b 55 0c             	mov    0xc(%ebp),%edx
  800acd:	89 c6                	mov    %eax,%esi
  800acf:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ad2:	eb 1a                	jmp    800aee <memcmp+0x2c>
		if (*s1 != *s2)
  800ad4:	0f b6 08             	movzbl (%eax),%ecx
  800ad7:	0f b6 1a             	movzbl (%edx),%ebx
  800ada:	38 d9                	cmp    %bl,%cl
  800adc:	74 0a                	je     800ae8 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ade:	0f b6 c1             	movzbl %cl,%eax
  800ae1:	0f b6 db             	movzbl %bl,%ebx
  800ae4:	29 d8                	sub    %ebx,%eax
  800ae6:	eb 0f                	jmp    800af7 <memcmp+0x35>
		s1++, s2++;
  800ae8:	83 c0 01             	add    $0x1,%eax
  800aeb:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aee:	39 f0                	cmp    %esi,%eax
  800af0:	75 e2                	jne    800ad4 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800af2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af7:	5b                   	pop    %ebx
  800af8:	5e                   	pop    %esi
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	53                   	push   %ebx
  800aff:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b02:	89 c1                	mov    %eax,%ecx
  800b04:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b07:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b0b:	eb 0a                	jmp    800b17 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b0d:	0f b6 10             	movzbl (%eax),%edx
  800b10:	39 da                	cmp    %ebx,%edx
  800b12:	74 07                	je     800b1b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b14:	83 c0 01             	add    $0x1,%eax
  800b17:	39 c8                	cmp    %ecx,%eax
  800b19:	72 f2                	jb     800b0d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b1b:	5b                   	pop    %ebx
  800b1c:	5d                   	pop    %ebp
  800b1d:	c3                   	ret    

00800b1e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b1e:	55                   	push   %ebp
  800b1f:	89 e5                	mov    %esp,%ebp
  800b21:	57                   	push   %edi
  800b22:	56                   	push   %esi
  800b23:	53                   	push   %ebx
  800b24:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b27:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b2a:	eb 03                	jmp    800b2f <strtol+0x11>
		s++;
  800b2c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b2f:	0f b6 01             	movzbl (%ecx),%eax
  800b32:	3c 20                	cmp    $0x20,%al
  800b34:	74 f6                	je     800b2c <strtol+0xe>
  800b36:	3c 09                	cmp    $0x9,%al
  800b38:	74 f2                	je     800b2c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b3a:	3c 2b                	cmp    $0x2b,%al
  800b3c:	75 0a                	jne    800b48 <strtol+0x2a>
		s++;
  800b3e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b41:	bf 00 00 00 00       	mov    $0x0,%edi
  800b46:	eb 11                	jmp    800b59 <strtol+0x3b>
  800b48:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b4d:	3c 2d                	cmp    $0x2d,%al
  800b4f:	75 08                	jne    800b59 <strtol+0x3b>
		s++, neg = 1;
  800b51:	83 c1 01             	add    $0x1,%ecx
  800b54:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b59:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b5f:	75 15                	jne    800b76 <strtol+0x58>
  800b61:	80 39 30             	cmpb   $0x30,(%ecx)
  800b64:	75 10                	jne    800b76 <strtol+0x58>
  800b66:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b6a:	75 7c                	jne    800be8 <strtol+0xca>
		s += 2, base = 16;
  800b6c:	83 c1 02             	add    $0x2,%ecx
  800b6f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b74:	eb 16                	jmp    800b8c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b76:	85 db                	test   %ebx,%ebx
  800b78:	75 12                	jne    800b8c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b7a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b7f:	80 39 30             	cmpb   $0x30,(%ecx)
  800b82:	75 08                	jne    800b8c <strtol+0x6e>
		s++, base = 8;
  800b84:	83 c1 01             	add    $0x1,%ecx
  800b87:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b8c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b91:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b94:	0f b6 11             	movzbl (%ecx),%edx
  800b97:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b9a:	89 f3                	mov    %esi,%ebx
  800b9c:	80 fb 09             	cmp    $0x9,%bl
  800b9f:	77 08                	ja     800ba9 <strtol+0x8b>
			dig = *s - '0';
  800ba1:	0f be d2             	movsbl %dl,%edx
  800ba4:	83 ea 30             	sub    $0x30,%edx
  800ba7:	eb 22                	jmp    800bcb <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ba9:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bac:	89 f3                	mov    %esi,%ebx
  800bae:	80 fb 19             	cmp    $0x19,%bl
  800bb1:	77 08                	ja     800bbb <strtol+0x9d>
			dig = *s - 'a' + 10;
  800bb3:	0f be d2             	movsbl %dl,%edx
  800bb6:	83 ea 57             	sub    $0x57,%edx
  800bb9:	eb 10                	jmp    800bcb <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800bbb:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bbe:	89 f3                	mov    %esi,%ebx
  800bc0:	80 fb 19             	cmp    $0x19,%bl
  800bc3:	77 16                	ja     800bdb <strtol+0xbd>
			dig = *s - 'A' + 10;
  800bc5:	0f be d2             	movsbl %dl,%edx
  800bc8:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800bcb:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bce:	7d 0b                	jge    800bdb <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800bd0:	83 c1 01             	add    $0x1,%ecx
  800bd3:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bd7:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bd9:	eb b9                	jmp    800b94 <strtol+0x76>

	if (endptr)
  800bdb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bdf:	74 0d                	je     800bee <strtol+0xd0>
		*endptr = (char *) s;
  800be1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800be4:	89 0e                	mov    %ecx,(%esi)
  800be6:	eb 06                	jmp    800bee <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800be8:	85 db                	test   %ebx,%ebx
  800bea:	74 98                	je     800b84 <strtol+0x66>
  800bec:	eb 9e                	jmp    800b8c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bee:	89 c2                	mov    %eax,%edx
  800bf0:	f7 da                	neg    %edx
  800bf2:	85 ff                	test   %edi,%edi
  800bf4:	0f 45 c2             	cmovne %edx,%eax
}
  800bf7:	5b                   	pop    %ebx
  800bf8:	5e                   	pop    %esi
  800bf9:	5f                   	pop    %edi
  800bfa:	5d                   	pop    %ebp
  800bfb:	c3                   	ret    

00800bfc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	57                   	push   %edi
  800c00:	56                   	push   %esi
  800c01:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c02:	b8 00 00 00 00       	mov    $0x0,%eax
  800c07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0d:	89 c3                	mov    %eax,%ebx
  800c0f:	89 c7                	mov    %eax,%edi
  800c11:	89 c6                	mov    %eax,%esi
  800c13:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c15:	5b                   	pop    %ebx
  800c16:	5e                   	pop    %esi
  800c17:	5f                   	pop    %edi
  800c18:	5d                   	pop    %ebp
  800c19:	c3                   	ret    

00800c1a <sys_cgetc>:

int
sys_cgetc(void)
{
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	57                   	push   %edi
  800c1e:	56                   	push   %esi
  800c1f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c20:	ba 00 00 00 00       	mov    $0x0,%edx
  800c25:	b8 01 00 00 00       	mov    $0x1,%eax
  800c2a:	89 d1                	mov    %edx,%ecx
  800c2c:	89 d3                	mov    %edx,%ebx
  800c2e:	89 d7                	mov    %edx,%edi
  800c30:	89 d6                	mov    %edx,%esi
  800c32:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c34:	5b                   	pop    %ebx
  800c35:	5e                   	pop    %esi
  800c36:	5f                   	pop    %edi
  800c37:	5d                   	pop    %ebp
  800c38:	c3                   	ret    

00800c39 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c39:	55                   	push   %ebp
  800c3a:	89 e5                	mov    %esp,%ebp
  800c3c:	57                   	push   %edi
  800c3d:	56                   	push   %esi
  800c3e:	53                   	push   %ebx
  800c3f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c42:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c47:	b8 03 00 00 00       	mov    $0x3,%eax
  800c4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4f:	89 cb                	mov    %ecx,%ebx
  800c51:	89 cf                	mov    %ecx,%edi
  800c53:	89 ce                	mov    %ecx,%esi
  800c55:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c57:	85 c0                	test   %eax,%eax
  800c59:	7e 17                	jle    800c72 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5b:	83 ec 0c             	sub    $0xc,%esp
  800c5e:	50                   	push   %eax
  800c5f:	6a 03                	push   $0x3
  800c61:	68 ff 2b 80 00       	push   $0x802bff
  800c66:	6a 23                	push   $0x23
  800c68:	68 1c 2c 80 00       	push   $0x802c1c
  800c6d:	e8 66 f5 ff ff       	call   8001d8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c72:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c75:	5b                   	pop    %ebx
  800c76:	5e                   	pop    %esi
  800c77:	5f                   	pop    %edi
  800c78:	5d                   	pop    %ebp
  800c79:	c3                   	ret    

00800c7a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c7a:	55                   	push   %ebp
  800c7b:	89 e5                	mov    %esp,%ebp
  800c7d:	57                   	push   %edi
  800c7e:	56                   	push   %esi
  800c7f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c80:	ba 00 00 00 00       	mov    $0x0,%edx
  800c85:	b8 02 00 00 00       	mov    $0x2,%eax
  800c8a:	89 d1                	mov    %edx,%ecx
  800c8c:	89 d3                	mov    %edx,%ebx
  800c8e:	89 d7                	mov    %edx,%edi
  800c90:	89 d6                	mov    %edx,%esi
  800c92:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c94:	5b                   	pop    %ebx
  800c95:	5e                   	pop    %esi
  800c96:	5f                   	pop    %edi
  800c97:	5d                   	pop    %ebp
  800c98:	c3                   	ret    

00800c99 <sys_yield>:

void
sys_yield(void)
{
  800c99:	55                   	push   %ebp
  800c9a:	89 e5                	mov    %esp,%ebp
  800c9c:	57                   	push   %edi
  800c9d:	56                   	push   %esi
  800c9e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9f:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ca9:	89 d1                	mov    %edx,%ecx
  800cab:	89 d3                	mov    %edx,%ebx
  800cad:	89 d7                	mov    %edx,%edi
  800caf:	89 d6                	mov    %edx,%esi
  800cb1:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cb3:	5b                   	pop    %ebx
  800cb4:	5e                   	pop    %esi
  800cb5:	5f                   	pop    %edi
  800cb6:	5d                   	pop    %ebp
  800cb7:	c3                   	ret    

00800cb8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cb8:	55                   	push   %ebp
  800cb9:	89 e5                	mov    %esp,%ebp
  800cbb:	57                   	push   %edi
  800cbc:	56                   	push   %esi
  800cbd:	53                   	push   %ebx
  800cbe:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc1:	be 00 00 00 00       	mov    $0x0,%esi
  800cc6:	b8 04 00 00 00       	mov    $0x4,%eax
  800ccb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cce:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd4:	89 f7                	mov    %esi,%edi
  800cd6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cd8:	85 c0                	test   %eax,%eax
  800cda:	7e 17                	jle    800cf3 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdc:	83 ec 0c             	sub    $0xc,%esp
  800cdf:	50                   	push   %eax
  800ce0:	6a 04                	push   $0x4
  800ce2:	68 ff 2b 80 00       	push   $0x802bff
  800ce7:	6a 23                	push   $0x23
  800ce9:	68 1c 2c 80 00       	push   $0x802c1c
  800cee:	e8 e5 f4 ff ff       	call   8001d8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cf3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf6:	5b                   	pop    %ebx
  800cf7:	5e                   	pop    %esi
  800cf8:	5f                   	pop    %edi
  800cf9:	5d                   	pop    %ebp
  800cfa:	c3                   	ret    

00800cfb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cfb:	55                   	push   %ebp
  800cfc:	89 e5                	mov    %esp,%ebp
  800cfe:	57                   	push   %edi
  800cff:	56                   	push   %esi
  800d00:	53                   	push   %ebx
  800d01:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d04:	b8 05 00 00 00       	mov    $0x5,%eax
  800d09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d12:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d15:	8b 75 18             	mov    0x18(%ebp),%esi
  800d18:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d1a:	85 c0                	test   %eax,%eax
  800d1c:	7e 17                	jle    800d35 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1e:	83 ec 0c             	sub    $0xc,%esp
  800d21:	50                   	push   %eax
  800d22:	6a 05                	push   $0x5
  800d24:	68 ff 2b 80 00       	push   $0x802bff
  800d29:	6a 23                	push   $0x23
  800d2b:	68 1c 2c 80 00       	push   $0x802c1c
  800d30:	e8 a3 f4 ff ff       	call   8001d8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d38:	5b                   	pop    %ebx
  800d39:	5e                   	pop    %esi
  800d3a:	5f                   	pop    %edi
  800d3b:	5d                   	pop    %ebp
  800d3c:	c3                   	ret    

00800d3d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
  800d40:	57                   	push   %edi
  800d41:	56                   	push   %esi
  800d42:	53                   	push   %ebx
  800d43:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d46:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d4b:	b8 06 00 00 00       	mov    $0x6,%eax
  800d50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d53:	8b 55 08             	mov    0x8(%ebp),%edx
  800d56:	89 df                	mov    %ebx,%edi
  800d58:	89 de                	mov    %ebx,%esi
  800d5a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d5c:	85 c0                	test   %eax,%eax
  800d5e:	7e 17                	jle    800d77 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d60:	83 ec 0c             	sub    $0xc,%esp
  800d63:	50                   	push   %eax
  800d64:	6a 06                	push   $0x6
  800d66:	68 ff 2b 80 00       	push   $0x802bff
  800d6b:	6a 23                	push   $0x23
  800d6d:	68 1c 2c 80 00       	push   $0x802c1c
  800d72:	e8 61 f4 ff ff       	call   8001d8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7a:	5b                   	pop    %ebx
  800d7b:	5e                   	pop    %esi
  800d7c:	5f                   	pop    %edi
  800d7d:	5d                   	pop    %ebp
  800d7e:	c3                   	ret    

00800d7f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d7f:	55                   	push   %ebp
  800d80:	89 e5                	mov    %esp,%ebp
  800d82:	57                   	push   %edi
  800d83:	56                   	push   %esi
  800d84:	53                   	push   %ebx
  800d85:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d88:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d8d:	b8 08 00 00 00       	mov    $0x8,%eax
  800d92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d95:	8b 55 08             	mov    0x8(%ebp),%edx
  800d98:	89 df                	mov    %ebx,%edi
  800d9a:	89 de                	mov    %ebx,%esi
  800d9c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d9e:	85 c0                	test   %eax,%eax
  800da0:	7e 17                	jle    800db9 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da2:	83 ec 0c             	sub    $0xc,%esp
  800da5:	50                   	push   %eax
  800da6:	6a 08                	push   $0x8
  800da8:	68 ff 2b 80 00       	push   $0x802bff
  800dad:	6a 23                	push   $0x23
  800daf:	68 1c 2c 80 00       	push   $0x802c1c
  800db4:	e8 1f f4 ff ff       	call   8001d8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800db9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dbc:	5b                   	pop    %ebx
  800dbd:	5e                   	pop    %esi
  800dbe:	5f                   	pop    %edi
  800dbf:	5d                   	pop    %ebp
  800dc0:	c3                   	ret    

00800dc1 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dc1:	55                   	push   %ebp
  800dc2:	89 e5                	mov    %esp,%ebp
  800dc4:	57                   	push   %edi
  800dc5:	56                   	push   %esi
  800dc6:	53                   	push   %ebx
  800dc7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dca:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dcf:	b8 09 00 00 00       	mov    $0x9,%eax
  800dd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dda:	89 df                	mov    %ebx,%edi
  800ddc:	89 de                	mov    %ebx,%esi
  800dde:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800de0:	85 c0                	test   %eax,%eax
  800de2:	7e 17                	jle    800dfb <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de4:	83 ec 0c             	sub    $0xc,%esp
  800de7:	50                   	push   %eax
  800de8:	6a 09                	push   $0x9
  800dea:	68 ff 2b 80 00       	push   $0x802bff
  800def:	6a 23                	push   $0x23
  800df1:	68 1c 2c 80 00       	push   $0x802c1c
  800df6:	e8 dd f3 ff ff       	call   8001d8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dfe:	5b                   	pop    %ebx
  800dff:	5e                   	pop    %esi
  800e00:	5f                   	pop    %edi
  800e01:	5d                   	pop    %ebp
  800e02:	c3                   	ret    

00800e03 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e03:	55                   	push   %ebp
  800e04:	89 e5                	mov    %esp,%ebp
  800e06:	57                   	push   %edi
  800e07:	56                   	push   %esi
  800e08:	53                   	push   %ebx
  800e09:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e11:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e19:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1c:	89 df                	mov    %ebx,%edi
  800e1e:	89 de                	mov    %ebx,%esi
  800e20:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e22:	85 c0                	test   %eax,%eax
  800e24:	7e 17                	jle    800e3d <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e26:	83 ec 0c             	sub    $0xc,%esp
  800e29:	50                   	push   %eax
  800e2a:	6a 0a                	push   $0xa
  800e2c:	68 ff 2b 80 00       	push   $0x802bff
  800e31:	6a 23                	push   $0x23
  800e33:	68 1c 2c 80 00       	push   $0x802c1c
  800e38:	e8 9b f3 ff ff       	call   8001d8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e40:	5b                   	pop    %ebx
  800e41:	5e                   	pop    %esi
  800e42:	5f                   	pop    %edi
  800e43:	5d                   	pop    %ebp
  800e44:	c3                   	ret    

00800e45 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e45:	55                   	push   %ebp
  800e46:	89 e5                	mov    %esp,%ebp
  800e48:	57                   	push   %edi
  800e49:	56                   	push   %esi
  800e4a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4b:	be 00 00 00 00       	mov    $0x0,%esi
  800e50:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e58:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e5e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e61:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e63:	5b                   	pop    %ebx
  800e64:	5e                   	pop    %esi
  800e65:	5f                   	pop    %edi
  800e66:	5d                   	pop    %ebp
  800e67:	c3                   	ret    

00800e68 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e68:	55                   	push   %ebp
  800e69:	89 e5                	mov    %esp,%ebp
  800e6b:	57                   	push   %edi
  800e6c:	56                   	push   %esi
  800e6d:	53                   	push   %ebx
  800e6e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e71:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e76:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7e:	89 cb                	mov    %ecx,%ebx
  800e80:	89 cf                	mov    %ecx,%edi
  800e82:	89 ce                	mov    %ecx,%esi
  800e84:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e86:	85 c0                	test   %eax,%eax
  800e88:	7e 17                	jle    800ea1 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e8a:	83 ec 0c             	sub    $0xc,%esp
  800e8d:	50                   	push   %eax
  800e8e:	6a 0d                	push   $0xd
  800e90:	68 ff 2b 80 00       	push   $0x802bff
  800e95:	6a 23                	push   $0x23
  800e97:	68 1c 2c 80 00       	push   $0x802c1c
  800e9c:	e8 37 f3 ff ff       	call   8001d8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ea1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ea4:	5b                   	pop    %ebx
  800ea5:	5e                   	pop    %esi
  800ea6:	5f                   	pop    %edi
  800ea7:	5d                   	pop    %ebp
  800ea8:	c3                   	ret    

00800ea9 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ea9:	55                   	push   %ebp
  800eaa:	89 e5                	mov    %esp,%ebp
  800eac:	57                   	push   %edi
  800ead:	56                   	push   %esi
  800eae:	53                   	push   %ebx
  800eaf:	83 ec 0c             	sub    $0xc,%esp
  800eb2:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800eb5:	8b 18                	mov    (%eax),%ebx
	uint32_t err = utf->utf_err;
  800eb7:	8b 78 04             	mov    0x4(%eax),%edi
	int r;
	envid_t curenvid = sys_getenvid();
  800eba:	e8 bb fd ff ff       	call   800c7a <sys_getenvid>
  800ebf:	89 c6                	mov    %eax,%esi
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(err & FEC_WR) && !(uvpt[PGNUM(addr)] & PTE_COW))
  800ec1:	f7 c7 02 00 00 00    	test   $0x2,%edi
  800ec7:	75 25                	jne    800eee <pgfault+0x45>
  800ec9:	89 d8                	mov    %ebx,%eax
  800ecb:	c1 e8 0c             	shr    $0xc,%eax
  800ece:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ed5:	f6 c4 08             	test   $0x8,%ah
  800ed8:	75 14                	jne    800eee <pgfault+0x45>
	    panic("pgfault error: wrong faulting access");
  800eda:	83 ec 04             	sub    $0x4,%esp
  800edd:	68 2c 2c 80 00       	push   $0x802c2c
  800ee2:	6a 1e                	push   $0x1e
  800ee4:	68 51 2c 80 00       	push   $0x802c51
  800ee9:	e8 ea f2 ff ff       	call   8001d8 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	sys_page_alloc(curenvid, PFTEMP, PTE_W | PTE_U | PTE_P);
  800eee:	83 ec 04             	sub    $0x4,%esp
  800ef1:	6a 07                	push   $0x7
  800ef3:	68 00 f0 7f 00       	push   $0x7ff000
  800ef8:	56                   	push   %esi
  800ef9:	e8 ba fd ff ff       	call   800cb8 <sys_page_alloc>

	addr = (void *)(PGNUM(addr) * PGSIZE);
  800efe:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr, PGSIZE);
  800f04:	83 c4 0c             	add    $0xc,%esp
  800f07:	68 00 10 00 00       	push   $0x1000
  800f0c:	53                   	push   %ebx
  800f0d:	68 00 f0 7f 00       	push   $0x7ff000
  800f12:	e8 30 fb ff ff       	call   800a47 <memmove>

	sys_page_unmap(curenvid, addr);
  800f17:	83 c4 08             	add    $0x8,%esp
  800f1a:	53                   	push   %ebx
  800f1b:	56                   	push   %esi
  800f1c:	e8 1c fe ff ff       	call   800d3d <sys_page_unmap>
	sys_page_map(curenvid, PFTEMP, curenvid, addr, PTE_W | PTE_U | PTE_P);
  800f21:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f28:	53                   	push   %ebx
  800f29:	56                   	push   %esi
  800f2a:	68 00 f0 7f 00       	push   $0x7ff000
  800f2f:	56                   	push   %esi
  800f30:	e8 c6 fd ff ff       	call   800cfb <sys_page_map>
	sys_page_unmap(curenvid, PFTEMP);
  800f35:	83 c4 18             	add    $0x18,%esp
  800f38:	68 00 f0 7f 00       	push   $0x7ff000
  800f3d:	56                   	push   %esi
  800f3e:	e8 fa fd ff ff       	call   800d3d <sys_page_unmap>
}
  800f43:	83 c4 10             	add    $0x10,%esp
  800f46:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f49:	5b                   	pop    %ebx
  800f4a:	5e                   	pop    %esi
  800f4b:	5f                   	pop    %edi
  800f4c:	5d                   	pop    %ebp
  800f4d:	c3                   	ret    

00800f4e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f4e:	55                   	push   %ebp
  800f4f:	89 e5                	mov    %esp,%ebp
  800f51:	57                   	push   %edi
  800f52:	56                   	push   %esi
  800f53:	53                   	push   %ebx
  800f54:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	extern void _pgfault_upcall();
	envid_t new_envid, curenv_id;

	curenv_id = sys_getenvid();
  800f57:	e8 1e fd ff ff       	call   800c7a <sys_getenvid>
	set_pgfault_handler(pgfault);
  800f5c:	83 ec 0c             	sub    $0xc,%esp
  800f5f:	68 a9 0e 80 00       	push   $0x800ea9
  800f64:	e8 6e 14 00 00       	call   8023d7 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f69:	b8 07 00 00 00       	mov    $0x7,%eax
  800f6e:	cd 30                	int    $0x30
  800f70:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800f73:	89 45 dc             	mov    %eax,-0x24(%ebp)
	new_envid = sys_exofork();

	if (new_envid < 0)
  800f76:	83 c4 10             	add    $0x10,%esp
  800f79:	85 c0                	test   %eax,%eax
  800f7b:	79 12                	jns    800f8f <fork+0x41>
	    panic("fork error: %e", new_envid);
  800f7d:	50                   	push   %eax
  800f7e:	68 5c 2c 80 00       	push   $0x802c5c
  800f83:	6a 75                	push   $0x75
  800f85:	68 51 2c 80 00       	push   $0x802c51
  800f8a:	e8 49 f2 ff ff       	call   8001d8 <_panic>
  800f8f:	bf 00 00 80 00       	mov    $0x800000,%edi
	else if (new_envid == 0)
  800f94:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800f98:	75 1c                	jne    800fb6 <fork+0x68>
		thisenv = envs + ENVX(sys_getenvid());
  800f9a:	e8 db fc ff ff       	call   800c7a <sys_getenvid>
  800f9f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fa4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fa7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fac:	a3 04 40 80 00       	mov    %eax,0x804004
  800fb1:	e9 27 01 00 00       	jmp    8010dd <fork+0x18f>
	else {

		for (uint32_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
			if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
  800fb6:	89 f8                	mov    %edi,%eax
  800fb8:	c1 e8 16             	shr    $0x16,%eax
  800fbb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fc2:	a8 01                	test   $0x1,%al
  800fc4:	0f 84 d2 00 00 00    	je     80109c <fork+0x14e>
  800fca:	89 fb                	mov    %edi,%ebx
  800fcc:	c1 eb 0c             	shr    $0xc,%ebx
  800fcf:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800fd6:	a8 01                	test   $0x1,%al
  800fd8:	0f 84 be 00 00 00    	je     80109c <fork+0x14e>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	int perm = PTE_U | PTE_P;
	envid_t curenvid = sys_getenvid();
  800fde:	e8 97 fc ff ff       	call   800c7a <sys_getenvid>
  800fe3:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  800fe6:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
		perm |= PTE_COW ;
  800fed:	be 05 08 00 00       	mov    $0x805,%esi
	int r;
	int perm = PTE_U | PTE_P;
	envid_t curenvid = sys_getenvid();

	// LAB 4: Your code here.
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  800ff2:	a8 02                	test   $0x2,%al
  800ff4:	75 1d                	jne    801013 <fork+0xc5>
  800ff6:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800ffd:	25 00 08 00 00       	and    $0x800,%eax
		perm |= PTE_COW ;
  801002:	83 f8 01             	cmp    $0x1,%eax
  801005:	19 f6                	sbb    %esi,%esi
  801007:	81 e6 00 f8 ff ff    	and    $0xfffff800,%esi
  80100d:	81 c6 05 08 00 00    	add    $0x805,%esi

	if (uvpt[pn] & PTE_SHARE)
  801013:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80101a:	25 00 04 00 00       	and    $0x400,%eax
		perm |= PTE_SYSCALL;
  80101f:	b8 07 0e 00 00       	mov    $0xe07,%eax
  801024:	0f 45 f0             	cmovne %eax,%esi

	r = sys_page_map(curenvid, (void *)(pn * PGSIZE),
  801027:	89 d8                	mov    %ebx,%eax
  801029:	c1 e0 0c             	shl    $0xc,%eax
  80102c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80102f:	83 ec 0c             	sub    $0xc,%esp
  801032:	56                   	push   %esi
  801033:	50                   	push   %eax
  801034:	ff 75 dc             	pushl  -0x24(%ebp)
  801037:	50                   	push   %eax
  801038:	ff 75 e4             	pushl  -0x1c(%ebp)
  80103b:	e8 bb fc ff ff       	call   800cfb <sys_page_map>
				envid, (void *)(pn * PGSIZE), perm);
	if (r < 0)
  801040:	83 c4 20             	add    $0x20,%esp
  801043:	85 c0                	test   %eax,%eax
  801045:	79 12                	jns    801059 <fork+0x10b>
		panic("duppage error: %e", r);
  801047:	50                   	push   %eax
  801048:	68 6b 2c 80 00       	push   $0x802c6b
  80104d:	6a 4d                	push   $0x4d
  80104f:	68 51 2c 80 00       	push   $0x802c51
  801054:	e8 7f f1 ff ff       	call   8001d8 <_panic>
	
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))	{
  801059:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801060:	a8 02                	test   $0x2,%al
  801062:	75 0c                	jne    801070 <fork+0x122>
  801064:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80106b:	f6 c4 08             	test   $0x8,%ah
  80106e:	74 2c                	je     80109c <fork+0x14e>
		r = sys_page_map(curenvid, (void *)(pn * PGSIZE),
  801070:	83 ec 0c             	sub    $0xc,%esp
  801073:	56                   	push   %esi
  801074:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801077:	52                   	push   %edx
  801078:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80107b:	50                   	push   %eax
  80107c:	52                   	push   %edx
  80107d:	50                   	push   %eax
  80107e:	e8 78 fc ff ff       	call   800cfb <sys_page_map>
						curenvid, (void *)(pn * PGSIZE), perm);
		if (r < 0)
  801083:	83 c4 20             	add    $0x20,%esp
  801086:	85 c0                	test   %eax,%eax
  801088:	79 12                	jns    80109c <fork+0x14e>
			panic("duppage error: %e", r);
  80108a:	50                   	push   %eax
  80108b:	68 6b 2c 80 00       	push   $0x802c6b
  801090:	6a 53                	push   $0x53
  801092:	68 51 2c 80 00       	push   $0x802c51
  801097:	e8 3c f1 ff ff       	call   8001d8 <_panic>
	    panic("fork error: %e", new_envid);
	else if (new_envid == 0)
		thisenv = envs + ENVX(sys_getenvid());
	else {

		for (uint32_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
  80109c:	81 c7 00 10 00 00    	add    $0x1000,%edi
  8010a2:	81 ff 00 e0 bf ee    	cmp    $0xeebfe000,%edi
  8010a8:	0f 85 08 ff ff ff    	jne    800fb6 <fork+0x68>
			if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
				duppage(new_envid, PGNUM(addr));
		}

		sys_page_alloc(new_envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  8010ae:	83 ec 04             	sub    $0x4,%esp
  8010b1:	6a 07                	push   $0x7
  8010b3:	68 00 f0 bf ee       	push   $0xeebff000
  8010b8:	8b 75 d8             	mov    -0x28(%ebp),%esi
  8010bb:	56                   	push   %esi
  8010bc:	e8 f7 fb ff ff       	call   800cb8 <sys_page_alloc>
		sys_env_set_pgfault_upcall(new_envid, _pgfault_upcall);
  8010c1:	83 c4 08             	add    $0x8,%esp
  8010c4:	68 1c 24 80 00       	push   $0x80241c
  8010c9:	56                   	push   %esi
  8010ca:	e8 34 fd ff ff       	call   800e03 <sys_env_set_pgfault_upcall>
		sys_env_set_status(new_envid, ENV_RUNNABLE);
  8010cf:	83 c4 08             	add    $0x8,%esp
  8010d2:	6a 02                	push   $0x2
  8010d4:	56                   	push   %esi
  8010d5:	e8 a5 fc ff ff       	call   800d7f <sys_env_set_status>
  8010da:	83 c4 10             	add    $0x10,%esp

	}
	return new_envid;
}
  8010dd:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8010e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e3:	5b                   	pop    %ebx
  8010e4:	5e                   	pop    %esi
  8010e5:	5f                   	pop    %edi
  8010e6:	5d                   	pop    %ebp
  8010e7:	c3                   	ret    

008010e8 <sfork>:

// Challenge!
int
sfork(void)
{
  8010e8:	55                   	push   %ebp
  8010e9:	89 e5                	mov    %esp,%ebp
  8010eb:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010ee:	68 7d 2c 80 00       	push   $0x802c7d
  8010f3:	68 8b 00 00 00       	push   $0x8b
  8010f8:	68 51 2c 80 00       	push   $0x802c51
  8010fd:	e8 d6 f0 ff ff       	call   8001d8 <_panic>

00801102 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801102:	55                   	push   %ebp
  801103:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801105:	8b 45 08             	mov    0x8(%ebp),%eax
  801108:	05 00 00 00 30       	add    $0x30000000,%eax
  80110d:	c1 e8 0c             	shr    $0xc,%eax
}
  801110:	5d                   	pop    %ebp
  801111:	c3                   	ret    

00801112 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801112:	55                   	push   %ebp
  801113:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801115:	8b 45 08             	mov    0x8(%ebp),%eax
  801118:	05 00 00 00 30       	add    $0x30000000,%eax
  80111d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801122:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801127:	5d                   	pop    %ebp
  801128:	c3                   	ret    

00801129 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801129:	55                   	push   %ebp
  80112a:	89 e5                	mov    %esp,%ebp
  80112c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80112f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801134:	89 c2                	mov    %eax,%edx
  801136:	c1 ea 16             	shr    $0x16,%edx
  801139:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801140:	f6 c2 01             	test   $0x1,%dl
  801143:	74 11                	je     801156 <fd_alloc+0x2d>
  801145:	89 c2                	mov    %eax,%edx
  801147:	c1 ea 0c             	shr    $0xc,%edx
  80114a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801151:	f6 c2 01             	test   $0x1,%dl
  801154:	75 09                	jne    80115f <fd_alloc+0x36>
			*fd_store = fd;
  801156:	89 01                	mov    %eax,(%ecx)
			return 0;
  801158:	b8 00 00 00 00       	mov    $0x0,%eax
  80115d:	eb 17                	jmp    801176 <fd_alloc+0x4d>
  80115f:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801164:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801169:	75 c9                	jne    801134 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80116b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801171:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801176:	5d                   	pop    %ebp
  801177:	c3                   	ret    

00801178 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801178:	55                   	push   %ebp
  801179:	89 e5                	mov    %esp,%ebp
  80117b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80117e:	83 f8 1f             	cmp    $0x1f,%eax
  801181:	77 36                	ja     8011b9 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801183:	c1 e0 0c             	shl    $0xc,%eax
  801186:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80118b:	89 c2                	mov    %eax,%edx
  80118d:	c1 ea 16             	shr    $0x16,%edx
  801190:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801197:	f6 c2 01             	test   $0x1,%dl
  80119a:	74 24                	je     8011c0 <fd_lookup+0x48>
  80119c:	89 c2                	mov    %eax,%edx
  80119e:	c1 ea 0c             	shr    $0xc,%edx
  8011a1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011a8:	f6 c2 01             	test   $0x1,%dl
  8011ab:	74 1a                	je     8011c7 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011b0:	89 02                	mov    %eax,(%edx)
	return 0;
  8011b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b7:	eb 13                	jmp    8011cc <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011be:	eb 0c                	jmp    8011cc <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011c0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011c5:	eb 05                	jmp    8011cc <fd_lookup+0x54>
  8011c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011cc:	5d                   	pop    %ebp
  8011cd:	c3                   	ret    

008011ce <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011ce:	55                   	push   %ebp
  8011cf:	89 e5                	mov    %esp,%ebp
  8011d1:	83 ec 08             	sub    $0x8,%esp
  8011d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011d7:	ba 10 2d 80 00       	mov    $0x802d10,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011dc:	eb 13                	jmp    8011f1 <dev_lookup+0x23>
  8011de:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011e1:	39 08                	cmp    %ecx,(%eax)
  8011e3:	75 0c                	jne    8011f1 <dev_lookup+0x23>
			*dev = devtab[i];
  8011e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011e8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ef:	eb 2e                	jmp    80121f <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011f1:	8b 02                	mov    (%edx),%eax
  8011f3:	85 c0                	test   %eax,%eax
  8011f5:	75 e7                	jne    8011de <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011f7:	a1 04 40 80 00       	mov    0x804004,%eax
  8011fc:	8b 40 48             	mov    0x48(%eax),%eax
  8011ff:	83 ec 04             	sub    $0x4,%esp
  801202:	51                   	push   %ecx
  801203:	50                   	push   %eax
  801204:	68 94 2c 80 00       	push   $0x802c94
  801209:	e8 a3 f0 ff ff       	call   8002b1 <cprintf>
	*dev = 0;
  80120e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801211:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801217:	83 c4 10             	add    $0x10,%esp
  80121a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80121f:	c9                   	leave  
  801220:	c3                   	ret    

00801221 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801221:	55                   	push   %ebp
  801222:	89 e5                	mov    %esp,%ebp
  801224:	56                   	push   %esi
  801225:	53                   	push   %ebx
  801226:	83 ec 10             	sub    $0x10,%esp
  801229:	8b 75 08             	mov    0x8(%ebp),%esi
  80122c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80122f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801232:	50                   	push   %eax
  801233:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801239:	c1 e8 0c             	shr    $0xc,%eax
  80123c:	50                   	push   %eax
  80123d:	e8 36 ff ff ff       	call   801178 <fd_lookup>
  801242:	83 c4 08             	add    $0x8,%esp
  801245:	85 c0                	test   %eax,%eax
  801247:	78 05                	js     80124e <fd_close+0x2d>
	    || fd != fd2)
  801249:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80124c:	74 0c                	je     80125a <fd_close+0x39>
		return (must_exist ? r : 0);
  80124e:	84 db                	test   %bl,%bl
  801250:	ba 00 00 00 00       	mov    $0x0,%edx
  801255:	0f 44 c2             	cmove  %edx,%eax
  801258:	eb 41                	jmp    80129b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80125a:	83 ec 08             	sub    $0x8,%esp
  80125d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801260:	50                   	push   %eax
  801261:	ff 36                	pushl  (%esi)
  801263:	e8 66 ff ff ff       	call   8011ce <dev_lookup>
  801268:	89 c3                	mov    %eax,%ebx
  80126a:	83 c4 10             	add    $0x10,%esp
  80126d:	85 c0                	test   %eax,%eax
  80126f:	78 1a                	js     80128b <fd_close+0x6a>
		if (dev->dev_close)
  801271:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801274:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801277:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80127c:	85 c0                	test   %eax,%eax
  80127e:	74 0b                	je     80128b <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801280:	83 ec 0c             	sub    $0xc,%esp
  801283:	56                   	push   %esi
  801284:	ff d0                	call   *%eax
  801286:	89 c3                	mov    %eax,%ebx
  801288:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80128b:	83 ec 08             	sub    $0x8,%esp
  80128e:	56                   	push   %esi
  80128f:	6a 00                	push   $0x0
  801291:	e8 a7 fa ff ff       	call   800d3d <sys_page_unmap>
	return r;
  801296:	83 c4 10             	add    $0x10,%esp
  801299:	89 d8                	mov    %ebx,%eax
}
  80129b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80129e:	5b                   	pop    %ebx
  80129f:	5e                   	pop    %esi
  8012a0:	5d                   	pop    %ebp
  8012a1:	c3                   	ret    

008012a2 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012a2:	55                   	push   %ebp
  8012a3:	89 e5                	mov    %esp,%ebp
  8012a5:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ab:	50                   	push   %eax
  8012ac:	ff 75 08             	pushl  0x8(%ebp)
  8012af:	e8 c4 fe ff ff       	call   801178 <fd_lookup>
  8012b4:	83 c4 08             	add    $0x8,%esp
  8012b7:	85 c0                	test   %eax,%eax
  8012b9:	78 10                	js     8012cb <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012bb:	83 ec 08             	sub    $0x8,%esp
  8012be:	6a 01                	push   $0x1
  8012c0:	ff 75 f4             	pushl  -0xc(%ebp)
  8012c3:	e8 59 ff ff ff       	call   801221 <fd_close>
  8012c8:	83 c4 10             	add    $0x10,%esp
}
  8012cb:	c9                   	leave  
  8012cc:	c3                   	ret    

008012cd <close_all>:

void
close_all(void)
{
  8012cd:	55                   	push   %ebp
  8012ce:	89 e5                	mov    %esp,%ebp
  8012d0:	53                   	push   %ebx
  8012d1:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012d4:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012d9:	83 ec 0c             	sub    $0xc,%esp
  8012dc:	53                   	push   %ebx
  8012dd:	e8 c0 ff ff ff       	call   8012a2 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012e2:	83 c3 01             	add    $0x1,%ebx
  8012e5:	83 c4 10             	add    $0x10,%esp
  8012e8:	83 fb 20             	cmp    $0x20,%ebx
  8012eb:	75 ec                	jne    8012d9 <close_all+0xc>
		close(i);
}
  8012ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012f0:	c9                   	leave  
  8012f1:	c3                   	ret    

008012f2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012f2:	55                   	push   %ebp
  8012f3:	89 e5                	mov    %esp,%ebp
  8012f5:	57                   	push   %edi
  8012f6:	56                   	push   %esi
  8012f7:	53                   	push   %ebx
  8012f8:	83 ec 2c             	sub    $0x2c,%esp
  8012fb:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012fe:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801301:	50                   	push   %eax
  801302:	ff 75 08             	pushl  0x8(%ebp)
  801305:	e8 6e fe ff ff       	call   801178 <fd_lookup>
  80130a:	83 c4 08             	add    $0x8,%esp
  80130d:	85 c0                	test   %eax,%eax
  80130f:	0f 88 c1 00 00 00    	js     8013d6 <dup+0xe4>
		return r;
	close(newfdnum);
  801315:	83 ec 0c             	sub    $0xc,%esp
  801318:	56                   	push   %esi
  801319:	e8 84 ff ff ff       	call   8012a2 <close>

	newfd = INDEX2FD(newfdnum);
  80131e:	89 f3                	mov    %esi,%ebx
  801320:	c1 e3 0c             	shl    $0xc,%ebx
  801323:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801329:	83 c4 04             	add    $0x4,%esp
  80132c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80132f:	e8 de fd ff ff       	call   801112 <fd2data>
  801334:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801336:	89 1c 24             	mov    %ebx,(%esp)
  801339:	e8 d4 fd ff ff       	call   801112 <fd2data>
  80133e:	83 c4 10             	add    $0x10,%esp
  801341:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801344:	89 f8                	mov    %edi,%eax
  801346:	c1 e8 16             	shr    $0x16,%eax
  801349:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801350:	a8 01                	test   $0x1,%al
  801352:	74 37                	je     80138b <dup+0x99>
  801354:	89 f8                	mov    %edi,%eax
  801356:	c1 e8 0c             	shr    $0xc,%eax
  801359:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801360:	f6 c2 01             	test   $0x1,%dl
  801363:	74 26                	je     80138b <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801365:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80136c:	83 ec 0c             	sub    $0xc,%esp
  80136f:	25 07 0e 00 00       	and    $0xe07,%eax
  801374:	50                   	push   %eax
  801375:	ff 75 d4             	pushl  -0x2c(%ebp)
  801378:	6a 00                	push   $0x0
  80137a:	57                   	push   %edi
  80137b:	6a 00                	push   $0x0
  80137d:	e8 79 f9 ff ff       	call   800cfb <sys_page_map>
  801382:	89 c7                	mov    %eax,%edi
  801384:	83 c4 20             	add    $0x20,%esp
  801387:	85 c0                	test   %eax,%eax
  801389:	78 2e                	js     8013b9 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80138b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80138e:	89 d0                	mov    %edx,%eax
  801390:	c1 e8 0c             	shr    $0xc,%eax
  801393:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80139a:	83 ec 0c             	sub    $0xc,%esp
  80139d:	25 07 0e 00 00       	and    $0xe07,%eax
  8013a2:	50                   	push   %eax
  8013a3:	53                   	push   %ebx
  8013a4:	6a 00                	push   $0x0
  8013a6:	52                   	push   %edx
  8013a7:	6a 00                	push   $0x0
  8013a9:	e8 4d f9 ff ff       	call   800cfb <sys_page_map>
  8013ae:	89 c7                	mov    %eax,%edi
  8013b0:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013b3:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013b5:	85 ff                	test   %edi,%edi
  8013b7:	79 1d                	jns    8013d6 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013b9:	83 ec 08             	sub    $0x8,%esp
  8013bc:	53                   	push   %ebx
  8013bd:	6a 00                	push   $0x0
  8013bf:	e8 79 f9 ff ff       	call   800d3d <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013c4:	83 c4 08             	add    $0x8,%esp
  8013c7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013ca:	6a 00                	push   $0x0
  8013cc:	e8 6c f9 ff ff       	call   800d3d <sys_page_unmap>
	return r;
  8013d1:	83 c4 10             	add    $0x10,%esp
  8013d4:	89 f8                	mov    %edi,%eax
}
  8013d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013d9:	5b                   	pop    %ebx
  8013da:	5e                   	pop    %esi
  8013db:	5f                   	pop    %edi
  8013dc:	5d                   	pop    %ebp
  8013dd:	c3                   	ret    

008013de <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013de:	55                   	push   %ebp
  8013df:	89 e5                	mov    %esp,%ebp
  8013e1:	53                   	push   %ebx
  8013e2:	83 ec 14             	sub    $0x14,%esp
  8013e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013eb:	50                   	push   %eax
  8013ec:	53                   	push   %ebx
  8013ed:	e8 86 fd ff ff       	call   801178 <fd_lookup>
  8013f2:	83 c4 08             	add    $0x8,%esp
  8013f5:	89 c2                	mov    %eax,%edx
  8013f7:	85 c0                	test   %eax,%eax
  8013f9:	78 6d                	js     801468 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013fb:	83 ec 08             	sub    $0x8,%esp
  8013fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801401:	50                   	push   %eax
  801402:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801405:	ff 30                	pushl  (%eax)
  801407:	e8 c2 fd ff ff       	call   8011ce <dev_lookup>
  80140c:	83 c4 10             	add    $0x10,%esp
  80140f:	85 c0                	test   %eax,%eax
  801411:	78 4c                	js     80145f <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801413:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801416:	8b 42 08             	mov    0x8(%edx),%eax
  801419:	83 e0 03             	and    $0x3,%eax
  80141c:	83 f8 01             	cmp    $0x1,%eax
  80141f:	75 21                	jne    801442 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801421:	a1 04 40 80 00       	mov    0x804004,%eax
  801426:	8b 40 48             	mov    0x48(%eax),%eax
  801429:	83 ec 04             	sub    $0x4,%esp
  80142c:	53                   	push   %ebx
  80142d:	50                   	push   %eax
  80142e:	68 d5 2c 80 00       	push   $0x802cd5
  801433:	e8 79 ee ff ff       	call   8002b1 <cprintf>
		return -E_INVAL;
  801438:	83 c4 10             	add    $0x10,%esp
  80143b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801440:	eb 26                	jmp    801468 <read+0x8a>
	}
	if (!dev->dev_read)
  801442:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801445:	8b 40 08             	mov    0x8(%eax),%eax
  801448:	85 c0                	test   %eax,%eax
  80144a:	74 17                	je     801463 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80144c:	83 ec 04             	sub    $0x4,%esp
  80144f:	ff 75 10             	pushl  0x10(%ebp)
  801452:	ff 75 0c             	pushl  0xc(%ebp)
  801455:	52                   	push   %edx
  801456:	ff d0                	call   *%eax
  801458:	89 c2                	mov    %eax,%edx
  80145a:	83 c4 10             	add    $0x10,%esp
  80145d:	eb 09                	jmp    801468 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80145f:	89 c2                	mov    %eax,%edx
  801461:	eb 05                	jmp    801468 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801463:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801468:	89 d0                	mov    %edx,%eax
  80146a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80146d:	c9                   	leave  
  80146e:	c3                   	ret    

0080146f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80146f:	55                   	push   %ebp
  801470:	89 e5                	mov    %esp,%ebp
  801472:	57                   	push   %edi
  801473:	56                   	push   %esi
  801474:	53                   	push   %ebx
  801475:	83 ec 0c             	sub    $0xc,%esp
  801478:	8b 7d 08             	mov    0x8(%ebp),%edi
  80147b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80147e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801483:	eb 21                	jmp    8014a6 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801485:	83 ec 04             	sub    $0x4,%esp
  801488:	89 f0                	mov    %esi,%eax
  80148a:	29 d8                	sub    %ebx,%eax
  80148c:	50                   	push   %eax
  80148d:	89 d8                	mov    %ebx,%eax
  80148f:	03 45 0c             	add    0xc(%ebp),%eax
  801492:	50                   	push   %eax
  801493:	57                   	push   %edi
  801494:	e8 45 ff ff ff       	call   8013de <read>
		if (m < 0)
  801499:	83 c4 10             	add    $0x10,%esp
  80149c:	85 c0                	test   %eax,%eax
  80149e:	78 10                	js     8014b0 <readn+0x41>
			return m;
		if (m == 0)
  8014a0:	85 c0                	test   %eax,%eax
  8014a2:	74 0a                	je     8014ae <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014a4:	01 c3                	add    %eax,%ebx
  8014a6:	39 f3                	cmp    %esi,%ebx
  8014a8:	72 db                	jb     801485 <readn+0x16>
  8014aa:	89 d8                	mov    %ebx,%eax
  8014ac:	eb 02                	jmp    8014b0 <readn+0x41>
  8014ae:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014b3:	5b                   	pop    %ebx
  8014b4:	5e                   	pop    %esi
  8014b5:	5f                   	pop    %edi
  8014b6:	5d                   	pop    %ebp
  8014b7:	c3                   	ret    

008014b8 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014b8:	55                   	push   %ebp
  8014b9:	89 e5                	mov    %esp,%ebp
  8014bb:	53                   	push   %ebx
  8014bc:	83 ec 14             	sub    $0x14,%esp
  8014bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014c2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014c5:	50                   	push   %eax
  8014c6:	53                   	push   %ebx
  8014c7:	e8 ac fc ff ff       	call   801178 <fd_lookup>
  8014cc:	83 c4 08             	add    $0x8,%esp
  8014cf:	89 c2                	mov    %eax,%edx
  8014d1:	85 c0                	test   %eax,%eax
  8014d3:	78 68                	js     80153d <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d5:	83 ec 08             	sub    $0x8,%esp
  8014d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014db:	50                   	push   %eax
  8014dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014df:	ff 30                	pushl  (%eax)
  8014e1:	e8 e8 fc ff ff       	call   8011ce <dev_lookup>
  8014e6:	83 c4 10             	add    $0x10,%esp
  8014e9:	85 c0                	test   %eax,%eax
  8014eb:	78 47                	js     801534 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014f0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014f4:	75 21                	jne    801517 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014f6:	a1 04 40 80 00       	mov    0x804004,%eax
  8014fb:	8b 40 48             	mov    0x48(%eax),%eax
  8014fe:	83 ec 04             	sub    $0x4,%esp
  801501:	53                   	push   %ebx
  801502:	50                   	push   %eax
  801503:	68 f1 2c 80 00       	push   $0x802cf1
  801508:	e8 a4 ed ff ff       	call   8002b1 <cprintf>
		return -E_INVAL;
  80150d:	83 c4 10             	add    $0x10,%esp
  801510:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801515:	eb 26                	jmp    80153d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801517:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80151a:	8b 52 0c             	mov    0xc(%edx),%edx
  80151d:	85 d2                	test   %edx,%edx
  80151f:	74 17                	je     801538 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801521:	83 ec 04             	sub    $0x4,%esp
  801524:	ff 75 10             	pushl  0x10(%ebp)
  801527:	ff 75 0c             	pushl  0xc(%ebp)
  80152a:	50                   	push   %eax
  80152b:	ff d2                	call   *%edx
  80152d:	89 c2                	mov    %eax,%edx
  80152f:	83 c4 10             	add    $0x10,%esp
  801532:	eb 09                	jmp    80153d <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801534:	89 c2                	mov    %eax,%edx
  801536:	eb 05                	jmp    80153d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801538:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80153d:	89 d0                	mov    %edx,%eax
  80153f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801542:	c9                   	leave  
  801543:	c3                   	ret    

00801544 <seek>:

int
seek(int fdnum, off_t offset)
{
  801544:	55                   	push   %ebp
  801545:	89 e5                	mov    %esp,%ebp
  801547:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80154a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80154d:	50                   	push   %eax
  80154e:	ff 75 08             	pushl  0x8(%ebp)
  801551:	e8 22 fc ff ff       	call   801178 <fd_lookup>
  801556:	83 c4 08             	add    $0x8,%esp
  801559:	85 c0                	test   %eax,%eax
  80155b:	78 0e                	js     80156b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80155d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801560:	8b 55 0c             	mov    0xc(%ebp),%edx
  801563:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801566:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80156b:	c9                   	leave  
  80156c:	c3                   	ret    

0080156d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80156d:	55                   	push   %ebp
  80156e:	89 e5                	mov    %esp,%ebp
  801570:	53                   	push   %ebx
  801571:	83 ec 14             	sub    $0x14,%esp
  801574:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801577:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80157a:	50                   	push   %eax
  80157b:	53                   	push   %ebx
  80157c:	e8 f7 fb ff ff       	call   801178 <fd_lookup>
  801581:	83 c4 08             	add    $0x8,%esp
  801584:	89 c2                	mov    %eax,%edx
  801586:	85 c0                	test   %eax,%eax
  801588:	78 65                	js     8015ef <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80158a:	83 ec 08             	sub    $0x8,%esp
  80158d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801590:	50                   	push   %eax
  801591:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801594:	ff 30                	pushl  (%eax)
  801596:	e8 33 fc ff ff       	call   8011ce <dev_lookup>
  80159b:	83 c4 10             	add    $0x10,%esp
  80159e:	85 c0                	test   %eax,%eax
  8015a0:	78 44                	js     8015e6 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015a9:	75 21                	jne    8015cc <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015ab:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015b0:	8b 40 48             	mov    0x48(%eax),%eax
  8015b3:	83 ec 04             	sub    $0x4,%esp
  8015b6:	53                   	push   %ebx
  8015b7:	50                   	push   %eax
  8015b8:	68 b4 2c 80 00       	push   $0x802cb4
  8015bd:	e8 ef ec ff ff       	call   8002b1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015c2:	83 c4 10             	add    $0x10,%esp
  8015c5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015ca:	eb 23                	jmp    8015ef <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015cf:	8b 52 18             	mov    0x18(%edx),%edx
  8015d2:	85 d2                	test   %edx,%edx
  8015d4:	74 14                	je     8015ea <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015d6:	83 ec 08             	sub    $0x8,%esp
  8015d9:	ff 75 0c             	pushl  0xc(%ebp)
  8015dc:	50                   	push   %eax
  8015dd:	ff d2                	call   *%edx
  8015df:	89 c2                	mov    %eax,%edx
  8015e1:	83 c4 10             	add    $0x10,%esp
  8015e4:	eb 09                	jmp    8015ef <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e6:	89 c2                	mov    %eax,%edx
  8015e8:	eb 05                	jmp    8015ef <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015ea:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015ef:	89 d0                	mov    %edx,%eax
  8015f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f4:	c9                   	leave  
  8015f5:	c3                   	ret    

008015f6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015f6:	55                   	push   %ebp
  8015f7:	89 e5                	mov    %esp,%ebp
  8015f9:	53                   	push   %ebx
  8015fa:	83 ec 14             	sub    $0x14,%esp
  8015fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801600:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801603:	50                   	push   %eax
  801604:	ff 75 08             	pushl  0x8(%ebp)
  801607:	e8 6c fb ff ff       	call   801178 <fd_lookup>
  80160c:	83 c4 08             	add    $0x8,%esp
  80160f:	89 c2                	mov    %eax,%edx
  801611:	85 c0                	test   %eax,%eax
  801613:	78 58                	js     80166d <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801615:	83 ec 08             	sub    $0x8,%esp
  801618:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80161b:	50                   	push   %eax
  80161c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161f:	ff 30                	pushl  (%eax)
  801621:	e8 a8 fb ff ff       	call   8011ce <dev_lookup>
  801626:	83 c4 10             	add    $0x10,%esp
  801629:	85 c0                	test   %eax,%eax
  80162b:	78 37                	js     801664 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80162d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801630:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801634:	74 32                	je     801668 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801636:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801639:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801640:	00 00 00 
	stat->st_isdir = 0;
  801643:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80164a:	00 00 00 
	stat->st_dev = dev;
  80164d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801653:	83 ec 08             	sub    $0x8,%esp
  801656:	53                   	push   %ebx
  801657:	ff 75 f0             	pushl  -0x10(%ebp)
  80165a:	ff 50 14             	call   *0x14(%eax)
  80165d:	89 c2                	mov    %eax,%edx
  80165f:	83 c4 10             	add    $0x10,%esp
  801662:	eb 09                	jmp    80166d <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801664:	89 c2                	mov    %eax,%edx
  801666:	eb 05                	jmp    80166d <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801668:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80166d:	89 d0                	mov    %edx,%eax
  80166f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801672:	c9                   	leave  
  801673:	c3                   	ret    

00801674 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801674:	55                   	push   %ebp
  801675:	89 e5                	mov    %esp,%ebp
  801677:	56                   	push   %esi
  801678:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801679:	83 ec 08             	sub    $0x8,%esp
  80167c:	6a 00                	push   $0x0
  80167e:	ff 75 08             	pushl  0x8(%ebp)
  801681:	e8 e3 01 00 00       	call   801869 <open>
  801686:	89 c3                	mov    %eax,%ebx
  801688:	83 c4 10             	add    $0x10,%esp
  80168b:	85 c0                	test   %eax,%eax
  80168d:	78 1b                	js     8016aa <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80168f:	83 ec 08             	sub    $0x8,%esp
  801692:	ff 75 0c             	pushl  0xc(%ebp)
  801695:	50                   	push   %eax
  801696:	e8 5b ff ff ff       	call   8015f6 <fstat>
  80169b:	89 c6                	mov    %eax,%esi
	close(fd);
  80169d:	89 1c 24             	mov    %ebx,(%esp)
  8016a0:	e8 fd fb ff ff       	call   8012a2 <close>
	return r;
  8016a5:	83 c4 10             	add    $0x10,%esp
  8016a8:	89 f0                	mov    %esi,%eax
}
  8016aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ad:	5b                   	pop    %ebx
  8016ae:	5e                   	pop    %esi
  8016af:	5d                   	pop    %ebp
  8016b0:	c3                   	ret    

008016b1 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016b1:	55                   	push   %ebp
  8016b2:	89 e5                	mov    %esp,%ebp
  8016b4:	56                   	push   %esi
  8016b5:	53                   	push   %ebx
  8016b6:	89 c6                	mov    %eax,%esi
  8016b8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016ba:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016c1:	75 12                	jne    8016d5 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016c3:	83 ec 0c             	sub    $0xc,%esp
  8016c6:	6a 01                	push   $0x1
  8016c8:	e8 3b 0e 00 00       	call   802508 <ipc_find_env>
  8016cd:	a3 00 40 80 00       	mov    %eax,0x804000
  8016d2:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016d5:	6a 07                	push   $0x7
  8016d7:	68 00 50 80 00       	push   $0x805000
  8016dc:	56                   	push   %esi
  8016dd:	ff 35 00 40 80 00    	pushl  0x804000
  8016e3:	e8 cc 0d 00 00       	call   8024b4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016e8:	83 c4 0c             	add    $0xc,%esp
  8016eb:	6a 00                	push   $0x0
  8016ed:	53                   	push   %ebx
  8016ee:	6a 00                	push   $0x0
  8016f0:	e8 4d 0d 00 00       	call   802442 <ipc_recv>
}
  8016f5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016f8:	5b                   	pop    %ebx
  8016f9:	5e                   	pop    %esi
  8016fa:	5d                   	pop    %ebp
  8016fb:	c3                   	ret    

008016fc <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016fc:	55                   	push   %ebp
  8016fd:	89 e5                	mov    %esp,%ebp
  8016ff:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801702:	8b 45 08             	mov    0x8(%ebp),%eax
  801705:	8b 40 0c             	mov    0xc(%eax),%eax
  801708:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80170d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801710:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801715:	ba 00 00 00 00       	mov    $0x0,%edx
  80171a:	b8 02 00 00 00       	mov    $0x2,%eax
  80171f:	e8 8d ff ff ff       	call   8016b1 <fsipc>
}
  801724:	c9                   	leave  
  801725:	c3                   	ret    

00801726 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801726:	55                   	push   %ebp
  801727:	89 e5                	mov    %esp,%ebp
  801729:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80172c:	8b 45 08             	mov    0x8(%ebp),%eax
  80172f:	8b 40 0c             	mov    0xc(%eax),%eax
  801732:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801737:	ba 00 00 00 00       	mov    $0x0,%edx
  80173c:	b8 06 00 00 00       	mov    $0x6,%eax
  801741:	e8 6b ff ff ff       	call   8016b1 <fsipc>
}
  801746:	c9                   	leave  
  801747:	c3                   	ret    

00801748 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801748:	55                   	push   %ebp
  801749:	89 e5                	mov    %esp,%ebp
  80174b:	53                   	push   %ebx
  80174c:	83 ec 04             	sub    $0x4,%esp
  80174f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801752:	8b 45 08             	mov    0x8(%ebp),%eax
  801755:	8b 40 0c             	mov    0xc(%eax),%eax
  801758:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80175d:	ba 00 00 00 00       	mov    $0x0,%edx
  801762:	b8 05 00 00 00       	mov    $0x5,%eax
  801767:	e8 45 ff ff ff       	call   8016b1 <fsipc>
  80176c:	85 c0                	test   %eax,%eax
  80176e:	78 2c                	js     80179c <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801770:	83 ec 08             	sub    $0x8,%esp
  801773:	68 00 50 80 00       	push   $0x805000
  801778:	53                   	push   %ebx
  801779:	e8 37 f1 ff ff       	call   8008b5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80177e:	a1 80 50 80 00       	mov    0x805080,%eax
  801783:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801789:	a1 84 50 80 00       	mov    0x805084,%eax
  80178e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801794:	83 c4 10             	add    $0x10,%esp
  801797:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80179c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80179f:	c9                   	leave  
  8017a0:	c3                   	ret    

008017a1 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017a1:	55                   	push   %ebp
  8017a2:	89 e5                	mov    %esp,%ebp
  8017a4:	83 ec 0c             	sub    $0xc,%esp
  8017a7:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	
	int r;

	n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8017aa:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8017af:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8017b4:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8017ba:	8b 52 0c             	mov    0xc(%edx),%edx
  8017bd:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8017c3:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8017c8:	50                   	push   %eax
  8017c9:	ff 75 0c             	pushl  0xc(%ebp)
  8017cc:	68 08 50 80 00       	push   $0x805008
  8017d1:	e8 71 f2 ff ff       	call   800a47 <memmove>
	
	return fsipc(FSREQ_WRITE, NULL);	
  8017d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8017db:	b8 04 00 00 00       	mov    $0x4,%eax
  8017e0:	e8 cc fe ff ff       	call   8016b1 <fsipc>
}
  8017e5:	c9                   	leave  
  8017e6:	c3                   	ret    

008017e7 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017e7:	55                   	push   %ebp
  8017e8:	89 e5                	mov    %esp,%ebp
  8017ea:	56                   	push   %esi
  8017eb:	53                   	push   %ebx
  8017ec:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f2:	8b 40 0c             	mov    0xc(%eax),%eax
  8017f5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017fa:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801800:	ba 00 00 00 00       	mov    $0x0,%edx
  801805:	b8 03 00 00 00       	mov    $0x3,%eax
  80180a:	e8 a2 fe ff ff       	call   8016b1 <fsipc>
  80180f:	89 c3                	mov    %eax,%ebx
  801811:	85 c0                	test   %eax,%eax
  801813:	78 4b                	js     801860 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801815:	39 c6                	cmp    %eax,%esi
  801817:	73 16                	jae    80182f <devfile_read+0x48>
  801819:	68 20 2d 80 00       	push   $0x802d20
  80181e:	68 27 2d 80 00       	push   $0x802d27
  801823:	6a 7c                	push   $0x7c
  801825:	68 3c 2d 80 00       	push   $0x802d3c
  80182a:	e8 a9 e9 ff ff       	call   8001d8 <_panic>
	assert(r <= PGSIZE);
  80182f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801834:	7e 16                	jle    80184c <devfile_read+0x65>
  801836:	68 47 2d 80 00       	push   $0x802d47
  80183b:	68 27 2d 80 00       	push   $0x802d27
  801840:	6a 7d                	push   $0x7d
  801842:	68 3c 2d 80 00       	push   $0x802d3c
  801847:	e8 8c e9 ff ff       	call   8001d8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80184c:	83 ec 04             	sub    $0x4,%esp
  80184f:	50                   	push   %eax
  801850:	68 00 50 80 00       	push   $0x805000
  801855:	ff 75 0c             	pushl  0xc(%ebp)
  801858:	e8 ea f1 ff ff       	call   800a47 <memmove>
	return r;
  80185d:	83 c4 10             	add    $0x10,%esp
}
  801860:	89 d8                	mov    %ebx,%eax
  801862:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801865:	5b                   	pop    %ebx
  801866:	5e                   	pop    %esi
  801867:	5d                   	pop    %ebp
  801868:	c3                   	ret    

00801869 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801869:	55                   	push   %ebp
  80186a:	89 e5                	mov    %esp,%ebp
  80186c:	53                   	push   %ebx
  80186d:	83 ec 20             	sub    $0x20,%esp
  801870:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801873:	53                   	push   %ebx
  801874:	e8 03 f0 ff ff       	call   80087c <strlen>
  801879:	83 c4 10             	add    $0x10,%esp
  80187c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801881:	7f 67                	jg     8018ea <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801883:	83 ec 0c             	sub    $0xc,%esp
  801886:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801889:	50                   	push   %eax
  80188a:	e8 9a f8 ff ff       	call   801129 <fd_alloc>
  80188f:	83 c4 10             	add    $0x10,%esp
		return r;
  801892:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801894:	85 c0                	test   %eax,%eax
  801896:	78 57                	js     8018ef <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801898:	83 ec 08             	sub    $0x8,%esp
  80189b:	53                   	push   %ebx
  80189c:	68 00 50 80 00       	push   $0x805000
  8018a1:	e8 0f f0 ff ff       	call   8008b5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018a9:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8018b6:	e8 f6 fd ff ff       	call   8016b1 <fsipc>
  8018bb:	89 c3                	mov    %eax,%ebx
  8018bd:	83 c4 10             	add    $0x10,%esp
  8018c0:	85 c0                	test   %eax,%eax
  8018c2:	79 14                	jns    8018d8 <open+0x6f>
		fd_close(fd, 0);
  8018c4:	83 ec 08             	sub    $0x8,%esp
  8018c7:	6a 00                	push   $0x0
  8018c9:	ff 75 f4             	pushl  -0xc(%ebp)
  8018cc:	e8 50 f9 ff ff       	call   801221 <fd_close>
		return r;
  8018d1:	83 c4 10             	add    $0x10,%esp
  8018d4:	89 da                	mov    %ebx,%edx
  8018d6:	eb 17                	jmp    8018ef <open+0x86>
	}

	return fd2num(fd);
  8018d8:	83 ec 0c             	sub    $0xc,%esp
  8018db:	ff 75 f4             	pushl  -0xc(%ebp)
  8018de:	e8 1f f8 ff ff       	call   801102 <fd2num>
  8018e3:	89 c2                	mov    %eax,%edx
  8018e5:	83 c4 10             	add    $0x10,%esp
  8018e8:	eb 05                	jmp    8018ef <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018ea:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018ef:	89 d0                	mov    %edx,%eax
  8018f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018f4:	c9                   	leave  
  8018f5:	c3                   	ret    

008018f6 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018f6:	55                   	push   %ebp
  8018f7:	89 e5                	mov    %esp,%ebp
  8018f9:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018fc:	ba 00 00 00 00       	mov    $0x0,%edx
  801901:	b8 08 00 00 00       	mov    $0x8,%eax
  801906:	e8 a6 fd ff ff       	call   8016b1 <fsipc>
}
  80190b:	c9                   	leave  
  80190c:	c3                   	ret    

0080190d <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  80190d:	55                   	push   %ebp
  80190e:	89 e5                	mov    %esp,%ebp
  801910:	57                   	push   %edi
  801911:	56                   	push   %esi
  801912:	53                   	push   %ebx
  801913:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801919:	6a 00                	push   $0x0
  80191b:	ff 75 08             	pushl  0x8(%ebp)
  80191e:	e8 46 ff ff ff       	call   801869 <open>
  801923:	89 c7                	mov    %eax,%edi
  801925:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  80192b:	83 c4 10             	add    $0x10,%esp
  80192e:	85 c0                	test   %eax,%eax
  801930:	0f 88 96 04 00 00    	js     801dcc <spawn+0x4bf>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  801936:	83 ec 04             	sub    $0x4,%esp
  801939:	68 00 02 00 00       	push   $0x200
  80193e:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801944:	50                   	push   %eax
  801945:	57                   	push   %edi
  801946:	e8 24 fb ff ff       	call   80146f <readn>
  80194b:	83 c4 10             	add    $0x10,%esp
  80194e:	3d 00 02 00 00       	cmp    $0x200,%eax
  801953:	75 0c                	jne    801961 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  801955:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  80195c:	45 4c 46 
  80195f:	74 33                	je     801994 <spawn+0x87>
		close(fd);
  801961:	83 ec 0c             	sub    $0xc,%esp
  801964:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80196a:	e8 33 f9 ff ff       	call   8012a2 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80196f:	83 c4 0c             	add    $0xc,%esp
  801972:	68 7f 45 4c 46       	push   $0x464c457f
  801977:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  80197d:	68 53 2d 80 00       	push   $0x802d53
  801982:	e8 2a e9 ff ff       	call   8002b1 <cprintf>
		return -E_NOT_EXEC;
  801987:	83 c4 10             	add    $0x10,%esp
  80198a:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  80198f:	e9 98 04 00 00       	jmp    801e2c <spawn+0x51f>
  801994:	b8 07 00 00 00       	mov    $0x7,%eax
  801999:	cd 30                	int    $0x30
  80199b:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  8019a1:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  8019a7:	85 c0                	test   %eax,%eax
  8019a9:	0f 88 25 04 00 00    	js     801dd4 <spawn+0x4c7>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  8019af:	89 c6                	mov    %eax,%esi
  8019b1:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8019b7:	6b f6 7c             	imul   $0x7c,%esi,%esi
  8019ba:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8019c0:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8019c6:	b9 11 00 00 00       	mov    $0x11,%ecx
  8019cb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8019cd:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8019d3:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8019d9:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8019de:	be 00 00 00 00       	mov    $0x0,%esi
  8019e3:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8019e6:	eb 13                	jmp    8019fb <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  8019e8:	83 ec 0c             	sub    $0xc,%esp
  8019eb:	50                   	push   %eax
  8019ec:	e8 8b ee ff ff       	call   80087c <strlen>
  8019f1:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8019f5:	83 c3 01             	add    $0x1,%ebx
  8019f8:	83 c4 10             	add    $0x10,%esp
  8019fb:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801a02:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801a05:	85 c0                	test   %eax,%eax
  801a07:	75 df                	jne    8019e8 <spawn+0xdb>
  801a09:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801a0f:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801a15:	bf 00 10 40 00       	mov    $0x401000,%edi
  801a1a:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801a1c:	89 fa                	mov    %edi,%edx
  801a1e:	83 e2 fc             	and    $0xfffffffc,%edx
  801a21:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801a28:	29 c2                	sub    %eax,%edx
  801a2a:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801a30:	8d 42 f8             	lea    -0x8(%edx),%eax
  801a33:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801a38:	0f 86 a6 03 00 00    	jbe    801de4 <spawn+0x4d7>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801a3e:	83 ec 04             	sub    $0x4,%esp
  801a41:	6a 07                	push   $0x7
  801a43:	68 00 00 40 00       	push   $0x400000
  801a48:	6a 00                	push   $0x0
  801a4a:	e8 69 f2 ff ff       	call   800cb8 <sys_page_alloc>
  801a4f:	83 c4 10             	add    $0x10,%esp
  801a52:	85 c0                	test   %eax,%eax
  801a54:	0f 88 91 03 00 00    	js     801deb <spawn+0x4de>
  801a5a:	be 00 00 00 00       	mov    $0x0,%esi
  801a5f:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801a65:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801a68:	eb 30                	jmp    801a9a <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801a6a:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801a70:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801a76:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  801a79:	83 ec 08             	sub    $0x8,%esp
  801a7c:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801a7f:	57                   	push   %edi
  801a80:	e8 30 ee ff ff       	call   8008b5 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801a85:	83 c4 04             	add    $0x4,%esp
  801a88:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801a8b:	e8 ec ed ff ff       	call   80087c <strlen>
  801a90:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801a94:	83 c6 01             	add    $0x1,%esi
  801a97:	83 c4 10             	add    $0x10,%esp
  801a9a:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801aa0:	7f c8                	jg     801a6a <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801aa2:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801aa8:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801aae:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801ab5:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801abb:	74 19                	je     801ad6 <spawn+0x1c9>
  801abd:	68 c8 2d 80 00       	push   $0x802dc8
  801ac2:	68 27 2d 80 00       	push   $0x802d27
  801ac7:	68 f1 00 00 00       	push   $0xf1
  801acc:	68 6d 2d 80 00       	push   $0x802d6d
  801ad1:	e8 02 e7 ff ff       	call   8001d8 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801ad6:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801adc:	89 f8                	mov    %edi,%eax
  801ade:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801ae3:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801ae6:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801aec:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801aef:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801af5:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801afb:	83 ec 0c             	sub    $0xc,%esp
  801afe:	6a 07                	push   $0x7
  801b00:	68 00 d0 bf ee       	push   $0xeebfd000
  801b05:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b0b:	68 00 00 40 00       	push   $0x400000
  801b10:	6a 00                	push   $0x0
  801b12:	e8 e4 f1 ff ff       	call   800cfb <sys_page_map>
  801b17:	89 c3                	mov    %eax,%ebx
  801b19:	83 c4 20             	add    $0x20,%esp
  801b1c:	85 c0                	test   %eax,%eax
  801b1e:	0f 88 f6 02 00 00    	js     801e1a <spawn+0x50d>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801b24:	83 ec 08             	sub    $0x8,%esp
  801b27:	68 00 00 40 00       	push   $0x400000
  801b2c:	6a 00                	push   $0x0
  801b2e:	e8 0a f2 ff ff       	call   800d3d <sys_page_unmap>
  801b33:	89 c3                	mov    %eax,%ebx
  801b35:	83 c4 10             	add    $0x10,%esp
  801b38:	85 c0                	test   %eax,%eax
  801b3a:	0f 88 da 02 00 00    	js     801e1a <spawn+0x50d>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801b40:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801b46:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801b4d:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801b53:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801b5a:	00 00 00 
  801b5d:	e9 88 01 00 00       	jmp    801cea <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  801b62:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801b68:	83 38 01             	cmpl   $0x1,(%eax)
  801b6b:	0f 85 6b 01 00 00    	jne    801cdc <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801b71:	89 c2                	mov    %eax,%edx
  801b73:	8b 40 18             	mov    0x18(%eax),%eax
  801b76:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801b7c:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801b7f:	83 f8 01             	cmp    $0x1,%eax
  801b82:	19 c0                	sbb    %eax,%eax
  801b84:	83 e0 fe             	and    $0xfffffffe,%eax
  801b87:	83 c0 07             	add    $0x7,%eax
  801b8a:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801b90:	89 d0                	mov    %edx,%eax
  801b92:	8b 7a 04             	mov    0x4(%edx),%edi
  801b95:	89 fa                	mov    %edi,%edx
  801b97:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801b9d:	8b 78 10             	mov    0x10(%eax),%edi
  801ba0:	8b 48 14             	mov    0x14(%eax),%ecx
  801ba3:	89 8d 90 fd ff ff    	mov    %ecx,-0x270(%ebp)
  801ba9:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801bac:	89 f0                	mov    %esi,%eax
  801bae:	25 ff 0f 00 00       	and    $0xfff,%eax
  801bb3:	74 14                	je     801bc9 <spawn+0x2bc>
		va -= i;
  801bb5:	29 c6                	sub    %eax,%esi
		memsz += i;
  801bb7:	01 c1                	add    %eax,%ecx
  801bb9:	89 8d 90 fd ff ff    	mov    %ecx,-0x270(%ebp)
		filesz += i;
  801bbf:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801bc1:	29 c2                	sub    %eax,%edx
  801bc3:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801bc9:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bce:	e9 f7 00 00 00       	jmp    801cca <spawn+0x3bd>
		if (i >= filesz) {
  801bd3:	39 df                	cmp    %ebx,%edi
  801bd5:	77 27                	ja     801bfe <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801bd7:	83 ec 04             	sub    $0x4,%esp
  801bda:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801be0:	56                   	push   %esi
  801be1:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801be7:	e8 cc f0 ff ff       	call   800cb8 <sys_page_alloc>
  801bec:	83 c4 10             	add    $0x10,%esp
  801bef:	85 c0                	test   %eax,%eax
  801bf1:	0f 89 c7 00 00 00    	jns    801cbe <spawn+0x3b1>
  801bf7:	89 c3                	mov    %eax,%ebx
  801bf9:	e9 fb 01 00 00       	jmp    801df9 <spawn+0x4ec>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801bfe:	83 ec 04             	sub    $0x4,%esp
  801c01:	6a 07                	push   $0x7
  801c03:	68 00 00 40 00       	push   $0x400000
  801c08:	6a 00                	push   $0x0
  801c0a:	e8 a9 f0 ff ff       	call   800cb8 <sys_page_alloc>
  801c0f:	83 c4 10             	add    $0x10,%esp
  801c12:	85 c0                	test   %eax,%eax
  801c14:	0f 88 d5 01 00 00    	js     801def <spawn+0x4e2>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801c1a:	83 ec 08             	sub    $0x8,%esp
  801c1d:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801c23:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801c29:	50                   	push   %eax
  801c2a:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c30:	e8 0f f9 ff ff       	call   801544 <seek>
  801c35:	83 c4 10             	add    $0x10,%esp
  801c38:	85 c0                	test   %eax,%eax
  801c3a:	0f 88 b3 01 00 00    	js     801df3 <spawn+0x4e6>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801c40:	83 ec 04             	sub    $0x4,%esp
  801c43:	89 f8                	mov    %edi,%eax
  801c45:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801c4b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801c50:	ba 00 10 00 00       	mov    $0x1000,%edx
  801c55:	0f 47 c2             	cmova  %edx,%eax
  801c58:	50                   	push   %eax
  801c59:	68 00 00 40 00       	push   $0x400000
  801c5e:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c64:	e8 06 f8 ff ff       	call   80146f <readn>
  801c69:	83 c4 10             	add    $0x10,%esp
  801c6c:	85 c0                	test   %eax,%eax
  801c6e:	0f 88 83 01 00 00    	js     801df7 <spawn+0x4ea>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801c74:	83 ec 0c             	sub    $0xc,%esp
  801c77:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801c7d:	56                   	push   %esi
  801c7e:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801c84:	68 00 00 40 00       	push   $0x400000
  801c89:	6a 00                	push   $0x0
  801c8b:	e8 6b f0 ff ff       	call   800cfb <sys_page_map>
  801c90:	83 c4 20             	add    $0x20,%esp
  801c93:	85 c0                	test   %eax,%eax
  801c95:	79 15                	jns    801cac <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  801c97:	50                   	push   %eax
  801c98:	68 79 2d 80 00       	push   $0x802d79
  801c9d:	68 24 01 00 00       	push   $0x124
  801ca2:	68 6d 2d 80 00       	push   $0x802d6d
  801ca7:	e8 2c e5 ff ff       	call   8001d8 <_panic>
			sys_page_unmap(0, UTEMP);
  801cac:	83 ec 08             	sub    $0x8,%esp
  801caf:	68 00 00 40 00       	push   $0x400000
  801cb4:	6a 00                	push   $0x0
  801cb6:	e8 82 f0 ff ff       	call   800d3d <sys_page_unmap>
  801cbb:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801cbe:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801cc4:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801cca:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801cd0:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801cd6:	0f 87 f7 fe ff ff    	ja     801bd3 <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801cdc:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801ce3:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801cea:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801cf1:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801cf7:	0f 8c 65 fe ff ff    	jl     801b62 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801cfd:	83 ec 0c             	sub    $0xc,%esp
  801d00:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d06:	e8 97 f5 ff ff       	call   8012a2 <close>
// Copy the mappings for shared pages into the child address space.
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	envid_t curenvid = sys_getenvid();
  801d0b:	e8 6a ef ff ff       	call   800c7a <sys_getenvid>
  801d10:	89 c6                	mov    %eax,%esi
  801d12:	83 c4 10             	add    $0x10,%esp

	for (int i = 0; i < UTOP; i += PGSIZE) {
  801d15:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d1a:	8b bd 84 fd ff ff    	mov    -0x27c(%ebp),%edi
		if ((uvpd[PDX(i)] & PTE_P) &&
  801d20:	89 d8                	mov    %ebx,%eax
  801d22:	c1 e8 16             	shr    $0x16,%eax
  801d25:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801d2c:	a8 01                	test   $0x1,%al
  801d2e:	74 31                	je     801d61 <spawn+0x454>
			(uvpt[PGNUM(i)] & PTE_P) &&
  801d30:	89 d8                	mov    %ebx,%eax
  801d32:	c1 e8 0c             	shr    $0xc,%eax
  801d35:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
{
	// LAB 5: Your code here.
	envid_t curenvid = sys_getenvid();

	for (int i = 0; i < UTOP; i += PGSIZE) {
		if ((uvpd[PDX(i)] & PTE_P) &&
  801d3c:	f6 c2 01             	test   $0x1,%dl
  801d3f:	74 20                	je     801d61 <spawn+0x454>
			(uvpt[PGNUM(i)] & PTE_P) &&
			(uvpt[PGNUM(i)] & PTE_SHARE))
  801d41:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// LAB 5: Your code here.
	envid_t curenvid = sys_getenvid();

	for (int i = 0; i < UTOP; i += PGSIZE) {
		if ((uvpd[PDX(i)] & PTE_P) &&
			(uvpt[PGNUM(i)] & PTE_P) &&
  801d48:	f6 c4 04             	test   $0x4,%ah
  801d4b:	74 14                	je     801d61 <spawn+0x454>
			(uvpt[PGNUM(i)] & PTE_SHARE))
			sys_page_map(curenvid, (void *)i,
  801d4d:	83 ec 0c             	sub    $0xc,%esp
  801d50:	68 07 0e 00 00       	push   $0xe07
  801d55:	53                   	push   %ebx
  801d56:	57                   	push   %edi
  801d57:	53                   	push   %ebx
  801d58:	56                   	push   %esi
  801d59:	e8 9d ef ff ff       	call   800cfb <sys_page_map>
  801d5e:	83 c4 20             	add    $0x20,%esp
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	envid_t curenvid = sys_getenvid();

	for (int i = 0; i < UTOP; i += PGSIZE) {
  801d61:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801d67:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801d6d:	75 b1                	jne    801d20 <spawn+0x413>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801d6f:	83 ec 08             	sub    $0x8,%esp
  801d72:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801d78:	50                   	push   %eax
  801d79:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801d7f:	e8 3d f0 ff ff       	call   800dc1 <sys_env_set_trapframe>
  801d84:	83 c4 10             	add    $0x10,%esp
  801d87:	85 c0                	test   %eax,%eax
  801d89:	79 15                	jns    801da0 <spawn+0x493>
		panic("sys_env_set_trapframe: %e", r);
  801d8b:	50                   	push   %eax
  801d8c:	68 96 2d 80 00       	push   $0x802d96
  801d91:	68 85 00 00 00       	push   $0x85
  801d96:	68 6d 2d 80 00       	push   $0x802d6d
  801d9b:	e8 38 e4 ff ff       	call   8001d8 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801da0:	83 ec 08             	sub    $0x8,%esp
  801da3:	6a 02                	push   $0x2
  801da5:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801dab:	e8 cf ef ff ff       	call   800d7f <sys_env_set_status>
  801db0:	83 c4 10             	add    $0x10,%esp
  801db3:	85 c0                	test   %eax,%eax
  801db5:	79 25                	jns    801ddc <spawn+0x4cf>
		panic("sys_env_set_status: %e", r);
  801db7:	50                   	push   %eax
  801db8:	68 b0 2d 80 00       	push   $0x802db0
  801dbd:	68 88 00 00 00       	push   $0x88
  801dc2:	68 6d 2d 80 00       	push   $0x802d6d
  801dc7:	e8 0c e4 ff ff       	call   8001d8 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801dcc:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801dd2:	eb 58                	jmp    801e2c <spawn+0x51f>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801dd4:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801dda:	eb 50                	jmp    801e2c <spawn+0x51f>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801ddc:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801de2:	eb 48                	jmp    801e2c <spawn+0x51f>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801de4:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801de9:	eb 41                	jmp    801e2c <spawn+0x51f>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801deb:	89 c3                	mov    %eax,%ebx
  801ded:	eb 3d                	jmp    801e2c <spawn+0x51f>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801def:	89 c3                	mov    %eax,%ebx
  801df1:	eb 06                	jmp    801df9 <spawn+0x4ec>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801df3:	89 c3                	mov    %eax,%ebx
  801df5:	eb 02                	jmp    801df9 <spawn+0x4ec>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801df7:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801df9:	83 ec 0c             	sub    $0xc,%esp
  801dfc:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e02:	e8 32 ee ff ff       	call   800c39 <sys_env_destroy>
	close(fd);
  801e07:	83 c4 04             	add    $0x4,%esp
  801e0a:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801e10:	e8 8d f4 ff ff       	call   8012a2 <close>
	return r;
  801e15:	83 c4 10             	add    $0x10,%esp
  801e18:	eb 12                	jmp    801e2c <spawn+0x51f>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801e1a:	83 ec 08             	sub    $0x8,%esp
  801e1d:	68 00 00 40 00       	push   $0x400000
  801e22:	6a 00                	push   $0x0
  801e24:	e8 14 ef ff ff       	call   800d3d <sys_page_unmap>
  801e29:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801e2c:	89 d8                	mov    %ebx,%eax
  801e2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e31:	5b                   	pop    %ebx
  801e32:	5e                   	pop    %esi
  801e33:	5f                   	pop    %edi
  801e34:	5d                   	pop    %ebp
  801e35:	c3                   	ret    

00801e36 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801e36:	55                   	push   %ebp
  801e37:	89 e5                	mov    %esp,%ebp
  801e39:	56                   	push   %esi
  801e3a:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e3b:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801e3e:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e43:	eb 03                	jmp    801e48 <spawnl+0x12>
		argc++;
  801e45:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801e48:	83 c2 04             	add    $0x4,%edx
  801e4b:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801e4f:	75 f4                	jne    801e45 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801e51:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801e58:	83 e2 f0             	and    $0xfffffff0,%edx
  801e5b:	29 d4                	sub    %edx,%esp
  801e5d:	8d 54 24 03          	lea    0x3(%esp),%edx
  801e61:	c1 ea 02             	shr    $0x2,%edx
  801e64:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801e6b:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801e6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e70:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801e77:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801e7e:	00 
  801e7f:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801e81:	b8 00 00 00 00       	mov    $0x0,%eax
  801e86:	eb 0a                	jmp    801e92 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801e88:	83 c0 01             	add    $0x1,%eax
  801e8b:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801e8f:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801e92:	39 d0                	cmp    %edx,%eax
  801e94:	75 f2                	jne    801e88 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801e96:	83 ec 08             	sub    $0x8,%esp
  801e99:	56                   	push   %esi
  801e9a:	ff 75 08             	pushl  0x8(%ebp)
  801e9d:	e8 6b fa ff ff       	call   80190d <spawn>
}
  801ea2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ea5:	5b                   	pop    %ebx
  801ea6:	5e                   	pop    %esi
  801ea7:	5d                   	pop    %ebp
  801ea8:	c3                   	ret    

00801ea9 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ea9:	55                   	push   %ebp
  801eaa:	89 e5                	mov    %esp,%ebp
  801eac:	56                   	push   %esi
  801ead:	53                   	push   %ebx
  801eae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801eb1:	83 ec 0c             	sub    $0xc,%esp
  801eb4:	ff 75 08             	pushl  0x8(%ebp)
  801eb7:	e8 56 f2 ff ff       	call   801112 <fd2data>
  801ebc:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ebe:	83 c4 08             	add    $0x8,%esp
  801ec1:	68 f0 2d 80 00       	push   $0x802df0
  801ec6:	53                   	push   %ebx
  801ec7:	e8 e9 e9 ff ff       	call   8008b5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ecc:	8b 46 04             	mov    0x4(%esi),%eax
  801ecf:	2b 06                	sub    (%esi),%eax
  801ed1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ed7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ede:	00 00 00 
	stat->st_dev = &devpipe;
  801ee1:	c7 83 88 00 00 00 28 	movl   $0x803028,0x88(%ebx)
  801ee8:	30 80 00 
	return 0;
}
  801eeb:	b8 00 00 00 00       	mov    $0x0,%eax
  801ef0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ef3:	5b                   	pop    %ebx
  801ef4:	5e                   	pop    %esi
  801ef5:	5d                   	pop    %ebp
  801ef6:	c3                   	ret    

00801ef7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ef7:	55                   	push   %ebp
  801ef8:	89 e5                	mov    %esp,%ebp
  801efa:	53                   	push   %ebx
  801efb:	83 ec 0c             	sub    $0xc,%esp
  801efe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f01:	53                   	push   %ebx
  801f02:	6a 00                	push   $0x0
  801f04:	e8 34 ee ff ff       	call   800d3d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f09:	89 1c 24             	mov    %ebx,(%esp)
  801f0c:	e8 01 f2 ff ff       	call   801112 <fd2data>
  801f11:	83 c4 08             	add    $0x8,%esp
  801f14:	50                   	push   %eax
  801f15:	6a 00                	push   $0x0
  801f17:	e8 21 ee ff ff       	call   800d3d <sys_page_unmap>
}
  801f1c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f1f:	c9                   	leave  
  801f20:	c3                   	ret    

00801f21 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801f21:	55                   	push   %ebp
  801f22:	89 e5                	mov    %esp,%ebp
  801f24:	57                   	push   %edi
  801f25:	56                   	push   %esi
  801f26:	53                   	push   %ebx
  801f27:	83 ec 1c             	sub    $0x1c,%esp
  801f2a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801f2d:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801f2f:	a1 04 40 80 00       	mov    0x804004,%eax
  801f34:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801f37:	83 ec 0c             	sub    $0xc,%esp
  801f3a:	ff 75 e0             	pushl  -0x20(%ebp)
  801f3d:	e8 ff 05 00 00       	call   802541 <pageref>
  801f42:	89 c3                	mov    %eax,%ebx
  801f44:	89 3c 24             	mov    %edi,(%esp)
  801f47:	e8 f5 05 00 00       	call   802541 <pageref>
  801f4c:	83 c4 10             	add    $0x10,%esp
  801f4f:	39 c3                	cmp    %eax,%ebx
  801f51:	0f 94 c1             	sete   %cl
  801f54:	0f b6 c9             	movzbl %cl,%ecx
  801f57:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801f5a:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801f60:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f63:	39 ce                	cmp    %ecx,%esi
  801f65:	74 1b                	je     801f82 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801f67:	39 c3                	cmp    %eax,%ebx
  801f69:	75 c4                	jne    801f2f <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f6b:	8b 42 58             	mov    0x58(%edx),%eax
  801f6e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801f71:	50                   	push   %eax
  801f72:	56                   	push   %esi
  801f73:	68 f7 2d 80 00       	push   $0x802df7
  801f78:	e8 34 e3 ff ff       	call   8002b1 <cprintf>
  801f7d:	83 c4 10             	add    $0x10,%esp
  801f80:	eb ad                	jmp    801f2f <_pipeisclosed+0xe>
	}
}
  801f82:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f88:	5b                   	pop    %ebx
  801f89:	5e                   	pop    %esi
  801f8a:	5f                   	pop    %edi
  801f8b:	5d                   	pop    %ebp
  801f8c:	c3                   	ret    

00801f8d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f8d:	55                   	push   %ebp
  801f8e:	89 e5                	mov    %esp,%ebp
  801f90:	57                   	push   %edi
  801f91:	56                   	push   %esi
  801f92:	53                   	push   %ebx
  801f93:	83 ec 28             	sub    $0x28,%esp
  801f96:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f99:	56                   	push   %esi
  801f9a:	e8 73 f1 ff ff       	call   801112 <fd2data>
  801f9f:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fa1:	83 c4 10             	add    $0x10,%esp
  801fa4:	bf 00 00 00 00       	mov    $0x0,%edi
  801fa9:	eb 4b                	jmp    801ff6 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801fab:	89 da                	mov    %ebx,%edx
  801fad:	89 f0                	mov    %esi,%eax
  801faf:	e8 6d ff ff ff       	call   801f21 <_pipeisclosed>
  801fb4:	85 c0                	test   %eax,%eax
  801fb6:	75 48                	jne    802000 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801fb8:	e8 dc ec ff ff       	call   800c99 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801fbd:	8b 43 04             	mov    0x4(%ebx),%eax
  801fc0:	8b 0b                	mov    (%ebx),%ecx
  801fc2:	8d 51 20             	lea    0x20(%ecx),%edx
  801fc5:	39 d0                	cmp    %edx,%eax
  801fc7:	73 e2                	jae    801fab <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801fc9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fcc:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801fd0:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801fd3:	89 c2                	mov    %eax,%edx
  801fd5:	c1 fa 1f             	sar    $0x1f,%edx
  801fd8:	89 d1                	mov    %edx,%ecx
  801fda:	c1 e9 1b             	shr    $0x1b,%ecx
  801fdd:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801fe0:	83 e2 1f             	and    $0x1f,%edx
  801fe3:	29 ca                	sub    %ecx,%edx
  801fe5:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801fe9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801fed:	83 c0 01             	add    $0x1,%eax
  801ff0:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ff3:	83 c7 01             	add    $0x1,%edi
  801ff6:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ff9:	75 c2                	jne    801fbd <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ffb:	8b 45 10             	mov    0x10(%ebp),%eax
  801ffe:	eb 05                	jmp    802005 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802000:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802005:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802008:	5b                   	pop    %ebx
  802009:	5e                   	pop    %esi
  80200a:	5f                   	pop    %edi
  80200b:	5d                   	pop    %ebp
  80200c:	c3                   	ret    

0080200d <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80200d:	55                   	push   %ebp
  80200e:	89 e5                	mov    %esp,%ebp
  802010:	57                   	push   %edi
  802011:	56                   	push   %esi
  802012:	53                   	push   %ebx
  802013:	83 ec 18             	sub    $0x18,%esp
  802016:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802019:	57                   	push   %edi
  80201a:	e8 f3 f0 ff ff       	call   801112 <fd2data>
  80201f:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802021:	83 c4 10             	add    $0x10,%esp
  802024:	bb 00 00 00 00       	mov    $0x0,%ebx
  802029:	eb 3d                	jmp    802068 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80202b:	85 db                	test   %ebx,%ebx
  80202d:	74 04                	je     802033 <devpipe_read+0x26>
				return i;
  80202f:	89 d8                	mov    %ebx,%eax
  802031:	eb 44                	jmp    802077 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802033:	89 f2                	mov    %esi,%edx
  802035:	89 f8                	mov    %edi,%eax
  802037:	e8 e5 fe ff ff       	call   801f21 <_pipeisclosed>
  80203c:	85 c0                	test   %eax,%eax
  80203e:	75 32                	jne    802072 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802040:	e8 54 ec ff ff       	call   800c99 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802045:	8b 06                	mov    (%esi),%eax
  802047:	3b 46 04             	cmp    0x4(%esi),%eax
  80204a:	74 df                	je     80202b <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80204c:	99                   	cltd   
  80204d:	c1 ea 1b             	shr    $0x1b,%edx
  802050:	01 d0                	add    %edx,%eax
  802052:	83 e0 1f             	and    $0x1f,%eax
  802055:	29 d0                	sub    %edx,%eax
  802057:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80205c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80205f:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802062:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802065:	83 c3 01             	add    $0x1,%ebx
  802068:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80206b:	75 d8                	jne    802045 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80206d:	8b 45 10             	mov    0x10(%ebp),%eax
  802070:	eb 05                	jmp    802077 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802072:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802077:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80207a:	5b                   	pop    %ebx
  80207b:	5e                   	pop    %esi
  80207c:	5f                   	pop    %edi
  80207d:	5d                   	pop    %ebp
  80207e:	c3                   	ret    

0080207f <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80207f:	55                   	push   %ebp
  802080:	89 e5                	mov    %esp,%ebp
  802082:	56                   	push   %esi
  802083:	53                   	push   %ebx
  802084:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802087:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80208a:	50                   	push   %eax
  80208b:	e8 99 f0 ff ff       	call   801129 <fd_alloc>
  802090:	83 c4 10             	add    $0x10,%esp
  802093:	89 c2                	mov    %eax,%edx
  802095:	85 c0                	test   %eax,%eax
  802097:	0f 88 2c 01 00 00    	js     8021c9 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80209d:	83 ec 04             	sub    $0x4,%esp
  8020a0:	68 07 04 00 00       	push   $0x407
  8020a5:	ff 75 f4             	pushl  -0xc(%ebp)
  8020a8:	6a 00                	push   $0x0
  8020aa:	e8 09 ec ff ff       	call   800cb8 <sys_page_alloc>
  8020af:	83 c4 10             	add    $0x10,%esp
  8020b2:	89 c2                	mov    %eax,%edx
  8020b4:	85 c0                	test   %eax,%eax
  8020b6:	0f 88 0d 01 00 00    	js     8021c9 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8020bc:	83 ec 0c             	sub    $0xc,%esp
  8020bf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020c2:	50                   	push   %eax
  8020c3:	e8 61 f0 ff ff       	call   801129 <fd_alloc>
  8020c8:	89 c3                	mov    %eax,%ebx
  8020ca:	83 c4 10             	add    $0x10,%esp
  8020cd:	85 c0                	test   %eax,%eax
  8020cf:	0f 88 e2 00 00 00    	js     8021b7 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020d5:	83 ec 04             	sub    $0x4,%esp
  8020d8:	68 07 04 00 00       	push   $0x407
  8020dd:	ff 75 f0             	pushl  -0x10(%ebp)
  8020e0:	6a 00                	push   $0x0
  8020e2:	e8 d1 eb ff ff       	call   800cb8 <sys_page_alloc>
  8020e7:	89 c3                	mov    %eax,%ebx
  8020e9:	83 c4 10             	add    $0x10,%esp
  8020ec:	85 c0                	test   %eax,%eax
  8020ee:	0f 88 c3 00 00 00    	js     8021b7 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8020f4:	83 ec 0c             	sub    $0xc,%esp
  8020f7:	ff 75 f4             	pushl  -0xc(%ebp)
  8020fa:	e8 13 f0 ff ff       	call   801112 <fd2data>
  8020ff:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802101:	83 c4 0c             	add    $0xc,%esp
  802104:	68 07 04 00 00       	push   $0x407
  802109:	50                   	push   %eax
  80210a:	6a 00                	push   $0x0
  80210c:	e8 a7 eb ff ff       	call   800cb8 <sys_page_alloc>
  802111:	89 c3                	mov    %eax,%ebx
  802113:	83 c4 10             	add    $0x10,%esp
  802116:	85 c0                	test   %eax,%eax
  802118:	0f 88 89 00 00 00    	js     8021a7 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80211e:	83 ec 0c             	sub    $0xc,%esp
  802121:	ff 75 f0             	pushl  -0x10(%ebp)
  802124:	e8 e9 ef ff ff       	call   801112 <fd2data>
  802129:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802130:	50                   	push   %eax
  802131:	6a 00                	push   $0x0
  802133:	56                   	push   %esi
  802134:	6a 00                	push   $0x0
  802136:	e8 c0 eb ff ff       	call   800cfb <sys_page_map>
  80213b:	89 c3                	mov    %eax,%ebx
  80213d:	83 c4 20             	add    $0x20,%esp
  802140:	85 c0                	test   %eax,%eax
  802142:	78 55                	js     802199 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802144:	8b 15 28 30 80 00    	mov    0x803028,%edx
  80214a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80214d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80214f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802152:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802159:	8b 15 28 30 80 00    	mov    0x803028,%edx
  80215f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802162:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802164:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802167:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80216e:	83 ec 0c             	sub    $0xc,%esp
  802171:	ff 75 f4             	pushl  -0xc(%ebp)
  802174:	e8 89 ef ff ff       	call   801102 <fd2num>
  802179:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80217c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80217e:	83 c4 04             	add    $0x4,%esp
  802181:	ff 75 f0             	pushl  -0x10(%ebp)
  802184:	e8 79 ef ff ff       	call   801102 <fd2num>
  802189:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80218c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80218f:	83 c4 10             	add    $0x10,%esp
  802192:	ba 00 00 00 00       	mov    $0x0,%edx
  802197:	eb 30                	jmp    8021c9 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802199:	83 ec 08             	sub    $0x8,%esp
  80219c:	56                   	push   %esi
  80219d:	6a 00                	push   $0x0
  80219f:	e8 99 eb ff ff       	call   800d3d <sys_page_unmap>
  8021a4:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8021a7:	83 ec 08             	sub    $0x8,%esp
  8021aa:	ff 75 f0             	pushl  -0x10(%ebp)
  8021ad:	6a 00                	push   $0x0
  8021af:	e8 89 eb ff ff       	call   800d3d <sys_page_unmap>
  8021b4:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8021b7:	83 ec 08             	sub    $0x8,%esp
  8021ba:	ff 75 f4             	pushl  -0xc(%ebp)
  8021bd:	6a 00                	push   $0x0
  8021bf:	e8 79 eb ff ff       	call   800d3d <sys_page_unmap>
  8021c4:	83 c4 10             	add    $0x10,%esp
  8021c7:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8021c9:	89 d0                	mov    %edx,%eax
  8021cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021ce:	5b                   	pop    %ebx
  8021cf:	5e                   	pop    %esi
  8021d0:	5d                   	pop    %ebp
  8021d1:	c3                   	ret    

008021d2 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8021d2:	55                   	push   %ebp
  8021d3:	89 e5                	mov    %esp,%ebp
  8021d5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021db:	50                   	push   %eax
  8021dc:	ff 75 08             	pushl  0x8(%ebp)
  8021df:	e8 94 ef ff ff       	call   801178 <fd_lookup>
  8021e4:	83 c4 10             	add    $0x10,%esp
  8021e7:	85 c0                	test   %eax,%eax
  8021e9:	78 18                	js     802203 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8021eb:	83 ec 0c             	sub    $0xc,%esp
  8021ee:	ff 75 f4             	pushl  -0xc(%ebp)
  8021f1:	e8 1c ef ff ff       	call   801112 <fd2data>
	return _pipeisclosed(fd, p);
  8021f6:	89 c2                	mov    %eax,%edx
  8021f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021fb:	e8 21 fd ff ff       	call   801f21 <_pipeisclosed>
  802200:	83 c4 10             	add    $0x10,%esp
}
  802203:	c9                   	leave  
  802204:	c3                   	ret    

00802205 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802205:	55                   	push   %ebp
  802206:	89 e5                	mov    %esp,%ebp
  802208:	56                   	push   %esi
  802209:	53                   	push   %ebx
  80220a:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  80220d:	85 f6                	test   %esi,%esi
  80220f:	75 16                	jne    802227 <wait+0x22>
  802211:	68 0f 2e 80 00       	push   $0x802e0f
  802216:	68 27 2d 80 00       	push   $0x802d27
  80221b:	6a 09                	push   $0x9
  80221d:	68 1a 2e 80 00       	push   $0x802e1a
  802222:	e8 b1 df ff ff       	call   8001d8 <_panic>
	e = &envs[ENVX(envid)];
  802227:	89 f3                	mov    %esi,%ebx
  802229:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80222f:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802232:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802238:	eb 05                	jmp    80223f <wait+0x3a>
		sys_yield();
  80223a:	e8 5a ea ff ff       	call   800c99 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80223f:	8b 43 48             	mov    0x48(%ebx),%eax
  802242:	39 c6                	cmp    %eax,%esi
  802244:	75 07                	jne    80224d <wait+0x48>
  802246:	8b 43 54             	mov    0x54(%ebx),%eax
  802249:	85 c0                	test   %eax,%eax
  80224b:	75 ed                	jne    80223a <wait+0x35>
		sys_yield();
}
  80224d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802250:	5b                   	pop    %ebx
  802251:	5e                   	pop    %esi
  802252:	5d                   	pop    %ebp
  802253:	c3                   	ret    

00802254 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802254:	55                   	push   %ebp
  802255:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802257:	b8 00 00 00 00       	mov    $0x0,%eax
  80225c:	5d                   	pop    %ebp
  80225d:	c3                   	ret    

0080225e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80225e:	55                   	push   %ebp
  80225f:	89 e5                	mov    %esp,%ebp
  802261:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802264:	68 25 2e 80 00       	push   $0x802e25
  802269:	ff 75 0c             	pushl  0xc(%ebp)
  80226c:	e8 44 e6 ff ff       	call   8008b5 <strcpy>
	return 0;
}
  802271:	b8 00 00 00 00       	mov    $0x0,%eax
  802276:	c9                   	leave  
  802277:	c3                   	ret    

00802278 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802278:	55                   	push   %ebp
  802279:	89 e5                	mov    %esp,%ebp
  80227b:	57                   	push   %edi
  80227c:	56                   	push   %esi
  80227d:	53                   	push   %ebx
  80227e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802284:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802289:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80228f:	eb 2d                	jmp    8022be <devcons_write+0x46>
		m = n - tot;
  802291:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802294:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802296:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802299:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80229e:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8022a1:	83 ec 04             	sub    $0x4,%esp
  8022a4:	53                   	push   %ebx
  8022a5:	03 45 0c             	add    0xc(%ebp),%eax
  8022a8:	50                   	push   %eax
  8022a9:	57                   	push   %edi
  8022aa:	e8 98 e7 ff ff       	call   800a47 <memmove>
		sys_cputs(buf, m);
  8022af:	83 c4 08             	add    $0x8,%esp
  8022b2:	53                   	push   %ebx
  8022b3:	57                   	push   %edi
  8022b4:	e8 43 e9 ff ff       	call   800bfc <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022b9:	01 de                	add    %ebx,%esi
  8022bb:	83 c4 10             	add    $0x10,%esp
  8022be:	89 f0                	mov    %esi,%eax
  8022c0:	3b 75 10             	cmp    0x10(%ebp),%esi
  8022c3:	72 cc                	jb     802291 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8022c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022c8:	5b                   	pop    %ebx
  8022c9:	5e                   	pop    %esi
  8022ca:	5f                   	pop    %edi
  8022cb:	5d                   	pop    %ebp
  8022cc:	c3                   	ret    

008022cd <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8022cd:	55                   	push   %ebp
  8022ce:	89 e5                	mov    %esp,%ebp
  8022d0:	83 ec 08             	sub    $0x8,%esp
  8022d3:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8022d8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8022dc:	74 2a                	je     802308 <devcons_read+0x3b>
  8022de:	eb 05                	jmp    8022e5 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8022e0:	e8 b4 e9 ff ff       	call   800c99 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8022e5:	e8 30 e9 ff ff       	call   800c1a <sys_cgetc>
  8022ea:	85 c0                	test   %eax,%eax
  8022ec:	74 f2                	je     8022e0 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8022ee:	85 c0                	test   %eax,%eax
  8022f0:	78 16                	js     802308 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8022f2:	83 f8 04             	cmp    $0x4,%eax
  8022f5:	74 0c                	je     802303 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8022f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022fa:	88 02                	mov    %al,(%edx)
	return 1;
  8022fc:	b8 01 00 00 00       	mov    $0x1,%eax
  802301:	eb 05                	jmp    802308 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802303:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802308:	c9                   	leave  
  802309:	c3                   	ret    

0080230a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80230a:	55                   	push   %ebp
  80230b:	89 e5                	mov    %esp,%ebp
  80230d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802310:	8b 45 08             	mov    0x8(%ebp),%eax
  802313:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802316:	6a 01                	push   $0x1
  802318:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80231b:	50                   	push   %eax
  80231c:	e8 db e8 ff ff       	call   800bfc <sys_cputs>
}
  802321:	83 c4 10             	add    $0x10,%esp
  802324:	c9                   	leave  
  802325:	c3                   	ret    

00802326 <getchar>:

int
getchar(void)
{
  802326:	55                   	push   %ebp
  802327:	89 e5                	mov    %esp,%ebp
  802329:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80232c:	6a 01                	push   $0x1
  80232e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802331:	50                   	push   %eax
  802332:	6a 00                	push   $0x0
  802334:	e8 a5 f0 ff ff       	call   8013de <read>
	if (r < 0)
  802339:	83 c4 10             	add    $0x10,%esp
  80233c:	85 c0                	test   %eax,%eax
  80233e:	78 0f                	js     80234f <getchar+0x29>
		return r;
	if (r < 1)
  802340:	85 c0                	test   %eax,%eax
  802342:	7e 06                	jle    80234a <getchar+0x24>
		return -E_EOF;
	return c;
  802344:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802348:	eb 05                	jmp    80234f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80234a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80234f:	c9                   	leave  
  802350:	c3                   	ret    

00802351 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802351:	55                   	push   %ebp
  802352:	89 e5                	mov    %esp,%ebp
  802354:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802357:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80235a:	50                   	push   %eax
  80235b:	ff 75 08             	pushl  0x8(%ebp)
  80235e:	e8 15 ee ff ff       	call   801178 <fd_lookup>
  802363:	83 c4 10             	add    $0x10,%esp
  802366:	85 c0                	test   %eax,%eax
  802368:	78 11                	js     80237b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80236a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80236d:	8b 15 44 30 80 00    	mov    0x803044,%edx
  802373:	39 10                	cmp    %edx,(%eax)
  802375:	0f 94 c0             	sete   %al
  802378:	0f b6 c0             	movzbl %al,%eax
}
  80237b:	c9                   	leave  
  80237c:	c3                   	ret    

0080237d <opencons>:

int
opencons(void)
{
  80237d:	55                   	push   %ebp
  80237e:	89 e5                	mov    %esp,%ebp
  802380:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802383:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802386:	50                   	push   %eax
  802387:	e8 9d ed ff ff       	call   801129 <fd_alloc>
  80238c:	83 c4 10             	add    $0x10,%esp
		return r;
  80238f:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802391:	85 c0                	test   %eax,%eax
  802393:	78 3e                	js     8023d3 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802395:	83 ec 04             	sub    $0x4,%esp
  802398:	68 07 04 00 00       	push   $0x407
  80239d:	ff 75 f4             	pushl  -0xc(%ebp)
  8023a0:	6a 00                	push   $0x0
  8023a2:	e8 11 e9 ff ff       	call   800cb8 <sys_page_alloc>
  8023a7:	83 c4 10             	add    $0x10,%esp
		return r;
  8023aa:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023ac:	85 c0                	test   %eax,%eax
  8023ae:	78 23                	js     8023d3 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8023b0:	8b 15 44 30 80 00    	mov    0x803044,%edx
  8023b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023b9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8023bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023be:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8023c5:	83 ec 0c             	sub    $0xc,%esp
  8023c8:	50                   	push   %eax
  8023c9:	e8 34 ed ff ff       	call   801102 <fd2num>
  8023ce:	89 c2                	mov    %eax,%edx
  8023d0:	83 c4 10             	add    $0x10,%esp
}
  8023d3:	89 d0                	mov    %edx,%eax
  8023d5:	c9                   	leave  
  8023d6:	c3                   	ret    

008023d7 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8023d7:	55                   	push   %ebp
  8023d8:	89 e5                	mov    %esp,%ebp
  8023da:	53                   	push   %ebx
  8023db:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  8023de:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8023e5:	75 28                	jne    80240f <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		void *va = (void *) (UXSTACKTOP - PGSIZE);
		envid_t envid = sys_getenvid();
  8023e7:	e8 8e e8 ff ff       	call   800c7a <sys_getenvid>
  8023ec:	89 c3                	mov    %eax,%ebx

		sys_page_alloc(envid, va, PTE_P | PTE_U | PTE_W);
  8023ee:	83 ec 04             	sub    $0x4,%esp
  8023f1:	6a 07                	push   $0x7
  8023f3:	68 00 f0 bf ee       	push   $0xeebff000
  8023f8:	50                   	push   %eax
  8023f9:	e8 ba e8 ff ff       	call   800cb8 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8023fe:	83 c4 08             	add    $0x8,%esp
  802401:	68 1c 24 80 00       	push   $0x80241c
  802406:	53                   	push   %ebx
  802407:	e8 f7 e9 ff ff       	call   800e03 <sys_env_set_pgfault_upcall>
  80240c:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80240f:	8b 45 08             	mov    0x8(%ebp),%eax
  802412:	a3 00 60 80 00       	mov    %eax,0x806000
}
  802417:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80241a:	c9                   	leave  
  80241b:	c3                   	ret    

0080241c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp				// function argument: pointer to UTF
  80241c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80241d:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802422:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802424:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp, %ebx		// 40 = size between utf_fault_va ~ utf_regs
  802427:	89 e3                	mov    %esp,%ebx
	movl 40(%esp), %eax // point to utf_eip
  802429:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %esp // point to utf_esp
  80242d:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax 			// push eip of utf
  802431:	50                   	push   %eax

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx, %esp 	// back to origin exception stack
  802432:	89 dc                	mov    %ebx,%esp
	subl $4, 48(%esp) 	// utf_esp - 4
  802434:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	popl %eax  			// pop utf_fault_va (ignore)
  802439:	58                   	pop    %eax
	popl %eax  			// pop utf_err (ignore)
  80243a:	58                   	pop    %eax
	popal 				// pop utf_regs 
  80243b:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4, %esp 		// ignore utf_eip
  80243c:	83 c4 04             	add    $0x4,%esp
	popfl 				// restore utf_eflags to eflags
  80243f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp  			// restore %esp = utf_esp
  802440:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802441:	c3                   	ret    

00802442 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802442:	55                   	push   %ebp
  802443:	89 e5                	mov    %esp,%ebp
  802445:	56                   	push   %esi
  802446:	53                   	push   %ebx
  802447:	8b 75 08             	mov    0x8(%ebp),%esi
  80244a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80244d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

    if (pg != NULL)
  802450:	85 c0                	test   %eax,%eax
  802452:	74 0e                	je     802462 <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  802454:	83 ec 0c             	sub    $0xc,%esp
  802457:	50                   	push   %eax
  802458:	e8 0b ea ff ff       	call   800e68 <sys_ipc_recv>
  80245d:	83 c4 10             	add    $0x10,%esp
  802460:	eb 0d                	jmp    80246f <ipc_recv+0x2d>
	else
        r = sys_ipc_recv((void *)-1);
  802462:	83 ec 0c             	sub    $0xc,%esp
  802465:	6a ff                	push   $0xffffffff
  802467:	e8 fc e9 ff ff       	call   800e68 <sys_ipc_recv>
  80246c:	83 c4 10             	add    $0x10,%esp

	if (r < 0) {
  80246f:	85 c0                	test   %eax,%eax
  802471:	79 16                	jns    802489 <ipc_recv+0x47>

		if (from_env_store != NULL)
  802473:	85 f6                	test   %esi,%esi
  802475:	74 06                	je     80247d <ipc_recv+0x3b>
			*from_env_store = 0;
  802477:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL)
  80247d:	85 db                	test   %ebx,%ebx
  80247f:	74 2c                	je     8024ad <ipc_recv+0x6b>
			*perm_store = 0;
  802481:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802487:	eb 24                	jmp    8024ad <ipc_recv+0x6b>
		return r;

	} else {

		if (from_env_store != NULL)
  802489:	85 f6                	test   %esi,%esi
  80248b:	74 0a                	je     802497 <ipc_recv+0x55>
			*from_env_store = thisenv->env_ipc_from;
  80248d:	a1 04 40 80 00       	mov    0x804004,%eax
  802492:	8b 40 74             	mov    0x74(%eax),%eax
  802495:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL)
  802497:	85 db                	test   %ebx,%ebx
  802499:	74 0a                	je     8024a5 <ipc_recv+0x63>
			*perm_store = thisenv->env_ipc_perm;
  80249b:	a1 04 40 80 00       	mov    0x804004,%eax
  8024a0:	8b 40 78             	mov    0x78(%eax),%eax
  8024a3:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  8024a5:	a1 04 40 80 00       	mov    0x804004,%eax
  8024aa:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  8024ad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8024b0:	5b                   	pop    %ebx
  8024b1:	5e                   	pop    %esi
  8024b2:	5d                   	pop    %ebp
  8024b3:	c3                   	ret    

008024b4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8024b4:	55                   	push   %ebp
  8024b5:	89 e5                	mov    %esp,%ebp
  8024b7:	57                   	push   %edi
  8024b8:	56                   	push   %esi
  8024b9:	53                   	push   %ebx
  8024ba:	83 ec 0c             	sub    $0xc,%esp
  8024bd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8024c0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8024c3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

	if (pg == NULL)
  8024c6:	85 db                	test   %ebx,%ebx
		pg = (void *)-1;	
  8024c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8024cd:	0f 44 d8             	cmove  %eax,%ebx

	while (true) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8024d0:	ff 75 14             	pushl  0x14(%ebp)
  8024d3:	53                   	push   %ebx
  8024d4:	56                   	push   %esi
  8024d5:	57                   	push   %edi
  8024d6:	e8 6a e9 ff ff       	call   800e45 <sys_ipc_try_send>
		if (r >= 0)
  8024db:	83 c4 10             	add    $0x10,%esp
  8024de:	85 c0                	test   %eax,%eax
  8024e0:	79 1e                	jns    802500 <ipc_send+0x4c>
			return;
		else if (r != -E_IPC_NOT_RECV)
  8024e2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8024e5:	74 12                	je     8024f9 <ipc_send+0x45>
			panic("ipc_send error: %e", r);
  8024e7:	50                   	push   %eax
  8024e8:	68 31 2e 80 00       	push   $0x802e31
  8024ed:	6a 49                	push   $0x49
  8024ef:	68 44 2e 80 00       	push   $0x802e44
  8024f4:	e8 df dc ff ff       	call   8001d8 <_panic>
	
		sys_yield();
  8024f9:	e8 9b e7 ff ff       	call   800c99 <sys_yield>
	}
  8024fe:	eb d0                	jmp    8024d0 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  802500:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802503:	5b                   	pop    %ebx
  802504:	5e                   	pop    %esi
  802505:	5f                   	pop    %edi
  802506:	5d                   	pop    %ebp
  802507:	c3                   	ret    

00802508 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802508:	55                   	push   %ebp
  802509:	89 e5                	mov    %esp,%ebp
  80250b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80250e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802513:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802516:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80251c:	8b 52 50             	mov    0x50(%edx),%edx
  80251f:	39 ca                	cmp    %ecx,%edx
  802521:	75 0d                	jne    802530 <ipc_find_env+0x28>
			return envs[i].env_id;
  802523:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802526:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80252b:	8b 40 48             	mov    0x48(%eax),%eax
  80252e:	eb 0f                	jmp    80253f <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802530:	83 c0 01             	add    $0x1,%eax
  802533:	3d 00 04 00 00       	cmp    $0x400,%eax
  802538:	75 d9                	jne    802513 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80253a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80253f:	5d                   	pop    %ebp
  802540:	c3                   	ret    

00802541 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802541:	55                   	push   %ebp
  802542:	89 e5                	mov    %esp,%ebp
  802544:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802547:	89 d0                	mov    %edx,%eax
  802549:	c1 e8 16             	shr    $0x16,%eax
  80254c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802553:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802558:	f6 c1 01             	test   $0x1,%cl
  80255b:	74 1d                	je     80257a <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80255d:	c1 ea 0c             	shr    $0xc,%edx
  802560:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802567:	f6 c2 01             	test   $0x1,%dl
  80256a:	74 0e                	je     80257a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80256c:	c1 ea 0c             	shr    $0xc,%edx
  80256f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802576:	ef 
  802577:	0f b7 c0             	movzwl %ax,%eax
}
  80257a:	5d                   	pop    %ebp
  80257b:	c3                   	ret    
  80257c:	66 90                	xchg   %ax,%ax
  80257e:	66 90                	xchg   %ax,%ax

00802580 <__udivdi3>:
  802580:	55                   	push   %ebp
  802581:	57                   	push   %edi
  802582:	56                   	push   %esi
  802583:	53                   	push   %ebx
  802584:	83 ec 1c             	sub    $0x1c,%esp
  802587:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80258b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80258f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802593:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802597:	85 f6                	test   %esi,%esi
  802599:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80259d:	89 ca                	mov    %ecx,%edx
  80259f:	89 f8                	mov    %edi,%eax
  8025a1:	75 3d                	jne    8025e0 <__udivdi3+0x60>
  8025a3:	39 cf                	cmp    %ecx,%edi
  8025a5:	0f 87 c5 00 00 00    	ja     802670 <__udivdi3+0xf0>
  8025ab:	85 ff                	test   %edi,%edi
  8025ad:	89 fd                	mov    %edi,%ebp
  8025af:	75 0b                	jne    8025bc <__udivdi3+0x3c>
  8025b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8025b6:	31 d2                	xor    %edx,%edx
  8025b8:	f7 f7                	div    %edi
  8025ba:	89 c5                	mov    %eax,%ebp
  8025bc:	89 c8                	mov    %ecx,%eax
  8025be:	31 d2                	xor    %edx,%edx
  8025c0:	f7 f5                	div    %ebp
  8025c2:	89 c1                	mov    %eax,%ecx
  8025c4:	89 d8                	mov    %ebx,%eax
  8025c6:	89 cf                	mov    %ecx,%edi
  8025c8:	f7 f5                	div    %ebp
  8025ca:	89 c3                	mov    %eax,%ebx
  8025cc:	89 d8                	mov    %ebx,%eax
  8025ce:	89 fa                	mov    %edi,%edx
  8025d0:	83 c4 1c             	add    $0x1c,%esp
  8025d3:	5b                   	pop    %ebx
  8025d4:	5e                   	pop    %esi
  8025d5:	5f                   	pop    %edi
  8025d6:	5d                   	pop    %ebp
  8025d7:	c3                   	ret    
  8025d8:	90                   	nop
  8025d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025e0:	39 ce                	cmp    %ecx,%esi
  8025e2:	77 74                	ja     802658 <__udivdi3+0xd8>
  8025e4:	0f bd fe             	bsr    %esi,%edi
  8025e7:	83 f7 1f             	xor    $0x1f,%edi
  8025ea:	0f 84 98 00 00 00    	je     802688 <__udivdi3+0x108>
  8025f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8025f5:	89 f9                	mov    %edi,%ecx
  8025f7:	89 c5                	mov    %eax,%ebp
  8025f9:	29 fb                	sub    %edi,%ebx
  8025fb:	d3 e6                	shl    %cl,%esi
  8025fd:	89 d9                	mov    %ebx,%ecx
  8025ff:	d3 ed                	shr    %cl,%ebp
  802601:	89 f9                	mov    %edi,%ecx
  802603:	d3 e0                	shl    %cl,%eax
  802605:	09 ee                	or     %ebp,%esi
  802607:	89 d9                	mov    %ebx,%ecx
  802609:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80260d:	89 d5                	mov    %edx,%ebp
  80260f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802613:	d3 ed                	shr    %cl,%ebp
  802615:	89 f9                	mov    %edi,%ecx
  802617:	d3 e2                	shl    %cl,%edx
  802619:	89 d9                	mov    %ebx,%ecx
  80261b:	d3 e8                	shr    %cl,%eax
  80261d:	09 c2                	or     %eax,%edx
  80261f:	89 d0                	mov    %edx,%eax
  802621:	89 ea                	mov    %ebp,%edx
  802623:	f7 f6                	div    %esi
  802625:	89 d5                	mov    %edx,%ebp
  802627:	89 c3                	mov    %eax,%ebx
  802629:	f7 64 24 0c          	mull   0xc(%esp)
  80262d:	39 d5                	cmp    %edx,%ebp
  80262f:	72 10                	jb     802641 <__udivdi3+0xc1>
  802631:	8b 74 24 08          	mov    0x8(%esp),%esi
  802635:	89 f9                	mov    %edi,%ecx
  802637:	d3 e6                	shl    %cl,%esi
  802639:	39 c6                	cmp    %eax,%esi
  80263b:	73 07                	jae    802644 <__udivdi3+0xc4>
  80263d:	39 d5                	cmp    %edx,%ebp
  80263f:	75 03                	jne    802644 <__udivdi3+0xc4>
  802641:	83 eb 01             	sub    $0x1,%ebx
  802644:	31 ff                	xor    %edi,%edi
  802646:	89 d8                	mov    %ebx,%eax
  802648:	89 fa                	mov    %edi,%edx
  80264a:	83 c4 1c             	add    $0x1c,%esp
  80264d:	5b                   	pop    %ebx
  80264e:	5e                   	pop    %esi
  80264f:	5f                   	pop    %edi
  802650:	5d                   	pop    %ebp
  802651:	c3                   	ret    
  802652:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802658:	31 ff                	xor    %edi,%edi
  80265a:	31 db                	xor    %ebx,%ebx
  80265c:	89 d8                	mov    %ebx,%eax
  80265e:	89 fa                	mov    %edi,%edx
  802660:	83 c4 1c             	add    $0x1c,%esp
  802663:	5b                   	pop    %ebx
  802664:	5e                   	pop    %esi
  802665:	5f                   	pop    %edi
  802666:	5d                   	pop    %ebp
  802667:	c3                   	ret    
  802668:	90                   	nop
  802669:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802670:	89 d8                	mov    %ebx,%eax
  802672:	f7 f7                	div    %edi
  802674:	31 ff                	xor    %edi,%edi
  802676:	89 c3                	mov    %eax,%ebx
  802678:	89 d8                	mov    %ebx,%eax
  80267a:	89 fa                	mov    %edi,%edx
  80267c:	83 c4 1c             	add    $0x1c,%esp
  80267f:	5b                   	pop    %ebx
  802680:	5e                   	pop    %esi
  802681:	5f                   	pop    %edi
  802682:	5d                   	pop    %ebp
  802683:	c3                   	ret    
  802684:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802688:	39 ce                	cmp    %ecx,%esi
  80268a:	72 0c                	jb     802698 <__udivdi3+0x118>
  80268c:	31 db                	xor    %ebx,%ebx
  80268e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802692:	0f 87 34 ff ff ff    	ja     8025cc <__udivdi3+0x4c>
  802698:	bb 01 00 00 00       	mov    $0x1,%ebx
  80269d:	e9 2a ff ff ff       	jmp    8025cc <__udivdi3+0x4c>
  8026a2:	66 90                	xchg   %ax,%ax
  8026a4:	66 90                	xchg   %ax,%ax
  8026a6:	66 90                	xchg   %ax,%ax
  8026a8:	66 90                	xchg   %ax,%ax
  8026aa:	66 90                	xchg   %ax,%ax
  8026ac:	66 90                	xchg   %ax,%ax
  8026ae:	66 90                	xchg   %ax,%ax

008026b0 <__umoddi3>:
  8026b0:	55                   	push   %ebp
  8026b1:	57                   	push   %edi
  8026b2:	56                   	push   %esi
  8026b3:	53                   	push   %ebx
  8026b4:	83 ec 1c             	sub    $0x1c,%esp
  8026b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8026bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8026bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8026c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8026c7:	85 d2                	test   %edx,%edx
  8026c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8026cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026d1:	89 f3                	mov    %esi,%ebx
  8026d3:	89 3c 24             	mov    %edi,(%esp)
  8026d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026da:	75 1c                	jne    8026f8 <__umoddi3+0x48>
  8026dc:	39 f7                	cmp    %esi,%edi
  8026de:	76 50                	jbe    802730 <__umoddi3+0x80>
  8026e0:	89 c8                	mov    %ecx,%eax
  8026e2:	89 f2                	mov    %esi,%edx
  8026e4:	f7 f7                	div    %edi
  8026e6:	89 d0                	mov    %edx,%eax
  8026e8:	31 d2                	xor    %edx,%edx
  8026ea:	83 c4 1c             	add    $0x1c,%esp
  8026ed:	5b                   	pop    %ebx
  8026ee:	5e                   	pop    %esi
  8026ef:	5f                   	pop    %edi
  8026f0:	5d                   	pop    %ebp
  8026f1:	c3                   	ret    
  8026f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8026f8:	39 f2                	cmp    %esi,%edx
  8026fa:	89 d0                	mov    %edx,%eax
  8026fc:	77 52                	ja     802750 <__umoddi3+0xa0>
  8026fe:	0f bd ea             	bsr    %edx,%ebp
  802701:	83 f5 1f             	xor    $0x1f,%ebp
  802704:	75 5a                	jne    802760 <__umoddi3+0xb0>
  802706:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80270a:	0f 82 e0 00 00 00    	jb     8027f0 <__umoddi3+0x140>
  802710:	39 0c 24             	cmp    %ecx,(%esp)
  802713:	0f 86 d7 00 00 00    	jbe    8027f0 <__umoddi3+0x140>
  802719:	8b 44 24 08          	mov    0x8(%esp),%eax
  80271d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802721:	83 c4 1c             	add    $0x1c,%esp
  802724:	5b                   	pop    %ebx
  802725:	5e                   	pop    %esi
  802726:	5f                   	pop    %edi
  802727:	5d                   	pop    %ebp
  802728:	c3                   	ret    
  802729:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802730:	85 ff                	test   %edi,%edi
  802732:	89 fd                	mov    %edi,%ebp
  802734:	75 0b                	jne    802741 <__umoddi3+0x91>
  802736:	b8 01 00 00 00       	mov    $0x1,%eax
  80273b:	31 d2                	xor    %edx,%edx
  80273d:	f7 f7                	div    %edi
  80273f:	89 c5                	mov    %eax,%ebp
  802741:	89 f0                	mov    %esi,%eax
  802743:	31 d2                	xor    %edx,%edx
  802745:	f7 f5                	div    %ebp
  802747:	89 c8                	mov    %ecx,%eax
  802749:	f7 f5                	div    %ebp
  80274b:	89 d0                	mov    %edx,%eax
  80274d:	eb 99                	jmp    8026e8 <__umoddi3+0x38>
  80274f:	90                   	nop
  802750:	89 c8                	mov    %ecx,%eax
  802752:	89 f2                	mov    %esi,%edx
  802754:	83 c4 1c             	add    $0x1c,%esp
  802757:	5b                   	pop    %ebx
  802758:	5e                   	pop    %esi
  802759:	5f                   	pop    %edi
  80275a:	5d                   	pop    %ebp
  80275b:	c3                   	ret    
  80275c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802760:	8b 34 24             	mov    (%esp),%esi
  802763:	bf 20 00 00 00       	mov    $0x20,%edi
  802768:	89 e9                	mov    %ebp,%ecx
  80276a:	29 ef                	sub    %ebp,%edi
  80276c:	d3 e0                	shl    %cl,%eax
  80276e:	89 f9                	mov    %edi,%ecx
  802770:	89 f2                	mov    %esi,%edx
  802772:	d3 ea                	shr    %cl,%edx
  802774:	89 e9                	mov    %ebp,%ecx
  802776:	09 c2                	or     %eax,%edx
  802778:	89 d8                	mov    %ebx,%eax
  80277a:	89 14 24             	mov    %edx,(%esp)
  80277d:	89 f2                	mov    %esi,%edx
  80277f:	d3 e2                	shl    %cl,%edx
  802781:	89 f9                	mov    %edi,%ecx
  802783:	89 54 24 04          	mov    %edx,0x4(%esp)
  802787:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80278b:	d3 e8                	shr    %cl,%eax
  80278d:	89 e9                	mov    %ebp,%ecx
  80278f:	89 c6                	mov    %eax,%esi
  802791:	d3 e3                	shl    %cl,%ebx
  802793:	89 f9                	mov    %edi,%ecx
  802795:	89 d0                	mov    %edx,%eax
  802797:	d3 e8                	shr    %cl,%eax
  802799:	89 e9                	mov    %ebp,%ecx
  80279b:	09 d8                	or     %ebx,%eax
  80279d:	89 d3                	mov    %edx,%ebx
  80279f:	89 f2                	mov    %esi,%edx
  8027a1:	f7 34 24             	divl   (%esp)
  8027a4:	89 d6                	mov    %edx,%esi
  8027a6:	d3 e3                	shl    %cl,%ebx
  8027a8:	f7 64 24 04          	mull   0x4(%esp)
  8027ac:	39 d6                	cmp    %edx,%esi
  8027ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8027b2:	89 d1                	mov    %edx,%ecx
  8027b4:	89 c3                	mov    %eax,%ebx
  8027b6:	72 08                	jb     8027c0 <__umoddi3+0x110>
  8027b8:	75 11                	jne    8027cb <__umoddi3+0x11b>
  8027ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8027be:	73 0b                	jae    8027cb <__umoddi3+0x11b>
  8027c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8027c4:	1b 14 24             	sbb    (%esp),%edx
  8027c7:	89 d1                	mov    %edx,%ecx
  8027c9:	89 c3                	mov    %eax,%ebx
  8027cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8027cf:	29 da                	sub    %ebx,%edx
  8027d1:	19 ce                	sbb    %ecx,%esi
  8027d3:	89 f9                	mov    %edi,%ecx
  8027d5:	89 f0                	mov    %esi,%eax
  8027d7:	d3 e0                	shl    %cl,%eax
  8027d9:	89 e9                	mov    %ebp,%ecx
  8027db:	d3 ea                	shr    %cl,%edx
  8027dd:	89 e9                	mov    %ebp,%ecx
  8027df:	d3 ee                	shr    %cl,%esi
  8027e1:	09 d0                	or     %edx,%eax
  8027e3:	89 f2                	mov    %esi,%edx
  8027e5:	83 c4 1c             	add    $0x1c,%esp
  8027e8:	5b                   	pop    %ebx
  8027e9:	5e                   	pop    %esi
  8027ea:	5f                   	pop    %edi
  8027eb:	5d                   	pop    %ebp
  8027ec:	c3                   	ret    
  8027ed:	8d 76 00             	lea    0x0(%esi),%esi
  8027f0:	29 f9                	sub    %edi,%ecx
  8027f2:	19 d6                	sbb    %edx,%esi
  8027f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8027f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8027fc:	e9 18 ff ff ff       	jmp    802719 <__umoddi3+0x69>
