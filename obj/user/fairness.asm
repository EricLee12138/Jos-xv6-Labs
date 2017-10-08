
obj/user/fairness.debug：     文件格式 elf32-i386


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
  80002c:	e8 70 00 00 00       	call   8000a1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 10             	sub    $0x10,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003b:	e8 1d 0b 00 00       	call   800b5d <sys_getenvid>
  800040:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800042:	81 3d 04 40 80 00 7c 	cmpl   $0xeec0007c,0x804004
  800049:	00 c0 ee 
  80004c:	75 26                	jne    800074 <umain+0x41>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004e:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800051:	83 ec 04             	sub    $0x4,%esp
  800054:	6a 00                	push   $0x0
  800056:	6a 00                	push   $0x0
  800058:	56                   	push   %esi
  800059:	e8 2e 0d 00 00       	call   800d8c <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80005e:	83 c4 0c             	add    $0xc,%esp
  800061:	ff 75 f4             	pushl  -0xc(%ebp)
  800064:	53                   	push   %ebx
  800065:	68 a0 1e 80 00       	push   $0x801ea0
  80006a:	e8 25 01 00 00       	call   800194 <cprintf>
  80006f:	83 c4 10             	add    $0x10,%esp
  800072:	eb dd                	jmp    800051 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800074:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800079:	83 ec 04             	sub    $0x4,%esp
  80007c:	50                   	push   %eax
  80007d:	53                   	push   %ebx
  80007e:	68 b1 1e 80 00       	push   $0x801eb1
  800083:	e8 0c 01 00 00       	call   800194 <cprintf>
  800088:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80008b:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800090:	6a 00                	push   $0x0
  800092:	6a 00                	push   $0x0
  800094:	6a 00                	push   $0x0
  800096:	50                   	push   %eax
  800097:	e8 62 0d 00 00       	call   800dfe <ipc_send>
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	eb ea                	jmp    80008b <umain+0x58>

008000a1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a1:	55                   	push   %ebp
  8000a2:	89 e5                	mov    %esp,%ebp
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
  8000a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000ac:	e8 ac 0a 00 00       	call   800b5d <sys_getenvid>
  8000b1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000be:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c3:	85 db                	test   %ebx,%ebx
  8000c5:	7e 07                	jle    8000ce <libmain+0x2d>
		binaryname = argv[0];
  8000c7:	8b 06                	mov    (%esi),%eax
  8000c9:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ce:	83 ec 08             	sub    $0x8,%esp
  8000d1:	56                   	push   %esi
  8000d2:	53                   	push   %ebx
  8000d3:	e8 5b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d8:	e8 0a 00 00 00       	call   8000e7 <exit>
}
  8000dd:	83 c4 10             	add    $0x10,%esp
  8000e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e3:	5b                   	pop    %ebx
  8000e4:	5e                   	pop    %esi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000ed:	e8 64 0f 00 00       	call   801056 <close_all>
	sys_env_destroy(0);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	6a 00                	push   $0x0
  8000f7:	e8 20 0a 00 00       	call   800b1c <sys_env_destroy>
}
  8000fc:	83 c4 10             	add    $0x10,%esp
  8000ff:	c9                   	leave  
  800100:	c3                   	ret    

00800101 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800101:	55                   	push   %ebp
  800102:	89 e5                	mov    %esp,%ebp
  800104:	53                   	push   %ebx
  800105:	83 ec 04             	sub    $0x4,%esp
  800108:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80010b:	8b 13                	mov    (%ebx),%edx
  80010d:	8d 42 01             	lea    0x1(%edx),%eax
  800110:	89 03                	mov    %eax,(%ebx)
  800112:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800115:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800119:	3d ff 00 00 00       	cmp    $0xff,%eax
  80011e:	75 1a                	jne    80013a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800120:	83 ec 08             	sub    $0x8,%esp
  800123:	68 ff 00 00 00       	push   $0xff
  800128:	8d 43 08             	lea    0x8(%ebx),%eax
  80012b:	50                   	push   %eax
  80012c:	e8 ae 09 00 00       	call   800adf <sys_cputs>
		b->idx = 0;
  800131:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800137:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80013a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80013e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800141:	c9                   	leave  
  800142:	c3                   	ret    

00800143 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80014c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800153:	00 00 00 
	b.cnt = 0;
  800156:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80015d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800160:	ff 75 0c             	pushl  0xc(%ebp)
  800163:	ff 75 08             	pushl  0x8(%ebp)
  800166:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80016c:	50                   	push   %eax
  80016d:	68 01 01 80 00       	push   $0x800101
  800172:	e8 1a 01 00 00       	call   800291 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800177:	83 c4 08             	add    $0x8,%esp
  80017a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800180:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800186:	50                   	push   %eax
  800187:	e8 53 09 00 00       	call   800adf <sys_cputs>

	return b.cnt;
}
  80018c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800192:	c9                   	leave  
  800193:	c3                   	ret    

00800194 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80019a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80019d:	50                   	push   %eax
  80019e:	ff 75 08             	pushl  0x8(%ebp)
  8001a1:	e8 9d ff ff ff       	call   800143 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    

008001a8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	57                   	push   %edi
  8001ac:	56                   	push   %esi
  8001ad:	53                   	push   %ebx
  8001ae:	83 ec 1c             	sub    $0x1c,%esp
  8001b1:	89 c7                	mov    %eax,%edi
  8001b3:	89 d6                	mov    %edx,%esi
  8001b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001be:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001c9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001cc:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001cf:	39 d3                	cmp    %edx,%ebx
  8001d1:	72 05                	jb     8001d8 <printnum+0x30>
  8001d3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001d6:	77 45                	ja     80021d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d8:	83 ec 0c             	sub    $0xc,%esp
  8001db:	ff 75 18             	pushl  0x18(%ebp)
  8001de:	8b 45 14             	mov    0x14(%ebp),%eax
  8001e1:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001e4:	53                   	push   %ebx
  8001e5:	ff 75 10             	pushl  0x10(%ebp)
  8001e8:	83 ec 08             	sub    $0x8,%esp
  8001eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f1:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f4:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f7:	e8 04 1a 00 00       	call   801c00 <__udivdi3>
  8001fc:	83 c4 18             	add    $0x18,%esp
  8001ff:	52                   	push   %edx
  800200:	50                   	push   %eax
  800201:	89 f2                	mov    %esi,%edx
  800203:	89 f8                	mov    %edi,%eax
  800205:	e8 9e ff ff ff       	call   8001a8 <printnum>
  80020a:	83 c4 20             	add    $0x20,%esp
  80020d:	eb 18                	jmp    800227 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80020f:	83 ec 08             	sub    $0x8,%esp
  800212:	56                   	push   %esi
  800213:	ff 75 18             	pushl  0x18(%ebp)
  800216:	ff d7                	call   *%edi
  800218:	83 c4 10             	add    $0x10,%esp
  80021b:	eb 03                	jmp    800220 <printnum+0x78>
  80021d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800220:	83 eb 01             	sub    $0x1,%ebx
  800223:	85 db                	test   %ebx,%ebx
  800225:	7f e8                	jg     80020f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800227:	83 ec 08             	sub    $0x8,%esp
  80022a:	56                   	push   %esi
  80022b:	83 ec 04             	sub    $0x4,%esp
  80022e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800231:	ff 75 e0             	pushl  -0x20(%ebp)
  800234:	ff 75 dc             	pushl  -0x24(%ebp)
  800237:	ff 75 d8             	pushl  -0x28(%ebp)
  80023a:	e8 f1 1a 00 00       	call   801d30 <__umoddi3>
  80023f:	83 c4 14             	add    $0x14,%esp
  800242:	0f be 80 d2 1e 80 00 	movsbl 0x801ed2(%eax),%eax
  800249:	50                   	push   %eax
  80024a:	ff d7                	call   *%edi
}
  80024c:	83 c4 10             	add    $0x10,%esp
  80024f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800252:	5b                   	pop    %ebx
  800253:	5e                   	pop    %esi
  800254:	5f                   	pop    %edi
  800255:	5d                   	pop    %ebp
  800256:	c3                   	ret    

00800257 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
  80025a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80025d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800261:	8b 10                	mov    (%eax),%edx
  800263:	3b 50 04             	cmp    0x4(%eax),%edx
  800266:	73 0a                	jae    800272 <sprintputch+0x1b>
		*b->buf++ = ch;
  800268:	8d 4a 01             	lea    0x1(%edx),%ecx
  80026b:	89 08                	mov    %ecx,(%eax)
  80026d:	8b 45 08             	mov    0x8(%ebp),%eax
  800270:	88 02                	mov    %al,(%edx)
}
  800272:	5d                   	pop    %ebp
  800273:	c3                   	ret    

00800274 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80027a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80027d:	50                   	push   %eax
  80027e:	ff 75 10             	pushl  0x10(%ebp)
  800281:	ff 75 0c             	pushl  0xc(%ebp)
  800284:	ff 75 08             	pushl  0x8(%ebp)
  800287:	e8 05 00 00 00       	call   800291 <vprintfmt>
	va_end(ap);
}
  80028c:	83 c4 10             	add    $0x10,%esp
  80028f:	c9                   	leave  
  800290:	c3                   	ret    

00800291 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
  800294:	57                   	push   %edi
  800295:	56                   	push   %esi
  800296:	53                   	push   %ebx
  800297:	83 ec 2c             	sub    $0x2c,%esp
  80029a:	8b 75 08             	mov    0x8(%ebp),%esi
  80029d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002a0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002a3:	eb 12                	jmp    8002b7 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002a5:	85 c0                	test   %eax,%eax
  8002a7:	0f 84 42 04 00 00    	je     8006ef <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8002ad:	83 ec 08             	sub    $0x8,%esp
  8002b0:	53                   	push   %ebx
  8002b1:	50                   	push   %eax
  8002b2:	ff d6                	call   *%esi
  8002b4:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002b7:	83 c7 01             	add    $0x1,%edi
  8002ba:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002be:	83 f8 25             	cmp    $0x25,%eax
  8002c1:	75 e2                	jne    8002a5 <vprintfmt+0x14>
  8002c3:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002c7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002ce:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002d5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002dc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002e1:	eb 07                	jmp    8002ea <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002e6:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002ea:	8d 47 01             	lea    0x1(%edi),%eax
  8002ed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002f0:	0f b6 07             	movzbl (%edi),%eax
  8002f3:	0f b6 d0             	movzbl %al,%edx
  8002f6:	83 e8 23             	sub    $0x23,%eax
  8002f9:	3c 55                	cmp    $0x55,%al
  8002fb:	0f 87 d3 03 00 00    	ja     8006d4 <vprintfmt+0x443>
  800301:	0f b6 c0             	movzbl %al,%eax
  800304:	ff 24 85 20 20 80 00 	jmp    *0x802020(,%eax,4)
  80030b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80030e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800312:	eb d6                	jmp    8002ea <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800314:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800317:	b8 00 00 00 00       	mov    $0x0,%eax
  80031c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80031f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800322:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800326:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800329:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80032c:	83 f9 09             	cmp    $0x9,%ecx
  80032f:	77 3f                	ja     800370 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800331:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800334:	eb e9                	jmp    80031f <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800336:	8b 45 14             	mov    0x14(%ebp),%eax
  800339:	8b 00                	mov    (%eax),%eax
  80033b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80033e:	8b 45 14             	mov    0x14(%ebp),%eax
  800341:	8d 40 04             	lea    0x4(%eax),%eax
  800344:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800347:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80034a:	eb 2a                	jmp    800376 <vprintfmt+0xe5>
  80034c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80034f:	85 c0                	test   %eax,%eax
  800351:	ba 00 00 00 00       	mov    $0x0,%edx
  800356:	0f 49 d0             	cmovns %eax,%edx
  800359:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80035f:	eb 89                	jmp    8002ea <vprintfmt+0x59>
  800361:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800364:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80036b:	e9 7a ff ff ff       	jmp    8002ea <vprintfmt+0x59>
  800370:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800373:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800376:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80037a:	0f 89 6a ff ff ff    	jns    8002ea <vprintfmt+0x59>
				width = precision, precision = -1;
  800380:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800383:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800386:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80038d:	e9 58 ff ff ff       	jmp    8002ea <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800392:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800395:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800398:	e9 4d ff ff ff       	jmp    8002ea <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80039d:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a0:	8d 78 04             	lea    0x4(%eax),%edi
  8003a3:	83 ec 08             	sub    $0x8,%esp
  8003a6:	53                   	push   %ebx
  8003a7:	ff 30                	pushl  (%eax)
  8003a9:	ff d6                	call   *%esi
			break;
  8003ab:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ae:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003b4:	e9 fe fe ff ff       	jmp    8002b7 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bc:	8d 78 04             	lea    0x4(%eax),%edi
  8003bf:	8b 00                	mov    (%eax),%eax
  8003c1:	99                   	cltd   
  8003c2:	31 d0                	xor    %edx,%eax
  8003c4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003c6:	83 f8 0f             	cmp    $0xf,%eax
  8003c9:	7f 0b                	jg     8003d6 <vprintfmt+0x145>
  8003cb:	8b 14 85 80 21 80 00 	mov    0x802180(,%eax,4),%edx
  8003d2:	85 d2                	test   %edx,%edx
  8003d4:	75 1b                	jne    8003f1 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8003d6:	50                   	push   %eax
  8003d7:	68 ea 1e 80 00       	push   $0x801eea
  8003dc:	53                   	push   %ebx
  8003dd:	56                   	push   %esi
  8003de:	e8 91 fe ff ff       	call   800274 <printfmt>
  8003e3:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003e6:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003ec:	e9 c6 fe ff ff       	jmp    8002b7 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003f1:	52                   	push   %edx
  8003f2:	68 cd 22 80 00       	push   $0x8022cd
  8003f7:	53                   	push   %ebx
  8003f8:	56                   	push   %esi
  8003f9:	e8 76 fe ff ff       	call   800274 <printfmt>
  8003fe:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800401:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800404:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800407:	e9 ab fe ff ff       	jmp    8002b7 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80040c:	8b 45 14             	mov    0x14(%ebp),%eax
  80040f:	83 c0 04             	add    $0x4,%eax
  800412:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800415:	8b 45 14             	mov    0x14(%ebp),%eax
  800418:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80041a:	85 ff                	test   %edi,%edi
  80041c:	b8 e3 1e 80 00       	mov    $0x801ee3,%eax
  800421:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800424:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800428:	0f 8e 94 00 00 00    	jle    8004c2 <vprintfmt+0x231>
  80042e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800432:	0f 84 98 00 00 00    	je     8004d0 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800438:	83 ec 08             	sub    $0x8,%esp
  80043b:	ff 75 d0             	pushl  -0x30(%ebp)
  80043e:	57                   	push   %edi
  80043f:	e8 33 03 00 00       	call   800777 <strnlen>
  800444:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800447:	29 c1                	sub    %eax,%ecx
  800449:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80044c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80044f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800453:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800456:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800459:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80045b:	eb 0f                	jmp    80046c <vprintfmt+0x1db>
					putch(padc, putdat);
  80045d:	83 ec 08             	sub    $0x8,%esp
  800460:	53                   	push   %ebx
  800461:	ff 75 e0             	pushl  -0x20(%ebp)
  800464:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800466:	83 ef 01             	sub    $0x1,%edi
  800469:	83 c4 10             	add    $0x10,%esp
  80046c:	85 ff                	test   %edi,%edi
  80046e:	7f ed                	jg     80045d <vprintfmt+0x1cc>
  800470:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800473:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800476:	85 c9                	test   %ecx,%ecx
  800478:	b8 00 00 00 00       	mov    $0x0,%eax
  80047d:	0f 49 c1             	cmovns %ecx,%eax
  800480:	29 c1                	sub    %eax,%ecx
  800482:	89 75 08             	mov    %esi,0x8(%ebp)
  800485:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800488:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80048b:	89 cb                	mov    %ecx,%ebx
  80048d:	eb 4d                	jmp    8004dc <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80048f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800493:	74 1b                	je     8004b0 <vprintfmt+0x21f>
  800495:	0f be c0             	movsbl %al,%eax
  800498:	83 e8 20             	sub    $0x20,%eax
  80049b:	83 f8 5e             	cmp    $0x5e,%eax
  80049e:	76 10                	jbe    8004b0 <vprintfmt+0x21f>
					putch('?', putdat);
  8004a0:	83 ec 08             	sub    $0x8,%esp
  8004a3:	ff 75 0c             	pushl  0xc(%ebp)
  8004a6:	6a 3f                	push   $0x3f
  8004a8:	ff 55 08             	call   *0x8(%ebp)
  8004ab:	83 c4 10             	add    $0x10,%esp
  8004ae:	eb 0d                	jmp    8004bd <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8004b0:	83 ec 08             	sub    $0x8,%esp
  8004b3:	ff 75 0c             	pushl  0xc(%ebp)
  8004b6:	52                   	push   %edx
  8004b7:	ff 55 08             	call   *0x8(%ebp)
  8004ba:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004bd:	83 eb 01             	sub    $0x1,%ebx
  8004c0:	eb 1a                	jmp    8004dc <vprintfmt+0x24b>
  8004c2:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004c8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004cb:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004ce:	eb 0c                	jmp    8004dc <vprintfmt+0x24b>
  8004d0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004dc:	83 c7 01             	add    $0x1,%edi
  8004df:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004e3:	0f be d0             	movsbl %al,%edx
  8004e6:	85 d2                	test   %edx,%edx
  8004e8:	74 23                	je     80050d <vprintfmt+0x27c>
  8004ea:	85 f6                	test   %esi,%esi
  8004ec:	78 a1                	js     80048f <vprintfmt+0x1fe>
  8004ee:	83 ee 01             	sub    $0x1,%esi
  8004f1:	79 9c                	jns    80048f <vprintfmt+0x1fe>
  8004f3:	89 df                	mov    %ebx,%edi
  8004f5:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004fb:	eb 18                	jmp    800515 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004fd:	83 ec 08             	sub    $0x8,%esp
  800500:	53                   	push   %ebx
  800501:	6a 20                	push   $0x20
  800503:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800505:	83 ef 01             	sub    $0x1,%edi
  800508:	83 c4 10             	add    $0x10,%esp
  80050b:	eb 08                	jmp    800515 <vprintfmt+0x284>
  80050d:	89 df                	mov    %ebx,%edi
  80050f:	8b 75 08             	mov    0x8(%ebp),%esi
  800512:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800515:	85 ff                	test   %edi,%edi
  800517:	7f e4                	jg     8004fd <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800519:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80051c:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800522:	e9 90 fd ff ff       	jmp    8002b7 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800527:	83 f9 01             	cmp    $0x1,%ecx
  80052a:	7e 19                	jle    800545 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  80052c:	8b 45 14             	mov    0x14(%ebp),%eax
  80052f:	8b 50 04             	mov    0x4(%eax),%edx
  800532:	8b 00                	mov    (%eax),%eax
  800534:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800537:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80053a:	8b 45 14             	mov    0x14(%ebp),%eax
  80053d:	8d 40 08             	lea    0x8(%eax),%eax
  800540:	89 45 14             	mov    %eax,0x14(%ebp)
  800543:	eb 38                	jmp    80057d <vprintfmt+0x2ec>
	else if (lflag)
  800545:	85 c9                	test   %ecx,%ecx
  800547:	74 1b                	je     800564 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800549:	8b 45 14             	mov    0x14(%ebp),%eax
  80054c:	8b 00                	mov    (%eax),%eax
  80054e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800551:	89 c1                	mov    %eax,%ecx
  800553:	c1 f9 1f             	sar    $0x1f,%ecx
  800556:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800559:	8b 45 14             	mov    0x14(%ebp),%eax
  80055c:	8d 40 04             	lea    0x4(%eax),%eax
  80055f:	89 45 14             	mov    %eax,0x14(%ebp)
  800562:	eb 19                	jmp    80057d <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800564:	8b 45 14             	mov    0x14(%ebp),%eax
  800567:	8b 00                	mov    (%eax),%eax
  800569:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80056c:	89 c1                	mov    %eax,%ecx
  80056e:	c1 f9 1f             	sar    $0x1f,%ecx
  800571:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800574:	8b 45 14             	mov    0x14(%ebp),%eax
  800577:	8d 40 04             	lea    0x4(%eax),%eax
  80057a:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80057d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800580:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800583:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800588:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80058c:	0f 89 0e 01 00 00    	jns    8006a0 <vprintfmt+0x40f>
				putch('-', putdat);
  800592:	83 ec 08             	sub    $0x8,%esp
  800595:	53                   	push   %ebx
  800596:	6a 2d                	push   $0x2d
  800598:	ff d6                	call   *%esi
				num = -(long long) num;
  80059a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80059d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005a0:	f7 da                	neg    %edx
  8005a2:	83 d1 00             	adc    $0x0,%ecx
  8005a5:	f7 d9                	neg    %ecx
  8005a7:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005aa:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005af:	e9 ec 00 00 00       	jmp    8006a0 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005b4:	83 f9 01             	cmp    $0x1,%ecx
  8005b7:	7e 18                	jle    8005d1 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8005b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bc:	8b 10                	mov    (%eax),%edx
  8005be:	8b 48 04             	mov    0x4(%eax),%ecx
  8005c1:	8d 40 08             	lea    0x8(%eax),%eax
  8005c4:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005c7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005cc:	e9 cf 00 00 00       	jmp    8006a0 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8005d1:	85 c9                	test   %ecx,%ecx
  8005d3:	74 1a                	je     8005ef <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8005d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d8:	8b 10                	mov    (%eax),%edx
  8005da:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005df:	8d 40 04             	lea    0x4(%eax),%eax
  8005e2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005e5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ea:	e9 b1 00 00 00       	jmp    8006a0 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f2:	8b 10                	mov    (%eax),%edx
  8005f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f9:	8d 40 04             	lea    0x4(%eax),%eax
  8005fc:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005ff:	b8 0a 00 00 00       	mov    $0xa,%eax
  800604:	e9 97 00 00 00       	jmp    8006a0 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800609:	83 ec 08             	sub    $0x8,%esp
  80060c:	53                   	push   %ebx
  80060d:	6a 58                	push   $0x58
  80060f:	ff d6                	call   *%esi
			putch('X', putdat);
  800611:	83 c4 08             	add    $0x8,%esp
  800614:	53                   	push   %ebx
  800615:	6a 58                	push   $0x58
  800617:	ff d6                	call   *%esi
			putch('X', putdat);
  800619:	83 c4 08             	add    $0x8,%esp
  80061c:	53                   	push   %ebx
  80061d:	6a 58                	push   $0x58
  80061f:	ff d6                	call   *%esi
			break;
  800621:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800624:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800627:	e9 8b fc ff ff       	jmp    8002b7 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  80062c:	83 ec 08             	sub    $0x8,%esp
  80062f:	53                   	push   %ebx
  800630:	6a 30                	push   $0x30
  800632:	ff d6                	call   *%esi
			putch('x', putdat);
  800634:	83 c4 08             	add    $0x8,%esp
  800637:	53                   	push   %ebx
  800638:	6a 78                	push   $0x78
  80063a:	ff d6                	call   *%esi
			num = (unsigned long long)
  80063c:	8b 45 14             	mov    0x14(%ebp),%eax
  80063f:	8b 10                	mov    (%eax),%edx
  800641:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800646:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800649:	8d 40 04             	lea    0x4(%eax),%eax
  80064c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80064f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800654:	eb 4a                	jmp    8006a0 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800656:	83 f9 01             	cmp    $0x1,%ecx
  800659:	7e 15                	jle    800670 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  80065b:	8b 45 14             	mov    0x14(%ebp),%eax
  80065e:	8b 10                	mov    (%eax),%edx
  800660:	8b 48 04             	mov    0x4(%eax),%ecx
  800663:	8d 40 08             	lea    0x8(%eax),%eax
  800666:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800669:	b8 10 00 00 00       	mov    $0x10,%eax
  80066e:	eb 30                	jmp    8006a0 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800670:	85 c9                	test   %ecx,%ecx
  800672:	74 17                	je     80068b <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800674:	8b 45 14             	mov    0x14(%ebp),%eax
  800677:	8b 10                	mov    (%eax),%edx
  800679:	b9 00 00 00 00       	mov    $0x0,%ecx
  80067e:	8d 40 04             	lea    0x4(%eax),%eax
  800681:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800684:	b8 10 00 00 00       	mov    $0x10,%eax
  800689:	eb 15                	jmp    8006a0 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80068b:	8b 45 14             	mov    0x14(%ebp),%eax
  80068e:	8b 10                	mov    (%eax),%edx
  800690:	b9 00 00 00 00       	mov    $0x0,%ecx
  800695:	8d 40 04             	lea    0x4(%eax),%eax
  800698:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80069b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006a0:	83 ec 0c             	sub    $0xc,%esp
  8006a3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006a7:	57                   	push   %edi
  8006a8:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ab:	50                   	push   %eax
  8006ac:	51                   	push   %ecx
  8006ad:	52                   	push   %edx
  8006ae:	89 da                	mov    %ebx,%edx
  8006b0:	89 f0                	mov    %esi,%eax
  8006b2:	e8 f1 fa ff ff       	call   8001a8 <printnum>
			break;
  8006b7:	83 c4 20             	add    $0x20,%esp
  8006ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006bd:	e9 f5 fb ff ff       	jmp    8002b7 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006c2:	83 ec 08             	sub    $0x8,%esp
  8006c5:	53                   	push   %ebx
  8006c6:	52                   	push   %edx
  8006c7:	ff d6                	call   *%esi
			break;
  8006c9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006cf:	e9 e3 fb ff ff       	jmp    8002b7 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006d4:	83 ec 08             	sub    $0x8,%esp
  8006d7:	53                   	push   %ebx
  8006d8:	6a 25                	push   $0x25
  8006da:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006dc:	83 c4 10             	add    $0x10,%esp
  8006df:	eb 03                	jmp    8006e4 <vprintfmt+0x453>
  8006e1:	83 ef 01             	sub    $0x1,%edi
  8006e4:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006e8:	75 f7                	jne    8006e1 <vprintfmt+0x450>
  8006ea:	e9 c8 fb ff ff       	jmp    8002b7 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f2:	5b                   	pop    %ebx
  8006f3:	5e                   	pop    %esi
  8006f4:	5f                   	pop    %edi
  8006f5:	5d                   	pop    %ebp
  8006f6:	c3                   	ret    

008006f7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f7:	55                   	push   %ebp
  8006f8:	89 e5                	mov    %esp,%ebp
  8006fa:	83 ec 18             	sub    $0x18,%esp
  8006fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800700:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800703:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800706:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80070a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80070d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800714:	85 c0                	test   %eax,%eax
  800716:	74 26                	je     80073e <vsnprintf+0x47>
  800718:	85 d2                	test   %edx,%edx
  80071a:	7e 22                	jle    80073e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80071c:	ff 75 14             	pushl  0x14(%ebp)
  80071f:	ff 75 10             	pushl  0x10(%ebp)
  800722:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800725:	50                   	push   %eax
  800726:	68 57 02 80 00       	push   $0x800257
  80072b:	e8 61 fb ff ff       	call   800291 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800730:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800733:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800736:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800739:	83 c4 10             	add    $0x10,%esp
  80073c:	eb 05                	jmp    800743 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80073e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800743:	c9                   	leave  
  800744:	c3                   	ret    

00800745 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800745:	55                   	push   %ebp
  800746:	89 e5                	mov    %esp,%ebp
  800748:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80074b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80074e:	50                   	push   %eax
  80074f:	ff 75 10             	pushl  0x10(%ebp)
  800752:	ff 75 0c             	pushl  0xc(%ebp)
  800755:	ff 75 08             	pushl  0x8(%ebp)
  800758:	e8 9a ff ff ff       	call   8006f7 <vsnprintf>
	va_end(ap);

	return rc;
}
  80075d:	c9                   	leave  
  80075e:	c3                   	ret    

0080075f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80075f:	55                   	push   %ebp
  800760:	89 e5                	mov    %esp,%ebp
  800762:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800765:	b8 00 00 00 00       	mov    $0x0,%eax
  80076a:	eb 03                	jmp    80076f <strlen+0x10>
		n++;
  80076c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80076f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800773:	75 f7                	jne    80076c <strlen+0xd>
		n++;
	return n;
}
  800775:	5d                   	pop    %ebp
  800776:	c3                   	ret    

00800777 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800777:	55                   	push   %ebp
  800778:	89 e5                	mov    %esp,%ebp
  80077a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80077d:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800780:	ba 00 00 00 00       	mov    $0x0,%edx
  800785:	eb 03                	jmp    80078a <strnlen+0x13>
		n++;
  800787:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078a:	39 c2                	cmp    %eax,%edx
  80078c:	74 08                	je     800796 <strnlen+0x1f>
  80078e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800792:	75 f3                	jne    800787 <strnlen+0x10>
  800794:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800796:	5d                   	pop    %ebp
  800797:	c3                   	ret    

00800798 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800798:	55                   	push   %ebp
  800799:	89 e5                	mov    %esp,%ebp
  80079b:	53                   	push   %ebx
  80079c:	8b 45 08             	mov    0x8(%ebp),%eax
  80079f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a2:	89 c2                	mov    %eax,%edx
  8007a4:	83 c2 01             	add    $0x1,%edx
  8007a7:	83 c1 01             	add    $0x1,%ecx
  8007aa:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007ae:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007b1:	84 db                	test   %bl,%bl
  8007b3:	75 ef                	jne    8007a4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007b5:	5b                   	pop    %ebx
  8007b6:	5d                   	pop    %ebp
  8007b7:	c3                   	ret    

008007b8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	53                   	push   %ebx
  8007bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007bf:	53                   	push   %ebx
  8007c0:	e8 9a ff ff ff       	call   80075f <strlen>
  8007c5:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007c8:	ff 75 0c             	pushl  0xc(%ebp)
  8007cb:	01 d8                	add    %ebx,%eax
  8007cd:	50                   	push   %eax
  8007ce:	e8 c5 ff ff ff       	call   800798 <strcpy>
	return dst;
}
  8007d3:	89 d8                	mov    %ebx,%eax
  8007d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d8:	c9                   	leave  
  8007d9:	c3                   	ret    

008007da <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007da:	55                   	push   %ebp
  8007db:	89 e5                	mov    %esp,%ebp
  8007dd:	56                   	push   %esi
  8007de:	53                   	push   %ebx
  8007df:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e5:	89 f3                	mov    %esi,%ebx
  8007e7:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ea:	89 f2                	mov    %esi,%edx
  8007ec:	eb 0f                	jmp    8007fd <strncpy+0x23>
		*dst++ = *src;
  8007ee:	83 c2 01             	add    $0x1,%edx
  8007f1:	0f b6 01             	movzbl (%ecx),%eax
  8007f4:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007f7:	80 39 01             	cmpb   $0x1,(%ecx)
  8007fa:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007fd:	39 da                	cmp    %ebx,%edx
  8007ff:	75 ed                	jne    8007ee <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800801:	89 f0                	mov    %esi,%eax
  800803:	5b                   	pop    %ebx
  800804:	5e                   	pop    %esi
  800805:	5d                   	pop    %ebp
  800806:	c3                   	ret    

00800807 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	56                   	push   %esi
  80080b:	53                   	push   %ebx
  80080c:	8b 75 08             	mov    0x8(%ebp),%esi
  80080f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800812:	8b 55 10             	mov    0x10(%ebp),%edx
  800815:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800817:	85 d2                	test   %edx,%edx
  800819:	74 21                	je     80083c <strlcpy+0x35>
  80081b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80081f:	89 f2                	mov    %esi,%edx
  800821:	eb 09                	jmp    80082c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800823:	83 c2 01             	add    $0x1,%edx
  800826:	83 c1 01             	add    $0x1,%ecx
  800829:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80082c:	39 c2                	cmp    %eax,%edx
  80082e:	74 09                	je     800839 <strlcpy+0x32>
  800830:	0f b6 19             	movzbl (%ecx),%ebx
  800833:	84 db                	test   %bl,%bl
  800835:	75 ec                	jne    800823 <strlcpy+0x1c>
  800837:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800839:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80083c:	29 f0                	sub    %esi,%eax
}
  80083e:	5b                   	pop    %ebx
  80083f:	5e                   	pop    %esi
  800840:	5d                   	pop    %ebp
  800841:	c3                   	ret    

00800842 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800848:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80084b:	eb 06                	jmp    800853 <strcmp+0x11>
		p++, q++;
  80084d:	83 c1 01             	add    $0x1,%ecx
  800850:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800853:	0f b6 01             	movzbl (%ecx),%eax
  800856:	84 c0                	test   %al,%al
  800858:	74 04                	je     80085e <strcmp+0x1c>
  80085a:	3a 02                	cmp    (%edx),%al
  80085c:	74 ef                	je     80084d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80085e:	0f b6 c0             	movzbl %al,%eax
  800861:	0f b6 12             	movzbl (%edx),%edx
  800864:	29 d0                	sub    %edx,%eax
}
  800866:	5d                   	pop    %ebp
  800867:	c3                   	ret    

00800868 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800868:	55                   	push   %ebp
  800869:	89 e5                	mov    %esp,%ebp
  80086b:	53                   	push   %ebx
  80086c:	8b 45 08             	mov    0x8(%ebp),%eax
  80086f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800872:	89 c3                	mov    %eax,%ebx
  800874:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800877:	eb 06                	jmp    80087f <strncmp+0x17>
		n--, p++, q++;
  800879:	83 c0 01             	add    $0x1,%eax
  80087c:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80087f:	39 d8                	cmp    %ebx,%eax
  800881:	74 15                	je     800898 <strncmp+0x30>
  800883:	0f b6 08             	movzbl (%eax),%ecx
  800886:	84 c9                	test   %cl,%cl
  800888:	74 04                	je     80088e <strncmp+0x26>
  80088a:	3a 0a                	cmp    (%edx),%cl
  80088c:	74 eb                	je     800879 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80088e:	0f b6 00             	movzbl (%eax),%eax
  800891:	0f b6 12             	movzbl (%edx),%edx
  800894:	29 d0                	sub    %edx,%eax
  800896:	eb 05                	jmp    80089d <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800898:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80089d:	5b                   	pop    %ebx
  80089e:	5d                   	pop    %ebp
  80089f:	c3                   	ret    

008008a0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008aa:	eb 07                	jmp    8008b3 <strchr+0x13>
		if (*s == c)
  8008ac:	38 ca                	cmp    %cl,%dl
  8008ae:	74 0f                	je     8008bf <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008b0:	83 c0 01             	add    $0x1,%eax
  8008b3:	0f b6 10             	movzbl (%eax),%edx
  8008b6:	84 d2                	test   %dl,%dl
  8008b8:	75 f2                	jne    8008ac <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008bf:	5d                   	pop    %ebp
  8008c0:	c3                   	ret    

008008c1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008cb:	eb 03                	jmp    8008d0 <strfind+0xf>
  8008cd:	83 c0 01             	add    $0x1,%eax
  8008d0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008d3:	38 ca                	cmp    %cl,%dl
  8008d5:	74 04                	je     8008db <strfind+0x1a>
  8008d7:	84 d2                	test   %dl,%dl
  8008d9:	75 f2                	jne    8008cd <strfind+0xc>
			break;
	return (char *) s;
}
  8008db:	5d                   	pop    %ebp
  8008dc:	c3                   	ret    

008008dd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008dd:	55                   	push   %ebp
  8008de:	89 e5                	mov    %esp,%ebp
  8008e0:	57                   	push   %edi
  8008e1:	56                   	push   %esi
  8008e2:	53                   	push   %ebx
  8008e3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e9:	85 c9                	test   %ecx,%ecx
  8008eb:	74 36                	je     800923 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ed:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008f3:	75 28                	jne    80091d <memset+0x40>
  8008f5:	f6 c1 03             	test   $0x3,%cl
  8008f8:	75 23                	jne    80091d <memset+0x40>
		c &= 0xFF;
  8008fa:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008fe:	89 d3                	mov    %edx,%ebx
  800900:	c1 e3 08             	shl    $0x8,%ebx
  800903:	89 d6                	mov    %edx,%esi
  800905:	c1 e6 18             	shl    $0x18,%esi
  800908:	89 d0                	mov    %edx,%eax
  80090a:	c1 e0 10             	shl    $0x10,%eax
  80090d:	09 f0                	or     %esi,%eax
  80090f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800911:	89 d8                	mov    %ebx,%eax
  800913:	09 d0                	or     %edx,%eax
  800915:	c1 e9 02             	shr    $0x2,%ecx
  800918:	fc                   	cld    
  800919:	f3 ab                	rep stos %eax,%es:(%edi)
  80091b:	eb 06                	jmp    800923 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80091d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800920:	fc                   	cld    
  800921:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800923:	89 f8                	mov    %edi,%eax
  800925:	5b                   	pop    %ebx
  800926:	5e                   	pop    %esi
  800927:	5f                   	pop    %edi
  800928:	5d                   	pop    %ebp
  800929:	c3                   	ret    

0080092a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	57                   	push   %edi
  80092e:	56                   	push   %esi
  80092f:	8b 45 08             	mov    0x8(%ebp),%eax
  800932:	8b 75 0c             	mov    0xc(%ebp),%esi
  800935:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800938:	39 c6                	cmp    %eax,%esi
  80093a:	73 35                	jae    800971 <memmove+0x47>
  80093c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80093f:	39 d0                	cmp    %edx,%eax
  800941:	73 2e                	jae    800971 <memmove+0x47>
		s += n;
		d += n;
  800943:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800946:	89 d6                	mov    %edx,%esi
  800948:	09 fe                	or     %edi,%esi
  80094a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800950:	75 13                	jne    800965 <memmove+0x3b>
  800952:	f6 c1 03             	test   $0x3,%cl
  800955:	75 0e                	jne    800965 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800957:	83 ef 04             	sub    $0x4,%edi
  80095a:	8d 72 fc             	lea    -0x4(%edx),%esi
  80095d:	c1 e9 02             	shr    $0x2,%ecx
  800960:	fd                   	std    
  800961:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800963:	eb 09                	jmp    80096e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800965:	83 ef 01             	sub    $0x1,%edi
  800968:	8d 72 ff             	lea    -0x1(%edx),%esi
  80096b:	fd                   	std    
  80096c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80096e:	fc                   	cld    
  80096f:	eb 1d                	jmp    80098e <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800971:	89 f2                	mov    %esi,%edx
  800973:	09 c2                	or     %eax,%edx
  800975:	f6 c2 03             	test   $0x3,%dl
  800978:	75 0f                	jne    800989 <memmove+0x5f>
  80097a:	f6 c1 03             	test   $0x3,%cl
  80097d:	75 0a                	jne    800989 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80097f:	c1 e9 02             	shr    $0x2,%ecx
  800982:	89 c7                	mov    %eax,%edi
  800984:	fc                   	cld    
  800985:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800987:	eb 05                	jmp    80098e <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800989:	89 c7                	mov    %eax,%edi
  80098b:	fc                   	cld    
  80098c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80098e:	5e                   	pop    %esi
  80098f:	5f                   	pop    %edi
  800990:	5d                   	pop    %ebp
  800991:	c3                   	ret    

00800992 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800995:	ff 75 10             	pushl  0x10(%ebp)
  800998:	ff 75 0c             	pushl  0xc(%ebp)
  80099b:	ff 75 08             	pushl  0x8(%ebp)
  80099e:	e8 87 ff ff ff       	call   80092a <memmove>
}
  8009a3:	c9                   	leave  
  8009a4:	c3                   	ret    

008009a5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
  8009a8:	56                   	push   %esi
  8009a9:	53                   	push   %ebx
  8009aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b0:	89 c6                	mov    %eax,%esi
  8009b2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b5:	eb 1a                	jmp    8009d1 <memcmp+0x2c>
		if (*s1 != *s2)
  8009b7:	0f b6 08             	movzbl (%eax),%ecx
  8009ba:	0f b6 1a             	movzbl (%edx),%ebx
  8009bd:	38 d9                	cmp    %bl,%cl
  8009bf:	74 0a                	je     8009cb <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009c1:	0f b6 c1             	movzbl %cl,%eax
  8009c4:	0f b6 db             	movzbl %bl,%ebx
  8009c7:	29 d8                	sub    %ebx,%eax
  8009c9:	eb 0f                	jmp    8009da <memcmp+0x35>
		s1++, s2++;
  8009cb:	83 c0 01             	add    $0x1,%eax
  8009ce:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d1:	39 f0                	cmp    %esi,%eax
  8009d3:	75 e2                	jne    8009b7 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009da:	5b                   	pop    %ebx
  8009db:	5e                   	pop    %esi
  8009dc:	5d                   	pop    %ebp
  8009dd:	c3                   	ret    

008009de <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	53                   	push   %ebx
  8009e2:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009e5:	89 c1                	mov    %eax,%ecx
  8009e7:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ea:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ee:	eb 0a                	jmp    8009fa <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009f0:	0f b6 10             	movzbl (%eax),%edx
  8009f3:	39 da                	cmp    %ebx,%edx
  8009f5:	74 07                	je     8009fe <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009f7:	83 c0 01             	add    $0x1,%eax
  8009fa:	39 c8                	cmp    %ecx,%eax
  8009fc:	72 f2                	jb     8009f0 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009fe:	5b                   	pop    %ebx
  8009ff:	5d                   	pop    %ebp
  800a00:	c3                   	ret    

00800a01 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a01:	55                   	push   %ebp
  800a02:	89 e5                	mov    %esp,%ebp
  800a04:	57                   	push   %edi
  800a05:	56                   	push   %esi
  800a06:	53                   	push   %ebx
  800a07:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a0a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a0d:	eb 03                	jmp    800a12 <strtol+0x11>
		s++;
  800a0f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a12:	0f b6 01             	movzbl (%ecx),%eax
  800a15:	3c 20                	cmp    $0x20,%al
  800a17:	74 f6                	je     800a0f <strtol+0xe>
  800a19:	3c 09                	cmp    $0x9,%al
  800a1b:	74 f2                	je     800a0f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a1d:	3c 2b                	cmp    $0x2b,%al
  800a1f:	75 0a                	jne    800a2b <strtol+0x2a>
		s++;
  800a21:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a24:	bf 00 00 00 00       	mov    $0x0,%edi
  800a29:	eb 11                	jmp    800a3c <strtol+0x3b>
  800a2b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a30:	3c 2d                	cmp    $0x2d,%al
  800a32:	75 08                	jne    800a3c <strtol+0x3b>
		s++, neg = 1;
  800a34:	83 c1 01             	add    $0x1,%ecx
  800a37:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a3c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a42:	75 15                	jne    800a59 <strtol+0x58>
  800a44:	80 39 30             	cmpb   $0x30,(%ecx)
  800a47:	75 10                	jne    800a59 <strtol+0x58>
  800a49:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a4d:	75 7c                	jne    800acb <strtol+0xca>
		s += 2, base = 16;
  800a4f:	83 c1 02             	add    $0x2,%ecx
  800a52:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a57:	eb 16                	jmp    800a6f <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a59:	85 db                	test   %ebx,%ebx
  800a5b:	75 12                	jne    800a6f <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a5d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a62:	80 39 30             	cmpb   $0x30,(%ecx)
  800a65:	75 08                	jne    800a6f <strtol+0x6e>
		s++, base = 8;
  800a67:	83 c1 01             	add    $0x1,%ecx
  800a6a:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a6f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a74:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a77:	0f b6 11             	movzbl (%ecx),%edx
  800a7a:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a7d:	89 f3                	mov    %esi,%ebx
  800a7f:	80 fb 09             	cmp    $0x9,%bl
  800a82:	77 08                	ja     800a8c <strtol+0x8b>
			dig = *s - '0';
  800a84:	0f be d2             	movsbl %dl,%edx
  800a87:	83 ea 30             	sub    $0x30,%edx
  800a8a:	eb 22                	jmp    800aae <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a8c:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a8f:	89 f3                	mov    %esi,%ebx
  800a91:	80 fb 19             	cmp    $0x19,%bl
  800a94:	77 08                	ja     800a9e <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a96:	0f be d2             	movsbl %dl,%edx
  800a99:	83 ea 57             	sub    $0x57,%edx
  800a9c:	eb 10                	jmp    800aae <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a9e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aa1:	89 f3                	mov    %esi,%ebx
  800aa3:	80 fb 19             	cmp    $0x19,%bl
  800aa6:	77 16                	ja     800abe <strtol+0xbd>
			dig = *s - 'A' + 10;
  800aa8:	0f be d2             	movsbl %dl,%edx
  800aab:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aae:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ab1:	7d 0b                	jge    800abe <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ab3:	83 c1 01             	add    $0x1,%ecx
  800ab6:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aba:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800abc:	eb b9                	jmp    800a77 <strtol+0x76>

	if (endptr)
  800abe:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac2:	74 0d                	je     800ad1 <strtol+0xd0>
		*endptr = (char *) s;
  800ac4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac7:	89 0e                	mov    %ecx,(%esi)
  800ac9:	eb 06                	jmp    800ad1 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800acb:	85 db                	test   %ebx,%ebx
  800acd:	74 98                	je     800a67 <strtol+0x66>
  800acf:	eb 9e                	jmp    800a6f <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ad1:	89 c2                	mov    %eax,%edx
  800ad3:	f7 da                	neg    %edx
  800ad5:	85 ff                	test   %edi,%edi
  800ad7:	0f 45 c2             	cmovne %edx,%eax
}
  800ada:	5b                   	pop    %ebx
  800adb:	5e                   	pop    %esi
  800adc:	5f                   	pop    %edi
  800add:	5d                   	pop    %ebp
  800ade:	c3                   	ret    

00800adf <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800adf:	55                   	push   %ebp
  800ae0:	89 e5                	mov    %esp,%ebp
  800ae2:	57                   	push   %edi
  800ae3:	56                   	push   %esi
  800ae4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae5:	b8 00 00 00 00       	mov    $0x0,%eax
  800aea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aed:	8b 55 08             	mov    0x8(%ebp),%edx
  800af0:	89 c3                	mov    %eax,%ebx
  800af2:	89 c7                	mov    %eax,%edi
  800af4:	89 c6                	mov    %eax,%esi
  800af6:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800af8:	5b                   	pop    %ebx
  800af9:	5e                   	pop    %esi
  800afa:	5f                   	pop    %edi
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <sys_cgetc>:

int
sys_cgetc(void)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	57                   	push   %edi
  800b01:	56                   	push   %esi
  800b02:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b03:	ba 00 00 00 00       	mov    $0x0,%edx
  800b08:	b8 01 00 00 00       	mov    $0x1,%eax
  800b0d:	89 d1                	mov    %edx,%ecx
  800b0f:	89 d3                	mov    %edx,%ebx
  800b11:	89 d7                	mov    %edx,%edi
  800b13:	89 d6                	mov    %edx,%esi
  800b15:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b17:	5b                   	pop    %ebx
  800b18:	5e                   	pop    %esi
  800b19:	5f                   	pop    %edi
  800b1a:	5d                   	pop    %ebp
  800b1b:	c3                   	ret    

00800b1c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	57                   	push   %edi
  800b20:	56                   	push   %esi
  800b21:	53                   	push   %ebx
  800b22:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b25:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b2a:	b8 03 00 00 00       	mov    $0x3,%eax
  800b2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b32:	89 cb                	mov    %ecx,%ebx
  800b34:	89 cf                	mov    %ecx,%edi
  800b36:	89 ce                	mov    %ecx,%esi
  800b38:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b3a:	85 c0                	test   %eax,%eax
  800b3c:	7e 17                	jle    800b55 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b3e:	83 ec 0c             	sub    $0xc,%esp
  800b41:	50                   	push   %eax
  800b42:	6a 03                	push   $0x3
  800b44:	68 df 21 80 00       	push   $0x8021df
  800b49:	6a 23                	push   $0x23
  800b4b:	68 fc 21 80 00       	push   $0x8021fc
  800b50:	e8 20 10 00 00       	call   801b75 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b58:	5b                   	pop    %ebx
  800b59:	5e                   	pop    %esi
  800b5a:	5f                   	pop    %edi
  800b5b:	5d                   	pop    %ebp
  800b5c:	c3                   	ret    

00800b5d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b5d:	55                   	push   %ebp
  800b5e:	89 e5                	mov    %esp,%ebp
  800b60:	57                   	push   %edi
  800b61:	56                   	push   %esi
  800b62:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b63:	ba 00 00 00 00       	mov    $0x0,%edx
  800b68:	b8 02 00 00 00       	mov    $0x2,%eax
  800b6d:	89 d1                	mov    %edx,%ecx
  800b6f:	89 d3                	mov    %edx,%ebx
  800b71:	89 d7                	mov    %edx,%edi
  800b73:	89 d6                	mov    %edx,%esi
  800b75:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b77:	5b                   	pop    %ebx
  800b78:	5e                   	pop    %esi
  800b79:	5f                   	pop    %edi
  800b7a:	5d                   	pop    %ebp
  800b7b:	c3                   	ret    

00800b7c <sys_yield>:

void
sys_yield(void)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	57                   	push   %edi
  800b80:	56                   	push   %esi
  800b81:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b82:	ba 00 00 00 00       	mov    $0x0,%edx
  800b87:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b8c:	89 d1                	mov    %edx,%ecx
  800b8e:	89 d3                	mov    %edx,%ebx
  800b90:	89 d7                	mov    %edx,%edi
  800b92:	89 d6                	mov    %edx,%esi
  800b94:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b96:	5b                   	pop    %ebx
  800b97:	5e                   	pop    %esi
  800b98:	5f                   	pop    %edi
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    

00800b9b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	57                   	push   %edi
  800b9f:	56                   	push   %esi
  800ba0:	53                   	push   %ebx
  800ba1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba4:	be 00 00 00 00       	mov    $0x0,%esi
  800ba9:	b8 04 00 00 00       	mov    $0x4,%eax
  800bae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb7:	89 f7                	mov    %esi,%edi
  800bb9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bbb:	85 c0                	test   %eax,%eax
  800bbd:	7e 17                	jle    800bd6 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbf:	83 ec 0c             	sub    $0xc,%esp
  800bc2:	50                   	push   %eax
  800bc3:	6a 04                	push   $0x4
  800bc5:	68 df 21 80 00       	push   $0x8021df
  800bca:	6a 23                	push   $0x23
  800bcc:	68 fc 21 80 00       	push   $0x8021fc
  800bd1:	e8 9f 0f 00 00       	call   801b75 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd9:	5b                   	pop    %ebx
  800bda:	5e                   	pop    %esi
  800bdb:	5f                   	pop    %edi
  800bdc:	5d                   	pop    %ebp
  800bdd:	c3                   	ret    

00800bde <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	57                   	push   %edi
  800be2:	56                   	push   %esi
  800be3:	53                   	push   %ebx
  800be4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be7:	b8 05 00 00 00       	mov    $0x5,%eax
  800bec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bef:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bf8:	8b 75 18             	mov    0x18(%ebp),%esi
  800bfb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bfd:	85 c0                	test   %eax,%eax
  800bff:	7e 17                	jle    800c18 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c01:	83 ec 0c             	sub    $0xc,%esp
  800c04:	50                   	push   %eax
  800c05:	6a 05                	push   $0x5
  800c07:	68 df 21 80 00       	push   $0x8021df
  800c0c:	6a 23                	push   $0x23
  800c0e:	68 fc 21 80 00       	push   $0x8021fc
  800c13:	e8 5d 0f 00 00       	call   801b75 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1b:	5b                   	pop    %ebx
  800c1c:	5e                   	pop    %esi
  800c1d:	5f                   	pop    %edi
  800c1e:	5d                   	pop    %ebp
  800c1f:	c3                   	ret    

00800c20 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c20:	55                   	push   %ebp
  800c21:	89 e5                	mov    %esp,%ebp
  800c23:	57                   	push   %edi
  800c24:	56                   	push   %esi
  800c25:	53                   	push   %ebx
  800c26:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c29:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c2e:	b8 06 00 00 00       	mov    $0x6,%eax
  800c33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c36:	8b 55 08             	mov    0x8(%ebp),%edx
  800c39:	89 df                	mov    %ebx,%edi
  800c3b:	89 de                	mov    %ebx,%esi
  800c3d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c3f:	85 c0                	test   %eax,%eax
  800c41:	7e 17                	jle    800c5a <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c43:	83 ec 0c             	sub    $0xc,%esp
  800c46:	50                   	push   %eax
  800c47:	6a 06                	push   $0x6
  800c49:	68 df 21 80 00       	push   $0x8021df
  800c4e:	6a 23                	push   $0x23
  800c50:	68 fc 21 80 00       	push   $0x8021fc
  800c55:	e8 1b 0f 00 00       	call   801b75 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5d:	5b                   	pop    %ebx
  800c5e:	5e                   	pop    %esi
  800c5f:	5f                   	pop    %edi
  800c60:	5d                   	pop    %ebp
  800c61:	c3                   	ret    

00800c62 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c62:	55                   	push   %ebp
  800c63:	89 e5                	mov    %esp,%ebp
  800c65:	57                   	push   %edi
  800c66:	56                   	push   %esi
  800c67:	53                   	push   %ebx
  800c68:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c70:	b8 08 00 00 00       	mov    $0x8,%eax
  800c75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c78:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7b:	89 df                	mov    %ebx,%edi
  800c7d:	89 de                	mov    %ebx,%esi
  800c7f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c81:	85 c0                	test   %eax,%eax
  800c83:	7e 17                	jle    800c9c <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c85:	83 ec 0c             	sub    $0xc,%esp
  800c88:	50                   	push   %eax
  800c89:	6a 08                	push   $0x8
  800c8b:	68 df 21 80 00       	push   $0x8021df
  800c90:	6a 23                	push   $0x23
  800c92:	68 fc 21 80 00       	push   $0x8021fc
  800c97:	e8 d9 0e 00 00       	call   801b75 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9f:	5b                   	pop    %ebx
  800ca0:	5e                   	pop    %esi
  800ca1:	5f                   	pop    %edi
  800ca2:	5d                   	pop    %ebp
  800ca3:	c3                   	ret    

00800ca4 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	57                   	push   %edi
  800ca8:	56                   	push   %esi
  800ca9:	53                   	push   %ebx
  800caa:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cad:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb2:	b8 09 00 00 00       	mov    $0x9,%eax
  800cb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cba:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbd:	89 df                	mov    %ebx,%edi
  800cbf:	89 de                	mov    %ebx,%esi
  800cc1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc3:	85 c0                	test   %eax,%eax
  800cc5:	7e 17                	jle    800cde <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc7:	83 ec 0c             	sub    $0xc,%esp
  800cca:	50                   	push   %eax
  800ccb:	6a 09                	push   $0x9
  800ccd:	68 df 21 80 00       	push   $0x8021df
  800cd2:	6a 23                	push   $0x23
  800cd4:	68 fc 21 80 00       	push   $0x8021fc
  800cd9:	e8 97 0e 00 00       	call   801b75 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce1:	5b                   	pop    %ebx
  800ce2:	5e                   	pop    %esi
  800ce3:	5f                   	pop    %edi
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    

00800ce6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ce6:	55                   	push   %ebp
  800ce7:	89 e5                	mov    %esp,%ebp
  800ce9:	57                   	push   %edi
  800cea:	56                   	push   %esi
  800ceb:	53                   	push   %ebx
  800cec:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cef:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf4:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cf9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cff:	89 df                	mov    %ebx,%edi
  800d01:	89 de                	mov    %ebx,%esi
  800d03:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d05:	85 c0                	test   %eax,%eax
  800d07:	7e 17                	jle    800d20 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d09:	83 ec 0c             	sub    $0xc,%esp
  800d0c:	50                   	push   %eax
  800d0d:	6a 0a                	push   $0xa
  800d0f:	68 df 21 80 00       	push   $0x8021df
  800d14:	6a 23                	push   $0x23
  800d16:	68 fc 21 80 00       	push   $0x8021fc
  800d1b:	e8 55 0e 00 00       	call   801b75 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d23:	5b                   	pop    %ebx
  800d24:	5e                   	pop    %esi
  800d25:	5f                   	pop    %edi
  800d26:	5d                   	pop    %ebp
  800d27:	c3                   	ret    

00800d28 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	57                   	push   %edi
  800d2c:	56                   	push   %esi
  800d2d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2e:	be 00 00 00 00       	mov    $0x0,%esi
  800d33:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d41:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d44:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d46:	5b                   	pop    %ebx
  800d47:	5e                   	pop    %esi
  800d48:	5f                   	pop    %edi
  800d49:	5d                   	pop    %ebp
  800d4a:	c3                   	ret    

00800d4b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d4b:	55                   	push   %ebp
  800d4c:	89 e5                	mov    %esp,%ebp
  800d4e:	57                   	push   %edi
  800d4f:	56                   	push   %esi
  800d50:	53                   	push   %ebx
  800d51:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d54:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d59:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d61:	89 cb                	mov    %ecx,%ebx
  800d63:	89 cf                	mov    %ecx,%edi
  800d65:	89 ce                	mov    %ecx,%esi
  800d67:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d69:	85 c0                	test   %eax,%eax
  800d6b:	7e 17                	jle    800d84 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6d:	83 ec 0c             	sub    $0xc,%esp
  800d70:	50                   	push   %eax
  800d71:	6a 0d                	push   $0xd
  800d73:	68 df 21 80 00       	push   $0x8021df
  800d78:	6a 23                	push   $0x23
  800d7a:	68 fc 21 80 00       	push   $0x8021fc
  800d7f:	e8 f1 0d 00 00       	call   801b75 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d87:	5b                   	pop    %ebx
  800d88:	5e                   	pop    %esi
  800d89:	5f                   	pop    %edi
  800d8a:	5d                   	pop    %ebp
  800d8b:	c3                   	ret    

00800d8c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	56                   	push   %esi
  800d90:	53                   	push   %ebx
  800d91:	8b 75 08             	mov    0x8(%ebp),%esi
  800d94:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d97:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

    if (pg != NULL)
  800d9a:	85 c0                	test   %eax,%eax
  800d9c:	74 0e                	je     800dac <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  800d9e:	83 ec 0c             	sub    $0xc,%esp
  800da1:	50                   	push   %eax
  800da2:	e8 a4 ff ff ff       	call   800d4b <sys_ipc_recv>
  800da7:	83 c4 10             	add    $0x10,%esp
  800daa:	eb 0d                	jmp    800db9 <ipc_recv+0x2d>
	else
        r = sys_ipc_recv((void *)-1);
  800dac:	83 ec 0c             	sub    $0xc,%esp
  800daf:	6a ff                	push   $0xffffffff
  800db1:	e8 95 ff ff ff       	call   800d4b <sys_ipc_recv>
  800db6:	83 c4 10             	add    $0x10,%esp

	if (r < 0) {
  800db9:	85 c0                	test   %eax,%eax
  800dbb:	79 16                	jns    800dd3 <ipc_recv+0x47>

		if (from_env_store != NULL)
  800dbd:	85 f6                	test   %esi,%esi
  800dbf:	74 06                	je     800dc7 <ipc_recv+0x3b>
			*from_env_store = 0;
  800dc1:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL)
  800dc7:	85 db                	test   %ebx,%ebx
  800dc9:	74 2c                	je     800df7 <ipc_recv+0x6b>
			*perm_store = 0;
  800dcb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800dd1:	eb 24                	jmp    800df7 <ipc_recv+0x6b>
		return r;

	} else {

		if (from_env_store != NULL)
  800dd3:	85 f6                	test   %esi,%esi
  800dd5:	74 0a                	je     800de1 <ipc_recv+0x55>
			*from_env_store = thisenv->env_ipc_from;
  800dd7:	a1 04 40 80 00       	mov    0x804004,%eax
  800ddc:	8b 40 74             	mov    0x74(%eax),%eax
  800ddf:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL)
  800de1:	85 db                	test   %ebx,%ebx
  800de3:	74 0a                	je     800def <ipc_recv+0x63>
			*perm_store = thisenv->env_ipc_perm;
  800de5:	a1 04 40 80 00       	mov    0x804004,%eax
  800dea:	8b 40 78             	mov    0x78(%eax),%eax
  800ded:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  800def:	a1 04 40 80 00       	mov    0x804004,%eax
  800df4:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  800df7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800dfa:	5b                   	pop    %ebx
  800dfb:	5e                   	pop    %esi
  800dfc:	5d                   	pop    %ebp
  800dfd:	c3                   	ret    

00800dfe <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800dfe:	55                   	push   %ebp
  800dff:	89 e5                	mov    %esp,%ebp
  800e01:	57                   	push   %edi
  800e02:	56                   	push   %esi
  800e03:	53                   	push   %ebx
  800e04:	83 ec 0c             	sub    $0xc,%esp
  800e07:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e0a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e0d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

	if (pg == NULL)
  800e10:	85 db                	test   %ebx,%ebx
		pg = (void *)-1;	
  800e12:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800e17:	0f 44 d8             	cmove  %eax,%ebx

	while (true) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  800e1a:	ff 75 14             	pushl  0x14(%ebp)
  800e1d:	53                   	push   %ebx
  800e1e:	56                   	push   %esi
  800e1f:	57                   	push   %edi
  800e20:	e8 03 ff ff ff       	call   800d28 <sys_ipc_try_send>
		if (r >= 0)
  800e25:	83 c4 10             	add    $0x10,%esp
  800e28:	85 c0                	test   %eax,%eax
  800e2a:	79 1e                	jns    800e4a <ipc_send+0x4c>
			return;
		else if (r != -E_IPC_NOT_RECV)
  800e2c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800e2f:	74 12                	je     800e43 <ipc_send+0x45>
			panic("ipc_send error: %e", r);
  800e31:	50                   	push   %eax
  800e32:	68 0a 22 80 00       	push   $0x80220a
  800e37:	6a 49                	push   $0x49
  800e39:	68 1d 22 80 00       	push   $0x80221d
  800e3e:	e8 32 0d 00 00       	call   801b75 <_panic>
	
		sys_yield();
  800e43:	e8 34 fd ff ff       	call   800b7c <sys_yield>
	}
  800e48:	eb d0                	jmp    800e1a <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  800e4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e4d:	5b                   	pop    %ebx
  800e4e:	5e                   	pop    %esi
  800e4f:	5f                   	pop    %edi
  800e50:	5d                   	pop    %ebp
  800e51:	c3                   	ret    

00800e52 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800e52:	55                   	push   %ebp
  800e53:	89 e5                	mov    %esp,%ebp
  800e55:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800e58:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800e5d:	6b d0 7c             	imul   $0x7c,%eax,%edx
  800e60:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800e66:	8b 52 50             	mov    0x50(%edx),%edx
  800e69:	39 ca                	cmp    %ecx,%edx
  800e6b:	75 0d                	jne    800e7a <ipc_find_env+0x28>
			return envs[i].env_id;
  800e6d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800e70:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800e75:	8b 40 48             	mov    0x48(%eax),%eax
  800e78:	eb 0f                	jmp    800e89 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800e7a:	83 c0 01             	add    $0x1,%eax
  800e7d:	3d 00 04 00 00       	cmp    $0x400,%eax
  800e82:	75 d9                	jne    800e5d <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800e84:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e89:	5d                   	pop    %ebp
  800e8a:	c3                   	ret    

00800e8b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e8b:	55                   	push   %ebp
  800e8c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e91:	05 00 00 00 30       	add    $0x30000000,%eax
  800e96:	c1 e8 0c             	shr    $0xc,%eax
}
  800e99:	5d                   	pop    %ebp
  800e9a:	c3                   	ret    

00800e9b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e9b:	55                   	push   %ebp
  800e9c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea1:	05 00 00 00 30       	add    $0x30000000,%eax
  800ea6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800eab:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800eb0:	5d                   	pop    %ebp
  800eb1:	c3                   	ret    

00800eb2 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800eb2:	55                   	push   %ebp
  800eb3:	89 e5                	mov    %esp,%ebp
  800eb5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eb8:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800ebd:	89 c2                	mov    %eax,%edx
  800ebf:	c1 ea 16             	shr    $0x16,%edx
  800ec2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ec9:	f6 c2 01             	test   $0x1,%dl
  800ecc:	74 11                	je     800edf <fd_alloc+0x2d>
  800ece:	89 c2                	mov    %eax,%edx
  800ed0:	c1 ea 0c             	shr    $0xc,%edx
  800ed3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eda:	f6 c2 01             	test   $0x1,%dl
  800edd:	75 09                	jne    800ee8 <fd_alloc+0x36>
			*fd_store = fd;
  800edf:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ee1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee6:	eb 17                	jmp    800eff <fd_alloc+0x4d>
  800ee8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800eed:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ef2:	75 c9                	jne    800ebd <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ef4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800efa:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800eff:	5d                   	pop    %ebp
  800f00:	c3                   	ret    

00800f01 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f01:	55                   	push   %ebp
  800f02:	89 e5                	mov    %esp,%ebp
  800f04:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f07:	83 f8 1f             	cmp    $0x1f,%eax
  800f0a:	77 36                	ja     800f42 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f0c:	c1 e0 0c             	shl    $0xc,%eax
  800f0f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f14:	89 c2                	mov    %eax,%edx
  800f16:	c1 ea 16             	shr    $0x16,%edx
  800f19:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f20:	f6 c2 01             	test   $0x1,%dl
  800f23:	74 24                	je     800f49 <fd_lookup+0x48>
  800f25:	89 c2                	mov    %eax,%edx
  800f27:	c1 ea 0c             	shr    $0xc,%edx
  800f2a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f31:	f6 c2 01             	test   $0x1,%dl
  800f34:	74 1a                	je     800f50 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f36:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f39:	89 02                	mov    %eax,(%edx)
	return 0;
  800f3b:	b8 00 00 00 00       	mov    $0x0,%eax
  800f40:	eb 13                	jmp    800f55 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f42:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f47:	eb 0c                	jmp    800f55 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f49:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f4e:	eb 05                	jmp    800f55 <fd_lookup+0x54>
  800f50:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f55:	5d                   	pop    %ebp
  800f56:	c3                   	ret    

00800f57 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f57:	55                   	push   %ebp
  800f58:	89 e5                	mov    %esp,%ebp
  800f5a:	83 ec 08             	sub    $0x8,%esp
  800f5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f60:	ba a4 22 80 00       	mov    $0x8022a4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f65:	eb 13                	jmp    800f7a <dev_lookup+0x23>
  800f67:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f6a:	39 08                	cmp    %ecx,(%eax)
  800f6c:	75 0c                	jne    800f7a <dev_lookup+0x23>
			*dev = devtab[i];
  800f6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f71:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f73:	b8 00 00 00 00       	mov    $0x0,%eax
  800f78:	eb 2e                	jmp    800fa8 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f7a:	8b 02                	mov    (%edx),%eax
  800f7c:	85 c0                	test   %eax,%eax
  800f7e:	75 e7                	jne    800f67 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f80:	a1 04 40 80 00       	mov    0x804004,%eax
  800f85:	8b 40 48             	mov    0x48(%eax),%eax
  800f88:	83 ec 04             	sub    $0x4,%esp
  800f8b:	51                   	push   %ecx
  800f8c:	50                   	push   %eax
  800f8d:	68 28 22 80 00       	push   $0x802228
  800f92:	e8 fd f1 ff ff       	call   800194 <cprintf>
	*dev = 0;
  800f97:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f9a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800fa0:	83 c4 10             	add    $0x10,%esp
  800fa3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fa8:	c9                   	leave  
  800fa9:	c3                   	ret    

00800faa <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800faa:	55                   	push   %ebp
  800fab:	89 e5                	mov    %esp,%ebp
  800fad:	56                   	push   %esi
  800fae:	53                   	push   %ebx
  800faf:	83 ec 10             	sub    $0x10,%esp
  800fb2:	8b 75 08             	mov    0x8(%ebp),%esi
  800fb5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fb8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fbb:	50                   	push   %eax
  800fbc:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fc2:	c1 e8 0c             	shr    $0xc,%eax
  800fc5:	50                   	push   %eax
  800fc6:	e8 36 ff ff ff       	call   800f01 <fd_lookup>
  800fcb:	83 c4 08             	add    $0x8,%esp
  800fce:	85 c0                	test   %eax,%eax
  800fd0:	78 05                	js     800fd7 <fd_close+0x2d>
	    || fd != fd2)
  800fd2:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fd5:	74 0c                	je     800fe3 <fd_close+0x39>
		return (must_exist ? r : 0);
  800fd7:	84 db                	test   %bl,%bl
  800fd9:	ba 00 00 00 00       	mov    $0x0,%edx
  800fde:	0f 44 c2             	cmove  %edx,%eax
  800fe1:	eb 41                	jmp    801024 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fe3:	83 ec 08             	sub    $0x8,%esp
  800fe6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fe9:	50                   	push   %eax
  800fea:	ff 36                	pushl  (%esi)
  800fec:	e8 66 ff ff ff       	call   800f57 <dev_lookup>
  800ff1:	89 c3                	mov    %eax,%ebx
  800ff3:	83 c4 10             	add    $0x10,%esp
  800ff6:	85 c0                	test   %eax,%eax
  800ff8:	78 1a                	js     801014 <fd_close+0x6a>
		if (dev->dev_close)
  800ffa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ffd:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801000:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801005:	85 c0                	test   %eax,%eax
  801007:	74 0b                	je     801014 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801009:	83 ec 0c             	sub    $0xc,%esp
  80100c:	56                   	push   %esi
  80100d:	ff d0                	call   *%eax
  80100f:	89 c3                	mov    %eax,%ebx
  801011:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801014:	83 ec 08             	sub    $0x8,%esp
  801017:	56                   	push   %esi
  801018:	6a 00                	push   $0x0
  80101a:	e8 01 fc ff ff       	call   800c20 <sys_page_unmap>
	return r;
  80101f:	83 c4 10             	add    $0x10,%esp
  801022:	89 d8                	mov    %ebx,%eax
}
  801024:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801027:	5b                   	pop    %ebx
  801028:	5e                   	pop    %esi
  801029:	5d                   	pop    %ebp
  80102a:	c3                   	ret    

0080102b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80102b:	55                   	push   %ebp
  80102c:	89 e5                	mov    %esp,%ebp
  80102e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801031:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801034:	50                   	push   %eax
  801035:	ff 75 08             	pushl  0x8(%ebp)
  801038:	e8 c4 fe ff ff       	call   800f01 <fd_lookup>
  80103d:	83 c4 08             	add    $0x8,%esp
  801040:	85 c0                	test   %eax,%eax
  801042:	78 10                	js     801054 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801044:	83 ec 08             	sub    $0x8,%esp
  801047:	6a 01                	push   $0x1
  801049:	ff 75 f4             	pushl  -0xc(%ebp)
  80104c:	e8 59 ff ff ff       	call   800faa <fd_close>
  801051:	83 c4 10             	add    $0x10,%esp
}
  801054:	c9                   	leave  
  801055:	c3                   	ret    

00801056 <close_all>:

void
close_all(void)
{
  801056:	55                   	push   %ebp
  801057:	89 e5                	mov    %esp,%ebp
  801059:	53                   	push   %ebx
  80105a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80105d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801062:	83 ec 0c             	sub    $0xc,%esp
  801065:	53                   	push   %ebx
  801066:	e8 c0 ff ff ff       	call   80102b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80106b:	83 c3 01             	add    $0x1,%ebx
  80106e:	83 c4 10             	add    $0x10,%esp
  801071:	83 fb 20             	cmp    $0x20,%ebx
  801074:	75 ec                	jne    801062 <close_all+0xc>
		close(i);
}
  801076:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801079:	c9                   	leave  
  80107a:	c3                   	ret    

0080107b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80107b:	55                   	push   %ebp
  80107c:	89 e5                	mov    %esp,%ebp
  80107e:	57                   	push   %edi
  80107f:	56                   	push   %esi
  801080:	53                   	push   %ebx
  801081:	83 ec 2c             	sub    $0x2c,%esp
  801084:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801087:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80108a:	50                   	push   %eax
  80108b:	ff 75 08             	pushl  0x8(%ebp)
  80108e:	e8 6e fe ff ff       	call   800f01 <fd_lookup>
  801093:	83 c4 08             	add    $0x8,%esp
  801096:	85 c0                	test   %eax,%eax
  801098:	0f 88 c1 00 00 00    	js     80115f <dup+0xe4>
		return r;
	close(newfdnum);
  80109e:	83 ec 0c             	sub    $0xc,%esp
  8010a1:	56                   	push   %esi
  8010a2:	e8 84 ff ff ff       	call   80102b <close>

	newfd = INDEX2FD(newfdnum);
  8010a7:	89 f3                	mov    %esi,%ebx
  8010a9:	c1 e3 0c             	shl    $0xc,%ebx
  8010ac:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8010b2:	83 c4 04             	add    $0x4,%esp
  8010b5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010b8:	e8 de fd ff ff       	call   800e9b <fd2data>
  8010bd:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8010bf:	89 1c 24             	mov    %ebx,(%esp)
  8010c2:	e8 d4 fd ff ff       	call   800e9b <fd2data>
  8010c7:	83 c4 10             	add    $0x10,%esp
  8010ca:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010cd:	89 f8                	mov    %edi,%eax
  8010cf:	c1 e8 16             	shr    $0x16,%eax
  8010d2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010d9:	a8 01                	test   $0x1,%al
  8010db:	74 37                	je     801114 <dup+0x99>
  8010dd:	89 f8                	mov    %edi,%eax
  8010df:	c1 e8 0c             	shr    $0xc,%eax
  8010e2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010e9:	f6 c2 01             	test   $0x1,%dl
  8010ec:	74 26                	je     801114 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010ee:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010f5:	83 ec 0c             	sub    $0xc,%esp
  8010f8:	25 07 0e 00 00       	and    $0xe07,%eax
  8010fd:	50                   	push   %eax
  8010fe:	ff 75 d4             	pushl  -0x2c(%ebp)
  801101:	6a 00                	push   $0x0
  801103:	57                   	push   %edi
  801104:	6a 00                	push   $0x0
  801106:	e8 d3 fa ff ff       	call   800bde <sys_page_map>
  80110b:	89 c7                	mov    %eax,%edi
  80110d:	83 c4 20             	add    $0x20,%esp
  801110:	85 c0                	test   %eax,%eax
  801112:	78 2e                	js     801142 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801114:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801117:	89 d0                	mov    %edx,%eax
  801119:	c1 e8 0c             	shr    $0xc,%eax
  80111c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801123:	83 ec 0c             	sub    $0xc,%esp
  801126:	25 07 0e 00 00       	and    $0xe07,%eax
  80112b:	50                   	push   %eax
  80112c:	53                   	push   %ebx
  80112d:	6a 00                	push   $0x0
  80112f:	52                   	push   %edx
  801130:	6a 00                	push   $0x0
  801132:	e8 a7 fa ff ff       	call   800bde <sys_page_map>
  801137:	89 c7                	mov    %eax,%edi
  801139:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80113c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80113e:	85 ff                	test   %edi,%edi
  801140:	79 1d                	jns    80115f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801142:	83 ec 08             	sub    $0x8,%esp
  801145:	53                   	push   %ebx
  801146:	6a 00                	push   $0x0
  801148:	e8 d3 fa ff ff       	call   800c20 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80114d:	83 c4 08             	add    $0x8,%esp
  801150:	ff 75 d4             	pushl  -0x2c(%ebp)
  801153:	6a 00                	push   $0x0
  801155:	e8 c6 fa ff ff       	call   800c20 <sys_page_unmap>
	return r;
  80115a:	83 c4 10             	add    $0x10,%esp
  80115d:	89 f8                	mov    %edi,%eax
}
  80115f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801162:	5b                   	pop    %ebx
  801163:	5e                   	pop    %esi
  801164:	5f                   	pop    %edi
  801165:	5d                   	pop    %ebp
  801166:	c3                   	ret    

00801167 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801167:	55                   	push   %ebp
  801168:	89 e5                	mov    %esp,%ebp
  80116a:	53                   	push   %ebx
  80116b:	83 ec 14             	sub    $0x14,%esp
  80116e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801171:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801174:	50                   	push   %eax
  801175:	53                   	push   %ebx
  801176:	e8 86 fd ff ff       	call   800f01 <fd_lookup>
  80117b:	83 c4 08             	add    $0x8,%esp
  80117e:	89 c2                	mov    %eax,%edx
  801180:	85 c0                	test   %eax,%eax
  801182:	78 6d                	js     8011f1 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801184:	83 ec 08             	sub    $0x8,%esp
  801187:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80118a:	50                   	push   %eax
  80118b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80118e:	ff 30                	pushl  (%eax)
  801190:	e8 c2 fd ff ff       	call   800f57 <dev_lookup>
  801195:	83 c4 10             	add    $0x10,%esp
  801198:	85 c0                	test   %eax,%eax
  80119a:	78 4c                	js     8011e8 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80119c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80119f:	8b 42 08             	mov    0x8(%edx),%eax
  8011a2:	83 e0 03             	and    $0x3,%eax
  8011a5:	83 f8 01             	cmp    $0x1,%eax
  8011a8:	75 21                	jne    8011cb <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011aa:	a1 04 40 80 00       	mov    0x804004,%eax
  8011af:	8b 40 48             	mov    0x48(%eax),%eax
  8011b2:	83 ec 04             	sub    $0x4,%esp
  8011b5:	53                   	push   %ebx
  8011b6:	50                   	push   %eax
  8011b7:	68 69 22 80 00       	push   $0x802269
  8011bc:	e8 d3 ef ff ff       	call   800194 <cprintf>
		return -E_INVAL;
  8011c1:	83 c4 10             	add    $0x10,%esp
  8011c4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011c9:	eb 26                	jmp    8011f1 <read+0x8a>
	}
	if (!dev->dev_read)
  8011cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011ce:	8b 40 08             	mov    0x8(%eax),%eax
  8011d1:	85 c0                	test   %eax,%eax
  8011d3:	74 17                	je     8011ec <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011d5:	83 ec 04             	sub    $0x4,%esp
  8011d8:	ff 75 10             	pushl  0x10(%ebp)
  8011db:	ff 75 0c             	pushl  0xc(%ebp)
  8011de:	52                   	push   %edx
  8011df:	ff d0                	call   *%eax
  8011e1:	89 c2                	mov    %eax,%edx
  8011e3:	83 c4 10             	add    $0x10,%esp
  8011e6:	eb 09                	jmp    8011f1 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011e8:	89 c2                	mov    %eax,%edx
  8011ea:	eb 05                	jmp    8011f1 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011ec:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8011f1:	89 d0                	mov    %edx,%eax
  8011f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011f6:	c9                   	leave  
  8011f7:	c3                   	ret    

008011f8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011f8:	55                   	push   %ebp
  8011f9:	89 e5                	mov    %esp,%ebp
  8011fb:	57                   	push   %edi
  8011fc:	56                   	push   %esi
  8011fd:	53                   	push   %ebx
  8011fe:	83 ec 0c             	sub    $0xc,%esp
  801201:	8b 7d 08             	mov    0x8(%ebp),%edi
  801204:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801207:	bb 00 00 00 00       	mov    $0x0,%ebx
  80120c:	eb 21                	jmp    80122f <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80120e:	83 ec 04             	sub    $0x4,%esp
  801211:	89 f0                	mov    %esi,%eax
  801213:	29 d8                	sub    %ebx,%eax
  801215:	50                   	push   %eax
  801216:	89 d8                	mov    %ebx,%eax
  801218:	03 45 0c             	add    0xc(%ebp),%eax
  80121b:	50                   	push   %eax
  80121c:	57                   	push   %edi
  80121d:	e8 45 ff ff ff       	call   801167 <read>
		if (m < 0)
  801222:	83 c4 10             	add    $0x10,%esp
  801225:	85 c0                	test   %eax,%eax
  801227:	78 10                	js     801239 <readn+0x41>
			return m;
		if (m == 0)
  801229:	85 c0                	test   %eax,%eax
  80122b:	74 0a                	je     801237 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80122d:	01 c3                	add    %eax,%ebx
  80122f:	39 f3                	cmp    %esi,%ebx
  801231:	72 db                	jb     80120e <readn+0x16>
  801233:	89 d8                	mov    %ebx,%eax
  801235:	eb 02                	jmp    801239 <readn+0x41>
  801237:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801239:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80123c:	5b                   	pop    %ebx
  80123d:	5e                   	pop    %esi
  80123e:	5f                   	pop    %edi
  80123f:	5d                   	pop    %ebp
  801240:	c3                   	ret    

00801241 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
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
  801250:	e8 ac fc ff ff       	call   800f01 <fd_lookup>
  801255:	83 c4 08             	add    $0x8,%esp
  801258:	89 c2                	mov    %eax,%edx
  80125a:	85 c0                	test   %eax,%eax
  80125c:	78 68                	js     8012c6 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80125e:	83 ec 08             	sub    $0x8,%esp
  801261:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801264:	50                   	push   %eax
  801265:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801268:	ff 30                	pushl  (%eax)
  80126a:	e8 e8 fc ff ff       	call   800f57 <dev_lookup>
  80126f:	83 c4 10             	add    $0x10,%esp
  801272:	85 c0                	test   %eax,%eax
  801274:	78 47                	js     8012bd <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801276:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801279:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80127d:	75 21                	jne    8012a0 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80127f:	a1 04 40 80 00       	mov    0x804004,%eax
  801284:	8b 40 48             	mov    0x48(%eax),%eax
  801287:	83 ec 04             	sub    $0x4,%esp
  80128a:	53                   	push   %ebx
  80128b:	50                   	push   %eax
  80128c:	68 85 22 80 00       	push   $0x802285
  801291:	e8 fe ee ff ff       	call   800194 <cprintf>
		return -E_INVAL;
  801296:	83 c4 10             	add    $0x10,%esp
  801299:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80129e:	eb 26                	jmp    8012c6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012a3:	8b 52 0c             	mov    0xc(%edx),%edx
  8012a6:	85 d2                	test   %edx,%edx
  8012a8:	74 17                	je     8012c1 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012aa:	83 ec 04             	sub    $0x4,%esp
  8012ad:	ff 75 10             	pushl  0x10(%ebp)
  8012b0:	ff 75 0c             	pushl  0xc(%ebp)
  8012b3:	50                   	push   %eax
  8012b4:	ff d2                	call   *%edx
  8012b6:	89 c2                	mov    %eax,%edx
  8012b8:	83 c4 10             	add    $0x10,%esp
  8012bb:	eb 09                	jmp    8012c6 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012bd:	89 c2                	mov    %eax,%edx
  8012bf:	eb 05                	jmp    8012c6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012c1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8012c6:	89 d0                	mov    %edx,%eax
  8012c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012cb:	c9                   	leave  
  8012cc:	c3                   	ret    

008012cd <seek>:

int
seek(int fdnum, off_t offset)
{
  8012cd:	55                   	push   %ebp
  8012ce:	89 e5                	mov    %esp,%ebp
  8012d0:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012d3:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012d6:	50                   	push   %eax
  8012d7:	ff 75 08             	pushl  0x8(%ebp)
  8012da:	e8 22 fc ff ff       	call   800f01 <fd_lookup>
  8012df:	83 c4 08             	add    $0x8,%esp
  8012e2:	85 c0                	test   %eax,%eax
  8012e4:	78 0e                	js     8012f4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ec:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012f4:	c9                   	leave  
  8012f5:	c3                   	ret    

008012f6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012f6:	55                   	push   %ebp
  8012f7:	89 e5                	mov    %esp,%ebp
  8012f9:	53                   	push   %ebx
  8012fa:	83 ec 14             	sub    $0x14,%esp
  8012fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801300:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801303:	50                   	push   %eax
  801304:	53                   	push   %ebx
  801305:	e8 f7 fb ff ff       	call   800f01 <fd_lookup>
  80130a:	83 c4 08             	add    $0x8,%esp
  80130d:	89 c2                	mov    %eax,%edx
  80130f:	85 c0                	test   %eax,%eax
  801311:	78 65                	js     801378 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801313:	83 ec 08             	sub    $0x8,%esp
  801316:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801319:	50                   	push   %eax
  80131a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80131d:	ff 30                	pushl  (%eax)
  80131f:	e8 33 fc ff ff       	call   800f57 <dev_lookup>
  801324:	83 c4 10             	add    $0x10,%esp
  801327:	85 c0                	test   %eax,%eax
  801329:	78 44                	js     80136f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80132b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80132e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801332:	75 21                	jne    801355 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801334:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801339:	8b 40 48             	mov    0x48(%eax),%eax
  80133c:	83 ec 04             	sub    $0x4,%esp
  80133f:	53                   	push   %ebx
  801340:	50                   	push   %eax
  801341:	68 48 22 80 00       	push   $0x802248
  801346:	e8 49 ee ff ff       	call   800194 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80134b:	83 c4 10             	add    $0x10,%esp
  80134e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801353:	eb 23                	jmp    801378 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801355:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801358:	8b 52 18             	mov    0x18(%edx),%edx
  80135b:	85 d2                	test   %edx,%edx
  80135d:	74 14                	je     801373 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80135f:	83 ec 08             	sub    $0x8,%esp
  801362:	ff 75 0c             	pushl  0xc(%ebp)
  801365:	50                   	push   %eax
  801366:	ff d2                	call   *%edx
  801368:	89 c2                	mov    %eax,%edx
  80136a:	83 c4 10             	add    $0x10,%esp
  80136d:	eb 09                	jmp    801378 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80136f:	89 c2                	mov    %eax,%edx
  801371:	eb 05                	jmp    801378 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801373:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801378:	89 d0                	mov    %edx,%eax
  80137a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80137d:	c9                   	leave  
  80137e:	c3                   	ret    

0080137f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80137f:	55                   	push   %ebp
  801380:	89 e5                	mov    %esp,%ebp
  801382:	53                   	push   %ebx
  801383:	83 ec 14             	sub    $0x14,%esp
  801386:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801389:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80138c:	50                   	push   %eax
  80138d:	ff 75 08             	pushl  0x8(%ebp)
  801390:	e8 6c fb ff ff       	call   800f01 <fd_lookup>
  801395:	83 c4 08             	add    $0x8,%esp
  801398:	89 c2                	mov    %eax,%edx
  80139a:	85 c0                	test   %eax,%eax
  80139c:	78 58                	js     8013f6 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80139e:	83 ec 08             	sub    $0x8,%esp
  8013a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a4:	50                   	push   %eax
  8013a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a8:	ff 30                	pushl  (%eax)
  8013aa:	e8 a8 fb ff ff       	call   800f57 <dev_lookup>
  8013af:	83 c4 10             	add    $0x10,%esp
  8013b2:	85 c0                	test   %eax,%eax
  8013b4:	78 37                	js     8013ed <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8013b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013b9:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013bd:	74 32                	je     8013f1 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013bf:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013c2:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013c9:	00 00 00 
	stat->st_isdir = 0;
  8013cc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013d3:	00 00 00 
	stat->st_dev = dev;
  8013d6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013dc:	83 ec 08             	sub    $0x8,%esp
  8013df:	53                   	push   %ebx
  8013e0:	ff 75 f0             	pushl  -0x10(%ebp)
  8013e3:	ff 50 14             	call   *0x14(%eax)
  8013e6:	89 c2                	mov    %eax,%edx
  8013e8:	83 c4 10             	add    $0x10,%esp
  8013eb:	eb 09                	jmp    8013f6 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ed:	89 c2                	mov    %eax,%edx
  8013ef:	eb 05                	jmp    8013f6 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013f1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013f6:	89 d0                	mov    %edx,%eax
  8013f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013fb:	c9                   	leave  
  8013fc:	c3                   	ret    

008013fd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013fd:	55                   	push   %ebp
  8013fe:	89 e5                	mov    %esp,%ebp
  801400:	56                   	push   %esi
  801401:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801402:	83 ec 08             	sub    $0x8,%esp
  801405:	6a 00                	push   $0x0
  801407:	ff 75 08             	pushl  0x8(%ebp)
  80140a:	e8 e3 01 00 00       	call   8015f2 <open>
  80140f:	89 c3                	mov    %eax,%ebx
  801411:	83 c4 10             	add    $0x10,%esp
  801414:	85 c0                	test   %eax,%eax
  801416:	78 1b                	js     801433 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801418:	83 ec 08             	sub    $0x8,%esp
  80141b:	ff 75 0c             	pushl  0xc(%ebp)
  80141e:	50                   	push   %eax
  80141f:	e8 5b ff ff ff       	call   80137f <fstat>
  801424:	89 c6                	mov    %eax,%esi
	close(fd);
  801426:	89 1c 24             	mov    %ebx,(%esp)
  801429:	e8 fd fb ff ff       	call   80102b <close>
	return r;
  80142e:	83 c4 10             	add    $0x10,%esp
  801431:	89 f0                	mov    %esi,%eax
}
  801433:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801436:	5b                   	pop    %ebx
  801437:	5e                   	pop    %esi
  801438:	5d                   	pop    %ebp
  801439:	c3                   	ret    

0080143a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80143a:	55                   	push   %ebp
  80143b:	89 e5                	mov    %esp,%ebp
  80143d:	56                   	push   %esi
  80143e:	53                   	push   %ebx
  80143f:	89 c6                	mov    %eax,%esi
  801441:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801443:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80144a:	75 12                	jne    80145e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80144c:	83 ec 0c             	sub    $0xc,%esp
  80144f:	6a 01                	push   $0x1
  801451:	e8 fc f9 ff ff       	call   800e52 <ipc_find_env>
  801456:	a3 00 40 80 00       	mov    %eax,0x804000
  80145b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80145e:	6a 07                	push   $0x7
  801460:	68 00 50 80 00       	push   $0x805000
  801465:	56                   	push   %esi
  801466:	ff 35 00 40 80 00    	pushl  0x804000
  80146c:	e8 8d f9 ff ff       	call   800dfe <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801471:	83 c4 0c             	add    $0xc,%esp
  801474:	6a 00                	push   $0x0
  801476:	53                   	push   %ebx
  801477:	6a 00                	push   $0x0
  801479:	e8 0e f9 ff ff       	call   800d8c <ipc_recv>
}
  80147e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801481:	5b                   	pop    %ebx
  801482:	5e                   	pop    %esi
  801483:	5d                   	pop    %ebp
  801484:	c3                   	ret    

00801485 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801485:	55                   	push   %ebp
  801486:	89 e5                	mov    %esp,%ebp
  801488:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80148b:	8b 45 08             	mov    0x8(%ebp),%eax
  80148e:	8b 40 0c             	mov    0xc(%eax),%eax
  801491:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801496:	8b 45 0c             	mov    0xc(%ebp),%eax
  801499:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80149e:	ba 00 00 00 00       	mov    $0x0,%edx
  8014a3:	b8 02 00 00 00       	mov    $0x2,%eax
  8014a8:	e8 8d ff ff ff       	call   80143a <fsipc>
}
  8014ad:	c9                   	leave  
  8014ae:	c3                   	ret    

008014af <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014af:	55                   	push   %ebp
  8014b0:	89 e5                	mov    %esp,%ebp
  8014b2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b8:	8b 40 0c             	mov    0xc(%eax),%eax
  8014bb:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c5:	b8 06 00 00 00       	mov    $0x6,%eax
  8014ca:	e8 6b ff ff ff       	call   80143a <fsipc>
}
  8014cf:	c9                   	leave  
  8014d0:	c3                   	ret    

008014d1 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014d1:	55                   	push   %ebp
  8014d2:	89 e5                	mov    %esp,%ebp
  8014d4:	53                   	push   %ebx
  8014d5:	83 ec 04             	sub    $0x4,%esp
  8014d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014db:	8b 45 08             	mov    0x8(%ebp),%eax
  8014de:	8b 40 0c             	mov    0xc(%eax),%eax
  8014e1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8014eb:	b8 05 00 00 00       	mov    $0x5,%eax
  8014f0:	e8 45 ff ff ff       	call   80143a <fsipc>
  8014f5:	85 c0                	test   %eax,%eax
  8014f7:	78 2c                	js     801525 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014f9:	83 ec 08             	sub    $0x8,%esp
  8014fc:	68 00 50 80 00       	push   $0x805000
  801501:	53                   	push   %ebx
  801502:	e8 91 f2 ff ff       	call   800798 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801507:	a1 80 50 80 00       	mov    0x805080,%eax
  80150c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801512:	a1 84 50 80 00       	mov    0x805084,%eax
  801517:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80151d:	83 c4 10             	add    $0x10,%esp
  801520:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801525:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801528:	c9                   	leave  
  801529:	c3                   	ret    

0080152a <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80152a:	55                   	push   %ebp
  80152b:	89 e5                	mov    %esp,%ebp
  80152d:	83 ec 0c             	sub    $0xc,%esp
  801530:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	
	int r;

	n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801533:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801538:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80153d:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801540:	8b 55 08             	mov    0x8(%ebp),%edx
  801543:	8b 52 0c             	mov    0xc(%edx),%edx
  801546:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80154c:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801551:	50                   	push   %eax
  801552:	ff 75 0c             	pushl  0xc(%ebp)
  801555:	68 08 50 80 00       	push   $0x805008
  80155a:	e8 cb f3 ff ff       	call   80092a <memmove>
	
	return fsipc(FSREQ_WRITE, NULL);	
  80155f:	ba 00 00 00 00       	mov    $0x0,%edx
  801564:	b8 04 00 00 00       	mov    $0x4,%eax
  801569:	e8 cc fe ff ff       	call   80143a <fsipc>
}
  80156e:	c9                   	leave  
  80156f:	c3                   	ret    

00801570 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801570:	55                   	push   %ebp
  801571:	89 e5                	mov    %esp,%ebp
  801573:	56                   	push   %esi
  801574:	53                   	push   %ebx
  801575:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801578:	8b 45 08             	mov    0x8(%ebp),%eax
  80157b:	8b 40 0c             	mov    0xc(%eax),%eax
  80157e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801583:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801589:	ba 00 00 00 00       	mov    $0x0,%edx
  80158e:	b8 03 00 00 00       	mov    $0x3,%eax
  801593:	e8 a2 fe ff ff       	call   80143a <fsipc>
  801598:	89 c3                	mov    %eax,%ebx
  80159a:	85 c0                	test   %eax,%eax
  80159c:	78 4b                	js     8015e9 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80159e:	39 c6                	cmp    %eax,%esi
  8015a0:	73 16                	jae    8015b8 <devfile_read+0x48>
  8015a2:	68 b4 22 80 00       	push   $0x8022b4
  8015a7:	68 bb 22 80 00       	push   $0x8022bb
  8015ac:	6a 7c                	push   $0x7c
  8015ae:	68 d0 22 80 00       	push   $0x8022d0
  8015b3:	e8 bd 05 00 00       	call   801b75 <_panic>
	assert(r <= PGSIZE);
  8015b8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015bd:	7e 16                	jle    8015d5 <devfile_read+0x65>
  8015bf:	68 db 22 80 00       	push   $0x8022db
  8015c4:	68 bb 22 80 00       	push   $0x8022bb
  8015c9:	6a 7d                	push   $0x7d
  8015cb:	68 d0 22 80 00       	push   $0x8022d0
  8015d0:	e8 a0 05 00 00       	call   801b75 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015d5:	83 ec 04             	sub    $0x4,%esp
  8015d8:	50                   	push   %eax
  8015d9:	68 00 50 80 00       	push   $0x805000
  8015de:	ff 75 0c             	pushl  0xc(%ebp)
  8015e1:	e8 44 f3 ff ff       	call   80092a <memmove>
	return r;
  8015e6:	83 c4 10             	add    $0x10,%esp
}
  8015e9:	89 d8                	mov    %ebx,%eax
  8015eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015ee:	5b                   	pop    %ebx
  8015ef:	5e                   	pop    %esi
  8015f0:	5d                   	pop    %ebp
  8015f1:	c3                   	ret    

008015f2 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015f2:	55                   	push   %ebp
  8015f3:	89 e5                	mov    %esp,%ebp
  8015f5:	53                   	push   %ebx
  8015f6:	83 ec 20             	sub    $0x20,%esp
  8015f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015fc:	53                   	push   %ebx
  8015fd:	e8 5d f1 ff ff       	call   80075f <strlen>
  801602:	83 c4 10             	add    $0x10,%esp
  801605:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80160a:	7f 67                	jg     801673 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80160c:	83 ec 0c             	sub    $0xc,%esp
  80160f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801612:	50                   	push   %eax
  801613:	e8 9a f8 ff ff       	call   800eb2 <fd_alloc>
  801618:	83 c4 10             	add    $0x10,%esp
		return r;
  80161b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80161d:	85 c0                	test   %eax,%eax
  80161f:	78 57                	js     801678 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801621:	83 ec 08             	sub    $0x8,%esp
  801624:	53                   	push   %ebx
  801625:	68 00 50 80 00       	push   $0x805000
  80162a:	e8 69 f1 ff ff       	call   800798 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80162f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801632:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801637:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80163a:	b8 01 00 00 00       	mov    $0x1,%eax
  80163f:	e8 f6 fd ff ff       	call   80143a <fsipc>
  801644:	89 c3                	mov    %eax,%ebx
  801646:	83 c4 10             	add    $0x10,%esp
  801649:	85 c0                	test   %eax,%eax
  80164b:	79 14                	jns    801661 <open+0x6f>
		fd_close(fd, 0);
  80164d:	83 ec 08             	sub    $0x8,%esp
  801650:	6a 00                	push   $0x0
  801652:	ff 75 f4             	pushl  -0xc(%ebp)
  801655:	e8 50 f9 ff ff       	call   800faa <fd_close>
		return r;
  80165a:	83 c4 10             	add    $0x10,%esp
  80165d:	89 da                	mov    %ebx,%edx
  80165f:	eb 17                	jmp    801678 <open+0x86>
	}

	return fd2num(fd);
  801661:	83 ec 0c             	sub    $0xc,%esp
  801664:	ff 75 f4             	pushl  -0xc(%ebp)
  801667:	e8 1f f8 ff ff       	call   800e8b <fd2num>
  80166c:	89 c2                	mov    %eax,%edx
  80166e:	83 c4 10             	add    $0x10,%esp
  801671:	eb 05                	jmp    801678 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801673:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801678:	89 d0                	mov    %edx,%eax
  80167a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80167d:	c9                   	leave  
  80167e:	c3                   	ret    

0080167f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80167f:	55                   	push   %ebp
  801680:	89 e5                	mov    %esp,%ebp
  801682:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801685:	ba 00 00 00 00       	mov    $0x0,%edx
  80168a:	b8 08 00 00 00       	mov    $0x8,%eax
  80168f:	e8 a6 fd ff ff       	call   80143a <fsipc>
}
  801694:	c9                   	leave  
  801695:	c3                   	ret    

00801696 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801696:	55                   	push   %ebp
  801697:	89 e5                	mov    %esp,%ebp
  801699:	56                   	push   %esi
  80169a:	53                   	push   %ebx
  80169b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80169e:	83 ec 0c             	sub    $0xc,%esp
  8016a1:	ff 75 08             	pushl  0x8(%ebp)
  8016a4:	e8 f2 f7 ff ff       	call   800e9b <fd2data>
  8016a9:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8016ab:	83 c4 08             	add    $0x8,%esp
  8016ae:	68 e7 22 80 00       	push   $0x8022e7
  8016b3:	53                   	push   %ebx
  8016b4:	e8 df f0 ff ff       	call   800798 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8016b9:	8b 46 04             	mov    0x4(%esi),%eax
  8016bc:	2b 06                	sub    (%esi),%eax
  8016be:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8016c4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016cb:	00 00 00 
	stat->st_dev = &devpipe;
  8016ce:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8016d5:	30 80 00 
	return 0;
}
  8016d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8016dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016e0:	5b                   	pop    %ebx
  8016e1:	5e                   	pop    %esi
  8016e2:	5d                   	pop    %ebp
  8016e3:	c3                   	ret    

008016e4 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8016e4:	55                   	push   %ebp
  8016e5:	89 e5                	mov    %esp,%ebp
  8016e7:	53                   	push   %ebx
  8016e8:	83 ec 0c             	sub    $0xc,%esp
  8016eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8016ee:	53                   	push   %ebx
  8016ef:	6a 00                	push   $0x0
  8016f1:	e8 2a f5 ff ff       	call   800c20 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8016f6:	89 1c 24             	mov    %ebx,(%esp)
  8016f9:	e8 9d f7 ff ff       	call   800e9b <fd2data>
  8016fe:	83 c4 08             	add    $0x8,%esp
  801701:	50                   	push   %eax
  801702:	6a 00                	push   $0x0
  801704:	e8 17 f5 ff ff       	call   800c20 <sys_page_unmap>
}
  801709:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80170c:	c9                   	leave  
  80170d:	c3                   	ret    

0080170e <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80170e:	55                   	push   %ebp
  80170f:	89 e5                	mov    %esp,%ebp
  801711:	57                   	push   %edi
  801712:	56                   	push   %esi
  801713:	53                   	push   %ebx
  801714:	83 ec 1c             	sub    $0x1c,%esp
  801717:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80171a:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80171c:	a1 04 40 80 00       	mov    0x804004,%eax
  801721:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801724:	83 ec 0c             	sub    $0xc,%esp
  801727:	ff 75 e0             	pushl  -0x20(%ebp)
  80172a:	e8 8c 04 00 00       	call   801bbb <pageref>
  80172f:	89 c3                	mov    %eax,%ebx
  801731:	89 3c 24             	mov    %edi,(%esp)
  801734:	e8 82 04 00 00       	call   801bbb <pageref>
  801739:	83 c4 10             	add    $0x10,%esp
  80173c:	39 c3                	cmp    %eax,%ebx
  80173e:	0f 94 c1             	sete   %cl
  801741:	0f b6 c9             	movzbl %cl,%ecx
  801744:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801747:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80174d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801750:	39 ce                	cmp    %ecx,%esi
  801752:	74 1b                	je     80176f <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801754:	39 c3                	cmp    %eax,%ebx
  801756:	75 c4                	jne    80171c <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801758:	8b 42 58             	mov    0x58(%edx),%eax
  80175b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80175e:	50                   	push   %eax
  80175f:	56                   	push   %esi
  801760:	68 ee 22 80 00       	push   $0x8022ee
  801765:	e8 2a ea ff ff       	call   800194 <cprintf>
  80176a:	83 c4 10             	add    $0x10,%esp
  80176d:	eb ad                	jmp    80171c <_pipeisclosed+0xe>
	}
}
  80176f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801772:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801775:	5b                   	pop    %ebx
  801776:	5e                   	pop    %esi
  801777:	5f                   	pop    %edi
  801778:	5d                   	pop    %ebp
  801779:	c3                   	ret    

0080177a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80177a:	55                   	push   %ebp
  80177b:	89 e5                	mov    %esp,%ebp
  80177d:	57                   	push   %edi
  80177e:	56                   	push   %esi
  80177f:	53                   	push   %ebx
  801780:	83 ec 28             	sub    $0x28,%esp
  801783:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801786:	56                   	push   %esi
  801787:	e8 0f f7 ff ff       	call   800e9b <fd2data>
  80178c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80178e:	83 c4 10             	add    $0x10,%esp
  801791:	bf 00 00 00 00       	mov    $0x0,%edi
  801796:	eb 4b                	jmp    8017e3 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801798:	89 da                	mov    %ebx,%edx
  80179a:	89 f0                	mov    %esi,%eax
  80179c:	e8 6d ff ff ff       	call   80170e <_pipeisclosed>
  8017a1:	85 c0                	test   %eax,%eax
  8017a3:	75 48                	jne    8017ed <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8017a5:	e8 d2 f3 ff ff       	call   800b7c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8017aa:	8b 43 04             	mov    0x4(%ebx),%eax
  8017ad:	8b 0b                	mov    (%ebx),%ecx
  8017af:	8d 51 20             	lea    0x20(%ecx),%edx
  8017b2:	39 d0                	cmp    %edx,%eax
  8017b4:	73 e2                	jae    801798 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8017b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017b9:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8017bd:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8017c0:	89 c2                	mov    %eax,%edx
  8017c2:	c1 fa 1f             	sar    $0x1f,%edx
  8017c5:	89 d1                	mov    %edx,%ecx
  8017c7:	c1 e9 1b             	shr    $0x1b,%ecx
  8017ca:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8017cd:	83 e2 1f             	and    $0x1f,%edx
  8017d0:	29 ca                	sub    %ecx,%edx
  8017d2:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8017d6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8017da:	83 c0 01             	add    $0x1,%eax
  8017dd:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017e0:	83 c7 01             	add    $0x1,%edi
  8017e3:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8017e6:	75 c2                	jne    8017aa <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8017e8:	8b 45 10             	mov    0x10(%ebp),%eax
  8017eb:	eb 05                	jmp    8017f2 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017ed:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8017f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017f5:	5b                   	pop    %ebx
  8017f6:	5e                   	pop    %esi
  8017f7:	5f                   	pop    %edi
  8017f8:	5d                   	pop    %ebp
  8017f9:	c3                   	ret    

008017fa <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8017fa:	55                   	push   %ebp
  8017fb:	89 e5                	mov    %esp,%ebp
  8017fd:	57                   	push   %edi
  8017fe:	56                   	push   %esi
  8017ff:	53                   	push   %ebx
  801800:	83 ec 18             	sub    $0x18,%esp
  801803:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801806:	57                   	push   %edi
  801807:	e8 8f f6 ff ff       	call   800e9b <fd2data>
  80180c:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80180e:	83 c4 10             	add    $0x10,%esp
  801811:	bb 00 00 00 00       	mov    $0x0,%ebx
  801816:	eb 3d                	jmp    801855 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801818:	85 db                	test   %ebx,%ebx
  80181a:	74 04                	je     801820 <devpipe_read+0x26>
				return i;
  80181c:	89 d8                	mov    %ebx,%eax
  80181e:	eb 44                	jmp    801864 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801820:	89 f2                	mov    %esi,%edx
  801822:	89 f8                	mov    %edi,%eax
  801824:	e8 e5 fe ff ff       	call   80170e <_pipeisclosed>
  801829:	85 c0                	test   %eax,%eax
  80182b:	75 32                	jne    80185f <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80182d:	e8 4a f3 ff ff       	call   800b7c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801832:	8b 06                	mov    (%esi),%eax
  801834:	3b 46 04             	cmp    0x4(%esi),%eax
  801837:	74 df                	je     801818 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801839:	99                   	cltd   
  80183a:	c1 ea 1b             	shr    $0x1b,%edx
  80183d:	01 d0                	add    %edx,%eax
  80183f:	83 e0 1f             	and    $0x1f,%eax
  801842:	29 d0                	sub    %edx,%eax
  801844:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801849:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80184c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80184f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801852:	83 c3 01             	add    $0x1,%ebx
  801855:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801858:	75 d8                	jne    801832 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80185a:	8b 45 10             	mov    0x10(%ebp),%eax
  80185d:	eb 05                	jmp    801864 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80185f:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801864:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801867:	5b                   	pop    %ebx
  801868:	5e                   	pop    %esi
  801869:	5f                   	pop    %edi
  80186a:	5d                   	pop    %ebp
  80186b:	c3                   	ret    

0080186c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80186c:	55                   	push   %ebp
  80186d:	89 e5                	mov    %esp,%ebp
  80186f:	56                   	push   %esi
  801870:	53                   	push   %ebx
  801871:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801874:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801877:	50                   	push   %eax
  801878:	e8 35 f6 ff ff       	call   800eb2 <fd_alloc>
  80187d:	83 c4 10             	add    $0x10,%esp
  801880:	89 c2                	mov    %eax,%edx
  801882:	85 c0                	test   %eax,%eax
  801884:	0f 88 2c 01 00 00    	js     8019b6 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80188a:	83 ec 04             	sub    $0x4,%esp
  80188d:	68 07 04 00 00       	push   $0x407
  801892:	ff 75 f4             	pushl  -0xc(%ebp)
  801895:	6a 00                	push   $0x0
  801897:	e8 ff f2 ff ff       	call   800b9b <sys_page_alloc>
  80189c:	83 c4 10             	add    $0x10,%esp
  80189f:	89 c2                	mov    %eax,%edx
  8018a1:	85 c0                	test   %eax,%eax
  8018a3:	0f 88 0d 01 00 00    	js     8019b6 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8018a9:	83 ec 0c             	sub    $0xc,%esp
  8018ac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018af:	50                   	push   %eax
  8018b0:	e8 fd f5 ff ff       	call   800eb2 <fd_alloc>
  8018b5:	89 c3                	mov    %eax,%ebx
  8018b7:	83 c4 10             	add    $0x10,%esp
  8018ba:	85 c0                	test   %eax,%eax
  8018bc:	0f 88 e2 00 00 00    	js     8019a4 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018c2:	83 ec 04             	sub    $0x4,%esp
  8018c5:	68 07 04 00 00       	push   $0x407
  8018ca:	ff 75 f0             	pushl  -0x10(%ebp)
  8018cd:	6a 00                	push   $0x0
  8018cf:	e8 c7 f2 ff ff       	call   800b9b <sys_page_alloc>
  8018d4:	89 c3                	mov    %eax,%ebx
  8018d6:	83 c4 10             	add    $0x10,%esp
  8018d9:	85 c0                	test   %eax,%eax
  8018db:	0f 88 c3 00 00 00    	js     8019a4 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8018e1:	83 ec 0c             	sub    $0xc,%esp
  8018e4:	ff 75 f4             	pushl  -0xc(%ebp)
  8018e7:	e8 af f5 ff ff       	call   800e9b <fd2data>
  8018ec:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018ee:	83 c4 0c             	add    $0xc,%esp
  8018f1:	68 07 04 00 00       	push   $0x407
  8018f6:	50                   	push   %eax
  8018f7:	6a 00                	push   $0x0
  8018f9:	e8 9d f2 ff ff       	call   800b9b <sys_page_alloc>
  8018fe:	89 c3                	mov    %eax,%ebx
  801900:	83 c4 10             	add    $0x10,%esp
  801903:	85 c0                	test   %eax,%eax
  801905:	0f 88 89 00 00 00    	js     801994 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80190b:	83 ec 0c             	sub    $0xc,%esp
  80190e:	ff 75 f0             	pushl  -0x10(%ebp)
  801911:	e8 85 f5 ff ff       	call   800e9b <fd2data>
  801916:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80191d:	50                   	push   %eax
  80191e:	6a 00                	push   $0x0
  801920:	56                   	push   %esi
  801921:	6a 00                	push   $0x0
  801923:	e8 b6 f2 ff ff       	call   800bde <sys_page_map>
  801928:	89 c3                	mov    %eax,%ebx
  80192a:	83 c4 20             	add    $0x20,%esp
  80192d:	85 c0                	test   %eax,%eax
  80192f:	78 55                	js     801986 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801931:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801937:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80193a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80193c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80193f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801946:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80194c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80194f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801951:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801954:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80195b:	83 ec 0c             	sub    $0xc,%esp
  80195e:	ff 75 f4             	pushl  -0xc(%ebp)
  801961:	e8 25 f5 ff ff       	call   800e8b <fd2num>
  801966:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801969:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80196b:	83 c4 04             	add    $0x4,%esp
  80196e:	ff 75 f0             	pushl  -0x10(%ebp)
  801971:	e8 15 f5 ff ff       	call   800e8b <fd2num>
  801976:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801979:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80197c:	83 c4 10             	add    $0x10,%esp
  80197f:	ba 00 00 00 00       	mov    $0x0,%edx
  801984:	eb 30                	jmp    8019b6 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801986:	83 ec 08             	sub    $0x8,%esp
  801989:	56                   	push   %esi
  80198a:	6a 00                	push   $0x0
  80198c:	e8 8f f2 ff ff       	call   800c20 <sys_page_unmap>
  801991:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801994:	83 ec 08             	sub    $0x8,%esp
  801997:	ff 75 f0             	pushl  -0x10(%ebp)
  80199a:	6a 00                	push   $0x0
  80199c:	e8 7f f2 ff ff       	call   800c20 <sys_page_unmap>
  8019a1:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8019a4:	83 ec 08             	sub    $0x8,%esp
  8019a7:	ff 75 f4             	pushl  -0xc(%ebp)
  8019aa:	6a 00                	push   $0x0
  8019ac:	e8 6f f2 ff ff       	call   800c20 <sys_page_unmap>
  8019b1:	83 c4 10             	add    $0x10,%esp
  8019b4:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8019b6:	89 d0                	mov    %edx,%eax
  8019b8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019bb:	5b                   	pop    %ebx
  8019bc:	5e                   	pop    %esi
  8019bd:	5d                   	pop    %ebp
  8019be:	c3                   	ret    

008019bf <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8019bf:	55                   	push   %ebp
  8019c0:	89 e5                	mov    %esp,%ebp
  8019c2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019c8:	50                   	push   %eax
  8019c9:	ff 75 08             	pushl  0x8(%ebp)
  8019cc:	e8 30 f5 ff ff       	call   800f01 <fd_lookup>
  8019d1:	83 c4 10             	add    $0x10,%esp
  8019d4:	85 c0                	test   %eax,%eax
  8019d6:	78 18                	js     8019f0 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8019d8:	83 ec 0c             	sub    $0xc,%esp
  8019db:	ff 75 f4             	pushl  -0xc(%ebp)
  8019de:	e8 b8 f4 ff ff       	call   800e9b <fd2data>
	return _pipeisclosed(fd, p);
  8019e3:	89 c2                	mov    %eax,%edx
  8019e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019e8:	e8 21 fd ff ff       	call   80170e <_pipeisclosed>
  8019ed:	83 c4 10             	add    $0x10,%esp
}
  8019f0:	c9                   	leave  
  8019f1:	c3                   	ret    

008019f2 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8019f2:	55                   	push   %ebp
  8019f3:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8019f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8019fa:	5d                   	pop    %ebp
  8019fb:	c3                   	ret    

008019fc <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8019fc:	55                   	push   %ebp
  8019fd:	89 e5                	mov    %esp,%ebp
  8019ff:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801a02:	68 06 23 80 00       	push   $0x802306
  801a07:	ff 75 0c             	pushl  0xc(%ebp)
  801a0a:	e8 89 ed ff ff       	call   800798 <strcpy>
	return 0;
}
  801a0f:	b8 00 00 00 00       	mov    $0x0,%eax
  801a14:	c9                   	leave  
  801a15:	c3                   	ret    

00801a16 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a16:	55                   	push   %ebp
  801a17:	89 e5                	mov    %esp,%ebp
  801a19:	57                   	push   %edi
  801a1a:	56                   	push   %esi
  801a1b:	53                   	push   %ebx
  801a1c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a22:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a27:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a2d:	eb 2d                	jmp    801a5c <devcons_write+0x46>
		m = n - tot;
  801a2f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a32:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801a34:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801a37:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801a3c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a3f:	83 ec 04             	sub    $0x4,%esp
  801a42:	53                   	push   %ebx
  801a43:	03 45 0c             	add    0xc(%ebp),%eax
  801a46:	50                   	push   %eax
  801a47:	57                   	push   %edi
  801a48:	e8 dd ee ff ff       	call   80092a <memmove>
		sys_cputs(buf, m);
  801a4d:	83 c4 08             	add    $0x8,%esp
  801a50:	53                   	push   %ebx
  801a51:	57                   	push   %edi
  801a52:	e8 88 f0 ff ff       	call   800adf <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a57:	01 de                	add    %ebx,%esi
  801a59:	83 c4 10             	add    $0x10,%esp
  801a5c:	89 f0                	mov    %esi,%eax
  801a5e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a61:	72 cc                	jb     801a2f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a66:	5b                   	pop    %ebx
  801a67:	5e                   	pop    %esi
  801a68:	5f                   	pop    %edi
  801a69:	5d                   	pop    %ebp
  801a6a:	c3                   	ret    

00801a6b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a6b:	55                   	push   %ebp
  801a6c:	89 e5                	mov    %esp,%ebp
  801a6e:	83 ec 08             	sub    $0x8,%esp
  801a71:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801a76:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a7a:	74 2a                	je     801aa6 <devcons_read+0x3b>
  801a7c:	eb 05                	jmp    801a83 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a7e:	e8 f9 f0 ff ff       	call   800b7c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a83:	e8 75 f0 ff ff       	call   800afd <sys_cgetc>
  801a88:	85 c0                	test   %eax,%eax
  801a8a:	74 f2                	je     801a7e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801a8c:	85 c0                	test   %eax,%eax
  801a8e:	78 16                	js     801aa6 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a90:	83 f8 04             	cmp    $0x4,%eax
  801a93:	74 0c                	je     801aa1 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801a95:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a98:	88 02                	mov    %al,(%edx)
	return 1;
  801a9a:	b8 01 00 00 00       	mov    $0x1,%eax
  801a9f:	eb 05                	jmp    801aa6 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801aa1:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801aa6:	c9                   	leave  
  801aa7:	c3                   	ret    

00801aa8 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801aa8:	55                   	push   %ebp
  801aa9:	89 e5                	mov    %esp,%ebp
  801aab:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801aae:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab1:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ab4:	6a 01                	push   $0x1
  801ab6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ab9:	50                   	push   %eax
  801aba:	e8 20 f0 ff ff       	call   800adf <sys_cputs>
}
  801abf:	83 c4 10             	add    $0x10,%esp
  801ac2:	c9                   	leave  
  801ac3:	c3                   	ret    

00801ac4 <getchar>:

int
getchar(void)
{
  801ac4:	55                   	push   %ebp
  801ac5:	89 e5                	mov    %esp,%ebp
  801ac7:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801aca:	6a 01                	push   $0x1
  801acc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801acf:	50                   	push   %eax
  801ad0:	6a 00                	push   $0x0
  801ad2:	e8 90 f6 ff ff       	call   801167 <read>
	if (r < 0)
  801ad7:	83 c4 10             	add    $0x10,%esp
  801ada:	85 c0                	test   %eax,%eax
  801adc:	78 0f                	js     801aed <getchar+0x29>
		return r;
	if (r < 1)
  801ade:	85 c0                	test   %eax,%eax
  801ae0:	7e 06                	jle    801ae8 <getchar+0x24>
		return -E_EOF;
	return c;
  801ae2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ae6:	eb 05                	jmp    801aed <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ae8:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801aed:	c9                   	leave  
  801aee:	c3                   	ret    

00801aef <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801aef:	55                   	push   %ebp
  801af0:	89 e5                	mov    %esp,%ebp
  801af2:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801af5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801af8:	50                   	push   %eax
  801af9:	ff 75 08             	pushl  0x8(%ebp)
  801afc:	e8 00 f4 ff ff       	call   800f01 <fd_lookup>
  801b01:	83 c4 10             	add    $0x10,%esp
  801b04:	85 c0                	test   %eax,%eax
  801b06:	78 11                	js     801b19 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801b08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b0b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b11:	39 10                	cmp    %edx,(%eax)
  801b13:	0f 94 c0             	sete   %al
  801b16:	0f b6 c0             	movzbl %al,%eax
}
  801b19:	c9                   	leave  
  801b1a:	c3                   	ret    

00801b1b <opencons>:

int
opencons(void)
{
  801b1b:	55                   	push   %ebp
  801b1c:	89 e5                	mov    %esp,%ebp
  801b1e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b21:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b24:	50                   	push   %eax
  801b25:	e8 88 f3 ff ff       	call   800eb2 <fd_alloc>
  801b2a:	83 c4 10             	add    $0x10,%esp
		return r;
  801b2d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b2f:	85 c0                	test   %eax,%eax
  801b31:	78 3e                	js     801b71 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b33:	83 ec 04             	sub    $0x4,%esp
  801b36:	68 07 04 00 00       	push   $0x407
  801b3b:	ff 75 f4             	pushl  -0xc(%ebp)
  801b3e:	6a 00                	push   $0x0
  801b40:	e8 56 f0 ff ff       	call   800b9b <sys_page_alloc>
  801b45:	83 c4 10             	add    $0x10,%esp
		return r;
  801b48:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b4a:	85 c0                	test   %eax,%eax
  801b4c:	78 23                	js     801b71 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801b4e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b57:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b5c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b63:	83 ec 0c             	sub    $0xc,%esp
  801b66:	50                   	push   %eax
  801b67:	e8 1f f3 ff ff       	call   800e8b <fd2num>
  801b6c:	89 c2                	mov    %eax,%edx
  801b6e:	83 c4 10             	add    $0x10,%esp
}
  801b71:	89 d0                	mov    %edx,%eax
  801b73:	c9                   	leave  
  801b74:	c3                   	ret    

00801b75 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801b75:	55                   	push   %ebp
  801b76:	89 e5                	mov    %esp,%ebp
  801b78:	56                   	push   %esi
  801b79:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801b7a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801b7d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801b83:	e8 d5 ef ff ff       	call   800b5d <sys_getenvid>
  801b88:	83 ec 0c             	sub    $0xc,%esp
  801b8b:	ff 75 0c             	pushl  0xc(%ebp)
  801b8e:	ff 75 08             	pushl  0x8(%ebp)
  801b91:	56                   	push   %esi
  801b92:	50                   	push   %eax
  801b93:	68 14 23 80 00       	push   $0x802314
  801b98:	e8 f7 e5 ff ff       	call   800194 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b9d:	83 c4 18             	add    $0x18,%esp
  801ba0:	53                   	push   %ebx
  801ba1:	ff 75 10             	pushl  0x10(%ebp)
  801ba4:	e8 9a e5 ff ff       	call   800143 <vcprintf>
	cprintf("\n");
  801ba9:	c7 04 24 ff 22 80 00 	movl   $0x8022ff,(%esp)
  801bb0:	e8 df e5 ff ff       	call   800194 <cprintf>
  801bb5:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801bb8:	cc                   	int3   
  801bb9:	eb fd                	jmp    801bb8 <_panic+0x43>

00801bbb <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801bbb:	55                   	push   %ebp
  801bbc:	89 e5                	mov    %esp,%ebp
  801bbe:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bc1:	89 d0                	mov    %edx,%eax
  801bc3:	c1 e8 16             	shr    $0x16,%eax
  801bc6:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801bcd:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bd2:	f6 c1 01             	test   $0x1,%cl
  801bd5:	74 1d                	je     801bf4 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801bd7:	c1 ea 0c             	shr    $0xc,%edx
  801bda:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801be1:	f6 c2 01             	test   $0x1,%dl
  801be4:	74 0e                	je     801bf4 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801be6:	c1 ea 0c             	shr    $0xc,%edx
  801be9:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801bf0:	ef 
  801bf1:	0f b7 c0             	movzwl %ax,%eax
}
  801bf4:	5d                   	pop    %ebp
  801bf5:	c3                   	ret    
  801bf6:	66 90                	xchg   %ax,%ax
  801bf8:	66 90                	xchg   %ax,%ax
  801bfa:	66 90                	xchg   %ax,%ax
  801bfc:	66 90                	xchg   %ax,%ax
  801bfe:	66 90                	xchg   %ax,%ax

00801c00 <__udivdi3>:
  801c00:	55                   	push   %ebp
  801c01:	57                   	push   %edi
  801c02:	56                   	push   %esi
  801c03:	53                   	push   %ebx
  801c04:	83 ec 1c             	sub    $0x1c,%esp
  801c07:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801c0b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c0f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801c13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c17:	85 f6                	test   %esi,%esi
  801c19:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c1d:	89 ca                	mov    %ecx,%edx
  801c1f:	89 f8                	mov    %edi,%eax
  801c21:	75 3d                	jne    801c60 <__udivdi3+0x60>
  801c23:	39 cf                	cmp    %ecx,%edi
  801c25:	0f 87 c5 00 00 00    	ja     801cf0 <__udivdi3+0xf0>
  801c2b:	85 ff                	test   %edi,%edi
  801c2d:	89 fd                	mov    %edi,%ebp
  801c2f:	75 0b                	jne    801c3c <__udivdi3+0x3c>
  801c31:	b8 01 00 00 00       	mov    $0x1,%eax
  801c36:	31 d2                	xor    %edx,%edx
  801c38:	f7 f7                	div    %edi
  801c3a:	89 c5                	mov    %eax,%ebp
  801c3c:	89 c8                	mov    %ecx,%eax
  801c3e:	31 d2                	xor    %edx,%edx
  801c40:	f7 f5                	div    %ebp
  801c42:	89 c1                	mov    %eax,%ecx
  801c44:	89 d8                	mov    %ebx,%eax
  801c46:	89 cf                	mov    %ecx,%edi
  801c48:	f7 f5                	div    %ebp
  801c4a:	89 c3                	mov    %eax,%ebx
  801c4c:	89 d8                	mov    %ebx,%eax
  801c4e:	89 fa                	mov    %edi,%edx
  801c50:	83 c4 1c             	add    $0x1c,%esp
  801c53:	5b                   	pop    %ebx
  801c54:	5e                   	pop    %esi
  801c55:	5f                   	pop    %edi
  801c56:	5d                   	pop    %ebp
  801c57:	c3                   	ret    
  801c58:	90                   	nop
  801c59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c60:	39 ce                	cmp    %ecx,%esi
  801c62:	77 74                	ja     801cd8 <__udivdi3+0xd8>
  801c64:	0f bd fe             	bsr    %esi,%edi
  801c67:	83 f7 1f             	xor    $0x1f,%edi
  801c6a:	0f 84 98 00 00 00    	je     801d08 <__udivdi3+0x108>
  801c70:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c75:	89 f9                	mov    %edi,%ecx
  801c77:	89 c5                	mov    %eax,%ebp
  801c79:	29 fb                	sub    %edi,%ebx
  801c7b:	d3 e6                	shl    %cl,%esi
  801c7d:	89 d9                	mov    %ebx,%ecx
  801c7f:	d3 ed                	shr    %cl,%ebp
  801c81:	89 f9                	mov    %edi,%ecx
  801c83:	d3 e0                	shl    %cl,%eax
  801c85:	09 ee                	or     %ebp,%esi
  801c87:	89 d9                	mov    %ebx,%ecx
  801c89:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c8d:	89 d5                	mov    %edx,%ebp
  801c8f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c93:	d3 ed                	shr    %cl,%ebp
  801c95:	89 f9                	mov    %edi,%ecx
  801c97:	d3 e2                	shl    %cl,%edx
  801c99:	89 d9                	mov    %ebx,%ecx
  801c9b:	d3 e8                	shr    %cl,%eax
  801c9d:	09 c2                	or     %eax,%edx
  801c9f:	89 d0                	mov    %edx,%eax
  801ca1:	89 ea                	mov    %ebp,%edx
  801ca3:	f7 f6                	div    %esi
  801ca5:	89 d5                	mov    %edx,%ebp
  801ca7:	89 c3                	mov    %eax,%ebx
  801ca9:	f7 64 24 0c          	mull   0xc(%esp)
  801cad:	39 d5                	cmp    %edx,%ebp
  801caf:	72 10                	jb     801cc1 <__udivdi3+0xc1>
  801cb1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801cb5:	89 f9                	mov    %edi,%ecx
  801cb7:	d3 e6                	shl    %cl,%esi
  801cb9:	39 c6                	cmp    %eax,%esi
  801cbb:	73 07                	jae    801cc4 <__udivdi3+0xc4>
  801cbd:	39 d5                	cmp    %edx,%ebp
  801cbf:	75 03                	jne    801cc4 <__udivdi3+0xc4>
  801cc1:	83 eb 01             	sub    $0x1,%ebx
  801cc4:	31 ff                	xor    %edi,%edi
  801cc6:	89 d8                	mov    %ebx,%eax
  801cc8:	89 fa                	mov    %edi,%edx
  801cca:	83 c4 1c             	add    $0x1c,%esp
  801ccd:	5b                   	pop    %ebx
  801cce:	5e                   	pop    %esi
  801ccf:	5f                   	pop    %edi
  801cd0:	5d                   	pop    %ebp
  801cd1:	c3                   	ret    
  801cd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cd8:	31 ff                	xor    %edi,%edi
  801cda:	31 db                	xor    %ebx,%ebx
  801cdc:	89 d8                	mov    %ebx,%eax
  801cde:	89 fa                	mov    %edi,%edx
  801ce0:	83 c4 1c             	add    $0x1c,%esp
  801ce3:	5b                   	pop    %ebx
  801ce4:	5e                   	pop    %esi
  801ce5:	5f                   	pop    %edi
  801ce6:	5d                   	pop    %ebp
  801ce7:	c3                   	ret    
  801ce8:	90                   	nop
  801ce9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cf0:	89 d8                	mov    %ebx,%eax
  801cf2:	f7 f7                	div    %edi
  801cf4:	31 ff                	xor    %edi,%edi
  801cf6:	89 c3                	mov    %eax,%ebx
  801cf8:	89 d8                	mov    %ebx,%eax
  801cfa:	89 fa                	mov    %edi,%edx
  801cfc:	83 c4 1c             	add    $0x1c,%esp
  801cff:	5b                   	pop    %ebx
  801d00:	5e                   	pop    %esi
  801d01:	5f                   	pop    %edi
  801d02:	5d                   	pop    %ebp
  801d03:	c3                   	ret    
  801d04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d08:	39 ce                	cmp    %ecx,%esi
  801d0a:	72 0c                	jb     801d18 <__udivdi3+0x118>
  801d0c:	31 db                	xor    %ebx,%ebx
  801d0e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801d12:	0f 87 34 ff ff ff    	ja     801c4c <__udivdi3+0x4c>
  801d18:	bb 01 00 00 00       	mov    $0x1,%ebx
  801d1d:	e9 2a ff ff ff       	jmp    801c4c <__udivdi3+0x4c>
  801d22:	66 90                	xchg   %ax,%ax
  801d24:	66 90                	xchg   %ax,%ax
  801d26:	66 90                	xchg   %ax,%ax
  801d28:	66 90                	xchg   %ax,%ax
  801d2a:	66 90                	xchg   %ax,%ax
  801d2c:	66 90                	xchg   %ax,%ax
  801d2e:	66 90                	xchg   %ax,%ax

00801d30 <__umoddi3>:
  801d30:	55                   	push   %ebp
  801d31:	57                   	push   %edi
  801d32:	56                   	push   %esi
  801d33:	53                   	push   %ebx
  801d34:	83 ec 1c             	sub    $0x1c,%esp
  801d37:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d3b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d3f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d47:	85 d2                	test   %edx,%edx
  801d49:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d4d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d51:	89 f3                	mov    %esi,%ebx
  801d53:	89 3c 24             	mov    %edi,(%esp)
  801d56:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d5a:	75 1c                	jne    801d78 <__umoddi3+0x48>
  801d5c:	39 f7                	cmp    %esi,%edi
  801d5e:	76 50                	jbe    801db0 <__umoddi3+0x80>
  801d60:	89 c8                	mov    %ecx,%eax
  801d62:	89 f2                	mov    %esi,%edx
  801d64:	f7 f7                	div    %edi
  801d66:	89 d0                	mov    %edx,%eax
  801d68:	31 d2                	xor    %edx,%edx
  801d6a:	83 c4 1c             	add    $0x1c,%esp
  801d6d:	5b                   	pop    %ebx
  801d6e:	5e                   	pop    %esi
  801d6f:	5f                   	pop    %edi
  801d70:	5d                   	pop    %ebp
  801d71:	c3                   	ret    
  801d72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d78:	39 f2                	cmp    %esi,%edx
  801d7a:	89 d0                	mov    %edx,%eax
  801d7c:	77 52                	ja     801dd0 <__umoddi3+0xa0>
  801d7e:	0f bd ea             	bsr    %edx,%ebp
  801d81:	83 f5 1f             	xor    $0x1f,%ebp
  801d84:	75 5a                	jne    801de0 <__umoddi3+0xb0>
  801d86:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d8a:	0f 82 e0 00 00 00    	jb     801e70 <__umoddi3+0x140>
  801d90:	39 0c 24             	cmp    %ecx,(%esp)
  801d93:	0f 86 d7 00 00 00    	jbe    801e70 <__umoddi3+0x140>
  801d99:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d9d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801da1:	83 c4 1c             	add    $0x1c,%esp
  801da4:	5b                   	pop    %ebx
  801da5:	5e                   	pop    %esi
  801da6:	5f                   	pop    %edi
  801da7:	5d                   	pop    %ebp
  801da8:	c3                   	ret    
  801da9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801db0:	85 ff                	test   %edi,%edi
  801db2:	89 fd                	mov    %edi,%ebp
  801db4:	75 0b                	jne    801dc1 <__umoddi3+0x91>
  801db6:	b8 01 00 00 00       	mov    $0x1,%eax
  801dbb:	31 d2                	xor    %edx,%edx
  801dbd:	f7 f7                	div    %edi
  801dbf:	89 c5                	mov    %eax,%ebp
  801dc1:	89 f0                	mov    %esi,%eax
  801dc3:	31 d2                	xor    %edx,%edx
  801dc5:	f7 f5                	div    %ebp
  801dc7:	89 c8                	mov    %ecx,%eax
  801dc9:	f7 f5                	div    %ebp
  801dcb:	89 d0                	mov    %edx,%eax
  801dcd:	eb 99                	jmp    801d68 <__umoddi3+0x38>
  801dcf:	90                   	nop
  801dd0:	89 c8                	mov    %ecx,%eax
  801dd2:	89 f2                	mov    %esi,%edx
  801dd4:	83 c4 1c             	add    $0x1c,%esp
  801dd7:	5b                   	pop    %ebx
  801dd8:	5e                   	pop    %esi
  801dd9:	5f                   	pop    %edi
  801dda:	5d                   	pop    %ebp
  801ddb:	c3                   	ret    
  801ddc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801de0:	8b 34 24             	mov    (%esp),%esi
  801de3:	bf 20 00 00 00       	mov    $0x20,%edi
  801de8:	89 e9                	mov    %ebp,%ecx
  801dea:	29 ef                	sub    %ebp,%edi
  801dec:	d3 e0                	shl    %cl,%eax
  801dee:	89 f9                	mov    %edi,%ecx
  801df0:	89 f2                	mov    %esi,%edx
  801df2:	d3 ea                	shr    %cl,%edx
  801df4:	89 e9                	mov    %ebp,%ecx
  801df6:	09 c2                	or     %eax,%edx
  801df8:	89 d8                	mov    %ebx,%eax
  801dfa:	89 14 24             	mov    %edx,(%esp)
  801dfd:	89 f2                	mov    %esi,%edx
  801dff:	d3 e2                	shl    %cl,%edx
  801e01:	89 f9                	mov    %edi,%ecx
  801e03:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e07:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801e0b:	d3 e8                	shr    %cl,%eax
  801e0d:	89 e9                	mov    %ebp,%ecx
  801e0f:	89 c6                	mov    %eax,%esi
  801e11:	d3 e3                	shl    %cl,%ebx
  801e13:	89 f9                	mov    %edi,%ecx
  801e15:	89 d0                	mov    %edx,%eax
  801e17:	d3 e8                	shr    %cl,%eax
  801e19:	89 e9                	mov    %ebp,%ecx
  801e1b:	09 d8                	or     %ebx,%eax
  801e1d:	89 d3                	mov    %edx,%ebx
  801e1f:	89 f2                	mov    %esi,%edx
  801e21:	f7 34 24             	divl   (%esp)
  801e24:	89 d6                	mov    %edx,%esi
  801e26:	d3 e3                	shl    %cl,%ebx
  801e28:	f7 64 24 04          	mull   0x4(%esp)
  801e2c:	39 d6                	cmp    %edx,%esi
  801e2e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e32:	89 d1                	mov    %edx,%ecx
  801e34:	89 c3                	mov    %eax,%ebx
  801e36:	72 08                	jb     801e40 <__umoddi3+0x110>
  801e38:	75 11                	jne    801e4b <__umoddi3+0x11b>
  801e3a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801e3e:	73 0b                	jae    801e4b <__umoddi3+0x11b>
  801e40:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e44:	1b 14 24             	sbb    (%esp),%edx
  801e47:	89 d1                	mov    %edx,%ecx
  801e49:	89 c3                	mov    %eax,%ebx
  801e4b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e4f:	29 da                	sub    %ebx,%edx
  801e51:	19 ce                	sbb    %ecx,%esi
  801e53:	89 f9                	mov    %edi,%ecx
  801e55:	89 f0                	mov    %esi,%eax
  801e57:	d3 e0                	shl    %cl,%eax
  801e59:	89 e9                	mov    %ebp,%ecx
  801e5b:	d3 ea                	shr    %cl,%edx
  801e5d:	89 e9                	mov    %ebp,%ecx
  801e5f:	d3 ee                	shr    %cl,%esi
  801e61:	09 d0                	or     %edx,%eax
  801e63:	89 f2                	mov    %esi,%edx
  801e65:	83 c4 1c             	add    $0x1c,%esp
  801e68:	5b                   	pop    %ebx
  801e69:	5e                   	pop    %esi
  801e6a:	5f                   	pop    %edi
  801e6b:	5d                   	pop    %ebp
  801e6c:	c3                   	ret    
  801e6d:	8d 76 00             	lea    0x0(%esi),%esi
  801e70:	29 f9                	sub    %edi,%ecx
  801e72:	19 d6                	sbb    %edx,%esi
  801e74:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e78:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e7c:	e9 18 ff ff ff       	jmp    801d99 <__umoddi3+0x69>
