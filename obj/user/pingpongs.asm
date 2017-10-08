
obj/user/pingpongs.debug：     文件格式 elf32-i386


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
  80002c:	e8 cd 00 00 00       	call   8000fe <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003c:	e8 e7 0f 00 00       	call   801028 <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 42                	je     80008a <umain+0x57>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800048:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  80004e:	e8 67 0b 00 00       	call   800bba <sys_getenvid>
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	53                   	push   %ebx
  800057:	50                   	push   %eax
  800058:	68 c0 21 80 00       	push   $0x8021c0
  80005d:	e8 8f 01 00 00       	call   8001f1 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800062:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800065:	e8 50 0b 00 00       	call   800bba <sys_getenvid>
  80006a:	83 c4 0c             	add    $0xc,%esp
  80006d:	53                   	push   %ebx
  80006e:	50                   	push   %eax
  80006f:	68 da 21 80 00       	push   $0x8021da
  800074:	e8 78 01 00 00       	call   8001f1 <cprintf>
		ipc_send(who, 0, 0, 0);
  800079:	6a 00                	push   $0x0
  80007b:	6a 00                	push   $0x0
  80007d:	6a 00                	push   $0x0
  80007f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800082:	e8 2d 10 00 00       	call   8010b4 <ipc_send>
  800087:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80008a:	83 ec 04             	sub    $0x4,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	6a 00                	push   $0x0
  800091:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800094:	50                   	push   %eax
  800095:	e8 a8 0f 00 00       	call   801042 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  80009a:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  8000a0:	8b 7b 48             	mov    0x48(%ebx),%edi
  8000a3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a6:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8000ae:	e8 07 0b 00 00       	call   800bba <sys_getenvid>
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	57                   	push   %edi
  8000b7:	53                   	push   %ebx
  8000b8:	56                   	push   %esi
  8000b9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8000bc:	50                   	push   %eax
  8000bd:	68 f0 21 80 00       	push   $0x8021f0
  8000c2:	e8 2a 01 00 00       	call   8001f1 <cprintf>
		if (val == 10)
  8000c7:	a1 04 40 80 00       	mov    0x804004,%eax
  8000cc:	83 c4 20             	add    $0x20,%esp
  8000cf:	83 f8 0a             	cmp    $0xa,%eax
  8000d2:	74 22                	je     8000f6 <umain+0xc3>
			return;
		++val;
  8000d4:	83 c0 01             	add    $0x1,%eax
  8000d7:	a3 04 40 80 00       	mov    %eax,0x804004
		ipc_send(who, 0, 0, 0);
  8000dc:	6a 00                	push   $0x0
  8000de:	6a 00                	push   $0x0
  8000e0:	6a 00                	push   $0x0
  8000e2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000e5:	e8 ca 0f 00 00       	call   8010b4 <ipc_send>
		if (val == 10)
  8000ea:	83 c4 10             	add    $0x10,%esp
  8000ed:	83 3d 04 40 80 00 0a 	cmpl   $0xa,0x804004
  8000f4:	75 94                	jne    80008a <umain+0x57>
			return;
	}

}
  8000f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f9:	5b                   	pop    %ebx
  8000fa:	5e                   	pop    %esi
  8000fb:	5f                   	pop    %edi
  8000fc:	5d                   	pop    %ebp
  8000fd:	c3                   	ret    

008000fe <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000fe:	55                   	push   %ebp
  8000ff:	89 e5                	mov    %esp,%ebp
  800101:	56                   	push   %esi
  800102:	53                   	push   %ebx
  800103:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800106:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800109:	e8 ac 0a 00 00       	call   800bba <sys_getenvid>
  80010e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800113:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800116:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80011b:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800120:	85 db                	test   %ebx,%ebx
  800122:	7e 07                	jle    80012b <libmain+0x2d>
		binaryname = argv[0];
  800124:	8b 06                	mov    (%esi),%eax
  800126:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80012b:	83 ec 08             	sub    $0x8,%esp
  80012e:	56                   	push   %esi
  80012f:	53                   	push   %ebx
  800130:	e8 fe fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800135:	e8 0a 00 00 00       	call   800144 <exit>
}
  80013a:	83 c4 10             	add    $0x10,%esp
  80013d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800140:	5b                   	pop    %ebx
  800141:	5e                   	pop    %esi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80014a:	e8 bd 11 00 00       	call   80130c <close_all>
	sys_env_destroy(0);
  80014f:	83 ec 0c             	sub    $0xc,%esp
  800152:	6a 00                	push   $0x0
  800154:	e8 20 0a 00 00       	call   800b79 <sys_env_destroy>
}
  800159:	83 c4 10             	add    $0x10,%esp
  80015c:	c9                   	leave  
  80015d:	c3                   	ret    

0080015e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015e:	55                   	push   %ebp
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	53                   	push   %ebx
  800162:	83 ec 04             	sub    $0x4,%esp
  800165:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800168:	8b 13                	mov    (%ebx),%edx
  80016a:	8d 42 01             	lea    0x1(%edx),%eax
  80016d:	89 03                	mov    %eax,(%ebx)
  80016f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800172:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800176:	3d ff 00 00 00       	cmp    $0xff,%eax
  80017b:	75 1a                	jne    800197 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80017d:	83 ec 08             	sub    $0x8,%esp
  800180:	68 ff 00 00 00       	push   $0xff
  800185:	8d 43 08             	lea    0x8(%ebx),%eax
  800188:	50                   	push   %eax
  800189:	e8 ae 09 00 00       	call   800b3c <sys_cputs>
		b->idx = 0;
  80018e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800194:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800197:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80019b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80019e:	c9                   	leave  
  80019f:	c3                   	ret    

008001a0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b0:	00 00 00 
	b.cnt = 0;
  8001b3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ba:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001bd:	ff 75 0c             	pushl  0xc(%ebp)
  8001c0:	ff 75 08             	pushl  0x8(%ebp)
  8001c3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c9:	50                   	push   %eax
  8001ca:	68 5e 01 80 00       	push   $0x80015e
  8001cf:	e8 1a 01 00 00       	call   8002ee <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d4:	83 c4 08             	add    $0x8,%esp
  8001d7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001dd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e3:	50                   	push   %eax
  8001e4:	e8 53 09 00 00       	call   800b3c <sys_cputs>

	return b.cnt;
}
  8001e9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ef:	c9                   	leave  
  8001f0:	c3                   	ret    

008001f1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f1:	55                   	push   %ebp
  8001f2:	89 e5                	mov    %esp,%ebp
  8001f4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001fa:	50                   	push   %eax
  8001fb:	ff 75 08             	pushl  0x8(%ebp)
  8001fe:	e8 9d ff ff ff       	call   8001a0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800203:	c9                   	leave  
  800204:	c3                   	ret    

00800205 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800205:	55                   	push   %ebp
  800206:	89 e5                	mov    %esp,%ebp
  800208:	57                   	push   %edi
  800209:	56                   	push   %esi
  80020a:	53                   	push   %ebx
  80020b:	83 ec 1c             	sub    $0x1c,%esp
  80020e:	89 c7                	mov    %eax,%edi
  800210:	89 d6                	mov    %edx,%esi
  800212:	8b 45 08             	mov    0x8(%ebp),%eax
  800215:	8b 55 0c             	mov    0xc(%ebp),%edx
  800218:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80021b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80021e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800221:	bb 00 00 00 00       	mov    $0x0,%ebx
  800226:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800229:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80022c:	39 d3                	cmp    %edx,%ebx
  80022e:	72 05                	jb     800235 <printnum+0x30>
  800230:	39 45 10             	cmp    %eax,0x10(%ebp)
  800233:	77 45                	ja     80027a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800235:	83 ec 0c             	sub    $0xc,%esp
  800238:	ff 75 18             	pushl  0x18(%ebp)
  80023b:	8b 45 14             	mov    0x14(%ebp),%eax
  80023e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800241:	53                   	push   %ebx
  800242:	ff 75 10             	pushl  0x10(%ebp)
  800245:	83 ec 08             	sub    $0x8,%esp
  800248:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024b:	ff 75 e0             	pushl  -0x20(%ebp)
  80024e:	ff 75 dc             	pushl  -0x24(%ebp)
  800251:	ff 75 d8             	pushl  -0x28(%ebp)
  800254:	e8 c7 1c 00 00       	call   801f20 <__udivdi3>
  800259:	83 c4 18             	add    $0x18,%esp
  80025c:	52                   	push   %edx
  80025d:	50                   	push   %eax
  80025e:	89 f2                	mov    %esi,%edx
  800260:	89 f8                	mov    %edi,%eax
  800262:	e8 9e ff ff ff       	call   800205 <printnum>
  800267:	83 c4 20             	add    $0x20,%esp
  80026a:	eb 18                	jmp    800284 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80026c:	83 ec 08             	sub    $0x8,%esp
  80026f:	56                   	push   %esi
  800270:	ff 75 18             	pushl  0x18(%ebp)
  800273:	ff d7                	call   *%edi
  800275:	83 c4 10             	add    $0x10,%esp
  800278:	eb 03                	jmp    80027d <printnum+0x78>
  80027a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80027d:	83 eb 01             	sub    $0x1,%ebx
  800280:	85 db                	test   %ebx,%ebx
  800282:	7f e8                	jg     80026c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800284:	83 ec 08             	sub    $0x8,%esp
  800287:	56                   	push   %esi
  800288:	83 ec 04             	sub    $0x4,%esp
  80028b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028e:	ff 75 e0             	pushl  -0x20(%ebp)
  800291:	ff 75 dc             	pushl  -0x24(%ebp)
  800294:	ff 75 d8             	pushl  -0x28(%ebp)
  800297:	e8 b4 1d 00 00       	call   802050 <__umoddi3>
  80029c:	83 c4 14             	add    $0x14,%esp
  80029f:	0f be 80 20 22 80 00 	movsbl 0x802220(%eax),%eax
  8002a6:	50                   	push   %eax
  8002a7:	ff d7                	call   *%edi
}
  8002a9:	83 c4 10             	add    $0x10,%esp
  8002ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002af:	5b                   	pop    %ebx
  8002b0:	5e                   	pop    %esi
  8002b1:	5f                   	pop    %edi
  8002b2:	5d                   	pop    %ebp
  8002b3:	c3                   	ret    

008002b4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
  8002b7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ba:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002be:	8b 10                	mov    (%eax),%edx
  8002c0:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c3:	73 0a                	jae    8002cf <sprintputch+0x1b>
		*b->buf++ = ch;
  8002c5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c8:	89 08                	mov    %ecx,(%eax)
  8002ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cd:	88 02                	mov    %al,(%edx)
}
  8002cf:	5d                   	pop    %ebp
  8002d0:	c3                   	ret    

008002d1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002d1:	55                   	push   %ebp
  8002d2:	89 e5                	mov    %esp,%ebp
  8002d4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002da:	50                   	push   %eax
  8002db:	ff 75 10             	pushl  0x10(%ebp)
  8002de:	ff 75 0c             	pushl  0xc(%ebp)
  8002e1:	ff 75 08             	pushl  0x8(%ebp)
  8002e4:	e8 05 00 00 00       	call   8002ee <vprintfmt>
	va_end(ap);
}
  8002e9:	83 c4 10             	add    $0x10,%esp
  8002ec:	c9                   	leave  
  8002ed:	c3                   	ret    

008002ee <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
  8002f1:	57                   	push   %edi
  8002f2:	56                   	push   %esi
  8002f3:	53                   	push   %ebx
  8002f4:	83 ec 2c             	sub    $0x2c,%esp
  8002f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8002fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002fd:	8b 7d 10             	mov    0x10(%ebp),%edi
  800300:	eb 12                	jmp    800314 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800302:	85 c0                	test   %eax,%eax
  800304:	0f 84 42 04 00 00    	je     80074c <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  80030a:	83 ec 08             	sub    $0x8,%esp
  80030d:	53                   	push   %ebx
  80030e:	50                   	push   %eax
  80030f:	ff d6                	call   *%esi
  800311:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800314:	83 c7 01             	add    $0x1,%edi
  800317:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80031b:	83 f8 25             	cmp    $0x25,%eax
  80031e:	75 e2                	jne    800302 <vprintfmt+0x14>
  800320:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800324:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80032b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800332:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800339:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033e:	eb 07                	jmp    800347 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800340:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800343:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800347:	8d 47 01             	lea    0x1(%edi),%eax
  80034a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80034d:	0f b6 07             	movzbl (%edi),%eax
  800350:	0f b6 d0             	movzbl %al,%edx
  800353:	83 e8 23             	sub    $0x23,%eax
  800356:	3c 55                	cmp    $0x55,%al
  800358:	0f 87 d3 03 00 00    	ja     800731 <vprintfmt+0x443>
  80035e:	0f b6 c0             	movzbl %al,%eax
  800361:	ff 24 85 60 23 80 00 	jmp    *0x802360(,%eax,4)
  800368:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80036b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80036f:	eb d6                	jmp    800347 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800371:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800374:	b8 00 00 00 00       	mov    $0x0,%eax
  800379:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80037c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80037f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800383:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800386:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800389:	83 f9 09             	cmp    $0x9,%ecx
  80038c:	77 3f                	ja     8003cd <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80038e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800391:	eb e9                	jmp    80037c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800393:	8b 45 14             	mov    0x14(%ebp),%eax
  800396:	8b 00                	mov    (%eax),%eax
  800398:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80039b:	8b 45 14             	mov    0x14(%ebp),%eax
  80039e:	8d 40 04             	lea    0x4(%eax),%eax
  8003a1:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003a7:	eb 2a                	jmp    8003d3 <vprintfmt+0xe5>
  8003a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ac:	85 c0                	test   %eax,%eax
  8003ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b3:	0f 49 d0             	cmovns %eax,%edx
  8003b6:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003bc:	eb 89                	jmp    800347 <vprintfmt+0x59>
  8003be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003c1:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003c8:	e9 7a ff ff ff       	jmp    800347 <vprintfmt+0x59>
  8003cd:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003d0:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003d3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003d7:	0f 89 6a ff ff ff    	jns    800347 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003dd:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003e3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003ea:	e9 58 ff ff ff       	jmp    800347 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003ef:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003f5:	e9 4d ff ff ff       	jmp    800347 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fd:	8d 78 04             	lea    0x4(%eax),%edi
  800400:	83 ec 08             	sub    $0x8,%esp
  800403:	53                   	push   %ebx
  800404:	ff 30                	pushl  (%eax)
  800406:	ff d6                	call   *%esi
			break;
  800408:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80040b:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800411:	e9 fe fe ff ff       	jmp    800314 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800416:	8b 45 14             	mov    0x14(%ebp),%eax
  800419:	8d 78 04             	lea    0x4(%eax),%edi
  80041c:	8b 00                	mov    (%eax),%eax
  80041e:	99                   	cltd   
  80041f:	31 d0                	xor    %edx,%eax
  800421:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800423:	83 f8 0f             	cmp    $0xf,%eax
  800426:	7f 0b                	jg     800433 <vprintfmt+0x145>
  800428:	8b 14 85 c0 24 80 00 	mov    0x8024c0(,%eax,4),%edx
  80042f:	85 d2                	test   %edx,%edx
  800431:	75 1b                	jne    80044e <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800433:	50                   	push   %eax
  800434:	68 38 22 80 00       	push   $0x802238
  800439:	53                   	push   %ebx
  80043a:	56                   	push   %esi
  80043b:	e8 91 fe ff ff       	call   8002d1 <printfmt>
  800440:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800443:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800446:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800449:	e9 c6 fe ff ff       	jmp    800314 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80044e:	52                   	push   %edx
  80044f:	68 75 26 80 00       	push   $0x802675
  800454:	53                   	push   %ebx
  800455:	56                   	push   %esi
  800456:	e8 76 fe ff ff       	call   8002d1 <printfmt>
  80045b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80045e:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800461:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800464:	e9 ab fe ff ff       	jmp    800314 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800469:	8b 45 14             	mov    0x14(%ebp),%eax
  80046c:	83 c0 04             	add    $0x4,%eax
  80046f:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800472:	8b 45 14             	mov    0x14(%ebp),%eax
  800475:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800477:	85 ff                	test   %edi,%edi
  800479:	b8 31 22 80 00       	mov    $0x802231,%eax
  80047e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800481:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800485:	0f 8e 94 00 00 00    	jle    80051f <vprintfmt+0x231>
  80048b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80048f:	0f 84 98 00 00 00    	je     80052d <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800495:	83 ec 08             	sub    $0x8,%esp
  800498:	ff 75 d0             	pushl  -0x30(%ebp)
  80049b:	57                   	push   %edi
  80049c:	e8 33 03 00 00       	call   8007d4 <strnlen>
  8004a1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004a4:	29 c1                	sub    %eax,%ecx
  8004a6:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004a9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004ac:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004b0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004b6:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b8:	eb 0f                	jmp    8004c9 <vprintfmt+0x1db>
					putch(padc, putdat);
  8004ba:	83 ec 08             	sub    $0x8,%esp
  8004bd:	53                   	push   %ebx
  8004be:	ff 75 e0             	pushl  -0x20(%ebp)
  8004c1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c3:	83 ef 01             	sub    $0x1,%edi
  8004c6:	83 c4 10             	add    $0x10,%esp
  8004c9:	85 ff                	test   %edi,%edi
  8004cb:	7f ed                	jg     8004ba <vprintfmt+0x1cc>
  8004cd:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004d0:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004d3:	85 c9                	test   %ecx,%ecx
  8004d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8004da:	0f 49 c1             	cmovns %ecx,%eax
  8004dd:	29 c1                	sub    %eax,%ecx
  8004df:	89 75 08             	mov    %esi,0x8(%ebp)
  8004e2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004e5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004e8:	89 cb                	mov    %ecx,%ebx
  8004ea:	eb 4d                	jmp    800539 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004ec:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004f0:	74 1b                	je     80050d <vprintfmt+0x21f>
  8004f2:	0f be c0             	movsbl %al,%eax
  8004f5:	83 e8 20             	sub    $0x20,%eax
  8004f8:	83 f8 5e             	cmp    $0x5e,%eax
  8004fb:	76 10                	jbe    80050d <vprintfmt+0x21f>
					putch('?', putdat);
  8004fd:	83 ec 08             	sub    $0x8,%esp
  800500:	ff 75 0c             	pushl  0xc(%ebp)
  800503:	6a 3f                	push   $0x3f
  800505:	ff 55 08             	call   *0x8(%ebp)
  800508:	83 c4 10             	add    $0x10,%esp
  80050b:	eb 0d                	jmp    80051a <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80050d:	83 ec 08             	sub    $0x8,%esp
  800510:	ff 75 0c             	pushl  0xc(%ebp)
  800513:	52                   	push   %edx
  800514:	ff 55 08             	call   *0x8(%ebp)
  800517:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80051a:	83 eb 01             	sub    $0x1,%ebx
  80051d:	eb 1a                	jmp    800539 <vprintfmt+0x24b>
  80051f:	89 75 08             	mov    %esi,0x8(%ebp)
  800522:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800525:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800528:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80052b:	eb 0c                	jmp    800539 <vprintfmt+0x24b>
  80052d:	89 75 08             	mov    %esi,0x8(%ebp)
  800530:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800533:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800536:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800539:	83 c7 01             	add    $0x1,%edi
  80053c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800540:	0f be d0             	movsbl %al,%edx
  800543:	85 d2                	test   %edx,%edx
  800545:	74 23                	je     80056a <vprintfmt+0x27c>
  800547:	85 f6                	test   %esi,%esi
  800549:	78 a1                	js     8004ec <vprintfmt+0x1fe>
  80054b:	83 ee 01             	sub    $0x1,%esi
  80054e:	79 9c                	jns    8004ec <vprintfmt+0x1fe>
  800550:	89 df                	mov    %ebx,%edi
  800552:	8b 75 08             	mov    0x8(%ebp),%esi
  800555:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800558:	eb 18                	jmp    800572 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80055a:	83 ec 08             	sub    $0x8,%esp
  80055d:	53                   	push   %ebx
  80055e:	6a 20                	push   $0x20
  800560:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800562:	83 ef 01             	sub    $0x1,%edi
  800565:	83 c4 10             	add    $0x10,%esp
  800568:	eb 08                	jmp    800572 <vprintfmt+0x284>
  80056a:	89 df                	mov    %ebx,%edi
  80056c:	8b 75 08             	mov    0x8(%ebp),%esi
  80056f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800572:	85 ff                	test   %edi,%edi
  800574:	7f e4                	jg     80055a <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800576:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800579:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80057f:	e9 90 fd ff ff       	jmp    800314 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800584:	83 f9 01             	cmp    $0x1,%ecx
  800587:	7e 19                	jle    8005a2 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800589:	8b 45 14             	mov    0x14(%ebp),%eax
  80058c:	8b 50 04             	mov    0x4(%eax),%edx
  80058f:	8b 00                	mov    (%eax),%eax
  800591:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800594:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800597:	8b 45 14             	mov    0x14(%ebp),%eax
  80059a:	8d 40 08             	lea    0x8(%eax),%eax
  80059d:	89 45 14             	mov    %eax,0x14(%ebp)
  8005a0:	eb 38                	jmp    8005da <vprintfmt+0x2ec>
	else if (lflag)
  8005a2:	85 c9                	test   %ecx,%ecx
  8005a4:	74 1b                	je     8005c1 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8005a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a9:	8b 00                	mov    (%eax),%eax
  8005ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ae:	89 c1                	mov    %eax,%ecx
  8005b0:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b9:	8d 40 04             	lea    0x4(%eax),%eax
  8005bc:	89 45 14             	mov    %eax,0x14(%ebp)
  8005bf:	eb 19                	jmp    8005da <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8005c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c4:	8b 00                	mov    (%eax),%eax
  8005c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c9:	89 c1                	mov    %eax,%ecx
  8005cb:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ce:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d4:	8d 40 04             	lea    0x4(%eax),%eax
  8005d7:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005da:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005dd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005e0:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005e5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005e9:	0f 89 0e 01 00 00    	jns    8006fd <vprintfmt+0x40f>
				putch('-', putdat);
  8005ef:	83 ec 08             	sub    $0x8,%esp
  8005f2:	53                   	push   %ebx
  8005f3:	6a 2d                	push   $0x2d
  8005f5:	ff d6                	call   *%esi
				num = -(long long) num;
  8005f7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005fa:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005fd:	f7 da                	neg    %edx
  8005ff:	83 d1 00             	adc    $0x0,%ecx
  800602:	f7 d9                	neg    %ecx
  800604:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800607:	b8 0a 00 00 00       	mov    $0xa,%eax
  80060c:	e9 ec 00 00 00       	jmp    8006fd <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800611:	83 f9 01             	cmp    $0x1,%ecx
  800614:	7e 18                	jle    80062e <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800616:	8b 45 14             	mov    0x14(%ebp),%eax
  800619:	8b 10                	mov    (%eax),%edx
  80061b:	8b 48 04             	mov    0x4(%eax),%ecx
  80061e:	8d 40 08             	lea    0x8(%eax),%eax
  800621:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800624:	b8 0a 00 00 00       	mov    $0xa,%eax
  800629:	e9 cf 00 00 00       	jmp    8006fd <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80062e:	85 c9                	test   %ecx,%ecx
  800630:	74 1a                	je     80064c <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800632:	8b 45 14             	mov    0x14(%ebp),%eax
  800635:	8b 10                	mov    (%eax),%edx
  800637:	b9 00 00 00 00       	mov    $0x0,%ecx
  80063c:	8d 40 04             	lea    0x4(%eax),%eax
  80063f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800642:	b8 0a 00 00 00       	mov    $0xa,%eax
  800647:	e9 b1 00 00 00       	jmp    8006fd <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80064c:	8b 45 14             	mov    0x14(%ebp),%eax
  80064f:	8b 10                	mov    (%eax),%edx
  800651:	b9 00 00 00 00       	mov    $0x0,%ecx
  800656:	8d 40 04             	lea    0x4(%eax),%eax
  800659:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80065c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800661:	e9 97 00 00 00       	jmp    8006fd <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800666:	83 ec 08             	sub    $0x8,%esp
  800669:	53                   	push   %ebx
  80066a:	6a 58                	push   $0x58
  80066c:	ff d6                	call   *%esi
			putch('X', putdat);
  80066e:	83 c4 08             	add    $0x8,%esp
  800671:	53                   	push   %ebx
  800672:	6a 58                	push   $0x58
  800674:	ff d6                	call   *%esi
			putch('X', putdat);
  800676:	83 c4 08             	add    $0x8,%esp
  800679:	53                   	push   %ebx
  80067a:	6a 58                	push   $0x58
  80067c:	ff d6                	call   *%esi
			break;
  80067e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800681:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800684:	e9 8b fc ff ff       	jmp    800314 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800689:	83 ec 08             	sub    $0x8,%esp
  80068c:	53                   	push   %ebx
  80068d:	6a 30                	push   $0x30
  80068f:	ff d6                	call   *%esi
			putch('x', putdat);
  800691:	83 c4 08             	add    $0x8,%esp
  800694:	53                   	push   %ebx
  800695:	6a 78                	push   $0x78
  800697:	ff d6                	call   *%esi
			num = (unsigned long long)
  800699:	8b 45 14             	mov    0x14(%ebp),%eax
  80069c:	8b 10                	mov    (%eax),%edx
  80069e:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006a3:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006a6:	8d 40 04             	lea    0x4(%eax),%eax
  8006a9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ac:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006b1:	eb 4a                	jmp    8006fd <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006b3:	83 f9 01             	cmp    $0x1,%ecx
  8006b6:	7e 15                	jle    8006cd <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8006b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bb:	8b 10                	mov    (%eax),%edx
  8006bd:	8b 48 04             	mov    0x4(%eax),%ecx
  8006c0:	8d 40 08             	lea    0x8(%eax),%eax
  8006c3:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006c6:	b8 10 00 00 00       	mov    $0x10,%eax
  8006cb:	eb 30                	jmp    8006fd <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006cd:	85 c9                	test   %ecx,%ecx
  8006cf:	74 17                	je     8006e8 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8006d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d4:	8b 10                	mov    (%eax),%edx
  8006d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006db:	8d 40 04             	lea    0x4(%eax),%eax
  8006de:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006e1:	b8 10 00 00 00       	mov    $0x10,%eax
  8006e6:	eb 15                	jmp    8006fd <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8006e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006eb:	8b 10                	mov    (%eax),%edx
  8006ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f2:	8d 40 04             	lea    0x4(%eax),%eax
  8006f5:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006f8:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006fd:	83 ec 0c             	sub    $0xc,%esp
  800700:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800704:	57                   	push   %edi
  800705:	ff 75 e0             	pushl  -0x20(%ebp)
  800708:	50                   	push   %eax
  800709:	51                   	push   %ecx
  80070a:	52                   	push   %edx
  80070b:	89 da                	mov    %ebx,%edx
  80070d:	89 f0                	mov    %esi,%eax
  80070f:	e8 f1 fa ff ff       	call   800205 <printnum>
			break;
  800714:	83 c4 20             	add    $0x20,%esp
  800717:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80071a:	e9 f5 fb ff ff       	jmp    800314 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80071f:	83 ec 08             	sub    $0x8,%esp
  800722:	53                   	push   %ebx
  800723:	52                   	push   %edx
  800724:	ff d6                	call   *%esi
			break;
  800726:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800729:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80072c:	e9 e3 fb ff ff       	jmp    800314 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800731:	83 ec 08             	sub    $0x8,%esp
  800734:	53                   	push   %ebx
  800735:	6a 25                	push   $0x25
  800737:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800739:	83 c4 10             	add    $0x10,%esp
  80073c:	eb 03                	jmp    800741 <vprintfmt+0x453>
  80073e:	83 ef 01             	sub    $0x1,%edi
  800741:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800745:	75 f7                	jne    80073e <vprintfmt+0x450>
  800747:	e9 c8 fb ff ff       	jmp    800314 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80074c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80074f:	5b                   	pop    %ebx
  800750:	5e                   	pop    %esi
  800751:	5f                   	pop    %edi
  800752:	5d                   	pop    %ebp
  800753:	c3                   	ret    

00800754 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800754:	55                   	push   %ebp
  800755:	89 e5                	mov    %esp,%ebp
  800757:	83 ec 18             	sub    $0x18,%esp
  80075a:	8b 45 08             	mov    0x8(%ebp),%eax
  80075d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800760:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800763:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800767:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80076a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800771:	85 c0                	test   %eax,%eax
  800773:	74 26                	je     80079b <vsnprintf+0x47>
  800775:	85 d2                	test   %edx,%edx
  800777:	7e 22                	jle    80079b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800779:	ff 75 14             	pushl  0x14(%ebp)
  80077c:	ff 75 10             	pushl  0x10(%ebp)
  80077f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800782:	50                   	push   %eax
  800783:	68 b4 02 80 00       	push   $0x8002b4
  800788:	e8 61 fb ff ff       	call   8002ee <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80078d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800790:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800793:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800796:	83 c4 10             	add    $0x10,%esp
  800799:	eb 05                	jmp    8007a0 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80079b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007a0:	c9                   	leave  
  8007a1:	c3                   	ret    

008007a2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007a2:	55                   	push   %ebp
  8007a3:	89 e5                	mov    %esp,%ebp
  8007a5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007a8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007ab:	50                   	push   %eax
  8007ac:	ff 75 10             	pushl  0x10(%ebp)
  8007af:	ff 75 0c             	pushl  0xc(%ebp)
  8007b2:	ff 75 08             	pushl  0x8(%ebp)
  8007b5:	e8 9a ff ff ff       	call   800754 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007ba:	c9                   	leave  
  8007bb:	c3                   	ret    

008007bc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007bc:	55                   	push   %ebp
  8007bd:	89 e5                	mov    %esp,%ebp
  8007bf:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c7:	eb 03                	jmp    8007cc <strlen+0x10>
		n++;
  8007c9:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007cc:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007d0:	75 f7                	jne    8007c9 <strlen+0xd>
		n++;
	return n;
}
  8007d2:	5d                   	pop    %ebp
  8007d3:	c3                   	ret    

008007d4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007d4:	55                   	push   %ebp
  8007d5:	89 e5                	mov    %esp,%ebp
  8007d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007da:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8007e2:	eb 03                	jmp    8007e7 <strnlen+0x13>
		n++;
  8007e4:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e7:	39 c2                	cmp    %eax,%edx
  8007e9:	74 08                	je     8007f3 <strnlen+0x1f>
  8007eb:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007ef:	75 f3                	jne    8007e4 <strnlen+0x10>
  8007f1:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007f3:	5d                   	pop    %ebp
  8007f4:	c3                   	ret    

008007f5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f5:	55                   	push   %ebp
  8007f6:	89 e5                	mov    %esp,%ebp
  8007f8:	53                   	push   %ebx
  8007f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007ff:	89 c2                	mov    %eax,%edx
  800801:	83 c2 01             	add    $0x1,%edx
  800804:	83 c1 01             	add    $0x1,%ecx
  800807:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80080b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80080e:	84 db                	test   %bl,%bl
  800810:	75 ef                	jne    800801 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800812:	5b                   	pop    %ebx
  800813:	5d                   	pop    %ebp
  800814:	c3                   	ret    

00800815 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	53                   	push   %ebx
  800819:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80081c:	53                   	push   %ebx
  80081d:	e8 9a ff ff ff       	call   8007bc <strlen>
  800822:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800825:	ff 75 0c             	pushl  0xc(%ebp)
  800828:	01 d8                	add    %ebx,%eax
  80082a:	50                   	push   %eax
  80082b:	e8 c5 ff ff ff       	call   8007f5 <strcpy>
	return dst;
}
  800830:	89 d8                	mov    %ebx,%eax
  800832:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800835:	c9                   	leave  
  800836:	c3                   	ret    

00800837 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800837:	55                   	push   %ebp
  800838:	89 e5                	mov    %esp,%ebp
  80083a:	56                   	push   %esi
  80083b:	53                   	push   %ebx
  80083c:	8b 75 08             	mov    0x8(%ebp),%esi
  80083f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800842:	89 f3                	mov    %esi,%ebx
  800844:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800847:	89 f2                	mov    %esi,%edx
  800849:	eb 0f                	jmp    80085a <strncpy+0x23>
		*dst++ = *src;
  80084b:	83 c2 01             	add    $0x1,%edx
  80084e:	0f b6 01             	movzbl (%ecx),%eax
  800851:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800854:	80 39 01             	cmpb   $0x1,(%ecx)
  800857:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80085a:	39 da                	cmp    %ebx,%edx
  80085c:	75 ed                	jne    80084b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80085e:	89 f0                	mov    %esi,%eax
  800860:	5b                   	pop    %ebx
  800861:	5e                   	pop    %esi
  800862:	5d                   	pop    %ebp
  800863:	c3                   	ret    

00800864 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800864:	55                   	push   %ebp
  800865:	89 e5                	mov    %esp,%ebp
  800867:	56                   	push   %esi
  800868:	53                   	push   %ebx
  800869:	8b 75 08             	mov    0x8(%ebp),%esi
  80086c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80086f:	8b 55 10             	mov    0x10(%ebp),%edx
  800872:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800874:	85 d2                	test   %edx,%edx
  800876:	74 21                	je     800899 <strlcpy+0x35>
  800878:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80087c:	89 f2                	mov    %esi,%edx
  80087e:	eb 09                	jmp    800889 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800880:	83 c2 01             	add    $0x1,%edx
  800883:	83 c1 01             	add    $0x1,%ecx
  800886:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800889:	39 c2                	cmp    %eax,%edx
  80088b:	74 09                	je     800896 <strlcpy+0x32>
  80088d:	0f b6 19             	movzbl (%ecx),%ebx
  800890:	84 db                	test   %bl,%bl
  800892:	75 ec                	jne    800880 <strlcpy+0x1c>
  800894:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800896:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800899:	29 f0                	sub    %esi,%eax
}
  80089b:	5b                   	pop    %ebx
  80089c:	5e                   	pop    %esi
  80089d:	5d                   	pop    %ebp
  80089e:	c3                   	ret    

0080089f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a8:	eb 06                	jmp    8008b0 <strcmp+0x11>
		p++, q++;
  8008aa:	83 c1 01             	add    $0x1,%ecx
  8008ad:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008b0:	0f b6 01             	movzbl (%ecx),%eax
  8008b3:	84 c0                	test   %al,%al
  8008b5:	74 04                	je     8008bb <strcmp+0x1c>
  8008b7:	3a 02                	cmp    (%edx),%al
  8008b9:	74 ef                	je     8008aa <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008bb:	0f b6 c0             	movzbl %al,%eax
  8008be:	0f b6 12             	movzbl (%edx),%edx
  8008c1:	29 d0                	sub    %edx,%eax
}
  8008c3:	5d                   	pop    %ebp
  8008c4:	c3                   	ret    

008008c5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
  8008c8:	53                   	push   %ebx
  8008c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cf:	89 c3                	mov    %eax,%ebx
  8008d1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008d4:	eb 06                	jmp    8008dc <strncmp+0x17>
		n--, p++, q++;
  8008d6:	83 c0 01             	add    $0x1,%eax
  8008d9:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008dc:	39 d8                	cmp    %ebx,%eax
  8008de:	74 15                	je     8008f5 <strncmp+0x30>
  8008e0:	0f b6 08             	movzbl (%eax),%ecx
  8008e3:	84 c9                	test   %cl,%cl
  8008e5:	74 04                	je     8008eb <strncmp+0x26>
  8008e7:	3a 0a                	cmp    (%edx),%cl
  8008e9:	74 eb                	je     8008d6 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008eb:	0f b6 00             	movzbl (%eax),%eax
  8008ee:	0f b6 12             	movzbl (%edx),%edx
  8008f1:	29 d0                	sub    %edx,%eax
  8008f3:	eb 05                	jmp    8008fa <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008f5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008fa:	5b                   	pop    %ebx
  8008fb:	5d                   	pop    %ebp
  8008fc:	c3                   	ret    

008008fd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008fd:	55                   	push   %ebp
  8008fe:	89 e5                	mov    %esp,%ebp
  800900:	8b 45 08             	mov    0x8(%ebp),%eax
  800903:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800907:	eb 07                	jmp    800910 <strchr+0x13>
		if (*s == c)
  800909:	38 ca                	cmp    %cl,%dl
  80090b:	74 0f                	je     80091c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80090d:	83 c0 01             	add    $0x1,%eax
  800910:	0f b6 10             	movzbl (%eax),%edx
  800913:	84 d2                	test   %dl,%dl
  800915:	75 f2                	jne    800909 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800917:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80091c:	5d                   	pop    %ebp
  80091d:	c3                   	ret    

0080091e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	8b 45 08             	mov    0x8(%ebp),%eax
  800924:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800928:	eb 03                	jmp    80092d <strfind+0xf>
  80092a:	83 c0 01             	add    $0x1,%eax
  80092d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800930:	38 ca                	cmp    %cl,%dl
  800932:	74 04                	je     800938 <strfind+0x1a>
  800934:	84 d2                	test   %dl,%dl
  800936:	75 f2                	jne    80092a <strfind+0xc>
			break;
	return (char *) s;
}
  800938:	5d                   	pop    %ebp
  800939:	c3                   	ret    

0080093a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	57                   	push   %edi
  80093e:	56                   	push   %esi
  80093f:	53                   	push   %ebx
  800940:	8b 7d 08             	mov    0x8(%ebp),%edi
  800943:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800946:	85 c9                	test   %ecx,%ecx
  800948:	74 36                	je     800980 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80094a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800950:	75 28                	jne    80097a <memset+0x40>
  800952:	f6 c1 03             	test   $0x3,%cl
  800955:	75 23                	jne    80097a <memset+0x40>
		c &= 0xFF;
  800957:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80095b:	89 d3                	mov    %edx,%ebx
  80095d:	c1 e3 08             	shl    $0x8,%ebx
  800960:	89 d6                	mov    %edx,%esi
  800962:	c1 e6 18             	shl    $0x18,%esi
  800965:	89 d0                	mov    %edx,%eax
  800967:	c1 e0 10             	shl    $0x10,%eax
  80096a:	09 f0                	or     %esi,%eax
  80096c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80096e:	89 d8                	mov    %ebx,%eax
  800970:	09 d0                	or     %edx,%eax
  800972:	c1 e9 02             	shr    $0x2,%ecx
  800975:	fc                   	cld    
  800976:	f3 ab                	rep stos %eax,%es:(%edi)
  800978:	eb 06                	jmp    800980 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80097a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80097d:	fc                   	cld    
  80097e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800980:	89 f8                	mov    %edi,%eax
  800982:	5b                   	pop    %ebx
  800983:	5e                   	pop    %esi
  800984:	5f                   	pop    %edi
  800985:	5d                   	pop    %ebp
  800986:	c3                   	ret    

00800987 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	57                   	push   %edi
  80098b:	56                   	push   %esi
  80098c:	8b 45 08             	mov    0x8(%ebp),%eax
  80098f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800992:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800995:	39 c6                	cmp    %eax,%esi
  800997:	73 35                	jae    8009ce <memmove+0x47>
  800999:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80099c:	39 d0                	cmp    %edx,%eax
  80099e:	73 2e                	jae    8009ce <memmove+0x47>
		s += n;
		d += n;
  8009a0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a3:	89 d6                	mov    %edx,%esi
  8009a5:	09 fe                	or     %edi,%esi
  8009a7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ad:	75 13                	jne    8009c2 <memmove+0x3b>
  8009af:	f6 c1 03             	test   $0x3,%cl
  8009b2:	75 0e                	jne    8009c2 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009b4:	83 ef 04             	sub    $0x4,%edi
  8009b7:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009ba:	c1 e9 02             	shr    $0x2,%ecx
  8009bd:	fd                   	std    
  8009be:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c0:	eb 09                	jmp    8009cb <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009c2:	83 ef 01             	sub    $0x1,%edi
  8009c5:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009c8:	fd                   	std    
  8009c9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009cb:	fc                   	cld    
  8009cc:	eb 1d                	jmp    8009eb <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ce:	89 f2                	mov    %esi,%edx
  8009d0:	09 c2                	or     %eax,%edx
  8009d2:	f6 c2 03             	test   $0x3,%dl
  8009d5:	75 0f                	jne    8009e6 <memmove+0x5f>
  8009d7:	f6 c1 03             	test   $0x3,%cl
  8009da:	75 0a                	jne    8009e6 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009dc:	c1 e9 02             	shr    $0x2,%ecx
  8009df:	89 c7                	mov    %eax,%edi
  8009e1:	fc                   	cld    
  8009e2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e4:	eb 05                	jmp    8009eb <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e6:	89 c7                	mov    %eax,%edi
  8009e8:	fc                   	cld    
  8009e9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009eb:	5e                   	pop    %esi
  8009ec:	5f                   	pop    %edi
  8009ed:	5d                   	pop    %ebp
  8009ee:	c3                   	ret    

008009ef <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ef:	55                   	push   %ebp
  8009f0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009f2:	ff 75 10             	pushl  0x10(%ebp)
  8009f5:	ff 75 0c             	pushl  0xc(%ebp)
  8009f8:	ff 75 08             	pushl  0x8(%ebp)
  8009fb:	e8 87 ff ff ff       	call   800987 <memmove>
}
  800a00:	c9                   	leave  
  800a01:	c3                   	ret    

00800a02 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a02:	55                   	push   %ebp
  800a03:	89 e5                	mov    %esp,%ebp
  800a05:	56                   	push   %esi
  800a06:	53                   	push   %ebx
  800a07:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a0d:	89 c6                	mov    %eax,%esi
  800a0f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a12:	eb 1a                	jmp    800a2e <memcmp+0x2c>
		if (*s1 != *s2)
  800a14:	0f b6 08             	movzbl (%eax),%ecx
  800a17:	0f b6 1a             	movzbl (%edx),%ebx
  800a1a:	38 d9                	cmp    %bl,%cl
  800a1c:	74 0a                	je     800a28 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a1e:	0f b6 c1             	movzbl %cl,%eax
  800a21:	0f b6 db             	movzbl %bl,%ebx
  800a24:	29 d8                	sub    %ebx,%eax
  800a26:	eb 0f                	jmp    800a37 <memcmp+0x35>
		s1++, s2++;
  800a28:	83 c0 01             	add    $0x1,%eax
  800a2b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2e:	39 f0                	cmp    %esi,%eax
  800a30:	75 e2                	jne    800a14 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a32:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a37:	5b                   	pop    %ebx
  800a38:	5e                   	pop    %esi
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    

00800a3b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	53                   	push   %ebx
  800a3f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a42:	89 c1                	mov    %eax,%ecx
  800a44:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a47:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a4b:	eb 0a                	jmp    800a57 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a4d:	0f b6 10             	movzbl (%eax),%edx
  800a50:	39 da                	cmp    %ebx,%edx
  800a52:	74 07                	je     800a5b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a54:	83 c0 01             	add    $0x1,%eax
  800a57:	39 c8                	cmp    %ecx,%eax
  800a59:	72 f2                	jb     800a4d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a5b:	5b                   	pop    %ebx
  800a5c:	5d                   	pop    %ebp
  800a5d:	c3                   	ret    

00800a5e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	57                   	push   %edi
  800a62:	56                   	push   %esi
  800a63:	53                   	push   %ebx
  800a64:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a67:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6a:	eb 03                	jmp    800a6f <strtol+0x11>
		s++;
  800a6c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6f:	0f b6 01             	movzbl (%ecx),%eax
  800a72:	3c 20                	cmp    $0x20,%al
  800a74:	74 f6                	je     800a6c <strtol+0xe>
  800a76:	3c 09                	cmp    $0x9,%al
  800a78:	74 f2                	je     800a6c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a7a:	3c 2b                	cmp    $0x2b,%al
  800a7c:	75 0a                	jne    800a88 <strtol+0x2a>
		s++;
  800a7e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a81:	bf 00 00 00 00       	mov    $0x0,%edi
  800a86:	eb 11                	jmp    800a99 <strtol+0x3b>
  800a88:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a8d:	3c 2d                	cmp    $0x2d,%al
  800a8f:	75 08                	jne    800a99 <strtol+0x3b>
		s++, neg = 1;
  800a91:	83 c1 01             	add    $0x1,%ecx
  800a94:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a99:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a9f:	75 15                	jne    800ab6 <strtol+0x58>
  800aa1:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa4:	75 10                	jne    800ab6 <strtol+0x58>
  800aa6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aaa:	75 7c                	jne    800b28 <strtol+0xca>
		s += 2, base = 16;
  800aac:	83 c1 02             	add    $0x2,%ecx
  800aaf:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab4:	eb 16                	jmp    800acc <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ab6:	85 db                	test   %ebx,%ebx
  800ab8:	75 12                	jne    800acc <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aba:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800abf:	80 39 30             	cmpb   $0x30,(%ecx)
  800ac2:	75 08                	jne    800acc <strtol+0x6e>
		s++, base = 8;
  800ac4:	83 c1 01             	add    $0x1,%ecx
  800ac7:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800acc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad1:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ad4:	0f b6 11             	movzbl (%ecx),%edx
  800ad7:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ada:	89 f3                	mov    %esi,%ebx
  800adc:	80 fb 09             	cmp    $0x9,%bl
  800adf:	77 08                	ja     800ae9 <strtol+0x8b>
			dig = *s - '0';
  800ae1:	0f be d2             	movsbl %dl,%edx
  800ae4:	83 ea 30             	sub    $0x30,%edx
  800ae7:	eb 22                	jmp    800b0b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ae9:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aec:	89 f3                	mov    %esi,%ebx
  800aee:	80 fb 19             	cmp    $0x19,%bl
  800af1:	77 08                	ja     800afb <strtol+0x9d>
			dig = *s - 'a' + 10;
  800af3:	0f be d2             	movsbl %dl,%edx
  800af6:	83 ea 57             	sub    $0x57,%edx
  800af9:	eb 10                	jmp    800b0b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800afb:	8d 72 bf             	lea    -0x41(%edx),%esi
  800afe:	89 f3                	mov    %esi,%ebx
  800b00:	80 fb 19             	cmp    $0x19,%bl
  800b03:	77 16                	ja     800b1b <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b05:	0f be d2             	movsbl %dl,%edx
  800b08:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b0b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b0e:	7d 0b                	jge    800b1b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b10:	83 c1 01             	add    $0x1,%ecx
  800b13:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b17:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b19:	eb b9                	jmp    800ad4 <strtol+0x76>

	if (endptr)
  800b1b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b1f:	74 0d                	je     800b2e <strtol+0xd0>
		*endptr = (char *) s;
  800b21:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b24:	89 0e                	mov    %ecx,(%esi)
  800b26:	eb 06                	jmp    800b2e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b28:	85 db                	test   %ebx,%ebx
  800b2a:	74 98                	je     800ac4 <strtol+0x66>
  800b2c:	eb 9e                	jmp    800acc <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b2e:	89 c2                	mov    %eax,%edx
  800b30:	f7 da                	neg    %edx
  800b32:	85 ff                	test   %edi,%edi
  800b34:	0f 45 c2             	cmovne %edx,%eax
}
  800b37:	5b                   	pop    %ebx
  800b38:	5e                   	pop    %esi
  800b39:	5f                   	pop    %edi
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800b42:	b8 00 00 00 00       	mov    $0x0,%eax
  800b47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4d:	89 c3                	mov    %eax,%ebx
  800b4f:	89 c7                	mov    %eax,%edi
  800b51:	89 c6                	mov    %eax,%esi
  800b53:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b55:	5b                   	pop    %ebx
  800b56:	5e                   	pop    %esi
  800b57:	5f                   	pop    %edi
  800b58:	5d                   	pop    %ebp
  800b59:	c3                   	ret    

00800b5a <sys_cgetc>:

int
sys_cgetc(void)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	57                   	push   %edi
  800b5e:	56                   	push   %esi
  800b5f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b60:	ba 00 00 00 00       	mov    $0x0,%edx
  800b65:	b8 01 00 00 00       	mov    $0x1,%eax
  800b6a:	89 d1                	mov    %edx,%ecx
  800b6c:	89 d3                	mov    %edx,%ebx
  800b6e:	89 d7                	mov    %edx,%edi
  800b70:	89 d6                	mov    %edx,%esi
  800b72:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b74:	5b                   	pop    %ebx
  800b75:	5e                   	pop    %esi
  800b76:	5f                   	pop    %edi
  800b77:	5d                   	pop    %ebp
  800b78:	c3                   	ret    

00800b79 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b79:	55                   	push   %ebp
  800b7a:	89 e5                	mov    %esp,%ebp
  800b7c:	57                   	push   %edi
  800b7d:	56                   	push   %esi
  800b7e:	53                   	push   %ebx
  800b7f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b82:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b87:	b8 03 00 00 00       	mov    $0x3,%eax
  800b8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8f:	89 cb                	mov    %ecx,%ebx
  800b91:	89 cf                	mov    %ecx,%edi
  800b93:	89 ce                	mov    %ecx,%esi
  800b95:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b97:	85 c0                	test   %eax,%eax
  800b99:	7e 17                	jle    800bb2 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9b:	83 ec 0c             	sub    $0xc,%esp
  800b9e:	50                   	push   %eax
  800b9f:	6a 03                	push   $0x3
  800ba1:	68 1f 25 80 00       	push   $0x80251f
  800ba6:	6a 23                	push   $0x23
  800ba8:	68 3c 25 80 00       	push   $0x80253c
  800bad:	e8 79 12 00 00       	call   801e2b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb5:	5b                   	pop    %ebx
  800bb6:	5e                   	pop    %esi
  800bb7:	5f                   	pop    %edi
  800bb8:	5d                   	pop    %ebp
  800bb9:	c3                   	ret    

00800bba <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	57                   	push   %edi
  800bbe:	56                   	push   %esi
  800bbf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc5:	b8 02 00 00 00       	mov    $0x2,%eax
  800bca:	89 d1                	mov    %edx,%ecx
  800bcc:	89 d3                	mov    %edx,%ebx
  800bce:	89 d7                	mov    %edx,%edi
  800bd0:	89 d6                	mov    %edx,%esi
  800bd2:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bd4:	5b                   	pop    %ebx
  800bd5:	5e                   	pop    %esi
  800bd6:	5f                   	pop    %edi
  800bd7:	5d                   	pop    %ebp
  800bd8:	c3                   	ret    

00800bd9 <sys_yield>:

void
sys_yield(void)
{
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	57                   	push   %edi
  800bdd:	56                   	push   %esi
  800bde:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdf:	ba 00 00 00 00       	mov    $0x0,%edx
  800be4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800be9:	89 d1                	mov    %edx,%ecx
  800beb:	89 d3                	mov    %edx,%ebx
  800bed:	89 d7                	mov    %edx,%edi
  800bef:	89 d6                	mov    %edx,%esi
  800bf1:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bf3:	5b                   	pop    %ebx
  800bf4:	5e                   	pop    %esi
  800bf5:	5f                   	pop    %edi
  800bf6:	5d                   	pop    %ebp
  800bf7:	c3                   	ret    

00800bf8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bf8:	55                   	push   %ebp
  800bf9:	89 e5                	mov    %esp,%ebp
  800bfb:	57                   	push   %edi
  800bfc:	56                   	push   %esi
  800bfd:	53                   	push   %ebx
  800bfe:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c01:	be 00 00 00 00       	mov    $0x0,%esi
  800c06:	b8 04 00 00 00       	mov    $0x4,%eax
  800c0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c11:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c14:	89 f7                	mov    %esi,%edi
  800c16:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c18:	85 c0                	test   %eax,%eax
  800c1a:	7e 17                	jle    800c33 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1c:	83 ec 0c             	sub    $0xc,%esp
  800c1f:	50                   	push   %eax
  800c20:	6a 04                	push   $0x4
  800c22:	68 1f 25 80 00       	push   $0x80251f
  800c27:	6a 23                	push   $0x23
  800c29:	68 3c 25 80 00       	push   $0x80253c
  800c2e:	e8 f8 11 00 00       	call   801e2b <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c36:	5b                   	pop    %ebx
  800c37:	5e                   	pop    %esi
  800c38:	5f                   	pop    %edi
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    

00800c3b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	57                   	push   %edi
  800c3f:	56                   	push   %esi
  800c40:	53                   	push   %ebx
  800c41:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c44:	b8 05 00 00 00       	mov    $0x5,%eax
  800c49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c52:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c55:	8b 75 18             	mov    0x18(%ebp),%esi
  800c58:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c5a:	85 c0                	test   %eax,%eax
  800c5c:	7e 17                	jle    800c75 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5e:	83 ec 0c             	sub    $0xc,%esp
  800c61:	50                   	push   %eax
  800c62:	6a 05                	push   $0x5
  800c64:	68 1f 25 80 00       	push   $0x80251f
  800c69:	6a 23                	push   $0x23
  800c6b:	68 3c 25 80 00       	push   $0x80253c
  800c70:	e8 b6 11 00 00       	call   801e2b <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c78:	5b                   	pop    %ebx
  800c79:	5e                   	pop    %esi
  800c7a:	5f                   	pop    %edi
  800c7b:	5d                   	pop    %ebp
  800c7c:	c3                   	ret    

00800c7d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c7d:	55                   	push   %ebp
  800c7e:	89 e5                	mov    %esp,%ebp
  800c80:	57                   	push   %edi
  800c81:	56                   	push   %esi
  800c82:	53                   	push   %ebx
  800c83:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c86:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8b:	b8 06 00 00 00       	mov    $0x6,%eax
  800c90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c93:	8b 55 08             	mov    0x8(%ebp),%edx
  800c96:	89 df                	mov    %ebx,%edi
  800c98:	89 de                	mov    %ebx,%esi
  800c9a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c9c:	85 c0                	test   %eax,%eax
  800c9e:	7e 17                	jle    800cb7 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca0:	83 ec 0c             	sub    $0xc,%esp
  800ca3:	50                   	push   %eax
  800ca4:	6a 06                	push   $0x6
  800ca6:	68 1f 25 80 00       	push   $0x80251f
  800cab:	6a 23                	push   $0x23
  800cad:	68 3c 25 80 00       	push   $0x80253c
  800cb2:	e8 74 11 00 00       	call   801e2b <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cb7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cba:	5b                   	pop    %ebx
  800cbb:	5e                   	pop    %esi
  800cbc:	5f                   	pop    %edi
  800cbd:	5d                   	pop    %ebp
  800cbe:	c3                   	ret    

00800cbf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cbf:	55                   	push   %ebp
  800cc0:	89 e5                	mov    %esp,%ebp
  800cc2:	57                   	push   %edi
  800cc3:	56                   	push   %esi
  800cc4:	53                   	push   %ebx
  800cc5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ccd:	b8 08 00 00 00       	mov    $0x8,%eax
  800cd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd8:	89 df                	mov    %ebx,%edi
  800cda:	89 de                	mov    %ebx,%esi
  800cdc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cde:	85 c0                	test   %eax,%eax
  800ce0:	7e 17                	jle    800cf9 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce2:	83 ec 0c             	sub    $0xc,%esp
  800ce5:	50                   	push   %eax
  800ce6:	6a 08                	push   $0x8
  800ce8:	68 1f 25 80 00       	push   $0x80251f
  800ced:	6a 23                	push   $0x23
  800cef:	68 3c 25 80 00       	push   $0x80253c
  800cf4:	e8 32 11 00 00       	call   801e2b <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cf9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfc:	5b                   	pop    %ebx
  800cfd:	5e                   	pop    %esi
  800cfe:	5f                   	pop    %edi
  800cff:	5d                   	pop    %ebp
  800d00:	c3                   	ret    

00800d01 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d01:	55                   	push   %ebp
  800d02:	89 e5                	mov    %esp,%ebp
  800d04:	57                   	push   %edi
  800d05:	56                   	push   %esi
  800d06:	53                   	push   %ebx
  800d07:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0f:	b8 09 00 00 00       	mov    $0x9,%eax
  800d14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d17:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1a:	89 df                	mov    %ebx,%edi
  800d1c:	89 de                	mov    %ebx,%esi
  800d1e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d20:	85 c0                	test   %eax,%eax
  800d22:	7e 17                	jle    800d3b <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d24:	83 ec 0c             	sub    $0xc,%esp
  800d27:	50                   	push   %eax
  800d28:	6a 09                	push   $0x9
  800d2a:	68 1f 25 80 00       	push   $0x80251f
  800d2f:	6a 23                	push   $0x23
  800d31:	68 3c 25 80 00       	push   $0x80253c
  800d36:	e8 f0 10 00 00       	call   801e2b <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3e:	5b                   	pop    %ebx
  800d3f:	5e                   	pop    %esi
  800d40:	5f                   	pop    %edi
  800d41:	5d                   	pop    %ebp
  800d42:	c3                   	ret    

00800d43 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d43:	55                   	push   %ebp
  800d44:	89 e5                	mov    %esp,%ebp
  800d46:	57                   	push   %edi
  800d47:	56                   	push   %esi
  800d48:	53                   	push   %ebx
  800d49:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d51:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d59:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5c:	89 df                	mov    %ebx,%edi
  800d5e:	89 de                	mov    %ebx,%esi
  800d60:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d62:	85 c0                	test   %eax,%eax
  800d64:	7e 17                	jle    800d7d <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d66:	83 ec 0c             	sub    $0xc,%esp
  800d69:	50                   	push   %eax
  800d6a:	6a 0a                	push   $0xa
  800d6c:	68 1f 25 80 00       	push   $0x80251f
  800d71:	6a 23                	push   $0x23
  800d73:	68 3c 25 80 00       	push   $0x80253c
  800d78:	e8 ae 10 00 00       	call   801e2b <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d80:	5b                   	pop    %ebx
  800d81:	5e                   	pop    %esi
  800d82:	5f                   	pop    %edi
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    

00800d85 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d85:	55                   	push   %ebp
  800d86:	89 e5                	mov    %esp,%ebp
  800d88:	57                   	push   %edi
  800d89:	56                   	push   %esi
  800d8a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8b:	be 00 00 00 00       	mov    $0x0,%esi
  800d90:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d98:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d9e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800da1:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800da3:	5b                   	pop    %ebx
  800da4:	5e                   	pop    %esi
  800da5:	5f                   	pop    %edi
  800da6:	5d                   	pop    %ebp
  800da7:	c3                   	ret    

00800da8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800da8:	55                   	push   %ebp
  800da9:	89 e5                	mov    %esp,%ebp
  800dab:	57                   	push   %edi
  800dac:	56                   	push   %esi
  800dad:	53                   	push   %ebx
  800dae:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db6:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbe:	89 cb                	mov    %ecx,%ebx
  800dc0:	89 cf                	mov    %ecx,%edi
  800dc2:	89 ce                	mov    %ecx,%esi
  800dc4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dc6:	85 c0                	test   %eax,%eax
  800dc8:	7e 17                	jle    800de1 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dca:	83 ec 0c             	sub    $0xc,%esp
  800dcd:	50                   	push   %eax
  800dce:	6a 0d                	push   $0xd
  800dd0:	68 1f 25 80 00       	push   $0x80251f
  800dd5:	6a 23                	push   $0x23
  800dd7:	68 3c 25 80 00       	push   $0x80253c
  800ddc:	e8 4a 10 00 00       	call   801e2b <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800de1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de4:	5b                   	pop    %ebx
  800de5:	5e                   	pop    %esi
  800de6:	5f                   	pop    %edi
  800de7:	5d                   	pop    %ebp
  800de8:	c3                   	ret    

00800de9 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800de9:	55                   	push   %ebp
  800dea:	89 e5                	mov    %esp,%ebp
  800dec:	57                   	push   %edi
  800ded:	56                   	push   %esi
  800dee:	53                   	push   %ebx
  800def:	83 ec 0c             	sub    $0xc,%esp
  800df2:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800df5:	8b 18                	mov    (%eax),%ebx
	uint32_t err = utf->utf_err;
  800df7:	8b 78 04             	mov    0x4(%eax),%edi
	int r;
	envid_t curenvid = sys_getenvid();
  800dfa:	e8 bb fd ff ff       	call   800bba <sys_getenvid>
  800dff:	89 c6                	mov    %eax,%esi
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(err & FEC_WR) && !(uvpt[PGNUM(addr)] & PTE_COW))
  800e01:	f7 c7 02 00 00 00    	test   $0x2,%edi
  800e07:	75 25                	jne    800e2e <pgfault+0x45>
  800e09:	89 d8                	mov    %ebx,%eax
  800e0b:	c1 e8 0c             	shr    $0xc,%eax
  800e0e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e15:	f6 c4 08             	test   $0x8,%ah
  800e18:	75 14                	jne    800e2e <pgfault+0x45>
	    panic("pgfault error: wrong faulting access");
  800e1a:	83 ec 04             	sub    $0x4,%esp
  800e1d:	68 4c 25 80 00       	push   $0x80254c
  800e22:	6a 1e                	push   $0x1e
  800e24:	68 71 25 80 00       	push   $0x802571
  800e29:	e8 fd 0f 00 00       	call   801e2b <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	sys_page_alloc(curenvid, PFTEMP, PTE_W | PTE_U | PTE_P);
  800e2e:	83 ec 04             	sub    $0x4,%esp
  800e31:	6a 07                	push   $0x7
  800e33:	68 00 f0 7f 00       	push   $0x7ff000
  800e38:	56                   	push   %esi
  800e39:	e8 ba fd ff ff       	call   800bf8 <sys_page_alloc>

	addr = (void *)(PGNUM(addr) * PGSIZE);
  800e3e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr, PGSIZE);
  800e44:	83 c4 0c             	add    $0xc,%esp
  800e47:	68 00 10 00 00       	push   $0x1000
  800e4c:	53                   	push   %ebx
  800e4d:	68 00 f0 7f 00       	push   $0x7ff000
  800e52:	e8 30 fb ff ff       	call   800987 <memmove>

	sys_page_unmap(curenvid, addr);
  800e57:	83 c4 08             	add    $0x8,%esp
  800e5a:	53                   	push   %ebx
  800e5b:	56                   	push   %esi
  800e5c:	e8 1c fe ff ff       	call   800c7d <sys_page_unmap>
	sys_page_map(curenvid, PFTEMP, curenvid, addr, PTE_W | PTE_U | PTE_P);
  800e61:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e68:	53                   	push   %ebx
  800e69:	56                   	push   %esi
  800e6a:	68 00 f0 7f 00       	push   $0x7ff000
  800e6f:	56                   	push   %esi
  800e70:	e8 c6 fd ff ff       	call   800c3b <sys_page_map>
	sys_page_unmap(curenvid, PFTEMP);
  800e75:	83 c4 18             	add    $0x18,%esp
  800e78:	68 00 f0 7f 00       	push   $0x7ff000
  800e7d:	56                   	push   %esi
  800e7e:	e8 fa fd ff ff       	call   800c7d <sys_page_unmap>
}
  800e83:	83 c4 10             	add    $0x10,%esp
  800e86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e89:	5b                   	pop    %ebx
  800e8a:	5e                   	pop    %esi
  800e8b:	5f                   	pop    %edi
  800e8c:	5d                   	pop    %ebp
  800e8d:	c3                   	ret    

00800e8e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e8e:	55                   	push   %ebp
  800e8f:	89 e5                	mov    %esp,%ebp
  800e91:	57                   	push   %edi
  800e92:	56                   	push   %esi
  800e93:	53                   	push   %ebx
  800e94:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	extern void _pgfault_upcall();
	envid_t new_envid, curenv_id;

	curenv_id = sys_getenvid();
  800e97:	e8 1e fd ff ff       	call   800bba <sys_getenvid>
	set_pgfault_handler(pgfault);
  800e9c:	83 ec 0c             	sub    $0xc,%esp
  800e9f:	68 e9 0d 80 00       	push   $0x800de9
  800ea4:	e8 c8 0f 00 00       	call   801e71 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800ea9:	b8 07 00 00 00       	mov    $0x7,%eax
  800eae:	cd 30                	int    $0x30
  800eb0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800eb3:	89 45 dc             	mov    %eax,-0x24(%ebp)
	new_envid = sys_exofork();

	if (new_envid < 0)
  800eb6:	83 c4 10             	add    $0x10,%esp
  800eb9:	85 c0                	test   %eax,%eax
  800ebb:	79 12                	jns    800ecf <fork+0x41>
	    panic("fork error: %e", new_envid);
  800ebd:	50                   	push   %eax
  800ebe:	68 7c 25 80 00       	push   $0x80257c
  800ec3:	6a 75                	push   $0x75
  800ec5:	68 71 25 80 00       	push   $0x802571
  800eca:	e8 5c 0f 00 00       	call   801e2b <_panic>
  800ecf:	bf 00 00 80 00       	mov    $0x800000,%edi
	else if (new_envid == 0)
  800ed4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800ed8:	75 1c                	jne    800ef6 <fork+0x68>
		thisenv = envs + ENVX(sys_getenvid());
  800eda:	e8 db fc ff ff       	call   800bba <sys_getenvid>
  800edf:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ee4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ee7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800eec:	a3 08 40 80 00       	mov    %eax,0x804008
  800ef1:	e9 27 01 00 00       	jmp    80101d <fork+0x18f>
	else {

		for (uint32_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
			if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
  800ef6:	89 f8                	mov    %edi,%eax
  800ef8:	c1 e8 16             	shr    $0x16,%eax
  800efb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f02:	a8 01                	test   $0x1,%al
  800f04:	0f 84 d2 00 00 00    	je     800fdc <fork+0x14e>
  800f0a:	89 fb                	mov    %edi,%ebx
  800f0c:	c1 eb 0c             	shr    $0xc,%ebx
  800f0f:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f16:	a8 01                	test   $0x1,%al
  800f18:	0f 84 be 00 00 00    	je     800fdc <fork+0x14e>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	int perm = PTE_U | PTE_P;
	envid_t curenvid = sys_getenvid();
  800f1e:	e8 97 fc ff ff       	call   800bba <sys_getenvid>
  800f23:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  800f26:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
		perm |= PTE_COW ;
  800f2d:	be 05 08 00 00       	mov    $0x805,%esi
	int r;
	int perm = PTE_U | PTE_P;
	envid_t curenvid = sys_getenvid();

	// LAB 4: Your code here.
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  800f32:	a8 02                	test   $0x2,%al
  800f34:	75 1d                	jne    800f53 <fork+0xc5>
  800f36:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f3d:	25 00 08 00 00       	and    $0x800,%eax
		perm |= PTE_COW ;
  800f42:	83 f8 01             	cmp    $0x1,%eax
  800f45:	19 f6                	sbb    %esi,%esi
  800f47:	81 e6 00 f8 ff ff    	and    $0xfffff800,%esi
  800f4d:	81 c6 05 08 00 00    	add    $0x805,%esi

	if (uvpt[pn] & PTE_SHARE)
  800f53:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f5a:	25 00 04 00 00       	and    $0x400,%eax
		perm |= PTE_SYSCALL;
  800f5f:	b8 07 0e 00 00       	mov    $0xe07,%eax
  800f64:	0f 45 f0             	cmovne %eax,%esi

	r = sys_page_map(curenvid, (void *)(pn * PGSIZE),
  800f67:	89 d8                	mov    %ebx,%eax
  800f69:	c1 e0 0c             	shl    $0xc,%eax
  800f6c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f6f:	83 ec 0c             	sub    $0xc,%esp
  800f72:	56                   	push   %esi
  800f73:	50                   	push   %eax
  800f74:	ff 75 dc             	pushl  -0x24(%ebp)
  800f77:	50                   	push   %eax
  800f78:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f7b:	e8 bb fc ff ff       	call   800c3b <sys_page_map>
				envid, (void *)(pn * PGSIZE), perm);
	if (r < 0)
  800f80:	83 c4 20             	add    $0x20,%esp
  800f83:	85 c0                	test   %eax,%eax
  800f85:	79 12                	jns    800f99 <fork+0x10b>
		panic("duppage error: %e", r);
  800f87:	50                   	push   %eax
  800f88:	68 8b 25 80 00       	push   $0x80258b
  800f8d:	6a 4d                	push   $0x4d
  800f8f:	68 71 25 80 00       	push   $0x802571
  800f94:	e8 92 0e 00 00       	call   801e2b <_panic>
	
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))	{
  800f99:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800fa0:	a8 02                	test   $0x2,%al
  800fa2:	75 0c                	jne    800fb0 <fork+0x122>
  800fa4:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800fab:	f6 c4 08             	test   $0x8,%ah
  800fae:	74 2c                	je     800fdc <fork+0x14e>
		r = sys_page_map(curenvid, (void *)(pn * PGSIZE),
  800fb0:	83 ec 0c             	sub    $0xc,%esp
  800fb3:	56                   	push   %esi
  800fb4:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800fb7:	52                   	push   %edx
  800fb8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800fbb:	50                   	push   %eax
  800fbc:	52                   	push   %edx
  800fbd:	50                   	push   %eax
  800fbe:	e8 78 fc ff ff       	call   800c3b <sys_page_map>
						curenvid, (void *)(pn * PGSIZE), perm);
		if (r < 0)
  800fc3:	83 c4 20             	add    $0x20,%esp
  800fc6:	85 c0                	test   %eax,%eax
  800fc8:	79 12                	jns    800fdc <fork+0x14e>
			panic("duppage error: %e", r);
  800fca:	50                   	push   %eax
  800fcb:	68 8b 25 80 00       	push   $0x80258b
  800fd0:	6a 53                	push   $0x53
  800fd2:	68 71 25 80 00       	push   $0x802571
  800fd7:	e8 4f 0e 00 00       	call   801e2b <_panic>
	    panic("fork error: %e", new_envid);
	else if (new_envid == 0)
		thisenv = envs + ENVX(sys_getenvid());
	else {

		for (uint32_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
  800fdc:	81 c7 00 10 00 00    	add    $0x1000,%edi
  800fe2:	81 ff 00 e0 bf ee    	cmp    $0xeebfe000,%edi
  800fe8:	0f 85 08 ff ff ff    	jne    800ef6 <fork+0x68>
			if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
				duppage(new_envid, PGNUM(addr));
		}

		sys_page_alloc(new_envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  800fee:	83 ec 04             	sub    $0x4,%esp
  800ff1:	6a 07                	push   $0x7
  800ff3:	68 00 f0 bf ee       	push   $0xeebff000
  800ff8:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800ffb:	56                   	push   %esi
  800ffc:	e8 f7 fb ff ff       	call   800bf8 <sys_page_alloc>
		sys_env_set_pgfault_upcall(new_envid, _pgfault_upcall);
  801001:	83 c4 08             	add    $0x8,%esp
  801004:	68 b6 1e 80 00       	push   $0x801eb6
  801009:	56                   	push   %esi
  80100a:	e8 34 fd ff ff       	call   800d43 <sys_env_set_pgfault_upcall>
		sys_env_set_status(new_envid, ENV_RUNNABLE);
  80100f:	83 c4 08             	add    $0x8,%esp
  801012:	6a 02                	push   $0x2
  801014:	56                   	push   %esi
  801015:	e8 a5 fc ff ff       	call   800cbf <sys_env_set_status>
  80101a:	83 c4 10             	add    $0x10,%esp

	}
	return new_envid;
}
  80101d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801020:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801023:	5b                   	pop    %ebx
  801024:	5e                   	pop    %esi
  801025:	5f                   	pop    %edi
  801026:	5d                   	pop    %ebp
  801027:	c3                   	ret    

00801028 <sfork>:

// Challenge!
int
sfork(void)
{
  801028:	55                   	push   %ebp
  801029:	89 e5                	mov    %esp,%ebp
  80102b:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80102e:	68 9d 25 80 00       	push   $0x80259d
  801033:	68 8b 00 00 00       	push   $0x8b
  801038:	68 71 25 80 00       	push   $0x802571
  80103d:	e8 e9 0d 00 00       	call   801e2b <_panic>

00801042 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801042:	55                   	push   %ebp
  801043:	89 e5                	mov    %esp,%ebp
  801045:	56                   	push   %esi
  801046:	53                   	push   %ebx
  801047:	8b 75 08             	mov    0x8(%ebp),%esi
  80104a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80104d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

    if (pg != NULL)
  801050:	85 c0                	test   %eax,%eax
  801052:	74 0e                	je     801062 <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  801054:	83 ec 0c             	sub    $0xc,%esp
  801057:	50                   	push   %eax
  801058:	e8 4b fd ff ff       	call   800da8 <sys_ipc_recv>
  80105d:	83 c4 10             	add    $0x10,%esp
  801060:	eb 0d                	jmp    80106f <ipc_recv+0x2d>
	else
        r = sys_ipc_recv((void *)-1);
  801062:	83 ec 0c             	sub    $0xc,%esp
  801065:	6a ff                	push   $0xffffffff
  801067:	e8 3c fd ff ff       	call   800da8 <sys_ipc_recv>
  80106c:	83 c4 10             	add    $0x10,%esp

	if (r < 0) {
  80106f:	85 c0                	test   %eax,%eax
  801071:	79 16                	jns    801089 <ipc_recv+0x47>

		if (from_env_store != NULL)
  801073:	85 f6                	test   %esi,%esi
  801075:	74 06                	je     80107d <ipc_recv+0x3b>
			*from_env_store = 0;
  801077:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL)
  80107d:	85 db                	test   %ebx,%ebx
  80107f:	74 2c                	je     8010ad <ipc_recv+0x6b>
			*perm_store = 0;
  801081:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801087:	eb 24                	jmp    8010ad <ipc_recv+0x6b>
		return r;

	} else {

		if (from_env_store != NULL)
  801089:	85 f6                	test   %esi,%esi
  80108b:	74 0a                	je     801097 <ipc_recv+0x55>
			*from_env_store = thisenv->env_ipc_from;
  80108d:	a1 08 40 80 00       	mov    0x804008,%eax
  801092:	8b 40 74             	mov    0x74(%eax),%eax
  801095:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL)
  801097:	85 db                	test   %ebx,%ebx
  801099:	74 0a                	je     8010a5 <ipc_recv+0x63>
			*perm_store = thisenv->env_ipc_perm;
  80109b:	a1 08 40 80 00       	mov    0x804008,%eax
  8010a0:	8b 40 78             	mov    0x78(%eax),%eax
  8010a3:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  8010a5:	a1 08 40 80 00       	mov    0x804008,%eax
  8010aa:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  8010ad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010b0:	5b                   	pop    %ebx
  8010b1:	5e                   	pop    %esi
  8010b2:	5d                   	pop    %ebp
  8010b3:	c3                   	ret    

008010b4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8010b4:	55                   	push   %ebp
  8010b5:	89 e5                	mov    %esp,%ebp
  8010b7:	57                   	push   %edi
  8010b8:	56                   	push   %esi
  8010b9:	53                   	push   %ebx
  8010ba:	83 ec 0c             	sub    $0xc,%esp
  8010bd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010c0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010c3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

	if (pg == NULL)
  8010c6:	85 db                	test   %ebx,%ebx
		pg = (void *)-1;	
  8010c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8010cd:	0f 44 d8             	cmove  %eax,%ebx

	while (true) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  8010d0:	ff 75 14             	pushl  0x14(%ebp)
  8010d3:	53                   	push   %ebx
  8010d4:	56                   	push   %esi
  8010d5:	57                   	push   %edi
  8010d6:	e8 aa fc ff ff       	call   800d85 <sys_ipc_try_send>
		if (r >= 0)
  8010db:	83 c4 10             	add    $0x10,%esp
  8010de:	85 c0                	test   %eax,%eax
  8010e0:	79 1e                	jns    801100 <ipc_send+0x4c>
			return;
		else if (r != -E_IPC_NOT_RECV)
  8010e2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8010e5:	74 12                	je     8010f9 <ipc_send+0x45>
			panic("ipc_send error: %e", r);
  8010e7:	50                   	push   %eax
  8010e8:	68 b3 25 80 00       	push   $0x8025b3
  8010ed:	6a 49                	push   $0x49
  8010ef:	68 c6 25 80 00       	push   $0x8025c6
  8010f4:	e8 32 0d 00 00       	call   801e2b <_panic>
	
		sys_yield();
  8010f9:	e8 db fa ff ff       	call   800bd9 <sys_yield>
	}
  8010fe:	eb d0                	jmp    8010d0 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  801100:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801103:	5b                   	pop    %ebx
  801104:	5e                   	pop    %esi
  801105:	5f                   	pop    %edi
  801106:	5d                   	pop    %ebp
  801107:	c3                   	ret    

00801108 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801108:	55                   	push   %ebp
  801109:	89 e5                	mov    %esp,%ebp
  80110b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80110e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801113:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801116:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80111c:	8b 52 50             	mov    0x50(%edx),%edx
  80111f:	39 ca                	cmp    %ecx,%edx
  801121:	75 0d                	jne    801130 <ipc_find_env+0x28>
			return envs[i].env_id;
  801123:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801126:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80112b:	8b 40 48             	mov    0x48(%eax),%eax
  80112e:	eb 0f                	jmp    80113f <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801130:	83 c0 01             	add    $0x1,%eax
  801133:	3d 00 04 00 00       	cmp    $0x400,%eax
  801138:	75 d9                	jne    801113 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80113a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80113f:	5d                   	pop    %ebp
  801140:	c3                   	ret    

00801141 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801141:	55                   	push   %ebp
  801142:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801144:	8b 45 08             	mov    0x8(%ebp),%eax
  801147:	05 00 00 00 30       	add    $0x30000000,%eax
  80114c:	c1 e8 0c             	shr    $0xc,%eax
}
  80114f:	5d                   	pop    %ebp
  801150:	c3                   	ret    

00801151 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801151:	55                   	push   %ebp
  801152:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801154:	8b 45 08             	mov    0x8(%ebp),%eax
  801157:	05 00 00 00 30       	add    $0x30000000,%eax
  80115c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801161:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801166:	5d                   	pop    %ebp
  801167:	c3                   	ret    

00801168 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801168:	55                   	push   %ebp
  801169:	89 e5                	mov    %esp,%ebp
  80116b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80116e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801173:	89 c2                	mov    %eax,%edx
  801175:	c1 ea 16             	shr    $0x16,%edx
  801178:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80117f:	f6 c2 01             	test   $0x1,%dl
  801182:	74 11                	je     801195 <fd_alloc+0x2d>
  801184:	89 c2                	mov    %eax,%edx
  801186:	c1 ea 0c             	shr    $0xc,%edx
  801189:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801190:	f6 c2 01             	test   $0x1,%dl
  801193:	75 09                	jne    80119e <fd_alloc+0x36>
			*fd_store = fd;
  801195:	89 01                	mov    %eax,(%ecx)
			return 0;
  801197:	b8 00 00 00 00       	mov    $0x0,%eax
  80119c:	eb 17                	jmp    8011b5 <fd_alloc+0x4d>
  80119e:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011a3:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011a8:	75 c9                	jne    801173 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011aa:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011b0:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011b5:	5d                   	pop    %ebp
  8011b6:	c3                   	ret    

008011b7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011b7:	55                   	push   %ebp
  8011b8:	89 e5                	mov    %esp,%ebp
  8011ba:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011bd:	83 f8 1f             	cmp    $0x1f,%eax
  8011c0:	77 36                	ja     8011f8 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011c2:	c1 e0 0c             	shl    $0xc,%eax
  8011c5:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011ca:	89 c2                	mov    %eax,%edx
  8011cc:	c1 ea 16             	shr    $0x16,%edx
  8011cf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011d6:	f6 c2 01             	test   $0x1,%dl
  8011d9:	74 24                	je     8011ff <fd_lookup+0x48>
  8011db:	89 c2                	mov    %eax,%edx
  8011dd:	c1 ea 0c             	shr    $0xc,%edx
  8011e0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011e7:	f6 c2 01             	test   $0x1,%dl
  8011ea:	74 1a                	je     801206 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011ef:	89 02                	mov    %eax,(%edx)
	return 0;
  8011f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8011f6:	eb 13                	jmp    80120b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011f8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011fd:	eb 0c                	jmp    80120b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801204:	eb 05                	jmp    80120b <fd_lookup+0x54>
  801206:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80120b:	5d                   	pop    %ebp
  80120c:	c3                   	ret    

0080120d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80120d:	55                   	push   %ebp
  80120e:	89 e5                	mov    %esp,%ebp
  801210:	83 ec 08             	sub    $0x8,%esp
  801213:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801216:	ba 4c 26 80 00       	mov    $0x80264c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80121b:	eb 13                	jmp    801230 <dev_lookup+0x23>
  80121d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801220:	39 08                	cmp    %ecx,(%eax)
  801222:	75 0c                	jne    801230 <dev_lookup+0x23>
			*dev = devtab[i];
  801224:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801227:	89 01                	mov    %eax,(%ecx)
			return 0;
  801229:	b8 00 00 00 00       	mov    $0x0,%eax
  80122e:	eb 2e                	jmp    80125e <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801230:	8b 02                	mov    (%edx),%eax
  801232:	85 c0                	test   %eax,%eax
  801234:	75 e7                	jne    80121d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801236:	a1 08 40 80 00       	mov    0x804008,%eax
  80123b:	8b 40 48             	mov    0x48(%eax),%eax
  80123e:	83 ec 04             	sub    $0x4,%esp
  801241:	51                   	push   %ecx
  801242:	50                   	push   %eax
  801243:	68 d0 25 80 00       	push   $0x8025d0
  801248:	e8 a4 ef ff ff       	call   8001f1 <cprintf>
	*dev = 0;
  80124d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801250:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801256:	83 c4 10             	add    $0x10,%esp
  801259:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80125e:	c9                   	leave  
  80125f:	c3                   	ret    

00801260 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801260:	55                   	push   %ebp
  801261:	89 e5                	mov    %esp,%ebp
  801263:	56                   	push   %esi
  801264:	53                   	push   %ebx
  801265:	83 ec 10             	sub    $0x10,%esp
  801268:	8b 75 08             	mov    0x8(%ebp),%esi
  80126b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80126e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801271:	50                   	push   %eax
  801272:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801278:	c1 e8 0c             	shr    $0xc,%eax
  80127b:	50                   	push   %eax
  80127c:	e8 36 ff ff ff       	call   8011b7 <fd_lookup>
  801281:	83 c4 08             	add    $0x8,%esp
  801284:	85 c0                	test   %eax,%eax
  801286:	78 05                	js     80128d <fd_close+0x2d>
	    || fd != fd2)
  801288:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80128b:	74 0c                	je     801299 <fd_close+0x39>
		return (must_exist ? r : 0);
  80128d:	84 db                	test   %bl,%bl
  80128f:	ba 00 00 00 00       	mov    $0x0,%edx
  801294:	0f 44 c2             	cmove  %edx,%eax
  801297:	eb 41                	jmp    8012da <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801299:	83 ec 08             	sub    $0x8,%esp
  80129c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80129f:	50                   	push   %eax
  8012a0:	ff 36                	pushl  (%esi)
  8012a2:	e8 66 ff ff ff       	call   80120d <dev_lookup>
  8012a7:	89 c3                	mov    %eax,%ebx
  8012a9:	83 c4 10             	add    $0x10,%esp
  8012ac:	85 c0                	test   %eax,%eax
  8012ae:	78 1a                	js     8012ca <fd_close+0x6a>
		if (dev->dev_close)
  8012b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b3:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012b6:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012bb:	85 c0                	test   %eax,%eax
  8012bd:	74 0b                	je     8012ca <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012bf:	83 ec 0c             	sub    $0xc,%esp
  8012c2:	56                   	push   %esi
  8012c3:	ff d0                	call   *%eax
  8012c5:	89 c3                	mov    %eax,%ebx
  8012c7:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8012ca:	83 ec 08             	sub    $0x8,%esp
  8012cd:	56                   	push   %esi
  8012ce:	6a 00                	push   $0x0
  8012d0:	e8 a8 f9 ff ff       	call   800c7d <sys_page_unmap>
	return r;
  8012d5:	83 c4 10             	add    $0x10,%esp
  8012d8:	89 d8                	mov    %ebx,%eax
}
  8012da:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012dd:	5b                   	pop    %ebx
  8012de:	5e                   	pop    %esi
  8012df:	5d                   	pop    %ebp
  8012e0:	c3                   	ret    

008012e1 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8012e1:	55                   	push   %ebp
  8012e2:	89 e5                	mov    %esp,%ebp
  8012e4:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ea:	50                   	push   %eax
  8012eb:	ff 75 08             	pushl  0x8(%ebp)
  8012ee:	e8 c4 fe ff ff       	call   8011b7 <fd_lookup>
  8012f3:	83 c4 08             	add    $0x8,%esp
  8012f6:	85 c0                	test   %eax,%eax
  8012f8:	78 10                	js     80130a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8012fa:	83 ec 08             	sub    $0x8,%esp
  8012fd:	6a 01                	push   $0x1
  8012ff:	ff 75 f4             	pushl  -0xc(%ebp)
  801302:	e8 59 ff ff ff       	call   801260 <fd_close>
  801307:	83 c4 10             	add    $0x10,%esp
}
  80130a:	c9                   	leave  
  80130b:	c3                   	ret    

0080130c <close_all>:

void
close_all(void)
{
  80130c:	55                   	push   %ebp
  80130d:	89 e5                	mov    %esp,%ebp
  80130f:	53                   	push   %ebx
  801310:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801313:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801318:	83 ec 0c             	sub    $0xc,%esp
  80131b:	53                   	push   %ebx
  80131c:	e8 c0 ff ff ff       	call   8012e1 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801321:	83 c3 01             	add    $0x1,%ebx
  801324:	83 c4 10             	add    $0x10,%esp
  801327:	83 fb 20             	cmp    $0x20,%ebx
  80132a:	75 ec                	jne    801318 <close_all+0xc>
		close(i);
}
  80132c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80132f:	c9                   	leave  
  801330:	c3                   	ret    

00801331 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801331:	55                   	push   %ebp
  801332:	89 e5                	mov    %esp,%ebp
  801334:	57                   	push   %edi
  801335:	56                   	push   %esi
  801336:	53                   	push   %ebx
  801337:	83 ec 2c             	sub    $0x2c,%esp
  80133a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80133d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801340:	50                   	push   %eax
  801341:	ff 75 08             	pushl  0x8(%ebp)
  801344:	e8 6e fe ff ff       	call   8011b7 <fd_lookup>
  801349:	83 c4 08             	add    $0x8,%esp
  80134c:	85 c0                	test   %eax,%eax
  80134e:	0f 88 c1 00 00 00    	js     801415 <dup+0xe4>
		return r;
	close(newfdnum);
  801354:	83 ec 0c             	sub    $0xc,%esp
  801357:	56                   	push   %esi
  801358:	e8 84 ff ff ff       	call   8012e1 <close>

	newfd = INDEX2FD(newfdnum);
  80135d:	89 f3                	mov    %esi,%ebx
  80135f:	c1 e3 0c             	shl    $0xc,%ebx
  801362:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801368:	83 c4 04             	add    $0x4,%esp
  80136b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80136e:	e8 de fd ff ff       	call   801151 <fd2data>
  801373:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801375:	89 1c 24             	mov    %ebx,(%esp)
  801378:	e8 d4 fd ff ff       	call   801151 <fd2data>
  80137d:	83 c4 10             	add    $0x10,%esp
  801380:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801383:	89 f8                	mov    %edi,%eax
  801385:	c1 e8 16             	shr    $0x16,%eax
  801388:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80138f:	a8 01                	test   $0x1,%al
  801391:	74 37                	je     8013ca <dup+0x99>
  801393:	89 f8                	mov    %edi,%eax
  801395:	c1 e8 0c             	shr    $0xc,%eax
  801398:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80139f:	f6 c2 01             	test   $0x1,%dl
  8013a2:	74 26                	je     8013ca <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013a4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013ab:	83 ec 0c             	sub    $0xc,%esp
  8013ae:	25 07 0e 00 00       	and    $0xe07,%eax
  8013b3:	50                   	push   %eax
  8013b4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013b7:	6a 00                	push   $0x0
  8013b9:	57                   	push   %edi
  8013ba:	6a 00                	push   $0x0
  8013bc:	e8 7a f8 ff ff       	call   800c3b <sys_page_map>
  8013c1:	89 c7                	mov    %eax,%edi
  8013c3:	83 c4 20             	add    $0x20,%esp
  8013c6:	85 c0                	test   %eax,%eax
  8013c8:	78 2e                	js     8013f8 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013ca:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8013cd:	89 d0                	mov    %edx,%eax
  8013cf:	c1 e8 0c             	shr    $0xc,%eax
  8013d2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013d9:	83 ec 0c             	sub    $0xc,%esp
  8013dc:	25 07 0e 00 00       	and    $0xe07,%eax
  8013e1:	50                   	push   %eax
  8013e2:	53                   	push   %ebx
  8013e3:	6a 00                	push   $0x0
  8013e5:	52                   	push   %edx
  8013e6:	6a 00                	push   $0x0
  8013e8:	e8 4e f8 ff ff       	call   800c3b <sys_page_map>
  8013ed:	89 c7                	mov    %eax,%edi
  8013ef:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013f2:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013f4:	85 ff                	test   %edi,%edi
  8013f6:	79 1d                	jns    801415 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013f8:	83 ec 08             	sub    $0x8,%esp
  8013fb:	53                   	push   %ebx
  8013fc:	6a 00                	push   $0x0
  8013fe:	e8 7a f8 ff ff       	call   800c7d <sys_page_unmap>
	sys_page_unmap(0, nva);
  801403:	83 c4 08             	add    $0x8,%esp
  801406:	ff 75 d4             	pushl  -0x2c(%ebp)
  801409:	6a 00                	push   $0x0
  80140b:	e8 6d f8 ff ff       	call   800c7d <sys_page_unmap>
	return r;
  801410:	83 c4 10             	add    $0x10,%esp
  801413:	89 f8                	mov    %edi,%eax
}
  801415:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801418:	5b                   	pop    %ebx
  801419:	5e                   	pop    %esi
  80141a:	5f                   	pop    %edi
  80141b:	5d                   	pop    %ebp
  80141c:	c3                   	ret    

0080141d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80141d:	55                   	push   %ebp
  80141e:	89 e5                	mov    %esp,%ebp
  801420:	53                   	push   %ebx
  801421:	83 ec 14             	sub    $0x14,%esp
  801424:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801427:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80142a:	50                   	push   %eax
  80142b:	53                   	push   %ebx
  80142c:	e8 86 fd ff ff       	call   8011b7 <fd_lookup>
  801431:	83 c4 08             	add    $0x8,%esp
  801434:	89 c2                	mov    %eax,%edx
  801436:	85 c0                	test   %eax,%eax
  801438:	78 6d                	js     8014a7 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80143a:	83 ec 08             	sub    $0x8,%esp
  80143d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801440:	50                   	push   %eax
  801441:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801444:	ff 30                	pushl  (%eax)
  801446:	e8 c2 fd ff ff       	call   80120d <dev_lookup>
  80144b:	83 c4 10             	add    $0x10,%esp
  80144e:	85 c0                	test   %eax,%eax
  801450:	78 4c                	js     80149e <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801452:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801455:	8b 42 08             	mov    0x8(%edx),%eax
  801458:	83 e0 03             	and    $0x3,%eax
  80145b:	83 f8 01             	cmp    $0x1,%eax
  80145e:	75 21                	jne    801481 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801460:	a1 08 40 80 00       	mov    0x804008,%eax
  801465:	8b 40 48             	mov    0x48(%eax),%eax
  801468:	83 ec 04             	sub    $0x4,%esp
  80146b:	53                   	push   %ebx
  80146c:	50                   	push   %eax
  80146d:	68 11 26 80 00       	push   $0x802611
  801472:	e8 7a ed ff ff       	call   8001f1 <cprintf>
		return -E_INVAL;
  801477:	83 c4 10             	add    $0x10,%esp
  80147a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80147f:	eb 26                	jmp    8014a7 <read+0x8a>
	}
	if (!dev->dev_read)
  801481:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801484:	8b 40 08             	mov    0x8(%eax),%eax
  801487:	85 c0                	test   %eax,%eax
  801489:	74 17                	je     8014a2 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80148b:	83 ec 04             	sub    $0x4,%esp
  80148e:	ff 75 10             	pushl  0x10(%ebp)
  801491:	ff 75 0c             	pushl  0xc(%ebp)
  801494:	52                   	push   %edx
  801495:	ff d0                	call   *%eax
  801497:	89 c2                	mov    %eax,%edx
  801499:	83 c4 10             	add    $0x10,%esp
  80149c:	eb 09                	jmp    8014a7 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80149e:	89 c2                	mov    %eax,%edx
  8014a0:	eb 05                	jmp    8014a7 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014a2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014a7:	89 d0                	mov    %edx,%eax
  8014a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ac:	c9                   	leave  
  8014ad:	c3                   	ret    

008014ae <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014ae:	55                   	push   %ebp
  8014af:	89 e5                	mov    %esp,%ebp
  8014b1:	57                   	push   %edi
  8014b2:	56                   	push   %esi
  8014b3:	53                   	push   %ebx
  8014b4:	83 ec 0c             	sub    $0xc,%esp
  8014b7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014ba:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014bd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014c2:	eb 21                	jmp    8014e5 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014c4:	83 ec 04             	sub    $0x4,%esp
  8014c7:	89 f0                	mov    %esi,%eax
  8014c9:	29 d8                	sub    %ebx,%eax
  8014cb:	50                   	push   %eax
  8014cc:	89 d8                	mov    %ebx,%eax
  8014ce:	03 45 0c             	add    0xc(%ebp),%eax
  8014d1:	50                   	push   %eax
  8014d2:	57                   	push   %edi
  8014d3:	e8 45 ff ff ff       	call   80141d <read>
		if (m < 0)
  8014d8:	83 c4 10             	add    $0x10,%esp
  8014db:	85 c0                	test   %eax,%eax
  8014dd:	78 10                	js     8014ef <readn+0x41>
			return m;
		if (m == 0)
  8014df:	85 c0                	test   %eax,%eax
  8014e1:	74 0a                	je     8014ed <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014e3:	01 c3                	add    %eax,%ebx
  8014e5:	39 f3                	cmp    %esi,%ebx
  8014e7:	72 db                	jb     8014c4 <readn+0x16>
  8014e9:	89 d8                	mov    %ebx,%eax
  8014eb:	eb 02                	jmp    8014ef <readn+0x41>
  8014ed:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8014ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014f2:	5b                   	pop    %ebx
  8014f3:	5e                   	pop    %esi
  8014f4:	5f                   	pop    %edi
  8014f5:	5d                   	pop    %ebp
  8014f6:	c3                   	ret    

008014f7 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014f7:	55                   	push   %ebp
  8014f8:	89 e5                	mov    %esp,%ebp
  8014fa:	53                   	push   %ebx
  8014fb:	83 ec 14             	sub    $0x14,%esp
  8014fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801501:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801504:	50                   	push   %eax
  801505:	53                   	push   %ebx
  801506:	e8 ac fc ff ff       	call   8011b7 <fd_lookup>
  80150b:	83 c4 08             	add    $0x8,%esp
  80150e:	89 c2                	mov    %eax,%edx
  801510:	85 c0                	test   %eax,%eax
  801512:	78 68                	js     80157c <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801514:	83 ec 08             	sub    $0x8,%esp
  801517:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80151a:	50                   	push   %eax
  80151b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80151e:	ff 30                	pushl  (%eax)
  801520:	e8 e8 fc ff ff       	call   80120d <dev_lookup>
  801525:	83 c4 10             	add    $0x10,%esp
  801528:	85 c0                	test   %eax,%eax
  80152a:	78 47                	js     801573 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80152c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80152f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801533:	75 21                	jne    801556 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801535:	a1 08 40 80 00       	mov    0x804008,%eax
  80153a:	8b 40 48             	mov    0x48(%eax),%eax
  80153d:	83 ec 04             	sub    $0x4,%esp
  801540:	53                   	push   %ebx
  801541:	50                   	push   %eax
  801542:	68 2d 26 80 00       	push   $0x80262d
  801547:	e8 a5 ec ff ff       	call   8001f1 <cprintf>
		return -E_INVAL;
  80154c:	83 c4 10             	add    $0x10,%esp
  80154f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801554:	eb 26                	jmp    80157c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801556:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801559:	8b 52 0c             	mov    0xc(%edx),%edx
  80155c:	85 d2                	test   %edx,%edx
  80155e:	74 17                	je     801577 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801560:	83 ec 04             	sub    $0x4,%esp
  801563:	ff 75 10             	pushl  0x10(%ebp)
  801566:	ff 75 0c             	pushl  0xc(%ebp)
  801569:	50                   	push   %eax
  80156a:	ff d2                	call   *%edx
  80156c:	89 c2                	mov    %eax,%edx
  80156e:	83 c4 10             	add    $0x10,%esp
  801571:	eb 09                	jmp    80157c <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801573:	89 c2                	mov    %eax,%edx
  801575:	eb 05                	jmp    80157c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801577:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80157c:	89 d0                	mov    %edx,%eax
  80157e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801581:	c9                   	leave  
  801582:	c3                   	ret    

00801583 <seek>:

int
seek(int fdnum, off_t offset)
{
  801583:	55                   	push   %ebp
  801584:	89 e5                	mov    %esp,%ebp
  801586:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801589:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80158c:	50                   	push   %eax
  80158d:	ff 75 08             	pushl  0x8(%ebp)
  801590:	e8 22 fc ff ff       	call   8011b7 <fd_lookup>
  801595:	83 c4 08             	add    $0x8,%esp
  801598:	85 c0                	test   %eax,%eax
  80159a:	78 0e                	js     8015aa <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80159c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80159f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015a2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015aa:	c9                   	leave  
  8015ab:	c3                   	ret    

008015ac <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015ac:	55                   	push   %ebp
  8015ad:	89 e5                	mov    %esp,%ebp
  8015af:	53                   	push   %ebx
  8015b0:	83 ec 14             	sub    $0x14,%esp
  8015b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015b9:	50                   	push   %eax
  8015ba:	53                   	push   %ebx
  8015bb:	e8 f7 fb ff ff       	call   8011b7 <fd_lookup>
  8015c0:	83 c4 08             	add    $0x8,%esp
  8015c3:	89 c2                	mov    %eax,%edx
  8015c5:	85 c0                	test   %eax,%eax
  8015c7:	78 65                	js     80162e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c9:	83 ec 08             	sub    $0x8,%esp
  8015cc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015cf:	50                   	push   %eax
  8015d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d3:	ff 30                	pushl  (%eax)
  8015d5:	e8 33 fc ff ff       	call   80120d <dev_lookup>
  8015da:	83 c4 10             	add    $0x10,%esp
  8015dd:	85 c0                	test   %eax,%eax
  8015df:	78 44                	js     801625 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015e8:	75 21                	jne    80160b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8015ea:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015ef:	8b 40 48             	mov    0x48(%eax),%eax
  8015f2:	83 ec 04             	sub    $0x4,%esp
  8015f5:	53                   	push   %ebx
  8015f6:	50                   	push   %eax
  8015f7:	68 f0 25 80 00       	push   $0x8025f0
  8015fc:	e8 f0 eb ff ff       	call   8001f1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801601:	83 c4 10             	add    $0x10,%esp
  801604:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801609:	eb 23                	jmp    80162e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80160b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80160e:	8b 52 18             	mov    0x18(%edx),%edx
  801611:	85 d2                	test   %edx,%edx
  801613:	74 14                	je     801629 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801615:	83 ec 08             	sub    $0x8,%esp
  801618:	ff 75 0c             	pushl  0xc(%ebp)
  80161b:	50                   	push   %eax
  80161c:	ff d2                	call   *%edx
  80161e:	89 c2                	mov    %eax,%edx
  801620:	83 c4 10             	add    $0x10,%esp
  801623:	eb 09                	jmp    80162e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801625:	89 c2                	mov    %eax,%edx
  801627:	eb 05                	jmp    80162e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801629:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80162e:	89 d0                	mov    %edx,%eax
  801630:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801633:	c9                   	leave  
  801634:	c3                   	ret    

00801635 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801635:	55                   	push   %ebp
  801636:	89 e5                	mov    %esp,%ebp
  801638:	53                   	push   %ebx
  801639:	83 ec 14             	sub    $0x14,%esp
  80163c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80163f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801642:	50                   	push   %eax
  801643:	ff 75 08             	pushl  0x8(%ebp)
  801646:	e8 6c fb ff ff       	call   8011b7 <fd_lookup>
  80164b:	83 c4 08             	add    $0x8,%esp
  80164e:	89 c2                	mov    %eax,%edx
  801650:	85 c0                	test   %eax,%eax
  801652:	78 58                	js     8016ac <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801654:	83 ec 08             	sub    $0x8,%esp
  801657:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80165a:	50                   	push   %eax
  80165b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80165e:	ff 30                	pushl  (%eax)
  801660:	e8 a8 fb ff ff       	call   80120d <dev_lookup>
  801665:	83 c4 10             	add    $0x10,%esp
  801668:	85 c0                	test   %eax,%eax
  80166a:	78 37                	js     8016a3 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80166c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80166f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801673:	74 32                	je     8016a7 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801675:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801678:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80167f:	00 00 00 
	stat->st_isdir = 0;
  801682:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801689:	00 00 00 
	stat->st_dev = dev;
  80168c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801692:	83 ec 08             	sub    $0x8,%esp
  801695:	53                   	push   %ebx
  801696:	ff 75 f0             	pushl  -0x10(%ebp)
  801699:	ff 50 14             	call   *0x14(%eax)
  80169c:	89 c2                	mov    %eax,%edx
  80169e:	83 c4 10             	add    $0x10,%esp
  8016a1:	eb 09                	jmp    8016ac <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a3:	89 c2                	mov    %eax,%edx
  8016a5:	eb 05                	jmp    8016ac <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016a7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016ac:	89 d0                	mov    %edx,%eax
  8016ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016b1:	c9                   	leave  
  8016b2:	c3                   	ret    

008016b3 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016b3:	55                   	push   %ebp
  8016b4:	89 e5                	mov    %esp,%ebp
  8016b6:	56                   	push   %esi
  8016b7:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016b8:	83 ec 08             	sub    $0x8,%esp
  8016bb:	6a 00                	push   $0x0
  8016bd:	ff 75 08             	pushl  0x8(%ebp)
  8016c0:	e8 e3 01 00 00       	call   8018a8 <open>
  8016c5:	89 c3                	mov    %eax,%ebx
  8016c7:	83 c4 10             	add    $0x10,%esp
  8016ca:	85 c0                	test   %eax,%eax
  8016cc:	78 1b                	js     8016e9 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016ce:	83 ec 08             	sub    $0x8,%esp
  8016d1:	ff 75 0c             	pushl  0xc(%ebp)
  8016d4:	50                   	push   %eax
  8016d5:	e8 5b ff ff ff       	call   801635 <fstat>
  8016da:	89 c6                	mov    %eax,%esi
	close(fd);
  8016dc:	89 1c 24             	mov    %ebx,(%esp)
  8016df:	e8 fd fb ff ff       	call   8012e1 <close>
	return r;
  8016e4:	83 c4 10             	add    $0x10,%esp
  8016e7:	89 f0                	mov    %esi,%eax
}
  8016e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ec:	5b                   	pop    %ebx
  8016ed:	5e                   	pop    %esi
  8016ee:	5d                   	pop    %ebp
  8016ef:	c3                   	ret    

008016f0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016f0:	55                   	push   %ebp
  8016f1:	89 e5                	mov    %esp,%ebp
  8016f3:	56                   	push   %esi
  8016f4:	53                   	push   %ebx
  8016f5:	89 c6                	mov    %eax,%esi
  8016f7:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016f9:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801700:	75 12                	jne    801714 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801702:	83 ec 0c             	sub    $0xc,%esp
  801705:	6a 01                	push   $0x1
  801707:	e8 fc f9 ff ff       	call   801108 <ipc_find_env>
  80170c:	a3 00 40 80 00       	mov    %eax,0x804000
  801711:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801714:	6a 07                	push   $0x7
  801716:	68 00 50 80 00       	push   $0x805000
  80171b:	56                   	push   %esi
  80171c:	ff 35 00 40 80 00    	pushl  0x804000
  801722:	e8 8d f9 ff ff       	call   8010b4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801727:	83 c4 0c             	add    $0xc,%esp
  80172a:	6a 00                	push   $0x0
  80172c:	53                   	push   %ebx
  80172d:	6a 00                	push   $0x0
  80172f:	e8 0e f9 ff ff       	call   801042 <ipc_recv>
}
  801734:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801737:	5b                   	pop    %ebx
  801738:	5e                   	pop    %esi
  801739:	5d                   	pop    %ebp
  80173a:	c3                   	ret    

0080173b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80173b:	55                   	push   %ebp
  80173c:	89 e5                	mov    %esp,%ebp
  80173e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801741:	8b 45 08             	mov    0x8(%ebp),%eax
  801744:	8b 40 0c             	mov    0xc(%eax),%eax
  801747:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80174c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80174f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801754:	ba 00 00 00 00       	mov    $0x0,%edx
  801759:	b8 02 00 00 00       	mov    $0x2,%eax
  80175e:	e8 8d ff ff ff       	call   8016f0 <fsipc>
}
  801763:	c9                   	leave  
  801764:	c3                   	ret    

00801765 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801765:	55                   	push   %ebp
  801766:	89 e5                	mov    %esp,%ebp
  801768:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80176b:	8b 45 08             	mov    0x8(%ebp),%eax
  80176e:	8b 40 0c             	mov    0xc(%eax),%eax
  801771:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801776:	ba 00 00 00 00       	mov    $0x0,%edx
  80177b:	b8 06 00 00 00       	mov    $0x6,%eax
  801780:	e8 6b ff ff ff       	call   8016f0 <fsipc>
}
  801785:	c9                   	leave  
  801786:	c3                   	ret    

00801787 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801787:	55                   	push   %ebp
  801788:	89 e5                	mov    %esp,%ebp
  80178a:	53                   	push   %ebx
  80178b:	83 ec 04             	sub    $0x4,%esp
  80178e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801791:	8b 45 08             	mov    0x8(%ebp),%eax
  801794:	8b 40 0c             	mov    0xc(%eax),%eax
  801797:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80179c:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a1:	b8 05 00 00 00       	mov    $0x5,%eax
  8017a6:	e8 45 ff ff ff       	call   8016f0 <fsipc>
  8017ab:	85 c0                	test   %eax,%eax
  8017ad:	78 2c                	js     8017db <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017af:	83 ec 08             	sub    $0x8,%esp
  8017b2:	68 00 50 80 00       	push   $0x805000
  8017b7:	53                   	push   %ebx
  8017b8:	e8 38 f0 ff ff       	call   8007f5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017bd:	a1 80 50 80 00       	mov    0x805080,%eax
  8017c2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017c8:	a1 84 50 80 00       	mov    0x805084,%eax
  8017cd:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8017d3:	83 c4 10             	add    $0x10,%esp
  8017d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017de:	c9                   	leave  
  8017df:	c3                   	ret    

008017e0 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017e0:	55                   	push   %ebp
  8017e1:	89 e5                	mov    %esp,%ebp
  8017e3:	83 ec 0c             	sub    $0xc,%esp
  8017e6:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	
	int r;

	n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8017e9:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8017ee:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8017f3:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8017f9:	8b 52 0c             	mov    0xc(%edx),%edx
  8017fc:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801802:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801807:	50                   	push   %eax
  801808:	ff 75 0c             	pushl  0xc(%ebp)
  80180b:	68 08 50 80 00       	push   $0x805008
  801810:	e8 72 f1 ff ff       	call   800987 <memmove>
	
	return fsipc(FSREQ_WRITE, NULL);	
  801815:	ba 00 00 00 00       	mov    $0x0,%edx
  80181a:	b8 04 00 00 00       	mov    $0x4,%eax
  80181f:	e8 cc fe ff ff       	call   8016f0 <fsipc>
}
  801824:	c9                   	leave  
  801825:	c3                   	ret    

00801826 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801826:	55                   	push   %ebp
  801827:	89 e5                	mov    %esp,%ebp
  801829:	56                   	push   %esi
  80182a:	53                   	push   %ebx
  80182b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80182e:	8b 45 08             	mov    0x8(%ebp),%eax
  801831:	8b 40 0c             	mov    0xc(%eax),%eax
  801834:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801839:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80183f:	ba 00 00 00 00       	mov    $0x0,%edx
  801844:	b8 03 00 00 00       	mov    $0x3,%eax
  801849:	e8 a2 fe ff ff       	call   8016f0 <fsipc>
  80184e:	89 c3                	mov    %eax,%ebx
  801850:	85 c0                	test   %eax,%eax
  801852:	78 4b                	js     80189f <devfile_read+0x79>
		return r;
	assert(r <= n);
  801854:	39 c6                	cmp    %eax,%esi
  801856:	73 16                	jae    80186e <devfile_read+0x48>
  801858:	68 5c 26 80 00       	push   $0x80265c
  80185d:	68 63 26 80 00       	push   $0x802663
  801862:	6a 7c                	push   $0x7c
  801864:	68 78 26 80 00       	push   $0x802678
  801869:	e8 bd 05 00 00       	call   801e2b <_panic>
	assert(r <= PGSIZE);
  80186e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801873:	7e 16                	jle    80188b <devfile_read+0x65>
  801875:	68 83 26 80 00       	push   $0x802683
  80187a:	68 63 26 80 00       	push   $0x802663
  80187f:	6a 7d                	push   $0x7d
  801881:	68 78 26 80 00       	push   $0x802678
  801886:	e8 a0 05 00 00       	call   801e2b <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80188b:	83 ec 04             	sub    $0x4,%esp
  80188e:	50                   	push   %eax
  80188f:	68 00 50 80 00       	push   $0x805000
  801894:	ff 75 0c             	pushl  0xc(%ebp)
  801897:	e8 eb f0 ff ff       	call   800987 <memmove>
	return r;
  80189c:	83 c4 10             	add    $0x10,%esp
}
  80189f:	89 d8                	mov    %ebx,%eax
  8018a1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018a4:	5b                   	pop    %ebx
  8018a5:	5e                   	pop    %esi
  8018a6:	5d                   	pop    %ebp
  8018a7:	c3                   	ret    

008018a8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018a8:	55                   	push   %ebp
  8018a9:	89 e5                	mov    %esp,%ebp
  8018ab:	53                   	push   %ebx
  8018ac:	83 ec 20             	sub    $0x20,%esp
  8018af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018b2:	53                   	push   %ebx
  8018b3:	e8 04 ef ff ff       	call   8007bc <strlen>
  8018b8:	83 c4 10             	add    $0x10,%esp
  8018bb:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018c0:	7f 67                	jg     801929 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018c2:	83 ec 0c             	sub    $0xc,%esp
  8018c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018c8:	50                   	push   %eax
  8018c9:	e8 9a f8 ff ff       	call   801168 <fd_alloc>
  8018ce:	83 c4 10             	add    $0x10,%esp
		return r;
  8018d1:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018d3:	85 c0                	test   %eax,%eax
  8018d5:	78 57                	js     80192e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8018d7:	83 ec 08             	sub    $0x8,%esp
  8018da:	53                   	push   %ebx
  8018db:	68 00 50 80 00       	push   $0x805000
  8018e0:	e8 10 ef ff ff       	call   8007f5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e8:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018f0:	b8 01 00 00 00       	mov    $0x1,%eax
  8018f5:	e8 f6 fd ff ff       	call   8016f0 <fsipc>
  8018fa:	89 c3                	mov    %eax,%ebx
  8018fc:	83 c4 10             	add    $0x10,%esp
  8018ff:	85 c0                	test   %eax,%eax
  801901:	79 14                	jns    801917 <open+0x6f>
		fd_close(fd, 0);
  801903:	83 ec 08             	sub    $0x8,%esp
  801906:	6a 00                	push   $0x0
  801908:	ff 75 f4             	pushl  -0xc(%ebp)
  80190b:	e8 50 f9 ff ff       	call   801260 <fd_close>
		return r;
  801910:	83 c4 10             	add    $0x10,%esp
  801913:	89 da                	mov    %ebx,%edx
  801915:	eb 17                	jmp    80192e <open+0x86>
	}

	return fd2num(fd);
  801917:	83 ec 0c             	sub    $0xc,%esp
  80191a:	ff 75 f4             	pushl  -0xc(%ebp)
  80191d:	e8 1f f8 ff ff       	call   801141 <fd2num>
  801922:	89 c2                	mov    %eax,%edx
  801924:	83 c4 10             	add    $0x10,%esp
  801927:	eb 05                	jmp    80192e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801929:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80192e:	89 d0                	mov    %edx,%eax
  801930:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801933:	c9                   	leave  
  801934:	c3                   	ret    

00801935 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801935:	55                   	push   %ebp
  801936:	89 e5                	mov    %esp,%ebp
  801938:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80193b:	ba 00 00 00 00       	mov    $0x0,%edx
  801940:	b8 08 00 00 00       	mov    $0x8,%eax
  801945:	e8 a6 fd ff ff       	call   8016f0 <fsipc>
}
  80194a:	c9                   	leave  
  80194b:	c3                   	ret    

0080194c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80194c:	55                   	push   %ebp
  80194d:	89 e5                	mov    %esp,%ebp
  80194f:	56                   	push   %esi
  801950:	53                   	push   %ebx
  801951:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801954:	83 ec 0c             	sub    $0xc,%esp
  801957:	ff 75 08             	pushl  0x8(%ebp)
  80195a:	e8 f2 f7 ff ff       	call   801151 <fd2data>
  80195f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801961:	83 c4 08             	add    $0x8,%esp
  801964:	68 8f 26 80 00       	push   $0x80268f
  801969:	53                   	push   %ebx
  80196a:	e8 86 ee ff ff       	call   8007f5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80196f:	8b 46 04             	mov    0x4(%esi),%eax
  801972:	2b 06                	sub    (%esi),%eax
  801974:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80197a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801981:	00 00 00 
	stat->st_dev = &devpipe;
  801984:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80198b:	30 80 00 
	return 0;
}
  80198e:	b8 00 00 00 00       	mov    $0x0,%eax
  801993:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801996:	5b                   	pop    %ebx
  801997:	5e                   	pop    %esi
  801998:	5d                   	pop    %ebp
  801999:	c3                   	ret    

0080199a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80199a:	55                   	push   %ebp
  80199b:	89 e5                	mov    %esp,%ebp
  80199d:	53                   	push   %ebx
  80199e:	83 ec 0c             	sub    $0xc,%esp
  8019a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019a4:	53                   	push   %ebx
  8019a5:	6a 00                	push   $0x0
  8019a7:	e8 d1 f2 ff ff       	call   800c7d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019ac:	89 1c 24             	mov    %ebx,(%esp)
  8019af:	e8 9d f7 ff ff       	call   801151 <fd2data>
  8019b4:	83 c4 08             	add    $0x8,%esp
  8019b7:	50                   	push   %eax
  8019b8:	6a 00                	push   $0x0
  8019ba:	e8 be f2 ff ff       	call   800c7d <sys_page_unmap>
}
  8019bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019c2:	c9                   	leave  
  8019c3:	c3                   	ret    

008019c4 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019c4:	55                   	push   %ebp
  8019c5:	89 e5                	mov    %esp,%ebp
  8019c7:	57                   	push   %edi
  8019c8:	56                   	push   %esi
  8019c9:	53                   	push   %ebx
  8019ca:	83 ec 1c             	sub    $0x1c,%esp
  8019cd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8019d0:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019d2:	a1 08 40 80 00       	mov    0x804008,%eax
  8019d7:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8019da:	83 ec 0c             	sub    $0xc,%esp
  8019dd:	ff 75 e0             	pushl  -0x20(%ebp)
  8019e0:	e8 f7 04 00 00       	call   801edc <pageref>
  8019e5:	89 c3                	mov    %eax,%ebx
  8019e7:	89 3c 24             	mov    %edi,(%esp)
  8019ea:	e8 ed 04 00 00       	call   801edc <pageref>
  8019ef:	83 c4 10             	add    $0x10,%esp
  8019f2:	39 c3                	cmp    %eax,%ebx
  8019f4:	0f 94 c1             	sete   %cl
  8019f7:	0f b6 c9             	movzbl %cl,%ecx
  8019fa:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8019fd:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801a03:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a06:	39 ce                	cmp    %ecx,%esi
  801a08:	74 1b                	je     801a25 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a0a:	39 c3                	cmp    %eax,%ebx
  801a0c:	75 c4                	jne    8019d2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a0e:	8b 42 58             	mov    0x58(%edx),%eax
  801a11:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a14:	50                   	push   %eax
  801a15:	56                   	push   %esi
  801a16:	68 96 26 80 00       	push   $0x802696
  801a1b:	e8 d1 e7 ff ff       	call   8001f1 <cprintf>
  801a20:	83 c4 10             	add    $0x10,%esp
  801a23:	eb ad                	jmp    8019d2 <_pipeisclosed+0xe>
	}
}
  801a25:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a2b:	5b                   	pop    %ebx
  801a2c:	5e                   	pop    %esi
  801a2d:	5f                   	pop    %edi
  801a2e:	5d                   	pop    %ebp
  801a2f:	c3                   	ret    

00801a30 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a30:	55                   	push   %ebp
  801a31:	89 e5                	mov    %esp,%ebp
  801a33:	57                   	push   %edi
  801a34:	56                   	push   %esi
  801a35:	53                   	push   %ebx
  801a36:	83 ec 28             	sub    $0x28,%esp
  801a39:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a3c:	56                   	push   %esi
  801a3d:	e8 0f f7 ff ff       	call   801151 <fd2data>
  801a42:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a44:	83 c4 10             	add    $0x10,%esp
  801a47:	bf 00 00 00 00       	mov    $0x0,%edi
  801a4c:	eb 4b                	jmp    801a99 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a4e:	89 da                	mov    %ebx,%edx
  801a50:	89 f0                	mov    %esi,%eax
  801a52:	e8 6d ff ff ff       	call   8019c4 <_pipeisclosed>
  801a57:	85 c0                	test   %eax,%eax
  801a59:	75 48                	jne    801aa3 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a5b:	e8 79 f1 ff ff       	call   800bd9 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a60:	8b 43 04             	mov    0x4(%ebx),%eax
  801a63:	8b 0b                	mov    (%ebx),%ecx
  801a65:	8d 51 20             	lea    0x20(%ecx),%edx
  801a68:	39 d0                	cmp    %edx,%eax
  801a6a:	73 e2                	jae    801a4e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a6f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a73:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a76:	89 c2                	mov    %eax,%edx
  801a78:	c1 fa 1f             	sar    $0x1f,%edx
  801a7b:	89 d1                	mov    %edx,%ecx
  801a7d:	c1 e9 1b             	shr    $0x1b,%ecx
  801a80:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a83:	83 e2 1f             	and    $0x1f,%edx
  801a86:	29 ca                	sub    %ecx,%edx
  801a88:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a8c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a90:	83 c0 01             	add    $0x1,%eax
  801a93:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a96:	83 c7 01             	add    $0x1,%edi
  801a99:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a9c:	75 c2                	jne    801a60 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a9e:	8b 45 10             	mov    0x10(%ebp),%eax
  801aa1:	eb 05                	jmp    801aa8 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801aa3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801aa8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aab:	5b                   	pop    %ebx
  801aac:	5e                   	pop    %esi
  801aad:	5f                   	pop    %edi
  801aae:	5d                   	pop    %ebp
  801aaf:	c3                   	ret    

00801ab0 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ab0:	55                   	push   %ebp
  801ab1:	89 e5                	mov    %esp,%ebp
  801ab3:	57                   	push   %edi
  801ab4:	56                   	push   %esi
  801ab5:	53                   	push   %ebx
  801ab6:	83 ec 18             	sub    $0x18,%esp
  801ab9:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801abc:	57                   	push   %edi
  801abd:	e8 8f f6 ff ff       	call   801151 <fd2data>
  801ac2:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ac4:	83 c4 10             	add    $0x10,%esp
  801ac7:	bb 00 00 00 00       	mov    $0x0,%ebx
  801acc:	eb 3d                	jmp    801b0b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ace:	85 db                	test   %ebx,%ebx
  801ad0:	74 04                	je     801ad6 <devpipe_read+0x26>
				return i;
  801ad2:	89 d8                	mov    %ebx,%eax
  801ad4:	eb 44                	jmp    801b1a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ad6:	89 f2                	mov    %esi,%edx
  801ad8:	89 f8                	mov    %edi,%eax
  801ada:	e8 e5 fe ff ff       	call   8019c4 <_pipeisclosed>
  801adf:	85 c0                	test   %eax,%eax
  801ae1:	75 32                	jne    801b15 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ae3:	e8 f1 f0 ff ff       	call   800bd9 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ae8:	8b 06                	mov    (%esi),%eax
  801aea:	3b 46 04             	cmp    0x4(%esi),%eax
  801aed:	74 df                	je     801ace <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801aef:	99                   	cltd   
  801af0:	c1 ea 1b             	shr    $0x1b,%edx
  801af3:	01 d0                	add    %edx,%eax
  801af5:	83 e0 1f             	and    $0x1f,%eax
  801af8:	29 d0                	sub    %edx,%eax
  801afa:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801aff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b02:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b05:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b08:	83 c3 01             	add    $0x1,%ebx
  801b0b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b0e:	75 d8                	jne    801ae8 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b10:	8b 45 10             	mov    0x10(%ebp),%eax
  801b13:	eb 05                	jmp    801b1a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b15:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b1d:	5b                   	pop    %ebx
  801b1e:	5e                   	pop    %esi
  801b1f:	5f                   	pop    %edi
  801b20:	5d                   	pop    %ebp
  801b21:	c3                   	ret    

00801b22 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b22:	55                   	push   %ebp
  801b23:	89 e5                	mov    %esp,%ebp
  801b25:	56                   	push   %esi
  801b26:	53                   	push   %ebx
  801b27:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b2a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b2d:	50                   	push   %eax
  801b2e:	e8 35 f6 ff ff       	call   801168 <fd_alloc>
  801b33:	83 c4 10             	add    $0x10,%esp
  801b36:	89 c2                	mov    %eax,%edx
  801b38:	85 c0                	test   %eax,%eax
  801b3a:	0f 88 2c 01 00 00    	js     801c6c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b40:	83 ec 04             	sub    $0x4,%esp
  801b43:	68 07 04 00 00       	push   $0x407
  801b48:	ff 75 f4             	pushl  -0xc(%ebp)
  801b4b:	6a 00                	push   $0x0
  801b4d:	e8 a6 f0 ff ff       	call   800bf8 <sys_page_alloc>
  801b52:	83 c4 10             	add    $0x10,%esp
  801b55:	89 c2                	mov    %eax,%edx
  801b57:	85 c0                	test   %eax,%eax
  801b59:	0f 88 0d 01 00 00    	js     801c6c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b5f:	83 ec 0c             	sub    $0xc,%esp
  801b62:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b65:	50                   	push   %eax
  801b66:	e8 fd f5 ff ff       	call   801168 <fd_alloc>
  801b6b:	89 c3                	mov    %eax,%ebx
  801b6d:	83 c4 10             	add    $0x10,%esp
  801b70:	85 c0                	test   %eax,%eax
  801b72:	0f 88 e2 00 00 00    	js     801c5a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b78:	83 ec 04             	sub    $0x4,%esp
  801b7b:	68 07 04 00 00       	push   $0x407
  801b80:	ff 75 f0             	pushl  -0x10(%ebp)
  801b83:	6a 00                	push   $0x0
  801b85:	e8 6e f0 ff ff       	call   800bf8 <sys_page_alloc>
  801b8a:	89 c3                	mov    %eax,%ebx
  801b8c:	83 c4 10             	add    $0x10,%esp
  801b8f:	85 c0                	test   %eax,%eax
  801b91:	0f 88 c3 00 00 00    	js     801c5a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b97:	83 ec 0c             	sub    $0xc,%esp
  801b9a:	ff 75 f4             	pushl  -0xc(%ebp)
  801b9d:	e8 af f5 ff ff       	call   801151 <fd2data>
  801ba2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ba4:	83 c4 0c             	add    $0xc,%esp
  801ba7:	68 07 04 00 00       	push   $0x407
  801bac:	50                   	push   %eax
  801bad:	6a 00                	push   $0x0
  801baf:	e8 44 f0 ff ff       	call   800bf8 <sys_page_alloc>
  801bb4:	89 c3                	mov    %eax,%ebx
  801bb6:	83 c4 10             	add    $0x10,%esp
  801bb9:	85 c0                	test   %eax,%eax
  801bbb:	0f 88 89 00 00 00    	js     801c4a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bc1:	83 ec 0c             	sub    $0xc,%esp
  801bc4:	ff 75 f0             	pushl  -0x10(%ebp)
  801bc7:	e8 85 f5 ff ff       	call   801151 <fd2data>
  801bcc:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801bd3:	50                   	push   %eax
  801bd4:	6a 00                	push   $0x0
  801bd6:	56                   	push   %esi
  801bd7:	6a 00                	push   $0x0
  801bd9:	e8 5d f0 ff ff       	call   800c3b <sys_page_map>
  801bde:	89 c3                	mov    %eax,%ebx
  801be0:	83 c4 20             	add    $0x20,%esp
  801be3:	85 c0                	test   %eax,%eax
  801be5:	78 55                	js     801c3c <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801be7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bf0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801bf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bf5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801bfc:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c02:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c05:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c07:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c0a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c11:	83 ec 0c             	sub    $0xc,%esp
  801c14:	ff 75 f4             	pushl  -0xc(%ebp)
  801c17:	e8 25 f5 ff ff       	call   801141 <fd2num>
  801c1c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c1f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c21:	83 c4 04             	add    $0x4,%esp
  801c24:	ff 75 f0             	pushl  -0x10(%ebp)
  801c27:	e8 15 f5 ff ff       	call   801141 <fd2num>
  801c2c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c2f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c32:	83 c4 10             	add    $0x10,%esp
  801c35:	ba 00 00 00 00       	mov    $0x0,%edx
  801c3a:	eb 30                	jmp    801c6c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c3c:	83 ec 08             	sub    $0x8,%esp
  801c3f:	56                   	push   %esi
  801c40:	6a 00                	push   $0x0
  801c42:	e8 36 f0 ff ff       	call   800c7d <sys_page_unmap>
  801c47:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c4a:	83 ec 08             	sub    $0x8,%esp
  801c4d:	ff 75 f0             	pushl  -0x10(%ebp)
  801c50:	6a 00                	push   $0x0
  801c52:	e8 26 f0 ff ff       	call   800c7d <sys_page_unmap>
  801c57:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c5a:	83 ec 08             	sub    $0x8,%esp
  801c5d:	ff 75 f4             	pushl  -0xc(%ebp)
  801c60:	6a 00                	push   $0x0
  801c62:	e8 16 f0 ff ff       	call   800c7d <sys_page_unmap>
  801c67:	83 c4 10             	add    $0x10,%esp
  801c6a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c6c:	89 d0                	mov    %edx,%eax
  801c6e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c71:	5b                   	pop    %ebx
  801c72:	5e                   	pop    %esi
  801c73:	5d                   	pop    %ebp
  801c74:	c3                   	ret    

00801c75 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c75:	55                   	push   %ebp
  801c76:	89 e5                	mov    %esp,%ebp
  801c78:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c7b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c7e:	50                   	push   %eax
  801c7f:	ff 75 08             	pushl  0x8(%ebp)
  801c82:	e8 30 f5 ff ff       	call   8011b7 <fd_lookup>
  801c87:	83 c4 10             	add    $0x10,%esp
  801c8a:	85 c0                	test   %eax,%eax
  801c8c:	78 18                	js     801ca6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c8e:	83 ec 0c             	sub    $0xc,%esp
  801c91:	ff 75 f4             	pushl  -0xc(%ebp)
  801c94:	e8 b8 f4 ff ff       	call   801151 <fd2data>
	return _pipeisclosed(fd, p);
  801c99:	89 c2                	mov    %eax,%edx
  801c9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c9e:	e8 21 fd ff ff       	call   8019c4 <_pipeisclosed>
  801ca3:	83 c4 10             	add    $0x10,%esp
}
  801ca6:	c9                   	leave  
  801ca7:	c3                   	ret    

00801ca8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ca8:	55                   	push   %ebp
  801ca9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801cab:	b8 00 00 00 00       	mov    $0x0,%eax
  801cb0:	5d                   	pop    %ebp
  801cb1:	c3                   	ret    

00801cb2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801cb2:	55                   	push   %ebp
  801cb3:	89 e5                	mov    %esp,%ebp
  801cb5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801cb8:	68 ae 26 80 00       	push   $0x8026ae
  801cbd:	ff 75 0c             	pushl  0xc(%ebp)
  801cc0:	e8 30 eb ff ff       	call   8007f5 <strcpy>
	return 0;
}
  801cc5:	b8 00 00 00 00       	mov    $0x0,%eax
  801cca:	c9                   	leave  
  801ccb:	c3                   	ret    

00801ccc <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ccc:	55                   	push   %ebp
  801ccd:	89 e5                	mov    %esp,%ebp
  801ccf:	57                   	push   %edi
  801cd0:	56                   	push   %esi
  801cd1:	53                   	push   %ebx
  801cd2:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801cd8:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cdd:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ce3:	eb 2d                	jmp    801d12 <devcons_write+0x46>
		m = n - tot;
  801ce5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ce8:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801cea:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801ced:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801cf2:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801cf5:	83 ec 04             	sub    $0x4,%esp
  801cf8:	53                   	push   %ebx
  801cf9:	03 45 0c             	add    0xc(%ebp),%eax
  801cfc:	50                   	push   %eax
  801cfd:	57                   	push   %edi
  801cfe:	e8 84 ec ff ff       	call   800987 <memmove>
		sys_cputs(buf, m);
  801d03:	83 c4 08             	add    $0x8,%esp
  801d06:	53                   	push   %ebx
  801d07:	57                   	push   %edi
  801d08:	e8 2f ee ff ff       	call   800b3c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d0d:	01 de                	add    %ebx,%esi
  801d0f:	83 c4 10             	add    $0x10,%esp
  801d12:	89 f0                	mov    %esi,%eax
  801d14:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d17:	72 cc                	jb     801ce5 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d1c:	5b                   	pop    %ebx
  801d1d:	5e                   	pop    %esi
  801d1e:	5f                   	pop    %edi
  801d1f:	5d                   	pop    %ebp
  801d20:	c3                   	ret    

00801d21 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d21:	55                   	push   %ebp
  801d22:	89 e5                	mov    %esp,%ebp
  801d24:	83 ec 08             	sub    $0x8,%esp
  801d27:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801d2c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d30:	74 2a                	je     801d5c <devcons_read+0x3b>
  801d32:	eb 05                	jmp    801d39 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801d34:	e8 a0 ee ff ff       	call   800bd9 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801d39:	e8 1c ee ff ff       	call   800b5a <sys_cgetc>
  801d3e:	85 c0                	test   %eax,%eax
  801d40:	74 f2                	je     801d34 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801d42:	85 c0                	test   %eax,%eax
  801d44:	78 16                	js     801d5c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801d46:	83 f8 04             	cmp    $0x4,%eax
  801d49:	74 0c                	je     801d57 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801d4b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d4e:	88 02                	mov    %al,(%edx)
	return 1;
  801d50:	b8 01 00 00 00       	mov    $0x1,%eax
  801d55:	eb 05                	jmp    801d5c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801d57:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801d5c:	c9                   	leave  
  801d5d:	c3                   	ret    

00801d5e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801d5e:	55                   	push   %ebp
  801d5f:	89 e5                	mov    %esp,%ebp
  801d61:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d64:	8b 45 08             	mov    0x8(%ebp),%eax
  801d67:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801d6a:	6a 01                	push   $0x1
  801d6c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d6f:	50                   	push   %eax
  801d70:	e8 c7 ed ff ff       	call   800b3c <sys_cputs>
}
  801d75:	83 c4 10             	add    $0x10,%esp
  801d78:	c9                   	leave  
  801d79:	c3                   	ret    

00801d7a <getchar>:

int
getchar(void)
{
  801d7a:	55                   	push   %ebp
  801d7b:	89 e5                	mov    %esp,%ebp
  801d7d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801d80:	6a 01                	push   $0x1
  801d82:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d85:	50                   	push   %eax
  801d86:	6a 00                	push   $0x0
  801d88:	e8 90 f6 ff ff       	call   80141d <read>
	if (r < 0)
  801d8d:	83 c4 10             	add    $0x10,%esp
  801d90:	85 c0                	test   %eax,%eax
  801d92:	78 0f                	js     801da3 <getchar+0x29>
		return r;
	if (r < 1)
  801d94:	85 c0                	test   %eax,%eax
  801d96:	7e 06                	jle    801d9e <getchar+0x24>
		return -E_EOF;
	return c;
  801d98:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d9c:	eb 05                	jmp    801da3 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d9e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801da3:	c9                   	leave  
  801da4:	c3                   	ret    

00801da5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801da5:	55                   	push   %ebp
  801da6:	89 e5                	mov    %esp,%ebp
  801da8:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dae:	50                   	push   %eax
  801daf:	ff 75 08             	pushl  0x8(%ebp)
  801db2:	e8 00 f4 ff ff       	call   8011b7 <fd_lookup>
  801db7:	83 c4 10             	add    $0x10,%esp
  801dba:	85 c0                	test   %eax,%eax
  801dbc:	78 11                	js     801dcf <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801dbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dc1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801dc7:	39 10                	cmp    %edx,(%eax)
  801dc9:	0f 94 c0             	sete   %al
  801dcc:	0f b6 c0             	movzbl %al,%eax
}
  801dcf:	c9                   	leave  
  801dd0:	c3                   	ret    

00801dd1 <opencons>:

int
opencons(void)
{
  801dd1:	55                   	push   %ebp
  801dd2:	89 e5                	mov    %esp,%ebp
  801dd4:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801dd7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dda:	50                   	push   %eax
  801ddb:	e8 88 f3 ff ff       	call   801168 <fd_alloc>
  801de0:	83 c4 10             	add    $0x10,%esp
		return r;
  801de3:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801de5:	85 c0                	test   %eax,%eax
  801de7:	78 3e                	js     801e27 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801de9:	83 ec 04             	sub    $0x4,%esp
  801dec:	68 07 04 00 00       	push   $0x407
  801df1:	ff 75 f4             	pushl  -0xc(%ebp)
  801df4:	6a 00                	push   $0x0
  801df6:	e8 fd ed ff ff       	call   800bf8 <sys_page_alloc>
  801dfb:	83 c4 10             	add    $0x10,%esp
		return r;
  801dfe:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e00:	85 c0                	test   %eax,%eax
  801e02:	78 23                	js     801e27 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e04:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e0d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e12:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e19:	83 ec 0c             	sub    $0xc,%esp
  801e1c:	50                   	push   %eax
  801e1d:	e8 1f f3 ff ff       	call   801141 <fd2num>
  801e22:	89 c2                	mov    %eax,%edx
  801e24:	83 c4 10             	add    $0x10,%esp
}
  801e27:	89 d0                	mov    %edx,%eax
  801e29:	c9                   	leave  
  801e2a:	c3                   	ret    

00801e2b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e2b:	55                   	push   %ebp
  801e2c:	89 e5                	mov    %esp,%ebp
  801e2e:	56                   	push   %esi
  801e2f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801e30:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e33:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801e39:	e8 7c ed ff ff       	call   800bba <sys_getenvid>
  801e3e:	83 ec 0c             	sub    $0xc,%esp
  801e41:	ff 75 0c             	pushl  0xc(%ebp)
  801e44:	ff 75 08             	pushl  0x8(%ebp)
  801e47:	56                   	push   %esi
  801e48:	50                   	push   %eax
  801e49:	68 bc 26 80 00       	push   $0x8026bc
  801e4e:	e8 9e e3 ff ff       	call   8001f1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801e53:	83 c4 18             	add    $0x18,%esp
  801e56:	53                   	push   %ebx
  801e57:	ff 75 10             	pushl  0x10(%ebp)
  801e5a:	e8 41 e3 ff ff       	call   8001a0 <vcprintf>
	cprintf("\n");
  801e5f:	c7 04 24 a7 26 80 00 	movl   $0x8026a7,(%esp)
  801e66:	e8 86 e3 ff ff       	call   8001f1 <cprintf>
  801e6b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801e6e:	cc                   	int3   
  801e6f:	eb fd                	jmp    801e6e <_panic+0x43>

00801e71 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e71:	55                   	push   %ebp
  801e72:	89 e5                	mov    %esp,%ebp
  801e74:	53                   	push   %ebx
  801e75:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801e78:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e7f:	75 28                	jne    801ea9 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		void *va = (void *) (UXSTACKTOP - PGSIZE);
		envid_t envid = sys_getenvid();
  801e81:	e8 34 ed ff ff       	call   800bba <sys_getenvid>
  801e86:	89 c3                	mov    %eax,%ebx

		sys_page_alloc(envid, va, PTE_P | PTE_U | PTE_W);
  801e88:	83 ec 04             	sub    $0x4,%esp
  801e8b:	6a 07                	push   $0x7
  801e8d:	68 00 f0 bf ee       	push   $0xeebff000
  801e92:	50                   	push   %eax
  801e93:	e8 60 ed ff ff       	call   800bf8 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801e98:	83 c4 08             	add    $0x8,%esp
  801e9b:	68 b6 1e 80 00       	push   $0x801eb6
  801ea0:	53                   	push   %ebx
  801ea1:	e8 9d ee ff ff       	call   800d43 <sys_env_set_pgfault_upcall>
  801ea6:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801ea9:	8b 45 08             	mov    0x8(%ebp),%eax
  801eac:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801eb1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801eb4:	c9                   	leave  
  801eb5:	c3                   	ret    

00801eb6 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp				// function argument: pointer to UTF
  801eb6:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801eb7:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801ebc:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801ebe:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp, %ebx		// 40 = size between utf_fault_va ~ utf_regs
  801ec1:	89 e3                	mov    %esp,%ebx
	movl 40(%esp), %eax // point to utf_eip
  801ec3:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %esp // point to utf_esp
  801ec7:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax 			// push eip of utf
  801ecb:	50                   	push   %eax

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx, %esp 	// back to origin exception stack
  801ecc:	89 dc                	mov    %ebx,%esp
	subl $4, 48(%esp) 	// utf_esp - 4
  801ece:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	popl %eax  			// pop utf_fault_va (ignore)
  801ed3:	58                   	pop    %eax
	popl %eax  			// pop utf_err (ignore)
  801ed4:	58                   	pop    %eax
	popal 				// pop utf_regs 
  801ed5:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4, %esp 		// ignore utf_eip
  801ed6:	83 c4 04             	add    $0x4,%esp
	popfl 				// restore utf_eflags to eflags
  801ed9:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp  			// restore %esp = utf_esp
  801eda:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801edb:	c3                   	ret    

00801edc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801edc:	55                   	push   %ebp
  801edd:	89 e5                	mov    %esp,%ebp
  801edf:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ee2:	89 d0                	mov    %edx,%eax
  801ee4:	c1 e8 16             	shr    $0x16,%eax
  801ee7:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801eee:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ef3:	f6 c1 01             	test   $0x1,%cl
  801ef6:	74 1d                	je     801f15 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ef8:	c1 ea 0c             	shr    $0xc,%edx
  801efb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f02:	f6 c2 01             	test   $0x1,%dl
  801f05:	74 0e                	je     801f15 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f07:	c1 ea 0c             	shr    $0xc,%edx
  801f0a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f11:	ef 
  801f12:	0f b7 c0             	movzwl %ax,%eax
}
  801f15:	5d                   	pop    %ebp
  801f16:	c3                   	ret    
  801f17:	66 90                	xchg   %ax,%ax
  801f19:	66 90                	xchg   %ax,%ax
  801f1b:	66 90                	xchg   %ax,%ax
  801f1d:	66 90                	xchg   %ax,%ax
  801f1f:	90                   	nop

00801f20 <__udivdi3>:
  801f20:	55                   	push   %ebp
  801f21:	57                   	push   %edi
  801f22:	56                   	push   %esi
  801f23:	53                   	push   %ebx
  801f24:	83 ec 1c             	sub    $0x1c,%esp
  801f27:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f2b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f2f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f37:	85 f6                	test   %esi,%esi
  801f39:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f3d:	89 ca                	mov    %ecx,%edx
  801f3f:	89 f8                	mov    %edi,%eax
  801f41:	75 3d                	jne    801f80 <__udivdi3+0x60>
  801f43:	39 cf                	cmp    %ecx,%edi
  801f45:	0f 87 c5 00 00 00    	ja     802010 <__udivdi3+0xf0>
  801f4b:	85 ff                	test   %edi,%edi
  801f4d:	89 fd                	mov    %edi,%ebp
  801f4f:	75 0b                	jne    801f5c <__udivdi3+0x3c>
  801f51:	b8 01 00 00 00       	mov    $0x1,%eax
  801f56:	31 d2                	xor    %edx,%edx
  801f58:	f7 f7                	div    %edi
  801f5a:	89 c5                	mov    %eax,%ebp
  801f5c:	89 c8                	mov    %ecx,%eax
  801f5e:	31 d2                	xor    %edx,%edx
  801f60:	f7 f5                	div    %ebp
  801f62:	89 c1                	mov    %eax,%ecx
  801f64:	89 d8                	mov    %ebx,%eax
  801f66:	89 cf                	mov    %ecx,%edi
  801f68:	f7 f5                	div    %ebp
  801f6a:	89 c3                	mov    %eax,%ebx
  801f6c:	89 d8                	mov    %ebx,%eax
  801f6e:	89 fa                	mov    %edi,%edx
  801f70:	83 c4 1c             	add    $0x1c,%esp
  801f73:	5b                   	pop    %ebx
  801f74:	5e                   	pop    %esi
  801f75:	5f                   	pop    %edi
  801f76:	5d                   	pop    %ebp
  801f77:	c3                   	ret    
  801f78:	90                   	nop
  801f79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f80:	39 ce                	cmp    %ecx,%esi
  801f82:	77 74                	ja     801ff8 <__udivdi3+0xd8>
  801f84:	0f bd fe             	bsr    %esi,%edi
  801f87:	83 f7 1f             	xor    $0x1f,%edi
  801f8a:	0f 84 98 00 00 00    	je     802028 <__udivdi3+0x108>
  801f90:	bb 20 00 00 00       	mov    $0x20,%ebx
  801f95:	89 f9                	mov    %edi,%ecx
  801f97:	89 c5                	mov    %eax,%ebp
  801f99:	29 fb                	sub    %edi,%ebx
  801f9b:	d3 e6                	shl    %cl,%esi
  801f9d:	89 d9                	mov    %ebx,%ecx
  801f9f:	d3 ed                	shr    %cl,%ebp
  801fa1:	89 f9                	mov    %edi,%ecx
  801fa3:	d3 e0                	shl    %cl,%eax
  801fa5:	09 ee                	or     %ebp,%esi
  801fa7:	89 d9                	mov    %ebx,%ecx
  801fa9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fad:	89 d5                	mov    %edx,%ebp
  801faf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801fb3:	d3 ed                	shr    %cl,%ebp
  801fb5:	89 f9                	mov    %edi,%ecx
  801fb7:	d3 e2                	shl    %cl,%edx
  801fb9:	89 d9                	mov    %ebx,%ecx
  801fbb:	d3 e8                	shr    %cl,%eax
  801fbd:	09 c2                	or     %eax,%edx
  801fbf:	89 d0                	mov    %edx,%eax
  801fc1:	89 ea                	mov    %ebp,%edx
  801fc3:	f7 f6                	div    %esi
  801fc5:	89 d5                	mov    %edx,%ebp
  801fc7:	89 c3                	mov    %eax,%ebx
  801fc9:	f7 64 24 0c          	mull   0xc(%esp)
  801fcd:	39 d5                	cmp    %edx,%ebp
  801fcf:	72 10                	jb     801fe1 <__udivdi3+0xc1>
  801fd1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801fd5:	89 f9                	mov    %edi,%ecx
  801fd7:	d3 e6                	shl    %cl,%esi
  801fd9:	39 c6                	cmp    %eax,%esi
  801fdb:	73 07                	jae    801fe4 <__udivdi3+0xc4>
  801fdd:	39 d5                	cmp    %edx,%ebp
  801fdf:	75 03                	jne    801fe4 <__udivdi3+0xc4>
  801fe1:	83 eb 01             	sub    $0x1,%ebx
  801fe4:	31 ff                	xor    %edi,%edi
  801fe6:	89 d8                	mov    %ebx,%eax
  801fe8:	89 fa                	mov    %edi,%edx
  801fea:	83 c4 1c             	add    $0x1c,%esp
  801fed:	5b                   	pop    %ebx
  801fee:	5e                   	pop    %esi
  801fef:	5f                   	pop    %edi
  801ff0:	5d                   	pop    %ebp
  801ff1:	c3                   	ret    
  801ff2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ff8:	31 ff                	xor    %edi,%edi
  801ffa:	31 db                	xor    %ebx,%ebx
  801ffc:	89 d8                	mov    %ebx,%eax
  801ffe:	89 fa                	mov    %edi,%edx
  802000:	83 c4 1c             	add    $0x1c,%esp
  802003:	5b                   	pop    %ebx
  802004:	5e                   	pop    %esi
  802005:	5f                   	pop    %edi
  802006:	5d                   	pop    %ebp
  802007:	c3                   	ret    
  802008:	90                   	nop
  802009:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802010:	89 d8                	mov    %ebx,%eax
  802012:	f7 f7                	div    %edi
  802014:	31 ff                	xor    %edi,%edi
  802016:	89 c3                	mov    %eax,%ebx
  802018:	89 d8                	mov    %ebx,%eax
  80201a:	89 fa                	mov    %edi,%edx
  80201c:	83 c4 1c             	add    $0x1c,%esp
  80201f:	5b                   	pop    %ebx
  802020:	5e                   	pop    %esi
  802021:	5f                   	pop    %edi
  802022:	5d                   	pop    %ebp
  802023:	c3                   	ret    
  802024:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802028:	39 ce                	cmp    %ecx,%esi
  80202a:	72 0c                	jb     802038 <__udivdi3+0x118>
  80202c:	31 db                	xor    %ebx,%ebx
  80202e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802032:	0f 87 34 ff ff ff    	ja     801f6c <__udivdi3+0x4c>
  802038:	bb 01 00 00 00       	mov    $0x1,%ebx
  80203d:	e9 2a ff ff ff       	jmp    801f6c <__udivdi3+0x4c>
  802042:	66 90                	xchg   %ax,%ax
  802044:	66 90                	xchg   %ax,%ax
  802046:	66 90                	xchg   %ax,%ax
  802048:	66 90                	xchg   %ax,%ax
  80204a:	66 90                	xchg   %ax,%ax
  80204c:	66 90                	xchg   %ax,%ax
  80204e:	66 90                	xchg   %ax,%ax

00802050 <__umoddi3>:
  802050:	55                   	push   %ebp
  802051:	57                   	push   %edi
  802052:	56                   	push   %esi
  802053:	53                   	push   %ebx
  802054:	83 ec 1c             	sub    $0x1c,%esp
  802057:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80205b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80205f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802063:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802067:	85 d2                	test   %edx,%edx
  802069:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80206d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802071:	89 f3                	mov    %esi,%ebx
  802073:	89 3c 24             	mov    %edi,(%esp)
  802076:	89 74 24 04          	mov    %esi,0x4(%esp)
  80207a:	75 1c                	jne    802098 <__umoddi3+0x48>
  80207c:	39 f7                	cmp    %esi,%edi
  80207e:	76 50                	jbe    8020d0 <__umoddi3+0x80>
  802080:	89 c8                	mov    %ecx,%eax
  802082:	89 f2                	mov    %esi,%edx
  802084:	f7 f7                	div    %edi
  802086:	89 d0                	mov    %edx,%eax
  802088:	31 d2                	xor    %edx,%edx
  80208a:	83 c4 1c             	add    $0x1c,%esp
  80208d:	5b                   	pop    %ebx
  80208e:	5e                   	pop    %esi
  80208f:	5f                   	pop    %edi
  802090:	5d                   	pop    %ebp
  802091:	c3                   	ret    
  802092:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802098:	39 f2                	cmp    %esi,%edx
  80209a:	89 d0                	mov    %edx,%eax
  80209c:	77 52                	ja     8020f0 <__umoddi3+0xa0>
  80209e:	0f bd ea             	bsr    %edx,%ebp
  8020a1:	83 f5 1f             	xor    $0x1f,%ebp
  8020a4:	75 5a                	jne    802100 <__umoddi3+0xb0>
  8020a6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8020aa:	0f 82 e0 00 00 00    	jb     802190 <__umoddi3+0x140>
  8020b0:	39 0c 24             	cmp    %ecx,(%esp)
  8020b3:	0f 86 d7 00 00 00    	jbe    802190 <__umoddi3+0x140>
  8020b9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020bd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8020c1:	83 c4 1c             	add    $0x1c,%esp
  8020c4:	5b                   	pop    %ebx
  8020c5:	5e                   	pop    %esi
  8020c6:	5f                   	pop    %edi
  8020c7:	5d                   	pop    %ebp
  8020c8:	c3                   	ret    
  8020c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020d0:	85 ff                	test   %edi,%edi
  8020d2:	89 fd                	mov    %edi,%ebp
  8020d4:	75 0b                	jne    8020e1 <__umoddi3+0x91>
  8020d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8020db:	31 d2                	xor    %edx,%edx
  8020dd:	f7 f7                	div    %edi
  8020df:	89 c5                	mov    %eax,%ebp
  8020e1:	89 f0                	mov    %esi,%eax
  8020e3:	31 d2                	xor    %edx,%edx
  8020e5:	f7 f5                	div    %ebp
  8020e7:	89 c8                	mov    %ecx,%eax
  8020e9:	f7 f5                	div    %ebp
  8020eb:	89 d0                	mov    %edx,%eax
  8020ed:	eb 99                	jmp    802088 <__umoddi3+0x38>
  8020ef:	90                   	nop
  8020f0:	89 c8                	mov    %ecx,%eax
  8020f2:	89 f2                	mov    %esi,%edx
  8020f4:	83 c4 1c             	add    $0x1c,%esp
  8020f7:	5b                   	pop    %ebx
  8020f8:	5e                   	pop    %esi
  8020f9:	5f                   	pop    %edi
  8020fa:	5d                   	pop    %ebp
  8020fb:	c3                   	ret    
  8020fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802100:	8b 34 24             	mov    (%esp),%esi
  802103:	bf 20 00 00 00       	mov    $0x20,%edi
  802108:	89 e9                	mov    %ebp,%ecx
  80210a:	29 ef                	sub    %ebp,%edi
  80210c:	d3 e0                	shl    %cl,%eax
  80210e:	89 f9                	mov    %edi,%ecx
  802110:	89 f2                	mov    %esi,%edx
  802112:	d3 ea                	shr    %cl,%edx
  802114:	89 e9                	mov    %ebp,%ecx
  802116:	09 c2                	or     %eax,%edx
  802118:	89 d8                	mov    %ebx,%eax
  80211a:	89 14 24             	mov    %edx,(%esp)
  80211d:	89 f2                	mov    %esi,%edx
  80211f:	d3 e2                	shl    %cl,%edx
  802121:	89 f9                	mov    %edi,%ecx
  802123:	89 54 24 04          	mov    %edx,0x4(%esp)
  802127:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80212b:	d3 e8                	shr    %cl,%eax
  80212d:	89 e9                	mov    %ebp,%ecx
  80212f:	89 c6                	mov    %eax,%esi
  802131:	d3 e3                	shl    %cl,%ebx
  802133:	89 f9                	mov    %edi,%ecx
  802135:	89 d0                	mov    %edx,%eax
  802137:	d3 e8                	shr    %cl,%eax
  802139:	89 e9                	mov    %ebp,%ecx
  80213b:	09 d8                	or     %ebx,%eax
  80213d:	89 d3                	mov    %edx,%ebx
  80213f:	89 f2                	mov    %esi,%edx
  802141:	f7 34 24             	divl   (%esp)
  802144:	89 d6                	mov    %edx,%esi
  802146:	d3 e3                	shl    %cl,%ebx
  802148:	f7 64 24 04          	mull   0x4(%esp)
  80214c:	39 d6                	cmp    %edx,%esi
  80214e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802152:	89 d1                	mov    %edx,%ecx
  802154:	89 c3                	mov    %eax,%ebx
  802156:	72 08                	jb     802160 <__umoddi3+0x110>
  802158:	75 11                	jne    80216b <__umoddi3+0x11b>
  80215a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80215e:	73 0b                	jae    80216b <__umoddi3+0x11b>
  802160:	2b 44 24 04          	sub    0x4(%esp),%eax
  802164:	1b 14 24             	sbb    (%esp),%edx
  802167:	89 d1                	mov    %edx,%ecx
  802169:	89 c3                	mov    %eax,%ebx
  80216b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80216f:	29 da                	sub    %ebx,%edx
  802171:	19 ce                	sbb    %ecx,%esi
  802173:	89 f9                	mov    %edi,%ecx
  802175:	89 f0                	mov    %esi,%eax
  802177:	d3 e0                	shl    %cl,%eax
  802179:	89 e9                	mov    %ebp,%ecx
  80217b:	d3 ea                	shr    %cl,%edx
  80217d:	89 e9                	mov    %ebp,%ecx
  80217f:	d3 ee                	shr    %cl,%esi
  802181:	09 d0                	or     %edx,%eax
  802183:	89 f2                	mov    %esi,%edx
  802185:	83 c4 1c             	add    $0x1c,%esp
  802188:	5b                   	pop    %ebx
  802189:	5e                   	pop    %esi
  80218a:	5f                   	pop    %edi
  80218b:	5d                   	pop    %ebp
  80218c:	c3                   	ret    
  80218d:	8d 76 00             	lea    0x0(%esi),%esi
  802190:	29 f9                	sub    %edi,%ecx
  802192:	19 d6                	sbb    %edx,%esi
  802194:	89 74 24 04          	mov    %esi,0x4(%esp)
  802198:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80219c:	e9 18 ff ff ff       	jmp    8020b9 <__umoddi3+0x69>
