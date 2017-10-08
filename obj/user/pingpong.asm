
obj/user/pingpong.debug：     文件格式 elf32-i386


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
  80002c:	e8 8d 00 00 00       	call   8000be <libmain>
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
  800039:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003c:	e8 0d 0e 00 00       	call   800e4e <fork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 27                	je     80006f <umain+0x3c>
  800048:	89 c3                	mov    %eax,%ebx
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004a:	e8 2b 0b 00 00       	call   800b7a <sys_getenvid>
  80004f:	83 ec 04             	sub    $0x4,%esp
  800052:	53                   	push   %ebx
  800053:	50                   	push   %eax
  800054:	68 80 21 80 00       	push   $0x802180
  800059:	e8 53 01 00 00       	call   8001b1 <cprintf>
		ipc_send(who, 0, 0, 0);
  80005e:	6a 00                	push   $0x0
  800060:	6a 00                	push   $0x0
  800062:	6a 00                	push   $0x0
  800064:	ff 75 e4             	pushl  -0x1c(%ebp)
  800067:	e8 08 10 00 00       	call   801074 <ipc_send>
  80006c:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  80006f:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800072:	83 ec 04             	sub    $0x4,%esp
  800075:	6a 00                	push   $0x0
  800077:	6a 00                	push   $0x0
  800079:	56                   	push   %esi
  80007a:	e8 83 0f 00 00       	call   801002 <ipc_recv>
  80007f:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  800081:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800084:	e8 f1 0a 00 00       	call   800b7a <sys_getenvid>
  800089:	57                   	push   %edi
  80008a:	53                   	push   %ebx
  80008b:	50                   	push   %eax
  80008c:	68 96 21 80 00       	push   $0x802196
  800091:	e8 1b 01 00 00       	call   8001b1 <cprintf>
		if (i == 10)
  800096:	83 c4 20             	add    $0x20,%esp
  800099:	83 fb 0a             	cmp    $0xa,%ebx
  80009c:	74 18                	je     8000b6 <umain+0x83>
			return;
		i++;
  80009e:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  8000a1:	6a 00                	push   $0x0
  8000a3:	6a 00                	push   $0x0
  8000a5:	53                   	push   %ebx
  8000a6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000a9:	e8 c6 0f 00 00       	call   801074 <ipc_send>
		if (i == 10)
  8000ae:	83 c4 10             	add    $0x10,%esp
  8000b1:	83 fb 0a             	cmp    $0xa,%ebx
  8000b4:	75 bc                	jne    800072 <umain+0x3f>
			return;
	}

}
  8000b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000b9:	5b                   	pop    %ebx
  8000ba:	5e                   	pop    %esi
  8000bb:	5f                   	pop    %edi
  8000bc:	5d                   	pop    %ebp
  8000bd:	c3                   	ret    

008000be <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	56                   	push   %esi
  8000c2:	53                   	push   %ebx
  8000c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000c6:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000c9:	e8 ac 0a 00 00       	call   800b7a <sys_getenvid>
  8000ce:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000d6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000db:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e0:	85 db                	test   %ebx,%ebx
  8000e2:	7e 07                	jle    8000eb <libmain+0x2d>
		binaryname = argv[0];
  8000e4:	8b 06                	mov    (%esi),%eax
  8000e6:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000eb:	83 ec 08             	sub    $0x8,%esp
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
  8000f0:	e8 3e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000f5:	e8 0a 00 00 00       	call   800104 <exit>
}
  8000fa:	83 c4 10             	add    $0x10,%esp
  8000fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800100:	5b                   	pop    %ebx
  800101:	5e                   	pop    %esi
  800102:	5d                   	pop    %ebp
  800103:	c3                   	ret    

00800104 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80010a:	e8 bd 11 00 00       	call   8012cc <close_all>
	sys_env_destroy(0);
  80010f:	83 ec 0c             	sub    $0xc,%esp
  800112:	6a 00                	push   $0x0
  800114:	e8 20 0a 00 00       	call   800b39 <sys_env_destroy>
}
  800119:	83 c4 10             	add    $0x10,%esp
  80011c:	c9                   	leave  
  80011d:	c3                   	ret    

0080011e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80011e:	55                   	push   %ebp
  80011f:	89 e5                	mov    %esp,%ebp
  800121:	53                   	push   %ebx
  800122:	83 ec 04             	sub    $0x4,%esp
  800125:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800128:	8b 13                	mov    (%ebx),%edx
  80012a:	8d 42 01             	lea    0x1(%edx),%eax
  80012d:	89 03                	mov    %eax,(%ebx)
  80012f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800132:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800136:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013b:	75 1a                	jne    800157 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80013d:	83 ec 08             	sub    $0x8,%esp
  800140:	68 ff 00 00 00       	push   $0xff
  800145:	8d 43 08             	lea    0x8(%ebx),%eax
  800148:	50                   	push   %eax
  800149:	e8 ae 09 00 00       	call   800afc <sys_cputs>
		b->idx = 0;
  80014e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800154:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800157:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80015b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800169:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800170:	00 00 00 
	b.cnt = 0;
  800173:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80017d:	ff 75 0c             	pushl  0xc(%ebp)
  800180:	ff 75 08             	pushl  0x8(%ebp)
  800183:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800189:	50                   	push   %eax
  80018a:	68 1e 01 80 00       	push   $0x80011e
  80018f:	e8 1a 01 00 00       	call   8002ae <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800194:	83 c4 08             	add    $0x8,%esp
  800197:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80019d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a3:	50                   	push   %eax
  8001a4:	e8 53 09 00 00       	call   800afc <sys_cputs>

	return b.cnt;
}
  8001a9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001af:	c9                   	leave  
  8001b0:	c3                   	ret    

008001b1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b1:	55                   	push   %ebp
  8001b2:	89 e5                	mov    %esp,%ebp
  8001b4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001ba:	50                   	push   %eax
  8001bb:	ff 75 08             	pushl  0x8(%ebp)
  8001be:	e8 9d ff ff ff       	call   800160 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c3:	c9                   	leave  
  8001c4:	c3                   	ret    

008001c5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c5:	55                   	push   %ebp
  8001c6:	89 e5                	mov    %esp,%ebp
  8001c8:	57                   	push   %edi
  8001c9:	56                   	push   %esi
  8001ca:	53                   	push   %ebx
  8001cb:	83 ec 1c             	sub    $0x1c,%esp
  8001ce:	89 c7                	mov    %eax,%edi
  8001d0:	89 d6                	mov    %edx,%esi
  8001d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001db:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001de:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001e9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001ec:	39 d3                	cmp    %edx,%ebx
  8001ee:	72 05                	jb     8001f5 <printnum+0x30>
  8001f0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f3:	77 45                	ja     80023a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f5:	83 ec 0c             	sub    $0xc,%esp
  8001f8:	ff 75 18             	pushl  0x18(%ebp)
  8001fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8001fe:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800201:	53                   	push   %ebx
  800202:	ff 75 10             	pushl  0x10(%ebp)
  800205:	83 ec 08             	sub    $0x8,%esp
  800208:	ff 75 e4             	pushl  -0x1c(%ebp)
  80020b:	ff 75 e0             	pushl  -0x20(%ebp)
  80020e:	ff 75 dc             	pushl  -0x24(%ebp)
  800211:	ff 75 d8             	pushl  -0x28(%ebp)
  800214:	e8 c7 1c 00 00       	call   801ee0 <__udivdi3>
  800219:	83 c4 18             	add    $0x18,%esp
  80021c:	52                   	push   %edx
  80021d:	50                   	push   %eax
  80021e:	89 f2                	mov    %esi,%edx
  800220:	89 f8                	mov    %edi,%eax
  800222:	e8 9e ff ff ff       	call   8001c5 <printnum>
  800227:	83 c4 20             	add    $0x20,%esp
  80022a:	eb 18                	jmp    800244 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022c:	83 ec 08             	sub    $0x8,%esp
  80022f:	56                   	push   %esi
  800230:	ff 75 18             	pushl  0x18(%ebp)
  800233:	ff d7                	call   *%edi
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	eb 03                	jmp    80023d <printnum+0x78>
  80023a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80023d:	83 eb 01             	sub    $0x1,%ebx
  800240:	85 db                	test   %ebx,%ebx
  800242:	7f e8                	jg     80022c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800244:	83 ec 08             	sub    $0x8,%esp
  800247:	56                   	push   %esi
  800248:	83 ec 04             	sub    $0x4,%esp
  80024b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024e:	ff 75 e0             	pushl  -0x20(%ebp)
  800251:	ff 75 dc             	pushl  -0x24(%ebp)
  800254:	ff 75 d8             	pushl  -0x28(%ebp)
  800257:	e8 b4 1d 00 00       	call   802010 <__umoddi3>
  80025c:	83 c4 14             	add    $0x14,%esp
  80025f:	0f be 80 b3 21 80 00 	movsbl 0x8021b3(%eax),%eax
  800266:	50                   	push   %eax
  800267:	ff d7                	call   *%edi
}
  800269:	83 c4 10             	add    $0x10,%esp
  80026c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026f:	5b                   	pop    %ebx
  800270:	5e                   	pop    %esi
  800271:	5f                   	pop    %edi
  800272:	5d                   	pop    %ebp
  800273:	c3                   	ret    

00800274 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80027a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80027e:	8b 10                	mov    (%eax),%edx
  800280:	3b 50 04             	cmp    0x4(%eax),%edx
  800283:	73 0a                	jae    80028f <sprintputch+0x1b>
		*b->buf++ = ch;
  800285:	8d 4a 01             	lea    0x1(%edx),%ecx
  800288:	89 08                	mov    %ecx,(%eax)
  80028a:	8b 45 08             	mov    0x8(%ebp),%eax
  80028d:	88 02                	mov    %al,(%edx)
}
  80028f:	5d                   	pop    %ebp
  800290:	c3                   	ret    

00800291 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
  800294:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800297:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80029a:	50                   	push   %eax
  80029b:	ff 75 10             	pushl  0x10(%ebp)
  80029e:	ff 75 0c             	pushl  0xc(%ebp)
  8002a1:	ff 75 08             	pushl  0x8(%ebp)
  8002a4:	e8 05 00 00 00       	call   8002ae <vprintfmt>
	va_end(ap);
}
  8002a9:	83 c4 10             	add    $0x10,%esp
  8002ac:	c9                   	leave  
  8002ad:	c3                   	ret    

008002ae <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	57                   	push   %edi
  8002b2:	56                   	push   %esi
  8002b3:	53                   	push   %ebx
  8002b4:	83 ec 2c             	sub    $0x2c,%esp
  8002b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8002ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002bd:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002c0:	eb 12                	jmp    8002d4 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002c2:	85 c0                	test   %eax,%eax
  8002c4:	0f 84 42 04 00 00    	je     80070c <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8002ca:	83 ec 08             	sub    $0x8,%esp
  8002cd:	53                   	push   %ebx
  8002ce:	50                   	push   %eax
  8002cf:	ff d6                	call   *%esi
  8002d1:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002d4:	83 c7 01             	add    $0x1,%edi
  8002d7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002db:	83 f8 25             	cmp    $0x25,%eax
  8002de:	75 e2                	jne    8002c2 <vprintfmt+0x14>
  8002e0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002e4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002eb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002f2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002fe:	eb 07                	jmp    800307 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800300:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800303:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800307:	8d 47 01             	lea    0x1(%edi),%eax
  80030a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80030d:	0f b6 07             	movzbl (%edi),%eax
  800310:	0f b6 d0             	movzbl %al,%edx
  800313:	83 e8 23             	sub    $0x23,%eax
  800316:	3c 55                	cmp    $0x55,%al
  800318:	0f 87 d3 03 00 00    	ja     8006f1 <vprintfmt+0x443>
  80031e:	0f b6 c0             	movzbl %al,%eax
  800321:	ff 24 85 00 23 80 00 	jmp    *0x802300(,%eax,4)
  800328:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80032b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80032f:	eb d6                	jmp    800307 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800331:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800334:	b8 00 00 00 00       	mov    $0x0,%eax
  800339:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80033c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80033f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800343:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800346:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800349:	83 f9 09             	cmp    $0x9,%ecx
  80034c:	77 3f                	ja     80038d <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80034e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800351:	eb e9                	jmp    80033c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800353:	8b 45 14             	mov    0x14(%ebp),%eax
  800356:	8b 00                	mov    (%eax),%eax
  800358:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80035b:	8b 45 14             	mov    0x14(%ebp),%eax
  80035e:	8d 40 04             	lea    0x4(%eax),%eax
  800361:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800364:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800367:	eb 2a                	jmp    800393 <vprintfmt+0xe5>
  800369:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80036c:	85 c0                	test   %eax,%eax
  80036e:	ba 00 00 00 00       	mov    $0x0,%edx
  800373:	0f 49 d0             	cmovns %eax,%edx
  800376:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800379:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80037c:	eb 89                	jmp    800307 <vprintfmt+0x59>
  80037e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800381:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800388:	e9 7a ff ff ff       	jmp    800307 <vprintfmt+0x59>
  80038d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800390:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800393:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800397:	0f 89 6a ff ff ff    	jns    800307 <vprintfmt+0x59>
				width = precision, precision = -1;
  80039d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003a0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003a3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003aa:	e9 58 ff ff ff       	jmp    800307 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003af:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003b5:	e9 4d ff ff ff       	jmp    800307 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bd:	8d 78 04             	lea    0x4(%eax),%edi
  8003c0:	83 ec 08             	sub    $0x8,%esp
  8003c3:	53                   	push   %ebx
  8003c4:	ff 30                	pushl  (%eax)
  8003c6:	ff d6                	call   *%esi
			break;
  8003c8:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003cb:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003d1:	e9 fe fe ff ff       	jmp    8002d4 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d9:	8d 78 04             	lea    0x4(%eax),%edi
  8003dc:	8b 00                	mov    (%eax),%eax
  8003de:	99                   	cltd   
  8003df:	31 d0                	xor    %edx,%eax
  8003e1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003e3:	83 f8 0f             	cmp    $0xf,%eax
  8003e6:	7f 0b                	jg     8003f3 <vprintfmt+0x145>
  8003e8:	8b 14 85 60 24 80 00 	mov    0x802460(,%eax,4),%edx
  8003ef:	85 d2                	test   %edx,%edx
  8003f1:	75 1b                	jne    80040e <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8003f3:	50                   	push   %eax
  8003f4:	68 cb 21 80 00       	push   $0x8021cb
  8003f9:	53                   	push   %ebx
  8003fa:	56                   	push   %esi
  8003fb:	e8 91 fe ff ff       	call   800291 <printfmt>
  800400:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800403:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800406:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800409:	e9 c6 fe ff ff       	jmp    8002d4 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80040e:	52                   	push   %edx
  80040f:	68 15 26 80 00       	push   $0x802615
  800414:	53                   	push   %ebx
  800415:	56                   	push   %esi
  800416:	e8 76 fe ff ff       	call   800291 <printfmt>
  80041b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80041e:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800421:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800424:	e9 ab fe ff ff       	jmp    8002d4 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800429:	8b 45 14             	mov    0x14(%ebp),%eax
  80042c:	83 c0 04             	add    $0x4,%eax
  80042f:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800432:	8b 45 14             	mov    0x14(%ebp),%eax
  800435:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800437:	85 ff                	test   %edi,%edi
  800439:	b8 c4 21 80 00       	mov    $0x8021c4,%eax
  80043e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800441:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800445:	0f 8e 94 00 00 00    	jle    8004df <vprintfmt+0x231>
  80044b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80044f:	0f 84 98 00 00 00    	je     8004ed <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800455:	83 ec 08             	sub    $0x8,%esp
  800458:	ff 75 d0             	pushl  -0x30(%ebp)
  80045b:	57                   	push   %edi
  80045c:	e8 33 03 00 00       	call   800794 <strnlen>
  800461:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800464:	29 c1                	sub    %eax,%ecx
  800466:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800469:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80046c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800470:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800473:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800476:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800478:	eb 0f                	jmp    800489 <vprintfmt+0x1db>
					putch(padc, putdat);
  80047a:	83 ec 08             	sub    $0x8,%esp
  80047d:	53                   	push   %ebx
  80047e:	ff 75 e0             	pushl  -0x20(%ebp)
  800481:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800483:	83 ef 01             	sub    $0x1,%edi
  800486:	83 c4 10             	add    $0x10,%esp
  800489:	85 ff                	test   %edi,%edi
  80048b:	7f ed                	jg     80047a <vprintfmt+0x1cc>
  80048d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800490:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800493:	85 c9                	test   %ecx,%ecx
  800495:	b8 00 00 00 00       	mov    $0x0,%eax
  80049a:	0f 49 c1             	cmovns %ecx,%eax
  80049d:	29 c1                	sub    %eax,%ecx
  80049f:	89 75 08             	mov    %esi,0x8(%ebp)
  8004a2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004a5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004a8:	89 cb                	mov    %ecx,%ebx
  8004aa:	eb 4d                	jmp    8004f9 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004ac:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004b0:	74 1b                	je     8004cd <vprintfmt+0x21f>
  8004b2:	0f be c0             	movsbl %al,%eax
  8004b5:	83 e8 20             	sub    $0x20,%eax
  8004b8:	83 f8 5e             	cmp    $0x5e,%eax
  8004bb:	76 10                	jbe    8004cd <vprintfmt+0x21f>
					putch('?', putdat);
  8004bd:	83 ec 08             	sub    $0x8,%esp
  8004c0:	ff 75 0c             	pushl  0xc(%ebp)
  8004c3:	6a 3f                	push   $0x3f
  8004c5:	ff 55 08             	call   *0x8(%ebp)
  8004c8:	83 c4 10             	add    $0x10,%esp
  8004cb:	eb 0d                	jmp    8004da <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8004cd:	83 ec 08             	sub    $0x8,%esp
  8004d0:	ff 75 0c             	pushl  0xc(%ebp)
  8004d3:	52                   	push   %edx
  8004d4:	ff 55 08             	call   *0x8(%ebp)
  8004d7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004da:	83 eb 01             	sub    $0x1,%ebx
  8004dd:	eb 1a                	jmp    8004f9 <vprintfmt+0x24b>
  8004df:	89 75 08             	mov    %esi,0x8(%ebp)
  8004e2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004e5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004e8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004eb:	eb 0c                	jmp    8004f9 <vprintfmt+0x24b>
  8004ed:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004f9:	83 c7 01             	add    $0x1,%edi
  8004fc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800500:	0f be d0             	movsbl %al,%edx
  800503:	85 d2                	test   %edx,%edx
  800505:	74 23                	je     80052a <vprintfmt+0x27c>
  800507:	85 f6                	test   %esi,%esi
  800509:	78 a1                	js     8004ac <vprintfmt+0x1fe>
  80050b:	83 ee 01             	sub    $0x1,%esi
  80050e:	79 9c                	jns    8004ac <vprintfmt+0x1fe>
  800510:	89 df                	mov    %ebx,%edi
  800512:	8b 75 08             	mov    0x8(%ebp),%esi
  800515:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800518:	eb 18                	jmp    800532 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80051a:	83 ec 08             	sub    $0x8,%esp
  80051d:	53                   	push   %ebx
  80051e:	6a 20                	push   $0x20
  800520:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800522:	83 ef 01             	sub    $0x1,%edi
  800525:	83 c4 10             	add    $0x10,%esp
  800528:	eb 08                	jmp    800532 <vprintfmt+0x284>
  80052a:	89 df                	mov    %ebx,%edi
  80052c:	8b 75 08             	mov    0x8(%ebp),%esi
  80052f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800532:	85 ff                	test   %edi,%edi
  800534:	7f e4                	jg     80051a <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800536:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800539:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80053f:	e9 90 fd ff ff       	jmp    8002d4 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800544:	83 f9 01             	cmp    $0x1,%ecx
  800547:	7e 19                	jle    800562 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800549:	8b 45 14             	mov    0x14(%ebp),%eax
  80054c:	8b 50 04             	mov    0x4(%eax),%edx
  80054f:	8b 00                	mov    (%eax),%eax
  800551:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800554:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800557:	8b 45 14             	mov    0x14(%ebp),%eax
  80055a:	8d 40 08             	lea    0x8(%eax),%eax
  80055d:	89 45 14             	mov    %eax,0x14(%ebp)
  800560:	eb 38                	jmp    80059a <vprintfmt+0x2ec>
	else if (lflag)
  800562:	85 c9                	test   %ecx,%ecx
  800564:	74 1b                	je     800581 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800566:	8b 45 14             	mov    0x14(%ebp),%eax
  800569:	8b 00                	mov    (%eax),%eax
  80056b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80056e:	89 c1                	mov    %eax,%ecx
  800570:	c1 f9 1f             	sar    $0x1f,%ecx
  800573:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800576:	8b 45 14             	mov    0x14(%ebp),%eax
  800579:	8d 40 04             	lea    0x4(%eax),%eax
  80057c:	89 45 14             	mov    %eax,0x14(%ebp)
  80057f:	eb 19                	jmp    80059a <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800581:	8b 45 14             	mov    0x14(%ebp),%eax
  800584:	8b 00                	mov    (%eax),%eax
  800586:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800589:	89 c1                	mov    %eax,%ecx
  80058b:	c1 f9 1f             	sar    $0x1f,%ecx
  80058e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800591:	8b 45 14             	mov    0x14(%ebp),%eax
  800594:	8d 40 04             	lea    0x4(%eax),%eax
  800597:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80059a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80059d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005a0:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005a5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005a9:	0f 89 0e 01 00 00    	jns    8006bd <vprintfmt+0x40f>
				putch('-', putdat);
  8005af:	83 ec 08             	sub    $0x8,%esp
  8005b2:	53                   	push   %ebx
  8005b3:	6a 2d                	push   $0x2d
  8005b5:	ff d6                	call   *%esi
				num = -(long long) num;
  8005b7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005ba:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005bd:	f7 da                	neg    %edx
  8005bf:	83 d1 00             	adc    $0x0,%ecx
  8005c2:	f7 d9                	neg    %ecx
  8005c4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005c7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005cc:	e9 ec 00 00 00       	jmp    8006bd <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005d1:	83 f9 01             	cmp    $0x1,%ecx
  8005d4:	7e 18                	jle    8005ee <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8005d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d9:	8b 10                	mov    (%eax),%edx
  8005db:	8b 48 04             	mov    0x4(%eax),%ecx
  8005de:	8d 40 08             	lea    0x8(%eax),%eax
  8005e1:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005e4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e9:	e9 cf 00 00 00       	jmp    8006bd <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8005ee:	85 c9                	test   %ecx,%ecx
  8005f0:	74 1a                	je     80060c <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8005f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f5:	8b 10                	mov    (%eax),%edx
  8005f7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005fc:	8d 40 04             	lea    0x4(%eax),%eax
  8005ff:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800602:	b8 0a 00 00 00       	mov    $0xa,%eax
  800607:	e9 b1 00 00 00       	jmp    8006bd <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80060c:	8b 45 14             	mov    0x14(%ebp),%eax
  80060f:	8b 10                	mov    (%eax),%edx
  800611:	b9 00 00 00 00       	mov    $0x0,%ecx
  800616:	8d 40 04             	lea    0x4(%eax),%eax
  800619:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80061c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800621:	e9 97 00 00 00       	jmp    8006bd <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800626:	83 ec 08             	sub    $0x8,%esp
  800629:	53                   	push   %ebx
  80062a:	6a 58                	push   $0x58
  80062c:	ff d6                	call   *%esi
			putch('X', putdat);
  80062e:	83 c4 08             	add    $0x8,%esp
  800631:	53                   	push   %ebx
  800632:	6a 58                	push   $0x58
  800634:	ff d6                	call   *%esi
			putch('X', putdat);
  800636:	83 c4 08             	add    $0x8,%esp
  800639:	53                   	push   %ebx
  80063a:	6a 58                	push   $0x58
  80063c:	ff d6                	call   *%esi
			break;
  80063e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800641:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800644:	e9 8b fc ff ff       	jmp    8002d4 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800649:	83 ec 08             	sub    $0x8,%esp
  80064c:	53                   	push   %ebx
  80064d:	6a 30                	push   $0x30
  80064f:	ff d6                	call   *%esi
			putch('x', putdat);
  800651:	83 c4 08             	add    $0x8,%esp
  800654:	53                   	push   %ebx
  800655:	6a 78                	push   $0x78
  800657:	ff d6                	call   *%esi
			num = (unsigned long long)
  800659:	8b 45 14             	mov    0x14(%ebp),%eax
  80065c:	8b 10                	mov    (%eax),%edx
  80065e:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800663:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800666:	8d 40 04             	lea    0x4(%eax),%eax
  800669:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80066c:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800671:	eb 4a                	jmp    8006bd <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800673:	83 f9 01             	cmp    $0x1,%ecx
  800676:	7e 15                	jle    80068d <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  800678:	8b 45 14             	mov    0x14(%ebp),%eax
  80067b:	8b 10                	mov    (%eax),%edx
  80067d:	8b 48 04             	mov    0x4(%eax),%ecx
  800680:	8d 40 08             	lea    0x8(%eax),%eax
  800683:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800686:	b8 10 00 00 00       	mov    $0x10,%eax
  80068b:	eb 30                	jmp    8006bd <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80068d:	85 c9                	test   %ecx,%ecx
  80068f:	74 17                	je     8006a8 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800691:	8b 45 14             	mov    0x14(%ebp),%eax
  800694:	8b 10                	mov    (%eax),%edx
  800696:	b9 00 00 00 00       	mov    $0x0,%ecx
  80069b:	8d 40 04             	lea    0x4(%eax),%eax
  80069e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006a1:	b8 10 00 00 00       	mov    $0x10,%eax
  8006a6:	eb 15                	jmp    8006bd <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8006a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ab:	8b 10                	mov    (%eax),%edx
  8006ad:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b2:	8d 40 04             	lea    0x4(%eax),%eax
  8006b5:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006b8:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006bd:	83 ec 0c             	sub    $0xc,%esp
  8006c0:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006c4:	57                   	push   %edi
  8006c5:	ff 75 e0             	pushl  -0x20(%ebp)
  8006c8:	50                   	push   %eax
  8006c9:	51                   	push   %ecx
  8006ca:	52                   	push   %edx
  8006cb:	89 da                	mov    %ebx,%edx
  8006cd:	89 f0                	mov    %esi,%eax
  8006cf:	e8 f1 fa ff ff       	call   8001c5 <printnum>
			break;
  8006d4:	83 c4 20             	add    $0x20,%esp
  8006d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006da:	e9 f5 fb ff ff       	jmp    8002d4 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006df:	83 ec 08             	sub    $0x8,%esp
  8006e2:	53                   	push   %ebx
  8006e3:	52                   	push   %edx
  8006e4:	ff d6                	call   *%esi
			break;
  8006e6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006ec:	e9 e3 fb ff ff       	jmp    8002d4 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006f1:	83 ec 08             	sub    $0x8,%esp
  8006f4:	53                   	push   %ebx
  8006f5:	6a 25                	push   $0x25
  8006f7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006f9:	83 c4 10             	add    $0x10,%esp
  8006fc:	eb 03                	jmp    800701 <vprintfmt+0x453>
  8006fe:	83 ef 01             	sub    $0x1,%edi
  800701:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800705:	75 f7                	jne    8006fe <vprintfmt+0x450>
  800707:	e9 c8 fb ff ff       	jmp    8002d4 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80070c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80070f:	5b                   	pop    %ebx
  800710:	5e                   	pop    %esi
  800711:	5f                   	pop    %edi
  800712:	5d                   	pop    %ebp
  800713:	c3                   	ret    

00800714 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800714:	55                   	push   %ebp
  800715:	89 e5                	mov    %esp,%ebp
  800717:	83 ec 18             	sub    $0x18,%esp
  80071a:	8b 45 08             	mov    0x8(%ebp),%eax
  80071d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800720:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800723:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800727:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80072a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800731:	85 c0                	test   %eax,%eax
  800733:	74 26                	je     80075b <vsnprintf+0x47>
  800735:	85 d2                	test   %edx,%edx
  800737:	7e 22                	jle    80075b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800739:	ff 75 14             	pushl  0x14(%ebp)
  80073c:	ff 75 10             	pushl  0x10(%ebp)
  80073f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800742:	50                   	push   %eax
  800743:	68 74 02 80 00       	push   $0x800274
  800748:	e8 61 fb ff ff       	call   8002ae <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80074d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800750:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800753:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800756:	83 c4 10             	add    $0x10,%esp
  800759:	eb 05                	jmp    800760 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80075b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800760:	c9                   	leave  
  800761:	c3                   	ret    

00800762 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800762:	55                   	push   %ebp
  800763:	89 e5                	mov    %esp,%ebp
  800765:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800768:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80076b:	50                   	push   %eax
  80076c:	ff 75 10             	pushl  0x10(%ebp)
  80076f:	ff 75 0c             	pushl  0xc(%ebp)
  800772:	ff 75 08             	pushl  0x8(%ebp)
  800775:	e8 9a ff ff ff       	call   800714 <vsnprintf>
	va_end(ap);

	return rc;
}
  80077a:	c9                   	leave  
  80077b:	c3                   	ret    

0080077c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80077c:	55                   	push   %ebp
  80077d:	89 e5                	mov    %esp,%ebp
  80077f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800782:	b8 00 00 00 00       	mov    $0x0,%eax
  800787:	eb 03                	jmp    80078c <strlen+0x10>
		n++;
  800789:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80078c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800790:	75 f7                	jne    800789 <strlen+0xd>
		n++;
	return n;
}
  800792:	5d                   	pop    %ebp
  800793:	c3                   	ret    

00800794 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800794:	55                   	push   %ebp
  800795:	89 e5                	mov    %esp,%ebp
  800797:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079d:	ba 00 00 00 00       	mov    $0x0,%edx
  8007a2:	eb 03                	jmp    8007a7 <strnlen+0x13>
		n++;
  8007a4:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a7:	39 c2                	cmp    %eax,%edx
  8007a9:	74 08                	je     8007b3 <strnlen+0x1f>
  8007ab:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007af:	75 f3                	jne    8007a4 <strnlen+0x10>
  8007b1:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007b3:	5d                   	pop    %ebp
  8007b4:	c3                   	ret    

008007b5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
  8007b8:	53                   	push   %ebx
  8007b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007bf:	89 c2                	mov    %eax,%edx
  8007c1:	83 c2 01             	add    $0x1,%edx
  8007c4:	83 c1 01             	add    $0x1,%ecx
  8007c7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007cb:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007ce:	84 db                	test   %bl,%bl
  8007d0:	75 ef                	jne    8007c1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007d2:	5b                   	pop    %ebx
  8007d3:	5d                   	pop    %ebp
  8007d4:	c3                   	ret    

008007d5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d5:	55                   	push   %ebp
  8007d6:	89 e5                	mov    %esp,%ebp
  8007d8:	53                   	push   %ebx
  8007d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007dc:	53                   	push   %ebx
  8007dd:	e8 9a ff ff ff       	call   80077c <strlen>
  8007e2:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007e5:	ff 75 0c             	pushl  0xc(%ebp)
  8007e8:	01 d8                	add    %ebx,%eax
  8007ea:	50                   	push   %eax
  8007eb:	e8 c5 ff ff ff       	call   8007b5 <strcpy>
	return dst;
}
  8007f0:	89 d8                	mov    %ebx,%eax
  8007f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f5:	c9                   	leave  
  8007f6:	c3                   	ret    

008007f7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
  8007fa:	56                   	push   %esi
  8007fb:	53                   	push   %ebx
  8007fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800802:	89 f3                	mov    %esi,%ebx
  800804:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800807:	89 f2                	mov    %esi,%edx
  800809:	eb 0f                	jmp    80081a <strncpy+0x23>
		*dst++ = *src;
  80080b:	83 c2 01             	add    $0x1,%edx
  80080e:	0f b6 01             	movzbl (%ecx),%eax
  800811:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800814:	80 39 01             	cmpb   $0x1,(%ecx)
  800817:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081a:	39 da                	cmp    %ebx,%edx
  80081c:	75 ed                	jne    80080b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80081e:	89 f0                	mov    %esi,%eax
  800820:	5b                   	pop    %ebx
  800821:	5e                   	pop    %esi
  800822:	5d                   	pop    %ebp
  800823:	c3                   	ret    

00800824 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	56                   	push   %esi
  800828:	53                   	push   %ebx
  800829:	8b 75 08             	mov    0x8(%ebp),%esi
  80082c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80082f:	8b 55 10             	mov    0x10(%ebp),%edx
  800832:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800834:	85 d2                	test   %edx,%edx
  800836:	74 21                	je     800859 <strlcpy+0x35>
  800838:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80083c:	89 f2                	mov    %esi,%edx
  80083e:	eb 09                	jmp    800849 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800840:	83 c2 01             	add    $0x1,%edx
  800843:	83 c1 01             	add    $0x1,%ecx
  800846:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800849:	39 c2                	cmp    %eax,%edx
  80084b:	74 09                	je     800856 <strlcpy+0x32>
  80084d:	0f b6 19             	movzbl (%ecx),%ebx
  800850:	84 db                	test   %bl,%bl
  800852:	75 ec                	jne    800840 <strlcpy+0x1c>
  800854:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800856:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800859:	29 f0                	sub    %esi,%eax
}
  80085b:	5b                   	pop    %ebx
  80085c:	5e                   	pop    %esi
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    

0080085f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800865:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800868:	eb 06                	jmp    800870 <strcmp+0x11>
		p++, q++;
  80086a:	83 c1 01             	add    $0x1,%ecx
  80086d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800870:	0f b6 01             	movzbl (%ecx),%eax
  800873:	84 c0                	test   %al,%al
  800875:	74 04                	je     80087b <strcmp+0x1c>
  800877:	3a 02                	cmp    (%edx),%al
  800879:	74 ef                	je     80086a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80087b:	0f b6 c0             	movzbl %al,%eax
  80087e:	0f b6 12             	movzbl (%edx),%edx
  800881:	29 d0                	sub    %edx,%eax
}
  800883:	5d                   	pop    %ebp
  800884:	c3                   	ret    

00800885 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800885:	55                   	push   %ebp
  800886:	89 e5                	mov    %esp,%ebp
  800888:	53                   	push   %ebx
  800889:	8b 45 08             	mov    0x8(%ebp),%eax
  80088c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088f:	89 c3                	mov    %eax,%ebx
  800891:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800894:	eb 06                	jmp    80089c <strncmp+0x17>
		n--, p++, q++;
  800896:	83 c0 01             	add    $0x1,%eax
  800899:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80089c:	39 d8                	cmp    %ebx,%eax
  80089e:	74 15                	je     8008b5 <strncmp+0x30>
  8008a0:	0f b6 08             	movzbl (%eax),%ecx
  8008a3:	84 c9                	test   %cl,%cl
  8008a5:	74 04                	je     8008ab <strncmp+0x26>
  8008a7:	3a 0a                	cmp    (%edx),%cl
  8008a9:	74 eb                	je     800896 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ab:	0f b6 00             	movzbl (%eax),%eax
  8008ae:	0f b6 12             	movzbl (%edx),%edx
  8008b1:	29 d0                	sub    %edx,%eax
  8008b3:	eb 05                	jmp    8008ba <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008b5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008ba:	5b                   	pop    %ebx
  8008bb:	5d                   	pop    %ebp
  8008bc:	c3                   	ret    

008008bd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c7:	eb 07                	jmp    8008d0 <strchr+0x13>
		if (*s == c)
  8008c9:	38 ca                	cmp    %cl,%dl
  8008cb:	74 0f                	je     8008dc <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008cd:	83 c0 01             	add    $0x1,%eax
  8008d0:	0f b6 10             	movzbl (%eax),%edx
  8008d3:	84 d2                	test   %dl,%dl
  8008d5:	75 f2                	jne    8008c9 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008dc:	5d                   	pop    %ebp
  8008dd:	c3                   	ret    

008008de <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008de:	55                   	push   %ebp
  8008df:	89 e5                	mov    %esp,%ebp
  8008e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e8:	eb 03                	jmp    8008ed <strfind+0xf>
  8008ea:	83 c0 01             	add    $0x1,%eax
  8008ed:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008f0:	38 ca                	cmp    %cl,%dl
  8008f2:	74 04                	je     8008f8 <strfind+0x1a>
  8008f4:	84 d2                	test   %dl,%dl
  8008f6:	75 f2                	jne    8008ea <strfind+0xc>
			break;
	return (char *) s;
}
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	57                   	push   %edi
  8008fe:	56                   	push   %esi
  8008ff:	53                   	push   %ebx
  800900:	8b 7d 08             	mov    0x8(%ebp),%edi
  800903:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800906:	85 c9                	test   %ecx,%ecx
  800908:	74 36                	je     800940 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80090a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800910:	75 28                	jne    80093a <memset+0x40>
  800912:	f6 c1 03             	test   $0x3,%cl
  800915:	75 23                	jne    80093a <memset+0x40>
		c &= 0xFF;
  800917:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80091b:	89 d3                	mov    %edx,%ebx
  80091d:	c1 e3 08             	shl    $0x8,%ebx
  800920:	89 d6                	mov    %edx,%esi
  800922:	c1 e6 18             	shl    $0x18,%esi
  800925:	89 d0                	mov    %edx,%eax
  800927:	c1 e0 10             	shl    $0x10,%eax
  80092a:	09 f0                	or     %esi,%eax
  80092c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80092e:	89 d8                	mov    %ebx,%eax
  800930:	09 d0                	or     %edx,%eax
  800932:	c1 e9 02             	shr    $0x2,%ecx
  800935:	fc                   	cld    
  800936:	f3 ab                	rep stos %eax,%es:(%edi)
  800938:	eb 06                	jmp    800940 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80093a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093d:	fc                   	cld    
  80093e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800940:	89 f8                	mov    %edi,%eax
  800942:	5b                   	pop    %ebx
  800943:	5e                   	pop    %esi
  800944:	5f                   	pop    %edi
  800945:	5d                   	pop    %ebp
  800946:	c3                   	ret    

00800947 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800947:	55                   	push   %ebp
  800948:	89 e5                	mov    %esp,%ebp
  80094a:	57                   	push   %edi
  80094b:	56                   	push   %esi
  80094c:	8b 45 08             	mov    0x8(%ebp),%eax
  80094f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800952:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800955:	39 c6                	cmp    %eax,%esi
  800957:	73 35                	jae    80098e <memmove+0x47>
  800959:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80095c:	39 d0                	cmp    %edx,%eax
  80095e:	73 2e                	jae    80098e <memmove+0x47>
		s += n;
		d += n;
  800960:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800963:	89 d6                	mov    %edx,%esi
  800965:	09 fe                	or     %edi,%esi
  800967:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80096d:	75 13                	jne    800982 <memmove+0x3b>
  80096f:	f6 c1 03             	test   $0x3,%cl
  800972:	75 0e                	jne    800982 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800974:	83 ef 04             	sub    $0x4,%edi
  800977:	8d 72 fc             	lea    -0x4(%edx),%esi
  80097a:	c1 e9 02             	shr    $0x2,%ecx
  80097d:	fd                   	std    
  80097e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800980:	eb 09                	jmp    80098b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800982:	83 ef 01             	sub    $0x1,%edi
  800985:	8d 72 ff             	lea    -0x1(%edx),%esi
  800988:	fd                   	std    
  800989:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80098b:	fc                   	cld    
  80098c:	eb 1d                	jmp    8009ab <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098e:	89 f2                	mov    %esi,%edx
  800990:	09 c2                	or     %eax,%edx
  800992:	f6 c2 03             	test   $0x3,%dl
  800995:	75 0f                	jne    8009a6 <memmove+0x5f>
  800997:	f6 c1 03             	test   $0x3,%cl
  80099a:	75 0a                	jne    8009a6 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80099c:	c1 e9 02             	shr    $0x2,%ecx
  80099f:	89 c7                	mov    %eax,%edi
  8009a1:	fc                   	cld    
  8009a2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a4:	eb 05                	jmp    8009ab <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009a6:	89 c7                	mov    %eax,%edi
  8009a8:	fc                   	cld    
  8009a9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ab:	5e                   	pop    %esi
  8009ac:	5f                   	pop    %edi
  8009ad:	5d                   	pop    %ebp
  8009ae:	c3                   	ret    

008009af <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009b2:	ff 75 10             	pushl  0x10(%ebp)
  8009b5:	ff 75 0c             	pushl  0xc(%ebp)
  8009b8:	ff 75 08             	pushl  0x8(%ebp)
  8009bb:	e8 87 ff ff ff       	call   800947 <memmove>
}
  8009c0:	c9                   	leave  
  8009c1:	c3                   	ret    

008009c2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	56                   	push   %esi
  8009c6:	53                   	push   %ebx
  8009c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009cd:	89 c6                	mov    %eax,%esi
  8009cf:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d2:	eb 1a                	jmp    8009ee <memcmp+0x2c>
		if (*s1 != *s2)
  8009d4:	0f b6 08             	movzbl (%eax),%ecx
  8009d7:	0f b6 1a             	movzbl (%edx),%ebx
  8009da:	38 d9                	cmp    %bl,%cl
  8009dc:	74 0a                	je     8009e8 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009de:	0f b6 c1             	movzbl %cl,%eax
  8009e1:	0f b6 db             	movzbl %bl,%ebx
  8009e4:	29 d8                	sub    %ebx,%eax
  8009e6:	eb 0f                	jmp    8009f7 <memcmp+0x35>
		s1++, s2++;
  8009e8:	83 c0 01             	add    $0x1,%eax
  8009eb:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ee:	39 f0                	cmp    %esi,%eax
  8009f0:	75 e2                	jne    8009d4 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f7:	5b                   	pop    %ebx
  8009f8:	5e                   	pop    %esi
  8009f9:	5d                   	pop    %ebp
  8009fa:	c3                   	ret    

008009fb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	53                   	push   %ebx
  8009ff:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a02:	89 c1                	mov    %eax,%ecx
  800a04:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a07:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a0b:	eb 0a                	jmp    800a17 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a0d:	0f b6 10             	movzbl (%eax),%edx
  800a10:	39 da                	cmp    %ebx,%edx
  800a12:	74 07                	je     800a1b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a14:	83 c0 01             	add    $0x1,%eax
  800a17:	39 c8                	cmp    %ecx,%eax
  800a19:	72 f2                	jb     800a0d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a1b:	5b                   	pop    %ebx
  800a1c:	5d                   	pop    %ebp
  800a1d:	c3                   	ret    

00800a1e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	57                   	push   %edi
  800a22:	56                   	push   %esi
  800a23:	53                   	push   %ebx
  800a24:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a27:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a2a:	eb 03                	jmp    800a2f <strtol+0x11>
		s++;
  800a2c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a2f:	0f b6 01             	movzbl (%ecx),%eax
  800a32:	3c 20                	cmp    $0x20,%al
  800a34:	74 f6                	je     800a2c <strtol+0xe>
  800a36:	3c 09                	cmp    $0x9,%al
  800a38:	74 f2                	je     800a2c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a3a:	3c 2b                	cmp    $0x2b,%al
  800a3c:	75 0a                	jne    800a48 <strtol+0x2a>
		s++;
  800a3e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a41:	bf 00 00 00 00       	mov    $0x0,%edi
  800a46:	eb 11                	jmp    800a59 <strtol+0x3b>
  800a48:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a4d:	3c 2d                	cmp    $0x2d,%al
  800a4f:	75 08                	jne    800a59 <strtol+0x3b>
		s++, neg = 1;
  800a51:	83 c1 01             	add    $0x1,%ecx
  800a54:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a59:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a5f:	75 15                	jne    800a76 <strtol+0x58>
  800a61:	80 39 30             	cmpb   $0x30,(%ecx)
  800a64:	75 10                	jne    800a76 <strtol+0x58>
  800a66:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a6a:	75 7c                	jne    800ae8 <strtol+0xca>
		s += 2, base = 16;
  800a6c:	83 c1 02             	add    $0x2,%ecx
  800a6f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a74:	eb 16                	jmp    800a8c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a76:	85 db                	test   %ebx,%ebx
  800a78:	75 12                	jne    800a8c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a7a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a7f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a82:	75 08                	jne    800a8c <strtol+0x6e>
		s++, base = 8;
  800a84:	83 c1 01             	add    $0x1,%ecx
  800a87:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a8c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a91:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a94:	0f b6 11             	movzbl (%ecx),%edx
  800a97:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a9a:	89 f3                	mov    %esi,%ebx
  800a9c:	80 fb 09             	cmp    $0x9,%bl
  800a9f:	77 08                	ja     800aa9 <strtol+0x8b>
			dig = *s - '0';
  800aa1:	0f be d2             	movsbl %dl,%edx
  800aa4:	83 ea 30             	sub    $0x30,%edx
  800aa7:	eb 22                	jmp    800acb <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800aa9:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aac:	89 f3                	mov    %esi,%ebx
  800aae:	80 fb 19             	cmp    $0x19,%bl
  800ab1:	77 08                	ja     800abb <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ab3:	0f be d2             	movsbl %dl,%edx
  800ab6:	83 ea 57             	sub    $0x57,%edx
  800ab9:	eb 10                	jmp    800acb <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800abb:	8d 72 bf             	lea    -0x41(%edx),%esi
  800abe:	89 f3                	mov    %esi,%ebx
  800ac0:	80 fb 19             	cmp    $0x19,%bl
  800ac3:	77 16                	ja     800adb <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ac5:	0f be d2             	movsbl %dl,%edx
  800ac8:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800acb:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ace:	7d 0b                	jge    800adb <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ad0:	83 c1 01             	add    $0x1,%ecx
  800ad3:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ad7:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ad9:	eb b9                	jmp    800a94 <strtol+0x76>

	if (endptr)
  800adb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800adf:	74 0d                	je     800aee <strtol+0xd0>
		*endptr = (char *) s;
  800ae1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae4:	89 0e                	mov    %ecx,(%esi)
  800ae6:	eb 06                	jmp    800aee <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ae8:	85 db                	test   %ebx,%ebx
  800aea:	74 98                	je     800a84 <strtol+0x66>
  800aec:	eb 9e                	jmp    800a8c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800aee:	89 c2                	mov    %eax,%edx
  800af0:	f7 da                	neg    %edx
  800af2:	85 ff                	test   %edi,%edi
  800af4:	0f 45 c2             	cmovne %edx,%eax
}
  800af7:	5b                   	pop    %ebx
  800af8:	5e                   	pop    %esi
  800af9:	5f                   	pop    %edi
  800afa:	5d                   	pop    %ebp
  800afb:	c3                   	ret    

00800afc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800afc:	55                   	push   %ebp
  800afd:	89 e5                	mov    %esp,%ebp
  800aff:	57                   	push   %edi
  800b00:	56                   	push   %esi
  800b01:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b02:	b8 00 00 00 00       	mov    $0x0,%eax
  800b07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0d:	89 c3                	mov    %eax,%ebx
  800b0f:	89 c7                	mov    %eax,%edi
  800b11:	89 c6                	mov    %eax,%esi
  800b13:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b15:	5b                   	pop    %ebx
  800b16:	5e                   	pop    %esi
  800b17:	5f                   	pop    %edi
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    

00800b1a <sys_cgetc>:

int
sys_cgetc(void)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	57                   	push   %edi
  800b1e:	56                   	push   %esi
  800b1f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b20:	ba 00 00 00 00       	mov    $0x0,%edx
  800b25:	b8 01 00 00 00       	mov    $0x1,%eax
  800b2a:	89 d1                	mov    %edx,%ecx
  800b2c:	89 d3                	mov    %edx,%ebx
  800b2e:	89 d7                	mov    %edx,%edi
  800b30:	89 d6                	mov    %edx,%esi
  800b32:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b34:	5b                   	pop    %ebx
  800b35:	5e                   	pop    %esi
  800b36:	5f                   	pop    %edi
  800b37:	5d                   	pop    %ebp
  800b38:	c3                   	ret    

00800b39 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	57                   	push   %edi
  800b3d:	56                   	push   %esi
  800b3e:	53                   	push   %ebx
  800b3f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b42:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b47:	b8 03 00 00 00       	mov    $0x3,%eax
  800b4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4f:	89 cb                	mov    %ecx,%ebx
  800b51:	89 cf                	mov    %ecx,%edi
  800b53:	89 ce                	mov    %ecx,%esi
  800b55:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b57:	85 c0                	test   %eax,%eax
  800b59:	7e 17                	jle    800b72 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5b:	83 ec 0c             	sub    $0xc,%esp
  800b5e:	50                   	push   %eax
  800b5f:	6a 03                	push   $0x3
  800b61:	68 bf 24 80 00       	push   $0x8024bf
  800b66:	6a 23                	push   $0x23
  800b68:	68 dc 24 80 00       	push   $0x8024dc
  800b6d:	e8 79 12 00 00       	call   801deb <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b72:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b75:	5b                   	pop    %ebx
  800b76:	5e                   	pop    %esi
  800b77:	5f                   	pop    %edi
  800b78:	5d                   	pop    %ebp
  800b79:	c3                   	ret    

00800b7a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	57                   	push   %edi
  800b7e:	56                   	push   %esi
  800b7f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b80:	ba 00 00 00 00       	mov    $0x0,%edx
  800b85:	b8 02 00 00 00       	mov    $0x2,%eax
  800b8a:	89 d1                	mov    %edx,%ecx
  800b8c:	89 d3                	mov    %edx,%ebx
  800b8e:	89 d7                	mov    %edx,%edi
  800b90:	89 d6                	mov    %edx,%esi
  800b92:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b94:	5b                   	pop    %ebx
  800b95:	5e                   	pop    %esi
  800b96:	5f                   	pop    %edi
  800b97:	5d                   	pop    %ebp
  800b98:	c3                   	ret    

00800b99 <sys_yield>:

void
sys_yield(void)
{
  800b99:	55                   	push   %ebp
  800b9a:	89 e5                	mov    %esp,%ebp
  800b9c:	57                   	push   %edi
  800b9d:	56                   	push   %esi
  800b9e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9f:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ba9:	89 d1                	mov    %edx,%ecx
  800bab:	89 d3                	mov    %edx,%ebx
  800bad:	89 d7                	mov    %edx,%edi
  800baf:	89 d6                	mov    %edx,%esi
  800bb1:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bb3:	5b                   	pop    %ebx
  800bb4:	5e                   	pop    %esi
  800bb5:	5f                   	pop    %edi
  800bb6:	5d                   	pop    %ebp
  800bb7:	c3                   	ret    

00800bb8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	57                   	push   %edi
  800bbc:	56                   	push   %esi
  800bbd:	53                   	push   %ebx
  800bbe:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc1:	be 00 00 00 00       	mov    $0x0,%esi
  800bc6:	b8 04 00 00 00       	mov    $0x4,%eax
  800bcb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bce:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd4:	89 f7                	mov    %esi,%edi
  800bd6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bd8:	85 c0                	test   %eax,%eax
  800bda:	7e 17                	jle    800bf3 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdc:	83 ec 0c             	sub    $0xc,%esp
  800bdf:	50                   	push   %eax
  800be0:	6a 04                	push   $0x4
  800be2:	68 bf 24 80 00       	push   $0x8024bf
  800be7:	6a 23                	push   $0x23
  800be9:	68 dc 24 80 00       	push   $0x8024dc
  800bee:	e8 f8 11 00 00       	call   801deb <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bf3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf6:	5b                   	pop    %ebx
  800bf7:	5e                   	pop    %esi
  800bf8:	5f                   	pop    %edi
  800bf9:	5d                   	pop    %ebp
  800bfa:	c3                   	ret    

00800bfb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	57                   	push   %edi
  800bff:	56                   	push   %esi
  800c00:	53                   	push   %ebx
  800c01:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c04:	b8 05 00 00 00       	mov    $0x5,%eax
  800c09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c12:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c15:	8b 75 18             	mov    0x18(%ebp),%esi
  800c18:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c1a:	85 c0                	test   %eax,%eax
  800c1c:	7e 17                	jle    800c35 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1e:	83 ec 0c             	sub    $0xc,%esp
  800c21:	50                   	push   %eax
  800c22:	6a 05                	push   $0x5
  800c24:	68 bf 24 80 00       	push   $0x8024bf
  800c29:	6a 23                	push   $0x23
  800c2b:	68 dc 24 80 00       	push   $0x8024dc
  800c30:	e8 b6 11 00 00       	call   801deb <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c38:	5b                   	pop    %ebx
  800c39:	5e                   	pop    %esi
  800c3a:	5f                   	pop    %edi
  800c3b:	5d                   	pop    %ebp
  800c3c:	c3                   	ret    

00800c3d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c3d:	55                   	push   %ebp
  800c3e:	89 e5                	mov    %esp,%ebp
  800c40:	57                   	push   %edi
  800c41:	56                   	push   %esi
  800c42:	53                   	push   %ebx
  800c43:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c46:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4b:	b8 06 00 00 00       	mov    $0x6,%eax
  800c50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c53:	8b 55 08             	mov    0x8(%ebp),%edx
  800c56:	89 df                	mov    %ebx,%edi
  800c58:	89 de                	mov    %ebx,%esi
  800c5a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c5c:	85 c0                	test   %eax,%eax
  800c5e:	7e 17                	jle    800c77 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c60:	83 ec 0c             	sub    $0xc,%esp
  800c63:	50                   	push   %eax
  800c64:	6a 06                	push   $0x6
  800c66:	68 bf 24 80 00       	push   $0x8024bf
  800c6b:	6a 23                	push   $0x23
  800c6d:	68 dc 24 80 00       	push   $0x8024dc
  800c72:	e8 74 11 00 00       	call   801deb <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7a:	5b                   	pop    %ebx
  800c7b:	5e                   	pop    %esi
  800c7c:	5f                   	pop    %edi
  800c7d:	5d                   	pop    %ebp
  800c7e:	c3                   	ret    

00800c7f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c7f:	55                   	push   %ebp
  800c80:	89 e5                	mov    %esp,%ebp
  800c82:	57                   	push   %edi
  800c83:	56                   	push   %esi
  800c84:	53                   	push   %ebx
  800c85:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c88:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8d:	b8 08 00 00 00       	mov    $0x8,%eax
  800c92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c95:	8b 55 08             	mov    0x8(%ebp),%edx
  800c98:	89 df                	mov    %ebx,%edi
  800c9a:	89 de                	mov    %ebx,%esi
  800c9c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c9e:	85 c0                	test   %eax,%eax
  800ca0:	7e 17                	jle    800cb9 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca2:	83 ec 0c             	sub    $0xc,%esp
  800ca5:	50                   	push   %eax
  800ca6:	6a 08                	push   $0x8
  800ca8:	68 bf 24 80 00       	push   $0x8024bf
  800cad:	6a 23                	push   $0x23
  800caf:	68 dc 24 80 00       	push   $0x8024dc
  800cb4:	e8 32 11 00 00       	call   801deb <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbc:	5b                   	pop    %ebx
  800cbd:	5e                   	pop    %esi
  800cbe:	5f                   	pop    %edi
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    

00800cc1 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	57                   	push   %edi
  800cc5:	56                   	push   %esi
  800cc6:	53                   	push   %ebx
  800cc7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cca:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ccf:	b8 09 00 00 00       	mov    $0x9,%eax
  800cd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cda:	89 df                	mov    %ebx,%edi
  800cdc:	89 de                	mov    %ebx,%esi
  800cde:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ce0:	85 c0                	test   %eax,%eax
  800ce2:	7e 17                	jle    800cfb <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce4:	83 ec 0c             	sub    $0xc,%esp
  800ce7:	50                   	push   %eax
  800ce8:	6a 09                	push   $0x9
  800cea:	68 bf 24 80 00       	push   $0x8024bf
  800cef:	6a 23                	push   $0x23
  800cf1:	68 dc 24 80 00       	push   $0x8024dc
  800cf6:	e8 f0 10 00 00       	call   801deb <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfe:	5b                   	pop    %ebx
  800cff:	5e                   	pop    %esi
  800d00:	5f                   	pop    %edi
  800d01:	5d                   	pop    %ebp
  800d02:	c3                   	ret    

00800d03 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d03:	55                   	push   %ebp
  800d04:	89 e5                	mov    %esp,%ebp
  800d06:	57                   	push   %edi
  800d07:	56                   	push   %esi
  800d08:	53                   	push   %ebx
  800d09:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d11:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d19:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1c:	89 df                	mov    %ebx,%edi
  800d1e:	89 de                	mov    %ebx,%esi
  800d20:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d22:	85 c0                	test   %eax,%eax
  800d24:	7e 17                	jle    800d3d <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d26:	83 ec 0c             	sub    $0xc,%esp
  800d29:	50                   	push   %eax
  800d2a:	6a 0a                	push   $0xa
  800d2c:	68 bf 24 80 00       	push   $0x8024bf
  800d31:	6a 23                	push   $0x23
  800d33:	68 dc 24 80 00       	push   $0x8024dc
  800d38:	e8 ae 10 00 00       	call   801deb <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d40:	5b                   	pop    %ebx
  800d41:	5e                   	pop    %esi
  800d42:	5f                   	pop    %edi
  800d43:	5d                   	pop    %ebp
  800d44:	c3                   	ret    

00800d45 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d45:	55                   	push   %ebp
  800d46:	89 e5                	mov    %esp,%ebp
  800d48:	57                   	push   %edi
  800d49:	56                   	push   %esi
  800d4a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4b:	be 00 00 00 00       	mov    $0x0,%esi
  800d50:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d58:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d5e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d61:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d63:	5b                   	pop    %ebx
  800d64:	5e                   	pop    %esi
  800d65:	5f                   	pop    %edi
  800d66:	5d                   	pop    %ebp
  800d67:	c3                   	ret    

00800d68 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d68:	55                   	push   %ebp
  800d69:	89 e5                	mov    %esp,%ebp
  800d6b:	57                   	push   %edi
  800d6c:	56                   	push   %esi
  800d6d:	53                   	push   %ebx
  800d6e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d71:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d76:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7e:	89 cb                	mov    %ecx,%ebx
  800d80:	89 cf                	mov    %ecx,%edi
  800d82:	89 ce                	mov    %ecx,%esi
  800d84:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d86:	85 c0                	test   %eax,%eax
  800d88:	7e 17                	jle    800da1 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8a:	83 ec 0c             	sub    $0xc,%esp
  800d8d:	50                   	push   %eax
  800d8e:	6a 0d                	push   $0xd
  800d90:	68 bf 24 80 00       	push   $0x8024bf
  800d95:	6a 23                	push   $0x23
  800d97:	68 dc 24 80 00       	push   $0x8024dc
  800d9c:	e8 4a 10 00 00       	call   801deb <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800da1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da4:	5b                   	pop    %ebx
  800da5:	5e                   	pop    %esi
  800da6:	5f                   	pop    %edi
  800da7:	5d                   	pop    %ebp
  800da8:	c3                   	ret    

00800da9 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800da9:	55                   	push   %ebp
  800daa:	89 e5                	mov    %esp,%ebp
  800dac:	57                   	push   %edi
  800dad:	56                   	push   %esi
  800dae:	53                   	push   %ebx
  800daf:	83 ec 0c             	sub    $0xc,%esp
  800db2:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800db5:	8b 18                	mov    (%eax),%ebx
	uint32_t err = utf->utf_err;
  800db7:	8b 78 04             	mov    0x4(%eax),%edi
	int r;
	envid_t curenvid = sys_getenvid();
  800dba:	e8 bb fd ff ff       	call   800b7a <sys_getenvid>
  800dbf:	89 c6                	mov    %eax,%esi
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(err & FEC_WR) && !(uvpt[PGNUM(addr)] & PTE_COW))
  800dc1:	f7 c7 02 00 00 00    	test   $0x2,%edi
  800dc7:	75 25                	jne    800dee <pgfault+0x45>
  800dc9:	89 d8                	mov    %ebx,%eax
  800dcb:	c1 e8 0c             	shr    $0xc,%eax
  800dce:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dd5:	f6 c4 08             	test   $0x8,%ah
  800dd8:	75 14                	jne    800dee <pgfault+0x45>
	    panic("pgfault error: wrong faulting access");
  800dda:	83 ec 04             	sub    $0x4,%esp
  800ddd:	68 ec 24 80 00       	push   $0x8024ec
  800de2:	6a 1e                	push   $0x1e
  800de4:	68 11 25 80 00       	push   $0x802511
  800de9:	e8 fd 0f 00 00       	call   801deb <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	sys_page_alloc(curenvid, PFTEMP, PTE_W | PTE_U | PTE_P);
  800dee:	83 ec 04             	sub    $0x4,%esp
  800df1:	6a 07                	push   $0x7
  800df3:	68 00 f0 7f 00       	push   $0x7ff000
  800df8:	56                   	push   %esi
  800df9:	e8 ba fd ff ff       	call   800bb8 <sys_page_alloc>

	addr = (void *)(PGNUM(addr) * PGSIZE);
  800dfe:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr, PGSIZE);
  800e04:	83 c4 0c             	add    $0xc,%esp
  800e07:	68 00 10 00 00       	push   $0x1000
  800e0c:	53                   	push   %ebx
  800e0d:	68 00 f0 7f 00       	push   $0x7ff000
  800e12:	e8 30 fb ff ff       	call   800947 <memmove>

	sys_page_unmap(curenvid, addr);
  800e17:	83 c4 08             	add    $0x8,%esp
  800e1a:	53                   	push   %ebx
  800e1b:	56                   	push   %esi
  800e1c:	e8 1c fe ff ff       	call   800c3d <sys_page_unmap>
	sys_page_map(curenvid, PFTEMP, curenvid, addr, PTE_W | PTE_U | PTE_P);
  800e21:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e28:	53                   	push   %ebx
  800e29:	56                   	push   %esi
  800e2a:	68 00 f0 7f 00       	push   $0x7ff000
  800e2f:	56                   	push   %esi
  800e30:	e8 c6 fd ff ff       	call   800bfb <sys_page_map>
	sys_page_unmap(curenvid, PFTEMP);
  800e35:	83 c4 18             	add    $0x18,%esp
  800e38:	68 00 f0 7f 00       	push   $0x7ff000
  800e3d:	56                   	push   %esi
  800e3e:	e8 fa fd ff ff       	call   800c3d <sys_page_unmap>
}
  800e43:	83 c4 10             	add    $0x10,%esp
  800e46:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e49:	5b                   	pop    %ebx
  800e4a:	5e                   	pop    %esi
  800e4b:	5f                   	pop    %edi
  800e4c:	5d                   	pop    %ebp
  800e4d:	c3                   	ret    

00800e4e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e4e:	55                   	push   %ebp
  800e4f:	89 e5                	mov    %esp,%ebp
  800e51:	57                   	push   %edi
  800e52:	56                   	push   %esi
  800e53:	53                   	push   %ebx
  800e54:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	extern void _pgfault_upcall();
	envid_t new_envid, curenv_id;

	curenv_id = sys_getenvid();
  800e57:	e8 1e fd ff ff       	call   800b7a <sys_getenvid>
	set_pgfault_handler(pgfault);
  800e5c:	83 ec 0c             	sub    $0xc,%esp
  800e5f:	68 a9 0d 80 00       	push   $0x800da9
  800e64:	e8 c8 0f 00 00       	call   801e31 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800e69:	b8 07 00 00 00       	mov    $0x7,%eax
  800e6e:	cd 30                	int    $0x30
  800e70:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800e73:	89 45 dc             	mov    %eax,-0x24(%ebp)
	new_envid = sys_exofork();

	if (new_envid < 0)
  800e76:	83 c4 10             	add    $0x10,%esp
  800e79:	85 c0                	test   %eax,%eax
  800e7b:	79 12                	jns    800e8f <fork+0x41>
	    panic("fork error: %e", new_envid);
  800e7d:	50                   	push   %eax
  800e7e:	68 1c 25 80 00       	push   $0x80251c
  800e83:	6a 75                	push   $0x75
  800e85:	68 11 25 80 00       	push   $0x802511
  800e8a:	e8 5c 0f 00 00       	call   801deb <_panic>
  800e8f:	bf 00 00 80 00       	mov    $0x800000,%edi
	else if (new_envid == 0)
  800e94:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800e98:	75 1c                	jne    800eb6 <fork+0x68>
		thisenv = envs + ENVX(sys_getenvid());
  800e9a:	e8 db fc ff ff       	call   800b7a <sys_getenvid>
  800e9f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ea4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ea7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800eac:	a3 04 40 80 00       	mov    %eax,0x804004
  800eb1:	e9 27 01 00 00       	jmp    800fdd <fork+0x18f>
	else {

		for (uint32_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
			if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
  800eb6:	89 f8                	mov    %edi,%eax
  800eb8:	c1 e8 16             	shr    $0x16,%eax
  800ebb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ec2:	a8 01                	test   $0x1,%al
  800ec4:	0f 84 d2 00 00 00    	je     800f9c <fork+0x14e>
  800eca:	89 fb                	mov    %edi,%ebx
  800ecc:	c1 eb 0c             	shr    $0xc,%ebx
  800ecf:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800ed6:	a8 01                	test   $0x1,%al
  800ed8:	0f 84 be 00 00 00    	je     800f9c <fork+0x14e>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	int perm = PTE_U | PTE_P;
	envid_t curenvid = sys_getenvid();
  800ede:	e8 97 fc ff ff       	call   800b7a <sys_getenvid>
  800ee3:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  800ee6:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
		perm |= PTE_COW ;
  800eed:	be 05 08 00 00       	mov    $0x805,%esi
	int r;
	int perm = PTE_U | PTE_P;
	envid_t curenvid = sys_getenvid();

	// LAB 4: Your code here.
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  800ef2:	a8 02                	test   $0x2,%al
  800ef4:	75 1d                	jne    800f13 <fork+0xc5>
  800ef6:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800efd:	25 00 08 00 00       	and    $0x800,%eax
		perm |= PTE_COW ;
  800f02:	83 f8 01             	cmp    $0x1,%eax
  800f05:	19 f6                	sbb    %esi,%esi
  800f07:	81 e6 00 f8 ff ff    	and    $0xfffff800,%esi
  800f0d:	81 c6 05 08 00 00    	add    $0x805,%esi

	if (uvpt[pn] & PTE_SHARE)
  800f13:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f1a:	25 00 04 00 00       	and    $0x400,%eax
		perm |= PTE_SYSCALL;
  800f1f:	b8 07 0e 00 00       	mov    $0xe07,%eax
  800f24:	0f 45 f0             	cmovne %eax,%esi

	r = sys_page_map(curenvid, (void *)(pn * PGSIZE),
  800f27:	89 d8                	mov    %ebx,%eax
  800f29:	c1 e0 0c             	shl    $0xc,%eax
  800f2c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f2f:	83 ec 0c             	sub    $0xc,%esp
  800f32:	56                   	push   %esi
  800f33:	50                   	push   %eax
  800f34:	ff 75 dc             	pushl  -0x24(%ebp)
  800f37:	50                   	push   %eax
  800f38:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f3b:	e8 bb fc ff ff       	call   800bfb <sys_page_map>
				envid, (void *)(pn * PGSIZE), perm);
	if (r < 0)
  800f40:	83 c4 20             	add    $0x20,%esp
  800f43:	85 c0                	test   %eax,%eax
  800f45:	79 12                	jns    800f59 <fork+0x10b>
		panic("duppage error: %e", r);
  800f47:	50                   	push   %eax
  800f48:	68 2b 25 80 00       	push   $0x80252b
  800f4d:	6a 4d                	push   $0x4d
  800f4f:	68 11 25 80 00       	push   $0x802511
  800f54:	e8 92 0e 00 00       	call   801deb <_panic>
	
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))	{
  800f59:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f60:	a8 02                	test   $0x2,%al
  800f62:	75 0c                	jne    800f70 <fork+0x122>
  800f64:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f6b:	f6 c4 08             	test   $0x8,%ah
  800f6e:	74 2c                	je     800f9c <fork+0x14e>
		r = sys_page_map(curenvid, (void *)(pn * PGSIZE),
  800f70:	83 ec 0c             	sub    $0xc,%esp
  800f73:	56                   	push   %esi
  800f74:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800f77:	52                   	push   %edx
  800f78:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f7b:	50                   	push   %eax
  800f7c:	52                   	push   %edx
  800f7d:	50                   	push   %eax
  800f7e:	e8 78 fc ff ff       	call   800bfb <sys_page_map>
						curenvid, (void *)(pn * PGSIZE), perm);
		if (r < 0)
  800f83:	83 c4 20             	add    $0x20,%esp
  800f86:	85 c0                	test   %eax,%eax
  800f88:	79 12                	jns    800f9c <fork+0x14e>
			panic("duppage error: %e", r);
  800f8a:	50                   	push   %eax
  800f8b:	68 2b 25 80 00       	push   $0x80252b
  800f90:	6a 53                	push   $0x53
  800f92:	68 11 25 80 00       	push   $0x802511
  800f97:	e8 4f 0e 00 00       	call   801deb <_panic>
	    panic("fork error: %e", new_envid);
	else if (new_envid == 0)
		thisenv = envs + ENVX(sys_getenvid());
	else {

		for (uint32_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
  800f9c:	81 c7 00 10 00 00    	add    $0x1000,%edi
  800fa2:	81 ff 00 e0 bf ee    	cmp    $0xeebfe000,%edi
  800fa8:	0f 85 08 ff ff ff    	jne    800eb6 <fork+0x68>
			if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
				duppage(new_envid, PGNUM(addr));
		}

		sys_page_alloc(new_envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  800fae:	83 ec 04             	sub    $0x4,%esp
  800fb1:	6a 07                	push   $0x7
  800fb3:	68 00 f0 bf ee       	push   $0xeebff000
  800fb8:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800fbb:	56                   	push   %esi
  800fbc:	e8 f7 fb ff ff       	call   800bb8 <sys_page_alloc>
		sys_env_set_pgfault_upcall(new_envid, _pgfault_upcall);
  800fc1:	83 c4 08             	add    $0x8,%esp
  800fc4:	68 76 1e 80 00       	push   $0x801e76
  800fc9:	56                   	push   %esi
  800fca:	e8 34 fd ff ff       	call   800d03 <sys_env_set_pgfault_upcall>
		sys_env_set_status(new_envid, ENV_RUNNABLE);
  800fcf:	83 c4 08             	add    $0x8,%esp
  800fd2:	6a 02                	push   $0x2
  800fd4:	56                   	push   %esi
  800fd5:	e8 a5 fc ff ff       	call   800c7f <sys_env_set_status>
  800fda:	83 c4 10             	add    $0x10,%esp

	}
	return new_envid;
}
  800fdd:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800fe0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fe3:	5b                   	pop    %ebx
  800fe4:	5e                   	pop    %esi
  800fe5:	5f                   	pop    %edi
  800fe6:	5d                   	pop    %ebp
  800fe7:	c3                   	ret    

00800fe8 <sfork>:

// Challenge!
int
sfork(void)
{
  800fe8:	55                   	push   %ebp
  800fe9:	89 e5                	mov    %esp,%ebp
  800feb:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  800fee:	68 3d 25 80 00       	push   $0x80253d
  800ff3:	68 8b 00 00 00       	push   $0x8b
  800ff8:	68 11 25 80 00       	push   $0x802511
  800ffd:	e8 e9 0d 00 00       	call   801deb <_panic>

00801002 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801002:	55                   	push   %ebp
  801003:	89 e5                	mov    %esp,%ebp
  801005:	56                   	push   %esi
  801006:	53                   	push   %ebx
  801007:	8b 75 08             	mov    0x8(%ebp),%esi
  80100a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80100d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

    if (pg != NULL)
  801010:	85 c0                	test   %eax,%eax
  801012:	74 0e                	je     801022 <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  801014:	83 ec 0c             	sub    $0xc,%esp
  801017:	50                   	push   %eax
  801018:	e8 4b fd ff ff       	call   800d68 <sys_ipc_recv>
  80101d:	83 c4 10             	add    $0x10,%esp
  801020:	eb 0d                	jmp    80102f <ipc_recv+0x2d>
	else
        r = sys_ipc_recv((void *)-1);
  801022:	83 ec 0c             	sub    $0xc,%esp
  801025:	6a ff                	push   $0xffffffff
  801027:	e8 3c fd ff ff       	call   800d68 <sys_ipc_recv>
  80102c:	83 c4 10             	add    $0x10,%esp

	if (r < 0) {
  80102f:	85 c0                	test   %eax,%eax
  801031:	79 16                	jns    801049 <ipc_recv+0x47>

		if (from_env_store != NULL)
  801033:	85 f6                	test   %esi,%esi
  801035:	74 06                	je     80103d <ipc_recv+0x3b>
			*from_env_store = 0;
  801037:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL)
  80103d:	85 db                	test   %ebx,%ebx
  80103f:	74 2c                	je     80106d <ipc_recv+0x6b>
			*perm_store = 0;
  801041:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801047:	eb 24                	jmp    80106d <ipc_recv+0x6b>
		return r;

	} else {

		if (from_env_store != NULL)
  801049:	85 f6                	test   %esi,%esi
  80104b:	74 0a                	je     801057 <ipc_recv+0x55>
			*from_env_store = thisenv->env_ipc_from;
  80104d:	a1 04 40 80 00       	mov    0x804004,%eax
  801052:	8b 40 74             	mov    0x74(%eax),%eax
  801055:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL)
  801057:	85 db                	test   %ebx,%ebx
  801059:	74 0a                	je     801065 <ipc_recv+0x63>
			*perm_store = thisenv->env_ipc_perm;
  80105b:	a1 04 40 80 00       	mov    0x804004,%eax
  801060:	8b 40 78             	mov    0x78(%eax),%eax
  801063:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801065:	a1 04 40 80 00       	mov    0x804004,%eax
  80106a:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  80106d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801070:	5b                   	pop    %ebx
  801071:	5e                   	pop    %esi
  801072:	5d                   	pop    %ebp
  801073:	c3                   	ret    

00801074 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801074:	55                   	push   %ebp
  801075:	89 e5                	mov    %esp,%ebp
  801077:	57                   	push   %edi
  801078:	56                   	push   %esi
  801079:	53                   	push   %ebx
  80107a:	83 ec 0c             	sub    $0xc,%esp
  80107d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801080:	8b 75 0c             	mov    0xc(%ebp),%esi
  801083:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

	if (pg == NULL)
  801086:	85 db                	test   %ebx,%ebx
		pg = (void *)-1;	
  801088:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80108d:	0f 44 d8             	cmove  %eax,%ebx

	while (true) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801090:	ff 75 14             	pushl  0x14(%ebp)
  801093:	53                   	push   %ebx
  801094:	56                   	push   %esi
  801095:	57                   	push   %edi
  801096:	e8 aa fc ff ff       	call   800d45 <sys_ipc_try_send>
		if (r >= 0)
  80109b:	83 c4 10             	add    $0x10,%esp
  80109e:	85 c0                	test   %eax,%eax
  8010a0:	79 1e                	jns    8010c0 <ipc_send+0x4c>
			return;
		else if (r != -E_IPC_NOT_RECV)
  8010a2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8010a5:	74 12                	je     8010b9 <ipc_send+0x45>
			panic("ipc_send error: %e", r);
  8010a7:	50                   	push   %eax
  8010a8:	68 53 25 80 00       	push   $0x802553
  8010ad:	6a 49                	push   $0x49
  8010af:	68 66 25 80 00       	push   $0x802566
  8010b4:	e8 32 0d 00 00       	call   801deb <_panic>
	
		sys_yield();
  8010b9:	e8 db fa ff ff       	call   800b99 <sys_yield>
	}
  8010be:	eb d0                	jmp    801090 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  8010c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010c3:	5b                   	pop    %ebx
  8010c4:	5e                   	pop    %esi
  8010c5:	5f                   	pop    %edi
  8010c6:	5d                   	pop    %ebp
  8010c7:	c3                   	ret    

008010c8 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8010c8:	55                   	push   %ebp
  8010c9:	89 e5                	mov    %esp,%ebp
  8010cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8010ce:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8010d3:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8010d6:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8010dc:	8b 52 50             	mov    0x50(%edx),%edx
  8010df:	39 ca                	cmp    %ecx,%edx
  8010e1:	75 0d                	jne    8010f0 <ipc_find_env+0x28>
			return envs[i].env_id;
  8010e3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010e6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010eb:	8b 40 48             	mov    0x48(%eax),%eax
  8010ee:	eb 0f                	jmp    8010ff <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8010f0:	83 c0 01             	add    $0x1,%eax
  8010f3:	3d 00 04 00 00       	cmp    $0x400,%eax
  8010f8:	75 d9                	jne    8010d3 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8010fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010ff:	5d                   	pop    %ebp
  801100:	c3                   	ret    

00801101 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801101:	55                   	push   %ebp
  801102:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801104:	8b 45 08             	mov    0x8(%ebp),%eax
  801107:	05 00 00 00 30       	add    $0x30000000,%eax
  80110c:	c1 e8 0c             	shr    $0xc,%eax
}
  80110f:	5d                   	pop    %ebp
  801110:	c3                   	ret    

00801111 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801111:	55                   	push   %ebp
  801112:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801114:	8b 45 08             	mov    0x8(%ebp),%eax
  801117:	05 00 00 00 30       	add    $0x30000000,%eax
  80111c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801121:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801126:	5d                   	pop    %ebp
  801127:	c3                   	ret    

00801128 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801128:	55                   	push   %ebp
  801129:	89 e5                	mov    %esp,%ebp
  80112b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80112e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801133:	89 c2                	mov    %eax,%edx
  801135:	c1 ea 16             	shr    $0x16,%edx
  801138:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80113f:	f6 c2 01             	test   $0x1,%dl
  801142:	74 11                	je     801155 <fd_alloc+0x2d>
  801144:	89 c2                	mov    %eax,%edx
  801146:	c1 ea 0c             	shr    $0xc,%edx
  801149:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801150:	f6 c2 01             	test   $0x1,%dl
  801153:	75 09                	jne    80115e <fd_alloc+0x36>
			*fd_store = fd;
  801155:	89 01                	mov    %eax,(%ecx)
			return 0;
  801157:	b8 00 00 00 00       	mov    $0x0,%eax
  80115c:	eb 17                	jmp    801175 <fd_alloc+0x4d>
  80115e:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801163:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801168:	75 c9                	jne    801133 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80116a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801170:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801175:	5d                   	pop    %ebp
  801176:	c3                   	ret    

00801177 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801177:	55                   	push   %ebp
  801178:	89 e5                	mov    %esp,%ebp
  80117a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80117d:	83 f8 1f             	cmp    $0x1f,%eax
  801180:	77 36                	ja     8011b8 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801182:	c1 e0 0c             	shl    $0xc,%eax
  801185:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80118a:	89 c2                	mov    %eax,%edx
  80118c:	c1 ea 16             	shr    $0x16,%edx
  80118f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801196:	f6 c2 01             	test   $0x1,%dl
  801199:	74 24                	je     8011bf <fd_lookup+0x48>
  80119b:	89 c2                	mov    %eax,%edx
  80119d:	c1 ea 0c             	shr    $0xc,%edx
  8011a0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011a7:	f6 c2 01             	test   $0x1,%dl
  8011aa:	74 1a                	je     8011c6 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011af:	89 02                	mov    %eax,(%edx)
	return 0;
  8011b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b6:	eb 13                	jmp    8011cb <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011b8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011bd:	eb 0c                	jmp    8011cb <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011c4:	eb 05                	jmp    8011cb <fd_lookup+0x54>
  8011c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011cb:	5d                   	pop    %ebp
  8011cc:	c3                   	ret    

008011cd <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011cd:	55                   	push   %ebp
  8011ce:	89 e5                	mov    %esp,%ebp
  8011d0:	83 ec 08             	sub    $0x8,%esp
  8011d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011d6:	ba ec 25 80 00       	mov    $0x8025ec,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011db:	eb 13                	jmp    8011f0 <dev_lookup+0x23>
  8011dd:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011e0:	39 08                	cmp    %ecx,(%eax)
  8011e2:	75 0c                	jne    8011f0 <dev_lookup+0x23>
			*dev = devtab[i];
  8011e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011e7:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8011ee:	eb 2e                	jmp    80121e <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011f0:	8b 02                	mov    (%edx),%eax
  8011f2:	85 c0                	test   %eax,%eax
  8011f4:	75 e7                	jne    8011dd <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011f6:	a1 04 40 80 00       	mov    0x804004,%eax
  8011fb:	8b 40 48             	mov    0x48(%eax),%eax
  8011fe:	83 ec 04             	sub    $0x4,%esp
  801201:	51                   	push   %ecx
  801202:	50                   	push   %eax
  801203:	68 70 25 80 00       	push   $0x802570
  801208:	e8 a4 ef ff ff       	call   8001b1 <cprintf>
	*dev = 0;
  80120d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801210:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801216:	83 c4 10             	add    $0x10,%esp
  801219:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80121e:	c9                   	leave  
  80121f:	c3                   	ret    

00801220 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801220:	55                   	push   %ebp
  801221:	89 e5                	mov    %esp,%ebp
  801223:	56                   	push   %esi
  801224:	53                   	push   %ebx
  801225:	83 ec 10             	sub    $0x10,%esp
  801228:	8b 75 08             	mov    0x8(%ebp),%esi
  80122b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80122e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801231:	50                   	push   %eax
  801232:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801238:	c1 e8 0c             	shr    $0xc,%eax
  80123b:	50                   	push   %eax
  80123c:	e8 36 ff ff ff       	call   801177 <fd_lookup>
  801241:	83 c4 08             	add    $0x8,%esp
  801244:	85 c0                	test   %eax,%eax
  801246:	78 05                	js     80124d <fd_close+0x2d>
	    || fd != fd2)
  801248:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80124b:	74 0c                	je     801259 <fd_close+0x39>
		return (must_exist ? r : 0);
  80124d:	84 db                	test   %bl,%bl
  80124f:	ba 00 00 00 00       	mov    $0x0,%edx
  801254:	0f 44 c2             	cmove  %edx,%eax
  801257:	eb 41                	jmp    80129a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801259:	83 ec 08             	sub    $0x8,%esp
  80125c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80125f:	50                   	push   %eax
  801260:	ff 36                	pushl  (%esi)
  801262:	e8 66 ff ff ff       	call   8011cd <dev_lookup>
  801267:	89 c3                	mov    %eax,%ebx
  801269:	83 c4 10             	add    $0x10,%esp
  80126c:	85 c0                	test   %eax,%eax
  80126e:	78 1a                	js     80128a <fd_close+0x6a>
		if (dev->dev_close)
  801270:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801273:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801276:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80127b:	85 c0                	test   %eax,%eax
  80127d:	74 0b                	je     80128a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80127f:	83 ec 0c             	sub    $0xc,%esp
  801282:	56                   	push   %esi
  801283:	ff d0                	call   *%eax
  801285:	89 c3                	mov    %eax,%ebx
  801287:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80128a:	83 ec 08             	sub    $0x8,%esp
  80128d:	56                   	push   %esi
  80128e:	6a 00                	push   $0x0
  801290:	e8 a8 f9 ff ff       	call   800c3d <sys_page_unmap>
	return r;
  801295:	83 c4 10             	add    $0x10,%esp
  801298:	89 d8                	mov    %ebx,%eax
}
  80129a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80129d:	5b                   	pop    %ebx
  80129e:	5e                   	pop    %esi
  80129f:	5d                   	pop    %ebp
  8012a0:	c3                   	ret    

008012a1 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012a1:	55                   	push   %ebp
  8012a2:	89 e5                	mov    %esp,%ebp
  8012a4:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012aa:	50                   	push   %eax
  8012ab:	ff 75 08             	pushl  0x8(%ebp)
  8012ae:	e8 c4 fe ff ff       	call   801177 <fd_lookup>
  8012b3:	83 c4 08             	add    $0x8,%esp
  8012b6:	85 c0                	test   %eax,%eax
  8012b8:	78 10                	js     8012ca <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012ba:	83 ec 08             	sub    $0x8,%esp
  8012bd:	6a 01                	push   $0x1
  8012bf:	ff 75 f4             	pushl  -0xc(%ebp)
  8012c2:	e8 59 ff ff ff       	call   801220 <fd_close>
  8012c7:	83 c4 10             	add    $0x10,%esp
}
  8012ca:	c9                   	leave  
  8012cb:	c3                   	ret    

008012cc <close_all>:

void
close_all(void)
{
  8012cc:	55                   	push   %ebp
  8012cd:	89 e5                	mov    %esp,%ebp
  8012cf:	53                   	push   %ebx
  8012d0:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012d3:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012d8:	83 ec 0c             	sub    $0xc,%esp
  8012db:	53                   	push   %ebx
  8012dc:	e8 c0 ff ff ff       	call   8012a1 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012e1:	83 c3 01             	add    $0x1,%ebx
  8012e4:	83 c4 10             	add    $0x10,%esp
  8012e7:	83 fb 20             	cmp    $0x20,%ebx
  8012ea:	75 ec                	jne    8012d8 <close_all+0xc>
		close(i);
}
  8012ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012ef:	c9                   	leave  
  8012f0:	c3                   	ret    

008012f1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012f1:	55                   	push   %ebp
  8012f2:	89 e5                	mov    %esp,%ebp
  8012f4:	57                   	push   %edi
  8012f5:	56                   	push   %esi
  8012f6:	53                   	push   %ebx
  8012f7:	83 ec 2c             	sub    $0x2c,%esp
  8012fa:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012fd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801300:	50                   	push   %eax
  801301:	ff 75 08             	pushl  0x8(%ebp)
  801304:	e8 6e fe ff ff       	call   801177 <fd_lookup>
  801309:	83 c4 08             	add    $0x8,%esp
  80130c:	85 c0                	test   %eax,%eax
  80130e:	0f 88 c1 00 00 00    	js     8013d5 <dup+0xe4>
		return r;
	close(newfdnum);
  801314:	83 ec 0c             	sub    $0xc,%esp
  801317:	56                   	push   %esi
  801318:	e8 84 ff ff ff       	call   8012a1 <close>

	newfd = INDEX2FD(newfdnum);
  80131d:	89 f3                	mov    %esi,%ebx
  80131f:	c1 e3 0c             	shl    $0xc,%ebx
  801322:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801328:	83 c4 04             	add    $0x4,%esp
  80132b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80132e:	e8 de fd ff ff       	call   801111 <fd2data>
  801333:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801335:	89 1c 24             	mov    %ebx,(%esp)
  801338:	e8 d4 fd ff ff       	call   801111 <fd2data>
  80133d:	83 c4 10             	add    $0x10,%esp
  801340:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801343:	89 f8                	mov    %edi,%eax
  801345:	c1 e8 16             	shr    $0x16,%eax
  801348:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80134f:	a8 01                	test   $0x1,%al
  801351:	74 37                	je     80138a <dup+0x99>
  801353:	89 f8                	mov    %edi,%eax
  801355:	c1 e8 0c             	shr    $0xc,%eax
  801358:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80135f:	f6 c2 01             	test   $0x1,%dl
  801362:	74 26                	je     80138a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801364:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80136b:	83 ec 0c             	sub    $0xc,%esp
  80136e:	25 07 0e 00 00       	and    $0xe07,%eax
  801373:	50                   	push   %eax
  801374:	ff 75 d4             	pushl  -0x2c(%ebp)
  801377:	6a 00                	push   $0x0
  801379:	57                   	push   %edi
  80137a:	6a 00                	push   $0x0
  80137c:	e8 7a f8 ff ff       	call   800bfb <sys_page_map>
  801381:	89 c7                	mov    %eax,%edi
  801383:	83 c4 20             	add    $0x20,%esp
  801386:	85 c0                	test   %eax,%eax
  801388:	78 2e                	js     8013b8 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80138a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80138d:	89 d0                	mov    %edx,%eax
  80138f:	c1 e8 0c             	shr    $0xc,%eax
  801392:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801399:	83 ec 0c             	sub    $0xc,%esp
  80139c:	25 07 0e 00 00       	and    $0xe07,%eax
  8013a1:	50                   	push   %eax
  8013a2:	53                   	push   %ebx
  8013a3:	6a 00                	push   $0x0
  8013a5:	52                   	push   %edx
  8013a6:	6a 00                	push   $0x0
  8013a8:	e8 4e f8 ff ff       	call   800bfb <sys_page_map>
  8013ad:	89 c7                	mov    %eax,%edi
  8013af:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013b2:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013b4:	85 ff                	test   %edi,%edi
  8013b6:	79 1d                	jns    8013d5 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013b8:	83 ec 08             	sub    $0x8,%esp
  8013bb:	53                   	push   %ebx
  8013bc:	6a 00                	push   $0x0
  8013be:	e8 7a f8 ff ff       	call   800c3d <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013c3:	83 c4 08             	add    $0x8,%esp
  8013c6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013c9:	6a 00                	push   $0x0
  8013cb:	e8 6d f8 ff ff       	call   800c3d <sys_page_unmap>
	return r;
  8013d0:	83 c4 10             	add    $0x10,%esp
  8013d3:	89 f8                	mov    %edi,%eax
}
  8013d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013d8:	5b                   	pop    %ebx
  8013d9:	5e                   	pop    %esi
  8013da:	5f                   	pop    %edi
  8013db:	5d                   	pop    %ebp
  8013dc:	c3                   	ret    

008013dd <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013dd:	55                   	push   %ebp
  8013de:	89 e5                	mov    %esp,%ebp
  8013e0:	53                   	push   %ebx
  8013e1:	83 ec 14             	sub    $0x14,%esp
  8013e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013e7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013ea:	50                   	push   %eax
  8013eb:	53                   	push   %ebx
  8013ec:	e8 86 fd ff ff       	call   801177 <fd_lookup>
  8013f1:	83 c4 08             	add    $0x8,%esp
  8013f4:	89 c2                	mov    %eax,%edx
  8013f6:	85 c0                	test   %eax,%eax
  8013f8:	78 6d                	js     801467 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013fa:	83 ec 08             	sub    $0x8,%esp
  8013fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801400:	50                   	push   %eax
  801401:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801404:	ff 30                	pushl  (%eax)
  801406:	e8 c2 fd ff ff       	call   8011cd <dev_lookup>
  80140b:	83 c4 10             	add    $0x10,%esp
  80140e:	85 c0                	test   %eax,%eax
  801410:	78 4c                	js     80145e <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801412:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801415:	8b 42 08             	mov    0x8(%edx),%eax
  801418:	83 e0 03             	and    $0x3,%eax
  80141b:	83 f8 01             	cmp    $0x1,%eax
  80141e:	75 21                	jne    801441 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801420:	a1 04 40 80 00       	mov    0x804004,%eax
  801425:	8b 40 48             	mov    0x48(%eax),%eax
  801428:	83 ec 04             	sub    $0x4,%esp
  80142b:	53                   	push   %ebx
  80142c:	50                   	push   %eax
  80142d:	68 b1 25 80 00       	push   $0x8025b1
  801432:	e8 7a ed ff ff       	call   8001b1 <cprintf>
		return -E_INVAL;
  801437:	83 c4 10             	add    $0x10,%esp
  80143a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80143f:	eb 26                	jmp    801467 <read+0x8a>
	}
	if (!dev->dev_read)
  801441:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801444:	8b 40 08             	mov    0x8(%eax),%eax
  801447:	85 c0                	test   %eax,%eax
  801449:	74 17                	je     801462 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80144b:	83 ec 04             	sub    $0x4,%esp
  80144e:	ff 75 10             	pushl  0x10(%ebp)
  801451:	ff 75 0c             	pushl  0xc(%ebp)
  801454:	52                   	push   %edx
  801455:	ff d0                	call   *%eax
  801457:	89 c2                	mov    %eax,%edx
  801459:	83 c4 10             	add    $0x10,%esp
  80145c:	eb 09                	jmp    801467 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80145e:	89 c2                	mov    %eax,%edx
  801460:	eb 05                	jmp    801467 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801462:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801467:	89 d0                	mov    %edx,%eax
  801469:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80146c:	c9                   	leave  
  80146d:	c3                   	ret    

0080146e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80146e:	55                   	push   %ebp
  80146f:	89 e5                	mov    %esp,%ebp
  801471:	57                   	push   %edi
  801472:	56                   	push   %esi
  801473:	53                   	push   %ebx
  801474:	83 ec 0c             	sub    $0xc,%esp
  801477:	8b 7d 08             	mov    0x8(%ebp),%edi
  80147a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80147d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801482:	eb 21                	jmp    8014a5 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801484:	83 ec 04             	sub    $0x4,%esp
  801487:	89 f0                	mov    %esi,%eax
  801489:	29 d8                	sub    %ebx,%eax
  80148b:	50                   	push   %eax
  80148c:	89 d8                	mov    %ebx,%eax
  80148e:	03 45 0c             	add    0xc(%ebp),%eax
  801491:	50                   	push   %eax
  801492:	57                   	push   %edi
  801493:	e8 45 ff ff ff       	call   8013dd <read>
		if (m < 0)
  801498:	83 c4 10             	add    $0x10,%esp
  80149b:	85 c0                	test   %eax,%eax
  80149d:	78 10                	js     8014af <readn+0x41>
			return m;
		if (m == 0)
  80149f:	85 c0                	test   %eax,%eax
  8014a1:	74 0a                	je     8014ad <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014a3:	01 c3                	add    %eax,%ebx
  8014a5:	39 f3                	cmp    %esi,%ebx
  8014a7:	72 db                	jb     801484 <readn+0x16>
  8014a9:	89 d8                	mov    %ebx,%eax
  8014ab:	eb 02                	jmp    8014af <readn+0x41>
  8014ad:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014b2:	5b                   	pop    %ebx
  8014b3:	5e                   	pop    %esi
  8014b4:	5f                   	pop    %edi
  8014b5:	5d                   	pop    %ebp
  8014b6:	c3                   	ret    

008014b7 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014b7:	55                   	push   %ebp
  8014b8:	89 e5                	mov    %esp,%ebp
  8014ba:	53                   	push   %ebx
  8014bb:	83 ec 14             	sub    $0x14,%esp
  8014be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014c4:	50                   	push   %eax
  8014c5:	53                   	push   %ebx
  8014c6:	e8 ac fc ff ff       	call   801177 <fd_lookup>
  8014cb:	83 c4 08             	add    $0x8,%esp
  8014ce:	89 c2                	mov    %eax,%edx
  8014d0:	85 c0                	test   %eax,%eax
  8014d2:	78 68                	js     80153c <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d4:	83 ec 08             	sub    $0x8,%esp
  8014d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014da:	50                   	push   %eax
  8014db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014de:	ff 30                	pushl  (%eax)
  8014e0:	e8 e8 fc ff ff       	call   8011cd <dev_lookup>
  8014e5:	83 c4 10             	add    $0x10,%esp
  8014e8:	85 c0                	test   %eax,%eax
  8014ea:	78 47                	js     801533 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ef:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014f3:	75 21                	jne    801516 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014f5:	a1 04 40 80 00       	mov    0x804004,%eax
  8014fa:	8b 40 48             	mov    0x48(%eax),%eax
  8014fd:	83 ec 04             	sub    $0x4,%esp
  801500:	53                   	push   %ebx
  801501:	50                   	push   %eax
  801502:	68 cd 25 80 00       	push   $0x8025cd
  801507:	e8 a5 ec ff ff       	call   8001b1 <cprintf>
		return -E_INVAL;
  80150c:	83 c4 10             	add    $0x10,%esp
  80150f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801514:	eb 26                	jmp    80153c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801516:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801519:	8b 52 0c             	mov    0xc(%edx),%edx
  80151c:	85 d2                	test   %edx,%edx
  80151e:	74 17                	je     801537 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801520:	83 ec 04             	sub    $0x4,%esp
  801523:	ff 75 10             	pushl  0x10(%ebp)
  801526:	ff 75 0c             	pushl  0xc(%ebp)
  801529:	50                   	push   %eax
  80152a:	ff d2                	call   *%edx
  80152c:	89 c2                	mov    %eax,%edx
  80152e:	83 c4 10             	add    $0x10,%esp
  801531:	eb 09                	jmp    80153c <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801533:	89 c2                	mov    %eax,%edx
  801535:	eb 05                	jmp    80153c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801537:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80153c:	89 d0                	mov    %edx,%eax
  80153e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801541:	c9                   	leave  
  801542:	c3                   	ret    

00801543 <seek>:

int
seek(int fdnum, off_t offset)
{
  801543:	55                   	push   %ebp
  801544:	89 e5                	mov    %esp,%ebp
  801546:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801549:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80154c:	50                   	push   %eax
  80154d:	ff 75 08             	pushl  0x8(%ebp)
  801550:	e8 22 fc ff ff       	call   801177 <fd_lookup>
  801555:	83 c4 08             	add    $0x8,%esp
  801558:	85 c0                	test   %eax,%eax
  80155a:	78 0e                	js     80156a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80155c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80155f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801562:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801565:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80156a:	c9                   	leave  
  80156b:	c3                   	ret    

0080156c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80156c:	55                   	push   %ebp
  80156d:	89 e5                	mov    %esp,%ebp
  80156f:	53                   	push   %ebx
  801570:	83 ec 14             	sub    $0x14,%esp
  801573:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801576:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801579:	50                   	push   %eax
  80157a:	53                   	push   %ebx
  80157b:	e8 f7 fb ff ff       	call   801177 <fd_lookup>
  801580:	83 c4 08             	add    $0x8,%esp
  801583:	89 c2                	mov    %eax,%edx
  801585:	85 c0                	test   %eax,%eax
  801587:	78 65                	js     8015ee <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801589:	83 ec 08             	sub    $0x8,%esp
  80158c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80158f:	50                   	push   %eax
  801590:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801593:	ff 30                	pushl  (%eax)
  801595:	e8 33 fc ff ff       	call   8011cd <dev_lookup>
  80159a:	83 c4 10             	add    $0x10,%esp
  80159d:	85 c0                	test   %eax,%eax
  80159f:	78 44                	js     8015e5 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015a8:	75 21                	jne    8015cb <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015aa:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015af:	8b 40 48             	mov    0x48(%eax),%eax
  8015b2:	83 ec 04             	sub    $0x4,%esp
  8015b5:	53                   	push   %ebx
  8015b6:	50                   	push   %eax
  8015b7:	68 90 25 80 00       	push   $0x802590
  8015bc:	e8 f0 eb ff ff       	call   8001b1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015c1:	83 c4 10             	add    $0x10,%esp
  8015c4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015c9:	eb 23                	jmp    8015ee <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015ce:	8b 52 18             	mov    0x18(%edx),%edx
  8015d1:	85 d2                	test   %edx,%edx
  8015d3:	74 14                	je     8015e9 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015d5:	83 ec 08             	sub    $0x8,%esp
  8015d8:	ff 75 0c             	pushl  0xc(%ebp)
  8015db:	50                   	push   %eax
  8015dc:	ff d2                	call   *%edx
  8015de:	89 c2                	mov    %eax,%edx
  8015e0:	83 c4 10             	add    $0x10,%esp
  8015e3:	eb 09                	jmp    8015ee <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e5:	89 c2                	mov    %eax,%edx
  8015e7:	eb 05                	jmp    8015ee <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015e9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015ee:	89 d0                	mov    %edx,%eax
  8015f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f3:	c9                   	leave  
  8015f4:	c3                   	ret    

008015f5 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015f5:	55                   	push   %ebp
  8015f6:	89 e5                	mov    %esp,%ebp
  8015f8:	53                   	push   %ebx
  8015f9:	83 ec 14             	sub    $0x14,%esp
  8015fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015ff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801602:	50                   	push   %eax
  801603:	ff 75 08             	pushl  0x8(%ebp)
  801606:	e8 6c fb ff ff       	call   801177 <fd_lookup>
  80160b:	83 c4 08             	add    $0x8,%esp
  80160e:	89 c2                	mov    %eax,%edx
  801610:	85 c0                	test   %eax,%eax
  801612:	78 58                	js     80166c <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801614:	83 ec 08             	sub    $0x8,%esp
  801617:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80161a:	50                   	push   %eax
  80161b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161e:	ff 30                	pushl  (%eax)
  801620:	e8 a8 fb ff ff       	call   8011cd <dev_lookup>
  801625:	83 c4 10             	add    $0x10,%esp
  801628:	85 c0                	test   %eax,%eax
  80162a:	78 37                	js     801663 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80162c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80162f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801633:	74 32                	je     801667 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801635:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801638:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80163f:	00 00 00 
	stat->st_isdir = 0;
  801642:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801649:	00 00 00 
	stat->st_dev = dev;
  80164c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801652:	83 ec 08             	sub    $0x8,%esp
  801655:	53                   	push   %ebx
  801656:	ff 75 f0             	pushl  -0x10(%ebp)
  801659:	ff 50 14             	call   *0x14(%eax)
  80165c:	89 c2                	mov    %eax,%edx
  80165e:	83 c4 10             	add    $0x10,%esp
  801661:	eb 09                	jmp    80166c <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801663:	89 c2                	mov    %eax,%edx
  801665:	eb 05                	jmp    80166c <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801667:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80166c:	89 d0                	mov    %edx,%eax
  80166e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801671:	c9                   	leave  
  801672:	c3                   	ret    

00801673 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801673:	55                   	push   %ebp
  801674:	89 e5                	mov    %esp,%ebp
  801676:	56                   	push   %esi
  801677:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801678:	83 ec 08             	sub    $0x8,%esp
  80167b:	6a 00                	push   $0x0
  80167d:	ff 75 08             	pushl  0x8(%ebp)
  801680:	e8 e3 01 00 00       	call   801868 <open>
  801685:	89 c3                	mov    %eax,%ebx
  801687:	83 c4 10             	add    $0x10,%esp
  80168a:	85 c0                	test   %eax,%eax
  80168c:	78 1b                	js     8016a9 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80168e:	83 ec 08             	sub    $0x8,%esp
  801691:	ff 75 0c             	pushl  0xc(%ebp)
  801694:	50                   	push   %eax
  801695:	e8 5b ff ff ff       	call   8015f5 <fstat>
  80169a:	89 c6                	mov    %eax,%esi
	close(fd);
  80169c:	89 1c 24             	mov    %ebx,(%esp)
  80169f:	e8 fd fb ff ff       	call   8012a1 <close>
	return r;
  8016a4:	83 c4 10             	add    $0x10,%esp
  8016a7:	89 f0                	mov    %esi,%eax
}
  8016a9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ac:	5b                   	pop    %ebx
  8016ad:	5e                   	pop    %esi
  8016ae:	5d                   	pop    %ebp
  8016af:	c3                   	ret    

008016b0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016b0:	55                   	push   %ebp
  8016b1:	89 e5                	mov    %esp,%ebp
  8016b3:	56                   	push   %esi
  8016b4:	53                   	push   %ebx
  8016b5:	89 c6                	mov    %eax,%esi
  8016b7:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016b9:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016c0:	75 12                	jne    8016d4 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016c2:	83 ec 0c             	sub    $0xc,%esp
  8016c5:	6a 01                	push   $0x1
  8016c7:	e8 fc f9 ff ff       	call   8010c8 <ipc_find_env>
  8016cc:	a3 00 40 80 00       	mov    %eax,0x804000
  8016d1:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016d4:	6a 07                	push   $0x7
  8016d6:	68 00 50 80 00       	push   $0x805000
  8016db:	56                   	push   %esi
  8016dc:	ff 35 00 40 80 00    	pushl  0x804000
  8016e2:	e8 8d f9 ff ff       	call   801074 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016e7:	83 c4 0c             	add    $0xc,%esp
  8016ea:	6a 00                	push   $0x0
  8016ec:	53                   	push   %ebx
  8016ed:	6a 00                	push   $0x0
  8016ef:	e8 0e f9 ff ff       	call   801002 <ipc_recv>
}
  8016f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016f7:	5b                   	pop    %ebx
  8016f8:	5e                   	pop    %esi
  8016f9:	5d                   	pop    %ebp
  8016fa:	c3                   	ret    

008016fb <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016fb:	55                   	push   %ebp
  8016fc:	89 e5                	mov    %esp,%ebp
  8016fe:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801701:	8b 45 08             	mov    0x8(%ebp),%eax
  801704:	8b 40 0c             	mov    0xc(%eax),%eax
  801707:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80170c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80170f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801714:	ba 00 00 00 00       	mov    $0x0,%edx
  801719:	b8 02 00 00 00       	mov    $0x2,%eax
  80171e:	e8 8d ff ff ff       	call   8016b0 <fsipc>
}
  801723:	c9                   	leave  
  801724:	c3                   	ret    

00801725 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801725:	55                   	push   %ebp
  801726:	89 e5                	mov    %esp,%ebp
  801728:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80172b:	8b 45 08             	mov    0x8(%ebp),%eax
  80172e:	8b 40 0c             	mov    0xc(%eax),%eax
  801731:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801736:	ba 00 00 00 00       	mov    $0x0,%edx
  80173b:	b8 06 00 00 00       	mov    $0x6,%eax
  801740:	e8 6b ff ff ff       	call   8016b0 <fsipc>
}
  801745:	c9                   	leave  
  801746:	c3                   	ret    

00801747 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801747:	55                   	push   %ebp
  801748:	89 e5                	mov    %esp,%ebp
  80174a:	53                   	push   %ebx
  80174b:	83 ec 04             	sub    $0x4,%esp
  80174e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801751:	8b 45 08             	mov    0x8(%ebp),%eax
  801754:	8b 40 0c             	mov    0xc(%eax),%eax
  801757:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80175c:	ba 00 00 00 00       	mov    $0x0,%edx
  801761:	b8 05 00 00 00       	mov    $0x5,%eax
  801766:	e8 45 ff ff ff       	call   8016b0 <fsipc>
  80176b:	85 c0                	test   %eax,%eax
  80176d:	78 2c                	js     80179b <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80176f:	83 ec 08             	sub    $0x8,%esp
  801772:	68 00 50 80 00       	push   $0x805000
  801777:	53                   	push   %ebx
  801778:	e8 38 f0 ff ff       	call   8007b5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80177d:	a1 80 50 80 00       	mov    0x805080,%eax
  801782:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801788:	a1 84 50 80 00       	mov    0x805084,%eax
  80178d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801793:	83 c4 10             	add    $0x10,%esp
  801796:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80179b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80179e:	c9                   	leave  
  80179f:	c3                   	ret    

008017a0 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017a0:	55                   	push   %ebp
  8017a1:	89 e5                	mov    %esp,%ebp
  8017a3:	83 ec 0c             	sub    $0xc,%esp
  8017a6:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	
	int r;

	n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8017a9:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8017ae:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8017b3:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8017b9:	8b 52 0c             	mov    0xc(%edx),%edx
  8017bc:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8017c2:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8017c7:	50                   	push   %eax
  8017c8:	ff 75 0c             	pushl  0xc(%ebp)
  8017cb:	68 08 50 80 00       	push   $0x805008
  8017d0:	e8 72 f1 ff ff       	call   800947 <memmove>
	
	return fsipc(FSREQ_WRITE, NULL);	
  8017d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8017da:	b8 04 00 00 00       	mov    $0x4,%eax
  8017df:	e8 cc fe ff ff       	call   8016b0 <fsipc>
}
  8017e4:	c9                   	leave  
  8017e5:	c3                   	ret    

008017e6 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017e6:	55                   	push   %ebp
  8017e7:	89 e5                	mov    %esp,%ebp
  8017e9:	56                   	push   %esi
  8017ea:	53                   	push   %ebx
  8017eb:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f1:	8b 40 0c             	mov    0xc(%eax),%eax
  8017f4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017f9:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801804:	b8 03 00 00 00       	mov    $0x3,%eax
  801809:	e8 a2 fe ff ff       	call   8016b0 <fsipc>
  80180e:	89 c3                	mov    %eax,%ebx
  801810:	85 c0                	test   %eax,%eax
  801812:	78 4b                	js     80185f <devfile_read+0x79>
		return r;
	assert(r <= n);
  801814:	39 c6                	cmp    %eax,%esi
  801816:	73 16                	jae    80182e <devfile_read+0x48>
  801818:	68 fc 25 80 00       	push   $0x8025fc
  80181d:	68 03 26 80 00       	push   $0x802603
  801822:	6a 7c                	push   $0x7c
  801824:	68 18 26 80 00       	push   $0x802618
  801829:	e8 bd 05 00 00       	call   801deb <_panic>
	assert(r <= PGSIZE);
  80182e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801833:	7e 16                	jle    80184b <devfile_read+0x65>
  801835:	68 23 26 80 00       	push   $0x802623
  80183a:	68 03 26 80 00       	push   $0x802603
  80183f:	6a 7d                	push   $0x7d
  801841:	68 18 26 80 00       	push   $0x802618
  801846:	e8 a0 05 00 00       	call   801deb <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80184b:	83 ec 04             	sub    $0x4,%esp
  80184e:	50                   	push   %eax
  80184f:	68 00 50 80 00       	push   $0x805000
  801854:	ff 75 0c             	pushl  0xc(%ebp)
  801857:	e8 eb f0 ff ff       	call   800947 <memmove>
	return r;
  80185c:	83 c4 10             	add    $0x10,%esp
}
  80185f:	89 d8                	mov    %ebx,%eax
  801861:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801864:	5b                   	pop    %ebx
  801865:	5e                   	pop    %esi
  801866:	5d                   	pop    %ebp
  801867:	c3                   	ret    

00801868 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801868:	55                   	push   %ebp
  801869:	89 e5                	mov    %esp,%ebp
  80186b:	53                   	push   %ebx
  80186c:	83 ec 20             	sub    $0x20,%esp
  80186f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801872:	53                   	push   %ebx
  801873:	e8 04 ef ff ff       	call   80077c <strlen>
  801878:	83 c4 10             	add    $0x10,%esp
  80187b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801880:	7f 67                	jg     8018e9 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801882:	83 ec 0c             	sub    $0xc,%esp
  801885:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801888:	50                   	push   %eax
  801889:	e8 9a f8 ff ff       	call   801128 <fd_alloc>
  80188e:	83 c4 10             	add    $0x10,%esp
		return r;
  801891:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801893:	85 c0                	test   %eax,%eax
  801895:	78 57                	js     8018ee <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801897:	83 ec 08             	sub    $0x8,%esp
  80189a:	53                   	push   %ebx
  80189b:	68 00 50 80 00       	push   $0x805000
  8018a0:	e8 10 ef ff ff       	call   8007b5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018a8:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018b0:	b8 01 00 00 00       	mov    $0x1,%eax
  8018b5:	e8 f6 fd ff ff       	call   8016b0 <fsipc>
  8018ba:	89 c3                	mov    %eax,%ebx
  8018bc:	83 c4 10             	add    $0x10,%esp
  8018bf:	85 c0                	test   %eax,%eax
  8018c1:	79 14                	jns    8018d7 <open+0x6f>
		fd_close(fd, 0);
  8018c3:	83 ec 08             	sub    $0x8,%esp
  8018c6:	6a 00                	push   $0x0
  8018c8:	ff 75 f4             	pushl  -0xc(%ebp)
  8018cb:	e8 50 f9 ff ff       	call   801220 <fd_close>
		return r;
  8018d0:	83 c4 10             	add    $0x10,%esp
  8018d3:	89 da                	mov    %ebx,%edx
  8018d5:	eb 17                	jmp    8018ee <open+0x86>
	}

	return fd2num(fd);
  8018d7:	83 ec 0c             	sub    $0xc,%esp
  8018da:	ff 75 f4             	pushl  -0xc(%ebp)
  8018dd:	e8 1f f8 ff ff       	call   801101 <fd2num>
  8018e2:	89 c2                	mov    %eax,%edx
  8018e4:	83 c4 10             	add    $0x10,%esp
  8018e7:	eb 05                	jmp    8018ee <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018e9:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018ee:	89 d0                	mov    %edx,%eax
  8018f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018f3:	c9                   	leave  
  8018f4:	c3                   	ret    

008018f5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018f5:	55                   	push   %ebp
  8018f6:	89 e5                	mov    %esp,%ebp
  8018f8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018fb:	ba 00 00 00 00       	mov    $0x0,%edx
  801900:	b8 08 00 00 00       	mov    $0x8,%eax
  801905:	e8 a6 fd ff ff       	call   8016b0 <fsipc>
}
  80190a:	c9                   	leave  
  80190b:	c3                   	ret    

0080190c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80190c:	55                   	push   %ebp
  80190d:	89 e5                	mov    %esp,%ebp
  80190f:	56                   	push   %esi
  801910:	53                   	push   %ebx
  801911:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801914:	83 ec 0c             	sub    $0xc,%esp
  801917:	ff 75 08             	pushl  0x8(%ebp)
  80191a:	e8 f2 f7 ff ff       	call   801111 <fd2data>
  80191f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801921:	83 c4 08             	add    $0x8,%esp
  801924:	68 2f 26 80 00       	push   $0x80262f
  801929:	53                   	push   %ebx
  80192a:	e8 86 ee ff ff       	call   8007b5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80192f:	8b 46 04             	mov    0x4(%esi),%eax
  801932:	2b 06                	sub    (%esi),%eax
  801934:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80193a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801941:	00 00 00 
	stat->st_dev = &devpipe;
  801944:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80194b:	30 80 00 
	return 0;
}
  80194e:	b8 00 00 00 00       	mov    $0x0,%eax
  801953:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801956:	5b                   	pop    %ebx
  801957:	5e                   	pop    %esi
  801958:	5d                   	pop    %ebp
  801959:	c3                   	ret    

0080195a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80195a:	55                   	push   %ebp
  80195b:	89 e5                	mov    %esp,%ebp
  80195d:	53                   	push   %ebx
  80195e:	83 ec 0c             	sub    $0xc,%esp
  801961:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801964:	53                   	push   %ebx
  801965:	6a 00                	push   $0x0
  801967:	e8 d1 f2 ff ff       	call   800c3d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80196c:	89 1c 24             	mov    %ebx,(%esp)
  80196f:	e8 9d f7 ff ff       	call   801111 <fd2data>
  801974:	83 c4 08             	add    $0x8,%esp
  801977:	50                   	push   %eax
  801978:	6a 00                	push   $0x0
  80197a:	e8 be f2 ff ff       	call   800c3d <sys_page_unmap>
}
  80197f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801982:	c9                   	leave  
  801983:	c3                   	ret    

00801984 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801984:	55                   	push   %ebp
  801985:	89 e5                	mov    %esp,%ebp
  801987:	57                   	push   %edi
  801988:	56                   	push   %esi
  801989:	53                   	push   %ebx
  80198a:	83 ec 1c             	sub    $0x1c,%esp
  80198d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801990:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801992:	a1 04 40 80 00       	mov    0x804004,%eax
  801997:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80199a:	83 ec 0c             	sub    $0xc,%esp
  80199d:	ff 75 e0             	pushl  -0x20(%ebp)
  8019a0:	e8 f7 04 00 00       	call   801e9c <pageref>
  8019a5:	89 c3                	mov    %eax,%ebx
  8019a7:	89 3c 24             	mov    %edi,(%esp)
  8019aa:	e8 ed 04 00 00       	call   801e9c <pageref>
  8019af:	83 c4 10             	add    $0x10,%esp
  8019b2:	39 c3                	cmp    %eax,%ebx
  8019b4:	0f 94 c1             	sete   %cl
  8019b7:	0f b6 c9             	movzbl %cl,%ecx
  8019ba:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8019bd:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8019c3:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8019c6:	39 ce                	cmp    %ecx,%esi
  8019c8:	74 1b                	je     8019e5 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8019ca:	39 c3                	cmp    %eax,%ebx
  8019cc:	75 c4                	jne    801992 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8019ce:	8b 42 58             	mov    0x58(%edx),%eax
  8019d1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019d4:	50                   	push   %eax
  8019d5:	56                   	push   %esi
  8019d6:	68 36 26 80 00       	push   $0x802636
  8019db:	e8 d1 e7 ff ff       	call   8001b1 <cprintf>
  8019e0:	83 c4 10             	add    $0x10,%esp
  8019e3:	eb ad                	jmp    801992 <_pipeisclosed+0xe>
	}
}
  8019e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019eb:	5b                   	pop    %ebx
  8019ec:	5e                   	pop    %esi
  8019ed:	5f                   	pop    %edi
  8019ee:	5d                   	pop    %ebp
  8019ef:	c3                   	ret    

008019f0 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019f0:	55                   	push   %ebp
  8019f1:	89 e5                	mov    %esp,%ebp
  8019f3:	57                   	push   %edi
  8019f4:	56                   	push   %esi
  8019f5:	53                   	push   %ebx
  8019f6:	83 ec 28             	sub    $0x28,%esp
  8019f9:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8019fc:	56                   	push   %esi
  8019fd:	e8 0f f7 ff ff       	call   801111 <fd2data>
  801a02:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a04:	83 c4 10             	add    $0x10,%esp
  801a07:	bf 00 00 00 00       	mov    $0x0,%edi
  801a0c:	eb 4b                	jmp    801a59 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a0e:	89 da                	mov    %ebx,%edx
  801a10:	89 f0                	mov    %esi,%eax
  801a12:	e8 6d ff ff ff       	call   801984 <_pipeisclosed>
  801a17:	85 c0                	test   %eax,%eax
  801a19:	75 48                	jne    801a63 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a1b:	e8 79 f1 ff ff       	call   800b99 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a20:	8b 43 04             	mov    0x4(%ebx),%eax
  801a23:	8b 0b                	mov    (%ebx),%ecx
  801a25:	8d 51 20             	lea    0x20(%ecx),%edx
  801a28:	39 d0                	cmp    %edx,%eax
  801a2a:	73 e2                	jae    801a0e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a2f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a33:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a36:	89 c2                	mov    %eax,%edx
  801a38:	c1 fa 1f             	sar    $0x1f,%edx
  801a3b:	89 d1                	mov    %edx,%ecx
  801a3d:	c1 e9 1b             	shr    $0x1b,%ecx
  801a40:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a43:	83 e2 1f             	and    $0x1f,%edx
  801a46:	29 ca                	sub    %ecx,%edx
  801a48:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a4c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a50:	83 c0 01             	add    $0x1,%eax
  801a53:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a56:	83 c7 01             	add    $0x1,%edi
  801a59:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a5c:	75 c2                	jne    801a20 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a5e:	8b 45 10             	mov    0x10(%ebp),%eax
  801a61:	eb 05                	jmp    801a68 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a63:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a6b:	5b                   	pop    %ebx
  801a6c:	5e                   	pop    %esi
  801a6d:	5f                   	pop    %edi
  801a6e:	5d                   	pop    %ebp
  801a6f:	c3                   	ret    

00801a70 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a70:	55                   	push   %ebp
  801a71:	89 e5                	mov    %esp,%ebp
  801a73:	57                   	push   %edi
  801a74:	56                   	push   %esi
  801a75:	53                   	push   %ebx
  801a76:	83 ec 18             	sub    $0x18,%esp
  801a79:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a7c:	57                   	push   %edi
  801a7d:	e8 8f f6 ff ff       	call   801111 <fd2data>
  801a82:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a84:	83 c4 10             	add    $0x10,%esp
  801a87:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a8c:	eb 3d                	jmp    801acb <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a8e:	85 db                	test   %ebx,%ebx
  801a90:	74 04                	je     801a96 <devpipe_read+0x26>
				return i;
  801a92:	89 d8                	mov    %ebx,%eax
  801a94:	eb 44                	jmp    801ada <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a96:	89 f2                	mov    %esi,%edx
  801a98:	89 f8                	mov    %edi,%eax
  801a9a:	e8 e5 fe ff ff       	call   801984 <_pipeisclosed>
  801a9f:	85 c0                	test   %eax,%eax
  801aa1:	75 32                	jne    801ad5 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801aa3:	e8 f1 f0 ff ff       	call   800b99 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801aa8:	8b 06                	mov    (%esi),%eax
  801aaa:	3b 46 04             	cmp    0x4(%esi),%eax
  801aad:	74 df                	je     801a8e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801aaf:	99                   	cltd   
  801ab0:	c1 ea 1b             	shr    $0x1b,%edx
  801ab3:	01 d0                	add    %edx,%eax
  801ab5:	83 e0 1f             	and    $0x1f,%eax
  801ab8:	29 d0                	sub    %edx,%eax
  801aba:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801abf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ac2:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ac5:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ac8:	83 c3 01             	add    $0x1,%ebx
  801acb:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ace:	75 d8                	jne    801aa8 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801ad0:	8b 45 10             	mov    0x10(%ebp),%eax
  801ad3:	eb 05                	jmp    801ada <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ad5:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ada:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801add:	5b                   	pop    %ebx
  801ade:	5e                   	pop    %esi
  801adf:	5f                   	pop    %edi
  801ae0:	5d                   	pop    %ebp
  801ae1:	c3                   	ret    

00801ae2 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ae2:	55                   	push   %ebp
  801ae3:	89 e5                	mov    %esp,%ebp
  801ae5:	56                   	push   %esi
  801ae6:	53                   	push   %ebx
  801ae7:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801aea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aed:	50                   	push   %eax
  801aee:	e8 35 f6 ff ff       	call   801128 <fd_alloc>
  801af3:	83 c4 10             	add    $0x10,%esp
  801af6:	89 c2                	mov    %eax,%edx
  801af8:	85 c0                	test   %eax,%eax
  801afa:	0f 88 2c 01 00 00    	js     801c2c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b00:	83 ec 04             	sub    $0x4,%esp
  801b03:	68 07 04 00 00       	push   $0x407
  801b08:	ff 75 f4             	pushl  -0xc(%ebp)
  801b0b:	6a 00                	push   $0x0
  801b0d:	e8 a6 f0 ff ff       	call   800bb8 <sys_page_alloc>
  801b12:	83 c4 10             	add    $0x10,%esp
  801b15:	89 c2                	mov    %eax,%edx
  801b17:	85 c0                	test   %eax,%eax
  801b19:	0f 88 0d 01 00 00    	js     801c2c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b1f:	83 ec 0c             	sub    $0xc,%esp
  801b22:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b25:	50                   	push   %eax
  801b26:	e8 fd f5 ff ff       	call   801128 <fd_alloc>
  801b2b:	89 c3                	mov    %eax,%ebx
  801b2d:	83 c4 10             	add    $0x10,%esp
  801b30:	85 c0                	test   %eax,%eax
  801b32:	0f 88 e2 00 00 00    	js     801c1a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b38:	83 ec 04             	sub    $0x4,%esp
  801b3b:	68 07 04 00 00       	push   $0x407
  801b40:	ff 75 f0             	pushl  -0x10(%ebp)
  801b43:	6a 00                	push   $0x0
  801b45:	e8 6e f0 ff ff       	call   800bb8 <sys_page_alloc>
  801b4a:	89 c3                	mov    %eax,%ebx
  801b4c:	83 c4 10             	add    $0x10,%esp
  801b4f:	85 c0                	test   %eax,%eax
  801b51:	0f 88 c3 00 00 00    	js     801c1a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b57:	83 ec 0c             	sub    $0xc,%esp
  801b5a:	ff 75 f4             	pushl  -0xc(%ebp)
  801b5d:	e8 af f5 ff ff       	call   801111 <fd2data>
  801b62:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b64:	83 c4 0c             	add    $0xc,%esp
  801b67:	68 07 04 00 00       	push   $0x407
  801b6c:	50                   	push   %eax
  801b6d:	6a 00                	push   $0x0
  801b6f:	e8 44 f0 ff ff       	call   800bb8 <sys_page_alloc>
  801b74:	89 c3                	mov    %eax,%ebx
  801b76:	83 c4 10             	add    $0x10,%esp
  801b79:	85 c0                	test   %eax,%eax
  801b7b:	0f 88 89 00 00 00    	js     801c0a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b81:	83 ec 0c             	sub    $0xc,%esp
  801b84:	ff 75 f0             	pushl  -0x10(%ebp)
  801b87:	e8 85 f5 ff ff       	call   801111 <fd2data>
  801b8c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b93:	50                   	push   %eax
  801b94:	6a 00                	push   $0x0
  801b96:	56                   	push   %esi
  801b97:	6a 00                	push   $0x0
  801b99:	e8 5d f0 ff ff       	call   800bfb <sys_page_map>
  801b9e:	89 c3                	mov    %eax,%ebx
  801ba0:	83 c4 20             	add    $0x20,%esp
  801ba3:	85 c0                	test   %eax,%eax
  801ba5:	78 55                	js     801bfc <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ba7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bb0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801bb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bb5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801bbc:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bc5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801bc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bca:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801bd1:	83 ec 0c             	sub    $0xc,%esp
  801bd4:	ff 75 f4             	pushl  -0xc(%ebp)
  801bd7:	e8 25 f5 ff ff       	call   801101 <fd2num>
  801bdc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bdf:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801be1:	83 c4 04             	add    $0x4,%esp
  801be4:	ff 75 f0             	pushl  -0x10(%ebp)
  801be7:	e8 15 f5 ff ff       	call   801101 <fd2num>
  801bec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bef:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801bf2:	83 c4 10             	add    $0x10,%esp
  801bf5:	ba 00 00 00 00       	mov    $0x0,%edx
  801bfa:	eb 30                	jmp    801c2c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801bfc:	83 ec 08             	sub    $0x8,%esp
  801bff:	56                   	push   %esi
  801c00:	6a 00                	push   $0x0
  801c02:	e8 36 f0 ff ff       	call   800c3d <sys_page_unmap>
  801c07:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c0a:	83 ec 08             	sub    $0x8,%esp
  801c0d:	ff 75 f0             	pushl  -0x10(%ebp)
  801c10:	6a 00                	push   $0x0
  801c12:	e8 26 f0 ff ff       	call   800c3d <sys_page_unmap>
  801c17:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c1a:	83 ec 08             	sub    $0x8,%esp
  801c1d:	ff 75 f4             	pushl  -0xc(%ebp)
  801c20:	6a 00                	push   $0x0
  801c22:	e8 16 f0 ff ff       	call   800c3d <sys_page_unmap>
  801c27:	83 c4 10             	add    $0x10,%esp
  801c2a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c2c:	89 d0                	mov    %edx,%eax
  801c2e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c31:	5b                   	pop    %ebx
  801c32:	5e                   	pop    %esi
  801c33:	5d                   	pop    %ebp
  801c34:	c3                   	ret    

00801c35 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c35:	55                   	push   %ebp
  801c36:	89 e5                	mov    %esp,%ebp
  801c38:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c3b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c3e:	50                   	push   %eax
  801c3f:	ff 75 08             	pushl  0x8(%ebp)
  801c42:	e8 30 f5 ff ff       	call   801177 <fd_lookup>
  801c47:	83 c4 10             	add    $0x10,%esp
  801c4a:	85 c0                	test   %eax,%eax
  801c4c:	78 18                	js     801c66 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c4e:	83 ec 0c             	sub    $0xc,%esp
  801c51:	ff 75 f4             	pushl  -0xc(%ebp)
  801c54:	e8 b8 f4 ff ff       	call   801111 <fd2data>
	return _pipeisclosed(fd, p);
  801c59:	89 c2                	mov    %eax,%edx
  801c5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c5e:	e8 21 fd ff ff       	call   801984 <_pipeisclosed>
  801c63:	83 c4 10             	add    $0x10,%esp
}
  801c66:	c9                   	leave  
  801c67:	c3                   	ret    

00801c68 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c68:	55                   	push   %ebp
  801c69:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c6b:	b8 00 00 00 00       	mov    $0x0,%eax
  801c70:	5d                   	pop    %ebp
  801c71:	c3                   	ret    

00801c72 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c72:	55                   	push   %ebp
  801c73:	89 e5                	mov    %esp,%ebp
  801c75:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c78:	68 4e 26 80 00       	push   $0x80264e
  801c7d:	ff 75 0c             	pushl  0xc(%ebp)
  801c80:	e8 30 eb ff ff       	call   8007b5 <strcpy>
	return 0;
}
  801c85:	b8 00 00 00 00       	mov    $0x0,%eax
  801c8a:	c9                   	leave  
  801c8b:	c3                   	ret    

00801c8c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c8c:	55                   	push   %ebp
  801c8d:	89 e5                	mov    %esp,%ebp
  801c8f:	57                   	push   %edi
  801c90:	56                   	push   %esi
  801c91:	53                   	push   %ebx
  801c92:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c98:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c9d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ca3:	eb 2d                	jmp    801cd2 <devcons_write+0x46>
		m = n - tot;
  801ca5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ca8:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801caa:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801cad:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801cb2:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cb5:	83 ec 04             	sub    $0x4,%esp
  801cb8:	53                   	push   %ebx
  801cb9:	03 45 0c             	add    0xc(%ebp),%eax
  801cbc:	50                   	push   %eax
  801cbd:	57                   	push   %edi
  801cbe:	e8 84 ec ff ff       	call   800947 <memmove>
		sys_cputs(buf, m);
  801cc3:	83 c4 08             	add    $0x8,%esp
  801cc6:	53                   	push   %ebx
  801cc7:	57                   	push   %edi
  801cc8:	e8 2f ee ff ff       	call   800afc <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ccd:	01 de                	add    %ebx,%esi
  801ccf:	83 c4 10             	add    $0x10,%esp
  801cd2:	89 f0                	mov    %esi,%eax
  801cd4:	3b 75 10             	cmp    0x10(%ebp),%esi
  801cd7:	72 cc                	jb     801ca5 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801cd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cdc:	5b                   	pop    %ebx
  801cdd:	5e                   	pop    %esi
  801cde:	5f                   	pop    %edi
  801cdf:	5d                   	pop    %ebp
  801ce0:	c3                   	ret    

00801ce1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ce1:	55                   	push   %ebp
  801ce2:	89 e5                	mov    %esp,%ebp
  801ce4:	83 ec 08             	sub    $0x8,%esp
  801ce7:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801cec:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801cf0:	74 2a                	je     801d1c <devcons_read+0x3b>
  801cf2:	eb 05                	jmp    801cf9 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801cf4:	e8 a0 ee ff ff       	call   800b99 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801cf9:	e8 1c ee ff ff       	call   800b1a <sys_cgetc>
  801cfe:	85 c0                	test   %eax,%eax
  801d00:	74 f2                	je     801cf4 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d02:	85 c0                	test   %eax,%eax
  801d04:	78 16                	js     801d1c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d06:	83 f8 04             	cmp    $0x4,%eax
  801d09:	74 0c                	je     801d17 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d0b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d0e:	88 02                	mov    %al,(%edx)
	return 1;
  801d10:	b8 01 00 00 00       	mov    $0x1,%eax
  801d15:	eb 05                	jmp    801d1c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d17:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d1c:	c9                   	leave  
  801d1d:	c3                   	ret    

00801d1e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d1e:	55                   	push   %ebp
  801d1f:	89 e5                	mov    %esp,%ebp
  801d21:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d24:	8b 45 08             	mov    0x8(%ebp),%eax
  801d27:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d2a:	6a 01                	push   $0x1
  801d2c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d2f:	50                   	push   %eax
  801d30:	e8 c7 ed ff ff       	call   800afc <sys_cputs>
}
  801d35:	83 c4 10             	add    $0x10,%esp
  801d38:	c9                   	leave  
  801d39:	c3                   	ret    

00801d3a <getchar>:

int
getchar(void)
{
  801d3a:	55                   	push   %ebp
  801d3b:	89 e5                	mov    %esp,%ebp
  801d3d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d40:	6a 01                	push   $0x1
  801d42:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d45:	50                   	push   %eax
  801d46:	6a 00                	push   $0x0
  801d48:	e8 90 f6 ff ff       	call   8013dd <read>
	if (r < 0)
  801d4d:	83 c4 10             	add    $0x10,%esp
  801d50:	85 c0                	test   %eax,%eax
  801d52:	78 0f                	js     801d63 <getchar+0x29>
		return r;
	if (r < 1)
  801d54:	85 c0                	test   %eax,%eax
  801d56:	7e 06                	jle    801d5e <getchar+0x24>
		return -E_EOF;
	return c;
  801d58:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d5c:	eb 05                	jmp    801d63 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d5e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d63:	c9                   	leave  
  801d64:	c3                   	ret    

00801d65 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d65:	55                   	push   %ebp
  801d66:	89 e5                	mov    %esp,%ebp
  801d68:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d6b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d6e:	50                   	push   %eax
  801d6f:	ff 75 08             	pushl  0x8(%ebp)
  801d72:	e8 00 f4 ff ff       	call   801177 <fd_lookup>
  801d77:	83 c4 10             	add    $0x10,%esp
  801d7a:	85 c0                	test   %eax,%eax
  801d7c:	78 11                	js     801d8f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d81:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d87:	39 10                	cmp    %edx,(%eax)
  801d89:	0f 94 c0             	sete   %al
  801d8c:	0f b6 c0             	movzbl %al,%eax
}
  801d8f:	c9                   	leave  
  801d90:	c3                   	ret    

00801d91 <opencons>:

int
opencons(void)
{
  801d91:	55                   	push   %ebp
  801d92:	89 e5                	mov    %esp,%ebp
  801d94:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d97:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d9a:	50                   	push   %eax
  801d9b:	e8 88 f3 ff ff       	call   801128 <fd_alloc>
  801da0:	83 c4 10             	add    $0x10,%esp
		return r;
  801da3:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801da5:	85 c0                	test   %eax,%eax
  801da7:	78 3e                	js     801de7 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801da9:	83 ec 04             	sub    $0x4,%esp
  801dac:	68 07 04 00 00       	push   $0x407
  801db1:	ff 75 f4             	pushl  -0xc(%ebp)
  801db4:	6a 00                	push   $0x0
  801db6:	e8 fd ed ff ff       	call   800bb8 <sys_page_alloc>
  801dbb:	83 c4 10             	add    $0x10,%esp
		return r;
  801dbe:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801dc0:	85 c0                	test   %eax,%eax
  801dc2:	78 23                	js     801de7 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801dc4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801dca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dcd:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801dcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dd2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801dd9:	83 ec 0c             	sub    $0xc,%esp
  801ddc:	50                   	push   %eax
  801ddd:	e8 1f f3 ff ff       	call   801101 <fd2num>
  801de2:	89 c2                	mov    %eax,%edx
  801de4:	83 c4 10             	add    $0x10,%esp
}
  801de7:	89 d0                	mov    %edx,%eax
  801de9:	c9                   	leave  
  801dea:	c3                   	ret    

00801deb <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801deb:	55                   	push   %ebp
  801dec:	89 e5                	mov    %esp,%ebp
  801dee:	56                   	push   %esi
  801def:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801df0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801df3:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801df9:	e8 7c ed ff ff       	call   800b7a <sys_getenvid>
  801dfe:	83 ec 0c             	sub    $0xc,%esp
  801e01:	ff 75 0c             	pushl  0xc(%ebp)
  801e04:	ff 75 08             	pushl  0x8(%ebp)
  801e07:	56                   	push   %esi
  801e08:	50                   	push   %eax
  801e09:	68 5c 26 80 00       	push   $0x80265c
  801e0e:	e8 9e e3 ff ff       	call   8001b1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801e13:	83 c4 18             	add    $0x18,%esp
  801e16:	53                   	push   %ebx
  801e17:	ff 75 10             	pushl  0x10(%ebp)
  801e1a:	e8 41 e3 ff ff       	call   800160 <vcprintf>
	cprintf("\n");
  801e1f:	c7 04 24 47 26 80 00 	movl   $0x802647,(%esp)
  801e26:	e8 86 e3 ff ff       	call   8001b1 <cprintf>
  801e2b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801e2e:	cc                   	int3   
  801e2f:	eb fd                	jmp    801e2e <_panic+0x43>

00801e31 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e31:	55                   	push   %ebp
  801e32:	89 e5                	mov    %esp,%ebp
  801e34:	53                   	push   %ebx
  801e35:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801e38:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e3f:	75 28                	jne    801e69 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		void *va = (void *) (UXSTACKTOP - PGSIZE);
		envid_t envid = sys_getenvid();
  801e41:	e8 34 ed ff ff       	call   800b7a <sys_getenvid>
  801e46:	89 c3                	mov    %eax,%ebx

		sys_page_alloc(envid, va, PTE_P | PTE_U | PTE_W);
  801e48:	83 ec 04             	sub    $0x4,%esp
  801e4b:	6a 07                	push   $0x7
  801e4d:	68 00 f0 bf ee       	push   $0xeebff000
  801e52:	50                   	push   %eax
  801e53:	e8 60 ed ff ff       	call   800bb8 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801e58:	83 c4 08             	add    $0x8,%esp
  801e5b:	68 76 1e 80 00       	push   $0x801e76
  801e60:	53                   	push   %ebx
  801e61:	e8 9d ee ff ff       	call   800d03 <sys_env_set_pgfault_upcall>
  801e66:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e69:	8b 45 08             	mov    0x8(%ebp),%eax
  801e6c:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801e71:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e74:	c9                   	leave  
  801e75:	c3                   	ret    

00801e76 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp				// function argument: pointer to UTF
  801e76:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e77:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e7c:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e7e:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp, %ebx		// 40 = size between utf_fault_va ~ utf_regs
  801e81:	89 e3                	mov    %esp,%ebx
	movl 40(%esp), %eax // point to utf_eip
  801e83:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %esp // point to utf_esp
  801e87:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax 			// push eip of utf
  801e8b:	50                   	push   %eax

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx, %esp 	// back to origin exception stack
  801e8c:	89 dc                	mov    %ebx,%esp
	subl $4, 48(%esp) 	// utf_esp - 4
  801e8e:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	popl %eax  			// pop utf_fault_va (ignore)
  801e93:	58                   	pop    %eax
	popl %eax  			// pop utf_err (ignore)
  801e94:	58                   	pop    %eax
	popal 				// pop utf_regs 
  801e95:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4, %esp 		// ignore utf_eip
  801e96:	83 c4 04             	add    $0x4,%esp
	popfl 				// restore utf_eflags to eflags
  801e99:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp  			// restore %esp = utf_esp
  801e9a:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e9b:	c3                   	ret    

00801e9c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e9c:	55                   	push   %ebp
  801e9d:	89 e5                	mov    %esp,%ebp
  801e9f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ea2:	89 d0                	mov    %edx,%eax
  801ea4:	c1 e8 16             	shr    $0x16,%eax
  801ea7:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801eae:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801eb3:	f6 c1 01             	test   $0x1,%cl
  801eb6:	74 1d                	je     801ed5 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801eb8:	c1 ea 0c             	shr    $0xc,%edx
  801ebb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ec2:	f6 c2 01             	test   $0x1,%dl
  801ec5:	74 0e                	je     801ed5 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ec7:	c1 ea 0c             	shr    $0xc,%edx
  801eca:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801ed1:	ef 
  801ed2:	0f b7 c0             	movzwl %ax,%eax
}
  801ed5:	5d                   	pop    %ebp
  801ed6:	c3                   	ret    
  801ed7:	66 90                	xchg   %ax,%ax
  801ed9:	66 90                	xchg   %ax,%ax
  801edb:	66 90                	xchg   %ax,%ax
  801edd:	66 90                	xchg   %ax,%ax
  801edf:	90                   	nop

00801ee0 <__udivdi3>:
  801ee0:	55                   	push   %ebp
  801ee1:	57                   	push   %edi
  801ee2:	56                   	push   %esi
  801ee3:	53                   	push   %ebx
  801ee4:	83 ec 1c             	sub    $0x1c,%esp
  801ee7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801eeb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801eef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801ef3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ef7:	85 f6                	test   %esi,%esi
  801ef9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801efd:	89 ca                	mov    %ecx,%edx
  801eff:	89 f8                	mov    %edi,%eax
  801f01:	75 3d                	jne    801f40 <__udivdi3+0x60>
  801f03:	39 cf                	cmp    %ecx,%edi
  801f05:	0f 87 c5 00 00 00    	ja     801fd0 <__udivdi3+0xf0>
  801f0b:	85 ff                	test   %edi,%edi
  801f0d:	89 fd                	mov    %edi,%ebp
  801f0f:	75 0b                	jne    801f1c <__udivdi3+0x3c>
  801f11:	b8 01 00 00 00       	mov    $0x1,%eax
  801f16:	31 d2                	xor    %edx,%edx
  801f18:	f7 f7                	div    %edi
  801f1a:	89 c5                	mov    %eax,%ebp
  801f1c:	89 c8                	mov    %ecx,%eax
  801f1e:	31 d2                	xor    %edx,%edx
  801f20:	f7 f5                	div    %ebp
  801f22:	89 c1                	mov    %eax,%ecx
  801f24:	89 d8                	mov    %ebx,%eax
  801f26:	89 cf                	mov    %ecx,%edi
  801f28:	f7 f5                	div    %ebp
  801f2a:	89 c3                	mov    %eax,%ebx
  801f2c:	89 d8                	mov    %ebx,%eax
  801f2e:	89 fa                	mov    %edi,%edx
  801f30:	83 c4 1c             	add    $0x1c,%esp
  801f33:	5b                   	pop    %ebx
  801f34:	5e                   	pop    %esi
  801f35:	5f                   	pop    %edi
  801f36:	5d                   	pop    %ebp
  801f37:	c3                   	ret    
  801f38:	90                   	nop
  801f39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f40:	39 ce                	cmp    %ecx,%esi
  801f42:	77 74                	ja     801fb8 <__udivdi3+0xd8>
  801f44:	0f bd fe             	bsr    %esi,%edi
  801f47:	83 f7 1f             	xor    $0x1f,%edi
  801f4a:	0f 84 98 00 00 00    	je     801fe8 <__udivdi3+0x108>
  801f50:	bb 20 00 00 00       	mov    $0x20,%ebx
  801f55:	89 f9                	mov    %edi,%ecx
  801f57:	89 c5                	mov    %eax,%ebp
  801f59:	29 fb                	sub    %edi,%ebx
  801f5b:	d3 e6                	shl    %cl,%esi
  801f5d:	89 d9                	mov    %ebx,%ecx
  801f5f:	d3 ed                	shr    %cl,%ebp
  801f61:	89 f9                	mov    %edi,%ecx
  801f63:	d3 e0                	shl    %cl,%eax
  801f65:	09 ee                	or     %ebp,%esi
  801f67:	89 d9                	mov    %ebx,%ecx
  801f69:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f6d:	89 d5                	mov    %edx,%ebp
  801f6f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f73:	d3 ed                	shr    %cl,%ebp
  801f75:	89 f9                	mov    %edi,%ecx
  801f77:	d3 e2                	shl    %cl,%edx
  801f79:	89 d9                	mov    %ebx,%ecx
  801f7b:	d3 e8                	shr    %cl,%eax
  801f7d:	09 c2                	or     %eax,%edx
  801f7f:	89 d0                	mov    %edx,%eax
  801f81:	89 ea                	mov    %ebp,%edx
  801f83:	f7 f6                	div    %esi
  801f85:	89 d5                	mov    %edx,%ebp
  801f87:	89 c3                	mov    %eax,%ebx
  801f89:	f7 64 24 0c          	mull   0xc(%esp)
  801f8d:	39 d5                	cmp    %edx,%ebp
  801f8f:	72 10                	jb     801fa1 <__udivdi3+0xc1>
  801f91:	8b 74 24 08          	mov    0x8(%esp),%esi
  801f95:	89 f9                	mov    %edi,%ecx
  801f97:	d3 e6                	shl    %cl,%esi
  801f99:	39 c6                	cmp    %eax,%esi
  801f9b:	73 07                	jae    801fa4 <__udivdi3+0xc4>
  801f9d:	39 d5                	cmp    %edx,%ebp
  801f9f:	75 03                	jne    801fa4 <__udivdi3+0xc4>
  801fa1:	83 eb 01             	sub    $0x1,%ebx
  801fa4:	31 ff                	xor    %edi,%edi
  801fa6:	89 d8                	mov    %ebx,%eax
  801fa8:	89 fa                	mov    %edi,%edx
  801faa:	83 c4 1c             	add    $0x1c,%esp
  801fad:	5b                   	pop    %ebx
  801fae:	5e                   	pop    %esi
  801faf:	5f                   	pop    %edi
  801fb0:	5d                   	pop    %ebp
  801fb1:	c3                   	ret    
  801fb2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801fb8:	31 ff                	xor    %edi,%edi
  801fba:	31 db                	xor    %ebx,%ebx
  801fbc:	89 d8                	mov    %ebx,%eax
  801fbe:	89 fa                	mov    %edi,%edx
  801fc0:	83 c4 1c             	add    $0x1c,%esp
  801fc3:	5b                   	pop    %ebx
  801fc4:	5e                   	pop    %esi
  801fc5:	5f                   	pop    %edi
  801fc6:	5d                   	pop    %ebp
  801fc7:	c3                   	ret    
  801fc8:	90                   	nop
  801fc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fd0:	89 d8                	mov    %ebx,%eax
  801fd2:	f7 f7                	div    %edi
  801fd4:	31 ff                	xor    %edi,%edi
  801fd6:	89 c3                	mov    %eax,%ebx
  801fd8:	89 d8                	mov    %ebx,%eax
  801fda:	89 fa                	mov    %edi,%edx
  801fdc:	83 c4 1c             	add    $0x1c,%esp
  801fdf:	5b                   	pop    %ebx
  801fe0:	5e                   	pop    %esi
  801fe1:	5f                   	pop    %edi
  801fe2:	5d                   	pop    %ebp
  801fe3:	c3                   	ret    
  801fe4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fe8:	39 ce                	cmp    %ecx,%esi
  801fea:	72 0c                	jb     801ff8 <__udivdi3+0x118>
  801fec:	31 db                	xor    %ebx,%ebx
  801fee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801ff2:	0f 87 34 ff ff ff    	ja     801f2c <__udivdi3+0x4c>
  801ff8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801ffd:	e9 2a ff ff ff       	jmp    801f2c <__udivdi3+0x4c>
  802002:	66 90                	xchg   %ax,%ax
  802004:	66 90                	xchg   %ax,%ax
  802006:	66 90                	xchg   %ax,%ax
  802008:	66 90                	xchg   %ax,%ax
  80200a:	66 90                	xchg   %ax,%ax
  80200c:	66 90                	xchg   %ax,%ax
  80200e:	66 90                	xchg   %ax,%ax

00802010 <__umoddi3>:
  802010:	55                   	push   %ebp
  802011:	57                   	push   %edi
  802012:	56                   	push   %esi
  802013:	53                   	push   %ebx
  802014:	83 ec 1c             	sub    $0x1c,%esp
  802017:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80201b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80201f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802023:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802027:	85 d2                	test   %edx,%edx
  802029:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80202d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802031:	89 f3                	mov    %esi,%ebx
  802033:	89 3c 24             	mov    %edi,(%esp)
  802036:	89 74 24 04          	mov    %esi,0x4(%esp)
  80203a:	75 1c                	jne    802058 <__umoddi3+0x48>
  80203c:	39 f7                	cmp    %esi,%edi
  80203e:	76 50                	jbe    802090 <__umoddi3+0x80>
  802040:	89 c8                	mov    %ecx,%eax
  802042:	89 f2                	mov    %esi,%edx
  802044:	f7 f7                	div    %edi
  802046:	89 d0                	mov    %edx,%eax
  802048:	31 d2                	xor    %edx,%edx
  80204a:	83 c4 1c             	add    $0x1c,%esp
  80204d:	5b                   	pop    %ebx
  80204e:	5e                   	pop    %esi
  80204f:	5f                   	pop    %edi
  802050:	5d                   	pop    %ebp
  802051:	c3                   	ret    
  802052:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802058:	39 f2                	cmp    %esi,%edx
  80205a:	89 d0                	mov    %edx,%eax
  80205c:	77 52                	ja     8020b0 <__umoddi3+0xa0>
  80205e:	0f bd ea             	bsr    %edx,%ebp
  802061:	83 f5 1f             	xor    $0x1f,%ebp
  802064:	75 5a                	jne    8020c0 <__umoddi3+0xb0>
  802066:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80206a:	0f 82 e0 00 00 00    	jb     802150 <__umoddi3+0x140>
  802070:	39 0c 24             	cmp    %ecx,(%esp)
  802073:	0f 86 d7 00 00 00    	jbe    802150 <__umoddi3+0x140>
  802079:	8b 44 24 08          	mov    0x8(%esp),%eax
  80207d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802081:	83 c4 1c             	add    $0x1c,%esp
  802084:	5b                   	pop    %ebx
  802085:	5e                   	pop    %esi
  802086:	5f                   	pop    %edi
  802087:	5d                   	pop    %ebp
  802088:	c3                   	ret    
  802089:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802090:	85 ff                	test   %edi,%edi
  802092:	89 fd                	mov    %edi,%ebp
  802094:	75 0b                	jne    8020a1 <__umoddi3+0x91>
  802096:	b8 01 00 00 00       	mov    $0x1,%eax
  80209b:	31 d2                	xor    %edx,%edx
  80209d:	f7 f7                	div    %edi
  80209f:	89 c5                	mov    %eax,%ebp
  8020a1:	89 f0                	mov    %esi,%eax
  8020a3:	31 d2                	xor    %edx,%edx
  8020a5:	f7 f5                	div    %ebp
  8020a7:	89 c8                	mov    %ecx,%eax
  8020a9:	f7 f5                	div    %ebp
  8020ab:	89 d0                	mov    %edx,%eax
  8020ad:	eb 99                	jmp    802048 <__umoddi3+0x38>
  8020af:	90                   	nop
  8020b0:	89 c8                	mov    %ecx,%eax
  8020b2:	89 f2                	mov    %esi,%edx
  8020b4:	83 c4 1c             	add    $0x1c,%esp
  8020b7:	5b                   	pop    %ebx
  8020b8:	5e                   	pop    %esi
  8020b9:	5f                   	pop    %edi
  8020ba:	5d                   	pop    %ebp
  8020bb:	c3                   	ret    
  8020bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020c0:	8b 34 24             	mov    (%esp),%esi
  8020c3:	bf 20 00 00 00       	mov    $0x20,%edi
  8020c8:	89 e9                	mov    %ebp,%ecx
  8020ca:	29 ef                	sub    %ebp,%edi
  8020cc:	d3 e0                	shl    %cl,%eax
  8020ce:	89 f9                	mov    %edi,%ecx
  8020d0:	89 f2                	mov    %esi,%edx
  8020d2:	d3 ea                	shr    %cl,%edx
  8020d4:	89 e9                	mov    %ebp,%ecx
  8020d6:	09 c2                	or     %eax,%edx
  8020d8:	89 d8                	mov    %ebx,%eax
  8020da:	89 14 24             	mov    %edx,(%esp)
  8020dd:	89 f2                	mov    %esi,%edx
  8020df:	d3 e2                	shl    %cl,%edx
  8020e1:	89 f9                	mov    %edi,%ecx
  8020e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8020e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8020eb:	d3 e8                	shr    %cl,%eax
  8020ed:	89 e9                	mov    %ebp,%ecx
  8020ef:	89 c6                	mov    %eax,%esi
  8020f1:	d3 e3                	shl    %cl,%ebx
  8020f3:	89 f9                	mov    %edi,%ecx
  8020f5:	89 d0                	mov    %edx,%eax
  8020f7:	d3 e8                	shr    %cl,%eax
  8020f9:	89 e9                	mov    %ebp,%ecx
  8020fb:	09 d8                	or     %ebx,%eax
  8020fd:	89 d3                	mov    %edx,%ebx
  8020ff:	89 f2                	mov    %esi,%edx
  802101:	f7 34 24             	divl   (%esp)
  802104:	89 d6                	mov    %edx,%esi
  802106:	d3 e3                	shl    %cl,%ebx
  802108:	f7 64 24 04          	mull   0x4(%esp)
  80210c:	39 d6                	cmp    %edx,%esi
  80210e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802112:	89 d1                	mov    %edx,%ecx
  802114:	89 c3                	mov    %eax,%ebx
  802116:	72 08                	jb     802120 <__umoddi3+0x110>
  802118:	75 11                	jne    80212b <__umoddi3+0x11b>
  80211a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80211e:	73 0b                	jae    80212b <__umoddi3+0x11b>
  802120:	2b 44 24 04          	sub    0x4(%esp),%eax
  802124:	1b 14 24             	sbb    (%esp),%edx
  802127:	89 d1                	mov    %edx,%ecx
  802129:	89 c3                	mov    %eax,%ebx
  80212b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80212f:	29 da                	sub    %ebx,%edx
  802131:	19 ce                	sbb    %ecx,%esi
  802133:	89 f9                	mov    %edi,%ecx
  802135:	89 f0                	mov    %esi,%eax
  802137:	d3 e0                	shl    %cl,%eax
  802139:	89 e9                	mov    %ebp,%ecx
  80213b:	d3 ea                	shr    %cl,%edx
  80213d:	89 e9                	mov    %ebp,%ecx
  80213f:	d3 ee                	shr    %cl,%esi
  802141:	09 d0                	or     %edx,%eax
  802143:	89 f2                	mov    %esi,%edx
  802145:	83 c4 1c             	add    $0x1c,%esp
  802148:	5b                   	pop    %ebx
  802149:	5e                   	pop    %esi
  80214a:	5f                   	pop    %edi
  80214b:	5d                   	pop    %ebp
  80214c:	c3                   	ret    
  80214d:	8d 76 00             	lea    0x0(%esi),%esi
  802150:	29 f9                	sub    %edi,%ecx
  802152:	19 d6                	sbb    %edx,%esi
  802154:	89 74 24 04          	mov    %esi,0x4(%esp)
  802158:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80215c:	e9 18 ff ff ff       	jmp    802079 <__umoddi3+0x69>
