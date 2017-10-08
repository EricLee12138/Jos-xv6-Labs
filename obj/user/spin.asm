
obj/user/spin.debug：     文件格式 elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 10             	sub    $0x10,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003a:	68 60 21 80 00       	push   $0x802160
  80003f:	e8 64 01 00 00       	call   8001a8 <cprintf>
	if ((env = fork()) == 0) {
  800044:	e8 fc 0d 00 00       	call   800e45 <fork>
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	85 c0                	test   %eax,%eax
  80004e:	75 12                	jne    800062 <umain+0x2f>
		cprintf("I am the child.  Spinning...\n");
  800050:	83 ec 0c             	sub    $0xc,%esp
  800053:	68 d8 21 80 00       	push   $0x8021d8
  800058:	e8 4b 01 00 00       	call   8001a8 <cprintf>
  80005d:	83 c4 10             	add    $0x10,%esp
  800060:	eb fe                	jmp    800060 <umain+0x2d>
  800062:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	68 88 21 80 00       	push   $0x802188
  80006c:	e8 37 01 00 00       	call   8001a8 <cprintf>
	sys_yield();
  800071:	e8 1a 0b 00 00       	call   800b90 <sys_yield>
	sys_yield();
  800076:	e8 15 0b 00 00       	call   800b90 <sys_yield>
	sys_yield();
  80007b:	e8 10 0b 00 00       	call   800b90 <sys_yield>
	sys_yield();
  800080:	e8 0b 0b 00 00       	call   800b90 <sys_yield>
	sys_yield();
  800085:	e8 06 0b 00 00       	call   800b90 <sys_yield>
	sys_yield();
  80008a:	e8 01 0b 00 00       	call   800b90 <sys_yield>
	sys_yield();
  80008f:	e8 fc 0a 00 00       	call   800b90 <sys_yield>
	sys_yield();
  800094:	e8 f7 0a 00 00       	call   800b90 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800099:	c7 04 24 b0 21 80 00 	movl   $0x8021b0,(%esp)
  8000a0:	e8 03 01 00 00       	call   8001a8 <cprintf>
	sys_env_destroy(env);
  8000a5:	89 1c 24             	mov    %ebx,(%esp)
  8000a8:	e8 83 0a 00 00       	call   800b30 <sys_env_destroy>
}
  8000ad:	83 c4 10             	add    $0x10,%esp
  8000b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000c0:	e8 ac 0a 00 00       	call   800b71 <sys_getenvid>
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d2:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d7:	85 db                	test   %ebx,%ebx
  8000d9:	7e 07                	jle    8000e2 <libmain+0x2d>
		binaryname = argv[0];
  8000db:	8b 06                	mov    (%esi),%eax
  8000dd:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000e2:	83 ec 08             	sub    $0x8,%esp
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	e8 47 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000ec:	e8 0a 00 00 00       	call   8000fb <exit>
}
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800101:	e8 be 10 00 00       	call   8011c4 <close_all>
	sys_env_destroy(0);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	6a 00                	push   $0x0
  80010b:	e8 20 0a 00 00       	call   800b30 <sys_env_destroy>
}
  800110:	83 c4 10             	add    $0x10,%esp
  800113:	c9                   	leave  
  800114:	c3                   	ret    

00800115 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	53                   	push   %ebx
  800119:	83 ec 04             	sub    $0x4,%esp
  80011c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80011f:	8b 13                	mov    (%ebx),%edx
  800121:	8d 42 01             	lea    0x1(%edx),%eax
  800124:	89 03                	mov    %eax,(%ebx)
  800126:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800129:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80012d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800132:	75 1a                	jne    80014e <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800134:	83 ec 08             	sub    $0x8,%esp
  800137:	68 ff 00 00 00       	push   $0xff
  80013c:	8d 43 08             	lea    0x8(%ebx),%eax
  80013f:	50                   	push   %eax
  800140:	e8 ae 09 00 00       	call   800af3 <sys_cputs>
		b->idx = 0;
  800145:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80014b:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80014e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800152:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800155:	c9                   	leave  
  800156:	c3                   	ret    

00800157 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800160:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800167:	00 00 00 
	b.cnt = 0;
  80016a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800171:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800174:	ff 75 0c             	pushl  0xc(%ebp)
  800177:	ff 75 08             	pushl  0x8(%ebp)
  80017a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800180:	50                   	push   %eax
  800181:	68 15 01 80 00       	push   $0x800115
  800186:	e8 1a 01 00 00       	call   8002a5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80018b:	83 c4 08             	add    $0x8,%esp
  80018e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800194:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80019a:	50                   	push   %eax
  80019b:	e8 53 09 00 00       	call   800af3 <sys_cputs>

	return b.cnt;
}
  8001a0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    

008001a8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ae:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b1:	50                   	push   %eax
  8001b2:	ff 75 08             	pushl  0x8(%ebp)
  8001b5:	e8 9d ff ff ff       	call   800157 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ba:	c9                   	leave  
  8001bb:	c3                   	ret    

008001bc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	57                   	push   %edi
  8001c0:	56                   	push   %esi
  8001c1:	53                   	push   %ebx
  8001c2:	83 ec 1c             	sub    $0x1c,%esp
  8001c5:	89 c7                	mov    %eax,%edi
  8001c7:	89 d6                	mov    %edx,%esi
  8001c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8001cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001cf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d2:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001d8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001dd:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001e0:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001e3:	39 d3                	cmp    %edx,%ebx
  8001e5:	72 05                	jb     8001ec <printnum+0x30>
  8001e7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001ea:	77 45                	ja     800231 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ec:	83 ec 0c             	sub    $0xc,%esp
  8001ef:	ff 75 18             	pushl  0x18(%ebp)
  8001f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8001f5:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001f8:	53                   	push   %ebx
  8001f9:	ff 75 10             	pushl  0x10(%ebp)
  8001fc:	83 ec 08             	sub    $0x8,%esp
  8001ff:	ff 75 e4             	pushl  -0x1c(%ebp)
  800202:	ff 75 e0             	pushl  -0x20(%ebp)
  800205:	ff 75 dc             	pushl  -0x24(%ebp)
  800208:	ff 75 d8             	pushl  -0x28(%ebp)
  80020b:	e8 c0 1c 00 00       	call   801ed0 <__udivdi3>
  800210:	83 c4 18             	add    $0x18,%esp
  800213:	52                   	push   %edx
  800214:	50                   	push   %eax
  800215:	89 f2                	mov    %esi,%edx
  800217:	89 f8                	mov    %edi,%eax
  800219:	e8 9e ff ff ff       	call   8001bc <printnum>
  80021e:	83 c4 20             	add    $0x20,%esp
  800221:	eb 18                	jmp    80023b <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800223:	83 ec 08             	sub    $0x8,%esp
  800226:	56                   	push   %esi
  800227:	ff 75 18             	pushl  0x18(%ebp)
  80022a:	ff d7                	call   *%edi
  80022c:	83 c4 10             	add    $0x10,%esp
  80022f:	eb 03                	jmp    800234 <printnum+0x78>
  800231:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800234:	83 eb 01             	sub    $0x1,%ebx
  800237:	85 db                	test   %ebx,%ebx
  800239:	7f e8                	jg     800223 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80023b:	83 ec 08             	sub    $0x8,%esp
  80023e:	56                   	push   %esi
  80023f:	83 ec 04             	sub    $0x4,%esp
  800242:	ff 75 e4             	pushl  -0x1c(%ebp)
  800245:	ff 75 e0             	pushl  -0x20(%ebp)
  800248:	ff 75 dc             	pushl  -0x24(%ebp)
  80024b:	ff 75 d8             	pushl  -0x28(%ebp)
  80024e:	e8 ad 1d 00 00       	call   802000 <__umoddi3>
  800253:	83 c4 14             	add    $0x14,%esp
  800256:	0f be 80 00 22 80 00 	movsbl 0x802200(%eax),%eax
  80025d:	50                   	push   %eax
  80025e:	ff d7                	call   *%edi
}
  800260:	83 c4 10             	add    $0x10,%esp
  800263:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800266:	5b                   	pop    %ebx
  800267:	5e                   	pop    %esi
  800268:	5f                   	pop    %edi
  800269:	5d                   	pop    %ebp
  80026a:	c3                   	ret    

0080026b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800271:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800275:	8b 10                	mov    (%eax),%edx
  800277:	3b 50 04             	cmp    0x4(%eax),%edx
  80027a:	73 0a                	jae    800286 <sprintputch+0x1b>
		*b->buf++ = ch;
  80027c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80027f:	89 08                	mov    %ecx,(%eax)
  800281:	8b 45 08             	mov    0x8(%ebp),%eax
  800284:	88 02                	mov    %al,(%edx)
}
  800286:	5d                   	pop    %ebp
  800287:	c3                   	ret    

00800288 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800288:	55                   	push   %ebp
  800289:	89 e5                	mov    %esp,%ebp
  80028b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80028e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800291:	50                   	push   %eax
  800292:	ff 75 10             	pushl  0x10(%ebp)
  800295:	ff 75 0c             	pushl  0xc(%ebp)
  800298:	ff 75 08             	pushl  0x8(%ebp)
  80029b:	e8 05 00 00 00       	call   8002a5 <vprintfmt>
	va_end(ap);
}
  8002a0:	83 c4 10             	add    $0x10,%esp
  8002a3:	c9                   	leave  
  8002a4:	c3                   	ret    

008002a5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	57                   	push   %edi
  8002a9:	56                   	push   %esi
  8002aa:	53                   	push   %ebx
  8002ab:	83 ec 2c             	sub    $0x2c,%esp
  8002ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8002b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002b4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002b7:	eb 12                	jmp    8002cb <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002b9:	85 c0                	test   %eax,%eax
  8002bb:	0f 84 42 04 00 00    	je     800703 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8002c1:	83 ec 08             	sub    $0x8,%esp
  8002c4:	53                   	push   %ebx
  8002c5:	50                   	push   %eax
  8002c6:	ff d6                	call   *%esi
  8002c8:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002cb:	83 c7 01             	add    $0x1,%edi
  8002ce:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002d2:	83 f8 25             	cmp    $0x25,%eax
  8002d5:	75 e2                	jne    8002b9 <vprintfmt+0x14>
  8002d7:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002db:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002e2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002e9:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002f5:	eb 07                	jmp    8002fe <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002fa:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002fe:	8d 47 01             	lea    0x1(%edi),%eax
  800301:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800304:	0f b6 07             	movzbl (%edi),%eax
  800307:	0f b6 d0             	movzbl %al,%edx
  80030a:	83 e8 23             	sub    $0x23,%eax
  80030d:	3c 55                	cmp    $0x55,%al
  80030f:	0f 87 d3 03 00 00    	ja     8006e8 <vprintfmt+0x443>
  800315:	0f b6 c0             	movzbl %al,%eax
  800318:	ff 24 85 40 23 80 00 	jmp    *0x802340(,%eax,4)
  80031f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800322:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800326:	eb d6                	jmp    8002fe <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800328:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80032b:	b8 00 00 00 00       	mov    $0x0,%eax
  800330:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800333:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800336:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80033a:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80033d:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800340:	83 f9 09             	cmp    $0x9,%ecx
  800343:	77 3f                	ja     800384 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800345:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800348:	eb e9                	jmp    800333 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80034a:	8b 45 14             	mov    0x14(%ebp),%eax
  80034d:	8b 00                	mov    (%eax),%eax
  80034f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800352:	8b 45 14             	mov    0x14(%ebp),%eax
  800355:	8d 40 04             	lea    0x4(%eax),%eax
  800358:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80035e:	eb 2a                	jmp    80038a <vprintfmt+0xe5>
  800360:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800363:	85 c0                	test   %eax,%eax
  800365:	ba 00 00 00 00       	mov    $0x0,%edx
  80036a:	0f 49 d0             	cmovns %eax,%edx
  80036d:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800370:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800373:	eb 89                	jmp    8002fe <vprintfmt+0x59>
  800375:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800378:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80037f:	e9 7a ff ff ff       	jmp    8002fe <vprintfmt+0x59>
  800384:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800387:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80038a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80038e:	0f 89 6a ff ff ff    	jns    8002fe <vprintfmt+0x59>
				width = precision, precision = -1;
  800394:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800397:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80039a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003a1:	e9 58 ff ff ff       	jmp    8002fe <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003a6:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003ac:	e9 4d ff ff ff       	jmp    8002fe <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b4:	8d 78 04             	lea    0x4(%eax),%edi
  8003b7:	83 ec 08             	sub    $0x8,%esp
  8003ba:	53                   	push   %ebx
  8003bb:	ff 30                	pushl  (%eax)
  8003bd:	ff d6                	call   *%esi
			break;
  8003bf:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003c2:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003c8:	e9 fe fe ff ff       	jmp    8002cb <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d0:	8d 78 04             	lea    0x4(%eax),%edi
  8003d3:	8b 00                	mov    (%eax),%eax
  8003d5:	99                   	cltd   
  8003d6:	31 d0                	xor    %edx,%eax
  8003d8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003da:	83 f8 0f             	cmp    $0xf,%eax
  8003dd:	7f 0b                	jg     8003ea <vprintfmt+0x145>
  8003df:	8b 14 85 a0 24 80 00 	mov    0x8024a0(,%eax,4),%edx
  8003e6:	85 d2                	test   %edx,%edx
  8003e8:	75 1b                	jne    800405 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8003ea:	50                   	push   %eax
  8003eb:	68 18 22 80 00       	push   $0x802218
  8003f0:	53                   	push   %ebx
  8003f1:	56                   	push   %esi
  8003f2:	e8 91 fe ff ff       	call   800288 <printfmt>
  8003f7:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003fa:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800400:	e9 c6 fe ff ff       	jmp    8002cb <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800405:	52                   	push   %edx
  800406:	68 39 26 80 00       	push   $0x802639
  80040b:	53                   	push   %ebx
  80040c:	56                   	push   %esi
  80040d:	e8 76 fe ff ff       	call   800288 <printfmt>
  800412:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800415:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800418:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80041b:	e9 ab fe ff ff       	jmp    8002cb <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800420:	8b 45 14             	mov    0x14(%ebp),%eax
  800423:	83 c0 04             	add    $0x4,%eax
  800426:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800429:	8b 45 14             	mov    0x14(%ebp),%eax
  80042c:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80042e:	85 ff                	test   %edi,%edi
  800430:	b8 11 22 80 00       	mov    $0x802211,%eax
  800435:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800438:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80043c:	0f 8e 94 00 00 00    	jle    8004d6 <vprintfmt+0x231>
  800442:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800446:	0f 84 98 00 00 00    	je     8004e4 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  80044c:	83 ec 08             	sub    $0x8,%esp
  80044f:	ff 75 d0             	pushl  -0x30(%ebp)
  800452:	57                   	push   %edi
  800453:	e8 33 03 00 00       	call   80078b <strnlen>
  800458:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80045b:	29 c1                	sub    %eax,%ecx
  80045d:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800460:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800463:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800467:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80046a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80046d:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80046f:	eb 0f                	jmp    800480 <vprintfmt+0x1db>
					putch(padc, putdat);
  800471:	83 ec 08             	sub    $0x8,%esp
  800474:	53                   	push   %ebx
  800475:	ff 75 e0             	pushl  -0x20(%ebp)
  800478:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80047a:	83 ef 01             	sub    $0x1,%edi
  80047d:	83 c4 10             	add    $0x10,%esp
  800480:	85 ff                	test   %edi,%edi
  800482:	7f ed                	jg     800471 <vprintfmt+0x1cc>
  800484:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800487:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80048a:	85 c9                	test   %ecx,%ecx
  80048c:	b8 00 00 00 00       	mov    $0x0,%eax
  800491:	0f 49 c1             	cmovns %ecx,%eax
  800494:	29 c1                	sub    %eax,%ecx
  800496:	89 75 08             	mov    %esi,0x8(%ebp)
  800499:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80049c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80049f:	89 cb                	mov    %ecx,%ebx
  8004a1:	eb 4d                	jmp    8004f0 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004a3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004a7:	74 1b                	je     8004c4 <vprintfmt+0x21f>
  8004a9:	0f be c0             	movsbl %al,%eax
  8004ac:	83 e8 20             	sub    $0x20,%eax
  8004af:	83 f8 5e             	cmp    $0x5e,%eax
  8004b2:	76 10                	jbe    8004c4 <vprintfmt+0x21f>
					putch('?', putdat);
  8004b4:	83 ec 08             	sub    $0x8,%esp
  8004b7:	ff 75 0c             	pushl  0xc(%ebp)
  8004ba:	6a 3f                	push   $0x3f
  8004bc:	ff 55 08             	call   *0x8(%ebp)
  8004bf:	83 c4 10             	add    $0x10,%esp
  8004c2:	eb 0d                	jmp    8004d1 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8004c4:	83 ec 08             	sub    $0x8,%esp
  8004c7:	ff 75 0c             	pushl  0xc(%ebp)
  8004ca:	52                   	push   %edx
  8004cb:	ff 55 08             	call   *0x8(%ebp)
  8004ce:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004d1:	83 eb 01             	sub    $0x1,%ebx
  8004d4:	eb 1a                	jmp    8004f0 <vprintfmt+0x24b>
  8004d6:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004dc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004df:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004e2:	eb 0c                	jmp    8004f0 <vprintfmt+0x24b>
  8004e4:	89 75 08             	mov    %esi,0x8(%ebp)
  8004e7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ea:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ed:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004f0:	83 c7 01             	add    $0x1,%edi
  8004f3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004f7:	0f be d0             	movsbl %al,%edx
  8004fa:	85 d2                	test   %edx,%edx
  8004fc:	74 23                	je     800521 <vprintfmt+0x27c>
  8004fe:	85 f6                	test   %esi,%esi
  800500:	78 a1                	js     8004a3 <vprintfmt+0x1fe>
  800502:	83 ee 01             	sub    $0x1,%esi
  800505:	79 9c                	jns    8004a3 <vprintfmt+0x1fe>
  800507:	89 df                	mov    %ebx,%edi
  800509:	8b 75 08             	mov    0x8(%ebp),%esi
  80050c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80050f:	eb 18                	jmp    800529 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800511:	83 ec 08             	sub    $0x8,%esp
  800514:	53                   	push   %ebx
  800515:	6a 20                	push   $0x20
  800517:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800519:	83 ef 01             	sub    $0x1,%edi
  80051c:	83 c4 10             	add    $0x10,%esp
  80051f:	eb 08                	jmp    800529 <vprintfmt+0x284>
  800521:	89 df                	mov    %ebx,%edi
  800523:	8b 75 08             	mov    0x8(%ebp),%esi
  800526:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800529:	85 ff                	test   %edi,%edi
  80052b:	7f e4                	jg     800511 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80052d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800530:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800533:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800536:	e9 90 fd ff ff       	jmp    8002cb <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80053b:	83 f9 01             	cmp    $0x1,%ecx
  80053e:	7e 19                	jle    800559 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800540:	8b 45 14             	mov    0x14(%ebp),%eax
  800543:	8b 50 04             	mov    0x4(%eax),%edx
  800546:	8b 00                	mov    (%eax),%eax
  800548:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80054b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80054e:	8b 45 14             	mov    0x14(%ebp),%eax
  800551:	8d 40 08             	lea    0x8(%eax),%eax
  800554:	89 45 14             	mov    %eax,0x14(%ebp)
  800557:	eb 38                	jmp    800591 <vprintfmt+0x2ec>
	else if (lflag)
  800559:	85 c9                	test   %ecx,%ecx
  80055b:	74 1b                	je     800578 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  80055d:	8b 45 14             	mov    0x14(%ebp),%eax
  800560:	8b 00                	mov    (%eax),%eax
  800562:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800565:	89 c1                	mov    %eax,%ecx
  800567:	c1 f9 1f             	sar    $0x1f,%ecx
  80056a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80056d:	8b 45 14             	mov    0x14(%ebp),%eax
  800570:	8d 40 04             	lea    0x4(%eax),%eax
  800573:	89 45 14             	mov    %eax,0x14(%ebp)
  800576:	eb 19                	jmp    800591 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800578:	8b 45 14             	mov    0x14(%ebp),%eax
  80057b:	8b 00                	mov    (%eax),%eax
  80057d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800580:	89 c1                	mov    %eax,%ecx
  800582:	c1 f9 1f             	sar    $0x1f,%ecx
  800585:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800588:	8b 45 14             	mov    0x14(%ebp),%eax
  80058b:	8d 40 04             	lea    0x4(%eax),%eax
  80058e:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800591:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800594:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800597:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80059c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005a0:	0f 89 0e 01 00 00    	jns    8006b4 <vprintfmt+0x40f>
				putch('-', putdat);
  8005a6:	83 ec 08             	sub    $0x8,%esp
  8005a9:	53                   	push   %ebx
  8005aa:	6a 2d                	push   $0x2d
  8005ac:	ff d6                	call   *%esi
				num = -(long long) num;
  8005ae:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005b1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005b4:	f7 da                	neg    %edx
  8005b6:	83 d1 00             	adc    $0x0,%ecx
  8005b9:	f7 d9                	neg    %ecx
  8005bb:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005be:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c3:	e9 ec 00 00 00       	jmp    8006b4 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005c8:	83 f9 01             	cmp    $0x1,%ecx
  8005cb:	7e 18                	jle    8005e5 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8005cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d0:	8b 10                	mov    (%eax),%edx
  8005d2:	8b 48 04             	mov    0x4(%eax),%ecx
  8005d5:	8d 40 08             	lea    0x8(%eax),%eax
  8005d8:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005db:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e0:	e9 cf 00 00 00       	jmp    8006b4 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8005e5:	85 c9                	test   %ecx,%ecx
  8005e7:	74 1a                	je     800603 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8005e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ec:	8b 10                	mov    (%eax),%edx
  8005ee:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f3:	8d 40 04             	lea    0x4(%eax),%eax
  8005f6:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005f9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005fe:	e9 b1 00 00 00       	jmp    8006b4 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800603:	8b 45 14             	mov    0x14(%ebp),%eax
  800606:	8b 10                	mov    (%eax),%edx
  800608:	b9 00 00 00 00       	mov    $0x0,%ecx
  80060d:	8d 40 04             	lea    0x4(%eax),%eax
  800610:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800613:	b8 0a 00 00 00       	mov    $0xa,%eax
  800618:	e9 97 00 00 00       	jmp    8006b4 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80061d:	83 ec 08             	sub    $0x8,%esp
  800620:	53                   	push   %ebx
  800621:	6a 58                	push   $0x58
  800623:	ff d6                	call   *%esi
			putch('X', putdat);
  800625:	83 c4 08             	add    $0x8,%esp
  800628:	53                   	push   %ebx
  800629:	6a 58                	push   $0x58
  80062b:	ff d6                	call   *%esi
			putch('X', putdat);
  80062d:	83 c4 08             	add    $0x8,%esp
  800630:	53                   	push   %ebx
  800631:	6a 58                	push   $0x58
  800633:	ff d6                	call   *%esi
			break;
  800635:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800638:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  80063b:	e9 8b fc ff ff       	jmp    8002cb <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800640:	83 ec 08             	sub    $0x8,%esp
  800643:	53                   	push   %ebx
  800644:	6a 30                	push   $0x30
  800646:	ff d6                	call   *%esi
			putch('x', putdat);
  800648:	83 c4 08             	add    $0x8,%esp
  80064b:	53                   	push   %ebx
  80064c:	6a 78                	push   $0x78
  80064e:	ff d6                	call   *%esi
			num = (unsigned long long)
  800650:	8b 45 14             	mov    0x14(%ebp),%eax
  800653:	8b 10                	mov    (%eax),%edx
  800655:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80065a:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80065d:	8d 40 04             	lea    0x4(%eax),%eax
  800660:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800663:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800668:	eb 4a                	jmp    8006b4 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80066a:	83 f9 01             	cmp    $0x1,%ecx
  80066d:	7e 15                	jle    800684 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  80066f:	8b 45 14             	mov    0x14(%ebp),%eax
  800672:	8b 10                	mov    (%eax),%edx
  800674:	8b 48 04             	mov    0x4(%eax),%ecx
  800677:	8d 40 08             	lea    0x8(%eax),%eax
  80067a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80067d:	b8 10 00 00 00       	mov    $0x10,%eax
  800682:	eb 30                	jmp    8006b4 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800684:	85 c9                	test   %ecx,%ecx
  800686:	74 17                	je     80069f <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800688:	8b 45 14             	mov    0x14(%ebp),%eax
  80068b:	8b 10                	mov    (%eax),%edx
  80068d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800692:	8d 40 04             	lea    0x4(%eax),%eax
  800695:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800698:	b8 10 00 00 00       	mov    $0x10,%eax
  80069d:	eb 15                	jmp    8006b4 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80069f:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a2:	8b 10                	mov    (%eax),%edx
  8006a4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006a9:	8d 40 04             	lea    0x4(%eax),%eax
  8006ac:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006af:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006b4:	83 ec 0c             	sub    $0xc,%esp
  8006b7:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006bb:	57                   	push   %edi
  8006bc:	ff 75 e0             	pushl  -0x20(%ebp)
  8006bf:	50                   	push   %eax
  8006c0:	51                   	push   %ecx
  8006c1:	52                   	push   %edx
  8006c2:	89 da                	mov    %ebx,%edx
  8006c4:	89 f0                	mov    %esi,%eax
  8006c6:	e8 f1 fa ff ff       	call   8001bc <printnum>
			break;
  8006cb:	83 c4 20             	add    $0x20,%esp
  8006ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006d1:	e9 f5 fb ff ff       	jmp    8002cb <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006d6:	83 ec 08             	sub    $0x8,%esp
  8006d9:	53                   	push   %ebx
  8006da:	52                   	push   %edx
  8006db:	ff d6                	call   *%esi
			break;
  8006dd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006e3:	e9 e3 fb ff ff       	jmp    8002cb <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006e8:	83 ec 08             	sub    $0x8,%esp
  8006eb:	53                   	push   %ebx
  8006ec:	6a 25                	push   $0x25
  8006ee:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006f0:	83 c4 10             	add    $0x10,%esp
  8006f3:	eb 03                	jmp    8006f8 <vprintfmt+0x453>
  8006f5:	83 ef 01             	sub    $0x1,%edi
  8006f8:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006fc:	75 f7                	jne    8006f5 <vprintfmt+0x450>
  8006fe:	e9 c8 fb ff ff       	jmp    8002cb <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800703:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800706:	5b                   	pop    %ebx
  800707:	5e                   	pop    %esi
  800708:	5f                   	pop    %edi
  800709:	5d                   	pop    %ebp
  80070a:	c3                   	ret    

0080070b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80070b:	55                   	push   %ebp
  80070c:	89 e5                	mov    %esp,%ebp
  80070e:	83 ec 18             	sub    $0x18,%esp
  800711:	8b 45 08             	mov    0x8(%ebp),%eax
  800714:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800717:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80071a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80071e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800721:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800728:	85 c0                	test   %eax,%eax
  80072a:	74 26                	je     800752 <vsnprintf+0x47>
  80072c:	85 d2                	test   %edx,%edx
  80072e:	7e 22                	jle    800752 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800730:	ff 75 14             	pushl  0x14(%ebp)
  800733:	ff 75 10             	pushl  0x10(%ebp)
  800736:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800739:	50                   	push   %eax
  80073a:	68 6b 02 80 00       	push   $0x80026b
  80073f:	e8 61 fb ff ff       	call   8002a5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800744:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800747:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80074a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80074d:	83 c4 10             	add    $0x10,%esp
  800750:	eb 05                	jmp    800757 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800752:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800757:	c9                   	leave  
  800758:	c3                   	ret    

00800759 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800759:	55                   	push   %ebp
  80075a:	89 e5                	mov    %esp,%ebp
  80075c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80075f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800762:	50                   	push   %eax
  800763:	ff 75 10             	pushl  0x10(%ebp)
  800766:	ff 75 0c             	pushl  0xc(%ebp)
  800769:	ff 75 08             	pushl  0x8(%ebp)
  80076c:	e8 9a ff ff ff       	call   80070b <vsnprintf>
	va_end(ap);

	return rc;
}
  800771:	c9                   	leave  
  800772:	c3                   	ret    

00800773 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800773:	55                   	push   %ebp
  800774:	89 e5                	mov    %esp,%ebp
  800776:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800779:	b8 00 00 00 00       	mov    $0x0,%eax
  80077e:	eb 03                	jmp    800783 <strlen+0x10>
		n++;
  800780:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800783:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800787:	75 f7                	jne    800780 <strlen+0xd>
		n++;
	return n;
}
  800789:	5d                   	pop    %ebp
  80078a:	c3                   	ret    

0080078b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80078b:	55                   	push   %ebp
  80078c:	89 e5                	mov    %esp,%ebp
  80078e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800791:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800794:	ba 00 00 00 00       	mov    $0x0,%edx
  800799:	eb 03                	jmp    80079e <strnlen+0x13>
		n++;
  80079b:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079e:	39 c2                	cmp    %eax,%edx
  8007a0:	74 08                	je     8007aa <strnlen+0x1f>
  8007a2:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007a6:	75 f3                	jne    80079b <strnlen+0x10>
  8007a8:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007aa:	5d                   	pop    %ebp
  8007ab:	c3                   	ret    

008007ac <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ac:	55                   	push   %ebp
  8007ad:	89 e5                	mov    %esp,%ebp
  8007af:	53                   	push   %ebx
  8007b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b6:	89 c2                	mov    %eax,%edx
  8007b8:	83 c2 01             	add    $0x1,%edx
  8007bb:	83 c1 01             	add    $0x1,%ecx
  8007be:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007c2:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007c5:	84 db                	test   %bl,%bl
  8007c7:	75 ef                	jne    8007b8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007c9:	5b                   	pop    %ebx
  8007ca:	5d                   	pop    %ebp
  8007cb:	c3                   	ret    

008007cc <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007cc:	55                   	push   %ebp
  8007cd:	89 e5                	mov    %esp,%ebp
  8007cf:	53                   	push   %ebx
  8007d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007d3:	53                   	push   %ebx
  8007d4:	e8 9a ff ff ff       	call   800773 <strlen>
  8007d9:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007dc:	ff 75 0c             	pushl  0xc(%ebp)
  8007df:	01 d8                	add    %ebx,%eax
  8007e1:	50                   	push   %eax
  8007e2:	e8 c5 ff ff ff       	call   8007ac <strcpy>
	return dst;
}
  8007e7:	89 d8                	mov    %ebx,%eax
  8007e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ec:	c9                   	leave  
  8007ed:	c3                   	ret    

008007ee <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ee:	55                   	push   %ebp
  8007ef:	89 e5                	mov    %esp,%ebp
  8007f1:	56                   	push   %esi
  8007f2:	53                   	push   %ebx
  8007f3:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f9:	89 f3                	mov    %esi,%ebx
  8007fb:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007fe:	89 f2                	mov    %esi,%edx
  800800:	eb 0f                	jmp    800811 <strncpy+0x23>
		*dst++ = *src;
  800802:	83 c2 01             	add    $0x1,%edx
  800805:	0f b6 01             	movzbl (%ecx),%eax
  800808:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80080b:	80 39 01             	cmpb   $0x1,(%ecx)
  80080e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800811:	39 da                	cmp    %ebx,%edx
  800813:	75 ed                	jne    800802 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800815:	89 f0                	mov    %esi,%eax
  800817:	5b                   	pop    %ebx
  800818:	5e                   	pop    %esi
  800819:	5d                   	pop    %ebp
  80081a:	c3                   	ret    

0080081b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	56                   	push   %esi
  80081f:	53                   	push   %ebx
  800820:	8b 75 08             	mov    0x8(%ebp),%esi
  800823:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800826:	8b 55 10             	mov    0x10(%ebp),%edx
  800829:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80082b:	85 d2                	test   %edx,%edx
  80082d:	74 21                	je     800850 <strlcpy+0x35>
  80082f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800833:	89 f2                	mov    %esi,%edx
  800835:	eb 09                	jmp    800840 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800837:	83 c2 01             	add    $0x1,%edx
  80083a:	83 c1 01             	add    $0x1,%ecx
  80083d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800840:	39 c2                	cmp    %eax,%edx
  800842:	74 09                	je     80084d <strlcpy+0x32>
  800844:	0f b6 19             	movzbl (%ecx),%ebx
  800847:	84 db                	test   %bl,%bl
  800849:	75 ec                	jne    800837 <strlcpy+0x1c>
  80084b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80084d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800850:	29 f0                	sub    %esi,%eax
}
  800852:	5b                   	pop    %ebx
  800853:	5e                   	pop    %esi
  800854:	5d                   	pop    %ebp
  800855:	c3                   	ret    

00800856 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80085c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80085f:	eb 06                	jmp    800867 <strcmp+0x11>
		p++, q++;
  800861:	83 c1 01             	add    $0x1,%ecx
  800864:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800867:	0f b6 01             	movzbl (%ecx),%eax
  80086a:	84 c0                	test   %al,%al
  80086c:	74 04                	je     800872 <strcmp+0x1c>
  80086e:	3a 02                	cmp    (%edx),%al
  800870:	74 ef                	je     800861 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800872:	0f b6 c0             	movzbl %al,%eax
  800875:	0f b6 12             	movzbl (%edx),%edx
  800878:	29 d0                	sub    %edx,%eax
}
  80087a:	5d                   	pop    %ebp
  80087b:	c3                   	ret    

0080087c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	53                   	push   %ebx
  800880:	8b 45 08             	mov    0x8(%ebp),%eax
  800883:	8b 55 0c             	mov    0xc(%ebp),%edx
  800886:	89 c3                	mov    %eax,%ebx
  800888:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80088b:	eb 06                	jmp    800893 <strncmp+0x17>
		n--, p++, q++;
  80088d:	83 c0 01             	add    $0x1,%eax
  800890:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800893:	39 d8                	cmp    %ebx,%eax
  800895:	74 15                	je     8008ac <strncmp+0x30>
  800897:	0f b6 08             	movzbl (%eax),%ecx
  80089a:	84 c9                	test   %cl,%cl
  80089c:	74 04                	je     8008a2 <strncmp+0x26>
  80089e:	3a 0a                	cmp    (%edx),%cl
  8008a0:	74 eb                	je     80088d <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a2:	0f b6 00             	movzbl (%eax),%eax
  8008a5:	0f b6 12             	movzbl (%edx),%edx
  8008a8:	29 d0                	sub    %edx,%eax
  8008aa:	eb 05                	jmp    8008b1 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008ac:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008b1:	5b                   	pop    %ebx
  8008b2:	5d                   	pop    %ebp
  8008b3:	c3                   	ret    

008008b4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008b4:	55                   	push   %ebp
  8008b5:	89 e5                	mov    %esp,%ebp
  8008b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ba:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008be:	eb 07                	jmp    8008c7 <strchr+0x13>
		if (*s == c)
  8008c0:	38 ca                	cmp    %cl,%dl
  8008c2:	74 0f                	je     8008d3 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008c4:	83 c0 01             	add    $0x1,%eax
  8008c7:	0f b6 10             	movzbl (%eax),%edx
  8008ca:	84 d2                	test   %dl,%dl
  8008cc:	75 f2                	jne    8008c0 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008d3:	5d                   	pop    %ebp
  8008d4:	c3                   	ret    

008008d5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
  8008d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008db:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008df:	eb 03                	jmp    8008e4 <strfind+0xf>
  8008e1:	83 c0 01             	add    $0x1,%eax
  8008e4:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008e7:	38 ca                	cmp    %cl,%dl
  8008e9:	74 04                	je     8008ef <strfind+0x1a>
  8008eb:	84 d2                	test   %dl,%dl
  8008ed:	75 f2                	jne    8008e1 <strfind+0xc>
			break;
	return (char *) s;
}
  8008ef:	5d                   	pop    %ebp
  8008f0:	c3                   	ret    

008008f1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	57                   	push   %edi
  8008f5:	56                   	push   %esi
  8008f6:	53                   	push   %ebx
  8008f7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008fa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008fd:	85 c9                	test   %ecx,%ecx
  8008ff:	74 36                	je     800937 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800901:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800907:	75 28                	jne    800931 <memset+0x40>
  800909:	f6 c1 03             	test   $0x3,%cl
  80090c:	75 23                	jne    800931 <memset+0x40>
		c &= 0xFF;
  80090e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800912:	89 d3                	mov    %edx,%ebx
  800914:	c1 e3 08             	shl    $0x8,%ebx
  800917:	89 d6                	mov    %edx,%esi
  800919:	c1 e6 18             	shl    $0x18,%esi
  80091c:	89 d0                	mov    %edx,%eax
  80091e:	c1 e0 10             	shl    $0x10,%eax
  800921:	09 f0                	or     %esi,%eax
  800923:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800925:	89 d8                	mov    %ebx,%eax
  800927:	09 d0                	or     %edx,%eax
  800929:	c1 e9 02             	shr    $0x2,%ecx
  80092c:	fc                   	cld    
  80092d:	f3 ab                	rep stos %eax,%es:(%edi)
  80092f:	eb 06                	jmp    800937 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800931:	8b 45 0c             	mov    0xc(%ebp),%eax
  800934:	fc                   	cld    
  800935:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800937:	89 f8                	mov    %edi,%eax
  800939:	5b                   	pop    %ebx
  80093a:	5e                   	pop    %esi
  80093b:	5f                   	pop    %edi
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	57                   	push   %edi
  800942:	56                   	push   %esi
  800943:	8b 45 08             	mov    0x8(%ebp),%eax
  800946:	8b 75 0c             	mov    0xc(%ebp),%esi
  800949:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80094c:	39 c6                	cmp    %eax,%esi
  80094e:	73 35                	jae    800985 <memmove+0x47>
  800950:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800953:	39 d0                	cmp    %edx,%eax
  800955:	73 2e                	jae    800985 <memmove+0x47>
		s += n;
		d += n;
  800957:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80095a:	89 d6                	mov    %edx,%esi
  80095c:	09 fe                	or     %edi,%esi
  80095e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800964:	75 13                	jne    800979 <memmove+0x3b>
  800966:	f6 c1 03             	test   $0x3,%cl
  800969:	75 0e                	jne    800979 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80096b:	83 ef 04             	sub    $0x4,%edi
  80096e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800971:	c1 e9 02             	shr    $0x2,%ecx
  800974:	fd                   	std    
  800975:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800977:	eb 09                	jmp    800982 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800979:	83 ef 01             	sub    $0x1,%edi
  80097c:	8d 72 ff             	lea    -0x1(%edx),%esi
  80097f:	fd                   	std    
  800980:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800982:	fc                   	cld    
  800983:	eb 1d                	jmp    8009a2 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800985:	89 f2                	mov    %esi,%edx
  800987:	09 c2                	or     %eax,%edx
  800989:	f6 c2 03             	test   $0x3,%dl
  80098c:	75 0f                	jne    80099d <memmove+0x5f>
  80098e:	f6 c1 03             	test   $0x3,%cl
  800991:	75 0a                	jne    80099d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800993:	c1 e9 02             	shr    $0x2,%ecx
  800996:	89 c7                	mov    %eax,%edi
  800998:	fc                   	cld    
  800999:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099b:	eb 05                	jmp    8009a2 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80099d:	89 c7                	mov    %eax,%edi
  80099f:	fc                   	cld    
  8009a0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009a2:	5e                   	pop    %esi
  8009a3:	5f                   	pop    %edi
  8009a4:	5d                   	pop    %ebp
  8009a5:	c3                   	ret    

008009a6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009a9:	ff 75 10             	pushl  0x10(%ebp)
  8009ac:	ff 75 0c             	pushl  0xc(%ebp)
  8009af:	ff 75 08             	pushl  0x8(%ebp)
  8009b2:	e8 87 ff ff ff       	call   80093e <memmove>
}
  8009b7:	c9                   	leave  
  8009b8:	c3                   	ret    

008009b9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	56                   	push   %esi
  8009bd:	53                   	push   %ebx
  8009be:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c4:	89 c6                	mov    %eax,%esi
  8009c6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c9:	eb 1a                	jmp    8009e5 <memcmp+0x2c>
		if (*s1 != *s2)
  8009cb:	0f b6 08             	movzbl (%eax),%ecx
  8009ce:	0f b6 1a             	movzbl (%edx),%ebx
  8009d1:	38 d9                	cmp    %bl,%cl
  8009d3:	74 0a                	je     8009df <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009d5:	0f b6 c1             	movzbl %cl,%eax
  8009d8:	0f b6 db             	movzbl %bl,%ebx
  8009db:	29 d8                	sub    %ebx,%eax
  8009dd:	eb 0f                	jmp    8009ee <memcmp+0x35>
		s1++, s2++;
  8009df:	83 c0 01             	add    $0x1,%eax
  8009e2:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e5:	39 f0                	cmp    %esi,%eax
  8009e7:	75 e2                	jne    8009cb <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ee:	5b                   	pop    %ebx
  8009ef:	5e                   	pop    %esi
  8009f0:	5d                   	pop    %ebp
  8009f1:	c3                   	ret    

008009f2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009f2:	55                   	push   %ebp
  8009f3:	89 e5                	mov    %esp,%ebp
  8009f5:	53                   	push   %ebx
  8009f6:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009f9:	89 c1                	mov    %eax,%ecx
  8009fb:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009fe:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a02:	eb 0a                	jmp    800a0e <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a04:	0f b6 10             	movzbl (%eax),%edx
  800a07:	39 da                	cmp    %ebx,%edx
  800a09:	74 07                	je     800a12 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a0b:	83 c0 01             	add    $0x1,%eax
  800a0e:	39 c8                	cmp    %ecx,%eax
  800a10:	72 f2                	jb     800a04 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a12:	5b                   	pop    %ebx
  800a13:	5d                   	pop    %ebp
  800a14:	c3                   	ret    

00800a15 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	57                   	push   %edi
  800a19:	56                   	push   %esi
  800a1a:	53                   	push   %ebx
  800a1b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a1e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a21:	eb 03                	jmp    800a26 <strtol+0x11>
		s++;
  800a23:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a26:	0f b6 01             	movzbl (%ecx),%eax
  800a29:	3c 20                	cmp    $0x20,%al
  800a2b:	74 f6                	je     800a23 <strtol+0xe>
  800a2d:	3c 09                	cmp    $0x9,%al
  800a2f:	74 f2                	je     800a23 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a31:	3c 2b                	cmp    $0x2b,%al
  800a33:	75 0a                	jne    800a3f <strtol+0x2a>
		s++;
  800a35:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a38:	bf 00 00 00 00       	mov    $0x0,%edi
  800a3d:	eb 11                	jmp    800a50 <strtol+0x3b>
  800a3f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a44:	3c 2d                	cmp    $0x2d,%al
  800a46:	75 08                	jne    800a50 <strtol+0x3b>
		s++, neg = 1;
  800a48:	83 c1 01             	add    $0x1,%ecx
  800a4b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a50:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a56:	75 15                	jne    800a6d <strtol+0x58>
  800a58:	80 39 30             	cmpb   $0x30,(%ecx)
  800a5b:	75 10                	jne    800a6d <strtol+0x58>
  800a5d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a61:	75 7c                	jne    800adf <strtol+0xca>
		s += 2, base = 16;
  800a63:	83 c1 02             	add    $0x2,%ecx
  800a66:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a6b:	eb 16                	jmp    800a83 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a6d:	85 db                	test   %ebx,%ebx
  800a6f:	75 12                	jne    800a83 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a71:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a76:	80 39 30             	cmpb   $0x30,(%ecx)
  800a79:	75 08                	jne    800a83 <strtol+0x6e>
		s++, base = 8;
  800a7b:	83 c1 01             	add    $0x1,%ecx
  800a7e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a83:	b8 00 00 00 00       	mov    $0x0,%eax
  800a88:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a8b:	0f b6 11             	movzbl (%ecx),%edx
  800a8e:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a91:	89 f3                	mov    %esi,%ebx
  800a93:	80 fb 09             	cmp    $0x9,%bl
  800a96:	77 08                	ja     800aa0 <strtol+0x8b>
			dig = *s - '0';
  800a98:	0f be d2             	movsbl %dl,%edx
  800a9b:	83 ea 30             	sub    $0x30,%edx
  800a9e:	eb 22                	jmp    800ac2 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800aa0:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aa3:	89 f3                	mov    %esi,%ebx
  800aa5:	80 fb 19             	cmp    $0x19,%bl
  800aa8:	77 08                	ja     800ab2 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800aaa:	0f be d2             	movsbl %dl,%edx
  800aad:	83 ea 57             	sub    $0x57,%edx
  800ab0:	eb 10                	jmp    800ac2 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ab2:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ab5:	89 f3                	mov    %esi,%ebx
  800ab7:	80 fb 19             	cmp    $0x19,%bl
  800aba:	77 16                	ja     800ad2 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800abc:	0f be d2             	movsbl %dl,%edx
  800abf:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ac2:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ac5:	7d 0b                	jge    800ad2 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ac7:	83 c1 01             	add    $0x1,%ecx
  800aca:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ace:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ad0:	eb b9                	jmp    800a8b <strtol+0x76>

	if (endptr)
  800ad2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ad6:	74 0d                	je     800ae5 <strtol+0xd0>
		*endptr = (char *) s;
  800ad8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800adb:	89 0e                	mov    %ecx,(%esi)
  800add:	eb 06                	jmp    800ae5 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800adf:	85 db                	test   %ebx,%ebx
  800ae1:	74 98                	je     800a7b <strtol+0x66>
  800ae3:	eb 9e                	jmp    800a83 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ae5:	89 c2                	mov    %eax,%edx
  800ae7:	f7 da                	neg    %edx
  800ae9:	85 ff                	test   %edi,%edi
  800aeb:	0f 45 c2             	cmovne %edx,%eax
}
  800aee:	5b                   	pop    %ebx
  800aef:	5e                   	pop    %esi
  800af0:	5f                   	pop    %edi
  800af1:	5d                   	pop    %ebp
  800af2:	c3                   	ret    

00800af3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	57                   	push   %edi
  800af7:	56                   	push   %esi
  800af8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af9:	b8 00 00 00 00       	mov    $0x0,%eax
  800afe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b01:	8b 55 08             	mov    0x8(%ebp),%edx
  800b04:	89 c3                	mov    %eax,%ebx
  800b06:	89 c7                	mov    %eax,%edi
  800b08:	89 c6                	mov    %eax,%esi
  800b0a:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b0c:	5b                   	pop    %ebx
  800b0d:	5e                   	pop    %esi
  800b0e:	5f                   	pop    %edi
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    

00800b11 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	57                   	push   %edi
  800b15:	56                   	push   %esi
  800b16:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b17:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1c:	b8 01 00 00 00       	mov    $0x1,%eax
  800b21:	89 d1                	mov    %edx,%ecx
  800b23:	89 d3                	mov    %edx,%ebx
  800b25:	89 d7                	mov    %edx,%edi
  800b27:	89 d6                	mov    %edx,%esi
  800b29:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b2b:	5b                   	pop    %ebx
  800b2c:	5e                   	pop    %esi
  800b2d:	5f                   	pop    %edi
  800b2e:	5d                   	pop    %ebp
  800b2f:	c3                   	ret    

00800b30 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
  800b33:	57                   	push   %edi
  800b34:	56                   	push   %esi
  800b35:	53                   	push   %ebx
  800b36:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b39:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b3e:	b8 03 00 00 00       	mov    $0x3,%eax
  800b43:	8b 55 08             	mov    0x8(%ebp),%edx
  800b46:	89 cb                	mov    %ecx,%ebx
  800b48:	89 cf                	mov    %ecx,%edi
  800b4a:	89 ce                	mov    %ecx,%esi
  800b4c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b4e:	85 c0                	test   %eax,%eax
  800b50:	7e 17                	jle    800b69 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b52:	83 ec 0c             	sub    $0xc,%esp
  800b55:	50                   	push   %eax
  800b56:	6a 03                	push   $0x3
  800b58:	68 ff 24 80 00       	push   $0x8024ff
  800b5d:	6a 23                	push   $0x23
  800b5f:	68 1c 25 80 00       	push   $0x80251c
  800b64:	e8 7a 11 00 00       	call   801ce3 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b69:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b6c:	5b                   	pop    %ebx
  800b6d:	5e                   	pop    %esi
  800b6e:	5f                   	pop    %edi
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    

00800b71 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	57                   	push   %edi
  800b75:	56                   	push   %esi
  800b76:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b77:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7c:	b8 02 00 00 00       	mov    $0x2,%eax
  800b81:	89 d1                	mov    %edx,%ecx
  800b83:	89 d3                	mov    %edx,%ebx
  800b85:	89 d7                	mov    %edx,%edi
  800b87:	89 d6                	mov    %edx,%esi
  800b89:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b8b:	5b                   	pop    %ebx
  800b8c:	5e                   	pop    %esi
  800b8d:	5f                   	pop    %edi
  800b8e:	5d                   	pop    %ebp
  800b8f:	c3                   	ret    

00800b90 <sys_yield>:

void
sys_yield(void)
{
  800b90:	55                   	push   %ebp
  800b91:	89 e5                	mov    %esp,%ebp
  800b93:	57                   	push   %edi
  800b94:	56                   	push   %esi
  800b95:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b96:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ba0:	89 d1                	mov    %edx,%ecx
  800ba2:	89 d3                	mov    %edx,%ebx
  800ba4:	89 d7                	mov    %edx,%edi
  800ba6:	89 d6                	mov    %edx,%esi
  800ba8:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800baa:	5b                   	pop    %ebx
  800bab:	5e                   	pop    %esi
  800bac:	5f                   	pop    %edi
  800bad:	5d                   	pop    %ebp
  800bae:	c3                   	ret    

00800baf <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	57                   	push   %edi
  800bb3:	56                   	push   %esi
  800bb4:	53                   	push   %ebx
  800bb5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb8:	be 00 00 00 00       	mov    $0x0,%esi
  800bbd:	b8 04 00 00 00       	mov    $0x4,%eax
  800bc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bcb:	89 f7                	mov    %esi,%edi
  800bcd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bcf:	85 c0                	test   %eax,%eax
  800bd1:	7e 17                	jle    800bea <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd3:	83 ec 0c             	sub    $0xc,%esp
  800bd6:	50                   	push   %eax
  800bd7:	6a 04                	push   $0x4
  800bd9:	68 ff 24 80 00       	push   $0x8024ff
  800bde:	6a 23                	push   $0x23
  800be0:	68 1c 25 80 00       	push   $0x80251c
  800be5:	e8 f9 10 00 00       	call   801ce3 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bed:	5b                   	pop    %ebx
  800bee:	5e                   	pop    %esi
  800bef:	5f                   	pop    %edi
  800bf0:	5d                   	pop    %ebp
  800bf1:	c3                   	ret    

00800bf2 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bf2:	55                   	push   %ebp
  800bf3:	89 e5                	mov    %esp,%ebp
  800bf5:	57                   	push   %edi
  800bf6:	56                   	push   %esi
  800bf7:	53                   	push   %ebx
  800bf8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfb:	b8 05 00 00 00       	mov    $0x5,%eax
  800c00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c03:	8b 55 08             	mov    0x8(%ebp),%edx
  800c06:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c09:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c0c:	8b 75 18             	mov    0x18(%ebp),%esi
  800c0f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c11:	85 c0                	test   %eax,%eax
  800c13:	7e 17                	jle    800c2c <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c15:	83 ec 0c             	sub    $0xc,%esp
  800c18:	50                   	push   %eax
  800c19:	6a 05                	push   $0x5
  800c1b:	68 ff 24 80 00       	push   $0x8024ff
  800c20:	6a 23                	push   $0x23
  800c22:	68 1c 25 80 00       	push   $0x80251c
  800c27:	e8 b7 10 00 00       	call   801ce3 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2f:	5b                   	pop    %ebx
  800c30:	5e                   	pop    %esi
  800c31:	5f                   	pop    %edi
  800c32:	5d                   	pop    %ebp
  800c33:	c3                   	ret    

00800c34 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	57                   	push   %edi
  800c38:	56                   	push   %esi
  800c39:	53                   	push   %ebx
  800c3a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c42:	b8 06 00 00 00       	mov    $0x6,%eax
  800c47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4d:	89 df                	mov    %ebx,%edi
  800c4f:	89 de                	mov    %ebx,%esi
  800c51:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c53:	85 c0                	test   %eax,%eax
  800c55:	7e 17                	jle    800c6e <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c57:	83 ec 0c             	sub    $0xc,%esp
  800c5a:	50                   	push   %eax
  800c5b:	6a 06                	push   $0x6
  800c5d:	68 ff 24 80 00       	push   $0x8024ff
  800c62:	6a 23                	push   $0x23
  800c64:	68 1c 25 80 00       	push   $0x80251c
  800c69:	e8 75 10 00 00       	call   801ce3 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c71:	5b                   	pop    %ebx
  800c72:	5e                   	pop    %esi
  800c73:	5f                   	pop    %edi
  800c74:	5d                   	pop    %ebp
  800c75:	c3                   	ret    

00800c76 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c76:	55                   	push   %ebp
  800c77:	89 e5                	mov    %esp,%ebp
  800c79:	57                   	push   %edi
  800c7a:	56                   	push   %esi
  800c7b:	53                   	push   %ebx
  800c7c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c84:	b8 08 00 00 00       	mov    $0x8,%eax
  800c89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8f:	89 df                	mov    %ebx,%edi
  800c91:	89 de                	mov    %ebx,%esi
  800c93:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c95:	85 c0                	test   %eax,%eax
  800c97:	7e 17                	jle    800cb0 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c99:	83 ec 0c             	sub    $0xc,%esp
  800c9c:	50                   	push   %eax
  800c9d:	6a 08                	push   $0x8
  800c9f:	68 ff 24 80 00       	push   $0x8024ff
  800ca4:	6a 23                	push   $0x23
  800ca6:	68 1c 25 80 00       	push   $0x80251c
  800cab:	e8 33 10 00 00       	call   801ce3 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cb0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb3:	5b                   	pop    %ebx
  800cb4:	5e                   	pop    %esi
  800cb5:	5f                   	pop    %edi
  800cb6:	5d                   	pop    %ebp
  800cb7:	c3                   	ret    

00800cb8 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800cc1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc6:	b8 09 00 00 00       	mov    $0x9,%eax
  800ccb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cce:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd1:	89 df                	mov    %ebx,%edi
  800cd3:	89 de                	mov    %ebx,%esi
  800cd5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cd7:	85 c0                	test   %eax,%eax
  800cd9:	7e 17                	jle    800cf2 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdb:	83 ec 0c             	sub    $0xc,%esp
  800cde:	50                   	push   %eax
  800cdf:	6a 09                	push   $0x9
  800ce1:	68 ff 24 80 00       	push   $0x8024ff
  800ce6:	6a 23                	push   $0x23
  800ce8:	68 1c 25 80 00       	push   $0x80251c
  800ced:	e8 f1 0f 00 00       	call   801ce3 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cf2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf5:	5b                   	pop    %ebx
  800cf6:	5e                   	pop    %esi
  800cf7:	5f                   	pop    %edi
  800cf8:	5d                   	pop    %ebp
  800cf9:	c3                   	ret    

00800cfa <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cfa:	55                   	push   %ebp
  800cfb:	89 e5                	mov    %esp,%ebp
  800cfd:	57                   	push   %edi
  800cfe:	56                   	push   %esi
  800cff:	53                   	push   %ebx
  800d00:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d03:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d08:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d10:	8b 55 08             	mov    0x8(%ebp),%edx
  800d13:	89 df                	mov    %ebx,%edi
  800d15:	89 de                	mov    %ebx,%esi
  800d17:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d19:	85 c0                	test   %eax,%eax
  800d1b:	7e 17                	jle    800d34 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1d:	83 ec 0c             	sub    $0xc,%esp
  800d20:	50                   	push   %eax
  800d21:	6a 0a                	push   $0xa
  800d23:	68 ff 24 80 00       	push   $0x8024ff
  800d28:	6a 23                	push   $0x23
  800d2a:	68 1c 25 80 00       	push   $0x80251c
  800d2f:	e8 af 0f 00 00       	call   801ce3 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d37:	5b                   	pop    %ebx
  800d38:	5e                   	pop    %esi
  800d39:	5f                   	pop    %edi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	57                   	push   %edi
  800d40:	56                   	push   %esi
  800d41:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d42:	be 00 00 00 00       	mov    $0x0,%esi
  800d47:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d52:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d55:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d58:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d5a:	5b                   	pop    %ebx
  800d5b:	5e                   	pop    %esi
  800d5c:	5f                   	pop    %edi
  800d5d:	5d                   	pop    %ebp
  800d5e:	c3                   	ret    

00800d5f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d5f:	55                   	push   %ebp
  800d60:	89 e5                	mov    %esp,%ebp
  800d62:	57                   	push   %edi
  800d63:	56                   	push   %esi
  800d64:	53                   	push   %ebx
  800d65:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d68:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d6d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d72:	8b 55 08             	mov    0x8(%ebp),%edx
  800d75:	89 cb                	mov    %ecx,%ebx
  800d77:	89 cf                	mov    %ecx,%edi
  800d79:	89 ce                	mov    %ecx,%esi
  800d7b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d7d:	85 c0                	test   %eax,%eax
  800d7f:	7e 17                	jle    800d98 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d81:	83 ec 0c             	sub    $0xc,%esp
  800d84:	50                   	push   %eax
  800d85:	6a 0d                	push   $0xd
  800d87:	68 ff 24 80 00       	push   $0x8024ff
  800d8c:	6a 23                	push   $0x23
  800d8e:	68 1c 25 80 00       	push   $0x80251c
  800d93:	e8 4b 0f 00 00       	call   801ce3 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9b:	5b                   	pop    %ebx
  800d9c:	5e                   	pop    %esi
  800d9d:	5f                   	pop    %edi
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    

00800da0 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	57                   	push   %edi
  800da4:	56                   	push   %esi
  800da5:	53                   	push   %ebx
  800da6:	83 ec 0c             	sub    $0xc,%esp
  800da9:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800dac:	8b 18                	mov    (%eax),%ebx
	uint32_t err = utf->utf_err;
  800dae:	8b 78 04             	mov    0x4(%eax),%edi
	int r;
	envid_t curenvid = sys_getenvid();
  800db1:	e8 bb fd ff ff       	call   800b71 <sys_getenvid>
  800db6:	89 c6                	mov    %eax,%esi
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(err & FEC_WR) && !(uvpt[PGNUM(addr)] & PTE_COW))
  800db8:	f7 c7 02 00 00 00    	test   $0x2,%edi
  800dbe:	75 25                	jne    800de5 <pgfault+0x45>
  800dc0:	89 d8                	mov    %ebx,%eax
  800dc2:	c1 e8 0c             	shr    $0xc,%eax
  800dc5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dcc:	f6 c4 08             	test   $0x8,%ah
  800dcf:	75 14                	jne    800de5 <pgfault+0x45>
	    panic("pgfault error: wrong faulting access");
  800dd1:	83 ec 04             	sub    $0x4,%esp
  800dd4:	68 2c 25 80 00       	push   $0x80252c
  800dd9:	6a 1e                	push   $0x1e
  800ddb:	68 51 25 80 00       	push   $0x802551
  800de0:	e8 fe 0e 00 00       	call   801ce3 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	sys_page_alloc(curenvid, PFTEMP, PTE_W | PTE_U | PTE_P);
  800de5:	83 ec 04             	sub    $0x4,%esp
  800de8:	6a 07                	push   $0x7
  800dea:	68 00 f0 7f 00       	push   $0x7ff000
  800def:	56                   	push   %esi
  800df0:	e8 ba fd ff ff       	call   800baf <sys_page_alloc>

	addr = (void *)(PGNUM(addr) * PGSIZE);
  800df5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr, PGSIZE);
  800dfb:	83 c4 0c             	add    $0xc,%esp
  800dfe:	68 00 10 00 00       	push   $0x1000
  800e03:	53                   	push   %ebx
  800e04:	68 00 f0 7f 00       	push   $0x7ff000
  800e09:	e8 30 fb ff ff       	call   80093e <memmove>

	sys_page_unmap(curenvid, addr);
  800e0e:	83 c4 08             	add    $0x8,%esp
  800e11:	53                   	push   %ebx
  800e12:	56                   	push   %esi
  800e13:	e8 1c fe ff ff       	call   800c34 <sys_page_unmap>
	sys_page_map(curenvid, PFTEMP, curenvid, addr, PTE_W | PTE_U | PTE_P);
  800e18:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e1f:	53                   	push   %ebx
  800e20:	56                   	push   %esi
  800e21:	68 00 f0 7f 00       	push   $0x7ff000
  800e26:	56                   	push   %esi
  800e27:	e8 c6 fd ff ff       	call   800bf2 <sys_page_map>
	sys_page_unmap(curenvid, PFTEMP);
  800e2c:	83 c4 18             	add    $0x18,%esp
  800e2f:	68 00 f0 7f 00       	push   $0x7ff000
  800e34:	56                   	push   %esi
  800e35:	e8 fa fd ff ff       	call   800c34 <sys_page_unmap>
}
  800e3a:	83 c4 10             	add    $0x10,%esp
  800e3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e40:	5b                   	pop    %ebx
  800e41:	5e                   	pop    %esi
  800e42:	5f                   	pop    %edi
  800e43:	5d                   	pop    %ebp
  800e44:	c3                   	ret    

00800e45 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e45:	55                   	push   %ebp
  800e46:	89 e5                	mov    %esp,%ebp
  800e48:	57                   	push   %edi
  800e49:	56                   	push   %esi
  800e4a:	53                   	push   %ebx
  800e4b:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	extern void _pgfault_upcall();
	envid_t new_envid, curenv_id;

	curenv_id = sys_getenvid();
  800e4e:	e8 1e fd ff ff       	call   800b71 <sys_getenvid>
	set_pgfault_handler(pgfault);
  800e53:	83 ec 0c             	sub    $0xc,%esp
  800e56:	68 a0 0d 80 00       	push   $0x800da0
  800e5b:	e8 c9 0e 00 00       	call   801d29 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800e60:	b8 07 00 00 00       	mov    $0x7,%eax
  800e65:	cd 30                	int    $0x30
  800e67:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800e6a:	89 45 dc             	mov    %eax,-0x24(%ebp)
	new_envid = sys_exofork();

	if (new_envid < 0)
  800e6d:	83 c4 10             	add    $0x10,%esp
  800e70:	85 c0                	test   %eax,%eax
  800e72:	79 12                	jns    800e86 <fork+0x41>
	    panic("fork error: %e", new_envid);
  800e74:	50                   	push   %eax
  800e75:	68 5c 25 80 00       	push   $0x80255c
  800e7a:	6a 75                	push   $0x75
  800e7c:	68 51 25 80 00       	push   $0x802551
  800e81:	e8 5d 0e 00 00       	call   801ce3 <_panic>
  800e86:	bf 00 00 80 00       	mov    $0x800000,%edi
	else if (new_envid == 0)
  800e8b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800e8f:	75 1c                	jne    800ead <fork+0x68>
		thisenv = envs + ENVX(sys_getenvid());
  800e91:	e8 db fc ff ff       	call   800b71 <sys_getenvid>
  800e96:	25 ff 03 00 00       	and    $0x3ff,%eax
  800e9b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e9e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ea3:	a3 04 40 80 00       	mov    %eax,0x804004
  800ea8:	e9 27 01 00 00       	jmp    800fd4 <fork+0x18f>
	else {

		for (uint32_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
			if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
  800ead:	89 f8                	mov    %edi,%eax
  800eaf:	c1 e8 16             	shr    $0x16,%eax
  800eb2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800eb9:	a8 01                	test   $0x1,%al
  800ebb:	0f 84 d2 00 00 00    	je     800f93 <fork+0x14e>
  800ec1:	89 fb                	mov    %edi,%ebx
  800ec3:	c1 eb 0c             	shr    $0xc,%ebx
  800ec6:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800ecd:	a8 01                	test   $0x1,%al
  800ecf:	0f 84 be 00 00 00    	je     800f93 <fork+0x14e>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	int perm = PTE_U | PTE_P;
	envid_t curenvid = sys_getenvid();
  800ed5:	e8 97 fc ff ff       	call   800b71 <sys_getenvid>
  800eda:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  800edd:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
		perm |= PTE_COW ;
  800ee4:	be 05 08 00 00       	mov    $0x805,%esi
	int r;
	int perm = PTE_U | PTE_P;
	envid_t curenvid = sys_getenvid();

	// LAB 4: Your code here.
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  800ee9:	a8 02                	test   $0x2,%al
  800eeb:	75 1d                	jne    800f0a <fork+0xc5>
  800eed:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800ef4:	25 00 08 00 00       	and    $0x800,%eax
		perm |= PTE_COW ;
  800ef9:	83 f8 01             	cmp    $0x1,%eax
  800efc:	19 f6                	sbb    %esi,%esi
  800efe:	81 e6 00 f8 ff ff    	and    $0xfffff800,%esi
  800f04:	81 c6 05 08 00 00    	add    $0x805,%esi

	if (uvpt[pn] & PTE_SHARE)
  800f0a:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f11:	25 00 04 00 00       	and    $0x400,%eax
		perm |= PTE_SYSCALL;
  800f16:	b8 07 0e 00 00       	mov    $0xe07,%eax
  800f1b:	0f 45 f0             	cmovne %eax,%esi

	r = sys_page_map(curenvid, (void *)(pn * PGSIZE),
  800f1e:	89 d8                	mov    %ebx,%eax
  800f20:	c1 e0 0c             	shl    $0xc,%eax
  800f23:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f26:	83 ec 0c             	sub    $0xc,%esp
  800f29:	56                   	push   %esi
  800f2a:	50                   	push   %eax
  800f2b:	ff 75 dc             	pushl  -0x24(%ebp)
  800f2e:	50                   	push   %eax
  800f2f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f32:	e8 bb fc ff ff       	call   800bf2 <sys_page_map>
				envid, (void *)(pn * PGSIZE), perm);
	if (r < 0)
  800f37:	83 c4 20             	add    $0x20,%esp
  800f3a:	85 c0                	test   %eax,%eax
  800f3c:	79 12                	jns    800f50 <fork+0x10b>
		panic("duppage error: %e", r);
  800f3e:	50                   	push   %eax
  800f3f:	68 6b 25 80 00       	push   $0x80256b
  800f44:	6a 4d                	push   $0x4d
  800f46:	68 51 25 80 00       	push   $0x802551
  800f4b:	e8 93 0d 00 00       	call   801ce3 <_panic>
	
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))	{
  800f50:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f57:	a8 02                	test   $0x2,%al
  800f59:	75 0c                	jne    800f67 <fork+0x122>
  800f5b:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f62:	f6 c4 08             	test   $0x8,%ah
  800f65:	74 2c                	je     800f93 <fork+0x14e>
		r = sys_page_map(curenvid, (void *)(pn * PGSIZE),
  800f67:	83 ec 0c             	sub    $0xc,%esp
  800f6a:	56                   	push   %esi
  800f6b:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800f6e:	52                   	push   %edx
  800f6f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f72:	50                   	push   %eax
  800f73:	52                   	push   %edx
  800f74:	50                   	push   %eax
  800f75:	e8 78 fc ff ff       	call   800bf2 <sys_page_map>
						curenvid, (void *)(pn * PGSIZE), perm);
		if (r < 0)
  800f7a:	83 c4 20             	add    $0x20,%esp
  800f7d:	85 c0                	test   %eax,%eax
  800f7f:	79 12                	jns    800f93 <fork+0x14e>
			panic("duppage error: %e", r);
  800f81:	50                   	push   %eax
  800f82:	68 6b 25 80 00       	push   $0x80256b
  800f87:	6a 53                	push   $0x53
  800f89:	68 51 25 80 00       	push   $0x802551
  800f8e:	e8 50 0d 00 00       	call   801ce3 <_panic>
	    panic("fork error: %e", new_envid);
	else if (new_envid == 0)
		thisenv = envs + ENVX(sys_getenvid());
	else {

		for (uint32_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
  800f93:	81 c7 00 10 00 00    	add    $0x1000,%edi
  800f99:	81 ff 00 e0 bf ee    	cmp    $0xeebfe000,%edi
  800f9f:	0f 85 08 ff ff ff    	jne    800ead <fork+0x68>
			if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
				duppage(new_envid, PGNUM(addr));
		}

		sys_page_alloc(new_envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  800fa5:	83 ec 04             	sub    $0x4,%esp
  800fa8:	6a 07                	push   $0x7
  800faa:	68 00 f0 bf ee       	push   $0xeebff000
  800faf:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800fb2:	56                   	push   %esi
  800fb3:	e8 f7 fb ff ff       	call   800baf <sys_page_alloc>
		sys_env_set_pgfault_upcall(new_envid, _pgfault_upcall);
  800fb8:	83 c4 08             	add    $0x8,%esp
  800fbb:	68 6e 1d 80 00       	push   $0x801d6e
  800fc0:	56                   	push   %esi
  800fc1:	e8 34 fd ff ff       	call   800cfa <sys_env_set_pgfault_upcall>
		sys_env_set_status(new_envid, ENV_RUNNABLE);
  800fc6:	83 c4 08             	add    $0x8,%esp
  800fc9:	6a 02                	push   $0x2
  800fcb:	56                   	push   %esi
  800fcc:	e8 a5 fc ff ff       	call   800c76 <sys_env_set_status>
  800fd1:	83 c4 10             	add    $0x10,%esp

	}
	return new_envid;
}
  800fd4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800fd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fda:	5b                   	pop    %ebx
  800fdb:	5e                   	pop    %esi
  800fdc:	5f                   	pop    %edi
  800fdd:	5d                   	pop    %ebp
  800fde:	c3                   	ret    

00800fdf <sfork>:

// Challenge!
int
sfork(void)
{
  800fdf:	55                   	push   %ebp
  800fe0:	89 e5                	mov    %esp,%ebp
  800fe2:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800fe5:	68 7d 25 80 00       	push   $0x80257d
  800fea:	68 8b 00 00 00       	push   $0x8b
  800fef:	68 51 25 80 00       	push   $0x802551
  800ff4:	e8 ea 0c 00 00       	call   801ce3 <_panic>

00800ff9 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ff9:	55                   	push   %ebp
  800ffa:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ffc:	8b 45 08             	mov    0x8(%ebp),%eax
  800fff:	05 00 00 00 30       	add    $0x30000000,%eax
  801004:	c1 e8 0c             	shr    $0xc,%eax
}
  801007:	5d                   	pop    %ebp
  801008:	c3                   	ret    

00801009 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801009:	55                   	push   %ebp
  80100a:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80100c:	8b 45 08             	mov    0x8(%ebp),%eax
  80100f:	05 00 00 00 30       	add    $0x30000000,%eax
  801014:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801019:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80101e:	5d                   	pop    %ebp
  80101f:	c3                   	ret    

00801020 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801020:	55                   	push   %ebp
  801021:	89 e5                	mov    %esp,%ebp
  801023:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801026:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80102b:	89 c2                	mov    %eax,%edx
  80102d:	c1 ea 16             	shr    $0x16,%edx
  801030:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801037:	f6 c2 01             	test   $0x1,%dl
  80103a:	74 11                	je     80104d <fd_alloc+0x2d>
  80103c:	89 c2                	mov    %eax,%edx
  80103e:	c1 ea 0c             	shr    $0xc,%edx
  801041:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801048:	f6 c2 01             	test   $0x1,%dl
  80104b:	75 09                	jne    801056 <fd_alloc+0x36>
			*fd_store = fd;
  80104d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80104f:	b8 00 00 00 00       	mov    $0x0,%eax
  801054:	eb 17                	jmp    80106d <fd_alloc+0x4d>
  801056:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80105b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801060:	75 c9                	jne    80102b <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801062:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801068:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80106d:	5d                   	pop    %ebp
  80106e:	c3                   	ret    

0080106f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80106f:	55                   	push   %ebp
  801070:	89 e5                	mov    %esp,%ebp
  801072:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801075:	83 f8 1f             	cmp    $0x1f,%eax
  801078:	77 36                	ja     8010b0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80107a:	c1 e0 0c             	shl    $0xc,%eax
  80107d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801082:	89 c2                	mov    %eax,%edx
  801084:	c1 ea 16             	shr    $0x16,%edx
  801087:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80108e:	f6 c2 01             	test   $0x1,%dl
  801091:	74 24                	je     8010b7 <fd_lookup+0x48>
  801093:	89 c2                	mov    %eax,%edx
  801095:	c1 ea 0c             	shr    $0xc,%edx
  801098:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80109f:	f6 c2 01             	test   $0x1,%dl
  8010a2:	74 1a                	je     8010be <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010a7:	89 02                	mov    %eax,(%edx)
	return 0;
  8010a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ae:	eb 13                	jmp    8010c3 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010b0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010b5:	eb 0c                	jmp    8010c3 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010b7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010bc:	eb 05                	jmp    8010c3 <fd_lookup+0x54>
  8010be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8010c3:	5d                   	pop    %ebp
  8010c4:	c3                   	ret    

008010c5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8010c5:	55                   	push   %ebp
  8010c6:	89 e5                	mov    %esp,%ebp
  8010c8:	83 ec 08             	sub    $0x8,%esp
  8010cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010ce:	ba 10 26 80 00       	mov    $0x802610,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8010d3:	eb 13                	jmp    8010e8 <dev_lookup+0x23>
  8010d5:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8010d8:	39 08                	cmp    %ecx,(%eax)
  8010da:	75 0c                	jne    8010e8 <dev_lookup+0x23>
			*dev = devtab[i];
  8010dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010df:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8010e6:	eb 2e                	jmp    801116 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8010e8:	8b 02                	mov    (%edx),%eax
  8010ea:	85 c0                	test   %eax,%eax
  8010ec:	75 e7                	jne    8010d5 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8010ee:	a1 04 40 80 00       	mov    0x804004,%eax
  8010f3:	8b 40 48             	mov    0x48(%eax),%eax
  8010f6:	83 ec 04             	sub    $0x4,%esp
  8010f9:	51                   	push   %ecx
  8010fa:	50                   	push   %eax
  8010fb:	68 94 25 80 00       	push   $0x802594
  801100:	e8 a3 f0 ff ff       	call   8001a8 <cprintf>
	*dev = 0;
  801105:	8b 45 0c             	mov    0xc(%ebp),%eax
  801108:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80110e:	83 c4 10             	add    $0x10,%esp
  801111:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801116:	c9                   	leave  
  801117:	c3                   	ret    

00801118 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801118:	55                   	push   %ebp
  801119:	89 e5                	mov    %esp,%ebp
  80111b:	56                   	push   %esi
  80111c:	53                   	push   %ebx
  80111d:	83 ec 10             	sub    $0x10,%esp
  801120:	8b 75 08             	mov    0x8(%ebp),%esi
  801123:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801126:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801129:	50                   	push   %eax
  80112a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801130:	c1 e8 0c             	shr    $0xc,%eax
  801133:	50                   	push   %eax
  801134:	e8 36 ff ff ff       	call   80106f <fd_lookup>
  801139:	83 c4 08             	add    $0x8,%esp
  80113c:	85 c0                	test   %eax,%eax
  80113e:	78 05                	js     801145 <fd_close+0x2d>
	    || fd != fd2)
  801140:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801143:	74 0c                	je     801151 <fd_close+0x39>
		return (must_exist ? r : 0);
  801145:	84 db                	test   %bl,%bl
  801147:	ba 00 00 00 00       	mov    $0x0,%edx
  80114c:	0f 44 c2             	cmove  %edx,%eax
  80114f:	eb 41                	jmp    801192 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801151:	83 ec 08             	sub    $0x8,%esp
  801154:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801157:	50                   	push   %eax
  801158:	ff 36                	pushl  (%esi)
  80115a:	e8 66 ff ff ff       	call   8010c5 <dev_lookup>
  80115f:	89 c3                	mov    %eax,%ebx
  801161:	83 c4 10             	add    $0x10,%esp
  801164:	85 c0                	test   %eax,%eax
  801166:	78 1a                	js     801182 <fd_close+0x6a>
		if (dev->dev_close)
  801168:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80116b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80116e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801173:	85 c0                	test   %eax,%eax
  801175:	74 0b                	je     801182 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801177:	83 ec 0c             	sub    $0xc,%esp
  80117a:	56                   	push   %esi
  80117b:	ff d0                	call   *%eax
  80117d:	89 c3                	mov    %eax,%ebx
  80117f:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801182:	83 ec 08             	sub    $0x8,%esp
  801185:	56                   	push   %esi
  801186:	6a 00                	push   $0x0
  801188:	e8 a7 fa ff ff       	call   800c34 <sys_page_unmap>
	return r;
  80118d:	83 c4 10             	add    $0x10,%esp
  801190:	89 d8                	mov    %ebx,%eax
}
  801192:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801195:	5b                   	pop    %ebx
  801196:	5e                   	pop    %esi
  801197:	5d                   	pop    %ebp
  801198:	c3                   	ret    

00801199 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801199:	55                   	push   %ebp
  80119a:	89 e5                	mov    %esp,%ebp
  80119c:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80119f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011a2:	50                   	push   %eax
  8011a3:	ff 75 08             	pushl  0x8(%ebp)
  8011a6:	e8 c4 fe ff ff       	call   80106f <fd_lookup>
  8011ab:	83 c4 08             	add    $0x8,%esp
  8011ae:	85 c0                	test   %eax,%eax
  8011b0:	78 10                	js     8011c2 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8011b2:	83 ec 08             	sub    $0x8,%esp
  8011b5:	6a 01                	push   $0x1
  8011b7:	ff 75 f4             	pushl  -0xc(%ebp)
  8011ba:	e8 59 ff ff ff       	call   801118 <fd_close>
  8011bf:	83 c4 10             	add    $0x10,%esp
}
  8011c2:	c9                   	leave  
  8011c3:	c3                   	ret    

008011c4 <close_all>:

void
close_all(void)
{
  8011c4:	55                   	push   %ebp
  8011c5:	89 e5                	mov    %esp,%ebp
  8011c7:	53                   	push   %ebx
  8011c8:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8011cb:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8011d0:	83 ec 0c             	sub    $0xc,%esp
  8011d3:	53                   	push   %ebx
  8011d4:	e8 c0 ff ff ff       	call   801199 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8011d9:	83 c3 01             	add    $0x1,%ebx
  8011dc:	83 c4 10             	add    $0x10,%esp
  8011df:	83 fb 20             	cmp    $0x20,%ebx
  8011e2:	75 ec                	jne    8011d0 <close_all+0xc>
		close(i);
}
  8011e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011e7:	c9                   	leave  
  8011e8:	c3                   	ret    

008011e9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8011e9:	55                   	push   %ebp
  8011ea:	89 e5                	mov    %esp,%ebp
  8011ec:	57                   	push   %edi
  8011ed:	56                   	push   %esi
  8011ee:	53                   	push   %ebx
  8011ef:	83 ec 2c             	sub    $0x2c,%esp
  8011f2:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8011f5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8011f8:	50                   	push   %eax
  8011f9:	ff 75 08             	pushl  0x8(%ebp)
  8011fc:	e8 6e fe ff ff       	call   80106f <fd_lookup>
  801201:	83 c4 08             	add    $0x8,%esp
  801204:	85 c0                	test   %eax,%eax
  801206:	0f 88 c1 00 00 00    	js     8012cd <dup+0xe4>
		return r;
	close(newfdnum);
  80120c:	83 ec 0c             	sub    $0xc,%esp
  80120f:	56                   	push   %esi
  801210:	e8 84 ff ff ff       	call   801199 <close>

	newfd = INDEX2FD(newfdnum);
  801215:	89 f3                	mov    %esi,%ebx
  801217:	c1 e3 0c             	shl    $0xc,%ebx
  80121a:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801220:	83 c4 04             	add    $0x4,%esp
  801223:	ff 75 e4             	pushl  -0x1c(%ebp)
  801226:	e8 de fd ff ff       	call   801009 <fd2data>
  80122b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80122d:	89 1c 24             	mov    %ebx,(%esp)
  801230:	e8 d4 fd ff ff       	call   801009 <fd2data>
  801235:	83 c4 10             	add    $0x10,%esp
  801238:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80123b:	89 f8                	mov    %edi,%eax
  80123d:	c1 e8 16             	shr    $0x16,%eax
  801240:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801247:	a8 01                	test   $0x1,%al
  801249:	74 37                	je     801282 <dup+0x99>
  80124b:	89 f8                	mov    %edi,%eax
  80124d:	c1 e8 0c             	shr    $0xc,%eax
  801250:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801257:	f6 c2 01             	test   $0x1,%dl
  80125a:	74 26                	je     801282 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80125c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801263:	83 ec 0c             	sub    $0xc,%esp
  801266:	25 07 0e 00 00       	and    $0xe07,%eax
  80126b:	50                   	push   %eax
  80126c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80126f:	6a 00                	push   $0x0
  801271:	57                   	push   %edi
  801272:	6a 00                	push   $0x0
  801274:	e8 79 f9 ff ff       	call   800bf2 <sys_page_map>
  801279:	89 c7                	mov    %eax,%edi
  80127b:	83 c4 20             	add    $0x20,%esp
  80127e:	85 c0                	test   %eax,%eax
  801280:	78 2e                	js     8012b0 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801282:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801285:	89 d0                	mov    %edx,%eax
  801287:	c1 e8 0c             	shr    $0xc,%eax
  80128a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801291:	83 ec 0c             	sub    $0xc,%esp
  801294:	25 07 0e 00 00       	and    $0xe07,%eax
  801299:	50                   	push   %eax
  80129a:	53                   	push   %ebx
  80129b:	6a 00                	push   $0x0
  80129d:	52                   	push   %edx
  80129e:	6a 00                	push   $0x0
  8012a0:	e8 4d f9 ff ff       	call   800bf2 <sys_page_map>
  8012a5:	89 c7                	mov    %eax,%edi
  8012a7:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8012aa:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012ac:	85 ff                	test   %edi,%edi
  8012ae:	79 1d                	jns    8012cd <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8012b0:	83 ec 08             	sub    $0x8,%esp
  8012b3:	53                   	push   %ebx
  8012b4:	6a 00                	push   $0x0
  8012b6:	e8 79 f9 ff ff       	call   800c34 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8012bb:	83 c4 08             	add    $0x8,%esp
  8012be:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012c1:	6a 00                	push   $0x0
  8012c3:	e8 6c f9 ff ff       	call   800c34 <sys_page_unmap>
	return r;
  8012c8:	83 c4 10             	add    $0x10,%esp
  8012cb:	89 f8                	mov    %edi,%eax
}
  8012cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012d0:	5b                   	pop    %ebx
  8012d1:	5e                   	pop    %esi
  8012d2:	5f                   	pop    %edi
  8012d3:	5d                   	pop    %ebp
  8012d4:	c3                   	ret    

008012d5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8012d5:	55                   	push   %ebp
  8012d6:	89 e5                	mov    %esp,%ebp
  8012d8:	53                   	push   %ebx
  8012d9:	83 ec 14             	sub    $0x14,%esp
  8012dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012df:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012e2:	50                   	push   %eax
  8012e3:	53                   	push   %ebx
  8012e4:	e8 86 fd ff ff       	call   80106f <fd_lookup>
  8012e9:	83 c4 08             	add    $0x8,%esp
  8012ec:	89 c2                	mov    %eax,%edx
  8012ee:	85 c0                	test   %eax,%eax
  8012f0:	78 6d                	js     80135f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012f2:	83 ec 08             	sub    $0x8,%esp
  8012f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f8:	50                   	push   %eax
  8012f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012fc:	ff 30                	pushl  (%eax)
  8012fe:	e8 c2 fd ff ff       	call   8010c5 <dev_lookup>
  801303:	83 c4 10             	add    $0x10,%esp
  801306:	85 c0                	test   %eax,%eax
  801308:	78 4c                	js     801356 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80130a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80130d:	8b 42 08             	mov    0x8(%edx),%eax
  801310:	83 e0 03             	and    $0x3,%eax
  801313:	83 f8 01             	cmp    $0x1,%eax
  801316:	75 21                	jne    801339 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801318:	a1 04 40 80 00       	mov    0x804004,%eax
  80131d:	8b 40 48             	mov    0x48(%eax),%eax
  801320:	83 ec 04             	sub    $0x4,%esp
  801323:	53                   	push   %ebx
  801324:	50                   	push   %eax
  801325:	68 d5 25 80 00       	push   $0x8025d5
  80132a:	e8 79 ee ff ff       	call   8001a8 <cprintf>
		return -E_INVAL;
  80132f:	83 c4 10             	add    $0x10,%esp
  801332:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801337:	eb 26                	jmp    80135f <read+0x8a>
	}
	if (!dev->dev_read)
  801339:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80133c:	8b 40 08             	mov    0x8(%eax),%eax
  80133f:	85 c0                	test   %eax,%eax
  801341:	74 17                	je     80135a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801343:	83 ec 04             	sub    $0x4,%esp
  801346:	ff 75 10             	pushl  0x10(%ebp)
  801349:	ff 75 0c             	pushl  0xc(%ebp)
  80134c:	52                   	push   %edx
  80134d:	ff d0                	call   *%eax
  80134f:	89 c2                	mov    %eax,%edx
  801351:	83 c4 10             	add    $0x10,%esp
  801354:	eb 09                	jmp    80135f <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801356:	89 c2                	mov    %eax,%edx
  801358:	eb 05                	jmp    80135f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80135a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80135f:	89 d0                	mov    %edx,%eax
  801361:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801364:	c9                   	leave  
  801365:	c3                   	ret    

00801366 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801366:	55                   	push   %ebp
  801367:	89 e5                	mov    %esp,%ebp
  801369:	57                   	push   %edi
  80136a:	56                   	push   %esi
  80136b:	53                   	push   %ebx
  80136c:	83 ec 0c             	sub    $0xc,%esp
  80136f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801372:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801375:	bb 00 00 00 00       	mov    $0x0,%ebx
  80137a:	eb 21                	jmp    80139d <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80137c:	83 ec 04             	sub    $0x4,%esp
  80137f:	89 f0                	mov    %esi,%eax
  801381:	29 d8                	sub    %ebx,%eax
  801383:	50                   	push   %eax
  801384:	89 d8                	mov    %ebx,%eax
  801386:	03 45 0c             	add    0xc(%ebp),%eax
  801389:	50                   	push   %eax
  80138a:	57                   	push   %edi
  80138b:	e8 45 ff ff ff       	call   8012d5 <read>
		if (m < 0)
  801390:	83 c4 10             	add    $0x10,%esp
  801393:	85 c0                	test   %eax,%eax
  801395:	78 10                	js     8013a7 <readn+0x41>
			return m;
		if (m == 0)
  801397:	85 c0                	test   %eax,%eax
  801399:	74 0a                	je     8013a5 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80139b:	01 c3                	add    %eax,%ebx
  80139d:	39 f3                	cmp    %esi,%ebx
  80139f:	72 db                	jb     80137c <readn+0x16>
  8013a1:	89 d8                	mov    %ebx,%eax
  8013a3:	eb 02                	jmp    8013a7 <readn+0x41>
  8013a5:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8013a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013aa:	5b                   	pop    %ebx
  8013ab:	5e                   	pop    %esi
  8013ac:	5f                   	pop    %edi
  8013ad:	5d                   	pop    %ebp
  8013ae:	c3                   	ret    

008013af <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8013af:	55                   	push   %ebp
  8013b0:	89 e5                	mov    %esp,%ebp
  8013b2:	53                   	push   %ebx
  8013b3:	83 ec 14             	sub    $0x14,%esp
  8013b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013b9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013bc:	50                   	push   %eax
  8013bd:	53                   	push   %ebx
  8013be:	e8 ac fc ff ff       	call   80106f <fd_lookup>
  8013c3:	83 c4 08             	add    $0x8,%esp
  8013c6:	89 c2                	mov    %eax,%edx
  8013c8:	85 c0                	test   %eax,%eax
  8013ca:	78 68                	js     801434 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013cc:	83 ec 08             	sub    $0x8,%esp
  8013cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013d2:	50                   	push   %eax
  8013d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d6:	ff 30                	pushl  (%eax)
  8013d8:	e8 e8 fc ff ff       	call   8010c5 <dev_lookup>
  8013dd:	83 c4 10             	add    $0x10,%esp
  8013e0:	85 c0                	test   %eax,%eax
  8013e2:	78 47                	js     80142b <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013e7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013eb:	75 21                	jne    80140e <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8013ed:	a1 04 40 80 00       	mov    0x804004,%eax
  8013f2:	8b 40 48             	mov    0x48(%eax),%eax
  8013f5:	83 ec 04             	sub    $0x4,%esp
  8013f8:	53                   	push   %ebx
  8013f9:	50                   	push   %eax
  8013fa:	68 f1 25 80 00       	push   $0x8025f1
  8013ff:	e8 a4 ed ff ff       	call   8001a8 <cprintf>
		return -E_INVAL;
  801404:	83 c4 10             	add    $0x10,%esp
  801407:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80140c:	eb 26                	jmp    801434 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80140e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801411:	8b 52 0c             	mov    0xc(%edx),%edx
  801414:	85 d2                	test   %edx,%edx
  801416:	74 17                	je     80142f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801418:	83 ec 04             	sub    $0x4,%esp
  80141b:	ff 75 10             	pushl  0x10(%ebp)
  80141e:	ff 75 0c             	pushl  0xc(%ebp)
  801421:	50                   	push   %eax
  801422:	ff d2                	call   *%edx
  801424:	89 c2                	mov    %eax,%edx
  801426:	83 c4 10             	add    $0x10,%esp
  801429:	eb 09                	jmp    801434 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80142b:	89 c2                	mov    %eax,%edx
  80142d:	eb 05                	jmp    801434 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80142f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801434:	89 d0                	mov    %edx,%eax
  801436:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801439:	c9                   	leave  
  80143a:	c3                   	ret    

0080143b <seek>:

int
seek(int fdnum, off_t offset)
{
  80143b:	55                   	push   %ebp
  80143c:	89 e5                	mov    %esp,%ebp
  80143e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801441:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801444:	50                   	push   %eax
  801445:	ff 75 08             	pushl  0x8(%ebp)
  801448:	e8 22 fc ff ff       	call   80106f <fd_lookup>
  80144d:	83 c4 08             	add    $0x8,%esp
  801450:	85 c0                	test   %eax,%eax
  801452:	78 0e                	js     801462 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801454:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801457:	8b 55 0c             	mov    0xc(%ebp),%edx
  80145a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80145d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801462:	c9                   	leave  
  801463:	c3                   	ret    

00801464 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801464:	55                   	push   %ebp
  801465:	89 e5                	mov    %esp,%ebp
  801467:	53                   	push   %ebx
  801468:	83 ec 14             	sub    $0x14,%esp
  80146b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80146e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801471:	50                   	push   %eax
  801472:	53                   	push   %ebx
  801473:	e8 f7 fb ff ff       	call   80106f <fd_lookup>
  801478:	83 c4 08             	add    $0x8,%esp
  80147b:	89 c2                	mov    %eax,%edx
  80147d:	85 c0                	test   %eax,%eax
  80147f:	78 65                	js     8014e6 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801481:	83 ec 08             	sub    $0x8,%esp
  801484:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801487:	50                   	push   %eax
  801488:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80148b:	ff 30                	pushl  (%eax)
  80148d:	e8 33 fc ff ff       	call   8010c5 <dev_lookup>
  801492:	83 c4 10             	add    $0x10,%esp
  801495:	85 c0                	test   %eax,%eax
  801497:	78 44                	js     8014dd <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801499:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80149c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014a0:	75 21                	jne    8014c3 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8014a2:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014a7:	8b 40 48             	mov    0x48(%eax),%eax
  8014aa:	83 ec 04             	sub    $0x4,%esp
  8014ad:	53                   	push   %ebx
  8014ae:	50                   	push   %eax
  8014af:	68 b4 25 80 00       	push   $0x8025b4
  8014b4:	e8 ef ec ff ff       	call   8001a8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8014b9:	83 c4 10             	add    $0x10,%esp
  8014bc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014c1:	eb 23                	jmp    8014e6 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8014c3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014c6:	8b 52 18             	mov    0x18(%edx),%edx
  8014c9:	85 d2                	test   %edx,%edx
  8014cb:	74 14                	je     8014e1 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8014cd:	83 ec 08             	sub    $0x8,%esp
  8014d0:	ff 75 0c             	pushl  0xc(%ebp)
  8014d3:	50                   	push   %eax
  8014d4:	ff d2                	call   *%edx
  8014d6:	89 c2                	mov    %eax,%edx
  8014d8:	83 c4 10             	add    $0x10,%esp
  8014db:	eb 09                	jmp    8014e6 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014dd:	89 c2                	mov    %eax,%edx
  8014df:	eb 05                	jmp    8014e6 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8014e1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8014e6:	89 d0                	mov    %edx,%eax
  8014e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014eb:	c9                   	leave  
  8014ec:	c3                   	ret    

008014ed <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8014ed:	55                   	push   %ebp
  8014ee:	89 e5                	mov    %esp,%ebp
  8014f0:	53                   	push   %ebx
  8014f1:	83 ec 14             	sub    $0x14,%esp
  8014f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014f7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014fa:	50                   	push   %eax
  8014fb:	ff 75 08             	pushl  0x8(%ebp)
  8014fe:	e8 6c fb ff ff       	call   80106f <fd_lookup>
  801503:	83 c4 08             	add    $0x8,%esp
  801506:	89 c2                	mov    %eax,%edx
  801508:	85 c0                	test   %eax,%eax
  80150a:	78 58                	js     801564 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80150c:	83 ec 08             	sub    $0x8,%esp
  80150f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801512:	50                   	push   %eax
  801513:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801516:	ff 30                	pushl  (%eax)
  801518:	e8 a8 fb ff ff       	call   8010c5 <dev_lookup>
  80151d:	83 c4 10             	add    $0x10,%esp
  801520:	85 c0                	test   %eax,%eax
  801522:	78 37                	js     80155b <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801524:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801527:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80152b:	74 32                	je     80155f <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80152d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801530:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801537:	00 00 00 
	stat->st_isdir = 0;
  80153a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801541:	00 00 00 
	stat->st_dev = dev;
  801544:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80154a:	83 ec 08             	sub    $0x8,%esp
  80154d:	53                   	push   %ebx
  80154e:	ff 75 f0             	pushl  -0x10(%ebp)
  801551:	ff 50 14             	call   *0x14(%eax)
  801554:	89 c2                	mov    %eax,%edx
  801556:	83 c4 10             	add    $0x10,%esp
  801559:	eb 09                	jmp    801564 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80155b:	89 c2                	mov    %eax,%edx
  80155d:	eb 05                	jmp    801564 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80155f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801564:	89 d0                	mov    %edx,%eax
  801566:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801569:	c9                   	leave  
  80156a:	c3                   	ret    

0080156b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80156b:	55                   	push   %ebp
  80156c:	89 e5                	mov    %esp,%ebp
  80156e:	56                   	push   %esi
  80156f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801570:	83 ec 08             	sub    $0x8,%esp
  801573:	6a 00                	push   $0x0
  801575:	ff 75 08             	pushl  0x8(%ebp)
  801578:	e8 e3 01 00 00       	call   801760 <open>
  80157d:	89 c3                	mov    %eax,%ebx
  80157f:	83 c4 10             	add    $0x10,%esp
  801582:	85 c0                	test   %eax,%eax
  801584:	78 1b                	js     8015a1 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801586:	83 ec 08             	sub    $0x8,%esp
  801589:	ff 75 0c             	pushl  0xc(%ebp)
  80158c:	50                   	push   %eax
  80158d:	e8 5b ff ff ff       	call   8014ed <fstat>
  801592:	89 c6                	mov    %eax,%esi
	close(fd);
  801594:	89 1c 24             	mov    %ebx,(%esp)
  801597:	e8 fd fb ff ff       	call   801199 <close>
	return r;
  80159c:	83 c4 10             	add    $0x10,%esp
  80159f:	89 f0                	mov    %esi,%eax
}
  8015a1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015a4:	5b                   	pop    %ebx
  8015a5:	5e                   	pop    %esi
  8015a6:	5d                   	pop    %ebp
  8015a7:	c3                   	ret    

008015a8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015a8:	55                   	push   %ebp
  8015a9:	89 e5                	mov    %esp,%ebp
  8015ab:	56                   	push   %esi
  8015ac:	53                   	push   %ebx
  8015ad:	89 c6                	mov    %eax,%esi
  8015af:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8015b1:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8015b8:	75 12                	jne    8015cc <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8015ba:	83 ec 0c             	sub    $0xc,%esp
  8015bd:	6a 01                	push   $0x1
  8015bf:	e8 96 08 00 00       	call   801e5a <ipc_find_env>
  8015c4:	a3 00 40 80 00       	mov    %eax,0x804000
  8015c9:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8015cc:	6a 07                	push   $0x7
  8015ce:	68 00 50 80 00       	push   $0x805000
  8015d3:	56                   	push   %esi
  8015d4:	ff 35 00 40 80 00    	pushl  0x804000
  8015da:	e8 27 08 00 00       	call   801e06 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8015df:	83 c4 0c             	add    $0xc,%esp
  8015e2:	6a 00                	push   $0x0
  8015e4:	53                   	push   %ebx
  8015e5:	6a 00                	push   $0x0
  8015e7:	e8 a8 07 00 00       	call   801d94 <ipc_recv>
}
  8015ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015ef:	5b                   	pop    %ebx
  8015f0:	5e                   	pop    %esi
  8015f1:	5d                   	pop    %ebp
  8015f2:	c3                   	ret    

008015f3 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8015f3:	55                   	push   %ebp
  8015f4:	89 e5                	mov    %esp,%ebp
  8015f6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8015f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8015fc:	8b 40 0c             	mov    0xc(%eax),%eax
  8015ff:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801604:	8b 45 0c             	mov    0xc(%ebp),%eax
  801607:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80160c:	ba 00 00 00 00       	mov    $0x0,%edx
  801611:	b8 02 00 00 00       	mov    $0x2,%eax
  801616:	e8 8d ff ff ff       	call   8015a8 <fsipc>
}
  80161b:	c9                   	leave  
  80161c:	c3                   	ret    

0080161d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80161d:	55                   	push   %ebp
  80161e:	89 e5                	mov    %esp,%ebp
  801620:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801623:	8b 45 08             	mov    0x8(%ebp),%eax
  801626:	8b 40 0c             	mov    0xc(%eax),%eax
  801629:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80162e:	ba 00 00 00 00       	mov    $0x0,%edx
  801633:	b8 06 00 00 00       	mov    $0x6,%eax
  801638:	e8 6b ff ff ff       	call   8015a8 <fsipc>
}
  80163d:	c9                   	leave  
  80163e:	c3                   	ret    

0080163f <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80163f:	55                   	push   %ebp
  801640:	89 e5                	mov    %esp,%ebp
  801642:	53                   	push   %ebx
  801643:	83 ec 04             	sub    $0x4,%esp
  801646:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801649:	8b 45 08             	mov    0x8(%ebp),%eax
  80164c:	8b 40 0c             	mov    0xc(%eax),%eax
  80164f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801654:	ba 00 00 00 00       	mov    $0x0,%edx
  801659:	b8 05 00 00 00       	mov    $0x5,%eax
  80165e:	e8 45 ff ff ff       	call   8015a8 <fsipc>
  801663:	85 c0                	test   %eax,%eax
  801665:	78 2c                	js     801693 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801667:	83 ec 08             	sub    $0x8,%esp
  80166a:	68 00 50 80 00       	push   $0x805000
  80166f:	53                   	push   %ebx
  801670:	e8 37 f1 ff ff       	call   8007ac <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801675:	a1 80 50 80 00       	mov    0x805080,%eax
  80167a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801680:	a1 84 50 80 00       	mov    0x805084,%eax
  801685:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80168b:	83 c4 10             	add    $0x10,%esp
  80168e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801693:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801696:	c9                   	leave  
  801697:	c3                   	ret    

00801698 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801698:	55                   	push   %ebp
  801699:	89 e5                	mov    %esp,%ebp
  80169b:	83 ec 0c             	sub    $0xc,%esp
  80169e:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	
	int r;

	n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8016a1:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8016a6:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8016ab:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8016ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8016b1:	8b 52 0c             	mov    0xc(%edx),%edx
  8016b4:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8016ba:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8016bf:	50                   	push   %eax
  8016c0:	ff 75 0c             	pushl  0xc(%ebp)
  8016c3:	68 08 50 80 00       	push   $0x805008
  8016c8:	e8 71 f2 ff ff       	call   80093e <memmove>
	
	return fsipc(FSREQ_WRITE, NULL);	
  8016cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d2:	b8 04 00 00 00       	mov    $0x4,%eax
  8016d7:	e8 cc fe ff ff       	call   8015a8 <fsipc>
}
  8016dc:	c9                   	leave  
  8016dd:	c3                   	ret    

008016de <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8016de:	55                   	push   %ebp
  8016df:	89 e5                	mov    %esp,%ebp
  8016e1:	56                   	push   %esi
  8016e2:	53                   	push   %ebx
  8016e3:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8016e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e9:	8b 40 0c             	mov    0xc(%eax),%eax
  8016ec:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8016f1:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8016f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8016fc:	b8 03 00 00 00       	mov    $0x3,%eax
  801701:	e8 a2 fe ff ff       	call   8015a8 <fsipc>
  801706:	89 c3                	mov    %eax,%ebx
  801708:	85 c0                	test   %eax,%eax
  80170a:	78 4b                	js     801757 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80170c:	39 c6                	cmp    %eax,%esi
  80170e:	73 16                	jae    801726 <devfile_read+0x48>
  801710:	68 20 26 80 00       	push   $0x802620
  801715:	68 27 26 80 00       	push   $0x802627
  80171a:	6a 7c                	push   $0x7c
  80171c:	68 3c 26 80 00       	push   $0x80263c
  801721:	e8 bd 05 00 00       	call   801ce3 <_panic>
	assert(r <= PGSIZE);
  801726:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80172b:	7e 16                	jle    801743 <devfile_read+0x65>
  80172d:	68 47 26 80 00       	push   $0x802647
  801732:	68 27 26 80 00       	push   $0x802627
  801737:	6a 7d                	push   $0x7d
  801739:	68 3c 26 80 00       	push   $0x80263c
  80173e:	e8 a0 05 00 00       	call   801ce3 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801743:	83 ec 04             	sub    $0x4,%esp
  801746:	50                   	push   %eax
  801747:	68 00 50 80 00       	push   $0x805000
  80174c:	ff 75 0c             	pushl  0xc(%ebp)
  80174f:	e8 ea f1 ff ff       	call   80093e <memmove>
	return r;
  801754:	83 c4 10             	add    $0x10,%esp
}
  801757:	89 d8                	mov    %ebx,%eax
  801759:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80175c:	5b                   	pop    %ebx
  80175d:	5e                   	pop    %esi
  80175e:	5d                   	pop    %ebp
  80175f:	c3                   	ret    

00801760 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801760:	55                   	push   %ebp
  801761:	89 e5                	mov    %esp,%ebp
  801763:	53                   	push   %ebx
  801764:	83 ec 20             	sub    $0x20,%esp
  801767:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80176a:	53                   	push   %ebx
  80176b:	e8 03 f0 ff ff       	call   800773 <strlen>
  801770:	83 c4 10             	add    $0x10,%esp
  801773:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801778:	7f 67                	jg     8017e1 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80177a:	83 ec 0c             	sub    $0xc,%esp
  80177d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801780:	50                   	push   %eax
  801781:	e8 9a f8 ff ff       	call   801020 <fd_alloc>
  801786:	83 c4 10             	add    $0x10,%esp
		return r;
  801789:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80178b:	85 c0                	test   %eax,%eax
  80178d:	78 57                	js     8017e6 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80178f:	83 ec 08             	sub    $0x8,%esp
  801792:	53                   	push   %ebx
  801793:	68 00 50 80 00       	push   $0x805000
  801798:	e8 0f f0 ff ff       	call   8007ac <strcpy>
	fsipcbuf.open.req_omode = mode;
  80179d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017a0:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017a8:	b8 01 00 00 00       	mov    $0x1,%eax
  8017ad:	e8 f6 fd ff ff       	call   8015a8 <fsipc>
  8017b2:	89 c3                	mov    %eax,%ebx
  8017b4:	83 c4 10             	add    $0x10,%esp
  8017b7:	85 c0                	test   %eax,%eax
  8017b9:	79 14                	jns    8017cf <open+0x6f>
		fd_close(fd, 0);
  8017bb:	83 ec 08             	sub    $0x8,%esp
  8017be:	6a 00                	push   $0x0
  8017c0:	ff 75 f4             	pushl  -0xc(%ebp)
  8017c3:	e8 50 f9 ff ff       	call   801118 <fd_close>
		return r;
  8017c8:	83 c4 10             	add    $0x10,%esp
  8017cb:	89 da                	mov    %ebx,%edx
  8017cd:	eb 17                	jmp    8017e6 <open+0x86>
	}

	return fd2num(fd);
  8017cf:	83 ec 0c             	sub    $0xc,%esp
  8017d2:	ff 75 f4             	pushl  -0xc(%ebp)
  8017d5:	e8 1f f8 ff ff       	call   800ff9 <fd2num>
  8017da:	89 c2                	mov    %eax,%edx
  8017dc:	83 c4 10             	add    $0x10,%esp
  8017df:	eb 05                	jmp    8017e6 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8017e1:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8017e6:	89 d0                	mov    %edx,%eax
  8017e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017eb:	c9                   	leave  
  8017ec:	c3                   	ret    

008017ed <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8017ed:	55                   	push   %ebp
  8017ee:	89 e5                	mov    %esp,%ebp
  8017f0:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8017f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f8:	b8 08 00 00 00       	mov    $0x8,%eax
  8017fd:	e8 a6 fd ff ff       	call   8015a8 <fsipc>
}
  801802:	c9                   	leave  
  801803:	c3                   	ret    

00801804 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801804:	55                   	push   %ebp
  801805:	89 e5                	mov    %esp,%ebp
  801807:	56                   	push   %esi
  801808:	53                   	push   %ebx
  801809:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80180c:	83 ec 0c             	sub    $0xc,%esp
  80180f:	ff 75 08             	pushl  0x8(%ebp)
  801812:	e8 f2 f7 ff ff       	call   801009 <fd2data>
  801817:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801819:	83 c4 08             	add    $0x8,%esp
  80181c:	68 53 26 80 00       	push   $0x802653
  801821:	53                   	push   %ebx
  801822:	e8 85 ef ff ff       	call   8007ac <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801827:	8b 46 04             	mov    0x4(%esi),%eax
  80182a:	2b 06                	sub    (%esi),%eax
  80182c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801832:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801839:	00 00 00 
	stat->st_dev = &devpipe;
  80183c:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801843:	30 80 00 
	return 0;
}
  801846:	b8 00 00 00 00       	mov    $0x0,%eax
  80184b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80184e:	5b                   	pop    %ebx
  80184f:	5e                   	pop    %esi
  801850:	5d                   	pop    %ebp
  801851:	c3                   	ret    

00801852 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801852:	55                   	push   %ebp
  801853:	89 e5                	mov    %esp,%ebp
  801855:	53                   	push   %ebx
  801856:	83 ec 0c             	sub    $0xc,%esp
  801859:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80185c:	53                   	push   %ebx
  80185d:	6a 00                	push   $0x0
  80185f:	e8 d0 f3 ff ff       	call   800c34 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801864:	89 1c 24             	mov    %ebx,(%esp)
  801867:	e8 9d f7 ff ff       	call   801009 <fd2data>
  80186c:	83 c4 08             	add    $0x8,%esp
  80186f:	50                   	push   %eax
  801870:	6a 00                	push   $0x0
  801872:	e8 bd f3 ff ff       	call   800c34 <sys_page_unmap>
}
  801877:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80187a:	c9                   	leave  
  80187b:	c3                   	ret    

0080187c <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80187c:	55                   	push   %ebp
  80187d:	89 e5                	mov    %esp,%ebp
  80187f:	57                   	push   %edi
  801880:	56                   	push   %esi
  801881:	53                   	push   %ebx
  801882:	83 ec 1c             	sub    $0x1c,%esp
  801885:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801888:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80188a:	a1 04 40 80 00       	mov    0x804004,%eax
  80188f:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801892:	83 ec 0c             	sub    $0xc,%esp
  801895:	ff 75 e0             	pushl  -0x20(%ebp)
  801898:	e8 f6 05 00 00       	call   801e93 <pageref>
  80189d:	89 c3                	mov    %eax,%ebx
  80189f:	89 3c 24             	mov    %edi,(%esp)
  8018a2:	e8 ec 05 00 00       	call   801e93 <pageref>
  8018a7:	83 c4 10             	add    $0x10,%esp
  8018aa:	39 c3                	cmp    %eax,%ebx
  8018ac:	0f 94 c1             	sete   %cl
  8018af:	0f b6 c9             	movzbl %cl,%ecx
  8018b2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8018b5:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8018bb:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8018be:	39 ce                	cmp    %ecx,%esi
  8018c0:	74 1b                	je     8018dd <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8018c2:	39 c3                	cmp    %eax,%ebx
  8018c4:	75 c4                	jne    80188a <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8018c6:	8b 42 58             	mov    0x58(%edx),%eax
  8018c9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8018cc:	50                   	push   %eax
  8018cd:	56                   	push   %esi
  8018ce:	68 5a 26 80 00       	push   $0x80265a
  8018d3:	e8 d0 e8 ff ff       	call   8001a8 <cprintf>
  8018d8:	83 c4 10             	add    $0x10,%esp
  8018db:	eb ad                	jmp    80188a <_pipeisclosed+0xe>
	}
}
  8018dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018e3:	5b                   	pop    %ebx
  8018e4:	5e                   	pop    %esi
  8018e5:	5f                   	pop    %edi
  8018e6:	5d                   	pop    %ebp
  8018e7:	c3                   	ret    

008018e8 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018e8:	55                   	push   %ebp
  8018e9:	89 e5                	mov    %esp,%ebp
  8018eb:	57                   	push   %edi
  8018ec:	56                   	push   %esi
  8018ed:	53                   	push   %ebx
  8018ee:	83 ec 28             	sub    $0x28,%esp
  8018f1:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8018f4:	56                   	push   %esi
  8018f5:	e8 0f f7 ff ff       	call   801009 <fd2data>
  8018fa:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018fc:	83 c4 10             	add    $0x10,%esp
  8018ff:	bf 00 00 00 00       	mov    $0x0,%edi
  801904:	eb 4b                	jmp    801951 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801906:	89 da                	mov    %ebx,%edx
  801908:	89 f0                	mov    %esi,%eax
  80190a:	e8 6d ff ff ff       	call   80187c <_pipeisclosed>
  80190f:	85 c0                	test   %eax,%eax
  801911:	75 48                	jne    80195b <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801913:	e8 78 f2 ff ff       	call   800b90 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801918:	8b 43 04             	mov    0x4(%ebx),%eax
  80191b:	8b 0b                	mov    (%ebx),%ecx
  80191d:	8d 51 20             	lea    0x20(%ecx),%edx
  801920:	39 d0                	cmp    %edx,%eax
  801922:	73 e2                	jae    801906 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801924:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801927:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80192b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80192e:	89 c2                	mov    %eax,%edx
  801930:	c1 fa 1f             	sar    $0x1f,%edx
  801933:	89 d1                	mov    %edx,%ecx
  801935:	c1 e9 1b             	shr    $0x1b,%ecx
  801938:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80193b:	83 e2 1f             	and    $0x1f,%edx
  80193e:	29 ca                	sub    %ecx,%edx
  801940:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801944:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801948:	83 c0 01             	add    $0x1,%eax
  80194b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80194e:	83 c7 01             	add    $0x1,%edi
  801951:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801954:	75 c2                	jne    801918 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801956:	8b 45 10             	mov    0x10(%ebp),%eax
  801959:	eb 05                	jmp    801960 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80195b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801960:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801963:	5b                   	pop    %ebx
  801964:	5e                   	pop    %esi
  801965:	5f                   	pop    %edi
  801966:	5d                   	pop    %ebp
  801967:	c3                   	ret    

00801968 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801968:	55                   	push   %ebp
  801969:	89 e5                	mov    %esp,%ebp
  80196b:	57                   	push   %edi
  80196c:	56                   	push   %esi
  80196d:	53                   	push   %ebx
  80196e:	83 ec 18             	sub    $0x18,%esp
  801971:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801974:	57                   	push   %edi
  801975:	e8 8f f6 ff ff       	call   801009 <fd2data>
  80197a:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80197c:	83 c4 10             	add    $0x10,%esp
  80197f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801984:	eb 3d                	jmp    8019c3 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801986:	85 db                	test   %ebx,%ebx
  801988:	74 04                	je     80198e <devpipe_read+0x26>
				return i;
  80198a:	89 d8                	mov    %ebx,%eax
  80198c:	eb 44                	jmp    8019d2 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80198e:	89 f2                	mov    %esi,%edx
  801990:	89 f8                	mov    %edi,%eax
  801992:	e8 e5 fe ff ff       	call   80187c <_pipeisclosed>
  801997:	85 c0                	test   %eax,%eax
  801999:	75 32                	jne    8019cd <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80199b:	e8 f0 f1 ff ff       	call   800b90 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8019a0:	8b 06                	mov    (%esi),%eax
  8019a2:	3b 46 04             	cmp    0x4(%esi),%eax
  8019a5:	74 df                	je     801986 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8019a7:	99                   	cltd   
  8019a8:	c1 ea 1b             	shr    $0x1b,%edx
  8019ab:	01 d0                	add    %edx,%eax
  8019ad:	83 e0 1f             	and    $0x1f,%eax
  8019b0:	29 d0                	sub    %edx,%eax
  8019b2:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8019b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019ba:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8019bd:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019c0:	83 c3 01             	add    $0x1,%ebx
  8019c3:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8019c6:	75 d8                	jne    8019a0 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8019c8:	8b 45 10             	mov    0x10(%ebp),%eax
  8019cb:	eb 05                	jmp    8019d2 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019cd:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8019d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019d5:	5b                   	pop    %ebx
  8019d6:	5e                   	pop    %esi
  8019d7:	5f                   	pop    %edi
  8019d8:	5d                   	pop    %ebp
  8019d9:	c3                   	ret    

008019da <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8019da:	55                   	push   %ebp
  8019db:	89 e5                	mov    %esp,%ebp
  8019dd:	56                   	push   %esi
  8019de:	53                   	push   %ebx
  8019df:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8019e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019e5:	50                   	push   %eax
  8019e6:	e8 35 f6 ff ff       	call   801020 <fd_alloc>
  8019eb:	83 c4 10             	add    $0x10,%esp
  8019ee:	89 c2                	mov    %eax,%edx
  8019f0:	85 c0                	test   %eax,%eax
  8019f2:	0f 88 2c 01 00 00    	js     801b24 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019f8:	83 ec 04             	sub    $0x4,%esp
  8019fb:	68 07 04 00 00       	push   $0x407
  801a00:	ff 75 f4             	pushl  -0xc(%ebp)
  801a03:	6a 00                	push   $0x0
  801a05:	e8 a5 f1 ff ff       	call   800baf <sys_page_alloc>
  801a0a:	83 c4 10             	add    $0x10,%esp
  801a0d:	89 c2                	mov    %eax,%edx
  801a0f:	85 c0                	test   %eax,%eax
  801a11:	0f 88 0d 01 00 00    	js     801b24 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a17:	83 ec 0c             	sub    $0xc,%esp
  801a1a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a1d:	50                   	push   %eax
  801a1e:	e8 fd f5 ff ff       	call   801020 <fd_alloc>
  801a23:	89 c3                	mov    %eax,%ebx
  801a25:	83 c4 10             	add    $0x10,%esp
  801a28:	85 c0                	test   %eax,%eax
  801a2a:	0f 88 e2 00 00 00    	js     801b12 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a30:	83 ec 04             	sub    $0x4,%esp
  801a33:	68 07 04 00 00       	push   $0x407
  801a38:	ff 75 f0             	pushl  -0x10(%ebp)
  801a3b:	6a 00                	push   $0x0
  801a3d:	e8 6d f1 ff ff       	call   800baf <sys_page_alloc>
  801a42:	89 c3                	mov    %eax,%ebx
  801a44:	83 c4 10             	add    $0x10,%esp
  801a47:	85 c0                	test   %eax,%eax
  801a49:	0f 88 c3 00 00 00    	js     801b12 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801a4f:	83 ec 0c             	sub    $0xc,%esp
  801a52:	ff 75 f4             	pushl  -0xc(%ebp)
  801a55:	e8 af f5 ff ff       	call   801009 <fd2data>
  801a5a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a5c:	83 c4 0c             	add    $0xc,%esp
  801a5f:	68 07 04 00 00       	push   $0x407
  801a64:	50                   	push   %eax
  801a65:	6a 00                	push   $0x0
  801a67:	e8 43 f1 ff ff       	call   800baf <sys_page_alloc>
  801a6c:	89 c3                	mov    %eax,%ebx
  801a6e:	83 c4 10             	add    $0x10,%esp
  801a71:	85 c0                	test   %eax,%eax
  801a73:	0f 88 89 00 00 00    	js     801b02 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a79:	83 ec 0c             	sub    $0xc,%esp
  801a7c:	ff 75 f0             	pushl  -0x10(%ebp)
  801a7f:	e8 85 f5 ff ff       	call   801009 <fd2data>
  801a84:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801a8b:	50                   	push   %eax
  801a8c:	6a 00                	push   $0x0
  801a8e:	56                   	push   %esi
  801a8f:	6a 00                	push   $0x0
  801a91:	e8 5c f1 ff ff       	call   800bf2 <sys_page_map>
  801a96:	89 c3                	mov    %eax,%ebx
  801a98:	83 c4 20             	add    $0x20,%esp
  801a9b:	85 c0                	test   %eax,%eax
  801a9d:	78 55                	js     801af4 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801a9f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801aa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aa8:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801aaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aad:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ab4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801aba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801abd:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801abf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ac2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ac9:	83 ec 0c             	sub    $0xc,%esp
  801acc:	ff 75 f4             	pushl  -0xc(%ebp)
  801acf:	e8 25 f5 ff ff       	call   800ff9 <fd2num>
  801ad4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ad7:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ad9:	83 c4 04             	add    $0x4,%esp
  801adc:	ff 75 f0             	pushl  -0x10(%ebp)
  801adf:	e8 15 f5 ff ff       	call   800ff9 <fd2num>
  801ae4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ae7:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801aea:	83 c4 10             	add    $0x10,%esp
  801aed:	ba 00 00 00 00       	mov    $0x0,%edx
  801af2:	eb 30                	jmp    801b24 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801af4:	83 ec 08             	sub    $0x8,%esp
  801af7:	56                   	push   %esi
  801af8:	6a 00                	push   $0x0
  801afa:	e8 35 f1 ff ff       	call   800c34 <sys_page_unmap>
  801aff:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b02:	83 ec 08             	sub    $0x8,%esp
  801b05:	ff 75 f0             	pushl  -0x10(%ebp)
  801b08:	6a 00                	push   $0x0
  801b0a:	e8 25 f1 ff ff       	call   800c34 <sys_page_unmap>
  801b0f:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b12:	83 ec 08             	sub    $0x8,%esp
  801b15:	ff 75 f4             	pushl  -0xc(%ebp)
  801b18:	6a 00                	push   $0x0
  801b1a:	e8 15 f1 ff ff       	call   800c34 <sys_page_unmap>
  801b1f:	83 c4 10             	add    $0x10,%esp
  801b22:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801b24:	89 d0                	mov    %edx,%eax
  801b26:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b29:	5b                   	pop    %ebx
  801b2a:	5e                   	pop    %esi
  801b2b:	5d                   	pop    %ebp
  801b2c:	c3                   	ret    

00801b2d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b2d:	55                   	push   %ebp
  801b2e:	89 e5                	mov    %esp,%ebp
  801b30:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b33:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b36:	50                   	push   %eax
  801b37:	ff 75 08             	pushl  0x8(%ebp)
  801b3a:	e8 30 f5 ff ff       	call   80106f <fd_lookup>
  801b3f:	83 c4 10             	add    $0x10,%esp
  801b42:	85 c0                	test   %eax,%eax
  801b44:	78 18                	js     801b5e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b46:	83 ec 0c             	sub    $0xc,%esp
  801b49:	ff 75 f4             	pushl  -0xc(%ebp)
  801b4c:	e8 b8 f4 ff ff       	call   801009 <fd2data>
	return _pipeisclosed(fd, p);
  801b51:	89 c2                	mov    %eax,%edx
  801b53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b56:	e8 21 fd ff ff       	call   80187c <_pipeisclosed>
  801b5b:	83 c4 10             	add    $0x10,%esp
}
  801b5e:	c9                   	leave  
  801b5f:	c3                   	ret    

00801b60 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b60:	55                   	push   %ebp
  801b61:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801b63:	b8 00 00 00 00       	mov    $0x0,%eax
  801b68:	5d                   	pop    %ebp
  801b69:	c3                   	ret    

00801b6a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b6a:	55                   	push   %ebp
  801b6b:	89 e5                	mov    %esp,%ebp
  801b6d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801b70:	68 72 26 80 00       	push   $0x802672
  801b75:	ff 75 0c             	pushl  0xc(%ebp)
  801b78:	e8 2f ec ff ff       	call   8007ac <strcpy>
	return 0;
}
  801b7d:	b8 00 00 00 00       	mov    $0x0,%eax
  801b82:	c9                   	leave  
  801b83:	c3                   	ret    

00801b84 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b84:	55                   	push   %ebp
  801b85:	89 e5                	mov    %esp,%ebp
  801b87:	57                   	push   %edi
  801b88:	56                   	push   %esi
  801b89:	53                   	push   %ebx
  801b8a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b90:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801b95:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801b9b:	eb 2d                	jmp    801bca <devcons_write+0x46>
		m = n - tot;
  801b9d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ba0:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801ba2:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ba5:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801baa:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bad:	83 ec 04             	sub    $0x4,%esp
  801bb0:	53                   	push   %ebx
  801bb1:	03 45 0c             	add    0xc(%ebp),%eax
  801bb4:	50                   	push   %eax
  801bb5:	57                   	push   %edi
  801bb6:	e8 83 ed ff ff       	call   80093e <memmove>
		sys_cputs(buf, m);
  801bbb:	83 c4 08             	add    $0x8,%esp
  801bbe:	53                   	push   %ebx
  801bbf:	57                   	push   %edi
  801bc0:	e8 2e ef ff ff       	call   800af3 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bc5:	01 de                	add    %ebx,%esi
  801bc7:	83 c4 10             	add    $0x10,%esp
  801bca:	89 f0                	mov    %esi,%eax
  801bcc:	3b 75 10             	cmp    0x10(%ebp),%esi
  801bcf:	72 cc                	jb     801b9d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801bd1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bd4:	5b                   	pop    %ebx
  801bd5:	5e                   	pop    %esi
  801bd6:	5f                   	pop    %edi
  801bd7:	5d                   	pop    %ebp
  801bd8:	c3                   	ret    

00801bd9 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bd9:	55                   	push   %ebp
  801bda:	89 e5                	mov    %esp,%ebp
  801bdc:	83 ec 08             	sub    $0x8,%esp
  801bdf:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801be4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801be8:	74 2a                	je     801c14 <devcons_read+0x3b>
  801bea:	eb 05                	jmp    801bf1 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801bec:	e8 9f ef ff ff       	call   800b90 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801bf1:	e8 1b ef ff ff       	call   800b11 <sys_cgetc>
  801bf6:	85 c0                	test   %eax,%eax
  801bf8:	74 f2                	je     801bec <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801bfa:	85 c0                	test   %eax,%eax
  801bfc:	78 16                	js     801c14 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801bfe:	83 f8 04             	cmp    $0x4,%eax
  801c01:	74 0c                	je     801c0f <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801c03:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c06:	88 02                	mov    %al,(%edx)
	return 1;
  801c08:	b8 01 00 00 00       	mov    $0x1,%eax
  801c0d:	eb 05                	jmp    801c14 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c0f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c14:	c9                   	leave  
  801c15:	c3                   	ret    

00801c16 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c16:	55                   	push   %ebp
  801c17:	89 e5                	mov    %esp,%ebp
  801c19:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c22:	6a 01                	push   $0x1
  801c24:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c27:	50                   	push   %eax
  801c28:	e8 c6 ee ff ff       	call   800af3 <sys_cputs>
}
  801c2d:	83 c4 10             	add    $0x10,%esp
  801c30:	c9                   	leave  
  801c31:	c3                   	ret    

00801c32 <getchar>:

int
getchar(void)
{
  801c32:	55                   	push   %ebp
  801c33:	89 e5                	mov    %esp,%ebp
  801c35:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c38:	6a 01                	push   $0x1
  801c3a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c3d:	50                   	push   %eax
  801c3e:	6a 00                	push   $0x0
  801c40:	e8 90 f6 ff ff       	call   8012d5 <read>
	if (r < 0)
  801c45:	83 c4 10             	add    $0x10,%esp
  801c48:	85 c0                	test   %eax,%eax
  801c4a:	78 0f                	js     801c5b <getchar+0x29>
		return r;
	if (r < 1)
  801c4c:	85 c0                	test   %eax,%eax
  801c4e:	7e 06                	jle    801c56 <getchar+0x24>
		return -E_EOF;
	return c;
  801c50:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801c54:	eb 05                	jmp    801c5b <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801c56:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801c5b:	c9                   	leave  
  801c5c:	c3                   	ret    

00801c5d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801c5d:	55                   	push   %ebp
  801c5e:	89 e5                	mov    %esp,%ebp
  801c60:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c63:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c66:	50                   	push   %eax
  801c67:	ff 75 08             	pushl  0x8(%ebp)
  801c6a:	e8 00 f4 ff ff       	call   80106f <fd_lookup>
  801c6f:	83 c4 10             	add    $0x10,%esp
  801c72:	85 c0                	test   %eax,%eax
  801c74:	78 11                	js     801c87 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801c76:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c79:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c7f:	39 10                	cmp    %edx,(%eax)
  801c81:	0f 94 c0             	sete   %al
  801c84:	0f b6 c0             	movzbl %al,%eax
}
  801c87:	c9                   	leave  
  801c88:	c3                   	ret    

00801c89 <opencons>:

int
opencons(void)
{
  801c89:	55                   	push   %ebp
  801c8a:	89 e5                	mov    %esp,%ebp
  801c8c:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c92:	50                   	push   %eax
  801c93:	e8 88 f3 ff ff       	call   801020 <fd_alloc>
  801c98:	83 c4 10             	add    $0x10,%esp
		return r;
  801c9b:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801c9d:	85 c0                	test   %eax,%eax
  801c9f:	78 3e                	js     801cdf <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ca1:	83 ec 04             	sub    $0x4,%esp
  801ca4:	68 07 04 00 00       	push   $0x407
  801ca9:	ff 75 f4             	pushl  -0xc(%ebp)
  801cac:	6a 00                	push   $0x0
  801cae:	e8 fc ee ff ff       	call   800baf <sys_page_alloc>
  801cb3:	83 c4 10             	add    $0x10,%esp
		return r;
  801cb6:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801cb8:	85 c0                	test   %eax,%eax
  801cba:	78 23                	js     801cdf <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801cbc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc5:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801cc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cca:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801cd1:	83 ec 0c             	sub    $0xc,%esp
  801cd4:	50                   	push   %eax
  801cd5:	e8 1f f3 ff ff       	call   800ff9 <fd2num>
  801cda:	89 c2                	mov    %eax,%edx
  801cdc:	83 c4 10             	add    $0x10,%esp
}
  801cdf:	89 d0                	mov    %edx,%eax
  801ce1:	c9                   	leave  
  801ce2:	c3                   	ret    

00801ce3 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ce3:	55                   	push   %ebp
  801ce4:	89 e5                	mov    %esp,%ebp
  801ce6:	56                   	push   %esi
  801ce7:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801ce8:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ceb:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801cf1:	e8 7b ee ff ff       	call   800b71 <sys_getenvid>
  801cf6:	83 ec 0c             	sub    $0xc,%esp
  801cf9:	ff 75 0c             	pushl  0xc(%ebp)
  801cfc:	ff 75 08             	pushl  0x8(%ebp)
  801cff:	56                   	push   %esi
  801d00:	50                   	push   %eax
  801d01:	68 80 26 80 00       	push   $0x802680
  801d06:	e8 9d e4 ff ff       	call   8001a8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d0b:	83 c4 18             	add    $0x18,%esp
  801d0e:	53                   	push   %ebx
  801d0f:	ff 75 10             	pushl  0x10(%ebp)
  801d12:	e8 40 e4 ff ff       	call   800157 <vcprintf>
	cprintf("\n");
  801d17:	c7 04 24 f4 21 80 00 	movl   $0x8021f4,(%esp)
  801d1e:	e8 85 e4 ff ff       	call   8001a8 <cprintf>
  801d23:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d26:	cc                   	int3   
  801d27:	eb fd                	jmp    801d26 <_panic+0x43>

00801d29 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d29:	55                   	push   %ebp
  801d2a:	89 e5                	mov    %esp,%ebp
  801d2c:	53                   	push   %ebx
  801d2d:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d30:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d37:	75 28                	jne    801d61 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		void *va = (void *) (UXSTACKTOP - PGSIZE);
		envid_t envid = sys_getenvid();
  801d39:	e8 33 ee ff ff       	call   800b71 <sys_getenvid>
  801d3e:	89 c3                	mov    %eax,%ebx

		sys_page_alloc(envid, va, PTE_P | PTE_U | PTE_W);
  801d40:	83 ec 04             	sub    $0x4,%esp
  801d43:	6a 07                	push   $0x7
  801d45:	68 00 f0 bf ee       	push   $0xeebff000
  801d4a:	50                   	push   %eax
  801d4b:	e8 5f ee ff ff       	call   800baf <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801d50:	83 c4 08             	add    $0x8,%esp
  801d53:	68 6e 1d 80 00       	push   $0x801d6e
  801d58:	53                   	push   %ebx
  801d59:	e8 9c ef ff ff       	call   800cfa <sys_env_set_pgfault_upcall>
  801d5e:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801d61:	8b 45 08             	mov    0x8(%ebp),%eax
  801d64:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801d69:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d6c:	c9                   	leave  
  801d6d:	c3                   	ret    

00801d6e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp				// function argument: pointer to UTF
  801d6e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801d6f:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801d74:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801d76:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp, %ebx		// 40 = size between utf_fault_va ~ utf_regs
  801d79:	89 e3                	mov    %esp,%ebx
	movl 40(%esp), %eax // point to utf_eip
  801d7b:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %esp // point to utf_esp
  801d7f:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax 			// push eip of utf
  801d83:	50                   	push   %eax

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx, %esp 	// back to origin exception stack
  801d84:	89 dc                	mov    %ebx,%esp
	subl $4, 48(%esp) 	// utf_esp - 4
  801d86:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	popl %eax  			// pop utf_fault_va (ignore)
  801d8b:	58                   	pop    %eax
	popl %eax  			// pop utf_err (ignore)
  801d8c:	58                   	pop    %eax
	popal 				// pop utf_regs 
  801d8d:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4, %esp 		// ignore utf_eip
  801d8e:	83 c4 04             	add    $0x4,%esp
	popfl 				// restore utf_eflags to eflags
  801d91:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp  			// restore %esp = utf_esp
  801d92:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801d93:	c3                   	ret    

00801d94 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801d94:	55                   	push   %ebp
  801d95:	89 e5                	mov    %esp,%ebp
  801d97:	56                   	push   %esi
  801d98:	53                   	push   %ebx
  801d99:	8b 75 08             	mov    0x8(%ebp),%esi
  801d9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

    if (pg != NULL)
  801da2:	85 c0                	test   %eax,%eax
  801da4:	74 0e                	je     801db4 <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  801da6:	83 ec 0c             	sub    $0xc,%esp
  801da9:	50                   	push   %eax
  801daa:	e8 b0 ef ff ff       	call   800d5f <sys_ipc_recv>
  801daf:	83 c4 10             	add    $0x10,%esp
  801db2:	eb 0d                	jmp    801dc1 <ipc_recv+0x2d>
	else
        r = sys_ipc_recv((void *)-1);
  801db4:	83 ec 0c             	sub    $0xc,%esp
  801db7:	6a ff                	push   $0xffffffff
  801db9:	e8 a1 ef ff ff       	call   800d5f <sys_ipc_recv>
  801dbe:	83 c4 10             	add    $0x10,%esp

	if (r < 0) {
  801dc1:	85 c0                	test   %eax,%eax
  801dc3:	79 16                	jns    801ddb <ipc_recv+0x47>

		if (from_env_store != NULL)
  801dc5:	85 f6                	test   %esi,%esi
  801dc7:	74 06                	je     801dcf <ipc_recv+0x3b>
			*from_env_store = 0;
  801dc9:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL)
  801dcf:	85 db                	test   %ebx,%ebx
  801dd1:	74 2c                	je     801dff <ipc_recv+0x6b>
			*perm_store = 0;
  801dd3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801dd9:	eb 24                	jmp    801dff <ipc_recv+0x6b>
		return r;

	} else {

		if (from_env_store != NULL)
  801ddb:	85 f6                	test   %esi,%esi
  801ddd:	74 0a                	je     801de9 <ipc_recv+0x55>
			*from_env_store = thisenv->env_ipc_from;
  801ddf:	a1 04 40 80 00       	mov    0x804004,%eax
  801de4:	8b 40 74             	mov    0x74(%eax),%eax
  801de7:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL)
  801de9:	85 db                	test   %ebx,%ebx
  801deb:	74 0a                	je     801df7 <ipc_recv+0x63>
			*perm_store = thisenv->env_ipc_perm;
  801ded:	a1 04 40 80 00       	mov    0x804004,%eax
  801df2:	8b 40 78             	mov    0x78(%eax),%eax
  801df5:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801df7:	a1 04 40 80 00       	mov    0x804004,%eax
  801dfc:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801dff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e02:	5b                   	pop    %ebx
  801e03:	5e                   	pop    %esi
  801e04:	5d                   	pop    %ebp
  801e05:	c3                   	ret    

00801e06 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e06:	55                   	push   %ebp
  801e07:	89 e5                	mov    %esp,%ebp
  801e09:	57                   	push   %edi
  801e0a:	56                   	push   %esi
  801e0b:	53                   	push   %ebx
  801e0c:	83 ec 0c             	sub    $0xc,%esp
  801e0f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e12:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e15:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

	if (pg == NULL)
  801e18:	85 db                	test   %ebx,%ebx
		pg = (void *)-1;	
  801e1a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801e1f:	0f 44 d8             	cmove  %eax,%ebx

	while (true) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801e22:	ff 75 14             	pushl  0x14(%ebp)
  801e25:	53                   	push   %ebx
  801e26:	56                   	push   %esi
  801e27:	57                   	push   %edi
  801e28:	e8 0f ef ff ff       	call   800d3c <sys_ipc_try_send>
		if (r >= 0)
  801e2d:	83 c4 10             	add    $0x10,%esp
  801e30:	85 c0                	test   %eax,%eax
  801e32:	79 1e                	jns    801e52 <ipc_send+0x4c>
			return;
		else if (r != -E_IPC_NOT_RECV)
  801e34:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e37:	74 12                	je     801e4b <ipc_send+0x45>
			panic("ipc_send error: %e", r);
  801e39:	50                   	push   %eax
  801e3a:	68 a4 26 80 00       	push   $0x8026a4
  801e3f:	6a 49                	push   $0x49
  801e41:	68 b7 26 80 00       	push   $0x8026b7
  801e46:	e8 98 fe ff ff       	call   801ce3 <_panic>
	
		sys_yield();
  801e4b:	e8 40 ed ff ff       	call   800b90 <sys_yield>
	}
  801e50:	eb d0                	jmp    801e22 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  801e52:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e55:	5b                   	pop    %ebx
  801e56:	5e                   	pop    %esi
  801e57:	5f                   	pop    %edi
  801e58:	5d                   	pop    %ebp
  801e59:	c3                   	ret    

00801e5a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801e5a:	55                   	push   %ebp
  801e5b:	89 e5                	mov    %esp,%ebp
  801e5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801e60:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801e65:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801e68:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801e6e:	8b 52 50             	mov    0x50(%edx),%edx
  801e71:	39 ca                	cmp    %ecx,%edx
  801e73:	75 0d                	jne    801e82 <ipc_find_env+0x28>
			return envs[i].env_id;
  801e75:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801e78:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801e7d:	8b 40 48             	mov    0x48(%eax),%eax
  801e80:	eb 0f                	jmp    801e91 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801e82:	83 c0 01             	add    $0x1,%eax
  801e85:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e8a:	75 d9                	jne    801e65 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801e8c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e91:	5d                   	pop    %ebp
  801e92:	c3                   	ret    

00801e93 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e93:	55                   	push   %ebp
  801e94:	89 e5                	mov    %esp,%ebp
  801e96:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e99:	89 d0                	mov    %edx,%eax
  801e9b:	c1 e8 16             	shr    $0x16,%eax
  801e9e:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ea5:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801eaa:	f6 c1 01             	test   $0x1,%cl
  801ead:	74 1d                	je     801ecc <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801eaf:	c1 ea 0c             	shr    $0xc,%edx
  801eb2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801eb9:	f6 c2 01             	test   $0x1,%dl
  801ebc:	74 0e                	je     801ecc <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ebe:	c1 ea 0c             	shr    $0xc,%edx
  801ec1:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801ec8:	ef 
  801ec9:	0f b7 c0             	movzwl %ax,%eax
}
  801ecc:	5d                   	pop    %ebp
  801ecd:	c3                   	ret    
  801ece:	66 90                	xchg   %ax,%ax

00801ed0 <__udivdi3>:
  801ed0:	55                   	push   %ebp
  801ed1:	57                   	push   %edi
  801ed2:	56                   	push   %esi
  801ed3:	53                   	push   %ebx
  801ed4:	83 ec 1c             	sub    $0x1c,%esp
  801ed7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801edb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801edf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801ee3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ee7:	85 f6                	test   %esi,%esi
  801ee9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801eed:	89 ca                	mov    %ecx,%edx
  801eef:	89 f8                	mov    %edi,%eax
  801ef1:	75 3d                	jne    801f30 <__udivdi3+0x60>
  801ef3:	39 cf                	cmp    %ecx,%edi
  801ef5:	0f 87 c5 00 00 00    	ja     801fc0 <__udivdi3+0xf0>
  801efb:	85 ff                	test   %edi,%edi
  801efd:	89 fd                	mov    %edi,%ebp
  801eff:	75 0b                	jne    801f0c <__udivdi3+0x3c>
  801f01:	b8 01 00 00 00       	mov    $0x1,%eax
  801f06:	31 d2                	xor    %edx,%edx
  801f08:	f7 f7                	div    %edi
  801f0a:	89 c5                	mov    %eax,%ebp
  801f0c:	89 c8                	mov    %ecx,%eax
  801f0e:	31 d2                	xor    %edx,%edx
  801f10:	f7 f5                	div    %ebp
  801f12:	89 c1                	mov    %eax,%ecx
  801f14:	89 d8                	mov    %ebx,%eax
  801f16:	89 cf                	mov    %ecx,%edi
  801f18:	f7 f5                	div    %ebp
  801f1a:	89 c3                	mov    %eax,%ebx
  801f1c:	89 d8                	mov    %ebx,%eax
  801f1e:	89 fa                	mov    %edi,%edx
  801f20:	83 c4 1c             	add    $0x1c,%esp
  801f23:	5b                   	pop    %ebx
  801f24:	5e                   	pop    %esi
  801f25:	5f                   	pop    %edi
  801f26:	5d                   	pop    %ebp
  801f27:	c3                   	ret    
  801f28:	90                   	nop
  801f29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f30:	39 ce                	cmp    %ecx,%esi
  801f32:	77 74                	ja     801fa8 <__udivdi3+0xd8>
  801f34:	0f bd fe             	bsr    %esi,%edi
  801f37:	83 f7 1f             	xor    $0x1f,%edi
  801f3a:	0f 84 98 00 00 00    	je     801fd8 <__udivdi3+0x108>
  801f40:	bb 20 00 00 00       	mov    $0x20,%ebx
  801f45:	89 f9                	mov    %edi,%ecx
  801f47:	89 c5                	mov    %eax,%ebp
  801f49:	29 fb                	sub    %edi,%ebx
  801f4b:	d3 e6                	shl    %cl,%esi
  801f4d:	89 d9                	mov    %ebx,%ecx
  801f4f:	d3 ed                	shr    %cl,%ebp
  801f51:	89 f9                	mov    %edi,%ecx
  801f53:	d3 e0                	shl    %cl,%eax
  801f55:	09 ee                	or     %ebp,%esi
  801f57:	89 d9                	mov    %ebx,%ecx
  801f59:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f5d:	89 d5                	mov    %edx,%ebp
  801f5f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f63:	d3 ed                	shr    %cl,%ebp
  801f65:	89 f9                	mov    %edi,%ecx
  801f67:	d3 e2                	shl    %cl,%edx
  801f69:	89 d9                	mov    %ebx,%ecx
  801f6b:	d3 e8                	shr    %cl,%eax
  801f6d:	09 c2                	or     %eax,%edx
  801f6f:	89 d0                	mov    %edx,%eax
  801f71:	89 ea                	mov    %ebp,%edx
  801f73:	f7 f6                	div    %esi
  801f75:	89 d5                	mov    %edx,%ebp
  801f77:	89 c3                	mov    %eax,%ebx
  801f79:	f7 64 24 0c          	mull   0xc(%esp)
  801f7d:	39 d5                	cmp    %edx,%ebp
  801f7f:	72 10                	jb     801f91 <__udivdi3+0xc1>
  801f81:	8b 74 24 08          	mov    0x8(%esp),%esi
  801f85:	89 f9                	mov    %edi,%ecx
  801f87:	d3 e6                	shl    %cl,%esi
  801f89:	39 c6                	cmp    %eax,%esi
  801f8b:	73 07                	jae    801f94 <__udivdi3+0xc4>
  801f8d:	39 d5                	cmp    %edx,%ebp
  801f8f:	75 03                	jne    801f94 <__udivdi3+0xc4>
  801f91:	83 eb 01             	sub    $0x1,%ebx
  801f94:	31 ff                	xor    %edi,%edi
  801f96:	89 d8                	mov    %ebx,%eax
  801f98:	89 fa                	mov    %edi,%edx
  801f9a:	83 c4 1c             	add    $0x1c,%esp
  801f9d:	5b                   	pop    %ebx
  801f9e:	5e                   	pop    %esi
  801f9f:	5f                   	pop    %edi
  801fa0:	5d                   	pop    %ebp
  801fa1:	c3                   	ret    
  801fa2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801fa8:	31 ff                	xor    %edi,%edi
  801faa:	31 db                	xor    %ebx,%ebx
  801fac:	89 d8                	mov    %ebx,%eax
  801fae:	89 fa                	mov    %edi,%edx
  801fb0:	83 c4 1c             	add    $0x1c,%esp
  801fb3:	5b                   	pop    %ebx
  801fb4:	5e                   	pop    %esi
  801fb5:	5f                   	pop    %edi
  801fb6:	5d                   	pop    %ebp
  801fb7:	c3                   	ret    
  801fb8:	90                   	nop
  801fb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fc0:	89 d8                	mov    %ebx,%eax
  801fc2:	f7 f7                	div    %edi
  801fc4:	31 ff                	xor    %edi,%edi
  801fc6:	89 c3                	mov    %eax,%ebx
  801fc8:	89 d8                	mov    %ebx,%eax
  801fca:	89 fa                	mov    %edi,%edx
  801fcc:	83 c4 1c             	add    $0x1c,%esp
  801fcf:	5b                   	pop    %ebx
  801fd0:	5e                   	pop    %esi
  801fd1:	5f                   	pop    %edi
  801fd2:	5d                   	pop    %ebp
  801fd3:	c3                   	ret    
  801fd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fd8:	39 ce                	cmp    %ecx,%esi
  801fda:	72 0c                	jb     801fe8 <__udivdi3+0x118>
  801fdc:	31 db                	xor    %ebx,%ebx
  801fde:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801fe2:	0f 87 34 ff ff ff    	ja     801f1c <__udivdi3+0x4c>
  801fe8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801fed:	e9 2a ff ff ff       	jmp    801f1c <__udivdi3+0x4c>
  801ff2:	66 90                	xchg   %ax,%ax
  801ff4:	66 90                	xchg   %ax,%ax
  801ff6:	66 90                	xchg   %ax,%ax
  801ff8:	66 90                	xchg   %ax,%ax
  801ffa:	66 90                	xchg   %ax,%ax
  801ffc:	66 90                	xchg   %ax,%ax
  801ffe:	66 90                	xchg   %ax,%ax

00802000 <__umoddi3>:
  802000:	55                   	push   %ebp
  802001:	57                   	push   %edi
  802002:	56                   	push   %esi
  802003:	53                   	push   %ebx
  802004:	83 ec 1c             	sub    $0x1c,%esp
  802007:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80200b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80200f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802013:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802017:	85 d2                	test   %edx,%edx
  802019:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80201d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802021:	89 f3                	mov    %esi,%ebx
  802023:	89 3c 24             	mov    %edi,(%esp)
  802026:	89 74 24 04          	mov    %esi,0x4(%esp)
  80202a:	75 1c                	jne    802048 <__umoddi3+0x48>
  80202c:	39 f7                	cmp    %esi,%edi
  80202e:	76 50                	jbe    802080 <__umoddi3+0x80>
  802030:	89 c8                	mov    %ecx,%eax
  802032:	89 f2                	mov    %esi,%edx
  802034:	f7 f7                	div    %edi
  802036:	89 d0                	mov    %edx,%eax
  802038:	31 d2                	xor    %edx,%edx
  80203a:	83 c4 1c             	add    $0x1c,%esp
  80203d:	5b                   	pop    %ebx
  80203e:	5e                   	pop    %esi
  80203f:	5f                   	pop    %edi
  802040:	5d                   	pop    %ebp
  802041:	c3                   	ret    
  802042:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802048:	39 f2                	cmp    %esi,%edx
  80204a:	89 d0                	mov    %edx,%eax
  80204c:	77 52                	ja     8020a0 <__umoddi3+0xa0>
  80204e:	0f bd ea             	bsr    %edx,%ebp
  802051:	83 f5 1f             	xor    $0x1f,%ebp
  802054:	75 5a                	jne    8020b0 <__umoddi3+0xb0>
  802056:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80205a:	0f 82 e0 00 00 00    	jb     802140 <__umoddi3+0x140>
  802060:	39 0c 24             	cmp    %ecx,(%esp)
  802063:	0f 86 d7 00 00 00    	jbe    802140 <__umoddi3+0x140>
  802069:	8b 44 24 08          	mov    0x8(%esp),%eax
  80206d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802071:	83 c4 1c             	add    $0x1c,%esp
  802074:	5b                   	pop    %ebx
  802075:	5e                   	pop    %esi
  802076:	5f                   	pop    %edi
  802077:	5d                   	pop    %ebp
  802078:	c3                   	ret    
  802079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802080:	85 ff                	test   %edi,%edi
  802082:	89 fd                	mov    %edi,%ebp
  802084:	75 0b                	jne    802091 <__umoddi3+0x91>
  802086:	b8 01 00 00 00       	mov    $0x1,%eax
  80208b:	31 d2                	xor    %edx,%edx
  80208d:	f7 f7                	div    %edi
  80208f:	89 c5                	mov    %eax,%ebp
  802091:	89 f0                	mov    %esi,%eax
  802093:	31 d2                	xor    %edx,%edx
  802095:	f7 f5                	div    %ebp
  802097:	89 c8                	mov    %ecx,%eax
  802099:	f7 f5                	div    %ebp
  80209b:	89 d0                	mov    %edx,%eax
  80209d:	eb 99                	jmp    802038 <__umoddi3+0x38>
  80209f:	90                   	nop
  8020a0:	89 c8                	mov    %ecx,%eax
  8020a2:	89 f2                	mov    %esi,%edx
  8020a4:	83 c4 1c             	add    $0x1c,%esp
  8020a7:	5b                   	pop    %ebx
  8020a8:	5e                   	pop    %esi
  8020a9:	5f                   	pop    %edi
  8020aa:	5d                   	pop    %ebp
  8020ab:	c3                   	ret    
  8020ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020b0:	8b 34 24             	mov    (%esp),%esi
  8020b3:	bf 20 00 00 00       	mov    $0x20,%edi
  8020b8:	89 e9                	mov    %ebp,%ecx
  8020ba:	29 ef                	sub    %ebp,%edi
  8020bc:	d3 e0                	shl    %cl,%eax
  8020be:	89 f9                	mov    %edi,%ecx
  8020c0:	89 f2                	mov    %esi,%edx
  8020c2:	d3 ea                	shr    %cl,%edx
  8020c4:	89 e9                	mov    %ebp,%ecx
  8020c6:	09 c2                	or     %eax,%edx
  8020c8:	89 d8                	mov    %ebx,%eax
  8020ca:	89 14 24             	mov    %edx,(%esp)
  8020cd:	89 f2                	mov    %esi,%edx
  8020cf:	d3 e2                	shl    %cl,%edx
  8020d1:	89 f9                	mov    %edi,%ecx
  8020d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8020d7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8020db:	d3 e8                	shr    %cl,%eax
  8020dd:	89 e9                	mov    %ebp,%ecx
  8020df:	89 c6                	mov    %eax,%esi
  8020e1:	d3 e3                	shl    %cl,%ebx
  8020e3:	89 f9                	mov    %edi,%ecx
  8020e5:	89 d0                	mov    %edx,%eax
  8020e7:	d3 e8                	shr    %cl,%eax
  8020e9:	89 e9                	mov    %ebp,%ecx
  8020eb:	09 d8                	or     %ebx,%eax
  8020ed:	89 d3                	mov    %edx,%ebx
  8020ef:	89 f2                	mov    %esi,%edx
  8020f1:	f7 34 24             	divl   (%esp)
  8020f4:	89 d6                	mov    %edx,%esi
  8020f6:	d3 e3                	shl    %cl,%ebx
  8020f8:	f7 64 24 04          	mull   0x4(%esp)
  8020fc:	39 d6                	cmp    %edx,%esi
  8020fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802102:	89 d1                	mov    %edx,%ecx
  802104:	89 c3                	mov    %eax,%ebx
  802106:	72 08                	jb     802110 <__umoddi3+0x110>
  802108:	75 11                	jne    80211b <__umoddi3+0x11b>
  80210a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80210e:	73 0b                	jae    80211b <__umoddi3+0x11b>
  802110:	2b 44 24 04          	sub    0x4(%esp),%eax
  802114:	1b 14 24             	sbb    (%esp),%edx
  802117:	89 d1                	mov    %edx,%ecx
  802119:	89 c3                	mov    %eax,%ebx
  80211b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80211f:	29 da                	sub    %ebx,%edx
  802121:	19 ce                	sbb    %ecx,%esi
  802123:	89 f9                	mov    %edi,%ecx
  802125:	89 f0                	mov    %esi,%eax
  802127:	d3 e0                	shl    %cl,%eax
  802129:	89 e9                	mov    %ebp,%ecx
  80212b:	d3 ea                	shr    %cl,%edx
  80212d:	89 e9                	mov    %ebp,%ecx
  80212f:	d3 ee                	shr    %cl,%esi
  802131:	09 d0                	or     %edx,%eax
  802133:	89 f2                	mov    %esi,%edx
  802135:	83 c4 1c             	add    $0x1c,%esp
  802138:	5b                   	pop    %ebx
  802139:	5e                   	pop    %esi
  80213a:	5f                   	pop    %edi
  80213b:	5d                   	pop    %ebp
  80213c:	c3                   	ret    
  80213d:	8d 76 00             	lea    0x0(%esi),%esi
  802140:	29 f9                	sub    %edi,%ecx
  802142:	19 d6                	sbb    %edx,%esi
  802144:	89 74 24 04          	mov    %esi,0x4(%esp)
  802148:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80214c:	e9 18 ff ff ff       	jmp    802069 <__umoddi3+0x69>
