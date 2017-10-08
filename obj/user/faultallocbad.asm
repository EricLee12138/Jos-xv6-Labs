
obj/user/faultallocbad.debug：     文件格式 elf32-i386


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
  800045:	e8 a4 01 00 00       	call   8001ee <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 97 0b 00 00       	call   800bf5 <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	79 16                	jns    80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  800065:	83 ec 0c             	sub    $0xc,%esp
  800068:	50                   	push   %eax
  800069:	53                   	push   %ebx
  80006a:	68 40 1f 80 00       	push   $0x801f40
  80006f:	6a 0f                	push   $0xf
  800071:	68 2a 1f 80 00       	push   $0x801f2a
  800076:	e8 9a 00 00 00       	call   800115 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  80007b:	53                   	push   %ebx
  80007c:	68 6c 1f 80 00       	push   $0x801f6c
  800081:	6a 64                	push   $0x64
  800083:	53                   	push   %ebx
  800084:	e8 16 07 00 00       	call   80079f <snprintf>
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
  80009c:	e8 45 0d 00 00       	call   800de6 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	6a 04                	push   $0x4
  8000a6:	68 ef be ad de       	push   $0xdeadbeef
  8000ab:	e8 89 0a 00 00       	call   800b39 <sys_cputs>
}
  8000b0:	83 c4 10             	add    $0x10,%esp
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
  8000c0:	e8 f2 0a 00 00       	call   800bb7 <sys_getenvid>
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
  8000e7:	e8 a5 ff ff ff       	call   800091 <umain>

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
  800101:	e8 16 0f 00 00       	call   80101c <close_all>
	sys_env_destroy(0);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	6a 00                	push   $0x0
  80010b:	e8 66 0a 00 00       	call   800b76 <sys_env_destroy>
}
  800110:	83 c4 10             	add    $0x10,%esp
  800113:	c9                   	leave  
  800114:	c3                   	ret    

00800115 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	56                   	push   %esi
  800119:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80011a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80011d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800123:	e8 8f 0a 00 00       	call   800bb7 <sys_getenvid>
  800128:	83 ec 0c             	sub    $0xc,%esp
  80012b:	ff 75 0c             	pushl  0xc(%ebp)
  80012e:	ff 75 08             	pushl  0x8(%ebp)
  800131:	56                   	push   %esi
  800132:	50                   	push   %eax
  800133:	68 98 1f 80 00       	push   $0x801f98
  800138:	e8 b1 00 00 00       	call   8001ee <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80013d:	83 c4 18             	add    $0x18,%esp
  800140:	53                   	push   %ebx
  800141:	ff 75 10             	pushl  0x10(%ebp)
  800144:	e8 54 00 00 00       	call   80019d <vcprintf>
	cprintf("\n");
  800149:	c7 04 24 c7 23 80 00 	movl   $0x8023c7,(%esp)
  800150:	e8 99 00 00 00       	call   8001ee <cprintf>
  800155:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800158:	cc                   	int3   
  800159:	eb fd                	jmp    800158 <_panic+0x43>

0080015b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	53                   	push   %ebx
  80015f:	83 ec 04             	sub    $0x4,%esp
  800162:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800165:	8b 13                	mov    (%ebx),%edx
  800167:	8d 42 01             	lea    0x1(%edx),%eax
  80016a:	89 03                	mov    %eax,(%ebx)
  80016c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80016f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800173:	3d ff 00 00 00       	cmp    $0xff,%eax
  800178:	75 1a                	jne    800194 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80017a:	83 ec 08             	sub    $0x8,%esp
  80017d:	68 ff 00 00 00       	push   $0xff
  800182:	8d 43 08             	lea    0x8(%ebx),%eax
  800185:	50                   	push   %eax
  800186:	e8 ae 09 00 00       	call   800b39 <sys_cputs>
		b->idx = 0;
  80018b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800191:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800194:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800198:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80019b:	c9                   	leave  
  80019c:	c3                   	ret    

0080019d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ad:	00 00 00 
	b.cnt = 0;
  8001b0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ba:	ff 75 0c             	pushl  0xc(%ebp)
  8001bd:	ff 75 08             	pushl  0x8(%ebp)
  8001c0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c6:	50                   	push   %eax
  8001c7:	68 5b 01 80 00       	push   $0x80015b
  8001cc:	e8 1a 01 00 00       	call   8002eb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001d1:	83 c4 08             	add    $0x8,%esp
  8001d4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001da:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001e0:	50                   	push   %eax
  8001e1:	e8 53 09 00 00       	call   800b39 <sys_cputs>

	return b.cnt;
}
  8001e6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ec:	c9                   	leave  
  8001ed:	c3                   	ret    

008001ee <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001ee:	55                   	push   %ebp
  8001ef:	89 e5                	mov    %esp,%ebp
  8001f1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001f4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001f7:	50                   	push   %eax
  8001f8:	ff 75 08             	pushl  0x8(%ebp)
  8001fb:	e8 9d ff ff ff       	call   80019d <vcprintf>
	va_end(ap);

	return cnt;
}
  800200:	c9                   	leave  
  800201:	c3                   	ret    

00800202 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800202:	55                   	push   %ebp
  800203:	89 e5                	mov    %esp,%ebp
  800205:	57                   	push   %edi
  800206:	56                   	push   %esi
  800207:	53                   	push   %ebx
  800208:	83 ec 1c             	sub    $0x1c,%esp
  80020b:	89 c7                	mov    %eax,%edi
  80020d:	89 d6                	mov    %edx,%esi
  80020f:	8b 45 08             	mov    0x8(%ebp),%eax
  800212:	8b 55 0c             	mov    0xc(%ebp),%edx
  800215:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800218:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80021b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80021e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800223:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800226:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800229:	39 d3                	cmp    %edx,%ebx
  80022b:	72 05                	jb     800232 <printnum+0x30>
  80022d:	39 45 10             	cmp    %eax,0x10(%ebp)
  800230:	77 45                	ja     800277 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800232:	83 ec 0c             	sub    $0xc,%esp
  800235:	ff 75 18             	pushl  0x18(%ebp)
  800238:	8b 45 14             	mov    0x14(%ebp),%eax
  80023b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80023e:	53                   	push   %ebx
  80023f:	ff 75 10             	pushl  0x10(%ebp)
  800242:	83 ec 08             	sub    $0x8,%esp
  800245:	ff 75 e4             	pushl  -0x1c(%ebp)
  800248:	ff 75 e0             	pushl  -0x20(%ebp)
  80024b:	ff 75 dc             	pushl  -0x24(%ebp)
  80024e:	ff 75 d8             	pushl  -0x28(%ebp)
  800251:	e8 2a 1a 00 00       	call   801c80 <__udivdi3>
  800256:	83 c4 18             	add    $0x18,%esp
  800259:	52                   	push   %edx
  80025a:	50                   	push   %eax
  80025b:	89 f2                	mov    %esi,%edx
  80025d:	89 f8                	mov    %edi,%eax
  80025f:	e8 9e ff ff ff       	call   800202 <printnum>
  800264:	83 c4 20             	add    $0x20,%esp
  800267:	eb 18                	jmp    800281 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800269:	83 ec 08             	sub    $0x8,%esp
  80026c:	56                   	push   %esi
  80026d:	ff 75 18             	pushl  0x18(%ebp)
  800270:	ff d7                	call   *%edi
  800272:	83 c4 10             	add    $0x10,%esp
  800275:	eb 03                	jmp    80027a <printnum+0x78>
  800277:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80027a:	83 eb 01             	sub    $0x1,%ebx
  80027d:	85 db                	test   %ebx,%ebx
  80027f:	7f e8                	jg     800269 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800281:	83 ec 08             	sub    $0x8,%esp
  800284:	56                   	push   %esi
  800285:	83 ec 04             	sub    $0x4,%esp
  800288:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028b:	ff 75 e0             	pushl  -0x20(%ebp)
  80028e:	ff 75 dc             	pushl  -0x24(%ebp)
  800291:	ff 75 d8             	pushl  -0x28(%ebp)
  800294:	e8 17 1b 00 00       	call   801db0 <__umoddi3>
  800299:	83 c4 14             	add    $0x14,%esp
  80029c:	0f be 80 bb 1f 80 00 	movsbl 0x801fbb(%eax),%eax
  8002a3:	50                   	push   %eax
  8002a4:	ff d7                	call   *%edi
}
  8002a6:	83 c4 10             	add    $0x10,%esp
  8002a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ac:	5b                   	pop    %ebx
  8002ad:	5e                   	pop    %esi
  8002ae:	5f                   	pop    %edi
  8002af:	5d                   	pop    %ebp
  8002b0:	c3                   	ret    

008002b1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002bb:	8b 10                	mov    (%eax),%edx
  8002bd:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c0:	73 0a                	jae    8002cc <sprintputch+0x1b>
		*b->buf++ = ch;
  8002c2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c5:	89 08                	mov    %ecx,(%eax)
  8002c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ca:	88 02                	mov    %al,(%edx)
}
  8002cc:	5d                   	pop    %ebp
  8002cd:	c3                   	ret    

008002ce <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8002ce:	55                   	push   %ebp
  8002cf:	89 e5                	mov    %esp,%ebp
  8002d1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8002d4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d7:	50                   	push   %eax
  8002d8:	ff 75 10             	pushl  0x10(%ebp)
  8002db:	ff 75 0c             	pushl  0xc(%ebp)
  8002de:	ff 75 08             	pushl  0x8(%ebp)
  8002e1:	e8 05 00 00 00       	call   8002eb <vprintfmt>
	va_end(ap);
}
  8002e6:	83 c4 10             	add    $0x10,%esp
  8002e9:	c9                   	leave  
  8002ea:	c3                   	ret    

008002eb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	57                   	push   %edi
  8002ef:	56                   	push   %esi
  8002f0:	53                   	push   %ebx
  8002f1:	83 ec 2c             	sub    $0x2c,%esp
  8002f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8002f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002fa:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002fd:	eb 12                	jmp    800311 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002ff:	85 c0                	test   %eax,%eax
  800301:	0f 84 42 04 00 00    	je     800749 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  800307:	83 ec 08             	sub    $0x8,%esp
  80030a:	53                   	push   %ebx
  80030b:	50                   	push   %eax
  80030c:	ff d6                	call   *%esi
  80030e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800311:	83 c7 01             	add    $0x1,%edi
  800314:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800318:	83 f8 25             	cmp    $0x25,%eax
  80031b:	75 e2                	jne    8002ff <vprintfmt+0x14>
  80031d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800321:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800328:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80032f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800336:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033b:	eb 07                	jmp    800344 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800340:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800344:	8d 47 01             	lea    0x1(%edi),%eax
  800347:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80034a:	0f b6 07             	movzbl (%edi),%eax
  80034d:	0f b6 d0             	movzbl %al,%edx
  800350:	83 e8 23             	sub    $0x23,%eax
  800353:	3c 55                	cmp    $0x55,%al
  800355:	0f 87 d3 03 00 00    	ja     80072e <vprintfmt+0x443>
  80035b:	0f b6 c0             	movzbl %al,%eax
  80035e:	ff 24 85 00 21 80 00 	jmp    *0x802100(,%eax,4)
  800365:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800368:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80036c:	eb d6                	jmp    800344 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800371:	b8 00 00 00 00       	mov    $0x0,%eax
  800376:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800379:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80037c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800380:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800383:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800386:	83 f9 09             	cmp    $0x9,%ecx
  800389:	77 3f                	ja     8003ca <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80038b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80038e:	eb e9                	jmp    800379 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800390:	8b 45 14             	mov    0x14(%ebp),%eax
  800393:	8b 00                	mov    (%eax),%eax
  800395:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800398:	8b 45 14             	mov    0x14(%ebp),%eax
  80039b:	8d 40 04             	lea    0x4(%eax),%eax
  80039e:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003a4:	eb 2a                	jmp    8003d0 <vprintfmt+0xe5>
  8003a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003a9:	85 c0                	test   %eax,%eax
  8003ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b0:	0f 49 d0             	cmovns %eax,%edx
  8003b3:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b9:	eb 89                	jmp    800344 <vprintfmt+0x59>
  8003bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003be:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003c5:	e9 7a ff ff ff       	jmp    800344 <vprintfmt+0x59>
  8003ca:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003cd:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8003d0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003d4:	0f 89 6a ff ff ff    	jns    800344 <vprintfmt+0x59>
				width = precision, precision = -1;
  8003da:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003e0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003e7:	e9 58 ff ff ff       	jmp    800344 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003ec:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003f2:	e9 4d ff ff ff       	jmp    800344 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fa:	8d 78 04             	lea    0x4(%eax),%edi
  8003fd:	83 ec 08             	sub    $0x8,%esp
  800400:	53                   	push   %ebx
  800401:	ff 30                	pushl  (%eax)
  800403:	ff d6                	call   *%esi
			break;
  800405:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800408:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80040e:	e9 fe fe ff ff       	jmp    800311 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800413:	8b 45 14             	mov    0x14(%ebp),%eax
  800416:	8d 78 04             	lea    0x4(%eax),%edi
  800419:	8b 00                	mov    (%eax),%eax
  80041b:	99                   	cltd   
  80041c:	31 d0                	xor    %edx,%eax
  80041e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800420:	83 f8 0f             	cmp    $0xf,%eax
  800423:	7f 0b                	jg     800430 <vprintfmt+0x145>
  800425:	8b 14 85 60 22 80 00 	mov    0x802260(,%eax,4),%edx
  80042c:	85 d2                	test   %edx,%edx
  80042e:	75 1b                	jne    80044b <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800430:	50                   	push   %eax
  800431:	68 d3 1f 80 00       	push   $0x801fd3
  800436:	53                   	push   %ebx
  800437:	56                   	push   %esi
  800438:	e8 91 fe ff ff       	call   8002ce <printfmt>
  80043d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800440:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800443:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800446:	e9 c6 fe ff ff       	jmp    800311 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80044b:	52                   	push   %edx
  80044c:	68 95 23 80 00       	push   $0x802395
  800451:	53                   	push   %ebx
  800452:	56                   	push   %esi
  800453:	e8 76 fe ff ff       	call   8002ce <printfmt>
  800458:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80045b:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800461:	e9 ab fe ff ff       	jmp    800311 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800466:	8b 45 14             	mov    0x14(%ebp),%eax
  800469:	83 c0 04             	add    $0x4,%eax
  80046c:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80046f:	8b 45 14             	mov    0x14(%ebp),%eax
  800472:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800474:	85 ff                	test   %edi,%edi
  800476:	b8 cc 1f 80 00       	mov    $0x801fcc,%eax
  80047b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80047e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800482:	0f 8e 94 00 00 00    	jle    80051c <vprintfmt+0x231>
  800488:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80048c:	0f 84 98 00 00 00    	je     80052a <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800492:	83 ec 08             	sub    $0x8,%esp
  800495:	ff 75 d0             	pushl  -0x30(%ebp)
  800498:	57                   	push   %edi
  800499:	e8 33 03 00 00       	call   8007d1 <strnlen>
  80049e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004a1:	29 c1                	sub    %eax,%ecx
  8004a3:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004a6:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004a9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004b3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b5:	eb 0f                	jmp    8004c6 <vprintfmt+0x1db>
					putch(padc, putdat);
  8004b7:	83 ec 08             	sub    $0x8,%esp
  8004ba:	53                   	push   %ebx
  8004bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8004be:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c0:	83 ef 01             	sub    $0x1,%edi
  8004c3:	83 c4 10             	add    $0x10,%esp
  8004c6:	85 ff                	test   %edi,%edi
  8004c8:	7f ed                	jg     8004b7 <vprintfmt+0x1cc>
  8004ca:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004cd:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004d0:	85 c9                	test   %ecx,%ecx
  8004d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d7:	0f 49 c1             	cmovns %ecx,%eax
  8004da:	29 c1                	sub    %eax,%ecx
  8004dc:	89 75 08             	mov    %esi,0x8(%ebp)
  8004df:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004e2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004e5:	89 cb                	mov    %ecx,%ebx
  8004e7:	eb 4d                	jmp    800536 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004e9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004ed:	74 1b                	je     80050a <vprintfmt+0x21f>
  8004ef:	0f be c0             	movsbl %al,%eax
  8004f2:	83 e8 20             	sub    $0x20,%eax
  8004f5:	83 f8 5e             	cmp    $0x5e,%eax
  8004f8:	76 10                	jbe    80050a <vprintfmt+0x21f>
					putch('?', putdat);
  8004fa:	83 ec 08             	sub    $0x8,%esp
  8004fd:	ff 75 0c             	pushl  0xc(%ebp)
  800500:	6a 3f                	push   $0x3f
  800502:	ff 55 08             	call   *0x8(%ebp)
  800505:	83 c4 10             	add    $0x10,%esp
  800508:	eb 0d                	jmp    800517 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80050a:	83 ec 08             	sub    $0x8,%esp
  80050d:	ff 75 0c             	pushl  0xc(%ebp)
  800510:	52                   	push   %edx
  800511:	ff 55 08             	call   *0x8(%ebp)
  800514:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800517:	83 eb 01             	sub    $0x1,%ebx
  80051a:	eb 1a                	jmp    800536 <vprintfmt+0x24b>
  80051c:	89 75 08             	mov    %esi,0x8(%ebp)
  80051f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800522:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800525:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800528:	eb 0c                	jmp    800536 <vprintfmt+0x24b>
  80052a:	89 75 08             	mov    %esi,0x8(%ebp)
  80052d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800530:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800533:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800536:	83 c7 01             	add    $0x1,%edi
  800539:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80053d:	0f be d0             	movsbl %al,%edx
  800540:	85 d2                	test   %edx,%edx
  800542:	74 23                	je     800567 <vprintfmt+0x27c>
  800544:	85 f6                	test   %esi,%esi
  800546:	78 a1                	js     8004e9 <vprintfmt+0x1fe>
  800548:	83 ee 01             	sub    $0x1,%esi
  80054b:	79 9c                	jns    8004e9 <vprintfmt+0x1fe>
  80054d:	89 df                	mov    %ebx,%edi
  80054f:	8b 75 08             	mov    0x8(%ebp),%esi
  800552:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800555:	eb 18                	jmp    80056f <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800557:	83 ec 08             	sub    $0x8,%esp
  80055a:	53                   	push   %ebx
  80055b:	6a 20                	push   $0x20
  80055d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80055f:	83 ef 01             	sub    $0x1,%edi
  800562:	83 c4 10             	add    $0x10,%esp
  800565:	eb 08                	jmp    80056f <vprintfmt+0x284>
  800567:	89 df                	mov    %ebx,%edi
  800569:	8b 75 08             	mov    0x8(%ebp),%esi
  80056c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80056f:	85 ff                	test   %edi,%edi
  800571:	7f e4                	jg     800557 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800573:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800576:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800579:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80057c:	e9 90 fd ff ff       	jmp    800311 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800581:	83 f9 01             	cmp    $0x1,%ecx
  800584:	7e 19                	jle    80059f <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800586:	8b 45 14             	mov    0x14(%ebp),%eax
  800589:	8b 50 04             	mov    0x4(%eax),%edx
  80058c:	8b 00                	mov    (%eax),%eax
  80058e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800591:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800594:	8b 45 14             	mov    0x14(%ebp),%eax
  800597:	8d 40 08             	lea    0x8(%eax),%eax
  80059a:	89 45 14             	mov    %eax,0x14(%ebp)
  80059d:	eb 38                	jmp    8005d7 <vprintfmt+0x2ec>
	else if (lflag)
  80059f:	85 c9                	test   %ecx,%ecx
  8005a1:	74 1b                	je     8005be <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8005a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a6:	8b 00                	mov    (%eax),%eax
  8005a8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ab:	89 c1                	mov    %eax,%ecx
  8005ad:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b6:	8d 40 04             	lea    0x4(%eax),%eax
  8005b9:	89 45 14             	mov    %eax,0x14(%ebp)
  8005bc:	eb 19                	jmp    8005d7 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8005be:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c1:	8b 00                	mov    (%eax),%eax
  8005c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c6:	89 c1                	mov    %eax,%ecx
  8005c8:	c1 f9 1f             	sar    $0x1f,%ecx
  8005cb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d1:	8d 40 04             	lea    0x4(%eax),%eax
  8005d4:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005d7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005da:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005dd:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005e2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005e6:	0f 89 0e 01 00 00    	jns    8006fa <vprintfmt+0x40f>
				putch('-', putdat);
  8005ec:	83 ec 08             	sub    $0x8,%esp
  8005ef:	53                   	push   %ebx
  8005f0:	6a 2d                	push   $0x2d
  8005f2:	ff d6                	call   *%esi
				num = -(long long) num;
  8005f4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005f7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005fa:	f7 da                	neg    %edx
  8005fc:	83 d1 00             	adc    $0x0,%ecx
  8005ff:	f7 d9                	neg    %ecx
  800601:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800604:	b8 0a 00 00 00       	mov    $0xa,%eax
  800609:	e9 ec 00 00 00       	jmp    8006fa <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80060e:	83 f9 01             	cmp    $0x1,%ecx
  800611:	7e 18                	jle    80062b <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800613:	8b 45 14             	mov    0x14(%ebp),%eax
  800616:	8b 10                	mov    (%eax),%edx
  800618:	8b 48 04             	mov    0x4(%eax),%ecx
  80061b:	8d 40 08             	lea    0x8(%eax),%eax
  80061e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800621:	b8 0a 00 00 00       	mov    $0xa,%eax
  800626:	e9 cf 00 00 00       	jmp    8006fa <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80062b:	85 c9                	test   %ecx,%ecx
  80062d:	74 1a                	je     800649 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
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
  800644:	e9 b1 00 00 00       	jmp    8006fa <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800649:	8b 45 14             	mov    0x14(%ebp),%eax
  80064c:	8b 10                	mov    (%eax),%edx
  80064e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800653:	8d 40 04             	lea    0x4(%eax),%eax
  800656:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800659:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065e:	e9 97 00 00 00       	jmp    8006fa <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800663:	83 ec 08             	sub    $0x8,%esp
  800666:	53                   	push   %ebx
  800667:	6a 58                	push   $0x58
  800669:	ff d6                	call   *%esi
			putch('X', putdat);
  80066b:	83 c4 08             	add    $0x8,%esp
  80066e:	53                   	push   %ebx
  80066f:	6a 58                	push   $0x58
  800671:	ff d6                	call   *%esi
			putch('X', putdat);
  800673:	83 c4 08             	add    $0x8,%esp
  800676:	53                   	push   %ebx
  800677:	6a 58                	push   $0x58
  800679:	ff d6                	call   *%esi
			break;
  80067b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800681:	e9 8b fc ff ff       	jmp    800311 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800686:	83 ec 08             	sub    $0x8,%esp
  800689:	53                   	push   %ebx
  80068a:	6a 30                	push   $0x30
  80068c:	ff d6                	call   *%esi
			putch('x', putdat);
  80068e:	83 c4 08             	add    $0x8,%esp
  800691:	53                   	push   %ebx
  800692:	6a 78                	push   $0x78
  800694:	ff d6                	call   *%esi
			num = (unsigned long long)
  800696:	8b 45 14             	mov    0x14(%ebp),%eax
  800699:	8b 10                	mov    (%eax),%edx
  80069b:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006a0:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006a3:	8d 40 04             	lea    0x4(%eax),%eax
  8006a6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006a9:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006ae:	eb 4a                	jmp    8006fa <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006b0:	83 f9 01             	cmp    $0x1,%ecx
  8006b3:	7e 15                	jle    8006ca <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8006b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b8:	8b 10                	mov    (%eax),%edx
  8006ba:	8b 48 04             	mov    0x4(%eax),%ecx
  8006bd:	8d 40 08             	lea    0x8(%eax),%eax
  8006c0:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006c3:	b8 10 00 00 00       	mov    $0x10,%eax
  8006c8:	eb 30                	jmp    8006fa <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006ca:	85 c9                	test   %ecx,%ecx
  8006cc:	74 17                	je     8006e5 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8006ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d1:	8b 10                	mov    (%eax),%edx
  8006d3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d8:	8d 40 04             	lea    0x4(%eax),%eax
  8006db:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006de:	b8 10 00 00 00       	mov    $0x10,%eax
  8006e3:	eb 15                	jmp    8006fa <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8006e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e8:	8b 10                	mov    (%eax),%edx
  8006ea:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ef:	8d 40 04             	lea    0x4(%eax),%eax
  8006f2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006f5:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006fa:	83 ec 0c             	sub    $0xc,%esp
  8006fd:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800701:	57                   	push   %edi
  800702:	ff 75 e0             	pushl  -0x20(%ebp)
  800705:	50                   	push   %eax
  800706:	51                   	push   %ecx
  800707:	52                   	push   %edx
  800708:	89 da                	mov    %ebx,%edx
  80070a:	89 f0                	mov    %esi,%eax
  80070c:	e8 f1 fa ff ff       	call   800202 <printnum>
			break;
  800711:	83 c4 20             	add    $0x20,%esp
  800714:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800717:	e9 f5 fb ff ff       	jmp    800311 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80071c:	83 ec 08             	sub    $0x8,%esp
  80071f:	53                   	push   %ebx
  800720:	52                   	push   %edx
  800721:	ff d6                	call   *%esi
			break;
  800723:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800726:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800729:	e9 e3 fb ff ff       	jmp    800311 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80072e:	83 ec 08             	sub    $0x8,%esp
  800731:	53                   	push   %ebx
  800732:	6a 25                	push   $0x25
  800734:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800736:	83 c4 10             	add    $0x10,%esp
  800739:	eb 03                	jmp    80073e <vprintfmt+0x453>
  80073b:	83 ef 01             	sub    $0x1,%edi
  80073e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800742:	75 f7                	jne    80073b <vprintfmt+0x450>
  800744:	e9 c8 fb ff ff       	jmp    800311 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800749:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80074c:	5b                   	pop    %ebx
  80074d:	5e                   	pop    %esi
  80074e:	5f                   	pop    %edi
  80074f:	5d                   	pop    %ebp
  800750:	c3                   	ret    

00800751 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800751:	55                   	push   %ebp
  800752:	89 e5                	mov    %esp,%ebp
  800754:	83 ec 18             	sub    $0x18,%esp
  800757:	8b 45 08             	mov    0x8(%ebp),%eax
  80075a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80075d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800760:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800764:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800767:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80076e:	85 c0                	test   %eax,%eax
  800770:	74 26                	je     800798 <vsnprintf+0x47>
  800772:	85 d2                	test   %edx,%edx
  800774:	7e 22                	jle    800798 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800776:	ff 75 14             	pushl  0x14(%ebp)
  800779:	ff 75 10             	pushl  0x10(%ebp)
  80077c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80077f:	50                   	push   %eax
  800780:	68 b1 02 80 00       	push   $0x8002b1
  800785:	e8 61 fb ff ff       	call   8002eb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80078a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80078d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800790:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800793:	83 c4 10             	add    $0x10,%esp
  800796:	eb 05                	jmp    80079d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800798:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80079d:	c9                   	leave  
  80079e:	c3                   	ret    

0080079f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80079f:	55                   	push   %ebp
  8007a0:	89 e5                	mov    %esp,%ebp
  8007a2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007a5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007a8:	50                   	push   %eax
  8007a9:	ff 75 10             	pushl  0x10(%ebp)
  8007ac:	ff 75 0c             	pushl  0xc(%ebp)
  8007af:	ff 75 08             	pushl  0x8(%ebp)
  8007b2:	e8 9a ff ff ff       	call   800751 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007b7:	c9                   	leave  
  8007b8:	c3                   	ret    

008007b9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007b9:	55                   	push   %ebp
  8007ba:	89 e5                	mov    %esp,%ebp
  8007bc:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c4:	eb 03                	jmp    8007c9 <strlen+0x10>
		n++;
  8007c6:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007cd:	75 f7                	jne    8007c6 <strlen+0xd>
		n++;
	return n;
}
  8007cf:	5d                   	pop    %ebp
  8007d0:	c3                   	ret    

008007d1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007d1:	55                   	push   %ebp
  8007d2:	89 e5                	mov    %esp,%ebp
  8007d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d7:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007da:	ba 00 00 00 00       	mov    $0x0,%edx
  8007df:	eb 03                	jmp    8007e4 <strnlen+0x13>
		n++;
  8007e1:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e4:	39 c2                	cmp    %eax,%edx
  8007e6:	74 08                	je     8007f0 <strnlen+0x1f>
  8007e8:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007ec:	75 f3                	jne    8007e1 <strnlen+0x10>
  8007ee:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007f0:	5d                   	pop    %ebp
  8007f1:	c3                   	ret    

008007f2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	53                   	push   %ebx
  8007f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007fc:	89 c2                	mov    %eax,%edx
  8007fe:	83 c2 01             	add    $0x1,%edx
  800801:	83 c1 01             	add    $0x1,%ecx
  800804:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800808:	88 5a ff             	mov    %bl,-0x1(%edx)
  80080b:	84 db                	test   %bl,%bl
  80080d:	75 ef                	jne    8007fe <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80080f:	5b                   	pop    %ebx
  800810:	5d                   	pop    %ebp
  800811:	c3                   	ret    

00800812 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	53                   	push   %ebx
  800816:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800819:	53                   	push   %ebx
  80081a:	e8 9a ff ff ff       	call   8007b9 <strlen>
  80081f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800822:	ff 75 0c             	pushl  0xc(%ebp)
  800825:	01 d8                	add    %ebx,%eax
  800827:	50                   	push   %eax
  800828:	e8 c5 ff ff ff       	call   8007f2 <strcpy>
	return dst;
}
  80082d:	89 d8                	mov    %ebx,%eax
  80082f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800832:	c9                   	leave  
  800833:	c3                   	ret    

00800834 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
  800837:	56                   	push   %esi
  800838:	53                   	push   %ebx
  800839:	8b 75 08             	mov    0x8(%ebp),%esi
  80083c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80083f:	89 f3                	mov    %esi,%ebx
  800841:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800844:	89 f2                	mov    %esi,%edx
  800846:	eb 0f                	jmp    800857 <strncpy+0x23>
		*dst++ = *src;
  800848:	83 c2 01             	add    $0x1,%edx
  80084b:	0f b6 01             	movzbl (%ecx),%eax
  80084e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800851:	80 39 01             	cmpb   $0x1,(%ecx)
  800854:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800857:	39 da                	cmp    %ebx,%edx
  800859:	75 ed                	jne    800848 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80085b:	89 f0                	mov    %esi,%eax
  80085d:	5b                   	pop    %ebx
  80085e:	5e                   	pop    %esi
  80085f:	5d                   	pop    %ebp
  800860:	c3                   	ret    

00800861 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800861:	55                   	push   %ebp
  800862:	89 e5                	mov    %esp,%ebp
  800864:	56                   	push   %esi
  800865:	53                   	push   %ebx
  800866:	8b 75 08             	mov    0x8(%ebp),%esi
  800869:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80086c:	8b 55 10             	mov    0x10(%ebp),%edx
  80086f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800871:	85 d2                	test   %edx,%edx
  800873:	74 21                	je     800896 <strlcpy+0x35>
  800875:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800879:	89 f2                	mov    %esi,%edx
  80087b:	eb 09                	jmp    800886 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80087d:	83 c2 01             	add    $0x1,%edx
  800880:	83 c1 01             	add    $0x1,%ecx
  800883:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800886:	39 c2                	cmp    %eax,%edx
  800888:	74 09                	je     800893 <strlcpy+0x32>
  80088a:	0f b6 19             	movzbl (%ecx),%ebx
  80088d:	84 db                	test   %bl,%bl
  80088f:	75 ec                	jne    80087d <strlcpy+0x1c>
  800891:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800893:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800896:	29 f0                	sub    %esi,%eax
}
  800898:	5b                   	pop    %ebx
  800899:	5e                   	pop    %esi
  80089a:	5d                   	pop    %ebp
  80089b:	c3                   	ret    

0080089c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a5:	eb 06                	jmp    8008ad <strcmp+0x11>
		p++, q++;
  8008a7:	83 c1 01             	add    $0x1,%ecx
  8008aa:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008ad:	0f b6 01             	movzbl (%ecx),%eax
  8008b0:	84 c0                	test   %al,%al
  8008b2:	74 04                	je     8008b8 <strcmp+0x1c>
  8008b4:	3a 02                	cmp    (%edx),%al
  8008b6:	74 ef                	je     8008a7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b8:	0f b6 c0             	movzbl %al,%eax
  8008bb:	0f b6 12             	movzbl (%edx),%edx
  8008be:	29 d0                	sub    %edx,%eax
}
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	53                   	push   %ebx
  8008c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cc:	89 c3                	mov    %eax,%ebx
  8008ce:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008d1:	eb 06                	jmp    8008d9 <strncmp+0x17>
		n--, p++, q++;
  8008d3:	83 c0 01             	add    $0x1,%eax
  8008d6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008d9:	39 d8                	cmp    %ebx,%eax
  8008db:	74 15                	je     8008f2 <strncmp+0x30>
  8008dd:	0f b6 08             	movzbl (%eax),%ecx
  8008e0:	84 c9                	test   %cl,%cl
  8008e2:	74 04                	je     8008e8 <strncmp+0x26>
  8008e4:	3a 0a                	cmp    (%edx),%cl
  8008e6:	74 eb                	je     8008d3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e8:	0f b6 00             	movzbl (%eax),%eax
  8008eb:	0f b6 12             	movzbl (%edx),%edx
  8008ee:	29 d0                	sub    %edx,%eax
  8008f0:	eb 05                	jmp    8008f7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008f2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008f7:	5b                   	pop    %ebx
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800900:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800904:	eb 07                	jmp    80090d <strchr+0x13>
		if (*s == c)
  800906:	38 ca                	cmp    %cl,%dl
  800908:	74 0f                	je     800919 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80090a:	83 c0 01             	add    $0x1,%eax
  80090d:	0f b6 10             	movzbl (%eax),%edx
  800910:	84 d2                	test   %dl,%dl
  800912:	75 f2                	jne    800906 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800914:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    

0080091b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	8b 45 08             	mov    0x8(%ebp),%eax
  800921:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800925:	eb 03                	jmp    80092a <strfind+0xf>
  800927:	83 c0 01             	add    $0x1,%eax
  80092a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80092d:	38 ca                	cmp    %cl,%dl
  80092f:	74 04                	je     800935 <strfind+0x1a>
  800931:	84 d2                	test   %dl,%dl
  800933:	75 f2                	jne    800927 <strfind+0xc>
			break;
	return (char *) s;
}
  800935:	5d                   	pop    %ebp
  800936:	c3                   	ret    

00800937 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	57                   	push   %edi
  80093b:	56                   	push   %esi
  80093c:	53                   	push   %ebx
  80093d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800940:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800943:	85 c9                	test   %ecx,%ecx
  800945:	74 36                	je     80097d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800947:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80094d:	75 28                	jne    800977 <memset+0x40>
  80094f:	f6 c1 03             	test   $0x3,%cl
  800952:	75 23                	jne    800977 <memset+0x40>
		c &= 0xFF;
  800954:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800958:	89 d3                	mov    %edx,%ebx
  80095a:	c1 e3 08             	shl    $0x8,%ebx
  80095d:	89 d6                	mov    %edx,%esi
  80095f:	c1 e6 18             	shl    $0x18,%esi
  800962:	89 d0                	mov    %edx,%eax
  800964:	c1 e0 10             	shl    $0x10,%eax
  800967:	09 f0                	or     %esi,%eax
  800969:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80096b:	89 d8                	mov    %ebx,%eax
  80096d:	09 d0                	or     %edx,%eax
  80096f:	c1 e9 02             	shr    $0x2,%ecx
  800972:	fc                   	cld    
  800973:	f3 ab                	rep stos %eax,%es:(%edi)
  800975:	eb 06                	jmp    80097d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800977:	8b 45 0c             	mov    0xc(%ebp),%eax
  80097a:	fc                   	cld    
  80097b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80097d:	89 f8                	mov    %edi,%eax
  80097f:	5b                   	pop    %ebx
  800980:	5e                   	pop    %esi
  800981:	5f                   	pop    %edi
  800982:	5d                   	pop    %ebp
  800983:	c3                   	ret    

00800984 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	57                   	push   %edi
  800988:	56                   	push   %esi
  800989:	8b 45 08             	mov    0x8(%ebp),%eax
  80098c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80098f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800992:	39 c6                	cmp    %eax,%esi
  800994:	73 35                	jae    8009cb <memmove+0x47>
  800996:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800999:	39 d0                	cmp    %edx,%eax
  80099b:	73 2e                	jae    8009cb <memmove+0x47>
		s += n;
		d += n;
  80099d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a0:	89 d6                	mov    %edx,%esi
  8009a2:	09 fe                	or     %edi,%esi
  8009a4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009aa:	75 13                	jne    8009bf <memmove+0x3b>
  8009ac:	f6 c1 03             	test   $0x3,%cl
  8009af:	75 0e                	jne    8009bf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009b1:	83 ef 04             	sub    $0x4,%edi
  8009b4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009b7:	c1 e9 02             	shr    $0x2,%ecx
  8009ba:	fd                   	std    
  8009bb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009bd:	eb 09                	jmp    8009c8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009bf:	83 ef 01             	sub    $0x1,%edi
  8009c2:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009c5:	fd                   	std    
  8009c6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c8:	fc                   	cld    
  8009c9:	eb 1d                	jmp    8009e8 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009cb:	89 f2                	mov    %esi,%edx
  8009cd:	09 c2                	or     %eax,%edx
  8009cf:	f6 c2 03             	test   $0x3,%dl
  8009d2:	75 0f                	jne    8009e3 <memmove+0x5f>
  8009d4:	f6 c1 03             	test   $0x3,%cl
  8009d7:	75 0a                	jne    8009e3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8009d9:	c1 e9 02             	shr    $0x2,%ecx
  8009dc:	89 c7                	mov    %eax,%edi
  8009de:	fc                   	cld    
  8009df:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e1:	eb 05                	jmp    8009e8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e3:	89 c7                	mov    %eax,%edi
  8009e5:	fc                   	cld    
  8009e6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e8:	5e                   	pop    %esi
  8009e9:	5f                   	pop    %edi
  8009ea:	5d                   	pop    %ebp
  8009eb:	c3                   	ret    

008009ec <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009ef:	ff 75 10             	pushl  0x10(%ebp)
  8009f2:	ff 75 0c             	pushl  0xc(%ebp)
  8009f5:	ff 75 08             	pushl  0x8(%ebp)
  8009f8:	e8 87 ff ff ff       	call   800984 <memmove>
}
  8009fd:	c9                   	leave  
  8009fe:	c3                   	ret    

008009ff <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	56                   	push   %esi
  800a03:	53                   	push   %ebx
  800a04:	8b 45 08             	mov    0x8(%ebp),%eax
  800a07:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a0a:	89 c6                	mov    %eax,%esi
  800a0c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a0f:	eb 1a                	jmp    800a2b <memcmp+0x2c>
		if (*s1 != *s2)
  800a11:	0f b6 08             	movzbl (%eax),%ecx
  800a14:	0f b6 1a             	movzbl (%edx),%ebx
  800a17:	38 d9                	cmp    %bl,%cl
  800a19:	74 0a                	je     800a25 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a1b:	0f b6 c1             	movzbl %cl,%eax
  800a1e:	0f b6 db             	movzbl %bl,%ebx
  800a21:	29 d8                	sub    %ebx,%eax
  800a23:	eb 0f                	jmp    800a34 <memcmp+0x35>
		s1++, s2++;
  800a25:	83 c0 01             	add    $0x1,%eax
  800a28:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a2b:	39 f0                	cmp    %esi,%eax
  800a2d:	75 e2                	jne    800a11 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a2f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a34:	5b                   	pop    %ebx
  800a35:	5e                   	pop    %esi
  800a36:	5d                   	pop    %ebp
  800a37:	c3                   	ret    

00800a38 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a38:	55                   	push   %ebp
  800a39:	89 e5                	mov    %esp,%ebp
  800a3b:	53                   	push   %ebx
  800a3c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a3f:	89 c1                	mov    %eax,%ecx
  800a41:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a44:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a48:	eb 0a                	jmp    800a54 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a4a:	0f b6 10             	movzbl (%eax),%edx
  800a4d:	39 da                	cmp    %ebx,%edx
  800a4f:	74 07                	je     800a58 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a51:	83 c0 01             	add    $0x1,%eax
  800a54:	39 c8                	cmp    %ecx,%eax
  800a56:	72 f2                	jb     800a4a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a58:	5b                   	pop    %ebx
  800a59:	5d                   	pop    %ebp
  800a5a:	c3                   	ret    

00800a5b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	57                   	push   %edi
  800a5f:	56                   	push   %esi
  800a60:	53                   	push   %ebx
  800a61:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a64:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a67:	eb 03                	jmp    800a6c <strtol+0x11>
		s++;
  800a69:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6c:	0f b6 01             	movzbl (%ecx),%eax
  800a6f:	3c 20                	cmp    $0x20,%al
  800a71:	74 f6                	je     800a69 <strtol+0xe>
  800a73:	3c 09                	cmp    $0x9,%al
  800a75:	74 f2                	je     800a69 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a77:	3c 2b                	cmp    $0x2b,%al
  800a79:	75 0a                	jne    800a85 <strtol+0x2a>
		s++;
  800a7b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a7e:	bf 00 00 00 00       	mov    $0x0,%edi
  800a83:	eb 11                	jmp    800a96 <strtol+0x3b>
  800a85:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a8a:	3c 2d                	cmp    $0x2d,%al
  800a8c:	75 08                	jne    800a96 <strtol+0x3b>
		s++, neg = 1;
  800a8e:	83 c1 01             	add    $0x1,%ecx
  800a91:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a96:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a9c:	75 15                	jne    800ab3 <strtol+0x58>
  800a9e:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa1:	75 10                	jne    800ab3 <strtol+0x58>
  800aa3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aa7:	75 7c                	jne    800b25 <strtol+0xca>
		s += 2, base = 16;
  800aa9:	83 c1 02             	add    $0x2,%ecx
  800aac:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab1:	eb 16                	jmp    800ac9 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800ab3:	85 db                	test   %ebx,%ebx
  800ab5:	75 12                	jne    800ac9 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ab7:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800abc:	80 39 30             	cmpb   $0x30,(%ecx)
  800abf:	75 08                	jne    800ac9 <strtol+0x6e>
		s++, base = 8;
  800ac1:	83 c1 01             	add    $0x1,%ecx
  800ac4:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800ac9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ace:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ad1:	0f b6 11             	movzbl (%ecx),%edx
  800ad4:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ad7:	89 f3                	mov    %esi,%ebx
  800ad9:	80 fb 09             	cmp    $0x9,%bl
  800adc:	77 08                	ja     800ae6 <strtol+0x8b>
			dig = *s - '0';
  800ade:	0f be d2             	movsbl %dl,%edx
  800ae1:	83 ea 30             	sub    $0x30,%edx
  800ae4:	eb 22                	jmp    800b08 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ae6:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ae9:	89 f3                	mov    %esi,%ebx
  800aeb:	80 fb 19             	cmp    $0x19,%bl
  800aee:	77 08                	ja     800af8 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800af0:	0f be d2             	movsbl %dl,%edx
  800af3:	83 ea 57             	sub    $0x57,%edx
  800af6:	eb 10                	jmp    800b08 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800af8:	8d 72 bf             	lea    -0x41(%edx),%esi
  800afb:	89 f3                	mov    %esi,%ebx
  800afd:	80 fb 19             	cmp    $0x19,%bl
  800b00:	77 16                	ja     800b18 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b02:	0f be d2             	movsbl %dl,%edx
  800b05:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b08:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b0b:	7d 0b                	jge    800b18 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b0d:	83 c1 01             	add    $0x1,%ecx
  800b10:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b14:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b16:	eb b9                	jmp    800ad1 <strtol+0x76>

	if (endptr)
  800b18:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b1c:	74 0d                	je     800b2b <strtol+0xd0>
		*endptr = (char *) s;
  800b1e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b21:	89 0e                	mov    %ecx,(%esi)
  800b23:	eb 06                	jmp    800b2b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b25:	85 db                	test   %ebx,%ebx
  800b27:	74 98                	je     800ac1 <strtol+0x66>
  800b29:	eb 9e                	jmp    800ac9 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b2b:	89 c2                	mov    %eax,%edx
  800b2d:	f7 da                	neg    %edx
  800b2f:	85 ff                	test   %edi,%edi
  800b31:	0f 45 c2             	cmovne %edx,%eax
}
  800b34:	5b                   	pop    %ebx
  800b35:	5e                   	pop    %esi
  800b36:	5f                   	pop    %edi
  800b37:	5d                   	pop    %ebp
  800b38:	c3                   	ret    

00800b39 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	57                   	push   %edi
  800b3d:	56                   	push   %esi
  800b3e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b47:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4a:	89 c3                	mov    %eax,%ebx
  800b4c:	89 c7                	mov    %eax,%edi
  800b4e:	89 c6                	mov    %eax,%esi
  800b50:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b52:	5b                   	pop    %ebx
  800b53:	5e                   	pop    %esi
  800b54:	5f                   	pop    %edi
  800b55:	5d                   	pop    %ebp
  800b56:	c3                   	ret    

00800b57 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
  800b5a:	57                   	push   %edi
  800b5b:	56                   	push   %esi
  800b5c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b5d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b62:	b8 01 00 00 00       	mov    $0x1,%eax
  800b67:	89 d1                	mov    %edx,%ecx
  800b69:	89 d3                	mov    %edx,%ebx
  800b6b:	89 d7                	mov    %edx,%edi
  800b6d:	89 d6                	mov    %edx,%esi
  800b6f:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b71:	5b                   	pop    %ebx
  800b72:	5e                   	pop    %esi
  800b73:	5f                   	pop    %edi
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    

00800b76 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	57                   	push   %edi
  800b7a:	56                   	push   %esi
  800b7b:	53                   	push   %ebx
  800b7c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b84:	b8 03 00 00 00       	mov    $0x3,%eax
  800b89:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8c:	89 cb                	mov    %ecx,%ebx
  800b8e:	89 cf                	mov    %ecx,%edi
  800b90:	89 ce                	mov    %ecx,%esi
  800b92:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800b94:	85 c0                	test   %eax,%eax
  800b96:	7e 17                	jle    800baf <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b98:	83 ec 0c             	sub    $0xc,%esp
  800b9b:	50                   	push   %eax
  800b9c:	6a 03                	push   $0x3
  800b9e:	68 bf 22 80 00       	push   $0x8022bf
  800ba3:	6a 23                	push   $0x23
  800ba5:	68 dc 22 80 00       	push   $0x8022dc
  800baa:	e8 66 f5 ff ff       	call   800115 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800baf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb2:	5b                   	pop    %ebx
  800bb3:	5e                   	pop    %esi
  800bb4:	5f                   	pop    %edi
  800bb5:	5d                   	pop    %ebp
  800bb6:	c3                   	ret    

00800bb7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bb7:	55                   	push   %ebp
  800bb8:	89 e5                	mov    %esp,%ebp
  800bba:	57                   	push   %edi
  800bbb:	56                   	push   %esi
  800bbc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbd:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc2:	b8 02 00 00 00       	mov    $0x2,%eax
  800bc7:	89 d1                	mov    %edx,%ecx
  800bc9:	89 d3                	mov    %edx,%ebx
  800bcb:	89 d7                	mov    %edx,%edi
  800bcd:	89 d6                	mov    %edx,%esi
  800bcf:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bd1:	5b                   	pop    %ebx
  800bd2:	5e                   	pop    %esi
  800bd3:	5f                   	pop    %edi
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    

00800bd6 <sys_yield>:

void
sys_yield(void)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	57                   	push   %edi
  800bda:	56                   	push   %esi
  800bdb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdc:	ba 00 00 00 00       	mov    $0x0,%edx
  800be1:	b8 0b 00 00 00       	mov    $0xb,%eax
  800be6:	89 d1                	mov    %edx,%ecx
  800be8:	89 d3                	mov    %edx,%ebx
  800bea:	89 d7                	mov    %edx,%edi
  800bec:	89 d6                	mov    %edx,%esi
  800bee:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bf0:	5b                   	pop    %ebx
  800bf1:	5e                   	pop    %esi
  800bf2:	5f                   	pop    %edi
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	57                   	push   %edi
  800bf9:	56                   	push   %esi
  800bfa:	53                   	push   %ebx
  800bfb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfe:	be 00 00 00 00       	mov    $0x0,%esi
  800c03:	b8 04 00 00 00       	mov    $0x4,%eax
  800c08:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c11:	89 f7                	mov    %esi,%edi
  800c13:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c15:	85 c0                	test   %eax,%eax
  800c17:	7e 17                	jle    800c30 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c19:	83 ec 0c             	sub    $0xc,%esp
  800c1c:	50                   	push   %eax
  800c1d:	6a 04                	push   $0x4
  800c1f:	68 bf 22 80 00       	push   $0x8022bf
  800c24:	6a 23                	push   $0x23
  800c26:	68 dc 22 80 00       	push   $0x8022dc
  800c2b:	e8 e5 f4 ff ff       	call   800115 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c33:	5b                   	pop    %ebx
  800c34:	5e                   	pop    %esi
  800c35:	5f                   	pop    %edi
  800c36:	5d                   	pop    %ebp
  800c37:	c3                   	ret    

00800c38 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c38:	55                   	push   %ebp
  800c39:	89 e5                	mov    %esp,%ebp
  800c3b:	57                   	push   %edi
  800c3c:	56                   	push   %esi
  800c3d:	53                   	push   %ebx
  800c3e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c41:	b8 05 00 00 00       	mov    $0x5,%eax
  800c46:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c49:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c4f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c52:	8b 75 18             	mov    0x18(%ebp),%esi
  800c55:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c57:	85 c0                	test   %eax,%eax
  800c59:	7e 17                	jle    800c72 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5b:	83 ec 0c             	sub    $0xc,%esp
  800c5e:	50                   	push   %eax
  800c5f:	6a 05                	push   $0x5
  800c61:	68 bf 22 80 00       	push   $0x8022bf
  800c66:	6a 23                	push   $0x23
  800c68:	68 dc 22 80 00       	push   $0x8022dc
  800c6d:	e8 a3 f4 ff ff       	call   800115 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c72:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c75:	5b                   	pop    %ebx
  800c76:	5e                   	pop    %esi
  800c77:	5f                   	pop    %edi
  800c78:	5d                   	pop    %ebp
  800c79:	c3                   	ret    

00800c7a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c7a:	55                   	push   %ebp
  800c7b:	89 e5                	mov    %esp,%ebp
  800c7d:	57                   	push   %edi
  800c7e:	56                   	push   %esi
  800c7f:	53                   	push   %ebx
  800c80:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c83:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c88:	b8 06 00 00 00       	mov    $0x6,%eax
  800c8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c90:	8b 55 08             	mov    0x8(%ebp),%edx
  800c93:	89 df                	mov    %ebx,%edi
  800c95:	89 de                	mov    %ebx,%esi
  800c97:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c99:	85 c0                	test   %eax,%eax
  800c9b:	7e 17                	jle    800cb4 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9d:	83 ec 0c             	sub    $0xc,%esp
  800ca0:	50                   	push   %eax
  800ca1:	6a 06                	push   $0x6
  800ca3:	68 bf 22 80 00       	push   $0x8022bf
  800ca8:	6a 23                	push   $0x23
  800caa:	68 dc 22 80 00       	push   $0x8022dc
  800caf:	e8 61 f4 ff ff       	call   800115 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb7:	5b                   	pop    %ebx
  800cb8:	5e                   	pop    %esi
  800cb9:	5f                   	pop    %edi
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    

00800cbc <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	57                   	push   %edi
  800cc0:	56                   	push   %esi
  800cc1:	53                   	push   %ebx
  800cc2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cca:	b8 08 00 00 00       	mov    $0x8,%eax
  800ccf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd5:	89 df                	mov    %ebx,%edi
  800cd7:	89 de                	mov    %ebx,%esi
  800cd9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cdb:	85 c0                	test   %eax,%eax
  800cdd:	7e 17                	jle    800cf6 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdf:	83 ec 0c             	sub    $0xc,%esp
  800ce2:	50                   	push   %eax
  800ce3:	6a 08                	push   $0x8
  800ce5:	68 bf 22 80 00       	push   $0x8022bf
  800cea:	6a 23                	push   $0x23
  800cec:	68 dc 22 80 00       	push   $0x8022dc
  800cf1:	e8 1f f4 ff ff       	call   800115 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cf6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf9:	5b                   	pop    %ebx
  800cfa:	5e                   	pop    %esi
  800cfb:	5f                   	pop    %edi
  800cfc:	5d                   	pop    %ebp
  800cfd:	c3                   	ret    

00800cfe <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cfe:	55                   	push   %ebp
  800cff:	89 e5                	mov    %esp,%ebp
  800d01:	57                   	push   %edi
  800d02:	56                   	push   %esi
  800d03:	53                   	push   %ebx
  800d04:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d07:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0c:	b8 09 00 00 00       	mov    $0x9,%eax
  800d11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d14:	8b 55 08             	mov    0x8(%ebp),%edx
  800d17:	89 df                	mov    %ebx,%edi
  800d19:	89 de                	mov    %ebx,%esi
  800d1b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d1d:	85 c0                	test   %eax,%eax
  800d1f:	7e 17                	jle    800d38 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d21:	83 ec 0c             	sub    $0xc,%esp
  800d24:	50                   	push   %eax
  800d25:	6a 09                	push   $0x9
  800d27:	68 bf 22 80 00       	push   $0x8022bf
  800d2c:	6a 23                	push   $0x23
  800d2e:	68 dc 22 80 00       	push   $0x8022dc
  800d33:	e8 dd f3 ff ff       	call   800115 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3b:	5b                   	pop    %ebx
  800d3c:	5e                   	pop    %esi
  800d3d:	5f                   	pop    %edi
  800d3e:	5d                   	pop    %ebp
  800d3f:	c3                   	ret    

00800d40 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	57                   	push   %edi
  800d44:	56                   	push   %esi
  800d45:	53                   	push   %ebx
  800d46:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d49:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d4e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d56:	8b 55 08             	mov    0x8(%ebp),%edx
  800d59:	89 df                	mov    %ebx,%edi
  800d5b:	89 de                	mov    %ebx,%esi
  800d5d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d5f:	85 c0                	test   %eax,%eax
  800d61:	7e 17                	jle    800d7a <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d63:	83 ec 0c             	sub    $0xc,%esp
  800d66:	50                   	push   %eax
  800d67:	6a 0a                	push   $0xa
  800d69:	68 bf 22 80 00       	push   $0x8022bf
  800d6e:	6a 23                	push   $0x23
  800d70:	68 dc 22 80 00       	push   $0x8022dc
  800d75:	e8 9b f3 ff ff       	call   800115 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7d:	5b                   	pop    %ebx
  800d7e:	5e                   	pop    %esi
  800d7f:	5f                   	pop    %edi
  800d80:	5d                   	pop    %ebp
  800d81:	c3                   	ret    

00800d82 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d82:	55                   	push   %ebp
  800d83:	89 e5                	mov    %esp,%ebp
  800d85:	57                   	push   %edi
  800d86:	56                   	push   %esi
  800d87:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d88:	be 00 00 00 00       	mov    $0x0,%esi
  800d8d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d95:	8b 55 08             	mov    0x8(%ebp),%edx
  800d98:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d9b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d9e:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800da0:	5b                   	pop    %ebx
  800da1:	5e                   	pop    %esi
  800da2:	5f                   	pop    %edi
  800da3:	5d                   	pop    %ebp
  800da4:	c3                   	ret    

00800da5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800da5:	55                   	push   %ebp
  800da6:	89 e5                	mov    %esp,%ebp
  800da8:	57                   	push   %edi
  800da9:	56                   	push   %esi
  800daa:	53                   	push   %ebx
  800dab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dae:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db3:	b8 0d 00 00 00       	mov    $0xd,%eax
  800db8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbb:	89 cb                	mov    %ecx,%ebx
  800dbd:	89 cf                	mov    %ecx,%edi
  800dbf:	89 ce                	mov    %ecx,%esi
  800dc1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dc3:	85 c0                	test   %eax,%eax
  800dc5:	7e 17                	jle    800dde <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc7:	83 ec 0c             	sub    $0xc,%esp
  800dca:	50                   	push   %eax
  800dcb:	6a 0d                	push   $0xd
  800dcd:	68 bf 22 80 00       	push   $0x8022bf
  800dd2:	6a 23                	push   $0x23
  800dd4:	68 dc 22 80 00       	push   $0x8022dc
  800dd9:	e8 37 f3 ff ff       	call   800115 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de1:	5b                   	pop    %ebx
  800de2:	5e                   	pop    %esi
  800de3:	5f                   	pop    %edi
  800de4:	5d                   	pop    %ebp
  800de5:	c3                   	ret    

00800de6 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800de6:	55                   	push   %ebp
  800de7:	89 e5                	mov    %esp,%ebp
  800de9:	53                   	push   %ebx
  800dea:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  800ded:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800df4:	75 28                	jne    800e1e <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		void *va = (void *) (UXSTACKTOP - PGSIZE);
		envid_t envid = sys_getenvid();
  800df6:	e8 bc fd ff ff       	call   800bb7 <sys_getenvid>
  800dfb:	89 c3                	mov    %eax,%ebx

		sys_page_alloc(envid, va, PTE_P | PTE_U | PTE_W);
  800dfd:	83 ec 04             	sub    $0x4,%esp
  800e00:	6a 07                	push   $0x7
  800e02:	68 00 f0 bf ee       	push   $0xeebff000
  800e07:	50                   	push   %eax
  800e08:	e8 e8 fd ff ff       	call   800bf5 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  800e0d:	83 c4 08             	add    $0x8,%esp
  800e10:	68 2b 0e 80 00       	push   $0x800e2b
  800e15:	53                   	push   %ebx
  800e16:	e8 25 ff ff ff       	call   800d40 <sys_env_set_pgfault_upcall>
  800e1b:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e21:	a3 08 40 80 00       	mov    %eax,0x804008
}
  800e26:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e29:	c9                   	leave  
  800e2a:	c3                   	ret    

00800e2b <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp				// function argument: pointer to UTF
  800e2b:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e2c:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800e31:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e33:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp, %ebx		// 40 = size between utf_fault_va ~ utf_regs
  800e36:	89 e3                	mov    %esp,%ebx
	movl 40(%esp), %eax // point to utf_eip
  800e38:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %esp // point to utf_esp
  800e3c:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax 			// push eip of utf
  800e40:	50                   	push   %eax

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx, %esp 	// back to origin exception stack
  800e41:	89 dc                	mov    %ebx,%esp
	subl $4, 48(%esp) 	// utf_esp - 4
  800e43:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	popl %eax  			// pop utf_fault_va (ignore)
  800e48:	58                   	pop    %eax
	popl %eax  			// pop utf_err (ignore)
  800e49:	58                   	pop    %eax
	popal 				// pop utf_regs 
  800e4a:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4, %esp 		// ignore utf_eip
  800e4b:	83 c4 04             	add    $0x4,%esp
	popfl 				// restore utf_eflags to eflags
  800e4e:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp  			// restore %esp = utf_esp
  800e4f:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800e50:	c3                   	ret    

00800e51 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e51:	55                   	push   %ebp
  800e52:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e54:	8b 45 08             	mov    0x8(%ebp),%eax
  800e57:	05 00 00 00 30       	add    $0x30000000,%eax
  800e5c:	c1 e8 0c             	shr    $0xc,%eax
}
  800e5f:	5d                   	pop    %ebp
  800e60:	c3                   	ret    

00800e61 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e61:	55                   	push   %ebp
  800e62:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e64:	8b 45 08             	mov    0x8(%ebp),%eax
  800e67:	05 00 00 00 30       	add    $0x30000000,%eax
  800e6c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e71:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e76:	5d                   	pop    %ebp
  800e77:	c3                   	ret    

00800e78 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e78:	55                   	push   %ebp
  800e79:	89 e5                	mov    %esp,%ebp
  800e7b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e7e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e83:	89 c2                	mov    %eax,%edx
  800e85:	c1 ea 16             	shr    $0x16,%edx
  800e88:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e8f:	f6 c2 01             	test   $0x1,%dl
  800e92:	74 11                	je     800ea5 <fd_alloc+0x2d>
  800e94:	89 c2                	mov    %eax,%edx
  800e96:	c1 ea 0c             	shr    $0xc,%edx
  800e99:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ea0:	f6 c2 01             	test   $0x1,%dl
  800ea3:	75 09                	jne    800eae <fd_alloc+0x36>
			*fd_store = fd;
  800ea5:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ea7:	b8 00 00 00 00       	mov    $0x0,%eax
  800eac:	eb 17                	jmp    800ec5 <fd_alloc+0x4d>
  800eae:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800eb3:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800eb8:	75 c9                	jne    800e83 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800eba:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800ec0:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800ec5:	5d                   	pop    %ebp
  800ec6:	c3                   	ret    

00800ec7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ec7:	55                   	push   %ebp
  800ec8:	89 e5                	mov    %esp,%ebp
  800eca:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ecd:	83 f8 1f             	cmp    $0x1f,%eax
  800ed0:	77 36                	ja     800f08 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ed2:	c1 e0 0c             	shl    $0xc,%eax
  800ed5:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800eda:	89 c2                	mov    %eax,%edx
  800edc:	c1 ea 16             	shr    $0x16,%edx
  800edf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ee6:	f6 c2 01             	test   $0x1,%dl
  800ee9:	74 24                	je     800f0f <fd_lookup+0x48>
  800eeb:	89 c2                	mov    %eax,%edx
  800eed:	c1 ea 0c             	shr    $0xc,%edx
  800ef0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ef7:	f6 c2 01             	test   $0x1,%dl
  800efa:	74 1a                	je     800f16 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800efc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eff:	89 02                	mov    %eax,(%edx)
	return 0;
  800f01:	b8 00 00 00 00       	mov    $0x0,%eax
  800f06:	eb 13                	jmp    800f1b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f08:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f0d:	eb 0c                	jmp    800f1b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f0f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f14:	eb 05                	jmp    800f1b <fd_lookup+0x54>
  800f16:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f1b:	5d                   	pop    %ebp
  800f1c:	c3                   	ret    

00800f1d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f1d:	55                   	push   %ebp
  800f1e:	89 e5                	mov    %esp,%ebp
  800f20:	83 ec 08             	sub    $0x8,%esp
  800f23:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f26:	ba 6c 23 80 00       	mov    $0x80236c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f2b:	eb 13                	jmp    800f40 <dev_lookup+0x23>
  800f2d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f30:	39 08                	cmp    %ecx,(%eax)
  800f32:	75 0c                	jne    800f40 <dev_lookup+0x23>
			*dev = devtab[i];
  800f34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f37:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f39:	b8 00 00 00 00       	mov    $0x0,%eax
  800f3e:	eb 2e                	jmp    800f6e <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f40:	8b 02                	mov    (%edx),%eax
  800f42:	85 c0                	test   %eax,%eax
  800f44:	75 e7                	jne    800f2d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f46:	a1 04 40 80 00       	mov    0x804004,%eax
  800f4b:	8b 40 48             	mov    0x48(%eax),%eax
  800f4e:	83 ec 04             	sub    $0x4,%esp
  800f51:	51                   	push   %ecx
  800f52:	50                   	push   %eax
  800f53:	68 ec 22 80 00       	push   $0x8022ec
  800f58:	e8 91 f2 ff ff       	call   8001ee <cprintf>
	*dev = 0;
  800f5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f60:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f66:	83 c4 10             	add    $0x10,%esp
  800f69:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f6e:	c9                   	leave  
  800f6f:	c3                   	ret    

00800f70 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f70:	55                   	push   %ebp
  800f71:	89 e5                	mov    %esp,%ebp
  800f73:	56                   	push   %esi
  800f74:	53                   	push   %ebx
  800f75:	83 ec 10             	sub    $0x10,%esp
  800f78:	8b 75 08             	mov    0x8(%ebp),%esi
  800f7b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f7e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f81:	50                   	push   %eax
  800f82:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f88:	c1 e8 0c             	shr    $0xc,%eax
  800f8b:	50                   	push   %eax
  800f8c:	e8 36 ff ff ff       	call   800ec7 <fd_lookup>
  800f91:	83 c4 08             	add    $0x8,%esp
  800f94:	85 c0                	test   %eax,%eax
  800f96:	78 05                	js     800f9d <fd_close+0x2d>
	    || fd != fd2)
  800f98:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f9b:	74 0c                	je     800fa9 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f9d:	84 db                	test   %bl,%bl
  800f9f:	ba 00 00 00 00       	mov    $0x0,%edx
  800fa4:	0f 44 c2             	cmove  %edx,%eax
  800fa7:	eb 41                	jmp    800fea <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800fa9:	83 ec 08             	sub    $0x8,%esp
  800fac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800faf:	50                   	push   %eax
  800fb0:	ff 36                	pushl  (%esi)
  800fb2:	e8 66 ff ff ff       	call   800f1d <dev_lookup>
  800fb7:	89 c3                	mov    %eax,%ebx
  800fb9:	83 c4 10             	add    $0x10,%esp
  800fbc:	85 c0                	test   %eax,%eax
  800fbe:	78 1a                	js     800fda <fd_close+0x6a>
		if (dev->dev_close)
  800fc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fc3:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800fc6:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800fcb:	85 c0                	test   %eax,%eax
  800fcd:	74 0b                	je     800fda <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800fcf:	83 ec 0c             	sub    $0xc,%esp
  800fd2:	56                   	push   %esi
  800fd3:	ff d0                	call   *%eax
  800fd5:	89 c3                	mov    %eax,%ebx
  800fd7:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fda:	83 ec 08             	sub    $0x8,%esp
  800fdd:	56                   	push   %esi
  800fde:	6a 00                	push   $0x0
  800fe0:	e8 95 fc ff ff       	call   800c7a <sys_page_unmap>
	return r;
  800fe5:	83 c4 10             	add    $0x10,%esp
  800fe8:	89 d8                	mov    %ebx,%eax
}
  800fea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fed:	5b                   	pop    %ebx
  800fee:	5e                   	pop    %esi
  800fef:	5d                   	pop    %ebp
  800ff0:	c3                   	ret    

00800ff1 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800ff1:	55                   	push   %ebp
  800ff2:	89 e5                	mov    %esp,%ebp
  800ff4:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ff7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ffa:	50                   	push   %eax
  800ffb:	ff 75 08             	pushl  0x8(%ebp)
  800ffe:	e8 c4 fe ff ff       	call   800ec7 <fd_lookup>
  801003:	83 c4 08             	add    $0x8,%esp
  801006:	85 c0                	test   %eax,%eax
  801008:	78 10                	js     80101a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80100a:	83 ec 08             	sub    $0x8,%esp
  80100d:	6a 01                	push   $0x1
  80100f:	ff 75 f4             	pushl  -0xc(%ebp)
  801012:	e8 59 ff ff ff       	call   800f70 <fd_close>
  801017:	83 c4 10             	add    $0x10,%esp
}
  80101a:	c9                   	leave  
  80101b:	c3                   	ret    

0080101c <close_all>:

void
close_all(void)
{
  80101c:	55                   	push   %ebp
  80101d:	89 e5                	mov    %esp,%ebp
  80101f:	53                   	push   %ebx
  801020:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801023:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801028:	83 ec 0c             	sub    $0xc,%esp
  80102b:	53                   	push   %ebx
  80102c:	e8 c0 ff ff ff       	call   800ff1 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801031:	83 c3 01             	add    $0x1,%ebx
  801034:	83 c4 10             	add    $0x10,%esp
  801037:	83 fb 20             	cmp    $0x20,%ebx
  80103a:	75 ec                	jne    801028 <close_all+0xc>
		close(i);
}
  80103c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80103f:	c9                   	leave  
  801040:	c3                   	ret    

00801041 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801041:	55                   	push   %ebp
  801042:	89 e5                	mov    %esp,%ebp
  801044:	57                   	push   %edi
  801045:	56                   	push   %esi
  801046:	53                   	push   %ebx
  801047:	83 ec 2c             	sub    $0x2c,%esp
  80104a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80104d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801050:	50                   	push   %eax
  801051:	ff 75 08             	pushl  0x8(%ebp)
  801054:	e8 6e fe ff ff       	call   800ec7 <fd_lookup>
  801059:	83 c4 08             	add    $0x8,%esp
  80105c:	85 c0                	test   %eax,%eax
  80105e:	0f 88 c1 00 00 00    	js     801125 <dup+0xe4>
		return r;
	close(newfdnum);
  801064:	83 ec 0c             	sub    $0xc,%esp
  801067:	56                   	push   %esi
  801068:	e8 84 ff ff ff       	call   800ff1 <close>

	newfd = INDEX2FD(newfdnum);
  80106d:	89 f3                	mov    %esi,%ebx
  80106f:	c1 e3 0c             	shl    $0xc,%ebx
  801072:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801078:	83 c4 04             	add    $0x4,%esp
  80107b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80107e:	e8 de fd ff ff       	call   800e61 <fd2data>
  801083:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801085:	89 1c 24             	mov    %ebx,(%esp)
  801088:	e8 d4 fd ff ff       	call   800e61 <fd2data>
  80108d:	83 c4 10             	add    $0x10,%esp
  801090:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801093:	89 f8                	mov    %edi,%eax
  801095:	c1 e8 16             	shr    $0x16,%eax
  801098:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80109f:	a8 01                	test   $0x1,%al
  8010a1:	74 37                	je     8010da <dup+0x99>
  8010a3:	89 f8                	mov    %edi,%eax
  8010a5:	c1 e8 0c             	shr    $0xc,%eax
  8010a8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8010af:	f6 c2 01             	test   $0x1,%dl
  8010b2:	74 26                	je     8010da <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010b4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010bb:	83 ec 0c             	sub    $0xc,%esp
  8010be:	25 07 0e 00 00       	and    $0xe07,%eax
  8010c3:	50                   	push   %eax
  8010c4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010c7:	6a 00                	push   $0x0
  8010c9:	57                   	push   %edi
  8010ca:	6a 00                	push   $0x0
  8010cc:	e8 67 fb ff ff       	call   800c38 <sys_page_map>
  8010d1:	89 c7                	mov    %eax,%edi
  8010d3:	83 c4 20             	add    $0x20,%esp
  8010d6:	85 c0                	test   %eax,%eax
  8010d8:	78 2e                	js     801108 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010da:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010dd:	89 d0                	mov    %edx,%eax
  8010df:	c1 e8 0c             	shr    $0xc,%eax
  8010e2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010e9:	83 ec 0c             	sub    $0xc,%esp
  8010ec:	25 07 0e 00 00       	and    $0xe07,%eax
  8010f1:	50                   	push   %eax
  8010f2:	53                   	push   %ebx
  8010f3:	6a 00                	push   $0x0
  8010f5:	52                   	push   %edx
  8010f6:	6a 00                	push   $0x0
  8010f8:	e8 3b fb ff ff       	call   800c38 <sys_page_map>
  8010fd:	89 c7                	mov    %eax,%edi
  8010ff:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801102:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801104:	85 ff                	test   %edi,%edi
  801106:	79 1d                	jns    801125 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801108:	83 ec 08             	sub    $0x8,%esp
  80110b:	53                   	push   %ebx
  80110c:	6a 00                	push   $0x0
  80110e:	e8 67 fb ff ff       	call   800c7a <sys_page_unmap>
	sys_page_unmap(0, nva);
  801113:	83 c4 08             	add    $0x8,%esp
  801116:	ff 75 d4             	pushl  -0x2c(%ebp)
  801119:	6a 00                	push   $0x0
  80111b:	e8 5a fb ff ff       	call   800c7a <sys_page_unmap>
	return r;
  801120:	83 c4 10             	add    $0x10,%esp
  801123:	89 f8                	mov    %edi,%eax
}
  801125:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801128:	5b                   	pop    %ebx
  801129:	5e                   	pop    %esi
  80112a:	5f                   	pop    %edi
  80112b:	5d                   	pop    %ebp
  80112c:	c3                   	ret    

0080112d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80112d:	55                   	push   %ebp
  80112e:	89 e5                	mov    %esp,%ebp
  801130:	53                   	push   %ebx
  801131:	83 ec 14             	sub    $0x14,%esp
  801134:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801137:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80113a:	50                   	push   %eax
  80113b:	53                   	push   %ebx
  80113c:	e8 86 fd ff ff       	call   800ec7 <fd_lookup>
  801141:	83 c4 08             	add    $0x8,%esp
  801144:	89 c2                	mov    %eax,%edx
  801146:	85 c0                	test   %eax,%eax
  801148:	78 6d                	js     8011b7 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80114a:	83 ec 08             	sub    $0x8,%esp
  80114d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801150:	50                   	push   %eax
  801151:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801154:	ff 30                	pushl  (%eax)
  801156:	e8 c2 fd ff ff       	call   800f1d <dev_lookup>
  80115b:	83 c4 10             	add    $0x10,%esp
  80115e:	85 c0                	test   %eax,%eax
  801160:	78 4c                	js     8011ae <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801162:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801165:	8b 42 08             	mov    0x8(%edx),%eax
  801168:	83 e0 03             	and    $0x3,%eax
  80116b:	83 f8 01             	cmp    $0x1,%eax
  80116e:	75 21                	jne    801191 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801170:	a1 04 40 80 00       	mov    0x804004,%eax
  801175:	8b 40 48             	mov    0x48(%eax),%eax
  801178:	83 ec 04             	sub    $0x4,%esp
  80117b:	53                   	push   %ebx
  80117c:	50                   	push   %eax
  80117d:	68 30 23 80 00       	push   $0x802330
  801182:	e8 67 f0 ff ff       	call   8001ee <cprintf>
		return -E_INVAL;
  801187:	83 c4 10             	add    $0x10,%esp
  80118a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80118f:	eb 26                	jmp    8011b7 <read+0x8a>
	}
	if (!dev->dev_read)
  801191:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801194:	8b 40 08             	mov    0x8(%eax),%eax
  801197:	85 c0                	test   %eax,%eax
  801199:	74 17                	je     8011b2 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80119b:	83 ec 04             	sub    $0x4,%esp
  80119e:	ff 75 10             	pushl  0x10(%ebp)
  8011a1:	ff 75 0c             	pushl  0xc(%ebp)
  8011a4:	52                   	push   %edx
  8011a5:	ff d0                	call   *%eax
  8011a7:	89 c2                	mov    %eax,%edx
  8011a9:	83 c4 10             	add    $0x10,%esp
  8011ac:	eb 09                	jmp    8011b7 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ae:	89 c2                	mov    %eax,%edx
  8011b0:	eb 05                	jmp    8011b7 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011b2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8011b7:	89 d0                	mov    %edx,%eax
  8011b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011bc:	c9                   	leave  
  8011bd:	c3                   	ret    

008011be <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011be:	55                   	push   %ebp
  8011bf:	89 e5                	mov    %esp,%ebp
  8011c1:	57                   	push   %edi
  8011c2:	56                   	push   %esi
  8011c3:	53                   	push   %ebx
  8011c4:	83 ec 0c             	sub    $0xc,%esp
  8011c7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011ca:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011cd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011d2:	eb 21                	jmp    8011f5 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011d4:	83 ec 04             	sub    $0x4,%esp
  8011d7:	89 f0                	mov    %esi,%eax
  8011d9:	29 d8                	sub    %ebx,%eax
  8011db:	50                   	push   %eax
  8011dc:	89 d8                	mov    %ebx,%eax
  8011de:	03 45 0c             	add    0xc(%ebp),%eax
  8011e1:	50                   	push   %eax
  8011e2:	57                   	push   %edi
  8011e3:	e8 45 ff ff ff       	call   80112d <read>
		if (m < 0)
  8011e8:	83 c4 10             	add    $0x10,%esp
  8011eb:	85 c0                	test   %eax,%eax
  8011ed:	78 10                	js     8011ff <readn+0x41>
			return m;
		if (m == 0)
  8011ef:	85 c0                	test   %eax,%eax
  8011f1:	74 0a                	je     8011fd <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011f3:	01 c3                	add    %eax,%ebx
  8011f5:	39 f3                	cmp    %esi,%ebx
  8011f7:	72 db                	jb     8011d4 <readn+0x16>
  8011f9:	89 d8                	mov    %ebx,%eax
  8011fb:	eb 02                	jmp    8011ff <readn+0x41>
  8011fd:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801202:	5b                   	pop    %ebx
  801203:	5e                   	pop    %esi
  801204:	5f                   	pop    %edi
  801205:	5d                   	pop    %ebp
  801206:	c3                   	ret    

00801207 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801207:	55                   	push   %ebp
  801208:	89 e5                	mov    %esp,%ebp
  80120a:	53                   	push   %ebx
  80120b:	83 ec 14             	sub    $0x14,%esp
  80120e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801211:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801214:	50                   	push   %eax
  801215:	53                   	push   %ebx
  801216:	e8 ac fc ff ff       	call   800ec7 <fd_lookup>
  80121b:	83 c4 08             	add    $0x8,%esp
  80121e:	89 c2                	mov    %eax,%edx
  801220:	85 c0                	test   %eax,%eax
  801222:	78 68                	js     80128c <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801224:	83 ec 08             	sub    $0x8,%esp
  801227:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80122a:	50                   	push   %eax
  80122b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80122e:	ff 30                	pushl  (%eax)
  801230:	e8 e8 fc ff ff       	call   800f1d <dev_lookup>
  801235:	83 c4 10             	add    $0x10,%esp
  801238:	85 c0                	test   %eax,%eax
  80123a:	78 47                	js     801283 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80123c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80123f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801243:	75 21                	jne    801266 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801245:	a1 04 40 80 00       	mov    0x804004,%eax
  80124a:	8b 40 48             	mov    0x48(%eax),%eax
  80124d:	83 ec 04             	sub    $0x4,%esp
  801250:	53                   	push   %ebx
  801251:	50                   	push   %eax
  801252:	68 4c 23 80 00       	push   $0x80234c
  801257:	e8 92 ef ff ff       	call   8001ee <cprintf>
		return -E_INVAL;
  80125c:	83 c4 10             	add    $0x10,%esp
  80125f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801264:	eb 26                	jmp    80128c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801266:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801269:	8b 52 0c             	mov    0xc(%edx),%edx
  80126c:	85 d2                	test   %edx,%edx
  80126e:	74 17                	je     801287 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801270:	83 ec 04             	sub    $0x4,%esp
  801273:	ff 75 10             	pushl  0x10(%ebp)
  801276:	ff 75 0c             	pushl  0xc(%ebp)
  801279:	50                   	push   %eax
  80127a:	ff d2                	call   *%edx
  80127c:	89 c2                	mov    %eax,%edx
  80127e:	83 c4 10             	add    $0x10,%esp
  801281:	eb 09                	jmp    80128c <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801283:	89 c2                	mov    %eax,%edx
  801285:	eb 05                	jmp    80128c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801287:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80128c:	89 d0                	mov    %edx,%eax
  80128e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801291:	c9                   	leave  
  801292:	c3                   	ret    

00801293 <seek>:

int
seek(int fdnum, off_t offset)
{
  801293:	55                   	push   %ebp
  801294:	89 e5                	mov    %esp,%ebp
  801296:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801299:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80129c:	50                   	push   %eax
  80129d:	ff 75 08             	pushl  0x8(%ebp)
  8012a0:	e8 22 fc ff ff       	call   800ec7 <fd_lookup>
  8012a5:	83 c4 08             	add    $0x8,%esp
  8012a8:	85 c0                	test   %eax,%eax
  8012aa:	78 0e                	js     8012ba <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8012ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012b2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012ba:	c9                   	leave  
  8012bb:	c3                   	ret    

008012bc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012bc:	55                   	push   %ebp
  8012bd:	89 e5                	mov    %esp,%ebp
  8012bf:	53                   	push   %ebx
  8012c0:	83 ec 14             	sub    $0x14,%esp
  8012c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012c9:	50                   	push   %eax
  8012ca:	53                   	push   %ebx
  8012cb:	e8 f7 fb ff ff       	call   800ec7 <fd_lookup>
  8012d0:	83 c4 08             	add    $0x8,%esp
  8012d3:	89 c2                	mov    %eax,%edx
  8012d5:	85 c0                	test   %eax,%eax
  8012d7:	78 65                	js     80133e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012d9:	83 ec 08             	sub    $0x8,%esp
  8012dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012df:	50                   	push   %eax
  8012e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e3:	ff 30                	pushl  (%eax)
  8012e5:	e8 33 fc ff ff       	call   800f1d <dev_lookup>
  8012ea:	83 c4 10             	add    $0x10,%esp
  8012ed:	85 c0                	test   %eax,%eax
  8012ef:	78 44                	js     801335 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012f8:	75 21                	jne    80131b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012fa:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012ff:	8b 40 48             	mov    0x48(%eax),%eax
  801302:	83 ec 04             	sub    $0x4,%esp
  801305:	53                   	push   %ebx
  801306:	50                   	push   %eax
  801307:	68 0c 23 80 00       	push   $0x80230c
  80130c:	e8 dd ee ff ff       	call   8001ee <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801311:	83 c4 10             	add    $0x10,%esp
  801314:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801319:	eb 23                	jmp    80133e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80131b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80131e:	8b 52 18             	mov    0x18(%edx),%edx
  801321:	85 d2                	test   %edx,%edx
  801323:	74 14                	je     801339 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801325:	83 ec 08             	sub    $0x8,%esp
  801328:	ff 75 0c             	pushl  0xc(%ebp)
  80132b:	50                   	push   %eax
  80132c:	ff d2                	call   *%edx
  80132e:	89 c2                	mov    %eax,%edx
  801330:	83 c4 10             	add    $0x10,%esp
  801333:	eb 09                	jmp    80133e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801335:	89 c2                	mov    %eax,%edx
  801337:	eb 05                	jmp    80133e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801339:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80133e:	89 d0                	mov    %edx,%eax
  801340:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801343:	c9                   	leave  
  801344:	c3                   	ret    

00801345 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801345:	55                   	push   %ebp
  801346:	89 e5                	mov    %esp,%ebp
  801348:	53                   	push   %ebx
  801349:	83 ec 14             	sub    $0x14,%esp
  80134c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80134f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801352:	50                   	push   %eax
  801353:	ff 75 08             	pushl  0x8(%ebp)
  801356:	e8 6c fb ff ff       	call   800ec7 <fd_lookup>
  80135b:	83 c4 08             	add    $0x8,%esp
  80135e:	89 c2                	mov    %eax,%edx
  801360:	85 c0                	test   %eax,%eax
  801362:	78 58                	js     8013bc <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801364:	83 ec 08             	sub    $0x8,%esp
  801367:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80136a:	50                   	push   %eax
  80136b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80136e:	ff 30                	pushl  (%eax)
  801370:	e8 a8 fb ff ff       	call   800f1d <dev_lookup>
  801375:	83 c4 10             	add    $0x10,%esp
  801378:	85 c0                	test   %eax,%eax
  80137a:	78 37                	js     8013b3 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80137c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80137f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801383:	74 32                	je     8013b7 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801385:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801388:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80138f:	00 00 00 
	stat->st_isdir = 0;
  801392:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801399:	00 00 00 
	stat->st_dev = dev;
  80139c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013a2:	83 ec 08             	sub    $0x8,%esp
  8013a5:	53                   	push   %ebx
  8013a6:	ff 75 f0             	pushl  -0x10(%ebp)
  8013a9:	ff 50 14             	call   *0x14(%eax)
  8013ac:	89 c2                	mov    %eax,%edx
  8013ae:	83 c4 10             	add    $0x10,%esp
  8013b1:	eb 09                	jmp    8013bc <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013b3:	89 c2                	mov    %eax,%edx
  8013b5:	eb 05                	jmp    8013bc <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013b7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013bc:	89 d0                	mov    %edx,%eax
  8013be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c1:	c9                   	leave  
  8013c2:	c3                   	ret    

008013c3 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013c3:	55                   	push   %ebp
  8013c4:	89 e5                	mov    %esp,%ebp
  8013c6:	56                   	push   %esi
  8013c7:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013c8:	83 ec 08             	sub    $0x8,%esp
  8013cb:	6a 00                	push   $0x0
  8013cd:	ff 75 08             	pushl  0x8(%ebp)
  8013d0:	e8 e3 01 00 00       	call   8015b8 <open>
  8013d5:	89 c3                	mov    %eax,%ebx
  8013d7:	83 c4 10             	add    $0x10,%esp
  8013da:	85 c0                	test   %eax,%eax
  8013dc:	78 1b                	js     8013f9 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013de:	83 ec 08             	sub    $0x8,%esp
  8013e1:	ff 75 0c             	pushl  0xc(%ebp)
  8013e4:	50                   	push   %eax
  8013e5:	e8 5b ff ff ff       	call   801345 <fstat>
  8013ea:	89 c6                	mov    %eax,%esi
	close(fd);
  8013ec:	89 1c 24             	mov    %ebx,(%esp)
  8013ef:	e8 fd fb ff ff       	call   800ff1 <close>
	return r;
  8013f4:	83 c4 10             	add    $0x10,%esp
  8013f7:	89 f0                	mov    %esi,%eax
}
  8013f9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013fc:	5b                   	pop    %ebx
  8013fd:	5e                   	pop    %esi
  8013fe:	5d                   	pop    %ebp
  8013ff:	c3                   	ret    

00801400 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801400:	55                   	push   %ebp
  801401:	89 e5                	mov    %esp,%ebp
  801403:	56                   	push   %esi
  801404:	53                   	push   %ebx
  801405:	89 c6                	mov    %eax,%esi
  801407:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801409:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801410:	75 12                	jne    801424 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801412:	83 ec 0c             	sub    $0xc,%esp
  801415:	6a 01                	push   $0x1
  801417:	e8 e5 07 00 00       	call   801c01 <ipc_find_env>
  80141c:	a3 00 40 80 00       	mov    %eax,0x804000
  801421:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801424:	6a 07                	push   $0x7
  801426:	68 00 50 80 00       	push   $0x805000
  80142b:	56                   	push   %esi
  80142c:	ff 35 00 40 80 00    	pushl  0x804000
  801432:	e8 76 07 00 00       	call   801bad <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801437:	83 c4 0c             	add    $0xc,%esp
  80143a:	6a 00                	push   $0x0
  80143c:	53                   	push   %ebx
  80143d:	6a 00                	push   $0x0
  80143f:	e8 f7 06 00 00       	call   801b3b <ipc_recv>
}
  801444:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801447:	5b                   	pop    %ebx
  801448:	5e                   	pop    %esi
  801449:	5d                   	pop    %ebp
  80144a:	c3                   	ret    

0080144b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80144b:	55                   	push   %ebp
  80144c:	89 e5                	mov    %esp,%ebp
  80144e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801451:	8b 45 08             	mov    0x8(%ebp),%eax
  801454:	8b 40 0c             	mov    0xc(%eax),%eax
  801457:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80145c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80145f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801464:	ba 00 00 00 00       	mov    $0x0,%edx
  801469:	b8 02 00 00 00       	mov    $0x2,%eax
  80146e:	e8 8d ff ff ff       	call   801400 <fsipc>
}
  801473:	c9                   	leave  
  801474:	c3                   	ret    

00801475 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801475:	55                   	push   %ebp
  801476:	89 e5                	mov    %esp,%ebp
  801478:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80147b:	8b 45 08             	mov    0x8(%ebp),%eax
  80147e:	8b 40 0c             	mov    0xc(%eax),%eax
  801481:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801486:	ba 00 00 00 00       	mov    $0x0,%edx
  80148b:	b8 06 00 00 00       	mov    $0x6,%eax
  801490:	e8 6b ff ff ff       	call   801400 <fsipc>
}
  801495:	c9                   	leave  
  801496:	c3                   	ret    

00801497 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801497:	55                   	push   %ebp
  801498:	89 e5                	mov    %esp,%ebp
  80149a:	53                   	push   %ebx
  80149b:	83 ec 04             	sub    $0x4,%esp
  80149e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a4:	8b 40 0c             	mov    0xc(%eax),%eax
  8014a7:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8014b1:	b8 05 00 00 00       	mov    $0x5,%eax
  8014b6:	e8 45 ff ff ff       	call   801400 <fsipc>
  8014bb:	85 c0                	test   %eax,%eax
  8014bd:	78 2c                	js     8014eb <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014bf:	83 ec 08             	sub    $0x8,%esp
  8014c2:	68 00 50 80 00       	push   $0x805000
  8014c7:	53                   	push   %ebx
  8014c8:	e8 25 f3 ff ff       	call   8007f2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014cd:	a1 80 50 80 00       	mov    0x805080,%eax
  8014d2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014d8:	a1 84 50 80 00       	mov    0x805084,%eax
  8014dd:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014e3:	83 c4 10             	add    $0x10,%esp
  8014e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ee:	c9                   	leave  
  8014ef:	c3                   	ret    

008014f0 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014f0:	55                   	push   %ebp
  8014f1:	89 e5                	mov    %esp,%ebp
  8014f3:	83 ec 0c             	sub    $0xc,%esp
  8014f6:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	
	int r;

	n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  8014f9:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8014fe:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801503:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801506:	8b 55 08             	mov    0x8(%ebp),%edx
  801509:	8b 52 0c             	mov    0xc(%edx),%edx
  80150c:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801512:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801517:	50                   	push   %eax
  801518:	ff 75 0c             	pushl  0xc(%ebp)
  80151b:	68 08 50 80 00       	push   $0x805008
  801520:	e8 5f f4 ff ff       	call   800984 <memmove>
	
	return fsipc(FSREQ_WRITE, NULL);	
  801525:	ba 00 00 00 00       	mov    $0x0,%edx
  80152a:	b8 04 00 00 00       	mov    $0x4,%eax
  80152f:	e8 cc fe ff ff       	call   801400 <fsipc>
}
  801534:	c9                   	leave  
  801535:	c3                   	ret    

00801536 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801536:	55                   	push   %ebp
  801537:	89 e5                	mov    %esp,%ebp
  801539:	56                   	push   %esi
  80153a:	53                   	push   %ebx
  80153b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80153e:	8b 45 08             	mov    0x8(%ebp),%eax
  801541:	8b 40 0c             	mov    0xc(%eax),%eax
  801544:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801549:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80154f:	ba 00 00 00 00       	mov    $0x0,%edx
  801554:	b8 03 00 00 00       	mov    $0x3,%eax
  801559:	e8 a2 fe ff ff       	call   801400 <fsipc>
  80155e:	89 c3                	mov    %eax,%ebx
  801560:	85 c0                	test   %eax,%eax
  801562:	78 4b                	js     8015af <devfile_read+0x79>
		return r;
	assert(r <= n);
  801564:	39 c6                	cmp    %eax,%esi
  801566:	73 16                	jae    80157e <devfile_read+0x48>
  801568:	68 7c 23 80 00       	push   $0x80237c
  80156d:	68 83 23 80 00       	push   $0x802383
  801572:	6a 7c                	push   $0x7c
  801574:	68 98 23 80 00       	push   $0x802398
  801579:	e8 97 eb ff ff       	call   800115 <_panic>
	assert(r <= PGSIZE);
  80157e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801583:	7e 16                	jle    80159b <devfile_read+0x65>
  801585:	68 a3 23 80 00       	push   $0x8023a3
  80158a:	68 83 23 80 00       	push   $0x802383
  80158f:	6a 7d                	push   $0x7d
  801591:	68 98 23 80 00       	push   $0x802398
  801596:	e8 7a eb ff ff       	call   800115 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80159b:	83 ec 04             	sub    $0x4,%esp
  80159e:	50                   	push   %eax
  80159f:	68 00 50 80 00       	push   $0x805000
  8015a4:	ff 75 0c             	pushl  0xc(%ebp)
  8015a7:	e8 d8 f3 ff ff       	call   800984 <memmove>
	return r;
  8015ac:	83 c4 10             	add    $0x10,%esp
}
  8015af:	89 d8                	mov    %ebx,%eax
  8015b1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015b4:	5b                   	pop    %ebx
  8015b5:	5e                   	pop    %esi
  8015b6:	5d                   	pop    %ebp
  8015b7:	c3                   	ret    

008015b8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015b8:	55                   	push   %ebp
  8015b9:	89 e5                	mov    %esp,%ebp
  8015bb:	53                   	push   %ebx
  8015bc:	83 ec 20             	sub    $0x20,%esp
  8015bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015c2:	53                   	push   %ebx
  8015c3:	e8 f1 f1 ff ff       	call   8007b9 <strlen>
  8015c8:	83 c4 10             	add    $0x10,%esp
  8015cb:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015d0:	7f 67                	jg     801639 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015d2:	83 ec 0c             	sub    $0xc,%esp
  8015d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d8:	50                   	push   %eax
  8015d9:	e8 9a f8 ff ff       	call   800e78 <fd_alloc>
  8015de:	83 c4 10             	add    $0x10,%esp
		return r;
  8015e1:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015e3:	85 c0                	test   %eax,%eax
  8015e5:	78 57                	js     80163e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015e7:	83 ec 08             	sub    $0x8,%esp
  8015ea:	53                   	push   %ebx
  8015eb:	68 00 50 80 00       	push   $0x805000
  8015f0:	e8 fd f1 ff ff       	call   8007f2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015f8:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801600:	b8 01 00 00 00       	mov    $0x1,%eax
  801605:	e8 f6 fd ff ff       	call   801400 <fsipc>
  80160a:	89 c3                	mov    %eax,%ebx
  80160c:	83 c4 10             	add    $0x10,%esp
  80160f:	85 c0                	test   %eax,%eax
  801611:	79 14                	jns    801627 <open+0x6f>
		fd_close(fd, 0);
  801613:	83 ec 08             	sub    $0x8,%esp
  801616:	6a 00                	push   $0x0
  801618:	ff 75 f4             	pushl  -0xc(%ebp)
  80161b:	e8 50 f9 ff ff       	call   800f70 <fd_close>
		return r;
  801620:	83 c4 10             	add    $0x10,%esp
  801623:	89 da                	mov    %ebx,%edx
  801625:	eb 17                	jmp    80163e <open+0x86>
	}

	return fd2num(fd);
  801627:	83 ec 0c             	sub    $0xc,%esp
  80162a:	ff 75 f4             	pushl  -0xc(%ebp)
  80162d:	e8 1f f8 ff ff       	call   800e51 <fd2num>
  801632:	89 c2                	mov    %eax,%edx
  801634:	83 c4 10             	add    $0x10,%esp
  801637:	eb 05                	jmp    80163e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801639:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80163e:	89 d0                	mov    %edx,%eax
  801640:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801643:	c9                   	leave  
  801644:	c3                   	ret    

00801645 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801645:	55                   	push   %ebp
  801646:	89 e5                	mov    %esp,%ebp
  801648:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80164b:	ba 00 00 00 00       	mov    $0x0,%edx
  801650:	b8 08 00 00 00       	mov    $0x8,%eax
  801655:	e8 a6 fd ff ff       	call   801400 <fsipc>
}
  80165a:	c9                   	leave  
  80165b:	c3                   	ret    

0080165c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80165c:	55                   	push   %ebp
  80165d:	89 e5                	mov    %esp,%ebp
  80165f:	56                   	push   %esi
  801660:	53                   	push   %ebx
  801661:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801664:	83 ec 0c             	sub    $0xc,%esp
  801667:	ff 75 08             	pushl  0x8(%ebp)
  80166a:	e8 f2 f7 ff ff       	call   800e61 <fd2data>
  80166f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801671:	83 c4 08             	add    $0x8,%esp
  801674:	68 af 23 80 00       	push   $0x8023af
  801679:	53                   	push   %ebx
  80167a:	e8 73 f1 ff ff       	call   8007f2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80167f:	8b 46 04             	mov    0x4(%esi),%eax
  801682:	2b 06                	sub    (%esi),%eax
  801684:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80168a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801691:	00 00 00 
	stat->st_dev = &devpipe;
  801694:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80169b:	30 80 00 
	return 0;
}
  80169e:	b8 00 00 00 00       	mov    $0x0,%eax
  8016a3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016a6:	5b                   	pop    %ebx
  8016a7:	5e                   	pop    %esi
  8016a8:	5d                   	pop    %ebp
  8016a9:	c3                   	ret    

008016aa <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8016aa:	55                   	push   %ebp
  8016ab:	89 e5                	mov    %esp,%ebp
  8016ad:	53                   	push   %ebx
  8016ae:	83 ec 0c             	sub    $0xc,%esp
  8016b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8016b4:	53                   	push   %ebx
  8016b5:	6a 00                	push   $0x0
  8016b7:	e8 be f5 ff ff       	call   800c7a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8016bc:	89 1c 24             	mov    %ebx,(%esp)
  8016bf:	e8 9d f7 ff ff       	call   800e61 <fd2data>
  8016c4:	83 c4 08             	add    $0x8,%esp
  8016c7:	50                   	push   %eax
  8016c8:	6a 00                	push   $0x0
  8016ca:	e8 ab f5 ff ff       	call   800c7a <sys_page_unmap>
}
  8016cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d2:	c9                   	leave  
  8016d3:	c3                   	ret    

008016d4 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8016d4:	55                   	push   %ebp
  8016d5:	89 e5                	mov    %esp,%ebp
  8016d7:	57                   	push   %edi
  8016d8:	56                   	push   %esi
  8016d9:	53                   	push   %ebx
  8016da:	83 ec 1c             	sub    $0x1c,%esp
  8016dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016e0:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8016e2:	a1 04 40 80 00       	mov    0x804004,%eax
  8016e7:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8016ea:	83 ec 0c             	sub    $0xc,%esp
  8016ed:	ff 75 e0             	pushl  -0x20(%ebp)
  8016f0:	e8 45 05 00 00       	call   801c3a <pageref>
  8016f5:	89 c3                	mov    %eax,%ebx
  8016f7:	89 3c 24             	mov    %edi,(%esp)
  8016fa:	e8 3b 05 00 00       	call   801c3a <pageref>
  8016ff:	83 c4 10             	add    $0x10,%esp
  801702:	39 c3                	cmp    %eax,%ebx
  801704:	0f 94 c1             	sete   %cl
  801707:	0f b6 c9             	movzbl %cl,%ecx
  80170a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80170d:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801713:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801716:	39 ce                	cmp    %ecx,%esi
  801718:	74 1b                	je     801735 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80171a:	39 c3                	cmp    %eax,%ebx
  80171c:	75 c4                	jne    8016e2 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80171e:	8b 42 58             	mov    0x58(%edx),%eax
  801721:	ff 75 e4             	pushl  -0x1c(%ebp)
  801724:	50                   	push   %eax
  801725:	56                   	push   %esi
  801726:	68 b6 23 80 00       	push   $0x8023b6
  80172b:	e8 be ea ff ff       	call   8001ee <cprintf>
  801730:	83 c4 10             	add    $0x10,%esp
  801733:	eb ad                	jmp    8016e2 <_pipeisclosed+0xe>
	}
}
  801735:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801738:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80173b:	5b                   	pop    %ebx
  80173c:	5e                   	pop    %esi
  80173d:	5f                   	pop    %edi
  80173e:	5d                   	pop    %ebp
  80173f:	c3                   	ret    

00801740 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801740:	55                   	push   %ebp
  801741:	89 e5                	mov    %esp,%ebp
  801743:	57                   	push   %edi
  801744:	56                   	push   %esi
  801745:	53                   	push   %ebx
  801746:	83 ec 28             	sub    $0x28,%esp
  801749:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80174c:	56                   	push   %esi
  80174d:	e8 0f f7 ff ff       	call   800e61 <fd2data>
  801752:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801754:	83 c4 10             	add    $0x10,%esp
  801757:	bf 00 00 00 00       	mov    $0x0,%edi
  80175c:	eb 4b                	jmp    8017a9 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80175e:	89 da                	mov    %ebx,%edx
  801760:	89 f0                	mov    %esi,%eax
  801762:	e8 6d ff ff ff       	call   8016d4 <_pipeisclosed>
  801767:	85 c0                	test   %eax,%eax
  801769:	75 48                	jne    8017b3 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80176b:	e8 66 f4 ff ff       	call   800bd6 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801770:	8b 43 04             	mov    0x4(%ebx),%eax
  801773:	8b 0b                	mov    (%ebx),%ecx
  801775:	8d 51 20             	lea    0x20(%ecx),%edx
  801778:	39 d0                	cmp    %edx,%eax
  80177a:	73 e2                	jae    80175e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80177c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80177f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801783:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801786:	89 c2                	mov    %eax,%edx
  801788:	c1 fa 1f             	sar    $0x1f,%edx
  80178b:	89 d1                	mov    %edx,%ecx
  80178d:	c1 e9 1b             	shr    $0x1b,%ecx
  801790:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801793:	83 e2 1f             	and    $0x1f,%edx
  801796:	29 ca                	sub    %ecx,%edx
  801798:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80179c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8017a0:	83 c0 01             	add    $0x1,%eax
  8017a3:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017a6:	83 c7 01             	add    $0x1,%edi
  8017a9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8017ac:	75 c2                	jne    801770 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8017ae:	8b 45 10             	mov    0x10(%ebp),%eax
  8017b1:	eb 05                	jmp    8017b8 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017b3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8017b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017bb:	5b                   	pop    %ebx
  8017bc:	5e                   	pop    %esi
  8017bd:	5f                   	pop    %edi
  8017be:	5d                   	pop    %ebp
  8017bf:	c3                   	ret    

008017c0 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8017c0:	55                   	push   %ebp
  8017c1:	89 e5                	mov    %esp,%ebp
  8017c3:	57                   	push   %edi
  8017c4:	56                   	push   %esi
  8017c5:	53                   	push   %ebx
  8017c6:	83 ec 18             	sub    $0x18,%esp
  8017c9:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8017cc:	57                   	push   %edi
  8017cd:	e8 8f f6 ff ff       	call   800e61 <fd2data>
  8017d2:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017d4:	83 c4 10             	add    $0x10,%esp
  8017d7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017dc:	eb 3d                	jmp    80181b <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8017de:	85 db                	test   %ebx,%ebx
  8017e0:	74 04                	je     8017e6 <devpipe_read+0x26>
				return i;
  8017e2:	89 d8                	mov    %ebx,%eax
  8017e4:	eb 44                	jmp    80182a <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8017e6:	89 f2                	mov    %esi,%edx
  8017e8:	89 f8                	mov    %edi,%eax
  8017ea:	e8 e5 fe ff ff       	call   8016d4 <_pipeisclosed>
  8017ef:	85 c0                	test   %eax,%eax
  8017f1:	75 32                	jne    801825 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8017f3:	e8 de f3 ff ff       	call   800bd6 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8017f8:	8b 06                	mov    (%esi),%eax
  8017fa:	3b 46 04             	cmp    0x4(%esi),%eax
  8017fd:	74 df                	je     8017de <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017ff:	99                   	cltd   
  801800:	c1 ea 1b             	shr    $0x1b,%edx
  801803:	01 d0                	add    %edx,%eax
  801805:	83 e0 1f             	and    $0x1f,%eax
  801808:	29 d0                	sub    %edx,%eax
  80180a:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80180f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801812:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801815:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801818:	83 c3 01             	add    $0x1,%ebx
  80181b:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80181e:	75 d8                	jne    8017f8 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801820:	8b 45 10             	mov    0x10(%ebp),%eax
  801823:	eb 05                	jmp    80182a <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801825:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80182a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80182d:	5b                   	pop    %ebx
  80182e:	5e                   	pop    %esi
  80182f:	5f                   	pop    %edi
  801830:	5d                   	pop    %ebp
  801831:	c3                   	ret    

00801832 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801832:	55                   	push   %ebp
  801833:	89 e5                	mov    %esp,%ebp
  801835:	56                   	push   %esi
  801836:	53                   	push   %ebx
  801837:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80183a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80183d:	50                   	push   %eax
  80183e:	e8 35 f6 ff ff       	call   800e78 <fd_alloc>
  801843:	83 c4 10             	add    $0x10,%esp
  801846:	89 c2                	mov    %eax,%edx
  801848:	85 c0                	test   %eax,%eax
  80184a:	0f 88 2c 01 00 00    	js     80197c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801850:	83 ec 04             	sub    $0x4,%esp
  801853:	68 07 04 00 00       	push   $0x407
  801858:	ff 75 f4             	pushl  -0xc(%ebp)
  80185b:	6a 00                	push   $0x0
  80185d:	e8 93 f3 ff ff       	call   800bf5 <sys_page_alloc>
  801862:	83 c4 10             	add    $0x10,%esp
  801865:	89 c2                	mov    %eax,%edx
  801867:	85 c0                	test   %eax,%eax
  801869:	0f 88 0d 01 00 00    	js     80197c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80186f:	83 ec 0c             	sub    $0xc,%esp
  801872:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801875:	50                   	push   %eax
  801876:	e8 fd f5 ff ff       	call   800e78 <fd_alloc>
  80187b:	89 c3                	mov    %eax,%ebx
  80187d:	83 c4 10             	add    $0x10,%esp
  801880:	85 c0                	test   %eax,%eax
  801882:	0f 88 e2 00 00 00    	js     80196a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801888:	83 ec 04             	sub    $0x4,%esp
  80188b:	68 07 04 00 00       	push   $0x407
  801890:	ff 75 f0             	pushl  -0x10(%ebp)
  801893:	6a 00                	push   $0x0
  801895:	e8 5b f3 ff ff       	call   800bf5 <sys_page_alloc>
  80189a:	89 c3                	mov    %eax,%ebx
  80189c:	83 c4 10             	add    $0x10,%esp
  80189f:	85 c0                	test   %eax,%eax
  8018a1:	0f 88 c3 00 00 00    	js     80196a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8018a7:	83 ec 0c             	sub    $0xc,%esp
  8018aa:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ad:	e8 af f5 ff ff       	call   800e61 <fd2data>
  8018b2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018b4:	83 c4 0c             	add    $0xc,%esp
  8018b7:	68 07 04 00 00       	push   $0x407
  8018bc:	50                   	push   %eax
  8018bd:	6a 00                	push   $0x0
  8018bf:	e8 31 f3 ff ff       	call   800bf5 <sys_page_alloc>
  8018c4:	89 c3                	mov    %eax,%ebx
  8018c6:	83 c4 10             	add    $0x10,%esp
  8018c9:	85 c0                	test   %eax,%eax
  8018cb:	0f 88 89 00 00 00    	js     80195a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018d1:	83 ec 0c             	sub    $0xc,%esp
  8018d4:	ff 75 f0             	pushl  -0x10(%ebp)
  8018d7:	e8 85 f5 ff ff       	call   800e61 <fd2data>
  8018dc:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8018e3:	50                   	push   %eax
  8018e4:	6a 00                	push   $0x0
  8018e6:	56                   	push   %esi
  8018e7:	6a 00                	push   $0x0
  8018e9:	e8 4a f3 ff ff       	call   800c38 <sys_page_map>
  8018ee:	89 c3                	mov    %eax,%ebx
  8018f0:	83 c4 20             	add    $0x20,%esp
  8018f3:	85 c0                	test   %eax,%eax
  8018f5:	78 55                	js     80194c <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8018f7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801900:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801902:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801905:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80190c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801912:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801915:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801917:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80191a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801921:	83 ec 0c             	sub    $0xc,%esp
  801924:	ff 75 f4             	pushl  -0xc(%ebp)
  801927:	e8 25 f5 ff ff       	call   800e51 <fd2num>
  80192c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80192f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801931:	83 c4 04             	add    $0x4,%esp
  801934:	ff 75 f0             	pushl  -0x10(%ebp)
  801937:	e8 15 f5 ff ff       	call   800e51 <fd2num>
  80193c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80193f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801942:	83 c4 10             	add    $0x10,%esp
  801945:	ba 00 00 00 00       	mov    $0x0,%edx
  80194a:	eb 30                	jmp    80197c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80194c:	83 ec 08             	sub    $0x8,%esp
  80194f:	56                   	push   %esi
  801950:	6a 00                	push   $0x0
  801952:	e8 23 f3 ff ff       	call   800c7a <sys_page_unmap>
  801957:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80195a:	83 ec 08             	sub    $0x8,%esp
  80195d:	ff 75 f0             	pushl  -0x10(%ebp)
  801960:	6a 00                	push   $0x0
  801962:	e8 13 f3 ff ff       	call   800c7a <sys_page_unmap>
  801967:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80196a:	83 ec 08             	sub    $0x8,%esp
  80196d:	ff 75 f4             	pushl  -0xc(%ebp)
  801970:	6a 00                	push   $0x0
  801972:	e8 03 f3 ff ff       	call   800c7a <sys_page_unmap>
  801977:	83 c4 10             	add    $0x10,%esp
  80197a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80197c:	89 d0                	mov    %edx,%eax
  80197e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801981:	5b                   	pop    %ebx
  801982:	5e                   	pop    %esi
  801983:	5d                   	pop    %ebp
  801984:	c3                   	ret    

00801985 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801985:	55                   	push   %ebp
  801986:	89 e5                	mov    %esp,%ebp
  801988:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80198b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80198e:	50                   	push   %eax
  80198f:	ff 75 08             	pushl  0x8(%ebp)
  801992:	e8 30 f5 ff ff       	call   800ec7 <fd_lookup>
  801997:	83 c4 10             	add    $0x10,%esp
  80199a:	85 c0                	test   %eax,%eax
  80199c:	78 18                	js     8019b6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80199e:	83 ec 0c             	sub    $0xc,%esp
  8019a1:	ff 75 f4             	pushl  -0xc(%ebp)
  8019a4:	e8 b8 f4 ff ff       	call   800e61 <fd2data>
	return _pipeisclosed(fd, p);
  8019a9:	89 c2                	mov    %eax,%edx
  8019ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ae:	e8 21 fd ff ff       	call   8016d4 <_pipeisclosed>
  8019b3:	83 c4 10             	add    $0x10,%esp
}
  8019b6:	c9                   	leave  
  8019b7:	c3                   	ret    

008019b8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8019b8:	55                   	push   %ebp
  8019b9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8019bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c0:	5d                   	pop    %ebp
  8019c1:	c3                   	ret    

008019c2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8019c2:	55                   	push   %ebp
  8019c3:	89 e5                	mov    %esp,%ebp
  8019c5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8019c8:	68 ce 23 80 00       	push   $0x8023ce
  8019cd:	ff 75 0c             	pushl  0xc(%ebp)
  8019d0:	e8 1d ee ff ff       	call   8007f2 <strcpy>
	return 0;
}
  8019d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8019da:	c9                   	leave  
  8019db:	c3                   	ret    

008019dc <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019dc:	55                   	push   %ebp
  8019dd:	89 e5                	mov    %esp,%ebp
  8019df:	57                   	push   %edi
  8019e0:	56                   	push   %esi
  8019e1:	53                   	push   %ebx
  8019e2:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019e8:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019ed:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019f3:	eb 2d                	jmp    801a22 <devcons_write+0x46>
		m = n - tot;
  8019f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8019f8:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8019fa:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8019fd:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801a02:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a05:	83 ec 04             	sub    $0x4,%esp
  801a08:	53                   	push   %ebx
  801a09:	03 45 0c             	add    0xc(%ebp),%eax
  801a0c:	50                   	push   %eax
  801a0d:	57                   	push   %edi
  801a0e:	e8 71 ef ff ff       	call   800984 <memmove>
		sys_cputs(buf, m);
  801a13:	83 c4 08             	add    $0x8,%esp
  801a16:	53                   	push   %ebx
  801a17:	57                   	push   %edi
  801a18:	e8 1c f1 ff ff       	call   800b39 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a1d:	01 de                	add    %ebx,%esi
  801a1f:	83 c4 10             	add    $0x10,%esp
  801a22:	89 f0                	mov    %esi,%eax
  801a24:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a27:	72 cc                	jb     8019f5 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a2c:	5b                   	pop    %ebx
  801a2d:	5e                   	pop    %esi
  801a2e:	5f                   	pop    %edi
  801a2f:	5d                   	pop    %ebp
  801a30:	c3                   	ret    

00801a31 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a31:	55                   	push   %ebp
  801a32:	89 e5                	mov    %esp,%ebp
  801a34:	83 ec 08             	sub    $0x8,%esp
  801a37:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801a3c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a40:	74 2a                	je     801a6c <devcons_read+0x3b>
  801a42:	eb 05                	jmp    801a49 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a44:	e8 8d f1 ff ff       	call   800bd6 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a49:	e8 09 f1 ff ff       	call   800b57 <sys_cgetc>
  801a4e:	85 c0                	test   %eax,%eax
  801a50:	74 f2                	je     801a44 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801a52:	85 c0                	test   %eax,%eax
  801a54:	78 16                	js     801a6c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a56:	83 f8 04             	cmp    $0x4,%eax
  801a59:	74 0c                	je     801a67 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801a5b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a5e:	88 02                	mov    %al,(%edx)
	return 1;
  801a60:	b8 01 00 00 00       	mov    $0x1,%eax
  801a65:	eb 05                	jmp    801a6c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a67:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a6c:	c9                   	leave  
  801a6d:	c3                   	ret    

00801a6e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a6e:	55                   	push   %ebp
  801a6f:	89 e5                	mov    %esp,%ebp
  801a71:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a74:	8b 45 08             	mov    0x8(%ebp),%eax
  801a77:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a7a:	6a 01                	push   $0x1
  801a7c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a7f:	50                   	push   %eax
  801a80:	e8 b4 f0 ff ff       	call   800b39 <sys_cputs>
}
  801a85:	83 c4 10             	add    $0x10,%esp
  801a88:	c9                   	leave  
  801a89:	c3                   	ret    

00801a8a <getchar>:

int
getchar(void)
{
  801a8a:	55                   	push   %ebp
  801a8b:	89 e5                	mov    %esp,%ebp
  801a8d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a90:	6a 01                	push   $0x1
  801a92:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a95:	50                   	push   %eax
  801a96:	6a 00                	push   $0x0
  801a98:	e8 90 f6 ff ff       	call   80112d <read>
	if (r < 0)
  801a9d:	83 c4 10             	add    $0x10,%esp
  801aa0:	85 c0                	test   %eax,%eax
  801aa2:	78 0f                	js     801ab3 <getchar+0x29>
		return r;
	if (r < 1)
  801aa4:	85 c0                	test   %eax,%eax
  801aa6:	7e 06                	jle    801aae <getchar+0x24>
		return -E_EOF;
	return c;
  801aa8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801aac:	eb 05                	jmp    801ab3 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801aae:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ab3:	c9                   	leave  
  801ab4:	c3                   	ret    

00801ab5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ab5:	55                   	push   %ebp
  801ab6:	89 e5                	mov    %esp,%ebp
  801ab8:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801abb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801abe:	50                   	push   %eax
  801abf:	ff 75 08             	pushl  0x8(%ebp)
  801ac2:	e8 00 f4 ff ff       	call   800ec7 <fd_lookup>
  801ac7:	83 c4 10             	add    $0x10,%esp
  801aca:	85 c0                	test   %eax,%eax
  801acc:	78 11                	js     801adf <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ace:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ad7:	39 10                	cmp    %edx,(%eax)
  801ad9:	0f 94 c0             	sete   %al
  801adc:	0f b6 c0             	movzbl %al,%eax
}
  801adf:	c9                   	leave  
  801ae0:	c3                   	ret    

00801ae1 <opencons>:

int
opencons(void)
{
  801ae1:	55                   	push   %ebp
  801ae2:	89 e5                	mov    %esp,%ebp
  801ae4:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ae7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aea:	50                   	push   %eax
  801aeb:	e8 88 f3 ff ff       	call   800e78 <fd_alloc>
  801af0:	83 c4 10             	add    $0x10,%esp
		return r;
  801af3:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801af5:	85 c0                	test   %eax,%eax
  801af7:	78 3e                	js     801b37 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801af9:	83 ec 04             	sub    $0x4,%esp
  801afc:	68 07 04 00 00       	push   $0x407
  801b01:	ff 75 f4             	pushl  -0xc(%ebp)
  801b04:	6a 00                	push   $0x0
  801b06:	e8 ea f0 ff ff       	call   800bf5 <sys_page_alloc>
  801b0b:	83 c4 10             	add    $0x10,%esp
		return r;
  801b0e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b10:	85 c0                	test   %eax,%eax
  801b12:	78 23                	js     801b37 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801b14:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b1d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b22:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b29:	83 ec 0c             	sub    $0xc,%esp
  801b2c:	50                   	push   %eax
  801b2d:	e8 1f f3 ff ff       	call   800e51 <fd2num>
  801b32:	89 c2                	mov    %eax,%edx
  801b34:	83 c4 10             	add    $0x10,%esp
}
  801b37:	89 d0                	mov    %edx,%eax
  801b39:	c9                   	leave  
  801b3a:	c3                   	ret    

00801b3b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b3b:	55                   	push   %ebp
  801b3c:	89 e5                	mov    %esp,%ebp
  801b3e:	56                   	push   %esi
  801b3f:	53                   	push   %ebx
  801b40:	8b 75 08             	mov    0x8(%ebp),%esi
  801b43:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b46:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

    if (pg != NULL)
  801b49:	85 c0                	test   %eax,%eax
  801b4b:	74 0e                	je     801b5b <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  801b4d:	83 ec 0c             	sub    $0xc,%esp
  801b50:	50                   	push   %eax
  801b51:	e8 4f f2 ff ff       	call   800da5 <sys_ipc_recv>
  801b56:	83 c4 10             	add    $0x10,%esp
  801b59:	eb 0d                	jmp    801b68 <ipc_recv+0x2d>
	else
        r = sys_ipc_recv((void *)-1);
  801b5b:	83 ec 0c             	sub    $0xc,%esp
  801b5e:	6a ff                	push   $0xffffffff
  801b60:	e8 40 f2 ff ff       	call   800da5 <sys_ipc_recv>
  801b65:	83 c4 10             	add    $0x10,%esp

	if (r < 0) {
  801b68:	85 c0                	test   %eax,%eax
  801b6a:	79 16                	jns    801b82 <ipc_recv+0x47>

		if (from_env_store != NULL)
  801b6c:	85 f6                	test   %esi,%esi
  801b6e:	74 06                	je     801b76 <ipc_recv+0x3b>
			*from_env_store = 0;
  801b70:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL)
  801b76:	85 db                	test   %ebx,%ebx
  801b78:	74 2c                	je     801ba6 <ipc_recv+0x6b>
			*perm_store = 0;
  801b7a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b80:	eb 24                	jmp    801ba6 <ipc_recv+0x6b>
		return r;

	} else {

		if (from_env_store != NULL)
  801b82:	85 f6                	test   %esi,%esi
  801b84:	74 0a                	je     801b90 <ipc_recv+0x55>
			*from_env_store = thisenv->env_ipc_from;
  801b86:	a1 04 40 80 00       	mov    0x804004,%eax
  801b8b:	8b 40 74             	mov    0x74(%eax),%eax
  801b8e:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL)
  801b90:	85 db                	test   %ebx,%ebx
  801b92:	74 0a                	je     801b9e <ipc_recv+0x63>
			*perm_store = thisenv->env_ipc_perm;
  801b94:	a1 04 40 80 00       	mov    0x804004,%eax
  801b99:	8b 40 78             	mov    0x78(%eax),%eax
  801b9c:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801b9e:	a1 04 40 80 00       	mov    0x804004,%eax
  801ba3:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801ba6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ba9:	5b                   	pop    %ebx
  801baa:	5e                   	pop    %esi
  801bab:	5d                   	pop    %ebp
  801bac:	c3                   	ret    

00801bad <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bad:	55                   	push   %ebp
  801bae:	89 e5                	mov    %esp,%ebp
  801bb0:	57                   	push   %edi
  801bb1:	56                   	push   %esi
  801bb2:	53                   	push   %ebx
  801bb3:	83 ec 0c             	sub    $0xc,%esp
  801bb6:	8b 7d 08             	mov    0x8(%ebp),%edi
  801bb9:	8b 75 0c             	mov    0xc(%ebp),%esi
  801bbc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

	if (pg == NULL)
  801bbf:	85 db                	test   %ebx,%ebx
		pg = (void *)-1;	
  801bc1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801bc6:	0f 44 d8             	cmove  %eax,%ebx

	while (true) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801bc9:	ff 75 14             	pushl  0x14(%ebp)
  801bcc:	53                   	push   %ebx
  801bcd:	56                   	push   %esi
  801bce:	57                   	push   %edi
  801bcf:	e8 ae f1 ff ff       	call   800d82 <sys_ipc_try_send>
		if (r >= 0)
  801bd4:	83 c4 10             	add    $0x10,%esp
  801bd7:	85 c0                	test   %eax,%eax
  801bd9:	79 1e                	jns    801bf9 <ipc_send+0x4c>
			return;
		else if (r != -E_IPC_NOT_RECV)
  801bdb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801bde:	74 12                	je     801bf2 <ipc_send+0x45>
			panic("ipc_send error: %e", r);
  801be0:	50                   	push   %eax
  801be1:	68 da 23 80 00       	push   $0x8023da
  801be6:	6a 49                	push   $0x49
  801be8:	68 ed 23 80 00       	push   $0x8023ed
  801bed:	e8 23 e5 ff ff       	call   800115 <_panic>
	
		sys_yield();
  801bf2:	e8 df ef ff ff       	call   800bd6 <sys_yield>
	}
  801bf7:	eb d0                	jmp    801bc9 <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  801bf9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bfc:	5b                   	pop    %ebx
  801bfd:	5e                   	pop    %esi
  801bfe:	5f                   	pop    %edi
  801bff:	5d                   	pop    %ebp
  801c00:	c3                   	ret    

00801c01 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c01:	55                   	push   %ebp
  801c02:	89 e5                	mov    %esp,%ebp
  801c04:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c07:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c0c:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c0f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c15:	8b 52 50             	mov    0x50(%edx),%edx
  801c18:	39 ca                	cmp    %ecx,%edx
  801c1a:	75 0d                	jne    801c29 <ipc_find_env+0x28>
			return envs[i].env_id;
  801c1c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c1f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c24:	8b 40 48             	mov    0x48(%eax),%eax
  801c27:	eb 0f                	jmp    801c38 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c29:	83 c0 01             	add    $0x1,%eax
  801c2c:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c31:	75 d9                	jne    801c0c <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c33:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c38:	5d                   	pop    %ebp
  801c39:	c3                   	ret    

00801c3a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c3a:	55                   	push   %ebp
  801c3b:	89 e5                	mov    %esp,%ebp
  801c3d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c40:	89 d0                	mov    %edx,%eax
  801c42:	c1 e8 16             	shr    $0x16,%eax
  801c45:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c4c:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c51:	f6 c1 01             	test   $0x1,%cl
  801c54:	74 1d                	je     801c73 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c56:	c1 ea 0c             	shr    $0xc,%edx
  801c59:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c60:	f6 c2 01             	test   $0x1,%dl
  801c63:	74 0e                	je     801c73 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c65:	c1 ea 0c             	shr    $0xc,%edx
  801c68:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c6f:	ef 
  801c70:	0f b7 c0             	movzwl %ax,%eax
}
  801c73:	5d                   	pop    %ebp
  801c74:	c3                   	ret    
  801c75:	66 90                	xchg   %ax,%ax
  801c77:	66 90                	xchg   %ax,%ax
  801c79:	66 90                	xchg   %ax,%ax
  801c7b:	66 90                	xchg   %ax,%ax
  801c7d:	66 90                	xchg   %ax,%ax
  801c7f:	90                   	nop

00801c80 <__udivdi3>:
  801c80:	55                   	push   %ebp
  801c81:	57                   	push   %edi
  801c82:	56                   	push   %esi
  801c83:	53                   	push   %ebx
  801c84:	83 ec 1c             	sub    $0x1c,%esp
  801c87:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801c8b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c8f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801c93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c97:	85 f6                	test   %esi,%esi
  801c99:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c9d:	89 ca                	mov    %ecx,%edx
  801c9f:	89 f8                	mov    %edi,%eax
  801ca1:	75 3d                	jne    801ce0 <__udivdi3+0x60>
  801ca3:	39 cf                	cmp    %ecx,%edi
  801ca5:	0f 87 c5 00 00 00    	ja     801d70 <__udivdi3+0xf0>
  801cab:	85 ff                	test   %edi,%edi
  801cad:	89 fd                	mov    %edi,%ebp
  801caf:	75 0b                	jne    801cbc <__udivdi3+0x3c>
  801cb1:	b8 01 00 00 00       	mov    $0x1,%eax
  801cb6:	31 d2                	xor    %edx,%edx
  801cb8:	f7 f7                	div    %edi
  801cba:	89 c5                	mov    %eax,%ebp
  801cbc:	89 c8                	mov    %ecx,%eax
  801cbe:	31 d2                	xor    %edx,%edx
  801cc0:	f7 f5                	div    %ebp
  801cc2:	89 c1                	mov    %eax,%ecx
  801cc4:	89 d8                	mov    %ebx,%eax
  801cc6:	89 cf                	mov    %ecx,%edi
  801cc8:	f7 f5                	div    %ebp
  801cca:	89 c3                	mov    %eax,%ebx
  801ccc:	89 d8                	mov    %ebx,%eax
  801cce:	89 fa                	mov    %edi,%edx
  801cd0:	83 c4 1c             	add    $0x1c,%esp
  801cd3:	5b                   	pop    %ebx
  801cd4:	5e                   	pop    %esi
  801cd5:	5f                   	pop    %edi
  801cd6:	5d                   	pop    %ebp
  801cd7:	c3                   	ret    
  801cd8:	90                   	nop
  801cd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ce0:	39 ce                	cmp    %ecx,%esi
  801ce2:	77 74                	ja     801d58 <__udivdi3+0xd8>
  801ce4:	0f bd fe             	bsr    %esi,%edi
  801ce7:	83 f7 1f             	xor    $0x1f,%edi
  801cea:	0f 84 98 00 00 00    	je     801d88 <__udivdi3+0x108>
  801cf0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801cf5:	89 f9                	mov    %edi,%ecx
  801cf7:	89 c5                	mov    %eax,%ebp
  801cf9:	29 fb                	sub    %edi,%ebx
  801cfb:	d3 e6                	shl    %cl,%esi
  801cfd:	89 d9                	mov    %ebx,%ecx
  801cff:	d3 ed                	shr    %cl,%ebp
  801d01:	89 f9                	mov    %edi,%ecx
  801d03:	d3 e0                	shl    %cl,%eax
  801d05:	09 ee                	or     %ebp,%esi
  801d07:	89 d9                	mov    %ebx,%ecx
  801d09:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d0d:	89 d5                	mov    %edx,%ebp
  801d0f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d13:	d3 ed                	shr    %cl,%ebp
  801d15:	89 f9                	mov    %edi,%ecx
  801d17:	d3 e2                	shl    %cl,%edx
  801d19:	89 d9                	mov    %ebx,%ecx
  801d1b:	d3 e8                	shr    %cl,%eax
  801d1d:	09 c2                	or     %eax,%edx
  801d1f:	89 d0                	mov    %edx,%eax
  801d21:	89 ea                	mov    %ebp,%edx
  801d23:	f7 f6                	div    %esi
  801d25:	89 d5                	mov    %edx,%ebp
  801d27:	89 c3                	mov    %eax,%ebx
  801d29:	f7 64 24 0c          	mull   0xc(%esp)
  801d2d:	39 d5                	cmp    %edx,%ebp
  801d2f:	72 10                	jb     801d41 <__udivdi3+0xc1>
  801d31:	8b 74 24 08          	mov    0x8(%esp),%esi
  801d35:	89 f9                	mov    %edi,%ecx
  801d37:	d3 e6                	shl    %cl,%esi
  801d39:	39 c6                	cmp    %eax,%esi
  801d3b:	73 07                	jae    801d44 <__udivdi3+0xc4>
  801d3d:	39 d5                	cmp    %edx,%ebp
  801d3f:	75 03                	jne    801d44 <__udivdi3+0xc4>
  801d41:	83 eb 01             	sub    $0x1,%ebx
  801d44:	31 ff                	xor    %edi,%edi
  801d46:	89 d8                	mov    %ebx,%eax
  801d48:	89 fa                	mov    %edi,%edx
  801d4a:	83 c4 1c             	add    $0x1c,%esp
  801d4d:	5b                   	pop    %ebx
  801d4e:	5e                   	pop    %esi
  801d4f:	5f                   	pop    %edi
  801d50:	5d                   	pop    %ebp
  801d51:	c3                   	ret    
  801d52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d58:	31 ff                	xor    %edi,%edi
  801d5a:	31 db                	xor    %ebx,%ebx
  801d5c:	89 d8                	mov    %ebx,%eax
  801d5e:	89 fa                	mov    %edi,%edx
  801d60:	83 c4 1c             	add    $0x1c,%esp
  801d63:	5b                   	pop    %ebx
  801d64:	5e                   	pop    %esi
  801d65:	5f                   	pop    %edi
  801d66:	5d                   	pop    %ebp
  801d67:	c3                   	ret    
  801d68:	90                   	nop
  801d69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d70:	89 d8                	mov    %ebx,%eax
  801d72:	f7 f7                	div    %edi
  801d74:	31 ff                	xor    %edi,%edi
  801d76:	89 c3                	mov    %eax,%ebx
  801d78:	89 d8                	mov    %ebx,%eax
  801d7a:	89 fa                	mov    %edi,%edx
  801d7c:	83 c4 1c             	add    $0x1c,%esp
  801d7f:	5b                   	pop    %ebx
  801d80:	5e                   	pop    %esi
  801d81:	5f                   	pop    %edi
  801d82:	5d                   	pop    %ebp
  801d83:	c3                   	ret    
  801d84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d88:	39 ce                	cmp    %ecx,%esi
  801d8a:	72 0c                	jb     801d98 <__udivdi3+0x118>
  801d8c:	31 db                	xor    %ebx,%ebx
  801d8e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801d92:	0f 87 34 ff ff ff    	ja     801ccc <__udivdi3+0x4c>
  801d98:	bb 01 00 00 00       	mov    $0x1,%ebx
  801d9d:	e9 2a ff ff ff       	jmp    801ccc <__udivdi3+0x4c>
  801da2:	66 90                	xchg   %ax,%ax
  801da4:	66 90                	xchg   %ax,%ax
  801da6:	66 90                	xchg   %ax,%ax
  801da8:	66 90                	xchg   %ax,%ax
  801daa:	66 90                	xchg   %ax,%ax
  801dac:	66 90                	xchg   %ax,%ax
  801dae:	66 90                	xchg   %ax,%ax

00801db0 <__umoddi3>:
  801db0:	55                   	push   %ebp
  801db1:	57                   	push   %edi
  801db2:	56                   	push   %esi
  801db3:	53                   	push   %ebx
  801db4:	83 ec 1c             	sub    $0x1c,%esp
  801db7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801dbb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801dbf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801dc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801dc7:	85 d2                	test   %edx,%edx
  801dc9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801dcd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801dd1:	89 f3                	mov    %esi,%ebx
  801dd3:	89 3c 24             	mov    %edi,(%esp)
  801dd6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dda:	75 1c                	jne    801df8 <__umoddi3+0x48>
  801ddc:	39 f7                	cmp    %esi,%edi
  801dde:	76 50                	jbe    801e30 <__umoddi3+0x80>
  801de0:	89 c8                	mov    %ecx,%eax
  801de2:	89 f2                	mov    %esi,%edx
  801de4:	f7 f7                	div    %edi
  801de6:	89 d0                	mov    %edx,%eax
  801de8:	31 d2                	xor    %edx,%edx
  801dea:	83 c4 1c             	add    $0x1c,%esp
  801ded:	5b                   	pop    %ebx
  801dee:	5e                   	pop    %esi
  801def:	5f                   	pop    %edi
  801df0:	5d                   	pop    %ebp
  801df1:	c3                   	ret    
  801df2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801df8:	39 f2                	cmp    %esi,%edx
  801dfa:	89 d0                	mov    %edx,%eax
  801dfc:	77 52                	ja     801e50 <__umoddi3+0xa0>
  801dfe:	0f bd ea             	bsr    %edx,%ebp
  801e01:	83 f5 1f             	xor    $0x1f,%ebp
  801e04:	75 5a                	jne    801e60 <__umoddi3+0xb0>
  801e06:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801e0a:	0f 82 e0 00 00 00    	jb     801ef0 <__umoddi3+0x140>
  801e10:	39 0c 24             	cmp    %ecx,(%esp)
  801e13:	0f 86 d7 00 00 00    	jbe    801ef0 <__umoddi3+0x140>
  801e19:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e1d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e21:	83 c4 1c             	add    $0x1c,%esp
  801e24:	5b                   	pop    %ebx
  801e25:	5e                   	pop    %esi
  801e26:	5f                   	pop    %edi
  801e27:	5d                   	pop    %ebp
  801e28:	c3                   	ret    
  801e29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e30:	85 ff                	test   %edi,%edi
  801e32:	89 fd                	mov    %edi,%ebp
  801e34:	75 0b                	jne    801e41 <__umoddi3+0x91>
  801e36:	b8 01 00 00 00       	mov    $0x1,%eax
  801e3b:	31 d2                	xor    %edx,%edx
  801e3d:	f7 f7                	div    %edi
  801e3f:	89 c5                	mov    %eax,%ebp
  801e41:	89 f0                	mov    %esi,%eax
  801e43:	31 d2                	xor    %edx,%edx
  801e45:	f7 f5                	div    %ebp
  801e47:	89 c8                	mov    %ecx,%eax
  801e49:	f7 f5                	div    %ebp
  801e4b:	89 d0                	mov    %edx,%eax
  801e4d:	eb 99                	jmp    801de8 <__umoddi3+0x38>
  801e4f:	90                   	nop
  801e50:	89 c8                	mov    %ecx,%eax
  801e52:	89 f2                	mov    %esi,%edx
  801e54:	83 c4 1c             	add    $0x1c,%esp
  801e57:	5b                   	pop    %ebx
  801e58:	5e                   	pop    %esi
  801e59:	5f                   	pop    %edi
  801e5a:	5d                   	pop    %ebp
  801e5b:	c3                   	ret    
  801e5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e60:	8b 34 24             	mov    (%esp),%esi
  801e63:	bf 20 00 00 00       	mov    $0x20,%edi
  801e68:	89 e9                	mov    %ebp,%ecx
  801e6a:	29 ef                	sub    %ebp,%edi
  801e6c:	d3 e0                	shl    %cl,%eax
  801e6e:	89 f9                	mov    %edi,%ecx
  801e70:	89 f2                	mov    %esi,%edx
  801e72:	d3 ea                	shr    %cl,%edx
  801e74:	89 e9                	mov    %ebp,%ecx
  801e76:	09 c2                	or     %eax,%edx
  801e78:	89 d8                	mov    %ebx,%eax
  801e7a:	89 14 24             	mov    %edx,(%esp)
  801e7d:	89 f2                	mov    %esi,%edx
  801e7f:	d3 e2                	shl    %cl,%edx
  801e81:	89 f9                	mov    %edi,%ecx
  801e83:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e87:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801e8b:	d3 e8                	shr    %cl,%eax
  801e8d:	89 e9                	mov    %ebp,%ecx
  801e8f:	89 c6                	mov    %eax,%esi
  801e91:	d3 e3                	shl    %cl,%ebx
  801e93:	89 f9                	mov    %edi,%ecx
  801e95:	89 d0                	mov    %edx,%eax
  801e97:	d3 e8                	shr    %cl,%eax
  801e99:	89 e9                	mov    %ebp,%ecx
  801e9b:	09 d8                	or     %ebx,%eax
  801e9d:	89 d3                	mov    %edx,%ebx
  801e9f:	89 f2                	mov    %esi,%edx
  801ea1:	f7 34 24             	divl   (%esp)
  801ea4:	89 d6                	mov    %edx,%esi
  801ea6:	d3 e3                	shl    %cl,%ebx
  801ea8:	f7 64 24 04          	mull   0x4(%esp)
  801eac:	39 d6                	cmp    %edx,%esi
  801eae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801eb2:	89 d1                	mov    %edx,%ecx
  801eb4:	89 c3                	mov    %eax,%ebx
  801eb6:	72 08                	jb     801ec0 <__umoddi3+0x110>
  801eb8:	75 11                	jne    801ecb <__umoddi3+0x11b>
  801eba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801ebe:	73 0b                	jae    801ecb <__umoddi3+0x11b>
  801ec0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801ec4:	1b 14 24             	sbb    (%esp),%edx
  801ec7:	89 d1                	mov    %edx,%ecx
  801ec9:	89 c3                	mov    %eax,%ebx
  801ecb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801ecf:	29 da                	sub    %ebx,%edx
  801ed1:	19 ce                	sbb    %ecx,%esi
  801ed3:	89 f9                	mov    %edi,%ecx
  801ed5:	89 f0                	mov    %esi,%eax
  801ed7:	d3 e0                	shl    %cl,%eax
  801ed9:	89 e9                	mov    %ebp,%ecx
  801edb:	d3 ea                	shr    %cl,%edx
  801edd:	89 e9                	mov    %ebp,%ecx
  801edf:	d3 ee                	shr    %cl,%esi
  801ee1:	09 d0                	or     %edx,%eax
  801ee3:	89 f2                	mov    %esi,%edx
  801ee5:	83 c4 1c             	add    $0x1c,%esp
  801ee8:	5b                   	pop    %ebx
  801ee9:	5e                   	pop    %esi
  801eea:	5f                   	pop    %edi
  801eeb:	5d                   	pop    %ebp
  801eec:	c3                   	ret    
  801eed:	8d 76 00             	lea    0x0(%esi),%esi
  801ef0:	29 f9                	sub    %edi,%ecx
  801ef2:	19 d6                	sbb    %edx,%esi
  801ef4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ef8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801efc:	e9 18 ff ff ff       	jmp    801e19 <__umoddi3+0x69>
