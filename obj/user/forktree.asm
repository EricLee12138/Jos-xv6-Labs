
obj/user/forktree.debug：     文件格式 elf32-i386


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
  80002c:	e8 b0 00 00 00       	call   8000e1 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
  80003a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003d:	e8 5b 0b 00 00       	call   800b9d <sys_getenvid>
  800042:	83 ec 04             	sub    $0x4,%esp
  800045:	53                   	push   %ebx
  800046:	50                   	push   %eax
  800047:	68 a0 21 80 00       	push   $0x8021a0
  80004c:	e8 83 01 00 00       	call   8001d4 <cprintf>

	forkchild(cur, '0');
  800051:	83 c4 08             	add    $0x8,%esp
  800054:	6a 30                	push   $0x30
  800056:	53                   	push   %ebx
  800057:	e8 13 00 00 00       	call   80006f <forkchild>
	forkchild(cur, '1');
  80005c:	83 c4 08             	add    $0x8,%esp
  80005f:	6a 31                	push   $0x31
  800061:	53                   	push   %ebx
  800062:	e8 08 00 00 00       	call   80006f <forkchild>
}
  800067:	83 c4 10             	add    $0x10,%esp
  80006a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80006d:	c9                   	leave  
  80006e:	c3                   	ret    

0080006f <forkchild>:

void forktree(const char *cur);

void
forkchild(const char *cur, char branch)
{
  80006f:	55                   	push   %ebp
  800070:	89 e5                	mov    %esp,%ebp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	83 ec 1c             	sub    $0x1c,%esp
  800077:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80007a:	8b 75 0c             	mov    0xc(%ebp),%esi
	char nxt[DEPTH+1];

	if (strlen(cur) >= DEPTH)
  80007d:	53                   	push   %ebx
  80007e:	e8 1c 07 00 00       	call   80079f <strlen>
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	83 f8 02             	cmp    $0x2,%eax
  800089:	7f 3a                	jg     8000c5 <forkchild+0x56>
		return;

	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	89 f0                	mov    %esi,%eax
  800090:	0f be f0             	movsbl %al,%esi
  800093:	56                   	push   %esi
  800094:	53                   	push   %ebx
  800095:	68 b1 21 80 00       	push   $0x8021b1
  80009a:	6a 04                	push   $0x4
  80009c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80009f:	50                   	push   %eax
  8000a0:	e8 e0 06 00 00       	call   800785 <snprintf>
	if (fork() == 0) {
  8000a5:	83 c4 20             	add    $0x20,%esp
  8000a8:	e8 c4 0d 00 00       	call   800e71 <fork>
  8000ad:	85 c0                	test   %eax,%eax
  8000af:	75 14                	jne    8000c5 <forkchild+0x56>
		forktree(nxt);
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000b7:	50                   	push   %eax
  8000b8:	e8 76 ff ff ff       	call   800033 <forktree>
		exit();
  8000bd:	e8 65 00 00 00       	call   800127 <exit>
  8000c2:	83 c4 10             	add    $0x10,%esp
	}
}
  8000c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c8:	5b                   	pop    %ebx
  8000c9:	5e                   	pop    %esi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    

008000cc <umain>:
	forkchild(cur, '1');
}

void
umain(int argc, char **argv)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	83 ec 14             	sub    $0x14,%esp
	forktree("");
  8000d2:	68 b0 21 80 00       	push   $0x8021b0
  8000d7:	e8 57 ff ff ff       	call   800033 <forktree>
}
  8000dc:	83 c4 10             	add    $0x10,%esp
  8000df:	c9                   	leave  
  8000e0:	c3                   	ret    

008000e1 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e1:	55                   	push   %ebp
  8000e2:	89 e5                	mov    %esp,%ebp
  8000e4:	56                   	push   %esi
  8000e5:	53                   	push   %ebx
  8000e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000ec:	e8 ac 0a 00 00       	call   800b9d <sys_getenvid>
  8000f1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000f9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000fe:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800103:	85 db                	test   %ebx,%ebx
  800105:	7e 07                	jle    80010e <libmain+0x2d>
		binaryname = argv[0];
  800107:	8b 06                	mov    (%esi),%eax
  800109:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80010e:	83 ec 08             	sub    $0x8,%esp
  800111:	56                   	push   %esi
  800112:	53                   	push   %ebx
  800113:	e8 b4 ff ff ff       	call   8000cc <umain>

	// exit gracefully
	exit();
  800118:	e8 0a 00 00 00       	call   800127 <exit>
}
  80011d:	83 c4 10             	add    $0x10,%esp
  800120:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800123:	5b                   	pop    %ebx
  800124:	5e                   	pop    %esi
  800125:	5d                   	pop    %ebp
  800126:	c3                   	ret    

00800127 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800127:	55                   	push   %ebp
  800128:	89 e5                	mov    %esp,%ebp
  80012a:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80012d:	e8 be 10 00 00       	call   8011f0 <close_all>
	sys_env_destroy(0);
  800132:	83 ec 0c             	sub    $0xc,%esp
  800135:	6a 00                	push   $0x0
  800137:	e8 20 0a 00 00       	call   800b5c <sys_env_destroy>
}
  80013c:	83 c4 10             	add    $0x10,%esp
  80013f:	c9                   	leave  
  800140:	c3                   	ret    

00800141 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800141:	55                   	push   %ebp
  800142:	89 e5                	mov    %esp,%ebp
  800144:	53                   	push   %ebx
  800145:	83 ec 04             	sub    $0x4,%esp
  800148:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80014b:	8b 13                	mov    (%ebx),%edx
  80014d:	8d 42 01             	lea    0x1(%edx),%eax
  800150:	89 03                	mov    %eax,(%ebx)
  800152:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800155:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800159:	3d ff 00 00 00       	cmp    $0xff,%eax
  80015e:	75 1a                	jne    80017a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800160:	83 ec 08             	sub    $0x8,%esp
  800163:	68 ff 00 00 00       	push   $0xff
  800168:	8d 43 08             	lea    0x8(%ebx),%eax
  80016b:	50                   	push   %eax
  80016c:	e8 ae 09 00 00       	call   800b1f <sys_cputs>
		b->idx = 0;
  800171:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800177:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80017a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80017e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800181:	c9                   	leave  
  800182:	c3                   	ret    

00800183 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80018c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800193:	00 00 00 
	b.cnt = 0;
  800196:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80019d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001a0:	ff 75 0c             	pushl  0xc(%ebp)
  8001a3:	ff 75 08             	pushl  0x8(%ebp)
  8001a6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001ac:	50                   	push   %eax
  8001ad:	68 41 01 80 00       	push   $0x800141
  8001b2:	e8 1a 01 00 00       	call   8002d1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001b7:	83 c4 08             	add    $0x8,%esp
  8001ba:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001c0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001c6:	50                   	push   %eax
  8001c7:	e8 53 09 00 00       	call   800b1f <sys_cputs>

	return b.cnt;
}
  8001cc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001d2:	c9                   	leave  
  8001d3:	c3                   	ret    

008001d4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001da:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001dd:	50                   	push   %eax
  8001de:	ff 75 08             	pushl  0x8(%ebp)
  8001e1:	e8 9d ff ff ff       	call   800183 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001e6:	c9                   	leave  
  8001e7:	c3                   	ret    

008001e8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	57                   	push   %edi
  8001ec:	56                   	push   %esi
  8001ed:	53                   	push   %ebx
  8001ee:	83 ec 1c             	sub    $0x1c,%esp
  8001f1:	89 c7                	mov    %eax,%edi
  8001f3:	89 d6                	mov    %edx,%esi
  8001f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001fb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001fe:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800201:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800204:	bb 00 00 00 00       	mov    $0x0,%ebx
  800209:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80020c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80020f:	39 d3                	cmp    %edx,%ebx
  800211:	72 05                	jb     800218 <printnum+0x30>
  800213:	39 45 10             	cmp    %eax,0x10(%ebp)
  800216:	77 45                	ja     80025d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800218:	83 ec 0c             	sub    $0xc,%esp
  80021b:	ff 75 18             	pushl  0x18(%ebp)
  80021e:	8b 45 14             	mov    0x14(%ebp),%eax
  800221:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800224:	53                   	push   %ebx
  800225:	ff 75 10             	pushl  0x10(%ebp)
  800228:	83 ec 08             	sub    $0x8,%esp
  80022b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80022e:	ff 75 e0             	pushl  -0x20(%ebp)
  800231:	ff 75 dc             	pushl  -0x24(%ebp)
  800234:	ff 75 d8             	pushl  -0x28(%ebp)
  800237:	e8 c4 1c 00 00       	call   801f00 <__udivdi3>
  80023c:	83 c4 18             	add    $0x18,%esp
  80023f:	52                   	push   %edx
  800240:	50                   	push   %eax
  800241:	89 f2                	mov    %esi,%edx
  800243:	89 f8                	mov    %edi,%eax
  800245:	e8 9e ff ff ff       	call   8001e8 <printnum>
  80024a:	83 c4 20             	add    $0x20,%esp
  80024d:	eb 18                	jmp    800267 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80024f:	83 ec 08             	sub    $0x8,%esp
  800252:	56                   	push   %esi
  800253:	ff 75 18             	pushl  0x18(%ebp)
  800256:	ff d7                	call   *%edi
  800258:	83 c4 10             	add    $0x10,%esp
  80025b:	eb 03                	jmp    800260 <printnum+0x78>
  80025d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800260:	83 eb 01             	sub    $0x1,%ebx
  800263:	85 db                	test   %ebx,%ebx
  800265:	7f e8                	jg     80024f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800267:	83 ec 08             	sub    $0x8,%esp
  80026a:	56                   	push   %esi
  80026b:	83 ec 04             	sub    $0x4,%esp
  80026e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800271:	ff 75 e0             	pushl  -0x20(%ebp)
  800274:	ff 75 dc             	pushl  -0x24(%ebp)
  800277:	ff 75 d8             	pushl  -0x28(%ebp)
  80027a:	e8 b1 1d 00 00       	call   802030 <__umoddi3>
  80027f:	83 c4 14             	add    $0x14,%esp
  800282:	0f be 80 c0 21 80 00 	movsbl 0x8021c0(%eax),%eax
  800289:	50                   	push   %eax
  80028a:	ff d7                	call   *%edi
}
  80028c:	83 c4 10             	add    $0x10,%esp
  80028f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800292:	5b                   	pop    %ebx
  800293:	5e                   	pop    %esi
  800294:	5f                   	pop    %edi
  800295:	5d                   	pop    %ebp
  800296:	c3                   	ret    

00800297 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800297:	55                   	push   %ebp
  800298:	89 e5                	mov    %esp,%ebp
  80029a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80029d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002a1:	8b 10                	mov    (%eax),%edx
  8002a3:	3b 50 04             	cmp    0x4(%eax),%edx
  8002a6:	73 0a                	jae    8002b2 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002a8:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ab:	89 08                	mov    %ecx,(%eax)
  8002ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b0:	88 02                	mov    %al,(%edx)
}
  8002b2:	5d                   	pop    %ebp
  8002b3:	c3                   	ret    

008002b4 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
  8002b7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002ba:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002bd:	50                   	push   %eax
  8002be:	ff 75 10             	pushl  0x10(%ebp)
  8002c1:	ff 75 0c             	pushl  0xc(%ebp)
  8002c4:	ff 75 08             	pushl  0x8(%ebp)
  8002c7:	e8 05 00 00 00       	call   8002d1 <vprintfmt>
	va_end(ap);
}
  8002cc:	83 c4 10             	add    $0x10,%esp
  8002cf:	c9                   	leave  
  8002d0:	c3                   	ret    

008002d1 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002d1:	55                   	push   %ebp
  8002d2:	89 e5                	mov    %esp,%ebp
  8002d4:	57                   	push   %edi
  8002d5:	56                   	push   %esi
  8002d6:	53                   	push   %ebx
  8002d7:	83 ec 2c             	sub    $0x2c,%esp
  8002da:	8b 75 08             	mov    0x8(%ebp),%esi
  8002dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002e0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002e3:	eb 12                	jmp    8002f7 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002e5:	85 c0                	test   %eax,%eax
  8002e7:	0f 84 42 04 00 00    	je     80072f <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8002ed:	83 ec 08             	sub    $0x8,%esp
  8002f0:	53                   	push   %ebx
  8002f1:	50                   	push   %eax
  8002f2:	ff d6                	call   *%esi
  8002f4:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002f7:	83 c7 01             	add    $0x1,%edi
  8002fa:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002fe:	83 f8 25             	cmp    $0x25,%eax
  800301:	75 e2                	jne    8002e5 <vprintfmt+0x14>
  800303:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800307:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80030e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800315:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80031c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800321:	eb 07                	jmp    80032a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800323:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800326:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032a:	8d 47 01             	lea    0x1(%edi),%eax
  80032d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800330:	0f b6 07             	movzbl (%edi),%eax
  800333:	0f b6 d0             	movzbl %al,%edx
  800336:	83 e8 23             	sub    $0x23,%eax
  800339:	3c 55                	cmp    $0x55,%al
  80033b:	0f 87 d3 03 00 00    	ja     800714 <vprintfmt+0x443>
  800341:	0f b6 c0             	movzbl %al,%eax
  800344:	ff 24 85 00 23 80 00 	jmp    *0x802300(,%eax,4)
  80034b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80034e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800352:	eb d6                	jmp    80032a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800354:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800357:	b8 00 00 00 00       	mov    $0x0,%eax
  80035c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80035f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800362:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800366:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800369:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80036c:	83 f9 09             	cmp    $0x9,%ecx
  80036f:	77 3f                	ja     8003b0 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800371:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800374:	eb e9                	jmp    80035f <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800376:	8b 45 14             	mov    0x14(%ebp),%eax
  800379:	8b 00                	mov    (%eax),%eax
  80037b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80037e:	8b 45 14             	mov    0x14(%ebp),%eax
  800381:	8d 40 04             	lea    0x4(%eax),%eax
  800384:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800387:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80038a:	eb 2a                	jmp    8003b6 <vprintfmt+0xe5>
  80038c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80038f:	85 c0                	test   %eax,%eax
  800391:	ba 00 00 00 00       	mov    $0x0,%edx
  800396:	0f 49 d0             	cmovns %eax,%edx
  800399:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80039f:	eb 89                	jmp    80032a <vprintfmt+0x59>
  8003a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003a4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003ab:	e9 7a ff ff ff       	jmp    80032a <vprintfmt+0x59>
  8003b0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003b3:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003b6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ba:	0f 89 6a ff ff ff    	jns    80032a <vprintfmt+0x59>
				width = precision, precision = -1;
  8003c0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003c6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003cd:	e9 58 ff ff ff       	jmp    80032a <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003d2:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003d8:	e9 4d ff ff ff       	jmp    80032a <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e0:	8d 78 04             	lea    0x4(%eax),%edi
  8003e3:	83 ec 08             	sub    $0x8,%esp
  8003e6:	53                   	push   %ebx
  8003e7:	ff 30                	pushl  (%eax)
  8003e9:	ff d6                	call   *%esi
			break;
  8003eb:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ee:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003f4:	e9 fe fe ff ff       	jmp    8002f7 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fc:	8d 78 04             	lea    0x4(%eax),%edi
  8003ff:	8b 00                	mov    (%eax),%eax
  800401:	99                   	cltd   
  800402:	31 d0                	xor    %edx,%eax
  800404:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800406:	83 f8 0f             	cmp    $0xf,%eax
  800409:	7f 0b                	jg     800416 <vprintfmt+0x145>
  80040b:	8b 14 85 60 24 80 00 	mov    0x802460(,%eax,4),%edx
  800412:	85 d2                	test   %edx,%edx
  800414:	75 1b                	jne    800431 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800416:	50                   	push   %eax
  800417:	68 d8 21 80 00       	push   $0x8021d8
  80041c:	53                   	push   %ebx
  80041d:	56                   	push   %esi
  80041e:	e8 91 fe ff ff       	call   8002b4 <printfmt>
  800423:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800426:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800429:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80042c:	e9 c6 fe ff ff       	jmp    8002f7 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800431:	52                   	push   %edx
  800432:	68 f9 25 80 00       	push   $0x8025f9
  800437:	53                   	push   %ebx
  800438:	56                   	push   %esi
  800439:	e8 76 fe ff ff       	call   8002b4 <printfmt>
  80043e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800441:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800444:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800447:	e9 ab fe ff ff       	jmp    8002f7 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80044c:	8b 45 14             	mov    0x14(%ebp),%eax
  80044f:	83 c0 04             	add    $0x4,%eax
  800452:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800455:	8b 45 14             	mov    0x14(%ebp),%eax
  800458:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80045a:	85 ff                	test   %edi,%edi
  80045c:	b8 d1 21 80 00       	mov    $0x8021d1,%eax
  800461:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800464:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800468:	0f 8e 94 00 00 00    	jle    800502 <vprintfmt+0x231>
  80046e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800472:	0f 84 98 00 00 00    	je     800510 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800478:	83 ec 08             	sub    $0x8,%esp
  80047b:	ff 75 d0             	pushl  -0x30(%ebp)
  80047e:	57                   	push   %edi
  80047f:	e8 33 03 00 00       	call   8007b7 <strnlen>
  800484:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800487:	29 c1                	sub    %eax,%ecx
  800489:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80048c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80048f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800493:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800496:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800499:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80049b:	eb 0f                	jmp    8004ac <vprintfmt+0x1db>
					putch(padc, putdat);
  80049d:	83 ec 08             	sub    $0x8,%esp
  8004a0:	53                   	push   %ebx
  8004a1:	ff 75 e0             	pushl  -0x20(%ebp)
  8004a4:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a6:	83 ef 01             	sub    $0x1,%edi
  8004a9:	83 c4 10             	add    $0x10,%esp
  8004ac:	85 ff                	test   %edi,%edi
  8004ae:	7f ed                	jg     80049d <vprintfmt+0x1cc>
  8004b0:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004b3:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004b6:	85 c9                	test   %ecx,%ecx
  8004b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8004bd:	0f 49 c1             	cmovns %ecx,%eax
  8004c0:	29 c1                	sub    %eax,%ecx
  8004c2:	89 75 08             	mov    %esi,0x8(%ebp)
  8004c5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004c8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004cb:	89 cb                	mov    %ecx,%ebx
  8004cd:	eb 4d                	jmp    80051c <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004cf:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004d3:	74 1b                	je     8004f0 <vprintfmt+0x21f>
  8004d5:	0f be c0             	movsbl %al,%eax
  8004d8:	83 e8 20             	sub    $0x20,%eax
  8004db:	83 f8 5e             	cmp    $0x5e,%eax
  8004de:	76 10                	jbe    8004f0 <vprintfmt+0x21f>
					putch('?', putdat);
  8004e0:	83 ec 08             	sub    $0x8,%esp
  8004e3:	ff 75 0c             	pushl  0xc(%ebp)
  8004e6:	6a 3f                	push   $0x3f
  8004e8:	ff 55 08             	call   *0x8(%ebp)
  8004eb:	83 c4 10             	add    $0x10,%esp
  8004ee:	eb 0d                	jmp    8004fd <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8004f0:	83 ec 08             	sub    $0x8,%esp
  8004f3:	ff 75 0c             	pushl  0xc(%ebp)
  8004f6:	52                   	push   %edx
  8004f7:	ff 55 08             	call   *0x8(%ebp)
  8004fa:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004fd:	83 eb 01             	sub    $0x1,%ebx
  800500:	eb 1a                	jmp    80051c <vprintfmt+0x24b>
  800502:	89 75 08             	mov    %esi,0x8(%ebp)
  800505:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800508:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80050b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80050e:	eb 0c                	jmp    80051c <vprintfmt+0x24b>
  800510:	89 75 08             	mov    %esi,0x8(%ebp)
  800513:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800516:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800519:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80051c:	83 c7 01             	add    $0x1,%edi
  80051f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800523:	0f be d0             	movsbl %al,%edx
  800526:	85 d2                	test   %edx,%edx
  800528:	74 23                	je     80054d <vprintfmt+0x27c>
  80052a:	85 f6                	test   %esi,%esi
  80052c:	78 a1                	js     8004cf <vprintfmt+0x1fe>
  80052e:	83 ee 01             	sub    $0x1,%esi
  800531:	79 9c                	jns    8004cf <vprintfmt+0x1fe>
  800533:	89 df                	mov    %ebx,%edi
  800535:	8b 75 08             	mov    0x8(%ebp),%esi
  800538:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80053b:	eb 18                	jmp    800555 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80053d:	83 ec 08             	sub    $0x8,%esp
  800540:	53                   	push   %ebx
  800541:	6a 20                	push   $0x20
  800543:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800545:	83 ef 01             	sub    $0x1,%edi
  800548:	83 c4 10             	add    $0x10,%esp
  80054b:	eb 08                	jmp    800555 <vprintfmt+0x284>
  80054d:	89 df                	mov    %ebx,%edi
  80054f:	8b 75 08             	mov    0x8(%ebp),%esi
  800552:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800555:	85 ff                	test   %edi,%edi
  800557:	7f e4                	jg     80053d <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800559:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80055c:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800562:	e9 90 fd ff ff       	jmp    8002f7 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800567:	83 f9 01             	cmp    $0x1,%ecx
  80056a:	7e 19                	jle    800585 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  80056c:	8b 45 14             	mov    0x14(%ebp),%eax
  80056f:	8b 50 04             	mov    0x4(%eax),%edx
  800572:	8b 00                	mov    (%eax),%eax
  800574:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800577:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80057a:	8b 45 14             	mov    0x14(%ebp),%eax
  80057d:	8d 40 08             	lea    0x8(%eax),%eax
  800580:	89 45 14             	mov    %eax,0x14(%ebp)
  800583:	eb 38                	jmp    8005bd <vprintfmt+0x2ec>
	else if (lflag)
  800585:	85 c9                	test   %ecx,%ecx
  800587:	74 1b                	je     8005a4 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800589:	8b 45 14             	mov    0x14(%ebp),%eax
  80058c:	8b 00                	mov    (%eax),%eax
  80058e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800591:	89 c1                	mov    %eax,%ecx
  800593:	c1 f9 1f             	sar    $0x1f,%ecx
  800596:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800599:	8b 45 14             	mov    0x14(%ebp),%eax
  80059c:	8d 40 04             	lea    0x4(%eax),%eax
  80059f:	89 45 14             	mov    %eax,0x14(%ebp)
  8005a2:	eb 19                	jmp    8005bd <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8005a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a7:	8b 00                	mov    (%eax),%eax
  8005a9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ac:	89 c1                	mov    %eax,%ecx
  8005ae:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b7:	8d 40 04             	lea    0x4(%eax),%eax
  8005ba:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005bd:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005c0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005c3:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005c8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005cc:	0f 89 0e 01 00 00    	jns    8006e0 <vprintfmt+0x40f>
				putch('-', putdat);
  8005d2:	83 ec 08             	sub    $0x8,%esp
  8005d5:	53                   	push   %ebx
  8005d6:	6a 2d                	push   $0x2d
  8005d8:	ff d6                	call   *%esi
				num = -(long long) num;
  8005da:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005dd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005e0:	f7 da                	neg    %edx
  8005e2:	83 d1 00             	adc    $0x0,%ecx
  8005e5:	f7 d9                	neg    %ecx
  8005e7:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005ea:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ef:	e9 ec 00 00 00       	jmp    8006e0 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005f4:	83 f9 01             	cmp    $0x1,%ecx
  8005f7:	7e 18                	jle    800611 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8005f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fc:	8b 10                	mov    (%eax),%edx
  8005fe:	8b 48 04             	mov    0x4(%eax),%ecx
  800601:	8d 40 08             	lea    0x8(%eax),%eax
  800604:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800607:	b8 0a 00 00 00       	mov    $0xa,%eax
  80060c:	e9 cf 00 00 00       	jmp    8006e0 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800611:	85 c9                	test   %ecx,%ecx
  800613:	74 1a                	je     80062f <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800615:	8b 45 14             	mov    0x14(%ebp),%eax
  800618:	8b 10                	mov    (%eax),%edx
  80061a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80061f:	8d 40 04             	lea    0x4(%eax),%eax
  800622:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800625:	b8 0a 00 00 00       	mov    $0xa,%eax
  80062a:	e9 b1 00 00 00       	jmp    8006e0 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80062f:	8b 45 14             	mov    0x14(%ebp),%eax
  800632:	8b 10                	mov    (%eax),%edx
  800634:	b9 00 00 00 00       	mov    $0x0,%ecx
  800639:	8d 40 04             	lea    0x4(%eax),%eax
  80063c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80063f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800644:	e9 97 00 00 00       	jmp    8006e0 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800649:	83 ec 08             	sub    $0x8,%esp
  80064c:	53                   	push   %ebx
  80064d:	6a 58                	push   $0x58
  80064f:	ff d6                	call   *%esi
			putch('X', putdat);
  800651:	83 c4 08             	add    $0x8,%esp
  800654:	53                   	push   %ebx
  800655:	6a 58                	push   $0x58
  800657:	ff d6                	call   *%esi
			putch('X', putdat);
  800659:	83 c4 08             	add    $0x8,%esp
  80065c:	53                   	push   %ebx
  80065d:	6a 58                	push   $0x58
  80065f:	ff d6                	call   *%esi
			break;
  800661:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800664:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800667:	e9 8b fc ff ff       	jmp    8002f7 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  80066c:	83 ec 08             	sub    $0x8,%esp
  80066f:	53                   	push   %ebx
  800670:	6a 30                	push   $0x30
  800672:	ff d6                	call   *%esi
			putch('x', putdat);
  800674:	83 c4 08             	add    $0x8,%esp
  800677:	53                   	push   %ebx
  800678:	6a 78                	push   $0x78
  80067a:	ff d6                	call   *%esi
			num = (unsigned long long)
  80067c:	8b 45 14             	mov    0x14(%ebp),%eax
  80067f:	8b 10                	mov    (%eax),%edx
  800681:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800686:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800689:	8d 40 04             	lea    0x4(%eax),%eax
  80068c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80068f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800694:	eb 4a                	jmp    8006e0 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800696:	83 f9 01             	cmp    $0x1,%ecx
  800699:	7e 15                	jle    8006b0 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  80069b:	8b 45 14             	mov    0x14(%ebp),%eax
  80069e:	8b 10                	mov    (%eax),%edx
  8006a0:	8b 48 04             	mov    0x4(%eax),%ecx
  8006a3:	8d 40 08             	lea    0x8(%eax),%eax
  8006a6:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006a9:	b8 10 00 00 00       	mov    $0x10,%eax
  8006ae:	eb 30                	jmp    8006e0 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006b0:	85 c9                	test   %ecx,%ecx
  8006b2:	74 17                	je     8006cb <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8006b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b7:	8b 10                	mov    (%eax),%edx
  8006b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006be:	8d 40 04             	lea    0x4(%eax),%eax
  8006c1:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006c4:	b8 10 00 00 00       	mov    $0x10,%eax
  8006c9:	eb 15                	jmp    8006e0 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8006cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ce:	8b 10                	mov    (%eax),%edx
  8006d0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d5:	8d 40 04             	lea    0x4(%eax),%eax
  8006d8:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006db:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006e0:	83 ec 0c             	sub    $0xc,%esp
  8006e3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006e7:	57                   	push   %edi
  8006e8:	ff 75 e0             	pushl  -0x20(%ebp)
  8006eb:	50                   	push   %eax
  8006ec:	51                   	push   %ecx
  8006ed:	52                   	push   %edx
  8006ee:	89 da                	mov    %ebx,%edx
  8006f0:	89 f0                	mov    %esi,%eax
  8006f2:	e8 f1 fa ff ff       	call   8001e8 <printnum>
			break;
  8006f7:	83 c4 20             	add    $0x20,%esp
  8006fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006fd:	e9 f5 fb ff ff       	jmp    8002f7 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800702:	83 ec 08             	sub    $0x8,%esp
  800705:	53                   	push   %ebx
  800706:	52                   	push   %edx
  800707:	ff d6                	call   *%esi
			break;
  800709:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80070f:	e9 e3 fb ff ff       	jmp    8002f7 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800714:	83 ec 08             	sub    $0x8,%esp
  800717:	53                   	push   %ebx
  800718:	6a 25                	push   $0x25
  80071a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80071c:	83 c4 10             	add    $0x10,%esp
  80071f:	eb 03                	jmp    800724 <vprintfmt+0x453>
  800721:	83 ef 01             	sub    $0x1,%edi
  800724:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800728:	75 f7                	jne    800721 <vprintfmt+0x450>
  80072a:	e9 c8 fb ff ff       	jmp    8002f7 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80072f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800732:	5b                   	pop    %ebx
  800733:	5e                   	pop    %esi
  800734:	5f                   	pop    %edi
  800735:	5d                   	pop    %ebp
  800736:	c3                   	ret    

00800737 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800737:	55                   	push   %ebp
  800738:	89 e5                	mov    %esp,%ebp
  80073a:	83 ec 18             	sub    $0x18,%esp
  80073d:	8b 45 08             	mov    0x8(%ebp),%eax
  800740:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800743:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800746:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80074a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80074d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800754:	85 c0                	test   %eax,%eax
  800756:	74 26                	je     80077e <vsnprintf+0x47>
  800758:	85 d2                	test   %edx,%edx
  80075a:	7e 22                	jle    80077e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80075c:	ff 75 14             	pushl  0x14(%ebp)
  80075f:	ff 75 10             	pushl  0x10(%ebp)
  800762:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800765:	50                   	push   %eax
  800766:	68 97 02 80 00       	push   $0x800297
  80076b:	e8 61 fb ff ff       	call   8002d1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800770:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800773:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800776:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800779:	83 c4 10             	add    $0x10,%esp
  80077c:	eb 05                	jmp    800783 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80077e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800783:	c9                   	leave  
  800784:	c3                   	ret    

00800785 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800785:	55                   	push   %ebp
  800786:	89 e5                	mov    %esp,%ebp
  800788:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80078b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80078e:	50                   	push   %eax
  80078f:	ff 75 10             	pushl  0x10(%ebp)
  800792:	ff 75 0c             	pushl  0xc(%ebp)
  800795:	ff 75 08             	pushl  0x8(%ebp)
  800798:	e8 9a ff ff ff       	call   800737 <vsnprintf>
	va_end(ap);

	return rc;
}
  80079d:	c9                   	leave  
  80079e:	c3                   	ret    

0080079f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80079f:	55                   	push   %ebp
  8007a0:	89 e5                	mov    %esp,%ebp
  8007a2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8007aa:	eb 03                	jmp    8007af <strlen+0x10>
		n++;
  8007ac:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007af:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007b3:	75 f7                	jne    8007ac <strlen+0xd>
		n++;
	return n;
}
  8007b5:	5d                   	pop    %ebp
  8007b6:	c3                   	ret    

008007b7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007bd:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8007c5:	eb 03                	jmp    8007ca <strnlen+0x13>
		n++;
  8007c7:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ca:	39 c2                	cmp    %eax,%edx
  8007cc:	74 08                	je     8007d6 <strnlen+0x1f>
  8007ce:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007d2:	75 f3                	jne    8007c7 <strnlen+0x10>
  8007d4:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007d6:	5d                   	pop    %ebp
  8007d7:	c3                   	ret    

008007d8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	53                   	push   %ebx
  8007dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007e2:	89 c2                	mov    %eax,%edx
  8007e4:	83 c2 01             	add    $0x1,%edx
  8007e7:	83 c1 01             	add    $0x1,%ecx
  8007ea:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007ee:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007f1:	84 db                	test   %bl,%bl
  8007f3:	75 ef                	jne    8007e4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007f5:	5b                   	pop    %ebx
  8007f6:	5d                   	pop    %ebp
  8007f7:	c3                   	ret    

008007f8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	53                   	push   %ebx
  8007fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007ff:	53                   	push   %ebx
  800800:	e8 9a ff ff ff       	call   80079f <strlen>
  800805:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800808:	ff 75 0c             	pushl  0xc(%ebp)
  80080b:	01 d8                	add    %ebx,%eax
  80080d:	50                   	push   %eax
  80080e:	e8 c5 ff ff ff       	call   8007d8 <strcpy>
	return dst;
}
  800813:	89 d8                	mov    %ebx,%eax
  800815:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800818:	c9                   	leave  
  800819:	c3                   	ret    

0080081a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	56                   	push   %esi
  80081e:	53                   	push   %ebx
  80081f:	8b 75 08             	mov    0x8(%ebp),%esi
  800822:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800825:	89 f3                	mov    %esi,%ebx
  800827:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80082a:	89 f2                	mov    %esi,%edx
  80082c:	eb 0f                	jmp    80083d <strncpy+0x23>
		*dst++ = *src;
  80082e:	83 c2 01             	add    $0x1,%edx
  800831:	0f b6 01             	movzbl (%ecx),%eax
  800834:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800837:	80 39 01             	cmpb   $0x1,(%ecx)
  80083a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80083d:	39 da                	cmp    %ebx,%edx
  80083f:	75 ed                	jne    80082e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800841:	89 f0                	mov    %esi,%eax
  800843:	5b                   	pop    %ebx
  800844:	5e                   	pop    %esi
  800845:	5d                   	pop    %ebp
  800846:	c3                   	ret    

00800847 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
  80084a:	56                   	push   %esi
  80084b:	53                   	push   %ebx
  80084c:	8b 75 08             	mov    0x8(%ebp),%esi
  80084f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800852:	8b 55 10             	mov    0x10(%ebp),%edx
  800855:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800857:	85 d2                	test   %edx,%edx
  800859:	74 21                	je     80087c <strlcpy+0x35>
  80085b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80085f:	89 f2                	mov    %esi,%edx
  800861:	eb 09                	jmp    80086c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800863:	83 c2 01             	add    $0x1,%edx
  800866:	83 c1 01             	add    $0x1,%ecx
  800869:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80086c:	39 c2                	cmp    %eax,%edx
  80086e:	74 09                	je     800879 <strlcpy+0x32>
  800870:	0f b6 19             	movzbl (%ecx),%ebx
  800873:	84 db                	test   %bl,%bl
  800875:	75 ec                	jne    800863 <strlcpy+0x1c>
  800877:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800879:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80087c:	29 f0                	sub    %esi,%eax
}
  80087e:	5b                   	pop    %ebx
  80087f:	5e                   	pop    %esi
  800880:	5d                   	pop    %ebp
  800881:	c3                   	ret    

00800882 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800888:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80088b:	eb 06                	jmp    800893 <strcmp+0x11>
		p++, q++;
  80088d:	83 c1 01             	add    $0x1,%ecx
  800890:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800893:	0f b6 01             	movzbl (%ecx),%eax
  800896:	84 c0                	test   %al,%al
  800898:	74 04                	je     80089e <strcmp+0x1c>
  80089a:	3a 02                	cmp    (%edx),%al
  80089c:	74 ef                	je     80088d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80089e:	0f b6 c0             	movzbl %al,%eax
  8008a1:	0f b6 12             	movzbl (%edx),%edx
  8008a4:	29 d0                	sub    %edx,%eax
}
  8008a6:	5d                   	pop    %ebp
  8008a7:	c3                   	ret    

008008a8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008a8:	55                   	push   %ebp
  8008a9:	89 e5                	mov    %esp,%ebp
  8008ab:	53                   	push   %ebx
  8008ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8008af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b2:	89 c3                	mov    %eax,%ebx
  8008b4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008b7:	eb 06                	jmp    8008bf <strncmp+0x17>
		n--, p++, q++;
  8008b9:	83 c0 01             	add    $0x1,%eax
  8008bc:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008bf:	39 d8                	cmp    %ebx,%eax
  8008c1:	74 15                	je     8008d8 <strncmp+0x30>
  8008c3:	0f b6 08             	movzbl (%eax),%ecx
  8008c6:	84 c9                	test   %cl,%cl
  8008c8:	74 04                	je     8008ce <strncmp+0x26>
  8008ca:	3a 0a                	cmp    (%edx),%cl
  8008cc:	74 eb                	je     8008b9 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ce:	0f b6 00             	movzbl (%eax),%eax
  8008d1:	0f b6 12             	movzbl (%edx),%edx
  8008d4:	29 d0                	sub    %edx,%eax
  8008d6:	eb 05                	jmp    8008dd <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008d8:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008dd:	5b                   	pop    %ebx
  8008de:	5d                   	pop    %ebp
  8008df:	c3                   	ret    

008008e0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ea:	eb 07                	jmp    8008f3 <strchr+0x13>
		if (*s == c)
  8008ec:	38 ca                	cmp    %cl,%dl
  8008ee:	74 0f                	je     8008ff <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008f0:	83 c0 01             	add    $0x1,%eax
  8008f3:	0f b6 10             	movzbl (%eax),%edx
  8008f6:	84 d2                	test   %dl,%dl
  8008f8:	75 f2                	jne    8008ec <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008ff:	5d                   	pop    %ebp
  800900:	c3                   	ret    

00800901 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800901:	55                   	push   %ebp
  800902:	89 e5                	mov    %esp,%ebp
  800904:	8b 45 08             	mov    0x8(%ebp),%eax
  800907:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80090b:	eb 03                	jmp    800910 <strfind+0xf>
  80090d:	83 c0 01             	add    $0x1,%eax
  800910:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800913:	38 ca                	cmp    %cl,%dl
  800915:	74 04                	je     80091b <strfind+0x1a>
  800917:	84 d2                	test   %dl,%dl
  800919:	75 f2                	jne    80090d <strfind+0xc>
			break;
	return (char *) s;
}
  80091b:	5d                   	pop    %ebp
  80091c:	c3                   	ret    

0080091d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	57                   	push   %edi
  800921:	56                   	push   %esi
  800922:	53                   	push   %ebx
  800923:	8b 7d 08             	mov    0x8(%ebp),%edi
  800926:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800929:	85 c9                	test   %ecx,%ecx
  80092b:	74 36                	je     800963 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80092d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800933:	75 28                	jne    80095d <memset+0x40>
  800935:	f6 c1 03             	test   $0x3,%cl
  800938:	75 23                	jne    80095d <memset+0x40>
		c &= 0xFF;
  80093a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80093e:	89 d3                	mov    %edx,%ebx
  800940:	c1 e3 08             	shl    $0x8,%ebx
  800943:	89 d6                	mov    %edx,%esi
  800945:	c1 e6 18             	shl    $0x18,%esi
  800948:	89 d0                	mov    %edx,%eax
  80094a:	c1 e0 10             	shl    $0x10,%eax
  80094d:	09 f0                	or     %esi,%eax
  80094f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800951:	89 d8                	mov    %ebx,%eax
  800953:	09 d0                	or     %edx,%eax
  800955:	c1 e9 02             	shr    $0x2,%ecx
  800958:	fc                   	cld    
  800959:	f3 ab                	rep stos %eax,%es:(%edi)
  80095b:	eb 06                	jmp    800963 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80095d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800960:	fc                   	cld    
  800961:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800963:	89 f8                	mov    %edi,%eax
  800965:	5b                   	pop    %ebx
  800966:	5e                   	pop    %esi
  800967:	5f                   	pop    %edi
  800968:	5d                   	pop    %ebp
  800969:	c3                   	ret    

0080096a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	57                   	push   %edi
  80096e:	56                   	push   %esi
  80096f:	8b 45 08             	mov    0x8(%ebp),%eax
  800972:	8b 75 0c             	mov    0xc(%ebp),%esi
  800975:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800978:	39 c6                	cmp    %eax,%esi
  80097a:	73 35                	jae    8009b1 <memmove+0x47>
  80097c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80097f:	39 d0                	cmp    %edx,%eax
  800981:	73 2e                	jae    8009b1 <memmove+0x47>
		s += n;
		d += n;
  800983:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800986:	89 d6                	mov    %edx,%esi
  800988:	09 fe                	or     %edi,%esi
  80098a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800990:	75 13                	jne    8009a5 <memmove+0x3b>
  800992:	f6 c1 03             	test   $0x3,%cl
  800995:	75 0e                	jne    8009a5 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800997:	83 ef 04             	sub    $0x4,%edi
  80099a:	8d 72 fc             	lea    -0x4(%edx),%esi
  80099d:	c1 e9 02             	shr    $0x2,%ecx
  8009a0:	fd                   	std    
  8009a1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a3:	eb 09                	jmp    8009ae <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009a5:	83 ef 01             	sub    $0x1,%edi
  8009a8:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009ab:	fd                   	std    
  8009ac:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ae:	fc                   	cld    
  8009af:	eb 1d                	jmp    8009ce <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b1:	89 f2                	mov    %esi,%edx
  8009b3:	09 c2                	or     %eax,%edx
  8009b5:	f6 c2 03             	test   $0x3,%dl
  8009b8:	75 0f                	jne    8009c9 <memmove+0x5f>
  8009ba:	f6 c1 03             	test   $0x3,%cl
  8009bd:	75 0a                	jne    8009c9 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009bf:	c1 e9 02             	shr    $0x2,%ecx
  8009c2:	89 c7                	mov    %eax,%edi
  8009c4:	fc                   	cld    
  8009c5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c7:	eb 05                	jmp    8009ce <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009c9:	89 c7                	mov    %eax,%edi
  8009cb:	fc                   	cld    
  8009cc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ce:	5e                   	pop    %esi
  8009cf:	5f                   	pop    %edi
  8009d0:	5d                   	pop    %ebp
  8009d1:	c3                   	ret    

008009d2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009d5:	ff 75 10             	pushl  0x10(%ebp)
  8009d8:	ff 75 0c             	pushl  0xc(%ebp)
  8009db:	ff 75 08             	pushl  0x8(%ebp)
  8009de:	e8 87 ff ff ff       	call   80096a <memmove>
}
  8009e3:	c9                   	leave  
  8009e4:	c3                   	ret    

008009e5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	56                   	push   %esi
  8009e9:	53                   	push   %ebx
  8009ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f0:	89 c6                	mov    %eax,%esi
  8009f2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f5:	eb 1a                	jmp    800a11 <memcmp+0x2c>
		if (*s1 != *s2)
  8009f7:	0f b6 08             	movzbl (%eax),%ecx
  8009fa:	0f b6 1a             	movzbl (%edx),%ebx
  8009fd:	38 d9                	cmp    %bl,%cl
  8009ff:	74 0a                	je     800a0b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a01:	0f b6 c1             	movzbl %cl,%eax
  800a04:	0f b6 db             	movzbl %bl,%ebx
  800a07:	29 d8                	sub    %ebx,%eax
  800a09:	eb 0f                	jmp    800a1a <memcmp+0x35>
		s1++, s2++;
  800a0b:	83 c0 01             	add    $0x1,%eax
  800a0e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a11:	39 f0                	cmp    %esi,%eax
  800a13:	75 e2                	jne    8009f7 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a15:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1a:	5b                   	pop    %ebx
  800a1b:	5e                   	pop    %esi
  800a1c:	5d                   	pop    %ebp
  800a1d:	c3                   	ret    

00800a1e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	53                   	push   %ebx
  800a22:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a25:	89 c1                	mov    %eax,%ecx
  800a27:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a2a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a2e:	eb 0a                	jmp    800a3a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a30:	0f b6 10             	movzbl (%eax),%edx
  800a33:	39 da                	cmp    %ebx,%edx
  800a35:	74 07                	je     800a3e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a37:	83 c0 01             	add    $0x1,%eax
  800a3a:	39 c8                	cmp    %ecx,%eax
  800a3c:	72 f2                	jb     800a30 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a3e:	5b                   	pop    %ebx
  800a3f:	5d                   	pop    %ebp
  800a40:	c3                   	ret    

00800a41 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	57                   	push   %edi
  800a45:	56                   	push   %esi
  800a46:	53                   	push   %ebx
  800a47:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a4a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a4d:	eb 03                	jmp    800a52 <strtol+0x11>
		s++;
  800a4f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a52:	0f b6 01             	movzbl (%ecx),%eax
  800a55:	3c 20                	cmp    $0x20,%al
  800a57:	74 f6                	je     800a4f <strtol+0xe>
  800a59:	3c 09                	cmp    $0x9,%al
  800a5b:	74 f2                	je     800a4f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a5d:	3c 2b                	cmp    $0x2b,%al
  800a5f:	75 0a                	jne    800a6b <strtol+0x2a>
		s++;
  800a61:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a64:	bf 00 00 00 00       	mov    $0x0,%edi
  800a69:	eb 11                	jmp    800a7c <strtol+0x3b>
  800a6b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a70:	3c 2d                	cmp    $0x2d,%al
  800a72:	75 08                	jne    800a7c <strtol+0x3b>
		s++, neg = 1;
  800a74:	83 c1 01             	add    $0x1,%ecx
  800a77:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a7c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a82:	75 15                	jne    800a99 <strtol+0x58>
  800a84:	80 39 30             	cmpb   $0x30,(%ecx)
  800a87:	75 10                	jne    800a99 <strtol+0x58>
  800a89:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a8d:	75 7c                	jne    800b0b <strtol+0xca>
		s += 2, base = 16;
  800a8f:	83 c1 02             	add    $0x2,%ecx
  800a92:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a97:	eb 16                	jmp    800aaf <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a99:	85 db                	test   %ebx,%ebx
  800a9b:	75 12                	jne    800aaf <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a9d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aa2:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa5:	75 08                	jne    800aaf <strtol+0x6e>
		s++, base = 8;
  800aa7:	83 c1 01             	add    $0x1,%ecx
  800aaa:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800aaf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab4:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ab7:	0f b6 11             	movzbl (%ecx),%edx
  800aba:	8d 72 d0             	lea    -0x30(%edx),%esi
  800abd:	89 f3                	mov    %esi,%ebx
  800abf:	80 fb 09             	cmp    $0x9,%bl
  800ac2:	77 08                	ja     800acc <strtol+0x8b>
			dig = *s - '0';
  800ac4:	0f be d2             	movsbl %dl,%edx
  800ac7:	83 ea 30             	sub    $0x30,%edx
  800aca:	eb 22                	jmp    800aee <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800acc:	8d 72 9f             	lea    -0x61(%edx),%esi
  800acf:	89 f3                	mov    %esi,%ebx
  800ad1:	80 fb 19             	cmp    $0x19,%bl
  800ad4:	77 08                	ja     800ade <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ad6:	0f be d2             	movsbl %dl,%edx
  800ad9:	83 ea 57             	sub    $0x57,%edx
  800adc:	eb 10                	jmp    800aee <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ade:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ae1:	89 f3                	mov    %esi,%ebx
  800ae3:	80 fb 19             	cmp    $0x19,%bl
  800ae6:	77 16                	ja     800afe <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ae8:	0f be d2             	movsbl %dl,%edx
  800aeb:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800aee:	3b 55 10             	cmp    0x10(%ebp),%edx
  800af1:	7d 0b                	jge    800afe <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800af3:	83 c1 01             	add    $0x1,%ecx
  800af6:	0f af 45 10          	imul   0x10(%ebp),%eax
  800afa:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800afc:	eb b9                	jmp    800ab7 <strtol+0x76>

	if (endptr)
  800afe:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b02:	74 0d                	je     800b11 <strtol+0xd0>
		*endptr = (char *) s;
  800b04:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b07:	89 0e                	mov    %ecx,(%esi)
  800b09:	eb 06                	jmp    800b11 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b0b:	85 db                	test   %ebx,%ebx
  800b0d:	74 98                	je     800aa7 <strtol+0x66>
  800b0f:	eb 9e                	jmp    800aaf <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b11:	89 c2                	mov    %eax,%edx
  800b13:	f7 da                	neg    %edx
  800b15:	85 ff                	test   %edi,%edi
  800b17:	0f 45 c2             	cmovne %edx,%eax
}
  800b1a:	5b                   	pop    %ebx
  800b1b:	5e                   	pop    %esi
  800b1c:	5f                   	pop    %edi
  800b1d:	5d                   	pop    %ebp
  800b1e:	c3                   	ret    

00800b1f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
  800b22:	57                   	push   %edi
  800b23:	56                   	push   %esi
  800b24:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b25:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b30:	89 c3                	mov    %eax,%ebx
  800b32:	89 c7                	mov    %eax,%edi
  800b34:	89 c6                	mov    %eax,%esi
  800b36:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b38:	5b                   	pop    %ebx
  800b39:	5e                   	pop    %esi
  800b3a:	5f                   	pop    %edi
  800b3b:	5d                   	pop    %ebp
  800b3c:	c3                   	ret    

00800b3d <sys_cgetc>:

int
sys_cgetc(void)
{
  800b3d:	55                   	push   %ebp
  800b3e:	89 e5                	mov    %esp,%ebp
  800b40:	57                   	push   %edi
  800b41:	56                   	push   %esi
  800b42:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b43:	ba 00 00 00 00       	mov    $0x0,%edx
  800b48:	b8 01 00 00 00       	mov    $0x1,%eax
  800b4d:	89 d1                	mov    %edx,%ecx
  800b4f:	89 d3                	mov    %edx,%ebx
  800b51:	89 d7                	mov    %edx,%edi
  800b53:	89 d6                	mov    %edx,%esi
  800b55:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b57:	5b                   	pop    %ebx
  800b58:	5e                   	pop    %esi
  800b59:	5f                   	pop    %edi
  800b5a:	5d                   	pop    %ebp
  800b5b:	c3                   	ret    

00800b5c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	57                   	push   %edi
  800b60:	56                   	push   %esi
  800b61:	53                   	push   %ebx
  800b62:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b65:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b6a:	b8 03 00 00 00       	mov    $0x3,%eax
  800b6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b72:	89 cb                	mov    %ecx,%ebx
  800b74:	89 cf                	mov    %ecx,%edi
  800b76:	89 ce                	mov    %ecx,%esi
  800b78:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b7a:	85 c0                	test   %eax,%eax
  800b7c:	7e 17                	jle    800b95 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7e:	83 ec 0c             	sub    $0xc,%esp
  800b81:	50                   	push   %eax
  800b82:	6a 03                	push   $0x3
  800b84:	68 bf 24 80 00       	push   $0x8024bf
  800b89:	6a 23                	push   $0x23
  800b8b:	68 dc 24 80 00       	push   $0x8024dc
  800b90:	e8 7a 11 00 00       	call   801d0f <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b98:	5b                   	pop    %ebx
  800b99:	5e                   	pop    %esi
  800b9a:	5f                   	pop    %edi
  800b9b:	5d                   	pop    %ebp
  800b9c:	c3                   	ret    

00800b9d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	57                   	push   %edi
  800ba1:	56                   	push   %esi
  800ba2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba8:	b8 02 00 00 00       	mov    $0x2,%eax
  800bad:	89 d1                	mov    %edx,%ecx
  800baf:	89 d3                	mov    %edx,%ebx
  800bb1:	89 d7                	mov    %edx,%edi
  800bb3:	89 d6                	mov    %edx,%esi
  800bb5:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bb7:	5b                   	pop    %ebx
  800bb8:	5e                   	pop    %esi
  800bb9:	5f                   	pop    %edi
  800bba:	5d                   	pop    %ebp
  800bbb:	c3                   	ret    

00800bbc <sys_yield>:

void
sys_yield(void)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	57                   	push   %edi
  800bc0:	56                   	push   %esi
  800bc1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc7:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bcc:	89 d1                	mov    %edx,%ecx
  800bce:	89 d3                	mov    %edx,%ebx
  800bd0:	89 d7                	mov    %edx,%edi
  800bd2:	89 d6                	mov    %edx,%esi
  800bd4:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bd6:	5b                   	pop    %ebx
  800bd7:	5e                   	pop    %esi
  800bd8:	5f                   	pop    %edi
  800bd9:	5d                   	pop    %ebp
  800bda:	c3                   	ret    

00800bdb <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	57                   	push   %edi
  800bdf:	56                   	push   %esi
  800be0:	53                   	push   %ebx
  800be1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be4:	be 00 00 00 00       	mov    $0x0,%esi
  800be9:	b8 04 00 00 00       	mov    $0x4,%eax
  800bee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf7:	89 f7                	mov    %esi,%edi
  800bf9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bfb:	85 c0                	test   %eax,%eax
  800bfd:	7e 17                	jle    800c16 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bff:	83 ec 0c             	sub    $0xc,%esp
  800c02:	50                   	push   %eax
  800c03:	6a 04                	push   $0x4
  800c05:	68 bf 24 80 00       	push   $0x8024bf
  800c0a:	6a 23                	push   $0x23
  800c0c:	68 dc 24 80 00       	push   $0x8024dc
  800c11:	e8 f9 10 00 00       	call   801d0f <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c19:	5b                   	pop    %ebx
  800c1a:	5e                   	pop    %esi
  800c1b:	5f                   	pop    %edi
  800c1c:	5d                   	pop    %ebp
  800c1d:	c3                   	ret    

00800c1e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c1e:	55                   	push   %ebp
  800c1f:	89 e5                	mov    %esp,%ebp
  800c21:	57                   	push   %edi
  800c22:	56                   	push   %esi
  800c23:	53                   	push   %ebx
  800c24:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c27:	b8 05 00 00 00       	mov    $0x5,%eax
  800c2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c32:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c35:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c38:	8b 75 18             	mov    0x18(%ebp),%esi
  800c3b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c3d:	85 c0                	test   %eax,%eax
  800c3f:	7e 17                	jle    800c58 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c41:	83 ec 0c             	sub    $0xc,%esp
  800c44:	50                   	push   %eax
  800c45:	6a 05                	push   $0x5
  800c47:	68 bf 24 80 00       	push   $0x8024bf
  800c4c:	6a 23                	push   $0x23
  800c4e:	68 dc 24 80 00       	push   $0x8024dc
  800c53:	e8 b7 10 00 00       	call   801d0f <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5b:	5b                   	pop    %ebx
  800c5c:	5e                   	pop    %esi
  800c5d:	5f                   	pop    %edi
  800c5e:	5d                   	pop    %ebp
  800c5f:	c3                   	ret    

00800c60 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	57                   	push   %edi
  800c64:	56                   	push   %esi
  800c65:	53                   	push   %ebx
  800c66:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c69:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c6e:	b8 06 00 00 00       	mov    $0x6,%eax
  800c73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c76:	8b 55 08             	mov    0x8(%ebp),%edx
  800c79:	89 df                	mov    %ebx,%edi
  800c7b:	89 de                	mov    %ebx,%esi
  800c7d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c7f:	85 c0                	test   %eax,%eax
  800c81:	7e 17                	jle    800c9a <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c83:	83 ec 0c             	sub    $0xc,%esp
  800c86:	50                   	push   %eax
  800c87:	6a 06                	push   $0x6
  800c89:	68 bf 24 80 00       	push   $0x8024bf
  800c8e:	6a 23                	push   $0x23
  800c90:	68 dc 24 80 00       	push   $0x8024dc
  800c95:	e8 75 10 00 00       	call   801d0f <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9d:	5b                   	pop    %ebx
  800c9e:	5e                   	pop    %esi
  800c9f:	5f                   	pop    %edi
  800ca0:	5d                   	pop    %ebp
  800ca1:	c3                   	ret    

00800ca2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ca2:	55                   	push   %ebp
  800ca3:	89 e5                	mov    %esp,%ebp
  800ca5:	57                   	push   %edi
  800ca6:	56                   	push   %esi
  800ca7:	53                   	push   %ebx
  800ca8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cab:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb0:	b8 08 00 00 00       	mov    $0x8,%eax
  800cb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbb:	89 df                	mov    %ebx,%edi
  800cbd:	89 de                	mov    %ebx,%esi
  800cbf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc1:	85 c0                	test   %eax,%eax
  800cc3:	7e 17                	jle    800cdc <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc5:	83 ec 0c             	sub    $0xc,%esp
  800cc8:	50                   	push   %eax
  800cc9:	6a 08                	push   $0x8
  800ccb:	68 bf 24 80 00       	push   $0x8024bf
  800cd0:	6a 23                	push   $0x23
  800cd2:	68 dc 24 80 00       	push   $0x8024dc
  800cd7:	e8 33 10 00 00       	call   801d0f <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cdc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdf:	5b                   	pop    %ebx
  800ce0:	5e                   	pop    %esi
  800ce1:	5f                   	pop    %edi
  800ce2:	5d                   	pop    %ebp
  800ce3:	c3                   	ret    

00800ce4 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	57                   	push   %edi
  800ce8:	56                   	push   %esi
  800ce9:	53                   	push   %ebx
  800cea:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ced:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf2:	b8 09 00 00 00       	mov    $0x9,%eax
  800cf7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfd:	89 df                	mov    %ebx,%edi
  800cff:	89 de                	mov    %ebx,%esi
  800d01:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d03:	85 c0                	test   %eax,%eax
  800d05:	7e 17                	jle    800d1e <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d07:	83 ec 0c             	sub    $0xc,%esp
  800d0a:	50                   	push   %eax
  800d0b:	6a 09                	push   $0x9
  800d0d:	68 bf 24 80 00       	push   $0x8024bf
  800d12:	6a 23                	push   $0x23
  800d14:	68 dc 24 80 00       	push   $0x8024dc
  800d19:	e8 f1 0f 00 00       	call   801d0f <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d21:	5b                   	pop    %ebx
  800d22:	5e                   	pop    %esi
  800d23:	5f                   	pop    %edi
  800d24:	5d                   	pop    %ebp
  800d25:	c3                   	ret    

00800d26 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
  800d29:	57                   	push   %edi
  800d2a:	56                   	push   %esi
  800d2b:	53                   	push   %ebx
  800d2c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d34:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3f:	89 df                	mov    %ebx,%edi
  800d41:	89 de                	mov    %ebx,%esi
  800d43:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d45:	85 c0                	test   %eax,%eax
  800d47:	7e 17                	jle    800d60 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d49:	83 ec 0c             	sub    $0xc,%esp
  800d4c:	50                   	push   %eax
  800d4d:	6a 0a                	push   $0xa
  800d4f:	68 bf 24 80 00       	push   $0x8024bf
  800d54:	6a 23                	push   $0x23
  800d56:	68 dc 24 80 00       	push   $0x8024dc
  800d5b:	e8 af 0f 00 00       	call   801d0f <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d63:	5b                   	pop    %ebx
  800d64:	5e                   	pop    %esi
  800d65:	5f                   	pop    %edi
  800d66:	5d                   	pop    %ebp
  800d67:	c3                   	ret    

00800d68 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d68:	55                   	push   %ebp
  800d69:	89 e5                	mov    %esp,%ebp
  800d6b:	57                   	push   %edi
  800d6c:	56                   	push   %esi
  800d6d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6e:	be 00 00 00 00       	mov    $0x0,%esi
  800d73:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d81:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d84:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d86:	5b                   	pop    %ebx
  800d87:	5e                   	pop    %esi
  800d88:	5f                   	pop    %edi
  800d89:	5d                   	pop    %ebp
  800d8a:	c3                   	ret    

00800d8b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d8b:	55                   	push   %ebp
  800d8c:	89 e5                	mov    %esp,%ebp
  800d8e:	57                   	push   %edi
  800d8f:	56                   	push   %esi
  800d90:	53                   	push   %ebx
  800d91:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d94:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d99:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800da1:	89 cb                	mov    %ecx,%ebx
  800da3:	89 cf                	mov    %ecx,%edi
  800da5:	89 ce                	mov    %ecx,%esi
  800da7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800da9:	85 c0                	test   %eax,%eax
  800dab:	7e 17                	jle    800dc4 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dad:	83 ec 0c             	sub    $0xc,%esp
  800db0:	50                   	push   %eax
  800db1:	6a 0d                	push   $0xd
  800db3:	68 bf 24 80 00       	push   $0x8024bf
  800db8:	6a 23                	push   $0x23
  800dba:	68 dc 24 80 00       	push   $0x8024dc
  800dbf:	e8 4b 0f 00 00       	call   801d0f <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc7:	5b                   	pop    %ebx
  800dc8:	5e                   	pop    %esi
  800dc9:	5f                   	pop    %edi
  800dca:	5d                   	pop    %ebp
  800dcb:	c3                   	ret    

00800dcc <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	57                   	push   %edi
  800dd0:	56                   	push   %esi
  800dd1:	53                   	push   %ebx
  800dd2:	83 ec 0c             	sub    $0xc,%esp
  800dd5:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800dd8:	8b 18                	mov    (%eax),%ebx
	uint32_t err = utf->utf_err;
  800dda:	8b 78 04             	mov    0x4(%eax),%edi
	int r;
	envid_t curenvid = sys_getenvid();
  800ddd:	e8 bb fd ff ff       	call   800b9d <sys_getenvid>
  800de2:	89 c6                	mov    %eax,%esi
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(err & FEC_WR) && !(uvpt[PGNUM(addr)] & PTE_COW))
  800de4:	f7 c7 02 00 00 00    	test   $0x2,%edi
  800dea:	75 25                	jne    800e11 <pgfault+0x45>
  800dec:	89 d8                	mov    %ebx,%eax
  800dee:	c1 e8 0c             	shr    $0xc,%eax
  800df1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800df8:	f6 c4 08             	test   $0x8,%ah
  800dfb:	75 14                	jne    800e11 <pgfault+0x45>
	    panic("pgfault error: wrong faulting access");
  800dfd:	83 ec 04             	sub    $0x4,%esp
  800e00:	68 ec 24 80 00       	push   $0x8024ec
  800e05:	6a 1e                	push   $0x1e
  800e07:	68 11 25 80 00       	push   $0x802511
  800e0c:	e8 fe 0e 00 00       	call   801d0f <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	sys_page_alloc(curenvid, PFTEMP, PTE_W | PTE_U | PTE_P);
  800e11:	83 ec 04             	sub    $0x4,%esp
  800e14:	6a 07                	push   $0x7
  800e16:	68 00 f0 7f 00       	push   $0x7ff000
  800e1b:	56                   	push   %esi
  800e1c:	e8 ba fd ff ff       	call   800bdb <sys_page_alloc>

	addr = (void *)(PGNUM(addr) * PGSIZE);
  800e21:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr, PGSIZE);
  800e27:	83 c4 0c             	add    $0xc,%esp
  800e2a:	68 00 10 00 00       	push   $0x1000
  800e2f:	53                   	push   %ebx
  800e30:	68 00 f0 7f 00       	push   $0x7ff000
  800e35:	e8 30 fb ff ff       	call   80096a <memmove>

	sys_page_unmap(curenvid, addr);
  800e3a:	83 c4 08             	add    $0x8,%esp
  800e3d:	53                   	push   %ebx
  800e3e:	56                   	push   %esi
  800e3f:	e8 1c fe ff ff       	call   800c60 <sys_page_unmap>
	sys_page_map(curenvid, PFTEMP, curenvid, addr, PTE_W | PTE_U | PTE_P);
  800e44:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e4b:	53                   	push   %ebx
  800e4c:	56                   	push   %esi
  800e4d:	68 00 f0 7f 00       	push   $0x7ff000
  800e52:	56                   	push   %esi
  800e53:	e8 c6 fd ff ff       	call   800c1e <sys_page_map>
	sys_page_unmap(curenvid, PFTEMP);
  800e58:	83 c4 18             	add    $0x18,%esp
  800e5b:	68 00 f0 7f 00       	push   $0x7ff000
  800e60:	56                   	push   %esi
  800e61:	e8 fa fd ff ff       	call   800c60 <sys_page_unmap>
}
  800e66:	83 c4 10             	add    $0x10,%esp
  800e69:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e6c:	5b                   	pop    %ebx
  800e6d:	5e                   	pop    %esi
  800e6e:	5f                   	pop    %edi
  800e6f:	5d                   	pop    %ebp
  800e70:	c3                   	ret    

00800e71 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e71:	55                   	push   %ebp
  800e72:	89 e5                	mov    %esp,%ebp
  800e74:	57                   	push   %edi
  800e75:	56                   	push   %esi
  800e76:	53                   	push   %ebx
  800e77:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	extern void _pgfault_upcall();
	envid_t new_envid, curenv_id;

	curenv_id = sys_getenvid();
  800e7a:	e8 1e fd ff ff       	call   800b9d <sys_getenvid>
	set_pgfault_handler(pgfault);
  800e7f:	83 ec 0c             	sub    $0xc,%esp
  800e82:	68 cc 0d 80 00       	push   $0x800dcc
  800e87:	e8 c9 0e 00 00       	call   801d55 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800e8c:	b8 07 00 00 00       	mov    $0x7,%eax
  800e91:	cd 30                	int    $0x30
  800e93:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800e96:	89 45 dc             	mov    %eax,-0x24(%ebp)
	new_envid = sys_exofork();

	if (new_envid < 0)
  800e99:	83 c4 10             	add    $0x10,%esp
  800e9c:	85 c0                	test   %eax,%eax
  800e9e:	79 12                	jns    800eb2 <fork+0x41>
	    panic("fork error: %e", new_envid);
  800ea0:	50                   	push   %eax
  800ea1:	68 1c 25 80 00       	push   $0x80251c
  800ea6:	6a 75                	push   $0x75
  800ea8:	68 11 25 80 00       	push   $0x802511
  800ead:	e8 5d 0e 00 00       	call   801d0f <_panic>
  800eb2:	bf 00 00 80 00       	mov    $0x800000,%edi
	else if (new_envid == 0)
  800eb7:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800ebb:	75 1c                	jne    800ed9 <fork+0x68>
		thisenv = envs + ENVX(sys_getenvid());
  800ebd:	e8 db fc ff ff       	call   800b9d <sys_getenvid>
  800ec2:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ec7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800eca:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ecf:	a3 04 40 80 00       	mov    %eax,0x804004
  800ed4:	e9 27 01 00 00       	jmp    801000 <fork+0x18f>
	else {

		for (uint32_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
			if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
  800ed9:	89 f8                	mov    %edi,%eax
  800edb:	c1 e8 16             	shr    $0x16,%eax
  800ede:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ee5:	a8 01                	test   $0x1,%al
  800ee7:	0f 84 d2 00 00 00    	je     800fbf <fork+0x14e>
  800eed:	89 fb                	mov    %edi,%ebx
  800eef:	c1 eb 0c             	shr    $0xc,%ebx
  800ef2:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800ef9:	a8 01                	test   $0x1,%al
  800efb:	0f 84 be 00 00 00    	je     800fbf <fork+0x14e>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	int perm = PTE_U | PTE_P;
	envid_t curenvid = sys_getenvid();
  800f01:	e8 97 fc ff ff       	call   800b9d <sys_getenvid>
  800f06:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  800f09:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
		perm |= PTE_COW ;
  800f10:	be 05 08 00 00       	mov    $0x805,%esi
	int r;
	int perm = PTE_U | PTE_P;
	envid_t curenvid = sys_getenvid();

	// LAB 4: Your code here.
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  800f15:	a8 02                	test   $0x2,%al
  800f17:	75 1d                	jne    800f36 <fork+0xc5>
  800f19:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f20:	25 00 08 00 00       	and    $0x800,%eax
		perm |= PTE_COW ;
  800f25:	83 f8 01             	cmp    $0x1,%eax
  800f28:	19 f6                	sbb    %esi,%esi
  800f2a:	81 e6 00 f8 ff ff    	and    $0xfffff800,%esi
  800f30:	81 c6 05 08 00 00    	add    $0x805,%esi

	if (uvpt[pn] & PTE_SHARE)
  800f36:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f3d:	25 00 04 00 00       	and    $0x400,%eax
		perm |= PTE_SYSCALL;
  800f42:	b8 07 0e 00 00       	mov    $0xe07,%eax
  800f47:	0f 45 f0             	cmovne %eax,%esi

	r = sys_page_map(curenvid, (void *)(pn * PGSIZE),
  800f4a:	89 d8                	mov    %ebx,%eax
  800f4c:	c1 e0 0c             	shl    $0xc,%eax
  800f4f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800f52:	83 ec 0c             	sub    $0xc,%esp
  800f55:	56                   	push   %esi
  800f56:	50                   	push   %eax
  800f57:	ff 75 dc             	pushl  -0x24(%ebp)
  800f5a:	50                   	push   %eax
  800f5b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f5e:	e8 bb fc ff ff       	call   800c1e <sys_page_map>
				envid, (void *)(pn * PGSIZE), perm);
	if (r < 0)
  800f63:	83 c4 20             	add    $0x20,%esp
  800f66:	85 c0                	test   %eax,%eax
  800f68:	79 12                	jns    800f7c <fork+0x10b>
		panic("duppage error: %e", r);
  800f6a:	50                   	push   %eax
  800f6b:	68 2b 25 80 00       	push   $0x80252b
  800f70:	6a 4d                	push   $0x4d
  800f72:	68 11 25 80 00       	push   $0x802511
  800f77:	e8 93 0d 00 00       	call   801d0f <_panic>
	
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))	{
  800f7c:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f83:	a8 02                	test   $0x2,%al
  800f85:	75 0c                	jne    800f93 <fork+0x122>
  800f87:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f8e:	f6 c4 08             	test   $0x8,%ah
  800f91:	74 2c                	je     800fbf <fork+0x14e>
		r = sys_page_map(curenvid, (void *)(pn * PGSIZE),
  800f93:	83 ec 0c             	sub    $0xc,%esp
  800f96:	56                   	push   %esi
  800f97:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800f9a:	52                   	push   %edx
  800f9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f9e:	50                   	push   %eax
  800f9f:	52                   	push   %edx
  800fa0:	50                   	push   %eax
  800fa1:	e8 78 fc ff ff       	call   800c1e <sys_page_map>
						curenvid, (void *)(pn * PGSIZE), perm);
		if (r < 0)
  800fa6:	83 c4 20             	add    $0x20,%esp
  800fa9:	85 c0                	test   %eax,%eax
  800fab:	79 12                	jns    800fbf <fork+0x14e>
			panic("duppage error: %e", r);
  800fad:	50                   	push   %eax
  800fae:	68 2b 25 80 00       	push   $0x80252b
  800fb3:	6a 53                	push   $0x53
  800fb5:	68 11 25 80 00       	push   $0x802511
  800fba:	e8 50 0d 00 00       	call   801d0f <_panic>
	    panic("fork error: %e", new_envid);
	else if (new_envid == 0)
		thisenv = envs + ENVX(sys_getenvid());
	else {

		for (uint32_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
  800fbf:	81 c7 00 10 00 00    	add    $0x1000,%edi
  800fc5:	81 ff 00 e0 bf ee    	cmp    $0xeebfe000,%edi
  800fcb:	0f 85 08 ff ff ff    	jne    800ed9 <fork+0x68>
			if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
				duppage(new_envid, PGNUM(addr));
		}

		sys_page_alloc(new_envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  800fd1:	83 ec 04             	sub    $0x4,%esp
  800fd4:	6a 07                	push   $0x7
  800fd6:	68 00 f0 bf ee       	push   $0xeebff000
  800fdb:	8b 75 d8             	mov    -0x28(%ebp),%esi
  800fde:	56                   	push   %esi
  800fdf:	e8 f7 fb ff ff       	call   800bdb <sys_page_alloc>
		sys_env_set_pgfault_upcall(new_envid, _pgfault_upcall);
  800fe4:	83 c4 08             	add    $0x8,%esp
  800fe7:	68 9a 1d 80 00       	push   $0x801d9a
  800fec:	56                   	push   %esi
  800fed:	e8 34 fd ff ff       	call   800d26 <sys_env_set_pgfault_upcall>
		sys_env_set_status(new_envid, ENV_RUNNABLE);
  800ff2:	83 c4 08             	add    $0x8,%esp
  800ff5:	6a 02                	push   $0x2
  800ff7:	56                   	push   %esi
  800ff8:	e8 a5 fc ff ff       	call   800ca2 <sys_env_set_status>
  800ffd:	83 c4 10             	add    $0x10,%esp

	}
	return new_envid;
}
  801000:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801003:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801006:	5b                   	pop    %ebx
  801007:	5e                   	pop    %esi
  801008:	5f                   	pop    %edi
  801009:	5d                   	pop    %ebp
  80100a:	c3                   	ret    

0080100b <sfork>:

// Challenge!
int
sfork(void)
{
  80100b:	55                   	push   %ebp
  80100c:	89 e5                	mov    %esp,%ebp
  80100e:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801011:	68 3d 25 80 00       	push   $0x80253d
  801016:	68 8b 00 00 00       	push   $0x8b
  80101b:	68 11 25 80 00       	push   $0x802511
  801020:	e8 ea 0c 00 00       	call   801d0f <_panic>

00801025 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801025:	55                   	push   %ebp
  801026:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801028:	8b 45 08             	mov    0x8(%ebp),%eax
  80102b:	05 00 00 00 30       	add    $0x30000000,%eax
  801030:	c1 e8 0c             	shr    $0xc,%eax
}
  801033:	5d                   	pop    %ebp
  801034:	c3                   	ret    

00801035 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801035:	55                   	push   %ebp
  801036:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801038:	8b 45 08             	mov    0x8(%ebp),%eax
  80103b:	05 00 00 00 30       	add    $0x30000000,%eax
  801040:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801045:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80104a:	5d                   	pop    %ebp
  80104b:	c3                   	ret    

0080104c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80104c:	55                   	push   %ebp
  80104d:	89 e5                	mov    %esp,%ebp
  80104f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801052:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801057:	89 c2                	mov    %eax,%edx
  801059:	c1 ea 16             	shr    $0x16,%edx
  80105c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801063:	f6 c2 01             	test   $0x1,%dl
  801066:	74 11                	je     801079 <fd_alloc+0x2d>
  801068:	89 c2                	mov    %eax,%edx
  80106a:	c1 ea 0c             	shr    $0xc,%edx
  80106d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801074:	f6 c2 01             	test   $0x1,%dl
  801077:	75 09                	jne    801082 <fd_alloc+0x36>
			*fd_store = fd;
  801079:	89 01                	mov    %eax,(%ecx)
			return 0;
  80107b:	b8 00 00 00 00       	mov    $0x0,%eax
  801080:	eb 17                	jmp    801099 <fd_alloc+0x4d>
  801082:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801087:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80108c:	75 c9                	jne    801057 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80108e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801094:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801099:	5d                   	pop    %ebp
  80109a:	c3                   	ret    

0080109b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80109b:	55                   	push   %ebp
  80109c:	89 e5                	mov    %esp,%ebp
  80109e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010a1:	83 f8 1f             	cmp    $0x1f,%eax
  8010a4:	77 36                	ja     8010dc <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010a6:	c1 e0 0c             	shl    $0xc,%eax
  8010a9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010ae:	89 c2                	mov    %eax,%edx
  8010b0:	c1 ea 16             	shr    $0x16,%edx
  8010b3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010ba:	f6 c2 01             	test   $0x1,%dl
  8010bd:	74 24                	je     8010e3 <fd_lookup+0x48>
  8010bf:	89 c2                	mov    %eax,%edx
  8010c1:	c1 ea 0c             	shr    $0xc,%edx
  8010c4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010cb:	f6 c2 01             	test   $0x1,%dl
  8010ce:	74 1a                	je     8010ea <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010d0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010d3:	89 02                	mov    %eax,(%edx)
	return 0;
  8010d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8010da:	eb 13                	jmp    8010ef <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010dc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010e1:	eb 0c                	jmp    8010ef <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010e8:	eb 05                	jmp    8010ef <fd_lookup+0x54>
  8010ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8010ef:	5d                   	pop    %ebp
  8010f0:	c3                   	ret    

008010f1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8010f1:	55                   	push   %ebp
  8010f2:	89 e5                	mov    %esp,%ebp
  8010f4:	83 ec 08             	sub    $0x8,%esp
  8010f7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010fa:	ba d0 25 80 00       	mov    $0x8025d0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8010ff:	eb 13                	jmp    801114 <dev_lookup+0x23>
  801101:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801104:	39 08                	cmp    %ecx,(%eax)
  801106:	75 0c                	jne    801114 <dev_lookup+0x23>
			*dev = devtab[i];
  801108:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80110b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80110d:	b8 00 00 00 00       	mov    $0x0,%eax
  801112:	eb 2e                	jmp    801142 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801114:	8b 02                	mov    (%edx),%eax
  801116:	85 c0                	test   %eax,%eax
  801118:	75 e7                	jne    801101 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80111a:	a1 04 40 80 00       	mov    0x804004,%eax
  80111f:	8b 40 48             	mov    0x48(%eax),%eax
  801122:	83 ec 04             	sub    $0x4,%esp
  801125:	51                   	push   %ecx
  801126:	50                   	push   %eax
  801127:	68 54 25 80 00       	push   $0x802554
  80112c:	e8 a3 f0 ff ff       	call   8001d4 <cprintf>
	*dev = 0;
  801131:	8b 45 0c             	mov    0xc(%ebp),%eax
  801134:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80113a:	83 c4 10             	add    $0x10,%esp
  80113d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801142:	c9                   	leave  
  801143:	c3                   	ret    

00801144 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801144:	55                   	push   %ebp
  801145:	89 e5                	mov    %esp,%ebp
  801147:	56                   	push   %esi
  801148:	53                   	push   %ebx
  801149:	83 ec 10             	sub    $0x10,%esp
  80114c:	8b 75 08             	mov    0x8(%ebp),%esi
  80114f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801152:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801155:	50                   	push   %eax
  801156:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80115c:	c1 e8 0c             	shr    $0xc,%eax
  80115f:	50                   	push   %eax
  801160:	e8 36 ff ff ff       	call   80109b <fd_lookup>
  801165:	83 c4 08             	add    $0x8,%esp
  801168:	85 c0                	test   %eax,%eax
  80116a:	78 05                	js     801171 <fd_close+0x2d>
	    || fd != fd2)
  80116c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80116f:	74 0c                	je     80117d <fd_close+0x39>
		return (must_exist ? r : 0);
  801171:	84 db                	test   %bl,%bl
  801173:	ba 00 00 00 00       	mov    $0x0,%edx
  801178:	0f 44 c2             	cmove  %edx,%eax
  80117b:	eb 41                	jmp    8011be <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80117d:	83 ec 08             	sub    $0x8,%esp
  801180:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801183:	50                   	push   %eax
  801184:	ff 36                	pushl  (%esi)
  801186:	e8 66 ff ff ff       	call   8010f1 <dev_lookup>
  80118b:	89 c3                	mov    %eax,%ebx
  80118d:	83 c4 10             	add    $0x10,%esp
  801190:	85 c0                	test   %eax,%eax
  801192:	78 1a                	js     8011ae <fd_close+0x6a>
		if (dev->dev_close)
  801194:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801197:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80119a:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80119f:	85 c0                	test   %eax,%eax
  8011a1:	74 0b                	je     8011ae <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8011a3:	83 ec 0c             	sub    $0xc,%esp
  8011a6:	56                   	push   %esi
  8011a7:	ff d0                	call   *%eax
  8011a9:	89 c3                	mov    %eax,%ebx
  8011ab:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011ae:	83 ec 08             	sub    $0x8,%esp
  8011b1:	56                   	push   %esi
  8011b2:	6a 00                	push   $0x0
  8011b4:	e8 a7 fa ff ff       	call   800c60 <sys_page_unmap>
	return r;
  8011b9:	83 c4 10             	add    $0x10,%esp
  8011bc:	89 d8                	mov    %ebx,%eax
}
  8011be:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011c1:	5b                   	pop    %ebx
  8011c2:	5e                   	pop    %esi
  8011c3:	5d                   	pop    %ebp
  8011c4:	c3                   	ret    

008011c5 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011c5:	55                   	push   %ebp
  8011c6:	89 e5                	mov    %esp,%ebp
  8011c8:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ce:	50                   	push   %eax
  8011cf:	ff 75 08             	pushl  0x8(%ebp)
  8011d2:	e8 c4 fe ff ff       	call   80109b <fd_lookup>
  8011d7:	83 c4 08             	add    $0x8,%esp
  8011da:	85 c0                	test   %eax,%eax
  8011dc:	78 10                	js     8011ee <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8011de:	83 ec 08             	sub    $0x8,%esp
  8011e1:	6a 01                	push   $0x1
  8011e3:	ff 75 f4             	pushl  -0xc(%ebp)
  8011e6:	e8 59 ff ff ff       	call   801144 <fd_close>
  8011eb:	83 c4 10             	add    $0x10,%esp
}
  8011ee:	c9                   	leave  
  8011ef:	c3                   	ret    

008011f0 <close_all>:

void
close_all(void)
{
  8011f0:	55                   	push   %ebp
  8011f1:	89 e5                	mov    %esp,%ebp
  8011f3:	53                   	push   %ebx
  8011f4:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8011f7:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8011fc:	83 ec 0c             	sub    $0xc,%esp
  8011ff:	53                   	push   %ebx
  801200:	e8 c0 ff ff ff       	call   8011c5 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801205:	83 c3 01             	add    $0x1,%ebx
  801208:	83 c4 10             	add    $0x10,%esp
  80120b:	83 fb 20             	cmp    $0x20,%ebx
  80120e:	75 ec                	jne    8011fc <close_all+0xc>
		close(i);
}
  801210:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801213:	c9                   	leave  
  801214:	c3                   	ret    

00801215 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801215:	55                   	push   %ebp
  801216:	89 e5                	mov    %esp,%ebp
  801218:	57                   	push   %edi
  801219:	56                   	push   %esi
  80121a:	53                   	push   %ebx
  80121b:	83 ec 2c             	sub    $0x2c,%esp
  80121e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801221:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801224:	50                   	push   %eax
  801225:	ff 75 08             	pushl  0x8(%ebp)
  801228:	e8 6e fe ff ff       	call   80109b <fd_lookup>
  80122d:	83 c4 08             	add    $0x8,%esp
  801230:	85 c0                	test   %eax,%eax
  801232:	0f 88 c1 00 00 00    	js     8012f9 <dup+0xe4>
		return r;
	close(newfdnum);
  801238:	83 ec 0c             	sub    $0xc,%esp
  80123b:	56                   	push   %esi
  80123c:	e8 84 ff ff ff       	call   8011c5 <close>

	newfd = INDEX2FD(newfdnum);
  801241:	89 f3                	mov    %esi,%ebx
  801243:	c1 e3 0c             	shl    $0xc,%ebx
  801246:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80124c:	83 c4 04             	add    $0x4,%esp
  80124f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801252:	e8 de fd ff ff       	call   801035 <fd2data>
  801257:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801259:	89 1c 24             	mov    %ebx,(%esp)
  80125c:	e8 d4 fd ff ff       	call   801035 <fd2data>
  801261:	83 c4 10             	add    $0x10,%esp
  801264:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801267:	89 f8                	mov    %edi,%eax
  801269:	c1 e8 16             	shr    $0x16,%eax
  80126c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801273:	a8 01                	test   $0x1,%al
  801275:	74 37                	je     8012ae <dup+0x99>
  801277:	89 f8                	mov    %edi,%eax
  801279:	c1 e8 0c             	shr    $0xc,%eax
  80127c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801283:	f6 c2 01             	test   $0x1,%dl
  801286:	74 26                	je     8012ae <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801288:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80128f:	83 ec 0c             	sub    $0xc,%esp
  801292:	25 07 0e 00 00       	and    $0xe07,%eax
  801297:	50                   	push   %eax
  801298:	ff 75 d4             	pushl  -0x2c(%ebp)
  80129b:	6a 00                	push   $0x0
  80129d:	57                   	push   %edi
  80129e:	6a 00                	push   $0x0
  8012a0:	e8 79 f9 ff ff       	call   800c1e <sys_page_map>
  8012a5:	89 c7                	mov    %eax,%edi
  8012a7:	83 c4 20             	add    $0x20,%esp
  8012aa:	85 c0                	test   %eax,%eax
  8012ac:	78 2e                	js     8012dc <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012ae:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012b1:	89 d0                	mov    %edx,%eax
  8012b3:	c1 e8 0c             	shr    $0xc,%eax
  8012b6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012bd:	83 ec 0c             	sub    $0xc,%esp
  8012c0:	25 07 0e 00 00       	and    $0xe07,%eax
  8012c5:	50                   	push   %eax
  8012c6:	53                   	push   %ebx
  8012c7:	6a 00                	push   $0x0
  8012c9:	52                   	push   %edx
  8012ca:	6a 00                	push   $0x0
  8012cc:	e8 4d f9 ff ff       	call   800c1e <sys_page_map>
  8012d1:	89 c7                	mov    %eax,%edi
  8012d3:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8012d6:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012d8:	85 ff                	test   %edi,%edi
  8012da:	79 1d                	jns    8012f9 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8012dc:	83 ec 08             	sub    $0x8,%esp
  8012df:	53                   	push   %ebx
  8012e0:	6a 00                	push   $0x0
  8012e2:	e8 79 f9 ff ff       	call   800c60 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8012e7:	83 c4 08             	add    $0x8,%esp
  8012ea:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012ed:	6a 00                	push   $0x0
  8012ef:	e8 6c f9 ff ff       	call   800c60 <sys_page_unmap>
	return r;
  8012f4:	83 c4 10             	add    $0x10,%esp
  8012f7:	89 f8                	mov    %edi,%eax
}
  8012f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012fc:	5b                   	pop    %ebx
  8012fd:	5e                   	pop    %esi
  8012fe:	5f                   	pop    %edi
  8012ff:	5d                   	pop    %ebp
  801300:	c3                   	ret    

00801301 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801301:	55                   	push   %ebp
  801302:	89 e5                	mov    %esp,%ebp
  801304:	53                   	push   %ebx
  801305:	83 ec 14             	sub    $0x14,%esp
  801308:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80130b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80130e:	50                   	push   %eax
  80130f:	53                   	push   %ebx
  801310:	e8 86 fd ff ff       	call   80109b <fd_lookup>
  801315:	83 c4 08             	add    $0x8,%esp
  801318:	89 c2                	mov    %eax,%edx
  80131a:	85 c0                	test   %eax,%eax
  80131c:	78 6d                	js     80138b <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80131e:	83 ec 08             	sub    $0x8,%esp
  801321:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801324:	50                   	push   %eax
  801325:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801328:	ff 30                	pushl  (%eax)
  80132a:	e8 c2 fd ff ff       	call   8010f1 <dev_lookup>
  80132f:	83 c4 10             	add    $0x10,%esp
  801332:	85 c0                	test   %eax,%eax
  801334:	78 4c                	js     801382 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801336:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801339:	8b 42 08             	mov    0x8(%edx),%eax
  80133c:	83 e0 03             	and    $0x3,%eax
  80133f:	83 f8 01             	cmp    $0x1,%eax
  801342:	75 21                	jne    801365 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801344:	a1 04 40 80 00       	mov    0x804004,%eax
  801349:	8b 40 48             	mov    0x48(%eax),%eax
  80134c:	83 ec 04             	sub    $0x4,%esp
  80134f:	53                   	push   %ebx
  801350:	50                   	push   %eax
  801351:	68 95 25 80 00       	push   $0x802595
  801356:	e8 79 ee ff ff       	call   8001d4 <cprintf>
		return -E_INVAL;
  80135b:	83 c4 10             	add    $0x10,%esp
  80135e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801363:	eb 26                	jmp    80138b <read+0x8a>
	}
	if (!dev->dev_read)
  801365:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801368:	8b 40 08             	mov    0x8(%eax),%eax
  80136b:	85 c0                	test   %eax,%eax
  80136d:	74 17                	je     801386 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80136f:	83 ec 04             	sub    $0x4,%esp
  801372:	ff 75 10             	pushl  0x10(%ebp)
  801375:	ff 75 0c             	pushl  0xc(%ebp)
  801378:	52                   	push   %edx
  801379:	ff d0                	call   *%eax
  80137b:	89 c2                	mov    %eax,%edx
  80137d:	83 c4 10             	add    $0x10,%esp
  801380:	eb 09                	jmp    80138b <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801382:	89 c2                	mov    %eax,%edx
  801384:	eb 05                	jmp    80138b <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801386:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80138b:	89 d0                	mov    %edx,%eax
  80138d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801390:	c9                   	leave  
  801391:	c3                   	ret    

00801392 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801392:	55                   	push   %ebp
  801393:	89 e5                	mov    %esp,%ebp
  801395:	57                   	push   %edi
  801396:	56                   	push   %esi
  801397:	53                   	push   %ebx
  801398:	83 ec 0c             	sub    $0xc,%esp
  80139b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80139e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013a1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013a6:	eb 21                	jmp    8013c9 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013a8:	83 ec 04             	sub    $0x4,%esp
  8013ab:	89 f0                	mov    %esi,%eax
  8013ad:	29 d8                	sub    %ebx,%eax
  8013af:	50                   	push   %eax
  8013b0:	89 d8                	mov    %ebx,%eax
  8013b2:	03 45 0c             	add    0xc(%ebp),%eax
  8013b5:	50                   	push   %eax
  8013b6:	57                   	push   %edi
  8013b7:	e8 45 ff ff ff       	call   801301 <read>
		if (m < 0)
  8013bc:	83 c4 10             	add    $0x10,%esp
  8013bf:	85 c0                	test   %eax,%eax
  8013c1:	78 10                	js     8013d3 <readn+0x41>
			return m;
		if (m == 0)
  8013c3:	85 c0                	test   %eax,%eax
  8013c5:	74 0a                	je     8013d1 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013c7:	01 c3                	add    %eax,%ebx
  8013c9:	39 f3                	cmp    %esi,%ebx
  8013cb:	72 db                	jb     8013a8 <readn+0x16>
  8013cd:	89 d8                	mov    %ebx,%eax
  8013cf:	eb 02                	jmp    8013d3 <readn+0x41>
  8013d1:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8013d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013d6:	5b                   	pop    %ebx
  8013d7:	5e                   	pop    %esi
  8013d8:	5f                   	pop    %edi
  8013d9:	5d                   	pop    %ebp
  8013da:	c3                   	ret    

008013db <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8013db:	55                   	push   %ebp
  8013dc:	89 e5                	mov    %esp,%ebp
  8013de:	53                   	push   %ebx
  8013df:	83 ec 14             	sub    $0x14,%esp
  8013e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013e8:	50                   	push   %eax
  8013e9:	53                   	push   %ebx
  8013ea:	e8 ac fc ff ff       	call   80109b <fd_lookup>
  8013ef:	83 c4 08             	add    $0x8,%esp
  8013f2:	89 c2                	mov    %eax,%edx
  8013f4:	85 c0                	test   %eax,%eax
  8013f6:	78 68                	js     801460 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013f8:	83 ec 08             	sub    $0x8,%esp
  8013fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013fe:	50                   	push   %eax
  8013ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801402:	ff 30                	pushl  (%eax)
  801404:	e8 e8 fc ff ff       	call   8010f1 <dev_lookup>
  801409:	83 c4 10             	add    $0x10,%esp
  80140c:	85 c0                	test   %eax,%eax
  80140e:	78 47                	js     801457 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801410:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801413:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801417:	75 21                	jne    80143a <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801419:	a1 04 40 80 00       	mov    0x804004,%eax
  80141e:	8b 40 48             	mov    0x48(%eax),%eax
  801421:	83 ec 04             	sub    $0x4,%esp
  801424:	53                   	push   %ebx
  801425:	50                   	push   %eax
  801426:	68 b1 25 80 00       	push   $0x8025b1
  80142b:	e8 a4 ed ff ff       	call   8001d4 <cprintf>
		return -E_INVAL;
  801430:	83 c4 10             	add    $0x10,%esp
  801433:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801438:	eb 26                	jmp    801460 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80143a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80143d:	8b 52 0c             	mov    0xc(%edx),%edx
  801440:	85 d2                	test   %edx,%edx
  801442:	74 17                	je     80145b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801444:	83 ec 04             	sub    $0x4,%esp
  801447:	ff 75 10             	pushl  0x10(%ebp)
  80144a:	ff 75 0c             	pushl  0xc(%ebp)
  80144d:	50                   	push   %eax
  80144e:	ff d2                	call   *%edx
  801450:	89 c2                	mov    %eax,%edx
  801452:	83 c4 10             	add    $0x10,%esp
  801455:	eb 09                	jmp    801460 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801457:	89 c2                	mov    %eax,%edx
  801459:	eb 05                	jmp    801460 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80145b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801460:	89 d0                	mov    %edx,%eax
  801462:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801465:	c9                   	leave  
  801466:	c3                   	ret    

00801467 <seek>:

int
seek(int fdnum, off_t offset)
{
  801467:	55                   	push   %ebp
  801468:	89 e5                	mov    %esp,%ebp
  80146a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80146d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801470:	50                   	push   %eax
  801471:	ff 75 08             	pushl  0x8(%ebp)
  801474:	e8 22 fc ff ff       	call   80109b <fd_lookup>
  801479:	83 c4 08             	add    $0x8,%esp
  80147c:	85 c0                	test   %eax,%eax
  80147e:	78 0e                	js     80148e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801480:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801483:	8b 55 0c             	mov    0xc(%ebp),%edx
  801486:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801489:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80148e:	c9                   	leave  
  80148f:	c3                   	ret    

00801490 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801490:	55                   	push   %ebp
  801491:	89 e5                	mov    %esp,%ebp
  801493:	53                   	push   %ebx
  801494:	83 ec 14             	sub    $0x14,%esp
  801497:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80149a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80149d:	50                   	push   %eax
  80149e:	53                   	push   %ebx
  80149f:	e8 f7 fb ff ff       	call   80109b <fd_lookup>
  8014a4:	83 c4 08             	add    $0x8,%esp
  8014a7:	89 c2                	mov    %eax,%edx
  8014a9:	85 c0                	test   %eax,%eax
  8014ab:	78 65                	js     801512 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ad:	83 ec 08             	sub    $0x8,%esp
  8014b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b3:	50                   	push   %eax
  8014b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b7:	ff 30                	pushl  (%eax)
  8014b9:	e8 33 fc ff ff       	call   8010f1 <dev_lookup>
  8014be:	83 c4 10             	add    $0x10,%esp
  8014c1:	85 c0                	test   %eax,%eax
  8014c3:	78 44                	js     801509 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014cc:	75 21                	jne    8014ef <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8014ce:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014d3:	8b 40 48             	mov    0x48(%eax),%eax
  8014d6:	83 ec 04             	sub    $0x4,%esp
  8014d9:	53                   	push   %ebx
  8014da:	50                   	push   %eax
  8014db:	68 74 25 80 00       	push   $0x802574
  8014e0:	e8 ef ec ff ff       	call   8001d4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8014e5:	83 c4 10             	add    $0x10,%esp
  8014e8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014ed:	eb 23                	jmp    801512 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8014ef:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014f2:	8b 52 18             	mov    0x18(%edx),%edx
  8014f5:	85 d2                	test   %edx,%edx
  8014f7:	74 14                	je     80150d <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8014f9:	83 ec 08             	sub    $0x8,%esp
  8014fc:	ff 75 0c             	pushl  0xc(%ebp)
  8014ff:	50                   	push   %eax
  801500:	ff d2                	call   *%edx
  801502:	89 c2                	mov    %eax,%edx
  801504:	83 c4 10             	add    $0x10,%esp
  801507:	eb 09                	jmp    801512 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801509:	89 c2                	mov    %eax,%edx
  80150b:	eb 05                	jmp    801512 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80150d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801512:	89 d0                	mov    %edx,%eax
  801514:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801517:	c9                   	leave  
  801518:	c3                   	ret    

00801519 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801519:	55                   	push   %ebp
  80151a:	89 e5                	mov    %esp,%ebp
  80151c:	53                   	push   %ebx
  80151d:	83 ec 14             	sub    $0x14,%esp
  801520:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801523:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801526:	50                   	push   %eax
  801527:	ff 75 08             	pushl  0x8(%ebp)
  80152a:	e8 6c fb ff ff       	call   80109b <fd_lookup>
  80152f:	83 c4 08             	add    $0x8,%esp
  801532:	89 c2                	mov    %eax,%edx
  801534:	85 c0                	test   %eax,%eax
  801536:	78 58                	js     801590 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801538:	83 ec 08             	sub    $0x8,%esp
  80153b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80153e:	50                   	push   %eax
  80153f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801542:	ff 30                	pushl  (%eax)
  801544:	e8 a8 fb ff ff       	call   8010f1 <dev_lookup>
  801549:	83 c4 10             	add    $0x10,%esp
  80154c:	85 c0                	test   %eax,%eax
  80154e:	78 37                	js     801587 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801550:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801553:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801557:	74 32                	je     80158b <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801559:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80155c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801563:	00 00 00 
	stat->st_isdir = 0;
  801566:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80156d:	00 00 00 
	stat->st_dev = dev;
  801570:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801576:	83 ec 08             	sub    $0x8,%esp
  801579:	53                   	push   %ebx
  80157a:	ff 75 f0             	pushl  -0x10(%ebp)
  80157d:	ff 50 14             	call   *0x14(%eax)
  801580:	89 c2                	mov    %eax,%edx
  801582:	83 c4 10             	add    $0x10,%esp
  801585:	eb 09                	jmp    801590 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801587:	89 c2                	mov    %eax,%edx
  801589:	eb 05                	jmp    801590 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80158b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801590:	89 d0                	mov    %edx,%eax
  801592:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801595:	c9                   	leave  
  801596:	c3                   	ret    

00801597 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801597:	55                   	push   %ebp
  801598:	89 e5                	mov    %esp,%ebp
  80159a:	56                   	push   %esi
  80159b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80159c:	83 ec 08             	sub    $0x8,%esp
  80159f:	6a 00                	push   $0x0
  8015a1:	ff 75 08             	pushl  0x8(%ebp)
  8015a4:	e8 e3 01 00 00       	call   80178c <open>
  8015a9:	89 c3                	mov    %eax,%ebx
  8015ab:	83 c4 10             	add    $0x10,%esp
  8015ae:	85 c0                	test   %eax,%eax
  8015b0:	78 1b                	js     8015cd <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015b2:	83 ec 08             	sub    $0x8,%esp
  8015b5:	ff 75 0c             	pushl  0xc(%ebp)
  8015b8:	50                   	push   %eax
  8015b9:	e8 5b ff ff ff       	call   801519 <fstat>
  8015be:	89 c6                	mov    %eax,%esi
	close(fd);
  8015c0:	89 1c 24             	mov    %ebx,(%esp)
  8015c3:	e8 fd fb ff ff       	call   8011c5 <close>
	return r;
  8015c8:	83 c4 10             	add    $0x10,%esp
  8015cb:	89 f0                	mov    %esi,%eax
}
  8015cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015d0:	5b                   	pop    %ebx
  8015d1:	5e                   	pop    %esi
  8015d2:	5d                   	pop    %ebp
  8015d3:	c3                   	ret    

008015d4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015d4:	55                   	push   %ebp
  8015d5:	89 e5                	mov    %esp,%ebp
  8015d7:	56                   	push   %esi
  8015d8:	53                   	push   %ebx
  8015d9:	89 c6                	mov    %eax,%esi
  8015db:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8015dd:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8015e4:	75 12                	jne    8015f8 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8015e6:	83 ec 0c             	sub    $0xc,%esp
  8015e9:	6a 01                	push   $0x1
  8015eb:	e8 96 08 00 00       	call   801e86 <ipc_find_env>
  8015f0:	a3 00 40 80 00       	mov    %eax,0x804000
  8015f5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8015f8:	6a 07                	push   $0x7
  8015fa:	68 00 50 80 00       	push   $0x805000
  8015ff:	56                   	push   %esi
  801600:	ff 35 00 40 80 00    	pushl  0x804000
  801606:	e8 27 08 00 00       	call   801e32 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80160b:	83 c4 0c             	add    $0xc,%esp
  80160e:	6a 00                	push   $0x0
  801610:	53                   	push   %ebx
  801611:	6a 00                	push   $0x0
  801613:	e8 a8 07 00 00       	call   801dc0 <ipc_recv>
}
  801618:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80161b:	5b                   	pop    %ebx
  80161c:	5e                   	pop    %esi
  80161d:	5d                   	pop    %ebp
  80161e:	c3                   	ret    

0080161f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80161f:	55                   	push   %ebp
  801620:	89 e5                	mov    %esp,%ebp
  801622:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801625:	8b 45 08             	mov    0x8(%ebp),%eax
  801628:	8b 40 0c             	mov    0xc(%eax),%eax
  80162b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801630:	8b 45 0c             	mov    0xc(%ebp),%eax
  801633:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801638:	ba 00 00 00 00       	mov    $0x0,%edx
  80163d:	b8 02 00 00 00       	mov    $0x2,%eax
  801642:	e8 8d ff ff ff       	call   8015d4 <fsipc>
}
  801647:	c9                   	leave  
  801648:	c3                   	ret    

00801649 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801649:	55                   	push   %ebp
  80164a:	89 e5                	mov    %esp,%ebp
  80164c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80164f:	8b 45 08             	mov    0x8(%ebp),%eax
  801652:	8b 40 0c             	mov    0xc(%eax),%eax
  801655:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80165a:	ba 00 00 00 00       	mov    $0x0,%edx
  80165f:	b8 06 00 00 00       	mov    $0x6,%eax
  801664:	e8 6b ff ff ff       	call   8015d4 <fsipc>
}
  801669:	c9                   	leave  
  80166a:	c3                   	ret    

0080166b <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80166b:	55                   	push   %ebp
  80166c:	89 e5                	mov    %esp,%ebp
  80166e:	53                   	push   %ebx
  80166f:	83 ec 04             	sub    $0x4,%esp
  801672:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801675:	8b 45 08             	mov    0x8(%ebp),%eax
  801678:	8b 40 0c             	mov    0xc(%eax),%eax
  80167b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801680:	ba 00 00 00 00       	mov    $0x0,%edx
  801685:	b8 05 00 00 00       	mov    $0x5,%eax
  80168a:	e8 45 ff ff ff       	call   8015d4 <fsipc>
  80168f:	85 c0                	test   %eax,%eax
  801691:	78 2c                	js     8016bf <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801693:	83 ec 08             	sub    $0x8,%esp
  801696:	68 00 50 80 00       	push   $0x805000
  80169b:	53                   	push   %ebx
  80169c:	e8 37 f1 ff ff       	call   8007d8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016a1:	a1 80 50 80 00       	mov    0x805080,%eax
  8016a6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016ac:	a1 84 50 80 00       	mov    0x805084,%eax
  8016b1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016b7:	83 c4 10             	add    $0x10,%esp
  8016ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c2:	c9                   	leave  
  8016c3:	c3                   	ret    

008016c4 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016c4:	55                   	push   %ebp
  8016c5:	89 e5                	mov    %esp,%ebp
  8016c7:	83 ec 0c             	sub    $0xc,%esp
  8016ca:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	
	int r;

	n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8016cd:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8016d2:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8016d7:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8016da:	8b 55 08             	mov    0x8(%ebp),%edx
  8016dd:	8b 52 0c             	mov    0xc(%edx),%edx
  8016e0:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8016e6:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8016eb:	50                   	push   %eax
  8016ec:	ff 75 0c             	pushl  0xc(%ebp)
  8016ef:	68 08 50 80 00       	push   $0x805008
  8016f4:	e8 71 f2 ff ff       	call   80096a <memmove>
	
	return fsipc(FSREQ_WRITE, NULL);	
  8016f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8016fe:	b8 04 00 00 00       	mov    $0x4,%eax
  801703:	e8 cc fe ff ff       	call   8015d4 <fsipc>
}
  801708:	c9                   	leave  
  801709:	c3                   	ret    

0080170a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80170a:	55                   	push   %ebp
  80170b:	89 e5                	mov    %esp,%ebp
  80170d:	56                   	push   %esi
  80170e:	53                   	push   %ebx
  80170f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801712:	8b 45 08             	mov    0x8(%ebp),%eax
  801715:	8b 40 0c             	mov    0xc(%eax),%eax
  801718:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80171d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801723:	ba 00 00 00 00       	mov    $0x0,%edx
  801728:	b8 03 00 00 00       	mov    $0x3,%eax
  80172d:	e8 a2 fe ff ff       	call   8015d4 <fsipc>
  801732:	89 c3                	mov    %eax,%ebx
  801734:	85 c0                	test   %eax,%eax
  801736:	78 4b                	js     801783 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801738:	39 c6                	cmp    %eax,%esi
  80173a:	73 16                	jae    801752 <devfile_read+0x48>
  80173c:	68 e0 25 80 00       	push   $0x8025e0
  801741:	68 e7 25 80 00       	push   $0x8025e7
  801746:	6a 7c                	push   $0x7c
  801748:	68 fc 25 80 00       	push   $0x8025fc
  80174d:	e8 bd 05 00 00       	call   801d0f <_panic>
	assert(r <= PGSIZE);
  801752:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801757:	7e 16                	jle    80176f <devfile_read+0x65>
  801759:	68 07 26 80 00       	push   $0x802607
  80175e:	68 e7 25 80 00       	push   $0x8025e7
  801763:	6a 7d                	push   $0x7d
  801765:	68 fc 25 80 00       	push   $0x8025fc
  80176a:	e8 a0 05 00 00       	call   801d0f <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80176f:	83 ec 04             	sub    $0x4,%esp
  801772:	50                   	push   %eax
  801773:	68 00 50 80 00       	push   $0x805000
  801778:	ff 75 0c             	pushl  0xc(%ebp)
  80177b:	e8 ea f1 ff ff       	call   80096a <memmove>
	return r;
  801780:	83 c4 10             	add    $0x10,%esp
}
  801783:	89 d8                	mov    %ebx,%eax
  801785:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801788:	5b                   	pop    %ebx
  801789:	5e                   	pop    %esi
  80178a:	5d                   	pop    %ebp
  80178b:	c3                   	ret    

0080178c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80178c:	55                   	push   %ebp
  80178d:	89 e5                	mov    %esp,%ebp
  80178f:	53                   	push   %ebx
  801790:	83 ec 20             	sub    $0x20,%esp
  801793:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801796:	53                   	push   %ebx
  801797:	e8 03 f0 ff ff       	call   80079f <strlen>
  80179c:	83 c4 10             	add    $0x10,%esp
  80179f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017a4:	7f 67                	jg     80180d <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017a6:	83 ec 0c             	sub    $0xc,%esp
  8017a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017ac:	50                   	push   %eax
  8017ad:	e8 9a f8 ff ff       	call   80104c <fd_alloc>
  8017b2:	83 c4 10             	add    $0x10,%esp
		return r;
  8017b5:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017b7:	85 c0                	test   %eax,%eax
  8017b9:	78 57                	js     801812 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017bb:	83 ec 08             	sub    $0x8,%esp
  8017be:	53                   	push   %ebx
  8017bf:	68 00 50 80 00       	push   $0x805000
  8017c4:	e8 0f f0 ff ff       	call   8007d8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017cc:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017d4:	b8 01 00 00 00       	mov    $0x1,%eax
  8017d9:	e8 f6 fd ff ff       	call   8015d4 <fsipc>
  8017de:	89 c3                	mov    %eax,%ebx
  8017e0:	83 c4 10             	add    $0x10,%esp
  8017e3:	85 c0                	test   %eax,%eax
  8017e5:	79 14                	jns    8017fb <open+0x6f>
		fd_close(fd, 0);
  8017e7:	83 ec 08             	sub    $0x8,%esp
  8017ea:	6a 00                	push   $0x0
  8017ec:	ff 75 f4             	pushl  -0xc(%ebp)
  8017ef:	e8 50 f9 ff ff       	call   801144 <fd_close>
		return r;
  8017f4:	83 c4 10             	add    $0x10,%esp
  8017f7:	89 da                	mov    %ebx,%edx
  8017f9:	eb 17                	jmp    801812 <open+0x86>
	}

	return fd2num(fd);
  8017fb:	83 ec 0c             	sub    $0xc,%esp
  8017fe:	ff 75 f4             	pushl  -0xc(%ebp)
  801801:	e8 1f f8 ff ff       	call   801025 <fd2num>
  801806:	89 c2                	mov    %eax,%edx
  801808:	83 c4 10             	add    $0x10,%esp
  80180b:	eb 05                	jmp    801812 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80180d:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801812:	89 d0                	mov    %edx,%eax
  801814:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801817:	c9                   	leave  
  801818:	c3                   	ret    

00801819 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801819:	55                   	push   %ebp
  80181a:	89 e5                	mov    %esp,%ebp
  80181c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80181f:	ba 00 00 00 00       	mov    $0x0,%edx
  801824:	b8 08 00 00 00       	mov    $0x8,%eax
  801829:	e8 a6 fd ff ff       	call   8015d4 <fsipc>
}
  80182e:	c9                   	leave  
  80182f:	c3                   	ret    

00801830 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801830:	55                   	push   %ebp
  801831:	89 e5                	mov    %esp,%ebp
  801833:	56                   	push   %esi
  801834:	53                   	push   %ebx
  801835:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801838:	83 ec 0c             	sub    $0xc,%esp
  80183b:	ff 75 08             	pushl  0x8(%ebp)
  80183e:	e8 f2 f7 ff ff       	call   801035 <fd2data>
  801843:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801845:	83 c4 08             	add    $0x8,%esp
  801848:	68 13 26 80 00       	push   $0x802613
  80184d:	53                   	push   %ebx
  80184e:	e8 85 ef ff ff       	call   8007d8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801853:	8b 46 04             	mov    0x4(%esi),%eax
  801856:	2b 06                	sub    (%esi),%eax
  801858:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80185e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801865:	00 00 00 
	stat->st_dev = &devpipe;
  801868:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80186f:	30 80 00 
	return 0;
}
  801872:	b8 00 00 00 00       	mov    $0x0,%eax
  801877:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80187a:	5b                   	pop    %ebx
  80187b:	5e                   	pop    %esi
  80187c:	5d                   	pop    %ebp
  80187d:	c3                   	ret    

0080187e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80187e:	55                   	push   %ebp
  80187f:	89 e5                	mov    %esp,%ebp
  801881:	53                   	push   %ebx
  801882:	83 ec 0c             	sub    $0xc,%esp
  801885:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801888:	53                   	push   %ebx
  801889:	6a 00                	push   $0x0
  80188b:	e8 d0 f3 ff ff       	call   800c60 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801890:	89 1c 24             	mov    %ebx,(%esp)
  801893:	e8 9d f7 ff ff       	call   801035 <fd2data>
  801898:	83 c4 08             	add    $0x8,%esp
  80189b:	50                   	push   %eax
  80189c:	6a 00                	push   $0x0
  80189e:	e8 bd f3 ff ff       	call   800c60 <sys_page_unmap>
}
  8018a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018a6:	c9                   	leave  
  8018a7:	c3                   	ret    

008018a8 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8018a8:	55                   	push   %ebp
  8018a9:	89 e5                	mov    %esp,%ebp
  8018ab:	57                   	push   %edi
  8018ac:	56                   	push   %esi
  8018ad:	53                   	push   %ebx
  8018ae:	83 ec 1c             	sub    $0x1c,%esp
  8018b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018b4:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8018b6:	a1 04 40 80 00       	mov    0x804004,%eax
  8018bb:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8018be:	83 ec 0c             	sub    $0xc,%esp
  8018c1:	ff 75 e0             	pushl  -0x20(%ebp)
  8018c4:	e8 f6 05 00 00       	call   801ebf <pageref>
  8018c9:	89 c3                	mov    %eax,%ebx
  8018cb:	89 3c 24             	mov    %edi,(%esp)
  8018ce:	e8 ec 05 00 00       	call   801ebf <pageref>
  8018d3:	83 c4 10             	add    $0x10,%esp
  8018d6:	39 c3                	cmp    %eax,%ebx
  8018d8:	0f 94 c1             	sete   %cl
  8018db:	0f b6 c9             	movzbl %cl,%ecx
  8018de:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8018e1:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8018e7:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8018ea:	39 ce                	cmp    %ecx,%esi
  8018ec:	74 1b                	je     801909 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8018ee:	39 c3                	cmp    %eax,%ebx
  8018f0:	75 c4                	jne    8018b6 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8018f2:	8b 42 58             	mov    0x58(%edx),%eax
  8018f5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8018f8:	50                   	push   %eax
  8018f9:	56                   	push   %esi
  8018fa:	68 1a 26 80 00       	push   $0x80261a
  8018ff:	e8 d0 e8 ff ff       	call   8001d4 <cprintf>
  801904:	83 c4 10             	add    $0x10,%esp
  801907:	eb ad                	jmp    8018b6 <_pipeisclosed+0xe>
	}
}
  801909:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80190c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80190f:	5b                   	pop    %ebx
  801910:	5e                   	pop    %esi
  801911:	5f                   	pop    %edi
  801912:	5d                   	pop    %ebp
  801913:	c3                   	ret    

00801914 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801914:	55                   	push   %ebp
  801915:	89 e5                	mov    %esp,%ebp
  801917:	57                   	push   %edi
  801918:	56                   	push   %esi
  801919:	53                   	push   %ebx
  80191a:	83 ec 28             	sub    $0x28,%esp
  80191d:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801920:	56                   	push   %esi
  801921:	e8 0f f7 ff ff       	call   801035 <fd2data>
  801926:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801928:	83 c4 10             	add    $0x10,%esp
  80192b:	bf 00 00 00 00       	mov    $0x0,%edi
  801930:	eb 4b                	jmp    80197d <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801932:	89 da                	mov    %ebx,%edx
  801934:	89 f0                	mov    %esi,%eax
  801936:	e8 6d ff ff ff       	call   8018a8 <_pipeisclosed>
  80193b:	85 c0                	test   %eax,%eax
  80193d:	75 48                	jne    801987 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80193f:	e8 78 f2 ff ff       	call   800bbc <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801944:	8b 43 04             	mov    0x4(%ebx),%eax
  801947:	8b 0b                	mov    (%ebx),%ecx
  801949:	8d 51 20             	lea    0x20(%ecx),%edx
  80194c:	39 d0                	cmp    %edx,%eax
  80194e:	73 e2                	jae    801932 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801950:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801953:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801957:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80195a:	89 c2                	mov    %eax,%edx
  80195c:	c1 fa 1f             	sar    $0x1f,%edx
  80195f:	89 d1                	mov    %edx,%ecx
  801961:	c1 e9 1b             	shr    $0x1b,%ecx
  801964:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801967:	83 e2 1f             	and    $0x1f,%edx
  80196a:	29 ca                	sub    %ecx,%edx
  80196c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801970:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801974:	83 c0 01             	add    $0x1,%eax
  801977:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80197a:	83 c7 01             	add    $0x1,%edi
  80197d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801980:	75 c2                	jne    801944 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801982:	8b 45 10             	mov    0x10(%ebp),%eax
  801985:	eb 05                	jmp    80198c <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801987:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80198c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80198f:	5b                   	pop    %ebx
  801990:	5e                   	pop    %esi
  801991:	5f                   	pop    %edi
  801992:	5d                   	pop    %ebp
  801993:	c3                   	ret    

00801994 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801994:	55                   	push   %ebp
  801995:	89 e5                	mov    %esp,%ebp
  801997:	57                   	push   %edi
  801998:	56                   	push   %esi
  801999:	53                   	push   %ebx
  80199a:	83 ec 18             	sub    $0x18,%esp
  80199d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8019a0:	57                   	push   %edi
  8019a1:	e8 8f f6 ff ff       	call   801035 <fd2data>
  8019a6:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019a8:	83 c4 10             	add    $0x10,%esp
  8019ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019b0:	eb 3d                	jmp    8019ef <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8019b2:	85 db                	test   %ebx,%ebx
  8019b4:	74 04                	je     8019ba <devpipe_read+0x26>
				return i;
  8019b6:	89 d8                	mov    %ebx,%eax
  8019b8:	eb 44                	jmp    8019fe <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8019ba:	89 f2                	mov    %esi,%edx
  8019bc:	89 f8                	mov    %edi,%eax
  8019be:	e8 e5 fe ff ff       	call   8018a8 <_pipeisclosed>
  8019c3:	85 c0                	test   %eax,%eax
  8019c5:	75 32                	jne    8019f9 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8019c7:	e8 f0 f1 ff ff       	call   800bbc <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8019cc:	8b 06                	mov    (%esi),%eax
  8019ce:	3b 46 04             	cmp    0x4(%esi),%eax
  8019d1:	74 df                	je     8019b2 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8019d3:	99                   	cltd   
  8019d4:	c1 ea 1b             	shr    $0x1b,%edx
  8019d7:	01 d0                	add    %edx,%eax
  8019d9:	83 e0 1f             	and    $0x1f,%eax
  8019dc:	29 d0                	sub    %edx,%eax
  8019de:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8019e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019e6:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8019e9:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019ec:	83 c3 01             	add    $0x1,%ebx
  8019ef:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8019f2:	75 d8                	jne    8019cc <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8019f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8019f7:	eb 05                	jmp    8019fe <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019f9:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8019fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a01:	5b                   	pop    %ebx
  801a02:	5e                   	pop    %esi
  801a03:	5f                   	pop    %edi
  801a04:	5d                   	pop    %ebp
  801a05:	c3                   	ret    

00801a06 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a06:	55                   	push   %ebp
  801a07:	89 e5                	mov    %esp,%ebp
  801a09:	56                   	push   %esi
  801a0a:	53                   	push   %ebx
  801a0b:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a0e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a11:	50                   	push   %eax
  801a12:	e8 35 f6 ff ff       	call   80104c <fd_alloc>
  801a17:	83 c4 10             	add    $0x10,%esp
  801a1a:	89 c2                	mov    %eax,%edx
  801a1c:	85 c0                	test   %eax,%eax
  801a1e:	0f 88 2c 01 00 00    	js     801b50 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a24:	83 ec 04             	sub    $0x4,%esp
  801a27:	68 07 04 00 00       	push   $0x407
  801a2c:	ff 75 f4             	pushl  -0xc(%ebp)
  801a2f:	6a 00                	push   $0x0
  801a31:	e8 a5 f1 ff ff       	call   800bdb <sys_page_alloc>
  801a36:	83 c4 10             	add    $0x10,%esp
  801a39:	89 c2                	mov    %eax,%edx
  801a3b:	85 c0                	test   %eax,%eax
  801a3d:	0f 88 0d 01 00 00    	js     801b50 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a43:	83 ec 0c             	sub    $0xc,%esp
  801a46:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a49:	50                   	push   %eax
  801a4a:	e8 fd f5 ff ff       	call   80104c <fd_alloc>
  801a4f:	89 c3                	mov    %eax,%ebx
  801a51:	83 c4 10             	add    $0x10,%esp
  801a54:	85 c0                	test   %eax,%eax
  801a56:	0f 88 e2 00 00 00    	js     801b3e <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a5c:	83 ec 04             	sub    $0x4,%esp
  801a5f:	68 07 04 00 00       	push   $0x407
  801a64:	ff 75 f0             	pushl  -0x10(%ebp)
  801a67:	6a 00                	push   $0x0
  801a69:	e8 6d f1 ff ff       	call   800bdb <sys_page_alloc>
  801a6e:	89 c3                	mov    %eax,%ebx
  801a70:	83 c4 10             	add    $0x10,%esp
  801a73:	85 c0                	test   %eax,%eax
  801a75:	0f 88 c3 00 00 00    	js     801b3e <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801a7b:	83 ec 0c             	sub    $0xc,%esp
  801a7e:	ff 75 f4             	pushl  -0xc(%ebp)
  801a81:	e8 af f5 ff ff       	call   801035 <fd2data>
  801a86:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a88:	83 c4 0c             	add    $0xc,%esp
  801a8b:	68 07 04 00 00       	push   $0x407
  801a90:	50                   	push   %eax
  801a91:	6a 00                	push   $0x0
  801a93:	e8 43 f1 ff ff       	call   800bdb <sys_page_alloc>
  801a98:	89 c3                	mov    %eax,%ebx
  801a9a:	83 c4 10             	add    $0x10,%esp
  801a9d:	85 c0                	test   %eax,%eax
  801a9f:	0f 88 89 00 00 00    	js     801b2e <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aa5:	83 ec 0c             	sub    $0xc,%esp
  801aa8:	ff 75 f0             	pushl  -0x10(%ebp)
  801aab:	e8 85 f5 ff ff       	call   801035 <fd2data>
  801ab0:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ab7:	50                   	push   %eax
  801ab8:	6a 00                	push   $0x0
  801aba:	56                   	push   %esi
  801abb:	6a 00                	push   $0x0
  801abd:	e8 5c f1 ff ff       	call   800c1e <sys_page_map>
  801ac2:	89 c3                	mov    %eax,%ebx
  801ac4:	83 c4 20             	add    $0x20,%esp
  801ac7:	85 c0                	test   %eax,%eax
  801ac9:	78 55                	js     801b20 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801acb:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ad1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad4:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ad6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ae0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ae6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ae9:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801aeb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801aee:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801af5:	83 ec 0c             	sub    $0xc,%esp
  801af8:	ff 75 f4             	pushl  -0xc(%ebp)
  801afb:	e8 25 f5 ff ff       	call   801025 <fd2num>
  801b00:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b03:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b05:	83 c4 04             	add    $0x4,%esp
  801b08:	ff 75 f0             	pushl  -0x10(%ebp)
  801b0b:	e8 15 f5 ff ff       	call   801025 <fd2num>
  801b10:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b13:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801b16:	83 c4 10             	add    $0x10,%esp
  801b19:	ba 00 00 00 00       	mov    $0x0,%edx
  801b1e:	eb 30                	jmp    801b50 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b20:	83 ec 08             	sub    $0x8,%esp
  801b23:	56                   	push   %esi
  801b24:	6a 00                	push   $0x0
  801b26:	e8 35 f1 ff ff       	call   800c60 <sys_page_unmap>
  801b2b:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b2e:	83 ec 08             	sub    $0x8,%esp
  801b31:	ff 75 f0             	pushl  -0x10(%ebp)
  801b34:	6a 00                	push   $0x0
  801b36:	e8 25 f1 ff ff       	call   800c60 <sys_page_unmap>
  801b3b:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b3e:	83 ec 08             	sub    $0x8,%esp
  801b41:	ff 75 f4             	pushl  -0xc(%ebp)
  801b44:	6a 00                	push   $0x0
  801b46:	e8 15 f1 ff ff       	call   800c60 <sys_page_unmap>
  801b4b:	83 c4 10             	add    $0x10,%esp
  801b4e:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801b50:	89 d0                	mov    %edx,%eax
  801b52:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b55:	5b                   	pop    %ebx
  801b56:	5e                   	pop    %esi
  801b57:	5d                   	pop    %ebp
  801b58:	c3                   	ret    

00801b59 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b59:	55                   	push   %ebp
  801b5a:	89 e5                	mov    %esp,%ebp
  801b5c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b5f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b62:	50                   	push   %eax
  801b63:	ff 75 08             	pushl  0x8(%ebp)
  801b66:	e8 30 f5 ff ff       	call   80109b <fd_lookup>
  801b6b:	83 c4 10             	add    $0x10,%esp
  801b6e:	85 c0                	test   %eax,%eax
  801b70:	78 18                	js     801b8a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b72:	83 ec 0c             	sub    $0xc,%esp
  801b75:	ff 75 f4             	pushl  -0xc(%ebp)
  801b78:	e8 b8 f4 ff ff       	call   801035 <fd2data>
	return _pipeisclosed(fd, p);
  801b7d:	89 c2                	mov    %eax,%edx
  801b7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b82:	e8 21 fd ff ff       	call   8018a8 <_pipeisclosed>
  801b87:	83 c4 10             	add    $0x10,%esp
}
  801b8a:	c9                   	leave  
  801b8b:	c3                   	ret    

00801b8c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b8c:	55                   	push   %ebp
  801b8d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801b8f:	b8 00 00 00 00       	mov    $0x0,%eax
  801b94:	5d                   	pop    %ebp
  801b95:	c3                   	ret    

00801b96 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b96:	55                   	push   %ebp
  801b97:	89 e5                	mov    %esp,%ebp
  801b99:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801b9c:	68 32 26 80 00       	push   $0x802632
  801ba1:	ff 75 0c             	pushl  0xc(%ebp)
  801ba4:	e8 2f ec ff ff       	call   8007d8 <strcpy>
	return 0;
}
  801ba9:	b8 00 00 00 00       	mov    $0x0,%eax
  801bae:	c9                   	leave  
  801baf:	c3                   	ret    

00801bb0 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bb0:	55                   	push   %ebp
  801bb1:	89 e5                	mov    %esp,%ebp
  801bb3:	57                   	push   %edi
  801bb4:	56                   	push   %esi
  801bb5:	53                   	push   %ebx
  801bb6:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bbc:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bc1:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bc7:	eb 2d                	jmp    801bf6 <devcons_write+0x46>
		m = n - tot;
  801bc9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801bcc:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801bce:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801bd1:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801bd6:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bd9:	83 ec 04             	sub    $0x4,%esp
  801bdc:	53                   	push   %ebx
  801bdd:	03 45 0c             	add    0xc(%ebp),%eax
  801be0:	50                   	push   %eax
  801be1:	57                   	push   %edi
  801be2:	e8 83 ed ff ff       	call   80096a <memmove>
		sys_cputs(buf, m);
  801be7:	83 c4 08             	add    $0x8,%esp
  801bea:	53                   	push   %ebx
  801beb:	57                   	push   %edi
  801bec:	e8 2e ef ff ff       	call   800b1f <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bf1:	01 de                	add    %ebx,%esi
  801bf3:	83 c4 10             	add    $0x10,%esp
  801bf6:	89 f0                	mov    %esi,%eax
  801bf8:	3b 75 10             	cmp    0x10(%ebp),%esi
  801bfb:	72 cc                	jb     801bc9 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801bfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c00:	5b                   	pop    %ebx
  801c01:	5e                   	pop    %esi
  801c02:	5f                   	pop    %edi
  801c03:	5d                   	pop    %ebp
  801c04:	c3                   	ret    

00801c05 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c05:	55                   	push   %ebp
  801c06:	89 e5                	mov    %esp,%ebp
  801c08:	83 ec 08             	sub    $0x8,%esp
  801c0b:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801c10:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c14:	74 2a                	je     801c40 <devcons_read+0x3b>
  801c16:	eb 05                	jmp    801c1d <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c18:	e8 9f ef ff ff       	call   800bbc <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c1d:	e8 1b ef ff ff       	call   800b3d <sys_cgetc>
  801c22:	85 c0                	test   %eax,%eax
  801c24:	74 f2                	je     801c18 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801c26:	85 c0                	test   %eax,%eax
  801c28:	78 16                	js     801c40 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c2a:	83 f8 04             	cmp    $0x4,%eax
  801c2d:	74 0c                	je     801c3b <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801c2f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c32:	88 02                	mov    %al,(%edx)
	return 1;
  801c34:	b8 01 00 00 00       	mov    $0x1,%eax
  801c39:	eb 05                	jmp    801c40 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c3b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c40:	c9                   	leave  
  801c41:	c3                   	ret    

00801c42 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c42:	55                   	push   %ebp
  801c43:	89 e5                	mov    %esp,%ebp
  801c45:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c48:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c4e:	6a 01                	push   $0x1
  801c50:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c53:	50                   	push   %eax
  801c54:	e8 c6 ee ff ff       	call   800b1f <sys_cputs>
}
  801c59:	83 c4 10             	add    $0x10,%esp
  801c5c:	c9                   	leave  
  801c5d:	c3                   	ret    

00801c5e <getchar>:

int
getchar(void)
{
  801c5e:	55                   	push   %ebp
  801c5f:	89 e5                	mov    %esp,%ebp
  801c61:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c64:	6a 01                	push   $0x1
  801c66:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c69:	50                   	push   %eax
  801c6a:	6a 00                	push   $0x0
  801c6c:	e8 90 f6 ff ff       	call   801301 <read>
	if (r < 0)
  801c71:	83 c4 10             	add    $0x10,%esp
  801c74:	85 c0                	test   %eax,%eax
  801c76:	78 0f                	js     801c87 <getchar+0x29>
		return r;
	if (r < 1)
  801c78:	85 c0                	test   %eax,%eax
  801c7a:	7e 06                	jle    801c82 <getchar+0x24>
		return -E_EOF;
	return c;
  801c7c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801c80:	eb 05                	jmp    801c87 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801c82:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801c87:	c9                   	leave  
  801c88:	c3                   	ret    

00801c89 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801c89:	55                   	push   %ebp
  801c8a:	89 e5                	mov    %esp,%ebp
  801c8c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c92:	50                   	push   %eax
  801c93:	ff 75 08             	pushl  0x8(%ebp)
  801c96:	e8 00 f4 ff ff       	call   80109b <fd_lookup>
  801c9b:	83 c4 10             	add    $0x10,%esp
  801c9e:	85 c0                	test   %eax,%eax
  801ca0:	78 11                	js     801cb3 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ca2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cab:	39 10                	cmp    %edx,(%eax)
  801cad:	0f 94 c0             	sete   %al
  801cb0:	0f b6 c0             	movzbl %al,%eax
}
  801cb3:	c9                   	leave  
  801cb4:	c3                   	ret    

00801cb5 <opencons>:

int
opencons(void)
{
  801cb5:	55                   	push   %ebp
  801cb6:	89 e5                	mov    %esp,%ebp
  801cb8:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cbb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cbe:	50                   	push   %eax
  801cbf:	e8 88 f3 ff ff       	call   80104c <fd_alloc>
  801cc4:	83 c4 10             	add    $0x10,%esp
		return r;
  801cc7:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cc9:	85 c0                	test   %eax,%eax
  801ccb:	78 3e                	js     801d0b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ccd:	83 ec 04             	sub    $0x4,%esp
  801cd0:	68 07 04 00 00       	push   $0x407
  801cd5:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd8:	6a 00                	push   $0x0
  801cda:	e8 fc ee ff ff       	call   800bdb <sys_page_alloc>
  801cdf:	83 c4 10             	add    $0x10,%esp
		return r;
  801ce2:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ce4:	85 c0                	test   %eax,%eax
  801ce6:	78 23                	js     801d0b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ce8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801cf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801cfd:	83 ec 0c             	sub    $0xc,%esp
  801d00:	50                   	push   %eax
  801d01:	e8 1f f3 ff ff       	call   801025 <fd2num>
  801d06:	89 c2                	mov    %eax,%edx
  801d08:	83 c4 10             	add    $0x10,%esp
}
  801d0b:	89 d0                	mov    %edx,%eax
  801d0d:	c9                   	leave  
  801d0e:	c3                   	ret    

00801d0f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d0f:	55                   	push   %ebp
  801d10:	89 e5                	mov    %esp,%ebp
  801d12:	56                   	push   %esi
  801d13:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d14:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d17:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d1d:	e8 7b ee ff ff       	call   800b9d <sys_getenvid>
  801d22:	83 ec 0c             	sub    $0xc,%esp
  801d25:	ff 75 0c             	pushl  0xc(%ebp)
  801d28:	ff 75 08             	pushl  0x8(%ebp)
  801d2b:	56                   	push   %esi
  801d2c:	50                   	push   %eax
  801d2d:	68 40 26 80 00       	push   $0x802640
  801d32:	e8 9d e4 ff ff       	call   8001d4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d37:	83 c4 18             	add    $0x18,%esp
  801d3a:	53                   	push   %ebx
  801d3b:	ff 75 10             	pushl  0x10(%ebp)
  801d3e:	e8 40 e4 ff ff       	call   800183 <vcprintf>
	cprintf("\n");
  801d43:	c7 04 24 af 21 80 00 	movl   $0x8021af,(%esp)
  801d4a:	e8 85 e4 ff ff       	call   8001d4 <cprintf>
  801d4f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d52:	cc                   	int3   
  801d53:	eb fd                	jmp    801d52 <_panic+0x43>

00801d55 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d55:	55                   	push   %ebp
  801d56:	89 e5                	mov    %esp,%ebp
  801d58:	53                   	push   %ebx
  801d59:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d5c:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d63:	75 28                	jne    801d8d <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		void *va = (void *) (UXSTACKTOP - PGSIZE);
		envid_t envid = sys_getenvid();
  801d65:	e8 33 ee ff ff       	call   800b9d <sys_getenvid>
  801d6a:	89 c3                	mov    %eax,%ebx

		sys_page_alloc(envid, va, PTE_P | PTE_U | PTE_W);
  801d6c:	83 ec 04             	sub    $0x4,%esp
  801d6f:	6a 07                	push   $0x7
  801d71:	68 00 f0 bf ee       	push   $0xeebff000
  801d76:	50                   	push   %eax
  801d77:	e8 5f ee ff ff       	call   800bdb <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801d7c:	83 c4 08             	add    $0x8,%esp
  801d7f:	68 9a 1d 80 00       	push   $0x801d9a
  801d84:	53                   	push   %ebx
  801d85:	e8 9c ef ff ff       	call   800d26 <sys_env_set_pgfault_upcall>
  801d8a:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801d8d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d90:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801d95:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d98:	c9                   	leave  
  801d99:	c3                   	ret    

00801d9a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp				// function argument: pointer to UTF
  801d9a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801d9b:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801da0:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801da2:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp, %ebx		// 40 = size between utf_fault_va ~ utf_regs
  801da5:	89 e3                	mov    %esp,%ebx
	movl 40(%esp), %eax // point to utf_eip
  801da7:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %esp // point to utf_esp
  801dab:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax 			// push eip of utf
  801daf:	50                   	push   %eax

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx, %esp 	// back to origin exception stack
  801db0:	89 dc                	mov    %ebx,%esp
	subl $4, 48(%esp) 	// utf_esp - 4
  801db2:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	popl %eax  			// pop utf_fault_va (ignore)
  801db7:	58                   	pop    %eax
	popl %eax  			// pop utf_err (ignore)
  801db8:	58                   	pop    %eax
	popal 				// pop utf_regs 
  801db9:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4, %esp 		// ignore utf_eip
  801dba:	83 c4 04             	add    $0x4,%esp
	popfl 				// restore utf_eflags to eflags
  801dbd:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp  			// restore %esp = utf_esp
  801dbe:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801dbf:	c3                   	ret    

00801dc0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801dc0:	55                   	push   %ebp
  801dc1:	89 e5                	mov    %esp,%ebp
  801dc3:	56                   	push   %esi
  801dc4:	53                   	push   %ebx
  801dc5:	8b 75 08             	mov    0x8(%ebp),%esi
  801dc8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dcb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

    if (pg != NULL)
  801dce:	85 c0                	test   %eax,%eax
  801dd0:	74 0e                	je     801de0 <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  801dd2:	83 ec 0c             	sub    $0xc,%esp
  801dd5:	50                   	push   %eax
  801dd6:	e8 b0 ef ff ff       	call   800d8b <sys_ipc_recv>
  801ddb:	83 c4 10             	add    $0x10,%esp
  801dde:	eb 0d                	jmp    801ded <ipc_recv+0x2d>
	else
        r = sys_ipc_recv((void *)-1);
  801de0:	83 ec 0c             	sub    $0xc,%esp
  801de3:	6a ff                	push   $0xffffffff
  801de5:	e8 a1 ef ff ff       	call   800d8b <sys_ipc_recv>
  801dea:	83 c4 10             	add    $0x10,%esp

	if (r < 0) {
  801ded:	85 c0                	test   %eax,%eax
  801def:	79 16                	jns    801e07 <ipc_recv+0x47>

		if (from_env_store != NULL)
  801df1:	85 f6                	test   %esi,%esi
  801df3:	74 06                	je     801dfb <ipc_recv+0x3b>
			*from_env_store = 0;
  801df5:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL)
  801dfb:	85 db                	test   %ebx,%ebx
  801dfd:	74 2c                	je     801e2b <ipc_recv+0x6b>
			*perm_store = 0;
  801dff:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801e05:	eb 24                	jmp    801e2b <ipc_recv+0x6b>
		return r;

	} else {

		if (from_env_store != NULL)
  801e07:	85 f6                	test   %esi,%esi
  801e09:	74 0a                	je     801e15 <ipc_recv+0x55>
			*from_env_store = thisenv->env_ipc_from;
  801e0b:	a1 04 40 80 00       	mov    0x804004,%eax
  801e10:	8b 40 74             	mov    0x74(%eax),%eax
  801e13:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL)
  801e15:	85 db                	test   %ebx,%ebx
  801e17:	74 0a                	je     801e23 <ipc_recv+0x63>
			*perm_store = thisenv->env_ipc_perm;
  801e19:	a1 04 40 80 00       	mov    0x804004,%eax
  801e1e:	8b 40 78             	mov    0x78(%eax),%eax
  801e21:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801e23:	a1 04 40 80 00       	mov    0x804004,%eax
  801e28:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801e2b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e2e:	5b                   	pop    %ebx
  801e2f:	5e                   	pop    %esi
  801e30:	5d                   	pop    %ebp
  801e31:	c3                   	ret    

00801e32 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e32:	55                   	push   %ebp
  801e33:	89 e5                	mov    %esp,%ebp
  801e35:	57                   	push   %edi
  801e36:	56                   	push   %esi
  801e37:	53                   	push   %ebx
  801e38:	83 ec 0c             	sub    $0xc,%esp
  801e3b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e3e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e41:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

	if (pg == NULL)
  801e44:	85 db                	test   %ebx,%ebx
		pg = (void *)-1;	
  801e46:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801e4b:	0f 44 d8             	cmove  %eax,%ebx

	while (true) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801e4e:	ff 75 14             	pushl  0x14(%ebp)
  801e51:	53                   	push   %ebx
  801e52:	56                   	push   %esi
  801e53:	57                   	push   %edi
  801e54:	e8 0f ef ff ff       	call   800d68 <sys_ipc_try_send>
		if (r >= 0)
  801e59:	83 c4 10             	add    $0x10,%esp
  801e5c:	85 c0                	test   %eax,%eax
  801e5e:	79 1e                	jns    801e7e <ipc_send+0x4c>
			return;
		else if (r != -E_IPC_NOT_RECV)
  801e60:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e63:	74 12                	je     801e77 <ipc_send+0x45>
			panic("ipc_send error: %e", r);
  801e65:	50                   	push   %eax
  801e66:	68 64 26 80 00       	push   $0x802664
  801e6b:	6a 49                	push   $0x49
  801e6d:	68 77 26 80 00       	push   $0x802677
  801e72:	e8 98 fe ff ff       	call   801d0f <_panic>
	
		sys_yield();
  801e77:	e8 40 ed ff ff       	call   800bbc <sys_yield>
	}
  801e7c:	eb d0                	jmp    801e4e <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  801e7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e81:	5b                   	pop    %ebx
  801e82:	5e                   	pop    %esi
  801e83:	5f                   	pop    %edi
  801e84:	5d                   	pop    %ebp
  801e85:	c3                   	ret    

00801e86 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801e86:	55                   	push   %ebp
  801e87:	89 e5                	mov    %esp,%ebp
  801e89:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801e8c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801e91:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801e94:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801e9a:	8b 52 50             	mov    0x50(%edx),%edx
  801e9d:	39 ca                	cmp    %ecx,%edx
  801e9f:	75 0d                	jne    801eae <ipc_find_env+0x28>
			return envs[i].env_id;
  801ea1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ea4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ea9:	8b 40 48             	mov    0x48(%eax),%eax
  801eac:	eb 0f                	jmp    801ebd <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801eae:	83 c0 01             	add    $0x1,%eax
  801eb1:	3d 00 04 00 00       	cmp    $0x400,%eax
  801eb6:	75 d9                	jne    801e91 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801eb8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ebd:	5d                   	pop    %ebp
  801ebe:	c3                   	ret    

00801ebf <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ebf:	55                   	push   %ebp
  801ec0:	89 e5                	mov    %esp,%ebp
  801ec2:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ec5:	89 d0                	mov    %edx,%eax
  801ec7:	c1 e8 16             	shr    $0x16,%eax
  801eca:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ed1:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ed6:	f6 c1 01             	test   $0x1,%cl
  801ed9:	74 1d                	je     801ef8 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801edb:	c1 ea 0c             	shr    $0xc,%edx
  801ede:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ee5:	f6 c2 01             	test   $0x1,%dl
  801ee8:	74 0e                	je     801ef8 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801eea:	c1 ea 0c             	shr    $0xc,%edx
  801eed:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801ef4:	ef 
  801ef5:	0f b7 c0             	movzwl %ax,%eax
}
  801ef8:	5d                   	pop    %ebp
  801ef9:	c3                   	ret    
  801efa:	66 90                	xchg   %ax,%ax
  801efc:	66 90                	xchg   %ax,%ax
  801efe:	66 90                	xchg   %ax,%ax

00801f00 <__udivdi3>:
  801f00:	55                   	push   %ebp
  801f01:	57                   	push   %edi
  801f02:	56                   	push   %esi
  801f03:	53                   	push   %ebx
  801f04:	83 ec 1c             	sub    $0x1c,%esp
  801f07:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f0b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f0f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f17:	85 f6                	test   %esi,%esi
  801f19:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f1d:	89 ca                	mov    %ecx,%edx
  801f1f:	89 f8                	mov    %edi,%eax
  801f21:	75 3d                	jne    801f60 <__udivdi3+0x60>
  801f23:	39 cf                	cmp    %ecx,%edi
  801f25:	0f 87 c5 00 00 00    	ja     801ff0 <__udivdi3+0xf0>
  801f2b:	85 ff                	test   %edi,%edi
  801f2d:	89 fd                	mov    %edi,%ebp
  801f2f:	75 0b                	jne    801f3c <__udivdi3+0x3c>
  801f31:	b8 01 00 00 00       	mov    $0x1,%eax
  801f36:	31 d2                	xor    %edx,%edx
  801f38:	f7 f7                	div    %edi
  801f3a:	89 c5                	mov    %eax,%ebp
  801f3c:	89 c8                	mov    %ecx,%eax
  801f3e:	31 d2                	xor    %edx,%edx
  801f40:	f7 f5                	div    %ebp
  801f42:	89 c1                	mov    %eax,%ecx
  801f44:	89 d8                	mov    %ebx,%eax
  801f46:	89 cf                	mov    %ecx,%edi
  801f48:	f7 f5                	div    %ebp
  801f4a:	89 c3                	mov    %eax,%ebx
  801f4c:	89 d8                	mov    %ebx,%eax
  801f4e:	89 fa                	mov    %edi,%edx
  801f50:	83 c4 1c             	add    $0x1c,%esp
  801f53:	5b                   	pop    %ebx
  801f54:	5e                   	pop    %esi
  801f55:	5f                   	pop    %edi
  801f56:	5d                   	pop    %ebp
  801f57:	c3                   	ret    
  801f58:	90                   	nop
  801f59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f60:	39 ce                	cmp    %ecx,%esi
  801f62:	77 74                	ja     801fd8 <__udivdi3+0xd8>
  801f64:	0f bd fe             	bsr    %esi,%edi
  801f67:	83 f7 1f             	xor    $0x1f,%edi
  801f6a:	0f 84 98 00 00 00    	je     802008 <__udivdi3+0x108>
  801f70:	bb 20 00 00 00       	mov    $0x20,%ebx
  801f75:	89 f9                	mov    %edi,%ecx
  801f77:	89 c5                	mov    %eax,%ebp
  801f79:	29 fb                	sub    %edi,%ebx
  801f7b:	d3 e6                	shl    %cl,%esi
  801f7d:	89 d9                	mov    %ebx,%ecx
  801f7f:	d3 ed                	shr    %cl,%ebp
  801f81:	89 f9                	mov    %edi,%ecx
  801f83:	d3 e0                	shl    %cl,%eax
  801f85:	09 ee                	or     %ebp,%esi
  801f87:	89 d9                	mov    %ebx,%ecx
  801f89:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f8d:	89 d5                	mov    %edx,%ebp
  801f8f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801f93:	d3 ed                	shr    %cl,%ebp
  801f95:	89 f9                	mov    %edi,%ecx
  801f97:	d3 e2                	shl    %cl,%edx
  801f99:	89 d9                	mov    %ebx,%ecx
  801f9b:	d3 e8                	shr    %cl,%eax
  801f9d:	09 c2                	or     %eax,%edx
  801f9f:	89 d0                	mov    %edx,%eax
  801fa1:	89 ea                	mov    %ebp,%edx
  801fa3:	f7 f6                	div    %esi
  801fa5:	89 d5                	mov    %edx,%ebp
  801fa7:	89 c3                	mov    %eax,%ebx
  801fa9:	f7 64 24 0c          	mull   0xc(%esp)
  801fad:	39 d5                	cmp    %edx,%ebp
  801faf:	72 10                	jb     801fc1 <__udivdi3+0xc1>
  801fb1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801fb5:	89 f9                	mov    %edi,%ecx
  801fb7:	d3 e6                	shl    %cl,%esi
  801fb9:	39 c6                	cmp    %eax,%esi
  801fbb:	73 07                	jae    801fc4 <__udivdi3+0xc4>
  801fbd:	39 d5                	cmp    %edx,%ebp
  801fbf:	75 03                	jne    801fc4 <__udivdi3+0xc4>
  801fc1:	83 eb 01             	sub    $0x1,%ebx
  801fc4:	31 ff                	xor    %edi,%edi
  801fc6:	89 d8                	mov    %ebx,%eax
  801fc8:	89 fa                	mov    %edi,%edx
  801fca:	83 c4 1c             	add    $0x1c,%esp
  801fcd:	5b                   	pop    %ebx
  801fce:	5e                   	pop    %esi
  801fcf:	5f                   	pop    %edi
  801fd0:	5d                   	pop    %ebp
  801fd1:	c3                   	ret    
  801fd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801fd8:	31 ff                	xor    %edi,%edi
  801fda:	31 db                	xor    %ebx,%ebx
  801fdc:	89 d8                	mov    %ebx,%eax
  801fde:	89 fa                	mov    %edi,%edx
  801fe0:	83 c4 1c             	add    $0x1c,%esp
  801fe3:	5b                   	pop    %ebx
  801fe4:	5e                   	pop    %esi
  801fe5:	5f                   	pop    %edi
  801fe6:	5d                   	pop    %ebp
  801fe7:	c3                   	ret    
  801fe8:	90                   	nop
  801fe9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ff0:	89 d8                	mov    %ebx,%eax
  801ff2:	f7 f7                	div    %edi
  801ff4:	31 ff                	xor    %edi,%edi
  801ff6:	89 c3                	mov    %eax,%ebx
  801ff8:	89 d8                	mov    %ebx,%eax
  801ffa:	89 fa                	mov    %edi,%edx
  801ffc:	83 c4 1c             	add    $0x1c,%esp
  801fff:	5b                   	pop    %ebx
  802000:	5e                   	pop    %esi
  802001:	5f                   	pop    %edi
  802002:	5d                   	pop    %ebp
  802003:	c3                   	ret    
  802004:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802008:	39 ce                	cmp    %ecx,%esi
  80200a:	72 0c                	jb     802018 <__udivdi3+0x118>
  80200c:	31 db                	xor    %ebx,%ebx
  80200e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802012:	0f 87 34 ff ff ff    	ja     801f4c <__udivdi3+0x4c>
  802018:	bb 01 00 00 00       	mov    $0x1,%ebx
  80201d:	e9 2a ff ff ff       	jmp    801f4c <__udivdi3+0x4c>
  802022:	66 90                	xchg   %ax,%ax
  802024:	66 90                	xchg   %ax,%ax
  802026:	66 90                	xchg   %ax,%ax
  802028:	66 90                	xchg   %ax,%ax
  80202a:	66 90                	xchg   %ax,%ax
  80202c:	66 90                	xchg   %ax,%ax
  80202e:	66 90                	xchg   %ax,%ax

00802030 <__umoddi3>:
  802030:	55                   	push   %ebp
  802031:	57                   	push   %edi
  802032:	56                   	push   %esi
  802033:	53                   	push   %ebx
  802034:	83 ec 1c             	sub    $0x1c,%esp
  802037:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80203b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80203f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802043:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802047:	85 d2                	test   %edx,%edx
  802049:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80204d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802051:	89 f3                	mov    %esi,%ebx
  802053:	89 3c 24             	mov    %edi,(%esp)
  802056:	89 74 24 04          	mov    %esi,0x4(%esp)
  80205a:	75 1c                	jne    802078 <__umoddi3+0x48>
  80205c:	39 f7                	cmp    %esi,%edi
  80205e:	76 50                	jbe    8020b0 <__umoddi3+0x80>
  802060:	89 c8                	mov    %ecx,%eax
  802062:	89 f2                	mov    %esi,%edx
  802064:	f7 f7                	div    %edi
  802066:	89 d0                	mov    %edx,%eax
  802068:	31 d2                	xor    %edx,%edx
  80206a:	83 c4 1c             	add    $0x1c,%esp
  80206d:	5b                   	pop    %ebx
  80206e:	5e                   	pop    %esi
  80206f:	5f                   	pop    %edi
  802070:	5d                   	pop    %ebp
  802071:	c3                   	ret    
  802072:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802078:	39 f2                	cmp    %esi,%edx
  80207a:	89 d0                	mov    %edx,%eax
  80207c:	77 52                	ja     8020d0 <__umoddi3+0xa0>
  80207e:	0f bd ea             	bsr    %edx,%ebp
  802081:	83 f5 1f             	xor    $0x1f,%ebp
  802084:	75 5a                	jne    8020e0 <__umoddi3+0xb0>
  802086:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80208a:	0f 82 e0 00 00 00    	jb     802170 <__umoddi3+0x140>
  802090:	39 0c 24             	cmp    %ecx,(%esp)
  802093:	0f 86 d7 00 00 00    	jbe    802170 <__umoddi3+0x140>
  802099:	8b 44 24 08          	mov    0x8(%esp),%eax
  80209d:	8b 54 24 04          	mov    0x4(%esp),%edx
  8020a1:	83 c4 1c             	add    $0x1c,%esp
  8020a4:	5b                   	pop    %ebx
  8020a5:	5e                   	pop    %esi
  8020a6:	5f                   	pop    %edi
  8020a7:	5d                   	pop    %ebp
  8020a8:	c3                   	ret    
  8020a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020b0:	85 ff                	test   %edi,%edi
  8020b2:	89 fd                	mov    %edi,%ebp
  8020b4:	75 0b                	jne    8020c1 <__umoddi3+0x91>
  8020b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8020bb:	31 d2                	xor    %edx,%edx
  8020bd:	f7 f7                	div    %edi
  8020bf:	89 c5                	mov    %eax,%ebp
  8020c1:	89 f0                	mov    %esi,%eax
  8020c3:	31 d2                	xor    %edx,%edx
  8020c5:	f7 f5                	div    %ebp
  8020c7:	89 c8                	mov    %ecx,%eax
  8020c9:	f7 f5                	div    %ebp
  8020cb:	89 d0                	mov    %edx,%eax
  8020cd:	eb 99                	jmp    802068 <__umoddi3+0x38>
  8020cf:	90                   	nop
  8020d0:	89 c8                	mov    %ecx,%eax
  8020d2:	89 f2                	mov    %esi,%edx
  8020d4:	83 c4 1c             	add    $0x1c,%esp
  8020d7:	5b                   	pop    %ebx
  8020d8:	5e                   	pop    %esi
  8020d9:	5f                   	pop    %edi
  8020da:	5d                   	pop    %ebp
  8020db:	c3                   	ret    
  8020dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020e0:	8b 34 24             	mov    (%esp),%esi
  8020e3:	bf 20 00 00 00       	mov    $0x20,%edi
  8020e8:	89 e9                	mov    %ebp,%ecx
  8020ea:	29 ef                	sub    %ebp,%edi
  8020ec:	d3 e0                	shl    %cl,%eax
  8020ee:	89 f9                	mov    %edi,%ecx
  8020f0:	89 f2                	mov    %esi,%edx
  8020f2:	d3 ea                	shr    %cl,%edx
  8020f4:	89 e9                	mov    %ebp,%ecx
  8020f6:	09 c2                	or     %eax,%edx
  8020f8:	89 d8                	mov    %ebx,%eax
  8020fa:	89 14 24             	mov    %edx,(%esp)
  8020fd:	89 f2                	mov    %esi,%edx
  8020ff:	d3 e2                	shl    %cl,%edx
  802101:	89 f9                	mov    %edi,%ecx
  802103:	89 54 24 04          	mov    %edx,0x4(%esp)
  802107:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80210b:	d3 e8                	shr    %cl,%eax
  80210d:	89 e9                	mov    %ebp,%ecx
  80210f:	89 c6                	mov    %eax,%esi
  802111:	d3 e3                	shl    %cl,%ebx
  802113:	89 f9                	mov    %edi,%ecx
  802115:	89 d0                	mov    %edx,%eax
  802117:	d3 e8                	shr    %cl,%eax
  802119:	89 e9                	mov    %ebp,%ecx
  80211b:	09 d8                	or     %ebx,%eax
  80211d:	89 d3                	mov    %edx,%ebx
  80211f:	89 f2                	mov    %esi,%edx
  802121:	f7 34 24             	divl   (%esp)
  802124:	89 d6                	mov    %edx,%esi
  802126:	d3 e3                	shl    %cl,%ebx
  802128:	f7 64 24 04          	mull   0x4(%esp)
  80212c:	39 d6                	cmp    %edx,%esi
  80212e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802132:	89 d1                	mov    %edx,%ecx
  802134:	89 c3                	mov    %eax,%ebx
  802136:	72 08                	jb     802140 <__umoddi3+0x110>
  802138:	75 11                	jne    80214b <__umoddi3+0x11b>
  80213a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80213e:	73 0b                	jae    80214b <__umoddi3+0x11b>
  802140:	2b 44 24 04          	sub    0x4(%esp),%eax
  802144:	1b 14 24             	sbb    (%esp),%edx
  802147:	89 d1                	mov    %edx,%ecx
  802149:	89 c3                	mov    %eax,%ebx
  80214b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80214f:	29 da                	sub    %ebx,%edx
  802151:	19 ce                	sbb    %ecx,%esi
  802153:	89 f9                	mov    %edi,%ecx
  802155:	89 f0                	mov    %esi,%eax
  802157:	d3 e0                	shl    %cl,%eax
  802159:	89 e9                	mov    %ebp,%ecx
  80215b:	d3 ea                	shr    %cl,%edx
  80215d:	89 e9                	mov    %ebp,%ecx
  80215f:	d3 ee                	shr    %cl,%esi
  802161:	09 d0                	or     %edx,%eax
  802163:	89 f2                	mov    %esi,%edx
  802165:	83 c4 1c             	add    $0x1c,%esp
  802168:	5b                   	pop    %ebx
  802169:	5e                   	pop    %esi
  80216a:	5f                   	pop    %edi
  80216b:	5d                   	pop    %ebp
  80216c:	c3                   	ret    
  80216d:	8d 76 00             	lea    0x0(%esi),%esi
  802170:	29 f9                	sub    %edi,%ecx
  802172:	19 d6                	sbb    %edx,%esi
  802174:	89 74 24 04          	mov    %esi,0x4(%esp)
  802178:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80217c:	e9 18 ff ff ff       	jmp    802099 <__umoddi3+0x69>
