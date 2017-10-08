
obj/user/spawnhello.debug：     文件格式 elf32-i386


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
  80002c:	e8 4a 00 00 00       	call   80007b <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	int r;
	cprintf("i am parent environment %08x\n", thisenv->env_id);
  800039:	a1 04 40 80 00       	mov    0x804004,%eax
  80003e:	8b 40 48             	mov    0x48(%eax),%eax
  800041:	50                   	push   %eax
  800042:	68 00 24 80 00       	push   $0x802400
  800047:	e8 68 01 00 00       	call   8001b4 <cprintf>
	if ((r = spawnl("hello", "hello", 0)) < 0)
  80004c:	83 c4 0c             	add    $0xc,%esp
  80004f:	6a 00                	push   $0x0
  800051:	68 1e 24 80 00       	push   $0x80241e
  800056:	68 1e 24 80 00       	push   $0x80241e
  80005b:	e8 80 1a 00 00       	call   801ae0 <spawnl>
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	85 c0                	test   %eax,%eax
  800065:	79 12                	jns    800079 <umain+0x46>
		panic("spawn(hello) failed: %e", r);
  800067:	50                   	push   %eax
  800068:	68 24 24 80 00       	push   $0x802424
  80006d:	6a 09                	push   $0x9
  80006f:	68 3c 24 80 00       	push   $0x80243c
  800074:	e8 62 00 00 00       	call   8000db <_panic>
}
  800079:	c9                   	leave  
  80007a:	c3                   	ret    

0080007b <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80007b:	55                   	push   %ebp
  80007c:	89 e5                	mov    %esp,%ebp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800083:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800086:	e8 f2 0a 00 00       	call   800b7d <sys_getenvid>
  80008b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800090:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800093:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800098:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80009d:	85 db                	test   %ebx,%ebx
  80009f:	7e 07                	jle    8000a8 <libmain+0x2d>
		binaryname = argv[0];
  8000a1:	8b 06                	mov    (%esi),%eax
  8000a3:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000a8:	83 ec 08             	sub    $0x8,%esp
  8000ab:	56                   	push   %esi
  8000ac:	53                   	push   %ebx
  8000ad:	e8 81 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000b2:	e8 0a 00 00 00       	call   8000c1 <exit>
}
  8000b7:	83 c4 10             	add    $0x10,%esp
  8000ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000bd:	5b                   	pop    %ebx
  8000be:	5e                   	pop    %esi
  8000bf:	5d                   	pop    %ebp
  8000c0:	c3                   	ret    

008000c1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c1:	55                   	push   %ebp
  8000c2:	89 e5                	mov    %esp,%ebp
  8000c4:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000c7:	e8 ab 0e 00 00       	call   800f77 <close_all>
	sys_env_destroy(0);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	6a 00                	push   $0x0
  8000d1:	e8 66 0a 00 00       	call   800b3c <sys_env_destroy>
}
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	c9                   	leave  
  8000da:	c3                   	ret    

008000db <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	56                   	push   %esi
  8000df:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8000e0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8000e3:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8000e9:	e8 8f 0a 00 00       	call   800b7d <sys_getenvid>
  8000ee:	83 ec 0c             	sub    $0xc,%esp
  8000f1:	ff 75 0c             	pushl  0xc(%ebp)
  8000f4:	ff 75 08             	pushl  0x8(%ebp)
  8000f7:	56                   	push   %esi
  8000f8:	50                   	push   %eax
  8000f9:	68 58 24 80 00       	push   $0x802458
  8000fe:	e8 b1 00 00 00       	call   8001b4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800103:	83 c4 18             	add    $0x18,%esp
  800106:	53                   	push   %ebx
  800107:	ff 75 10             	pushl  0x10(%ebp)
  80010a:	e8 54 00 00 00       	call   800163 <vcprintf>
	cprintf("\n");
  80010f:	c7 04 24 20 29 80 00 	movl   $0x802920,(%esp)
  800116:	e8 99 00 00 00       	call   8001b4 <cprintf>
  80011b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80011e:	cc                   	int3   
  80011f:	eb fd                	jmp    80011e <_panic+0x43>

00800121 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800121:	55                   	push   %ebp
  800122:	89 e5                	mov    %esp,%ebp
  800124:	53                   	push   %ebx
  800125:	83 ec 04             	sub    $0x4,%esp
  800128:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80012b:	8b 13                	mov    (%ebx),%edx
  80012d:	8d 42 01             	lea    0x1(%edx),%eax
  800130:	89 03                	mov    %eax,(%ebx)
  800132:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800135:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800139:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013e:	75 1a                	jne    80015a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800140:	83 ec 08             	sub    $0x8,%esp
  800143:	68 ff 00 00 00       	push   $0xff
  800148:	8d 43 08             	lea    0x8(%ebx),%eax
  80014b:	50                   	push   %eax
  80014c:	e8 ae 09 00 00       	call   800aff <sys_cputs>
		b->idx = 0;
  800151:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800157:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80015a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80015e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800161:	c9                   	leave  
  800162:	c3                   	ret    

00800163 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80016c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800173:	00 00 00 
	b.cnt = 0;
  800176:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800180:	ff 75 0c             	pushl  0xc(%ebp)
  800183:	ff 75 08             	pushl  0x8(%ebp)
  800186:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80018c:	50                   	push   %eax
  80018d:	68 21 01 80 00       	push   $0x800121
  800192:	e8 1a 01 00 00       	call   8002b1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800197:	83 c4 08             	add    $0x8,%esp
  80019a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001a0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a6:	50                   	push   %eax
  8001a7:	e8 53 09 00 00       	call   800aff <sys_cputs>

	return b.cnt;
}
  8001ac:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001b2:	c9                   	leave  
  8001b3:	c3                   	ret    

008001b4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ba:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001bd:	50                   	push   %eax
  8001be:	ff 75 08             	pushl  0x8(%ebp)
  8001c1:	e8 9d ff ff ff       	call   800163 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c6:	c9                   	leave  
  8001c7:	c3                   	ret    

008001c8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	57                   	push   %edi
  8001cc:	56                   	push   %esi
  8001cd:	53                   	push   %ebx
  8001ce:	83 ec 1c             	sub    $0x1c,%esp
  8001d1:	89 c7                	mov    %eax,%edi
  8001d3:	89 d6                	mov    %edx,%esi
  8001d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001db:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001de:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001ec:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001ef:	39 d3                	cmp    %edx,%ebx
  8001f1:	72 05                	jb     8001f8 <printnum+0x30>
  8001f3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f6:	77 45                	ja     80023d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f8:	83 ec 0c             	sub    $0xc,%esp
  8001fb:	ff 75 18             	pushl  0x18(%ebp)
  8001fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800201:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800204:	53                   	push   %ebx
  800205:	ff 75 10             	pushl  0x10(%ebp)
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80020e:	ff 75 e0             	pushl  -0x20(%ebp)
  800211:	ff 75 dc             	pushl  -0x24(%ebp)
  800214:	ff 75 d8             	pushl  -0x28(%ebp)
  800217:	e8 54 1f 00 00       	call   802170 <__udivdi3>
  80021c:	83 c4 18             	add    $0x18,%esp
  80021f:	52                   	push   %edx
  800220:	50                   	push   %eax
  800221:	89 f2                	mov    %esi,%edx
  800223:	89 f8                	mov    %edi,%eax
  800225:	e8 9e ff ff ff       	call   8001c8 <printnum>
  80022a:	83 c4 20             	add    $0x20,%esp
  80022d:	eb 18                	jmp    800247 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022f:	83 ec 08             	sub    $0x8,%esp
  800232:	56                   	push   %esi
  800233:	ff 75 18             	pushl  0x18(%ebp)
  800236:	ff d7                	call   *%edi
  800238:	83 c4 10             	add    $0x10,%esp
  80023b:	eb 03                	jmp    800240 <printnum+0x78>
  80023d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800240:	83 eb 01             	sub    $0x1,%ebx
  800243:	85 db                	test   %ebx,%ebx
  800245:	7f e8                	jg     80022f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800247:	83 ec 08             	sub    $0x8,%esp
  80024a:	56                   	push   %esi
  80024b:	83 ec 04             	sub    $0x4,%esp
  80024e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800251:	ff 75 e0             	pushl  -0x20(%ebp)
  800254:	ff 75 dc             	pushl  -0x24(%ebp)
  800257:	ff 75 d8             	pushl  -0x28(%ebp)
  80025a:	e8 41 20 00 00       	call   8022a0 <__umoddi3>
  80025f:	83 c4 14             	add    $0x14,%esp
  800262:	0f be 80 7b 24 80 00 	movsbl 0x80247b(%eax),%eax
  800269:	50                   	push   %eax
  80026a:	ff d7                	call   *%edi
}
  80026c:	83 c4 10             	add    $0x10,%esp
  80026f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800272:	5b                   	pop    %ebx
  800273:	5e                   	pop    %esi
  800274:	5f                   	pop    %edi
  800275:	5d                   	pop    %ebp
  800276:	c3                   	ret    

00800277 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800277:	55                   	push   %ebp
  800278:	89 e5                	mov    %esp,%ebp
  80027a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80027d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800281:	8b 10                	mov    (%eax),%edx
  800283:	3b 50 04             	cmp    0x4(%eax),%edx
  800286:	73 0a                	jae    800292 <sprintputch+0x1b>
		*b->buf++ = ch;
  800288:	8d 4a 01             	lea    0x1(%edx),%ecx
  80028b:	89 08                	mov    %ecx,(%eax)
  80028d:	8b 45 08             	mov    0x8(%ebp),%eax
  800290:	88 02                	mov    %al,(%edx)
}
  800292:	5d                   	pop    %ebp
  800293:	c3                   	ret    

00800294 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800294:	55                   	push   %ebp
  800295:	89 e5                	mov    %esp,%ebp
  800297:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80029a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80029d:	50                   	push   %eax
  80029e:	ff 75 10             	pushl  0x10(%ebp)
  8002a1:	ff 75 0c             	pushl  0xc(%ebp)
  8002a4:	ff 75 08             	pushl  0x8(%ebp)
  8002a7:	e8 05 00 00 00       	call   8002b1 <vprintfmt>
	va_end(ap);
}
  8002ac:	83 c4 10             	add    $0x10,%esp
  8002af:	c9                   	leave  
  8002b0:	c3                   	ret    

008002b1 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	57                   	push   %edi
  8002b5:	56                   	push   %esi
  8002b6:	53                   	push   %ebx
  8002b7:	83 ec 2c             	sub    $0x2c,%esp
  8002ba:	8b 75 08             	mov    0x8(%ebp),%esi
  8002bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002c0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002c3:	eb 12                	jmp    8002d7 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002c5:	85 c0                	test   %eax,%eax
  8002c7:	0f 84 42 04 00 00    	je     80070f <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8002cd:	83 ec 08             	sub    $0x8,%esp
  8002d0:	53                   	push   %ebx
  8002d1:	50                   	push   %eax
  8002d2:	ff d6                	call   *%esi
  8002d4:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002d7:	83 c7 01             	add    $0x1,%edi
  8002da:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002de:	83 f8 25             	cmp    $0x25,%eax
  8002e1:	75 e2                	jne    8002c5 <vprintfmt+0x14>
  8002e3:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002e7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002ee:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002f5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002fc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800301:	eb 07                	jmp    80030a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800303:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800306:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80030a:	8d 47 01             	lea    0x1(%edi),%eax
  80030d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800310:	0f b6 07             	movzbl (%edi),%eax
  800313:	0f b6 d0             	movzbl %al,%edx
  800316:	83 e8 23             	sub    $0x23,%eax
  800319:	3c 55                	cmp    $0x55,%al
  80031b:	0f 87 d3 03 00 00    	ja     8006f4 <vprintfmt+0x443>
  800321:	0f b6 c0             	movzbl %al,%eax
  800324:	ff 24 85 c0 25 80 00 	jmp    *0x8025c0(,%eax,4)
  80032b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80032e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800332:	eb d6                	jmp    80030a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800334:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800337:	b8 00 00 00 00       	mov    $0x0,%eax
  80033c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80033f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800342:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800346:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800349:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80034c:	83 f9 09             	cmp    $0x9,%ecx
  80034f:	77 3f                	ja     800390 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800351:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800354:	eb e9                	jmp    80033f <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800356:	8b 45 14             	mov    0x14(%ebp),%eax
  800359:	8b 00                	mov    (%eax),%eax
  80035b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80035e:	8b 45 14             	mov    0x14(%ebp),%eax
  800361:	8d 40 04             	lea    0x4(%eax),%eax
  800364:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800367:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80036a:	eb 2a                	jmp    800396 <vprintfmt+0xe5>
  80036c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80036f:	85 c0                	test   %eax,%eax
  800371:	ba 00 00 00 00       	mov    $0x0,%edx
  800376:	0f 49 d0             	cmovns %eax,%edx
  800379:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80037f:	eb 89                	jmp    80030a <vprintfmt+0x59>
  800381:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800384:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80038b:	e9 7a ff ff ff       	jmp    80030a <vprintfmt+0x59>
  800390:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800393:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800396:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80039a:	0f 89 6a ff ff ff    	jns    80030a <vprintfmt+0x59>
				width = precision, precision = -1;
  8003a0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003a6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003ad:	e9 58 ff ff ff       	jmp    80030a <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003b2:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003b8:	e9 4d ff ff ff       	jmp    80030a <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c0:	8d 78 04             	lea    0x4(%eax),%edi
  8003c3:	83 ec 08             	sub    $0x8,%esp
  8003c6:	53                   	push   %ebx
  8003c7:	ff 30                	pushl  (%eax)
  8003c9:	ff d6                	call   *%esi
			break;
  8003cb:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ce:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003d4:	e9 fe fe ff ff       	jmp    8002d7 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003dc:	8d 78 04             	lea    0x4(%eax),%edi
  8003df:	8b 00                	mov    (%eax),%eax
  8003e1:	99                   	cltd   
  8003e2:	31 d0                	xor    %edx,%eax
  8003e4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003e6:	83 f8 0f             	cmp    $0xf,%eax
  8003e9:	7f 0b                	jg     8003f6 <vprintfmt+0x145>
  8003eb:	8b 14 85 20 27 80 00 	mov    0x802720(,%eax,4),%edx
  8003f2:	85 d2                	test   %edx,%edx
  8003f4:	75 1b                	jne    800411 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8003f6:	50                   	push   %eax
  8003f7:	68 93 24 80 00       	push   $0x802493
  8003fc:	53                   	push   %ebx
  8003fd:	56                   	push   %esi
  8003fe:	e8 91 fe ff ff       	call   800294 <printfmt>
  800403:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800406:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800409:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80040c:	e9 c6 fe ff ff       	jmp    8002d7 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800411:	52                   	push   %edx
  800412:	68 51 28 80 00       	push   $0x802851
  800417:	53                   	push   %ebx
  800418:	56                   	push   %esi
  800419:	e8 76 fe ff ff       	call   800294 <printfmt>
  80041e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800421:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800424:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800427:	e9 ab fe ff ff       	jmp    8002d7 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80042c:	8b 45 14             	mov    0x14(%ebp),%eax
  80042f:	83 c0 04             	add    $0x4,%eax
  800432:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800435:	8b 45 14             	mov    0x14(%ebp),%eax
  800438:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80043a:	85 ff                	test   %edi,%edi
  80043c:	b8 8c 24 80 00       	mov    $0x80248c,%eax
  800441:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800444:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800448:	0f 8e 94 00 00 00    	jle    8004e2 <vprintfmt+0x231>
  80044e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800452:	0f 84 98 00 00 00    	je     8004f0 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800458:	83 ec 08             	sub    $0x8,%esp
  80045b:	ff 75 d0             	pushl  -0x30(%ebp)
  80045e:	57                   	push   %edi
  80045f:	e8 33 03 00 00       	call   800797 <strnlen>
  800464:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800467:	29 c1                	sub    %eax,%ecx
  800469:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80046c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80046f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800473:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800476:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800479:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80047b:	eb 0f                	jmp    80048c <vprintfmt+0x1db>
					putch(padc, putdat);
  80047d:	83 ec 08             	sub    $0x8,%esp
  800480:	53                   	push   %ebx
  800481:	ff 75 e0             	pushl  -0x20(%ebp)
  800484:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800486:	83 ef 01             	sub    $0x1,%edi
  800489:	83 c4 10             	add    $0x10,%esp
  80048c:	85 ff                	test   %edi,%edi
  80048e:	7f ed                	jg     80047d <vprintfmt+0x1cc>
  800490:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800493:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800496:	85 c9                	test   %ecx,%ecx
  800498:	b8 00 00 00 00       	mov    $0x0,%eax
  80049d:	0f 49 c1             	cmovns %ecx,%eax
  8004a0:	29 c1                	sub    %eax,%ecx
  8004a2:	89 75 08             	mov    %esi,0x8(%ebp)
  8004a5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004a8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ab:	89 cb                	mov    %ecx,%ebx
  8004ad:	eb 4d                	jmp    8004fc <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004af:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004b3:	74 1b                	je     8004d0 <vprintfmt+0x21f>
  8004b5:	0f be c0             	movsbl %al,%eax
  8004b8:	83 e8 20             	sub    $0x20,%eax
  8004bb:	83 f8 5e             	cmp    $0x5e,%eax
  8004be:	76 10                	jbe    8004d0 <vprintfmt+0x21f>
					putch('?', putdat);
  8004c0:	83 ec 08             	sub    $0x8,%esp
  8004c3:	ff 75 0c             	pushl  0xc(%ebp)
  8004c6:	6a 3f                	push   $0x3f
  8004c8:	ff 55 08             	call   *0x8(%ebp)
  8004cb:	83 c4 10             	add    $0x10,%esp
  8004ce:	eb 0d                	jmp    8004dd <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8004d0:	83 ec 08             	sub    $0x8,%esp
  8004d3:	ff 75 0c             	pushl  0xc(%ebp)
  8004d6:	52                   	push   %edx
  8004d7:	ff 55 08             	call   *0x8(%ebp)
  8004da:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004dd:	83 eb 01             	sub    $0x1,%ebx
  8004e0:	eb 1a                	jmp    8004fc <vprintfmt+0x24b>
  8004e2:	89 75 08             	mov    %esi,0x8(%ebp)
  8004e5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004e8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004eb:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004ee:	eb 0c                	jmp    8004fc <vprintfmt+0x24b>
  8004f0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004fc:	83 c7 01             	add    $0x1,%edi
  8004ff:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800503:	0f be d0             	movsbl %al,%edx
  800506:	85 d2                	test   %edx,%edx
  800508:	74 23                	je     80052d <vprintfmt+0x27c>
  80050a:	85 f6                	test   %esi,%esi
  80050c:	78 a1                	js     8004af <vprintfmt+0x1fe>
  80050e:	83 ee 01             	sub    $0x1,%esi
  800511:	79 9c                	jns    8004af <vprintfmt+0x1fe>
  800513:	89 df                	mov    %ebx,%edi
  800515:	8b 75 08             	mov    0x8(%ebp),%esi
  800518:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80051b:	eb 18                	jmp    800535 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80051d:	83 ec 08             	sub    $0x8,%esp
  800520:	53                   	push   %ebx
  800521:	6a 20                	push   $0x20
  800523:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800525:	83 ef 01             	sub    $0x1,%edi
  800528:	83 c4 10             	add    $0x10,%esp
  80052b:	eb 08                	jmp    800535 <vprintfmt+0x284>
  80052d:	89 df                	mov    %ebx,%edi
  80052f:	8b 75 08             	mov    0x8(%ebp),%esi
  800532:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800535:	85 ff                	test   %edi,%edi
  800537:	7f e4                	jg     80051d <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800539:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80053c:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800542:	e9 90 fd ff ff       	jmp    8002d7 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800547:	83 f9 01             	cmp    $0x1,%ecx
  80054a:	7e 19                	jle    800565 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  80054c:	8b 45 14             	mov    0x14(%ebp),%eax
  80054f:	8b 50 04             	mov    0x4(%eax),%edx
  800552:	8b 00                	mov    (%eax),%eax
  800554:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800557:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80055a:	8b 45 14             	mov    0x14(%ebp),%eax
  80055d:	8d 40 08             	lea    0x8(%eax),%eax
  800560:	89 45 14             	mov    %eax,0x14(%ebp)
  800563:	eb 38                	jmp    80059d <vprintfmt+0x2ec>
	else if (lflag)
  800565:	85 c9                	test   %ecx,%ecx
  800567:	74 1b                	je     800584 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800569:	8b 45 14             	mov    0x14(%ebp),%eax
  80056c:	8b 00                	mov    (%eax),%eax
  80056e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800571:	89 c1                	mov    %eax,%ecx
  800573:	c1 f9 1f             	sar    $0x1f,%ecx
  800576:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800579:	8b 45 14             	mov    0x14(%ebp),%eax
  80057c:	8d 40 04             	lea    0x4(%eax),%eax
  80057f:	89 45 14             	mov    %eax,0x14(%ebp)
  800582:	eb 19                	jmp    80059d <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800584:	8b 45 14             	mov    0x14(%ebp),%eax
  800587:	8b 00                	mov    (%eax),%eax
  800589:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058c:	89 c1                	mov    %eax,%ecx
  80058e:	c1 f9 1f             	sar    $0x1f,%ecx
  800591:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800594:	8b 45 14             	mov    0x14(%ebp),%eax
  800597:	8d 40 04             	lea    0x4(%eax),%eax
  80059a:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80059d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005a0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005a3:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005a8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005ac:	0f 89 0e 01 00 00    	jns    8006c0 <vprintfmt+0x40f>
				putch('-', putdat);
  8005b2:	83 ec 08             	sub    $0x8,%esp
  8005b5:	53                   	push   %ebx
  8005b6:	6a 2d                	push   $0x2d
  8005b8:	ff d6                	call   *%esi
				num = -(long long) num;
  8005ba:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005bd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005c0:	f7 da                	neg    %edx
  8005c2:	83 d1 00             	adc    $0x0,%ecx
  8005c5:	f7 d9                	neg    %ecx
  8005c7:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005ca:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005cf:	e9 ec 00 00 00       	jmp    8006c0 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005d4:	83 f9 01             	cmp    $0x1,%ecx
  8005d7:	7e 18                	jle    8005f1 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8005d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dc:	8b 10                	mov    (%eax),%edx
  8005de:	8b 48 04             	mov    0x4(%eax),%ecx
  8005e1:	8d 40 08             	lea    0x8(%eax),%eax
  8005e4:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005e7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ec:	e9 cf 00 00 00       	jmp    8006c0 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8005f1:	85 c9                	test   %ecx,%ecx
  8005f3:	74 1a                	je     80060f <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8005f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f8:	8b 10                	mov    (%eax),%edx
  8005fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ff:	8d 40 04             	lea    0x4(%eax),%eax
  800602:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800605:	b8 0a 00 00 00       	mov    $0xa,%eax
  80060a:	e9 b1 00 00 00       	jmp    8006c0 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80060f:	8b 45 14             	mov    0x14(%ebp),%eax
  800612:	8b 10                	mov    (%eax),%edx
  800614:	b9 00 00 00 00       	mov    $0x0,%ecx
  800619:	8d 40 04             	lea    0x4(%eax),%eax
  80061c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80061f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800624:	e9 97 00 00 00       	jmp    8006c0 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800629:	83 ec 08             	sub    $0x8,%esp
  80062c:	53                   	push   %ebx
  80062d:	6a 58                	push   $0x58
  80062f:	ff d6                	call   *%esi
			putch('X', putdat);
  800631:	83 c4 08             	add    $0x8,%esp
  800634:	53                   	push   %ebx
  800635:	6a 58                	push   $0x58
  800637:	ff d6                	call   *%esi
			putch('X', putdat);
  800639:	83 c4 08             	add    $0x8,%esp
  80063c:	53                   	push   %ebx
  80063d:	6a 58                	push   $0x58
  80063f:	ff d6                	call   *%esi
			break;
  800641:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800644:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800647:	e9 8b fc ff ff       	jmp    8002d7 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  80064c:	83 ec 08             	sub    $0x8,%esp
  80064f:	53                   	push   %ebx
  800650:	6a 30                	push   $0x30
  800652:	ff d6                	call   *%esi
			putch('x', putdat);
  800654:	83 c4 08             	add    $0x8,%esp
  800657:	53                   	push   %ebx
  800658:	6a 78                	push   $0x78
  80065a:	ff d6                	call   *%esi
			num = (unsigned long long)
  80065c:	8b 45 14             	mov    0x14(%ebp),%eax
  80065f:	8b 10                	mov    (%eax),%edx
  800661:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800666:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800669:	8d 40 04             	lea    0x4(%eax),%eax
  80066c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80066f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800674:	eb 4a                	jmp    8006c0 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800676:	83 f9 01             	cmp    $0x1,%ecx
  800679:	7e 15                	jle    800690 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  80067b:	8b 45 14             	mov    0x14(%ebp),%eax
  80067e:	8b 10                	mov    (%eax),%edx
  800680:	8b 48 04             	mov    0x4(%eax),%ecx
  800683:	8d 40 08             	lea    0x8(%eax),%eax
  800686:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800689:	b8 10 00 00 00       	mov    $0x10,%eax
  80068e:	eb 30                	jmp    8006c0 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800690:	85 c9                	test   %ecx,%ecx
  800692:	74 17                	je     8006ab <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800694:	8b 45 14             	mov    0x14(%ebp),%eax
  800697:	8b 10                	mov    (%eax),%edx
  800699:	b9 00 00 00 00       	mov    $0x0,%ecx
  80069e:	8d 40 04             	lea    0x4(%eax),%eax
  8006a1:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006a4:	b8 10 00 00 00       	mov    $0x10,%eax
  8006a9:	eb 15                	jmp    8006c0 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8006ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ae:	8b 10                	mov    (%eax),%edx
  8006b0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b5:	8d 40 04             	lea    0x4(%eax),%eax
  8006b8:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006bb:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006c0:	83 ec 0c             	sub    $0xc,%esp
  8006c3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006c7:	57                   	push   %edi
  8006c8:	ff 75 e0             	pushl  -0x20(%ebp)
  8006cb:	50                   	push   %eax
  8006cc:	51                   	push   %ecx
  8006cd:	52                   	push   %edx
  8006ce:	89 da                	mov    %ebx,%edx
  8006d0:	89 f0                	mov    %esi,%eax
  8006d2:	e8 f1 fa ff ff       	call   8001c8 <printnum>
			break;
  8006d7:	83 c4 20             	add    $0x20,%esp
  8006da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006dd:	e9 f5 fb ff ff       	jmp    8002d7 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006e2:	83 ec 08             	sub    $0x8,%esp
  8006e5:	53                   	push   %ebx
  8006e6:	52                   	push   %edx
  8006e7:	ff d6                	call   *%esi
			break;
  8006e9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006ef:	e9 e3 fb ff ff       	jmp    8002d7 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006f4:	83 ec 08             	sub    $0x8,%esp
  8006f7:	53                   	push   %ebx
  8006f8:	6a 25                	push   $0x25
  8006fa:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006fc:	83 c4 10             	add    $0x10,%esp
  8006ff:	eb 03                	jmp    800704 <vprintfmt+0x453>
  800701:	83 ef 01             	sub    $0x1,%edi
  800704:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800708:	75 f7                	jne    800701 <vprintfmt+0x450>
  80070a:	e9 c8 fb ff ff       	jmp    8002d7 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80070f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800712:	5b                   	pop    %ebx
  800713:	5e                   	pop    %esi
  800714:	5f                   	pop    %edi
  800715:	5d                   	pop    %ebp
  800716:	c3                   	ret    

00800717 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800717:	55                   	push   %ebp
  800718:	89 e5                	mov    %esp,%ebp
  80071a:	83 ec 18             	sub    $0x18,%esp
  80071d:	8b 45 08             	mov    0x8(%ebp),%eax
  800720:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800723:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800726:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80072a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80072d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800734:	85 c0                	test   %eax,%eax
  800736:	74 26                	je     80075e <vsnprintf+0x47>
  800738:	85 d2                	test   %edx,%edx
  80073a:	7e 22                	jle    80075e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80073c:	ff 75 14             	pushl  0x14(%ebp)
  80073f:	ff 75 10             	pushl  0x10(%ebp)
  800742:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800745:	50                   	push   %eax
  800746:	68 77 02 80 00       	push   $0x800277
  80074b:	e8 61 fb ff ff       	call   8002b1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800750:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800753:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800756:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800759:	83 c4 10             	add    $0x10,%esp
  80075c:	eb 05                	jmp    800763 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80075e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800763:	c9                   	leave  
  800764:	c3                   	ret    

00800765 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800765:	55                   	push   %ebp
  800766:	89 e5                	mov    %esp,%ebp
  800768:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80076b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80076e:	50                   	push   %eax
  80076f:	ff 75 10             	pushl  0x10(%ebp)
  800772:	ff 75 0c             	pushl  0xc(%ebp)
  800775:	ff 75 08             	pushl  0x8(%ebp)
  800778:	e8 9a ff ff ff       	call   800717 <vsnprintf>
	va_end(ap);

	return rc;
}
  80077d:	c9                   	leave  
  80077e:	c3                   	ret    

0080077f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80077f:	55                   	push   %ebp
  800780:	89 e5                	mov    %esp,%ebp
  800782:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800785:	b8 00 00 00 00       	mov    $0x0,%eax
  80078a:	eb 03                	jmp    80078f <strlen+0x10>
		n++;
  80078c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80078f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800793:	75 f7                	jne    80078c <strlen+0xd>
		n++;
	return n;
}
  800795:	5d                   	pop    %ebp
  800796:	c3                   	ret    

00800797 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
  80079a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079d:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8007a5:	eb 03                	jmp    8007aa <strnlen+0x13>
		n++;
  8007a7:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007aa:	39 c2                	cmp    %eax,%edx
  8007ac:	74 08                	je     8007b6 <strnlen+0x1f>
  8007ae:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007b2:	75 f3                	jne    8007a7 <strnlen+0x10>
  8007b4:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007b6:	5d                   	pop    %ebp
  8007b7:	c3                   	ret    

008007b8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	53                   	push   %ebx
  8007bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c2:	89 c2                	mov    %eax,%edx
  8007c4:	83 c2 01             	add    $0x1,%edx
  8007c7:	83 c1 01             	add    $0x1,%ecx
  8007ca:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007ce:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007d1:	84 db                	test   %bl,%bl
  8007d3:	75 ef                	jne    8007c4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007d5:	5b                   	pop    %ebx
  8007d6:	5d                   	pop    %ebp
  8007d7:	c3                   	ret    

008007d8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	53                   	push   %ebx
  8007dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007df:	53                   	push   %ebx
  8007e0:	e8 9a ff ff ff       	call   80077f <strlen>
  8007e5:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007e8:	ff 75 0c             	pushl  0xc(%ebp)
  8007eb:	01 d8                	add    %ebx,%eax
  8007ed:	50                   	push   %eax
  8007ee:	e8 c5 ff ff ff       	call   8007b8 <strcpy>
	return dst;
}
  8007f3:	89 d8                	mov    %ebx,%eax
  8007f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f8:	c9                   	leave  
  8007f9:	c3                   	ret    

008007fa <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007fa:	55                   	push   %ebp
  8007fb:	89 e5                	mov    %esp,%ebp
  8007fd:	56                   	push   %esi
  8007fe:	53                   	push   %ebx
  8007ff:	8b 75 08             	mov    0x8(%ebp),%esi
  800802:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800805:	89 f3                	mov    %esi,%ebx
  800807:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80080a:	89 f2                	mov    %esi,%edx
  80080c:	eb 0f                	jmp    80081d <strncpy+0x23>
		*dst++ = *src;
  80080e:	83 c2 01             	add    $0x1,%edx
  800811:	0f b6 01             	movzbl (%ecx),%eax
  800814:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800817:	80 39 01             	cmpb   $0x1,(%ecx)
  80081a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081d:	39 da                	cmp    %ebx,%edx
  80081f:	75 ed                	jne    80080e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800821:	89 f0                	mov    %esi,%eax
  800823:	5b                   	pop    %ebx
  800824:	5e                   	pop    %esi
  800825:	5d                   	pop    %ebp
  800826:	c3                   	ret    

00800827 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	56                   	push   %esi
  80082b:	53                   	push   %ebx
  80082c:	8b 75 08             	mov    0x8(%ebp),%esi
  80082f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800832:	8b 55 10             	mov    0x10(%ebp),%edx
  800835:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800837:	85 d2                	test   %edx,%edx
  800839:	74 21                	je     80085c <strlcpy+0x35>
  80083b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80083f:	89 f2                	mov    %esi,%edx
  800841:	eb 09                	jmp    80084c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800843:	83 c2 01             	add    $0x1,%edx
  800846:	83 c1 01             	add    $0x1,%ecx
  800849:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80084c:	39 c2                	cmp    %eax,%edx
  80084e:	74 09                	je     800859 <strlcpy+0x32>
  800850:	0f b6 19             	movzbl (%ecx),%ebx
  800853:	84 db                	test   %bl,%bl
  800855:	75 ec                	jne    800843 <strlcpy+0x1c>
  800857:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800859:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80085c:	29 f0                	sub    %esi,%eax
}
  80085e:	5b                   	pop    %ebx
  80085f:	5e                   	pop    %esi
  800860:	5d                   	pop    %ebp
  800861:	c3                   	ret    

00800862 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800868:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80086b:	eb 06                	jmp    800873 <strcmp+0x11>
		p++, q++;
  80086d:	83 c1 01             	add    $0x1,%ecx
  800870:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800873:	0f b6 01             	movzbl (%ecx),%eax
  800876:	84 c0                	test   %al,%al
  800878:	74 04                	je     80087e <strcmp+0x1c>
  80087a:	3a 02                	cmp    (%edx),%al
  80087c:	74 ef                	je     80086d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80087e:	0f b6 c0             	movzbl %al,%eax
  800881:	0f b6 12             	movzbl (%edx),%edx
  800884:	29 d0                	sub    %edx,%eax
}
  800886:	5d                   	pop    %ebp
  800887:	c3                   	ret    

00800888 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	53                   	push   %ebx
  80088c:	8b 45 08             	mov    0x8(%ebp),%eax
  80088f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800892:	89 c3                	mov    %eax,%ebx
  800894:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800897:	eb 06                	jmp    80089f <strncmp+0x17>
		n--, p++, q++;
  800899:	83 c0 01             	add    $0x1,%eax
  80089c:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80089f:	39 d8                	cmp    %ebx,%eax
  8008a1:	74 15                	je     8008b8 <strncmp+0x30>
  8008a3:	0f b6 08             	movzbl (%eax),%ecx
  8008a6:	84 c9                	test   %cl,%cl
  8008a8:	74 04                	je     8008ae <strncmp+0x26>
  8008aa:	3a 0a                	cmp    (%edx),%cl
  8008ac:	74 eb                	je     800899 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ae:	0f b6 00             	movzbl (%eax),%eax
  8008b1:	0f b6 12             	movzbl (%edx),%edx
  8008b4:	29 d0                	sub    %edx,%eax
  8008b6:	eb 05                	jmp    8008bd <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008b8:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008bd:	5b                   	pop    %ebx
  8008be:	5d                   	pop    %ebp
  8008bf:	c3                   	ret    

008008c0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ca:	eb 07                	jmp    8008d3 <strchr+0x13>
		if (*s == c)
  8008cc:	38 ca                	cmp    %cl,%dl
  8008ce:	74 0f                	je     8008df <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008d0:	83 c0 01             	add    $0x1,%eax
  8008d3:	0f b6 10             	movzbl (%eax),%edx
  8008d6:	84 d2                	test   %dl,%dl
  8008d8:	75 f2                	jne    8008cc <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008da:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008df:	5d                   	pop    %ebp
  8008e0:	c3                   	ret    

008008e1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
  8008e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008eb:	eb 03                	jmp    8008f0 <strfind+0xf>
  8008ed:	83 c0 01             	add    $0x1,%eax
  8008f0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008f3:	38 ca                	cmp    %cl,%dl
  8008f5:	74 04                	je     8008fb <strfind+0x1a>
  8008f7:	84 d2                	test   %dl,%dl
  8008f9:	75 f2                	jne    8008ed <strfind+0xc>
			break;
	return (char *) s;
}
  8008fb:	5d                   	pop    %ebp
  8008fc:	c3                   	ret    

008008fd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008fd:	55                   	push   %ebp
  8008fe:	89 e5                	mov    %esp,%ebp
  800900:	57                   	push   %edi
  800901:	56                   	push   %esi
  800902:	53                   	push   %ebx
  800903:	8b 7d 08             	mov    0x8(%ebp),%edi
  800906:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800909:	85 c9                	test   %ecx,%ecx
  80090b:	74 36                	je     800943 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80090d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800913:	75 28                	jne    80093d <memset+0x40>
  800915:	f6 c1 03             	test   $0x3,%cl
  800918:	75 23                	jne    80093d <memset+0x40>
		c &= 0xFF;
  80091a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80091e:	89 d3                	mov    %edx,%ebx
  800920:	c1 e3 08             	shl    $0x8,%ebx
  800923:	89 d6                	mov    %edx,%esi
  800925:	c1 e6 18             	shl    $0x18,%esi
  800928:	89 d0                	mov    %edx,%eax
  80092a:	c1 e0 10             	shl    $0x10,%eax
  80092d:	09 f0                	or     %esi,%eax
  80092f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800931:	89 d8                	mov    %ebx,%eax
  800933:	09 d0                	or     %edx,%eax
  800935:	c1 e9 02             	shr    $0x2,%ecx
  800938:	fc                   	cld    
  800939:	f3 ab                	rep stos %eax,%es:(%edi)
  80093b:	eb 06                	jmp    800943 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80093d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800940:	fc                   	cld    
  800941:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800943:	89 f8                	mov    %edi,%eax
  800945:	5b                   	pop    %ebx
  800946:	5e                   	pop    %esi
  800947:	5f                   	pop    %edi
  800948:	5d                   	pop    %ebp
  800949:	c3                   	ret    

0080094a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	57                   	push   %edi
  80094e:	56                   	push   %esi
  80094f:	8b 45 08             	mov    0x8(%ebp),%eax
  800952:	8b 75 0c             	mov    0xc(%ebp),%esi
  800955:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800958:	39 c6                	cmp    %eax,%esi
  80095a:	73 35                	jae    800991 <memmove+0x47>
  80095c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80095f:	39 d0                	cmp    %edx,%eax
  800961:	73 2e                	jae    800991 <memmove+0x47>
		s += n;
		d += n;
  800963:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800966:	89 d6                	mov    %edx,%esi
  800968:	09 fe                	or     %edi,%esi
  80096a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800970:	75 13                	jne    800985 <memmove+0x3b>
  800972:	f6 c1 03             	test   $0x3,%cl
  800975:	75 0e                	jne    800985 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800977:	83 ef 04             	sub    $0x4,%edi
  80097a:	8d 72 fc             	lea    -0x4(%edx),%esi
  80097d:	c1 e9 02             	shr    $0x2,%ecx
  800980:	fd                   	std    
  800981:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800983:	eb 09                	jmp    80098e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800985:	83 ef 01             	sub    $0x1,%edi
  800988:	8d 72 ff             	lea    -0x1(%edx),%esi
  80098b:	fd                   	std    
  80098c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80098e:	fc                   	cld    
  80098f:	eb 1d                	jmp    8009ae <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800991:	89 f2                	mov    %esi,%edx
  800993:	09 c2                	or     %eax,%edx
  800995:	f6 c2 03             	test   $0x3,%dl
  800998:	75 0f                	jne    8009a9 <memmove+0x5f>
  80099a:	f6 c1 03             	test   $0x3,%cl
  80099d:	75 0a                	jne    8009a9 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80099f:	c1 e9 02             	shr    $0x2,%ecx
  8009a2:	89 c7                	mov    %eax,%edi
  8009a4:	fc                   	cld    
  8009a5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a7:	eb 05                	jmp    8009ae <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009a9:	89 c7                	mov    %eax,%edi
  8009ab:	fc                   	cld    
  8009ac:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ae:	5e                   	pop    %esi
  8009af:	5f                   	pop    %edi
  8009b0:	5d                   	pop    %ebp
  8009b1:	c3                   	ret    

008009b2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009b5:	ff 75 10             	pushl  0x10(%ebp)
  8009b8:	ff 75 0c             	pushl  0xc(%ebp)
  8009bb:	ff 75 08             	pushl  0x8(%ebp)
  8009be:	e8 87 ff ff ff       	call   80094a <memmove>
}
  8009c3:	c9                   	leave  
  8009c4:	c3                   	ret    

008009c5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	56                   	push   %esi
  8009c9:	53                   	push   %ebx
  8009ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d0:	89 c6                	mov    %eax,%esi
  8009d2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d5:	eb 1a                	jmp    8009f1 <memcmp+0x2c>
		if (*s1 != *s2)
  8009d7:	0f b6 08             	movzbl (%eax),%ecx
  8009da:	0f b6 1a             	movzbl (%edx),%ebx
  8009dd:	38 d9                	cmp    %bl,%cl
  8009df:	74 0a                	je     8009eb <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009e1:	0f b6 c1             	movzbl %cl,%eax
  8009e4:	0f b6 db             	movzbl %bl,%ebx
  8009e7:	29 d8                	sub    %ebx,%eax
  8009e9:	eb 0f                	jmp    8009fa <memcmp+0x35>
		s1++, s2++;
  8009eb:	83 c0 01             	add    $0x1,%eax
  8009ee:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f1:	39 f0                	cmp    %esi,%eax
  8009f3:	75 e2                	jne    8009d7 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009fa:	5b                   	pop    %ebx
  8009fb:	5e                   	pop    %esi
  8009fc:	5d                   	pop    %ebp
  8009fd:	c3                   	ret    

008009fe <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	53                   	push   %ebx
  800a02:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a05:	89 c1                	mov    %eax,%ecx
  800a07:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a0a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a0e:	eb 0a                	jmp    800a1a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a10:	0f b6 10             	movzbl (%eax),%edx
  800a13:	39 da                	cmp    %ebx,%edx
  800a15:	74 07                	je     800a1e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a17:	83 c0 01             	add    $0x1,%eax
  800a1a:	39 c8                	cmp    %ecx,%eax
  800a1c:	72 f2                	jb     800a10 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a1e:	5b                   	pop    %ebx
  800a1f:	5d                   	pop    %ebp
  800a20:	c3                   	ret    

00800a21 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a21:	55                   	push   %ebp
  800a22:	89 e5                	mov    %esp,%ebp
  800a24:	57                   	push   %edi
  800a25:	56                   	push   %esi
  800a26:	53                   	push   %ebx
  800a27:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a2a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a2d:	eb 03                	jmp    800a32 <strtol+0x11>
		s++;
  800a2f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a32:	0f b6 01             	movzbl (%ecx),%eax
  800a35:	3c 20                	cmp    $0x20,%al
  800a37:	74 f6                	je     800a2f <strtol+0xe>
  800a39:	3c 09                	cmp    $0x9,%al
  800a3b:	74 f2                	je     800a2f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a3d:	3c 2b                	cmp    $0x2b,%al
  800a3f:	75 0a                	jne    800a4b <strtol+0x2a>
		s++;
  800a41:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a44:	bf 00 00 00 00       	mov    $0x0,%edi
  800a49:	eb 11                	jmp    800a5c <strtol+0x3b>
  800a4b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a50:	3c 2d                	cmp    $0x2d,%al
  800a52:	75 08                	jne    800a5c <strtol+0x3b>
		s++, neg = 1;
  800a54:	83 c1 01             	add    $0x1,%ecx
  800a57:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a5c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a62:	75 15                	jne    800a79 <strtol+0x58>
  800a64:	80 39 30             	cmpb   $0x30,(%ecx)
  800a67:	75 10                	jne    800a79 <strtol+0x58>
  800a69:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a6d:	75 7c                	jne    800aeb <strtol+0xca>
		s += 2, base = 16;
  800a6f:	83 c1 02             	add    $0x2,%ecx
  800a72:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a77:	eb 16                	jmp    800a8f <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a79:	85 db                	test   %ebx,%ebx
  800a7b:	75 12                	jne    800a8f <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a7d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a82:	80 39 30             	cmpb   $0x30,(%ecx)
  800a85:	75 08                	jne    800a8f <strtol+0x6e>
		s++, base = 8;
  800a87:	83 c1 01             	add    $0x1,%ecx
  800a8a:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a94:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a97:	0f b6 11             	movzbl (%ecx),%edx
  800a9a:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a9d:	89 f3                	mov    %esi,%ebx
  800a9f:	80 fb 09             	cmp    $0x9,%bl
  800aa2:	77 08                	ja     800aac <strtol+0x8b>
			dig = *s - '0';
  800aa4:	0f be d2             	movsbl %dl,%edx
  800aa7:	83 ea 30             	sub    $0x30,%edx
  800aaa:	eb 22                	jmp    800ace <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800aac:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aaf:	89 f3                	mov    %esi,%ebx
  800ab1:	80 fb 19             	cmp    $0x19,%bl
  800ab4:	77 08                	ja     800abe <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ab6:	0f be d2             	movsbl %dl,%edx
  800ab9:	83 ea 57             	sub    $0x57,%edx
  800abc:	eb 10                	jmp    800ace <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800abe:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ac1:	89 f3                	mov    %esi,%ebx
  800ac3:	80 fb 19             	cmp    $0x19,%bl
  800ac6:	77 16                	ja     800ade <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ac8:	0f be d2             	movsbl %dl,%edx
  800acb:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ace:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ad1:	7d 0b                	jge    800ade <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ad3:	83 c1 01             	add    $0x1,%ecx
  800ad6:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ada:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800adc:	eb b9                	jmp    800a97 <strtol+0x76>

	if (endptr)
  800ade:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ae2:	74 0d                	je     800af1 <strtol+0xd0>
		*endptr = (char *) s;
  800ae4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae7:	89 0e                	mov    %ecx,(%esi)
  800ae9:	eb 06                	jmp    800af1 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aeb:	85 db                	test   %ebx,%ebx
  800aed:	74 98                	je     800a87 <strtol+0x66>
  800aef:	eb 9e                	jmp    800a8f <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800af1:	89 c2                	mov    %eax,%edx
  800af3:	f7 da                	neg    %edx
  800af5:	85 ff                	test   %edi,%edi
  800af7:	0f 45 c2             	cmovne %edx,%eax
}
  800afa:	5b                   	pop    %ebx
  800afb:	5e                   	pop    %esi
  800afc:	5f                   	pop    %edi
  800afd:	5d                   	pop    %ebp
  800afe:	c3                   	ret    

00800aff <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	57                   	push   %edi
  800b03:	56                   	push   %esi
  800b04:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b05:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b10:	89 c3                	mov    %eax,%ebx
  800b12:	89 c7                	mov    %eax,%edi
  800b14:	89 c6                	mov    %eax,%esi
  800b16:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b18:	5b                   	pop    %ebx
  800b19:	5e                   	pop    %esi
  800b1a:	5f                   	pop    %edi
  800b1b:	5d                   	pop    %ebp
  800b1c:	c3                   	ret    

00800b1d <sys_cgetc>:

int
sys_cgetc(void)
{
  800b1d:	55                   	push   %ebp
  800b1e:	89 e5                	mov    %esp,%ebp
  800b20:	57                   	push   %edi
  800b21:	56                   	push   %esi
  800b22:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b23:	ba 00 00 00 00       	mov    $0x0,%edx
  800b28:	b8 01 00 00 00       	mov    $0x1,%eax
  800b2d:	89 d1                	mov    %edx,%ecx
  800b2f:	89 d3                	mov    %edx,%ebx
  800b31:	89 d7                	mov    %edx,%edi
  800b33:	89 d6                	mov    %edx,%esi
  800b35:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b37:	5b                   	pop    %ebx
  800b38:	5e                   	pop    %esi
  800b39:	5f                   	pop    %edi
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	57                   	push   %edi
  800b40:	56                   	push   %esi
  800b41:	53                   	push   %ebx
  800b42:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b45:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b4a:	b8 03 00 00 00       	mov    $0x3,%eax
  800b4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b52:	89 cb                	mov    %ecx,%ebx
  800b54:	89 cf                	mov    %ecx,%edi
  800b56:	89 ce                	mov    %ecx,%esi
  800b58:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b5a:	85 c0                	test   %eax,%eax
  800b5c:	7e 17                	jle    800b75 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5e:	83 ec 0c             	sub    $0xc,%esp
  800b61:	50                   	push   %eax
  800b62:	6a 03                	push   $0x3
  800b64:	68 7f 27 80 00       	push   $0x80277f
  800b69:	6a 23                	push   $0x23
  800b6b:	68 9c 27 80 00       	push   $0x80279c
  800b70:	e8 66 f5 ff ff       	call   8000db <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b78:	5b                   	pop    %ebx
  800b79:	5e                   	pop    %esi
  800b7a:	5f                   	pop    %edi
  800b7b:	5d                   	pop    %ebp
  800b7c:	c3                   	ret    

00800b7d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	57                   	push   %edi
  800b81:	56                   	push   %esi
  800b82:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b83:	ba 00 00 00 00       	mov    $0x0,%edx
  800b88:	b8 02 00 00 00       	mov    $0x2,%eax
  800b8d:	89 d1                	mov    %edx,%ecx
  800b8f:	89 d3                	mov    %edx,%ebx
  800b91:	89 d7                	mov    %edx,%edi
  800b93:	89 d6                	mov    %edx,%esi
  800b95:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b97:	5b                   	pop    %ebx
  800b98:	5e                   	pop    %esi
  800b99:	5f                   	pop    %edi
  800b9a:	5d                   	pop    %ebp
  800b9b:	c3                   	ret    

00800b9c <sys_yield>:

void
sys_yield(void)
{
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	57                   	push   %edi
  800ba0:	56                   	push   %esi
  800ba1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba7:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bac:	89 d1                	mov    %edx,%ecx
  800bae:	89 d3                	mov    %edx,%ebx
  800bb0:	89 d7                	mov    %edx,%edi
  800bb2:	89 d6                	mov    %edx,%esi
  800bb4:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bb6:	5b                   	pop    %ebx
  800bb7:	5e                   	pop    %esi
  800bb8:	5f                   	pop    %edi
  800bb9:	5d                   	pop    %ebp
  800bba:	c3                   	ret    

00800bbb <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	57                   	push   %edi
  800bbf:	56                   	push   %esi
  800bc0:	53                   	push   %ebx
  800bc1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc4:	be 00 00 00 00       	mov    $0x0,%esi
  800bc9:	b8 04 00 00 00       	mov    $0x4,%eax
  800bce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd7:	89 f7                	mov    %esi,%edi
  800bd9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bdb:	85 c0                	test   %eax,%eax
  800bdd:	7e 17                	jle    800bf6 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdf:	83 ec 0c             	sub    $0xc,%esp
  800be2:	50                   	push   %eax
  800be3:	6a 04                	push   $0x4
  800be5:	68 7f 27 80 00       	push   $0x80277f
  800bea:	6a 23                	push   $0x23
  800bec:	68 9c 27 80 00       	push   $0x80279c
  800bf1:	e8 e5 f4 ff ff       	call   8000db <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bf6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf9:	5b                   	pop    %ebx
  800bfa:	5e                   	pop    %esi
  800bfb:	5f                   	pop    %edi
  800bfc:	5d                   	pop    %ebp
  800bfd:	c3                   	ret    

00800bfe <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	57                   	push   %edi
  800c02:	56                   	push   %esi
  800c03:	53                   	push   %ebx
  800c04:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c07:	b8 05 00 00 00       	mov    $0x5,%eax
  800c0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c12:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c15:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c18:	8b 75 18             	mov    0x18(%ebp),%esi
  800c1b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c1d:	85 c0                	test   %eax,%eax
  800c1f:	7e 17                	jle    800c38 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c21:	83 ec 0c             	sub    $0xc,%esp
  800c24:	50                   	push   %eax
  800c25:	6a 05                	push   $0x5
  800c27:	68 7f 27 80 00       	push   $0x80277f
  800c2c:	6a 23                	push   $0x23
  800c2e:	68 9c 27 80 00       	push   $0x80279c
  800c33:	e8 a3 f4 ff ff       	call   8000db <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3b:	5b                   	pop    %ebx
  800c3c:	5e                   	pop    %esi
  800c3d:	5f                   	pop    %edi
  800c3e:	5d                   	pop    %ebp
  800c3f:	c3                   	ret    

00800c40 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	57                   	push   %edi
  800c44:	56                   	push   %esi
  800c45:	53                   	push   %ebx
  800c46:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c49:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4e:	b8 06 00 00 00       	mov    $0x6,%eax
  800c53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c56:	8b 55 08             	mov    0x8(%ebp),%edx
  800c59:	89 df                	mov    %ebx,%edi
  800c5b:	89 de                	mov    %ebx,%esi
  800c5d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c5f:	85 c0                	test   %eax,%eax
  800c61:	7e 17                	jle    800c7a <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c63:	83 ec 0c             	sub    $0xc,%esp
  800c66:	50                   	push   %eax
  800c67:	6a 06                	push   $0x6
  800c69:	68 7f 27 80 00       	push   $0x80277f
  800c6e:	6a 23                	push   $0x23
  800c70:	68 9c 27 80 00       	push   $0x80279c
  800c75:	e8 61 f4 ff ff       	call   8000db <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7d:	5b                   	pop    %ebx
  800c7e:	5e                   	pop    %esi
  800c7f:	5f                   	pop    %edi
  800c80:	5d                   	pop    %ebp
  800c81:	c3                   	ret    

00800c82 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	57                   	push   %edi
  800c86:	56                   	push   %esi
  800c87:	53                   	push   %ebx
  800c88:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c90:	b8 08 00 00 00       	mov    $0x8,%eax
  800c95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c98:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9b:	89 df                	mov    %ebx,%edi
  800c9d:	89 de                	mov    %ebx,%esi
  800c9f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca1:	85 c0                	test   %eax,%eax
  800ca3:	7e 17                	jle    800cbc <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca5:	83 ec 0c             	sub    $0xc,%esp
  800ca8:	50                   	push   %eax
  800ca9:	6a 08                	push   $0x8
  800cab:	68 7f 27 80 00       	push   $0x80277f
  800cb0:	6a 23                	push   $0x23
  800cb2:	68 9c 27 80 00       	push   $0x80279c
  800cb7:	e8 1f f4 ff ff       	call   8000db <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5f                   	pop    %edi
  800cc2:	5d                   	pop    %ebp
  800cc3:	c3                   	ret    

00800cc4 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	57                   	push   %edi
  800cc8:	56                   	push   %esi
  800cc9:	53                   	push   %ebx
  800cca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd2:	b8 09 00 00 00       	mov    $0x9,%eax
  800cd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cda:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdd:	89 df                	mov    %ebx,%edi
  800cdf:	89 de                	mov    %ebx,%esi
  800ce1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	7e 17                	jle    800cfe <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce7:	83 ec 0c             	sub    $0xc,%esp
  800cea:	50                   	push   %eax
  800ceb:	6a 09                	push   $0x9
  800ced:	68 7f 27 80 00       	push   $0x80277f
  800cf2:	6a 23                	push   $0x23
  800cf4:	68 9c 27 80 00       	push   $0x80279c
  800cf9:	e8 dd f3 ff ff       	call   8000db <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	57                   	push   %edi
  800d0a:	56                   	push   %esi
  800d0b:	53                   	push   %ebx
  800d0c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d14:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1f:	89 df                	mov    %ebx,%edi
  800d21:	89 de                	mov    %ebx,%esi
  800d23:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d25:	85 c0                	test   %eax,%eax
  800d27:	7e 17                	jle    800d40 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d29:	83 ec 0c             	sub    $0xc,%esp
  800d2c:	50                   	push   %eax
  800d2d:	6a 0a                	push   $0xa
  800d2f:	68 7f 27 80 00       	push   $0x80277f
  800d34:	6a 23                	push   $0x23
  800d36:	68 9c 27 80 00       	push   $0x80279c
  800d3b:	e8 9b f3 ff ff       	call   8000db <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d43:	5b                   	pop    %ebx
  800d44:	5e                   	pop    %esi
  800d45:	5f                   	pop    %edi
  800d46:	5d                   	pop    %ebp
  800d47:	c3                   	ret    

00800d48 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	57                   	push   %edi
  800d4c:	56                   	push   %esi
  800d4d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4e:	be 00 00 00 00       	mov    $0x0,%esi
  800d53:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d61:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d64:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d66:	5b                   	pop    %ebx
  800d67:	5e                   	pop    %esi
  800d68:	5f                   	pop    %edi
  800d69:	5d                   	pop    %ebp
  800d6a:	c3                   	ret    

00800d6b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	57                   	push   %edi
  800d6f:	56                   	push   %esi
  800d70:	53                   	push   %ebx
  800d71:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d74:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d79:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d81:	89 cb                	mov    %ecx,%ebx
  800d83:	89 cf                	mov    %ecx,%edi
  800d85:	89 ce                	mov    %ecx,%esi
  800d87:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d89:	85 c0                	test   %eax,%eax
  800d8b:	7e 17                	jle    800da4 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8d:	83 ec 0c             	sub    $0xc,%esp
  800d90:	50                   	push   %eax
  800d91:	6a 0d                	push   $0xd
  800d93:	68 7f 27 80 00       	push   $0x80277f
  800d98:	6a 23                	push   $0x23
  800d9a:	68 9c 27 80 00       	push   $0x80279c
  800d9f:	e8 37 f3 ff ff       	call   8000db <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800da4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da7:	5b                   	pop    %ebx
  800da8:	5e                   	pop    %esi
  800da9:	5f                   	pop    %edi
  800daa:	5d                   	pop    %ebp
  800dab:	c3                   	ret    

00800dac <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dac:	55                   	push   %ebp
  800dad:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800daf:	8b 45 08             	mov    0x8(%ebp),%eax
  800db2:	05 00 00 00 30       	add    $0x30000000,%eax
  800db7:	c1 e8 0c             	shr    $0xc,%eax
}
  800dba:	5d                   	pop    %ebp
  800dbb:	c3                   	ret    

00800dbc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800dbc:	55                   	push   %ebp
  800dbd:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800dbf:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc2:	05 00 00 00 30       	add    $0x30000000,%eax
  800dc7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800dcc:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800dd1:	5d                   	pop    %ebp
  800dd2:	c3                   	ret    

00800dd3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800dd3:	55                   	push   %ebp
  800dd4:	89 e5                	mov    %esp,%ebp
  800dd6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dd9:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800dde:	89 c2                	mov    %eax,%edx
  800de0:	c1 ea 16             	shr    $0x16,%edx
  800de3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dea:	f6 c2 01             	test   $0x1,%dl
  800ded:	74 11                	je     800e00 <fd_alloc+0x2d>
  800def:	89 c2                	mov    %eax,%edx
  800df1:	c1 ea 0c             	shr    $0xc,%edx
  800df4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dfb:	f6 c2 01             	test   $0x1,%dl
  800dfe:	75 09                	jne    800e09 <fd_alloc+0x36>
			*fd_store = fd;
  800e00:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e02:	b8 00 00 00 00       	mov    $0x0,%eax
  800e07:	eb 17                	jmp    800e20 <fd_alloc+0x4d>
  800e09:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e0e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e13:	75 c9                	jne    800dde <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e15:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e1b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e20:	5d                   	pop    %ebp
  800e21:	c3                   	ret    

00800e22 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e22:	55                   	push   %ebp
  800e23:	89 e5                	mov    %esp,%ebp
  800e25:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e28:	83 f8 1f             	cmp    $0x1f,%eax
  800e2b:	77 36                	ja     800e63 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e2d:	c1 e0 0c             	shl    $0xc,%eax
  800e30:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e35:	89 c2                	mov    %eax,%edx
  800e37:	c1 ea 16             	shr    $0x16,%edx
  800e3a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e41:	f6 c2 01             	test   $0x1,%dl
  800e44:	74 24                	je     800e6a <fd_lookup+0x48>
  800e46:	89 c2                	mov    %eax,%edx
  800e48:	c1 ea 0c             	shr    $0xc,%edx
  800e4b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e52:	f6 c2 01             	test   $0x1,%dl
  800e55:	74 1a                	je     800e71 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e57:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e5a:	89 02                	mov    %eax,(%edx)
	return 0;
  800e5c:	b8 00 00 00 00       	mov    $0x0,%eax
  800e61:	eb 13                	jmp    800e76 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e63:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e68:	eb 0c                	jmp    800e76 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e6a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e6f:	eb 05                	jmp    800e76 <fd_lookup+0x54>
  800e71:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e76:	5d                   	pop    %ebp
  800e77:	c3                   	ret    

00800e78 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e78:	55                   	push   %ebp
  800e79:	89 e5                	mov    %esp,%ebp
  800e7b:	83 ec 08             	sub    $0x8,%esp
  800e7e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e81:	ba 28 28 80 00       	mov    $0x802828,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e86:	eb 13                	jmp    800e9b <dev_lookup+0x23>
  800e88:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e8b:	39 08                	cmp    %ecx,(%eax)
  800e8d:	75 0c                	jne    800e9b <dev_lookup+0x23>
			*dev = devtab[i];
  800e8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e92:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e94:	b8 00 00 00 00       	mov    $0x0,%eax
  800e99:	eb 2e                	jmp    800ec9 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e9b:	8b 02                	mov    (%edx),%eax
  800e9d:	85 c0                	test   %eax,%eax
  800e9f:	75 e7                	jne    800e88 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ea1:	a1 04 40 80 00       	mov    0x804004,%eax
  800ea6:	8b 40 48             	mov    0x48(%eax),%eax
  800ea9:	83 ec 04             	sub    $0x4,%esp
  800eac:	51                   	push   %ecx
  800ead:	50                   	push   %eax
  800eae:	68 ac 27 80 00       	push   $0x8027ac
  800eb3:	e8 fc f2 ff ff       	call   8001b4 <cprintf>
	*dev = 0;
  800eb8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ebb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800ec1:	83 c4 10             	add    $0x10,%esp
  800ec4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ec9:	c9                   	leave  
  800eca:	c3                   	ret    

00800ecb <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800ecb:	55                   	push   %ebp
  800ecc:	89 e5                	mov    %esp,%ebp
  800ece:	56                   	push   %esi
  800ecf:	53                   	push   %ebx
  800ed0:	83 ec 10             	sub    $0x10,%esp
  800ed3:	8b 75 08             	mov    0x8(%ebp),%esi
  800ed6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ed9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800edc:	50                   	push   %eax
  800edd:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800ee3:	c1 e8 0c             	shr    $0xc,%eax
  800ee6:	50                   	push   %eax
  800ee7:	e8 36 ff ff ff       	call   800e22 <fd_lookup>
  800eec:	83 c4 08             	add    $0x8,%esp
  800eef:	85 c0                	test   %eax,%eax
  800ef1:	78 05                	js     800ef8 <fd_close+0x2d>
	    || fd != fd2)
  800ef3:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ef6:	74 0c                	je     800f04 <fd_close+0x39>
		return (must_exist ? r : 0);
  800ef8:	84 db                	test   %bl,%bl
  800efa:	ba 00 00 00 00       	mov    $0x0,%edx
  800eff:	0f 44 c2             	cmove  %edx,%eax
  800f02:	eb 41                	jmp    800f45 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f04:	83 ec 08             	sub    $0x8,%esp
  800f07:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f0a:	50                   	push   %eax
  800f0b:	ff 36                	pushl  (%esi)
  800f0d:	e8 66 ff ff ff       	call   800e78 <dev_lookup>
  800f12:	89 c3                	mov    %eax,%ebx
  800f14:	83 c4 10             	add    $0x10,%esp
  800f17:	85 c0                	test   %eax,%eax
  800f19:	78 1a                	js     800f35 <fd_close+0x6a>
		if (dev->dev_close)
  800f1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f1e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f21:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f26:	85 c0                	test   %eax,%eax
  800f28:	74 0b                	je     800f35 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f2a:	83 ec 0c             	sub    $0xc,%esp
  800f2d:	56                   	push   %esi
  800f2e:	ff d0                	call   *%eax
  800f30:	89 c3                	mov    %eax,%ebx
  800f32:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f35:	83 ec 08             	sub    $0x8,%esp
  800f38:	56                   	push   %esi
  800f39:	6a 00                	push   $0x0
  800f3b:	e8 00 fd ff ff       	call   800c40 <sys_page_unmap>
	return r;
  800f40:	83 c4 10             	add    $0x10,%esp
  800f43:	89 d8                	mov    %ebx,%eax
}
  800f45:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f48:	5b                   	pop    %ebx
  800f49:	5e                   	pop    %esi
  800f4a:	5d                   	pop    %ebp
  800f4b:	c3                   	ret    

00800f4c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f4c:	55                   	push   %ebp
  800f4d:	89 e5                	mov    %esp,%ebp
  800f4f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f52:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f55:	50                   	push   %eax
  800f56:	ff 75 08             	pushl  0x8(%ebp)
  800f59:	e8 c4 fe ff ff       	call   800e22 <fd_lookup>
  800f5e:	83 c4 08             	add    $0x8,%esp
  800f61:	85 c0                	test   %eax,%eax
  800f63:	78 10                	js     800f75 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f65:	83 ec 08             	sub    $0x8,%esp
  800f68:	6a 01                	push   $0x1
  800f6a:	ff 75 f4             	pushl  -0xc(%ebp)
  800f6d:	e8 59 ff ff ff       	call   800ecb <fd_close>
  800f72:	83 c4 10             	add    $0x10,%esp
}
  800f75:	c9                   	leave  
  800f76:	c3                   	ret    

00800f77 <close_all>:

void
close_all(void)
{
  800f77:	55                   	push   %ebp
  800f78:	89 e5                	mov    %esp,%ebp
  800f7a:	53                   	push   %ebx
  800f7b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f7e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f83:	83 ec 0c             	sub    $0xc,%esp
  800f86:	53                   	push   %ebx
  800f87:	e8 c0 ff ff ff       	call   800f4c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f8c:	83 c3 01             	add    $0x1,%ebx
  800f8f:	83 c4 10             	add    $0x10,%esp
  800f92:	83 fb 20             	cmp    $0x20,%ebx
  800f95:	75 ec                	jne    800f83 <close_all+0xc>
		close(i);
}
  800f97:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f9a:	c9                   	leave  
  800f9b:	c3                   	ret    

00800f9c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f9c:	55                   	push   %ebp
  800f9d:	89 e5                	mov    %esp,%ebp
  800f9f:	57                   	push   %edi
  800fa0:	56                   	push   %esi
  800fa1:	53                   	push   %ebx
  800fa2:	83 ec 2c             	sub    $0x2c,%esp
  800fa5:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fa8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fab:	50                   	push   %eax
  800fac:	ff 75 08             	pushl  0x8(%ebp)
  800faf:	e8 6e fe ff ff       	call   800e22 <fd_lookup>
  800fb4:	83 c4 08             	add    $0x8,%esp
  800fb7:	85 c0                	test   %eax,%eax
  800fb9:	0f 88 c1 00 00 00    	js     801080 <dup+0xe4>
		return r;
	close(newfdnum);
  800fbf:	83 ec 0c             	sub    $0xc,%esp
  800fc2:	56                   	push   %esi
  800fc3:	e8 84 ff ff ff       	call   800f4c <close>

	newfd = INDEX2FD(newfdnum);
  800fc8:	89 f3                	mov    %esi,%ebx
  800fca:	c1 e3 0c             	shl    $0xc,%ebx
  800fcd:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800fd3:	83 c4 04             	add    $0x4,%esp
  800fd6:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fd9:	e8 de fd ff ff       	call   800dbc <fd2data>
  800fde:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800fe0:	89 1c 24             	mov    %ebx,(%esp)
  800fe3:	e8 d4 fd ff ff       	call   800dbc <fd2data>
  800fe8:	83 c4 10             	add    $0x10,%esp
  800feb:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fee:	89 f8                	mov    %edi,%eax
  800ff0:	c1 e8 16             	shr    $0x16,%eax
  800ff3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ffa:	a8 01                	test   $0x1,%al
  800ffc:	74 37                	je     801035 <dup+0x99>
  800ffe:	89 f8                	mov    %edi,%eax
  801000:	c1 e8 0c             	shr    $0xc,%eax
  801003:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80100a:	f6 c2 01             	test   $0x1,%dl
  80100d:	74 26                	je     801035 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80100f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801016:	83 ec 0c             	sub    $0xc,%esp
  801019:	25 07 0e 00 00       	and    $0xe07,%eax
  80101e:	50                   	push   %eax
  80101f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801022:	6a 00                	push   $0x0
  801024:	57                   	push   %edi
  801025:	6a 00                	push   $0x0
  801027:	e8 d2 fb ff ff       	call   800bfe <sys_page_map>
  80102c:	89 c7                	mov    %eax,%edi
  80102e:	83 c4 20             	add    $0x20,%esp
  801031:	85 c0                	test   %eax,%eax
  801033:	78 2e                	js     801063 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801035:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801038:	89 d0                	mov    %edx,%eax
  80103a:	c1 e8 0c             	shr    $0xc,%eax
  80103d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801044:	83 ec 0c             	sub    $0xc,%esp
  801047:	25 07 0e 00 00       	and    $0xe07,%eax
  80104c:	50                   	push   %eax
  80104d:	53                   	push   %ebx
  80104e:	6a 00                	push   $0x0
  801050:	52                   	push   %edx
  801051:	6a 00                	push   $0x0
  801053:	e8 a6 fb ff ff       	call   800bfe <sys_page_map>
  801058:	89 c7                	mov    %eax,%edi
  80105a:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80105d:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80105f:	85 ff                	test   %edi,%edi
  801061:	79 1d                	jns    801080 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801063:	83 ec 08             	sub    $0x8,%esp
  801066:	53                   	push   %ebx
  801067:	6a 00                	push   $0x0
  801069:	e8 d2 fb ff ff       	call   800c40 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80106e:	83 c4 08             	add    $0x8,%esp
  801071:	ff 75 d4             	pushl  -0x2c(%ebp)
  801074:	6a 00                	push   $0x0
  801076:	e8 c5 fb ff ff       	call   800c40 <sys_page_unmap>
	return r;
  80107b:	83 c4 10             	add    $0x10,%esp
  80107e:	89 f8                	mov    %edi,%eax
}
  801080:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801083:	5b                   	pop    %ebx
  801084:	5e                   	pop    %esi
  801085:	5f                   	pop    %edi
  801086:	5d                   	pop    %ebp
  801087:	c3                   	ret    

00801088 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801088:	55                   	push   %ebp
  801089:	89 e5                	mov    %esp,%ebp
  80108b:	53                   	push   %ebx
  80108c:	83 ec 14             	sub    $0x14,%esp
  80108f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801092:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801095:	50                   	push   %eax
  801096:	53                   	push   %ebx
  801097:	e8 86 fd ff ff       	call   800e22 <fd_lookup>
  80109c:	83 c4 08             	add    $0x8,%esp
  80109f:	89 c2                	mov    %eax,%edx
  8010a1:	85 c0                	test   %eax,%eax
  8010a3:	78 6d                	js     801112 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010a5:	83 ec 08             	sub    $0x8,%esp
  8010a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010ab:	50                   	push   %eax
  8010ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010af:	ff 30                	pushl  (%eax)
  8010b1:	e8 c2 fd ff ff       	call   800e78 <dev_lookup>
  8010b6:	83 c4 10             	add    $0x10,%esp
  8010b9:	85 c0                	test   %eax,%eax
  8010bb:	78 4c                	js     801109 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010bd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010c0:	8b 42 08             	mov    0x8(%edx),%eax
  8010c3:	83 e0 03             	and    $0x3,%eax
  8010c6:	83 f8 01             	cmp    $0x1,%eax
  8010c9:	75 21                	jne    8010ec <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010cb:	a1 04 40 80 00       	mov    0x804004,%eax
  8010d0:	8b 40 48             	mov    0x48(%eax),%eax
  8010d3:	83 ec 04             	sub    $0x4,%esp
  8010d6:	53                   	push   %ebx
  8010d7:	50                   	push   %eax
  8010d8:	68 ed 27 80 00       	push   $0x8027ed
  8010dd:	e8 d2 f0 ff ff       	call   8001b4 <cprintf>
		return -E_INVAL;
  8010e2:	83 c4 10             	add    $0x10,%esp
  8010e5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010ea:	eb 26                	jmp    801112 <read+0x8a>
	}
	if (!dev->dev_read)
  8010ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010ef:	8b 40 08             	mov    0x8(%eax),%eax
  8010f2:	85 c0                	test   %eax,%eax
  8010f4:	74 17                	je     80110d <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010f6:	83 ec 04             	sub    $0x4,%esp
  8010f9:	ff 75 10             	pushl  0x10(%ebp)
  8010fc:	ff 75 0c             	pushl  0xc(%ebp)
  8010ff:	52                   	push   %edx
  801100:	ff d0                	call   *%eax
  801102:	89 c2                	mov    %eax,%edx
  801104:	83 c4 10             	add    $0x10,%esp
  801107:	eb 09                	jmp    801112 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801109:	89 c2                	mov    %eax,%edx
  80110b:	eb 05                	jmp    801112 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80110d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801112:	89 d0                	mov    %edx,%eax
  801114:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801117:	c9                   	leave  
  801118:	c3                   	ret    

00801119 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801119:	55                   	push   %ebp
  80111a:	89 e5                	mov    %esp,%ebp
  80111c:	57                   	push   %edi
  80111d:	56                   	push   %esi
  80111e:	53                   	push   %ebx
  80111f:	83 ec 0c             	sub    $0xc,%esp
  801122:	8b 7d 08             	mov    0x8(%ebp),%edi
  801125:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801128:	bb 00 00 00 00       	mov    $0x0,%ebx
  80112d:	eb 21                	jmp    801150 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80112f:	83 ec 04             	sub    $0x4,%esp
  801132:	89 f0                	mov    %esi,%eax
  801134:	29 d8                	sub    %ebx,%eax
  801136:	50                   	push   %eax
  801137:	89 d8                	mov    %ebx,%eax
  801139:	03 45 0c             	add    0xc(%ebp),%eax
  80113c:	50                   	push   %eax
  80113d:	57                   	push   %edi
  80113e:	e8 45 ff ff ff       	call   801088 <read>
		if (m < 0)
  801143:	83 c4 10             	add    $0x10,%esp
  801146:	85 c0                	test   %eax,%eax
  801148:	78 10                	js     80115a <readn+0x41>
			return m;
		if (m == 0)
  80114a:	85 c0                	test   %eax,%eax
  80114c:	74 0a                	je     801158 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80114e:	01 c3                	add    %eax,%ebx
  801150:	39 f3                	cmp    %esi,%ebx
  801152:	72 db                	jb     80112f <readn+0x16>
  801154:	89 d8                	mov    %ebx,%eax
  801156:	eb 02                	jmp    80115a <readn+0x41>
  801158:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80115a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80115d:	5b                   	pop    %ebx
  80115e:	5e                   	pop    %esi
  80115f:	5f                   	pop    %edi
  801160:	5d                   	pop    %ebp
  801161:	c3                   	ret    

00801162 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801162:	55                   	push   %ebp
  801163:	89 e5                	mov    %esp,%ebp
  801165:	53                   	push   %ebx
  801166:	83 ec 14             	sub    $0x14,%esp
  801169:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80116c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80116f:	50                   	push   %eax
  801170:	53                   	push   %ebx
  801171:	e8 ac fc ff ff       	call   800e22 <fd_lookup>
  801176:	83 c4 08             	add    $0x8,%esp
  801179:	89 c2                	mov    %eax,%edx
  80117b:	85 c0                	test   %eax,%eax
  80117d:	78 68                	js     8011e7 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80117f:	83 ec 08             	sub    $0x8,%esp
  801182:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801185:	50                   	push   %eax
  801186:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801189:	ff 30                	pushl  (%eax)
  80118b:	e8 e8 fc ff ff       	call   800e78 <dev_lookup>
  801190:	83 c4 10             	add    $0x10,%esp
  801193:	85 c0                	test   %eax,%eax
  801195:	78 47                	js     8011de <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801197:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80119a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80119e:	75 21                	jne    8011c1 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011a0:	a1 04 40 80 00       	mov    0x804004,%eax
  8011a5:	8b 40 48             	mov    0x48(%eax),%eax
  8011a8:	83 ec 04             	sub    $0x4,%esp
  8011ab:	53                   	push   %ebx
  8011ac:	50                   	push   %eax
  8011ad:	68 09 28 80 00       	push   $0x802809
  8011b2:	e8 fd ef ff ff       	call   8001b4 <cprintf>
		return -E_INVAL;
  8011b7:	83 c4 10             	add    $0x10,%esp
  8011ba:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011bf:	eb 26                	jmp    8011e7 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011c4:	8b 52 0c             	mov    0xc(%edx),%edx
  8011c7:	85 d2                	test   %edx,%edx
  8011c9:	74 17                	je     8011e2 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011cb:	83 ec 04             	sub    $0x4,%esp
  8011ce:	ff 75 10             	pushl  0x10(%ebp)
  8011d1:	ff 75 0c             	pushl  0xc(%ebp)
  8011d4:	50                   	push   %eax
  8011d5:	ff d2                	call   *%edx
  8011d7:	89 c2                	mov    %eax,%edx
  8011d9:	83 c4 10             	add    $0x10,%esp
  8011dc:	eb 09                	jmp    8011e7 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011de:	89 c2                	mov    %eax,%edx
  8011e0:	eb 05                	jmp    8011e7 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8011e2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8011e7:	89 d0                	mov    %edx,%eax
  8011e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011ec:	c9                   	leave  
  8011ed:	c3                   	ret    

008011ee <seek>:

int
seek(int fdnum, off_t offset)
{
  8011ee:	55                   	push   %ebp
  8011ef:	89 e5                	mov    %esp,%ebp
  8011f1:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011f4:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011f7:	50                   	push   %eax
  8011f8:	ff 75 08             	pushl  0x8(%ebp)
  8011fb:	e8 22 fc ff ff       	call   800e22 <fd_lookup>
  801200:	83 c4 08             	add    $0x8,%esp
  801203:	85 c0                	test   %eax,%eax
  801205:	78 0e                	js     801215 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801207:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80120a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80120d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801210:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801215:	c9                   	leave  
  801216:	c3                   	ret    

00801217 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801217:	55                   	push   %ebp
  801218:	89 e5                	mov    %esp,%ebp
  80121a:	53                   	push   %ebx
  80121b:	83 ec 14             	sub    $0x14,%esp
  80121e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801221:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801224:	50                   	push   %eax
  801225:	53                   	push   %ebx
  801226:	e8 f7 fb ff ff       	call   800e22 <fd_lookup>
  80122b:	83 c4 08             	add    $0x8,%esp
  80122e:	89 c2                	mov    %eax,%edx
  801230:	85 c0                	test   %eax,%eax
  801232:	78 65                	js     801299 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801234:	83 ec 08             	sub    $0x8,%esp
  801237:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80123a:	50                   	push   %eax
  80123b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80123e:	ff 30                	pushl  (%eax)
  801240:	e8 33 fc ff ff       	call   800e78 <dev_lookup>
  801245:	83 c4 10             	add    $0x10,%esp
  801248:	85 c0                	test   %eax,%eax
  80124a:	78 44                	js     801290 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80124c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80124f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801253:	75 21                	jne    801276 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801255:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80125a:	8b 40 48             	mov    0x48(%eax),%eax
  80125d:	83 ec 04             	sub    $0x4,%esp
  801260:	53                   	push   %ebx
  801261:	50                   	push   %eax
  801262:	68 cc 27 80 00       	push   $0x8027cc
  801267:	e8 48 ef ff ff       	call   8001b4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80126c:	83 c4 10             	add    $0x10,%esp
  80126f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801274:	eb 23                	jmp    801299 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801276:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801279:	8b 52 18             	mov    0x18(%edx),%edx
  80127c:	85 d2                	test   %edx,%edx
  80127e:	74 14                	je     801294 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801280:	83 ec 08             	sub    $0x8,%esp
  801283:	ff 75 0c             	pushl  0xc(%ebp)
  801286:	50                   	push   %eax
  801287:	ff d2                	call   *%edx
  801289:	89 c2                	mov    %eax,%edx
  80128b:	83 c4 10             	add    $0x10,%esp
  80128e:	eb 09                	jmp    801299 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801290:	89 c2                	mov    %eax,%edx
  801292:	eb 05                	jmp    801299 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801294:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801299:	89 d0                	mov    %edx,%eax
  80129b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80129e:	c9                   	leave  
  80129f:	c3                   	ret    

008012a0 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012a0:	55                   	push   %ebp
  8012a1:	89 e5                	mov    %esp,%ebp
  8012a3:	53                   	push   %ebx
  8012a4:	83 ec 14             	sub    $0x14,%esp
  8012a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ad:	50                   	push   %eax
  8012ae:	ff 75 08             	pushl  0x8(%ebp)
  8012b1:	e8 6c fb ff ff       	call   800e22 <fd_lookup>
  8012b6:	83 c4 08             	add    $0x8,%esp
  8012b9:	89 c2                	mov    %eax,%edx
  8012bb:	85 c0                	test   %eax,%eax
  8012bd:	78 58                	js     801317 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012bf:	83 ec 08             	sub    $0x8,%esp
  8012c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c5:	50                   	push   %eax
  8012c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c9:	ff 30                	pushl  (%eax)
  8012cb:	e8 a8 fb ff ff       	call   800e78 <dev_lookup>
  8012d0:	83 c4 10             	add    $0x10,%esp
  8012d3:	85 c0                	test   %eax,%eax
  8012d5:	78 37                	js     80130e <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8012d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012da:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012de:	74 32                	je     801312 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012e0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012e3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012ea:	00 00 00 
	stat->st_isdir = 0;
  8012ed:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012f4:	00 00 00 
	stat->st_dev = dev;
  8012f7:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012fd:	83 ec 08             	sub    $0x8,%esp
  801300:	53                   	push   %ebx
  801301:	ff 75 f0             	pushl  -0x10(%ebp)
  801304:	ff 50 14             	call   *0x14(%eax)
  801307:	89 c2                	mov    %eax,%edx
  801309:	83 c4 10             	add    $0x10,%esp
  80130c:	eb 09                	jmp    801317 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80130e:	89 c2                	mov    %eax,%edx
  801310:	eb 05                	jmp    801317 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801312:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801317:	89 d0                	mov    %edx,%eax
  801319:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80131c:	c9                   	leave  
  80131d:	c3                   	ret    

0080131e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80131e:	55                   	push   %ebp
  80131f:	89 e5                	mov    %esp,%ebp
  801321:	56                   	push   %esi
  801322:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801323:	83 ec 08             	sub    $0x8,%esp
  801326:	6a 00                	push   $0x0
  801328:	ff 75 08             	pushl  0x8(%ebp)
  80132b:	e8 e3 01 00 00       	call   801513 <open>
  801330:	89 c3                	mov    %eax,%ebx
  801332:	83 c4 10             	add    $0x10,%esp
  801335:	85 c0                	test   %eax,%eax
  801337:	78 1b                	js     801354 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801339:	83 ec 08             	sub    $0x8,%esp
  80133c:	ff 75 0c             	pushl  0xc(%ebp)
  80133f:	50                   	push   %eax
  801340:	e8 5b ff ff ff       	call   8012a0 <fstat>
  801345:	89 c6                	mov    %eax,%esi
	close(fd);
  801347:	89 1c 24             	mov    %ebx,(%esp)
  80134a:	e8 fd fb ff ff       	call   800f4c <close>
	return r;
  80134f:	83 c4 10             	add    $0x10,%esp
  801352:	89 f0                	mov    %esi,%eax
}
  801354:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801357:	5b                   	pop    %ebx
  801358:	5e                   	pop    %esi
  801359:	5d                   	pop    %ebp
  80135a:	c3                   	ret    

0080135b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80135b:	55                   	push   %ebp
  80135c:	89 e5                	mov    %esp,%ebp
  80135e:	56                   	push   %esi
  80135f:	53                   	push   %ebx
  801360:	89 c6                	mov    %eax,%esi
  801362:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801364:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80136b:	75 12                	jne    80137f <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80136d:	83 ec 0c             	sub    $0xc,%esp
  801370:	6a 01                	push   $0x1
  801372:	e8 81 0d 00 00       	call   8020f8 <ipc_find_env>
  801377:	a3 00 40 80 00       	mov    %eax,0x804000
  80137c:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80137f:	6a 07                	push   $0x7
  801381:	68 00 50 80 00       	push   $0x805000
  801386:	56                   	push   %esi
  801387:	ff 35 00 40 80 00    	pushl  0x804000
  80138d:	e8 12 0d 00 00       	call   8020a4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801392:	83 c4 0c             	add    $0xc,%esp
  801395:	6a 00                	push   $0x0
  801397:	53                   	push   %ebx
  801398:	6a 00                	push   $0x0
  80139a:	e8 93 0c 00 00       	call   802032 <ipc_recv>
}
  80139f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013a2:	5b                   	pop    %ebx
  8013a3:	5e                   	pop    %esi
  8013a4:	5d                   	pop    %ebp
  8013a5:	c3                   	ret    

008013a6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013a6:	55                   	push   %ebp
  8013a7:	89 e5                	mov    %esp,%ebp
  8013a9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8013af:	8b 40 0c             	mov    0xc(%eax),%eax
  8013b2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013ba:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8013c4:	b8 02 00 00 00       	mov    $0x2,%eax
  8013c9:	e8 8d ff ff ff       	call   80135b <fsipc>
}
  8013ce:	c9                   	leave  
  8013cf:	c3                   	ret    

008013d0 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8013d0:	55                   	push   %ebp
  8013d1:	89 e5                	mov    %esp,%ebp
  8013d3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d9:	8b 40 0c             	mov    0xc(%eax),%eax
  8013dc:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8013e6:	b8 06 00 00 00       	mov    $0x6,%eax
  8013eb:	e8 6b ff ff ff       	call   80135b <fsipc>
}
  8013f0:	c9                   	leave  
  8013f1:	c3                   	ret    

008013f2 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013f2:	55                   	push   %ebp
  8013f3:	89 e5                	mov    %esp,%ebp
  8013f5:	53                   	push   %ebx
  8013f6:	83 ec 04             	sub    $0x4,%esp
  8013f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ff:	8b 40 0c             	mov    0xc(%eax),%eax
  801402:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801407:	ba 00 00 00 00       	mov    $0x0,%edx
  80140c:	b8 05 00 00 00       	mov    $0x5,%eax
  801411:	e8 45 ff ff ff       	call   80135b <fsipc>
  801416:	85 c0                	test   %eax,%eax
  801418:	78 2c                	js     801446 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80141a:	83 ec 08             	sub    $0x8,%esp
  80141d:	68 00 50 80 00       	push   $0x805000
  801422:	53                   	push   %ebx
  801423:	e8 90 f3 ff ff       	call   8007b8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801428:	a1 80 50 80 00       	mov    0x805080,%eax
  80142d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801433:	a1 84 50 80 00       	mov    0x805084,%eax
  801438:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80143e:	83 c4 10             	add    $0x10,%esp
  801441:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801446:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801449:	c9                   	leave  
  80144a:	c3                   	ret    

0080144b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80144b:	55                   	push   %ebp
  80144c:	89 e5                	mov    %esp,%ebp
  80144e:	83 ec 0c             	sub    $0xc,%esp
  801451:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	
	int r;

	n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801454:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801459:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80145e:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801461:	8b 55 08             	mov    0x8(%ebp),%edx
  801464:	8b 52 0c             	mov    0xc(%edx),%edx
  801467:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80146d:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801472:	50                   	push   %eax
  801473:	ff 75 0c             	pushl  0xc(%ebp)
  801476:	68 08 50 80 00       	push   $0x805008
  80147b:	e8 ca f4 ff ff       	call   80094a <memmove>
	
	return fsipc(FSREQ_WRITE, NULL);	
  801480:	ba 00 00 00 00       	mov    $0x0,%edx
  801485:	b8 04 00 00 00       	mov    $0x4,%eax
  80148a:	e8 cc fe ff ff       	call   80135b <fsipc>
}
  80148f:	c9                   	leave  
  801490:	c3                   	ret    

00801491 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801491:	55                   	push   %ebp
  801492:	89 e5                	mov    %esp,%ebp
  801494:	56                   	push   %esi
  801495:	53                   	push   %ebx
  801496:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801499:	8b 45 08             	mov    0x8(%ebp),%eax
  80149c:	8b 40 0c             	mov    0xc(%eax),%eax
  80149f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014a4:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8014af:	b8 03 00 00 00       	mov    $0x3,%eax
  8014b4:	e8 a2 fe ff ff       	call   80135b <fsipc>
  8014b9:	89 c3                	mov    %eax,%ebx
  8014bb:	85 c0                	test   %eax,%eax
  8014bd:	78 4b                	js     80150a <devfile_read+0x79>
		return r;
	assert(r <= n);
  8014bf:	39 c6                	cmp    %eax,%esi
  8014c1:	73 16                	jae    8014d9 <devfile_read+0x48>
  8014c3:	68 38 28 80 00       	push   $0x802838
  8014c8:	68 3f 28 80 00       	push   $0x80283f
  8014cd:	6a 7c                	push   $0x7c
  8014cf:	68 54 28 80 00       	push   $0x802854
  8014d4:	e8 02 ec ff ff       	call   8000db <_panic>
	assert(r <= PGSIZE);
  8014d9:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014de:	7e 16                	jle    8014f6 <devfile_read+0x65>
  8014e0:	68 5f 28 80 00       	push   $0x80285f
  8014e5:	68 3f 28 80 00       	push   $0x80283f
  8014ea:	6a 7d                	push   $0x7d
  8014ec:	68 54 28 80 00       	push   $0x802854
  8014f1:	e8 e5 eb ff ff       	call   8000db <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014f6:	83 ec 04             	sub    $0x4,%esp
  8014f9:	50                   	push   %eax
  8014fa:	68 00 50 80 00       	push   $0x805000
  8014ff:	ff 75 0c             	pushl  0xc(%ebp)
  801502:	e8 43 f4 ff ff       	call   80094a <memmove>
	return r;
  801507:	83 c4 10             	add    $0x10,%esp
}
  80150a:	89 d8                	mov    %ebx,%eax
  80150c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80150f:	5b                   	pop    %ebx
  801510:	5e                   	pop    %esi
  801511:	5d                   	pop    %ebp
  801512:	c3                   	ret    

00801513 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801513:	55                   	push   %ebp
  801514:	89 e5                	mov    %esp,%ebp
  801516:	53                   	push   %ebx
  801517:	83 ec 20             	sub    $0x20,%esp
  80151a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80151d:	53                   	push   %ebx
  80151e:	e8 5c f2 ff ff       	call   80077f <strlen>
  801523:	83 c4 10             	add    $0x10,%esp
  801526:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80152b:	7f 67                	jg     801594 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80152d:	83 ec 0c             	sub    $0xc,%esp
  801530:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801533:	50                   	push   %eax
  801534:	e8 9a f8 ff ff       	call   800dd3 <fd_alloc>
  801539:	83 c4 10             	add    $0x10,%esp
		return r;
  80153c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80153e:	85 c0                	test   %eax,%eax
  801540:	78 57                	js     801599 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801542:	83 ec 08             	sub    $0x8,%esp
  801545:	53                   	push   %ebx
  801546:	68 00 50 80 00       	push   $0x805000
  80154b:	e8 68 f2 ff ff       	call   8007b8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801550:	8b 45 0c             	mov    0xc(%ebp),%eax
  801553:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801558:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80155b:	b8 01 00 00 00       	mov    $0x1,%eax
  801560:	e8 f6 fd ff ff       	call   80135b <fsipc>
  801565:	89 c3                	mov    %eax,%ebx
  801567:	83 c4 10             	add    $0x10,%esp
  80156a:	85 c0                	test   %eax,%eax
  80156c:	79 14                	jns    801582 <open+0x6f>
		fd_close(fd, 0);
  80156e:	83 ec 08             	sub    $0x8,%esp
  801571:	6a 00                	push   $0x0
  801573:	ff 75 f4             	pushl  -0xc(%ebp)
  801576:	e8 50 f9 ff ff       	call   800ecb <fd_close>
		return r;
  80157b:	83 c4 10             	add    $0x10,%esp
  80157e:	89 da                	mov    %ebx,%edx
  801580:	eb 17                	jmp    801599 <open+0x86>
	}

	return fd2num(fd);
  801582:	83 ec 0c             	sub    $0xc,%esp
  801585:	ff 75 f4             	pushl  -0xc(%ebp)
  801588:	e8 1f f8 ff ff       	call   800dac <fd2num>
  80158d:	89 c2                	mov    %eax,%edx
  80158f:	83 c4 10             	add    $0x10,%esp
  801592:	eb 05                	jmp    801599 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801594:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801599:	89 d0                	mov    %edx,%eax
  80159b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80159e:	c9                   	leave  
  80159f:	c3                   	ret    

008015a0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015a0:	55                   	push   %ebp
  8015a1:	89 e5                	mov    %esp,%ebp
  8015a3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ab:	b8 08 00 00 00       	mov    $0x8,%eax
  8015b0:	e8 a6 fd ff ff       	call   80135b <fsipc>
}
  8015b5:	c9                   	leave  
  8015b6:	c3                   	ret    

008015b7 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8015b7:	55                   	push   %ebp
  8015b8:	89 e5                	mov    %esp,%ebp
  8015ba:	57                   	push   %edi
  8015bb:	56                   	push   %esi
  8015bc:	53                   	push   %ebx
  8015bd:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8015c3:	6a 00                	push   $0x0
  8015c5:	ff 75 08             	pushl  0x8(%ebp)
  8015c8:	e8 46 ff ff ff       	call   801513 <open>
  8015cd:	89 c7                	mov    %eax,%edi
  8015cf:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8015d5:	83 c4 10             	add    $0x10,%esp
  8015d8:	85 c0                	test   %eax,%eax
  8015da:	0f 88 96 04 00 00    	js     801a76 <spawn+0x4bf>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8015e0:	83 ec 04             	sub    $0x4,%esp
  8015e3:	68 00 02 00 00       	push   $0x200
  8015e8:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8015ee:	50                   	push   %eax
  8015ef:	57                   	push   %edi
  8015f0:	e8 24 fb ff ff       	call   801119 <readn>
  8015f5:	83 c4 10             	add    $0x10,%esp
  8015f8:	3d 00 02 00 00       	cmp    $0x200,%eax
  8015fd:	75 0c                	jne    80160b <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8015ff:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801606:	45 4c 46 
  801609:	74 33                	je     80163e <spawn+0x87>
		close(fd);
  80160b:	83 ec 0c             	sub    $0xc,%esp
  80160e:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801614:	e8 33 f9 ff ff       	call   800f4c <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801619:	83 c4 0c             	add    $0xc,%esp
  80161c:	68 7f 45 4c 46       	push   $0x464c457f
  801621:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801627:	68 6b 28 80 00       	push   $0x80286b
  80162c:	e8 83 eb ff ff       	call   8001b4 <cprintf>
		return -E_NOT_EXEC;
  801631:	83 c4 10             	add    $0x10,%esp
  801634:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801639:	e9 98 04 00 00       	jmp    801ad6 <spawn+0x51f>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80163e:	b8 07 00 00 00       	mov    $0x7,%eax
  801643:	cd 30                	int    $0x30
  801645:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  80164b:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801651:	85 c0                	test   %eax,%eax
  801653:	0f 88 25 04 00 00    	js     801a7e <spawn+0x4c7>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801659:	89 c6                	mov    %eax,%esi
  80165b:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801661:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801664:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  80166a:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801670:	b9 11 00 00 00       	mov    $0x11,%ecx
  801675:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801677:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  80167d:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801683:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801688:	be 00 00 00 00       	mov    $0x0,%esi
  80168d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801690:	eb 13                	jmp    8016a5 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801692:	83 ec 0c             	sub    $0xc,%esp
  801695:	50                   	push   %eax
  801696:	e8 e4 f0 ff ff       	call   80077f <strlen>
  80169b:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80169f:	83 c3 01             	add    $0x1,%ebx
  8016a2:	83 c4 10             	add    $0x10,%esp
  8016a5:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8016ac:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8016af:	85 c0                	test   %eax,%eax
  8016b1:	75 df                	jne    801692 <spawn+0xdb>
  8016b3:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8016b9:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8016bf:	bf 00 10 40 00       	mov    $0x401000,%edi
  8016c4:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8016c6:	89 fa                	mov    %edi,%edx
  8016c8:	83 e2 fc             	and    $0xfffffffc,%edx
  8016cb:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8016d2:	29 c2                	sub    %eax,%edx
  8016d4:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8016da:	8d 42 f8             	lea    -0x8(%edx),%eax
  8016dd:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8016e2:	0f 86 a6 03 00 00    	jbe    801a8e <spawn+0x4d7>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8016e8:	83 ec 04             	sub    $0x4,%esp
  8016eb:	6a 07                	push   $0x7
  8016ed:	68 00 00 40 00       	push   $0x400000
  8016f2:	6a 00                	push   $0x0
  8016f4:	e8 c2 f4 ff ff       	call   800bbb <sys_page_alloc>
  8016f9:	83 c4 10             	add    $0x10,%esp
  8016fc:	85 c0                	test   %eax,%eax
  8016fe:	0f 88 91 03 00 00    	js     801a95 <spawn+0x4de>
  801704:	be 00 00 00 00       	mov    $0x0,%esi
  801709:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  80170f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801712:	eb 30                	jmp    801744 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801714:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  80171a:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801720:	89 04 b2             	mov    %eax,(%edx,%esi,4)
		strcpy(string_store, argv[i]);
  801723:	83 ec 08             	sub    $0x8,%esp
  801726:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801729:	57                   	push   %edi
  80172a:	e8 89 f0 ff ff       	call   8007b8 <strcpy>
		string_store += strlen(argv[i]) + 1;
  80172f:	83 c4 04             	add    $0x4,%esp
  801732:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801735:	e8 45 f0 ff ff       	call   80077f <strlen>
  80173a:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  80173e:	83 c6 01             	add    $0x1,%esi
  801741:	83 c4 10             	add    $0x10,%esp
  801744:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  80174a:	7f c8                	jg     801714 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  80174c:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801752:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801758:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  80175f:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801765:	74 19                	je     801780 <spawn+0x1c9>
  801767:	68 e0 28 80 00       	push   $0x8028e0
  80176c:	68 3f 28 80 00       	push   $0x80283f
  801771:	68 f1 00 00 00       	push   $0xf1
  801776:	68 85 28 80 00       	push   $0x802885
  80177b:	e8 5b e9 ff ff       	call   8000db <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801780:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801786:	89 f8                	mov    %edi,%eax
  801788:	2d 00 30 80 11       	sub    $0x11803000,%eax
  80178d:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801790:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801796:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801799:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  80179f:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8017a5:	83 ec 0c             	sub    $0xc,%esp
  8017a8:	6a 07                	push   $0x7
  8017aa:	68 00 d0 bf ee       	push   $0xeebfd000
  8017af:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8017b5:	68 00 00 40 00       	push   $0x400000
  8017ba:	6a 00                	push   $0x0
  8017bc:	e8 3d f4 ff ff       	call   800bfe <sys_page_map>
  8017c1:	89 c3                	mov    %eax,%ebx
  8017c3:	83 c4 20             	add    $0x20,%esp
  8017c6:	85 c0                	test   %eax,%eax
  8017c8:	0f 88 f6 02 00 00    	js     801ac4 <spawn+0x50d>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8017ce:	83 ec 08             	sub    $0x8,%esp
  8017d1:	68 00 00 40 00       	push   $0x400000
  8017d6:	6a 00                	push   $0x0
  8017d8:	e8 63 f4 ff ff       	call   800c40 <sys_page_unmap>
  8017dd:	89 c3                	mov    %eax,%ebx
  8017df:	83 c4 10             	add    $0x10,%esp
  8017e2:	85 c0                	test   %eax,%eax
  8017e4:	0f 88 da 02 00 00    	js     801ac4 <spawn+0x50d>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  8017ea:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  8017f0:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  8017f7:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8017fd:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801804:	00 00 00 
  801807:	e9 88 01 00 00       	jmp    801994 <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  80180c:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801812:	83 38 01             	cmpl   $0x1,(%eax)
  801815:	0f 85 6b 01 00 00    	jne    801986 <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  80181b:	89 c2                	mov    %eax,%edx
  80181d:	8b 40 18             	mov    0x18(%eax),%eax
  801820:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801826:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801829:	83 f8 01             	cmp    $0x1,%eax
  80182c:	19 c0                	sbb    %eax,%eax
  80182e:	83 e0 fe             	and    $0xfffffffe,%eax
  801831:	83 c0 07             	add    $0x7,%eax
  801834:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  80183a:	89 d0                	mov    %edx,%eax
  80183c:	8b 7a 04             	mov    0x4(%edx),%edi
  80183f:	89 fa                	mov    %edi,%edx
  801841:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801847:	8b 78 10             	mov    0x10(%eax),%edi
  80184a:	8b 48 14             	mov    0x14(%eax),%ecx
  80184d:	89 8d 90 fd ff ff    	mov    %ecx,-0x270(%ebp)
  801853:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801856:	89 f0                	mov    %esi,%eax
  801858:	25 ff 0f 00 00       	and    $0xfff,%eax
  80185d:	74 14                	je     801873 <spawn+0x2bc>
		va -= i;
  80185f:	29 c6                	sub    %eax,%esi
		memsz += i;
  801861:	01 c1                	add    %eax,%ecx
  801863:	89 8d 90 fd ff ff    	mov    %ecx,-0x270(%ebp)
		filesz += i;
  801869:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  80186b:	29 c2                	sub    %eax,%edx
  80186d:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801873:	bb 00 00 00 00       	mov    $0x0,%ebx
  801878:	e9 f7 00 00 00       	jmp    801974 <spawn+0x3bd>
		if (i >= filesz) {
  80187d:	39 df                	cmp    %ebx,%edi
  80187f:	77 27                	ja     8018a8 <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801881:	83 ec 04             	sub    $0x4,%esp
  801884:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  80188a:	56                   	push   %esi
  80188b:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801891:	e8 25 f3 ff ff       	call   800bbb <sys_page_alloc>
  801896:	83 c4 10             	add    $0x10,%esp
  801899:	85 c0                	test   %eax,%eax
  80189b:	0f 89 c7 00 00 00    	jns    801968 <spawn+0x3b1>
  8018a1:	89 c3                	mov    %eax,%ebx
  8018a3:	e9 fb 01 00 00       	jmp    801aa3 <spawn+0x4ec>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8018a8:	83 ec 04             	sub    $0x4,%esp
  8018ab:	6a 07                	push   $0x7
  8018ad:	68 00 00 40 00       	push   $0x400000
  8018b2:	6a 00                	push   $0x0
  8018b4:	e8 02 f3 ff ff       	call   800bbb <sys_page_alloc>
  8018b9:	83 c4 10             	add    $0x10,%esp
  8018bc:	85 c0                	test   %eax,%eax
  8018be:	0f 88 d5 01 00 00    	js     801a99 <spawn+0x4e2>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8018c4:	83 ec 08             	sub    $0x8,%esp
  8018c7:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  8018cd:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  8018d3:	50                   	push   %eax
  8018d4:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8018da:	e8 0f f9 ff ff       	call   8011ee <seek>
  8018df:	83 c4 10             	add    $0x10,%esp
  8018e2:	85 c0                	test   %eax,%eax
  8018e4:	0f 88 b3 01 00 00    	js     801a9d <spawn+0x4e6>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  8018ea:	83 ec 04             	sub    $0x4,%esp
  8018ed:	89 f8                	mov    %edi,%eax
  8018ef:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  8018f5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018fa:	ba 00 10 00 00       	mov    $0x1000,%edx
  8018ff:	0f 47 c2             	cmova  %edx,%eax
  801902:	50                   	push   %eax
  801903:	68 00 00 40 00       	push   $0x400000
  801908:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80190e:	e8 06 f8 ff ff       	call   801119 <readn>
  801913:	83 c4 10             	add    $0x10,%esp
  801916:	85 c0                	test   %eax,%eax
  801918:	0f 88 83 01 00 00    	js     801aa1 <spawn+0x4ea>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  80191e:	83 ec 0c             	sub    $0xc,%esp
  801921:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801927:	56                   	push   %esi
  801928:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  80192e:	68 00 00 40 00       	push   $0x400000
  801933:	6a 00                	push   $0x0
  801935:	e8 c4 f2 ff ff       	call   800bfe <sys_page_map>
  80193a:	83 c4 20             	add    $0x20,%esp
  80193d:	85 c0                	test   %eax,%eax
  80193f:	79 15                	jns    801956 <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  801941:	50                   	push   %eax
  801942:	68 91 28 80 00       	push   $0x802891
  801947:	68 24 01 00 00       	push   $0x124
  80194c:	68 85 28 80 00       	push   $0x802885
  801951:	e8 85 e7 ff ff       	call   8000db <_panic>
			sys_page_unmap(0, UTEMP);
  801956:	83 ec 08             	sub    $0x8,%esp
  801959:	68 00 00 40 00       	push   $0x400000
  80195e:	6a 00                	push   $0x0
  801960:	e8 db f2 ff ff       	call   800c40 <sys_page_unmap>
  801965:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801968:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80196e:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801974:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  80197a:	39 9d 90 fd ff ff    	cmp    %ebx,-0x270(%ebp)
  801980:	0f 87 f7 fe ff ff    	ja     80187d <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801986:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  80198d:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801994:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  80199b:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  8019a1:	0f 8c 65 fe ff ff    	jl     80180c <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  8019a7:	83 ec 0c             	sub    $0xc,%esp
  8019aa:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8019b0:	e8 97 f5 ff ff       	call   800f4c <close>
// Copy the mappings for shared pages into the child address space.
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	envid_t curenvid = sys_getenvid();
  8019b5:	e8 c3 f1 ff ff       	call   800b7d <sys_getenvid>
  8019ba:	89 c6                	mov    %eax,%esi
  8019bc:	83 c4 10             	add    $0x10,%esp

	for (int i = 0; i < UTOP; i += PGSIZE) {
  8019bf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019c4:	8b bd 84 fd ff ff    	mov    -0x27c(%ebp),%edi
		if ((uvpd[PDX(i)] & PTE_P) &&
  8019ca:	89 d8                	mov    %ebx,%eax
  8019cc:	c1 e8 16             	shr    $0x16,%eax
  8019cf:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8019d6:	a8 01                	test   $0x1,%al
  8019d8:	74 31                	je     801a0b <spawn+0x454>
			(uvpt[PGNUM(i)] & PTE_P) &&
  8019da:	89 d8                	mov    %ebx,%eax
  8019dc:	c1 e8 0c             	shr    $0xc,%eax
  8019df:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
{
	// LAB 5: Your code here.
	envid_t curenvid = sys_getenvid();

	for (int i = 0; i < UTOP; i += PGSIZE) {
		if ((uvpd[PDX(i)] & PTE_P) &&
  8019e6:	f6 c2 01             	test   $0x1,%dl
  8019e9:	74 20                	je     801a0b <spawn+0x454>
			(uvpt[PGNUM(i)] & PTE_P) &&
			(uvpt[PGNUM(i)] & PTE_SHARE))
  8019eb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// LAB 5: Your code here.
	envid_t curenvid = sys_getenvid();

	for (int i = 0; i < UTOP; i += PGSIZE) {
		if ((uvpd[PDX(i)] & PTE_P) &&
			(uvpt[PGNUM(i)] & PTE_P) &&
  8019f2:	f6 c4 04             	test   $0x4,%ah
  8019f5:	74 14                	je     801a0b <spawn+0x454>
			(uvpt[PGNUM(i)] & PTE_SHARE))
			sys_page_map(curenvid, (void *)i,
  8019f7:	83 ec 0c             	sub    $0xc,%esp
  8019fa:	68 07 0e 00 00       	push   $0xe07
  8019ff:	53                   	push   %ebx
  801a00:	57                   	push   %edi
  801a01:	53                   	push   %ebx
  801a02:	56                   	push   %esi
  801a03:	e8 f6 f1 ff ff       	call   800bfe <sys_page_map>
  801a08:	83 c4 20             	add    $0x20,%esp
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	envid_t curenvid = sys_getenvid();

	for (int i = 0; i < UTOP; i += PGSIZE) {
  801a0b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801a11:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801a17:	75 b1                	jne    8019ca <spawn+0x413>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801a19:	83 ec 08             	sub    $0x8,%esp
  801a1c:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801a22:	50                   	push   %eax
  801a23:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801a29:	e8 96 f2 ff ff       	call   800cc4 <sys_env_set_trapframe>
  801a2e:	83 c4 10             	add    $0x10,%esp
  801a31:	85 c0                	test   %eax,%eax
  801a33:	79 15                	jns    801a4a <spawn+0x493>
		panic("sys_env_set_trapframe: %e", r);
  801a35:	50                   	push   %eax
  801a36:	68 ae 28 80 00       	push   $0x8028ae
  801a3b:	68 85 00 00 00       	push   $0x85
  801a40:	68 85 28 80 00       	push   $0x802885
  801a45:	e8 91 e6 ff ff       	call   8000db <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801a4a:	83 ec 08             	sub    $0x8,%esp
  801a4d:	6a 02                	push   $0x2
  801a4f:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801a55:	e8 28 f2 ff ff       	call   800c82 <sys_env_set_status>
  801a5a:	83 c4 10             	add    $0x10,%esp
  801a5d:	85 c0                	test   %eax,%eax
  801a5f:	79 25                	jns    801a86 <spawn+0x4cf>
		panic("sys_env_set_status: %e", r);
  801a61:	50                   	push   %eax
  801a62:	68 c8 28 80 00       	push   $0x8028c8
  801a67:	68 88 00 00 00       	push   $0x88
  801a6c:	68 85 28 80 00       	push   $0x802885
  801a71:	e8 65 e6 ff ff       	call   8000db <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801a76:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801a7c:	eb 58                	jmp    801ad6 <spawn+0x51f>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801a7e:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801a84:	eb 50                	jmp    801ad6 <spawn+0x51f>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801a86:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801a8c:	eb 48                	jmp    801ad6 <spawn+0x51f>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801a8e:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801a93:	eb 41                	jmp    801ad6 <spawn+0x51f>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801a95:	89 c3                	mov    %eax,%ebx
  801a97:	eb 3d                	jmp    801ad6 <spawn+0x51f>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801a99:	89 c3                	mov    %eax,%ebx
  801a9b:	eb 06                	jmp    801aa3 <spawn+0x4ec>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801a9d:	89 c3                	mov    %eax,%ebx
  801a9f:	eb 02                	jmp    801aa3 <spawn+0x4ec>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801aa1:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801aa3:	83 ec 0c             	sub    $0xc,%esp
  801aa6:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801aac:	e8 8b f0 ff ff       	call   800b3c <sys_env_destroy>
	close(fd);
  801ab1:	83 c4 04             	add    $0x4,%esp
  801ab4:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801aba:	e8 8d f4 ff ff       	call   800f4c <close>
	return r;
  801abf:	83 c4 10             	add    $0x10,%esp
  801ac2:	eb 12                	jmp    801ad6 <spawn+0x51f>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801ac4:	83 ec 08             	sub    $0x8,%esp
  801ac7:	68 00 00 40 00       	push   $0x400000
  801acc:	6a 00                	push   $0x0
  801ace:	e8 6d f1 ff ff       	call   800c40 <sys_page_unmap>
  801ad3:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801ad6:	89 d8                	mov    %ebx,%eax
  801ad8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801adb:	5b                   	pop    %ebx
  801adc:	5e                   	pop    %esi
  801add:	5f                   	pop    %edi
  801ade:	5d                   	pop    %ebp
  801adf:	c3                   	ret    

00801ae0 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801ae0:	55                   	push   %ebp
  801ae1:	89 e5                	mov    %esp,%ebp
  801ae3:	56                   	push   %esi
  801ae4:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801ae5:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801ae8:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801aed:	eb 03                	jmp    801af2 <spawnl+0x12>
		argc++;
  801aef:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801af2:	83 c2 04             	add    $0x4,%edx
  801af5:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801af9:	75 f4                	jne    801aef <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801afb:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801b02:	83 e2 f0             	and    $0xfffffff0,%edx
  801b05:	29 d4                	sub    %edx,%esp
  801b07:	8d 54 24 03          	lea    0x3(%esp),%edx
  801b0b:	c1 ea 02             	shr    $0x2,%edx
  801b0e:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801b15:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801b17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b1a:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801b21:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801b28:	00 
  801b29:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801b2b:	b8 00 00 00 00       	mov    $0x0,%eax
  801b30:	eb 0a                	jmp    801b3c <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801b32:	83 c0 01             	add    $0x1,%eax
  801b35:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801b39:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801b3c:	39 d0                	cmp    %edx,%eax
  801b3e:	75 f2                	jne    801b32 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801b40:	83 ec 08             	sub    $0x8,%esp
  801b43:	56                   	push   %esi
  801b44:	ff 75 08             	pushl  0x8(%ebp)
  801b47:	e8 6b fa ff ff       	call   8015b7 <spawn>
}
  801b4c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b4f:	5b                   	pop    %ebx
  801b50:	5e                   	pop    %esi
  801b51:	5d                   	pop    %ebp
  801b52:	c3                   	ret    

00801b53 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b53:	55                   	push   %ebp
  801b54:	89 e5                	mov    %esp,%ebp
  801b56:	56                   	push   %esi
  801b57:	53                   	push   %ebx
  801b58:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b5b:	83 ec 0c             	sub    $0xc,%esp
  801b5e:	ff 75 08             	pushl  0x8(%ebp)
  801b61:	e8 56 f2 ff ff       	call   800dbc <fd2data>
  801b66:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b68:	83 c4 08             	add    $0x8,%esp
  801b6b:	68 08 29 80 00       	push   $0x802908
  801b70:	53                   	push   %ebx
  801b71:	e8 42 ec ff ff       	call   8007b8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b76:	8b 46 04             	mov    0x4(%esi),%eax
  801b79:	2b 06                	sub    (%esi),%eax
  801b7b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b81:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b88:	00 00 00 
	stat->st_dev = &devpipe;
  801b8b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b92:	30 80 00 
	return 0;
}
  801b95:	b8 00 00 00 00       	mov    $0x0,%eax
  801b9a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b9d:	5b                   	pop    %ebx
  801b9e:	5e                   	pop    %esi
  801b9f:	5d                   	pop    %ebp
  801ba0:	c3                   	ret    

00801ba1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ba1:	55                   	push   %ebp
  801ba2:	89 e5                	mov    %esp,%ebp
  801ba4:	53                   	push   %ebx
  801ba5:	83 ec 0c             	sub    $0xc,%esp
  801ba8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801bab:	53                   	push   %ebx
  801bac:	6a 00                	push   $0x0
  801bae:	e8 8d f0 ff ff       	call   800c40 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bb3:	89 1c 24             	mov    %ebx,(%esp)
  801bb6:	e8 01 f2 ff ff       	call   800dbc <fd2data>
  801bbb:	83 c4 08             	add    $0x8,%esp
  801bbe:	50                   	push   %eax
  801bbf:	6a 00                	push   $0x0
  801bc1:	e8 7a f0 ff ff       	call   800c40 <sys_page_unmap>
}
  801bc6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bc9:	c9                   	leave  
  801bca:	c3                   	ret    

00801bcb <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801bcb:	55                   	push   %ebp
  801bcc:	89 e5                	mov    %esp,%ebp
  801bce:	57                   	push   %edi
  801bcf:	56                   	push   %esi
  801bd0:	53                   	push   %ebx
  801bd1:	83 ec 1c             	sub    $0x1c,%esp
  801bd4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801bd7:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801bd9:	a1 04 40 80 00       	mov    0x804004,%eax
  801bde:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801be1:	83 ec 0c             	sub    $0xc,%esp
  801be4:	ff 75 e0             	pushl  -0x20(%ebp)
  801be7:	e8 45 05 00 00       	call   802131 <pageref>
  801bec:	89 c3                	mov    %eax,%ebx
  801bee:	89 3c 24             	mov    %edi,(%esp)
  801bf1:	e8 3b 05 00 00       	call   802131 <pageref>
  801bf6:	83 c4 10             	add    $0x10,%esp
  801bf9:	39 c3                	cmp    %eax,%ebx
  801bfb:	0f 94 c1             	sete   %cl
  801bfe:	0f b6 c9             	movzbl %cl,%ecx
  801c01:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801c04:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c0a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c0d:	39 ce                	cmp    %ecx,%esi
  801c0f:	74 1b                	je     801c2c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801c11:	39 c3                	cmp    %eax,%ebx
  801c13:	75 c4                	jne    801bd9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c15:	8b 42 58             	mov    0x58(%edx),%eax
  801c18:	ff 75 e4             	pushl  -0x1c(%ebp)
  801c1b:	50                   	push   %eax
  801c1c:	56                   	push   %esi
  801c1d:	68 0f 29 80 00       	push   $0x80290f
  801c22:	e8 8d e5 ff ff       	call   8001b4 <cprintf>
  801c27:	83 c4 10             	add    $0x10,%esp
  801c2a:	eb ad                	jmp    801bd9 <_pipeisclosed+0xe>
	}
}
  801c2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c32:	5b                   	pop    %ebx
  801c33:	5e                   	pop    %esi
  801c34:	5f                   	pop    %edi
  801c35:	5d                   	pop    %ebp
  801c36:	c3                   	ret    

00801c37 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c37:	55                   	push   %ebp
  801c38:	89 e5                	mov    %esp,%ebp
  801c3a:	57                   	push   %edi
  801c3b:	56                   	push   %esi
  801c3c:	53                   	push   %ebx
  801c3d:	83 ec 28             	sub    $0x28,%esp
  801c40:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801c43:	56                   	push   %esi
  801c44:	e8 73 f1 ff ff       	call   800dbc <fd2data>
  801c49:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c4b:	83 c4 10             	add    $0x10,%esp
  801c4e:	bf 00 00 00 00       	mov    $0x0,%edi
  801c53:	eb 4b                	jmp    801ca0 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c55:	89 da                	mov    %ebx,%edx
  801c57:	89 f0                	mov    %esi,%eax
  801c59:	e8 6d ff ff ff       	call   801bcb <_pipeisclosed>
  801c5e:	85 c0                	test   %eax,%eax
  801c60:	75 48                	jne    801caa <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c62:	e8 35 ef ff ff       	call   800b9c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c67:	8b 43 04             	mov    0x4(%ebx),%eax
  801c6a:	8b 0b                	mov    (%ebx),%ecx
  801c6c:	8d 51 20             	lea    0x20(%ecx),%edx
  801c6f:	39 d0                	cmp    %edx,%eax
  801c71:	73 e2                	jae    801c55 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c76:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c7a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c7d:	89 c2                	mov    %eax,%edx
  801c7f:	c1 fa 1f             	sar    $0x1f,%edx
  801c82:	89 d1                	mov    %edx,%ecx
  801c84:	c1 e9 1b             	shr    $0x1b,%ecx
  801c87:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c8a:	83 e2 1f             	and    $0x1f,%edx
  801c8d:	29 ca                	sub    %ecx,%edx
  801c8f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c93:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c97:	83 c0 01             	add    $0x1,%eax
  801c9a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c9d:	83 c7 01             	add    $0x1,%edi
  801ca0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ca3:	75 c2                	jne    801c67 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801ca5:	8b 45 10             	mov    0x10(%ebp),%eax
  801ca8:	eb 05                	jmp    801caf <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801caa:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801caf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cb2:	5b                   	pop    %ebx
  801cb3:	5e                   	pop    %esi
  801cb4:	5f                   	pop    %edi
  801cb5:	5d                   	pop    %ebp
  801cb6:	c3                   	ret    

00801cb7 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801cb7:	55                   	push   %ebp
  801cb8:	89 e5                	mov    %esp,%ebp
  801cba:	57                   	push   %edi
  801cbb:	56                   	push   %esi
  801cbc:	53                   	push   %ebx
  801cbd:	83 ec 18             	sub    $0x18,%esp
  801cc0:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801cc3:	57                   	push   %edi
  801cc4:	e8 f3 f0 ff ff       	call   800dbc <fd2data>
  801cc9:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ccb:	83 c4 10             	add    $0x10,%esp
  801cce:	bb 00 00 00 00       	mov    $0x0,%ebx
  801cd3:	eb 3d                	jmp    801d12 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801cd5:	85 db                	test   %ebx,%ebx
  801cd7:	74 04                	je     801cdd <devpipe_read+0x26>
				return i;
  801cd9:	89 d8                	mov    %ebx,%eax
  801cdb:	eb 44                	jmp    801d21 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801cdd:	89 f2                	mov    %esi,%edx
  801cdf:	89 f8                	mov    %edi,%eax
  801ce1:	e8 e5 fe ff ff       	call   801bcb <_pipeisclosed>
  801ce6:	85 c0                	test   %eax,%eax
  801ce8:	75 32                	jne    801d1c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801cea:	e8 ad ee ff ff       	call   800b9c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801cef:	8b 06                	mov    (%esi),%eax
  801cf1:	3b 46 04             	cmp    0x4(%esi),%eax
  801cf4:	74 df                	je     801cd5 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cf6:	99                   	cltd   
  801cf7:	c1 ea 1b             	shr    $0x1b,%edx
  801cfa:	01 d0                	add    %edx,%eax
  801cfc:	83 e0 1f             	and    $0x1f,%eax
  801cff:	29 d0                	sub    %edx,%eax
  801d01:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801d06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d09:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801d0c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d0f:	83 c3 01             	add    $0x1,%ebx
  801d12:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801d15:	75 d8                	jne    801cef <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801d17:	8b 45 10             	mov    0x10(%ebp),%eax
  801d1a:	eb 05                	jmp    801d21 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d1c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801d21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d24:	5b                   	pop    %ebx
  801d25:	5e                   	pop    %esi
  801d26:	5f                   	pop    %edi
  801d27:	5d                   	pop    %ebp
  801d28:	c3                   	ret    

00801d29 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801d29:	55                   	push   %ebp
  801d2a:	89 e5                	mov    %esp,%ebp
  801d2c:	56                   	push   %esi
  801d2d:	53                   	push   %ebx
  801d2e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801d31:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d34:	50                   	push   %eax
  801d35:	e8 99 f0 ff ff       	call   800dd3 <fd_alloc>
  801d3a:	83 c4 10             	add    $0x10,%esp
  801d3d:	89 c2                	mov    %eax,%edx
  801d3f:	85 c0                	test   %eax,%eax
  801d41:	0f 88 2c 01 00 00    	js     801e73 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d47:	83 ec 04             	sub    $0x4,%esp
  801d4a:	68 07 04 00 00       	push   $0x407
  801d4f:	ff 75 f4             	pushl  -0xc(%ebp)
  801d52:	6a 00                	push   $0x0
  801d54:	e8 62 ee ff ff       	call   800bbb <sys_page_alloc>
  801d59:	83 c4 10             	add    $0x10,%esp
  801d5c:	89 c2                	mov    %eax,%edx
  801d5e:	85 c0                	test   %eax,%eax
  801d60:	0f 88 0d 01 00 00    	js     801e73 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d66:	83 ec 0c             	sub    $0xc,%esp
  801d69:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d6c:	50                   	push   %eax
  801d6d:	e8 61 f0 ff ff       	call   800dd3 <fd_alloc>
  801d72:	89 c3                	mov    %eax,%ebx
  801d74:	83 c4 10             	add    $0x10,%esp
  801d77:	85 c0                	test   %eax,%eax
  801d79:	0f 88 e2 00 00 00    	js     801e61 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d7f:	83 ec 04             	sub    $0x4,%esp
  801d82:	68 07 04 00 00       	push   $0x407
  801d87:	ff 75 f0             	pushl  -0x10(%ebp)
  801d8a:	6a 00                	push   $0x0
  801d8c:	e8 2a ee ff ff       	call   800bbb <sys_page_alloc>
  801d91:	89 c3                	mov    %eax,%ebx
  801d93:	83 c4 10             	add    $0x10,%esp
  801d96:	85 c0                	test   %eax,%eax
  801d98:	0f 88 c3 00 00 00    	js     801e61 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d9e:	83 ec 0c             	sub    $0xc,%esp
  801da1:	ff 75 f4             	pushl  -0xc(%ebp)
  801da4:	e8 13 f0 ff ff       	call   800dbc <fd2data>
  801da9:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dab:	83 c4 0c             	add    $0xc,%esp
  801dae:	68 07 04 00 00       	push   $0x407
  801db3:	50                   	push   %eax
  801db4:	6a 00                	push   $0x0
  801db6:	e8 00 ee ff ff       	call   800bbb <sys_page_alloc>
  801dbb:	89 c3                	mov    %eax,%ebx
  801dbd:	83 c4 10             	add    $0x10,%esp
  801dc0:	85 c0                	test   %eax,%eax
  801dc2:	0f 88 89 00 00 00    	js     801e51 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dc8:	83 ec 0c             	sub    $0xc,%esp
  801dcb:	ff 75 f0             	pushl  -0x10(%ebp)
  801dce:	e8 e9 ef ff ff       	call   800dbc <fd2data>
  801dd3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801dda:	50                   	push   %eax
  801ddb:	6a 00                	push   $0x0
  801ddd:	56                   	push   %esi
  801dde:	6a 00                	push   $0x0
  801de0:	e8 19 ee ff ff       	call   800bfe <sys_page_map>
  801de5:	89 c3                	mov    %eax,%ebx
  801de7:	83 c4 20             	add    $0x20,%esp
  801dea:	85 c0                	test   %eax,%eax
  801dec:	78 55                	js     801e43 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801dee:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801df4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801df7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801df9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dfc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801e03:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801e09:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e0c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801e0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e11:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801e18:	83 ec 0c             	sub    $0xc,%esp
  801e1b:	ff 75 f4             	pushl  -0xc(%ebp)
  801e1e:	e8 89 ef ff ff       	call   800dac <fd2num>
  801e23:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e26:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e28:	83 c4 04             	add    $0x4,%esp
  801e2b:	ff 75 f0             	pushl  -0x10(%ebp)
  801e2e:	e8 79 ef ff ff       	call   800dac <fd2num>
  801e33:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e36:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e39:	83 c4 10             	add    $0x10,%esp
  801e3c:	ba 00 00 00 00       	mov    $0x0,%edx
  801e41:	eb 30                	jmp    801e73 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801e43:	83 ec 08             	sub    $0x8,%esp
  801e46:	56                   	push   %esi
  801e47:	6a 00                	push   $0x0
  801e49:	e8 f2 ed ff ff       	call   800c40 <sys_page_unmap>
  801e4e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e51:	83 ec 08             	sub    $0x8,%esp
  801e54:	ff 75 f0             	pushl  -0x10(%ebp)
  801e57:	6a 00                	push   $0x0
  801e59:	e8 e2 ed ff ff       	call   800c40 <sys_page_unmap>
  801e5e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e61:	83 ec 08             	sub    $0x8,%esp
  801e64:	ff 75 f4             	pushl  -0xc(%ebp)
  801e67:	6a 00                	push   $0x0
  801e69:	e8 d2 ed ff ff       	call   800c40 <sys_page_unmap>
  801e6e:	83 c4 10             	add    $0x10,%esp
  801e71:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e73:	89 d0                	mov    %edx,%eax
  801e75:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e78:	5b                   	pop    %ebx
  801e79:	5e                   	pop    %esi
  801e7a:	5d                   	pop    %ebp
  801e7b:	c3                   	ret    

00801e7c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e7c:	55                   	push   %ebp
  801e7d:	89 e5                	mov    %esp,%ebp
  801e7f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e82:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e85:	50                   	push   %eax
  801e86:	ff 75 08             	pushl  0x8(%ebp)
  801e89:	e8 94 ef ff ff       	call   800e22 <fd_lookup>
  801e8e:	83 c4 10             	add    $0x10,%esp
  801e91:	85 c0                	test   %eax,%eax
  801e93:	78 18                	js     801ead <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e95:	83 ec 0c             	sub    $0xc,%esp
  801e98:	ff 75 f4             	pushl  -0xc(%ebp)
  801e9b:	e8 1c ef ff ff       	call   800dbc <fd2data>
	return _pipeisclosed(fd, p);
  801ea0:	89 c2                	mov    %eax,%edx
  801ea2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea5:	e8 21 fd ff ff       	call   801bcb <_pipeisclosed>
  801eaa:	83 c4 10             	add    $0x10,%esp
}
  801ead:	c9                   	leave  
  801eae:	c3                   	ret    

00801eaf <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801eaf:	55                   	push   %ebp
  801eb0:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801eb2:	b8 00 00 00 00       	mov    $0x0,%eax
  801eb7:	5d                   	pop    %ebp
  801eb8:	c3                   	ret    

00801eb9 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801eb9:	55                   	push   %ebp
  801eba:	89 e5                	mov    %esp,%ebp
  801ebc:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ebf:	68 27 29 80 00       	push   $0x802927
  801ec4:	ff 75 0c             	pushl  0xc(%ebp)
  801ec7:	e8 ec e8 ff ff       	call   8007b8 <strcpy>
	return 0;
}
  801ecc:	b8 00 00 00 00       	mov    $0x0,%eax
  801ed1:	c9                   	leave  
  801ed2:	c3                   	ret    

00801ed3 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ed3:	55                   	push   %ebp
  801ed4:	89 e5                	mov    %esp,%ebp
  801ed6:	57                   	push   %edi
  801ed7:	56                   	push   %esi
  801ed8:	53                   	push   %ebx
  801ed9:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801edf:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ee4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801eea:	eb 2d                	jmp    801f19 <devcons_write+0x46>
		m = n - tot;
  801eec:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801eef:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801ef1:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ef4:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ef9:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801efc:	83 ec 04             	sub    $0x4,%esp
  801eff:	53                   	push   %ebx
  801f00:	03 45 0c             	add    0xc(%ebp),%eax
  801f03:	50                   	push   %eax
  801f04:	57                   	push   %edi
  801f05:	e8 40 ea ff ff       	call   80094a <memmove>
		sys_cputs(buf, m);
  801f0a:	83 c4 08             	add    $0x8,%esp
  801f0d:	53                   	push   %ebx
  801f0e:	57                   	push   %edi
  801f0f:	e8 eb eb ff ff       	call   800aff <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f14:	01 de                	add    %ebx,%esi
  801f16:	83 c4 10             	add    $0x10,%esp
  801f19:	89 f0                	mov    %esi,%eax
  801f1b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f1e:	72 cc                	jb     801eec <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801f20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f23:	5b                   	pop    %ebx
  801f24:	5e                   	pop    %esi
  801f25:	5f                   	pop    %edi
  801f26:	5d                   	pop    %ebp
  801f27:	c3                   	ret    

00801f28 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f28:	55                   	push   %ebp
  801f29:	89 e5                	mov    %esp,%ebp
  801f2b:	83 ec 08             	sub    $0x8,%esp
  801f2e:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801f33:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f37:	74 2a                	je     801f63 <devcons_read+0x3b>
  801f39:	eb 05                	jmp    801f40 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801f3b:	e8 5c ec ff ff       	call   800b9c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801f40:	e8 d8 eb ff ff       	call   800b1d <sys_cgetc>
  801f45:	85 c0                	test   %eax,%eax
  801f47:	74 f2                	je     801f3b <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801f49:	85 c0                	test   %eax,%eax
  801f4b:	78 16                	js     801f63 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801f4d:	83 f8 04             	cmp    $0x4,%eax
  801f50:	74 0c                	je     801f5e <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f52:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f55:	88 02                	mov    %al,(%edx)
	return 1;
  801f57:	b8 01 00 00 00       	mov    $0x1,%eax
  801f5c:	eb 05                	jmp    801f63 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f5e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f63:	c9                   	leave  
  801f64:	c3                   	ret    

00801f65 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f65:	55                   	push   %ebp
  801f66:	89 e5                	mov    %esp,%ebp
  801f68:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f6b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f6e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f71:	6a 01                	push   $0x1
  801f73:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f76:	50                   	push   %eax
  801f77:	e8 83 eb ff ff       	call   800aff <sys_cputs>
}
  801f7c:	83 c4 10             	add    $0x10,%esp
  801f7f:	c9                   	leave  
  801f80:	c3                   	ret    

00801f81 <getchar>:

int
getchar(void)
{
  801f81:	55                   	push   %ebp
  801f82:	89 e5                	mov    %esp,%ebp
  801f84:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f87:	6a 01                	push   $0x1
  801f89:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f8c:	50                   	push   %eax
  801f8d:	6a 00                	push   $0x0
  801f8f:	e8 f4 f0 ff ff       	call   801088 <read>
	if (r < 0)
  801f94:	83 c4 10             	add    $0x10,%esp
  801f97:	85 c0                	test   %eax,%eax
  801f99:	78 0f                	js     801faa <getchar+0x29>
		return r;
	if (r < 1)
  801f9b:	85 c0                	test   %eax,%eax
  801f9d:	7e 06                	jle    801fa5 <getchar+0x24>
		return -E_EOF;
	return c;
  801f9f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801fa3:	eb 05                	jmp    801faa <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801fa5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801faa:	c9                   	leave  
  801fab:	c3                   	ret    

00801fac <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801fac:	55                   	push   %ebp
  801fad:	89 e5                	mov    %esp,%ebp
  801faf:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fb2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fb5:	50                   	push   %eax
  801fb6:	ff 75 08             	pushl  0x8(%ebp)
  801fb9:	e8 64 ee ff ff       	call   800e22 <fd_lookup>
  801fbe:	83 c4 10             	add    $0x10,%esp
  801fc1:	85 c0                	test   %eax,%eax
  801fc3:	78 11                	js     801fd6 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801fc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fc8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fce:	39 10                	cmp    %edx,(%eax)
  801fd0:	0f 94 c0             	sete   %al
  801fd3:	0f b6 c0             	movzbl %al,%eax
}
  801fd6:	c9                   	leave  
  801fd7:	c3                   	ret    

00801fd8 <opencons>:

int
opencons(void)
{
  801fd8:	55                   	push   %ebp
  801fd9:	89 e5                	mov    %esp,%ebp
  801fdb:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fde:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fe1:	50                   	push   %eax
  801fe2:	e8 ec ed ff ff       	call   800dd3 <fd_alloc>
  801fe7:	83 c4 10             	add    $0x10,%esp
		return r;
  801fea:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801fec:	85 c0                	test   %eax,%eax
  801fee:	78 3e                	js     80202e <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ff0:	83 ec 04             	sub    $0x4,%esp
  801ff3:	68 07 04 00 00       	push   $0x407
  801ff8:	ff 75 f4             	pushl  -0xc(%ebp)
  801ffb:	6a 00                	push   $0x0
  801ffd:	e8 b9 eb ff ff       	call   800bbb <sys_page_alloc>
  802002:	83 c4 10             	add    $0x10,%esp
		return r;
  802005:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802007:	85 c0                	test   %eax,%eax
  802009:	78 23                	js     80202e <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80200b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802011:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802014:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802016:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802019:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802020:	83 ec 0c             	sub    $0xc,%esp
  802023:	50                   	push   %eax
  802024:	e8 83 ed ff ff       	call   800dac <fd2num>
  802029:	89 c2                	mov    %eax,%edx
  80202b:	83 c4 10             	add    $0x10,%esp
}
  80202e:	89 d0                	mov    %edx,%eax
  802030:	c9                   	leave  
  802031:	c3                   	ret    

00802032 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802032:	55                   	push   %ebp
  802033:	89 e5                	mov    %esp,%ebp
  802035:	56                   	push   %esi
  802036:	53                   	push   %ebx
  802037:	8b 75 08             	mov    0x8(%ebp),%esi
  80203a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80203d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

    if (pg != NULL)
  802040:	85 c0                	test   %eax,%eax
  802042:	74 0e                	je     802052 <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  802044:	83 ec 0c             	sub    $0xc,%esp
  802047:	50                   	push   %eax
  802048:	e8 1e ed ff ff       	call   800d6b <sys_ipc_recv>
  80204d:	83 c4 10             	add    $0x10,%esp
  802050:	eb 0d                	jmp    80205f <ipc_recv+0x2d>
	else
        r = sys_ipc_recv((void *)-1);
  802052:	83 ec 0c             	sub    $0xc,%esp
  802055:	6a ff                	push   $0xffffffff
  802057:	e8 0f ed ff ff       	call   800d6b <sys_ipc_recv>
  80205c:	83 c4 10             	add    $0x10,%esp

	if (r < 0) {
  80205f:	85 c0                	test   %eax,%eax
  802061:	79 16                	jns    802079 <ipc_recv+0x47>

		if (from_env_store != NULL)
  802063:	85 f6                	test   %esi,%esi
  802065:	74 06                	je     80206d <ipc_recv+0x3b>
			*from_env_store = 0;
  802067:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL)
  80206d:	85 db                	test   %ebx,%ebx
  80206f:	74 2c                	je     80209d <ipc_recv+0x6b>
			*perm_store = 0;
  802071:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802077:	eb 24                	jmp    80209d <ipc_recv+0x6b>
		return r;

	} else {

		if (from_env_store != NULL)
  802079:	85 f6                	test   %esi,%esi
  80207b:	74 0a                	je     802087 <ipc_recv+0x55>
			*from_env_store = thisenv->env_ipc_from;
  80207d:	a1 04 40 80 00       	mov    0x804004,%eax
  802082:	8b 40 74             	mov    0x74(%eax),%eax
  802085:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL)
  802087:	85 db                	test   %ebx,%ebx
  802089:	74 0a                	je     802095 <ipc_recv+0x63>
			*perm_store = thisenv->env_ipc_perm;
  80208b:	a1 04 40 80 00       	mov    0x804004,%eax
  802090:	8b 40 78             	mov    0x78(%eax),%eax
  802093:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  802095:	a1 04 40 80 00       	mov    0x804004,%eax
  80209a:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  80209d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020a0:	5b                   	pop    %ebx
  8020a1:	5e                   	pop    %esi
  8020a2:	5d                   	pop    %ebp
  8020a3:	c3                   	ret    

008020a4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020a4:	55                   	push   %ebp
  8020a5:	89 e5                	mov    %esp,%ebp
  8020a7:	57                   	push   %edi
  8020a8:	56                   	push   %esi
  8020a9:	53                   	push   %ebx
  8020aa:	83 ec 0c             	sub    $0xc,%esp
  8020ad:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020b0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

	if (pg == NULL)
  8020b6:	85 db                	test   %ebx,%ebx
		pg = (void *)-1;	
  8020b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8020bd:	0f 44 d8             	cmove  %eax,%ebx

	while (true) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8020c0:	ff 75 14             	pushl  0x14(%ebp)
  8020c3:	53                   	push   %ebx
  8020c4:	56                   	push   %esi
  8020c5:	57                   	push   %edi
  8020c6:	e8 7d ec ff ff       	call   800d48 <sys_ipc_try_send>
		if (r >= 0)
  8020cb:	83 c4 10             	add    $0x10,%esp
  8020ce:	85 c0                	test   %eax,%eax
  8020d0:	79 1e                	jns    8020f0 <ipc_send+0x4c>
			return;
		else if (r != -E_IPC_NOT_RECV)
  8020d2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020d5:	74 12                	je     8020e9 <ipc_send+0x45>
			panic("ipc_send error: %e", r);
  8020d7:	50                   	push   %eax
  8020d8:	68 33 29 80 00       	push   $0x802933
  8020dd:	6a 49                	push   $0x49
  8020df:	68 46 29 80 00       	push   $0x802946
  8020e4:	e8 f2 df ff ff       	call   8000db <_panic>
	
		sys_yield();
  8020e9:	e8 ae ea ff ff       	call   800b9c <sys_yield>
	}
  8020ee:	eb d0                	jmp    8020c0 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  8020f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020f3:	5b                   	pop    %ebx
  8020f4:	5e                   	pop    %esi
  8020f5:	5f                   	pop    %edi
  8020f6:	5d                   	pop    %ebp
  8020f7:	c3                   	ret    

008020f8 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020f8:	55                   	push   %ebp
  8020f9:	89 e5                	mov    %esp,%ebp
  8020fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020fe:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802103:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802106:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80210c:	8b 52 50             	mov    0x50(%edx),%edx
  80210f:	39 ca                	cmp    %ecx,%edx
  802111:	75 0d                	jne    802120 <ipc_find_env+0x28>
			return envs[i].env_id;
  802113:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802116:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80211b:	8b 40 48             	mov    0x48(%eax),%eax
  80211e:	eb 0f                	jmp    80212f <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802120:	83 c0 01             	add    $0x1,%eax
  802123:	3d 00 04 00 00       	cmp    $0x400,%eax
  802128:	75 d9                	jne    802103 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80212a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80212f:	5d                   	pop    %ebp
  802130:	c3                   	ret    

00802131 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802131:	55                   	push   %ebp
  802132:	89 e5                	mov    %esp,%ebp
  802134:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802137:	89 d0                	mov    %edx,%eax
  802139:	c1 e8 16             	shr    $0x16,%eax
  80213c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802143:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802148:	f6 c1 01             	test   $0x1,%cl
  80214b:	74 1d                	je     80216a <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80214d:	c1 ea 0c             	shr    $0xc,%edx
  802150:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802157:	f6 c2 01             	test   $0x1,%dl
  80215a:	74 0e                	je     80216a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80215c:	c1 ea 0c             	shr    $0xc,%edx
  80215f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802166:	ef 
  802167:	0f b7 c0             	movzwl %ax,%eax
}
  80216a:	5d                   	pop    %ebp
  80216b:	c3                   	ret    
  80216c:	66 90                	xchg   %ax,%ax
  80216e:	66 90                	xchg   %ax,%ax

00802170 <__udivdi3>:
  802170:	55                   	push   %ebp
  802171:	57                   	push   %edi
  802172:	56                   	push   %esi
  802173:	53                   	push   %ebx
  802174:	83 ec 1c             	sub    $0x1c,%esp
  802177:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80217b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80217f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802183:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802187:	85 f6                	test   %esi,%esi
  802189:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80218d:	89 ca                	mov    %ecx,%edx
  80218f:	89 f8                	mov    %edi,%eax
  802191:	75 3d                	jne    8021d0 <__udivdi3+0x60>
  802193:	39 cf                	cmp    %ecx,%edi
  802195:	0f 87 c5 00 00 00    	ja     802260 <__udivdi3+0xf0>
  80219b:	85 ff                	test   %edi,%edi
  80219d:	89 fd                	mov    %edi,%ebp
  80219f:	75 0b                	jne    8021ac <__udivdi3+0x3c>
  8021a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8021a6:	31 d2                	xor    %edx,%edx
  8021a8:	f7 f7                	div    %edi
  8021aa:	89 c5                	mov    %eax,%ebp
  8021ac:	89 c8                	mov    %ecx,%eax
  8021ae:	31 d2                	xor    %edx,%edx
  8021b0:	f7 f5                	div    %ebp
  8021b2:	89 c1                	mov    %eax,%ecx
  8021b4:	89 d8                	mov    %ebx,%eax
  8021b6:	89 cf                	mov    %ecx,%edi
  8021b8:	f7 f5                	div    %ebp
  8021ba:	89 c3                	mov    %eax,%ebx
  8021bc:	89 d8                	mov    %ebx,%eax
  8021be:	89 fa                	mov    %edi,%edx
  8021c0:	83 c4 1c             	add    $0x1c,%esp
  8021c3:	5b                   	pop    %ebx
  8021c4:	5e                   	pop    %esi
  8021c5:	5f                   	pop    %edi
  8021c6:	5d                   	pop    %ebp
  8021c7:	c3                   	ret    
  8021c8:	90                   	nop
  8021c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	39 ce                	cmp    %ecx,%esi
  8021d2:	77 74                	ja     802248 <__udivdi3+0xd8>
  8021d4:	0f bd fe             	bsr    %esi,%edi
  8021d7:	83 f7 1f             	xor    $0x1f,%edi
  8021da:	0f 84 98 00 00 00    	je     802278 <__udivdi3+0x108>
  8021e0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8021e5:	89 f9                	mov    %edi,%ecx
  8021e7:	89 c5                	mov    %eax,%ebp
  8021e9:	29 fb                	sub    %edi,%ebx
  8021eb:	d3 e6                	shl    %cl,%esi
  8021ed:	89 d9                	mov    %ebx,%ecx
  8021ef:	d3 ed                	shr    %cl,%ebp
  8021f1:	89 f9                	mov    %edi,%ecx
  8021f3:	d3 e0                	shl    %cl,%eax
  8021f5:	09 ee                	or     %ebp,%esi
  8021f7:	89 d9                	mov    %ebx,%ecx
  8021f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8021fd:	89 d5                	mov    %edx,%ebp
  8021ff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802203:	d3 ed                	shr    %cl,%ebp
  802205:	89 f9                	mov    %edi,%ecx
  802207:	d3 e2                	shl    %cl,%edx
  802209:	89 d9                	mov    %ebx,%ecx
  80220b:	d3 e8                	shr    %cl,%eax
  80220d:	09 c2                	or     %eax,%edx
  80220f:	89 d0                	mov    %edx,%eax
  802211:	89 ea                	mov    %ebp,%edx
  802213:	f7 f6                	div    %esi
  802215:	89 d5                	mov    %edx,%ebp
  802217:	89 c3                	mov    %eax,%ebx
  802219:	f7 64 24 0c          	mull   0xc(%esp)
  80221d:	39 d5                	cmp    %edx,%ebp
  80221f:	72 10                	jb     802231 <__udivdi3+0xc1>
  802221:	8b 74 24 08          	mov    0x8(%esp),%esi
  802225:	89 f9                	mov    %edi,%ecx
  802227:	d3 e6                	shl    %cl,%esi
  802229:	39 c6                	cmp    %eax,%esi
  80222b:	73 07                	jae    802234 <__udivdi3+0xc4>
  80222d:	39 d5                	cmp    %edx,%ebp
  80222f:	75 03                	jne    802234 <__udivdi3+0xc4>
  802231:	83 eb 01             	sub    $0x1,%ebx
  802234:	31 ff                	xor    %edi,%edi
  802236:	89 d8                	mov    %ebx,%eax
  802238:	89 fa                	mov    %edi,%edx
  80223a:	83 c4 1c             	add    $0x1c,%esp
  80223d:	5b                   	pop    %ebx
  80223e:	5e                   	pop    %esi
  80223f:	5f                   	pop    %edi
  802240:	5d                   	pop    %ebp
  802241:	c3                   	ret    
  802242:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802248:	31 ff                	xor    %edi,%edi
  80224a:	31 db                	xor    %ebx,%ebx
  80224c:	89 d8                	mov    %ebx,%eax
  80224e:	89 fa                	mov    %edi,%edx
  802250:	83 c4 1c             	add    $0x1c,%esp
  802253:	5b                   	pop    %ebx
  802254:	5e                   	pop    %esi
  802255:	5f                   	pop    %edi
  802256:	5d                   	pop    %ebp
  802257:	c3                   	ret    
  802258:	90                   	nop
  802259:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802260:	89 d8                	mov    %ebx,%eax
  802262:	f7 f7                	div    %edi
  802264:	31 ff                	xor    %edi,%edi
  802266:	89 c3                	mov    %eax,%ebx
  802268:	89 d8                	mov    %ebx,%eax
  80226a:	89 fa                	mov    %edi,%edx
  80226c:	83 c4 1c             	add    $0x1c,%esp
  80226f:	5b                   	pop    %ebx
  802270:	5e                   	pop    %esi
  802271:	5f                   	pop    %edi
  802272:	5d                   	pop    %ebp
  802273:	c3                   	ret    
  802274:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802278:	39 ce                	cmp    %ecx,%esi
  80227a:	72 0c                	jb     802288 <__udivdi3+0x118>
  80227c:	31 db                	xor    %ebx,%ebx
  80227e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802282:	0f 87 34 ff ff ff    	ja     8021bc <__udivdi3+0x4c>
  802288:	bb 01 00 00 00       	mov    $0x1,%ebx
  80228d:	e9 2a ff ff ff       	jmp    8021bc <__udivdi3+0x4c>
  802292:	66 90                	xchg   %ax,%ax
  802294:	66 90                	xchg   %ax,%ax
  802296:	66 90                	xchg   %ax,%ax
  802298:	66 90                	xchg   %ax,%ax
  80229a:	66 90                	xchg   %ax,%ax
  80229c:	66 90                	xchg   %ax,%ax
  80229e:	66 90                	xchg   %ax,%ax

008022a0 <__umoddi3>:
  8022a0:	55                   	push   %ebp
  8022a1:	57                   	push   %edi
  8022a2:	56                   	push   %esi
  8022a3:	53                   	push   %ebx
  8022a4:	83 ec 1c             	sub    $0x1c,%esp
  8022a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8022ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8022af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8022b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022b7:	85 d2                	test   %edx,%edx
  8022b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8022bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022c1:	89 f3                	mov    %esi,%ebx
  8022c3:	89 3c 24             	mov    %edi,(%esp)
  8022c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022ca:	75 1c                	jne    8022e8 <__umoddi3+0x48>
  8022cc:	39 f7                	cmp    %esi,%edi
  8022ce:	76 50                	jbe    802320 <__umoddi3+0x80>
  8022d0:	89 c8                	mov    %ecx,%eax
  8022d2:	89 f2                	mov    %esi,%edx
  8022d4:	f7 f7                	div    %edi
  8022d6:	89 d0                	mov    %edx,%eax
  8022d8:	31 d2                	xor    %edx,%edx
  8022da:	83 c4 1c             	add    $0x1c,%esp
  8022dd:	5b                   	pop    %ebx
  8022de:	5e                   	pop    %esi
  8022df:	5f                   	pop    %edi
  8022e0:	5d                   	pop    %ebp
  8022e1:	c3                   	ret    
  8022e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022e8:	39 f2                	cmp    %esi,%edx
  8022ea:	89 d0                	mov    %edx,%eax
  8022ec:	77 52                	ja     802340 <__umoddi3+0xa0>
  8022ee:	0f bd ea             	bsr    %edx,%ebp
  8022f1:	83 f5 1f             	xor    $0x1f,%ebp
  8022f4:	75 5a                	jne    802350 <__umoddi3+0xb0>
  8022f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8022fa:	0f 82 e0 00 00 00    	jb     8023e0 <__umoddi3+0x140>
  802300:	39 0c 24             	cmp    %ecx,(%esp)
  802303:	0f 86 d7 00 00 00    	jbe    8023e0 <__umoddi3+0x140>
  802309:	8b 44 24 08          	mov    0x8(%esp),%eax
  80230d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802311:	83 c4 1c             	add    $0x1c,%esp
  802314:	5b                   	pop    %ebx
  802315:	5e                   	pop    %esi
  802316:	5f                   	pop    %edi
  802317:	5d                   	pop    %ebp
  802318:	c3                   	ret    
  802319:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802320:	85 ff                	test   %edi,%edi
  802322:	89 fd                	mov    %edi,%ebp
  802324:	75 0b                	jne    802331 <__umoddi3+0x91>
  802326:	b8 01 00 00 00       	mov    $0x1,%eax
  80232b:	31 d2                	xor    %edx,%edx
  80232d:	f7 f7                	div    %edi
  80232f:	89 c5                	mov    %eax,%ebp
  802331:	89 f0                	mov    %esi,%eax
  802333:	31 d2                	xor    %edx,%edx
  802335:	f7 f5                	div    %ebp
  802337:	89 c8                	mov    %ecx,%eax
  802339:	f7 f5                	div    %ebp
  80233b:	89 d0                	mov    %edx,%eax
  80233d:	eb 99                	jmp    8022d8 <__umoddi3+0x38>
  80233f:	90                   	nop
  802340:	89 c8                	mov    %ecx,%eax
  802342:	89 f2                	mov    %esi,%edx
  802344:	83 c4 1c             	add    $0x1c,%esp
  802347:	5b                   	pop    %ebx
  802348:	5e                   	pop    %esi
  802349:	5f                   	pop    %edi
  80234a:	5d                   	pop    %ebp
  80234b:	c3                   	ret    
  80234c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802350:	8b 34 24             	mov    (%esp),%esi
  802353:	bf 20 00 00 00       	mov    $0x20,%edi
  802358:	89 e9                	mov    %ebp,%ecx
  80235a:	29 ef                	sub    %ebp,%edi
  80235c:	d3 e0                	shl    %cl,%eax
  80235e:	89 f9                	mov    %edi,%ecx
  802360:	89 f2                	mov    %esi,%edx
  802362:	d3 ea                	shr    %cl,%edx
  802364:	89 e9                	mov    %ebp,%ecx
  802366:	09 c2                	or     %eax,%edx
  802368:	89 d8                	mov    %ebx,%eax
  80236a:	89 14 24             	mov    %edx,(%esp)
  80236d:	89 f2                	mov    %esi,%edx
  80236f:	d3 e2                	shl    %cl,%edx
  802371:	89 f9                	mov    %edi,%ecx
  802373:	89 54 24 04          	mov    %edx,0x4(%esp)
  802377:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80237b:	d3 e8                	shr    %cl,%eax
  80237d:	89 e9                	mov    %ebp,%ecx
  80237f:	89 c6                	mov    %eax,%esi
  802381:	d3 e3                	shl    %cl,%ebx
  802383:	89 f9                	mov    %edi,%ecx
  802385:	89 d0                	mov    %edx,%eax
  802387:	d3 e8                	shr    %cl,%eax
  802389:	89 e9                	mov    %ebp,%ecx
  80238b:	09 d8                	or     %ebx,%eax
  80238d:	89 d3                	mov    %edx,%ebx
  80238f:	89 f2                	mov    %esi,%edx
  802391:	f7 34 24             	divl   (%esp)
  802394:	89 d6                	mov    %edx,%esi
  802396:	d3 e3                	shl    %cl,%ebx
  802398:	f7 64 24 04          	mull   0x4(%esp)
  80239c:	39 d6                	cmp    %edx,%esi
  80239e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023a2:	89 d1                	mov    %edx,%ecx
  8023a4:	89 c3                	mov    %eax,%ebx
  8023a6:	72 08                	jb     8023b0 <__umoddi3+0x110>
  8023a8:	75 11                	jne    8023bb <__umoddi3+0x11b>
  8023aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8023ae:	73 0b                	jae    8023bb <__umoddi3+0x11b>
  8023b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8023b4:	1b 14 24             	sbb    (%esp),%edx
  8023b7:	89 d1                	mov    %edx,%ecx
  8023b9:	89 c3                	mov    %eax,%ebx
  8023bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8023bf:	29 da                	sub    %ebx,%edx
  8023c1:	19 ce                	sbb    %ecx,%esi
  8023c3:	89 f9                	mov    %edi,%ecx
  8023c5:	89 f0                	mov    %esi,%eax
  8023c7:	d3 e0                	shl    %cl,%eax
  8023c9:	89 e9                	mov    %ebp,%ecx
  8023cb:	d3 ea                	shr    %cl,%edx
  8023cd:	89 e9                	mov    %ebp,%ecx
  8023cf:	d3 ee                	shr    %cl,%esi
  8023d1:	09 d0                	or     %edx,%eax
  8023d3:	89 f2                	mov    %esi,%edx
  8023d5:	83 c4 1c             	add    $0x1c,%esp
  8023d8:	5b                   	pop    %ebx
  8023d9:	5e                   	pop    %esi
  8023da:	5f                   	pop    %edi
  8023db:	5d                   	pop    %ebp
  8023dc:	c3                   	ret    
  8023dd:	8d 76 00             	lea    0x0(%esi),%esi
  8023e0:	29 f9                	sub    %edi,%ecx
  8023e2:	19 d6                	sbb    %edx,%esi
  8023e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023ec:	e9 18 ff ff ff       	jmp    802309 <__umoddi3+0x69>
