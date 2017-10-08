
obj/user/sendpage.debug：     文件格式 elf32-i386


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
  80002c:	e8 68 01 00 00       	call   800199 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#define TEMP_ADDR	((char*)0xa00000)
#define TEMP_ADDR_CHILD	((char*)0xb00000)

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	envid_t who;

	if ((who = fork()) == 0) {
  800039:	e8 eb 0e 00 00       	call   800f29 <fork>
  80003e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800041:	85 c0                	test   %eax,%eax
  800043:	0f 85 9f 00 00 00    	jne    8000e8 <umain+0xb5>
		// Child
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
  800049:	83 ec 04             	sub    $0x4,%esp
  80004c:	6a 00                	push   $0x0
  80004e:	68 00 00 b0 00       	push   $0xb00000
  800053:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800056:	50                   	push   %eax
  800057:	e8 81 10 00 00       	call   8010dd <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  80005c:	83 c4 0c             	add    $0xc,%esp
  80005f:	68 00 00 b0 00       	push   $0xb00000
  800064:	ff 75 f4             	pushl  -0xc(%ebp)
  800067:	68 60 22 80 00       	push   $0x802260
  80006c:	e8 1b 02 00 00       	call   80028c <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800071:	83 c4 04             	add    $0x4,%esp
  800074:	ff 35 04 30 80 00    	pushl  0x803004
  80007a:	e8 d8 07 00 00       	call   800857 <strlen>
  80007f:	83 c4 0c             	add    $0xc,%esp
  800082:	50                   	push   %eax
  800083:	ff 35 04 30 80 00    	pushl  0x803004
  800089:	68 00 00 b0 00       	push   $0xb00000
  80008e:	e8 cd 08 00 00       	call   800960 <strncmp>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	75 10                	jne    8000aa <umain+0x77>
			cprintf("child received correct message\n");
  80009a:	83 ec 0c             	sub    $0xc,%esp
  80009d:	68 74 22 80 00       	push   $0x802274
  8000a2:	e8 e5 01 00 00       	call   80028c <cprintf>
  8000a7:	83 c4 10             	add    $0x10,%esp

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000aa:	83 ec 0c             	sub    $0xc,%esp
  8000ad:	ff 35 00 30 80 00    	pushl  0x803000
  8000b3:	e8 9f 07 00 00       	call   800857 <strlen>
  8000b8:	83 c4 0c             	add    $0xc,%esp
  8000bb:	83 c0 01             	add    $0x1,%eax
  8000be:	50                   	push   %eax
  8000bf:	ff 35 00 30 80 00    	pushl  0x803000
  8000c5:	68 00 00 b0 00       	push   $0xb00000
  8000ca:	e8 bb 09 00 00       	call   800a8a <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000cf:	6a 07                	push   $0x7
  8000d1:	68 00 00 b0 00       	push   $0xb00000
  8000d6:	6a 00                	push   $0x0
  8000d8:	ff 75 f4             	pushl  -0xc(%ebp)
  8000db:	e8 6f 10 00 00       	call   80114f <ipc_send>
		return;
  8000e0:	83 c4 20             	add    $0x20,%esp
  8000e3:	e9 af 00 00 00       	jmp    800197 <umain+0x164>
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  8000e8:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ed:	8b 40 48             	mov    0x48(%eax),%eax
  8000f0:	83 ec 04             	sub    $0x4,%esp
  8000f3:	6a 07                	push   $0x7
  8000f5:	68 00 00 a0 00       	push   $0xa00000
  8000fa:	50                   	push   %eax
  8000fb:	e8 93 0b 00 00       	call   800c93 <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800100:	83 c4 04             	add    $0x4,%esp
  800103:	ff 35 04 30 80 00    	pushl  0x803004
  800109:	e8 49 07 00 00       	call   800857 <strlen>
  80010e:	83 c4 0c             	add    $0xc,%esp
  800111:	83 c0 01             	add    $0x1,%eax
  800114:	50                   	push   %eax
  800115:	ff 35 04 30 80 00    	pushl  0x803004
  80011b:	68 00 00 a0 00       	push   $0xa00000
  800120:	e8 65 09 00 00       	call   800a8a <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800125:	6a 07                	push   $0x7
  800127:	68 00 00 a0 00       	push   $0xa00000
  80012c:	6a 00                	push   $0x0
  80012e:	ff 75 f4             	pushl  -0xc(%ebp)
  800131:	e8 19 10 00 00       	call   80114f <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  800136:	83 c4 1c             	add    $0x1c,%esp
  800139:	6a 00                	push   $0x0
  80013b:	68 00 00 a0 00       	push   $0xa00000
  800140:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	e8 94 0f 00 00       	call   8010dd <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  800149:	83 c4 0c             	add    $0xc,%esp
  80014c:	68 00 00 a0 00       	push   $0xa00000
  800151:	ff 75 f4             	pushl  -0xc(%ebp)
  800154:	68 60 22 80 00       	push   $0x802260
  800159:	e8 2e 01 00 00       	call   80028c <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  80015e:	83 c4 04             	add    $0x4,%esp
  800161:	ff 35 00 30 80 00    	pushl  0x803000
  800167:	e8 eb 06 00 00       	call   800857 <strlen>
  80016c:	83 c4 0c             	add    $0xc,%esp
  80016f:	50                   	push   %eax
  800170:	ff 35 00 30 80 00    	pushl  0x803000
  800176:	68 00 00 a0 00       	push   $0xa00000
  80017b:	e8 e0 07 00 00       	call   800960 <strncmp>
  800180:	83 c4 10             	add    $0x10,%esp
  800183:	85 c0                	test   %eax,%eax
  800185:	75 10                	jne    800197 <umain+0x164>
		cprintf("parent received correct message\n");
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	68 94 22 80 00       	push   $0x802294
  80018f:	e8 f8 00 00 00       	call   80028c <cprintf>
  800194:	83 c4 10             	add    $0x10,%esp
	return;
}
  800197:	c9                   	leave  
  800198:	c3                   	ret    

00800199 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	56                   	push   %esi
  80019d:	53                   	push   %ebx
  80019e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001a1:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001a4:	e8 ac 0a 00 00       	call   800c55 <sys_getenvid>
  8001a9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001ae:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001b1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001b6:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001bb:	85 db                	test   %ebx,%ebx
  8001bd:	7e 07                	jle    8001c6 <libmain+0x2d>
		binaryname = argv[0];
  8001bf:	8b 06                	mov    (%esi),%eax
  8001c1:	a3 08 30 80 00       	mov    %eax,0x803008

	// call user main routine
	umain(argc, argv);
  8001c6:	83 ec 08             	sub    $0x8,%esp
  8001c9:	56                   	push   %esi
  8001ca:	53                   	push   %ebx
  8001cb:	e8 63 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001d0:	e8 0a 00 00 00       	call   8001df <exit>
}
  8001d5:	83 c4 10             	add    $0x10,%esp
  8001d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001db:	5b                   	pop    %ebx
  8001dc:	5e                   	pop    %esi
  8001dd:	5d                   	pop    %ebp
  8001de:	c3                   	ret    

008001df <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001e5:	e8 bd 11 00 00       	call   8013a7 <close_all>
	sys_env_destroy(0);
  8001ea:	83 ec 0c             	sub    $0xc,%esp
  8001ed:	6a 00                	push   $0x0
  8001ef:	e8 20 0a 00 00       	call   800c14 <sys_env_destroy>
}
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	c9                   	leave  
  8001f8:	c3                   	ret    

008001f9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001f9:	55                   	push   %ebp
  8001fa:	89 e5                	mov    %esp,%ebp
  8001fc:	53                   	push   %ebx
  8001fd:	83 ec 04             	sub    $0x4,%esp
  800200:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800203:	8b 13                	mov    (%ebx),%edx
  800205:	8d 42 01             	lea    0x1(%edx),%eax
  800208:	89 03                	mov    %eax,(%ebx)
  80020a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80020d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800211:	3d ff 00 00 00       	cmp    $0xff,%eax
  800216:	75 1a                	jne    800232 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800218:	83 ec 08             	sub    $0x8,%esp
  80021b:	68 ff 00 00 00       	push   $0xff
  800220:	8d 43 08             	lea    0x8(%ebx),%eax
  800223:	50                   	push   %eax
  800224:	e8 ae 09 00 00       	call   800bd7 <sys_cputs>
		b->idx = 0;
  800229:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80022f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800232:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800236:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800239:	c9                   	leave  
  80023a:	c3                   	ret    

0080023b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800244:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80024b:	00 00 00 
	b.cnt = 0;
  80024e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800255:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800258:	ff 75 0c             	pushl  0xc(%ebp)
  80025b:	ff 75 08             	pushl  0x8(%ebp)
  80025e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800264:	50                   	push   %eax
  800265:	68 f9 01 80 00       	push   $0x8001f9
  80026a:	e8 1a 01 00 00       	call   800389 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80026f:	83 c4 08             	add    $0x8,%esp
  800272:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800278:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80027e:	50                   	push   %eax
  80027f:	e8 53 09 00 00       	call   800bd7 <sys_cputs>

	return b.cnt;
}
  800284:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80028a:	c9                   	leave  
  80028b:	c3                   	ret    

0080028c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800292:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800295:	50                   	push   %eax
  800296:	ff 75 08             	pushl  0x8(%ebp)
  800299:	e8 9d ff ff ff       	call   80023b <vcprintf>
	va_end(ap);

	return cnt;
}
  80029e:	c9                   	leave  
  80029f:	c3                   	ret    

008002a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	57                   	push   %edi
  8002a4:	56                   	push   %esi
  8002a5:	53                   	push   %ebx
  8002a6:	83 ec 1c             	sub    $0x1c,%esp
  8002a9:	89 c7                	mov    %eax,%edi
  8002ab:	89 d6                	mov    %edx,%esi
  8002ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002b6:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002b9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002bc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002c4:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002c7:	39 d3                	cmp    %edx,%ebx
  8002c9:	72 05                	jb     8002d0 <printnum+0x30>
  8002cb:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002ce:	77 45                	ja     800315 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d0:	83 ec 0c             	sub    $0xc,%esp
  8002d3:	ff 75 18             	pushl  0x18(%ebp)
  8002d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8002d9:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8002dc:	53                   	push   %ebx
  8002dd:	ff 75 10             	pushl  0x10(%ebp)
  8002e0:	83 ec 08             	sub    $0x8,%esp
  8002e3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8002e9:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ec:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ef:	e8 cc 1c 00 00       	call   801fc0 <__udivdi3>
  8002f4:	83 c4 18             	add    $0x18,%esp
  8002f7:	52                   	push   %edx
  8002f8:	50                   	push   %eax
  8002f9:	89 f2                	mov    %esi,%edx
  8002fb:	89 f8                	mov    %edi,%eax
  8002fd:	e8 9e ff ff ff       	call   8002a0 <printnum>
  800302:	83 c4 20             	add    $0x20,%esp
  800305:	eb 18                	jmp    80031f <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800307:	83 ec 08             	sub    $0x8,%esp
  80030a:	56                   	push   %esi
  80030b:	ff 75 18             	pushl  0x18(%ebp)
  80030e:	ff d7                	call   *%edi
  800310:	83 c4 10             	add    $0x10,%esp
  800313:	eb 03                	jmp    800318 <printnum+0x78>
  800315:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800318:	83 eb 01             	sub    $0x1,%ebx
  80031b:	85 db                	test   %ebx,%ebx
  80031d:	7f e8                	jg     800307 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80031f:	83 ec 08             	sub    $0x8,%esp
  800322:	56                   	push   %esi
  800323:	83 ec 04             	sub    $0x4,%esp
  800326:	ff 75 e4             	pushl  -0x1c(%ebp)
  800329:	ff 75 e0             	pushl  -0x20(%ebp)
  80032c:	ff 75 dc             	pushl  -0x24(%ebp)
  80032f:	ff 75 d8             	pushl  -0x28(%ebp)
  800332:	e8 b9 1d 00 00       	call   8020f0 <__umoddi3>
  800337:	83 c4 14             	add    $0x14,%esp
  80033a:	0f be 80 0c 23 80 00 	movsbl 0x80230c(%eax),%eax
  800341:	50                   	push   %eax
  800342:	ff d7                	call   *%edi
}
  800344:	83 c4 10             	add    $0x10,%esp
  800347:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034a:	5b                   	pop    %ebx
  80034b:	5e                   	pop    %esi
  80034c:	5f                   	pop    %edi
  80034d:	5d                   	pop    %ebp
  80034e:	c3                   	ret    

0080034f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
  800352:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800355:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800359:	8b 10                	mov    (%eax),%edx
  80035b:	3b 50 04             	cmp    0x4(%eax),%edx
  80035e:	73 0a                	jae    80036a <sprintputch+0x1b>
		*b->buf++ = ch;
  800360:	8d 4a 01             	lea    0x1(%edx),%ecx
  800363:	89 08                	mov    %ecx,(%eax)
  800365:	8b 45 08             	mov    0x8(%ebp),%eax
  800368:	88 02                	mov    %al,(%edx)
}
  80036a:	5d                   	pop    %ebp
  80036b:	c3                   	ret    

0080036c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80036c:	55                   	push   %ebp
  80036d:	89 e5                	mov    %esp,%ebp
  80036f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800372:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800375:	50                   	push   %eax
  800376:	ff 75 10             	pushl  0x10(%ebp)
  800379:	ff 75 0c             	pushl  0xc(%ebp)
  80037c:	ff 75 08             	pushl  0x8(%ebp)
  80037f:	e8 05 00 00 00       	call   800389 <vprintfmt>
	va_end(ap);
}
  800384:	83 c4 10             	add    $0x10,%esp
  800387:	c9                   	leave  
  800388:	c3                   	ret    

00800389 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800389:	55                   	push   %ebp
  80038a:	89 e5                	mov    %esp,%ebp
  80038c:	57                   	push   %edi
  80038d:	56                   	push   %esi
  80038e:	53                   	push   %ebx
  80038f:	83 ec 2c             	sub    $0x2c,%esp
  800392:	8b 75 08             	mov    0x8(%ebp),%esi
  800395:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800398:	8b 7d 10             	mov    0x10(%ebp),%edi
  80039b:	eb 12                	jmp    8003af <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80039d:	85 c0                	test   %eax,%eax
  80039f:	0f 84 42 04 00 00    	je     8007e7 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8003a5:	83 ec 08             	sub    $0x8,%esp
  8003a8:	53                   	push   %ebx
  8003a9:	50                   	push   %eax
  8003aa:	ff d6                	call   *%esi
  8003ac:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003af:	83 c7 01             	add    $0x1,%edi
  8003b2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003b6:	83 f8 25             	cmp    $0x25,%eax
  8003b9:	75 e2                	jne    80039d <vprintfmt+0x14>
  8003bb:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003bf:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003c6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003cd:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003d4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003d9:	eb 07                	jmp    8003e2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003db:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003de:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e2:	8d 47 01             	lea    0x1(%edi),%eax
  8003e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003e8:	0f b6 07             	movzbl (%edi),%eax
  8003eb:	0f b6 d0             	movzbl %al,%edx
  8003ee:	83 e8 23             	sub    $0x23,%eax
  8003f1:	3c 55                	cmp    $0x55,%al
  8003f3:	0f 87 d3 03 00 00    	ja     8007cc <vprintfmt+0x443>
  8003f9:	0f b6 c0             	movzbl %al,%eax
  8003fc:	ff 24 85 40 24 80 00 	jmp    *0x802440(,%eax,4)
  800403:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800406:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80040a:	eb d6                	jmp    8003e2 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80040f:	b8 00 00 00 00       	mov    $0x0,%eax
  800414:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800417:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80041a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80041e:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800421:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800424:	83 f9 09             	cmp    $0x9,%ecx
  800427:	77 3f                	ja     800468 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800429:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80042c:	eb e9                	jmp    800417 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80042e:	8b 45 14             	mov    0x14(%ebp),%eax
  800431:	8b 00                	mov    (%eax),%eax
  800433:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800436:	8b 45 14             	mov    0x14(%ebp),%eax
  800439:	8d 40 04             	lea    0x4(%eax),%eax
  80043c:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80043f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800442:	eb 2a                	jmp    80046e <vprintfmt+0xe5>
  800444:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800447:	85 c0                	test   %eax,%eax
  800449:	ba 00 00 00 00       	mov    $0x0,%edx
  80044e:	0f 49 d0             	cmovns %eax,%edx
  800451:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800454:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800457:	eb 89                	jmp    8003e2 <vprintfmt+0x59>
  800459:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80045c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800463:	e9 7a ff ff ff       	jmp    8003e2 <vprintfmt+0x59>
  800468:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80046b:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80046e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800472:	0f 89 6a ff ff ff    	jns    8003e2 <vprintfmt+0x59>
				width = precision, precision = -1;
  800478:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80047b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80047e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800485:	e9 58 ff ff ff       	jmp    8003e2 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80048a:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800490:	e9 4d ff ff ff       	jmp    8003e2 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800495:	8b 45 14             	mov    0x14(%ebp),%eax
  800498:	8d 78 04             	lea    0x4(%eax),%edi
  80049b:	83 ec 08             	sub    $0x8,%esp
  80049e:	53                   	push   %ebx
  80049f:	ff 30                	pushl  (%eax)
  8004a1:	ff d6                	call   *%esi
			break;
  8004a3:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004a6:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004ac:	e9 fe fe ff ff       	jmp    8003af <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b4:	8d 78 04             	lea    0x4(%eax),%edi
  8004b7:	8b 00                	mov    (%eax),%eax
  8004b9:	99                   	cltd   
  8004ba:	31 d0                	xor    %edx,%eax
  8004bc:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004be:	83 f8 0f             	cmp    $0xf,%eax
  8004c1:	7f 0b                	jg     8004ce <vprintfmt+0x145>
  8004c3:	8b 14 85 a0 25 80 00 	mov    0x8025a0(,%eax,4),%edx
  8004ca:	85 d2                	test   %edx,%edx
  8004cc:	75 1b                	jne    8004e9 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8004ce:	50                   	push   %eax
  8004cf:	68 24 23 80 00       	push   $0x802324
  8004d4:	53                   	push   %ebx
  8004d5:	56                   	push   %esi
  8004d6:	e8 91 fe ff ff       	call   80036c <printfmt>
  8004db:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004de:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004e4:	e9 c6 fe ff ff       	jmp    8003af <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8004e9:	52                   	push   %edx
  8004ea:	68 55 27 80 00       	push   $0x802755
  8004ef:	53                   	push   %ebx
  8004f0:	56                   	push   %esi
  8004f1:	e8 76 fe ff ff       	call   80036c <printfmt>
  8004f6:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004f9:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ff:	e9 ab fe ff ff       	jmp    8003af <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800504:	8b 45 14             	mov    0x14(%ebp),%eax
  800507:	83 c0 04             	add    $0x4,%eax
  80050a:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80050d:	8b 45 14             	mov    0x14(%ebp),%eax
  800510:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800512:	85 ff                	test   %edi,%edi
  800514:	b8 1d 23 80 00       	mov    $0x80231d,%eax
  800519:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80051c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800520:	0f 8e 94 00 00 00    	jle    8005ba <vprintfmt+0x231>
  800526:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80052a:	0f 84 98 00 00 00    	je     8005c8 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800530:	83 ec 08             	sub    $0x8,%esp
  800533:	ff 75 d0             	pushl  -0x30(%ebp)
  800536:	57                   	push   %edi
  800537:	e8 33 03 00 00       	call   80086f <strnlen>
  80053c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80053f:	29 c1                	sub    %eax,%ecx
  800541:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800544:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800547:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80054b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80054e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800551:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800553:	eb 0f                	jmp    800564 <vprintfmt+0x1db>
					putch(padc, putdat);
  800555:	83 ec 08             	sub    $0x8,%esp
  800558:	53                   	push   %ebx
  800559:	ff 75 e0             	pushl  -0x20(%ebp)
  80055c:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80055e:	83 ef 01             	sub    $0x1,%edi
  800561:	83 c4 10             	add    $0x10,%esp
  800564:	85 ff                	test   %edi,%edi
  800566:	7f ed                	jg     800555 <vprintfmt+0x1cc>
  800568:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80056b:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80056e:	85 c9                	test   %ecx,%ecx
  800570:	b8 00 00 00 00       	mov    $0x0,%eax
  800575:	0f 49 c1             	cmovns %ecx,%eax
  800578:	29 c1                	sub    %eax,%ecx
  80057a:	89 75 08             	mov    %esi,0x8(%ebp)
  80057d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800580:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800583:	89 cb                	mov    %ecx,%ebx
  800585:	eb 4d                	jmp    8005d4 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800587:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80058b:	74 1b                	je     8005a8 <vprintfmt+0x21f>
  80058d:	0f be c0             	movsbl %al,%eax
  800590:	83 e8 20             	sub    $0x20,%eax
  800593:	83 f8 5e             	cmp    $0x5e,%eax
  800596:	76 10                	jbe    8005a8 <vprintfmt+0x21f>
					putch('?', putdat);
  800598:	83 ec 08             	sub    $0x8,%esp
  80059b:	ff 75 0c             	pushl  0xc(%ebp)
  80059e:	6a 3f                	push   $0x3f
  8005a0:	ff 55 08             	call   *0x8(%ebp)
  8005a3:	83 c4 10             	add    $0x10,%esp
  8005a6:	eb 0d                	jmp    8005b5 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8005a8:	83 ec 08             	sub    $0x8,%esp
  8005ab:	ff 75 0c             	pushl  0xc(%ebp)
  8005ae:	52                   	push   %edx
  8005af:	ff 55 08             	call   *0x8(%ebp)
  8005b2:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b5:	83 eb 01             	sub    $0x1,%ebx
  8005b8:	eb 1a                	jmp    8005d4 <vprintfmt+0x24b>
  8005ba:	89 75 08             	mov    %esi,0x8(%ebp)
  8005bd:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005c0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005c3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005c6:	eb 0c                	jmp    8005d4 <vprintfmt+0x24b>
  8005c8:	89 75 08             	mov    %esi,0x8(%ebp)
  8005cb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005ce:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005d1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005d4:	83 c7 01             	add    $0x1,%edi
  8005d7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005db:	0f be d0             	movsbl %al,%edx
  8005de:	85 d2                	test   %edx,%edx
  8005e0:	74 23                	je     800605 <vprintfmt+0x27c>
  8005e2:	85 f6                	test   %esi,%esi
  8005e4:	78 a1                	js     800587 <vprintfmt+0x1fe>
  8005e6:	83 ee 01             	sub    $0x1,%esi
  8005e9:	79 9c                	jns    800587 <vprintfmt+0x1fe>
  8005eb:	89 df                	mov    %ebx,%edi
  8005ed:	8b 75 08             	mov    0x8(%ebp),%esi
  8005f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005f3:	eb 18                	jmp    80060d <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005f5:	83 ec 08             	sub    $0x8,%esp
  8005f8:	53                   	push   %ebx
  8005f9:	6a 20                	push   $0x20
  8005fb:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005fd:	83 ef 01             	sub    $0x1,%edi
  800600:	83 c4 10             	add    $0x10,%esp
  800603:	eb 08                	jmp    80060d <vprintfmt+0x284>
  800605:	89 df                	mov    %ebx,%edi
  800607:	8b 75 08             	mov    0x8(%ebp),%esi
  80060a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80060d:	85 ff                	test   %edi,%edi
  80060f:	7f e4                	jg     8005f5 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800611:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800614:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800617:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80061a:	e9 90 fd ff ff       	jmp    8003af <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80061f:	83 f9 01             	cmp    $0x1,%ecx
  800622:	7e 19                	jle    80063d <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800624:	8b 45 14             	mov    0x14(%ebp),%eax
  800627:	8b 50 04             	mov    0x4(%eax),%edx
  80062a:	8b 00                	mov    (%eax),%eax
  80062c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80062f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800632:	8b 45 14             	mov    0x14(%ebp),%eax
  800635:	8d 40 08             	lea    0x8(%eax),%eax
  800638:	89 45 14             	mov    %eax,0x14(%ebp)
  80063b:	eb 38                	jmp    800675 <vprintfmt+0x2ec>
	else if (lflag)
  80063d:	85 c9                	test   %ecx,%ecx
  80063f:	74 1b                	je     80065c <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800641:	8b 45 14             	mov    0x14(%ebp),%eax
  800644:	8b 00                	mov    (%eax),%eax
  800646:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800649:	89 c1                	mov    %eax,%ecx
  80064b:	c1 f9 1f             	sar    $0x1f,%ecx
  80064e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800651:	8b 45 14             	mov    0x14(%ebp),%eax
  800654:	8d 40 04             	lea    0x4(%eax),%eax
  800657:	89 45 14             	mov    %eax,0x14(%ebp)
  80065a:	eb 19                	jmp    800675 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  80065c:	8b 45 14             	mov    0x14(%ebp),%eax
  80065f:	8b 00                	mov    (%eax),%eax
  800661:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800664:	89 c1                	mov    %eax,%ecx
  800666:	c1 f9 1f             	sar    $0x1f,%ecx
  800669:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80066c:	8b 45 14             	mov    0x14(%ebp),%eax
  80066f:	8d 40 04             	lea    0x4(%eax),%eax
  800672:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800675:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800678:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80067b:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800680:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800684:	0f 89 0e 01 00 00    	jns    800798 <vprintfmt+0x40f>
				putch('-', putdat);
  80068a:	83 ec 08             	sub    $0x8,%esp
  80068d:	53                   	push   %ebx
  80068e:	6a 2d                	push   $0x2d
  800690:	ff d6                	call   *%esi
				num = -(long long) num;
  800692:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800695:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800698:	f7 da                	neg    %edx
  80069a:	83 d1 00             	adc    $0x0,%ecx
  80069d:	f7 d9                	neg    %ecx
  80069f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006a2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006a7:	e9 ec 00 00 00       	jmp    800798 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006ac:	83 f9 01             	cmp    $0x1,%ecx
  8006af:	7e 18                	jle    8006c9 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8006b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b4:	8b 10                	mov    (%eax),%edx
  8006b6:	8b 48 04             	mov    0x4(%eax),%ecx
  8006b9:	8d 40 08             	lea    0x8(%eax),%eax
  8006bc:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8006bf:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006c4:	e9 cf 00 00 00       	jmp    800798 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006c9:	85 c9                	test   %ecx,%ecx
  8006cb:	74 1a                	je     8006e7 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8006cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d0:	8b 10                	mov    (%eax),%edx
  8006d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d7:	8d 40 04             	lea    0x4(%eax),%eax
  8006da:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8006dd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006e2:	e9 b1 00 00 00       	jmp    800798 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8006e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ea:	8b 10                	mov    (%eax),%edx
  8006ec:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f1:	8d 40 04             	lea    0x4(%eax),%eax
  8006f4:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8006f7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006fc:	e9 97 00 00 00       	jmp    800798 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800701:	83 ec 08             	sub    $0x8,%esp
  800704:	53                   	push   %ebx
  800705:	6a 58                	push   $0x58
  800707:	ff d6                	call   *%esi
			putch('X', putdat);
  800709:	83 c4 08             	add    $0x8,%esp
  80070c:	53                   	push   %ebx
  80070d:	6a 58                	push   $0x58
  80070f:	ff d6                	call   *%esi
			putch('X', putdat);
  800711:	83 c4 08             	add    $0x8,%esp
  800714:	53                   	push   %ebx
  800715:	6a 58                	push   $0x58
  800717:	ff d6                	call   *%esi
			break;
  800719:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  80071f:	e9 8b fc ff ff       	jmp    8003af <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800724:	83 ec 08             	sub    $0x8,%esp
  800727:	53                   	push   %ebx
  800728:	6a 30                	push   $0x30
  80072a:	ff d6                	call   *%esi
			putch('x', putdat);
  80072c:	83 c4 08             	add    $0x8,%esp
  80072f:	53                   	push   %ebx
  800730:	6a 78                	push   $0x78
  800732:	ff d6                	call   *%esi
			num = (unsigned long long)
  800734:	8b 45 14             	mov    0x14(%ebp),%eax
  800737:	8b 10                	mov    (%eax),%edx
  800739:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80073e:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800741:	8d 40 04             	lea    0x4(%eax),%eax
  800744:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800747:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80074c:	eb 4a                	jmp    800798 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80074e:	83 f9 01             	cmp    $0x1,%ecx
  800751:	7e 15                	jle    800768 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  800753:	8b 45 14             	mov    0x14(%ebp),%eax
  800756:	8b 10                	mov    (%eax),%edx
  800758:	8b 48 04             	mov    0x4(%eax),%ecx
  80075b:	8d 40 08             	lea    0x8(%eax),%eax
  80075e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800761:	b8 10 00 00 00       	mov    $0x10,%eax
  800766:	eb 30                	jmp    800798 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800768:	85 c9                	test   %ecx,%ecx
  80076a:	74 17                	je     800783 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  80076c:	8b 45 14             	mov    0x14(%ebp),%eax
  80076f:	8b 10                	mov    (%eax),%edx
  800771:	b9 00 00 00 00       	mov    $0x0,%ecx
  800776:	8d 40 04             	lea    0x4(%eax),%eax
  800779:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80077c:	b8 10 00 00 00       	mov    $0x10,%eax
  800781:	eb 15                	jmp    800798 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800783:	8b 45 14             	mov    0x14(%ebp),%eax
  800786:	8b 10                	mov    (%eax),%edx
  800788:	b9 00 00 00 00       	mov    $0x0,%ecx
  80078d:	8d 40 04             	lea    0x4(%eax),%eax
  800790:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800793:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800798:	83 ec 0c             	sub    $0xc,%esp
  80079b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80079f:	57                   	push   %edi
  8007a0:	ff 75 e0             	pushl  -0x20(%ebp)
  8007a3:	50                   	push   %eax
  8007a4:	51                   	push   %ecx
  8007a5:	52                   	push   %edx
  8007a6:	89 da                	mov    %ebx,%edx
  8007a8:	89 f0                	mov    %esi,%eax
  8007aa:	e8 f1 fa ff ff       	call   8002a0 <printnum>
			break;
  8007af:	83 c4 20             	add    $0x20,%esp
  8007b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007b5:	e9 f5 fb ff ff       	jmp    8003af <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007ba:	83 ec 08             	sub    $0x8,%esp
  8007bd:	53                   	push   %ebx
  8007be:	52                   	push   %edx
  8007bf:	ff d6                	call   *%esi
			break;
  8007c1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007c7:	e9 e3 fb ff ff       	jmp    8003af <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007cc:	83 ec 08             	sub    $0x8,%esp
  8007cf:	53                   	push   %ebx
  8007d0:	6a 25                	push   $0x25
  8007d2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007d4:	83 c4 10             	add    $0x10,%esp
  8007d7:	eb 03                	jmp    8007dc <vprintfmt+0x453>
  8007d9:	83 ef 01             	sub    $0x1,%edi
  8007dc:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007e0:	75 f7                	jne    8007d9 <vprintfmt+0x450>
  8007e2:	e9 c8 fb ff ff       	jmp    8003af <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007ea:	5b                   	pop    %ebx
  8007eb:	5e                   	pop    %esi
  8007ec:	5f                   	pop    %edi
  8007ed:	5d                   	pop    %ebp
  8007ee:	c3                   	ret    

008007ef <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	83 ec 18             	sub    $0x18,%esp
  8007f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007fe:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800802:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800805:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80080c:	85 c0                	test   %eax,%eax
  80080e:	74 26                	je     800836 <vsnprintf+0x47>
  800810:	85 d2                	test   %edx,%edx
  800812:	7e 22                	jle    800836 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800814:	ff 75 14             	pushl  0x14(%ebp)
  800817:	ff 75 10             	pushl  0x10(%ebp)
  80081a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80081d:	50                   	push   %eax
  80081e:	68 4f 03 80 00       	push   $0x80034f
  800823:	e8 61 fb ff ff       	call   800389 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800828:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80082b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80082e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800831:	83 c4 10             	add    $0x10,%esp
  800834:	eb 05                	jmp    80083b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800836:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80083b:	c9                   	leave  
  80083c:	c3                   	ret    

0080083d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800843:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800846:	50                   	push   %eax
  800847:	ff 75 10             	pushl  0x10(%ebp)
  80084a:	ff 75 0c             	pushl  0xc(%ebp)
  80084d:	ff 75 08             	pushl  0x8(%ebp)
  800850:	e8 9a ff ff ff       	call   8007ef <vsnprintf>
	va_end(ap);

	return rc;
}
  800855:	c9                   	leave  
  800856:	c3                   	ret    

00800857 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80085d:	b8 00 00 00 00       	mov    $0x0,%eax
  800862:	eb 03                	jmp    800867 <strlen+0x10>
		n++;
  800864:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800867:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80086b:	75 f7                	jne    800864 <strlen+0xd>
		n++;
	return n;
}
  80086d:	5d                   	pop    %ebp
  80086e:	c3                   	ret    

0080086f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80086f:	55                   	push   %ebp
  800870:	89 e5                	mov    %esp,%ebp
  800872:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800875:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800878:	ba 00 00 00 00       	mov    $0x0,%edx
  80087d:	eb 03                	jmp    800882 <strnlen+0x13>
		n++;
  80087f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800882:	39 c2                	cmp    %eax,%edx
  800884:	74 08                	je     80088e <strnlen+0x1f>
  800886:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80088a:	75 f3                	jne    80087f <strnlen+0x10>
  80088c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80088e:	5d                   	pop    %ebp
  80088f:	c3                   	ret    

00800890 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	53                   	push   %ebx
  800894:	8b 45 08             	mov    0x8(%ebp),%eax
  800897:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80089a:	89 c2                	mov    %eax,%edx
  80089c:	83 c2 01             	add    $0x1,%edx
  80089f:	83 c1 01             	add    $0x1,%ecx
  8008a2:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008a6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008a9:	84 db                	test   %bl,%bl
  8008ab:	75 ef                	jne    80089c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008ad:	5b                   	pop    %ebx
  8008ae:	5d                   	pop    %ebp
  8008af:	c3                   	ret    

008008b0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	53                   	push   %ebx
  8008b4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008b7:	53                   	push   %ebx
  8008b8:	e8 9a ff ff ff       	call   800857 <strlen>
  8008bd:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008c0:	ff 75 0c             	pushl  0xc(%ebp)
  8008c3:	01 d8                	add    %ebx,%eax
  8008c5:	50                   	push   %eax
  8008c6:	e8 c5 ff ff ff       	call   800890 <strcpy>
	return dst;
}
  8008cb:	89 d8                	mov    %ebx,%eax
  8008cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d0:	c9                   	leave  
  8008d1:	c3                   	ret    

008008d2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	56                   	push   %esi
  8008d6:	53                   	push   %ebx
  8008d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008dd:	89 f3                	mov    %esi,%ebx
  8008df:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e2:	89 f2                	mov    %esi,%edx
  8008e4:	eb 0f                	jmp    8008f5 <strncpy+0x23>
		*dst++ = *src;
  8008e6:	83 c2 01             	add    $0x1,%edx
  8008e9:	0f b6 01             	movzbl (%ecx),%eax
  8008ec:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008ef:	80 39 01             	cmpb   $0x1,(%ecx)
  8008f2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f5:	39 da                	cmp    %ebx,%edx
  8008f7:	75 ed                	jne    8008e6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008f9:	89 f0                	mov    %esi,%eax
  8008fb:	5b                   	pop    %ebx
  8008fc:	5e                   	pop    %esi
  8008fd:	5d                   	pop    %ebp
  8008fe:	c3                   	ret    

008008ff <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008ff:	55                   	push   %ebp
  800900:	89 e5                	mov    %esp,%ebp
  800902:	56                   	push   %esi
  800903:	53                   	push   %ebx
  800904:	8b 75 08             	mov    0x8(%ebp),%esi
  800907:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80090a:	8b 55 10             	mov    0x10(%ebp),%edx
  80090d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80090f:	85 d2                	test   %edx,%edx
  800911:	74 21                	je     800934 <strlcpy+0x35>
  800913:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800917:	89 f2                	mov    %esi,%edx
  800919:	eb 09                	jmp    800924 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80091b:	83 c2 01             	add    $0x1,%edx
  80091e:	83 c1 01             	add    $0x1,%ecx
  800921:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800924:	39 c2                	cmp    %eax,%edx
  800926:	74 09                	je     800931 <strlcpy+0x32>
  800928:	0f b6 19             	movzbl (%ecx),%ebx
  80092b:	84 db                	test   %bl,%bl
  80092d:	75 ec                	jne    80091b <strlcpy+0x1c>
  80092f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800931:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800934:	29 f0                	sub    %esi,%eax
}
  800936:	5b                   	pop    %ebx
  800937:	5e                   	pop    %esi
  800938:	5d                   	pop    %ebp
  800939:	c3                   	ret    

0080093a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800940:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800943:	eb 06                	jmp    80094b <strcmp+0x11>
		p++, q++;
  800945:	83 c1 01             	add    $0x1,%ecx
  800948:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80094b:	0f b6 01             	movzbl (%ecx),%eax
  80094e:	84 c0                	test   %al,%al
  800950:	74 04                	je     800956 <strcmp+0x1c>
  800952:	3a 02                	cmp    (%edx),%al
  800954:	74 ef                	je     800945 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800956:	0f b6 c0             	movzbl %al,%eax
  800959:	0f b6 12             	movzbl (%edx),%edx
  80095c:	29 d0                	sub    %edx,%eax
}
  80095e:	5d                   	pop    %ebp
  80095f:	c3                   	ret    

00800960 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	53                   	push   %ebx
  800964:	8b 45 08             	mov    0x8(%ebp),%eax
  800967:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096a:	89 c3                	mov    %eax,%ebx
  80096c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80096f:	eb 06                	jmp    800977 <strncmp+0x17>
		n--, p++, q++;
  800971:	83 c0 01             	add    $0x1,%eax
  800974:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800977:	39 d8                	cmp    %ebx,%eax
  800979:	74 15                	je     800990 <strncmp+0x30>
  80097b:	0f b6 08             	movzbl (%eax),%ecx
  80097e:	84 c9                	test   %cl,%cl
  800980:	74 04                	je     800986 <strncmp+0x26>
  800982:	3a 0a                	cmp    (%edx),%cl
  800984:	74 eb                	je     800971 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800986:	0f b6 00             	movzbl (%eax),%eax
  800989:	0f b6 12             	movzbl (%edx),%edx
  80098c:	29 d0                	sub    %edx,%eax
  80098e:	eb 05                	jmp    800995 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800990:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800995:	5b                   	pop    %ebx
  800996:	5d                   	pop    %ebp
  800997:	c3                   	ret    

00800998 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800998:	55                   	push   %ebp
  800999:	89 e5                	mov    %esp,%ebp
  80099b:	8b 45 08             	mov    0x8(%ebp),%eax
  80099e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a2:	eb 07                	jmp    8009ab <strchr+0x13>
		if (*s == c)
  8009a4:	38 ca                	cmp    %cl,%dl
  8009a6:	74 0f                	je     8009b7 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009a8:	83 c0 01             	add    $0x1,%eax
  8009ab:	0f b6 10             	movzbl (%eax),%edx
  8009ae:	84 d2                	test   %dl,%dl
  8009b0:	75 f2                	jne    8009a4 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b7:	5d                   	pop    %ebp
  8009b8:	c3                   	ret    

008009b9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c3:	eb 03                	jmp    8009c8 <strfind+0xf>
  8009c5:	83 c0 01             	add    $0x1,%eax
  8009c8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009cb:	38 ca                	cmp    %cl,%dl
  8009cd:	74 04                	je     8009d3 <strfind+0x1a>
  8009cf:	84 d2                	test   %dl,%dl
  8009d1:	75 f2                	jne    8009c5 <strfind+0xc>
			break;
	return (char *) s;
}
  8009d3:	5d                   	pop    %ebp
  8009d4:	c3                   	ret    

008009d5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009d5:	55                   	push   %ebp
  8009d6:	89 e5                	mov    %esp,%ebp
  8009d8:	57                   	push   %edi
  8009d9:	56                   	push   %esi
  8009da:	53                   	push   %ebx
  8009db:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009de:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009e1:	85 c9                	test   %ecx,%ecx
  8009e3:	74 36                	je     800a1b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009e5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009eb:	75 28                	jne    800a15 <memset+0x40>
  8009ed:	f6 c1 03             	test   $0x3,%cl
  8009f0:	75 23                	jne    800a15 <memset+0x40>
		c &= 0xFF;
  8009f2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009f6:	89 d3                	mov    %edx,%ebx
  8009f8:	c1 e3 08             	shl    $0x8,%ebx
  8009fb:	89 d6                	mov    %edx,%esi
  8009fd:	c1 e6 18             	shl    $0x18,%esi
  800a00:	89 d0                	mov    %edx,%eax
  800a02:	c1 e0 10             	shl    $0x10,%eax
  800a05:	09 f0                	or     %esi,%eax
  800a07:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a09:	89 d8                	mov    %ebx,%eax
  800a0b:	09 d0                	or     %edx,%eax
  800a0d:	c1 e9 02             	shr    $0x2,%ecx
  800a10:	fc                   	cld    
  800a11:	f3 ab                	rep stos %eax,%es:(%edi)
  800a13:	eb 06                	jmp    800a1b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a15:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a18:	fc                   	cld    
  800a19:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a1b:	89 f8                	mov    %edi,%eax
  800a1d:	5b                   	pop    %ebx
  800a1e:	5e                   	pop    %esi
  800a1f:	5f                   	pop    %edi
  800a20:	5d                   	pop    %ebp
  800a21:	c3                   	ret    

00800a22 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a22:	55                   	push   %ebp
  800a23:	89 e5                	mov    %esp,%ebp
  800a25:	57                   	push   %edi
  800a26:	56                   	push   %esi
  800a27:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a2d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a30:	39 c6                	cmp    %eax,%esi
  800a32:	73 35                	jae    800a69 <memmove+0x47>
  800a34:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a37:	39 d0                	cmp    %edx,%eax
  800a39:	73 2e                	jae    800a69 <memmove+0x47>
		s += n;
		d += n;
  800a3b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a3e:	89 d6                	mov    %edx,%esi
  800a40:	09 fe                	or     %edi,%esi
  800a42:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a48:	75 13                	jne    800a5d <memmove+0x3b>
  800a4a:	f6 c1 03             	test   $0x3,%cl
  800a4d:	75 0e                	jne    800a5d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a4f:	83 ef 04             	sub    $0x4,%edi
  800a52:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a55:	c1 e9 02             	shr    $0x2,%ecx
  800a58:	fd                   	std    
  800a59:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a5b:	eb 09                	jmp    800a66 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a5d:	83 ef 01             	sub    $0x1,%edi
  800a60:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a63:	fd                   	std    
  800a64:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a66:	fc                   	cld    
  800a67:	eb 1d                	jmp    800a86 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a69:	89 f2                	mov    %esi,%edx
  800a6b:	09 c2                	or     %eax,%edx
  800a6d:	f6 c2 03             	test   $0x3,%dl
  800a70:	75 0f                	jne    800a81 <memmove+0x5f>
  800a72:	f6 c1 03             	test   $0x3,%cl
  800a75:	75 0a                	jne    800a81 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a77:	c1 e9 02             	shr    $0x2,%ecx
  800a7a:	89 c7                	mov    %eax,%edi
  800a7c:	fc                   	cld    
  800a7d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a7f:	eb 05                	jmp    800a86 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a81:	89 c7                	mov    %eax,%edi
  800a83:	fc                   	cld    
  800a84:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a86:	5e                   	pop    %esi
  800a87:	5f                   	pop    %edi
  800a88:	5d                   	pop    %ebp
  800a89:	c3                   	ret    

00800a8a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a8a:	55                   	push   %ebp
  800a8b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a8d:	ff 75 10             	pushl  0x10(%ebp)
  800a90:	ff 75 0c             	pushl  0xc(%ebp)
  800a93:	ff 75 08             	pushl  0x8(%ebp)
  800a96:	e8 87 ff ff ff       	call   800a22 <memmove>
}
  800a9b:	c9                   	leave  
  800a9c:	c3                   	ret    

00800a9d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	56                   	push   %esi
  800aa1:	53                   	push   %ebx
  800aa2:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa8:	89 c6                	mov    %eax,%esi
  800aaa:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aad:	eb 1a                	jmp    800ac9 <memcmp+0x2c>
		if (*s1 != *s2)
  800aaf:	0f b6 08             	movzbl (%eax),%ecx
  800ab2:	0f b6 1a             	movzbl (%edx),%ebx
  800ab5:	38 d9                	cmp    %bl,%cl
  800ab7:	74 0a                	je     800ac3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ab9:	0f b6 c1             	movzbl %cl,%eax
  800abc:	0f b6 db             	movzbl %bl,%ebx
  800abf:	29 d8                	sub    %ebx,%eax
  800ac1:	eb 0f                	jmp    800ad2 <memcmp+0x35>
		s1++, s2++;
  800ac3:	83 c0 01             	add    $0x1,%eax
  800ac6:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ac9:	39 f0                	cmp    %esi,%eax
  800acb:	75 e2                	jne    800aaf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800acd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad2:	5b                   	pop    %ebx
  800ad3:	5e                   	pop    %esi
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    

00800ad6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
  800ad9:	53                   	push   %ebx
  800ada:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800add:	89 c1                	mov    %eax,%ecx
  800adf:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae2:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ae6:	eb 0a                	jmp    800af2 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae8:	0f b6 10             	movzbl (%eax),%edx
  800aeb:	39 da                	cmp    %ebx,%edx
  800aed:	74 07                	je     800af6 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aef:	83 c0 01             	add    $0x1,%eax
  800af2:	39 c8                	cmp    %ecx,%eax
  800af4:	72 f2                	jb     800ae8 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800af6:	5b                   	pop    %ebx
  800af7:	5d                   	pop    %ebp
  800af8:	c3                   	ret    

00800af9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
  800afc:	57                   	push   %edi
  800afd:	56                   	push   %esi
  800afe:	53                   	push   %ebx
  800aff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b02:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b05:	eb 03                	jmp    800b0a <strtol+0x11>
		s++;
  800b07:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b0a:	0f b6 01             	movzbl (%ecx),%eax
  800b0d:	3c 20                	cmp    $0x20,%al
  800b0f:	74 f6                	je     800b07 <strtol+0xe>
  800b11:	3c 09                	cmp    $0x9,%al
  800b13:	74 f2                	je     800b07 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b15:	3c 2b                	cmp    $0x2b,%al
  800b17:	75 0a                	jne    800b23 <strtol+0x2a>
		s++;
  800b19:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b1c:	bf 00 00 00 00       	mov    $0x0,%edi
  800b21:	eb 11                	jmp    800b34 <strtol+0x3b>
  800b23:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b28:	3c 2d                	cmp    $0x2d,%al
  800b2a:	75 08                	jne    800b34 <strtol+0x3b>
		s++, neg = 1;
  800b2c:	83 c1 01             	add    $0x1,%ecx
  800b2f:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b34:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b3a:	75 15                	jne    800b51 <strtol+0x58>
  800b3c:	80 39 30             	cmpb   $0x30,(%ecx)
  800b3f:	75 10                	jne    800b51 <strtol+0x58>
  800b41:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b45:	75 7c                	jne    800bc3 <strtol+0xca>
		s += 2, base = 16;
  800b47:	83 c1 02             	add    $0x2,%ecx
  800b4a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b4f:	eb 16                	jmp    800b67 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b51:	85 db                	test   %ebx,%ebx
  800b53:	75 12                	jne    800b67 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b55:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b5a:	80 39 30             	cmpb   $0x30,(%ecx)
  800b5d:	75 08                	jne    800b67 <strtol+0x6e>
		s++, base = 8;
  800b5f:	83 c1 01             	add    $0x1,%ecx
  800b62:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b67:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b6f:	0f b6 11             	movzbl (%ecx),%edx
  800b72:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b75:	89 f3                	mov    %esi,%ebx
  800b77:	80 fb 09             	cmp    $0x9,%bl
  800b7a:	77 08                	ja     800b84 <strtol+0x8b>
			dig = *s - '0';
  800b7c:	0f be d2             	movsbl %dl,%edx
  800b7f:	83 ea 30             	sub    $0x30,%edx
  800b82:	eb 22                	jmp    800ba6 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b84:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b87:	89 f3                	mov    %esi,%ebx
  800b89:	80 fb 19             	cmp    $0x19,%bl
  800b8c:	77 08                	ja     800b96 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b8e:	0f be d2             	movsbl %dl,%edx
  800b91:	83 ea 57             	sub    $0x57,%edx
  800b94:	eb 10                	jmp    800ba6 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b96:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b99:	89 f3                	mov    %esi,%ebx
  800b9b:	80 fb 19             	cmp    $0x19,%bl
  800b9e:	77 16                	ja     800bb6 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ba0:	0f be d2             	movsbl %dl,%edx
  800ba3:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ba6:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ba9:	7d 0b                	jge    800bb6 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800bab:	83 c1 01             	add    $0x1,%ecx
  800bae:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bb2:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bb4:	eb b9                	jmp    800b6f <strtol+0x76>

	if (endptr)
  800bb6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bba:	74 0d                	je     800bc9 <strtol+0xd0>
		*endptr = (char *) s;
  800bbc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bbf:	89 0e                	mov    %ecx,(%esi)
  800bc1:	eb 06                	jmp    800bc9 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bc3:	85 db                	test   %ebx,%ebx
  800bc5:	74 98                	je     800b5f <strtol+0x66>
  800bc7:	eb 9e                	jmp    800b67 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bc9:	89 c2                	mov    %eax,%edx
  800bcb:	f7 da                	neg    %edx
  800bcd:	85 ff                	test   %edi,%edi
  800bcf:	0f 45 c2             	cmovne %edx,%eax
}
  800bd2:	5b                   	pop    %ebx
  800bd3:	5e                   	pop    %esi
  800bd4:	5f                   	pop    %edi
  800bd5:	5d                   	pop    %ebp
  800bd6:	c3                   	ret    

00800bd7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bd7:	55                   	push   %ebp
  800bd8:	89 e5                	mov    %esp,%ebp
  800bda:	57                   	push   %edi
  800bdb:	56                   	push   %esi
  800bdc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bdd:	b8 00 00 00 00       	mov    $0x0,%eax
  800be2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be5:	8b 55 08             	mov    0x8(%ebp),%edx
  800be8:	89 c3                	mov    %eax,%ebx
  800bea:	89 c7                	mov    %eax,%edi
  800bec:	89 c6                	mov    %eax,%esi
  800bee:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bf0:	5b                   	pop    %ebx
  800bf1:	5e                   	pop    %esi
  800bf2:	5f                   	pop    %edi
  800bf3:	5d                   	pop    %ebp
  800bf4:	c3                   	ret    

00800bf5 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	57                   	push   %edi
  800bf9:	56                   	push   %esi
  800bfa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfb:	ba 00 00 00 00       	mov    $0x0,%edx
  800c00:	b8 01 00 00 00       	mov    $0x1,%eax
  800c05:	89 d1                	mov    %edx,%ecx
  800c07:	89 d3                	mov    %edx,%ebx
  800c09:	89 d7                	mov    %edx,%edi
  800c0b:	89 d6                	mov    %edx,%esi
  800c0d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c0f:	5b                   	pop    %ebx
  800c10:	5e                   	pop    %esi
  800c11:	5f                   	pop    %edi
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    

00800c14 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	57                   	push   %edi
  800c18:	56                   	push   %esi
  800c19:	53                   	push   %ebx
  800c1a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c22:	b8 03 00 00 00       	mov    $0x3,%eax
  800c27:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2a:	89 cb                	mov    %ecx,%ebx
  800c2c:	89 cf                	mov    %ecx,%edi
  800c2e:	89 ce                	mov    %ecx,%esi
  800c30:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c32:	85 c0                	test   %eax,%eax
  800c34:	7e 17                	jle    800c4d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c36:	83 ec 0c             	sub    $0xc,%esp
  800c39:	50                   	push   %eax
  800c3a:	6a 03                	push   $0x3
  800c3c:	68 ff 25 80 00       	push   $0x8025ff
  800c41:	6a 23                	push   $0x23
  800c43:	68 1c 26 80 00       	push   $0x80261c
  800c48:	e8 79 12 00 00       	call   801ec6 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c50:	5b                   	pop    %ebx
  800c51:	5e                   	pop    %esi
  800c52:	5f                   	pop    %edi
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	57                   	push   %edi
  800c59:	56                   	push   %esi
  800c5a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c60:	b8 02 00 00 00       	mov    $0x2,%eax
  800c65:	89 d1                	mov    %edx,%ecx
  800c67:	89 d3                	mov    %edx,%ebx
  800c69:	89 d7                	mov    %edx,%edi
  800c6b:	89 d6                	mov    %edx,%esi
  800c6d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c6f:	5b                   	pop    %ebx
  800c70:	5e                   	pop    %esi
  800c71:	5f                   	pop    %edi
  800c72:	5d                   	pop    %ebp
  800c73:	c3                   	ret    

00800c74 <sys_yield>:

void
sys_yield(void)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	57                   	push   %edi
  800c78:	56                   	push   %esi
  800c79:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c84:	89 d1                	mov    %edx,%ecx
  800c86:	89 d3                	mov    %edx,%ebx
  800c88:	89 d7                	mov    %edx,%edi
  800c8a:	89 d6                	mov    %edx,%esi
  800c8c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c8e:	5b                   	pop    %ebx
  800c8f:	5e                   	pop    %esi
  800c90:	5f                   	pop    %edi
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    

00800c93 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	57                   	push   %edi
  800c97:	56                   	push   %esi
  800c98:	53                   	push   %ebx
  800c99:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9c:	be 00 00 00 00       	mov    $0x0,%esi
  800ca1:	b8 04 00 00 00       	mov    $0x4,%eax
  800ca6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800caf:	89 f7                	mov    %esi,%edi
  800cb1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cb3:	85 c0                	test   %eax,%eax
  800cb5:	7e 17                	jle    800cce <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb7:	83 ec 0c             	sub    $0xc,%esp
  800cba:	50                   	push   %eax
  800cbb:	6a 04                	push   $0x4
  800cbd:	68 ff 25 80 00       	push   $0x8025ff
  800cc2:	6a 23                	push   $0x23
  800cc4:	68 1c 26 80 00       	push   $0x80261c
  800cc9:	e8 f8 11 00 00       	call   801ec6 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd1:	5b                   	pop    %ebx
  800cd2:	5e                   	pop    %esi
  800cd3:	5f                   	pop    %edi
  800cd4:	5d                   	pop    %ebp
  800cd5:	c3                   	ret    

00800cd6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cd6:	55                   	push   %ebp
  800cd7:	89 e5                	mov    %esp,%ebp
  800cd9:	57                   	push   %edi
  800cda:	56                   	push   %esi
  800cdb:	53                   	push   %ebx
  800cdc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdf:	b8 05 00 00 00       	mov    $0x5,%eax
  800ce4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cea:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ced:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf0:	8b 75 18             	mov    0x18(%ebp),%esi
  800cf3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cf5:	85 c0                	test   %eax,%eax
  800cf7:	7e 17                	jle    800d10 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf9:	83 ec 0c             	sub    $0xc,%esp
  800cfc:	50                   	push   %eax
  800cfd:	6a 05                	push   $0x5
  800cff:	68 ff 25 80 00       	push   $0x8025ff
  800d04:	6a 23                	push   $0x23
  800d06:	68 1c 26 80 00       	push   $0x80261c
  800d0b:	e8 b6 11 00 00       	call   801ec6 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d13:	5b                   	pop    %ebx
  800d14:	5e                   	pop    %esi
  800d15:	5f                   	pop    %edi
  800d16:	5d                   	pop    %ebp
  800d17:	c3                   	ret    

00800d18 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d18:	55                   	push   %ebp
  800d19:	89 e5                	mov    %esp,%ebp
  800d1b:	57                   	push   %edi
  800d1c:	56                   	push   %esi
  800d1d:	53                   	push   %ebx
  800d1e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d21:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d26:	b8 06 00 00 00       	mov    $0x6,%eax
  800d2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d31:	89 df                	mov    %ebx,%edi
  800d33:	89 de                	mov    %ebx,%esi
  800d35:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d37:	85 c0                	test   %eax,%eax
  800d39:	7e 17                	jle    800d52 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3b:	83 ec 0c             	sub    $0xc,%esp
  800d3e:	50                   	push   %eax
  800d3f:	6a 06                	push   $0x6
  800d41:	68 ff 25 80 00       	push   $0x8025ff
  800d46:	6a 23                	push   $0x23
  800d48:	68 1c 26 80 00       	push   $0x80261c
  800d4d:	e8 74 11 00 00       	call   801ec6 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d52:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d55:	5b                   	pop    %ebx
  800d56:	5e                   	pop    %esi
  800d57:	5f                   	pop    %edi
  800d58:	5d                   	pop    %ebp
  800d59:	c3                   	ret    

00800d5a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d5a:	55                   	push   %ebp
  800d5b:	89 e5                	mov    %esp,%ebp
  800d5d:	57                   	push   %edi
  800d5e:	56                   	push   %esi
  800d5f:	53                   	push   %ebx
  800d60:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d63:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d68:	b8 08 00 00 00       	mov    $0x8,%eax
  800d6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d70:	8b 55 08             	mov    0x8(%ebp),%edx
  800d73:	89 df                	mov    %ebx,%edi
  800d75:	89 de                	mov    %ebx,%esi
  800d77:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d79:	85 c0                	test   %eax,%eax
  800d7b:	7e 17                	jle    800d94 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7d:	83 ec 0c             	sub    $0xc,%esp
  800d80:	50                   	push   %eax
  800d81:	6a 08                	push   $0x8
  800d83:	68 ff 25 80 00       	push   $0x8025ff
  800d88:	6a 23                	push   $0x23
  800d8a:	68 1c 26 80 00       	push   $0x80261c
  800d8f:	e8 32 11 00 00       	call   801ec6 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d97:	5b                   	pop    %ebx
  800d98:	5e                   	pop    %esi
  800d99:	5f                   	pop    %edi
  800d9a:	5d                   	pop    %ebp
  800d9b:	c3                   	ret    

00800d9c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d9c:	55                   	push   %ebp
  800d9d:	89 e5                	mov    %esp,%ebp
  800d9f:	57                   	push   %edi
  800da0:	56                   	push   %esi
  800da1:	53                   	push   %ebx
  800da2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800daa:	b8 09 00 00 00       	mov    $0x9,%eax
  800daf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db2:	8b 55 08             	mov    0x8(%ebp),%edx
  800db5:	89 df                	mov    %ebx,%edi
  800db7:	89 de                	mov    %ebx,%esi
  800db9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dbb:	85 c0                	test   %eax,%eax
  800dbd:	7e 17                	jle    800dd6 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dbf:	83 ec 0c             	sub    $0xc,%esp
  800dc2:	50                   	push   %eax
  800dc3:	6a 09                	push   $0x9
  800dc5:	68 ff 25 80 00       	push   $0x8025ff
  800dca:	6a 23                	push   $0x23
  800dcc:	68 1c 26 80 00       	push   $0x80261c
  800dd1:	e8 f0 10 00 00       	call   801ec6 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd9:	5b                   	pop    %ebx
  800dda:	5e                   	pop    %esi
  800ddb:	5f                   	pop    %edi
  800ddc:	5d                   	pop    %ebp
  800ddd:	c3                   	ret    

00800dde <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dde:	55                   	push   %ebp
  800ddf:	89 e5                	mov    %esp,%ebp
  800de1:	57                   	push   %edi
  800de2:	56                   	push   %esi
  800de3:	53                   	push   %ebx
  800de4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dec:	b8 0a 00 00 00       	mov    $0xa,%eax
  800df1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df4:	8b 55 08             	mov    0x8(%ebp),%edx
  800df7:	89 df                	mov    %ebx,%edi
  800df9:	89 de                	mov    %ebx,%esi
  800dfb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dfd:	85 c0                	test   %eax,%eax
  800dff:	7e 17                	jle    800e18 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e01:	83 ec 0c             	sub    $0xc,%esp
  800e04:	50                   	push   %eax
  800e05:	6a 0a                	push   $0xa
  800e07:	68 ff 25 80 00       	push   $0x8025ff
  800e0c:	6a 23                	push   $0x23
  800e0e:	68 1c 26 80 00       	push   $0x80261c
  800e13:	e8 ae 10 00 00       	call   801ec6 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1b:	5b                   	pop    %ebx
  800e1c:	5e                   	pop    %esi
  800e1d:	5f                   	pop    %edi
  800e1e:	5d                   	pop    %ebp
  800e1f:	c3                   	ret    

00800e20 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e20:	55                   	push   %ebp
  800e21:	89 e5                	mov    %esp,%ebp
  800e23:	57                   	push   %edi
  800e24:	56                   	push   %esi
  800e25:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e26:	be 00 00 00 00       	mov    $0x0,%esi
  800e2b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e33:	8b 55 08             	mov    0x8(%ebp),%edx
  800e36:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e39:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e3c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e3e:	5b                   	pop    %ebx
  800e3f:	5e                   	pop    %esi
  800e40:	5f                   	pop    %edi
  800e41:	5d                   	pop    %ebp
  800e42:	c3                   	ret    

00800e43 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e43:	55                   	push   %ebp
  800e44:	89 e5                	mov    %esp,%ebp
  800e46:	57                   	push   %edi
  800e47:	56                   	push   %esi
  800e48:	53                   	push   %ebx
  800e49:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e51:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e56:	8b 55 08             	mov    0x8(%ebp),%edx
  800e59:	89 cb                	mov    %ecx,%ebx
  800e5b:	89 cf                	mov    %ecx,%edi
  800e5d:	89 ce                	mov    %ecx,%esi
  800e5f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e61:	85 c0                	test   %eax,%eax
  800e63:	7e 17                	jle    800e7c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e65:	83 ec 0c             	sub    $0xc,%esp
  800e68:	50                   	push   %eax
  800e69:	6a 0d                	push   $0xd
  800e6b:	68 ff 25 80 00       	push   $0x8025ff
  800e70:	6a 23                	push   $0x23
  800e72:	68 1c 26 80 00       	push   $0x80261c
  800e77:	e8 4a 10 00 00       	call   801ec6 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e7f:	5b                   	pop    %ebx
  800e80:	5e                   	pop    %esi
  800e81:	5f                   	pop    %edi
  800e82:	5d                   	pop    %ebp
  800e83:	c3                   	ret    

00800e84 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e84:	55                   	push   %ebp
  800e85:	89 e5                	mov    %esp,%ebp
  800e87:	57                   	push   %edi
  800e88:	56                   	push   %esi
  800e89:	53                   	push   %ebx
  800e8a:	83 ec 0c             	sub    $0xc,%esp
  800e8d:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e90:	8b 18                	mov    (%eax),%ebx
	uint32_t err = utf->utf_err;
  800e92:	8b 78 04             	mov    0x4(%eax),%edi
	int r;
	envid_t curenvid = sys_getenvid();
  800e95:	e8 bb fd ff ff       	call   800c55 <sys_getenvid>
  800e9a:	89 c6                	mov    %eax,%esi
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(err & FEC_WR) && !(uvpt[PGNUM(addr)] & PTE_COW))
  800e9c:	f7 c7 02 00 00 00    	test   $0x2,%edi
  800ea2:	75 25                	jne    800ec9 <pgfault+0x45>
  800ea4:	89 d8                	mov    %ebx,%eax
  800ea6:	c1 e8 0c             	shr    $0xc,%eax
  800ea9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800eb0:	f6 c4 08             	test   $0x8,%ah
  800eb3:	75 14                	jne    800ec9 <pgfault+0x45>
	    panic("pgfault error: wrong faulting access");
  800eb5:	83 ec 04             	sub    $0x4,%esp
  800eb8:	68 2c 26 80 00       	push   $0x80262c
  800ebd:	6a 1e                	push   $0x1e
  800ebf:	68 51 26 80 00       	push   $0x802651
  800ec4:	e8 fd 0f 00 00       	call   801ec6 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	sys_page_alloc(curenvid, PFTEMP, PTE_W | PTE_U | PTE_P);
  800ec9:	83 ec 04             	sub    $0x4,%esp
  800ecc:	6a 07                	push   $0x7
  800ece:	68 00 f0 7f 00       	push   $0x7ff000
  800ed3:	56                   	push   %esi
  800ed4:	e8 ba fd ff ff       	call   800c93 <sys_page_alloc>

	addr = (void *)(PGNUM(addr) * PGSIZE);
  800ed9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr, PGSIZE);
  800edf:	83 c4 0c             	add    $0xc,%esp
  800ee2:	68 00 10 00 00       	push   $0x1000
  800ee7:	53                   	push   %ebx
  800ee8:	68 00 f0 7f 00       	push   $0x7ff000
  800eed:	e8 30 fb ff ff       	call   800a22 <memmove>

	sys_page_unmap(curenvid, addr);
  800ef2:	83 c4 08             	add    $0x8,%esp
  800ef5:	53                   	push   %ebx
  800ef6:	56                   	push   %esi
  800ef7:	e8 1c fe ff ff       	call   800d18 <sys_page_unmap>
	sys_page_map(curenvid, PFTEMP, curenvid, addr, PTE_W | PTE_U | PTE_P);
  800efc:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f03:	53                   	push   %ebx
  800f04:	56                   	push   %esi
  800f05:	68 00 f0 7f 00       	push   $0x7ff000
  800f0a:	56                   	push   %esi
  800f0b:	e8 c6 fd ff ff       	call   800cd6 <sys_page_map>
	sys_page_unmap(curenvid, PFTEMP);
  800f10:	83 c4 18             	add    $0x18,%esp
  800f13:	68 00 f0 7f 00       	push   $0x7ff000
  800f18:	56                   	push   %esi
  800f19:	e8 fa fd ff ff       	call   800d18 <sys_page_unmap>
}
  800f1e:	83 c4 10             	add    $0x10,%esp
  800f21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f24:	5b                   	pop    %ebx
  800f25:	5e                   	pop    %esi
  800f26:	5f                   	pop    %edi
  800f27:	5d                   	pop    %ebp
  800f28:	c3                   	ret    

00800f29 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f29:	55                   	push   %ebp
  800f2a:	89 e5                	mov    %esp,%ebp
  800f2c:	57                   	push   %edi
  800f2d:	56                   	push   %esi
  800f2e:	53                   	push   %ebx
  800f2f:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	extern void _pgfault_upcall();
	envid_t new_envid, curenv_id;

	curenv_id = sys_getenvid();
  800f32:	e8 1e fd ff ff       	call   800c55 <sys_getenvid>
	set_pgfault_handler(pgfault);
  800f37:	83 ec 0c             	sub    $0xc,%esp
  800f3a:	68 84 0e 80 00       	push   $0x800e84
  800f3f:	e8 c8 0f 00 00       	call   801f0c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800f44:	b8 07 00 00 00       	mov    $0x7,%eax
  800f49:	cd 30                	int    $0x30
  800f4b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800f4e:	89 45 dc             	mov    %eax,-0x24(%ebp)
	new_envid = sys_exofork();

	if (new_envid < 0)
  800f51:	83 c4 10             	add    $0x10,%esp
  800f54:	85 c0                	test   %eax,%eax
  800f56:	79 12                	jns    800f6a <fork+0x41>
	    panic("fork error: %e", new_envid);
  800f58:	50                   	push   %eax
  800f59:	68 5c 26 80 00       	push   $0x80265c
  800f5e:	6a 75                	push   $0x75
  800f60:	68 51 26 80 00       	push   $0x802651
  800f65:	e8 5c 0f 00 00       	call   801ec6 <_panic>
  800f6a:	bf 00 00 80 00       	mov    $0x800000,%edi
	else if (new_envid == 0)
  800f6f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800f73:	75 1c                	jne    800f91 <fork+0x68>
		thisenv = envs + ENVX(sys_getenvid());
  800f75:	e8 db fc ff ff       	call   800c55 <sys_getenvid>
  800f7a:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f7f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f82:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f87:	a3 04 40 80 00       	mov    %eax,0x804004
  800f8c:	e9 27 01 00 00       	jmp    8010b8 <fork+0x18f>
	else {

		for (uint32_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
			if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
  800f91:	89 f8                	mov    %edi,%eax
  800f93:	c1 e8 16             	shr    $0x16,%eax
  800f96:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f9d:	a8 01                	test   $0x1,%al
  800f9f:	0f 84 d2 00 00 00    	je     801077 <fork+0x14e>
  800fa5:	89 fb                	mov    %edi,%ebx
  800fa7:	c1 eb 0c             	shr    $0xc,%ebx
  800faa:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800fb1:	a8 01                	test   $0x1,%al
  800fb3:	0f 84 be 00 00 00    	je     801077 <fork+0x14e>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	int perm = PTE_U | PTE_P;
	envid_t curenvid = sys_getenvid();
  800fb9:	e8 97 fc ff ff       	call   800c55 <sys_getenvid>
  800fbe:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  800fc1:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
		perm |= PTE_COW ;
  800fc8:	be 05 08 00 00       	mov    $0x805,%esi
	int r;
	int perm = PTE_U | PTE_P;
	envid_t curenvid = sys_getenvid();

	// LAB 4: Your code here.
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  800fcd:	a8 02                	test   $0x2,%al
  800fcf:	75 1d                	jne    800fee <fork+0xc5>
  800fd1:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800fd8:	25 00 08 00 00       	and    $0x800,%eax
		perm |= PTE_COW ;
  800fdd:	83 f8 01             	cmp    $0x1,%eax
  800fe0:	19 f6                	sbb    %esi,%esi
  800fe2:	81 e6 00 f8 ff ff    	and    $0xfffff800,%esi
  800fe8:	81 c6 05 08 00 00    	add    $0x805,%esi

	if (uvpt[pn] & PTE_SHARE)
  800fee:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800ff5:	25 00 04 00 00       	and    $0x400,%eax
		perm |= PTE_SYSCALL;
  800ffa:	b8 07 0e 00 00       	mov    $0xe07,%eax
  800fff:	0f 45 f0             	cmovne %eax,%esi

	r = sys_page_map(curenvid, (void *)(pn * PGSIZE),
  801002:	89 d8                	mov    %ebx,%eax
  801004:	c1 e0 0c             	shl    $0xc,%eax
  801007:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80100a:	83 ec 0c             	sub    $0xc,%esp
  80100d:	56                   	push   %esi
  80100e:	50                   	push   %eax
  80100f:	ff 75 dc             	pushl  -0x24(%ebp)
  801012:	50                   	push   %eax
  801013:	ff 75 e4             	pushl  -0x1c(%ebp)
  801016:	e8 bb fc ff ff       	call   800cd6 <sys_page_map>
				envid, (void *)(pn * PGSIZE), perm);
	if (r < 0)
  80101b:	83 c4 20             	add    $0x20,%esp
  80101e:	85 c0                	test   %eax,%eax
  801020:	79 12                	jns    801034 <fork+0x10b>
		panic("duppage error: %e", r);
  801022:	50                   	push   %eax
  801023:	68 6b 26 80 00       	push   $0x80266b
  801028:	6a 4d                	push   $0x4d
  80102a:	68 51 26 80 00       	push   $0x802651
  80102f:	e8 92 0e 00 00       	call   801ec6 <_panic>
	
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))	{
  801034:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80103b:	a8 02                	test   $0x2,%al
  80103d:	75 0c                	jne    80104b <fork+0x122>
  80103f:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801046:	f6 c4 08             	test   $0x8,%ah
  801049:	74 2c                	je     801077 <fork+0x14e>
		r = sys_page_map(curenvid, (void *)(pn * PGSIZE),
  80104b:	83 ec 0c             	sub    $0xc,%esp
  80104e:	56                   	push   %esi
  80104f:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801052:	52                   	push   %edx
  801053:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801056:	50                   	push   %eax
  801057:	52                   	push   %edx
  801058:	50                   	push   %eax
  801059:	e8 78 fc ff ff       	call   800cd6 <sys_page_map>
						curenvid, (void *)(pn * PGSIZE), perm);
		if (r < 0)
  80105e:	83 c4 20             	add    $0x20,%esp
  801061:	85 c0                	test   %eax,%eax
  801063:	79 12                	jns    801077 <fork+0x14e>
			panic("duppage error: %e", r);
  801065:	50                   	push   %eax
  801066:	68 6b 26 80 00       	push   $0x80266b
  80106b:	6a 53                	push   $0x53
  80106d:	68 51 26 80 00       	push   $0x802651
  801072:	e8 4f 0e 00 00       	call   801ec6 <_panic>
	    panic("fork error: %e", new_envid);
	else if (new_envid == 0)
		thisenv = envs + ENVX(sys_getenvid());
	else {

		for (uint32_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
  801077:	81 c7 00 10 00 00    	add    $0x1000,%edi
  80107d:	81 ff 00 e0 bf ee    	cmp    $0xeebfe000,%edi
  801083:	0f 85 08 ff ff ff    	jne    800f91 <fork+0x68>
			if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
				duppage(new_envid, PGNUM(addr));
		}

		sys_page_alloc(new_envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  801089:	83 ec 04             	sub    $0x4,%esp
  80108c:	6a 07                	push   $0x7
  80108e:	68 00 f0 bf ee       	push   $0xeebff000
  801093:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801096:	56                   	push   %esi
  801097:	e8 f7 fb ff ff       	call   800c93 <sys_page_alloc>
		sys_env_set_pgfault_upcall(new_envid, _pgfault_upcall);
  80109c:	83 c4 08             	add    $0x8,%esp
  80109f:	68 51 1f 80 00       	push   $0x801f51
  8010a4:	56                   	push   %esi
  8010a5:	e8 34 fd ff ff       	call   800dde <sys_env_set_pgfault_upcall>
		sys_env_set_status(new_envid, ENV_RUNNABLE);
  8010aa:	83 c4 08             	add    $0x8,%esp
  8010ad:	6a 02                	push   $0x2
  8010af:	56                   	push   %esi
  8010b0:	e8 a5 fc ff ff       	call   800d5a <sys_env_set_status>
  8010b5:	83 c4 10             	add    $0x10,%esp

	}
	return new_envid;
}
  8010b8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8010bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010be:	5b                   	pop    %ebx
  8010bf:	5e                   	pop    %esi
  8010c0:	5f                   	pop    %edi
  8010c1:	5d                   	pop    %ebp
  8010c2:	c3                   	ret    

008010c3 <sfork>:

// Challenge!
int
sfork(void)
{
  8010c3:	55                   	push   %ebp
  8010c4:	89 e5                	mov    %esp,%ebp
  8010c6:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010c9:	68 7d 26 80 00       	push   $0x80267d
  8010ce:	68 8b 00 00 00       	push   $0x8b
  8010d3:	68 51 26 80 00       	push   $0x802651
  8010d8:	e8 e9 0d 00 00       	call   801ec6 <_panic>

008010dd <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010dd:	55                   	push   %ebp
  8010de:	89 e5                	mov    %esp,%ebp
  8010e0:	56                   	push   %esi
  8010e1:	53                   	push   %ebx
  8010e2:	8b 75 08             	mov    0x8(%ebp),%esi
  8010e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010e8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

    if (pg != NULL)
  8010eb:	85 c0                	test   %eax,%eax
  8010ed:	74 0e                	je     8010fd <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  8010ef:	83 ec 0c             	sub    $0xc,%esp
  8010f2:	50                   	push   %eax
  8010f3:	e8 4b fd ff ff       	call   800e43 <sys_ipc_recv>
  8010f8:	83 c4 10             	add    $0x10,%esp
  8010fb:	eb 0d                	jmp    80110a <ipc_recv+0x2d>
	else
        r = sys_ipc_recv((void *)-1);
  8010fd:	83 ec 0c             	sub    $0xc,%esp
  801100:	6a ff                	push   $0xffffffff
  801102:	e8 3c fd ff ff       	call   800e43 <sys_ipc_recv>
  801107:	83 c4 10             	add    $0x10,%esp

	if (r < 0) {
  80110a:	85 c0                	test   %eax,%eax
  80110c:	79 16                	jns    801124 <ipc_recv+0x47>

		if (from_env_store != NULL)
  80110e:	85 f6                	test   %esi,%esi
  801110:	74 06                	je     801118 <ipc_recv+0x3b>
			*from_env_store = 0;
  801112:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL)
  801118:	85 db                	test   %ebx,%ebx
  80111a:	74 2c                	je     801148 <ipc_recv+0x6b>
			*perm_store = 0;
  80111c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801122:	eb 24                	jmp    801148 <ipc_recv+0x6b>
		return r;

	} else {

		if (from_env_store != NULL)
  801124:	85 f6                	test   %esi,%esi
  801126:	74 0a                	je     801132 <ipc_recv+0x55>
			*from_env_store = thisenv->env_ipc_from;
  801128:	a1 04 40 80 00       	mov    0x804004,%eax
  80112d:	8b 40 74             	mov    0x74(%eax),%eax
  801130:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL)
  801132:	85 db                	test   %ebx,%ebx
  801134:	74 0a                	je     801140 <ipc_recv+0x63>
			*perm_store = thisenv->env_ipc_perm;
  801136:	a1 04 40 80 00       	mov    0x804004,%eax
  80113b:	8b 40 78             	mov    0x78(%eax),%eax
  80113e:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801140:	a1 04 40 80 00       	mov    0x804004,%eax
  801145:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801148:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80114b:	5b                   	pop    %ebx
  80114c:	5e                   	pop    %esi
  80114d:	5d                   	pop    %ebp
  80114e:	c3                   	ret    

0080114f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80114f:	55                   	push   %ebp
  801150:	89 e5                	mov    %esp,%ebp
  801152:	57                   	push   %edi
  801153:	56                   	push   %esi
  801154:	53                   	push   %ebx
  801155:	83 ec 0c             	sub    $0xc,%esp
  801158:	8b 7d 08             	mov    0x8(%ebp),%edi
  80115b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80115e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

	if (pg == NULL)
  801161:	85 db                	test   %ebx,%ebx
		pg = (void *)-1;	
  801163:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801168:	0f 44 d8             	cmove  %eax,%ebx

	while (true) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  80116b:	ff 75 14             	pushl  0x14(%ebp)
  80116e:	53                   	push   %ebx
  80116f:	56                   	push   %esi
  801170:	57                   	push   %edi
  801171:	e8 aa fc ff ff       	call   800e20 <sys_ipc_try_send>
		if (r >= 0)
  801176:	83 c4 10             	add    $0x10,%esp
  801179:	85 c0                	test   %eax,%eax
  80117b:	79 1e                	jns    80119b <ipc_send+0x4c>
			return;
		else if (r != -E_IPC_NOT_RECV)
  80117d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801180:	74 12                	je     801194 <ipc_send+0x45>
			panic("ipc_send error: %e", r);
  801182:	50                   	push   %eax
  801183:	68 93 26 80 00       	push   $0x802693
  801188:	6a 49                	push   $0x49
  80118a:	68 a6 26 80 00       	push   $0x8026a6
  80118f:	e8 32 0d 00 00       	call   801ec6 <_panic>
	
		sys_yield();
  801194:	e8 db fa ff ff       	call   800c74 <sys_yield>
	}
  801199:	eb d0                	jmp    80116b <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  80119b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80119e:	5b                   	pop    %ebx
  80119f:	5e                   	pop    %esi
  8011a0:	5f                   	pop    %edi
  8011a1:	5d                   	pop    %ebp
  8011a2:	c3                   	ret    

008011a3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8011a3:	55                   	push   %ebp
  8011a4:	89 e5                	mov    %esp,%ebp
  8011a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8011a9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8011ae:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8011b1:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8011b7:	8b 52 50             	mov    0x50(%edx),%edx
  8011ba:	39 ca                	cmp    %ecx,%edx
  8011bc:	75 0d                	jne    8011cb <ipc_find_env+0x28>
			return envs[i].env_id;
  8011be:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011c1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011c6:	8b 40 48             	mov    0x48(%eax),%eax
  8011c9:	eb 0f                	jmp    8011da <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8011cb:	83 c0 01             	add    $0x1,%eax
  8011ce:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011d3:	75 d9                	jne    8011ae <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8011d5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011da:	5d                   	pop    %ebp
  8011db:	c3                   	ret    

008011dc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011dc:	55                   	push   %ebp
  8011dd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011df:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e2:	05 00 00 00 30       	add    $0x30000000,%eax
  8011e7:	c1 e8 0c             	shr    $0xc,%eax
}
  8011ea:	5d                   	pop    %ebp
  8011eb:	c3                   	ret    

008011ec <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011ec:	55                   	push   %ebp
  8011ed:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f2:	05 00 00 00 30       	add    $0x30000000,%eax
  8011f7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011fc:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801201:	5d                   	pop    %ebp
  801202:	c3                   	ret    

00801203 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801203:	55                   	push   %ebp
  801204:	89 e5                	mov    %esp,%ebp
  801206:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801209:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80120e:	89 c2                	mov    %eax,%edx
  801210:	c1 ea 16             	shr    $0x16,%edx
  801213:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80121a:	f6 c2 01             	test   $0x1,%dl
  80121d:	74 11                	je     801230 <fd_alloc+0x2d>
  80121f:	89 c2                	mov    %eax,%edx
  801221:	c1 ea 0c             	shr    $0xc,%edx
  801224:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80122b:	f6 c2 01             	test   $0x1,%dl
  80122e:	75 09                	jne    801239 <fd_alloc+0x36>
			*fd_store = fd;
  801230:	89 01                	mov    %eax,(%ecx)
			return 0;
  801232:	b8 00 00 00 00       	mov    $0x0,%eax
  801237:	eb 17                	jmp    801250 <fd_alloc+0x4d>
  801239:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80123e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801243:	75 c9                	jne    80120e <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801245:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80124b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801250:	5d                   	pop    %ebp
  801251:	c3                   	ret    

00801252 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801252:	55                   	push   %ebp
  801253:	89 e5                	mov    %esp,%ebp
  801255:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801258:	83 f8 1f             	cmp    $0x1f,%eax
  80125b:	77 36                	ja     801293 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80125d:	c1 e0 0c             	shl    $0xc,%eax
  801260:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801265:	89 c2                	mov    %eax,%edx
  801267:	c1 ea 16             	shr    $0x16,%edx
  80126a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801271:	f6 c2 01             	test   $0x1,%dl
  801274:	74 24                	je     80129a <fd_lookup+0x48>
  801276:	89 c2                	mov    %eax,%edx
  801278:	c1 ea 0c             	shr    $0xc,%edx
  80127b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801282:	f6 c2 01             	test   $0x1,%dl
  801285:	74 1a                	je     8012a1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801287:	8b 55 0c             	mov    0xc(%ebp),%edx
  80128a:	89 02                	mov    %eax,(%edx)
	return 0;
  80128c:	b8 00 00 00 00       	mov    $0x0,%eax
  801291:	eb 13                	jmp    8012a6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801293:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801298:	eb 0c                	jmp    8012a6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80129a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80129f:	eb 05                	jmp    8012a6 <fd_lookup+0x54>
  8012a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012a6:	5d                   	pop    %ebp
  8012a7:	c3                   	ret    

008012a8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012a8:	55                   	push   %ebp
  8012a9:	89 e5                	mov    %esp,%ebp
  8012ab:	83 ec 08             	sub    $0x8,%esp
  8012ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012b1:	ba 2c 27 80 00       	mov    $0x80272c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012b6:	eb 13                	jmp    8012cb <dev_lookup+0x23>
  8012b8:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012bb:	39 08                	cmp    %ecx,(%eax)
  8012bd:	75 0c                	jne    8012cb <dev_lookup+0x23>
			*dev = devtab[i];
  8012bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012c2:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c9:	eb 2e                	jmp    8012f9 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012cb:	8b 02                	mov    (%edx),%eax
  8012cd:	85 c0                	test   %eax,%eax
  8012cf:	75 e7                	jne    8012b8 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012d1:	a1 04 40 80 00       	mov    0x804004,%eax
  8012d6:	8b 40 48             	mov    0x48(%eax),%eax
  8012d9:	83 ec 04             	sub    $0x4,%esp
  8012dc:	51                   	push   %ecx
  8012dd:	50                   	push   %eax
  8012de:	68 b0 26 80 00       	push   $0x8026b0
  8012e3:	e8 a4 ef ff ff       	call   80028c <cprintf>
	*dev = 0;
  8012e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012eb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012f1:	83 c4 10             	add    $0x10,%esp
  8012f4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012f9:	c9                   	leave  
  8012fa:	c3                   	ret    

008012fb <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012fb:	55                   	push   %ebp
  8012fc:	89 e5                	mov    %esp,%ebp
  8012fe:	56                   	push   %esi
  8012ff:	53                   	push   %ebx
  801300:	83 ec 10             	sub    $0x10,%esp
  801303:	8b 75 08             	mov    0x8(%ebp),%esi
  801306:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801309:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80130c:	50                   	push   %eax
  80130d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801313:	c1 e8 0c             	shr    $0xc,%eax
  801316:	50                   	push   %eax
  801317:	e8 36 ff ff ff       	call   801252 <fd_lookup>
  80131c:	83 c4 08             	add    $0x8,%esp
  80131f:	85 c0                	test   %eax,%eax
  801321:	78 05                	js     801328 <fd_close+0x2d>
	    || fd != fd2)
  801323:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801326:	74 0c                	je     801334 <fd_close+0x39>
		return (must_exist ? r : 0);
  801328:	84 db                	test   %bl,%bl
  80132a:	ba 00 00 00 00       	mov    $0x0,%edx
  80132f:	0f 44 c2             	cmove  %edx,%eax
  801332:	eb 41                	jmp    801375 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801334:	83 ec 08             	sub    $0x8,%esp
  801337:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80133a:	50                   	push   %eax
  80133b:	ff 36                	pushl  (%esi)
  80133d:	e8 66 ff ff ff       	call   8012a8 <dev_lookup>
  801342:	89 c3                	mov    %eax,%ebx
  801344:	83 c4 10             	add    $0x10,%esp
  801347:	85 c0                	test   %eax,%eax
  801349:	78 1a                	js     801365 <fd_close+0x6a>
		if (dev->dev_close)
  80134b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80134e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801351:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801356:	85 c0                	test   %eax,%eax
  801358:	74 0b                	je     801365 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80135a:	83 ec 0c             	sub    $0xc,%esp
  80135d:	56                   	push   %esi
  80135e:	ff d0                	call   *%eax
  801360:	89 c3                	mov    %eax,%ebx
  801362:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801365:	83 ec 08             	sub    $0x8,%esp
  801368:	56                   	push   %esi
  801369:	6a 00                	push   $0x0
  80136b:	e8 a8 f9 ff ff       	call   800d18 <sys_page_unmap>
	return r;
  801370:	83 c4 10             	add    $0x10,%esp
  801373:	89 d8                	mov    %ebx,%eax
}
  801375:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801378:	5b                   	pop    %ebx
  801379:	5e                   	pop    %esi
  80137a:	5d                   	pop    %ebp
  80137b:	c3                   	ret    

0080137c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80137c:	55                   	push   %ebp
  80137d:	89 e5                	mov    %esp,%ebp
  80137f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801382:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801385:	50                   	push   %eax
  801386:	ff 75 08             	pushl  0x8(%ebp)
  801389:	e8 c4 fe ff ff       	call   801252 <fd_lookup>
  80138e:	83 c4 08             	add    $0x8,%esp
  801391:	85 c0                	test   %eax,%eax
  801393:	78 10                	js     8013a5 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801395:	83 ec 08             	sub    $0x8,%esp
  801398:	6a 01                	push   $0x1
  80139a:	ff 75 f4             	pushl  -0xc(%ebp)
  80139d:	e8 59 ff ff ff       	call   8012fb <fd_close>
  8013a2:	83 c4 10             	add    $0x10,%esp
}
  8013a5:	c9                   	leave  
  8013a6:	c3                   	ret    

008013a7 <close_all>:

void
close_all(void)
{
  8013a7:	55                   	push   %ebp
  8013a8:	89 e5                	mov    %esp,%ebp
  8013aa:	53                   	push   %ebx
  8013ab:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013ae:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013b3:	83 ec 0c             	sub    $0xc,%esp
  8013b6:	53                   	push   %ebx
  8013b7:	e8 c0 ff ff ff       	call   80137c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013bc:	83 c3 01             	add    $0x1,%ebx
  8013bf:	83 c4 10             	add    $0x10,%esp
  8013c2:	83 fb 20             	cmp    $0x20,%ebx
  8013c5:	75 ec                	jne    8013b3 <close_all+0xc>
		close(i);
}
  8013c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ca:	c9                   	leave  
  8013cb:	c3                   	ret    

008013cc <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013cc:	55                   	push   %ebp
  8013cd:	89 e5                	mov    %esp,%ebp
  8013cf:	57                   	push   %edi
  8013d0:	56                   	push   %esi
  8013d1:	53                   	push   %ebx
  8013d2:	83 ec 2c             	sub    $0x2c,%esp
  8013d5:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013d8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013db:	50                   	push   %eax
  8013dc:	ff 75 08             	pushl  0x8(%ebp)
  8013df:	e8 6e fe ff ff       	call   801252 <fd_lookup>
  8013e4:	83 c4 08             	add    $0x8,%esp
  8013e7:	85 c0                	test   %eax,%eax
  8013e9:	0f 88 c1 00 00 00    	js     8014b0 <dup+0xe4>
		return r;
	close(newfdnum);
  8013ef:	83 ec 0c             	sub    $0xc,%esp
  8013f2:	56                   	push   %esi
  8013f3:	e8 84 ff ff ff       	call   80137c <close>

	newfd = INDEX2FD(newfdnum);
  8013f8:	89 f3                	mov    %esi,%ebx
  8013fa:	c1 e3 0c             	shl    $0xc,%ebx
  8013fd:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801403:	83 c4 04             	add    $0x4,%esp
  801406:	ff 75 e4             	pushl  -0x1c(%ebp)
  801409:	e8 de fd ff ff       	call   8011ec <fd2data>
  80140e:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801410:	89 1c 24             	mov    %ebx,(%esp)
  801413:	e8 d4 fd ff ff       	call   8011ec <fd2data>
  801418:	83 c4 10             	add    $0x10,%esp
  80141b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80141e:	89 f8                	mov    %edi,%eax
  801420:	c1 e8 16             	shr    $0x16,%eax
  801423:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80142a:	a8 01                	test   $0x1,%al
  80142c:	74 37                	je     801465 <dup+0x99>
  80142e:	89 f8                	mov    %edi,%eax
  801430:	c1 e8 0c             	shr    $0xc,%eax
  801433:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80143a:	f6 c2 01             	test   $0x1,%dl
  80143d:	74 26                	je     801465 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80143f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801446:	83 ec 0c             	sub    $0xc,%esp
  801449:	25 07 0e 00 00       	and    $0xe07,%eax
  80144e:	50                   	push   %eax
  80144f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801452:	6a 00                	push   $0x0
  801454:	57                   	push   %edi
  801455:	6a 00                	push   $0x0
  801457:	e8 7a f8 ff ff       	call   800cd6 <sys_page_map>
  80145c:	89 c7                	mov    %eax,%edi
  80145e:	83 c4 20             	add    $0x20,%esp
  801461:	85 c0                	test   %eax,%eax
  801463:	78 2e                	js     801493 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801465:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801468:	89 d0                	mov    %edx,%eax
  80146a:	c1 e8 0c             	shr    $0xc,%eax
  80146d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801474:	83 ec 0c             	sub    $0xc,%esp
  801477:	25 07 0e 00 00       	and    $0xe07,%eax
  80147c:	50                   	push   %eax
  80147d:	53                   	push   %ebx
  80147e:	6a 00                	push   $0x0
  801480:	52                   	push   %edx
  801481:	6a 00                	push   $0x0
  801483:	e8 4e f8 ff ff       	call   800cd6 <sys_page_map>
  801488:	89 c7                	mov    %eax,%edi
  80148a:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80148d:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80148f:	85 ff                	test   %edi,%edi
  801491:	79 1d                	jns    8014b0 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801493:	83 ec 08             	sub    $0x8,%esp
  801496:	53                   	push   %ebx
  801497:	6a 00                	push   $0x0
  801499:	e8 7a f8 ff ff       	call   800d18 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80149e:	83 c4 08             	add    $0x8,%esp
  8014a1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014a4:	6a 00                	push   $0x0
  8014a6:	e8 6d f8 ff ff       	call   800d18 <sys_page_unmap>
	return r;
  8014ab:	83 c4 10             	add    $0x10,%esp
  8014ae:	89 f8                	mov    %edi,%eax
}
  8014b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014b3:	5b                   	pop    %ebx
  8014b4:	5e                   	pop    %esi
  8014b5:	5f                   	pop    %edi
  8014b6:	5d                   	pop    %ebp
  8014b7:	c3                   	ret    

008014b8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
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
  8014c7:	e8 86 fd ff ff       	call   801252 <fd_lookup>
  8014cc:	83 c4 08             	add    $0x8,%esp
  8014cf:	89 c2                	mov    %eax,%edx
  8014d1:	85 c0                	test   %eax,%eax
  8014d3:	78 6d                	js     801542 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014d5:	83 ec 08             	sub    $0x8,%esp
  8014d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014db:	50                   	push   %eax
  8014dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014df:	ff 30                	pushl  (%eax)
  8014e1:	e8 c2 fd ff ff       	call   8012a8 <dev_lookup>
  8014e6:	83 c4 10             	add    $0x10,%esp
  8014e9:	85 c0                	test   %eax,%eax
  8014eb:	78 4c                	js     801539 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014ed:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014f0:	8b 42 08             	mov    0x8(%edx),%eax
  8014f3:	83 e0 03             	and    $0x3,%eax
  8014f6:	83 f8 01             	cmp    $0x1,%eax
  8014f9:	75 21                	jne    80151c <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014fb:	a1 04 40 80 00       	mov    0x804004,%eax
  801500:	8b 40 48             	mov    0x48(%eax),%eax
  801503:	83 ec 04             	sub    $0x4,%esp
  801506:	53                   	push   %ebx
  801507:	50                   	push   %eax
  801508:	68 f1 26 80 00       	push   $0x8026f1
  80150d:	e8 7a ed ff ff       	call   80028c <cprintf>
		return -E_INVAL;
  801512:	83 c4 10             	add    $0x10,%esp
  801515:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80151a:	eb 26                	jmp    801542 <read+0x8a>
	}
	if (!dev->dev_read)
  80151c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80151f:	8b 40 08             	mov    0x8(%eax),%eax
  801522:	85 c0                	test   %eax,%eax
  801524:	74 17                	je     80153d <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801526:	83 ec 04             	sub    $0x4,%esp
  801529:	ff 75 10             	pushl  0x10(%ebp)
  80152c:	ff 75 0c             	pushl  0xc(%ebp)
  80152f:	52                   	push   %edx
  801530:	ff d0                	call   *%eax
  801532:	89 c2                	mov    %eax,%edx
  801534:	83 c4 10             	add    $0x10,%esp
  801537:	eb 09                	jmp    801542 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801539:	89 c2                	mov    %eax,%edx
  80153b:	eb 05                	jmp    801542 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80153d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801542:	89 d0                	mov    %edx,%eax
  801544:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801547:	c9                   	leave  
  801548:	c3                   	ret    

00801549 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801549:	55                   	push   %ebp
  80154a:	89 e5                	mov    %esp,%ebp
  80154c:	57                   	push   %edi
  80154d:	56                   	push   %esi
  80154e:	53                   	push   %ebx
  80154f:	83 ec 0c             	sub    $0xc,%esp
  801552:	8b 7d 08             	mov    0x8(%ebp),%edi
  801555:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801558:	bb 00 00 00 00       	mov    $0x0,%ebx
  80155d:	eb 21                	jmp    801580 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80155f:	83 ec 04             	sub    $0x4,%esp
  801562:	89 f0                	mov    %esi,%eax
  801564:	29 d8                	sub    %ebx,%eax
  801566:	50                   	push   %eax
  801567:	89 d8                	mov    %ebx,%eax
  801569:	03 45 0c             	add    0xc(%ebp),%eax
  80156c:	50                   	push   %eax
  80156d:	57                   	push   %edi
  80156e:	e8 45 ff ff ff       	call   8014b8 <read>
		if (m < 0)
  801573:	83 c4 10             	add    $0x10,%esp
  801576:	85 c0                	test   %eax,%eax
  801578:	78 10                	js     80158a <readn+0x41>
			return m;
		if (m == 0)
  80157a:	85 c0                	test   %eax,%eax
  80157c:	74 0a                	je     801588 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80157e:	01 c3                	add    %eax,%ebx
  801580:	39 f3                	cmp    %esi,%ebx
  801582:	72 db                	jb     80155f <readn+0x16>
  801584:	89 d8                	mov    %ebx,%eax
  801586:	eb 02                	jmp    80158a <readn+0x41>
  801588:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80158a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80158d:	5b                   	pop    %ebx
  80158e:	5e                   	pop    %esi
  80158f:	5f                   	pop    %edi
  801590:	5d                   	pop    %ebp
  801591:	c3                   	ret    

00801592 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801592:	55                   	push   %ebp
  801593:	89 e5                	mov    %esp,%ebp
  801595:	53                   	push   %ebx
  801596:	83 ec 14             	sub    $0x14,%esp
  801599:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80159c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80159f:	50                   	push   %eax
  8015a0:	53                   	push   %ebx
  8015a1:	e8 ac fc ff ff       	call   801252 <fd_lookup>
  8015a6:	83 c4 08             	add    $0x8,%esp
  8015a9:	89 c2                	mov    %eax,%edx
  8015ab:	85 c0                	test   %eax,%eax
  8015ad:	78 68                	js     801617 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015af:	83 ec 08             	sub    $0x8,%esp
  8015b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b5:	50                   	push   %eax
  8015b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b9:	ff 30                	pushl  (%eax)
  8015bb:	e8 e8 fc ff ff       	call   8012a8 <dev_lookup>
  8015c0:	83 c4 10             	add    $0x10,%esp
  8015c3:	85 c0                	test   %eax,%eax
  8015c5:	78 47                	js     80160e <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ca:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015ce:	75 21                	jne    8015f1 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015d0:	a1 04 40 80 00       	mov    0x804004,%eax
  8015d5:	8b 40 48             	mov    0x48(%eax),%eax
  8015d8:	83 ec 04             	sub    $0x4,%esp
  8015db:	53                   	push   %ebx
  8015dc:	50                   	push   %eax
  8015dd:	68 0d 27 80 00       	push   $0x80270d
  8015e2:	e8 a5 ec ff ff       	call   80028c <cprintf>
		return -E_INVAL;
  8015e7:	83 c4 10             	add    $0x10,%esp
  8015ea:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015ef:	eb 26                	jmp    801617 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015f4:	8b 52 0c             	mov    0xc(%edx),%edx
  8015f7:	85 d2                	test   %edx,%edx
  8015f9:	74 17                	je     801612 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015fb:	83 ec 04             	sub    $0x4,%esp
  8015fe:	ff 75 10             	pushl  0x10(%ebp)
  801601:	ff 75 0c             	pushl  0xc(%ebp)
  801604:	50                   	push   %eax
  801605:	ff d2                	call   *%edx
  801607:	89 c2                	mov    %eax,%edx
  801609:	83 c4 10             	add    $0x10,%esp
  80160c:	eb 09                	jmp    801617 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80160e:	89 c2                	mov    %eax,%edx
  801610:	eb 05                	jmp    801617 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801612:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801617:	89 d0                	mov    %edx,%eax
  801619:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80161c:	c9                   	leave  
  80161d:	c3                   	ret    

0080161e <seek>:

int
seek(int fdnum, off_t offset)
{
  80161e:	55                   	push   %ebp
  80161f:	89 e5                	mov    %esp,%ebp
  801621:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801624:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801627:	50                   	push   %eax
  801628:	ff 75 08             	pushl  0x8(%ebp)
  80162b:	e8 22 fc ff ff       	call   801252 <fd_lookup>
  801630:	83 c4 08             	add    $0x8,%esp
  801633:	85 c0                	test   %eax,%eax
  801635:	78 0e                	js     801645 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801637:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80163a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80163d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801640:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801645:	c9                   	leave  
  801646:	c3                   	ret    

00801647 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801647:	55                   	push   %ebp
  801648:	89 e5                	mov    %esp,%ebp
  80164a:	53                   	push   %ebx
  80164b:	83 ec 14             	sub    $0x14,%esp
  80164e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801651:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801654:	50                   	push   %eax
  801655:	53                   	push   %ebx
  801656:	e8 f7 fb ff ff       	call   801252 <fd_lookup>
  80165b:	83 c4 08             	add    $0x8,%esp
  80165e:	89 c2                	mov    %eax,%edx
  801660:	85 c0                	test   %eax,%eax
  801662:	78 65                	js     8016c9 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801664:	83 ec 08             	sub    $0x8,%esp
  801667:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80166a:	50                   	push   %eax
  80166b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80166e:	ff 30                	pushl  (%eax)
  801670:	e8 33 fc ff ff       	call   8012a8 <dev_lookup>
  801675:	83 c4 10             	add    $0x10,%esp
  801678:	85 c0                	test   %eax,%eax
  80167a:	78 44                	js     8016c0 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80167c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80167f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801683:	75 21                	jne    8016a6 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801685:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80168a:	8b 40 48             	mov    0x48(%eax),%eax
  80168d:	83 ec 04             	sub    $0x4,%esp
  801690:	53                   	push   %ebx
  801691:	50                   	push   %eax
  801692:	68 d0 26 80 00       	push   $0x8026d0
  801697:	e8 f0 eb ff ff       	call   80028c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80169c:	83 c4 10             	add    $0x10,%esp
  80169f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016a4:	eb 23                	jmp    8016c9 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016a9:	8b 52 18             	mov    0x18(%edx),%edx
  8016ac:	85 d2                	test   %edx,%edx
  8016ae:	74 14                	je     8016c4 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016b0:	83 ec 08             	sub    $0x8,%esp
  8016b3:	ff 75 0c             	pushl  0xc(%ebp)
  8016b6:	50                   	push   %eax
  8016b7:	ff d2                	call   *%edx
  8016b9:	89 c2                	mov    %eax,%edx
  8016bb:	83 c4 10             	add    $0x10,%esp
  8016be:	eb 09                	jmp    8016c9 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c0:	89 c2                	mov    %eax,%edx
  8016c2:	eb 05                	jmp    8016c9 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016c4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016c9:	89 d0                	mov    %edx,%eax
  8016cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ce:	c9                   	leave  
  8016cf:	c3                   	ret    

008016d0 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016d0:	55                   	push   %ebp
  8016d1:	89 e5                	mov    %esp,%ebp
  8016d3:	53                   	push   %ebx
  8016d4:	83 ec 14             	sub    $0x14,%esp
  8016d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016da:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016dd:	50                   	push   %eax
  8016de:	ff 75 08             	pushl  0x8(%ebp)
  8016e1:	e8 6c fb ff ff       	call   801252 <fd_lookup>
  8016e6:	83 c4 08             	add    $0x8,%esp
  8016e9:	89 c2                	mov    %eax,%edx
  8016eb:	85 c0                	test   %eax,%eax
  8016ed:	78 58                	js     801747 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ef:	83 ec 08             	sub    $0x8,%esp
  8016f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f5:	50                   	push   %eax
  8016f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f9:	ff 30                	pushl  (%eax)
  8016fb:	e8 a8 fb ff ff       	call   8012a8 <dev_lookup>
  801700:	83 c4 10             	add    $0x10,%esp
  801703:	85 c0                	test   %eax,%eax
  801705:	78 37                	js     80173e <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801707:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80170a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80170e:	74 32                	je     801742 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801710:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801713:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80171a:	00 00 00 
	stat->st_isdir = 0;
  80171d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801724:	00 00 00 
	stat->st_dev = dev;
  801727:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80172d:	83 ec 08             	sub    $0x8,%esp
  801730:	53                   	push   %ebx
  801731:	ff 75 f0             	pushl  -0x10(%ebp)
  801734:	ff 50 14             	call   *0x14(%eax)
  801737:	89 c2                	mov    %eax,%edx
  801739:	83 c4 10             	add    $0x10,%esp
  80173c:	eb 09                	jmp    801747 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80173e:	89 c2                	mov    %eax,%edx
  801740:	eb 05                	jmp    801747 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801742:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801747:	89 d0                	mov    %edx,%eax
  801749:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80174c:	c9                   	leave  
  80174d:	c3                   	ret    

0080174e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80174e:	55                   	push   %ebp
  80174f:	89 e5                	mov    %esp,%ebp
  801751:	56                   	push   %esi
  801752:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801753:	83 ec 08             	sub    $0x8,%esp
  801756:	6a 00                	push   $0x0
  801758:	ff 75 08             	pushl  0x8(%ebp)
  80175b:	e8 e3 01 00 00       	call   801943 <open>
  801760:	89 c3                	mov    %eax,%ebx
  801762:	83 c4 10             	add    $0x10,%esp
  801765:	85 c0                	test   %eax,%eax
  801767:	78 1b                	js     801784 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801769:	83 ec 08             	sub    $0x8,%esp
  80176c:	ff 75 0c             	pushl  0xc(%ebp)
  80176f:	50                   	push   %eax
  801770:	e8 5b ff ff ff       	call   8016d0 <fstat>
  801775:	89 c6                	mov    %eax,%esi
	close(fd);
  801777:	89 1c 24             	mov    %ebx,(%esp)
  80177a:	e8 fd fb ff ff       	call   80137c <close>
	return r;
  80177f:	83 c4 10             	add    $0x10,%esp
  801782:	89 f0                	mov    %esi,%eax
}
  801784:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801787:	5b                   	pop    %ebx
  801788:	5e                   	pop    %esi
  801789:	5d                   	pop    %ebp
  80178a:	c3                   	ret    

0080178b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80178b:	55                   	push   %ebp
  80178c:	89 e5                	mov    %esp,%ebp
  80178e:	56                   	push   %esi
  80178f:	53                   	push   %ebx
  801790:	89 c6                	mov    %eax,%esi
  801792:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801794:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80179b:	75 12                	jne    8017af <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80179d:	83 ec 0c             	sub    $0xc,%esp
  8017a0:	6a 01                	push   $0x1
  8017a2:	e8 fc f9 ff ff       	call   8011a3 <ipc_find_env>
  8017a7:	a3 00 40 80 00       	mov    %eax,0x804000
  8017ac:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017af:	6a 07                	push   $0x7
  8017b1:	68 00 50 80 00       	push   $0x805000
  8017b6:	56                   	push   %esi
  8017b7:	ff 35 00 40 80 00    	pushl  0x804000
  8017bd:	e8 8d f9 ff ff       	call   80114f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017c2:	83 c4 0c             	add    $0xc,%esp
  8017c5:	6a 00                	push   $0x0
  8017c7:	53                   	push   %ebx
  8017c8:	6a 00                	push   $0x0
  8017ca:	e8 0e f9 ff ff       	call   8010dd <ipc_recv>
}
  8017cf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017d2:	5b                   	pop    %ebx
  8017d3:	5e                   	pop    %esi
  8017d4:	5d                   	pop    %ebp
  8017d5:	c3                   	ret    

008017d6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017d6:	55                   	push   %ebp
  8017d7:	89 e5                	mov    %esp,%ebp
  8017d9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017df:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017ea:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f4:	b8 02 00 00 00       	mov    $0x2,%eax
  8017f9:	e8 8d ff ff ff       	call   80178b <fsipc>
}
  8017fe:	c9                   	leave  
  8017ff:	c3                   	ret    

00801800 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801800:	55                   	push   %ebp
  801801:	89 e5                	mov    %esp,%ebp
  801803:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801806:	8b 45 08             	mov    0x8(%ebp),%eax
  801809:	8b 40 0c             	mov    0xc(%eax),%eax
  80180c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801811:	ba 00 00 00 00       	mov    $0x0,%edx
  801816:	b8 06 00 00 00       	mov    $0x6,%eax
  80181b:	e8 6b ff ff ff       	call   80178b <fsipc>
}
  801820:	c9                   	leave  
  801821:	c3                   	ret    

00801822 <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801822:	55                   	push   %ebp
  801823:	89 e5                	mov    %esp,%ebp
  801825:	53                   	push   %ebx
  801826:	83 ec 04             	sub    $0x4,%esp
  801829:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80182c:	8b 45 08             	mov    0x8(%ebp),%eax
  80182f:	8b 40 0c             	mov    0xc(%eax),%eax
  801832:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801837:	ba 00 00 00 00       	mov    $0x0,%edx
  80183c:	b8 05 00 00 00       	mov    $0x5,%eax
  801841:	e8 45 ff ff ff       	call   80178b <fsipc>
  801846:	85 c0                	test   %eax,%eax
  801848:	78 2c                	js     801876 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80184a:	83 ec 08             	sub    $0x8,%esp
  80184d:	68 00 50 80 00       	push   $0x805000
  801852:	53                   	push   %ebx
  801853:	e8 38 f0 ff ff       	call   800890 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801858:	a1 80 50 80 00       	mov    0x805080,%eax
  80185d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801863:	a1 84 50 80 00       	mov    0x805084,%eax
  801868:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80186e:	83 c4 10             	add    $0x10,%esp
  801871:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801876:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801879:	c9                   	leave  
  80187a:	c3                   	ret    

0080187b <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80187b:	55                   	push   %ebp
  80187c:	89 e5                	mov    %esp,%ebp
  80187e:	83 ec 0c             	sub    $0xc,%esp
  801881:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	
	int r;

	n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  801884:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801889:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80188e:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801891:	8b 55 08             	mov    0x8(%ebp),%edx
  801894:	8b 52 0c             	mov    0xc(%edx),%edx
  801897:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80189d:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8018a2:	50                   	push   %eax
  8018a3:	ff 75 0c             	pushl  0xc(%ebp)
  8018a6:	68 08 50 80 00       	push   $0x805008
  8018ab:	e8 72 f1 ff ff       	call   800a22 <memmove>
	
	return fsipc(FSREQ_WRITE, NULL);	
  8018b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b5:	b8 04 00 00 00       	mov    $0x4,%eax
  8018ba:	e8 cc fe ff ff       	call   80178b <fsipc>
}
  8018bf:	c9                   	leave  
  8018c0:	c3                   	ret    

008018c1 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018c1:	55                   	push   %ebp
  8018c2:	89 e5                	mov    %esp,%ebp
  8018c4:	56                   	push   %esi
  8018c5:	53                   	push   %ebx
  8018c6:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018cc:	8b 40 0c             	mov    0xc(%eax),%eax
  8018cf:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018d4:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018da:	ba 00 00 00 00       	mov    $0x0,%edx
  8018df:	b8 03 00 00 00       	mov    $0x3,%eax
  8018e4:	e8 a2 fe ff ff       	call   80178b <fsipc>
  8018e9:	89 c3                	mov    %eax,%ebx
  8018eb:	85 c0                	test   %eax,%eax
  8018ed:	78 4b                	js     80193a <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018ef:	39 c6                	cmp    %eax,%esi
  8018f1:	73 16                	jae    801909 <devfile_read+0x48>
  8018f3:	68 3c 27 80 00       	push   $0x80273c
  8018f8:	68 43 27 80 00       	push   $0x802743
  8018fd:	6a 7c                	push   $0x7c
  8018ff:	68 58 27 80 00       	push   $0x802758
  801904:	e8 bd 05 00 00       	call   801ec6 <_panic>
	assert(r <= PGSIZE);
  801909:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80190e:	7e 16                	jle    801926 <devfile_read+0x65>
  801910:	68 63 27 80 00       	push   $0x802763
  801915:	68 43 27 80 00       	push   $0x802743
  80191a:	6a 7d                	push   $0x7d
  80191c:	68 58 27 80 00       	push   $0x802758
  801921:	e8 a0 05 00 00       	call   801ec6 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801926:	83 ec 04             	sub    $0x4,%esp
  801929:	50                   	push   %eax
  80192a:	68 00 50 80 00       	push   $0x805000
  80192f:	ff 75 0c             	pushl  0xc(%ebp)
  801932:	e8 eb f0 ff ff       	call   800a22 <memmove>
	return r;
  801937:	83 c4 10             	add    $0x10,%esp
}
  80193a:	89 d8                	mov    %ebx,%eax
  80193c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80193f:	5b                   	pop    %ebx
  801940:	5e                   	pop    %esi
  801941:	5d                   	pop    %ebp
  801942:	c3                   	ret    

00801943 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801943:	55                   	push   %ebp
  801944:	89 e5                	mov    %esp,%ebp
  801946:	53                   	push   %ebx
  801947:	83 ec 20             	sub    $0x20,%esp
  80194a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80194d:	53                   	push   %ebx
  80194e:	e8 04 ef ff ff       	call   800857 <strlen>
  801953:	83 c4 10             	add    $0x10,%esp
  801956:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80195b:	7f 67                	jg     8019c4 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80195d:	83 ec 0c             	sub    $0xc,%esp
  801960:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801963:	50                   	push   %eax
  801964:	e8 9a f8 ff ff       	call   801203 <fd_alloc>
  801969:	83 c4 10             	add    $0x10,%esp
		return r;
  80196c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80196e:	85 c0                	test   %eax,%eax
  801970:	78 57                	js     8019c9 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801972:	83 ec 08             	sub    $0x8,%esp
  801975:	53                   	push   %ebx
  801976:	68 00 50 80 00       	push   $0x805000
  80197b:	e8 10 ef ff ff       	call   800890 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801980:	8b 45 0c             	mov    0xc(%ebp),%eax
  801983:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801988:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80198b:	b8 01 00 00 00       	mov    $0x1,%eax
  801990:	e8 f6 fd ff ff       	call   80178b <fsipc>
  801995:	89 c3                	mov    %eax,%ebx
  801997:	83 c4 10             	add    $0x10,%esp
  80199a:	85 c0                	test   %eax,%eax
  80199c:	79 14                	jns    8019b2 <open+0x6f>
		fd_close(fd, 0);
  80199e:	83 ec 08             	sub    $0x8,%esp
  8019a1:	6a 00                	push   $0x0
  8019a3:	ff 75 f4             	pushl  -0xc(%ebp)
  8019a6:	e8 50 f9 ff ff       	call   8012fb <fd_close>
		return r;
  8019ab:	83 c4 10             	add    $0x10,%esp
  8019ae:	89 da                	mov    %ebx,%edx
  8019b0:	eb 17                	jmp    8019c9 <open+0x86>
	}

	return fd2num(fd);
  8019b2:	83 ec 0c             	sub    $0xc,%esp
  8019b5:	ff 75 f4             	pushl  -0xc(%ebp)
  8019b8:	e8 1f f8 ff ff       	call   8011dc <fd2num>
  8019bd:	89 c2                	mov    %eax,%edx
  8019bf:	83 c4 10             	add    $0x10,%esp
  8019c2:	eb 05                	jmp    8019c9 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019c4:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019c9:	89 d0                	mov    %edx,%eax
  8019cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019ce:	c9                   	leave  
  8019cf:	c3                   	ret    

008019d0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019d0:	55                   	push   %ebp
  8019d1:	89 e5                	mov    %esp,%ebp
  8019d3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8019db:	b8 08 00 00 00       	mov    $0x8,%eax
  8019e0:	e8 a6 fd ff ff       	call   80178b <fsipc>
}
  8019e5:	c9                   	leave  
  8019e6:	c3                   	ret    

008019e7 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019e7:	55                   	push   %ebp
  8019e8:	89 e5                	mov    %esp,%ebp
  8019ea:	56                   	push   %esi
  8019eb:	53                   	push   %ebx
  8019ec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019ef:	83 ec 0c             	sub    $0xc,%esp
  8019f2:	ff 75 08             	pushl  0x8(%ebp)
  8019f5:	e8 f2 f7 ff ff       	call   8011ec <fd2data>
  8019fa:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019fc:	83 c4 08             	add    $0x8,%esp
  8019ff:	68 6f 27 80 00       	push   $0x80276f
  801a04:	53                   	push   %ebx
  801a05:	e8 86 ee ff ff       	call   800890 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a0a:	8b 46 04             	mov    0x4(%esi),%eax
  801a0d:	2b 06                	sub    (%esi),%eax
  801a0f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a15:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a1c:	00 00 00 
	stat->st_dev = &devpipe;
  801a1f:	c7 83 88 00 00 00 28 	movl   $0x803028,0x88(%ebx)
  801a26:	30 80 00 
	return 0;
}
  801a29:	b8 00 00 00 00       	mov    $0x0,%eax
  801a2e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a31:	5b                   	pop    %ebx
  801a32:	5e                   	pop    %esi
  801a33:	5d                   	pop    %ebp
  801a34:	c3                   	ret    

00801a35 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a35:	55                   	push   %ebp
  801a36:	89 e5                	mov    %esp,%ebp
  801a38:	53                   	push   %ebx
  801a39:	83 ec 0c             	sub    $0xc,%esp
  801a3c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a3f:	53                   	push   %ebx
  801a40:	6a 00                	push   $0x0
  801a42:	e8 d1 f2 ff ff       	call   800d18 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a47:	89 1c 24             	mov    %ebx,(%esp)
  801a4a:	e8 9d f7 ff ff       	call   8011ec <fd2data>
  801a4f:	83 c4 08             	add    $0x8,%esp
  801a52:	50                   	push   %eax
  801a53:	6a 00                	push   $0x0
  801a55:	e8 be f2 ff ff       	call   800d18 <sys_page_unmap>
}
  801a5a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a5d:	c9                   	leave  
  801a5e:	c3                   	ret    

00801a5f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a5f:	55                   	push   %ebp
  801a60:	89 e5                	mov    %esp,%ebp
  801a62:	57                   	push   %edi
  801a63:	56                   	push   %esi
  801a64:	53                   	push   %ebx
  801a65:	83 ec 1c             	sub    $0x1c,%esp
  801a68:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a6b:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a6d:	a1 04 40 80 00       	mov    0x804004,%eax
  801a72:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a75:	83 ec 0c             	sub    $0xc,%esp
  801a78:	ff 75 e0             	pushl  -0x20(%ebp)
  801a7b:	e8 f7 04 00 00       	call   801f77 <pageref>
  801a80:	89 c3                	mov    %eax,%ebx
  801a82:	89 3c 24             	mov    %edi,(%esp)
  801a85:	e8 ed 04 00 00       	call   801f77 <pageref>
  801a8a:	83 c4 10             	add    $0x10,%esp
  801a8d:	39 c3                	cmp    %eax,%ebx
  801a8f:	0f 94 c1             	sete   %cl
  801a92:	0f b6 c9             	movzbl %cl,%ecx
  801a95:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a98:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a9e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801aa1:	39 ce                	cmp    %ecx,%esi
  801aa3:	74 1b                	je     801ac0 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801aa5:	39 c3                	cmp    %eax,%ebx
  801aa7:	75 c4                	jne    801a6d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801aa9:	8b 42 58             	mov    0x58(%edx),%eax
  801aac:	ff 75 e4             	pushl  -0x1c(%ebp)
  801aaf:	50                   	push   %eax
  801ab0:	56                   	push   %esi
  801ab1:	68 76 27 80 00       	push   $0x802776
  801ab6:	e8 d1 e7 ff ff       	call   80028c <cprintf>
  801abb:	83 c4 10             	add    $0x10,%esp
  801abe:	eb ad                	jmp    801a6d <_pipeisclosed+0xe>
	}
}
  801ac0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ac3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ac6:	5b                   	pop    %ebx
  801ac7:	5e                   	pop    %esi
  801ac8:	5f                   	pop    %edi
  801ac9:	5d                   	pop    %ebp
  801aca:	c3                   	ret    

00801acb <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801acb:	55                   	push   %ebp
  801acc:	89 e5                	mov    %esp,%ebp
  801ace:	57                   	push   %edi
  801acf:	56                   	push   %esi
  801ad0:	53                   	push   %ebx
  801ad1:	83 ec 28             	sub    $0x28,%esp
  801ad4:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ad7:	56                   	push   %esi
  801ad8:	e8 0f f7 ff ff       	call   8011ec <fd2data>
  801add:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801adf:	83 c4 10             	add    $0x10,%esp
  801ae2:	bf 00 00 00 00       	mov    $0x0,%edi
  801ae7:	eb 4b                	jmp    801b34 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ae9:	89 da                	mov    %ebx,%edx
  801aeb:	89 f0                	mov    %esi,%eax
  801aed:	e8 6d ff ff ff       	call   801a5f <_pipeisclosed>
  801af2:	85 c0                	test   %eax,%eax
  801af4:	75 48                	jne    801b3e <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801af6:	e8 79 f1 ff ff       	call   800c74 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801afb:	8b 43 04             	mov    0x4(%ebx),%eax
  801afe:	8b 0b                	mov    (%ebx),%ecx
  801b00:	8d 51 20             	lea    0x20(%ecx),%edx
  801b03:	39 d0                	cmp    %edx,%eax
  801b05:	73 e2                	jae    801ae9 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b0a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b0e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b11:	89 c2                	mov    %eax,%edx
  801b13:	c1 fa 1f             	sar    $0x1f,%edx
  801b16:	89 d1                	mov    %edx,%ecx
  801b18:	c1 e9 1b             	shr    $0x1b,%ecx
  801b1b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b1e:	83 e2 1f             	and    $0x1f,%edx
  801b21:	29 ca                	sub    %ecx,%edx
  801b23:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b27:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b2b:	83 c0 01             	add    $0x1,%eax
  801b2e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b31:	83 c7 01             	add    $0x1,%edi
  801b34:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b37:	75 c2                	jne    801afb <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b39:	8b 45 10             	mov    0x10(%ebp),%eax
  801b3c:	eb 05                	jmp    801b43 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b3e:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b46:	5b                   	pop    %ebx
  801b47:	5e                   	pop    %esi
  801b48:	5f                   	pop    %edi
  801b49:	5d                   	pop    %ebp
  801b4a:	c3                   	ret    

00801b4b <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b4b:	55                   	push   %ebp
  801b4c:	89 e5                	mov    %esp,%ebp
  801b4e:	57                   	push   %edi
  801b4f:	56                   	push   %esi
  801b50:	53                   	push   %ebx
  801b51:	83 ec 18             	sub    $0x18,%esp
  801b54:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b57:	57                   	push   %edi
  801b58:	e8 8f f6 ff ff       	call   8011ec <fd2data>
  801b5d:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b5f:	83 c4 10             	add    $0x10,%esp
  801b62:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b67:	eb 3d                	jmp    801ba6 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b69:	85 db                	test   %ebx,%ebx
  801b6b:	74 04                	je     801b71 <devpipe_read+0x26>
				return i;
  801b6d:	89 d8                	mov    %ebx,%eax
  801b6f:	eb 44                	jmp    801bb5 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b71:	89 f2                	mov    %esi,%edx
  801b73:	89 f8                	mov    %edi,%eax
  801b75:	e8 e5 fe ff ff       	call   801a5f <_pipeisclosed>
  801b7a:	85 c0                	test   %eax,%eax
  801b7c:	75 32                	jne    801bb0 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b7e:	e8 f1 f0 ff ff       	call   800c74 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b83:	8b 06                	mov    (%esi),%eax
  801b85:	3b 46 04             	cmp    0x4(%esi),%eax
  801b88:	74 df                	je     801b69 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b8a:	99                   	cltd   
  801b8b:	c1 ea 1b             	shr    $0x1b,%edx
  801b8e:	01 d0                	add    %edx,%eax
  801b90:	83 e0 1f             	and    $0x1f,%eax
  801b93:	29 d0                	sub    %edx,%eax
  801b95:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b9d:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ba0:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ba3:	83 c3 01             	add    $0x1,%ebx
  801ba6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ba9:	75 d8                	jne    801b83 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bab:	8b 45 10             	mov    0x10(%ebp),%eax
  801bae:	eb 05                	jmp    801bb5 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bb0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801bb5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bb8:	5b                   	pop    %ebx
  801bb9:	5e                   	pop    %esi
  801bba:	5f                   	pop    %edi
  801bbb:	5d                   	pop    %ebp
  801bbc:	c3                   	ret    

00801bbd <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bbd:	55                   	push   %ebp
  801bbe:	89 e5                	mov    %esp,%ebp
  801bc0:	56                   	push   %esi
  801bc1:	53                   	push   %ebx
  801bc2:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bc5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bc8:	50                   	push   %eax
  801bc9:	e8 35 f6 ff ff       	call   801203 <fd_alloc>
  801bce:	83 c4 10             	add    $0x10,%esp
  801bd1:	89 c2                	mov    %eax,%edx
  801bd3:	85 c0                	test   %eax,%eax
  801bd5:	0f 88 2c 01 00 00    	js     801d07 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bdb:	83 ec 04             	sub    $0x4,%esp
  801bde:	68 07 04 00 00       	push   $0x407
  801be3:	ff 75 f4             	pushl  -0xc(%ebp)
  801be6:	6a 00                	push   $0x0
  801be8:	e8 a6 f0 ff ff       	call   800c93 <sys_page_alloc>
  801bed:	83 c4 10             	add    $0x10,%esp
  801bf0:	89 c2                	mov    %eax,%edx
  801bf2:	85 c0                	test   %eax,%eax
  801bf4:	0f 88 0d 01 00 00    	js     801d07 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bfa:	83 ec 0c             	sub    $0xc,%esp
  801bfd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c00:	50                   	push   %eax
  801c01:	e8 fd f5 ff ff       	call   801203 <fd_alloc>
  801c06:	89 c3                	mov    %eax,%ebx
  801c08:	83 c4 10             	add    $0x10,%esp
  801c0b:	85 c0                	test   %eax,%eax
  801c0d:	0f 88 e2 00 00 00    	js     801cf5 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c13:	83 ec 04             	sub    $0x4,%esp
  801c16:	68 07 04 00 00       	push   $0x407
  801c1b:	ff 75 f0             	pushl  -0x10(%ebp)
  801c1e:	6a 00                	push   $0x0
  801c20:	e8 6e f0 ff ff       	call   800c93 <sys_page_alloc>
  801c25:	89 c3                	mov    %eax,%ebx
  801c27:	83 c4 10             	add    $0x10,%esp
  801c2a:	85 c0                	test   %eax,%eax
  801c2c:	0f 88 c3 00 00 00    	js     801cf5 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c32:	83 ec 0c             	sub    $0xc,%esp
  801c35:	ff 75 f4             	pushl  -0xc(%ebp)
  801c38:	e8 af f5 ff ff       	call   8011ec <fd2data>
  801c3d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c3f:	83 c4 0c             	add    $0xc,%esp
  801c42:	68 07 04 00 00       	push   $0x407
  801c47:	50                   	push   %eax
  801c48:	6a 00                	push   $0x0
  801c4a:	e8 44 f0 ff ff       	call   800c93 <sys_page_alloc>
  801c4f:	89 c3                	mov    %eax,%ebx
  801c51:	83 c4 10             	add    $0x10,%esp
  801c54:	85 c0                	test   %eax,%eax
  801c56:	0f 88 89 00 00 00    	js     801ce5 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c5c:	83 ec 0c             	sub    $0xc,%esp
  801c5f:	ff 75 f0             	pushl  -0x10(%ebp)
  801c62:	e8 85 f5 ff ff       	call   8011ec <fd2data>
  801c67:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c6e:	50                   	push   %eax
  801c6f:	6a 00                	push   $0x0
  801c71:	56                   	push   %esi
  801c72:	6a 00                	push   $0x0
  801c74:	e8 5d f0 ff ff       	call   800cd6 <sys_page_map>
  801c79:	89 c3                	mov    %eax,%ebx
  801c7b:	83 c4 20             	add    $0x20,%esp
  801c7e:	85 c0                	test   %eax,%eax
  801c80:	78 55                	js     801cd7 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c82:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801c88:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c8b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c90:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c97:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801c9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ca0:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ca2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ca5:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801cac:	83 ec 0c             	sub    $0xc,%esp
  801caf:	ff 75 f4             	pushl  -0xc(%ebp)
  801cb2:	e8 25 f5 ff ff       	call   8011dc <fd2num>
  801cb7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cba:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cbc:	83 c4 04             	add    $0x4,%esp
  801cbf:	ff 75 f0             	pushl  -0x10(%ebp)
  801cc2:	e8 15 f5 ff ff       	call   8011dc <fd2num>
  801cc7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cca:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ccd:	83 c4 10             	add    $0x10,%esp
  801cd0:	ba 00 00 00 00       	mov    $0x0,%edx
  801cd5:	eb 30                	jmp    801d07 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801cd7:	83 ec 08             	sub    $0x8,%esp
  801cda:	56                   	push   %esi
  801cdb:	6a 00                	push   $0x0
  801cdd:	e8 36 f0 ff ff       	call   800d18 <sys_page_unmap>
  801ce2:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ce5:	83 ec 08             	sub    $0x8,%esp
  801ce8:	ff 75 f0             	pushl  -0x10(%ebp)
  801ceb:	6a 00                	push   $0x0
  801ced:	e8 26 f0 ff ff       	call   800d18 <sys_page_unmap>
  801cf2:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801cf5:	83 ec 08             	sub    $0x8,%esp
  801cf8:	ff 75 f4             	pushl  -0xc(%ebp)
  801cfb:	6a 00                	push   $0x0
  801cfd:	e8 16 f0 ff ff       	call   800d18 <sys_page_unmap>
  801d02:	83 c4 10             	add    $0x10,%esp
  801d05:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d07:	89 d0                	mov    %edx,%eax
  801d09:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d0c:	5b                   	pop    %ebx
  801d0d:	5e                   	pop    %esi
  801d0e:	5d                   	pop    %ebp
  801d0f:	c3                   	ret    

00801d10 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d10:	55                   	push   %ebp
  801d11:	89 e5                	mov    %esp,%ebp
  801d13:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d16:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d19:	50                   	push   %eax
  801d1a:	ff 75 08             	pushl  0x8(%ebp)
  801d1d:	e8 30 f5 ff ff       	call   801252 <fd_lookup>
  801d22:	83 c4 10             	add    $0x10,%esp
  801d25:	85 c0                	test   %eax,%eax
  801d27:	78 18                	js     801d41 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d29:	83 ec 0c             	sub    $0xc,%esp
  801d2c:	ff 75 f4             	pushl  -0xc(%ebp)
  801d2f:	e8 b8 f4 ff ff       	call   8011ec <fd2data>
	return _pipeisclosed(fd, p);
  801d34:	89 c2                	mov    %eax,%edx
  801d36:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d39:	e8 21 fd ff ff       	call   801a5f <_pipeisclosed>
  801d3e:	83 c4 10             	add    $0x10,%esp
}
  801d41:	c9                   	leave  
  801d42:	c3                   	ret    

00801d43 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d43:	55                   	push   %ebp
  801d44:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d46:	b8 00 00 00 00       	mov    $0x0,%eax
  801d4b:	5d                   	pop    %ebp
  801d4c:	c3                   	ret    

00801d4d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d4d:	55                   	push   %ebp
  801d4e:	89 e5                	mov    %esp,%ebp
  801d50:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d53:	68 8e 27 80 00       	push   $0x80278e
  801d58:	ff 75 0c             	pushl  0xc(%ebp)
  801d5b:	e8 30 eb ff ff       	call   800890 <strcpy>
	return 0;
}
  801d60:	b8 00 00 00 00       	mov    $0x0,%eax
  801d65:	c9                   	leave  
  801d66:	c3                   	ret    

00801d67 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d67:	55                   	push   %ebp
  801d68:	89 e5                	mov    %esp,%ebp
  801d6a:	57                   	push   %edi
  801d6b:	56                   	push   %esi
  801d6c:	53                   	push   %ebx
  801d6d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d73:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d78:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d7e:	eb 2d                	jmp    801dad <devcons_write+0x46>
		m = n - tot;
  801d80:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d83:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d85:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d88:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d8d:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d90:	83 ec 04             	sub    $0x4,%esp
  801d93:	53                   	push   %ebx
  801d94:	03 45 0c             	add    0xc(%ebp),%eax
  801d97:	50                   	push   %eax
  801d98:	57                   	push   %edi
  801d99:	e8 84 ec ff ff       	call   800a22 <memmove>
		sys_cputs(buf, m);
  801d9e:	83 c4 08             	add    $0x8,%esp
  801da1:	53                   	push   %ebx
  801da2:	57                   	push   %edi
  801da3:	e8 2f ee ff ff       	call   800bd7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801da8:	01 de                	add    %ebx,%esi
  801daa:	83 c4 10             	add    $0x10,%esp
  801dad:	89 f0                	mov    %esi,%eax
  801daf:	3b 75 10             	cmp    0x10(%ebp),%esi
  801db2:	72 cc                	jb     801d80 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801db4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801db7:	5b                   	pop    %ebx
  801db8:	5e                   	pop    %esi
  801db9:	5f                   	pop    %edi
  801dba:	5d                   	pop    %ebp
  801dbb:	c3                   	ret    

00801dbc <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dbc:	55                   	push   %ebp
  801dbd:	89 e5                	mov    %esp,%ebp
  801dbf:	83 ec 08             	sub    $0x8,%esp
  801dc2:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801dc7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dcb:	74 2a                	je     801df7 <devcons_read+0x3b>
  801dcd:	eb 05                	jmp    801dd4 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801dcf:	e8 a0 ee ff ff       	call   800c74 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801dd4:	e8 1c ee ff ff       	call   800bf5 <sys_cgetc>
  801dd9:	85 c0                	test   %eax,%eax
  801ddb:	74 f2                	je     801dcf <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ddd:	85 c0                	test   %eax,%eax
  801ddf:	78 16                	js     801df7 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801de1:	83 f8 04             	cmp    $0x4,%eax
  801de4:	74 0c                	je     801df2 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801de6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801de9:	88 02                	mov    %al,(%edx)
	return 1;
  801deb:	b8 01 00 00 00       	mov    $0x1,%eax
  801df0:	eb 05                	jmp    801df7 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801df2:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801df7:	c9                   	leave  
  801df8:	c3                   	ret    

00801df9 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801df9:	55                   	push   %ebp
  801dfa:	89 e5                	mov    %esp,%ebp
  801dfc:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801dff:	8b 45 08             	mov    0x8(%ebp),%eax
  801e02:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e05:	6a 01                	push   $0x1
  801e07:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e0a:	50                   	push   %eax
  801e0b:	e8 c7 ed ff ff       	call   800bd7 <sys_cputs>
}
  801e10:	83 c4 10             	add    $0x10,%esp
  801e13:	c9                   	leave  
  801e14:	c3                   	ret    

00801e15 <getchar>:

int
getchar(void)
{
  801e15:	55                   	push   %ebp
  801e16:	89 e5                	mov    %esp,%ebp
  801e18:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e1b:	6a 01                	push   $0x1
  801e1d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e20:	50                   	push   %eax
  801e21:	6a 00                	push   $0x0
  801e23:	e8 90 f6 ff ff       	call   8014b8 <read>
	if (r < 0)
  801e28:	83 c4 10             	add    $0x10,%esp
  801e2b:	85 c0                	test   %eax,%eax
  801e2d:	78 0f                	js     801e3e <getchar+0x29>
		return r;
	if (r < 1)
  801e2f:	85 c0                	test   %eax,%eax
  801e31:	7e 06                	jle    801e39 <getchar+0x24>
		return -E_EOF;
	return c;
  801e33:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e37:	eb 05                	jmp    801e3e <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e39:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e3e:	c9                   	leave  
  801e3f:	c3                   	ret    

00801e40 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e40:	55                   	push   %ebp
  801e41:	89 e5                	mov    %esp,%ebp
  801e43:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e46:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e49:	50                   	push   %eax
  801e4a:	ff 75 08             	pushl  0x8(%ebp)
  801e4d:	e8 00 f4 ff ff       	call   801252 <fd_lookup>
  801e52:	83 c4 10             	add    $0x10,%esp
  801e55:	85 c0                	test   %eax,%eax
  801e57:	78 11                	js     801e6a <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e5c:	8b 15 44 30 80 00    	mov    0x803044,%edx
  801e62:	39 10                	cmp    %edx,(%eax)
  801e64:	0f 94 c0             	sete   %al
  801e67:	0f b6 c0             	movzbl %al,%eax
}
  801e6a:	c9                   	leave  
  801e6b:	c3                   	ret    

00801e6c <opencons>:

int
opencons(void)
{
  801e6c:	55                   	push   %ebp
  801e6d:	89 e5                	mov    %esp,%ebp
  801e6f:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e72:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e75:	50                   	push   %eax
  801e76:	e8 88 f3 ff ff       	call   801203 <fd_alloc>
  801e7b:	83 c4 10             	add    $0x10,%esp
		return r;
  801e7e:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e80:	85 c0                	test   %eax,%eax
  801e82:	78 3e                	js     801ec2 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e84:	83 ec 04             	sub    $0x4,%esp
  801e87:	68 07 04 00 00       	push   $0x407
  801e8c:	ff 75 f4             	pushl  -0xc(%ebp)
  801e8f:	6a 00                	push   $0x0
  801e91:	e8 fd ed ff ff       	call   800c93 <sys_page_alloc>
  801e96:	83 c4 10             	add    $0x10,%esp
		return r;
  801e99:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e9b:	85 c0                	test   %eax,%eax
  801e9d:	78 23                	js     801ec2 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e9f:	8b 15 44 30 80 00    	mov    0x803044,%edx
  801ea5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ea8:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801eaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ead:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801eb4:	83 ec 0c             	sub    $0xc,%esp
  801eb7:	50                   	push   %eax
  801eb8:	e8 1f f3 ff ff       	call   8011dc <fd2num>
  801ebd:	89 c2                	mov    %eax,%edx
  801ebf:	83 c4 10             	add    $0x10,%esp
}
  801ec2:	89 d0                	mov    %edx,%eax
  801ec4:	c9                   	leave  
  801ec5:	c3                   	ret    

00801ec6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ec6:	55                   	push   %ebp
  801ec7:	89 e5                	mov    %esp,%ebp
  801ec9:	56                   	push   %esi
  801eca:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801ecb:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ece:	8b 35 08 30 80 00    	mov    0x803008,%esi
  801ed4:	e8 7c ed ff ff       	call   800c55 <sys_getenvid>
  801ed9:	83 ec 0c             	sub    $0xc,%esp
  801edc:	ff 75 0c             	pushl  0xc(%ebp)
  801edf:	ff 75 08             	pushl  0x8(%ebp)
  801ee2:	56                   	push   %esi
  801ee3:	50                   	push   %eax
  801ee4:	68 9c 27 80 00       	push   $0x80279c
  801ee9:	e8 9e e3 ff ff       	call   80028c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801eee:	83 c4 18             	add    $0x18,%esp
  801ef1:	53                   	push   %ebx
  801ef2:	ff 75 10             	pushl  0x10(%ebp)
  801ef5:	e8 41 e3 ff ff       	call   80023b <vcprintf>
	cprintf("\n");
  801efa:	c7 04 24 87 27 80 00 	movl   $0x802787,(%esp)
  801f01:	e8 86 e3 ff ff       	call   80028c <cprintf>
  801f06:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f09:	cc                   	int3   
  801f0a:	eb fd                	jmp    801f09 <_panic+0x43>

00801f0c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f0c:	55                   	push   %ebp
  801f0d:	89 e5                	mov    %esp,%ebp
  801f0f:	53                   	push   %ebx
  801f10:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f13:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f1a:	75 28                	jne    801f44 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		void *va = (void *) (UXSTACKTOP - PGSIZE);
		envid_t envid = sys_getenvid();
  801f1c:	e8 34 ed ff ff       	call   800c55 <sys_getenvid>
  801f21:	89 c3                	mov    %eax,%ebx

		sys_page_alloc(envid, va, PTE_P | PTE_U | PTE_W);
  801f23:	83 ec 04             	sub    $0x4,%esp
  801f26:	6a 07                	push   $0x7
  801f28:	68 00 f0 bf ee       	push   $0xeebff000
  801f2d:	50                   	push   %eax
  801f2e:	e8 60 ed ff ff       	call   800c93 <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801f33:	83 c4 08             	add    $0x8,%esp
  801f36:	68 51 1f 80 00       	push   $0x801f51
  801f3b:	53                   	push   %ebx
  801f3c:	e8 9d ee ff ff       	call   800dde <sys_env_set_pgfault_upcall>
  801f41:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f44:	8b 45 08             	mov    0x8(%ebp),%eax
  801f47:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f4c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f4f:	c9                   	leave  
  801f50:	c3                   	ret    

00801f51 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp				// function argument: pointer to UTF
  801f51:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f52:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f57:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f59:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp, %ebx		// 40 = size between utf_fault_va ~ utf_regs
  801f5c:	89 e3                	mov    %esp,%ebx
	movl 40(%esp), %eax // point to utf_eip
  801f5e:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %esp // point to utf_esp
  801f62:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax 			// push eip of utf
  801f66:	50                   	push   %eax

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx, %esp 	// back to origin exception stack
  801f67:	89 dc                	mov    %ebx,%esp
	subl $4, 48(%esp) 	// utf_esp - 4
  801f69:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	popl %eax  			// pop utf_fault_va (ignore)
  801f6e:	58                   	pop    %eax
	popl %eax  			// pop utf_err (ignore)
  801f6f:	58                   	pop    %eax
	popal 				// pop utf_regs 
  801f70:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4, %esp 		// ignore utf_eip
  801f71:	83 c4 04             	add    $0x4,%esp
	popfl 				// restore utf_eflags to eflags
  801f74:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp  			// restore %esp = utf_esp
  801f75:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f76:	c3                   	ret    

00801f77 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f77:	55                   	push   %ebp
  801f78:	89 e5                	mov    %esp,%ebp
  801f7a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f7d:	89 d0                	mov    %edx,%eax
  801f7f:	c1 e8 16             	shr    $0x16,%eax
  801f82:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f89:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f8e:	f6 c1 01             	test   $0x1,%cl
  801f91:	74 1d                	je     801fb0 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f93:	c1 ea 0c             	shr    $0xc,%edx
  801f96:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f9d:	f6 c2 01             	test   $0x1,%dl
  801fa0:	74 0e                	je     801fb0 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fa2:	c1 ea 0c             	shr    $0xc,%edx
  801fa5:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fac:	ef 
  801fad:	0f b7 c0             	movzwl %ax,%eax
}
  801fb0:	5d                   	pop    %ebp
  801fb1:	c3                   	ret    
  801fb2:	66 90                	xchg   %ax,%ax
  801fb4:	66 90                	xchg   %ax,%ax
  801fb6:	66 90                	xchg   %ax,%ax
  801fb8:	66 90                	xchg   %ax,%ax
  801fba:	66 90                	xchg   %ax,%ax
  801fbc:	66 90                	xchg   %ax,%ax
  801fbe:	66 90                	xchg   %ax,%ax

00801fc0 <__udivdi3>:
  801fc0:	55                   	push   %ebp
  801fc1:	57                   	push   %edi
  801fc2:	56                   	push   %esi
  801fc3:	53                   	push   %ebx
  801fc4:	83 ec 1c             	sub    $0x1c,%esp
  801fc7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801fcb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fcf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fd7:	85 f6                	test   %esi,%esi
  801fd9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fdd:	89 ca                	mov    %ecx,%edx
  801fdf:	89 f8                	mov    %edi,%eax
  801fe1:	75 3d                	jne    802020 <__udivdi3+0x60>
  801fe3:	39 cf                	cmp    %ecx,%edi
  801fe5:	0f 87 c5 00 00 00    	ja     8020b0 <__udivdi3+0xf0>
  801feb:	85 ff                	test   %edi,%edi
  801fed:	89 fd                	mov    %edi,%ebp
  801fef:	75 0b                	jne    801ffc <__udivdi3+0x3c>
  801ff1:	b8 01 00 00 00       	mov    $0x1,%eax
  801ff6:	31 d2                	xor    %edx,%edx
  801ff8:	f7 f7                	div    %edi
  801ffa:	89 c5                	mov    %eax,%ebp
  801ffc:	89 c8                	mov    %ecx,%eax
  801ffe:	31 d2                	xor    %edx,%edx
  802000:	f7 f5                	div    %ebp
  802002:	89 c1                	mov    %eax,%ecx
  802004:	89 d8                	mov    %ebx,%eax
  802006:	89 cf                	mov    %ecx,%edi
  802008:	f7 f5                	div    %ebp
  80200a:	89 c3                	mov    %eax,%ebx
  80200c:	89 d8                	mov    %ebx,%eax
  80200e:	89 fa                	mov    %edi,%edx
  802010:	83 c4 1c             	add    $0x1c,%esp
  802013:	5b                   	pop    %ebx
  802014:	5e                   	pop    %esi
  802015:	5f                   	pop    %edi
  802016:	5d                   	pop    %ebp
  802017:	c3                   	ret    
  802018:	90                   	nop
  802019:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802020:	39 ce                	cmp    %ecx,%esi
  802022:	77 74                	ja     802098 <__udivdi3+0xd8>
  802024:	0f bd fe             	bsr    %esi,%edi
  802027:	83 f7 1f             	xor    $0x1f,%edi
  80202a:	0f 84 98 00 00 00    	je     8020c8 <__udivdi3+0x108>
  802030:	bb 20 00 00 00       	mov    $0x20,%ebx
  802035:	89 f9                	mov    %edi,%ecx
  802037:	89 c5                	mov    %eax,%ebp
  802039:	29 fb                	sub    %edi,%ebx
  80203b:	d3 e6                	shl    %cl,%esi
  80203d:	89 d9                	mov    %ebx,%ecx
  80203f:	d3 ed                	shr    %cl,%ebp
  802041:	89 f9                	mov    %edi,%ecx
  802043:	d3 e0                	shl    %cl,%eax
  802045:	09 ee                	or     %ebp,%esi
  802047:	89 d9                	mov    %ebx,%ecx
  802049:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80204d:	89 d5                	mov    %edx,%ebp
  80204f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802053:	d3 ed                	shr    %cl,%ebp
  802055:	89 f9                	mov    %edi,%ecx
  802057:	d3 e2                	shl    %cl,%edx
  802059:	89 d9                	mov    %ebx,%ecx
  80205b:	d3 e8                	shr    %cl,%eax
  80205d:	09 c2                	or     %eax,%edx
  80205f:	89 d0                	mov    %edx,%eax
  802061:	89 ea                	mov    %ebp,%edx
  802063:	f7 f6                	div    %esi
  802065:	89 d5                	mov    %edx,%ebp
  802067:	89 c3                	mov    %eax,%ebx
  802069:	f7 64 24 0c          	mull   0xc(%esp)
  80206d:	39 d5                	cmp    %edx,%ebp
  80206f:	72 10                	jb     802081 <__udivdi3+0xc1>
  802071:	8b 74 24 08          	mov    0x8(%esp),%esi
  802075:	89 f9                	mov    %edi,%ecx
  802077:	d3 e6                	shl    %cl,%esi
  802079:	39 c6                	cmp    %eax,%esi
  80207b:	73 07                	jae    802084 <__udivdi3+0xc4>
  80207d:	39 d5                	cmp    %edx,%ebp
  80207f:	75 03                	jne    802084 <__udivdi3+0xc4>
  802081:	83 eb 01             	sub    $0x1,%ebx
  802084:	31 ff                	xor    %edi,%edi
  802086:	89 d8                	mov    %ebx,%eax
  802088:	89 fa                	mov    %edi,%edx
  80208a:	83 c4 1c             	add    $0x1c,%esp
  80208d:	5b                   	pop    %ebx
  80208e:	5e                   	pop    %esi
  80208f:	5f                   	pop    %edi
  802090:	5d                   	pop    %ebp
  802091:	c3                   	ret    
  802092:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802098:	31 ff                	xor    %edi,%edi
  80209a:	31 db                	xor    %ebx,%ebx
  80209c:	89 d8                	mov    %ebx,%eax
  80209e:	89 fa                	mov    %edi,%edx
  8020a0:	83 c4 1c             	add    $0x1c,%esp
  8020a3:	5b                   	pop    %ebx
  8020a4:	5e                   	pop    %esi
  8020a5:	5f                   	pop    %edi
  8020a6:	5d                   	pop    %ebp
  8020a7:	c3                   	ret    
  8020a8:	90                   	nop
  8020a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020b0:	89 d8                	mov    %ebx,%eax
  8020b2:	f7 f7                	div    %edi
  8020b4:	31 ff                	xor    %edi,%edi
  8020b6:	89 c3                	mov    %eax,%ebx
  8020b8:	89 d8                	mov    %ebx,%eax
  8020ba:	89 fa                	mov    %edi,%edx
  8020bc:	83 c4 1c             	add    $0x1c,%esp
  8020bf:	5b                   	pop    %ebx
  8020c0:	5e                   	pop    %esi
  8020c1:	5f                   	pop    %edi
  8020c2:	5d                   	pop    %ebp
  8020c3:	c3                   	ret    
  8020c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020c8:	39 ce                	cmp    %ecx,%esi
  8020ca:	72 0c                	jb     8020d8 <__udivdi3+0x118>
  8020cc:	31 db                	xor    %ebx,%ebx
  8020ce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020d2:	0f 87 34 ff ff ff    	ja     80200c <__udivdi3+0x4c>
  8020d8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020dd:	e9 2a ff ff ff       	jmp    80200c <__udivdi3+0x4c>
  8020e2:	66 90                	xchg   %ax,%ax
  8020e4:	66 90                	xchg   %ax,%ax
  8020e6:	66 90                	xchg   %ax,%ax
  8020e8:	66 90                	xchg   %ax,%ax
  8020ea:	66 90                	xchg   %ax,%ax
  8020ec:	66 90                	xchg   %ax,%ax
  8020ee:	66 90                	xchg   %ax,%ax

008020f0 <__umoddi3>:
  8020f0:	55                   	push   %ebp
  8020f1:	57                   	push   %edi
  8020f2:	56                   	push   %esi
  8020f3:	53                   	push   %ebx
  8020f4:	83 ec 1c             	sub    $0x1c,%esp
  8020f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020fb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  802103:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802107:	85 d2                	test   %edx,%edx
  802109:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80210d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802111:	89 f3                	mov    %esi,%ebx
  802113:	89 3c 24             	mov    %edi,(%esp)
  802116:	89 74 24 04          	mov    %esi,0x4(%esp)
  80211a:	75 1c                	jne    802138 <__umoddi3+0x48>
  80211c:	39 f7                	cmp    %esi,%edi
  80211e:	76 50                	jbe    802170 <__umoddi3+0x80>
  802120:	89 c8                	mov    %ecx,%eax
  802122:	89 f2                	mov    %esi,%edx
  802124:	f7 f7                	div    %edi
  802126:	89 d0                	mov    %edx,%eax
  802128:	31 d2                	xor    %edx,%edx
  80212a:	83 c4 1c             	add    $0x1c,%esp
  80212d:	5b                   	pop    %ebx
  80212e:	5e                   	pop    %esi
  80212f:	5f                   	pop    %edi
  802130:	5d                   	pop    %ebp
  802131:	c3                   	ret    
  802132:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802138:	39 f2                	cmp    %esi,%edx
  80213a:	89 d0                	mov    %edx,%eax
  80213c:	77 52                	ja     802190 <__umoddi3+0xa0>
  80213e:	0f bd ea             	bsr    %edx,%ebp
  802141:	83 f5 1f             	xor    $0x1f,%ebp
  802144:	75 5a                	jne    8021a0 <__umoddi3+0xb0>
  802146:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80214a:	0f 82 e0 00 00 00    	jb     802230 <__umoddi3+0x140>
  802150:	39 0c 24             	cmp    %ecx,(%esp)
  802153:	0f 86 d7 00 00 00    	jbe    802230 <__umoddi3+0x140>
  802159:	8b 44 24 08          	mov    0x8(%esp),%eax
  80215d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802161:	83 c4 1c             	add    $0x1c,%esp
  802164:	5b                   	pop    %ebx
  802165:	5e                   	pop    %esi
  802166:	5f                   	pop    %edi
  802167:	5d                   	pop    %ebp
  802168:	c3                   	ret    
  802169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802170:	85 ff                	test   %edi,%edi
  802172:	89 fd                	mov    %edi,%ebp
  802174:	75 0b                	jne    802181 <__umoddi3+0x91>
  802176:	b8 01 00 00 00       	mov    $0x1,%eax
  80217b:	31 d2                	xor    %edx,%edx
  80217d:	f7 f7                	div    %edi
  80217f:	89 c5                	mov    %eax,%ebp
  802181:	89 f0                	mov    %esi,%eax
  802183:	31 d2                	xor    %edx,%edx
  802185:	f7 f5                	div    %ebp
  802187:	89 c8                	mov    %ecx,%eax
  802189:	f7 f5                	div    %ebp
  80218b:	89 d0                	mov    %edx,%eax
  80218d:	eb 99                	jmp    802128 <__umoddi3+0x38>
  80218f:	90                   	nop
  802190:	89 c8                	mov    %ecx,%eax
  802192:	89 f2                	mov    %esi,%edx
  802194:	83 c4 1c             	add    $0x1c,%esp
  802197:	5b                   	pop    %ebx
  802198:	5e                   	pop    %esi
  802199:	5f                   	pop    %edi
  80219a:	5d                   	pop    %ebp
  80219b:	c3                   	ret    
  80219c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021a0:	8b 34 24             	mov    (%esp),%esi
  8021a3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021a8:	89 e9                	mov    %ebp,%ecx
  8021aa:	29 ef                	sub    %ebp,%edi
  8021ac:	d3 e0                	shl    %cl,%eax
  8021ae:	89 f9                	mov    %edi,%ecx
  8021b0:	89 f2                	mov    %esi,%edx
  8021b2:	d3 ea                	shr    %cl,%edx
  8021b4:	89 e9                	mov    %ebp,%ecx
  8021b6:	09 c2                	or     %eax,%edx
  8021b8:	89 d8                	mov    %ebx,%eax
  8021ba:	89 14 24             	mov    %edx,(%esp)
  8021bd:	89 f2                	mov    %esi,%edx
  8021bf:	d3 e2                	shl    %cl,%edx
  8021c1:	89 f9                	mov    %edi,%ecx
  8021c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021c7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021cb:	d3 e8                	shr    %cl,%eax
  8021cd:	89 e9                	mov    %ebp,%ecx
  8021cf:	89 c6                	mov    %eax,%esi
  8021d1:	d3 e3                	shl    %cl,%ebx
  8021d3:	89 f9                	mov    %edi,%ecx
  8021d5:	89 d0                	mov    %edx,%eax
  8021d7:	d3 e8                	shr    %cl,%eax
  8021d9:	89 e9                	mov    %ebp,%ecx
  8021db:	09 d8                	or     %ebx,%eax
  8021dd:	89 d3                	mov    %edx,%ebx
  8021df:	89 f2                	mov    %esi,%edx
  8021e1:	f7 34 24             	divl   (%esp)
  8021e4:	89 d6                	mov    %edx,%esi
  8021e6:	d3 e3                	shl    %cl,%ebx
  8021e8:	f7 64 24 04          	mull   0x4(%esp)
  8021ec:	39 d6                	cmp    %edx,%esi
  8021ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021f2:	89 d1                	mov    %edx,%ecx
  8021f4:	89 c3                	mov    %eax,%ebx
  8021f6:	72 08                	jb     802200 <__umoddi3+0x110>
  8021f8:	75 11                	jne    80220b <__umoddi3+0x11b>
  8021fa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021fe:	73 0b                	jae    80220b <__umoddi3+0x11b>
  802200:	2b 44 24 04          	sub    0x4(%esp),%eax
  802204:	1b 14 24             	sbb    (%esp),%edx
  802207:	89 d1                	mov    %edx,%ecx
  802209:	89 c3                	mov    %eax,%ebx
  80220b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80220f:	29 da                	sub    %ebx,%edx
  802211:	19 ce                	sbb    %ecx,%esi
  802213:	89 f9                	mov    %edi,%ecx
  802215:	89 f0                	mov    %esi,%eax
  802217:	d3 e0                	shl    %cl,%eax
  802219:	89 e9                	mov    %ebp,%ecx
  80221b:	d3 ea                	shr    %cl,%edx
  80221d:	89 e9                	mov    %ebp,%ecx
  80221f:	d3 ee                	shr    %cl,%esi
  802221:	09 d0                	or     %edx,%eax
  802223:	89 f2                	mov    %esi,%edx
  802225:	83 c4 1c             	add    $0x1c,%esp
  802228:	5b                   	pop    %ebx
  802229:	5e                   	pop    %esi
  80222a:	5f                   	pop    %edi
  80222b:	5d                   	pop    %ebp
  80222c:	c3                   	ret    
  80222d:	8d 76 00             	lea    0x0(%esi),%esi
  802230:	29 f9                	sub    %edi,%ecx
  802232:	19 d6                	sbb    %edx,%esi
  802234:	89 74 24 04          	mov    %esi,0x4(%esp)
  802238:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80223c:	e9 18 ff ff ff       	jmp    802159 <__umoddi3+0x69>
