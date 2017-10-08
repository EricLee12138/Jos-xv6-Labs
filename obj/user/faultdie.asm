
obj/user/faultdie.debug：     文件格式 elf32-i386


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
  80002c:	e8 4f 00 00 00       	call   800080 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
  800039:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  80003c:	8b 42 04             	mov    0x4(%edx),%eax
  80003f:	83 e0 07             	and    $0x7,%eax
  800042:	50                   	push   %eax
  800043:	ff 32                	pushl  (%edx)
  800045:	68 e0 1e 80 00       	push   $0x801ee0
  80004a:	e8 24 01 00 00       	call   800173 <cprintf>
	sys_env_destroy(sys_getenvid());
  80004f:	e8 e8 0a 00 00       	call   800b3c <sys_getenvid>
  800054:	89 04 24             	mov    %eax,(%esp)
  800057:	e8 9f 0a 00 00       	call   800afb <sys_env_destroy>
}
  80005c:	83 c4 10             	add    $0x10,%esp
  80005f:	c9                   	leave  
  800060:	c3                   	ret    

00800061 <umain>:

void
umain(int argc, char **argv)
{
  800061:	55                   	push   %ebp
  800062:	89 e5                	mov    %esp,%ebp
  800064:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800067:	68 33 00 80 00       	push   $0x800033
  80006c:	e8 fa 0c 00 00       	call   800d6b <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800071:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800078:	00 00 00 
}
  80007b:	83 c4 10             	add    $0x10,%esp
  80007e:	c9                   	leave  
  80007f:	c3                   	ret    

00800080 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	56                   	push   %esi
  800084:	53                   	push   %ebx
  800085:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800088:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80008b:	e8 ac 0a 00 00       	call   800b3c <sys_getenvid>
  800090:	25 ff 03 00 00       	and    $0x3ff,%eax
  800095:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800098:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80009d:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a2:	85 db                	test   %ebx,%ebx
  8000a4:	7e 07                	jle    8000ad <libmain+0x2d>
		binaryname = argv[0];
  8000a6:	8b 06                	mov    (%esi),%eax
  8000a8:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ad:	83 ec 08             	sub    $0x8,%esp
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
  8000b2:	e8 aa ff ff ff       	call   800061 <umain>

	// exit gracefully
	exit();
  8000b7:	e8 0a 00 00 00       	call   8000c6 <exit>
}
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c2:	5b                   	pop    %ebx
  8000c3:	5e                   	pop    %esi
  8000c4:	5d                   	pop    %ebp
  8000c5:	c3                   	ret    

008000c6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c6:	55                   	push   %ebp
  8000c7:	89 e5                	mov    %esp,%ebp
  8000c9:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000cc:	e8 d0 0e 00 00       	call   800fa1 <close_all>
	sys_env_destroy(0);
  8000d1:	83 ec 0c             	sub    $0xc,%esp
  8000d4:	6a 00                	push   $0x0
  8000d6:	e8 20 0a 00 00       	call   800afb <sys_env_destroy>
}
  8000db:	83 c4 10             	add    $0x10,%esp
  8000de:	c9                   	leave  
  8000df:	c3                   	ret    

008000e0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	53                   	push   %ebx
  8000e4:	83 ec 04             	sub    $0x4,%esp
  8000e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ea:	8b 13                	mov    (%ebx),%edx
  8000ec:	8d 42 01             	lea    0x1(%edx),%eax
  8000ef:	89 03                	mov    %eax,(%ebx)
  8000f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000f4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000f8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000fd:	75 1a                	jne    800119 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000ff:	83 ec 08             	sub    $0x8,%esp
  800102:	68 ff 00 00 00       	push   $0xff
  800107:	8d 43 08             	lea    0x8(%ebx),%eax
  80010a:	50                   	push   %eax
  80010b:	e8 ae 09 00 00       	call   800abe <sys_cputs>
		b->idx = 0;
  800110:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800116:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800119:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80011d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800120:	c9                   	leave  
  800121:	c3                   	ret    

00800122 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80012b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800132:	00 00 00 
	b.cnt = 0;
  800135:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80013c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80013f:	ff 75 0c             	pushl  0xc(%ebp)
  800142:	ff 75 08             	pushl  0x8(%ebp)
  800145:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80014b:	50                   	push   %eax
  80014c:	68 e0 00 80 00       	push   $0x8000e0
  800151:	e8 1a 01 00 00       	call   800270 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800156:	83 c4 08             	add    $0x8,%esp
  800159:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80015f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800165:	50                   	push   %eax
  800166:	e8 53 09 00 00       	call   800abe <sys_cputs>

	return b.cnt;
}
  80016b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800171:	c9                   	leave  
  800172:	c3                   	ret    

00800173 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800173:	55                   	push   %ebp
  800174:	89 e5                	mov    %esp,%ebp
  800176:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800179:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80017c:	50                   	push   %eax
  80017d:	ff 75 08             	pushl  0x8(%ebp)
  800180:	e8 9d ff ff ff       	call   800122 <vcprintf>
	va_end(ap);

	return cnt;
}
  800185:	c9                   	leave  
  800186:	c3                   	ret    

00800187 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800187:	55                   	push   %ebp
  800188:	89 e5                	mov    %esp,%ebp
  80018a:	57                   	push   %edi
  80018b:	56                   	push   %esi
  80018c:	53                   	push   %ebx
  80018d:	83 ec 1c             	sub    $0x1c,%esp
  800190:	89 c7                	mov    %eax,%edi
  800192:	89 d6                	mov    %edx,%esi
  800194:	8b 45 08             	mov    0x8(%ebp),%eax
  800197:	8b 55 0c             	mov    0xc(%ebp),%edx
  80019a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80019d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001a3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001a8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001ab:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001ae:	39 d3                	cmp    %edx,%ebx
  8001b0:	72 05                	jb     8001b7 <printnum+0x30>
  8001b2:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001b5:	77 45                	ja     8001fc <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b7:	83 ec 0c             	sub    $0xc,%esp
  8001ba:	ff 75 18             	pushl  0x18(%ebp)
  8001bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8001c0:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001c3:	53                   	push   %ebx
  8001c4:	ff 75 10             	pushl  0x10(%ebp)
  8001c7:	83 ec 08             	sub    $0x8,%esp
  8001ca:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001cd:	ff 75 e0             	pushl  -0x20(%ebp)
  8001d0:	ff 75 dc             	pushl  -0x24(%ebp)
  8001d3:	ff 75 d8             	pushl  -0x28(%ebp)
  8001d6:	e8 65 1a 00 00       	call   801c40 <__udivdi3>
  8001db:	83 c4 18             	add    $0x18,%esp
  8001de:	52                   	push   %edx
  8001df:	50                   	push   %eax
  8001e0:	89 f2                	mov    %esi,%edx
  8001e2:	89 f8                	mov    %edi,%eax
  8001e4:	e8 9e ff ff ff       	call   800187 <printnum>
  8001e9:	83 c4 20             	add    $0x20,%esp
  8001ec:	eb 18                	jmp    800206 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001ee:	83 ec 08             	sub    $0x8,%esp
  8001f1:	56                   	push   %esi
  8001f2:	ff 75 18             	pushl  0x18(%ebp)
  8001f5:	ff d7                	call   *%edi
  8001f7:	83 c4 10             	add    $0x10,%esp
  8001fa:	eb 03                	jmp    8001ff <printnum+0x78>
  8001fc:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001ff:	83 eb 01             	sub    $0x1,%ebx
  800202:	85 db                	test   %ebx,%ebx
  800204:	7f e8                	jg     8001ee <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800206:	83 ec 08             	sub    $0x8,%esp
  800209:	56                   	push   %esi
  80020a:	83 ec 04             	sub    $0x4,%esp
  80020d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800210:	ff 75 e0             	pushl  -0x20(%ebp)
  800213:	ff 75 dc             	pushl  -0x24(%ebp)
  800216:	ff 75 d8             	pushl  -0x28(%ebp)
  800219:	e8 52 1b 00 00       	call   801d70 <__umoddi3>
  80021e:	83 c4 14             	add    $0x14,%esp
  800221:	0f be 80 06 1f 80 00 	movsbl 0x801f06(%eax),%eax
  800228:	50                   	push   %eax
  800229:	ff d7                	call   *%edi
}
  80022b:	83 c4 10             	add    $0x10,%esp
  80022e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800231:	5b                   	pop    %ebx
  800232:	5e                   	pop    %esi
  800233:	5f                   	pop    %edi
  800234:	5d                   	pop    %ebp
  800235:	c3                   	ret    

00800236 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80023c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800240:	8b 10                	mov    (%eax),%edx
  800242:	3b 50 04             	cmp    0x4(%eax),%edx
  800245:	73 0a                	jae    800251 <sprintputch+0x1b>
		*b->buf++ = ch;
  800247:	8d 4a 01             	lea    0x1(%edx),%ecx
  80024a:	89 08                	mov    %ecx,(%eax)
  80024c:	8b 45 08             	mov    0x8(%ebp),%eax
  80024f:	88 02                	mov    %al,(%edx)
}
  800251:	5d                   	pop    %ebp
  800252:	c3                   	ret    

00800253 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800253:	55                   	push   %ebp
  800254:	89 e5                	mov    %esp,%ebp
  800256:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800259:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80025c:	50                   	push   %eax
  80025d:	ff 75 10             	pushl  0x10(%ebp)
  800260:	ff 75 0c             	pushl  0xc(%ebp)
  800263:	ff 75 08             	pushl  0x8(%ebp)
  800266:	e8 05 00 00 00       	call   800270 <vprintfmt>
	va_end(ap);
}
  80026b:	83 c4 10             	add    $0x10,%esp
  80026e:	c9                   	leave  
  80026f:	c3                   	ret    

00800270 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	57                   	push   %edi
  800274:	56                   	push   %esi
  800275:	53                   	push   %ebx
  800276:	83 ec 2c             	sub    $0x2c,%esp
  800279:	8b 75 08             	mov    0x8(%ebp),%esi
  80027c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80027f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800282:	eb 12                	jmp    800296 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800284:	85 c0                	test   %eax,%eax
  800286:	0f 84 42 04 00 00    	je     8006ce <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  80028c:	83 ec 08             	sub    $0x8,%esp
  80028f:	53                   	push   %ebx
  800290:	50                   	push   %eax
  800291:	ff d6                	call   *%esi
  800293:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800296:	83 c7 01             	add    $0x1,%edi
  800299:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80029d:	83 f8 25             	cmp    $0x25,%eax
  8002a0:	75 e2                	jne    800284 <vprintfmt+0x14>
  8002a2:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002a6:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002ad:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002b4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002bb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002c0:	eb 07                	jmp    8002c9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002c5:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002c9:	8d 47 01             	lea    0x1(%edi),%eax
  8002cc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002cf:	0f b6 07             	movzbl (%edi),%eax
  8002d2:	0f b6 d0             	movzbl %al,%edx
  8002d5:	83 e8 23             	sub    $0x23,%eax
  8002d8:	3c 55                	cmp    $0x55,%al
  8002da:	0f 87 d3 03 00 00    	ja     8006b3 <vprintfmt+0x443>
  8002e0:	0f b6 c0             	movzbl %al,%eax
  8002e3:	ff 24 85 40 20 80 00 	jmp    *0x802040(,%eax,4)
  8002ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002ed:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002f1:	eb d6                	jmp    8002c9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8002fb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8002fe:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800301:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800305:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800308:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80030b:	83 f9 09             	cmp    $0x9,%ecx
  80030e:	77 3f                	ja     80034f <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800310:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800313:	eb e9                	jmp    8002fe <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800315:	8b 45 14             	mov    0x14(%ebp),%eax
  800318:	8b 00                	mov    (%eax),%eax
  80031a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80031d:	8b 45 14             	mov    0x14(%ebp),%eax
  800320:	8d 40 04             	lea    0x4(%eax),%eax
  800323:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800326:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800329:	eb 2a                	jmp    800355 <vprintfmt+0xe5>
  80032b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80032e:	85 c0                	test   %eax,%eax
  800330:	ba 00 00 00 00       	mov    $0x0,%edx
  800335:	0f 49 d0             	cmovns %eax,%edx
  800338:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80033e:	eb 89                	jmp    8002c9 <vprintfmt+0x59>
  800340:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800343:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80034a:	e9 7a ff ff ff       	jmp    8002c9 <vprintfmt+0x59>
  80034f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800352:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800355:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800359:	0f 89 6a ff ff ff    	jns    8002c9 <vprintfmt+0x59>
				width = precision, precision = -1;
  80035f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800362:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800365:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80036c:	e9 58 ff ff ff       	jmp    8002c9 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800371:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800374:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800377:	e9 4d ff ff ff       	jmp    8002c9 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80037c:	8b 45 14             	mov    0x14(%ebp),%eax
  80037f:	8d 78 04             	lea    0x4(%eax),%edi
  800382:	83 ec 08             	sub    $0x8,%esp
  800385:	53                   	push   %ebx
  800386:	ff 30                	pushl  (%eax)
  800388:	ff d6                	call   *%esi
			break;
  80038a:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80038d:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800390:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800393:	e9 fe fe ff ff       	jmp    800296 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800398:	8b 45 14             	mov    0x14(%ebp),%eax
  80039b:	8d 78 04             	lea    0x4(%eax),%edi
  80039e:	8b 00                	mov    (%eax),%eax
  8003a0:	99                   	cltd   
  8003a1:	31 d0                	xor    %edx,%eax
  8003a3:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003a5:	83 f8 0f             	cmp    $0xf,%eax
  8003a8:	7f 0b                	jg     8003b5 <vprintfmt+0x145>
  8003aa:	8b 14 85 a0 21 80 00 	mov    0x8021a0(,%eax,4),%edx
  8003b1:	85 d2                	test   %edx,%edx
  8003b3:	75 1b                	jne    8003d0 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8003b5:	50                   	push   %eax
  8003b6:	68 1e 1f 80 00       	push   $0x801f1e
  8003bb:	53                   	push   %ebx
  8003bc:	56                   	push   %esi
  8003bd:	e8 91 fe ff ff       	call   800253 <printfmt>
  8003c2:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003c5:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003cb:	e9 c6 fe ff ff       	jmp    800296 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003d0:	52                   	push   %edx
  8003d1:	68 d1 22 80 00       	push   $0x8022d1
  8003d6:	53                   	push   %ebx
  8003d7:	56                   	push   %esi
  8003d8:	e8 76 fe ff ff       	call   800253 <printfmt>
  8003dd:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003e0:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e6:	e9 ab fe ff ff       	jmp    800296 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ee:	83 c0 04             	add    $0x4,%eax
  8003f1:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003f9:	85 ff                	test   %edi,%edi
  8003fb:	b8 17 1f 80 00       	mov    $0x801f17,%eax
  800400:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800403:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800407:	0f 8e 94 00 00 00    	jle    8004a1 <vprintfmt+0x231>
  80040d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800411:	0f 84 98 00 00 00    	je     8004af <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800417:	83 ec 08             	sub    $0x8,%esp
  80041a:	ff 75 d0             	pushl  -0x30(%ebp)
  80041d:	57                   	push   %edi
  80041e:	e8 33 03 00 00       	call   800756 <strnlen>
  800423:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800426:	29 c1                	sub    %eax,%ecx
  800428:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80042b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80042e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800432:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800435:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800438:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80043a:	eb 0f                	jmp    80044b <vprintfmt+0x1db>
					putch(padc, putdat);
  80043c:	83 ec 08             	sub    $0x8,%esp
  80043f:	53                   	push   %ebx
  800440:	ff 75 e0             	pushl  -0x20(%ebp)
  800443:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800445:	83 ef 01             	sub    $0x1,%edi
  800448:	83 c4 10             	add    $0x10,%esp
  80044b:	85 ff                	test   %edi,%edi
  80044d:	7f ed                	jg     80043c <vprintfmt+0x1cc>
  80044f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800452:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800455:	85 c9                	test   %ecx,%ecx
  800457:	b8 00 00 00 00       	mov    $0x0,%eax
  80045c:	0f 49 c1             	cmovns %ecx,%eax
  80045f:	29 c1                	sub    %eax,%ecx
  800461:	89 75 08             	mov    %esi,0x8(%ebp)
  800464:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800467:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80046a:	89 cb                	mov    %ecx,%ebx
  80046c:	eb 4d                	jmp    8004bb <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80046e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800472:	74 1b                	je     80048f <vprintfmt+0x21f>
  800474:	0f be c0             	movsbl %al,%eax
  800477:	83 e8 20             	sub    $0x20,%eax
  80047a:	83 f8 5e             	cmp    $0x5e,%eax
  80047d:	76 10                	jbe    80048f <vprintfmt+0x21f>
					putch('?', putdat);
  80047f:	83 ec 08             	sub    $0x8,%esp
  800482:	ff 75 0c             	pushl  0xc(%ebp)
  800485:	6a 3f                	push   $0x3f
  800487:	ff 55 08             	call   *0x8(%ebp)
  80048a:	83 c4 10             	add    $0x10,%esp
  80048d:	eb 0d                	jmp    80049c <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80048f:	83 ec 08             	sub    $0x8,%esp
  800492:	ff 75 0c             	pushl  0xc(%ebp)
  800495:	52                   	push   %edx
  800496:	ff 55 08             	call   *0x8(%ebp)
  800499:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80049c:	83 eb 01             	sub    $0x1,%ebx
  80049f:	eb 1a                	jmp    8004bb <vprintfmt+0x24b>
  8004a1:	89 75 08             	mov    %esi,0x8(%ebp)
  8004a4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004a7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004aa:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004ad:	eb 0c                	jmp    8004bb <vprintfmt+0x24b>
  8004af:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004b5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004bb:	83 c7 01             	add    $0x1,%edi
  8004be:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004c2:	0f be d0             	movsbl %al,%edx
  8004c5:	85 d2                	test   %edx,%edx
  8004c7:	74 23                	je     8004ec <vprintfmt+0x27c>
  8004c9:	85 f6                	test   %esi,%esi
  8004cb:	78 a1                	js     80046e <vprintfmt+0x1fe>
  8004cd:	83 ee 01             	sub    $0x1,%esi
  8004d0:	79 9c                	jns    80046e <vprintfmt+0x1fe>
  8004d2:	89 df                	mov    %ebx,%edi
  8004d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004da:	eb 18                	jmp    8004f4 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004dc:	83 ec 08             	sub    $0x8,%esp
  8004df:	53                   	push   %ebx
  8004e0:	6a 20                	push   $0x20
  8004e2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004e4:	83 ef 01             	sub    $0x1,%edi
  8004e7:	83 c4 10             	add    $0x10,%esp
  8004ea:	eb 08                	jmp    8004f4 <vprintfmt+0x284>
  8004ec:	89 df                	mov    %ebx,%edi
  8004ee:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f4:	85 ff                	test   %edi,%edi
  8004f6:	7f e4                	jg     8004dc <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004f8:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004fb:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800501:	e9 90 fd ff ff       	jmp    800296 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800506:	83 f9 01             	cmp    $0x1,%ecx
  800509:	7e 19                	jle    800524 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  80050b:	8b 45 14             	mov    0x14(%ebp),%eax
  80050e:	8b 50 04             	mov    0x4(%eax),%edx
  800511:	8b 00                	mov    (%eax),%eax
  800513:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800516:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800519:	8b 45 14             	mov    0x14(%ebp),%eax
  80051c:	8d 40 08             	lea    0x8(%eax),%eax
  80051f:	89 45 14             	mov    %eax,0x14(%ebp)
  800522:	eb 38                	jmp    80055c <vprintfmt+0x2ec>
	else if (lflag)
  800524:	85 c9                	test   %ecx,%ecx
  800526:	74 1b                	je     800543 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800528:	8b 45 14             	mov    0x14(%ebp),%eax
  80052b:	8b 00                	mov    (%eax),%eax
  80052d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800530:	89 c1                	mov    %eax,%ecx
  800532:	c1 f9 1f             	sar    $0x1f,%ecx
  800535:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800538:	8b 45 14             	mov    0x14(%ebp),%eax
  80053b:	8d 40 04             	lea    0x4(%eax),%eax
  80053e:	89 45 14             	mov    %eax,0x14(%ebp)
  800541:	eb 19                	jmp    80055c <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800543:	8b 45 14             	mov    0x14(%ebp),%eax
  800546:	8b 00                	mov    (%eax),%eax
  800548:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80054b:	89 c1                	mov    %eax,%ecx
  80054d:	c1 f9 1f             	sar    $0x1f,%ecx
  800550:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800553:	8b 45 14             	mov    0x14(%ebp),%eax
  800556:	8d 40 04             	lea    0x4(%eax),%eax
  800559:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80055c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80055f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800562:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800567:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80056b:	0f 89 0e 01 00 00    	jns    80067f <vprintfmt+0x40f>
				putch('-', putdat);
  800571:	83 ec 08             	sub    $0x8,%esp
  800574:	53                   	push   %ebx
  800575:	6a 2d                	push   $0x2d
  800577:	ff d6                	call   *%esi
				num = -(long long) num;
  800579:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80057c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80057f:	f7 da                	neg    %edx
  800581:	83 d1 00             	adc    $0x0,%ecx
  800584:	f7 d9                	neg    %ecx
  800586:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800589:	b8 0a 00 00 00       	mov    $0xa,%eax
  80058e:	e9 ec 00 00 00       	jmp    80067f <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800593:	83 f9 01             	cmp    $0x1,%ecx
  800596:	7e 18                	jle    8005b0 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800598:	8b 45 14             	mov    0x14(%ebp),%eax
  80059b:	8b 10                	mov    (%eax),%edx
  80059d:	8b 48 04             	mov    0x4(%eax),%ecx
  8005a0:	8d 40 08             	lea    0x8(%eax),%eax
  8005a3:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005a6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ab:	e9 cf 00 00 00       	jmp    80067f <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8005b0:	85 c9                	test   %ecx,%ecx
  8005b2:	74 1a                	je     8005ce <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8005b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b7:	8b 10                	mov    (%eax),%edx
  8005b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005be:	8d 40 04             	lea    0x4(%eax),%eax
  8005c1:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005c4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c9:	e9 b1 00 00 00       	jmp    80067f <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8005ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d1:	8b 10                	mov    (%eax),%edx
  8005d3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d8:	8d 40 04             	lea    0x4(%eax),%eax
  8005db:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005de:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e3:	e9 97 00 00 00       	jmp    80067f <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8005e8:	83 ec 08             	sub    $0x8,%esp
  8005eb:	53                   	push   %ebx
  8005ec:	6a 58                	push   $0x58
  8005ee:	ff d6                	call   *%esi
			putch('X', putdat);
  8005f0:	83 c4 08             	add    $0x8,%esp
  8005f3:	53                   	push   %ebx
  8005f4:	6a 58                	push   $0x58
  8005f6:	ff d6                	call   *%esi
			putch('X', putdat);
  8005f8:	83 c4 08             	add    $0x8,%esp
  8005fb:	53                   	push   %ebx
  8005fc:	6a 58                	push   $0x58
  8005fe:	ff d6                	call   *%esi
			break;
  800600:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800603:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800606:	e9 8b fc ff ff       	jmp    800296 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  80060b:	83 ec 08             	sub    $0x8,%esp
  80060e:	53                   	push   %ebx
  80060f:	6a 30                	push   $0x30
  800611:	ff d6                	call   *%esi
			putch('x', putdat);
  800613:	83 c4 08             	add    $0x8,%esp
  800616:	53                   	push   %ebx
  800617:	6a 78                	push   $0x78
  800619:	ff d6                	call   *%esi
			num = (unsigned long long)
  80061b:	8b 45 14             	mov    0x14(%ebp),%eax
  80061e:	8b 10                	mov    (%eax),%edx
  800620:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800625:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800628:	8d 40 04             	lea    0x4(%eax),%eax
  80062b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80062e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800633:	eb 4a                	jmp    80067f <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800635:	83 f9 01             	cmp    $0x1,%ecx
  800638:	7e 15                	jle    80064f <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  80063a:	8b 45 14             	mov    0x14(%ebp),%eax
  80063d:	8b 10                	mov    (%eax),%edx
  80063f:	8b 48 04             	mov    0x4(%eax),%ecx
  800642:	8d 40 08             	lea    0x8(%eax),%eax
  800645:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800648:	b8 10 00 00 00       	mov    $0x10,%eax
  80064d:	eb 30                	jmp    80067f <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80064f:	85 c9                	test   %ecx,%ecx
  800651:	74 17                	je     80066a <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800653:	8b 45 14             	mov    0x14(%ebp),%eax
  800656:	8b 10                	mov    (%eax),%edx
  800658:	b9 00 00 00 00       	mov    $0x0,%ecx
  80065d:	8d 40 04             	lea    0x4(%eax),%eax
  800660:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800663:	b8 10 00 00 00       	mov    $0x10,%eax
  800668:	eb 15                	jmp    80067f <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80066a:	8b 45 14             	mov    0x14(%ebp),%eax
  80066d:	8b 10                	mov    (%eax),%edx
  80066f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800674:	8d 40 04             	lea    0x4(%eax),%eax
  800677:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80067a:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80067f:	83 ec 0c             	sub    $0xc,%esp
  800682:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800686:	57                   	push   %edi
  800687:	ff 75 e0             	pushl  -0x20(%ebp)
  80068a:	50                   	push   %eax
  80068b:	51                   	push   %ecx
  80068c:	52                   	push   %edx
  80068d:	89 da                	mov    %ebx,%edx
  80068f:	89 f0                	mov    %esi,%eax
  800691:	e8 f1 fa ff ff       	call   800187 <printnum>
			break;
  800696:	83 c4 20             	add    $0x20,%esp
  800699:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80069c:	e9 f5 fb ff ff       	jmp    800296 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006a1:	83 ec 08             	sub    $0x8,%esp
  8006a4:	53                   	push   %ebx
  8006a5:	52                   	push   %edx
  8006a6:	ff d6                	call   *%esi
			break;
  8006a8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006ae:	e9 e3 fb ff ff       	jmp    800296 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006b3:	83 ec 08             	sub    $0x8,%esp
  8006b6:	53                   	push   %ebx
  8006b7:	6a 25                	push   $0x25
  8006b9:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006bb:	83 c4 10             	add    $0x10,%esp
  8006be:	eb 03                	jmp    8006c3 <vprintfmt+0x453>
  8006c0:	83 ef 01             	sub    $0x1,%edi
  8006c3:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006c7:	75 f7                	jne    8006c0 <vprintfmt+0x450>
  8006c9:	e9 c8 fb ff ff       	jmp    800296 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006d1:	5b                   	pop    %ebx
  8006d2:	5e                   	pop    %esi
  8006d3:	5f                   	pop    %edi
  8006d4:	5d                   	pop    %ebp
  8006d5:	c3                   	ret    

008006d6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006d6:	55                   	push   %ebp
  8006d7:	89 e5                	mov    %esp,%ebp
  8006d9:	83 ec 18             	sub    $0x18,%esp
  8006dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006df:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006e5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006e9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006f3:	85 c0                	test   %eax,%eax
  8006f5:	74 26                	je     80071d <vsnprintf+0x47>
  8006f7:	85 d2                	test   %edx,%edx
  8006f9:	7e 22                	jle    80071d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006fb:	ff 75 14             	pushl  0x14(%ebp)
  8006fe:	ff 75 10             	pushl  0x10(%ebp)
  800701:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800704:	50                   	push   %eax
  800705:	68 36 02 80 00       	push   $0x800236
  80070a:	e8 61 fb ff ff       	call   800270 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80070f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800712:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800715:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800718:	83 c4 10             	add    $0x10,%esp
  80071b:	eb 05                	jmp    800722 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80071d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800722:	c9                   	leave  
  800723:	c3                   	ret    

00800724 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800724:	55                   	push   %ebp
  800725:	89 e5                	mov    %esp,%ebp
  800727:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80072a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80072d:	50                   	push   %eax
  80072e:	ff 75 10             	pushl  0x10(%ebp)
  800731:	ff 75 0c             	pushl  0xc(%ebp)
  800734:	ff 75 08             	pushl  0x8(%ebp)
  800737:	e8 9a ff ff ff       	call   8006d6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80073c:	c9                   	leave  
  80073d:	c3                   	ret    

0080073e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80073e:	55                   	push   %ebp
  80073f:	89 e5                	mov    %esp,%ebp
  800741:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800744:	b8 00 00 00 00       	mov    $0x0,%eax
  800749:	eb 03                	jmp    80074e <strlen+0x10>
		n++;
  80074b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80074e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800752:	75 f7                	jne    80074b <strlen+0xd>
		n++;
	return n;
}
  800754:	5d                   	pop    %ebp
  800755:	c3                   	ret    

00800756 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800756:	55                   	push   %ebp
  800757:	89 e5                	mov    %esp,%ebp
  800759:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80075c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075f:	ba 00 00 00 00       	mov    $0x0,%edx
  800764:	eb 03                	jmp    800769 <strnlen+0x13>
		n++;
  800766:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800769:	39 c2                	cmp    %eax,%edx
  80076b:	74 08                	je     800775 <strnlen+0x1f>
  80076d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800771:	75 f3                	jne    800766 <strnlen+0x10>
  800773:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800775:	5d                   	pop    %ebp
  800776:	c3                   	ret    

00800777 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800777:	55                   	push   %ebp
  800778:	89 e5                	mov    %esp,%ebp
  80077a:	53                   	push   %ebx
  80077b:	8b 45 08             	mov    0x8(%ebp),%eax
  80077e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800781:	89 c2                	mov    %eax,%edx
  800783:	83 c2 01             	add    $0x1,%edx
  800786:	83 c1 01             	add    $0x1,%ecx
  800789:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80078d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800790:	84 db                	test   %bl,%bl
  800792:	75 ef                	jne    800783 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800794:	5b                   	pop    %ebx
  800795:	5d                   	pop    %ebp
  800796:	c3                   	ret    

00800797 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
  80079a:	53                   	push   %ebx
  80079b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80079e:	53                   	push   %ebx
  80079f:	e8 9a ff ff ff       	call   80073e <strlen>
  8007a4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007a7:	ff 75 0c             	pushl  0xc(%ebp)
  8007aa:	01 d8                	add    %ebx,%eax
  8007ac:	50                   	push   %eax
  8007ad:	e8 c5 ff ff ff       	call   800777 <strcpy>
	return dst;
}
  8007b2:	89 d8                	mov    %ebx,%eax
  8007b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b7:	c9                   	leave  
  8007b8:	c3                   	ret    

008007b9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b9:	55                   	push   %ebp
  8007ba:	89 e5                	mov    %esp,%ebp
  8007bc:	56                   	push   %esi
  8007bd:	53                   	push   %ebx
  8007be:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c4:	89 f3                	mov    %esi,%ebx
  8007c6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c9:	89 f2                	mov    %esi,%edx
  8007cb:	eb 0f                	jmp    8007dc <strncpy+0x23>
		*dst++ = *src;
  8007cd:	83 c2 01             	add    $0x1,%edx
  8007d0:	0f b6 01             	movzbl (%ecx),%eax
  8007d3:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007d6:	80 39 01             	cmpb   $0x1,(%ecx)
  8007d9:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007dc:	39 da                	cmp    %ebx,%edx
  8007de:	75 ed                	jne    8007cd <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007e0:	89 f0                	mov    %esi,%eax
  8007e2:	5b                   	pop    %ebx
  8007e3:	5e                   	pop    %esi
  8007e4:	5d                   	pop    %ebp
  8007e5:	c3                   	ret    

008007e6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e6:	55                   	push   %ebp
  8007e7:	89 e5                	mov    %esp,%ebp
  8007e9:	56                   	push   %esi
  8007ea:	53                   	push   %ebx
  8007eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f1:	8b 55 10             	mov    0x10(%ebp),%edx
  8007f4:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f6:	85 d2                	test   %edx,%edx
  8007f8:	74 21                	je     80081b <strlcpy+0x35>
  8007fa:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007fe:	89 f2                	mov    %esi,%edx
  800800:	eb 09                	jmp    80080b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800802:	83 c2 01             	add    $0x1,%edx
  800805:	83 c1 01             	add    $0x1,%ecx
  800808:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80080b:	39 c2                	cmp    %eax,%edx
  80080d:	74 09                	je     800818 <strlcpy+0x32>
  80080f:	0f b6 19             	movzbl (%ecx),%ebx
  800812:	84 db                	test   %bl,%bl
  800814:	75 ec                	jne    800802 <strlcpy+0x1c>
  800816:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800818:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80081b:	29 f0                	sub    %esi,%eax
}
  80081d:	5b                   	pop    %ebx
  80081e:	5e                   	pop    %esi
  80081f:	5d                   	pop    %ebp
  800820:	c3                   	ret    

00800821 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800821:	55                   	push   %ebp
  800822:	89 e5                	mov    %esp,%ebp
  800824:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800827:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80082a:	eb 06                	jmp    800832 <strcmp+0x11>
		p++, q++;
  80082c:	83 c1 01             	add    $0x1,%ecx
  80082f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800832:	0f b6 01             	movzbl (%ecx),%eax
  800835:	84 c0                	test   %al,%al
  800837:	74 04                	je     80083d <strcmp+0x1c>
  800839:	3a 02                	cmp    (%edx),%al
  80083b:	74 ef                	je     80082c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80083d:	0f b6 c0             	movzbl %al,%eax
  800840:	0f b6 12             	movzbl (%edx),%edx
  800843:	29 d0                	sub    %edx,%eax
}
  800845:	5d                   	pop    %ebp
  800846:	c3                   	ret    

00800847 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
  80084a:	53                   	push   %ebx
  80084b:	8b 45 08             	mov    0x8(%ebp),%eax
  80084e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800851:	89 c3                	mov    %eax,%ebx
  800853:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800856:	eb 06                	jmp    80085e <strncmp+0x17>
		n--, p++, q++;
  800858:	83 c0 01             	add    $0x1,%eax
  80085b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80085e:	39 d8                	cmp    %ebx,%eax
  800860:	74 15                	je     800877 <strncmp+0x30>
  800862:	0f b6 08             	movzbl (%eax),%ecx
  800865:	84 c9                	test   %cl,%cl
  800867:	74 04                	je     80086d <strncmp+0x26>
  800869:	3a 0a                	cmp    (%edx),%cl
  80086b:	74 eb                	je     800858 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80086d:	0f b6 00             	movzbl (%eax),%eax
  800870:	0f b6 12             	movzbl (%edx),%edx
  800873:	29 d0                	sub    %edx,%eax
  800875:	eb 05                	jmp    80087c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800877:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80087c:	5b                   	pop    %ebx
  80087d:	5d                   	pop    %ebp
  80087e:	c3                   	ret    

0080087f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80087f:	55                   	push   %ebp
  800880:	89 e5                	mov    %esp,%ebp
  800882:	8b 45 08             	mov    0x8(%ebp),%eax
  800885:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800889:	eb 07                	jmp    800892 <strchr+0x13>
		if (*s == c)
  80088b:	38 ca                	cmp    %cl,%dl
  80088d:	74 0f                	je     80089e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80088f:	83 c0 01             	add    $0x1,%eax
  800892:	0f b6 10             	movzbl (%eax),%edx
  800895:	84 d2                	test   %dl,%dl
  800897:	75 f2                	jne    80088b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800899:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80089e:	5d                   	pop    %ebp
  80089f:	c3                   	ret    

008008a0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008aa:	eb 03                	jmp    8008af <strfind+0xf>
  8008ac:	83 c0 01             	add    $0x1,%eax
  8008af:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008b2:	38 ca                	cmp    %cl,%dl
  8008b4:	74 04                	je     8008ba <strfind+0x1a>
  8008b6:	84 d2                	test   %dl,%dl
  8008b8:	75 f2                	jne    8008ac <strfind+0xc>
			break;
	return (char *) s;
}
  8008ba:	5d                   	pop    %ebp
  8008bb:	c3                   	ret    

008008bc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
  8008bf:	57                   	push   %edi
  8008c0:	56                   	push   %esi
  8008c1:	53                   	push   %ebx
  8008c2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008c5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008c8:	85 c9                	test   %ecx,%ecx
  8008ca:	74 36                	je     800902 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008cc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008d2:	75 28                	jne    8008fc <memset+0x40>
  8008d4:	f6 c1 03             	test   $0x3,%cl
  8008d7:	75 23                	jne    8008fc <memset+0x40>
		c &= 0xFF;
  8008d9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008dd:	89 d3                	mov    %edx,%ebx
  8008df:	c1 e3 08             	shl    $0x8,%ebx
  8008e2:	89 d6                	mov    %edx,%esi
  8008e4:	c1 e6 18             	shl    $0x18,%esi
  8008e7:	89 d0                	mov    %edx,%eax
  8008e9:	c1 e0 10             	shl    $0x10,%eax
  8008ec:	09 f0                	or     %esi,%eax
  8008ee:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008f0:	89 d8                	mov    %ebx,%eax
  8008f2:	09 d0                	or     %edx,%eax
  8008f4:	c1 e9 02             	shr    $0x2,%ecx
  8008f7:	fc                   	cld    
  8008f8:	f3 ab                	rep stos %eax,%es:(%edi)
  8008fa:	eb 06                	jmp    800902 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ff:	fc                   	cld    
  800900:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800902:	89 f8                	mov    %edi,%eax
  800904:	5b                   	pop    %ebx
  800905:	5e                   	pop    %esi
  800906:	5f                   	pop    %edi
  800907:	5d                   	pop    %ebp
  800908:	c3                   	ret    

00800909 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800909:	55                   	push   %ebp
  80090a:	89 e5                	mov    %esp,%ebp
  80090c:	57                   	push   %edi
  80090d:	56                   	push   %esi
  80090e:	8b 45 08             	mov    0x8(%ebp),%eax
  800911:	8b 75 0c             	mov    0xc(%ebp),%esi
  800914:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800917:	39 c6                	cmp    %eax,%esi
  800919:	73 35                	jae    800950 <memmove+0x47>
  80091b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80091e:	39 d0                	cmp    %edx,%eax
  800920:	73 2e                	jae    800950 <memmove+0x47>
		s += n;
		d += n;
  800922:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800925:	89 d6                	mov    %edx,%esi
  800927:	09 fe                	or     %edi,%esi
  800929:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80092f:	75 13                	jne    800944 <memmove+0x3b>
  800931:	f6 c1 03             	test   $0x3,%cl
  800934:	75 0e                	jne    800944 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800936:	83 ef 04             	sub    $0x4,%edi
  800939:	8d 72 fc             	lea    -0x4(%edx),%esi
  80093c:	c1 e9 02             	shr    $0x2,%ecx
  80093f:	fd                   	std    
  800940:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800942:	eb 09                	jmp    80094d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800944:	83 ef 01             	sub    $0x1,%edi
  800947:	8d 72 ff             	lea    -0x1(%edx),%esi
  80094a:	fd                   	std    
  80094b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80094d:	fc                   	cld    
  80094e:	eb 1d                	jmp    80096d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800950:	89 f2                	mov    %esi,%edx
  800952:	09 c2                	or     %eax,%edx
  800954:	f6 c2 03             	test   $0x3,%dl
  800957:	75 0f                	jne    800968 <memmove+0x5f>
  800959:	f6 c1 03             	test   $0x3,%cl
  80095c:	75 0a                	jne    800968 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80095e:	c1 e9 02             	shr    $0x2,%ecx
  800961:	89 c7                	mov    %eax,%edi
  800963:	fc                   	cld    
  800964:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800966:	eb 05                	jmp    80096d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800968:	89 c7                	mov    %eax,%edi
  80096a:	fc                   	cld    
  80096b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80096d:	5e                   	pop    %esi
  80096e:	5f                   	pop    %edi
  80096f:	5d                   	pop    %ebp
  800970:	c3                   	ret    

00800971 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800971:	55                   	push   %ebp
  800972:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800974:	ff 75 10             	pushl  0x10(%ebp)
  800977:	ff 75 0c             	pushl  0xc(%ebp)
  80097a:	ff 75 08             	pushl  0x8(%ebp)
  80097d:	e8 87 ff ff ff       	call   800909 <memmove>
}
  800982:	c9                   	leave  
  800983:	c3                   	ret    

00800984 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	56                   	push   %esi
  800988:	53                   	push   %ebx
  800989:	8b 45 08             	mov    0x8(%ebp),%eax
  80098c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098f:	89 c6                	mov    %eax,%esi
  800991:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800994:	eb 1a                	jmp    8009b0 <memcmp+0x2c>
		if (*s1 != *s2)
  800996:	0f b6 08             	movzbl (%eax),%ecx
  800999:	0f b6 1a             	movzbl (%edx),%ebx
  80099c:	38 d9                	cmp    %bl,%cl
  80099e:	74 0a                	je     8009aa <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009a0:	0f b6 c1             	movzbl %cl,%eax
  8009a3:	0f b6 db             	movzbl %bl,%ebx
  8009a6:	29 d8                	sub    %ebx,%eax
  8009a8:	eb 0f                	jmp    8009b9 <memcmp+0x35>
		s1++, s2++;
  8009aa:	83 c0 01             	add    $0x1,%eax
  8009ad:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b0:	39 f0                	cmp    %esi,%eax
  8009b2:	75 e2                	jne    800996 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b9:	5b                   	pop    %ebx
  8009ba:	5e                   	pop    %esi
  8009bb:	5d                   	pop    %ebp
  8009bc:	c3                   	ret    

008009bd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	53                   	push   %ebx
  8009c1:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009c4:	89 c1                	mov    %eax,%ecx
  8009c6:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009c9:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009cd:	eb 0a                	jmp    8009d9 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009cf:	0f b6 10             	movzbl (%eax),%edx
  8009d2:	39 da                	cmp    %ebx,%edx
  8009d4:	74 07                	je     8009dd <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d6:	83 c0 01             	add    $0x1,%eax
  8009d9:	39 c8                	cmp    %ecx,%eax
  8009db:	72 f2                	jb     8009cf <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009dd:	5b                   	pop    %ebx
  8009de:	5d                   	pop    %ebp
  8009df:	c3                   	ret    

008009e0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	57                   	push   %edi
  8009e4:	56                   	push   %esi
  8009e5:	53                   	push   %ebx
  8009e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ec:	eb 03                	jmp    8009f1 <strtol+0x11>
		s++;
  8009ee:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f1:	0f b6 01             	movzbl (%ecx),%eax
  8009f4:	3c 20                	cmp    $0x20,%al
  8009f6:	74 f6                	je     8009ee <strtol+0xe>
  8009f8:	3c 09                	cmp    $0x9,%al
  8009fa:	74 f2                	je     8009ee <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009fc:	3c 2b                	cmp    $0x2b,%al
  8009fe:	75 0a                	jne    800a0a <strtol+0x2a>
		s++;
  800a00:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a03:	bf 00 00 00 00       	mov    $0x0,%edi
  800a08:	eb 11                	jmp    800a1b <strtol+0x3b>
  800a0a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a0f:	3c 2d                	cmp    $0x2d,%al
  800a11:	75 08                	jne    800a1b <strtol+0x3b>
		s++, neg = 1;
  800a13:	83 c1 01             	add    $0x1,%ecx
  800a16:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a1b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a21:	75 15                	jne    800a38 <strtol+0x58>
  800a23:	80 39 30             	cmpb   $0x30,(%ecx)
  800a26:	75 10                	jne    800a38 <strtol+0x58>
  800a28:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a2c:	75 7c                	jne    800aaa <strtol+0xca>
		s += 2, base = 16;
  800a2e:	83 c1 02             	add    $0x2,%ecx
  800a31:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a36:	eb 16                	jmp    800a4e <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a38:	85 db                	test   %ebx,%ebx
  800a3a:	75 12                	jne    800a4e <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a3c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a41:	80 39 30             	cmpb   $0x30,(%ecx)
  800a44:	75 08                	jne    800a4e <strtol+0x6e>
		s++, base = 8;
  800a46:	83 c1 01             	add    $0x1,%ecx
  800a49:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a4e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a53:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a56:	0f b6 11             	movzbl (%ecx),%edx
  800a59:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a5c:	89 f3                	mov    %esi,%ebx
  800a5e:	80 fb 09             	cmp    $0x9,%bl
  800a61:	77 08                	ja     800a6b <strtol+0x8b>
			dig = *s - '0';
  800a63:	0f be d2             	movsbl %dl,%edx
  800a66:	83 ea 30             	sub    $0x30,%edx
  800a69:	eb 22                	jmp    800a8d <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a6b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a6e:	89 f3                	mov    %esi,%ebx
  800a70:	80 fb 19             	cmp    $0x19,%bl
  800a73:	77 08                	ja     800a7d <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a75:	0f be d2             	movsbl %dl,%edx
  800a78:	83 ea 57             	sub    $0x57,%edx
  800a7b:	eb 10                	jmp    800a8d <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a7d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a80:	89 f3                	mov    %esi,%ebx
  800a82:	80 fb 19             	cmp    $0x19,%bl
  800a85:	77 16                	ja     800a9d <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a87:	0f be d2             	movsbl %dl,%edx
  800a8a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a8d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a90:	7d 0b                	jge    800a9d <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a92:	83 c1 01             	add    $0x1,%ecx
  800a95:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a99:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a9b:	eb b9                	jmp    800a56 <strtol+0x76>

	if (endptr)
  800a9d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aa1:	74 0d                	je     800ab0 <strtol+0xd0>
		*endptr = (char *) s;
  800aa3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa6:	89 0e                	mov    %ecx,(%esi)
  800aa8:	eb 06                	jmp    800ab0 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aaa:	85 db                	test   %ebx,%ebx
  800aac:	74 98                	je     800a46 <strtol+0x66>
  800aae:	eb 9e                	jmp    800a4e <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ab0:	89 c2                	mov    %eax,%edx
  800ab2:	f7 da                	neg    %edx
  800ab4:	85 ff                	test   %edi,%edi
  800ab6:	0f 45 c2             	cmovne %edx,%eax
}
  800ab9:	5b                   	pop    %ebx
  800aba:	5e                   	pop    %esi
  800abb:	5f                   	pop    %edi
  800abc:	5d                   	pop    %ebp
  800abd:	c3                   	ret    

00800abe <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800abe:	55                   	push   %ebp
  800abf:	89 e5                	mov    %esp,%ebp
  800ac1:	57                   	push   %edi
  800ac2:	56                   	push   %esi
  800ac3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800acc:	8b 55 08             	mov    0x8(%ebp),%edx
  800acf:	89 c3                	mov    %eax,%ebx
  800ad1:	89 c7                	mov    %eax,%edi
  800ad3:	89 c6                	mov    %eax,%esi
  800ad5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ad7:	5b                   	pop    %ebx
  800ad8:	5e                   	pop    %esi
  800ad9:	5f                   	pop    %edi
  800ada:	5d                   	pop    %ebp
  800adb:	c3                   	ret    

00800adc <sys_cgetc>:

int
sys_cgetc(void)
{
  800adc:	55                   	push   %ebp
  800add:	89 e5                	mov    %esp,%ebp
  800adf:	57                   	push   %edi
  800ae0:	56                   	push   %esi
  800ae1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae7:	b8 01 00 00 00       	mov    $0x1,%eax
  800aec:	89 d1                	mov    %edx,%ecx
  800aee:	89 d3                	mov    %edx,%ebx
  800af0:	89 d7                	mov    %edx,%edi
  800af2:	89 d6                	mov    %edx,%esi
  800af4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800af6:	5b                   	pop    %ebx
  800af7:	5e                   	pop    %esi
  800af8:	5f                   	pop    %edi
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	57                   	push   %edi
  800aff:	56                   	push   %esi
  800b00:	53                   	push   %ebx
  800b01:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b04:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b09:	b8 03 00 00 00       	mov    $0x3,%eax
  800b0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b11:	89 cb                	mov    %ecx,%ebx
  800b13:	89 cf                	mov    %ecx,%edi
  800b15:	89 ce                	mov    %ecx,%esi
  800b17:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b19:	85 c0                	test   %eax,%eax
  800b1b:	7e 17                	jle    800b34 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b1d:	83 ec 0c             	sub    $0xc,%esp
  800b20:	50                   	push   %eax
  800b21:	6a 03                	push   $0x3
  800b23:	68 ff 21 80 00       	push   $0x8021ff
  800b28:	6a 23                	push   $0x23
  800b2a:	68 1c 22 80 00       	push   $0x80221c
  800b2f:	e8 8c 0f 00 00       	call   801ac0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b37:	5b                   	pop    %ebx
  800b38:	5e                   	pop    %esi
  800b39:	5f                   	pop    %edi
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	57                   	push   %edi
  800b40:	56                   	push   %esi
  800b41:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b42:	ba 00 00 00 00       	mov    $0x0,%edx
  800b47:	b8 02 00 00 00       	mov    $0x2,%eax
  800b4c:	89 d1                	mov    %edx,%ecx
  800b4e:	89 d3                	mov    %edx,%ebx
  800b50:	89 d7                	mov    %edx,%edi
  800b52:	89 d6                	mov    %edx,%esi
  800b54:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b56:	5b                   	pop    %ebx
  800b57:	5e                   	pop    %esi
  800b58:	5f                   	pop    %edi
  800b59:	5d                   	pop    %ebp
  800b5a:	c3                   	ret    

00800b5b <sys_yield>:

void
sys_yield(void)
{
  800b5b:	55                   	push   %ebp
  800b5c:	89 e5                	mov    %esp,%ebp
  800b5e:	57                   	push   %edi
  800b5f:	56                   	push   %esi
  800b60:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b61:	ba 00 00 00 00       	mov    $0x0,%edx
  800b66:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b6b:	89 d1                	mov    %edx,%ecx
  800b6d:	89 d3                	mov    %edx,%ebx
  800b6f:	89 d7                	mov    %edx,%edi
  800b71:	89 d6                	mov    %edx,%esi
  800b73:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b75:	5b                   	pop    %ebx
  800b76:	5e                   	pop    %esi
  800b77:	5f                   	pop    %edi
  800b78:	5d                   	pop    %ebp
  800b79:	c3                   	ret    

00800b7a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	57                   	push   %edi
  800b7e:	56                   	push   %esi
  800b7f:	53                   	push   %ebx
  800b80:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b83:	be 00 00 00 00       	mov    $0x0,%esi
  800b88:	b8 04 00 00 00       	mov    $0x4,%eax
  800b8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b90:	8b 55 08             	mov    0x8(%ebp),%edx
  800b93:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b96:	89 f7                	mov    %esi,%edi
  800b98:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b9a:	85 c0                	test   %eax,%eax
  800b9c:	7e 17                	jle    800bb5 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9e:	83 ec 0c             	sub    $0xc,%esp
  800ba1:	50                   	push   %eax
  800ba2:	6a 04                	push   $0x4
  800ba4:	68 ff 21 80 00       	push   $0x8021ff
  800ba9:	6a 23                	push   $0x23
  800bab:	68 1c 22 80 00       	push   $0x80221c
  800bb0:	e8 0b 0f 00 00       	call   801ac0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bb5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb8:	5b                   	pop    %ebx
  800bb9:	5e                   	pop    %esi
  800bba:	5f                   	pop    %edi
  800bbb:	5d                   	pop    %ebp
  800bbc:	c3                   	ret    

00800bbd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	57                   	push   %edi
  800bc1:	56                   	push   %esi
  800bc2:	53                   	push   %ebx
  800bc3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc6:	b8 05 00 00 00       	mov    $0x5,%eax
  800bcb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bce:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bd7:	8b 75 18             	mov    0x18(%ebp),%esi
  800bda:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bdc:	85 c0                	test   %eax,%eax
  800bde:	7e 17                	jle    800bf7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be0:	83 ec 0c             	sub    $0xc,%esp
  800be3:	50                   	push   %eax
  800be4:	6a 05                	push   $0x5
  800be6:	68 ff 21 80 00       	push   $0x8021ff
  800beb:	6a 23                	push   $0x23
  800bed:	68 1c 22 80 00       	push   $0x80221c
  800bf2:	e8 c9 0e 00 00       	call   801ac0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bf7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfa:	5b                   	pop    %ebx
  800bfb:	5e                   	pop    %esi
  800bfc:	5f                   	pop    %edi
  800bfd:	5d                   	pop    %ebp
  800bfe:	c3                   	ret    

00800bff <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	57                   	push   %edi
  800c03:	56                   	push   %esi
  800c04:	53                   	push   %ebx
  800c05:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c08:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c0d:	b8 06 00 00 00       	mov    $0x6,%eax
  800c12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c15:	8b 55 08             	mov    0x8(%ebp),%edx
  800c18:	89 df                	mov    %ebx,%edi
  800c1a:	89 de                	mov    %ebx,%esi
  800c1c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c1e:	85 c0                	test   %eax,%eax
  800c20:	7e 17                	jle    800c39 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c22:	83 ec 0c             	sub    $0xc,%esp
  800c25:	50                   	push   %eax
  800c26:	6a 06                	push   $0x6
  800c28:	68 ff 21 80 00       	push   $0x8021ff
  800c2d:	6a 23                	push   $0x23
  800c2f:	68 1c 22 80 00       	push   $0x80221c
  800c34:	e8 87 0e 00 00       	call   801ac0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3c:	5b                   	pop    %ebx
  800c3d:	5e                   	pop    %esi
  800c3e:	5f                   	pop    %edi
  800c3f:	5d                   	pop    %ebp
  800c40:	c3                   	ret    

00800c41 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c41:	55                   	push   %ebp
  800c42:	89 e5                	mov    %esp,%ebp
  800c44:	57                   	push   %edi
  800c45:	56                   	push   %esi
  800c46:	53                   	push   %ebx
  800c47:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4f:	b8 08 00 00 00       	mov    $0x8,%eax
  800c54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c57:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5a:	89 df                	mov    %ebx,%edi
  800c5c:	89 de                	mov    %ebx,%esi
  800c5e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c60:	85 c0                	test   %eax,%eax
  800c62:	7e 17                	jle    800c7b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c64:	83 ec 0c             	sub    $0xc,%esp
  800c67:	50                   	push   %eax
  800c68:	6a 08                	push   $0x8
  800c6a:	68 ff 21 80 00       	push   $0x8021ff
  800c6f:	6a 23                	push   $0x23
  800c71:	68 1c 22 80 00       	push   $0x80221c
  800c76:	e8 45 0e 00 00       	call   801ac0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7e:	5b                   	pop    %ebx
  800c7f:	5e                   	pop    %esi
  800c80:	5f                   	pop    %edi
  800c81:	5d                   	pop    %ebp
  800c82:	c3                   	ret    

00800c83 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c83:	55                   	push   %ebp
  800c84:	89 e5                	mov    %esp,%ebp
  800c86:	57                   	push   %edi
  800c87:	56                   	push   %esi
  800c88:	53                   	push   %ebx
  800c89:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c91:	b8 09 00 00 00       	mov    $0x9,%eax
  800c96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c99:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9c:	89 df                	mov    %ebx,%edi
  800c9e:	89 de                	mov    %ebx,%esi
  800ca0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ca2:	85 c0                	test   %eax,%eax
  800ca4:	7e 17                	jle    800cbd <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca6:	83 ec 0c             	sub    $0xc,%esp
  800ca9:	50                   	push   %eax
  800caa:	6a 09                	push   $0x9
  800cac:	68 ff 21 80 00       	push   $0x8021ff
  800cb1:	6a 23                	push   $0x23
  800cb3:	68 1c 22 80 00       	push   $0x80221c
  800cb8:	e8 03 0e 00 00       	call   801ac0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc0:	5b                   	pop    %ebx
  800cc1:	5e                   	pop    %esi
  800cc2:	5f                   	pop    %edi
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    

00800cc5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	57                   	push   %edi
  800cc9:	56                   	push   %esi
  800cca:	53                   	push   %ebx
  800ccb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cce:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd3:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cde:	89 df                	mov    %ebx,%edi
  800ce0:	89 de                	mov    %ebx,%esi
  800ce2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce4:	85 c0                	test   %eax,%eax
  800ce6:	7e 17                	jle    800cff <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce8:	83 ec 0c             	sub    $0xc,%esp
  800ceb:	50                   	push   %eax
  800cec:	6a 0a                	push   $0xa
  800cee:	68 ff 21 80 00       	push   $0x8021ff
  800cf3:	6a 23                	push   $0x23
  800cf5:	68 1c 22 80 00       	push   $0x80221c
  800cfa:	e8 c1 0d 00 00       	call   801ac0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d02:	5b                   	pop    %ebx
  800d03:	5e                   	pop    %esi
  800d04:	5f                   	pop    %edi
  800d05:	5d                   	pop    %ebp
  800d06:	c3                   	ret    

00800d07 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	57                   	push   %edi
  800d0b:	56                   	push   %esi
  800d0c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0d:	be 00 00 00 00       	mov    $0x0,%esi
  800d12:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d20:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d23:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d25:	5b                   	pop    %ebx
  800d26:	5e                   	pop    %esi
  800d27:	5f                   	pop    %edi
  800d28:	5d                   	pop    %ebp
  800d29:	c3                   	ret    

00800d2a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	57                   	push   %edi
  800d2e:	56                   	push   %esi
  800d2f:	53                   	push   %ebx
  800d30:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d33:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d38:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d40:	89 cb                	mov    %ecx,%ebx
  800d42:	89 cf                	mov    %ecx,%edi
  800d44:	89 ce                	mov    %ecx,%esi
  800d46:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d48:	85 c0                	test   %eax,%eax
  800d4a:	7e 17                	jle    800d63 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4c:	83 ec 0c             	sub    $0xc,%esp
  800d4f:	50                   	push   %eax
  800d50:	6a 0d                	push   $0xd
  800d52:	68 ff 21 80 00       	push   $0x8021ff
  800d57:	6a 23                	push   $0x23
  800d59:	68 1c 22 80 00       	push   $0x80221c
  800d5e:	e8 5d 0d 00 00       	call   801ac0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d66:	5b                   	pop    %ebx
  800d67:	5e                   	pop    %esi
  800d68:	5f                   	pop    %edi
  800d69:	5d                   	pop    %ebp
  800d6a:	c3                   	ret    

00800d6b <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	53                   	push   %ebx
  800d6f:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d72:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800d79:	75 28                	jne    800da3 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		void *va = (void *) (UXSTACKTOP - PGSIZE);
		envid_t envid = sys_getenvid();
  800d7b:	e8 bc fd ff ff       	call   800b3c <sys_getenvid>
  800d80:	89 c3                	mov    %eax,%ebx

		sys_page_alloc(envid, va, PTE_P | PTE_U | PTE_W);
  800d82:	83 ec 04             	sub    $0x4,%esp
  800d85:	6a 07                	push   $0x7
  800d87:	68 00 f0 bf ee       	push   $0xeebff000
  800d8c:	50                   	push   %eax
  800d8d:	e8 e8 fd ff ff       	call   800b7a <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  800d92:	83 c4 08             	add    $0x8,%esp
  800d95:	68 b0 0d 80 00       	push   $0x800db0
  800d9a:	53                   	push   %ebx
  800d9b:	e8 25 ff ff ff       	call   800cc5 <sys_env_set_pgfault_upcall>
  800da0:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800da3:	8b 45 08             	mov    0x8(%ebp),%eax
  800da6:	a3 08 40 80 00       	mov    %eax,0x804008
}
  800dab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dae:	c9                   	leave  
  800daf:	c3                   	ret    

00800db0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp				// function argument: pointer to UTF
  800db0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800db1:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800db6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800db8:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp, %ebx		// 40 = size between utf_fault_va ~ utf_regs
  800dbb:	89 e3                	mov    %esp,%ebx
	movl 40(%esp), %eax // point to utf_eip
  800dbd:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %esp // point to utf_esp
  800dc1:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax 			// push eip of utf
  800dc5:	50                   	push   %eax

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx, %esp 	// back to origin exception stack
  800dc6:	89 dc                	mov    %ebx,%esp
	subl $4, 48(%esp) 	// utf_esp - 4
  800dc8:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	popl %eax  			// pop utf_fault_va (ignore)
  800dcd:	58                   	pop    %eax
	popl %eax  			// pop utf_err (ignore)
  800dce:	58                   	pop    %eax
	popal 				// pop utf_regs 
  800dcf:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4, %esp 		// ignore utf_eip
  800dd0:	83 c4 04             	add    $0x4,%esp
	popfl 				// restore utf_eflags to eflags
  800dd3:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp  			// restore %esp = utf_esp
  800dd4:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800dd5:	c3                   	ret    

00800dd6 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dd6:	55                   	push   %ebp
  800dd7:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800ddc:	05 00 00 00 30       	add    $0x30000000,%eax
  800de1:	c1 e8 0c             	shr    $0xc,%eax
}
  800de4:	5d                   	pop    %ebp
  800de5:	c3                   	ret    

00800de6 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800de6:	55                   	push   %ebp
  800de7:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800de9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dec:	05 00 00 00 30       	add    $0x30000000,%eax
  800df1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800df6:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800dfb:	5d                   	pop    %ebp
  800dfc:	c3                   	ret    

00800dfd <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800dfd:	55                   	push   %ebp
  800dfe:	89 e5                	mov    %esp,%ebp
  800e00:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e03:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e08:	89 c2                	mov    %eax,%edx
  800e0a:	c1 ea 16             	shr    $0x16,%edx
  800e0d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e14:	f6 c2 01             	test   $0x1,%dl
  800e17:	74 11                	je     800e2a <fd_alloc+0x2d>
  800e19:	89 c2                	mov    %eax,%edx
  800e1b:	c1 ea 0c             	shr    $0xc,%edx
  800e1e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e25:	f6 c2 01             	test   $0x1,%dl
  800e28:	75 09                	jne    800e33 <fd_alloc+0x36>
			*fd_store = fd;
  800e2a:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e2c:	b8 00 00 00 00       	mov    $0x0,%eax
  800e31:	eb 17                	jmp    800e4a <fd_alloc+0x4d>
  800e33:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e38:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e3d:	75 c9                	jne    800e08 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e3f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e45:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e4a:	5d                   	pop    %ebp
  800e4b:	c3                   	ret    

00800e4c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e52:	83 f8 1f             	cmp    $0x1f,%eax
  800e55:	77 36                	ja     800e8d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e57:	c1 e0 0c             	shl    $0xc,%eax
  800e5a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e5f:	89 c2                	mov    %eax,%edx
  800e61:	c1 ea 16             	shr    $0x16,%edx
  800e64:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e6b:	f6 c2 01             	test   $0x1,%dl
  800e6e:	74 24                	je     800e94 <fd_lookup+0x48>
  800e70:	89 c2                	mov    %eax,%edx
  800e72:	c1 ea 0c             	shr    $0xc,%edx
  800e75:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e7c:	f6 c2 01             	test   $0x1,%dl
  800e7f:	74 1a                	je     800e9b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e81:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e84:	89 02                	mov    %eax,(%edx)
	return 0;
  800e86:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8b:	eb 13                	jmp    800ea0 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e8d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e92:	eb 0c                	jmp    800ea0 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e94:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e99:	eb 05                	jmp    800ea0 <fd_lookup+0x54>
  800e9b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ea0:	5d                   	pop    %ebp
  800ea1:	c3                   	ret    

00800ea2 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ea2:	55                   	push   %ebp
  800ea3:	89 e5                	mov    %esp,%ebp
  800ea5:	83 ec 08             	sub    $0x8,%esp
  800ea8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eab:	ba a8 22 80 00       	mov    $0x8022a8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800eb0:	eb 13                	jmp    800ec5 <dev_lookup+0x23>
  800eb2:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800eb5:	39 08                	cmp    %ecx,(%eax)
  800eb7:	75 0c                	jne    800ec5 <dev_lookup+0x23>
			*dev = devtab[i];
  800eb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ebc:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ebe:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec3:	eb 2e                	jmp    800ef3 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ec5:	8b 02                	mov    (%edx),%eax
  800ec7:	85 c0                	test   %eax,%eax
  800ec9:	75 e7                	jne    800eb2 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ecb:	a1 04 40 80 00       	mov    0x804004,%eax
  800ed0:	8b 40 48             	mov    0x48(%eax),%eax
  800ed3:	83 ec 04             	sub    $0x4,%esp
  800ed6:	51                   	push   %ecx
  800ed7:	50                   	push   %eax
  800ed8:	68 2c 22 80 00       	push   $0x80222c
  800edd:	e8 91 f2 ff ff       	call   800173 <cprintf>
	*dev = 0;
  800ee2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ee5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800eeb:	83 c4 10             	add    $0x10,%esp
  800eee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ef3:	c9                   	leave  
  800ef4:	c3                   	ret    

00800ef5 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800ef5:	55                   	push   %ebp
  800ef6:	89 e5                	mov    %esp,%ebp
  800ef8:	56                   	push   %esi
  800ef9:	53                   	push   %ebx
  800efa:	83 ec 10             	sub    $0x10,%esp
  800efd:	8b 75 08             	mov    0x8(%ebp),%esi
  800f00:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f03:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f06:	50                   	push   %eax
  800f07:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f0d:	c1 e8 0c             	shr    $0xc,%eax
  800f10:	50                   	push   %eax
  800f11:	e8 36 ff ff ff       	call   800e4c <fd_lookup>
  800f16:	83 c4 08             	add    $0x8,%esp
  800f19:	85 c0                	test   %eax,%eax
  800f1b:	78 05                	js     800f22 <fd_close+0x2d>
	    || fd != fd2)
  800f1d:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f20:	74 0c                	je     800f2e <fd_close+0x39>
		return (must_exist ? r : 0);
  800f22:	84 db                	test   %bl,%bl
  800f24:	ba 00 00 00 00       	mov    $0x0,%edx
  800f29:	0f 44 c2             	cmove  %edx,%eax
  800f2c:	eb 41                	jmp    800f6f <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f2e:	83 ec 08             	sub    $0x8,%esp
  800f31:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f34:	50                   	push   %eax
  800f35:	ff 36                	pushl  (%esi)
  800f37:	e8 66 ff ff ff       	call   800ea2 <dev_lookup>
  800f3c:	89 c3                	mov    %eax,%ebx
  800f3e:	83 c4 10             	add    $0x10,%esp
  800f41:	85 c0                	test   %eax,%eax
  800f43:	78 1a                	js     800f5f <fd_close+0x6a>
		if (dev->dev_close)
  800f45:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f48:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f4b:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f50:	85 c0                	test   %eax,%eax
  800f52:	74 0b                	je     800f5f <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f54:	83 ec 0c             	sub    $0xc,%esp
  800f57:	56                   	push   %esi
  800f58:	ff d0                	call   *%eax
  800f5a:	89 c3                	mov    %eax,%ebx
  800f5c:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f5f:	83 ec 08             	sub    $0x8,%esp
  800f62:	56                   	push   %esi
  800f63:	6a 00                	push   $0x0
  800f65:	e8 95 fc ff ff       	call   800bff <sys_page_unmap>
	return r;
  800f6a:	83 c4 10             	add    $0x10,%esp
  800f6d:	89 d8                	mov    %ebx,%eax
}
  800f6f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f72:	5b                   	pop    %ebx
  800f73:	5e                   	pop    %esi
  800f74:	5d                   	pop    %ebp
  800f75:	c3                   	ret    

00800f76 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f76:	55                   	push   %ebp
  800f77:	89 e5                	mov    %esp,%ebp
  800f79:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f7c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f7f:	50                   	push   %eax
  800f80:	ff 75 08             	pushl  0x8(%ebp)
  800f83:	e8 c4 fe ff ff       	call   800e4c <fd_lookup>
  800f88:	83 c4 08             	add    $0x8,%esp
  800f8b:	85 c0                	test   %eax,%eax
  800f8d:	78 10                	js     800f9f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f8f:	83 ec 08             	sub    $0x8,%esp
  800f92:	6a 01                	push   $0x1
  800f94:	ff 75 f4             	pushl  -0xc(%ebp)
  800f97:	e8 59 ff ff ff       	call   800ef5 <fd_close>
  800f9c:	83 c4 10             	add    $0x10,%esp
}
  800f9f:	c9                   	leave  
  800fa0:	c3                   	ret    

00800fa1 <close_all>:

void
close_all(void)
{
  800fa1:	55                   	push   %ebp
  800fa2:	89 e5                	mov    %esp,%ebp
  800fa4:	53                   	push   %ebx
  800fa5:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fa8:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fad:	83 ec 0c             	sub    $0xc,%esp
  800fb0:	53                   	push   %ebx
  800fb1:	e8 c0 ff ff ff       	call   800f76 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fb6:	83 c3 01             	add    $0x1,%ebx
  800fb9:	83 c4 10             	add    $0x10,%esp
  800fbc:	83 fb 20             	cmp    $0x20,%ebx
  800fbf:	75 ec                	jne    800fad <close_all+0xc>
		close(i);
}
  800fc1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fc4:	c9                   	leave  
  800fc5:	c3                   	ret    

00800fc6 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fc6:	55                   	push   %ebp
  800fc7:	89 e5                	mov    %esp,%ebp
  800fc9:	57                   	push   %edi
  800fca:	56                   	push   %esi
  800fcb:	53                   	push   %ebx
  800fcc:	83 ec 2c             	sub    $0x2c,%esp
  800fcf:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fd2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fd5:	50                   	push   %eax
  800fd6:	ff 75 08             	pushl  0x8(%ebp)
  800fd9:	e8 6e fe ff ff       	call   800e4c <fd_lookup>
  800fde:	83 c4 08             	add    $0x8,%esp
  800fe1:	85 c0                	test   %eax,%eax
  800fe3:	0f 88 c1 00 00 00    	js     8010aa <dup+0xe4>
		return r;
	close(newfdnum);
  800fe9:	83 ec 0c             	sub    $0xc,%esp
  800fec:	56                   	push   %esi
  800fed:	e8 84 ff ff ff       	call   800f76 <close>

	newfd = INDEX2FD(newfdnum);
  800ff2:	89 f3                	mov    %esi,%ebx
  800ff4:	c1 e3 0c             	shl    $0xc,%ebx
  800ff7:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800ffd:	83 c4 04             	add    $0x4,%esp
  801000:	ff 75 e4             	pushl  -0x1c(%ebp)
  801003:	e8 de fd ff ff       	call   800de6 <fd2data>
  801008:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80100a:	89 1c 24             	mov    %ebx,(%esp)
  80100d:	e8 d4 fd ff ff       	call   800de6 <fd2data>
  801012:	83 c4 10             	add    $0x10,%esp
  801015:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801018:	89 f8                	mov    %edi,%eax
  80101a:	c1 e8 16             	shr    $0x16,%eax
  80101d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801024:	a8 01                	test   $0x1,%al
  801026:	74 37                	je     80105f <dup+0x99>
  801028:	89 f8                	mov    %edi,%eax
  80102a:	c1 e8 0c             	shr    $0xc,%eax
  80102d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801034:	f6 c2 01             	test   $0x1,%dl
  801037:	74 26                	je     80105f <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801039:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801040:	83 ec 0c             	sub    $0xc,%esp
  801043:	25 07 0e 00 00       	and    $0xe07,%eax
  801048:	50                   	push   %eax
  801049:	ff 75 d4             	pushl  -0x2c(%ebp)
  80104c:	6a 00                	push   $0x0
  80104e:	57                   	push   %edi
  80104f:	6a 00                	push   $0x0
  801051:	e8 67 fb ff ff       	call   800bbd <sys_page_map>
  801056:	89 c7                	mov    %eax,%edi
  801058:	83 c4 20             	add    $0x20,%esp
  80105b:	85 c0                	test   %eax,%eax
  80105d:	78 2e                	js     80108d <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80105f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801062:	89 d0                	mov    %edx,%eax
  801064:	c1 e8 0c             	shr    $0xc,%eax
  801067:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80106e:	83 ec 0c             	sub    $0xc,%esp
  801071:	25 07 0e 00 00       	and    $0xe07,%eax
  801076:	50                   	push   %eax
  801077:	53                   	push   %ebx
  801078:	6a 00                	push   $0x0
  80107a:	52                   	push   %edx
  80107b:	6a 00                	push   $0x0
  80107d:	e8 3b fb ff ff       	call   800bbd <sys_page_map>
  801082:	89 c7                	mov    %eax,%edi
  801084:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801087:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801089:	85 ff                	test   %edi,%edi
  80108b:	79 1d                	jns    8010aa <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80108d:	83 ec 08             	sub    $0x8,%esp
  801090:	53                   	push   %ebx
  801091:	6a 00                	push   $0x0
  801093:	e8 67 fb ff ff       	call   800bff <sys_page_unmap>
	sys_page_unmap(0, nva);
  801098:	83 c4 08             	add    $0x8,%esp
  80109b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80109e:	6a 00                	push   $0x0
  8010a0:	e8 5a fb ff ff       	call   800bff <sys_page_unmap>
	return r;
  8010a5:	83 c4 10             	add    $0x10,%esp
  8010a8:	89 f8                	mov    %edi,%eax
}
  8010aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ad:	5b                   	pop    %ebx
  8010ae:	5e                   	pop    %esi
  8010af:	5f                   	pop    %edi
  8010b0:	5d                   	pop    %ebp
  8010b1:	c3                   	ret    

008010b2 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010b2:	55                   	push   %ebp
  8010b3:	89 e5                	mov    %esp,%ebp
  8010b5:	53                   	push   %ebx
  8010b6:	83 ec 14             	sub    $0x14,%esp
  8010b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010bf:	50                   	push   %eax
  8010c0:	53                   	push   %ebx
  8010c1:	e8 86 fd ff ff       	call   800e4c <fd_lookup>
  8010c6:	83 c4 08             	add    $0x8,%esp
  8010c9:	89 c2                	mov    %eax,%edx
  8010cb:	85 c0                	test   %eax,%eax
  8010cd:	78 6d                	js     80113c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010cf:	83 ec 08             	sub    $0x8,%esp
  8010d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010d5:	50                   	push   %eax
  8010d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010d9:	ff 30                	pushl  (%eax)
  8010db:	e8 c2 fd ff ff       	call   800ea2 <dev_lookup>
  8010e0:	83 c4 10             	add    $0x10,%esp
  8010e3:	85 c0                	test   %eax,%eax
  8010e5:	78 4c                	js     801133 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010e7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010ea:	8b 42 08             	mov    0x8(%edx),%eax
  8010ed:	83 e0 03             	and    $0x3,%eax
  8010f0:	83 f8 01             	cmp    $0x1,%eax
  8010f3:	75 21                	jne    801116 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010f5:	a1 04 40 80 00       	mov    0x804004,%eax
  8010fa:	8b 40 48             	mov    0x48(%eax),%eax
  8010fd:	83 ec 04             	sub    $0x4,%esp
  801100:	53                   	push   %ebx
  801101:	50                   	push   %eax
  801102:	68 6d 22 80 00       	push   $0x80226d
  801107:	e8 67 f0 ff ff       	call   800173 <cprintf>
		return -E_INVAL;
  80110c:	83 c4 10             	add    $0x10,%esp
  80110f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801114:	eb 26                	jmp    80113c <read+0x8a>
	}
	if (!dev->dev_read)
  801116:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801119:	8b 40 08             	mov    0x8(%eax),%eax
  80111c:	85 c0                	test   %eax,%eax
  80111e:	74 17                	je     801137 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801120:	83 ec 04             	sub    $0x4,%esp
  801123:	ff 75 10             	pushl  0x10(%ebp)
  801126:	ff 75 0c             	pushl  0xc(%ebp)
  801129:	52                   	push   %edx
  80112a:	ff d0                	call   *%eax
  80112c:	89 c2                	mov    %eax,%edx
  80112e:	83 c4 10             	add    $0x10,%esp
  801131:	eb 09                	jmp    80113c <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801133:	89 c2                	mov    %eax,%edx
  801135:	eb 05                	jmp    80113c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801137:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80113c:	89 d0                	mov    %edx,%eax
  80113e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801141:	c9                   	leave  
  801142:	c3                   	ret    

00801143 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801143:	55                   	push   %ebp
  801144:	89 e5                	mov    %esp,%ebp
  801146:	57                   	push   %edi
  801147:	56                   	push   %esi
  801148:	53                   	push   %ebx
  801149:	83 ec 0c             	sub    $0xc,%esp
  80114c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80114f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801152:	bb 00 00 00 00       	mov    $0x0,%ebx
  801157:	eb 21                	jmp    80117a <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801159:	83 ec 04             	sub    $0x4,%esp
  80115c:	89 f0                	mov    %esi,%eax
  80115e:	29 d8                	sub    %ebx,%eax
  801160:	50                   	push   %eax
  801161:	89 d8                	mov    %ebx,%eax
  801163:	03 45 0c             	add    0xc(%ebp),%eax
  801166:	50                   	push   %eax
  801167:	57                   	push   %edi
  801168:	e8 45 ff ff ff       	call   8010b2 <read>
		if (m < 0)
  80116d:	83 c4 10             	add    $0x10,%esp
  801170:	85 c0                	test   %eax,%eax
  801172:	78 10                	js     801184 <readn+0x41>
			return m;
		if (m == 0)
  801174:	85 c0                	test   %eax,%eax
  801176:	74 0a                	je     801182 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801178:	01 c3                	add    %eax,%ebx
  80117a:	39 f3                	cmp    %esi,%ebx
  80117c:	72 db                	jb     801159 <readn+0x16>
  80117e:	89 d8                	mov    %ebx,%eax
  801180:	eb 02                	jmp    801184 <readn+0x41>
  801182:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801184:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801187:	5b                   	pop    %ebx
  801188:	5e                   	pop    %esi
  801189:	5f                   	pop    %edi
  80118a:	5d                   	pop    %ebp
  80118b:	c3                   	ret    

0080118c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80118c:	55                   	push   %ebp
  80118d:	89 e5                	mov    %esp,%ebp
  80118f:	53                   	push   %ebx
  801190:	83 ec 14             	sub    $0x14,%esp
  801193:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801196:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801199:	50                   	push   %eax
  80119a:	53                   	push   %ebx
  80119b:	e8 ac fc ff ff       	call   800e4c <fd_lookup>
  8011a0:	83 c4 08             	add    $0x8,%esp
  8011a3:	89 c2                	mov    %eax,%edx
  8011a5:	85 c0                	test   %eax,%eax
  8011a7:	78 68                	js     801211 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011a9:	83 ec 08             	sub    $0x8,%esp
  8011ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011af:	50                   	push   %eax
  8011b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011b3:	ff 30                	pushl  (%eax)
  8011b5:	e8 e8 fc ff ff       	call   800ea2 <dev_lookup>
  8011ba:	83 c4 10             	add    $0x10,%esp
  8011bd:	85 c0                	test   %eax,%eax
  8011bf:	78 47                	js     801208 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011c8:	75 21                	jne    8011eb <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011ca:	a1 04 40 80 00       	mov    0x804004,%eax
  8011cf:	8b 40 48             	mov    0x48(%eax),%eax
  8011d2:	83 ec 04             	sub    $0x4,%esp
  8011d5:	53                   	push   %ebx
  8011d6:	50                   	push   %eax
  8011d7:	68 89 22 80 00       	push   $0x802289
  8011dc:	e8 92 ef ff ff       	call   800173 <cprintf>
		return -E_INVAL;
  8011e1:	83 c4 10             	add    $0x10,%esp
  8011e4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011e9:	eb 26                	jmp    801211 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011ee:	8b 52 0c             	mov    0xc(%edx),%edx
  8011f1:	85 d2                	test   %edx,%edx
  8011f3:	74 17                	je     80120c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011f5:	83 ec 04             	sub    $0x4,%esp
  8011f8:	ff 75 10             	pushl  0x10(%ebp)
  8011fb:	ff 75 0c             	pushl  0xc(%ebp)
  8011fe:	50                   	push   %eax
  8011ff:	ff d2                	call   *%edx
  801201:	89 c2                	mov    %eax,%edx
  801203:	83 c4 10             	add    $0x10,%esp
  801206:	eb 09                	jmp    801211 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801208:	89 c2                	mov    %eax,%edx
  80120a:	eb 05                	jmp    801211 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80120c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801211:	89 d0                	mov    %edx,%eax
  801213:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801216:	c9                   	leave  
  801217:	c3                   	ret    

00801218 <seek>:

int
seek(int fdnum, off_t offset)
{
  801218:	55                   	push   %ebp
  801219:	89 e5                	mov    %esp,%ebp
  80121b:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80121e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801221:	50                   	push   %eax
  801222:	ff 75 08             	pushl  0x8(%ebp)
  801225:	e8 22 fc ff ff       	call   800e4c <fd_lookup>
  80122a:	83 c4 08             	add    $0x8,%esp
  80122d:	85 c0                	test   %eax,%eax
  80122f:	78 0e                	js     80123f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801231:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801234:	8b 55 0c             	mov    0xc(%ebp),%edx
  801237:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80123a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80123f:	c9                   	leave  
  801240:	c3                   	ret    

00801241 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801241:	55                   	push   %ebp
  801242:	89 e5                	mov    %esp,%ebp
  801244:	53                   	push   %ebx
  801245:	83 ec 14             	sub    $0x14,%esp
  801248:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80124b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80124e:	50                   	push   %eax
  80124f:	53                   	push   %ebx
  801250:	e8 f7 fb ff ff       	call   800e4c <fd_lookup>
  801255:	83 c4 08             	add    $0x8,%esp
  801258:	89 c2                	mov    %eax,%edx
  80125a:	85 c0                	test   %eax,%eax
  80125c:	78 65                	js     8012c3 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80125e:	83 ec 08             	sub    $0x8,%esp
  801261:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801264:	50                   	push   %eax
  801265:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801268:	ff 30                	pushl  (%eax)
  80126a:	e8 33 fc ff ff       	call   800ea2 <dev_lookup>
  80126f:	83 c4 10             	add    $0x10,%esp
  801272:	85 c0                	test   %eax,%eax
  801274:	78 44                	js     8012ba <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801276:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801279:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80127d:	75 21                	jne    8012a0 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80127f:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801284:	8b 40 48             	mov    0x48(%eax),%eax
  801287:	83 ec 04             	sub    $0x4,%esp
  80128a:	53                   	push   %ebx
  80128b:	50                   	push   %eax
  80128c:	68 4c 22 80 00       	push   $0x80224c
  801291:	e8 dd ee ff ff       	call   800173 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801296:	83 c4 10             	add    $0x10,%esp
  801299:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80129e:	eb 23                	jmp    8012c3 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012a3:	8b 52 18             	mov    0x18(%edx),%edx
  8012a6:	85 d2                	test   %edx,%edx
  8012a8:	74 14                	je     8012be <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012aa:	83 ec 08             	sub    $0x8,%esp
  8012ad:	ff 75 0c             	pushl  0xc(%ebp)
  8012b0:	50                   	push   %eax
  8012b1:	ff d2                	call   *%edx
  8012b3:	89 c2                	mov    %eax,%edx
  8012b5:	83 c4 10             	add    $0x10,%esp
  8012b8:	eb 09                	jmp    8012c3 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ba:	89 c2                	mov    %eax,%edx
  8012bc:	eb 05                	jmp    8012c3 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012be:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012c3:	89 d0                	mov    %edx,%eax
  8012c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012c8:	c9                   	leave  
  8012c9:	c3                   	ret    

008012ca <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012ca:	55                   	push   %ebp
  8012cb:	89 e5                	mov    %esp,%ebp
  8012cd:	53                   	push   %ebx
  8012ce:	83 ec 14             	sub    $0x14,%esp
  8012d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012d7:	50                   	push   %eax
  8012d8:	ff 75 08             	pushl  0x8(%ebp)
  8012db:	e8 6c fb ff ff       	call   800e4c <fd_lookup>
  8012e0:	83 c4 08             	add    $0x8,%esp
  8012e3:	89 c2                	mov    %eax,%edx
  8012e5:	85 c0                	test   %eax,%eax
  8012e7:	78 58                	js     801341 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e9:	83 ec 08             	sub    $0x8,%esp
  8012ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ef:	50                   	push   %eax
  8012f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f3:	ff 30                	pushl  (%eax)
  8012f5:	e8 a8 fb ff ff       	call   800ea2 <dev_lookup>
  8012fa:	83 c4 10             	add    $0x10,%esp
  8012fd:	85 c0                	test   %eax,%eax
  8012ff:	78 37                	js     801338 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801301:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801304:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801308:	74 32                	je     80133c <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80130a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80130d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801314:	00 00 00 
	stat->st_isdir = 0;
  801317:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80131e:	00 00 00 
	stat->st_dev = dev;
  801321:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801327:	83 ec 08             	sub    $0x8,%esp
  80132a:	53                   	push   %ebx
  80132b:	ff 75 f0             	pushl  -0x10(%ebp)
  80132e:	ff 50 14             	call   *0x14(%eax)
  801331:	89 c2                	mov    %eax,%edx
  801333:	83 c4 10             	add    $0x10,%esp
  801336:	eb 09                	jmp    801341 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801338:	89 c2                	mov    %eax,%edx
  80133a:	eb 05                	jmp    801341 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80133c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801341:	89 d0                	mov    %edx,%eax
  801343:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801346:	c9                   	leave  
  801347:	c3                   	ret    

00801348 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801348:	55                   	push   %ebp
  801349:	89 e5                	mov    %esp,%ebp
  80134b:	56                   	push   %esi
  80134c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80134d:	83 ec 08             	sub    $0x8,%esp
  801350:	6a 00                	push   $0x0
  801352:	ff 75 08             	pushl  0x8(%ebp)
  801355:	e8 e3 01 00 00       	call   80153d <open>
  80135a:	89 c3                	mov    %eax,%ebx
  80135c:	83 c4 10             	add    $0x10,%esp
  80135f:	85 c0                	test   %eax,%eax
  801361:	78 1b                	js     80137e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801363:	83 ec 08             	sub    $0x8,%esp
  801366:	ff 75 0c             	pushl  0xc(%ebp)
  801369:	50                   	push   %eax
  80136a:	e8 5b ff ff ff       	call   8012ca <fstat>
  80136f:	89 c6                	mov    %eax,%esi
	close(fd);
  801371:	89 1c 24             	mov    %ebx,(%esp)
  801374:	e8 fd fb ff ff       	call   800f76 <close>
	return r;
  801379:	83 c4 10             	add    $0x10,%esp
  80137c:	89 f0                	mov    %esi,%eax
}
  80137e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801381:	5b                   	pop    %ebx
  801382:	5e                   	pop    %esi
  801383:	5d                   	pop    %ebp
  801384:	c3                   	ret    

00801385 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801385:	55                   	push   %ebp
  801386:	89 e5                	mov    %esp,%ebp
  801388:	56                   	push   %esi
  801389:	53                   	push   %ebx
  80138a:	89 c6                	mov    %eax,%esi
  80138c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80138e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801395:	75 12                	jne    8013a9 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801397:	83 ec 0c             	sub    $0xc,%esp
  80139a:	6a 01                	push   $0x1
  80139c:	e8 2b 08 00 00       	call   801bcc <ipc_find_env>
  8013a1:	a3 00 40 80 00       	mov    %eax,0x804000
  8013a6:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013a9:	6a 07                	push   $0x7
  8013ab:	68 00 50 80 00       	push   $0x805000
  8013b0:	56                   	push   %esi
  8013b1:	ff 35 00 40 80 00    	pushl  0x804000
  8013b7:	e8 bc 07 00 00       	call   801b78 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013bc:	83 c4 0c             	add    $0xc,%esp
  8013bf:	6a 00                	push   $0x0
  8013c1:	53                   	push   %ebx
  8013c2:	6a 00                	push   $0x0
  8013c4:	e8 3d 07 00 00       	call   801b06 <ipc_recv>
}
  8013c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013cc:	5b                   	pop    %ebx
  8013cd:	5e                   	pop    %esi
  8013ce:	5d                   	pop    %ebp
  8013cf:	c3                   	ret    

008013d0 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013d0:	55                   	push   %ebp
  8013d1:	89 e5                	mov    %esp,%ebp
  8013d3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8013d9:	8b 40 0c             	mov    0xc(%eax),%eax
  8013dc:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013e4:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ee:	b8 02 00 00 00       	mov    $0x2,%eax
  8013f3:	e8 8d ff ff ff       	call   801385 <fsipc>
}
  8013f8:	c9                   	leave  
  8013f9:	c3                   	ret    

008013fa <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8013fa:	55                   	push   %ebp
  8013fb:	89 e5                	mov    %esp,%ebp
  8013fd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801400:	8b 45 08             	mov    0x8(%ebp),%eax
  801403:	8b 40 0c             	mov    0xc(%eax),%eax
  801406:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80140b:	ba 00 00 00 00       	mov    $0x0,%edx
  801410:	b8 06 00 00 00       	mov    $0x6,%eax
  801415:	e8 6b ff ff ff       	call   801385 <fsipc>
}
  80141a:	c9                   	leave  
  80141b:	c3                   	ret    

0080141c <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80141c:	55                   	push   %ebp
  80141d:	89 e5                	mov    %esp,%ebp
  80141f:	53                   	push   %ebx
  801420:	83 ec 04             	sub    $0x4,%esp
  801423:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801426:	8b 45 08             	mov    0x8(%ebp),%eax
  801429:	8b 40 0c             	mov    0xc(%eax),%eax
  80142c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801431:	ba 00 00 00 00       	mov    $0x0,%edx
  801436:	b8 05 00 00 00       	mov    $0x5,%eax
  80143b:	e8 45 ff ff ff       	call   801385 <fsipc>
  801440:	85 c0                	test   %eax,%eax
  801442:	78 2c                	js     801470 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801444:	83 ec 08             	sub    $0x8,%esp
  801447:	68 00 50 80 00       	push   $0x805000
  80144c:	53                   	push   %ebx
  80144d:	e8 25 f3 ff ff       	call   800777 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801452:	a1 80 50 80 00       	mov    0x805080,%eax
  801457:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80145d:	a1 84 50 80 00       	mov    0x805084,%eax
  801462:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801468:	83 c4 10             	add    $0x10,%esp
  80146b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801470:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801473:	c9                   	leave  
  801474:	c3                   	ret    

00801475 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801475:	55                   	push   %ebp
  801476:	89 e5                	mov    %esp,%ebp
  801478:	83 ec 0c             	sub    $0xc,%esp
  80147b:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	
	int r;

	n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  80147e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801483:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801488:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80148b:	8b 55 08             	mov    0x8(%ebp),%edx
  80148e:	8b 52 0c             	mov    0xc(%edx),%edx
  801491:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801497:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80149c:	50                   	push   %eax
  80149d:	ff 75 0c             	pushl  0xc(%ebp)
  8014a0:	68 08 50 80 00       	push   $0x805008
  8014a5:	e8 5f f4 ff ff       	call   800909 <memmove>
	
	return fsipc(FSREQ_WRITE, NULL);	
  8014aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8014af:	b8 04 00 00 00       	mov    $0x4,%eax
  8014b4:	e8 cc fe ff ff       	call   801385 <fsipc>
}
  8014b9:	c9                   	leave  
  8014ba:	c3                   	ret    

008014bb <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014bb:	55                   	push   %ebp
  8014bc:	89 e5                	mov    %esp,%ebp
  8014be:	56                   	push   %esi
  8014bf:	53                   	push   %ebx
  8014c0:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c6:	8b 40 0c             	mov    0xc(%eax),%eax
  8014c9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014ce:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d9:	b8 03 00 00 00       	mov    $0x3,%eax
  8014de:	e8 a2 fe ff ff       	call   801385 <fsipc>
  8014e3:	89 c3                	mov    %eax,%ebx
  8014e5:	85 c0                	test   %eax,%eax
  8014e7:	78 4b                	js     801534 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8014e9:	39 c6                	cmp    %eax,%esi
  8014eb:	73 16                	jae    801503 <devfile_read+0x48>
  8014ed:	68 b8 22 80 00       	push   $0x8022b8
  8014f2:	68 bf 22 80 00       	push   $0x8022bf
  8014f7:	6a 7c                	push   $0x7c
  8014f9:	68 d4 22 80 00       	push   $0x8022d4
  8014fe:	e8 bd 05 00 00       	call   801ac0 <_panic>
	assert(r <= PGSIZE);
  801503:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801508:	7e 16                	jle    801520 <devfile_read+0x65>
  80150a:	68 df 22 80 00       	push   $0x8022df
  80150f:	68 bf 22 80 00       	push   $0x8022bf
  801514:	6a 7d                	push   $0x7d
  801516:	68 d4 22 80 00       	push   $0x8022d4
  80151b:	e8 a0 05 00 00       	call   801ac0 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801520:	83 ec 04             	sub    $0x4,%esp
  801523:	50                   	push   %eax
  801524:	68 00 50 80 00       	push   $0x805000
  801529:	ff 75 0c             	pushl  0xc(%ebp)
  80152c:	e8 d8 f3 ff ff       	call   800909 <memmove>
	return r;
  801531:	83 c4 10             	add    $0x10,%esp
}
  801534:	89 d8                	mov    %ebx,%eax
  801536:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801539:	5b                   	pop    %ebx
  80153a:	5e                   	pop    %esi
  80153b:	5d                   	pop    %ebp
  80153c:	c3                   	ret    

0080153d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80153d:	55                   	push   %ebp
  80153e:	89 e5                	mov    %esp,%ebp
  801540:	53                   	push   %ebx
  801541:	83 ec 20             	sub    $0x20,%esp
  801544:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801547:	53                   	push   %ebx
  801548:	e8 f1 f1 ff ff       	call   80073e <strlen>
  80154d:	83 c4 10             	add    $0x10,%esp
  801550:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801555:	7f 67                	jg     8015be <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801557:	83 ec 0c             	sub    $0xc,%esp
  80155a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80155d:	50                   	push   %eax
  80155e:	e8 9a f8 ff ff       	call   800dfd <fd_alloc>
  801563:	83 c4 10             	add    $0x10,%esp
		return r;
  801566:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801568:	85 c0                	test   %eax,%eax
  80156a:	78 57                	js     8015c3 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80156c:	83 ec 08             	sub    $0x8,%esp
  80156f:	53                   	push   %ebx
  801570:	68 00 50 80 00       	push   $0x805000
  801575:	e8 fd f1 ff ff       	call   800777 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80157a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80157d:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801582:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801585:	b8 01 00 00 00       	mov    $0x1,%eax
  80158a:	e8 f6 fd ff ff       	call   801385 <fsipc>
  80158f:	89 c3                	mov    %eax,%ebx
  801591:	83 c4 10             	add    $0x10,%esp
  801594:	85 c0                	test   %eax,%eax
  801596:	79 14                	jns    8015ac <open+0x6f>
		fd_close(fd, 0);
  801598:	83 ec 08             	sub    $0x8,%esp
  80159b:	6a 00                	push   $0x0
  80159d:	ff 75 f4             	pushl  -0xc(%ebp)
  8015a0:	e8 50 f9 ff ff       	call   800ef5 <fd_close>
		return r;
  8015a5:	83 c4 10             	add    $0x10,%esp
  8015a8:	89 da                	mov    %ebx,%edx
  8015aa:	eb 17                	jmp    8015c3 <open+0x86>
	}

	return fd2num(fd);
  8015ac:	83 ec 0c             	sub    $0xc,%esp
  8015af:	ff 75 f4             	pushl  -0xc(%ebp)
  8015b2:	e8 1f f8 ff ff       	call   800dd6 <fd2num>
  8015b7:	89 c2                	mov    %eax,%edx
  8015b9:	83 c4 10             	add    $0x10,%esp
  8015bc:	eb 05                	jmp    8015c3 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015be:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015c3:	89 d0                	mov    %edx,%eax
  8015c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c8:	c9                   	leave  
  8015c9:	c3                   	ret    

008015ca <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015ca:	55                   	push   %ebp
  8015cb:	89 e5                	mov    %esp,%ebp
  8015cd:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8015d5:	b8 08 00 00 00       	mov    $0x8,%eax
  8015da:	e8 a6 fd ff ff       	call   801385 <fsipc>
}
  8015df:	c9                   	leave  
  8015e0:	c3                   	ret    

008015e1 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8015e1:	55                   	push   %ebp
  8015e2:	89 e5                	mov    %esp,%ebp
  8015e4:	56                   	push   %esi
  8015e5:	53                   	push   %ebx
  8015e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8015e9:	83 ec 0c             	sub    $0xc,%esp
  8015ec:	ff 75 08             	pushl  0x8(%ebp)
  8015ef:	e8 f2 f7 ff ff       	call   800de6 <fd2data>
  8015f4:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8015f6:	83 c4 08             	add    $0x8,%esp
  8015f9:	68 eb 22 80 00       	push   $0x8022eb
  8015fe:	53                   	push   %ebx
  8015ff:	e8 73 f1 ff ff       	call   800777 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801604:	8b 46 04             	mov    0x4(%esi),%eax
  801607:	2b 06                	sub    (%esi),%eax
  801609:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80160f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801616:	00 00 00 
	stat->st_dev = &devpipe;
  801619:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801620:	30 80 00 
	return 0;
}
  801623:	b8 00 00 00 00       	mov    $0x0,%eax
  801628:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80162b:	5b                   	pop    %ebx
  80162c:	5e                   	pop    %esi
  80162d:	5d                   	pop    %ebp
  80162e:	c3                   	ret    

0080162f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80162f:	55                   	push   %ebp
  801630:	89 e5                	mov    %esp,%ebp
  801632:	53                   	push   %ebx
  801633:	83 ec 0c             	sub    $0xc,%esp
  801636:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801639:	53                   	push   %ebx
  80163a:	6a 00                	push   $0x0
  80163c:	e8 be f5 ff ff       	call   800bff <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801641:	89 1c 24             	mov    %ebx,(%esp)
  801644:	e8 9d f7 ff ff       	call   800de6 <fd2data>
  801649:	83 c4 08             	add    $0x8,%esp
  80164c:	50                   	push   %eax
  80164d:	6a 00                	push   $0x0
  80164f:	e8 ab f5 ff ff       	call   800bff <sys_page_unmap>
}
  801654:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801657:	c9                   	leave  
  801658:	c3                   	ret    

00801659 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801659:	55                   	push   %ebp
  80165a:	89 e5                	mov    %esp,%ebp
  80165c:	57                   	push   %edi
  80165d:	56                   	push   %esi
  80165e:	53                   	push   %ebx
  80165f:	83 ec 1c             	sub    $0x1c,%esp
  801662:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801665:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801667:	a1 04 40 80 00       	mov    0x804004,%eax
  80166c:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80166f:	83 ec 0c             	sub    $0xc,%esp
  801672:	ff 75 e0             	pushl  -0x20(%ebp)
  801675:	e8 8b 05 00 00       	call   801c05 <pageref>
  80167a:	89 c3                	mov    %eax,%ebx
  80167c:	89 3c 24             	mov    %edi,(%esp)
  80167f:	e8 81 05 00 00       	call   801c05 <pageref>
  801684:	83 c4 10             	add    $0x10,%esp
  801687:	39 c3                	cmp    %eax,%ebx
  801689:	0f 94 c1             	sete   %cl
  80168c:	0f b6 c9             	movzbl %cl,%ecx
  80168f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801692:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801698:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80169b:	39 ce                	cmp    %ecx,%esi
  80169d:	74 1b                	je     8016ba <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80169f:	39 c3                	cmp    %eax,%ebx
  8016a1:	75 c4                	jne    801667 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8016a3:	8b 42 58             	mov    0x58(%edx),%eax
  8016a6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016a9:	50                   	push   %eax
  8016aa:	56                   	push   %esi
  8016ab:	68 f2 22 80 00       	push   $0x8022f2
  8016b0:	e8 be ea ff ff       	call   800173 <cprintf>
  8016b5:	83 c4 10             	add    $0x10,%esp
  8016b8:	eb ad                	jmp    801667 <_pipeisclosed+0xe>
	}
}
  8016ba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016c0:	5b                   	pop    %ebx
  8016c1:	5e                   	pop    %esi
  8016c2:	5f                   	pop    %edi
  8016c3:	5d                   	pop    %ebp
  8016c4:	c3                   	ret    

008016c5 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8016c5:	55                   	push   %ebp
  8016c6:	89 e5                	mov    %esp,%ebp
  8016c8:	57                   	push   %edi
  8016c9:	56                   	push   %esi
  8016ca:	53                   	push   %ebx
  8016cb:	83 ec 28             	sub    $0x28,%esp
  8016ce:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8016d1:	56                   	push   %esi
  8016d2:	e8 0f f7 ff ff       	call   800de6 <fd2data>
  8016d7:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016d9:	83 c4 10             	add    $0x10,%esp
  8016dc:	bf 00 00 00 00       	mov    $0x0,%edi
  8016e1:	eb 4b                	jmp    80172e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8016e3:	89 da                	mov    %ebx,%edx
  8016e5:	89 f0                	mov    %esi,%eax
  8016e7:	e8 6d ff ff ff       	call   801659 <_pipeisclosed>
  8016ec:	85 c0                	test   %eax,%eax
  8016ee:	75 48                	jne    801738 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8016f0:	e8 66 f4 ff ff       	call   800b5b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8016f5:	8b 43 04             	mov    0x4(%ebx),%eax
  8016f8:	8b 0b                	mov    (%ebx),%ecx
  8016fa:	8d 51 20             	lea    0x20(%ecx),%edx
  8016fd:	39 d0                	cmp    %edx,%eax
  8016ff:	73 e2                	jae    8016e3 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801701:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801704:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801708:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80170b:	89 c2                	mov    %eax,%edx
  80170d:	c1 fa 1f             	sar    $0x1f,%edx
  801710:	89 d1                	mov    %edx,%ecx
  801712:	c1 e9 1b             	shr    $0x1b,%ecx
  801715:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801718:	83 e2 1f             	and    $0x1f,%edx
  80171b:	29 ca                	sub    %ecx,%edx
  80171d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801721:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801725:	83 c0 01             	add    $0x1,%eax
  801728:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80172b:	83 c7 01             	add    $0x1,%edi
  80172e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801731:	75 c2                	jne    8016f5 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801733:	8b 45 10             	mov    0x10(%ebp),%eax
  801736:	eb 05                	jmp    80173d <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801738:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80173d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801740:	5b                   	pop    %ebx
  801741:	5e                   	pop    %esi
  801742:	5f                   	pop    %edi
  801743:	5d                   	pop    %ebp
  801744:	c3                   	ret    

00801745 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801745:	55                   	push   %ebp
  801746:	89 e5                	mov    %esp,%ebp
  801748:	57                   	push   %edi
  801749:	56                   	push   %esi
  80174a:	53                   	push   %ebx
  80174b:	83 ec 18             	sub    $0x18,%esp
  80174e:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801751:	57                   	push   %edi
  801752:	e8 8f f6 ff ff       	call   800de6 <fd2data>
  801757:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801759:	83 c4 10             	add    $0x10,%esp
  80175c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801761:	eb 3d                	jmp    8017a0 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801763:	85 db                	test   %ebx,%ebx
  801765:	74 04                	je     80176b <devpipe_read+0x26>
				return i;
  801767:	89 d8                	mov    %ebx,%eax
  801769:	eb 44                	jmp    8017af <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80176b:	89 f2                	mov    %esi,%edx
  80176d:	89 f8                	mov    %edi,%eax
  80176f:	e8 e5 fe ff ff       	call   801659 <_pipeisclosed>
  801774:	85 c0                	test   %eax,%eax
  801776:	75 32                	jne    8017aa <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801778:	e8 de f3 ff ff       	call   800b5b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80177d:	8b 06                	mov    (%esi),%eax
  80177f:	3b 46 04             	cmp    0x4(%esi),%eax
  801782:	74 df                	je     801763 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801784:	99                   	cltd   
  801785:	c1 ea 1b             	shr    $0x1b,%edx
  801788:	01 d0                	add    %edx,%eax
  80178a:	83 e0 1f             	and    $0x1f,%eax
  80178d:	29 d0                	sub    %edx,%eax
  80178f:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801794:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801797:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80179a:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80179d:	83 c3 01             	add    $0x1,%ebx
  8017a0:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8017a3:	75 d8                	jne    80177d <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8017a5:	8b 45 10             	mov    0x10(%ebp),%eax
  8017a8:	eb 05                	jmp    8017af <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017aa:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8017af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017b2:	5b                   	pop    %ebx
  8017b3:	5e                   	pop    %esi
  8017b4:	5f                   	pop    %edi
  8017b5:	5d                   	pop    %ebp
  8017b6:	c3                   	ret    

008017b7 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8017b7:	55                   	push   %ebp
  8017b8:	89 e5                	mov    %esp,%ebp
  8017ba:	56                   	push   %esi
  8017bb:	53                   	push   %ebx
  8017bc:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8017bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017c2:	50                   	push   %eax
  8017c3:	e8 35 f6 ff ff       	call   800dfd <fd_alloc>
  8017c8:	83 c4 10             	add    $0x10,%esp
  8017cb:	89 c2                	mov    %eax,%edx
  8017cd:	85 c0                	test   %eax,%eax
  8017cf:	0f 88 2c 01 00 00    	js     801901 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017d5:	83 ec 04             	sub    $0x4,%esp
  8017d8:	68 07 04 00 00       	push   $0x407
  8017dd:	ff 75 f4             	pushl  -0xc(%ebp)
  8017e0:	6a 00                	push   $0x0
  8017e2:	e8 93 f3 ff ff       	call   800b7a <sys_page_alloc>
  8017e7:	83 c4 10             	add    $0x10,%esp
  8017ea:	89 c2                	mov    %eax,%edx
  8017ec:	85 c0                	test   %eax,%eax
  8017ee:	0f 88 0d 01 00 00    	js     801901 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8017f4:	83 ec 0c             	sub    $0xc,%esp
  8017f7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017fa:	50                   	push   %eax
  8017fb:	e8 fd f5 ff ff       	call   800dfd <fd_alloc>
  801800:	89 c3                	mov    %eax,%ebx
  801802:	83 c4 10             	add    $0x10,%esp
  801805:	85 c0                	test   %eax,%eax
  801807:	0f 88 e2 00 00 00    	js     8018ef <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80180d:	83 ec 04             	sub    $0x4,%esp
  801810:	68 07 04 00 00       	push   $0x407
  801815:	ff 75 f0             	pushl  -0x10(%ebp)
  801818:	6a 00                	push   $0x0
  80181a:	e8 5b f3 ff ff       	call   800b7a <sys_page_alloc>
  80181f:	89 c3                	mov    %eax,%ebx
  801821:	83 c4 10             	add    $0x10,%esp
  801824:	85 c0                	test   %eax,%eax
  801826:	0f 88 c3 00 00 00    	js     8018ef <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80182c:	83 ec 0c             	sub    $0xc,%esp
  80182f:	ff 75 f4             	pushl  -0xc(%ebp)
  801832:	e8 af f5 ff ff       	call   800de6 <fd2data>
  801837:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801839:	83 c4 0c             	add    $0xc,%esp
  80183c:	68 07 04 00 00       	push   $0x407
  801841:	50                   	push   %eax
  801842:	6a 00                	push   $0x0
  801844:	e8 31 f3 ff ff       	call   800b7a <sys_page_alloc>
  801849:	89 c3                	mov    %eax,%ebx
  80184b:	83 c4 10             	add    $0x10,%esp
  80184e:	85 c0                	test   %eax,%eax
  801850:	0f 88 89 00 00 00    	js     8018df <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801856:	83 ec 0c             	sub    $0xc,%esp
  801859:	ff 75 f0             	pushl  -0x10(%ebp)
  80185c:	e8 85 f5 ff ff       	call   800de6 <fd2data>
  801861:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801868:	50                   	push   %eax
  801869:	6a 00                	push   $0x0
  80186b:	56                   	push   %esi
  80186c:	6a 00                	push   $0x0
  80186e:	e8 4a f3 ff ff       	call   800bbd <sys_page_map>
  801873:	89 c3                	mov    %eax,%ebx
  801875:	83 c4 20             	add    $0x20,%esp
  801878:	85 c0                	test   %eax,%eax
  80187a:	78 55                	js     8018d1 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80187c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801882:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801885:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801887:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80188a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801891:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801897:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80189a:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80189c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80189f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8018a6:	83 ec 0c             	sub    $0xc,%esp
  8018a9:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ac:	e8 25 f5 ff ff       	call   800dd6 <fd2num>
  8018b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018b4:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8018b6:	83 c4 04             	add    $0x4,%esp
  8018b9:	ff 75 f0             	pushl  -0x10(%ebp)
  8018bc:	e8 15 f5 ff ff       	call   800dd6 <fd2num>
  8018c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018c4:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8018c7:	83 c4 10             	add    $0x10,%esp
  8018ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8018cf:	eb 30                	jmp    801901 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8018d1:	83 ec 08             	sub    $0x8,%esp
  8018d4:	56                   	push   %esi
  8018d5:	6a 00                	push   $0x0
  8018d7:	e8 23 f3 ff ff       	call   800bff <sys_page_unmap>
  8018dc:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8018df:	83 ec 08             	sub    $0x8,%esp
  8018e2:	ff 75 f0             	pushl  -0x10(%ebp)
  8018e5:	6a 00                	push   $0x0
  8018e7:	e8 13 f3 ff ff       	call   800bff <sys_page_unmap>
  8018ec:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8018ef:	83 ec 08             	sub    $0x8,%esp
  8018f2:	ff 75 f4             	pushl  -0xc(%ebp)
  8018f5:	6a 00                	push   $0x0
  8018f7:	e8 03 f3 ff ff       	call   800bff <sys_page_unmap>
  8018fc:	83 c4 10             	add    $0x10,%esp
  8018ff:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801901:	89 d0                	mov    %edx,%eax
  801903:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801906:	5b                   	pop    %ebx
  801907:	5e                   	pop    %esi
  801908:	5d                   	pop    %ebp
  801909:	c3                   	ret    

0080190a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80190a:	55                   	push   %ebp
  80190b:	89 e5                	mov    %esp,%ebp
  80190d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801910:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801913:	50                   	push   %eax
  801914:	ff 75 08             	pushl  0x8(%ebp)
  801917:	e8 30 f5 ff ff       	call   800e4c <fd_lookup>
  80191c:	83 c4 10             	add    $0x10,%esp
  80191f:	85 c0                	test   %eax,%eax
  801921:	78 18                	js     80193b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801923:	83 ec 0c             	sub    $0xc,%esp
  801926:	ff 75 f4             	pushl  -0xc(%ebp)
  801929:	e8 b8 f4 ff ff       	call   800de6 <fd2data>
	return _pipeisclosed(fd, p);
  80192e:	89 c2                	mov    %eax,%edx
  801930:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801933:	e8 21 fd ff ff       	call   801659 <_pipeisclosed>
  801938:	83 c4 10             	add    $0x10,%esp
}
  80193b:	c9                   	leave  
  80193c:	c3                   	ret    

0080193d <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80193d:	55                   	push   %ebp
  80193e:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801940:	b8 00 00 00 00       	mov    $0x0,%eax
  801945:	5d                   	pop    %ebp
  801946:	c3                   	ret    

00801947 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801947:	55                   	push   %ebp
  801948:	89 e5                	mov    %esp,%ebp
  80194a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80194d:	68 0a 23 80 00       	push   $0x80230a
  801952:	ff 75 0c             	pushl  0xc(%ebp)
  801955:	e8 1d ee ff ff       	call   800777 <strcpy>
	return 0;
}
  80195a:	b8 00 00 00 00       	mov    $0x0,%eax
  80195f:	c9                   	leave  
  801960:	c3                   	ret    

00801961 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801961:	55                   	push   %ebp
  801962:	89 e5                	mov    %esp,%ebp
  801964:	57                   	push   %edi
  801965:	56                   	push   %esi
  801966:	53                   	push   %ebx
  801967:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80196d:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801972:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801978:	eb 2d                	jmp    8019a7 <devcons_write+0x46>
		m = n - tot;
  80197a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80197d:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80197f:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801982:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801987:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80198a:	83 ec 04             	sub    $0x4,%esp
  80198d:	53                   	push   %ebx
  80198e:	03 45 0c             	add    0xc(%ebp),%eax
  801991:	50                   	push   %eax
  801992:	57                   	push   %edi
  801993:	e8 71 ef ff ff       	call   800909 <memmove>
		sys_cputs(buf, m);
  801998:	83 c4 08             	add    $0x8,%esp
  80199b:	53                   	push   %ebx
  80199c:	57                   	push   %edi
  80199d:	e8 1c f1 ff ff       	call   800abe <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019a2:	01 de                	add    %ebx,%esi
  8019a4:	83 c4 10             	add    $0x10,%esp
  8019a7:	89 f0                	mov    %esi,%eax
  8019a9:	3b 75 10             	cmp    0x10(%ebp),%esi
  8019ac:	72 cc                	jb     80197a <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8019ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019b1:	5b                   	pop    %ebx
  8019b2:	5e                   	pop    %esi
  8019b3:	5f                   	pop    %edi
  8019b4:	5d                   	pop    %ebp
  8019b5:	c3                   	ret    

008019b6 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019b6:	55                   	push   %ebp
  8019b7:	89 e5                	mov    %esp,%ebp
  8019b9:	83 ec 08             	sub    $0x8,%esp
  8019bc:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8019c1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019c5:	74 2a                	je     8019f1 <devcons_read+0x3b>
  8019c7:	eb 05                	jmp    8019ce <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8019c9:	e8 8d f1 ff ff       	call   800b5b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8019ce:	e8 09 f1 ff ff       	call   800adc <sys_cgetc>
  8019d3:	85 c0                	test   %eax,%eax
  8019d5:	74 f2                	je     8019c9 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8019d7:	85 c0                	test   %eax,%eax
  8019d9:	78 16                	js     8019f1 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8019db:	83 f8 04             	cmp    $0x4,%eax
  8019de:	74 0c                	je     8019ec <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8019e0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019e3:	88 02                	mov    %al,(%edx)
	return 1;
  8019e5:	b8 01 00 00 00       	mov    $0x1,%eax
  8019ea:	eb 05                	jmp    8019f1 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8019ec:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8019f1:	c9                   	leave  
  8019f2:	c3                   	ret    

008019f3 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8019f3:	55                   	push   %ebp
  8019f4:	89 e5                	mov    %esp,%ebp
  8019f6:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8019f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019fc:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8019ff:	6a 01                	push   $0x1
  801a01:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a04:	50                   	push   %eax
  801a05:	e8 b4 f0 ff ff       	call   800abe <sys_cputs>
}
  801a0a:	83 c4 10             	add    $0x10,%esp
  801a0d:	c9                   	leave  
  801a0e:	c3                   	ret    

00801a0f <getchar>:

int
getchar(void)
{
  801a0f:	55                   	push   %ebp
  801a10:	89 e5                	mov    %esp,%ebp
  801a12:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a15:	6a 01                	push   $0x1
  801a17:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a1a:	50                   	push   %eax
  801a1b:	6a 00                	push   $0x0
  801a1d:	e8 90 f6 ff ff       	call   8010b2 <read>
	if (r < 0)
  801a22:	83 c4 10             	add    $0x10,%esp
  801a25:	85 c0                	test   %eax,%eax
  801a27:	78 0f                	js     801a38 <getchar+0x29>
		return r;
	if (r < 1)
  801a29:	85 c0                	test   %eax,%eax
  801a2b:	7e 06                	jle    801a33 <getchar+0x24>
		return -E_EOF;
	return c;
  801a2d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a31:	eb 05                	jmp    801a38 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a33:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a38:	c9                   	leave  
  801a39:	c3                   	ret    

00801a3a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a3a:	55                   	push   %ebp
  801a3b:	89 e5                	mov    %esp,%ebp
  801a3d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a40:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a43:	50                   	push   %eax
  801a44:	ff 75 08             	pushl  0x8(%ebp)
  801a47:	e8 00 f4 ff ff       	call   800e4c <fd_lookup>
  801a4c:	83 c4 10             	add    $0x10,%esp
  801a4f:	85 c0                	test   %eax,%eax
  801a51:	78 11                	js     801a64 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801a53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a56:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a5c:	39 10                	cmp    %edx,(%eax)
  801a5e:	0f 94 c0             	sete   %al
  801a61:	0f b6 c0             	movzbl %al,%eax
}
  801a64:	c9                   	leave  
  801a65:	c3                   	ret    

00801a66 <opencons>:

int
opencons(void)
{
  801a66:	55                   	push   %ebp
  801a67:	89 e5                	mov    %esp,%ebp
  801a69:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a6c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a6f:	50                   	push   %eax
  801a70:	e8 88 f3 ff ff       	call   800dfd <fd_alloc>
  801a75:	83 c4 10             	add    $0x10,%esp
		return r;
  801a78:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a7a:	85 c0                	test   %eax,%eax
  801a7c:	78 3e                	js     801abc <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a7e:	83 ec 04             	sub    $0x4,%esp
  801a81:	68 07 04 00 00       	push   $0x407
  801a86:	ff 75 f4             	pushl  -0xc(%ebp)
  801a89:	6a 00                	push   $0x0
  801a8b:	e8 ea f0 ff ff       	call   800b7a <sys_page_alloc>
  801a90:	83 c4 10             	add    $0x10,%esp
		return r;
  801a93:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a95:	85 c0                	test   %eax,%eax
  801a97:	78 23                	js     801abc <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801a99:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aa2:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801aa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aa7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801aae:	83 ec 0c             	sub    $0xc,%esp
  801ab1:	50                   	push   %eax
  801ab2:	e8 1f f3 ff ff       	call   800dd6 <fd2num>
  801ab7:	89 c2                	mov    %eax,%edx
  801ab9:	83 c4 10             	add    $0x10,%esp
}
  801abc:	89 d0                	mov    %edx,%eax
  801abe:	c9                   	leave  
  801abf:	c3                   	ret    

00801ac0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ac0:	55                   	push   %ebp
  801ac1:	89 e5                	mov    %esp,%ebp
  801ac3:	56                   	push   %esi
  801ac4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801ac5:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ac8:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801ace:	e8 69 f0 ff ff       	call   800b3c <sys_getenvid>
  801ad3:	83 ec 0c             	sub    $0xc,%esp
  801ad6:	ff 75 0c             	pushl  0xc(%ebp)
  801ad9:	ff 75 08             	pushl  0x8(%ebp)
  801adc:	56                   	push   %esi
  801add:	50                   	push   %eax
  801ade:	68 18 23 80 00       	push   $0x802318
  801ae3:	e8 8b e6 ff ff       	call   800173 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ae8:	83 c4 18             	add    $0x18,%esp
  801aeb:	53                   	push   %ebx
  801aec:	ff 75 10             	pushl  0x10(%ebp)
  801aef:	e8 2e e6 ff ff       	call   800122 <vcprintf>
	cprintf("\n");
  801af4:	c7 04 24 03 23 80 00 	movl   $0x802303,(%esp)
  801afb:	e8 73 e6 ff ff       	call   800173 <cprintf>
  801b00:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b03:	cc                   	int3   
  801b04:	eb fd                	jmp    801b03 <_panic+0x43>

00801b06 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b06:	55                   	push   %ebp
  801b07:	89 e5                	mov    %esp,%ebp
  801b09:	56                   	push   %esi
  801b0a:	53                   	push   %ebx
  801b0b:	8b 75 08             	mov    0x8(%ebp),%esi
  801b0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b11:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

    if (pg != NULL)
  801b14:	85 c0                	test   %eax,%eax
  801b16:	74 0e                	je     801b26 <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  801b18:	83 ec 0c             	sub    $0xc,%esp
  801b1b:	50                   	push   %eax
  801b1c:	e8 09 f2 ff ff       	call   800d2a <sys_ipc_recv>
  801b21:	83 c4 10             	add    $0x10,%esp
  801b24:	eb 0d                	jmp    801b33 <ipc_recv+0x2d>
	else
        r = sys_ipc_recv((void *)-1);
  801b26:	83 ec 0c             	sub    $0xc,%esp
  801b29:	6a ff                	push   $0xffffffff
  801b2b:	e8 fa f1 ff ff       	call   800d2a <sys_ipc_recv>
  801b30:	83 c4 10             	add    $0x10,%esp

	if (r < 0) {
  801b33:	85 c0                	test   %eax,%eax
  801b35:	79 16                	jns    801b4d <ipc_recv+0x47>

		if (from_env_store != NULL)
  801b37:	85 f6                	test   %esi,%esi
  801b39:	74 06                	je     801b41 <ipc_recv+0x3b>
			*from_env_store = 0;
  801b3b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL)
  801b41:	85 db                	test   %ebx,%ebx
  801b43:	74 2c                	je     801b71 <ipc_recv+0x6b>
			*perm_store = 0;
  801b45:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b4b:	eb 24                	jmp    801b71 <ipc_recv+0x6b>
		return r;

	} else {

		if (from_env_store != NULL)
  801b4d:	85 f6                	test   %esi,%esi
  801b4f:	74 0a                	je     801b5b <ipc_recv+0x55>
			*from_env_store = thisenv->env_ipc_from;
  801b51:	a1 04 40 80 00       	mov    0x804004,%eax
  801b56:	8b 40 74             	mov    0x74(%eax),%eax
  801b59:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL)
  801b5b:	85 db                	test   %ebx,%ebx
  801b5d:	74 0a                	je     801b69 <ipc_recv+0x63>
			*perm_store = thisenv->env_ipc_perm;
  801b5f:	a1 04 40 80 00       	mov    0x804004,%eax
  801b64:	8b 40 78             	mov    0x78(%eax),%eax
  801b67:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801b69:	a1 04 40 80 00       	mov    0x804004,%eax
  801b6e:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801b71:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b74:	5b                   	pop    %ebx
  801b75:	5e                   	pop    %esi
  801b76:	5d                   	pop    %ebp
  801b77:	c3                   	ret    

00801b78 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b78:	55                   	push   %ebp
  801b79:	89 e5                	mov    %esp,%ebp
  801b7b:	57                   	push   %edi
  801b7c:	56                   	push   %esi
  801b7d:	53                   	push   %ebx
  801b7e:	83 ec 0c             	sub    $0xc,%esp
  801b81:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b84:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b87:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

	if (pg == NULL)
  801b8a:	85 db                	test   %ebx,%ebx
		pg = (void *)-1;	
  801b8c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801b91:	0f 44 d8             	cmove  %eax,%ebx

	while (true) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801b94:	ff 75 14             	pushl  0x14(%ebp)
  801b97:	53                   	push   %ebx
  801b98:	56                   	push   %esi
  801b99:	57                   	push   %edi
  801b9a:	e8 68 f1 ff ff       	call   800d07 <sys_ipc_try_send>
		if (r >= 0)
  801b9f:	83 c4 10             	add    $0x10,%esp
  801ba2:	85 c0                	test   %eax,%eax
  801ba4:	79 1e                	jns    801bc4 <ipc_send+0x4c>
			return;
		else if (r != -E_IPC_NOT_RECV)
  801ba6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ba9:	74 12                	je     801bbd <ipc_send+0x45>
			panic("ipc_send error: %e", r);
  801bab:	50                   	push   %eax
  801bac:	68 3c 23 80 00       	push   $0x80233c
  801bb1:	6a 49                	push   $0x49
  801bb3:	68 4f 23 80 00       	push   $0x80234f
  801bb8:	e8 03 ff ff ff       	call   801ac0 <_panic>
	
		sys_yield();
  801bbd:	e8 99 ef ff ff       	call   800b5b <sys_yield>
	}
  801bc2:	eb d0                	jmp    801b94 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  801bc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bc7:	5b                   	pop    %ebx
  801bc8:	5e                   	pop    %esi
  801bc9:	5f                   	pop    %edi
  801bca:	5d                   	pop    %ebp
  801bcb:	c3                   	ret    

00801bcc <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801bcc:	55                   	push   %ebp
  801bcd:	89 e5                	mov    %esp,%ebp
  801bcf:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801bd2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801bd7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801bda:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801be0:	8b 52 50             	mov    0x50(%edx),%edx
  801be3:	39 ca                	cmp    %ecx,%edx
  801be5:	75 0d                	jne    801bf4 <ipc_find_env+0x28>
			return envs[i].env_id;
  801be7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801bea:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801bef:	8b 40 48             	mov    0x48(%eax),%eax
  801bf2:	eb 0f                	jmp    801c03 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801bf4:	83 c0 01             	add    $0x1,%eax
  801bf7:	3d 00 04 00 00       	cmp    $0x400,%eax
  801bfc:	75 d9                	jne    801bd7 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801bfe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c03:	5d                   	pop    %ebp
  801c04:	c3                   	ret    

00801c05 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c05:	55                   	push   %ebp
  801c06:	89 e5                	mov    %esp,%ebp
  801c08:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c0b:	89 d0                	mov    %edx,%eax
  801c0d:	c1 e8 16             	shr    $0x16,%eax
  801c10:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c17:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c1c:	f6 c1 01             	test   $0x1,%cl
  801c1f:	74 1d                	je     801c3e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c21:	c1 ea 0c             	shr    $0xc,%edx
  801c24:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c2b:	f6 c2 01             	test   $0x1,%dl
  801c2e:	74 0e                	je     801c3e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c30:	c1 ea 0c             	shr    $0xc,%edx
  801c33:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c3a:	ef 
  801c3b:	0f b7 c0             	movzwl %ax,%eax
}
  801c3e:	5d                   	pop    %ebp
  801c3f:	c3                   	ret    

00801c40 <__udivdi3>:
  801c40:	55                   	push   %ebp
  801c41:	57                   	push   %edi
  801c42:	56                   	push   %esi
  801c43:	53                   	push   %ebx
  801c44:	83 ec 1c             	sub    $0x1c,%esp
  801c47:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801c4b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c4f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801c53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c57:	85 f6                	test   %esi,%esi
  801c59:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c5d:	89 ca                	mov    %ecx,%edx
  801c5f:	89 f8                	mov    %edi,%eax
  801c61:	75 3d                	jne    801ca0 <__udivdi3+0x60>
  801c63:	39 cf                	cmp    %ecx,%edi
  801c65:	0f 87 c5 00 00 00    	ja     801d30 <__udivdi3+0xf0>
  801c6b:	85 ff                	test   %edi,%edi
  801c6d:	89 fd                	mov    %edi,%ebp
  801c6f:	75 0b                	jne    801c7c <__udivdi3+0x3c>
  801c71:	b8 01 00 00 00       	mov    $0x1,%eax
  801c76:	31 d2                	xor    %edx,%edx
  801c78:	f7 f7                	div    %edi
  801c7a:	89 c5                	mov    %eax,%ebp
  801c7c:	89 c8                	mov    %ecx,%eax
  801c7e:	31 d2                	xor    %edx,%edx
  801c80:	f7 f5                	div    %ebp
  801c82:	89 c1                	mov    %eax,%ecx
  801c84:	89 d8                	mov    %ebx,%eax
  801c86:	89 cf                	mov    %ecx,%edi
  801c88:	f7 f5                	div    %ebp
  801c8a:	89 c3                	mov    %eax,%ebx
  801c8c:	89 d8                	mov    %ebx,%eax
  801c8e:	89 fa                	mov    %edi,%edx
  801c90:	83 c4 1c             	add    $0x1c,%esp
  801c93:	5b                   	pop    %ebx
  801c94:	5e                   	pop    %esi
  801c95:	5f                   	pop    %edi
  801c96:	5d                   	pop    %ebp
  801c97:	c3                   	ret    
  801c98:	90                   	nop
  801c99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ca0:	39 ce                	cmp    %ecx,%esi
  801ca2:	77 74                	ja     801d18 <__udivdi3+0xd8>
  801ca4:	0f bd fe             	bsr    %esi,%edi
  801ca7:	83 f7 1f             	xor    $0x1f,%edi
  801caa:	0f 84 98 00 00 00    	je     801d48 <__udivdi3+0x108>
  801cb0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801cb5:	89 f9                	mov    %edi,%ecx
  801cb7:	89 c5                	mov    %eax,%ebp
  801cb9:	29 fb                	sub    %edi,%ebx
  801cbb:	d3 e6                	shl    %cl,%esi
  801cbd:	89 d9                	mov    %ebx,%ecx
  801cbf:	d3 ed                	shr    %cl,%ebp
  801cc1:	89 f9                	mov    %edi,%ecx
  801cc3:	d3 e0                	shl    %cl,%eax
  801cc5:	09 ee                	or     %ebp,%esi
  801cc7:	89 d9                	mov    %ebx,%ecx
  801cc9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ccd:	89 d5                	mov    %edx,%ebp
  801ccf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801cd3:	d3 ed                	shr    %cl,%ebp
  801cd5:	89 f9                	mov    %edi,%ecx
  801cd7:	d3 e2                	shl    %cl,%edx
  801cd9:	89 d9                	mov    %ebx,%ecx
  801cdb:	d3 e8                	shr    %cl,%eax
  801cdd:	09 c2                	or     %eax,%edx
  801cdf:	89 d0                	mov    %edx,%eax
  801ce1:	89 ea                	mov    %ebp,%edx
  801ce3:	f7 f6                	div    %esi
  801ce5:	89 d5                	mov    %edx,%ebp
  801ce7:	89 c3                	mov    %eax,%ebx
  801ce9:	f7 64 24 0c          	mull   0xc(%esp)
  801ced:	39 d5                	cmp    %edx,%ebp
  801cef:	72 10                	jb     801d01 <__udivdi3+0xc1>
  801cf1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801cf5:	89 f9                	mov    %edi,%ecx
  801cf7:	d3 e6                	shl    %cl,%esi
  801cf9:	39 c6                	cmp    %eax,%esi
  801cfb:	73 07                	jae    801d04 <__udivdi3+0xc4>
  801cfd:	39 d5                	cmp    %edx,%ebp
  801cff:	75 03                	jne    801d04 <__udivdi3+0xc4>
  801d01:	83 eb 01             	sub    $0x1,%ebx
  801d04:	31 ff                	xor    %edi,%edi
  801d06:	89 d8                	mov    %ebx,%eax
  801d08:	89 fa                	mov    %edi,%edx
  801d0a:	83 c4 1c             	add    $0x1c,%esp
  801d0d:	5b                   	pop    %ebx
  801d0e:	5e                   	pop    %esi
  801d0f:	5f                   	pop    %edi
  801d10:	5d                   	pop    %ebp
  801d11:	c3                   	ret    
  801d12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d18:	31 ff                	xor    %edi,%edi
  801d1a:	31 db                	xor    %ebx,%ebx
  801d1c:	89 d8                	mov    %ebx,%eax
  801d1e:	89 fa                	mov    %edi,%edx
  801d20:	83 c4 1c             	add    $0x1c,%esp
  801d23:	5b                   	pop    %ebx
  801d24:	5e                   	pop    %esi
  801d25:	5f                   	pop    %edi
  801d26:	5d                   	pop    %ebp
  801d27:	c3                   	ret    
  801d28:	90                   	nop
  801d29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d30:	89 d8                	mov    %ebx,%eax
  801d32:	f7 f7                	div    %edi
  801d34:	31 ff                	xor    %edi,%edi
  801d36:	89 c3                	mov    %eax,%ebx
  801d38:	89 d8                	mov    %ebx,%eax
  801d3a:	89 fa                	mov    %edi,%edx
  801d3c:	83 c4 1c             	add    $0x1c,%esp
  801d3f:	5b                   	pop    %ebx
  801d40:	5e                   	pop    %esi
  801d41:	5f                   	pop    %edi
  801d42:	5d                   	pop    %ebp
  801d43:	c3                   	ret    
  801d44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d48:	39 ce                	cmp    %ecx,%esi
  801d4a:	72 0c                	jb     801d58 <__udivdi3+0x118>
  801d4c:	31 db                	xor    %ebx,%ebx
  801d4e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801d52:	0f 87 34 ff ff ff    	ja     801c8c <__udivdi3+0x4c>
  801d58:	bb 01 00 00 00       	mov    $0x1,%ebx
  801d5d:	e9 2a ff ff ff       	jmp    801c8c <__udivdi3+0x4c>
  801d62:	66 90                	xchg   %ax,%ax
  801d64:	66 90                	xchg   %ax,%ax
  801d66:	66 90                	xchg   %ax,%ax
  801d68:	66 90                	xchg   %ax,%ax
  801d6a:	66 90                	xchg   %ax,%ax
  801d6c:	66 90                	xchg   %ax,%ax
  801d6e:	66 90                	xchg   %ax,%ax

00801d70 <__umoddi3>:
  801d70:	55                   	push   %ebp
  801d71:	57                   	push   %edi
  801d72:	56                   	push   %esi
  801d73:	53                   	push   %ebx
  801d74:	83 ec 1c             	sub    $0x1c,%esp
  801d77:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d7b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d7f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d87:	85 d2                	test   %edx,%edx
  801d89:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d91:	89 f3                	mov    %esi,%ebx
  801d93:	89 3c 24             	mov    %edi,(%esp)
  801d96:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d9a:	75 1c                	jne    801db8 <__umoddi3+0x48>
  801d9c:	39 f7                	cmp    %esi,%edi
  801d9e:	76 50                	jbe    801df0 <__umoddi3+0x80>
  801da0:	89 c8                	mov    %ecx,%eax
  801da2:	89 f2                	mov    %esi,%edx
  801da4:	f7 f7                	div    %edi
  801da6:	89 d0                	mov    %edx,%eax
  801da8:	31 d2                	xor    %edx,%edx
  801daa:	83 c4 1c             	add    $0x1c,%esp
  801dad:	5b                   	pop    %ebx
  801dae:	5e                   	pop    %esi
  801daf:	5f                   	pop    %edi
  801db0:	5d                   	pop    %ebp
  801db1:	c3                   	ret    
  801db2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801db8:	39 f2                	cmp    %esi,%edx
  801dba:	89 d0                	mov    %edx,%eax
  801dbc:	77 52                	ja     801e10 <__umoddi3+0xa0>
  801dbe:	0f bd ea             	bsr    %edx,%ebp
  801dc1:	83 f5 1f             	xor    $0x1f,%ebp
  801dc4:	75 5a                	jne    801e20 <__umoddi3+0xb0>
  801dc6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801dca:	0f 82 e0 00 00 00    	jb     801eb0 <__umoddi3+0x140>
  801dd0:	39 0c 24             	cmp    %ecx,(%esp)
  801dd3:	0f 86 d7 00 00 00    	jbe    801eb0 <__umoddi3+0x140>
  801dd9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ddd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801de1:	83 c4 1c             	add    $0x1c,%esp
  801de4:	5b                   	pop    %ebx
  801de5:	5e                   	pop    %esi
  801de6:	5f                   	pop    %edi
  801de7:	5d                   	pop    %ebp
  801de8:	c3                   	ret    
  801de9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801df0:	85 ff                	test   %edi,%edi
  801df2:	89 fd                	mov    %edi,%ebp
  801df4:	75 0b                	jne    801e01 <__umoddi3+0x91>
  801df6:	b8 01 00 00 00       	mov    $0x1,%eax
  801dfb:	31 d2                	xor    %edx,%edx
  801dfd:	f7 f7                	div    %edi
  801dff:	89 c5                	mov    %eax,%ebp
  801e01:	89 f0                	mov    %esi,%eax
  801e03:	31 d2                	xor    %edx,%edx
  801e05:	f7 f5                	div    %ebp
  801e07:	89 c8                	mov    %ecx,%eax
  801e09:	f7 f5                	div    %ebp
  801e0b:	89 d0                	mov    %edx,%eax
  801e0d:	eb 99                	jmp    801da8 <__umoddi3+0x38>
  801e0f:	90                   	nop
  801e10:	89 c8                	mov    %ecx,%eax
  801e12:	89 f2                	mov    %esi,%edx
  801e14:	83 c4 1c             	add    $0x1c,%esp
  801e17:	5b                   	pop    %ebx
  801e18:	5e                   	pop    %esi
  801e19:	5f                   	pop    %edi
  801e1a:	5d                   	pop    %ebp
  801e1b:	c3                   	ret    
  801e1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e20:	8b 34 24             	mov    (%esp),%esi
  801e23:	bf 20 00 00 00       	mov    $0x20,%edi
  801e28:	89 e9                	mov    %ebp,%ecx
  801e2a:	29 ef                	sub    %ebp,%edi
  801e2c:	d3 e0                	shl    %cl,%eax
  801e2e:	89 f9                	mov    %edi,%ecx
  801e30:	89 f2                	mov    %esi,%edx
  801e32:	d3 ea                	shr    %cl,%edx
  801e34:	89 e9                	mov    %ebp,%ecx
  801e36:	09 c2                	or     %eax,%edx
  801e38:	89 d8                	mov    %ebx,%eax
  801e3a:	89 14 24             	mov    %edx,(%esp)
  801e3d:	89 f2                	mov    %esi,%edx
  801e3f:	d3 e2                	shl    %cl,%edx
  801e41:	89 f9                	mov    %edi,%ecx
  801e43:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e47:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801e4b:	d3 e8                	shr    %cl,%eax
  801e4d:	89 e9                	mov    %ebp,%ecx
  801e4f:	89 c6                	mov    %eax,%esi
  801e51:	d3 e3                	shl    %cl,%ebx
  801e53:	89 f9                	mov    %edi,%ecx
  801e55:	89 d0                	mov    %edx,%eax
  801e57:	d3 e8                	shr    %cl,%eax
  801e59:	89 e9                	mov    %ebp,%ecx
  801e5b:	09 d8                	or     %ebx,%eax
  801e5d:	89 d3                	mov    %edx,%ebx
  801e5f:	89 f2                	mov    %esi,%edx
  801e61:	f7 34 24             	divl   (%esp)
  801e64:	89 d6                	mov    %edx,%esi
  801e66:	d3 e3                	shl    %cl,%ebx
  801e68:	f7 64 24 04          	mull   0x4(%esp)
  801e6c:	39 d6                	cmp    %edx,%esi
  801e6e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e72:	89 d1                	mov    %edx,%ecx
  801e74:	89 c3                	mov    %eax,%ebx
  801e76:	72 08                	jb     801e80 <__umoddi3+0x110>
  801e78:	75 11                	jne    801e8b <__umoddi3+0x11b>
  801e7a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801e7e:	73 0b                	jae    801e8b <__umoddi3+0x11b>
  801e80:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e84:	1b 14 24             	sbb    (%esp),%edx
  801e87:	89 d1                	mov    %edx,%ecx
  801e89:	89 c3                	mov    %eax,%ebx
  801e8b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e8f:	29 da                	sub    %ebx,%edx
  801e91:	19 ce                	sbb    %ecx,%esi
  801e93:	89 f9                	mov    %edi,%ecx
  801e95:	89 f0                	mov    %esi,%eax
  801e97:	d3 e0                	shl    %cl,%eax
  801e99:	89 e9                	mov    %ebp,%ecx
  801e9b:	d3 ea                	shr    %cl,%edx
  801e9d:	89 e9                	mov    %ebp,%ecx
  801e9f:	d3 ee                	shr    %cl,%esi
  801ea1:	09 d0                	or     %edx,%eax
  801ea3:	89 f2                	mov    %esi,%edx
  801ea5:	83 c4 1c             	add    $0x1c,%esp
  801ea8:	5b                   	pop    %ebx
  801ea9:	5e                   	pop    %esi
  801eaa:	5f                   	pop    %edi
  801eab:	5d                   	pop    %ebp
  801eac:	c3                   	ret    
  801ead:	8d 76 00             	lea    0x0(%esi),%esi
  801eb0:	29 f9                	sub    %edi,%ecx
  801eb2:	19 d6                	sbb    %edx,%esi
  801eb4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801eb8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ebc:	e9 18 ff ff ff       	jmp    801dd9 <__umoddi3+0x69>
