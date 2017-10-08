
obj/user/faultalloc.debug：     文件格式 elf32-i386


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
  80002c:	e8 99 00 00 00       	call   8000ca <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
  80003d:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80003f:	53                   	push   %ebx
  800040:	68 20 1f 80 00       	push   $0x801f20
  800045:	e8 b9 01 00 00       	call   800203 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 ac 0b 00 00       	call   800c0a <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 40 1f 80 00       	push   $0x801f40
  80006f:	6a 0e                	push   $0xe
  800071:	68 2a 1f 80 00       	push   $0x801f2a
  800076:	e8 af 00 00 00       	call   80012a <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 6c 1f 80 00       	push   $0x801f6c
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 2b 07 00 00       	call   8007b4 <snprintf>
}
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80008f:	c9                   	leave  
  800090:	c3                   	ret    

00800091 <umain>:

void
umain(int argc, char **argv)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800097:	68 33 00 80 00       	push   $0x800033
  80009c:	e8 5a 0d 00 00       	call   800dfb <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	68 ef be ad de       	push   $0xdeadbeef
  8000a9:	68 3c 1f 80 00       	push   $0x801f3c
  8000ae:	e8 50 01 00 00       	call   800203 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	68 fe bf fe ca       	push   $0xcafebffe
  8000bb:	68 3c 1f 80 00       	push   $0x801f3c
  8000c0:	e8 3e 01 00 00       	call   800203 <cprintf>
}
  8000c5:	83 c4 10             	add    $0x10,%esp
  8000c8:	c9                   	leave  
  8000c9:	c3                   	ret    

008000ca <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	56                   	push   %esi
  8000ce:	53                   	push   %ebx
  8000cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000d2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000d5:	e8 f2 0a 00 00       	call   800bcc <sys_getenvid>
  8000da:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000df:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000e2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e7:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ec:	85 db                	test   %ebx,%ebx
  8000ee:	7e 07                	jle    8000f7 <libmain+0x2d>
		binaryname = argv[0];
  8000f0:	8b 06                	mov    (%esi),%eax
  8000f2:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	56                   	push   %esi
  8000fb:	53                   	push   %ebx
  8000fc:	e8 90 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  800101:	e8 0a 00 00 00       	call   800110 <exit>
}
  800106:	83 c4 10             	add    $0x10,%esp
  800109:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010c:	5b                   	pop    %ebx
  80010d:	5e                   	pop    %esi
  80010e:	5d                   	pop    %ebp
  80010f:	c3                   	ret    

00800110 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800116:	e8 16 0f 00 00       	call   801031 <close_all>
	sys_env_destroy(0);
  80011b:	83 ec 0c             	sub    $0xc,%esp
  80011e:	6a 00                	push   $0x0
  800120:	e8 66 0a 00 00       	call   800b8b <sys_env_destroy>
}
  800125:	83 c4 10             	add    $0x10,%esp
  800128:	c9                   	leave  
  800129:	c3                   	ret    

0080012a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	56                   	push   %esi
  80012e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80012f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800132:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800138:	e8 8f 0a 00 00       	call   800bcc <sys_getenvid>
  80013d:	83 ec 0c             	sub    $0xc,%esp
  800140:	ff 75 0c             	pushl  0xc(%ebp)
  800143:	ff 75 08             	pushl  0x8(%ebp)
  800146:	56                   	push   %esi
  800147:	50                   	push   %eax
  800148:	68 98 1f 80 00       	push   $0x801f98
  80014d:	e8 b1 00 00 00       	call   800203 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800152:	83 c4 18             	add    $0x18,%esp
  800155:	53                   	push   %ebx
  800156:	ff 75 10             	pushl  0x10(%ebp)
  800159:	e8 54 00 00 00       	call   8001b2 <vcprintf>
	cprintf("\n");
  80015e:	c7 04 24 c7 23 80 00 	movl   $0x8023c7,(%esp)
  800165:	e8 99 00 00 00       	call   800203 <cprintf>
  80016a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80016d:	cc                   	int3   
  80016e:	eb fd                	jmp    80016d <_panic+0x43>

00800170 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	53                   	push   %ebx
  800174:	83 ec 04             	sub    $0x4,%esp
  800177:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80017a:	8b 13                	mov    (%ebx),%edx
  80017c:	8d 42 01             	lea    0x1(%edx),%eax
  80017f:	89 03                	mov    %eax,(%ebx)
  800181:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800184:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800188:	3d ff 00 00 00       	cmp    $0xff,%eax
  80018d:	75 1a                	jne    8001a9 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80018f:	83 ec 08             	sub    $0x8,%esp
  800192:	68 ff 00 00 00       	push   $0xff
  800197:	8d 43 08             	lea    0x8(%ebx),%eax
  80019a:	50                   	push   %eax
  80019b:	e8 ae 09 00 00       	call   800b4e <sys_cputs>
		b->idx = 0;
  8001a0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001a6:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001a9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b0:	c9                   	leave  
  8001b1:	c3                   	ret    

008001b2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001b2:	55                   	push   %ebp
  8001b3:	89 e5                	mov    %esp,%ebp
  8001b5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001bb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c2:	00 00 00 
	b.cnt = 0;
  8001c5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001cc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001cf:	ff 75 0c             	pushl  0xc(%ebp)
  8001d2:	ff 75 08             	pushl  0x8(%ebp)
  8001d5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001db:	50                   	push   %eax
  8001dc:	68 70 01 80 00       	push   $0x800170
  8001e1:	e8 1a 01 00 00       	call   800300 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e6:	83 c4 08             	add    $0x8,%esp
  8001e9:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001ef:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f5:	50                   	push   %eax
  8001f6:	e8 53 09 00 00       	call   800b4e <sys_cputs>

	return b.cnt;
}
  8001fb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800201:	c9                   	leave  
  800202:	c3                   	ret    

00800203 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800203:	55                   	push   %ebp
  800204:	89 e5                	mov    %esp,%ebp
  800206:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800209:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80020c:	50                   	push   %eax
  80020d:	ff 75 08             	pushl  0x8(%ebp)
  800210:	e8 9d ff ff ff       	call   8001b2 <vcprintf>
	va_end(ap);

	return cnt;
}
  800215:	c9                   	leave  
  800216:	c3                   	ret    

00800217 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800217:	55                   	push   %ebp
  800218:	89 e5                	mov    %esp,%ebp
  80021a:	57                   	push   %edi
  80021b:	56                   	push   %esi
  80021c:	53                   	push   %ebx
  80021d:	83 ec 1c             	sub    $0x1c,%esp
  800220:	89 c7                	mov    %eax,%edi
  800222:	89 d6                	mov    %edx,%esi
  800224:	8b 45 08             	mov    0x8(%ebp),%eax
  800227:	8b 55 0c             	mov    0xc(%ebp),%edx
  80022a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80022d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800230:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800233:	bb 00 00 00 00       	mov    $0x0,%ebx
  800238:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80023b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80023e:	39 d3                	cmp    %edx,%ebx
  800240:	72 05                	jb     800247 <printnum+0x30>
  800242:	39 45 10             	cmp    %eax,0x10(%ebp)
  800245:	77 45                	ja     80028c <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800247:	83 ec 0c             	sub    $0xc,%esp
  80024a:	ff 75 18             	pushl  0x18(%ebp)
  80024d:	8b 45 14             	mov    0x14(%ebp),%eax
  800250:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800253:	53                   	push   %ebx
  800254:	ff 75 10             	pushl  0x10(%ebp)
  800257:	83 ec 08             	sub    $0x8,%esp
  80025a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80025d:	ff 75 e0             	pushl  -0x20(%ebp)
  800260:	ff 75 dc             	pushl  -0x24(%ebp)
  800263:	ff 75 d8             	pushl  -0x28(%ebp)
  800266:	e8 25 1a 00 00       	call   801c90 <__udivdi3>
  80026b:	83 c4 18             	add    $0x18,%esp
  80026e:	52                   	push   %edx
  80026f:	50                   	push   %eax
  800270:	89 f2                	mov    %esi,%edx
  800272:	89 f8                	mov    %edi,%eax
  800274:	e8 9e ff ff ff       	call   800217 <printnum>
  800279:	83 c4 20             	add    $0x20,%esp
  80027c:	eb 18                	jmp    800296 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80027e:	83 ec 08             	sub    $0x8,%esp
  800281:	56                   	push   %esi
  800282:	ff 75 18             	pushl  0x18(%ebp)
  800285:	ff d7                	call   *%edi
  800287:	83 c4 10             	add    $0x10,%esp
  80028a:	eb 03                	jmp    80028f <printnum+0x78>
  80028c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80028f:	83 eb 01             	sub    $0x1,%ebx
  800292:	85 db                	test   %ebx,%ebx
  800294:	7f e8                	jg     80027e <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800296:	83 ec 08             	sub    $0x8,%esp
  800299:	56                   	push   %esi
  80029a:	83 ec 04             	sub    $0x4,%esp
  80029d:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002a0:	ff 75 e0             	pushl  -0x20(%ebp)
  8002a3:	ff 75 dc             	pushl  -0x24(%ebp)
  8002a6:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a9:	e8 12 1b 00 00       	call   801dc0 <__umoddi3>
  8002ae:	83 c4 14             	add    $0x14,%esp
  8002b1:	0f be 80 bb 1f 80 00 	movsbl 0x801fbb(%eax),%eax
  8002b8:	50                   	push   %eax
  8002b9:	ff d7                	call   *%edi
}
  8002bb:	83 c4 10             	add    $0x10,%esp
  8002be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c1:	5b                   	pop    %ebx
  8002c2:	5e                   	pop    %esi
  8002c3:	5f                   	pop    %edi
  8002c4:	5d                   	pop    %ebp
  8002c5:	c3                   	ret    

008002c6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
  8002c9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002cc:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002d0:	8b 10                	mov    (%eax),%edx
  8002d2:	3b 50 04             	cmp    0x4(%eax),%edx
  8002d5:	73 0a                	jae    8002e1 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002d7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002da:	89 08                	mov    %ecx,(%eax)
  8002dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8002df:	88 02                	mov    %al,(%edx)
}
  8002e1:	5d                   	pop    %ebp
  8002e2:	c3                   	ret    

008002e3 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002e3:	55                   	push   %ebp
  8002e4:	89 e5                	mov    %esp,%ebp
  8002e6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002e9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002ec:	50                   	push   %eax
  8002ed:	ff 75 10             	pushl  0x10(%ebp)
  8002f0:	ff 75 0c             	pushl  0xc(%ebp)
  8002f3:	ff 75 08             	pushl  0x8(%ebp)
  8002f6:	e8 05 00 00 00       	call   800300 <vprintfmt>
	va_end(ap);
}
  8002fb:	83 c4 10             	add    $0x10,%esp
  8002fe:	c9                   	leave  
  8002ff:	c3                   	ret    

00800300 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
  800303:	57                   	push   %edi
  800304:	56                   	push   %esi
  800305:	53                   	push   %ebx
  800306:	83 ec 2c             	sub    $0x2c,%esp
  800309:	8b 75 08             	mov    0x8(%ebp),%esi
  80030c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80030f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800312:	eb 12                	jmp    800326 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800314:	85 c0                	test   %eax,%eax
  800316:	0f 84 42 04 00 00    	je     80075e <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  80031c:	83 ec 08             	sub    $0x8,%esp
  80031f:	53                   	push   %ebx
  800320:	50                   	push   %eax
  800321:	ff d6                	call   *%esi
  800323:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800326:	83 c7 01             	add    $0x1,%edi
  800329:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80032d:	83 f8 25             	cmp    $0x25,%eax
  800330:	75 e2                	jne    800314 <vprintfmt+0x14>
  800332:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800336:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80033d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800344:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80034b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800350:	eb 07                	jmp    800359 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800352:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800355:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800359:	8d 47 01             	lea    0x1(%edi),%eax
  80035c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80035f:	0f b6 07             	movzbl (%edi),%eax
  800362:	0f b6 d0             	movzbl %al,%edx
  800365:	83 e8 23             	sub    $0x23,%eax
  800368:	3c 55                	cmp    $0x55,%al
  80036a:	0f 87 d3 03 00 00    	ja     800743 <vprintfmt+0x443>
  800370:	0f b6 c0             	movzbl %al,%eax
  800373:	ff 24 85 00 21 80 00 	jmp    *0x802100(,%eax,4)
  80037a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80037d:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800381:	eb d6                	jmp    800359 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800383:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800386:	b8 00 00 00 00       	mov    $0x0,%eax
  80038b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80038e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800391:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800395:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800398:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80039b:	83 f9 09             	cmp    $0x9,%ecx
  80039e:	77 3f                	ja     8003df <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003a0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003a3:	eb e9                	jmp    80038e <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a8:	8b 00                	mov    (%eax),%eax
  8003aa:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b0:	8d 40 04             	lea    0x4(%eax),%eax
  8003b3:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003b9:	eb 2a                	jmp    8003e5 <vprintfmt+0xe5>
  8003bb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003be:	85 c0                	test   %eax,%eax
  8003c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8003c5:	0f 49 d0             	cmovns %eax,%edx
  8003c8:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ce:	eb 89                	jmp    800359 <vprintfmt+0x59>
  8003d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003d3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003da:	e9 7a ff ff ff       	jmp    800359 <vprintfmt+0x59>
  8003df:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003e2:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003e5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003e9:	0f 89 6a ff ff ff    	jns    800359 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003ef:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003f2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003f5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003fc:	e9 58 ff ff ff       	jmp    800359 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800401:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800404:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800407:	e9 4d ff ff ff       	jmp    800359 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80040c:	8b 45 14             	mov    0x14(%ebp),%eax
  80040f:	8d 78 04             	lea    0x4(%eax),%edi
  800412:	83 ec 08             	sub    $0x8,%esp
  800415:	53                   	push   %ebx
  800416:	ff 30                	pushl  (%eax)
  800418:	ff d6                	call   *%esi
			break;
  80041a:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80041d:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800420:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800423:	e9 fe fe ff ff       	jmp    800326 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800428:	8b 45 14             	mov    0x14(%ebp),%eax
  80042b:	8d 78 04             	lea    0x4(%eax),%edi
  80042e:	8b 00                	mov    (%eax),%eax
  800430:	99                   	cltd   
  800431:	31 d0                	xor    %edx,%eax
  800433:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800435:	83 f8 0f             	cmp    $0xf,%eax
  800438:	7f 0b                	jg     800445 <vprintfmt+0x145>
  80043a:	8b 14 85 60 22 80 00 	mov    0x802260(,%eax,4),%edx
  800441:	85 d2                	test   %edx,%edx
  800443:	75 1b                	jne    800460 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800445:	50                   	push   %eax
  800446:	68 d3 1f 80 00       	push   $0x801fd3
  80044b:	53                   	push   %ebx
  80044c:	56                   	push   %esi
  80044d:	e8 91 fe ff ff       	call   8002e3 <printfmt>
  800452:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800455:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800458:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80045b:	e9 c6 fe ff ff       	jmp    800326 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800460:	52                   	push   %edx
  800461:	68 95 23 80 00       	push   $0x802395
  800466:	53                   	push   %ebx
  800467:	56                   	push   %esi
  800468:	e8 76 fe ff ff       	call   8002e3 <printfmt>
  80046d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800470:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800473:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800476:	e9 ab fe ff ff       	jmp    800326 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80047b:	8b 45 14             	mov    0x14(%ebp),%eax
  80047e:	83 c0 04             	add    $0x4,%eax
  800481:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800484:	8b 45 14             	mov    0x14(%ebp),%eax
  800487:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800489:	85 ff                	test   %edi,%edi
  80048b:	b8 cc 1f 80 00       	mov    $0x801fcc,%eax
  800490:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800493:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800497:	0f 8e 94 00 00 00    	jle    800531 <vprintfmt+0x231>
  80049d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004a1:	0f 84 98 00 00 00    	je     80053f <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a7:	83 ec 08             	sub    $0x8,%esp
  8004aa:	ff 75 d0             	pushl  -0x30(%ebp)
  8004ad:	57                   	push   %edi
  8004ae:	e8 33 03 00 00       	call   8007e6 <strnlen>
  8004b3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004b6:	29 c1                	sub    %eax,%ecx
  8004b8:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004bb:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004be:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004c2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004c8:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ca:	eb 0f                	jmp    8004db <vprintfmt+0x1db>
					putch(padc, putdat);
  8004cc:	83 ec 08             	sub    $0x8,%esp
  8004cf:	53                   	push   %ebx
  8004d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8004d3:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d5:	83 ef 01             	sub    $0x1,%edi
  8004d8:	83 c4 10             	add    $0x10,%esp
  8004db:	85 ff                	test   %edi,%edi
  8004dd:	7f ed                	jg     8004cc <vprintfmt+0x1cc>
  8004df:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004e2:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004e5:	85 c9                	test   %ecx,%ecx
  8004e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ec:	0f 49 c1             	cmovns %ecx,%eax
  8004ef:	29 c1                	sub    %eax,%ecx
  8004f1:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004fa:	89 cb                	mov    %ecx,%ebx
  8004fc:	eb 4d                	jmp    80054b <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004fe:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800502:	74 1b                	je     80051f <vprintfmt+0x21f>
  800504:	0f be c0             	movsbl %al,%eax
  800507:	83 e8 20             	sub    $0x20,%eax
  80050a:	83 f8 5e             	cmp    $0x5e,%eax
  80050d:	76 10                	jbe    80051f <vprintfmt+0x21f>
					putch('?', putdat);
  80050f:	83 ec 08             	sub    $0x8,%esp
  800512:	ff 75 0c             	pushl  0xc(%ebp)
  800515:	6a 3f                	push   $0x3f
  800517:	ff 55 08             	call   *0x8(%ebp)
  80051a:	83 c4 10             	add    $0x10,%esp
  80051d:	eb 0d                	jmp    80052c <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80051f:	83 ec 08             	sub    $0x8,%esp
  800522:	ff 75 0c             	pushl  0xc(%ebp)
  800525:	52                   	push   %edx
  800526:	ff 55 08             	call   *0x8(%ebp)
  800529:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052c:	83 eb 01             	sub    $0x1,%ebx
  80052f:	eb 1a                	jmp    80054b <vprintfmt+0x24b>
  800531:	89 75 08             	mov    %esi,0x8(%ebp)
  800534:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800537:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80053a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80053d:	eb 0c                	jmp    80054b <vprintfmt+0x24b>
  80053f:	89 75 08             	mov    %esi,0x8(%ebp)
  800542:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800545:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800548:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80054b:	83 c7 01             	add    $0x1,%edi
  80054e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800552:	0f be d0             	movsbl %al,%edx
  800555:	85 d2                	test   %edx,%edx
  800557:	74 23                	je     80057c <vprintfmt+0x27c>
  800559:	85 f6                	test   %esi,%esi
  80055b:	78 a1                	js     8004fe <vprintfmt+0x1fe>
  80055d:	83 ee 01             	sub    $0x1,%esi
  800560:	79 9c                	jns    8004fe <vprintfmt+0x1fe>
  800562:	89 df                	mov    %ebx,%edi
  800564:	8b 75 08             	mov    0x8(%ebp),%esi
  800567:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80056a:	eb 18                	jmp    800584 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80056c:	83 ec 08             	sub    $0x8,%esp
  80056f:	53                   	push   %ebx
  800570:	6a 20                	push   $0x20
  800572:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800574:	83 ef 01             	sub    $0x1,%edi
  800577:	83 c4 10             	add    $0x10,%esp
  80057a:	eb 08                	jmp    800584 <vprintfmt+0x284>
  80057c:	89 df                	mov    %ebx,%edi
  80057e:	8b 75 08             	mov    0x8(%ebp),%esi
  800581:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800584:	85 ff                	test   %edi,%edi
  800586:	7f e4                	jg     80056c <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800588:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80058b:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800591:	e9 90 fd ff ff       	jmp    800326 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800596:	83 f9 01             	cmp    $0x1,%ecx
  800599:	7e 19                	jle    8005b4 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  80059b:	8b 45 14             	mov    0x14(%ebp),%eax
  80059e:	8b 50 04             	mov    0x4(%eax),%edx
  8005a1:	8b 00                	mov    (%eax),%eax
  8005a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ac:	8d 40 08             	lea    0x8(%eax),%eax
  8005af:	89 45 14             	mov    %eax,0x14(%ebp)
  8005b2:	eb 38                	jmp    8005ec <vprintfmt+0x2ec>
	else if (lflag)
  8005b4:	85 c9                	test   %ecx,%ecx
  8005b6:	74 1b                	je     8005d3 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8b 00                	mov    (%eax),%eax
  8005bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c0:	89 c1                	mov    %eax,%ecx
  8005c2:	c1 f9 1f             	sar    $0x1f,%ecx
  8005c5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cb:	8d 40 04             	lea    0x4(%eax),%eax
  8005ce:	89 45 14             	mov    %eax,0x14(%ebp)
  8005d1:	eb 19                	jmp    8005ec <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8005d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d6:	8b 00                	mov    (%eax),%eax
  8005d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005db:	89 c1                	mov    %eax,%ecx
  8005dd:	c1 f9 1f             	sar    $0x1f,%ecx
  8005e0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e6:	8d 40 04             	lea    0x4(%eax),%eax
  8005e9:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005ec:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005ef:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005f2:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005f7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005fb:	0f 89 0e 01 00 00    	jns    80070f <vprintfmt+0x40f>
				putch('-', putdat);
  800601:	83 ec 08             	sub    $0x8,%esp
  800604:	53                   	push   %ebx
  800605:	6a 2d                	push   $0x2d
  800607:	ff d6                	call   *%esi
				num = -(long long) num;
  800609:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80060c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80060f:	f7 da                	neg    %edx
  800611:	83 d1 00             	adc    $0x0,%ecx
  800614:	f7 d9                	neg    %ecx
  800616:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800619:	b8 0a 00 00 00       	mov    $0xa,%eax
  80061e:	e9 ec 00 00 00       	jmp    80070f <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800623:	83 f9 01             	cmp    $0x1,%ecx
  800626:	7e 18                	jle    800640 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800628:	8b 45 14             	mov    0x14(%ebp),%eax
  80062b:	8b 10                	mov    (%eax),%edx
  80062d:	8b 48 04             	mov    0x4(%eax),%ecx
  800630:	8d 40 08             	lea    0x8(%eax),%eax
  800633:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800636:	b8 0a 00 00 00       	mov    $0xa,%eax
  80063b:	e9 cf 00 00 00       	jmp    80070f <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800640:	85 c9                	test   %ecx,%ecx
  800642:	74 1a                	je     80065e <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800644:	8b 45 14             	mov    0x14(%ebp),%eax
  800647:	8b 10                	mov    (%eax),%edx
  800649:	b9 00 00 00 00       	mov    $0x0,%ecx
  80064e:	8d 40 04             	lea    0x4(%eax),%eax
  800651:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800654:	b8 0a 00 00 00       	mov    $0xa,%eax
  800659:	e9 b1 00 00 00       	jmp    80070f <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80065e:	8b 45 14             	mov    0x14(%ebp),%eax
  800661:	8b 10                	mov    (%eax),%edx
  800663:	b9 00 00 00 00       	mov    $0x0,%ecx
  800668:	8d 40 04             	lea    0x4(%eax),%eax
  80066b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80066e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800673:	e9 97 00 00 00       	jmp    80070f <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800678:	83 ec 08             	sub    $0x8,%esp
  80067b:	53                   	push   %ebx
  80067c:	6a 58                	push   $0x58
  80067e:	ff d6                	call   *%esi
			putch('X', putdat);
  800680:	83 c4 08             	add    $0x8,%esp
  800683:	53                   	push   %ebx
  800684:	6a 58                	push   $0x58
  800686:	ff d6                	call   *%esi
			putch('X', putdat);
  800688:	83 c4 08             	add    $0x8,%esp
  80068b:	53                   	push   %ebx
  80068c:	6a 58                	push   $0x58
  80068e:	ff d6                	call   *%esi
			break;
  800690:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800693:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800696:	e9 8b fc ff ff       	jmp    800326 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  80069b:	83 ec 08             	sub    $0x8,%esp
  80069e:	53                   	push   %ebx
  80069f:	6a 30                	push   $0x30
  8006a1:	ff d6                	call   *%esi
			putch('x', putdat);
  8006a3:	83 c4 08             	add    $0x8,%esp
  8006a6:	53                   	push   %ebx
  8006a7:	6a 78                	push   $0x78
  8006a9:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ae:	8b 10                	mov    (%eax),%edx
  8006b0:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006b5:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006b8:	8d 40 04             	lea    0x4(%eax),%eax
  8006bb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006be:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006c3:	eb 4a                	jmp    80070f <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006c5:	83 f9 01             	cmp    $0x1,%ecx
  8006c8:	7e 15                	jle    8006df <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8006ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cd:	8b 10                	mov    (%eax),%edx
  8006cf:	8b 48 04             	mov    0x4(%eax),%ecx
  8006d2:	8d 40 08             	lea    0x8(%eax),%eax
  8006d5:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006d8:	b8 10 00 00 00       	mov    $0x10,%eax
  8006dd:	eb 30                	jmp    80070f <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006df:	85 c9                	test   %ecx,%ecx
  8006e1:	74 17                	je     8006fa <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8006e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e6:	8b 10                	mov    (%eax),%edx
  8006e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ed:	8d 40 04             	lea    0x4(%eax),%eax
  8006f0:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006f3:	b8 10 00 00 00       	mov    $0x10,%eax
  8006f8:	eb 15                	jmp    80070f <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8006fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fd:	8b 10                	mov    (%eax),%edx
  8006ff:	b9 00 00 00 00       	mov    $0x0,%ecx
  800704:	8d 40 04             	lea    0x4(%eax),%eax
  800707:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80070a:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80070f:	83 ec 0c             	sub    $0xc,%esp
  800712:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800716:	57                   	push   %edi
  800717:	ff 75 e0             	pushl  -0x20(%ebp)
  80071a:	50                   	push   %eax
  80071b:	51                   	push   %ecx
  80071c:	52                   	push   %edx
  80071d:	89 da                	mov    %ebx,%edx
  80071f:	89 f0                	mov    %esi,%eax
  800721:	e8 f1 fa ff ff       	call   800217 <printnum>
			break;
  800726:	83 c4 20             	add    $0x20,%esp
  800729:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80072c:	e9 f5 fb ff ff       	jmp    800326 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800731:	83 ec 08             	sub    $0x8,%esp
  800734:	53                   	push   %ebx
  800735:	52                   	push   %edx
  800736:	ff d6                	call   *%esi
			break;
  800738:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80073b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80073e:	e9 e3 fb ff ff       	jmp    800326 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800743:	83 ec 08             	sub    $0x8,%esp
  800746:	53                   	push   %ebx
  800747:	6a 25                	push   $0x25
  800749:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80074b:	83 c4 10             	add    $0x10,%esp
  80074e:	eb 03                	jmp    800753 <vprintfmt+0x453>
  800750:	83 ef 01             	sub    $0x1,%edi
  800753:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800757:	75 f7                	jne    800750 <vprintfmt+0x450>
  800759:	e9 c8 fb ff ff       	jmp    800326 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80075e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800761:	5b                   	pop    %ebx
  800762:	5e                   	pop    %esi
  800763:	5f                   	pop    %edi
  800764:	5d                   	pop    %ebp
  800765:	c3                   	ret    

00800766 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800766:	55                   	push   %ebp
  800767:	89 e5                	mov    %esp,%ebp
  800769:	83 ec 18             	sub    $0x18,%esp
  80076c:	8b 45 08             	mov    0x8(%ebp),%eax
  80076f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800772:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800775:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800779:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80077c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800783:	85 c0                	test   %eax,%eax
  800785:	74 26                	je     8007ad <vsnprintf+0x47>
  800787:	85 d2                	test   %edx,%edx
  800789:	7e 22                	jle    8007ad <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80078b:	ff 75 14             	pushl  0x14(%ebp)
  80078e:	ff 75 10             	pushl  0x10(%ebp)
  800791:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800794:	50                   	push   %eax
  800795:	68 c6 02 80 00       	push   $0x8002c6
  80079a:	e8 61 fb ff ff       	call   800300 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80079f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007a2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a8:	83 c4 10             	add    $0x10,%esp
  8007ab:	eb 05                	jmp    8007b2 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007b2:	c9                   	leave  
  8007b3:	c3                   	ret    

008007b4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ba:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007bd:	50                   	push   %eax
  8007be:	ff 75 10             	pushl  0x10(%ebp)
  8007c1:	ff 75 0c             	pushl  0xc(%ebp)
  8007c4:	ff 75 08             	pushl  0x8(%ebp)
  8007c7:	e8 9a ff ff ff       	call   800766 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007cc:	c9                   	leave  
  8007cd:	c3                   	ret    

008007ce <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007ce:	55                   	push   %ebp
  8007cf:	89 e5                	mov    %esp,%ebp
  8007d1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d9:	eb 03                	jmp    8007de <strlen+0x10>
		n++;
  8007db:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007de:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007e2:	75 f7                	jne    8007db <strlen+0xd>
		n++;
	return n;
}
  8007e4:	5d                   	pop    %ebp
  8007e5:	c3                   	ret    

008007e6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007e6:	55                   	push   %ebp
  8007e7:	89 e5                	mov    %esp,%ebp
  8007e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ec:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8007f4:	eb 03                	jmp    8007f9 <strnlen+0x13>
		n++;
  8007f6:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f9:	39 c2                	cmp    %eax,%edx
  8007fb:	74 08                	je     800805 <strnlen+0x1f>
  8007fd:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800801:	75 f3                	jne    8007f6 <strnlen+0x10>
  800803:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800805:	5d                   	pop    %ebp
  800806:	c3                   	ret    

00800807 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	53                   	push   %ebx
  80080b:	8b 45 08             	mov    0x8(%ebp),%eax
  80080e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800811:	89 c2                	mov    %eax,%edx
  800813:	83 c2 01             	add    $0x1,%edx
  800816:	83 c1 01             	add    $0x1,%ecx
  800819:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80081d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800820:	84 db                	test   %bl,%bl
  800822:	75 ef                	jne    800813 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800824:	5b                   	pop    %ebx
  800825:	5d                   	pop    %ebp
  800826:	c3                   	ret    

00800827 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	53                   	push   %ebx
  80082b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80082e:	53                   	push   %ebx
  80082f:	e8 9a ff ff ff       	call   8007ce <strlen>
  800834:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800837:	ff 75 0c             	pushl  0xc(%ebp)
  80083a:	01 d8                	add    %ebx,%eax
  80083c:	50                   	push   %eax
  80083d:	e8 c5 ff ff ff       	call   800807 <strcpy>
	return dst;
}
  800842:	89 d8                	mov    %ebx,%eax
  800844:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800847:	c9                   	leave  
  800848:	c3                   	ret    

00800849 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800849:	55                   	push   %ebp
  80084a:	89 e5                	mov    %esp,%ebp
  80084c:	56                   	push   %esi
  80084d:	53                   	push   %ebx
  80084e:	8b 75 08             	mov    0x8(%ebp),%esi
  800851:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800854:	89 f3                	mov    %esi,%ebx
  800856:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800859:	89 f2                	mov    %esi,%edx
  80085b:	eb 0f                	jmp    80086c <strncpy+0x23>
		*dst++ = *src;
  80085d:	83 c2 01             	add    $0x1,%edx
  800860:	0f b6 01             	movzbl (%ecx),%eax
  800863:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800866:	80 39 01             	cmpb   $0x1,(%ecx)
  800869:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80086c:	39 da                	cmp    %ebx,%edx
  80086e:	75 ed                	jne    80085d <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800870:	89 f0                	mov    %esi,%eax
  800872:	5b                   	pop    %ebx
  800873:	5e                   	pop    %esi
  800874:	5d                   	pop    %ebp
  800875:	c3                   	ret    

00800876 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	56                   	push   %esi
  80087a:	53                   	push   %ebx
  80087b:	8b 75 08             	mov    0x8(%ebp),%esi
  80087e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800881:	8b 55 10             	mov    0x10(%ebp),%edx
  800884:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800886:	85 d2                	test   %edx,%edx
  800888:	74 21                	je     8008ab <strlcpy+0x35>
  80088a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80088e:	89 f2                	mov    %esi,%edx
  800890:	eb 09                	jmp    80089b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800892:	83 c2 01             	add    $0x1,%edx
  800895:	83 c1 01             	add    $0x1,%ecx
  800898:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80089b:	39 c2                	cmp    %eax,%edx
  80089d:	74 09                	je     8008a8 <strlcpy+0x32>
  80089f:	0f b6 19             	movzbl (%ecx),%ebx
  8008a2:	84 db                	test   %bl,%bl
  8008a4:	75 ec                	jne    800892 <strlcpy+0x1c>
  8008a6:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008a8:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008ab:	29 f0                	sub    %esi,%eax
}
  8008ad:	5b                   	pop    %ebx
  8008ae:	5e                   	pop    %esi
  8008af:	5d                   	pop    %ebp
  8008b0:	c3                   	ret    

008008b1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008b1:	55                   	push   %ebp
  8008b2:	89 e5                	mov    %esp,%ebp
  8008b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008ba:	eb 06                	jmp    8008c2 <strcmp+0x11>
		p++, q++;
  8008bc:	83 c1 01             	add    $0x1,%ecx
  8008bf:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008c2:	0f b6 01             	movzbl (%ecx),%eax
  8008c5:	84 c0                	test   %al,%al
  8008c7:	74 04                	je     8008cd <strcmp+0x1c>
  8008c9:	3a 02                	cmp    (%edx),%al
  8008cb:	74 ef                	je     8008bc <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008cd:	0f b6 c0             	movzbl %al,%eax
  8008d0:	0f b6 12             	movzbl (%edx),%edx
  8008d3:	29 d0                	sub    %edx,%eax
}
  8008d5:	5d                   	pop    %ebp
  8008d6:	c3                   	ret    

008008d7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	53                   	push   %ebx
  8008db:	8b 45 08             	mov    0x8(%ebp),%eax
  8008de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e1:	89 c3                	mov    %eax,%ebx
  8008e3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008e6:	eb 06                	jmp    8008ee <strncmp+0x17>
		n--, p++, q++;
  8008e8:	83 c0 01             	add    $0x1,%eax
  8008eb:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008ee:	39 d8                	cmp    %ebx,%eax
  8008f0:	74 15                	je     800907 <strncmp+0x30>
  8008f2:	0f b6 08             	movzbl (%eax),%ecx
  8008f5:	84 c9                	test   %cl,%cl
  8008f7:	74 04                	je     8008fd <strncmp+0x26>
  8008f9:	3a 0a                	cmp    (%edx),%cl
  8008fb:	74 eb                	je     8008e8 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008fd:	0f b6 00             	movzbl (%eax),%eax
  800900:	0f b6 12             	movzbl (%edx),%edx
  800903:	29 d0                	sub    %edx,%eax
  800905:	eb 05                	jmp    80090c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800907:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80090c:	5b                   	pop    %ebx
  80090d:	5d                   	pop    %ebp
  80090e:	c3                   	ret    

0080090f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80090f:	55                   	push   %ebp
  800910:	89 e5                	mov    %esp,%ebp
  800912:	8b 45 08             	mov    0x8(%ebp),%eax
  800915:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800919:	eb 07                	jmp    800922 <strchr+0x13>
		if (*s == c)
  80091b:	38 ca                	cmp    %cl,%dl
  80091d:	74 0f                	je     80092e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80091f:	83 c0 01             	add    $0x1,%eax
  800922:	0f b6 10             	movzbl (%eax),%edx
  800925:	84 d2                	test   %dl,%dl
  800927:	75 f2                	jne    80091b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800929:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80092e:	5d                   	pop    %ebp
  80092f:	c3                   	ret    

00800930 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800930:	55                   	push   %ebp
  800931:	89 e5                	mov    %esp,%ebp
  800933:	8b 45 08             	mov    0x8(%ebp),%eax
  800936:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80093a:	eb 03                	jmp    80093f <strfind+0xf>
  80093c:	83 c0 01             	add    $0x1,%eax
  80093f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800942:	38 ca                	cmp    %cl,%dl
  800944:	74 04                	je     80094a <strfind+0x1a>
  800946:	84 d2                	test   %dl,%dl
  800948:	75 f2                	jne    80093c <strfind+0xc>
			break;
	return (char *) s;
}
  80094a:	5d                   	pop    %ebp
  80094b:	c3                   	ret    

0080094c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80094c:	55                   	push   %ebp
  80094d:	89 e5                	mov    %esp,%ebp
  80094f:	57                   	push   %edi
  800950:	56                   	push   %esi
  800951:	53                   	push   %ebx
  800952:	8b 7d 08             	mov    0x8(%ebp),%edi
  800955:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800958:	85 c9                	test   %ecx,%ecx
  80095a:	74 36                	je     800992 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80095c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800962:	75 28                	jne    80098c <memset+0x40>
  800964:	f6 c1 03             	test   $0x3,%cl
  800967:	75 23                	jne    80098c <memset+0x40>
		c &= 0xFF;
  800969:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80096d:	89 d3                	mov    %edx,%ebx
  80096f:	c1 e3 08             	shl    $0x8,%ebx
  800972:	89 d6                	mov    %edx,%esi
  800974:	c1 e6 18             	shl    $0x18,%esi
  800977:	89 d0                	mov    %edx,%eax
  800979:	c1 e0 10             	shl    $0x10,%eax
  80097c:	09 f0                	or     %esi,%eax
  80097e:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800980:	89 d8                	mov    %ebx,%eax
  800982:	09 d0                	or     %edx,%eax
  800984:	c1 e9 02             	shr    $0x2,%ecx
  800987:	fc                   	cld    
  800988:	f3 ab                	rep stos %eax,%es:(%edi)
  80098a:	eb 06                	jmp    800992 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80098c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80098f:	fc                   	cld    
  800990:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800992:	89 f8                	mov    %edi,%eax
  800994:	5b                   	pop    %ebx
  800995:	5e                   	pop    %esi
  800996:	5f                   	pop    %edi
  800997:	5d                   	pop    %ebp
  800998:	c3                   	ret    

00800999 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800999:	55                   	push   %ebp
  80099a:	89 e5                	mov    %esp,%ebp
  80099c:	57                   	push   %edi
  80099d:	56                   	push   %esi
  80099e:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009a4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009a7:	39 c6                	cmp    %eax,%esi
  8009a9:	73 35                	jae    8009e0 <memmove+0x47>
  8009ab:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009ae:	39 d0                	cmp    %edx,%eax
  8009b0:	73 2e                	jae    8009e0 <memmove+0x47>
		s += n;
		d += n;
  8009b2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b5:	89 d6                	mov    %edx,%esi
  8009b7:	09 fe                	or     %edi,%esi
  8009b9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009bf:	75 13                	jne    8009d4 <memmove+0x3b>
  8009c1:	f6 c1 03             	test   $0x3,%cl
  8009c4:	75 0e                	jne    8009d4 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009c6:	83 ef 04             	sub    $0x4,%edi
  8009c9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009cc:	c1 e9 02             	shr    $0x2,%ecx
  8009cf:	fd                   	std    
  8009d0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d2:	eb 09                	jmp    8009dd <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009d4:	83 ef 01             	sub    $0x1,%edi
  8009d7:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009da:	fd                   	std    
  8009db:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009dd:	fc                   	cld    
  8009de:	eb 1d                	jmp    8009fd <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e0:	89 f2                	mov    %esi,%edx
  8009e2:	09 c2                	or     %eax,%edx
  8009e4:	f6 c2 03             	test   $0x3,%dl
  8009e7:	75 0f                	jne    8009f8 <memmove+0x5f>
  8009e9:	f6 c1 03             	test   $0x3,%cl
  8009ec:	75 0a                	jne    8009f8 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009ee:	c1 e9 02             	shr    $0x2,%ecx
  8009f1:	89 c7                	mov    %eax,%edi
  8009f3:	fc                   	cld    
  8009f4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009f6:	eb 05                	jmp    8009fd <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009f8:	89 c7                	mov    %eax,%edi
  8009fa:	fc                   	cld    
  8009fb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009fd:	5e                   	pop    %esi
  8009fe:	5f                   	pop    %edi
  8009ff:	5d                   	pop    %ebp
  800a00:	c3                   	ret    

00800a01 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a01:	55                   	push   %ebp
  800a02:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a04:	ff 75 10             	pushl  0x10(%ebp)
  800a07:	ff 75 0c             	pushl  0xc(%ebp)
  800a0a:	ff 75 08             	pushl  0x8(%ebp)
  800a0d:	e8 87 ff ff ff       	call   800999 <memmove>
}
  800a12:	c9                   	leave  
  800a13:	c3                   	ret    

00800a14 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	56                   	push   %esi
  800a18:	53                   	push   %ebx
  800a19:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a1f:	89 c6                	mov    %eax,%esi
  800a21:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a24:	eb 1a                	jmp    800a40 <memcmp+0x2c>
		if (*s1 != *s2)
  800a26:	0f b6 08             	movzbl (%eax),%ecx
  800a29:	0f b6 1a             	movzbl (%edx),%ebx
  800a2c:	38 d9                	cmp    %bl,%cl
  800a2e:	74 0a                	je     800a3a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a30:	0f b6 c1             	movzbl %cl,%eax
  800a33:	0f b6 db             	movzbl %bl,%ebx
  800a36:	29 d8                	sub    %ebx,%eax
  800a38:	eb 0f                	jmp    800a49 <memcmp+0x35>
		s1++, s2++;
  800a3a:	83 c0 01             	add    $0x1,%eax
  800a3d:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a40:	39 f0                	cmp    %esi,%eax
  800a42:	75 e2                	jne    800a26 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a44:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a49:	5b                   	pop    %ebx
  800a4a:	5e                   	pop    %esi
  800a4b:	5d                   	pop    %ebp
  800a4c:	c3                   	ret    

00800a4d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a4d:	55                   	push   %ebp
  800a4e:	89 e5                	mov    %esp,%ebp
  800a50:	53                   	push   %ebx
  800a51:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a54:	89 c1                	mov    %eax,%ecx
  800a56:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a59:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a5d:	eb 0a                	jmp    800a69 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a5f:	0f b6 10             	movzbl (%eax),%edx
  800a62:	39 da                	cmp    %ebx,%edx
  800a64:	74 07                	je     800a6d <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a66:	83 c0 01             	add    $0x1,%eax
  800a69:	39 c8                	cmp    %ecx,%eax
  800a6b:	72 f2                	jb     800a5f <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a6d:	5b                   	pop    %ebx
  800a6e:	5d                   	pop    %ebp
  800a6f:	c3                   	ret    

00800a70 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	57                   	push   %edi
  800a74:	56                   	push   %esi
  800a75:	53                   	push   %ebx
  800a76:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a79:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a7c:	eb 03                	jmp    800a81 <strtol+0x11>
		s++;
  800a7e:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a81:	0f b6 01             	movzbl (%ecx),%eax
  800a84:	3c 20                	cmp    $0x20,%al
  800a86:	74 f6                	je     800a7e <strtol+0xe>
  800a88:	3c 09                	cmp    $0x9,%al
  800a8a:	74 f2                	je     800a7e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a8c:	3c 2b                	cmp    $0x2b,%al
  800a8e:	75 0a                	jne    800a9a <strtol+0x2a>
		s++;
  800a90:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a93:	bf 00 00 00 00       	mov    $0x0,%edi
  800a98:	eb 11                	jmp    800aab <strtol+0x3b>
  800a9a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a9f:	3c 2d                	cmp    $0x2d,%al
  800aa1:	75 08                	jne    800aab <strtol+0x3b>
		s++, neg = 1;
  800aa3:	83 c1 01             	add    $0x1,%ecx
  800aa6:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aab:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ab1:	75 15                	jne    800ac8 <strtol+0x58>
  800ab3:	80 39 30             	cmpb   $0x30,(%ecx)
  800ab6:	75 10                	jne    800ac8 <strtol+0x58>
  800ab8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800abc:	75 7c                	jne    800b3a <strtol+0xca>
		s += 2, base = 16;
  800abe:	83 c1 02             	add    $0x2,%ecx
  800ac1:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ac6:	eb 16                	jmp    800ade <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ac8:	85 db                	test   %ebx,%ebx
  800aca:	75 12                	jne    800ade <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800acc:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ad1:	80 39 30             	cmpb   $0x30,(%ecx)
  800ad4:	75 08                	jne    800ade <strtol+0x6e>
		s++, base = 8;
  800ad6:	83 c1 01             	add    $0x1,%ecx
  800ad9:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ade:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae3:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ae6:	0f b6 11             	movzbl (%ecx),%edx
  800ae9:	8d 72 d0             	lea    -0x30(%edx),%esi
  800aec:	89 f3                	mov    %esi,%ebx
  800aee:	80 fb 09             	cmp    $0x9,%bl
  800af1:	77 08                	ja     800afb <strtol+0x8b>
			dig = *s - '0';
  800af3:	0f be d2             	movsbl %dl,%edx
  800af6:	83 ea 30             	sub    $0x30,%edx
  800af9:	eb 22                	jmp    800b1d <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800afb:	8d 72 9f             	lea    -0x61(%edx),%esi
  800afe:	89 f3                	mov    %esi,%ebx
  800b00:	80 fb 19             	cmp    $0x19,%bl
  800b03:	77 08                	ja     800b0d <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b05:	0f be d2             	movsbl %dl,%edx
  800b08:	83 ea 57             	sub    $0x57,%edx
  800b0b:	eb 10                	jmp    800b1d <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b0d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b10:	89 f3                	mov    %esi,%ebx
  800b12:	80 fb 19             	cmp    $0x19,%bl
  800b15:	77 16                	ja     800b2d <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b17:	0f be d2             	movsbl %dl,%edx
  800b1a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b1d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b20:	7d 0b                	jge    800b2d <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b22:	83 c1 01             	add    $0x1,%ecx
  800b25:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b29:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b2b:	eb b9                	jmp    800ae6 <strtol+0x76>

	if (endptr)
  800b2d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b31:	74 0d                	je     800b40 <strtol+0xd0>
		*endptr = (char *) s;
  800b33:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b36:	89 0e                	mov    %ecx,(%esi)
  800b38:	eb 06                	jmp    800b40 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b3a:	85 db                	test   %ebx,%ebx
  800b3c:	74 98                	je     800ad6 <strtol+0x66>
  800b3e:	eb 9e                	jmp    800ade <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b40:	89 c2                	mov    %eax,%edx
  800b42:	f7 da                	neg    %edx
  800b44:	85 ff                	test   %edi,%edi
  800b46:	0f 45 c2             	cmovne %edx,%eax
}
  800b49:	5b                   	pop    %ebx
  800b4a:	5e                   	pop    %esi
  800b4b:	5f                   	pop    %edi
  800b4c:	5d                   	pop    %ebp
  800b4d:	c3                   	ret    

00800b4e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b4e:	55                   	push   %ebp
  800b4f:	89 e5                	mov    %esp,%ebp
  800b51:	57                   	push   %edi
  800b52:	56                   	push   %esi
  800b53:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b54:	b8 00 00 00 00       	mov    $0x0,%eax
  800b59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5f:	89 c3                	mov    %eax,%ebx
  800b61:	89 c7                	mov    %eax,%edi
  800b63:	89 c6                	mov    %eax,%esi
  800b65:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b67:	5b                   	pop    %ebx
  800b68:	5e                   	pop    %esi
  800b69:	5f                   	pop    %edi
  800b6a:	5d                   	pop    %ebp
  800b6b:	c3                   	ret    

00800b6c <sys_cgetc>:

int
sys_cgetc(void)
{
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	57                   	push   %edi
  800b70:	56                   	push   %esi
  800b71:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b72:	ba 00 00 00 00       	mov    $0x0,%edx
  800b77:	b8 01 00 00 00       	mov    $0x1,%eax
  800b7c:	89 d1                	mov    %edx,%ecx
  800b7e:	89 d3                	mov    %edx,%ebx
  800b80:	89 d7                	mov    %edx,%edi
  800b82:	89 d6                	mov    %edx,%esi
  800b84:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b86:	5b                   	pop    %ebx
  800b87:	5e                   	pop    %esi
  800b88:	5f                   	pop    %edi
  800b89:	5d                   	pop    %ebp
  800b8a:	c3                   	ret    

00800b8b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b8b:	55                   	push   %ebp
  800b8c:	89 e5                	mov    %esp,%ebp
  800b8e:	57                   	push   %edi
  800b8f:	56                   	push   %esi
  800b90:	53                   	push   %ebx
  800b91:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b94:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b99:	b8 03 00 00 00       	mov    $0x3,%eax
  800b9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba1:	89 cb                	mov    %ecx,%ebx
  800ba3:	89 cf                	mov    %ecx,%edi
  800ba5:	89 ce                	mov    %ecx,%esi
  800ba7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ba9:	85 c0                	test   %eax,%eax
  800bab:	7e 17                	jle    800bc4 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bad:	83 ec 0c             	sub    $0xc,%esp
  800bb0:	50                   	push   %eax
  800bb1:	6a 03                	push   $0x3
  800bb3:	68 bf 22 80 00       	push   $0x8022bf
  800bb8:	6a 23                	push   $0x23
  800bba:	68 dc 22 80 00       	push   $0x8022dc
  800bbf:	e8 66 f5 ff ff       	call   80012a <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc7:	5b                   	pop    %ebx
  800bc8:	5e                   	pop    %esi
  800bc9:	5f                   	pop    %edi
  800bca:	5d                   	pop    %ebp
  800bcb:	c3                   	ret    

00800bcc <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bcc:	55                   	push   %ebp
  800bcd:	89 e5                	mov    %esp,%ebp
  800bcf:	57                   	push   %edi
  800bd0:	56                   	push   %esi
  800bd1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd7:	b8 02 00 00 00       	mov    $0x2,%eax
  800bdc:	89 d1                	mov    %edx,%ecx
  800bde:	89 d3                	mov    %edx,%ebx
  800be0:	89 d7                	mov    %edx,%edi
  800be2:	89 d6                	mov    %edx,%esi
  800be4:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800be6:	5b                   	pop    %ebx
  800be7:	5e                   	pop    %esi
  800be8:	5f                   	pop    %edi
  800be9:	5d                   	pop    %ebp
  800bea:	c3                   	ret    

00800beb <sys_yield>:

void
sys_yield(void)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	57                   	push   %edi
  800bef:	56                   	push   %esi
  800bf0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf1:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf6:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bfb:	89 d1                	mov    %edx,%ecx
  800bfd:	89 d3                	mov    %edx,%ebx
  800bff:	89 d7                	mov    %edx,%edi
  800c01:	89 d6                	mov    %edx,%esi
  800c03:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c05:	5b                   	pop    %ebx
  800c06:	5e                   	pop    %esi
  800c07:	5f                   	pop    %edi
  800c08:	5d                   	pop    %ebp
  800c09:	c3                   	ret    

00800c0a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	57                   	push   %edi
  800c0e:	56                   	push   %esi
  800c0f:	53                   	push   %ebx
  800c10:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c13:	be 00 00 00 00       	mov    $0x0,%esi
  800c18:	b8 04 00 00 00       	mov    $0x4,%eax
  800c1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c20:	8b 55 08             	mov    0x8(%ebp),%edx
  800c23:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c26:	89 f7                	mov    %esi,%edi
  800c28:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c2a:	85 c0                	test   %eax,%eax
  800c2c:	7e 17                	jle    800c45 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2e:	83 ec 0c             	sub    $0xc,%esp
  800c31:	50                   	push   %eax
  800c32:	6a 04                	push   $0x4
  800c34:	68 bf 22 80 00       	push   $0x8022bf
  800c39:	6a 23                	push   $0x23
  800c3b:	68 dc 22 80 00       	push   $0x8022dc
  800c40:	e8 e5 f4 ff ff       	call   80012a <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c48:	5b                   	pop    %ebx
  800c49:	5e                   	pop    %esi
  800c4a:	5f                   	pop    %edi
  800c4b:	5d                   	pop    %ebp
  800c4c:	c3                   	ret    

00800c4d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c4d:	55                   	push   %ebp
  800c4e:	89 e5                	mov    %esp,%ebp
  800c50:	57                   	push   %edi
  800c51:	56                   	push   %esi
  800c52:	53                   	push   %ebx
  800c53:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c56:	b8 05 00 00 00       	mov    $0x5,%eax
  800c5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c61:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c64:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c67:	8b 75 18             	mov    0x18(%ebp),%esi
  800c6a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c6c:	85 c0                	test   %eax,%eax
  800c6e:	7e 17                	jle    800c87 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c70:	83 ec 0c             	sub    $0xc,%esp
  800c73:	50                   	push   %eax
  800c74:	6a 05                	push   $0x5
  800c76:	68 bf 22 80 00       	push   $0x8022bf
  800c7b:	6a 23                	push   $0x23
  800c7d:	68 dc 22 80 00       	push   $0x8022dc
  800c82:	e8 a3 f4 ff ff       	call   80012a <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8a:	5b                   	pop    %ebx
  800c8b:	5e                   	pop    %esi
  800c8c:	5f                   	pop    %edi
  800c8d:	5d                   	pop    %ebp
  800c8e:	c3                   	ret    

00800c8f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c8f:	55                   	push   %ebp
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	57                   	push   %edi
  800c93:	56                   	push   %esi
  800c94:	53                   	push   %ebx
  800c95:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c98:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9d:	b8 06 00 00 00       	mov    $0x6,%eax
  800ca2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca8:	89 df                	mov    %ebx,%edi
  800caa:	89 de                	mov    %ebx,%esi
  800cac:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cae:	85 c0                	test   %eax,%eax
  800cb0:	7e 17                	jle    800cc9 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb2:	83 ec 0c             	sub    $0xc,%esp
  800cb5:	50                   	push   %eax
  800cb6:	6a 06                	push   $0x6
  800cb8:	68 bf 22 80 00       	push   $0x8022bf
  800cbd:	6a 23                	push   $0x23
  800cbf:	68 dc 22 80 00       	push   $0x8022dc
  800cc4:	e8 61 f4 ff ff       	call   80012a <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cc9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ccc:	5b                   	pop    %ebx
  800ccd:	5e                   	pop    %esi
  800cce:	5f                   	pop    %edi
  800ccf:	5d                   	pop    %ebp
  800cd0:	c3                   	ret    

00800cd1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cd1:	55                   	push   %ebp
  800cd2:	89 e5                	mov    %esp,%ebp
  800cd4:	57                   	push   %edi
  800cd5:	56                   	push   %esi
  800cd6:	53                   	push   %ebx
  800cd7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cda:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cdf:	b8 08 00 00 00       	mov    $0x8,%eax
  800ce4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cea:	89 df                	mov    %ebx,%edi
  800cec:	89 de                	mov    %ebx,%esi
  800cee:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cf0:	85 c0                	test   %eax,%eax
  800cf2:	7e 17                	jle    800d0b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf4:	83 ec 0c             	sub    $0xc,%esp
  800cf7:	50                   	push   %eax
  800cf8:	6a 08                	push   $0x8
  800cfa:	68 bf 22 80 00       	push   $0x8022bf
  800cff:	6a 23                	push   $0x23
  800d01:	68 dc 22 80 00       	push   $0x8022dc
  800d06:	e8 1f f4 ff ff       	call   80012a <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0e:	5b                   	pop    %ebx
  800d0f:	5e                   	pop    %esi
  800d10:	5f                   	pop    %edi
  800d11:	5d                   	pop    %ebp
  800d12:	c3                   	ret    

00800d13 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d13:	55                   	push   %ebp
  800d14:	89 e5                	mov    %esp,%ebp
  800d16:	57                   	push   %edi
  800d17:	56                   	push   %esi
  800d18:	53                   	push   %ebx
  800d19:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d21:	b8 09 00 00 00       	mov    $0x9,%eax
  800d26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d29:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2c:	89 df                	mov    %ebx,%edi
  800d2e:	89 de                	mov    %ebx,%esi
  800d30:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d32:	85 c0                	test   %eax,%eax
  800d34:	7e 17                	jle    800d4d <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d36:	83 ec 0c             	sub    $0xc,%esp
  800d39:	50                   	push   %eax
  800d3a:	6a 09                	push   $0x9
  800d3c:	68 bf 22 80 00       	push   $0x8022bf
  800d41:	6a 23                	push   $0x23
  800d43:	68 dc 22 80 00       	push   $0x8022dc
  800d48:	e8 dd f3 ff ff       	call   80012a <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d50:	5b                   	pop    %ebx
  800d51:	5e                   	pop    %esi
  800d52:	5f                   	pop    %edi
  800d53:	5d                   	pop    %ebp
  800d54:	c3                   	ret    

00800d55 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d55:	55                   	push   %ebp
  800d56:	89 e5                	mov    %esp,%ebp
  800d58:	57                   	push   %edi
  800d59:	56                   	push   %esi
  800d5a:	53                   	push   %ebx
  800d5b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d63:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6e:	89 df                	mov    %ebx,%edi
  800d70:	89 de                	mov    %ebx,%esi
  800d72:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d74:	85 c0                	test   %eax,%eax
  800d76:	7e 17                	jle    800d8f <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d78:	83 ec 0c             	sub    $0xc,%esp
  800d7b:	50                   	push   %eax
  800d7c:	6a 0a                	push   $0xa
  800d7e:	68 bf 22 80 00       	push   $0x8022bf
  800d83:	6a 23                	push   $0x23
  800d85:	68 dc 22 80 00       	push   $0x8022dc
  800d8a:	e8 9b f3 ff ff       	call   80012a <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d92:	5b                   	pop    %ebx
  800d93:	5e                   	pop    %esi
  800d94:	5f                   	pop    %edi
  800d95:	5d                   	pop    %ebp
  800d96:	c3                   	ret    

00800d97 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d97:	55                   	push   %ebp
  800d98:	89 e5                	mov    %esp,%ebp
  800d9a:	57                   	push   %edi
  800d9b:	56                   	push   %esi
  800d9c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9d:	be 00 00 00 00       	mov    $0x0,%esi
  800da2:	b8 0c 00 00 00       	mov    $0xc,%eax
  800da7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800daa:	8b 55 08             	mov    0x8(%ebp),%edx
  800dad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800db0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800db3:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800db5:	5b                   	pop    %ebx
  800db6:	5e                   	pop    %esi
  800db7:	5f                   	pop    %edi
  800db8:	5d                   	pop    %ebp
  800db9:	c3                   	ret    

00800dba <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dba:	55                   	push   %ebp
  800dbb:	89 e5                	mov    %esp,%ebp
  800dbd:	57                   	push   %edi
  800dbe:	56                   	push   %esi
  800dbf:	53                   	push   %ebx
  800dc0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dc8:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dcd:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd0:	89 cb                	mov    %ecx,%ebx
  800dd2:	89 cf                	mov    %ecx,%edi
  800dd4:	89 ce                	mov    %ecx,%esi
  800dd6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dd8:	85 c0                	test   %eax,%eax
  800dda:	7e 17                	jle    800df3 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ddc:	83 ec 0c             	sub    $0xc,%esp
  800ddf:	50                   	push   %eax
  800de0:	6a 0d                	push   $0xd
  800de2:	68 bf 22 80 00       	push   $0x8022bf
  800de7:	6a 23                	push   $0x23
  800de9:	68 dc 22 80 00       	push   $0x8022dc
  800dee:	e8 37 f3 ff ff       	call   80012a <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800df3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df6:	5b                   	pop    %ebx
  800df7:	5e                   	pop    %esi
  800df8:	5f                   	pop    %edi
  800df9:	5d                   	pop    %ebp
  800dfa:	c3                   	ret    

00800dfb <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800dfb:	55                   	push   %ebp
  800dfc:	89 e5                	mov    %esp,%ebp
  800dfe:	53                   	push   %ebx
  800dff:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  800e02:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800e09:	75 28                	jne    800e33 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		void *va = (void *) (UXSTACKTOP - PGSIZE);
		envid_t envid = sys_getenvid();
  800e0b:	e8 bc fd ff ff       	call   800bcc <sys_getenvid>
  800e10:	89 c3                	mov    %eax,%ebx

		sys_page_alloc(envid, va, PTE_P | PTE_U | PTE_W);
  800e12:	83 ec 04             	sub    $0x4,%esp
  800e15:	6a 07                	push   $0x7
  800e17:	68 00 f0 bf ee       	push   $0xeebff000
  800e1c:	50                   	push   %eax
  800e1d:	e8 e8 fd ff ff       	call   800c0a <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  800e22:	83 c4 08             	add    $0x8,%esp
  800e25:	68 40 0e 80 00       	push   $0x800e40
  800e2a:	53                   	push   %ebx
  800e2b:	e8 25 ff ff ff       	call   800d55 <sys_env_set_pgfault_upcall>
  800e30:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e33:	8b 45 08             	mov    0x8(%ebp),%eax
  800e36:	a3 08 40 80 00       	mov    %eax,0x804008
}
  800e3b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e3e:	c9                   	leave  
  800e3f:	c3                   	ret    

00800e40 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp				// function argument: pointer to UTF
  800e40:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e41:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800e46:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e48:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp, %ebx		// 40 = size between utf_fault_va ~ utf_regs
  800e4b:	89 e3                	mov    %esp,%ebx
	movl 40(%esp), %eax // point to utf_eip
  800e4d:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %esp // point to utf_esp
  800e51:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax 			// push eip of utf
  800e55:	50                   	push   %eax

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx, %esp 	// back to origin exception stack
  800e56:	89 dc                	mov    %ebx,%esp
	subl $4, 48(%esp) 	// utf_esp - 4
  800e58:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	popl %eax  			// pop utf_fault_va (ignore)
  800e5d:	58                   	pop    %eax
	popl %eax  			// pop utf_err (ignore)
  800e5e:	58                   	pop    %eax
	popal 				// pop utf_regs 
  800e5f:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4, %esp 		// ignore utf_eip
  800e60:	83 c4 04             	add    $0x4,%esp
	popfl 				// restore utf_eflags to eflags
  800e63:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp  			// restore %esp = utf_esp
  800e64:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800e65:	c3                   	ret    

00800e66 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e66:	55                   	push   %ebp
  800e67:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e69:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6c:	05 00 00 00 30       	add    $0x30000000,%eax
  800e71:	c1 e8 0c             	shr    $0xc,%eax
}
  800e74:	5d                   	pop    %ebp
  800e75:	c3                   	ret    

00800e76 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e76:	55                   	push   %ebp
  800e77:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e79:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7c:	05 00 00 00 30       	add    $0x30000000,%eax
  800e81:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e86:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e8b:	5d                   	pop    %ebp
  800e8c:	c3                   	ret    

00800e8d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e8d:	55                   	push   %ebp
  800e8e:	89 e5                	mov    %esp,%ebp
  800e90:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e93:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e98:	89 c2                	mov    %eax,%edx
  800e9a:	c1 ea 16             	shr    $0x16,%edx
  800e9d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ea4:	f6 c2 01             	test   $0x1,%dl
  800ea7:	74 11                	je     800eba <fd_alloc+0x2d>
  800ea9:	89 c2                	mov    %eax,%edx
  800eab:	c1 ea 0c             	shr    $0xc,%edx
  800eae:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eb5:	f6 c2 01             	test   $0x1,%dl
  800eb8:	75 09                	jne    800ec3 <fd_alloc+0x36>
			*fd_store = fd;
  800eba:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ebc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec1:	eb 17                	jmp    800eda <fd_alloc+0x4d>
  800ec3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800ec8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ecd:	75 c9                	jne    800e98 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800ecf:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800ed5:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800eda:	5d                   	pop    %ebp
  800edb:	c3                   	ret    

00800edc <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800edc:	55                   	push   %ebp
  800edd:	89 e5                	mov    %esp,%ebp
  800edf:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ee2:	83 f8 1f             	cmp    $0x1f,%eax
  800ee5:	77 36                	ja     800f1d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ee7:	c1 e0 0c             	shl    $0xc,%eax
  800eea:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800eef:	89 c2                	mov    %eax,%edx
  800ef1:	c1 ea 16             	shr    $0x16,%edx
  800ef4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800efb:	f6 c2 01             	test   $0x1,%dl
  800efe:	74 24                	je     800f24 <fd_lookup+0x48>
  800f00:	89 c2                	mov    %eax,%edx
  800f02:	c1 ea 0c             	shr    $0xc,%edx
  800f05:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f0c:	f6 c2 01             	test   $0x1,%dl
  800f0f:	74 1a                	je     800f2b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f11:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f14:	89 02                	mov    %eax,(%edx)
	return 0;
  800f16:	b8 00 00 00 00       	mov    $0x0,%eax
  800f1b:	eb 13                	jmp    800f30 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f1d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f22:	eb 0c                	jmp    800f30 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f24:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f29:	eb 05                	jmp    800f30 <fd_lookup+0x54>
  800f2b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f30:	5d                   	pop    %ebp
  800f31:	c3                   	ret    

00800f32 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f32:	55                   	push   %ebp
  800f33:	89 e5                	mov    %esp,%ebp
  800f35:	83 ec 08             	sub    $0x8,%esp
  800f38:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f3b:	ba 6c 23 80 00       	mov    $0x80236c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f40:	eb 13                	jmp    800f55 <dev_lookup+0x23>
  800f42:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f45:	39 08                	cmp    %ecx,(%eax)
  800f47:	75 0c                	jne    800f55 <dev_lookup+0x23>
			*dev = devtab[i];
  800f49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f4c:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f4e:	b8 00 00 00 00       	mov    $0x0,%eax
  800f53:	eb 2e                	jmp    800f83 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f55:	8b 02                	mov    (%edx),%eax
  800f57:	85 c0                	test   %eax,%eax
  800f59:	75 e7                	jne    800f42 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f5b:	a1 04 40 80 00       	mov    0x804004,%eax
  800f60:	8b 40 48             	mov    0x48(%eax),%eax
  800f63:	83 ec 04             	sub    $0x4,%esp
  800f66:	51                   	push   %ecx
  800f67:	50                   	push   %eax
  800f68:	68 ec 22 80 00       	push   $0x8022ec
  800f6d:	e8 91 f2 ff ff       	call   800203 <cprintf>
	*dev = 0;
  800f72:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f75:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f7b:	83 c4 10             	add    $0x10,%esp
  800f7e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f83:	c9                   	leave  
  800f84:	c3                   	ret    

00800f85 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f85:	55                   	push   %ebp
  800f86:	89 e5                	mov    %esp,%ebp
  800f88:	56                   	push   %esi
  800f89:	53                   	push   %ebx
  800f8a:	83 ec 10             	sub    $0x10,%esp
  800f8d:	8b 75 08             	mov    0x8(%ebp),%esi
  800f90:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f93:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f96:	50                   	push   %eax
  800f97:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f9d:	c1 e8 0c             	shr    $0xc,%eax
  800fa0:	50                   	push   %eax
  800fa1:	e8 36 ff ff ff       	call   800edc <fd_lookup>
  800fa6:	83 c4 08             	add    $0x8,%esp
  800fa9:	85 c0                	test   %eax,%eax
  800fab:	78 05                	js     800fb2 <fd_close+0x2d>
	    || fd != fd2)
  800fad:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800fb0:	74 0c                	je     800fbe <fd_close+0x39>
		return (must_exist ? r : 0);
  800fb2:	84 db                	test   %bl,%bl
  800fb4:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb9:	0f 44 c2             	cmove  %edx,%eax
  800fbc:	eb 41                	jmp    800fff <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fbe:	83 ec 08             	sub    $0x8,%esp
  800fc1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fc4:	50                   	push   %eax
  800fc5:	ff 36                	pushl  (%esi)
  800fc7:	e8 66 ff ff ff       	call   800f32 <dev_lookup>
  800fcc:	89 c3                	mov    %eax,%ebx
  800fce:	83 c4 10             	add    $0x10,%esp
  800fd1:	85 c0                	test   %eax,%eax
  800fd3:	78 1a                	js     800fef <fd_close+0x6a>
		if (dev->dev_close)
  800fd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fd8:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800fdb:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800fe0:	85 c0                	test   %eax,%eax
  800fe2:	74 0b                	je     800fef <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800fe4:	83 ec 0c             	sub    $0xc,%esp
  800fe7:	56                   	push   %esi
  800fe8:	ff d0                	call   *%eax
  800fea:	89 c3                	mov    %eax,%ebx
  800fec:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fef:	83 ec 08             	sub    $0x8,%esp
  800ff2:	56                   	push   %esi
  800ff3:	6a 00                	push   $0x0
  800ff5:	e8 95 fc ff ff       	call   800c8f <sys_page_unmap>
	return r;
  800ffa:	83 c4 10             	add    $0x10,%esp
  800ffd:	89 d8                	mov    %ebx,%eax
}
  800fff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801002:	5b                   	pop    %ebx
  801003:	5e                   	pop    %esi
  801004:	5d                   	pop    %ebp
  801005:	c3                   	ret    

00801006 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801006:	55                   	push   %ebp
  801007:	89 e5                	mov    %esp,%ebp
  801009:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80100c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80100f:	50                   	push   %eax
  801010:	ff 75 08             	pushl  0x8(%ebp)
  801013:	e8 c4 fe ff ff       	call   800edc <fd_lookup>
  801018:	83 c4 08             	add    $0x8,%esp
  80101b:	85 c0                	test   %eax,%eax
  80101d:	78 10                	js     80102f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80101f:	83 ec 08             	sub    $0x8,%esp
  801022:	6a 01                	push   $0x1
  801024:	ff 75 f4             	pushl  -0xc(%ebp)
  801027:	e8 59 ff ff ff       	call   800f85 <fd_close>
  80102c:	83 c4 10             	add    $0x10,%esp
}
  80102f:	c9                   	leave  
  801030:	c3                   	ret    

00801031 <close_all>:

void
close_all(void)
{
  801031:	55                   	push   %ebp
  801032:	89 e5                	mov    %esp,%ebp
  801034:	53                   	push   %ebx
  801035:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801038:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80103d:	83 ec 0c             	sub    $0xc,%esp
  801040:	53                   	push   %ebx
  801041:	e8 c0 ff ff ff       	call   801006 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801046:	83 c3 01             	add    $0x1,%ebx
  801049:	83 c4 10             	add    $0x10,%esp
  80104c:	83 fb 20             	cmp    $0x20,%ebx
  80104f:	75 ec                	jne    80103d <close_all+0xc>
		close(i);
}
  801051:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801054:	c9                   	leave  
  801055:	c3                   	ret    

00801056 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801056:	55                   	push   %ebp
  801057:	89 e5                	mov    %esp,%ebp
  801059:	57                   	push   %edi
  80105a:	56                   	push   %esi
  80105b:	53                   	push   %ebx
  80105c:	83 ec 2c             	sub    $0x2c,%esp
  80105f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801062:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801065:	50                   	push   %eax
  801066:	ff 75 08             	pushl  0x8(%ebp)
  801069:	e8 6e fe ff ff       	call   800edc <fd_lookup>
  80106e:	83 c4 08             	add    $0x8,%esp
  801071:	85 c0                	test   %eax,%eax
  801073:	0f 88 c1 00 00 00    	js     80113a <dup+0xe4>
		return r;
	close(newfdnum);
  801079:	83 ec 0c             	sub    $0xc,%esp
  80107c:	56                   	push   %esi
  80107d:	e8 84 ff ff ff       	call   801006 <close>

	newfd = INDEX2FD(newfdnum);
  801082:	89 f3                	mov    %esi,%ebx
  801084:	c1 e3 0c             	shl    $0xc,%ebx
  801087:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80108d:	83 c4 04             	add    $0x4,%esp
  801090:	ff 75 e4             	pushl  -0x1c(%ebp)
  801093:	e8 de fd ff ff       	call   800e76 <fd2data>
  801098:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80109a:	89 1c 24             	mov    %ebx,(%esp)
  80109d:	e8 d4 fd ff ff       	call   800e76 <fd2data>
  8010a2:	83 c4 10             	add    $0x10,%esp
  8010a5:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010a8:	89 f8                	mov    %edi,%eax
  8010aa:	c1 e8 16             	shr    $0x16,%eax
  8010ad:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010b4:	a8 01                	test   $0x1,%al
  8010b6:	74 37                	je     8010ef <dup+0x99>
  8010b8:	89 f8                	mov    %edi,%eax
  8010ba:	c1 e8 0c             	shr    $0xc,%eax
  8010bd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010c4:	f6 c2 01             	test   $0x1,%dl
  8010c7:	74 26                	je     8010ef <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010c9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010d0:	83 ec 0c             	sub    $0xc,%esp
  8010d3:	25 07 0e 00 00       	and    $0xe07,%eax
  8010d8:	50                   	push   %eax
  8010d9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010dc:	6a 00                	push   $0x0
  8010de:	57                   	push   %edi
  8010df:	6a 00                	push   $0x0
  8010e1:	e8 67 fb ff ff       	call   800c4d <sys_page_map>
  8010e6:	89 c7                	mov    %eax,%edi
  8010e8:	83 c4 20             	add    $0x20,%esp
  8010eb:	85 c0                	test   %eax,%eax
  8010ed:	78 2e                	js     80111d <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010ef:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010f2:	89 d0                	mov    %edx,%eax
  8010f4:	c1 e8 0c             	shr    $0xc,%eax
  8010f7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010fe:	83 ec 0c             	sub    $0xc,%esp
  801101:	25 07 0e 00 00       	and    $0xe07,%eax
  801106:	50                   	push   %eax
  801107:	53                   	push   %ebx
  801108:	6a 00                	push   $0x0
  80110a:	52                   	push   %edx
  80110b:	6a 00                	push   $0x0
  80110d:	e8 3b fb ff ff       	call   800c4d <sys_page_map>
  801112:	89 c7                	mov    %eax,%edi
  801114:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801117:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801119:	85 ff                	test   %edi,%edi
  80111b:	79 1d                	jns    80113a <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80111d:	83 ec 08             	sub    $0x8,%esp
  801120:	53                   	push   %ebx
  801121:	6a 00                	push   $0x0
  801123:	e8 67 fb ff ff       	call   800c8f <sys_page_unmap>
	sys_page_unmap(0, nva);
  801128:	83 c4 08             	add    $0x8,%esp
  80112b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80112e:	6a 00                	push   $0x0
  801130:	e8 5a fb ff ff       	call   800c8f <sys_page_unmap>
	return r;
  801135:	83 c4 10             	add    $0x10,%esp
  801138:	89 f8                	mov    %edi,%eax
}
  80113a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80113d:	5b                   	pop    %ebx
  80113e:	5e                   	pop    %esi
  80113f:	5f                   	pop    %edi
  801140:	5d                   	pop    %ebp
  801141:	c3                   	ret    

00801142 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801142:	55                   	push   %ebp
  801143:	89 e5                	mov    %esp,%ebp
  801145:	53                   	push   %ebx
  801146:	83 ec 14             	sub    $0x14,%esp
  801149:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80114c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80114f:	50                   	push   %eax
  801150:	53                   	push   %ebx
  801151:	e8 86 fd ff ff       	call   800edc <fd_lookup>
  801156:	83 c4 08             	add    $0x8,%esp
  801159:	89 c2                	mov    %eax,%edx
  80115b:	85 c0                	test   %eax,%eax
  80115d:	78 6d                	js     8011cc <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80115f:	83 ec 08             	sub    $0x8,%esp
  801162:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801165:	50                   	push   %eax
  801166:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801169:	ff 30                	pushl  (%eax)
  80116b:	e8 c2 fd ff ff       	call   800f32 <dev_lookup>
  801170:	83 c4 10             	add    $0x10,%esp
  801173:	85 c0                	test   %eax,%eax
  801175:	78 4c                	js     8011c3 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801177:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80117a:	8b 42 08             	mov    0x8(%edx),%eax
  80117d:	83 e0 03             	and    $0x3,%eax
  801180:	83 f8 01             	cmp    $0x1,%eax
  801183:	75 21                	jne    8011a6 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801185:	a1 04 40 80 00       	mov    0x804004,%eax
  80118a:	8b 40 48             	mov    0x48(%eax),%eax
  80118d:	83 ec 04             	sub    $0x4,%esp
  801190:	53                   	push   %ebx
  801191:	50                   	push   %eax
  801192:	68 30 23 80 00       	push   $0x802330
  801197:	e8 67 f0 ff ff       	call   800203 <cprintf>
		return -E_INVAL;
  80119c:	83 c4 10             	add    $0x10,%esp
  80119f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011a4:	eb 26                	jmp    8011cc <read+0x8a>
	}
	if (!dev->dev_read)
  8011a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011a9:	8b 40 08             	mov    0x8(%eax),%eax
  8011ac:	85 c0                	test   %eax,%eax
  8011ae:	74 17                	je     8011c7 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011b0:	83 ec 04             	sub    $0x4,%esp
  8011b3:	ff 75 10             	pushl  0x10(%ebp)
  8011b6:	ff 75 0c             	pushl  0xc(%ebp)
  8011b9:	52                   	push   %edx
  8011ba:	ff d0                	call   *%eax
  8011bc:	89 c2                	mov    %eax,%edx
  8011be:	83 c4 10             	add    $0x10,%esp
  8011c1:	eb 09                	jmp    8011cc <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011c3:	89 c2                	mov    %eax,%edx
  8011c5:	eb 05                	jmp    8011cc <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011c7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8011cc:	89 d0                	mov    %edx,%eax
  8011ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011d1:	c9                   	leave  
  8011d2:	c3                   	ret    

008011d3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011d3:	55                   	push   %ebp
  8011d4:	89 e5                	mov    %esp,%ebp
  8011d6:	57                   	push   %edi
  8011d7:	56                   	push   %esi
  8011d8:	53                   	push   %ebx
  8011d9:	83 ec 0c             	sub    $0xc,%esp
  8011dc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011df:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011e2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011e7:	eb 21                	jmp    80120a <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011e9:	83 ec 04             	sub    $0x4,%esp
  8011ec:	89 f0                	mov    %esi,%eax
  8011ee:	29 d8                	sub    %ebx,%eax
  8011f0:	50                   	push   %eax
  8011f1:	89 d8                	mov    %ebx,%eax
  8011f3:	03 45 0c             	add    0xc(%ebp),%eax
  8011f6:	50                   	push   %eax
  8011f7:	57                   	push   %edi
  8011f8:	e8 45 ff ff ff       	call   801142 <read>
		if (m < 0)
  8011fd:	83 c4 10             	add    $0x10,%esp
  801200:	85 c0                	test   %eax,%eax
  801202:	78 10                	js     801214 <readn+0x41>
			return m;
		if (m == 0)
  801204:	85 c0                	test   %eax,%eax
  801206:	74 0a                	je     801212 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801208:	01 c3                	add    %eax,%ebx
  80120a:	39 f3                	cmp    %esi,%ebx
  80120c:	72 db                	jb     8011e9 <readn+0x16>
  80120e:	89 d8                	mov    %ebx,%eax
  801210:	eb 02                	jmp    801214 <readn+0x41>
  801212:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801214:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801217:	5b                   	pop    %ebx
  801218:	5e                   	pop    %esi
  801219:	5f                   	pop    %edi
  80121a:	5d                   	pop    %ebp
  80121b:	c3                   	ret    

0080121c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80121c:	55                   	push   %ebp
  80121d:	89 e5                	mov    %esp,%ebp
  80121f:	53                   	push   %ebx
  801220:	83 ec 14             	sub    $0x14,%esp
  801223:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801226:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801229:	50                   	push   %eax
  80122a:	53                   	push   %ebx
  80122b:	e8 ac fc ff ff       	call   800edc <fd_lookup>
  801230:	83 c4 08             	add    $0x8,%esp
  801233:	89 c2                	mov    %eax,%edx
  801235:	85 c0                	test   %eax,%eax
  801237:	78 68                	js     8012a1 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801239:	83 ec 08             	sub    $0x8,%esp
  80123c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80123f:	50                   	push   %eax
  801240:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801243:	ff 30                	pushl  (%eax)
  801245:	e8 e8 fc ff ff       	call   800f32 <dev_lookup>
  80124a:	83 c4 10             	add    $0x10,%esp
  80124d:	85 c0                	test   %eax,%eax
  80124f:	78 47                	js     801298 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801251:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801254:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801258:	75 21                	jne    80127b <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80125a:	a1 04 40 80 00       	mov    0x804004,%eax
  80125f:	8b 40 48             	mov    0x48(%eax),%eax
  801262:	83 ec 04             	sub    $0x4,%esp
  801265:	53                   	push   %ebx
  801266:	50                   	push   %eax
  801267:	68 4c 23 80 00       	push   $0x80234c
  80126c:	e8 92 ef ff ff       	call   800203 <cprintf>
		return -E_INVAL;
  801271:	83 c4 10             	add    $0x10,%esp
  801274:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801279:	eb 26                	jmp    8012a1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80127b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80127e:	8b 52 0c             	mov    0xc(%edx),%edx
  801281:	85 d2                	test   %edx,%edx
  801283:	74 17                	je     80129c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801285:	83 ec 04             	sub    $0x4,%esp
  801288:	ff 75 10             	pushl  0x10(%ebp)
  80128b:	ff 75 0c             	pushl  0xc(%ebp)
  80128e:	50                   	push   %eax
  80128f:	ff d2                	call   *%edx
  801291:	89 c2                	mov    %eax,%edx
  801293:	83 c4 10             	add    $0x10,%esp
  801296:	eb 09                	jmp    8012a1 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801298:	89 c2                	mov    %eax,%edx
  80129a:	eb 05                	jmp    8012a1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80129c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8012a1:	89 d0                	mov    %edx,%eax
  8012a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a6:	c9                   	leave  
  8012a7:	c3                   	ret    

008012a8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012a8:	55                   	push   %ebp
  8012a9:	89 e5                	mov    %esp,%ebp
  8012ab:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012ae:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012b1:	50                   	push   %eax
  8012b2:	ff 75 08             	pushl  0x8(%ebp)
  8012b5:	e8 22 fc ff ff       	call   800edc <fd_lookup>
  8012ba:	83 c4 08             	add    $0x8,%esp
  8012bd:	85 c0                	test   %eax,%eax
  8012bf:	78 0e                	js     8012cf <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012c7:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012cf:	c9                   	leave  
  8012d0:	c3                   	ret    

008012d1 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012d1:	55                   	push   %ebp
  8012d2:	89 e5                	mov    %esp,%ebp
  8012d4:	53                   	push   %ebx
  8012d5:	83 ec 14             	sub    $0x14,%esp
  8012d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012db:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012de:	50                   	push   %eax
  8012df:	53                   	push   %ebx
  8012e0:	e8 f7 fb ff ff       	call   800edc <fd_lookup>
  8012e5:	83 c4 08             	add    $0x8,%esp
  8012e8:	89 c2                	mov    %eax,%edx
  8012ea:	85 c0                	test   %eax,%eax
  8012ec:	78 65                	js     801353 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ee:	83 ec 08             	sub    $0x8,%esp
  8012f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f4:	50                   	push   %eax
  8012f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f8:	ff 30                	pushl  (%eax)
  8012fa:	e8 33 fc ff ff       	call   800f32 <dev_lookup>
  8012ff:	83 c4 10             	add    $0x10,%esp
  801302:	85 c0                	test   %eax,%eax
  801304:	78 44                	js     80134a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801306:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801309:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80130d:	75 21                	jne    801330 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80130f:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801314:	8b 40 48             	mov    0x48(%eax),%eax
  801317:	83 ec 04             	sub    $0x4,%esp
  80131a:	53                   	push   %ebx
  80131b:	50                   	push   %eax
  80131c:	68 0c 23 80 00       	push   $0x80230c
  801321:	e8 dd ee ff ff       	call   800203 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801326:	83 c4 10             	add    $0x10,%esp
  801329:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80132e:	eb 23                	jmp    801353 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801330:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801333:	8b 52 18             	mov    0x18(%edx),%edx
  801336:	85 d2                	test   %edx,%edx
  801338:	74 14                	je     80134e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80133a:	83 ec 08             	sub    $0x8,%esp
  80133d:	ff 75 0c             	pushl  0xc(%ebp)
  801340:	50                   	push   %eax
  801341:	ff d2                	call   *%edx
  801343:	89 c2                	mov    %eax,%edx
  801345:	83 c4 10             	add    $0x10,%esp
  801348:	eb 09                	jmp    801353 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80134a:	89 c2                	mov    %eax,%edx
  80134c:	eb 05                	jmp    801353 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80134e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801353:	89 d0                	mov    %edx,%eax
  801355:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801358:	c9                   	leave  
  801359:	c3                   	ret    

0080135a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80135a:	55                   	push   %ebp
  80135b:	89 e5                	mov    %esp,%ebp
  80135d:	53                   	push   %ebx
  80135e:	83 ec 14             	sub    $0x14,%esp
  801361:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801364:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801367:	50                   	push   %eax
  801368:	ff 75 08             	pushl  0x8(%ebp)
  80136b:	e8 6c fb ff ff       	call   800edc <fd_lookup>
  801370:	83 c4 08             	add    $0x8,%esp
  801373:	89 c2                	mov    %eax,%edx
  801375:	85 c0                	test   %eax,%eax
  801377:	78 58                	js     8013d1 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801379:	83 ec 08             	sub    $0x8,%esp
  80137c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80137f:	50                   	push   %eax
  801380:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801383:	ff 30                	pushl  (%eax)
  801385:	e8 a8 fb ff ff       	call   800f32 <dev_lookup>
  80138a:	83 c4 10             	add    $0x10,%esp
  80138d:	85 c0                	test   %eax,%eax
  80138f:	78 37                	js     8013c8 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801391:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801394:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801398:	74 32                	je     8013cc <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80139a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80139d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013a4:	00 00 00 
	stat->st_isdir = 0;
  8013a7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013ae:	00 00 00 
	stat->st_dev = dev;
  8013b1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013b7:	83 ec 08             	sub    $0x8,%esp
  8013ba:	53                   	push   %ebx
  8013bb:	ff 75 f0             	pushl  -0x10(%ebp)
  8013be:	ff 50 14             	call   *0x14(%eax)
  8013c1:	89 c2                	mov    %eax,%edx
  8013c3:	83 c4 10             	add    $0x10,%esp
  8013c6:	eb 09                	jmp    8013d1 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013c8:	89 c2                	mov    %eax,%edx
  8013ca:	eb 05                	jmp    8013d1 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013cc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013d1:	89 d0                	mov    %edx,%eax
  8013d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013d6:	c9                   	leave  
  8013d7:	c3                   	ret    

008013d8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013d8:	55                   	push   %ebp
  8013d9:	89 e5                	mov    %esp,%ebp
  8013db:	56                   	push   %esi
  8013dc:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013dd:	83 ec 08             	sub    $0x8,%esp
  8013e0:	6a 00                	push   $0x0
  8013e2:	ff 75 08             	pushl  0x8(%ebp)
  8013e5:	e8 e3 01 00 00       	call   8015cd <open>
  8013ea:	89 c3                	mov    %eax,%ebx
  8013ec:	83 c4 10             	add    $0x10,%esp
  8013ef:	85 c0                	test   %eax,%eax
  8013f1:	78 1b                	js     80140e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013f3:	83 ec 08             	sub    $0x8,%esp
  8013f6:	ff 75 0c             	pushl  0xc(%ebp)
  8013f9:	50                   	push   %eax
  8013fa:	e8 5b ff ff ff       	call   80135a <fstat>
  8013ff:	89 c6                	mov    %eax,%esi
	close(fd);
  801401:	89 1c 24             	mov    %ebx,(%esp)
  801404:	e8 fd fb ff ff       	call   801006 <close>
	return r;
  801409:	83 c4 10             	add    $0x10,%esp
  80140c:	89 f0                	mov    %esi,%eax
}
  80140e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801411:	5b                   	pop    %ebx
  801412:	5e                   	pop    %esi
  801413:	5d                   	pop    %ebp
  801414:	c3                   	ret    

00801415 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801415:	55                   	push   %ebp
  801416:	89 e5                	mov    %esp,%ebp
  801418:	56                   	push   %esi
  801419:	53                   	push   %ebx
  80141a:	89 c6                	mov    %eax,%esi
  80141c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80141e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801425:	75 12                	jne    801439 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801427:	83 ec 0c             	sub    $0xc,%esp
  80142a:	6a 01                	push   $0x1
  80142c:	e8 e5 07 00 00       	call   801c16 <ipc_find_env>
  801431:	a3 00 40 80 00       	mov    %eax,0x804000
  801436:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801439:	6a 07                	push   $0x7
  80143b:	68 00 50 80 00       	push   $0x805000
  801440:	56                   	push   %esi
  801441:	ff 35 00 40 80 00    	pushl  0x804000
  801447:	e8 76 07 00 00       	call   801bc2 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80144c:	83 c4 0c             	add    $0xc,%esp
  80144f:	6a 00                	push   $0x0
  801451:	53                   	push   %ebx
  801452:	6a 00                	push   $0x0
  801454:	e8 f7 06 00 00       	call   801b50 <ipc_recv>
}
  801459:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80145c:	5b                   	pop    %ebx
  80145d:	5e                   	pop    %esi
  80145e:	5d                   	pop    %ebp
  80145f:	c3                   	ret    

00801460 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801460:	55                   	push   %ebp
  801461:	89 e5                	mov    %esp,%ebp
  801463:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801466:	8b 45 08             	mov    0x8(%ebp),%eax
  801469:	8b 40 0c             	mov    0xc(%eax),%eax
  80146c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801471:	8b 45 0c             	mov    0xc(%ebp),%eax
  801474:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801479:	ba 00 00 00 00       	mov    $0x0,%edx
  80147e:	b8 02 00 00 00       	mov    $0x2,%eax
  801483:	e8 8d ff ff ff       	call   801415 <fsipc>
}
  801488:	c9                   	leave  
  801489:	c3                   	ret    

0080148a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80148a:	55                   	push   %ebp
  80148b:	89 e5                	mov    %esp,%ebp
  80148d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801490:	8b 45 08             	mov    0x8(%ebp),%eax
  801493:	8b 40 0c             	mov    0xc(%eax),%eax
  801496:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80149b:	ba 00 00 00 00       	mov    $0x0,%edx
  8014a0:	b8 06 00 00 00       	mov    $0x6,%eax
  8014a5:	e8 6b ff ff ff       	call   801415 <fsipc>
}
  8014aa:	c9                   	leave  
  8014ab:	c3                   	ret    

008014ac <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014ac:	55                   	push   %ebp
  8014ad:	89 e5                	mov    %esp,%ebp
  8014af:	53                   	push   %ebx
  8014b0:	83 ec 04             	sub    $0x4,%esp
  8014b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b9:	8b 40 0c             	mov    0xc(%eax),%eax
  8014bc:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c6:	b8 05 00 00 00       	mov    $0x5,%eax
  8014cb:	e8 45 ff ff ff       	call   801415 <fsipc>
  8014d0:	85 c0                	test   %eax,%eax
  8014d2:	78 2c                	js     801500 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014d4:	83 ec 08             	sub    $0x8,%esp
  8014d7:	68 00 50 80 00       	push   $0x805000
  8014dc:	53                   	push   %ebx
  8014dd:	e8 25 f3 ff ff       	call   800807 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014e2:	a1 80 50 80 00       	mov    0x805080,%eax
  8014e7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014ed:	a1 84 50 80 00       	mov    0x805084,%eax
  8014f2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014f8:	83 c4 10             	add    $0x10,%esp
  8014fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801500:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801503:	c9                   	leave  
  801504:	c3                   	ret    

00801505 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801505:	55                   	push   %ebp
  801506:	89 e5                	mov    %esp,%ebp
  801508:	83 ec 0c             	sub    $0xc,%esp
  80150b:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	
	int r;

	n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  80150e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801513:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801518:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80151b:	8b 55 08             	mov    0x8(%ebp),%edx
  80151e:	8b 52 0c             	mov    0xc(%edx),%edx
  801521:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801527:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80152c:	50                   	push   %eax
  80152d:	ff 75 0c             	pushl  0xc(%ebp)
  801530:	68 08 50 80 00       	push   $0x805008
  801535:	e8 5f f4 ff ff       	call   800999 <memmove>
	
	return fsipc(FSREQ_WRITE, NULL);	
  80153a:	ba 00 00 00 00       	mov    $0x0,%edx
  80153f:	b8 04 00 00 00       	mov    $0x4,%eax
  801544:	e8 cc fe ff ff       	call   801415 <fsipc>
}
  801549:	c9                   	leave  
  80154a:	c3                   	ret    

0080154b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80154b:	55                   	push   %ebp
  80154c:	89 e5                	mov    %esp,%ebp
  80154e:	56                   	push   %esi
  80154f:	53                   	push   %ebx
  801550:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801553:	8b 45 08             	mov    0x8(%ebp),%eax
  801556:	8b 40 0c             	mov    0xc(%eax),%eax
  801559:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80155e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801564:	ba 00 00 00 00       	mov    $0x0,%edx
  801569:	b8 03 00 00 00       	mov    $0x3,%eax
  80156e:	e8 a2 fe ff ff       	call   801415 <fsipc>
  801573:	89 c3                	mov    %eax,%ebx
  801575:	85 c0                	test   %eax,%eax
  801577:	78 4b                	js     8015c4 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801579:	39 c6                	cmp    %eax,%esi
  80157b:	73 16                	jae    801593 <devfile_read+0x48>
  80157d:	68 7c 23 80 00       	push   $0x80237c
  801582:	68 83 23 80 00       	push   $0x802383
  801587:	6a 7c                	push   $0x7c
  801589:	68 98 23 80 00       	push   $0x802398
  80158e:	e8 97 eb ff ff       	call   80012a <_panic>
	assert(r <= PGSIZE);
  801593:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801598:	7e 16                	jle    8015b0 <devfile_read+0x65>
  80159a:	68 a3 23 80 00       	push   $0x8023a3
  80159f:	68 83 23 80 00       	push   $0x802383
  8015a4:	6a 7d                	push   $0x7d
  8015a6:	68 98 23 80 00       	push   $0x802398
  8015ab:	e8 7a eb ff ff       	call   80012a <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015b0:	83 ec 04             	sub    $0x4,%esp
  8015b3:	50                   	push   %eax
  8015b4:	68 00 50 80 00       	push   $0x805000
  8015b9:	ff 75 0c             	pushl  0xc(%ebp)
  8015bc:	e8 d8 f3 ff ff       	call   800999 <memmove>
	return r;
  8015c1:	83 c4 10             	add    $0x10,%esp
}
  8015c4:	89 d8                	mov    %ebx,%eax
  8015c6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015c9:	5b                   	pop    %ebx
  8015ca:	5e                   	pop    %esi
  8015cb:	5d                   	pop    %ebp
  8015cc:	c3                   	ret    

008015cd <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015cd:	55                   	push   %ebp
  8015ce:	89 e5                	mov    %esp,%ebp
  8015d0:	53                   	push   %ebx
  8015d1:	83 ec 20             	sub    $0x20,%esp
  8015d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015d7:	53                   	push   %ebx
  8015d8:	e8 f1 f1 ff ff       	call   8007ce <strlen>
  8015dd:	83 c4 10             	add    $0x10,%esp
  8015e0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015e5:	7f 67                	jg     80164e <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015e7:	83 ec 0c             	sub    $0xc,%esp
  8015ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ed:	50                   	push   %eax
  8015ee:	e8 9a f8 ff ff       	call   800e8d <fd_alloc>
  8015f3:	83 c4 10             	add    $0x10,%esp
		return r;
  8015f6:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015f8:	85 c0                	test   %eax,%eax
  8015fa:	78 57                	js     801653 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015fc:	83 ec 08             	sub    $0x8,%esp
  8015ff:	53                   	push   %ebx
  801600:	68 00 50 80 00       	push   $0x805000
  801605:	e8 fd f1 ff ff       	call   800807 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80160a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80160d:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801612:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801615:	b8 01 00 00 00       	mov    $0x1,%eax
  80161a:	e8 f6 fd ff ff       	call   801415 <fsipc>
  80161f:	89 c3                	mov    %eax,%ebx
  801621:	83 c4 10             	add    $0x10,%esp
  801624:	85 c0                	test   %eax,%eax
  801626:	79 14                	jns    80163c <open+0x6f>
		fd_close(fd, 0);
  801628:	83 ec 08             	sub    $0x8,%esp
  80162b:	6a 00                	push   $0x0
  80162d:	ff 75 f4             	pushl  -0xc(%ebp)
  801630:	e8 50 f9 ff ff       	call   800f85 <fd_close>
		return r;
  801635:	83 c4 10             	add    $0x10,%esp
  801638:	89 da                	mov    %ebx,%edx
  80163a:	eb 17                	jmp    801653 <open+0x86>
	}

	return fd2num(fd);
  80163c:	83 ec 0c             	sub    $0xc,%esp
  80163f:	ff 75 f4             	pushl  -0xc(%ebp)
  801642:	e8 1f f8 ff ff       	call   800e66 <fd2num>
  801647:	89 c2                	mov    %eax,%edx
  801649:	83 c4 10             	add    $0x10,%esp
  80164c:	eb 05                	jmp    801653 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80164e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801653:	89 d0                	mov    %edx,%eax
  801655:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801658:	c9                   	leave  
  801659:	c3                   	ret    

0080165a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80165a:	55                   	push   %ebp
  80165b:	89 e5                	mov    %esp,%ebp
  80165d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801660:	ba 00 00 00 00       	mov    $0x0,%edx
  801665:	b8 08 00 00 00       	mov    $0x8,%eax
  80166a:	e8 a6 fd ff ff       	call   801415 <fsipc>
}
  80166f:	c9                   	leave  
  801670:	c3                   	ret    

00801671 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801671:	55                   	push   %ebp
  801672:	89 e5                	mov    %esp,%ebp
  801674:	56                   	push   %esi
  801675:	53                   	push   %ebx
  801676:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801679:	83 ec 0c             	sub    $0xc,%esp
  80167c:	ff 75 08             	pushl  0x8(%ebp)
  80167f:	e8 f2 f7 ff ff       	call   800e76 <fd2data>
  801684:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801686:	83 c4 08             	add    $0x8,%esp
  801689:	68 af 23 80 00       	push   $0x8023af
  80168e:	53                   	push   %ebx
  80168f:	e8 73 f1 ff ff       	call   800807 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801694:	8b 46 04             	mov    0x4(%esi),%eax
  801697:	2b 06                	sub    (%esi),%eax
  801699:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80169f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016a6:	00 00 00 
	stat->st_dev = &devpipe;
  8016a9:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8016b0:	30 80 00 
	return 0;
}
  8016b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8016b8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016bb:	5b                   	pop    %ebx
  8016bc:	5e                   	pop    %esi
  8016bd:	5d                   	pop    %ebp
  8016be:	c3                   	ret    

008016bf <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8016bf:	55                   	push   %ebp
  8016c0:	89 e5                	mov    %esp,%ebp
  8016c2:	53                   	push   %ebx
  8016c3:	83 ec 0c             	sub    $0xc,%esp
  8016c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8016c9:	53                   	push   %ebx
  8016ca:	6a 00                	push   $0x0
  8016cc:	e8 be f5 ff ff       	call   800c8f <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8016d1:	89 1c 24             	mov    %ebx,(%esp)
  8016d4:	e8 9d f7 ff ff       	call   800e76 <fd2data>
  8016d9:	83 c4 08             	add    $0x8,%esp
  8016dc:	50                   	push   %eax
  8016dd:	6a 00                	push   $0x0
  8016df:	e8 ab f5 ff ff       	call   800c8f <sys_page_unmap>
}
  8016e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e7:	c9                   	leave  
  8016e8:	c3                   	ret    

008016e9 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8016e9:	55                   	push   %ebp
  8016ea:	89 e5                	mov    %esp,%ebp
  8016ec:	57                   	push   %edi
  8016ed:	56                   	push   %esi
  8016ee:	53                   	push   %ebx
  8016ef:	83 ec 1c             	sub    $0x1c,%esp
  8016f2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016f5:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8016f7:	a1 04 40 80 00       	mov    0x804004,%eax
  8016fc:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8016ff:	83 ec 0c             	sub    $0xc,%esp
  801702:	ff 75 e0             	pushl  -0x20(%ebp)
  801705:	e8 45 05 00 00       	call   801c4f <pageref>
  80170a:	89 c3                	mov    %eax,%ebx
  80170c:	89 3c 24             	mov    %edi,(%esp)
  80170f:	e8 3b 05 00 00       	call   801c4f <pageref>
  801714:	83 c4 10             	add    $0x10,%esp
  801717:	39 c3                	cmp    %eax,%ebx
  801719:	0f 94 c1             	sete   %cl
  80171c:	0f b6 c9             	movzbl %cl,%ecx
  80171f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801722:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801728:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80172b:	39 ce                	cmp    %ecx,%esi
  80172d:	74 1b                	je     80174a <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80172f:	39 c3                	cmp    %eax,%ebx
  801731:	75 c4                	jne    8016f7 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801733:	8b 42 58             	mov    0x58(%edx),%eax
  801736:	ff 75 e4             	pushl  -0x1c(%ebp)
  801739:	50                   	push   %eax
  80173a:	56                   	push   %esi
  80173b:	68 b6 23 80 00       	push   $0x8023b6
  801740:	e8 be ea ff ff       	call   800203 <cprintf>
  801745:	83 c4 10             	add    $0x10,%esp
  801748:	eb ad                	jmp    8016f7 <_pipeisclosed+0xe>
	}
}
  80174a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80174d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801750:	5b                   	pop    %ebx
  801751:	5e                   	pop    %esi
  801752:	5f                   	pop    %edi
  801753:	5d                   	pop    %ebp
  801754:	c3                   	ret    

00801755 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801755:	55                   	push   %ebp
  801756:	89 e5                	mov    %esp,%ebp
  801758:	57                   	push   %edi
  801759:	56                   	push   %esi
  80175a:	53                   	push   %ebx
  80175b:	83 ec 28             	sub    $0x28,%esp
  80175e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801761:	56                   	push   %esi
  801762:	e8 0f f7 ff ff       	call   800e76 <fd2data>
  801767:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801769:	83 c4 10             	add    $0x10,%esp
  80176c:	bf 00 00 00 00       	mov    $0x0,%edi
  801771:	eb 4b                	jmp    8017be <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801773:	89 da                	mov    %ebx,%edx
  801775:	89 f0                	mov    %esi,%eax
  801777:	e8 6d ff ff ff       	call   8016e9 <_pipeisclosed>
  80177c:	85 c0                	test   %eax,%eax
  80177e:	75 48                	jne    8017c8 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801780:	e8 66 f4 ff ff       	call   800beb <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801785:	8b 43 04             	mov    0x4(%ebx),%eax
  801788:	8b 0b                	mov    (%ebx),%ecx
  80178a:	8d 51 20             	lea    0x20(%ecx),%edx
  80178d:	39 d0                	cmp    %edx,%eax
  80178f:	73 e2                	jae    801773 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801791:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801794:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801798:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80179b:	89 c2                	mov    %eax,%edx
  80179d:	c1 fa 1f             	sar    $0x1f,%edx
  8017a0:	89 d1                	mov    %edx,%ecx
  8017a2:	c1 e9 1b             	shr    $0x1b,%ecx
  8017a5:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8017a8:	83 e2 1f             	and    $0x1f,%edx
  8017ab:	29 ca                	sub    %ecx,%edx
  8017ad:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8017b1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8017b5:	83 c0 01             	add    $0x1,%eax
  8017b8:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017bb:	83 c7 01             	add    $0x1,%edi
  8017be:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8017c1:	75 c2                	jne    801785 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8017c3:	8b 45 10             	mov    0x10(%ebp),%eax
  8017c6:	eb 05                	jmp    8017cd <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017c8:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8017cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017d0:	5b                   	pop    %ebx
  8017d1:	5e                   	pop    %esi
  8017d2:	5f                   	pop    %edi
  8017d3:	5d                   	pop    %ebp
  8017d4:	c3                   	ret    

008017d5 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8017d5:	55                   	push   %ebp
  8017d6:	89 e5                	mov    %esp,%ebp
  8017d8:	57                   	push   %edi
  8017d9:	56                   	push   %esi
  8017da:	53                   	push   %ebx
  8017db:	83 ec 18             	sub    $0x18,%esp
  8017de:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8017e1:	57                   	push   %edi
  8017e2:	e8 8f f6 ff ff       	call   800e76 <fd2data>
  8017e7:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017e9:	83 c4 10             	add    $0x10,%esp
  8017ec:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017f1:	eb 3d                	jmp    801830 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8017f3:	85 db                	test   %ebx,%ebx
  8017f5:	74 04                	je     8017fb <devpipe_read+0x26>
				return i;
  8017f7:	89 d8                	mov    %ebx,%eax
  8017f9:	eb 44                	jmp    80183f <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8017fb:	89 f2                	mov    %esi,%edx
  8017fd:	89 f8                	mov    %edi,%eax
  8017ff:	e8 e5 fe ff ff       	call   8016e9 <_pipeisclosed>
  801804:	85 c0                	test   %eax,%eax
  801806:	75 32                	jne    80183a <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801808:	e8 de f3 ff ff       	call   800beb <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80180d:	8b 06                	mov    (%esi),%eax
  80180f:	3b 46 04             	cmp    0x4(%esi),%eax
  801812:	74 df                	je     8017f3 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801814:	99                   	cltd   
  801815:	c1 ea 1b             	shr    $0x1b,%edx
  801818:	01 d0                	add    %edx,%eax
  80181a:	83 e0 1f             	and    $0x1f,%eax
  80181d:	29 d0                	sub    %edx,%eax
  80181f:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801824:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801827:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80182a:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80182d:	83 c3 01             	add    $0x1,%ebx
  801830:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801833:	75 d8                	jne    80180d <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801835:	8b 45 10             	mov    0x10(%ebp),%eax
  801838:	eb 05                	jmp    80183f <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80183a:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80183f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801842:	5b                   	pop    %ebx
  801843:	5e                   	pop    %esi
  801844:	5f                   	pop    %edi
  801845:	5d                   	pop    %ebp
  801846:	c3                   	ret    

00801847 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801847:	55                   	push   %ebp
  801848:	89 e5                	mov    %esp,%ebp
  80184a:	56                   	push   %esi
  80184b:	53                   	push   %ebx
  80184c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80184f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801852:	50                   	push   %eax
  801853:	e8 35 f6 ff ff       	call   800e8d <fd_alloc>
  801858:	83 c4 10             	add    $0x10,%esp
  80185b:	89 c2                	mov    %eax,%edx
  80185d:	85 c0                	test   %eax,%eax
  80185f:	0f 88 2c 01 00 00    	js     801991 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801865:	83 ec 04             	sub    $0x4,%esp
  801868:	68 07 04 00 00       	push   $0x407
  80186d:	ff 75 f4             	pushl  -0xc(%ebp)
  801870:	6a 00                	push   $0x0
  801872:	e8 93 f3 ff ff       	call   800c0a <sys_page_alloc>
  801877:	83 c4 10             	add    $0x10,%esp
  80187a:	89 c2                	mov    %eax,%edx
  80187c:	85 c0                	test   %eax,%eax
  80187e:	0f 88 0d 01 00 00    	js     801991 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801884:	83 ec 0c             	sub    $0xc,%esp
  801887:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80188a:	50                   	push   %eax
  80188b:	e8 fd f5 ff ff       	call   800e8d <fd_alloc>
  801890:	89 c3                	mov    %eax,%ebx
  801892:	83 c4 10             	add    $0x10,%esp
  801895:	85 c0                	test   %eax,%eax
  801897:	0f 88 e2 00 00 00    	js     80197f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80189d:	83 ec 04             	sub    $0x4,%esp
  8018a0:	68 07 04 00 00       	push   $0x407
  8018a5:	ff 75 f0             	pushl  -0x10(%ebp)
  8018a8:	6a 00                	push   $0x0
  8018aa:	e8 5b f3 ff ff       	call   800c0a <sys_page_alloc>
  8018af:	89 c3                	mov    %eax,%ebx
  8018b1:	83 c4 10             	add    $0x10,%esp
  8018b4:	85 c0                	test   %eax,%eax
  8018b6:	0f 88 c3 00 00 00    	js     80197f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8018bc:	83 ec 0c             	sub    $0xc,%esp
  8018bf:	ff 75 f4             	pushl  -0xc(%ebp)
  8018c2:	e8 af f5 ff ff       	call   800e76 <fd2data>
  8018c7:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018c9:	83 c4 0c             	add    $0xc,%esp
  8018cc:	68 07 04 00 00       	push   $0x407
  8018d1:	50                   	push   %eax
  8018d2:	6a 00                	push   $0x0
  8018d4:	e8 31 f3 ff ff       	call   800c0a <sys_page_alloc>
  8018d9:	89 c3                	mov    %eax,%ebx
  8018db:	83 c4 10             	add    $0x10,%esp
  8018de:	85 c0                	test   %eax,%eax
  8018e0:	0f 88 89 00 00 00    	js     80196f <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018e6:	83 ec 0c             	sub    $0xc,%esp
  8018e9:	ff 75 f0             	pushl  -0x10(%ebp)
  8018ec:	e8 85 f5 ff ff       	call   800e76 <fd2data>
  8018f1:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8018f8:	50                   	push   %eax
  8018f9:	6a 00                	push   $0x0
  8018fb:	56                   	push   %esi
  8018fc:	6a 00                	push   $0x0
  8018fe:	e8 4a f3 ff ff       	call   800c4d <sys_page_map>
  801903:	89 c3                	mov    %eax,%ebx
  801905:	83 c4 20             	add    $0x20,%esp
  801908:	85 c0                	test   %eax,%eax
  80190a:	78 55                	js     801961 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80190c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801912:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801915:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801917:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80191a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801921:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801927:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80192a:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80192c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80192f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801936:	83 ec 0c             	sub    $0xc,%esp
  801939:	ff 75 f4             	pushl  -0xc(%ebp)
  80193c:	e8 25 f5 ff ff       	call   800e66 <fd2num>
  801941:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801944:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801946:	83 c4 04             	add    $0x4,%esp
  801949:	ff 75 f0             	pushl  -0x10(%ebp)
  80194c:	e8 15 f5 ff ff       	call   800e66 <fd2num>
  801951:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801954:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801957:	83 c4 10             	add    $0x10,%esp
  80195a:	ba 00 00 00 00       	mov    $0x0,%edx
  80195f:	eb 30                	jmp    801991 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801961:	83 ec 08             	sub    $0x8,%esp
  801964:	56                   	push   %esi
  801965:	6a 00                	push   $0x0
  801967:	e8 23 f3 ff ff       	call   800c8f <sys_page_unmap>
  80196c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80196f:	83 ec 08             	sub    $0x8,%esp
  801972:	ff 75 f0             	pushl  -0x10(%ebp)
  801975:	6a 00                	push   $0x0
  801977:	e8 13 f3 ff ff       	call   800c8f <sys_page_unmap>
  80197c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80197f:	83 ec 08             	sub    $0x8,%esp
  801982:	ff 75 f4             	pushl  -0xc(%ebp)
  801985:	6a 00                	push   $0x0
  801987:	e8 03 f3 ff ff       	call   800c8f <sys_page_unmap>
  80198c:	83 c4 10             	add    $0x10,%esp
  80198f:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801991:	89 d0                	mov    %edx,%eax
  801993:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801996:	5b                   	pop    %ebx
  801997:	5e                   	pop    %esi
  801998:	5d                   	pop    %ebp
  801999:	c3                   	ret    

0080199a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80199a:	55                   	push   %ebp
  80199b:	89 e5                	mov    %esp,%ebp
  80199d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019a3:	50                   	push   %eax
  8019a4:	ff 75 08             	pushl  0x8(%ebp)
  8019a7:	e8 30 f5 ff ff       	call   800edc <fd_lookup>
  8019ac:	83 c4 10             	add    $0x10,%esp
  8019af:	85 c0                	test   %eax,%eax
  8019b1:	78 18                	js     8019cb <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8019b3:	83 ec 0c             	sub    $0xc,%esp
  8019b6:	ff 75 f4             	pushl  -0xc(%ebp)
  8019b9:	e8 b8 f4 ff ff       	call   800e76 <fd2data>
	return _pipeisclosed(fd, p);
  8019be:	89 c2                	mov    %eax,%edx
  8019c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019c3:	e8 21 fd ff ff       	call   8016e9 <_pipeisclosed>
  8019c8:	83 c4 10             	add    $0x10,%esp
}
  8019cb:	c9                   	leave  
  8019cc:	c3                   	ret    

008019cd <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8019cd:	55                   	push   %ebp
  8019ce:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8019d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8019d5:	5d                   	pop    %ebp
  8019d6:	c3                   	ret    

008019d7 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8019d7:	55                   	push   %ebp
  8019d8:	89 e5                	mov    %esp,%ebp
  8019da:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8019dd:	68 ce 23 80 00       	push   $0x8023ce
  8019e2:	ff 75 0c             	pushl  0xc(%ebp)
  8019e5:	e8 1d ee ff ff       	call   800807 <strcpy>
	return 0;
}
  8019ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8019ef:	c9                   	leave  
  8019f0:	c3                   	ret    

008019f1 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019f1:	55                   	push   %ebp
  8019f2:	89 e5                	mov    %esp,%ebp
  8019f4:	57                   	push   %edi
  8019f5:	56                   	push   %esi
  8019f6:	53                   	push   %ebx
  8019f7:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019fd:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a02:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a08:	eb 2d                	jmp    801a37 <devcons_write+0x46>
		m = n - tot;
  801a0a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a0d:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801a0f:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801a12:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801a17:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a1a:	83 ec 04             	sub    $0x4,%esp
  801a1d:	53                   	push   %ebx
  801a1e:	03 45 0c             	add    0xc(%ebp),%eax
  801a21:	50                   	push   %eax
  801a22:	57                   	push   %edi
  801a23:	e8 71 ef ff ff       	call   800999 <memmove>
		sys_cputs(buf, m);
  801a28:	83 c4 08             	add    $0x8,%esp
  801a2b:	53                   	push   %ebx
  801a2c:	57                   	push   %edi
  801a2d:	e8 1c f1 ff ff       	call   800b4e <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a32:	01 de                	add    %ebx,%esi
  801a34:	83 c4 10             	add    $0x10,%esp
  801a37:	89 f0                	mov    %esi,%eax
  801a39:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a3c:	72 cc                	jb     801a0a <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a41:	5b                   	pop    %ebx
  801a42:	5e                   	pop    %esi
  801a43:	5f                   	pop    %edi
  801a44:	5d                   	pop    %ebp
  801a45:	c3                   	ret    

00801a46 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a46:	55                   	push   %ebp
  801a47:	89 e5                	mov    %esp,%ebp
  801a49:	83 ec 08             	sub    $0x8,%esp
  801a4c:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801a51:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a55:	74 2a                	je     801a81 <devcons_read+0x3b>
  801a57:	eb 05                	jmp    801a5e <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a59:	e8 8d f1 ff ff       	call   800beb <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a5e:	e8 09 f1 ff ff       	call   800b6c <sys_cgetc>
  801a63:	85 c0                	test   %eax,%eax
  801a65:	74 f2                	je     801a59 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801a67:	85 c0                	test   %eax,%eax
  801a69:	78 16                	js     801a81 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a6b:	83 f8 04             	cmp    $0x4,%eax
  801a6e:	74 0c                	je     801a7c <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801a70:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a73:	88 02                	mov    %al,(%edx)
	return 1;
  801a75:	b8 01 00 00 00       	mov    $0x1,%eax
  801a7a:	eb 05                	jmp    801a81 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a7c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a81:	c9                   	leave  
  801a82:	c3                   	ret    

00801a83 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a83:	55                   	push   %ebp
  801a84:	89 e5                	mov    %esp,%ebp
  801a86:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a89:	8b 45 08             	mov    0x8(%ebp),%eax
  801a8c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a8f:	6a 01                	push   $0x1
  801a91:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a94:	50                   	push   %eax
  801a95:	e8 b4 f0 ff ff       	call   800b4e <sys_cputs>
}
  801a9a:	83 c4 10             	add    $0x10,%esp
  801a9d:	c9                   	leave  
  801a9e:	c3                   	ret    

00801a9f <getchar>:

int
getchar(void)
{
  801a9f:	55                   	push   %ebp
  801aa0:	89 e5                	mov    %esp,%ebp
  801aa2:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801aa5:	6a 01                	push   $0x1
  801aa7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801aaa:	50                   	push   %eax
  801aab:	6a 00                	push   $0x0
  801aad:	e8 90 f6 ff ff       	call   801142 <read>
	if (r < 0)
  801ab2:	83 c4 10             	add    $0x10,%esp
  801ab5:	85 c0                	test   %eax,%eax
  801ab7:	78 0f                	js     801ac8 <getchar+0x29>
		return r;
	if (r < 1)
  801ab9:	85 c0                	test   %eax,%eax
  801abb:	7e 06                	jle    801ac3 <getchar+0x24>
		return -E_EOF;
	return c;
  801abd:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ac1:	eb 05                	jmp    801ac8 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ac3:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ac8:	c9                   	leave  
  801ac9:	c3                   	ret    

00801aca <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801aca:	55                   	push   %ebp
  801acb:	89 e5                	mov    %esp,%ebp
  801acd:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ad0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ad3:	50                   	push   %eax
  801ad4:	ff 75 08             	pushl  0x8(%ebp)
  801ad7:	e8 00 f4 ff ff       	call   800edc <fd_lookup>
  801adc:	83 c4 10             	add    $0x10,%esp
  801adf:	85 c0                	test   %eax,%eax
  801ae1:	78 11                	js     801af4 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ae6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801aec:	39 10                	cmp    %edx,(%eax)
  801aee:	0f 94 c0             	sete   %al
  801af1:	0f b6 c0             	movzbl %al,%eax
}
  801af4:	c9                   	leave  
  801af5:	c3                   	ret    

00801af6 <opencons>:

int
opencons(void)
{
  801af6:	55                   	push   %ebp
  801af7:	89 e5                	mov    %esp,%ebp
  801af9:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801afc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aff:	50                   	push   %eax
  801b00:	e8 88 f3 ff ff       	call   800e8d <fd_alloc>
  801b05:	83 c4 10             	add    $0x10,%esp
		return r;
  801b08:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b0a:	85 c0                	test   %eax,%eax
  801b0c:	78 3e                	js     801b4c <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b0e:	83 ec 04             	sub    $0x4,%esp
  801b11:	68 07 04 00 00       	push   $0x407
  801b16:	ff 75 f4             	pushl  -0xc(%ebp)
  801b19:	6a 00                	push   $0x0
  801b1b:	e8 ea f0 ff ff       	call   800c0a <sys_page_alloc>
  801b20:	83 c4 10             	add    $0x10,%esp
		return r;
  801b23:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b25:	85 c0                	test   %eax,%eax
  801b27:	78 23                	js     801b4c <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801b29:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b32:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b37:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b3e:	83 ec 0c             	sub    $0xc,%esp
  801b41:	50                   	push   %eax
  801b42:	e8 1f f3 ff ff       	call   800e66 <fd2num>
  801b47:	89 c2                	mov    %eax,%edx
  801b49:	83 c4 10             	add    $0x10,%esp
}
  801b4c:	89 d0                	mov    %edx,%eax
  801b4e:	c9                   	leave  
  801b4f:	c3                   	ret    

00801b50 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b50:	55                   	push   %ebp
  801b51:	89 e5                	mov    %esp,%ebp
  801b53:	56                   	push   %esi
  801b54:	53                   	push   %ebx
  801b55:	8b 75 08             	mov    0x8(%ebp),%esi
  801b58:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b5b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

    if (pg != NULL)
  801b5e:	85 c0                	test   %eax,%eax
  801b60:	74 0e                	je     801b70 <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  801b62:	83 ec 0c             	sub    $0xc,%esp
  801b65:	50                   	push   %eax
  801b66:	e8 4f f2 ff ff       	call   800dba <sys_ipc_recv>
  801b6b:	83 c4 10             	add    $0x10,%esp
  801b6e:	eb 0d                	jmp    801b7d <ipc_recv+0x2d>
	else
        r = sys_ipc_recv((void *)-1);
  801b70:	83 ec 0c             	sub    $0xc,%esp
  801b73:	6a ff                	push   $0xffffffff
  801b75:	e8 40 f2 ff ff       	call   800dba <sys_ipc_recv>
  801b7a:	83 c4 10             	add    $0x10,%esp

	if (r < 0) {
  801b7d:	85 c0                	test   %eax,%eax
  801b7f:	79 16                	jns    801b97 <ipc_recv+0x47>

		if (from_env_store != NULL)
  801b81:	85 f6                	test   %esi,%esi
  801b83:	74 06                	je     801b8b <ipc_recv+0x3b>
			*from_env_store = 0;
  801b85:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL)
  801b8b:	85 db                	test   %ebx,%ebx
  801b8d:	74 2c                	je     801bbb <ipc_recv+0x6b>
			*perm_store = 0;
  801b8f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b95:	eb 24                	jmp    801bbb <ipc_recv+0x6b>
		return r;

	} else {

		if (from_env_store != NULL)
  801b97:	85 f6                	test   %esi,%esi
  801b99:	74 0a                	je     801ba5 <ipc_recv+0x55>
			*from_env_store = thisenv->env_ipc_from;
  801b9b:	a1 04 40 80 00       	mov    0x804004,%eax
  801ba0:	8b 40 74             	mov    0x74(%eax),%eax
  801ba3:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL)
  801ba5:	85 db                	test   %ebx,%ebx
  801ba7:	74 0a                	je     801bb3 <ipc_recv+0x63>
			*perm_store = thisenv->env_ipc_perm;
  801ba9:	a1 04 40 80 00       	mov    0x804004,%eax
  801bae:	8b 40 78             	mov    0x78(%eax),%eax
  801bb1:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801bb3:	a1 04 40 80 00       	mov    0x804004,%eax
  801bb8:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801bbb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bbe:	5b                   	pop    %ebx
  801bbf:	5e                   	pop    %esi
  801bc0:	5d                   	pop    %ebp
  801bc1:	c3                   	ret    

00801bc2 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bc2:	55                   	push   %ebp
  801bc3:	89 e5                	mov    %esp,%ebp
  801bc5:	57                   	push   %edi
  801bc6:	56                   	push   %esi
  801bc7:	53                   	push   %ebx
  801bc8:	83 ec 0c             	sub    $0xc,%esp
  801bcb:	8b 7d 08             	mov    0x8(%ebp),%edi
  801bce:	8b 75 0c             	mov    0xc(%ebp),%esi
  801bd1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

	if (pg == NULL)
  801bd4:	85 db                	test   %ebx,%ebx
		pg = (void *)-1;	
  801bd6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801bdb:	0f 44 d8             	cmove  %eax,%ebx

	while (true) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801bde:	ff 75 14             	pushl  0x14(%ebp)
  801be1:	53                   	push   %ebx
  801be2:	56                   	push   %esi
  801be3:	57                   	push   %edi
  801be4:	e8 ae f1 ff ff       	call   800d97 <sys_ipc_try_send>
		if (r >= 0)
  801be9:	83 c4 10             	add    $0x10,%esp
  801bec:	85 c0                	test   %eax,%eax
  801bee:	79 1e                	jns    801c0e <ipc_send+0x4c>
			return;
		else if (r != -E_IPC_NOT_RECV)
  801bf0:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801bf3:	74 12                	je     801c07 <ipc_send+0x45>
			panic("ipc_send error: %e", r);
  801bf5:	50                   	push   %eax
  801bf6:	68 da 23 80 00       	push   $0x8023da
  801bfb:	6a 49                	push   $0x49
  801bfd:	68 ed 23 80 00       	push   $0x8023ed
  801c02:	e8 23 e5 ff ff       	call   80012a <_panic>
	
		sys_yield();
  801c07:	e8 df ef ff ff       	call   800beb <sys_yield>
	}
  801c0c:	eb d0                	jmp    801bde <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  801c0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c11:	5b                   	pop    %ebx
  801c12:	5e                   	pop    %esi
  801c13:	5f                   	pop    %edi
  801c14:	5d                   	pop    %ebp
  801c15:	c3                   	ret    

00801c16 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c16:	55                   	push   %ebp
  801c17:	89 e5                	mov    %esp,%ebp
  801c19:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c1c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c21:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c24:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c2a:	8b 52 50             	mov    0x50(%edx),%edx
  801c2d:	39 ca                	cmp    %ecx,%edx
  801c2f:	75 0d                	jne    801c3e <ipc_find_env+0x28>
			return envs[i].env_id;
  801c31:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c34:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c39:	8b 40 48             	mov    0x48(%eax),%eax
  801c3c:	eb 0f                	jmp    801c4d <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c3e:	83 c0 01             	add    $0x1,%eax
  801c41:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c46:	75 d9                	jne    801c21 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c48:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c4d:	5d                   	pop    %ebp
  801c4e:	c3                   	ret    

00801c4f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c4f:	55                   	push   %ebp
  801c50:	89 e5                	mov    %esp,%ebp
  801c52:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c55:	89 d0                	mov    %edx,%eax
  801c57:	c1 e8 16             	shr    $0x16,%eax
  801c5a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c61:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c66:	f6 c1 01             	test   $0x1,%cl
  801c69:	74 1d                	je     801c88 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c6b:	c1 ea 0c             	shr    $0xc,%edx
  801c6e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c75:	f6 c2 01             	test   $0x1,%dl
  801c78:	74 0e                	je     801c88 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c7a:	c1 ea 0c             	shr    $0xc,%edx
  801c7d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c84:	ef 
  801c85:	0f b7 c0             	movzwl %ax,%eax
}
  801c88:	5d                   	pop    %ebp
  801c89:	c3                   	ret    
  801c8a:	66 90                	xchg   %ax,%ax
  801c8c:	66 90                	xchg   %ax,%ax
  801c8e:	66 90                	xchg   %ax,%ax

00801c90 <__udivdi3>:
  801c90:	55                   	push   %ebp
  801c91:	57                   	push   %edi
  801c92:	56                   	push   %esi
  801c93:	53                   	push   %ebx
  801c94:	83 ec 1c             	sub    $0x1c,%esp
  801c97:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801c9b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c9f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801ca3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ca7:	85 f6                	test   %esi,%esi
  801ca9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801cad:	89 ca                	mov    %ecx,%edx
  801caf:	89 f8                	mov    %edi,%eax
  801cb1:	75 3d                	jne    801cf0 <__udivdi3+0x60>
  801cb3:	39 cf                	cmp    %ecx,%edi
  801cb5:	0f 87 c5 00 00 00    	ja     801d80 <__udivdi3+0xf0>
  801cbb:	85 ff                	test   %edi,%edi
  801cbd:	89 fd                	mov    %edi,%ebp
  801cbf:	75 0b                	jne    801ccc <__udivdi3+0x3c>
  801cc1:	b8 01 00 00 00       	mov    $0x1,%eax
  801cc6:	31 d2                	xor    %edx,%edx
  801cc8:	f7 f7                	div    %edi
  801cca:	89 c5                	mov    %eax,%ebp
  801ccc:	89 c8                	mov    %ecx,%eax
  801cce:	31 d2                	xor    %edx,%edx
  801cd0:	f7 f5                	div    %ebp
  801cd2:	89 c1                	mov    %eax,%ecx
  801cd4:	89 d8                	mov    %ebx,%eax
  801cd6:	89 cf                	mov    %ecx,%edi
  801cd8:	f7 f5                	div    %ebp
  801cda:	89 c3                	mov    %eax,%ebx
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
  801cf0:	39 ce                	cmp    %ecx,%esi
  801cf2:	77 74                	ja     801d68 <__udivdi3+0xd8>
  801cf4:	0f bd fe             	bsr    %esi,%edi
  801cf7:	83 f7 1f             	xor    $0x1f,%edi
  801cfa:	0f 84 98 00 00 00    	je     801d98 <__udivdi3+0x108>
  801d00:	bb 20 00 00 00       	mov    $0x20,%ebx
  801d05:	89 f9                	mov    %edi,%ecx
  801d07:	89 c5                	mov    %eax,%ebp
  801d09:	29 fb                	sub    %edi,%ebx
  801d0b:	d3 e6                	shl    %cl,%esi
  801d0d:	89 d9                	mov    %ebx,%ecx
  801d0f:	d3 ed                	shr    %cl,%ebp
  801d11:	89 f9                	mov    %edi,%ecx
  801d13:	d3 e0                	shl    %cl,%eax
  801d15:	09 ee                	or     %ebp,%esi
  801d17:	89 d9                	mov    %ebx,%ecx
  801d19:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d1d:	89 d5                	mov    %edx,%ebp
  801d1f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d23:	d3 ed                	shr    %cl,%ebp
  801d25:	89 f9                	mov    %edi,%ecx
  801d27:	d3 e2                	shl    %cl,%edx
  801d29:	89 d9                	mov    %ebx,%ecx
  801d2b:	d3 e8                	shr    %cl,%eax
  801d2d:	09 c2                	or     %eax,%edx
  801d2f:	89 d0                	mov    %edx,%eax
  801d31:	89 ea                	mov    %ebp,%edx
  801d33:	f7 f6                	div    %esi
  801d35:	89 d5                	mov    %edx,%ebp
  801d37:	89 c3                	mov    %eax,%ebx
  801d39:	f7 64 24 0c          	mull   0xc(%esp)
  801d3d:	39 d5                	cmp    %edx,%ebp
  801d3f:	72 10                	jb     801d51 <__udivdi3+0xc1>
  801d41:	8b 74 24 08          	mov    0x8(%esp),%esi
  801d45:	89 f9                	mov    %edi,%ecx
  801d47:	d3 e6                	shl    %cl,%esi
  801d49:	39 c6                	cmp    %eax,%esi
  801d4b:	73 07                	jae    801d54 <__udivdi3+0xc4>
  801d4d:	39 d5                	cmp    %edx,%ebp
  801d4f:	75 03                	jne    801d54 <__udivdi3+0xc4>
  801d51:	83 eb 01             	sub    $0x1,%ebx
  801d54:	31 ff                	xor    %edi,%edi
  801d56:	89 d8                	mov    %ebx,%eax
  801d58:	89 fa                	mov    %edi,%edx
  801d5a:	83 c4 1c             	add    $0x1c,%esp
  801d5d:	5b                   	pop    %ebx
  801d5e:	5e                   	pop    %esi
  801d5f:	5f                   	pop    %edi
  801d60:	5d                   	pop    %ebp
  801d61:	c3                   	ret    
  801d62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d68:	31 ff                	xor    %edi,%edi
  801d6a:	31 db                	xor    %ebx,%ebx
  801d6c:	89 d8                	mov    %ebx,%eax
  801d6e:	89 fa                	mov    %edi,%edx
  801d70:	83 c4 1c             	add    $0x1c,%esp
  801d73:	5b                   	pop    %ebx
  801d74:	5e                   	pop    %esi
  801d75:	5f                   	pop    %edi
  801d76:	5d                   	pop    %ebp
  801d77:	c3                   	ret    
  801d78:	90                   	nop
  801d79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d80:	89 d8                	mov    %ebx,%eax
  801d82:	f7 f7                	div    %edi
  801d84:	31 ff                	xor    %edi,%edi
  801d86:	89 c3                	mov    %eax,%ebx
  801d88:	89 d8                	mov    %ebx,%eax
  801d8a:	89 fa                	mov    %edi,%edx
  801d8c:	83 c4 1c             	add    $0x1c,%esp
  801d8f:	5b                   	pop    %ebx
  801d90:	5e                   	pop    %esi
  801d91:	5f                   	pop    %edi
  801d92:	5d                   	pop    %ebp
  801d93:	c3                   	ret    
  801d94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d98:	39 ce                	cmp    %ecx,%esi
  801d9a:	72 0c                	jb     801da8 <__udivdi3+0x118>
  801d9c:	31 db                	xor    %ebx,%ebx
  801d9e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801da2:	0f 87 34 ff ff ff    	ja     801cdc <__udivdi3+0x4c>
  801da8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801dad:	e9 2a ff ff ff       	jmp    801cdc <__udivdi3+0x4c>
  801db2:	66 90                	xchg   %ax,%ax
  801db4:	66 90                	xchg   %ax,%ax
  801db6:	66 90                	xchg   %ax,%ax
  801db8:	66 90                	xchg   %ax,%ax
  801dba:	66 90                	xchg   %ax,%ax
  801dbc:	66 90                	xchg   %ax,%ax
  801dbe:	66 90                	xchg   %ax,%ax

00801dc0 <__umoddi3>:
  801dc0:	55                   	push   %ebp
  801dc1:	57                   	push   %edi
  801dc2:	56                   	push   %esi
  801dc3:	53                   	push   %ebx
  801dc4:	83 ec 1c             	sub    $0x1c,%esp
  801dc7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801dcb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801dcf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801dd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801dd7:	85 d2                	test   %edx,%edx
  801dd9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801ddd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801de1:	89 f3                	mov    %esi,%ebx
  801de3:	89 3c 24             	mov    %edi,(%esp)
  801de6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dea:	75 1c                	jne    801e08 <__umoddi3+0x48>
  801dec:	39 f7                	cmp    %esi,%edi
  801dee:	76 50                	jbe    801e40 <__umoddi3+0x80>
  801df0:	89 c8                	mov    %ecx,%eax
  801df2:	89 f2                	mov    %esi,%edx
  801df4:	f7 f7                	div    %edi
  801df6:	89 d0                	mov    %edx,%eax
  801df8:	31 d2                	xor    %edx,%edx
  801dfa:	83 c4 1c             	add    $0x1c,%esp
  801dfd:	5b                   	pop    %ebx
  801dfe:	5e                   	pop    %esi
  801dff:	5f                   	pop    %edi
  801e00:	5d                   	pop    %ebp
  801e01:	c3                   	ret    
  801e02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e08:	39 f2                	cmp    %esi,%edx
  801e0a:	89 d0                	mov    %edx,%eax
  801e0c:	77 52                	ja     801e60 <__umoddi3+0xa0>
  801e0e:	0f bd ea             	bsr    %edx,%ebp
  801e11:	83 f5 1f             	xor    $0x1f,%ebp
  801e14:	75 5a                	jne    801e70 <__umoddi3+0xb0>
  801e16:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801e1a:	0f 82 e0 00 00 00    	jb     801f00 <__umoddi3+0x140>
  801e20:	39 0c 24             	cmp    %ecx,(%esp)
  801e23:	0f 86 d7 00 00 00    	jbe    801f00 <__umoddi3+0x140>
  801e29:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e2d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e31:	83 c4 1c             	add    $0x1c,%esp
  801e34:	5b                   	pop    %ebx
  801e35:	5e                   	pop    %esi
  801e36:	5f                   	pop    %edi
  801e37:	5d                   	pop    %ebp
  801e38:	c3                   	ret    
  801e39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e40:	85 ff                	test   %edi,%edi
  801e42:	89 fd                	mov    %edi,%ebp
  801e44:	75 0b                	jne    801e51 <__umoddi3+0x91>
  801e46:	b8 01 00 00 00       	mov    $0x1,%eax
  801e4b:	31 d2                	xor    %edx,%edx
  801e4d:	f7 f7                	div    %edi
  801e4f:	89 c5                	mov    %eax,%ebp
  801e51:	89 f0                	mov    %esi,%eax
  801e53:	31 d2                	xor    %edx,%edx
  801e55:	f7 f5                	div    %ebp
  801e57:	89 c8                	mov    %ecx,%eax
  801e59:	f7 f5                	div    %ebp
  801e5b:	89 d0                	mov    %edx,%eax
  801e5d:	eb 99                	jmp    801df8 <__umoddi3+0x38>
  801e5f:	90                   	nop
  801e60:	89 c8                	mov    %ecx,%eax
  801e62:	89 f2                	mov    %esi,%edx
  801e64:	83 c4 1c             	add    $0x1c,%esp
  801e67:	5b                   	pop    %ebx
  801e68:	5e                   	pop    %esi
  801e69:	5f                   	pop    %edi
  801e6a:	5d                   	pop    %ebp
  801e6b:	c3                   	ret    
  801e6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e70:	8b 34 24             	mov    (%esp),%esi
  801e73:	bf 20 00 00 00       	mov    $0x20,%edi
  801e78:	89 e9                	mov    %ebp,%ecx
  801e7a:	29 ef                	sub    %ebp,%edi
  801e7c:	d3 e0                	shl    %cl,%eax
  801e7e:	89 f9                	mov    %edi,%ecx
  801e80:	89 f2                	mov    %esi,%edx
  801e82:	d3 ea                	shr    %cl,%edx
  801e84:	89 e9                	mov    %ebp,%ecx
  801e86:	09 c2                	or     %eax,%edx
  801e88:	89 d8                	mov    %ebx,%eax
  801e8a:	89 14 24             	mov    %edx,(%esp)
  801e8d:	89 f2                	mov    %esi,%edx
  801e8f:	d3 e2                	shl    %cl,%edx
  801e91:	89 f9                	mov    %edi,%ecx
  801e93:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e97:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801e9b:	d3 e8                	shr    %cl,%eax
  801e9d:	89 e9                	mov    %ebp,%ecx
  801e9f:	89 c6                	mov    %eax,%esi
  801ea1:	d3 e3                	shl    %cl,%ebx
  801ea3:	89 f9                	mov    %edi,%ecx
  801ea5:	89 d0                	mov    %edx,%eax
  801ea7:	d3 e8                	shr    %cl,%eax
  801ea9:	89 e9                	mov    %ebp,%ecx
  801eab:	09 d8                	or     %ebx,%eax
  801ead:	89 d3                	mov    %edx,%ebx
  801eaf:	89 f2                	mov    %esi,%edx
  801eb1:	f7 34 24             	divl   (%esp)
  801eb4:	89 d6                	mov    %edx,%esi
  801eb6:	d3 e3                	shl    %cl,%ebx
  801eb8:	f7 64 24 04          	mull   0x4(%esp)
  801ebc:	39 d6                	cmp    %edx,%esi
  801ebe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ec2:	89 d1                	mov    %edx,%ecx
  801ec4:	89 c3                	mov    %eax,%ebx
  801ec6:	72 08                	jb     801ed0 <__umoddi3+0x110>
  801ec8:	75 11                	jne    801edb <__umoddi3+0x11b>
  801eca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801ece:	73 0b                	jae    801edb <__umoddi3+0x11b>
  801ed0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801ed4:	1b 14 24             	sbb    (%esp),%edx
  801ed7:	89 d1                	mov    %edx,%ecx
  801ed9:	89 c3                	mov    %eax,%ebx
  801edb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801edf:	29 da                	sub    %ebx,%edx
  801ee1:	19 ce                	sbb    %ecx,%esi
  801ee3:	89 f9                	mov    %edi,%ecx
  801ee5:	89 f0                	mov    %esi,%eax
  801ee7:	d3 e0                	shl    %cl,%eax
  801ee9:	89 e9                	mov    %ebp,%ecx
  801eeb:	d3 ea                	shr    %cl,%edx
  801eed:	89 e9                	mov    %ebp,%ecx
  801eef:	d3 ee                	shr    %cl,%esi
  801ef1:	09 d0                	or     %edx,%eax
  801ef3:	89 f2                	mov    %esi,%edx
  801ef5:	83 c4 1c             	add    $0x1c,%esp
  801ef8:	5b                   	pop    %ebx
  801ef9:	5e                   	pop    %esi
  801efa:	5f                   	pop    %edi
  801efb:	5d                   	pop    %ebp
  801efc:	c3                   	ret    
  801efd:	8d 76 00             	lea    0x0(%esi),%esi
  801f00:	29 f9                	sub    %edi,%ecx
  801f02:	19 d6                	sbb    %edx,%esi
  801f04:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f08:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f0c:	e9 18 ff ff ff       	jmp    801e29 <__umoddi3+0x69>
