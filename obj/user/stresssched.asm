
obj/user/stresssched.debug：     文件格式 elf32-i386


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
  80002c:	e8 bc 00 00 00       	call   8000ed <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800038:	e8 b2 0b 00 00       	call   800bef <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80003f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800044:	e8 7a 0e 00 00       	call   800ec3 <fork>
  800049:	85 c0                	test   %eax,%eax
  80004b:	74 0a                	je     800057 <umain+0x24>
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();

	// Fork several environments
	for (i = 0; i < 20; i++)
  80004d:	83 c3 01             	add    $0x1,%ebx
  800050:	83 fb 14             	cmp    $0x14,%ebx
  800053:	75 ef                	jne    800044 <umain+0x11>
  800055:	eb 05                	jmp    80005c <umain+0x29>
		if (fork() == 0)
			break;
	if (i == 20) {
  800057:	83 fb 14             	cmp    $0x14,%ebx
  80005a:	75 0e                	jne    80006a <umain+0x37>
		sys_yield();
  80005c:	e8 ad 0b 00 00       	call   800c0e <sys_yield>
		return;
  800061:	e9 80 00 00 00       	jmp    8000e6 <umain+0xb3>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");
  800066:	f3 90                	pause  
  800068:	eb 0f                	jmp    800079 <umain+0x46>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80006a:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800070:	6b d6 7c             	imul   $0x7c,%esi,%edx
  800073:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800079:	8b 42 54             	mov    0x54(%edx),%eax
  80007c:	85 c0                	test   %eax,%eax
  80007e:	75 e6                	jne    800066 <umain+0x33>
  800080:	bb 0a 00 00 00       	mov    $0xa,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  800085:	e8 84 0b 00 00       	call   800c0e <sys_yield>
  80008a:	ba 10 27 00 00       	mov    $0x2710,%edx
		for (j = 0; j < 10000; j++)
			counter++;
  80008f:	a1 04 40 80 00       	mov    0x804004,%eax
  800094:	83 c0 01             	add    $0x1,%eax
  800097:	a3 04 40 80 00       	mov    %eax,0x804004
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  80009c:	83 ea 01             	sub    $0x1,%edx
  80009f:	75 ee                	jne    80008f <umain+0x5c>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000a1:	83 eb 01             	sub    $0x1,%ebx
  8000a4:	75 df                	jne    800085 <umain+0x52>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000a6:	a1 04 40 80 00       	mov    0x804004,%eax
  8000ab:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000b0:	74 17                	je     8000c9 <umain+0x96>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000b2:	a1 04 40 80 00       	mov    0x804004,%eax
  8000b7:	50                   	push   %eax
  8000b8:	68 a0 21 80 00       	push   $0x8021a0
  8000bd:	6a 21                	push   $0x21
  8000bf:	68 c8 21 80 00       	push   $0x8021c8
  8000c4:	e8 84 00 00 00       	call   80014d <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000c9:	a1 08 40 80 00       	mov    0x804008,%eax
  8000ce:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000d1:	8b 40 48             	mov    0x48(%eax),%eax
  8000d4:	83 ec 04             	sub    $0x4,%esp
  8000d7:	52                   	push   %edx
  8000d8:	50                   	push   %eax
  8000d9:	68 db 21 80 00       	push   $0x8021db
  8000de:	e8 43 01 00 00       	call   800226 <cprintf>
  8000e3:	83 c4 10             	add    $0x10,%esp

}
  8000e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e9:	5b                   	pop    %ebx
  8000ea:	5e                   	pop    %esi
  8000eb:	5d                   	pop    %ebp
  8000ec:	c3                   	ret    

008000ed <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ed:	55                   	push   %ebp
  8000ee:	89 e5                	mov    %esp,%ebp
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
  8000f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000f5:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000f8:	e8 f2 0a 00 00       	call   800bef <sys_getenvid>
  8000fd:	25 ff 03 00 00       	and    $0x3ff,%eax
  800102:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800105:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80010a:	a3 08 40 80 00       	mov    %eax,0x804008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010f:	85 db                	test   %ebx,%ebx
  800111:	7e 07                	jle    80011a <libmain+0x2d>
		binaryname = argv[0];
  800113:	8b 06                	mov    (%esi),%eax
  800115:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80011a:	83 ec 08             	sub    $0x8,%esp
  80011d:	56                   	push   %esi
  80011e:	53                   	push   %ebx
  80011f:	e8 0f ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800124:	e8 0a 00 00 00       	call   800133 <exit>
}
  800129:	83 c4 10             	add    $0x10,%esp
  80012c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80012f:	5b                   	pop    %ebx
  800130:	5e                   	pop    %esi
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800139:	e8 04 11 00 00       	call   801242 <close_all>
	sys_env_destroy(0);
  80013e:	83 ec 0c             	sub    $0xc,%esp
  800141:	6a 00                	push   $0x0
  800143:	e8 66 0a 00 00       	call   800bae <sys_env_destroy>
}
  800148:	83 c4 10             	add    $0x10,%esp
  80014b:	c9                   	leave  
  80014c:	c3                   	ret    

0080014d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	56                   	push   %esi
  800151:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800152:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800155:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80015b:	e8 8f 0a 00 00       	call   800bef <sys_getenvid>
  800160:	83 ec 0c             	sub    $0xc,%esp
  800163:	ff 75 0c             	pushl  0xc(%ebp)
  800166:	ff 75 08             	pushl  0x8(%ebp)
  800169:	56                   	push   %esi
  80016a:	50                   	push   %eax
  80016b:	68 04 22 80 00       	push   $0x802204
  800170:	e8 b1 00 00 00       	call   800226 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800175:	83 c4 18             	add    $0x18,%esp
  800178:	53                   	push   %ebx
  800179:	ff 75 10             	pushl  0x10(%ebp)
  80017c:	e8 54 00 00 00       	call   8001d5 <vcprintf>
	cprintf("\n");
  800181:	c7 04 24 f7 21 80 00 	movl   $0x8021f7,(%esp)
  800188:	e8 99 00 00 00       	call   800226 <cprintf>
  80018d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800190:	cc                   	int3   
  800191:	eb fd                	jmp    800190 <_panic+0x43>

00800193 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	53                   	push   %ebx
  800197:	83 ec 04             	sub    $0x4,%esp
  80019a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80019d:	8b 13                	mov    (%ebx),%edx
  80019f:	8d 42 01             	lea    0x1(%edx),%eax
  8001a2:	89 03                	mov    %eax,(%ebx)
  8001a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001ab:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b0:	75 1a                	jne    8001cc <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001b2:	83 ec 08             	sub    $0x8,%esp
  8001b5:	68 ff 00 00 00       	push   $0xff
  8001ba:	8d 43 08             	lea    0x8(%ebx),%eax
  8001bd:	50                   	push   %eax
  8001be:	e8 ae 09 00 00       	call   800b71 <sys_cputs>
		b->idx = 0;
  8001c3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c9:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001cc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001d3:	c9                   	leave  
  8001d4:	c3                   	ret    

008001d5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d5:	55                   	push   %ebp
  8001d6:	89 e5                	mov    %esp,%ebp
  8001d8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001de:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e5:	00 00 00 
	b.cnt = 0;
  8001e8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ef:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f2:	ff 75 0c             	pushl  0xc(%ebp)
  8001f5:	ff 75 08             	pushl  0x8(%ebp)
  8001f8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001fe:	50                   	push   %eax
  8001ff:	68 93 01 80 00       	push   $0x800193
  800204:	e8 1a 01 00 00       	call   800323 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800209:	83 c4 08             	add    $0x8,%esp
  80020c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800212:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800218:	50                   	push   %eax
  800219:	e8 53 09 00 00       	call   800b71 <sys_cputs>

	return b.cnt;
}
  80021e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800224:	c9                   	leave  
  800225:	c3                   	ret    

00800226 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
  800229:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80022c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80022f:	50                   	push   %eax
  800230:	ff 75 08             	pushl  0x8(%ebp)
  800233:	e8 9d ff ff ff       	call   8001d5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800238:	c9                   	leave  
  800239:	c3                   	ret    

0080023a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80023a:	55                   	push   %ebp
  80023b:	89 e5                	mov    %esp,%ebp
  80023d:	57                   	push   %edi
  80023e:	56                   	push   %esi
  80023f:	53                   	push   %ebx
  800240:	83 ec 1c             	sub    $0x1c,%esp
  800243:	89 c7                	mov    %eax,%edi
  800245:	89 d6                	mov    %edx,%esi
  800247:	8b 45 08             	mov    0x8(%ebp),%eax
  80024a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80024d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800250:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800253:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800256:	bb 00 00 00 00       	mov    $0x0,%ebx
  80025b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80025e:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800261:	39 d3                	cmp    %edx,%ebx
  800263:	72 05                	jb     80026a <printnum+0x30>
  800265:	39 45 10             	cmp    %eax,0x10(%ebp)
  800268:	77 45                	ja     8002af <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80026a:	83 ec 0c             	sub    $0xc,%esp
  80026d:	ff 75 18             	pushl  0x18(%ebp)
  800270:	8b 45 14             	mov    0x14(%ebp),%eax
  800273:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800276:	53                   	push   %ebx
  800277:	ff 75 10             	pushl  0x10(%ebp)
  80027a:	83 ec 08             	sub    $0x8,%esp
  80027d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800280:	ff 75 e0             	pushl  -0x20(%ebp)
  800283:	ff 75 dc             	pushl  -0x24(%ebp)
  800286:	ff 75 d8             	pushl  -0x28(%ebp)
  800289:	e8 82 1c 00 00       	call   801f10 <__udivdi3>
  80028e:	83 c4 18             	add    $0x18,%esp
  800291:	52                   	push   %edx
  800292:	50                   	push   %eax
  800293:	89 f2                	mov    %esi,%edx
  800295:	89 f8                	mov    %edi,%eax
  800297:	e8 9e ff ff ff       	call   80023a <printnum>
  80029c:	83 c4 20             	add    $0x20,%esp
  80029f:	eb 18                	jmp    8002b9 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a1:	83 ec 08             	sub    $0x8,%esp
  8002a4:	56                   	push   %esi
  8002a5:	ff 75 18             	pushl  0x18(%ebp)
  8002a8:	ff d7                	call   *%edi
  8002aa:	83 c4 10             	add    $0x10,%esp
  8002ad:	eb 03                	jmp    8002b2 <printnum+0x78>
  8002af:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b2:	83 eb 01             	sub    $0x1,%ebx
  8002b5:	85 db                	test   %ebx,%ebx
  8002b7:	7f e8                	jg     8002a1 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b9:	83 ec 08             	sub    $0x8,%esp
  8002bc:	56                   	push   %esi
  8002bd:	83 ec 04             	sub    $0x4,%esp
  8002c0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c3:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c6:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c9:	ff 75 d8             	pushl  -0x28(%ebp)
  8002cc:	e8 6f 1d 00 00       	call   802040 <__umoddi3>
  8002d1:	83 c4 14             	add    $0x14,%esp
  8002d4:	0f be 80 27 22 80 00 	movsbl 0x802227(%eax),%eax
  8002db:	50                   	push   %eax
  8002dc:	ff d7                	call   *%edi
}
  8002de:	83 c4 10             	add    $0x10,%esp
  8002e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e4:	5b                   	pop    %ebx
  8002e5:	5e                   	pop    %esi
  8002e6:	5f                   	pop    %edi
  8002e7:	5d                   	pop    %ebp
  8002e8:	c3                   	ret    

008002e9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002e9:	55                   	push   %ebp
  8002ea:	89 e5                	mov    %esp,%ebp
  8002ec:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002ef:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002f3:	8b 10                	mov    (%eax),%edx
  8002f5:	3b 50 04             	cmp    0x4(%eax),%edx
  8002f8:	73 0a                	jae    800304 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002fa:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002fd:	89 08                	mov    %ecx,(%eax)
  8002ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800302:	88 02                	mov    %al,(%edx)
}
  800304:	5d                   	pop    %ebp
  800305:	c3                   	ret    

00800306 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800306:	55                   	push   %ebp
  800307:	89 e5                	mov    %esp,%ebp
  800309:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80030c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80030f:	50                   	push   %eax
  800310:	ff 75 10             	pushl  0x10(%ebp)
  800313:	ff 75 0c             	pushl  0xc(%ebp)
  800316:	ff 75 08             	pushl  0x8(%ebp)
  800319:	e8 05 00 00 00       	call   800323 <vprintfmt>
	va_end(ap);
}
  80031e:	83 c4 10             	add    $0x10,%esp
  800321:	c9                   	leave  
  800322:	c3                   	ret    

00800323 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	57                   	push   %edi
  800327:	56                   	push   %esi
  800328:	53                   	push   %ebx
  800329:	83 ec 2c             	sub    $0x2c,%esp
  80032c:	8b 75 08             	mov    0x8(%ebp),%esi
  80032f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800332:	8b 7d 10             	mov    0x10(%ebp),%edi
  800335:	eb 12                	jmp    800349 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800337:	85 c0                	test   %eax,%eax
  800339:	0f 84 42 04 00 00    	je     800781 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  80033f:	83 ec 08             	sub    $0x8,%esp
  800342:	53                   	push   %ebx
  800343:	50                   	push   %eax
  800344:	ff d6                	call   *%esi
  800346:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800349:	83 c7 01             	add    $0x1,%edi
  80034c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800350:	83 f8 25             	cmp    $0x25,%eax
  800353:	75 e2                	jne    800337 <vprintfmt+0x14>
  800355:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800359:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800360:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800367:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80036e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800373:	eb 07                	jmp    80037c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800375:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800378:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037c:	8d 47 01             	lea    0x1(%edi),%eax
  80037f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800382:	0f b6 07             	movzbl (%edi),%eax
  800385:	0f b6 d0             	movzbl %al,%edx
  800388:	83 e8 23             	sub    $0x23,%eax
  80038b:	3c 55                	cmp    $0x55,%al
  80038d:	0f 87 d3 03 00 00    	ja     800766 <vprintfmt+0x443>
  800393:	0f b6 c0             	movzbl %al,%eax
  800396:	ff 24 85 60 23 80 00 	jmp    *0x802360(,%eax,4)
  80039d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003a0:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003a4:	eb d6                	jmp    80037c <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ae:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003b1:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003b4:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003b8:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003bb:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003be:	83 f9 09             	cmp    $0x9,%ecx
  8003c1:	77 3f                	ja     800402 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003c3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003c6:	eb e9                	jmp    8003b1 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cb:	8b 00                	mov    (%eax),%eax
  8003cd:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d3:	8d 40 04             	lea    0x4(%eax),%eax
  8003d6:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003dc:	eb 2a                	jmp    800408 <vprintfmt+0xe5>
  8003de:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e1:	85 c0                	test   %eax,%eax
  8003e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8003e8:	0f 49 d0             	cmovns %eax,%edx
  8003eb:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003f1:	eb 89                	jmp    80037c <vprintfmt+0x59>
  8003f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003f6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003fd:	e9 7a ff ff ff       	jmp    80037c <vprintfmt+0x59>
  800402:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800405:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800408:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80040c:	0f 89 6a ff ff ff    	jns    80037c <vprintfmt+0x59>
				width = precision, precision = -1;
  800412:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800415:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800418:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80041f:	e9 58 ff ff ff       	jmp    80037c <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800424:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800427:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80042a:	e9 4d ff ff ff       	jmp    80037c <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80042f:	8b 45 14             	mov    0x14(%ebp),%eax
  800432:	8d 78 04             	lea    0x4(%eax),%edi
  800435:	83 ec 08             	sub    $0x8,%esp
  800438:	53                   	push   %ebx
  800439:	ff 30                	pushl  (%eax)
  80043b:	ff d6                	call   *%esi
			break;
  80043d:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800440:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800443:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800446:	e9 fe fe ff ff       	jmp    800349 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80044b:	8b 45 14             	mov    0x14(%ebp),%eax
  80044e:	8d 78 04             	lea    0x4(%eax),%edi
  800451:	8b 00                	mov    (%eax),%eax
  800453:	99                   	cltd   
  800454:	31 d0                	xor    %edx,%eax
  800456:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800458:	83 f8 0f             	cmp    $0xf,%eax
  80045b:	7f 0b                	jg     800468 <vprintfmt+0x145>
  80045d:	8b 14 85 c0 24 80 00 	mov    0x8024c0(,%eax,4),%edx
  800464:	85 d2                	test   %edx,%edx
  800466:	75 1b                	jne    800483 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800468:	50                   	push   %eax
  800469:	68 3f 22 80 00       	push   $0x80223f
  80046e:	53                   	push   %ebx
  80046f:	56                   	push   %esi
  800470:	e8 91 fe ff ff       	call   800306 <printfmt>
  800475:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800478:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80047e:	e9 c6 fe ff ff       	jmp    800349 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800483:	52                   	push   %edx
  800484:	68 5d 26 80 00       	push   $0x80265d
  800489:	53                   	push   %ebx
  80048a:	56                   	push   %esi
  80048b:	e8 76 fe ff ff       	call   800306 <printfmt>
  800490:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800493:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800496:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800499:	e9 ab fe ff ff       	jmp    800349 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80049e:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a1:	83 c0 04             	add    $0x4,%eax
  8004a4:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8004a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004aa:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004ac:	85 ff                	test   %edi,%edi
  8004ae:	b8 38 22 80 00       	mov    $0x802238,%eax
  8004b3:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004b6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004ba:	0f 8e 94 00 00 00    	jle    800554 <vprintfmt+0x231>
  8004c0:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004c4:	0f 84 98 00 00 00    	je     800562 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ca:	83 ec 08             	sub    $0x8,%esp
  8004cd:	ff 75 d0             	pushl  -0x30(%ebp)
  8004d0:	57                   	push   %edi
  8004d1:	e8 33 03 00 00       	call   800809 <strnlen>
  8004d6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004d9:	29 c1                	sub    %eax,%ecx
  8004db:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004de:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004e1:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004e5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e8:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004eb:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ed:	eb 0f                	jmp    8004fe <vprintfmt+0x1db>
					putch(padc, putdat);
  8004ef:	83 ec 08             	sub    $0x8,%esp
  8004f2:	53                   	push   %ebx
  8004f3:	ff 75 e0             	pushl  -0x20(%ebp)
  8004f6:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f8:	83 ef 01             	sub    $0x1,%edi
  8004fb:	83 c4 10             	add    $0x10,%esp
  8004fe:	85 ff                	test   %edi,%edi
  800500:	7f ed                	jg     8004ef <vprintfmt+0x1cc>
  800502:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800505:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800508:	85 c9                	test   %ecx,%ecx
  80050a:	b8 00 00 00 00       	mov    $0x0,%eax
  80050f:	0f 49 c1             	cmovns %ecx,%eax
  800512:	29 c1                	sub    %eax,%ecx
  800514:	89 75 08             	mov    %esi,0x8(%ebp)
  800517:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80051a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80051d:	89 cb                	mov    %ecx,%ebx
  80051f:	eb 4d                	jmp    80056e <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800521:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800525:	74 1b                	je     800542 <vprintfmt+0x21f>
  800527:	0f be c0             	movsbl %al,%eax
  80052a:	83 e8 20             	sub    $0x20,%eax
  80052d:	83 f8 5e             	cmp    $0x5e,%eax
  800530:	76 10                	jbe    800542 <vprintfmt+0x21f>
					putch('?', putdat);
  800532:	83 ec 08             	sub    $0x8,%esp
  800535:	ff 75 0c             	pushl  0xc(%ebp)
  800538:	6a 3f                	push   $0x3f
  80053a:	ff 55 08             	call   *0x8(%ebp)
  80053d:	83 c4 10             	add    $0x10,%esp
  800540:	eb 0d                	jmp    80054f <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800542:	83 ec 08             	sub    $0x8,%esp
  800545:	ff 75 0c             	pushl  0xc(%ebp)
  800548:	52                   	push   %edx
  800549:	ff 55 08             	call   *0x8(%ebp)
  80054c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80054f:	83 eb 01             	sub    $0x1,%ebx
  800552:	eb 1a                	jmp    80056e <vprintfmt+0x24b>
  800554:	89 75 08             	mov    %esi,0x8(%ebp)
  800557:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80055a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80055d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800560:	eb 0c                	jmp    80056e <vprintfmt+0x24b>
  800562:	89 75 08             	mov    %esi,0x8(%ebp)
  800565:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800568:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80056b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80056e:	83 c7 01             	add    $0x1,%edi
  800571:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800575:	0f be d0             	movsbl %al,%edx
  800578:	85 d2                	test   %edx,%edx
  80057a:	74 23                	je     80059f <vprintfmt+0x27c>
  80057c:	85 f6                	test   %esi,%esi
  80057e:	78 a1                	js     800521 <vprintfmt+0x1fe>
  800580:	83 ee 01             	sub    $0x1,%esi
  800583:	79 9c                	jns    800521 <vprintfmt+0x1fe>
  800585:	89 df                	mov    %ebx,%edi
  800587:	8b 75 08             	mov    0x8(%ebp),%esi
  80058a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80058d:	eb 18                	jmp    8005a7 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80058f:	83 ec 08             	sub    $0x8,%esp
  800592:	53                   	push   %ebx
  800593:	6a 20                	push   $0x20
  800595:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800597:	83 ef 01             	sub    $0x1,%edi
  80059a:	83 c4 10             	add    $0x10,%esp
  80059d:	eb 08                	jmp    8005a7 <vprintfmt+0x284>
  80059f:	89 df                	mov    %ebx,%edi
  8005a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8005a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005a7:	85 ff                	test   %edi,%edi
  8005a9:	7f e4                	jg     80058f <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005ab:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005ae:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b4:	e9 90 fd ff ff       	jmp    800349 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005b9:	83 f9 01             	cmp    $0x1,%ecx
  8005bc:	7e 19                	jle    8005d7 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8005be:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c1:	8b 50 04             	mov    0x4(%eax),%edx
  8005c4:	8b 00                	mov    (%eax),%eax
  8005c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cf:	8d 40 08             	lea    0x8(%eax),%eax
  8005d2:	89 45 14             	mov    %eax,0x14(%ebp)
  8005d5:	eb 38                	jmp    80060f <vprintfmt+0x2ec>
	else if (lflag)
  8005d7:	85 c9                	test   %ecx,%ecx
  8005d9:	74 1b                	je     8005f6 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8005db:	8b 45 14             	mov    0x14(%ebp),%eax
  8005de:	8b 00                	mov    (%eax),%eax
  8005e0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e3:	89 c1                	mov    %eax,%ecx
  8005e5:	c1 f9 1f             	sar    $0x1f,%ecx
  8005e8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ee:	8d 40 04             	lea    0x4(%eax),%eax
  8005f1:	89 45 14             	mov    %eax,0x14(%ebp)
  8005f4:	eb 19                	jmp    80060f <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8005f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f9:	8b 00                	mov    (%eax),%eax
  8005fb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005fe:	89 c1                	mov    %eax,%ecx
  800600:	c1 f9 1f             	sar    $0x1f,%ecx
  800603:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800606:	8b 45 14             	mov    0x14(%ebp),%eax
  800609:	8d 40 04             	lea    0x4(%eax),%eax
  80060c:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80060f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800612:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800615:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80061a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80061e:	0f 89 0e 01 00 00    	jns    800732 <vprintfmt+0x40f>
				putch('-', putdat);
  800624:	83 ec 08             	sub    $0x8,%esp
  800627:	53                   	push   %ebx
  800628:	6a 2d                	push   $0x2d
  80062a:	ff d6                	call   *%esi
				num = -(long long) num;
  80062c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80062f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800632:	f7 da                	neg    %edx
  800634:	83 d1 00             	adc    $0x0,%ecx
  800637:	f7 d9                	neg    %ecx
  800639:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80063c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800641:	e9 ec 00 00 00       	jmp    800732 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800646:	83 f9 01             	cmp    $0x1,%ecx
  800649:	7e 18                	jle    800663 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  80064b:	8b 45 14             	mov    0x14(%ebp),%eax
  80064e:	8b 10                	mov    (%eax),%edx
  800650:	8b 48 04             	mov    0x4(%eax),%ecx
  800653:	8d 40 08             	lea    0x8(%eax),%eax
  800656:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800659:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065e:	e9 cf 00 00 00       	jmp    800732 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800663:	85 c9                	test   %ecx,%ecx
  800665:	74 1a                	je     800681 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800667:	8b 45 14             	mov    0x14(%ebp),%eax
  80066a:	8b 10                	mov    (%eax),%edx
  80066c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800671:	8d 40 04             	lea    0x4(%eax),%eax
  800674:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800677:	b8 0a 00 00 00       	mov    $0xa,%eax
  80067c:	e9 b1 00 00 00       	jmp    800732 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800681:	8b 45 14             	mov    0x14(%ebp),%eax
  800684:	8b 10                	mov    (%eax),%edx
  800686:	b9 00 00 00 00       	mov    $0x0,%ecx
  80068b:	8d 40 04             	lea    0x4(%eax),%eax
  80068e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800691:	b8 0a 00 00 00       	mov    $0xa,%eax
  800696:	e9 97 00 00 00       	jmp    800732 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80069b:	83 ec 08             	sub    $0x8,%esp
  80069e:	53                   	push   %ebx
  80069f:	6a 58                	push   $0x58
  8006a1:	ff d6                	call   *%esi
			putch('X', putdat);
  8006a3:	83 c4 08             	add    $0x8,%esp
  8006a6:	53                   	push   %ebx
  8006a7:	6a 58                	push   $0x58
  8006a9:	ff d6                	call   *%esi
			putch('X', putdat);
  8006ab:	83 c4 08             	add    $0x8,%esp
  8006ae:	53                   	push   %ebx
  8006af:	6a 58                	push   $0x58
  8006b1:	ff d6                	call   *%esi
			break;
  8006b3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8006b9:	e9 8b fc ff ff       	jmp    800349 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8006be:	83 ec 08             	sub    $0x8,%esp
  8006c1:	53                   	push   %ebx
  8006c2:	6a 30                	push   $0x30
  8006c4:	ff d6                	call   *%esi
			putch('x', putdat);
  8006c6:	83 c4 08             	add    $0x8,%esp
  8006c9:	53                   	push   %ebx
  8006ca:	6a 78                	push   $0x78
  8006cc:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d1:	8b 10                	mov    (%eax),%edx
  8006d3:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006d8:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006db:	8d 40 04             	lea    0x4(%eax),%eax
  8006de:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006e1:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006e6:	eb 4a                	jmp    800732 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006e8:	83 f9 01             	cmp    $0x1,%ecx
  8006eb:	7e 15                	jle    800702 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8006ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f0:	8b 10                	mov    (%eax),%edx
  8006f2:	8b 48 04             	mov    0x4(%eax),%ecx
  8006f5:	8d 40 08             	lea    0x8(%eax),%eax
  8006f8:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006fb:	b8 10 00 00 00       	mov    $0x10,%eax
  800700:	eb 30                	jmp    800732 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800702:	85 c9                	test   %ecx,%ecx
  800704:	74 17                	je     80071d <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800706:	8b 45 14             	mov    0x14(%ebp),%eax
  800709:	8b 10                	mov    (%eax),%edx
  80070b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800710:	8d 40 04             	lea    0x4(%eax),%eax
  800713:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800716:	b8 10 00 00 00       	mov    $0x10,%eax
  80071b:	eb 15                	jmp    800732 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80071d:	8b 45 14             	mov    0x14(%ebp),%eax
  800720:	8b 10                	mov    (%eax),%edx
  800722:	b9 00 00 00 00       	mov    $0x0,%ecx
  800727:	8d 40 04             	lea    0x4(%eax),%eax
  80072a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80072d:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800732:	83 ec 0c             	sub    $0xc,%esp
  800735:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800739:	57                   	push   %edi
  80073a:	ff 75 e0             	pushl  -0x20(%ebp)
  80073d:	50                   	push   %eax
  80073e:	51                   	push   %ecx
  80073f:	52                   	push   %edx
  800740:	89 da                	mov    %ebx,%edx
  800742:	89 f0                	mov    %esi,%eax
  800744:	e8 f1 fa ff ff       	call   80023a <printnum>
			break;
  800749:	83 c4 20             	add    $0x20,%esp
  80074c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80074f:	e9 f5 fb ff ff       	jmp    800349 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800754:	83 ec 08             	sub    $0x8,%esp
  800757:	53                   	push   %ebx
  800758:	52                   	push   %edx
  800759:	ff d6                	call   *%esi
			break;
  80075b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80075e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800761:	e9 e3 fb ff ff       	jmp    800349 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800766:	83 ec 08             	sub    $0x8,%esp
  800769:	53                   	push   %ebx
  80076a:	6a 25                	push   $0x25
  80076c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80076e:	83 c4 10             	add    $0x10,%esp
  800771:	eb 03                	jmp    800776 <vprintfmt+0x453>
  800773:	83 ef 01             	sub    $0x1,%edi
  800776:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80077a:	75 f7                	jne    800773 <vprintfmt+0x450>
  80077c:	e9 c8 fb ff ff       	jmp    800349 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800781:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800784:	5b                   	pop    %ebx
  800785:	5e                   	pop    %esi
  800786:	5f                   	pop    %edi
  800787:	5d                   	pop    %ebp
  800788:	c3                   	ret    

00800789 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800789:	55                   	push   %ebp
  80078a:	89 e5                	mov    %esp,%ebp
  80078c:	83 ec 18             	sub    $0x18,%esp
  80078f:	8b 45 08             	mov    0x8(%ebp),%eax
  800792:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800795:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800798:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80079c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80079f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007a6:	85 c0                	test   %eax,%eax
  8007a8:	74 26                	je     8007d0 <vsnprintf+0x47>
  8007aa:	85 d2                	test   %edx,%edx
  8007ac:	7e 22                	jle    8007d0 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007ae:	ff 75 14             	pushl  0x14(%ebp)
  8007b1:	ff 75 10             	pushl  0x10(%ebp)
  8007b4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007b7:	50                   	push   %eax
  8007b8:	68 e9 02 80 00       	push   $0x8002e9
  8007bd:	e8 61 fb ff ff       	call   800323 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007c5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007cb:	83 c4 10             	add    $0x10,%esp
  8007ce:	eb 05                	jmp    8007d5 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007d0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007d5:	c9                   	leave  
  8007d6:	c3                   	ret    

008007d7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007d7:	55                   	push   %ebp
  8007d8:	89 e5                	mov    %esp,%ebp
  8007da:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007dd:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007e0:	50                   	push   %eax
  8007e1:	ff 75 10             	pushl  0x10(%ebp)
  8007e4:	ff 75 0c             	pushl  0xc(%ebp)
  8007e7:	ff 75 08             	pushl  0x8(%ebp)
  8007ea:	e8 9a ff ff ff       	call   800789 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007ef:	c9                   	leave  
  8007f0:	c3                   	ret    

008007f1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007f1:	55                   	push   %ebp
  8007f2:	89 e5                	mov    %esp,%ebp
  8007f4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007fc:	eb 03                	jmp    800801 <strlen+0x10>
		n++;
  8007fe:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800801:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800805:	75 f7                	jne    8007fe <strlen+0xd>
		n++;
	return n;
}
  800807:	5d                   	pop    %ebp
  800808:	c3                   	ret    

00800809 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800809:	55                   	push   %ebp
  80080a:	89 e5                	mov    %esp,%ebp
  80080c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80080f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800812:	ba 00 00 00 00       	mov    $0x0,%edx
  800817:	eb 03                	jmp    80081c <strnlen+0x13>
		n++;
  800819:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80081c:	39 c2                	cmp    %eax,%edx
  80081e:	74 08                	je     800828 <strnlen+0x1f>
  800820:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800824:	75 f3                	jne    800819 <strnlen+0x10>
  800826:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800828:	5d                   	pop    %ebp
  800829:	c3                   	ret    

0080082a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	53                   	push   %ebx
  80082e:	8b 45 08             	mov    0x8(%ebp),%eax
  800831:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800834:	89 c2                	mov    %eax,%edx
  800836:	83 c2 01             	add    $0x1,%edx
  800839:	83 c1 01             	add    $0x1,%ecx
  80083c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800840:	88 5a ff             	mov    %bl,-0x1(%edx)
  800843:	84 db                	test   %bl,%bl
  800845:	75 ef                	jne    800836 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800847:	5b                   	pop    %ebx
  800848:	5d                   	pop    %ebp
  800849:	c3                   	ret    

0080084a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80084a:	55                   	push   %ebp
  80084b:	89 e5                	mov    %esp,%ebp
  80084d:	53                   	push   %ebx
  80084e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800851:	53                   	push   %ebx
  800852:	e8 9a ff ff ff       	call   8007f1 <strlen>
  800857:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80085a:	ff 75 0c             	pushl  0xc(%ebp)
  80085d:	01 d8                	add    %ebx,%eax
  80085f:	50                   	push   %eax
  800860:	e8 c5 ff ff ff       	call   80082a <strcpy>
	return dst;
}
  800865:	89 d8                	mov    %ebx,%eax
  800867:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80086a:	c9                   	leave  
  80086b:	c3                   	ret    

0080086c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80086c:	55                   	push   %ebp
  80086d:	89 e5                	mov    %esp,%ebp
  80086f:	56                   	push   %esi
  800870:	53                   	push   %ebx
  800871:	8b 75 08             	mov    0x8(%ebp),%esi
  800874:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800877:	89 f3                	mov    %esi,%ebx
  800879:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80087c:	89 f2                	mov    %esi,%edx
  80087e:	eb 0f                	jmp    80088f <strncpy+0x23>
		*dst++ = *src;
  800880:	83 c2 01             	add    $0x1,%edx
  800883:	0f b6 01             	movzbl (%ecx),%eax
  800886:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800889:	80 39 01             	cmpb   $0x1,(%ecx)
  80088c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80088f:	39 da                	cmp    %ebx,%edx
  800891:	75 ed                	jne    800880 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800893:	89 f0                	mov    %esi,%eax
  800895:	5b                   	pop    %ebx
  800896:	5e                   	pop    %esi
  800897:	5d                   	pop    %ebp
  800898:	c3                   	ret    

00800899 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800899:	55                   	push   %ebp
  80089a:	89 e5                	mov    %esp,%ebp
  80089c:	56                   	push   %esi
  80089d:	53                   	push   %ebx
  80089e:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008a4:	8b 55 10             	mov    0x10(%ebp),%edx
  8008a7:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008a9:	85 d2                	test   %edx,%edx
  8008ab:	74 21                	je     8008ce <strlcpy+0x35>
  8008ad:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008b1:	89 f2                	mov    %esi,%edx
  8008b3:	eb 09                	jmp    8008be <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008b5:	83 c2 01             	add    $0x1,%edx
  8008b8:	83 c1 01             	add    $0x1,%ecx
  8008bb:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008be:	39 c2                	cmp    %eax,%edx
  8008c0:	74 09                	je     8008cb <strlcpy+0x32>
  8008c2:	0f b6 19             	movzbl (%ecx),%ebx
  8008c5:	84 db                	test   %bl,%bl
  8008c7:	75 ec                	jne    8008b5 <strlcpy+0x1c>
  8008c9:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008cb:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008ce:	29 f0                	sub    %esi,%eax
}
  8008d0:	5b                   	pop    %ebx
  8008d1:	5e                   	pop    %esi
  8008d2:	5d                   	pop    %ebp
  8008d3:	c3                   	ret    

008008d4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008da:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008dd:	eb 06                	jmp    8008e5 <strcmp+0x11>
		p++, q++;
  8008df:	83 c1 01             	add    $0x1,%ecx
  8008e2:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008e5:	0f b6 01             	movzbl (%ecx),%eax
  8008e8:	84 c0                	test   %al,%al
  8008ea:	74 04                	je     8008f0 <strcmp+0x1c>
  8008ec:	3a 02                	cmp    (%edx),%al
  8008ee:	74 ef                	je     8008df <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f0:	0f b6 c0             	movzbl %al,%eax
  8008f3:	0f b6 12             	movzbl (%edx),%edx
  8008f6:	29 d0                	sub    %edx,%eax
}
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	53                   	push   %ebx
  8008fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800901:	8b 55 0c             	mov    0xc(%ebp),%edx
  800904:	89 c3                	mov    %eax,%ebx
  800906:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800909:	eb 06                	jmp    800911 <strncmp+0x17>
		n--, p++, q++;
  80090b:	83 c0 01             	add    $0x1,%eax
  80090e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800911:	39 d8                	cmp    %ebx,%eax
  800913:	74 15                	je     80092a <strncmp+0x30>
  800915:	0f b6 08             	movzbl (%eax),%ecx
  800918:	84 c9                	test   %cl,%cl
  80091a:	74 04                	je     800920 <strncmp+0x26>
  80091c:	3a 0a                	cmp    (%edx),%cl
  80091e:	74 eb                	je     80090b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800920:	0f b6 00             	movzbl (%eax),%eax
  800923:	0f b6 12             	movzbl (%edx),%edx
  800926:	29 d0                	sub    %edx,%eax
  800928:	eb 05                	jmp    80092f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80092a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80092f:	5b                   	pop    %ebx
  800930:	5d                   	pop    %ebp
  800931:	c3                   	ret    

00800932 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
  800935:	8b 45 08             	mov    0x8(%ebp),%eax
  800938:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80093c:	eb 07                	jmp    800945 <strchr+0x13>
		if (*s == c)
  80093e:	38 ca                	cmp    %cl,%dl
  800940:	74 0f                	je     800951 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800942:	83 c0 01             	add    $0x1,%eax
  800945:	0f b6 10             	movzbl (%eax),%edx
  800948:	84 d2                	test   %dl,%dl
  80094a:	75 f2                	jne    80093e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80094c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800951:	5d                   	pop    %ebp
  800952:	c3                   	ret    

00800953 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800953:	55                   	push   %ebp
  800954:	89 e5                	mov    %esp,%ebp
  800956:	8b 45 08             	mov    0x8(%ebp),%eax
  800959:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80095d:	eb 03                	jmp    800962 <strfind+0xf>
  80095f:	83 c0 01             	add    $0x1,%eax
  800962:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800965:	38 ca                	cmp    %cl,%dl
  800967:	74 04                	je     80096d <strfind+0x1a>
  800969:	84 d2                	test   %dl,%dl
  80096b:	75 f2                	jne    80095f <strfind+0xc>
			break;
	return (char *) s;
}
  80096d:	5d                   	pop    %ebp
  80096e:	c3                   	ret    

0080096f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	57                   	push   %edi
  800973:	56                   	push   %esi
  800974:	53                   	push   %ebx
  800975:	8b 7d 08             	mov    0x8(%ebp),%edi
  800978:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80097b:	85 c9                	test   %ecx,%ecx
  80097d:	74 36                	je     8009b5 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80097f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800985:	75 28                	jne    8009af <memset+0x40>
  800987:	f6 c1 03             	test   $0x3,%cl
  80098a:	75 23                	jne    8009af <memset+0x40>
		c &= 0xFF;
  80098c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800990:	89 d3                	mov    %edx,%ebx
  800992:	c1 e3 08             	shl    $0x8,%ebx
  800995:	89 d6                	mov    %edx,%esi
  800997:	c1 e6 18             	shl    $0x18,%esi
  80099a:	89 d0                	mov    %edx,%eax
  80099c:	c1 e0 10             	shl    $0x10,%eax
  80099f:	09 f0                	or     %esi,%eax
  8009a1:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009a3:	89 d8                	mov    %ebx,%eax
  8009a5:	09 d0                	or     %edx,%eax
  8009a7:	c1 e9 02             	shr    $0x2,%ecx
  8009aa:	fc                   	cld    
  8009ab:	f3 ab                	rep stos %eax,%es:(%edi)
  8009ad:	eb 06                	jmp    8009b5 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b2:	fc                   	cld    
  8009b3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009b5:	89 f8                	mov    %edi,%eax
  8009b7:	5b                   	pop    %ebx
  8009b8:	5e                   	pop    %esi
  8009b9:	5f                   	pop    %edi
  8009ba:	5d                   	pop    %ebp
  8009bb:	c3                   	ret    

008009bc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	57                   	push   %edi
  8009c0:	56                   	push   %esi
  8009c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009c7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009ca:	39 c6                	cmp    %eax,%esi
  8009cc:	73 35                	jae    800a03 <memmove+0x47>
  8009ce:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009d1:	39 d0                	cmp    %edx,%eax
  8009d3:	73 2e                	jae    800a03 <memmove+0x47>
		s += n;
		d += n;
  8009d5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d8:	89 d6                	mov    %edx,%esi
  8009da:	09 fe                	or     %edi,%esi
  8009dc:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009e2:	75 13                	jne    8009f7 <memmove+0x3b>
  8009e4:	f6 c1 03             	test   $0x3,%cl
  8009e7:	75 0e                	jne    8009f7 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009e9:	83 ef 04             	sub    $0x4,%edi
  8009ec:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009ef:	c1 e9 02             	shr    $0x2,%ecx
  8009f2:	fd                   	std    
  8009f3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009f5:	eb 09                	jmp    800a00 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009f7:	83 ef 01             	sub    $0x1,%edi
  8009fa:	8d 72 ff             	lea    -0x1(%edx),%esi
  8009fd:	fd                   	std    
  8009fe:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a00:	fc                   	cld    
  800a01:	eb 1d                	jmp    800a20 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a03:	89 f2                	mov    %esi,%edx
  800a05:	09 c2                	or     %eax,%edx
  800a07:	f6 c2 03             	test   $0x3,%dl
  800a0a:	75 0f                	jne    800a1b <memmove+0x5f>
  800a0c:	f6 c1 03             	test   $0x3,%cl
  800a0f:	75 0a                	jne    800a1b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a11:	c1 e9 02             	shr    $0x2,%ecx
  800a14:	89 c7                	mov    %eax,%edi
  800a16:	fc                   	cld    
  800a17:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a19:	eb 05                	jmp    800a20 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a1b:	89 c7                	mov    %eax,%edi
  800a1d:	fc                   	cld    
  800a1e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a20:	5e                   	pop    %esi
  800a21:	5f                   	pop    %edi
  800a22:	5d                   	pop    %ebp
  800a23:	c3                   	ret    

00800a24 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a27:	ff 75 10             	pushl  0x10(%ebp)
  800a2a:	ff 75 0c             	pushl  0xc(%ebp)
  800a2d:	ff 75 08             	pushl  0x8(%ebp)
  800a30:	e8 87 ff ff ff       	call   8009bc <memmove>
}
  800a35:	c9                   	leave  
  800a36:	c3                   	ret    

00800a37 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a37:	55                   	push   %ebp
  800a38:	89 e5                	mov    %esp,%ebp
  800a3a:	56                   	push   %esi
  800a3b:	53                   	push   %ebx
  800a3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a42:	89 c6                	mov    %eax,%esi
  800a44:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a47:	eb 1a                	jmp    800a63 <memcmp+0x2c>
		if (*s1 != *s2)
  800a49:	0f b6 08             	movzbl (%eax),%ecx
  800a4c:	0f b6 1a             	movzbl (%edx),%ebx
  800a4f:	38 d9                	cmp    %bl,%cl
  800a51:	74 0a                	je     800a5d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a53:	0f b6 c1             	movzbl %cl,%eax
  800a56:	0f b6 db             	movzbl %bl,%ebx
  800a59:	29 d8                	sub    %ebx,%eax
  800a5b:	eb 0f                	jmp    800a6c <memcmp+0x35>
		s1++, s2++;
  800a5d:	83 c0 01             	add    $0x1,%eax
  800a60:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a63:	39 f0                	cmp    %esi,%eax
  800a65:	75 e2                	jne    800a49 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a67:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a6c:	5b                   	pop    %ebx
  800a6d:	5e                   	pop    %esi
  800a6e:	5d                   	pop    %ebp
  800a6f:	c3                   	ret    

00800a70 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	53                   	push   %ebx
  800a74:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a77:	89 c1                	mov    %eax,%ecx
  800a79:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a7c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a80:	eb 0a                	jmp    800a8c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a82:	0f b6 10             	movzbl (%eax),%edx
  800a85:	39 da                	cmp    %ebx,%edx
  800a87:	74 07                	je     800a90 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a89:	83 c0 01             	add    $0x1,%eax
  800a8c:	39 c8                	cmp    %ecx,%eax
  800a8e:	72 f2                	jb     800a82 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a90:	5b                   	pop    %ebx
  800a91:	5d                   	pop    %ebp
  800a92:	c3                   	ret    

00800a93 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a93:	55                   	push   %ebp
  800a94:	89 e5                	mov    %esp,%ebp
  800a96:	57                   	push   %edi
  800a97:	56                   	push   %esi
  800a98:	53                   	push   %ebx
  800a99:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a9f:	eb 03                	jmp    800aa4 <strtol+0x11>
		s++;
  800aa1:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aa4:	0f b6 01             	movzbl (%ecx),%eax
  800aa7:	3c 20                	cmp    $0x20,%al
  800aa9:	74 f6                	je     800aa1 <strtol+0xe>
  800aab:	3c 09                	cmp    $0x9,%al
  800aad:	74 f2                	je     800aa1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800aaf:	3c 2b                	cmp    $0x2b,%al
  800ab1:	75 0a                	jne    800abd <strtol+0x2a>
		s++;
  800ab3:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ab6:	bf 00 00 00 00       	mov    $0x0,%edi
  800abb:	eb 11                	jmp    800ace <strtol+0x3b>
  800abd:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ac2:	3c 2d                	cmp    $0x2d,%al
  800ac4:	75 08                	jne    800ace <strtol+0x3b>
		s++, neg = 1;
  800ac6:	83 c1 01             	add    $0x1,%ecx
  800ac9:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ace:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ad4:	75 15                	jne    800aeb <strtol+0x58>
  800ad6:	80 39 30             	cmpb   $0x30,(%ecx)
  800ad9:	75 10                	jne    800aeb <strtol+0x58>
  800adb:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800adf:	75 7c                	jne    800b5d <strtol+0xca>
		s += 2, base = 16;
  800ae1:	83 c1 02             	add    $0x2,%ecx
  800ae4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ae9:	eb 16                	jmp    800b01 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800aeb:	85 db                	test   %ebx,%ebx
  800aed:	75 12                	jne    800b01 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aef:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800af4:	80 39 30             	cmpb   $0x30,(%ecx)
  800af7:	75 08                	jne    800b01 <strtol+0x6e>
		s++, base = 8;
  800af9:	83 c1 01             	add    $0x1,%ecx
  800afc:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b01:	b8 00 00 00 00       	mov    $0x0,%eax
  800b06:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b09:	0f b6 11             	movzbl (%ecx),%edx
  800b0c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b0f:	89 f3                	mov    %esi,%ebx
  800b11:	80 fb 09             	cmp    $0x9,%bl
  800b14:	77 08                	ja     800b1e <strtol+0x8b>
			dig = *s - '0';
  800b16:	0f be d2             	movsbl %dl,%edx
  800b19:	83 ea 30             	sub    $0x30,%edx
  800b1c:	eb 22                	jmp    800b40 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b1e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b21:	89 f3                	mov    %esi,%ebx
  800b23:	80 fb 19             	cmp    $0x19,%bl
  800b26:	77 08                	ja     800b30 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b28:	0f be d2             	movsbl %dl,%edx
  800b2b:	83 ea 57             	sub    $0x57,%edx
  800b2e:	eb 10                	jmp    800b40 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b30:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b33:	89 f3                	mov    %esi,%ebx
  800b35:	80 fb 19             	cmp    $0x19,%bl
  800b38:	77 16                	ja     800b50 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b3a:	0f be d2             	movsbl %dl,%edx
  800b3d:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b40:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b43:	7d 0b                	jge    800b50 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b45:	83 c1 01             	add    $0x1,%ecx
  800b48:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b4c:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b4e:	eb b9                	jmp    800b09 <strtol+0x76>

	if (endptr)
  800b50:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b54:	74 0d                	je     800b63 <strtol+0xd0>
		*endptr = (char *) s;
  800b56:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b59:	89 0e                	mov    %ecx,(%esi)
  800b5b:	eb 06                	jmp    800b63 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b5d:	85 db                	test   %ebx,%ebx
  800b5f:	74 98                	je     800af9 <strtol+0x66>
  800b61:	eb 9e                	jmp    800b01 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b63:	89 c2                	mov    %eax,%edx
  800b65:	f7 da                	neg    %edx
  800b67:	85 ff                	test   %edi,%edi
  800b69:	0f 45 c2             	cmovne %edx,%eax
}
  800b6c:	5b                   	pop    %ebx
  800b6d:	5e                   	pop    %esi
  800b6e:	5f                   	pop    %edi
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    

00800b71 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800b77:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b82:	89 c3                	mov    %eax,%ebx
  800b84:	89 c7                	mov    %eax,%edi
  800b86:	89 c6                	mov    %eax,%esi
  800b88:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b8a:	5b                   	pop    %ebx
  800b8b:	5e                   	pop    %esi
  800b8c:	5f                   	pop    %edi
  800b8d:	5d                   	pop    %ebp
  800b8e:	c3                   	ret    

00800b8f <sys_cgetc>:

int
sys_cgetc(void)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	57                   	push   %edi
  800b93:	56                   	push   %esi
  800b94:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b95:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b9f:	89 d1                	mov    %edx,%ecx
  800ba1:	89 d3                	mov    %edx,%ebx
  800ba3:	89 d7                	mov    %edx,%edi
  800ba5:	89 d6                	mov    %edx,%esi
  800ba7:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ba9:	5b                   	pop    %ebx
  800baa:	5e                   	pop    %esi
  800bab:	5f                   	pop    %edi
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	57                   	push   %edi
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
  800bb4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bbc:	b8 03 00 00 00       	mov    $0x3,%eax
  800bc1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc4:	89 cb                	mov    %ecx,%ebx
  800bc6:	89 cf                	mov    %ecx,%edi
  800bc8:	89 ce                	mov    %ecx,%esi
  800bca:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800bcc:	85 c0                	test   %eax,%eax
  800bce:	7e 17                	jle    800be7 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd0:	83 ec 0c             	sub    $0xc,%esp
  800bd3:	50                   	push   %eax
  800bd4:	6a 03                	push   $0x3
  800bd6:	68 1f 25 80 00       	push   $0x80251f
  800bdb:	6a 23                	push   $0x23
  800bdd:	68 3c 25 80 00       	push   $0x80253c
  800be2:	e8 66 f5 ff ff       	call   80014d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800be7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bea:	5b                   	pop    %ebx
  800beb:	5e                   	pop    %esi
  800bec:	5f                   	pop    %edi
  800bed:	5d                   	pop    %ebp
  800bee:	c3                   	ret    

00800bef <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bef:	55                   	push   %ebp
  800bf0:	89 e5                	mov    %esp,%ebp
  800bf2:	57                   	push   %edi
  800bf3:	56                   	push   %esi
  800bf4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bfa:	b8 02 00 00 00       	mov    $0x2,%eax
  800bff:	89 d1                	mov    %edx,%ecx
  800c01:	89 d3                	mov    %edx,%ebx
  800c03:	89 d7                	mov    %edx,%edi
  800c05:	89 d6                	mov    %edx,%esi
  800c07:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c09:	5b                   	pop    %ebx
  800c0a:	5e                   	pop    %esi
  800c0b:	5f                   	pop    %edi
  800c0c:	5d                   	pop    %ebp
  800c0d:	c3                   	ret    

00800c0e <sys_yield>:

void
sys_yield(void)
{
  800c0e:	55                   	push   %ebp
  800c0f:	89 e5                	mov    %esp,%ebp
  800c11:	57                   	push   %edi
  800c12:	56                   	push   %esi
  800c13:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c14:	ba 00 00 00 00       	mov    $0x0,%edx
  800c19:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c1e:	89 d1                	mov    %edx,%ecx
  800c20:	89 d3                	mov    %edx,%ebx
  800c22:	89 d7                	mov    %edx,%edi
  800c24:	89 d6                	mov    %edx,%esi
  800c26:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c28:	5b                   	pop    %ebx
  800c29:	5e                   	pop    %esi
  800c2a:	5f                   	pop    %edi
  800c2b:	5d                   	pop    %ebp
  800c2c:	c3                   	ret    

00800c2d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c2d:	55                   	push   %ebp
  800c2e:	89 e5                	mov    %esp,%ebp
  800c30:	57                   	push   %edi
  800c31:	56                   	push   %esi
  800c32:	53                   	push   %ebx
  800c33:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c36:	be 00 00 00 00       	mov    $0x0,%esi
  800c3b:	b8 04 00 00 00       	mov    $0x4,%eax
  800c40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c43:	8b 55 08             	mov    0x8(%ebp),%edx
  800c46:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c49:	89 f7                	mov    %esi,%edi
  800c4b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c4d:	85 c0                	test   %eax,%eax
  800c4f:	7e 17                	jle    800c68 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c51:	83 ec 0c             	sub    $0xc,%esp
  800c54:	50                   	push   %eax
  800c55:	6a 04                	push   $0x4
  800c57:	68 1f 25 80 00       	push   $0x80251f
  800c5c:	6a 23                	push   $0x23
  800c5e:	68 3c 25 80 00       	push   $0x80253c
  800c63:	e8 e5 f4 ff ff       	call   80014d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6b:	5b                   	pop    %ebx
  800c6c:	5e                   	pop    %esi
  800c6d:	5f                   	pop    %edi
  800c6e:	5d                   	pop    %ebp
  800c6f:	c3                   	ret    

00800c70 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c70:	55                   	push   %ebp
  800c71:	89 e5                	mov    %esp,%ebp
  800c73:	57                   	push   %edi
  800c74:	56                   	push   %esi
  800c75:	53                   	push   %ebx
  800c76:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c79:	b8 05 00 00 00       	mov    $0x5,%eax
  800c7e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c81:	8b 55 08             	mov    0x8(%ebp),%edx
  800c84:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c87:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c8a:	8b 75 18             	mov    0x18(%ebp),%esi
  800c8d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c8f:	85 c0                	test   %eax,%eax
  800c91:	7e 17                	jle    800caa <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c93:	83 ec 0c             	sub    $0xc,%esp
  800c96:	50                   	push   %eax
  800c97:	6a 05                	push   $0x5
  800c99:	68 1f 25 80 00       	push   $0x80251f
  800c9e:	6a 23                	push   $0x23
  800ca0:	68 3c 25 80 00       	push   $0x80253c
  800ca5:	e8 a3 f4 ff ff       	call   80014d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800caa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cad:	5b                   	pop    %ebx
  800cae:	5e                   	pop    %esi
  800caf:	5f                   	pop    %edi
  800cb0:	5d                   	pop    %ebp
  800cb1:	c3                   	ret    

00800cb2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cb2:	55                   	push   %ebp
  800cb3:	89 e5                	mov    %esp,%ebp
  800cb5:	57                   	push   %edi
  800cb6:	56                   	push   %esi
  800cb7:	53                   	push   %ebx
  800cb8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc0:	b8 06 00 00 00       	mov    $0x6,%eax
  800cc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccb:	89 df                	mov    %ebx,%edi
  800ccd:	89 de                	mov    %ebx,%esi
  800ccf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cd1:	85 c0                	test   %eax,%eax
  800cd3:	7e 17                	jle    800cec <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd5:	83 ec 0c             	sub    $0xc,%esp
  800cd8:	50                   	push   %eax
  800cd9:	6a 06                	push   $0x6
  800cdb:	68 1f 25 80 00       	push   $0x80251f
  800ce0:	6a 23                	push   $0x23
  800ce2:	68 3c 25 80 00       	push   $0x80253c
  800ce7:	e8 61 f4 ff ff       	call   80014d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cef:	5b                   	pop    %ebx
  800cf0:	5e                   	pop    %esi
  800cf1:	5f                   	pop    %edi
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    

00800cf4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	57                   	push   %edi
  800cf8:	56                   	push   %esi
  800cf9:	53                   	push   %ebx
  800cfa:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d02:	b8 08 00 00 00       	mov    $0x8,%eax
  800d07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0d:	89 df                	mov    %ebx,%edi
  800d0f:	89 de                	mov    %ebx,%esi
  800d11:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d13:	85 c0                	test   %eax,%eax
  800d15:	7e 17                	jle    800d2e <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d17:	83 ec 0c             	sub    $0xc,%esp
  800d1a:	50                   	push   %eax
  800d1b:	6a 08                	push   $0x8
  800d1d:	68 1f 25 80 00       	push   $0x80251f
  800d22:	6a 23                	push   $0x23
  800d24:	68 3c 25 80 00       	push   $0x80253c
  800d29:	e8 1f f4 ff ff       	call   80014d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d31:	5b                   	pop    %ebx
  800d32:	5e                   	pop    %esi
  800d33:	5f                   	pop    %edi
  800d34:	5d                   	pop    %ebp
  800d35:	c3                   	ret    

00800d36 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d36:	55                   	push   %ebp
  800d37:	89 e5                	mov    %esp,%ebp
  800d39:	57                   	push   %edi
  800d3a:	56                   	push   %esi
  800d3b:	53                   	push   %ebx
  800d3c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d44:	b8 09 00 00 00       	mov    $0x9,%eax
  800d49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4f:	89 df                	mov    %ebx,%edi
  800d51:	89 de                	mov    %ebx,%esi
  800d53:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d55:	85 c0                	test   %eax,%eax
  800d57:	7e 17                	jle    800d70 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d59:	83 ec 0c             	sub    $0xc,%esp
  800d5c:	50                   	push   %eax
  800d5d:	6a 09                	push   $0x9
  800d5f:	68 1f 25 80 00       	push   $0x80251f
  800d64:	6a 23                	push   $0x23
  800d66:	68 3c 25 80 00       	push   $0x80253c
  800d6b:	e8 dd f3 ff ff       	call   80014d <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d73:	5b                   	pop    %ebx
  800d74:	5e                   	pop    %esi
  800d75:	5f                   	pop    %edi
  800d76:	5d                   	pop    %ebp
  800d77:	c3                   	ret    

00800d78 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d78:	55                   	push   %ebp
  800d79:	89 e5                	mov    %esp,%ebp
  800d7b:	57                   	push   %edi
  800d7c:	56                   	push   %esi
  800d7d:	53                   	push   %ebx
  800d7e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d81:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d86:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d91:	89 df                	mov    %ebx,%edi
  800d93:	89 de                	mov    %ebx,%esi
  800d95:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d97:	85 c0                	test   %eax,%eax
  800d99:	7e 17                	jle    800db2 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9b:	83 ec 0c             	sub    $0xc,%esp
  800d9e:	50                   	push   %eax
  800d9f:	6a 0a                	push   $0xa
  800da1:	68 1f 25 80 00       	push   $0x80251f
  800da6:	6a 23                	push   $0x23
  800da8:	68 3c 25 80 00       	push   $0x80253c
  800dad:	e8 9b f3 ff ff       	call   80014d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800db2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db5:	5b                   	pop    %ebx
  800db6:	5e                   	pop    %esi
  800db7:	5f                   	pop    %edi
  800db8:	5d                   	pop    %ebp
  800db9:	c3                   	ret    

00800dba <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dba:	55                   	push   %ebp
  800dbb:	89 e5                	mov    %esp,%ebp
  800dbd:	57                   	push   %edi
  800dbe:	56                   	push   %esi
  800dbf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc0:	be 00 00 00 00       	mov    $0x0,%esi
  800dc5:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dcd:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dd3:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dd6:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dd8:	5b                   	pop    %ebx
  800dd9:	5e                   	pop    %esi
  800dda:	5f                   	pop    %edi
  800ddb:	5d                   	pop    %ebp
  800ddc:	c3                   	ret    

00800ddd <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ddd:	55                   	push   %ebp
  800dde:	89 e5                	mov    %esp,%ebp
  800de0:	57                   	push   %edi
  800de1:	56                   	push   %esi
  800de2:	53                   	push   %ebx
  800de3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800deb:	b8 0d 00 00 00       	mov    $0xd,%eax
  800df0:	8b 55 08             	mov    0x8(%ebp),%edx
  800df3:	89 cb                	mov    %ecx,%ebx
  800df5:	89 cf                	mov    %ecx,%edi
  800df7:	89 ce                	mov    %ecx,%esi
  800df9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dfb:	85 c0                	test   %eax,%eax
  800dfd:	7e 17                	jle    800e16 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dff:	83 ec 0c             	sub    $0xc,%esp
  800e02:	50                   	push   %eax
  800e03:	6a 0d                	push   $0xd
  800e05:	68 1f 25 80 00       	push   $0x80251f
  800e0a:	6a 23                	push   $0x23
  800e0c:	68 3c 25 80 00       	push   $0x80253c
  800e11:	e8 37 f3 ff ff       	call   80014d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e19:	5b                   	pop    %ebx
  800e1a:	5e                   	pop    %esi
  800e1b:	5f                   	pop    %edi
  800e1c:	5d                   	pop    %ebp
  800e1d:	c3                   	ret    

00800e1e <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e1e:	55                   	push   %ebp
  800e1f:	89 e5                	mov    %esp,%ebp
  800e21:	57                   	push   %edi
  800e22:	56                   	push   %esi
  800e23:	53                   	push   %ebx
  800e24:	83 ec 0c             	sub    $0xc,%esp
  800e27:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e2a:	8b 18                	mov    (%eax),%ebx
	uint32_t err = utf->utf_err;
  800e2c:	8b 78 04             	mov    0x4(%eax),%edi
	int r;
	envid_t curenvid = sys_getenvid();
  800e2f:	e8 bb fd ff ff       	call   800bef <sys_getenvid>
  800e34:	89 c6                	mov    %eax,%esi
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if(!(err & FEC_WR) && !(uvpt[PGNUM(addr)] & PTE_COW))
  800e36:	f7 c7 02 00 00 00    	test   $0x2,%edi
  800e3c:	75 25                	jne    800e63 <pgfault+0x45>
  800e3e:	89 d8                	mov    %ebx,%eax
  800e40:	c1 e8 0c             	shr    $0xc,%eax
  800e43:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e4a:	f6 c4 08             	test   $0x8,%ah
  800e4d:	75 14                	jne    800e63 <pgfault+0x45>
	    panic("pgfault error: wrong faulting access");
  800e4f:	83 ec 04             	sub    $0x4,%esp
  800e52:	68 4c 25 80 00       	push   $0x80254c
  800e57:	6a 1e                	push   $0x1e
  800e59:	68 71 25 80 00       	push   $0x802571
  800e5e:	e8 ea f2 ff ff       	call   80014d <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	sys_page_alloc(curenvid, PFTEMP, PTE_W | PTE_U | PTE_P);
  800e63:	83 ec 04             	sub    $0x4,%esp
  800e66:	6a 07                	push   $0x7
  800e68:	68 00 f0 7f 00       	push   $0x7ff000
  800e6d:	56                   	push   %esi
  800e6e:	e8 ba fd ff ff       	call   800c2d <sys_page_alloc>

	addr = (void *)(PGNUM(addr) * PGSIZE);
  800e73:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr, PGSIZE);
  800e79:	83 c4 0c             	add    $0xc,%esp
  800e7c:	68 00 10 00 00       	push   $0x1000
  800e81:	53                   	push   %ebx
  800e82:	68 00 f0 7f 00       	push   $0x7ff000
  800e87:	e8 30 fb ff ff       	call   8009bc <memmove>

	sys_page_unmap(curenvid, addr);
  800e8c:	83 c4 08             	add    $0x8,%esp
  800e8f:	53                   	push   %ebx
  800e90:	56                   	push   %esi
  800e91:	e8 1c fe ff ff       	call   800cb2 <sys_page_unmap>
	sys_page_map(curenvid, PFTEMP, curenvid, addr, PTE_W | PTE_U | PTE_P);
  800e96:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e9d:	53                   	push   %ebx
  800e9e:	56                   	push   %esi
  800e9f:	68 00 f0 7f 00       	push   $0x7ff000
  800ea4:	56                   	push   %esi
  800ea5:	e8 c6 fd ff ff       	call   800c70 <sys_page_map>
	sys_page_unmap(curenvid, PFTEMP);
  800eaa:	83 c4 18             	add    $0x18,%esp
  800ead:	68 00 f0 7f 00       	push   $0x7ff000
  800eb2:	56                   	push   %esi
  800eb3:	e8 fa fd ff ff       	call   800cb2 <sys_page_unmap>
}
  800eb8:	83 c4 10             	add    $0x10,%esp
  800ebb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ebe:	5b                   	pop    %ebx
  800ebf:	5e                   	pop    %esi
  800ec0:	5f                   	pop    %edi
  800ec1:	5d                   	pop    %ebp
  800ec2:	c3                   	ret    

00800ec3 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ec3:	55                   	push   %ebp
  800ec4:	89 e5                	mov    %esp,%ebp
  800ec6:	57                   	push   %edi
  800ec7:	56                   	push   %esi
  800ec8:	53                   	push   %ebx
  800ec9:	83 ec 1c             	sub    $0x1c,%esp
	// LAB 4: Your code here.
	extern void _pgfault_upcall();
	envid_t new_envid, curenv_id;

	curenv_id = sys_getenvid();
  800ecc:	e8 1e fd ff ff       	call   800bef <sys_getenvid>
	set_pgfault_handler(pgfault);
  800ed1:	83 ec 0c             	sub    $0xc,%esp
  800ed4:	68 1e 0e 80 00       	push   $0x800e1e
  800ed9:	e8 83 0e 00 00       	call   801d61 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  800ede:	b8 07 00 00 00       	mov    $0x7,%eax
  800ee3:	cd 30                	int    $0x30
  800ee5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ee8:	89 45 dc             	mov    %eax,-0x24(%ebp)
	new_envid = sys_exofork();

	if (new_envid < 0)
  800eeb:	83 c4 10             	add    $0x10,%esp
  800eee:	85 c0                	test   %eax,%eax
  800ef0:	79 12                	jns    800f04 <fork+0x41>
	    panic("fork error: %e", new_envid);
  800ef2:	50                   	push   %eax
  800ef3:	68 7c 25 80 00       	push   $0x80257c
  800ef8:	6a 75                	push   $0x75
  800efa:	68 71 25 80 00       	push   $0x802571
  800eff:	e8 49 f2 ff ff       	call   80014d <_panic>
  800f04:	bf 00 00 80 00       	mov    $0x800000,%edi
	else if (new_envid == 0)
  800f09:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800f0d:	75 1c                	jne    800f2b <fork+0x68>
		thisenv = envs + ENVX(sys_getenvid());
  800f0f:	e8 db fc ff ff       	call   800bef <sys_getenvid>
  800f14:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f19:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f1c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f21:	a3 08 40 80 00       	mov    %eax,0x804008
  800f26:	e9 27 01 00 00       	jmp    801052 <fork+0x18f>
	else {

		for (uint32_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
			if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
  800f2b:	89 f8                	mov    %edi,%eax
  800f2d:	c1 e8 16             	shr    $0x16,%eax
  800f30:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f37:	a8 01                	test   $0x1,%al
  800f39:	0f 84 d2 00 00 00    	je     801011 <fork+0x14e>
  800f3f:	89 fb                	mov    %edi,%ebx
  800f41:	c1 eb 0c             	shr    $0xc,%ebx
  800f44:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f4b:	a8 01                	test   $0x1,%al
  800f4d:	0f 84 be 00 00 00    	je     801011 <fork+0x14e>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	int perm = PTE_U | PTE_P;
	envid_t curenvid = sys_getenvid();
  800f53:	e8 97 fc ff ff       	call   800bef <sys_getenvid>
  800f58:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  800f5b:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
		perm |= PTE_COW ;
  800f62:	be 05 08 00 00       	mov    $0x805,%esi
	int r;
	int perm = PTE_U | PTE_P;
	envid_t curenvid = sys_getenvid();

	// LAB 4: Your code here.
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))
  800f67:	a8 02                	test   $0x2,%al
  800f69:	75 1d                	jne    800f88 <fork+0xc5>
  800f6b:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f72:	25 00 08 00 00       	and    $0x800,%eax
		perm |= PTE_COW ;
  800f77:	83 f8 01             	cmp    $0x1,%eax
  800f7a:	19 f6                	sbb    %esi,%esi
  800f7c:	81 e6 00 f8 ff ff    	and    $0xfffff800,%esi
  800f82:	81 c6 05 08 00 00    	add    $0x805,%esi

	if (uvpt[pn] & PTE_SHARE)
  800f88:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f8f:	25 00 04 00 00       	and    $0x400,%eax
		perm |= PTE_SYSCALL;
  800f94:	b8 07 0e 00 00       	mov    $0xe07,%eax
  800f99:	0f 45 f0             	cmovne %eax,%esi

	r = sys_page_map(curenvid, (void *)(pn * PGSIZE),
  800f9c:	89 d8                	mov    %ebx,%eax
  800f9e:	c1 e0 0c             	shl    $0xc,%eax
  800fa1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800fa4:	83 ec 0c             	sub    $0xc,%esp
  800fa7:	56                   	push   %esi
  800fa8:	50                   	push   %eax
  800fa9:	ff 75 dc             	pushl  -0x24(%ebp)
  800fac:	50                   	push   %eax
  800fad:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fb0:	e8 bb fc ff ff       	call   800c70 <sys_page_map>
				envid, (void *)(pn * PGSIZE), perm);
	if (r < 0)
  800fb5:	83 c4 20             	add    $0x20,%esp
  800fb8:	85 c0                	test   %eax,%eax
  800fba:	79 12                	jns    800fce <fork+0x10b>
		panic("duppage error: %e", r);
  800fbc:	50                   	push   %eax
  800fbd:	68 8b 25 80 00       	push   $0x80258b
  800fc2:	6a 4d                	push   $0x4d
  800fc4:	68 71 25 80 00       	push   $0x802571
  800fc9:	e8 7f f1 ff ff       	call   80014d <_panic>
	
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW))	{
  800fce:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800fd5:	a8 02                	test   $0x2,%al
  800fd7:	75 0c                	jne    800fe5 <fork+0x122>
  800fd9:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800fe0:	f6 c4 08             	test   $0x8,%ah
  800fe3:	74 2c                	je     801011 <fork+0x14e>
		r = sys_page_map(curenvid, (void *)(pn * PGSIZE),
  800fe5:	83 ec 0c             	sub    $0xc,%esp
  800fe8:	56                   	push   %esi
  800fe9:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800fec:	52                   	push   %edx
  800fed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800ff0:	50                   	push   %eax
  800ff1:	52                   	push   %edx
  800ff2:	50                   	push   %eax
  800ff3:	e8 78 fc ff ff       	call   800c70 <sys_page_map>
						curenvid, (void *)(pn * PGSIZE), perm);
		if (r < 0)
  800ff8:	83 c4 20             	add    $0x20,%esp
  800ffb:	85 c0                	test   %eax,%eax
  800ffd:	79 12                	jns    801011 <fork+0x14e>
			panic("duppage error: %e", r);
  800fff:	50                   	push   %eax
  801000:	68 8b 25 80 00       	push   $0x80258b
  801005:	6a 53                	push   $0x53
  801007:	68 71 25 80 00       	push   $0x802571
  80100c:	e8 3c f1 ff ff       	call   80014d <_panic>
	    panic("fork error: %e", new_envid);
	else if (new_envid == 0)
		thisenv = envs + ENVX(sys_getenvid());
	else {

		for (uint32_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {
  801011:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801017:	81 ff 00 e0 bf ee    	cmp    $0xeebfe000,%edi
  80101d:	0f 85 08 ff ff ff    	jne    800f2b <fork+0x68>
			if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
				duppage(new_envid, PGNUM(addr));
		}

		sys_page_alloc(new_envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W);
  801023:	83 ec 04             	sub    $0x4,%esp
  801026:	6a 07                	push   $0x7
  801028:	68 00 f0 bf ee       	push   $0xeebff000
  80102d:	8b 75 d8             	mov    -0x28(%ebp),%esi
  801030:	56                   	push   %esi
  801031:	e8 f7 fb ff ff       	call   800c2d <sys_page_alloc>
		sys_env_set_pgfault_upcall(new_envid, _pgfault_upcall);
  801036:	83 c4 08             	add    $0x8,%esp
  801039:	68 a6 1d 80 00       	push   $0x801da6
  80103e:	56                   	push   %esi
  80103f:	e8 34 fd ff ff       	call   800d78 <sys_env_set_pgfault_upcall>
		sys_env_set_status(new_envid, ENV_RUNNABLE);
  801044:	83 c4 08             	add    $0x8,%esp
  801047:	6a 02                	push   $0x2
  801049:	56                   	push   %esi
  80104a:	e8 a5 fc ff ff       	call   800cf4 <sys_env_set_status>
  80104f:	83 c4 10             	add    $0x10,%esp

	}
	return new_envid;
}
  801052:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801055:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801058:	5b                   	pop    %ebx
  801059:	5e                   	pop    %esi
  80105a:	5f                   	pop    %edi
  80105b:	5d                   	pop    %ebp
  80105c:	c3                   	ret    

0080105d <sfork>:

// Challenge!
int
sfork(void)
{
  80105d:	55                   	push   %ebp
  80105e:	89 e5                	mov    %esp,%ebp
  801060:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801063:	68 9d 25 80 00       	push   $0x80259d
  801068:	68 8b 00 00 00       	push   $0x8b
  80106d:	68 71 25 80 00       	push   $0x802571
  801072:	e8 d6 f0 ff ff       	call   80014d <_panic>

00801077 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801077:	55                   	push   %ebp
  801078:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80107a:	8b 45 08             	mov    0x8(%ebp),%eax
  80107d:	05 00 00 00 30       	add    $0x30000000,%eax
  801082:	c1 e8 0c             	shr    $0xc,%eax
}
  801085:	5d                   	pop    %ebp
  801086:	c3                   	ret    

00801087 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801087:	55                   	push   %ebp
  801088:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80108a:	8b 45 08             	mov    0x8(%ebp),%eax
  80108d:	05 00 00 00 30       	add    $0x30000000,%eax
  801092:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801097:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80109c:	5d                   	pop    %ebp
  80109d:	c3                   	ret    

0080109e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80109e:	55                   	push   %ebp
  80109f:	89 e5                	mov    %esp,%ebp
  8010a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010a4:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010a9:	89 c2                	mov    %eax,%edx
  8010ab:	c1 ea 16             	shr    $0x16,%edx
  8010ae:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010b5:	f6 c2 01             	test   $0x1,%dl
  8010b8:	74 11                	je     8010cb <fd_alloc+0x2d>
  8010ba:	89 c2                	mov    %eax,%edx
  8010bc:	c1 ea 0c             	shr    $0xc,%edx
  8010bf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010c6:	f6 c2 01             	test   $0x1,%dl
  8010c9:	75 09                	jne    8010d4 <fd_alloc+0x36>
			*fd_store = fd;
  8010cb:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8010d2:	eb 17                	jmp    8010eb <fd_alloc+0x4d>
  8010d4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010d9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010de:	75 c9                	jne    8010a9 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010e0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010e6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010eb:	5d                   	pop    %ebp
  8010ec:	c3                   	ret    

008010ed <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010ed:	55                   	push   %ebp
  8010ee:	89 e5                	mov    %esp,%ebp
  8010f0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010f3:	83 f8 1f             	cmp    $0x1f,%eax
  8010f6:	77 36                	ja     80112e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010f8:	c1 e0 0c             	shl    $0xc,%eax
  8010fb:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801100:	89 c2                	mov    %eax,%edx
  801102:	c1 ea 16             	shr    $0x16,%edx
  801105:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80110c:	f6 c2 01             	test   $0x1,%dl
  80110f:	74 24                	je     801135 <fd_lookup+0x48>
  801111:	89 c2                	mov    %eax,%edx
  801113:	c1 ea 0c             	shr    $0xc,%edx
  801116:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80111d:	f6 c2 01             	test   $0x1,%dl
  801120:	74 1a                	je     80113c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801122:	8b 55 0c             	mov    0xc(%ebp),%edx
  801125:	89 02                	mov    %eax,(%edx)
	return 0;
  801127:	b8 00 00 00 00       	mov    $0x0,%eax
  80112c:	eb 13                	jmp    801141 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80112e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801133:	eb 0c                	jmp    801141 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801135:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80113a:	eb 05                	jmp    801141 <fd_lookup+0x54>
  80113c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801141:	5d                   	pop    %ebp
  801142:	c3                   	ret    

00801143 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801143:	55                   	push   %ebp
  801144:	89 e5                	mov    %esp,%ebp
  801146:	83 ec 08             	sub    $0x8,%esp
  801149:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80114c:	ba 34 26 80 00       	mov    $0x802634,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801151:	eb 13                	jmp    801166 <dev_lookup+0x23>
  801153:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801156:	39 08                	cmp    %ecx,(%eax)
  801158:	75 0c                	jne    801166 <dev_lookup+0x23>
			*dev = devtab[i];
  80115a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80115d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80115f:	b8 00 00 00 00       	mov    $0x0,%eax
  801164:	eb 2e                	jmp    801194 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801166:	8b 02                	mov    (%edx),%eax
  801168:	85 c0                	test   %eax,%eax
  80116a:	75 e7                	jne    801153 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80116c:	a1 08 40 80 00       	mov    0x804008,%eax
  801171:	8b 40 48             	mov    0x48(%eax),%eax
  801174:	83 ec 04             	sub    $0x4,%esp
  801177:	51                   	push   %ecx
  801178:	50                   	push   %eax
  801179:	68 b4 25 80 00       	push   $0x8025b4
  80117e:	e8 a3 f0 ff ff       	call   800226 <cprintf>
	*dev = 0;
  801183:	8b 45 0c             	mov    0xc(%ebp),%eax
  801186:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80118c:	83 c4 10             	add    $0x10,%esp
  80118f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801194:	c9                   	leave  
  801195:	c3                   	ret    

00801196 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801196:	55                   	push   %ebp
  801197:	89 e5                	mov    %esp,%ebp
  801199:	56                   	push   %esi
  80119a:	53                   	push   %ebx
  80119b:	83 ec 10             	sub    $0x10,%esp
  80119e:	8b 75 08             	mov    0x8(%ebp),%esi
  8011a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011a7:	50                   	push   %eax
  8011a8:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011ae:	c1 e8 0c             	shr    $0xc,%eax
  8011b1:	50                   	push   %eax
  8011b2:	e8 36 ff ff ff       	call   8010ed <fd_lookup>
  8011b7:	83 c4 08             	add    $0x8,%esp
  8011ba:	85 c0                	test   %eax,%eax
  8011bc:	78 05                	js     8011c3 <fd_close+0x2d>
	    || fd != fd2)
  8011be:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011c1:	74 0c                	je     8011cf <fd_close+0x39>
		return (must_exist ? r : 0);
  8011c3:	84 db                	test   %bl,%bl
  8011c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8011ca:	0f 44 c2             	cmove  %edx,%eax
  8011cd:	eb 41                	jmp    801210 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011cf:	83 ec 08             	sub    $0x8,%esp
  8011d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011d5:	50                   	push   %eax
  8011d6:	ff 36                	pushl  (%esi)
  8011d8:	e8 66 ff ff ff       	call   801143 <dev_lookup>
  8011dd:	89 c3                	mov    %eax,%ebx
  8011df:	83 c4 10             	add    $0x10,%esp
  8011e2:	85 c0                	test   %eax,%eax
  8011e4:	78 1a                	js     801200 <fd_close+0x6a>
		if (dev->dev_close)
  8011e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e9:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011ec:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011f1:	85 c0                	test   %eax,%eax
  8011f3:	74 0b                	je     801200 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8011f5:	83 ec 0c             	sub    $0xc,%esp
  8011f8:	56                   	push   %esi
  8011f9:	ff d0                	call   *%eax
  8011fb:	89 c3                	mov    %eax,%ebx
  8011fd:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801200:	83 ec 08             	sub    $0x8,%esp
  801203:	56                   	push   %esi
  801204:	6a 00                	push   $0x0
  801206:	e8 a7 fa ff ff       	call   800cb2 <sys_page_unmap>
	return r;
  80120b:	83 c4 10             	add    $0x10,%esp
  80120e:	89 d8                	mov    %ebx,%eax
}
  801210:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801213:	5b                   	pop    %ebx
  801214:	5e                   	pop    %esi
  801215:	5d                   	pop    %ebp
  801216:	c3                   	ret    

00801217 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801217:	55                   	push   %ebp
  801218:	89 e5                	mov    %esp,%ebp
  80121a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80121d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801220:	50                   	push   %eax
  801221:	ff 75 08             	pushl  0x8(%ebp)
  801224:	e8 c4 fe ff ff       	call   8010ed <fd_lookup>
  801229:	83 c4 08             	add    $0x8,%esp
  80122c:	85 c0                	test   %eax,%eax
  80122e:	78 10                	js     801240 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801230:	83 ec 08             	sub    $0x8,%esp
  801233:	6a 01                	push   $0x1
  801235:	ff 75 f4             	pushl  -0xc(%ebp)
  801238:	e8 59 ff ff ff       	call   801196 <fd_close>
  80123d:	83 c4 10             	add    $0x10,%esp
}
  801240:	c9                   	leave  
  801241:	c3                   	ret    

00801242 <close_all>:

void
close_all(void)
{
  801242:	55                   	push   %ebp
  801243:	89 e5                	mov    %esp,%ebp
  801245:	53                   	push   %ebx
  801246:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801249:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80124e:	83 ec 0c             	sub    $0xc,%esp
  801251:	53                   	push   %ebx
  801252:	e8 c0 ff ff ff       	call   801217 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801257:	83 c3 01             	add    $0x1,%ebx
  80125a:	83 c4 10             	add    $0x10,%esp
  80125d:	83 fb 20             	cmp    $0x20,%ebx
  801260:	75 ec                	jne    80124e <close_all+0xc>
		close(i);
}
  801262:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801265:	c9                   	leave  
  801266:	c3                   	ret    

00801267 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801267:	55                   	push   %ebp
  801268:	89 e5                	mov    %esp,%ebp
  80126a:	57                   	push   %edi
  80126b:	56                   	push   %esi
  80126c:	53                   	push   %ebx
  80126d:	83 ec 2c             	sub    $0x2c,%esp
  801270:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801273:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801276:	50                   	push   %eax
  801277:	ff 75 08             	pushl  0x8(%ebp)
  80127a:	e8 6e fe ff ff       	call   8010ed <fd_lookup>
  80127f:	83 c4 08             	add    $0x8,%esp
  801282:	85 c0                	test   %eax,%eax
  801284:	0f 88 c1 00 00 00    	js     80134b <dup+0xe4>
		return r;
	close(newfdnum);
  80128a:	83 ec 0c             	sub    $0xc,%esp
  80128d:	56                   	push   %esi
  80128e:	e8 84 ff ff ff       	call   801217 <close>

	newfd = INDEX2FD(newfdnum);
  801293:	89 f3                	mov    %esi,%ebx
  801295:	c1 e3 0c             	shl    $0xc,%ebx
  801298:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80129e:	83 c4 04             	add    $0x4,%esp
  8012a1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012a4:	e8 de fd ff ff       	call   801087 <fd2data>
  8012a9:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012ab:	89 1c 24             	mov    %ebx,(%esp)
  8012ae:	e8 d4 fd ff ff       	call   801087 <fd2data>
  8012b3:	83 c4 10             	add    $0x10,%esp
  8012b6:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012b9:	89 f8                	mov    %edi,%eax
  8012bb:	c1 e8 16             	shr    $0x16,%eax
  8012be:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012c5:	a8 01                	test   $0x1,%al
  8012c7:	74 37                	je     801300 <dup+0x99>
  8012c9:	89 f8                	mov    %edi,%eax
  8012cb:	c1 e8 0c             	shr    $0xc,%eax
  8012ce:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012d5:	f6 c2 01             	test   $0x1,%dl
  8012d8:	74 26                	je     801300 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012da:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012e1:	83 ec 0c             	sub    $0xc,%esp
  8012e4:	25 07 0e 00 00       	and    $0xe07,%eax
  8012e9:	50                   	push   %eax
  8012ea:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012ed:	6a 00                	push   $0x0
  8012ef:	57                   	push   %edi
  8012f0:	6a 00                	push   $0x0
  8012f2:	e8 79 f9 ff ff       	call   800c70 <sys_page_map>
  8012f7:	89 c7                	mov    %eax,%edi
  8012f9:	83 c4 20             	add    $0x20,%esp
  8012fc:	85 c0                	test   %eax,%eax
  8012fe:	78 2e                	js     80132e <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801300:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801303:	89 d0                	mov    %edx,%eax
  801305:	c1 e8 0c             	shr    $0xc,%eax
  801308:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80130f:	83 ec 0c             	sub    $0xc,%esp
  801312:	25 07 0e 00 00       	and    $0xe07,%eax
  801317:	50                   	push   %eax
  801318:	53                   	push   %ebx
  801319:	6a 00                	push   $0x0
  80131b:	52                   	push   %edx
  80131c:	6a 00                	push   $0x0
  80131e:	e8 4d f9 ff ff       	call   800c70 <sys_page_map>
  801323:	89 c7                	mov    %eax,%edi
  801325:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801328:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80132a:	85 ff                	test   %edi,%edi
  80132c:	79 1d                	jns    80134b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80132e:	83 ec 08             	sub    $0x8,%esp
  801331:	53                   	push   %ebx
  801332:	6a 00                	push   $0x0
  801334:	e8 79 f9 ff ff       	call   800cb2 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801339:	83 c4 08             	add    $0x8,%esp
  80133c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80133f:	6a 00                	push   $0x0
  801341:	e8 6c f9 ff ff       	call   800cb2 <sys_page_unmap>
	return r;
  801346:	83 c4 10             	add    $0x10,%esp
  801349:	89 f8                	mov    %edi,%eax
}
  80134b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80134e:	5b                   	pop    %ebx
  80134f:	5e                   	pop    %esi
  801350:	5f                   	pop    %edi
  801351:	5d                   	pop    %ebp
  801352:	c3                   	ret    

00801353 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801353:	55                   	push   %ebp
  801354:	89 e5                	mov    %esp,%ebp
  801356:	53                   	push   %ebx
  801357:	83 ec 14             	sub    $0x14,%esp
  80135a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80135d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801360:	50                   	push   %eax
  801361:	53                   	push   %ebx
  801362:	e8 86 fd ff ff       	call   8010ed <fd_lookup>
  801367:	83 c4 08             	add    $0x8,%esp
  80136a:	89 c2                	mov    %eax,%edx
  80136c:	85 c0                	test   %eax,%eax
  80136e:	78 6d                	js     8013dd <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801370:	83 ec 08             	sub    $0x8,%esp
  801373:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801376:	50                   	push   %eax
  801377:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80137a:	ff 30                	pushl  (%eax)
  80137c:	e8 c2 fd ff ff       	call   801143 <dev_lookup>
  801381:	83 c4 10             	add    $0x10,%esp
  801384:	85 c0                	test   %eax,%eax
  801386:	78 4c                	js     8013d4 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801388:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80138b:	8b 42 08             	mov    0x8(%edx),%eax
  80138e:	83 e0 03             	and    $0x3,%eax
  801391:	83 f8 01             	cmp    $0x1,%eax
  801394:	75 21                	jne    8013b7 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801396:	a1 08 40 80 00       	mov    0x804008,%eax
  80139b:	8b 40 48             	mov    0x48(%eax),%eax
  80139e:	83 ec 04             	sub    $0x4,%esp
  8013a1:	53                   	push   %ebx
  8013a2:	50                   	push   %eax
  8013a3:	68 f8 25 80 00       	push   $0x8025f8
  8013a8:	e8 79 ee ff ff       	call   800226 <cprintf>
		return -E_INVAL;
  8013ad:	83 c4 10             	add    $0x10,%esp
  8013b0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013b5:	eb 26                	jmp    8013dd <read+0x8a>
	}
	if (!dev->dev_read)
  8013b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013ba:	8b 40 08             	mov    0x8(%eax),%eax
  8013bd:	85 c0                	test   %eax,%eax
  8013bf:	74 17                	je     8013d8 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013c1:	83 ec 04             	sub    $0x4,%esp
  8013c4:	ff 75 10             	pushl  0x10(%ebp)
  8013c7:	ff 75 0c             	pushl  0xc(%ebp)
  8013ca:	52                   	push   %edx
  8013cb:	ff d0                	call   *%eax
  8013cd:	89 c2                	mov    %eax,%edx
  8013cf:	83 c4 10             	add    $0x10,%esp
  8013d2:	eb 09                	jmp    8013dd <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013d4:	89 c2                	mov    %eax,%edx
  8013d6:	eb 05                	jmp    8013dd <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013d8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8013dd:	89 d0                	mov    %edx,%eax
  8013df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013e2:	c9                   	leave  
  8013e3:	c3                   	ret    

008013e4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013e4:	55                   	push   %ebp
  8013e5:	89 e5                	mov    %esp,%ebp
  8013e7:	57                   	push   %edi
  8013e8:	56                   	push   %esi
  8013e9:	53                   	push   %ebx
  8013ea:	83 ec 0c             	sub    $0xc,%esp
  8013ed:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013f0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013f3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013f8:	eb 21                	jmp    80141b <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013fa:	83 ec 04             	sub    $0x4,%esp
  8013fd:	89 f0                	mov    %esi,%eax
  8013ff:	29 d8                	sub    %ebx,%eax
  801401:	50                   	push   %eax
  801402:	89 d8                	mov    %ebx,%eax
  801404:	03 45 0c             	add    0xc(%ebp),%eax
  801407:	50                   	push   %eax
  801408:	57                   	push   %edi
  801409:	e8 45 ff ff ff       	call   801353 <read>
		if (m < 0)
  80140e:	83 c4 10             	add    $0x10,%esp
  801411:	85 c0                	test   %eax,%eax
  801413:	78 10                	js     801425 <readn+0x41>
			return m;
		if (m == 0)
  801415:	85 c0                	test   %eax,%eax
  801417:	74 0a                	je     801423 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801419:	01 c3                	add    %eax,%ebx
  80141b:	39 f3                	cmp    %esi,%ebx
  80141d:	72 db                	jb     8013fa <readn+0x16>
  80141f:	89 d8                	mov    %ebx,%eax
  801421:	eb 02                	jmp    801425 <readn+0x41>
  801423:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801425:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801428:	5b                   	pop    %ebx
  801429:	5e                   	pop    %esi
  80142a:	5f                   	pop    %edi
  80142b:	5d                   	pop    %ebp
  80142c:	c3                   	ret    

0080142d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80142d:	55                   	push   %ebp
  80142e:	89 e5                	mov    %esp,%ebp
  801430:	53                   	push   %ebx
  801431:	83 ec 14             	sub    $0x14,%esp
  801434:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801437:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80143a:	50                   	push   %eax
  80143b:	53                   	push   %ebx
  80143c:	e8 ac fc ff ff       	call   8010ed <fd_lookup>
  801441:	83 c4 08             	add    $0x8,%esp
  801444:	89 c2                	mov    %eax,%edx
  801446:	85 c0                	test   %eax,%eax
  801448:	78 68                	js     8014b2 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80144a:	83 ec 08             	sub    $0x8,%esp
  80144d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801450:	50                   	push   %eax
  801451:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801454:	ff 30                	pushl  (%eax)
  801456:	e8 e8 fc ff ff       	call   801143 <dev_lookup>
  80145b:	83 c4 10             	add    $0x10,%esp
  80145e:	85 c0                	test   %eax,%eax
  801460:	78 47                	js     8014a9 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801462:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801465:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801469:	75 21                	jne    80148c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80146b:	a1 08 40 80 00       	mov    0x804008,%eax
  801470:	8b 40 48             	mov    0x48(%eax),%eax
  801473:	83 ec 04             	sub    $0x4,%esp
  801476:	53                   	push   %ebx
  801477:	50                   	push   %eax
  801478:	68 14 26 80 00       	push   $0x802614
  80147d:	e8 a4 ed ff ff       	call   800226 <cprintf>
		return -E_INVAL;
  801482:	83 c4 10             	add    $0x10,%esp
  801485:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80148a:	eb 26                	jmp    8014b2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80148c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80148f:	8b 52 0c             	mov    0xc(%edx),%edx
  801492:	85 d2                	test   %edx,%edx
  801494:	74 17                	je     8014ad <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801496:	83 ec 04             	sub    $0x4,%esp
  801499:	ff 75 10             	pushl  0x10(%ebp)
  80149c:	ff 75 0c             	pushl  0xc(%ebp)
  80149f:	50                   	push   %eax
  8014a0:	ff d2                	call   *%edx
  8014a2:	89 c2                	mov    %eax,%edx
  8014a4:	83 c4 10             	add    $0x10,%esp
  8014a7:	eb 09                	jmp    8014b2 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a9:	89 c2                	mov    %eax,%edx
  8014ab:	eb 05                	jmp    8014b2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014ad:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014b2:	89 d0                	mov    %edx,%eax
  8014b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014b7:	c9                   	leave  
  8014b8:	c3                   	ret    

008014b9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8014b9:	55                   	push   %ebp
  8014ba:	89 e5                	mov    %esp,%ebp
  8014bc:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014bf:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014c2:	50                   	push   %eax
  8014c3:	ff 75 08             	pushl  0x8(%ebp)
  8014c6:	e8 22 fc ff ff       	call   8010ed <fd_lookup>
  8014cb:	83 c4 08             	add    $0x8,%esp
  8014ce:	85 c0                	test   %eax,%eax
  8014d0:	78 0e                	js     8014e0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014d8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014db:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014e0:	c9                   	leave  
  8014e1:	c3                   	ret    

008014e2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014e2:	55                   	push   %ebp
  8014e3:	89 e5                	mov    %esp,%ebp
  8014e5:	53                   	push   %ebx
  8014e6:	83 ec 14             	sub    $0x14,%esp
  8014e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014ef:	50                   	push   %eax
  8014f0:	53                   	push   %ebx
  8014f1:	e8 f7 fb ff ff       	call   8010ed <fd_lookup>
  8014f6:	83 c4 08             	add    $0x8,%esp
  8014f9:	89 c2                	mov    %eax,%edx
  8014fb:	85 c0                	test   %eax,%eax
  8014fd:	78 65                	js     801564 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ff:	83 ec 08             	sub    $0x8,%esp
  801502:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801505:	50                   	push   %eax
  801506:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801509:	ff 30                	pushl  (%eax)
  80150b:	e8 33 fc ff ff       	call   801143 <dev_lookup>
  801510:	83 c4 10             	add    $0x10,%esp
  801513:	85 c0                	test   %eax,%eax
  801515:	78 44                	js     80155b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801517:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80151a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80151e:	75 21                	jne    801541 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801520:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801525:	8b 40 48             	mov    0x48(%eax),%eax
  801528:	83 ec 04             	sub    $0x4,%esp
  80152b:	53                   	push   %ebx
  80152c:	50                   	push   %eax
  80152d:	68 d4 25 80 00       	push   $0x8025d4
  801532:	e8 ef ec ff ff       	call   800226 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801537:	83 c4 10             	add    $0x10,%esp
  80153a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80153f:	eb 23                	jmp    801564 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801541:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801544:	8b 52 18             	mov    0x18(%edx),%edx
  801547:	85 d2                	test   %edx,%edx
  801549:	74 14                	je     80155f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80154b:	83 ec 08             	sub    $0x8,%esp
  80154e:	ff 75 0c             	pushl  0xc(%ebp)
  801551:	50                   	push   %eax
  801552:	ff d2                	call   *%edx
  801554:	89 c2                	mov    %eax,%edx
  801556:	83 c4 10             	add    $0x10,%esp
  801559:	eb 09                	jmp    801564 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80155b:	89 c2                	mov    %eax,%edx
  80155d:	eb 05                	jmp    801564 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80155f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801564:	89 d0                	mov    %edx,%eax
  801566:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801569:	c9                   	leave  
  80156a:	c3                   	ret    

0080156b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80156b:	55                   	push   %ebp
  80156c:	89 e5                	mov    %esp,%ebp
  80156e:	53                   	push   %ebx
  80156f:	83 ec 14             	sub    $0x14,%esp
  801572:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801575:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801578:	50                   	push   %eax
  801579:	ff 75 08             	pushl  0x8(%ebp)
  80157c:	e8 6c fb ff ff       	call   8010ed <fd_lookup>
  801581:	83 c4 08             	add    $0x8,%esp
  801584:	89 c2                	mov    %eax,%edx
  801586:	85 c0                	test   %eax,%eax
  801588:	78 58                	js     8015e2 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80158a:	83 ec 08             	sub    $0x8,%esp
  80158d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801590:	50                   	push   %eax
  801591:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801594:	ff 30                	pushl  (%eax)
  801596:	e8 a8 fb ff ff       	call   801143 <dev_lookup>
  80159b:	83 c4 10             	add    $0x10,%esp
  80159e:	85 c0                	test   %eax,%eax
  8015a0:	78 37                	js     8015d9 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015a5:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015a9:	74 32                	je     8015dd <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015ab:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015ae:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015b5:	00 00 00 
	stat->st_isdir = 0;
  8015b8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015bf:	00 00 00 
	stat->st_dev = dev;
  8015c2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015c8:	83 ec 08             	sub    $0x8,%esp
  8015cb:	53                   	push   %ebx
  8015cc:	ff 75 f0             	pushl  -0x10(%ebp)
  8015cf:	ff 50 14             	call   *0x14(%eax)
  8015d2:	89 c2                	mov    %eax,%edx
  8015d4:	83 c4 10             	add    $0x10,%esp
  8015d7:	eb 09                	jmp    8015e2 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d9:	89 c2                	mov    %eax,%edx
  8015db:	eb 05                	jmp    8015e2 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015dd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015e2:	89 d0                	mov    %edx,%eax
  8015e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e7:	c9                   	leave  
  8015e8:	c3                   	ret    

008015e9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015e9:	55                   	push   %ebp
  8015ea:	89 e5                	mov    %esp,%ebp
  8015ec:	56                   	push   %esi
  8015ed:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015ee:	83 ec 08             	sub    $0x8,%esp
  8015f1:	6a 00                	push   $0x0
  8015f3:	ff 75 08             	pushl  0x8(%ebp)
  8015f6:	e8 e3 01 00 00       	call   8017de <open>
  8015fb:	89 c3                	mov    %eax,%ebx
  8015fd:	83 c4 10             	add    $0x10,%esp
  801600:	85 c0                	test   %eax,%eax
  801602:	78 1b                	js     80161f <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801604:	83 ec 08             	sub    $0x8,%esp
  801607:	ff 75 0c             	pushl  0xc(%ebp)
  80160a:	50                   	push   %eax
  80160b:	e8 5b ff ff ff       	call   80156b <fstat>
  801610:	89 c6                	mov    %eax,%esi
	close(fd);
  801612:	89 1c 24             	mov    %ebx,(%esp)
  801615:	e8 fd fb ff ff       	call   801217 <close>
	return r;
  80161a:	83 c4 10             	add    $0x10,%esp
  80161d:	89 f0                	mov    %esi,%eax
}
  80161f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801622:	5b                   	pop    %ebx
  801623:	5e                   	pop    %esi
  801624:	5d                   	pop    %ebp
  801625:	c3                   	ret    

00801626 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801626:	55                   	push   %ebp
  801627:	89 e5                	mov    %esp,%ebp
  801629:	56                   	push   %esi
  80162a:	53                   	push   %ebx
  80162b:	89 c6                	mov    %eax,%esi
  80162d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80162f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801636:	75 12                	jne    80164a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801638:	83 ec 0c             	sub    $0xc,%esp
  80163b:	6a 01                	push   $0x1
  80163d:	e8 50 08 00 00       	call   801e92 <ipc_find_env>
  801642:	a3 00 40 80 00       	mov    %eax,0x804000
  801647:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80164a:	6a 07                	push   $0x7
  80164c:	68 00 50 80 00       	push   $0x805000
  801651:	56                   	push   %esi
  801652:	ff 35 00 40 80 00    	pushl  0x804000
  801658:	e8 e1 07 00 00       	call   801e3e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80165d:	83 c4 0c             	add    $0xc,%esp
  801660:	6a 00                	push   $0x0
  801662:	53                   	push   %ebx
  801663:	6a 00                	push   $0x0
  801665:	e8 62 07 00 00       	call   801dcc <ipc_recv>
}
  80166a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80166d:	5b                   	pop    %ebx
  80166e:	5e                   	pop    %esi
  80166f:	5d                   	pop    %ebp
  801670:	c3                   	ret    

00801671 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801671:	55                   	push   %ebp
  801672:	89 e5                	mov    %esp,%ebp
  801674:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801677:	8b 45 08             	mov    0x8(%ebp),%eax
  80167a:	8b 40 0c             	mov    0xc(%eax),%eax
  80167d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801682:	8b 45 0c             	mov    0xc(%ebp),%eax
  801685:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80168a:	ba 00 00 00 00       	mov    $0x0,%edx
  80168f:	b8 02 00 00 00       	mov    $0x2,%eax
  801694:	e8 8d ff ff ff       	call   801626 <fsipc>
}
  801699:	c9                   	leave  
  80169a:	c3                   	ret    

0080169b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80169b:	55                   	push   %ebp
  80169c:	89 e5                	mov    %esp,%ebp
  80169e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a4:	8b 40 0c             	mov    0xc(%eax),%eax
  8016a7:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b1:	b8 06 00 00 00       	mov    $0x6,%eax
  8016b6:	e8 6b ff ff ff       	call   801626 <fsipc>
}
  8016bb:	c9                   	leave  
  8016bc:	c3                   	ret    

008016bd <devfile_stat>:
	return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016bd:	55                   	push   %ebp
  8016be:	89 e5                	mov    %esp,%ebp
  8016c0:	53                   	push   %ebx
  8016c1:	83 ec 04             	sub    $0x4,%esp
  8016c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ca:	8b 40 0c             	mov    0xc(%eax),%eax
  8016cd:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d7:	b8 05 00 00 00       	mov    $0x5,%eax
  8016dc:	e8 45 ff ff ff       	call   801626 <fsipc>
  8016e1:	85 c0                	test   %eax,%eax
  8016e3:	78 2c                	js     801711 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016e5:	83 ec 08             	sub    $0x8,%esp
  8016e8:	68 00 50 80 00       	push   $0x805000
  8016ed:	53                   	push   %ebx
  8016ee:	e8 37 f1 ff ff       	call   80082a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016f3:	a1 80 50 80 00       	mov    0x805080,%eax
  8016f8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016fe:	a1 84 50 80 00       	mov    0x805084,%eax
  801703:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801709:	83 c4 10             	add    $0x10,%esp
  80170c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801711:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801714:	c9                   	leave  
  801715:	c3                   	ret    

00801716 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801716:	55                   	push   %ebp
  801717:	89 e5                	mov    %esp,%ebp
  801719:	83 ec 0c             	sub    $0xc,%esp
  80171c:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 5: Your code here
	
	int r;

	n = MIN(n, sizeof(fsipcbuf.write.req_buf));
  80171f:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801724:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801729:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80172c:	8b 55 08             	mov    0x8(%ebp),%edx
  80172f:	8b 52 0c             	mov    0xc(%edx),%edx
  801732:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801738:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80173d:	50                   	push   %eax
  80173e:	ff 75 0c             	pushl  0xc(%ebp)
  801741:	68 08 50 80 00       	push   $0x805008
  801746:	e8 71 f2 ff ff       	call   8009bc <memmove>
	
	return fsipc(FSREQ_WRITE, NULL);	
  80174b:	ba 00 00 00 00       	mov    $0x0,%edx
  801750:	b8 04 00 00 00       	mov    $0x4,%eax
  801755:	e8 cc fe ff ff       	call   801626 <fsipc>
}
  80175a:	c9                   	leave  
  80175b:	c3                   	ret    

0080175c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80175c:	55                   	push   %ebp
  80175d:	89 e5                	mov    %esp,%ebp
  80175f:	56                   	push   %esi
  801760:	53                   	push   %ebx
  801761:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801764:	8b 45 08             	mov    0x8(%ebp),%eax
  801767:	8b 40 0c             	mov    0xc(%eax),%eax
  80176a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80176f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801775:	ba 00 00 00 00       	mov    $0x0,%edx
  80177a:	b8 03 00 00 00       	mov    $0x3,%eax
  80177f:	e8 a2 fe ff ff       	call   801626 <fsipc>
  801784:	89 c3                	mov    %eax,%ebx
  801786:	85 c0                	test   %eax,%eax
  801788:	78 4b                	js     8017d5 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80178a:	39 c6                	cmp    %eax,%esi
  80178c:	73 16                	jae    8017a4 <devfile_read+0x48>
  80178e:	68 44 26 80 00       	push   $0x802644
  801793:	68 4b 26 80 00       	push   $0x80264b
  801798:	6a 7c                	push   $0x7c
  80179a:	68 60 26 80 00       	push   $0x802660
  80179f:	e8 a9 e9 ff ff       	call   80014d <_panic>
	assert(r <= PGSIZE);
  8017a4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017a9:	7e 16                	jle    8017c1 <devfile_read+0x65>
  8017ab:	68 6b 26 80 00       	push   $0x80266b
  8017b0:	68 4b 26 80 00       	push   $0x80264b
  8017b5:	6a 7d                	push   $0x7d
  8017b7:	68 60 26 80 00       	push   $0x802660
  8017bc:	e8 8c e9 ff ff       	call   80014d <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017c1:	83 ec 04             	sub    $0x4,%esp
  8017c4:	50                   	push   %eax
  8017c5:	68 00 50 80 00       	push   $0x805000
  8017ca:	ff 75 0c             	pushl  0xc(%ebp)
  8017cd:	e8 ea f1 ff ff       	call   8009bc <memmove>
	return r;
  8017d2:	83 c4 10             	add    $0x10,%esp
}
  8017d5:	89 d8                	mov    %ebx,%eax
  8017d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017da:	5b                   	pop    %ebx
  8017db:	5e                   	pop    %esi
  8017dc:	5d                   	pop    %ebp
  8017dd:	c3                   	ret    

008017de <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017de:	55                   	push   %ebp
  8017df:	89 e5                	mov    %esp,%ebp
  8017e1:	53                   	push   %ebx
  8017e2:	83 ec 20             	sub    $0x20,%esp
  8017e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017e8:	53                   	push   %ebx
  8017e9:	e8 03 f0 ff ff       	call   8007f1 <strlen>
  8017ee:	83 c4 10             	add    $0x10,%esp
  8017f1:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017f6:	7f 67                	jg     80185f <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017f8:	83 ec 0c             	sub    $0xc,%esp
  8017fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017fe:	50                   	push   %eax
  8017ff:	e8 9a f8 ff ff       	call   80109e <fd_alloc>
  801804:	83 c4 10             	add    $0x10,%esp
		return r;
  801807:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801809:	85 c0                	test   %eax,%eax
  80180b:	78 57                	js     801864 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80180d:	83 ec 08             	sub    $0x8,%esp
  801810:	53                   	push   %ebx
  801811:	68 00 50 80 00       	push   $0x805000
  801816:	e8 0f f0 ff ff       	call   80082a <strcpy>
	fsipcbuf.open.req_omode = mode;
  80181b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80181e:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801823:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801826:	b8 01 00 00 00       	mov    $0x1,%eax
  80182b:	e8 f6 fd ff ff       	call   801626 <fsipc>
  801830:	89 c3                	mov    %eax,%ebx
  801832:	83 c4 10             	add    $0x10,%esp
  801835:	85 c0                	test   %eax,%eax
  801837:	79 14                	jns    80184d <open+0x6f>
		fd_close(fd, 0);
  801839:	83 ec 08             	sub    $0x8,%esp
  80183c:	6a 00                	push   $0x0
  80183e:	ff 75 f4             	pushl  -0xc(%ebp)
  801841:	e8 50 f9 ff ff       	call   801196 <fd_close>
		return r;
  801846:	83 c4 10             	add    $0x10,%esp
  801849:	89 da                	mov    %ebx,%edx
  80184b:	eb 17                	jmp    801864 <open+0x86>
	}

	return fd2num(fd);
  80184d:	83 ec 0c             	sub    $0xc,%esp
  801850:	ff 75 f4             	pushl  -0xc(%ebp)
  801853:	e8 1f f8 ff ff       	call   801077 <fd2num>
  801858:	89 c2                	mov    %eax,%edx
  80185a:	83 c4 10             	add    $0x10,%esp
  80185d:	eb 05                	jmp    801864 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80185f:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801864:	89 d0                	mov    %edx,%eax
  801866:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801869:	c9                   	leave  
  80186a:	c3                   	ret    

0080186b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80186b:	55                   	push   %ebp
  80186c:	89 e5                	mov    %esp,%ebp
  80186e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801871:	ba 00 00 00 00       	mov    $0x0,%edx
  801876:	b8 08 00 00 00       	mov    $0x8,%eax
  80187b:	e8 a6 fd ff ff       	call   801626 <fsipc>
}
  801880:	c9                   	leave  
  801881:	c3                   	ret    

00801882 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801882:	55                   	push   %ebp
  801883:	89 e5                	mov    %esp,%ebp
  801885:	56                   	push   %esi
  801886:	53                   	push   %ebx
  801887:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80188a:	83 ec 0c             	sub    $0xc,%esp
  80188d:	ff 75 08             	pushl  0x8(%ebp)
  801890:	e8 f2 f7 ff ff       	call   801087 <fd2data>
  801895:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801897:	83 c4 08             	add    $0x8,%esp
  80189a:	68 77 26 80 00       	push   $0x802677
  80189f:	53                   	push   %ebx
  8018a0:	e8 85 ef ff ff       	call   80082a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018a5:	8b 46 04             	mov    0x4(%esi),%eax
  8018a8:	2b 06                	sub    (%esi),%eax
  8018aa:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8018b0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018b7:	00 00 00 
	stat->st_dev = &devpipe;
  8018ba:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8018c1:	30 80 00 
	return 0;
}
  8018c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8018c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018cc:	5b                   	pop    %ebx
  8018cd:	5e                   	pop    %esi
  8018ce:	5d                   	pop    %ebp
  8018cf:	c3                   	ret    

008018d0 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018d0:	55                   	push   %ebp
  8018d1:	89 e5                	mov    %esp,%ebp
  8018d3:	53                   	push   %ebx
  8018d4:	83 ec 0c             	sub    $0xc,%esp
  8018d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8018da:	53                   	push   %ebx
  8018db:	6a 00                	push   $0x0
  8018dd:	e8 d0 f3 ff ff       	call   800cb2 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8018e2:	89 1c 24             	mov    %ebx,(%esp)
  8018e5:	e8 9d f7 ff ff       	call   801087 <fd2data>
  8018ea:	83 c4 08             	add    $0x8,%esp
  8018ed:	50                   	push   %eax
  8018ee:	6a 00                	push   $0x0
  8018f0:	e8 bd f3 ff ff       	call   800cb2 <sys_page_unmap>
}
  8018f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018f8:	c9                   	leave  
  8018f9:	c3                   	ret    

008018fa <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8018fa:	55                   	push   %ebp
  8018fb:	89 e5                	mov    %esp,%ebp
  8018fd:	57                   	push   %edi
  8018fe:	56                   	push   %esi
  8018ff:	53                   	push   %ebx
  801900:	83 ec 1c             	sub    $0x1c,%esp
  801903:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801906:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801908:	a1 08 40 80 00       	mov    0x804008,%eax
  80190d:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801910:	83 ec 0c             	sub    $0xc,%esp
  801913:	ff 75 e0             	pushl  -0x20(%ebp)
  801916:	e8 b0 05 00 00       	call   801ecb <pageref>
  80191b:	89 c3                	mov    %eax,%ebx
  80191d:	89 3c 24             	mov    %edi,(%esp)
  801920:	e8 a6 05 00 00       	call   801ecb <pageref>
  801925:	83 c4 10             	add    $0x10,%esp
  801928:	39 c3                	cmp    %eax,%ebx
  80192a:	0f 94 c1             	sete   %cl
  80192d:	0f b6 c9             	movzbl %cl,%ecx
  801930:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801933:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801939:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80193c:	39 ce                	cmp    %ecx,%esi
  80193e:	74 1b                	je     80195b <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801940:	39 c3                	cmp    %eax,%ebx
  801942:	75 c4                	jne    801908 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801944:	8b 42 58             	mov    0x58(%edx),%eax
  801947:	ff 75 e4             	pushl  -0x1c(%ebp)
  80194a:	50                   	push   %eax
  80194b:	56                   	push   %esi
  80194c:	68 7e 26 80 00       	push   $0x80267e
  801951:	e8 d0 e8 ff ff       	call   800226 <cprintf>
  801956:	83 c4 10             	add    $0x10,%esp
  801959:	eb ad                	jmp    801908 <_pipeisclosed+0xe>
	}
}
  80195b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80195e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801961:	5b                   	pop    %ebx
  801962:	5e                   	pop    %esi
  801963:	5f                   	pop    %edi
  801964:	5d                   	pop    %ebp
  801965:	c3                   	ret    

00801966 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801966:	55                   	push   %ebp
  801967:	89 e5                	mov    %esp,%ebp
  801969:	57                   	push   %edi
  80196a:	56                   	push   %esi
  80196b:	53                   	push   %ebx
  80196c:	83 ec 28             	sub    $0x28,%esp
  80196f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801972:	56                   	push   %esi
  801973:	e8 0f f7 ff ff       	call   801087 <fd2data>
  801978:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80197a:	83 c4 10             	add    $0x10,%esp
  80197d:	bf 00 00 00 00       	mov    $0x0,%edi
  801982:	eb 4b                	jmp    8019cf <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801984:	89 da                	mov    %ebx,%edx
  801986:	89 f0                	mov    %esi,%eax
  801988:	e8 6d ff ff ff       	call   8018fa <_pipeisclosed>
  80198d:	85 c0                	test   %eax,%eax
  80198f:	75 48                	jne    8019d9 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801991:	e8 78 f2 ff ff       	call   800c0e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801996:	8b 43 04             	mov    0x4(%ebx),%eax
  801999:	8b 0b                	mov    (%ebx),%ecx
  80199b:	8d 51 20             	lea    0x20(%ecx),%edx
  80199e:	39 d0                	cmp    %edx,%eax
  8019a0:	73 e2                	jae    801984 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019a5:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8019a9:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8019ac:	89 c2                	mov    %eax,%edx
  8019ae:	c1 fa 1f             	sar    $0x1f,%edx
  8019b1:	89 d1                	mov    %edx,%ecx
  8019b3:	c1 e9 1b             	shr    $0x1b,%ecx
  8019b6:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8019b9:	83 e2 1f             	and    $0x1f,%edx
  8019bc:	29 ca                	sub    %ecx,%edx
  8019be:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8019c2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8019c6:	83 c0 01             	add    $0x1,%eax
  8019c9:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019cc:	83 c7 01             	add    $0x1,%edi
  8019cf:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8019d2:	75 c2                	jne    801996 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8019d4:	8b 45 10             	mov    0x10(%ebp),%eax
  8019d7:	eb 05                	jmp    8019de <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019d9:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8019de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019e1:	5b                   	pop    %ebx
  8019e2:	5e                   	pop    %esi
  8019e3:	5f                   	pop    %edi
  8019e4:	5d                   	pop    %ebp
  8019e5:	c3                   	ret    

008019e6 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019e6:	55                   	push   %ebp
  8019e7:	89 e5                	mov    %esp,%ebp
  8019e9:	57                   	push   %edi
  8019ea:	56                   	push   %esi
  8019eb:	53                   	push   %ebx
  8019ec:	83 ec 18             	sub    $0x18,%esp
  8019ef:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8019f2:	57                   	push   %edi
  8019f3:	e8 8f f6 ff ff       	call   801087 <fd2data>
  8019f8:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019fa:	83 c4 10             	add    $0x10,%esp
  8019fd:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a02:	eb 3d                	jmp    801a41 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a04:	85 db                	test   %ebx,%ebx
  801a06:	74 04                	je     801a0c <devpipe_read+0x26>
				return i;
  801a08:	89 d8                	mov    %ebx,%eax
  801a0a:	eb 44                	jmp    801a50 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a0c:	89 f2                	mov    %esi,%edx
  801a0e:	89 f8                	mov    %edi,%eax
  801a10:	e8 e5 fe ff ff       	call   8018fa <_pipeisclosed>
  801a15:	85 c0                	test   %eax,%eax
  801a17:	75 32                	jne    801a4b <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a19:	e8 f0 f1 ff ff       	call   800c0e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a1e:	8b 06                	mov    (%esi),%eax
  801a20:	3b 46 04             	cmp    0x4(%esi),%eax
  801a23:	74 df                	je     801a04 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a25:	99                   	cltd   
  801a26:	c1 ea 1b             	shr    $0x1b,%edx
  801a29:	01 d0                	add    %edx,%eax
  801a2b:	83 e0 1f             	and    $0x1f,%eax
  801a2e:	29 d0                	sub    %edx,%eax
  801a30:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a38:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a3b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a3e:	83 c3 01             	add    $0x1,%ebx
  801a41:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a44:	75 d8                	jne    801a1e <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a46:	8b 45 10             	mov    0x10(%ebp),%eax
  801a49:	eb 05                	jmp    801a50 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a4b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a53:	5b                   	pop    %ebx
  801a54:	5e                   	pop    %esi
  801a55:	5f                   	pop    %edi
  801a56:	5d                   	pop    %ebp
  801a57:	c3                   	ret    

00801a58 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a58:	55                   	push   %ebp
  801a59:	89 e5                	mov    %esp,%ebp
  801a5b:	56                   	push   %esi
  801a5c:	53                   	push   %ebx
  801a5d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a60:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a63:	50                   	push   %eax
  801a64:	e8 35 f6 ff ff       	call   80109e <fd_alloc>
  801a69:	83 c4 10             	add    $0x10,%esp
  801a6c:	89 c2                	mov    %eax,%edx
  801a6e:	85 c0                	test   %eax,%eax
  801a70:	0f 88 2c 01 00 00    	js     801ba2 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a76:	83 ec 04             	sub    $0x4,%esp
  801a79:	68 07 04 00 00       	push   $0x407
  801a7e:	ff 75 f4             	pushl  -0xc(%ebp)
  801a81:	6a 00                	push   $0x0
  801a83:	e8 a5 f1 ff ff       	call   800c2d <sys_page_alloc>
  801a88:	83 c4 10             	add    $0x10,%esp
  801a8b:	89 c2                	mov    %eax,%edx
  801a8d:	85 c0                	test   %eax,%eax
  801a8f:	0f 88 0d 01 00 00    	js     801ba2 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a95:	83 ec 0c             	sub    $0xc,%esp
  801a98:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a9b:	50                   	push   %eax
  801a9c:	e8 fd f5 ff ff       	call   80109e <fd_alloc>
  801aa1:	89 c3                	mov    %eax,%ebx
  801aa3:	83 c4 10             	add    $0x10,%esp
  801aa6:	85 c0                	test   %eax,%eax
  801aa8:	0f 88 e2 00 00 00    	js     801b90 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aae:	83 ec 04             	sub    $0x4,%esp
  801ab1:	68 07 04 00 00       	push   $0x407
  801ab6:	ff 75 f0             	pushl  -0x10(%ebp)
  801ab9:	6a 00                	push   $0x0
  801abb:	e8 6d f1 ff ff       	call   800c2d <sys_page_alloc>
  801ac0:	89 c3                	mov    %eax,%ebx
  801ac2:	83 c4 10             	add    $0x10,%esp
  801ac5:	85 c0                	test   %eax,%eax
  801ac7:	0f 88 c3 00 00 00    	js     801b90 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801acd:	83 ec 0c             	sub    $0xc,%esp
  801ad0:	ff 75 f4             	pushl  -0xc(%ebp)
  801ad3:	e8 af f5 ff ff       	call   801087 <fd2data>
  801ad8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ada:	83 c4 0c             	add    $0xc,%esp
  801add:	68 07 04 00 00       	push   $0x407
  801ae2:	50                   	push   %eax
  801ae3:	6a 00                	push   $0x0
  801ae5:	e8 43 f1 ff ff       	call   800c2d <sys_page_alloc>
  801aea:	89 c3                	mov    %eax,%ebx
  801aec:	83 c4 10             	add    $0x10,%esp
  801aef:	85 c0                	test   %eax,%eax
  801af1:	0f 88 89 00 00 00    	js     801b80 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801af7:	83 ec 0c             	sub    $0xc,%esp
  801afa:	ff 75 f0             	pushl  -0x10(%ebp)
  801afd:	e8 85 f5 ff ff       	call   801087 <fd2data>
  801b02:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b09:	50                   	push   %eax
  801b0a:	6a 00                	push   $0x0
  801b0c:	56                   	push   %esi
  801b0d:	6a 00                	push   $0x0
  801b0f:	e8 5c f1 ff ff       	call   800c70 <sys_page_map>
  801b14:	89 c3                	mov    %eax,%ebx
  801b16:	83 c4 20             	add    $0x20,%esp
  801b19:	85 c0                	test   %eax,%eax
  801b1b:	78 55                	js     801b72 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b1d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b23:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b26:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b2b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b32:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b38:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b3b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b40:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b47:	83 ec 0c             	sub    $0xc,%esp
  801b4a:	ff 75 f4             	pushl  -0xc(%ebp)
  801b4d:	e8 25 f5 ff ff       	call   801077 <fd2num>
  801b52:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b55:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b57:	83 c4 04             	add    $0x4,%esp
  801b5a:	ff 75 f0             	pushl  -0x10(%ebp)
  801b5d:	e8 15 f5 ff ff       	call   801077 <fd2num>
  801b62:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b65:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801b68:	83 c4 10             	add    $0x10,%esp
  801b6b:	ba 00 00 00 00       	mov    $0x0,%edx
  801b70:	eb 30                	jmp    801ba2 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b72:	83 ec 08             	sub    $0x8,%esp
  801b75:	56                   	push   %esi
  801b76:	6a 00                	push   $0x0
  801b78:	e8 35 f1 ff ff       	call   800cb2 <sys_page_unmap>
  801b7d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b80:	83 ec 08             	sub    $0x8,%esp
  801b83:	ff 75 f0             	pushl  -0x10(%ebp)
  801b86:	6a 00                	push   $0x0
  801b88:	e8 25 f1 ff ff       	call   800cb2 <sys_page_unmap>
  801b8d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b90:	83 ec 08             	sub    $0x8,%esp
  801b93:	ff 75 f4             	pushl  -0xc(%ebp)
  801b96:	6a 00                	push   $0x0
  801b98:	e8 15 f1 ff ff       	call   800cb2 <sys_page_unmap>
  801b9d:	83 c4 10             	add    $0x10,%esp
  801ba0:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801ba2:	89 d0                	mov    %edx,%eax
  801ba4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ba7:	5b                   	pop    %ebx
  801ba8:	5e                   	pop    %esi
  801ba9:	5d                   	pop    %ebp
  801baa:	c3                   	ret    

00801bab <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801bab:	55                   	push   %ebp
  801bac:	89 e5                	mov    %esp,%ebp
  801bae:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bb1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bb4:	50                   	push   %eax
  801bb5:	ff 75 08             	pushl  0x8(%ebp)
  801bb8:	e8 30 f5 ff ff       	call   8010ed <fd_lookup>
  801bbd:	83 c4 10             	add    $0x10,%esp
  801bc0:	85 c0                	test   %eax,%eax
  801bc2:	78 18                	js     801bdc <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801bc4:	83 ec 0c             	sub    $0xc,%esp
  801bc7:	ff 75 f4             	pushl  -0xc(%ebp)
  801bca:	e8 b8 f4 ff ff       	call   801087 <fd2data>
	return _pipeisclosed(fd, p);
  801bcf:	89 c2                	mov    %eax,%edx
  801bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bd4:	e8 21 fd ff ff       	call   8018fa <_pipeisclosed>
  801bd9:	83 c4 10             	add    $0x10,%esp
}
  801bdc:	c9                   	leave  
  801bdd:	c3                   	ret    

00801bde <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801bde:	55                   	push   %ebp
  801bdf:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801be1:	b8 00 00 00 00       	mov    $0x0,%eax
  801be6:	5d                   	pop    %ebp
  801be7:	c3                   	ret    

00801be8 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801be8:	55                   	push   %ebp
  801be9:	89 e5                	mov    %esp,%ebp
  801beb:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801bee:	68 96 26 80 00       	push   $0x802696
  801bf3:	ff 75 0c             	pushl  0xc(%ebp)
  801bf6:	e8 2f ec ff ff       	call   80082a <strcpy>
	return 0;
}
  801bfb:	b8 00 00 00 00       	mov    $0x0,%eax
  801c00:	c9                   	leave  
  801c01:	c3                   	ret    

00801c02 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c02:	55                   	push   %ebp
  801c03:	89 e5                	mov    %esp,%ebp
  801c05:	57                   	push   %edi
  801c06:	56                   	push   %esi
  801c07:	53                   	push   %ebx
  801c08:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c0e:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c13:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c19:	eb 2d                	jmp    801c48 <devcons_write+0x46>
		m = n - tot;
  801c1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c1e:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801c20:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c23:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c28:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c2b:	83 ec 04             	sub    $0x4,%esp
  801c2e:	53                   	push   %ebx
  801c2f:	03 45 0c             	add    0xc(%ebp),%eax
  801c32:	50                   	push   %eax
  801c33:	57                   	push   %edi
  801c34:	e8 83 ed ff ff       	call   8009bc <memmove>
		sys_cputs(buf, m);
  801c39:	83 c4 08             	add    $0x8,%esp
  801c3c:	53                   	push   %ebx
  801c3d:	57                   	push   %edi
  801c3e:	e8 2e ef ff ff       	call   800b71 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c43:	01 de                	add    %ebx,%esi
  801c45:	83 c4 10             	add    $0x10,%esp
  801c48:	89 f0                	mov    %esi,%eax
  801c4a:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c4d:	72 cc                	jb     801c1b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c52:	5b                   	pop    %ebx
  801c53:	5e                   	pop    %esi
  801c54:	5f                   	pop    %edi
  801c55:	5d                   	pop    %ebp
  801c56:	c3                   	ret    

00801c57 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c57:	55                   	push   %ebp
  801c58:	89 e5                	mov    %esp,%ebp
  801c5a:	83 ec 08             	sub    $0x8,%esp
  801c5d:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801c62:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c66:	74 2a                	je     801c92 <devcons_read+0x3b>
  801c68:	eb 05                	jmp    801c6f <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c6a:	e8 9f ef ff ff       	call   800c0e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c6f:	e8 1b ef ff ff       	call   800b8f <sys_cgetc>
  801c74:	85 c0                	test   %eax,%eax
  801c76:	74 f2                	je     801c6a <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801c78:	85 c0                	test   %eax,%eax
  801c7a:	78 16                	js     801c92 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c7c:	83 f8 04             	cmp    $0x4,%eax
  801c7f:	74 0c                	je     801c8d <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801c81:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c84:	88 02                	mov    %al,(%edx)
	return 1;
  801c86:	b8 01 00 00 00       	mov    $0x1,%eax
  801c8b:	eb 05                	jmp    801c92 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c8d:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c92:	c9                   	leave  
  801c93:	c3                   	ret    

00801c94 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c94:	55                   	push   %ebp
  801c95:	89 e5                	mov    %esp,%ebp
  801c97:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c9a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c9d:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ca0:	6a 01                	push   $0x1
  801ca2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ca5:	50                   	push   %eax
  801ca6:	e8 c6 ee ff ff       	call   800b71 <sys_cputs>
}
  801cab:	83 c4 10             	add    $0x10,%esp
  801cae:	c9                   	leave  
  801caf:	c3                   	ret    

00801cb0 <getchar>:

int
getchar(void)
{
  801cb0:	55                   	push   %ebp
  801cb1:	89 e5                	mov    %esp,%ebp
  801cb3:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801cb6:	6a 01                	push   $0x1
  801cb8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cbb:	50                   	push   %eax
  801cbc:	6a 00                	push   $0x0
  801cbe:	e8 90 f6 ff ff       	call   801353 <read>
	if (r < 0)
  801cc3:	83 c4 10             	add    $0x10,%esp
  801cc6:	85 c0                	test   %eax,%eax
  801cc8:	78 0f                	js     801cd9 <getchar+0x29>
		return r;
	if (r < 1)
  801cca:	85 c0                	test   %eax,%eax
  801ccc:	7e 06                	jle    801cd4 <getchar+0x24>
		return -E_EOF;
	return c;
  801cce:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801cd2:	eb 05                	jmp    801cd9 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801cd4:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801cd9:	c9                   	leave  
  801cda:	c3                   	ret    

00801cdb <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801cdb:	55                   	push   %ebp
  801cdc:	89 e5                	mov    %esp,%ebp
  801cde:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ce1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ce4:	50                   	push   %eax
  801ce5:	ff 75 08             	pushl  0x8(%ebp)
  801ce8:	e8 00 f4 ff ff       	call   8010ed <fd_lookup>
  801ced:	83 c4 10             	add    $0x10,%esp
  801cf0:	85 c0                	test   %eax,%eax
  801cf2:	78 11                	js     801d05 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801cf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cf7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cfd:	39 10                	cmp    %edx,(%eax)
  801cff:	0f 94 c0             	sete   %al
  801d02:	0f b6 c0             	movzbl %al,%eax
}
  801d05:	c9                   	leave  
  801d06:	c3                   	ret    

00801d07 <opencons>:

int
opencons(void)
{
  801d07:	55                   	push   %ebp
  801d08:	89 e5                	mov    %esp,%ebp
  801d0a:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d0d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d10:	50                   	push   %eax
  801d11:	e8 88 f3 ff ff       	call   80109e <fd_alloc>
  801d16:	83 c4 10             	add    $0x10,%esp
		return r;
  801d19:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d1b:	85 c0                	test   %eax,%eax
  801d1d:	78 3e                	js     801d5d <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d1f:	83 ec 04             	sub    $0x4,%esp
  801d22:	68 07 04 00 00       	push   $0x407
  801d27:	ff 75 f4             	pushl  -0xc(%ebp)
  801d2a:	6a 00                	push   $0x0
  801d2c:	e8 fc ee ff ff       	call   800c2d <sys_page_alloc>
  801d31:	83 c4 10             	add    $0x10,%esp
		return r;
  801d34:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d36:	85 c0                	test   %eax,%eax
  801d38:	78 23                	js     801d5d <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d3a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d40:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d43:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d45:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d48:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d4f:	83 ec 0c             	sub    $0xc,%esp
  801d52:	50                   	push   %eax
  801d53:	e8 1f f3 ff ff       	call   801077 <fd2num>
  801d58:	89 c2                	mov    %eax,%edx
  801d5a:	83 c4 10             	add    $0x10,%esp
}
  801d5d:	89 d0                	mov    %edx,%eax
  801d5f:	c9                   	leave  
  801d60:	c3                   	ret    

00801d61 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d61:	55                   	push   %ebp
  801d62:	89 e5                	mov    %esp,%ebp
  801d64:	53                   	push   %ebx
  801d65:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d68:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d6f:	75 28                	jne    801d99 <set_pgfault_handler+0x38>
		// First time through!
		// LAB 4: Your code here.
		void *va = (void *) (UXSTACKTOP - PGSIZE);
		envid_t envid = sys_getenvid();
  801d71:	e8 79 ee ff ff       	call   800bef <sys_getenvid>
  801d76:	89 c3                	mov    %eax,%ebx

		sys_page_alloc(envid, va, PTE_P | PTE_U | PTE_W);
  801d78:	83 ec 04             	sub    $0x4,%esp
  801d7b:	6a 07                	push   $0x7
  801d7d:	68 00 f0 bf ee       	push   $0xeebff000
  801d82:	50                   	push   %eax
  801d83:	e8 a5 ee ff ff       	call   800c2d <sys_page_alloc>
		sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801d88:	83 c4 08             	add    $0x8,%esp
  801d8b:	68 a6 1d 80 00       	push   $0x801da6
  801d90:	53                   	push   %ebx
  801d91:	e8 e2 ef ff ff       	call   800d78 <sys_env_set_pgfault_upcall>
  801d96:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801d99:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9c:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801da1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801da4:	c9                   	leave  
  801da5:	c3                   	ret    

00801da6 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp				// function argument: pointer to UTF
  801da6:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801da7:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801dac:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801dae:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl %esp, %ebx		// 40 = size between utf_fault_va ~ utf_regs
  801db1:	89 e3                	mov    %esp,%ebx
	movl 40(%esp), %eax // point to utf_eip
  801db3:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %esp // point to utf_esp
  801db7:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %eax 			// push eip of utf
  801dbb:	50                   	push   %eax

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	movl %ebx, %esp 	// back to origin exception stack
  801dbc:	89 dc                	mov    %ebx,%esp
	subl $4, 48(%esp) 	// utf_esp - 4
  801dbe:	83 6c 24 30 04       	subl   $0x4,0x30(%esp)
	popl %eax  			// pop utf_fault_va (ignore)
  801dc3:	58                   	pop    %eax
	popl %eax  			// pop utf_err (ignore)
  801dc4:	58                   	pop    %eax
	popal 				// pop utf_regs 
  801dc5:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4, %esp 		// ignore utf_eip
  801dc6:	83 c4 04             	add    $0x4,%esp
	popfl 				// restore utf_eflags to eflags
  801dc9:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp  			// restore %esp = utf_esp
  801dca:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801dcb:	c3                   	ret    

00801dcc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801dcc:	55                   	push   %ebp
  801dcd:	89 e5                	mov    %esp,%ebp
  801dcf:	56                   	push   %esi
  801dd0:	53                   	push   %ebx
  801dd1:	8b 75 08             	mov    0x8(%ebp),%esi
  801dd4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dd7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

    if (pg != NULL)
  801dda:	85 c0                	test   %eax,%eax
  801ddc:	74 0e                	je     801dec <ipc_recv+0x20>
        r = sys_ipc_recv(pg);
  801dde:	83 ec 0c             	sub    $0xc,%esp
  801de1:	50                   	push   %eax
  801de2:	e8 f6 ef ff ff       	call   800ddd <sys_ipc_recv>
  801de7:	83 c4 10             	add    $0x10,%esp
  801dea:	eb 0d                	jmp    801df9 <ipc_recv+0x2d>
	else
        r = sys_ipc_recv((void *)-1);
  801dec:	83 ec 0c             	sub    $0xc,%esp
  801def:	6a ff                	push   $0xffffffff
  801df1:	e8 e7 ef ff ff       	call   800ddd <sys_ipc_recv>
  801df6:	83 c4 10             	add    $0x10,%esp

	if (r < 0) {
  801df9:	85 c0                	test   %eax,%eax
  801dfb:	79 16                	jns    801e13 <ipc_recv+0x47>

		if (from_env_store != NULL)
  801dfd:	85 f6                	test   %esi,%esi
  801dff:	74 06                	je     801e07 <ipc_recv+0x3b>
			*from_env_store = 0;
  801e01:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store != NULL)
  801e07:	85 db                	test   %ebx,%ebx
  801e09:	74 2c                	je     801e37 <ipc_recv+0x6b>
			*perm_store = 0;
  801e0b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801e11:	eb 24                	jmp    801e37 <ipc_recv+0x6b>
		return r;

	} else {

		if (from_env_store != NULL)
  801e13:	85 f6                	test   %esi,%esi
  801e15:	74 0a                	je     801e21 <ipc_recv+0x55>
			*from_env_store = thisenv->env_ipc_from;
  801e17:	a1 08 40 80 00       	mov    0x804008,%eax
  801e1c:	8b 40 74             	mov    0x74(%eax),%eax
  801e1f:	89 06                	mov    %eax,(%esi)
		if (perm_store != NULL)
  801e21:	85 db                	test   %ebx,%ebx
  801e23:	74 0a                	je     801e2f <ipc_recv+0x63>
			*perm_store = thisenv->env_ipc_perm;
  801e25:	a1 08 40 80 00       	mov    0x804008,%eax
  801e2a:	8b 40 78             	mov    0x78(%eax),%eax
  801e2d:	89 03                	mov    %eax,(%ebx)
		return thisenv->env_ipc_value;
  801e2f:	a1 08 40 80 00       	mov    0x804008,%eax
  801e34:	8b 40 70             	mov    0x70(%eax),%eax
	}
}
  801e37:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e3a:	5b                   	pop    %ebx
  801e3b:	5e                   	pop    %esi
  801e3c:	5d                   	pop    %ebp
  801e3d:	c3                   	ret    

00801e3e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e3e:	55                   	push   %ebp
  801e3f:	89 e5                	mov    %esp,%ebp
  801e41:	57                   	push   %edi
  801e42:	56                   	push   %esi
  801e43:	53                   	push   %ebx
  801e44:	83 ec 0c             	sub    $0xc,%esp
  801e47:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e4a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e4d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;

	if (pg == NULL)
  801e50:	85 db                	test   %ebx,%ebx
		pg = (void *)-1;	
  801e52:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801e57:	0f 44 d8             	cmove  %eax,%ebx

	while (true) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  801e5a:	ff 75 14             	pushl  0x14(%ebp)
  801e5d:	53                   	push   %ebx
  801e5e:	56                   	push   %esi
  801e5f:	57                   	push   %edi
  801e60:	e8 55 ef ff ff       	call   800dba <sys_ipc_try_send>
		if (r >= 0)
  801e65:	83 c4 10             	add    $0x10,%esp
  801e68:	85 c0                	test   %eax,%eax
  801e6a:	79 1e                	jns    801e8a <ipc_send+0x4c>
			return;
		else if (r != -E_IPC_NOT_RECV)
  801e6c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e6f:	74 12                	je     801e83 <ipc_send+0x45>
			panic("ipc_send error: %e", r);
  801e71:	50                   	push   %eax
  801e72:	68 a2 26 80 00       	push   $0x8026a2
  801e77:	6a 49                	push   $0x49
  801e79:	68 b5 26 80 00       	push   $0x8026b5
  801e7e:	e8 ca e2 ff ff       	call   80014d <_panic>
	
		sys_yield();
  801e83:	e8 86 ed ff ff       	call   800c0e <sys_yield>
	}
  801e88:	eb d0                	jmp    801e5a <ipc_send+0x1c>
	//panic("ipc_send not implemented");
}
  801e8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e8d:	5b                   	pop    %ebx
  801e8e:	5e                   	pop    %esi
  801e8f:	5f                   	pop    %edi
  801e90:	5d                   	pop    %ebp
  801e91:	c3                   	ret    

00801e92 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801e92:	55                   	push   %ebp
  801e93:	89 e5                	mov    %esp,%ebp
  801e95:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801e98:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801e9d:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ea0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ea6:	8b 52 50             	mov    0x50(%edx),%edx
  801ea9:	39 ca                	cmp    %ecx,%edx
  801eab:	75 0d                	jne    801eba <ipc_find_env+0x28>
			return envs[i].env_id;
  801ead:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801eb0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801eb5:	8b 40 48             	mov    0x48(%eax),%eax
  801eb8:	eb 0f                	jmp    801ec9 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801eba:	83 c0 01             	add    $0x1,%eax
  801ebd:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ec2:	75 d9                	jne    801e9d <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ec4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ec9:	5d                   	pop    %ebp
  801eca:	c3                   	ret    

00801ecb <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ecb:	55                   	push   %ebp
  801ecc:	89 e5                	mov    %esp,%ebp
  801ece:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ed1:	89 d0                	mov    %edx,%eax
  801ed3:	c1 e8 16             	shr    $0x16,%eax
  801ed6:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801edd:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ee2:	f6 c1 01             	test   $0x1,%cl
  801ee5:	74 1d                	je     801f04 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ee7:	c1 ea 0c             	shr    $0xc,%edx
  801eea:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ef1:	f6 c2 01             	test   $0x1,%dl
  801ef4:	74 0e                	je     801f04 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ef6:	c1 ea 0c             	shr    $0xc,%edx
  801ef9:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f00:	ef 
  801f01:	0f b7 c0             	movzwl %ax,%eax
}
  801f04:	5d                   	pop    %ebp
  801f05:	c3                   	ret    
  801f06:	66 90                	xchg   %ax,%ax
  801f08:	66 90                	xchg   %ax,%ax
  801f0a:	66 90                	xchg   %ax,%ax
  801f0c:	66 90                	xchg   %ax,%ax
  801f0e:	66 90                	xchg   %ax,%ax

00801f10 <__udivdi3>:
  801f10:	55                   	push   %ebp
  801f11:	57                   	push   %edi
  801f12:	56                   	push   %esi
  801f13:	53                   	push   %ebx
  801f14:	83 ec 1c             	sub    $0x1c,%esp
  801f17:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f1b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f1f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f27:	85 f6                	test   %esi,%esi
  801f29:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f2d:	89 ca                	mov    %ecx,%edx
  801f2f:	89 f8                	mov    %edi,%eax
  801f31:	75 3d                	jne    801f70 <__udivdi3+0x60>
  801f33:	39 cf                	cmp    %ecx,%edi
  801f35:	0f 87 c5 00 00 00    	ja     802000 <__udivdi3+0xf0>
  801f3b:	85 ff                	test   %edi,%edi
  801f3d:	89 fd                	mov    %edi,%ebp
  801f3f:	75 0b                	jne    801f4c <__udivdi3+0x3c>
  801f41:	b8 01 00 00 00       	mov    $0x1,%eax
  801f46:	31 d2                	xor    %edx,%edx
  801f48:	f7 f7                	div    %edi
  801f4a:	89 c5                	mov    %eax,%ebp
  801f4c:	89 c8                	mov    %ecx,%eax
  801f4e:	31 d2                	xor    %edx,%edx
  801f50:	f7 f5                	div    %ebp
  801f52:	89 c1                	mov    %eax,%ecx
  801f54:	89 d8                	mov    %ebx,%eax
  801f56:	89 cf                	mov    %ecx,%edi
  801f58:	f7 f5                	div    %ebp
  801f5a:	89 c3                	mov    %eax,%ebx
  801f5c:	89 d8                	mov    %ebx,%eax
  801f5e:	89 fa                	mov    %edi,%edx
  801f60:	83 c4 1c             	add    $0x1c,%esp
  801f63:	5b                   	pop    %ebx
  801f64:	5e                   	pop    %esi
  801f65:	5f                   	pop    %edi
  801f66:	5d                   	pop    %ebp
  801f67:	c3                   	ret    
  801f68:	90                   	nop
  801f69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f70:	39 ce                	cmp    %ecx,%esi
  801f72:	77 74                	ja     801fe8 <__udivdi3+0xd8>
  801f74:	0f bd fe             	bsr    %esi,%edi
  801f77:	83 f7 1f             	xor    $0x1f,%edi
  801f7a:	0f 84 98 00 00 00    	je     802018 <__udivdi3+0x108>
  801f80:	bb 20 00 00 00       	mov    $0x20,%ebx
  801f85:	89 f9                	mov    %edi,%ecx
  801f87:	89 c5                	mov    %eax,%ebp
  801f89:	29 fb                	sub    %edi,%ebx
  801f8b:	d3 e6                	shl    %cl,%esi
  801f8d:	89 d9                	mov    %ebx,%ecx
  801f8f:	d3 ed                	shr    %cl,%ebp
  801f91:	89 f9                	mov    %edi,%ecx
  801f93:	d3 e0                	shl    %cl,%eax
  801f95:	09 ee                	or     %ebp,%esi
  801f97:	89 d9                	mov    %ebx,%ecx
  801f99:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f9d:	89 d5                	mov    %edx,%ebp
  801f9f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801fa3:	d3 ed                	shr    %cl,%ebp
  801fa5:	89 f9                	mov    %edi,%ecx
  801fa7:	d3 e2                	shl    %cl,%edx
  801fa9:	89 d9                	mov    %ebx,%ecx
  801fab:	d3 e8                	shr    %cl,%eax
  801fad:	09 c2                	or     %eax,%edx
  801faf:	89 d0                	mov    %edx,%eax
  801fb1:	89 ea                	mov    %ebp,%edx
  801fb3:	f7 f6                	div    %esi
  801fb5:	89 d5                	mov    %edx,%ebp
  801fb7:	89 c3                	mov    %eax,%ebx
  801fb9:	f7 64 24 0c          	mull   0xc(%esp)
  801fbd:	39 d5                	cmp    %edx,%ebp
  801fbf:	72 10                	jb     801fd1 <__udivdi3+0xc1>
  801fc1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801fc5:	89 f9                	mov    %edi,%ecx
  801fc7:	d3 e6                	shl    %cl,%esi
  801fc9:	39 c6                	cmp    %eax,%esi
  801fcb:	73 07                	jae    801fd4 <__udivdi3+0xc4>
  801fcd:	39 d5                	cmp    %edx,%ebp
  801fcf:	75 03                	jne    801fd4 <__udivdi3+0xc4>
  801fd1:	83 eb 01             	sub    $0x1,%ebx
  801fd4:	31 ff                	xor    %edi,%edi
  801fd6:	89 d8                	mov    %ebx,%eax
  801fd8:	89 fa                	mov    %edi,%edx
  801fda:	83 c4 1c             	add    $0x1c,%esp
  801fdd:	5b                   	pop    %ebx
  801fde:	5e                   	pop    %esi
  801fdf:	5f                   	pop    %edi
  801fe0:	5d                   	pop    %ebp
  801fe1:	c3                   	ret    
  801fe2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801fe8:	31 ff                	xor    %edi,%edi
  801fea:	31 db                	xor    %ebx,%ebx
  801fec:	89 d8                	mov    %ebx,%eax
  801fee:	89 fa                	mov    %edi,%edx
  801ff0:	83 c4 1c             	add    $0x1c,%esp
  801ff3:	5b                   	pop    %ebx
  801ff4:	5e                   	pop    %esi
  801ff5:	5f                   	pop    %edi
  801ff6:	5d                   	pop    %ebp
  801ff7:	c3                   	ret    
  801ff8:	90                   	nop
  801ff9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802000:	89 d8                	mov    %ebx,%eax
  802002:	f7 f7                	div    %edi
  802004:	31 ff                	xor    %edi,%edi
  802006:	89 c3                	mov    %eax,%ebx
  802008:	89 d8                	mov    %ebx,%eax
  80200a:	89 fa                	mov    %edi,%edx
  80200c:	83 c4 1c             	add    $0x1c,%esp
  80200f:	5b                   	pop    %ebx
  802010:	5e                   	pop    %esi
  802011:	5f                   	pop    %edi
  802012:	5d                   	pop    %ebp
  802013:	c3                   	ret    
  802014:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802018:	39 ce                	cmp    %ecx,%esi
  80201a:	72 0c                	jb     802028 <__udivdi3+0x118>
  80201c:	31 db                	xor    %ebx,%ebx
  80201e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802022:	0f 87 34 ff ff ff    	ja     801f5c <__udivdi3+0x4c>
  802028:	bb 01 00 00 00       	mov    $0x1,%ebx
  80202d:	e9 2a ff ff ff       	jmp    801f5c <__udivdi3+0x4c>
  802032:	66 90                	xchg   %ax,%ax
  802034:	66 90                	xchg   %ax,%ax
  802036:	66 90                	xchg   %ax,%ax
  802038:	66 90                	xchg   %ax,%ax
  80203a:	66 90                	xchg   %ax,%ax
  80203c:	66 90                	xchg   %ax,%ax
  80203e:	66 90                	xchg   %ax,%ax

00802040 <__umoddi3>:
  802040:	55                   	push   %ebp
  802041:	57                   	push   %edi
  802042:	56                   	push   %esi
  802043:	53                   	push   %ebx
  802044:	83 ec 1c             	sub    $0x1c,%esp
  802047:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80204b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80204f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802053:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802057:	85 d2                	test   %edx,%edx
  802059:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80205d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802061:	89 f3                	mov    %esi,%ebx
  802063:	89 3c 24             	mov    %edi,(%esp)
  802066:	89 74 24 04          	mov    %esi,0x4(%esp)
  80206a:	75 1c                	jne    802088 <__umoddi3+0x48>
  80206c:	39 f7                	cmp    %esi,%edi
  80206e:	76 50                	jbe    8020c0 <__umoddi3+0x80>
  802070:	89 c8                	mov    %ecx,%eax
  802072:	89 f2                	mov    %esi,%edx
  802074:	f7 f7                	div    %edi
  802076:	89 d0                	mov    %edx,%eax
  802078:	31 d2                	xor    %edx,%edx
  80207a:	83 c4 1c             	add    $0x1c,%esp
  80207d:	5b                   	pop    %ebx
  80207e:	5e                   	pop    %esi
  80207f:	5f                   	pop    %edi
  802080:	5d                   	pop    %ebp
  802081:	c3                   	ret    
  802082:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802088:	39 f2                	cmp    %esi,%edx
  80208a:	89 d0                	mov    %edx,%eax
  80208c:	77 52                	ja     8020e0 <__umoddi3+0xa0>
  80208e:	0f bd ea             	bsr    %edx,%ebp
  802091:	83 f5 1f             	xor    $0x1f,%ebp
  802094:	75 5a                	jne    8020f0 <__umoddi3+0xb0>
  802096:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80209a:	0f 82 e0 00 00 00    	jb     802180 <__umoddi3+0x140>
  8020a0:	39 0c 24             	cmp    %ecx,(%esp)
  8020a3:	0f 86 d7 00 00 00    	jbe    802180 <__umoddi3+0x140>
  8020a9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020ad:	8b 54 24 04          	mov    0x4(%esp),%edx
  8020b1:	83 c4 1c             	add    $0x1c,%esp
  8020b4:	5b                   	pop    %ebx
  8020b5:	5e                   	pop    %esi
  8020b6:	5f                   	pop    %edi
  8020b7:	5d                   	pop    %ebp
  8020b8:	c3                   	ret    
  8020b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020c0:	85 ff                	test   %edi,%edi
  8020c2:	89 fd                	mov    %edi,%ebp
  8020c4:	75 0b                	jne    8020d1 <__umoddi3+0x91>
  8020c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8020cb:	31 d2                	xor    %edx,%edx
  8020cd:	f7 f7                	div    %edi
  8020cf:	89 c5                	mov    %eax,%ebp
  8020d1:	89 f0                	mov    %esi,%eax
  8020d3:	31 d2                	xor    %edx,%edx
  8020d5:	f7 f5                	div    %ebp
  8020d7:	89 c8                	mov    %ecx,%eax
  8020d9:	f7 f5                	div    %ebp
  8020db:	89 d0                	mov    %edx,%eax
  8020dd:	eb 99                	jmp    802078 <__umoddi3+0x38>
  8020df:	90                   	nop
  8020e0:	89 c8                	mov    %ecx,%eax
  8020e2:	89 f2                	mov    %esi,%edx
  8020e4:	83 c4 1c             	add    $0x1c,%esp
  8020e7:	5b                   	pop    %ebx
  8020e8:	5e                   	pop    %esi
  8020e9:	5f                   	pop    %edi
  8020ea:	5d                   	pop    %ebp
  8020eb:	c3                   	ret    
  8020ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020f0:	8b 34 24             	mov    (%esp),%esi
  8020f3:	bf 20 00 00 00       	mov    $0x20,%edi
  8020f8:	89 e9                	mov    %ebp,%ecx
  8020fa:	29 ef                	sub    %ebp,%edi
  8020fc:	d3 e0                	shl    %cl,%eax
  8020fe:	89 f9                	mov    %edi,%ecx
  802100:	89 f2                	mov    %esi,%edx
  802102:	d3 ea                	shr    %cl,%edx
  802104:	89 e9                	mov    %ebp,%ecx
  802106:	09 c2                	or     %eax,%edx
  802108:	89 d8                	mov    %ebx,%eax
  80210a:	89 14 24             	mov    %edx,(%esp)
  80210d:	89 f2                	mov    %esi,%edx
  80210f:	d3 e2                	shl    %cl,%edx
  802111:	89 f9                	mov    %edi,%ecx
  802113:	89 54 24 04          	mov    %edx,0x4(%esp)
  802117:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80211b:	d3 e8                	shr    %cl,%eax
  80211d:	89 e9                	mov    %ebp,%ecx
  80211f:	89 c6                	mov    %eax,%esi
  802121:	d3 e3                	shl    %cl,%ebx
  802123:	89 f9                	mov    %edi,%ecx
  802125:	89 d0                	mov    %edx,%eax
  802127:	d3 e8                	shr    %cl,%eax
  802129:	89 e9                	mov    %ebp,%ecx
  80212b:	09 d8                	or     %ebx,%eax
  80212d:	89 d3                	mov    %edx,%ebx
  80212f:	89 f2                	mov    %esi,%edx
  802131:	f7 34 24             	divl   (%esp)
  802134:	89 d6                	mov    %edx,%esi
  802136:	d3 e3                	shl    %cl,%ebx
  802138:	f7 64 24 04          	mull   0x4(%esp)
  80213c:	39 d6                	cmp    %edx,%esi
  80213e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802142:	89 d1                	mov    %edx,%ecx
  802144:	89 c3                	mov    %eax,%ebx
  802146:	72 08                	jb     802150 <__umoddi3+0x110>
  802148:	75 11                	jne    80215b <__umoddi3+0x11b>
  80214a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80214e:	73 0b                	jae    80215b <__umoddi3+0x11b>
  802150:	2b 44 24 04          	sub    0x4(%esp),%eax
  802154:	1b 14 24             	sbb    (%esp),%edx
  802157:	89 d1                	mov    %edx,%ecx
  802159:	89 c3                	mov    %eax,%ebx
  80215b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80215f:	29 da                	sub    %ebx,%edx
  802161:	19 ce                	sbb    %ecx,%esi
  802163:	89 f9                	mov    %edi,%ecx
  802165:	89 f0                	mov    %esi,%eax
  802167:	d3 e0                	shl    %cl,%eax
  802169:	89 e9                	mov    %ebp,%ecx
  80216b:	d3 ea                	shr    %cl,%edx
  80216d:	89 e9                	mov    %ebp,%ecx
  80216f:	d3 ee                	shr    %cl,%esi
  802171:	09 d0                	or     %edx,%eax
  802173:	89 f2                	mov    %esi,%edx
  802175:	83 c4 1c             	add    $0x1c,%esp
  802178:	5b                   	pop    %ebx
  802179:	5e                   	pop    %esi
  80217a:	5f                   	pop    %edi
  80217b:	5d                   	pop    %ebp
  80217c:	c3                   	ret    
  80217d:	8d 76 00             	lea    0x0(%esi),%esi
  802180:	29 f9                	sub    %edi,%ecx
  802182:	19 d6                	sbb    %edx,%esi
  802184:	89 74 24 04          	mov    %esi,0x4(%esp)
  802188:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80218c:	e9 18 ff ff ff       	jmp    8020a9 <__umoddi3+0x69>
